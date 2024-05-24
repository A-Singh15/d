`timescale 1ns/1ps

class CoverageAnalysis;

  // Metric for tracking coverage
  real coverageScore;

  // Virtual interface to memory
  virtual MotionEstimationInterface mem_intf;

  // Mailbox for receiving transactions from the monitor
  mailbox monitorMailbox;

  // Object for transactions
  Transaction transactionData;
      
  // Covergroup for measuring coverage
  covergroup CoverageMetrics;
    option.per_instance = 1;
    
    // Coverpoint for bestDistance
    cpBestDistance: coverpoint transactionData.bestDistance;

    // Coverpoint for expected X motion values
    cpExpectedXMotion: coverpoint transactionData.expectedXMotion {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for expected Y motion values
    cpExpectedYMotion: coverpoint transactionData.expectedYMotion {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for actual X motion values
    cpActualXMotion: coverpoint transactionData.actualXMotion {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for actual Y motion values
    cpActualYMotion: coverpoint transactionData.actualYMotion {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }
    
    // Cross coverage for expected motion
    crossExpected: cross cpExpectedXMotion, cpExpectedYMotion;
    
    // Cross coverage for actual motion
    crossActual: cross cpActualXMotion, cpActualYMotion;
  endgroup
  
  // Constructor to initialize the coverage analysis
  function new(virtual MotionEstimationInterface mem_intf, mailbox monitorMailbox);
    this.mem_intf = mem_intf;
    this.monitorMailbox = monitorMailbox;
    CoverageMetrics = new();
  endfunction
   
  // Task to sample and update coverage metrics
  task trackCoverage();
    begin
      forever begin
        monitorMailbox.get(transactionData);        // Receive a transaction
        CoverageMetrics.sample();                   // Sample the covergroup
        coverageScore = CoverageMetrics.get_coverage(); // Update the coverage metric
      end
    end
  endtask
  
endclass
