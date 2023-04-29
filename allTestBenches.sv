module correlatingBranchPredictor_TB();

logic [31:0] PC;
logic [34:0] junk;
logic        clk, result, branch, reset;

logic [67:0] testvectors [0:1799];
logic [31:0] vectornum, correctPredictions;

initial begin
  $readmemh("history.txt", testvectors);
  vectornum = 0; correctPredictions = 0;
  reset = 1;
  #7;
  reset = 0;
end

always begin
  clk = 1; #5;
  clk = 0; #5;
end

always @(negedge clk) begin
  #3; {PC, junk, result} = testvectors[vectornum];
  #4; vectornum = vectornum + 1;
end

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

module RAM_tb();

parameter firstAlternations  = 8'b0101_0101;
parameter secondAlternations = 8'b1010_1010;
logic           sequenceChoice;

logic           clk;
logic           CS, WE, OE;
logic [R+M-1:0] ADDR;
logic [N-1:0]   DataOther;
wire  [N-1:0]   DATA;
logic [N-1:0]   dataWrite;
logic           writestage;

assign DATA = (CS | ~WE | OE ) ? DataOther : 'bZ;

RAM #(6, 2, 8) DUT(CS, WE, OE, ADDR, DATA);

always begin
  clk = 0; #5;
  clk = 1; #5;
end

initial begin
  writestage = 1; CS = 0; OE = 1;
  sequenceChoice = 1;
  DataOther = firstAlternations;
  ADDR = 8'h00;
  #2559;
  writestage = 0; OE = 0;
  #2560;
  writestage = 1; OE = 1;
  sequenceChoice = 0;
  DataOther = secondAlternations;
  ADDR = 8'h00;
  #2560;
  writestage = 0; OE = 0;
end

always_ff @(posedge clk)  begin
  sequenceChoice <= ~sequenceChoice;
  ADDR <= ADDR + 1;
  if(~WE) DataOther <= sequenceChoice ? secondAlternations : firstAlternations;
end

always_ff @(negedge clk)
  if(~writestage) begin
    $display("RAM[%d] = %h (%h expected), ", ADDR, DATA, sequenceChoice ? firstAlternations :  secondAlternations);
    if(DATA === (sequenceChoice ? firstAlternations :  secondAlternations))
      $display("Correct!");
    else
      $display("Incorrect!");
  end

assign WE = writestage ? ~clk : 1'b1;

endmodule