#!/usr/bin/env bash
# Generate reference vectors and simulate both designs.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build

python model/reference.py
iverilog -g2005 -o build/tb_dp.vvp rtl/dot_parallel.v tb/tb_dot_parallel.v
vvp build/tb_dp.vvp
iverilog -g2005 -o build/tb_ds.vvp rtl/dot_serial.v tb/tb_dot_serial.v
vvp build/tb_ds.vvp