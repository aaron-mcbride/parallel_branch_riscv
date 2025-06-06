`include "common.sv"

`ifndef __TARG_PRED_SV__
`define __TARG_PRED_SV__

// 

module targ_pred #(
  parameter int req_ports = 3,
  parameter int table_size = 32,
  parameter int hist_size = 3
) (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input core::targ_pred_req_t targ_pred_req [req_ports],
  input core::targ_pred_fb_t targ_pred_fb,
  output core::targ_pred_rsp_t targ_pred_rsp [req_ports]
);

  // Numeric types for representing table index and history index
  typedef logic [($clog2(table_size) - 1):0] table_index_t;
  typedef logic [($clog2(hist_size) - 1):0] hist_index_t;

  // Target history memory
  hist_index_t targ_hist [table_size][hist_size];

  // Feedback/target history update logic
  always @(posedge clk, posedge rst) begin
    logic i, j;
    table_index_t cur_table_index;
    if (rst) begin
      for (i = 0; i < table_size; i++) begin
        for (j = 0; j < hist_size; j++) begin
          targ_hist[i][j] <= '0;
        end
      end
    end else if (en && targ_pred_fb.valid) begin
      cur_table_index = targ_pred_fb.base_pc % table_size;
      for (i = (hist_size - 1); i > 0; i--) begin
        targ_hist[cur_table_index][i] <= targ_hist[cur_table_index][i - 1];
      end
      targ_hist[cur_table_index][0] <= targ_pred_fb.targ_pc;
    end
  end

  // Target prediction request/response logic
  always @(*) begin
    table_index_t cur_table_index = '0;
    bool_t targ_found_flag = '0;
    logic i, j, k;
    for (i = 0; i < req_ports; i++) begin
      targ_pred_rsp[i] = core::targ_pred_rsp_rst;
      if (en && targ_pred_req[i].valid) begin
        cur_table_index = targ_pred_req[i].base_pc % table_size;
        for (j = 0; j < hist_size; j++) begin
          targ_found_flag = false;
          for (k = 0; k < targ_pred_rsp[i].pred_cnt; k++) begin
            if (targ_pred_rsp[i].pred_pc[k] == targ_hist[cur_table_index][j]) begin
              targ_found_flag = true;
            end
          end
          if (!targ_found_flag) begin
            targ_pred_rsp[i].pred_pc[j] = targ_hist[cur_table_index][j];
            targ_pred_rsp[i].pred_cnt++;
          end
        end
      end
    end
  end

endmodule

`endif // __TARG_PRED_SV__