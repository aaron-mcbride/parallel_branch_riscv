`include "common.sv"

`ifndef __HZD_UNIT_SV__
`define __HZD_UNIT_SV__

module hzd_unit (
  input bool_t en,
  input core::id_rd_t id_rd,
  input core::rd_ex_t rd_ex
  input core::ex_mem_t ex_mem,
  input core::mem_asm_t mem_asm,
  input core::asm_wb_t asm_wb,
  output core::reg_byp_t reg_byp
  output bool_t rs1_use_flag,
  output bool_t rs2_use_flag,
  output bool_t ex_stall_flag
);

  // Use flag logic - set when register is used in pipeline
  always @(*) begin
    if (en) begin
      rs1_use_flag = false;
      if (id_rd.valid && id_rd.has_rs1) begin
        if ((rd_ex.valid && rd_ex.has_rd) && 
            (rd_ex.de_inst.rs1 == rd_ex.de_inst.rd)) begin
          rs1_use_flag = true;
        end else if ((ex_mem.valid && ex_mem.has_rd) && 
            (ex_mem.de_inst.rs1 == ex_mem.de_inst.rd)) begin
          rs1_use_flag = true;
        end else if ((mem_asm.valid && mem_asm.has_rd) && 
            (mem_asm.de_inst.rs1 == mem_asm.de_inst.rd)) begin
          rs1_use_flag = true;
        end else if ((asm_wb.valid && asm_wb.has_rd) && 
            (asm_wb.de_inst.rs1 == asm_wb.de_inst.rd)) begin
          rs1_use_flag = true;
        end
      end
      rs2_use_flag = false;
      if (id_rd.valid && id_rd.has_rs2) begin
        if ((rd_ex.valid && rd_ex.has_rd) && 
            (rd_ex.de_inst.rs2 == rd_ex.de_inst.rd)) begin
          rs2_use_flag = true;
        end else if ((ex_mem.valid && ex_mem.has_rd) && 
            (ex_mem.de_inst.rs2 == ex_mem.de_inst.rd)) begin
          rs2_use_flag = true;
        end else if ((mem_asm.valid && mem_asm.has_rd) && 
            (mem_asm.de_inst.rs2 == mem_asm.de_inst.rd)) begin
          rs2_use_flag = true;
        end else if ((asm_wb.valid && asm_wb.has_rd) && 
            (asm_wb.de_inst.rs2 == asm_wb.de_inst.rd)) begin
          rs2_use_flag = true;
        end
      end
    end
  end

  // Bypass and stall logic
  always @(*) begin
    reg_byp.byp_rs1_value = '0;
    reg_byp.byp_rs1_valid = false;
    ex_stall_flag = false;
    if (en) begin
      if (rd_ex.valid && rd_ex.de_inst.has_rs1) begin
        if (ex_mem.valid && 
            ex_mem.de_inst.rd == rd_ex.de_inst.rs1) begin
          if (ex_mem.rd_rdy) begin
            reg_byp.byp_rs1_value = ex_mem.ex_result;
            reg_byp.byp_rs1_valid = true;
          end else begin
            ex_stall_flag = true;
          end
        end else if (mem_asm.valid && 
            mem_asm.de_inst.rd == rd_ex.de_inst.rs1) begin
          if (mem_asm.rd_rdy) begin
            reg_byp.byp_rs1_value = mem_asm.ex_result;
            reg_byp.byp_rs1_valid = true;
          end else begin
            ex_stall_flag = true;
          end
        end else if (asm_wb.valid && asm_wb.de_inst.has_rd && 
            asm_wb.de_inst.rd == rd_ex.de_inst.rs1) begin
          reg_byp.byp_rs1_value = asm_wb.asm_result;
          reg_byp.byp_rs1_valid = true;
        end
      end
      reg_byp.byp_rs2_value = '0;
      reg_byp.byp_rs2_valid = false;
      if (rd_ex.valid && rd_ex.de_inst.has_rs2) begin
        if (ex_mem.valid && 
            ex_mem.de_inst.rd == rd_ex.de_inst.rs2) begin
          if (ex_mem.rd_rdy) begin
            reg_byp.byp_rs2_value = ex_mem.ex_result;
            reg_byp.byp_rs2_valid = true;
          end else begin
            ex_stall_flag = true;
          end
        end else if (mem_asm.valid && 
            mem_asm.de_inst.rd == rd_ex.de_inst.rs2) begin
          if (mem_asm.rd_rdy) begin
            reg_byp.byp_rs2_value = mem_asm.ex_result;
            reg_byp.byp_rs2_valid = true;
          end else begin
            ex_stall_flag = true;
          end
        end else if (asm_wb.valid && asm_wb.de_inst.has_rd &&
            (asm_wb.de_inst.rd == rd_ex.de_inst.rs2)) begin
          reg_byp.byp_rs2_value = asm_wb.asm_result;
          reg_byp.byp_rs2_valid = true;
        end
      end
    end
  end

endmodule

`endif // __HZD_UNIT_SV__