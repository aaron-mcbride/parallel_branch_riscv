`include "common.sv"

`ifndef __DECODE_STAGE_SV__
`define __DECODE_STAGE_SV__

module decode_stage (
  input logic clk,
  input logic rst,
  input logic en,
  input logic execute_rdy,
  input if_id_t if_id,
  input mem_read_rsp_t rf_read_rsp [2],
  output mem_read_req_t rf_read_req [2],
  output logic rdy,
  output id_ex_t id_ex
);

  // Function to determine if instruction has rs1 register
  function logic has_rs1(input opcode_t opcode);
    return (opcode == OPCODE_OP || opcode == OPCODE_OP_IMM ||
        opcode == OPCODE_LOAD || opcode == OPCODE_STORE ||
        opcode == OPCODE_BRANCH || opcode == OPCODE_JALR);
  endfunction

  // Function to determine if instruction has rs2 register
  function logic has_rs2(input opcode_t opcode);
    return (opcode == OPCODE_OP || opcode == OPCODE_OP_IMM ||
        opcode == OPCODE_STORE || opcode == OPCODE_BRANCH);
  endfunction

  // Ready flag logic
  assign rdy = en && execute_rdy && rf_read_done &&
      rf_read_rsp[0].done && rf_read_rsp[1].done;

  // Regfile read request logic
  assign rf_read_req[0].addr = next_id_ex.rs1;
  assign rf_read_req[1].addr = next_id_ex.rs2;
  assign rf_read_req[0].mask = 4'b1111;
  assign rf_read_req[1].mask = 4'b1111;
  assign rf_read_req[0].en   = has_rs1(if_id.inst[6:0]) && if_id.valid && en;
  assign rf_read_req[1].en   = has_rs2(if_id.inst[6:0]) && if_id.valid && en;

  // Update id_ex registers on clock/rst edge
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      id_ex.inst    <= '0;
      id_ex.pc      <= '0;
      id_ex.opcode  <= '0;
      id_ex.funct3  <= '0;
      id_ex.funct7  <= '0;
      id_ex.rs1     <= '0;
      id_ex.rs2     <= '0;
      id_ex.rd      <= '0;
      id_ex.imm     <= '0;
      id_ex.valid   <= '0;
    end else if (en && execute_rdy) begin
      id_ex.inst   = if_id.inst;
      id_ex.pc     = if_id.pc;
      id_ex.opcode = if_id.inst[6:0];
      id_ex.funct3 = if_id.inst[14:12];
      id_ex.funct7 = if_id.inst[31:25];
      id_ex.rs1    = if_id.inst[19:15];
      id_ex.rs2    = if_id.inst[24:20];
      id_ex.rd     = if_id.inst[11:7];
      case (if_id.inst[6:0])
        OPCODE_LUI: begin
          id_ex.imm = {if_id.inst[31:12], 12'b0};
        end
        OPCODE_AUIPC: begin
          id_ex.imm = {if_id.inst[31:12], 12'b0};
        end
        OPCODE_JAL: begin
          id_ex.imm = {{11{if_id.inst[31]}}, if_id.inst[19:12], if_id.inst[20], if_id.inst[30:21], 1'b0};
        end
        OPCODE_JALR: begin
          id_ex.imm = {{20{if_id.inst[31]}}, if_id.inst[31:20]};
        end
        OPCODE_BRANCH: begin
          id_ex.imm = {{19{if_id.inst[31]}}, if_id.inst[7], if_id.inst[30:25], if_id.inst[11:8], 1'b0};
        end
        default: begin
          id_ex.imm = {{20{if_id.inst[31]}}, if_id.inst[31:20]};
        end
      endcase
      id_ex.rs1_data = rf_read_rsp[0].data;
      id_ex.rs2_data = rf_read_rsp[1].data;
      id_ex.valid = if_id.valid && en && 
          (!has_rs1(if_id.inst) || rf_read_rsp[0].valid) &&
          (!has_rs2(if_id.inst))
    end
  end

endmodule

`endif // __DECODE_STAGE_SV__