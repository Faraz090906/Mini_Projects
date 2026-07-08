module complex_add #(
    parameter INT  = 3,
    parameter FRAC = 5,
    parameter W    = INT + FRAC
)(
    input  signed [W-1:0] ar,
    input  signed [W-1:0] ai,
    input  signed [W-1:0] br,
    input  signed [W-1:0] bi,
    output signed [W:0]   sr,
    output signed [W:0]   si
);

assign sr = ar + br;
assign si = ai + bi;

endmodule

module complex_sub #(
    parameter INT  = 3,
    parameter FRAC = 5,
    parameter W    = INT + FRAC
)(
    input  signed [W-1:0] ar,
    input  signed [W-1:0] ai,
    input  signed [W-1:0] br,
    input  signed [W-1:0] bi,
    output signed [W:0]   dr,
    output signed [W:0]   di
);

assign dr = ar - br;
assign di = ai - bi;

endmodule

module complex_mult #(
    parameter INT  = 3,
    parameter FRAC = 5,
    parameter W    = INT + FRAC
)(
    input  signed [W-1:0] ar,
    input  signed [W-1:0] ai,
    input  signed [W-1:0] br,
    input  signed [W-1:0] bi,
    output signed [W-1:0] pr,
    output signed [W-1:0] pi
);

wire signed [2*W-1:0] ac;
wire signed [2*W-1:0] bd;
wire signed [2*W-1:0] ad;
wire signed [2*W-1:0] bc;

wire signed [2*W:0] real_full;
wire signed [2*W:0] imag_full;
wire signed [2*W:0] real_scaled;
wire signed [2*W:0] imag_scaled;

assign ac = ar * br;
assign bd = ai * bi;
assign ad = ar * bi;
assign bc = ai * br;

assign real_full   = ac - bd;
assign imag_full   = ad + bc;
assign real_scaled = real_full >>> FRAC;
assign imag_scaled = imag_full >>> FRAC;

assign pr = real_scaled[W-1:0];
assign pi = imag_scaled[W-1:0];

endmodule