// File: inv_shift_rows.v
// Description: AES-128 InvShiftRows combinational module (FIPS-197 Section 5.3.1)
// Byte mapping: state byte i (0..15) = in_state[127-8i -: 8], column-major order.
// Byte index i = row + 4 * col
// Cyclic right shift of row r by r positions: s'[r, c] = s[r, (c - r) mod 4]

module inv_shift_rows (
    input  wire [127:0] in_state,
    output wire [127:0] out_state
);

    // Extract input state matrix s[row, col]
    // Row 0
    wire [7:0] s00 = in_state[127:120]; // Byte 0
    wire [7:0] s01 = in_state[95:88];   // Byte 4
    wire [7:0] s02 = in_state[63:56];   // Byte 8
    wire [7:0] s03 = in_state[31:24];   // Byte 12

    // Row 1
    wire [7:0] s10 = in_state[119:112]; // Byte 1
    wire [7:0] s11 = in_state[87:80];   // Byte 5
    wire [7:0] s12 = in_state[55:48];   // Byte 9
    wire [7:0] s13 = in_state[23:16];   // Byte 13

    // Row 2
    wire [7:0] s20 = in_state[111:104]; // Byte 2
    wire [7:0] s21 = in_state[79:72];   // Byte 6
    wire [7:0] s22 = in_state[47:40];   // Byte 10
    wire [7:0] s23 = in_state[15:8];    // Byte 14

    // Row 3
    wire [7:0] s30 = in_state[103:96];  // Byte 3
    wire [7:0] s31 = in_state[71:64];   // Byte 7
    wire [7:0] s32 = in_state[39:32];   // Byte 11
    wire [7:0] s33 = in_state[7:0];     // Byte 15

    // InvShiftRows mapping: s'[r, c] = s[r, (c - r) mod 4]
    // Row 0: shift 0
    wire [7:0] s00_p = s00;
    wire [7:0] s01_p = s01;
    wire [7:0] s02_p = s02;
    wire [7:0] s03_p = s03;

    // Row 1: shift 1 right -> s'[1,c] = s[1, (c-1) mod 4]
    wire [7:0] s10_p = s13;
    wire [7:0] s11_p = s10;
    wire [7:0] s12_p = s11;
    wire [7:0] s13_p = s12;

    // Row 2: shift 2 right -> s'[2,c] = s[2, (c-2) mod 4]
    wire [7:0] s20_p = s22;
    wire [7:0] s21_p = s23;
    wire [7:0] s22_p = s20;
    wire [7:0] s23_p = s21;

    // Row 3: shift 3 right -> s'[3,c] = s[3, (c-3) mod 4] = s[3, (c+1) mod 4]
    wire [7:0] s30_p = s31;
    wire [7:0] s31_p = s32;
    wire [7:0] s32_p = s33;
    wire [7:0] s33_p = s30;

    // Pack output state in column-major byte order
    assign out_state = {
        s00_p, s10_p, s20_p, s30_p, // Column 0 (Bytes 0, 1, 2, 3)
        s01_p, s11_p, s21_p, s31_p, // Column 1 (Bytes 4, 5, 6, 7)
        s02_p, s12_p, s22_p, s32_p, // Column 2 (Bytes 8, 9, 10, 11)
        s03_p, s13_p, s23_p, s33_p  // Column 3 (Bytes 12, 13, 14, 15)
    };

endmodule
