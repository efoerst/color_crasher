// Wire the graphics generator to the vga display
module vga_graphics(
    // Inputs:
    input vgaclk,
    input rst,

    // Declare input main character position
    input reg[3:0] blockieee,

    // Declare Enemy (DDAVER) array
    input reg[11:0] ddavers [0:4][0:5],

    // Declare BulletBill information arrays
    input reg[11:0] bulletBillColor [0:2],
    input reg[3:0] bulletBillXLoc [0:2],
    input reg[3:0] bulletBillYLoc [0:2],

    // Outputs:
    output hsync,
    output vsync,
    output reg[9:0] hc,
    output reg[9:0] vc,
    output reg[3:0] red,
    output reg[3:0] green,
    output reg[3:0] blue
);

// VGA-Colors Reg
reg[11:0] vgaColorsIn [0:191];
reg[11:0] vgaColorsOut [0:191];

// Graphics generator Regs
reg[9:0] horizCount, vertCount;

// Instantiate VGA
vga battlefront(vgaclk, rst, vgaColorsIn, hsync, vsync, hc, vc, red, green, blue);

// Instantiate graphics_generator
graphics_generator i_luv_design(horizCount, vertCount, blockieee, ddavers, bulletBillColor, bulletBillXLoc, bulletBillYLoc, vgaColorsOut);

// Wire the modules together
assign vgaColorsIn = vgaColorsOut;
assign horizCount = hc;
assign vertCount = vc;

endmodule
