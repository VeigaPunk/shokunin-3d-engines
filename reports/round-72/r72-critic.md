# game-dev-3d round 72 — critic (seat: critic, host: devin)

Scope of attack: falsify the r71-boundary-derived depth claim the lane wants
to formalize — "`path_desired_distance` pops waypoints by Euclidean distance
to the AGENT position (not path-sum), saturating at the last index;
`is_navigation_finished` has two modes — reachable: `euclid(agent, raw
target) < tdd` strict; unreachable: `euclid(agent, clamped final) <= ~pdd`".

Probe: `corpus/live/r72-critic/scratch/r72c_pdd.gd` (sha256
`2a9198615231591ce85ab7a7c0e0d40e26630c3a2c55fc2f1c0fa70effd6aa97`), plus a
verbatim `project.godot` (sha256 `1fda90d4…23`, byte-identical to the
committed seed). Godot `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot --headless`; 60 tps; cell_size 0.25; 30-frame settle;
stationary single-region agents — same authoring pattern as
`navagent3d_detour.gd` and the r71 boundary probe.

Command shape per arm (receipts `corpus/live/r72-critic/runs/<arm>.stdout.txt`
/ `.stderr.txt` / `.exit`):

    godot --headless --path corpus/live/r72-critic/scratch \
        --script res://r72c_pdd.gd -- --geo={l,u,s} [--tx= --tz=] \
        [--pdd=F] [--tdd=F] [--sy=F] [--postproc=N]

41 probe invocations + 6 verbatim author-arm replays (working-tree
`navagent3d_detour.gd` sha256 `ea722a75…a0`, copied to
`scratch/author_navagent3d_detour.gd`), all exit 0, all stderr files
empty/banner-free, `u_gap_pdd2.3` rerun byte-identical
(`u_gap_pdd2.3_repeat.stdout.txt`).

## Geometries

- **l** — the r70 L-corridor verbatim (independent re-implementation of the
  boundary geometry; replication surface).
- **u** — authored U/hairpin, 5 quads with exact shared edges: A
  [0,1]×z[0,3], portal strip [0,3]×z[3,4] split into three quads, B
  [2,3]×z[0,3]. The routed path folds back toward the agent:
  `path=[S,(1,0,3),(2,0,3),F]` with per-waypoint Euclidean distances
  `[0, 2.549510, 2.915476, 2.061553]` — **non-monotone**: every intermediate
  waypoint is farther than the final (2.061553). Pathsum 6.590891. This is
  the geometry the L-corridor cannot express — it separates "distance to
  final" from "distance to the current waypoint" and "index saturation".
- **s** — straight single quad [0,2]×z[0,4]: 2-point paths with
  exactly-representable distances (euclidF 3.5, 1.5, euclidT 1.0, final→T
  gap 0.5) for clean equality cells.

## Attack (a): pdd pop keys on path-sum, not Euclidean — FAILS

The Euclidean basis is re-confirmed on a *stronger* geometry than r71's
single dogleg:

| arm | path[idx] under test | euclid | pathsum-to-date | pdd | result |
|---|---|---|---|---|---|
| u_gap_pdd3.0 | path[2]=(2,0,3) | 2.915476 | 3.549510 | 3.0 | idx=3 — **popped past a waypoint whose pathsum exceeds pdd** |
| l_gap2_pdd2.0 | path[2]=(2,0,1) | 1.581139 | 2.581139 | 2.0 | idx=3 (replicates r71) |
| u_gap_pdd2.549509 / .549510 | path[1]=(1,0,3) | 2.549510 (=√6.5) | 2.549510 | ±1e-6 bracket | idx=1 vs 2 — strict `<` at sub-printed-digit resolution |

A path-sum basis predicts idx=2 on `u_gap_pdd3.0` (3.549510 > 3.0); measured
idx=3 — Euclidean. The hairpin adds what gap2 could not show: the metric is
per-current-waypoint Euclidean **even when the final point is Euclidean-nearer
than the intermediate** (wpdist 2.92 > 2.06 along the same path).

**Structural sharpening the claim is missing**: the pop is *sequential* — it
only ever tests `path[current_index]`. On `u_gap_pdd2.3` the final waypoint
sits at euclid 2.0616 < pdd yet idx stays 1: a Euclidean-close final cannot
leapfrog a Euclidean-far intermediate. "Pops waypoints by Euclidean distance
to the agent" is metric-correct but structure-incomplete; a global
nearest-waypoint model is refuted by the same arm.

Pop strictness: `<` strict, not inclusive. `u_gap_pdd2.5_pp1`
(edgecentered): path[1]=(0.5,0,3) at euclid **exactly 2.500000** vs pdd=2.5 →
idx=1, no pop. This resolves r71's "inclusive-ish" reading — √2.5 =
1.58113883 < the printed arg 1.581139, so the earlier "equality pop" was a
sub-digit float artifact.

Pop origin basis: `s_yoff2_pdd1.5` (agent floated to y=2, path still
authored from clamped projection): dist(agent, path[0]) = 2.0 > 1.5 → idx=0,
**no pop** — a path[0]-relative basis reads 0 and would pop. The distance is
keyed on the live 3D agent position, and in 3D not 2D (`s_yoff2_pdd4.0`:
euclidF_3D 4.031129 > 4.0 → finished=false though the xz-plane distance
3.5 < 4.0).

## Attack (b): saturate-at-last-index fails under large pdd — FAILS

pdd=1000 on all three geometries: idx stops exactly at `size−1`
(2 on the 3-pt L path, 3 on the 4-pt U path, 1 on the 2-pt S path), never
`size`; `next`/`next2` keep returning the final point; reachable arms keep
`finished=false` (`l_detour_pdd1000`, `u_reach_tdd2.0_pdd1000`). pdd=0 →
idx=0 (no pop — strict `<` on zero distance). The last index is entered when
the *penultimate* waypoint is within pdd; the final itself is never popped
through. Saturation claim holds.

## Attack (c): is_navigation_finished uses a third basis — **LANDS**

The declared unreachable-mode model `euclid(agent, clamped final) <= ~pdd`
is refuted in BOTH its conjunct structure and its strictness:

| arm | euclidF | pdd | idx post-pop | finished | pure-euclid-final predicts |
|---|---|---|---|---|---|
| **u_gap_pdd2.3** | 2.061553 | 2.3 | 1 (blocked: wp1 at 2.5495) | **false** | true — **refuted** |
| **u_gap_pdd2.6** | 2.061553 | 2.6 | 2 (blocked: wp2 at 2.9155) | **false** | true — **refuted** |
| u_gap_pdd3.0 | 2.061553 | 3.0 | 3 = last | true | true |
| s_gap_pdd3.5 | 3.500000 | **3.5** | 1 = last | **false** | `<=` predicts true — strictness refuted |
| s_gap2_pdd1.5 | 1.500000 | **1.5** | 1 = last | **false** | `<=` predicts true — second exact cell |

`u_gap_pdd2.3` is the money arm: the agent is within pdd of the clamped
final (margin 0.238447, ~60× the 0.004 fixture tolerance), unreachable
selector engaged, and finished stays false because the pop loop is blocked
one waypoint short of the last index. r71 proved "idx at last is
insufficient"; this arm proves the converse — **euclid-final < pdd is also
insufficient**. The unreachable gate is conjunctive:

    finished_unreachable ≡ idx == path.size()−1  AND  euclid3D(agent, final) < pdd   (strict)

Equivalent restatement at quiesced state: remaining path distance < pdd
(`remaining` column in every PROBE line; provably identical to the conjunct
post-pop since remaining ≥ euclid(agent, path[idx]) ≥ pdd whenever
idx < size−1). Both restatements fit all 41 arms; the declared model does
not.

Reachable mode, by contrast, is verified **pure**: `u_reach_tdd2.5_pdd1`
fires finished=true with idx=1 and remaining=6.099 — no path-consumption
conjunct on the reachable side. And mode-purity holds both ways:
`u_reach_tdd2.0_pdd1000` (idx=3 saturated, euclidT==tdd) and
`u_gap_tdd0.5_pdd1000` (selector flipped reachable at gap==tdd) both keep
finished=false — no pdd channel leaks into reachable mode.

The reachable/unreachable selector is `euclid(final→target) <= tdd`
**inclusive**: u_gap bracket 0.49→false / 0.5→**true** / 0.51→true, and
`s_gap_tdd0.5` reproduces on the straight corridor (0.5==0.5 → reachable).
Consistent with r71.

Ordering note (free measurement): `fin_early`/`reached` columns show
`is_navigation_finished`/`is_target_reached` themselves force the lazy
update **and the pop** — idx advances 0→1 on those calls before
`get_next_path_position` runs (idx0/idx1 split on every arm). Finished is
never a stale flag on this probe's read order; all 41 arms show
early==post.

## Attack (d): equality edges — strictness resolved

| gate | equality point | measured | verdict |
|---|---|---|---|
| reached / finished (reachable mode) | euclidT==tdd: 1.0==1.0 (s), 2.0==2.0 (u) | reached=false, finished=false | **strict `<`** — claim's wording correct |
| finished (unreachable mode) | euclidF==pdd: 3.5==3.5, 1.5==1.5 (s, two cells) | finished=false | **strict `<`** — claim's `<= ~pdd` wrong |
| waypoint pop | euclid==pdd: 2.5==2.5 (u, edgecentered wp1) | no pop | **strict `<`** |
| reachable selector | gap==tdd: 0.5==0.5 (u and s) | reachable=true | **inclusive `<=`** |

The asymmetry r71 reported (reached strict, reachable inclusive) is
confirmed at exactly-representable constants on two geometries; the
unreachable finish gate shares the strict `<` of the pop predicate, not an
inclusive `<=`.

## Verbatim replay — the landed artifact already carries the correction

The working-tree `navagent3d_detour.gd` (sha256 `ea722a75…a0`, author's
uncommitted r72 arms) was replayed in my scratch; six discriminating arms
all PASS byte-exact (`runs/author_*.stdout.txt`):

- `fin_idx_gate` — agent teleported **onto** the clamped final
  (euclidF = 0 < pdd=1.0) yet finished=false because idx stayed 1: the
  author's own encode of my `u_gap_pdd2.3` counterexample, stronger (exact
  zero distance).
- `fin_wall` — **a cell my matrix missed**: reachable=false, reached=true
  (teleport adjacent to the raw off-mesh target through the wall) →
  finished=true. The complete model is
  `finished = reached OR (¬reachable ∧ idx==size−1 ∧ euclidF < pdd)` —
  my probe never placed an agent near an off-mesh raw target, so my arms
  alone could not see the OR clause. The author's header comment states it.
- `tp_eq`, `vert_fin_eq` — pop and finish strictness at exact equality
  (teleport-to-exactly-pdd → no pop; euclidF=3.0 vs pdd=3.0 → no finish),
  matching my strict-`<` pins.
- `edge_unr`, `pop_hi` — unreachable finish via idx+pdd clause and
  saturation replication.

So the declared claim text is falsified, but the **landed fixture is not**:
it already encodes the conjunctive unreachable gate, strict `<` on all three
distance sub-gates, the `reached OR` channel, and latch semantics
(`fin_latch` — reached/finished persist after the agent teleports back
out). The remaining defect is in the *claim wording* the round was
dispatched with, not the artifact.

## Impacted axes

- **quality / discernment**: the lane's declared claim is wrong in two
  load-bearing details — unreachable finished is conjunctive
  (`idx==last ∧ euclidF < pdd`, strict; equivalently remaining-path-distance
  < pdd at quiescence), and its strictness is `<` not `<= ~pdd`. The pop
  clause needs "sequential, current-waypoint only, strict <, live 3D agent
  position". All corrections are already present in the author's landed
  CASES rows; the fixable defect is that the *declared model* — what
  reviewers/judges would check the diff against — understates the gate.
- **expansion**: unaffected; claim's skeleton (two modes, selector,
  Euclidean metric) survives.

## Verdict summary

| attack | result |
|---|---|
| (a) path-sum pop | FAILS — Euclidean re-confirmed, non-monotone path, sub-digit bracket |
| (b) saturation overrun | FAILS — idx ≤ size−1 at pdd=1000 on 3 geometries |
| (c) third basis | **LANDS** — unreachable finish is conjunctive (idx==last ∧ euclidF<pdd strict), not pure distance-to-final; reachable mode verified pure-tdd-strict |
| (d) equality edges | reached/strict, unreachable-finish/strict (not `<=`), pop/strict, selector/inclusive |

Bounded: one engine build, one host, stationary agents (teleport cells only
via author's replayed fixture), pure-server regions, 30-frame settle;
unprobed — moving agents mid-pop (the conjunctive restatement may separate
from remaining-path-length under motion), avoidance, `path_max_distance`,
multi-region maps, multi-frame pop across lazy updates.

Receipts: `corpus/live/r72-critic/runs/` (47 arms × .stdout.txt/.stderr.txt/
.exit), probe `corpus/live/r72-critic/scratch/r72c_pdd.gd`, replay copy
`scratch/author_navagent3d_detour.gd`. No tracked files touched, no
commits, leaf — no dispatch.
