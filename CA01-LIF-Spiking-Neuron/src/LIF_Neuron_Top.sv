module LIF_Neuron #(
  parameter int N=12, DEPTH=8
)(
  input  logic                  clk,
  input  logic                  rst,
  input  logic                  start,
  input  logic [7:0]            input_spikes,

  input  logic                  Vrest_en,
  input  logic signed [N-1:0]   Vrest_in,
  input  logic                  Vth_en,
  input  logic signed [N-1:0]   Vth_in,

  output logic                  spike_out,
  output logic                  valid,

  output logic signed [N-1:0]   V_out
);

  logic cnt_init, cnt_en, acc_clr, ld_ACC, ld_I, V_init, Vnext_init, V_ld, Vnext_ld, spikes_ld;
  logic [2:0] alu_sel_a, alu_sel_b, alu_op;
  logic [3:0] addr;
  logic       cmp_ge;
  logic signed [N-1:0] V_mon;

  LIF_Datapath #(.N(N), .DEPTH(DEPTH)) u_dp (
    .clk        (clk),
    .rst        (rst),
    .input_spikes(input_spikes),
    .Vrest_in   (Vrest_in),
    .Vrest_en   (Vrest_en),
    .Vth_in     (Vth_in),
    .Vth_en     (Vth_en),

    .cnt_init   (cnt_init),
    .cnt_en     (cnt_en),
    .acc_clr    (acc_clr),
    .ld_ACC     (ld_ACC),
    .ld_I       (ld_I),
    .V_init     (V_init),
    .V_ld       (V_ld),
    .Vnext_ld   (Vnext_ld),
    .Vnext_init (Vnext_init),
    .spikes_ld  (spikes_ld),

    .alu_sel_a  (alu_sel_a),
    .alu_sel_b  (alu_sel_b),
    .alu_op     (alu_op),

    .addr       (addr),
    .cmp_ge     (cmp_ge),
    .V_out      (V_mon)
  );

  LIF_Ctrl u_ctrl (
    .clk        (clk),
    .rst        (rst),
    .start      (start),

    .addr       (addr),
    .cmp_ge     (cmp_ge),

    .Vrest_en   (Vrest_en),
    .Vth_en     (Vth_en),  

    .cnt_init   (cnt_init),
    .cnt_en     (cnt_en),
    .acc_clr    (acc_clr),
    .ld_ACC     (ld_ACC),
    .ld_I       (ld_I),
    .V_init     (V_init),
    .V_ld       (V_ld),
    .Vnext_ld   (Vnext_ld),
    .Vnext_init (Vnext_init),
    .spikes_ld  (spikes_ld),

    .alu_sel_a  (alu_sel_a),
    .alu_sel_b  (alu_sel_b),
    .alu_op     (alu_op),

    .spike_out  (spike_out),
    .valid      (valid)
  );

  assign V_out = V_mon;

endmodule
