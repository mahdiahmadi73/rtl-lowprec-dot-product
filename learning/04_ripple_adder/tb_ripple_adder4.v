`timescale 1ns/1ps

module tb_ripple_adder4;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout, overflow;
    integer i, j, errors, signed_sum;
    reg expected_overflow;

    ripple_adder4 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout), .overflow(overflow));

    initial begin
        $dumpfile("build/ripple_adder4.vcd");
        $dumpvars(0, tb_ripple_adder4);
        errors = 0;
        cin = 0;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i; b = j;
                #10;

                //  unsigned 
                if ({cout, sum} !== i + j) begin
                    $display("FAIL unsigned: %0d + %0d -> %0d", i, j, {cout, sum});
                    errors = errors + 1;
                end

                //  signed 
                signed_sum = $signed(a) + $signed(b);
                expected_overflow = (signed_sum > 7) || (signed_sum < -8);
                if (overflow !== expected_overflow) begin
                    $display("FAIL overflow: %0d + %0d", $signed(a), $signed(b));
                    errors = errors + 1;
                end
                if (!expected_overflow && $signed(sum) !== signed_sum) begin
                    $display("FAIL signed: %0d + %0d -> %0d", $signed(a), $signed(b), $signed(sum));
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) $display("PASS: 4-bit adder, all 256 cases");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule