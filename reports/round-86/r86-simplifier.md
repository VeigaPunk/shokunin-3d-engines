# game-dev-3d round 86 — simplifier (seat: simplifier, host: devin)

Wave `shokunin-train-20261101-w17`, lane g3d. YAGNI audit of `4e65726`
(`r86 work: size-gate, deferred-hang, backend-tier, dummy-floor cells`;
`phys3d_events.gd` +622, `run_battery.py` +8, `README.md` +60/−8).
Assigned questions: (1) are the nine new inline project-body literals
foldable into the project generator? (2) dead branches/params in the new
arms? (3) duplicate sweep tails again? — with replay proof for every
candidate (195/195, prior 191 identical) and no weight move that shrinks
falsifiability (`HANG_BOUND_S`, the two-point band argument).

**No tracked edit was made by this seat.** Every write of this seat is
enumerated in §7: `/tmp/r86sim/`, the gitignored
`corpus/live/r86-simplifier/` receipt tree, and this report.

**The tree moved under this seat, twice (provenance; neither move is this
seat's write).** At `18:04:38` local (`21:04:38Z`) a sibling fold lane
applied this seat's SP1+SP2 helpers — verbatim, `_quit_clean` and
`_project_body` including their comment text — plus five r86-critic
corrections to the uncommitted `corpus/fixtures/phys3d_events.gd` and
`README.md`, validated the result with a full battery run at `21:04:45Z`
(`corpus/live/runs/20261014T210445883434Z/`: **195/195 PASS**,
`seed_digests.phys3d_events.gd = 4b539a12…`), and at `18:12:04` local
committed it as **`dd1737ac`** (`r86 fold: simplifier SP1+SP2 + critic
A1-A5`; `4e65726` → `dd1737ac`, fixture blob `66c92c38…` → `4b539a12…`).
The working tree is clean against that commit apart from untracked reports.
The committed delta against this seat's fully-replayed `v3` is exactly those
critic corrections (63 diff lines: A1 abort-text pin, A3 statement-count
wording, A4 callsite-line corroboration, A5 zero-vs-positive solver token,
the dummy child's `HANG_BOUND_S` pass-through) — and the landed tree's
receipts are that lane's, not this seat's. Every receipt in §7 is pinned to
the pre-fold bytes (`66c92c38…`, `4e65726`'s blob) or to this seat's scratch
trees, so no result below is read against the moved tree.

**Runtime:** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, 60 tps, 32 cores, this host. Every battery run below is the
canonical `corpus/fixtures/run_battery.py` verbatim (sha
`e2df9f96…` in every variant dir), 195 cases, no probe flags.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` for
this repo — no `lsp` device answers (same as every r85/r86 sibling lane).
No symbol-aware `references` operation was possible. Every symbol fact below
is therefore a **text census over the committed bytes** (declaration +
occurrence count), never presented as semantic proof; the semantic
substitute for this file is the engine's own GDScript parse plus the
battery's `Parse Error`/`SCRIPT ERROR` scan, which every replay below
exercises.

---

## 0. Result

| id | site | change | Δbytes | Δlines | replay | verdict |
|---|---|---|---|---|---|---|
| **SP1** | 13 project-body literals (`:785,888,927,962,1075,1076,1131,1132,1187,1192,1197,1250,1255`) | one `_project_body(name, engine, threaded)` generator; **all 13** sites folded | **−632** | +11 | 195/195 PASS; 11-field rows **0/195** diffs; prior-191 ordered-subsequence **191/191 at identical positions**; 15/15 generated `project.godot` **byte-identical**; 12/15 child logs byte-identical, 3 differ only by backtrace line numbers | **PROPOSE** |
| **SP2** | 15 cleanup+quit tails + 2 plain exits (whole-file exit protocol) | one `_quit_clean(code, message)`; all 17 exits folded | **−185** | **−29** | 195/195 PASS; 11-field rows **0/195**; prior-191 **191/191**; red/BLOCKED paths A/B-proven byte-identical (5 gates raw-identical, `_fail` norm-identical) | **PROPOSE** (optional — blast radius named) |
| — | `_child_tier` 8-frame dss retry `:1686-1693` | delete the bounded retry + named bail | −~350 | −12 | path unexercised on this build (first read always granted); r84 already rejected removing the analogous `_child_split` bail | **REJECT** — a named bail, not dead |
| — | `_backend_name` `"unexpected"` floor `:1680` | delete the floor | −35 | −1 | unreachable on any host with a physics server | **REJECT** — total-function floor, 1 line |
| — | `_child_split` retry guard `:1415-1426` (copy at `_child_tier`) | fold the two guards | — | — | load-bearing in `_child_split` (r85: 10/10 refusals at this size, the retry is what grants) | **REJECT** — one copy is load-bearing; folding re-attributes the bail (r85 VC) |
| — | individual `_cleanup_*` calls | delete any one | — | — | r84 V4/V5 settled: V4 falsified, V5 invisible to byte-identity | **REJECT** — settled ruling |

Both proposals are *candidates* from this seat (it has no edit scope). The
combined variant `SP1+SP2` = **−817 B / −18 lines** (`phys3d_events.gd` sha
`ec00f175cc9ea777…`), replayed as `v3`. The sibling fold lane applied the
same two folds (verbatim) plus critic corrections and committed them as
`dd1737ac`; that lane's receipts, not this seat's, are the landed tree's
evidence (see the provenance note above and §8).

**The author's disclosed tradeoff is answered directly.** §5 of
`r86-author.md` says a helper "used only by the new arms would leave two
ways to write the same thing". That is true of a 9-site fold and false of a
13-site fold: all 13 literals — the four r83–r85 bodies included — are
byte-for-byte the output of one three-argument generator (§2), so the fold
is total and no second convention remains. The four older literals are
frozen by their *receipts*, not by their source text, and the receipts are
preserved (§2.3).

---

## 1. Method, controls, byte-identity discipline

- Scratch trees (`/tmp/r86sim/`): `base` = `git archive HEAD corpus/fixtures`
  (byte-equal to the committed blobs, checked), `v1` = base + SP1, `v2` =
  base + SP2, `v3` = base + SP1 + SP2. The battery script is copied verbatim
  (its sha is inside every receipt's `seed_digests`).
- **Control receipt** `runs/control/20261014T203953716461Z/verdicts.json`:
  195/195 PASS, rc 0, `seeds_unchanged=true`, and
  `seed_digests.phys3d_events.gd = 66c92c38…` — the run measured the
  committed bytes.
- **Committed reference receipt** `corpus/live/r86-author/final1/
  20261014T202932153128Z/verdicts.json` (195/195, author §6.1) and the
  repo's own prior-row tool
  `corpus/live/r86-baseline/tools/postcommit_verify_godot_prior.py`
  against `prior-191-godot-rows.json` (the frozen r85 receipt's
  `(case, verdict, exit, marker)` tuples).
- Row comparison (`compare_receipts.py`, shipped in the receipt tree) is
  over the 11 receipt fields `case, script, flags, expected_exit,
  actual_exit, kind, marker, verdict, reasons, stdout, stderr`; the deep
  diff (all fields) additionally names `command` and `elapsed_seconds`,
  which are run-scoped by construction.
- Child logs are compared with the run directory normalized
  (`/<run>/scratch` → `/SCRATCH`), then line-by-line.
- One v2 run was **invalidated and superseded**, disclosed rather than
  deleted: `runs/v2/SUPERSEDED-gamepad-flake/` failed
  `phys3d_events_dummy_refused` on a stderr line
  `ERROR: Error opening gamepad at index 1: …` while the marker and exit
  were correct — the seat ran its red/BLOCKED A/B probes concurrently with
  that battery, and 16 concurrent godot processes fight over the SDL
  input device. A second serial re-run was then hit by the same external
  flake on an unrelated row (`navagent3d_distance_wide_reach`, correct
  marker and exit, `runs/v2/SUPERSEDED-gamepad-flake-2/`). This is the
  known host intermittence r69-verifier recorded ("at r68 the same case
  flaked via an external SDL gamepad stderr line"), not a fixture or
  variant finding: the flaked rows' `PASS`/`NEGATIVE REJECTED` markers and
  exit codes are correct in both receipts, and every phys3d row passes in
  both. The receipt of record is the serial re-run below; the superseded
  runs stay on disk so the flake is auditable.

---

## 2. SP1 — the project-body literals fold, totally

### 2.1 Census and the byte-equality proof

13 GDScript string literals in `phys3d_events.gd` begin `[application]`:
the four r83–r85 arms (`ThrChild` `:785`, `JoltChild` `:888`,
`JoltThrChild` `:927`, `DummyChild` `:962`) and the nine r86 arms
(`SzThr`, `SzPlain`, `HangThr`, `HangDummy`, `TierPlain`, `TierJolt`,
`TierDummy`, `FloorDummy`, `FloorReal`). Each was parsed into
`(name, engine, threaded)` and regenerated by the proposed

```gdscript
func _project_body(name: String, engine := "", threaded := false) -> String:
	var body := "[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\ncommon/physics_ticks_per_second=60\n" % name
	if engine != "":
		body += "3d/physics_engine=\"%s\"\n" % engine
	if threaded:
		body += "3d/run_on_separate_thread=true\n"
	return body
```

**13/13 literals reproduce byte-for-byte** (script `tools/fold_census.py`
in the receipt tree; the comparison is on the raw GDScript source text,
escapes included, so it is the runtime string). No literal needs a fourth
argument, no engine/threading combination is unrepresented, and the `60`
ticks line is constant across all 13 — the generator is total.

### 2.2 The variant

`v1` replaces each literal with its call (`_project_body("ThrChild", "",
true)` …) and defines the helper immediately before the `_spawn_probe`
section, with a two-line provenance comment. **Δ = −632 B / +11 lines**
(`wc -c` / `wc -l`; the helper is 6 code lines + 2 comment + 2 blank
separators, and every call site stays one line). File sha
`25eeba03969bb60d40e0625be60b1229a578fe6bd858f0813c801abe23bcda57`.

### 2.3 Replay — receipts byte-identical

| check | result |
|---|---|
| full battery | **195/195 PASS**, rc 0, `seeds_unchanged=true`, 4 new rows 4/4 (receipt `runs/v1/20261014T204340840862Z`) |
| 11 receipt fields × 195 rows vs control | **0 diffs** |
| deep fields (adds `command`, `elapsed_seconds`) | only those two run-scoped fields |
| repo prior-row tool vs `prior-191-godot-rows.json` | ordered-subsequence **PASS 191/191**, **identical positions 191/191**, inserted rows = exactly the 4 r86 cells |
| generated `project.godot`, all 15 child projects | **15/15 byte-identical** to control |
| child logs, 15 | 12 byte-identical; 3 differ **only** in GDScript backtrace line numbers |

The three shifted logs and their only differences:

| child log | difference |
|---|---|
| `thrproj` | `[0] _child_threaded (…phys3d_events.gd:1310)` → `:1321` ×11 |
| `joltthrproj` | `[0] _child_jolt_threaded (…:1390)` → `:1401` ×11, `[0] _child_split (…:1414)` → `:1425`, `[1] _child_jolt_threaded (…:1394)` → `:1405` |
| `floorrealproj` | `[0] _child_floor (…:1827)` → `:1838`, `[1] _run (…:468)` → `:479`, `[0] _child_floor (…:1843)` → `:1854` |

Every differing line is a source-pointer inside a backtrace; no verdict,
`CHILD_RESULT`, `CHILD_NOTE`, count or error text moves. This is the
normalization class the r84 V2 fold was accepted with ("threaded child log
normalized-identical (only the backtrace line number moves)") and the r85
verifier's caveat already covers `joltthrproj` as not byte-stable. 12 of the
15 child logs contain no `phys3d_events.gd` frame at all (they are
byte-identical outright); the 3 that do are exactly the 3 above, and all
eleven r86 child logs are byte-identical apart from `floorrealproj`'s two
shifted frames.

**Placement note (measured, optional).** The shifts exist because the
helper is inserted at `:315`, before every child body. Appending the same
helper after the last function (`_child_floor`, EOF) leaves all line numbers
below the 13 call sites untouched — the call sites are 1-for-1 line
replacements — so the fold would land with **zero** child-log churn.
`v1b` (that shape) was smoke-run on the three affected rows
(`threaded_edge`, `jolt_threaded`, `dummy_floor`): their child logs are then
byte-identical to control modulo the run-dir path. It is offered as the
strictly-safer placement if the fold is taken; it needs its own full replay
(the near-`_spawn_child` placement above is the fully-replayed shape).

### 2.4 Why not a 9-site fold

A helper used by only the nine new arms leaves four hand-written literals
and one generator — the second convention the author named. A 13-site fold
removes the literals entirely; the generator is then the only way a child
project body exists, exactly as `_spawn_child` is the only way a child
project is spawned (r84 V2 rule). The `project.godot` bytes it writes are
identical (15/15), which is what the pinned receipts actually pin.

---

## 3. Dead branches and params in the new arms

Census over the committed bytes (declaration + every occurrence, LSP
unavailable as recorded). **No dead local, no dead parameter, no dead
import** in the r86 additions:

| new symbol | sites | reads |
|---|---|---|
| `SIZE_PAD`, `HANG_BOUND_S`, `HANG_RC` | consts | 1, 1, 2 (compare + drift text) |
| `_spawn_child(script_res, bound_s)` | 2 defaulted params | `script_res` written by exactly one caller (`_spawn_probe`), default used by the other 9; `bound_s` forwarded by `_spawn_probe`, non-default at exactly one site (the hung child) |
| `res["errs"]` | additive key | read by 3 of the 4 new arms; `serr` retained for the pinned arms — both live, neither derivable without touching pinned fail text |
| `_spawn_probe` / `_size_probe_body(pad)` | 5 / 3 calls | `pad` read in the body; 0 and `SIZE_PAD` both used |
| `_backend_name()` | 2 child bodies | 3 branches + floor, all reachable except the floor |
| `_child_size` / `_child_tier` / `_child_floor` | 1 / 3 / 2 dispatch+spawn sites | all read |
| every new local (`b0,b1,base_g,base_d,ov_g,ov_d,area_g,casts,sep_data,sep_type,sep_cast,tokens,floor_sig,real_sig,cls,…`) | ≥2 occurrences | all read |

The one branch worth naming is **`_child_tier`'s bounded dss retry +
named bail (`:1686-1699`, 12 lines incl. comment)**: it never fires — the
tier children run under non-threaded generated projects, where the fetch is
granted at `_run` (boundary §4: the gate does not exist without
`run_on_separate_thread`), and their logs show `dss_class` on the first
read with no `dss_null` note. It is nonetheless **not dead**: it is
reachable in principle, it is the same named-bail convention the r84
simplifier already refused to delete from `_child_split` ("the child's
`dss == null` named bail"), and the r86 boundary seat independently ruled
the identical guard "unexercised but not dead" (`first_ok_tick=1` in 24/24
ladder cells). Deleting it would convert a named `dss_null=true` bail into
a SCRIPT ERROR plus a 30 s spin — falsifiability unchanged, diagnosis
worse, for ~350 B. **Rejected.**

Likewise `_backend_name()`'s `return "unexpected"` floor is unreachable on
a host that has any 3D physics server, but it is the total-function floor
of a three-way ClassDB gate (the same shape `_child_split` carries) and
costs one line. **Rejected.**

Two smaller duplications were considered and left standing: the 3-line
`make_dir_recursive_absolute` + error text that `_spawn_probe` repeats from
`_spawn_child` (it must create the directory *before* writing the generated
probe, and folding it would put a "write this script first" concern into the
pinned `_spawn_child` signature — the r84 V2 rule is that the spawn, not the
probe, is single-sourced), and the two `_size_probe_body(0)` calls (one per
arm; GDScript cannot const-fold a function call, and each arm owns its own
body binding).

No weight move here touches `HANG_BOUND_S = 8`, `HANG_RC = 137`,
`SIZE_PAD = 1000`, the ~475–575-line band wording, or the two-point
argument; the seat's stop condition was reached before those.

---

## 4. SP2 — the sweep tails, measured rather than assumed

### 4.1 Census

`_cleanup_nodes(); _cleanup_rids()` appears at **15 sites**: `_fail`,
`_exit_ok`, the `static_nopair` negative tail, **6 BLOCKED gates** (3 of
them new in r86: `:1174`, `:1180`, `:1243`), the two child bails
(`_child_split`, `_child_tier` — the latter new), and 6 child tails (2 new:
`_child_tier`, `_child_floor`). Two further exits own nothing and do not
clean up: the unknown-child-arm bail (`:471`) and `_child_size` (`:1348`).

So yes — **the pattern recurs**: r86 added 6 copies. They match the
established r84 convention ("every exit path in the file cleans up"), so
the additions are not a *new* convention; the question is whether the
convention itself has a cheaper total form. It does.

### 4.2 The variant

`v2` replaces every exit with one primitive, order-exact at every site
(cleanup → report line → quit):

```gdscript
func _quit_clean(code := 0, message := "") -> void:
	_cleanup_nodes()
	_cleanup_rids()
	if message != "":
		print(message)
	quit(code)
```

`_fail` keeps `push_error` in its own frame and calls `_quit_clean(1)`;
`_exit_ok(marker)` becomes `_quit_clean(0, marker)`. **Δ = −185 B /
−29 lines**; file sha `5aa8e77e1b550beb…`. 17 exits → 1 authority.

### 4.3 Replay — green path, and the paths the battery cannot see

Green (receipt `runs/v2/20261014T205855600118Z`): 195/195 PASS, 11-field
rows 0/195 vs control, prior-191 ordered-subsequence 191/191 at identical
positions, `seeds_unchanged=true`. Child logs: the same three
(`thrproj` 11, `joltthrproj` 13, `floorrealproj` 3 differing lines), every
one of them a backtrace line number and nothing else — same class as §2.3.

The battery never exercises a BLOCKED gate or a `_fail`, which is exactly
why the r84 seat rejected a *deletion* there ("unprovable by replay here").
SP2 deletes nothing, and the unexercised paths were instead **exercised in
an A/B** with an identical stub in `base` and `v2`:

| path | cells | result |
|---|---|---|
| 5 BLOCKED gates (`jolt_edge`, `jolt_threaded`, `dummy_refused`, `backend_tier`, `dummy_floor`) with `_engine_hint_has` stubbed false | 10 runs | stdout, stderr **and rc byte-identical** (`BLOCKED phys3d_events …`, rc 1) |
| red `_fail` path (`isect` expectation stubbed to fail) | 2 runs | stdout identical; stderr identical modulo one backtrace line number (`[1] _run …:489` → `:494`); the `[0] _fail` frame is preserved — no `_quit_clean` frame appears, so the r85 VE attribution objection does not apply |
| unknown-child-arm exit (`--child --arm=bogus`) | 2 runs | byte-identical (rc 2) |
| `_child_size` exit (`--child --arm=size_probe`) | 2 runs | byte-identical (rc 0) |

### 4.4 Tradeoff

SP2 is the only candidate that improves **both** weight axes at once, and
it single-sources an invariant 15 hand-copied tails enforce. The cost is
blast radius: it rewrites every exit in the file, including the pinned
r83–r85 arms, and its win is small in bytes (−185) — the line win (−29) and
the convention win are the real currency. The r84 V2 fold (−318 B, net
−1 line, 39-line diff, "justification is the single-sourced invariant, not
the byte count") is the precedent for admitting that shape; the r84/r85
rejections were about *deleting* cleanups or moving `_fail` out of the arm,
neither of which this does. **PROPOSE, optional** — an adjudicator that
prefers the smaller diff can take SP1 alone; SP1 and SP2 are disjoint
(`v3` = both, −817 B / −18 lines, replayed at
`runs/v3/20261014T210629604223Z`: 195/195 PASS, 11-field rows 0/195,
prior-191 191/191 at identical positions, same 3 line-number-only child-log
diffs).

---

## 5. Preserved contract

Under `v1`, `v2` and `v3`, all of the following are unchanged:

- 195/195 markers and exit codes (149 ordinary, 46 negative controls),
  empty stderr on every case, `seeds_unchanged=true` before/after.
- The 4 new r86 markers verbatim (`script_size_gate min_thr=refused …
  child_exit=0`, `deferred_hang threaded_rc=137 …`, `backend_tier
  plain=honors jolt=ignores dummy=floor …`, `dummy_floor … real_errs=2`).
- The 15 generated child projects' `project.godot` bytes (15/15 identical
  under SP1) and every child verdict map (`sz_*`, `hang*`, `tier*`,
  `floor*`, `jt_*`), the refusal-line counts, the hang's rc 137 / no-marker
  class, the Dummy floor signature and the real-backend refusal pair.
- The BLOCKED, red and bail paths (A/B, §4.3), the "every exit path cleans
  up" invariant, and the `_fail`/`_exit_ok` public shape.
- Every provenance comment: no comment is deleted by either candidate;
  SP1 adds one two-line note, SP2 adds one four-line note.

---

## 6. Stop condition and residual risks

- The next deletions available are the `_child_tier` retry bail, the
  `_backend_name` floor, and the `_child_split` guard copy — each removes a
  named bail or a total-function floor, i.e. diagnosis on a path the
  receipts cannot see. That is the stop: **the next deletion would harm the
  falsifiability axis.**
- SP1's +11 lines are real; if the round scores lines as an axis, SP1 is a
  byte win bought with lines and the single-sourcing argument (r84 V2
  precedent), not a pure weight win.
- SP1 and SP2 shift GDScript backtrace line numbers in 3 (SP1) / several
  (SP2) pinned child logs; the placement note in §2.3 removes SP1's churn
  entirely if the adjudicator wants zero normalization.
- The stochastic band (~475–575 lines) and `HANG_BOUND_S = 8` are untouched
  and untested by this seat: no candidate here re-pins a band point, and
  both candidates leave the size-gate and hang cells byte-identical
  (verified in the 4 new rows' markers and their child logs).
- The seat ran under a concurrently-loaded host (sibling lanes were running
  the battery in the shared tree); the two invalidated v2 runs are disclosed
  in §1 rather than deleted, and the receipt of record is a serial run.

---

## 7. Receipts

All under `corpus/live/r86-simplifier/` (gitignored), 229 files pinned in
`manifest.sha256`:

| artefact | what it is |
|---|---|
| `variants/{base,v1,v1b,v2,v3}-phys3d_events.gd` | the five fixture trees; shas `66c92c38…` (base = committed blob), `25eeba03…` (SP1), v1b = SP1 end-placement, `5aa8e77e…` (SP2), `ec00f175…` (SP1+SP2) |
| `runs/control/20261014T203953716461Z/verdicts.json` | unmodified-tree control, 195/195, seed sha = the committed blob |
| `runs/v1/20261014T204340840862Z/verdicts.json` | SP1 full replay, 195/195 |
| `runs/v2/20261014T205855600118Z/verdicts.json` | SP2 full replay, 195/195 |
| `runs/v2/SUPERSEDED-gamepad-flake{,-2}/verdicts.json` | the two flake-hit v2 runs, kept for audit |
| `runs/v3/20261014T210629604223Z/verdicts.json` | SP1+SP2 full replay, 195/195 |
| `cmp_sp1.txt`, `cmp_v2.txt`, `cmp_v3.txt` | 11-field/deep row + child-log comparisons vs control |
| `ab/` | the red/BLOCKED A/B stdout/stderr/rc files for `base` and `v2` |
| `tools/fold_census.py` | the 13-literal byte-equality census |
| `tools/mk_sp2.py`, `tools/compare_receipts.py`, `tools/ab_paths.sh` | the builders used above |

Every run's `seed_digests` records which tree it measured, so a receipt can
never be read against the wrong bytes.

---

## 8. Provenance of this seat's writes and of the moved tree

| fact | evidence |
|---|---|
| this seat edited no tracked file | its writes are exactly: `/tmp/r86sim/**` (scratch trees, builders, run dirs), `corpus/live/r86-simplifier/**` (gitignored receipts), `reports/round-86/r86-simplifier.md` |
| HEAD at seat start / at seat end | `4e65726` (audited revision, blob `66c92c38…`) → `dd1737ac` (`r86 fold: simplifier SP1+SP2 + critic A1-A5`, blob `4b539a12…`), committed by the sibling fold lane, not this seat |
| the committed fixture bytes this seat measured | `git show 4e65726:corpus/fixtures/phys3d_events.gd` = `66c92c38…` = the `base` tree = the control receipt's `seed_digests` |
| the tree moves | fixture mtime `18:04:38` local then commit `18:12:04` local; `git status` clean against `dd1737ac` apart from untracked reports |
| the landed fold is this seat's shape | the committed `_quit_clean`/`_project_body` text (helper + comment) is byte-identical to `v3`'s; the delta is exactly the critic corrections listed in the provenance note |
| the landed tree was replayed by its applier | `corpus/live/runs/20261014T210445883434Z/verdicts.json`: 195/195 PASS, `seed_digests.phys3d_events.gd = 4b539a12…`; commit message records the same verification |

This seat did not verify the landed tree's critic corrections — they are
outside its candidates and are the applier lane's (and the verifier's)
evidence, not this seat's.
