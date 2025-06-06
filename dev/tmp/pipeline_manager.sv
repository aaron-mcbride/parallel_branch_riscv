`include "common.sv"

`ifndef __PIPELINE_MANAGER_SV__
`define __PIPELINE_MANAGER_SV__

// Speculative pipeline manager module. Manages parallel speculative
// pipelines up to memory stage. Outputs PC addresses, enable signals
// and reset (flush) signals.
module s_pipe_manager #(
  parameter int s_pipe_cnt       = 3,                          // Number of parallel speculative pipes
  parameter sys::addr_t start_pc = 0                           // Starting PC address
) (
  input logic clk,                                             // Clock signal
  input bool_t rst,                                              // Reset signal
  input bool_t en,                                               // Enable signal
  input core::if_id_t if_id [s_pipe_cnt],                      // Fetch stage registers from all s-pipes
  input core::id_ex_t ex_mem [s_pipe_cnt],                     // Execute stage registers from all s-pipes
  input bool_t mem_rdy,                                          // Memory stage ready signal
  input core::targ_pred_rsp_t targ_pred_rsp [s_pipe_cnt],      // Target predictor response structs
  input core::branch_pred_rsp_t branch_pred_rsp [s_pipe_cnt],  // Branch predictor response structs
  output core::targ_pred_req_t targ_pred_req [s_pipe_cnt],     // Target predictor request structs
  output core::branch_pred_req_t branch_pred_req [s_pipe_cnt], // Branch predictor request structs
  output core::targ_pred_fb_t targ_pred_fb,                    // Target predictor feedback struct
  output core::branch_pred_fb_t branch_pred_fb,                // Branch predictor feedback struct
  output core::ex_mem_t ex_mem_out,                            // Execute stage register from non-speculative s-pipe
  output sys::addr_t s_pipe_pc [s_pipe_cnt],                   // Current PC values for all s-pipes
  output bool_t s_pipe_en [s_pipe_cnt],                          // Enable signals for all s-pipes
  output bool_t s_pipe_rst [s_pipe_cnt]                          // Reset (flush) signals for all s-pipes
);

  // Numeric types based on number of s-pipes
  typedef logic [($clog2(s_pipe_cnt) - 1):0] s_pipe_id_t;
  typedef logic [(s_pipe_cnt - 1):0] s_pipe_mask_t;

  // Struct containing information about an s-pipe
  typedef struct packed {
    s_pipe_mask_t mask;
    sys::addr_t base_pc;
    bool_t active;
  } s_pipe_info_t;

  // Value to reset s-pipe info structs to
  parameter s_pipe_info_t s_pipe_info_rst = '0;

  // Registers for s-pipe management logic
  s_pipe_info_t s_pipe_info [s_pipe_cnt];
  s_pipe_id_t head_s_pipe_id;

  // Signals for s-pipe management logic
  s_pipe_info_t next_s_pipe_info [s_pipe_cnt];
  s_pipe_id_t next_head_s_pipe_id;
  bool_t init_found_flag;
  bool_t eval_found_flag;

  // Non-speculative output from execute stage
  assign ex_mem_out = ex_mem[head_s_pipe_id];

  // Asynchronous s-pipe management logic
  always @(*) begin
    eval_found_flag = false;
    next_head_s_pipe_id = head_s_pipe_id;
    for (int i = 0; i < s_pipe_cnt; i++) begin
      next_s_pipe_info[i] = s_pipe_info[i];
      targ_pred_req[i] = core::targ_pred_req_rst;
      branch_pred_req[i] = core::branch_pred_req_rst;
      targ_pred_fb = core::targ_pred_fb_rst;
      branch_pred_fb = core::branch_pred_fb_rst;
      s_pipe_pc[i] = if_id[i].pc;
      s_pipe_en[i] = false;
      s_pipe_rst[i] = false;
    end

    // Logic for handling evaluated branch/jump instructions
    if ((ex_mem[head_s_pipe_id].de_inst.opcode == rv32i::opcode_branch ||
        ex_mem[head_s_pipe_id].de_inst.opcode == rv32i::opcode_jalr) && 
        ex_mem[head_s_pipe_id].valid && mem_rdy) begin
      case (ex_mem[head_s_pipe_id].de_inst.opcode)
        rv32i::opcode_branch: begin
          branch_pred_fb.base_pc = ex_mem[head_s_pipe_id].pc;
          branch_pred_fb.targ_pc = ex_mem[head_s_pipe_id].ex_addr;
          branch_pred_fb.taken = ex_mem[head_s_pipe_id].ex_result;
          branch_pred_fb.valid = true;
        end
        rv32i::opcode_jalr: begin
          targ_pred_fb.base_pc = ex_mem[head_s_pipe_id].pc;
          targ_pred_fb.targ_pc = ex_mem[head_s_pipe_id].ex_addr;
          targ_pred_fb.valid = true;
        end
      endcase
      for (int i = 0; i < s_pipe_cnt; i++) begin
        init_found_flag = false;
        if ((next_s_pipe_info[i].base_pc == ex_mem[head_s_pipe_id].ex_addr) &&
            !eval_found_flag && next_s_pipe_info[i].active) begin
          next_head_s_pipe_id = i;
          eval_found_flag = true;
          for (int j = 0; j < s_pipe_cnt; j++) begin
            if (next_s_pipe_info[j].active) begin
              if ((next_s_pipe_info[j].mask & next_s_pipe_info[i].mask) == 
                  next_s_pipe_info[i].mask) begin
                if (next_head_s_pipe_id != head_s_pipe_id) begin
                  next_s_pipe_info[j].mask = next_s_pipe_info[j].mask & 
                      ~s_pipe_info[head_s_pipe_id].mask;
                end
              end else begin
                next_s_pipe_info[j] = s_pipe_info_rst;
                s_pipe_rst[j] = true;
              end
            end
          end
        end
      end
      if (!eval_found_flag) begin
        for (int i = 0; i < s_pipe_cnt; i++) begin
          next_s_pipe_info[i] = s_pipe_info_rst;
        end
        next_head_s_pipe_id = 0;
        next_s_pipe_info[0].mask = 1;
        next_s_pipe_info[0].base_pc = ex_mem[head_s_pipe_id].ex_addr;
        next_s_pipe_info[0].active = true;
      end
    end

    // Management logic for active s-pipes (init, enable, flush etc...)
    for (int i = 0; i < s_pipe_cnt; i++) begin
      if (next_s_pipe_info[i].active) begin
        s_pipe_en[i] = true;
        if (if_id[i].valid) begin
          s_pipe_pc[i] = if_id[i].pc + (sys::addr_width / 8);
          case (rv32i::get_opcode(if_id[i].inst))
            rv32i::opcode_branch: begin
              branch_pred_req[i].base_pc = if_id[i].pc;
              branch_pred_req[i].targ_pc = if_id[i].pc + rv32i::get_imm_b(if_id[i].inst);
              branch_pred_req[i].valid = true;
              if (branch_pred_rsp[i].pred_taken) begin
                s_pipe_pc[i] = if_id[i].pc + rv32i::get_imm_b(if_id[i].inst);
              end
              if (branch_pred_rsp[i].exec_alt) begin
                for (int j = 0; j < s_pipe_cnt; j++) begin
                  if (j != i && !next_s_pipe_info[j].active && !init_found_flag) begin
                    next_s_pipe_info[j].mask = next_s_pipe_info[i].mask | (1 << j);
                    if (branch_pred_rsp[i].pred_taken) begin
                      next_s_pipe_info[j].base_pc = if_id[i].pc + (sys::addr_width / 8);
                    end else begin
                      next_s_pipe_info[j].base_pc = if_id[i].pc + rv32i::get_imm_b(if_id[i].inst);
                    end
                    next_s_pipe_info[j].active = true;
                    s_pipe_pc[j] = next_s_pipe_info[j].base_pc;
                    s_pipe_en[j] = true;
                    init_found_flag = true;
                  end
                end
              end
            end
            rv32i::opcode_jalr: begin
              targ_pred_req[i].base_pc = if_id[i].pc;
              targ_pred_req[i].valid = true;
              if (targ_pred_rsp[i].pred_cnt > 0) begin
                s_pipe_pc[i] = targ_pred_rsp[i].pred_pc[0];
                for (int j = 1; j < targ_pred_rsp[i].pred_cnt; j++) begin
                  for (int k = 0; k < s_pipe_cnt; k++) begin
                    if (k != i && !next_s_pipe_info[k].active && !init_found_flag) begin
                      next_s_pipe_info[k].mask = next_s_pipe_info[i].mask | (1 << k);
                      next_s_pipe_info[k].base_pc = targ_pred_rsp[i].pred_pc[j];
                      next_s_pipe_info[k].active = true;
                      s_pipe_pc[k] = next_s_pipe_info[k].base_pc;
                      s_pipe_en[k] = true;
                      init_found_flag = true;
                    end
                  end
                end
              end
            end
            rv32i::opcode_jal: begin
              s_pipe_pc[i] = if_id[i].pc + rv32i::get_imm_j(if_id[i].inst);
            end
          endcase
        end
      end
    end
  end
  
  // Update logic for s pipe info struct registers
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      s_pipe_info[0].mask = 1;
      s_pipe_info[0].base_pc = start_pc;
      s_pipe_info[0].active = true;
      for (int i = 1; i < s_pipe_cnt; i++) begin
        s_pipe_info[i] <= s_pipe_info_rst;
      end
    end else if (en) begin
      head_s_pipe_id <= next_head_s_pipe_id;
      for (int i = 0; i < s_pipe_cnt; i++) begin
        s_pipe_info[i] <= next_s_pipe_info[i];
      end
    end
  end

endmodule

`endif // __PIPELINE_MANAGER_SV__