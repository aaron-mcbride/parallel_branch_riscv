/*
module core_mem (
  input logic clk,
  input logic rst,
  input logic enable,
  input ex_mem_t ex_mem,
  input reg_t fwd_ex_rs2,
  input logic wb_ready,
  input data_mem_rsp_t data_mem_rsp,
  output data_mem_req_t data_mem_req,
  output mem_wb_t mem_wb,
  output logic ready
);

  assign ready = enable && wb_ready && data_mem_rsp.done;

  always @(*) begin
    data_mem_req = DATA_MEM_REQ_RST;
    if (enable && ex_mem.valid) begin
      case (ex_mem.opcode)
        OPCODE_STORE: begin
          data_mem_req.addr = align_addr(ex_mem.ex_result);
          data_mem_req.we = '1;
          data_mem_req.enable = '1;
          case (ex_mem.funct3)
            FUNCT3_STORE_SB: begin
              data_mem_req.mask = 'b1 << addr_offset(ex_mem.ex_result);
              data_mem_req.data = fwd_ex_rs2[7:0] << (addr_offset(ex_mem.ex_result) * 8);
            end
            FUNCT3_STORE_SH: begin
              data_mem_req.mask = 'b11 << addr_offset(ex_mem.ex_result);
              data_mem_req.data = fwd_ex_rs2[15:0] << (addr_offset(ex_mem.ex_result) * 8);
            end
            FUNCT3_STORE_SW: begin
              data_mem_req.mask = 'b1111;
              data_mem_req.data = fwd_ex_rs2;
            end
          endcase
        end
        OPCODE_LOAD: begin
          data_mem_req.addr = align_addr(ex_mem.ex_result);
          data_mem_req.we = '0;
          data_mem_req.enable = '1;
          case (ex_mem.funct3)
            FUNCT3_LOAD_LB, FUNCT3_LOAD_LBU: begin
              data_mem_req.mask = 'b1 << addr_offset(ex_mem.ex_result);
            end
            FUNCT3_LOAD_LH, FUNCT3_LOAD_LHU: begin
              data_mem_req.mask = 'b11 << addr_offset(ex_mem.ex_result);
            end
            FUNCT3_LOAD_LW: begin
              data_mem_req.mask = 'b1111;
            end
          endcase
        end
      endcase
    end
  end

  word_t next_load_result;
  always @(*) begin
    next_load_result = '0;
    if (data_mem_rsp.done && data_mem_rsp.valid) begin
      case (ex_mem.funct3)
        FUNCT3_LOAD_LB: begin
          next_load_result = data_mem_rsp.data >> (addr_offset(ex_mem.ex_result) * 8);
          next_load_result = {{24{next_load_result[7]}}, next_load_result[7:0]};
        end
        FUNCT3_LOAD_LBU: begin
          next_load_result = data_mem_rsp.data >> (addr_offset(ex_mem.ex_result) * 8);
          next_load_result = {{24{1'b0}}, next_load_result[7:0]};
        end
        FUNCT3_LOAD_LH: begin
          next_load_result = data_mem_rsp.data >> (addr_offset(ex_mem.ex_result) * 8);
          next_load_result = {{16{next_load_result[15]}}, next_load_result[15:0]};
        end
        FUNCT3_LOAD_LHU: begin
          next_load_result = data_mem_rsp.data >> (addr_offset(ex_mem.ex_result) * 8);
          next_load_result = {{16{1'b0}}, next_load_result[15:0]};
        end
        FUNCT3_LOAD_LW: begin
          next_load_result = data_mem_rsp.data;
        end
      endcase
    end
  end

  logic next_valid;
  always @(*) begin
    next_valid = '0;
    if (enable && ex_mem.valid && data_mem_rsp.done) begin
      next_valid = '1;
      if (data_mem_req.enable && !data_mem_rsp.valid) begin
        next_valid = '0;
      end
    end
  end

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      mem_wb = MEM_WB_RST;
    end else if (wb_ready) begin
      mem_wb.inst         <= ex_mem.inst;
      mem_wb.pc           <= ex_mem.pc;
      mem_wb.branch_pred  <= ex_mem.branch_pred;
      mem_wb.rd           <= ex_mem.rd;
      mem_wb.opcode       <= ex_mem.opcode;
      mem_wb.funct3       <= ex_mem.funct3;
      mem_wb.funct7       <= ex_mem.funct7;
      mem_wb.imm          <= ex_mem.imm;
      mem_wb.ex_result    <= ex_mem.ex_result;
      mem_wb.load_result  <= next_load_result;
      mem_wb.store_data   <= data_mem_req.data;
      mem_wb.valid        <= next_valid;
      mem_wb.inst_id      <= ex_mem.inst_id;
    end
  end

endmodule

*/

module mem_stage (
  input logic clk,
  input logic rst,
  input logic en,
  input logic wb_rdy,
  input id_ex_t ex_mem,
  input bypass_t bypass,
  input mem_read_rsp_t data_read_rsp,
  input mem_write_rsp_t data_write_rsp,
  output logic rdy,
  output mem_read_req_t data_read_req,
  output mem_write_req_t data_write_req,
  output ex_mem_t mem_wb
);

  // Mem request done flag
  logic mem_req_done;
  assign mem_req_done = data_read_req.done && data_write_req.done;

  // Ready flag logic
  assign rdy = en && wb_rdy && mem_req_done;

  // Memory write request logic
  always @(*) begin
    data_write_req.addr = '0;
    data_write_req.data = '0;
    data_write_req.mask = '0;
    data_write_req.en = '0;
    if (en && ex_mem.opcode == OPCODE_STORE) begin
      data_write_req.addr = ex_mem.ex_result;
      data_write_req.en = '1;
      case (ex_mem.funct3)
        FUNCT3_STORE_SB: begin
          data_write_req.mask = 'b1 << get_addr_off(ex_mem.ex_result);
          data_write_req.data = bypass.rs2_value[7:0] << (get_addr_off(ex_mem.ex_result) * 8);
        end
        FUNCT3_STORE_SH: begin
          data_write_req.mask = 'b11 << get_addr_off(ex_mem.ex_result);
          data_write_req.data = bypass.rs2_value[15:0] << (get_addr_off(ex_mem.ex_result) * 8);
        end
        FUNCT3_STORE_SW: begin
          data_write_req.mask = 'b1111;
          data_write_req.data = bypass.rs2_value;
        end
      endcase
    end
  end

  // Memory read request logic
  always @(*) begin
    data_read_req.addr = '0;
    data_read_req.en = '0;
    if (en && ex_mem.opcode == OPCODE_LOAD) begin
      data_read_req.addr = ex_mem.ex_result;
      data_read_req.en = '1;
      case (ex_mem.funct3)
        FUNCT3_LOAD_LB, FUNCT3_LOAD_LBU: begin
          data_read_req.mask = 'b1 << get_addr_off(ex_mem.ex_result);
        end
        FUNCT3_LOAD_LH, FUNCT3_LOAD_LHU: begin
          data_read_req.mask = 'b11 << get_addr_off(ex_mem.ex_result);
        end
        FUNCT3_LOAD_LW: begin
          data_read_req.mask = 'b1111;
        end
      endcase
    end
  end


endmodule
