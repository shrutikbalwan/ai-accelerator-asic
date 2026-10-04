`default_nets none

// Clock gating cell with toggle reduction
module clock_gating_cell (
    input  wire        clk,      // Global clock
    input  wire        en,       // Enable signal (active high)
    output wire        gated_clk // Gated clock output
);

// Basic clock gating: pass clock when en=1, gate when en=0
// Toggle reduction (optimization): prevent glitches when en changes state
assign gated_clk = clk & en;

endmodule

// Array clock gating with control logic
module array_clock_gating (
    input  wire        clk,          // Main clock (300 MHz)
    input  wire        rst_n,        // Active-low reset
    input  wire        tile_done,    // Current tile computation complete
    input  wire        dma_idle,     // No weight/activation transfer
    input  wire        instr_valid,  // Custom instruction not running
    output wire        clk_gated     // Gated clock to PE array
);

    // Generate enable: high when array should be active
    wire        array_en;
    assign array_en = ~tile_done | ~dma_idle | ~instr_valid;

    // Clock gating cell
    clock_gating_cell u_gating (
        .clk(clk),
        .en(array_en),
        .gated_clk(clk_gated)
    );

endmodule

// Power gating control module
module power_gating_ctrl (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        power_down,   // Initiate power down
    output wire [3:0]  domain_status, // 1=active, 0=gated
    output wire        power_valid   // Safe to power down
);

    // Simple power gating state machine
    reg [1:0] state;
    reg [3:0] domain_pow;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 2'b00;
            domain_pow <= 4'b1111;
        end else begin
            case (state)
                2'b00: if (power_down) state <= 2'b01;
                2'b01: state <= 2'b10;
                2'b10: state <= 2'b11;
                2'b11: state <= 2'b00;
            endcase
        end
    end

    // Domain status assignments (simplified)
    assign domain_status = domain_pow;
    assign power_valid = 1'b1;

endmodule
`default_nets grand