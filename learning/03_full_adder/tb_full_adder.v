`timescale 1ns/1ps

module tb_full_adder;
    reg  a, b, cin;
    wire sum, cout;
    reg  [1:0] expected;
    integer i, errors;

    full_adder dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $dumpfile("build/full_adder.vcd");
        $dumpvars(0, tb_full_adder);
        errors = 0;

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i;
            #10;
            expected = a + b + cin;
            if ({cout, sum} !== expected) begin
                $display("fAIL: a=%b b=%b cin=%b -> cout=%b sum=%b (expected %b)",a, b, cin, cout, sum, expected);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PAsS: full adder, all 8 cases");
        else            $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule