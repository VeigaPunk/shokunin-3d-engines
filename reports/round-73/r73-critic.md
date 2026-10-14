# game-dev-3d round 73 — critic (seat: critic, host: devin)

Scope of attack: the declared axis-move — off-mesh navigation-link traversal
gating as tracked CASES arms on `navagent3d_detour.gd`: (a)
`path_metadata_flags` surfaces LINK-typed companion arrays; (b) three
independent drop gates (layers bitmask mismatch, bidirectional=false from the
exit side, enabled=false); (c) `enter_cost` inert while `travel_cost` is live;
(d) the pdd pop-through hazard across the void.

Probe: `corpus/live/r73-critic/scratch/r73c_link.gd` (sha256
`caeaa0878101ea42ce7c2396d92b4d0df00aa21623fbebb7cc63dfacf2b2eb66`), an
independent extension of the r72-boundary `navagent3d_link.gd` pattern
(L-corridor + island C, plus a second parallel link, spawn/target/teleport
overrides, region-layer control), with verbatim `project.godot` (sha256
`1fda90d4…8eac23`, byte-identical to the committed seed). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot --headless`; 60 tps;
cell_size 0.25; 30-frame settle. 86 probe invocations, all exit 0, all stderr
banner-only; two repeats (`d_pdd4.03`, `a_ll2_al1`) byte-identical.

Command shape per arm (receipts `corpus/live/r73-critic/runs/<arm>.stdout.txt`
/ `.stderr.txt` / `.exit`):

    godot --headless --path corpus/live/r73-critic/scratch \
        --script res://r73c_link.gd -- --geo=shortcut|bridge \
        [--link=none|server|node] [--link2=parallel|short] [--meta=N|absent] \
        [--pdd=F --tdd=F --postproc=N --ll=N --al=N --rl=N --ll2=N] \
        [--oneway --rev --disabled --e=F --t=F --e2=F --t2=F] \
        [--spawn=x,z --target=x,z --tp=x,z --swapx]

Author arms landed mid-review (working tree, uncommitted; 15 new CASES rows,
purely additive — `git diff` shows 0 removed CASES lines and only mechanical
context edits in the fixture). Verbatim replay of the FULL battery against the
author's working-tree state, run inside my write scope
(`python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
corpus/live/r73-critic/battery-runs`): **127/127 PASS** — all 112 prior rows
byte-stable by exact marker match, all 15 new `link_*` arms pass. Verdicts:
`corpus/live/r73-critic/battery-runs/20261014T015632521492Z/verdicts.json`.

## Attack 1 — gate attribution: does the layers arm isolate the bitmask? FAILS (claim holds); semantics sharpened

The author's `link_layers_off`/`link_layers_on` pair is a clean control —
geometry, spawn, target and link identical across the pair, only the mask
intersection changes. My probe confirms and delimits:

| arm | ll/al/rl | result |
|---|---|---|
| a_ll2_al1 | 2/1/1 | link dropped → corridor `[S,(2,0,1),T]` pathlen 4.130649 — **byte-identical to a_nolink** |
| a_ll1_al1 | 1/1/1 | link used `[S,ls,le,T]` pathlen 4.192582, types `[0,1,0,0]` |
| a_ll2_al3 | 2/3/1 | link used — bitmask INTERSECTION confirmed |
| a_ll0_al1 | 0/1/1 | link dropped — a zero layer mask never matches |
| **a_ll2_al2 / a_ll2_al2_rl1** | 2/2/1 | **EMPTY PATH: npath=0, final=(0,0,0), next=spawn, reachable=false, finished=false** |
| a_ll2_al2_rl2 | 2/2/2 | link used (region also on bit 2) |
| a_ll2_al4_rl1 / a_ll4_al2 | — | empty path (agent mask disjoint from region) |

Two findings the claim's wording misses (both measured, neither falsifies it):
1. The bitmask gate is **uniform** — `navigation_layers` filters regions and
   links alike. "The link drops" is only observable while the agent's mask
   still covers a region; mask matching the link but not the region yields
   not "corridor fallback" but total query collapse (empty array, final =
   Vector3.ZERO — a third mode distinct from the r72 unreachable-clamp, and
   `final=(0,0,0)` is a sentinel that would alias a real origin target).
2. A layers-drop is **output-identical to link absence** (and to disabled,
   and to backward-direction — all four produce the corridor/clamped
   baseline byte-for-byte), so every gate arm's falsification path is its
   own flag-restored twin, exactly as authored.
   Node-authored links gate identically (`a_node_ll2_al1` → corridor).

## Attack 2 — enter_cost "inert": below the decision gap, or never applied? FAILS — inert beyond all doubt

The counter-hypothesis was that e=100 merely sat below the detour-vs-direct
cost gap. Measured otherwise:

- **Decision gap measured**: `travel_cost` flip threshold T* ∈ (1.11, 1.13]
  on the shortcut (b_t1.11 keeps the link, b_t1.13 drops it — bisected from
  {1.0,1.02,1.05,1.1,1.11,1.13,1.15,1.17,1.19,1.2,…,10}). The internal
  link-route advantage over the corridor is ≈ 0.12·hop_cost (~0.3 in
  length units).
- **Sweep**: `enter_cost` ∈ {0, 0.001, 0.01, 0.1, 0.5, 1, 2, 5, 10, 100,
  1000, 1e6} — link chosen at every value. e=1e6 is ~3×10⁶× the decision
  gap: not "below the gap", **inert**.
- **Head-to-head at zero gap**: two parallel links of equal hop (x=2.5 vs
  x=2.2). With link2's `enter_cost`=1e6 the engine still routes link2
  (`b2_par_e2_1e6`, `b2_short2_e1e6`, l2match=1 both). An additive cost that
  entered route selection would flip a tie at any positive value; 1e6 does
  nothing.
- **Positive controls**: `travel_cost` flips head-to-head (`b2_short2_t2x10`,
  `b2_t2x3`: t2≥3 prices the shorter 1.5-hop link out vs the 2.0-hop link1)
  and against the corridor (b_t* bisect). The cost channel is live — the
  enter half is dead on this build.
- **Reported cost also inert**: `get_path_length()` returns the geometric
  length in every arm (4.192582 shortcut, 6.130649 bridge) — enter_cost
  moves neither route choice nor the returned path cost; travel_cost moves
  only the choice.
- **Not an absolute gate**: sole-route bridge at e=1e6 still traverses
  (`b_bridge_e1e6`, reachable=true, types `[0,0,1,0]`).

The author's pinned `link_entercost` (e=100, link kept) encodes the true
behavior; this probe makes "inert" the measured statement, not "small".

## Attack 3 — companion-array typing: populated in 4.7.2, and the flag is opt-OUT

| arm | meta | types | rids | owners |
|---|---|---|---|---|
| c_meta_default (property untouched) | **read 7** | `[0,1,0,0]` | 4 (link RID @1) | 4 (invalid 0s) |
| c_meta0 | 0 | `[]` empty | 0 | 0 |
| c_meta1 / c_meta2 / c_meta4 | single bit | types only / rids only / owners only | — | — |
| c_meta3 / c_meta6 | OR combos | types+rids / rids+owners | | |
| c_meta7_node | 7, node link | `[0,1,0,0]` | l1@1 | ownvalid=1 `NavigationLink3D` |
| c_meta7_pp1 / pp2 (bridge) | 7 | npath=6, LINK mark at reshaped idx 3 | 6 | 6 |

Findings:
- **Correction to claim (a)'s framing**: on this build
  `agent.path_metadata_flags` **defaults to 7** (ClassDB-dumped by the
  scout's api_verify; my c_meta_default readback confirms). LINK typing is
  surfaced without "enabling" anything — the gate is opt-OUT. The
  discriminating arm is meta=0 → companion arrays come back **EMPTY**
  (size 0), not zero-filled mirrors of the path. The author's arms encode
  this correctly (`link_shortcut` pins `types=[]` at explicit meta=0).
- Bit values: TYPES=1, RIDS=2, OWNERS=4 on
  `NavigationPathQueryParameters3D` (constants absent on NA3D/NPR3D);
  `PATH_SEGMENT_TYPE_LINK=1` marks the hop's **start** index.
- Postproc alignment caveat for future arms: under edgecentered/none the
  bridge path reshapes to 6 points (edge midpoints + a **duplicated
  zero-length final point** after the hop) and the companion arrays track
  the reshaped length — LINK still marks the hop start (index 3). The
  author's pinned `types` vectors are corridorfunnel-specific.

## Attack 4 — pop-through: identical pop rule; hazard is SYMMETRIC

- Threshold bracketed at the claimed strict-`<`: pdd=3.60 → idx=2
  (next=linkstart (2.5,0,3.5)); pdd=3.61 → idx=3 (next=linkend
  (2.5,0,5.5), across the void) — the pop flips at
  euclid(S→linkstart)=3.605551.
  `d_pdd4.03` reproduces the author's `link_pop_void` exactly.
- **No traversal latch**: teleporting the agent onto the island mid-path
  (`d_tp_island_pdd2.5`) simply pops both link endpoints by Euclidean
  distance on the frozen path (idx 2→3, next=T). Link waypoints are
  ordinary waypoints — nothing resets or latches at hop time.
- **Sharper than the declared hazard — the retro-point**: agent teleported
  to (2.2,0,5.2) on the island with the frozen mainland path, pdd=1.5,
  tdd=0.3 (small enough that reached=false unmasks it): idx stays 1 and
  `get_next_path_position` returns **(2,0,1) — the mainland portal,
  backward across the unjumpable void** (`d_tp_island_retro`,
  finished=false, dist=0.424264). The sequential pop cannot skip to the
  link's near endpoint, so an agent that finds itself past the link is
  directed INTO the gap — the mirror image of the pinned forward
  pop-through. The battery pins only the forward direction; the hazard
  claim is true and under-pinned.
- Bonus edge: spawning IN the void clamps to the nearer poly —
  `d_spawn_void43` (z=4.3) clamps to B and routes backward through the
  link (path `[clampB, linkstart, linkend]`, types `[0,1,0]`, idx pops to 2
  immediately → next=far endpoint); `e_spawn_void47` (z=4.7) clamps to C
  and the path is pure-island — the link never enters it. Which side of a
  mid-gap spawn the engine picks silently decides whether the link is even
  in the path.

## Attack 5 — bidirectional approached mid-link / from the exit side: FAILS (claim holds literally)

| arm | setup | result |
|---|---|---|
| e_fwd_isl2main | oneway mainland→island; **agent spawned ON the island**, target mainland | unreachable, final clamps (2.5,0,5.0) — exit-side approach drops the link |
| e_bidir_isl2main | same, bidir | traversed backward: path `[spawnC,(2.5,0,3.5)]`, types `[1,0]` |
| e_rev_isl2main | oneway with authored direction reversed (start on island) | traversed — reachable |
| e_fwd_main2isl | oneway forward, mainland spawn | traversed (author's `link_oneway_fwd` twin) |
| e_rev_main2isl | oneway, authored reversed | dropped → clamp (2.5,0,4.0) ≡ e_nolink |
| e_disabled | enabled=false | dropped → identical clamp ≡ e_nolink |
| e_node_rev | node-authored oneway reversed | dropped — identical gating |

The author's `link_oneway_rev` encodes the exit-side gate by swapping
authored endpoints at fixed spawn; my literal exit-side spawn (agent
physically on the island needing a backward hop) produces the same drop —
the gate keys on query direction vs authored start→end, not on which side
the agent occupies.

## Verdict summary

| attack | result |
|---|---|
| (1) layers attribution | FAILS — bitmask-intersection confirmed on a clean control; sharpened: uniform per-element filter, zero-mask drops, mask-matching-nothing yields empty path + zero-vector final (new third mode) |
| (2) enter_cost inert | FAILS the "below-the-gap" hypothesis — inert at ~3×10⁶× the measured decision gap, in head-to-head at zero gap, and in `get_path_length()`; travel_cost live at T*∈(1.11,1.13] |
| (3) companion typing | FAILS — but the claim's "enabling" wording is inverted: the flag defaults to 7 on this build (opt-out); meta=0 yields EMPTY arrays; LINK=1 marks hop-start; arrays track postproc-reshaped paths |
| (4) pop-through | FAILS — strict-`<` at 3.605551; symmetric retro-point hazard found (agent past the link gets a mainland `next` through the void, unmasked at small tdd); no traversal latch |
| (5) bidir mid-link/exit-side | FAILS — literal exit-side approach drops the link; direction keyed on authored start→end |

## Impacted axes

- **depth**: the claimed semantics survive every attack — and get sharper
  (enter_cost inert-not-small; uniform layers filter with a third empty-path
  mode; symmetric pop-through hazard; opt-out metadata default).
- **coverage**: 15 additive arms + controls cover (a)–(d); identified
  unpinned extensions: retro-point pop-through, empty-path layers mode,
  meta-default-7 frame, postproc×companion-array alignment, equal-cost link
  tie-break (positional — x=2.2 side won under both creation orders,
  `b2_tie`/`b2_swapx`).
- **calibration**: byte-stability verified by my own 127/127 replay; r72
  pop arms now run under explicit meta=0/agent-layers=1 (setter added in
  the arm branch — companion arrays are unread by pop assertions, so no
  observable change).

## Smallest safe corrections (fixable wording; nothing blocks)

1. Header comment / claim wording: "enabling path_metadata_flags" →
   "path_metadata_flags (default 7 on this build) gates the companion
   arrays; meta=0 returns them EMPTY" — one line, prevents a future reader
   expecting opt-in.
2. Optional future arm, not required by this claim: pin the retro-point
   (`d_tp_island_retro` numbers above) if the lane wants both directions of
   the pop-through hazard tracked.

Bounded: one engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
60 Hz physics, stationary/teleported agents only — real mid-hop traversal
dynamics under motion unprobed; pure-server map, single region (+island),
30-frame settle; avoidance/path_max_distance/simplify unprobed. Receipts:
`corpus/live/r73-critic/runs/` (86 arms × .stdout/.stderr/.exit),
`corpus/live/r73-critic/battery-runs/20261014T015632521492Z/verdicts.json`
(full battery replay, 127/127). No tracked files touched, no commits, leaf —
no dispatch.
