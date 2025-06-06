`ifndef _lab6_sv
`define _lab6_sv

`define __DEBUG__

/**************************************************************************************************
 * Common Constants, Typedefs and Functions
 **************************************************************************************************/

localparam int WORD_SIZE = 32;
localparam int REG_COUNT = 32;

typedef logic [WORD_SIZE-1:0] word_t;
typedef logic [WORD_SIZE-1:0] inst_t;
typedef logic [WORD_SIZE-1:0] addr_t;
typedef logic [WORD_SIZE-1:0] reg_t;
typedef logic [$clog2(REG_COUNT)-1:0] reg_num_t;
typedef logic [6:0] opcode_t;
typedef logic [2:0] funct3_t;
typedef logic [6:0] funct7_t;
typedef logic [WORD_SIZE-1:0] imm_t;
typedef logic [(WORD_SIZE/8)-1:0] byte_mask_t;
typedef logic unsigned [3:0] inst_id_t;

typedef struct packed {
  reg_num_t reg_num;
  logic enable;
} rf_read_req_t;

typedef struct packed {
  reg_t read_data;
  logic valid;
  logic done;
} rf_read_rsp_t;

typedef struct packed {
  reg_num_t reg_num;
  reg_t write_data;
  logic enable;
} rf_write_req_t;

typedef struct packed {
  logic valid;
  logic done;
} rf_write_rsp_t;

typedef struct packed {
  addr_t addr;
  word_t data;
  byte_mask_t mask;
  logic we;
  logic enable;
} data_mem_req_t;

typedef struct packed {
  word_t data;
  logic valid;
  logic done;
} data_mem_rsp_t;

typedef struct packed {
  addr_t addr;
  logic enable;
} inst_mem_req_t;

typedef struct packed {
  inst_t inst;
  logic valid;
  logic done;
} inst_mem_rsp_t;

typedef struct packed {
  inst_t inst;
  addr_t pc;
  logic valid;
  inst_id_t inst_id;
} if_id_t;

typedef struct packed {
  inst_t inst;
  addr_t pc;
  logic branch_pred;
  reg_t rs1_data;
  reg_t rs2_data;
  reg_num_t rd;
  opcode_t opcode;
  funct3_t funct3;
  funct7_t funct7;
  imm_t imm;
  logic valid;
  inst_id_t inst_id;
} id_ex_t;

typedef struct packed {
  inst_t inst;
  addr_t pc;
  logic branch_pred;
  reg_t rs1_data;
  reg_t rs2_data;
  reg_num_t rd;
  opcode_t opcode;
  funct3_t funct3;
  funct7_t funct7;
  imm_t imm;
  reg_t ex_result;
  logic valid;
  inst_id_t inst_id;
} ex_mem_t;

typedef struct packed {
  inst_t inst;
  addr_t pc;
  logic branch_pred;
  reg_t rs1_data;
  reg_t rs2_data;
  reg_num_t rd;
  opcode_t opcode;
  funct3_t funct3;
  funct7_t funct7;
  imm_t imm;
  reg_t ex_result;
  reg_t load_result;
  reg_t store_data;
  logic valid;
  inst_id_t inst_id;
} mem_wb_t;

// Reset values for pipeline registers
localparam if_id_t IF_ID_RST = '0;
localparam id_ex_t ID_EX_RST = '0;
localparam ex_mem_t EX_MEM_RST = '0;
localparam mem_wb_t MEM_WB_RST = '0;

// Reset values for request/response structs
localparam rf_read_req_t RF_READ_REQ_RST   = '0;
localparam rf_write_req_t RF_WRITE_REQ_RST = '0;
localparam inst_mem_req_t INST_MEM_REQ_RST = '0;
localparam data_mem_req_t DATA_MEM_REQ_RST = '0;
localparam rf_read_rsp_t RF_READ_RSP_RST   = '{0, 0, 1};
localparam rf_write_rsp_t RF_WRITE_RSP_RST = '{0, 1};
localparam inst_mem_rsp_t INST_MEM_RSP_RST = '{0, 0, 1};
localparam data_mem_rsp_t DATA_MEM_RSP_RST = '{0, 0, 1};

// Opcode Constants
localparam opcode_t OPCODE_LOAD     = 'b0000011;
localparam opcode_t OPCODE_STORE    = 'b0100011;
localparam opcode_t OPCODE_BRANCH   = 'b1100011;
localparam opcode_t OPCODE_JALR     = 'b1100111;
localparam opcode_t OPCODE_JAL      = 'b1101111;
localparam opcode_t OPCODE_OP_IMM   = 'b0010011;
localparam opcode_t OPCODE_OP       = 'b0110011;
localparam opcode_t OPCODE_LUI      = 'b0110111;
localparam opcode_t OPCODE_AUIPC    = 'b0010111;
localparam opcode_t OPCODE_SYSTEM   = 'b1110011;
localparam opcode_t OPCODE_FENCE    = 'b0001111;

// Funct3 Load Constants
localparam funct3_t FUNCT3_LOAD_LB  = 'b000;
localparam funct3_t FUNCT3_LOAD_LH  = 'b001;
localparam funct3_t FUNCT3_LOAD_LW  = 'b010;
localparam funct3_t FUNCT3_LOAD_LBU = 'b100;
localparam funct3_t FUNCT3_LOAD_LHU = 'b101;

// Funct3 Store Constants
localparam funct3_t FUNCT3_STORE_SB = 'b000;
localparam funct3_t FUNCT3_STORE_SH = 'b001;
localparam funct3_t FUNCT3_STORE_SW = 'b010;

// Funct3 Branch Constants
localparam funct3_t FUNCT3_BRANCH_BEQ  = 'b000;
localparam funct3_t FUNCT3_BRANCH_BNE  = 'b001;
localparam funct3_t FUNCT3_BRANCH_BLT  = 'b100;
localparam funct3_t FUNCT3_BRANCH_BGE  = 'b101;
localparam funct3_t FUNCT3_BRANCH_BLTU = 'b110;
localparam funct3_t FUNCT3_BRANCH_BGEU = 'b111;

// Funct3 Immediate ALU Constants
localparam funct3_t FUNCT3_OP_IMM_ADDI       = 'b000;
localparam funct3_t FUNCT3_OP_IMM_SLLI       = 'b001;
localparam funct3_t FUNCT3_OP_IMM_SLTI       = 'b010;
localparam funct3_t FUNCT3_OP_IMM_SLTIU      = 'b011;
localparam funct3_t FUNCT3_OP_IMM_XORI       = 'b100;
localparam funct3_t FUNCT3_OP_IMM_ORI        = 'b110;
localparam funct3_t FUNCT3_OP_IMM_ANDI       = 'b111;
localparam funct3_t FUNCT3_OP_IMM_SRAI_SRLI  = 'b101;

// Funct7 Immediate ALU Constants
localparam funct7_t FUNCT7_OP_IMM_SRAI  = 'b0100000;
localparam funct7_t FUNCT7_OP_IMM_SRLI = 'b0000000;

// Funct3 R-type ALU Constants
localparam funct3_t FUNCT3_OP_ADD_SUB = 'b000;
localparam funct3_t FUNCT3_OP_SLL     = 'b001;
localparam funct3_t FUNCT3_OP_SLT     = 'b010;
localparam funct3_t FUNCT3_OP_SLTU    = 'b011;
localparam funct3_t FUNCT3_OP_XOR     = 'b100;
localparam funct3_t FUNCT3_OP_OR      = 'b110;
localparam funct3_t FUNCT3_OP_AND     = 'b111;
localparam funct3_t FUNCT3_OP_SRL_SRA = 'b101;

// Funct7 R-type ALU Constants
localparam funct7_t FUNCT7_OP_ADD = 'b0000000;
localparam funct7_t FUNCT7_OP_SUB = 'b0100000;
localparam funct7_t FUNCT7_OP_SRL = 'b0000000;
localparam funct7_t FUNCT7_OP_SRA = 'b0100000;

// Register constants
localparam reg_num_t REG_ZERO = 'b00000;
localparam reg_num_t REG_RA   = 'b00001;
localparam reg_num_t REG_SP   = 'b00010;
localparam reg_num_t REG_GP   = 'b00011;
localparam reg_num_t REG_TP   = 'b00100;
localparam reg_num_t REG_T0   = 'b00101;
localparam reg_num_t REG_T1   = 'b00110;
localparam reg_num_t REG_T2   = 'b00111;
localparam reg_num_t REG_S0   = 'b01000;
localparam reg_num_t REG_S1   = 'b01001;
localparam reg_num_t REG_A0   = 'b01010;
localparam reg_num_t REG_A1   = 'b01011;
localparam reg_num_t REG_A2   = 'b01100;
localparam reg_num_t REG_A3   = 'b01101;
localparam reg_num_t REG_A4   = 'b01110;
localparam reg_num_t REG_A5   = 'b01111;
localparam reg_num_t REG_A6   = 'b10000;
localparam reg_num_t REG_A7   = 'b10001;
localparam reg_num_t REG_S2   = 'b10010;
localparam reg_num_t REG_S3   = 'b10011;
localparam reg_num_t REG_S4   = 'b10100;
localparam reg_num_t REG_S5   = 'b10101;
localparam reg_num_t REG_S6   = 'b10110;
localparam reg_num_t REG_S7   = 'b10111;
localparam reg_num_t REG_S8   = 'b11000;
localparam reg_num_t REG_S9   = 'b11001;
localparam reg_num_t REG_S10  = 'b11010;
localparam reg_num_t REG_S11  = 'b11011;
localparam reg_num_t REG_T3   = 'b11100;
localparam reg_num_t REG_T4   = 'b11101;
localparam reg_num_t REG_T5   = 'b11110;
localparam reg_num_t REG_T6   = 'b11111;

// Misc Constants
localparam int LUI_SHIFT = 12;
localparam int SHIFT_BITS = 5;

// Extract opcode [6:0]
function automatic opcode_t get_opcode(input inst_t inst);
  return inst[6:0];
endfunction

// Extract rd [11:7]
function automatic reg_num_t get_rd(input inst_t inst);
  return inst[11:7];
endfunction

// Extract rs1 [19:15]
function automatic reg_num_t get_rs1(input inst_t inst);
  return inst[19:15];
endfunction

// Extract rs2 [24:20]
function automatic reg_num_t get_rs2(input inst_t inst);
  return inst[24:20];
endfunction

// Extract funct3 [14:12]
function automatic funct3_t get_funct3(input inst_t inst);
  return inst[14:12];
endfunction

// Extract funct7 [31:25]
function automatic funct7_t get_funct7(input inst_t inst);
  return inst[31:25];
endfunction

// Extract immediate value [various]
function automatic imm_t get_imm(input inst_t inst);
  case (get_opcode(inst))
    OPCODE_LUI:     return {inst[31:12], 12'b0};                                        // U-type
    OPCODE_AUIPC:   return {inst[31:12], 12'b0};                                        // U-type
    OPCODE_JAL:     return {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};  // J-type, sign-extended with 11 copies of inst[31]
    OPCODE_JALR:    return {{20{inst[31]}}, inst[31:20]};                               // I-type
    OPCODE_BRANCH:  return {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};    // B-type, sign-extended with 19 copies of inst[31]
    OPCODE_LOAD:    return {{20{inst[31]}}, inst[31:20]};                               // I-type
    OPCODE_STORE:   return {{20{inst[31]}}, inst[31:25], inst[11:7]};                   // S-type
    OPCODE_OP_IMM:  return {{20{inst[31]}}, inst[31:20]};                               // I-type
    default:        return 0;
  endcase
endfunction

function automatic logic has_rs1(input inst_t inst);
  opcode_t opcode = get_opcode(inst);
  return (
    opcode == OPCODE_LOAD   ||
    opcode == OPCODE_STORE  ||
    opcode == OPCODE_OP_IMM ||
    opcode == OPCODE_OP     ||
    opcode == OPCODE_BRANCH ||
    opcode == OPCODE_JALR);
endfunction

function automatic logic has_rs2(input inst_t inst);
  opcode_t opcode = get_opcode(inst);
  return (
    opcode == OPCODE_STORE ||
    opcode == OPCODE_OP    ||
    opcode == OPCODE_BRANCH);
endfunction 

function automatic logic has_rd(input inst_t inst);
  opcode_t opcode = get_opcode(inst);
  reg_num_t rd = get_rd(inst);
  return (
    opcode == OPCODE_OP     ||
    opcode == OPCODE_OP_IMM ||
    opcode == OPCODE_LOAD   ||
    opcode == OPCODE_LUI    ||
    opcode == OPCODE_AUIPC  ||
    opcode == OPCODE_JAL    ||
    opcode == OPCODE_JALR);
endfunction

function automatic addr_t align_addr(input addr_t addr);
  return addr & ~(WORD_SIZE/8-1);
endfunction

function automatic addr_t addr_offset(input addr_t addr);
  return addr & (WORD_SIZE/8-1);
endfunction

/**************************************************************************************************
 * Debug Manager
 **************************************************************************************************/

module core_debug #(
  parameter int STOP_CYCLE = 0,
  parameter int FINISH_CYCLE = 0
)(
  input logic clk,
  input if_id_t if_id,
  input id_ex_t id_ex,
  input ex_mem_t ex_mem,
  input mem_wb_t mem_wb,
  input data_mem_req_t data_mem_req,
  input reg_t fwd_id_rs1,
  input reg_t fwd_id_rs2
);

  `ifdef __DEBUG__

  function automatic string reg_str(input reg_num_t reg_num);
    case (reg_num)
      REG_ZERO: reg_str = "zero";
      REG_RA:   reg_str = "ra";
      REG_SP:   reg_str = "sp";
      REG_GP:   reg_str = "gp";
      REG_TP:   reg_str = "tp";
      REG_T0:   reg_str = "t0";
      REG_T1:   reg_str = "t1";
      REG_T2:   reg_str = "t2";
      REG_S0:   reg_str = "s0";
      REG_S1:   reg_str = "s1";
      REG_A0:   reg_str = "a0";
      REG_A1:   reg_str = "a1";
      REG_A2:   reg_str = "a2";
      REG_A3:   reg_str = "a3";
      REG_A4:   reg_str = "a4";
      REG_A5:   reg_str = "a5";
      REG_A6:   reg_str = "a6";
      REG_A7:   reg_str = "a7";
      REG_S2:   reg_str = "s2";
      REG_S3:   reg_str = "s3";
      REG_S4:   reg_str = "s4";
      REG_S5:   reg_str = "s5";
      REG_S6:   reg_str = "s6";
      REG_S7:   reg_str = "s7";
      REG_S8:   reg_str = "s8";
      REG_S9:   reg_str = "s9";
      REG_S10:  reg_str = "s10";
      REG_S11:  reg_str = "s11";
      REG_T3:   reg_str = "t3";
      REG_T4:   reg_str = "t4";
      REG_T5:   reg_str = "t5";
      REG_T6:   reg_str = "t6";
      default:  reg_str = "unknown";
    endcase
  endfunction

  function automatic void write_inst(input addr_t pc, input inst_t inst);
    opcode_t opcode = get_opcode(inst);
    funct7_t funct7 = get_funct7(inst);
    funct3_t funct3 = get_funct3(inst);
    imm_t imm = get_imm(inst);
    string rd_str = reg_str(get_rd(inst));
    string rs1_str = reg_str(get_rs1(inst));
    string rs2_str = reg_str(get_rs2(inst));
    $write("0x%0X: ", pc);
    case (opcode)
      OPCODE_LUI:    $write("lui %s, 0x%0x", rd_str, imm >> 12);
      OPCODE_AUIPC:  $write("auipc %s, 0x%0x", rd_str, imm >> 12);
      OPCODE_JAL:    $write("jal %s, %0d", rd_str, $signed(imm));
      OPCODE_JALR:   $write("jalr %s, %0d(%s)", rd_str, $signed(imm), rs1_str);
      OPCODE_FENCE:  $write("fence");
      OPCODE_SYSTEM: $write("ecall/ebreak");
      OPCODE_BRANCH: begin
        case (funct3)
          FUNCT3_BRANCH_BEQ:  $write("beq %s, %s, 0x%0x",  rs1_str, rs2_str, pc + imm);
          FUNCT3_BRANCH_BNE:  $write("bne %s, %s, 0x%0x",  rs1_str, rs2_str, pc + imm);
          FUNCT3_BRANCH_BLT:  $write("blt %s, %s, 0x%0x",  rs1_str, rs2_str, pc + imm);
          FUNCT3_BRANCH_BGE:  $write("bge %s, %s, 0x%0x",  rs1_str, rs2_str, pc + imm);
          FUNCT3_BRANCH_BLTU: $write("bltu %s, %s, 0x%0x", rs1_str, rs2_str, pc + imm);
          FUNCT3_BRANCH_BGEU: $write("bgeu %s, %s, 0x%0x", rs1_str, rs2_str, pc + imm);
          default: $write("unknown instruction");
        endcase
      end
      OPCODE_LOAD: begin 
        case (funct3)
          FUNCT3_LOAD_LB:  $write("lb %s, %0d(%s)",  rd_str, $signed(imm), rs1_str);
          FUNCT3_LOAD_LH:  $write("lh %s, %0d(%s)",  rd_str, $signed(imm), rs1_str);
          FUNCT3_LOAD_LW:  $write("lw %s, %0d(%s)",  rd_str, $signed(imm), rs1_str);
          FUNCT3_LOAD_LBU: $write("lbu %s, %0d(%s)", rd_str, $signed(imm), rs1_str);
          FUNCT3_LOAD_LHU: $write("lhu %s, %0d(%s)", rd_str, $signed(imm), rs1_str);
          default: $write("unknown instruction");
        endcase
      end
      OPCODE_STORE: begin 
        case (funct3)
          FUNCT3_STORE_SB: $write("sb %s, %0d(%s)", rs2_str, $signed(imm), rs1_str);
          FUNCT3_STORE_SH: $write("sh %s, %0d(%s)", rs2_str, $signed(imm), rs1_str);
          FUNCT3_STORE_SW: $write("sw %s, %0d(%s)", rs2_str, $signed(imm), rs1_str);
          default: $write("unknown instruction");
        endcase
      end
      OPCODE_OP_IMM: begin 
        case (funct3)
          FUNCT3_OP_IMM_ADDI:  $write("addi %s, %s, %0d",    rd_str, rs1_str, $signed(imm));
          FUNCT3_OP_IMM_SLTI:  $write("slti %s, %s, %0d",    rd_str, rs1_str, $signed(imm));
          FUNCT3_OP_IMM_SLTIU: $write("sltiu %s, %s, 0x%0x", rd_str, rs1_str, imm);
          FUNCT3_OP_IMM_XORI:  $write("xori %s, %s, %0d",    rd_str, rs1_str, $signed(imm));
          FUNCT3_OP_IMM_ORI:   $write("ori %s, %s, %0d",     rd_str, rs1_str, $signed(imm));
          FUNCT3_OP_IMM_ANDI:  $write("andi %s, %s, %0d",    rd_str, rs1_str, $signed(imm));
          FUNCT3_OP_IMM_SLLI:  $write("slli %s, %s, %0d",    rd_str, rs1_str, imm[4:0]);
          FUNCT3_OP_IMM_SRAI_SRLI: begin
            case (funct7)
              FUNCT7_OP_IMM_SRAI: $write("srli %s, %s, %0d", rd_str, rs1_str, imm[4:0]);
              FUNCT7_OP_IMM_SRLI: $write("srai %s, %s, %0d", rd_str, rs1_str, imm[4:0]);
              default: $write("unknown instruction");
            endcase
          end
          default: $write("unknown instruction");
        endcase
      end
      OPCODE_OP: begin
        case (funct3)
          FUNCT3_OP_SLL:  $write("sll %s, %s, %s",  rd_str, rs1_str, rs2_str);
          FUNCT3_OP_SLT:  $write("slt %s, %s, %s",  rd_str, rs1_str, rs2_str);
          FUNCT3_OP_SLTU: $write("sltu %s, %s, %s", rd_str, rs1_str, rs2_str);
          FUNCT3_OP_XOR:  $write("xor %s, %s, %s",  rd_str, rs1_str, rs2_str);
          FUNCT3_OP_OR:   $write("or %s, %s, %s",   rd_str, rs1_str, rs2_str);
          FUNCT3_OP_AND:  $write("and %s, %s, %s",  rd_str, rs1_str, rs2_str);
          FUNCT3_OP_ADD_SUB: begin
            case (funct7)
              FUNCT7_OP_ADD: $write("add %s, %s, %s", rd_str, rs1_str, rs2_str);
              FUNCT7_OP_SUB: $write("sub %s, %s, %s", rd_str, rs1_str, rs2_str);
              default: $write("unknown instruction");
            endcase
          end
          FUNCT3_OP_SRL_SRA: begin
            case (funct7)
              FUNCT7_OP_SRL: $write("srl %s, %s, %s", rd_str, rs1_str, rs2_str);
              FUNCT7_OP_SRA: $write("sra %s, %s, %s", rd_str, rs1_str, rs2_str);
              default: $write("unknown instruction");
            endcase
          end
          default: $write("unknown instruction");
        endcase
      end
      default: $write("unknown instruction");
    endcase
    $write("\n");
  endfunction

  int cur_cycle = 1;
  always @(posedge clk) begin
    $display("CYCLE: %0d", cur_cycle);
    $display("================ IF/ID ================");
    if (if_id.valid) begin
      write_inst(if_id.pc, if_id.inst);
    end else begin
      $display("NOP");
    end
    $display("================ ID/EX ================");
    if (id_ex.valid) begin
      write_inst(id_ex.pc, id_ex.inst);
      if (has_rs1(id_ex.inst)) begin
        $write("RS1 value: %0d ", fwd_id_rs1);
      end
      if (has_rs2(id_ex.inst)) begin
        $write("RS2 value: %0d ", fwd_id_rs2);
      end
      if (has_rs1(id_ex.inst) || has_rs2(id_ex.inst)) begin
        $display();
      end
      if (get_opcode(id_ex.inst) == OPCODE_BRANCH) begin
        $display("Branch prediction: %0d ", id_ex.branch_pred);
      end
    end else begin
      $display("NOP");
    end
    $display("================ EX/MEM ===============");
    if (ex_mem.valid) begin
      write_inst(ex_mem.pc, ex_mem.inst);
      case (get_opcode(ex_mem.inst))
        OPCODE_OP, OPCODE_OP_IMM, OPCODE_LUI, 
        OPCODE_AUIPC, OPCODE_JAL, OPCODE_JALR: begin
          $display("ALU result: %0d", ex_mem.ex_result);
        end
        OPCODE_BRANCH: begin
          $display("Branch taken: %0d", ex_mem.ex_result);
        end
      endcase
    end else begin
      $display("NOP");
    end
    $display("================ MEM/WB ===============");
    if (mem_wb.valid) begin
      write_inst(mem_wb.pc, mem_wb.inst);
      case (get_opcode(mem_wb.inst))
        OPCODE_LOAD: begin
          $display("Load addr: 0x%0X, Load value: %0d", align_addr(mem_wb.ex_result), mem_wb.load_result);
        end
        OPCODE_STORE: begin
          $display("Store addr: %0d, Store value: %0d", align_addr(mem_wb.ex_result), mem_wb.store_data);
        end
      endcase
    end else begin
      $display("NOP");
    end
    $display("=======================================\n");
    if (STOP_CYCLE) begin
      if (cur_cycle % STOP_CYCLE == 0) $stop;
    end
    if (FINISH_CYCLE) begin
      if (cur_cycle >= FINISH_CYCLE) $finish;
    end
    cur_cycle++;
  end

  `endif // __DEBUG__

endmodule

/**************************************************************************************************
 * Memory Wrapper
 **************************************************************************************************/

module core_mem_wrapper (
  input memory_io_rsp o_inst_mem_rsp,
  input memory_io_rsp o_data_mem_rsp,
  input inst_mem_req_t inst_mem_req,
  input data_mem_req_t data_mem_req,
  output memory_io_req o_inst_mem_req,
  output memory_io_req o_data_mem_req,
  output inst_mem_rsp_t inst_mem_rsp,
  output data_mem_rsp_t data_mem_rsp
);

  always @(*) begin
    o_inst_mem_req.addr = inst_mem_req.addr;
    o_inst_mem_req.valid = inst_mem_req.enable;
    o_inst_mem_req.do_write = '0;
    o_inst_mem_req.do_read = 'b1111;
  end

  always @(*) begin
    o_data_mem_req.addr = data_mem_req.addr;
    o_data_mem_req.data = data_mem_req.data;
    o_data_mem_req.valid = data_mem_req.enable;
    if (data_mem_req.we) begin
      o_data_mem_req.do_write = data_mem_req.mask;
      o_data_mem_req.do_read = '0;
    end else begin
      o_data_mem_req.do_write = '0;
      o_data_mem_req.do_read = data_mem_req.mask;
    end
  end

  always @(*) begin
    inst_mem_rsp.inst = o_inst_mem_rsp.data;
    inst_mem_rsp.valid = o_inst_mem_rsp.valid && inst_mem_req.enable;
    inst_mem_rsp.done = o_inst_mem_rsp.valid || !inst_mem_req.enable;
  end

  always @(*) begin
    data_mem_rsp.data = o_data_mem_rsp.data;
    data_mem_rsp.valid = o_data_mem_rsp.valid && data_mem_req.enable;
    data_mem_rsp.done = o_data_mem_rsp.valid || !data_mem_req.enable;
  end

endmodule

/**************************************************************************************************
 * Regfile
 **************************************************************************************************/

 module core_regfile (
  input logic clk,
  input logic rst,
  input rf_read_req_t rs1_req,
  input rf_read_req_t rs2_req,
  input rf_write_req_t rd_req,
  output rf_read_rsp_t rs1_rsp,
  output rf_read_rsp_t rs2_rsp,
  output rf_write_rsp_t rd_rsp
);

  reg_t reg_mem [REG_COUNT];

  initial begin
    for (int i = 0; i < REG_COUNT; i++) begin
      reg_mem[i] = '0;
    end
  end

  rf_read_req_t prev_rs1_req = RF_READ_REQ_RST;
  rf_read_req_t prev_rs2_req = RF_READ_REQ_RST;
  rf_write_req_t prev_rd_req = RF_WRITE_REQ_RST;

  function automatic logic is_reg_num_valid(input reg_num_t reg_num);
    return (reg_num >= 0) && (reg_num < REG_COUNT);
  endfunction

  always @(*) begin
    rd_rsp.valid  = rd_req.enable  && is_reg_num_valid(rd_req.reg_num);
    rs1_rsp.valid = rs1_req.enable && is_reg_num_valid(rs1_req.reg_num);
    rs2_rsp.valid = rs2_req.enable && is_reg_num_valid(rs2_req.reg_num);
    rd_rsp.done   = !rd_rsp.valid  || (rd_req  == prev_rd_req);
    rs1_rsp.done  = !rs1_rsp.valid || (rs1_req == prev_rs1_req);
    rs2_rsp.done  = !rs2_rsp.valid || (rs2_req == prev_rs2_req);
  end

  always @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < REG_COUNT; i++) begin
        reg_mem[i] <= '0;
      end
      prev_rs1_req <= RF_READ_REQ_RST;
      prev_rs2_req <= RF_READ_REQ_RST;
      prev_rd_req  <= RF_WRITE_REQ_RST;
    end else begin
      if (rs1_req.enable && !rs1_rsp.done) begin
        if (rd_req.enable && !rd_rsp.done && 
            (rs1_req.reg_num == rd_req.reg_num)) begin
          rs1_rsp.read_data <= rd_req.write_data;
        end else if (rs1_req.reg_num != REG_ZERO) begin
          rs1_rsp.read_data <= reg_mem[rs1_req.reg_num];
        end else begin
          rs1_rsp.read_data <= '0;
        end
      end
      if (rs2_req.enable && !rs2_rsp.done) begin
        if (rd_req.enable && !rd_rsp.done && 
            (rs2_req.reg_num == rd_req.reg_num)) begin
          rs2_rsp.read_data <= rd_req.write_data;
        end else if (rs2_req.reg_num != REG_ZERO) begin
          rs2_rsp.read_data <= reg_mem[rs2_req.reg_num];
        end else begin
          rs2_rsp.read_data <= '0;
        end
      end
      if (rd_req.enable && !rd_rsp.done) begin
        if (rd_req.reg_num != REG_ZERO) begin
          reg_mem[rd_req.reg_num] <= rd_req.write_data;
        end
      end
      prev_rs1_req <= rs1_req;
      prev_rs2_req <= rs2_req;
      prev_rd_req  <= rd_req;
    end
    $display("SP: 0x%0X", reg_mem[REG_SP]);
  end

endmodule

/**************************************************************************************************
 * PC Manager / Branch Predictor
 **************************************************************************************************/

module core_pc_manager #(
  parameter int TABLE_SIZE = 1024
)(
  input logic clk,
  input logic rst,
  input addr_t rst_pc,
  input if_id_t if_id,
  input id_ex_t id_ex,
  input ex_mem_t ex_mem,
  input mem_wb_t mem_wb,
  input logic fetch_ready,
  output logic flush_flag,
  output logic branch_pred,
  output logic decode_stall,
  output addr_t pc
);

  typedef logic [$clog2(TABLE_SIZE)-1:0] table_index_t;

  typedef enum {
    STRONG_NOT_TAKEN,
    WEAK_NOT_TAKEN,
    WEAK_TAKEN,
    STRONG_TAKEN
  } taken_state_t;

  addr_t prev_pc = rst_pc - 4;

  taken_state_t branch_table [TABLE_SIZE];
  localparam taken_state_t DEFAULT_TAKEN_STATE = WEAK_TAKEN;
  initial begin
    for (int i = 0; i < TABLE_SIZE; i++) begin
      branch_table[i] = DEFAULT_TAKEN_STATE;
    end
  end

  always @(*) begin
    decode_stall = '0;
    flush_flag = '0;
    branch_pred = '0;
    pc = prev_pc + 4;
    if (ex_mem.valid && (get_opcode(ex_mem.inst) == OPCODE_BRANCH) && 
        (ex_mem.ex_result != ex_mem.branch_pred)) begin
      flush_flag = '1;
      if (ex_mem.ex_result) begin
        pc = ex_mem.pc + get_imm(ex_mem.inst);
      end else begin
        pc = ex_mem.pc + 4;
      end
    end else if (id_ex.valid && (get_opcode(id_ex.inst) == OPCODE_JALR)) begin
      flush_flag = '1;
      if (ex_mem.valid && has_rd(ex_mem.inst) && get_rs1(id_ex.inst) == ex_mem.rd) begin
        if (get_opcode(ex_mem.inst) == OPCODE_LOAD) begin
          decode_stall = '1;
        end else begin
          pc = (ex_mem.ex_result + id_ex.imm) & ~1;
        end
      end else if (mem_wb.valid && has_rd(mem_wb.inst) && get_rs1(id_ex.inst) == mem_wb.rd) begin
        if (get_opcode(mem_wb.inst) == OPCODE_LOAD) begin
          pc = (mem_wb.load_result + id_ex.imm) & ~1;
        end else begin
          pc = (mem_wb.ex_result + id_ex.imm) & ~1;
        end
      end else begin
        pc = (id_ex.rs1_data + id_ex.imm) & ~1;
      end
    end else begin
      case (get_opcode(if_id.inst))
        OPCODE_BRANCH: begin
          case (branch_table[if_id.pc % TABLE_SIZE])
            STRONG_TAKEN, WEAK_TAKEN: begin
              pc = if_id.pc + get_imm(if_id.inst);
              branch_pred = '1;
            end
          endcase
        end
        OPCODE_JAL: begin
          pc = if_id.pc + get_imm(if_id.inst);
        end
      endcase
    end
  end

  table_index_t write_index;
  assign write_index = ex_mem.pc % TABLE_SIZE;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      for (int i = 0; i < TABLE_SIZE; i++) begin
        branch_table[i] <= WEAK_NOT_TAKEN;
      end
    end else if (ex_mem.valid && (get_opcode(ex_mem.inst) == OPCODE_BRANCH)) begin
      if (ex_mem.ex_result) begin
        case (branch_table[write_index])
          STRONG_NOT_TAKEN: branch_table[write_index] <= WEAK_NOT_TAKEN;
          WEAK_NOT_TAKEN:   branch_table[write_index] <= WEAK_TAKEN;
          WEAK_TAKEN:       branch_table[write_index] <= STRONG_TAKEN;
        endcase
      end else begin
        case (branch_table[write_index])
          STRONG_TAKEN:   branch_table[write_index] <= WEAK_TAKEN;
          WEAK_TAKEN:     branch_table[write_index] <= WEAK_NOT_TAKEN;
          WEAK_NOT_TAKEN: branch_table[write_index] <= STRONG_NOT_TAKEN;
        endcase
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      prev_pc <= rst_pc - 4;
    end else if (fetch_ready) begin
      prev_pc <= pc;
    end
  end

endmodule

/**************************************************************************************************
 * Hazard Unit
 **************************************************************************************************/

module core_hazard_unit (
  input logic clk,
  input logic rst,
  input if_id_t if_id,
  input id_ex_t id_ex,
  input ex_mem_t ex_mem,
  input mem_wb_t mem_wb,
  output reg_t fwd_id_rs1,
  output reg_t fwd_id_rs2,
  output reg_t fwd_ex_rs2,
  output logic execute_stall,
  output logic fetch_stall
);

  reg_num_t id_rs1;
  reg_num_t id_rs2;
  reg_num_t ex_rs2;
  reg_num_t ex_rd;
  reg_num_t mem_rd;

  assign id_rs1 = get_rs1(id_ex.inst);
  assign id_rs2 = get_rs2(id_ex.inst);
  assign ex_rs2 = get_rs2(ex_mem.inst);
  assign ex_rd  = get_rd(ex_mem.inst);
  assign mem_rd = get_rd(mem_wb.inst);

  logic id_rs1_valid;
  logic id_rs2_valid;
  logic ex_rs2_valid;
  logic ex_rd_valid;
  logic mem_rd_valid;

  assign id_rs1_valid = has_rs1(id_ex.inst)  && id_ex.valid;
  assign id_rs2_valid = has_rs2(id_ex.inst)  && id_ex.valid;
  assign ex_rs2_valid = has_rs2(ex_mem.inst) && ex_mem.valid;
  assign ex_rd_valid  = has_rd(ex_mem.inst)  && ex_mem.valid;
  assign mem_rd_valid = has_rd(mem_wb.inst)  && mem_wb.valid;

  opcode_t id_opcode;
  opcode_t ex_opcode;
  opcode_t mem_opcode;

  assign id_opcode  = get_opcode(id_ex.inst);
  assign ex_opcode  = get_opcode(ex_mem.inst);
  assign mem_opcode = get_opcode(mem_wb.inst);

  reg_num_t prev_mem_rd_num = '0;
  reg_t prev_mem_fwd = '0;

  always @(*) begin
    execute_stall = '0;
    fetch_stall   = '0;
    fwd_id_rs1    = id_ex.rs1_data;
    fwd_id_rs2    = id_ex.rs2_data;
    fwd_ex_rs2    = ex_mem.rs2_data;
    if (ex_rd_valid && (ex_opcode == OPCODE_LOAD)) begin
      if (id_rs1_valid && (id_rs1 != REG_ZERO) && (id_rs1 == ex_rd)) begin
        execute_stall = '1;
      end
      if (id_rs2_valid && (id_rs2 != REG_ZERO) && (id_rs2 == ex_rd)) begin
        execute_stall = '1;
      end
    end
    if (if_id.valid && (get_opcode(if_id.inst) == OPCODE_JALR)) begin
      fetch_stall = '1;
    end
    if (!execute_stall && id_rs1_valid && (id_rs1 != REG_ZERO)) begin
      if (ex_rd_valid && (ex_opcode != OPCODE_LOAD) && (id_rs1 == ex_rd)) begin
        fwd_id_rs1 = ex_mem.ex_result;
      end
      else if (mem_rd_valid && (id_rs1 == mem_rd)) begin
        if (mem_opcode == OPCODE_LOAD) begin
          fwd_id_rs1 = mem_wb.load_result;
        end else begin
          fwd_id_rs1 = mem_wb.ex_result;
        end
      end
    end
    if (!execute_stall && id_rs2_valid && (id_rs2 != REG_ZERO)) begin
      if (ex_rd_valid && (ex_opcode != OPCODE_LOAD) && (id_rs2 == ex_rd)) begin
        fwd_id_rs2 = ex_mem.ex_result;
      end
      else if (mem_rd_valid && (id_rs2 == mem_rd)) begin
        if (mem_opcode == OPCODE_LOAD) begin
          fwd_id_rs2 = mem_wb.load_result;
        end else begin
          fwd_id_rs2 = mem_wb.ex_result;
        end
      end
    end
    if (ex_rs2_valid && (ex_opcode == OPCODE_STORE) && (ex_rs2 != REG_ZERO)) begin
      if (mem_rd_valid && (ex_rs2 == mem_rd)) begin
        if (mem_opcode == OPCODE_LOAD) begin
          fwd_ex_rs2 = mem_wb.load_result;
        end else begin
          fwd_ex_rs2 = mem_wb.ex_result;
        end
      end
    end
  end

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      prev_mem_rd_num <= '0;
      prev_mem_fwd    <= '0;
    end else if (mem_rd_valid) begin
      prev_mem_rd_num <= mem_rd;
      if (mem_opcode == OPCODE_LOAD) begin
        prev_mem_fwd <= mem_wb.load_result;
      end else begin
        prev_mem_fwd <= mem_wb.ex_result;
      end
    end
  end

endmodule

/**************************************************************************************************
 * Fetch Stage Module
 **************************************************************************************************/

module core_fetch (
  input logic clk,
  input logic rst,
  input logic enable,
  input logic decode_ready,
  input addr_t pc,
  input inst_mem_rsp_t inst_mem_rsp,
  output inst_mem_req_t inst_mem_req,
  output if_id_t if_id,
  output logic ready
);

  inst_id_t cur_inst_id = '0;

  assign ready = enable && decode_ready && inst_mem_rsp.done;

  assign inst_mem_req.addr = pc;
  assign inst_mem_req.enable = enable;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      if_id = IF_ID_RST;
    end else if (decode_ready) begin
      if_id.inst    <= inst_mem_rsp.inst;
      if_id.pc      <= pc;
      if_id.valid   <= enable && inst_mem_rsp.done && inst_mem_rsp.valid;
      if_id.inst_id <= cur_inst_id++;
    end
  end

endmodule

/**************************************************************************************************
 * Decode Stage Module
 **************************************************************************************************/

module core_decode (
  input logic clk,
  input logic rst,
  input logic enable,
  input if_id_t if_id,
  input ex_mem_t ex_mem,
  input mem_wb_t mem_wb,
  input logic execute_ready,
  input logic branch_pred,
  input rf_read_rsp_t rs1_rsp,
  input rf_read_rsp_t rs2_rsp,
  output rf_read_req_t rs1_req,
  output rf_read_req_t rs2_req,
  output id_ex_t id_ex,
  output logic ready
);

  assign ready = enable && execute_ready && rs1_rsp.done && rs2_rsp.done;

  always @(*) begin
    rs1_req = RF_READ_REQ_RST;
    if (enable && if_id.valid && has_rs1(if_id.inst)) begin
      rs1_req.reg_num = get_rs1(if_id.inst);
      rs1_req.enable = '1;
    end
  end

  always @(*) begin
    rs2_req = RF_READ_REQ_RST;
    if (enable && if_id.valid && has_rs2(if_id.inst)) begin
      rs2_req.reg_num = get_rs2(if_id.inst);
      rs2_req.enable = '1;
    end
  end

  logic next_valid;
  always @(*) begin
    next_valid = '0;
    if (enable && if_id.valid && rs1_rsp.done && rs2_rsp.done) begin
      next_valid = '1;
      if (rs1_req.enable && !rs1_rsp.valid) begin
        next_valid = '0;
      end
      if (rs2_req.enable && !rs2_rsp.valid) begin
        next_valid = '0;
      end
    end
  end
  
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      id_ex = ID_EX_RST;
    end else if (execute_ready) begin
      id_ex.inst        <= if_id.inst;
      id_ex.pc          <= if_id.pc;
      id_ex.branch_pred <= branch_pred;
      id_ex.rs1_data    <= rs1_rsp.read_data;
      id_ex.rs2_data    <= rs2_rsp.read_data;
      id_ex.rd          <= get_rd(if_id.inst);
      id_ex.opcode      <= get_opcode(if_id.inst);
      id_ex.funct3      <= get_funct3(if_id.inst);
      id_ex.funct7      <= get_funct7(if_id.inst);
      id_ex.imm         <= get_imm(if_id.inst);
      id_ex.valid       <= next_valid;
      id_ex.inst_id     <= if_id.inst_id;
    end
  end

endmodule

/**************************************************************************************************
 * Execute Stage Module
 **************************************************************************************************/

module core_execute (
  input logic clk,
  input logic rst,
  input logic enable,
  input logic mem_ready,
  input id_ex_t id_ex,
  input reg_t fwd_id_rs1,
  input reg_t fwd_id_rs2,
  output ex_mem_t ex_mem,
  output logic ready
);

  assign ready = enable && mem_ready;

  reg_t next_ex_result;
  always @(*) begin
    next_ex_result = '0;
    case (id_ex.opcode)
      OPCODE_OP: begin
        case (id_ex.funct3)
          FUNCT3_OP_SLL: begin
            next_ex_result = fwd_id_rs1 << fwd_id_rs2[SHIFT_BITS-1:0];
          end
          FUNCT3_OP_SLT: begin
            next_ex_result = $signed(fwd_id_rs1) < $signed(fwd_id_rs2);
          end
          FUNCT3_OP_SLTU: begin
            next_ex_result = fwd_id_rs1 < fwd_id_rs2;
          end
          FUNCT3_OP_XOR: begin
            next_ex_result = fwd_id_rs1 ^ fwd_id_rs2;
          end
          FUNCT3_OP_OR: begin
            next_ex_result = fwd_id_rs1 | fwd_id_rs2;
          end
          FUNCT3_OP_AND: begin
            next_ex_result = fwd_id_rs1 & fwd_id_rs2;
          end
          FUNCT3_OP_ADD_SUB: begin
            if (id_ex.funct7 == FUNCT7_OP_ADD) begin
            next_ex_result = fwd_id_rs1 + fwd_id_rs2;
            end else if (id_ex.funct7 == FUNCT7_OP_SUB) begin
              next_ex_result = fwd_id_rs1 - fwd_id_rs2;
            end
          end
          FUNCT3_OP_SRL_SRA: begin
            if (id_ex.funct7 == FUNCT7_OP_SRL) begin
              next_ex_result = fwd_id_rs1 >> fwd_id_rs2[SHIFT_BITS-1:0];
            end else if (id_ex.funct7 == FUNCT7_OP_SRA) begin
              next_ex_result = fwd_id_rs1 >>> fwd_id_rs2[SHIFT_BITS-1:0];
            end
          end
        endcase
      end
      OPCODE_OP_IMM: begin
        case (id_ex.funct3)
          FUNCT3_OP_IMM_XORI: begin
            next_ex_result = fwd_id_rs1 ^ id_ex.imm;
          end
          FUNCT3_OP_IMM_ORI: begin
            next_ex_result = fwd_id_rs1 | id_ex.imm;
          end
          FUNCT3_OP_IMM_ANDI: begin
            next_ex_result = fwd_id_rs1 & id_ex.imm;
          end
          FUNCT3_OP_IMM_SLTI: begin
            next_ex_result = $signed(fwd_id_rs1) < $signed(id_ex.imm);
          end
          FUNCT3_OP_IMM_SLTIU: begin
            next_ex_result = fwd_id_rs1 < id_ex.imm;
          end
          FUNCT3_OP_IMM_SLLI: begin
            next_ex_result = fwd_id_rs1 << id_ex.imm[SHIFT_BITS-1:0];
          end
          FUNCT3_OP_IMM_ADDI: begin
            next_ex_result = fwd_id_rs1 + id_ex.imm;
          end
          FUNCT3_OP_IMM_SRAI_SRLI: begin
            if (id_ex.funct7 == FUNCT7_OP_IMM_SRAI) begin
              next_ex_result = fwd_id_rs1 >>> id_ex.imm[SHIFT_BITS-1:0];
            end else if (id_ex.funct7 == FUNCT7_OP_IMM_SRLI) begin
              next_ex_result = fwd_id_rs1 >> id_ex.imm[SHIFT_BITS-1:0];
            end
          end
        endcase
      end
      OPCODE_BRANCH: begin
        case (id_ex.funct3)
          FUNCT3_BRANCH_BEQ: begin
            next_ex_result = fwd_id_rs1 == fwd_id_rs2;
          end
          FUNCT3_BRANCH_BNE: begin
            next_ex_result = fwd_id_rs1 != fwd_id_rs2;
          end
          FUNCT3_BRANCH_BLT: begin
            next_ex_result = $signed(fwd_id_rs1) < $signed(fwd_id_rs2);
          end
          FUNCT3_BRANCH_BGE: begin
            next_ex_result = $signed(fwd_id_rs1) >= $signed(fwd_id_rs2);
          end
          FUNCT3_BRANCH_BLTU: begin
            next_ex_result = fwd_id_rs1 < fwd_id_rs2;
          end
          FUNCT3_BRANCH_BGEU: begin
            next_ex_result = fwd_id_rs1 >= fwd_id_rs2;
          end
        endcase
      end
      OPCODE_LUI: begin
        next_ex_result = id_ex.imm;
      end
      OPCODE_AUIPC: begin
        next_ex_result = id_ex.pc + id_ex.imm;
      end
      OPCODE_LOAD, OPCODE_STORE: begin
        next_ex_result = fwd_id_rs1 + id_ex.imm;
      end
      OPCODE_JAL, OPCODE_JALR: begin
        next_ex_result = id_ex.pc + 4;
      end
    endcase
  end

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      ex_mem <= EX_MEM_RST;
    end else if (mem_ready) begin
      ex_mem.inst         <= id_ex.inst;
      ex_mem.pc           <= id_ex.pc;
      ex_mem.branch_pred  <= id_ex.branch_pred;
      ex_mem.rs1_data     <= id_ex.rs1_data;
      ex_mem.rs2_data     <= id_ex.rs2_data;
      ex_mem.rd           <= id_ex.rd;
      ex_mem.opcode       <= id_ex.opcode;
      ex_mem.funct3       <= id_ex.funct3;
      ex_mem.funct7       <= id_ex.funct7;
      ex_mem.imm          <= id_ex.imm;
      ex_mem.ex_result    <= next_ex_result;
      ex_mem.valid        <= enable && id_ex.valid;
      ex_mem.inst_id      <= id_ex.inst_id;
    end
  end

endmodule

/**************************************************************************************************
 * Memory Stage Module
 **************************************************************************************************/

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

/**************************************************************************************************
 * Writeback Stage Module
 **************************************************************************************************/

 module core_writeback (
  input logic clk,
  input logic rst,
  input logic enable,
  input mem_wb_t mem_wb,
  input rf_write_rsp_t rd_rsp,
  output rf_write_req_t rd_req,
  output logic ready
);

  assign ready = enable && rd_rsp.done;

  always @(*) begin
    rd_req = RF_WRITE_REQ_RST;
    if (enable && mem_wb.valid) begin
      rd_req.reg_num = mem_wb.rd;
      rd_req.enable = '1;
      case (mem_wb.opcode)
        OPCODE_LOAD: begin
          rd_req.write_data = mem_wb.load_result;
        end
        OPCODE_AUIPC, OPCODE_LUI, OPCODE_OP, 
        OPCODE_OP_IMM, OPCODE_JAL, OPCODE_JALR: begin
          rd_req.write_data = mem_wb.ex_result;
        end
      endcase
    end
  end

endmodule

/**************************************************************************************************
 * Top Level 'Core' Module
 **************************************************************************************************/

 module core (
  input  logic clk,
  input  logic reset,
  input  logic [`word_address_size-1:0] reset_pc,
  output memory_io_req   inst_mem_req,
  input  memory_io_rsp   inst_mem_rsp,
  output memory_io_req   data_mem_req,
  input  memory_io_rsp   data_mem_rsp
);

  localparam int STOP_CYCLE = 100;
  localparam int FINISH_CYCLE = 10000;

  inst_mem_req_t w_inst_mem_req;
  data_mem_req_t w_data_mem_req;
  inst_mem_rsp_t w_inst_mem_rsp;
  data_mem_rsp_t w_data_mem_rsp;

  rf_read_req_t rs1_req;
  rf_read_req_t rs2_req;
  rf_write_req_t rd_req;

  rf_read_rsp_t rs1_rsp;
  rf_read_rsp_t rs2_rsp;
  rf_write_rsp_t rd_rsp;

  if_id_t if_id;
  id_ex_t id_ex;
  ex_mem_t ex_mem;
  mem_wb_t mem_wb;

  logic fetch_enable;
  logic decode_enable;
  logic execute_enable;
  logic mem_enable;
  logic wb_enable;

  logic fetch_rst;
  logic decode_rst;
  logic execute_rst;
  logic mem_rst;
  logic wb_rst;

  logic decode_ready;
  logic execute_ready;
  logic mem_ready;
  logic wb_ready;

  addr_t pc;
  logic branch_pred;
  logic miss_flush_flag;

  reg_t fwd_id_rs1;
  reg_t fwd_id_rs2;
  reg_t fwd_ex_rs2;

  logic core_halt = '0;
  logic execute_stall;
  logic fetch_stall;
  logic decode_stall;

  core_mem_wrapper core_mem_wrapper (
    .o_inst_mem_rsp(inst_mem_rsp),
    .o_data_mem_rsp(data_mem_rsp),
    .inst_mem_req(w_inst_mem_req),
    .data_mem_req(w_data_mem_req),
    .o_inst_mem_req(inst_mem_req),
    .o_data_mem_req(data_mem_req),
    .inst_mem_rsp(w_inst_mem_rsp),
    .data_mem_rsp(w_data_mem_rsp)
  );

  core_regfile core_regfile (
    .clk(clk),
    .rst(reset),
    .rs1_req(rs1_req),
    .rs2_req(rs2_req),
    .rd_req(rd_req),
    .rs1_rsp(rs1_rsp),
    .rs2_rsp(rs2_rsp),
    .rd_rsp(rd_rsp)
  );

  core_pc_manager core_pc_manager (
    .clk(clk),
    .rst(reset),
    .pc(pc),
    .rst_pc(reset_pc),
    .if_id(if_id),
    .id_ex(id_ex),
    .ex_mem(ex_mem),
    .mem_wb(mem_wb),
    .fetch_ready(fetch_ready),
    .flush_flag(miss_flush_flag),
    .branch_pred(branch_pred),
    .decode_stall(decode_stall)
  );

  core_hazard_unit core_hazard_unit (
    .clk(clk),
    .rst(reset),
    .if_id(if_id),
    .id_ex(id_ex),
    .ex_mem(ex_mem),
    .mem_wb(mem_wb),
    .fwd_id_rs1(fwd_id_rs1),
    .fwd_id_rs2(fwd_id_rs2),
    .fwd_ex_rs2(fwd_ex_rs2),
    .execute_stall(execute_stall),
    .fetch_stall(fetch_stall)
  );

  core_debug #(
    .STOP_CYCLE(STOP_CYCLE),
    .FINISH_CYCLE(FINISH_CYCLE)
  ) core_debug (
    .clk(clk),
    .if_id(if_id),
    .id_ex(id_ex),
    .ex_mem(ex_mem),
    .mem_wb(mem_wb),
    .data_mem_req(w_data_mem_req),
    .fwd_id_rs1(fwd_id_rs1),
    .fwd_id_rs2(fwd_id_rs2)
  );

  core_fetch core_fetch (
    .clk(clk),
    .rst(fetch_rst),
    .enable(fetch_enable),
    .pc(pc),
    .decode_ready(decode_ready),
    .inst_mem_rsp(w_inst_mem_rsp),
    .inst_mem_req(w_inst_mem_req),
    .if_id(if_id),
    .ready(fetch_ready)
  );

  core_decode core_decode (
    .clk(clk),
    .rst(decode_rst),
    .enable(decode_enable),
    .if_id(if_id),
    .execute_ready(execute_ready),
    .branch_pred(branch_pred),
    .rs1_rsp(rs1_rsp),
    .rs2_rsp(rs2_rsp),
    .rs1_req(rs1_req),
    .rs2_req(rs2_req),
    .id_ex(id_ex),
    .ready(decode_ready)
  );

  core_execute core_execute (
    .clk(clk),
    .rst(execute_rst),
    .enable(execute_enable),
    .mem_ready(mem_ready),
    .id_ex(id_ex),
    .fwd_id_rs1(fwd_id_rs1),
    .fwd_id_rs2(fwd_id_rs2),
    .ex_mem(ex_mem),
    .ready(execute_ready)
  );

  core_mem core_mem (
    .clk(clk),
    .rst(mem_rst),
    .enable(mem_enable),
    .ex_mem(ex_mem),
    .fwd_ex_rs2(fwd_ex_rs2),
    .wb_ready(wb_ready),
    .data_mem_rsp(w_data_mem_rsp),
    .data_mem_req(w_data_mem_req),
    .mem_wb(mem_wb),
    .ready(mem_ready)
  );

  core_writeback core_writeback (
    .clk(clk),
    .rst(wb_rst),
    .enable(wb_enable),
    .mem_wb(mem_wb),
    .rd_req(rd_req),
    .rd_rsp(rd_rsp),
    .ready(wb_ready)
  );

  always @(*) begin
    fetch_enable = !core_halt && !fetch_stall;
    decode_enable = !core_halt && !decode_stall;
    execute_enable = !core_halt && !execute_stall;
    mem_enable = !core_halt;
    wb_enable = !core_halt;
  end

  always @(*) begin
    fetch_rst = '0;
    decode_rst = '0;
    execute_rst = '0;
    mem_rst = '0;
    wb_rst = '0;
    if (reset) begin
      fetch_rst = '1;
      decode_rst = '1;
      execute_rst = '1;
      mem_rst = '1;
      wb_rst = '1;
    end else if (miss_flush_flag) begin
      fetch_rst = '1;
      decode_rst = '1;
    end
  end

endmodule

`endif // _lab6_sv