# SEAT-32 CENSUS-PHYS3D-EVENTS — r106

Axes: depth (re-probe `phys3d_events_inactive_space` under the r105 two-state model), calibration (receipt fields and marker vs the live tree), coverage (command and receipt paths resolve; no corpus edit in this chunk).

Scope: one battery row, `phys3d_events_inactive_space` (`--arm=inactive_space`). Fixture sources were not written. `corpus/knowledge/engines.md` was not written. Unreal is not claimed: this row is a Godot headless lane fixture. The arm does not emit a `node=` token; Node is environment identity, not a marker input.

## Result

**PASS** in both states. Serial, one case, `case_timeout_seconds=20`. Marker matched the seeded expectation byte-for-byte (110 bytes). `seeds_unchanged=true`, runner rc 0, stderr empty, reasons `[]`.

| State | Node | Battery | Row | Exit | Case elapsed | Process wall | Receipt |
|---|---|---|---|---|---:|---:|---|
| Default PATH (mise) | v26.12.0 | PASS | PASS | 0/0 | 3.624 s | 3.742018 s | `reports/round-106/scratch/20261018T212236099489Z/verdicts.json` |
| PATH-prefixed fnm | v24.21.0 | PASS | PASS | 0/0 | 3.215 s | 3.326556 s | `reports/round-106/scratch/20261018T212646689429Z/verdicts.json` |

Case elapsed is the runner's `elapsed_seconds` (Godot child only). Process wall is `time.perf_counter` around the whole `python3 corpus/fixtures/run_battery.py` subprocess, including scratch copy, seed hashing, and `godot --version`. `/usr/bin/time` is absent (`ls /usr/bin/time` → `No such file or directory`; `command -v time` resolves the shell keyword). The first attempt, which wrapped the battery in `/usr/bin/time`, exited 127 before Godot ran and is not a result.

Neither measurement is the historical r105 pinned full-battery figure. That receipt (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`) records this same case `verdict=PASS`, `elapsed_seconds=3.905`, marker identical. Dated note, 2026-10-18: 3.905 s is that full-battery child, not this seat's isolated wall. This seat does not rewrite it. Both fresh runs finished under 4 s, inside the 20 s bound.

Expected marker, from `corpus/fixtures/run_battery.py` and both receipts:

```text
PASS phys3d_events inactive_space plain=open thr=phase jolt_thr=phase alts=answered sig=wall_only child_exit=0
```

## Environment

Commands run from the repo root. Default probe had no PATH prefix. Pinned probe prepended the fnm bin for that process only.

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:22:23Z
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ python3 --version; command -v python3
Python 3.14.7
/usr/bin/python3
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_events.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
df1cde494cce9575dee78a25259f24cebb7e8523bb32d166d4196f9ad23ec6de  corpus/fixtures/phys3d_events.gd
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ git status --porcelain -- corpus/fixtures/run_battery.py corpus/fixtures/phys3d_events.gd
(empty)
```

Pinned selection, command-scoped, before the second run:

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
node_path=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Reconfirmed after both runs: default `node --version` still `v26.12.0` at the mise path; both seed digests unchanged; porcelain on those two files still empty. Runner sha matches the r105 pin `f456bd00…`.

## Commands and observed output

Scratch is under `reports/round-106/scratch/` (host note: do not use `/tmp`). `--runs` points the runner there so seeds stay read-only.

Failed clock attempt (not a battery result):

```text
$ /usr/bin/time -f '...' python3 corpus/fixtures/run_battery.py --only phys3d_events_inactive_space --runs reports/round-106/scratch
/bin/bash: line 13: /usr/bin/time: No such file or directory
battery_rc=127
```

Receipt of that miss: `reports/round-106/scratch/seat32-failed-time/stdout.txt`.

Default state:

```text
$ python3 corpus/fixtures/run_battery.py --only phys3d_events_inactive_space --runs reports/round-106/scratch
PASS phys3d_events_inactive_space: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../scratch/20261018T212236099489Z/verdicts.json
battery_rc=0
wall_seconds=3.742018
perf_counter_start_utc=2026-10-18T21:22:36.069326Z
perf_counter_end_utc=2026-10-18T21:22:39.811347Z
```

Pinned state (same command, PATH prefix only):

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only phys3d_events_inactive_space --runs reports/round-106/scratch
PASS phys3d_events_inactive_space: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../scratch/20261018T212646689429Z/verdicts.json
battery_rc=0
wall_seconds=3.326556
node=v24.21.0
perf_counter_start_utc=2026-10-18T21:26:46.661823Z
perf_counter_end_utc=2026-10-18T21:26:49.988381Z
```

Wrapper stdout/meta sit beside each receipt (`wrapper.stdout`, `wrapper.meta.txt`).

Receipt readout (parser only; did not rerun):

```text
default verdict=PASS totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
  seeds_unchanged=True only=phys3d_events_inactive_space timeout=20
  godot=/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf godot_version_exit=0
  started_utc=20261018T212236099489Z
  row PASS exit 0/0 reasons=[] elapsed=3.624 error=None
  MARKER_EQ_EXPECTED=True MARKER_LEN=110
  stdout ends with the marker; stderr=[]
  receipt sha256=3be7f3a8f99f6ee4096b4721ce7f9b8849ba1f649b9c6b50e3a9c02b6ff0e441 bytes=14419

pinned verdict=PASS totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
  seeds_unchanged=True only=phys3d_events_inactive_space timeout=20
  godot=/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf godot_version_exit=0
  started_utc=20261018T212646689429Z
  row PASS exit 0/0 reasons=[] elapsed=3.215 error=None
  MARKER_EQ_EXPECTED=True MARKER_LEN=110
  stdout ends with the marker; stderr=[]
  receipt sha256=7c72bc0783f9620261fa63cde21e60444aa8038ec7ef726d9e7cc020becde244 bytes=14419
```

Godot command recorded in each receipt: `/usr/bin/godot --headless --path <that run's scratch> --script res://phys3d_events.gd -- --arm=inactive_space`.

## Child-log witness (both runs)

The parent marker is not the only line. Each run's generated children printed the same split. Count of `Space state is inaccessible` in `child.log`, plus the `CHILD_NOTE` / `CHILD_RESULT` lines:

| Child | Backend | open | refused | inaccessible lines | sig |
|---|---|---:|---:|---:|---|
| `iaplainproj` | DEFAULT | 5 | 0 | 0 | `pt1,is1,ray7,cs0,cmfrac,ri0,rv6` |
| `iathrproj` | DEFAULT | 2 | 3 | 3 | same |
| `iajoltthrproj` | Jolt Physics | 2 | 3 | 3 | same |

`alts=2/2` and `f_bp=1/1` on all three. Identical on the default run and the pinned run. That is the gate-on-step-cycle claim the marker compresses (`plain=open thr=phase jolt_thr=phase alts=answered sig=wall_only`).

## Census note for engines.md (not edited here)

`corpus/knowledge/engines.md` is outside this seat's write set. Queue for the engines census owner, dated 2026-10-18:

Godot row remains executable-headless. Fresh receipts for `phys3d_events_inactive_space` are the two paths above (both `PASS battery`, `seeds_unchanged=true`, Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`). Default process wall 3.742018 s; pinned process wall 3.326556 s. This does not move any other engine row and does not authorize an Unreal runtime claim.

## Not done

- Full 350-case battery. Not this seat.
- No mechanical edit to fixtures, lessons, or `engines.md`. No citation defect found in this chunk: the README arm description (`open=5` / `open=2 refused=3` / that sig) matches both child logs, and fixtures README is SEAT-17's write set.
- No judgment defect queued.
