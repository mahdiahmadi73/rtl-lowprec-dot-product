`timescale 1ns/1ps

module dot_serial #(
    parameter N    = 4,
    parameter W    = 8,
    parameter ACCW = 2*W + $clog2(N)
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   start,
    input  wire [N*W-1:0]         a_flat,
    input  wire [N*W-1:0]         w_flat,
    output reg                    busy,
    output reg                    done,
    output reg  signed [ACCW-1:0] result
);
    localparam CW = (N > 1) ? $clog2(N) : 1;

    reg        [CW-1:0]   idx;
    reg signed [ACCW-1:0] acc;

    // pick element idx: only one a and one w are used per cycle
    wire signed [W-1:0]    a_cur    = a_flat[idx*W +: W];
    wire signed [W-1:0]    w_cur    = w_flat[idx*W +: W];
    wire signed [ACCW-1:0] acc_next = acc + a_cur * w_cur;   // the single MAC

    always @(posedge clk) begin
        if (rst) begin
            busy   <= 1'b0;
            done   <= 1'b0;
            idx    <= 0;
            acc    <= 0;
            result <= 0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    busy <= 1'b1;
                    idx  <= 0;
                    acc  <= 0;
                end
            end else begin
                acc <= acc_next;
                if (idx == N-1) begin
                    busy   <= 1'b0;
                    done   <= 1'b1;
                    result <= acc_next;
                end else begin
                    idx <= idx + 1;
                end
            end
        end
    end
endmodule