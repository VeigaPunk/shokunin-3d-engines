#!/usr/bin/env python3
"""r104 SEAT-06 — anchor the serial/conc arms against the corpus pin.

The strongest form of "no byte changed" is not serial==conc (both could have
drifted together) but serial==conc==<the literal pinned in run_battery.py>.
This reads the CASES table out of the shipped runner and compares each arm's
own stdout PASS line against its pinned marker string, byte for byte.
"""
import hashlib
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
RUNNER = HERE / "serial" / "run_battery.py"

spec = importlib.util.spec_from_file_location("rb", RUNNER)
rb = importlib.util.module_from_spec(spec)
sys.modules["rb"] = rb
spec.loader.exec_module(rb)

pins = {}
for name, script, flags, exp, marker in rb.CASES:
    if script == "phys3d_joints.gd":
        arm = [f[6:] for f in flags if f.startswith("--arm=")]
        if arm:
            pins[name] = (arm[0], marker)

print(f"pinned phys3d_joints rows: {len(pins)}")

for name, (arm, marker) in sorted(pins.items()):
    s = (HERE / "runs" / f"{arm}.serial.stdout")
    c = (HERE / "runs" / f"{arm}.conc.stdout")
    if not s.exists() or not c.exists():
        print(f"{arm:10s} MISSING RUN")
        continue
    lines_s = [ln for ln in s.read_text().splitlines() if ln.startswith("PASS ") or ln.startswith("FAIL ")]
    lines_c = [ln for ln in c.read_text().splitlines() if ln.startswith("PASS ") or ln.startswith("FAIL ")]
    ok_s = len(lines_s) == 1 and lines_s[0] == marker
    ok_c = len(lines_c) == 1 and lines_c[0] == marker
    print(f"{arm:10s} n_serial={len(lines_s)} n_conc={len(lines_c)} "
          f"serial==pin={ok_s} conc==pin={ok_c} "
          f"sha16={hashlib.sha256(lines_s[0].encode()).hexdigest()[:16] if lines_s else '-'}")
