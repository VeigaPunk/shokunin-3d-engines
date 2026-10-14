# r73 Sol adjudicator — game-dev-3d lane, wave `shokunin-train-20261013-w4`

Adjudicator: Sol (parent session), host devin, 2026-10-14. Scope: round 73 declared depth move — formalize off-mesh navigation-link traversal gating as tracked CASES arms on the detour fixture; claims (a) companion LINK metadata, (b) three independent traversal gates, (c) enter_cost inertness re-test, (d) pop-through hazard; 112 prior rows + 4 probes + Node 31/31 byte-stable.

## Declared claim (verbatim)

"formalize off-mesh navigation-link traversal gating … (a) enabling path_metadata_flags surfaces LINK-type points in companion arrays where the plain path array is opaque; (b) navigation_layers bitmask mismatch, bidirectional=false from the exit side, and enabled=false each drop the link (each independently falsifiable); (c) enter_cost inert vs travel_cost live — re-test as pinned arm pair; (d) pop-through hazard: large pdd pops the near endpoint and next_target points across the void."

## Measured result

**CONFIRMED — all four claims**, with critic corrections absorbed into the record:

- (a) Companion arrays carry LINK-type (`1`) at hop-start index under `path_metadata_flags` bits 1/2/4 (types/rids/owner_ids). **Wording correction (critic)**: flags are opt-OUT — default is `7` on 4.7.2; meta=0 empties the arrays (not "enabling"). Node links surface valid `NavigationLink3D` ObjectID; server links give 0s.
- (b) Each gate independently drops the link: layers mismatch → corridor fallback (uniform bitmask filters regions and links — link-only mask yields EMPTY path + `final=(0,0,0)`, a third measured mode); `bidirectional=false` approached exit-side → unreachable clamp; `enabled=false` → dropped. Every drop mode byte-identical to link absence.
- (c) `enter_cost` **structurally inert** in 4.7.2: 10, 100, **1e6** all fail to move route choice (sole-route link at e=1e6 still traverses); `travel_cost` live — flips at T*∈(1.11,1.13]. Inertness measured, mechanism unexplained.
- (d) Pop-through pinned: pdd=4.0 → idx=3, `next=(2.5,0,5.5)` across the void, `reachable=true`, `finished=false`. Boundary/critic sharpened: **symmetric** — retro direction also unmasked (`d_tp_island_retro`); no traversal latch; teleport pops by plain Euclidean index advance.

15 tracked CASES arms; real measured gotcha recorded: `vertices.append_array` post-assignment does NOT write through on this build (`WRITETHRU` probe independently mechanism-pinned).

## Adjudicator's own reproduction (committed tree, HEAD `b41fb33`)

`godot --headless -- --arm=` on four CASES pins — all byte-exact: `link_shortcut` (idx=1, next=1.5,0,0.5 — link hop entered), `link_layers_on` (`types=0,1,0,0` — LINK at index 1), `link_oneway_rev` (exit-side → unreachable clamp final=2.5,0,4.0), `link_pop_void` (idx=3, `next=2.5,0,5.5` across the z∈(4,5) gap).

## Seat-evidence audit

| seat | landed | key evidence |
|---|---|---|
| author | `r73-author.md` + tracked +337/−2 +30/−0 | 15 arms, 127/127, 112×11 0-mismatch, Node 31/31, read-back gate honesty check |
| scout | `r73-scout.md` | insertion map; API verified on binary (companion arrays on `NavigationPathQueryResult3D`; flags constant lives on `…QueryParameters3D` — r72's "MISSING" was wrong-class lookup); meta default=7 measured |
| critic | `r73-critic.md` | 86 probes; enter_cost inert at 1e6; opt-OUT wording correction; layers-uniformity third mode; symmetric pop-through; node/server identical; artifact verified 127/127 |
| reviewer | `r73-reviewer.md` | r72 audit AGREE-all (112/112, 4 probes, Node 31/31); --runs trap reproduces + flagged absent from operational surfaces (README/docstring gap — residual) |
| baseline | `r73-baseline.md` | frozen `3f6a03d` 112/112 + Node 31/31; 0 mismatches vs r72-verifier receipt; greenfield confirmation (zero link refs in frozen tree) |
| simplifier | `r73-simplifier.md` | 14/15 load-bearing; `link_meta` borderline (union arm — kept); own 33-run probe reproduces all four claims; 8/8 mutants rejected |
| scribe | `r73-scribe.md` | independent fixture `link_gate_check.gd` — all four claims on own geometry; pop-through fires pdd>0.5 (below engine default); lesson draft → `corpus/lessons/r73-navagent-link-gating-review.md` |
| boundary | `r73-boundary.md` | 49 arms: mid-flight `next` endpoint-switches (never interpolated); chained links compose; `dist < link_connection_radius` strict (==1.0 fails); mid-hop retarget re-anchors; `map_get_link_connection_radius` stale-read quirk |
| verifier | `r73-verifier.md` | **AGREE all 5 claims** — 127/127 + 4 probes + seeds, 112×12 0-mismatch, 15/15 verbatim replay, Node 31/31, numstat exact |

## Disclosures recorded

- Wording precision (verifier): tracked arms pin `entercost=100` / `pdd=4.0` (the 10/1e6 values and 3.605551 threshold live in critic/boundary sweeps, not the battery).
- `--runs` relative-path trap documented in reports but absent from operational surfaces — deferred docstring/README note remains open (flagged again).
- `_run_link_arm` duplicates `_run_pop_arm`'s tuple-check chain (~22 lines) — kept for byte-stability of 22 prior arms; shared-helper extraction is a candidate follow-up.
- Unexplained items honestly carried: enter_cost inertness mechanism; default-cost preference for the *longer* link route; tie-break internals.

## Per-axis verdicts

- **depth: improved locally** — link traversal is now a measured gate system: companion metadata, three independent drop gates, cost-field liveness split, mid-flight readout semantics.
- **coverage: improved locally** — 112→127 rows; link geometry, metadata flags, and chained/off-mesh paths all tracked.
- **calibration: unchanged** — bounds/thresholds untouched; equality edges measured strictly per gate.

Verdict: **ADMIT** — no demonstrated scoped harm; four SHONEN boxes remain checked without promotion.

## Bounds retained

Godot 4.7.2.stable.arch_linux.ed1daf0bf, single host, headless, stationary agent, this detour/island/link geometry family; companion-array semantics verified on the installed binary only; enter_cost inertness is measured-not-explained; no exported-build or other-engine-version claims.
