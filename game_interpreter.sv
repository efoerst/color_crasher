module game_interpreter(
    // Inputs
    input[3:0] blockPos,
    input[2:0] ddState [0:4][0:5],
    input[1:0] bullState [0:2],
    input[3:0] bullX [0:2],
    input[3:0] bullY [0:2],

    // Outputs
    output reg[3:0] sub_blockieee_pos,
    output reg[11:0] sub_ddavers [0:4][0:5],
    output reg[11:0] sub_bulletBillColor [0:2],
    output reg[3:0] sub_bulletBillXLoc [0:2],
    output reg[3:0] sub_bulletBillYLoc [0:2]
);

// Parameter values

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

// Integer Values
integer i;
integer j;

// Assign associated values
always_comb begin
    // Blockieee Position
    sub_blockieee_pos = blockPos;

    // DDaver colors
    for (i = 0; i < 5; i = i + 1) begin
        for (j = 0; j < 6; j = j + 1) begin
            case (ddState[i][j])
            // The RGB are identified red, green, blue
                DDNE: begin
                    sub_ddavers[i][j] = {4'd0, 4'd0, 4'd0};
                end
                PURPLE: begin
                    sub_ddavers[i][j] = {4'd15, 4'd0, 4'd15};
                end
                ORANGE: begin
                    sub_ddavers[i][j] = {4'd15, 4'd15, 4'd0};
                end
                YELLOW: begin
                    sub_ddavers[i][j] = {4'd0, 4'd15, 4'd15};
                end
                BLUE: begin
                    sub_ddavers[i][j] = {4'd0, 4'd0, 4'd15};
                end
                RED: begin
                    sub_ddavers[i][j] = {4'd15, 4'd0, 4'd0};
                end
                GREEN: begin
                    sub_ddavers[i][j] = {4'd0, 4'd15, 4'd0};
                end
                default: begin
                    sub_ddavers[i][j] = {4'd0, 4'd0, 4'd0};
                end
            endcase
        end
    end

    // Bullet Bill colors + positions
    for (i = 0; i < 3; i = i + 1) begin
        sub_bulletBillXLoc[i] = bullX[i];
        sub_bulletBillYLoc[i] = bullY[i];
        case (bullState[i])
            BBDNE: begin
                sub_bulletBillColor[i] = {4'd0, 4'd0, 4'd0};
            end
            EBLUE: begin
                sub_bulletBillColor[i] = {4'd0, 4'd0, 4'd15};
            end
            ERED: begin
                sub_bulletBillColor[i] = {4'd15, 4'd0, 4'd0};
            end
            EGREEN: begin
                sub_bulletBillColor[i] = {4'd0, 4'd15, 4'd0};
            end
            default: begin
                sub_bulletBillColor[i] = {4'd0, 4'd0, 4'd0};
            end
        endcase
    end
end

endmodule
