`include "common.sv"

`ifndef __MEMORY_SV__
`define __MEMORY_SV__

// RAM memory module
module memory #(
  parameter int mem_size = 1024,
  parameter int read_port_cnt = 2
  parameter string init_file = "init.mem"
) (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input sys::mem_write_req_t write_req,
  input sys::mem_read_req_t read_req [read_port_cnt],
  output sys::mem_write_rsp_t write_rsp,
  output sys::mem_read_rsp_t read_rsp [read_port_cnt]
);

  // Memory array
  logic [(sys::byte_width - 1):0] mem_array [mem_size];

  // Acknowledged read/write request register
  sys::mem_read_req_t ack_read_req [read_port_cnt];
  sys::mem_write_req_t ack_write_req;

  // Read request result
  sys::word_t read_req_result [read_port_cnt];

  // Memory read request response logic
  always @(*) begin
    for (int i = 0; i < read_port_cnt; i++) begin
      read_rsp[i] = sys::mem_read_rsp_rst;
      if (en && read_req[i].en && (read_req[i].addr < mem_size) && 
          (util::addr_off(read_req[i].addr) == 0)) begin
        read_rsp[i].valid = true;
        read_rsp[i].done = read_req[i] == ack_read_req[i] &&
            (write_rsp.done || !write_rsp.valid || !write_req.en ||
            (write_req.addr != read_req[i].addr));
      end
    end
  end

  // Memory write request response logic
  always @(*) begin
    write_rsp = sys::mem_write_rsp_rst;
    if (en && write_req.en && (write_req.addr < mem_size) &&
        (util::addr_off(write_req.addr) == 0)) begin
      write_rsp.valid = true;
      write_rsp.done = write_req == ack_write_req;
    end
  end

  // Memory update and request acknowledge logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      ack_write_req <= sys::mem_write_req_rst;
      for (int i = 0; i < read_port_cnt; i++) begin
        ack_read_req[i] <= sys::mem_read_req_rst;
        read_req_result[i] <= '0;
      end
      `ifdef __SYNTHESIS__
        for (int i = 0; i < mem_size; i++) begin
          mem_array[i] <= '0;
        end
      `else
        $readmemh(init_file, mem_array);
      `endif
    end else if (en) begin
      if (write_req.en) begin
        ack_write_req <= write_req;
        if (write_rsp.valid) begin
          for (int i = 0; i < (sys::word_width / sys::byte_width); i++) begin
            if (write_req.mask[i]) begin
              mem_array[write_req.addr + i] = write_req.data
                  [(i * sys::byte_width) +: sys::byte_width];
            end
          end
        end
      end
      for (int i = 0; i < read_port_cnt; i++) begin
        if (read_req[i].en) begin
          ack_read_req[i] <= read_req[i];
          if (read_rsp[i].valid) begin
            read_req_result[i] = '0;
            for (int j = 0; j < (sys::word_width / sys::byte_width); j++) begin
              if (read_req[i].mask[j]) begin
                read_req_result[i][(j * sys::byte_width) +: sys::byte_width] <= 
                    mem_array[read_req[i].addr + j];
              end
            end
          end
        end
      end
    end
  end

endmodule

`endif // __MEMORY_SV__