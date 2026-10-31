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


        // Test 1: Single column check
        // FIPS-197 Section 5.3.3: InvMixColumns(8e 4d a1 bc) = db 13 53 45
        tb_in_state = 128'h8e4da1bc_00000000_00000000_00000000;
        #10;


        // Test 2: Full 4-column check with repeated pattern
        tb_in_state = 128'h8e4da1bc_8e4da1bc_8e4da1bc_8e4da1bc;
        #10;



    end

endmodule
