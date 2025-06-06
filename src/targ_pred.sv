`include "common.sv"

`ifndef __TARG_PRED_SV__
`define __TARG_PRED_SV__

import bool_type::*;

module targ_pred #(
  parameter int table_size = 32, // Size of prediction table
  parameter int prune_freq = 4   // Frequency at which stale entries are pruned
) (
  input logic clk,                                     // Clock signal
  input bool_t rst,                                    // Reset signal
  input bool_t en,                                     // Enable signal
  input core::targ_pred_fb_t fb,                       // Target prediction feedback
  input core::targ_pred_req_t req [core::peval_width], // Target prediction requests
  output core::targ_pred_rsp_t rsp [core::peval_width] // Target prediction responses
);

  typedef logic [($clog2(table_size) - 1):0] table_idx_t;
  typedef logic [($clog2(prune_freq) - 1):0] prune_cnt_t;

  typedef struct {
    sys::addr_t targ_list [core::peval_width];
    core::peval_idx_t targ_cnt;
    prune_cnt_t prune_cnt;
  } table_entry_t;

  parameter table_entry_t table_entry_rst = '{default: '0};

  table_entry_t pred_table [table_size];

  always @(*) begin
    int i, j;
    table_idx_t cur_idx;
    for (i = 0; i < core::peval_width; i++) begin
      cur_idx = req[i].base_pc % table_size;
      rsp[i].targ_cnt = pred_table[cur_idx].targ_cnt;
      for (j = 0; j < core::peval_width; j++) begin
        rsp[i].targ_list[j] = pred_table[cur_idx].targ_list[j];
      end
    end
  end

  table_entry_t n_fb_entry;
  table_idx_t n_fb_entry_idx;
  always @(*) begin
    int i;
    bool_t targ_found;
    n_fb_entry_idx = '0;
    n_fb_entry = pred_table[n_fb_entry_idx];
    if (fb.valid) begin
      n_fb_entry_idx = fb.base_pc % table_size;
      n_fb_entry = pred_table[n_fb_entry_idx];
      targ_found = false;
      if (n_fb_entry.targ_list[core::peval_width - 1] == fb.targ_pc) begin
        targ_found = true;
      end else begin
        for (i = 0; i < (core::peval_width - 1); i++) begin
          if (targ_found || (n_fb_entry.targ_list[i] == fb.targ_pc)) begin
            n_fb_entry.targ_list[i] = n_fb_entry.targ_list[i + 1];
            targ_found = true;
          end
        end
      end
      for (i = (core::peval_width - 1); i > 0; i--) begin
        n_fb_entry.targ_list[i] = n_fb_entry.targ_list[i - 1];
      end
      n_fb_entry.targ_list[0] = fb.targ_pc;
      if ((n_fb_entry.targ_cnt < core::peval_width) && !targ_found) begin
        n_fb_entry.targ_cnt++;
      end
      if ((n_fb_entry.prune_cnt == (prune_freq - 1))) begin
        if (n_fb_entry.targ_cnt > 0) begin
          n_fb_entry.targ_cnt--;
        end
        n_fb_entry.prune_cnt = '0;
      end else begin
        n_fb_entry.prune_cnt++;
      end
    end
  end

  always @(posedge clk) begin
    int i;
    if (rst) begin
      for (i = 0; i < table_size; i++) begin
        pred_table[i] <= table_entry_rst;
      end
    end else if (en) begin
      pred_table[n_fb_entry_idx] <= n_fb_entry;
    end
  end

endmodule

`endif // __TARG_PRED_SV__