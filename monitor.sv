`timescale 1ns/1ps

class monitor;

  // Loop variable
  int j;

  // Virtual interface handle
  virtual MotionEstimationInterface mem_if;
  
  // Mailbox handles for communication with scoreboard and coverage
  mailbox mon2scb;
  mailbox mon2cov;
  
  // Constructor: Initializes the virtual interface and mailboxes
  function new(virtual MotionEstimationInterface mem_if, mailbox mon2scb, mailbox mon2cov);
    this.mem_if = mem_if;
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
  endfunction
  
  // Main monitoring task: Observes DUT activity, captures transactions, and communicates with scoreboard and coverage
  task main;
    $display("================================================= Monitor Main Task =================================================\n");
    forever begin
      Transaction trans, cov_trans;
      trans = new();
      wait(mem_if.start == 1); // Wait for start signal from DUT
      @(posedge mem_if.MonitorModport.clk);
      trans.referenceMemory = mem_if.referenceMemory; // Capture R memory state
      trans.searchMemory = mem_if.searchMemory; // Capture S memory state
      @(posedge mem_if.MonitorModport.clk);
      trans.expectedXMotion = mem_if.MonitorInterface.expectedXMotion;
      trans.expectedYMotion = mem_if.MonitorInterface.expectedYMotion;
      wait(mem_if.completed); // Wait for completion signal from DUT
      $display("[MONITOR_INFO]    :: COMPLETED");
      trans.bestDistance = mem_if.MonitorInterface.bestDistance;
      trans.actualXMotion = mem_if.MonitorInterface.motionX;
      trans.actualYMotion = mem_if.MonitorInterface.motionY;

      // Adjust motionX and motionY for signed values
      if (trans.actualXMotion >= 8)
        trans.actualXMotion = trans.actualXMotion - 16;
      if (trans.actualYMotion >= 8)
        trans.actualYMotion = trans.actualYMotion - 16;
        
      $display("[MONITOR_INFO]    :: DUT OUTPUT Packet motionX: %d and motionY: %d", trans.actualXMotion, trans.actualYMotion);

      // Copy transaction data for coverage
      cov_trans = new trans; 
      
      // Send transaction to scoreboard and coverage
      mon2scb.put(trans); 
      mon2cov.put(cov_trans); 
    end
  endtask
  
endclass
