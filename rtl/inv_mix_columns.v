module inv_mix_columns (
input wire [127:0] in_state,
output wire [127:0] out_state
);

function [7:0] xtime;


input [7:0] a;


begin

xtime = (a[7] == 1'b1) ? ((a << 1) ^ 8'h1b) : (a << 1);

end

endfunction

function [7:0] mul9;
input [7:0] a;
begin
mul9 = xtime(xtime(xtime(a))) ^ a;
end
endfunction

function [7:0] mulB;
input [7:0] a;
begin
mulB = xtime(xtime(xtime(a))) ^ xtime(a) ^ a;
end
endfunction

function [7:0] mulD;
input [7:0] a;
begin
mulD = xtime(xtime(xtime(a))) ^ xtime(xtime(a)) ^ a;
end
endfunction

function [7:0] mulE;
input [7:0] a;
begin
mulE = xtime(xtime(xtime(a))) ^ xtime(xtime(a)) ^ xtime(a);
end
endfunction

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

assign out_state[127:120] = mulE(s0) ^ mulB(s1) ^ mulD(s2) ^ mul9(s3);
assign out_state[119:112] = mul9(s0) ^ mulE(s1) ^ mulB(s2) ^ mulD(s3);
assign out_state[111:104] = mulD(s0) ^ mul9(s1) ^ mulE(s2) ^ mulB(s3);
assign out_state[103:96] = mulB(s0) ^ mulD(s1) ^ mul9(s2) ^ mulE(s3);

assign out_state[95:88] = mulE(s4) ^ mulB(s5) ^ mulD(s6) ^ mul9(s7);
assign out_state[87:80] = mul9(s4) ^ mulE(s5) ^ mulB(s6) ^ mulD(s7);
assign out_state[79:72] = mulD(s4) ^ mul9(s5) ^ mulE(s6) ^ mulB(s7);
assign out_state[71:64] = mulB(s4) ^ mulD(s5) ^ mul9(s6) ^ mulE(s7);

assign out_state[63:56] = mulE(s8) ^ mulB(s9) ^ mulD(s10) ^ mul9(s11);
assign out_state[55:48] = mul9(s8) ^ mulE(s9) ^ mulB(s10) ^ mulD(s11);
assign out_state[47:40] = mulD(s8) ^ mul9(s9) ^ mulE(s10) ^ mulB(s11);
assign out_state[39:32] = mulB(s8) ^ mulD(s9) ^ mul9(s10) ^ mulE(s11);

assign out_state[31:24] = mulE(s12) ^ mulB(s13) ^ mulD(s14) ^ mul9(s15);
assign out_state[23:16] = mul9(s12) ^ mulE(s13) ^ mulB(s14) ^ mulD(s15);
assign out_state[15:8] = mulD(s12) ^ mul9(s13) ^ mulE(s14) ^ mulB(s15);
assign out_state[7:0] = mulB(s12) ^ mulD(s13) ^ mul9(s14) ^ mulE(s15);

endmodule
