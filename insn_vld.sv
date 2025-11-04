module insn_vld (
    input logic  i_insn_vld,         
    input logic i_clk,             
    output logic o_insn_vld // 
);

    always_ff @(posedge i_clk) begin
        o_insn_vld <= i_insn_vld;         
    end

endmodule
