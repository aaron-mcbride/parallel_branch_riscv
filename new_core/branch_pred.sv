`include "common.sv"

`ifndef __BRANCH_PRED_SV__
`define __BRANCH_PRED_SV__

module branch_pred #(
  parameter int table_cnt       = 2,  // Number of prediction tables (selected from global history)
  parameter int table_size      = 32, // Size of prediction table
  parameter int eval_alt_thresh = 4   // Threshold of consective taken/not-taken to stop evaluating alternate path
) (
  input logic clk,                                            // Clock signal
  input bool rst,                                             // Reset signal
  input bool en,                                              // Enable signal
  input core::branch_pred_fb_t fb,                            // Branch prediction feedback
  input core::branch_pred_req_t req [core::peval_width], // Branch prediction requests
  output core::branch_pred_rsp_t rsp [core::peval_width] // Branch prediction responses
);

  typedef logic [($clog2(table_cnt) - 1):0] table_num_t;
  typedef logic [($clog2(table_size) - 1):0] table_idx_t;
  typedef logic [($clog2(eval_alt_thresh) - 1):0] hist_cnt_t;

  typedef struct packed {
    bool branch_taken;
    hist_cnt_t hist_cnt; 
  } table_entry_t;

  parameter table_entry_t table_entry_rst = '0;

  table_num_t cur_table_num;
  table_entry_t pred_table [table_cnt][table_size];

  always @(*) begin
    int i;
    table_idx_t cur_idx;
    for (i = 0; i < core::peval_width; i++) begin
      cur_idx = req[i].base_pc % table_size;
      rsp[i].branch_taken = pred_table[cur_table_num][cur_idx].branch_taken;
      rsp[i].eval_alt = pred_table[cur_table_num][cur_idx].hist_cnt >= (eval_alt_thresh - 1);
    end
  end

  table_num_t n_table_num;
  table_idx_t n_fb_entry_idx;
  table_entry_t n_fb_entry;
  always @(*) begin
    n_table_num = cur_table_num;
    n_fb_entry_idx = '0;
    n_fb_entry = pred_table[n_table_num][n_fb_entry_idx];
    if (fb.valid) begin
      n_table_num = (n_table_num << 1) | fb.branch_taken;
      n_fb_entry_idx = fb.base_pc % table_size;
      n_fb_entry = pred_table[n_table_num][n_fb_entry_idx];
      if (n_fb_entry.branch_taken == fb.branch_taken) begin
        n_fb_entry.hist_cnt++;
      end else begin
        n_fb_entry.hist_cnt = '0;
      end
      n_fb_entry.branch_taken = fb.branch_taken;
    end
  end

  always @(posedge clk) begin
    int i, j;
    if (rst) begin
      for (i = 0; i < table_cnt; i++) begin
        for (j = 0; j < table_size; j++) begin
          pred_table[i][j] <= table_entry_rst;
        end
      end
    end else if (en) begin
      cur_table_num <= n_table_num;
      pred_table[n_table_num][n_fb_entry_idx] <= n_fb_entry;
    end
  end

endmodule

`endif // __BRANCH_PRED_SV__