module mux2 #(
  parameter int N = 14
)(
  input  logic                 sel,
  input  logic signed [N-1:0]  d0,
  input  logic signed [N-1:0]  d1,
  output logic signed [N-1:0]  y
);
  assign y = sel ? d1 : d0;
endmodule
