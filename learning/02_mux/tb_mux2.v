module tb_mux2 ;
    reg switch1, switch2, sel;
    wire y;
    mux2 uut (
        .a(switch1),
        .b(switch2),
        .sel(sel),
        .y(y)
    );
    initial begin
        $dumpfile("build/mux.vcd");
        $dumpvars(0, tb_mux2);

        // Test 1: sel=0 should select a (switch1)
        switch1 = 0; switch2 = 1; sel = 0; #10;
        if (y !== 0) $display("FAIL: sel=0 gave %b", y);
        else         $display("PASS: sel=0 = %b", y);

        // Test 2: sel=1 should select b (switch2)
        switch1 = 0; switch2 = 1; sel = 1; #10;
        if (y !== 1) $display("FAIL: sel=1 gave %b", y);
        else         $display("PASS: sel=1 = %b", y);
        // another test remaining
        // Test 3: sel=0 should select a (switch1)

        $finish;
    end
endmodule
