module tb_and_gate;
    reg switch1, switch2;
    wire y;
    and_gate uut (
        .a(switch1),
        .b(switch2),
        .y(y)
    );
    initial begin
        $dumpfile("build/and.vcd");      // where to save the recording
        $dumpvars(0, tb_and_gate);       // record all signals in the testbench
        switch1 = 0; switch2 = 0; #10; $display("switch1=%b, switch2=%b, y=%b", switch1, switch2, y);
        switch1 = 0; switch2 = 1; #10; $display("switch1=%b, switch2=%b, y=%b", switch1, switch2, y);
        switch1 = 1; switch2 = 0; #10; $display("switch1=%b, switch2=%b, y=%b", switch1, switch2, y);
        switch1 = 1; switch2 = 1; #10; $display("switch1=%b, switch2=%b, y=%b", switch1, switch2, y);
        $finish;
    end
endmodule