module execute_stage (
  input logic clk,
  input logic rst,
  input logic en,
  input logic mem_rdy,
  input id_ex_t id_ex,
  input bypass_t bypass,
  output logic rdy,
  output ex_mem_t ex_mem
);

  // Ready flag logic
  assign rdy = en && mem_rdy;

  // Instruction execution logic
  word_t ex_result;
  always @(*) begin
    ex_result = '0;
    case (id_ex.opcode)
      OPCODE_OP: begin
        case (id_ex.funct3)
          FUNCT3_OP_SLL: begin
            ex_result = bypass.rs1_value << bypass.rs2_value[SHIFT_BITS-1:0];
          end
          FUNCT3_OP_SLT: begin
            ex_result = $signed(bypass.rs1_value) < $signed(bypass.rs2_value);
          end
          FUNCT3_OP_SLTU: begin
            ex_result = bypass.rs1_value < bypass.rs2_value;
          end
          FUNCT3_OP_XOR: begin
            ex_result = bypass.rs1_value ^ bypass.rs2_value;
          end
          FUNCT3_OP_OR: begin
            ex_result = bypass.rs1_value | bypass.rs2_value;
          end
          FUNCT3_OP_AND: begin
            ex_result = bypass.rs1_value & bypass.rs2_value;
          end
          FUNCT3_OP_ADD_SUB: begin
            if (id_ex.funct7 == FUNCT7_OP_ADD) begin
            ex_result = bypass.rs1_value + bypass.rs2_value;
            end else if (id_ex.funct7 == FUNCT7_OP_SUB) begin
              ex_result = bypass.rs1_value - bypass.rs2_value;
            end
          end
          FUNCT3_OP_SRL_SRA: begin
            if (id_ex.funct7 == FUNCT7_OP_SRL) begin
              ex_result = bypass.rs1_value >> bypass.rs2_value[SHIFT_BITS-1:0];
            end else if (id_ex.funct7 == FUNCT7_OP_SRA) begin
              ex_result = bypass.rs1_value >>> bypass.rs2_value[SHIFT_BITS-1:0];
            end
          end
        endcase
      end
      OPCODE_OP_IMM: begin
        case (id_ex.funct3)
          FUNCT3_OP_IMM_XORI: begin
            ex_result = bypass.rs1_value ^ id_ex.imm;
          end
          FUNCT3_OP_IMM_ORI: begin
            ex_result = bypass.rs1_value | id_ex.imm;
          end
          FUNCT3_OP_IMM_ANDI: begin
            ex_result = bypass.rs1_value & id_ex.imm;
          end
          FUNCT3_OP_IMM_SLTI: begin
            ex_result = $signed(bypass.rs1_value) < $signed(id_ex.imm);
          end
          FUNCT3_OP_IMM_SLTIU: begin
            ex_result = bypass.rs1_value < id_ex.imm;
          end
          FUNCT3_OP_IMM_SLLI: begin
            ex_result = bypass.rs1_value << id_ex.imm[SHIFT_BITS-1:0];
          end
          FUNCT3_OP_IMM_ADDI: begin
            ex_result = bypass.rs1_value + id_ex.imm;
          end
          FUNCT3_OP_IMM_SRAI_SRLI: begin
            if (id_ex.funct7 == FUNCT7_OP_IMM_SRAI) begin
              ex_result = bypass.rs1_value >>> id_ex.imm[SHIFT_BITS-1:0];
            end else if (id_ex.funct7 == FUNCT7_OP_IMM_SRLI) begin
              ex_result = bypass.rs1_value >> id_ex.imm[SHIFT_BITS-1:0];
            end
          end
        endcase
      end
      OPCODE_BRANCH: begin
        case (id_ex.funct3)
          FUNCT3_BRANCH_BEQ: begin
            ex_result = bypass.rs1_value == bypass.rs2_value;
          end
          FUNCT3_BRANCH_BNE: begin
            ex_result = bypass.rs1_value != bypass.rs2_value;
          end
          FUNCT3_BRANCH_BLT: begin
            ex_result = $signed(bypass.rs1_value) < $signed(bypass.rs2_value);
          end
          FUNCT3_BRANCH_BGE: begin
            ex_result = $signed(bypass.rs1_value) >= $signed(bypass.rs2_value);
          end
          FUNCT3_BRANCH_BLTU: begin
            ex_result = bypass.rs1_value < bypass.rs2_value;
          end
          FUNCT3_BRANCH_BGEU: begin
            ex_result = bypass.rs1_value >= bypass.rs2_value;
          end
        endcase
      end
      OPCODE_LUI: begin
        ex_result = id_ex.imm;
      end
      OPCODE_AUIPC: begin
        ex_result = id_ex.pc + id_ex.imm;
      end
      OPCODE_LOAD, OPCODE_STORE: begin
        ex_result = bypass.rs1_value + id_ex.imm;
      end
      OPCODE_JAL, OPCODE_JALR: begin
        ex_result = id_ex.pc + 4;
      end
    endcase
  end

  // Update logic for ex_mem registers
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      ex_mem.inst      <= '0;
      ex_mem.pc        <= '0;
      ex_mem.opcode    <= '0;
      ex_mem.funct3    <= '0;
      ex_mem.funct7    <= '0;
      ex_mem.rs1       <= '0;
      ex_mem.rs2       <= '0;
      ex_mem.rd        <= '0;
      ex_mem.has_rs1   <= '0;
      ex_mem.has_rs2   <= '0;
      ex_mem.has_rd    <= '0;
      ex_mem.imm       <= '0;
      ex_mem.ex_result <= '0;
      ex_mem.valid     <= '0;
    end else if (en && mem_rdy) begin
      ex_mem.inst      <= id_ex.inst;
      ex_mem.pc        <= id_ex.pc;
      ex_mem.opcode    <= id_ex.opcode;
      ex_mem.funct3    <= id_ex.funct3;
      ex_mem.funct7    <= id_ex.funct7;
      ex_mem.rs1       <= id_ex.rs1;
      ex_mem.rs2       <= id_ex.rs2;
      ex_mem.rd        <= id_ex.rd;
      ex_mem.has_rs1   <= id_ex.has_rs1;
      ex_mem.has_rs2   <= id_ex.has_rs2;
      ex_mem.has_rd    <= id_ex.has_rd;
      ex_mem.imm       <= id_ex.imm;
      ex_mem.ex_result <= ex_result;
      ex_mem.valid     <= id_ex.valid;
    end
  end

endmodule