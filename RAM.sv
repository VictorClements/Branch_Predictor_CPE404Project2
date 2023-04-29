module RAM #(parameter R = 6, M = 2, N = 8) 
            (input logic CS, WE, OE, 
             input logic [R+M-1:0] ADDR,
             inout logic [N-1:0] DATA);

// declare a ram with bitwidth N and depth of 2^(R+M)
logic [N-1:0] RAM[0:2**(R+M)-1];

// will need to initialize the RAM at the start of simulation, necessary for branch predictor
// and I have chosen to initialize everything to "Weakly predict pranch not taken"
  initial begin
    for(int i = 0; i < 2**(R+M); i++) begin
      RAM[i] = {'0,1'b1};
    end
  end

// if this chip isnt selected, or if we are writing to it, or if we are not outputting from the chip
// then it should output high impedence.
// If the chip is selected, we are not writing to it, and we are outputting from the chip
// then it should output the value at the given address (asynchronously)
assign DATA = (CS | ~WE | OE ) ? 'Z : RAM[ADDR]; //read from RAM

// synchronous to the write enable signal
// if we want to write, then the WE signal deasserts to zero
// then only if the chip is selected, we write the given data to the address
always @(negedge WE)
  if(~CS)  RAM[ADDR] <= DATA;

endmodule
