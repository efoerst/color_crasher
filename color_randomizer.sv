module color_randomizer(input wire clk, input rst, output reg [2:0] random_color [0:4][0:5]);

    localparam PURPLE       = 3'b001;
    localparam ORANGE       = 3'b010;
    localparam YELLOW       = 3'b011;
    
    reg [31:0] state; // LFSR state register

    // 10111000

    initial begin
        state <= 32'b10101010101010101010101010101010;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= 8'b10101010; // reset to initial state
        end else begin
            // calculate next state using XOR feedback
            state <= {state[30:0], state[31] ^ state[21] ^ state[1] ^ state[0]};
        end
    end

    always_comb begin
        if (state[2:0] < 3'd2) begin
            random_color[0][0] = PURPLE;
        end else if (state[2:0] < 3'd4)  begin
            random_color[0][0] = ORANGE;
        end else begin
            random_color[0][0] = YELLOW;
        end 
		  
        if (state[3:1] < 3'd2) begin
            random_color[1][0] = PURPLE;
        end else if (state[3:1] < 3'd4)  begin
            random_color[1][0] = ORANGE;
        end else begin
            random_color[1][0] = YELLOW;
        end 
		  
        if (state[4:2] < 3'd2) begin
            random_color[2][0] = PURPLE;
        end else if (state[4:2] < 3'd4)  begin
            random_color[2][0] = ORANGE;
        end else begin
            random_color[2][0] = YELLOW;
		  end 
		  
        if (state[5:3] == 3'd2) begin
            random_color[3][0] = PURPLE;
        end else if (state[5:3] < 3'd4)  begin
            random_color[3][0] = ORANGE;
        end else begin
            random_color[3][0] = YELLOW;
        end
		  
		  if (state[6:4] < 3'd2) begin
            random_color[4][0] = PURPLE;
        end else if (state[6:4] < 3'd4)  begin
            random_color[4][0] = ORANGE;
        end else begin
            random_color[4][0] = YELLOW;
        end 
		  
		  if (state[7:5] < 3'd2) begin
            random_color[0][1] = PURPLE;
        end else if (state[7:5] < 3'd4)  begin
            random_color[0][1] = ORANGE;
        end else begin
            random_color[0][1] = YELLOW;
        end 

        if (state[8:6] < 3'd2) begin
            random_color[1][1] = PURPLE;
        end else if (state[8:6] < 3'd4)  begin
            random_color[1][1] = ORANGE;
        end else begin
            random_color[1][1] = YELLOW;
        end 
		  
        if (state[9:7] < 3'd2) begin
            random_color[2][1] = PURPLE;
        end else if (state[9:7] < 3'd4)  begin
            random_color[2][1] = ORANGE;
        end else begin
            random_color[2][1] = YELLOW;
		  end 
		  
        if (state[10:8] == 3'd2) begin
            random_color[3][1] = PURPLE;
        end else if (state[10:8] < 3'd4)  begin
            random_color[3][1] = ORANGE;
        end else begin
            random_color[3][1] = YELLOW;
        end
		  
		  if (state[11:9] < 3'd2) begin
            random_color[4][1] = PURPLE;
        end else if (state[11:9] < 3'd4)  begin
            random_color[4][1] = ORANGE;
        end else begin
            random_color[4][1] = YELLOW;
        end 
		  
		  if (state[12:10] < 3'd2) begin
            random_color[0][2] = PURPLE;
        end else if (state[12:10] < 3'd4)  begin
            random_color[0][2] = ORANGE;
        end else begin
            random_color[0][2] = YELLOW;
        end 

        if (state[13:11] < 3'd2) begin
            random_color[1][2] = PURPLE;
        end else if (state[13:11] < 3'd4)  begin
            random_color[1][2] = ORANGE;
        end else begin
            random_color[1][2] = YELLOW;
        end 
		  
        if (state[14:12] < 3'd2) begin
            random_color[2][2] = PURPLE;
        end else if (state[14:12] < 3'd4)  begin
            random_color[2][2] = ORANGE;
        end else begin
            random_color[2][2] = YELLOW;
		  end 
		  
        if (state[15:13] == 3'd2) begin
            random_color[3][2] = PURPLE;
        end else if (state[15:13] < 3'd4)  begin
            random_color[3][2] = ORANGE;
        end else begin
            random_color[3][2] = YELLOW;
        end
		  
		  if (state[16:14] < 3'd2) begin
            random_color[4][2] = PURPLE;
        end else if (state[16:14] < 3'd4)  begin
            random_color[4][2] = ORANGE;
        end else begin
            random_color[4][2] = YELLOW;
        end 
		  
		  if (state[17:15] < 3'd2) begin
            random_color[0][3] = PURPLE;
        end else if (state[7:5] < 3'd4)  begin
            random_color[0][3] = ORANGE;
        end else begin
            random_color[0][3] = YELLOW;
        end 

        if (state[18:16] < 3'd2) begin
            random_color[1][3] = PURPLE;
        end else if (state[18:16] < 3'd4)  begin
            random_color[1][3] = ORANGE;
        end else begin
            random_color[1][3] = YELLOW;
        end 
		  
        if (state[19:17] < 3'd2) begin
            random_color[2][3] = PURPLE;
        end else if (state[19:17] < 3'd4)  begin
            random_color[2][3] = ORANGE;
        end else begin
            random_color[2][3] = YELLOW;
		  end 
		  
        if (state[20:18] == 3'd2) begin
            random_color[3][3] = PURPLE;
        end else if (state[20:18] < 3'd4)  begin
            random_color[3][3] = ORANGE;
        end else begin
            random_color[3][3] = YELLOW;
        end
		  
		  if (state[21:19] < 3'd2) begin
            random_color[4][3] = PURPLE;
        end else if (state[21:19] < 3'd4)  begin
            random_color[4][3] = ORANGE;
        end else begin
            random_color[4][3] = YELLOW;
        end 
		  
		  if (state[22:20] < 3'd2) begin
            random_color[0][4] = PURPLE;
        end else if (state[22:20] < 3'd4)  begin
            random_color[0][4] = ORANGE;
        end else begin
            random_color[0][4] = YELLOW;
        end 

        if (state[23:21] < 3'd2) begin
            random_color[1][4] = PURPLE;
        end else if (state[23:21] < 3'd4)  begin
            random_color[1][4] = ORANGE;
        end else begin
            random_color[1][4] = YELLOW;
        end 
		  
        if (state[24:22] < 3'd2) begin
            random_color[2][4] = PURPLE;
        end else if (state[24:22] < 3'd4)  begin
            random_color[2][4] = ORANGE;
        end else begin
            random_color[2][4] = YELLOW;
		  end 
		  
        if (state[25:23] == 3'd2) begin
            random_color[3][4] = PURPLE;
        end else if (state[25:23] < 3'd4)  begin
            random_color[3][4] = ORANGE;
        end else begin
            random_color[3][4] = YELLOW;
        end
		  
		  if (state[26:24] < 3'd2) begin
            random_color[4][4] = PURPLE;
        end else if (state[26:24] < 3'd4)  begin
            random_color[4][4] = ORANGE;
        end else begin
            random_color[4][4] = YELLOW;
        end 
		  
		  if (state[27:25] < 3'd2) begin
            random_color[0][5] = PURPLE;
        end else if (state[27:25] < 3'd4)  begin
            random_color[0][5] = ORANGE;
        end else begin
            random_color[0][5] = YELLOW;
        end 

        if (state[28:26] < 3'd2) begin
            random_color[1][5] = PURPLE;
        end else if (state[28:26] < 3'd4)  begin
            random_color[1][5] = ORANGE;
        end else begin
            random_color[1][5] = YELLOW;
        end 
		  
        if (state[29:27] < 3'd2) begin
            random_color[2][5] = PURPLE;
        end else if (state[29:27] < 3'd4)  begin
            random_color[2][5] = ORANGE;
        end else begin
            random_color[2][5] = YELLOW;
		  end 
		  
        if (state[30:28] == 3'd2) begin
            random_color[3][5] = PURPLE;
        end else if (state[30:28] < 3'd4)  begin
            random_color[3][5] = ORANGE;
        end else begin
            random_color[3][5] = YELLOW;
        end
		  
		  if (state[31:29] < 3'd2) begin
            random_color[4][5] = PURPLE;
        end else if (state[31:29] < 3'd4)  begin
            random_color[4][5] = ORANGE;
        end else begin
            random_color[4][5] = YELLOW;
        end 
    end

endmodule
