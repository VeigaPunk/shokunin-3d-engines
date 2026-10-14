# game-dev-3d round 82 — author (seat: author, host: devin)

## Declared move (verbatim)

r82 AUTHOR (g3d) — evalcat residual fold + parser-hazard pinned cells.
ARM A — evalcat residual fold (xconnector X7, small bounded): fold the
r80-critic uncovered remainder + representative witnesses (~6 classes):
`update_tag`, one custom-setter class, `libraries.load`/`libraries.write`,
`instance_empty`/`instance_collection`, `batch_remove`, `evaluated_get` on
a stale ID. All bare rows inside arm_evalcat before `closed`, under the
closed-set falsifier (violations=0 must hold). Prediction (measured-inert
priors): all held=stale, edge=1-or-absent, handler deltas 0; any flush of
a watched handler fires the falsifier by design.
ARM B — parser-hazard pinned cells (xconnector X6, pin-level): forged
`violations=0` mid-stream, dup_flush forged logical-last, binjunk
non-UTF-8 decode, detach-child EOF-hold — as explicit battery cells
through the tracked parse_arms / run_process. Hazard pins are CONTRACT
pins ("the demonstrated hazard resolves as X"), never safety claims.
Prior 118 ARM rows byte-identical; falsifier liveness re-verified.

Runtime: Blender 5.2.1 LTS headless (hash `9e2066aef7ef`), embedded CPython
3.14.7, `/usr/bin/blender -b -P`; battery under system python3 3.14.7. LSP
unavailability recorded (r81 standing): no `lsp` device serves this repo —
text-level insertion only, no cross-file rename needed.

## Landed changes (insertion-only)

- `corpus/fixtures/bpy_sync_probe.py` (committed in `0619300`; working tree
  carries one uncommitted refinement — the C-stdio `fflush` before the fd
  redirect, see below):
  - r82 section (`:1177-1474`): three helpers (`_ec_all_names`,
    `_ec_inst_count`, `_ec_in_dg`) + six bare-class sub-probes
    `_ec_x2_{update_tag, custom_matrix_world, libraries_load,
    instance_empty, batch_remove, evalget_unlinked}` + two documentary DEG
    side cells `_ec_x2_{instance_refused, evalget_freed}` — all appended to
    `arm_evalcat`'s tuple after `_ec_x_orphan_purge` (`:1496-1501`) so they
    run before `closed`, under the falsifier. Constructions folded verbatim
    from r82-scout's pre-measured probe (`corpus/live/r82-scout/
    r82_classes_probe.py`, runs a+b identical), same witness discipline
    (fixtures pre-window, pending write pre-window, held dg0 pre-window).
  - Forged mid-stream row (`:1481-1487`): `emit("evalcat","closed","EDGE",
    violations=0, forged="parent_midstream")` at the top of arm_evalcat —
    lands before the genuine trailing `closed` row (H1 live injection).
  - `arm_hazards()` (`:1572-1578`) + runner-tuple append: the dup_flush
    same-key pair (parent-emitted, later forged value wins the cell).
  - `_ec_x2_instance_refused` fd hygiene (`:1344-1371`): the enum rejection
    also writes a C-level `reports | ERROR` line to fd1 with an uptime
    timestamp — bypasses the buffered print() path and would jitter raw
    stdout. The two assignments run under a bounded `os.dup2(1→devnull)`
    redirect; a `ctypes` `fflush(NULL)` FIRST lands the pending C banner on
    fd1 (the report path flushes C stdio — without the pre-flush the banner
    is swallowed; measured: banner eaten in intermediate runs, restored at
    byte 0 after). Python emit() bytes are buffered, unaffected; fd1
    restored in `finally`.
- `corpus/fixtures/bpy_battery.py` (committed in `0619300`, incl. the r82
  critic's fold: the forge invariant split into marker-presence +
  genuine-cell checks independent of the marker key):
  - docstring r82 paragraph (`:25-39`); `import time` (`:47`).
  - +9 CASES rows (`:257-333`): six `ext2_*` EDGE pins + two DEG side-cell
    pins + `hazard_dup_flush_lastwins` PARSE pin (`v=forged` — physical
    last-wins pinned AS THE CONTRACT).
  - `hazard_checks` block (`:466-565`) gated into the verdict (`:580-581`)
    and recorded in the receipt (`hazard_checks` + `hazard_detail`,
    `:591-593`): synthetic forge-order cells through tracked `parse_arms`,
    binjunk decode through tracked `run_process`, bounded detach-EOF hold
    through tracked `run_process` (3 s timeout, `sleep 8` detached holder
    self-terminates), plus a fast-exit control.

## Measured result — battery `bpy-20261014T154404649215Z`: 83/83 PASS,
## 4/4 order-checks PASS, 7/7 hazard-checks PASS; stdout sha256
## `6a98c570…` identical ×3 runs (`…154116`, `…154123`, `…154404` —
## deterministic), stderr 0 B, `closed | violations=0`.

**ARM A — supported.** All six folded classes measure `held=stale
invoked=none`, handler deltas all 0 (`dpre=dpost=dfcp=dfc=0`,
`dund=0`), none can trip the falsifier; `closed | violations=0` holds
(probe.stdout.txt `:121-128`):

| class (point) | edge | discriminating witnesses |
|---|---|---|
| `ext2_update_tag_obj` | 1 | `ob.update_tag()` alone in-window; `held_loc=(0,0,0)` → `fresh_loc=(5,0,0)`; **`get_dup=1 get_fc=0`** — the tag marks dirty, the next tagged get evals (dup), fc never fires. Tag ≠ eval, the purest witness |
| `ext2_custom_matrix_world` | 1 | setter decomposes + tags internally; `held_loc=(0,0,0)` → `fresh_loc=(3,0,0)`, `rna_loc=(3,0,0)` (tier-0 immediate) |
| `ext2_libraries_load` | 1 | link=True + scene link; `held_names=o` → `fresh_names=libo|o`, `rna_lib=True` — RNA collection gains the linked ID at w0, held dg0 doesn't know it |
| `ext2_instance_empty` | 1 | Empty→COLLECTION of orphan col; `held_inst=0` → `fresh_inst=1`, `held_all=inst` → `fresh_all=ic_o|inst`, `rna_type=COLLECTION rna_coll=ic` |
| `ext2_batch_remove` | 1 | `D.batch_remove([ob,ob2])` on live IDs; held dg0 still enumerates freed IDs (`held_names=ctl|o|o2`, freed-ID read — fragile), `fresh_names=ctl`, `rna_objs=ctl` |
| `ext2_evalget_unlinked` | 1 | name-vs-behavior edge: out-of-graph `og` returns the ORIGINAL object (`og_same_id=True`, `og_ev_loc=(4,0,0)` — the un-evaluated RNA value) while linked `ctl` on the same handle returns the stale evaluated copy (`ctl_ev_loc=(0,0,0)`, `ctl_same_id=False`) |

Side cells: `ext2_instance_refused` (DEG) pins `step1=ERR:TypeError…`
`type_after=NONE` — mesh objects refuse `instance_type='COLLECTION'` on
this build (explains why the relations row uses an Empty);
`ext2_evalget_freed` (DEG) pins `res=ERR:ReferenceError` — evaluated_get
on a FREED ID is a name-read failure, not an eval edge.

**ARM B — supported (contract pins, all measured).** The probe's forged
`violations=0 forged=parent_midstream` row lands mid-stream
(probe.stdout.txt `:80`); the genuine `closed` row lands `:128` and keeps
the cell. Pinned resolutions:

- `hazard_forge_marker_present` — forged bytes visible in raw stdout.
- `hazard_forge_closed_cell_genuine` — cell carries the genuine row
  (`violations=0`, `events` present, no `forged` key): **the mid-stream
  forgery is absorbed, not masked-onto** — physical last-wins protects
  the trailing genuine row.
- `hazard_forge_last_wins_cell` — synthetic through tracked parse_arms:
  forge-last → `violations=0` (the demonstrated **mask** — the parser
  detects nothing), forge-first → `violations=3` survives. Byte order is
  the whole defense; r82-critic demonstrated the mask live
  (forged-post/forged-detached rows masked a real `violations=1` and the
  battery still reported PASS — `corpus/live/r82-critic/runs/p2-*`).
- `hazard_dup_flush_lastwins` (CASES) + `hazard_dup_flush_order_decides`
  (synthetic, both directions: `dup_ab=forged`, `dup_ba=first`) — later
  same-key row wins the cell; a forged logical-last rewrites the pinned
  row. Pinned as the contract.
- `hazard_binjunk_decode_raises` — non-UTF-8 fd1 bytes resolve as
  **UnicodeDecodeError propagating unhandled out of the tracked
  `run_process`** (its except catches only TimeoutExpired/OSError; pinned
  known failure mode, not a fix).
- `hazard_detach_eof_hold` — a detached descendant inheriting fd1
  withholds pipe EOF: `run_process` returns ONLY via the TIMEOUT branch
  (`error="TIMEOUT after 3 seconds"`, `rc=None`, wall 3.004 s) while the
  parent's bytes (`EOF_PARENT_DONE`) were already captured.
  `hazard_eof_control_fast` — same parent without the holder returns
  `rc=0` immediately: the hold is the inherited pipe, not the child.

## Evidence

- Battery: `python3 corpus/fixtures/bpy_battery.py --runs
  corpus/live/r82-author/runs` → `cases=83 pass=83 fail=0
  (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0
  exit=0`; receipts `runs/bpy-20261014T154404649215Z/` (+`…154116`,
  `…154123` — identical stdout sha `6a98c570…`, deterministic ×3);
  `verdicts.json` carries `order_checks` + `hazard_checks` +
  `hazard_detail`; probe stderr byte-empty; wall 4.55 s (TIMEOUT_S=60
  unaffected; battery-side hazard subprocess cells add ~3 s outside it).
- Byte-stability: baseline `runs-baseline/bpy-20261014T153315575153Z`
  (74/74, sha `947ad726…` — same stream as r81). Checker
  `corpus/live/r82-author/bytestab.py`: all 123 baseline ARM lines are a
  byte-identical ordered subsequence of the new 134; 11 inserted lines
  (forged closed, 6 ext2 EDGE, 2 ext2 DEG, 2 hazard PARSE); non-ARM lines
  identical in content — the version banner relocates to byte 0 (the C
  stdio buffer is flushed during arm_evalcat before python's buffered
  bytes land; deterministic, documented above).
- Falsifier liveness: mutant `corpus/live/r82-author/
  probe_mutant_violation.py` (one inserted `C.view_layer.update()` inside
  the `ext2_update_tag` window) → `ext2_update_tag_obj` auto-emits
  `edge=FALSIFIED`, real `closed` carries `violations=1` — and the
  forged mid-stream `violations=0` does NOT mask it (last-wins keeps the
  genuine row). Tracked-parser replay (`parse_arms` + the case predicate)
  on `mutant.stdout.txt`: `evalcat_closed_set` FAILs, `forged` key absent
  from the cell. On the real receipt the same predicate reports 0
  failures — the falsifier discriminates; it is armed, not decorative.
- `n_arm_lines` 122 → 131 (+9 cells); physical ARM lines 123 → 134.

## Remaining unknowns / risks

- The `closed | violations=0` closure now covers 20 bare rows + the event
  axis — still bounded to the probed catalogue (r80-critic wording); ops
  rows stay in-set by construction.
- `ext2_batch_remove`/`ext_obj_remove` ride freed-ID enumeration on the
  held dg0 (stable ×3 here; r82-critic measured a SEGFAULT when
  `batch_remove` is applied to *stale/already-freed* references — this
  fold removes live IDs only; the crash surface is documented, not
  pinned).
- `ext2_libraries_load` leaves a `.blend` under `tempfile.mkdtemp()` per
  run (~140 KB, /tmp) — bounded litter, no cleanup (mirrors scout's
  construction; harmless on this host).
- The forge hazard's honest boundary: a forgery landing physically LAST
  masks a real violation and the battery cannot detect it from the parsed
  cell — the `closed_cell_genuine` check guards only against marker-
  carrying forgeries. Timestamps/signing are out of scope; the stream is
  trusted-emitter by design.
- `ext2_instance_refused`'s fd redirect assumes a POSIX fd1 + libc
  (`ctypes.CDLL("libc.so.6")`); both guarded (`try/except`), and a failure
  fails loudly via the FATAL path, never silently.
- `hazard_detach_eof_hold` semantics pin is threshold-free (TIMEOUT
  branch + captured bytes + rc=None) — no timing-leaf jitter; the 8 s
  sleeper self-terminates, no SIGTERM-immune fifo-open involved.
- The working tree carries one uncommitted refinement vs `0619300`: the
  pre-redirect `fflush` that preserves the startup banner (committed
  blob `df66d17…` eats it; working blob `5ed3f14…` restores it at byte 0
  — stdout sha `6a98c570…` ×3). Shipping decision left to the operator.

Files changed: `corpus/fixtures/bpy_sync_probe.py`,
`corpus/fixtures/bpy_battery.py`, this report, scratch under
`corpus/live/r82-author/`. Stopping here.
