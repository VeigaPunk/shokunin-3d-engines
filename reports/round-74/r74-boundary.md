# game-dev-3d round 74 — boundary (revenger): moving-agent edge probes on the landed mv_* surface

Seat: boundary (role revenger — leaf, no dispatch, no tracked edits, no git
mutation). Brief: probe the five assigned edges on the author's landed
(uncommitted) r74 diff — `corpus/fixtures/navagent3d_detour.gd` (sha256
`336898f4…`, +506 lines: 18 `mv_*` step-driven arms + `_run_steps` /
`_run_motion_arm`) and `run_battery.py` (+36 lines, 18 CASES rows). All work
scratch-only under `corpus/live/r74-boundary/`.

## Deliverable and method

- `corpus/live/r74-boundary/scratch/project.godot` — byte-identical copy of
  `corpus/fixtures/project.godot` (sha256 `1fda90d4…8eac23`), 60 tps.
- `corpus/live/r74-boundary/scratch/navagent3d_detour.gd` — verbatim copy of
  the author's uncommitted fixture (sha256 `336898f4…`) for verification runs.
- `corpus/live/r74-boundary/scratch/r74b_edges.gd` — sha256
  `34f1367e1535c19ef0ecc38b9c42ad786b533183595c0502295d13e2818dfc7c` —
  extends-SceneTree probe replicating the fixture geometry verbatim
  (L-corridor A1 x[0,2]z[0,1] + A2 x[2,3]z[0,1] + B x[2,3]z[1,4], optional
  island C x[2,3]z[5,6], optional bidirectional server link
  LS(2.5,0,3.5)→LE(2.5,0,5.5), cell_size 0.25, 30-frame settle) with the
  same forcing-first `_read_state` getter order; adds `dwp` =
  euclid(agent, path[idx]) and a `_lazy` non-forcing read (path/idx/
  reached/dist only) for the post-assignment dirty window. `--probe=<name>`,
  optional `--z=` for the pmd bisect. The `_drive` mode is the corpus's
  `navfollow3d_driver` idiom — per physics tick, force-read
  `get_next_path_position()` at the live position then
  `move_toward(next, speed/60)` (`follow`) or a fixed heading (`march`).
- Command shape (cwd `corpus/live/r74-boundary`):
  `timeout 60|90 /usr/bin/godot --headless --path scratch --script
  res://r74b_edges.gd -- --probe=<name>`; Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`. 28 probe runs + 2 repeats + 18 author
  arm runs under `runs/*.stdout.txt`; every exit 0, every stderr clean
  (banner only); `e1_hop` and `e4_march_out` repeats byte-identical —
  deterministic.

## Landed-diff verification (before edges)

All 18 tracked `mv_*` arms run in my scratch copy reproduce their CASES
markers verbatim (`runs/author_<arm>.stdout.txt` — PASS lines equal to the
strings in `run_battery.py`): mv_walk, mv_live, mv_popback, mv_popstrict,
mv_void, mv_pmd_edge, mv_pmd_offmesh, mv_pmd2, mv_latch, mv_unlatch,
mv_reanchor, mv_reanchor_same, mv_reanchor_bank, mv_reanchor_void,
mv_popskip, mv_reanchor_lazy, mv_reanchor_force, mv_bridge_walk. The
author's measured tuples are accurate on this host.

## E1 — teleport THROUGH the link hop: pops are position-only; traversal has no state to break

(`runs/e1_hop.stdout.txt`, `e1_skip`, `e1_latch_freeze`, `e1_burst`; island+
link, path `[S,(2,0,1),LS,LE]`, pdd=1 unless noted.)

- Mid-void pop works, strict-<: at z=4.5 exactly (dwp to LS == 1.000000 ==
  pdd) `idx=2` holds, `next=LS` pointing BACK across the gap; at z=4.4
  (dwp 0.9<1) idx pops 2→3 mid-void and `next` flips to LE. The hop is
  traversed by pure distance arithmetic — the engine knows nothing about
  "being on the link".
- Bypass leaves the index behind: teleporting past BOTH endpoints to the
  island (2.1,0,5.05, dwp→LS 1.6>pdd) keeps `idx=2`, `next=LS` — an
  unconsumed waypoint behind the agent. Nothing breaks: a backward teleport
  to (2.5,0,3.4) pops 2→3 (direction-agnostic), a forward teleport to
  (2.2,0,5.0) pops 3→4, and arrival at (2.9,0,5.85) latches normally. The
  index catches up only when the live position re-enters each waypoint's
  pdd sphere, strictly in stored order.
- `e1_latch_freeze`: latch `finished` mid-void (z=4.6, euclid→LE 0.9<tdd)
  while `idx=2` is still on unconsumed LS → a following teleport INTO LS's
  pdd sphere (dwp 0.1) does NOT pop — `idx=2`, `next=LS` forever. Post-
  finish the update early-returns and the pop index is frozen too, even
  with the strict-< condition visibly met (the author's `mv_latch` shows
  this at idx=1=last on a degenerate path; this pins it mid-path on the
  link surface, `reached=true finished=true idx=2` coexisting with an
  unpopped waypoint).
- `e1_burst`: pdd=1.5, one teleport to (2.25,0,2.25) — within pdd of BOTH
  path[1] and LS — lazy read still `idx=1`, the forcing read returns
  `idx=3`: **two pops inside a single call** — the pop is a while-loop, so
  "sequential, cannot skip" bounds the DIRECTION of advance (each waypoint
  must individually come within pdd), not the per-call rate.
- Stored path byte-identical every step (`pathlen=6.130649` constant) —
  no mid-hop mutation, traversal never "breaks" because there is no
  traversal state at all.

## E2 — latch then target re-set: reached recomputes fresh (re-latches), not inherited

(`runs/e2_relatch.stdout.txt`, `e2_sync`; latch setup spawn FG=(2,0,3),
target TG=(0.5,0,3.0) tdd=1.6 → latched at settle.)

- `moved` (tp to S): stays latched, path `[FG,FG]` frozen.
- `reset_far` (set_target TD): lazy window shows `npath=0` (stored path
  cleared synchronously) BUT `idx=1` still — the pop index is NOT reset at
  assignment; the stale value is readable in the dirty window and the 0
  only materializes inside the first forcing call. (Author header says
  "resets the pop index to 0 and synchronously clears the stored path" —
  the clear is synchronous, the idx reset is lazy; same as r74-critic's
  `ra_idx_pre` on the pre-landing spike.) Forced read: fresh path
  `[S,(2,0,1),TD]`, `reached=false finished=false` — recomputed.
- `reset_near` (set_target (0.9,0,0.5), euclid 0.4<1.6 from live pos):
  `reached=true finished=true` — the flag **re-latches on the new target
  at the first forcing call** — a fresh evaluation per assignment, no
  sticky-on, no sticky-off.
- `reset_far2`: unlatches again. The full cycle
  latched→recompute-false→re-latch→recompute-false is closed.
- `e2_sync`: latched, tp (10,0,10) stays latched; same-value
  `target_position=TG` then non-forcing reads: `path=[]`, `idx=1` stale,
  `reached=false` (flag cleared synchronously), `dist=11.800424` already
  live euclid to the re-assigned target. Forced read: `idx=0`, path
  `[(3,0,4),FG]` — clamp anchor.

## E3 — teleport INTO the void gap (z∈(4,5)): mid-gap readouts are fully defined; two claim-boundary corrections

(`runs/e3_gap_link.stdout.txt`, `e3_gap_nolink`, `e3_pmd_eq`,
`e3_pmd_z*.stdout.txt`, `e3_pmd_leg`, `e3_pmd_leg_link`.)

- `e3_gap_link` (target (2.9,0,5.9) so the sequence stays unlatched):
  dead-center (2.5,0,4.5) — `idx=2`, `next=LS` behind, `dist=1.456022`
  live euclid to raw target, path frozen; deeper (2.5,0,4.9, dwp→LS 1.4)
  still no pop — drifting AWAY from the current waypoint never pops;
  backward to (2.5,0,4.1, dwp 0.6) pops idx→3 (`next` flips LS→LE); back
  to (2.5,0,4.9) pops 3→4 (`next=T`); arrive latches.
- `e3_gap_nolink` (island, NO link, pdd=2.5 → settle already pops to
  idx=2=last): tp mid-gap (2.5,0,4.5) — **`finished=true` fired while the
  agent stands IN the void**, via the unreachable + idx==last +
  euclid(agent, clamped final (2.5,0,4.0))=0.5<pdd clause; `reached=false`
  (euclid to raw LE=1.0==tdd, strict). At (2.5,0,4.6) — euclid to raw
  0.9<tdd — `reached` stays **false**: post-finish reached-freeze,
  reproduced mid-void on the landed surface.
- **FALSIFIED, pmd gate equality**: author's header says "within
  path_max_distance (default 5.0, STRICT >)". Bisect `e3_pmd_z` (tp to
  (2,0,z), dist to path[1]=(2,0,1) = z−1): z=5.9999 (dwp 4.999900) FROZEN
  idx=1; **z=6.0 (dwp exactly 5.000000) RE-QUERIES** — idx=0, path
  re-anchored `[(2,0,4),(2.5,0,3.5)]`. The gate fires AT equality — it is
  `>=` (inclusive), matching the `reached<`/pop`<`/`reachable<=` family:
  "frozen while strictly inside" = `<`.
- **CORRECTED, pmd gate metric**: author says "within pmd of the CURRENT
  next waypoint path[idx]". Measured metric is distance to the current
  LEG segment `path[idx-1]→path[idx]`, not to the waypoint:
  - `e3_pmd_leg` (pmd=1.5, idx=1): tp (2.5,0,3.0) — ~0.1 from the LATER
    leg (2,0,1)→(2.5,0,3.5) but 2.06 from the current leg S→(2,0,1) →
    RE-QUERY (path `[(2.5,0,3.0),TD]`). Proximity to a future leg does
    not save the freeze — the tube covers only the current leg.
  - `e3_pmd_leg_link` (pmd=0.8, idx=3): tp mid-void (2.5,0,4.5) — ON the
    LS→LE hop line, 1.0>0.8 from BOTH endpoints → **FROZEN**, path
    unchanged. The pmd tube runs along the link leg through the void.
  - `e4_march_out` ratchet (below) confirms quantitatively: breaches fire
    at leg-distance exactly pmd three times (x=1.5, x=0.5, x=−0.525).

## E4 — continuous motion (per-tick follow/march) vs teleport: semantics identical; the only new observable is the beyond-pmd ratchet

(`runs/e4_walk.stdout.txt`, `e4_walk_link`, `e4_march_out`,
`e4_march_latch`; speed 3.0 u/s = 0.05/tick follow, 1.5 u/s = 0.025/tick
march.)

- `e4_walk` (corridor, target TD): idx flips 1→2 at t=12 at pos
  (1.069210,0,0.689737) — the first tick inside strict-< of (2,0,1)
  (euclid≈0.98); the follower corner-cuts toward live `next`; reached+
  finished latch at t=56 (dist 0.9535<1); stored path byte-frozen all 80+
  ticks. Identical rules to the teleport arms — pop is call-time, motion
  granularity irrelevant.
- `e4_walk_link` (island+link, target LE): pops at t=12 (bend, 0.98) and
  t=56 (LS, 0.95 on the near bank); VOID_IN t=84 z=4.03; mid-gap ticks
  show `idx=3 next=LE` with live dist; **`reached`/`finished` latch at
  t=94 at z=4.5287 — mid-flight in dead space** (euclid→LE 0.982<1), then
  VOID_OUT t=104, arrival dist=0 at t=120. No divergence from teleport
  semantics; reproduces r73-boundary's mid-hop latch under the r74 model.
- `e4_march_out` (pmd=1.0, pdd=0.3, fixed march −x away from target):
  the stored path is NOT frozen in the breach regime — it re-queries each
  time the agent drifts pmd past the CURRENT LEG, re-anchoring at the
  live clamp: ratchet ticks visible at t≈40 (x=1.5, leg-dist exactly 1.0
  → p0 jumps to (1.5,0,0.5)), t≈81 (p0→(0.475,0,0.5)), t≈121 (off-mesh
  x<0 → p0 pins at the edge clamp (0,0,0.5)). Post-breach the agent sits
  `idx=0` with `next=path[0]` = the stale clamp (dwp 0.525>pdd → no pop)
  while dwp grows unbounded (1.75 at end) — a stationary off-mesh regime
  where `next` permanently points at the map edge. The teleport arms see
  only the discrete anchors; the march exposes the pmd-sized cadence.
- `e4_march_latch` (pmd=1.0, march +z THROUGH the target): pre-latch,
  although dwp→path[2] exceeds pmd for 70+ ticks (2.775→1.0), the path
  stays frozen — because the agent marches ON the current leg
  (leg-distance 0); this is the positive half of the leg-segment
  correction. Latch at t=104 (z=3.10, euclid 0.399997<tdd 0.4); marching
  on into the void (VOID_IN t=140, z=4.0+) — path `[…(2.5,0,0.5)…]`
  frozen forever: the finished-latch early-return gates the pmd re-query
  off under continuous motion, exactly as `mv_latch` showed for
  teleports.
- **Divergence verdict**: none in pop/finished/latch semantics — call-time
  evaluation makes teleport and per-tick motion equivalent. The
  continuous-only observables are the beyond-pmd ratchet cadence and the
  post-latch absolute freeze.

## E5 — target re-set to an UNREACHABLE point mid-link-traversal

(`runs/e5_unreach_bank.stdout.txt`, `e5_unreach_void_{b,c,tie}`; retarget
to (2.5,0,7.5) → clamps to island edge (2.5,0,6.0), euclid 1.5>tdd=1 →
`reachable=false`; the routed path still crosses the link when anchored
bank-side.)

- Bank-side (`armed` at (2.5,0,3.4), idx=3 hop armed): lazy window
  `npath=0`, `idx=3` stale, `reached=false`; forced: new path
  `[(2.5,0,3.399999),LS,LE,(2.5,0,6.0)]` — live anchor, **link retained**,
  idx reset→re-pops to 2. `finished` stays false until the index
  saturates: tp (2.5,0,5.9) pops 2→3 (euclid→LE 0.4<1) and the
  unreachable-clause fires `finished=true` at euclid 0.1 from the clamped
  final — `reached` stays false (euclid to raw 1.6>tdd). Proximity to the
  clamped final alone does not finish — idx must reach last first.
- Mid-void B-side (z=4.4): anchor clamps to B edge `(2.5,0,4.0)`; the new
  path is `[(2.5,0,4.0),LS,LE,(2.5,0,6.0)]` — it routes the agent BACK
  through the link start behind it. The index re-pops forward (idx=2 on
  landing since the leg's near waypoints are within pdd).
- Mid-void C-side (z=4.6): anchor clamps to C edge `(2.5,0,5.0)`; new
  path `[(2.5,0,5.0),(2.5,0,6.0)]` — **the link is abandoned entirely**;
  a mid-hop retarget on the far half of the gap never uses the link back.
  Also demonstrates unlatch-through-assignment mid-void (the drift there
  had latched; the retarget's forced read shows `finished=false`).
- Exact tie (z=4.5, equidistant to both banks): clamps to the **B (near)
  bank** `(2.5,0,4.0)` — link retained backward leg. Consistent with
  r73-boundary's `e5_tp45_rt45` measurement on the walk surface; now
  measured through the r74 lazy-materialization path.

## Divergences from the author's landed header wording

1. `path_max_distance` gate is **inclusive** — fires at
   `dist == pmd` (e3_pmd_z: 4.9999 frozen, 5.0000 re-query), not "STRICT >".
   Family-consistent: frozen iff dist < pmd.
2. The pmd gate measures distance to the **current leg segment**
   `path[idx-1]→path[idx]`, not to `path[idx]`: marching along the leg
   2.775 past the waypoint stays frozen (e4_march_latch pre-latch);
   standing mid-void ON the LS→LE leg at pmd=0.8 stays frozen while 1.0
   from both endpoints (e3_pmd_leg_link); standing near a LATER leg but
   >pmd from the current leg re-queries (e3_pmd_leg). All authored arm
   tuples remain correct — the waypoint and its leg coincide at the
   measured positions — but the general rule is the leg tube.
3. `set_target` does not synchronously reset the pop index: the dirty
   window reads stale idx (e2_relatch `reset_far_lazy` idx=1; e5
   `*_lazy` idx=3). The stored path IS cleared synchronously (`npath=0`)
   and `reached` reads false synchronously; idx=0 materializes at the
   first forcing call.
4. Post-finish freeze is total: idx cannot pop even into a satisfied
   strict-< sphere (e1_latch_freeze), and `reached` cannot fire even when
   the agent moves inside tdd of the raw target (e3_gap_nolink gap46).

## Reconstructed contract (measured, this build)

- Stored path: cleared synchronously on ANY `target_position` assignment;
  lazily materialized at the first forcing call anchored at the live
  position/clamp; thereafter stable while the agent stays within
  `pmd`-distance of the CURRENT LEG (segment into `path[idx]`),
  re-querying at `leg-dist >= pmd` with anchor = live navmesh clamp;
  gated OFF entirely once `finished` latches.
- Pop index: `while idx < size-1 and euclid(agent, path[idx]) < pdd` —
  strict-< against the stored path, live position, inside forcing calls
  only (a wait=0 read pops immediately; pure ticks never do); a single
  call pops multiple waypoints (sequential loop — direction-bounded, not
  rate-bounded); never un-pops; frozen once `finished` latches; reset to
  0 only at a materializing re-query (not at assignment).
- Flags: `reached` = euclid(agent, raw target) < tdd sampled inside
  forcing calls; `finished` = reached OR (unreachable ∧ idx==size-1 ∧
  euclid(agent, clamped final) < pdd); both latch; `reached` freezes at
  its sampled value post-finish; unlatch = any `target_position`
  assignment (synchronous flag clear), then fresh evaluation — a new
  target within tdd re-latches immediately.
- Link traversal under motion: no traversal state — endpoints are plain
  waypoints; mid-gap pops, bypass, backward catch-up, mid-gap latch, and
  mid-gap retarget re-anchoring (bank-tie → near bank) all behave as pure
  position arithmetic on the stored array.

## Confidence and bounds

HIGH on all pinned items — every claim above is backed by a PROBE receipt
in `runs/` with exact tuples, deterministic repeats, and the author's own
18 arms reproducing in scratch. Bounded: one build
(`4.7.2.stable.arch_linux.ed1daf0bf`), one region + one island + one
server link, transform-driven motion (Node3D teleports and per-tick
move_toward — no collision stepping), default path_postprocessing. The
leg-segment pmd model is inference-fit to 7 measurements (e3_pmd_z sweep,
e3_pmd_leg, e3_pmd_leg_link, e4_march_out cadence, e4_march_latch); an
alternative formulation matching all of them is not ruled out but the
simple point-to-waypoint rule is refuted. Report + scratch only; leaf —
stop here.
