
module LIF_Ctrl #(
  parameter int N  = 12
) (
  input  logic              clk,
  input  logic              rst,

  input  logic              start,       
  input  logic              Vrest_en,    
  input  logic              Vth_en,      

  input  logic [3:0]        addr,   
  input  logic              cmp_ge,     

  output logic              cnt_init,
  output logic              cnt_en,
  output logic              acc_clr,
  output logic              ld_ACC,
  output logic              ld_I,
  output logic              V_init,
  output logic              V_ld,
  output logic              Vnext_ld,
  output  logic              Vnext_init,
  output logic              spikes_ld,
  output logic [2:0]        alu_sel_a,
  output logic [2:0]        alu_sel_b,
  output logic [2:0]        alu_op,

  output logic              valid,       
  output logic              spike_out    
);

  localparam logic [2:0] SEL_ACC     = 3'd0;
  localparam logic [2:0] SEL_I       = 3'd1;
  localparam logic [2:0] SEL_V       = 3'd2;
  localparam logic [2:0] SEL_VREST   = 3'd3;
  localparam logic [2:0] SEL_VNEXT   = 3'd4;
  localparam logic [2:0] SEL_VTH     = 3'd5;
  localparam logic [2:0] SEL_WEIGHT  = 3'd6;

  localparam logic [2:0] OP_ADD      = 3'd0;
  localparam logic [2:0] OP_SHIFT_R1 = 3'd1;
  localparam logic [2:0] OP_PASS_A   = 3'd2;
  localparam logic [2:0] OP_CMP_GE   = 3'd3;

  typedef enum logic [4:0] {
    S_IDLE,        
    S_INIT,         
    S_SPIKE_LD,      
    S_CALC_I,       
    S_I_READY,      
    S_HALF_VREST,   
    S_ALPHA_VREST,  
    S_SUM,          
    S_HALF_V,      
    S_DIV4_V,   
    S_MINALP_V,        
    S_FUTURE_V,        
    S_COMP_V,  
    S_ISS1_V,
    S_ISS2_V
  } state_t;

  state_t state, state_n;


  always_comb begin
    
    cnt_init   = 1'b0;
    cnt_en     = 1'b0;
    acc_clr    = 1'b0;
    ld_ACC     = 1'b0;
    ld_I       = 1'b0;
    V_init     = 1'b0;
    V_ld       = 1'b0;
    Vnext_ld   = 1'b0;
    Vnext_init = 1'b0;
    spikes_ld  = 1'b0;
    
    
    alu_sel_a  = SEL_ACC;
    alu_sel_b  = SEL_ACC;
    alu_op     = OP_PASS_A;

    
    state_n = state;



    
    if (Vrest_en)
      V_init = 1'b1;

    unique case (state)
      
      S_IDLE: begin
        if (start) state_n = S_INIT;
      end

      
      S_INIT: begin
        acc_clr  = 1'b1;
        cnt_init = 1'b1;
        V_ld     = 1'b1;
        if (!start) state_n  = S_SPIKE_LD;
        else state_n = S_INIT;
      end

      
      S_SPIKE_LD: begin
        spikes_ld = 1'b1;
        valid = 1'b0;
        spike_out = 1'b0;
        state_n = S_CALC_I;
      end

      
      S_CALC_I: begin
        alu_sel_a  = SEL_ACC;
        alu_sel_b  = SEL_WEIGHT;
        alu_op     = OP_ADD;
        ld_ACC     = 1'b1;
        cnt_en     = 1'b1;
        state_n = S_I_READY;
      end

      
      S_I_READY: begin
        ld_I    = 1'b1;
        if (!addr[3]) 
        state_n = S_CALC_I;
        else
        state_n = S_HALF_VREST;
      end

      
      S_HALF_VREST: begin
       
        alu_sel_b = SEL_VREST;
        alu_op    = OP_SHIFT_R1;
        ld_ACC    = 1'b1;
        state_n   = S_ALPHA_VREST;
      end

      
      S_ALPHA_VREST: begin
        
        alu_sel_b = SEL_ACC;
        alu_op    = OP_SHIFT_R1;
        ld_ACC    = 1'b1;
        state_n   = S_SUM;
      end

      
      S_SUM: begin
       
        alu_sel_a = SEL_I;
        alu_sel_b = SEL_ACC;
        alu_op    = OP_ADD;
        ld_ACC    = 1'b1;
        state_n   = S_HALF_V;
      end

      
      S_HALF_V: begin
        
        alu_sel_b = SEL_V;
        alu_op    = OP_SHIFT_R1;
        ld_I      = 1'b1;
        ld_ACC    = 1'b1;
        state_n   = S_DIV4_V;
      end

      
      S_DIV4_V: begin
        
        alu_sel_b = SEL_ACC;     
        alu_op    = OP_SHIFT_R1;
        Vnext_ld  = 1'b1;
        state_n   = S_MINALP_V;
      end

      
      S_MINALP_V: begin
        
        alu_sel_a = SEL_VNEXT; 
        alu_sel_b = SEL_V;
        alu_op    = OP_PASS_A;
        Vnext_ld  = 1'b1;
        state_n   = S_FUTURE_V;
      end

      
      S_FUTURE_V: begin
        
        alu_sel_a = SEL_VNEXT;
        alu_sel_b = SEL_I;
        alu_op    = OP_ADD;
        Vnext_ld  = 1'b1;     
        state_n   = S_COMP_V;
      end

      
      S_COMP_V: begin
        
        alu_sel_a = SEL_VNEXT;
        alu_sel_b = SEL_VTH;
        alu_op    = OP_CMP_GE;   
        if(cmp_ge)  
          state_n  = S_ISS1_V;
        else
          state_n = S_ISS2_V;
      end


      S_ISS1_V: begin
        
        V_init = 1'b1;  
        Vnext_init = 1'b1;  
        spike_out = 1'b1;
        valid     = 1'b1;      
        state_n  = S_IDLE;
      end


      S_ISS2_V: begin
        V_init = 1'b0;
        V_ld = 1'b1;
        valid =1'b1;
        state_n  = S_IDLE;
      end


      default: state_n = S_IDLE;
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state     <= S_IDLE;
    end else begin
      state     <= state_n;
    end
  end

endmodule
