`timescale 1ns/1ps

module tb_optimized_fir;

parameter a = 2;
parameter b = 14;
parameter taps = 100;
parameter W = a + b + 1;
parameter NSAMP = 501;
parameter WAIT_CYCLES = taps/2 + 2;

reg clk;
reg rst;
reg signed [W-1:0] x;
wire signed [W-1:0] y;

reg signed [W-1:0] sig_mem [0:NSAMP-1];

integer i, j, idx, temp, code, fsig, fout;

// DUT
optimized #(
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

    // ======================================================
    // 950 Hz SIGNAL
    // ======================================================
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

    fout = $fopen("out_optimized_pipeline_950_q214.txt","w");
    if (fout == 0) begin
        $display("ERROR: cannot open output file");
        $finish;
    end

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        for(j = 0; j < WAIT_CYCLES; j = j + 1)
            @(posedge clk);

        #1;
        $fdisplay(fout,"%0d",y);
    end

    $fclose(fout);

    // RESET
    rst = 1;
    x = 0;
    repeat(3) @(posedge clk);
    rst = 0;

    // ======================================================
    // 1100 Hz SIGNAL
    // ======================================================
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

    fout = $fopen("out_optimized_pipeline_1100_q214.txt","w");

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        for(j = 0; j < WAIT_CYCLES; j = j + 1)
            @(posedge clk);

        #1;
        $fdisplay(fout,"%0d",y);
    end

    $fclose(fout);

    // RESET
    rst = 1;
    x = 0;
    repeat(3) @(posedge clk);
    rst = 0;

    // ======================================================
    // 2000 Hz SIGNAL
    // ======================================================
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

    fout = $fopen("out_optimized_pipeline_2000_q214.txt","w");

    for(i = 0; i < NSAMP; i = i + 1) begin
        @(negedge clk);
        x = sig_mem[i];

        for(j = 0; j < WAIT_CYCLES; j = j + 1)
            @(posedge clk);

        #1;
        $fdisplay(fout,"%0d",y);
    end

    $fclose(fout);

    $display("All optimized FIR simulations finished.");
    $finish;

end

endmodule