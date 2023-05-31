module game_state_updater(
    // Inputs
    input rst,

    // Input Clocks
    input vga_clock,    // Might be useless
    input blockieee_clock,
    input ddaver_clock,
    input bullet_clock,

    // Input Nunchuk Data
    input[7:0] stick_y,
    input z,
    input c,

    ////////////////////////////////////////////////////////////////////////////////////

    // Outputs
    // Blockieee Output
    output reg[3:0] blockieee_pos,

    // Ddaver Output
    output reg[11:0] ddavers [0:4][0:5],

    // Bullet Bill Output
    output reg[11:0] bulletBillColor [0:2],
    output reg[3:0] bulletBillXLoc [0:2],
    output reg[3:0] bulletBillYLoc [0:2]
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FSM State Declarations
// Blockieee States
localparam STEADY = 0;
localparam UP = 1;
localparam DOWN = 2;
localparam DEAD = 3;
// Bullet Bill States
localparam BBDNE = 0;
localparam EBLUE = 1;
localparam ERED = 2;
localparam EGREEN = 3;
// Ddaver States
localparam DDNE = 0;
localparam PURPLE = 1;
localparam ORANGE = 2;
localparam YELLOW = 3;
localparam BLUE = 4;
localparam RED = 5;
localparam GREEN = 6;

// Tolerance Parameter
localparam SENSITIVITY = 20;
localparam DEADLOC = 0;             // TODO: Update this value later (Calibrate)

// User Experience
reg[3:0] curr_pos = 4'd5;
reg isBlockieeeDead = 0;                // LOSE Parameter

// Firing Mechanics
reg isCollided [0:2];

// Bullet Bill Position Tracer
reg[3:0] bulletBill_curr_XLoc [0:2];
reg[3:0] bulletBill_curr_YLoc [0:2];

// Hitting Mechanics (as in the Ddaver that has been hit)
/*
    Description:
        If a DDaver is hit the main operation in the state machine is to change its color state. The rest of the operation
        should occur in the always @ (posedge) block. However, this block should implement some register which is able to
        idenitfy if a ddaver has been hit (a simple 1 bit reg) should do. This should soley identify if it is hit.

        The register is 2 bit to correspond with the initial hit color to allow FSM logic flow
        0 - no hit by any bulletBill
        1 - HIT by Blue bulletBill
        2 - HIT by Red bulletBill
        3 - HIT by Green bulletBill
*/

reg[1:0] isHit [0:4][0:5];
reg secondTime [0:4][0:5];
reg[2:0] otherActiveCol;
reg[2:0] activeCol;
reg[1:0] isHitAgain [0:4][0:5];

// FSM State
// Blockieee
reg[1:0] blockieee_state = STEADY;
reg[1:0] next_blockieee_state = STEADY;

// Bullet Bill
reg[1:0] bulletBill_state[0:2];
reg[1:0] next_bulletBill_state[0:2];
reg isEnd[0:2];
reg[1:0] nextUp;

// Ddaver
reg[2:0] ddaver_state [0:4][0:5];
reg[2:0] next_ddaver_state [0:4][0:5];

// Initialize registers
integer i;
integer j;
initial begin
    // Initialize bullet bill parameters
    nextUp = 2'd0;
    for (i = 0; i < 3; i = i + 1) begin
        // Location initials
        bulletBill_curr_XLoc[i] = 4'd0;
        bulletBill_curr_YLoc[i] = 4'd0;
        // State initials
        bulletBill_state[i] = BBDNE;
        next_bulletBill_state[i] = BBDNE;
        // Collision initials
        isCollided[i] = 0;
        isEnd[i] = 0;
    end

    // Initialize ddaver parameters
    otherActiveCol = 3'd0;
    activeCol = 3'd6;
	for (i = 0; i < 5; i = i + 1) begin
		for (j = 0; j < 6; j = j + 1) begin
        // Initialize isHit to 0
			isHit[i][j] = 0;
			isHitAgain[i][j] = 0;
            secondTime[i][j] = 0;
        // Initialize states to DNE
			ddaver_state[i][j] = DDNE;
			next_ddaver_state[i][j] = DDNE;
		end
	end
end

//Instantialize color randomizer
color_randomizer wanda_vision(ddaver_clock, rst, ddaver_color); 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// FSM Sequential Logic
/*
    An Interlude:
        Ever wonder why Computer Scientists and Computer Engineers always are in pain. Welp. This next portion is an example
        of why. Jokes aside, the sequential logic is based on various clocking cycles all at their posedge. The explanation of
        the logic behind the sequential lies here:
            - vga_clock: The posedge for this clock will be used for reseting gameplay and tracing important values
            - blockieee_clock: The posedge for this clock will be used to update the position states of the MC depending on
                nunchuck input.
            - ddaver_clock: The posedge for this clock will be used to update the movement of the ddavers across the screen
                from R -> L. If the enemy crosses "homeworld" then the lose register will be activated.
            - bulletBill: The posedge for this clock will be used to update the movement of the bullets across the screen from
                L -> R. If the bullet hits an enemy space that is colored the appropriate color then this will also update the
                isHit OR the isHitAgain registers with the appropriate color of the bullet (in state form)
*/

// General Gameplay
always @(posedge vga_clock) begin
    // Reset Logistics + IF YOU ARE A LOOOOOOOOSERRRRRRR
    if (rst || isBlockieeeDead) begin
        // Reinitialize Blockieee Operators
        curr_pos <= 4'd5;
        // Reinitialize Bullet Bill Operators
        nextUp <= 2'd0;
        for (i = 0; i < 3; i = i + 1) begin
            bulletBill_curr_XLoc[i] <= 4'd0;
            bulletBill_curr_YLoc[i] <= 4'd0;
            isCollided[i] <= 0;
            isEnd[i] <= 0;
        end
        // Reinitialize Ddaver Operators
        otherActiveCol <= 3'd0;
        activeCol <= 3'd6;
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 6; j = j + 1) begin
			    isHit[i][j] <= 0;
			    isHitAgain[i][j] <= 0;
                secondTime[i][j] <= 0;
            end
        end
    end
    else begin
        curr_pos <= curr_pos;
        nextUp <= nextUp;
        for (i = 0; i < 3; i = i + 1) begin
            bulletBill_curr_XLoc[i] <= bulletBill_curr_XLoc[i];
            bulletBill_curr_YLoc[i] <= bulletBill_curr_YLoc[i];
            isCollided[i] <= isCollided[i];
            isEnd[i] <= isEnd[i];
        end
        // Reinitialize Ddaver Operators
        otherActiveCol <= otherActiveCol;
        activeCol <= activeCol;
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 6; j = j + 1) begin
			    isHit[i][j] <= isHit[i][j];
			    isHitAgain[i][j] <= isHitAgain[i][j];
                secondTime[i][j] <= secondTime[i][j];
            end
        end
    end
end

// Blockieee Gameplay
always @(posedge blockieee_clock) begin
    // If blockieee is in the Steady State
    if (blockieee_state == STEADY) begin
        // Maintain the current position
        curr_pos <= curr_pos;
    end
    // If blockiee is in the UP State
    else if (blockieee_state == UP) begin
        // Increment up one so long as it is possible
        if (curr_pos > 4'd0) begin
            curr_pos <= curr_pos - 4'd1;
        end
        else begin
            curr_pos <= curr_pos;
        end
    end
    // If blockieee is in the DOWN State
    else if (blockieee_state == DOWN) begin
        // Increment down one so long as it is possible
        if (curr_pos < 4'd10) begin
            curr_pos <= curr_pos + 4'd1;
        end
        else begin
            curr_pos <= curr_pos;
        end
    end
    // Blockieee can literally be in no other state so like tell blockieee to stop trying
    else begin
        curr_pos <= curr_pos;
    end
end

// Bullet Bill Gameplay
always @(posedge bullet_clock) begin
    // Bullet Bill 1 Implementation
    // Spawning In
    if (bulletBill_state[0] == BBDNE && next_bulletBill_state[0] != BBDNE && nextUp == 2'd0) begin
        bulletBill_curr_YLoc[0] <= curr_pos;
        bulletBill_curr_XLoc[0] <= 4'd2;
        nextUp <= 2'd1;
    end
    // Incrementation -> Collision Confirming
    else if (bulletBill_state[0] != BBDNE && next_bulletBill_state[0] != BBDNE) begin
        bulletBill_curr_YLoc[0] <= bulletBill_curr_YLoc[0];             // Bullet Bills cannot move in the y direction
        // Check if it has reached the end
        if (bulletBill_curr_XLoc[0] < 4'd15) begin
            bulletBill_curr_XLoc[0] <= bulletBill_curr_XLoc[0] + 4'd1;      // Increment by 1
            isEnd[0] <= 0;
            // Collision Confirmation
            if ((bulletBill_curr_YLoc[0] % 2 != 0) && (bulletBill_curr_XLoc[0] % 2 == 0) && (bulletBill_curr_XLoc[0] >= 4'd4) && (ddaver_state[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2] != DDNE)) begin
                // Log Bullet Bill collision data
                isCollided[0] <= 1;
                // Log color for ddaver
                isHit[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2] <= bulletBill_state[0];
                isHitAgain[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2] <= bulletBill_state[0] && secondTime[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2];
            end
            // Set arbitrary values
            else begin
                isCollided[0] <= 0;
                isHit[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2] <= BBDNE;
                isHitAgain[(bulletBill_curr_YLoc[0] - 1) / 2][(bulletBill_curr_XLoc[0] - 4) / 2] <= BBDNE;
            end
        end
        // If it has reached the end
        else begin
            bulletBill_curr_XLoc[0] <= 4'd0;
            isEnd[0] <= 1;
        end
        nextUp <= 2'd1;
    end
    // It does not exist
    else begin
        bulletBill_curr_YLoc[0] <= bulletBill_curr_YLoc[0];
        bulletBill_curr_XLoc[0] <= bulletBill_curr_XLoc[0];
        nextUp <= 2'd0;
    end

    // Bullet Bill 2 Implementation
    // Spawning In
    if (bulletBill_state[1] == BBDNE && next_bulletBill_state[1] != BBDNE && nextUp == 2'd1) begin
        bulletBill_curr_YLoc[1] <= curr_pos;
        bulletBill_curr_XLoc[1] <= 4'd2;
        nextUp <= 2'd2;
    end
    // Incrementation -> Collision Confirming
    else if (bulletBill_state[1] != BBDNE && next_bulletBill_state[1] != BBDNE) begin
        bulletBill_curr_YLoc[1] <= bulletBill_curr_YLoc[1];             // Bullet Bills cannot move in the y direction
        // Check if it has reached the end
        if (bulletBill_curr_XLoc[1] < 4'd15) begin
            bulletBill_curr_XLoc[1] <= bulletBill_curr_XLoc[1] + 4'd1;      // Increment by 1
            isEnd[1] <= 0;
            // Collision Confirmation
            if ((bulletBill_curr_YLoc[1] % 2 != 0) && (bulletBill_curr_XLoc[1] % 2 == 0) && (bulletBill_curr_XLoc[1] >= 4'd4) && (ddaver_state[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2] != DDNE)) begin
                // Log Bullet Bill collision data
                isCollided[1] <= 1;
                // Log color for ddaver
                isHit[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2] <= bulletBill_state[1];
                isHitAgain[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2] <= bulletBill_state[1] && secondTime[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2];
            end
            // Set arbitrary values
            else begin
                isCollided[1] <= 0;
                isHit[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2] <= BBDNE;
                isHitAgain[(bulletBill_curr_YLoc[1] - 1) / 2][(bulletBill_curr_XLoc[1] - 4) / 2] <= BBDNE;
            end
        end
        // If it has reached the end
        else begin
            bulletBill_curr_XLoc[1] <= 4'd0;
            isEnd[1] <= 1;
        end
        nextUp <= 2'd2;
    end
    // It does not exist
    else begin
        bulletBill_curr_YLoc[1] <= bulletBill_curr_YLoc[1];
        bulletBill_curr_XLoc[1] <= bulletBill_curr_XLoc[1];
        nextUp <= 2'd1;
    end

    // Bullet Bill 3 Implementation
    // Spawning In
    if (bulletBill_state[2] == BBDNE && next_bulletBill_state[2] != BBDNE && nextUp == 2'd2) begin
        bulletBill_curr_YLoc[2] <= curr_pos;
        bulletBill_curr_XLoc[2] <= 4'd2;
        nextUp <= 2'd0;
    end
    // Incrementation -> Collision Confirming
    else if (bulletBill_state[2] != BBDNE && next_bulletBill_state[2] != BBDNE) begin
        bulletBill_curr_YLoc[2] <= bulletBill_curr_YLoc[2];             // Bullet Bills cannot move in the y direction
        // Check if it has reached the end
        if (bulletBill_curr_XLoc[2] < 4'd15) begin
            bulletBill_curr_XLoc[2] <= bulletBill_curr_XLoc[2] + 4'd1;      // Increment by 1
            isEnd[2] <= 0;
            // Collision Confirmation
            if ((bulletBill_curr_YLoc[2] % 2 != 0) && (bulletBill_curr_XLoc[2] % 2 == 0) && (bulletBill_curr_XLoc[2] >= 4'd4) && (ddaver_state[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2] != DDNE)) begin
                // Log Bullet Bill collision data
                isCollided[2] <= 1;
                // Log color for ddaver
                isHit[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2] <= bulletBill_state[2];
                isHitAgain[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2] <= bulletBill_state[2] && secondTime[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2];
            end
            // Set arbitrary values
            else begin
                isCollided[2] <= 0;
                isHit[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2] <= BBDNE;
                isHitAgain[(bulletBill_curr_YLoc[2] - 1) / 2][(bulletBill_curr_XLoc[2] - 4) / 2] <= BBDNE;
            end
        end
        // If it has reached the end
        else begin
            bulletBill_curr_XLoc[2] <= 4'd0;
            isEnd[2] <= 1;
        end
        nextUp <= 2'd0;
    end
    // It does not exist
    else begin
        bulletBill_curr_YLoc[2] <= bulletBill_curr_YLoc[2];
        bulletBill_curr_XLoc[2] <= bulletBill_curr_XLoc[2];
        nextUp <= 2'd2;
    end
end

// Ddaver Gameplay

// TODO: Check this to ensure compliation

always @(posedge ddaver_clock) begin
    // If any ddaver crosses the "Homeworld" barrier then it is GAME OVER
    if (((| ddaver_state[0][0]) || (| ddaver_state[1][0]) || (| ddaver_state[2][0]) || (| ddaver_state[3][0]) || (| ddaver_state[4][0])) && ((| next_ddaver_state[0][0]) || (| next_ddaver_state[1][0]) || (| next_ddaver_state[2][0]) || (| next_ddaver_state[3][0]) || (| next_ddaver_state[4][0]))) begin
        isBlockieeeDead <= 1;
    end
    // Check to see active columns
    else if (activeCol != 3'd0 && activeCol < 3'd7) begin
        // This means that we are capable of setting states
        // State Initialization + Incrementation
        for (i = 0; i < 5; i = i + 1) begin
            if (activeCol == 3'd6) begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
            else if (activeCol == 3'd5) begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
            else if (activeCol == 3'd4) begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
            else if (activeCol == 3'd3) begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
            else if (activeCol == 3'd2) begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
            else begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= ddaver_color[i];
            end
        end
    end
    // State Incrementation for continued gameplay
    else if (otherActiveCol != 3'd0) begin
        // Ddavers should increment onscreen (dissapearing now from the rightmost)
        // otherActiveCol will begin incrementing as soon as activeCol reaches 0 [staggered response].
        for (i = 0; i < 5; i = i + 1) begin
            if (otherActiveCol == 3'd6) begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= ddaver_state[i][5];
                next_ddaver_state[i][5] <= DDNE;
            end
            else if (otherActiveCol == 3'd5) begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= ddaver_state[i][4];
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= DDNE;
            end
            else if (otherActiveCol == 3'd4) begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= ddaver_state[i][3];
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= DDNE;
            end
            else if (otherActiveCol == 3'd3) begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= ddaver_state[i][2];
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= DDNE;
            end
            else if (otherActiveCol == 3'd2) begin
                next_ddaver_state[i][0] <= ddaver_state[i][1];
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= DDNE;
            end
            else begin
                next_ddaver_state[i][0] <= DDNE;
                next_ddaver_state[i][1] <= DDNE;
                next_ddaver_state[i][2] <= DDNE;
                next_ddaver_state[i][3] <= DDNE;
                next_ddaver_state[i][4] <= DDNE;
                next_ddaver_state[i][5] <= DDNE;
            end
        end
    end
    /*
        If there are no enemies on screen because both activity monitors are at a loss then this else should probably not happen.
        However, when has anything ever worked the way we want it to? #Facts
    */
    else begin
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 6; j = j + 1) begin
                // This would infer a stagnent screen (a.k.a. no movement and likely no color) if it were to occur. Pray for me.
                next_ddaver_state[i][j] <= ddaver_state[i][j]
            end
        end
    end
end

// Negative Edge Updating
always @(negedge blockieee_clock) begin
    blockieee_state <= next_blockieee_state;
end
always @(negedge bullet_clock) begin
    bulletBill_state[0] <= next_bulletBill_state[0];
    bulletBill_state[1] <= next_bulletBill_state[1];
    bulletBill_state[2] <= next_bulletBill_state[2];
end
always @(negedge ddaver_clock) begin
    for (i = 0; i < 5; i = i + 1) begin
        for (j = 0; j < 6; j = j + 1) begin
            next_ddaver_state[i][j] <= ddaver_state[i][j];
        end
    end

    // Active + otherActive Implementation
    if (activeCol > 3'd0 && activeCol < 3'd7) begin
        activeCol <= activeCol - 3'd1;
        otherActiveCol <= 3'd0;
    end
    // Initialize otherActiveCol
    else if (activeCol == 3'd0 && otherActiveCol == 3'd0) begin
        activeCol <= 3'd7;                  // Set it out of bounds
        otherActiveCol <= 3'd6;
    end
    // Will run after first iteration
    else if (activeCol == 3'd7 && otherActiveCol > 3'd0) begin
        activeCol <= 3'd7;
        otherActiveCol <= otherActiveCol - 3'd1;
    end
    else begin
        activeCol <= 3'd0;
        otherActiveCol <= 3'd0;
    end
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// FSM Combinational Logic
always_comb begin
    // Blockieee State Machine
    case (blockieee_state)
        // Initial State for the Main Character
        STEADY: begin
            // If reset go back to steady
            if (rst) begin
                next_blockieee_state = STEADY;
            end
            else if (isBlockieeeDead) begin
                next_blockieee_state = DEAD;
            end
            else begin
                // Dependent on Nunchuk Position
                if (stick_y > DEADLOC + SENSITIVITY) begin
                    next_blockieee_state = UP;
                end
                else if (stick_y < DEADLOC - SENSITIVITY) begin
                    next_blockieee_state = DOWN;
                end
                else begin
                    next_blockieee_state = STEADY;
                end
            end
        end

        // MC is moving UP
        UP: begin
            if (rst) begin
                next_blockieee_state = STEADY;
            end
            else if (isBlockieeeDead) begin
                next_blockieee_state = DEAD;
            end
            else begin
                // Dependent on Nunchuk Position
                if (stick_y > DEADLOC + SENSITIVITY) begin
                    next_blockieee_state = UP;
                end
                else if (stick_y < DEADLOC - SENSITIVITY) begin
                    next_blockieee_state = DOWN;
                end
                else begin
                    next_blockieee_state = STEADY;
                end
            end
        end
        DOWN: begin
            if (rst) begin
                next_blockieee_state = STEADY;
            end
            else if (isBlockieeeDead) begin
                next_blockieee_state = DEAD;
            end
            else begin
                // Dependent on Nunchuk Position
                if (stick_y > DEADLOC + SENSITIVITY) begin
                    next_blockieee_state = UP;
                end
                else if (stick_y < DEADLOC - SENSITIVITY) begin
                    next_blockieee_state = DOWN;
                end
                else begin
                    next_blockieee_state = STEADY;
                end
            end
        end
        DEAD: begin
            if (rst) begin
                next_blockieee_state = STEADY;
            end
            else begin
                next_blockieee_state = DEAD;
            end
        end
        default: begin
            next_blockieee_state = blockieee_state;
        end
    endcase

	////////////////////////////////////////////////////////////////////////////////////

    // Bullet Bill State Machine
    for (int i = 0; i < 3; i = i + 1) begin
        // Iterations per bullet
        case (bulletBill_state[i])
            // The bullet does not exist
            BBDNE: begin
                // If the game is reset or a bullet collides with something reset it
                if (rst || isCollided[i] || isEnd[i]) begin
                    next_bulletBill_state[i] = BBDNE;
                end
                // If any button is pressed
                if (z || c) begin
                    // Sort through the options availble
                    // If 'z' is pressed
                    if (z && ~c) begin
                        next_bulletBill_state[i] = EBLUE;
                    end
                    // If 'c' is pressed
                    else if (~z && c) begin
                        next_bulletBill_state[i] = ERED;
                    end
                    // If both are pressed
                    else begin
                        next_bulletBill_state[i] = EGREEN;
                    end
                end
                // If no button is pressed
                else begin
                    next_bulletBill_state[i] = BBDNE;
                end
            end
            // But what if the bullet already has a color?
            // The bullet exists and is colored blue
            EBLUE: begin
                // If the game is reset... well you know what to do.
                if (rst || isCollided[i] || isEnd[i]) begin
                    next_bulletBill_state[i] = BBDNE;
                end
                // The bullet should not change states regardless of button input
                // Maintain current state
                else begin
                    next_bulletBill_state[i] = bulletBill_state[i];
                end
            end
            // The bullet exists and is colored red
            ERED: begin
                if (rst || isCollided[i] || isEnd[i]) begin
                    next_bulletBill_state[i] = BBDNE;
                end
                // The bullet should not change states regardless of button input
                // Maintain current state
                else begin
                    next_bulletBill_state[i] = bulletBill_state[i];
                end
            end
            // The bullet exists and is colored green
            EGREEN: begin
                if (rst || isCollided[i] || isEnd[i]) begin
                    next_bulletBill_state[i] = BBDNE;
                end
                // The bullet should not change states regardless of button input
                // Maintain current state
                else begin
                    next_bulletBill_state[i] = bulletBill_state[i];
                end
            end
            default: begin
                next_bulletBill_state[i] = bulletBill_state[i];
            end
        endcase
    end

	////////////////////////////////////////////////////////////////////////////////////

    // Ddaver State Machine
    for (int i = 0; i < 5; i = i + 1) begin
        // Iterations per ddaver
        for (int j = 0; j < 6; j = j + 1) begin
            case (ddaver_state[i][j])
            // The ddaver does not exist (is not visible onscreen)
                DDNE: begin
                    // If the game is reset
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
					else begin
						next_ddaver_state[i][j] = ddaver_state[i][j];
					end
                end
                PURPLE: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Blue bulletBill
                    else if (isHit[i][j] == EBLUE) begin
                        // Change color to red
                        next_ddaver_state[i][j] = RED;
                        secondTime[i][j] = 1;
                    end
                    // HIT by Red bulletBill
                    else if (isHit[i][j] == ERED) begin
                        // Change color to blue
                        next_ddaver_state[i][j] = BLUE;
                        secondTime[i][j] = 1;
                    end
                    // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end
                ORANGE: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Green bulletBill
                    else if (isHit[i][j] == EGREEN) begin
                        // Change color to Red
                        next_ddaver_state[i][j] = RED;
                        secondTime[i][j] = 1;
                    end
                    // HIT by Red bulletBill
                    else if (isHit[i][j] == ERED) begin
                        // Change color to green
                        next_ddaver_state[i][j] = GREEN;
                        secondTime[i][j] = 1;
                    end
                    // IF it is HIT by blue bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end
                YELLOW: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Blue bulletBill
                    else if (isHit[i][j] == EBLUE) begin
                        // Change color to green
                        next_ddaver_state[i][j] = GREEN;
                        secondTime[i][j] = 1;
                    end
                    // HIT by Green bulletBill
                    else if (isHit[i][j] == EGREEN) begin
                        // Change color to blue
                        next_ddaver_state[i][j] = BLUE;
                        secondTime[i][j] = 1;
                    end
                    // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end

                /*
                    Statement of logic:

                    The following portion is dependent upon the register isHitAgain which logs the color of the bullet which
                    collides with the ddaver a second time through. This is a seperate register from isHit for simpler logic
                    at the developer end.
                */

                // *** The DEADLY States *** //
                BLUE: begin
                    // If the game is reset OR a HIT by Blue bulletBill... the enemy "DIES"
                    if (rst || (isHitAgain[i][j] == EBLUE)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // Otherwise the enemy continues to exist happy and free
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end
                RED: begin
                    // If the game is reset OR a HIT by Red bulletBill
                    if (rst || (isHitAgain[i][j] == ERED)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end
                GREEN: begin
                    // If the game is reset OR a HIT by Red bulletBill
                    if (rst || (isHitAgain[i][j] == ERED)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j];
                    end
                end
                default: begin
                    next_ddaver_state[i][j] = ddaver_state[i][j];
                end
        endcase
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Set Outputs for the VGA
game_interpreter pain_interpreter(curr_pos, ddaver_state, bulletBill_state, bulletBill_curr_XLoc, bulletBill_curr_YLoc, blockieee_pos, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
