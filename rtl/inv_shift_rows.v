module inv_shift_rows (
input wire [127:0] in_state,
output wire [127:0] out_state
);

wire [7:0] s0 = in_state[127:120];
wire [7:0] s1 = in_state[119:112];
wire [7:0] s2 = in_state[111:104];
wire [7:0] s3 = in_state[103:96];

wire [7:0] s4 = in_state[95:88];
wire [7:0] s5 = in_state[87:80];
wire [7:0] s6 = in_state[79:72];
wire [7:0] s7 = in_state[71:64];

wire [7:0] s8 = in_state[63:56];
wire [7:0] s9 = in_state[55:48];
wire [7:0] s10 = in_state[47:40];
wire [7:0] s11 = in_state[39:32];

wire [7:0] s12 = in_state[31:24];
wire [7:0] s13 = in_state[23:16];
wire [7:0] s14 = in_state[15:8];
wire [7:0] s15 = in_state[7:0];

assign out_state[127:120] = s0;
assign out_state[119:112] = s13;
assign out_state[111:104] = s10;
assign out_state[103:96] = s7;

assign out_state[95:88] = s4;
assign out_state[87:80] = s1;
assign out_state[79:72] = s14;
assign out_state[71:64] = s11;

assign out_state[63:56] = s8;
assign out_state[55:48] = s5;
assign out_state[47:40] = s2;
assign out_state[39:32] = s15;

assign out_state[31:24] = s12;
assign out_state[23:16] = s9;
assign out_state[15:8] = s6;
assign out_state[7:0] = s3;

endmodule
