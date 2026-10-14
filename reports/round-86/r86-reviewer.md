# game-dev-3d round 86 — reviewer (seat: reviewer, host: devin)

Commit under review: **`4e65726`** (`r86 work: size-gate, deferred-hang,
backend-tier, dummy-floor cells`), parent `3d42f77`. Worktree clean at review
start apart from the sibling untracked `reports/round-86/r86-baseline.md`.

**Verdict: ACCEPT.** Every landed claim reproduced on this seat's own runs.
One finding (F1) is a **record-integrity defect, not a corpus defect**: the
nav-cell "non-replication" that the commit message and two reports state as a
measured fact is a harness artifact, and I reproduced the scout's receipt
byte-identically. No landed byte needs to change; the claim and its r87
instruction do.

**Runtime.** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` (`--headless`,
60 tps, 32 cores), Python 3.14.7, single host. Same build the round is bounded
to.

**LSP unavailability — recorded.** `mcp_list_servers` exposes exactly one
server (`rea`, a Ghidra reverse-engineering device: `annotate_native_function`
etc.) and **no `lsp` device**, so no `references` / `definition` /
`diagnostics` request could be made and no empty cold result was recorded as
absence (same as r85, r86-scout, r86-boundary, r86-scribe). Symbol work below
is exact-symbol text search plus runtime/receipt evidence, never presented as
semantic proof: all **10** `_spawn_child(` call sites were enumerated and each
read, and the backward-compatibility claim is carried by a byte-level child-log
comparison and by 191 ordered receipt rows, not by grep.

---

## 1. Claim ledger

| # | Claim (from the brief / commit) | Method | Result |
|---|---|---|---|
| 1 | Insertion-only: the 8 deletions are the `_spawn_child` signature + the README count | `git show --numstat` + line-level read of every `-` line + behavioural A/B | **VERIFIED, value-preserving** (§2) |
| 2 | Battery **195/195** on my own runs | 2 × full battery, all 4 probes | **VERIFIED** — 195/195, 149 ord / 46 neg, `seeds_unchanged=true`, mutation probe `detected=true`, exit 0 |
| 3 | The 4 new cells reproduce in my own children | 4 arms × 3 direct reps + child-log read + 2 × README `--only` | **VERIFIED** — 12/12 arms, 4/4 and 4/4 focused |
| 4 | New `CASES` rows registered correctly | AST parse + marker-vs-`_exit_ok` byte compare | **VERIFIED** — 4 rows appended at the tail, 195 total, no dups, every marker byte-matches a fixture `_exit_ok` string |
| 5 | README count now **195/149** | AST parse of `CASES` | **VERIFIED** — 195 rows = 149 ordinary + 46 negative |
| 6 | Nav cell refused honestly; replication evidence exists | re-ran the scout's pinned probe in both environments | **PARTLY FALSIFIED** — the evidence files are genuine and the decision was conservative, but the stated ground is wrong: **F1** |
| 7 | `_spawn_child` signature change backward-compatible | static + frozen-vs-HEAD child-log map + prior-191 receipts | **VERIFIED** (§2) |
| 8 | Author's 9/9 mutation matrix (§6.3) | re-ran `corpus/live/r86-author/mutate.py` | **VERIFIED** — 9/9 load-bearing, each with the expected named drift |

## 2. Insertion-only and backward-compatibility (claims 1 and 7)

`--numstat`: `phys3d_events.gd` +615/−7, `run_battery.py` +8/−0, `README.md`
+59/−1, three reports +1351/−0 → **8 deletions**, enumerated:

| # | file | deleted line | replacement | value-preserving? |
|---|---|---|---|---|
| 1 | `README.md` | `191 registered cases (145 ordinary and 46` | `195 registered cases (149 ordinary and 46` | intended count edit; verified against `CASES` |
| 2–3 | `phys3d_events.gd:252-253` | the two `_spawn_child` doc lines naming the return tuple | same lines + `errs` in the tuple | doc-only, and now accurate |
| 4 | `:265` | `allow_inaccessible: bool) -> Dictionary:` | same + `script_res := "res://phys3d_events.gd", bound_s := 30) -> Dictionary:` (`:265-266`) | default reproduces the old literal exactly |
| 5 | `:276` | `globalize_path("res://phys3d_events.gd")` | `globalize_path(script_res)` | same value under the default |
| 6 | `:281` | `"timeout -s KILL 30 …"` | `"timeout -s KILL %d …"` + `bound_s` | `%d` = 30 under the default |
| 7 | `:284` | the `% […]` argument list | same list with `bound_s` prepended | 6 placeholders ↔ 6 arguments, order verified |
| 8 | `:290` | `{"code", "verdicts", "last", "serr"}` | same dict + `"errs": []` | **additive key only** |

`errs` is read only by the four new arms; no prior caller stringifies the whole
dictionary (the prior arms read `["code"]`, `["serr"]`, `["last"]`,
`["verdicts"]`), so no prior marker can move. All four prior call sites
(`:784`, `:887`, `:926`, `:961`) pass exactly four positional arguments.

Behavioural A/B, not just a read: the **frozen r85 fixture** (`23bb2e27…`,
`corpus/live/r86-baseline/frozen-extract/`) and HEAD (`66c92c38…`) both run
`--arm=threaded_edge` through the default `_spawn_child` path and produce an
**identical child.log map** (`child_log_map.py --compare` → PASS identical;
notes 1/1 identical, non-empty non-map lines 45/45) and the same PASS marker.
At the receipt level, both of my full runs and the baseline seat's own
post-commit run put the prior **191/191 rows as an ordered subsequence at
identical positions, 0 drift**, with exactly 4 inserted rows at indices
192–195.

## 3. Battery and cells on this seat's own runs (claims 2, 3, 4)

Receipts (`corpus/live/r86-reviewer/runs/`, all exit 0):

| run | receipt | result |
|---|---|---|
| full #1 (4 probes) | `20261014T203814176858Z` | `cases=195 pass=195 fail=0 ordinary=149 negative_controls=46`, 4/4 probes, mutation `detected=true`, `seeds_unchanged=true` |
| full #2 (4 probes) | `20261014T204202674436Z` | identical totals and verdict |
| `--only` (README command) ×2 | `20261014T204547212102Z`, `20261014T204602705493Z` | 4/4 PASS each |

All four new rows are byte-stable across my two full runs (verdict, exit,
marker, stdout, reasons) — 0 drift — and their elapsed times sit far under the
20 s case timeout: `script_size_gate` 2.56/2.61 s, `deferred_hang` 9.08/9.20 s
(structural: the 8 s kill bound plus the Dummy contrast child),
`backend_tier` 2.04/2.80 s, `dummy_floor` 1.55/1.66 s.

Direct arm runs (4 arms × 3 reps, 12/12 PASS) plus a read of the children they
actually produced (`corpus/live/r86-reviewer/arm-children/`):

- `szminproj/child.log` — exactly **one** engine refusal
  (`ERROR: Space state is inaccessible…`) + `CHILD_RESULT sz_fetch=refused`;
  `szpadproj`, `szplainproj`, `szfxproj` — `granted`, **zero** rejected lines.
  The generated probes are **25** and **1025** lines exactly, and the
  `szminproj`/`szplainproj` bodies are byte-identical (only the project
  differs) — a clean controlled pair.
- `hangproj/child.log` — the refusal, `CHILD_NOTE sz_deref pad=0 null=true`,
  then `SCRIPT ERROR: Attempt to call function 'get_class' in base 'null
  instance'`, and **no `CHILD_RESULT` line at all**; the arm's `rc == 137`
  pin is what carries the class. `hangdummyproj/child.log` — no refusal,
  `CHILD_RESULT sz_abort=PhysicsDirectSpaceState3DDummy`, rc 0.
- tier children — `plain` `base=(0,-9.8,0)/0.100000 → override=(0,20,0)/2.000000`
  (`honors`), `jolt` override stays `(0,-9.8,0)/0.100000` while
  `area_readback=20.0` (`ignores` — the write lands, the effect does not),
  `dummy` floor; margin `inert`/`binds`/`empty`; sepray
  `same-signature`/`differs-constants`/`floor`.
- floor children — the 11-token signature
  `["rid0","nil","2","rid0","0.0","dummy","nil","nil","0","rid0","nil"]` with
  **zero** rejected lines under Dummy, versus `real-values` plus exactly two
  loud refusals (`ERROR: Parameter "space" is null.`, `ERROR: Invalid ID.`) on
  the identical body under DEFAULT.

Re-running the author's `mutate.py` (`corpus/live/r86-reviewer/mutation-matrix-reviewer.txt`)
reproduces **9/9 load-bearing** mutations, each failing with the expected named
drift (`M1 pad_thr … refused`, `M3 min_plain … refused`, `M4 exit=137
expected=0`, `M6 jolt … ignores`, `M9 dummy_floor … unexpected`, …), so the new
pins are falsifiable rather than self-restating.

## 4. Findings

### F1 — HIGH (record integrity; no landed byte affected): the nav-cell "non-replication" is a harness artifact, and the scout's receipt reproduces byte-identically

The commit message, `r86-author.md` §7 and
`corpus/live/r86-author/nav-replication/RERUN.md` state that the nas-scout's
`safe_n=10` / `last_safe=(2.0,0,0)` witness **does not replicate**: "`safe_n=0`
in 8/8 fresh processes … That is not a harness defect." The evidence for the
attempt is real (both probe copies are byte-identical to the scout's pinned
manifest entries — `probe_nav_node_rid.gd` `68f0b843…`,
`nav_node_rid_driver.gd` `1c6a60ff…`; two saved rerun logs; the exact command
in `RERUN.md`). **The inference from it is false.**

`RERUN.md`'s command runs `--path .` **from `nav-replication/`, which contains
no `project.godot`.** The scout's own recorded command
(`corpus/live/nas-scout/runs/p6/nav_node_rid.cmd`) points at
`…/nas-scout/runs/p6/scratch/w0`, a scratch directory that no longer exists —
so its contents cannot be read back. I reconstructed the scout's environment
from `corpus/live/nas-scout/proj/` (the seed project copy, `project.godot`
present, and the probe bytes byte-identical to both the `probes/` and `proj/`
manifest entries). That reconstruction is *confirmed* by the receipt itself:
the run is byte-for-byte identical, **including the process-specific
`RID(154618822657)` fingerprint**, which no other environment reproduced. I ran
both:

| environment | runs | `B_server_rid` | sha256 |
|---|---|---|---|
| copy of `corpus/live/nas-scout/proj/` (project.godot present) | 3 saved reps (4–6) + 3 observed | `safe_n=10 last_safe=(2.0,0,0)`, `TAIL_SAFE [(2,0,0)×10]`, `RID(154618822657)` | `cc0a3f87…` — **byte-identical to the scout's own receipt** `corpus/live/nas-scout/runs/p6/nav_node_rid.stdout.txt` |
| the author's harness (no `project.godot`) | 3 saved reps | `safe_n=0`, `TAIL_SAFE []`, `RID(101288213741569)` | `1f6dae5d…` — **byte-identical to the author's own `rerun_1.log` and `rerun_2.log`** (all three share that sha) |

Both harnesses are perfectly reproducible; they simply reproduce *different*
things, and the difference is the project file.

Mechanism isolated by bisection (each variant one run, probe bytes unchanged):
a **0-byte** `project.godot` → `safe_n=10`; `config_version=5` alone → 10; the
seed `project.godot` verbatim → 10; the **full fixture copy with
`project.godot` deleted** → `safe_n=0`. So it is the presence of a project
file, not the other files, not `config/features`, not any setting value: the
project settings dumps differ in only four lines (`PROJ_FILE_EXISTS`,
`application/config/features`, `application/config/name`,
`rendering/renderer/rendering_method.mobile`) and **no navigation setting
differs at all**. (I isolated the gate empirically and did not read engine
source; the engine-internal reason is unexamined.)

Consequences, in order of importance:

1. **The scout's receipt is good and the witness is reproducible** — the
   scout's run plus 9/9 of mine with a project file, against 11/11 without one
   (3 mine + the author's 8). `r86-author.md`'s instruction that "its
   `last_safe` pins must be re-derived before any r87 author arms it" is
   misdirected: the pins are right and only the harness was wrong.
2. **A landed nav cell would have been stable**, because the battery always
   runs inside a project: `run_battery.py:786-793` copies every seed —
   `project.godot` included — into `runs/<ts>/scratch` before invoking Godot,
   and every generated child project in `phys3d_events.gd` writes its own
   `project.godot`.
3. The author's *fallback* characterisation is accurate and reproduces in both
   environments (node setter never reaches the server; the RID push lands from
   the next read onward; `C_server_rid_forced` inert; `in_map/avoidance/has_cb`
   correct) — only the `last_safe` conclusion is wrong.
4. The decision not to land a cell whose witness the author could not
   reproduce in their own harness remains the **conservative and correct**
   call; the defect is the claim and the r87 instruction, not the parking.

Suggested correction (no corpus change): fix the sentence in the commit-message
record / `r86-author.md` §7 / `RERUN.md` to "not reproduced **in a
project-less directory**; the receipt reproduces byte-identically once the
probe runs under a project (`project.godot` present)", and re-derive nothing in
r87 — re-run the probe under `--path` pointing at a project copy before
repeating the claim. The same project-less pattern also occurs in the author's
`mutate.py` scratch (`/tmp/r86v/mut/scratch` holds only `phys3d_events.gd`); it
does not affect the 9/9 matrix (I reproduced it, and the physics path is
project-file-insensitive), but it is the same habit that produced F1.

### F2 — LOW (report set, not the commit): `r86-baseline.md` still says PHASE 2 "PENDING" while its phase-2 receipts exist

`reports/round-86/r86-baseline.md` (untracked, to be landed with the round)
ends its Phase 2 section with "PENDING (waiting on the r86 author commit)",
written 17:10. The receipts it describes exist and are green:
`corpus/live/r86-baseline/runs-post/20261014T203735129154Z/verdicts.json`
(195/195, 149/46, 4/4 probes, `seeds_unchanged=true`),
`runs-post/bpy-…203732322457Z` (83/83), and six
`receipts/run_*.post.json` (three.js `verdict: PASS`, `seedsUnchanged: true`).
I re-ran the seat's own checker against its post-commit receipt:
prior-191 ordered-subsequence **PASS 191/191 at identical positions**, 4
inserted rows. If the report lands as written it will contradict its own
receipts. Open item for the integrator's report-last commit; **not** a defect
of `4e65726` (the file is not in it).

### F3 — INFORMATIONAL: the scribe report's "at HEAD" now reads ambiguously

`r86-scribe.md:61` says "`CASES` at HEAD parses to **191 rows**". That was
correct for its own HEAD (`3d42f77`, stated in its provenance section), but the
report is now committed into a tree whose HEAD parses to 195. No correction
needed — the scope is bracketed — flagged only so the ledger does not read it
as a stale count.

### Checked, no defect

- **README's `min_plain` generalisation** ("the gate does not exist without the
  threading flag") is broader than the arm's own two-point contrast (the
  unthreaded child is the *minimal* body, i.e. below the band), but it is
  independently corroborated: the unthreaded **parent** fixture at 1870 lines
  passes its own `dss == null → _fail` guard (`phys3d_events.gd:479-480`) in
  every arm of every battery run, i.e. granted above the band unthreaded.
- **Error paths of the new arms**: all 10 new spawns check `has("err")` before
  touching `["errs"]`; `_spawn_probe` propagates `_spawn_child`'s early
  `{"err": …}` returns verbatim; a stale `child.log` is unlinked before every
  spawn, so the killed child's log can never be forged by a prior run.
- **`script_res` as an absolute path** (the generated probe) is handled
  correctly by `globalize_path`; the children really ran it (their backtraces
  read `res://szprobe.gd:15/20`).
- **Backend gating**: `backend_tier` / `dummy_floor` (and the inherited r85
  arms) print `BLOCKED` + `quit(1)` when a hint is absent, which the battery
  reports as a FAIL row rather than a skip — a pre-existing convention
  documented at `README.md:620,671`, not introduced here; moot on this host.
- **Determinism pins** are outcome/engine-semantic (refusal counts, rc, token
  tuples), never wall-clock; the only wall-clock value is the disclosed
  `HANG_BOUND_S`.

## 5. Residual risk

- **The size-gate band is stochastic.** The pins sit ~450 lines clear of the
  measured edges (475–575 lines, 6 reps/point, boundary §1), and I measured
  3/3 per arm plus 4 battery executions with no flip, but the 1025-line point
  has only this round's receipts behind it. A future `SIZE_PAD` move must be
  re-measured repeated, not once (author's own note, §8).
- **`HANG_BOUND_S = 8`** is a wall-clock bound: on a much slower host the
  refusal/abort lines might not be flushed before the kill, which fails the arm
  **named** (`abort=false` / `errs` size drift), never silently. The row's
  ~9.1 s of the 20 s case timeout is structural, not slack to spend.
- **`deferred_hang`'s class claim is one backend pair** (DEFAULT+threaded hangs
  vs Dummy+threaded grants); the boundary seat's broader await-shape/backend
  independence is cited, not re-derived here.
- **Jolt/Dummy splits are one build's answer** (`4.7.2.stable.arch_linux.ed1daf0bf`).
- **F1's mechanism is named at the file level only** — "a `project.godot` must
  exist" — not explained engine-internally.
- The `errs` pin for the refused child is strict (`== 1`); an engine that
  emitted a second refusal line at another callsite would fail the row loudly,
  which is intended but does make the row build-sensitive.

## 6. Verification gaps

- No `lsp` device (recorded above): call-site and symbol claims rest on exact
  text search over enumerated hits plus receipt-level evidence, not on
  references/definition/diagnostics.
- Single host, single Godot build; the bpy (83/83) and three.js (31/31)
  surfaces were **not re-run by this seat** — their post-commit receipts were
  read (`verdict: PASS`, `seedsUnchanged: true`) but not independently
  reproduced.
- I did not reproduce the nav *fixture prototype* (it lives in `/tmp/r86v/…`
  and is not pinned) — my finding is scoped to the scout probe's witness and
  the project-file gate, which is what the refusal cites.
- My F1 bisection used one run per variant (plus 6 project-env and 3
  project-less probe runs); the split was 100 % deterministic at every point,
  so repetition would add little, but it is not a 6-rep-per-point ladder like
  boundary §1.

## 7. Evidence index (all under `corpus/live/r86-reviewer/`, gitignored)

- `runs/20261014T203814176858Z/verdicts.json` — full battery #1, 195/195 + 4 probes
- `runs/20261014T204202674436Z/verdicts.json` — full battery #2
- `runs/20261014T204547212102Z/`, `runs/20261014T204602705493Z/` — README `--only` ×2
- `arm-children/{szminproj,szpadproj,szplainproj,szfxproj,hangproj,hangdummyproj,tier*,floor*}/`
  — child logs, generated `szprobe.gd` (25 / 1025 lines), generated `project.godot`
- `arm-children/{frozen,head}-threaded_edge.child.log` — the backward-compat A/B pair
- `nav-replication/` — `reviewer_w0_projectenv_rep{4,5,6}.stdout.txt`
  (`cc0a3f87…`, byte-identical to the scout receipt), `reviewer_noproj_rep{1,2,3}.stdout.txt`
  (`1f6dae5d…`), `reviewer_settings_{projectenv,noproj}.txt`, `settings_probe.gd`
- `mutation-matrix-reviewer.txt` — re-run of the author's 9-mutation matrix
- `/tmp/r86rev/{vA,vB,vC,vE}` — the project-file bisection variants (ephemeral,
  results quoted above); `/tmp/r86rev/fx`, `/tmp/r86rev/fxfrozen` — direct-arm and A/B scratch

No tracked file was edited by this seat; no commit, judge, or integration was
performed.
