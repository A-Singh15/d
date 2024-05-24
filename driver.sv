`timescale 1ns/1ps

`include "defines.sv"

class driver;

  // Number of transactions and loop variable
  int no_transactions, j;             

  // Virtual interface handle
  virtual MotionEstimationInterface interface;      

  // Mailbox handle for Gen2Driver
  mailbox gen2driv;                   
  
  // Constructor: Initializes the virtual interface and mailbox
  function new(virtual MotionEstimationInterface interface, mailbox gen2driv);
    this.interface = interface; 
    this.gen2driv = gen2driv;     
  endfunction
  
  // Start task: Resets the values in memories before starting the operation
  task start;
    $display(" ================================================= Start of driver, interface.start: %b =================================================\n", interface.start);
    wait(!interface.start);
    $display(" ================================================= [DRIVER_INFO] Initialized to Default =================================================\n");
    for(j = 0; j < `SMEM_MAX; j++)
      `DRIV_IF.searchMemory[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      `DRIV_IF.referenceMemory[j] <= 0;
    wait(interface.start);
    $display(" ================================================= [DRIVER_INFO] All Memories Set =================================================");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction transactionData;
    forever begin
      gen2driv.get(transactionData);
      $display(" ================================================= [DRIVER_INFO] :: Driving Transaction %0d ================================================= ", no_transactions);
      interface.referenceMemory = transactionData.referenceMemory;  // Drive referenceMemory to interface
      interface.searchMemory = transactionData.searchMemory;  // Drive searchMemory to interface
      interface.start = 1; 
      @(posedge interface.ME_DRIVER.ME_driver_cb.clk);
      `DRIV_IF.expectedXMotion <= transactionData.expectedXMotion;  // Drive Expected X Motion to interface
      `DRIV_IF.expectedYMotion <= transactionData.expectedYMotion;  // Drive Expected Y Motion to interface
      $display("[DRIVER_INFO]     :: Driver Packet Expected X Motion: %d and Expected Y Motion: %d", transactionData.expectedXMotion, transactionData.expectedYMotion);       
      wait(interface.completed == 1);  // Wait for DUT to signal completion
      interface.start = 0;
      $display("[DRIVER_INFO]     :: DUT sent completed = 1 ");
      no_transactions++;
      @(posedge interface.ME_DRIVER.ME_driver_cb.clk);
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
