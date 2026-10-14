# game-dev-3d round 82 — boundary (seat: boundary, host: devin)

Wave `shokunin-train-20261101-w13`, lane g3d. Boundary lattice for the r82
author brief (ARM A evalcat residual fold, ARM B parser-hazard pins): the edge
cells the author did not build — evalcat classes near the boundary (nested
depsgraph, scene swaps), forged-row variants (misplaced `violations=0`,
truncated ARM lines), detach EOF under the battery timeout, and
`--python-use-system-env` env cells. This seat measures, does not fold, judge,
edit, or ship.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `31cf56a`
(r81 report-last), working tree clean at arrival (0 dirty entries; r82 author
had not landed at measurement time). Tracked fixtures as read:
`corpus/fixtures/bpy_sync_probe.py` sha256 `a4b1f94b…` (1262 lines),
`corpus/fixtures/bpy_battery.py` sha256 `111568ee…` (409 lines) — both
byte-identical to `git show HEAD:` and to the r82-simplifier arrival shas.
Runtime: Blender 5.2.1 LTS headless, `/usr/bin/blender` sha256
`fd7c5e44f50de3012e9cd8c919ce7cfaca716ff7bc3b9d9e53d300401b892e7c` (internal
build hash `9e2066aef7ef`), embedded CPython 3.14.7; host python3 3.14.7;
`io.DEFAULT_BUFFER_SIZE=131072` (this build). **LSP unavailability recorded:**
`mcp_list_servers` exposes only `rea` (Ghidra binary analysis) — no `lsp`
device serves this repo, so all symbol tracing below is text-level
(read/grep), never presented as semantic proof. Scratch + receipts:
`corpus/live/r82-boundary/` (`manifest.sha256` pins every artifact cited).
No tracked file modified; no git mutations. Every probe wrapped
`timeout -s KILL`; every fifo-adjacent cell bounded.

## (0) Viability

| command | exit | wall | evidence |
|---|---|---|---|
| `python3 corpus/fixtures/bpy_battery.py --runs …/runs/baseline{,2}` | 0/0 | 4.4 s probe each | **74/74 PASS ×2**, stdout sha `947ad726…` byte-identical ×2 (matches the r81 receipts) |
| `harness.py --mode canned` on the baseline stream | 0 | <1 s | 74/74 PASS — harness fidelity (tracked `main()` verdict logic on a canned stream) |
| `blender -b [-flag] -P mutants/envdiag.py` ×4 | 0 ×4 | 0.4 s each | `runs/env-e{0,1,2,3}_*.std{out,err}.txt` |
| `harness.py --mode real --flag=--python-use-system-env --env PYTHONUNBUFFERED=1` (tracked probe) | 1 | 4.4 s | `runs/envcollapse/bpy-…T152037266288Z` — 72/74, 2 order-checks fail |
| `make_edge_mutant.py` (+219/−1, insertion-only) → tracked battery on it | 1 | 4.4 s | `runs/edges-battery3/bpy-…T152247655563Z` — 73/74, only `evalcat_closed_set` FAIL |
| `make_forge_mutant.py` (+28/−1) → tracked battery ×5 env variants | 0/0/1/1/1 | 4.4 s each | `runs/forge-{after_mask,forge_full_keys,misplaced,truncated_key,truncated_nobody}` |
| synthetic streams + canned harness ×3 | 1 ×3 | <2 s | `runs/synth-*` |
| `make_detach_mutant.py` (+16/−1) → tracked battery ×4 | 0/0/1/1 | 12.4 / 10.4 / 60.2 / 60.2 s | `runs/detach-{d1_s8,d4_s6write,d2_s75b,d3_s300}` |
| direct mutant probe run (`runs/edges.stdout.txt`) | 0 | 4.7 s | stderr byte-empty; all mutant runs stderr 0 B |

All probe stderr files byte-empty. The tracked battery's own launch command is
hardcoded `[blender, "-b", "-P", probe]` (`bpy_battery.py:307-308`) — the env
cells are reachable only through a wrapper, so the harness monkeypatches
`run_process` (mirroring its timeout contract, `bpy_battery.py:264-275`).

## (1) Evalcat boundary classes — nested depsgraph + scene swaps

Method: insertion-only mutant of the tracked probe (`mutants/edge_section.py`,
+219/−1) with six boundary sub-probes appended to `arm_evalcat`'s tuple
before `closed`, so a bare flush/handler fire auto-FALSIFIES and counts. Same
witness discipline as the r81 ext fold (fresh factory scene, handler
reinstall, held `dg0` pre-window, fixtures built outside the window).
Measured rows (`runs/edges-battery3/…/probe.stdout.txt:118-126`):

| cell | held | handler deltas | edge | mechanism |
|---|---|---|---|---|
| `bx_scene_swap` | flushed (on swap-back) | **dfcp=2 dfc=2**, dpost=0 | **FALSIFIED** | two bare `C.window.scene =` swaps (out + back): each scene *change* fires one frame_change pair; the re-activated scene's graph is evaluated (held flush `(0,0,0)`→`(1,0,0)` on swap-back; swap-out does **not** flush: `held_out=(0,0,0)`) |
| `bx_self_swap` (control) | stale | 0 | 1 | assigning the *current* scene fires nothing → the event is the change, not the assignment |
| `bx_nested_vl` | stale | 0 | 1 | bare view-layer swap (`C.window.view_layer = vl2` and back) is silent; a tagged get binds (`fresh=(2,0,0)`) |
| `bx_nested_graphs` (info) | — | — | — | `same_vl2=False`, `same_a2=True`, `prop_match=True`: each view layer owns a **distinct** depsgraph object; the VL1 identity survives the round-trip; `vl2.depsgraph == C.evaluated_depsgraph_get()` while VL2 is active |
| `bx_scene_graphs` (info) | — | — | — | `same_ab=False` (scene B's graph ≠ scene A's), `same_a2=True`; cross-graph `ob.evaluated_get(dgB)` returns the **RNA pending value** (`(1,0,0)` while `held_out=(0,0,0)`) — a silent fallback, not an error, not an eval |
| `bx_scene_remove` | na (degenerate read) | 0 | na | `D.scenes.remove(scnA)` is silent; the held read returns the original's RNA value (`(3,0,0)`) with `ev_is_ob=True` |
| `bx_scene_remove_eval` (disambiguation) | — | 0 | na | modifier witness: pre=`verts49` (evaluated), held-pending=`verts49` (stale), after removal `held_mesh=verts16` (**base mesh**) + `ev_is_ob=True`/`ev_orig=True` → the value movement is a read-path fallback to the original ID, **not an evaluation** |
| `bx_scene_rebuild` | ERR:ReferenceError | 0 (artifact) | 0 | `bpy.ops.wm.read_factory_settings` invalidates both the held graph read and the RNA read (`held_loc=rna_loc=ERR:ReferenceError`); `handlers_after=0` — the reset clears the watched handler lists (see `_ec_register`, `bpy_sync_probe.py:464-480`), so the zero deltas are a measurement artifact, not "no eval" |

`closed` row on the mutant stream: **`violations=1`** (the scene swap only).
Tracked battery on the mutant stream: **73/74, only `evalcat_closed_set`
FAIL** — the boundary rows do not perturb any tracked row (isolation), and the
closed-set falsifier is live at the boundary.

Reading (bounded): the closed-set claim survives only *within its probed
catalogue*. The scene-swap class is a real sixth bare event class (fc-family,
outside the enumerated five — `bpy_sync_probe.py:454-455`); folding it as a
bare row breaks `violations=0`. Scene removal is inert but **witness-
degenerate**: the standard `_ec_held` discipline (`:573-582`) misclassifies it
as a flush, so folding it needs the `ev is ob` identity check or it emits a
spurious FALSIFIED. The nested/VL class is inert with per-view-layer graph
identity — the expected shape if it is ever folded.

## (2) Forged-row variants (misplaced `violations=0`, truncated ARM lines)

Method: insertion-only forge mutant (`mutants/forge_section.py`, +28/−1) —
a *real* untracked bare violation (`bx_forge_violation`: `dpre=1 dpost=1`,
`edge=FALSIFIED`, `violations=1`) plus an env-driven forged row
(`$BOUNDARY_FORGED`) written by the fd1-inheriting descendant in `arm_reorder`,
which lands after the real `closed` row (the parent flushes before spawning).
All verdicts below are the **tracked battery's own** logic (real capture or
canned streams; `runs/forge-*`, `runs/synth-*`).

| variant | forged/edited line | placement | battery | closed observed |
|---|---|---|---|---|
| `after_mask` | `ARM evalcat \| closed \| EDGE \| violations=0` | after real | **PASS 74/74, rc=0** | `{'violations':'0'}` — **masked** |
| `forge_full_keys` | `…violations=0 events=faked` | after real | **PASS 74/74, rc=0** | `{'violations':'0','events':'faked'}` |
| `misplaced` | `ARM evalcat \| closed_forged \| EDGE \| violations=0` | after real | FAIL (closed) | real `violations=1` stands; phantom cell added (`n_arm_lines` 123→124), **invisible** to every check |
| `truncated_key` | `ARM evalcat \| closed \| EDGE \| violations=` | after real | FAIL (closed) | `{'violations':''}` ≠ `'0'` — loud |
| `truncated_nobody` | `ARM evalcat \| closed \| EDGE` | after real | FAIL (closed) | `^ARM` needs a body → cell unchanged, real stands — loud |
| `forged_before_real` (synth) | `violations=0` | **before** real | FAIL (closed) | physical last-wins → real `1` wins — forgery ineffective |
| `real_truncated_key` (synth) | real row body cut to `violations=` | — | FAIL (closed) | `{'violations':''}` — loud |
| `real_truncated_nobody` (synth) | real row cut to 3 fields | — | FAIL (closed) | `missing ARM line for (evalcat \| closed \| EDGE)` — loud |

**Primary finding — complete silent pass.** With a real untracked bare-class
violation (stream line 119: `violations=1 events=…`), a descendant's forged
`violations=0` row (line 122) wins the `(evalcat, closed, EDGE)` cell
(physical last-wins, `bpy_battery.py:278-287`) and the battery reports
**74/74 PASS, exit 0** (`runs/forge-after_mask/…`). The per-row
`edge=FALSIFIED` line is present in the stream but unpinned — no CASES row
names `bx_forge_violation` — so the aggregate `closed` row was the only
detector, and it is overwritable. This is the first end-to-end demonstration
through the tracked verdict gate (r81-scribe cells H3a/H3c were parser-level;
r81-scout predicted the forged-pin path).

Secondary, measured parser facts:
- **Placement is load-bearing**: the mask requires the forged row to be
  physically last; before the real row it is inert (last-wins keeps the real
  value).
- **Truncation is fail-loud, not fail-silent**: truncated forged rows either
  overwrite with a non-matching value (`''` ≠ `'0'`) or fail the `^ARM`
  regex and leave the real row; truncated *real* rows lose the pinned key or
  the cell. (The glued-line drop-not-misattribute case is already tracked as
  `reorder_splice_dropped`.)
- **Misplaced rows are invisible**: there is no evalcat extra-cell guard
  (only `reorder_no_extra_cells`, `bpy_battery.py:358-360`); a phantom
  `evalcat | closed_forged | EDGE` cell changes only `n_arm_lines`, which is
  reported but not gated.
- A forged row replaces the whole cell dict: the `events=` diagnostic is
  rewritable too (`forge_full_keys` observed `events=faked` while PASSing).

## (3) Detach EOF under the battery timeout (`TIMEOUT_S=60`)

Method: insertion-only detach mutant (`mutants/detach_section.py`, +16/−1) —
a descendant inherits fd1 and outlives blender (lifetime via
`BOUNDARY_DETACH_S`, optional late write via `BOUNDARY_DETACH_WRITE`); the
parent does not wait on it. Tracked battery, real capture.

| cell | child lifetime | battery wall | verdict | measured |
|---|---|---|---|---|
| `d1_s8` | 8 s (< 60) | 12.44 s | PASS 74/74 rc=0 | capture EOF held until the descendant exits; case table unaffected |
| `d4_s6write` | 6 s + late row | 10.43 s | PASS 74/74 rc=0 | late `ARM detach \| late \| FD1 \| who=child` lands **after** `PROBE_DONE`, the banner and `Blender quit` (`done_marker` is presence-only, `bpy_battery.py:315`) — accepted silently |
| `d2_s75b` | 75 s (> 60) | 60.19 s | **FAIL rc=1** | `launch_ok=False`, `probe_error='TIMEOUT after 60 seconds'`, `probe_exit=None`, `probe_elapsed_s=60.06`; **cases 74/74 PASS**, `done_marker=True`, stream complete (123 ARM + `PROBE_DONE`); `probe.stdout.txt`+`verdicts.json` written |
| `d3_s300` | 300 s (never EOF in-run) | 60.17 s | **FAIL rc=1** | same as `d2_s75b`; **no hang** — orphan still held fd1 at return (pid 736950, killed by pid after) |

Findings: the battery returns at the timeout, not at descendant EOF (POSIX
`subprocess.run` kills/waits only the blender process; the descendant's fd1
copy is not waited on) — the FAIL is purely the launch gate
(`bpy_battery.py:314,388-389`) while every case passes; and the descendant's
post-timeout bytes are lost to the closed pipe. One aborted first attempt
(`runs/detach-d2_s75/…`, no `verdicts.json`) measured a harness that lacked
the tracked `run_process` catch — the tracked catch (`:269-273`) is what keeps
the timeout on the verdict path instead of a traceback.

## (4) `--python-use-system-env` env cells

`mutants/envdiag.py` (ARM-shaped rows) ×4, plus the collapse cell driven
through the tracked verdict gate:

| cell | flag | env | `ignore_environment` | `write_through` | PYTHONPATH import | PYTHONUNBUFFERED |
|---|---|---|---|---|---|---|
| `e0` | — | — | 1 | 0 | `ModuleNotFoundError` | — |
| `e1` | — | `PYTHONUNBUFFERED=1` | 1 | 0 | `ModuleNotFoundError` | visible in `os.environ` but **not honored** |
| `e2` | flag | — | 0 | 0 | **OK** | — |
| `e3` | flag | `PYTHONUNBUFFERED=1` | 0 | **1** | **OK** | honored |

`utf8_mode=1` in all four; `no_user_site` flips 1→0 with the flag.
The carried guard is confirmed and sharpened: the gate is
`sys.flags.ignore_environment` (1 without the flag → all `PYTHON*` env vars
ignored, incl. `PYTHONPATH`; 0 with it). Visibility is not honoring. The flag
alone does not change buffering (`e2` write_through=0); only flag+env does.

Collapse through the battery's own logic (`runs/envcollapse/…`): with the
flag + `PYTHONUNBUFFERED=1`, the tracked probe's stream is causal-order and
the battery reports **FAIL, 72/74** — order-checks
`reorder_child_before_pre_spawn` and `reorder_splice_dropped` FAIL; cases
`reorder_dup_lastwins` FAIL (`src=child_inj` — logical-last becomes
physical-last under write-through) and `reorder_post_spawn_row` FAIL
(`write_through=True`). The splice casualty flips from the parent's
`gluevictim` to the parent's own `dup` row
(`REORDERGLUE::ARM reorder | dup | FD1 | src=parent` at line 124). This is the
natural, non-mutant falsifier of the reorder pins — a supported runtime
configuration, not a mutation. The tracked battery cannot enter this regime
itself (launch hardcodes no flag, `bpy_battery.py:307-308`).

## (5) Determinism / byte-stability

- Tracked battery ×2 at r82 arrival: **74/74 PASS**, full stdout sha
  `947ad72643d2a450fbea099a2b4392bc8eec51005e1e03568bbdce6879ddc1d0`
  byte-identical — and equal to the sha the r81 receipts cite, so the r81
  tracked stdout is unchanged at r82 HEAD (author had not landed).
- All mutant/harness runs stderr byte-empty; every probe exit 0 unless the
  cell under test says otherwise.

## (6) Deltas vs prior rounds

1. **New bare event class (scene swap)**: `C.window.scene =` *change* fires
   the frame_change pair and evaluates the re-activated scene's graph — a
   boundary class outside the enumerated five; the closed-set falsifier fires
   (`violations=1`). Prior rounds probed `scenes.new` (inert), never a swap.
2. **Witness-degeneracy class (scene removal)**: `evaluated_get` falls back
   to the original ID once the owning scene is gone (`ev is ob`, base mesh) —
   the standard held witness misclassifies this as a flush; folding requires
   the identity check.
3. **Nested-depsgraph identity pinned**: per-view-layer graphs are distinct
   objects; VL1 identity survives a swap round-trip; a bare VL swap is inert
   (edge=1).
4. **Cross-graph `evaluated_get` is a silent RNA fallback** (scene B's graph
   reading scene A's object returned the pending RNA value).
5. **Factory reset**: handle + ID reads raise `ReferenceError`; the watched
   handler lists are cleared by the reset (delta-0 artifact).
6. **Forged `violations=0` = complete silent pass end-to-end** with a real
   untracked violation (first verdict-gate demonstration; parser-level cells
   were r81-scribe H3a/H3c).
7. **Detach under battery timeout measured**: return at ~60 s, no hang,
   launch-gate FAIL with a clean case table; late rows after `PROBE_DONE`
   accepted silently.
8. **Env gate mechanism**: `ignore_environment` + `PYTHONPATH` gating +
   collapse-through-battery (r81 measured the collapse cells; the gate flag
   and the PYTHONPATH cell are new).

## (7) Remaining unknowns

- "Nested depsgraph" is operationalized here as per-view-layer graphs; nested
  node-group/sub-graph constructs are unprobed.
- Scene-swap fc-pair attribution is per *change* (2 changes → 2 pairs;
  self-assignment → 0); whether the pair count varies with frame deltas or
  animated scenes is unmeasured (both scenes at frame 1 here).
- Whether scene swap fires dup on other scene shapes (empty scene B here) or
  other builds — the pin is per-runtime, as declared.
- fd2 (stderr) inheritance under detach unprobed (the battery parses stdout).
- The mask requires an untracked violating class; a fold that pins every bare
  row per-row would make the aggregate forgery less complete, but the
  aggregate detector remains overwritable by the same mechanism.
- The scene-remove orphan cleanup was by pid (736950); no system-level
  guarantee recorded.
- No non-bpy runtime env cell; "per runtime" rests on bpy + host CPython.

## Scope guards carried

Reorder topology variable = the fd1-OWNER's buffering mode, never the
descendant's (env-collapse cell: parent's write-through flips the splice
casualty). bpy ignores `PYTHONUNBUFFERED` unless `--python-use-system-env`
(mechanism now pinned: `ignore_environment=1`). `io.DEFAULT_BUFFER_SIZE`
131072 is THIS build's constant. Wire order + write-order both needed for a
fabrication witness (forged-row matrix is exactly that pair). Parser survival
≠ parser safety: the forged/misplaced/truncated matrix documents measured
behavior, never a safety claim. Evalcat closure is bounded to the probed
catalogue — the boundary adds two non-inert classes at the scene axis.
Timing leaves are jitter unless semantically pinned (detach walls are pinned
by mechanism, not offsets). fifo-open SIGTERM-immunity not exercised; every
bounded probe used `timeout -s KILL`.

Receipts and pinned artifact shas: `corpus/live/r82-boundary/manifest.sha256`
(tracked fixtures, mutants, harness, streams, every receipt dir + verdict).
Report only; I do not judge, admit, edit, integrate, or ship. Stopping here.
