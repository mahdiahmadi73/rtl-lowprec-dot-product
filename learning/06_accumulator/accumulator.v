`timescale 1ns/1ps

module accumulator #(
    parameter W    = 8,
    parameter ACCW = 12
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   clear,
    input  wire                   en,
    input  wire signed [W-1:0]    x,
    output reg  signed [ACCW-1:0] acc,
    output reg  [7:0]             count
);
    always @(posedge clk) begin
        if (rst || clear) begin
            acc   <= 0;
            count <= 0;
        end else if (en) begin
            acc   <= acc + x;
            count <= count + 1;
        end
    end
endmodule