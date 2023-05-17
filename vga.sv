module vga(
    input vgaclk,
    input rst,
    output hsync,
    output vsync,
    output reg[9:0] hc,
    output reg[9:0] vc,
    output reg[3:0] red,
    output reg[3:0] green,
    output reg[3:0] blue,
);

// Instantiate graphics_generator
// TODO: Instantiate Here

// Declare parameters
localparam HPIXELS = 640;
localparam HPULSE = 96;
localparam HBP = 48;
localparam HFP = 16;

localparam VLINES = 480;
localparam VPULSE = 2;
localparam VBP = 33;
localparam VFP = 10;

// Declare horizontal and vertical counters
reg[9:0] hc = 0;
reg[9:0] vc = 0;

// Change hc & vc correspondingly to the current state
always @(posedge vgaclk) begin
    // RST
    if (rst == 0)begin
        hc <= 0;
        vc <= 0;
    end
    else begin
        // Go through pixel by pixel [include the blanking interval]
        // Reach the final pixel
        if (hc == HPIXELS + HFP + HPULSE + HBP - 1) && (vc == VLINES + VFP + VPULSE + VBP - 1) begin
            hc <= 0;
            vc <= 0;
        end
        // Otherwise continue through the VGA
        else begin
            // Have we reached the end of the horizontal "screen"
            if (hc == HPIXELS + HFP - 1) begin
                hc <= hc + 1;
            end
            // Include the pulse and front porch
            else if (hc == HPIXELS + HFP  + HPULSE - 1) begin
                hc <= hc + 1;
            end
            // Go down a level
            else if (hc == HPIXELS + HFP + HPULSE + HBP - 1) begin
                vc <= vc + 1;
                hc <= 0;
            end
            // IF not any of these cases
            else begin
                hc <= hc + 1;
            end
        end
    end
end

assign hsync = !(hc > HPIXELS + HFP - 1 && hc <= HPIXELS + HFP + HPULSE - 1);
assign vsync = !(vc > VLINES + VFP - 1 && vc <= VLINES + VFP + VPULSE - 1);`

// RGB output block
always_comb begin
    // Check to see if within vertical active video range
    if (vc < VLINES - 1 && hc < HPIXELS - 1)begin
        
    end
    else begin
        // Output black
        red = 4'd0;
        green = 4'd0;
        blue = 4'd0;
    end
end
endmodule
