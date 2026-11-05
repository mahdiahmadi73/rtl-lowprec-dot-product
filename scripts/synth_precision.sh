#!/usr/bin/env bash
# Synthesize dot_parallel at 8, 4 and 2 bits (Yosys, iCE40) and count the hardware.
# Results are synthesis estimates , not a real one on the fpga board.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results

for w in 8 4 2; do
    yosys -q -p "
        read_verilog rtl/dot_parallel.v
        chparam -set W $w dot_parallel
        synth_ice40 -top dot_parallel
        tee -o results/synth_W$w.txt stat
    "
    echo "== W=$w =="
    grep -E "Number of cells|SB_LUT4|SB_CARRY|SB_DFF" "results/synth_W$w.txt"
done