`timescale 1ns/1ps

module tb_genvar_fir;

parameter a = 2;
parameter b = 14;
parameter taps = 100;
parameter W = a + b + 1;
parameter NSAMP = 501;
parameter TOTAL_OUT = NSAMP + taps + 5;

reg clk;
reg rst;
reg en;
reg signed [W-1:0] x;
wire signed [W-1:0] y;
wire data_valid;

reg signed [W-1:0] sig_mem [0:NSAMP-1];

integer i;
integer idx;
integer temp;
integer code;
integer fsig;
integer fout;

// DUT
genvar_fir #(
    .a(a),
    .b(b),
    .taps(taps)
) DUT (
    .clk(clk),
    .rst(rst),
    .en(en),
    .x(x),
    .y(y),
    .data_valid(data_valid)
);

// CLOCK
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    x  = 0;
    en = 0;
    rst = 1;

    repeat(3) @(posedge clk);
    rst = 0;

    // ======================================
    // 950 Hz SIGNAL
    // ======================================
    fsig = $fopen("sig_950_q214.txt","r");
    if (fsig == 0) begin
        $display("ERROR: cannot open sig_950_q214.txt");
        $finish;
    end

    idx = 0;
    while(!$feof(fsig) && idx < NSAMP) begin
        code = $fscanf(fsig,"%d\n",temp);
        if(code == 1) begin
            sig_mem[idx] = temp;
            idx = idx + 1;
        end
    end
    $fclose(fsig);

    if (idx != NSAMP) begin
        $display("ERROR: signal count mismatch, read = %0d expected = %0d", idx, NSAMP);
        $finish;
    end

    fout = $fopen("out_genvar_950_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_genvar_950_q214.txt");
        $finish;
    end

    en = 1;
    for(i = 0; i < TOTAL_OUT; i = i + 1) begin
        @(negedge clk);
        if (i < NSAMP)
            x = sig_mem[i];
        else
            x = 0;

        @(posedge clk);
        #1;
        $fdisplay(fout,"%0d",y);
    end
    en = 0;

    $fclose(fout);

    // RESET
    rst = 1;
    en  = 0;
    x   = 0;
    repeat(3) @(posedge clk);
    rst = 0;

    // ======================================
    // 1100 Hz SIGNAL
    // ======================================
    fsig = $fopen("sig_1100_q214.txt","r");
    if (fsig == 0) begin
        $display("ERROR: cannot open sig_1100_q214.txt");
        $finish;
    end

    idx = 0;
    while(!$feof(fsig) && idx < NSAMP) begin
        code = $fscanf(fsig,"%d\n",temp);
        if(code == 1) begin
            sig_mem[idx] = temp;
            idx = idx + 1;
        end
    end
    $fclose(fsig);

    if (idx != NSAMP) begin
        $display("ERROR: signal count mismatch, read = %0d expected = %0d", idx, NSAMP);
        $finish;
    end

    fout = $fopen("out_genvar_1100_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_genvar_1100_q214.txt");
        $finish;
    end

    en = 1;
    for(i = 0; i < TOTAL_OUT; i = i + 1) begin
        @(negedge clk);
        if (i < NSAMP)
            x = sig_mem[i];
        else
            x = 0;

        @(posedge clk);
        #1;
        $fdisplay(fout,"%0d",y);
    end
    en = 0;

    $fclose(fout);

    // RESET
    rst = 1;
    en  = 0;
    x   = 0;
    repeat(3) @(posedge clk);
    rst = 0;

    // ======================================
    // 2000 Hz SIGNAL
    // ======================================
    fsig = $fopen("sig_2000_q214.txt","r");
    if (fsig == 0) begin
        $display("ERROR: cannot open sig_2000_q214.txt");
        $finish;
    end

    idx = 0;
    while(!$feof(fsig) && idx < NSAMP) begin
        code = $fscanf(fsig,"%d\n",temp);
        if(code == 1) begin
            sig_mem[idx] = temp;
            idx = idx + 1;
        end
    end
    $fclose(fsig);

    if (idx != NSAMP) begin
        $display("ERROR: signal count mismatch, read = %0d expected = %0d", idx, NSAMP);
        $finish;
    end

    fout = $fopen("out_genvar_2000_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_genvar_2000_q214.txt");
        $finish;
    end

    en = 1;
    for(i = 0; i < TOTAL_OUT; i = i + 1) begin
        @(negedge clk);
        if (i < NSAMP)
            x = sig_mem[i];
        else
            x = 0;

        @(posedge clk);
        #1;
        $fdisplay(fout,"%0d",y);
    end
    en = 0;

    $fclose(fout);

    $display("All genvar FIR simulations finished.");
    $finish;

end

endmodule