# SEAT-35 CENSUS-ANIMTREE — r106

Axes: depth (one r99 AnimationTree row re-probed, not inherited), coverage (battery case name resolves; both r105 environment states actually selected), calibration (marker bytes match the seeded expectation and the r105 pinned full-run row).

Result: **PASS**. Chosen row `r99_animtree_core` (`r99_animtree.gd --arm=core`), the first of the nine r99 arms. Contract is one row. Both environment states of that same row passed. The other eight arms were not re-run.

## Result

| State | Battery | Row | Exit | Reasons | Case elapsed | Process wall | Receipt |
|---|---|---|---|---:|---:|---:|---|
| default (mise Node v26.12.0) | PASS | PASS | 0/0 | `[]` | 3.423 s | 3.534 s | `reports/round-106/census/animtree-r99_animtree_core-default-20261018T213234Z.verdicts.json` |
| pinned (fnm Node v24.21.0, command-scoped PATH) | PASS | PASS | 0/0 | `[]` | 3.208 s | 3.321 s | `reports/round-106/census/animtree-r99_animtree_core-pinned-20261018T213238Z.verdicts.json` |

Case elapsed is the runner's `elapsed_seconds` (Godot child only). Process wall is `date +%s.%N` around the whole `python3 corpus/fixtures/run_battery.py` invocation. `case_timeout_seconds=20`. Both finished well under that bound. Stderr was empty (0 bytes) on both. `seeds_unchanged=true`. Runner rc 0.

Marker length 2519 bytes. Exact stdout marker matched the seeded expectation (one copy in the receipt stdout) and matched the r105 pinned full-run row `r99_animtree_core` byte-for-byte, including that row's stdout lines. r105 elapsed for the same row was 3.807 s, also PASS. This probe does not replace that 350/350 receipt.

## Environment (two-state)

Commands run from the repo root immediately before the cases. Probe stamp `2026-10-18T21:32:34Z`.

```text
$ node --version; command -v node; readlink -f "$(command -v node)"
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ python3 --version; command -v python3
Python 3.14.7
/usr/bin/python3
$ command -v godot; godot --version
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/r99_animtree.gd corpus/fixtures/r99_probe_r99b_core.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2  corpus/fixtures/r99_animtree.gd
6683aba10439885d08488fd36275fabbb938895f04a853cb2650e4e10db0ff51  corpus/fixtures/r99_probe_r99b_core.gd
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ git status --porcelain -- corpus/fixtures/run_battery.py corpus/fixtures/r99_animtree.gd corpus/fixtures/r99_probe_r99b_core.gd
(empty)
$ /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version
v24.21.0
```

The pinned binary was present and not selected for the default run. The pinned run prefixed that `bin` directory for one command only. After both runs, plain `node --version` was still `v26.12.0` at the mise path, and the three seed paths above were still porcelain-clean. No fixture file was written. No mise/fnm config was written.

Env-exposure class, from the r105 marker audit (`reports/round-105/n24/markers.md`): this row is not one of the 13 `node=v<semver>` rows. Its expected marker has no `node=` token. The two-state rerun confirms that: default and pinned stdout lines are identical, so Node PATH is environment identity here, not a marker input. Godot is the runtime that the row actually exercises.

## Commands and observed output

Scratch is under `reports/round-106/scratch/seat35/` because `/tmp` per-user quota is exhausted. The runner copies the fixture tree into each run's scratch; that copy is not a fixture edit.

```text
$ python3 corpus/fixtures/run_battery.py --only r99_animtree_core \
    --runs reports/round-106/scratch/seat35/runs-default
PASS r99_animtree_core: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../runs-default/20261018T213234560570Z/verdicts.json
DEFAULT_RC=0 WALL=3.534
stderr bytes=0

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
    python3 corpus/fixtures/run_battery.py --only r99_animtree_core \
    --runs reports/round-106/scratch/seat35/runs-pinned
PASS r99_animtree_core: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../runs-pinned/20261018T213238104799Z/verdicts.json
PINNED_RC=0 WALL=3.321
stderr bytes=0
```

Wall clock of the pair: start `2026-10-18T21:32:34Z`, after default `2026-10-18T21:32:38Z`, after pinned `2026-10-18T21:32:41Z`. Captured stdout: `reports/round-106/census/animtree-default-20261018T213234Z.stdout` (SHA-256 `472bdedfb8b1e3bf74628e63ca71944a37adb580a1f6f8f648a0ee3f335b80f4`, 475 bytes) and `reports/round-106/census/animtree-pinned-20261018T213238Z.stdout` (SHA-256 `0ec36f7b6a995cd5a338ac59172831b41464272c28071dba7e325c9e7d8e86c6`, 474 bytes). Each durable verdict copy is byte-identical to the runner output (`read_bytes()` equal).

## Verdict JSON

| Field | Default | Pinned |
|---|---|---|
| SHA-256 | `4dd697a576fe853a6c59e22d78039d1f4cc9d685f76c6ff33f87793349666e9c` | `219fba09749b0ec54a706b813e433d085f9543c34d3ab21e84b1bfbe2d0ef146` |
| bytes | 19233 | 19231 |
| `verdict` | PASS | PASS |
| `only` | `r99_animtree_core` | `r99_animtree_core` |
| `started_utc` | `20261018T213234560570Z` | `20261018T213238104799Z` |
| `totals` | cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 | same |
| `seeds_unchanged` | true (131 seed digests) | true (131) |
| runner sha | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | same |
| `r99_animtree.gd` sha | `75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2` | same |
| `r99_probe_r99b_core.gd` sha | `6683aba10439885d08488fd36275fabbb938895f04a853cb2650e4e10db0ff51` | same |
| Godot | `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, version exit 0 | same |
| row | PASS, exit 0/0, ordinary, reasons `[]`, error `None`, stderr empty | same |
| marker vs r105 row | equal (2519 bytes); receipt stdout lines equal | equal |

Parsed with `json.load` on the durable copies. Godot command recorded in each receipt is `/usr/bin/godot --headless --path <that run's scratch> --script res://r99_animtree.gd -- --arm=core`.

Original runner receipts (same bytes as the durable copies): `reports/round-106/scratch/seat35/runs-default/20261018T213234560570Z/verdicts.json` and `reports/round-106/scratch/seat35/runs-pinned/20261018T213238104799Z/verdicts.json`.

## Census note for engines.md (not edited here)

`corpus/knowledge/engines.md` is outside this seat's write set. Queue for the engines census owner, dated 2026-10-18:

Godot row remains executable-headless. Fresh receipts for `r99_animtree_core` under both r105 environment states are the two paths in the result table (both `PASS battery`, `seeds_unchanged=true`, Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`). The row does not pin Node, and the two states produced the same marker. This does not move any engine row, does not cover the other eight r99 arms, and does not authorize an Unreal runtime claim.

## Not done

- The other eight `r99_animtree_*` arms (`ut_scope`, `ut_mech`, `modes`, `order`, `sm_adv`, `sm_misc`, `silent`, `life`). Not this seat. They were PASS in the r105 pinned full receipt (elapsed 2.793–4.749 s) and were not re-run here, so that fact is not a fresh census claim.
- Full 350-case battery. Not this seat. Default-env 337/350 and pinned-env 350/350 stand as the r104/r105 receipts, not as something this row remeasures.
- No edits to `corpus/knowledge/engines.md`, fixtures, or rounds 101–105. No citation defect in this chunk to fix.
