`timescale 1ns/1ps

`include "defines.sv"
`include "interface.sv" // Ensure to include the interface definition

class driver;

  // Number of transactions and loop variable
  int no_transactions, j;             

  // Virtual interface handle
  virtual MotionEstimationInterface mem_if;      

  // Mailbox handle for Gen2Driver
  mailbox gen2driv;                   
  
  // Constructor: Initializes the virtual interface and mailbox
  function new(virtual MotionEstimationInterface mem_if, mailbox gen2driv);
    this.mem_if = mem_if; 
    this.gen2driv = gen2driv;     
  endfunction
  
  // Start task: Resets the values in memories before starting the operation
  task start;
    $display(" ================================================= Start of driver, mem_if.start: %b =================================================\n", mem_if.start);
    wait(!mem_if.start);
    $display(" ================================================= [DRIVER_INFO] Initialized to Default =================================================\n");
    for(j = 0; j < `SMEM_MAX; j++)
      mem_if.referenceMemory[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      mem_if.referenceMemory[j] <= 0;
    wait(mem_if.start);
    $display(" ================================================= [DRIVER_INFO] All Memories Set =================================================");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction transactionData;
    forever begin
      gen2driv.get(transactionData);
      $display(" ================================================= [DRIVER_INFO] :: Driving Transaction %0d ================================================= ", no_transactions);
      mem_if.referenceMemory = transactionData.referenceMemory;  // Drive referenceMemory to interface
      mem_if.searchMemory = transactionData.searchMemory;  // Drive searchMemory to interface
      mem_if.start = 1; 
      @(posedge mem_if.DriverModport.clk);
      mem_if.DriverInterface.expectedXMotion <= transactionData.expectedXMotion;  // Drive Expected X Motion to interface
      mem_if.DriverInterface.expectedYMotion <= transactionData.expectedYMotion;  // Drive Expected Y Motion to interface
      $display("[DRIVER_INFO]     :: Driver Packet Expected X Motion: %d and Expected Y Motion: %d", transactionData.expectedXMotion, transactionData.expectedYMotion);       
      wait(mem_if.completed == 1);  // Wait for DUT to signal completion
      mem_if.start = 0;
      $display("[DRIVER_INFO]     :: DUT sent completed = 1 ");
      no_transactions++;
      @(posedge mem_if.DriverModport.clk);
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
