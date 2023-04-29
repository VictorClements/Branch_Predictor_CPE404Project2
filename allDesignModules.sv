module correlatingBranchPredictor #(parameter R = 6, M = 2, N = 2)  
                                   (input  logic        clk, reset,
                                    input  logic [31:0] PC,
                                    input  logic        result,
                                    output logic        branch);

wire  [N-1:0]   state;
logic [R+M-1:0] address;
logic           OE, WE, CS;

RAM     #(R, M, N) myRAM     (CS, WE, OE, address, state);
control #(R, M, N) mycontrol (clk, reset, PC, result, state, address, OE, WE, CS, branch);

endmodule

module RAM #(parameter R = 6, M = 2, N = 8) 
            (input logic CS, WE, OE, 
             input logic [R+M-1:0] ADDR,
             inout logic [N-1:0] DATA);

logic [N-1:0] RAM[0:2**(R+M)-1];

  initial begin
    for(int i = 0; i < 2**(R+M); i++) begin
      RAM[i] = {'0,1'b1};
    end
  end

assign DATA = (CS | ~WE | OE ) ? 'Z : RAM[ADDR];

always @(negedge WE)
  if(~CS)  RAM[ADDR] <= DATA;

endmodule

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

  always_ff @(posedge clk)  begin
    currentState <= state;
  end

  assign address = {PC[R-1:0], lastMBranches};
  assign state = (CS | ~WE | OE ) ? nextstate : 'bZ;

  assign CS = 1'b0;
  assign WE = clk;
  assign OE = ~clk;

  assign shiftEnable = 1'b1;

endmodule

module shiftRegister  (input  logic       clk, reset, shiftEnable,
                       input  logic       shiftIn,
                       output logic [1:0] shiftRegisters);
  
  always_ff @(posedge clk)
    if(reset)             shiftRegisters <= 0; 
    else if(shiftEnable)  shiftRegisters <= {shiftIn, shiftRegisters[1]};
  
endmodule

module branchPredictor2Bit(input  logic branchTaken,
                           input  logic [1:0] currentState,
                           output logic [1:0] nextstate,
                           output logic prediction);

  parameter stronglyNotTaken = 2'b00;
  parameter weaklyNotTaken   = 2'b01;
  parameter weaklyTaken      = 2'b10;
  parameter stronglyTaken    = 2'b11;

  always_comb
    case(currentState)
      stronglyNotTaken: nextstate = branchTaken ? weaklyNotTaken : stronglyNotTaken;
      weaklyNotTaken:   nextstate = branchTaken ? weaklyTaken    : stronglyNotTaken;
      weaklyTaken:      nextstate = branchTaken ? stronglyTaken  : weaklyNotTaken;
      stronglyTaken:    nextstate = branchTaken ? stronglyTaken  : weaklyTaken;
      default:          nextstate = weaklyTaken;
    endcase

  assign prediction = currentState[1];

endmodule