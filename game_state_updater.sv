module game_state_updater(
    ////////////////////////////////////////////////////////////////////////////////////
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
    ////////////////////////////////////////////////////////////////////////////////////
);

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
reg[3:0] curr_pos;
reg isBlockieeeDead;

// Firing Mechanics
reg isCollided [0:2];

// FSM State
reg[1:0] blockieee_state = STEADY;
reg[1:0] next_blockieee_state = STEADY;

reg[1:0] bulletBill_state[0:2];
bulletBill_state[0] = BBDNE;
bulletBill_state[1] = BBDNE;
bulletBill_state[2] = BBDNE;
reg[1:0] next_bulletBill_state[0:2];
next_bulletBill_state[0] = BBDNE;
next_bulletBill_state[1] = BBDNE;
next_bulletBill_state[2] = BBDNE;

reg[2:0] ddaver_state = DDNE;
reg[2:0] next_ddaver_state = DDNE;

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
            next_state = STEADY;
        end
    endcase
    // Bullet Bill State Machine
    case (bulletBill_state)
        BBDNE: begin
        end
        EBLUE: begin
        end
        ERED: begin
        end
        EGREEN: begin
        end
        default: begin
        end
    endcase
    // Ddaver State Machine
    case (ddaver_state)
        DDNE: begin
        end
        PURPLE: begin
        end
        ORANGE: begin
        end
        YELLOW: begin
        end
        BLUE: begin
        end
        RED: begin
        end
        GREEN: begin
        end
        default: begin
        end
    endcase
end
endmodule
