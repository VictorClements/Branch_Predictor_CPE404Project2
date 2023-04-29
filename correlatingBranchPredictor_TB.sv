module correlatingBranchPredictor_TB();

// signals
logic [31:0] PC;
logic [34:0] junk;
logic        clk, result, branch, reset;

logic [67:0] testvectors [0:1799];
logic [31:0] vectornum, correctPredictions;

//
initial begin
  $readmemh("history.txt", testvectors);
  vectornum = 0; correctPredictions = 0;
  reset = 1;
  #7;
  reset = 0;
end

// generate the clock
always begin
  clk = 1; #5;
  clk = 0; #5;
end

// inject test vector
always @(negedge clk) begin
  #3; {PC, junk, result} = testvectors[vectornum];
  #4; vectornum = vectornum + 1;
end

// instantiate DUT         #(R, M, N)
correlatingBranchPredictor #(8, 0, 2) dut(clk, reset, PC, result, branch);

always @(negedge clk) begin
  if(~reset)  begin
    if(testvectors[vectornum] === 68'bx)  begin
      $display("%0d/%0d correct predictions", correctPredictions, vectornum);
      $stop;
    end
    else correctPredictions = correctPredictions + (result == branch);
  end
end

endmodule