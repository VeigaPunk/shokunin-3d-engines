# game-dev-3d round 78 — critic (seat: critic, host: devin)

Adversarial audit of the author's landed r78 diff. Canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` is the stale meta-worktree; its
`.shokunin/game-dev-3d` symlink resolves here — same as r75–r77 seats).
HEAD `71818b7` + uncommitted author work in the working tree:
`M corpus/fixtures/navagent3d_detour.gd` (+238/−5),
`M corpus/fixtures/run_battery.py` (+6/−0, one hunk). `git diff` saved
at `corpus/live/r78-critic/r78_tracked.diff`; the author's scratch copy
`corpus/live/r78-author/scratch/proj/navagent3d_detour.gd` is
byte-identical to the landed tracked file (verified `diff` = empty).
Godot `4.7.2.stable.arch_linux.ed1daf0bf`, 60 tps, Python 3.14.7.

**Headline: every measurable claim in the diff verified by direct
replay — the three new arms PASS with the declared constants,
byte-identical across reps, and the landed tree replays 176/176 with
all 173 prior rows field-identical to the frozen baseline. The
strongest counterexample available (the callsite pair measuring a real
latency difference) is refuted BY the pair itself in a way the comments
partially misstate: both contexts reach the same per-tick sync drain;
the −1 is observable-only. Two comment phrases read as an absolute
mechanism claim that the wave's own phase evidence falsifies —
fixable wording, not a rejectable measurement.**

## Verified on the landed tree (own runs this session)

- **All three new arms PASS, deterministic** — run directly against the
  author's staged fixture (== landed file), receipts
  `corpus/live/r78-critic/runs-authorstaged/`:
  - `mut_mapoff_ladder` → `steps=6 ... bound=5 groups=2 sizes=5,1`,
    **3/3 byte-identical** (md5 `15ab04ef…`), stderr empty, ~6.1s.
  - `mut_ctx_resume` → `bound=2 groups=2 sizes=2,1`, 2/2 identical.
  - `mut_ctx_phys` → `bound=1 groups=2 sizes=1,2`,
    **4/4 byte-identical** (md5 `274d35c7…`), stderr empty.
  Zero ObjectDB/RID leaks in the landed arms (the author's spike
  `r78a_probe.gd` leaks 3 RIDs at quit — spike-only, not in the diff).
- **Merged battery = landed fixture + landed CASES, 176/176** —
  `corpus/live/r78-critic/merged-fixtures/` (committed `corpus/fixtures`
  + the author's landed `navagent3d_detour.gd`; the `cp` caught the
  post-landing `run_battery.py`, confirmed by 176 cases and the three
  new rows present). Command:
  `python3 run_battery.py --godot /usr/bin/godot --runs <abs>/merged-runs
  --probe-failing --probe-crash-exit --probe-stream-attribution
  --probe-tree-timeout` → exit 0,
  `totals: cases=176 pass=176 fail=0 ordinary=131 negative_controls=45
  probes=4`, `seeds_unchanged: true`, `crash/stream/tree_probe_ok: true`,
  mutation probe `detected: true`. Receipt
  `merged-runs/20261014T122518308674Z/verdicts.json`.
  New rows' elapsed: ladder 6.06s (scout's ~6.3s prediction holds, well
  under the 20s case timeout), ctx_resume 0.95s, ctx_phys 1.02s.
- **173 prior rows byte-stable on the landed tree** — field-diff of my
  merged receipt vs the baseline seat's frozen receipt
  `corpus/live/r78-baseline/runs/20261014T120340433067Z/verdicts.json`
  on the 12 stable fields (`case, script, flags, expected_exit,
  actual_exit, kind, marker, verdict, reasons, stdout, stderr, error`;
  `command`/`elapsed_seconds` excluded): **173 common rows, 0
  mismatches; added rows = exactly the 3 new cases; missing = none**.
- **CASES diff is insertion-only** — `run_battery.py` +6 lines, one
  hunk at CASES:229; the three pinned markers are byte-identical to my
  measured stdout (compare `runs-authorstaged/*.stdout.txt`).

## Attack item (1): does {20,60,120,300}f probe permanence — what could flush between rungs? — CLOSED, no gap

The arm (`mut_mapoff_ladder`, fixture :2055–2118) kills+deactivates in
one dict, then samples at cumulative +20/+60/+120/+300f with per-rung
`srv_get {map_active:false, link_enabled:false, link_iter:1,
map_iter:2}` + served tuple + peek signature. Between-rung flush
mechanisms enumerated and excluded:

- **`map_iter` cadence / async iteration**: the iteration clock is
  monotone — a transient flush between rung samples cannot un-bump it,
  so ANY flush in (0, rung] is caught at the rung. Direct witnesses:
  my `iter_watch` arm (per-frame canary, 600 consecutive frames under
  off — receipt `runs/iter_watch.stdout.txt`) caught exactly one event:
  the f1 object-level apply (`link_en true→false`), **zero
  map_iter/link_iter bumps**. Boundary's `map_changed` signal monitor
  (one level deeper than the tuple) recorded **zero emissions to
  1200f** — the map is removed from sync entirely; no cadence exists.
- **GC / queue expiry**: RIDs and nodes are held in `owned`/`owned_nodes`
  for the arm's life; nothing collectible. The queued kill survives:
  +600f (scribe fresh-rung, this seat's `iter_watch`/`ladder_*`),
  +1200f (boundary) — no expiry, no overflow.
- **The arm's own reads as a perturbation** (r77 mark-vs-phase
  concern): forcing reads per rung are proven pure under inactivity —
  my `ladder_inst` (forcing read at every rung) ≡ `ladder_pass`
  (peeks only) through 600f, field-identical; boundary `read=every`
  120 consecutive forcing reads, zero events, on+2 unchanged; scribe
  `cuml_w*` flips=0. There is no sync phase to race.

Falsifier wiring is complete: a map_iter bump, link_iter stamp, or
served-tuple change at any rung fails that step and names the
cumulative wait as the measured bound — the declared falsification
shape lands exactly as designed.

## Attack item (2): does permanent-stale need the reactivation arm? — INCLUDED, correct edge

The arm's steps 5–6 reactivate: `{map_active:true}, wait:1` pins
`link_iter:2, map_iter:2` (queued kill stamped at the first
post-reactivation sync, rebuild not yet landed) then `wait:1` pins
`map_iter:3` + the fresh dead clamp `(2.5,0,4.0) reachable=false`.
The queued write replays the normal +2f edge — never dropped, never
early, wait-length independent: identical tail in my
`react_quick` (+5f off), `react_pass` (+300f passive),
`react_inst` (+300f instrumented), `cs_mapoff`, `double_cycle`
receipts and the author's own spike (`mapoff.stdout.txt` react+1/2).
The bare-cycle control also holds: a bare off→on with no queued write
bumps nothing (`double_cycle` `after_cycle1` map_iter=2 link_iter=1 —
the bumps belong to the queued write's flush, not reactivation itself,
as the author's comment :238–241 correctly states).

## Attack item (3): does the callsite pair isolate callsite? — PARTIALLY; two mechanism-wording defects

**What the pair pins is an observable signature, not a latency
difference.** The author's `mutate_phys` path (`_run_steps` :2404–2408)
appends the dict to `PhysMutator.pending` at the coroutine's
physics_frame-resume (B-phase of tick t); the node's `_physics_process`
drains it at C-phase **of the same tick**; both the B-context
`mutate` write and the C-context `mutate_phys` write apply at
**sync(t)** — the identical per-tick drain. Rebuild at sync(t+1),
fresh serve at reads of t+2 — absolute write→serve latency is **+2 for
both contexts**. Evidence chain (all this wave, mostly this seat's own
receipts):

- `runs/order_probe.stdout.txt`: `ORDER write B pf=31` →
  `C _physics_process pf=31` → `F _process pf=31` → resume@pf=32 reads
  `link_iter=2` — the B-issued write applied at sync(31), the same
  tick. Boundary's `phase_probe` independently bisects it:
  `link_iter=1` at C@31, `link_iter=2` at F@31 — the apply stage runs
  between `_physics_process` and idle `_process` of tick 31.
- `runs/cs_flag.stdout.txt` — the direct test of the author's exact
  mechanism (flag armed by the coroutine at B, drained by the node's
  next `_physics_process`): fires at C of the arming tick, applied by
  the next resume, serve edge identical-in-absolute to `cs_self`. The
  confound predicted in my probe comments ("a flag-armed write lands
  in the same inter-flush gap and the +1 shift collapses") did NOT
  occur — arming at B(t) drains at C(t), still pre-sync.
- `runs/cs_idle.stdout.txt`: the genuinely different context —
  `_process`-phase write missed sync(t)'s apply → **+3 absolute**.
  Boundary's 9-context table agrees: two latency bands
  {pre-sync B/C/D + inside-`path_changed`: +2; post-sync
  idle/`process_frame`/timer + in-emission `map_changed`: +3}.

So the pair's `bound=2` vs `bound=1` is a **sample-base shift**: the
phys arm's drain-await consumes exactly one resume, and the coroutine
cannot observe a mid-tick pending state while parked — the phys arm's
first sample is already +1 deep vs the co arm's same-resume w0. The
author's header comment knows this (":253–255: shifts one await
shallower **in the arm's own sample base**") — but two phrases state
the wrong mechanism:

- **Defect A (moderate, wording)**: header :249–252 — "the write lands
  in that tick's server drain … while the identical coroutine-issued
  'mutate' still reads pending … **and applies at +1**". The parallel
  construction claims the coroutine write lands in a *later* drain.
  Measured: it lands in the same sync(t) drain; it is *observed*
  applied at +1 by the next resume. As written, the comment asserts an
  absolute apply-time difference that this wave's phase evidence
  falsifies.
- **Defect B (minor, wording)**: PhysMutator class comment :268 — "one
  queue-stage deeper than a 'mutate' dict". There is no deeper
  server-side queue: the `pending` list is a client-side handoff; the
  write enters the same sync drain at the same stage boundary. Reads
  as "drains one tick later" — the opposite of what the code does
  (same-tick drain, correctly described one clause earlier).

**Scope note for the judge (not a defect of the declared work):** the
{coroutine-resume, `_physics_process`} pair sits entirely inside the
pre-sync +2 band — it does not span the real callsite boundary
(pre-sync vs post-sync/idle, {+2,+3}). The declared axis asked for
exactly this pair and it is landed honestly; the durable lesson is
that "callsite" matters at the sync boundary, not the resume-vs-callback
distinction — worth carrying into the r78 lesson wording.

**Design strength worth crediting**: the drain-await handshake
(`while not phys_mut.pending.is_empty(): await physics_frame`)
guarantees the phys arm's first sample is post-fire — avoiding the
pre-fire collapse my `cs_prefire` arm demonstrates (a phys arm whose
first sample precedes the fire reads pending and measures nothing of
callsite). The wait:0 pin `link_iter:2` is a real mechanism test, not
an assumption.

## Attack item (4): honest reporting if stale breaks — the arm falsifies at the rung

Each rung's srv_get + tuple + peek pins make a late flush fail the
step; the battery fails the case at that rung index — the cumulative
wait is the measured bound, exactly the declared falsification->bound
contract. The pins are honest assertions of state (`link_iter:1`
asserts the write applied-but-unpublished — itself a flush witness),
not outcome-only checks.

## Byte-stability / integration audit

- Diff is purely additive: PhysMutator spawned only when an arm's
  steps contain `mutate_phys` (:403–414), the `mutate_phys` block no-ops
  otherwise, `_mut_list`/`_run_steps`/`_read_srv` changes are defaulted
  params and an opt-in `map_iter` key; `_final_srv_state` fold extends
  to the new channel (:2555) preserving the honesty gate for phys
  dicts. The 5 deleted lines are mechanical signatures only.
- Result: zero behavioral change for the 173 prior arms — confirmed by
  the merged battery field-diff (0/173 mismatches).
- `map_iter` added to `_read_srv` (:2519–2523) — closes the
  scout/reviewer-flagged falsifier gap.

## Coverage footnotes (non-blocking)

- The ladder arm uses the **one-dict kill+off** ordering
  (≈`mut_ord_kill_mapoff`), not the strictest
  kill-issued-while-already-off (`mut_map_cycle` shape). Ordering is
  proven inert under inactivity by four seats (scribe `kill_off`≡
  `off_kill`; my `cs_mapoff` — a `_physics_process` kill under an
  already-inactive map — identical freeze + on+2 replay; boundary
  same-turn arms). The declared rung set falsifies the claim either
  way.
- Measured bound on the landed arm is exactly the declared +300f;
  sibling evidence extends the same regime to +600f (scribe/this
  seat) and +1200f (boundary) — the arm's comment correctly scopes
  "through +300f".
- Environment note for the verifier: wave-concurrent battery runs
  flaked 2–3 unpinned moving-agent rows this round (scribe run1: 3;
  this seat's earlier run1: `navagent3d_retarget_fixed`,
  `navagent3d_follow`) — each re-passed standalone and both quiet runs
  were clean (scribe run2 173/173; my merged run 176/176). Load
  jitter on motion-integrating cases, orthogonal to this diff.

## Findings → smallest safe correction

| # | severity | finding | correction |
|---|---|---|---|
| A | low (wording, tracked file) | header :252 "applies at +1" reads as the co write landing a drain later than the phys write — falsified: same sync(t) drain (order_probe, phase_probe, cs_flag) | rephrase: "…reads pending at its write turn and is first *observed* applied at +1 — both writes apply at the same per-tick sync drain; only the reader's sample base shifts." |
| B | low (wording) | PhysMutator :268 "one queue-stage deeper" — no deeper server queue exists; same drain, one intra-tick phase later client-side | "…through the host's _apply_mutation — queued one intra-tick phase later than a resume-issued 'mutate' but landing in the same per-tick sync drain." |
| C | note (scope) | pair spans only the pre-sync band; the real callsite boundary is pre/post-sync {+2,+3} (idle/timer/`map_changed` deeper) | carry "two-band" phrasing into the r78 lesson; an idle-context arm would pin the deeper band if a later round wants it |
| D | note (coverage) | ladder arm uses one-dict kill+off, not strict kill-under-off | optional: comment the ordering equivalence (4-seat converged) or add the mut_map_cycle-ordered variant later |

## Evidence index (this seat's write scope)

- `corpus/live/r78-critic/r78_tracked.diff` — `git diff` of the landed
  fixture.
- `corpus/live/r78-critic/runs-authorstaged/` — 8 arm replays on the
  landed file: 3× `mut_mapoff_ladder` (md5 `15ab04ef…` identical),
  4× `mut_ctx_phys` (md5 `274d35c7…` identical), `mut_ctx_resume`;
  all stderr byte-empty.
- `corpus/live/r78-critic/merged-fixtures/` — committed corpus +
  landed fixture + landed `run_battery.py` (post-landing copy);
  `merged-runs/20261014T122518308674Z/verdicts.json` — **176/176 PASS**,
  `seeds_unchanged: true`, 4 probes green; 173-row field-diff vs
  `corpus/live/r78-baseline/runs/20261014T120340433067Z/verdicts.json`
  = 0 mismatches, added = the 3 new cases.
- `corpus/live/r78-critic/scratch/r78c_mapoff.gd` + `runs/` —
  18 probe arms (this seat's earlier instance, all exit 0):
  `iter_watch` (per-frame 600f canary, zero iter bumps),
  `ladder_{inst,pass}` (instrumented≡passive to 600f),
  `react_{quick,pass,inst}` (+2 replay wait-independent),
  `cs_{co,self,flag,prefire,idle,defer,mapoff}` (callsite family),
  `order_probe`/`idle_count` (intra-tick phase order),
  `force_mapoff`, `region_mapoff`, `double_cycle`.
- `corpus/live/r78-critic/battery-runs/` — earlier full battery:
  run1 171/173 (two moving-agent flakes under wave load, re-passed),
  run2 **173/173** on committed HEAD; `node/` six three.js suites
  **31/31** all `seedsUnchanged: true`.
- Sibling evidence cited as data: `reports/round-78/r78-{baseline,
  scout,scribe,boundary,reviewer}.md` — convergent on every measured
  axis this report relies on (bound +300f/+600f/+1200f, on+2 replay,
  two-band callsite model, `_read_srv` map_iter gap — closed by the
  diff).

Audit stops here. The diff's measurable claims hold; the only
corrections requested are two mechanism-wording fixes in comments the
diff itself adds — no axis regression, no falsified claim.
