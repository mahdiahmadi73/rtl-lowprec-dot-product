`timescale 1ns/1ps

module tb_dot_serial;
    localparam N    = 4;
    localparam W    = 8;
    localparam ACCW = 18;
    localparam NVEC = 1024;

    reg clk = 0;
    always #5 clk = ~clk;

    reg [N*W-1:0]  a_mem   [0:NVEC-1];
    reg [N*W-1:0]  w_mem   [0:NVEC-1];
    reg [ACCW-1:0] exp_mem [0:NVEC-1];

    reg                    rst, start;
    reg  [N*W-1:0]         a_flat, w_flat;
    wire                   busy, done;
    wire signed [ACCW-1:0] result;

    dot_serial #(.N(N), .W(W)) dut (
        .clk(clk), .rst(rst), .start(start),
        .a_flat(a_flat), .w_flat(w_flat),
        .busy(busy), .done(done), .result(result)
    );

    integer k, errors, cycles, cycles_min, cycles_max;

    initial begin
        $readmemh("build/vec_a.hex",   a_mem);
        $readmemh("build/vec_w.hex",   w_mem);
        $readmemh("build/vec_exp.hex", exp_mem);

        errors = 0; cycles_min = 1000; cycles_max = 0;
        rst = 1; start = 0; a_flat = 0; w_flat = 0;
        @(negedge clk); @(negedge clk);
        rst = 0;

        for (k = 0; k < NVEC; k = k + 1) begin
            // give one vector and pulse start for one clock
            a_flat = a_mem[k]; w_flat = w_mem[k]; start = 1;
            @(negedge clk);
            start  = 0;
            cycles = 1;

            // wait until done, counting clocks
            while (done !== 1'b1) begin
                @(negedge clk);
                cycles = cycles + 1;
                if (cycles > 100) begin
                    $display("FAIL vector %0d: no done after 100 cycles", k);
                    $finish;
                end
            end

            if (result !== exp_mem[k]) begin
                if (errors < 10)
                    $display("FAIL vector %0d: got %0d, expected %0d",
                             k, result, $signed(exp_mem[k]));
                errors = errors + 1;
            end
            if (cycles < cycles_min) cycles_min = cycles;
            if (cycles > cycles_max) cycles_max = cycles;

            @(negedge clk);   // one idle clock before the next vector
        end

        if (errors == 0)
            $display("PASS: dot_serial, all %0d vectors, %0d cycles per result (min %0d, max %0d)",
                     NVEC, cycles_max, cycles_min, cycles_max);
        else
            $display("FAIL: %0d of %0d vectors wrong", errors, NVEC);
        $finish;
    end
endmodule