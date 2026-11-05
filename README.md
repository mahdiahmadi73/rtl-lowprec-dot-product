# Low-Precision Dot Product in RTL

An INT8 dot product in Verilog, the core operation of neural-network inference,
checked bit-exactly against a Python reference model.

## Result

- `rtl/dot_parallel.v` computes `a0·w0 + a1·w1 + a2·w2 + a3·w3` for signed INT8
  values in one clock cycle, with an 18-bit result.
- All 1024 test vectors match the reference model, including the corner cases
  (−128 × −128, mixed extremes, −1).
- Latency 1 cycle, throughput 1 result per cycle (simulation).

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

## Run

```
python model/reference.py
iverilog -g2005 -o build/tb_dp.vvp rtl/dot_parallel.v tb/tb_dot_parallel.v
vvp build/tb_dp.vvp
scripts/synth_precision.sh
```

Needs Icarus Verilog, Yosys and Python with NumPy.

## Structure

- `learning/` six small steps from an AND gate to an accumulator, each with a self-checking testbench
- `model/reference.py` reference model and test vectors
- `rtl/` designs
- `tb/` testbenches

## Next

- Serial version: one multiplier reused over four cycles, to compare speed with hardware cost
- Ternary weights (−1, 0, +1): the multiplication becomes add, subtract or skip
- Bit-flip sensitivity: how much one flipped weight bit changes the result

Results are from simulation only, not from FPGA measurements.

Mahdi Ahmadi
