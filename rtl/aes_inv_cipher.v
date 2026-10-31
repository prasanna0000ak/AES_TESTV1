module aes_inv_cipher (
input wire clk,
input wire rst_n,
input wire start,
input wire [127:0] key,
input wire [127:0] din,
output reg [127:0] dout,
output reg busy,
output reg done
);



localparam [2:0] STATE_IDLE = 3'd0;
localparam [2:0] STATE_FWD_KEY = 3'd1;
localparam [2:0] STATE_PRE_DEC = 3'd2;
localparam [2:0] STATE_ROUND = 3'd3;
localparam [2:0] STATE_FINAL = 3'd4;
localparam [2:0] STATE_DONE = 3'd5;


reg [2:0] state;
reg [3:0] round_cnt;
reg [127:0] curr_key;
reg [127:0] din_reg;
reg [127:0] state_reg;



wire [127:0] key_step_out;
wire key_dir;


assign key_dir = (state == STATE_FWD_KEY) ? 1'b1 : 1'b0;

key_expansion key_step_inst (`
.key_in(curr_key),
.round_num(round_cnt),
.dir(key_dir),
.key_out(key_step_out)
);



wire [127:0] shift_out;
inv_shift_rows inv_shift_inst (
.in_state(state_reg),
.out_state(shift_out)
);



wire [127:0] sub_out;
inv_sub_bytes inv_sub_inst (
.in_state(shift_out),      ////^^^
.out_state(sub_out)
);
wire [127:0] rk_out;
assign rk_out = sub_out ^ key_step_out;




wire [127:0] mix_out;
inv_mix_columns inv_mix_inst (
.in_state(rk_out),      ////^^^
.out_state(mix_out)
);
wire [127:0] final_out;
assign final_out = sub_out ^ key_step_out; ////form key expansion 






always @(posedge clk or negedge rst_n) 

begin
if (!rst_n) 
begin
state <= STATE_IDLE;
round_cnt <= 4'd0;
curr_key <= 128'd0;
din_reg <= 128'd0;
state_reg <= 128'd0;
dout <= 128'd0;
busy <= 1'b0;
done <= 1'b0;
end 


else
begin
case (state) STATE_IDLE: 
begin
done <= 1'b0;

if (start) 
begin
curr_key <= key;
din_reg <= din;
busy <= 1'b1;
round_cnt <= 4'd1;
state <= STATE_FWD_KEY;
end 

else 
busy <= 1'b0;
end
end


STATE_FWD_KEY: begin
curr_key <= key_step_out;

if (round_cnt == 4'd10)
begin
state <= STATE_PRE_DEC;
end 

else begin
round_cnt <= round_cnt + 4'd1;
end
end

STATE_PRE_DEC: begin
state_reg <= din_reg ^ curr_key;
round_cnt <= 4'd10;
state <= STATE_ROUND;

end

STATE_ROUND: begin
state_reg <= mix_out;
curr_key <= key_step_out;
if (round_cnt == 4'd2) 

begin
round_cnt <= 4'd1;
state <= STATE_FINAL;
end

else begin
round_cnt <= round_cnt - 4'd1;
end
end

STATE_FINAL: begin
dout <= final_out;
done <= 1'b1;
state <= STATE_DONE;
end

STATE_DONE: begin
done <= 1'b0;
busy <= 1'b0;
state <= STATE_IDLE;
end

default: begin
state <= STATE_IDLE;
end
endcase
end
end

endmodule
