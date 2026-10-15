# r91 author — the bpy rigid-body world + point-cache lattice (bpy_rbw3d)

10 arms in `corpus/fixtures/bpy_rbw3d.gd` (SceneTree parent) + bpy child
probe `corpus/fixtures/r91_child.py`, **+10 battery rows → 235**
(189 ordinary + 46 negative), all on Blender 5.2.1 LTS headless
(`/usr/bin/blender -b -P`), this host.

**Seat completion note:** the dispatched author died after writing the
measure probe `corpus/live/r91-author/probes/m1.py` (8 modes, no runs).
This seat ran it to decide the open unknowns, kept the sound cells and
rewrote what was not, then landed the fixture + rows. Salvage ledger:

- `rebuild3`/`fps3`/`knobs` — ran clean: in-process
  `read_factory_settings` rebuilds are trajectory-identical (×3, h
  `3302e3c1de9c5dd0`), so the multi-variant knob cells run as
  one-process lattices inside single children.
- `extend` — re-measured scout 1.7 on this host: presweep 1..40 then
  `pc.frame_end=20` + bake → flood 40, post-bake `info='40 frames…'`,
  read `h=cfb45aff07e749b5` (frozen tail). Ported as `presweep20`.
- `blend` — decided the scout's open unknown: a **baked cache survives
  save/reload** (`loaded_pc info='40 frames in memory (7 KiB).'
  baked=True`; jump40/jump20 served). But the probe's BHead parse is
  dead code on this build — 5.2.1 writes a **zstd container**
  (`magic=28 b5 2f fd`), and file size/sha **drift rep to rep**
  (88638→88640 B). Pin = reload behaviour only, never file bytes.
- `render` — no-step cell reproduced (pre==post at fcur=40).
- `exit2`/`exit_os2` — `sys.exit(2)`/`os._exit(2)` propagate rc=2;
  unused by the fixture (the parent's log-scan + rc envelope carry the
  contract), kept as probe evidence.

## Convention mapping

The bpy surface has **one solver** — the per-(case, backend) spawn
convention of `phys3d_joints.gd` maps onto per-case Blender children.
The parent generates `res://r91bt_<arm>_<case>/`, spawns
`timeout -s KILL 15 /usr/bin/blender -b -P res://r91_child.py -- <case>
<dir>` with stdout+stderr merged into `child.log`, and scans for
`M`-prefix verdict rows plus four counted classes: `e` (lines starting
`Error`/`Traceback`/`RuntimeError`), `w` (`WARNING`/`Warning`), `b`
(`bake: frame` flood lines — the bake-range witness), and the
`blender.crash.txt` marker. Emits `case@bpy{rc,m,e,w,b}` or the
`{mode_ok,m<N>=sha,rc}` crash envelope. No PNG/.blend bytes, no scratch
paths, no wall-clock fields cross the boundary — those drift.

## Cells (all values measured on this host, standalone ×2 byte-identical)

| arm | cases | pinned class |
|---|---|---|
| `det` | `free`, `bequiv` | free-run `h=3302e3c1de9c5dd0` stable across re-sweep and a 41..60 excursion; `bake_all` ≡ free run (`eq_free=True`), `info='250 frames in memory (41 KiB).'`; the post-narrow rebake floods **40** lines — the bake extends over already-simulated frames, not the narrowed `pc_fe=20` (b=290 = 250+40 pinned as measured) |
| `bake` | `bake20`, `bake5_30`, `scene20b`, `presweep20` | bake range = pc range: b=20 / b=26 / b=250 under `scene.frame_end=20` (scene range ignored) / b=40 after presweep; phase-shift pins `f20=(0,0,3.087401)` on 5..30; frozen-tail reads `h=cfb45aff07e749b5` |
| `window` | `end20`, `start20`, `scene20w` | the pc range IS the sim window: end20 tail frozen `h=6498e1a38a4b7b9f`; start20 phase shift (f21 = free-run f2) `h=3a72772535e85419`; scene20w unconstrained `h=74e6cfb2e009f02f` |
| `order` | `order`, `bjump` | `frame_set(40)` never sims (loc stays `(0,0,5)`); backward/subframe/frame0 reads deterministic; post-bake jumps are addressable, `jump60_past_cache` holds the f40 state; `b=40` |
| `resim` | `stale`, `resim`, `partial`, `trace`, `ctrl025` | `is_outdated` not honored (baked ts=0.25 reads serve ts=1 bytes, `eq_free=True`); `free_bake_all` clears only the flag; disabled RBW serves authored `(0,0,5)` `h=5c473677cca8d53a`; resim tail stays frozen; **partial** mixed tail `h=393edd37abcaef22`; **trace** the read-order cell — R20 returns the frame-5 value `4.860652`, T frozen, H2 ≡ ts025 control; ctrl `h=5c2eb7d566c54855` |
| `knobs` | `fps`, `solv` | fps 24/60/120 → `3302e3c1de9c5dd0`/`1f12776ddff6285f`/`9c73c3f28300910c` (the time base is scene fps); substeps 1/40, iters 1, split 1 → `4161bab53d2cbe73`/`898e0dd0a6c61fc4`/`6eae9b3b9a01a1dd`/`a3657c2e88f737c2` — every knob moves |
| `ops` | `polls`, `b2k`, `disk` | headless poll matrix (`bake_all`/`free_bake_all` only) + RuntimeError refusals; `bake_to_keyframes` polls True but dies inside the anim op (`pollfail=True kf_op=True`, `actions=0`, deterministic `e=4` — two printed tracebacks); `use_disk_cache` write refused, `use_external` kills the cache silently (`info='No valid data to read!'`, `bake_all` still FINISHED over it, `b=250`); cloth cache identical |
| `io` | `blend` | baked cache survives `save_as_mainfile` + `open_mainfile` (closes the scout's unknown); `exists=True` only — file bytes drift |
| `render` | `shot`, `rdet` | render does not step the sim (`pre==post` at every fcur); `stable=False`/`differs=True` — PNG bytes are not a witness |
| `ptr` | `ptr_stale`, `ptr_fresh` | stale-RNA-pointer write across `read_factory_settings` → **SIGSEGV**: `rc=139` via `timeout -s KILL`, crash marker present, `m3=b748ab7457574f90` (M0+`reset`+`pre_write`; `post_write`/`DONE` absent); fresh-pointer control rc=0 |

## Crash-envelope convention

`ptr_stale@bpy` pins the envelope — `mode_ok=1` iff the log carries the
`blender.crash.txt` marker AND `rc ∈ {134,139}` AND the M-prefix is
exactly the 3-line breadcrumb prefix (sha-pinned) — never ASLR/backtrace
bytes. A clean exit, a hang (rc 137 without the marker), or a shifted
prefix all fail the cell.

## Run evidence

- Standalone ×2, byte-identical per arm:
  `corpus/live/r91-author/standalone/*.r{1,2}.txt` (diffs empty) +
  `*.marker.txt` (the pinned PASS lines).
- Full battery **235/235 PASS**, `seeds_unchanged=true`, exit 0:
  `corpus/live/r91-author/battery-runs/20261015T160201215229Z/verdicts.json`
  (log `corpus/live/r91-author/battery-full2.log`).
- Prior-row stability: all 225 pre-existing cases byte-identical
  (stdout+stderr+exit) between runs `…155547020405Z` and `…160201215229Z`;
  the 10 new rows sit tail-appended after `phys3d_joints_twopin`.
- r91 rows at battery time: 0.77–2.24 s per arm (25 blender children
  across 10 rows; per-child `timeout -s KILL 15`, case cap 20 s).
- Measure-probe outputs: the m1 mode transcripts above were run under
  `corpus/live/r91-author/probes/` (m1.py verbatim, dead seat's file).

## Deviations / incidents

- **First full run failed `seeds_unchanged`:** a concurrent seat edited
  `corpus/fixtures/phys3d_joints.gd` at 12:56:09 local, ~22 s into the
  run (comment-only wording fix inside the r90 BIMODAL note;
  `559b1c89…→88be87fa…`). The battery's own seed guard caught it
  correctly. The foreign edit is preserved untouched; the re-run on the
  quiescent tree passed 235/235 with seeds intact. Recorded here for the
  verifier's awareness — not this seat's edit.
- `m1.py`'s BHead block parse was dropped (5.2.1 `.blend` is a zstd
  container — `magic=b'(\xb5/\xfd\xa0A\x06'` measured) and its `msg=`
  line in the b2k cell carried a scratch path; both replaced by
  deterministic fields before porting.
- `corpus/fixtures/README.md` count updated 225→235 (179→189 ordinary).

## Bounds

- Bounded to `/usr/bin/blender` **5.2.1 LTS** (hash `9e2066aef7ef`),
  `blender -b -P`, this host; Godot 4.7.2 is only the runner shell.
- Float tuples are 6-dp formatted; trajectory `h` is sha256-16 over the
  repr — engine-build-coupled pins, not cross-build claims.
- `rdet`'s `stable=False` is a measured mode pin (PNG nondeterminism):
  3/3 scout reps + 3 author realizations; if a build ever renders a
  1-sample state byte-stable the cell fails — that is the intended
  falsifier, not a flake.
- `b2k`'s `e=4` counts the runtime's own double-printed traceback of the
  execute-refusal; deterministic on this host, brittle by nature — it is
  pinned as an observation of stderr noise, not a semantic contract.
- Not covered: cloth/soft-body bake determinism beyond the disk-flag
  refusal; `frame_step > 1`; other geometry/RBW settings; sub-frame
  reads beyond `f40+0.5`; the three.js adapter lane stays unmeasured
  (no tracked dependency).

## Process hygiene

No leaked `godot`/`blender` processes from this seat's runs (checked
post-battery); each blender child is bounded by `timeout -s KILL 15`
and a generated per-case dir under the battery scratch, removed with the
run tree. The `ptr_stale` core dump writes `/tmp/blender.crash.txt`
(Blender's own crash artifact, shared path — not per-run state).

Tree state left dirty per dispatch: `run_battery.py` (+10 CASES rows),
`README.md` (count), new `bpy_rbw3d.gd` + `r91_child.py`, this report,
and the foreign `phys3d_joints.gd` comment edit — nothing committed.
