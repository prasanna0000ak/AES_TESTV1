`timescale 1ns/1ps

module tb_key_expansion;

reg [127:0] tb_key;
reg [3:0] tb_round;
reg tb_dir;
wire [127:0] tb_key_out;

key_expansion dut (
.key_in   (tb_key),
.round_num(tb_round),
.dir      (tb_dir),
.key_out  (tb_key_out)
);

localparam [127:0] K0  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
localparam [127:0] K1  = 128'ha0fafe1788542cb123a339392a6c7605;
localparam [127:0] K10 = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;

integer pass_cnt = 0;
integer fail_cnt = 0;

initial begin

tb_key = K0;
tb_round = 4'd1;
tb_dir = 1'b1;
#10;



tb_key = K1;
tb_round = 4'd1;
tb_dir = 1'b0;
#10;




$finish;
end

endmodule
