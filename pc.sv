module pc  
#(
    parameter N = 32                       // 32-bit program counter
)(
    input logic i_clk,                     // Clock signal
    input logic i_rst,                     // Reset signal
    input logic en_pc,                     // high active
    input logic [N-1:0] i_mux_before_pc,   // Input for the next PC value
    output logic [N-1:0] o_pc               // Output for the current PC value
);
     logic [N-1:0] pc_next;
	  assign pc_next = (en_pc) ? i_mux_before_pc : o_pc;
    // Sequential logic for updating the PC
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (!i_rst)                          // Check for active-high reset
           o_pc <= 32'b0;                   // Reset PC to 0 on reset
        else 
           o_pc <= pc_next;         // Update PC if enable is high
    end

endmodule
