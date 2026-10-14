# game-dev-3d round 75 — critic (seat: critic, host: devin)

Scope of attack: the declared axis-move — pin server-side map/link MUTATION
under a committed NavigationAgent3D path (the zombie-waypoint question): does
mutating the map (link enable/disable, navigation_layers on link/agent,
region delete/recreate, region_set_transform) invalidate the stored path
lazily, leave a traversable dead-gate waypoint, or update on the next forcing
call. Declared falsifiable claim: **"the stored path is invalidated by map
mutation"** (r74 lazy-update model predicts forcing-call-gated invalidation;
r74 fw_mapedit/fw_layermask measured EMPTY path + final=(0,0,0)).

**Author landed mid-review.** Working tree at cutoff: `M
corpus/fixtures/navagent3d_detour.gd` (+464/−11, adds 11 `mut_*` arms,
`mutate`/`peek_path`/`peek_idx`/`peek_only` step keys, `_apply_mutation`,
`_final_srv_state`, `srv` live-objects dict) and `M
corpus/fixtures/run_battery.py` (+22/−0, 11 CASES rows, 145→156 total —
programmatic count; all prior rows byte-preserved per the diff). All 11 new
arms **PASS** under my direct invocation AND through the battery classifier
(`corpus/live/r75-critic/battery-runs/20261014T051420756268Z/verdicts.json`);
all 60 prior detour cases re-run **PASS 60/60** — zero regression
(`…/20261014T051439087690Z/verdicts.json`).

Critic probe (independent, built before the landing per the brief's poll-or-
build clause): `corpus/live/r75-critic/scratch/r75c_mutate.gd` (sha256
`58d62582…432592`), extends-SceneTree on verbatim `project.godot`
(`1fda90d4…8eac23`), same L-corridor + island C + server link
ls=(2.5,0,3.5)→le=(2.5,0,5.5), plus optional second agent (`--two`) on the
same map. Godot `4.7.2.stable.arch_linux.ed1daf0bf`, 60 tps. **34 arm runs,
all exit 0, stderr banner-only**; three sharpest arms repeated
byte-identical. Receipts: `corpus/live/r75-critic/runs/`; runner
`run_arms.sh`. A working-tree copy of the author's fixture with one added
`wait:0` arm is at `scratch/navagent3d_detour_wt.gd` (scratch-only).

## Headline: the landed model is right post-sync — but "no dead-hop point is ever SERVED" is FALSIFIED

Every overlapping measurement agrees — the author's 11 arms and my 34 runs
pin identical semantics: lazy, total, forcing-call-gated invalidation;
EMPTY vs clamped-anchor completeness; latch freeze through region delete;
revive byte-restore. The ONE falsified claim is in the fixture header
(diff line ~148) and the `mut_link_kill` arm comment:

> "The zombie waypoint exists only as stored data — **no dead-hop point is
> ever SERVED**: the update runs before the pop/next fetch inside the same
> forcing call." / "the first forcing call re-queries … NO zombie served."

**Counterexample `zw_popgate_sameturn`** (`runs/zw_popgate_sameturn.stdout.txt`,
byte-identical on repeat): two-step walk to idx=2, teleport onto the near
gate endpoint (2.5,0,3.4), `link_set_enabled(false)`, then
`get_next_path_position()` **in the same turn** →

    sameforce next=2.500000,0.000000,5.500000 idx=3
    path=[(0.5,0,0.5)(2,0,1)(2.5,0,3.5)(2.5,0,5.5)]

`get_next_path_position` SERVED the dead gate's far endpoint and the pop
index advanced 2→3 across it — a dead-hop point both served and traversed.
This is not agent-cache staleness alone: the invalidation flag is **set at
map sync, not at setter call** — proven two ways:

1. The served array is the untouched original (`path[0]=S`, npath=4): had a
   requery run, path[0] would re-anchor at the live position (2.5,0,3.4)
   and idx would reset — exactly what happens at the first post-sync force
   (`:post5` → `[(2.5,0,3.4),(2.5,0,4.0)]` finished=true).
2. **Server-side ground truth is equally stale**: `link_get_enabled(link)`
   returns `true` and `link_get_iteration_id` stays 1 in the same turn as
   `link_set_enabled(false)`; only after the next physics sync does it read
   `false`/iter=2 (receipt `runs/iter_check.stdout.txt`, script
   `scratch/iter_check.gd`, reproduced below in Evidence). The mutation is
   invisible to EVERYTHING — server getters included — until one physics
   frame elapses.

So the honest contract: *"no dead-hop point is served once a physics frame
has synced the mutation; inside the setter→sync window the stale path is
served AND pop-traversed."* The author's ordering claim (update runs before
pop/next fetch) is true but toothless here — the update itself runs on the
pre-sync map.

## Attack 1 — zombie traversal: measured in two regimes

| receipt | result |
|---|---|
| `zw_popgate_sameturn` | **same-turn zombie pop**: idx 2→3, next=le across the dead gate, zombie array served |
| `zw_disable_sameturn` | same-turn force at S serves stale zombie array (idx=1 next=(2,0,1)) |
| `zw_disable_idle` | post-sync: pure=STALE; forced → [S,(2,0,1),(2.5,0,4.0)] reachable=false |
| `zw_disable_midvoid` | mid-void (2.5,0,4.4): post-sync → [(2.5,0,4.0),(2.5,0,4.0)] finished=true |
| `zw_disable_popgate` | idx=3 on bank: pure keeps idx=3 zombie; forced → idx 3→1, clamped, finished=true |
| `zw_linklayers` | layers→2 identical to disable (sync-gated, lazy) |
| `zw_linkmove` | requery routes through MOVED link endpoints |
| `zw_enable_dead` | dead→live also invalidates (hop restored, reachable=true) |
| `zw_agentlayers` | agent-side setter is SYNCHRONOUS (peek [] same-turn) — matches author mut_layers_agent |
| `zw_regionlayers`/`zw_region_delete`/`zw_region_free` | EMPTY path + final=(0,0,0) + idx→0 |
| `zw_region_recreate` | recreated region → byte-identical path restored (pathsame=true) |
| `zw_regionmove` | region +5x → re-anchor on moved mesh; **the link does NOT move with the region** (not region-parented) → final=(7,0,4) unreachable |

## Attack 2 — mutation inside the finished-latch: never bypasses (author agrees; I extended it)

The latch's early-return gates invalidation OFF — `lt_linkkill_island`,
`lt_regionmove_island`, `lt_agentlayers_island`, `lt_linkkill_backstep` all
pathsame=true latched. Two sharpenings beyond the landed `mut_latch_zombie`
(corridor latch, next=(2,0,3) survives region move + delete — consistent):

- `lt_zombie_gate`: **bridge** latch with idx=3 next=le → link killed → the
  DEAD GATE's far endpoint (2.5,0,5.5) is served as `next` forever — the
  zombie is not just stored, it's the served next-hop.
- `lt_regionfree_island`: `free_rid(region)` under latch — the stored path
  outlives its entire map region.
- `lt_linkkill_unlatch`: pending invalidation is NOT queued — post-unlatch
  requery just sees the already-dead map → island-local path
  [(2.5,0,5.4),(2.5,0,5.5)].

## Attack 3 — invalidation completeness: three modes, idx never preserved

- **partial re-anchor** (link off/layers/move, region move): idx resets to 0
  then re-pops from live position (never preserved — inv_idx_reset 3→1,
  author's mut_link_kill idxs=2,3,1 agrees); reachable/final recomputed
  (final=clamp, NOT (0,0,0)); `dist` stays raw-euclid to the RAW target.
- **EMPTY** (region gone/masked, agent layers disjoint): path=[] final=(0,0,0)
  idx→0, next=agent position — matches author mut_layers_region/mut_region_renew.
- **New edge**: killing the gate while the agent stands at the dead bank
  LATCHES `finished=true` via the unreachable idx+pdd clause — a mutation
  that *creates* a latch (zw_disable_popgate, zw_disable_midvoid,
  inv_idx_reset; author's mut_link_kill step3 finished=true agrees).

## Attack 4 — double-mutation races: flag is setter-edge-boolean, NOT state-diffed

The declared question "enable+disable between two forcing calls = no
observable change?" is **falsified whenever the agent isn't at the old
anchor**: `race_dis_en_midpath` — disable+enable same turn with the agent
moved to M=(2.6,0,2.0) → forced read re-anchors at M
[(2.6,0,2.0),ls,le] — a net-zero map mutation still fires a full requery.
Same via `race_linklayers_toggle`. At the anchor it's invisible
(race_dis_en_idle byte-identical). Two-step dis→en→dis → net-disabled
(race_triple); dis→force→en→force → byte-identical zombie restore
(race_dis_read_en, author s3/mut_link_revive agree).

## Attack 5 — all agents vs dependents: GLOBAL per-agent invalidation

`shared_nolink` (two agents, one map): agent2's corridor path never touches
the link, agent2 moved to M2 — killing the link invalidates agent2 anyway:
its forced read re-anchors [(2.6,0,2.0),(2.5,0,3.5)]. "Only dependents" is
falsified: every un-latched agent on the map is dirtied. `shared_latch`:
latched agent exempt. `shared_regionmove`: both agents dirtied by a region
transform. **The landed fixture is single-agent — the global scope is
untestable on the CASES surface; documented per brief.**

## Landed-machinery audit (the +464 diff)

- `_run_steps` mutate ordering set_target→tp→mutate→wait→peek→force is
  correct; `peek` captures the pre-force stale state AFTER the wait —
  correctly pins lazy invalidation. `peek_only` steps assert idx+path only
  (handled in `_run_motion_arm`). `_final_srv_state` folds mutations into
  the gate; `want_regions` adapts the setup gate to region_delete. All
  additive; 60/60 prior detour cases green.
- **Defect (bounded, fixable): the mutation-honesty gate is sync-blind.**
  `link_get_enabled`/`region_get_*`/`iteration_id` read PRE-SYNC state — a
  mutate step with `wait:0` fails "authored link flags not in effect" even
  though the setter was issued (my scratch `mut_link_kill_w0` on the
  author's own machinery fails exactly there). Effect: the CASES surface
  cannot express the same-turn zombie window — the gate requires the final
  mutate step to have wait≥1. All 11 landed arms comply (min wait 5), so
  this is latent, not active — but it's the same blind spot as the header
  wording: the sync boundary is invisible to the machinery.
- The `srv` region RID indirection for recreate is correct (recreated
  region re-gates against map).

## Verdict summary

| attack | result |
|---|---|
| (1) zombie traversal | Declared claim CONFIRMED post-sync; **header wording FALSIFIED**: same-turn forcing calls serve AND pop the dead gate (idx 2→3 next=le); server getters also read pre-sync truth — the window is one physics frame at minimum |
| (2) latch mutation | CONFIRMED both ways: never bypasses; author mut_latch_zombie + my lt_zombie_gate pin the served-dead-endpoint variant |
| (3) completeness | CONFIRMED + sharpened: partial re-anchor vs EMPTY modes; idx always reset→repop; finished can latch at the dead bank |
| (4) races | **"no observable change" FALSIFIED** off-anchor: net-zero mutation still requeries (edge-flagged) — observable via re-anchor; two-step restore byte-identical |
| (5) scope | **"only dependents" FALSIFIED**: global per-agent dirty; latched exempt; untestable on the landed single-agent surface |

## Impacted axes

- **depth**: model sharpens to "lazily invalidated for un-latched agents at
  the first forcing call after the next map sync; the setter→sync window
  serves and traverses the stale path; under latch never invalidated."
- **coverage**: same-turn zombie serve, net-zero-race re-anchor, global
  per-agent scope are measurable but NOT pinned by the landed arms.
- **calibration**: the sync-blind honesty gate silently rejects wait:0
  mutate arms — a documented requirement, not an active failure.

## Smallest safe corrections (fixable wording + one doc line; nothing blocks the move)

1. Header: "no dead-hop point is ever SERVED" → "no dead-hop point is
   served once a physics frame has synced the mutation; inside the
   setter→sync window the stale path is served and pop-traversed." One
   line; removes the falsified universal.
2. `_apply_mutation`/arm docs: note mutate steps require wait≥1 for the
   `_final_srv_state` gate to read post-sync truth (same-turn mutation arms
   fail the gate, not the semantics). One comment line.
3. Optional future arms if the lane wants the window pinned: `wait:0`
   mutate + pure/peek expectations (needs gate relaxation or a peek_only
   trailing step); two-agent fixture for the global-scope claim.

Bounded: one engine build, one host, 60 Hz, teleports not locomotion,
single region + island + one server link (two agents in my scratch only).
Not probed: node-authored NavigationLink3D mutation, cost mid-run mutation,
multi-region maps, map_set_cell_size, avoidance. No tracked files touched
by me; the author's diff is theirs. Leaf — no dispatch, no commits.

Evidence index: `corpus/live/r75-critic/runs/` (34 arms + iter_check ×
.stdout/.stderr/.exit), `corpus/live/r75-critic/battery-runs/` (two
verdicts.json: 11/11 mut + 60/60 prior detour),
`corpus/live/r75-critic/scratch/` (probe, iter_check.gd, project copy,
author-fixture working copy with the wait:0 arm).
link_get_enabled staleness receipt (`runs/iter_check.stdout.txt`):

    PRE  iter=1 en=true
    SAME iter=1 en=true        <- link_set_enabled(false) issued this turn
    POST5 iter=2 en=false      <- first sync applies it
