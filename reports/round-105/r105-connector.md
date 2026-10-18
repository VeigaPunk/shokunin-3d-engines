# r105 SEAT-31 — CONNECTOR

**Axes:** depth, coverage, calibration. **Owned path:** this report only; no engine-census, fixture, environment, or pin changes.

## Finding

For the 13 `r94_cannon_*` mismatches, keep the historical observation but correct the fleet diagnosis: the default `node` selection was v26.12.0, while the stdout markers pin v24.21.0. However, v24.21.0 is already installed on this host and becomes the selected runtime when its fnm `bin` directory is prepended to `PATH`. This is a **PATH-shadowing / runtime-selection problem**, not evidence that the pinned runtime is absent or that the host must be upgraded. The older rounds correctly reported the version mismatch and missing-marker failures; “host drift” was an incomplete cause, not a false observation.

This distinction is scoped to the cannon marker class. It does not establish that the full battery passes under v24.21.0. The inspected r105 L1 receipt proves one isolated case (`r94_cannon_nan`) only. The 350/350 C2 acceptance remains a separate full-battery claim requiring its own receipt and runbook evidence.

## Evidence

1. **Current executable resolution — commands run in this seat:**

   ```sh
   node --version
   node -p 'process.execPath'
   command -v node
   PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
   PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node -p 'process.execPath'
   PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
   ```

   ```text
   default: v26.12.0
   default exec: /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
   default lookup: /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
   pinned PATH: v24.21.0
   pinned exec: /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
   pinned lookup: /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
   ```

2. **The fixture uses PATH-selected Node and places its observed version in the pinned marker.** Inspection of `corpus/fixtures/r94_cannon.gd` found `_node_version_probe()` running `/bin/sh -c "node --version"`, the child command invoking bare `node`, and the PASS marker formatting `node=%s` (source lines 125–140, 166–173). Thus the PATH prefix changes the actual child runtime selection; it does not edit the fixture or its expected marker.

3. **Pinned scope and fixture identity — commands run in this seat:**

   ```sh
   sha256sum corpus/fixtures/run_battery.py
   python3 -c 'import runpy; p=runpy.run_path("corpus/fixtures/run_battery.py"); xs=[x for x in p["CASES"] if x[0].startswith("r94_cannon_")]; print("cases",len(p["CASES"]),"r94_cannon",len(xs),"node24 markers",sum("node=v24.21.0" in x[4] for x in xs)); print("marker_node_versions",sorted({part for x in xs for part in x[4].split() if part.startswith("node=v")}))'
   ```

   ```text
   f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
   cases 350 r94_cannon 19 node24 markers 13
   marker_node_versions ['node=v24.21.0']
   ```

4. **Isolated r105 pre-probe — receipt read and summarized in this seat:**

   ```sh
   python3 -c 'import json,pathlib; p=pathlib.Path("corpus/live/runs/20261018T202715395926Z"); print("receipt_dir_exists",p.is_dir()); print("files",sorted(x.name for x in p.iterdir()) if p.is_dir() else []); [print(f.name, json.load(f.open()).get("totals",{})) for f in p.glob("*.json")]'
   ```

   ```text
   receipt_dir_exists True
   files ['scratch', 'verdicts.json']
   verdicts.json {'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
   ```

   The receipt records `only: r94_cannon_nan`, `seeds_unchanged: true`, `actual_exit: 0`, `verdict: PASS`, `elapsed_seconds: 0.859`, and the marker `PASS r94_cannon nan node=v24.21.0 …`. The round brief identifies this receipt as the run with the fnm v24.21.0 PATH prefix. It is deliberately **not** presented as a 13-row or 350-row result.

5. **Historical baseline:** `reports/round-104/physics/full-regression.md` records the default-environment full run as **337 PASS / 13 FAIL of 350**; the 13 failures were the cannon marker class. `reports/round-104/r104-verification-protocol.md` §6 further records that these rows exited 0 and failed only the exact-marker check, with `node=v24.21.0` in the marker versus default `node v26.12.0`. Those are historical full-run observations, not a full run repeated by this seat.

## Recommendation for `corpus/knowledge/engines.md`

Treat toolchain pins as **per-test runtime requirements**, and record runtime availability separately from command resolution. For Node-backed entries, report the pinned/expected version, observed version, resolved executable (`command -v` and `node -p 'process.execPath'`), and invocation/PATH used for the receipt. The current census already names Node v26.11.1 beside the three.js lockfile; keep that as the three.js evidence context rather than treating it as a universal host Node version.

When a pinned stdout marker disagrees with the default runtime, first inventory/select the pinned binary and compare a bounded case under both the default and explicit pinned PATH. Rebaseline marker literals only if the intended runtime requirement has changed and that change is authorized; do not relabel an available-but-shadowed runtime as unavailable, or “fix” the mismatch by silently editing byte-pinned fixtures. For this incident, the narrow remedy is explicit runtime selection plus a reproducible runbook; the full 350-case receipt must still demonstrate the acceptance result before claiming 350/350.
