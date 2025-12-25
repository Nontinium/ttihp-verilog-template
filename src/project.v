`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    
    output reg [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);
    
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Using 18-bit signed to ensure precision and prevent overflow
    wire signed [7:0] h0, h1, h2, h3;
    wire signed [11:0] e0, e1, e2, e3, e4, e5, e6, e7, e8, e9;

    // LAYER 1: Hidden Neurons (Weights + Intercepts*10)
    assign h0 = (ui_in[0]?24:0)+(ui_in[1]?-6:0)+(ui_in[2]?-15:0)+(ui_in[3]?18:0)+(ui_in[4]?-20:0)+(ui_in[5]?-9:0)+(ui_in[6]?9:0) - 2;
    assign h1 = (ui_in[0]?-2:0)+(ui_in[1]?-21:0)+(ui_in[2]?15:0)+(ui_in[3]?-12:0)+(ui_in[4]?-11:0)+(ui_in[5]?-18:0)+(ui_in[6]?18:0) + 7;
    assign h2 = (ui_in[0]? 6:0)+(ui_in[1]? 2:0)+(ui_in[2]?-5:0)+(ui_in[3]?-3:0)+(ui_in[4]? 7:0)+(ui_in[5]?-16:0)+(ui_in[6]?-17:0) + 8;
    assign h3 = (ui_in[0]? 7:0)+(ui_in[1]?19:0)+(ui_in[2]?14:0)+(ui_in[3]?-13:0)+(ui_in[4]?-17:0)+(ui_in[5]?-10:0)+(ui_in[6]?-11:0) - 1;

    // LAYER 2: Output Scores (Weights + Intercepts*100)
    assign e0 = (-19 * h0) + (-18 * h1) + ( 9 * h2) + (-2 * h3) - 60;
    assign e1 = (-13 * h0) + (  2 * h1) + ( 8 * h2) + ( 9 * h3) + 140;
    assign e2 = ( 13 * h0) + (-11 * h1) + (12 * h2) + (-10 * h3) - 40;
    assign e3 = ( 20 * h0) + ( 14 * h1) + ( 5 * h2) + ( 10 * h3) + 50;
    assign e4 = (-17 * h0) + (  9 * h1) + (-14 * h2) + ( 2 * h3) + 20;
    assign e5 = (  7 * h0) + ( 15 * h1) + (-17 * h2) + (-6 * h3) - 70;
    assign e6 = ( -8 * h0) + (  8 * h1) + ( -9 * h2) + (-21 * h3) + 50;
    assign e7 = (  6 * h0) + (  1 * h1) + (  9 * h2) + ( 20 * h3) - 10;
    assign e8 = ( -9 * h0) + (-12 * h1) + (-12 * h2) + ( -8 * h3) - 20;
    assign e9 = ( 10 * h0) + ( -9 * h1) + (-15 * h2) + ( 10 * h3) - 110;

    reg signed [11:0] max_val;
    reg [3:0] prediction;

    // Argmax Logic
    always @(*) begin
        max_val = e0;
        prediction = 4'd0;

        if (e1 > max_val) begin max_val = e1; prediction = 4'd1; end
        if (e2 > max_val) begin max_val = e2; prediction = 4'd2; end
        if (e3 > max_val) begin max_val = e3; prediction = 4'd3; end
        if (e4 > max_val) begin max_val = e4; prediction = 4'd4; end
        if (e5 > max_val) begin max_val = e5; prediction = 4'd5; end
        if (e6 > max_val) begin max_val = e6; prediction = 4'd6; end
        if (e7 > max_val) begin max_val = e7; prediction = 4'd7; end
        if (e8 > max_val) begin max_val = e8; prediction = 4'd8; end
        if (e9 > max_val) begin max_val = e9; prediction = 4'd9; end 
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'b0;
        end else begin

            uo_out <= {4'b0000, prediction}; 
        end
    end

    wire _unused = &{ena, ui_in[7], uio_in, 1'b0};

    
endmodule
