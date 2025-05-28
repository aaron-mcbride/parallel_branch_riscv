`include "common.sv"

`ifndef __ID_STAGE_SV__
`define __ID_STAGE_SV__

// Decode stage module
module id_stage (
  input logic clk,                        // Clock signal
  input bool rst,                         // Reset signal
  input bool en,                          // Enable signal
  input bool next_rdy,                    // Next stage ready signal
  input core::if_id_t if_id,              // Stage input registers
  input rv32i::rf_read_rsp_t rf_read_rsp, // Register file read response
  output core::id_ex_t id_ex,             // Stage output registers
  output core::rf_read_req_t rf_read_req, // Register file read request
  output bool rdy                         // Ready signal
);

  assign rdy = en && next_rdy;

  core::de_inst_t n_de_inst;
  always @(*) begin
    n_de_inst.opcode  = rv32i::get_opcode(if_id.inst);
    n_de_inst.funct3  = rv32i::get_funct3(if_id.inst);
    n_de_inst.funct7  = rv32i::get_funct7(if_id.inst);
    n_de_inst.rs1     = rv32i::get_rs1_num(if_id.inst);
    n_de_inst.rs2     = rv32i::get_rs2_num(if_id.inst);
    n_de_inst.rd      = rv32i::get_rd_num(if_id.inst);
    n_de_inst.imm     = '0;
    n_de_inst.has_rs1 = '0;
    n_de_inst.has_rs2 = '0;
    n_de_inst.has_rd  = '0;
    case (n_de_inst.opcode)
      rv32i::opcode_lui: begin
        n_de_inst.imm     = rv32i::get_imm_u(if_id.inst);
        n_de_inst.has_rd  = '1;
      end
      rv32i::opcode_auipc: begin
        n_de_inst.imm     = rv32i::get_imm_u(if_id.inst);
        n_de_inst.has_rd  = '1;
      end
      rv32i::opcode_jal: begin
        n_de_inst.imm     = rv32i::get_imm_j(if_id.inst);
        n_de_inst.has_rd  = '1;
      end
      rv32i::opcode_jalr: begin
        n_de_inst.imm     = rv32i::get_imm_i(if_id.inst);
        n_de_inst.has_rd  = '1;
        n_de_inst.has_rs1 = '1;
      end
      rv32i::opcode_branch: begin
        n_de_inst.imm     = rv32i::get_imm_b(if_id.inst);
        n_de_inst.has_rs1 = '1;
        n_de_inst.has_rs2 = '1;
      end
      rv32i::opcode_load: begin
        n_de_inst.imm     = rv32i::get_imm_i(if_id.inst);
        n_de_inst.has_rd  = '1;
        n_de_inst.has_rs1 = '1;
      end
      rv32i::opcode_store: begin
        n_de_inst.imm     = rv32i::get_imm_s(if_id.inst);
        n_de_inst.has_rs1 = '1;
        n_de_inst.has_rs2 = '1;
      end
      rv32i::opcode_op: begin
        n_de_inst.has_rd  = '1;
        n_de_inst.has_rs1 = '1;
        n_de_inst.has_rs2 = '1;
      end
      rv32i::opcode_imm_op: begin
        n_de_inst.imm     = rv32i::get_imm_i(if_id.inst);
        n_de_inst.has_rd  = '1;
        n_de_inst.has_rs1 = '1;
      end
    endcase
  end

  assign rf_read_req.rs1_num = n_de_inst.rs1_num;
  assign rf_read_req.rs2_num = n_de_inst.rs2_num;

  core::id_ex_t n_id_ex;
  always @(*) begin
    n_id_ex = core::id_ex_rst;
    if (rst) begin
      n_id_ex = core::id_ex_rst;
    end else if (next_rdy) begin
      n_id_ex.pc        = if_id.pc;
      n_id_ex.inst      = if_id.inst;
      n_id_ex.de_inst   = n_de_inst;
      n_id_ex.rs1_value = rf_read_rsp.rs1_value;
      n_id_ex.rs2_value = rf_read_rsp.rs2_value;
      n_id_ex.valid     = en && if_id.valid;
    end
  end

  always @(posedge clk) begin
    id_ex <= n_id_ex;
  end

endmodule

`endif // __ID_STAGE_SV__