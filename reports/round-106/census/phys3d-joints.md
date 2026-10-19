# SEAT-33 CENSUS-PHYS3D-JOINTS — r106

Axes: depth (re-probe the two free-joint rows under the r105 two-state model), calibration (receipt fields vs the live tree). Coverage: no citation defect in this chunk; no mechanical edit outside this report.

Scope: default environment only. No PATH prefix, no `--godot` override. Fixture sources were not written. Unreal is not claimed: these rows are Godot headless lane fixtures.

## Result

Both rows PASS on the default environment (mise Node v26.12.0; Godot 4.7.2). Serial, one case each, `case_timeout_seconds=20`.

| Case | Battery verdict | Row | Exit | Reasons | Case elapsed | Process wall | Receipt |
|---|---|---|---|---|---:|---:|---|
| `phys3d_joints_free_pair` | PASS | PASS | 0/0 | `[]` | 2.765 s | 2.902 s | `reports/round-106/census/phys3d-joints/runs/20261018T212035512412Z/verdicts.json` |
| `phys3d_joints_free_ops` | PASS | PASS | 0/0 | `[]` | 2.774 s | 2.902 s | `reports/round-106/census/phys3d-joints/runs/20261018T212038422172Z/verdicts.json` |

Case elapsed is the runner's `elapsed_seconds` (Godot child only). Process wall is bash `date +%s.%N` around the whole `python3 corpus/fixtures/run_battery.py` invocation, including scratch copy and seed hashing. `/usr/bin/time` is absent (`shutil.which("time")` → `None`); the first attempt exited 127 before either case ran and wrote nothing.

Neither row is the historical 20 s knife-edge: both finished in under 3 s, markers matched the seeded expectation byte-for-byte (`free_pair` 1514 bytes, `free_ops` 3921 bytes), `seeds_unchanged=true`, runner rc 0, stderr empty.

## Environment (default state)

Commands run from the repo root immediately before the cases, with no PATH prefix:

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:20:17Z
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ python3 --version; command -v python3
Python 3.14.7
/usr/bin/python3
$ command -v godot; godot --version
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ git status --porcelain -- corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
(empty)
```

Reconfirmed after both runs: `node --version` still `v26.12.0` at the mise path; both seed files still those digests; porcelain still empty. The pinned fnm Node v24.21.0 was not selected. These two rows do not emit a `node=` token, so the node version is environment identity, not a marker input.

## Commands and observed output

Scratch lives under the round directory (host `/tmp` quota is exhausted; not used).

```text
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_pair --runs reports/round-106/census/phys3d-joints/runs
PASS phys3d_joints_free_pair: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../runs/20261018T212035512412Z/verdicts.json
free_pair_rc=0
WALL_SEC 2.902
stderr bytes=0

$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-106/census/phys3d-joints/runs
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../runs/20261018T212038422172Z/verdicts.json
free_ops_rc=0
WALL_SEC 2.902
stderr bytes=0
```

Wall clock of the pair: start `2026-10-18T21:20:35Z`, end `2026-10-18T21:20:41Z`. Captured stdout: `runs/free_pair.stdout`, `runs/free_ops.stdout`.

Receipt readout (parser only; did not rerun):

```text
free_pair verdict=PASS totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
  seeds_unchanged=True only=phys3d_joints_free_pair timeout=20
  godot=/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf exit=0
  started_utc=20261018T212035512412Z seed_paths=131
  runner_sha=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
  fixture_sha=80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6
  row PASS exit 0/0 reasons=[] elapsed=2.765
  MARKER_EQ_EXPECTED=True MARKER_LEN=1514
  receipt sha256=91f2bd2a0ac0f7f5a766ce8eb3c9671423605ece99279b3e5659033809627c32 bytes=17243

free_ops verdict=PASS totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
  seeds_unchanged=True only=phys3d_joints_free_ops timeout=20
  godot=/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf exit=0
  started_utc=20261018T212038422172Z seed_paths=131
  runner_sha=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
  fixture_sha=80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6
  row PASS exit 0/0 reasons=[] elapsed=2.774
  MARKER_EQ_EXPECTED=True MARKER_LEN=3921
  receipt sha256=dd6b8cda3216aa11e8e8bf9f7a7b67ebb27fec5944b8a5d13b67cb2bd4e017d8 bytes=22053
```

Godot command recorded in each receipt is `/usr/bin/godot --headless --path <that run's scratch> --script res://phys3d_joints.gd -- --arm=<free_pair|free_ops>`.

## Census note for engines.md (not edited here)

`corpus/knowledge/engines.md` is outside this seat's write set. Queue for the engines census owner, dated 2026-10-18:

Godot row remains executable-headless. Fresh default-env receipts for `phys3d_joints_free_pair` and `phys3d_joints_free_ops` are the two paths above (both `PASS battery`, `seeds_unchanged=true`, Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`). This does not move any other engine row and does not authorize an Unreal runtime claim.

## Not done

- Pinned-env (fnm Node v24.21.0) rerun of these two rows. Seat contract is default only. These markers do not depend on Node, so a pinned rerun would not be expected to change the joint result; it was not run, so it is not claimed.
- Full 350-case battery. Not this seat.
- No edits to `corpus/knowledge/engines.md`, fixtures, or rounds 101–105.
