`timescale 1ns/1ns
module vga_tb(output reg clk);
	initial begin
		clk = 0;
	end
	
	wire rst = 1;
	wire [3:0] red, green, blue;

	wire blockieee_clock; // 60 hz
    wire ddaver_clock;    // 30 hz
    wire bullet_clock;    // 90 hz

	wire[7:0] stick_y;
	wire z;
	wire c;

	wire[3:0] blockieee_pos;
	wire[11:0] ddavers [0:4][0:5];
	wire[11:0] bulletBillColor;
	wire[3:0] bulletBillXLoc;
	reg[3:0] bulletBillYLoc;
	
	always begin
		#10 clk = ~clk;   // 180 hz
	end

	game_state_updater UUT(rst, clk, stick_y, z, c, blockieee_pos, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc);
	game_runner UUT2(clk, rst, sda, scl, hsync, vsync, leds, red, green, blue);
endmodule
