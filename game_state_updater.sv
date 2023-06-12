/*
Note: The following module has unresolved bugs.

Since Last Update:
 - Main Character is able to move
 - Bullet state machine and posedge logic works in sim
 - Enemy iteration is incomplete, colors randomize however they fail to move cross screen.
*/
module game_state_updater(
    // Inputs
    input rst,

    // Input Clocks
    input clk,

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
    output reg[11:0] bulletBillColor,
    output reg[3:0] bulletBillXLoc,
    output reg[3:0] bulletBillYLoc
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Input Clocks
localparam BLOCKIEEE_SPEED = 1500000;
localparam DDAVER_SPEED = 100000;
localparam BULLET_SPEED = 3000000;

clockDivider #(BLOCKIEEE_SPEED) blockieee_clock_uut(clk, blockieee_clock, rst);
clockDivider #(DDAVER_SPEED) ddaver_clock_uut(clk, ddaver_clock, !rst);
clockDivider #(BULLET_SPEED) bullet_clock_uut(clk, bullet_clock, !rst);

// FSM State Declarations
// Blockieee States
localparam STEADY = 2'd0;
localparam UP = 2'd1;
localparam DOWN = 2'd2;
localparam DEAD = 2'd3;
// Bullet Bill States
localparam BBDNE = 2'd0;
localparam EBLUE = 2'd1;
localparam ERED = 2'd2;
localparam EGREEN = 2'd3;
// Ddaver States
localparam DDNE = 3'd0;
localparam PURPLE = 3'd1;
localparam ORANGE = 3'd2;
localparam YELLOW = 3'd3;
localparam BLUE = 3'd4;
localparam RED = 3'd5;
localparam GREEN = 3'd6;

// Tolerance Parameter
localparam SENSITIVITY = 8'd70;
localparam DEADLOC = 8'd128;             

// User Experience
reg[3:0] curr_pos = 4'd5;
reg[3:0] next_pos;
reg isBlockieeeDead = 1'd0;

// Firing Mechanics
reg isCollided;

// Bullet Bill Position Tracer
reg[3:0] bulletBill_curr_XLoc;
reg[3:0] bulletBill_curr_YLoc;
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
reg[1:0] isHitAgain [0:4][0:5];
reg secondTime [0:4][0:5];
//reg [2:0] shiftPos; 
reg [2:0] activeCol;
reg [2:0] otherActiveCol;

// FSM State
// Blockieee
reg[1:0] blockieee_state = STEADY;
reg[1:0] next_blockieee_state = STEADY;

// Bullet Bill
reg[1:0] bulletBill_state;
reg[1:0] next_bulletBill_state;
reg isEnd;
reg [1:0] nextUp;


// Ddaver
reg[2:0] ddaver_state [0:4][0:5];
reg[2:0] next_ddaver_state [0:4][0:5];
reg[2:0] ndds[0:4][0:5];
reg[2:0] ddaver_color[0:4][0:5];
reg firstTime; 

// Initialize DDaver registers
integer i;
integer j;
initial begin
	for (i = 0; i < 5; i = i + 1) begin
		for (j = 0; j < 6; j = j + 1) begin
        // Initialize isHit to 0
			isHit[i][j] = 2'd0;
			isHitAgain[i][j] = 2'd0;
			secondTime[i][j] = 1'b0;
        // Initialize states to DNE
			ddaver_state[i][j] = DDNE;
			//next_ddaver_state[i][j] = DDNE;
		end
	end
	bulletBill_state = BBDNE;
	//next_bulletBill_state[k] = BBDNE;
	isEnd = 1'b0;
	isCollided = 1'b0;
	bulletBill_curr_XLoc = 4'd0;
	bulletBill_curr_YLoc = 4'd0;
	
	nextUp = 2'd0;
	//shiftPos = 0;
	activeCol = 3'd6;
	otherActiveCol = 3'd0;
	next_pos = 4'd5;
	firstTime = 1'b1;
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
            - vga_clock: The posedge for this clock will be      TODO      (prolly something with rst)
            - blockieee_clock: The posedge for this clock will be used to update the position states of the MC depending on
                nunchuck input.
            - ddaver_clock: The posedge for this clock will be used to update the movement of the ddavers across the screen
                from R -> L. If the enemy crosses "homeworld" then the lose register will be activated.
            - bulletBill: The posedge for this clock will be used to update the movement of the bullets across the screen from
                L -> R. If the bullet hits an enemy space that is colored the appropriate color then this will also update the
                isHit OR the isHitAgain registers with the appropriate color of the bullet (in state form)
*/

// General Gameplay
// General Gameplay



// Blockieee Gameplay
always @(posedge blockieee_clock) begin
    // If blockieee is in the Steady State
	 if (rst || isBlockieeeDead) begin
		next_pos <= 4'd5;
	 end
    else if (blockieee_state == STEADY) begin
        // Maintain the current position
        next_pos <= curr_pos;
    end
    // If blockiee is in the UP State
    else if (blockieee_state == UP) begin
        // Increment up one so long as it is possible
        if (curr_pos > 4'd0) begin
            next_pos <= curr_pos - 4'd1;
        end
        else begin
            next_pos <= curr_pos;
        end
    end
    // If blockieee is in the DOWN State
    else if (blockieee_state == DOWN) begin
        // Increment down one so long as it is possible
        if (curr_pos < 4'd10) begin
            next_pos <= curr_pos + 4'd1;
        end
        else begin
            next_pos <= curr_pos;
        end
    end
    // Blockieee can literally be in no other state so like tell blockieee to stop trying
    else begin
        next_pos <= curr_pos;
    end
end

// Bullet Bill Gameplay
always @(posedge bullet_clock) begin
    // Bullet Bill 1 Implementation
    if (~rst) begin
        //nextUp <= 2'd0;
        bulletBill_curr_XLoc <= 4'd0;
        bulletBill_curr_YLoc <= 4'd0;
        isCollided <= 0;
        isEnd <= 0;
    end
    // Spawning In
    else if (bulletBill_state == BBDNE && next_bulletBill_state != BBDNE && nextUp == 2'd0) begin
        bulletBill_curr_YLoc <= curr_pos;
        bulletBill_curr_XLoc <= 4'd2;
        //nextUp <= 2'd1;
    end
    // Incrementation -> Collision Confirming
    else if (bulletBill_state != BBDNE && next_bulletBill_state != BBDNE) begin
        bulletBill_curr_YLoc <= bulletBill_curr_YLoc;             // Bullet Bills cannot move in the y direction
        // Check if it has reached the end
        if (bulletBill_curr_XLoc < 4'd15) begin
            bulletBill_curr_XLoc <= bulletBill_curr_XLoc + 4'd1;      // Increment by 1
            isEnd <= 0;
            // Collision Confirmation
            if ((bulletBill_curr_YLoc % 2 != 0) && (bulletBill_curr_XLoc % 2 == 0) && (bulletBill_curr_XLoc >= 4'd4) && (ddaver_state[(bulletBill_curr_YLoc - 1) / 2][(bulletBill_curr_XLoc - 4) / 2] != DDNE)) begin
                // Log Bullet Bill collision data
                isCollided <= 1;
                // Log color for ddaver
                isHit[(bulletBill_curr_YLoc- 1) / 2][(bulletBill_curr_XLoc - 4) / 2] <= bulletBill_state;
                isHitAgain[(bulletBill_curr_YLoc - 1) / 2][(bulletBill_curr_XLoc - 4) / 2] <= bulletBill_state && secondTime[(bulletBill_curr_YLoc - 1) / 2][(bulletBill_curr_XLoc - 4) / 2];
            end
            // Set arbitrary values
            else begin
                isCollided <= 0;
                isHit[(bulletBill_curr_YLoc - 1) / 2][(bulletBill_curr_XLoc - 4) / 2] <= BBDNE;
                isHitAgain[(bulletBill_curr_YLoc - 1) / 2][(bulletBill_curr_XLoc - 4) / 2] <= BBDNE;
            end
        end
        // If it has reached the end
        else begin
            bulletBill_curr_XLoc <= 4'd0;
            isEnd <= 1;
        end
        //nextUp <= 2'd1;
    end
    // It does not exist
    else begin
        bulletBill_curr_YLoc <= bulletBill_curr_YLoc;
        bulletBill_curr_XLoc <= bulletBill_curr_XLoc;
        //nextUp <= 2'd0;
    end

end

// ddaver gameplay
// TODO: If the ddaver is red, green, or blue then secondTime should be true
// TODO: "Left shift" array of ddavers towards "homeworld"
// TODO: Each ddaver should take on the value of their state


always @(posedge ddaver_clock) begin
	// If any ddaver crosses the "homeworld" barrier, then it is GAME OVER
	// use a "pointer" to "shift" the values around 
	integer m;
	integer n;
	if (rst) begin
        for (m = 0; m < 5; m = m + 1) begin
            for (n = 0; n < 6; n = n + 1) begin
						secondTime[m][n] <= 0;
            end
        end
		  firstTime <= 1'b0;
	end
	else if (firstTime) begin
		firstTime <= 1'b0;
	end
	else begin
		firstTime <= firstTime;
	end
end

// Negative Edge Updating
always @(negedge blockieee_clock) begin
    blockieee_state <= next_blockieee_state;
	 curr_pos <= next_pos;
end

always @(negedge bullet_clock) begin
 	 bulletBill_state <= next_bulletBill_state;
end

always @(negedge ddaver_clock) begin
	 integer a;
	 integer b;
	 // state updating
	 for (a = 0; a < 5; a = a + 1) begin
		for (b = 0; b < 6; b = b + 1) begin
			ddaver_state[a][b] <= next_ddaver_state[a][b];
		end
	 end
end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FSM Combinational Logic
/*
    TODO:   
        Contains 1 TODO
*/
always_comb begin
	integer k;
	 integer l;
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

	 // Iterations per bullet
         case (bulletBill_state)
             // The bullet does not exist
             BBDNE: begin
                 // If the game is reset or a bullet collides with something reset it
                 if (~rst || isCollided || isEnd) begin
                     next_bulletBill_state = BBDNE;
                 end
                 // If any button is pressed
                 else if (z || c) begin
                     // Sort through the options availble
                     // If 'z' is pressed
                     if (z && !c) begin
                         next_bulletBill_state = EBLUE;
                     end
                     // If 'c' is pressed
                     else if (!z && c) begin
                         next_bulletBill_state = ERED;
                     end
                     // If both are pressed
                     else begin
                         next_bulletBill_state = EGREEN;
                     end
                 end
                 // If no button is pressed
                 else begin
                     next_bulletBill_state = BBDNE;
                 end
             end
             // But what if the bullet already has a color?
             // The bullet exists and is colored blue
             EBLUE: begin
                 // If the game is reset... well you know what to do.
                 if (~rst || isCollided || isEnd) begin
                     next_bulletBill_state = BBDNE;
                 end
                 // The bullet should not change states regardless of button input
                 // Maintain current state
                 else begin
                     next_bulletBill_state = bulletBill_state;
                 end
             end
             // The bullet exists and is colored red
             ERED: begin
                 if (~rst || isCollided || isEnd) begin
                     next_bulletBill_state = BBDNE;
                 end
                 // The bullet should not change states regardless of button input
                 // Maintain current state
                 else begin
                     next_bulletBill_state = bulletBill_state;
                 end
             end
             // The bullet exists and is colored green
             EGREEN: begin
                 if (~rst || isCollided || isEnd) begin
                     next_bulletBill_state = BBDNE;
                 end
                 // The bullet should not change states regardless of button input
                 // Maintain current state
                 else begin
                    next_bulletBill_state = bulletBill_state;
                 end
             end
             default: begin
                 next_bulletBill_state = bulletBill_state;
             end
         endcase
     

	////////////////////////////////////////////////////////////////////////////////////

    //Ddaver State Machine
	 
    for (k = 0; k < 5; k = k + 1) begin
        // Iterations per ddaver
        for ( l = 0; l < 6; l = l + 1) begin
                case (ddaver_state[k][l])
                // The ddaver does not exist (is not visible onscreen)
                    DDNE: begin
                        // If the game is reset
                        if (rst) begin
                            next_ddaver_state[k][l] = DDNE;
                       end
								else if (firstTime) begin
									next_ddaver_state[k][l] = ddaver_color[k][l];
								end
								else begin
									next_ddaver_state[k][l] = ddaver_state[k][l];
								end
                    end
                    PURPLE: begin
                        if (rst) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        // HIT by Blue bulletBill
                        else if (isHit[k][l] == EBLUE) begin
                            // Change color to red
                            next_ddaver_state[k][l] = RED;
                        end
                        // HIT by Red bulletBill
                        else if (isHit[k][l] == ERED) begin
                            // Change color to blue
                            next_ddaver_state[k][l] = BLUE;
                        end
                        // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                        else begin
                            next_ddaver_state[k][l] = PURPLE;
                        end
                    end
                    ORANGE: begin
                        if (rst) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        // HIT by Green bulletBill
                        else if (isHit[i][j] == EGREEN) begin
                            // Change color to Red
                            next_ddaver_state[k][l] = RED;
                        end
                        // HIT by Red bulletBill
                        else if (isHit[k][l] == ERED) begin
                            // Change color to green
                            next_ddaver_state[k][l] = GREEN;
                        end
                        // IF it is HIT by blue bulletBill OR not HIT then does not matter no change
                        else begin
                            next_ddaver_state[k][l] = ORANGE;
                        end
                    end
                    YELLOW: begin
                        if (rst) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        // HIT by Blue bulletBill
                        else if (isHit[k][l] == EBLUE) begin
                            // Change color to green
                            next_ddaver_state[k][l] = GREEN;
                        end
                        // HIT by Green bulletBill
                        else if (isHit[k][l] == EGREEN) begin
                            // Change color to blue
                            next_ddaver_state[k][l] = BLUE;
                        end
                        // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                        else begin
                            next_ddaver_state[k][l] = YELLOW;
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
                        if (rst || (isHitAgain[k][l] == EBLUE)) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        // Otherwise the enemy continues to exist happy and free
                        else begin
                            next_ddaver_state[k][l] = BLUE;
                        end
                    end
                    RED: begin
                        // If the game is reset OR a HIT by Red bulletBill
                        if (rst || (isHitAgain[k][l] == ERED)) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        else begin
                            next_ddaver_state[k][l] = RED;
                        end
                    end
                    GREEN: begin
                        // If the game is reset OR a HIT by Red bulletBill
                        if (rst || (isHitAgain[k][l] == ERED)) begin
                            next_ddaver_state[k][l] = DDNE;
                        end
                        else begin
                            next_ddaver_state[k][l] = GREEN;
                        end
                    end
                    default: begin
                        next_ddaver_state[k][l] = ddaver_state[k][l];
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
