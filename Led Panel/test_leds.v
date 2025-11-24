module test_leds (
    input wire clk,
    output reg r0, g0, b0,
    output reg r1, g1, b1,
    output reg [4:0] addr,
    output reg clk_out,
    output reg latch,
    output reg oe
);

    reg [23:0] cnt = 0;

    always @(posedge clk) begin
        cnt <= cnt + 1;

        r0 <= cnt[5];
        g0 <= cnt[6];
        b0 <= cnt[7];
        r1 <= cnt[8];
        g1 <= cnt[9];
        b1 <= cnt[10];

        oe <= 0;
        clk_out <= cnt[0];
        addr <= cnt[9:5];
        latch <= cnt[10];
    end

endmodule

