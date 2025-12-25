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

    // Bit-widths updated for experimental coefficients + intercepts
    wire signed [8:0] h0_raw, h2_raw, h3_raw;
    wire signed [8:0] h0, h2, h3; // ReLU outputs
    wire signed [13:0] e0, e1, e2, e3, e4, e5, e6, e7, e8, e9;

    // --- LAYER 1: New Hidden Weights + Intercepts (Scaled x10) ---
    assign h0_raw = (ui_in[0]?-3:0)+(ui_in[1]?-5:0)+(ui_in[3]?4:0)+(ui_in[4]?-1:0)+(ui_in[6]?-2:0);
    assign h2_raw = (ui_in[0]?28:0)+(ui_in[1]?19:0)+(ui_in[2]?-24:0)+(ui_in[3]?15:0)+(ui_in[4]?37:0)+(ui_in[5]?-37:0)+(ui_in[6]?29:0) + 5;
    assign h3_raw = (ui_in[0]?23:0)+(ui_in[1]?36:0)+(ui_in[2]?32:0)+(ui_in[3]?-9:0)+(ui_in[4]?3:0)+(ui_in[5]?-28:0)+(ui_in[6]?-30:0) + 9;

    // --- ReLU LAYER ---
    assign h0 = (h0_raw[8]) ? 9'd0 : h0_raw;
    assign h2 = (h2_raw[8]) ? 9'd0 : h2_raw;
    assign h3 = (h3_raw[8]) ? 9'd0 : h3_raw;

    // --- LAYER 2: New Output Weights + Intercepts (Scaled x100) ---
    assign e0 = (-6 * h0) + (-1 * h2) + (23 * h3) - 180;
    assign e1 = ( 5 * h0) + (-38 * h2) + (32 * h3) - 120;
    assign e2 = ( 5 * h0) + ( 36 * h2) + (-30 * h3) - 280;
    assign e3 = ( 3 * h0) + ( 17 * h2) + ( 8 * h3) - 350;
    assign e4 = (-3 * h0) + (-27 * h2) + (20 * h3) + 380;
    assign e5 = (-4 * h0) + ( 23 * h2) + (-29 * h3) + 360;
    assign e6 = ( 3 * h0) + ( 36 * h2) + (-48 * h3) - 30;
    assign e7 = (-1 * h0) + (-17 * h2) + (31 * h3) - 340;
    assign e8 = (-6 * h0) + ( 28 * h2) + (-13 * h3) - 90;
    assign e9 = (-1 * h0) + ( 7 * h2) + ( 4 * h3) + 350;

    reg signed [13:0] max_val;
    reg [3:0] prediction;

    // Argmax Logic
    // Tournament Bracket - Round 1
    wire signed [13:0] m01, m23, m45, m67, m89;
    wire [3:0] p01, p23, p45, p67, p89;
    
    assign {m01, p01} = (e0 >= e1) ? {e0, 4'd0} : {e1, 4'd1};
    assign {m23, p23} = (e2 >= e3) ? {e2, 4'd2} : {e3, 4'd3};
    assign {m45, p45} = (e4 >= e5) ? {e4, 4'd4} : {e5, 4'd5};
    assign {m67, p67} = (e6 >= e7) ? {e6, 4'd6} : {e7, 4'd7};
    assign {m89, p89} = (e8 >= e9) ? {e8, 4'd8} : {e9, 4'd9};

    // Round 2
    wire signed [13:0] m03, m47;
    wire [3:0] p03, p47;
    
    assign {m03, p03} = (m01 >= m23) ? {m01, p01} : {m23, p23};
    assign {m47, p47} = (m45 >= m67) ? {m45, p45} : {m67, p67};

    // Round 3 (Semi-Finals)
    wire signed [13:0] m07;
    wire [3:0] p07;
    assign {m07, p07} = (m03 >= m47) ? {m03, p03} : {m47, p47};

    // Round 4 (Finals)
    wire [3:0] final_prediction;
    assign final_prediction = (m07 >= m89) ? p07 : p89;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'b0;
        end else begin

            uo_out <= {4'b0000, prediction}; 
        end
    end

    wire _unused = &{ena, ui_in[7], uio_in, 1'b0};

    
endmodule

`default_nettype wire
