// Top Level Diagram
module game_runner(clk, rst, sda, scl, hsync, vsync, leds, red, green, blue);
	input clk, rst;
	inout sda;
	output scl;
	output hsync, vsync;
	output [9:0] leds;
	output reg [3:0] red, green, blue;
	
   reg[9:0] hc;
   reg[9:0] vc;
	
	reg [3:0] blockieee;
	reg [11:0] ddavers [0:4][0:5];
	reg [11:0] bulletBillColor [0:2];
	reg [3:0] bulletBillXLoc [0:2];
	reg [3:0] bulletBillYLoc [0:2];
	reg [3:0] red_in;
	reg [3:0] green_in;
	reg [3:0] blue_in;
	wire [7:0] stick_y;
	reg z, c;

	////////////////////////////////////////////////////////////////////////////////////
	// Throw away data
	wire [9:0] accel_x, accel_y, accel_z;
	wire [7:0] stick_x;
	////////////////////////////////////////////////////////////////////////////////////
	
	assign leds = {2'b0, stick_y};
	
	// Clocking Parameter Declarations
	localparam I2C_CLOCK_SPEED = 400000;
	localparam VGA_CLOCK = 25000000;
	localparam MESSAGE_RATE = 100;
	localparam BLOCKIEEE_SPEED = 60;
	localparam DDAVER_SPEED = 1;
	localparam BULLET_SPEED = 90;
	
	wire i2c_clock, polling_clock, vga_clock, blockieee_clock, ddaver_clock, bullet_clock;
	
	// Clock Divider Instantiations
	clockdivider #(VGA_CLOCK) vga_clock_uut(clk, !rst, vga_clock);
	clockdivider #(BLOCKIEEE_SPEED) blockieee_clock_uut(clk, !rst, blockieee_clock);
	clockdivider #(DDAVER_SPEED) ddaver_clock_uut(clk, !rst, ddaver_clock);
	/*clockdivider #(BULLET_SPEED) bullet_clock_uut(clk, !rst, bullet_clock);*/
	
	// clock_divider #(50000000) vga_clock_uut(clk, VGA_CLOCK, !rst, vga_clock);
	//clock_divider #(25000000) blockieee_clock_uut(vga_clock, BLOCKIEEE_SPEED, !rst, blockieee_clock);
	//clock_divider #(50000000) ddaver_clock_uut(clk, DDAVER_SPEED, !rst, ddaver_clock);
	//clock_divider #(50000000) bullet_clock_uut(clk, BULLET_SPEED, !rst, bullet_clock);
	// Game Interface Instantiations
	nunchuckDriver hablo_i2c(clk, sda, scl, stick_x, stick_y, accel_x, accel_y, accel_z, z, c, !rst);
	game_state_updater gamer_moment(~rst, blockieee_clock, ddaver_clock, bullet_clock, stick_y, z, c, blockieee, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc);
	graphics_generator i_luv_design(hc, vc, blockieee, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc, red_in, green_in, blue_in);
	vga dispos(vga_clock, rst, red_in, green_in, blue_in, hsync, vsync, hc, vc, red, green, blue);

endmodule
