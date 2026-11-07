# Low-Precision Dot Product in RTL

**How much hardware does precision cost?** An INT8 dot product in Verilog, the
core operation of neural-network inference, verified bit-exactly against a Python
reference model on 1024 test vectors, then synthesized at 8, 4 and 2 bits.
Each halving of the bit width cuts the logic by about 4× (883 → 224 → 55 LUTs).

## Result

- `rtl/dot_parallel.v` computes `a0·w0 + a1·w1 + a2·w2 + a3·w3` for signed INT8
  values in one clock cycle, with an 18-bit result.
- All 1024 test vectors match the reference model, including the corner cases
  (−128 × −128, mixed extremes, −1).
- Latency 1 cycle, throughput 1 result per cycle (simulation).
- `rtl/dot_serial.v` reuses one multiplier over four cycles: 5 cycles per result,
  all 1024 vectors match as well.

Why 18 bits: one product needs 16 bits (−128 × −128 = 16384), and adding four
products needs 2 more, so the sum can never overflow.

## Hardware cost vs precision

The same design synthesized at 8, 4 and 2 bits per element
(`scripts/synth_precision.sh`, Yosys for a Lattice iCE40, LUT-only):

| Precision | LUTs | Carry cells | Flip-flops |
|---|---:|---:|---:|
| INT8 | 883 | 14 | 19 |
| INT4 | 224 | 9 | 11 |
| INT2 | 55 | 4 | 7 |

Halving the bit width cuts the logic by about 4×, because a multiplier grows
with the square of its width. The flip-flops only hold the result, so they
shrink linearly (18, 10 and 6 bits plus a valid flag). These are synthesis
estimates, not board measurements.

## Parallel vs serial

The same INT8 dot product built two ways (`scripts/synth_compare.sh`, same Yosys flow):

| Design | Multipliers | Cycles per result | LUTs | Flip-flops |
|---|---:|---:|---:|---:|
| `dot_parallel` | 4 | 1 | 883 | 19 |
| `dot_serial` | 1 | 5 | 316 | 40 |

The serial design needs 2.8× fewer LUTs but is 5× slower, so it uses more
hardware per result (316 × 5 vs 883 × 1). It saves area, not efficiency.
It reads one activation and one weight per cycle instead of four of each,
and needs more flip-flops for its accumulator, counter and control.

## Run

```
python model/reference.py
iverilog -g2005 -o build/tb_dp.vvp rtl/dot_parallel.v tb/tb_dot_parallel.v
vvp build/tb_dp.vvp
iverilog -g2005 -o build/tb_ds.vvp rtl/dot_serial.v tb/tb_dot_serial.v
vvp build/tb_ds.vvp
scripts/synth_precision.sh
scripts/synth_compare.sh
```

Needs Icarus Verilog, Yosys and Python with NumPy.

## Structure

- `learning/` six small steps from an AND gate to an accumulator, each with a self-checking testbench
- `model/reference.py` reference model and test vectors
- `rtl/` designs
- `tb/` testbenches

## Next

- Ternary weights (−1, 0, +1): the multiplication becomes add, subtract or skip
- Bit-flip sensitivity: how much one flipped weight bit changes the result

Results are from simulation only, not from FPGA measurements.

Mahdi Ahmadi
