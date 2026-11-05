`timescale 1ns/1ps

module dot_parallel #(
    parameter N    = 4,
    parameter W    = 8,
    parameter ACCW = 2*W + $clog2(N)
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   valid_in,
    input  wire [N*W-1:0]         a_flat,
    input  wire [N*W-1:0]         w_flat,
    output reg                    valid_out,
    output reg  signed [ACCW-1:0] result
);
    // combinational core: 4 multiplications + sum, always computing
    integer i;
    reg signed [ACCW-1:0] sum;
    always @* begin
        sum = 0;
        for (i = 0; i < N; i = i + 1)
            sum = sum + $signed(a_flat[i*W +: W]) * $signed(w_flat[i*W +: W]);
    end

    // registered wrapper: store the sum at the rising clock edge
    always @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            result    <= 0;
        end else begin
            valid_out <= valid_in;
            if (valid_in)
                result <= sum;
        end
    end
endmodule