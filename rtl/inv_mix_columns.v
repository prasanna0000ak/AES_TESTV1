// File: inv_mix_columns.v
// Description: AES-128 InvMixColumns combinational module (FIPS-197 Section 5.3.3)
// Matrix multiplication in GF(2^8) with reduction polynomial 0x11B:
// [0E 0B 0D 09]
// [09 0E 0B 0D]
// [0D 09 0E 0B]
// [0B 0D 09 0E]

module inv_mix_columns (
    input  wire [127:0] in_state,
    output wire [127:0] out_state
);

    function [7:0] xtime;
        input [7:0] a;
        begin
            xtime = (a[7] == 1'b1) ? ((a << 1) ^ 8'h1b) : (a << 1);
        end
    endfunction

    function [7:0] gfm2;
        input [7:0] a;
        begin
            gfm2 = xtime(a);
        end
    endfunction

    function [7:0] gfm4;
        input [7:0] a;
        begin
            gfm4 = xtime(gfm2(a));
        end
    endfunction

    function [7:0] gfm8;
        input [7:0] a;
        begin
            gfm8 = xtime(gfm4(a));
        end
    endfunction

    function [7:0] gfm9;
        input [7:0] a;
        begin
            gfm9 = gfm8(a) ^ a;
        end
    endfunction

    function [7:0] gfmB;
        input [7:0] a;
        begin
            gfmB = gfm8(a) ^ gfm2(a) ^ a;
        end
    endfunction

    function [7:0] gfmD;
        input [7:0] a;
        begin
            gfmD = gfm8(a) ^ gfm4(a) ^ a;
        end
    endfunction

    function [7:0] gfmE;
        input [7:0] a;
        begin
            gfmE = gfm8(a) ^ gfm4(a) ^ gfm2(a);
        end
    endfunction

    generate
        genvar c;
        for (c = 0; c < 4; c = c + 1) begin : gen_inv_mix_col
            wire [7:0] s0 = in_state[127 - 32*c -: 8];
            wire [7:0] s1 = in_state[119 - 32*c -: 8];
            wire [7:0] s2 = in_state[111 - 32*c -: 8];
            wire [7:0] s3 = in_state[103 - 32*c -: 8];

            assign out_state[127 - 32*c -: 8] = gfmE(s0) ^ gfmB(s1) ^ gfmD(s2) ^ gfm9(s3);
            assign out_state[119 - 32*c -: 8] = gfm9(s0) ^ gfmE(s1) ^ gfmB(s2) ^ gfmD(s3);
            assign out_state[111 - 32*c -: 8] = gfmD(s0) ^ gfm9(s1) ^ gfmE(s2) ^ gfmB(s3);
            assign out_state[103 - 32*c -: 8] = gfmB(s0) ^ gfmD(s1) ^ gfm9(s2) ^ gfmE(s3);
        end
    endgenerate

endmodule
