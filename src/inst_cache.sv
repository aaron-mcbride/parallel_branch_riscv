`include "common.sv"

`ifndef __INST_CACHE_SV__
`define __INST_CACHE_SV__

import bool_type::*;

module inst_cache #(
  parameter int fetch_port_cnt = 4,
  parameter int mem_port_cnt   = 2,
  parameter int cache_size     = 1024
) (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input core::inst_fetch_req_t fetch_req [fetch_port_cnt],
  input sys::mem_read_block_rsp_t mem_rsp [mem_port_cnt],
  output core::inst_fetch_rsp_t fetch_rsp [fetch_port_cnt],
  output sys::mem_read_block_req_t mem_req [mem_port_cnt]
);

  // derived parameters
  localparam int line_size    = sys::mem_block_size / sys::inst_size;
  localparam int index_width  = $clog2(line_size);
  localparam int set_width    = $clog2(cache_size);
  localparam int tag_width    = sys::addr_width - set_width - index_width;
  localparam int offset_width = $clog2(sys::mem_block_size);

  typedef logic [(tag_width-1) : 0] tag_t;
  typedef logic [(set_width-1) : 0] set_t;
  typedef logic [(index_width-1): 0] index_t;

  typedef struct {
    tag_t tag;
    rv32i::inst_t data [line_size];
  } cache_line_t;

  sys::mem_read_block_req_t mem_req_reg [mem_port_cnt];
  tag_t req_tag [mem_port_cnt];
  set_t req_set [mem_port_cnt];
  cache_line_t cache_mem [cache_size];

  bool_t mem_req_next_en [mem_port_cnt];
  sys::addr_t mem_req_next_addr [mem_port_cnt];
  tag_t mem_req_next_tag [mem_port_cnt];
  set_t mem_req_next_set [mem_port_cnt];

  always_comb begin
    int i;
    tag_t cur_tag;
    set_t cur_set;
    index_t cur_index;
    for (i = 0; i < fetch_port_cnt; i++) begin
      fetch_rsp[i] = core::inst_fetch_rsp_rst;
      if (fetch_req[i].en) begin
        cur_tag = fetch_req[i].pc[(sys::addr_width - 1)-:tag_width];
        cur_set = fetch_req[i].pc[index_width+:set_width];
        if (cache_mem[cur_set].tag == cur_tag) begin
          cur_index = fetch_req[i].pc[(index_width - 1):0];
          fetch_rsp[i].inst = cache_mem[cur_set].data[cur_index];
          fetch_rsp[i].done = 1;
        end
      end
    end
  end

  function automatic int find_free_port(input bool_t busy_list [mem_port_cnt]);
    int i;
    int free_port = -1;
    bool_t break_flag = false;
    for (i = 0; i < mem_port_cnt && !break_flag; i++) begin
      if (!busy_list[i]) begin
        break_flag = true;
        free_port = i;
      end
    end
    return free_port;
  endfunction

  always_comb begin
    int i;
    tag_t cur_tag;
    set_t cur_set;
    int freep;
    for (i = 0; i < mem_port_cnt; i++) begin
      mem_req_next_en[i]   = mem_req_reg[i].en;
      mem_req_next_addr[i] = mem_req_reg[i].addr;
      mem_req_next_tag[i]  = req_tag[i];
      mem_req_next_set[i]  = req_set[i];
    end
    for (i = 0; i < fetch_port_cnt; i++) begin
      if (fetch_req[i].en) begin
        cur_tag = fetch_req[i].pc[(sys::addr_width - 1)-:tag_width];
        cur_set = fetch_req[i].pc[index_width +: set_width];
        if (cache_mem[cur_set].tag != cur_tag) begin
          freep = find_free_port(mem_req_next_en);
          if (freep >= 0) begin
            mem_req_next_en[freep]   = true;
            mem_req_next_addr[freep] = fetch_req[i].pc & ~((1 << offset_width) - 1);
            mem_req_next_tag[freep]  = cur_tag;
            mem_req_next_set[freep]  = cur_set;
          end
        end
      end
    end
    for (i = 0; i < mem_port_cnt; i++) begin
      mem_req[i].en = mem_req_next_en[i];
      mem_req[i].addr  = mem_req_next_addr [i];
    end
  end

  always_ff @(posedge clk) begin
    int i, j, k;
    if (rst) begin
      for (i = 0; i < mem_port_cnt; i++) begin
        mem_req_reg[i] <= sys::mem_read_block_req_rst;
        req_tag[i] <= '0;
        req_set[i] <= '0;
      end
    end else if (en) begin
      for (i = 0; i < mem_port_cnt; i++) begin
        if (!mem_req_reg[i].en && mem_req_next_en[i]) begin
          req_tag[i] <= mem_req_next_tag[i];
          req_set[i] <= mem_req_next_set[i];
        end
        mem_req_reg[i].en <= mem_req_next_en[i];
        mem_req_reg[i].addr  <= mem_req_next_addr [i];
      end
      for (i = 0; i < mem_port_cnt; i++) begin
        if (mem_req_reg[i].en && mem_rsp[i].done) begin
          cache_mem[req_set[i]].tag <= req_tag[i];
          for (j = 0; j < line_size; j++) begin
            for (k = 0; k < rv32i::inst_width; k++) begin
              cache_mem[req_set[i]].data[j][(rv32i::inst_width * k) +: rv32i::inst_width] <= 
                  mem_rsp[i].data[(rv32i::inst_width * j) + k];
            end
          end
          mem_req_reg[i] <= sys::mem_read_block_req_rst;
        end
      end
    end
  end

endmodule

`endif // __INST_CACHE_SV__