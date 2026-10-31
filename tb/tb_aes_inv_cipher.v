// File: tb_aes_inv_cipher.v
// Description: Testbench for full aes_inv_cipher core (Step 5)

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

        $display("--------------------------------------------------");
        $display("Starting Testbench: AES-128 InvCipher Core (Step 5)");
        $display("--------------------------------------------------");

        $dumpfile("wave_aes_inv_cipher.vcd");
        $dumpvars(0, tb_aes_inv_cipher);

        // Apply Reset
        #20;
        rst_n = 1;
        #10;

        // FIPS-197 Appendix B Test Vector
        key   = 128'h000102030405060708090a0b0c0d0e0f

  ;
        din   = 128'h69c4e0d86a7b0430d8cdb78070b4c55a; // Ciphertext

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

        if (done && dout === 128'h00112233445566778899aabbccddeeff) begin
            $display("[RESULT] TEST 1 (FIPS-197 Appendix B Decryption): PASS");
            $display("  Plaintext Result: %h", dout);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 1 (FIPS-197 Appendix B Decryption): FAIL");
            $display("  Actual Output   : %h", dout);
            $display("  Expected Output : 3243f6a8885a308d313198a2e0370734");
            fail_cnt = fail_cnt + 1;
        end

        $display("--------------------------------------------------");
        $display("SUMMARY - PASS: %0d | FAIL: %0d", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
