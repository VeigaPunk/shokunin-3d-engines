# Round 74 adjudication — moving-agent semantics (Sol)

Work commit `fc9915e`. Seat set: author, baseline, scout, critic, reviewer,
simplifier, scribe, boundary + named non-author verifier (`r74-verifier.md`).

## Own reproductions on the committed tree

| check | observed |
|---|---|
| `mv_latch` | byte-exact: `steps=2 idxs=1,1 ... dist=11.800424 pathlen=0.000000 reachable=true reached=true finished=true` — latch holds after teleport-away; stored path cleared |
| `mv_reanchor_void` | byte-exact: `idxs=1,1 ... final=2.500000,0.000000,4.000000 dist=1.600000 pathlen=0.099998 reachable=false ... finished=true` — re-anchor to unreachable clamps and finishes via the idx+pdd clause |

## Verdict per claim (convergent: author + critic + scribe independent
geometry + simplifier 18/18 load-bearing)

1. **Stored path frozen under motion** — CONFIRMED, sharpened: freeze is
   conditional on `euclid(agent, path[idx]) < path_max_distance` STRICT
   (scribe's true-equality datapoint: 5.000000 == pmd re-queries — strict
   `<` confirmed, not `<=`); breach re-queries lazily from live pos,
   idx→0, no undo on return; pmd authored value respected (pmd=2, pmd
   offmesh). Finished latch gates even the re-query off.
2. **Pop follows live position** — CONFIRMED: monotone sequential strict-`<`
   on the STORED path evaluated inside forcing calls on live pos; no skips;
   pops through link endpoints mid-void.
3. **distance_to_target = call-time Euclidean to raw target** — CONFIRMED:
   pure reader, commits nothing; live at wait=0.
4. **Latch release = ANY target_position re-assignment** — CONFIRMED:
   same-value assignment unlatches (no dedup), clears stored path, resets
   idx; materialization is lazy — anchored at the first forcing call's
   position, not assignment (`mv_reanchor_lazy`/`_force` pair isolates it).
5. **Prior surface stable** — CONFIRMED: 145/145 (127 prior byte-stable +
   18 new), 4/4 probes, Node 31/31, seeds_unchanged.

## Absorbed corrections

- Author's inherited diff needed no fixes (respawned-author audit);
  simplifier's dead `st2` nit recorded as cosmetic, not applied
  (keeps byte-identical output).
- Simplifier: elif-chain now 3 copies — consolidation warranted next
  round (`_check_tuple(obs,want,prefix)`, ~53 lines reclaimable);
  recorded as a wave-6 simplifier target.
- Scribe refinement: pmd gate is strict `<` at exact equality —
  carried into the lesson.
- Reviewer-flagged operational gap (relative `--runs` fails the
  tree-timeout witness) — still absent from docstring/README; queued
  for wave-6 housekeeping.

## Verdict: ADMIT

Lazy-update model pinned: forcing-getter set vs pure readers, freeze
inside pmd, live-position pop, same-value unlatch, lazy materialization
anchor. Bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf, this host,
headless physics; teleport-only motion (no velocity/move_and_slide);
single map. No engine-internals or cross-build inference.
