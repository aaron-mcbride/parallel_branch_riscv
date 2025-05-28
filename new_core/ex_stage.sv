`include "common.sv"

`ifndef __EX_STAGE_SV__
`define __EX_STAGE_SV__

// Execute stage module
module ex_stage (
  input logic clk,               // Clock signal
  input bool rst,                // Reset signal
  input bool en,                 // Enable signal
  input bool next_rdy,           // Next stage ready signal
  input core::reg_fwd_t reg_fwd, // Forwarded register values
  input core::id_ex_t id_ex,     // Stage input registers
  output core::ex_mem_t ex_mem,  // Stage output registers
  output bool rdy                // Stage ready signal
);

  assign rdy = en && next_rdy;

  rv32i::reg_t n_ex_result;
  always @(*) begin
    n_ex_result = '0;
    case (id_ex.de_inst.opcode)
      rv32i::opcode_op: begin
        case (id_ex.de_inst.funct3)
          rv32i::funct3_op_sll: begin
            n_ex_result = reg_fwd.rs1_value << reg_fwd.rs2_value[4:0];
          end
          rv32i::funct3_op_slt: begin
            n_ex_result = $signed(reg_fwd.rs1_value) < $signed(reg_fwd.rs2_value);
          end
          rv32i::funct3_op_sltu: begin
            n_ex_result = reg_fwd.rs1_value < reg_fwd.rs2_value;
          end
          rv32i::funct3_op_xor: begin
            n_ex_result = reg_fwd.rs1_value ^ reg_fwd.rs2_value;
          end
          rv32i::funct3_op_or: begin
            n_ex_result = reg_fwd.rs1_value | reg_fwd.rs2_value;
          end
          rv32i::funct3_op_and: begin
            n_ex_result = reg_fwd.rs1_value & reg_fwd.rs2_value;
          end
          rv32i::funct3_op_add_sub: begin
            if (id_ex.de_inst.funct7 == rv32i::funct7_op_add) begin
              n_ex_result = reg_fwd.rs1_value + reg_fwd.rs2_value;
            end else if (id_ex.de_inst.funct7 == rv32i::funct7_op_sub) begin
              n_ex_result = reg_fwd.rs1_value - reg_fwd.rs2_value;
            end
          end
          rv32i::funct3_op_srl_sra: begin
            if (id_ex.de_inst.funct7 == rv32i::funct7_op_srl) begin
              n_ex_result = reg_fwd.rs1_value >> reg_fwd.rs2_value[4:0];
            end else if (id_ex.de_inst.funct7 == rv32i::funct7_op_sra) begin
              n_ex_result = reg_fwd.rs1_value >>> reg_fwd.rs2_value[4:0];
            end
          end
        endcase
      end
      rv32i::opcode_imm_op: begin
        case (id_ex.de_inst.funct3)
          rv32i::funct3_imm_op_xori: begin
            n_ex_result = reg_fwd.rs1_value ^ id_ex.de_inst.imm;
          end
          rv32i::funct3_imm_op_ori: begin
            n_ex_result = reg_fwd.rs1_value | id_ex.de_inst.imm;
          end
          rv32i::funct3_imm_op_andi: begin
            n_ex_result = reg_fwd.rs1_value & id_ex.de_inst.imm;
          end
          rv32i::funct3_imm_op_slti: begin
            n_ex_result = $signed(reg_fwd.rs1_value) < $signed(id_ex.de_inst.imm);
          end
          rv32i::funct3_imm_op_sltiu: begin
            n_ex_result = reg_fwd.rs1_value < id_ex.de_inst.imm;
          end
          rv32i::funct3_imm_op_slli: begin
            n_ex_result = reg_fwd.rs1_value << id_ex.de_inst.imm[4:0];
          end
          rv32i::funct3_imm_op_addi: begin
            n_ex_result = reg_fwd.rs1_value + id_ex.de_inst.imm;
          end
          rv32i::funct3_imm_op_srai_srli: begin
            if (id_ex.de_inst.funct7 == rv32i::funct7_imm_op_srai) begin
              n_ex_result = reg_fwd.rs1_value >>> id_ex.de_inst.imm[4:0];
            end else if (id_ex.de_inst.funct7 == rv32i::funct7_imm_op_srli) begin
              n_ex_result = reg_fwd.rs1_value >> id_ex.de_inst.imm[4:0];
            end
          end
        endcase
      end
      rv32i::opcode_branch: begin
        case (id_ex.de_inst.funct3)
          rv32i::funct3_branch_beq: begin
            n_ex_result = reg_fwd.rs1_value == reg_fwd.rs2_value;
          end
          rv32i::funct3_branch_bne: begin
            n_ex_result = reg_fwd.rs1_value != reg_fwd.rs2_value;
          end
          rv32i::funct3_branch_blt: begin
            n_ex_result = $signed(reg_fwd.rs1_value) < $signed(reg_fwd.rs2_value);
          end
          rv32i::funct3_branch_bge: begin
            n_ex_result = $signed(reg_fwd.rs1_value) >= $signed(reg_fwd.rs2_value);
          end
          rv32i::funct3_branch_bltu: begin
            n_ex_result = reg_fwd.rs1_value < reg_fwd.rs2_value;
          end
          rv32i::funct3_branch_bgeu: begin
            n_ex_result = reg_fwd.rs1_value >= reg_fwd.rs2_value;
          end
        endcase
      end
      rv32i::opcode_auipc: begin
        n_ex_result = id_ex.pc + id_ex.de_inst.imm;
      end
      rv32i::opcode_jal, rv32i::opcode_jalr: begin
        n_ex_result = id_ex.pc + sys::inst_size;
      end
    endcase
  end

  rv32i::addr_t n_ex_addr;
  always @(*) begin
    n_ex_addr = '0;
    case (id_ex.de_inst.opcode)
      rv32i::opcode_branch: begin
        if (n_ex_result) begin
          n_ex_addr = util::align_inst(id_ex.pc + id_ex.de_inst.imm);
        end else begin
          n_ex_addr = id_ex.pc + sys::inst_size;
        end
      end
      rv32i::opcode_jalr: begin
        n_ex_addr = util::align_inst(reg_fwd.rs1_value + id_ex.de_inst.imm);
      end
      rv32i::opcode_jal: begin
        n_ex_addr = util::align_inst(id_ex.pc + id_ex.de_inst.imm);
      end
    endcase
  end

  core::ex_mem_t n_ex_mem;
  always @(*) begin
    n_ex_mem = ex_mem;
    if (rst) begin
      n_ex_mem = core::ex_mem_rst;
    end else if (next_rdy) begin
      n_ex_mem.pc        = id_ex.pc;
      n_ex_mem.inst      = id_ex.inst;
      n_ex_mem.de_inst   = id_ex.de_inst;
      n_ex_mem.rs1_value = reg_fwd.rs1_value;
      n_ex_mem.rs2_value = reg_fwd.rs2_value;
      n_ex_mem.ex_result = n_ex_result;
      n_ex_mem.ex_addr   = n_ex_addr;
      n_ex_mem.valid     = en && id_ex.valid;
    end
  end

  always @(posedge clk) begin
    ex_mem <= n_ex_mem;
  end

endmodule

`endif // __EX_STAGE_SV__