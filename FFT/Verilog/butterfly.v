module butterfly_dif #(
    parameter INT  = 3,
    parameter FRAC = 5,
    parameter W    = INT + FRAC
)(
    input  signed [W-1:0] ar,
    input  signed [W-1:0] ai,
    input  signed [W-1:0] br,
    input  signed [W-1:0] bi,
    input  signed [W-1:0] wr,
    input  signed [W-1:0] wi,

    output signed [W-1:0] sum_r,
    output signed [W-1:0] sum_i,
    output signed [W-1:0] diff_tw_r,
    output signed [W-1:0] diff_tw_i
);

wire signed [W:0] sum_r_w;
wire signed [W:0] sum_i_w;
wire signed [W:0] diff_r_w;
wire signed [W:0] diff_i_w;
wire signed [W-1:0] diff_r;
wire signed [W-1:0] diff_i;

assign sum_r_w  = ar + br;
assign sum_i_w  = ai + bi;
assign diff_r_w = ar - br;
assign diff_i_w = ai - bi;

assign sum_r  = sum_r_w[W-1:0];
assign sum_i  = sum_i_w[W-1:0];
assign diff_r = diff_r_w[W-1:0];
assign diff_i = diff_i_w[W-1:0];

complex_mult #(
    .INT(INT),
    .FRAC(FRAC),
    .W(W)
) CMULT (
    .ar(diff_r),
    .ai(diff_i),
    .br(wr),
    .bi(wi),
    .pr(diff_tw_r),
    .pi(diff_tw_i)
);

endmodule