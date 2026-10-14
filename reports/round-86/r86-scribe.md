# game-dev-3d round 86 — scribe report (seat `scribe`, host: devin) — r85 ledger audit

Wave `shokunin-train-20261101-w17`, lane g3d. Seat card verbatim (dispatch
brief `tasks/g3d-scribe.md`):

> r86 SCRIBE (g3d) — r85 ledger audit
> Re-derive r85: 191 verdicts vs raw child logs/maps; the tuple-sha claim
> (efb81318) reproduces; fold commit deltas match declared set exactly;
> adjudicator cites resolve (all 8 seat reports exist now); r84-scribe's
> 12-vs-11 correction chain verified. reports/round-86/r86-scribe.md.

This seat does not implement, judge, edit fixtures, commit, or re-run the
battery. It re-derives the r85 ledger from the landed receipts' own bytes and
resolves every digest/citation against the tree at HEAD `3d42f77`.

## Behavior (what this seat did)

1. Read `SHARED.md`, the brief, the wave-16 registry/spec/tasks, all ten
   landed r85 reports (9 seats + adjudicator), `r84-scribe.md`, the r85
   fixture and runner at HEAD, and the wave-17 spec/brief.
2. Ran two read-only audit tools (no Godot invocation, no battery re-run):
   - `r86s_audit.py` — tuple-sha over every 191-row receipt; per-row verdict
     re-derivation from the receipt's own bytes with the HEAD
     `run_battery.py:497-524` `classify` mirror; child-map re-derivation from
     the raw child-log `CHILD_NOTE` fields with the HEAD `_child_split`
     predicates (`phys3d_events.gd:1025-1262`); child-log census.
   - `r86s_checks.py` — first-188 prefix identity vs three frozen 188-row
     receipts; pre-fold-vs-folded `LEAKED_OBJECTDB` regex neutrality;
     per-arm path-normalized child-log census; fold-hunk classification.
3. Verified every artifact digest the r85-scribe published (12/12 resolve).
4. Bracketed sibling state: HEAD `3d42f77`, `git status --porcelain` empty
   before and after; `reports/round-86/` already held the three r86 scouts;
   the live `r86-baseline` lane wrote a new 191-row receipt
   (`corpus/live/r86-baseline/runs/…200631955691Z`) during the audit — it is
   included in every census below, and the tree is otherwise unchanged.

## Audit answers

### 1. 191 verdicts re-derived from raw bytes — 2101/2101 rows, 0 mismatches

Eleven landed receipts carry the 191-row battery (the r86-baseline post-fold
run appeared in the tree during this audit and is included); each row's
verdict **and** reasons were recomputed from that receipt's own
`stdout`/`stderr`/`actual_exit` using the classifier as written at HEAD
(`classify`, `run_battery.py:497-524`):

| receipt (run dir) | rows | re-derived clean | kinds | battery verdict | phys3d seed |
|---|---|---|---|---|---|
| `r85-author/runs/…192404847004Z` | 191 | 191 | 145 ord / 46 neg | PASS | `4bcde2bf` (f230443) |
| `r85-author/runs/…192747715686Z` | 191 | 191 | 145/46 | PASS | `4bcde2bf` |
| `r85-baseline/runs-post/…193334590923Z` | 191 | 191 | 145/46 | PASS | `4bcde2bf` |
| `r85-reviewer/runs/…193426106570Z/…193426134676Z` | 191 | 191 | 145/46 | PASS | `4bcde2bf` |
| `r85-simplifier/runs/VD/…194304816352Z` | 191 | 191 | 145/46 | PASS | `6ea03112` (variant) |
| `r85-simplifier/runs/VE/…194005413123Z` | 191 | 191 | 145/46 | PASS | `3e88b36b` (variant) |
| `r85-simplifier/runs/VS/…194825627054Z` | 191 | 191 | 145/46 | PASS | `b6a7e484` (variant) |
| `r85-verifier/runs/…193427386137Z` | 191 | 191 | 145/46 | PASS | `4bcde2bf` |
| `r85-verifier/runs/…193753739226Z` | 191 | 191 | 145/46 | PASS | `4bcde2bf` |
| `runs/…195459710695Z` (folded seeds, pre-commit) | 191 | 191 | 145/46 | PASS | `23bb2e27` (4e6fbe3) |
| `r86-baseline/runs/…200631955691Z` (folded seeds, post-commit) | 191 | 191 | 145/46 | PASS | `23bb2e27` (4e6fbe3) |

- `CASES` at HEAD parses to **191 rows = 145 ordinary + 46 negative**, tail
  exactly the three r85 cells (`jolt_threaded`, `dummy_refused`,
  `srv_phase_delta`, `run_battery.py:443-448`); the 15 `phys3d_events` rows
  map 1:1 onto the 15 fixture arms.
- Battery-level verdict re-derived (`fail==0 and seeds_unchanged and four
  probes`) = PASS in all eleven; `godot_version` =
  `4.7.2.stable.arch_linux.ed1daf0bf` in all eleven.

**Child maps (the raw maps behind the four child rows).** 44 checks
(11 receipts × 4 arms), **0 mismatches**. For each: the classes re-derived
from the child log's own `CHILD_NOTE` fields == the log's `CHILD_RESULT`
lines == the parent marker's claimed classes:

| arm | re-derived from raw fields | log lines | verdict |
|---|---|---|---|
| `jolt_edge` | `same-signature / differs-constants / differs-constants / same-signature / inverts`, `backend=Jolt Physics` | 7 keys, `2f9900fd…` | 11/11 match |
| `jolt_threaded` | same map + `jt_threaded=true` | 8 keys | 11/11 match |
| `dummy_refused` | `unexpected ×5`, `backend=Dummy`, `dss=PhysicsDirectSpaceState3DDummy` | 7 keys, `b7ecd80a…` | 11/11 match |
| `threaded_edge` | last `CHILD_RESULT` == pinned `pp_edge0=true proc_dss_refused=true srv_ok=true` | 48-line log | 11/11 match |

The `jolt_threaded` witness is a *measured* 11/12: 11 refusal blocks
backtraced `[0] _child_jolt_threaded (…:1004)` + 1 backtraced
`[0] _child_split (…:1028)`, then `CHILD_RESULT jt_threaded=true`
(≥8 of 12). The raw constants the adjudicator cites reproduce from the logs:
`safe=0.149841 unsafe=0.150024`, `t0=-0.998535`, `set=0,1 in=0,1,4 out=4,0`.

**`srv_phase_delta` has no child log** (parent-only cell). Its raw frames are
not in the receipt; the only landed raw-frame evidence is the verifier's
instrumented probe `corpus/live/r85-verifier/probe_proj/rep{1,2,3}.out`
(3/3 byte-identical, sha `7b511ab0…`: `PROBE_A proc f0=5 w0=0 n1=0 n2=1`,
`PROBE_B exit fexit=7`, `PROBE_C phys f1=13 p0=0 p1=1` → proc delta 2 /
phys delta 1). This seat read those receipts; it did not re-run the probe.

### 2. Tuple-sha claim `efb81318…` — reproduces, 11/11 receipts

`efb81318804621389dd5a1bfe0cb0226d1ec3988652d02bb475ec6e777604e6d`
(verifier serialization: `(case, verdict, actual_exit, marker)`,
`\x1f`-joined, `\x1e`-terminated) is the sha of **all eleven** 191-row
receipts above — the four the adjudicator names (author ×2, reviewer,
verifier ×2, integrator) **plus** `r85-baseline/runs-post`, the three
simplifier variant runs, and the post-commit `r86-baseline` run.

- **First-188 prefix:** every one of the eleven receipts is field-identical
  (`case`, `verdict`, `actual_exit`, `marker`, `stdout`, `stderr`) to **all
  three** frozen 188-row receipts the verifier used — `r85-baseline/runs/
  …182310632331Z`, `r84-verifier/runs/…175211547739Z`,
  `r84-verifier/runs2/…175525729401Z` — **0 differing fields across
  11 × 188 × 6 × 3 comparisons**.
- **Full 191 rows:** author ×2, verifier ×2, the pre-commit folded-seed run
  and the post-commit `r86-baseline` run are field-identical to each other
  (0 diffs), so the fold moved no row and the pre/post-fold receipts are the
  same case stream.
- **Count discrepancy (verbatim, for the judge):** the adjudicator writes
  "191/191 PASS across author×2, reviewer, verifier×2, integrator — **four
  independent executions** hash to the same tuple sha" (`r85-adjudicator.md:
  29-31`), and `LOG.md` writes "191/191 **x4** executions identical tuple
  sha". The six receipts named exist and share the sha; the tree held **ten**
  at the adjudicator's bracket and holds **eleven** now. "Four" undercounts
  the landed evidence and does not match the six receipts listed in the same
  sentence.

### 3. Fold commit deltas vs the declared set — exact, 5 hunks ↔ 4 declared items

`4e6fbe3` = **3 files, 5 hunks, +11/−12**. Hunk-by-hunk mapping to the
declared set (adjudicator §Corrections landed; seat reports):

| hunk | change | declared by | class |
|---|---|---|---|
| `README.md:5` | `188 registered cases (142 ordinary and 46` → `191 registered cases (145 ordinary and 46` | critic §9 #15, reviewer F1 | text, declared ("README 191/145") |
| `phys3d_events.gd @@ -962,14 +962,13 @@` | stale body-diff enumeration reworded (adds "plus jolt_threaded's pre-sweep witness loop + allow_inaccessible"; keeps the load-bearing "can never be a difference in the sweep code" claim) | simplifier S3 | **comment-only** |
| `phys3d_events.gd @@ -995,7 +994,7 @@` | `(r85 author probe: 12/12 null on Jolt+threaded…)` → `11/12` | simplifier S1 | **comment-only** |
| `phys3d_events.gd @@ -1029,7 +1028,7 @@` | `12/12 refusals in the author probe` → `10/10` | simplifier S2 | **comment-only** |
| `run_battery.py:469` | `ObjectDB instances were leaked` → `ObjectDB instances? (?:were\|was) leaked` | boundary §9 #5/B4, critic §9 #13 | regex, declared |

- The three `phys3d_events.gd` hunks are comment-only (verified
  programmatically: every changed line is a `#` line); no logic, no
  expectation map, no marker moved.
- **Every landed hunk is declared, and every declared landed item is a hunk.**
  No undeclared change exists in the commit.
- **Post-fold evidence exists and is honest:** the receipts whose seed
  digests equal the folded bytes are `runs/…195459710695Z` (191 rows, PASS,
  tuple sha `efb81318…`, first-188 identical to the frozen 188),
  `runs/…195449683745Z` (`--only` the three new arms, 3/3 PASS) — both
  stamped 19:54Z, i.e. working-tree runs of the folded bytes nine minutes
  *before* the fold commit (20:03:53Z) — and, post-commit,
  `r86-baseline/runs/…200631955691Z` (20:06:31Z, 191 rows, PASS, same tuple
  sha, same prefix identity). The fold message's "191/191 post-fold; prior
  188 rows tuple-identical to frozen reference" reproduces, and a wave-B
  seat has since re-executed the committed folded bytes.
- **Verdict neutrality of the regex fold:** re-running the classify mirror
  with the pre-fold regex vs the folded regex changes **0 rows** in all
  eleven receipts — the singular-leak blind spot was masked by the blanket
  stderr rule on every landed row, exactly as the boundary/critic findings
  state.
- Declared/open items **not** in the fold (consistent with the adjudicator's
  "recorded, not folded"): critic M6 (witness is a child self-report), critic
  #7 (`dummy_class` NOTE key misnamed), critic #14/boundary #7 (latent Dummy
  hazards at `:297`/`:944`), reviewer F3 (author §5.4 over-broad), verifier
  caveat (`jolt_threaded` log not byte-stable). Two open items are in
  *neither* list and remain open: critic §9 #4 (`allow_inaccessible` admits
  12 refusal lines, unbounded; suggested `jt_refusals=<n>` + band) and the
  critic's request for an r85 README section (only the count sentence
  landed).

### 4. Adjudicator cites resolve

`reports/round-85/` holds **10 files = 9 seat reports + adjudicator** at
`3d42f77`; the adjudicator cites **8 distinct seat reports** (author,
baseline, boundary, critic, reviewer, scribe, simplifier, verifier — the
r85-scout is cited inside author/critic/reviewer, not by the adjudicator).
Every cited content resolves:

| cite | resolves to |
|---|---|
| "first author seat died mid-landing on a rate limit with a parse-broken diff (`_child_jolt_threaded`/`_child_dummy` referenced, never defined)" | boundary §1 v1 (`9c99b306…`, "Parse Error: Function `_child_jolt_threaded()` not found"); registry `g3d-r85.author: a625e839(died:rate-limit)->completion:33a86f0f` |
| "all three cells CONFIRMED … four independent executions hash to the same tuple sha" | §2 above (identity holds; count discrepancy recorded) |
| "prior 188 rows at identical positions with stdout+stderr byte-identical (verifier checked wider than the author: three frozen receipts)" | §2 prefix check, 3 frozen refs × 11 receipts, 0 diffs |
| "threading invariance … map byte-equal to `jolt_edge` modulo prefix plus `jt_threaded=true`; raw constants identical" | map-line diff = exactly `+threaded=true` (13 shared lines identical); constants read from both logs |
| "same sweep under another real backend emits `same-signature ×5`" | critic M3 log `r85-critic/m3_dummy_no_engine_key/dummyproj/child.log` (`engine=DEFAULT`, `GodotPhysicsDirectSpaceState3D`, `same-signature ×5`, `backend=unexpected`) |
| "threaded DEFAULT → `backend=unexpected`" | critic `controls.json` `thr_only/jolt_threaded` (`jt_threaded=true`, `backend=unexpected`, `same-signature ×5`) |
| "mutation matrix 6/6 load-bearing (critic)" | critic §6 table (M1–M5 flip to named FAIL; M6 = documented limit) and §9 #8 "holds 6/6" |
| "forged child.log destroyed pre-run (verifier property test)" | verifier §5 (`0` FORGED lines post-run, marker still earned) |
| "baseline zero-drift both phases" | baseline §"Byte-stability summary" (bpy 83/83 + Godot 188/191, prior rows/ARM rows 0 drift, only the declared 2 seed files) |
| "scribe verified fold deltas exact" | r85-scribe §2 + finding 3 ("the fold moved nothing", 188/188 byte-identical; 12 published artifact digests re-verified 12/12 here) |
| "`LEAKED_OBJECTDB` singular … (boundary finding; masked by the stderr gate)" | boundary §9 #5/B4; critic §9 #13 |
| "falsified comment counts corrected to measured 11/12 and 10/10 (simplifier)" | simplifier §5 S1/S2; author §3.1 table ("11/12 refusals (not 12/12)", "refused, 10/10 reps") |
| "stale body-diff enumeration reworded; README 191/145" | simplifier S3; README hunk |
| "critic M6: `jt_threaded` is a child self-report" | critic §3/§9 #3 (forced-true child passes with key ablated) |
| "`dummy_class` CHILD_NOTE key is misnamed" | critic §9 #7; verifier §3a log line `CHILD_NOTE dummy_class=false …` |
| "reviewer F3: r85-author §5.4's 'Dummy silently hangs a threaded child' is over-broad" | author §5.4 (line 330) vs reviewer §"F3" (threaded Dummy + `_child_split` exits 0; rc-137 class is `_child_threaded`/`PPQueries`) |
| "verifier caveat: `jolt_threaded` child.log is NOT byte-stable … MAP is the stable witness" | verifier §8.1/§8.2 |
| "latent pre-existing: `_child_threaded`/`PPQueries` Dummy-type hazards (`:297`, `:944` per boundary)" | boundary §7 (lines 467-476, 505); reviewer §7 |
| "r86 frontier seeds (r86-scout + nas-scout + bpx-scout landed)" | `reports/round-86/{r86-scout,nas-scout,bpx-scout}.md` exist in `3d42f77` |

**Not verifiable from artifacts (declared, not confirmed):** "All wave-B seats
ran deepseek-flash" — the wave-16 spec's `model_mix.analysis` declares
`-ds deepseek-v4-1-flash-max` and the reports declare `host: devin`, but no
receipt or report carries a model identity; this seat records the claim as
declared-only.

**Ledger rows.** `LOG.md`'s r85 entry (added in `3d42f77`) matches the landed
move, the fold list, and the recorded list verbatim (its "x4 executions" and
the fold-correction phrase carry the discrepancies recorded below). The
`SCORECARD.md` row `| r85 | game-dev-3d | backend x threading | ADMIT-corr |
f230443 + 4e6fbe3 |` exists at HEAD and matches the adjudicator's verdict and
commits.

### 5. r84-scribe's 12-vs-11 correction chain

- **The claim:** `r84-scribe.md:276` — "preceded by 12 `ERROR: Space state is
  inaccessible right now…` lines". The file is **unchanged since `ac025b2`**
  (`git diff ac025b2 HEAD -- reports/round-84/r84-scribe.md` empty); the r85
  fold touched no report file.
- **The measurement:** every landed threaded child log (`thrproj/child.log`)
  has **48 lines and 11 `ERROR:` lines** — **31/31 receipts** from r83 through
  r86 (all eleven 191-row receipts plus the r83/r84 logs). The r85-scribe's
  11 reproduces; the r84-scribe's 12 does not.
- **The catch:** r85-scribe finding 7 + "Conflicts recorded verbatim" — it
  states the discrepancy and records it *for the judge*, explicitly "not
  reconciled" (the report is sealed; only a judge could supersede it).
- **The fold's own two count corrections are different instruments:**
  - S1 `:994` `12/12 null` → `11/12 null`: evidence = author §3.1/§5.2
    ("11/12 … not 12/12"), the commit message, and the receipt's 11 refusal
    ERRORs backtraced `_child_jolt_threaded:1004` (+1 from `_child_split`) —
    all three reproduce in the logs.
  - S2 `:1028` `12/12 refusals` → `10/10`: evidence = author §3.1
    ("refused, 10/10 reps") and the bounded retry behaviour.
- **Chain verdict:** the *catch* is the r85-scribe's (r84-scribe claim vs
  11-measured); the *correction landed* is on two r85 fixture comments whose
  "12/12" values came from the dead author seat's probe. The adjudicator's
  sentence "also caught an r84-scribe 12-vs-11 ERROR-count discrepancy —
  **corrected in the fold**" resolves for the fixture-comment counts and does
  **not** resolve for `r84-scribe.md:276`, which remains at HEAD exactly as
  written. Recorded verbatim for the judge; no reconciliation attempted here.

## Gates (measured by this seat)

- **Row gate:** 2101/2101 rows re-derived (verdict + reasons) across 11
  receipts; 0 mismatches; 145/46 kind split exact.
- **Prefix gate:** 11 receipts × 188 rows × 6 fields vs 3 frozen receipts =
  0 differing fields (33,264 comparisons).
- **Tuple gate:** `efb81318…` in 11/11 receipts (claim reproduces; "four"
  undercount recorded).
- **Child-map gate:** 44/44 re-derivations match both the raw log lines and
  the parent markers.
- **Fold gate:** 5 hunks ↔ 4 declared items, exact; 3/3 fixture hunks
  comment-only; regex fold verdict-neutral on 2101 rows.
- **Post-fold gate:** both 191-row folded-seed runs PASS with the same tuple
  sha (one pre-commit, one post-commit by `r86-baseline`); the 3-case
  folded-seed run PASSes 3/3.
- **Citation gate:** every adjudicator cite resolves; 12/12 r85-scribe
  artifact digests resolve.
- **12-vs-11 gate:** 31/31 threaded logs at 11 ERROR lines; r84-scribe claim
  contradicted, r85-scribe catch reproduced.
- **Not gates:** `srv_phase_delta` raw frames (probe receipts read, not
  re-run); model mix (declared only); BLOCKED branches and other unexercised
  paths (no receipt, as the r85 seats state).

## Findings

1. **The tuple-sha claim reproduces exactly** — one sha for all eleven landed
   191-row receipts, and the prior 188 rows are byte-identical (stdout +
   stderr) to all three frozen references in all eleven. The only defect is
   the count word "four" (adjudicator and LOG) against six listed / eleven
   landed receipts.
2. **The 191-verdict ledger is fully re-derivable from raw bytes** — rows,
   kinds, battery verdicts, and the four child maps; 0 mismatches anywhere,
   including the three variant-fixture receipts and both folded-seed runs.
3. **The fold commit is exactly its declared set** — 5 hunks, 3 files,
   comment-only in the fixture, and verdict-neutral on every landed row. Its
   own "191/191 post-fold" claim is backed by two 191-row folded-seed runs
   (one working-tree, one post-commit) plus a 3-case folded-seed run.
4. **The 12-vs-11 chain is real and asymmetric**: measured 11 in 31/31
   threaded logs; the r84-scribe text remains uncorrected at HEAD; the fold
   corrected two *different* fixture comment counts (S1/S2) whose evidence is
   the r85 author's probes. The adjudicator's "corrected in the fold" should
   be read as scoped to the fixture comments, not to `r84-scribe.md:276`.
5. **The `jolt_threaded` log varies only by scratch path**: raw shas differ
   per run, but after normalizing the absolute scratch path and `.gd:<line>`
   coordinates the log is identical in **11/11** receipts (65 lines, 12
   ERROR blocks, 11 witness refusals in every one). The verifier's
   "not byte-stable" caution is a raw-byte/mechanism caution; no landed
   receipt shows the 11-block variant, and the ≥8 tolerance was never
   stressed below 11.
6. **The post-fold evidence base is thin but has grown**: nine of eleven
   receipts carry the pre-fold bytes (one of them a variant fixture); the
   folded bytes are covered by the pre-commit 191-run + 3-case run and, since
   this audit began, the post-commit `r86-baseline` 191-run (191/191 PASS,
   same tuple sha, same first-188 identity). Provenance is sound (seed
   digests), and the round now has a post-commit wave-B replay of the folded
   bytes.
7. **Two open items are in neither the adjudicator's "landed" nor
   "recorded" list**: critic §9 #4 (`allow_inaccessible` refusal-count band)
   and the r85 README section request (count sentence landed, section did
   not). Both are low/round-level, but the ledger's "recorded" list is not
   exhaustive.

## Conflicts recorded verbatim (for the canonical judge)

- `r85-adjudicator.md:29-31` "191/191 PASS across author×2, reviewer,
  verifier×2, integrator — four independent executions hash to the same
  tuple sha `efb81318…`" / `LOG.md` "191/191 x4 executions identical tuple
  sha" vs measured: six receipts named in the same sentence, **eleven**
  receipts in the tree, all sharing the sha. The identity claim is true; the
  count is not.
- `r85-adjudicator.md:45-47` "scribe verified fold deltas exact (also caught
  an r84-scribe 12-vs-11 ERROR-count discrepancy — corrected in the fold)"
  vs measured: the catch is the r85-scribe's (`r84-scribe.md:276` = 12 vs
  31/31 landed threaded logs = 11); the fold corrected the *fixture comments*
  S1/S2 (r85 `jolt_threaded` witness 11/12, deferred fetch 10/10), and
  `r84-scribe.md` is unchanged since `ac025b2`.
- `r85-verifier.md:345-353` "the author reports the manual sweep also seeing
  12/12 refusals (13 blocks)" and "11–12 observed" vs this seat's census:
  every landed `joltthrproj/child.log` (11/11 receipts) carries 12 ERROR
  blocks (11 witness + 1 fetch) and `jt_threaded=true`; no landed receipt
  shows an 11-block variant. The caution is about a mechanism, not a landed
  variation.
- `r84-scribe.md:276` "12 `ERROR: Space state is inaccessible right now…`
  lines" vs measured **11** in all 31 landed 48-line threaded logs (r83 →
  r86, both backends, every receipt). Recorded, not reconciled.

## Known limits

- Read-only audit of landed receipts: **no Godot process was invoked**, no
  battery or probe was re-run; the comparator re-derivations are pure JSON /
  text re-derivation.
- **Bracket drift:** the fleet is live. The `r86-baseline` 191-row receipt
  appeared mid-audit and was folded into the census (both tools were re-run
  against the full tree); further sibling receipts may land after this
  report's digests, which are scoped to the artifacts as listed.
- "Current tree" = HEAD `3d42f77`; `corpus/live/` is untracked, so receipt
  paths are this host's working copy, not a commit.
- Re-derivation uses the HEAD predicates; for the three simplifier
  variant-fixture runs it therefore tests present-day re-derivability of
  *their* logs under the landed classifier, not the variant's own code.
- `srv_phase_delta` raw frames are quoted from the verifier's probe receipts;
  this seat did not reproduce them.
- Model identity ("deepseek-flash"), author-seat death/rate-limit details,
  and anything outside the receipts are taken from reports/registry as
  declared, not measured.
- Bounded to this host, Godot `4.7.2.stable.arch_linux.ed1daf0bf`, Python
  3.14.7, fixtures at HEAD (`phys3d_events.gd` `23bb2e27…`, 1262 lines;
  `run_battery.py` `2e1a3242…`, 920 lines; 191 CASES).
- No judgment, admission, or promotion is made by this seat; r85's
  ADMIT-corr and the r86 arm are other seats' business.

## Touched surfaces

- Written (this seat's scope only): `reports/round-86/r86-scribe.md`;
  `corpus/live/r86-scribe/scratch/` (2 audit tools),
  `corpus/live/r86-scribe/runs/` (4 JSON/text receipts, 2 `.exit` rc files,
  1 digest listing).
- Read-only: `corpus/fixtures/*` (parsed, never executed), all r83/r84/r85
  receipts under `corpus/live/`, all landed reports, `LOG.md`,
  `SCORECARD.md`, the wave-16 registry/spec/tasks and wave-17 spec/brief.
- Untouched: tracked files, `LOG.md`, `SCORECARD.md`, git state — no
  mutation. `git status --porcelain` was empty at this seat's bracket (HEAD
  `3d42f77`); after this seat's write it lists only this report and the
  concurrent sibling `reports/round-86/r86-baseline.md` as untracked, with
  no tracked modification.

## Out-of-scope items

- The r86 arm (wave-17 spec: "deferred until r85 wave-B closes — same
  fixture file") — not implemented, not judged.
- The three landed r86 scouts (`r86-scout`, `nas-scout`, `bpx-scout`) — read
  as data only; their claims are not audited here.
- g2d r77, audio r77, and every sibling seat's verdicts — receipts read as
  data only.
- Any product-code edit, fixture edit, commit, push, publication, or sibling
  dispatch.

## Artifact paths (sha256)

Tools (`corpus/live/r86-scribe/scratch/`):
`r86s_audit.py`
`6f55df1ec008e272e7368a28e5521940274cf520dac1d83ad7efd4016d8b2181`,
`r86s_checks.py`
`529b6228e06cd0d592470399b708e00e55f7e5b85169f78352e1a5e84b90a61a`.

Receipts (`corpus/live/r86-scribe/runs/`):
`r86s_audit.json`
`4a0eba8b6676ddf2200b2afd23d06b897b70234d845d15a1b7b1580e70d84501`,
`r86s_audit.stdout.txt`
`a6354ff247aad4a30a61243644434a5fc3b971962dd8d418fbd6b202a69ef213`,
`r86s_checks.json`
`cba69db90847ccfc89226e2dd1278ffd1da5fc3fdfb67fc6f808432b7f3a80ad`,
`r86s_checks.stdout.txt`
`b6554a94839f66391caef6597a1debff1dd3ce6106af83c585b7844341f74db8`,
`artifact_digests.txt`
`6dad10f8cc71ea7173219ca0a2997ba796f303c10bd93c13095bab7512b4283e`
(the `sha256sum scratch/*.py runs/*` listing, minus itself; `.exit` rc files
both exactly `rc=0\n`, sha
`93ff7811a209e2a8479230bbb9b6bc19f7f311d3af383ec350c1db2a7e7d5494`,
5 bytes each).

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
