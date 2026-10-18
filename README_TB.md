

# AES-128 Decryption Core — Simulation Waveforms

**Group B | CDAC Project 
**Team:** Tithi · Prasanna · Shreyas
**Standard:** NIST FIPS-197 |

---

## Grand Summary

| # | Module Tested | Test Cases | Result |
|:--|:---|:---:|:---:|
| TB1 | `inv_shift_rows` | 1 | PASS |
| TB2 | `inv_sub_bytes` | 3 | PASS |
| TB3 | `inv_mix_columns` | 2 |  PASS |
| TB4 | `key_expansion` | 2 | PASS |
| TB5 | `aes_inv_cipher` (full core) | 1 | PASS |
| **Total** | | **9** | **All Passed** |

---

## TB1 — InvShiftRows (`inv_shift_rows.v`)

![InvShiftRows Waveform](waveforms/wave_inv_shift_rows.png)

### What This Module Does
`InvShiftRows` cyclically shifts each row of the AES 4×4 state matrix **to the right**.
This is the inverse of the encryption `ShiftRows` operation.

### Signal-by-Signal Explanation

| Signal | Value Seen | What It Means |
|:---|:---|:---|
| `tb_in_state` | `00112233445566778899AABBCCDDEEFF` | 128-bit ciphertext state fed as input |
| `in_state` | Same as `tb_in_state` | DUT sees the same input — wiring verified |
| `tb_out_state` | `00DDAA774411EEBB885522FFCC996633` | Output after applying InvShiftRows |
| `EXPECTED_OUT` | `00DDAA774411EEBB885522FFCC996633` | Hardcoded golden answer from FIPS-197 |
| `pass_cnt` | Transitions `0 → 1` | One test ran and passed |
| `fail_cnt` | Stays at `0` | Zero failures — logic is correct |

### Row Shift Mapping (Visible in Individual Byte Signals)

| Signal | Value | Meaning |
|:---|:---|:---|
| `s00_p` | `00` | Row 0, Col 0 — unchanged (shift right by 0) |
| `s01_p` | `44` | Row 0, Col 1 — unchanged |
| `s10_p` | `DD` | Row 1, Col 0 — came from Col 3 (shift right by 1) |
| `s11_p` | `11` | Row 1, Col 1 — came from Col 0 |
| `s20_p` | `AA` | Row 2, Col 0 — came from Col 2 (shift right by 2) |
| `s21_p` | `EE` | Row 2, Col 1 — came from Col 3 |
| `s30_p` | `77` | Row 3, Col 0 — came from Col 1 (shift right by 3) |
| `s31_p` | `BB` | Row 3, Col 1 — came from Col 2 |
| `s32_p` | `FF` | Row 3, Col 2 — came from Col 3 |
| `s33_p` | `33` | Row 3, Col 3 — came from Col 0 |

> **Key observation:** `tb_out_state` exactly matches `EXPECTED_OUT` throughout simulation —
> the module is combinational (no clock needed) so output is stable at `t = 0`.

---

## TB2 — InvSubBytes (`inv_sub_bytes.v`)

![InvSubBytes Waveform](waveforms/wave_inv_sub_bytes.png)

### What This Module Does
`InvSubBytes` replaces every byte of the 128-bit state with its inverse value from the
AES Inverse S-Box lookup table (FIPS-197 Table 6). All 16 bytes are substituted in parallel.

### Signal-by-Signal Explanation

| Signal | Value Seen | What It Means |
|:---|:---|:---|
| `tb_in_state` | Changes 3 times | Three different 128-bit test inputs applied |
| `in_state` | Mirrors `tb_in_state` | Input wiring confirmed correct |
| `tb_out_state` / `out_state` | Changes with each input | S-box output for each test case |
| `pass_cnt` | Increments `0 → 1 → 2 → 3` | Three tests ran, all passed |
| `fail_cnt` | Stays at `0` | No failures |

### Three Test Cases (Visible as State Transitions)

| Time Slot | Input (`tb_in_state`) | Output (`tb_out_state`) | Test |
|:---|:---|:---|:---|
| **Test 1** | `6300...00` (byte 0 = `0x63`) | Byte 0 output = `0x00` | InvSbox(0x63) = 0x00 ✅ |
| **Test 2** | `7C00...00` (byte 0 = `0x7C`) | Byte 0 output = `0x01` | InvSbox(0x7C) = 0x01 ✅ |
| **Test 3** | `000102...0F` (bytes 0x00..0x0F) | `52096AD5...` | Full 16-byte table check ✅ |

> **Key observation:** The `generate` loop applies the inverse S-box to all 16 bytes
> simultaneously. No clock is used — this is a purely combinational lookup.

---

## TB3 — InvMixColumns (`inv_mix_columns.v`)

![InvMixColumns Waveform](waveforms/wave_inv_mix_columns.png)

### What This Module Does
`InvMixColumns` applies matrix multiplication in GF(2⁸) arithmetic to each 4-byte column
of the state. Uses the FIPS-197 inverse matrix with coefficients `{0E, 0B, 0D, 09}`.

### Signal-by-Signal Explanation

| Signal | Value Seen | What It Means |
|:---|:---|:---|
| `tb_in_state` | `8E4DA1BC000...` → `8E4DA1BC8E4DA1BC...` | Two test inputs applied sequentially |
| `tb_out_state` | `DB135345000...` → `DB135345DB135345...` | Corresponding InvMixColumns results |
| `s0` | `8E` | Row 0 byte of Column 0 input |
| `s1` | `4D` | Row 1 byte of Column 0 input |
| `s2` | `A1` | Row 2 byte of Column 0 input |
| `s3` | `BC` | Row 3 byte of Column 0 input |
| `pass_cnt` | Increments `0 → 1 → 2` | Two tests ran, both passed |
| `fail_cnt` | Stays at `0` | No failures |

### FIPS-197 Column Example (Test 1 — visible at left side of waveform)

| Column Input | Matrix Operation | Column Output |
|:---|:---|:---|
| `[8E, 4D, A1, BC]` | GF(2⁸) multiply by inverse AES matrix | `[DB, 13, 53, 45]` |

> **Key observation:** In Test 2, all 4 columns are identical (`8E4DA1BC` repeated 4×).
> All 4 output columns show `DB135345` — proves the `generate` loop handles all columns independently.

---

## TB4 — Key Expansion (`key_expansion.v`)

![Key Expansion Waveform](waveforms/wave_key_expansion.png)

### What This Module Does
`key_expansion` takes the 128-bit AES master key and expands it into
**11 round keys** (1408 bits total — 44 words of 32 bits each), following FIPS-197 Section 5.2.

### Signal-by-Signal Explanation

| Signal | Value Seen | What It Means |
|:---|:---|:---|
| `tb_key` | `2B7E151628AED2A6ABF7158809CF4F3C` | The NIST FIPS-197 test master key input |
| `key` | Same as `tb_key` | Key wired correctly to the DUT |
| `key_schedule` | `2B7E1516...BEF44` (1408 bits) | All 11 round keys packed in one bus |
| `k0` | `2B7E151628AED2A6ABF7158809CF4F3C` | Round Key 0 = master key itself (w[0..3]) |
| `k10` | `D014F9A8C9EE2589E13F0CC8B6630CA6` | Round Key 10 — the last key (w[40..43]) |
| `EXPECTED_K0` | `2B7E151628AED2A6ABF7158809CF4F3C` | Golden expected value for K0 |
| `EXPECTED_K10` | `D014F9A8C9EE2589E13F0CC8B6630CA6` | Golden expected value for K10 |
| `pass_cnt` | Transitions `0 → 2` at end | Both key tests passed |
| `fail_cnt` | Stays at `0` | No failures |

### Internal Computation Signals

| Signal | Value | Meaning |
|:---|:---|:---|
| `r` (generate loop index) | `0` through `A` (10) | Iterates over the 11 round keys |
| `w` | `S75C006E`, `5C006E57`, etc. | Internal 32-bit word values (RotWord / SubWord intermediate) |

> **Key observation:** `key_schedule` is a single 1408-bit combinational bus. All 11 round keys
> are computed and available simultaneously — no clock cycles needed for key expansion.

---

## TB5 — Full AES-128 Inverse Cipher (`aes_inv_cipher.v`)

![AES InvCipher Waveform](waveforms/wave_aes_inv_cipher.png)

### What This Module Does
The top-level `aes_inv_cipher` module integrates all four sub-modules under a
5-state FSM (`IDLE → KEY_EXP → ROUND × 9 → FINAL → DONE`) and decrypts a
128-bit ciphertext block back to the original plaintext.

### Signal-by-Signal Explanation

| Signal | Value / Behaviour | What It Means |
|:---|:---|:---|
| `clk` | Continuous square wave | 100 MHz clock — every edge drives the FSM forward |
| `rst_n` | Goes `LOW → HIGH` early | Active-low reset released, FSM starts from IDLE |
| `start` | Single HIGH pulse | One-cycle trigger to begin decryption |
| `key` | `2B7E151628AED2A6ABF7158809CF4F3C` | FIPS-197 Appendix B master key loaded |
| `din` | `3925841D02DC09FBDC118597196A0B32` | Ciphertext input — the data to decrypt |
| `busy` | Goes HIGH then LOW | HIGH during all active decryption rounds, drops when done |
| `done` | Single HIGH pulse at end | Signals that `dout` is valid — one clock wide pulse only |
| `dout` | `3243F6A8885A308D313198A2E0370734` | Final recovered plaintext — matches FIPS-197 Appendix B ✅ |

### FSM State Signals (Visible as Numeric Bus Values)

| Signal | Value | Meaning |
|:---|:---|:---|
| `STATE_IDLE` | `0` | IDLE state encoding |
| `STATE_KEY_EXP` | `1` | KEY_EXP state — applies initial AddRoundKey(K10) |
| `STATE_FINAL` | `3` | FINAL state — last InvShiftRows + InvSubBytes + AddRoundKey(K0) |
| `STATE_DONE` | `4` | DONE state — pulses `done=1`, returns to IDLE |

### Intermediate Datapath Signals (Visible Round by Round)

| Signal | What It Shows |
|:---|:---|
| `current_round_key` | Changes each clock: K9 → K8 → ... → K1 as rounds count down |
| `shift_out` | State after InvShiftRows in current round |
| `sub_out` | State after InvSubBytes applied to `shift_out` |
| `rk_out` | State after AddRoundKey (XOR with round key) |
| `mix_out` | State after InvMixColumns — fed back as next round's input |
| `final_out` | Final XOR with K0 — this is the plaintext output |
| `timeout_cnt` | Counts `0 → 1 → 2 → ... → B` (0 to 11) | 11 FSM cycles taken to complete decryption |

### Decryption Timeline

```
Cycle 0 : rst_n = 0  → FSM in reset
Cycle 1 : rst_n = 1  → FSM enters IDLE
Cycle 2 : start = 1  → key and din captured, FSM moves to KEY_EXP
Cycle 3 : KEY_EXP    → AddRoundKey(K10) applied, FSM enters ROUND (round_cnt=9)
Cycle 4 : ROUND 9    → InvShiftRows, InvSubBytes, AddRoundKey(K9), InvMixColumns
Cycle 5 : ROUND 8    → ...
  ...
Cycle 12: ROUND 1    → last main round, FSM enters FINAL
Cycle 13: FINAL      → InvShiftRows, InvSubBytes, AddRoundKey(K0) → dout valid
Cycle 14: DONE       → done = 1 (one cycle pulse), busy = 0
Cycle 15: IDLE       → FSM resets, ready for next decryption
```

> **Key observation:** `done` pulses exactly once (single clock cycle) and `dout`
> shows `3243F6A8885A308D313198A2E0370734` — identical to the NIST FIPS-197
> Appendix B known plaintext. This confirms the entire 10-round decryption pipeline works correctly.

---

## File Reference

| File | Type | Description |
|:---|:---|:---|
| `inv_shift_rows.v` | RTL | Combinational InvShiftRows |
| `inv_sub_bytes.v` | RTL | Combinational InvSubBytes (Inv S-Box LUT) |
| `inv_mix_columns.v` | RTL | Combinational InvMixColumns (GF(2⁸) matrix) |
| `key_expansion.v` | RTL | Combinational AES-128 Key Schedule |
| `aes_inv_cipher.v` | RTL | Top-Level InvCipher with FSM |
| `tb_inv_shift_rows.v` | Testbench | Unit test for InvShiftRows |
| `tb_inv_sub_bytes.v` | Testbench | Unit test for InvSubBytes |
| `tb_inv_mix_columns.v` | Testbench | Unit test for InvMixColumns |
| `tb_key_expansion.v` | Testbench | Unit test for Key Expansion |
| `tb_aes_inv_cipher.v` | Testbench | Integration test for full core |
| `run_all_tb.sh` | Script | Run all TBs + generate all PNGs in one command |
| `vcd_to_png.py` | Script | Python VCD → PNG waveform renderer |
| `waveforms/*.png` | Output | Waveform screenshots for all 5 testbenches |
| `*.vcd` | Output | Raw waveform data (open with GTKWave) |

---
