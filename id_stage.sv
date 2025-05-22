`include "common.sv"

`ifndef __ID_STAGE_SV__
`define __ID_STAGE_SV__

// Decode stage module
module id_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input bool next_rdy,
  input core::if_id_t if_id,
  output core::id_rd_t id_rd,
  output bool rdy
);

  // Ready flag logic
  assign rdy = en && next_rdy;

  // Pipeline register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      id_rd <= core::id_rd_rst;
    end else if (next_rdy) begin
      id_rd.de_inst.opcode = rv32i::get_opcode(if_id.inst);
      case (id_rd.de_inst.opcode)
        rv32i::opcode_lui: begin
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_u(if_id.inst);
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_auipc: begin
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_u(if_id.inst);
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_jal: begin
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_j(if_id.inst);
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_jalr: begin
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_i(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_branch: begin
          id_rd.de_inst.funct3  <= rv32i::get_funct3(if_id.inst);
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rs2     <= rv32i::get_rs2(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_b(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '1;
          id_rd.de_inst.has_rd  <= '0;
        end
        rv32i::opcode_load: begin
          id_rd.de_inst.funct3  <= rv32i::get_funct3(if_id.inst);
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_i(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_store: begin
          id_rd.de_inst.funct3  <= rv32i::get_funct3(if_id.inst);
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rs2     <= rv32i::get_rs2(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_s(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '1;
          id_rd.de_inst.has_rd  <= '0;
        end
        rv32i::opcode_op: begin
          id_rd.de_inst.funct3  <= rv32i::get_funct3(if_id.inst);
          id_rd.de_inst.funct7  <= rv32i::get_funct7(if_id.inst);
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rs2     <= rv32i::get_rs2(if_id.inst);
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '1;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_imm_op: begin
          id_rd.de_inst.rs1     <= rv32i::get_rs1(if_id.inst);
          id_rd.de_inst.rd      <= rv32i::get_rd(if_id.inst);
          id_rd.de_inst.imm     <= get_imm_i(if_id.inst);
          id_rd.de_inst.has_rs1 <= '1;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '1;
        end
        rv32i::opcode_sys: begin
          id_rd.de_inst.funct3  <= rv32i::get_funct3(if_id.inst);
          id_rd.de_inst.funct7  <= rv32i::get_funct7(if_id.inst);
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '0;
        end
        rv32i::opcode_fence: begin
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '0;
        end
        default: begin
          id_rd.de_inst.has_rs1 <= '0;
          id_rd.de_inst.has_rs2 <= '0;
          id_rd.de_inst.has_rd  <= '0;
        end
      endcase
      id_rd.pc    <= if_id.pc;
      id_rd.inst  <= if_id.inst;
      id_rd.valid <= en && if_id.valid;
    end
  end

endmodule

`endif // __ID_STAGE_SV__