`include "common.sv"

`ifndef __IF_STAGE_SV__
`define __IF_STAGE_SV__

// Instruction fetch stage module
module if_stage (
  input logic clk,                          // Clock signal
  input bool rst,                           // Reset signal
  input bool en,                            // Enable signal
  input bool next_rdy,                      // Next stage ready signal
  input rv32i::addr_t pc,                   // Current program counter
  input sys::mem_read_rsp_t inst_read_rsp,  // Instruction memory read response
  output sys::mem_read_req_t inst_read_req, // Instruction memory read request
  output core::if_id_t if_id,               // Stage output registers
  output bool rdy                           // Stage ready signal
);

  assign rdy = en && next_rdy && inst_read_rsp.done;

  assign inst_read_req.addr = pc;
  assign inst_read_req.size = sys::inst_size;
  assign inst_read_req.en   = en && !rst;
  
  core::if_id_t n_if_id;
  always @(*) begin
    n_if_id = if_id;
    if (rst) begin
      n_if_id = core::if_id_rst;
    end else if (next_rdy) begin
      n_if_id.pc        = pc;
      n_if_id.inst      = inst_read_rsp.data;
      n_if_id.valid     = en && inst_read_rsp.done;
    end
  end

  always @(posedge clk) begin
    if_id <= n_if_id;
  end

endmodule

`endif // __IF_STAGE_SV__