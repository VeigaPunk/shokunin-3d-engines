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
