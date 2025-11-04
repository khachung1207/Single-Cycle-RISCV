module pc_debug (
    input logic [31:0] pc,         // 32-bit input named pc
    input logic i_clk,             // 1-bit clock input
    output logic [31:0] o_pc_debug // 32-bit output named o_pc_debug
);

    always_ff @(posedge i_clk) begin
        o_pc_debug <= pc;         // Assign pc to o_pc_debug on the rising edge of the clock
    end

endmodule
