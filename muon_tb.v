`timescale 1ns/1ps

module muon_detector_tb;

  // Inputs
  reg clk = 0;
  reg reset = 0;
  reg event_A = 0;
  reg event_B = 0;

  // Outputs
  wire [63:0] timestamp_out;
  wire event_valid;
  wire buffer_empty;
  wire buffer_full;

  // Instantiate the DUT
  muon_detector uut (
    .clk(clk),
    .reset(reset),
    .event_A(event_A),
    .event_B(event_B),
    .timestamp_out(timestamp_out),
    .event_valid(event_valid),
    .buffer_empty(buffer_empty),
    .buffer_full(buffer_full)
  );

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz clock (10ns period)

  initial begin
    $display("Starting simulation...");
    $monitor("Time: %0t | A: %b B: %b | Pending=(A:%b B:%b)| Timer =%d | EventValid: %b | Timestamp: %d | Empty: %b | Full: %b",
              $time, event_A, event_B, uut.pending_A, uut.pending_B, uut.timer, event_valid, timestamp_out, buffer_empty, buffer_full);
  
    

// main sequence test
// Reset the system

    reset = 1;
    #20;
    reset = 0;
    #10;

    // Simulate a muon event: A then B within coincidence window
    // test case 1 A->B coincidence (30ns gap)
    event_A = 1; #10 event_A = 0;     
    #30;                              // 30 ns delay
    event_B = 1; #10 event_B = 0;  // within 8 cycles = 80ns ? should trigger event
    #100;
    // test case 2 B->A coincidence (20ns gap)
    event_B = 1; #10 event_B = 0;
    #20;
    event_A = 1; #10 event_A = 0;
    #100;

    // too much delay
    event_A = 1; #10 event_A = 0;
    #100;
    event_B = 1; #10 event_B = 0;  // should NOT trigger event
    #100;
    // Fill FIFO to test full condition
    repeat (15) begin
      event_A = 1; #10 event_A = 0;
      #15 event_B = 1; #10 event_B = 0;      
      #50;
    end
    event_A =1; event_B = 1; #10;
    event_A =0; event_B = 0;
    #100;
 
    // Done
    #1000;
    $finish;
  end

endmodule

