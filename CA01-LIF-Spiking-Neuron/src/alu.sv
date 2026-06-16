module ALU #(
  parameter int N = 12       
)(
  input  logic signed [N-1:0] a   ,
  input  logic signed [N-1:0] b   ,
  input  logic        [2:0]   sel ,  
  output logic signed [N-1:0] y   ,
  output logic                cmp_ge
);
  localparam logic [2:0]
    ALU_ADD        = 3'd0,
    ALU_SHIFT_R1   = 3'd1,
    ALU_PASSA      = 3'd2,
    ALU_CMPGE      = 3'd3;

  always_comb begin
    y = '0; cmp_ge = 1'b0;
    unique case (sel)
      ALU_ADD  : y = a + b;
      ALU_SHIFT_R1  : y = b >>> 1;
      ALU_PASSA: y = b - a;
      ALU_CMPGE: cmp_ge = (a > b)? 1'b1:1'b0 ;
      default:y = '0 ;
    endcase
  end
endmodule
