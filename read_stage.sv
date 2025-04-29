`include "common.sv"

`ifndef __READ_STAGE_SV__
`define __READ_STAGE_SV__

module read_stage (
  input logic clk,
  input logic rst,
  input logic en,
  input logic next_rdy,
  input core::id_rd_t id_rd,
  input core::rf_read_rsp_t rf_read_rsp [2],
  output core::rf_read_req_t rf_read_req [2],
  output core::rd_ex_t rd_ex,
  output logic rdy
);

  // Ready flag logic
  assign rdy = en && next_rdy && rf_read_rsp[0].done && rf_read_rsp[1].done;

  // Register read request logic
  always @(*) begin
    if (reg_fwd)

  end





endmodule

`endif // __READ_STAGE_SV__