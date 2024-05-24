`timescale 1ns/1ps

class Transaction;

  // Memory arrays for reference and search data
  logic [7:0] referenceMemory[`RMEM_MAX-1:0];
  rand logic [7:0] searchMemory[`SMEM_MAX-1:0];

  // Motion vectors and best distance metrics
  rand integer expectedXMotion;
  rand integer expectedYMotion;
  integer actualXMotion;
  integer actualYMotion;
  logic [7:0] bestDistance;

  // Random index for introducing mismatches
  rand int randMismatchIndex;
  
  // Constraints for expected motion vectors
  constraint expectedMotionConstraint { 
    expectedXMotion dist {[-8:0]:=10, [1:7]:=10};
    expectedYMotion dist {[-8:0]:=10, [1:7]:=10};
  };

  // Constraints for mismatch index distribution
  constraint mismatchIndexConstraint {
    soft randMismatchIndex dist {[0:255] := 10, [256:511] := 10, [512:767] := 10}; 
  };

  // Constraints for search memory values
  constraint searchMemoryConstraint {
    foreach(searchMemory[i]) searchMemory[i] inside {[0:`SMEM_MAX-1]};
  };

  // Display function to output transaction details
  function void display();
    $display(" ================================================= [TRANSACTION_INFO] :: searchMemory Generated =================================================");
    for (int j = 0; j < `SMEM_MAX; j++) begin
      if (j % 32 == 0) $display("  ");
      $write("%h  ", searchMemory[j]);
      if (j == 1023) $display("  ");
    end

    $display(" ================================================= [TRANSACTION_INFO] :: referenceMemory Generated =================================================");
    for (int j = 0; j < `RMEM_MAX; j++) begin
      if (j % 16 == 0) $display("  ");
      $write("%h ", referenceMemory[j]);
      if (j == 255) $display("  ");
    end

    $display("\n[TRANSACTION_INFO] :: Rand_mismatch_index : %0d", randMismatchIndex);     
    $display("[TRANSACTION_INFO] :: Expected X Motion : %0d", expectedXMotion);
    $display("[TRANSACTION_INFO] :: Expected Y Motion : %0d", expectedYMotion);
  endfunction

  // Function to generate reference memory based on search memory and motion vectors
  function void generateReferenceMemory();
    foreach (referenceMemory[i]) begin
      // Generate a full match by default
      referenceMemory[i] = searchMemory[32 * 8 + 8 + (((i / 16) + expectedYMotion) * 32) + ((i % 16) + expectedXMotion)];
      
      // Introduce a partial match at the random mismatch index
      if (i == randMismatchIndex)   
        referenceMemory[i] = $urandom_range(0, 255);
    end

    // Shuffle referenceMemory to create no match if randMismatchIndex is above a threshold
    if (randMismatchIndex >= 400) begin
      referenceMemory.shuffle();
    end
  endfunction

endclass
