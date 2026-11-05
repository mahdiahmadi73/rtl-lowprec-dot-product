`timescale 1ns/1ps

module tb_dot_parallel;
    localparam N    = 4;
    localparam W    = 8;
    localparam ACCW = 18;
    localparam NVEC = 1024;

    reg clk = 0;
    always #5 clk = ~clk;

    // test vectors from the Python reference model
    reg [N*W-1:0]  a_mem   [0:NVEC-1];
    reg [N*W-1:0]  w_mem   [0:NVEC-1];
    reg [ACCW-1:0] exp_mem [0:NVEC-1];

    reg                    rst, valid_in;
    reg  [N*W-1:0]         a_flat, w_flat;
    wire                   valid_out;
    wire signed [ACCW-1:0] result;

    dot_parallel #(.N(N), .W(W)) dut (
        .clk(clk), .rst(rst), .valid_in(valid_in),
        .a_flat(a_flat), .w_flat(w_flat),
        .valid_out(valid_out), .result(result)
    );

    integer k, errors;

    initial begin
        $readmemh("build/vec_a.hex",   a_mem);
        $readmemh("build/vec_w.hex",   w_mem);
        $readmemh("build/vec_exp.hex", exp_mem);

        errors = 0;
        rst = 1; valid_in = 0; a_flat = 0; w_flat = 0;
        @(negedge clk); @(negedge clk);
        rst = 0;

        // one new vector every clock cycle
        for (k = 0; k < NVEC; k = k + 1) begin
            a_flat = a_mem[k]; w_flat = w_mem[k]; valid_in = 1;
            @(negedge clk);
            if (valid_out !== 1'b1 || result !== exp_mem[k]) begin
                if (errors < 10)
                    $display("FAIL vector %0d: got %0d, expected %0d",
                             k, result, $signed(exp_mem[k]));
                errors = errors + 1;
            end
        end
        valid_in = 0;

        if (errors == 0) $display("PASS: dot_parallel, all %0d vectors, 1 result per cycle", NVEC);
        else             $display("FAIL: %0d of %0d vectors wrong", errors, NVEC);
        $finish;
    end
endmodule