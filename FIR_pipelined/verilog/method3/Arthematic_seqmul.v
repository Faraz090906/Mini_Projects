// Fixed-point addition module
module Addition #(
    parameter A1 = 3,
    parameter B1 = 14,
    parameter A2 = 5,
    parameter B2 = 12,
    parameter A3_1 = 16, // output integer bits
    parameter B3_1 = 16     // output fractional bits
) (
    input  [A1 + B1 : 0] operand1,
    input  [A2 + B2 : 0] operand2,
    output [A3_1 + B3_1 : 0] result
);  
    localparam A3 = ((A2 > A1) ? A2 : A1) + 1;
    localparam B3 = ((B2 > B1) ? B2 : B1);

    // internal signals
    reg  [A3 + B3 : 0] op1_1, op2_1, op1, op2;

    // bits required for sign extension
    localparam Shift_1 = A3 + B3 - (A1 + B1);
    localparam Shift_2 = A3 + B3 - (A2 + B2);

    // sign extension and fractional alignment
    always @(*) begin
        if (operand1[A1 + B1])
            op1_1 = {{Shift_1{1'b1}}, operand1};
        else
            op1_1 = operand1;

        if (operand2[A2 + B2])
            op2_1 = {{Shift_2{1'b1}}, operand2};
        else
            op2_1 = operand2;

        if (B1 < B2)
            op1 = op1_1 <<< (B3 - B1);
        else
            op1 = op1_1;

        if (B2 < B1)
            op2 = op2_1 <<< (B3 - B2);
        else
            op2 = op2_1;
    end
    
    wire [A3 + B3 : 0] result_1;
    // final addition
    FAddA3B3 #(.A(A3), .B(B3)) instance3 (
        .a(op1),
        .b(op2),
        .cin(1'b0),
        .sum(result_1),
        .cout()
    );

    FixedpointResize #(.A1(A3), .B1(B3), .A2(A3_1), .B2(B3_1)) resize_instance (
        .in(result_1),
        .result(result)
    );

endmodule


// Fixed-point subtraction module
module Subtraction #(
    parameter A1 = 3,
    parameter B1 = 14,
    parameter A2 = 5,
    parameter B2 = 12,
    parameter A3 = 16,
    parameter B3 = 16
) (
    input  [A1 + B1 : 0] operand1,
    input  [A2 + B2 : 0] operand2,
    output [A3 + B3 : 0] result
);

    // two's complement of operand2
    wire [A2 + B2 : 0] op2;
    assign op2 = ~operand2 + 1;

    // reuse addition module
    Addition #(.A1(A1), .B1(B1), .A2(A2), .B2(B2), .A3_1(A3), .B3_1(B3)) instance4 (
        operand1,
        op2,
        result
    );

endmodule

// Fixed-point multiplication module
module Multiplication #(
    parameter A1 = 3,
    parameter B1 = 14,
    parameter A2 = 5,
    parameter B2 = 12,
    parameter A3_1 = 16,
    parameter B3_1 = 16
) (
    input  [A1 + B1 : 0] operand1,
    input  [A2 + B2 : 0] operand2,
    output [A3_1 + B3_1 : 0] result_1
);  
    localparam A3 = A1 + A2;
    localparam B3 = B1 + B2;
    wire [A3 + B3 : 0] result;

    // convert inputs to positive magnitude
    wire [A1 + B1 : 0] op1_pos = operand1[A1 + B1] ? (~operand1 + 1'b1) : operand1;
    wire [A2 + B2 : 0] op2_pos = operand2[A2 + B2] ? (~operand2 + 1'b1) : operand2;

    // partial products and sums
    wire [A3 + B3 : 0] pp [A2 + B2 : 0];
    wire [A3 + B3 : 0] ps [A2 + B2 : 0];

    genvar i;
    generate
        for (i = 0; i < A2 + B2 + 1; i = i + 1) begin
            assign pp[i] = {{
                (A3 + B3 - (A1 + B1)){1'b0}
            }, (op1_pos & {(A1 + B1 + 1){op2_pos[i]}})} <<< i;
        end
    endgenerate

    assign ps[0] = pp[0];

    generate
        for (i = 1; i < A2 + B2 + 1; i = i + 1) begin
            FAddA3B3 #(.A(A3), .B(B3)) instance6 (
                .a(ps[i-1]),
                .b(pp[i]),
                .cin(1'b0),
                .sum(ps[i]),
                .cout()
            );
        end
    endgenerate

    // restore sign
    wire sign = operand1[A1 + B1] ^ operand2[A2 + B2];
    wire [A3 + B3 : 0] unsigned_result = ps[A2 + B2];

    assign result = sign ? (~unsigned_result + 1'b1) : unsigned_result;
    FixedpointResize #(.A1(A3), .B1(B3), .A2(A3_1), .B2(B3_1)) resize_instance (
        .in(result),
        .result(result_1)
    );
endmodule


// Ripple-carry adder
module FAddA3B3 #(
    parameter A = 5,
    parameter B = 14
) (
    input  [A + B : 0] a,
    input  [A + B : 0] b,
    input  cin,
    output [A + B : 0] sum,
    output cout
);

    wire [A + B : 0] c;
    genvar i;

    FAdd fa0(a[0], b[0], cin, sum[0], c[0]);

    generate
        for (i = 1; i < A + B + 1; i = i + 1) begin
            FAdd fai(a[i], b[i], c[i-1], sum[i], c[i]);
        end
    endgenerate

    assign cout = c[A + B];

endmodule

// 1-bit full adder
module FAdd (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule


// IEEE-754 double to fixed-point conversion
module floating_point #(
    parameter A = 2,
    parameter B = 14
) (
    input  [63:0] input_float,
    output reg [A+B:0] fixed_out
);

    reg input_sign;
    reg [51:0] mantissa;
    reg signed [10:0] exp_unbiased;
    reg [51:0] int_part, frac_part;
    reg [A+B:0] fixed_mag;
    reg guard;

    always @(*) begin
        input_sign   = input_float[63];
        mantissa     = input_float[51:0];
        exp_unbiased = $signed(input_float[62:52]) - 1023;

        if (exp_unbiased < 52 && exp_unbiased > 0) begin
            int_part  = ({1'b1, mantissa} >> (52 - exp_unbiased));
            frac_part = mantissa << exp_unbiased;
        end
        else if (exp_unbiased == 0) begin
            int_part  = {51'b0, 1'b1};
            frac_part = mantissa;
        end
        else if (exp_unbiased < 0 && exp_unbiased > -52) begin
            int_part  = 52'b0;
            frac_part = ({1'b1, mantissa} >> (-exp_unbiased));
        end
        else if (exp_unbiased <= -52) begin
            int_part  = 52'b0;
            frac_part = 52'b0;
        end
        else begin
            int_part  = {51{1'b1}};
            frac_part = {51{1'b1}};
        end

        if (int_part[51:A] != 0 && !input_sign)
            fixed_out = {(A+B){1'b1}};
        else if (int_part[51:A] != 0 && input_sign)
            fixed_out = {(A+B+1){1'b1}};
        else begin
            fixed_mag = {1'b0, int_part[A-1:0], frac_part[51:52-B]};
            guard = frac_part[51-B];
            if (guard)
                fixed_mag = fixed_mag + 1;
            fixed_out = input_sign ? (~fixed_mag + 1) : fixed_mag;
        end
    end
endmodule

module FixedpointResize #(
    parameter A1,
    parameter B1,
    parameter A2 = 16,
    parameter B2 = 16
)(
    input  [A1+B1:0] in,
    output [A2+B2:0] result
);

    localparam integer FRAC_DIFF = B1 - B2;

    // shifted version at the target fractional alignment
    wire [A1+B1:0] shifted =
        (FRAC_DIFF > 0) ? $signed(in) >>> FRAC_DIFF :
        (FRAC_DIFF < 0) ? (in << (-FRAC_DIFF)) :
                          in;

    // If shrinking, we may need saturation based on overflow beyond output width
    generate
    if ((A1+B1) > (A2+B2)) begin : SHRINK
        wire sign_bit = shifted[A1+B1];

        // upper bits that will be discarded: [A1+B1 : A2+B2+1]
        wire upper_all_zero = ~|shifted[A1+B1 : A2+B2+1];
        wire upper_all_one  =  &shifted[A1+B1 : A2+B2+1];

        wire overflow_pos = (~sign_bit) & (~upper_all_zero);
        wire overflow_neg = ( sign_bit) & (~upper_all_one);

        assign result =
            overflow_pos ? {1'b0, {(A2+B2){1'b1}}} :   // max positive
            overflow_neg ? {1'b1, {(A2+B2){1'b0}}} :   // most negative
            shifted[A2+B2:0];

    end else begin : EXPAND
        // if expanding, just take LSBs (shifted already aligned)
        assign result = shifted[A2+B2:0];
    end
    endgenerate

endmodule
// -----------------------------------------------------------------------------
// Sequential fixed-point multiplication
// -----------------------------------------------------------------------------

module MultiplicationSeq #( 
    parameter A1   = 3,
    parameter B1   = 14,
    parameter A2   = 5,
    parameter B2   = 12,
    parameter A3_1 = 16,
    parameter B3_1 = 16
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   start,
    input  wire [A1 + B1 : 0]     operand1,
    input  wire [A2 + B2 : 0]     operand2,
    output reg  [A3_1 + B3_1 : 0] result,
    output reg                    done,
    output reg                    busy
);
    localparam IN1W   = A1 + B1 + 1;
    localparam IN2W   = A2 + B2 + 1;
    localparam PROD_W = IN1W + IN2W;
    localparam COUNT_W = (IN2W <= 2) ? 1 : $clog2(IN2W + 1);

    wire [IN1W-1:0] op1_mag = operand1[IN1W-1] ? (~operand1 + 1'b1) : operand1;
    wire [IN2W-1:0] op2_mag = operand2[IN2W-1] ? (~operand2 + 1'b1) : operand2;
    wire            res_sign = operand1[IN1W-1] ^ operand2[IN2W-1];

    reg [PROD_W-1:0] multiplicand_shifted;
    reg [IN2W-1:0]   multiplier_shifted;
    reg [PROD_W-1:0] accumulator;
    reg [COUNT_W-1:0] count;
    reg              sign_reg;

    wire [PROD_W-1:0] acc_after_add = multiplier_shifted[0] ? (accumulator + multiplicand_shifted) : accumulator;

    wire [PROD_W-1:0] signed_product = sign_reg ? (~acc_after_add + 1'b1) : acc_after_add;

    wire [A3_1 + B3_1 : 0] resized_product;
    FixedpointResize #(
        .A1(A1 + A2),
        .B1(B1 + B2),
        .A2(A3_1),
        .B2(B3_1)
    ) resize_seq_mul (
        .in(signed_product),
        .result(resized_product)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            multiplicand_shifted <= {PROD_W{1'b0}};
            multiplier_shifted   <= {IN2W{1'b0}};
            accumulator          <= {PROD_W{1'b0}};
            count                <= {COUNT_W{1'b0}};
            sign_reg             <= 1'b0;
            result               <= {(A3_1 + B3_1 + 1){1'b0}};
            done                 <= 1'b0;
            busy                 <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                multiplicand_shifted <= {{IN2W{1'b0}}, op1_mag};
                multiplier_shifted   <= op2_mag;
                accumulator          <= {PROD_W{1'b0}};
                count                <= {COUNT_W{1'b0}};
                sign_reg             <= res_sign;
                busy                 <= 1'b1;
            end
            else if (busy) begin
                if (count == IN2W-1) begin
                    accumulator <= acc_after_add;
                    result      <= resized_product;
                    busy        <= 1'b0;
                    done        <= 1'b1;
                end else begin
                    accumulator          <= acc_after_add;
                    multiplicand_shifted <= multiplicand_shifted << 1;
                    multiplier_shifted   <= multiplier_shifted >> 1;
                    count                <= count + 1'b1;
                end
            end
        end
    end
endmodule
