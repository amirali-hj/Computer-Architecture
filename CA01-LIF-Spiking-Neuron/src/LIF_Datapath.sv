module LIF_Datapath #(
  parameter int N     = 12,
  parameter int DEPTH = 8
)(
  input  logic                    clk,
  input  logic                    rst,

  input  logic [7:0]              input_spikes,
  input  logic signed [N-1:0]     Vrest_in,
  input  logic                    Vrest_en,
  input  logic signed [N-1:0]     Vth_in,
  input  logic                    Vth_en,

  input  logic                    cnt_init,
  input  logic                    cnt_en,
  input  logic                    acc_clr,
  input  logic                    ld_ACC,
  input  logic                    ld_I,
  input  logic                    V_init,
  input  logic                    V_ld,
  input  logic                    Vnext_ld,
  input  logic                    Vnext_init,
  input  logic                    spikes_ld,
  input  logic        [2:0]       alu_sel_a,
  input  logic        [2:0]       alu_sel_b,
  input  logic        [2:0]       alu_op,

  output logic        [3:0]       addr,
  output logic                    cmp_ge,

  output logic signed [N-1:0]     V_out
);
  logic signed [N-1:0]     weight_n, V_reg, Vrest_reg, Vth_reg, I_reg, Vnext_reg;
  logic [7:0]              spike_reg;
  logic signed [N-1:0]     alu_output , ACC_w , alu_input_a , alu_input_b;

  // ----------- counter & ROM ----------
  counter_4bit u_cnt(
    .clk(clk), 
    .rst(rst), 
    .init(cnt_init), 
    .en(cnt_en), 
    .count(addr), 
    .last(cnt_last)
  );
  W_ROM #(.N(N), .DEPTH(DEPTH)) u_rom(
    .clk(clk), 
    .addr(addr), 
    .en(1'b1), 
    .data_out(weight_n)
  );

  // ----------- spike reg ----------
  reg_en_init #(.N(8)) u_spike(
    .clk(clk),
    .rst(rst),
    .init(1'b0),      
    .ld(spikes_ld),
    .d_init(8'b0),   
    .d(input_spikes),
    .q(spike_reg)
  );

  logic [N-1:0] weight_mux;
  mux2 #(.N(N)) u_mux_c(
    .sel(spike_reg[addr]), 
    .d1(weight_n), 
    .d0('0), 
    .y(weight_mux[N-1:0])
  );

  // ----------- parameter regs ----------
  reg_en_init #(.N(N)) u_vrest(
    .clk(clk),
    .rst(rst),
    .init(1'b0),     
    .ld(Vrest_en),
    .d_init('0),  
    .d(Vrest_in),
    .q(Vrest_reg)
  );

  reg_en_init #(.N(N)) u_vth(
    .clk(clk),
    .rst(rst),
    .init(1'b0),   
    .ld(Vth_en),
    .d_init('0),     
    .d(Vth_in),
    .q(Vth_reg)
  );

  // ----------- V / Vnext ----------
  reg_en_init #(.N(N)) u_v(
    .clk(clk),
    .rst(rst),
    .init(V_init),
    .ld(V_ld),
    .d_init(Vrest_reg),
    .d(Vnext_reg),
    .q(V_reg)
  );

  reg_en_init #(.N(N)) u_vnext(
    .clk(clk),
    .rst(rst),
    .init(Vnext_init),    
    .ld(Vnext_ld),
    .d_init(Vrest_reg),      
    .d(alu_output[N-1:0]),
    .q(Vnext_reg)
  );

  // ----------- ACC & I ----------
  reg_en_init #(.N(N)) u_acc(
    .clk(clk),
    .rst(rst),
    .init(acc_clr),
    .ld(ld_ACC),
    .d_init('0),
    .d(alu_output),
    .q(ACC_w[N-1:0])
  );

  reg_en_init #(.N(N)) u_I(
    .clk(clk),
    .rst(rst),
    .init(1'b0),  
    .ld(ld_I),
    .d_init('0), 
    .d(ACC_w[N-1:0]),
    .q(I_reg)
  );

  // ----------- ALU muxes ----------
  mux_a_wide #(.N(N)) u_mux_a (
    .sel(alu_sel_a),
    .Vnext(Vnext_reg),
    .Vrest(Vrest_reg),
    .I_reg(I_reg),
    .Vth(Vth_reg),
    .Acc_reg(ACC_w),
    .V_reg(V_reg),
    .Y(alu_input_a)
  );

  mux_b_wide #(.N(N)) u_mux_b (
    .sel(alu_sel_b),
    .V_reg(V_reg),
    .Vrest(Vrest_reg),
    .Z_or_W(weight_mux),
    .Acc_reg(ACC_w),
    .I_reg(I_reg),
    .Vnext(Vnext_reg),
    .Vth(Vth_reg),
    .Y(alu_input_b)
  );

  // ----------- ALU ----------
  ALU #(.N(N)) u_alu (
    .a(alu_input_a), 
    .b(alu_input_b), 
    .sel(alu_op),
    .y(alu_output), 
    .cmp_ge(cmp_ge)
  );

  assign V_out = V_reg;
endmodule
