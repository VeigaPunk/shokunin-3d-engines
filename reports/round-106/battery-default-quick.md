# SEAT-87 BATTERY-DEFAULT-QUICK — r106

Axes: two-state fidelity (default PATH must still fail a positive cannon row on the Node token, and `phys3d_joints_free_ops` must still pass on that same PATH), evidence (commands actually run, receipts hashed), coverage (spot check only — not a 350-row recount).

Scope: one representative positive cannon row plus `phys3d_joints_free_ops --only`, both under the host default PATH. No pinned-env run (that is SEAT-88). No fixture edits. HEAD at run time `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

## Verdict

| Probe | Env | Expected class | Observed | Match |
|---|---|---|---|---|
| `r94_cannon_nan` | default PATH, Node v26.12.0 | FAIL class (exit 0, `exact stdout marker missing`, token `v26.12.0` vs pin `v24.21.0`) | battery exit 1; row FAIL; `seeds_unchanged=true` | yes |
| `phys3d_joints_free_ops` | same default PATH | PASS | battery exit 0; row PASS; marker byte-exact; `seeds_unchanged=true` | yes |

The two-state spot check on this tree holds: the default environment still fails a positive cannon row only on the Node version token, and the physics free-ops row still passes under that same environment. This is not a 337/350 recount.

## Environment actually observed

```text
$ date -Is; git rev-parse HEAD; command -v node; node --version; /usr/bin/godot --version | head -1; sha256sum corpus/fixtures/run_battery.py
2026-10-18T18:20:22-03:00
0cc3f4162f8c319f8d01a69a174fe939f36701bd
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0
4.7.2.stable.arch_linux.ed1daf0bf
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

`type -a node` (first five): mise `latest/bin/node`, mise shim, then three `/run/user/1000/fnm_multishells/.../bin/node` entries. The pinned binary is present but not first:

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Python `/usr/bin/python3` 3.14.7. Scratch was under `reports/round-106/scratch/` (a 4KiB write there succeeded). `/tmp` was not used.

## Commands run

Cannon row (default PATH, no prefix):

```text
$ python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs reports/round-106/scratch/seat87/runs-default-20261018T212029Z
FAIL r94_cannon_nan: exit=0 expected=0 reasons=['exact stdout marker missing']

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
FAIL     r94_cannon_nan                     r94_cannon.gd              --arm=nan          0/0       ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
FAIL battery: .../runs-default-20261018T212029Z/20261018T212029481284Z/verdicts.json
battery_exit=1
```

stderr of that invocation was empty (0 bytes). Wall clock of the Godot child, from the receipt: 0.876 s. `error=None`.

free_ops row (same default PATH, separate invocation):

```text
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-106/scratch/seat87/runs-freeops-20261018T212030Z
PASS phys3d_joints_free_ops: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     phys3d_joints_free_ops             phys3d_joints.gd           --arm=free_ops     0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../runs-freeops-20261018T212030Z/20261018T212030605458Z/verdicts.json
battery_exit=0
```

stderr empty (0 bytes). Child elapsed 3.045 s. `error=None`. `reasons=[]`.

## Receipt readout

Parser (did not rerun the battery):

```text
$ python3 -c "… load each verdicts.json; print verdict, seeds_unchanged, totals, case, exits, reasons, node tokens …"
CANNON verdict=FAIL seeds_unchanged=True totals={'cases': 1, 'pass': 0, 'fail': 1, 'ordinary': 1, 'negative_controls': 0}
only=r94_cannon_nan godot_version=4.7.2.stable.arch_linux.ed1daf0bf started_utc=20261018T212029481284Z
run_battery_sha=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f n_seed_digests=131 PINNED-ENV.md_in_map=True
case=r94_cannon_nan verdict=FAIL expected_exit=0 actual_exit=0 reasons=['exact stdout marker missing'] elapsed=0.876 error=None
expected_node=v24.21.0 observed_node=v26.12.0
FREEOPS verdict=PASS seeds_unchanged=True totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
only=phys3d_joints_free_ops started_utc=20261018T212030605458Z
same run_battery_sha n_seed_digests=131 PINNED-ENV.md_in_map=True
case=phys3d_joints_free_ops verdict=PASS expected_exit=0 actual_exit=0 reasons=[] elapsed=3.045 error=None
```

Token isolation (same parser session): replacing `node=v24.21.0` in the expected cannon marker and `node=v26.12.0` in the observed stdout line with one placeholder made the two 2546-byte strings equal (`marker_equal_after_node_swap=True`). The FAIL is the Node token only, not a payload drift. free_ops observed stdout equalled the pinned marker exactly (`freeops_marker_exact=True`, 3921 bytes).

## Durable copies and hashes

Runner scratch (full Godot project copies) stays under `reports/round-106/scratch/seat87/`. The receipts copied beside this report:

| File | SHA-256 |
|---|---|
| `reports/round-106/battery-default-quick-receipts/cannon-default-verdicts.json` | `4bb5094233c6a61a6fb9b9d0ef89198475ebf49f84a9bad5513f786d088b3ce2` |
| `reports/round-106/battery-default-quick-receipts/default-cannon-20261018T212029Z.stdout` | `d1acd80133ba17174b290d0934f3d96076c2b1189ca943f51fa9e854a0aec3be` |
| `reports/round-106/battery-default-quick-receipts/freeops-default-verdicts.json` | `65016de381f05535e3b57dd653ad2ef4c794c5857b0f020d86e71bd30809d795` |
| `reports/round-106/battery-default-quick-receipts/freeops-20261018T212030Z.stdout` | `b7507f90eed742f54e19153d01d97c6c7ceb421cbac790db6a3045eea57aa938` |

`cmp` of each copied `verdicts.json` against the runner path was equal. `sha256sum` of the four files above plus the two env sidecars is in `reports/round-106/battery-default-quick-receipts/SHA256SUMS`.

## What this does not claim

- Not a full battery. One of 13 positive cannon rows, plus one ordinary physics row. The other 12 positive cannon rows were not executed here.
- Not a pinned-env PASS. The fnm v24.21.0 binary was only version-probed, not used to run a case.
- Not a seed-tree mutation. Both receipts have `seeds_unchanged=true` and include `PINNED-ENV.md` in the 131-path pre-map (the r105 pinned full run's map had 130 and excluded that doc). `git status --short -- corpus/fixtures` after both runs was empty. `run_battery.py` sha remained `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`.
- No Unreal runtime claim. Godot used: `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf.

## Blockers

None for this seat. The expected FAIL class and the expected PASS both landed.
