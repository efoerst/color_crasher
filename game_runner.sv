// Top Level Diagram
module game_runner(clk, rst, sda, scl, hsync, vsync, hc, vc, red, green, blue);
	input clk, rst;
	inout sda;
	output scl;
	output hsync, vsync;
	output reg [9:0] hc, vc;
	output reg [3:0] red, green, blue;
	
	reg [3:0] blockieee;
	reg [11:0] ddavers [0:4][0:5];
	reg [11:0] bulletBillColor [0:2];
	reg [3:0] bulletBillXLoc [0:2];
	reg [3:0] bulletBillYLoc [0:2];
	reg [3:0] red_in;
	reg [3:0] green_in;
	reg [3:0] blue_in;
	reg [7:0] stick_y;
	reg z, c;

	////////////////////////////////////////////////////////////////////////////////////
	// Throw away data
	reg [9:0] accel_x, accel_y, accel_z;
	reg [7:0] stick_x;
	////////////////////////////////////////////////////////////////////////////////////
	
	// Clocking Parameter Declarations
	localparam I2C_CLOCK_SPEED = 400000;
	localparam VGA_CLOCK = 25000000;
	localparam MESSAGE_RATE = 100;
	localparam BLOCKIEEE_SPEED = 60;
	localparam DDAVER_SPEED = 1;
	localparam BULLET_SPEED = 90;
	
	wire i2c_clock, polling_clock, vga_clock, blockieee_clock, ddaver_clock, bullet_clock;
	
	// Clock Divider Instantiations
	clockdividers #(VGA_CLOCK) vga_clock_uut(clk, rst, vga_clock);
	clockdividers #(BLOCKIEEE_SPEED) blockieee_clock_uut(clk, rst, blockieee_clock);
	clockdividers #(DDAVER_SPEED) ddaver_clock_uut(clk, rst, ddaver_clock);
	clockdividers #(BULLET_SPEED) bullet_clock_uut(clk, rst, bullet_clock);

	// Game Interface Instantiations
	nunchuck_translator hablo_i2c(clk, sda, scl, stick_x, stick_y, accel_x, accel_y, accel_z, z, c, rst);
	graphics_generator i_luv_design(hc, vc, blockieee, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc, red_in, green_in, blue_in);
	vga dispos(vga_clock, rst, red_in, green_in, blue_in, hsync, vsync, hc, vc, red, green, blue);
	game_state_updater gamer_moment();

endmodule
