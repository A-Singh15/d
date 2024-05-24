`timescale 1ns/10ps

`include "defines.sv"
`include "interface.sv"
`include "test.sv"
`include "assertion.sv"

module top_tb();
  bit clk;
  always #10 clk = ~clk;  // Clock Generation
  
  initial begin 
    $display("$$$$$ [ENV_INFO] Testbench Start $$$$$");
    memoryInterface.start = 1'b0;
    repeat(2) @(posedge clk);
    memoryInterface.start = 1'b1;
  end
  
  MotionEstimationInterface memoryInterface(clk);  // Interface Instantiation
  ROM_R memR_u(.clock(clk), .AddressR(memoryInterface.AddressR), .R(memoryInterface.R));
  ROM_S memS_u(.clock(clk), .AddressS1(memoryInterface.AddressS1), .AddressS2(memoryInterface.AddressS2), .S1(memoryInterface.S1), .S2(memoryInterface.S2));
  
  assign memR_u.Rmem = memoryInterface.referenceMemory;  // Updated variable name
  assign memS_u.Smem = memoryInterface.searchMemory;     // Updated variable name

  test Motion_Estimator(memoryInterface);  // Test instantiation

  initial begin
    $vcdpluson();
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  top dut(  // DUT Instantiation
    .clock(memoryInterface.clk), 
    .start(memoryInterface.start), 
    .BestDist(memoryInterface.bestDistance),  // Updated variable name
    .motionX(memoryInterface.motionX), 
    .motionY(memoryInterface.motionY), 
    .AddressR(memoryInterface.AddressR), 
    .AddressS1(memoryInterface.AddressS1), 
    .AddressS2(memoryInterface.AddressS2), 
    .R(memoryInterface.R), 
    .S1(memoryInterface.S1), 
    .S2(memoryInterface.S2), 
    .completed(memoryInterface.completed)
  );

  // Bind statement to bind the assertions module to the top module
  bind dut MotionEstimationAssertions assertion_instance (
    .clk(memoryInterface.clk), 
    .trigger(memoryInterface.start), 
    .distance(memoryInterface.bestDistance),  // Updated variable name
    .vectorX(memoryInterface.motionX), 
    .vectorY(memoryInterface.motionY),  
    .done(memoryInterface.completed)
  );

endmodule
