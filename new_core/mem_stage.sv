`include "common.sv"

`ifndef __MEM_STAGE_SV__
`define __MEM_STAGE_SV__

// Memory stage module
module mem_stage (
  input logic clk,                           // Clock signal
  input bool rst,                            // Reset signal
  input bool en,                             // Enable signal
  input bool next_rdy,                       // Next stage ready signal
  input core::ex_mem_t ex_mem,               // Stage input registers
  input core::reg_fwd_t reg_fwd,             // Forwarded register values
  input sys::mem_read_rsp_t mem_read_rsp,    // Memory read response
  input sys::mem_write_rsp_t mem_write_rsp,  // Memory write response
  output sys::mem_read_req_t mem_read_req,   // Memory read request
  output sys::mem_write_req_t mem_write_req, // Memory write request
  output core::mem_wb_t mem_wb,              // Stage output registers
  output bool rdy                            // Stage ready signal
);

  assign rdy = en && next_rdy && 
      (!mem_read_req.en  || mem_read_rsp.done) &&
      (!mem_write_req.en || mem_write_rsp.done);

  always @(*) begin
    mem_read_req = sys::mem_read_req_rst;
    if (ex_mem.de_inst.opcode == rv32i::opcode_load) begin
      mem_read_req.en = '1;
      case (ex_mem.de_inst.funct3)
        rv32i::funct3_load_lb, rv32i::funct3_load_lbu: begin
          mem_read_req.size = '1;
        end
        rv32i::funct3_load_lh, rv32i::funct3_load_lhu: begin
          mem_read_req.size = '2;
        end
        rv32i::funct3_load_lw: begin
          mem_read_req.size = '4;
        end
      endcase
      mem_read_req.addr = reg_fwd.rs1_value + ex_mem.de_inst.imm;
      mem_read_req.addr -= mem_read_req.addr % mem_read_req.size;
    end
  end

  always @(*) begin
    mem_write_req = sys::mem_write_req_rst;
    if (ex_mem.de_inst.opcode == rv32i::opcode_store) begin
      mem_write_req.en = '1;
      case (ex_mem.de_inst.funct3)
        rv32i::funct3_store_sb: begin
          mem_write_req.size = '1;
        end
        rv32i::funct3_store_sh: begin
          mem_write_req.size = '2;
        end
        rv32i::funct3_store_sw: begin
          mem_write_req.size = '4;
        end
      endcase
      mem_write_req.addr = reg_fwd.rs1_value + ex_mem.de_inst.imm;
      mem_write_req.addr -= mem_write_req.addr % mem_write_req.size;
      mem_write_req.data = reg_fwd.rs2_value;
    end
  end

  rv32i::reg_t n_mem_result;
  always @(*) begin
    n_mem_result = '0;
    if (ex_mem.de_inst.opcode == rv32i::opcode_load) begin
      case (ex_mem.de_inst.funct3)
        rv32i::funct3_load_lb: begin
          n_mem_result = util::sext(mem_read_rsp.data, sys::byte_width);
        end
        rv32i::funct3_load_lh: begin
          n_mem_result = util::sext(mem_read_rsp.data, sys::half_word_width);
        end
        default: begin
          n_mem_result = mem_read_rsp.data;
        end
      endcase
    end
  end

  core::mem_wb_t n_mem_wb;
  always @(*) begin
    n_mem_wb = mem_wb;
    if (rst) begin
      n_mem_wb = core::mem_wb_rst;
    end else if (next_rdy) begin
      n_mem_wb.pc         = ex_mem.pc;
      n_mem_wb.inst       = ex_mem.inst;
      n_mem_wb.de_inst    = ex_mem.de_inst;
      n_mem_wb.rs1_value  = ex_mem.rs1_value;
      n_mem_wb.rs2_value  = ex_mem.rs2_value;
      n_mem_wb.ex_result  = ex_mem.ex_result;
      n_mem_wb.ex_addr    = ex_mem.ex_addr;
      n_mem_wb.mem_result = n_mem_result;
      n_mem_wb.valid      = en && ex_mem.valid &&
          (!mem_read_req.en  || mem_read_rsp.done) &&
          (!mem_write_req.en || mem_write_rsp.done);
    end
  end

  always @(posedge clk) begin
    mem_wb <= n_mem_wb;
  end

endmodule

`endif // __MEM_STAGE_SV__
