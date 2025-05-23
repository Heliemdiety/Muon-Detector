module muon_detector (
    input wire clk,
    input wire reset,
    input wire event_A,
    input wire event_B,
    output reg [63:0] timestamp_out,
    output reg event_valid,
    output reg buffer_empty,
    output reg buffer_full
);

reg [63:0] counter;
reg [63:0] fifo [0:15];  // Simple 16-depth FIFO
reg [3:0] write_ptr = 0, read_ptr = 0;

reg event_A_d, event_B_d;
reg [7:0] coincidence_window = 8;  // Max cycles allowed between A and B
reg [7:0] timer = 0;
reg pending_A = 0, pending_B = 0;    // flags that sensor has been hit

// Free-running timestamp counter
always @(posedge clk or posedge reset) begin
    if (reset)
        counter <= 0;
    else
        counter <= counter + 1;
end

// Delayed inputs
always @(posedge clk) begin
    event_A_d <= event_A;
    event_B_d <= event_B;
end

// Coincidence detection and buffering
always @(posedge clk or posedge reset) begin
    if (reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        buffer_empty <= 1;
        buffer_full <= 0;
        event_valid <= 0;
        pending_A <= 0;
        pending_B <= 0;
        timer <= 0;
    end else begin
        event_valid <= 0;   // default case

        // Rising edge detection
        if (~event_A_d & event_A) begin
            pending_A <= 1;
            timer <= 0;
        end
        if (~event_B_d & event_B) begin
            pending_B <= 1;
            timer <= 0;
        end
        // timeout for pending flags
        if(pending_A && !pending_B && timer >= coincidence_window)

            pending_A <= 0;
        if(pending_B && !pending_A && timer >= coincidence_window)
            pending_B <=0;
        
        // Timer logic - will only count when both signals are pending
        if (pending_A && pending_B)
            timer <= timer + 1;
        else 
            timer <=0;

        // Check for coincidence
        if (pending_A && pending_B && timer < coincidence_window) begin
            fifo[write_ptr] <= counter;
            timestamp_out <= counter;
            write_ptr <= write_ptr + 1;
            event_valid <= 1;
            pending_A <= 0;
            pending_B <= 0;
            timer <=0;
        end

        // FIFO status flags
        buffer_empty <= (write_ptr == read_ptr);
        buffer_full  <= ((write_ptr + 1) % 16 == read_ptr);
    end
end

endmodule
