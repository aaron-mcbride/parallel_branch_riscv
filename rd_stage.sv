`include "common.sv"

`ifndef __RD_STAGE_SV__
`define __RD_STAGE_SV__

// Read stage module
module rd_stage (
  input logic clk,
  input logic rst,
  input logic en,
  input logic next_rdy,
  input core::id_rd_t id_rd,
  input bool rs1_use_flag,
  input bool rs2_use_flag,
  input core::rf_read_rsp_t rs1_rf_read_rsp,
  input core::rf_read_rsp_t rs2_rf_read_rsp,
  output core::rf_read_req_t rs1_rf_read_req,
  output core::rf_read_req_t rs2_rf_read_req,
  output core::rd_ex_t rd_ex,
  output logic rdy,
);

  // Ready flag logic
  assign rdy = en && next_rdy && 
      (!rs1_rf_read_req.en || rs1_rf_read_rsp.done) &&
      (!rs2_rf_read_req.en || rs2_rf_read_rsp.done);

  // RS1 register file read request logic
  assign rs1_rf_read_req.addr = id_rd.de_inst.rs1;
  assign rs1_rf_read_req.en   = en && id_rd.valid && 
      !rs1_use_flag && id_rd.de_inst.has_rs1 && !rst;
  
  // RS2 register file read request logic
  assign rs2_rf_read_req.addr = id_rd.de_inst.rs2;
  assign rs2_rf_read_req.en   = en && id_rd.valid &&
      !rs2_use_flag && id_rd.de_inst.has_rs2 && !rst;
  
  // Pipeline register update logic
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      rd_ex <= core::rd_ex_rst;
    end else if (next_rdy) begin
      rd_ex.inst      <= id_rd.inst;
      rd_ex.pc        <= id_rd.pc;
      rd_ex.de_inst   <= id_rd.de_inst;
      rd_ex.rs1_value <= rs1_rf_read_rsp.value;
      rd_ex.rs2_value <= rs2_rf_read_rsp.value;     
      rd_ex.valid     <= en && id_rd.valid &&
          (!rs1_rf_read_req.en || rs1_rf_read_rsp.valid) &&
          (!rs2_rf_read_req.en || rs2_rf_read_rsp.valid);
    end
  end

endmodule

`endif // __RD_STAGE_SV__