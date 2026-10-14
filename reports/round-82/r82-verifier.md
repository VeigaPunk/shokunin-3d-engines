# game-dev-3d round 82 — verifier (seat: verifier; host: devin)

Post-landing verification of the committed tree. The author commit landed
inside my poll window (~22 min of `git log` polling from a clean `31cf56a`
tree): work commit **0619300** `r82: evalcat residual fold (update_tag +
custom-setter + 4 witnesses, catalogue 14->20) + parser-hazard pinned cells`
at 12:38:26 local, then **7b4615b** `r82 refinement: pre-redirect fflush
preserves the startup banner` (12:48:49) and **e79e004** `r82 simplifier-fold:
dead held param off _ec_edge1 (16 call sites), dead dg0 binding, stale
line-refs fixed` (12:49:30) — all by `ci <ci@local>`. Verified at final HEAD
**e79e004**; committed fixture blobs hash-identical to the working tree
(`bpy_sync_probe.py` sha256 `07ec83e3…`, `bpy_battery.py` `045102a8…`;
`git status` clean on `corpus/fixtures/`). Pre-landing baseline snapshotted
at 31cf56a before any r82 diff existed. Scratch confined to
`corpus/live/r82-verifier/`; this report is the only other write. No git
mutations, no subagents (leaf).

Toolchain: Blender **5.2.1 LTS** (`/usr/bin/blender`, banner hash
`9e2066aef7ef`), Godot `4.7.2.stable.arch_linux.ed1daf0bf`, python3 3.14.7
— same builds as r81.

## Item 1 — battery replay on the committed tree → **AGREE (PASS)**

`python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender --runs
corpus/live/r82-verifier/runs` at HEAD e79e004, exit **0**; receipts
`runs/bpy-20261014T155236154234Z/` + `bpy-20261014T155249323031Z/` +
`bpy-20261014T155412203833Z/`:

    totals: cases=83 pass=83 fail=0 (signal_fail=0 quirk_drift=0)
            launch_ok=True done_marker=True fatals=0 exit=0
    order_checks : 4/4 — reorder_child_before_pre_spawn,
                   reorder_child_before_post_spawn, reorder_no_extra_cells,
                   reorder_splice_dropped
    hazard_checks: 7/7 — forge_marker_present, forge_closed_cell_genuine,
                   forge_last_wins_cell, dup_flush_order_decides,
                   binjunk_decode_raises, detach_eof_hold, eof_control_fast

`n_arm_lines=131` (122 prior cells + 6 ext2 EDGE + 2 ext2 DEG + 1 hazard
PARSE), 134 physical `^ARM ` lines, probe ~4.5 s, `probe.stderr.txt`
byte-empty.

## Item 2 — determinism ×2 (measured ×3) → **AGREE, with a resolved
## in-flight finding**

All three committed-tree runs produced **byte-identical stdout** sha256
`6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
matching the e79e004 commit subject's claimed sha. stderr 0 B each.

In-flight finding (resolved before final HEAD, disclosed by the author in
`r82-author.md:178-181` and proven load-bearing by r82-simplifier §2-D-C/D):
on the *first* work commit `0619300` alone (pre-fflush blob `df66d17`), the
full stdout was **not** byte-stable — my own runs split `3f82eb52…` ×2 /
`6a98c570…` ×1, and the author's receipts span ≥4 distinct shas
(`f0ebda5d`, `1b0d043a`, `3f82eb52`, `6a98c570`). The jitter is confined to
non-ARM bytes: the C-level startup banner's flush timing vs the
`_ec_x2_instance_refused` fd1→devnull window (banner eaten vs landed at
byte 0; in two pre-commit drafts the timestamped `reports | ERROR` line
escaped too). **The ARM-row stream was byte-stable throughout** — sha
`7b19c058e2f7…` on all 10 r82-tree receipts (author×7, mine×3). At the
final tree the pre-redirect `fflush` lands the banner deterministically at
byte 0 (8/8 observed `6a98c570…`: author×3 + simplifier×2 + mine×3); the
residual risk is a future C-level print flushing outside the window —
measured-clean, not proven-impossible.

## Item 3 — prior ARM rows byte-identical → **AGREE**

Baseline at 31cf56a: `runs/bpy-20261014T152051839817Z/` (74/74, stdout sha
`947ad726…` — reproduces the r81 landed receipt exactly). Against
`bpy-20261014T155236154234Z` at e79e004:

- all **123** prior physical `^ARM ` lines are a **byte-identical in-order
  subsequence** of the new 134-line stream (0 missing/out-of-order); the
  prior 122 unique `(arm,point,layer)` cells parse identically.
- 11 inserted lines, exactly the declared set: forged `closed` row at
  stream offset 79 (`violations=0 forged=parent_midstream`), 8 `ext2_*`
  rows between `ext_orphan_purge` and the genuine `closed`, 2
  `hazard|dup_flush|PARSE` rows appended after the reorder block.
- non-ARM content: `REORDERGLUE::…gluevictim…`, `PROBE_DONE`, `Blender
  quit` identical; the banner moved from post-`PROBE_DONE` (baseline) to
  byte 0 (post-fix) — a documented relocation, not content loss.
- Brief-count nit: the brief says "Prior 118 ARM rows"; measured prior
  stream is 123 physical lines / 122 cells. Counting nit only — same
  off-by-N as r81's "prior 111" subject.

## Item 4 — ARM A residual fold → **AGREE**

Six bare classes folded inside `arm_evalcat` before `closed`
(`bpy_sync_probe.py:1516-1523` tuple order; forged row emitted at
`:1508-1509`, genuine `closed` at `:1529`; CASES `bpy_battery.py:257-333`),
each `invoked=none` → under the armed
closed-set falsifier. Committed-tree stdout verbatim, matching
r82-scout's pre-measured values field-for-field:

| row | edge | observed witnesses |
|---|---|---|
| `ext2_update_tag_obj` | 1 | `held=stale dpre=…=dund=0 held_loc=(0,0,0) fresh_loc=(5,0,0) get_dup=1 get_fc=0` — tag≠eval, purest discriminating witness |
| `ext2_custom_matrix_world` | 1 | `fresh_loc=(3,0,0) rna_loc=(3,0,0) get_dup=1 get_fc=0` — setter decomposes + tags internally |
| `ext2_libraries_load` | 1 | `held_names=o fresh_names=libo|o rna_lib=True` — RNA gains linked ID at w0, held dg0 blind |
| `ext2_instance_empty` | 1 | `held_inst_pre/post=0 fresh_inst=1 held_all=inst fresh_all=ic_o|inst rna_type=COLLECTION rna_coll=ic` |
| `ext2_batch_remove` | 1 | `ret_type=NoneType held_names=ctl|o|o2 fresh_names=ctl rna_objs=ctl` — live-IDs-only call (critic's SIGSEGV guard honored: no stale reference crosses `_ec_reset`) |
| `ext2_evalget_unlinked` | 1 | `og_same_id=True og_ev_loc=(4,0,0) og_rna_loc=(4,0,0) ctl_same_id=False ctl_ev_loc=(0,0,0)` — out-of-graph evaluated_get returns the ORIGINAL with the un-evaluated RNA value |

DEG side cells: `ext2_instance_refused` (`step1=ERR:TypeError…`,
`type_after=NONE coll_after=none`) and `ext2_evalget_freed`
(`res=ERR:ReferenceError`) — documentary, correctly outside the EDGE
catalogue. `evalcat|closed|EDGE violations=0` holds: catalogue 14→20 bare
rows.

## Item 5 — ARM B parser-hazard contract pins → **AGREE**

All measured resolutions reproduced through the tracked path
(`parse_arms`/`run_process`, bpy_battery.py `:358-381` at HEAD):

- **Forged `violations=0` (H1)**: the probe's forged row lands at raw
  offset 79, the genuine row (carrying `events=…`, no `forged` key) lands
  last → parsed cell is genuine. The battery splits the invariant:
  `forge_marker_present` (raw-byte visibility) +
  `forge_closed_cell_genuine` (`violations=0 ∧ events∈ ∧ forged∉`) —
  independent of the marker, folding the r82-critic correction. Synthetic
  `forge_last`/`forge_first` through tracked `parse_arms` pin **physical
  last-wins both directions** (`forge_last.violations="0"` = the
  demonstrated mask; `forge_first.violations="3"` survives). The brief's
  "must NOT mask" is honestly pinned as measured resolution: forgery
  landing last DOES mask; the parser detects nothing.
- **dup_flush**: live two-row arm (`arm_hazards`, last in the runner) —
  `src=row2_forged v=forged` wins the cell; synthetic A+B/B+A both
  directions pinned (`dup_ab=forged`, `dup_ba=first`).
- **binjunk**: `run_process` on non-UTF-8 fd1 raises `UnicodeDecodeError`
  unhandled (battery catches only TimeoutExpired/OSError) — pinned as the
  failure mode, not a fix.
- **detach EOF-hold**: `(exec sleep 8) & exit 0` under `timeout=3` →
  `error="TIMEOUT after 3 seconds"`, `rc=None`, parent bytes
  (`EOF_PARENT_DONE`) captured, wall 3.004 s; control without the holder
  returns `rc=0` immediately. The 8 s holder self-terminates — bounded.
  Wording throughout: "the demonstrated hazard resolves as X" — never
  "the parser is safe".

## Item 6 — falsifier liveness (independent mutant at e79e004) → **AGREE**

`corpus/live/r82-verifier/probe_mutant_liveness.py` = committed probe +
one line `C.view_layer.update()` inside `_ec_x2_update_tag`'s window.
`timeout -s KILL 90 /usr/bin/blender -b -P <mutant>` → exit 0, stderr 0 B:

    ext2_update_tag_obj … held=flushed dup_fired=True edge=FALSIFIED
    closed … violations=1   (the forged violations=0 row at offset 80
                             does NOT mask it — genuine row lands last)

Tracked-parser replay (`import bpy_battery` + `parse_arms` + CASES
predicate on my mutant stream): `evalcat_closed_set` FAIL
(`violations='1'`), `evalcat_ext2_update_tag` FAIL on 6 keys,
`hazard_forge_closed_cell_genuine` → False. The armed catalogue's rows
discriminate — not constant-True decorations.

## Item 7 — Godot sibling → **AGREE**

`python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
<abs r82-verifier/runs> --probe-failing --probe-crash-exit
--probe-stream-attribution --probe-tree-timeout` → **176/176 PASS** (131
ordinary + 45 negative controls) + **4/4 probes**, `seeds_unchanged=true`;
receipt `runs/20261014T154155913808Z/verdicts.json`. Run was taken while
HEAD was `0619300`; the two later commits touch only the two bpy fixtures
(`git diff 0619300..e79e004 --name-status` = `M` ×2 on
`bpy_{sync_probe,battery}.py`), so the sibling result is head-stable.

## Item 8 — scope / head-movement audit → **AGREE**

- `git diff 31cf56a..e79e004 --name-status`: only the two bpy fixtures —
  Godot runner, seeds, three.js untouched.
- Insertion-only: `0619300` = +542/−3; the 3 deletions are mechanical
  (two tuple-continuation lines + the verdict-gate wrap). `7b4615b` is a
  10-line behavioral addition (the `fflush`) — **not** comment-only, but
  stabilizing and re-verified (Item 2). `e79e004` is dead-code removal
  (`_ec_edge1` unused `held` param ×16 call sites — the parameter truly
  gates nothing: body is `return "1" if fresh == expected else
  "unbound"`), one dead `dg0` binding, and stale comment line-refs — all
  byte-neutral (proven: identical `7b19c058` ARM / `6a98c570` stdout
  before and after).
- Working tree carries uncommitted `LOG.md`/`SCORECARD.md` edits +
  untracked `reports/round-82/` (report-last fold in flight) — outside
  this verdict; any later commit there is report-only by construction
  (fixture blobs unchanged).

## Defects / nits

- **None blocking.** Brief-count nit "prior 118 ARM rows" vs measured
  123/122 (all byte-identical).
- `hazard_forge_closed_cell_genuine` cannot detect a byte-perfect forged
  copy of the genuine key set landing last (undetectable from the parsed
  cell by construction) — disclosed in-fixture and in `r82-author.md:167-171`;
  the synthetic forge cells document the mask direction honestly.
- `ext2_batch_remove`/`ext_obj_remove` held-name witnesses ride freed-ID
  enumeration (build-fragile, flagged in-report); batch_remove is
  live-IDs-only per the critic's SIGSEGV boundary.
- `ext2_libraries_load` leaves ~140 KB per run under `tempfile.mkdtemp()`
  — bounded litter, disclosed.
- `fd1_fifo=True` pin holds under the battery pipe only (my direct `>`
  redirect reads False — same documented dependency as r81).

## Verdict

**8/8 AGREE** — r82 verified at **e79e004** (work commit `0619300` +
banner-stability refinement `7b4615b` + byte-neutral simplifier fold):
83/83 pinned cases with 4/4 order-checks and 7/7 hazard-checks, stdout
byte-identical ×3 (`6a98c570…`), all 123 prior ARM lines byte-identical
as an ordered subsequence, falsifier proven live by my own smuggled-event
mutant (FALSIFIED + violations=1 unmasked), Godot sibling 176/176 +
4/4 probes with seeds unchanged. The six residual classes are measured
inert under the armed closed-set falsifier (violations=0), and the four
parser hazards are pinned as honest contract cells — forged-last masks,
forge-first/midstream is absorbed, binjunk crashes the capture,
detach-EOF resolves via the timeout branch. The one in-flight defect I
found (banner jitter on `0619300`) was fixed and disclosed before final
HEAD; residual risk on future C-level prints noted, not claimed closed.
