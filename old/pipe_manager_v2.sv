`include "common.sv"

`ifndef __PIPE_MANAGER_SV__
`define __PIPE_MANAGER_SV__

module pipe_manager #(
  
) (
  input logic clk,
  input bool rst,
  input bool en,
  input core::if_id_t parent_if_id,
  input core::id_ex_t parent_ex_mem,
  output bool free_flag,
  output sys::addr_t pipe_pc
);

  opcode_t inst_opcode;
  sys::addr_t inst_target;
  




endmodule

`endif // __PIPE_MANAGER_SV__