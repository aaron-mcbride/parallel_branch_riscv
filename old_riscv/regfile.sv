`include "common.sv"

`ifndef __REGFILE_SV__
`define __REGFILE_SV__

/**
 * Register File Module
 *
 * Configurable register file with parameterized read/write ports.
 * Supports special handling for register 0 and custom reset values.
 *
 * Parameters:
 *   WIDTH       [int] - Bit width of each register (default: 32)
 *   LENGTH      [int] - Number of registers (default: 32)
 *   READ_PORTS  [int] - Number of read ports (default: 2)
 *   WRITE_PORTS [int] - Number of write ports (default: 1)
 *   ZERO_REG_EN [bit] - When 1, register 0 is always 0 (default: 1)
 *   RST_DATA    [WIDTH-1:0][LENGTH] - Initial register values (default: all 0s)
 *
 * Ports:
 *   clk          [1-bit]  - Clock input
 *   rst          [1-bit]  - Reset input (active high)
 *   read_addr    [$clog2(LENGTH)-1:0][READ_PORTS] - Read address for each port
 *   write_addr   [$clog2(LENGTH)-1:0][WRITE_PORTS] - Write address for each port
 *   read_enable  [1-bit][READ_PORTS] - Enable signal for read operations
 *   write_enable [1-bit][WRITE_PORTS] - Enable signal for write operations
 *   write_data   [WIDTH-1:0][WRITE_PORTS] - Data to write to registers
 *   read_data    [WIDTH-1:0][READ_PORTS] - Data read from registers
 *   write_valid  [1-bit][WRITE_PORTS] - Indicates valid write operation
 *   read_valid   [1-bit][READ_PORTS] - Indicates valid read operation
 *   write_done   [1-bit][WRITE_PORTS] - Indicates write operation completion
 *   read_done    [1-bit][READ_PORTS] - Indicates read operation completion
 */
module regfile #(
  parameter int WIDTH = 32,
  parameter int LENGTH = 32,
  parameter int READ_PORTS = 2,
  parameter int WRITE_PORTS = 1,
  parameter bit ZERO_REG_EN = 1,
  parameter logic [WIDTH-1:0] RST_DATA [LENGTH] = '{default: 0} 
) (
  input logic clk,
  input logic rst,
  input logic [$clog2(LENGTH)-1:0] read_addr [READ_PORTS],
  input logic [$clog2(LENGTH)-1:0] write_addr [WRITE_PORTS],
  input logic read_enable [READ_PORTS],
  input logic write_enable [WRITE_PORTS],
  input logic [WIDTH-1:0] write_data [WRITE_PORTS],
  output logic [WIDTH-1:0] read_data [READ_PORTS],
  output logic write_valid [WRITE_PORTS],
  output logic read_valid [READ_PORTS],
  output logic write_done [WRITE_PORTS],
  output logic read_done [READ_PORTS]
);

  // Regfile memory
  logic [WIDTH-1:0] reg_mem [LENGTH] = '{default: 0};

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_mem[0] <= ZERO_REG_EN ? '0 : RST_DATA[0];
      for (int i = 1; i < LENGTH; i++) begin
        reg_mem[i] <= RST_DATA[i];
      end
    end else begin
      for (int i = 0; i < WRITE_PORTS; i++) begin
        write_valid[i] <= '0;
        write_done[i] <= '0;
        if (write_enable[i]) begin
          
          if (write_addr[i] < LENGTH) begin

          end
        end
      end


    end
  end


`endif // __REGFILE_SV__