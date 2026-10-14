# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs <abs> --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → non-author 90/90 + 4 probes; `distance_to_target` = 3.605551 (√13) Euclidean to raw `target_position` and postprocessing-INVARIANT (corridorfunnel/edgecentered/none) while pathlen shifts 4.130649→4.707107→4.549510 and `next` moves (2,0,1)→(2,0,0.5); `final`=(2.5,0,3.5) postprocessing-invariant. Prior 85 rows byte-identical vs frozen baseline; Node 31/31 unchanged. Non-author `reports/round-71/r71-verifier.md` + `reports/round-70/r70-verifier.md`. Stationary agent, single region, cell_size 0.25, this engine build only. | r71 | `corpus/lessons/r70-navagent-detour-non-author.json`: `distance_to_target` = 3.605551 (√13) on an L-corridor whose routed path sums 4.130649 — Euclidean to raw `target_position` resolved; reach gates `euclid(final,target)≤tdd` fire with no path through a wall; absent path still returns Euclidean. Prior 85 rows byte-identical vs frozen baseline; Node 31/31 unchanged. Non-author `reports/round-70/r70-verifier.md`. Stationary agent, default funnel postprocessing, this engine build only. | r70 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_layer_cases.mjs` → non-author 4/4: layer0 near depth3, layer1 far depth5; ray mask1 selects near, mask2 far, mask3 both ordered; far layer1→0 mutation with ray mask2 exits1 on zero actual hits. Prior five Node suites 3/5/5/5/9 complete payloads unchanged. Godot first replay 82/83 on isolated SDL gamepad-mapping stderr, no-change retry 83/83+four probes with all 83 stable raw rows/50 hashes equal r67; preserve caveat. Evidence `corpus/lessons/r68-ray-layers-review.md`, work `f3e5644d5ec15637e0fd6a9c91174c828818a2bf`. CPU Raycaster mask selection only, not rendered visibility. | r68 |
| calibration | unscored | Three Node runners now compare selected stream exactly to `expectedLine + "\n"`, other stream empty. Non-author `corpus/lessons/r61-stream-review.md`: private copied-source PASS+`\n\n` output with child exit0 accepted by all old `6b1af7e` runners but rejected as positive-only FAIL by all revised runners at work `6c2e02597a08890cfa41ac9fa482e9c1d60367c0`; normal Object3D 3/3, perspective 5/5, ortho 3/3 raw fields unchanged except runner hashes; Godot 83/83+four probes, 83 fields/50 seeds unchanged. Narrow Node script UTF-8 newline policy only. | r61 |

planned: r72 (devin, ADMIT) — pdd strict-Euclidean waypoint-pop + two-mode is_navigation_finished tracked (112/112, equality edges measured). Next: boundary-measured surfaces — path_metadata_flags off-mesh-link behavior (authorable headlessly), latch release conditions, moving-agent locomotion dynamics, XConnector while-live marker gate port to 2d; retained: ULP float edges, non-corridor geometry. Prior: r71 — distance_to_target postprocessing-invariant (Euclidean to raw target under all three path_postprocessing values); final postprocessing-invariant; 90/90 + Node 31/31 non-author verified. Next: boundary-measured surfaces — pdd Euclidean waypoint-pop with saturate-at-last-index, two-mode is_navigation_finished (reachable→tdd strict / unreachable→pdd-to-final), path_metadata_flags companion arrays; off-mesh links for metadata discrimination; moving-agent/repath windows unprobed.
planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision beyond the one sampled near=1 point, general far-boundary precision beyond the one sampled far=10 point, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.

## Round 72 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | pdd pop resolved to strict sequential Euclidean keyed on live 3D position (saturate `size−1`, no skipping, multi-pop/update); two-mode `finished` resolved conjunctively — `reached` (euclid→rawT < tdd, through-wall, latched) OR (¬reachable ∧ idx==size−1 ∧ euclid→final < pdd); `reachable` selector inclusive `euclid(final→T)≤tdd`; non-monotone sawtooth measured; critic's idx-conjunct counterexample absorbed as claim wording (artifact already correct); equality edges strict at every gate. |
| coverage | **improved locally** | 90→112 CASES rows (22-arm preset table, authored expectations, falsification path per clause); boundary mapped off-mesh links (headlessly authorable, metadata annotation-only) + call-time-arithmetic `distance_to_target` + latch semantics for next rounds. |
| calibration | **unchanged** | thresholds/tolerances untouched; verifier's relative-`--runs` tree-timeout trap recorded as pre-existing (fails closed). |

Non-author `reports/round-72/r72-verifier.md`: **AGREE all five claims** — 112/112 battery, 90×12 prior 0-mismatch, 16/16 spot-checks verbatim, Node 31/31. Bounded: Godot 4.7.2 headless, this-mesh geometry; no moving-agent/metadata-flags/latch-release/cross-version claims. Work commit `05405ae`; report-last follows.

## Round 73 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | off-mesh link traversal resolved to a measured gate system: companion arrays carry LINK-type (1) at hop-start index under `path_metadata_flags` per-bit control — opt-OUT, default 7 on 4.7.2 (critic wording correction absorbed); layers-bitmask / bidirectional-exit-side / enabled=false each independently drop the link to byte-identical no-link tuples (link-only mask → empty path + final=(0,0,0) third mode); `enter_cost` structurally inert (10/100/1e6 measured, mechanism unexplained) vs `travel_cost` live (crossover ~1.12); pop-through pinned symmetric — forward AND retro `next` across the void; `vertices.append_array` post-assignment non-write-through gotcha pinned. |
| coverage | **improved locally** | 112→127 CASES rows (15 link arms: shortcut/meta-bits/layers/oneway/disabled/cost-pair/pop-through + island quad + server/node link authoring); mid-flight readouts, chained links, connection-radius strict bound measured at boundary; Node suites 31/31. |
| calibration | **unchanged** | thresholds untouched; equality edges measured strict per gate; no bounds changed. |

Non-author `reports/round-73/r73-verifier.md`: **AGREE all five claims** — 127/127 + 4 probes + seeds on committed `b41fb33`, 112×12 prior 0-mismatch, 15/15 verbatim CASES replay, Node 31/31. Bounded: Godot 4.7.2 headless, stationary agent, this geometry family; enter_cost inertness measured-not-explained; metadata flags verified on installed binary only. Work commit `b41fb33`; report-last commit follows.

## Round 74 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | lazy-update model measured: forcing-getter set vs pure readers; stored path frozen strictly under pmd (5.000000==pmd re-queries); pop = live-pos sequential strict-`<`; latch survives all motion, released by ANY target_position assignment (same-value too); lazy materialization anchored at first forcing call. |
| coverage | **improved locally** | 18 `mv_*` arms + `steps`/`pmd` machinery; pmd gate, bank-side re-anchor (on-mesh verbatim vs off-mesh clamp), pop-through-link-under-motion, bridge walk. 145/145, 4/4 probes, Node 31/31. |
| calibration | **unchanged** | no threshold/gate edits; engine-internal comparators pinned empirically. |

Non-author `reports/round-74/r74-verifier.md`: **AGREE on all six claims** — 145/145 + 4/4 probes + Node 31/31 on committed state, pmd boundary recomputed independently (4.9951 frozen / 5.0249 re-query), 6/6 byte-exact spot checks, prior 127 rows byte-preserved. Sol `r74-adjudicator.md` reproduced committed-state arms byte-exact. Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf this host; teleport-motion only; single map/region; engine-internal pmd comparator pinned empirically. No cross-build/internals inference. Work commit `fc9915e`; report-last commit follows.

## Round 75 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | Two-stage mutation gate measured: setter→server-sync (~2–3 frames) + sync→first-forcing-call; same-turn pre-sync serving is a real bounded zombie window; pure readers serve stale data indefinitely; agent `navigation_layers` = synchronous exception; **finished-latch zombie pinned** — early-return gates off invalidation, dead route served through region move AND delete until target re-assign. |
| coverage | **improved locally** | 11 `mut_*` arms across link (kill/drop/layers/revive), agent layers, region (layers/move/off/renew), latch-zombie classes; 145→156, 4/4 probes, Node 31/31. |
| calibration | **unchanged** | additive arms only; engine sync timing measured not edited. |

Non-author `reports/round-75/r75-verifier.md`: **AGREE 5/5** — 156/156 + 4 probes + Node 31/31 on committed HEAD, 0 mismatches over 156×12 fields vs author and 145 shared r74 rows, byte-exact committed-blob replays (5/11 mut arms sampled incl. both falsification arms), Node 31/31 `seeds_unchanged`. Sol `r75-adjudicator.md` reproduced `mut_latch_zombie`/`mut_link_kill`/`mut_region_move` verbatim on committed `cefc821`. Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf this host, headless, single map/region, teleport-only; sync latency ~2–3 frames measured-not-cased; multi-agent/node-link unexercised. Work commit `6498973` (+`cefc821`); report-last commit follows verifier landing.

## Round 76 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| coverage | **improved locally** | Setter→server-sync window pinned as 7 tracked CASES (156→163): per-class edges {link:2, region:3, map_off:∞, agent:0}, map reactivation, same-value suppression on 3 channels. Prior 156 rows byte-identical. |
| depth | **improved locally** | "wait≥1" falsified per-class (still stale at +1f); permanent-stale `map_off` regime distinguished from the finished-latch mechanism (server never syncs vs agent early-return); callsite qualifier measured (physics-callback writes one tick shallower); M-witness suppression proof on 8 setters with target_position carve-out. |
| calibration | **unchanged** | additive CASES + one `map_active` mutate key; gate/readback semantics unchanged; warranted `_check_tuple` consolidation applied (byte-identical 78/78 + 19/19 mutants, battery re-verified 163/163). |

Sol `r76-adjudicator.md`: four-way convergence on constants (author, critic, boundary 54/54+24/24 + 96 cross-process, scribe own-geometry). Non-author `r76-verifier.md`: **AGREE 5/5** on `3ab09fd` — 163/163 + 4 probes + Node 31/31, 156 prior rows unchanged. Bounded: 4.7.2.stable headless 60tps, single map/region, coroutine/deferred write context. Work `3ab09fd` + hygiene `8a67f71`; report-last follows.

## Round 77 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | Apply-order mechanism pinned: load-bearing only through RID lifecycle (doomed-RID voiding, verifier own-geometry both directions; boundary all-6-perms → 3 outcome classes + 2f empty interlude); map_force_update reach split — getter edge collapses same-turn; serve edge = mark-vs-phase race: prior forcing read marks dirty → next sync phase publishes early (link jittered {1,2} ~15-20%; region −1f deterministic; single-read-per-rung sees no collapse); jittered cell honestly skipped not pinned. |
| coverage | **improved locally** | `mutate` array schema + `_tuple_sig`/`ladder`/`srv_get` receipt keys; 10 new CASES (mut_ord_*×6, mut_force_*×2, mut_ladder_*×2); verdict-groups re-derive r76 edges from data (link [2,2] bound 2; region [3,2] bound 3). |
| calibration | **unchanged** | +20/−0 additive CASES; 163 prior rows byte-stable vs independent r76 verifier receipt; Node 31/31; seeds_unchanged; bare-dict mutation order unchanged. |

Sol `r77-adjudicator.md`: declared claim ADMIT — mechanism is dead-write voiding not emergence (critic correction absorbed); force-update serve edge is per-class (link jitter / region deterministic −1f) with only deterministic samples pinned. Non-author `r77-verifier.md`: **AGREE 6/6** on `35dfbe2` — 173/173 + 31/31 + jitter reproduced 6/10 vs 4/10. Bounded: Godot 4.7.2, 60tps; w1 jitter is host phase-dependent; verdict groups hide non-serve state (truth digests = open frontier). Work `35dfbe2` + hygiene `565318c`/`5e02b25`/`a5ae849`; report-last follows.

## Round 78 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| depth | **improved locally** | map-off permanence extended to a measured +1200f bound (80x over r76) with the falsifier wired in-fixture (per-rung map_iter/link_iter pins, iter_watch canary); reactivation edge on+2 wait-independent; callsite pair resolved to sample-base semantics (critic: same sync drain for both writes) — kills the r76 "−1 tick" misreading. |
| coverage | **improved locally** | +3 tracked CASES (mut_mapoff_ladder / mut_ctx_resume / mut_ctx_phys) insertion-only; `_read_srv` gained the `map_iter` falsifier pin the scout/reviewer flagged. |
| calibration | **unchanged** | additive CASES + comment precision only; 173 prior rows + 4 probes + Node 31/31 byte-stable (critic merged-battery + operator replay 176/176). |

Sol `r78-adjudicator.md`: permanence claim CONFIRMED as a bounded measured regime (+1200f, falsifier armed); callsite finding corrected to sample-base. Non-author: verifier seat lost to rate limits (3 respawns); operator adjudicator replay on `efcf33c` = 176/176 + arms byte-verbatim; critic verified the merged diff 176/176 independently. Bounded: Godot 4.7.2 / 60tps / this host; permanence = bounded regime; callsite constants context-specific. Work commit `efcf33c`; report-last commit follows.

## Round 79 verdict — 2026-10-14

| axis | Sol verdict | evidence |
|---|---|---|
| coverage | **improved locally** | first NEW runtime in lane history: Blender 5.2.1 bpy headless under measurement — 9-arm probe + 37-case pinned battery (`bpy_battery.py`); full two-layer lattice measured (write-through vs evaluation-gated, shared-graph flush, absent drain, membership edge, non-signal quirk) |
| depth | **improved locally** | the r76–r78 two-layer Godot model now has a cross-runtime twin: bpy held-handle staleness = unbounded (map_off-analogue), drain absent (vs per-tick serve) — the generalization boundary itself is mapped |
| calibration | **unchanged** | new sibling runner only; `run_battery.py` untouched, all 176 prior rows byte-stable by construction |

Sol `r79-adjudicator.md` (provisional): claim ADMIT-as-narrowed — split is write-through vs evaluation-gated not RNA-vs-depsgraph. Author = operator-substituted (free-pool massacre); scout lattice reproduced 37/37 on the tracked fixture. Verifier pending post-reset. Bounded: Blender 5.2.1 LTS, `blender -b -P`, this host. Work commit follows.

## Round 80 verdict — 2026-10-14

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | eval-event catalogue folded into the tracked lattice: bpy.ops-call auto-eval (new event class), driver edge=1, keyframe binds only at frame_set, handler timing split (dup vs fc), msgbus/undo_post dead headless |
| depth | **improved** | bounded closure confirmed — ~100 probed mutation classes, 0 falsifiers across 4 independent sweeps; mechanical falsifier armed in-fixture (`closed|violations`) |
| calibration | **unchanged** | additive arm + cases only; r79's 37 cases byte-identical; replay byte-identical ×2 after slept= removal |

## Round 81 verdict — 2026-11-01

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | X1 reorder fabrication confirmed on a SECOND Python runtime: bpy -b -P child bytes prefix the parent's buffered rows (child < pre_spawn); parse-survival contract pinned (gluevictim dropped, physical last-wins); PYTHONUNBUFFERED inert on bpy — per-runtime falsifier working as designed |
| coverage | **improved** | evalcat bare catalogue 8->14 (r80-critic fold rows: frame_current/hier_link/data_swap/parent_write/obj_remove edge=1, orphans_purge edge=absent); frame_current closes r80-boundary unknown (a); 4 raw order_checks added as a new gate class |
| calibration | **unchanged** | insertion-only (+331/-3); prior 111 ARM lines byte-identical; r79 78-line prefix + r80 34-row block preserved in order; deterministic x2 |

Sol `r81-adjudicator.md`: ADMIT — reorder topology + parse-survival confirmed on bpy; bounded-closure catalogue extended honestly. Verifier replay pending at write. Bounded: Blender 5.2.1 -b -P, embedded CPython 3.14.7 (PYTHONUNBUFFERED-inert), pipe capture, this host. Work commit `65b2f26`; report-last commit follows.
