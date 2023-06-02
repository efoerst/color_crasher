// Graphics Generator Module
module graphics_generator(
    // Input the counters for pixel iteration
    input[9:0] horizCount,
    input[9:0] vertCount,

    // Declare input main character position
    input[3:0] blockieee,

    // Declare Enemy (DDAVER) array
    input[11:0] ddavers [0:4][0:5],

    // Declare BulletBill information arrays
    input[11:0] bulletBillColor,
    input[3:0] bulletBillXLoc,
    input[3:0] bulletBillYLoc,

    // Output VGA display colors
    /*
    ERROR 1: Latching Inferred for vgaColors
     - FIX: RGB colors are already changed bit by bit so instead of parsing an array just output these values into the other!
    */
    output reg[3:0] red,
    output reg[3:0] green,
    output reg[3:0] blue
);

// Declare VGA parameters
localparam HPIXELS = 640;
localparam VPIXELS = 480;
localparam BSIZE = 40;

// Assign vga colors
always_comb begin
    // Ensure actions occur while within the VGA Display range
    if (horizCount < HPIXELS - 1 && vertCount < VPIXELS - 1) begin
        // Set the bottom row (buffer-land) color
        if ((vertCount / BSIZE) == 11) begin
            // Set RGB Values
            red = 4'd7;
            green = 4'd7;
            blue = 4'd7;
        end

        // Set the leftmost column (a.k.a. Homeworld) color
        else if ((horizCount / BSIZE) == 0) begin
            // Set RGB Values
            red = 4'd2;
            green = 4'd8;
            blue = 4'd2;
        end

        // Blockieee color application
        else if ((horizCount / BSIZE) == 1 && (vertCount / BSIZE) == $unsigned(blockieee)) begin
            // Set RGB Values
            red = 4'd15;
            green = 4'd15;
            blue = 4'd15;
        end

        // -- Bullet Bill Battlefield Implementation --
        // BulletBill
        else if ((horizCount / BSIZE) == $unsigned(bulletBillXLoc) && (vertCount / BSIZE) == $unsigned(bulletBillYLoc) && bulletBillColor != 12'd0) begin
            // Set RGB Values
            red = bulletBillColor[11:8];
            green = bulletBillColor[7:4];
            blue = bulletBillColor[3:0];
        end

        // -- Battlefield DDaver Implementation --
        /*
            Logic Description:
                - Modulus the vertical counter (after blocking) with 2 and if the result is not 0 then it is a location for the enemy
                - Modulus the horizontal counter (after blocking) with 2 and if the result is 0 then it is a confirmed location for the enemy
                - Ensure that the location is a "visible" location for the enemy by making sure the cell is in the appropriate range
        */
        else if ((vertCount / BSIZE) % 2 != 0 && (horizCount / BSIZE) % 2 == 0 && (horizCount / BSIZE) >= 4) begin
            red = ddavers[(vertCount / BSIZE) / 2][(horizCount / BSIZE) / 2 - 2][11:8];
            green = ddavers[(vertCount / BSIZE) / 2][(horizCount / BSIZE) / 2 - 2][7:4];
            blue = ddavers[(vertCount / BSIZE) / 2][(horizCount / BSIZE) / 2 - 2][3:0];
        end

        // Assign backdrop
        else begin
            red = 4'd0;
            green = 4'd0;
            blue = 4'd0;
        end
    end

    // Do nothing if outside of the appropriate range
    else begin
        red = 4'd0;
        green = 4'd0;
        blue = 4'd0;
    end
end
endmodule
