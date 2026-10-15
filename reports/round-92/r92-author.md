# r92 author — RemoteTransform3D frame boundary, AnimationPlayer x bodies, SceneTree timing edges

Seat: GAME-DEV-3D r92 AUTHOR. Task: `/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r92-author.md`. Scout evidence: `reports/round-92/r92-scout.md` + `corpus/live/r92-scout/{probes,runs}`.

Landed three parent fixtures plus one shared child probe, all self-contained and following the r90/r91 parent→generated-child-project convention:

- `corpus/fixtures/r92_remote.gd` — 8 arms (`boundary`, `phase`, `flags`, `stale`, `path`, `chainlag`, `srv`, `drive`)
- `corpus/fixtures/r92_animphys.gd` — 9 positive arms (`rbpos`, `rbfrozen`, `animrb`, `animatable`, `reset`, `manual`, `destroy`, `iforder`, `idlemode`) + 1 negative arm (`badkey_insert`, exit 2)
- `corpus/fixtures/r92_timing.gd` — 5 arms (`tps`, `tscale`, `edge`, `refuse`, `steps`)
- `corpus/fixtures/r92_child.gd` — the shared per-case child, spawned once per `(case, backend)` into a generated `res://r92{a,r,t}_*/` project

`run_battery.py`: **insertion-only tail-append** — `git diff` shows +57 lines, 0 deletions; the only removal was a transient double-comma typo fixed before any run (the splice point, not a prior row). Prior rows byte-for-byte untouched.

## Cells armed

23 new CASES rows → **369 child cells** per battery pass (Σ case×backend, plus 24 idlemode reps):

| Row | Children | Content |
|---|---|---|
| `r92_remote_boundary` | 6 | `sync`+`lag` ×3: writes never propagate synchronously; next-frame-boundary push, `imm=0`→`after1=write` |
| `r92_remote_phase` | 3 | physics-write: `imm=0`, same-tick later `_physics_process` `same_e=0`, post-boundary `post_f=1`, next tick `next_e_dpf=1`; idle-write: `imm=0`, `same_f=0`, `post_f=1`, `next_e=1` — pf stamps pinned only where tick-counted |
| `r92_remote_flags` | 3 | 8 flag combos global + 3 local: independent pos/rot/scl bits; `use_global_coordinates=false` pushes local transform |
| `r92_remote_stale` | 3 | cache lifecycle: `post_free valid=false`, `move_after_free_imm FREED`, orphan target retains local xf, rebind/repath recover, `after_forcecache` clean |
| `r92_remote_path` | 3 | `.`/`../Plain`/`../Nope`/`""`/`/root`/`..`/`../Target/Ghost` all leave target at origin; `valid_again` rebinds |
| `r92_remote_chainlag` | 3 | A→B→C→leaf converges in ONE frame in both tree orders (`f1[b=c=leaf=write]`) |
| `r92_remote_srv` | 3 | pushed transform reaches `body_get_state` + ray `hit@5.000,0.500,0.000`; Dummy: `srv_o=null`, `ray=miss` |
| `r92_remote_drive` | 9 | `driver`+`parent`+`local`: `set_process(false)`/`set_physics_process(false)` do NOT gate the pass; parent move/scale pushes |
| `r92_animphys_rbpos`/`rbfrozen`/`animrb` | 9 | per-tick anim teleports on live/frozen/falling bodies; `srv` lags node one tick; gravity integrates under the written transform |
| `r92_animphys_animatable` | 3 | `sync_to_physics` true/false identical on gp/jolt (`ab→0.5`, ray hit); **Dummy inversion**: moves only under `false` |
| `r92_animphys_reset` | 3 | literal `RESET` animation plays as a track: `pos→(7,0,0)`, `anim=RESET` — no snapshot restore |
| `r92_animphys_manual` | 3 | PROCESS_MANUAL frozen until `advance(0.5)` → `pos=(1.5,…)`, `t=0.5` |
| `r92_animphys_destroy` | 6 | `empty_track` resting depth **0.3920 gp / 0.0800 jolt / 0.0000 dummy**; `badkey` wrong-typed inserts `-1,-1`, keys=0, play still teleports to ZERO (e=2 engine ERRORs pinned) |
| `r92_animphys_iforder` | 3 | E-callback reads previous push; idle read sees current push (+0.05/tick) |
| `r92_animphys_idlemode` | 24 | **envelope arm**: 8 reps/backend; marker = `ok=8, xband=0.2-0.5` per backend |
| `r92_animphys_badkey_insert` | 3 | negative: honouring `-1` + refusing play leaves the transform intact → `NEGATIVE REJECTED` exit 2 |
| `r92_timing_tps` | 6 | tps 30→`0.033333`, 120→`0.008333` effective next tick |
| `r92_timing_tscale` | 9 | ts 0.5→`0.008333`, 2→`0.033333`, 10→`0.166667` at unchanged tps |
| `r92_timing_edge` | 6 | ts=0 → `0.000000` deltas, pf advances; ts=-1 → `-0.016667` |
| `r92_timing_refuse` | 6 | tps 0/-60 refused, `e=1`, tps reads back 60 |
| `r92_timing_steps` | 9 | `mps=1`+ts=10 delivers full `0.166667` (no clamp); `interp` write reads back true, schedule unchanged; **`jitfix0` = first real measurement** of the jitter-fix axis (`0.5→0.0`, schedule unchanged) |

All animation cells pin `callback_mode_process=ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS` except `idlemode` (the contrast cell).

## Rep-stability contract

Per the scout receipt: only pf-stamped observables and labelled rows cross the child boundary — `seq`, `n_e`, `n_f`, `anim_t`, F-row multiplicity never emitted. Digest cells embed `m=` M-lines verbatim + `rc,e,w,s` counts (`s`=script-error/leak/crash, pinned 0). Verified: every arm's full digest byte-identical across two consecutive arm runs, and all 23 rows byte-identical between the two full battery runs.

`idlemode` envelope (the scout's three non-rep-stable cells, one per backend): 8 independent child processes each; predicate = rc=0, e=0, w=0, s=0, exactly one M0+DONE, `post` row with `x∈[0.05,1.2]`, `y=2.0000`, `z=0.0000`, `playing=true`, `lv`/`srv` per-backend constants. Observed x over 24 dev+battery samples: 0.2686–0.2895 → `xband=0.2-0.5` (median bucket). Requirement was ≥6 reps; armed 8.

## Backend splits pinned

- `srv`/`ray`: gp+jolt `srv_o=(…)` + `hit@5.000,0.500,0.000`; dummy `null`/`miss`
- `animatable`: gp/jolt move under both sync values; dummy only under `sync_to_physics=false`
- `empty_track` rest depth: `0.3920 / 0.0800 / 0.0000`
- rider settle: `2.9973` gp vs `3.0000` jolt+dummy
- `idlemode` lv/srv: `(0,-1.1376,0)`/`(x,2,0)` vs `(0,0,0)`/`nil`
- all remote node-side cells and all timing cells backend-identical (as measured)

## Battery

- Before: **235 cases** (189 ordinary + 46 negative) — r92-baseline runs pass
- After: **258 cases** (211 ordinary + 47 negative) = +23
- Run 1 (`runs/20261015T175116507786Z`): 257/258 — `bpy_rbw3d_render` emitted `rdet stable=True` vs pinned `False`
- Run 2 (`runs/20261015T175829468804Z`): **258/258 PASS**, seeds unchanged both runs

Prior-row byte-identity run1↔run2: **234/235 identical** in exit+stdout+stderr. The single delta is `bpy_rbw3d_render`'s `rdet.stable` — the **r91-documented stochastic PNG pin** (r91-author: "PNG bytes are not a witness; 1-sample stable = cell fails is the intended mode"; r91-scout §6.2 recorded `stable=True` as a possible observation). It flipped True→False between the two runs, i.e. the cell sampled both distribution values — pre-existing distribution cell, unrelated to r92 (Blender render nondeterminism, no Godot dependency).

## Corrections / disclosures vs scout

1. **`jitfix` arm**: the scout arm wrote the default `0.5` (no-op). The landed `tm_jitfix0` writes `0.0` — first real measurement of that axis (delta schedule unchanged at 0.016667, `jit` reads back `0.0000`).
2. **`phase` F-arm**: scout rows used idle-frame counts that are scheduler-dependent; the landed port guarantees the post-write physics tick explicitly (`await physics_frame`), pinning `imm/same_f=0` vs `post_f/next_e=1` semantics without pf stamps on the F arm. Reps now byte-identical.
3. `remote3d_transform` (existing fixture) waits 4 frames; measured law needs 1 — left unchanged (still correct, merely conservative).
4. `bpy_rbw3d_render` flip documented above — worth folding into the corpus's known-distribution list if not already there.

## Commands (repro)

    # dev sweeps (per-case children, 3 backends × 2 reps; only idlemode diffs)
    godot --headless --path <proj> --script res://r92_child.gd -- <case>
    # parent arms
    godot --headless --path corpus/live/r92-author/dev/proj \
        --script res://r92_remote.gd -- --arm=<arm>
    # battery
    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
        --runs corpus/live/r92-author/runs          # ×2

No commit made, per instruction.
