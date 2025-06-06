`include "common.sv"

`ifndef __PIPE_MANAGER_SV__
`define __PIPE_MANAGER_SV__

import bool_type::*;

module pipe_manager #(
  parameter sys::addr_t start_pc = '0 // Starting PC address
) (
  input logic clk,                                                    // Clock signal
  input bool_t rst,                                                   // Reset signal
  input core::if_id_t if_id_in [core::peval_width ** 2],              // IF stage registers
  input core::id_ex_t id_ex_in [core::peval_width],                   // ID stage registers
  input core::ex_mem_t ex_mem,                                        // EX stage registers
  input core::targ_pred_rsp_t targ_pred_rsp [core::peval_width],      // Target prediction responses
  input core::branch_pred_rsp_t branch_pred_rsp [core::peval_width],  // Branch prediction responses
  output core::if_id_t if_id_out [core::peval_width],                 // IF stage output registers
  output core::id_ex_t id_ex_out,                                     // ID stage output registers
  output core::targ_pred_req_t targ_pred_req [core::peval_width],     // Target prediction requests
  output core::branch_pred_req_t branch_pred_req [core::peval_width], // Branch prediction requests
  output core::targ_pred_fb_t targ_pred_fb,                           // Target prediction feedback
  output core::branch_pred_fb_t branch_pred_fb,                       // Branch prediction feedback
  output sys::addr_t if_pc [core::peval_width ** 2],                  // IF stage PC addresses
  output bool_t if_en [core::peval_width ** 2],                       // IF stage enable signals
  output bool_t if_rst [core::peval_width ** 2],                      // IF stage reset signals
  output bool_t id_en [core::peval_width],                            // ID stage enable signals
  output bool_t id_rst [core::peval_width]                            // ID stage reset signals
);

  core::peval_idx_t peval_idx;

  bool_t targ_found;
  bool_t eval_flag;
  core::peval_idx_t n_peval_idx;
  always @(*) begin
    int i, j;
    eval_flag   = false;
    targ_found  = false;
    n_peval_idx = peval_idx;
    if (rst) begin
      n_peval_idx = '0;
    end else if (ex_mem.valid && (
        (ex_mem.de_inst.opcode == rv32i::opcode_branch) ||
        (ex_mem.de_inst.opcode == rv32i::opcode_jalr)   ||
        (ex_mem.de_inst.opcode == rv32i::opcode_jal))) begin
      eval_flag = true;
      for (i = 0; i < core::peval_width; i++) begin
        if (!targ_found) begin
          if (id_ex[i].valid) begin
            if (id_ex[i].de_inst.pc == ex_mem.ex_addr) begin
              targ_found  = true;
              n_peval_idx = i;
            end
          end else begin
            for (j = 0; j < core::peval_width; j++) begin
              if (if_id_in[(i * core::peval_width) + j].valid &&
                 (if_id_in[(i * core::peval_width) + j].pc == ex_mem.ex_addr)) begin
                targ_found  = true;
                n_peval_idx = i;
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    int i;
    id_ex_out = id_ex_in[n_peval_idx];
    for (i = 0; i < core::peval_width; i++) begin
      if_id_out[i] = if_id_in[(n_peval_idx * core::peval_width) + i];
    end
  end

  core::targ_pred_fb_t n_targ_pred_fb;
  core::branch_pred_fb_t n_branch_pred_fb;
  always @(*) begin
    int i;
    n_targ_pred_fb   = core::targ_pred_fb_rst;
    n_branch_pred_fb = core::branch_pred_fb_rst;
    if (!rst && ex_mem.valid) begin
      case (ex_mem.de_inst.opcode)
        rv32i::opcode_branch: begin
          n_branch_pred_fb.valid        = true;
          n_branch_pred_fb.base_pc      = ex_mem.pc;
          n_branch_pred_fb.targ_pc      = ex_mem.ex_addr;
          n_branch_pred_fb.branch_taken = ex_mem.ex_result;
        end
        rv32i::opcode_jalr: begin
          n_targ_pred_fb.valid   = true;
          n_targ_pred_fb.base_pc = ex_mem.pc;
          n_targ_pred_fb.targ_pc = ex_mem.ex_addr;
        end
      endcase
    end
  end

  always @(*) begin
    int i, j;
    bool_t id_valid;
    core::if_idx_t base_if_idx;
    for (i = 0; i < core::peval_width; i++) begin
      id_valid  = eval_flag && (i == n_peval_idx);
      id_rst[i] = !id_valid;
      id_en[i]  = id_valid;
    end
    for (i = 0; i < (core::peval_width ** 2); i++) begin
      if_rst[i] = true;
      if_en[i]  = false;
      if_pc[i]  = '0;
    end
    if (rst) begin
      if_pc[0] = util::align_inst(start_pc);
      if_en[0] = true;
    end else if (eval_flag && !targ_found) begin
      if_rst[0] = false;
      if_en[0]  = true;
      if_pc[0]  = ex_mem.ex_addr;
    end else begin
      for (i = 0; i < core::peval_width; i++) begin
        base_if_idx = i * core::peval_width;
        if (if_id_out[i].valid && (!eval_flag || 
            ((base_if_idx / core::peval_width) != n_peval_idx))) begin
          case (rv32i::get_opcode(if_id_out[i].inst))
            rv32i::opcode_branch: begin
              branch_pred_req[i].base_pc = if_id_out[i].pc;
              if_rst[base_if_idx] = false;
              if_en[base_if_idx]  = true;
              if_pc[base_if_idx]  = util::align_inst(
                branch_pred_rsp[i].branch_taken ? 
                (if_id_out[i].pc + rv32i::get_imm_b(if_id_out[i].inst)) : 
                (if_id_out[i].pc + sys::inst_size));
              if ((core::peval_width > 1) && branch_pred_rsp[i].eval_alt) begin
                if_rst[base_if_idx + 1] = false;
                if_en[base_if_idx + 1]  = true;
                if_pc[base_if_idx + 1]  = util::align_inst(
                  branch_pred_rsp[i].branch_taken ? 
                  (if_id_out[i].pc + sys::inst_size) : 
                  (if_id_out[i].pc + rv32i::get_imm_b(if_id_out[i].inst)));
              end
            end
            rv32i::opcode_jalr: begin
              targ_pred_req[i].base_pc = if_id_out[i].pc;
              for (j = 0; j < core::peval_width; j++) begin
                if (j < targ_pred_rsp[i].targ_cnt) begin
                  if_rst[base_if_idx + j] = false;
                  if_en[base_if_idx + j]  = true;
                  if_pc[base_if_idx + j]  = targ_pred_rsp[i].targ_list[j];
                end
              end
            end
            rv32i::opcode_jal: begin
              if_rst[base_if_idx] = false;
              if_en[base_if_idx]  = true;
              if_pc[base_if_idx]  = util::align_inst(
                  if_id_out[i].pc + rv32i::get_imm_j(if_id_out[i].inst));
            end
            default: begin
              if_rst[base_if_idx] = false;
              if_en[base_if_idx]  = true;
              if_pc[base_if_idx]  = if_id_out[i].pc + sys::inst_size;
            end
          endcase
        end
      end
    end
  end

  always @(posedge clk) begin
    branch_pred_fb <= n_branch_pred_fb;
    targ_pred_fb   <= n_targ_pred_fb;
    peval_idx      <= n_peval_idx;
  end

endmodule

`endif // __PIPE_MANAGER_SV_