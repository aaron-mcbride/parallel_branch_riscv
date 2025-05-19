`include "common.sv"

`ifndef __TARG_PRED_SV__
`define __TARG_PRED_SV__

module targ_pred #(
  parameter int s_pipe_cnt = 3,
  parameter int table_cnt = 2,
  parameter int table_size = 32,
  parameter int table_width = 3,
  parameter int hist_thresh = 1,
) (
  input logic clk,
  input logic rst,
  input logic en,
  input logic [($clog2(table_cnt) - 1):0] table_index,
  input core::targ_pred_req_t req [s_pipe_cnt],
  input core::targ_pred_fb_t fb,
  output core::targ_pred_rsp_t rsp [s_pipe_cnt]
);

  // Numeric types for history and
  typedef logic [(hist_width - 1):0] hist_value_t;

  // Table entry struct type
  typedef struct packed {
    hist_value_t hist_value [table_width];
    sys::addr_t targ_addr [table_width];
    bool valid;
  } target_info_t;
    
  // Target prediction tables
  target_info_t targ_pred_table [table_cnt][table_size];

  // Prediction request response logic
  target_info_t cur_targ_info [s_pipe_cnt];
  always @(*) begin
    for (int i = 0; i < s_pipe_cnt; i++) begin
      rsp[i] = core::targ_pred_rsp_rst;
      if (en && req.valid) begin
        cur_targ_info[i] = targ_pred_table[table_index]
            [req[i].addr[($clog2(table_size) - 1):0]];
        if (cur_targ_info[i].valid) begin
          for (int j = 0; j < table_width; j++) begin
            if (cur_targ_info[i].hist_value)
          end
        end
      end
    end
  end

endmodule

`endif // __TARG_PRED_SV__
