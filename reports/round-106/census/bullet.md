# SEAT-29 CENSUS-BULLET — r95 bullet rows, default env

Axes: **depth** (20 `r95_bullet_*` rows re-run, not inherited from r104/r105), **coverage** (receipt path resolvable; markers match the r105 pinned receipt), **calibration** (default-env pins recorded; Node is not in this contract; no `engines.md` cell to move).

Result: **PASS**. 20/20, `seeds_unchanged=true`, runner exit 0. This is the r95 bullet lattice (14 ordinary + 6 negative controls), not a 350-case battery and not a new `engines.md` row.

## Environment (two-state; default used)

| State | Resolution | This run |
|---|---|---|
| default (used) | mise Node; system Python; `/usr/bin/godot` | no `PATH` prefix |
| pinned (present, not selected) | fnm Node `v24.21.0` at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin` | queried by absolute path only |

Observed before the battery, 2026-10-18T21:26:55Z, HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```text
node_version=v26.12.0
node_path=/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
node_real=/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
sha256 node_real=caa24debe02770c92a70677e2a62ca98890150e7ac1c17bcfe31bcc98cc89943
python_path=/usr/bin/python3
python_version=Python 3.14.7
godot_path=/usr/bin/godot
godot_version=4.7.2.stable.arch_linux.ed1daf0bf
pinned node absolute --version → v24.21.0
```

After the run (same log): `node_version=v26.12.0`, same mise path. No mise/fnm config written. `git status --short -- corpus/fixtures` printed nothing.

Separate identity hashes (not inside the battery log):

```text
$ sha256sum /usr/bin/python3 /usr/bin/godot
d78f9cf7178ecff09963551399855543c297f37ac207e626228bfe43cb26a70c  /usr/bin/python3
3a72f85d53b84d7656ad8a633b06b019a11ad170a5718ff50bacc1c83cd4e72b  /usr/bin/godot
```

Bullet contract pins, from `sha256sum` in the same pre-run block:

| File | SHA-256 |
|---|---|
| `corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` |
| `corpus/fixtures/r95_bullet.gd` | `f988ba86fdef62a03a59c91e000a94288a4610f9ef9c92c5e56db967515f1447` |
| `corpus/fixtures/r95_child.py` | `8821ebd50459dd1371a6484a68abc79e0decb8aa50a8c416636f644baddf5b6b` |
| `corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` | `eca749a0d9b53964dca06764300c3481f328dc4cd1499a60e287393972be3693` |

The runner's saved `seed_digests` repeats those four hashes (`run_battery.py`, `r95_bullet.gd`, `r95_child.py`, `r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so`) across 131 seed files.

Node is recorded because the r105 two-state model asks for it. No `r95_bullet_*` expected marker contains `node=`. The 14 ordinary markers pin `engine=pybullet-3.2.7`, `api=202010061`, `py=3.14.7`, `build="Oct 15 2026 03:47:36"`. The 6 negative markers pin `NEGATIVE REJECTED:` lines and do not embed that M0 header. The child is `/usr/bin/python3` plus the vendored `.so`, not `PATH` `python3` and not Node.

System module check (not a battery row):

```text
$ /usr/bin/python3 -c 'import pybullet'
ModuleNotFoundError: No module named 'pybullet'
```

Vendored import (same interpreter, `sys.path` insert of `corpus/fixtures/r95vendor` only) printed `pybullet build time: Oct 15 2026 03:47:36`, `__file__` the `.so` above, `getAPIVersion()` `202010061`. That matches the ordinary markers. It is identity, not the PASS receipt. No `__pycache__` was left under `r95vendor`.

## Command

From the repository root. Scratch is under `reports/round-106/scratch/seat29` because `/tmp` per-user quota is exhausted. The runner copies the fixture tree into that scratch; that copy is not a fixture edit. `--only` is the full `r95_bullet_*` set (20 `CASES` rows), not one arm.

```sh
python3 corpus/fixtures/run_battery.py \
  --only r95_bullet_det,r95_bullet_freeze,r95_bullet_rt,r95_bullet_shm,r95_bullet_sleep,r95_bullet_sleep2,r95_bullet_nan,r95_bullet_nan2,r95_bullet_fric,r95_bullet_rest,r95_bullet_knobs,r95_bullet_solver,r95_bullet_pile,r95_bullet_misc,r95_bullet_neg_dt,r95_bullet_neg_order,r95_bullet_neg_radius,r95_bullet_neg_simtime,r95_bullet_neg_badid,r95_bullet_neg_shm_rt \
  --runs reports/round-106/scratch/seat29
```

## Observed terminal

Transcript: `reports/round-106/census/bullet-run-20261018T212655Z.log` (69 lines, 4544 bytes, SHA-256 `03f973c8e177287c607261593087e5515587d841b23e4ddb5029e7fb154904ed`).

```text
totals: cases=20 pass=20 fail=0 ordinary=14 negative_controls=6 probes=0
PASS battery: .../reports/round-106/scratch/seat29/20261018T212655497155Z/verdicts.json
COMMAND_EXIT=0
```

Every row printed `PASS` with empty `reasons` and empty stderr. Case elapsed sum 27.569 s (min 0.518, max 4.135). `case_timeout_seconds=20`. No row approached the cap.

| Case | Kind | Exit | Elapsed s |
|---|---|---:|---:|
| `r95_bullet_det` | ordinary | 0/0 | 2.002 |
| `r95_bullet_freeze` | ordinary | 0/0 | 0.898 |
| `r95_bullet_rt` | ordinary | 0/0 | 4.135 |
| `r95_bullet_shm` | ordinary | 0/0 | 3.154 |
| `r95_bullet_sleep` | ordinary | 0/0 | 1.037 |
| `r95_bullet_sleep2` | ordinary | 0/0 | 1.075 |
| `r95_bullet_nan` | ordinary | 0/0 | 1.046 |
| `r95_bullet_nan2` | ordinary | 0/0 | 0.940 |
| `r95_bullet_fric` | ordinary | 0/0 | 1.145 |
| `r95_bullet_rest` | ordinary | 0/0 | 0.725 |
| `r95_bullet_knobs` | ordinary | 0/0 | 0.930 |
| `r95_bullet_solver` | ordinary | 0/0 | 0.918 |
| `r95_bullet_pile` | ordinary | 0/0 | 1.299 |
| `r95_bullet_misc` | ordinary | 0/0 | 0.919 |
| `r95_bullet_neg_dt` | negative | 2/2 | 0.940 |
| `r95_bullet_neg_order` | negative | 2/2 | 0.695 |
| `r95_bullet_neg_radius` | negative | 2/2 | 0.737 |
| `r95_bullet_neg_simtime` | negative | 2/2 | 0.518 |
| `r95_bullet_neg_badid` | negative | 2/2 | 0.610 |
| `r95_bullet_neg_shm_rt` | negative | 2/2 | 3.846 |

## Verdict JSON

Durable copy, byte-identical to the runner file (`sha256sum` both `4a99ad94e5a7424e13b9324019cbf1c88d10614954ec37027315b860a280743b`, 70037 bytes):

`reports/round-106/census/bullet-r95-20261018T212655Z.verdicts.json`

Runner original: `reports/round-106/scratch/seat29/20261018T212655497155Z/verdicts.json`

| Field | Observed |
|---|---|
| `verdict` | `PASS` |
| `started_utc` | `20261018T212655497155Z` |
| `godot` | `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, version exit 0 |
| `totals` | cases=20 pass=20 fail=0 ordinary=14 negative_controls=6 |
| `seeds_unchanged` | true (131 digests) |
| `only` | the 20 names above |
| probes | all false / not run |

Marker strings equal the matching rows in `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` (20/20, same PASS and exit). That r105 file is the pinned-Node full battery (350/350). This r106 file does not replace it. Default-env 337/350 remains the r104 full-battery figure; this seat did not re-run the other 330 rows.

## engines.md

Not edited by this seat. SEAT-38 owns `corpus/knowledge/engines.md`.

First read, before the battery (16 lines, SHA-256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`): rows Godot 4.7.2 / Unity Editor / Unreal Engine / three.js 0.186.1. No `bullet` or `pybullet` token. That hash is the pre-r106 bytes (the stamp SEAT-38 later recorded as still sitting in protected `SKILL.md`).

> **Correction note (r106, 2026-10-18, same seat, after the report draft).** A later `sha256sum corpus/knowledge/engines.md` returned `501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933` (166 lines, 15463 bytes). `git diff --stat` had already shown a SEAT-38 rewrite (`+110/-4` at an intermediate frame; the file was still growing). Table rows at this second read: Godot 4.7.2, Unity Editor, Unreal Engine, three.js 0.186.1, Blender 5.2.1 LTS. No pybullet table row (`has_pybullet_row False`). The file cites this report (20/20 `r95_bullet_*` PASS, marker `engine=pybullet-3.2.7`, no new row). This seat did not write those lines. Do not treat `d03907d3…` as the live file hash after that rewrite.

This receipt does not move the Godot / Unity / Unreal / three.js cells. It does not authorize a pybullet row: system `/usr/bin/python3 -c 'import pybullet'` raised `ModuleNotFoundError`; the PASS is the vendored r95 `.so` under a Godot fixture. Same class as cannon-es, which is also not its own engines row.

## What this does not claim

- Not a full battery. Not a Node-version result. Not a system Bullet or pybullet install.
- Not an Unreal runtime claim. `command -v UnrealEditor` found nothing. Editor is not installed.
- Not a Unity import or editor run.
- Godot here is process transport for the Python child. Pinned physics values are pybullet evidence, as r95 authored them.
