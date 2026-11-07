#!/usr/bin/env bash
# Synthesize the parallel and serial INT8 designs (Yosys, iCE40) and compare the hardware.
# Results are synthesis estimates, not measurements on a board.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results

for top in dot_parallel dot_serial; do
    yosys -q -p "
        read_verilog rtl/${top}.v
        synth_ice40 -top ${top}
        tee -o results/synth_${top}.txt stat
    "
    echo "== ${top} =="
    grep -E "SB_LUT4|SB_CARRY|SB_DFF" "results/synth_${top}.txt"
done