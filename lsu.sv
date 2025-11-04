module lsu (
  input logic i_clk,
  input logic i_reset,
  input logic [31:0] i_lsu_addr,
  input logic [31:0] i_st_data,
  input logic i_lsu_wren,
  input logic [2:0] num_byte,
  input logic [31:0] i_io_sw,
  output logic [31:0] o_ld_data,
  output logic [31:0] o_io_ledr,
  output logic [31:0] o_io_ledg,
  output logic [6:0] o_io_hex0,
  output logic [6:0] o_io_hex1,
  output logic [6:0] o_io_hex2,
  output logic [6:0] o_io_hex3,
  output logic [6:0] o_io_hex4,
  output logic [6:0] o_io_hex5,
  output logic [6:0] o_io_hex6,
  output logic [6:0] o_io_hex7,
  output logic [31:0] o_io_lcd
);
  //Bộ nho 2KiB 
  //2Kib = 2048 bytes. 2048 (bytes)/ 4 (bytes/word) = 512 word
  logic [31:0] mem [0:511];
  //khoi tao bo nho tu file mem.dump
  initial begin
    $readmemh("02_test/dump/mem.dump", mem);
  end
  
  localparam addr_mem_base = 32'h0000_0000;
  localparam addr_mem_top = 32'h0000_07FF;
  localparam addr_sw_base = 32'h1001_0000;
  localparam addr_sw_top = 32'h1001_0FFF;
  localparam addr_lcd_base = 32'h1000_4000;
  localparam addr_lcd_top = 32'h1000_4FFF;
  localparam addr_hex0_base = 32'h1000_2000;
  localparam addr_hex0_top = 32'h1000_2FFF;
  localparam addr_hex4_base = 32'h1000_3000;
  localparam addr_hex4_top = 32'h1000_3FFF;
  localparam addr_ledg_base = 32'h1000_1000;
  localparam addr_ledg_top = 32'h1000_1FFF;
  localparam addr_ledr_base = 32'h1000_0000;
  localparam addr_ledr_top = 32'h1000_0FFF;
  
  logic [31:0] ledr_reg;
  logic [31:0] ledg_reg; 
  logic [31:0] lcd_reg;
  logic [6:0] hex0_reg; 
  logic [6:0] hex1_reg; 
  logic [6:0] hex2_reg; 
  logic [6:0] hex3_reg;
  logic [6:0] hex4_reg; 
  logic [6:0] hex5_reg; 
  logic [6:0] hex6_reg; 
  logic [6:0] hex7_reg;

  assign o_io_ledr = ledr_reg & 32'h0001FFFF;
  assign o_io_ledg = ledg_reg & 32'h000000FF;
  assign o_io_lcd  = lcd_reg;
  assign o_io_hex0 = hex0_reg;
  assign o_io_hex1 = hex1_reg;
  assign o_io_hex2 = hex2_reg;
  assign o_io_hex3 = hex3_reg;
  assign o_io_hex4 = hex4_reg;
  assign o_io_hex5 = hex5_reg;
  assign o_io_hex6 = hex6_reg;
  assign o_io_hex7 = hex7_reg;
  
  logic mem_access;
  logic sw_access;
  logic lcd_access;
  logic hex0_access;
  logic hex4_access;
  logic ledg_access;
  logic ledr_access;
  
  assign mem_access = (i_lsu_addr>=addr_mem_base&&i_lsu_addr<=addr_mem_top); 
  assign sw_access = (i_lsu_addr>=addr_sw_base&&i_lsu_addr<=addr_sw_top);
  assign lcd_access = (i_lsu_addr>=addr_lcd_base&&i_lsu_addr<=addr_lcd_top);
  assign hex0_access = (i_lsu_addr>=addr_hex0_base&&i_lsu_addr<=addr_hex0_top);
  assign hex4_access = (i_lsu_addr>=addr_hex4_base&&i_lsu_addr<=addr_hex4_top);
  assign ledg_access = (i_lsu_addr>=addr_ledg_base&&i_lsu_addr<=addr_ledg_top);
  assign ledr_access = (i_lsu_addr>=addr_ledr_base&&i_lsu_addr<=addr_ledr_top);
  
  logic [8:0] mem_addr_low;
  logic [8:0] mem_addr_high;
  logic [1:0] mem_offset;
  logic [31:0] mem_data_low;
  logic [31:0] mem_data_high;
  logic [63:0] combined_data;
  logic [31:0] misalgned_word;
  
  assign mem_addr_low = i_lsu_addr[10:2];
  assign mem_addr_high = mem_addr_low + 1;
  assign mem_offset = i_lsu_addr[1:0];
  
  assign mem_data_low = mem[mem_addr_low];
  assign mem_data_high = mem[mem_addr_high];
  assign combined_data = {mem_data_high, mem_data_low};
  
  //--------------------
  //Load khong dong bo
  //--------------------
  always_comb begin
    o_ld_data = 32'd0;
   
    case(mem_offset)
      2'b00: misalgned_word = combined_data[31:0];
      2'b01: misalgned_word = combined_data[39:8];
      2'b10: misalgned_word = combined_data[47:16];
      2'b11: misalgned_word = combined_data[55:24];
    endcase
    if(!i_lsu_wren) begin
      if(mem_access) begin
        case(num_byte)
          //lb
          3'd0: begin
            o_ld_data = {{24{misalgned_word[7]}},misalgned_word[7:0]};        
          end
          //lbu
          3'd1: begin
            o_ld_data = {{24{1'b0}},misalgned_word[7:0]};
          end
          //lh
          3'd2: begin
            o_ld_data = {{16{misalgned_word[15]}},misalgned_word[15:0]};
          end
          //lhu
          3'd3: begin
            o_ld_data = {{16{1'b0}},misalgned_word[15:0]};
          end
          //lw
          3'd4: begin
            o_ld_data = misalgned_word;
          end
          default: o_ld_data = misalgned_word;
        endcase
      end else if(sw_access) begin
        case(num_byte)
          //lb
          3'd0: begin
            case(mem_offset)
              2'b00: o_ld_data = {{24{i_io_sw[7]}},i_io_sw[7:0]};
              2'b01: o_ld_data = {{24{i_io_sw[15]}},i_io_sw[15:8]};
              2'b10: o_ld_data = {{24{i_io_sw[23]}},i_io_sw[23:16]};
              2'b11: o_ld_data = {{24{i_io_sw[31]}},i_io_sw[31:24]};
            endcase
          end
          //lbu
          3'd1: begin
            case(mem_offset)
              2'b00: o_ld_data = {{24{1'b0}},i_io_sw[7:0]};
              2'b01: o_ld_data = {{24{1'b0}},i_io_sw[15:8]};
              2'b10: o_ld_data = {{24{1'b0}},i_io_sw[23:16]};
              2'b11: o_ld_data = {{24{1'b0}},i_io_sw[31:24]};
            endcase
          end
          //lh
          3'd2: begin
            if(mem_offset[1] == 1'b0) begin
              o_ld_data = {{16{i_io_sw[15]}},i_io_sw[15:0]};
            end else begin
              o_ld_data = {{16{i_io_sw[31]}},i_io_sw[31:16]};
            end
          end
          //lhu
          3'd3: begin
            if(mem_offset[1] == 1'b0) begin
              o_ld_data = {{16{1'b0}},i_io_sw[15:0]};
            end else begin
              o_ld_data = {{16{1'b0}},i_io_sw[31:16]};
            end
          end
          //lw
          3'd4: begin
            o_ld_data = i_io_sw;
          end
          default: o_ld_data = i_io_sw;
        endcase
      end
    end
  end
  
  //--------------------
  //Store dong bo
  //--------------------
  
  logic [31:0] mem_data_wr_low;
  logic [31:0] mem_data_wr_high;
  logic [7:0] mem_byte_en;
  always_comb begin
    mem_data_wr_low = mem_data_low;
    mem_data_wr_high = mem_data_high;
    mem_byte_en = 8'b00000000;
    if(i_lsu_wren) begin
      case(num_byte)
        //sb
        3'd0: begin
          case(mem_offset)
            2'b00: begin
              mem_data_wr_low[7:0] = i_st_data[7:0];
              mem_byte_en = 8'b00000001;
            end
            2'b01: begin
              mem_data_wr_low[15:8] = i_st_data[7:0];
              mem_byte_en = 8'b00000010;
            end
            2'b10: begin
              mem_data_wr_low[23:16] = i_st_data[7:0];
              mem_byte_en = 8'b00000100;
            end
            2'b11: begin
              mem_data_wr_low[31:24] = i_st_data[7:0];
              mem_byte_en = 8'b00001000;
            end
          endcase
        end
        //sh
        3'd2: begin
          case(mem_offset)
            2'b00: begin
              mem_data_wr_low[15:0] = i_st_data[15:0];
              mem_byte_en = 8'b00000011;
            end
            2'b01: begin
              mem_data_wr_low[23:8] = i_st_data[15:0];
              mem_byte_en = 8'b00000110;
            end
            2'b10: begin
              mem_data_wr_low[31:16] = i_st_data[15:0];
              mem_byte_en = 8'b00001100;
            end
            2'b11: begin
              mem_data_wr_low[31:24] = i_st_data[7:0];
              mem_data_wr_high[7:0] = i_st_data[15:8];
              mem_byte_en = 8'b00011000;
            end
          endcase
        end
        //sw
        3'd4: begin
          case(mem_offset)
            2'b00: begin
              mem_data_wr_low = i_st_data;
              mem_byte_en = 8'b00001111;
            end
            2'b01: begin
              mem_data_wr_low[31:8] = i_st_data[23:0];
              mem_data_wr_high[7:0] = i_st_data[31:24];
              mem_byte_en = 8'b00011110;
            end
            2'b10: begin
              mem_data_wr_low[31:16] = i_st_data[15:0];
              mem_data_wr_high[15:0] = i_st_data[31:16];
              mem_byte_en = 8'b00111100;
            end
            2'b11:begin
              mem_data_wr_low[31:24] = i_st_data[7:0];
              mem_data_wr_high[23:0] = i_st_data[31:8];
              mem_byte_en = 8'b01111000;
            end
          endcase
        end
        default: begin
          mem_data_wr_low = mem_data_low;
          mem_data_wr_high = mem_data_high;
          mem_byte_en = 8'b00000000;
        end
      endcase
    end
  end         
  
  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      ledr_reg <= 32'h0;
      ledg_reg <= 32'h0;
      lcd_reg  <= 32'h0;
      hex0_reg <= 7'h0;
      hex1_reg <= 7'h0;
      hex2_reg <= 7'h0;
      hex3_reg <= 7'h0;
      hex4_reg <= 7'h0;
      hex5_reg <= 7'h0;
      hex6_reg <= 7'h0;
      hex7_reg <= 7'h0;
    end else begin
      if(i_lsu_wren) begin
        if(mem_access) begin
          if(mem_byte_en[0]) 
            mem[mem_addr_low][7:0] <= mem_data_wr_low[7:0];
          if(mem_byte_en[1]) 
            mem[mem_addr_low][15:8] <= mem_data_wr_low[15:8];
          if(mem_byte_en[2]) 
            mem[mem_addr_low][23:16] <= mem_data_wr_low[23:16];
          if(mem_byte_en[3])
            mem[mem_addr_low][31:24] <= mem_data_wr_low[31:24];
          if(mem_byte_en[4])
            mem[mem_addr_high][7:0] <= mem_data_wr_high[7:0];
          if(mem_byte_en[5])
            mem[mem_addr_high][15:8] <= mem_data_wr_high[15:8];
          if(mem_byte_en[6])
            mem[mem_addr_high][23:16] <= mem_data_wr_high[23:16];
          if(mem_byte_en[7])
            mem[mem_addr_high][31:24] <= mem_data_wr_high[31:24];
        end else if(ledr_access) begin
          case(num_byte)
            //sb
            3'd0: begin
              case(mem_offset)
                2'b00: ledr_reg[7:0] <= i_st_data[7:0];
                2'b01: ledr_reg[15:8] <= i_st_data[7:0];
                2'b10: ledr_reg[23:16] <= i_st_data[7:0];
                2'b11: ledr_reg[31:24] <= i_st_data[7:0];
              endcase
            end
            //sh
            3'd2: begin
              if(mem_offset[1] == 1'b0) begin
                ledr_reg[15:0] <= i_st_data[15:0];               
              end else begin
                ledr_reg[31:16] <= i_st_data[15:0];              
              end
            end
            //sw
            3'd4: begin
              ledr_reg <= i_st_data;
            end
          endcase
        end else if(ledg_access) begin
          case(num_byte)
            //sb
            3'd0: begin
              case(mem_offset)
                2'b00: ledg_reg[7:0] <= i_st_data[7:0];
                2'b01: ledg_reg[15:8] <= i_st_data[7:0];
                2'b10: ledg_reg[23:16] <= i_st_data[7:0];
                2'b11: ledg_reg[31:24] <= i_st_data[7:0];
              endcase
            end
            //sh
            3'd2: begin
              if(mem_offset[1] == 1'b0) begin
                ledg_reg[15:0] <= i_st_data[15:0];                
              end else begin
                ledg_reg[31:16] <= i_st_data[15:0];              
              end
            end
            //sw
            3'd4: begin
              ledg_reg <= i_st_data;
            end
          endcase
        end else if(lcd_access) begin
           case(num_byte)
            //sb
            3'd0: begin
              case(mem_offset)
                2'b00: lcd_reg[7:0] <= i_st_data[7:0];
                2'b01: lcd_reg[15:8] <= i_st_data[7:0];
                2'b10: lcd_reg[23:16] <= i_st_data[7:0];
                2'b11: lcd_reg[31:24] <= i_st_data[7:0];
              endcase
            end
            //sh
            3'd2: begin
              if(mem_offset[1] == 1'b0) begin
                lcd_reg[15:0] <= i_st_data[15:0];                
              end else begin
                lcd_reg[31:16] <= i_st_data[15:0];              
              end
            end
            //sw
            3'd4: begin
              lcd_reg <= i_st_data;
            end
          endcase
        end else if(hex0_access) begin
          case(num_byte)
            //sb
            3'd0: begin
              case(mem_offset)
                2'b00: hex0_reg <= i_st_data[6:0];
                2'b01: hex1_reg <= i_st_data[6:0];
                2'b10: hex2_reg <= i_st_data[6:0];
                2'b11: hex3_reg <= i_st_data[6:0];
              endcase
            end
            //sh
            3'd2: begin
              if(mem_offset[1] == 1'b0) begin
                hex0_reg <= i_st_data[6:0];
                hex1_reg <= i_st_data[14:8];
              end else begin
                hex2_reg <= i_st_data[6:0];
                hex3_reg <= i_st_data[14:8];
              end
            end
            //sw
            3'd4: begin
              hex0_reg <= i_st_data[6:0];
              hex1_reg <= i_st_data[14:8];
              hex2_reg <= i_st_data[22:16];
              hex3_reg <= i_st_data[30:24];
            end
          endcase
        end else if(hex4_access) begin
          case(num_byte)
            //sb
            3'd0: begin
              case(mem_offset)
                2'b00: hex4_reg <= i_st_data[6:0];
                2'b01: hex5_reg <= i_st_data[6:0];
                2'b10: hex6_reg <= i_st_data[6:0];
                2'b11: hex7_reg <= i_st_data[6:0];
              endcase
            end
            //sh
            3'd2: begin
              if(mem_offset[1] == 1'b0) begin
                hex4_reg <= i_st_data[6:0];
                hex5_reg <= i_st_data[14:8];
              end else begin
                hex6_reg <= i_st_data[6:0];
                hex7_reg <= i_st_data[14:8];
              end
            end
            //sw
            3'd4: begin
              hex4_reg <= i_st_data[6:0];
              hex5_reg <= i_st_data[14:8];
              hex6_reg <= i_st_data[22:16];
              hex7_reg <= i_st_data[30:24];
            end
          endcase
        end
      end
    end
  end
endmodule


