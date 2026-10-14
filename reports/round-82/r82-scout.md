# game-dev-3d round 82 — scout (seat: scout, host: devin)

Pre-measurement of the r82 author's declared surface, before it lands. Read
first: `SHARED.md`, `tasks/g3d-author.md`, r80-critic §4 fold list,
r81-scout §6 addendum, r81-adjudicator, r81-scribe parser-hazard table.
HEAD `31cf56a`; working tree untouched by this seat (scratch only,
`corpus/live/` gitignored); no tracked fixture, LOG, or SCORECARD write.

**Runtime (all bounds below).** Blender 5.2.1 LTS headless
(`/usr/bin/blender`, hash `9e2066aef7ef`, built 2026-09-01), embedded
CPython 3.14.7, `blender -b -P`, pipe capture, this host.
`io.DEFAULT_BUFFER_SIZE=131072` is THIS build's constant, not a universal.
Hazard pins below are CONTRACT pins — they document measured parser/harness
behavior, never safety claims; parser survival != parser safety; evalcat
closure stays bounded to the probed catalogue.

**Line-ref correction.** The author brief sends the parser cells "through the
tracked `parse_arms` at `bpy_battery.py:211-220`". That is pre-r81
numbering; at HEAD the tracked functions are `ARM_LINE` `:261`,
`run_process` `:264-275`, `parse_arms` `:278-287`, `TIMEOUT_S` `:36`,
closed-set pin `:198-199`, verdict gate `:388-389`. Everything below imports
and runs those functions verbatim.

## 0. Method, viability, baseline

Scratch: `corpus/live/r82-scout/` (manifest.sha256 pins every artifact).

- `r82_classes_probe.py` copies the tracked `_ec_*` witness machinery
  verbatim (`emit` `bpy_sync_probe.py:60-62`, `_ec_held` `:573`,
  `_ec_edge` closed-set rule `:585-596`) and adds the six candidate classes.
  Self-validation: two control rows reproduce tracked pins exactly —
  `ctl_rna_write` == `evalcat_rna_write_edge1` (held=stale, deltas 0,
  edge=1) and `ctl_ev_get` == `evalcat_ev_get_flush` (flushed, dup+1,
  edge=0).
- Witness discipline (r81-critic in-window-settle rule, r81-scout §6.5):
  fixtures built OUTSIDE the window; pending RNA write lands BEFORE the
  window; the window contains only the class action; held read = `dg0`
  captured pre-window. Destructive classes (batch_remove) ride a separate
  `ctl` witness object.
- Viability: probe exit 0, stderr byte-empty, wall 0.66 s (blender startup +
  15 rows); run ×2 → ARM rows byte-identical, sha256 `02e9c475…`.
- Pre-landing baseline (my own run): `python3 corpus/fixtures/bpy_battery.py
  --runs corpus/live/r82-scout/runs/baseline` → exit 0, **74/74 PASS**,
  `signal_fail=0 quirk_drift=0 fatals=0`, probe 4.43 s, `n_arm_lines=122`,
  probe.stdout sha256 `947ad726…` — byte-identical to the r81 landed receipt
  (`r81-author/runs/bpy-20261014T145725071084Z`) and to the r82-simplifier
  baseline. This is the anchor the author's insertion-only fold must preserve.
- Fold cost estimate: +~0.7 s probe wall (my whole 15-row probe is 0.66 s);
  `TIMEOUT_S=60` unaffected.

## 1. ARM A — six candidate classes, pre-measured (all foldable)

All twelve class rows measured `held=stale`, `invoked=none`, every handler
delta 0, and the closing `closed | violations=0` row holds with all of them
appended — the brief's prediction (held=stale, edge=1-or-absent, deltas 0)
is CONFIRMED for every class; no falsifier fired. Exact emitted rows are in
`runs/classes/classes-a.stdout.txt` (class rows 3-14, `closed` at 15;
controls 1-2); suggested pin keys below.

| # | class / point | held | edge | deltas | discriminating witnesses (held → fresh) |
|---|---|---|---|---|---|
| 1 | `update_tag` obj `ext2_update_tag_obj` | stale | 1 | all 0 | `held_loc=(0,0,0)` → `fresh_loc=(5,0,0)`; `get_dup=1 get_fc=0` |
| 2 | `update_tag` scene `ext2_update_tag_scn` | stale | 1 | all 0 | `held_loc=(0,0,0)` → `fresh_loc=(6,0,0)`; `get_dup=1 get_fc=0` |
| 3 | tag-on-clean side cell `ext2_update_tag_clean` | stale | absent | all 0 | `fresh_loc=(0,0,0)` == held — nothing to bind |
| 4 | custom setter `ext2_custom_matrix_world` | stale | 1 | all 0 | `rna_loc=(3,0,0)` immediate; `fresh_loc=(3,0,0)`; `get_dup=1 get_fc=0` |
| 5 | custom setter `ext2_custom_dimensions` | stale | 1 | all 0 | `held_scale=(1,1,1)` → `fresh_scale=(2,2,1)`; `rna_scale=(2,2,1)` |
| 6 | `libraries.write` `ext2_libraries_write` | stale | 1 | all 0 | `fresh_loc=(4,0,0)`; `ret_type=NoneType`; `lib_bytes=140680` |
| 7 | `libraries.load` `ext2_libraries_load` | stale | 1 | all 0 | `held_names=o` → `fresh_names=libo|o`; `rna_lib=True` |
| 8 | `instance_empty` `ext2_instance_empty` | stale | 1 | all 0 | `held_inst=0/0` → `fresh_inst=1`; `held_all=inst` → `fresh_all=ic_o|inst` |
| 9 | `batch_remove` `ext2_batch_remove` | stale | 1 | all 0 | `held_names=ctl|o|o2` → `fresh_names=ctl`; `rna_objs=ctl` |
| 10 | `evaluated_get` out-of-graph `ext2_evalget_unlinked` | stale | 1* | all 0 | `og_same_id=True og_ev_loc=(4,0,0)` vs `ctl_same_id=False ctl_ev_loc=(0,0,0)` |
| 11 | `evaluated_get` freed (DEG side) `ext2_evalget_freed` | — | — | all 0 | `res=ERR:ReferenceError` |
| 12 | mesh `instance_type` refused (DEG side) `ext2_instance_refused` | — | — | all 0 | `step1=ERR:TypeError…`; `step2=ok` but `coll_after=none` |

Verbatim rows (fold source; every value space-free):

```
ARM evalcat | ext2_update_tag_obj | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(5.000,0.000,0.000) get_dup=1 get_fc=0
ARM evalcat | ext2_update_tag_scn | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(6.000,0.000,0.000) get_dup=1 get_fc=0
ARM evalcat | ext2_update_tag_clean | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=absent held_loc=(0.000,0.000,0.000) fresh_loc=(0.000,0.000,0.000)
ARM evalcat | ext2_custom_matrix_world | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(3.000,0.000,0.000) rna_loc=(3.000,0.000,0.000) get_dup=1 get_fc=0
ARM evalcat | ext2_custom_dimensions | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) held_scale=(1.000,1.000,1.000) fresh_scale=(2.000,2.000,1.000) rna_scale=(2.000,2.000,1.000) get_dup=1 get_fc=0
ARM evalcat | ext2_libraries_write | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(4.000,0.000,0.000) ret_type=NoneType lib_bytes=140680 get_dup=1 get_fc=0
ARM evalcat | ext2_libraries_load | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(4.000,0.000,0.000) pre_names=o held_names=o fresh_names=libo|o rna_lib=True get_dup=1 get_fc=0
ARM evalcat | ext2_instance_empty | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(2.000,0.000,0.000) held_inst_pre=0 held_inst_post=0 fresh_inst=1 held_all=inst fresh_all=ic_o|inst rna_type=COLLECTION rna_coll=ic get_dup=1 get_fc=0
ARM evalcat | ext2_batch_remove | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(5.000,0.000,0.000) ret_type=NoneType pre_names=ctl|o|o2 held_names=ctl|o|o2 fresh_names=ctl rna_objs=ctl get_dup=1 get_fc=0
ARM evalcat | ext2_evalget_unlinked | EDGE | held=stale invoked=none dpre=0 dpost=0 dfcp=0 dfc=0 dund=0 dup_fired=False fc_fired=False edge=1 held_loc=(0.000,0.000,0.000) fresh_loc=(7.000,0.000,0.000) og_in_dg=False ctl_in_dg=True og_same_id=True og_ev_loc=(4.000,0.000,0.000) og_ev_name=og og_err=none og_rna_loc=(4.000,0.000,0.000) ctl_same_id=False ctl_ev_loc=(0.000,0.000,0.000) get_dup=1 get_fc=0
ARM evalcat | ext2_evalget_freed | DEG | res=ERR:ReferenceError ev_loc=na ev_name=na dpre=0 dpost=0 dfcp=0 dfc=0
ARM evalcat | ext2_instance_refused | DEG | step1=ERR:TypeError:bpy_struct:_item.attr_=_val:_enum_"COLLECTION"_not_found_in_ step2=ok type_after=NONE coll_after=none dpre=0 dpost=0 dfcp=0 dfc=0
```

Per-class notes (all measured, ×2 deterministic):

1-2. **`update_tag` = tag != eval.** Pending write pre-window, `ob.update_tag()`
   / `scene.update_tag()` in-window: held stays `(0,0,0)`, zero handler fires,
   and the next tagged get binds the pending write (`get_dup=1`, `get_fc=0`).
   The purer separation is row 3: tag alone on a clean graph binds nothing
   (`fresh == held`) — "tagging is not an eval event" with no eval to bind.
3. Label decision needed: `edge=absent` (no eval event, no bind) vs dropping
   the row. It cannot falsify (d=0, held=stale). r81-scout §6.7 measured the
   same class in scratch; this is an independent re-measure.
4-5. **Custom setter** = `matrix_world` (decomposing setter) and `dimensions`
   (scale via evaluated bbox). `matrix_world`'s discriminating witness is the
   immediate tier-0 `rna_loc`; `dimensions`' location witness is
   non-discriminating (loc stays `(0,0,0)`), the scale pair is the witness.
   Same values as r81-scout's scratch addendum — independent reproduction.
6-7. **Data layer.** `libraries.write` writes 140680 B and returns NoneType;
   `libraries.load(link=True)` + scene link: RNA collection gains `libo` at
   w0, held `dg0` stays blind (`held_names=o`), fresh serves `libo|o`.
   `lib_bytes` is an optional pin (file-size; low cross-build risk but it is
   a file artifact, not a graph witness).
8. **Relations.** The Empty variant is the valid one: `held_inst 0→0` (held
   graph blind), `fresh_inst=1`; `held_all=inst` → `fresh_all=ic_o|inst`.
   Side cell (row 12): mesh objects refuse `instance_type='COLLECTION'`
   (`TypeError: enum "COLLECTION" not found in ('NONE','VERTS','FACES')`);
   the subsequent `instance_collection=` assignment does not raise but is
   silently dropped (`coll_after=none`) with the build report line "Only
   empty objects support collection instances" — matches r80-boundary §2.
9. **Destructive batch — API correction.** `bpy.data.objects.batch_remove`
   does NOT exist on this build (`AttributeError: bpy_prop_collection:
   attribute "batch_remove" not found`); the tracked-sweep API is
   `bpy.data.batch_remove([ids])` (returns NoneType). Held `dg0` still
   enumerates the freed IDs (`held_names=ctl|o|o2` — the same freed-ID read
   fragility as `ext_obj_remove`), fresh drops them.
10. **`evaluated_get` name-vs-behavior edge.** On an ID absent from the
   evaluated graph (`og_in_dg=False`), `ob.evaluated_get(dg0)` returns the
   ORIGINAL object (`og_same_id=True`, name `og`) whose `.location` is the
   RNA value `(4,0,0)` — an "evaluated" call serving an un-evaluated value.
   The linked control on the same held handle returns the evaluated copy
   (`ctl_same_id=False`) with the stale value `(0,0,0)`. The call itself
   fires nothing (deltas 0). Label flag: the row uses the edge=1 shape
   (pending ctl witness binds at the tagged get), but the class action is a
   READ, not a write — author/critic should confirm the label (or use
   `absent`). Freed-ID variant (row 11, DEG side cell):
   `ReferenceError: StructRNA of type Object has been removed`.

## 2. ARM B — parser-hazard cells against the tracked parser (measured)

All cells import the tracked `run_process`/`parse_arms` verbatim. Receipts:
`runs/hazards/hazards.json` (+ `-run2/-run3`; stable modulo wall/pid),
`runs/mutant-{forge-last,forge-first,eof-hold}/`.

**H1 — forged `violations=0` row.** Synthetic streams, tracked pin
`evalcat_closed_set` (`{"violations": "0"}`, `bpy_battery.py:198-199`):

| stream order | parsed `violations` | tracked pin |
|---|---|---|
| real(3) then forged(0) | `0` | **PASS — masked** |
| forged(0) then real(3) | `3` | FAIL — detected |
| real(3), forged(0), real(3) | `3` | FAIL — detected |

Live end-to-end (copied fixtures, appended rows after the tracked `closed`
row, real battery run): **forge-last → `cases=74 pass=74 … launch_ok=True`
verdict PASS exit 0** — a real `violations=3` row was fully masked; the
forged row also leaves no trace in the payload (`n_arm_lines=122`, unchanged:
it counts unique `(arm,point,layer)` keys, not physical rows). forge-first →
73/74, `evalcat_closed_set FAIL` (`violations='3' != pinned '0'`), verdict
FAIL exit 1. **Honest pin: there is no forgery detection anywhere in the
tracked path; the outcome is pure physical last-wins. A forged row that
lands last masks a real violation; a real row that lands last survives.**
The brief's "must NOT mask" requirement is NOT met in the masking direction.

**H2 — dup_flush forged logical-last.** Synthetic: same key, later row wins
(`child_forge` last → `src=child_forge`; `parent` last → `src=parent`).
Live through the tracked capture, both flush positions:

| parent behavior | physical order | parsed `src` |
|---|---|---|
| parent flushes its row before spawning | parent, child_forge | `child_forge` (forged last wins) |
| parent withholds (block buffer), child first | child_forge, parent | `parent` (real last wins) |

Contract to document: **physical last-wins** — the same tie-break the r81
`reorder_dup_lastwins` row pins from the other direction. Value flips with
byte order; it is not a universal.

**H3 — binjunk non-UTF-8.** A descendant writing `\xff\xfe` on the captured
fd1 raises `UnicodeDecodeError` out of the tracked `run_process` (`'utf-8'
codec can't decode byte 0xff in position 28`). The battery catches only
`TimeoutExpired` (`:269`) and `OSError` (`:274`), so at battery level this is
an interpreter crash: uncaught driver → **exit 1, UnicodeDecodeError
traceback, no verdicts.json written, zero stdout** (receipts
`runs/hazards/binjunk-driver.{stdout,stderr}.txt`). Contrast pinned by H4:
the timeout branch decodes with `errors="replace"` (`:269-272`), so a
timed-out stream with the same byte yields `\ufffd` instead of raising.
Pin as a known-failure-mode cell (or the guarded decode, if the author
implements one — then this cell must flip).

**H4 — detach-child EOF-hold.** A detached descendant (`start_new_session`)
that inherits fd1 and outlives the direct child holds the pipe open: capture
EOF never arrives. Control (same parent, stdout NOT captured): exit 0 in
0.015 s — the stall is the held-open pipe, not the parent. Tracked
`run_process` under the battery timeout:
- T=3 s cell: wall 3.003 s, `rc=None`, `error="TIMEOUT after 3 seconds"`,
  partial stdout captured and decoded with replacement (`junk=\ufffd`),
  stderr empty.
- T=60 s end-to-end (copied probe spawns the detached `sleep` at exit; real
  battery run): **all 74 cases PASS, 4/4 order-checks PASS, `done_marker=True`,
  `fatals=0`, `launch_ok=False`, `probe_error="TIMEOUT after 60 seconds"`,
  elapsed 60.06 s → verdict FAIL exit 1.** The captured `probe.stdout.txt` is
  byte-identical to the baseline (`947ad726…`) — the capture is complete; only
  EOF never arrives. Pin: the harness converts a fully-green run to FAIL
  after exactly `TIMEOUT_S`, and the detached child survives the battery's
  kill (it must be reaped externally; my cells did).

## 3. Deltas for the author (what the design should carry)

1. Fold the twelve rows above inside `arm_evalcat` before `closed` (the two
   `ctl_*` rows are scratch self-validation — do NOT fold). `closed |
   violations=0` holds with all of them; no row falsifies. Suggested point
   names already carry the `ext2_` prefix.
2. Pin H1 as a contract, with the masking direction explicit: "the
   demonstrated hazard resolves as: forged-last masks (PASS), real-last is
   detected (FAIL); the tracked parser has no forgery detection; the payload
   does not count physical rows". Never "the parser is safe".
3. Pin H2 as the physical-last-wins contract, documented with both live
   flush orders (or as the battery-side equivalent of the r81 tie-break).
4. Pin H3 as the measured failure mode (strict decode raises; battery exits 1
   without a verdict) or implement + pin the guarded decode — do not claim
   both.
5. Pin H4 as harness behavior under `TIMEOUT_S=60` (`launch_ok=False` ⇒
   FAIL), and note the external reaping requirement for the detached child.
6. Row hygiene: every witness value must be space-free (r80-critic §5) — the
   refusal message was sanitized (`_` for spaces) in my probe; keep that if
   folded.
7. API corrections for the fold: `bpy.data.batch_remove([ids])` (not
   `objects.batch_remove`); `libraries.write` returns None on this build.
8. Baseline for insertion-only diffing: probe.stdout sha `947ad726…` (122
   ARM cells, 74 CASES) — the author's fold must keep every prior row
   byte-identical and in order as a subsequence.

## 4. Confidence and remaining unknowns

- **High**: all six classes inert (`held=stale`, all deltas 0, `edge=1` or
  `absent`) with deterministic discriminating witnesses ×2; parser last-wins
  in both orders synthetic + live; forged-last masking live end-to-end;
  strict-decode crash class; detach-EOF timeout branch and 60 s battery FAIL.
- **Medium**: the instance witness shape (`object_instances` is_instance
  count) as the fold pin; the `evaluated_get` row's edge label; `lib_bytes`
  as a pin.
- **Unknowns / not measured**: whether the folded sub-probes inside the
  tracked fixture reproduce these byte values (author must re-measure there —
  my probe is scratch); freed-ID reads remain build-fragile
  (`ext_obj_remove` inheritance); a Python descendant (vs `/bin/sh`) adds its
  own buffering layer to the dup/forge direction; tty/interactive/Windows
  bpy regimes; cross-build tolerance (none claimed — this host, this build).
- No judgment, admission, or promotion is made by this seat; the tracked
  fixture is untouched.

## 5. Receipts (commands, exits, shas under `corpus/live/r82-scout/`)

| # | command | exit | receipt | sha256 |
|---|---|---|---|---|
| 1 | `blender -b -P corpus/live/r82-scout/r82_classes_probe.py` ×2 | 0,0 | `runs/classes/classes-{a,b}.stdout.txt` | ARM rows identical `02e9c475…`; full a `75b1f119…` |
| 2 | `python3 corpus/live/r82-scout/r82_parser_hazards.py` ×3 | 0 | `runs/hazards/hazards{,-run2,-run3}.json`, `hazards-{a,b}.stdout.txt` | json `ec3b3032…`; run2 `2aeb679a…`; stable modulo wall/pid |
| 3 | `python3 corpus/live/r82-scout/ph_binjunk_driver.py` | 1 | `runs/hazards/binjunk-driver.stderr.txt` | `ae39cfcf…` (UnicodeDecodeError traceback; stdout 0 B) |
| 4 | `python3 corpus/fixtures/bpy_battery.py --runs …/runs/baseline` | 0 | `runs/baseline/bpy-20261014T152218487515Z/` | probe `947ad726…`, verdicts `2a9ff9bb…` |
| 5 | `python3 …/mutants/forge-last/bpy_battery.py --runs …/runs/mutant-forge-last` | 0 | `runs/mutant-forge-last/…/` | probe `e55b991d…`, verdicts `fc01da45…` (74/74 PASS — masked) |
| 6 | `python3 …/mutants/forge-first/bpy_battery.py --runs …/runs/mutant-forge-first` | 1 | `runs/mutant-forge-first/…/` | probe `44124c1e…`, verdicts `ec92ea2d…` (73/74 FAIL) |
| 7 | `timeout -s KILL 150 python3 …/mutants/eof-hold/bpy_battery.py --runs …/runs/mutant-eof-hold` | 1 | `runs/mutant-eof-hold/bpy-20261014T152242154286Z/` | probe `947ad726…`, verdicts `cc0f3a15…` (FAIL, 60.06 s) |

Probe sources: `r82_classes_probe.py` `5f34a0dd…`, `r82_parser_hazards.py`
`51f84ca1…`, `ph_dup_parent.py` `3177db33…`, `ph_eof_parent.py` `d8df17d5…`,
`ph_binjunk_driver.py` `3fc84ff3…`; all pinned in `manifest.sha256`. No stray
processes left by this seat (both detached children reaped; the live
`sleep 75` on the host belongs to another seat's watcher).

Report only; I do not judge, admit, edit, integrate, or ship. Stopping here.
