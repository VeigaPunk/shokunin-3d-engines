#!/usr/bin/env python3
"""r104 SEAT-06 — parent-independent decisive concurrency test.

r90_child.gd is copied unchanged into both trees and the generated
project.godot string is identical, so a child is byte-identical in serial and
conc. The conc parent's workload is exactly: launch the arm's 21 child command
lines simultaneously, then read their logs.

This script does precisely that, with no parent involved, and applies the
parent's OWN projection (first n_pre M-lines, sha256[:16]) to each log. It is
the only way R3 could refute the marker: a child starved past its inner
`timeout -s KILL 20` yields rc=137 + sig11=0 -> mode_ok=0 -> different bytes.

Control: the same 21 children run 1-at-a-time. Both runs are compared against
the pinned literal's per-cell projections, extracted from run_battery.py.
"""
import hashlib
import importlib.util
import pathlib
import re
import subprocess
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
GODOT = "/usr/bin/godot"
TREE = HERE / "serial"
SCRIPT = TREE / "r90_child.gd"
OUT = HERE / "child21"
OUT.mkdir(exist_ok=True)

spec = importlib.util.spec_from_file_location("rb", TREE / "run_battery.py")
rb = importlib.util.module_from_spec(spec)
sys.modules["rb"] = rb
spec.loader.exec_module(rb)

PIN = None
for name, script, flags, exp, marker in rb.CASES:
    if name == "phys3d_joints_free_ops":
        PIN = marker
assert PIN, "no pin for phys3d_joints_free_ops"

# per-cell pinned projection: <tag>{mode_ok=N,m<n>=<sha>}
pinned = {}
for m in re.finditer(r"([a-z0-9_]+)@(gp|jolt)\{mode_ok=(\d),m(\d+)=([0-9a-f]+)\}", PIN):
    pinned[f"{m.group(1)}@{m.group(2)}"] = (int(m.group(4)), m.group(5))

# the 21 (case, backend) pairs, in the parent's own ARM_CASES x BACKENDS order
cases = rb.CASES and [c for c in
                      next(c for c in rb.CASES if c[0] == "phys3d_joints_free_ops")[2]]
arm = [f for f in cases if f.startswith("--arm=")][0][6:]
import ast
# read ARM_CASES straight out of the fixture source (no Godot needed)
src = (TREE / "phys3d_joints.gd").read_text()
block = re.search(r"const ARM_CASES := \{(.*?)\n\}", src, re.S).group(1)
arm_cases = {}
for m in re.finditer(r'"([a-z0-9_]+)": \[([^\]]*)\]', block):
    arm_cases[m.group(1)] = re.findall(r'"([^"]+)"', m.group(2))
BACKENDS = [("gp", ""), ("jolt", "Jolt Physics"), ("dummy", "Dummy")]
pairs = [(c, b) for c in arm_cases[arm] for b, _ in BACKENDS]
print(f"arm={arm} pairs={len(pairs)} pinned_cells={len(pinned)}")


def project(log: pathlib.Path, n_pre: int):
    m = [l for l in log.read_text(errors="replace").splitlines()
         if l.startswith("M0 ") or l.startswith("M ")]
    pre = m[:n_pre]
    return hashlib.sha256(" ".join(pre).encode()).hexdigest()[:16], len(m)


def run(label, concurrent):
    d = OUT / label
    d.mkdir(parents=True, exist_ok=True)
    for f in d.glob("*.log"):
        f.unlink()
    t0 = time.time()
    procs = []
    for c, b in pairs:
        proj = TREE / f"r90bt_free_ops_{c}_{b}"
        if not proj.is_dir():
            print(f"  MISSING {proj}")
            continue
        fh = open(d / f"{c}.{b}.log", "w")
        p = subprocess.Popen([GODOT, "--headless", "--path", str(proj),
                              "--script", str(SCRIPT), "--", c],
                             stdout=fh, stderr=subprocess.STDOUT)
        if concurrent:
            procs.append((p, fh))
        else:
            p.wait()
            fh.close()
    for p, fh in procs:
        p.wait()
        fh.close()
    wall = time.time() - t0
    print(f"== {label} concurrent={concurrent} wall_ms={int(wall * 1000)}")
    ok = bad = 0
    for c, b in pairs:
        tag = f"{c}@{b}"
        n_pre, want = pinned.get(tag, (0, None))
        got, nlines = project(d / f"{c}.{b}.log", n_pre)
        verdict = "ok" if (want is None or got == want) else "MISMATCH"
        if want is None:
            print(f"   {tag:24s} (no pin) msha16={got} mlines={nlines}")
            continue
        if got == want:
            ok += 1
        else:
            bad += 1
        print(f"   {tag:24s} n_pre={n_pre} msha16={got} pin={want} "
              f"mlines={nlines} {verdict}")
    print(f"   matched={ok} mismatched={bad} of {len(pinned)} pinned cells")
    return bad


if __name__ == "__main__":
    bad_serial = run("serial_control", False)
    bad_conc = run("all21_concurrent", True)
    print(f"\nRESULT serial_control mismatches={bad_serial} "
          f"all21_concurrent mismatches={bad_conc}")

# --- repeat evidence: 3 more concurrent rounds, counting mismatches ---------
total = 0
for r in range(3):
    total += run(f"conc_rep{r}", True)
print(f"\nREPEAT: 3 extra concurrent rounds, total mismatches={total}")
