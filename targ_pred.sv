`include "common.sv"

`ifndef __TARG_PRED_SV__
`define __TARG_PRED_SV__

`define TARG_PRED_TYPE_SIMPLE_BTB

module targ_pred #(
  parameter int s_pipe_cnt = 3,
  parameter int table_size = 32,
  parameter int table_width = 5,
  parameter int hist_width = 2,
  parameter int 
) (
  input logic clk,
  input logic rst,
  input logic en,
  input core::targ_pred_req_t req [s_pipe_cnt],
  input core::targ_pred_fb_t fb,
  output core::targ_pred_rsp_t rsp [s_pipe_cnt]
);

  `ifdef TARG_PRED_TYPE_SIMPLE_BTB

    // Target buffer
    logic [sys::addr_t] targ_buff [table_size];

    // Prediction request response logic
    always @(*) begin
      for (int i = 0; i < s_pipe_cnt; i++) begin
        rsp[i] = core::targ_pred_rsp_rst;
        if (en && req.valid) begin
          rsp[i].valid[0] = true;
          rsp[i].pred = targ_buff[req[i].addr[($clog2(table_size) - 1):0]];
        end
      end
    end

  `else

  `endif



endmodule

`endif // __TARG_PRED_SV__
