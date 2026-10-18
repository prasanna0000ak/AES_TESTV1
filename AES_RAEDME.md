# AES-128 Decryption Core — RTL Design and Verification
### Group B | CDAC Project |

**Team Members:** Tithi, Prasanna, Shreyas
**Reference Standard:** NIST FIPS-197 (Advanced Encryption Standard)

---

## 1. Project Background

### 1.1 What is AES?

AES (Advanced Encryption Standard) is a globally accepted algorithm used to protect data. It was published by the United States National Institute of Standards and Technology (NIST) as FIPS-197 in 2001 and is used in banking, secure communications, and embedded systems worldwide.

AES-128 works by taking a block of 128 bits of data and scrambling it using a 128-bit secret key. The scrambled output is called **ciphertext**. To recover the original data (called **plaintext**), the ciphertext must be **decrypted** using the same key and the inverse algorithm.

### 1.2 Why Implement AES in Hardware (FPGA)?

Software running on a processor executes instructions one step at a time. Hardware circuits can perform many operations simultaneously (in parallel), making them much faster and more energy-efficient for cryptographic tasks. An FPGA (Field-Programmable Gate Array) is a chip whose internal circuit can be configured after manufacturing — making it ideal for prototyping hardware designs like AES.


## 2. AES-128 Decryption — Technical Overview

### 2.1 The 128-Bit State Block

AES processes data in fixed 128-bit (16-byte) chunks called **blocks**. These 16 bytes are arranged as a 4×4 matrix (called the **state**) in column-major order:

```
Byte Index:  0   4   8  12
             1   5   9  13
             2   6  10  14
             3   7  11  15
```

This means byte 0 is top-left, byte 1 is below it, and so on — filling columns first. This specific byte ordering is defined in FIPS-197 Section 3.4 and must be followed exactly.

### 2.2 The Four Decryption Operations

AES decryption applies four operations in each round. Each operation undoes a corresponding encryption operation:

| Operation | What It Does |
|:---|:---|
| **InvShiftRows** | Cyclically shifts each row of the 4×4 grid to the **right** (reverse of encryption's left shift) |
| **InvSubBytes** | Replaces every byte using a reverse lookup table (Inverse S-Box — FIPS-197 Table 6) |
| **AddRoundKey** | XORs the current data block with the secret round key for that round |
| **InvMixColumns** | Scrambles each column using matrix multiplication in GF(2⁸) arithmetic |

### 2.3 The 10 Rounds and Round Keys

AES-128 applies these operations in **10 rounds** to make the encryption strong. A **round key** is a unique 128-bit secret value used in each round, derived from the original master key.

### 2.4 Key Expansion

The single 128-bit master key is expanded into **11 round keys** (one for the initial step + one per round) using a process defined in FIPS-197 Section 5.2. The decryption core generates these keys internally and independently, without depending on the encryption core.

### 2.5 Inverse Cipher Algorithm (FIPS-197 Section 5.3)

The exact decryption sequence is:

```
Step 1:  AddRoundKey( ciphertext, RoundKey[10] )

Step 2:  for round = 9 down to 1:
             InvShiftRows
             InvSubBytes
             AddRoundKey( state, RoundKey[round] )
             InvMixColumns

Step 3:  InvShiftRows
         InvSubBytes
         AddRoundKey( state, RoundKey[0] )
         → Output: Plaintext
```

---

## 3. Implementation — Step by Step

### Step 1: InvShiftRows
**File:** `inv_shift_rows.v` | **Testbench:** `tb_inv_shift_rows.v`

**Goal:** Undo the ShiftRows operation from encryption by cyclically shifting each row to the right.

**Shift Rule (FIPS-197 Section 5.3.1):**
```
Row 0 → shift right by 0 (no change)
Row 1 → shift right by 1
Row 2 → shift right by 2
Row 3 → shift right by 3
```
This is described mathematically as: `s'[r, c] = s[r, (c - r) mod 4]`

**Bug Found:** The teammate's starter code had an incorrect row 3 mapping. It was shifting left instead of right by 3. This was corrected in our implementation.

**Test Vector:**
| Input State | Expected Output |
|:---|:---|
| `00112233445566778899AABBCCDDEEFF` | `004488CCDD115599AAEE226677BBFF33` |

**Simulation Result: ✅ PASS**
```
Input State  : 00112233445566778899aabbccddeeff
Output State : 00ddaa774411eebb885522ffcc996633
[RESULT] TEST 1 (InvShiftRows): PASS
SUMMARY - PASS: 1 | FAIL: 0
ALL TESTS PASSED
```

---

### Step 2: InvSubBytes
**File:** `inv_sub_bytes.v` | **Testbench:** `tb_inv_sub_bytes.v`

**Goal:** Replace each of the 16 bytes in the state with its inverse S-Box value using the 256-entry lookup table defined in FIPS-197 Table 6.

**How It Works:** A `case` statement function maps every possible input byte (0x00 to 0xFF) to its corresponding output byte. The function is applied independently to all 16 bytes using a `generate` loop.

**Key Test Points (from FIPS-197):**
- `InvSubBytes(0x63) = 0x00`
- `InvSubBytes(0x7C) = 0x01`

**Simulation Result: ✅ PASS**
```
[RESULT] TEST 1 (InvSubBytes(63) == 00): PASS
[RESULT] TEST 2 (InvSubBytes(7c) == 01): PASS
[RESULT] TEST 3 (Full 16-byte InvSubBytes): PASS
SUMMARY - PASS: 3 | FAIL: 0
ALL TESTS PASSED
```

---

### Step 3: InvMixColumns
**File:** `inv_mix_columns.v` | **Testbench:** `tb_inv_mix_columns.v`

**Goal:** Apply matrix multiplication in GF(2⁸) arithmetic (Galois Field) to each 4-byte column of the state, using the FIPS-197 Section 5.3.3 inverse matrix.

**Inverse Matrix (FIPS-197 Section 5.3.3):**
```
| 0E  0B  0D  09 |
| 09  0E  0B  0D |
| 0D  09  0E  0B |
| 0B  0D  09  0E |
```

**GF(2⁸) Arithmetic:** All multiplications use XOR and bit-shifts with reduction by the AES irreducible polynomial `x⁸ + x⁴ + x³ + x + 1` (0x11B). This is implemented using the `xtime()` function.

**Test Vector (FIPS-197 Example):**
| Input Column | Expected Output Column |
|:---|:---|
| `8E 4D A1 BC` | `DB 13 53 45` |

**Simulation Result: ✅ PASS**
```
[RESULT] TEST 1 (InvMixColumns column [8e 4d a1 bc] -> [db 13 53 45]): PASS
[RESULT] TEST 2 (Full 4-column InvMixColumns): PASS
SUMMARY - PASS: 2 | FAIL: 0
ALL TESTS PASSED
```

---

### Step 4: Key Expansion
**File:** `key_expansion.v` | **Testbench:** `tb_key_expansion.v`

**Goal:** Expand the 128-bit master key into 11 round keys (44 32-bit words: w[0..43]) as specified in FIPS-197 Section 5.2.

**Algorithm:**
- Words `w[0..3]` are taken directly from the 128-bit key.
- For each subsequent word `w[i]`:
  - If `i mod 4 == 0`: Apply `SubWord(RotWord(w[i-1])) XOR Rcon[i/4]`, then XOR with `w[i-4]`.
  - Otherwise: Simply XOR `w[i-1]` with `w[i-4]`.

**Key Functions:**
- `RotWord`: Rotate a 32-bit word left by 8 bits.
- `SubWord`: Apply the forward S-Box to each of the 4 bytes of a word.
- `Rcon`: Round constants — predetermined values used in key schedule.

**Test Vector (NIST FIPS-197 Appendix A):**
| | Value |
|:---|:---|
| Input Key | `2b7e151628aed2a6abf7158809cf4f3c` |
| Round Key 0 (w[0..3]) | `2b7e151628aed2a6abf7158809cf4f3c` |
| Round Key 10 (w[40..43]) | `d014f9a8c9ee2589e13f0cc8b6630ca6` |

**Simulation Result: ✅ PASS**
```
Input Key : 2b7e151628aed2a6abf7158809cf4f3c
K0  (w[0..3])   : 2b7e151628aed2a6abf7158809cf4f3c
K10 (w[40..43]) : d014f9a8c9ee2589e13f0cc8b6630ca6
[RESULT] TEST 1 (Round Key 0 w[0..3]): PASS
[RESULT] TEST 2 (Last Round Key 10 w[40..43]): PASS
SUMMARY - PASS: 2 | FAIL: 0
ALL TESTS PASSED
```

---

### Step 5: Full AES-128 Inverse Cipher with Control FSM
**File:** `aes_inv_cipher.v` | **Testbench:** `tb_aes_inv_cipher.v`

**Goal:** Combine all four modules into a complete, sequentially controlled decryption engine with a hardware state machine.

**Module Interface:**
| Signal | Direction | Width | Description |
|:---|:---|:---:|:---|
| `clk` | Input | 1-bit | Clock signal |
| `rst_n` | Input | 1-bit | Active-low reset |
| `start` | Input | 1-bit | Start decryption pulse |
| `key` | Input | 128-bit | AES-128 master key |
| `din` | Input | 128-bit | Ciphertext input |
| `dout` | Output | 128-bit | Decrypted plaintext |
| `busy` | Output | 1-bit | High while decrypting |
| `done` | Output | 1-bit | One-cycle pulse when output is valid |

**FSM State Diagram:**
```
IDLE ──(start=1)──► KEY_EXP ──► ROUND (×9) ──► FINAL ──► DONE ──► IDLE
```

| State | Action |
|:---|:---|
| `IDLE` | Waits for `start` signal, captures `key` and `din` |
| `KEY_EXP` | Applies initial AddRoundKey(K10) to ciphertext |
| `ROUND` | Executes: InvShiftRows → InvSubBytes → AddRoundKey(Kr) → InvMixColumns (9 times: rounds 9 down to 1) |
| `FINAL` | Executes: InvShiftRows → InvSubBytes → AddRoundKey(K0) |
| `DONE` | Pulses `done=1` for one clock cycle, then returns to IDLE |

**Note:** The key expansion module is combinational (pure logic), so round keys are immediately available in KEY_EXP — no separate key schedule computation cycles are needed.

**Known Answer Test (FIPS-197 Appendix B):**
| | Value |
|:---|:---|
| Key | `2b7e151628aed2a6abf7158809cf4f3c` |
| Ciphertext Input (`din`) | `3925841d02dc09fbdc118597196a0b32` |
| Expected Plaintext (`dout`) | `3243f6a8885a308d313198a2e0370734` |

**Python Pre-Verification (cryptography library):**
Before loading values into the testbench, all expected values were independently verified using Python's `cryptography` library (AES-ECB decryption). Both test vectors matched exactly.

**Simulation Result: ✅ PASS**
```
[RESULT] TEST 1 (FIPS-197 Appendix B Decryption): PASS
  Plaintext Result: 3243f6a8885a308d313198a2e0370734
SUMMARY - PASS: 1 | FAIL: 0
ALL TESTS PASSED
```

---

## 4. Bugs Found and Fixed

### Bug 1: Incorrect Row 3 Shift in Teammate's `round.v`

**Problem:** The original starter code shifted row 3 in the wrong direction (left by 1 instead of right by 3).

**Effect:** Row 3 bytes ended up in wrong positions, producing completely wrong decryption output.

**Fix:** Corrected the mapping using the FIPS-197 definition:
```
s'[3, c] = s[3, (c - 3) mod 4]
```
Which maps:
- Column 0 ← Column 1 (previously wrong)
- Column 1 ← Column 2
- Column 2 ← Column 3
- Column 3 ← Column 0

---

### Bug 2: Wrong Expected Value in Teammate's `tb_round.v`

**Problem:** The teammate's testbench had the expected output of InvShiftRows as:
```
004488CCDD115599AAEE2266FF3377BB  ← WRONG
```
**Why it was wrong:** The last 4 bytes (`FF3377BB`) were derived from the buggy row 3 shift, so the expected value itself was wrong.

**Correct value (verified by Python):**
```
004488CCDD115599AAEE226677BBFF33  ← CORRECT (row-by-row)
00DDAA774411EEBB885522FFCC996633  ← CORRECT (column-major bit-packed)
```

**Why this matters:** In cryptography, even a single wrong bit makes the final output completely unrecognizable. Hard-coding wrong expected values in a testbench means bugs pass silently as "PASS" — which is more dangerous than a failing test.

---

## 5. File Listing

| File | Type | Description |
|:---|:---|:---|
| `inv_shift_rows.v` | RTL | Combinational InvShiftRows module |
| `tb_inv_shift_rows.v` | Testbench | Verifies InvShiftRows with FIPS vector |
| `inv_sub_bytes.v` | RTL | Combinational InvSubBytes (256-entry Inv S-Box) |
| `tb_inv_sub_bytes.v` | Testbench | Verifies InvSubBytes with single-byte and full-state tests |
| `inv_mix_columns.v` | RTL | Combinational InvMixColumns (GF(2⁸) matrix multiply) |
| `tb_inv_mix_columns.v` | Testbench | Verifies InvMixColumns with FIPS column example |
| `key_expansion.v` | RTL | Combinational AES-128 Key Expansion (all 11 round keys) |
| `tb_key_expansion.v` | Testbench | Verifies key schedule w[0..3] and w[40..43] |
| `aes_inv_cipher.v` | RTL | Top-level AES-128 Decryption Core with FSM |
| `tb_aes_inv_cipher.v` | Testbench | Verifies full decryption (FIPS-197 Appendix B) |

---

## 6. Simulation Summary

| Step | Module | Test Cases | Result |
|:---|:---|:---:|:---:|
| Step 1 | InvShiftRows | 1 | ✅ PASS |
| Step 2 | InvSubBytes | 3 | ✅ PASS |
| Step 3 | InvMixColumns | 2 | ✅ PASS |
| Step 4 | Key Expansion | 2 | ✅ PASS |
| Step 5 | Full InvCipher | 1 | ✅ PASS |
| **Total** | | **9** | **✅ All Passed** |

**Tools Used:**
- **Simulator:** Icarus Verilog (`iverilog` + `vvp`) v10.3
- **Python Verification:** `cryptography` library (AES-128 ECB)
- **Target Synthesis:** Xilinx Vivado (Zynq-7000)

---

## 7. What Remains (Pending Work)

The following items are designed and planned but not yet implemented:

1. **Step 6 — Full Self-Checking Testbench (`tb_aes_inv_cipher_kat.v`)**
   - FIPS-197 Appendix B (key A) full decrypt test
   - FIPS-197 Appendix C.1 (key B: `000102030405060708090a0b0c0d0e0f`) decrypt test
   - Automatic pass/fail counters with timeout watchdog
   - VCD waveform dump for GTKWave analysis
   - Final summary: `TOTAL: N  PASS: P  FAIL: F`

2. **AXI4-Lite Slave Wrapper** (Joint work with Group A)
   - Expose `key`, `din`, `dout`, `start`, `busy`, `done` as memory-mapped registers
   - Integrate into Zynq-7000 PS-PL system via AXI interconnect

3. **FPGA Hardware Validation**
   - Bitstream generation and board bring-up on ZedBoard / ZC702
   - End-to-end test: Encrypt (Group A) → BRAM → Decrypt (Group B) → UART output

---

| Term | Definition |
|:---|:---|
| **AES** | Advanced Encryption Standard — a symmetric-key block cipher algorithm |
| **Plaintext** | Original readable data before encryption |
| **Ciphertext** | Scrambled data after encryption |
| **Key** | A secret 128-bit value used to encrypt and decrypt data |
| **Block** | A fixed 128-bit chunk of data processed at one time by AES |
| **Byte** | A group of 8 binary bits; AES operates on 16 bytes at a time |
| **Round** | One complete set of four AES operations applied to the state |
| **Round Key** | A 128-bit secret derived from the master key, unique to each round |
| **Key Expansion** | The algorithm that generates 11 round keys from 1 master key |
| **State** | The 4×4 matrix of 16 bytes being processed inside AES at any moment |
| **S-Box** | Substitution Box — a fixed 256-entry lookup table used in SubBytes |
| **GF(2⁸)** | Galois Field — a special number system used in MixColumns arithmetic |
| **FSM** | Finite State Machine — a circuit that steps through defined operating states |
| **RTL** | Register Transfer Level — hardware described as data flowing between registers |
| **Verilog** | A hardware description language used to design digital circuits |
| **Synthesizable** | Code that can be converted by tools into actual logic gates on a chip |
| **FPGA** | Field-Programmable Gate Array — a chip whose circuits can be user-configured |
| **Testbench** | A simulation file that applies test inputs to a module and checks outputs |
| **VCD** | Value Change Dump — a waveform file for viewing signals in GTKWave |
| **FIPS-197** | The official NIST publication defining the AES standard |
| **KAT** | Known Answer Test — a test using pre-verified input/output pairs |
| **XOR** | Exclusive-OR — a bitwise logic operation used extensively in AES |

---

## 9. References

1. NIST FIPS-197: *Advanced Encryption Standard (AES)*, National Institute of Standards and Technology, 2001 (Updated May 2023). https://doi.org/10.6028/NIST.FIPS.197-upd1

2. Avi Kak, *Lecture 8: AES: The Advanced Encryption Standard*, Lecture Notes on "Computer and Network Security", Purdue University, 2026.

3. Xilinx, *Zynq-7000 SoC Technical Reference Manual*, UG585, Xilinx Inc.

---

*Report prepared by Group B — Tithi, Prasanna, Shreyas*
*CDAC Project | AES-128 Decryption Core | October 2026*
