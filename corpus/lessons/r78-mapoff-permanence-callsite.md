# R78 — inactive-map permanence is a bounded measured regime (+600f, no late flush); the callsite pair is a sample-base shift, not an absolute latency (Godot 4.7.2 headless)

## Decision and evidence

`map_set_active(false)` is not "stale forever" as a claim of faith — it is a
measured regime with a checked falsifier: on the link-kill-under-mapoff arm,
every rung of a {0,1,2,5,15,20,45,60,90,120,180,300,301,600}-frame ladder
(fresh-rung: one process per wait, zero intermediate reads) serves the
committed bridge tuple byte-verbatim with `map_iter` frozen and `link_iter`
unstamped; the boundary seat pushed the same regime to **+1200f** (zero
`map_changed` emissions — the falsification bound extended 80x over r76's
+15f). A late flush — `map_iter` bump or any served-tuple change — would
have falsified permanent-stale at that rung and become the measured bound;
it never fired. Fresh-rung, per-frame-cumulative, and the fixture's own
cumulative-step scan all agree — under an inactive map there is no sync
phase for a read to race, so the r77 mark-vs-phase concern does not apply.

- **The queued write neither expires nor applies early.** After >=600f of
  inactivity, `map_set_active(true)` replays the standard window: the kill
  stamps at the first post-reactivation sync (link_iter bump at on+1,
  stale serve) and serves fresh at on+2 — restart-on-reactivation, not
  apply-on-write and not dropped-on-timeout; the on+2 edge is
  wait-length-INDEPENDENT (boundary resampled).
- **Setter order under inactivity is inert** (kill-then-off ≡ off-then-kill,
  r77 consistent), and `map_force_update` on an inactive map stamps the
  object's iteration (`link_iter=2`) without bumping `map_iter` or
  publishing — an explicit flush does not resurrect the regime; mid-wait
  force halves the post-on edge (boundary).
- **Callsite pair = a SAMPLE-BASE shift, deterministic.** The same
  `link_set_enabled(false)` issued inside a node's `_physics_process` joins
  the firing tick's own drain: tracked constants bound=1 (phys) vs
  bound=2 (coroutine-resume). The r78 critic's order_probe + phase
  evidence: BOTH writes apply at the same per-tick sync drain — the
  absolute write→apply latency is identical; the pinned difference is
  the reader's sample base (the phys arm's drain-await consumes the
  pending-state sample a parked coroutine can't observe). Fixture
  comments state the same-drain + sample-base semantics explicitly.
- Unlike the r77 forced-serve {1,2} jitter, the callsite shift is
  deterministic across rep triples — a structural phase difference, so
  it can be pinned as exact CASES constants per context. The
  {coroutine-resume, _physics_process} pair spans only the pre-sync
  band — the full callsite boundary is pre/post-sync {+2,+3}
  (idle/timer/`map_changed` sit in the deeper band; critic scope note).

## Authoring consequences

- "Permanent-stale" rows carry their measured bound: the falsifiable
  surface is `map_iter` + the served tuple per rung — the landed arm
  wires it (`_read_srv` gained the `map_iter` pin at the author's diff;
  per-rung map_iter/link_iter pins + a 600f `iter_watch` canary +
  boundary's `map_changed` monitor to 1200f, zero emissions).
- A CASES row's edge constants are callsite-context constants. A
  physics-callsite arm pins its own (one await shallower in its sample
  base) constants — same mechanism, different numbers; never reuse
  coroutine pins, and never read the pair as an absolute-latency fork.
- Fresh-rung vs cumulative only matters when a sync phase exists to race
  (active map + forced update). Under an inactive map both protocols are
  interchangeable — cheaper cumulative arms are safe there.

## Recheck conditions

Engine rebuild or async-iteration default change re-runs the ladder; the
regime is engine internals measured, not specified. The bound is +1200f
measured (boundary) on this build — "permanent" stays phrased as a bound;
a stronger claim needs engine-source evidence or a longer ladder.
The ladder arm uses the one-dict kill+off ordering (proven inert under
inactivity by four seats); the strictest kill-issued-while-already-off
ordering (`mut_map_cycle` shape) is an open refinement.
