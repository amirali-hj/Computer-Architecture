module W_ROM #(
  parameter int N = 12,
  parameter int DEPTH = 8,
  parameter     FILE_NAME = "weights.mif"
)(
  input  logic                       clk,
  input  logic [3:0]   addr,
  input  logic                       en,
  output logic signed [N-1:0]        data_out
);
  logic signed [N-1:0] mem [0:DEPTH-1];
  logic signed [N-1:0] q;
  initial $readmemb(FILE_NAME, mem);
  always_ff @(posedge clk) if (en) q <= mem[addr];
  assign data_out = q;
endmodule
