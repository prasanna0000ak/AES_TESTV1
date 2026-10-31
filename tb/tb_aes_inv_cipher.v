
`timescale 1ns/1ps

module tb_aes_inv_cipher;

    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [127:0] key;
    reg  [127:0] din;
    wire [127:0] dout;
    wire         busy;
    wire         done;

    // Instantiate DUT
    aes_inv_cipher dut (
        .clk  (clk),
        .rst_n(rst_n),
        .start(start),
        .key  (key),
        .din  (din),
        .dout (dout),
        .busy (busy),
        .done (done)
    );

    // Clock Generation (100MHz => 10ns period)
    always #5 clk = ~clk;

    integer pass_cnt = 0;
    integer fail_cnt = 0;
    integer timeout_cnt = 0;

    initial begin
        clk   = 0;
        rst_n = 0;
        start = 0;
        key   = 128'd0;
        din   = 128'd0;


        // Apply Reset
        #20;
        rst_n = 1;
        #10;

        // FIPS-197 Appendix B Test Vector
        key   = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        din   = 128'h3925841d02dc09fbdc118597196a0b32; // Ciphertext

        // Start pulse
        @(posedge clk);
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        // Wait for done or timeout
        while (!done && timeout_cnt < 50) begin
            @(posedge clk);
            timeout_cnt = timeout_cnt + 1;
        end

        $finish;
    end

endmodule
