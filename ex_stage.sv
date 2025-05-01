`include "common.sv"

`ifndef __EX_STAGE_SV__
`define __EX_STAGE_SV__

// Execute stage module
module ex_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input bool next_rdy,
  input core::reg_byp_t reg_byp,
  input core::rd_ex_t rd_ex,
  output core::ex_mem_t ex_mem,
  output bool rdy
);

  // Ready flag logic
  assign rdy = en && next_rdy;

  // RS1 value selection logic (bypassing)
  rv32i::reg_t rs1_sel_value;
  assign rs1_sel_value = reg_byp.byp_rs1_valid ? 
      reg_byp.byp_rs1_value : rd_ex.rs1_value;

  // RS2 value selection logic (bypassing)
  rv32i::reg_t rs2_sel_value;
  assign rs2_sel_value = reg_byp.byp_rs2_valid ? 
      reg_byp.byp_rs2_value : rd_ex.rs2_value;

  // Primary instruction arithmetic execution logic
  bool next_rd_rdy;
  rv32i::reg_t next_ex_result;
  always @(*) begin
    next_ex_result <= '0;
    next_rd_rdy    <= false;
    if (rd_ex.valid) begin
      case (rd_ex.de_inst.opcode)
        rv32i::opcode_op: begin
          next_rd_rdy <= true;
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_op_sll: begin
              next_ex_result = rs1_sel_value << rs2_sel_value[4:0];
            end
            rv32i::funct3_op_slt: begin
              next_ex_result = $signed(rs1_sel_value) < $signed(rs2_sel_value);
            end
            rv32i::funct3_op_sltu: begin
              next_ex_result = rs1_sel_value < rs2_sel_value;
            end
            rv32i::funct3_op_xor: begin
              next_ex_result = rs1_sel_value ^ rs2_sel_value;
            end
            rv32i::funct3_op_or: begin
              next_ex_result = rs1_sel_value | rs2_sel_value;
            end
            rv32i::funct3_op_and: begin
              next_ex_result = rs1_sel_value & rs2_sel_value;
            end
            rv32i::funct3_op_add_sub: begin
              if (rd_ex.de_inst.funct7 == rv32i::funct7_op_add) begin
                next_ex_result = rs1_sel_value + rs2_sel_value;
              end else if (rd_ex.de_inst.funct7 == rv32i::funct7_op_sub) begin
                next_ex_result = rs1_sel_value - rs2_sel_value;
              end
            end
            rv32i::funct3_op_srl_sra: begin
              if (rd_ex.de_inst.funct7 == rv32i::funct7_op_srl) begin
                next_ex_result = rs1_sel_value >> rs2_sel_value[4:0];
              end else if (rd_ex.de_inst.funct7 == rv32i::funct7_op_sra) begin
                next_ex_result = rs1_sel_value >>> rs2_sel_value[4:0];
              end
            end
          endcase
        end
        rv32i::opcode_imm_op: begin
          next_rd_rdy <= true;
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_imm_op_xori: begin
              next_ex_result = rs1_sel_value ^ rd_ex.de_inst.imm;
            end
            rv32i::funct3_imm_op_ori: begin
              next_ex_result = rs1_sel_value | rd_ex.de_inst.imm;
            end
            rv32i::funct3_imm_op_andi: begin
              next_ex_result = rs1_sel_value & rd_ex.de_inst.imm;
            end
            rv32i::funct3_imm_op_slti: begin
              next_ex_result = $signed(rs1_sel_value) < $signed(rd_ex.de_inst.imm);
            end
            rv32i::funct3_imm_op_sltiu: begin
              next_ex_result = rs1_sel_value < rd_ex.de_inst.imm;
            end
            rv32i::funct3_imm_op_slli: begin
              next_ex_result = rs1_sel_value << rd_ex.de_inst.imm[4:0];
            end
            rv32i::funct3_imm_op_addi: begin
              next_ex_result = rs1_sel_value + rd_ex.de_inst.imm;
            end
            rv32i::funct3_imm_op_srai_srli: begin
              if (rd_ex.de_inst.funct7 == rv32i::funct7_imm_op_srai) begin
                next_ex_result = rs1_sel_value >>> rd_ex.de_inst.imm[4:0];
              end else if (rd_ex.de_inst.funct7 == rv32i::funct7_imm_op_srli) begin
                next_ex_result = rs1_sel_value >> rd_ex.de_inst.imm[4:0];
              end
            end
          endcase
        end
        rv32i::opcode_branch: begin
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_branch_beq: begin
              next_ex_result = rs1_sel_value == rs2_sel_value;
            end
            rv32i::funct3_branch_bne: begin
              next_ex_result = rs1_sel_value != rs2_sel_value;
            end
            rv32i::funct3_branch_blt: begin
              next_ex_result = $signed(rs1_sel_value) < $signed(rs2_sel_value);
            end
            rv32i::funct3_branch_bge: begin
              next_ex_result = $signed(rs1_sel_value) >= $signed(rs2_sel_value);
            end
            rv32i::funct3_branch_bltu: begin
              next_ex_result = rs1_sel_value < rs2_sel_value;
            end
            rv32i::funct3_branch_bgeu: begin
              next_ex_result = rs1_sel_value >= rs2_sel_value;
            end
          endcase
        end
        rv32i::opcode_lui: begin
          next_rd_rdy <= true;
          next_ex_result = rd_ex.de_inst.imm;
        end
        rv32i::opcode_auipc: begin
          next_rd_rdy <= true;
          next_ex_result = rd_ex.pc + rd_ex.de_inst.imm;
        end
        rv32i::opcode_store: begin
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_store_sb: begin
              next_ex_result = util::v2f(rs2_sel_value, byte_width, 
                  util::addr_off(next_ex_addr) * byte_width);
            end
            rv32i::funct3_store_sh: begin
              next_ex_result = util::v2f(rs2_sel_value, half_width, 
                  util::addr_off(next_ex_addr) * byte_width);
            end
            rv32i::funct3_store_sw: begin
              next_ex_result = rs2_sel_value;
            end
          endcase
        end
        rv32i::opcode_jal, rv32i::opcode_jalr: begin
          next_ex_result = rd_ex.pc + 4;
        end
      endcase
    end
  end

  sys::addr_t next_ex_addr;
  always @(*) begin
    next_ex_addr = '0;
    if (rd_ex.valid) begin
      case (rd_ex.de_inst.opcode)
        rv32i::opcode_load, rv32i::opcode_store: begin
          next_ex_addr = (rs1_sel_value + rd_ex.de_inst.imm);
        end
        rv32i::opcode_jalr: begin
          next_ex_addr = (rs1_sel_value + rd_ex.de_inst.imm) & ~sys::addr_t'(1);
        end
        rv32i::opcode_jal: begin
          next_ex_addr = (rd_ex.pc + rd_ex.de_inst.imm) & ~sys::addr_t'(1);
        end
        rv32i::opcode_branch: begin
          if (next_ex_result) begin
            next_ex_addr = rd_ex.pc + rd_ex.de_inst.imm;
          end else begin
            next_ex_addr = rd_ex.pc + 4;
          end
        end
      endcase
    end
  end

  sys::mem_req_mask_t next_ex_mask;
  always @(*) begin
    next_ex_mask = '0;
    if (rd_ex.valid) begin
      case (rd_ex.de_inst.opcode)
        rv32i::opcode_load: begin
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_load_lb, rv32i::funct3_load_lbu: begin
              next_ex_mask = sys::mem_req_byte_mask << util::addr_off(next_ex_addr);
            end
            rv32i::funct3_load_lh, rv32i::funct3_load_lhu: begin
              next_ex_mask = sys::mem_req_half_mask << util::addr_off(next_ex_addr);
            end
            rv32i::funct3_load_lw: begin
              next_ex_mask = sys::mem_req_word_mask;
            end
          endcase
        end
        rv32i::opcode_store: begin
          case (rd_ex.de_inst.funct3)
            rv32i::funct3_store_sb: begin
              next_ex_mask = sys::mem_req_byte_mask << util::addr_off(next_ex_addr);
            end
            rv32i::funct3_store_sh: begin
              next_ex_mask = sys::mem_req_half_mask << util::addr_off(next_ex_addr);
            end
            rv32i::funct3_store_sw: begin
              next_ex_mask = sys::mem_req_word_mask;
            end
          endcase
        end
      endcase
    end
  end

  // Pipeline register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      ex_mem <= core::ex_mem_rst;
    end else if (next_rdy) begin
      ex_mem.inst      <= rd_ex.inst;
      ex_mem.pc        <= rd_ex.pc;
      ex_mem.de_inst   <= rd_ex.de_inst;
      ex_mem.rs1_value <= rs1_sel_value;
      ex_mem.rs2_value <= rs2_sel_value;
      ex_mem.ex_result <= next_ex_result;
      ex_mem.ex_addr   <= next_ex_addr;
      ex_mem.ex_mask   <= next_ex_mask;
      ex_mem.rd_rdy    <= next_rd_rdy;
      ex_mem.valid     <= en && rd_ex.valid;
    end
  end

endmodule

`endif // __EX_STAGE_SV__