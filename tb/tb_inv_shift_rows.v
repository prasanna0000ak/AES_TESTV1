// File: tb_inv_shift_rows.v
// Description: Testbench for inv_shift_rows module

`timescale 1ns/1ps

module tb_inv_shift_rows;

    reg  [127:0] tb_in_state;
    wire [127:0] tb_out_state;

    // Instantiate DUT
    inv_shift_rows dut (
        .in_state (tb_in_state),
        .out_state(tb_out_state)
    );

    // Expected output for input 00112233445566778899AABBCCDDEEFF:
    // Row 0: 00 44 88 CC
    // Row 1: DD 11 55 99
    // Row 2: AA EE 22 66
    // Row 3: 77 BB FF 33
    // Column-major bit packed state: 00DDAA774411EEBB885522FFCC996633
    localparam [127:0] EXPECTED_OUT = 128'h00DDAA774411EEBB885522FFCC996633;

    integer pass_cnt = 0;
    integer fail_cnt = 0;

    initial begin
        $display("--------------------------------------------------");
        $display("Starting Testbench: InvShiftRows");
        $display("--------------------------------------------------");

        tb_in_state = 128'h00112233445566778899AABBCCDDEEFF;
        #10;

        $display("Input State  : %h", tb_in_state);
        $display("Output State : %h", tb_out_state);
        $display("Expected Out : %h", EXPECTED_OUT);

        if (tb_out_state === EXPECTED_OUT) begin
            $display("[RESULT] TEST 1 (InvShiftRows): PASS");
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[RESULT] TEST 1 (InvShiftRows): FAIL");
            $display("  Actual  : %h", tb_out_state);
            $display("  Expected: %h", EXPECTED_OUT);
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
