// module shiftRegister #(parameter REGISTER_COUNT = 2, WIDTH = 1)
//                       (input  logic clk, reset, shiftEnable,
//                        input  logic [WIDTH-1:0] wordIn,
//                        output logic [WIDTH-1:0] shiftRegisters [REGISTER_COUNT-1:0]);
  
//   always_ff @(posedge clk)
//     if(reset)             shiftRegisters <= '{default:0}; 
//     else if(shiftEnable)  shiftRegisters <= {shiftRegisters[REGISTER_COUNT-2:0], wordIn};
  
// endmodule

module shiftRegister  (input  logic       clk, reset, shiftEnable,
                       input  logic       shiftIn,
                       output logic [1:0] shiftRegisters);
  
  always_ff @(posedge clk)
    if(reset)             shiftRegisters <= 0; 
    else if(shiftEnable)  shiftRegisters <= {shiftIn, shiftRegisters[1]};
  
endmodule