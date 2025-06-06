`include "common.sv"

`ifndef __BRANCH_PRED_SV__
`define __BRANCH_PRED_SV__

module branch_pred #(
  parameter int req_ports = 3,
  parameter int table_cnt = 3,
  parameter int table_size = 32,
  parameter int hist_size = 3
) (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input core::branch_pred_req_t branch_pred_req [req_ports],
  input core::branch_pred_fb_t branch_pred_fb,
  output core::branch_pred_rsp_t branch_pred_rsp [req_ports]
);

  // Numeric types for representing table number, table index, and history index
  typedef logic [($clog2(table_cnt) - 1):0] table_num_t;
  typedef logic [($clog2(table_size) - 1):0] table_index_t;
  typedef logic [(hist_size - 1):0] hist_num_t;

  // Global branch history register
  table_num_t global_bhr;

  // Branch history table
  hist_num_t branch_hist [table_cnt][table_size];

  // Feedback/branch history update logic
  table_index_t fb_table_index;
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      for (int i = 0; i < table_cnt; i++) begin
        for (int j = 0; j < table_size; j++) begin
          branch_hist[i][j] <= '0;
        end
      end
    end else if (en && branch_pred_fb.valid) begin
      global_bhr >>= 1;
      global_bhr[0] = branch_pred_fb.branch_taken;
      fb_table_index = branch_pred_fb.base_pc % table_size;
      branch_hist[global_bhr][fb_table_index][hist_size - 1] <<= 1;
      branch_hist[global_bhr][fb_table_index][0] <= branch_pred_fb.branch_taken;
    end
  end

  // Branch prediction request/response logic
  table_index_t req_table_index;
  hist_index_t req_taken_cnt;
  always @(*) begin
    req_table_index = '0;
    req_taken_cnt   = '0;
    if (en) begin
      for (int i = 0; i < req_ports; i++) begin
        branch_pred_rsp[i] = core::branch_pred_rsp_rst;
        if (branch_pred_rsp[i].valid) begin
          req_taken_cnt = '0;
          req_table_index = branch_pred_req[i].base_pc % table_size;
          for (int j = 0; j < hist_size; j++) begin
            if (branch_hist[global_bhr][req_table_index][j] == 1) begin
              req_taken_cnt++;
            end
          end
          branch_pred_rsp[i].pred_taken = (req_taken_cnt > (hist_size / 2));
          branch_pred_rsp[i].exec_alt = (req_taken_cnt == 0) || (req_taken_cnt == hist_size);
        end
      end
    end
  end

endmodule

`endif // __BRANCH_PRED_SV__