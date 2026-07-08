`timescale 1ns/1ps

module tb_direct;

parameter a = 2;
parameter b = 14;
parameter taps = 100;
parameter W = a + b + 1;
parameter NSAMP = 501;

reg clk;
reg rst;
reg signed [W-1:0] x;
wire signed [W-1:0] y;

reg signed [W-1:0] sig_mem [0:NSAMP-1];

integer i;
integer idx;
integer temp;
integer code;
integer fsig;
integer fout;


// DUT
direct #(
    .a(a),
    .b(b),
    .taps(taps)
) DUT (
    .clk(clk),
    .rst(rst),
    .x(x),
    .y(y)
);


// CLOCK
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


initial begin
    x = 0;
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

    fout = $fopen("out_direct_950_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_direct_950_q214.txt");
        $finish;
    end

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        @(posedge clk);
        repeat(taps) @(posedge clk);
        #1;
        $fdisplay(fout, "%0d", y);
    end
    $fclose(fout);

    // RESET
    rst = 1;
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

    fout = $fopen("out_direct_1100_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_direct_1100_q214.txt");
        $finish;
    end

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        @(posedge clk);
        repeat(taps) @(posedge clk);
        #1;
        $fdisplay(fout, "%0d", y);
    end
    $fclose(fout);

    // RESET
    rst = 1;
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

    fout = $fopen("out_direct_2000_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open out_direct_2000_q214.txt");
        $finish;
    end

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        @(posedge clk);
        repeat(taps) @(posedge clk);
        #1;
        $fdisplay(fout, "%0d", y);
    end
    $fclose(fout);

    $display("All FIR simulations finished.");
    $finish;
end

endmodule