# r93 simplifier — YAGNI/dead-code review of the committed r93 areasig landing (`661749f`)

Seat: GAME-DEV-3D r93 SIMPLIFIER, read-only. Scope: the committed work commit
`661749f` only — `corpus/fixtures/r93_areasig.gd` (+219, new),
`corpus/fixtures/r93_child.gd` (+875, new), `corpus/fixtures/run_battery.py`
(+28/−1), `reports/round-93/r93-author.md` (+79) — plus its receipts. No fixture
edit, no commit; the only write this seat makes anywhere is this report. The
tree was clean at HEAD `661749f` when this seat started (18:34); by report time a
concurrent sibling lane had landed an **insertion-only r94 diff** — 38 lines of
new `r94_cannon_*` rows in `run_battery.py`, plus `r94_cannon.gd`,
`r94_child.mjs`, `r94vendor/` — with **zero `r93_` lines touched** in either the
diff or the fixtures (`git diff -U0 … | grep -c r93_` = 0; `git status` on both
r93 fixtures empty). Deletion probes ran on throwaway copies under
`/tmp/r93simp/`; receipts under `corpus/live/r93-simplifier/`.

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`. Every battery run in
this report ran at load 99–124 on the 32-core host (§7, `load.txt`).

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer GDScript,
and no `lsp`/`references` tool exists in this toolset — so every call-site claim
below is the **literal grep fallback and is not presented as semantic proof**.
Two facts narrow the gap for these two files: (a) `r93_child.gd` is named by
exactly one seed (`r93_areasig.gd`, `const CHILD`), and `r93_areasig.gd` by
exactly one battery row group; (b) neither file has a reflective call surface —
`set_script`, `Callable`, `callv`, `has_method`, `.call(`, `emit_signal` are all
zero hits in both files (the only `connect(` uses are 12 direct typed signal
connections) — so a method or member name cannot be reached dynamically.
Deletion candidates were therefore *executed*, not just reasoned
about (§3): a wrong "dead" call turns the probe red, which is the empirical
substitute for the missing semantic index.

## 0. Verdict

**PASS — no bar-meeting defect; the landing is 1094 new lines of measurement
surface whose legs all fired, with ~8 lines of genuinely removable dead weight
(verified by executed probes, zero marker delta) and 3 pin fields that restate
configuration instead of measuring (not removable without re-pinning).**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | child: `var rid_a: RID` (99) + `rid_a = area_a.get_rid()` (821) — assigned, never read (`rid_b` is read by `_teleport_area_b`) | **−2 lines** | census: 2 occurrences, 1 is the declaration, 1 the assignment; probeA executed | **take** |
| **SP-2** | parent: `"dir": dir` key in `_child_prepare`'s returned dict (155) — `_spawn_batch`/`_scan` read only `cmd`, `logpath`, `pid` | **−0 lines** (same-line edit) | census: `["dir"]` has 0 readers; probeA executed | **take** |
| **SP-3** | child: the `"tif": pass` / `"tsig": pass` no-op match arms in `on_e` (347–350) — both cases' E-time action is elsewhere (`on_if`, the handler) | **−4 lines** | `match` needs no exhaustive arm; probeA executed | **take** |
| **SP-4** | child: 4 record payload entries with no reader — `"seq": seq` (153), `IF{"body"}` (244), `F{"ovA"}` (262), `E{"monA"}` (382); the E literal also folds 2 lines → 1 | **−1 line net** (3 further sub-line edits) | every `ev` reader is enumerated in §3.4; probeA executed | **take** |
| **SP-5** | child: `b.max_contacts_reported = 8` (778) — no contact datum is read anywhere in the fixture | **−1 line** | probeC executed (probeA + SP-5) | **take (weak)** — see §3.5 |
| **F1** | child: trailing `return 20` in `budget()` (275) — looks unreachable (all 18 cases are enumerated above it) | 0 | **probeB turned it into a Parse error** — the `-> int` annotation requires the terminal return | **reject — retained, §5.1** |

Bar-meeting total: **−8 net lines** of 1094 added (probeC), zero marker delta,
verified by execution. Everything else in the diff is retained measurement
surface or a below-bar candidate (§4).

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

- `corpus/live/r93-author/battery/verdicts-run{1,2,3}.json` — recomputed: run 1
  **265/265** `seeds_unchanged=true`; run 2 **262/265** (fails
  `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang`,
  `phys3d_joints_free_ops`); run 3 **260/265** (the same trio +
  `navagent3d_retarget`, `navagent3d_retarget_fixed`). Every non-pass row in
  runs 2/3 is on the documented load-flake lists (`r93-baseline` F1/F2,
  `r93-baseline2`, `r92-verifier2`).
- `corpus/live/r93-author/SHA256SUMS` — **1304 files hashed, 0 mismatched, 0
  missing** (recomputed from `corpus/live/r93-author/`).
- `corpus/live/r93-author/runs/` — 1296 files = 8 reps × 18 cases × 3 backends ×
  3 artefacts, i.e. the claimed 432 child runs.
- The pinned markers in `corpus/fixtures/run_battery.py` (exact-line contract,
  `classify()` requires the marker to be an exact stdout line).
- This seat's own receipts (§7): `battery-r93only/` (7/7, `seeds_unchanged=true`),
  `battery-full/` (259/265, `seeds_unchanged=false` — cause identified in §7.1),
  `battery-full2/` (260/265, same caveat), `probes/probe{A,B,C}.*`.

**Independent rep test (recomputed, not quoted).** The 7 r93 rows are
**byte-identical across six independent executions** — the author's three full
runs, this seat's r93-only run, and both of this seat's full runs:
`r93_areasig_edges 10694b9c…`, `_writes c1891d00…`, `_exits a7479a82…`,
`_dispatch 5cfe0275…`, `_splits d662cfab…`, `_multi 15d17720…`,
`_prio 5508b048…` (sha256 of the joined stdout lines, recomputed per run;
`probes/` and the two `battery-full*` verdicts are the raw material). The
committed `r93_child.gd` is `fac6b439…` — the author's run-2/3 seed — so the
author's byte-precision note (run 1 ran `610905a0…`, differing only in a
`#`-diagnostic label) is confirmed end-to-end by this seat's runs on the
committed bytes.

## 2. Arm/leg firing audit — no CASES row has a dead arm

| row | arm | legs in `ARM_CASES` | cells observed (backend × leg) | fired |
|---|---|---|---|---|
| r93_areasig_edges | edges | enter, enter0, tele | 3×3 = 9 | all |
| r93_areasig_writes | writes | tif, tsig, monoff, monif | 3×4 = 12 | all |
| r93_areasig_exits | exits | freeq, freerid | 3×2 = 6 | all |
| r93_areasig_dispatch | dispatch | monsig, moncycle, monoff0 | 3×3 = 9 | all |
| r93_areasig_splits | splits | telefr, monitoff | 3×2 = 6 | all |
| r93_areasig_multi | multi | multi, areasig, bodysig | 3×3 = 9 | all |
| r93_areasig_prio | prio | prio | 3×1 = 3 | all |

54 cells = 18 cases × 3 backends, exactly as the author states. The 18 case
names are distinct and each appears in exactly one `ARM_CASES` list; the
child's `on_e` match, `budget()`, `_facts()` match and `_digest()` `anchors` all
cover the same 18 names (checked one by one), so no arm, leg, case branch or
anchor entry in the landed diff is unreachable from a CASES row. Across the
whole battery: **265 rows, 265 unique case names, 265 unique `(script, flags)`
pairs, 218 exit-0 + 47 exit-2, zero duplicate rows.** The `run_battery.py` hunk
is **insertion-only**: the single `-` line is the `r92_timing_steps` row
re-emitted byte-identically plus the comma that was missing at the splice point
(verified by string comparison with the trailing comma stripped).

Rep-stability contract holds on the pinned surface, recomputed over all 54
cells: no `seq=` token appears in any `M` row, and no cell contains a `#`
diagnostic (the order diagnostics stay in the child log, which the parent's
`_scan` filters to `M0`/`M` only).

## 3. SP list — deletions that meet the bar, each verified by execution

Method: copy `corpus/fixtures/` to `/tmp/r93simp/probe{X}/`, apply the fold,
run the seven r93 rows through that copy's own `run_battery.py` (which seeds its
scratch from its own directory), then byte-compare the seven stdout lines against
the committed baseline. Diffs and verdicts are in
`corpus/live/r93-simplifier/probes/`.

- **probeA** (SP-1…SP-4): child −11/+4 = **−7 net lines**, parent −1/+1.
  Result **7/7 PASS**, and **all 7 rows byte-identical** to the committed
  baseline.
- **probeC** (probeA + SP-5): child −12/+4 = **−8 net lines**.
  Result **7/7 PASS**, **all 7 rows byte-identical**.
- **probeB** (probeC + F1): **7/7 FAIL** — `Failed to load script "…/r93_child.gd"
  with error "Parse error"` on every cell. That is the falsification of F1, not
  of the SP set (§5.1).

### 3.1 SP-1 · `rid_a` (2 lines)

`r93_child.gd:99` `var rid_a: RID`; `:821` `rid_a = area_a.get_rid()`. Two
occurrences in the file: the declaration and the assignment. `rid_b` — the
sibling the same code path builds — *is* read (`:285` `area_set_transform(rid_b,
…)`), which is what makes `rid_a` look load-bearing at a glance. It is not:
every `area_a` write in the fixture goes through `area_a.<property>` or
`PhysicsServer3D.body_set_state(rids[i], …)`, never through `rid_a`. No
reflective surface (§LSP note), so no dynamic reader exists.

### 3.2 SP-2 · the `"dir"` key in the prepared-child dict (same-line)

`r93_areasig.gd:155` returns `{"dir": dir, "logpath": logpath, "cmd": cmd}`.
`_spawn_batch` reads `spec["dirname"]` (input), then `prep["cmd"]`,
`prep["logpath"]`, `prep["pid"]`; `_scan` reads `prep["logpath"]`. `["dir"]` has
zero readers in either fixture — grep over the whole repository finds
`r93_areasig.gd:155` as its only occurrence. Removing it is a same-line edit
(0 lines saved), which is why it is listed separately from the line-count total.

### 3.3 SP-3 · the two no-op match arms (4 lines)

`r93_child.gd:347–350`:
```
		"tif":
			pass
		"tsig":
			pass
```
Both cases exist and both are exercised — their E-time behaviour is simply "no
action": `tif` acts inside `on_if` (`:246`), `tsig` acts inside
`_on_a_body_entered` (`:178`). GDScript `match` is non-exhaustive, so the arms
are pure no-ops. Zero-delta, proven by probeA.

### 3.4 SP-4 · four record payloads with no reader (4 sub-line edits, −2 net lines)

`_rec()` buffers `{k, pf, seq, f}` for every event; `_sig_cls`, `_anchor`,
`_emit_sig`, `_facts` and the prio/monsig fact builders are the *complete* set of
readers, and they read exactly: `k`, `pf`, `f.by`, `f.ovA`, `f.ovB`, `f.ifc`,
`f.t`, `f.msg`, and — on SIG rows only — `f.area`, `f.sig`, `f.body`, `f.tgt`,
`f.bsi`, `f.lsi`, `f.asi`, `f.ov`, `f.ovn`, `f.mon`. Enumerating the writers
against that list leaves four write-only entries:

| line | payload | why it is unreachable |
|---|---|---|
| 153 | `"seq": seq` | `["seq"]` occurs only in this literal; `seq` itself is printed, the buffered copy is never read |
| 244 | `_rec("IF", {"body": b.name})` | the only `k=="IF"` readers test `pf`; `f.body` is read only on SIG rows |
| 262 | `_rec("F", {"ovA": ova})` | the only `k=="F"` reader tests `pf`; the `ovA=` field in the *printed* F row comes from the local `ova`, not the record |
| 382 | `"monA": str(area_a.monitoring)` | the E-record readers take `t`/`by`/`ovA`/`ovB`/`ifc`; the printed E row formats `str(area_a.monitoring)` itself |

The E literal also collapses from two lines to one, so this fold is −1 net line
(the other three are sub-line edits). All four are side-effect-free value reads
(`seq`, `b.name`, `ova`, `str(...)`), so removing them cannot change the printed
stream — and probeA confirms it byte-for-byte.

### 3.5 SP-5 · `max_contacts_reported = 8` (1 line) — take, weak

`r93_child.gd:778`. No contact datum is read anywhere in the fixture: the
measurement surface is transforms (`body_get_state`), overlap lists
(`get_overlapping_*`) and signal emission points. `max_contacts_reported` only
sizes the body's contact-report buffer. probeC (probeA + this) is 7/7 and
byte-identical, so the line is removable with no observable delta. It is ranked
weak because it is harmless realism rather than a contradiction — a reader may
prefer to keep the body shaped like a normal game body. Take or drop, either way
the pin surface does not move.

## 4. Candidates found, below the bar (recorded, not deleted)

**C-1 · the parent's spawn machinery is a 4th copy (~92 lines).**
`r93_areasig.gd` lines 110–219 (`_cell` → EOF) are a 111-line near-copy of the
98-line block that is byte-identical across `r92_remote.gd`, `r92_animphys.gd`
and `r92_timing.gd` (sha `a2d7db40…` for all three): **92 of the 111 lines are
byte-identical**, and the remaining 19 are exactly four functional deltas — the
`et` cell field, its collection in `_scan`, the `~`-join, `--fixed-fps 60` in the
spawn command, and the Jolt job-system `WARNING:` filter (recomputed with
`difflib.SequenceMatcher` over the two tails).
**Why below bar:** unchanged from the r92 simplifier's C-1 — no existing seed
*provides* this machinery, and extracting a shared module/base class creates a
second spawn convention in a corpus whose standing rule is per-fixture
self-containment. A corpus-wide decision, not a round-diff deletion.

**C-2 · three pin fields that restate configuration instead of measuring.**
Verified over the pinned cells:

| field | where | why it cannot discriminate |
|---|---|---|
| `in_write=<n>` | `monoff`/`monif`/`moncycle` facts | the same counter as `flush_sigs` — the print passes `flush_n` twice (`:527`, `:553`). All 9 occurrences in the battery carry equal values (`0 in_write=0` ×3, `2 in_write=2` ×6). It *reads* like a second, independent fact ("flushed inside the write"); it is the first fact printed twice. |
| `flush_sigs=0` | `monsig` facts | a **literal in the format string** (`:540`), not a measurement — it cannot ever be anything else. The real evidence for "no flush" is the absence of sig rows plus `readback=true` + `e=1`/`et=`. |
| `off_from_init=1` | `monoff0` facts | a **literal** (`:562`) — a label for the case setup. The measurement in that cell is `redetect=`. |

Related, same family: `refused=<0|1>` in `monsig` is set by the presence of the
`ACT` row (`:537–539`), i.e. it proves *the handler body ran*, not that the
engine refused. The refusal itself is carried by `e=1` + the exact `et=` text.
**Why below bar:** every one of these is embedded in a pinned marker, so
deleting or fixing a field is a marker re-pin — a contract change, not a
simplification, and outside a read-only seat. Flagged so a future re-pin does
not re-import the redundancy.

**C-3 · the `#` order-diagnostic emitter (~15 lines, `:726–740`) has no
automated reader.** No tooling in `corpus/live/r93-author/` or
`corpus/live/r93-boundary/` parses `#` lines, and the values are deliberately
unpinned (`seqeq=-`/`pairs=-` on Jolt). **Why below bar:** it is the only
human-visible evidence for the quantity that was deliberately left free; keeping
an unpinned axis observable is the point of leaving it observable. Retained.

**C-4 · the raw-row print layer (9 print sites) never reaches a cell.** The
parent's `_scan` keeps `M0`/`M` only, so `PRE`/`IF`/`SIG`/`E`/`F`/`ACT`/`DONE`/
`DONE_ALL` exist for the receipt tree. **Why below bar:** it is the evidence layer
the digest is *derived* from, and it has a real consumer —
`corpus/live/r93-boundary/check.py` re-derives the positional classes from
`IF `/`SIG `/`E ` line order (its `_sig_cls` analogue), which is how the
boundary falsifiers and the mutation masks (`stamp_shift`, `move_to_idle`) were
built. Retained. Two cosmetic defects worth one line each, both in that layer
only:
`SIG` rows label an area's own overlap `ovA=` even for `B` signals (`:165`), and
`E` rows print `monA=` (A's `monitoring`) next to `monB=` (B's `monitorable`) —
two different properties under parallel names. Neither reaches an `M` cell
(`_emit_sig` uses `ov=`/`n=`/`m=`, `_anchor` uses `ifc=`), so neither can move a
pin.

**C-5 · `floor_node` is a member variable used only inside `_initialize`.**
`:96`, `:795–802`. Every other member (`area_a`, `area_b`, `rid_b`, `balls`,
`rids`, `home_x`) crosses a function boundary; this one does not. A local would
be tidier; 0 lines saved, 0 observable delta. Below bar.

**C-6 · derived summaries duplicate lower-level rows.** For
`enter`/`enter0`/`tele`/`tif`/`tsig`/`freerid` the `facts entry=<pf> exit=<pf>`
line restates pfs that already appear in the `s` rows, and `telefr`'s
`detected=` restates `nsig`. **Why below bar:** the summary is the readable
contract (a sig-row renumbering must not silently move the semantic pin), and
it costs one line per case. Retained.

## 5. Checked and deliberately retained (not dead)

**5.1 `budget()`'s trailing `return 20` (`:275`) — retained; its removal is a
Parse error.** The `match` above it enumerates all 18 cases, so at runtime the
line is unreachable. Removing it (probeB) does not merely fail a marker: the
child fails to *load* — every cell becomes
`rc=1, m=, e=1, et=Failed to load script "…/r93_child.gd" with error "Parse
error".` The `-> int` annotation requires a terminal return on every path, so
the "dead" line is load-bearing for the parse. This is the one candidate the
probe *rejected*, and it is why the SP set is 8 lines rather than 9.

**5.2 fail-closed guards, none exercised by any receipt, all deliberate:**
`_run`'s unknown-arm FAIL (`:87–90`), `_cell`'s `err` branch (`:111–112`),
`_child_prepare`'s dirname whitelist and three failure branches (`:131–148`),
`_spawn_batch`'s `cannot create child process` + deadline/kill (`:196–217`),
`_scan`'s `child log missing` and its `s` counter (`:161–183`). These are the
same remediation-bearing conventions the r89/r90 simplifier reports kept; the
`et` floor they feed *is* exercised (14 cells carry `e>0` with the exact text).

**5.3 the classification buckets that are empty on the pinned surface:**
`_sig_cls`'s `pre_if` ("law violation — never seen") and `other` (`:425–430`),
plus `census`'s `idle`. All three print `0` in every cell. They are the
falsification surface — a violation must be *named*, not silently counted as
`post_e` — so they stay.

**5.4 Dummy cells.** `nif=0`, `nsig=0`, `entry=-`, `by=n/a` on all 18 Dummy
cells: vacuous by design and backend-qualified, per the folded boundary
correction. Not a missing measurement.

**5.5 `CANON_CASES` + both `_emit_sig` branches.** `multi`/`areasig`/`monitoff`/
`prio` take the canonical branch (order-free pins), the other 14 take the
raw-order branch; both are exercised in every battery pass.

**5.6 the `et` expected-error floor.** 14 of 54 cells carry `e>0`; the distinct
texts are pinned per cell (`monoff`/`monif` `e=30`, `monoff0` `e=116`,
`moncycle` `e=6`, `freerid` `e=3` with the GP/Jolt teardown split, `monsig`
`e=1` with the dispatch refusal). This is the gate that makes "a pinned refusal
must actually fire, with the pinned text, and only that text" checkable — it is
the highest-value part of the new surface, not weight to trim.

## 6. Weight summary, tradeoff, stop condition

Bar-meeting deletions: **8 net lines** (SP-1 2, SP-3 4, SP-4 1, SP-5 1, SP-2
same-line) out of 1094 added, all with zero marker delta *verified by execution*
on the committed bytes. The remaining ~1086 lines
are new measurement surface whose legs all fired, whose pins are byte-stable
across 6 independent executions (three of them loaded), and whose one
non-obvious "dead" line turned out to be parse-load-bearing.

The next candidate (C-1, ~92 lines) needs a corpus-wide convention decision;
C-2 is 3 field fixes that require re-pinning markers; C-3/C-4/C-6 trade
observability of an unpinned axis or the readable contract for bytes;
C-5 saves nothing. **Stop here.**

## 7. Load observations, receipts, residual risks

Receipts: `corpus/live/r93-simplifier/{battery-r93only,battery-full,battery-full2,probes,load.txt}`.

| run | when | load 1/5/15 | result |
|---|---|---|---|
| `battery-r93only` | 21:35:59Z | 108.38/105.82/100.03 | **7/7 PASS**, `seeds_unchanged=true` |
| `battery-full` (#1) | 21:36:21Z→21:45 | 99–120 | **259/265**; 7/7 r93 PASS; `seeds_unchanged=false` (§7.1) |
| `battery-full2` (#2) | 21:46Z→21:57 | ~100–124 | **260/265**; 7/7 r93 PASS; `seeds_unchanged=false` (§7.1) |

Battery #2's five FAILs are `navagent3d_retarget`, `navagent3d_retarget_fixed`,
`navagent3d_follow`, `phys3d_events_script_size_gate`, `phys3d_joints_free_ops`
— all on the documented flake lists; `phys3d_events_deferred_hang` passed in #2
(it failed in #1 and in the author's runs 2/3). In both full runs the seven r93
rows are **byte-identical to the committed baseline** — five independent
executions of the committed bytes now agree exactly (§1).

### 7.1 Both full runs' `seeds_unchanged=false` — cause identified, not the r93 landing

Both full runs tripped the battery's own seed-tree integrity check, and in both
the cause is a **concurrent sibling lane writing into `corpus/fixtures/`**, not
this seat and not the r93 landing:

- Run #1 (window 18:36–18:45): `corpus/fixtures/r94vendor/` appears at 18:42 and
  `r94_child.mjs` at 18:45.
- Run #2 (window 18:46–18:57): the same lane edits the **tracked**
  `corpus/fixtures/run_battery.py` (18:52, +38 lines, all `r94_cannon_*`) and
  adds `r94_cannon.gd` (18:50).

`seed_digests()` hashes every file under the seed dir (excluding `__pycache__`
and `three/`), so it is sensitive to exactly these writes — including the edit to
`run_battery.py`, a file the battery *excludes from the scratch copy* and which
therefore cannot affect what executes. The r93-only run six minutes before #1 is
`seeds_unchanged=true`.

The flag does not invalidate what was executed: the battery copies the seeds to
`<run>/scratch` *before* the first case, and both runs' scratch snapshots carry
`r93_child.gd`/`r93_areasig.gd` byte-identical to the committed files
(`fac6b439…` / `e4b04006…`, checked for #1). So both full runs executed the
committed r93 bytes, and the r93 rows' stdout is byte-identical to the committed
baseline in both. What the flag cannot certify is that the *seed tree* stayed
read-only for the ~10 minutes — a property no seat on this host can hold while
sibling lanes land fixtures. **The receipt to cite for the r93 surface is
`battery-r93only` (clean flag); the full runs are corroboration with a
concurrency caveat.**

### 7.2 Findings ranked

1. **[MEDIUM — outside the assigned diff, for the L1]** Under load 99–124 the
   two full batteries show **6 and 5 FAILs, all on-record flakes**:
   `navagent3d_retarget`, `navagent3d_retarget_fixed`, `navagent3d_follow`
   (one-tick miss: `before=1.754246` vs pinned `1.730676`, `first=1.636395` vs
   pinned `1.612825` — both exactly `+0.023570 = √2/60`),
   `phys3d_events_script_size_gate` + `phys3d_events_deferred_hang` (size-gate
   granted-under-load; the pair split across the two runs) and
   `phys3d_joints_free_ops` (20 s bound, `None/0`). The r93 rows are **not** in
   that class — they passed byte-identically in all six executions. Not this
   seat's call whether the navagent family's post-`fc6d033` state is "fixed";
   recorded only because a "green" claim on this host is load-conditional, and
   the wave-B gates are being run under load by design.
2. **[LOW]** The r93 rows' wall time under load ~110 is 0.98–4.48 s
   (max `writes` 4.48 s) against the parent's 20 s batch bound and 10 s
   per-child `timeout -s KILL` — ≈4.5× margin. Beyond that the failure mode is a
   kill, i.e. a *new* flake class for these rows; no such event in 6 runs.
3. **[LOW]** No mutation-detection evidence exists for the r93 rows:
   `run_battery.py`'s `--probe-failing` anchor is still `body3d_contact`
   (`BOX_SIZE` 4→6), so the new rows' detection evidence is the exact-marker
   contract itself (they fail if any cell byte moves — as probeB demonstrates).
   Same posture as every other row added since that anchor was chosen.
4. **[INFO]** `r93-author.md`'s prose compresses two distinct engine lines into
   one (`Can't find overlapping bodies/areas when monitoring is off.`); the
   pinned `et=` carries them separately, joined by `~` (`…bodies when monitoring
   is off.~Can't find overlapping areas when monitoring is off.`). Fixture
   text is correct; only the report shorthand differs.

### 7.3 Blockers

**None for the assigned implementation.** Two caveats for whoever consumes the
receipts: (a) both full batteries' `seeds_unchanged=false` is caused by the
concurrent r94 lane (§7.1) — the clean `battery-r93only` receipt is the one to
cite for the r93 surface; (b) this seat could not use the `lsp` device (only
`rea` is bound), so §3's call-site claims are grep + executed-probe evidence, not
semantic proof.

No fixture was edited, nothing was committed, and no descendant was spawned: the
seat's one read-only `labrat` allowance was not used, because every deletion
candidate in §3 was settled by *executing* it against the committed bytes rather
than by a further advisory probe. Stopping here.
