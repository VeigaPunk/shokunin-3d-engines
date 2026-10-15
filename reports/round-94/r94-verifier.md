# r94 verifier — wave-B gate on committed `05e72ef`

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 94. Assigned
tree: `05e72ef968f218fc7c4f8b2e58a190d2eddd63fc` ("r94 author: 19 cannon.js
rows (284 total) — boundary corrections folded … 284/284 green"). Author
report: `reports/round-94/r94-author.md`; boundary: `r94-boundary.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(`--headless` before `--script` throughout), `node` `v24.21.0` via inherited
PATH (fnm), Python 3.14.7, 32-thread host. **No `lsp` device is exposed to
this seat's toolset** (same recorded absence as r85–r93 lanes); no source
edits were made, so the hand-edit fallback was never in play. This seat wrote
only `corpus/live/r94-verifier/**` (gitignored via `corpus/.gitignore: live/`)
and this report. No commits, no tracked writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `05e72ef`, `git status --porcelain`
  empty; sha256 of `r94_cannon.gd` (`d40a1f75…`), `r94_child.mjs`
  (`c84a8e8a…`), `run_battery.py` (`b230d29c…`), `r94vendor/cannon-es.js`
  (`f0700cbd…`), `three.core.js` (`9edde002…`), `three.module.js`
  (`9052042d…`), `package.json` (`75310bff…`) all byte-match the commit.
- **Vendored bytes = scout's npm pins**: the three dist bundles sha256-match
  `corpus/live/r94-scout/proj/node_modules/{cannon-es/dist/cannon-es.js,
  three/build/three.core.js, three/build/three.module.js}` byte-for-byte.
  All six r94 paths are inside the battery's `seed_digests()` before/after
  map (verified by enumeration).
- **Mid-seat movement (documented, contained):** three sibling report
  commits landed during the seat — `7cd5ec8` scribe 19:23, `942f56e`
  critic 19:25, `52b2fbc` simplifier 19:27 — and an r95 lane wrote the
  untracked `corpus/fixtures/r95vendor/` at 19:28:59. `git diff 05e72ef
  52b2fbc -- corpus/` is **empty**: all commits are report-only. Every r94
  measurement below ran on bytes identical to `05e72ef` (both batteries
  closed `seeds_unchanged=true`; worktree fixture shas re-verified equal
  at filing). The CASES diff was computed on committed blobs (`git show`).
- **Host context:** the corpus's normal multi-seat box. During the seat a
  r94-reviewer frozen-tree battery, a g2d battery, and sibling probes ran
  concurrently; loadavg ranged ~55–127. The "under load" condition was
  ambient and real; this seat additionally added its own 24-hog arm for the
  flip probe (trap-killed; zero stray `while` loops at filing).

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | CASES diff is insertion-only, +19 rows, 284 total | **PASS** — AST `literal_eval` at `05e72ef^` vs `05e72ef`: 265→284, single `insert` op of the 19 `r94_cannon_*` tuples appended after `r93_areasig_prio`; `new[:265] == old` byte-equal tuples; removed=0, changed=0, dup-names=0; `expected_exit` ∈ {0,2}, script `r94_cannon.gd` on all 19 |
| 2 | All 19 r94 rows pass on committed bytes, under load | **PASS** — `--only` battery at loadavg ~110–123: **19/19 PASS**, `seeds_unchanged=true`, parent stderr 0 lines each, elapsed 0.8–3.8 s (bound 20 s); full battery (§3): **19/19 r94 PASS** |
| 3 | Rep-stability: digest surface deterministic | **PASS (arm level) / SEE F1 (child level)** — 6 reps × 19 arms standalone under ambient load+own battery: **114/114 executions rc correct (0 or 2), stderr empty, stdout byte-identical per arm, and each rep's marker line byte-equals the committed `CASES` pin** (114/114). Direct child probe of the 4 critic-flagged accumulator cells: **1160 executions, 0 flips** (§4) |
| 4 | Wall-clock instability stays unpinned & confined | **PASS** — `mod_fixedstep` `#` diag `stepnumber=1 ph=a3ec872defc812b2` in all 6 reps (boundary's stable ph; only `d=1` count + `class=wallclock mode_ok=1 ticks_lt_calls=true` pinned). `var_bailout` `stepnumber=1` edge held 6/6 reps + 2 battery runs |
| 5 | Full battery 284 rows on final bytes | **PASS-with-classified-fails** — 280/284; all 19 r94 and all 7 r93 rows PASS; every FAIL is a non-r94 documented load-flake row (§3); `seeds_unchanged=true` |
| 6 | Fixture hygiene / red flags | **PASS** — bounded machinery (`timeout -s KILL 15` per child, `BOUND_S=15`; battery `CASE_TIMEOUT_SECONDS=20`); child case names come only from `ARM_CASES`/`NEGATIVE` constants (no user-input paths); children write only `child.log` under `res://r94ch_<case>` of the scratch project; `o` counts every non-M/non-`#` line (any node warning/stack/`ERROR:` line fails the cell); `d` counted-never-pinned; negative arms require rc=2 **and** exactly one `NEGATIVE REJECTED:` line **and** `o=0`; child itself has zero fs/net/subprocess calls |

## 1. Marker surface — insertion verified, cells well-formed

`tools/compare_cases.py`: 265→284, tail insert only. Cell counts per row
13+4+6+1+1+9+2+1+4+5+8+4+2 = **60 `{rc=…}` digest cells** over the 13
positive rows + 6 negative rows = **66 child processes per pass** — matches
the author report (its "66 child cells" phrasing; critic F5 wording nit
noted there). Spot-pinned semantics verified in the markers themselves:
`det_base` carries the canon pin `h=0e24fb5aca619253`; `ord_*` pin the
corrected per-order hashes (`asym2 2e65cf…≠d02da5…`, `stack3 4caaad…≠d3795d…`,
`tri f1a92e…≠a8ad93…`) with `sortedSame=false` solver signatures;
`mod_internal` carries the boundary-corrected pair (`h=c882e660… sleep=1,1,1,1
eqBase=false` frozen vs `h=0e24fb… sleep=2,2,2,2 eqBase=true` clocked);
`mod_dt_zero_acc` pins `acc=NaN` + `frozen=true`; `mod_fixedstep` pins only
the class; `fric_corrected` carries the measured grid (`15.173` mass-inert,
`3.053…17.273` μ/v₀-dependent), not `15·μg`; the 6 negatives pin
`NEGATIVE REJECTED:` + exit 2 after a live control.

## 2. Batteries executed (all on `05e72ef` bytes)

| run | context | totals | notes |
|---|---|---|---|
| `--only` r94, `runs/20261015T221437686978Z` | loadavg ~110–123 | **19/19 PASS**, `seeds_unchanged=true` | verdicts `44993b3c…` |
| full, `runs/20261015T221556034992Z` | loadavg ~84–125, sibling batteries | **280/284**, Σ504.2 s, max 20.012 s | verdicts `1b85e6d4…`; `seeds_unchanged=true` |
| rep sweep `reps/` | same ambient + own full battery | 114 standalone arm execs, all byte-identical & marker-equal | incl. `mod_fixedstep`/`var_bailout` child-log archives per rep |
| flip probes `flips/`,`flips-load/` | ambient ~55–85 + own 24 hogs | **1160 child execs, 0 flips, rc=0 all** | targeted at the critic's 4 flagged cells (§4) |

## 3. Non-r94 failures — classification

| case | signature | class |
|---|---|---|
| `navagent3d_retarget` | `before=1.754246` vs pinned `1.730676` | **documented F1** navagent 1-tick miss — identical value to r93-verifier and r94-author run 1 |
| `navagent3d_retarget_fixed` | same internal `before=1.754246` misfire | F1 |
| `navagent3d_follow` | `first=1.636395` | F1 — identical value to r93-verifier |
| `phys3d_joints_free_ops` | TIMEOUT at the 20 s bound | **documented** bound row under ~load 100–125 |

`phys3d_events_script_size_gate` and `phys3d_events_deferred_hang` (the F2
pair) held their pins this run. All 23 r92 rows and all 7 r93 rows PASS —
neither prior fold's surface is disturbed by the r94 landing.

## 4. The one contested surface — accumulator wall-bail (critic F1)

The committed mid-seat `r94-critic.md` (F1, MEDIUM) measured **13 M-surface
flips in 1340 direct child execs (~1.0 %) at load1 90–135** on
`{var_interp, var_sleep_phase, var_maxsub, mod_two_arg}` — mechanism the
engine's `performance.now() - t0 > dt*1000` (16.67 ms) substep bail
(`cannon-es.js:12529`), i.e. boundary §7's class inside pinned cells.
This seat's independent measurement on the same committed bytes:

- `flips/` (ambient ~55–85): 200×`mod_two_arg` + 120×3 others = **560 execs, 0 flips**
- `flips-load/` (own 24 hogs, ~55–75 effective): 150×4 = **600 execs, 0 flips**
- arm level: 114/114 byte-identical (matches critic's own 114/114 arm runs)

**Classification:** the class is real (critic's flipped values are
budget-arithmetic-exact: `stepnumber=4` where 10 pinned) but
**load-rate-conditional** — my 1160 execs at ~55–85 saw none where ~1 %
would predict ~11 at ≥90 load. Per-row fail rate ≈ 4 cells × ~1 % only when
load ≳90; every row-level run on record (author 19/19 + 284/284 + 280/284;
scribe audit; critic 42 row-execs; this seat 19/19 + 19/19 + 114 reps)
passed. Not a defect in the pinned *values* (the un-preempted path is the
correct witness); it is a residual load-flake risk on 4 named cells, to be
dispositioned by the canonical judge alongside the documented flake list.

**Labrat disclosure:** this seat's one permitted `ufo-labrat` probe was
dispatched on this exact hypothesis and returned **environment-blocked** —
the repo is not materialized in its sandbox and it has no exec capability
(same limitation class the critic recorded). The hypothesis was measured by
this seat directly, so no evidence gate is left open.

## 5. Static review notes (non-blocking)

- `r94vendor/package.json` is `{"type":"module","private":true}` — the
  author report quotes only `{"type":"module"}`; cosmetic nit. The file is
  load-bearing (critic M9: removing it → `o=4` warnings FAIL the row;
  simplifier flags a layout-dependent conflict with critic F8 → adjudicator).
- Simplifier's "nan arm is 16 distinct hashes not 22" is consistent with the
  marker: 22 NaN-lattice M-lines, canonical hashing collapses repeat states
  — report-accuracy nit only.
- The negative-arm gate does not bound `d` (extra `#` lines from a negative
  child would be invisible to the marker); harmless — `rc=2` + exactly one
  reject line + `o=0` already fails closed.
- `node` resolves via inherited PATH; version pinned in every PASS line
  (`node=v24.21.0`). Scribe measured v24/v26 byte-identical — the pin is a
  host pin, same class as `/usr/bin/godot`/`/usr/bin/blender`.

## Files changed

None tracked beyond this report. Written by this seat (all gitignored):
`corpus/live/r94-verifier/{runs/…,reps/…,spot/proj/**,flips/,flips-load/,
tools/{compare_cases.py,rep_sweep.sh,flip_probe.sh,flip_probe_load.sh},
cases-diff.json,MANIFEST.txt,*.log}` — **1318 receipt files** hashed in
`MANIFEST.txt`.

Key receipt shas:
- r94-only verdicts `44993b3c…` (19/19, seeds_unchanged=true, ~load 110–123)
- full verdicts `1b85e6d4…` (280/284, ~load 84–125, seeds_unchanged=true)
- `mod_fixedstep` `#` diag, 6/6 reps `stepnumber=1 ph=a3ec872defc812b2`

## Remaining risks / blockers

- **Critic F1** (§4): 4 accumulator cells carry a measured ~1 %/child-exec
  flip class at load ≥90 — unreproduced in my 1160 execs at ~55–85, so the
  rate is load-conditional; a flip is a row FAIL by construction. Top
  residual risk; disposition is the canonical runtime's.
- The r94 surface pins `node v24.21.0` + the vendored `cannon-es@0.20.0` /
  `three@0.186.1` bytes + `/usr/bin/godot 4.7.2` — host pins, no
  cross-runtime inference (v26 byte-identity is the scribe's evidence).
- `var_bailout` `stepnumber=1` sits on the boundary-measured 1↔2 substep
  edge at `dt=1e-5`; held in all my runs but remains the thinnest pin.
- Stray-process check at filing: zero godot/node/`timeout`/`sh` processes
  referencing `r94-verifier`, `r94ch_`, or my run dirs; live battery/godot
  processes all belong to sibling seats (r94-reviewer, g2d-r89).
- No blockers to the gate decision itself.

## Verdict

The insertion is clean (265→284, zero prior rows touched, strict prefix),
the vendored engine bytes are the scout's sha-verified npm pins, every r94
cell is byte-pinned and reproduced **byte-exactly on 19/19 + 19/19 battery
passes + 114 independent arm executions** under sustained real load
(~55–127), the wall-clock-dependent surface is correctly confined to the
`#`/class channels (`mod_fixedstep` measured `stepnumber=1` in the `#` slot,
`var_bailout` edge held), and all four non-r94 FAILs classify to the
documented load-flake list. The one contested surface — critic F1's ~1 %
accumulator-cell flip — was measured by that seat at higher load and is
reported here as the top residual risk, not reproduced in this seat's
1160 executions.

**VERIFIED** — committed `05e72ef` clears the wave-B gate, with F1 carried
forward as a documented load-conditional flake candidate for the canonical
judge.
