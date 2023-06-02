module game_interpreter(
    // Inputs
    input[3:0] blockPos,
    input[2:0] ddState [0:4][0:5],
    input[1:0] bullState,
    input[3:0] bullX,
    input[3:0] bullY,

    // Outputs
    output reg[3:0] sub_blockieee_pos,
    output reg[11:0] sub_ddavers [0:4][0:5],
    output reg[11:0] sub_bulletBillColor,
    output reg[3:0] sub_bulletBillXLoc,
    output reg[3:0] sub_bulletBillYLoc
);

// Parameters
localparam BBDNE = 2'd0;
localparam EBLUE = 2'd1;
localparam ERED = 2'd2;
localparam EGREEN = 2'd3;
localparam DDNE = 3'd0;
localparam PURPLE = 3'd1;
localparam ORANGE = 3'd2;
localparam YELLOW = 3'd3;
localparam BLUE = 3'd4;
localparam RED = 3'd5;
localparam GREEN = 3'd6;

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
                    sub_ddavers[i][j] = {4'd15, 4'd9, 4'd0};
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
    sub_bulletBillXLoc = bullX;
    sub_bulletBillYLoc = bullY;
    case (bullState)
        BBDNE: begin
            sub_bulletBillColor = {4'd0, 4'd0, 4'd0};
        end
        EBLUE: begin
            sub_bulletBillColor = {4'd0, 4'd0, 4'd15};
        end
        ERED: begin
            sub_bulletBillColor = {4'd15, 4'd0, 4'd0};
        end
        EGREEN: begin
            sub_bulletBillColor = {4'd0, 4'd15, 4'd0};
        end
        default: begin
            sub_bulletBillColor = {4'd0, 4'd0, 4'd0};
        end
    endcase
end

endmodule
