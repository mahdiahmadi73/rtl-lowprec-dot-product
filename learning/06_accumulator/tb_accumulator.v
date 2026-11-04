`timescale 1ns/1ps

module tb_accumulator;
    reg                clk = 0;
    reg                rst, clear, en;
    reg  signed [7:0]  x;
    wire signed [11:0] acc;
    wire [7:0]         count;

    integer k, errors, model_sum, model_count;
    reg signed [7:0] values [0:7];

    accumulator #(.W(8), .ACCW(12)) dut (
        .clk(clk), .rst(rst), .clear(clear), .en(en), .x(x), .acc(acc), .count(count)
    );

    always #5 clk = ~clk;

    task check;
        begin
            if (acc !== model_sum || count !== model_count) begin
                $display("FAIL at t=%0t: acc=%0d count=%0d, expected %0d / %0d",
                         $time, acc, count, model_sum, model_count);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("build/accumulator.vcd");
        $dumpvars(0, tb_accumulator);
        errors = 0;

        values[0] = 5;  values[1] = -3; values[2] = 127; values[3] = -128;
        values[4] = 10; values[5] = -1; values[6] = 127; values[7] = 127;

        rst = 1; clear = 0; en = 0; x = 0;
        @(negedge clk); @(negedge clk);
        rst = 0;
        model_sum = 0; model_count = 0;
        check;

        // 1) add 8 values, one per clock
        for (k = 0; k < 8; k = k + 1) begin
            x = values[k]; en = 1;
            @(negedge clk);
            model_sum   = model_sum + values[k];
            model_count = model_count + 1;
            check;
        end

        // 2) en = 0: the sum must hold
        en = 0; x = 99;
        @(negedge clk); @(negedge clk);
        check;

        // 3) clear: back to zero
        clear = 1;
        @(negedge clk);
        clear = 0;
        model_sum = 0; model_count = 0;
        check;

        if (errors == 0) $display("PASS: accumulator (add, hold, clear)");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule