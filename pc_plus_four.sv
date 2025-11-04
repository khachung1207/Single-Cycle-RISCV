module pc_plus_four (
    input logic [31:0] i_pc,           // Input: 32-bit Program Counter (pc)
    output logic [31:0] o_pc_plus_four // Output: pc + 4
);

    always_comb begin
        o_pc_plus_four = i_pc + 32'd4; // Add 4 to the input pc value
    end

endmodule
