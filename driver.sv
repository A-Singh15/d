`timescale 1ns/1ps

`include "defines.sv"
`include "transaction.sv"

class driver;

  // Number of transactions and loop variable
  int no_transactions, j;             

  // Virtual interface handle
  virtual MotionEstimationInterface memIntf;      

  // Mailbox handle for Gen2Driver
  mailbox gen2driv;                   
  
  // Constructor: Initializes the virtual interface and mailbox
  function new(virtual MotionEstimationInterface memIntf, mailbox gen2driv);
    this.memIntf = memIntf; 
    this.gen2driv = gen2driv;     
  endfunction
  
  // Start task: Resets the values in memories before starting the operation
  task start;
    $display(" ================================================= Start of driver, memIntf.start: %b =================================================\n", memIntf.start);
    wait(!memIntf.start);
    $display(" ================================================= [DRIVER_INFO] Initialized to Default =================================================\n");
    for(j = 0; j < `SMEM_MAX; j++)
      memIntf.searchMemory[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      memIntf.referenceMemory[j] <= 0;
    wait(memIntf.start);
    $display(" ================================================= [DRIVER_INFO] All Memories Set =================================================");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction transactionData;
    forever begin
      gen2driv.get(transactionData);
      $display(" ================================================= [DRIVER_INFO] :: Driving Transaction %0d ================================================= ", no_transactions);
      memIntf.referenceMemory = transactionData.referenceMemory;  // Drive referenceMemory to interface
      memIntf.searchMemory = transactionData.searchMemory;  // Drive searchMemory to interface
      memIntf.start = 1; 
      @(posedge memIntf.DriverInterface.clk);
      memIntf.expectedXMotion <= transactionData.expectedXMotion;  // Drive Expected Motion X to interface
      memIntf.expectedYMotion <= transactionData.expectedYMotion;  // Drive Expected Motion Y to interface
      $display("[DRIVER_INFO]     :: Driver Packet Expected X Motion: %d and Expected Y Motion: %d", transactionData.expectedXMotion, transactionData.expectedYMotion);       
      wait(memIntf.completed == 1);  // Wait for DUT to signal completion
      memIntf.start = 0;
      $display("[DRIVER_INFO]     :: DUT sent completed = 1 ");
      no_transactions++;
      @(posedge memIntf.DriverInterface.clk);
    end
  endtask

  // Main task: Starts the driver and continuously drives transactions
  task main;
    $display("[DRIVER_INFO]   :: ================================================= Driver Main Started =================================================");
    forever begin
      fork
        begin
          forever
            drive();
        end
      join
      disable fork;
    end
  endtask
        
endclass
