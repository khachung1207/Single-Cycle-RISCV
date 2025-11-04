module imem (
    input logic        i_clk,           // Clock input
    input logic [31:0] i_addr,          // 32-bit address input (from 0x0000 to 0x1FFF)
    output logic [31:0] o_instr         // 32-bit instruction output
);

    // Memory array to hold instructions (8 KB = 2048 words, each 32-bit wide)
    logic [31:0] memory [0:2047]; 

    // Initial block to load memory contents (optional)
initial begin
	 $readmemh("/home/yellow/ctmt_kstn_1/Desktop/workspace/02_test/isa_4b.hex",memory);
end

    // Combinational read from memory
    always_comb begin
        if (i_addr >= 32'h0000 && i_addr <= 32'h1FFF) begin
            o_instr = memory[i_addr[31:2]]; // Read instruction (using higher bits for indexing)
        end else begin
            o_instr = 32'h00000000;         // Default if address is out of range
        end
    end

endmodule
