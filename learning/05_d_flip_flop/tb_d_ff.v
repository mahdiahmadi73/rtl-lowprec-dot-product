`timescale 1ns/1ps

module tb_d_ff;
    reg  clk = 0;
    reg  rst, en, d;
    wire q;
    integer errors;

    d_ff dut (.clk(clk), .rst(rst), .en(en), .d(d), .q(q));

    always #5 clk = ~clk;   // clock period 10 ns

    task expect_q(input reg value);
        begin
            if (q !== value) begin
                $display("FAIL at t=%0t: q=%b, expected %b", $time, q, value);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("build/d_ff.vcd");
        $dumpvars(0, tb_d_ff);
        errors = 0;

        // 1) reset
        rst = 1; en = 0; d = 1;
        @(negedge clk); expect_q(0);
        rst = 0;

        // 2) en = 1: q follows d, one clock later
        en = 1; d = 1; @(negedge clk); expect_q(1);
        d = 0;         @(negedge clk); expect_q(0);

        // 3) d changes between clock edges so q shouldnt change yet
        @(posedge clk); #2 d = 1; #1 expect_q(0);
        @(negedge clk); expect_q(0);     // still 0: no rising edge since d changed
        @(negedge clk); expect_q(1);     // now the edge has passed

        // 4) en = 0: q holds
        en = 0; d = 0;
        @(negedge clk); expect_q(1);
        @(negedge clk); expect_q(1);

        if (errors == 0) $display("PASS: D flip-flop (reset, capture, hold)");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule