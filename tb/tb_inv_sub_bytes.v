// File: tb_inv_sub_bytes.v
// Description: Testbench for inv_sub_bytes module

`timescale 1ns/1ps

module tb_inv_sub_bytes;

    reg  [127:0] tb_in_state;
    wire [127:0] tb_out_state;

    // Instantiate DUT
    inv_sub_bytes dut (
        .in_state (tb_in_state),
        .out_state(tb_out_state)
    );

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    initial begin
        $display("--------------------------------------------------");
        $display("Starting Testbench: InvSubBytes");
        $display("--------------------------------------------------");

        // Test 1: InvSubBytes(63) = 00 for single byte at byte 0
        tb_in_state = 128'h63000000000000000000000000000000;
        #10;
        if (tb_out_state[127:120] === 8'h00) begin
            $display("[RESULT] TEST 1 (InvSubBytes(63) == 00): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 1 (InvSubBytes(63) == 00): FAIL (Got: %h)", tb_out_state[127:120]);
            fail_cnt = fail_cnt + 1;
        end

        // Test 2: InvSubBytes(7c) = 01 for single byte at byte 0
        tb_in_state = 128'h7c000000000000000000000000000000;
        #10;
        if (tb_out_state[127:120] === 8'h01) begin
            $display("[RESULT] TEST 2 (InvSubBytes(7c) == 01): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 2 (InvSubBytes(7c) == 01): FAIL (Got: %h)", tb_out_state[127:120]);
            fail_cnt = fail_cnt + 1;
        end

        // Test 3: Full 16-byte check (bytes 0x00..0x0F)
        tb_in_state = 128'h000102030405060708090a0b0c0d0e0f;
        #10;
        if (tb_out_state === 128'h52096ad53036a538bf40a39e81f3d7fb) begin
            $display("[RESULT] TEST 3 (Full 16-byte InvSubBytes): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 3 (Full 16-byte InvSubBytes): FAIL");
            $display("  Actual  : %h", tb_out_state);
            $display("  Expected: 52096ad53036a538bf40a39e81f3d7fb");
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
