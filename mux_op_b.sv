module mux_op_b (
input logic [31:0] imm, o_rs2_data,
input logic opb_sel,
output logic [31:0] op_b
);
assign op_b = opb_sel ?  o_rs2_data:imm;
endmodule