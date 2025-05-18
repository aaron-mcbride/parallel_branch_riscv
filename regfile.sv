`include "common.sv"

`ifndef __REGFILE_SV__
`define __REGFILE_SV__

// CPU register file module - responds to read/write requests
module regfile #(
  parameter int read_port_cnt  = 3,                    // Number of read ports
) (
  input logic clk,                                     // Clock signal
  input logic rst,                                     // Reset signal
  input logic en,                                      // Enable signal
  input core::rf_write_req_t write_req,                // Write request struct
  input core::rf_read_req_t read_req [read_port_cnt],  // Read request structs for all ports
  output core::rf_write_rsp_t write_rsp                // Write response struct
  output core::rf_read_rsp_t read_rsp [read_port_cnt], // Read response structs for all ports
);

  // Register file memory
  logic [(rv32i::reg_width - 1):0] rf_mem [rv32i::reg_cnt];

  // Acknowledged write request register
  core::rf_write_req_t ack_write_req;

  // Regfile read response logic
  always @(*) begin
    for (int i = 0; i < read_port_cnt; i++) begin
      read_rsp[i].valid = false;
      read_rsp[i].value = '0;
      if (en && read_req[i].en) begin
        if (write_req.en && (read_req[i].reg_addr == write_req.reg_addr)) begin
          read_rsp[i].value = write_req.value;
        end else begin
          read_rsp[i].value = rf_mem[read_req[i].reg_addr];
        end
        read_rsp[i].valid = true;
      end
    end
  end

  // Regfile write logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      ack_write_req <= core::rf_write_req_rst;
      for (int i = 0; i < rv32i::reg_cnt; i++) begin
        rf_mem[i] <= '0;
      end
    end else if (en) begin
      ack_write_req <= write_req;
      if (write_req.en) begin
        if (write_req.reg_addr != rv32i::reg_zero) begin
          rf_mem[write_req.reg_addr] <= write_req.value;
        end
      end
    end
  end

  // Regfile write response logic
  assign write_rsp.done = write_req == ack_write_req;
  assign write_rsp.valid = write_req.en;

endmodule

`endif // __REGFILE_SV__