`timescale 1ns/1ps

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverageanalysis.sv"


class environment;
  // Handles for Generator, Driver, Monitor, Scoreboard, and Coverage
  generator gen;                          
  driver driv;
  monitor mon;
  scoreboard scb;
  CoverageAnalysis cov;                 
  
  // Mailbox handles for communication between components
  mailbox gen2driv, mon2scb, mon2cov;      
  
  // Events for synchronization
  event gen_ended;
  event mon_done;
  
  // Virtual interface handle
  virtual MotionEstimationInterface memoryInterface;          

  // Constructor: Initializes the virtual interface and component instances
  function new(virtual MotionEstimationInterface memoryInterface);
    this.memoryInterface = memoryInterface;   
    gen2driv = new();
    mon2scb = new();
    mon2cov = new();
    gen = new(gen2driv, gen_ended);
    driv = new(memoryInterface, gen2driv);
    mon = new(memoryInterface, mon2scb, mon2cov);
    scb = new(mon2scb);
    cov = new(memoryInterface, mon2cov);
  endfunction
  
  // Pre-test task: Initializes default values
  task pre_test();
    $display("&&& [DRIVER_INFO]   :: *********** Driver Initialization Started ***********");
    driv.start();  // Initialize default values
  endtask
  
  // Test task: Executes the main tasks of all components
  task test();
    fork
      gen.main();
      driv.main();
      mon.main();
      scb.main();
      cov.trackCoverage();  // Updated method call
    join_any
  endtask
  
  // Post-test task: Waits for completion and prints the coverage report
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.trans_count == driv.no_transactions);
    wait(gen.trans_count == scb.no_transactions);
    $display("&&& Coverage Report = %0.2f %% &&&", cov.coverageScore);  // Updated print statement
    scb.summary();  // Print summary
  endtask 
  
  // Run task: Executes the complete test sequence
  task run;
    pre_test();
    $display("&&& [ENV_INFO] Test Started &&&");
    test();
    post_test();
    $finish;
  endtask
  
endclass;
