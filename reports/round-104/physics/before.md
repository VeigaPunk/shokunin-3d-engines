# SEAT-02 — PRE-FIX BASELINE: `phys3d_joints_free_ops` on the unpatched tree

**Seat:** SEAT-02 · **Round:** r104 · **Lane:** `game-dev-3d-shokunin`
**Owned paths written:** this file, plus run artifacts under
`reports/round-104/physics/{runs,runs-clean,standalone}` and the two captured
stdout files at `reports/round-104/physics/before-battery{,-clean}.stdout`.
**Claim served:** C1 (depth) — fix the `phys3d_joints_free_ops` wall-cost.
**Fixture edits:** none. `corpus/fixtures/**` was read only; every run below
executed the battery's own scratch copy.

**No Unreal runtime claim is made here.** Unreal Editor is not installed on this
host; this seat makes no claim about it at all.

---

## 1. Headline

On the **unpatched** tree, the row fails exactly as the r102 receipt recorded it:
killed at the 20 s per-case cap with **no exit code** and **no marker**, stdout
carrying only the engine banner. The isolated run reproduces this
**deterministically, twice, on two independent fresh scratches**.

The arm itself is correct. Uncapped, the same fixture on the same host returns
`rc=0` and a PASS marker that is **byte-identical** to the 3921-byte pin
(`sha256[:16] = 706ad9151452e18d`). So the defect is a **budget underrun**, not a
physics regression — which is the before-measurement the C1 fix must move.

---

## 2. Tree state — the tree under test is unpatched

```
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  corpus/fixtures/phys3d_joints.gd
```

Both digests equal the r102 receipt's own `seed_digests` entries for the same two
files (verified by loading `corpus/live/runs/20261018T181301123479Z/verdicts.json`):
`run_battery.py = f456bd00…` and `phys3d_joints.gd = 88be87fa…`. `git status
--porcelain -- corpus/fixtures/` is empty. The binding constant is present and
unmodified:

```
$ grep -n 'CASE_TIMEOUT_SECONDS = 20' corpus/fixtures/run_battery.py
36:CASE_TIMEOUT_SECONDS = 20
```

Host: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, `nproc` = 32.

---

## 3. The single-case flag — read from source, not assumed

`run_battery.py` has no `--case`; the selector is `--only`, comma-separated:

```
$ grep -n 'add_argument("--only"' corpus/fixtures/run_battery.py
1229:    parser.add_argument("--only", default="", help="comma-separated case names to run")
```

`--only` filters the `CASES` table and re-runs the seed-digest check over the
whole fixture dir, so the isolated invocation is the same code path as the full
battery, not a shortcut.

---

## 4. The before receipt — command and observed output

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
      --runs reports/round-104/physics/runs-clean
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
FAIL     phys3d_joints_free_ops             phys3d_joints.gd           --arm=free_ops     None/0    ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
FAIL battery: …/reports/round-104/physics/runs-clean/20261018T191758479619Z/verdicts.json
```

The receipt row, read back from the JSON:

```
$ python3 -c "import json;d=json.load(open('reports/round-104/physics/runs-clean/20261018T191758479619Z/verdicts.json'));r=d['results'][0];print({k:r[k] for k in ('verdict','actual_exit','expected_exit','error','reasons','elapsed_seconds')})"
{'verdict': 'FAIL', 'actual_exit': None, 'expected_exit': 0, 'error': 'TIMEOUT after 20 seconds',
 'reasons': ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
             'exact stdout marker missing'], 'elapsed_seconds': 20.024}
```

**stdout — the whole of it is the banner.** Nothing else reached the runner before
the kill:

```
['Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org']
```

**stderr is empty** (`[]`). `case_timeout_seconds` in the receipt is `20`;
`seeds_unchanged` is `true`.

### 4.1 Two independent reproductions, and the r102 row for scale

| run | scratch | elapsed (s) | actual_exit | error | verdict |
|---|---|---|---|---|---|
| r102 lane receipt `20261018T181301123479Z` | (lane scratch) | 20.008 | `None` | TIMEOUT after 20 seconds | FAIL |
| this seat, run A `20261018T191620117114Z` | fresh | 20.024 | `None` | TIMEOUT after 20 seconds | FAIL |
| this seat, run B `20261018T191758479619Z` | fresh | 20.024 | `None` | TIMEOUT after 20 seconds | FAIL |

All three cap within 16 ms of the 20.000 s bound. Run A and run B are separate
`--runs` roots, each with its own `scratch/`; neither reused a prior scratch.

The same lane receipt shows every **sibling** `phys3d_joints` row passing, so the
failure is specific to this arm's child count, not to `phys3d_joints.gd` as a
script:

```
PASS phys3d_joints_sweep        3.636    PASS phys3d_joints_free_pair   12.078
PASS phys3d_joints_rid          3.685    FAIL phys3d_joints_free_ops    20.008
PASS phys3d_joints_api          3.607    PASS phys3d_joints_detach       4.133
PASS phys3d_joints_chain3       5.753    PASS phys3d_joints_twopin       9.403
```

---

## 5. Where the 20 s goes — child-level evidence from the killed run

The fixture serialises children: `ARM_CASES["free_ops"]` holds **7** sub-cases and
`BACKENDS` holds **3**, and `_run()` (`corpus/fixtures/phys3d_joints.gd:83-93`)
runs each child with `OS.execute(…, blocking=true)` inside a loop, so the arm pays
**7 × 3 = 21 sequential Godot boots**.

The killed run's scratch shows exactly that, and shows where it was cut off.
Per-child log mtimes in the clean scratch (each gap = one child's full boot+work):

```
$ python3 - <<'EOF'   # mtime deltas over runs-clean/*/scratch/r90bt_free_ops_*/child.log
  0.000s  r90bt_free_ops_freeb_ops_gp        0.951s  r90bt_free_ops_freeb_world_gp
  0.848s  r90bt_free_ops_freeb_ops_jolt      0.965s  r90bt_free_ops_freeb_world_jolt
  0.943s  r90bt_free_ops_freeb_ops_dummy     0.853s  r90bt_free_ops_freeb_world_dummy
  1.851s  r90bt_free_ops_freeb_twice_gp      0.893s  r90bt_free_ops_freeb_afterclear_gp
  0.850s  r90bt_free_ops_freeb_twice_jolt    0.874s  r90bt_free_ops_freeb_afterclear_jolt
  0.856s  r90bt_free_ops_freeb_twice_dummy   0.899s  r90bt_free_ops_freeb_afterclear_dummy
  0.900s  r90bt_free_ops_freeb_make_gp       0.899s  r90bt_free_ops_freej_then_b_gp
  0.899s  r90bt_free_ops_freeb_make_jolt     0.897s  r90bt_free_ops_freej_then_b_jolt
  0.861s  r90bt_free_ops_freeb_make_dummy    0.886s  r90bt_free_ops_freej_then_b_dummy
                                             0.872s  r90bt_free_ops_detachb_free_gp
                                             0.945s  r90bt_free_ops_detachb_free_jolt
```

- **20 of 21 child logs exist; the 21st (`r90bt_free_ops_detachb_free_dummy`)
  never wrote one.** That is the kill landing mid-loop, not an error path.
- Of the 19 inter-log transitions, **17 fall in 0.85–0.97 s** — a flat ~0.9 s
  serial boot floor, matching the r103 ledger's cost model. The two exceptions
  are 1.851 s (`freeb_twice_gp`) and 0.848 s (`freeb_ops_jolt`).
- First log 16:18:00.681745 → last 16:18:18.623812 = **17.942 s of child time
  inside a 20.024 s case**, leaving ~2.1 s for parent boot + scratch copy + one
  final child.
- 21 × 0.9 s ≈ 18.9 s floor is already inside the cap's margin, so the row's
  verdict is decided by host load, not by the fixture.

---

## 6. Control — the arm is correct, the cap is the constraint

Same fixture bytes, run **without** the 20 s bound. The scratch used here is run
A's (`runs/20261018T191620117114Z/scratch`), not run B's — see §7:

```
$ D=reports/round-104/physics/runs/20261018T191620117114Z/scratch; S=$(date +%s.%N)
  timeout -s KILL 180 /usr/bin/godot --headless --path "$D" \
      --script res://phys3d_joints.gd -- --arm=free_ops \
      > reports/round-104/physics/standalone/free_ops-uncapped.stdout 2> …stderr
  RC=$?; E=$(date +%s.%N); …
RC=0 WALL=21.024
```

Captured stdout (`reports/round-104/physics/standalone/free_ops-uncapped.stdout`,
4023 bytes, 3 lines): banner, one `PASS phys3d_joints free_ops …` line, and
nothing else. **Zero `FAIL` lines**, stderr empty.

The emitted marker is byte-identical to the pin in `CASES`:

```
$ python3 - <<'EOF'   # compare standalone stdout against the pinned literal
lines: 3
PASS lines: 1
marker == pin bytes: True
sha16 standalone: 706ad9151452e18d
sha16 pin       : 706ad9151452e18d
marker len 3921 pin len 3921
FAIL lines: []
```

`706ad9151452e18d` is the same digest the r102 lane receipt's marker produces and
the same one SEAT-03's bank records for this row — the pin did not move.

**So: wall clock 21.024 s uncapped vs a 20 s cap.** The margin is ~1 s on an idle
32-core host; under any load the row tips over. This is the number the C1 fix
must push below the cap (or the cap must be raised above).

---

## 7. Disclosure — one scratch in this seat's first run was polluted by my own control

Run A's receipt is valid (written 16:16:40, before any other process touched that
tree). Its **child logs are not**, and must not be quoted as child-level evidence:

- I ran the uncapped control against run A's `scratch/` at 16:17:25–16:17:43, which
  rewrote run A's `freeb_ops_gp` child log and wrote the 21st child dir the killed
  parent never reached. In run A's scratch the `freeb_ops_gp` mtime gap reads
  44.354 s — an artifact of my control, not of the battery.
- **Run B (`runs-clean/…`) is the clean scratch** and is the one §5 draws on. It
  was created after the control and was never touched by anything but its own
  battery run.
- No seed was modified: `seeds_unchanged: true` in both receipts, and the digests
  in §2 are unchanged from r102.

This is the same reentrancy hazard the r103 ledger §5.4 recorded (the arm is not
reentrant because its children share the parent project dir). Any future re-run of
this row must use a **fresh** `--runs` root; a reused scratch can turn a D2
degraded run into what looks like a D1 timeout and vice versa.

---

## 8. What the "after" measurement must show

The pre-fix baseline, in one line each:

| quantity | before (unpatched, 20 s cap) | required after |
|---|---|---|
| `phys3d_joints_free_ops` verdict | FAIL | PASS |
| `actual_exit` | `None` | `0` |
| `error` / `reasons` | `TIMEOUT after 20 seconds` / 3 reasons | `None` / `[]` |
| `elapsed_seconds` | 20.008–20.024 (capped) | < cap, uncapped wall was 21.024 |
| stdout | engine banner only | banner + the pinned `PASS` line |
| marker sha256[:16] | (never emitted) | `706ad9151452e18d`, byte-equal to the pin |
| child count completed | 20 of 21 | 21 of 21 |
| full-battery totals | 336 pass / 350 (r102 receipt) | 337+ pass, this row among them |

Acceptance command for the after-receipt — identical to §4 except for the tree:

```
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
    --runs reports/round-104/physics/runs-after
```

and it must print `PASS phys3d_joints_free_ops: exit=0 expected=0`, `pass=1 fail=0`,
with a receipt row carrying `reasons: []`, `actual_exit: 0`, and a stdout PASS
line whose sha256[:16] is `706ad9151452e18d`. The fix must not move a byte of that
marker; SEAT-03's bank (`reports/round-104/physics/markers.md`) is the byte-level
reference for that check.

---

## 9. Scope

- Wrote: `reports/round-104/physics/before.md`,
  `reports/round-104/physics/before-battery.stdout`,
  `reports/round-104/physics/before-battery-clean.stdout`,
  `reports/round-104/physics/before-battery.stderr`,
  `reports/round-104/physics/standalone/{free_ops-uncapped.stdout,free_ops-uncapped.stderr}`,
  `reports/round-104/physics/runs/**`, `reports/round-104/physics/runs-clean/**`.
- Read only: `corpus/fixtures/**`, `corpus/live/runs/20261018T181301123479Z/verdicts.json`,
  `reports/round-103/physics/ledger.md`, `reports/round-104/physics/{markers.md,seeds.md}`.
- Did not run: any full-battery invocation. The 350-row before/after counting run is
  not this seat's; this seat's numbers are single-row.
