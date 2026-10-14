# game-dev-3d round 83 — simplifier (seat: simplifier, host: devin)

## Mandate and method

Delete weight from the LANDED r83 arm (`e9145d9`: `corpus/fixtures/phys3d_events.gd`
+ 10 `CASES` rows + README section) without creating a second convention.
Propose + prove only; the tracked tree is never edited by this seat. Every
candidate was replayed in a scratch copy of the fixture tree
(`corpus/live/r83-simplifier/scratch/<V>/`) with the unmodified battery, and
compared byte-for-byte against a scratch baseline built from the landed bytes
(sha256 `6ddf4aefde97d31673f337699ba1dedbe9e6caf4226917225577a36b8ac4fab3`,
identical to `HEAD:corpus/fixtures/phys3d_events.gd`).

## Device record (semantic proof vs literal fallback)

- The MCP-exposed server set is `rea` only (173 Ghidra/native-RE tools; its
  `procedure_references` resolves native-binary procedures, not GDScript
  symbols) — **no MCP `lsp` device for GDScript**. The answering language server
  is **Godot's own LSP** (headless editor, `--lsp-port 8619`), driven over JSON-RPC by
  `corpus/live/r83-simplifier/lsp_refs_multi.py` (harness inherited from the
  dead r83 seat's scratch and re-verified: `initialize` answered with server
  capabilities; `textDocument/references` answered for 16 positions).
- Warmup discipline (seat card): 20 s after `didOpen`. Session 1
  (`lsp_refs_r83.jsonl`) answered every query non-empty. Session 2
  (`lsp_refs_r83_session2.jsonl`) exercised the real cold path — the **first**
  query returned empty, the harness emitted `retry_after_warmup`, and the
  repeat stayed empty; session 3 (`lsp_refs_r83_session3.jsonl`) put a known
  17-reference control first and reproduced the same empty result. That empty
  result is recorded as a **device coverage gap** (the server does not model
  `for`-loop variables), never as absence.
- Repeatability: `tries`, `sh_out`, `floor_b`, `early`, `ray_hit`, `p` and
  `sig_log` were queried in two independent sessions and returned identical
  reference lists both times — the results are warm, not cold-index artifacts.
- Text grep was used only as a literal census (never as semantic proof): the
  deleted names appear nowhere else in the tracked tree except the fixture
  (`grep -rn` over the repo, `node_modules` noise excluded).

## LSP evidence (Godot LSP, landed bytes, 0-based lines)

| query (position) | refs | reading |
|---|---|---|
| `PPQueries.tries` decl `145:5` / incr `161:2` | **2** — `145:5`, `161:2` | only the declaration and its own `+= 1`; **no reader** |
| `PPQueries.ray_hit` decl `147:5` | 4 — `147:5`, `154:25` (`result_ok`), `189:2` (assign), `299:31` (drift diagnostic) | control: initial value **is** read by the `_fail` diagnostic → sentinel-initializer deletion rejected |
| `PPQueries.travel_z` decl `151:5` | 3 — `151:5`, `156:13`, `193:2` | control: read by `result_ok` |
| `threaded.sh_out` decl `516:7` | 2 — `516:7`, `517:50` (the `OS.execute` argument) | one write-only sink argument, **no reader of the bound value** |
| `child.early` decl `548:5` | 2 — `548:5`, `549:19` (the `== null` test) | exactly one reader; collapsing preserves it |
| `child.early_null` decl `549:5` | 2 — `549:5`, `591:41` (`CHILD_NOTE` print) | control: the note's reader is untouched |
| `contact_stale.floor_b` decl `309:7` | **1** — `309:7` | **declaration only**; the `_mk_body` call's side effect is what matters |
| `_frames` `58:5` | 28 | control: many refs (server is answering semantically) |
| `_fail` `539:3` (guard call) | 20 | control: the `_:` guard is a real `_fail` caller (reachable via a typo'd `--arm=`) |
| `sig_log` `44:4` | 17 | control |
| `SETTLE` `37:6` | 11 | control |
| `_cleanup_rids` `116:5` | 5 | control |
| `PPQueries.dss` `144:5` | 4 | control: field read at `162:11`, assigned at `291:5`, `560:3` |
| `PPQueries` class `140:6` | 3 | control: constructed at `287:12`, `556:10` |
| `p` local `95:5` | 7 | control (parser scope probe) |
| `for` loop var `i` `59:5` | 0 in both sessions that queried it (one as a first query with the post-warmup retry, one behind a 17-ref warm control) | **device gap**, not absence — no claim made |

## Deletion candidates and proofs

Baseline scratch V0 = landed bytes. Every variant is V0 with exactly one
anchored deletion (anchors asserted to occur exactly once,
`corpus/live/r83-simplifier/mkvariants.py`). Receipts:
`corpus/live/r83-simplifier/runs/<V>/<stamp>/verdicts.json`; comparison:
`compare.py` (10-case rows) and `compare_full.py` (186 cases).

| id | deletion (landed line) | Δ weight | 10-case rows | verdict |
|---|---|---|---|---|
| **D1** | `PPQueries.tries`: `146` decl + `162` `tries += 1` | −2 lines / −29 B | V1 identical | **PROPOSE** |
| **D2** | `threaded_edge`: `517` `var sh_out := []` → inline `[]` in the `518` `OS.execute` call | −1 line / −24 B | V2 identical | **PROPOSE** |
| **D4** | `_child_threaded`: `549-550` two-line fetch+test → one-line `early_null := … == null` | −1 line / −46 B | V4 identical | **PROPOSE** |
| D5 | `_:` guard `541`: drop the redundant trailing `return` after `_fail(...)` | −1 line / −10 B | V5 identical | OPTIONAL |
| V6 (D5-alt) | same site as `return _fail("unknown arm " + arm)` — the form the file's other 19 `_fail` sites use | −1 line / −3 B | V6 identical | OPTIONAL (convention alignment, not deletion) |
| D3 | `contact_stale`: `310` `var floor_b := _mk_body(...)` → bare call | −15 B | V3 identical | **REJECT** (see below) |
| — | all five together | −5 lines / −124 B | VALL identical | — |

**Byte-identity result.** All eight variant runs (V0, V1, V2, V3, V4, V5, V6,
VALL) produced the *same* 10-case `(case, verdict, exit, marker)` rows
(`sha256(rows) = a726929ef8c0fcbc`), the same per-case stdout lists, empty
stderr on every case, exit 2 on the `static_nopair` negative, and
`seeds_unchanged=true` in every receipt; the only seed-digest delta is
`phys3d_events.gd` itself.

**Full-battery result (VALL, all five deletions).**
`corpus/live/r83-simplifier/runs/VALL-full/20261014T170058883201Z/verdicts.json`
— **186/186 PASS**, `seeds_unchanged=true`, `totals={cases:186, pass:186,
fail:0, ordinary:140, negative_controls:46}`; `compare_full.py` compared all
186 cases against the LANDED author receipt
(`corpus/live/r83-author/runs/20261014T165207093423Z/verdicts.json`, whose
`phys3d_events.gd` digest equals the tracked file's sha256) →
**FULL_BATTERY_IDENTICAL**: identical stdout, markers, exits, verdicts, kinds,
totals. The receipt's own `seed_digests.phys3d_events.gd = d398e7ca…` matches
the VALL scratch file, so the run provably executed the deleted bytes. The
threaded child still logs 11 `Space state is inaccessible` refusals
(`scratch/thrproj/child.log`, ≥8/12 pin holds) and the exact
`CHILD_RESULT pp_edge0=true proc_dss_refused=true srv_ok=true` line.

## Rejected candidates (tested or analysed, not proposed)

- **D3 `floor_b` (rejected).** Byte-identical (V3), but all 13 other `_mk_body`
  call sites in the file bind their result, and the name is what
  documents "this is the floor the rigid body lands on". Deleting it breaks the
  local convention for 15 bytes and converts the call into a discarded-return
  statement — a construct a future Godot build could start warning about, which
  the battery classifier would turn into a case FAIL (any non-empty stderr line
  fails). Harm to the readability/hazard axes exceeds the weight removed.
- **Sentinel initializers (rejected, with a reader).** `ray_hit := true`,
  `isect_n := -1`, `safe := -1.0`, `btm_hit := true`, `travel_z := 0.0` look
  like dead defaults because `result_ok()` short-circuits on `printed`. LSP
  shows `ray_hit` (and `btm_hit`) are read by the `pp_queries` drift diagnostic
  at `phys3d_events.gd:300` — the values are the failure surface's report.
  Removing them would change what a FAIL diagnostic prints for zero gain.
- **`contact_sig` / `static_nopair` setup extraction (rejected).** ~22 lines of
  near-identical Area3D+body construction, but each arm's setup is part of that
  arm's own evidence (rigid vs static is the discriminating variable). A shared
  helper adds a parameterized second convention over two deliberately
  independent arms and saves fewer lines than it costs in indirection.
- **Loop counter `i` in `_frames` (rejected).** Never read (`for i in
  range(n)`), but the fix is a rename (`_i`), not a deletion: zero bytes
  removed. LSP does not model `for`-loop variables at all, so no semantic claim
  is made either way.
- **CASES rows / README / fixture header (no action).** Census
  (`corpus/live/r83-simplifier/arm_census.py`): 186 cases, no duplicate case
  names, no duplicate `(script, flags)` pairs, no duplicate markers; the 10
  fixture `match` arms and the 10 r83 rows are in exact bijection (no unused
  arm, no orphan row); every pinned marker payload appears verbatim in the
  fixture; the README `--only` list names all 10 cases and no unknown name. The
  single `_:` match guard is reachable by a typo'd `--arm=` and is kept (without
  it a bad arm would idle a headless tree into the 20 s SIGKILL — the r83 hazard
  note records exactly that failure mode).

## Preserved contract

The 10 pinned markers and exit codes (9 × exit 0 `PASS …`, 1 × exit 2
`NEGATIVE REJECTED: …`), empty stderr on every case, the threaded child's
`CHILD_RESULT`/`CHILD_NOTE` lines and ≥8/12 refusal threshold, the battery's
before/after seed-digest equality, and all 186 battery cases including the 176
pre-r83 rows — unchanged, at byte level, under the full deletion set.

## Tradeoffs / notes for the integrator

- **Fold shape.** The proposed set touches only
  `corpus/fixtures/phys3d_events.gd`; the 10 `CASES` rows, the README section
  and the fixture's header comments stay byte-identical. Exact anchors are in
  `mkvariants.py` (D1, D2, D4; D5/V6 optional).
- **One citation goes stale.** `reports/round-83/r83-author.md:57-58` cites the
  landed fixture sha256 `6ddf4aef…`. Any fold changes that sha; the same commit
  should update the citation (or record pre/post-fold shas). No landed r83
  report cites *line numbers* into the fixture, so no other reference rots.
- **D2 removes a vestigial capture convention, not the provenance.** The
  `OS.execute` output-array hazard note (fixture comment `495-502`, author
  report) stays; only the throwaway sink binding goes.
- **Cheapest option if fold churn must be minimal:** D1 alone (−2 lines, −29 B,
  zero readability cost, LSP-proven no reader).
- **Dead-seat scratch reused, with one defect recorded.** `lsp_refs.py` /
  `lsp_refs_multi.py` were verified and reused as-is. The inherited
  `run_variant.sh` put `--runs` *inside* the seed dir; because `seed_digests()`
  hashes the seed dir before and after, that layout makes a clean run report
  `seeds_unchanged=false`. This seat's harness keeps every `--runs` path outside
  the variant dir (`corpus/live/r83-simplifier/runs/<V>/`).
- **Unknown / not measured.** Whether a future Godot build turns
  discarded-return calls into runtime warnings (basis for rejecting D3); the
  LSP's cross-file reference behaviour for these symbols (all readers are in the
  same file; nothing outside the fixture names them).

## Tree identity and stop condition

- `git diff --exit-code HEAD -- corpus/fixtures` → clean; `git hash-object`
  over every tracked file under `corpus/fixtures` matches `HEAD` (drift=0);
  `git status --porcelain` lists only pre-existing untracked sibling reports
  under `reports/round-83/` (no tracked modification). All scratch work lives
  under `corpus/live/r83-simplifier/` (`corpus/.gitignore:1` ignores `live/`).
- Stopped here: D3/D5-and-below would trade a convention or a failure-surface
  diagnostic for bytes, i.e. harm an axis. No git mutation, no subagent, no
  judgment of the arm's claim.
