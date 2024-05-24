`timescale 1ns/1ps

`include "environment.sv"

program test(MotionEstimationInterface memoryInterface); 

  // Instance of the environment class
  environment env;
  
  // Initial block to set up and run the environment
  initial begin
    env = new(memoryInterface);  // Create a new environment instance with the given interface
    env.gen.trans_count = `TRANSACTION_COUNT;  // Set the total number of transactions to be generated
    env.run();  // Start the run task of the environment
  end
endprogram
