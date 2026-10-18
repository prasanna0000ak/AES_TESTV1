// File: tb_inv_mix_columns.v
// Description: Testbench for inv_mix_columns module

`timescale 1ns/1ps

module tb_inv_mix_columns;

    reg  [127:0] tb_in_state;
    wire [127:0] tb_out_state;

    // Instantiate DUT
    inv_mix_columns dut (
        .in_state (tb_in_state),
        .out_state(tb_out_state)
    );

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    initial begin
        $display("--------------------------------------------------");
        $display("Starting Testbench: InvMixColumns");
        $display("--------------------------------------------------");

        // Test 1: Single column check
        // FIPS-197 Section 5.3.3: InvMixColumns(8e 4d a1 bc) = db 13 53 45
        tb_in_state = 128'h8e4da1bc_00000000_00000000_00000000;
        #10;
        if (tb_out_state[127:96] === 32'hdb135345) begin
            $display("[RESULT] TEST 1 (InvMixColumns column [8e 4d a1 bc] -> [db 13 53 45]): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 1 (InvMixColumns column [8e 4d a1 bc]): FAIL");
            $display("  Actual  : %h", tb_out_state[127:96]);
            $display("  Expected: db135345");
            fail_cnt = fail_cnt + 1;
        end

        // Test 2: Full 4-column check with repeated pattern
        tb_in_state = 128'h8e4da1bc_8e4da1bc_8e4da1bc_8e4da1bc;
        #10;
        if (tb_out_state === 128'hdb135345_db135345_db135345_db135345) begin
            $display("[RESULT] TEST 2 (Full 4-column InvMixColumns): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 2 (Full 4-column InvMixColumns): FAIL");
            $display("  Actual  : %h", tb_out_state);
            $display("  Expected: db135345db135345db135345db135345");
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
