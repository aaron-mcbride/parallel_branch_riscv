`ifndef __COMMON_SV__
`define __COMMON_SV__

// Package for boolean type definnition
package bool_type;

  // Boolean type definition
  typedef logic bool_t;

  // Boolean true/false constants
  localparam bool_t true  = '1;
  localparam bool_t false = '0;

endpackage

// RV32I ISA typedefs and constants
package rv32i;

    // Instruction field widths
    localparam int opcode_width = 7;
    localparam int funct3_width = 3;
    localparam int funct7_width = 7;
    localparam int imm_width    = 32;
    localparam int reg_cnt      = 32;
    localparam int reg_width    = 32;
    localparam int inst_width   = 32;

    // Instruction field types
    typedef logic [(opcode_width - 1):0] opcode_t;
    typedef logic [(funct3_width - 1):0] funct3_t;
    typedef logic [(funct7_width - 1):0] funct7_t;
    typedef logic [(imm_width - 1):0] imm_t;
    typedef logic [($clog2(reg_cnt) - 1):0] reg_num_t;
    typedef logic [(reg_width - 1):0] reg_t;
    typedef logic [(inst_width - 1):0] inst_t;

    // Extract opcode from instruction
    function automatic opcode_t get_opcode(inst_t inst);
      return inst[6:0];
    endfunction

    // Extract funct3 from instruction
    function automatic funct3_t get_funct3(inst_t inst);
      return inst[14:12];
    endfunction

    // Extract funct7 from instruction
    function automatic funct7_t get_funct7(inst_t inst);
      return inst[31:25];
    endfunction

    // Extract rs1 from instruction
    function automatic reg_num_t get_rs1_num(inst_t inst);
      return inst[19:15];
    endfunction

    // Extract rs2 from instruction
    function automatic reg_num_t get_rs2_num(inst_t inst);
      return inst[24:20];
    endfunction

    // Extract rd from instruction
    function automatic reg_num_t get_rd_num(inst_t inst);
      return inst[11:7];
    endfunction

    // Extract U-type immediate from instruction
    function automatic imm_t get_imm_u(inst_t inst);
      return {inst[31:12], 12'b0};
    endfunction

    // Extract I-type immediate from instruction
    function automatic imm_t get_imm_i(inst_t inst);
      return {{20{inst[31]}}, inst[31:20]};
    endfunction

    // Extract S-type immediate from instruction
    function automatic imm_t get_imm_s(inst_t inst);
      return {{20{inst[31]}}, inst[31:25], inst[11:7]};
    endfunction

    // Extract B-type immediate from instruction
    function automatic imm_t get_imm_b(inst_t inst);
      return {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    endfunction

    // Extract J-type immediate from instruction
    function automatic imm_t get_imm_j(inst_t inst);
      return {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
    endfunction

    // Opcode Constants
    localparam opcode_t opcode_load   = 'b0000011;
    localparam opcode_t opcode_store  = 'b0100011;
    localparam opcode_t opcode_branch = 'b1100011;
    localparam opcode_t opcode_jalr   = 'b1100111;
    localparam opcode_t opcode_jal    = 'b1101111;
    localparam opcode_t opcode_imm_op = 'b0010011;
    localparam opcode_t opcode_op     = 'b0110011;
    localparam opcode_t opcode_lui    = 'b0110111;
    localparam opcode_t opcode_auipc  = 'b0010111;
    localparam opcode_t opcode_sys    = 'b1110011;
    localparam opcode_t opcode_fence  = 'b0001111;

    // Funct3 constants for load instructions
    localparam funct3_t funct3_load_lb  = 'b000;
    localparam funct3_t funct3_load_lh  = 'b001;
    localparam funct3_t funct3_load_lw  = 'b010;
    localparam funct3_t funct3_load_lbu = 'b100;
    localparam funct3_t funct3_load_lhu = 'b101;

    // Funct3 constants for store instructions
    localparam funct3_t funct3_store_sb = 'b000;
    localparam funct3_t funct3_store_sh = 'b001;
    localparam funct3_t funct3_store_sw = 'b010;

    // Funct3 constants for branch instructions
    localparam funct3_t funct3_branch_beq  = 'b000;
    localparam funct3_t funct3_branch_bne  = 'b001;
    localparam funct3_t funct3_branch_blt  = 'b100;
    localparam funct3_t funct3_branch_bge  = 'b101;
    localparam funct3_t funct3_branch_bltu = 'b110;
    localparam funct3_t funct3_branch_bgeu = 'b111;

    // Funct3 constants for immediate operation instructions
    localparam funct3_t funct3_imm_op_addi      = 'b000;
    localparam funct3_t funct3_imm_op_slli      = 'b001;
    localparam funct3_t funct3_imm_op_slti      = 'b010;
    localparam funct3_t funct3_imm_op_sltiu     = 'b011;
    localparam funct3_t funct3_imm_op_xori      = 'b100;
    localparam funct3_t funct3_imm_op_ori       = 'b110;
    localparam funct3_t funct3_imm_op_andi      = 'b111;
    localparam funct3_t funct3_imm_op_srai_srli = 'b101;

    // Funct7 constants for immediate operation instruction
    localparam funct7_t funct7_imm_op_srai = 'b0100000;
    localparam funct7_t funct7_imm_op_srli = 'b0000000;

    // Funct3 constants for register operation instructions
    localparam funct3_t funct3_op_add_sub = 'b000;
    localparam funct3_t funct3_op_sll     = 'b001;
    localparam funct3_t funct3_op_slt     = 'b010;
    localparam funct3_t funct3_op_sltu    = 'b011;
    localparam funct3_t funct3_op_xor     = 'b100;
    localparam funct3_t funct3_op_or      = 'b110;
    localparam funct3_t funct3_op_and     = 'b111;
    localparam funct3_t funct3_op_srl_sra = 'b101;

    // Funct7 constants for register operation instructions
    localparam funct7_t funct7_op_add = 'b0000000;
    localparam funct7_t funct7_op_sub = 'b0100000;
    localparam funct7_t funct7_op_srl = 'b0000000;
    localparam funct7_t funct7_op_sra = 'b0100000;

    // Funct3 constants for system instructions
    localparam funct3_t funct3_sys_ecall  = 'b000;
    localparam funct3_t funct3_sys_ebreak = 'b000;

    // Funct7 constants for system instructions
    localparam funct7_t funct7_sys_ecall  = 'b0000000;
    localparam funct7_t funct7_sys_ebreak = 'b0000000;

    // Register constants
    localparam reg_num_t reg_zero = 'b00000;
    localparam reg_num_t reg_ra   = 'b00001;
    localparam reg_num_t reg_sp   = 'b00010;
    localparam reg_num_t reg_gp   = 'b00011;
    localparam reg_num_t reg_tp   = 'b00100;
    localparam reg_num_t reg_t0   = 'b00101;
    localparam reg_num_t reg_t1   = 'b00110;
    localparam reg_num_t reg_t2   = 'b00111;
    localparam reg_num_t reg_s0   = 'b01000;
    localparam reg_num_t reg_s1   = 'b01001;
    localparam reg_num_t reg_a0   = 'b01010;
    localparam reg_num_t reg_a1   = 'b01011;
    localparam reg_num_t reg_a2   = 'b01100;
    localparam reg_num_t reg_a3   = 'b01101;
    localparam reg_num_t reg_a4   = 'b01110;
    localparam reg_num_t reg_a5   = 'b01111;
    localparam reg_num_t reg_a6   = 'b10000;
    localparam reg_num_t reg_a7   = 'b10001;
    localparam reg_num_t reg_s2   = 'b10010;
    localparam reg_num_t reg_s3   = 'b10011;
    localparam reg_num_t reg_s4   = 'b10100;
    localparam reg_num_t reg_s5   = 'b10101;
    localparam reg_num_t reg_s6   = 'b10110;
    localparam reg_num_t reg_s7   = 'b10111;
    localparam reg_num_t reg_s8   = 'b11000;
    localparam reg_num_t reg_s9   = 'b11001;
    localparam reg_num_t reg_s10  = 'b11010;
    localparam reg_num_t reg_s11  = 'b11011;
    localparam reg_num_t reg_t3   = 'b11100;
    localparam reg_num_t reg_t4   = 'b11101;
    localparam reg_num_t reg_t5   = 'b11110;
    localparam reg_num_t reg_t6   = 'b11111;

endpackage

// System typedefs and constants
package sys;

  import bool_type::*;

  // System width constants
  localparam int addr_width = 32;
  localparam int word_width = 32;
  localparam int half_width = 16;
  localparam int byte_width = 8;

  // System size constants
  localparam int inst_size = (rv32i::inst_width / byte_width);
  localparam int addr_size = (addr_width / byte_width);
  localparam int word_size = (word_width / byte_width);
  localparam int half_size = (half_width / byte_width);

  // System types
  typedef logic [(addr_width - 1):0] addr_t;
  typedef logic [(word_width - 1):0] word_t;
  typedef logic [(half_width - 1):0] half_t;
  typedef logic [(byte_width - 1):0] byte_t;

  // Memory request size type
  typedef logic [($clog2(word_size) - 1):0] mem_req_size_t;

  // Memory read arguments
  typedef struct {
    addr_t addr;
    mem_req_size_t size;
    bool_t en;
  } mem_read_req_t;

  // Memory write request arguments
  typedef struct {
    addr_t addr;
    mem_req_size_t size;
    word_t data;
    bool_t en;
  } mem_write_req_t;

  // Memory read response arguments
  typedef struct {
    word_t data;
    bool_t done;
  } mem_read_rsp_t;

  // Memory write response arguments
  typedef struct {
    bool_t done;
  } mem_write_rsp_t;

  // Memory request/response reset constants
  localparam mem_read_req_t mem_read_req_rst   = '{default: '0};
  localparam mem_write_req_t mem_write_req_rst = '{default: '0};
  localparam mem_read_rsp_t mem_read_rsp_rst   = '{default: '0};
  localparam mem_write_rsp_t mem_write_rsp_rst = '{default: '0};

  // Size of memory blocks loaded by cache
  parameter int mem_block_size = 16;

  // Memory read block request arguments
  typedef struct {
    addr_t addr;
    bool_t en;
  } mem_read_block_req_t;

  // Memory read block response arguments
  typedef struct {
    byte_t data [mem_block_size];
    bool_t done;
  } mem_read_block_rsp_t;

  // Memory read block request/response reset constants
  parameter mem_read_block_req_t mem_read_block_req_rst = '{default: '0};
  parameter mem_read_block_rsp_t mem_read_block_rsp_rst = '{default: '0};

endpackage

// CPU core implementation typedefs and constants
package core;

  import bool_type::*;

  // Instruction fields and information
  typedef struct {
    rv32i::opcode_t opcode;
    rv32i::funct3_t funct3;
    rv32i::funct7_t funct7;
    rv32i::reg_num_t rs1_num;
    rv32i::reg_num_t rs2_num;
    rv32i::reg_num_t rd_num;
    rv32i::imm_t imm;
    bool_t has_rs1;
    bool_t has_rs2;
    bool_t has_rd;
  } de_inst_t;

  // Fetch/decode stage registers
  typedef struct {
    sys::addr_t pc;
    rv32i::inst_t inst;
    bool_t valid;
  } if_id_t;

  // Decode stage registers
  typedef struct {
    sys::addr_t pc;
    rv32i::inst_t inst;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    bool_t valid;
  } id_ex_t;

  // Execute stage registers
  typedef struct {
    sys::addr_t pc;
    rv32i::inst_t inst;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    rv32i::reg_t ex_result;
    sys::addr_t ex_addr;
    bool_t valid;
  } ex_mem_t;

  // Memory stage registers
  typedef struct {
    sys::addr_t pc;
    rv32i::inst_t inst;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    rv32i::reg_t ex_result;
    sys::addr_t ex_addr;
    rv32i::reg_t mem_result;
    bool_t valid;
  } mem_wb_t;

  // Pipeline register reset constants
  localparam if_id_t if_id_rst   = '{default: '0};
  localparam id_ex_t id_ex_rst   = '{default: '0};
  localparam ex_mem_t ex_mem_rst = '{default: '0};
  localparam mem_wb_t mem_wb_rst = '{default: '0};

  // Register forwarding arguments
  typedef struct {
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
  } reg_fwd_t;

  // Register file read request arguments
  typedef struct {
    rv32i::reg_num_t rs1_num;
    rv32i::reg_num_t rs2_num;
  } rf_read_req_t;

  // Register file write request arguments
  typedef struct {
    rv32i::reg_num_t rd_num;
    rv32i::reg_t rd_value;
    bool_t en;
  } rf_write_req_t;

  // Register file read response structure
  typedef struct {
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
  } rf_read_rsp_t;

  // Register struct reset constants
  localparam reg_fwd_t reg_fwd_rst           = '{default: '0};
  localparam rf_read_req_t rf_read_req_rst   = '{default: '0};
  localparam rf_write_req_t rf_write_req_rst = '{default: '0};
  localparam rf_read_rsp_t rf_read_rsp_rst   = '{default: '0};

  // Pipeline parallel evaluation width
  localparam int peval_width = 3;

  // Numeric type for parallel evaluation index
  typedef logic [($clog2(peval_width) - 1):0] peval_idx_t;

  // Numeric types for stage indicies
  typedef logic [($clog2(peval_width ** 2) - 1):0] if_idx_t;
  typedef logic [($clog2(peval_width) - 1):0] id_idx_t;

  // Target prediction request arguments
  typedef struct {
    sys::addr_t base_pc;
  } targ_pred_req_t;

  // Target prediction response arguments
  typedef struct {
    sys::addr_t targ_list [peval_width];
    peval_idx_t targ_cnt;
  } targ_pred_rsp_t;

  // Target prediction feedback arguments
  typedef struct {
    sys::addr_t base_pc;
    sys::addr_t targ_pc;
    bool_t valid;
  } targ_pred_fb_t;

  // Branch prediction request arguments
  typedef struct {
    sys::addr_t base_pc;
  } branch_pred_req_t;

  // Branch prediction response arguments
  typedef struct {
    bool_t branch_taken;
    bool_t eval_alt;
  } branch_pred_rsp_t;

  // Branch prediction feedback arguments
  typedef struct {
    sys::addr_t base_pc;
    sys::addr_t targ_pc;
    bool_t branch_taken;
    bool_t valid;
  } branch_pred_fb_t;

  // Branch/target prediction reset constants
  localparam targ_pred_req_t targ_pred_req_rst     = '{default: '0};
  localparam targ_pred_rsp_t targ_pred_rsp_rst     = '{default: '0};
  localparam targ_pred_fb_t targ_pred_fb_rst       = '{default: '0};
  localparam branch_pred_req_t branch_pred_req_rst = '{default: '0};
  localparam branch_pred_rsp_t branch_pred_rsp_rst = '{default: '0};
  localparam branch_pred_fb_t branch_pred_fb_rst   = '{default: '0};

  // Instruction fetch request arguments
  typedef struct {
    sys::addr_t pc;
    bool_t en;
  } inst_fetch_req_t;

  // Instruction fetch response arguments
  typedef struct {
    rv32i::inst_t inst;
    bool_t done;
  } inst_fetch_rsp_t;

  // Instruction fetch request/response reset constants
  parameter inst_fetch_req_t inst_fetch_req_rst = '{default: '0};
  parameter inst_fetch_rsp_t inst_fetch_rsp_rst = '{default: '0};

endpackage

// Utility macros and functions
package util;

  // Sign extends byte to word
  function automatic sys::word_t sext_byte(input sys::byte_t value);
    return {{(sys::word_width - sys::byte_width){value[sys::byte_width - 1]}}, value};
  endfunction

  // Sign extends half to word
  function automatic sys::word_t sext_half(input sys::half_t value);
    return {{(sys::word_width - sys::half_width){value[sys::half_width - 1]}}, value};
  endfunction

  // Aligns address to lower word size boundary
  function automatic sys::addr_t align_word(input sys::addr_t addr);
    return addr - (addr % sys::word_size);
  endfunction

  // Aligns an address to lower instruction size boundary
  function automatic sys::addr_t align_inst(input sys::addr_t addr);
    return addr - (addr % sys::inst_size);
  endfunction

endpackage

`endif // __COMMON_SV__