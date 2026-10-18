// File: aes_inv_cipher.v
// Description: Full AES-128 Inverse Cipher Top-Level Core with Control FSM (FIPS-197 Section 5.3)

module aes_inv_cipher (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] din,  // Ciphertext input
    output reg  [127:0] dout, // Plaintext output
    output reg          busy,
    output reg          done
);

    // FSM State Encoding
    localparam [2:0] STATE_IDLE    = 3'd0;
    localparam [2:0] STATE_KEY_EXP = 3'd1;
    localparam [2:0] STATE_ROUND   = 3'd2;
    localparam [2:0] STATE_FINAL   = 3'd3;
    localparam [2:0] STATE_DONE    = 3'd4;

    reg [2:0] state;
    reg [3:0] round_cnt;

    reg [127:0] key_reg;
    reg [127:0] din_reg;
    reg [127:0] state_reg;

    // Key Expansion Instance
    wire [1407:0] key_schedule;
    key_expansion key_exp_inst (
        .key         (key_reg),
        .key_schedule(key_schedule)
    );

    // Combinational Round Datapath Signals
    wire [127:0] current_round_key;
    assign current_round_key = key_schedule[1407 - 128*round_cnt -: 128];

    wire [127:0] shift_out;
    inv_shift_rows inv_shift_inst (
        .in_state (state_reg),
        .out_state(shift_out)
    );

    wire [127:0] sub_out;
    inv_sub_bytes inv_sub_inst (
        .in_state (shift_out),
        .out_state(sub_out)
    );

    wire [127:0] rk_out;
    assign rk_out = sub_out ^ current_round_key;

    wire [127:0] mix_out;
    inv_mix_columns inv_mix_inst (
        .in_state (rk_out),
        .out_state(mix_out)
    );

    wire [127:0] final_out;
    assign final_out = sub_out ^ key_schedule[1407:1280]; // Round Key 0

    // Sequential FSM & Datapath Control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= STATE_IDLE;
            round_cnt <= 4'd0;
            key_reg   <= 128'd0;
            din_reg   <= 128'd0;
            state_reg <= 128'd0;
            dout      <= 128'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        key_reg   <= key;
                        din_reg   <= din;
                        busy      <= 1'b1;
                        state     <= STATE_KEY_EXP;
                    end else begin
                        busy      <= 1'b0;
                    end
                end

                STATE_KEY_EXP: begin
                    // Initial round: AddRoundKey(ciphertext, K10)
                    state_reg <= din_reg ^ key_schedule[127:0]; // Round Key 10
                    round_cnt <= 4'd9;
                    state     <= STATE_ROUND;
                end

                STATE_ROUND: begin
                    state_reg <= mix_out;
                    if (round_cnt == 4'd1) begin
                        state <= STATE_FINAL;
                    end else begin
                        round_cnt <= round_cnt - 4'd1;
                    end
                end

                STATE_FINAL: begin
                    dout  <= final_out;
                    done  <= 1'b1;
                    state <= STATE_DONE;
                end

                STATE_DONE: begin
                    done  <= 1'b0;
                    busy  <= 1'b0;
                    state <= STATE_IDLE;
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
