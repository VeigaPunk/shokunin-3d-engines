# Game-dev-3d round 77 — boundary (revenger): mutation APPLY-ORDER, edge-probed

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r77-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (pin mutation APPLY-ORDER as a
measured axis: is `_apply_mutation`'s fixed order
delete→recreate→transform→link→agent→map load-bearing or inert; land a
`map_force_update` CASES arm; land a wait-ladder verdict-groups receipt;
163 prior rows byte-stable) is owned by the author seat. My assigned
recon — the four probe edges from the brief — runs on my own scratch
harness independent of the tracked arms:

1. triple+ mutation orders — 3-setter permutations: is order a pairwise
   or a global effect?
2. apply-order × physics-callsite interaction — does same-tick order
   matter more inside `_physics_process`?
3. `map_force_update` under `map_set_active(false)` — does force re-arm
   sync on an inactive map?
4. verdict-group granularity — tuple fields where distinct states share
   a signature.

## Deliverable and method

`corpus/live/r77-boundary/scratch/navagent3d_applyorder.gd` sha256
`1be40ce34a54614320a3b1c48f7187375505abcd1bccd56422fab52e0a86f3a6` —
SceneTree probe. Geometry verbatim from the r70 L-corridor + r73 island +
r73 server bridge link (identical to r76-boundary `navagent3d_syncwin.gd`):
A1 x[0,2]z[0,1], A2 x[2,3]z[0,1], B x[2,3]z[1,4], C x[2,3]z[5,6]; link
ls=(2.5,0,3.5)→le=(2.5,0,5.5); agent S=(0.5,0,0.5)→T=(2.5,0,5.5); path
WITH link `[S,(2,0,1),ls,le]`, WITHOUT `[S,(2,0,1),(2.5,0,4.0)]`.
`project.godot` byte-identical to the tracked seed (sha256
`1fda90d4…8eac23`). Godot `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot --headless`, 60 tps, cell_size 0.25, 30-tick settle;
the deferred query is materialized once before `pre` is captured.

The instrument is a **same-turn ordered sequence applicator**
(`_apply_seq`, driven by `--seq=Op,Op,…`) plus the r76 per-frame
transition sampler (one forcing call per physics frame; `fstar` = first
frame index — 0 = same GDScript turn — whose served-path signature
differs from the pre-mutation array). Ops mirror the fixture's mutate
dict keys 1:1 (`Rdel`/`Rrec` rebind `srv["region"]` exactly as
`_apply_mutation` does; `Rx03`/`Rx5` carry the same `region.is_valid()`
guard). A `_truth()` digest (`map_get_iteration_id`,
`link/region_get_iteration_id`, `link_get_enabled`,
`region_get_transform`, `map_is_active`, `agent.navigation_layers`)
records server-side truth alongside the served tuple, so a write that
LANDS but stays serve-invisible is separated from a write that never
applied. `PhysMutator` (Node3D `_physics_process`, fires the seq at its
tick 2) is the r76 callsite instrument — the coroutine resumes after the
firing tick and samples f0 = first post-tick read.

Command shape per arm:

```
timeout 120 /usr/bin/godot --headless --path corpus/live/r77-boundary/scratch \
    --script res://navagent3d_applyorder.gd -- --arm=<name> [--seq=Op,Op,...]
```

129 runs under `corpus/live/r77-boundary/runs/` (`<name>.stdout.txt`,
`.stderr.txt`, `.exit`) via `run_arms.sh` + the extra sequence arms —
every run exit 0, every stderr empty, every repeat family byte-identical
(md5: `ord3_rdel_rrec_rx03` ×3 `30907cbd…`, `ord3_rx03_rdel_rrec` ×2
`53709c2c…`, `phys_ord3_drt` ×2 `36a29d37…`, `fu_off_queue` ×2
`86ab8bc8…`, `fu_mid` ×2 `57f2c404…`, `vg_ladder` ×2 `a68c0cf5…`).

## (1) Triple+ mutation orders — order is REAL and PAIRWISE, via two mechanisms only

All six permutations of the destructive triple {`Rdel`, `Rrec`, `Rx03`}
(region delete / recreate / transform +0.3x), one turn, coroutine
context (`runs/ord3_*.stdout.txt`):

| order | fstar | served timeline | final state |
|---|---|---|---|
| `Rdel,Rrec,Rx03` (**= fixture order**) | 2 | stale ×2 → **path `[]` ×2** → moved | `(0.5,0.5)(2.3,1.0)(2.5,3.5)(2.5,5.5)` reachable=true |
| `Rdel,Rx03,Rrec` | 2 | stale ×2 → `[]` ×2 → restored | `(0.5,0.5)(2.0,1.0)(2.5,3.5)(2.5,5.5)` reachable=true |
| `Rx03,Rdel,Rrec` | 2 | stale ×2 → `[]` ×2 → restored | unmoved path (transform bound to the freed RID, lost) |
| `Rrec,Rdel,Rx03` | 2 | stale ×2 → `[]` forever | region **gone**: `next=S final=(0,0,0) reachable=false` |
| `Rrec,Rx03,Rdel` | 2 | stale ×2 → `[]` forever | region gone |
| `Rx03,Rrec,Rdel` | 2 | stale ×2 → `[]` forever | region gone |

Three observably distinct post-sync states from one op multiset — the
declared claim ("at least one order-pair produces observable distinct
served state") is **CONFIRMED**, three separate ways:

- **RID-rebinding adjacency**: a write ordered before `Rdel` dies with
  the old RID; ordered after `Rrec` it lands on the new RID. The
  fixture's `region_transform` key (applied after delete/recreate)
  therefore lands on the recreated region — `Rdel,Rrec,Rx03` moves the
  corridor while `Rx03,Rdel,Rrec` and `Rdel,Rx03,Rrec` do not. This is
  exactly the brief's example pair (region_transform-then-delete vs
  delete-then-recreate).
- **Rrec-then-Rdel is fatal**: every order that deletes after
  recreating frees the NEW region — net state "no region at all", a
  third outcome class.
- **Same-field last-wins**: `Rx5,Rx03` serves the +0.3 corridor while
  `Rx03,Rx5` serves +5x (`ord2_rx5_rx03` / `ord2_rx03_rx5`; truth
  `region_x=0.30` vs `5.00`). Two writes to one field are
  order-sensitive by overwrite — trivially load-bearing.

Order-INERT families, same measurement:

- **Cross-object triples**: all 6 perms of {`Loff`, `Rx03`, `A2`}
  (`ord3x_*`) converge — `fstar=0` (the synchronous agent channel
  clears the path same-turn) and identical final tuple `[]` —
  `agent_layers=2` masks the whole map regardless of position.
- **Same-object different-field triples**: all 6 perms of {`Loff`,
  `Lmv`, `Llay`} (`ord3s_*`) coalesce to one wave at f2, identical
  dead-link clamp — r76's same-turn same-object coalescing extends to
  triples; no intermediate moved-but-alive state is ever served.
- **Map-off sequences**: `Moff,Loff,Mon` ≡ `Loff,Moff,Mon` (dead clamp
  lands at f2 — the off+on pair collapses to a same-value no-op round
  trip, matching r76 `ma_off_on_sameturn`); `Loff,Mon,Moff` leaves
  `link_en=false` queued-invisible forever (`fstar=-1`, `link_iter`
  stays 1 while `link_get_enabled` already reads false — the
  object-stored vs sync-stamped split again).

Four-op region permutations extend the same pattern (`runs/ord4_*`):
`Rdel,Rrec,Roff` serves the empty path (the disable lands on the NEW
region, `region_en=false`), while `Roff,Rdel,Rrec` serves the normal
corridor (the disable dies with the old RID — recreated region is
enabled). `Rdel,Rrec,Roff,Rx03` vs `Rx03,Rdel,Rrec,Roff` both end
region-disabled → identical served `[]`, but truth differs
(`region_x=0.30` vs `0.00`): under a disabled region the served tuple
cannot see whether the transform survived — a verdict-group collision
inside an order pair.

**Flush coupling is per-flush, not per-pair** (`ordf_*`): two link-class
writes + a region write in one turn (`Loff,Llay,Rx03`, `Rx03,Loff,Llay`,
`Loff,Rx03,Llay`) push the region landing to f4 — the SAME +1 the single
co-flush link write caused in r76 (`mw_sameturn_*`), not +2. And two
region writes co-flushed with a link (`Rx03,Rx5,Loff`, `Loff,Rx03,Rx5`)
land the region at f4 with the LAST transform value (+5x) — writes to
the same object coalesce before the push, the push counts once per
flush. So order sensitivity decomposes into pairwise relations
(RID-rebinding adjacency, same-field adjacency); the one non-pairwise
observable (the +1 flush coupling) is itself order-inert — a global
property of the shared flush, not of writer order. **Verdict: pairwise.**

The transient `[]` interlude is a two-phase seam: every permutation
containing both `Rdel` and `Rrec` serves the EMPTY path for exactly 2
frames (f2,f3) before the recreated region lands at f4 — an intermediate
served state that neither endpoint state carries, visible only inside
the composed mutation's window. (`free_rid` lands at its own edge f2 —
matching the r76 critic's `{free_rid:2}` class — while the recreated
region's mesh+map writes take the region rebuild cycle to f4.)

## (2) Apply-order × physics callsite — same partition, every edge −1 tick

Identical sequences issued inside `PhysMutator._physics_process`
(`runs/phys_*.stdout.txt`):

| seq | callsite | getter truth at resume | fstar | landing |
|---|---|---|---|---|
| `Loff` | coroutine (r76) | pending | 2 | dead clamp f2 |
| `Loff` | `_physics_process` | **`link_iter=2, en=false` already applied** | 1 | dead clamp f1 |
| `Loff,Lmv` / `Lmv,Loff` | physics | applied same tick | 1 | coalesced clamp f1, order-inert |
| `Loff,Rx03` / `Rx03,Loff` | physics | applied same tick | 1 | clamp f1, region f3 — order-inert, +1 coupling preserved |
| `Rdel,Rrec,Rx03` | physics | applied same tick | 1 | `[]` at f1,f2 → moved f3 |
| `Rx03,Rdel,Rrec` | physics | applied same tick | 1 | `[]` at f1,f2 → unmoved f3 |

The physics callsite shifts EVERY boundary one tick shallower (control
`phys_loff` fstar=1 replicates the r76 critic `bb_physmut` on this
geometry: the setter drains inside the firing tick, getters already
applied when the coroutine resumes). But the ORDER semantics are
untouched: the divergent triple still partitions into moved vs unmoved
by transform-vs-recreate position; the coalesced and cross-class
families stay convergent; the +1 flush coupling survives (region lands
f3 with a co-flush link write vs its solo-physics f2 — inferred from the
f4-vs-f3 coroutine structure, same relative shift). **Order does not
matter MORE inside `_physics_process` — it matters identically; only the
clock moves.** The apply-order axis is callsite-independent in a way the
window constants are not.

## (3) `map_force_update` under `map_set_active(false)` — it flushes the SETTER stage even on an inactive map, and on an active map it DOES collapse the serve edge once the setter stage ran

`runs/fu_*.stdout.txt`, both repeats byte-identical:

- **`fu_off_queue`**: map off → 3 frames → `link_set_enabled(false)`
  while off (queued: `link_iter=1`, `en=true` still) →
  `map_force_update` **while still off** → same-turn truth flips to
  `link_iter=2, link_en=false` — the force applies the queued setter to
  the object even though the map is inactive (`map_iter` stays 2 — no
  map sync is stamped). Served path while off: `fstar=-1`, the committed
  link tuple serves uninterrupted — consistent with query-inertness.
  Then `map_set_active(true)`: the dead-link clamp lands at **on+1**
  (`fstar=1` after reactivation), one frame EARLIER than the +2 a
  queued-without-force write needs (r76 `ma_off_mutate_inside`) —
  because the setter stage already ran under the force, reactivation
  owes only the rebuild.
- **`fu_off_bump`**: force on an inactive map with an EMPTY queue is a
  complete no-op — `map_iter`, `link_iter`, all truth fields unchanged
  same-turn and +1. So `map_force_update` is not itself a sync: it
  advances whatever sync stage is pending, and on an inactive map only
  the setter-apply stage exists.
- **`fu_mid`** (active map): `link off` → wait 1 (getters already
  applied, serve still stale — the r76 pinned regime) →
  `map_force_update` → **`map_iter` 2→3 same turn** and the forcing
  read serves the dead-link clamp IMMEDIATELY (`fstar=0`). The serve
  edge collapses once the setter stage has run — this REFINES r76's
  `bb_fu`, which only probed the same-turn force (w0) and found the
  serve edge intact at w0.
- **`fu_w0_w1`**: same-turn force applies the setter (`link_iter` 1→2,
  `map_iter` stays 2); a second force at w1 runs the rebuild
  (`map_iter`→3) and the read is fresh at w1. Two calls, two stages.
- **`fu_w0_only`** (same-turn kill+force, NO second force, read each
  frame, `runs/fu_w0_only_*.stdout.txt` ×20): the UNFORCED landing after
  a w0 force is a phase race — fresh at w1 in 20/20 bare-probe runs on
  this host, while the same sequence under the tracked fixture's heavier
  per-step instrumentation lands at w2 in 13/15 tracked-context runs
  (see post-cutoff). Both are the same boundary: the rebuild lands on
  the next SCHEDULED sync phase, whose position inside a frame window
  jitters with the caller's per-frame workload. Bound: serve edge after
  a w0 force ∈ {w1,w2} — never later, never same-turn.

Reconstructed mechanism (inference, marked): `map_force_update` advances
the pending stage of a two-stage pipeline — setter-apply (object truth)
then map-rebuild (the `map_iter` bump that feeds the agent's deferred
requery). At w0 only the setter stage is pending, so one force collapses
just the getter edge (r76's observation); at w≥1 the rebuild is pending,
so one force collapses the serve edge too. Under `map_set_active(false)`
the rebuild stage never exists — force still runs the setter stage
(object truth moves, `link_iter` stamps, `map_iter` does not), the serve
edge stays infinite, and the pre-applied write then lands at on+1 after
reactivation. **Answer to the brief: force does NOT re-arm sync on an
inactive map — no rebuild, no served-state change — but it DOES apply
queued setters, halving the post-reactivation window (on+1 vs on+2).**

## (4) Verdict-group granularity — the served tuple is blind to kill-mechanism, empty-path cause, `enter_cost`, `map_active`, and suppressed writes

`vg_ladder` (`runs/vg_ladder{,_r2}.stdout.txt`, byte-identical): ten
distinct mutations, fresh world each, tuple signature + truth digest at
w=pre,0..4. Grouping rows by identical served tuple:

- **Dead-link group** (`idx=1/1 next=(2,1) final=(2.5,4)
  reachable=false path=[S,(2,1),(2.5,4)]` at w≥2): `Loff`
  (`link_en=false`), `Llay` (layers=2, `link_en` still true), `Ldel`
  (RID freed outright). Three truth-distinct kill mechanisms — one
  signature. `vg_ladder_pair` confirms convergence inside one world:
  `Llay` at w≥2 serves byte-identically to the subsequent `Ldel`
  ladder. A verdict-groups receipt derived from served-signature
  partitions cannot separate disable vs re-layer vs free.
- **Empty-path group** (`idx=0/0 next=S final=(0,0,0) reachable=false
  path=[]`): reached by `Rdel` at **w2** (free_rid-class edge), `Roff`
  at **w3** (region-class edge), `A2` at **w0→1** (synchronous channel —
  `idx=1/0` at w0). Same signature, three different partition
  boundaries — the wait-ladder correctly bounds each mutation's edge
  but the group itself is three causally distinct states.
- **Baseline-collision group** — identical to the pre-mutation tuple at
  EVERY wait: `Lent` (`enter_cost=50`; landed — `link_iter` bumps to 2 —
  but serve-invisible, the r73 anomaly as a verdict-group), `Moff`
  (`map_active=false` — invisible forever), `Lon_same` (same-value
  write, suppressed — `link_iter` stays 1, no dirty). For these
  mutations the partition boundary DOES NOT EXIST: the window bound
  derived as a signature-partition boundary is undefined when the
  mutation never leaves the baseline group. Any verdict-groups receipt
  must carry the truth digest (or an explicit "no-transition" class)
  alongside, else a landed-inert write and a lost write are
  indistinguishable.
- **Window-transient group**: at w1 the stale tuple is shared by states
  whose getter stage already diverged (`Loff` w1 has `link_en=false`,
  `Llay` w1 still `en=true`) — mid-window rows also collide.

So the tuple fields pin {idx, next, final, dist, reachable, reached,
finished, path} — blind fields observed: link enabled/layers/validity
(within the dead outcome), region enabled/validity and agent layer
membership (within the empty outcome), `enter_cost`, `map_active`, and
the suppressed-vs-never-written distinction. That is the granularity
ceiling a signature-partitioned verdict receipt inherits.

## Reconstructed contract (evidence chain)

1. `_apply_mutation`'s fixed order **is load-bearing**, not inert:
   `delete→recreate→transform` is the only ordering of that triple that
   lands the transform on the live region. The mechanism is RID
   rebinding — writes bind whichever RID is current at their position
   in the sequence — plus same-field last-wins. Claim CONFIRMED;
   "order-pair" is the right granularity (the effect is pairwise).
2. Apply-order is callsite-independent: inside `_physics_process` every
   phase boundary is −1 tick but the order partition is identical.
3. `map_force_update` advances the pending sync stage: setter-stage
   pending → getter edge collapses (even on an inactive map); rebuild
   pending → serve edge collapses. It never re-arms an inactive map's
   rebuild, and on an empty queue it is a no-op.
4. Wait-ladder verdict groups partition by served signature only;
   collisions measured above bound what such a receipt can see.

## Suggested battery surface (for the author / verifier)

- The discriminating arm is the triple {delete,recreate,transform}: the
  fixed order must serve the MOVED corridor (`(2.3,1.0)` bend); a
  hand-ordered transform-first arm must serve the unmoved one. If a
  landed order-override arm asserts convergence of those two, it
  falsifies on this build (measured divergence, byte-stable ×3+2).
- A verdict-groups arm must treat `enter_cost`, `map_set_active`, and
  same-value writes as "no partition boundary" — they sit in the
  baseline group at every wait.
- `map_force_update` arms: same-turn force collapses getters only;
  wait≥1 force collapses the serve edge to same-turn (fresh read at
  `fstar=0`); under `map_set_active(false)` force stamps the queued
  setter (`link_iter` bumps) without any serve or `map_iter` change,
  and post-reactivation landing is on+1 not on+2.
- Physics-callsite order arms pin identical partitions one tick
  shallower; coroutine constants {f2 empty-phase, f4 region-landing}
  become {f1, f3}.

## Divergences and honest caveats

- The +1 flush coupling's pipeline mechanics remain inference (r76
  carry-over); my runs pin only its order-inertness and per-flush
  arity.
- The `map_force_update` two-stage model is reconstructed from iter
  stamps + serve edges; the engine's internal queue structure is not
  directly observed — inference, flagged.
- `Rx03` applied to a region that a later op frees was verified to die
  with the RID (`Rx03,Rdel,Rrec` → unmoved); I did not test transform
  on an invalid RID directly — my op guard mirrors the fixture's
  `is_valid()` check, so `Rdel,Rx03,Rrec` skips rather than errors.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 Hz physics, 30-tick settle, teleport-motion only, single
  region/link per map — same bounds as r72–r76.
- At probe-start the tracked fixture carried no r77 code: canonical
  HEAD `e417365` (r76 report-last), `run_battery.py` CASES = 163 rows
  at HEAD (counted: `git show HEAD:corpus/fixtures/run_battery.py |
  grep -cE '^    \("'` = 163). The author's landing arrived mid-session
  (and was amended once, mid-battery) — receipts below.

## Post-cutoff: author landing verification

**Landing receipt.** `git status --porcelain corpus/fixtures/` =
`M navagent3d_detour.gd`, `M run_battery.py` on HEAD `e417365`.
`git diff HEAD --numstat`: `navagent3d_detour.gd` **+501/−33**,
`run_battery.py` **+20/−0** — the CASES diff is a single appended hunk
(`@@ -209,6 +209,26 @@`): 10 new rows appended after `mut_same_agent`,
163→173 rows, **zero deletions/modifications — all 163 prior rows
byte-stable by construction**. Working-tree fixture sha256
`fa4eb04af0387ac27c1bc4ec9aa782613e8b911da8b7a991852dc5ccb8832e77`;
my replay copy `scratch/navagent3d_detour_wt.gd` is byte-identical
(same sha). Whole-diff digest
(`git diff HEAD -- corpus/fixtures/ | sha256sum`):
`852ef599e6e01f0e8d4680481d8ba0468c9c84b133315774ce7cb9379c5492a7`.
(A first landing ~08:13, fixture sha `a967f012…`, was amended
~08:20–08:21 — the amendment is entirely the `mut_force_link` arm +
comments, below.)

**What landed.** `mutate` accepts an ARRAY of dicts = a hand-ordered
sequence through `_apply_mutation` (`navagent3d_detour.gd:1679`); a
dict still runs the fixed order. New keys `link_start`/`link_end`,
`map_force` (`_apply_mutation:2215`; `map_force_update` at `:2255` —
placed after every RID/agent write, before `map_active`, so a
force+deactivate dict flushes then freezes). New step key `srv_get`
(`_read_srv:2269`) asserts object-getter truth alongside the served
tuple; `_tuple_sig` (`:2031`) canonicalizes all tuple fields + the full
path for the ladder partitions; `_final_srv_state` (`:2294`) folds
array mutations in sequence.

**Replay vs CASES strings — 10/10 byte-exact**
(`runs/author_arms_v2_verdicts.json`, `author_arms_v2.out`:
`replay: 10/10 exact`; each arm's stdout marker matched the CASES
string verbatim, exit 0 each).

**Cross-check vs my independent table — full agreement:**

- `mut_ord_renew_xform` (dict: delete→recreate→transform+5x): srv_get
  `region_transform=(5,0,0)` at w0 — the transform LANDED on the
  recreated RID; served `next=(5,0,0.5) final=(5,0,1.0)` reachable=false
  (off-mesh clamp inside the moved region). `mut_ord_xform_renew`
  (array: transform→delete→recreate): srv_get `region_transform=(0,0,0)`
  — the transform died with the freed RID; served the unmoved corridor,
  reachable=true. **The tracked order pair diverges exactly as my
  `Rdel,Rrec,Rx03` vs `Rx03,Rdel,Rrec` measured — claim CONFIRMED in
  the fixture's own arms** (theirs moves +5x → off-mesh class, mine
  +0.3x → moved-connected class; same RID-rebinding mechanism).
- `mut_ord_link_offmv` / `mut_ord_link_mvoff`: identical dead clamp
  `final=(2.5,4)`, srv_get `link_enabled=false` + moved endpoints both
  orders — writes on a disabled link still land; order-inert pair,
  matches my `Loff,Lmv`/`Lmv,Loff`.
- `mut_ord_kill_mapoff` / `mut_ord_mapoff_kill`: committed tuple served
  while off, dead clamp after reactivation, srv_get pins
  `{map_active,link_enabled}` per step — matches `fu_off_queue`'s
  frozen-map regime + r76 replay-on-reactivation.
- `mut_force_ctl`: srv_get at w0 shows `link_enabled=true,
  link_iter=1` — the unforced setter sits QUEUED at w0 (cleaner
  evidence than r76's serve-only observation), applied w1, serve fresh
  w2 = the deterministic {link:2f} edge.
- `mut_ladder_link` → `bound=2 groups=2 sizes=2,2`;
  `mut_ladder_region` → `bound=3 groups=2 sizes=3,2` — the r76
  {link:2f, region:3f} edges re-derived as signature-partition
  boundaries. The partition IS the verdict-groups receipt §4 scoped:
  identical served tuples collapse into one group and the bound lands
  on the first signature change — no hand-pinned per-step assertions.

**`mut_force_link` — measured nondeterminism, honestly reported.**
The FIRST landing pinned a w1 step expecting the stale bridge
(`final=(2.5,5.5)`). First battery run
(`battery/20261014T111927336306Z/verdicts.json`): FAIL exit1 —
actual w1 already served the dead clamp:
`step1 final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000`.
That same run's `seeds_unchanged=False` was the author amending the
seed MID-RUN (mtimes 08:20:48/08:21:02 inside the battery window) —
superseded receipt, not a seed leak. Distribution on the first version
(`runs/force_link_r*.exit`): **2×exit0 / 13×exit1**; the unforced
control `force_ctl_r*`: **10×exit0** — the race is confined to the
forced arm. My independent sampler agrees the boundary is JITTERED,
not collapsed: bare-probe `fu_w0_only` landed fresh at w1 in 20/20,
the heavier tracked-step context lands w2 in ~87%. The author
measured the same jitter and amended the arm: it now pins only the
two deterministic facts — w0 {srv_get `link_enabled=false,link_iter=2`
+ stale serve} and w3 fresh clamp — and documents the jitter inline
(`navagent3d_detour.gd:1842`: "the serve boundary under force is
JITTERED — fresh at w1 on some runs, w2 on others on this host").
Amended-arm repeats `runs/fl2_r*.exit`: **8/8 exit0, byte-identical
marker** (`steps=2 … final=(2.5,4)`). Consistent with §3's two-stage
model: the w0 force deterministically drains the setter stage
(`srv_get` stable at w0); the rebuild stage runs on the next scheduled
sync phase — the w1-vs-w2 split — and a SECOND force (my `fu_w0_w1`)
drains it deterministically.

**Battery on the amended diff — clean PASS.**
`python3 run_battery.py --godot /usr/bin/godot --runs
<abs>/corpus/live/r77-boundary/battery --probe-failing` →
`totals: cases=173 pass=173 fail=0 ordinary=128 negative_controls=45
probes=1`, `BATTERY EXIT=0` (full log `corpus/live/r77-boundary/
battery_full_v2.log`), verdicts at
`battery/20261014T112435550995Z/verdicts.json`; the `--probe-failing`
witness `mutant_body3d_contact` detected=True `seeds_unchanged=True`
(FAIL line = the deliberate scratch mutant being caught). Every one of
the 163 prior markers replayed byte-exact under the amended fixture.
Node frozen-tree suites (`receipts/run_*.json`): 31/31 — cases 3/3,
layer 4/4, order 9/9, camera 5/5, ortho 5/5, ray 5/5, all
`seeds_unchanged=true`.

**Boundary verdict on the r77 axis:** apply-order is LOAD-BEARING
(pairwise, via RID-rebinding adjacency + same-field last-wins) and
callsite-invariant (only the clock shifts); `map_force_update` drains
the pending sync stage — deterministic for setters (even under
`map_set_active(false)`), jittered one-phase for the rebuild, never
re-arms an inactive map; the signature-partition wait-ladder is a sound
window-bound instrument with the blindness set enumerated in §4.
