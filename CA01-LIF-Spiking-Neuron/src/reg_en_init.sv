module reg_en_init #(
  parameter int N = 14
)(
  input  logic              clk,
  input  logic              rst,
  input  logic              init,     
  input  logic              ld,       
  input  logic signed [N-1:0] d_init,
  input  logic signed [N-1:0] d,
  output logic signed [N-1:0] q
);
  always_ff @(posedge clk or posedge rst) begin
    if (rst)       q <= '0;
    else if (init) q <= d_init;
    else if (ld)   q <= d;
  end
endmodule
