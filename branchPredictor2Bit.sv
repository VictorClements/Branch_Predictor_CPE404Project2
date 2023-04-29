
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

  assign prediction = currentState[1]; // since the top bit is 1 if predicting taken

endmodule

// module branchPredictor2Bit(input  logic clk, reset, 
//                            input  logic branchTaken,
//                            output logic prediction);

//   typedef enum logic [1:0] {stronglyNotTaken, weaklyNotTaken, weaklyTaken, stronglyTaken} statetype;
//   logic [1:0] state, nextstate;

//   always_ff @(posedge clk)
//     if(reset) state <= weaklyTaken;
//     else      state <= nextstate;

//   always_comb
//     case(state)
//       stronglyNotTaken: nextstate = branchTaken ? weaklyNotTaken : stronglyNotTaken;
//       weaklyNotTaken:   nextstate = branchTaken ? weaklyTaken    : stronglyNotTaken;
//       weaklyTaken:      nextstate = branchTaken ? stronglyTaken  : weaklyNotTaken;
//       stronglyTaken:    nextstate = branchTaken ? stronglyTaken  : weaklyTaken;
//       default:          nextstate = weaklyTaken;
//     endcase

//   assign prediction = (state == stronglyTaken) | (state == weaklyTaken);

// endmodule


// module branchPredictor #(WIDTH = 2)
//                         (input  logic             result,
//                          input  logic [WIDTH-1:0] currentState,
//                          output logic [WIDTH-1:0] nextstate
//                          output logic             prediction);

//   always_comb begin
//     if(currentState = '0) begin
//       if(result)  currentState = currentState + 1;
//       else        currentState = currentState;
//     end
//     else if(currentState = '1)  begin
//       if(result)  currentState = currentState;
//       else        currentState = currentState - 1;
//     end
//     else          currentState = result ? currentState + 1 : currentState - 1;
//   end

//   assign prediction = currentState[WIDTH-1];

// endmodule