module RAM_tb();

parameter R = 6; // think of this as the lower bits of the address, and it will come from PC
parameter M = 2; // think of this as the upper bits of the address, which comes from global history
parameter N = 8; // RAM width = 8

// for testing
parameter firstAlternations  = 8'b0101_0101;
parameter secondAlternations = 8'b1010_1010;
logic           sequenceChoice;

// DUT logic signals
logic           clk;
logic           CS, WE, OE;
logic [R+M-1:0] ADDR;
logic [N-1:0]   DataOther;
wire  [N-1:0]   DATA;
logic [N-1:0]   dataWrite;
logic           writestage;

// because we have an INOUT port
assign DATA = (CS | ~WE | OE ) ? DataOther : 'bZ;

// instantiate DUT
RAM #(R, M, N) DUT(CS, WE, OE, ADDR, DATA);

// generate the clock
always begin
  clk = 0; #5;
  clk = 1; #5;
end

// initial conditions
initial begin
  // 
  writestage = 1; CS = 0; OE = 1;
  sequenceChoice = 1;
  DataOther = firstAlternations;
  ADDR = 8'h00;

  #2559
  writestage = 0; OE = 0;

  #2560
  writestage = 1; OE = 1;
  sequenceChoice = 0;
  DataOther = secondAlternations;
  ADDR = 8'h00;

  #2560
  writestage = 0; OE = 0;
end

// every rising edge
always_ff @(posedge clk)  begin
  sequenceChoice <= ~sequenceChoice; // negate sequence Choice
  ADDR <= ADDR + 1; // increment the address
  // if we are writing, then assign DataOther to a digit sequence
  if(~WE) DataOther <= sequenceChoice ? secondAlternations : firstAlternations;
end

// every falling edge
always_ff @(negedge clk)
  // only if we are not writing anymore
  if(~writestage) begin
    // display the read in value and expected value
    $display("RAM[%d] = %h (%h expected), ", ADDR, DATA, sequenceChoice ? firstAlternations :  secondAlternations);
    if(DATA === (sequenceChoice ? firstAlternations :  secondAlternations))
      $display("Correct!");
    else
      $display("Incorrect!");
  end

assign WE = writestage ? ~clk : 1'b1;

endmodule