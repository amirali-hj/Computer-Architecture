module mux_a_wide #(
  parameter int N = 12
)(
  input  logic [2:0]       sel,
  input  logic signed [N-1:0] Vnext,
  input  logic signed [N-1:0] Vrest,
  input  logic signed [N-1:0] I_reg,
  input  logic signed [N-1:0] Vth,
  input  logic signed [N-1:0] Acc_reg,
  input  logic signed [N-1:0] V_reg,
  output logic signed [N-1:0] Y
);

  localparam logic [2:0] SEL_ACC    = 3'd0;
  localparam logic [2:0] SEL_I      = 3'd1;
  localparam logic [2:0] SEL_V      = 3'd2;
  localparam logic [2:0] SEL_VREST  = 3'd3;
  localparam logic [2:0] SEL_VNEXT  = 3'd4;
  localparam logic [2:0] SEL_VTH    = 3'd5;

  always_comb begin
    unique case (sel)
      SEL_ACC:    Y = Acc_reg;
      SEL_I:      Y = I_reg;
      SEL_V:      Y = V_reg;
      SEL_VREST:  Y = Vrest;
      SEL_VNEXT:  Y = Vnext;
      SEL_VTH:    Y = Vth;
      default:    Y = '0;
    endcase
  end

endmodule
