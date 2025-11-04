module single_cycle (
               
		input logic i_clk,
		input logic i_reset,
		
		input logic [31:0] i_io_sw,
		///output
		output logic [31:0]   o_pc_debug ,
		output logic  [1-1:0]   o_insn_vld,
		///led
		output logic [31:0] o_io_ledr,
		output logic [31:0] o_io_ledg,
		///lcd
		output logic [31:0] o_io_lcd,
		///hex
		output logic [6:0] o_io_hex0,
		output logic [6:0] o_io_hex1,
		output logic [6:0] o_io_hex2,
		output logic [6:0] o_io_hex3,
		output logic [6:0] o_io_hex4,
		output logic [6:0] o_io_hex5,
		output logic [6:0] o_io_hex6,
		output logic [6:0] o_io_hex7,
		///SRAM
	  /*output logic [17:0]   SRAM_ADDR,
	  inout  wire [15:0]    SRAM_DQ  ,
	  output logic          SRAM_CE_N,
	  output logic          SRAM_WE_N,
	  output logic          SRAM_LB_N,
	  output logic          SRAM_UB_N,
	  output  logic         SRAM_OE_N,*/
	  output logic [31:0] alu_data_check, wb_data_check,
	  output logic pc_t
	  
);
   logic [31:0] alu_data, pc_next ,  pc, pc_four , instr , wb_data , rs1_data , rs2_data , imm_gen , operand_a, operand_b ,ld_data;
	
	logic [3-1:0] imm_sel;
	
	logic pc_sel , rd_wren , br_un , br_less , br_equal , opa_sel , opb_sel,mem_wren ,insn_vld,mem_read;
	
	logic [4-1:0]  alu_op;
	
	logic [2-1:0] wb_sel;
	
	//logic in_sram;
	
	/*logic o_ACK_temp;*/// sửa chỗ này
	
	/*logic en_pc;*/ ///sửa chỗ này
	
	logic [2:0] num_byte_temp;
	
   
	
	
	
	/*clk_div clk0 (
	.Clk_in(CLOCK_50),
	.Clk_out(i_clk)
	);*/
	
	mux_before_PC pc3(.PC_plus_four_i(pc_four) , 
	              .alu_i(alu_data) , 
					  .sel(pc_sel) , 
					  .mux_before_PC_o(pc_next) );
	
	
	pc pc2( .i_clk(i_clk), 
	    .i_rst(i_reset) , 
		 .i_mux_before_pc(pc_next) ,
		 .en_pc(1'b1),
		 .o_pc(pc) );
		 
	pc_plus_four pc1( .i_pc(pc ) , 
	              .o_pc_plus_four(pc_four) );
					  
	pc_debug pc0( .pc( pc ) , 
	          .i_clk(i_clk), 
				 .o_pc_debug(o_pc_debug));
				 
	imem imem0( .i_clk(i_clk) , 
	      .i_addr(pc) , 
			.o_instr(instr ) );
	
	regfile regfile0(.i_clk(i_clk ), 
	         .i_rst(i_reset),
	         .i_rd_wren(rd_wren) ,
				.i_rd_addr(instr[11:7 ]) , 
				.i_rs1_addr(instr[19:15 ]) , 
				.i_rs2_addr(instr[24:20 ]) ,
				.i_rd_data(wb_data) ,
				.o_rs1_data(rs1_data), 
				.o_rs2_data(rs2_data)
			
				);
				
	imm_gen imm0( .i_inst(instr) , 
	         .imm_sel(imm_sel),
	         .o_imm(imm_gen )
				
				);
				
	brc brc0( .i_rs1_data(rs1_data), 
	     .i_rs2_data(rs2_data) , 
		  .i_br_un(br_un) , 
		  .o_br_less(br_less) , 
		  .o_br_equal(br_equal) );
		  
		  mux_op_a opa( .pc(pc),
		            .o_rs1_data(rs1_data),
						.opa_sel(opa_sel),
						.op_a(operand_a)
					
						);
		  mux_op_b opb (
                   .imm(imm_gen),
						 .o_rs2_data(rs2_data),
                   .opb_sel(opb_sel),
                   .op_b(operand_b)
						
                  );
		  alu alu0(
		       .i_alu_op(alu_op),
				 .i_operand_a(operand_a),
				 .i_operand_b(operand_b),
				 .o_alu_data(alu_data)
				 
		  
		  );
		  
		  lsu lsu0(
		        .i_clk(i_clk),                // Global clock
				  .i_reset(i_reset),             // Global active low reset
              .i_lsu_addr(alu_data),    // Address for data read/write
              .i_st_data(rs2_data),     // Data to be stored
              .i_lsu_wren(mem_wren),           // Write enable signal
				  
              .o_ld_data(ld_data),    // Data read from memory
				  
				  /*.o_ACK(o_ACK_temp),*/ //sửa chỗ này
				  .i_io_sw(i_io_sw),
				  
				  .o_io_ledg(o_io_ledg),
				  .o_io_ledr(o_io_ledr),
				  .o_io_lcd(o_io_lcd),
				  .o_io_hex0(o_io_hex0),
				  .o_io_hex1(o_io_hex1),
				  .o_io_hex2(o_io_hex2),
				  .o_io_hex3(o_io_hex3),
				  .o_io_hex4(o_io_hex4),
				  .o_io_hex5(o_io_hex5),
				  .o_io_hex6(o_io_hex6),
				  .o_io_hex7(o_io_hex7),				
				   /*.SRAM_ADDR(SRAM_ADDR),
					.SRAM_DQ(SRAM_DQ),
					.SRAM_CE_N(SRAM_CE_N),
					.SRAM_LB_N(SRAM_LB_N),
					.SRAM_UB_N(SRAM_UB_N),
					.SRAM_WE_N(SRAM_WE_N),
					.SRAM_OE_N(SRAM_OE_N),*/
					.num_byte(num_byte_temp)
		  );
		  
		  mux_wb mux0(
		          .pc_four(pc_four),
					 .o_alu_data(alu_data),
					 .o_ld_data(ld_data),  // Đầu vào 32-bit
                .wb_sel(wb_sel),                          // Tín hiệu chọn 2-bit
                .wb_data(wb_data)                       // Đầu ra 32-bit
					);
					
		 control_unit ctrl(
		                .inst(instr),
                      .br_less(br_less),
							 .br_eqal(br_equal),
                      .pc_sel(pc_sel),
							 .rd_wren(rd_wren),
							 .insn_vld(insn_vld),
							 .br_un(br_un),
							 .opa_sel(opa_sel),
							 .opb_sel(opb_sel),
							 .mem_wren(mem_wren),
							 
                      .alu_op(alu_op),
                      .wb_sel(wb_sel),
                      .imm_sel(imm_sel),
							 
							 /*.en_pc(en_pc),*/ //sửa chỗ này
							 /*.o_ACK(o_ACK_temp),*/ // sửa chỗ này
							 .num_byte(num_byte_temp)
		              );
		 
		 insn_vld checkisn(
		             .i_insn_vld(insn_vld),         
                   .i_clk(i_clk),             
                   .o_insn_vld(o_insn_vld) 
		          );
assign alu_data_check = alu_data;
assign wb_data_check = wb_data;
assign pc_t = pc;
endmodule