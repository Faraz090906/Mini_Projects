module optimized #(
    parameter a = 2,
    parameter b = 14,
    parameter taps = 100
) (
    input clk,
    input rst,
    input  signed [a+b:0] x,
    output reg signed [a+b:0] y
);

    localparam W          = a + b + 1;    // 17
    localparam CW         = 16;           // coefficient width
    localparam PAIR_W     = W + 1;        // sum of 2 samples
    localparam PROD_W     = PAIR_W + CW;  // product width
    localparam ACC_W      = 42;           // wide accumulator

    reg signed [CW-1:0] h [0:(taps/2)-1];

    reg signed [W-1:0]      x_reg [0:taps-1];
    reg signed [PAIR_W-1:0] pair;
    reg signed [PROD_W-1:0] prod;
    reg signed [ACC_W-1:0]  acc;

    reg signed [ACC_W-1:0]  final_sum;
    reg signed [ACC_W-1:0]  final_shifted;

    reg signed [W-1:0] max_out;
    reg signed [W-1:0] min_out;

    reg [7:0] k;
    integer i;

    // =========================================================
    // First half coefficients only (symmetry used)
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h[0]  <= -16'sd3;
            h[1]  <= -16'sd7;
            h[2]  <= -16'sd9;
            h[3]  <= -16'sd8;
            h[4]  <= -16'sd3;
            h[5]  <=  16'sd4;
            h[6]  <=  16'sd11;
            h[7]  <=  16'sd15;
            h[8]  <=  16'sd14;
            h[9]  <=  16'sd6;
            h[10] <= -16'sd7;
            h[11] <= -16'sd21;
            h[12] <= -16'sd29;
            h[13] <= -16'sd26;
            h[14] <= -16'sd11;
            h[15] <=  16'sd13;
            h[16] <=  16'sd38;
            h[17] <=  16'sd52;
            h[18] <=  16'sd47;
            h[19] <=  16'sd20;
            h[20] <= -16'sd22;
            h[21] <= -16'sd64;
            h[22] <= -16'sd87;
            h[23] <= -16'sd78;
            h[24] <= -16'sd33;  
            h[25] <=  16'sd36;
            h[26] <=  16'sd104;
            h[27] <=  16'sd141;
            h[28] <=  16'sd125;
            h[29] <=  16'sd52;
            h[30] <= -16'sd57;
            h[31] <= -16'sd164;
            h[32] <= -16'sd222;
            h[33] <= -16'sd197;
            h[34] <= -16'sd83;
            h[35] <=  16'sd91;
            h[36] <=  16'sd263;
            h[37] <=  16'sd360;
            h[38] <=  16'sd324;
            h[39] <=  16'sd139;
            h[40] <= -16'sd156;
            h[41] <= -16'sd465;
            h[42] <= -16'sd661;
            h[43] <= -16'sd625;
            h[44] <= -16'sd285;
            h[45] <=  16'sd352;
            h[46] <=  16'sd1194;
            h[47] <=  16'sd2077;
            h[48] <=  16'sd2811;
            h[49] <=  16'sd3227;
        end
    end

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
    // Serial optimized pipelined FIR
    // No intermediate truncation/saturation
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pair          <= 0;
            prod          <= 0;
            acc           <= 0;
            final_sum     <= 0;
            final_shifted <= 0;
            y             <= 0;
            k             <= 0;
        end
        else begin
            if (k == 0) begin
                acc  <= 0;
                pair <= x + x_reg[taps-1];
                prod <= 0;
                k    <= 8'd1;
            end
            else if (k <= taps/2) begin
                acc  <= acc + prod;
                prod <= pair * h[k-1];

                if (k < taps/2)
                    pair <= x_reg[k] + x_reg[taps-k-1];
                else
                    pair <= 0;

                k <= k + 8'd1;
            end
            else begin
                final_sum     <= acc + prod;
                final_shifted <= (final_sum) >>> b;

                max_out = {1'b0, {(W-1){1'b1}}};
                min_out = {1'b1, {(W-1){1'b0}}};

                if (final_shifted > max_out)
                    y <= max_out;
                else if (final_shifted < min_out)
                    y <= min_out;
                else
                    y <= final_shifted;

                k <= 0;
            end
        end
    end

endmodule