`timescale 1ns/1ps

module d_ff (
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (rst)     q <= 1'b0;
        else if (en) q <= d;
    end
endmodule