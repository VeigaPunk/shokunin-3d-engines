# r100 simplifier — gate on the committed r100 capstone landing (`8183191`)

Seat: **GAME-DEV-3D r100 SIMPLIFIER**, read-only on tracked files. Scope: the
committed landing `8183191f789acca8f3f0292392a1ee84fe317a50` only —
`corpus/fixtures/r100_fpslat.gd` (+892, new) and the **r100 block** in
`corpus/fixtures/run_battery.py` (lines 877–915, +39/−0, insertion-only;
recomputed here) — plus the six `corpus/fixtures/r100_probe_r100b_*.gd` seeds
that the block references (untracked at seat start, byte-identical to the
boundary probes, recomputed). **Zero tracked writes by this seat; the only
tracked write is this report** (all receipts under the gitignored
`corpus/live/r100-simplifier/`; no commit made).

**HEAD moved once during the seat (benign, verified).** Seat start: `8183191`.
Mid-seat the orchestrator committed `523c943` *"r100 landing fix: commit the six
r100_probe_r100b_* seeds (reviewer F1)"* — `git show --stat 523c943` = the six
probe seeds only (+710), and `git diff 8183191 523c943 -- corpus/fixtures/r100_fpslat.gd
corpus/fixtures/run_battery.py` is **empty**, so the two foldable files are
byte-identical across the move. The six committed probe blobs are byte-identical
to the seed copies this seat ran (recomputed, §1.1). Every claim below is pinned
to the `8183191` bytes of those two files, which are also `523c943`'s bytes.

**LSP device: unavailable to this seat.** `mcp_list_servers` returns exactly one
server, `rea` (Ghidra/REA binary analysis); there is no
`lsp`/`references`/`definition`/`code-action` tool in this toolset, so no server
can answer `r100_fpslat.gd` or `run_battery.py`. **Recorded as unavailability**
(same as r97/r98/r99). The gap is narrowed by shape and closed by execution: the
landing has no reflection and no dynamic-name dispatch, cell tables are literal
dicts, and **every fold below was executed** (fresh before/after battery runs at
cell granularity), not merely censused. Text grep is used only as the literal
fallback and is never presented as semantic proof. No rename was performed by
this seat.

Environment: Godot `4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`),
`--headless`; `/usr/bin/python3`; 32-core host, **loadavg 3.97–6.20 across the
seat's 16 battery invocations** (recorded per run in `runs/<label>.log`). Three
sibling lanes ran concurrently on the same host during the seat (an r100 critic
full-battery mutant at `/var/tmp/r100-critic`, the r100 verifier full battery
from its own archive checkout `/home/vgpnk/g3d-r100-8183191` — not touched by
this seat — and r92/r96 audio lanes); every run records its own load
before→after, and the r100 rows are wall-clock-insensitive by design (wall-clock
lines are dropped before hashing).

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. Three folds are proven
behavior-preserving by fresh before/after runs at cell granularity: SP-1
(−2 lines, the write-only `w` counter + the two unread result keys `"m"`/`"w"`)
and SP-2 (−7 lines, the dead `leak` allowlist path) are **take**; SP-3 (5 edits,
0 net lines, unreachable `.get` defaults on the normalized spawn-spec contract)
is **take-or-drop (weak)**. Every fold run passed 8/8 rows with **0 cells moved**
against two independent baselines, and an independent pin audit re-derived
188/188 checks per run (187 for the control runs, §1.4). Two candidates are
**refuted by census** (`spec.get("rc", 0)` and the `bound` *key* are live — the
r99 SP-2/SP-3 shapes do not transfer).
Two detection controls are non-vacuous: a one-cell fixture mutation moved
exactly 1 cell and reddened exactly 1 row; a one-line probe shift moved exactly
the 6 cells whose streams embed probe line numbers. SP-2's only executed delta is
a *latent* capability (`e=["leak"]`, selected by no cell) — demonstrated
precisely by a synthetic scanner probe and named as the tradeoff.**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | `r100_fpslat.gd`: the write-only `w` counter (decl L589, `w += 1` L600) and the two unread result keys `"m"`/`"w"` in the L628 return; plus the stale header clause "counted in w" (L23) | **−2 lines** (4 edits) | probeA1f + probeA2f = 8/8 rows PASS each, **0 cell diffs** vs both baselines, pin audit 188/188; the scanner probe is byte-identical to the seed for all three allow cases | **take** |
| **SP-2** | `r100_fpslat.gd`: `ERR_ALLOW` `"leak"` sentinel (L129), the unreachable `if head == "leak": continue` guard (L579–580), the unreachable `allow.has("leak")` branch (L616–618 → 4 lines), header prose L113–115; plus the r100 block comment clause "leak the ObjectDB class" (`run_battery.py` L891) | **−7 lines** (5 edits) | probeB1f = 8/8 rows PASS, **0 cell diffs**, pin audit 188/188; scanner probe differs from the seed **only** in the `allow=["leak"]` case (removed latent class) | **take** |
| **SP-3** | `r100_fpslat.gd`: 5 unreachable `.get(k, default)` reads on the normalized spawn spec (`bound` ×2, `eargs`, `e`, `done`) → direct `spec[k]` | 0 lines (5 edits) | probeC1f = 8/8 rows PASS, **0 cell diffs**, pin audit 188/188; scanner probe byte-identical | **take-or-drop (weak)** |
| **SP-F** | SP-1 + SP-2 + SP-3 together | **−9 lines** | probeF1f = 8/8 rows PASS, **0 cell diffs**, pin audit 188/188 | **take** |
| R-1 | `spec.get("rc", 0)` in `_cell_ok` (r99 SP-3 analogue) | — | **refuted**: `writemovie` sets `"rc": 134`, `noquit_unbound` sets `"rc": 137`; both pins re-derive | **drop** |
| R-2 | `spec.get("bound", BOUND_S)` as a *knob* (r99 SP-2 analogue: "no spec sets it") | — | **refuted as a knob**: `fdelay200_qa40` sets `bound: 13`, `noquit_unbound` sets `bound: 5`; only the *default* is unreachable (that is SP-3) | **drop as stated** |

Findings filed (not this seat's call): **F-1** LOW — probe line numbers live
inside the hashed stream: 6 of 142 cells (`life` `err@*`, `finalize_touch@*`)
hash `res://r100b_life.gd:68` / `:91`; a one-line shift in the life probe moves
exactly those 6 cells (control probeE1f). **F-2** LOW — the committed author
report says `r100_fpslat.gd` is "879 lines"; the committed blob is **892** lines
(a stale count; the landing's own bytes are what every run above was pinned to).
**F-3** INFO — guard-only normalizations kept: the Jolt WARN pair skip (0/142
logs in this seat's runs; the author's boundary corpus measured it at 38–92%
under load), the `FPS:` wall prefix (0/142), the `_id_re` mask (0/142 — no `#`
at all in any child log), and the `_leak_re` routing (0/142). **F-4** INFO — the
r99 vestiges SP-1/SP-2 target are still present in `r99_animtree.gd`
(`"leak": ["leak"]` L134, guard L498, `var w` L508, `"m"`/`"w"` keys L546); the
r99 simplifier proved the same folds and they were not landed — the r100 driver
inherited the shape. Out of this seat's scope.

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Frozen seed (an archive checkout under `/home`)

```
git archive 8183191 corpus/fixtures | tar -x -C corpus/live/r100-simplifier/seed-frozen --strip-components=2
cp corpus/fixtures/r100_probe_r100b_*.gd corpus/live/r100-simplifier/seed-frozen/
```

`scripts/verify_seed.py`: **140/140 tracked blobs byte-equal** to
`git show 8183191:<path>` (0 mismatches, 0 missing) and **6/6 probe seeds
byte-identical (`cmp`) to `corpus/live/r100-boundary/probes/r100b_*.gd`**; 146
files in the seed, no unexpected file. After the mid-seat commit the six probe
blobs in `523c943` were re-compared to the seed: **6/6 identical**. Every run
below starts from this seed or from a byte-reproducible edit of it
(`scripts/prepare_trees.py`, strict unique anchors, aborts on any drift), never
from the live tree.

```
da11495de7a24703a911bb1c8fef15ba62481e5f492bda1efd56fc3b1950b537  r100_fpslat.gd     (892 lines)
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  run_battery.py     (1387 lines; r100 block = 877–915)
a577d6265f78f1ff337b09a7169a236044b0bd2b16ddfdf416d90e9364d4469d  r100_probe_r100b_area.gd
0adf98aadd38cdc62b60742e3fb393566586cc531706edc3b3ebb98df2a45e03  r100_probe_r100b_cls.gd
427fc7d159f524da345c0b684b13c6d66690aa59f7e9afc6f73bbab1fb1ad760  r100_probe_r100b_life.gd
249c0caf8ac4a1d5270beccadd65d99d0083a1db77264d56958a8ec0ac884896  r100_probe_r100b_modes.gd
8bfd76adf5ae5551eb870524c7677ea24755ac068f71b1d1936e1fd298cb2585  r100_probe_r100b_rt.gd
c61025594deff49dfbd7819376a9e6379dca6efb5c6d7b0aa149aa79cbc86849  r100_probe_r100b_sched.gd
```

### 1.2 Battery runs (8 r100 rows = 142 cells / 142 children per pass)

Every run: `run_battery.py --only <8 r100 rows>` from the tree under test,
`--headless`, the battery's own 20 s case cap, every child `timeout -s KILL`
bounded. "moved cells" = cell-level diff of the observed aggregate line vs the
named baseline (`scripts/analyze.py compare`); `wall` and load before→after are
from `runs/<label>.log`. The fold trees were rebuilt once (to carry the SP-1/SP-2
prose and block-comment edits), so **every fold was run twice, on both tree
revisions** — pre-final (`probe*1`) and final (`probe*1f`) — with identical
verdicts and identical (zero) cell movement.

| run | tree | verdict | moved cells vs ref1 / ref2 | wall | load before→after |
|---|---|---|---|---|---|
| `ref1` | seed-frozen | **PASS 8/8** | — (baseline) | 36 s | 3.97→6.08 |
| `ref2` | seed-frozen | **PASS 8/8** | **0** | 36 s | 5.84→5.90 |
| `probeA1` | probeA (−2, pre-prose) | **PASS 8/8** | 0 | 36 s | 5.51→6.20 |
| `probeA2` | probeA (−2, pre-prose) | **PASS 8/8** | 0 | 35 s | 6.20→5.71 |
| `probeB1` | probeB (−7, pre-comment) | **PASS 8/8** | 0 | 36 s | 5.71→5.38 |
| `probeC1` | probeC (0) | **PASS 8/8** | 0 | 34 s | 5.38→5.20 |
| `probeF1` | probeF (−9, pre-prose) | **PASS 8/8** | 0 | 36 s | 5.20→4.15 |
| `probeD1` | probeD (control) | **FAIL 7/8** (intended) | **1** (`ffpsdup_30_60 eq 1→0`) | 35 s | 4.15→5.11 |
| `probeE1` | probeE (control) | **FAIL 7/8** (intended) | **6** (`err@*`, `finalize_touch@*`) | 37 s | 5.11→5.19 |
| `probeA1f` | probeA **final** | **PASS 8/8** | 0 | 35 s | 4.20→5.30 |
| `probeA2f` | probeA **final** | **PASS 8/8** | 0 | 35 s | 5.30→5.43 |
| `probeB1f` | probeB **final** | **PASS 8/8** | 0 | 34 s | 5.43→4.95 |
| `probeC1f` | probeC **final** | **PASS 8/8** | 0 | 37 s | 4.95→6.01 |
| `probeF1f` | probeF **final** | **PASS 8/8** | 0 | 34 s | 6.01→6.11 |
| `probeD1f` | probeD **final** | **FAIL 7/8** (intended) | **1** | 33 s | 6.11→5.05 |
| `probeE1f` | probeE **final** | **FAIL 7/8** (intended) | **6** | 36 s | 5.05→5.72 |

`seeds_unchanged=true` in every run; the battery's own exact-marker check is the
authority and it is green on every non-control tree, and each tree's observed
aggregate line equals the pinned CASES literal byte-for-byte (`analyze.py pins`:
8 rows, 0 rows differing). The FAILs in `probeD*`/`probeE*` are the **intended
outcome of a detection control**, not a flake — each control was run twice
(pre-final and final trees) with identical movements.

### 1.3 Comparator and noise floor

`scripts/analyze.py compare` (aggregate line → cell dicts → field-by-field):

```
ref1 vs ref2          : 0 cells moved                    ← the noise floor is zero
ref1/ref2 vs probeA*  : 0 cells moved (each of the four A runs)
ref1/ref2 vs probeB1f : 0 cells moved
ref1/ref2 vs probeC1f : 0 cells moved
ref1/ref2 vs probeF1f : 0 cells moved
ref1/ref2 vs probeD1f : 1 cell  (ffpsdup_30_60 eq 1→0)
ref1/ref2 vs probeE1f : 6 cells (err@*, finalize_touch@* sha moves, all three backends)
```

Two independent baseline runs are byte-identical at cell granularity, so a fold
tree reporting 0 diffs is a real no-op, not noise masking a change.

### 1.4 Independent pin audit (shares no code with the fixture)

`scripts/verify_pins.py` re-implements the declared normalization from the
fixture header, **re-parses the `ERR_ALLOW` heads out of the fixture text**, and
recomputes sha256-16 + `ee` from each raw `child.log`; it also re-derives the
envelope fields (`inert`, `boot`, `tickge1`) and the computed `beq`/`eq=1`
fields:

```
ref1 / ref2 / probeA1 / probeA2 / probeA1f / probeA2f / probeB1 / probeB1f
  / probeC1 / probeC1f / probeF1 / probeF1f / probeE1 / probeE1f : 188 checks, 0 mismatches
probeD1 / probeD1f                                              : 187 checks, 0 mismatches
        (one fewer because the control's cell carries eq=0, so the eq=1
         re-derivation does not apply to it)
```

Every checked cell's `sha=` **and** `ee=` re-derive from the raw child log — in
the folded trees as well as the baselines. This closes the loop the fixture's own
scanner opens.

### 1.5 Executed census (every claim measured on the committed bytes)

- **Cells**: 142/run = 21 sched + 13 qa + 22 modes + 34 compose + 11 rt +
  8 area + 24 life + 9 cls. **0 empty-valued pinned fields** (the `movie=` pin is
  a bare-prefix field whose value is `, recording movie in 1152×648 @ 60 FPS…`).
- **Child-log normalization engagement** (142 logs, `ref1`): `RS_TIME` 35,
  `AR_TIME` 8, `BM_TIME`/`BM_WALL`/`BM_FPS` 52 each, `BM_WF` 1740,
  `BENCHMARK:` 2; **`FPS:` 0**; **Jolt WARN1/WARN2 pair 0**; **`#<digits>` 0**
  (no `#` in any log, so `_id_re` never fires here); **ObjectDB leak 0**;
  `handle_crash` 1 (the `writemovie` SIGABRT, past the declared `at:`
  truncation point, so not in the hashed stream).
- **Expected-error classes** (all allowlisted, counted `ee=`): `arerr` 6
  (enter/exit × gp/jolt + the two ffps120 cells), `wm` 1, `lerr` 3, `lfin` 3.
- **Backtrace coupling**: `res://r100b_life.gd:<line>` appears 12 times (4 lines
  × 3 backends) in the `err` and `finalize_touch` cells — those 6 cells hash the
  probe's line numbers (F-1).
- **`e` lists at runtime**: `{}`, `{wm}`, `{arerr}`, `{lerr}`, `{lfin}` only
  (grep census of every `"e":` literal and every `d["e"] = …` assignment, plus
  `_sched_cell`'s `extra` merge — extras only ever carry `x`). No cell can select
  `"leak"`.
- **Dead locals/keys**: `w` (declared once L589, incremented once L600 inside the
  WARN-pair skip, returned once as `"w"` L628, read nowhere); result key `"m"`
  (produced L628, read nowhere; the local `m` is still used to compute the sha).
  No dead function, no other zero-use declaration.
- **Unreachable defaults**: the 5 spawn-spec `.get(k, default)` reads
  (L807/L810/L829/L847/L848) — `_run_cells` (the only producer of spawn specs,
  the only caller of `_spawn_batch`, the only caller of `_child_prepare`) always
  writes all five keys.
- **Live optional keys** (contrast): the cell-table reads `spec.get("x", [])`,
  `spec.get("env", "")`, `spec.get("bytes", false)`, `spec.get("rtw", false)`
  are genuinely optional — most cells omit them.
- **Runner block**: `git show 8183191 --numstat` = `39 0 corpus/fixtures/run_battery.py`;
  the block is lines 877–915 (22 comment + 8 two-line rows + 1 blank), no other
  round's row can be affected. The block comment's claims were checked against
  the runs: "142 cells" ✓, "8 rows" ✓, "byte-identical copies of the boundary
  probes" ✓ (cmp), "no pin authored from scout/boundary text" ✓ (my fresh runs
  reproduce every literal), expected-error clause ✓ except the `leak` clause
  (SP-2).

## 2. Taken folds

### 2.1 SP-1 — the write-only `w` counter and the unread `"m"`/`"w"` keys

Tree `probeA` = seed −2 lines (892 → 890), fixture sha
`063b2e9795e0b0c3…` (receipt `probes/probeA-r100_fpslat.gd`):

| edit | seed lines | Δ | what |
|---|---|---|---|
| `_scan_lines` decl | 589 | −1 | `var w := 0` |
| `_scan_lines` increment | 600 | −1 | `w += 1` (the WARN1+WARN2 *skip itself* stays — it is load-bearing) |
| `_scan_lines` return | 628 | 0 | `{"m": m, "raw": raw, "sha": _sha16(m), "w": w, …}` → `{"raw": raw, "sha": _sha16(m), …}` |
| header prose | 23 | 0 | "counted in w, never pinned" → "dropped before hashing, never pinned" |

**Proof:** probeA1f + probeA2f = 8/8 rows PASS each, aggregate lines byte-identical
to both baselines (0 cell diffs), pin audit 188/188, `seeds_unchanged=true`. The
scanner probe (`scripts/scanner_probe.gd`) drives `_scan_lines` directly with a
synthetic stream containing the WARN pair, a leak line, an id-bearing line and an
allowlisted ERROR line: **probeA's output is byte-identical to the seed's for all
three allow cases**, so the fold is identical even on the paths the 142 cells do
not reach in a quiet run (the WARN pair never appeared in this seat's runs).

### 2.2 SP-2 — the dead `leak` allowlist path

Tree `probeB` = seed −7 lines (892 → 885), fixture sha `9421c7d7ee86e00b…`
(receipt `probes/probeB-r100_fpslat.gd`) + the block comment edit
(`probes/probeB-run_battery.py`, `run_battery.py` sha `2b553be6a404a6d5…`,
0 net lines):

| edit | seed lines | Δ | what |
|---|---|---|---|
| `ERR_ALLOW` entry | 129 | −1 | `"leak": ["leak"],` — unselected by every cell |
| `_allowed` guard | 579–580 | −2 | `if head == "leak": continue` — unreachable once the sentinel is gone |
| leak handler | 616–618 | −4 | `if allow.has("leak"): m/raw.append else: ue.append` → unconditional `ue.append` (the positive path is unreachable) |
| header prose | 113–115 | 0 | the sentinel sentence becomes "…The ObjectDB-leak warning line is matched by regex and always fails the cell." |
| r100 block comment | `run_battery.py` 891 | 0 | "…lifecycle script-error classes, leak the ObjectDB class." → "…classes; an ObjectDB leak always fails the cell." |

**Proof:** probeB1f = 8/8 rows PASS, **0 cell diffs**, pin audit 188/188. The
scanner probe pins the exact boundary: probeB differs from the seed **only** in
the `allow=["leak"]` case (the leak line lands in `ue` instead of the hashed
stream) — the only observable delta is the latent capability, and the census
shows no cell can select `"leak"` (runtime `e` sets are `{}`, `{wm}`, `{arerr}`,
`{lerr}`, `{lfin}`).

**Tradeoff (named, not hidden):** the fold removes the *latent extension point*
— a future cell could have written `"e": ["leak"]` to tolerate ObjectDB-leak
lines as an expected class. The declared contract in the fixture header (L31–32)
is already "ObjectDB-leak … lands in `ue` and fails the cell", so SP-2 aligns
code with the declaration; r99's simplifier reached the same call for the same
shape (its SP-4, "take", with the same caveat). If the taker wants to keep the
extension point instead, drop SP-2 — the executed surface is identical either way
(no leak line was observed in 142 logs).

### 2.3 SP-3 — unreachable `.get` defaults on the normalized spawn spec (weak)

Tree `probeC` = seed, 0 net lines, 5 edits, fixture sha `e53a6f729bb4f8fa…`
(receipt `probes/probeC-r100_fpslat.gd`):

```
L807  var bound: int = spec.get("bound", BOUND_S)   ->  spec["bound"]
L810  dir, spec.get("eargs", "")                    ->  spec["eargs"]
L829  mbound = maxi(mbound, spec.get("bound", BOUND_S) as int)  ->  spec["bound"] as int
L847  _scan(prep["logpath"], specs[i].get("e", []),  ->  specs[i]["e"],
L848  specs[i].get("done", ""))                      ->  specs[i]["done"])
```

`_run_cells` builds every spawn spec with all five keys (from the cell table's
own defaults); `_spawn_batch` and `_child_prepare` are reached only from there,
and they already index `spec["dir"]`/`spec["body"]`/`spec["probe"]`/`spec["case"]`
directly. The defaults are therefore unreachable *by construction of the single
producer* — a total static argument, corroborated by execution.

**Proof:** probeC1f = 8/8 rows PASS, **0 cell diffs**, pin audit 188/188, scanner
probe byte-identical.

**Call: take-or-drop (weak).** It saves no lines; it tightens an internal
contract. It is listed separately so the taker can drop it without losing SP-1/SP-2
(the combined tree probeF covers both choices).

## 3. Refuted candidates (recorded so they are not re-proposed)

- **R-1** — `spec.get("rc", 0)` in `_cell_ok` (the r99 SP-3 shape): **live**.
  `writemovie` sets `"rc": 134` and `noquit_unbound` sets `"rc": 137`; the
  `rc=134`/`rc=137` pins re-derive in every run. Deleting the default or the key
  would change those two cells' contract.
- **R-2** — `spec.get("bound", BOUND_S)` as a *knob* (the r99 SP-2 shape, "no
  spec sets it"): **refuted as stated** — `fdelay200_qa40` sets `bound: 13` and
  `noquit_unbound` sets `bound: 5`, and both bounds are load-bearing (the former
  rides the 8 s frame-delay wall, the latter bounds the unbound envelope cell).
  Only the *default value* is unreachable; that residue is SP-3.
- **R-3** — "fold the `res.get(…)` defaults in `_cell_text`/`_cell_ok` too":
  same class as SP-3 but the scanner result has a second legal shape
  (`{"err": …}`) whose early return is what makes those defaults dead. The proof
  is weaker than SP-3's total-producer argument, so they are **not** folded.

## 4. Detection controls (the "0 diffs" claim is not vacuous)

- **probeD** (fixture-side, 0 net lines): `ffpsdup_30_60`'s `"eq": "ffps60"` twin
  renamed to an absent name. Result: exactly **1 of 142 cells moved**
  (`eq 1→0`), exactly **1 of 8 rows red** (`r100_fpslat_modes`), the other 7 rows
  byte-identical, `seeds_unchanged=true`, both runs identical.
- **probeE** (probe-side, +1 line): one comment line inserted at the top of
  `r100_probe_r100b_life.gd`, shifting every following line. Result: exactly
  **6 of 142 cells moved** (`err@{gp,jolt,dummy}`, `finalize_touch@{gp,jolt,dummy}`
  — the cells whose streams hash the probe's `:68`/`:91` backtrace lines), exactly
  **1 of 8 rows red**, the other 7 rows byte-identical, both runs identical.
  This is F-1 demonstrated end-to-end: the probe copies are frozen provenance and
  a probe-side edit is never free (r99's SP-5 refutation, same mechanism).

## 5. Findings (filed, not this seat's call)

- **F-1 (LOW)** — 6/142 cells hash `res://r100b_life.gd:<line>` backtrace lines.
  Self-consistent today (the six probe copies are byte-identical to the boundary
  probes, so a child receipt reproduces the boundary receipt), but any future
  edit to the life probe copy must re-pin those 6 cells. A declared mask for
  `res://…:<line>` would itself move the 6 cells and therefore needs a re-pin —
  a landing decision, not a simplifier fold.
- **F-2 (LOW)** — `reports/round-100/r100-author.md` L16 says
  `r100_fpslat.gd` is "879 lines"; the committed blob is 892 lines (the env-`beq`
  fix added lines after the count was written). The landing bytes are what the
  runs above pin; the report's number is stale.
- **F-3 (INFO)** — guard-only normalizations kept (removing them would change
  failure semantics for unforeseen engine output): WARN pair skip, `FPS:` wall
  prefix, `_id_re` mask, `_leak_re` routing. Their engagement in this seat's runs
  is recorded in §1.5; the WARN pair is load-dependent (the author's boundary
  corpus measured 38–92%) and was never observed here.
- **F-4 (INFO)** — `r99_animtree.gd` still carries the exact vestiges SP-1/SP-2
  remove (`"leak": ["leak"]` L134, guard L498, `var w` L508, `"m"`/`"w"` L546).
  The r99 simplifier proved the same folds and they were not landed; r100's
  driver inherited the shape. Out of scope here (the tasking limits folds to the
  r100 block + `r100_fpslat.gd`), but it is the reason a r100-only cleanup
  creates a (benign, behavior-identical) shape divergence between the two
  parent drivers.

## 6. Preserved contract

Nothing in the landing's *declared* contract is touched by SP-1/SP-2/SP-3: the
142 pinned cells, the 8 row markers, the 6 probe copies, the normalization
surface, the expected-error classes that cells select, and the envelope cells
are all byte-identical under every fold (0 cell diffs, observed == pinned). The
only behavioral delta in the whole fold set is SP-2's latent `e=["leak"]` path,
which no cell selects and which the fixture header already declares as
always-failing.

## 7. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
R=corpus/live/r100-simplifier

# 1. frozen seed (archive checkout under /home) + byte verification
git archive 8183191 corpus/fixtures | tar -x -C $R/seed-frozen --strip-components=2
cp corpus/fixtures/r100_probe_r100b_*.gd $R/seed-frozen/
python3 $R/scripts/verify_seed.py            # 140/140 blobs, 6/6 probes, 0 mismatches

# 2. fold trees (strict unique anchors; aborts on drift) + receipts
python3 $R/scripts/prepare_trees.py

# 3. baselines and fold runs (8 rows / 142 cells each)
bash $R/scripts/run100.sh $R/seed-frozen       ref1
bash $R/scripts/run100.sh $R/seed-frozen       ref2
bash $R/scripts/run100.sh $R/trees/probeA      probeA1f
bash $R/scripts/run100.sh $R/trees/probeA      probeA2f
bash $R/scripts/run100.sh $R/trees/probeB      probeB1f
bash $R/scripts/run100.sh $R/trees/probeC      probeC1f
bash $R/scripts/run100.sh $R/trees/probeF      probeF1f
bash $R/scripts/run100.sh $R/trees/probeD      probeD1f   # control -> FAIL 7/8 (intended)
bash $R/scripts/run100.sh $R/trees/probeE      probeE1f   # control -> FAIL 7/8 (intended)

# 4. every comparison + pin audit + census, regenerated from the receipts
bash $R/scripts/verify_all.sh | tee $R/out/verify-all.txt

# 5. scanner-level probe on the unexercised paths (WARN pair / leak / id mask)
for l in base A B C F; do (cd $R/scanner/$l && \
  timeout -s KILL 30 /usr/bin/godot --headless --path . --script res://scanner_probe.gd \
  2>/dev/null | grep '^SCAN' > $R/out/scanner-$l.txt); done
diff $R/out/scanner-base.txt $R/out/scanner-A.txt   # identical
diff $R/out/scanner-base.txt $R/out/scanner-B.txt   # differs only in allow=["leak"]
```

## 8. Receipts pointer

`corpus/live/r100-simplifier/` (gitignored scratch): `seed-frozen/` (the
`git archive 8183191` seed + 6 probe seeds, re-verified against the committed
blobs, and re-verified against `523c943` after the mid-seat commit);
`trees/probe{A..F}/` (throwaway, byte-reproducible from `prepare_trees.py`);
`probes/` (the edited artifacts kept as receipts —
`probeA-r100_fpslat.gd` `063b2e97…`, `probeB-r100_fpslat.gd` `9421c7d7…`,
`probeB-run_battery.py` `2b553be6…`, `probeC-r100_fpslat.gd` `e53a6f72…`,
`probeF-r100_fpslat.gd` `7c243734…`, `probeF-run_battery.py` `2b553be6…`,
`probeD-r100_fpslat.gd` `aec8f43e…`, `probeE-r100_probe_r100b_life.gd`
`1c7bba92…`); `runs/<label>/<UTCstamp>/` (`verdicts.json` + `scratch/` holding
the 142 per-cell `child.log` receipts per run); `scanner/<base|A|B|C|F>/`;
`out/` (`verify-all.txt`, `scanner-*.txt`, this report's draft); `scripts/`
(`verify_seed.py`, `analyze.py`, `verify_pins.py`, `prepare_trees.py`,
`run100.sh`, `verify_all.sh`, `prune_runs.sh`, `scanner_probe.gd`).

Footprint: 237 MB after one prune pass (`prune_runs.sh` dropped the per-child
`project.godot`/probe copies and the per-run fixture copies, keeping every
`child.log` as the pin-audit receipt); the prune was re-verified harmless by
re-running `verify_all.sh` on the pruned runs — same 188/187 checks with 0
mismatches and the same comparator verdicts (0/0/0/0/0/1/6).

Provenance: this seat wrote only this report and its scratch tree. No committed
fixture, probe, runner row or report was modified; **no commit made**, per the
task contract. The shared tree was verified byte-identical to the committed
`8183191` blobs (`git diff --stat` empty; `r100_fpslat.gd` and `run_battery.py`
match their blobs exactly, which are also `523c943`'s bytes) before this report
was filed.
