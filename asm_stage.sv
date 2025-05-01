`include "common.sv"

`ifndef __ASM_STAGE_SV__
`define __ASM_STAGE_SV__

// Assembly stage module
module asm_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input bool next_rdy,
  input core::mem_asm_t mem_asm,
  output core::asm_wb_t asm_wb,
  output bool rdy
);

  // Ready logic
  assign rdy = en && next_rdy;

  // Writeback value assembly logic
  rv32i::reg_t next_asm_result;
  always @(*) begin
    next_asm_result <= '0;
    if (mem_asm.valid) begin
      case (mem_asm.de_inst.opcode)
        rv32i::opcode_load: begin
          case (mem_asm.de_inst.funct3)
            rv32i::funct3_load_lbu, rv32i::funct3_load_lhu: begin
              next_asm_result = mem_asm.mem_result >> (util::addr_off(mem_asm.ex_addr) * 8);
            end
            rv32i::funct3_load_lb, rv32i::funct3_load_lh: begin
              next_asm_result = mem_asm.mem_result >> (util::addr_off(mem_asm.ex_addr) * 8);
              next_asm_result = sext(sys::word_width, sys::byte_width, next_asm_result);
            end
            rv32i::funct3_load_lw: begin
              next_asm_result = mem_asm.mem_result;
            end
          endcase
        end
        rv32i::opcode_auipc, rv32i::opcode_lui, 
        rv32i::opcode_op, rv32i::opcode_imm_op: begin
          next_asm_result = mem_asm.ex_result;
        end
      endcase
    end
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