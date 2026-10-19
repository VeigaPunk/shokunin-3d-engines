# SEAT-28 CENSUS-CANNON — `r94_cannon_det` pinned-env row

Axes: **depth** (one cannon row re-probed, not inherited), **coverage** (pinned Node 24 path actually resolved), **calibration** (verdict fields match the r105 accepted full-run receipt; no engines.md rewrite).

Result: **PASS**. `r94_cannon_det` (`r94_cannon.gd --arm=det`) exited 0/0 under command-scoped fnm Node `v24.21.0`. Exact stdout marker matched, including `node=v24.21.0` and `engine=cannon-es-0.20.0+three-0.186.1`. `seeds_unchanged=true`. This is one ordinary row, not a 350-case claim.

## Environment (two-state)

| State | Resolution | Observed |
|---|---|---|
| pinned (this run) | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH"` | `command -v node` → that `bin/node`; `node --version` → `v24.21.0` |
| default (host, not used for the row) | mise | `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node` → `v26.12.0` |

The PATH prefix was command-scoped. After the run, plain `node --version` was still `v26.12.0`. No mise/fnm config was written. No fixture file was written. `git status --short -- corpus/fixtures` returned no paths.

Runner: `corpus/fixtures/run_battery.py`, SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (same bytes as the r105 accepted receipt). HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Godot from the verdict: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, version exit 0.

## Command

From the repository root, 2026-10-18T21:20:35Z:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  python3 corpus/fixtures/run_battery.py --only r94_cannon_det \
  --runs reports/round-106/scratch/seat28-cannon
```

Scratch is under `reports/round-106/scratch/` because `/tmp` per-user quota is exhausted. The runner copies the fixture tree into the run scratch; that copy is not a fixture edit.

## Observed terminal

```text
PASS r94_cannon_det: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     r94_cannon_det                     r94_cannon.gd              --arm=det          0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/scratch/seat28-cannon/20261018T212035892614Z/verdicts.json
COMMAND_EXIT=0
```

Full transcript: `reports/round-106/census/cannon-run-20261018T212035Z.log` (SHA-256 `64638c76cd22353d0c92b3340830194563370e45454845d7934954579980ecd4`).

## Verdict JSON

Durable copy (byte-identical to the runner output; `cmp` via equal `read_bytes()`): `reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json`

| Field | Observed |
|---|---|
| SHA-256 | `11109a3cad610b759974606e7784a5f215332c7d092ab0ead0c514b2fdac344f` |
| bytes | 20884 |
| `verdict` | `PASS` |
| `only` | `r94_cannon_det` |
| `started_utc` | `20261018T212035892614Z` |
| `totals` | cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 |
| `seeds_unchanged` | true (131 seed digests) |
| result | exit 0/0, kind ordinary, reasons `[]`, elapsed 1.68s |
| marker | exact match in stdout; token `node=v24.21.0`; engine token `cannon-es-0.20.0+three-0.186.1` |
| stderr | empty |

Parsed with `json.load` on the durable copy. Marker equality against `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` row `r94_cannon_det` is true (that row also PASS, exit 0/0, elapsed 1.769s). r105 stdout lines 266 and 618 are the matching PASS lines. This r106 probe does not replace that full-battery receipt.

## What this does not claim

- Not a full battery. r105 pinned remains 350/350 (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`); default-env 337/350 is unchanged and was not re-run here.
- Not an Unreal runtime claim. Editor is not installed; this row is Godot headless driving vendored cannon-es.
- `corpus/knowledge/engines.md` has no cannon row. This seat does not own that file and did not edit it. The cannon evidence class for a later census refresh is: lane fixture, executable headless only under pinned Node `v24.21.0` (marker-pinned), receipt above.
