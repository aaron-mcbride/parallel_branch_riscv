`include "common.sv"

`ifndef __REGFILE_SV__
`define __REGFILE_SV__

import bool_type::*;

module regfile #(
  parameter int read_port_cnt = 3, // Number of read ports
  parameter int write_port_cnt = 1 // Number of write ports
) (
  input logic clk,                                       // Clock signal
  input bool_t rst,                                        // Reset signal
  input bool_t en,                                         // Enable signal
  input core::rf_read_req_t read_req [read_port_cnt],    // Register file read request array
  input core::rf_write_req_t write_req [write_port_cnt], // Register file write request array
  output core::rf_read_rsp_t read_rsp [read_port_cnt]    // Register file read response array  
);

  rv32i::reg_t reg_array [rv32i::reg_cnt - 1];

  always @(*) begin
    for (int i = 0; i < read_port_cnt; i++) begin
      read_rsp[i].rs1_value = '0;
      read_rsp[i].rs2_value = '0;
      if (read_req[i].rs1_num != 0) begin
        read_rsp[i].rs1_value = reg_array[read_req[i].rs1_num - 1];
        for (int j = 0; j < write_port_cnt; j++) begin
          if (write_req[j].en && write_req[j].rd_num == read_req[i].rs1_num) begin
            read_rsp[i].rs1_value = write_req[j].rd_value;
          end
        end
      end
      if (read_req[i].rs2_num != 0) begin
        read_rsp[i].rs2_value = reg_array[read_req[i].rs2_num - 1];
        for (int j = 0; j < write_port_cnt; j++) begin
          if (write_req[j].en && write_req[j].rd_num == read_req[i].rs2_num) begin
            read_rsp[i].rs2_value = write_req[j].rd_value;
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < (rv32i::reg_cnt - 1); i++) begin
        reg_array[i] <= '0;
      end
    end else if (en) begin
      for (int i = 0; i < write_port_cnt; i++) begin
        if (write_req[i].en && write_req[i].rd_num != 0) begin
          reg_array[write_req[i].rd_num - 1] <= write_req[i].rd_value;
        end
      end
    end
  end 

endmodule

`endif // __REGFILE_SV__