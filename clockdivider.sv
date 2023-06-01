module clockdivider #(parameter MESSAGE_RATE) (input clk, input rst, output reg newClk);
    // Declare the necessary counter
    localparam COUNTING_LENGTH = 50000000 / MESSAGE_RATE;
    reg [$clog2(COUNTING_LENGTH)-1:0] counter = 0;

    // Now we get to divide the 50 MHz onbaord clock by the counter we created
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
    always_comb begin
        if(counter >= COUNTING_LENGTH/2)begin
            newClk = 1;
        end else begin
            newClk = 0;
        end
    end
endmodule

module clockDivider(input inClock, output reg outClock, input reset);
	parameter SPEED = 100; //default of 100Hz
	integer counter = 0;
	localparam threshold = 50000000 / (2*SPEED);
	initial begin
		outClock = 0;
		counter = 0;
	end
	
	always@(posedge inClock) begin
		if(reset) begin
			counter <= 0;
			outClock <= 0;
		end
		else begin
			counter <= counter + 1;
			if(counter == threshold) begin
				outClock <= ~outClock;
				counter <=0;
			end
		end
	end
endmodule
