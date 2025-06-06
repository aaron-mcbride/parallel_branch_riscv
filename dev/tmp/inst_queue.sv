typedef struct packed {
  sys::addr_t pc;
  bool_t valid;
} inst_fetch_req_t;

typedef struct packed {
  rv32i::inst_t inst;
  bool_t done;
} inst_fetch_rsp_t;

parameter inst_fetch_req_t inst_fetch_req_rst = '0;
parameter inst_fetch_rsp_t inst_fetch_rsp_rst = '0;

module fetch_queue #(
  parameter int fetch_port_cnt = 4,
  parameter int mem_port_cnt = 2,
) (
  input logic clk,
  input bool_t rst,
  input bool_t en,
  input core::inst_fetch_req_t fetch_req [fetch_port_cnt],
  input sys::mem_read_rsp_t mem_rsp [mem_port_cnt],
  output core::inst_fetch_rsp_t fetch_rsp [fetch_port_cnt],
  output sys::mem_read_req_t mem_req [mem_port_cnt],
);

  typedef logic [($clog2(fetch_port_cnt) - 1):0] fetch_port_idx_t;
  typedef logic [($clog2(mem_port_cnt) - 1):0] mem_port_idx_t;

  typedef struct packed {
    fetch_port_idx_t fetch_idx;
    bool_t valid;
  } mem_req_info_t;

  parameter mem_req_info_t mem_req_info_rst = '0;

  mem_req_info_t mem_req_info_list [mem_port_cnt];
  fetch_port_idx_t head_fetch_req_idx;

  fetch_port_idx_t new_fetch_cnt;
  mem_req_info_t n_mem_req_info_list [mem_port_cnt];
  always @(*) begin
    int i, j;
    fetch_port_idx_t cur_idx;
    for (i = 0; i < mem_port_cnt; i++) begin
      n_mem_req_info_list[i] = mem_req_info_list[i];
    end
    new_fetch_cnt = 0;
    for (i = 0; i < fetch_port_cnt; i++) begin
      cur_idx = (head_fetch_req_idx + i) % fetch_port_cnt;
      if (fetch_req[cur_idx].valid) begin
        for (j = 0; j < mem_port_cnt; j++) begin
          if (n_mem_req_info_list[j].valid == 0) begin
            n_mem_req_info_list[j].fetch_idx = cur_idx;
            n_mem_req_info_list[j].valid     = 1;
            new_fetch_cnt++;
          end
        end
      end
    end
  end

  always @(*) begin
    int i;
    for (i = 0; i < mem_port_cnt; i++) begin
      if (n_mem_req_info_list[i].valid) begin
        mem_req[i].addr = fetch_req[n_mem_req_info_list[i].fetch_idx].pc;
        mem_req[i].size = sys::inst_size;
      end
    end
  end

  always @(posedge clk) begin
    int i;
    if (rst) begin
      for (i = 0; i < fetch_port_cnt; i++) begin
        fetch_rsp[i] <= core::inst_fetch_rsp_rst;
      end
      for (i = 0; i < mem_port_cnt; i++) begin
        mem_req_info_list[i] <= mem_req_info_rst;
      end
      head_fetch_req_idx <= '0;
    end else if (en) begin
      for (i = 0; i < mem_port_cnt; i++) begin
        mem_req_info_list[i] <= n_mem_req_info_list[i];
      end
      for (i = 0; i < mem_port_cnt; i++) begin
        if (mem_req_info_list[i].valid) begin
          if (mem_rsp[i].done) begin
            fetch_rsp[mem_req_info_list[i].fetch_idx].inst <= mem_rsp[i].data;
            fetch_rsp[mem_req_info_list[i].fetch_idx].done <= 1;
            mem_req_info_list[i].valid <= 0;
          end else begin
            fetch_rsp[mem_req_info_list[i].fetch_idx].done <= 0;
          end
        end
      end
      head_fetch_req_idx <= (head_fetch_req_idx + new_fetch_cnt) % fetch_port_cnt;
    end
  end

endmodule
