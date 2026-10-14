# R77 — mutation apply-order: doomed-RID voiding, force-update jitter, verdict groups (Godot 4.7.2 headless)

Sources: `reports/round-77/r77-{author,scout,boundary,critic,reviewer,verifier}.md`;
`corpus/fixtures/navagent3d_detour.gd` `_mut_list`/`_apply_mutation`/`_tuple_sig`;
work commit `35dfbe2` (+ hygiene `565318c` per-class force-edge comment fix);
boundary raw runs `corpus/live/r77-boundary/runs/ord{2,3,3x,3s,4,f}_*.stdout.txt`;
verifier own-geometry probe `corpus/live/r77-verifier/scratch/proj/r77v_probe.gd`
(10-rep force_ladder + 5-rep ctl_ladder).
Prior lessons extended: `r76-*.md` (sync windows {link:2,region:3,map_off:∞,agent:0}).

verified-at: 2026-10-14, Godot `4.7.2.stable.arch_linux.ed1daf0bf`,
Node v24.21.0, Linux x86_64, 60tps-pinned.

## Apply-order is load-bearing only through RID lifecycle

Mechanism is **dead-write voiding by RID rebinding** (critic correction:
not an "emergent seam" — which RID receives the setter decides whether
the write survives):

- `mutate` accepts an array of sub-dicts; each sub-dict runs through
  `_apply_mutation`'s unchanged fixed order (delete → recreate →
  region xform/enabled/layers → link enabled/layers/start/end →
  agent → map_force → map_active) — `_mut_list` fans the sequence out.
- **Doomed-RID class**: a transform ordered BEFORE delete/recreate dies
  with the freed RID — `mut_ord_xform_renew` serves the unmoved corridor
  + srv_get `region_transform=(0,0,0)`; `mut_ord_renew_xform` serves the
  moved corridor + `(5,0,0)`. Same setter multiset, different served
  state. Verifier reproduced on own geometry both directions.
- Boundary extended to all six permutations of {Rdel,Rrec,Rx03}: three
  observably distinct post-sync states (moved / unmoved / region-gone —
  `Rrec→Rdel` frees the NEW region). Four-op perms: disable ordered
  after recreate lands on the new region; ordered before, it dies.
  Order sensitivity **decomposes pairwise** (RID-rebinding adjacency,
  same-field last-wins `Rx5,Rx03` vs `Rx03,Rx5`); the one non-pairwise
  observable (+1 flush coupling) is order-inert — a per-flush global.
- **Surviving-object pairs are inert**: link disable↔endpoint-move order
  converges; link-kill↔map-off order converges; cross-object triples
  converge (synchronous agent channel masks); same-object different-field
  triples coalesce to one wave.
- Callsite interaction: identical sequences inside `_physics_process`
  show the SAME partition, every edge −1 tick (the coroutine resume
  straddles one more sync).

## Transient `[]` interlude — a two-phase seam

Every permutation containing both Rdel and Rrec serves the EMPTY path
for exactly 2 frames (f2,f3) before the recreated region lands at f4 —
an intermediate served state neither endpoint carries (`free_rid` lands
at its own f2 edge; mesh+map rebuild takes to f4).

## map_force_update — getter edge collapses; serve edge is per-class

- Getter/object edge: collapses to same-turn for link (en=false +
  link_iter=2 at w0). Region asymmetry: transform VALUE lands same-turn
  but `region_get_iteration_id` does not stamp until w1.
- Serve edge splits by class: **link kills are JITTERED** — fresh at w1
  on ~15-20% of identical runs (critic ~5/30, verifier 6/10), w2
  dominant; **region transforms move DETERMINISTICALLY 3f→2f** (critic
  9/9). Both stale at w0, fresh by w3.
- **Mechanism (scribe mark-vs-phase)**: FU drains stage S to same-turn
  deterministically; stage P lands on the next *scheduled* sync phase.
  What pulls P in by one frame is a prior forcing READ marking the
  stamped-dirty map — read-every-frame callers (the fixture's shape)
  see link 2→1 / region 3→2; **single-read-per-rung probes see NO
  collapse** (edges unchanged 2/3). The {1,2} jitter = mark-vs-phase
  race, workload-biased (light probe 5/5 edge-1; heavy harness w2
  13/15). Mid-window second FU collapses the residual to 0.
- Scribe own-geometry corroboration: `rec,xf` vs `xf,rec` diverges
  (moved dock vs restored bridge); transient seam is geometry-shaped
  (reachable raft route sig vs boundary's `[]` — same 2-frame window);
  `map_get_use_async_iterations=true` default carries the +1
  (async_off moves link 2→1 — scout).
- The tracked arm `mut_force_link` pins only deterministic facts
  (w0: getter applied + stale serve; w3: fresh clamp) — the jittered w1
  sample is skipped. The earlier 3-step pin caught the jitter inside the
  official battery (~15-20% flake) before the correction.
- `map_force_update` flushes the command queue but does not accelerate
  the served-graph invalidation for link class; bare force is a no-op;
  force under inactive map applies getter state while serve stays stale.
- Fixture comment corrected post-verifier (`565318c`): earlier
  "SERVE edge does not collapse" was link-scoped and falsified for
  region — per-class wording landed.

## Wait-ladder verdict groups — serve-surface partition

- `_tuple_sig` canonicalizes the observed per-step tuple; the ladder
  partitions consecutive identical-signature groups, bound = first
  differing index: link → bound=2, groups=2, sizes=[2,2]; region →
  bound=3, groups=2, sizes=[3,2] — re-derives the r76 edges from data.
- Groups describe **served tuples only** — they hide internal state:
  getter edges, region_transform truth (`0.30` vs `0.00` under a
  disabled region), kill mechanism, suppressed writes. Critic's masking
  witness `omk` pair: identical served tuple, divergent internals
  (nreg=1 live-disabled vs nreg=0 void). Receipts need truth digests in
  addition to serve signatures — open frontier.

## Battery

173/173 + 4 probes + Node 31/31; 163 prior rows byte-stable vs r76
verifier's independent receipt; seeds_unchanged; `run_battery.py` +20/−0
pure additive CASES.

## Method notes

- Nondeterministic edges: pin deterministic samples only and record the
  measured distribution (6/10, ~15-20%, 9/9) — never pin a jittered
  cell as a constant. The arm that pinned w1-stale flaked inside the
  official battery.
- Read-history is part of the measurement: a probe that reads every
  frame perturbs the serve edge under force; a single-read-per-rung
  probe does not. State the sampling protocol next to the edge.
- Order probes: enumerate all permutations of the destructive triple —
  three outcome classes hide in what "one pair differs" undersells.
- `_tuple_sig` groups are a projection: pair them with srv_get truth
  fields before claiming state equivalence.
