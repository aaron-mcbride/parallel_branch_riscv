`include "common.sv"

`ifndef __WB_STAGE_SV__
`define __WB_STAGE_SV__

// Writeback stage module
module wb_stage (
  input logic clk,                          // Clock signal
  input bool rst,                           // Reset signal
  input bool en,                            // Enable signal
  input core::mem_wb_t mem_wb,              // Stage input registers
  output core::rf_write_req_t rf_write_req, // Register file write request
  output bool rdy                           // Stage ready signal
);

  assign rdy = en;

  assign rf_write_req.rd_num = mem_wb.de_inst.rd_num;
  assign rf_write_req.en   = en && !rst && mem_wb.valid && mem_wb.de_inst.has_rd;

  always @(*) begin
    rf_write_req.rd_value = '0;
    case (mem_wb.de_inst.opcode)
      rv32i::opcode_auipc, rv32i::opcode_jal, rv32i::opcode_jalr, 
      rv32i::opcode_op, rv32i::opcode_imm_op: begin
        rf_write_req.rd_value = mem_wb.ex_result;
      end
      rv32i::opcode_load: begin
        rf_write_req.rd_value = mem_wb.mem_result;
      end
      rv32i::opcode_lui: begin
        rf_write_req.rd_value = mem_wb.de_inst.imm;
      end
    endcase
  end

endmodule

`endif // __WB_STAGE_SV__