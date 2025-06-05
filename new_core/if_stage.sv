`include "common.sv"

`ifndef __IF_STAGE_SV__
`define __IF_STAGE_SV__

// Instruction fetch stage module
module if_stage (
  input logic clk,                              // Clock signal
  input bool rst,                               // Reset signal
  input bool en,                                // Enable signal
  input bool next_rdy,                          // Next stage ready signal
  input rv32i::addr_t pc,                       // Current program counter
  input core::inst_fetch_rsp_t inst_fetch_rsp,  // Instruction fetch response
  output core::inst_fetch_req_t inst_fetch_req, // Instruction fetch request
  output core::if_id_t if_id,                   // Stage output registers
  output bool rdy                               // Stage ready signal
);

  assign rdy = en && next_rdy && inst_fetch_rsp.done;

  assign inst_fetch_req.addr = pc;
  assign inst_fetch_req.en   = en && !rst;

  core::if_id_t n_if_id;
  always @(*) begin
    n_if_id = if_id;
    if (rst) begin
      n_if_id = core::if_id_rst;
    end else if (next_rdy) begin
      n_if_id.pc    = pc;
      n_if_id.inst  = inst_fetch_rsp.data;
      n_if_id.valid = en && inst_fetch_rsp.done;
    end
  end

  always @(posedge clk) begin
    if_id <= n_if_id;
  end

endmodule

`endif // __IF_STAGE_SV__