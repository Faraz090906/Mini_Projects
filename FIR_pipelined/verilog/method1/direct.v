module direct #(
    parameter a = 2,
    parameter b = 14,
    parameter taps = 100
) (
    input clk,
    input rst,
    input  signed [a+b:0] x,
    output reg signed [a+b:0] y
);

    localparam W      = a + b + 1;   // 17
    localparam CW     = 16;          // coefficient width
    localparam PROD_W = W + CW;      // 33
    localparam ACC_W  = 42;          // wide accumulator

    wire signed [CW-1:0] h [0:taps-1];

    reg signed [W-1:0]      x_reg [0:taps-1];
    reg signed [PROD_W-1:0] prod;
    reg signed [ACC_W-1:0]  acc;
    reg signed [ACC_W-1:0]  sum_full;
    reg signed [ACC_W-1:0]  shifted;

    reg signed [W-1:0] max_out;
    reg signed [W-1:0] min_out;

    reg [7:0] k;
    integer i;

    // =========================================================
    // Filter coefficients (Q2.14 format)
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

    // =========================================================
    // Shift register
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < taps; i = i + 1)
                x_reg[i] <= 0;
        end
        else if (k == 0) begin
            for (i = taps-1; i > 0; i = i - 1)
                x_reg[i] <= x_reg[i-1];
            x_reg[0] <= x;
        end
    end

    // =========================================================
    // Serial iterative MAC
    // No intermediate truncation/saturation
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc      <= 0;
            prod     <= 0;
            sum_full <= 0;
            shifted  <= 0;
            y        <= 0;
            k        <= 0;
        end
        else begin
            if (k == 0) begin
                acc  <= 0;
                prod <= x * h[0];
                k    <= 1;
            end
            else if (k < taps) begin
                acc  <= acc + prod;
                prod <= x_reg[k] * h[k];
                k    <= k + 1;
            end
            else begin
                sum_full <= acc + prod;
                shifted  <= (sum_full) >>> b;

                max_out = {1'b0, {(W-1){1'b1}}};
                min_out = {1'b1, {(W-1){1'b0}}};

                if (shifted > max_out)
                    y <= max_out;
                else if (shifted < min_out)
                    y <= min_out;
                else
                    y <= shifted;

                k <= 0;
            end
        end
    end

endmodule