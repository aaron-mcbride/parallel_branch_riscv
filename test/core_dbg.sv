`include "../src/common.sv"

`ifndef __CORE_DBG_SV__
`define __CORE_DBG_SV__

import bool_type::*;

module core_dbg (
  input logic clk,
  input core::if_id_t if_id_in [core::peval_width ** 2], // IF stage registers (no mux)
  input core::id_ex_t id_ex_in [core::peval_width],      // ID stage registers (no mux)
  input core::id_ex_t id_ex_out,                         // ID stage registers (muxed)
  input core::ex_mem_t ex_mem,                           // EX stage registers
  input core::mem_wb_t mem_wb,                           // MEM stage registers
  input core::reg_fwd_t ex_reg_fwd                       // EX stage register forwarding values
);

  function automatic string reg_name(input rv32i::reg_num_t reg_num);
    case (reg_num)
      rv32i::reg_zero: return "zero";
      rv32i::reg_ra:   return "ra";
      rv32i::reg_sp:   return "sp";
      rv32i::reg_gp:   return "gp";
      rv32i::reg_tp:   return "tp";
      rv32i::reg_t0:   return "t0";
      rv32i::reg_t1:   return "t1";
      rv32i::reg_t2:   return "t2";
      rv32i::reg_s0:   return "s0";
      rv32i::reg_s1:   return "s1";
      rv32i::reg_a0:   return "a0";
      rv32i::reg_a1:   return "a1";
      rv32i::reg_a2:   return "a2";
      rv32i::reg_a3:   return "a3";
      rv32i::reg_a4:   return "a4";
      rv32i::reg_a5:   return "a5";
      rv32i::reg_a6:   return "a6";
      rv32i::reg_a7:   return "a7";
      rv32i::reg_s2:   return "s2";
      rv32i::reg_s3:   return "s3";
      rv32i::reg_s4:   return "s4";
      rv32i::reg_s5:   return "s5";
      rv32i::reg_s6:   return "s6";
      rv32i::reg_s7:   return "s7";
      rv32i::reg_s8:   return "s8";
      rv32i::reg_s9:   return "s9";
      rv32i::reg_s10:  return "s10";
      rv32i::reg_s11:  return "s11";
      rv32i::reg_t3:   return "t3";
      rv32i::reg_t4:   return "t4";
      rv32i::reg_t5:   return "t5";
      rv32i::reg_t6:   return "t6";
      default:         return "<NULL>";
    endcase
  endfunction

  function automatic string decode_inst(input rv32i::inst_t inst);
    sys::word_t tmp_value;
    case (rv32i::get_opcode(inst))
      rv32i::opcode_auipc: begin
        return $sformatf("auipc %s, 0x%0d", 
            reg_name(rv32i::get_rd_num(inst)), 
            rv32i::get_imm_u(inst));
      end
      rv32i::opcode_lui: begin
        return $sformatf("lui %s, 0x%0d", 
            reg_name(rv32i::get_rd_num(inst)), 
            rv32i::get_imm_u(inst));
      end
      rv32i::opcode_op: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_op_and: begin
            return $sformatf("and %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_or: begin
            return $sformatf("or %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_xor: begin
            return $sformatf("xor %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_sll: begin
            return $sformatf("sll %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_slt: begin
            return $sformatf("slt %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_sltu: begin
            return $sformatf("sltu %s, %s, %s", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)));
          end
          rv32i::funct3_op_add_sub: begin
            case (rv32i::get_funct7(inst))
              rv32i::funct7_op_add: begin
                return $sformatf("add %s, %s, %s", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    reg_name(rv32i::get_rs2_num(inst)));
              end
              rv32i::funct7_op_sub: begin
                return $sformatf("sub %s, %s, %s", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    reg_name(rv32i::get_rs2_num(inst)));
              end
              default: begin
                return "<NULL>";
              end
            endcase
          end
          rv32i::funct3_op_srl_sra: begin
            case (rv32i::get_funct7(inst))
              rv32i::funct7_op_srl: begin
                return $sformatf("srl %s, %s, %s", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    reg_name(rv32i::get_rs2_num(inst)));
              end
              rv32i::funct7_op_sra: begin
                return $sformatf("sra %s, %s, %s", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    reg_name(rv32i::get_rs2_num(inst)));
              end
              default: begin
                return "<NULL>";
              end
            endcase
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_imm_op: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_imm_op_addi: begin
            return $sformatf("addi %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_andi: begin
            return $sformatf("andi %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_ori: begin
            return $sformatf("ori %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_slli: begin
            tmp_value = rv32i::get_imm_i(inst);
            return $sformatf("slli %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                tmp_value[4:0]);
          end
          rv32i::funct3_imm_op_slti: begin
            return $sformatf("slti %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_sltiu: begin
            return $sformatf("sltiu %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_xori: begin
            return $sformatf("xori %s, %s, 0x%0d", 
                reg_name(rv32i::get_rd_num(inst)), 
                reg_name(rv32i::get_rs1_num(inst)), 
                rv32i::get_imm_i(inst));
          end
          rv32i::funct3_imm_op_srai_srli: begin
            case (rv32i::get_funct7(inst))
              rv32i::funct7_op_srl: begin
                tmp_value = rv32i::get_imm_i(inst);
                return $sformatf("srli %s, %s, 0x%0d", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    tmp_value[4:0]);
              end
              rv32i::funct7_op_sra: begin
                tmp_value = rv32i::get_imm_i(inst);
                return $sformatf("srai %s, %s, 0x%0d", 
                    reg_name(rv32i::get_rd_num(inst)), 
                    reg_name(rv32i::get_rs1_num(inst)), 
                    tmp_value[4:0]);
              end
              default: begin
                return "<NULL>";
              end
            endcase
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_branch: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_branch_beq: begin
            return $sformatf("beq %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          rv32i::funct3_branch_bne: begin
            return $sformatf("bne %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          rv32i::funct3_branch_blt: begin
            return $sformatf("blt %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          rv32i::funct3_branch_bge: begin
            return $sformatf("bge %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          rv32i::funct3_branch_bltu: begin
            return $sformatf("bltu %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          rv32i::funct3_branch_bgeu: begin
            return $sformatf("bgeu %s, %s, 0x%0d", 
                reg_name(rv32i::get_rs1_num(inst)), 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_b(inst));
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_load: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_load_lb: begin
            return $sformatf("lb %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rd_num(inst)), 
                rv32i::get_imm_i(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_load_lh: begin
            return $sformatf("lh %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rd_num(inst)), 
                rv32i::get_imm_i(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_load_lw: begin
            return $sformatf("lw %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rd_num(inst)), 
                rv32i::get_imm_i(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_load_lbu: begin
            return $sformatf("lbu %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rd_num(inst)), 
                rv32i::get_imm_i(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_load_lhu: begin
            return $sformatf("lhu %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rd_num(inst)), 
                rv32i::get_imm_i(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_store: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_store_sb: begin
            return $sformatf("sb %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_s(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_store_sh: begin
            return $sformatf("sh %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_s(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          rv32i::funct3_store_sw: begin
            return $sformatf("sw %s, 0x%0d(%s)", 
                reg_name(rv32i::get_rs2_num(inst)), 
                rv32i::get_imm_s(inst), 
                reg_name(rv32i::get_rs1_num(inst)));
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_jal: begin
        return $sformatf("jal %s, 0x%0d", 
            reg_name(rv32i::get_rd_num(inst)), 
            rv32i::get_imm_j(inst));
      end
      rv32i::opcode_jalr: begin
        return $sformatf("jalr %s, %s, 0x%0d", 
            reg_name(rv32i::get_rd_num(inst)), 
            reg_name(rv32i::get_rs1_num(inst)), 
            rv32i::get_imm_i(inst));
      end
      rv32i::opcode_sys: begin
        case (rv32i::get_funct3(inst))
          rv32i::funct3_sys_ecall: begin
            return "ecall";
          end
          rv32i::funct3_sys_ebreak: begin
            return "ebreak";
          end
          default: begin
            return "<NULL>";
          end
        endcase
      end
      rv32i::opcode_fence: begin
        return "fence";
      end
      default: begin
        return "<NULL>";
      end
    endcase
  endfunction

  int branch_cnt   = 0;
  int branch_hit   = 0;
  int jalr_cnt     = 0;
  int jalr_hit     = 0;
  int cur_cycle    = 0;
  int valid_wb_cnt = 0;

  always @(posedge clk) begin
    int i, j;
    int if_index;
    string ex_inst;
    bool_t targ_found;
    real real_value;
    sys::addr_t targ_pc;
    cur_cycle++;
    if (ex_mem.valid) begin
      case (ex_mem.de_inst.opcode)
        rv32i::opcode_branch: begin
          branch_cnt++;
          targ_found = false;
          for (i = 0; (i < core::peval_width) && !targ_found; i++) begin
            if (id_ex_in[i].valid) begin
              if (id_ex_in[i].pc == ex_mem.ex_addr) begin
                targ_found = true;
                branch_hit++;
              end
            end else begin
              for (j = 0; (j < core::peval_width) && !targ_found; j++) begin
                if_index = (i * core::peval_width) + j; 
                if (if_id_in[if_index].valid && if_id_in[if_index].pc == ex_mem.ex_addr) begin
                  targ_found = true;
                  branch_hit++;
                end
              end
            end
          end
        end
        rv32i::opcode_jalr: begin
          jalr_cnt++;
          targ_found = false;
          for (i = 0; (i < core::peval_width) && !targ_found; i++) begin
            if (id_ex_in[i].valid) begin
              if (id_ex_in[i].pc == ex_mem.ex_addr) begin
                targ_found = true;
                jalr_hit++;
              end
            end else begin
              for (j = 0; (j < core::peval_width) && !targ_found; j++) begin
                if_index = (i * core::peval_width) + j; 
                if (if_id_in[if_index].valid && if_id_in[if_index].pc == ex_mem.ex_addr) begin
                  targ_found = true;
                  jalr_hit++;
                end
              end
            end
          end
        end
      endcase
    end
    if (mem_wb.valid) begin
      valid_wb_cnt++;
    end
    $display("CYCLE: %0d", cur_cycle);
    $display("----------------- IF/ID -----------------");
    for (i = 0; i < (core::peval_width ** 2); i++) begin
      if (if_id_in[i].valid) begin
        $display("%0d: 0x%0h %s", i, if_id_in[i].pc, decode_inst(if_id_in[i].inst));
      end else begin
        $display("%0d: <INVALID>", i);
      end
    end
    $display("----------------- ID/EX -----------------");
    for (i = 0; i < core::peval_width; i++) begin
      if (id_ex_in[i].valid) begin
        $display("%0d 0x%0h %s", i, id_ex_in[i].pc, decode_inst(id_ex_in[i].inst));
      end else begin
        $display("%0d: <INVALID>", i);
      end
    end
    $display("----------------- EX/MEM ----------------");
    if (ex_mem.valid) begin
      $display("0x%0h %s", ex_mem.pc, decode_inst(ex_mem.inst));
      if ((ex_mem.de_inst.opcode != rv32i::opcode_store) &&
          (ex_mem.de_inst.opcode != rv32i::opcode_load)) begin
        $display("rs1: %0d", ex_reg_fwd.rs1_value);
        $display("rs2: %0d", ex_reg_fwd.rs2_value);
        $display("result: %0d", ex_mem.ex_result);
      end
    end else begin
      $display("<INVALID>");
    end
    $display("----------------- MEM/WB ----------------");
    if (mem_wb.valid) begin
      $display("0x%0h %s", mem_wb.pc, decode_inst(mem_wb.inst));
      if (mem_wb.de_inst.opcode == rv32i::opcode_load) begin
        $display("result: %0d", mem_wb.mem_result);
      end
    end else begin
      $display("<INVALID>");
    end
    $display("----------------- INFO ------------------");
    real_value = (branch_cnt > 0) ? (branch_hit / branch_cnt) : 0.0;
    $display("BRANCH hit rate: %.4f", real_value);
    real_value = (jalr_cnt > 0) ? (jalr_hit / jalr_cnt) : 0.0;
    $display("JALR hit rate: %.4f", real_value);
    real_value = (cur_cycle > 0) ? (valid_wb_cnt / cur_cycle) : 0.0;
    $display("Instructions per cycle: %.4f", real_value);
    if (id_ex_out.valid && decode_inst(id_ex_out.inst) == "<NULL>") begin
      $display("ERROR: Unknown instruction executed!");
      $stop;
    end
  end

endmodule

`endif // __CORE_DBG_SV__