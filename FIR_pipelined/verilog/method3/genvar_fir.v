module genvar_fir #(
    parameter a = 2,
    parameter b = 14,
    parameter taps = 100
) (
    input clk,
    input rst,
    input en,
    input  signed [a+b:0] x,
    output signed [a+b:0] y,
    output data_valid
);

    localparam W      = a + b + 1;   // 17
    localparam CW     = 16;          // coefficient width
    localparam PROD_W = W + CW;      // 33
    localparam ACC_W  = 42;          // wide accumulator

    wire signed [CW-1:0] h [0:taps-1];
    wire signed [ACC_W-1:0] accum [0:taps];
    wire signed [W-1:0] x_wire [0:taps];
    wire en_wire [0:taps];

    assign accum[0]   = 0;
    assign x_wire[0]  = x;
    assign en_wire[0] = en;

    assign data_valid = en_wire[taps];
    assign y = sat_shift(accum[taps]);

    // =========================================================
    // Coefficients
    // =========================================================
    assign h[0]  = -16'sd3;
    assign h[1]  = -16'sd7;
    assign h[2]  = -16'sd9;
    assign h[3]  = -16'sd8;
    assign h[4]  = -16'sd3;
    assign h[5]  =  16'sd4;
    assign h[6]  =  16'sd11;
    assign h[7]  =  16'sd15;
    assign h[8]  =  16'sd14;
    assign h[9]  =  16'sd6;
    assign h[10] = -16'sd7;
    assign h[11] = -16'sd21;
    assign h[12] = -16'sd29;
    assign h[13] = -16'sd26;
    assign h[14] = -16'sd11;
    assign h[15] =  16'sd13;
    assign h[16] =  16'sd38;
    assign h[17] =  16'sd52;
    assign h[18] =  16'sd47;
    assign h[19] =  16'sd20;
    assign h[20] = -16'sd22;
    assign h[21] = -16'sd64;
    assign h[22] = -16'sd87;
    assign h[23] = -16'sd78;
    assign h[24] = -16'sd33;
    assign h[25] =  16'sd36;
    assign h[26] =  16'sd104;
    assign h[27] =  16'sd141;
    assign h[28] =  16'sd125;
    assign h[29] =  16'sd52;
    assign h[30] = -16'sd57;
    assign h[31] = -16'sd164;
    assign h[32] = -16'sd222;
    assign h[33] = -16'sd197;
    assign h[34] = -16'sd83;
    assign h[35] =  16'sd91;
    assign h[36] =  16'sd263;
    assign h[37] =  16'sd360;
    assign h[38] =  16'sd324;
    assign h[39] =  16'sd139;
    assign h[40] = -16'sd156;
    assign h[41] = -16'sd465;
    assign h[42] = -16'sd661;
    assign h[43] = -16'sd625;
    assign h[44] = -16'sd285;
    assign h[45] =  16'sd352;
    assign h[46] =  16'sd1194;
    assign h[47] =  16'sd2077;
    assign h[48] =  16'sd2811;
    assign h[49] =  16'sd3227;
    assign h[50] =  16'sd3227;
    assign h[51] =  16'sd2811;
    assign h[52] =  16'sd2077;
    assign h[53] =  16'sd1194;
    assign h[54] =  16'sd352;
    assign h[55] = -16'sd285;
    assign h[56] = -16'sd625;
    assign h[57] = -16'sd661;
    assign h[58] = -16'sd465;
    assign h[59] = -16'sd156;
    assign h[60] =  16'sd139;
    assign h[61] =  16'sd324;
    assign h[62] =  16'sd360;
    assign h[63] =  16'sd263;
    assign h[64] =  16'sd91;
    assign h[65] = -16'sd83;
    assign h[66] = -16'sd197;
    assign h[67] = -16'sd222;
    assign h[68] = -16'sd164;
    assign h[69] = -16'sd57;
    assign h[70] =  16'sd52;
    assign h[71] =  16'sd125;
    assign h[72] =  16'sd141;
    assign h[73] =  16'sd104;
    assign h[74] =  16'sd36;
    assign h[75] = -16'sd33;
    assign h[76] = -16'sd78;
    assign h[77] = -16'sd87;
    assign h[78] = -16'sd64;
    assign h[79] = -16'sd22;
    assign h[80] =  16'sd20;
    assign h[81] =  16'sd47;
    assign h[82] =  16'sd52;
    assign h[83] =  16'sd38;
    assign h[84] =  16'sd13;
    assign h[85] = -16'sd11;
    assign h[86] = -16'sd26;
    assign h[87] = -16'sd29;
    assign h[88] = -16'sd21;
    assign h[89] = -16'sd7;
    assign h[90] =  16'sd6;
    assign h[91] =  16'sd14;
    assign h[92] =  16'sd15;
    assign h[93] =  16'sd11;
    assign h[94] =  16'sd4;
    assign h[95] = -16'sd3;
    assign h[96] = -16'sd8;
    assign h[97] = -16'sd9;
    assign h[98] = -16'sd7;
    assign h[99] = -16'sd3;

    genvar i;
    generate
        for (i = 0; i < taps; i = i + 1) begin : gen_fir_cells
            fir_cell #(
                .a(a),
                .b(b),
                .CW(CW),
                .ACC_W(ACC_W)
            ) cell_inst (
                .clk(clk),
                .rst(rst),
                .en_in(en_wire[i]),
                .ai(x_wire[i]),
                .bi(accum[i]),
                .h(h[i]),
                .en_out(en_wire[i+1]),
                .ao(x_wire[i+1]),
                .bo(accum[i+1])
            );
        end
    endgenerate

    function signed [W-1:0] sat_shift;
        input signed [ACC_W-1:0] acc_in;
        reg signed [ACC_W-1:0] shifted;
        reg signed [W-1:0] max_val;
        reg signed [W-1:0] min_val;
    begin
        shifted = acc_in >>> b;

        max_val = {1'b0, {(W-1){1'b1}}};
        min_val = {1'b1, {(W-1){1'b0}}};

        if (shifted > max_val)
            sat_shift = max_val;
        else if (shifted < min_val)
            sat_shift = min_val;
        else
            sat_shift = shifted[W-1:0];
    end
    endfunction

endmodule


module fir_cell #(
    parameter a = 2,
    parameter b = 14,
    parameter CW = 16,
    parameter ACC_W = 42
) (
    input clk,
    input rst,
    input en_in,
    input signed [a+b:0] ai,
    input signed [ACC_W-1:0] bi,
    input signed [CW-1:0] h,
    output reg en_out,
    output reg signed [a+b:0] ao,
    output reg signed [ACC_W-1:0] bo
);

    localparam W      = a + b + 1;
    localparam PROD_W = W + CW;

    reg signed [W-1:0] a_delay;
    wire signed [PROD_W-1:0] product;
    wire signed [ACC_W-1:0] product_ext;
    wire signed [ACC_W-1:0] add_out;

    assign product     = ai * h;
    assign product_ext = {{(ACC_W-PROD_W){product[PROD_W-1]}}, product};
    assign add_out     = bi + product_ext;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_delay <= 0;
            ao      <= 0;
            bo      <= 0;
            en_out  <= 0;
        end
        else if (!en_in) begin
            a_delay <= 0;
            ao      <= 0;
            bo      <= 0;
            en_out  <= 0;
        end
        else begin
            a_delay <= ai;
            ao      <= a_delay;
            bo      <= add_out;
            en_out  <= en_in;
        end
    end

endmodule