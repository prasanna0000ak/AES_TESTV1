// File: tb_key_expansion.v
// Description: Testbench for key_expansion module

`timescale 1ns/1ps

module tb_key_expansion;

    reg  [127:0]  tb_key;
    wire [1407:0] tb_key_schedule;

    // Instantiate DUT
    key_expansion dut (
        .key         (tb_key),
        .key_schedule(tb_key_schedule)
    );

    // Expected Round Key 0 (w[0..3]): 2b7e1516 28aed2a6 abf71588 09cf4f3c
    localparam [127:0] EXPECTED_K0  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    // Expected Round Key 10 (w[40..43]): d014f9a8 c9ee2589 e13f0cc8 b6630ca6
    localparam [127:0] EXPECTED_K10 = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    wire [127:0] k0  = tb_key_schedule[1407:1280];
    wire [127:0] k10 = tb_key_schedule[127:0];

    initial begin
        $display("--------------------------------------------------");
        $display("Starting Testbench: KeyExpansion");
        $display("--------------------------------------------------");

        tb_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        #10;

        $display("Input Key : %h", tb_key);
        $display("K0  (w[0..3])   : %h", k0);
        $display("K10 (w[40..43]) : %h", k10);

        // Test 1: Check Round Key 0
        if (k0 === EXPECTED_K0) begin
            $display("[RESULT] TEST 1 (Round Key 0 w[0..3]): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 1 (Round Key 0 w[0..3]): FAIL");
            $display("  Actual  : %h", k0);
            $display("  Expected: %h", EXPECTED_K0);
            fail_cnt = fail_cnt + 1;
        end

        // Test 2: Check Round Key 10 (w[40..43])
        if (k10 === EXPECTED_K10) begin
            $display("[RESULT] TEST 2 (Last Round Key 10 w[40..43]): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 2 (Last Round Key 10 w[40..43]): FAIL");
            $display("  Actual  : %h", k10);
            $display("  Expected: %h", EXPECTED_K10);
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
