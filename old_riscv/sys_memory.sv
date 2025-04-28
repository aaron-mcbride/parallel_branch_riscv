
module sys_memory #(
  parameter int WIDTH = 32,
  parameter int LENGTH = 1024,
  parameter int READ_PORTS = 2,
  parameter int WRITE_PORTS = 1
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
)

  // Memory array
  logic [WIDTH-1:0] mem [LENGTH] = '{default: 0};

  // Next state variables
  logic [WIDTH-1:0] next_read_data [READ_PORTS];
  logic next_write_valid [WRITE_PORTS];
  logic next_read_valid [READ_PORTS];
  logic next_write_done [WRITE_PORTS];
  logic next_read_done [READ_PORTS];

  // Process read requests
  always_comb begin
    for (int i = 0; i < READ_PORTS; i++) begin
      next_read_data[i] = '0;
      next_read_valid[i] = '0;
      next_read_done[i] = '0;
      if (read_enable[i]) begin
        if (read_addr[i] < LENGTH) begin
          next_read_data[i] = mem[read_addr[i]];
          next_read_valid[i] = '1;
        end
        next_read_done[i] = '1;
      end
    end
  end

  // Process write requests
  always_comb begin
    for (int i = 0; i < LENGTH; i++) begin
      next_mem[i] = mem[i];
    end
    for (int i = 0; i < WRITE_PORTS; i++) begin
      next_write_valid[i] = '0;
      next_write_done[i] = '0;
      if (write_enable[i]) begin
        if (write_addr[i] < LENGTH) begin
          next_mem[write_addr[i]] = write_data[i];
          next_write_valid[i] = '1';
        end
        next_write_done[i] = '1';
      end
    end
  end

  // Sequential logic to update memory and output signals on clock edge or reset
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      for (int i = 0; i < LENGTH; i++) begin
        mem[i] <= '0;
      end
    end else begin
      for (int i = 0; i < LENGTH; i++) begin
        mem[i] <= next_mem[i];
      end
    end
    for (int i = 0; i < READ_PORTS; i++) begin
      read_data[i] <= next_read_data[i];
      read_valid[i] <= next_read_valid[i];
      read_done[i] <= next_read_done[i];
    end
    for (int i = 0; i < WRITE_PORTS; i++) begin
      write_valid[i] <= next_write_valid[i];
      write_done[i] <= next_write_done[i];
    end
  end

endmodule