module mux_before_PC  

//
#(
parameter N = 32 
)(
input logic [N -1:0] PC_plus_four_i,alu_i,
input logic  sel ,
output logic [N -1:0] mux_before_PC_o
);
always_comb begin
	case (sel)
		1'b0: mux_before_PC_o = PC_plus_four_i;
		1'b1: mux_before_PC_o = alu_i;
	endcase
end
endmodule