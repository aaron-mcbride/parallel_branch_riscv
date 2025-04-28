`include "common.sv"

`ifndef __FETCH_STAGE_SV__
`define __FETCH_STAGE_SV__

module core_fetch (
  input logic clk,
  input logic rst,
  input logic en,
  input logic decode_rdy,
  input addr_t pc,
  input mem_read_rsp_t inst_read_rsp,
  output logic rdy,
  output mem_read_req_t inst_read_req,
  output if_id_t if_id
);

  // Logic for ready flag
  assign ready = en && decode_rdy && inst_read_rsp.done;

  // Logic for memory read request
  assign inst_read_req.addr = pc;
  assign inst_read_req.mask = 4'b1111;
  assign inst_read_req.en   = en;

  // ID_EX register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      if_id.inst  <= '0;
      if_id.pc    <= '0;
      if_id.valid <= '0;
    end else if (decode_rdy) begin
      if_id.inst  <= inst_read_rsp.data;
      if_id.pc    <= pc;
      if_id.valid <= en && inst_read_rsp.done && inst_read_rsp.valid;
    end
  end

endmodule

`endif // __FETCH_STAGE_SV__