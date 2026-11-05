#Golden model and test vector generator for the INT8 dot product.
import argparse
from pathlib import Path

import numpy as np

N = 4                                       # vector length
W = 8                                       # bits per element (signed)
ACCW = 2 * W + int(np.ceil(np.log2(N)))     # result width: 18 bits for N = 4
NVEC = 1024                                 # number of test vectors
LO, HI = -(2 ** (W - 1)), 2 ** (W - 1) - 1  # -128 .. 127


def dot(a, w):
    """The reference answer, in exact integer arithmetic."""
    return int(np.dot(np.asarray(a, dtype=np.int64), np.asarray(w, dtype=np.int64)))


def pack(vec, width=W):
    """Put a vector into one integer: element i goes to bits [i*width +: width]."""
    word = 0
    for i, v in enumerate(vec):
        word |= (int(v) & ((1 << width) - 1)) << (i * width)
    return word


def to_twos(value, width):
    """Two's complement bit pattern of a signed value."""
    assert -(1 << (width - 1)) <= value < (1 << (width - 1)), f"{value} does not fit in {width} bits"
    return value & ((1 << width) - 1)


def corner_cases():
    """Hand-picked vectors at the edges of the INT8 range."""
    z = [0] * N
    cases = [
        (z, z),                                  # all zero
        ([HI] * N, [HI] * N),                    # 127 * 127
        ([LO] * N, [LO] * N),                    # -128 * -128: largest result, +65536
        ([LO] * N, [HI] * N),                    # most negative result, -65024
        ([1] * N, [-1] * N),                     # small signed values
        ([-1] * N, [-1] * N),                    # -1 is all ones in binary
        ([LO, HI, LO, HI], [HI, LO, HI, LO]),    # alternating extremes
    ]
    for i in range(N):                           # one-hot: only element i is non-zero
        a = [0] * N; a[i] = LO
        w = [0] * N; w[i] = LO
        cases.append((a, w))
    return cases


def make_vectors(nvec=NVEC, seed=0):
    rng = np.random.default_rng(seed)
    cases = corner_cases()
    while len(cases) < nvec:
        a = rng.integers(LO, HI + 1, size=N).tolist()
        w = rng.integers(LO, HI + 1, size=N).tolist()
        cases.append((a, w))
    return cases


def write_hex(cases, outdir):
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    with open(outdir / "vec_a.hex", "w") as fa, \
         open(outdir / "vec_w.hex", "w") as fw, \
         open(outdir / "vec_exp.hex", "w") as fe:
        for a, w in cases:
            fa.write(f"{pack(a):08x}\n")
            fw.write(f"{pack(w):08x}\n")
            fe.write(f"{to_twos(dot(a, w), ACCW):05x}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="build")
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args()

    cases = make_vectors(seed=args.seed)
    write_hex(cases, args.out)
    results = [dot(a, w) for a, w in cases]
    print(f"wrote {len(cases)} vectors (N={N}, W={W}, ACCW={ACCW}) to {args.out}/")
    print(f"result range: {min(results)} .. {max(results)}")