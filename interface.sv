`timescale 1ns/1ps

`default_nettype none

// Memory Estimator Interface
interface MotionEstimationInterface(input bit clk);

  // Signals
  bit start; 
  logic [3:0] motionX;
  logic [3:0] motionY;
  integer expectedXMotion;
  integer expectedYMotion;
  logic [7:0] AddressR;
  logic [9:0] AddressS1;
  logic [9:0] AddressS2;
  logic [7:0] R;
  logic [7:0] S1;
  logic [7:0] S2;
  logic [7:0] bestDistance;
  logic completed;
  logic [7:0] referenceMemory[`RMEM_MAX-1:0];
  logic [7:0] searchMemory[`SMEM_MAX-1:0];

  // Clocking block for driver
  clocking DriverInterface @(posedge clk);
    default input #1 output #1;
    output referenceMemory;
    output searchMemory;
    output R;
    output S1;
    output S2;
    output expectedXMotion;
    output expectedYMotion;
    input bestDistance;
    input motionX, motionY;
    input AddressR;
    input AddressS1;
    input AddressS2;
    input completed;
  endclocking
  
  // Clocking block for monitor
  clocking MonitorInterface @(posedge clk);
    default input #1 output #1;
    input referenceMemory;
    input searchMemory;
    input R;
    input S1;
    input S2;
    input expectedXMotion;
    input expectedYMotion;
    input motionX, motionY;
    input AddressR;
    input AddressS1;
    input AddressS2;
    input completed;
    input bestDistance;
  endclocking
  
  // Modport for driver
  modport DriverModport (clocking DriverInterface, input clk, start);
  
  // Modport for monitor
  modport MonitorModport (clocking MonitorInterface, input clk, start);

endinterface
