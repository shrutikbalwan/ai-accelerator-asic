`default_nets none

// Accelerator Control Unit
module accelerator_ctrl (
    input  wire        clk,        // Main clock
    input  wire        rst_n,      // Active-low reset
    input  wire        start,      // Start computation
    output wire        done,       // Done signal from array
    input  wire        [31:0]  weight_addr,  // Weight buffer start address
    input  wire        [31:0]  act_addr,     // Activation buffer start address
    input  wire        [31:0]  out_addr,     // Output buffer start address
    input  wire        [15:0]  height,      // Input feature map height
    input  wire        [15:0]  width,       // Input feature map width
    input  wire        [15:0]  kernel_size, // Convolution kernel size
    input  wire        [15:0]  channels,    // Input/output channels
    input  wire        [1:0]   mode,        // Operation mode
    output wire        [31:0]  result,      // Computation result
    output wire                interrupt,   // Computation complete interrupt
    output wire                busy         // Accelerator busy flag
);

    // Internal signals
    reg [1:0]  state;
    reg        computation_busy;
    reg        computation_done;
    reg [31:0] computation_result;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 2'b00;
            computation_busy <= 1'b0;
            computation_done <= 1'b0;
        end else begin
            case (state)
                2'b00: begin // IDLE
                    if (start) begin
                        state <= 2'b01;
                        computation_busy <= 1'b1;
                        computation_done <= 1'b0;
                    end
                end
                2'b01: begin // COMPUTING
                    // In real design, would wait for PE array done signal
                    // Here we simulate computation
                    if (computation_done_nxt) begin
                        state <= 2'b10;
                        computation_busy <= 1'b0;
                    end
                end
                2'b10: begin // DONE
                    computation_done <= 1'b1;
                    state <= 2'b00;
                end
                default: state <= 2'b00;
            endcase
        end
    end
    
    // Next state logic (simplified)
    // computation_done is set in DONE state and cleared when returning to IDLE
    wire computation_done_nxt;
    assign computation_done_nxt = (state == 2'b10) || (state == 2'b00 && computation_done);
    
    // Output assignments
    assign done = computation_done;
    assign busy = computation_busy;
    assign result = computation_result;
    assign interrupt = done;
    
endmodule
`default_nets grand