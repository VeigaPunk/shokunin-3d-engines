# r92 simplifier — YAGNI/dead-code review of the landed r92 diff

Seat: GAME-DEV-3D r92 SIMPLIFIER, read-only. Scope: the landed work commit
`dd32c3c` only — `corpus/fixtures/r92_child.gd` (+1065),
`r92_remote.gd` (+183), `r92_animphys.gd` (+312), `r92_timing.gd` (+173),
`run_battery.py` (+57/0) — plus its receipts. No fixture edits, no commits; the
only repo write is this report. `git status --porcelain` clean before and after
(HEAD `b6169f6`, which adds only the author report). One throwaway Godot probe
was run under `/tmp/r92probe/`, outside the repo.

**Evidence base (all read-only, all recomputed here — nothing taken on the
author's word):**

- `corpus/live/r92-author/runs/20261015T175829468804Z/verdicts.json` — run 2,
  258/258 PASS, `seeds_unchanged=true`.
- `corpus/live/r92-author/runs/20261015T175116507786Z/verdicts.json` — run 1,
  257/258; the single failure is the pre-existing `bpy_rbw3d_render` marker
  (Blender distribution cell, unrelated to r92). **All 23 r92 rows are
  byte-identical stdout+exit run1↔run2** (recomputed, not quoted).
- `corpus/live/r92-author/battery_run{1,2}.log`, `dev/marks/*.txt` (23) and
  `dev/marks2/*.txt` (23).
- The pinned markers in `corpus/fixtures/run_battery.py` (exact-line contract,
  `classify()` requires the marker to be an exact stdout line).

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer GDScript
files, and no `lsp`/`references` tool exists in this toolset. Every call-site
claim below is therefore the **literal grep fallback and is not presented as
semantic proof**. Two facts narrow the gap for this specific file: (a)
`r92_child.gd` is only ever instantiated as a SceneTree main-loop script by the
three r92 parents (grep: only those three seeds name it); (b) the script has no
reflective call surface — `call(`, `callv`, `Callable`, `has_method`, string
`connect`/`emit_signal` are all zero hits — so a method name cannot be invoked
dynamically.

## 1. Arm/leg firing audit — no CASES row has a dead arm

Parsed each parent's `ARM_CASES` and the run-2 digest cells per row:

| row | arm | legs in ARM_CASES | cells observed (backend×leg) | fired |
|---|---|---|---|---|
| r92_remote_boundary | boundary | sync, lag | 3×2 | all |
| r92_remote_phase | phase | phase | 3×1 | all |
| r92_remote_flags | flags | flags | 3×1 | all |
| r92_remote_stale | stale | stale | 3×1 | all |
| r92_remote_path | path | path | 3×1 | all |
| r92_remote_chainlag | chainlag | chainlag | 3×1 | all |
| r92_remote_srv | srv | srv | 3×1 | all |
| r92_remote_drive | drive | driver, parent, local | 3×3 | all |
| r92_animphys_rbpos | rbpos | rbpos | 3×1 | all |
| r92_animphys_rbfrozen | rbfrozen | rbfrozen | 3×1 | all |
| r92_animphys_animrb | animrb | animrb | 3×1 | all |
| r92_animphys_animatable | animatable | animatable | 3×1 | all |
| r92_animphys_reset | reset | reset | 3×1 | all |
| r92_animphys_manual | manual | manual | 3×1 | all |
| r92_animphys_destroy | destroy | empty_track, badkey | 3×2 | all |
| r92_animphys_iforder | iforder | iforder | 3×1 | all |
| r92_animphys_idlemode | idlemode (special) | idlemode | 3×8 reps, ok=8/8, xband=0.2-0.5 | all |
| r92_animphys_badkey_insert | badkey_insert (special) | badkey_reject | exit 2, exact `NEGATIVE REJECTED: … ins=-1,-1 keys=0 destroyed=false on=gp,jolt,dummy` | yes |
| r92_timing_tps | tps | tm_tps30, tm_tps120 | 3×2 | all |
| r92_timing_tscale | tscale | tm_ts05, tm_ts2big, tm_tsbig | 3×3 | all |
| r92_timing_edge | edge | tm_ts0, tm_tsneg | 3×2 | all |
| r92_timing_refuse | refuse | tm_tps0, tm_tpsneg | 3×2 | all |
| r92_timing_steps | steps | tm_maxsteps, tm_interpf, tm_jitfix0 | 3×3 | all |

Every parent arm is invoked by exactly one CASES row and every leg emitted its
cell on all three backends; the child's `match` has no arm that no parent can
reach (the 22 case names + the `tm_*` wildcard are all in some `ARM_CASES`
list). No duplicate case name and no duplicate `(script, flags)` pair among the
258 CASES rows. The `run_battery.py` hunk is insertion-only (57 added, 0
deleted; `git show dd32c3c --numstat`).

**Conclusion: no CASES row is backed by dead code, and no arm/leg in the landed
diff is unreachable.**

## 2. SP list — meets the bar

### SP-1 · Vestigial F-capture path in `r92_child.gd` (13 lines)

**Lines:** `27` (`var cap_f := false`), `28` (`var f_rows: Array = []`),
`84-91` (`Watcher._process` capture branch), `734` (`cap_f = true`),
`736-737` (`for fr in f_rows: emit("F_post", fr)`). **Retain `735`
(`await process_frame`) — see below.**

**Static proof:** `cap_f` is written once (734) and read only at 85-86;
`f_rows` is appended only at 87 and read only at 736; the `_process` override
exists solely for this capture. No other reader of either name in the file.

**Receipt proof:** the string `F_post` occurs **0 times** in (a) the full
258-row stdout of run 2, (b) the full 258-row stdout of run 1, (c) both
`battery_run*.log`, (d) all 46 dev marks; none of the 23 pinned markers contains
it. The child's own contract (lines 11-13) already declares F-row multiplicity
"never emitted".

**Mechanism (measured, `/tmp/r92probe`, Godot 4.7.2):** `process_frame` resumes
the SceneTree coroutine **before** node `_process` callbacks in the same frame —
probe log `["arm f=1", "W._process f=1", "resume1 f=2", "W._process f=2", …]`.
So at line 736 the loop always runs before the capture can happen; the single
row captured one frame later is never read (and the capture itself resets
`cap_f`). The machinery is a leftover of the scout probe's F rows
(`corpus/live/r92-scout/probes/animphys.gd:54-61`).

**Retained contract / why 735 stays:** the pinned `post` row reads
`pos=(0.4000,…)` / `lv=(0,-1.4602,0)` while the last E sample (pf=9) is
`0.3500` / `-1.2991` — exactly one more tick, and the idle-frame await is the
only wait between them. Removing 735 would change the pinned marker: a
behaviour change, not a simplification. Out of scope.

**Expected receipt delta:** none (with 735 kept).
**Check:** re-run `r92_animphys_rbpos`, `_rbfrozen` (the only `cap_f` setters)
plus `_animrb`/`_destroy` (same `Watcher` class); full battery preferred.
**Tradeoff:** none — the deleted code has no reader by construction.

### SP-2 · Dead helper `f4()` (2 lines)

**Lines:** `31-32`.
**Static proof:** the only occurrence of `f4` in the file is its definition;
no reflective call surface exists (see LSP note), so it cannot be invoked.
**Receipt proof:** a pure formatter with no side effects cannot originate any
row; all float formatting in the 23 markers is inline `%.4f`.
**Expected delta:** none. **Check:** any r92 row (full battery preferred).

### SP-3 · Dead `RB` subclass + write-only `ball.probe` (5 lines)

**Lines:** `25` (`var ball: RB`), `686` (`ball = RB.new()`), `688`
(`ball.probe = self`), `706-707` (`class RB extends RigidBody3D: var probe`).
**Static proof:** `RB` declares exactly one member, `probe`; `ball.probe` is
written at 688 and read nowhere; `RB` defines no callback/override; `ball` is
only ever used through `RigidBody3D`/`Node3D` members (`position`,
`global_position`, `linear_velocity`, `freeze`, `can_sleep`, `name`,
`add_child`, `get_rid()`).
**Fix:** `var ball: RigidBody3D`; `RigidBody3D.new()`; delete the class and the
`ball.probe` assignment.
**Expected delta:** none. **Check:** the 11 `r92_animphys_*` rows.

### SP-4 · Dead `PhaseReader.n_e` counter (4 lines)

**Lines:** `118` (declaration), `123` (increment), `124` (stored as
`e_rows` element 0), `285` and `321` (resets).
**Static proof:** `e_rows` elements are only ever indexed `[1]` (pf) and `[2]`
(x) — `e[0]` is never read anywhere — and `n_e` itself has no other reader.
Contrast `f_rows2[0]`, which **is** read at 336, so the reader's `n_f` stays.
**Fix:** drop the counter, the element and both resets.
**Expected delta:** none. **Check:** `r92_remote_phase`.

### SP-5 · Inert watcher in `c_iforder` + write-only `watcher` field (low weight)

**Lines:** `981` (`anim_watch()` inside `c_iforder`), `618` (`var watcher`),
`711` (`watcher = Watcher.new()`).
**Static proof:** `live_e` is set true only at 727/886/909
(rbpos/animrb/empty_track); `c_iforder` never sets it, so `on_e` (626) can
never emit there, and the only other `Watcher` branch is SP-1's dead capture.
The `watcher` member is assigned at 711 and read nowhere (the tree owns the
node, so the field is redundant).
**Receipt proof:** `c_iforder`'s 12 E rows (4×3) carry no `lv=` field — while
every `on_e` row always does (compare `rbpos` E rows) — and the pinned iforder
cells contain no `lv=` row and no `F_post`.
**Expected delta:** none. **Check:** `r92_animphys_iforder`.
**Tradeoff:** every other animation cell instantiates a watcher; a reviewer may
prefer tree-shape parity. The pinned contract does not depend on it, so this is
listed as a candidate, not a strong recommendation.

## 3. Candidates found, below the bar (recorded, not deleted)

**C-1 · Triplicated parent machinery (~97 lines × 2 redundant).**
`func _cell` → EOF is byte-identical across the three parents — `r92_remote.gd
87-183`, `r92_animphys.gd 216-312`, `r92_timing.gd 77-173`
(`sha256 a2d7db40…` for all three; the `_run_arm` tails 80-84 / 95-99 / 70-74
are identical too). That covers `_cell`, `_project_body`, `_child_prepare`,
`_scan`, `_spawn_batch` — ≈200 of the 1790 added lines are duplicate weight.
**Why below bar:** no existing seed *provides* this machinery.
`phys3d_events.gd:530+` carries a richer variant of the same convention
(arm-prefixed errors, `allow_lines`, `batch_timeout`) and `phys3d_joints.gd`
its own; the corpus's preload precedent (`runner3d.gd`, `input_mover3d.gd`)
covers scenario drivers, not child spawning. Extracting a shared module or base
class would create a second convention for the spawn machinery in a corpus
whose standing rule is per-fixture self-containment — a corpus-wide decision,
not a round-diff deletion.

**C-2 · `c_animatable` inline animation build (773-786) duplicates
`mk_anim`+`put`+`lib` (643-665).** The helpers are bound to the global `player`
while this case builds a local one; assigning `player = p` and calling
`mk_anim(NodePath("Ball"), Vector3(0,2,0), Vector3(6,2,0))` would save ~9 lines
and remove the second player idiom. Rewrites a live pinned cell for a modest
gain and needs its own re-run — below bar for a read-only round.

**C-3 · `srv` (55-60) vs `srv_o` (63-68).** Identical except the fallback
literal, and **both spellings are pinned in different cells** (`rbpos…@dummy`
pins `srv=nil`; `srv@dummy` pins `srv_o=null`). Unifying them changes a pinned
marker → not a simplification under the exact-marker contract.

**C-4 · `c_badkey` (926-932) vs `c_badkey_reject` (957-963)** duplicate the
wrong-typed insert setup; a shared builder would make "the SAME inserts"
structural, but it touches the negative control's arrangement for ~5 lines.
Below bar.

## 4. Checked and deliberately retained (not dead)

- `r92_child.gd:735` — the idle-frame await (SP-1 above).
- `c_badkey_reject`'s `if not refused:` fallback (965-967): the control's
  falsification path; without it the negative control would pass vacuously if
  the engine ever honoured the wrong-typed inserts.
- Parent fail-closed guards never exercised by any r92 receipt, all deliberate:
  `_child_prepare` dirname/char whitelist (the r89 sentinel-S3 remediation,
  carried by corpus convention), `_spawn_batch` deadline/kill, `_cell` err
  branch, `_scan` `e/w/s` counting (the `e=2` pin **is** exercised),
  `_env_idlen`/`_xband` out-of-band buckets, `_run_negative` FAIL branch.
- `Watcher._physics_process`/`on_e` — receipt-live (18-24 E rows per animation
  row).
- All 23 pinned markers — the retained contract.

## 5. Weight summary, tradeoff, stop condition

Bar-meeting deletions: **~24 lines** (SP-1 13, SP-2 2, SP-3 5, SP-4 4, SP-5 2)
out of 1790 added; every one has zero expected marker delta. The remaining
~1765 lines are new measurement surface whose legs all fired. The next deletion
candidate (C-1, ~200 lines) requires a corpus-wide convention decision, and
C-2/C-3/C-4 each trade a pinned contract or a control's independence for ≤9
lines — **stop here.**

Verification note: the deltas above are *predicted* "no marker change"; I did
not run the battery, because a run writes receipts under `corpus/live` and this
seat is read-only. The check to run is the ordinary battery (or `--only` the
listed rows) with a byte-diff of the 23 markers against run 2 — run1↔run2
byte-identity of those rows is already recomputed in the evidence header, so a
post-deletion run has a frozen comparison target. Nothing in the diff is marked historical, and
no provenance-bearing line is proposed for deletion.
