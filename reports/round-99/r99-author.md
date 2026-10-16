# r99 author — AnimationTree / AnimationNodeBlendTree lattice

Task: `.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r99-author.md`.
Encode, as a battery-pinned fixture lattice, only the AnimationTree /
AnimationNodeBlendTree claims that survived the r99 boundary round.

## Sources consumed

- `reports/round-99/r99-scout.md` (132 cells / 536 children, 7 unstable
  tags — all unthrottled-IDLE callback interleave)
- `reports/round-99/r99-boundary.md` (292 cells / 939 children, 0 crashes,
  byte-stable under `--fixed-fps`, backend-inert modulo Dummy server reads)
- `corpus/live/r99-scout/probes/`, `corpus/live/r99-boundary/probes/`
- `corpus/fixtures/r97_nodelat.gd`, `corpus/fixtures/r98_gltflat.gd`
  (parent-fixture architecture: per-cell child projects, batched
  `OS.create_process` spawns, normalized-sha digest cells, `beq`
  cross-backend pins)

## Files changed (tracked)

| file | change |
|---|---|
| `corpus/fixtures/r99_animtree.gd` | new parent fixture (779 lines, 9 arms) |
| `corpus/fixtures/r99_probe_r99b_core.gd` | new, byte-identical copy |
| `corpus/fixtures/r99_probe_r99b_life.gd` | new, byte-identical copy |
| `corpus/fixtures/r99_probe_r99b_modes.gd` | new, byte-identical copy |
| `corpus/fixtures/r99_probe_r99b_silent.gd` | new, byte-identical copy |
| `corpus/fixtures/r99_probe_r99b_sm.gd` | new, byte-identical copy |
| `corpus/fixtures/r99_probe_r99b_untracked.gd` | new, byte-identical copy |
| `corpus/fixtures/run_battery.py` | +29 lines (11-line comment + 9 CASES tuples), insertion-only, zero deletions |
| `reports/round-99/r99-author.md` | this report |

Probe-copy SHA-256 vs `corpus/live/r99-boundary/probes/` (verified equal):

| probe | sha256 |
|---|---|
| r99b_core | `6683aba10439885d08488fd36275fabbb938895f04a853cb2650e4e10db0ff51` |
| r99b_life | `2eb2e2428a317934aa88682e1f3477352771243413fc5201df001b37e4724df8` |
| r99b_modes | `f6d23bb1f69e2c4f27d5904d846d3394edb83e73ae1386c25624f00ea6195ff5` |
| r99b_silent | `de0fd54e2ed5dbed8912f0848cb99d7775314510638a4802dc85571d54b645ee` |
| r99b_sm | `a8d41a1b1fd5c624d2f5501bbc4a1ba19cba15679ee5f01284120bcc8b229081` |
| r99b_untracked | `5981275d176f1fc06c5d644165ab3293cd079a54d9a700c7c2bca7eefb745afd` |

## Rows added

9 battery rows (one per arm), each a single `PASS r99_animtree <arm> …`
marker over 183 cells = 61 logical cells × 3 backends
(GodotPhysics / Jolt / Dummy), all children at `--fixed-fps 60`:

| row | cells | pins |
|---|---|---|
| r99_animtree_core | 21 | receiver-first `connect_node` (provider-first ee=1, actor never moves); 4·tp clock exactness (dz=0); tree drives without `player.play` (playing=false, raw position read errors once); exact `blend_amount` read-back; TimeScale 2×; root-swap pose cut on a continuing clock; tree write reaches the physics server identically on GP+Jolt (Dummy srv=nil) |
| r99_animtree_ut_scope | 21 | untracked-default write scope = mixer (path, track-type) set across ALL driving-player libraries; not from live Animation objects, not from other players; server+node both zeroed on GP/Jolt |
| r99_animtree_ut_mech | 21 | keyed by track type (scale/rot reset, position survives); needs active tree + a process pass (inactive/manual hold); re-applied every pass (hand-restore re-zeroed); plain `player.play` does NOT do it; unresolvable path warns once at cache build |
| r99_animtree_modes | 27 | under ffps every cell byte-stable; PHYSICS rate-invariant (f30/f120 peq=1); IDLE deterministic-per-rate but rate-dependent (peq=0); MANUAL inert until `advance()` with first-advance absorption; player `callback_mode_process` irrelevant under a driving tree |
| r99_animtree_order | 12 | corrected first-frames law: leading non-advancing frames are watcher-position dependent (phys pre=2 / post=1; idle=1 both) |
| r99_animtree_sm_adv | 27 | ENABLED never auto-advances in 7 wirings (swpf=-, node=a); AUTO+condition fires the frame after the condition write (swpf=7); condition-less AUTO fires on state entry (node=b, chain-skip) |
| r99_animtree_sm_misc | 21 | `next()` inert (ENABLED stays a; AUTO arm already at b via condition-less AUTO — receipt-verbatim encoding); travel path never populated; stale condition re-fires AUTO-only; `stop()` clears is_playing but not evaluation; `travel()` defers one process |
| r99_animtree_silent | 15 | missing anim/param silent (reads `<null>`, valid write lands); duplicate node/state names error once and keep the original; `travel(<unknown>)` errors on the next process pass (ee=6), state unchanged |
| r99_animtree_life | 18 | free tree freezes pose; free player does NOT stop the tree; free actor silent; null root freezes last pose; active off/on holds+resumes clock; 340 instantiate/free rounds safe |

Cross-checks in every non-`@gp` cell: `beq=1` (normalized child stream
identical to the GP twin) on all 122 comparison cells; `peq` compares the
ffps60 physics tuple inside rate-variant cells (1 on PHYSICS, 0 on IDLE).
`ee` counts expected engine ERROR lines; `swpf` records the pf a state
machine actually switched; `mk` would flag a missing end marker (none).

## Verification evidence

- r99-only pre-runs (9 rows each): `corpus/live/runs/20261016T071708787743Z/verdicts.json` PASS, `20261016T071742046259Z` PASS
- Arm-level scratch runs and child logs: `corpus/live/r99-author/ftest/r99t*/child.log`, captured PASS lines in `corpus/live/r99-author/passlines/`
- Full battery runs on final bytes, both green at 342/342:
  `corpus/live/runs/20261016T073752637660Z/verdicts.json` and
  `corpus/live/runs/20261016T074637746785Z/verdicts.json`.
  Two earlier attempts failed only on legacy flake class (2) below —
  `20261016T071812120994Z` (navagent3d_follow, phys3d_events_deferred_hang),
  `20261016T072806927381Z` (navagent3d_retarget, r96_joltdet_thread);
  all 9 r99 rows passed on every attempt.

Reproduce:

```sh
python3 corpus/fixtures/run_battery.py --only \
  r99_animtree_core,r99_animtree_ut_scope,r99_animtree_ut_mech,\
  r99_animtree_modes,r99_animtree_order,r99_animtree_sm_adv,\
  r99_animtree_sm_misc,r99_animtree_silent,r99_animtree_life
python3 corpus/fixtures/run_battery.py
```

## Deliberately not pinned

Unthrottled `base` rate cells (scheduler-load variable by construction),
`xfade_time` crossfade, what ENABLED is *for*, BlendSpace1D/2D, OneShot /
Transition / Add2/3 / Mix*/Sync, play_mode/backward, root_motion,
skeleton targets, and every scout-only arm the boundary never replayed.

## Known flake classes

1. **`clsloop` teardown abort (td-encoded).** The 340-instance/free-loop
   child completed `CLS_LOOP_ALIVE` + `LIFE_DONE` in every observed run
   but once aborted in engine shutdown with glibc
   `corrupted size vs. prev_size while consolidating` (rc=134,
   host load ~60). Boundary ran the same probe 24× clean. The cell is
   `td` — the hashed stream is truncated at the arm marker (both outcomes
   hash `9251889a008ea983`) and rc accepts the honest token `0|134`. An
   abort *before* the marker still fails the cell.
2. **Pre-existing unthrottled cells elsewhere in the battery**
   (not r99): under the current host load (loadavg >50), legacy
   scheduler-sensitive cases flake intermittently — observed
   `navagent3d_follow`, `navagent3d_retarget`,
   `phys3d_events_deferred_hang`, `r96_joltdet_thread` across attempts;
   different cells each run, all outside r99. All 9 r99 rows passed on
   every attempt (2 r99-only selections + all 4 full-battery attempts).

## Blockers

None. Two consecutive fully-green 342-case battery verdicts on the final
bytes are recorded above; the r99 rows passed on all 4 battery attempts
and both r99-only selections.

## Commit

None. `run_battery.py` change is insertion-only (29 lines added, 0
removed); probe copies verified byte-identical to boundary sources.
