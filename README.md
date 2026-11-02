# Low-Precision Dot Product in RTL: Serial vs Parallel

A small hardware project comparing two architectures for a low-precision
(int8, and later ternary) dot product, the core operation of neural-network
inference on edge hardware.

> Status: work in progress. Sections marked *TODO* are filled in as the
> project develops. The step-by-step learning record is in
> [`learning/`](learning/README.md).

## Goal
- Implement a dot product in two RTL architectures:
  - **Parallel:** all multiply-accumulates at once (combinational core in a registered wrapper).
  - **Serial:** one multiply-accumulate per clock cycle (counter, accumulator, done flag).
- Verify both against a Python golden model.
- Compare cycle latency, throughput, data supply per cycle and synthesis resources.
- Study bit-flip sensitivity of the computation (int8 vs ternary).

## Architecture
*TODO*

## Results
*TODO*

All cycle counts come from simulation. Resource figures are synthesis
estimates (Yosys / nextpnr for the iCE40 target), not measurements on a board.
No frequency, power or energy measurements are claimed.

## How to run
*TODO*

## Tools
- Icarus Verilog (simulation), GTKWave (waveforms)
- Yosys (synthesis), nextpnr-ice40 (place and route estimates)
- Python 3 with NumPy, pytest, Matplotlib (golden model, tests, analysis)

Installed via [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build).

## Repository layout
| Folder | Contents |
|---|---|
| `learning/` | Fundamentals, one step per folder (gates, mux, adders, counter) |
| `rtl/` | Final designs |
| `tb/` | Verilog testbenches |
| `model/` | Python golden model, test-vector generation, comparison, bit-flip analysis |
| `tests/` | Python tests of the golden model and analysis |
| `synth/` | Synthesis scripts |
| `scripts/` | Reproducible simulation and synthesis commands |
| `results/` | Final summary tables and charts |
| `build/` | Generated files (not committed) |

## Author
Mahdi Ahmadi
