`include "common.sv"

`ifndef __MEM_STAGE_SV__
`define __MEM_STAGE_SV__

// Memory stage module
module mem_stage (
  input logic clk,
  input bool rst,
  input bool en,
  input bool next_rdy,
  input core::ex_mem_t ex_mem,
  input sys::mem_read_rsp_t mem_read_rsp,
  input sys::mem_write_rsp_t mem_write_rsp,
  output sys::mem_read_req_t mem_read_req,
  output sys::mem_write_req_t mem_write_req,
  output core::mem_asm_t mem_asm,
  output bool rdy
);

  // Ready flag logic
  assign rdy = en && next_rdy && 
      (!mem_read_req.en  || mem_read_rsp.done) &&
      (!mem_write_req.en || mem_write_rsp.done);

  // Memory read request logic
  assign mem_read_req.addr = ex_mem.ex_addr;
  assign mem_read_req.mask = ex_mem.ex_mask;
  assign mem_read_req.en   = en && !rst && ex_mem.valid && 
      ex_mem.de_inst.opcode == rv32i::opcode_load;

  // Memory write request logic
  assign mem_write_req.addr = ex_mem.ex_addr;
  assign mem_write_req.mask = ex_mem.ex_mask;
  assign mem_write_req.data = ex_mem.rs2_value;
  assign mem_write_req.en   = en && !rst && ex_mem.valid &&
      ex_mem.de_inst.opcode == rv32i::opcode_store;

  // Pipeline register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      mem_asm <= core::mem_asm_rst;
    end else if (next_rdy) begin
      mem_asm.pc         <= ex_mem.pc;
      mem_asm.de_inst    <= ex_mem.de_inst;
      mem_asm.rs1_value  <= ex_mem.rs1_value;
      mem_asm.rs2_value  <= ex_mem.rs2_value;
      mem_asm.ex_result  <= ex_mem.ex_result;
      mem_asm.ex_addr    <= ex_mem.ex_addr;
      mem_asm.mem_result <= mem_read_rsp.data;
      mem_asm.rd_rdy     <= ex_mem.rd_rdy;
      mem_asm.valid      <= en && ex_mem.valid && 
          (!mem_read_req.en  || (mem_read_rsp.valid  && mem_read_rsp.done )) &&
          (!mem_write_req.en || (mem_write_rsp.valid && mem_write_rsp.done));
    end
  end

endmodule

`endif // __MEM_STAGE_SV__
