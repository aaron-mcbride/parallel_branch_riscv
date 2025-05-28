`include "common.sv"

`ifndef __RD_STAGE_SV__
`define __RD_STAGE_SV__

// Read stage module
module rd_stage (
  input logic clk,                            // Clock signal
  input logic rst,                            // Reset signal
  input logic en,                             // Enable signal
  input logic next_rdy,                       // Next stage ready signal
  input core::id_rd_t id_rd,                  // Stage input registers
  input core::rf_read_rsp_t rs1_rf_read_rsp,  // Register file read response for rs1
  input core::rf_read_rsp_t rs2_rf_read_rsp,  // Register file read response for rs2
  output core::rf_read_req_t rs1_rf_read_req, // Register file read request for rs1
  output core::rf_read_req_t rs2_rf_read_req, // Register file read request for rs2
  output core::rd_ex_t rd_ex,                 // Stage output registers
  output logic rdy                            // Stage ready signal
);

  assign rdy = en && next_rdy;

  assign rs1_rf_read_req.addr = id_rd.de_inst.rs1;
  assign rs1_rf_read_req.en   = en && !rst && 
      id_rd.valid && id_rd.de_inst.has_rs1;

  assign rs2_rf_read_req.addr = id_rd.de_inst.rs2;
  assign rs2_rf_read_req.en   = en && !rst && 
      id_rd.valid && id_rd.de_inst.has_rs2;

  core::rd_ex_t n_rd_ex;
  always @(*) begin
    n_rd_ex = rd_ex;
    if (rst) begin
      n_rd_ex = core::rd_ex_rst;
    end else if (next_rdy) begin
      n_rd_ex.inst      = id_rd.inst;
      n_rd_ex.pc        = id_rd.pc;
      n_rd_ex.de_inst   = id_rd.de_inst;
      n_rd_ex.rs1_value = rs1_rf_read_rsp.value;
      n_rd_ex.rs2_value = rs2_rf_read_rsp.value;     
      n_rd_ex.valid     = en && id_rd.valid;
    end
  end

  always @(posedge clk) begin
    rd_ex <= n_rd_ex;
  end

endmodule

`endif // __RD_STAGE_SV__