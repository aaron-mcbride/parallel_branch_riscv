`include "branch_pred.sv"
`include "common.sv"
`include "core_dbg.sv"
`include "ex_stage.sv"
`include "hzd_unit.sv"
`include "id_stage.sv"
`include "if_stage.sv"
`include "mem_stage.sv"
`include "pipe_manager.sv"
`include "regfile.sv"
`include "sys_mem.sv"
`include "targ_pred.sv"
`include "wb_stage.sv"

`ifndef __CORE_TOP_SV__
`define __CORE_TOP_SV__

module core_top (
  input logic clk,
  input bool rst,
  input bool en
);

  localparam int sys_mem_size   = 1024;
  localparam string sys_mem_mif = "null";

  localparam int start_pc = 32'h00000000;

  localparam bool core_dbg_enable_output = true;
  localparam int core_dbg_stop_freq      = 10;

  localparam int targ_pred_table_size = 32;
  localparam int targ_pred_prune_freq = 4;

  localparam int branch_pred_table_cnt       = 2;
  localparam int branch_pred_table_size      = 32;
  localparam int branch_pred_eval_alt_thresh = 4;

  core::branch_pred_req_t branch_pred_req [core::peval_width];
  core::branch_pred_rsp_t branch_pred_rsp [core::peval_width];
  core::branch_pred_fb_t branch_pred_fb;

  core::targ_pred_req_t targ_pred_req [core::peval_width];
  core::targ_pred_rsp_t targ_pred_rsp [core::peval_width];
  core::targ_pred_fb_t targ_pred_fb;

  core::if_id_t if_id_in [core::peval_width ** 2];
  core::if_id_t if_id_out [core::peval_width];
  core::id_ex_t id_ex_in [core::peval_width];
  core::id_ex_t id_ex_out;
  core::ex_mem_t ex_mem;
  core::mem_wb_t mem_wb;

  sys::addr_t if_pc [core::peval_width ** 2];

  bool hzd_unit_ex_stall;

  bool pipe_manager_if_en [core::peval_width ** 2];
  bool pipe_manager_if_rst [core::peval_width ** 2];

  bool pipe_manager_id_en [core::peval_width];
  bool pipe_manager_id_rst [core::peval_width];

  bool if_rdy [core::peval_width ** 2];
  bool if_en [core::peval_width ** 2];
  bool if_rst [core::peval_width ** 2];
  
  bool id_rdy [core::peval_width];
  bool id_en [core::peval_width];
  bool id_rst [core::peval_width];

  bool ex_rdy;
  bool ex_en;
  bool ex_rst;

  bool mem_rdy;
  bool mem_en;
  bool mem_rst;
  
  bool wb_rdy;
  bool wb_en;
  bool wb_rst;

  core::rf_read_req_t rf_read_req [core::peval_width];
  core::rf_read_rsp_t rf_read_rsp [core::peval_width];

  core::rf_write_req_t rf_write_req;
  core::rf_write_rsp_t rf_write_rsp;

  core::mem_read_req_t inst_read_req [core::peval_width ** 2];
  core::mem_read_rsp_t inst_read_rsp [core::peval_width ** 2];
  
  core::mem_read_req_t data_read_req;
  core::mem_read_rsp_t data_read_rsp;

  core::mem_write_req_t data_write_req;
  core::mem_write_rsp_t data_write_rsp;

  core::mem_read_req_t concat_read_req;
  core::mem_read_rsp_t concat_read_rsp;

  core::mem_write_req_t concat_write_req;
  core::mem_write_rsp_t concat_write_rsp; 

  core::reg_fwd_t ex_reg_fwd;
  core::reg_fwd_t mem_reg_fwd;

  sys_mem #(
    .size(sys_mem_size),
    .read_port_cnt((core::peval_width ** 2) + 1),
    .write_port_cnt(1),
    .mif(sys_mem_mif)
  ) sys_mem_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .read_req(concat_read_req),
    .write_req(concat_write_req),
    .read_rsp('{inst_read_rsp, data_read_rsp}),
    .write_rsp(data_write_rsp)
  );

  regfile #(
    .read_port_cnt(core::peval_width),
    .write_port_cnt(1)
  ) regfile_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .read_req(rf_read_req),
    .write_req(rf_write_req),
    .read_rsp(rf_read_rsp)
  );

  targ_pred #(
    .table_size(targ_pred_table_size),
    .prune_freq(targ_pred_prune_freq)
  ) targ_pred_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .targ_pred_fb(targ_pred_fb),
    .targ_pred_req(targ_pred_req),
    .targ_pred_rsp(targ_pred_rsp)
  );

  branch_pred #(
    .table_cnt(branch_pred_table_cnt),
    .table_size(branch_pred_table_size),
    .eval_alt_thresh(branch_pred_eval_alt_thresh)
  ) branch_pred_inst (
    .clk(clk),
    .rst(rst),
    .en(en),
    .branch_pred_fb(branch_pred_fb),
    .branch_pred_req(branch_pred_req),
    .branch_pred_rsp(branch_pred_rsp)
  );

  hzd_unit hzd_unit_inst (
    .id_ex(id_ex_out),
    .ex_mem(ex_mem),
    .mem_wb(mem_wb),
    .ex_reg_fwd(ex_reg_fwd),
    .mem_reg_fwd(mem_reg_fwd),
    .ex_stall(hzd_unit_ex_stall)
  );

  pipe_manager #(
    .start_pc(start_pc)
  ) pipe_manager_inst (
    .clk(clk),
    .rst(rst),
    .if_id_in(if_id_in),
    .id_ex_in(id_ex_in),
    .ex_mem(ex_mem),
    .targ_pred_rsp(targ_pred_rsp),
    .branch_pred_rsp(branch_pred_rsp),
    .if_id_out(if_id_out),
    .id_ex_out(id_ex_out),
    .targ_pred_req(targ_pred_req),
    .branch_pred_req(branch_pred_req),
    .targ_pred_fb(targ_pred_fb),
    .branch_pred_fb(branch_pred_fb),
    .if_pc(if_pc),
    .if_en(pipe_manager_if_en),
    .if_rst(pipe_manager_if_rst),
    .id_en(pipe_manager_id_en),
    .id_rst(pipe_manager_id_rst)
  );

  generate
    genvar i;
    for (i = 0; i < (core::peval_width ** 2); i++) begin
      if_stage if_stage_inst (
        .clk(clk),
        .rst(if_rst[i]),
        .en(if_en[i]),
        .next_rdy(id_rdy[i / core::peval_width]),
        .pc(if_pc[i]),
        .inst_read_rsp(inst_read_rsp[i]),
        .inst_read_req(inst_read_req[i]),
        .if_id(if_id_en[i]),
        .rdy(if_rdy[i])
      );
    end
  endgenerate

  generate
    genvar i;
    for (i = 0; i < core::peval_width; i++) begin
      id_stage id_stage_inst (
        .clk(clk),
        .rst(id_rst[i]),
        .en(id_en[i]),
        .next_rdy(ex_rdy),
        .if_id(if_id_out[i]),
        .rf_read_rsp(rf_read_rsp[i]),
        .id_ex(id_ex_in[i]),
        .rf_read_req(rf_read_req[i]),
        .rdy(id_rdy[i])
      );
    end
  endgenerate

  ex_stage ex_stage_inst (
    .clk(clk),
    .rst(ex_rst),
    .en(ex_en),
    .next_rdy(mem_rdy),
    .reg_fwd(ex_reg_fwd),
    .id_ex(id_ex_out),
    .ex_mem(ex_mem),
    .rdy(ex_rdy)
  );

  mem_stage mem_stage_inst (
    .clk(clk),
    .rst(mem_rst),
    .en(mem_en),
    .next_rdy(wb_rdy),
    .ex_mem(ex_mem),
    .reg_fwd(mem_reg_fwd),
    .mem_read_rsp(data_read_rsp),
    .mem_write_rsp(data_write_rsp),
    .mem_read_req(data_read_req),
    .mem_write_req(data_write_req),
    .mem_wb(mem_wb),
    .rdy(mem_rdy)
  );

  wb_stage wb_stage_inst (
    .clk(clk),
    .rst(wb_rst),
    .en(wb_en),
    .mem_wb(mem_wb),
    .rf_write_req(rf_write_req),
    .rdy(wb_rdy)
  );

  core_dbg #(
    .enable_output(core_dbg_enable_output),
    .stop_freq(core_dbg_stop_freq)
  ) core_dbg_inst (
    .clk(clk),
    .if_id_in(if_id_in),
    .id_ex_in(id_ex_in),
    .ex_mem(ex_mem),
    .mem_wb(mem_wb),
    .ex_reg_fwd(ex_reg_fwd),
    .mem_reg_fwd(mem_reg_fwd)
  );

  always @(*) begin
    int i;
    for (i = 0; i < (core::peval_width ** 2); i++) begin
      if_en[i]  = pipe_manager_if_en[i]  && en;
      if_rst[i] = pipe_manager_if_rst[i] || rst;
    end
  end

  always @(*) begin
    int i;
    for (i = 0; i < core::peval_width; i++) begin
      id_en[i]  = pipe_manager_id_en[i]  && en;
      id_rst[i] = pipe_manager_id_rst[i] || rst;
    end
  end

  assign ex_en  = en && !hzd_unit_ex_stall;
  assign ex_rst = rst;

  assign mem_en  = en;
  assign mem_rst = rst;

  assign wb_en  = en;
  assign wb_rst = rst;

endmodule

`endif // __CORE_TOP_SV__