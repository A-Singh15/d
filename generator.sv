`timescale 1ns/1ps

class generator;

  // Transaction class handle
  rand Transaction trans;

  // Number of transactions to generate (set to 1 for single transaction)
  int trans_count = 1;

  // Mailbox handle for communication with driver
  mailbox gen2driv;

  // Event to signal end of generation
  event ended;

  // Constructor: Initializes mailbox and event handles
  function new(mailbox gen2driv, event ended);
    this.gen2driv = gen2driv;
    this.ended = ended;
  endfunction

  // Main task: Generates transactions and sends them to the driver
  task main();
    $display("================================================= [GEN_INFO]: Generator Main Task =================================================");
    repeat (trans_count) begin
      trans = new();
      if (!trans.randomize()) $fatal("[GEN_ERROR] :: Randomization failed"); // Randomize Transaction class
      trans.generateReferenceMemory(); // Generate referenceMemory from searchMemory
      trans.display();
      gen2driv.put(trans); // Put transaction packet into mailbox
    end
    -> ended; // Signal that generation is ended
  endtask

endclass
