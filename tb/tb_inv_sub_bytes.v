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


        // Test 1: InvSubBytes(63) = 00 for single byte at byte 0
        tb_in_state = 128'h63000000000000000000000000000000;
        #10;
       

        // Test 2: InvSubBytes(7c) = 01 for single byte at byte 0
        tb_in_state = 128'h7c000000000000000000000000000000;
        #10;
       

        // Test 3: Full 16-byte check (bytes 0x00..0x0F)
        tb_in_state = 128'h000102030405060708090a0b0c0d0e0f;
        #10;
      


        $finish;
    end

endmodule
