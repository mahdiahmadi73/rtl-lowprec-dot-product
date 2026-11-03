module tb_and_gate;
    reg switch1, switch2;
    wire y;
    and_gate uut (
        .a(switch1),
        .b(switch2),
        .y(y)
    );
    initial begin
        $dumpfile("build/and.vcd");
        $dumpvars(0, tb_and_gate);

        // Test 1: 0 AND 0 should be 0
        switch1 = 0; switch2 = 0; #10;
        if (y !== 0) $display("FAIL: 0 & 0 gave %b", y);
        else         $display("PASS: 0 & 0 = %b", y);

        // Test 2: 0 AND 1 should be 0
        switch1 = 0; switch2 = 1; #10;
        if (y !== 0) $display("FAIL: 0 & 1 gave %b", y);
        else         $display("PASS: 0 & 1 = %b", y);

        // Test 3: 1 AND 0 should be 0
        switch1 = 1; switch2 = 0; #10;
        if (y !== 0) $display("FAIL: 1 & 0 gave %b", y);
        else         $display("PASS: 1 & 0 = %b", y);

        // Test 4: 1 AND 1 should be 1
        switch1 = 1; switch2 = 1; #10;
        if (y !== 1) $display("FAIL: 1 & 1 gave %b", y);
        else         $display("PASS: 1 & 1 = %b", y);

        $finish;
    end
endmodule