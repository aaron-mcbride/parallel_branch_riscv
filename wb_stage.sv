`include "common.sv"

`ifndef __WB_STAGE_SV__
`define __WB_STAGE_SV__

// Writeback stage module
module wb_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input core::asm_wb_t asm_wb,
  input core::rf_write_rsp_t rd_rf_write_rsp,
  output core::rf_write_req_t rd_rf_write_req,
  output bool rdy
);

  // Ready flag logic
  assign rdy = en && (!rd_rf_write_req.en || rd_rf_write_rsp.done);

  // Register file write request logic
  assign rd_rf_write_req.addr = asm_wb.de_inst.rd;
  assign rd_rf_write_req.data = asm_wb.asm_result;
  assign rd_rf_write_req.en   = en && !rst && asm_wb.valid && asm_wb.de_inst.has_rd;

endmodule

`endif // __WB_STAGE_SV__