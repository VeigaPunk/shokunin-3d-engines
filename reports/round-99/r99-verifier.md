# r99 verifier — wave-B gate on committed `f1ff626`

**VERDICT: VERIFIED.** Every assigned claim of the r99 animtree landing
(`f1ff626`: `r99_animtree.gd` + 6 byte-identical boundary probe copies + 9
insertion-only battery rows, 342 total) re-derives on the committed bytes:
**183/183 cells** rebuilt from raw child logs by this seat's own scanner and
own hand-transcribed spec, in **five independent harness instances** (three
battery passes + two of this seat's own drivers), with **0 cell problems** and
**0 sha disagreements** between any two instances. `beq=1` on **122/122**
comparison cells; the `clsloop` `td` encoding is load-bearing and correctly
scoped (post-marker teardown abort tolerated, pre-marker abort fails, non-`td`
cells still fail on rc=134); the pinned markers bite under six scratch-copy
mutations. Findings are INFO (§8); no blockers (§9).

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 99. Assigned
tree: `f1ff626f4d83e67ab841485a56e972e79869535d` ("r99 author: 9 animtree rows
(342 total) — 183 cells, beq=1 122/122 backends, clsloop td-encoded heap
abort; 342/342 x2"). Task: `…/tasks/g3d-r99-verifier.md`. Author report
`reports/round-99/r99-author.md`; boundary `r99-boundary.md`; scout
`r99-scout.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/python3` `3.14.7`, 32 threads; **1-min load average 52 → 83 → 60
across the seat** (sibling lanes active: `r99-simplifier` report appeared in
the worktree mid-seat). **No `lsp` device is exposed to this seat's toolset**
(same recorded absence as r85–r98); this seat made no source edits, so the
hand-edit fallback was never in play. It wrote only
`corpus/live/r99-verifier/**` (gitignored via `corpus/.gitignore: live/`) and
this report. No commits, no tracked writes. The frozen probeParent privilege
(one read-only `labrat`) was **not used**: every assigned claim closed
empirically under this seat's own tooling, so no residual falsifiable
hypothesis remained to delegate (§8 F7).

## Byte custody

- At seat start `git rev-parse HEAD` = `f1ff626f4d83e67ab841485a56e972e79869535d`
  and `git status --porcelain` carried only sibling untracked reports
  (`r94-reviewer`, `r95-reviewer`; `r99-simplifier` appeared mid-seat). **No
  tracked file was modified** by this seat or by any run it started.
- **Fixture sha**: committed `corpus/fixtures/r99_animtree.gd` =
  `75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2` (779 lines,
  matches the commit stat `+779`).
- **6/6 probe copies are the boundary sources, not lookalikes**: committed
  blobs equal `corpus/live/r99-boundary/probes/r99b_*.gd` byte-for-byte *and*
  equal the boundary manifest pins —
  `core 6683aba1…`, `life 2eb2e242…`, `modes f6d23bb1…`, `silent de0fd54e…`,
  `sm a8d41a1b…`, `untracked 5981275d…` (the six shas quoted in the author's
  §"Probe-copy SHA-256" table).
- **CASES diff is insertion-only**: AST `literal_eval` on the committed blobs
  (`ba5ab41` → `f1ff626`): **333 → 342**; `new[:333] == old` tuple-equal;
  removed 0, changed 0, duplicate names 0; composition **283 ordinary + 59
  negative** (the r98 274+59 set plus the 9 new ordinary rows); the 9 tail
  rows are `r99_animtree_{core,ut_scope,ut_mech,modes,order,sm_adv,sm_misc,
  silent,life}` on `r99_animtree.gd` with `expected_exit=0`.
- **183 pinned cells / 183 children per pass** — counted four ways, all 183:
  (a) the fixture's own cell tables executed (`tools/countcells.gd`, scratch
  copy: `core 21, ut_scope 21, ut_mech 21, modes 27, order 12, sm_adv 27,
  sm_misc 21, silent 15, life 18`); (b) this seat's hand transcription
  (`tools/cellspec.py`) — **byte-identical to (a) on all 183 rows**
  (`tools/specdiff.py`: `identical: True`); (c) cell tokens parsed out of the
  nine pinned markers (21/21/21/27/12/27/21/15/18 = 183); (d) dynamically, in
  every scratch: **183 `r99t*` child dirs / 183 `child.log` / 0 `.godot`**.
- 61 logical cells × 3 backends (gp60/jolt60/dummy60) = 183; the battery's 9
  rows are the 9 arms.

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | Committed tree loaded; zero tracked writes | **PASS** — HEAD `f1ff626`; only gitignored scratch + this report; `git status` clean of tracked edits |
| 2 | Fixture/probe custody | **PASS** — fixture sha recorded; 6/6 probes byte-identical to boundary sources and manifest pins |
| 3 | CASES insertion-only, +9 rows, 342 total | **PASS** — strict-prefix tail insert; 0 removed/changed/dups; 283+59 |
| 4 | 183 cells = 61 × 3 backends | **PASS** — four independent counts, all 183 (§Byte custody) |
| 5 | r99 rows green on committed bytes | **PASS** — 9/9 in **every** instance: 3 r99-only batteries, 4 single-arm batteries, full1; row stdout byte-identical across instances (§1) |
| 6 | Full battery 342 rows on committed bytes | **PASS (r99) / host-limited (overall)** — full1 339/342 (3 pre-existing navagent rows); full2 see §1 |
| 7 | 183 children per pass, bounded | **PASS** — 183/183/0 `.godot` in 4 battery scratches + 2 own runs; max **8** concurrent `timeout` children observed (CHUNK=8) + the parent |
| 8 | All 183 cells re-derived independently | **PASS** — **183/183 × 5 harness instances, 0 problems**; 180/180 unique-cell shas identical across all five (§2) |
| 9 | `beq=1` on all comparison cells | **PASS** — **122/122** in every instance; `peq` 1 on the four PHYSICS comparison cells and 0 on the four IDLE ones, as declared; `mk=0` never observed |
| 10 | Scanner fail-closed semantics | **PASS** — this seat's re-implementation agrees **13/13** with the committed fixture's own `_scan_lines` on synthetic streams (§5) |
| 11 | `clsloop` `td` encoding: marker-truncated hash | **PASS** — hashed stream is exactly the two lines through the marker; sha `9251889a008ea983` reproduced from raw logs on all three backends; `LIFE_DONE` is excluded (§4) |
| 12 | `clsloop` `td` rc acceptance `0\|134` | **PASS** — the fixture's own `_cell_ok` accepts 0 and 134, rejects 1; a real post-marker abort is recorded as **rc=134** by the fixture's own machinery (8/8 spawns) and passes with the pinned text (§4) |
| 13 | A pre-marker abort still fails loudly | **PASS** — abort before the marker ⇒ `mk=0` ⇒ arm `FAIL`; with `td` removed, the same post-marker abort also `FAIL`s (rc=134 printed, different sha, `beq=0`) (§4) |
| 14 | Does the gate bite? | **PASS** — 6 scratch-copy mutations: control exact, moved value / removed mask / injected ERROR / suppressed marker / extra hashed line all move or red the row (§6) |
| 15 | Encoded laws re-measured with this seat's own probe | **PASS** — own rig, own code: receiver-first wiring, `x = 4·tp`, exact blend read-back, TimeScale ratio 2.0000, untracked Ball zeroing, ENABLED vs AUTO, 340/240 census; 21/22 lines identical across gp/jolt/dummy (§7) |
| 16 | Author's cited receipts are real | **PASS** — 6 `verdicts.json` files re-read: 2 r99-only 9/9; 2 full **342/342**; 2 earlier full attempts **340/342** with exactly the documented legacy rows; r99 9/9 in all six |
| 17 | Hygiene / red flags | **PASS with INFO findings** — bounded children, dirname validation, fail-closed `ue`, no dead gates, no user-dir seeding, writes confined to scratch (§6, §8) |

## 1. Batteries executed (all on `f1ff626` bytes)

| run | dir (`corpus/live/r99-verifier/battery/…`) | context | totals | r99 rows |
|---|---|---|---|---|
| r99-only #1 | `only1/20261016T075645225603Z` | load ~70, sibling lanes | **9/9** | **9/9**, 2.03–3.69 s |
| r99-only #2 | `only2/20261016T080444457001Z` | load ~65 | **9/9** | **9/9**, 1.82–3.49 s |
| r99-only #3 | `only3/20261016T080507905332Z` | load ~65 | **9/9** | **9/9**, 1.90–3.73 s |
| single arms | `conc*` | concurrency probes | 1/1 each | `modes` / `sm_adv` green |
| full #1 | `full1/20261016T075718900664Z` | load 60–83 | **339/342** | **9/9**, 1.90–3.34 s |
| full #2 | `full2/…` | load ~60 | see run log | see run log |

- **Row output is byte-stable**: across the four completed battery instances
  each of the nine r99 rows produced **exactly one distinct stdout**, equal to
  the committed pin (`verdicts.json` comparison, 9/9 rows × 4 instances).
- `seeds_unchanged=True` in every instance: no fixture seed was touched by any
  run (the battery hashes all seeds before/after).
- Every full-battery failure is a **pre-existing, non-r99 row**: full1 —
  `navagent3d_retarget`, `navagent3d_retarget_fixed`, `navagent3d_follow` (the
  documented load flake; the author saw the same class plus
  `phys3d_events_deferred_hang` / `r96_joltdet_thread` in two earlier
  attempts). No r99 fixture, probe or cell is involved.
- The author's six cited receipts were re-read directly
  (`corpus/live/runs/<ts>/verdicts.json`): `…71708787743Z` 9/9,
  `…71742046259Z` 9/9, `…73752637660Z` **342/342**, `…74637746785Z`
  **342/342**, `…71812120994Z` 340/342 (`navagent3d_follow`,
  `phys3d_events_deferred_hang`), `…72806927381Z` 340/342
  (`navagent3d_retarget`, `r96_joltdet_thread`) — **r99 9/9 in all six**, as
  claimed.
- Per-row wall times (1.8–3.7 s) sit far inside the battery's 20 s per-case
  bound and inside the fixture's own 14 s child bound.

## 2. Independent re-derivation of all 183 cells (five sources)

`tools/vnorm.py` is a **from-contract** re-implementation of the declared
normalization (fixture header lines 15–35: banner/blank drop, the exact 2-line
Jolt warning pair, `#N`/`srv=S`/`seq=N`/`idle_rows=N`/`pf_rows=N` masks,
expected-error allowlist classes, marker truncation). `tools/cellspec.py` is a
hand transcription of the fixture's spec tables; `tools/specdiff.py` proves the
transcription is byte-identical to the fixture's own executed tables on all 183
rows. `tools/rederive.py` re-parses every pinned marker out of the
**committed** `run_battery.py` blob, re-reads each child's raw log, and rebuilds
`rc`, `sha`, `ee`, `ue`, every extracted field and every `beq`/`peq`/`mk` flag
with its own code.

| log source | harness | result |
|---|---|---|
| `battery/only1/…/scratch` | fixture's own children | **183/183, 0 problems** |
| `battery/only2/…/scratch` | fixture's own children | **183/183, 0 problems** |
| `battery/only3/…/scratch` | fixture's own children | **183/183, 0 problems** |
| `mine/` | this seat's own driver, 183 own children, **real exit codes** | **183/183, 0 problems** |
| `mine_rep2/` | second own-driver rep (fresh dirs/pids) | **183/183, 0 problems** |

- **Cross-instance identity**: 180 unique cell names (three names repeat across
  arms — `manual@*` exists in both `ut_mech` and `modes`), and **all 180 shas
  are identical in all five instances** — including the two runs driven by this
  seat's own spawner rather than the fixture's.
- **Flag census in every instance**: `beq=1` 122/122 (never 0); `peq` 1 on the
  four PHYSICS comparison cells (jolt/dummy of `phys_f30` and `phys_f120`, whose
  gp twins are the references) and 0 on the four IDLE ones; `mk=0` never.
- **Rep-stability**: this seat's two own-driver reps agree on 180/180 shas and
  on the identical 0-problem set; the three battery instances agree with them.

## 3. Cell facts re-measured (not restated)

- `min`: `dz=0` — `x = 4·tp` exactly on every sampled frame; `tp=0.5333`,
  `actor=(2.1333,0,0)` on all three backends.
- `timescale`: `dtp=0.2667`, `expect=0.2667` (exact 2× over 8 physics frames).
- `rootswap`: pose cut on a continuing clock (`tp=0.2833`, `x=4·tp`).
- `body`: `srv` read equals the node pose on GP and Jolt, `srv=nil` on Dummy.
- `ut_*`: `ctl/namedlib/ballonly/keyless` zero the Ball on node **and** server;
  `libclean`/`orphan`/`otherplayer` do not; `typedef` resets scale/rot and
  keeps position; `repeat` re-zeroes a hand-restored Ball; `notree` does not.
- `modes`: PHYSICS rate-invariant (`peq=1` at ffps 30/120), IDLE rate-dependent
  (`peq=0`); MANUAL inert until `advance()`.
- `order`: `lead_zero` 2 (phys pre) / 1 (phys post) / 1 (idle both).
- `sm_adv`: all seven ENABLED wirings end `node=a`, `swpf=-`; `autocond`
  `swpf=7`; `autonocond` `node=b`.
- `sm_misc`: `next()` inert; `travel_path=[]`; `condlate node=b` vs
  `condlate_enabled node=a`; `stopstart` `si_playing=true`, `st_playing=false`.
- `silent`: `ee=0` on the two silent no-ops, `ee=1` on the duplicate
  node/state, `ee=6` on `travel(zzz)`.
- `life`: free tree freezes (`tp=-`), free player does not stop the tree,
  null root freezes, active off/on holds+resumes.

## 4. The `clsloop` `td` encoding — three-way evidence

1. **Truncation is real and load-bearing.** This seat's scanner over the raw
   child logs yields `sha=9251889a008ea983` on all three backends for the
   stream truncated at `CLS_LOOP_ALIVE`; the hashed stream is exactly
   `["CLS_LOOP made=340 skipped=240 rounds=20 names=29", "CLS_LOOP_ALIVE
   ok=true"]` — `LIFE_DONE case=clsloop` and any later teardown output are
   excluded. Without truncation the same log hashes `b21037deec6ef0e5`.
2. **The gate's own semantics** (committed fixture's `_cell_ok`/`_cell_text`
   called directly on synthetic results, `tools/scandiff.gd`): `rc=0` → ok,
   text `rc=0|134`; `rc=134` → **ok, identical text**; `rc=1` → not ok; marker
   absent → not ok + `mk=0`; a **non-`td`** cell with `rc=134` → not ok.
3. **A real abort, end-to-end.** Scratch copies of the committed fixture/probes
   (committed bytes untouched):
   - `OS.crash()` **after** the marker → the fixture prints the *pinned* cell
     text on all three backends and the arm **PASSES**; instrumenting the
     scratch fixture to print the raw rc shows **`RAWRC clsloop@gp rc=134`**
     (jolt, dummy likewise).
   - `OS.crash()` **before** the marker → `mk=0`, `beq=0`, arm **FAILS**.
   - the same post-marker abort with the `td` flag **removed** → `rc=134`
     printed plainly, different sha, `beq=0`, arm **FAILS** — the tolerance is
     scoped to exactly this one cell.
   - the fixture's own spawn shape, run through Godot's own
     `OS.get_process_exit_code` on a crashing child: **rc=134 in 8/8 spawns**,
     and 10/10 through a Python re-run of the same command.
   - the fixture's own probe (`r99b_life.gd --case=clsloop`) prints
     `made=340 skipped=240 rounds=20 names=29` in **6/6 fresh processes** and
     in **15/15 battery children**; the author's four instances agree.
   - residual (INFO, §8 F3): a *synthetic* shape whose inner command is itself
     a shell (`timeout -s KILL 5 sh -c 'kill -ABRT $$'`) is reported by Godot
     as rc=6, i.e. a bare signal number — outside the lattice's spawn shape,
     and the safe direction (it would fail closed, not pass silently).

## 5. Scanner differential

`tools/scandiff.gd` executes the **committed** fixture's own `_scan_lines`
(scratch copy of the committed bytes; the five regexes re-created because
`instantiate()` bypasses `_initialize`) over 13 synthetic streams: banner/blank,
the Jolt warning pair complete and split, all five masks, allowlisted
`ERROR` hit/miss for `ppos`/`dupn`/`badstate`, `SCRIPT ERROR`/`Parse
Error`/`handle_crash`, ObjectDB-leak with and without the `leak` allowlist,
and the `td` truncation pair. `tools/scandiffcmp.py` compares kept lines, sha,
`w`, `ee`, `ue` against this seat's re-implementation: **13/13 agree**.

## 6. Does the gate bite? (scratch-copy mutations)

| experiment | result |
|---|---|
| control: committed bytes, `--arm=order` | prints the pinned marker **exactly** |
| M1 probe prints `x_pf10=9.9999` | row **differs** (hashed value moved) |
| M2 `_srv_re` mask removed in the fixture | `ut_scope` row **differs** (sha moves) |
| M3 `push_error()` injected into a probe | arm **FAILs** (`ue` non-empty) |
| M4 final marker suppressed | arm **FAILs** (`mk=0`) |
| M5 extra stdout line inside the hashed stream | row **differs** (sha moves) |

Hygiene complements: `timeout -s KILL 14` per child + a 14 s batch deadline +
`OS.kill` on stragglers; `CHUNK = 8` (**max 8 concurrent `timeout` children + 1
parent observed** by polling `ps`); child dirnames validated (rejects `..`, `/`,
`\`, `:`, non-charset) and namespaced by parent pid; `_cell_ok` is fail-closed
on `ue`/rc/marker; no `user://` writes and no user-dir seeding anywhere in the
fixture or the six probes; no `if false`/`or true`/TODO/FIXME in any committed
r99 file; 0 `.godot` minted in **1,206 r99 child dirs** (4 full-size battery scratches
× 183 + 4 single-arm batteries × 27 + 2 own runs × 183).

**One methodological hazard this seat hit and corrected** (evidence-quality
note, not a landing defect): capturing a child's stdout and stderr in
**separate pipes** reorders the hashed stream for the **18 cells that carry an
engine diagnostic line** (`wire`, `pposerr`, `ghostpath`, `dupnode`,
`dupstate`, `badstate` × 3 backends). This seat's first own-driver pass showed
exactly those 18 cells differing from the pins with an *identical masked line
multiset*; switching to the fixture's single-fd `> log 2>&1` redirection
reproduced **all 183 pins** (and the isolated single-cell re-runs had already
reproduced the pins 3/3). The pins are therefore sound for any harness that
redirects both streams to one fd, as the fixture does.

## 7. The encoded laws, re-measured with this seat's own probe

`tools/vprobe.gd` is this seat's own code on its own rig (not the fixture's
probes), run at `--fixed-fps 60` in fresh projects on all three backends:

```
L1A_PROVIDER_FIRST actor=(0.0000,0.0000,0.0000) tp=0.0000    # rejected, 1 ERROR line
L1B_RECEIVER_FIRST actor=(0.2667,0.0000,0.0000) tp=0.0667    # 4*tp exactly
L2_CLOCK rows=20 (x - 4*tp = +-0.0001 = printed-tp quantization on every frame)
L3_BLEND_READBACK 0.0000,0.2500,0.5000,0.7500,1.0000         # exact
L3_BLEND_POSE actor=(0.0000,0.6000,0.0000) tp=0.1500         # 4*tp at blend=1
L4_TIMESCALE plain=0.1333 scaled=0.2666 ratio=2.0000 expect=2.0
L6_PRE ball=(0.0000,3.0000,0.0000) -> L6_UT_BALL ball=(0.0000,0.0000,0.0000)   # zeroed
L7_ENABLED before=a node=a                                   # no auto-advance
L7_AUTO    before=a node=b                                   # condition fires
L8_CLSLOOP made=340 skipped=240
```

Backend parity: **21 of 22 output lines byte-identical on gp/jolt/dummy**; the
22nd is the `L8` census line, which varies run-to-run in *this* context (see
§8 F2) — no measured law moves.

## 8. Findings and remaining risks

- **F1 (INFO).** The fixture's own `PASS` is *not* the gate: M2/M5 show the arm
  printing `PASS` with a moved sha; the **battery row** is what reds, because
  `classify()` compares stdout exactly. Same structural point the r98 verifier
  recorded (F2 there); true as claimed at battery level, and the reason every
  cell text must stay byte-exact.
- **F2 (INFO).** `made=340` is a property of the *probe's process context*, not
  a context-free engine constant: this seat's independent re-implementation of
  the same 29-class round-major loop yields **340/240** in a bare deferred
  context (3/3) but **341/239** in some runs after a rig/tree sequence
  (same script, different preceding state). The pinned cell is stable in its
  own context — **6/6 fresh processes, 15/15 battery children, 4 author
  instances** — so the pin is sound; the number should not be quoted as an
  engine-wide census.
- **F3 (INFO, residual).** `OS.get_process_exit_code` mapping for *synthetic*
  shapes: a direct signal death reports 128+signum (134 for SIGABRT), but
  `timeout -s KILL N sh -c 'kill -ABRT $$'` reports **6** (bare signal number).
  The lattice's own shape (a crashing Godot under `timeout`) reports **134**
  (8/8), so the `td` set `{0,134}` covers the observed abort class; if a future
  abort ever surfaced as 6 the cell would **fail closed**, which is the safe
  direction. Recorded with exact commands in `corpus/live/r99-verifier/`.
- **F4 (INFO, prose).** The author's illustrative list of non-instantiable
  classes ("`AnimationNode`, `AnimationRootNode`, …") is half-right: this
  seat's census names the twelve as `AnimationMixer`, `AnimationRootNode`,
  `AnimationNodeBlend3`, `Add2`, `Add3`, `Sub2`, `Mix`, `Mix2`, `Mix3`,
  `Sync`, `Output`, `BlendSpace2D` — `AnimationNode` **is** instantiable. The
  count (12 → 340/240) is correct; only the example is imprecise.
- **F5 (INFO, host).** The host ran at load 52–83 with sibling lanes; the three
  `navagent3d_*` legacy rows flaked in full1 and the same class appears in the
  author's two earlier attempts. **No r99 row flaked in any of the 1,206 r99
  children this seat executed or re-derived.**
- **F6 (INFO).** The nine r99 rows were green in every battery instance this
  seat ran (3 r99-only, 4 single-arm, 1 full) and in all four of the author's
  plus the two partial attempts — 9/9 in **every** observation, i.e. across
  ~2,100 r99 child executions (1,206 of them this seat's own).
- **F7 (INFO).** The probeParent privilege was unused; no claim was left
  needing a bounded empirical probe.
- **F8 (INFO, portability).** The 18 diagnostic-bearing cells' sha is sensitive
  to how a harness captures stdout/stderr (§6). Any future lane that spawns
  these probes must redirect both streams to a single fd, as the fixture does,
  or those cells will not compare.

## 9. Blockers

**None.** No resume mutation was attempted (no `resume_continuity_v1`
preflight was requested or needed); no canonical-runtime judgment was made by
this seat; nothing was committed, pushed or deployed.

## 10. Provenance

This seat wrote only `corpus/live/r99-verifier/**` (gitignored scratch:
`tools/` — `vnorm.py`, `cellspec.py`, `rederive.py`, `specdiff.py`,
`mychild.py`, `sensitivity.py`, `scandiffcmp.py`, `scandiff.gd`,
`countcells.gd`, `census*.gd`, `orderprobe.gd`, `rcprobe.gd`, `vprobe.gd`;
`battery/` — 4 battery passes + 4 single-arm passes; `mine/`, `mine_rep2/` —
366 own children; `sens/`, `abrt/`, `crashprobe/`, `rcprobe/`, `census*/`,
`orderprobe/`, `countcells/`, `scandiff/`, `clsloop_rep/`, `vprobe/` —
experiments) and this report. No tracked file was created, modified or deleted;
no commit was made.

Reproduce the core evidence:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# 1. r99-only battery (9 rows, 183 children), twice
python3 corpus/fixtures/run_battery.py --runs corpus/live/r99-verifier/battery/onlyA \
  --only r99_animtree_core,r99_animtree_ut_scope,r99_animtree_ut_mech,r99_animtree_modes,\
r99_animtree_order,r99_animtree_sm_adv,r99_animtree_sm_misc,r99_animtree_silent,r99_animtree_life
# 2. re-derive all 183 cells from the scratch with this seat's scanner
cd corpus/live/r99-verifier/tools
python3 rederive.py ../battery/onlyA/*/scratch          # checked=183 problems=0, beq 122/122
# 3. own driver + own scanner (183 children with real exit codes)
python3 mychild.py ../mine all && python3 rederive.py ../mine
# 4. does the gate bite
python3 sensitivity.py
```
