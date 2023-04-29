module control #(parameter R = 4, M = 2, N = 2) 
                (input  logic           clk, reset,
                 input  logic [31:0]    PC,
                 input  logic           result,
                 inout  logic [N-1:0]   state,
                 output logic [R+M-1:0] address,
                 output logic           OE, WE, CS, branch);

  logic [M-1:0]   lastMBranches;
  logic [N-1:0]   currentState, nextstate;
  logic           shiftEnable;

  shiftRegister       globalBranchHistory (clk, reset, shiftEnable, result, lastMBranches);
  branchPredictor2Bit branchPredictor2Bit (result, currentState, nextstate, branch);

  // read from RAM after posedge of clk
  always_ff @(posedge clk)  begin
    currentState <= state;
  end

  // write to RAM after negedge of clk

  assign address = {PC[R-1:0], lastMBranches};
  assign state = (CS | ~WE | OE ) ? nextstate : 'bZ;

  assign CS = 1'b0;
  assign WE = clk;
  assign OE = ~clk;

  assign shiftEnable = 1'b1;

endmodule