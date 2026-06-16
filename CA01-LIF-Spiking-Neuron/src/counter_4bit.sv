module counter_4bit (
  input  logic       clk  ,
  input  logic       rst  ,
  input  logic       init ,
  input  logic       en   ,
  output logic [3:0] count,
  output logic       last
);
  always_ff @(posedge clk or posedge rst) begin
    if (rst)       count <= 4'd0;
    else if (init) count <= 4'd0;
    else if (en)   count <= count + 4'd1;
  end
  assign last = (count == 4'd15);
endmodule
