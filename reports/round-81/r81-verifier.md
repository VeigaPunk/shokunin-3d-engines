# game-dev-3d round 81 — verifier (seat: verifier; host: devin)

Post-landing verification of the committed tree. The author commit DID land
inside my poll window (~35 min of `git log` polling while seats worked):
work commit **65b2f26** `r81: bpy reorder fabrication (X1 second Python
runtime) + 6 evalcat extension rows` at 12:03 local, then simplifier-fold
**fd75567** `dead t0 store + unreachable _ec_edge1 branches + und
false-positive gate removed` at 12:05 — both by `ci <ci@local>`. Verified at
HEAD **fd75567**; committed fixture blobs hash-identical to the working
tree (`bpy_sync_probe.py` sha256 `58ffb9f2…`, `bpy_battery.py` `111568ee…`;
`git diff` on fixtures empty). Pre-landing baseline snapshotted at ae89c13
before any r81 diff existed. Scratch confined to `corpus/live/r81-verifier/`;
this report is the only other write. No git mutations, no subagents (leaf).

Toolchain: Blender **5.2.1 LTS** (`/usr/bin/blender`, hash 9e2066aef7ef) —
same build as r79/r80. python3 3.14.7 on PATH.

## Item 1 — battery replay on the committed tree → **AGREE (PASS)**

`python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r81-verifier/runs`
at HEAD fd75567, exit **0**; receipt
`corpus/live/r81-verifier/runs/bpy-20261014T150635802704Z/verdicts.json`:

    totals: cases=74 pass=74 fail=0 (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0 exit=0
    order_checks: 4/4 True — reorder_child_before_pre_spawn, reorder_child_before_post_spawn,
                  reorder_no_extra_cells, reorder_splice_dropped

`n_arm_lines=122` (112 prior + 6 ext EDGE + 4 reorder cells), probe 4.34 s,
`probe.stderr.txt` byte-empty, `blender_version="Blender 5.2.1 LTS"`.

## Item 2 — reorder topology (X1) measured in MY raw stdout → **AGREE**

`probe.stdout.txt` lines 119–124 of the same run (verbatim):

    119 ARM reorder | child_marker | FD1 | who=child
    120 ARM reorder | dup | FD1 | src=child_inj
    121 REORDERGLUE::ARM reorder | gluevictim | FD1 | who=parent note=first-buffered-after-spawn
    122 ARM reorder | pre_spawn | FD1 | who=parent
    123 ARM reorder | dup | FD1 | src=parent
    124 ARM reorder | post_spawn | FD1 | who=parent child_rc=0 line_buf=False write_through=False fd1_fifo=True

- **Prefix reorder is real**: the `/bin/sh` descendant's bytes (119–120)
  physically precede the parent's `pre_spawn` row (122) that was *emitted*
  before the spawn — the discriminating topology. `post_spawn` reports
  `line_buf=False write_through=False fd1_fifo=True` (block-buffered pipe
  under `capture_output`).
- **Splice boundary**: the child's unterminated `REORDERGLUE::` glues onto
  the first buffered parent row (121) → `^ARM ` fails → the parser drops
  the merged line; `("reorder","gluevictim","FD1")` is absent from parsed
  cells while its bytes are present — **dropped, not misattributed**
  (`bpy_battery.py:353-367`).
- **Last-wins**: child's forged `dup src=child_inj` (120) lands first,
  parent's `dup src=parent` (123) lands last → cell resolves to `parent`,
  pinned by `reorder_dup_lastwins` (`bpy_battery.py:251`).
- `child_marker` parses to its own cell attributed to child bytes — the
  injection surface is documented, not hidden.

## Item 3 — the topology pins discriminate (collapse mutant) → **AGREE**

`blender -b -P corpus/live/r81-author/probe_collapse_mutant.py` (author's
mutant: `sys.stdout.reconfigure(line_buffering=True)` at
`probe_collapse_mutant.py:1228`), captured via `>` redirect; exit 0,
stderr empty; then `python3 corpus/live/r81-author/liveness_check.py
corpus/live/r81-verifier/collapse_mutant.stdout.txt` → **exit 1**,
verdict FAIL (5 failures):

    FAIL ORDER reorder_child_before_pre_spawn      (parent rows now precede child bytes)
    FAIL ORDER reorder_splice_dropped              (gluevictim parses cleanly — splice moved to `dup`)
    FAIL CASE  dup:        src='child_inj' != 'parent'   — real misattribution under collapse
    FAIL CASE  post_spawn: line_buf='True' / fd1_fifo='False' != pinned

The pins are not constant-True decorations: collapsing the buffer window
flips the order checks and lets the forged child row **win** the dup cell
(the exact hazard the arm documents). Note: my direct `>` redirect makes
fd1 a regular file → `fd1_fifo=False` (author's `probe.direct.stdout.txt`
agrees); the pinned `True` holds for the battery's pipe path. Same check
on the real run passes 0-failure (receipt above).

## Item 4 — evalcat extension rows (arm 2) → **AGREE**

All six critic-list classes landed (`bpy_sync_probe.py:1029-1175`,
`:1188-1189`; CASES `bpy_battery.py:207-241`), every one bare
(`invoked=none`) → under the `closed` falsifier (now 14 bare rows).
Committed-tree stdout verbatim:

| row | pinned edge | observed (verbatim) |
|---|---|---|
| `ext_frame_current` | `1` | `held=stale dpost=0 dfc=0 edge=1 frame=2 held_loc=(0,0,0) fresh_loc=(0,4,0) get_dup=1 get_fc=0` — lazy tag; binds at tagged get, fc never fires (closes r80-boundary unknown (a)) |
| `ext_hier_link` | `1` | `held_names=o fresh_names=n|o rna_child=True` — link RNA-visible at w0, held keeps pre-link set |
| `ext_data_swap` | `1` | `held_mesh=verts3:xmax1.000 fresh_mesh=verts16:xmax1.000 rna_verts=16` — held evaluated mesh keeps old data |
| `ext_parent_write` | `1` | `held_mw=(0,0,0) fresh_mw=(3,0,0) rna_parent=tgt rna_mw_w0=(0,0,0)` — RNA mw sampled pre-eval is itself stale (tier-1, scout's trap) |
| `ext_obj_remove` | `1` | `held_names=keep|o fresh_names=keep rna_objs=keep` — held dg0 still enumerates the freed ID (author-flagged fragile) |
| `ext_orphan_purge` | `absent` | `purged=1 rna_meshes_before=2 rna_meshes_after=1 held_names=o fresh_names=o` — data-layer axis, dg witness non-discriminating; `edge=absent` label extended per scout's label gap |

`evalcat|closed|EDGE violations=0` still holds — the extension rows run
inside `arm_evalcat` before `closed`, so a bare flush on any of them
auto-FALSIFIES the row and increments the counter.

## Item 5 — byte-stability of the prior stream → **AGREE**

Baseline snapshot at ae89c13 (pre-r81):
`corpus/live/r81-verifier/runs/bpy-20261014T143719540894Z/` (64/64,
ARM-stream sha `097c8a19…`, byte-identical to r81-simplifier's baseline).
At fd75567, all **112** prior `^ARM ` lines are **byte-identical**
(`diff` of the prior-only streams: empty; "PRIOR_STREAM_BYTE_IDENTICAL").
The commit message's "prior 111 ARM lines" undercounts by one — measured
112 lines, all stable (nit on the message, not the claim).
Determinism: second committed-tree run
`bpy-20261014T150706154984Z` produced **byte-identical full stdout** —
sha256 `947ad72643d2a450fbea099a2b4392bc8eec51005e1e03568bbdce6879ddc1d0`,
matching the fd75567 subject's claimed `sha 947ad726 unchanged`.

## Item 6 — scope hygiene → **AGREE**

`git diff ae89c13..HEAD --name-status`: only `bpy_sync_probe.py` and
`bpy_battery.py` touched across both commits — Godot battery, runner, and
seeds untouched. The simplifier-fold (fd75567) is faithfully minimal:
drops `d["und"]` from the `_ec_edge` falsifier predicate (r80 critic nit —
undo_post is not an eval event), the unreachable `held!=stale` branches
of `_ec_edge1` (`:597-601`), and the dead `t0=` store in `_ec_walltime`
(`:1004`). None of these alter emitted bytes — confirmed by the
byte-identical stdout above.

## Defects / nits

- **None blocking.** Commit subject "prior 111 ARM lines" vs measured 112
  (all byte-identical) — counting nit only.
- `ext_obj_remove`'s held-read of a freed ID is author-flagged fragile;
  pinned `held_names=keep|o` is a this-build receipt (disclosed in-fixture,
  `bpy_sync_probe.py:1131-1133`).
- `fd1_fifo`/`line_buf`/`write_through` pins are capture-path-dependent by
  design (True under the battery pipe); direct file redirect flips
  `fd1_fifo` — the pins document the battery's own runtime, as declared.
- Uncommitted `LOG.md`/`SCORECARD.md` modifications present in the working
  tree (adjacent seat's report-last work in flight); outside this verdict.

## Remaining risks

- The reorder arm fabricates collapse via `/bin/sh` + inherited fd1 on
  this POSIX host; a runtime without block-buffered fd1 fails
  `reorder_child_before_pre_spawn` by design (claim pinned per runtime).
- Parse-survival pins cover this arm's fabricated stream; other corruption
  classes (mid-line tears inside a buffered flush, interleaved atomic
  writes) are demonstrated in r81-critic scratch but not pinned here.
- evalcat remains *bounded* closure: 14 bare rows tracked; the ~100-class
  swept surface stays scratch evidence, per r80 adjudicator wording.

## Verdict

**6/6 AGREE** — r81 verified at fd75567 (work commit 65b2f26 +
simplifier-fold): 74/74 pinned cases green with 4/4 raw-stdout order
checks; the fd1-inheritance prefix reorder is measured live (child bytes
before parent's pre-spawn row), the splice is dropped not misattributed,
last-wins attribution pinned, and the collapse mutant flips 5 surfaces —
the topology is falsifiable per runtime as claimed. The six evalcat
extension rows are the critic's list verbatim, all under the armed
closed-set falsifier (`violations=0`), and the prior 112-line ARM stream
is byte-identical with two byte-identical committed-tree runs
(`947ad726…`). Godot sibling untouched.
