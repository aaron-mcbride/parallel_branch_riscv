`include "core_dbg.sv"
`include "../src/core_top.sv"

`ifndef __CORE_TB_SV__
`define __CORE_TB_SV__

`timescale 1ns / 1ps

// TEMPORARY
`define EN_DBG_MODULE

// Path to system memory initialization file (hex)
`ifndef SYS_MEM_MIF
  `define SYS_MEM_MIF "null"
`endif

// Size of system memory in bytes
`ifndef SYS_MEM_SIZE
  `define SYS_MEM_SIZE 100000
`endif

// Size of instruction cache
`ifndef INST_CACHE_SIZE
  `define INST_CACHE_SIZE 64
`endif

// Starting program counter value
`ifndef START_PC
  `define START_PC 0
`endif

// Target prediction table size
`ifndef TARG_PRED_TABLE_SIZE
  `define TARG_PRED_TABLE_SIZE 32
`endif

// Frequency at which target prediction table is pruned
`ifndef TARG_PRED_PRUNE_FREQ
  `define TARG_PRED_PRUNE_FREQ 4
`endif

// Branch prediction table count
`ifndef BRANCH_PRED_TABLE_CNT
  `define BRANCH_PRED_TABLE_CNT 2
`endif

// Size of each branch prediction table
`ifndef BRANCH_PRED_TABLE_SIZE
  `define BRANCH_PRED_TABLE_SIZE 32
`endif

// Threshold for alternative evaluation in branch prediction
`ifndef BRANCH_PRED_EVAL_ALT_THRESH
  `define BRANCH_PRED_EVAL_ALT_THRESH 4
`endif

// Core testbench module
module core_tb;

  logic clk;
  always begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  core_top #(
    .sys_mem_mif(`SYS_MEM_MIF),
    .sys_mem_size(`SYS_MEM_SIZE),
    .inst_cache_size(`INST_CACHE_SIZE),
    .start_pc(`START_PC),
    .targ_pred_table_size(`TARG_PRED_TABLE_SIZE),
    .targ_pred_prune_freq(`TARG_PRED_PRUNE_FREQ),
    .branch_pred_table_cnt(`BRANCH_PRED_TABLE_CNT),
    .branch_pred_table_size(`BRANCH_PRED_TABLE_SIZE),
    .branch_pred_eval_alt_thresh(`BRANCH_PRED_EVAL_ALT_THRESH)
  ) core_inst (
    .clk(clk),
    .rst(1'b0),
    .en(1'b1)
  );

  `ifdef EN_DBG_MODULE

    core::if_id_t if_id_in [core::peval_width ** 2];
    core::if_id_t if_id_out [core::peval_width];
    core::id_ex_t id_ex_in [core::peval_width];
    core::id_ex_t id_ex_out;
    core::ex_mem_t ex_mem;
    core::mem_wb_t mem_wb;
    core::reg_fwd_t ex_reg_fwd;

    always @(*) begin
      int i;
      for (i = 0; i < (core::peval_width ** 2); i++) begin
        if_id_in[i] = core_inst.if_id_in[i];
      end
    end

    always @(*) begin
      int i;
      for (i = 0; i < core::peval_width; i++) begin
        if_id_out[i] = core_inst.if_id_out[i];
      end
    end

    always @(*) begin
      int i;
      for (i = 0; i < core::peval_width; i++) begin
        id_ex_in[i] = core_inst.id_ex_in[i];
      end
    end

    assign id_ex_out = core_inst.id_ex_out;
    assign ex_mem = core_inst.ex_mem;
    assign mem_wb = core_inst.mem_wb;
    assign ex_reg_fwd = core_inst.ex_reg_fwd;

    core_dbg core_dbg_inst (
      .clk(clk),
      .if_id_in(if_id_in),
      .id_ex_in(id_ex_in),
      .ex_mem(ex_mem),
      .mem_wb(mem_wb),
      .ex_reg_fwd(ex_reg_fwd)
    );

  `endif

  `ifdef STOP_FREQ

    int stop_cnt = 0;
    always @(posedge clk) begin
      stop_cnt++;
      if (stop_cnt > `STOP_FREQ) begin
        stop_cnt = 0;
        $display("Stopping simulation...");
        $stop;
      end
    end

  `endif
  
endmodule

`endif // __CORE_TB_SV__