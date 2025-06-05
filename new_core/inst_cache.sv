`include "common.sv"

`ifndef __INST_CACHE_SV__
`define __INST_CACHE_SV__

module inst_cache #(
  parameter int fetch_port_cnt = 4,
  parameter int mem_port_cnt   = 2,
  parameter int cache_size     = 1024
) (
  input logic clk,
  input bool rst,
  input bool en,
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

  typedef struct packed {
    tag_t tag;
    rv32i::inst_t data [line_size];
  } cache_line_t;

  logic sys::mem_read_block_req_t mem_req_reg [mem_port_cnt];
  tag_t req_tag [mem_port_cnt];
  set_t req_set [mem_port_cnt];
  cache_line_t cache_mem [cache_size];

  logic mem_req_next_valid [mem_port_cnt];
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
      if (fetch_req[i].valid) begin
        cur_tag = fetch_req[i].pc[(sys::addr_width - 1)-:tag_width];
        cur_set = fetch_req[i].pc[index_width +: set_width];
        if (cache_mem[cur_set].tag == cur_tag) begin
          cur_index = fetch_req[i].pc[(index_width - 1):0];
          fetch_rsp[i].inst = cache_mem[cur_set].data[cur_index];
          fetch_rsp[i].done = 1;
        end
      end
    end
  end

  function automatic int find_free_port(input logic [mem_port_cnt-1:0] busy);
    int idx;
    begin
      find_free_port = -1;
      for (idx = 0; idx < mem_port_cnt; idx++) begin
        if (!busy[idx]) begin
          find_free_port = idx;
          break;
        end
      end
    end
  endfunction

  always_comb begin
    for (int p = 0; p < mem_port_cnt; p++) begin
      mem_req_next_valid[p] = mem_req_reg[p].valid;
      mem_req_next_addr[p]  = mem_req_reg[p].addr;
      mem_req_next_tag[p]   = req_tag[p];
      mem_req_next_set[p]   = req_set[p];
    end
    for (int f = 0; f < fetch_port_cnt; f++) begin
      if (fetch_req[f].valid) begin
        tag_t comb_tag = fetch_req[f].pc[(sys::addr_width - 1)-:tag_width];
        set_t comb_set = fetch_req[f].pc[index_width +: set_width];
        if (cache_mem[comb_set].tag != comb_tag) begin
          int freep = find_free_port(mem_req_next_valid);
          if (freep >= 0) begin
            mem_req_next_valid[freep] = 1;
            mem_req_next_addr[freep]  = fetch_req[f].pc & ~((1 << offset_width) - 1);
            mem_req_next_tag[freep]   = comb_tag;
            mem_req_next_set[freep]   = comb_set;
          end
        end
      end
    end
    for (int p = 0; p < mem_port_cnt; p++) begin
      mem_req[p].valid = mem_req_next_valid[p];
      mem_req[p].addr  = mem_req_next_addr [p];
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
        if (!mem_req_reg[i].valid && mem_req_next_valid[i]) begin
          req_tag[i] <= mem_req_next_tag[i];
          req_set[i] <= mem_req_next_set[i];
        end
        mem_req_reg[i].valid <= mem_req_next_valid[i];
        mem_req_reg[i].addr  <= mem_req_next_addr [i];
      end
      for (i = 0; i < mem_port_cnt; i++) begin
        if (mem_req_reg[i].valid && mem_rsp[i].done) begin
          cache_mem[req_set[i]].tag <= req_tag[i];
          for (j = 0; j < line_size; j++) begin
            for (k = 0; k < sys::inst_width; k++) begin
              cache_mem[req_set[i]].data[j][(sys::inst_width * k) +: sys::inst_width] <= 
                  mem_rsp[i].data[(sys::inst_width * j) + k];
            end
          end
          mem_req_reg[i] <= sys::mem_read_block_req_rst;
        end
      end
    end
  end

endmodule

`endif // __INST_CACHE_SV__