# game-dev-3d round 84 — simplifier (seat: simplifier, host: devin)

Wave `shokunin-train-20261101-w15`, lane g3d, post-commit verify of `01f7d4f`
(`r84: backend pinning — jolt_edge child re-exec + phase_delta first-class
cell`; fixture +396/−6, `run_battery.py` +4, README +28). Mandate: find dead
code / duplication in the r84 diff **only**, prove every candidate
replay-identical in `corpus/live/r84-simplifier/`, propose — never apply.

**No deletion was applied.** The tracked tree is byte-identical: HEAD `01f7d4f`,
`git status --porcelain` = untracked `reports/round-84/*.md` only,
`corpus/fixtures/phys3d_events.gd` sha256
`255dcab56e5db479aa27e8d0cada0773c8547027cfe7e12464063d3191d536e6` (= the commit's
seed digest), `run_battery.py` `8c88aa33…`, `README.md` `ea6630b8…` unchanged.
All writes are under `corpus/live/r84-simplifier/` plus this report.

## 0. Result

| id | site (committed lines) | change | proof | verdict |
|---|---|---|---|---|
| **V2** | child-spawn protocol: `:533-550` (threaded) + `:670-690` (jolt) → one `_spawn_child()` helper | +38/−39 lines, −318 B | 12/12 phys3d rows byte-identical; jolt child log byte-identical; threaded child log normalized-identical (only the backtrace line number moves 754→753); LSP `_spawn_child` refs = 3 (decl + exactly the two call sites); **VALL full 188/188 byte-identical** | **PROPOSE** (optional — see tradeoffs) |
| **V3** | header `:5-9`, stale "unprobed for crashes" clause kept by r84 | comment re-scope, +4/−4, −1 B | 12/12 rows byte-identical (comment-only) | **PROPOSE** (doc-only, weight-neutral) |
| V1 | `_child_jolt` `:900` `var floor_b := _mk_body(...)` | −15 B | 12/12 rows byte-identical + both child logs identical; LSP refs = **1** (declaration only) | REJECT (r83 D3 precedent; a child-only deletion would create a second convention) |
| V4 | delete `_cleanup_rids()` `:896` (btm→contact_stale) | −1 line | `jolt_edge` **FAILs** (`set=0,2 in=0,2,8`, `contact_stale=unexpected`) | REJECT — load-bearing, falsified |
| V5 | delete `_cleanup_rids()` `:930` (contact_stale→static_nopair) | −1 line | `jolt_edge` PASSes (replay-identical) | REJECT — arm-independence (byte-identity cannot see it) |
| — | print-only child fields `mv_ov` `:982`, `engine` `:796`, `tp[2..5]` `:964-970` | ≈ −6 lines, but the `tp` samples need an index rewrite | LSP: `mv_ov` refs 2 (decl + print), `engine` refs 2 (decl + print) | REJECT — CHILD_NOTE is provenance cited in `r84-author.md`; deleting it changes the cited child receipt |
| — | 3rd copy of the Area3D+rigid setup (`phase_delta` `:584-607`) | ≈ −25 lines | r83 precedent + discriminating-variable argument | REJECT — the write phase is the cell's variable; per-arm setup is evidence |
| — | child reduced replays of five parent arms (`_child_jolt`) | ≈ −60 lines | design | REJECT — the child runs in a different project; it cannot call the parent arm bodies |
| — | BLOCKED-path `_cleanup_nodes/_cleanup_rids` `:665-666` | −2 lines | path unexercisable on this host (hint always contains Jolt) | REJECT — every exit path in the file cleans up; unprovable by replay here |
| — | `godot_cls` / `not godot_cls` guard `:795,803` | −1 var | r83 gate measurement | REJECT — the ClassDB pair is the impersonation witness |

**Stop condition.** The next deletion would remove either evidence (child
receipts, per-arm setup) or an invariant the receipts cannot see (V5), or
overturn a settled r83 ruling (V1) — each harms an axis for ≤ 25 bytes.

## 1. Method, controls, and byte-identity discipline

- Scratch copies: `mkvariants.py` copies the committed `corpus/fixtures/` tree
  into `scratch/<V>/` and applies each variant's edits only after asserting
  every anchor against the committed sha (`variants.json`,
  sha256 `3b38511b…`). The runner `run_battery.py` is copied verbatim
  (sha `8c88aa33…` in **every** variant dir), so every run is the unmodified
  battery.
- Control receipts (the "committed receipts"):
  - **C1** `corpus/live/r84-author/runs/20261014T173849346559Z/verdicts.json`
    (sha256 `3b367c65…`): 188/188 PASS, `seeds_unchanged=true`,
    `seed_digests.phys3d_events.gd = 255dcab5…` = the tracked file → it ran the
    committed bytes. The second full run
    (`…T174318041429Z`, `873795fa…`) is row-identical to C1 (checked
    programmatically).
  - **C2** `corpus/live/integrator-r84-verify/20261014T175035192215Z/verdicts.json`
    (sha256 `c88f8b58…`): post-commit 2/2 on `phase_delta,jolt_edge`, same
    fixture digest.
- Comparison is row-level over `(verdict, actual_exit, kind, marker, stdout,
  stderr, error, reasons)` for the 12 `phys3d_events_*` rows (per-candidate) or
  all 188 (VALL), via `compare.py`; it also reports which seed digests differ
  from the control map and diffs both child logs.
- The subset used everywhere: the 12 phys3d rows
  (`isect, cast, btm, pp_queries, contact_stale, contact_sig, sync_cb,
  srv_area_cb, static_nopair, threaded_edge, phase_delta, jolt_edge`).

**Per-variant receipts** (12 phys3d rows for V0–V3, `jolt_edge` only for the
V4/V5 probes, full 188 for VALL; `seeds_unchanged=true` everywhere):

| variant | fixture sha256 | bytes | receipt |
|---|---|---|---|
| V0 (verbatim copy) | `255dcab5…` | 41004 | `runs/V0/20261014T175437184384Z` (`c1810847…`) |
| V1 | `ee93d135…` | 40989 | `runs/V1/20261014T175437185162Z` (`a79c7027…`) |
| V2 | `6d4b31e3…` | 40686 | `runs/V2/20261014T175437184472Z` (`f13360af…`) |
| V3 | `6164ed58…` | 41003 | `runs/V3/20261014T175437184655Z` (`7072a377…`) |
| V4 | `5e4bacfd…` | 40987 | `runs/V4/20261014T175616660798Z` (`532da54b…`, **FAIL** intended) |
| V5 | `3f95c6d1…` | 40987 | `runs/V5/20261014T175618498139Z` (`582e1b0b…`) |
| VALL (V2+V3) | `11d09422…` | 40685 | `runs/VALL/20261014T175458426477Z` (`fe8c241c…`) |

Byte-identity results:

- **V0** (calibration): 12/12 rows identical to C1's subset, **all** seed
  digests identical to C1, both child logs byte-identical — the scratch
  harness reproduces the committed control.
- **V1/V2/V3**: 12/12 rows identical to C1's subset, 0 row diffs; the only
  seed-digest delta is `phys3d_events.gd` itself (proving which bytes ran);
  every other seed byte-identical; empty stderr on every case.
- **VALL**: `compare.py VALL author full` → **188/188 rows identical**
  (`compare-full.json`), `seeds_unchanged=true`, totals
  `{cases:188, pass:188, ordinary:142, negative_controls:46}`.
- **V0 and VALL vs C2** (post-commit): the 2 rows identical.
- Child logs: **jolt `child.log` byte-identical** in V0/V1/V2/V3/V5/VALL
  (sha `4b8c0e88…`, 764 B — also byte-identical across the author's two full
  runs; V4's differs by design, it is the falsification probe). **Threaded
  `child.log`**: raw-identical for V0/V1/V3; for V2/VALL it differs *only* in
  the GDScript backtrace line number
  (`phys3d_events.gd:754` → `:753`, the fold's −1 line shift), proven by a
  normalized comparison (`identical_normalized=true`, sha `9d074001…`) and by
  the unchanged `CHILD_RESULT pp_edge0=true proc_dss_refused=true srv_ok=true`
  line and unchanged 11 refusal ERROR lines (≥8/12 threshold holds).
- **V4** is the falsification probe for the mid-child cleanup: with `:896`
  deleted, the kinematic probe stays alive, `_floor_isect_hits` reads 2 instead
  of 1 (`CHILD_NOTE jolt_contact_stale set=0,2 in=0,2,8`), the child classifies
  `unexpected`, and the parent fails named (`jolt_edge child mismatch …`). The
  line is **load-bearing**, not dead weight.
- **V5** proves the limit of replay-identity: deleting `:930` is
  **receipt-identical** (`PASS`) yet rejected — the child arm would no longer
  replay the parent cell's environment (its RIDs would survive into
  `static_nopair`), and only the arm-independence argument, not the battery,
  sees that.

## 2. Device record (semantic proof vs literal fallback)

- **MCP**: `mcp_list_servers` exposes only `rea` (Ghidra/native-RE tools; it
  resolves native-binary procedures, not GDScript symbols) — **no MCP `lsp`
  device serves this file**. Recorded, not used as absence.
- The answering language server is **Godot's own LSP** (headless editor,
  `--lsp-port 8621`), harness inherited from the r83-simplifier scratch
  (`lsp_refs.py`, sha `64e26a6d…`, port changed to avoid collisions) and
  re-verified this session: `initialize` answered with capabilities; **every**
  query in both sessions returned a non-empty result (no cold-index empty was
  observed, and no claim here rests on an empty result). Warmup 20 s after
  `didOpen` per the seat card; the harness's `retry_after_warmup` event never
  fired. `lsp_refs_v0.err` / `lsp_refs_v2.err` are 0 B.
- Session A (`lsp_refs_v0.jsonl`, `cb1d1bc0…`) ran against a fresh LSP project
  holding the **committed** fixture (`lsp-proj/phys3d_events.gd` sha
  `255dcab5…`); session B (`lsp_refs_v2.jsonl`, `cb7cc9ae…`) against the V2
  file.
- Text grep was used only as a **literal census** (identifier occurrence
  counts), never as semantic proof.

### LSP references (0-based lines, `includeDeclaration=true`)

| query (0-based pos) | n | refs | reading |
|---|---|---|---|
| `_child_jolt.floor_b` decl `899:5` | **1** | `899:5` | **declaration only — no reader** (the V1 candidate) |
| `contact_stale.floor_b` decl `335:7` | **1** | `335:7` | control: the r83 site measures the same (r83 D3) |
| `_child_jolt.mv_ov` decl `981:5` | 2 | `981:5`, `987:21` | one reader: the `CHILD_NOTE` print |
| `_child_jolt.engine` decl `795:5` | 2 | `795:5`, `797:37` | one reader: the `CHILD_NOTE` print |
| `_child_jolt.rig` decl `900:5` | 12 | — | control (heavily read) |
| `_child_jolt.jolt_cls` / `godot_cls` | 3 / 3 | — | control: both feed `jolt_backend` + note |
| `_child_jolt.silent` / `tp` / `cast_edge` / `btm_edge` | 2 / 20 / 2 / 2 | — | control: classification readers exist |
| `func._frames` decl `77:5` | 48 | — | **server answers semantically** (large control) |
| `func._child_threaded` / `func._child_jolt` | 2 / 2 | — | control: exactly call site + decl |
| `threaded.thrdir` decl `532:7` | 5 | `532,533,536,542,548` | all inside the replaced block `:533-550` → block-local, no outside reader |
| `jolt.joltdir` decl `669:7` | 5 | `669,670,673,680,688` | all inside the replaced block `:670-690` → block-local |
| `threaded.selfpath` decl `541:7` | 2 | `541,548` | block-local |
| (V2 file) `func._spawn_child` decl `706:5` | **3** | `532:16`, `658:16`, `706:5` | the helper is the **single** spawn authority: decl + exactly the two call sites |
| (V2 file) `spawn` at each call site `532:7` / `658:7` | 5 / 5 | decl + 4 reads each | call-site-local |

## 3. Candidates in detail

**V2 — duplicate spawn authority (the only structural candidate).** r84 added
a second copy of the child-spawn protocol: `make_dir_recursive_absolute` →
write `project.godot` → `globalize_path("res://phys3d_events.gd")` →
`/bin/sh -c 'timeout -s KILL 30 … > child.log 2>&1'`. The copy is deliberate
(the jolt comment says "the threaded_edge thrproj pattern -> joltproj"), but it
duplicates the r83 reviewer F2 bound and the redirect invariant in two places —
the exact drift class the repo contract warns about for duplicated routing
tables. V2 consolidates both call sites onto `_spawn_child(arm, dir_name,
project_body, child_args)` (`:707-727`), with the failure messages parameterized
so the diagnostics are character-identical (`"%s cannot make %s err=%d"` /
`"%s cannot write child project"`), and the shell command string reproduced
character-for-character (the `-- %s` slot carries `--child` /
`--child --arm=jolt_edge`). Evidence: 12/12 rows byte-identical, both child
logs identical up to the line-number shift, `_spawn_child` refs = 3, and VALL's
full 188/188 identity. **Weight: −318 B, net −1 line** (39 replaced lines → 38
new ones, 26 of them the helper) — the justification is the single-sourced
spawn invariant, not the byte count.

**V3 — stale claim in a line r84 rewrote.** r84 edited the header sentence and
kept the clause "Jolt is selectable on this build but unprobed for crashes
beyond r83-boundary's jolt-* receipts". The first clause it added ("Jolt is
pinned in-battery by the jolt_edge child arm") falsifies the second: the child
*is* an in-battery crash probe for its five arms (exit code + `ERROR:` scan +
`timeout -s KILL 30`), and the author's own remaining-risks list scopes what
stays unprobed to the five non-replayed arms. Proposed re-scope (5 lines → 5,
keeps the r83-boundary citation — no provenance deleted):

```
# (GodotPhysics3D; Jolt is selectable on this build and pinned in-battery
# by the jolt_edge child arm: the query/event split holds, cast/btm differ
# on solver constants, static_nopair inverts; the five arms the child
# does not replay stay unprobed beyond r83-boundary's jolt-* receipts).
```

This is **not** the carried `README.md:5` staleness r84-reviewer recorded
(different file, different claim, untouched by r84) — this clause is a `+` line
of the r84 diff itself.

**V1 — the one truly dead binding in the additions.** `_child_jolt`'s
`floor_b` (`:900`) is a write-only binding: LSP returns exactly one reference
(its own declaration), and no `CHILD_NOTE` or classification reads it. r83
tested and rejected the parent's identical binding (D3) because all `_mk_body`
call sites bind their result and the name documents the floor. A child-only
deletion would now make the two sites inconsistent (a second convention), and
deleting both overturns a settled ruling without new evidence — so the
candidate is recorded with its proof, not proposed.

**Rejected without a variant** (analysis only, no replay claim needed):
the three-fold Area3D+rigid setup (r83 rejected the two-fold extraction; the
write phase is `phase_delta`'s discriminating variable), the child's reduced
replays (a different project cannot call the parent arm bodies; the README
pins "replays reduced copies"), the BLOCKED-path cleanup calls (every exit path
in the file cleans up; the path is unexercisable on this host, so a deletion
there could not be replay-proven), the `godot_cls` half of the impersonation
guard (r83-measured pair), and the child's `dss == null` named bail.

## 4. Preserved contract

Under VALL (and every per-candidate variant): the 12 pinned markers and exit
codes (11 × exit 0 `PASS …`, 1 × exit 2 `NEGATIVE REJECTED: …`), empty stderr
on every case, the child logs' `CHILD_NOTE`/`CHILD_RESULT` content and the
six-entry verdict map (`jolt_backend`/`jolt_isect`/`jolt_cast`/`jolt_btm`/
`jolt_contact_stale`/`jolt_static_nopair`), the ≥8/12 `proc_dss_refused`
threshold, the battery's before/after seed-digest equality, and all 188 battery
rows including the 176 pre-r84 rows — unchanged at byte level.

Census of the r84 `run_battery.py` rows: 12 `phys3d_events_*` rows, 12 unique
case names, 12 unique `(script, flags)` pairs, every marker verbatim in the
fixture (no orphan row, no duplicate marker) — no action.

## 5. Tradeoffs / notes for the integrator

- **V2 rewrites a landed r83 arm.** The 18-line threaded spawn block is
  pre-r84 code; folding V2 makes the r84 commit message's "prior 186 rows
  byte-identical (insertion-only)" and `r84-author.md`'s "Every pre-existing
  arm's code is byte-identical" stale *for those lines* (the rows stay
  byte-identical). Any fold also changes the fixture sha cited in
  `r84-author.md:31` (`255dcab5…`) — the fold commit should record pre/post
  shas, as the r83 fold did. The threaded child's backtrace line number moves
  754 → 753 (scratch evidence; the verdict line is unchanged).
- **V2's weight is small** (−318 B). If the integrator prefers zero churn on
  landed arms, dropping V2 costs only the single-sourcing of the F2 bound; the
  next child arm (the listed `Jolt × run_on_separate_thread` cross-product)
  would otherwise copy the protocol a third time.
- **V3 is doc-only** and weight-neutral; it can be folded with V2 or alone.
- **Citation nits already recorded by r84-reviewer** (`_child_jolt()` range
  `:791-1003` vs actual end `:1001`; BLOCKED branch `:660-669` vs `:661-669`)
  live in the author report, not the fixture; any fold shifts those numbers
  anyway.
- Receipts: `corpus/live/r84-simplifier/runs/<V>/<stamp>/verdicts.json`,
  comparisons `runs/<V>/compare*.json`, LSP sessions `lsp_refs_v0.jsonl` /
  `lsp_refs_v2.jsonl`, variant manifest `variants.json`. Reproduce:
  `python3 mkvariants.py`, `bash run_variants.sh <V> phys3d|full`,
  `python3 compare.py <V> author phys3d|full`.

Leaf seat: no subagents, no git mutation, no judgment, no ship. Shared tree
verified byte-identical before reporting. Stopping here — the next deletion
would harm an axis.
