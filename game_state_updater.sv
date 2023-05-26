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
reg[3:0] start_pos = 4'd5;
reg[3:0] curr_pos = start_pos;
reg isBlockieeeDead = 0;

// Firing Mechanics
reg isCollided [0:2];
isCollided[0] = 0;
isCollided[1] = 0;
isCollided[2] = 0;

// Bullet Bill Position Tracer
reg[3:0] shot_loc;
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
reg[1:0] isHitAgain [0:4][0:5];

// FSM State
// Blockieee
reg[1:0] blockieee_state = STEADY;
reg[1:0] next_blockieee_state = STEADY;

// Bullet Bill
reg[1:0] bulletBill_state[0:2];
bulletBill_state[0] = BBDNE;
bulletBill_state[1] = BBDNE;
bulletBill_state[2] = BBDNE;
reg[1:0] next_bulletBill_state[0:2];
next_bulletBill_state[0] = BBDNE;
next_bulletBill_state[1] = BBDNE;
next_bulletBill_state[2] = BBDNE;

// Ddaver
reg[2:0] ddaver_state [0:4][0:5];
reg[2:0] next_ddaver_state [0:4][0:5];

// Initialize DDaver registers
for (int i = 0; i < 5; i = i + 1) begin
    for (int j = 0; j < 6; j = j + 1) begin
        // Initialize isHit to 0
        isHit[i][j] = 0;
        isHitAgain[i][j] = 0;
        // Initialize states to DNE
        ddaver_state[i][j] = DDNE;
        next_ddaver_state[i][j] = DDNE;
    end
end
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
    // There must be a state change to initialize the
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FSM Combinational Logic
/*
    TODO:   
        Contains 1 TODO
*/
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
                if (rst || isCollided[i]) begin
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
                if (rst || isCollided[i]) begin
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
                if (rst || isCollided[i]) begin
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
                if (rst || isCollided[i]) begin
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
                    // Need something here that initializes colors

                    // TODO: Randomizer for colors

                end
                PURPLE: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Blue bulletBill
                    else if (isHit[i][j] == 2'd1) begin
                        // Change color to red
                        next_ddaver_state[i][j] = RED;
                    end
                    // HIT by Red bulletBill
                    else if (isHit[i][j] == 2'd2) begin
                        // Change color to blue
                        next_ddaver_state[i][j] = BLUE;
                    end
                    // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
                    end
                end
                ORANGE: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Green bulletBill
                    else if (isHit[i][j] == 2'd3) begin
                        // Change color to Red
                        next_ddaver_state[i][j] = RED;
                    end
                    // HIT by Red bulletBill
                    else if (isHit[i][j] == 2'd2) begin
                        // Change color to green
                        next_ddaver_state[i][j] = GREEN;
                    end
                    // IF it is HIT by blue bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
                    end
                end
                YELLOW: begin
                    if (rst) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // HIT by Blue bulletBill
                    else if (isHit[i][j] == 2'd1) begin
                        // Change color to green
                        next_ddaver_state[i][j] = GREEN;
                    end
                    // HIT by Green bulletBill
                    else if (isHit[i][j] == 2'd3) begin
                        // Change color to blue
                        next_ddaver_state[i][j] = BLUE;
                    end
                    // IF it is HIT by green bulletBill OR not HIT then does not matter no change
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
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
                    if (rst || (isHitAgain[i][j] == 2'd1)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    // Otherwise the enemy continues to exist happy and free
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
                    end
                end
                RED: begin
                    // If the game is reset OR a HIT by Red bulletBill
                    if (rst || (isHitAgain[i][j] == 2'd2)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
                    end
                end
                GREEN: begin
                    // If the game is reset OR a HIT by Red bulletBill
                    if (rst || (isHitAgain[i][j] == 2'd3)) begin
                        next_ddaver_state[i][j] = DDNE;
                    end
                    else begin
                        next_ddaver_state[i][j] = ddaver_state[i][j]
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

endmodule
