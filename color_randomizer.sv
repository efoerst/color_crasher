module Randomizer(
  input wire clk,
  input wire reset,
  output reg [2:0] random_number
);

  reg [2:0] counter;
  reg [2:0] random;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      random <= 0;
    end
    else begin
      counter <= counter + 1;
      if (counter >= 3) begin
        random <= $random % 6; // Generates random number from 0 to 5
        counter <= 0;
      end
    end
  end

  always @(posedge clk) begin
    random_number <= random;
  end

endmodule
//In this Verilog module, we have an internal counter that increments on every clock cycle. When the counter reaches a value of 3, it generates a new random number using the $random system function, which returns a random 32-bit number. We take the modulo 6 of this value to restrict the range from 0 to 5.

//The reset input signal is used to reset the counter and random number back to their initial states (0) whenever it's asserted.

//The output random_number will be updated with the generated random number on every clock cycle.

//Please note that the $random function is a system function and its behavior might differ based on the specific Verilog simulator you are using.






