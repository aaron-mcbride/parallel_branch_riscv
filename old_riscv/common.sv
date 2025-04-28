`ifndef __COMMON_SV__
`define __COMMON_SV__

// System size constants
localparam int WORD_SIZE = 32; // Size of value stored at each address in memory (in bits)
localparam int ADDR_SIZE = 32; // Size of memory address (in bits)

// System size types
typedef logic [WORD_SIZE-1:0] word_t; // Type with size of value stored at each address
typedef logic [ADDR_SIZE-1:0] addr_t; // Type with size of memory adress

// Instruction format constants
localparam int INST_SIZE   = 32; // Size of individual instruction (in bits)
localparam int REG_COUNT   = 32; // Number of registers in the register file
localparam int OPCODE_SIZE = 7;  // Size of opcode field (in bits)
localparam int FUNCT3_SIZE = 3;  // Size of funct3 field (in bits)
localparam int FUNCT7_SIZE = 7;  // Size of funct7 field (in bits)
localparam int IMM_SIZE    = 32; // Size of largest immediate value in instruction (in bits)

// Instruction format types
typedef logic [INST_SIZE-1:0] inst_t;    // Type with size of instruction
typedef logic [REG_COUNT-1:0] reg_num_t; // Type with size of register number/address
typedef logic [6:0]           opcode_t;  // Type with size of opcode field in instruction
typedef logic [2:0]           funct3_t;  // Type with size of funct3 field in instruction
typedef logic [6:0]           funct7_t;  // Type with size of funct7 field in instruction
typedef logic [IMM_SIZE-1:0]  imm_t;     // Type with size of largest immediate field in instruction

// Opcode Constants
localparam opcode_t OPCODE_LOAD   = 'b0000011;
localparam opcode_t OPCODE_STORE  = 'b0100011;
localparam opcode_t OPCODE_BRANCH = 'b1100011;
localparam opcode_t OPCODE_JALR   = 'b1100111;
localparam opcode_t OPCODE_JAL    = 'b1101111;
localparam opcode_t OPCODE_IMM_OP = 'b0010011;
localparam opcode_t OPCODE_OP     = 'b0110011;
localparam opcode_t OPCODE_LUI    = 'b0110111;
localparam opcode_t OPCODE_AUIPC  = 'b0010111;
localparam opcode_t OPCODE_SYSTEM = 'b1110011;
localparam opcode_t OPCODE_FENCE  = 'b0001111;

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
localparam funct3_t FUNCT3_IMM_OP_ADDI      = 'b000;
localparam funct3_t FUNCT3_IMM_OP_SLLI      = 'b001;
localparam funct3_t FUNCT3_IMM_OP_SLTI      = 'b010;
localparam funct3_t FUNCT3_IMM_OP_SLTIU     = 'b011;
localparam funct3_t FUNCT3_IMM_OP_XORI      = 'b100;
localparam funct3_t FUNCT3_IMM_OP_ORI       = 'b110;
localparam funct3_t FUNCT3_IMM_OP_ANDI      = 'b111;
localparam funct3_t FUNCT3_IMM_OP_SRAI_SRLI = 'b101;

// Funct7 Immediate ALU Constants
localparam funct7_t FUNCT7_IMM_OP_SRAI = 'b0100000;
localparam funct7_t FUNCT7_IMM_OP_SRLI = 'b0000000;

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

// Extract opcode
function automatic opcode_t get_opcode(input inst_t inst);
  return inst[6:0];
endfunction

// Extract rd
function automatic reg_num_t get_rd(input inst_t inst);
  return inst[11:7];
endfunction

// Extract rs1
function automatic reg_num_t get_rs1(input inst_t inst);
  return inst[19:15];
endfunction

// Extract rs2
function automatic reg_num_t get_rs2(input inst_t inst);
  return inst[24:20];
endfunction

// Extract funct3
function automatic funct3_t get_funct3(input inst_t inst);
  return inst[14:12];
endfunction

// Extract funct7
function automatic funct7_t get_funct7(input inst_t inst);
  return inst[31:25];
endfunction

// Extract immediate value
function automatic imm_t get_imm(input inst_t inst);
  case (get_opcode(inst))
    OPCODE_LUI:     return {inst[31:12], 12'b0};
    OPCODE_AUIPC:   return {inst[31:12], 12'b0};
    OPCODE_JAL:     return {{11{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    OPCODE_JALR:    return {{20{inst[31]}}, inst[31:20]};
    OPCODE_BRANCH:  return {{19{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    OPCODE_LOAD:    return {{20{inst[31]}}, inst[31:20]};
    OPCODE_STORE:   return {{20{inst[31]}}, inst[31:25], inst[11:7]};
    OPCODE_OP_IMM:  return {{20{inst[31]}}, inst[31:20]};
    default:        return 0;
  endcase
endfunction

// Determines if instruction contains rs1 field
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

// Determines if instruction contains rs2 field
function automatic logic has_rs2(input inst_t inst);
  opcode_t opcode = get_opcode(inst);
  return (
    opcode == OPCODE_STORE ||
    opcode == OPCODE_OP    ||
    opcode == OPCODE_BRANCH);
endfunction 

// Determines if instruction contains rd field
function automatic logic has_rd(input inst_t inst);
  opcode_t opcode = get_opcode(inst);
  return (
    opcode == OPCODE_OP     ||
    opcode == OPCODE_OP_IMM ||
    opcode == OPCODE_LOAD   ||
    opcode == OPCODE_LUI    ||
    opcode == OPCODE_AUIPC  ||
    opcode == OPCODE_JAL    ||
    opcode == OPCODE_JALR);
endfunction

// Determines the offset of an address
function automatic int get_addr_off(input addr_t addr);
  return addr[1:0];
endfunction

// Memory ready request arguments
typedef struct packed {
  addr_t addr; // Address to read from
  word_t mask; // Mask for read operation
  logic en;    // Enable signal for the read request
} mem_read_req_t;

// Memory read response arguments
typedef struct packed {
  logic valid; // Active high if read request was valid
  logic done;  // Active high if read operation is done
  word_t data; // Data read from memory
} mem_read_rsp_t;

// Memory write request arguments
typedef struct packed {
  addr_t addr; // Address to write to
  word_t data; // Data to write to memory
  word_t mask; // Mask for write operation
  logic en;    // Enable signal for the write request
} mem_write_req_t;

// Memory write response arguments
typedef struct packed {
  logic valid; // Active high if write request was valid
  logic done;  // Active high if write operation is done
} mem_write_rsp_t;

// Bypass unit register values
typedef struct packed {
  word_t rs1_value; // Value of RS1 from bypass unit
  word_t rs2_value; // Value of RS2 from bypass unit
} bypass_t;

// Registers between fetch and decode stages
typedef struct packed {
  inst_t inst; // Instruction fetched from memory
  addr_t pc;   // Address of instruction
  logic valid; // Active high if if_id data is valid
} if_id_t;

// Registers between decode and execute stages
typedef struct packed {
  inst_t inst;     // Current instruction
  addr_t pc;       // Address of current instruction
  opcode_t opcode; // Opcode of current instruction
  funct3_t funct3; // Funct3 of current instruction
  funct7_t funct7; // Funct7 of current instruction
  reg_num_t rs1;   // Source register 1
  reg_num_t rs2;   // Source register 2
  word_t rs1_data; // Data from source register 1
  word_t rs2_data; // Data from source register 2
  reg_num_t rd;    // Destination register
  logic has_rs1;   // Active high if rs1 is used in instruction
  logic has_rs2;   // Active high if rs2 is used in instruction
  logic has_rd;    // Active high if rd is used in instruction
  imm_t imm;       // Immediate value from instruction
  logic valid;     // Active high if id_ex data is valid
} id_ex_t;

typedef struct packed {
  inst_t inst;      // Current instruction
  addr_t pc;        // Address of current instruction
  opcode_t opcode;  // Opcode of current instruction
  funct3_t funct3;  // Funct3 of current instruction
  funct7_t funct7;  // Funct7 of current instruction
  reg_num_t rs1;    // Source register 1
  reg_num_t rs2;    // Source register 2
  word_t rs1_data;  // Data from source register 1
  word_t rs2_data;  // Data from source register 2
  reg_num_t rd;     // Destination register
  logic has_rs1;    // Active high if rs1 is used in instruction
  logic has_rs2;    // Active high if rs2 is used in instruction
  logic has_rd;     // Active high if rd is used in instruction
  imm_t imm;        // Immediate value from instruction
  word_t ex_result; // Result of execution stage computation
  logic valid;      // Active high if id_ex data is valid
} ex_mem_t;

typedef struct packed {
  inst_t inst;       // Current instruction
  addr_t pc;         // Address of current instruction
  opcode_t opcode;   // Opcode of current instruction
  funct3_t funct3;   // Funct3 of current instruction
  funct7_t funct7;   // Funct7 of current instruction
  reg_num_t rs1;     // Source register 1
  reg_num_t rs2;     // Source register 2
  word_t rs1_data;   // Data from source register 1
  word_t rs2_data;   // Data from source register 2
  reg_num_t rd;      // Destination register
  logic has_rs1;     // Active high if rs1 is used in instruction
  logic has_rs2;     // Active high if rs2 is used in instruction
  logic has_rd;      // Active high if rd is used in instruction
  imm_t imm;         // Immediate value from instruction
  word_t ex_result;  // Result of execution stage computation
  word_t mem_result; // Result of memory stage (for load operations)
  logic valid;       // Active high if ex_mem data is valid
} mem_wb_t;

`endif // __COMMON_SV__