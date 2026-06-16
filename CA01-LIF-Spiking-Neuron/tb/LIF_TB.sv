`timescale 1ns/1ps

module our_tb_variant;

    // --- Inputs ---
    reg clk;
    reg rst;
    reg start;
    reg [7:0] input_spikes;
    reg [11:0] Vth_in;
    reg [11:0] Vrest_in;
    reg Vth_en;
    reg Vrest_en;

    // --- Outputs ---
    wire valid;
    wire spike_out;
    wire signed [11:0] V_out;

    // --- Instantiate TOP module ---
    LIF_Neuron DUT_TOP (
        .clk(clk),
        .rst(rst),
        .start(start),
        .input_spikes(input_spikes),
        .Vth_in(Vth_in),
        .Vrest_in(Vrest_in),
        .Vth_en(Vth_en),
        .Vrest_en(Vrest_en),
        .valid(valid),
        .spike_out(spike_out),
        .V_out(V_out) 
    );

    // --- Clock generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        start = 0;
        input_spikes = 8'b00000000;
        Vth_in   = 12'b000100000000; 
        Vrest_in = 12'b111111100110; 
        Vth_en = 0;
        Vrest_en = 0;

    
        #20 rst = 0;


        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b11111011; 

        Vth_en = 1;
        Vrest_en = 1;

        #15 Vth_en = 0;
        #5  Vrest_en = 0;

        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00011010;
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00010001; 
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00000010;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b01010111;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00111101;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10011100;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b01011110;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b01110000;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10101010;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10101110;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00000101;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b11110111;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10100111;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b11110000;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10100010;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10101010;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10110110;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00010000;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00001100;  
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b00000111; 
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b11111100;
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b10010010;
        #500;

        #10 start = 1;
        #20 start = 0;
        input_spikes = 8'b01100001; 
        #500;

        #200 $stop;
    end

// --- Monitor output signals ---
    initial begin
        $monitor("T=%0t | valid=%b spike_out=%b V_out=%0d",
                 $time, valid, spike_out, V_out);  // 👈 اضافه‌شده برای مشاهده V_out
    end


endmodule
