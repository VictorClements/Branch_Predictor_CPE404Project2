module correlatingBranchPredictor #(parameter R = 6, M = 2, N = 2)  
                                   (input  logic        clk, reset,
                                    input  logic [31:0] PC,
                                    input  logic        result,
                                    output logic        branch);

wire  [N-1:0]   state;
logic [R+M-1:0] address;
logic           OE, WE, CS;

control #(R, M, N) mycontrol (clk, reset, PC, result, state, address, OE, WE, CS, branch);
RAM     #(R, M, N) myRAM     (CS, WE, OE, address, state);

endmodule

// together R and M will result in a RAM of depth 2^(R + M)
// think of R as the lower bits of the RAM address, and M as the upper bits
// R comes from the lower bits of PC and M comes from the global branch history (most recent branches)

// N will result in a RAM width of N
// N is the bitwidth of the individual n-bit branch predictors

// (m,n) predictor, with 2^r entries
// m = n = 2, r = 4
// 16 entry predictor, since r = 4
// the global branch history is 2 bits, since m = 2 (this is the 2 most recent branches) 
// the number of bits in a local predictor is 2, since n = 2

// so the total depth is 2^(R + M) = 2^(4 + 2) = 64
// and the total width is 2 bits since n = 2

// so we have the following structure:

// [1:0] RAM [0:63]

// where the ADDR = {M[1:0], R[3:0]};