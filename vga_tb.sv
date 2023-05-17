`timescale 1ns/1ns
module vga_tb(output reg clk, output hsync, output vsync);
	initial begin
		clk = 0;
	end
	
	wire rst = 1;
	wire [3:0] red, green, blue;
	
	always begin
		#10 clk = ~clk;
	end
	
	vga disp(clk, rst, hsync, vsync, red, green, blue);
endmodule