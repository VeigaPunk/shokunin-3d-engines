# game-dev-3d round 82 — critic (seat: critic, host: devin)

Adversarial audit of the r82 declared move (ARM A: evalcat residual fold, X7;
ARM B: parser-hazard pinned cells, X6) as specified by
`.ufo/waves/shokunin-train-20261101-w13/tasks/g3d-author.md`, plus the
counterexample probes and mutants that the landed diff will be replayed
against.

Host/build: Blender 5.2.1 LTS headless — banner identity `Blender 5.2.1 LTS
(hash 9e2066aef7ef built 2026-09-01 00:24:57)`, i.e. the `9e2066aef7ef` token
in prior reports is the **build hash from the banner**, not a file digest
(file sha256 `fd7c5e44f50de301…`, md5 `a10af274…`; the banner identity is the
one to quote). Embedded CPython 3.14.7. `timeout -s KILL` on every
spawn-adjacent probe.

Reviewed artifacts (pre-landing state, re-hashed repeatedly through the
review):

| artifact | sha256 | lines |
|---|---|---|
| `corpus/fixtures/bpy_sync_probe.py` | `a4b1f94bff08af47c63b86df0fac3f9fa0e481ad5aa6d48aa81947d342a52023` | 1262 |
| `corpus/fixtures/bpy_battery.py` | `111568eec55fe1e489cc8ec6d41b8c2934611466537749d0dace68601fb44e4e` | 409 |

`git status --porcelain` empty, HEAD `31cf56a` (r81 report-last) at the start of
the review. **The author diff landed during the review** — probe at 15:34:16Z,
battery CASES at ~15:35Z, `hazard_checks` at ~15:36Z — and §9 replays it
end-to-end (hash-watched: `runs/watch_diff.log`; pre-landing hashes
re-verified unchanged at 15:32:12Z, i.e. all of §1–§8 is a genuine pre-landing
attack on the declared move). Reviewed landed state: `bpy_sync_probe.py`
sha256 `77065bb6a5989c1f5646415c5670bd166348ef1de49bd7a36af1ef3db271ef45`
(1589 lines) and `bpy_battery.py` sha256
`f8729aa725e6061cc08ce13d34b1d66718112a1d29ff16065f817cca2ba3ae19`
(604 lines) at 15:36:15Z; the battery may still be growing after that stamp,
so §9 pins the exact hashes it reviewed. Nothing here is a verdict on the
diff; every claim below is about the tracked fixtures at the hashes above or
about my own scratch constructs, each with a receipt.

This seat wrote only `reports/round-82/r82-critic.md` (tracked) and
`corpus/live/r82-critic/` (gitignored, `corpus/.gitignore:1`). No tracked file
was modified; no git mutation; report only — I do not judge, admit, edit,
integrate, or ship.

**Net.** The declared ARM-A fold is inert on this build for all 13 candidate
classes I measured (agreeing with the scout's independent 14) — but two of the
brief's declared fold classes carry hazards the brief does not name: (F1)
`batch_remove` on any **stale/invalidated** datablock reference **SIGSEGVs the
host Blender** (exit 139), killing the probe and every row after it; and the
instance/relations axis is structurally invisible to the r81 witness helper,
so a copied row can pass vacuously. For ARM B, the honest measured answer to
"does the battery detect the forgery" is **no**: a line-boundary forged
`violations=0` row landing physically after the real row is **forge-accepted**
by the tracked case loop (74/74 PASS with a real violation on the wire), and
the same forge-accept path generalizes to *every* pinned cell (F2/F3). The
r81 body-splice residual is **live and reachable** with one mid-line flush and
is misattributed by the tracked parser (F4) — it is a checkpoint on the landed
diff, not a theoretical boundary. **All four ARM-B pins must be worded as
measured resolutions, not safety properties.**

**Landed-diff addendum (§9, probe `77065bb6…` / battery `f8729aa7…`):** the
diff implements the F1 crash guard (live-IDs-only `batch_remove`, with the
SEGFAULT cited in the docstring) and the F5b instance-aware witnesses; the new
fold rows are genuinely armed (injected-event mutant flips `closed` to
violations=1); the H1/H2 hazard cells are honestly worded; the body-splice is
**not** reachable in the landed arm (no mid-line flush anywhere in the probe);
and my live physically-last forgery mutant (real violation + descendant
forgery) is caught by the landed `hazard_forge_midstream_absorbed` invariant
even though the case layer passes 83/83 — verified against the landed code,
with one coupling caveat in §9.5.

## 1. Pre-landing replay (the lattice the diff will be measured against)

- **Battery replay at pre-landing HEAD**:
  `python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r82-critic/runs/prebaseline`
  → exit 0, `cases=74 pass=74 fail=0 (signal_fail=0 quirk_drift=0)
  launch_ok=True done_marker=True fatals=0`, probe 4.37 s, all four
  `order_checks` PASS; receipt
  `runs/prebaseline/bpy-20261014T151936478743Z/`.
- **Byte-identity with the r81 landed receipt**: my replay's
  `probe.stdout.txt` sha256 =
  `947ad72643d2a450fbea099a2b4392bc8eec51005e1e03568bbdce6879ddc1d0`, the
  exact full-stdout sha r81-author/r81-critic cite for the landed r81 tree
  (`reports/round-81/r81-critic.md:37-39`). Non-author reproduction of the
  prior wave's receipt at r82 pre-landing HEAD, so any r82 drift is
  attributable.
- Falsifier liveness (my own harness, P1): a bare row whose window contains a
  smuggled `evaluated_depsgraph_get()` auto-FALSIFIES and increments the
  violation counter (`runs/p1.stdout.txt: c_control_smuggled_eval`,
  `edge=FALSIFIED`, `violations=1`). My measurement apparatus is live, not
  constant-True.

## 2. ARM A — does the residual fold stay under the falsifier honestly?

Independent re-measurement with the tracked `_ec_*` predicate copied verbatim
(`bpy_sync_probe.py:585-596`): scratch probe
`corpus/live/r82-critic/p1_fold_candidates.py` (+`p1b`, `p1d`–`p1g`), receipt
`runs/p1.stdout.txt`.

**Measured inert (held=stale, invoked=none, dpre=dpost=dfcp=dfc=dund=0,
edge=1), i.e. safe to fold under `closed | violations=0`:**

| brief class | my row (P1) | notes |
|---|---|---|
| `update_tag` (purest discriminator) | `c_update_tag_dirty` / `_clean` / `_data` | all stale; `update_tag` is a tag, not an eval — the prediction holds in the dirty form too (the strongest form) |
| custom setter | `c_setter_matrix_world`, `c_setter_delta_location`, `c_setter_write_plus_tag` | RNA flips, held handle stale |
| `libraries.load` / `write` | `c_libraries_write`, `c_libraries_load_link` | live `.blend` round-trip, no handler fire |
| `instance_empty` / `instance_collection` | `c_instance_collection_clear`, `c_instance_type_clear` | inert **but witness-limited — see F5a** |
| `batch_remove` | `c_batch_remove*` | **could not be measured: SIGSEGV — see F1** |
| `evaluated_get` on a stale ID | `c_freed_id_name_read` | `freed_name=ERR:ReferenceError`, `held_names=keep\|o` (freed ID still enumerated, matching r81's `ext_obj_remove`), handler deltas 0 |

The scout's independent 14-class run
(`corpus/live/r82-scout/runs/classes/classes-a.stdout.txt`) agrees class by
class on everything except `batch_remove`, which it measured with **live**
IDs (no crash) — see F1 for why both measurements are correct.

**The falsifier's own honesty checkpoints for the landed rows** (code-level,
exact refs):

1. A row is only under the closed-set falsifier if it runs inside
   `arm_evalcat` **before** the `closed` emit (`bpy_sync_probe.py:1178-1210`).
   A new arm appended after `arm_reorder` would be outside it; the brief says
   "inside `arm_evalcat` before `closed`" — verify against the diff.
2. `invoked=None` is what arms the predicate (`:589`). A new row that needs a
   fresh get must close its measurement window before calling
   `evaluated_depsgraph_get()` (the r81 `_ec_x_*` pattern, e.g. `:1096-1100`),
   or the row auto-FALSIFIES. Passing `invoked="evaluated_depsgraph_get"` to
   dodge that while calling it a bare mutation would be **false provenance**
   (an event row mislabeled as a bare row) — that is the single most likely
   way the landed fold could *look* armed while being unarmed.
3. An exception escaping a folded sub-probe is caught at `:1190-1194` and
   emitted as `ARM evalcat | <fn> | FATAL | …`; any line containing
   `| FATAL |` forces verdict FAIL (`bpy_battery.py:316, 388-389`). Good
   (conservative), but it means every risky call inside a fold row needs its
   own `try/except`, and **crashes cannot be caught at all** (F1).

## 3. ARM B — do the parser-hazard pins overstate safety?

The brief's own wording discipline ("the demonstrated hazard resolves as X",
never "the parser is safe") is the right frame. Measured resolutions below;
each is a live end-to-end cell evaluated by the **tracked** battery case loop
(`corpus/live/r82-critic/p2_judge.py` imports `bpy_battery` and replays
`CASES` + `order_checks` verbatim).

### F2 (HIGH) — forged `violations=0`: **MASKS, and the battery does not detect it**

Scratch probe `p2_probe_forged.py` forces a **real** closed-set violation
(a bare row that flushes) and injects a forged `violations=0` row from a
descendant on the inherited fd1:

| variant | physical order | parsed `closed` cell | tracked verdict |
|---|---|---|---|
| real violation only (`R82_FORGERY_POS=none`) | real `violations=1` only | `violations=1` | **FAIL** (`evalcat_closed_set`) — pin live |
| forgery **before** the real row (`pre`) | forged @0, real @10901 | real `violations=1` | FAIL — **does not mask** |
| forgery glued to the `REORDERGLUE::` tail (`post`) | merged line | real `violations=1` | FAIL — dropped by `^ARM` |
| forgery with a leading newline (`post_nl`) | forged @11060 | forged `violations=0` | FAIL — but only via the *unrelated* `reorder_splice_dropped` |
| forgery after the arm's final flush (`post_flush`) | real @10841, forged @11332 | **forged `violations=0`** | **PASS — 74/74, 4/4 order-checks, real violation still on the wire** |
| detached descendant writing **after `PROBE_DONE`** (`detach`) | forged after `Blender quit` | **forged `violations=0`** | **PASS — post-hoc injection captured** |

Receipts: `runs/p2-realonly-*`, `p2-pre-*`, `p2-forgedpost-*`,
`p2-forgedpostnl-*`, `p2-post_flush-*`, `p2-detach-*` (`judge.json` +
`probe.stdout.txt` each). Corroborated independently by r82-scribe cells
A1/E2 (`reports/round-82/r82-scribe.md:158-193`), r82-scout H1
(`corpus/live/r82-scout/runs/hazards/hazards.json`), and r82-boundary
`after_mask` (`reports/round-82/r82-boundary.md:91-110`: 74/74 PASS with a
real untracked violation, forged row physically last; their `misplaced`
variant additionally shows an *unpinned* injected cell changes only
`n_arm_lines` and is invisible to every gate).

**The forge-accept path is not specific to `closed`** (F3, stream-level,
deterministic, `p7_forge_any_pin.py` → `runs/p7_forge_any_pin.json`):

- simulate a regime where the r81 dup pin *should* fail (`src=child_inj`) →
  `reorder_dup_lastwins` FAILs (pin live);
- append a forged `ARM reorder | dup | FD1 | src=parent forged=yes` after
  `PROBE_DONE` → **0 failures**; parsed cell is
  `{'src': 'parent', 'forged': 'yes'}`;
- same for `closed`: real `violations=1` FAILs; + forged `violations=0` →
  **0 failures**, parsed cell `{'violations': '0', 'forged': 'yes'}`.

The forgery is *visible in the parsed cell* and the battery still reports
PASS, because the case model compares only pinned keys and
`reorder_no_extra_cells` (`bpy_battery.py:358-360`) only rejects *extra* cell
names, not duplicates of allowed ones.

**Smallest safe correction (prototype, measured):** a raw-stdout multiplicity
check for singleton pins — the `closed` row must appear exactly once
physically. `p6_detect.py` → `runs/p6_detect.json`: clean baseline
`raw_closed=1 detect_ok=True` (no false positive), and **every** forged
variant above `raw_closed=2 detect_ok=False`. Six lines, insertion-only,
inside `main()` next to `order_checks`. A blanket duplicate-key census is
*not* safe: the r81 `dup` cell legitimately appears twice
(`reports/round-81/r81-critic.md:51-54`), so the check must be scoped to the
singleton cells and the `dup` cell must carry the "forgeable by construction"
sentence.

### F4 (MEDIUM) — the body-splice residual (r81-critic G2) is live and misattributed

`corpus/live/r82-critic/p5_splice_probe.py` + `p5_splice_parse.py` (tracked
parser imported) → `runs/p5_result.json`:

- **S1 body-splice**: parent writes a partial row and **flushes mid-line**,
  then a descendant's bytes land inside the parent row's `k=v` body. Raw line
  = `ARM splice | torn | FD1 | v=SPLICED-CHILD`; the tracked parser resolves
  `('splice','torn','FD1') → {'v': 'SPLICED-CHILD'}` — **a descendant's value
  attributed to the parent's cell**. The `^ARM` anchor cannot help: the merged
  line has a valid `ARM` prefix. So r81's "drop-not-misattribute" holds for
  the *glued-at-line-start* variant only (r81 `reorder_splice_dropped`) and
  **any r82 arm that flushes a partial row re-opens misattribution**.
  Reachability on the landed diff is a one-line check: a `sys.stdout.write(…)`
  without a trailing newline followed by a flush (or a `print(..., end='')`).
  This is the answer to "body-splice residual still reachable?" — reachable in
  the demonstrated construction; not reachable in the r81 arm (no mid-line
  flush), so the landed diff decides it.

### F5 (MEDIUM) — tie-break pin wording, and two fold-honesty traps

**(a) tie-break = physical flush order, and the descendant controls its flush
time** (same `p5_result.json`):

- S3 (descendant `printf`, parent buffered): parent flushes last →
  `src=parent_buffered` (the r81 contract shape).
- **S2 (descendant is `python3`, block-buffered pipe): the descendant's own
  withholding layer makes it physically last → `src=child_flushed_last` — the
  descendant wins the cell** even though the parent's write was earlier in
  logical order.
- P4 (`p4_hold_parent.py`): a detached descendant can write **after
  `PROBE_DONE`/`Blender quit`** and the row is still captured (reader holds
  until EOF); `post_hold_after_done: true` (`runs/p4_hold3.json`).

So the `dup_flush` pin must read "physical (flush) last-wins; whoever flushes
last wins, and a descendant can be last by buffering its own output or by
outliving the parent" — never "the parent wins" / "the parser cannot be
overridden". The brief's "pin the physical last-wins behavior as the
CONTRACT, documented" is exactly right; the risk is the surrounding sentence.

**(b) the relations/instance axis is invisible to the r81 witness helper.**
`p1g_instance.py` → `runs/p1g.stdout.txt`: the tracked witness
`_ec_names` (`bpy_sync_probe.py:558-563`, filters `not i.is_instance`) reads
`tracked_names_pre=inst → tracked_names_post=inst` while the instance axis
actually moved `inst 1 → 0` under an enumerated event. And `_ec_edge1`
(`:599-604`) returns `"1"` whenever `fresh == expected`, so a
**non-discriminating witness yields a vacuous `edge=1`** — a row that looks
armed and measures nothing. The axis *does* have a discriminating witness
(the held handle moves under an event: `held_inst 1 → 0`), so the fold row
must use an instance-aware witness (`i.is_instance` names/count), not
`_ec_names`. Note the scout's instance row used
`held_inst_pre=0 held_inst_post=0 fresh_inst=1` — held-side non-discriminating
by construction; the author should not inherit that shape.

## 4. F1 (HIGH) — `batch_remove` on a stale reference SIGSEGVs the host

Two of the brief's declared fold classes (`batch_remove`, "`evaluated_get` on
a stale ID") sit on a crash class the brief does not name. Measured rule
(`p1c`/`p1d`/`p1e`/`p1f`; logs in `runs/`, crash dumps
`runs/p1b_crash.txt`, `runs/p1f_crash_batch_remove_stale_collection.txt`):

| call | argument state | result |
|---|---|---|
| `D.batch_remove({ob})` | live ID | ok (returns `None`) |
| `D.batch_remove({ob})` twice, same ID | 2nd call sees a freed ID | **SIGSEGV, exit 139** |
| `D.batch_remove({freed, live})` | mixed | **SIGSEGV** |
| `D.objects.remove(a)` then `D.batch_remove({a})` | freed by a different free path | **SIGSEGV** |
| `read_factory_settings()` then `D.batch_remove({ob})` | invalidated by reset (**the `_ec_reset()` shape, `bpy_sync_probe.py:483-485`**) | **SIGSEGV** |
| `read_factory_settings()` then `D.batch_remove({col})` | stale collection | **SIGSEGV** |
| `D.batch_remove({a})` then `D.batch_remove({c})` | distinct live IDs | ok |
| `ob.name`, `ob.evaluated_get(dg0)`, `D.objects.remove(ob)` on a freed ID | freed | clean `ReferenceError` (no crash) |

Repro (one command each; `timeout -s KILL` mandatory — the crash writes
`/tmp/blender.crash.txt`):
`timeout -s KILL 60 /usr/bin/blender -b -P corpus/live/r82-critic/p1d_stale_id.py -- double_batch_remove`
and `… -- batch_remove_stale_after_reset` for the `_ec_reset` shape (script
`corpus/live/r82-critic/p1f_batch_remove_stale.py`, log
`runs/p1f_batch_remove_stale_after_reset.log`; the crash dump is
`runs/p1f_crash_batch_remove_stale_collection.txt`, first frame
`p1f_batch_remove_stale.py`, i.e. the `batch_remove` call itself).

Why this matters to the landed diff, not just to a scratch probe: a segfault
is **unrecoverable by the probe's own `try/except`** (`:1190-1194`). The probe
dies with no `closed` row, no `PROBE_DONE`, no `verdicts.json`; the battery
reports FAIL and every later row — including the whole ARM-B parser-hazard
section if it is appended after `arm_evalcat` — is lost in the same run. The
scout's non-crashing `ext2_batch_remove` used a single call with live IDs,
which is consistent with the rule: the crash needs a stale reference, and
`_ec_reset()` is the most likely way a fold row acquires one (any module-level
or cross-sub-probe cached reference).

## 5. Mutant battery — run against the landed diff (§9)

The author diff landed at 15:34Z; the items below were executed against it and
the outcomes are recorded in §9 (items 1–4, 6, 8); items 5 and 7 are the
forgery/crash mutants, with the live outcomes in §9.5 and §9.2.

Ready-to-run (no edits needed to the tracked fixtures); each mutant is an
independent, falsifiable prediction about the new rows:

1. **Replay** — `python3 corpus/fixtures/bpy_battery.py --runs
   corpus/live/r82-critic/runs/landed`. Expect PASS; compare the new rows'
   values against my P1 table and the scout's 14-class run; check
   `closed | violations=0` and that the new rows sit *before* `closed`
   (`bpy_sync_probe.py:1178-1210`).
2. **Byte-stability** — the 123 prior raw ARM lines (122 unique cells; the
   `dup` cell is legitimately duplicated) must remain an in-order subsequence
   of the new stdout; the 74 prior CASES must be unchanged. My harness does
   this automatically (`landed_replay.py`: `prior_rows.in_order_subsequence`),
   plus a scope check that every new `evalcat` bare row sits physically
   *before* `closed`, a census of which new `_ec_*` sub-probes are actually
   wired into `arm_evalcat`'s tuple (a defined-but-unwired probe is dead
   code, not a folded row), and the singleton multiplicity check.
3. **Collapse mutant** (ARM-A liveness) — one-line
   `sys.stdout.reconfigure(line_buffering=True)` in the new fold's window:
   any row that becomes FALSIFIED proves the rows are live; a row that stays
   `edge=1` under collapse is decoration.
4. **Smuggled-event mutant** (false-provenance probe) — inject an enumerated
   event inside a new row's window: expect `edge=FALSIFIED` + `violations≥1`.
   If instead the row stays green, the row is mislabeled or out of scope.
5. **Forged-post-flush mutant** (ARM-B) — replay `p2_probe_forged.py`'s
   `post_flush`/`detach` shapes against the *landed* parser cells: if the
   landed pins claim detection, they must fail this; if they claim only
   measured resolution, they must say "MASKS".
6. **Mid-line-flush mutant** (body-splice) — `p5_splice_probe.py` against the
   landed parser: expect `v=SPLICED-CHILD` unless a new check closes it.
7. **Crash mutants** — `p1d`/`p1f` batch_remove shapes plus a
   `_ec_reset()`-crossing stale reference in the new fold: any new
   `batch_remove` row must survive all of them.
8. **Freshness/hash** — the two fixture sha256s at review time are in the
   header; a diff that touches bytes outside the declared insertion points
   (`bpy_sync_probe.py` arm_evalcat region + new arm; `bpy_battery.py` CASES
   tail + `order_checks`) is a scope violation regardless of verdict.

## 6. Impacted axes

- **depth**: parser-hazard pins are *measurement* pins, not safety pins. The
  demonstrated resolutions are: forge-accept on any pinned cell when the
  forgery lands physically last (F2/F3); drop-not-misattribute for the glued
  line but **misattribution for the body-splice** (F4); physical flush order
  as the tie-break contract, descendant-controlled (F5a); binjunk →
  `UnicodeDecodeError` out of `run_process` (corroborated scout H3 / scribe
  C1 — the tracked battery *aborts*, it does not report FAIL); detach EOF-hold
  bounded by the capture timeout, descendant leaks (P4 + scribe D-reap).
- **coverage**: ARM-A fold adds witnesses; the classes are inert on this
  build, so the fold's value is *representativeness*, not new signal. The
  instance row's witness must be fixed (F5b) or it adds a row without
  discrimination. `batch_remove` can only be folded safely in the live-ID
  form (F1).
- **calibration**: no thresholds need to change; the only new gate I recommend
  is the conservative raw multiplicity check on singleton pins (F2), which
  cannot produce a false FAIL on the clean stream (`p6_detect.json`).
- **identity/provenance**: the brief cites `bpy_battery.py:211-220` for
  `parse_arms`; the landed file has `ARM_LINE` at `:261` and `parse_arms` at
  `:278-287` (the brief's numbers match the r80-era 302-line file). The
  `9e2066aef7ef` "blender hash" in r81 reports is the banner build hash, not a
  file digest — receipts should say which token they mean.

## 7. Smallest safe corrections

1. **ARM B wording (mandatory):** pin the forged-`violations=0` cell as
   *"the demonstrated hazard resolves as: a line-boundary forged row landing
   physically after the real one is forge-accepted; the tracked battery does
   not detect it"* — with the `pre`/`post_nl` controls as the other two
   directions. Never "the parser must not let it mask" / "the battery detects
   the forgery".
2. **Add the multiplicity check** (six lines, `bpy_battery.py` next to
   `order_checks`): `closed` must appear exactly once physically; measured to
   detect all four forged shapes and to pass the clean stream
   (`p6_detect.py`).
3. **`dup_flush` pin text:** "physical (flush) last-wins is the contract; a
   descendant can be physically last by buffering its own output or by
   outliving the parent (measured S2/P4)" — plus one sentence that the cell is
   forgeable by construction, so the pin is a tie-break witness, not an
   integrity guarantee.
4. **Body-splice sentence in the scribe/knowledge note:** "drop-not-
   misattribute holds for the glued-at-line-start variant; a mid-line parent
   flush splices descendant bytes into the row body and the parser attributes
   them to the parent cell (`v=SPLICED-CHILD`). The landed arm performs no
   mid-line flush."
5. **ARM A implementation constraints:** `batch_remove` called **once with
   live IDs only**, placed last in the fold tuple; stale-ID classes read-only
   inside `try/except`; no stale reference may cross `_ec_reset()`; the
   instance row uses an instance-aware witness, not `_ec_names`; every new row
   closes its window before any fresh get and stays `invoked=none` (or is
   emitted as an event row and labeled as one).
6. **Nit sweep:** cite the real `parse_arms` line numbers; name the blender
   identity token (banner build hash vs file digest); binjunk belongs in
   scratch receipts unless a guarded decode is added to `run_process` (and
   then pinned as a fixture change).

## 8. Verification trail

- Scratch (gitignored): `corpus/live/r82-critic/` — `p1_fold_candidates.py`,
  `p1b_batch_instance.py`, `p1c_batch_remove_bisect.py`, `p1d_stale_id.py`,
  `p1e_batch_remove_pair.py`, `p1f_batch_remove_stale.py`, `p1g_instance.py`,
  `p2_probe_forged.py`, `p2_judge.py`, `p3_junkprobe.py`,
  `p3_binjunk_parent.py`, `p4_holdprobe.py`, `p4_hold_parent.py`,
  `p5_splice_probe.py`, `p5_splice_parse.py`, `p6_detect.py`,
  `p7_forge_any_pin.py`, `landed_replay.py` (the §5 one-shot mutant harness,
  dry-run clean at pre-landing HEAD: `runs/dryrun-*/landed_replay.json` —
  prior rows in-order, `closed` multiplicity 1, no `evalcat` row after
  `closed`, 16 `_ec_*` sub-probes wired into `arm_evalcat`).
- Runs/receipts: `runs/prebaseline/bpy-20261014T151936478743Z/` (74/74,
  stdout sha `947ad726…`); `runs/p1.stdout.txt` (+`p1b`, `p1g`);
  `runs/p1d_*.log`, `runs/p1e_*.log`, `runs/p1f_*.log`,
  `runs/p1b_crash.txt`, `runs/p1f_crash_batch_remove_stale_collection.txt`;
  `runs/p2-{realonly,pre,forgedpost,forgedpostnl,post_flush,detach}-*/judge.json`;
  `runs/p3_blender_result.json`; `runs/p4_hold3.json`, `runs/p4_hold40.json`;
  `runs/p5_result.json`, `runs/p5.stdout.txt`; `runs/p6_detect.json`;
  `runs/p7_forge_any_pin.json`; `runs/watch_diff.log`.
- All blender invocations bounded with `timeout -s KILL`; the one leaked
  detached descendant from the `hold=40` cell was reaped by pid (verified
  `pgrep` clean). The `hold=40`/`timeout=12` cell returned at **12.01 s**
  (`launch_error="TIMEOUT after 12 seconds"`, `rc=None`) — the tracked capture
  path is bounded, but the descendant survives the kill (same as scribe
  D-reap) and its post-hoc row is lost (`post_hold_present: false`).
- Cross-checks: r82-scout `runs/classes/classes-a.stdout.txt`,
  `runs/hazards/hazards.json`; r82-scribe `reports/round-82/r82-scribe.md`
  §2/A1-C1/D-reap; r82-boundary `reports/round-82/r82-boundary.md:91-110`.
- Landed-diff receipts (§9): `runs/landedA/…` (probe-only landing),
  `runs/landedB/…` (CASES landing), `runs/landedC/bpy-20261014T153628708520Z/`
  (full landed state, 83/83 + 4/4 + 6/6); `runs/mut-fold-eval-…/` (injected
  event → FALSIFIED); `runs/mut-landed-forge-20261014T153601066886Z/` (live
  physically-last forgery); `runs/p6b_singleton_last.json` (refined invariant
  tested on landed + forged + clean streams); `mut_fold_eval.py`,
  `mut_landed_forge.py` (scratch mutants of the landed probe).

## 9. Landed-diff replay (probe `77065bb6…`, battery `f8729aa7…`)

Reviewed at 15:34:16Z–15:36:15Z, replay run 15:36:28Z. Probe +329/−2 (the eight
`_ec_x2_*` sub-probes wired into `arm_evalcat` at `bpy_sync_probe.py:1497-1501`,
the H1 forged row at `:1484-1487`, `arm_hazards` at `:1572`); battery +197
(CASES for the eight cells + `hazard_dup_flush_lastwins`, the `hazard_checks`
block at `bpy_battery.py:515-546`, verdict gate extended with
`not hazard_failed` at `:581`).

**Replay** — `python3 corpus/fixtures/bpy_battery.py --runs
corpus/live/r82-critic/runs/landedC` → exit 0, **83/83 cases, 4/4 order-checks,
6/6 hazard-checks**, `signal_fail=0 quirk_drift=0 launch_ok=True
done_marker=True fatals=0`, probe 4.54 s, `n_arm_lines=131`; receipt
`runs/landedC/bpy-20261014T153628708520Z/` (`verdicts.json` carries
`hazard_checks` + `hazard_detail`). Battery wall **7.67 s** (was ~4.4 s; the
`hazard_detach_eof_hold` cell contributes a 3 s bounded hold and leaves a
self-terminating `sleep 8` descendant — measured gone after ~6 s; `TIMEOUT_S=60`
unaffected).

**9.1 Prior-row byte-stability — clean.** All 123 pre-landing raw ARM lines are
an in-order subsequence of the landed stream (missing 0), the 74 prior CASES are
unchanged, and every new `evalcat` row sits physically before the genuine
`closed` row (the H1 forgery is emitted at the top of `arm_evalcat`, so it is
physically first; the genuine row at line 130 is the last `evalcat` row).
Verified by `landed_replay.py` and re-checked on the landed stream.

**9.2 F1 (batch_remove SEGFAULT) — correction implemented.** The landed
`_ec_x2_batch_remove` calls `D.batch_remove([ob, ob2])` with **live IDs only**
(`bpy_sync_probe.py:1385`) and its docstring cites the critic measurement
("r82-critic measured a SEGFAULT when batch_remove is applied to
stale/already-freed references -- only live IDs are removed here"). The
post-window reads (`_ec_names` on the held and fresh graphs) match my
no-crash `stale_handle_read` cell (`runs/p1d_stale_handle_read.log`). The row
reproduces the scout's measurement (`held_names=ctl|o|o2` freed-ID enumeration,
`fresh_names=ctl`, `ret_type=NoneType`).

**9.3 F5b (witness honesty) — correction implemented.** The landed rows use
instance-aware helpers (`_ec_all_names`, `_ec_inst_count`,
`bpy_sync_probe.py:1188-1204`) instead of `_ec_names` for the relations axis:
`ext2_instance_empty` pins `held_inst_pre=0 → held_inst_post=0 → fresh_inst=1`
and `held_all=inst → fresh_all=ic_o|inst`. Because the pre-state is 0, a flush
in-window would move the held count to 1 and FALSIFY — the row is armed on that
axis too (consistent with my `p1g` event measurement, where the same witness
moved 1→0). No action needed.

**9.4 Fold arming — live under mutation.** `mut_fold_eval.py` (one injected
`C.view_layer.update()` inside `_ec_x2_update_tag`) → the row emits
`held=flushed invoked=none dpre=1 dpost=1 edge=FALSIFIED` and `closed` becomes
`violations=1` → battery FAIL (`runs/mut-fold-eval-*/`). The new fold rows are
discriminating, not decoration.

**9.5 ARM B — honest pins, and the live mask *is* caught by the new invariant.**
- H1 (`:1484-1487`) injects a forged `violations=0 forged=parent_midstream` row
  physically **first**; the genuine trailing row keeps the cell — the pinned
  direction. The code comment already states the other direction ("a forgery
  landing physically LAST would take the cell"), and
  `hazard_forge_last_wins_cell` pins that direction with a *synthetic* stream
  (`violations=0` last vs `3` first) — a parser-property test, honestly labeled.
- My **live** mutant (`mut_landed_forge.py`: a forced bare violation + a
  descendant forgery written after the arm's final flush) produces raw closed
  rows `[H1 @81, genuine violations=1 @130, forgery @139]`, `parse_arms` →
  `{'violations': '0', 'forged': 'descendant_last'}`, and the **case layer
  passes 83/83 with 4/4 order-checks** (`runs/mut-landed-forge-20261014T153601066886Z/`).
  So the mask is real end-to-end at the case layer.
- **But** the landed `hazard_forge_midstream_absorbed` invariant
  (`bpy_battery.py:519-524`) evaluates **False** on that same stream (the
  winning closed cell lacks `events` and carries `forged`), so `hazard_failed`
  is non-empty and the landed verdict would be FAIL. Evaluated directly against
  the landed code on both streams: genuine landed stream → check True; my
  forgery stream → check False. That is the correction I proposed in §7.2,
  independently derived, already implemented in equivalent form.
- **Caveat (smallest remaining correction):** that invariant is written as a
  conjunction whose first conjunct is the H1 marker string, so the
  "genuine-wins" half only runs while the H1 cell exists. Split it into an
  independent check — the winning `(evalcat, closed, EDGE)` cell must carry
  `events` and must not carry `forged` — so the invariant survives a future
  round that drops the H1 emit, and so it reads as a property of the parser
  rather than of this round's cell. Neither form detects a forgery that copies
  the genuine key set (boundary's `forge_full_keys`); state that limit.
- **F4 (body-splice) is not reachable in the landed arm**: `grep -n
  "sys.stdout.write(" corpus/fixtures/bpy_sync_probe.py` → no match, so no
  mid-line flush exists anywhere in the probe; the H2 `dup_flush` cell
  (`:1572-1578`) pins byte-order last-wins in both directions
  (`hazard_dup_flush_order_decides`). The residual stays a documented boundary.

**9.6 Provenance nuance (no action).** `_ec_x2_evalget_unlinked`'s class action
calls object-level `ob.evaluated_get(dg0)` / `ctl.evaluated_get(dg0)` inside the
window while the row is emitted as bare (`invoked=none`). That is defensible:
`evaluated_get` (object-level) is not in `EVALCAT_EVENTS` and the measured
handler deltas are 0 (`dpre=dpost=0`), so no graph-eval event fired. One
sentence in the row docstring ("object-level evaluated_get is a read, not an
enumerated eval trigger") would prevent a reader from reading `invoked=none` as
"nothing graph-related ran".

**9.7 Residual risks I could not close.** (a) The battery was still changing
after 15:36:15Z; §9 pins the hashes it reviewed — a later edit invalidates this
section, not the pre-landing findings. (b) The `hazard_binjunk_*` and
`hazard_detach_*` cells run *inside* the battery process, so a regression there
turns the whole battery red rather than degrading a single cell (conservative,
but it means the battery is now coupled to two extra subprocess paths).
(c) Nothing in the landed diff closes the `dup`-cell forgeability (a physically
last forgery carrying the pinned value); it is documented, and the singleton
invariant covers `closed` only.

**Verdict-level judgement is the canonical runtime's; this seat returns the
counterexamples, the measured resolutions, and the corrections above, and
stops here.**


