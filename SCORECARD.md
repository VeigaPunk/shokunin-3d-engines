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

## Round 82 verdict — 2026-11-01

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | evalcat bare catalogue 14->20 (update_tag discriminating witness + custom setter + libraries + instance + batch_remove + evalget-stale/freed/refused edges); parser-hazard surface now pinned both directions |
| depth | **improved** | forge-last masking measured reachable (74/74 silent) -> independent genuine-cell invariant armed; detach EOF-hold under battery timeout characterized (FAIL not hang); batch_remove stale-ref SIGSEGV boundary mapped |
| calibration | **unchanged** | insertion-only; prior 122 keys byte-identical; sha 6a98c570 deterministic x3; falsifier liveness re-verified by critic mutant |

Sol `r82-adjudicator.md`: ADMIT — residual fold honest, hazard contract pinned, masking direction documented not hidden. Bounded: Blender 5.2.1, embedded CPython 3.14.7, -b -P, this host.

## Round 83 verdict — 2026-10-14

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | two-tier lattice armed inside PhysicsServer3D: queries edge-0, generated events tick-bound, sync-callback once/tick; write-phase dependency (delta=1|2) measured and folded; ST refusal characterized as a deterministic context gate |
| coverage | **improved** | new fixture `phys3d_events.gd` + 10 CASES rows (9 ordinary + 1 negative); threaded-backend conversion cell; backend matrix now names GodotPhysics3D vs Jolt with the `static_nopair` inversion recorded |
| calibration | **improved** | insertion-only author diff (+597/-0 fixture, +28 README); critic falsified two claims as stated and both folds re-verified (186/186 on `4c1c100`); prior 176 rows byte-identical; verifier AGREE 18/18 |

Sol `r83-adjudicator.md`: ADMIT-corr — lattice confirmed with backend scope honestly named; Jolt-pinned rows and contact-signal timing depth queued for r84. Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf, GodotPhysics3D/Jolt pair, this host.
## Round 84 verdict — 2026-10-14

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | Jolt backend now a pinned, probed in-battery arm (jolt_edge child re-exec, 7-key verdict map incl. live jolt_dss_class witness); phase_delta makes the write-phase split a first-class cell (proc=2 / phys=1, identical across both backends) |
| depth | **improved** | setting-string vs active-backend gap closed (impersonation guard + live dss class pin); first-entry artifact identified as the delta_pf=1 contamination source (keyed reading vindicates the pin); Dummy-degenerate backend paths now classify instead of crash |
| calibration | **improved** | child dispatch total (silent wrong-body default removed); classifier totality (zero-evidence elif closed); stale-log forge path unlinked; ObjectDB leak arm mirrored into parent scans; insertion-only +617/-6, 188/188, prior 186 normalized prefix c0c3fcbb unchanged |

Sol `r84-adjudicator.md`: ADMIT-corr — Jolt pinning with live witness, write-phase cell landed, child-path totality hardened. Verifier AGREE 15/15 on `01f7d4f`; baseline zero-drift `c4b2fa2`->`01f7d4f`. Bounded: Godot 4.7.2, GodotPhysics3D/Jolt pair, this host. Work `01f7d4f` + folds `a56f683`.

| r85 | game-dev-3d | backend x threading | ADMIT-corr | f230443 + 4e6fbe3 |
| r86 | game-dev-3d | statement-band + hang + backend tier + dummy floor | ADMIT-corr | 4e65726 + dd1737a |
## Round 87 verdict — 2026-10-14

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | 6 cells: singleton-handle identity law, acquisition-vs-use split under threading, step-stamped getters with GP/Jolt in-class split, bounded write-loss observation, body-tier backend split, freed-space fatal tail |
| depth | **improved** | crash row now pins per-backend breadcrumb envelope (GP dies inside get_space_state; Jolt at intersect_ray) — critic's self-print forge replayed and FAILS; refusal ERROR counts ==BODY_REPS corroborate gate; ss_fired makes dummy_cb=never honest |
| calibration | **improved** | simplifier +85/-117 replay-verified; nav cell correctly refused then record-corrected (harness artifact); authored claims +876/-4 |

`r87-adjudicator.md`: ADMIT-corr — body-tier lattice admitted with envelope corrections. Reviewer + swe-2 verifier AGREE; baseline zero-drift; 195/195 prior byte-identical. Work `c57fa40` + folds `a11e1ad`.

| r87 | game-dev-3d | body-tier direct-state lattice | ADMIT-corr | c57fa40 + a11e1ad |

## Round 85 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | Jolt×threaded cross-product pinned on the generated-project child harness: `jolt_threaded` verdict map byte-equal to `jolt_edge` modulo the key prefix plus `jt_threaded=true`, raw constants identical (`0.149841/0.150024`, `-0.998535`, `set=0,1 in=0,1,4 out=4,0`); backend-determinism — the same sweep under another real backend emits `same-signature ×5`, under Dummy `unexpected ×5`, so the class is backend state, not a classifier default; both halves of the pin independently load-bearing (non-threaded Jolt → `jt_threaded=false` same map; threaded DEFAULT → `backend=unexpected`); server-write tier cell (`srv_phase_delta`, 14 server calls, zero node constructors). |
| coverage | **improved** | 188→191 (+3 cells: jolt_threaded / dummy_refused / srv_phase_delta); Dummy negative control backend-determined; `_child_split(prefix)` shared sweep, `_spawn_child` single-sources the four child-spawn sites, bounded dss-fetch retry, `allow_inaccessible` true exactly on the two threaded arms; mutation matrix 6/6 load-bearing (critic) and forged `child.log` destroyed pre-run (verifier property test). |
| calibration | **unchanged** | fold `4e6fbe3` = falsifiability repairs, not weight moves (adjudicator's wording): `LEAKED_OBJECTDB` singular accepted (masked by the stderr gate, coverage now matches intent), falsified comment counts corrected to measured 11/12 and 10/10, stale body-diff enumeration reworded, README 191/145; dispatch totality preserved through the `_spawn_child` single-sourcing. |

Non-author `reports/round-85/r85-verifier.md`: **AGREE 6/6, 0 DISAGREE** (claim 4 AGREE on the map; the §3.1 phrasing is imprecise, not a false claim) — 191/191 PASS ×2 with all tuples identical, prior 188 rows byte-identical at identical positions over three frozen receipts, `_spawn_child` fold behaviour-preserving, hygiene clean.

Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf, Jolt/GodotPhysics3D/Dummy, this host; `jolt_threaded` child.log is NOT byte-stable (refusal-block count 11–12 observed; tolerance ≥8 never stressed below 11 — the MAP is the stable witness); `jt_threaded` is a child self-report; `dummy_class` CHILD_NOTE key misnamed (rename deferred); r85-author §5.4 "Dummy silently hangs a threaded child" over-broad (the rc-137 class is `_child_threaded`/`PPQueries`-specific); latent `_child_threaded`/`PPQueries` Dummy-type hazards. Work `f230443` + folds `4e6fbe3`; report-last follows.

## Round 86 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | four cells on the generated-probe harness: `script_size_gate` is statement COUNT, not fetch position (refused below a stochastic ~475–575-statement band, granted above; an uncalled 1000-statement body grants 7/7); `deferred_hang` — unguarded deref of the refused fetch aborts the coroutine, SceneTree lives on, the timeout bound kills it (rc 137, no CHILD_RESULT); `backend_tier` — GodotPhysics honors / Jolt inverts / Dummy floors on the same sweep; `dummy_floor` — 34-call silent-floor signature vs 2 real-backend refusals; verifier re-derived every arm with its OWN generated children (size-gate 9/9 per side in three padding shapes; hang rc 137 + refusal + abort + no marker; tier sweep raw floats identical incl. the Jolt area-inversion; floor signature + 2 refusals reproduced). |
| coverage | **improved** | 191→195 (149 ordinary, 46 negative), exactly 4 inserted rows @192–195; prior 191 rows byte-identical at identical positions (verifier 11-field × 191 × 4-receipt matrix = 0 mismatches); `_spawn_probe` delegates to `_spawn_child`; mutation coverage author 9/9 + verifier's own 4-mutation set 3 detected with V-M2 no-detect mechanism proven (double-free re-emits from `_cleanup_rids`); boundary mapped the stochastic band (~475–575, 50%-point session-dependent) and the leak-scan blindness to KILLed children. |
| calibration | **improved** | fold `dd1737a` gate/falsifiability repairs: A1 abort witness now requires the landed `"null instance"` text (an unrelated abort previously satisfied it); A4/`min_thr` refusal now requires the engine's `space_get_direct_state` callsite line in the RAW child log (a self-printed ERROR passed text match in the merged 2>&1 stream); A2 the Dummy contrast child gets `HANG_BOUND_S` (an unbounded 30 s contrast could exceed the 20 s case bound); A5 `dummy_floor` token 4 pins zero-vs-positive on `solver_iterations`, not the literal default 16.0 (a host tuned to 8 previously failed as "refusal drift"); A3 statement-count wording. Simplifier SP1/SP2 replay-proven (195/195 + 191/191 + 15/15 `project.godot` byte-identical). |

Non-author `reports/round-86/r86-verifier.md`: **AGREE on every landed claim, one DISAGREE on the recorded *reason*** — 195/195 ×2 on its own runs, prior 191 rows byte-identical over 11 fields at identical positions against two independent references, all four new cells re-derived with its own generated children, 4-mutation adversarial check 3 detected + 1 explained; the nav-cell park stays correct on procedure, but the recorded ground was wrong — the scout's `safe_n=10` IS reproducible where any `project.godot` exists (17/17, incl. an empty file) and `safe_n=0` only in the project-less harness layout (11/11).

Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf, Jolt/GodotPhysics3D/Dummy, this host; the refusal band is stochastic and load-sensitive with a session-dependent 50%-point (the two pinned points sit ~450 statements clear; a two-point ladder cannot see inside); `HANG_BOUND_S=8` is wall-clock (~9.1 s of its 20 s bound); Jolt/Dummy splits are one build; the merged child.log stream is a deliberate position-fidelity tradeoff, provenance now needs the callsite line (A4). Work `4e65726` + folds `dd1737a`; report-last follows.

## Round 88 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | read-family split CONFIRMED — `cast_motion` alone applies `motion`; the other five query methods ignore it in the tested shared-parameter setup; fetch gate CONFIRMED — threaded acquisition is phase-gated (grant=2/refuse=6, one ERROR per acquisition path per refused sample, log-counted) and a held handle bypasses refusal with the SAME dss object, parent-witnessed by emitted id pairs (C6); inactive space is gated by step cycle, not activation; freed-space outcome is the shared post-free `bds.get_space_state()` fetch (boundary falsified the per-method framing; marker now reads `@post_fetch`), with the per-method dimension at the VM dead-handle line (C1). |
| coverage | **improved** | nine cells (motion_split, fetch_gate, inactive_space, param_purity, body_inertia, wrong_args, geom_split, race_class, freed_space_methods) 201→210; `_child_prepare`/`_child_scan` split + `_spawn_batch` (13 crash children in ~3 s, own `timeout -s KILL` bounds and a fail-closed batch deadline); 210/210 ×2 non-author with prior 201 index-identical and 14/14 spawn-heavy prior rows byte-identical under the split; forges killed both directions (verifier: expected-token / fake breadcrumb / torn channel + row-deletion isolation; critic FORGE A/B/C + REPLAY-5 killed by the folded conjuncts). |
| calibration | **improved** | simplifier C9 (−27-line proven vfold, sha `74399b0a…`, tuple-identical) + critic C1–C8 folded: per-method `Nonexistent function` witness, `errs.is_empty()` on the three real-backend envelopes, `wa_counts[1][2]==3` count pin, injective `str(p.exclude)` fingerprint, `blocked [1,1]` named as a torn class not a violation, `byp_ids` parent-visible identity witness, marker/README wording vs measured sites, scribe F5 `if_fired` bucketed pin (`dummy_cb=never` now earns both callback halves); the rep-run `seeds modified` FAIL at 06:04 was the fold landing mid-battery (the integrity gate working), clean re-run 210/210. |

Non-author `reports/round-88/r88-verifier.md`: **PASS 5/5 assigned checks** — 210/210 ×2 (164 ordinary / 46 negative) with 0 tuple mismatches over 210×6 fields, prior 201 index-identical on both runs, three forges fail closed and the row-deletion kill test changes only that row; non-author `r88-sentinel.md` live-reproduced S1–S5 as harness-hardness classes queued for r89 (the engine-level claims stand independent of them).

Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf (`--headless`, 60 tps), Jolt/GodotPhysics3D/Dummy, this host; crash/dead Jolt branches stay envelope-pinned (branch-stable, no distribution over-claim); S1 sibling-log forgery, S2 deadline kills the `/bin/sh` wrapper not the payload, S3 `dirname="../…"` path traversal, S4 last-match-wins parser, S5 kill-by-pid without identity remain open. Work `3028263` + folds `44a488c`.

| r88 | game-dev-3d | direct-state read family + body state | ADMIT-corr | 3028263 + 44a488c |

## Round 89 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | 7 cells admitted: `if_phase` IF→E→F ordering (PHASEMK real-time merged-log witness; GP impulse lands one solve late vs Jolt same-step), `if_write` deferred-force classes, `joint_pin`/`joint_param`/`joint_solver` Jolt drop lists (Jolt WARNING counts pinned 35/3/1, all zero on GP/Dummy), `cross_space` Jolt non-main-space split (`b_bound`/`b_find` world-binding pins), `sleep_state` held-state stale-read classes; boundary recorded, not folded: Jolt teardown `body_set_space`→freed space SIGABRTs 6/6 vs GP clean, Jolt `SLEEPING` at tick 1 marks the `slept=41` pin sampler-fragile, a sleeping-body joint make wakes both on Jolt. |
| coverage | **improved** | +7 rows → 217 (171 ordinary + 46 negative); author 217/217 ×4 and verifier 217/217 ×2 with prior-210 index-identical, 3 forge-kills live; sentinel S3 dirname remediation folded (guard whitelist `[A-Za-z0-9_-]`, live shell-escape killed, h2 PWNED pre-fix); C3 unasserted sleep row now fails named. |
| calibration | **improved** | corrections folded C1–C3, C5–C7 + verifier F1: additive Jolt WARNING count pins (35 joint_param / 3 joint_pin / 1 joint_solver), guard tighten, named failure replacing the unasserted-row `{}` trap, PHASEMK merged-log ordering witness, stale-buffer wording narrowed to held-state read, `b_bound`/`b_find` world-binding pins, README count/path drift fixed; simplifier P1+P2+P3 proven folds applied, P4 declined (14-arm rewrite, residual auditability risk). |

Non-author `reports/round-89/r89-verifier.md`: **AGREE all five assigned checks** — 217/217 ×2, prior-210 index-identical, receipt shas byte-for-byte, guard and three forged mechanisms fail closed; the sole finding is pre-existing low-severity README drift (F1, corrected in the fold). The r89 scribe seat died in the 09:0x rate-limit sweep before reporting; record audit was absorbed into `r89-adjudicator.md` (counts re-derived 217 = 171 + 46; README paths verified against the repository root layout; report claims cross-checked against `corpus/live/r89-*/` receipts).

Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, GodotPhysics/Jolt/Dummy, this host; Jolt teardown SIGABRT class, `slept=` sampler fragility, Jolt wake-on-joint-make and the `apply_impulse`/`apply_force` zero call-site README overclaim (C4) recorded not folded; HELD-OUT: none this lane. Work `c16f6ba` (+ record `93d01fb`).

| r89 | game-dev-3d | body-state phase lattice + joint family | ADMIT-corr | c16f6ba + 93d01fb |
| r92 | improved | improved | improved | RemoteTransform3D/anim-x-body/scheduler timing (23 rows, 235->258); verifier FAILED pre-fold -> fold re-anchored timing to iteration boundary + settled ticks; idlemode envelope = legal set; VERIFIED on folded bytes (4212 samples 0 off-pin) |

## Round 93 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | Area3D signal phase lattice admitted: `in_step` (post-IF/pre-E) ordering across 3 entry shapes, `queue_free` post-E exits, in-dispatch `monitoring` refusal with exact text, `free_rid` `no_if` exits + backend teardown errors, GP/Jolt frozen-teleport/`bsi` splits, Dummy `nif=0` vacuity, Jolt multi-overlap order honestly unpinned (`seqeq=-`/`pairs=-`) — verified as live flips by two independent seats. |
| coverage | **improved** | +7 rows → 265 (218 ordinary + 47 negative), 18 cases × 3 backends = 54 cells; author 265/265 + byte-identical ×3; verifier 64 execs byte-exact @load127; critic 1136 child execs, 0 multi-hash cells, `bodysig` 90/90/backend. |
| calibration | **improved** | boundary corrections folded pre-authoring (queue_free post-E, refusal semantics, order instability unpinned); scribe F1 pre-commit child delta disclosed (diagnostic-only, M surfaces identical 54/54); reviewer F1-F5 report nits filed; critic F1 adds freed_space segv class to flake list. |

| r93 | game-dev-3d | Area3D signal-in-tick ordering lattice | ADMIT | 661749f |

## Round 94 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | +19 `r94_cannon_*` rows → 284 (13 ord + 6 neg): vendored cannon-es@0.20.0 byte-pinned, 66 children/pass, bit-exact sha witnesses. Author 284/284; verifier 19/19 @load123, 114/114 rep-stable; reviewer 57/57 fresh exact. |
| depth | **improved** | Boundary falsifications folded pre-authoring (internalStep impurity, order-neutrality scope, μ/v₀ grid, fixedStep wall-clock, dt=0 NaN-freeze, GridBroadphase refusal); cross-runtime check v24↔v26 node byte-identical. |
| calibration | **improved** | Critic F1: accumulator cells flip ~1% under contention via engine-internal 16.67 ms wall-bail — corroborated by reviewer, filed to flake list; package.json load-bearing proven in battery layout; nan-witness over-count corrected; SP1-4 −22 queued. |

| r94 | game-dev-3d | cannon.js physics lattice | ADMIT-with-findings | 05e72ef |

## Round 95 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | +20 `r95_bullet_*` rows → 304 (14 ord + 6 neg): 52 child cells/pass, vendored `.so` byte-pinned and reproduced by `strip --strip-debug` of the scout build. Author 304/304 ×2; verifier 304/304 + 208 dual-build execs byte-identical. |
| depth | **improved** | Boundary corrections encoded (DIRECT-scoped wall-clock purity, SHM `rt=1` pump-live `fell`, order non-neutrality permutation-invariant, 1-ulp friction, EMPTY calibration); all 6 negatives carry in-child live controls (r94 gap closed). |
| calibration | **improved** | SHM `d`-count race found independently by 4 seats (teardown partial-line prints; M-surface never moves — fail-closed); fold spec filed (envelope/deterministic drain); SP1–SP6 −42 proven queued; `sl_force_mb` rest-pin precision corrected. |

| r95 | game-dev-3d | Bullet/PyBullet physics lattice | ADMIT-with-findings | 0767b59 |

## Round 96 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | +12 `r96_joltdet_*` rows → 316: Jolt-vs-GP determinism grid across joints/contacts/restkin/tps/solver/mechanisms/tscale/ffps/dummy/thread/knobs/nc; 123 cells ×4 passes, 160 bounded children. |
| depth | **improved** | Warning allowlist proven load-bearing in vivo (mutation reddens 3/3); ts=tps sha-equal 6/6 both backends; hang reproduced outside the parent (rc=137, 9.7 MB); verifier re-derived all 492 cell shas from a contract re-implementation. |
| calibration | **improved** | Three gates converged on the header's "warning fails the arm" defect (marker check is the real gate); thread-knob drop-blindness filed; SP1-4 −14 proven queued; seeds_unchanged flag correctly attributed sibling r97 files. |

| r96 | game-dev-3d | Jolt determinism lattice | ADMIT | dd054a2 |

## Round 97 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | +8 `r97_nodelat_*` rows → 324: joint/soft-body/DSS/CB/vehicle/XR/suspension surfaces, 79 cells + 83 bounded children per pass; deferred-pin census kept unpinned by design. |
| depth | **improved** | All five gates independently re-derived the cells (verifier 79/79x3, critic 317/317, reviewer 237/237, scribe 79/79); mutations detected 10/11 + 6/6 + mechanistic moves; xr crash envelope strict (fail-closed). |
| calibration | **improved** | Task-headline mismatch flagged by author (authored real claims, not invented cells); prose-vs-receipt corrections folded (plat_ride fl=1, ClassDB 45); 4-seat consensus comment defects queued. |

| r97 | game-dev-3d | node lattice (joints/soft/DSS/CB/vehicle/XR) | ADMIT | ec27b78 |

## Round 98 verdict — 2026-10-15

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | +9 `r98_gltflat_*` rows → 333: cold-cache import dead-end, document taxonomy, sniff/extbin/class/write/TRS/phys/var surfaces; 17 vendored assets sha-pinned; 137 cells per pass. |
| depth | **improved** | 4 seats re-derived all cells (581+411+411+137x4 instances); 9 mechanistic mutant detections; clobber repair proven byte-pinned vs manifest (manifest predates repair); 0 .godot minted. |
| calibration | **improved** | Author disclosed + repaired a tracked-seed clobber — scribe caught the disclosure's own inaccuracy (the class worked); user-dir hazard named by 4 seats with a controlled repro; fold spec filed. |

| r98 | game-dev-3d | GLTF/GLB runtime-import lattice | ADMIT-with-findings | b6d60b1 |

## Capabilities

| Capability | What it can now do | Evidence pointer | First-working round |
|---|---|---|---|
| — none yet — | | | |
| fixture-battery-targeted | run named Godot 4.7.2 headless battery rows (pinned Node v24.21.0) with exact-marker, exit-code and seed-integrity verdicts | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only slope3d_floor,slope3d_steep,slope3d_bound_naive,slope3d_bound_in,slope3d_bound_edge_in,slope3d_bound_edge_out,slope3d_bound_out` → `totals: cases=7 pass=7 fail=0`; `reports/round-108/battery/slope-only.verdicts.json` (the full run is 353/355, two pre-existing host-drift rows, `reports/round-108/battery/README.md`) | r108 |
| unreal-mcp-gate | re-verify the vendored unreal-mcp subtree: manifest identity, fresh-clone set-equality, 13-card label census, pointer sweep; fail-closed | `GATE_WORKDIR=$XDG_RUNTIME_DIR/r108gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `GATE RESULT: PASS (checks failed: 0)` rc 0; `reports/round-108/battery/gate-run.txt` (first passing r102; first recorded in this table r108) | r108 |
| source-registry | keep a contract-v1 tiered source registry whose every census command runs clean | `bash reports/round-108/census.sh` (the frozen contract v1 census, verbatim) → 35 rows, 0 malformed, A=32 B=2 C=1, mined=5 queued=28 rejected=2, no duplicate/enum/inflation/missing-path output; `corpus/SOURCES.md` | r108 |

Rows enter only through a round that demonstrates the capability running (`AXES.md` §Capabilities); none enter through this rollout.

## Saturation

The lane's saturation line and stagnation window N are to be declared by the lane on its next round per `AXES.md` §The stagnation nudge; not asserted by this conformance change.

Saturation line: 8/10 on every owned axis (the rubric's "8" anchors in `## Axes — scored (r108)` below; 10 needs executable evidence on surfaces this host cannot run). Stagnation window N = 3 rounds without a capability entering the table above. Declared r108 (2026-10-19).

## Round 101 verdict — 2026-10-18

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | 0→12 upstream files vendored byte-identical @ pin `a6aa73ad`; `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` → 12×OK rc=0 (re-run on committed `1659c036`); path-set equality vs `git ls-files` clean; non-author `r101-reviewer-c1.md` CONFIRMED across 4 transports + negative control; mutation gate proven (11/11 caught, `r101-mutation-tester.md`). Claim scoped: all files tracked at the pin; out-of-pin surface recorded `PROVENANCE.md` §8. |
| depth | **improved** | 13 executability cards: 12 `static-only` / 1 `unproven-runtime` (`actors-scene.md:5`) / 0 `verified-here` — `label-scan.sh` PASS on committed tree; prereq matrix (39 rows: 10 present / 21 missing / 8 operator-wall) independently reproduced by non-author `r101-reviewer-c2.md`; engine-install wall confirmed 4 ways (404 / gh api / SSH / AUR recipes); unproven unlock path recorded (`wukakuki/unreal-engine:dev-slim-5.8.3`, operator decision). |
| calibration | **improved** | Binary proven/unproven policy + ternary→binary mapping (`corpus/knowledge/unreal-mcp/README.md:12-48`); adaptation table 15 rows, 17 upstream pointers, 0 unresolvable — non-author `r101-reviewer-c3.md` CONFIRMED with biting negative controls; whole-round pointer sweep `POINTERS=78 UNRESOLVED=0` on committed tree; folds landed at close: meshes-textures F1 line-cites corrected (`:213-227`/`:209`), assets-content F4 word count 17→13 (wc -w re-measured). |

Non-author: `r101-reviewer-c{1,2,3}.md` CONFIRMED all three claims; critics filed findings — 2 in-scope folds landed this round, 6 pre-existing lane defects routed (see LOG.md ROUND 101 ROUTED). Bounded: no live-editor claim exists or can exist on this host (editor absent; install operator-gated); C3 `verified-here` rows are Kimi-side probes, not Unreal. Work `1659c036`; report-last follows.

## Round 102 verdict — 2026-10-18

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | 0→1 standing gate over the r101 subtree (`corpus/knowledge/unreal-mcp/gate/run_gate.sh`: manifest identity / fresh-clone set-equality / 13-card label census / pointer sweep; cwd-independent, fail-closed) — `GATE RESULT: PASS (checks failed: 0)` rc=0 re-run on committed `c6f655d`; post-hardening attack suite: 11/11 adversary attacks DETECTED, comm-absent exit 1 (`/tmp/r102-gate-verify-full.txt`, mirrored in round report); 0→1 lesson `corpus/lessons/r102-unreal-integration.md` (4 laws + next-iteration hooks; critic ADMIT-WITH-CORRECTIONS with both blocking folds landed at close); `engines.md` Unreal row evidence-class updated per connector IP-1 with state cells unmoved (non-author engines-verify PASS). |
| depth | **improved** | Five routed defects repaired, each with before(fail)→after(pass) receipts under `reports/round-102/before/` + `repairs/`: F1 path-root exit 2→0 in both r22 files; F2 `verdicts.json` pointer → dated correction note (gitignore + empty-history evidence); F3 sha `a065a56d…`→`f456bd00…` + pass-count 29→350 correction; F5 three.js command `npm ci --prefix`-first, exit 0 from clean `git archive` export; F6 JADX/Binwalk/Unblob census with version receipts. Battery + fixtures byte-untouched: `git diff -- corpus/fixtures` empty, `run_battery.py` `f456bd00…` stable (non-author battery-integrity PASS). |
| calibration | **unchanged** | No C3 claim declared this round; the axis was exercised, not moved: scanner-relative pointer datum recorded (three scanners → 40/41/43 on one tree), lesson-critic D1 folded, no label/threshold semantics changed. Routed, not silent: math-audit's 2 wrong rows and the gate's own pre-hardening false-passes are recorded in `fold-spec.md` and the round report. |

Non-author verification: lesson-verify (722 lines, all cited commands re-run), engines-verify, gate-review, math-audit (97/99 VERIFIED), ledger-check, battery-integrity — all PASS or findings-folded. Bounded: a fresh full-battery run state is recorded in the round report (r94_cannon node-marker drift, routed — battery bytes themselves untouched); no live-editor claim exists anywhere; a green gate is static evidence only. Work `c6f655d`; report-last follows.

## Round 103 verdict — 2026-10-18

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | Freshness note appended to `adaptation-kimi.md` (lines 1–363 byte-identical to the r102 digest `e0f8ca9b…`; dated correction note; `[[hooks]]` precedent ruled at line 3290 by two independent seats with a drift-proof structural citation); 3 stale citation classes closed (config line, 4 doc URLs → verified `/en/` 200s, `/tmp` → vendored pointer). B2 dead-root repairs: `three/README.md` 17→0, `glb-r12` 3→0, `unity-r19` 2→0; corpus-wide hits 167→164 with every survivor a justified historical quote (`reports/round-103/b2/postgrep.md`). Gate re-run PASS ×6 consecutive on the final script (POINTERS=101, UNRESOLVED=0). |
| depth | **improved** | Gate hardening A1–A4 all verified **by falsification on the final installed script** (not by reading): A1 planted `:1-99999` → `LINE-OOR (max 112)` + FAIL; A2 prose-hijack → `FAIL no-label`; A3 renamed card → `NAME_SET=BAD`; A4 proxy-killed clone → `STEP=BLOCKED` / `GATE RESULT: BLOCKED` / **exit 2**, and `GATE_REF` offline path → PASS (`reports/round-103/close-count.md` §C2 + L1 re-run in `gate/close-runs.md`). r102 11-attack suite: 11/11 still detected. SEAT-14's mid-round falsification was ruled a stale-intermediate race (target md5 `7a206d…`, 249 lines vs final 347) — recorded as a process defect: attack verdicts must pin the target hash. |
| calibration | **improved** | The r102 battery boundary is now precisely classified, not just observed: `phys3d_joints_free_ops` = `INTRINSIC_WALL_COST` — 21 serial child Godots × ~0.9 s boot floor ≈ 19 s inside the 20 s cap (wall 22.5 s / CPU 3.5 s; contention disproved: 21 concurrent boots = 1.0 s); the arm is correct (pinned marker byte-identical at a 120 s bound; 26/26 stored receipts fail only at the cap). Fix routed with a ruled recommendation (concurrent children), not a silent re-baseline. New operational hazard recorded: `--path .` runs stray-writing fixture dirs. |

Non-author verification: SEAT-64 close-count verified all four hardenings by falsification; SEAT-33's adversarial ruling corrected SEAT-32's classification with measured counter-evidence; note rows 14 REPRODUCED / 1 PARTIAL (citation-only). Conformance defect recorded and ruled (fixtures doc repair vs code protection — template ambiguity, accepted with the defect named). Work `8c9d9ad`; report-last follows.

## Round 104 verdict — 2026-10-18

| axis | verdict | evidence |
|---|---|---|
| depth | **improved** | `phys3d_joints_free_ops` fixed at the root cause per the r103 ruling: concurrent child batch (`_spawn_batch` pattern from `phys3d_events.gd`) + fail-closed `BATCH_BOUND_S=16` deadline with named `batch_timeout` failure. L1 close run: **PASS in 2.9 s at the shipped 20 s bound** (was killed at 20.008 s in r102), marker byte-identical; SEAT-07 full battery on the final fixture bytes: **337/350** — free_ops PASS at 2.77 s, 336/336 previously-passing rows unbroken, the 13 `r94_cannon_*` rows unchanged, `seeds_unchanged=true`. Determinism adversary: serial vs concurrent outputs byte-identical. Fixture scope: only `phys3d_joints.gd` changed; `run_battery.py` sha `f456bd00…` and all 350 CASES rows AST-identical (seats 08/09). |
| coverage | **improved** | Gate resilience: `GATE_WORKDIR`/`TMPDIR` support landed and verified end-to-end (PASS, scratch created + cleaned, `WORK_ROOT` reported); the documented `REPO` override actually implemented (`REPO=${REPO:-…}`) — bad-URL run gives `CHECK 2 BLOCKED` + exit 2, clean run PASS (gate sha `390a25ae…`); durable flake harness landed (`gate/flake_harness.sh`); full attack regression re-ran against the patched gate — 11 content attacks + A1–A4 + comm-absent all detected (`gate/regression.md`). |
| calibration | **improved** | `SKILL.md` landed (new file, 182 lines): the five-row Unreal-claim decision table + eight named error patterns (incl. `scanner-relative datum`, `temp-dir-dependent gate`, `command-does-not-reproduce-its-printed-rc`) + admissibility checklist + the P/C precedence collision stated as open, not resolved. Reviewer REVISE and critic REVISE were both fully folded at close (2 mechanical + 5 label overreaches; acceptance greps 0/1/2/0; the `⇔` overclaim replaced by the conditional; refusal 4 reconciled with row D's row-probe sense). SHONEN box 1: artifact half satisfied; the named-verifier half is explicitly left open in the file's own §6. |

Non-author: SEAT-07 full regression, SEAT-15 attack regression, SEAT-19/20/21 review chain, SEAT-06 determinism adversary, SEAT-33-ruling inherited. Bounded: default-workdir gate runs remain sensitive to the host's exhausted /tmp quota (measured live: FS 3.1G free, user quota refuses 4KiB) — the durable close runs use `GATE_WORKDIR`; the 13 cannon rows await the operator's node-v24 decision; no live-editor claim exists anywhere. Work `<WORK>`; report-last follows.

## Round 105 verdict — 2026-10-18

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** | `corpus/lessons/r105-unreal-lifecycle.md` landed (5-stage lifecycle, 6 round-attributed error classes, hooks; critic's REVISE folded at close — the 2.9 s physics claim now carries its receipt pointer); SKILL.md row F landed and folded per review+critic (aggregate `verdict=PASS` + `seeds_unchanged=true` + named non-author replay required; canonical command no longer targets frozen round-104 paths); kimi-404 URL fixed and verified 200. Gate re-run PASS (POINTERS=103, pin matched, SEAT-10). |
| depth | **improved** | The battery's pinned environment is restored as a first-class, documented state: **350/350 PASS under fnm node v24.21.0**, `seeds_unchanged=true`, all 13 cannon markers and `free_ops` green (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`, 854 KB durable copy); the shadowing mechanism proven end-to-end (default-env row FAIL vs pinned-env row PASS for the same seed); `corpus/fixtures/PINNED-ENV.md` runbook + marker census (exactly 13 node-pinned rows, nothing else env-exposed; SEAT-14). Zero fixture bytes changed (`run_battery.py` `f456bd00…`). |
| calibration | **improved** | The P/C label-precedence collision is converted from open disagreement to a ruled-pending package: both sides argued at strength (SEAT-19/20), the six cards' exact dissent extracted (SEAT-21), impact diffs computed but NOT applied (SEAT-22), ruling proposal drafted (SEAT-23), three independent strong reviews landed — REVISE ×2 with a distilled amendment set (SEAT-24/25/26/27) — and an operator queue with acceptance commands written for either outcome (SEAT-28). The two-state toolchain model replaces the drift narrative (SEAT-31/60). |

Non-author: three independent P/C reviews + lesson verify/critic + row F review/critic + marker audit. Bounded: the first N24 full run failed on a concurrent seat's mid-run fixture write (the stray-writer hazard, second sighting — routed as a write-isolation proposal); reviews landed against moving proposal hashes (distiller-recorded); the P/C ruling itself awaits the operator; no live-editor claim exists anywhere. Work `3634bc0`; report-last follows.

## Round 106 verdict — 2026-10-18 (interrupted round, closed on the verified subset)

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** (bounded) | 85 corpus files repaired (+1534/−163): dead `.shokunin/game-dev-3d/` roots stripped from runnable contexts, dated correction/receipt notes added (sample: r13-nav-review, r105/r102 lessons, corpus/README.md, rea.md); historical sentences preserved in every sampled file. Bound: the sweep is INCOMPLETE — several chunk seats rate-limited before filing chunk reports, so the defect census is derived from `git diff --shortstat` + samples, not from complete chunk ledgers; the remainder is routed to r107. |
| depth | **improved** | engines.md census refresh under the r105 two-state model: per-row probe receipts (33 census artifacts under `reports/round-106/census/`), explicit default-vs-pinned state table with parsed receipts named and verdict classes stated, NO state cell moved, Blender row added with `partial` honestly marked; `engine-cmd-regression.md` green (expected FAIL class + expected PASS both landed). |
| calibration | **improved** (bounded) | Receipt-discipline notes landed: non-resolvable `corpus/live/runs` receipts marked with dated notes (SEAT-45 pattern, `consistency/receipts.md`), battery totals paired with their environment state (`consistency/two-state.md`); jolt curiosity investigated (`jolt/investigate.md`). Bound: consistency chunk audits and the jolt ruling did not land (rate limit). |

Round admits as ADMIT-with-findings: no axis harmed, invariants green at close (gate PASS, manifest 12/12 rc=0, fixtures 0 diff, `run_battery.py` `f456bd00…` stable, protected ledgers untouched). Provider substitutions named per the stop rule: xai credits exhausted at 47/128 → cursor/grok-4.7-xhigh-fast refire → Cursor Pro rate limit (operator-owned recovery). Work `<WORK>`; report-last follows.

## Axes — scored (r108, 2026-10-19)

Appended; the mint table above (`unscored`) is kept as history. Rubric (anchors only — use the highest anchor fully met, never interpolate; a row count alone is never a score). **Provisional retrospective baseline:** the rubric was written in the round that first applies it, so these scores are self-assessment, not an independently calibrated scale; the rubric is frozen from r108 and any later change is a new dated block, never an edit here.

- **depth** — 0: no independently replayed mechanism. 5: one source-backed measured behavior with a falsifier and non-author replay. 8: multiple measured mechanisms with falsifiers, re-derivation and explicit limits. 10: every core and frontier behavior in the coverage map measured across every declared environment.
- **coverage** — 0: no inventory. 5: ≥5 engine/artifact families evidenced, runtime vs static status distinguished (`corpus/knowledge/engines.md`). 8: every PROVINCE surface placed as Core/Frontier/Adjacent with evidence or an explicit gap (`corpus/README.md` `## Coverage map`, `PROVINCE.md`). 10: every PROVINCE surface has executable evidence on this host (no surface left frontier).
- **calibration** — 0: no scored rubric or admission bar. 5: evidence-backed scores and named misses. 8: lesson-linked admission criteria with rechecks, saturation line and window declared, and a capability demonstrated in-round. 10: every historical reject and unknown is ledgered accurately and every admission is independently adjudicated.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | 8/10 | base 8 (r99/r100 verified mechanisms: `reports/round-99/r99-verifier.md`, `reports/round-100/r100-adjudicator.md`); r108 keeps 8 — the floor-angle boundary adds a mechanism, the 10 anchor is not reachable on this host. `bash reports/round-108/measure.sh <commit>` § C3 | r108 (scored) |
| coverage | 8/10 | base 5 (`git show 7c4e589:corpus/knowledge/engines.md \| grep -cE '^\| (Godot\|Unity\|Unreal Engine\|three\.js\|Blender)'` → 5); r108 → 8: 27 surfaces placed Core/Frontier/Adjacent with pointers, incl. the vendored cannon-es and pybullet runtimes (`corpus/README.md` `## Coverage map`, `PROVINCE.md` `## Core/Frontier/Adjacent`). `bash reports/round-108/measure.sh <commit>` § C2 | r108 |
| calibration | 8/10 | base 0 (no rubric, no `corpus/QUALITY.md`, no saturation line, capabilities `— none yet —`); r108 → 8: `corpus/QUALITY.md` Q1–Q18 each citing a mined lesson, 22 mistake classes in `corpus/lessons/round-108.md`, saturation line + N declared, and C1's own in-round capability demonstration `unreal-mcp-gate` (the other two capability rows are C2's and C3's outputs and are shared evidence, not C1's). `bash reports/round-108/measure.sh <commit>` § C1 | r108 |

## Round 90 verdict — retroactive record written r108 (not a pass)

Overall: **REJECT** (`reports/round-90/r90-verifier.md:101-107`, on `191f131`); repair `6420dc7` was held for adjudication (`reports/round-90/r90-repair.md:77-82`) and no r90 adjudicator exists. Per-axis attribution is not in the record and is not inferred: depth / coverage / calibration **unassigned**. Lesson: `corpus/lessons/round-108.md` M1.

## Round 91 verdict — retroactive record written r108 (not a pass)

Overall: **unverified** — dead-seat salvage, author-only 235/235 (`reports/round-91/r91-author.md:68-80`; commit `b6ba234`); no verifier or adjudicator in the tree. depth / coverage / calibration **unverified**. Lesson: M2.

## Round 92 verdict — retroactive block written r108 (replaces nothing)

The r92 record above is an inline row in the wrong column shape (`| r92 | improved | improved | improved | … |`, line 213). Its adjudicator records **ADMIT-corr** (`reports/round-92/r92-adjudicator.md:3`): 23 rows (235→258), verifier FAILED pre-fold, fold re-anchored timing to the iteration boundary + settled ticks, VERIFIED on folded bytes. Per-axis verdicts as the inline row states them: depth / coverage / calibration **improved**. Lesson: M3.

## Round 99 verdict — retroactive record written r108 (not a fresh pass)

Overall: **ADMIT-with-findings** on `f1ff626` (`reports/round-99/r99-adjudicator.md:3-8,26-28`; adjudication commit `c28783a`); per-axis attribution not recorded — **unassigned**. Lesson: M6.

## Round 100 verdict — retroactive record written r108 (not a fresh pass)

Overall: **ADMIT-with-findings on successor `523c943`**, not on `8183191` alone (`reports/round-100/r100-adjudicator.md:3-18,34-36`; adjudication commit `78fa0f6`); per-axis attribution not recorded — **unassigned**.

## Correction notes (r108, 2026-10-19)

- r104 and r106 blocks above end `Work <WORK>` (lines 330 and 350 after this round's capability rows). The landed work commits are `77811e1` (r104) and `4755b0e` (r106). Their report-last commits name `work 2ca87e8` (`546970e`) and `work 26cd9f2` (`3ea02ff`), which exist but are not ancestors of HEAD (`git merge-base --is-ancestor 2ca87e8 HEAD; echo $?` → 1). Lesson M20/M21; criterion Q16.
- r81 and r82 blocks are dated 2026-11-01, after the round they record (lines 109, 119). The dates are kept; read them as recording errors. Lesson M17.
- The mint-table depth row (line 8) carries more cells than its header: an `r71` cell mid-row and `r70` as the final `last change` cell. Kept as written; the scored table above supersedes it.

## Round 108 verdict — 2026-10-19 (kaika W2a)

Claims (each measured with `bash reports/round-108/measure.sh 7c4e589` → `… <r108 commit>`; the commit hash is recorded in the fleet report `.ufo/reports/round-108/game-dev-3d.md`, since a file cannot carry its own commit hash):

| axis | claim | before → after | verdict (self, pending non-author) |
|---|---|---|---|
| calibration | C1: admission bar + mined mistakes + scored self-assessment | QUALITY criteria 0→18; mistake rows 0→22 (22 captured by a Q); scored axis rows 0→3; Saturation line 0→1; verdict blocks 30→36 (retroactive r90, r91, r92, r99, r100 + this r108 block); capabilities 0→3 (C1-local: `unreal-mcp-gate`; `source-registry` is C2's and `fixture-battery-targeted` C3's — shared evidence); score 0→8 (provisional) | **improved** |
| coverage | C2 (capability `source-registry`): tiered registry + coverage map + Core/Frontier/Adjacent | SOURCES rows 0→35 (A=32 B=2 C=1; queued 28, mined 5, rejected 2), census clean; README map/Frontier headings 0→2, map surfaces 0→27; PROVINCE headings 0→3; score 5→8 (provisional) | **improved** |
| depth | C3: floor/wall boundary at `floor_max_angle=45°` measured adjacently | CASES 350→355; slope3d rows 4→9; boundary bracket 30°/60° → 45.57°/45.58° (effective 45.573°, GodotPhysics3D battery + Jolt scan); SKILL error row 0→1; score 8→8 | **improved** (within anchor) |

Expansion (not a claim): 2 knowledge entries admitted through Q1–Q18 citing mined rows (`corpus/knowledge/godot-floor-angle-threshold.md`, `godot-headless-not-render.md`). Harm check: fixtures — only `slope3d_boundary.gd` added and `run_battery.py` +10 lines; the 350 prior CASES unchanged; the full pinned run is 353/355 with `r95_bullet_shm`/`r95_bullet_solver` failing identically on the base commit's own runner (host drift, lesson M5; `reports/round-108/battery/README.md`). Gate PASS. Provider exhaustion named: in the first batch 4 of 5 executor seats died on a provider rate limit and the fifth (fixture) stalled and was stopped; all 5 fresh re-dispatches died at provider capacity within a minute; a third dispatch of the four non-fixture seats landed. The L1 wrote and ran the fixture seat itself.

## Post-review corrections (r108, 2026-10-19 — orchestrator adjudication + W3 critic)

Append-only; the blocks above are kept as written.

- **Q16 placeholder filled.** Line 394 of this file (`## Round 108 verdict`) reads `… <r108 commit>`. Value: work `09192f6`, measured at `3f53896` (the count fold); these post-review corrections land in a later commit named in the fleet report's "Post-review fixes" section. The `<commit>` tokens in the scored-axis rows (lines 362–364) are the usage parameter of `measure.sh`, not unfilled fields. Q16 re-check over r108 records: no `<WORK>` or `<r108 commit>` remains unexplained.
- **Calibration 0→8 is provisional, not measured against an independent scale.** The rubric and the scores were written in the same round, and the base 0 is the rubric's own definition of "no rubric or bar"; the move records that the artifacts now exist, not that self-assessment quality was independently calibrated. Re-score only after the frozen rubric is applied in r109+ by a non-author.
- **C1-only evidence (separated from shared counts).** C1's own measures: QUALITY criteria 0→18, mistake rows 0→22 (all captured), scored axis rows 0→3, saturation line 0→1. The verdict-block count 30→36 is retroactive record-keeping (5 back-filled blocks + the r108 block), and capabilities 0→3 includes C2's `source-registry` and C3's `fixture-battery-targeted`: neither is C1 evidence.
- **`unreal-mcp-gate` first-working round is r102**, not r108 (the gate first passed in r102, `## Round 102 verdict` above); r108 is the round it was recorded and re-demonstrated (`reports/round-108/battery/gate-run.txt`).
- **C2 measured without C3 evidence.** S035 (own-work scan), S036 (pinned source) and the coverage-map frontier→core move of the floor-angle surface belong to C3. C2 alone: registry rows 0→34 at `3f53896` excluding S035 (0→34 again after this correction, excluding S035 and S036), 27 map surfaces, 3 PROVINCE headings.
- **C3 wording.** The runtime evidence is the measured bracket — floor at 45.57°, wall at 45.58° on Godot 4.7.2 (GodotPhysics3D in the battery, Jolt in the scratch scan). 45.573° is the **source-derived** threshold (S036, pinned to the installed build's commit `ed1daf0bf`), not a runtime-measured cutoff. The threshold-0 mutant is caught by the printed `threshold_deg` field, not by classification; it does not falsify the engine threshold.
- **Fail-closed measurement.** `reports/round-108/measure.sh` swallows `git show` errors (a bad ref reads as zeros). Use `reports/round-108/measure-strict.sh <commit> [allowed-absent ...]`: it validates the ref and every blob first (bad ref → exit 2; missing blob not explicitly allowed → exit 2).
