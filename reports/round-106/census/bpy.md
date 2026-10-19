# SEAT-36 CENSUS-BPY — r106

Axes: **depth** (`blender -b -P` re-probed this seat, both Node PATH states, receipts saved), **coverage** (bpy battery presence counted, not inherited; engines.md gap named), **calibration** (version pin `5.2.1 LTS` / build `9e2066aef7ef` checked against this probe; no engines.md rewrite).

Result: **installed, background launch works, battery not run.** `/usr/bin/blender` is Blender **5.2.1 LTS**, build hash **9e2066aef7ef**, pacman `17:5.2.1-2`. `blender -b -P` imports `bpy` (rc 0) under both the default mise Node PATH and the pinned fnm Node PATH. The two import stdouts are byte-identical. This seat did **not** run `bpy_battery.py` and did **not** run the 10 `bpy_rbw3d_*` Godot-battery rows.

No `engines.md` edit (outside this seat's chunk). No fixture code written. No Unreal runtime claim — `command -v UnrealEditor` and `command -v UnrealEditor-Cmd` both exited 1 (`reports/round-106/census/bpy/host-probe.txt`).

HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Probe window for the saved receipts: `2026-10-18T21:31:39Z`. `TMPDIR` was `reports/round-106/scratch/seat36` (host `/tmp` quota is exhausted). Scratch is not the receipt; the files under `reports/round-106/census/bpy/` are.

## Verdict

| cell | this seat | engines.md |
|---|---|---|
| installed | **yes** — `/usr/bin/blender`, pacman `blender 17:5.2.1-2` | **no row** at probe time and still no row at report close |
| `blender -b -P` import | **yes, both PATH states**, rc 0, stderr 0 bytes, stdouts identical | not stated |
| executable-headless promotion | **not promoted** — import probe only; `bpy_battery.py` not executed | row absent, so nothing to promote |
| node two-state | **does not select Blender** — both states resolve `/usr/bin/blender`; bundled Python `3.14.7` either way | n/a (the r106 two-state section does not mention Blender) |

> **Correction note (r106, 2026-10-18) — `engines.md` identity moved during this seat.** At the probe (`2026-10-18T21:31:39Z`) `sha256sum corpus/knowledge/engines.md` was `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`, 2768 bytes, mtime `2026-10-18 14:42:49.295040755 -0300`, and `git status --porcelain -- corpus/knowledge/engines.md` was empty. A case-insensitive `rg` of that bytes for `blender|bpy` was not re-run on the old bytes after they were replaced; the pre-edit read of the file (16 lines, four tooling rows) contained no Blender row. At report close the worktree file is a concurrent edit (Godot evidence cell cites `reports/round-106/scratch/seat38`), sha256 `149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba`, 11555 bytes, mtime `2026-10-18 18:44:28.659390607 -0300`. `rg -n -i 'blender|bpy' corpus/knowledge/engines.md` on those bytes exited 1 (no matches). This seat did not write that file. Re-hash before citing it if the engines owner writes again.

## Probe (saved)

Script: `reports/round-106/census/bpy/census_probe.py`, sha256 `95a78da7f70c7b50c8ba89b00598d1a055abe4aa529b1c0a901351b25069489d`. It imports `bpy` and prints `bpy.app.version`, `version_string`, `build_hash`, `background`, `binary_path`, and `sys.version`. It does not load `bpy_sync_probe.py` and does not render.

From the repo root, default PATH (mise node `v26.12.0` on `PATH`, not used by Blender):

```text
$ /usr/bin/timeout -s KILL 40 blender -b -P reports/round-106/census/bpy/census_probe.py -- --census
CENSUS_IMPORT_START
bpy.app.version 5.2.1
bpy.app.version_string 5.2.1 LTS
bpy.app.build_hash 9e2066aef7ef
bpy.app.background True
bpy.app.binary_path /usr/bin/blender
python 3.14.7
CENSUS_IMPORT_OK
Blender 5.2.1 LTS (hash 9e2066aef7ef built 2026-09-01 00:24:57)

Blender quit
default_probe_rc=0
```

Pinned PATH, same script, command-scoped only:

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" /usr/bin/timeout -s KILL 40 blender -b -P reports/round-106/census/bpy/census_probe.py -- --census
pinned_probe_rc=0
$ diff -u reports/round-106/census/bpy/bpy-import-default.stdout reports/round-106/census/bpy/bpy-import-pinned.stdout
diff_rc=0
```

Receipts: `bpy-import-default.stdout` and `bpy-import-pinned.stdout` share sha256 `d2178ffadbf86939de18c09a0107b4cb7d3d885523df840ed4fc54da0239fe8c` (277 bytes each). Both stderr files are 0 bytes, sha256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.

Host identity (same window, `host-probe.txt`):

```text
command -v blender → /usr/bin/blender (default_which_rc=0, pinned_which_rc=0)
readlink -f → /usr/bin/blender
stat → size=116071952 mtime=2026-08-31 21:24:57.000000000 -0300 mode=755
sha256sum /usr/bin/blender → fd7c5e44f50de3012e9cd8c919ce7cfaca716ff7bc3b9d9e53d300401b892e7c
blender --version → Blender 5.2.1 LTS / build hash 9e2066aef7ef / build date 2026-09-01 / version_rc=0
pacman -Q blender → blender 17:5.2.1-2 / pacman_rc=0
default node → /home/vgpnk/.local/share/mise/installs/node/latest/bin/node v26.12.0
pinned node → /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node v24.21.0
```

The full `blender --version` flag dump is in `host-probe.txt` and is not repeated here. An earlier probe at `2026-10-18T21:20:30Z` is in `reports/round-106/scratch/seat36/probe-host.txt` and printed the same version lines; the saved receipts above are the ones to cite.

## Battery presence (no run)

`bpy_battery.py` is a sibling runner. Its module docstring says it runs `bpy_sync_probe.py` under `blender -b -P`. This seat confirmed the files and the case table, then stopped.

| path | tracked | sha256 | bytes |
|---|---|---|---:|
| `corpus/fixtures/bpy_battery.py` | yes | `045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec` | 36577 |
| `corpus/fixtures/bpy_sync_probe.py` | yes | `07ec83e33512b6430b085dee9029163b41594b4e6e8608aab8b98d6c6c483a48` | 63726 |
| `corpus/fixtures/bpy_rbw3d.gd` | yes | `b35909d13f487ca276188c88fcb1fc29b15b9e60a1060736380e1924f951b61c` | 6272 |
| `corpus/fixtures/r91_child.py` | yes | `ab63245b1b29c5c647444ba6f062695679b795383db8b417f08a4df2ba1a6b56` | 21989 |
| `corpus/fixtures/run_battery.py` | yes (read-only) | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | 346248 |

```text
$ PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile corpus/fixtures/bpy_battery.py corpus/fixtures/bpy_sync_probe.py
py_compile_rc=0
$ python3 corpus/fixtures/bpy_battery.py --help
usage: bpy_battery.py [-h] [--blender BLENDER] [--runs RUNS]
help_rc=0
```

`--help` exits before `main()` creates a run directory. `find corpus/live/runs -maxdepth 1 -name 'bpy-*' -newermt '2026-10-18 18:15'` printed no paths. `git status --porcelain` on the four fixture paths was empty after these checks.

AST count of `CASES` in `bpy_battery.py` (not a Blender launch): **83** rows, `TIMEOUT_S=60`, `PROBE` assigned. Arms: transform 7, hide 3, modifier 3, collink 2, membership 7, draincheck 3, shared 4, freshhandle 4, vis 4, evalcat 41, hazard 1, reorder 4. `non_signal` 4, signal 79.

AST count of `run_battery.py` tuples whose name starts with `bpy_`: **10**, all script `bpy_rbw3d.gd`:

`bpy_rbw3d_det`, `bpy_rbw3d_bake`, `bpy_rbw3d_window`, `bpy_rbw3d_order`, `bpy_rbw3d_resim`, `bpy_rbw3d_knobs`, `bpy_rbw3d_ops`, `bpy_rbw3d_io`, `bpy_rbw3d_render`, `bpy_rbw3d_ptr`.

Those 10 rows are Godot-parent cases that spawn `blender -b -P`. They are present in the runner. This seat did not execute them.

## Archived receipts (read, not re-run)

Parsed with a local `json` load. Not a battery invocation. All three already-saved verdict files contain the same 10 `bpy_*` rows, all `PASS`. That does not refresh the census by itself, and it is not this seat's run.

```text
reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
  verdict=PASS seeds=True totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59}
  bpy 10 pass 10 fail 0
reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json
  verdict=FAIL seeds=False totals={'cases': 350, 'pass': 350, 'fail': 0, ...}
  bpy 10 pass 10 fail 0
reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
  verdict=FAIL seeds=True totals={'cases': 350, 'pass': 337, 'fail': 13, ...}
  bpy 10 pass 10 fail 0
```

The 13 fails in the 337/350 receipt are not bpy rows (this parser's `bpy_*` filter was empty of failures). Do not read that as a bpy result, and do not read the archived 10/10 as a substitute for a bounded re-run.

Version pin still matches the live binary: fixture docstring and the r91 battery comments say Blender 5.2.1 LTS; `reports/frontier/bpy-boundary.md` names build `9e2066aef7ef`. This probe observed both. No dated correction inside the fixtures (they are not this seat's files, and the pin is still true).

## Queued, not applied

1. **`corpus/knowledge/engines.md` still has no Blender row after the concurrent r106 refresh.** Coverage defect for the engines owner. Not edited here. Their close-time judgment queue (read this seat, lines 109–122 of sha `149e61cf…`) names cannon-es, the stale `SKILL.md` stamp, and the `v26.11.1` note. It does not name Blender. Their census-file list at `2026-10-18T21:38:07Z` predates this report. A row may move to "executable headless" only with a saved bounded fixture receipt and a non-author verifier — this file is neither. Suggested cell, if that owner lands it: installed **yes** (`/usr/bin/blender`, pacman `17:5.2.1-2`); executable headless **partial** (background `bpy` import rc 0, both Node PATH states, this report); do not write `yes` until `bpy_battery.py` or the `bpy_rbw3d_*` rows have a new saved receipt plus a non-author verifier. Note in the row that the node pin does not select this binary.
2. **`PROVINCE.md` standing host fact** names Godot / Unity / Unreal / three.js and not Blender. Protected this round. Not edited. `rg -n -i 'blender|bpy' PROVINCE.md` exited 1.
3. **`SKILL.md` description** lists Godot, three.js, Unity, Unreal and not Blender. Protected. Not edited.

`reports/round-106/census/verify.md` (SEAT-40, read this seat) compared the four engines.md rows and did not probe Blender, because the census table has no Blender row. This file does not reopen that seat's verdict.

## What this file does not say

- It does not say the bpy battery passes.
- It does not say the 10 `bpy_rbw3d_*` rows pass on this round.
- It does not promote an engines.md row.
- It does not claim an Unreal, Unity, Godot, or three.js result.
- It does not claim rendering, pixels, or a GPU path. `bpy.app.background True` is the import probe, not a render.
