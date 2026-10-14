# game-dev-3d round 78 — scribe report (seat: scribe, host: devin)

Declared lane axis (from dispatch, verbatim): "pin the `map_set_active(false)`
permanent-stale claim as a bounded measurement — the r76 'stale forever' is
measured only to +15f (r76-adjudicator: 'not a proof of unboundedness').
Ladder the inactive-map wait {20,60,120,300}f on the link-kill-under-mapoff
arm: falsifiable claim is permanent-stale — a late flush (map_iter bump,
tuple change) at ANY rung falsifies it and becomes the measured bound. Plus:
pin the callsite shift as tracked CASES — r76-critic's `_physics_process`
+1-tick finding (bb_physmut) is scratch-level only; land the same link-kill
mutation issued from {coroutine-resume, _physics_process-callsite} contexts
as paired arms with edge-shift receipts. All 173 prior rows + probes + Node
suites byte-stable."

Scribe duty per brief: independently re-run the author's permanence ladder +
callsite arms under `corpus/live/r78-scribe/` — own harness (fresh-rung vs
cumulative where it matters — the r77 lesson), own wait values incl.
off-grid probes; verify or falsify permanent-stale vs late flush + the +1
callsite shift; verify prior-row byte-stability; draft the lesson +
LOG.md entry. Report-only; not the judge. Leaf lane: no subagents, no
commits, no tracked writes outside this report.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` is the stale worktree — its
`.shokunin/game-dev-3d` symlink resolves here; same finding as r75–r77).
Engine `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, Python
3.14.7, Node v24.21.0, 60 tps pinned (`project.godot` sha256
`1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23` —
byte-copied verbatim into my scratch).

## Landed-state at measurement time

HEAD `71818b70180d14c51d197a75253d8839e451c08b` (r77 report-last). Committed
fixture `navagent3d_detour.gd` sha256
`de9ef7cf61b91073c058d77e3e7835820e3914bbc203a8cd870f1b1a11bc14d6`,
`run_battery.py` sha256 `92c5ad87df04d8ed247ced3b83d06d0e384e28fbaef0b22a161f280deb64b661`
(173 CASES = the r77 set). **The author's r78 tracked CASES had NOT landed
when this seat's measurements ran** — `git status` clean except sibling
`reports/round-78/*.md` drafts; `corpus/live/r78-author/` held only a spike
in progress (`scratch/proj/r78a_probe.gd`, whose `mapoff` receipt already
shows the same react+2 fresh edge I measure — convergent). What I verified
independently is the declared arm shape itself: the link-kill-under-mapoff
permanence ladder and the callsite pair, on the tracked arm's own geometry
but my own harness. If the author's CASES land after this report, the
committed-arm replay check remains open for the verifier lane.

## Own measured evidence — same bridge geometry, own harness, 56 receipts

Probe `corpus/live/r78-scribe/scratch/r78s_perm.gd` sha256
`963d2d993edf4da57ed37905c2ba36205b42ad02ee095ff7854d12a70f80a2d1`,
extends-SceneTree, world = the tracked arm's bridge (corridor + island C +
server link `(2.5,0,3.5)→(2.5,0,5.5)`, agent `S=(0.5,0,0.5)` → `T2=(2.5,0,5.5)`,
pdd/tdd 1.0, 30f settle). Deliberately identical geometry — the declared
claim is pinned to that arm, so my rungs compare row-for-row; the
independence is in the harness (my own instrumentation reads `map_iter`,
`link_iter`, `link_en`, `map_active` server truth plus peek + forcing
tuple per sample — the falsifier surface).

Runner `run_arms.sh` sha256 `cc09d292c057f51368f86f9f1aecf2e47f3cf09bb7317a9bd09a63dda1619e6d`.
**56 run receipts under `corpus/live/r78-scribe/runs/`** — every `.exit`
file = 0, every `.stderr.txt` byte-empty (my `_teardown` frees all RIDs +
nodes; no ObjectDB leaks). Repeatability: `rep_{a,b,c}` triples on
`perm_w300`, `co_w1`, `co_w2`, `ph_w3` are **byte-identical** past the
engine banner.

## (1) Permanence ladder — CONFIRMED at every rung, measured bound +600f

Fresh-rung (one process per wait, zero intermediate reads — the r77
fresh-vs-cumulative lesson applied where it matters): `map_set_active(false)`
then `link_set_enabled(false)` (the write queued under the inactive map,
`off_kill` order), await exactly N `physics_frame`s, one peek + one forcing
read + server truth:

| wait (frames) | verdict | map_iter | link_iter | served tuple |
|---|---|---|---|---|
| 0, 1, 2, 5, 15 | STALE | 2 (frozen) | 1 | committed bridge, reachable=true |
| **20, 60, 120, 300** (declared) | STALE | 2 | 1 | committed |
| 45, 90, 180, 301, **600** (off-grid) | STALE | 2 | 1 | committed |

Every rung: `PROBE verdict | wait=N order=off_kill cls=STALE
map_iter_delta=0 stale=true`. At w0 the writes are still queued
(`link_en=true`, `map_active=true` — both getters deferred); from w1 on
`link_en=false`/`map_active=false` applied to the objects while
`link_iter`/`map_iter` never stamp — the write landed but was never
published. **No late flush at any rung: the r76 "+15f" ceiling extends to a
measured bound of +600f (10 s at 60 tps), 40× the prior evidence.**

- **Setter order inert** (r77 recheck): `kill_off` at w20/w300 — identical
  STALE receipts (`perm_ko_w*.stdout.txt`).
- **Cumulative** (`cuml_w{20,60,300}`): forcing read EVERY physics frame —
  `flips=0`, `map_iter_delta=0`. Repeated forcing reads against the inactive
  map perturb nothing; there is no sync phase for a mark-vs-phase race to
  exist in (contrast the r77 `map_force_update` link jitter, which needs a
  live sync to race). Fresh-rung and cumulative protocols agree.
- **Fixture-shaped scan** (`scan_mixed`): one process, cumulative sparse
  rungs {0,1,2,20,60,120,300} — all STALE, delta 0.
- **Active-map control** (`ctl_w{0,1,2,20,300}`): same kill, map active —
  stale at w0/w1, FRESH at w2/20/300. The kill works and the ladder is not
  vacuously stale.

### Extra falsifier probes (beyond the brief's minimum)

- `perm_fu_w{20,300}` — `map_force_update` on the INACTIVE map at the
  window's midpoint: stamps the queued kill (`link_iter=2` at the fu read)
  but `map_iter` stays 2 and the served tuple stays STALE through the rung.
  An explicit flush call does not resurrect the map — consistent with r77's
  "FU under mapoff applies S, serve frozen," now extended to a mid-window
  force inside a long inactivity.
- `perm_mid_w{20,300}` — the kill issued at N/2 inside the inactivity
  window (discriminates time-since-deactivation from time-since-write):
  STALE, delta 0.
- **Reactivation tails** (`perm_tail_w{20,120,300,600}`): after the rung,
  `map_set_active(true)` → on+0 still reads `map_active=false` (reactivation
  getter itself deferred), on+1 `link_iter=2` (queued kill stamped at the
  first post-reactivation sync) serve still stale, on+2 `map_iter=3` serve
  FRESH clamp `[(S),(2,0,1),(2.5,0,4.0)]` reachable=false. The queued write
  survives ≥600f of dead time and flushes at the normal +2f edge — never
  dropped, never early.

## (2) Callsite pair — +1-tick shift CONFIRMED (both edges)

Same mutation `link_set_enabled(false)`:

| context | write site | getter edge | serve edge |
|---|---|---|---|
| coroutine-resume (the fixture's step context) | `_run`-family resume after `physics_frame` | +1f (`link_iter=2` first read at w1; w0 still `iter=1`) | **+2f** (STALE w0/w1, FRESH w2–w4) |
| `_physics_process` callback | inner `TickWriter` node fires inside its 2nd `_physics_process` | **same tick** (`link_iter=2, en=false` already applied at the firing tick's boundary read — ph_w2/t1) | **+1f past the firing tick** (STALE at firing-tick read, FRESH at ph_w3 ≡ t2) |

Receipts: `co_w{0..4}`/`co_scan` (cumulative per-frame truth+serve),
`ph_scan` (mutator timeline: fired at its tick 2; t1 truth
`link_iter=2,en=false` map_iter still 2 → stale serve; t2 `map_iter=3` →
fresh clamp), `ph_w{2..5}` fresh-rung. The exact r76-critic `bb_physmut`
shape reproduced on a fresh harness: a physics-callsite setter joins the
firing tick's own drain — both edges shift one tick earlier. Deterministic
across rep triples (byte-identical); **no spread observed** (contrast the
r77 forced-serve {1,2} jitter — this shift is not a race, it's a fixed
phase difference).

## (3) Byte-stability — 173/173, 4 probes, Node 31/31

- **Full battery** `python3 corpus/fixtures/run_battery.py --godot
  /usr/bin/godot --runs <abs>/corpus/live/r78-scribe/runs-battery2
  --probe-failing --probe-crash-exit --probe-stream-attribution
  --probe-tree-timeout` → `BATTERY EXIT=0`, `totals: cases=173 pass=173
  fail=0 ordinary=128 negative_controls=45 probes=4`, `seeds_unchanged:
  true`. Receipt `runs-battery2/20261014T120943406099Z/verdicts.json`
  (godot_version `4.7.2.stable.arch_linux.ed1daf0bf`; all four probe
  receipts verdict=PASS). Since HEAD is the r77 tree, this verifies all 173
  rows (incl. the r78-relevant `mut_map_off`, `mut_map_cycle`,
  `mut_ord_{kill_mapoff,mapoff_kill}`, `mut_ladder_*`) byte-stable on the
  pre-r78 state.
- **First battery run (honest record)**: `runs-battery/20261014T120524364454Z`
  finished `pass=170 fail=3` — `navagent3d_retarget`, `navagent3d_retarget_fixed`,
  `navagent3d_follow` each missed their marker by a small motion delta
  (e.g. `before=1.754246` vs pinned `1.730676`). All three are
  motion-accumulating cases; the deltas pattern-match a one-tick-late async
  map iteration under the wave's concurrent host load (sibling Godot
  processes were running). Each re-run **standalone passed 3/3** and the
  full second run passed 173/173 — recorded as transient load jitter on the
  un-pinned moving-agent rows, not a regression. Recheck flag, not a claim
  of flakiness by fiat: two of the three are `navagent3d_*` cases whose
  markers integrate agent motion over 90–120 callbacks.
- **Node**: six three.js suites under `corpus/live/r78-scribe/node/` —
  cases 3/3, layer 4/4, order 9/9, camera 5/5, ortho 5/5, ray 5/5 →
  **31/31**, `seedsUnchanged: true` in every `run_*.json`.

## Cross-seat convergence map (sibling artifacts = data, cited verbatim)

| claim | scout | author (in-flight spike) | this seat |
|---|---|---|---|
| map_off permanent-stale through 300f | `r78_mapoff_lad` + `r78_offkill_lad` PASS through 300f (both orderings) | probe shows react+2 fresh edge | CONFIRMED fresh-rung to **+600f**, 14 rungs + cuml + scan + tails |
| callsite −1 tick | `r78_csite_ph` bound=1 vs mut_ladder_link bound=2, 4/4 reps | — | CONFIRMED — getter 1→0, serve 2→1, byte-identical reps |

Reviewer (`r78-reviewer.md`) independently confirmed the committed base:
173/173 + 4 probes + Node 31/31, 163 prior rows 0-diff vs r76-verifier
receipt. Baseline froze `frozen-tree.tar` and replayed.

## Draft: `corpus/lessons/r78-mapoff-permanence-callsite.md`

```markdown
# R78 — inactive-map permanence is a bounded measured regime (+600f, no late flush); the callsite shift moves BOTH edges −1 tick (Godot 4.7.2 headless)

## Decision and evidence

`map_set_active(false)` is not "stale forever" as a claim of faith — it is a
measured regime with a checked falsifier: on the link-kill-under-mapoff arm,
every rung of a {0,1,2,5,15,20,45,60,90,120,180,300,301,600}-frame ladder
(fresh-rung: one process per wait, zero intermediate reads) serves the
committed bridge tuple byte-verbatim with `map_iter` frozen and `link_iter`
unstamped. A late flush — `map_iter` bump or any served-tuple change — would
have falsified permanent-stale at that rung and become the measured bound;
it never fired. The measured bound on this build is **+600f** (10 s at
60 tps), up from r76's +15f. Fresh-rung, per-frame-cumulative, and the
fixture's own cumulative-step scan all agree — under an inactive map there
is no sync phase for a read to race, so the r77 mark-vs-phase concern does
not apply.

- **The queued write neither expires nor applies early.** After ≥600f of
  inactivity, `map_set_active(true)` replays the standard window: the kill
  stamps at the first post-reactivation sync (link_iter bump at on+1,
  stale serve) and serves fresh at on+2 — restart-on-reactivation, not
  apply-on-write and not dropped-on-timeout.
- **Setter order under inactivity is inert** (kill-then-off ≡ off-then-kill,
  r77 consistent), and `map_force_update` on an inactive map stamps the
  object's iteration (`link_iter=2`) without bumping `map_iter` or
  publishing — an explicit flush does not resurrect the regime.
- **Callsite is a fixed −1 phase, not a race.** The same
  `link_set_enabled(false)` issued inside a node's `_physics_process` joins
  the firing tick's own drain: getter edge 1→0 (`link_iter` stamped at the
  firing tick's boundary read), serve edge 2→1 (fresh one await past the
  firing tick). Coroutine-resume context keeps getter +1 / serve +2. Unlike
  the r77 forced-serve {1,2} jitter, the shift is deterministic across
  rep triples — it is a structural phase difference (a `_physics_process`
  write precedes the tick's queue drain; a coroutine-resume write misses it),
  so it can be pinned as exact CASES constants per context.

## Authoring consequences

- "Permanent-stale" rows should carry their measured bound: the falsifiable
  surface is `map_iter` + the served tuple per rung (the committed
  `_read_srv` lacks a `map_iter` key — `navagent3d_detour.gd:2278-2294`
  knows `link_iter` but not `map_iter`; the scout flagged the same gap — so
  the tracked arm needs it or an equivalent witness to pin "map_iter bump"
  as the falsifier).
- A CASES row's edge constants are coroutine-context constants. A
  physics-callsite arm must pin its own (one tick shallower) constants —
  same mechanism, different numbers; never reuse coroutine pins.
- Fresh-rung vs cumulative only matters when a sync phase exists to race
  (active map + forced update). Under an inactive map both protocols are
  interchangeable — cheaper cumulative arms are safe there.

## Recheck conditions

Engine rebuild or async-iteration default change re-runs the ladder; the
regime is engine internals measured, not specified. The bound is +600f on
this build — a stronger "permanent" claim needs either engine-source
evidence or a longer ladder, and should stay phrased as a bound.
```

## Draft: LOG.md round-78 entry

    ## Round 78 — devin host — map_set_active(false) permanence bounded to a measured +600f (no late flush, queued write survives); callsite pair pinned: _physics_process write shifts getter+serve edges −1 tick
    - Declared (dispatch brief): ladder the inactive-map wait
      {20,60,120,300}f on the link-kill-under-mapoff arm — falsifiable claim
      permanent-stale, a late flush (map_iter bump, tuple change) at any
      rung falsifies and becomes the bound; plus pin the r76-critic
      `_physics_process` +1-tick callsite finding (bb_physmut) as tracked
      CASES — same link-kill issued from {coroutine-resume,
      _physics_process} contexts with edge-shift receipts; all 173 prior
      rows + probes + Node suites byte-stable.
    - Wave `shokunin-train-20261014-w9`: leaf set reports/round-78/r78-*.
      At scribe-measurement time HEAD remained 71818b7 (r77 report-last);
      the author's tracked CASES were still in spike
      (corpus/live/r78-author/scratch/proj/r78a_probe.gd) — committed-arm
      replay deferred to the verifier lane.
    - Scribe independent harness (`corpus/live/r78-scribe/`, 56 receipts,
      all exit 0, stderr-empty, rep triples byte-identical): permanence
      CONFIRMED — every rung {0..600}f STALE, map_iter frozen, link_iter
      unstamped, measured bound +600f (was +15f); cumulative and
      fixture-shaped scan identical (0 flips); tails prove the queued kill
      flushes at on+2 after ≥600f; force_update on the inactive map stamps
      the object iter without publishing; setter order inert.
    - Callsite pair CONFIRMED: coroutine getter +1 / serve +2 vs
      _physics_process getter same-tick / serve +1-past-firing — a fixed
      −1 phase, deterministic (not the r77 {1,2} race).
    - Battery on committed tree: run2 173/173 + 4 probes + seeds_unchanged
      (run1 flaked 3 moving-agent rows under concurrent wave load —
      navagent3d_retarget{,_fixed}, navagent3d_follow — each re-passed 3/3
      standalone and clean in run2; recorded as load jitter, flagged for
      recheck). Node six suites 31/31.

## Residual risks / recheck conditions

- The bound is a measured +600f on this build/host — "permanent" remains a
  bounded claim by design; the falsifier (map_iter bump or tuple change at
  any rung) is what the tracked arm should pin, and my probe's receipt shape
  (`PROBE verdict … map_iter_delta`) is the form it takes.
- My `TickWriter` fires at its 2nd `_physics_process` (the r76-critic
  shape). The edge-shift constants were identical across every run; a
  different fire tick lands the same −1 relative shift.
- The three run-1 battery flakes are attributable to wave-concurrent load
  (async map iteration a tick late); if they recur on a quiet host they
  deserve a jitter audit, not a shrug.
- Author's landed CASES pending at report time: my verification is of the
  declared arm shape on the tracked geometry; the committed-row replay is
  the next seat's check.
