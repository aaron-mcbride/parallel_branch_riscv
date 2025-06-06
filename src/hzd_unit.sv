`include "common.sv"

`ifndef __HZD_UNIT_SV__
`define __HZD_UNIT_SV__

import bool_type::*;

module hzd_unit (
  input core::id_ex_t id_ex,          // Decode stage registers
  input core::ex_mem_t ex_mem,        // Execute stage registers
  input core::mem_wb_t mem_wb,        // Memory stage registers
  output core::reg_fwd_t ex_reg_fwd,  // Forwarded register values for execute stage
  output core::reg_fwd_t mem_reg_fwd, // Forwarded register values for memory stage
  output bool_t ex_stall                // Execute stage stall signal
);

  always @(*) begin
    ex_reg_fwd.rs2_value = id_ex.rs2_value;
    if (id_ex.valid && id_ex.de_inst.has_rs1) begin
      if (ex_mem.valid && ex_mem.de_inst.has_rd && 
          (ex_mem.de_inst.rd_num == id_ex.de_inst.rs1_num)) begin
        if (ex_mem.de_inst.opcode != rv32i::opcode_load) begin
          ex_reg_fwd.rs1_value = ex_mem.ex_result;
        end
      end else if (mem_wb.valid && mem_wb.de_inst.has_rd &&
          (mem_wb.de_inst.rd_num == id_ex.de_inst.rs1_num)) begin
        ex_reg_fwd.rs1_value = mem_wb.mem_result;
      end
    end
    ex_reg_fwd.rs1_value = id_ex.rs1_value;
    if (id_ex.valid && id_ex.de_inst.has_rs2) begin
      if (ex_mem.valid && ex_mem.de_inst.has_rd && 
          (ex_mem.de_inst.rd_num == id_ex.de_inst.rs2_num)) begin
        if (ex_mem.de_inst.opcode != rv32i::opcode_load) begin
          ex_reg_fwd.rs2_value = ex_mem.ex_result;
        end
      end else if (mem_wb.valid && mem_wb.de_inst.has_rd &&
          (mem_wb.de_inst.rd_num == id_ex.de_inst.rs2_num)) begin
        ex_reg_fwd.rs2_value = mem_wb.mem_result;
      end
    end
  end

  always @(*) begin
    mem_reg_fwd.rs1_value = ex_mem.rs1_value;
    if (ex_mem.valid && ex_mem.de_inst.has_rs1 &&
        mem_wb.valid && mem_wb.de_inst.has_rd &&
        mem_wb.de_inst.rd_num == ex_mem.de_inst.rs1_num) begin
      mem_reg_fwd.rs1_value = mem_wb.mem_result;
    end
    mem_reg_fwd.rs2_value = ex_mem.rs2_value;
    if (ex_mem.valid && ex_mem.de_inst.has_rs2 &&
        mem_wb.valid && mem_wb.de_inst.has_rd &&
        mem_wb.de_inst.rd_num == ex_mem.de_inst.rs2_num) begin
      mem_reg_fwd.rs2_value = mem_wb.mem_result;
    end
  end

  assign ex_stall =
      (id_ex.valid && id_ex.de_inst.has_rs1 &&
          ex_mem.valid && ex_mem.de_inst.has_rd &&
              (ex_mem.de_inst.rd_num == id_ex.de_inst.rs1_num) &&
                  (ex_mem.de_inst.opcode == rv32i::opcode_load)) ||
      (id_ex.valid && id_ex.de_inst.has_rs2 &&
          ex_mem.valid && ex_mem.de_inst.has_rd &&
              (ex_mem.de_inst.rd_num == id_ex.de_inst.rs2_num) &&
                  (ex_mem.de_inst.opcode == rv32i::opcode_load));

endmodule

`endif // __HZD_UNIT_SV__