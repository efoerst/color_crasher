module color_randomizer(input wire clk, input rst, output reg [2:0] random_color [0:4]);

    localparam PURPLE       = 3'b001;
    localparam ORANGE       = 3'b010;
    localparam YELLOW       = 3'b011;
    localparam BLUE         = 3'b100;
    localparam RED          = 3'b101;
    localparam GREEN        = 3'b110;

    reg [7:0] state; // LFSR state register

    // 10111000

    initial begin
        state <= 8'b10101010;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 8'b10101010; // reset to initial state
        end else begin
            // calculate next state using XOR feedback
            state <= {state[6:0], state[7] ^ state[5] ^ state[4] ^ state[3]};
        end
    end

    always_comb begin
        if (state[2:0] < 3'd2) begin
            random_color[0] = PURPLE;
        end else if (state[2:0] < 3'd4)  begin
            random_color[0] = ORANGE;
        end else begin
            random_color[0] = YELLOW;
        end 
		  
        if (state[3:1] < 3'd2) begin
            random_color[1] = PURPLE;
        end else if (state[3:1] < 3'd4)  begin
            random_color[1] = ORANGE;
        end else begin
            random_color[1] = YELLOW;
        end 
		  
        if (state[4:2] < 3'd2) begin
            random_color[2] = PURPLE;
        end else if (state[4:2] < 3'd4)  begin
            random_color[2] = ORANGE;
        end else begin
            random_color[2] = YELLOW;
		  end 
		  
        if (state[5:3] == 3'd2) begin
            random_color[3] = PURPLE;
        end else if (state[5:3] < 3'd4)  begin
            random_color[3] = ORANGE;
        end else begin
            random_color[3] = YELLOW;
        end
		  
		  if (state[6:4] < 3'd2) begin
            random_color[3] = PURPLE;
        end else if (state[6:4] < 3'd4)  begin
            random_color[3] = ORANGE;
        end else begin
            random_color[3] = YELLOW;
        end 
		  
		  if (state[7:5] < 3'd2) begin
            random_color[4] = PURPLE;
        end else if (state[7:5] < 3'd4)  begin
            random_color[4] = ORANGE;
        end else begin
            random_color[4] = YELLOW;
        end 
		  
    end

endmodule
