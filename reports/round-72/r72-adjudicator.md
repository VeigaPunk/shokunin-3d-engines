# r72 Sol adjudicator — game-dev-3d lane, wave `shokunin-train-20261013-w3`

Adjudicator: Sol (parent session), host devin, 2026-10-14. Scope: round 72 declared depth move — formalize `path_desired_distance` waypoint-pop semantics and two-mode `is_navigation_finished` as tracked arms; prior 90 rows field-stable.

## Declared claim (verbatim)

"pin pdd pop-point index vs agent-position as tracked arms on the L-corridor, plus the two is_navigation_finished modes with equality-edge cases (euclid exactly == tdd reachable vs unreachable)."

## Measured result

**CONFIRMED with wording corrections absorbed.** The landed model (22-arm preset table, `_arm_cfg` carries authored expectations — rows cannot tune themselves):

- **Pop loop**: `idx` advances while `idx < size−1 && euclid(agent, path[idx]) < pdd` — **strict**, sequential (cannot skip), keyed on live 3D agent position over the fixed stored path, saturates at `size−1` (pdd=1000 never exceeds). Euclidean re-confirmed on the critic's non-monotone U-hairpin where path-sum and Euclidean orderings differ.
- **`reached`** = `euclid(agent, raw target) < tdd` — strict, through-wall (ignores reachability), latched.
- **`reachable`** = `euclid(final→target) ≤ tdd` — inclusive at equality (only inclusive gate in the family), agent-independent.
- **`finished`** = `reached OR (¬reachable ∧ idx==size−1 ∧ euclid(agent, final) < pdd)` — strict, latched; non-monotone in tdd (sawtooth T,F,T across the inclusive selector flip measured).

**Critic correction absorbed**: r71-boundary's `<= ~pdd` resolves **strict** at exact equality; the unreachable clause is conjunctive — `idx==size-1` required (critic's `u_gap_pdd2.3` counterexample: euclid(agent,final)=2.0616 < pdd=2.3 yet finished=false while pop blocked at idx=1). The author's landed artifact already encodes the corrected model (critic replayed 6 arms byte-exact); defect was claim-wording, not artifact. Scribe refuted scout's headline formula for the same missing conjunct — resolved in favor of the author's formulation.

## Adjudicator's own reproduction (committed tree, HEAD `05405ae`, fresh scratch project)

| arm | observed | verdict |
|---|---|---|
| `vert_pop_eq` | idx=1 at exact euclid==pdd=1.0 → strict `<` confirmed | PASS exit 0 |
| `vert_pop_above` | pdd=1.01 → idx=2 pops | PASS exit 0 |
| `pop_sat` | pdd=5.0 → idx=2=size−1 (never size) | PASS exit 0 |
| `fin_idx_gate` | agent 0.1-adjacent to final, idx=1 → finished=false | PASS exit 0 |
| `edge_unr` | unreachable mode finished=true | PASS exit 0 |

## Seat-evidence audit

| seat | landed | key evidence |
|---|---|---|
| author | `r72-author.md` + tracked +297/−1 +44/−0 | 112/112 battery, 90×12 prior 0-mismatch, Node 31/31, falsification path per clause |
| critic | `r72-critic.md` | U-hairpin non-monotone re-confirmation; `u_gap_pdd2.3` idx-conjunct counterexample LANDS; saturation/equality edges all measured strict |
| reviewer | `r72-reviewer.md` | r71 audit AGREE-all; byte-exact arm replays; fixture/runner sha256s match r71 verifier's cited values |
| baseline | `r72-baseline.md` | frozen `996ea37` 90/90 + 4 probes + Node 31/31; engine defaults confirmed (no fixture sets pdd) |
| scout | `r72-scout.md` | per-arm predicted table (14 rows); both gates strict measured; traps flagged (clamp-tie, lazy-update ordering) |
| scribe | `r72-scribe.md` | lesson + LOG drafts (landed `corpus/lessons/r72-navagent-pdd-finish-review.md`); 29-arm own probe + 22/22 verbatim author-arm replay; scout-formula conflict resolved |
| boundary | `r72-boundary.md` | off-mesh links authorable headlessly (link_create + NavigationLink3D node; metadata annotation-only); **`distance_to_target` is live call-time arithmetic** (not per-frame re-query); path array frozen at first query; reached/finished latch; only target_position re-assignment re-queries (re-anchors at clamped live position) |
| verifier | `r72-verifier.md` | **AGREE all five claims** — 112/112 (`seeds_unchanged`, 52/52 digests), 90×12 fields 0-mismatch, 16/16 spot-checks verbatim, Node 31/31, commits resolve; one non-blocking trap found: relative `--runs` fails tree-timeout probe closed (pre-existing; docstring note recommended) |
| simplifier | pending | last seat in flight at adjudication time — landing with report-last commit if it arrives; verdict stands on critic+verifier convergence |

## Disclosures recorded

- Verifier's `--runs` relative-path trap: `run_battery.py:534-536` matches a relative scratch prefix against globalized absolute `/proc` cmdline → `witness_verified=false` fails closed. Pre-existing runner property (present at `996ea37`), safe-direction. Recorded as a docstring-note candidate for a future round.
- Author caveats retained: vertex/edge-spawn arms are this-mesh pins; teleport arms pin position re-evaluation not tracked locomotion; irrational-boundary float edges fragile; latch-release conditions unprobed.
- XConnector synthesis proposal (next-round candidate): 2d could adopt 3d-style liveness-gated acceptance for marker reads (while-live marker gate); recorded, not this round's scope.

## Per-axis verdicts

- **depth: improved locally** — pdd pop law resolved to strict sequential Euclidean keyed on live position; two-mode finished resolved conjunctively with latch semantics; the equality-edge truth table is now measured at every gate.
- **coverage: improved locally** — 90→112 CASES rows; falsification paths built into every arm.
- **calibration: unchanged** — no thresholds/bounds touched; tolerances inherited.

Verdict: **ADMIT** — no demonstrated scoped harm; four SHONEN boxes remain checked without promotion.

## Bounds retained

Godot 4.7.2.stable headless on this host's navmesh; this-mesh pins only; no moving-agent locomotion, metadata-flag behavior, latch release, baked-region, multi-region, rendering, or cross-version claims.
