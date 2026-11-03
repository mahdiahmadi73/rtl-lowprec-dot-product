# Step 02: 2-to-1 multiplexer

**What:** a selector. `sel = 0` passes input `a` to `y`, `sel = 1` passes input `b`.
Written with one line using the conditional operator: `assign y = sel ? b : a;`

 self-checking testbench with PASS/FAIL messages and a waveform (`build/mux.vcd`).


