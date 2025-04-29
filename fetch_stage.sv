`include "common.sv"

`ifndef __FETCH_STAGE_SV__
`define __FETCH_STAGE_SV__

module fetch_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input bool next_rdy,
  input rv32i::addr_t pc,
  input sys::mem_read_rsp_t inst_read_rsp,
  output sys::mem_read_req_t inst_read_req,
  output core::if_id_t if_id,
  output bool rdy
);

  // Ready flag logic
  assign rdy = next_rdy && inst_read_rsp.done;

  // Instruction read request logic
  assign inst_read_req.addr = pc;
  assign inst_read_req.mask = '{(rv32i::inst_width/8){1'b1}};
  assign inst_read_req.en = en && !rst;
  
  // Pipeline register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      if_id <= core::if_id_rst;
    end else if (next_rdy) begin
      if_id.pc <= pc;
      if_id.inst <= inst_read_rsp.data;
      if_id.valid <= en && inst_read_rsp.done && inst_read_rsp.valid;
    end
  end

endmodule

`endif // __FETCH_STAGE_SV__