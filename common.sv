`ifndef __COMMON_SV__
`define __COMMON_SV__

// Global boolean type
`ifndef __BOOL_TYPE__
  `define __BOOL_TYPE__
  typedef logic bool;
  localparam bool true  = '1;
  localparam bool false = '0;
`endif

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
    typedef logic [($clog2(reg_cnt) - 1):0] reg_addr_t;
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
    function automatic reg_addr_t get_rs1(inst_t inst);
      return inst[19:15];
    endfunction

    // Extract rs2 from instruction
    function automatic reg_addr_t get_rs2(inst_t inst);
      return inst[24:20];
    endfunction

    // Extract rd from instruction
    function automatic reg_addr_t get_rd(inst_t inst);
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
    localparam reg_addr_t reg_zero = 'b00000;
    localparam reg_addr_t reg_ra   = 'b00001;
    localparam reg_addr_t reg_sp   = 'b00010;
    localparam reg_addr_t reg_gp   = 'b00011;
    localparam reg_addr_t reg_tp   = 'b00100;
    localparam reg_addr_t reg_t0   = 'b00101;
    localparam reg_addr_t reg_t1   = 'b00110;
    localparam reg_addr_t reg_t2   = 'b00111;
    localparam reg_addr_t reg_s0   = 'b01000;
    localparam reg_addr_t reg_s1   = 'b01001;
    localparam reg_addr_t reg_a0   = 'b01010;
    localparam reg_addr_t reg_a1   = 'b01011;
    localparam reg_addr_t reg_a2   = 'b01100;
    localparam reg_addr_t reg_a3   = 'b01101;
    localparam reg_addr_t reg_a4   = 'b01110;
    localparam reg_addr_t reg_a5   = 'b01111;
    localparam reg_addr_t reg_a6   = 'b10000;
    localparam reg_addr_t reg_a7   = 'b10001;
    localparam reg_addr_t reg_s2   = 'b10010;
    localparam reg_addr_t reg_s3   = 'b10011;
    localparam reg_addr_t reg_s4   = 'b10100;
    localparam reg_addr_t reg_s5   = 'b10101;
    localparam reg_addr_t reg_s6   = 'b10110;
    localparam reg_addr_t reg_s7   = 'b10111;
    localparam reg_addr_t reg_s8   = 'b11000;
    localparam reg_addr_t reg_s9   = 'b11001;
    localparam reg_addr_t reg_s10  = 'b11010;
    localparam reg_addr_t reg_s11  = 'b11011;
    localparam reg_addr_t reg_t3   = 'b11100;
    localparam reg_addr_t reg_t4   = 'b11101;
    localparam reg_addr_t reg_t5   = 'b11110;
    localparam reg_addr_t reg_t6   = 'b11111;

endpackage

// Memory system typedefs and constants
package mem;

  // System size constants
  localparam int addr_width = 32;
  localparam int word_width = 32;
  localparam int half_width = 16;
  localparam int byte_width = 8;

  // System types
  typedef logic [word_width-1:0] word_t;
  typedef logic [addr_width-1:0] addr_t;

  // Memory request mask type
  typedef logic [(word_width/byte_width)-1:0] mem_req_mask_t;

  // Memory request mask constants
  localparam mem_req_mask_t mem_req_byte_mask = 'b0001;
  localparam mem_req_mask_t mem_req_half_mask = 'b0011;
  localparam mem_req_mask_t mem_req_word_mask = 'b1111;

  // Memory read arguments
  typedef struct packed {
    addr_t addr;
    mem_req_mask_t mask;
    bool en;
  } mem_read_req_t;

  // Memory write request arguments
  typedef struct packed {
    addr_t addr;
    word_t data;
    mem_req_mask_t mask;
    bool en;
  } mem_write_req_t;

  // Memory read response arguments
  typedef struct packed {
    addr_t addr;
    word_t data;
    bool valid;
    bool done;
  } mem_read_rsp_t;

  // Memory write response arguments
  typedef struct packed {
    bool valid;
    bool done;
  } mem_write_rsp_t;

  // Memory request/response reset constants
  localparam mem_read_req_t mem_read_req_rst   = '0;
  localparam mem_write_req_t mem_write_req_rst = '0;
  localparam mem_read_rsp_t mem_read_rsp_rst   = '0;
  localparam mem_write_rsp_t mem_write_rsp_rst = '0;

endpackage

// CPU core implementation typedefs and constants
package core;

  // Instruction fields
  typedef struct packed {
    rv32i::opcode_t opcode;
    rv32i::funct7_t funct7;
    rv32i::funct3_t funct3;
    rv32i::reg_addr_t rs1;
    rv32i::reg_addr_t rs2;
    rv32i::reg_addr_t rd;
    rv32i::imm_t imm;
    bool has_rs1;
    bool has_rs2;
    bool has_rd;
  } de_inst_t;

  // Fetch/decode stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    bool valid;
  } if_id_t;

  // Decode/read stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    de_inst_t de_inst;
    bool valid;
  } id_rd_t;

  // Read/execute stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    bool valid;
  } rd_ex_t;

  // Execute/memory stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    rv32i::reg_t ex_result;
    sys::addr_t ex_addr;
    sys::mem_req_mask_t ex_mask;
    bool rd_rdy;
    bool valid;
  } ex_mem;

  // Memory/assemble stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    rv32i::reg_t ex_result;
    sys::addr_t ex_addr;
    sys::word_t mem_result;
    bool rd_rdy;
    bool valid;
  } mem_asm_t;

  // Assemble/writeback stage pipeline registers
  typedef struct packed {
    rv32i::inst_t inst;
    rv32i::addr_t pc;
    de_inst_t de_inst;
    rv32i::reg_t rs1_value;
    rv32i::reg_t rs2_value;
    rv32i::reg_t asm_result;
    bool valid;
  } asm_wb_t;

  // Pipeline register reset constants
  localparam de_inst_t de_inst_rst = '0;
  localparam if_id_t if_id_rst     = '0;
  localparam id_rd_t id_rd_rst     = '0;
  localparam rd_ex_t rd_ex_rst     = '0;
  localparam ex_mem_t ex_mem_rst   = '0;
  localparam mem_asm_t mem_asm_rst = '0;
  localparam asm_wb_t asm_wb_rst   = '0;

  // Register bypassing info
  typedef struct packed {
    rv32i::reg_t byp_rs1_value;
    rv32i::reg_t byp_rs2_value;
    bool byp_rs1_valid;
    bool byp_rs2_valid;
  } reg_byp_t;

  // Register file read request arguments
  typedef struct packed {
    rv32i::reg_addr_t reg_addr;
    bool en;
  } rf_read_req_t;

  // Register file write request arguments
  typedef struct packed {
    rv32i::reg_addr_t reg_addr;
    rv32i::reg_t value;
    bool en;
  } rf_write_req_t;

  // Register file read response arguments
  typedef struct packed {
    rv32i::reg_t value;
    bool valid;
  } rf_read_rsp_t;

  // Register file write response arguments
  typedef struct packed {
    bool valid;
    bool done;
  } rf_write_rsp_t;

  // Regfile/forwarding unit reset constants
  localparam reg_fwd_t reg_fwd_rst           = '0;
  localparam rf_read_req_t rf_read_req_rst   = '0;
  localparam rf_write_req_t rf_write_req_rst = '0;
  localparam rf_read_rsp_t rf_read_rsp_rst   = '0;
  localparam rf_write_rsp_t rf_write_rsp_rst = '0;

  // Max number of predictions from target predictor
  localparam int max_targ_pred_cnt = 3;

  // Numeric type to represent index of target prediction
  typedef logic [($clog2(max_targ_pred_cnt) - 1):0] targ_pred_index_t;

  // Target prediction request arguments
  typedef struct packed {
    sys::addr_t base_pc;
    bool valid;
  } targ_pred_req_t;

  // Target prediction response arguments
  typedef struct packed {
    sys::addr_t pred_pc [max_targ_pred_cnt];
    targ_pred_index_t pred_cnt;
  } targ_pred_rsp_t;

  // Target prediction feedback information
  typedef struct packed {
    sys::addr_t base_pc;
    sys::addr_t targ_pc;
    bool valid;
  } targ_pred_fb_t;

  // Target predictor request/response/feedback reset constants
  localparam targ_pred_req_t targ_pred_req_rst = '0;
  localparam targ_pred_rsp_t targ_pred_rsp_rst = '0;
  localparam targ_pred_fb_t targ_pred_fb_rst = '0;

  // Branch prediction request arguments
  typedef struct packed {
    sys::addr_t base_pc;
    sys::addr_t targ_pc;
    bool valid;
  } branch_pred_req_t;

  // Branch prediction response arguments
  typedef struct packed {
    bool pred_taken;
    bool exec_alt;
    bool valid;
  } branch_pred_rsp_t;

  // Branch prediction feedback information
  typedef struct packed {
    sys::addr_t base_pc;
    sys::addr_t targ_pc;
    bool taken;
    bool valid;
  } branch_pred_fb_t;

  // Branch predictor request/response/feedback reset constants
  localparam branch_pred_req_t branch_pred_req_rst = '0;
  localparam branch_pred_rsp_t branch_pred_rsp_rst = '0;
  localparam branch_pred_fb_t branch_pred_fb_rst = '0;  

endpackage

package util;

  // Creates a bit mask with the specified length and position.
  function automatic sys::word_t get_mask(input int len, input int pos);
    return {len{1'b1}} << pos;
  endfunction

  // Moves a value into the position of a field at the specified position.
  function automatic sys::word_t v2f(input sys::word_t value, input int len, input int pos);
    return (value & get_mask(len, pos)) << pos;
  endfunction

  // Extracts a value from a field at the specified position.
  function automatic sys::word_t f2v(input sys::word_t value, input int len, input int pos);
    return (value >> pos) & get_mask(len, pos);
  endfunction

  // Gets the offset of a memory address in bytes (from word aligned address).
  function automatic sys::addr_t addr_off(input sys::addr_t addr);
    return addr[($clog2(sys::word_width/sys::byte_width) - 1):0];
  endfunction

  // Aligns a memory address to the nearest word boundary.
  function automatic sys::addr_t align_addr(input sys::addr_t addr);
    return addr[(sys::addr_width - 1):$clog2(sys::word_width/sys::byte_width)];
  endfunction

  // Sign extends a value (x) from src_len to dst_len (given in bits).
  function automatic sys::word_t sext(input int dst_len, input int src_len, input sys::word_t value);
    return {{(dst_len - src_len){value[src_len - 1]}}, value[(src_len - 1):0]};
  endfunction

endpackage

`endif // __COMMON_SV__