# game-dev-3d round 80 — scout (seat: scout, host: devin)

Axis: **bpy eval-event catalogue** (extends r79 two-layer lattice). Claim under
test: *"the eval-event set is enumerable and closed"* — falsified if any probed
mutation class flushes held handles without one of
`{evaluated_depsgraph_get, view_layer.update, frame_set, dg.update, bpy.ops}`
firing. Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `3f9e070`,
working tree clean at scout start (11:18). **Baseline note:** the tracked
`corpus/fixtures/bpy_sync_probe.py` was subsequently folded by the author seat
in parallel (mtime 11:22:44, sha `e9609814…`, 39248 bytes, different row
schema; diff vs baseline is additive except the runner-tuple line
`arm_vis_quirk):` → `arm_vis_quirk, arm_evalcat):`, so r79 arm bodies are
preserved and the new arm runs last); every scout measurement here is against
the r79 baseline, preserved
byte-identically at `corpus/live/r80-scout/bpy_sync_probe.py` (sha
`740ccdf6…`). Runtime: Blender 5.2.1 LTS headless (`/usr/bin/blender`,
`blender -b -P`, hash `9e2066aef7ef`), same build as r79/frontier. Frontier
read first: `reports/frontier/fa-bpy-evalcat.md` +
`corpus/live/frontier-bpyeval/` (receipts re-read: `runs/evalcat1.stdout.txt`,
`runs/evalcat2.stdout.txt`). Probe scratch: ignored `corpus/live/r80-scout/`
(`corpus/.gitignore:1 live/`). Write scope respected: this report + scratch
only; no git mutations.

## (0) Viability — positive

| command | exit | wall | evidence |
|---|---|---|---|
| `blender -b -P bpy_sync_probe.py` (tracked fixture rerun) | 0 | 542ms | `runs/tracked.stdout.txt`, stderr 0 bytes; **byte-identical** to tracked receipt `corpus/live/runs/bpy-20261014T141354732737Z/probe.stdout.txt` (both sha256 `69b512cb…`) |
| `blender -b -P bpy_sync_probe_r80.py` (fold candidate) | 0 | 815ms | `runs/folded2.stdout.txt` (sha `84cee6d9…`), 118 ARM lines, stderr 0 bytes, `PROBE_DONE` |
| `python3 bpy_battery_r80.py --runs runs/battery` | 0 | 0.773s probe | `runs/battery/bpy-20261014T142201074120Z/verdicts.json` — **67/67 PASS** (37 r79 + 30 evalcat), signal_fail=0, quirk_drift=0, fatals=0 |
| `blender -b -P bpy_closure_probe.py` | 0 | 1151ms | `runs/closure1.stdout.txt` (sha `f61162a8…`), 25 ARM lines, `CLOSURE_DONE` |
| iso `iso_dgupdate.py` / `iso_selall.py` / `iso_selall2.py` | 0 | — | `runs/iso_*.stdout.txt` |

## (1) Fold candidate — `evalcat` arm with per-op edge rows

Ready-to-fold artifacts (scratch): `evalcat_section.py` (sha `028f28de…`),
assembled candidate `bpy_sync_probe_r80.py` (sha `1a0a6e03…`, prefix before the
runner block copied verbatim from `corpus/fixtures/bpy_sync_probe.py:416`),
battery copy `bpy_battery_r80.py` (sha `799b4446…`), edit spec `FOLD_SPEC.md`.
Values below are `runs/folded2.stdout.txt`, identical in the battery probe run.
`dup`/`fc` are handler-fire deltas sampled per row (`dup` =
`depsgraph_update_post`, `fc` = `frame_change_post`); `dup_ge1`/`fc_ge1` are
derived booleans so pins are "≥1" without pinning the unstable exact op counts.

**Event classes** (held handle `dg0` captured pre-write; "flush" = held read
shows post-mutation state at write+0):

| row | held at write+0 | control | handler delta | battery pin |
|---|---|---|---|---|
| `rna-write` | stale `(0,0,0)` | RNA `(1,0,0)` | dup 0 / fc 0 | held stale, dup_ge1=False |
| `get-dirty` | **flush** `(1,0,0)` | fresh `(1,0,0)`, `same=True` | dup 1 / fc 0 | flush + dup_ge1=True |
| `get-clean` | unchanged | — | dup 0 / fc 0 | dup_ge1=False |
| `vl-update` | **flush** `(2,0,0)` | — | dup 1 / fc 0 | flush + dup_ge1=True |
| `frame-set(+1)` | **flush** `(3,0,0)` | — | dup 0 / fc 1 | flush + fc_ge1=True |
| `frame-same` | **flush** `(4,0,0)` | — | dup 0 / fc 1 | flush + fc_ge1=True |
| `dgupdate-pre` | stale `(4,0,0)` | — | dup 0 / fc 0 | (control) |
| `dgupdate` | **flush** `(5,0,0)` | — | dup 1 / fc 0 | flush + dup_ge1=True |

**`bpy.ops` class** (10 mutating calls; held witness per call):

| row | held at write+0 | ret | dup | pin |
|---|---|---|---|---|
| `apply-w0` (RNA loc write) | stale `v3xmax1.0` | — | 0 | stale, dup_ge1=False |
| `apply-post` (`transform_apply`) | **flush** `v3xmax6.0` | FINISHED | 2 | flush + dup_ge1=True |
| `add-post` (`primitive_cube_add`) | **flush** `Cube|o` | FINISHED | 1 | flush + dup_ge1=True |
| `modrna-post` (`modifiers.new` RNA) | stale `v16xmax1.0` | — | 0 | stale, dup_ge1=False |
| `modapply-post` (`modifier_apply`) | **flush** `v49xmax1.0` | FINISHED | 2 | flush + dup_ge1=True |
| `modadd-post` (`modifier_add`) | **flush** `v169xmax1.0` | FINISHED | 1 | flush + dup_ge1=True |
| `mode-edit` / `mode-object` (`mode_set`) | **flush** `(5,0,0)` | FINISHED | 2 / 1 | flush + dup_ge1=True |
| `locclear-post` (`location_clear`) | **flush** `(0,0,0)` | FINISHED | 1 | flush + dup_ge1=True |
| `conops-post` (`constraint_add`) | `(0,0,0)` inert | FINISHED | 2 | dup_ge1=True |
| `conops-target` (constraint target RNA) | stale `(0,0,0)` | — | 0 | stale, dup_ge1=False |
| `conops-fresh` (tagged get) | `(3,0,0)` | — | 1 | applies + dup_ge1=True |
| `del-post` (`object.delete`) | **flush** names `""` | FINISHED | 2 | flush + dup_ge1=True |
| `dupe-post` (`object.duplicate`) | **flush** `o|o.001` | FINISHED | 2 | flush + dup_ge1=True |
| `selall-post` (`select_all`) | unchanged | CANCELLED | 1 | not pinned (quirk §5) |
| `undopush-post` (`ed.undo_push`) | unchanged | FINISHED | 0 | dup_ge1=False |

**Write classes with an eval edge** (frontier reproduced):

| row | held at write+0 | tagged eval | frame path | pins |
|---|---|---|---|---|
| `driver-post` / `driver-fresh` | stale `(0,0,0)` | fresh `(7,0,0)`, dup 1 | — | edge = 1 tagged eval |
| `driver-edit` / `driver-edit-fresh` | stale `(7,0,0)` | fresh `(9,0,0)`, dup 1 | — | expression edit = plain RNA write |
| `kf-w0` (`keyframe_insert`) | stale `(0,0,0)`, ret=True | `kf-fresh` still `(0,0,0)` **despite dup 1** | — | insert fires nothing |
| `kf-wU` (`view_layer.update`) | still `(0,0,0)` (dup 0, graph clean) | — | — | fcurve inert through tagged evals |
| `kf-wF` (`frame_set+1`) | **flush** `(0,4,0)`, rna_y 4.0 | — | fc 1 / dup 0 | binds only on frame path |

## (2) Claim verdict — not falsified on the probed surface

The eval-event set reproduced from the frontier is exactly:
tagged path `{evaluated_depsgraph_get (dirty), view_layer.update (dirty),
dg.update}` + `bpy.ops` (10/10 mutating op invocations fired the tagged path —
9 with an observable held flush at write+0; `constraint_add`'s eval is
unobservable while the constraint is inert, witnessed by dup=1),
frame path `{frame_set ±Δ and same}` (fires `frame_change_*`, bypasses
`depsgraph_update_post`). RNA/data-API mutations never flush (r79 arms + §4).
No probed mutation class flushed a held handle without one of the five event
classes firing — **the closure claim survives this sweep; it is not proven
closed beyond the probed surface** (unprobed classes in "Confidence and
remaining unknowns").

## (3) Byte-stability of r79's 37 cases — required, verified

- (a) Tracked fixture rerun is byte-identical to the tracked receipt (sha
  `69b512cb…`, 78 ARM lines).
- (b) Folded probe's 78 r79 ARM lines are byte-identical to that receipt
  (`build_folded.py` asserts the pre-runner prefix is byte-identical; the run
  diff confirms all 78 lines).
- (c) Battery r80 `verdicts.json`: 37/37 r79 cases PASS, quirk_drift=0; the 30
  new `evalcat_*` cases PASS too (67/67). evalcat rows are identical across
  folded2 and the battery probe stdout. A second battery run
  (`runs/battery2/bpy-20261014T142250177981Z/verdicts.json`) also 67/67 PASS.
- Transparency: the first fold run (`runs/folded1.stdout.txt`) emitted `dup=0`
  on the `dgupdate` row because my row re-baselined the counters *after* the
  update. `iso_dgupdate.py` proved `dg0.update()` fires dup ×1 in three
  sequences (frontier tail, r79 transform tail, plain write+update); the fixed
  row measures dup=1. This was a probe bug, not a runtime discrepancy.

## (4) Closure sweep — 10 mutation classes the frontier did not probe

`bpy_closure_probe.py` (sha `1ff4f1fe…`); each class has a `-fresh` control
proving the witness is discriminating:

| class | held at write+0 | dup/fc | fresh control | falsifier? |
|---|---|---|---|---|
| `ob.data = <other mesh>` | stale `v3xmax1.0` | 0/0 | `v4xmax1.0` | no |
| mesh vertex `co` write | stale `xmax1.0` | 0/0 | `xmax9.0` | no |
| `modifiers.remove` | stale `v49` | 0/0 | `v16` | no |
| `ob.parent = tgt` | stale `(1,0,0)` | 0/0 | `(11,0,0)` | no |
| new object + RNA link | stale `o` | 0/0 | `n|o` | no |
| `scene.collection.children.link` | stale `o` | 0/0 | `o|o2` | no |
| `ob.matrix_world = M` | stale `(0,0,0)` (rna `(2,0,0)`) | 0/0 | `(2,0,0)` | no |
| `D.objects.remove(ob)` | stale `o` (freed ID) | 0/0 | `""` | no |
| edit-mode `mesh.select_all` / `mesh.subdivide` | `v16` → subdivide **flush** `v49` | 1/0 each | `v49` | no (op class) |
| edit-mode `mode_set` pair | flush by op | 1/0 | — | no (op class) |

`objrm-w0` note: after data-API removal the held graph still enumerates the
freed object (`held_names=o`) while fresh is empty — stale-with-freed-ID. Not a
falsifier; worth knowing before any arm caches handles across removals.

## (5) Refinements and quirks (measured)

- Edit-mode `bpy.ops.mesh.*` (frontier unknown): `mode_set(EDIT)` dup=1,
  `mesh.select_all` dup=1, `mesh.subdivide` dup=1 + held flush v16→v49,
  `mode_set(OBJECT)` dup=1 — edit-mode ops are ordinary members of the op class.
- `bpy.ops.object.select_all(action='SELECT')` returns `CANCELLED` headless yet
  fires dup ×1 (isolated twice; returns FINISHED when it actually changes
  selection) — op evals are not strictly mutation-gated. Not pinned
  (context-brittle ret); `undo_push` (FINISHED, dup=0) is the negative control.
- `get-clean` fires nothing — a `get()` on a clean graph does not evaluate
  (r79/frontier conditional confirmed in the folded arm).
- `dup` is not a universal eval witness: `frame_set` (incl. same-frame) fires
  `fc` only, and `dg.update()` fires `dup` only.

## (6) Fold spec for the author

1. `corpus/fixtures/bpy_sync_probe.py`: insert `evalcat_section.py` verbatim
   immediately before the runner block (`:416`), extend the runner tuple with
   `arm_evalcat_events, arm_evalcat_ops, arm_evalcat_anim` **last** (so handler
   registration cannot affect the r79 arms), add a docstring paragraph.
   Nothing else changes.
2. `corpus/fixtures/bpy_battery.py`: append the 30 `evalcat_*` CASES rows
   verbatim from `bpy_battery_r80.py` (block between the r80 comment banners);
   `PROBE` unchanged. Pins are held/fresh witnesses + `dup_ge1`/`fc_ge1` only.
3. Optional: fold the §4 closure arm for negative controls.

Note: the tracked fixture already carries the author seat's own evalcat fold
(EDGE-row schema with auto-computed `FALSIFIED`/`violations`, sha
`e9609814…`), landed in parallel after the scout baseline read. The row block
in `bpy_battery_r80.py` matches the scout candidate's ARM schema; if the
author's schema lands instead, the §1/§4 measured values remain the evidence
for its pins — only key names differ.

## Confidence and remaining unknowns

- **High**: fold safety (78 r79 lines byte-identical, 67/67 battery PASS);
  auto-eval of 10/10 mutating op calls at write+0; per-path handler split;
  driver edge = 1 tagged eval; keyframe frame-path-only binding (inert through
  tagged get and `view_layer.update`); 8 additional non-op mutation classes
  never flush; no wall-time/implicit drain.
- **Medium**: closedness holds only over the probed surface; mechanism of op
  evals (why CANCELLED `select_all` fires) unmeasured; `dup` x1/x2 variation
  still unpinned by design.
- **Unprobed classes** (each needs its own discriminating witness): library
  linking (`bpy.data.libraries.load`), node-tree / geometry-node socket writes,
  animation `action`/slot assignment via the 5.x layered API, render-engine /
  scene-setting writes (no held witness), timers/msgbus (dead headless).

## Receipts

| artifact | sha256 |
|---|---|
| `runs/tracked.stdout.txt` (== tracked receipt) | `69b512cb38555196214df312cef4567cf6df4279e37ea91e0b383e3976adf2e5` |
| `runs/folded2.stdout.txt` | `84cee6d98a619846345ffda5384e03c20f71be195cba13ad26030a43496c2563` |
| `runs/closure1.stdout.txt` | `f61162a84f9c8de7653b8e083cfabd6886cd8eca8d524385e32af46da48ace7d` |
| `evalcat_section.py` | `028f28dea373811e2ef6bef9c90330b5ac87cbd0bf82b22e4eb96af15a95a4e1` |
| `bpy_sync_probe_r80.py` | `1a0a6e03b519a89aea84939035341e563ba753eb342853eb8412be387bdc692d` |
| `bpy_battery_r80.py` | `799b444651ab50d4e183cc3c0394408344c32e6a7536fb469dabc050eb30dda3` |
| `bpy_closure_probe.py` | `1ff4f1feaa212d2587d94d21a519e58169c0d38fde7d599a93afb463dc8aec66` |
| tracked `corpus/fixtures/bpy_sync_probe.py` (r79 baseline as read; author folded later) | `740ccdf64c1918b2eb1b3b46746f87f384270827ce7e4c5f8f54d1831d61eec5` |
| tracked `corpus/fixtures/bpy_battery.py` (unmodified) | `e107b25152fcc828cf0ce65c8467f50c7001f0fb4851eeab5ec856158a79dc13` |

Battery verdicts: `runs/battery/bpy-20261014T142201074120Z/verdicts.json` and
`runs/battery2/bpy-20261014T142250177981Z/verdicts.json` (both 67/67 PASS;
probe exit 0; 118 ARM lines; 0.773s / second run).
