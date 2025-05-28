`include "common.sv"

`ifndef __SYS_MEM_SV__
`define __SYS_MEM_SV__

module sys_mem #(
  parameter int size     = 1024,    // Memory size in bytes
  parameter int read_port_cnt = 3,  // Number of read ports
  parameter int write_port_cnt = 1, // Number of write ports
  parameter string mif   = "null"   // Memory initialization file path
) (
  input logic clk,                                       // Clock signal
  input bool rst,                                        // Reset signal
  input bool en,                                         // Enable signal
  input sys::mem_read_req_t read_req [read_port_cnt],    // Memory read request array
  input sys::mem_write_req_t write_req [write_port_cnt], // Memory write request array
  output sys::mem_read_rsp_t read_rsp [read_port_cnt],   // Memory read response array
  output sys::mem_write_rsp_t write_rsp [write_port_cnt] // Memory write response array
);

  sys::byte_t mem_array [size];

  initial begin
    if (mif != "null") begin
      $readmemh(mif, mem_array);
    end else begin
      for (int i = 0; i < size; i++) begin
        mem_array[i] = '0;
      end
    end
  end

  always @(posedge clk) begin
    if (en) begin
      for (int i = 0; i < read_port_cnt; i++) begin
        read_rsp[i].done <= '1;
        if (read_req[i].en) begin
          if (read_req[i].addr > size) begin
            $display("ERROR: Read request address out of bounds: %0d", read_req[i].addr);
            $finish;
          end
          for (int j = 0; j < read_req[i].size; j++) begin
            read_rsp[i].data[(sys::byte_size * j)+:sys::byte_size] <= mem_array[read_req[i].addr + j];
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      if (mif != "null") begin
        $readmemh(mif, mem_array);
      end else begin
        for (int i = 0; i < size; i++) begin
          mem_array[i] <= '0;
        end
      end
    end else if (en) begin
      for (int i = 0; i < write_port_cnt; i++) begin
        write_rsp[i].done <= '1;
        if (write_req[i].en) begin
          if (write_req[i].addr > size) begin
            $display("ERROR: Write request address out of bounds: %0d", write_req[i].addr);
            $finish;
          end
          for (int j = 0; j < write_req[i].size; j++) begin
            mem_array[write_req[i].addr + j] <= write_req[i].data[(sys::byte_size * j)+:sys::byte_size];
          end
        end
      end
    end
  end


endmodule

`endif // __SYS_MEM_SV__