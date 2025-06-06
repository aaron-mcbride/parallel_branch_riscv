`include "common.sv"

`ifndef __DEBUG_SV__
`define __DEBUG_SV__

module debug #(
  parameter int s_pipe_cnt = 3,
  parameter int stop_cycles = 1,
) (
  input logic clk,
  input logic en,
  input core::if_id_t if_id [s_pipe_cnt],
  input core::id_rd_t id_rd [s_pipe_cnt],
  input core::rd_ex_t rd_ex [s_pipe_cnt],
  input core::ex_mem_t ex_mem [s_pipe_cnt],
  input core::mem_asm_t mem_asm [s_pipe_cnt],
  input core::asm_wb_t asm_wb [s_pipe_cnt]
);



endmodule

`endif // __DEBUG_SV__