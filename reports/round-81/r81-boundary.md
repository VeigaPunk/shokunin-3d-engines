# game-dev-3d round 81 — boundary (seat: boundary, host: devin)

Claim under test (r81 lane move, verbatim): **"reorder topology falsifiable per
runtime; catalogue extension byte-stable."** Two arms — (1) X1 reorder
fabrication on `blender -b -P` (fd1-inheriting descendant × buffered parent →
prefix reordering of ARM-stream bytes; parse-survival cells for the battery's
own ARM parser), (2) ~6 representative bare-class rows folded into the tracked
evalcat catalogue (r80-critic fold guidance). This seat measures **edge cells
the author skipped**; it does not fold, judge, or edit tracked fixtures.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `ae89c13` (r80
report-last), working tree: r80 baseline/reviewer/verifier reports untracked,
otherwise clean. Tracked fixtures as read: `corpus/fixtures/bpy_sync_probe.py`
sha `bfa80ed4…` (1041 lines), `corpus/fixtures/bpy_battery.py` sha `ae3b04b1…`
(302 lines). Runtime: Blender 5.2.1 LTS headless (hash `9e2066aef7ef`),
embedded CPython 3.14.7; host python3 3.14.7. **LSP unavailability recorded:**
`mcp_list_servers` exposes only `rea` (Ghidra binary analysis) — no `lsp`
device serves this repo, so all symbol tracing below is text-level (read +
grep), never presented as semantic proof. Scratch + receipts:
`corpus/live/r81-boundary/` (ignored; `manifest.sha256` pins every artifact
cited). No writes outside scope; no git mutations.

## (0) Viability

| command | exit | wall | evidence |
|---|---|---|---|
| `python3 run_cells.py` (14 cells, blender+host) | 0 | ~14 s total | `runs/reorder/summary.txt`, per-cell stdout/stderr/meta |
| `blender -b -P reorder_probe.py` (12 blender cells) | 0 (10) / capture-fail (2) | 0.34–0.40 s; detach 6.30 s | per-cell stdout/stderr/meta |
| `python3 fill_boundary.py` | 0 | — | `runs/reorder/fill_boundary.txt` |
| `python3 corpus/fixtures/bpy_battery.py --runs …/battery-tracked-{a,b}` | 0 / 0 | 4.2 s probe | **64/64 PASS** ×2, signal_fail=0 quirk_drift=0 fatals=0 |
| `python3 extend/make_extended.py` | 0 | — | `extend/extended.diff`: **250 added, 1 removed** (insertion-only) |
| `python3 extend/run_extended.py` (4 probe runs) | 0 | 4.2–4.4 s each | `runs/extend/compare.{txt,json}` |
| `python3 extend/bpy_battery.py --runs …/battery-ext-{a,b}` | 0 / 0 | 4.35 s probe | **74/74 PASS** ×2 (64 tracked + 10 new), fatals=0 |

## (1) Arm 1 — reorder topology on `blender -b -P`: measured cells

`reorder_probe.py` emits ARM-shaped rows and spawns a descendant
(`subprocess.run([...], stdout=None)` / `os.system`) that inherits fd1. The
runner captures stdout exactly as `bpy_battery.run_process`
(`bpy_battery.py:197-206`: `capture_output=True, text=True`) and parses the
captured stream with the **tracked** parser (`bpy_battery.parse_arms`,
imported by path, not a replica).

Buffering facts (`bufdiag` row, probe-flushed): `py=3.14.7
bufsize=131072 line_buffering=False write_through=False isatty=False` — the
battery always captures through a pipe, so the tracked probe's `print()`
stream (`emit`, `bpy_sync_probe.py:56-58`, never flushes) is one userspace
block buffer.

| cell | mechanism | measured ARM-row stream order (byte offsets) | topology |
|---|---|---|---|
| `buffered` | child full ARM line, parent unflushed | `child`(0) → `bufdiag` → `head`(152) → `tail` | **prefix reorder** |
| `flush` | parent `sys.stdout.flush()` before spawn | `bufdiag` → `head`(113) → `child`(149) → `tail` | causal order (collapse) |
| `unbuffered` | `PYTHONUNBUFFERED=1` **+ `--python-use-system-env`** | `head`(181) → `child`(217) → `tail` | causal order (collapse) |
| `unbuf_plain` | `PYTHONUNBUFFERED=1`, no blender flag | `child`(0) → `bufdiag` → `head`(154) → `tail` | **reorder persists** |
| `partial` | child writes `NOISE` (no newline) while parent mid-line | first line `NOISEARM bufdiag \| partial \| T \| …`; `partial`+`tail` intact | first buffered line merged |
| `merge_first` | same, first buffered line already complete | `NOISEARM bufdiag \| merge_first \| …`; `first`/`partial2`/`tail` intact | first buffered line merged |
| `dup` | child + parent emit the **same** `(arm,point,layer)` | `child`(0) → `dup src=parent`(145) | last-wins → parent |
| `dup_flush` | same key, parent row flushed first | `dup src=parent`(117) → `child`(152) | last-wins → child |
| `bigwrite` | 140×1001 B filler, then child | child(126242) → `big_pre`(140292) → `big_post` | **hybrid**: already-flushed prefix in order, buffered suffix reordered after child |
| `shell` | descendant via `os.system("printf …")` | `shell`(0) → `head`(146) → `tail` | **prefix reorder** |
| `host_py` | bare `python3` runs the same probe | `child`(0) → `head`(152) → `tail` | **prefix reorder** (interpreter-level) |
| `detach` | session-detached child holds fd1, writes at t+6 s | `head` → `tail` → `PROBE_DONE` → Blender banner/quit → `late` | late row after stream end; EOF held 6.30 s |
| `detach_t3` | same cell, runner timeout 3 s | `bufdiag`/`head`/`tail`/`PROBE_DONE` captured, then TIMEOUT | capture-fail |
| `binjunk` | child writes `\xff\xfeJUNK\n` into fd1 | capture raises before any parse | capture-fail |

**Measured deltas vs the scout pre-measurement (`r81-scout.md` §1-2):**
`PYTHONUNBUFFERED=1` is ignored *by default*, but the collapse control does
exist: with Blender's `--python-use-system-env` the env var is honored
(`write_through=True`, causal order — `runs/reorder/unbuffered.meta.json`).
The scout's "window collapses only via explicit `flush()`" is therefore
narrower than measured. Also: the newline-less merge targets the **first
buffered byte run** (here `bufdiag`), *not* the line the parent was mid-way
through (`partial` survived intact behind the merged first line) — the
scout's `midline` cell had its pending line first in the buffer, which hid
this.

Window-boundary constants (host python3 3.14.7, `runs/reorder/fill_boundary.txt`
+ `fill_pattern.txt`): `io.DEFAULT_BUFFER_SIZE=131072`; a single write is
buffered at K=131071 and written through at K=131072 (direct-write
threshold). Under 1001-byte chunked writes the first flush carried **130130 B
(130 chunks) on the byte layer** — the capacity model — but **126126 B (126
chunks, remainder retained) on the text layer**; `bigwrite` corroborates on
blender (child at 126242 = 116 B `bufdiag` + 126×1001). The observable
spawn-time window is therefore write-size/layer dependent: **carry the
measured offset per receipt, never a hardcoded edge** (xconnector rule,
`xconnector.md:181-186`). The partial-flush/retention mechanism itself is not
isolated — see §7.

## (2) Arm 1 — parse-survival cells (tracked parser, measured streams)

Each measured stream above was fed to `bpy_battery.parse_arms`
(`bpy_battery.py:194` regex, `:211-220` keying `(arm,point,layer)`,
last-wins). Classification: `SURVIVES` = every parent row present with its
program-order-last value; `MISATTRIBUTES` = row loss or value flip;
`CONTAMINATED` = phantom row (descendant bytes parsed as a catalogue row).

| cell | parser outcome | misattribution hazard |
|---|---|---|
| `buffered` | all parent rows present; `child` row added | CONTAMINATED: stream order no longer reflects program order (child at byte 0); a *streaming* consumer attributes child bytes first |
| `flush` / `unbuffered` | parent rows present; `child` row added | CONTAMINATED; splice topology |
| `dup` (buffered) | resolves `src=parent` | **survives** — reorder places the parent's row last |
| `dup_flush` | resolves `src=child` | **MISATTRIBUTES** — descendant spoof overrides the pinned row (last-wins) |
| `partial` / `merge_first` | `bufdiag` row **missing** | **MISATTRIBUTES** — newline-less child write merges onto the first buffered line; `^ARM (\S+) \|` fails |
| `bigwrite` | all parent rows present, `child` row added | CONTAMINATED; order fabricated |
| `shell` / `host_py` | parent rows present, `child` row added | CONTAMINATED |
| `detach` | parent rows + `late` row | CONTAMINATED; `PROBE_DONE` no longer last probe line |
| `detach_t3` / `binjunk` | no verdict possible | capture-fail (below) |

Pinned reading: for **unique keys** the battery's post-exit key-indexed parser
does not misattribute a reordered stream — because reorder puts the parent's
buffered bytes *after* the descendant's, last-wins still resolves to the
parent's program-order-last row. The live hazards are (a) **row loss** when a
descendant writes without a trailing newline (merge onto the first buffered
line), (b) **spoof override** in the splice topology (`flush` / unbuffered),
where the descendant's row lands last and silently rewrites any pinned key —
including a forged `evalcat | closed | EDGE | violations=0` (the scout
demonstrated the forged-pin variant; this seat's `dup_flush` is the minimal
measured mechanism), and (c) **contamination** by phantom rows for all other
topologies. The hazard is latent in the tracked tree: `bpy_sync_probe.py`
never spawns a descendant (grep: no `subprocess`/`os.system`/`Popen` in the
fixture; only `bpy_battery.py:21,199` uses subprocess to launch blender), and
the battery's `done_marker` check is **presence-only** (`bpy_battery.py:248`)
— a late row after `PROBE_DONE` does not fail it.

## (3) Arm 1 — capture-level edge cells the author skipped

1. **Detached descendant holds fd1 → capture EOF delayed** (`detach`):
   blender itself exits in 0.36 s, but the capture wall is **6.30 s** (EOF
   arrives only when the detached child exits). With the runner timeout
   below the descendant's lifetime (`detach_t3`, 3 s) the capture fails
   **before** the battery can parse: exit=None, `TIMEOUT after 3s`, partial
   stdout, no late row. Scaled to the battery's `TIMEOUT_S=60`
   (`bpy_battery.py:28`), any descendant that outlives 60 s makes the battery
   report `TIMEOUT after 60 seconds` → verdict FAIL with all cases failing —
   while blender itself exited cleanly. The late row also lands **after**
   `PROBE_DONE` and even after Blender's own exit-time banner
   (`probe_done_last=False`), violating the "`PROBE_DONE` last marker"
   convention the r80 fold relied on.
2. **Non-UTF-8 descendant bytes → battery runner crash** (`binjunk`):
   `text=True` decodes with strict UTF-8; a descendant writing `\xff\xfe…`
   to inherited fd1 raises `UnicodeDecodeError` inside `subprocess.run`, and
   the battery's `run_process` catches only `TimeoutExpired`/`OSError`
   (`bpy_battery.py:197-208`). Measured directly against the tracked runner:
   `m.run_process([...]) → RAISED UnicodeDecodeError 'utf-8' codec can't
   decode byte 0xff in position 20`. The battery would abort with a traceback
   (no verdict), not fail a case.

## (4) Arm 2 — extension rows, isolation convention, byte-stability

Method: `extend/make_extended.py` builds an **insertion-only** copy of the
tracked probe (`extend/bpy_sync_probe.py`, +190 lines: the 6 sub-probes
inserted before the runner loop at tracked `bpy_sync_probe.py:1033`, tuple
extended at `:1035`) and of the tracked battery (`extend/bpy_battery.py`,
+59 lines: 10 CASES inserted before the fold anchor
`bpy_battery.py:189`). Diff: 250 added / 1 removed (the tuple line).

**Isolation convention (this seat's delta vs the r80/scout witnesses):** each
sub-probe mutates ONE class on a clean graph with **no co-pending witness
write**, then measures whether the mutation *itself* tagged the graph —
`tag_dup`/`tag_dpre` = handler deltas across the NEXT
`evaluated_depsgraph_get()`. The r80 rows measure mutations with a co-pending
witness write (r80-critic's own note), which cannot separate "mutation tags"
from "witness write tags". The scout's `frame_current` row uses an *animated*
witness (`sp_frame_current`, keyframes at frames 1/2) and reports `get_dup=1`
without a clean-graph control before the write; my `scene_prop` row mutates an
empty scene with no pending writes, so the dup pair at the next get is
attributable to the frame write alone. Measured (identical ×2 runs,
`runs/extend/compare.txt`):

| class (point) | immediate window | tag check | binding witness |
|---|---|---|---|
| scene-prop `scn.frame_current=` | held stale, dpre=dpost=dfcp=dfc=dund=0, `edge=1`, `rna_frame=2` (RNA write-through) | **`tag_dup=1 tag_dpre=1`, `fc_after=0`** | frame write *does* tag; fires no `frame_change_*`; next get flushes dup pair |
| hierarchy link `scn.collection.children.link(col)` | held stale (`held_names=o`), deltas 0, `edge=1`, `rna_children=1` | **`tag_dup=1 tag_dpre=1`** | `fresh=o\|o2`; forced `view_layer.update()` → `o\|o2` |
| data swap `ob.data=` | held stale `verts3:xmax1.000`, deltas 0, `edge=1`, `rna_verts=3` | not sampled | `fresh=verts3:xmax2.000` (same count, different geometry) |
| parent write `ob.parent=` | held mw `(0,0,0)`, deltas 0, `edge=1`, `rna_parent=tgt` | not sampled | `fresh=(3.000,0.000,0.000)` (DEG sample, pre-eval held) |
| `D.objects.remove(sub)` | held stale (separate **live** witness object), deltas 0, `edge=1`, `rna_n=1` | `rm_dup=0 rm_dpre=0`, then **`tag_dup=1 tag_dpre=1`** | `fresh=(4,0,0)`; `objects_remove_get`: `names=o` |
| `D.orphans_purge()` | held stale, deltas 0, `edge=1`, `purged=1`, meshes 2→1 | `rm_dup=0`, then **`tag_dup=1 tag_dpre=1`** | `fresh=(4,0,0)`; `orphans_purge_get`: meshes 2→1 |

New measured facts (fold guidance, not verdicts):

- The scene-prop frame write **tags the graph itself** (`tag_dup=1`,
  `tag_dpre=1`) while firing **no** frame-change handler (`fc_after=0`) —
  this closes the r80-boundary `frame_lazy` ambiguity (`r80-boundary.md`
  §3.2): the scout's `get_dup=1` rides an animated witness with no
  clean-graph control, mine has no co-pending write at all, so the tag is
  attributable to the frame write.
- Destructive classes (`objects.remove`, `orphans_purge`) do not evaluate
  immediately (`rm_dup=0`) but **do leave a tag** (`tag_dup=1` at the next
  get) — refining the r80-boundary wording "ID removal is not an eval event"
  to "not an *immediate* eval event; it tags and binds at the next get".
- `objects_remove` here uses a **separate live witness object** for the held
  read; the scout's freed-ID held read (`keep|o`) is a documented fragility
  this row avoids.

**Byte-stability receipts (claim 2):**

- tracked probe stdout: 112 ARM lines, sha `fb336ae5…` **byte-identical ×2**
  (`runs/extend/tracked1|2.stdout.txt`; equals the scout's baseline and the
  landed r80 receipt).
- extended probe stdout: 122 ARM lines, sha `8ce3aec2…` **byte-identical ×2**.
- insertion-only: all **112/112 tracked ARM lines present byte-identical** in
  the extended stream (tracked-ARM-block sha `bf1fc79e…` equal on both sides,
  `runs/extend/compare.json`).
- batteries: tracked **64/64 PASS ×2**; extended **74/74 PASS ×2**
  (`runs/battery-tracked-{a,b}/…`, `runs/battery-ext-{a,b}/…`), all 64
  tracked pins pass against the extended probe; `evalcat | closed | EDGE |
  violations=0` unchanged in both streams.
- structural note for the fold: the extension arms run *after* `arm_evalcat`,
  so the aggregate `closed` row cannot count violations from the extension
  rows; the extension rows still **self-enforce** (`_ec_edge` forces
  `edge=FALSIFIED` on any bare flush/handler fire) and are pinned `edge=1`.

**Fold-ready artifacts (scratch, exact):** `extend/evalcat_ext_section.py`
(sha `daa8ebeb…`; insert before `corpus/fixtures/bpy_sync_probe.py:1033`),
tuple edit at `:1035` → `… arm_evalcat,\n _ecx_scene_prop, _ecx_hier_link,
_ecx_data_swap,\n _ecx_parent_write, _ecx_objects_remove,
_ecx_orphans_purge):`; `extend/new_cases.py` (sha `eec80765…`; insert before
`corpus/fixtures/bpy_battery.py:189`); `extend/extended.diff` is the full
unified diff; `extend/bpy_sync_probe.py` (sha `945473cb…`) and
`extend/bpy_battery.py` (sha `242b2359…`) are the measured combined files.

## (5) Claim verdicts

- **"reorder topology falsifiable per runtime" — SUPPORTED on this runtime.**
  Prefix reorder measured under `blender -b -P` default buffering (child bytes
  at stream offset 0, before every parent ARM line); falsifiable controls
  measured (flush; `--python-use-system-env`+`PYTHONUNBUFFERED`), plus the
  counter-control (`PYTHONUNBUFFERED` alone does **not** collapse it) and the
  interpreter-level control (bare CPython reorders identically). Window and
  capture boundaries measured (hybrid bigwrite; detach EOF; binjunk decode).
  "Per runtime" beyond bpy/host CPython is not measured here.
- **Parse-survival pins — measured, and the naive reading is falsified.**
  The battery parser does **not** misattribute a *reordered unique-key* stream
  (last-wins resolves to the parent), but it **loses rows** on newline-less
  descendant writes and **misattributes (spoof override)** in the splice
  topology; phantom-row contamination and two capture-level failures
  (descendant-held EOF, non-UTF-8 bytes) are additional live hazard classes.
  All are latent today (tracked probe spawns no descendant).
- **"catalogue extension byte-stable" — SUPPORTED.** 74/74 ×2, 112/112 prior
  ARM lines byte-identical, insertion-only diff, deterministic stdout.

## (6) Deltas vs the scout pre-measurement

1. `PYTHONUNBUFFERED=1` **is** honored with `--python-use-system-env`
   (`unbuffered` cell); ignored only without it (`unbuf_plain`).
2. Newline-less merge destroys the **first buffered byte run**, not the
   pending mid-line write.
3. The four mutating extension classes **tag** (`tag_dup=1`) even though the
   immediate window is silent — visible only under the isolation convention.
4. `objects_remove` pinned via a **live** witness object (no freed-ID read).
5. `data_swap` witness discriminates **geometry at constant vertex count**
   (`xmax` 1.000→2.000).
6. Capture-level cells absent from the scout's set: `detach` (EOF/timeout),
   `binjunk` (strict-decode crash of `run_process`).

## (7) Remaining unknowns

- The **partial-flush/retention** at the fill boundary (text layer flushes
  126126 B of 134134 B buffered at 1001 B writes; byte layer flushes all
  130130 B) is measured but not mechanistically isolated; it only shifts the
  spawn-time window constant, not the topology. Do not pin a window size
  without its per-receipt referent.
- `stderr` (fd2) reorder/inheritance is unprobed (the battery parses stdout
  only, so impact is diagnostic-level).
- No pygame/other-runtime cell here; "per runtime" rests on bpy + host CPython.
- Extension arms appended after `arm_evalcat` are not aggregated into the
  `closed` row (per-row self-enforcement only) — an author-level choice.
- Wall-time cost: +0.13 s probe (4.22 → 4.35 s), `TIMEOUT_S=60` unaffected.

Boundary cells measured, deltas stated, fold-ready artifacts pinned. Report
only; I do not judge, admit, edit, integrate, or ship. Stopping here.
