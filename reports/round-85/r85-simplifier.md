# game-dev-3d round 85 — simplifier (seat: simplifier, host: devin)

Wave `shokunin-train-20261101-w16`, lane g3d, post-commit review of `f230443`
(`r85: backend cross-product — jolt_threaded + dummy_refused + srv_phase_delta`;
`phys3d_events.gd` +519/−146, `run_battery.py` +6). Mandate: the
`_spawn_child`/`_child_split` refactor — inlined remnants, dead locals/params,
duplicated tail fragments between the four child bodies, `run_battery` tuple
duplication, comment staleness after the refactor — plus the deferred V2
question: are the parent arms' verdict-compare blocks still duplicated? Every
candidate is built as an anchored variant, replayed against the committed
bytes, and compared row-by-row with the author's committed receipt.

**No deletion was applied.** No tracked edit, no git mutation: HEAD `f230443`,
`git status --porcelain` shows only untracked report/`corpus/live` paths,
`corpus/fixtures/phys3d_events.gd` sha256
`4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355` (byte-equal
to the commit's blob) and `run_battery.py`
`991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5`. All writes
are under `corpus/live/r85-simplifier/` plus this report.

Runtime: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps. Control receipt:
`corpus/live/r85-author/runs/20261014T192404847004Z/verdicts.json`
(`4690496f…`, 191/191 PASS, `seed_digests.phys3d_events.gd = 4bcde2bf…` = the
tracked file, so it ran the committed bytes).

## 0. Result

**Headline: the r85 child-arm additions sit at a local weight minimum.** Every
remaining duplication can be single-sourced, and every single-sourcing costs at
least what it removes (measured, below). Of the four weight-negative candidates
(`VS` −148 B, `VD` −222 B, `VE` −146 B, `VF` −15 B) three buy their bytes with
a measured non-weight cost — a named body's identity plus an orphaned rationale
(VD), the failure attribution (VE), the parent/child binding convention (VF) —
leaving one comment-only deletion (`VS`) that costs no axis at all.

| id | site (committed lines) | change | Δlines | Δbytes | replay | verdict |
|---|---|---|---|---|---|---|
| **VS** | child-section comment `:965-968` | delete the "differ only in …" enumeration (an incomplete difference list), keep the sweep-identity claim + r84/r85 provenance | **−2** | **−148** | 15/15 rows + 191/191 rows identical, all child logs identical | **PROPOSE** (comment-only) |
| VF | `_child_split` `:1162` write-only `floor_b` binding | bare `_mk_body(...)` call | 0 | −15 | 15/15 identical | REJECT — r84 D3/V1 precedent (the parent `:438` binding stays → second convention); LSP `floor_b` refs = **1** (declaration only) |
| VD | `_child_jolt` `:983` + `_child_dummy` `:1018` | inline into the dispatch (`await _child_split("jolt"\|"dummy")`) | −7 | −222 | 15/15 + **191/191** identical | REJECT — each `--child` arm has exactly one named body (LSP n=2 = decl + its dispatch call); inlining 2 of 4 is the second convention the seat forbids, it deletes the 2-line `_child_jolt` doc comment, and it **orphans** `_child_dummy`'s 7-line rationale ("No proc-context fetch loop on this body …") above `_child_split`'s section comment — the deletion creates the stale comment |
| VE | three child arms' whole tail `:741-762`, `:780-800`, `:815-834` | one `_child_case()` (spawn + compare + `_exit_ok`) | −1 | −146 | 15/15 + **191/191** identical | REJECT as proposed — measured cost: the failure backtrace gains a `_child_case` frame (3 stderr lines on a red row, §6), i.e. exactly the attribution the landed `_spawn_child` protects |
| VG | same tail, attribution-preserving form | `_child_tail()` returns the `_fail` text, the arm keeps `_fail` | +4 | **+100** | 15/15 identical, red path byte-identical | REJECT — weight **up**: the duplication is cheaper than its own single-sourcing |
| VA | BLOCKED gate ×3 `:735-740`, `:774-779`, `:809-814` | one `_gate_absent()` | +1 | +147 | 15/15 identical; BLOCKED path identical under a stubbed gate | REJECT — weight up |
| VB | err-check + compare + `_exit_ok` ×3 | one `_child_verdicts()` | 0 | −15 | 15/15 identical | REJECT — dominated by VE, and weight-neutral |
| VC | witness loop ×2 `:934-940`, `:1002-1007` | one `_proc_dss_nulls()` | +2 | +178 | rows identical, **child logs move**: 22 + 23 lines of frame attribution (`_child_threaded`/`_child_jolt_threaded` → `_proc_dss_nulls`) | REJECT — weight up **and** evidence moved |
| VAB / VABC / VAE | combinations | — | +1 / +3 / 0 | +132 / +310 / +1 | VAB, VAE 15/15 identical | REJECT — weight ≥ 0 |

Rejected by measurement, not vibes: each row above has a variant receipt under
`corpus/live/r85-simplifier/runs/<id>/` and a `variants.json` entry with the
exact sha256/byte/line delta.

**Answers to the assigned questions.** (1) Every inlined remnant is gone (§1).
(2) No dead local, parameter or import in the new arms except the pre-existing
`floor_b` binding (§2). (3) The duplicated tail fragments between
`_child_jolt`/`_child_jolt_threaded`/`_child_dummy`/`_child_split` are the
three verdict tails (identical, §3) and the two witness loops (identical,
rejected on evidence); the `_child_jolt`/`_child_dummy` wrappers are 1-line
delegations, not duplicates. (4) `run_battery.py` carries no foldable tuple
duplication (§4). (5) Three stale comment claims, two of them falsified by the
commit's own message and by a receipt inside the same run (§5). (6) **Yes** —
the three parent arms' verdict-compare blocks are still duplicated (21 lines),
and §3 measures why they can stay.

## 1. Inlined remnant census — the V2 fold is complete

The four child-spawn sites all route through one helper, and nothing of the
unfolded protocol survives outside it:

| symbol | occurrences in `phys3d_events.gd` | where |
|---|---|---|
| `make_dir_recursive_absolute` | 1 | `:191` (`_spawn_child`) |
| `globalize_path` | 2 | `:190`, `:199` (`_spawn_child`) |
| `remove_absolute` (stale-log unlink) | 1 | `:211` (`_spawn_child`) |
| `OS.execute` | 1 | `:212` (`_spawn_child`) |
| `timeout -s KILL` | 1 code + 2 comment | `:204`, `:180`, `:201` |
| `child.log` | 1 code + 1 comment | `:200`, `:208` |
| `thrdir`, `joltdir`, `script_err`, `jolt_avail` | **0** | the unfolded arms' locals are gone |
| `selfpath`, `logpath`, `var cmd` | 2 / 4 / 1 | all inside `_spawn_child` |

LSP confirms the same at symbol level: `_spawn_child` refs = **8** =
declaration `187:5` + the four call sites `637/740/779/814` + three comment
mentions `628/728` (0-based lines); `_engine_hint_has` refs = **4** =
declaration + exactly the three gates (`734`, `773`, `808`). The child dispatch
is still total: four arms, each with exactly one named body
(`_child_jolt`/`_child_jolt_threaded`/`_child_dummy`/`_child_threaded` each
n=2 = declaration + its single dispatch call) plus the `var bad:` arm that
exits 2.

## 2. Dead-symbol census (LSP device)

42 positions queried on the committed bytes; **every** query returned a
non-empty result, and the cold-index retry event never fired (0
`retry_after_warmup` lines, `.err` 0 B).

| query (0-based) | n | reading |
|---|---|---|
| `_child_split.floor_b` decl `1161:5` | **1** | **declaration only — the one dead binding in the new code** (r84 V1's candidate, now inside the shared sweep; measured as VF, rejected by precedent) |
| `_child_split.mv_ov` `1243:5` | 2 | one reader: the `CHILD_NOTE` print (`:1249`) — child.log evidence |
| `_child_split.engine` `1042:5` | 2 | one reader: the `CHILD_NOTE` print (`:1044`) |
| `_child_threaded.early_null` `913:5` | 2 | one reader: `CHILD_NOTE early_null=…` (`:955`, the deliberately unpinned note) |
| `jt.nulls` `1001:5` / `thr.nulls` `933:5` | 3 / 3 | read by the counter and the pin (`>= 8`) |
| `_spawn_child` params: `dirname` `187:18`, `project_body` `187:35`, `arm` `187:57`, `allow_inaccessible` `188:2` | 3 / 2 / 5 / 2 | **every parameter is read** — no dead param |
| `_child_split(prefix)` `1025:18` | 16 | heavily read (15 print/key sites) |
| `split.rig` `1162:5`, `split.tp` `1225:5`, `split.q` `1067:5`, `srv.srv_log` `846:7` | 12 / 20 / 5 / 14 | controls: the sweep's locals are read |
| `_frames` `97:5` | 54 | control: the server answers semantically |

No `preload`/`load()` statement exists in the fixture (GDScript resolves the
engine singletons directly), so there is no import to check.

## 3. Duplicated fragments — measured, and why they can stay

The duplication is real and the LSP shows it structurally: the three
reduced-sweep arms read `spawned` with the *same* shape (n=9 each, same
`err`/`code`/`serr`/`verdicts` reads), while `threaded_edge` differs (it
compares `spawned["last"]` against a single `CHILD_RESULT` line at `:644` and
its failure text is `verdict='%s'`, not `verdicts=%s`). That is 21 duplicated
lines (err-check 2 + compare 5, ×3) plus the 3 duplicated gates.

| fold shape | Δlines | Δbytes | green replay | red path (§6) |
|---|---|---|---|---|
| `_child_verdicts(arm, spawned, expect, marker)` (VB: err+compare+exit) | 0 | −15 | identical | — |
| `_child_case(...)` (VE: whole tail incl. spawn) | −1 | −146 | 191/191 identical | **+1 backtrace frame**, 3 stderr lines |
| `_child_tail(arm, spawned, expect) -> String` (VG: arm keeps `_fail`) | +4 | **+100** | identical | **byte-identical** |
| `_gate_absent(arm, engine, label)` (VA: 3 gates) | +1 | +147 | identical | P3 identical |
| `_proc_dss_nulls()` (VC: 2 witness loops) | +2 | +178 | rows identical | child logs: **22 + 23 changed lines** |

The sharp result: **the duplicated tail is cheaper than any single-sourcing of
it.** A helper that does the whole job (VE) only wins bytes by taking the
`_fail` call out of the arm — and that move is visible in the red-path
backtrace (§6), which is precisely the property the landed `_spawn_child`
design protects by *returning* `{"err": …}` instead of failing inside. Written
the same way (VG), the fold is weight-**positive**. The landed shape is the
local minimum on the weight axis.

VC is rejected on a second axis: folding the two witness loops moves the
threaded children's logs — the refusal ERROR lines are attributed to
`_proc_dss_nulls` instead of `_child_threaded` / `_child_jolt_threaded`
(22 changed lines in `thrproj/child.log`, 23 in `joltthrproj/child.log`;
`CHILD_RESULT` lines unchanged). The witness is armed evidence cited by the
author report; re-attributing it is not a byte-neutral move.

## 4. `run_battery.py` tuple census

191 rows total; **15 `phys3d_events` rows ↔ 15 fixture arms, 1:1** — no orphan
arm, no row without an arm (checked both directions). The file's convention is
flat self-contained tuples: `navagent3d_detour.gd` alone carries 91 rows, and
the file contains no row generator (`CASES.append`/`def case`/template: 0
occurrences; `for case in CASES` is the runner loop). The three new markers
(137/155/159 chars) are exact-stdout receipts matched verbatim by `classify`,
so a shared prefix/suffix template would change the authored contract, not the
weight. **Nothing foldable — rejected without a variant.**

## 5. Comment staleness after the refactor (measured)

| id | site | claim | measurement |
|---|---|---|---|
| **S1** | `:998` `# (r85 author probe: 12/12 null on Jolt+threaded, 0/12 on DEFAULT)` | the witness is 12/12 | the author's own report §3.1/§5.2 says **11/12, "not 12/12"**, and the commit message says "threading witness **11/12**"; the receipt in that same run shows **11** refusal ERRORs attributed to `_child_jolt_threaded` (+1 from `_child_split`) with `CHILD_RESULT jt_threaded=true` |
| **S2** | `:1032` `# … 12/12 refusals in the author probe` | the deferred fetch was refused 12/12 | report §3.1 table + F2 + commit message all say **10/10 reps**; the in-battery receipt shows the deferred fetch refused once, then granted by the bounded retry |
| **S3** | `:965-967` `# … differ only in the engine key …, the threading flag and the CHILD_RESULT key prefix;` | a complete difference list | the three child bodies differ **also** by `_child_jolt_threaded`'s pre-sweep witness loop (`:1002-1007`) and by `allow_inaccessible` (`true` for `jolt_threaded`, `false` for the other two) — an enumeration that is already stale in the commit that authored it |

S1/S2 are **repairs, not deletions** (byte-neutral: variant `VT` = +0 B, 15/15
identical) — flagged because a wrong count in a witness comment damages
falsifiability. S3 is the deletion candidate **VS**: dropping the enumeration
(`−2 lines / −148 B`, variant receipt 15/15 + 191/191 identical) keeps the
load-bearing claim ("the sweep is literally the same code … so a class
difference between the three receipts can never be a difference in the sweep
code") and the r84/r85 provenance, and removes an authority that is already
wrong.

One observation outside the commit, **not** a candidate: `corpus/fixtures/README.md`
still ends its `phys3d_events` record at the round-84 section, whose `--only`
command lists 2 of the now-15 rows (`:601`; the round-83 section at `:563`
lists 10). The file has no stale *claim* — the sections are round-scoped
history — but an operator following the newest command runs 2 of 15 cells.

## 6. Unexercised paths — probed, not assumed

The battery never reaches the failure or BLOCKED paths, so a fold there cannot
be proven by replay. `probe_paths.py` corrupts the same input in the committed
file and in the variant and compares the parent's full output (path and line
coordinates normalized):

| probe | input | V0 vs VE | V0 vs VG | V0 vs VA |
|---|---|---|---|---|
| P1 expectation mismatch (one pinned verdict value corrupted) | 3 child arms | message identical, **stderr +3 lines** (`[1] _child_case` inserted before `_run`) | **byte-identical** (stdout, stderr, exit) | — |
| P2 spawn error (`_spawn_child` stubbed) | 3 child arms | message identical, **stderr +3 lines** | **byte-identical** | — |
| P3 gate closed (`_engine_hint_has` stubbed false) | 3 gated arms | — | — | **byte-identical** (`BLOCKED phys3d_events <arm> <label>_absent=true`, exit 1, empty stderr) |

So VE's −146 B is priced: it moves the failure attribution out of the arm. VG
buys that property back for +100 B. VA's BLOCKED row text is provably preserved
(it is rejected on weight, not on evidence). Raw evidence:
`probe_paths_VE.json` / `probe_paths_VG.json` and the line-level
`probe_redpath_diff.txt` (VE: 3 stderr lines on all 3 arms × both probes, 0
stdout lines; VG: 0 diff lines on all 6 pairs).

## 7. Preserved contract, tradeoffs, stop condition

Preserved in every variant above (except where stated): the 191-row battery
receipts (`VE`, `VD`, `VS` run full — all 191/191 PASS, row-identical to the
control), the fixture seed digest being the only seed delta, the four child
logs (`joltproj`/`dummyproj` byte-identical; `thrproj`/`joltthrproj` identical
modulo the absolute scratch path and `phys3d_events.gd:<line>` coordinates,
with unchanged `CHILD_RESULT` lines **and unchanged backtrace frame names**),
every pinned marker and expectation dict, and every provenance comment.

Tradeoffs stated per candidate in §0/§3. **Stop condition:** the next deletion
would remove either the failure-attribution property the landed `_spawn_child`
protects (VE), a named child body's identity (VD), the parent's matching
`floor_b` binding (VF — a sweep-only deletion is a second convention), or a
cited measurement (S1/S2) — each for ≤ 250 B out of 53,771 B (0.5%). The
remaining weight in the r85 diff is prose that carries the cells' rationale;
deleting it would trade evidence for bytes.

## 8. Device record

- **No MCP `lsp` device.** `mcp_list_servers` exposes only `rea` (native-RE
  tools); it does not serve GDScript symbols. Recorded, not used as absence.
- The answering language server is **Godot's own LSP** (headless editor,
  `--lsp-port 8624`), harness `corpus/live/r85-simplifier/lsp_refs.py`
  (inherited from the r83/r84 simplifier scratch, port changed to avoid
  collisions). `initialize` answered with capabilities; 42/42 queries returned
  a non-empty result; warmup 20 s after `didOpen`; the
  `retry_after_warmup` event never fired; `lsp_refs_v0.err` is 0 B. Session ran
  against `lsp-proj/phys3d_events.gd`, sha `4bcde2bf…` = the tracked bytes.
- Text grep was used only as a **literal census** (§1 table, §4 counts), never
  as semantic proof.
- Variant harness: `mkvariants.py` asserts every anchor against the committed
  sha (`4bcde2bf…`) before editing, copies the whole `corpus/fixtures/` tree
  per variant, and records sha256/bytes/lines in `variants.json`; the battery
  runner is copied verbatim (sha `991c6c8a…` in every variant dir), so every
  receipt is the unmodified battery.

### Receipts

`runs/<variant>/<ts>/verdicts.json` (sha256 prefix, rows):

| variant | phys3d receipt | full receipt | fixture sha256 | Δ |
|---|---|---|---|---|
| V0 (calibration) | `193632699590Z` `b5a61b7d` 15/15 | — | `4bcde2bf` | — |
| VA | `193651306027Z` `3ad3cae6` 15/15 | — | `d3767258` | +1 / +147 |
| VB | `193703905997Z` `8b2645a1` 15/15 | — | `20fbca8c` | 0 / −15 |
| VC | `193905746150Z` `1cedf778` 15/15 | — | `f4285b00` | +2 / +178 |
| VD | `193733358941Z` `5f46af7f` 15/15 | `194304816352Z` `174daf92` **191/191** | `6ea03112` | −7 / −222 |
| VE | `193829660942Z` `18079b98` 15/15 | `194005413123Z` `bc08d084` **191/191** | `3e88b36b` | −1 / −146 |
| VF | `193853932398Z` `cac00aa0` 15/15 | — | `6d69c3da` | 0 / −15 |
| VG | `194702417568Z` `fe2cdfda` 15/15 | — | `b72f34f1` | +4 / +100 |
| VS | `194753168641Z` `3d271821` 15/15 | `194825627054Z` `e4388c4f` **191/191** | `b6a7e484` | −2 / −148 |
| VT | `194808224393Z` `e53d2fd3` 15/15 | — | `0ef67eb9` | 0 / 0 |
| VAB | `193746297751Z` `41eefd64` 15/15 | — | `2a47f447` | +1 / +132 |
| VAE | `193841890447Z` `6334a967` 15/15 | — | `e4d3bffb` | 0 / +1 |
| VABC | built, not run (`VC` fails alone) | — | `cae8908d` | +3 / +310 |

`probe_paths_VE.json` / `probe_paths_VG.json` / `probe_redpath_diff.txt` hold
the P1/P2/P3 evidence (V0 vs VE, V0 vs VG, V0 vs VA); `compare.py <V> author
phys3d|full` reproduces every row comparison.
