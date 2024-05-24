`timescale 1ns/10ps

`include "defines.sv"
`include "interface.sv"
`include "test.sv"
`include "assertion.sv"

module top_tb();
  bit clk;
  always #10 clk = ~clk;  // Clock Generation
  
  initial begin 
    $display(" ================================================= TB Start = 0 =================================================\n");
    mem_if.start = 1'b0;
    repeat(2) @(posedge clk);
    mem_if.start = 1'b1;
  end
  
  MotionEstimationInterface mem_if(clk);  // Interface Instantiation
  ROM_R memR_u(.clock(clk), .AddressR(mem_if.AddressR), .R(mem_if.R));
  ROM_S memS_u(.clock(clk), .AddressS1(mem_if.AddressS1), .AddressS2(mem_if.AddressS2), .S1(mem_if.S1), .S2(mem_if.S2));
  
  assign memR_u.Rmem = mem_if.referenceMemory;
  assign memS_u.Smem = mem_if.searchMemory;

  test Motion_Estimator(mem_if);  // Test instantiation

  initial begin
    $vcdpluson();
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  top dut(  // DUT Instantiation
    .clock(mem_if.clk), 
    .start(mem_if.start), 
    .bestDistance(mem_if.bestDistance), 
    .motionX(mem_if.motionX), 
    .motionY(mem_if.motionY), 
    .AddressR(mem_if.AddressR), 
    .AddressS1(mem_if.AddressS1), 
    .AddressS2(mem_if.AddressS2), 
    .R(mem_if.R), 
    .S1(mem_if.S1), 
    .S2(mem_if.S2), 
    .completed(mem_if.completed)
  );

  // Bind statement to bind the assertions module to the top module
  bind dut MotionEstimationAssertions assertion_instance (
    .clk(mem_if.clk), 
    .trigger(mem_if.start), 
    .distance(mem_if.bestDistance), 
    .vectorX(mem_if.motionX), 
    .vectorY(mem_if.motionY),  
    .done(mem_if.completed)
  );

endmodule
