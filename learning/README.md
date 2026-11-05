# Learning Log

Each folder is one small step: a design and a self-checking testbench.
The path ends at the accumulator, the building block of the dot product in
[`../rtl/`](../rtl/).

| Step | Concept | What I learned |
|---|---|---|
| 01_and_gate | Module, `assign`, first testbench | A test must fail when the design is wrong |
| 02_mux | Conditional operator | Too few test cases let a wrong design pass |
| 03_full_adder | XOR, carry | Loop over all inputs, compute the expected value |
| 04_ripple_adder | Vectors, `generate`, signed numbers | Same bits, unsigned or two's complement |
| 05_d_flip_flop | Clock, reset, enable | Output changes only at the rising edge |
| 06_accumulator | Register with feedback | `acc <= acc + x`: the core of a serial MAC |
