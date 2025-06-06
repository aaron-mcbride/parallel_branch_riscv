`include "common.sv"

`ifndef __ASM_STAGE_SV__
`define __ASM_STAGE_SV__

// Assembly stage module
module asm_stage (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input bool_t next_rdy,
  input core::mem_asm_t mem_asm,
  output core::asm_wb_t asm_wb,
  output bool_t rdy
);

  assign rdy = en && next_rdy;

  rv32i::reg_t n_asm_result;
  always @(*) begin
    n_asm_result = '0;
    case (mem_asm.de_inst.opcode)
      rv32i::opcode_load: begin
        n_asm_result = mem_asm.mem_result >> 
            ((mem_asm.ex_addr % sys::word_size) * sys::byte_width);
        case (mem_asm.de_inst.funct3)
          rv32i::funct3_load_lb: begin
            n_asm_result = util::sext(n_asm_result, sys::byte_width);
          end
          rv32i::funct3_load_lh: begin
            n_asm_result = util::sext(n_asm_result, sys::half_width);
          end
        endcase
      end
      rv32i::opcode_auipc, rv32i::opcode_lui,
      rv32i::opcode_jal, rv32i::opcode_jalr: begin
        n_asm_result = mem_asm.ex_result;
      end
    endcase
  end

  // Pipeline register update logic
  always @(*) begin
    if (rst) begin
      asm_wb <= core::asm_wb_rst;
    end else if (next_rdy) begin
      asm_wb.inst       <= mem_asm.de_inst;
      asm_wb.pc         <= mem_asm.pc;
      asm_wb.rs1_value  <= mem_asm.rs1_value;
      asm_wb.rs2_value  <= mem_asm.rs2_value;
      asm_wb.asm_result <= next_asm_result;
      asm_wb.valid      <= en && mem_asm.valid;
    end
  end

endmodule

`endif // __ASM_STAGE_SV__