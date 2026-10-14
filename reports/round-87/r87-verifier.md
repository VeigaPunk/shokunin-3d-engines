# game-dev-3d round 87 — verifier (seat: verifier, host: devin) — independent re-derivation of `c57fa40`

Wave `shokunin-train-20261101-w19`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w19/tasks/g3d-r87-verifier.md`, verbatim):

> Independent verdict on c57fa40: re-derive every row's receipt fields
> from the raw stdout/stderr; check insertion-only (prior 195 rows at
> identical positions), all 6 arms' witness pins present and honest,
> crash-row classification, and the two deliberate disjunctions
> (rc {134,137}, Jolt two crash modes). AGREE/DISAGREE per claim.
> Report -> reports/round-87/r87-verifier.md.

**Verdict: AGREE on every load-bearing claim — independently reproduced
201/201 with all four probes on my own battery run of the committed bytes,
all 201 rows byte-identical to the author's `runs-final` receipt over 12
fields plus scratch-normalized `command`, prior 195 rows byte-identical to
the r86 post-commit reference at identical positions, all six arms' witness
pins re-derived from the raw child logs (not the markers), both deliberate
disjunctions reproduced first-hand (rc 134 at the 6 s bound and rc 137 at a
1 s bound; Jolt's `std::system_error` throw 3/3 on the author's probe shape
and the signal-11 handler on every fixture child), and the mutation harness
re-run by me: 6/6
detected. Three minor prose/count slips are noted (a +880-vs-+876 diff
count, a 4/4-vs-5/5 callback tally, and the freed-space prose that
generalizes the Jolt crash locus to GodotPhysics); none touches a pin.**

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, GodotPhysics3D /
Jolt Physics / Dummy on this host (32 cores). Verified commit
`c57fa40c3b560b8f26e13231eb8b90e4c4ab8526` (HEAD). Verified bytes =
committed bytes, and the worktree carries no uncommitted fixture edit:

    sha256sum corpus/fixtures/phys3d_events.gd corpus/fixtures/run_battery.py \
              corpus/fixtures/README.md
      0e5e64f42e99652fadedaf1459278e5d7a460ef9b9341c3aac34d8661f2f0d12  phys3d_events.gd   (2752 lines)
      45b1ea867259cbb5ff452652e1ace62602ee59215e0f251e202714cccc2f6083  run_battery.py     (201 CASES)
      45ec89a2166af0ee7ab82862675461bdb5c420a47ad433a88236eb109188dd5e  README.md
    git status --porcelain corpus/                -> empty
    git rev-parse HEAD                            -> c57fa40c3b560b8f26e13231eb8b90e4c4ab8526

All three match the author report §10's declared submission shas exactly.

**LSP unavailability recorded (per seat card).** No `lsp` device is exposed
on this host and no LSP binary is on `PATH` (same recorded absence as the
r85/r86/r87 sibling lanes). No symbol-aware operation was needed: this seat
re-derives landed behavior — the semantic check that replaces a server here
is Godot's own GDScript compiler and the battery's ERROR/SCRIPT-ERROR scan,
which classify any misspelled or unresolved name as a row failure.

---

## 0. Claim table

| # | claim (author `r87-author.md` / the brief) | verdict | one-line evidence |
|---|---|---|---|
| 1 | insertion-only: prior 195 rows byte-identical at identical positions | **AGREE** | 12 fields × 195 rows + scratch-normalized `command`, **0 mismatches** in all three author receipts vs the r86-post reference — and in **my own** battery run vs that same reference (0 mismatches); `git show` on `run_battery.py` = +14/−0 |
| 2 | six rows appended at the tail (195→201), crash row last | **AGREE** | receipt order: `body_handle, acq_use, step_stamp, write_loss, body_tier, freed_space` at positions 196–201; `freed_space` is the last tuple before `CASES` closes (`run_battery.py:469–471`) |
| 3 | 201/201 PASS ×3, `seeds_unchanged=true`, ordinary=155 negative=46 | **AGREE** | all three author `verdicts.json` re-read: PASS, 201/201, totals identical; plus baseline's post-commit run and **my own run** = five independent 201/201 receipts; 55/55 `seed_digests` match `HEAD` blobs (re-hashed by me) |
| 4 | all 201 rows deterministic run-to-run | **AGREE** | author run1↔run2↔final: 0 mismatches × 12 fields + command; my run ↔ `runs-final`: **0 mismatches over all 201 rows** |
| 5 | new-row receipt fields honest (marker = exact stdout line, exit 0, stderr empty) | **AGREE** | all six rows: `actual_exit=0`, `kind=ordinary`, `error=null`, `stderr=[]`, `reasons=[]`, marker is an exact line of `stdout` — re-derived field by field |
| 6 | `body_handle` identity law + Dummy floor | **AGREE** | raw `CHILD_RESULT`s in `bhplainproj`/`bhjoltproj`/`bhdummyproj` `child.log` equal the expected dicts token-for-token (8 keys each); Dummy: `ss=0/0`, `if_fired=false`, `detach=obj` |
| 7 | `acq_use`: fetch refused out-of-phase, held handle ungated, threading witness | **AGREE** | both children: exactly **8** engine `ERROR: Body state is inaccessible` lines (`godot_physics_server_3d.cpp:952` / `jolt_physics_server_3d.cpp:969`, backtraced to `_child_acq_use:2498`), then `reps=8 out_of_phase=8 refused=8 live=8 same_turn=8 persist=8` |
| 8 | `step_stamp` per-backend pins incl. the Jolt pre-solve refinement | **AGREE** | `ss_plain`: `pre=0.0010000000475/zero/0.0`; `ss_jolt`: `pre=0.0/real/0.10000000149012`; `cc 0→4`, `last_step=4,0` — all match the expected dicts; scout's own `ph_proj_jolt.stdout.txt` independently shows `A.get_total_gravity -> (0.0, -9.8, 0.0)` at pre-solve position A |
| 9 | `write_loss`: accounted tally, `race=bounded`, scout loss not reproduced | **AGREE** | every retained wl log shows `landed=8 lost=0 rows=[8×"T>true"]` (4 battery/focused `wlproj` runs + `fxcheck/wlproj` + `thr_wloss` probe); the scout's loss is real evidence (`fl_proj_thr.r1` `SLEEP srv_sleeping=false` vs r2 `true`); the row never claims a loss |
| 10 | `body_tier`: impulse zero/real @ first in-contact step, `lshape_oob` −1/0/absent, `sleep_lv` kept/zeroed/flat, detach refusal 0/1/0 counted in raw log | **AGREE** | `bt_plain` `first_i=12 cc=4 impulse=-0.000000000×3`; `bt_jolt` `first_i=12 impulse=-0.006821907,0.647047877,0.013493819`; my own counts: `Failed to apply central impulse` = 0/1/0 across the three raw logs; the two refusal texts (`(body->contact_count = 4)` vs `((int)body->get_contact_count() = 4)`) differ verbatim as claimed |
| 11 | `freed_space`: GP+Jolt hard crash, no marker; Dummy `{}` rc 0 | **AGREE** | 8 child logs inspected (author ×3, focused, fxcheck, baseline, mine ×2): `handle_crash: … signal 11` exactly once, `CHILD_RESULT` **zero** on both crashers every time; `fs_dummy_ray=empty` rc 0 |
| 12 | disjunction 1 — `rc ∈ {134,137}` with a second witness | **AGREE** | code requires 134 or 137 **and** `verdicts` empty **and** the engine line =1; I reproduced **both** rcs on the committed bytes: rc **134** at the landed 6 s bound (handler completes → `abort`), rc **137** at a 1 s bound (SIGKILL mid-dump), the `handle_crash` line present in both |
| 13 | disjunction 2 — Jolt crash mode ∈ {`std::system_error`, signal-11 handler}, exactly one | **AGREE** | fixture child: handler mode in all 8 observed runs; **`std::system_error` mode reproduced first-hand by me** — author's `btier.gd --arm=crash` under Jolt: `terminate called … what(): Invalid argument` + dumped core, rc 134, 3/3 (`r87-verifier/jtc/run{1,2,3}.log`); also in the raw evidence `runs/jolt_crash/child.log` and scout's `fr_proj_jolt.stdout.txt`; code requires `throw + segv == 1` plus empty verdicts plus signal-class rc |
| 14 | `_spawn_child`: additive defaulted `allow_lines`; `allow_inaccessible` carve-out preserved; every pre-existing call site ≤6 positional args | **AGREE** | the only non-insertion edit is 4 deleted lines (signature + inline ERROR predicate) replaced by `allow_lines := []` + `_error_allowed` whose first branch is the old carve-out verbatim; old call sites pass 4 args, `_spawn_probe` passes 6 — `allow_lines` is always `[]` on old paths, and the byte-identical 195/195 proves no behavior moved |
| 15 | `_log_count` counts engine signature lines in the raw log; −1 is a named failure | **AGREE, with a wording caveat** | the counts are real (verified against the logs); the comment's "a self-print cannot manufacture" is loose — `child.log` is a merged 2>&1 stream, so a literal `prints()` of the token would be counted; the actual guarantee is parent-side counting of the raw stream instead of trusting `CHILD_RESULT` claims, which is what the gates use |
| 16 | mutation matrix 6/6 load-bearing | **AGREE** | re-ran `mutations.py` myself: **6/6 detected** (M1 reps, M2 live-space, M3 late-impulse, M4 no-optin, M5 no-detach, M6 in-phase write) |
| 17 | siblings untouched and green: bpy 83/83 sha `6a98c570…`; three.js 31/31 `seedsUnchanged` | **AGREE** | `bpy-final/bpy-20261014T214816011070Z`: 83/83, `probe.stdout.txt` sha256 `6a98c570…defc3` (re-hashed); six `three-final-*.json`: 3+4+9+5+5+5 = 31/31, `seedsUnchanged=true` each |
| 18 | three tracked files, nothing else | **AGREE** | `git show --numstat`: `README.md` 90/0, `phys3d_events.gd` 876/4, `run_battery.py` 14/0, plus the report file itself |
| 19 | the report's own numbers | **MOSTLY AGREE, two slips** | `+880/−4` for `phys3d_events.gd` is actually **+876/−4** (numstat and `grep -c '^+'` agree); `ss_same` prose "4/4 ticks" vs the log's **`ss=5/5`** (4 awaited frames + one extra sync — the gate is `fired>0 and fired==same`, satisfied either way); bpy called "the 10th identical receipt" while the baseline's own enumeration makes it the 12th |
| 20 | freed-space mechanism prose | **AGREE on the class; DISAGREE on one mechanism detail** | §6 "gets `held.get_space_state()` — which still answers — and calls `intersect_ray`" is the **Jolt** path verbatim (`space=` prints, then the crash at `intersect_ray`). On **GodotPhysics** `get_space_state()` never answers — the SIGSEGV fires *inside the call itself*: every GP backtrace lands on the `var sp = held.get_space_state()` statement (HEAD line 2739; pre-freeze copies read 2735, fxcheck's 2700 — same statement, comment-drifted numbering), while every Jolt backtrace lands on `intersect_ray` (HEAD 2745; copies 2741/2706), and the scout's `fr_proj` shows the same split (`freed.gd:105`). The pinned class (crash, no marker, engine line, signal rc) is unaffected — but "which still answers" is not true on GP |

---

## 1. My own battery runs (the ×2 standard)

Three full batteries from the committed bytes under
`corpus/live/r87-verifier/`:

| run | `--runs` path | result |
|---|---|---|
| v1 `runs/20261014T223245010923Z` | **relative** | 201/201 cases PASS, probes 3/4, battery FAIL |
| v2 `runs/20261014T223734566225Z` | **relative** | 201/201 cases PASS, probes 3/4, battery FAIL |
| v3 `runs-abs/20261014T224349463988Z` | **absolute** | **201/201 PASS, probes 4/4, battery PASS, exit 0** |

The two FAILs are the documented `--runs` contract, not a flake and not an
r87 defect: `run_battery.py:16–19` declares the tree-timeout witness probe
verifies the child's `/proc` cmdline **verbatim and absolute**, so a relative
`--runs` makes `witness_verified` deterministically false (both my failing
verdicts show exactly that signature: `timed_out=true marker_observed=true
witness_verified=false`, then the still-live detached witness holds the
inherited pipes open so "Godot cleanup exceeded 3 seconds"). With an
absolute `--runs` the identical byte stream passes 4/4 probes. All 201 case
rows — the seeded surface — passed identically in all three of my runs, so
even the FAILed receipts carry full case-level evidence.

Cross-run identity (12 fields `case, script, flags, expected_exit,
actual_exit, error, kind, marker, verdict, reasons, stdout, stderr` plus
`command` normalized for the per-run scratch path — one field more than the
author's comparator):

- my v3 vs author `runs-final`: **201/201 rows, 0 mismatches**
- my v3 vs r86-post reference, first 195 rows: **0 mismatches**
- author run1↔run2↔final: 0 mismatches each pair

## 2. Receipt-level re-derivation of the six new rows

For each new row in `runs-final/…/verdicts.json` (and re-confirmed in my own
run): `actual_exit=0`, `error=null`, `stderr=[]` (empty), `reasons=[]`,
`kind=ordinary`, and the `marker` string is an exact line of the captured
`stdout` list — i.e., the receipt's recorded stdout literally contains the
expected marker text, so the PASS is not a classification artifact. Wall
clock on the new rows: 1.72–5.49 s across four runs (author cites
"1.99–5.49" which is run-1's range; the sweep-wide minimum is 1.72 — under
the 20 s `case_timeout_seconds` in every observation).

## 3. Witness-pin honesty, per arm, from the raw child logs

The marker is only the parent's summary; the actual gates compare
whole-dict `verdicts` or individually-asserted fields plus `_log_count`ed
engine lines. Raw-log findings:

- **body_handle** — `bhplainproj`: `ss=5/5` (the sync callback fired 5 times
  and saw the same object 5 times; the author's "4/4 ticks" understates by
  one — 4 awaited frames plus one extra tick-sync; gate `fired>0 &&
  fired==same` satisfied). `if_refetch=true`, `detach_nil=true`,
  `held_live=true`, `reattach_same=true`, `twin=true`, `two_fetch=true` —
  all literal in the NOTE/RESULT lines. `bhdummyproj`: `if_fired=false`,
  `ss=0/0`, `detach=obj` — the Dummy floor is real, and the row is not
  armed as a hazard detector (scout directive 8).
- **acq_use** — each child printed exactly **8** engine
  `ERROR: Body state is inaccessible` lines with backend-typical
  `at:` paths and backtraces to `_child_acq_use:2498` (the fresh fetch), one
  per refused rep; then `refused=8 live=8 same_turn=8 persist=8`. The
  `allow_lines` admission is what lets these expected witnesses through
  `serr` — honest, because the same lines are the counted witness class.
- **step_stamp** — `ss_plain`/`ss_jolt` verdict dicts equal the expected
  maps token-for-token, including the Jolt refinement
  (`jolt_grav_pre=real`, `jolt_damp_pre=0.10000000149012` vs GP's
  `zero`/`0.0`); the scout's own `ph_proj_jolt.stdout.txt` shows the same
  pre-solve real values, so the refinement corrects the summary while
  agreeing with the scout's raw data.
- **write_loss** — `wlproj`: `reps=8 refused=8 same_turn=8 landed=8 lost=0
  rows=["0:T>true"…"7:T>true"]`. Zero loss in every retained run (the
  author's "18 child runs / 144 writes / four forms" is not fully retained
  on disk — the retained subset covers 5 wlproj logs + `thr_wloss` + the
  fxcheck sweep, all `lost=0`; nothing contradicts the larger count, and the
  row's pin — precondition + accounted tally — needs none of it). The
  scout's measured loss is separately real:
  `fl_proj_thr.r1.stdout.txt` ends `SLEEP srv_sleeping=false` where r2 reads
  `true`. Both halves of the author's framing hold.
- **body_tier** — `bt_plain`/`bt_jolt` both at `first_i=12`: GP impulse
  `-0.000000000,-0.000000000,-0.000000000` (the "zero" token is a
  `length() < 1e-6` classification of exactly-zero reads), Jolt
  `-0.006821907,0.647047877,0.013493819` — matching the scout's `mm_*`
  numbers to the printed precision. `btdummyproj`: `first_i=-1 cc=0` —
  Dummy never reaches the impulse read, hence `absent`/`flat`. The
  detached-impulse refusal is counted in the raw logs: `Failed to apply
  central impulse` = 0 (plain), **1** (jolt, `jolt_body_3d.cpp:924`, called
  from `phys3d_events.gd:2708`), 0 (dummy) — the claimed `silent,loud,silent`.
  The `gp_imp` probe log verifies the oscillation caveat: a 40-frame
  GodotPhysics series reads exactly `0` at steps 30 and 34 and
  `len=0.103033` at step 39 — the pin is correctly step-scoped.
- **freed_space** — eight observations inspected (author's three battery
  runs + focused run + `fxcheck` sweep + baseline's post-commit run + my
  direct spawn + my `runs-abs` battery): `fsplainproj` and `fsjoltproj`
  each carry exactly one `handle_crash: Program crashed with signal 11`
  line and **zero** `CHILD_RESULT` lines in every one of them;
  `fsdummyproj` carries exactly `CHILD_RESULT fs_dummy_ray=empty`, rc 0.
  GDScript backtrace loci: **GP = the `held.get_space_state()` statement
  (HEAD `phys3d_events.gd:2739`; 2735/2700 in earlier copies), Jolt =
  `sp.intersect_ray(q)` (HEAD 2745; 2741/2706)** — see claim 20.

## 4. The two deliberate disjunctions — independently reproduced

On the committed fixture bytes, spawning the children exactly as
`_spawn_child` does (`timeout -s KILL N /usr/bin/godot --headless --path
<proj> --script <gd> -- --child --arm=<arm> > child.log 2>&1`):

- `fs_plain` @ 6 s bound: **rc 134**, 1 crash line, 0 results — the
  handler-completed path.
- `fs_plain` @ 1 s bound (×3): **rc 137**, SIGKILL mid-handler — the
  bound-cut path. The `handle_crash` line is emitted before the dump, so
  the second witness survives the kill: `kill{1,2,3}.log` each contain it.
- `fs_jolt` @ 6 s: **rc 134**, handler mode (`segv=1 throw=0`), 0 results.
- `fs_dummy`: **rc 0**, `fs_dummy_ray=empty`.
- Jolt throw mode: `r87-author/runs/jolt_crash/child.log` —
  `terminate called after throwing an instance of 'std::system_error'
  what(): Invalid argument` + `timeout: … dumped core`; the same mode is in
  the scout's `fr_proj_jolt.stdout.txt`. **Reproduced first-hand**: the
  author's `probes/btier.gd --arm=crash` under Jolt threw
  `std::system_error` → rc 134 in **3/3** of my own runs
  (`r87-verifier/jtc/run{1,2,3}.log`) — the smaller probe heap takes the
  throw path where the fixture's larger child takes the handler. The
  gate's `throw + segv == 1` is the honest form of a genuinely
  heap-layout-dependent mode.

Both disjunctions carry the required second witness (engine line count ==
1, verdicts empty), so neither can be satisfied by a clean exit or a quiet
fail.

## 5. Harness change review (`_spawn_child`, `_error_allowed`, `_log_count`)

- The signature edit is the only non-insertion: `bound_s := 30` gains
  `, allow_lines := []` and the three-line inline ERROR predicate becomes
  `_error_allowed(line, allow_inaccessible, allow_lines)`. All pre-existing
  call sites pass ≤6 positional args (`_spawn_probe` passes 6, arm calls
  pass 4), so `allow_lines` is `[]` everywhere it isn't explicitly set —
  and the byte-identical prior-195 stdout/stderr across five receipts
  proves no observable moved.
- `_error_allowed` preserves the `allow_inaccessible` → `"Space state is
  inaccessible"` carve-out verbatim as its first branch.
- `allow_lines` matches by **substring**: `"Index p_contact_idx"` admits
  both backends' differently-worded out-of-range refusals (verified: GP
  `(body->contact_count = 4)` vs Jolt `((int)body->get_contact_count() = 4)`)
  and `"Failed to apply central impulse"` admits Jolt's detached-impulse
  refusal. Substring admission is slightly wider than exact-line matching —
  acceptable here because each admitted class is also *counted* where the
  count matters (the `loud` table).
- `_log_count` returns −1 on an unreadable log (named failure, not silent
  zero). Caveat on its doc-comment, recorded above at claim 15: the merged
  2>&1 log can in principle carry a child `prints()` of the token, so
  "cannot manufacture" overstates; the genuine property is that the count
  is a parent-side read of raw engine bytes, independent of the child's
  `CHILD_RESULT` claims. Nothing in the landed children prints any admitted
  token.

## 6. Minor notes (none pin-level)

1. `+880/−4` in the author report §0/§10 vs actual **+876/−4**.
2. `ss_same` prose "4/4 ticks" vs measured **`ss=5/5`**.
3. The GP freed-space crash is inside `get_space_state()` (2739), one call
   earlier than the prose's "still answers → `intersect_ray`" — accurate
   for Jolt and Dummy only. The scout's GP receipt shows the same locus
   (`freed.gd:105`), so this is a real backend difference in *where* the
   class fires, worth a comment touch-up next round rather than a gate
   change.
4. `child_exit=0` on the `freed_space` marker follows the file's
   convention (the case/parent exit — cf. `deferred_hang`'s
   `threaded_rc=137 … child_exit=0`), but on a row whose two children exit
   134 it can be misread; `deferred_hang` already shows the better
   convention of naming per-child rcs in the marker.
5. bpy "10th identical receipt" — the baseline's own enumeration makes the
   author's run the 12th identical stdout sha; the sha itself
   (`6a98c570…defc3`) is verified identical.

## 7. Receipts / scratch used

- Author: `corpus/live/r87-author/{runs-battery,runs-battery2,runs-final,
  runs-only87}/*/verdicts.json` + `*/scratch/*proj/child.log`,
  `runs/{gp_crash,jolt_crash,fsbound,fstime,gp_imp,thr_wloss,thr_acq,
  jolt_thr_acq,*_identity}/child.log`, `fxcheck/*proj/child.log`,
  `mutations.py` (re-executed: 6/6), `prior_rows.py`.
- Baseline: `corpus/live/r87-baseline/runs-post/20261014T215119929090Z/`
  (4th independent 201/201; its fs children show the same crash signature).
- Scout: `corpus/live/r87-scout-dss/runs/{fl_proj_thr.r1,fl_proj_thr.r2,
  fr_proj,fr_proj_jolt,ph_proj_jolt}.stdout.txt`.
- Mine: `corpus/live/r87-verifier/{runs,runs-abs}/*/verdicts.json` +
  `scratch/*proj/child.log`, `fsv_{plain,jolt,dummy}/child.log` +
  `fsv_plain/kill{1,2,3}.log` (the rc-137 reproductions),
  `jtc/run{1,2,3}.log` (the Jolt `std::system_error` reproductions),
  `battery-v*.log`.
- Reference: `corpus/live/r86-baseline/runs-post/20261014T203735129154Z/
  verdicts.json` (the prior-195 baseline, 12 fields + normalized command).

## 8. Remaining risks

1. All measurements are one host, one build (`4.7.2.stable.arch_linux
   .ed1daf0bf`), 60 tps, `--headless`.
2. The write-loss *class* remains witness-level (scout r1 receipt real;
   0-loss in every bounded form). The row's `race=bounded` marker is a
   claim about the observation, not about a loss rate — correctly scoped.
3. Jolt's crash mode is characterised, not explained (author's own words,
   confirmed here).
4. The `tree-timeout` probe FAIL on a relative `--runs` is documented
   behavior, but it costs a full battery to learn — two of my runs were
   spent that way; future seats should take the docstring literally.
5. The GP-vs-Jolt crash-locus difference (claim 20) is documented nowhere
   in the fixture comments — only the class is pinned, which is the right
   scope; a future reader of the prose may still expect `space=` to print
   on GP.

**Seat output complete.** Read-only verification; no commits, no pushes, no
fixture or contract edits; the only runtime invoked was the fixture battery
and direct `godot --headless` child re-executions of the committed bytes.
