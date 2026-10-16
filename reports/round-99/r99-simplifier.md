# r99 simplifier — YAGNI/dead-code review of the committed r99 animtree landing (`f1ff626`)

Seat: **GAME-DEV-3D r99 SIMPLIFIER**, read-only on tracked files. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r99-simplifier.md`.
Scope: the committed work commit
`f1ff626f4d83e67ab84185a56e972e79869535d` only — `corpus/fixtures/r99_animtree.gd`
(+779, new), the six `corpus/fixtures/r99_probe_r99b_*.gd` copies
(+308/+233/+248/+212/+413/+411, new), `corpus/fixtures/run_battery.py` (+29/−0,
insertion-only; recomputed here), `reports/round-99/r99-author.md` (+124) —
plus its receipts. **Zero tracked writes by this seat; the only tracked write is
this report** (all receipts land under the gitignored `corpus/live/r99-simplifier/`;
no commit made). HEAD was `f1ff626` at seat start; the orchestrator committed the
r99 critic report as `b3d366e` during the seat (`git show --stat b3d366e` =
`reports/round-99/r99-critic.md` only; `git diff f1ff626 b3d366e -- corpus/fixtures`
is empty, so no seed moved), and every claim below is pinned to the `f1ff626`
bytes. The working tree bytes equal the committed `f1ff626` blobs for all eight
fixture/runner files (recomputed sha256, §1.1), so no sibling lane moved these
bytes during the seat.

**LSP device: unavailable to this seat.** `mcp_list_servers` returns exactly one
server, `rea` (Ghidra/REA binary analysis); there is no `lsp`/`references`/
`definition`/`code-action` tool in this toolset, so no server can answer
`r99_animtree.gd` or the probe copies. **Recorded as unavailability** (same as
r97/r98). The landing's shape narrows the gap — no reflection, no dynamic-name
access, cell tables are literal dicts (`_cells_*`, `_spread`), children are read
by literal `res://` path — and every fold below is *executed*, not merely
censused. No rename was performed by this seat.

Environment: Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`;
`/usr/bin/python3`; 32-core host, **loadavg 65.8–88.7 across the seat's 18 battery
invocations** (seat-start `78.37/69.75/65.80`; per-run before→after echoes in the
`*.log` files). "Load preferred" is satisfied; every pin below was re-measured
under it. One `ufo-labrat` probe was dispatched (frozen probeParent, exactly one)
and returned `confirmed-all` (§8).

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. Three parent-side dead-code folds
(SP-1…SP-3, −2 net lines + two unread result keys) are proven no-op by two
independent 9-row battery runs each, a fourth parent-side fold (SP-4, −7 lines,
the leak-allowlist dead path r98 had already dropped) by one run, and one
probe-copy fold (SP-6, −2 lines) by one run — every one at cell granularity
(0 moved cells) and against an independent pin audit (183/183). One candidate
fold is REFUTED by execution: deleting the dead `var stage2: Node3D` from
`r99_probe_r99b_core.gd` moves exactly 6 pinned cells because GDScript backtraces
embed probe source line numbers in the hashed stream (12 of 183 cells are
line-number-coupled) — **SP-5 must be dropped, not taken**. The detection control
moved exactly 3 cells and reddened exactly 1 row, so "0 diffs" means what it says.
The runner change is insertion-only at the CASES tail (342 rows = 333 + 9) and
no other round's row can be affected. The 6 probe copies are byte-identical to
the boundary's own probes (shas recomputed).**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | parent `_scan_lines`: the write-only `w` counter (decl L508, increment L518) and the two unread result keys `"m"`/`"w"` in the L546 return | **−2 lines** (3 edits) | probeA1 + probeA2 = 9/9 rows PASS each, **0 cell diffs** vs both baselines, pin audit **183/183** | **take** |
| **SP-2** | parent `_child_prepare` L698: `spec.get("bound", BOUND_S)` — no spec sets `"bound"`; inline `BOUND_S` | 0 lines (1 edit) | same runs | **take** |
| **SP-3** | parent `_cell_ok` L651: `spec.get("rc", 0) as int` — no spec sets `"rc"` (all 9 rows expect exit 0); compare against `0` | 0 lines (1 edit) | same runs | **take** |
| **SP-4** | parent leak-allowlist dead path: ERR_ALLOW `"leak"` entry (L134), the unreachable `allow.has("leak")` branch (L534–537), the now-unreachable `head == "leak"` guard (L498–499), header prose L114–115 | **−7 lines** (4 edits) | probeB1 = 9/9 rows PASS, **0 cell diffs**, pin audit **183/183** | **take** (r98 had already dropped this shape; r99 reintroduced it — §4) |
| **SP-5** | probe copy `r99_probe_r99b_core.gd`: dead `var stage2: Node3D` (single occurrence, never assigned/read) | −1 line | **REFUTED** — probeC1 + probeC2: exactly **6 cells moved** (`wire@*`, `pposerr@*`), 1 row red, deterministic, all three backends agree | **drop** (§5.1) |
| **SP-6** | probe copy `r99_probe_r99b_modes.gd`: write-only `watcher` handle (L21 decl + L102 assignment, never read) | −2 lines (2 edits) | probeE1 = 9/9 rows PASS, **0 cell diffs**, pin audit **183/183** | **take-or-drop** (proven no-op; breaks 1 of the 6 pinned "byte-identical copy" shas — §5.2) |

Findings filed (not this seat's call): **F-1** LOW — probe source line numbers
live inside the hashed stream (12/183 cells coupled; demonstrated by SP-5's
refutation). **F-2** LOW — the six probe copies are frozen provenance artifacts,
so probe-side simplification is never free. **F-3** INFO — r99 reintroduced the
`leak` allowlist vestige r98 had removed. **F-4** INFO — the dead result keys
`"m"`/`"w"` (r98 read `m`; r99 reads `raw`, so `m` became dead here). **F-5**
INFO — guard-only normalizations kept. No behavioral defect found; nothing in
the landing is unsound — the folds are cleanup, and SP-5's refutation is the
reason a naive cleanup would have broken pins.

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

sha256 recomputed here (all match `reports/round-99/r99-author.md` and the
working tree, which was byte-identical to the committed blobs at seat start and
report time):

```
75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2  r99_animtree.gd              (779 lines)
6683aba10439885d08488fd36275fabbb938895f04a853cb2650e4e10db0ff51  r99_probe_r99b_core.gd       (308)
2eb2e2428a317934aa88682e1f3477352771243413fc5201df001b37e4724df8  r99_probe_r99b_life.gd       (233)
f6d23bb1f69e2c4f27d5904d846d3394edb83e73ae1386c25624f00ea6195ff5  r99_probe_r99b_modes.gd      (248)
de0fd54e2ed5dbed8912f0848cb99d7775314510638a4802dc85571d54b645ee  r99_probe_r99b_silent.gd     (212)
a8d41a1b1fd5c624d2f5501bbc4a1ba19cba15679ee5f01284120bcc8b229081  r99_probe_r99b_sm.gd         (413)
5981275d176f1fc06c5d644165ab3293cd079a54d9a700c7c2bca7eefb745afd  r99_probe_r99b_untracked.gd  (411)
ff010bd35004a7377a9135c43a1d21653c2d68cab2e601af3c5df28676fa5335  run_battery.py
```

**The six probe copies are byte-identical to their boundary sources** —
`corpus/live/r99-boundary/probes/r99b_{core,life,modes,silent,sm,untracked}.gd`
hash to exactly the six values above (recomputed). That identity is what makes a
child receipt reproduce the boundary's own receipt, and §5.1 shows it is also
load-bearing for pin stability.

### 1.2 The runner change

`git diff f1ff626^ f1ff626 -- corpus/fixtures/run_battery.py` = **+29/−0**: an
11-line comment block + 9 CASES tuples appended after `r98_gltflat_var`; no
existing byte moved. Parsing the committed `CASES` literal: **342 rows**, of
which **9** name `r99_animtree.gd` (all `r99_animtree_*`). The `--only` selection
used by this seat resolves to exactly those 9.

### 1.3 Frozen committed seed

`git archive f1ff626 corpus/fixtures` → `corpus/live/r99-simplifier/seed-frozen/`:
**139 files, 139 byte-equal to `git show f1ff626:<path>` blobs, 0 mismatches,
0 extra files** (re-verified file-by-file). All runs below use this frozen seed or
a byte-reproducible edit of it, never the live tree.

### 1.4 Battery runs (9 r99 rows = 183 cells / 183 children per pass)

Every run: `run_battery.py --only <9 r99 rows>` from the tree under test,
`--headless`, children at `--fixed-fps 60`. "moved cells" = cell-level diff vs
the `ref1` baseline (§1.5). The whole 9-run set was executed **twice** (original
session; regenerated after the scratch prune) with **identical verdicts and
identical cell movements**. `elapsed` is from the regenerated set; the loadavg
column is the before→after echo from the first execution of the same label
(32-core host; the seat's overall observed range is 65.8–88.7).

| run | tree | verdict | moved cells vs ref1 | elapsed | load before→after |
|---|---|---|---|---|---|
| `ref1` | seed-frozen | **PASS 9/9** | — (baseline) | 22.2 s | ~78 (seat start) |
| `ref2` | seed-frozen | **PASS 9/9** | 0 | 22.3 s | — |
| `probeA1` | probeA (−2) | **PASS 9/9** | 0 | 22.0 s | 82.8→83.6 |
| `probeA2` | probeA (−2) | **PASS 9/9** | 0 | 21.8 s | 83.6→86.8 |
| `probeB1` | probeB (−7) | **PASS 9/9** | 0 | 22.9 s | 86.7→86.7 |
| `probeC1` | probeC (probe −1) | **FAIL 8/9** | **6** (`wire@*`, `pposerr@*`) | 22.4 s | 86.7→88.6 |
| `probeC2` | probeC (probe −1) | **FAIL 8/9** | **6** (same cells) | 25.1 s | 82.0→78.0 |
| `probeD1` | probeD (mutant) | **FAIL 8/9** | **3** (`clsloop@*`) | 24.3 s | 88.6→88.7 |
| `probeE1` | probeE (probe −2) | **PASS 9/9** | 0 | 23.6 s | 73.3→70.1 |

`seeds_unchanged=true` in **all 9** runs; **183 child logs** in every run
(1647 post-prune); the battery's own exact-marker check is the authority and it
is green on every non-mutant, non-refuted tree. The FAILs in `probeC*` are the
**intended outcome of a refuted fold** (§5.1), not a flake: the run set was
executed twice and moved exactly the same cells both times.

### 1.5 Comparator and noise floor

`scripts/analyze99.py compare` (marker line, cell-by-cell, stderr, rc):

```
ref1 vs ref2 : 0 cases with diffs, 0 cells moved      ← the noise floor is zero
ref1 vs probeA1/A2/B1/E1 : 0 diffs, 0 cells moved (each)
ref1 vs probeC1/C2 : 1 case, 6 cells  wire@*/pposerr@* sha bbfe973e763e7ea5→67b6516a37cf5899
                                       pposerr 0dad831554e52987→4b8569cb9d3a9dd2
ref1 vs probeD1 : 1 case, 3 cells  clsloop@* made 340→323 skipped 240→228
                                   sha 9251889a008ea983→1413a90e5cf3d9cc
```

Two independent baseline runs are byte-identical at cell granularity, so a
folded tree reporting 0 diffs is a real no-op, not noise masking a change.

### 1.6 Independent pin audit (implementation shares no code with the fixture)

`scripts/verify_pins99.py` re-implements the declared normalization (banner/empty
drop, WARN1+WARN2 skip, `#N`/`srv=S`/`seq=N`/`idle_rows=N`/`pf_rows=N` masks,
the allowlist heads re-parsed from the fixture text, the `td` marker truncation)
and recomputes sha256-16 of every child log:

```
ref1/ref2/probeA1/probeA2/probeB1/probeE1 : cells checked=183  mismatches=0
probeC1/probeC2                           : cells checked=162  mismatches=0   (core row red → its 21 cells skipped)
probeD1                                   : cells checked=165  mismatches=0   (life row red → its 18 cells skipped)
```

Every checked cell's `sha=` **and** `ee=` re-derive from the raw child log. This
closes the loop the fixture's own scanner opens: the pins are reproducible by an
independent implementation, in the folded trees as well as the baseline.

### 1.7 Detection control is not vacuous

probeD = committed + one authored constant in the `r99b_life` probe copy
(`for rnd in range(20)` → `range(19)`; the probe prints `rounds=20` as a literal,
so the movement shows up in `made`/`skipped`/`sha`). Result: exactly **3 of 183
cells moved**, exactly **1 of 9 rows reddened** (`r99_animtree_life`), the other
8 rows byte-identical, `seeds_unchanged=true`, and the comparator names the moved
cells and the moved fields. The detector chain (exact-marker battery check →
cell comparator → pin audit) is therefore live at cell granularity in both
directions.

### 1.8 Executed census (every claim measured on the committed bytes)

- **Cells**: 183/run = 61 logical × 3 backends (21/21/21/27/12/27/21/15/18 per
  arm); **122/122 non-`@gp` cells `beq=1`**; **12 `peq` cells** = 6×`peq=1`
  (PHYSICS f30/f120) + 6×`peq=0` (IDLE f30/f120); **`dz=0`** on all three `min`
  cells; **no empty-valued pinned field** in any of the 183 baseline cells —
  every `x`-block field resolves (no dead pin).
- **Mask engagement** (per baseline run): `_id_re` fires in **51/183** child logs;
  `_srv_re` fires in the core/untracked cells; `_seq_re`/`_irows_re`/`_prows_re`
  fire in the modes cells. **WARN1/WARN2 never observed** in 1647 child logs;
  **no ObjectDB-leak line observed**.
- **`td` exercised live**: in `probeA1`, the `clsloop@gp` child aborted with
  `corrupted size vs. prev_size while consolidating` + `timeout: the monitored
  command dumped core` **after** `LIFE_DONE` — and the cell still pinned
  `rc=0|134, sha=9251889a008ea983`; the independent audit re-derived the
  truncated sha from that exact log.
- **Declarations**: parent 53 top-level decls, **0 zero-use**; probe copies
  27/24/39/22/41/39 decls, **0 zero-use**; no dead function.
- **Dead locals**: parent none; `stage2` (core probe, declared once, never
  assigned or read); `watcher` (modes probe, assigned once at L102, never read).
- **Allowlist**: 5 of 6 `ERR_ALLOW` classes selected by ≥1 spec literal
  (`wire`,`pposerr`,`dupn`,`dups`,`badstate`); `leak` unselected.
- **Duplication**: no identical ≥6-line block repeats in the parent (the only
  repeated line pair is the `m.append(_mask(line))`/`raw.append(line)` in the two
  allow branches — semantically distinct; SP-4 removes one of them). There is no
  `_run_phys`-style duplicate emitter on this surface, so r98's SP-6 dedup has no
  r99 analogue.
- **Runner**: +29/−0 at the CASES tail; 342 rows; no other round touched.

### 1.9 The r99 laws, spot values re-derived from `ref1`

```
wire@gp     {rc=0,sha=bbfe973e763e7ea5,a_actor=(0.0000,0.0000,0.0000),a_tp=0.0000,b_actor=(0.6000,0.0000,0.0000),b_tp=0.1500,ee=1}
pposerr@gp  {rc=0,sha=0dad831554e52987,pre_playing=false,pre_tp=0.0833,raw=0.0000,playing=false,tp=0.0833,ee=1}
body@dummy  {rc=0,sha=c3874b9f1ed0bd0b,actor=(1.2667,0.0000,0.0000),ball=(1.2667,3.0000,0.0000),srv=nil,frozen=true,tp=0.3167,beq=1}
phys_f30@gp {rc=0,sha=2dddf1d495293189,x_pf10=0.4667,x_pf20=1.1333,x_pf30=1.8000,t_pf30=0.4500,lead_zero=2,pf_first_move=4,peq=1}
idle_f120@gp{rc=0,sha=1b6eba439d239339,x_pf10=0.5667,x_pf20=1.2333,x_pf30=1.9000,t_pf30=0.4750,lead_zero=0,pf_first_move=2,peq=0}
clsloop@gp  {rc=0|134,sha=9251889a008ea983,made=340,skipped=240,rounds=20,names=29}
```

All equal the committed `run_battery.py` expectations; the battery's own
exact-marker check is what makes that statement true (it passes 9/9 on every
non-mutant, non-refuted tree).

## 2. Census: what in the landing is dead

`scripts/census99.py` (textual, every claim executed by a fold + run) and
`out/deadlocals.txt`:

- **Parent `r99_animtree.gd` (779 lines, 53 decls):** the only dead items are the
  `w` counter + the two unread result keys (§3), the two never-set spec knobs
  `bound`/`rc` (§3), and the unselected `leak` allowlist path (§4). Everything
  else is live: `CHUNK`/`BOUND_S`/`JOLT`/`DUMMY`/`WARN1`/`WARN2`/`PROJECTS` are
  each consumed; all six regexes are used (four engaged at runtime, two
  guard-only); every `spec` key that is read is set somewhere (`n,p,pr,c,mark,
  eargs,e,x,dz,peq,sw,td,done,dir,body,probe,case`) and every result key that is
  read is produced (`err,rc,sha,raw,ee,ue`).
- **Probe copies:** one never-assigned dead declaration (`stage2`) and one
  write-only handle (`watcher`). Both inherited from the boundary probes; both
  are probe-side edits, and probe-side edits are not free (§5).
- **Seen, not taken:** the `mk=0` facility (never fired — every arm emits its
  marker), the WARN1/WARN2 skip (never engaged on this surface), and `_leak_re`
  routing (never engaged). These are the declared normalization surface; removing
  them would change failure semantics for unforeseen engine output — the opposite
  of a simplification (same call as r98 F-6).

## 3. Taken folds — SP-1…SP-3 (probeA, parent only)

`scripts/prepare_trees.py` (every anchor asserted unique/counted; aborts
otherwise); tree `probeA` = committed −2 lines (779 → 777), sha256
`613ae279f28714cf53d56d36930d334cf7b568d00e847e2fec0ced90a0749843`
(receipt: `probes/A-r99_animtree.gd`).

| edit | committed lines | Δ | what |
|---|---|---|---|
| SP-1 decl | 508 | −1 | `var w := 0` |
| SP-1 increment | 518 | −1 | `w += 1` (the WARN1+WARN2 skip itself stays — it is load-bearing) |
| SP-1 result keys | 546 | 0 | drop `"m": m, ` and `"w": w, ` from the returned dict |
| SP-2 | 698 | 0 | `spec.get("bound", BOUND_S)` → `BOUND_S` |
| SP-3 | 651 | 0 | `rc == (spec.get("rc", 0) as int)` → `rc == 0` |

**Proof:** probeA1 + probeA2 = 9/9 rows PASS each, marker lines byte-identical to
both committed baselines (0 cell diffs), stderr/rc identical,
`seeds_unchanged=true`, **and** the independent pin audit 183/183. SP-1 is
exercised by every row (the scanner runs on every child; the *skip* stays, only
the dead count and the two unread keys go); SP-2/SP-3 are exercised by the
absence of any behavior change on every row. `w` and `m` are read by nobody
(§1.8; labrat-confirmed, §8); `bound`/`rc` are set by no spec literal.

## 4. Fold SP-4 — the leak-allowlist dead path (probeB, parent only, −7 lines)

Tree `probeB` = committed −7 lines (779 → 772), sha256
`7300ef215af276c37853474a454022bfaa0b91b116c8f43eccb27d4ea08a3704`
(receipt: `probes/B-r99_animtree.gd`):

| edit | committed lines | Δ | what |
|---|---|---|---|
| ERR_ALLOW entry | 134 | −1 | `"leak": ["leak"],` — never consulted (`_allowed` skips it; the gate is `allow.has("leak")`) |
| leak handler | 533–540 | −4 | `if allow.has("leak"): m/raw.append else: ue.append` → unconditional `ue.append` (the `allow` list of **no** cell contains `"leak"`, so the positive path is unreachable) |
| `_allowed` guard | 498–499 | −2 | `if head == "leak": continue` — unreachable once the sentinel entry is gone |
| header prose | 114–115 | 0 | the sentinel sentence becomes "the ObjectDB-leak warning line is matched by regex and always fails the cell" (which is what the code did) |

**Proof:** probeB1 = 9/9 rows PASS, **0 cell diffs**, pin audit **183/183**.

**Why this is a vestige, not a capability:** r98's `_scan_lines` routes leak
lines straight to `ue` with no `allow.has("leak")` branch, and r98's ERR_ALLOW
had **7/7 classes selected** (no `leak` sentinel) — the r98 simplifier's own
census recorded "no unreachable allowlist class". r99 reintroduced the sentinel
and the branch; SP-4 restores r98's shape. Filed as F-3. If the taker wants to
*keep* the latent `e=["leak"]` extension point instead, drop SP-4 — the executed
surface is identical either way (no cell selects `"leak"`, no leak line was
observed in 1647 child logs).

## 5. Probe-copy candidates — SP-5 refuted, SP-6 a proven no-op

### 5.1 SP-5 (REFUTED — do not take): `stage2` in `r99_probe_r99b_core.gd`

`var stage2: Node3D` (L18) is declared once and never assigned or read — a dead
declaration inherited from the boundary probe. Deleting it (tree `probeC`, −1
line, receipt `probes/C-r99_probe_r99b_core.gd`) **moves exactly 6 pinned cells**
and reddens the `core` row, reproducibly (probeC1 and probeC2, same 6 cells):

```
wire@*    sha bbfe973e763e7ea5 -> 67b6516a37cf5899   (gp, jolt, dummy)
pposerr@* sha 0dad831554e52987 -> 4b8569cb9d3a9dd2   (gp, jolt, dummy)
```

**Mechanism (forensically pinned):** the `wire` and `pposerr` cases print a
GDScript backtrace as part of their expected-error lines:

```
ERROR: Condition "p_output_node == SceneStringNames::get_singleton()->output" is true.
   at: connect_node (scene/animation/animation_blend_tree.cpp:1615)
   GDScript backtrace (most recent call first):
       [0] c_wire (res://r99b_core.gd:161)
       [1] _run (res://r99b_core.gd:51)
```

The backtrace lines are ordinary lines (they match no allowlist head, no mask),
so they are hashed verbatim. Deleting one declaration shifts every following
line by 1 → `:161`→`:160`, `:51`→`:50` (and `:304`→`:303` for `pposerr`). The
child-log diff between `ref1` and `probeC1` is **exactly** those line numbers and
nothing else; all three backends move identically (`beq=1`), and the independent
audit still re-derives probeC's own printed shas 162/162 — so this is a real
change in the pinned stream, not a scanner artifact.

**Call: drop.** The declaration stays. Re-pinning instead would contradict the
landing's "byte-identical copy of the boundary probe" design (the author pins all
six shas), and the battery file is tracked and outside this seat's scope.

### 5.2 SP-6 (take-or-drop): `watcher` in `r99_probe_r99b_modes.gd`

`var watcher: Node = null` (L21) is assigned once in `mk_watcher()` (L102) and
never read; the watcher node is kept alive by `root.add_child(w)` (L101), so the
member reference is redundant. Removing both lines (tree `probeE`, −2 lines,
receipt `probes/E-r99_probe_r99b_modes.gd`) is a **proven no-op**: probeE1 = 9/9
rows PASS, **0 cell diffs**, pin audit **183/183** (the modes probe emits no
backtrace lines, so the line shift is invisible — §5.1 does not bite here).

**Call: take-or-drop (weak).** Same trade-off as r98's SP-7: the deletion is
proven dead, but the six probe copies are *deliberately frozen* — the fixture
header and `reports/round-99/r99-author.md` pin them as byte-identical to their
boundary sources, and taking SP-6 changes 1 of those 6 shas (the receipts
themselves are unaffected). The binding is inherited from the boundary probe, not
introduced here.

## 6. Findings (filed, not this seat's call)

### 6.1 F-1 (LOW) — probe source line numbers are inside the hashed stream

12 of 183 cells (4 cases × 3 backends: `core_wire`, `core_pposerr`,
`silent_dupnode`, `silent_dupstate`) embed GDScript backtrace lines
`[0] c_* (res://r99b_*.gd:<line>)` in the hashed stream. Any edit to a probe copy
that shifts line numbering re-pins the cells whose probe prints a backtrace;
editing the core probe moves 6 cells, editing the silent probe would move 6 more.
Demonstrated end-to-end by SP-5 (§5.1), deterministic across runs and backends.

The current design is **self-consistent** because the copies are frozen
byte-identical to the boundary's probes (recomputed, §1.1) — this is a coupling,
not a false pin. It does not make any pinned law false and cannot produce a false
PASS/FAIL (the battery reddens immediately on any movement). Taker options:
(a) no action — keep the copies frozen; (b) add a declared mask for
`res://…:<line>` to the normalization surface — this would itself change the 12
cells' shas and therefore requires a re-pin, so it is a landing decision, not a
simplifier fold. Filed for the record; §5.1 is the evidence.

### 6.2 F-2 (LOW) — probe copies are frozen provenance artifacts; probe-side simplification is never free

SP-5 is refuted and SP-6 is take-or-drop, for the same structural reason: the six
copies are pinned byte-identical to the boundary's probes, which is what makes a
child receipt reproduce the boundary's own receipt. Any probe-side dead-code
removal either moves pins (core/silent, via F-1) or breaks 1 of the 6 pinned
shas. Recommendation: leave the probe copies exactly as landed; take SP-1…SP-4,
which are parent-side and cost nothing.

### 6.3 F-3 (INFO) — r99 reintroduced a vestige r98 had removed

r98's `_scan_lines` routed leak lines straight to `ue` (r98 L500–503) and r98's
`ERR_ALLOW` had 7/7 classes selected, no `leak` sentinel. r99 adds the sentinel,
an unreachable positive branch, and a guard for it. SP-4 restores r98's shape and
aligns the code with the header's own contract ("… ObjectDB-leak lands in `ue`
and fails the cell"). Fixed by SP-4; filed so the divergence is on the record.

### 6.4 F-4 (INFO) — the dead result keys `"m"`/`"w"` (r99-specific)

`_scan_lines` returns `"m"` (the masked stream) and `"w"`; no consumer reads
either. Note the r98/r99 divergence: r98's `_cell_text` read `res.get("m", [])`
(L548/L554), so `m` was live there; r99's `_extract`/`_pfset` read `"raw"`
instead, which made `m` dead in this landing. Fixed by SP-1; the value `m` is
still used to compute the sha in-function.

### 6.5 F-5 (INFO) — guard-only normalizations kept

WARN1+WARN2 skip (never observed in 1647 child logs), `_leak_re` → `ue` routing
(no leak line observed), and the `mk=0` facility (never fired) are declared
guards. Kept: removing them would change failure semantics for unforeseen engine
output. The masks that *are* engaged at runtime (`_id_re` 51/183 logs,
`_srv_re`, `_seq_re`/`_irows_re`/`_prows_re`) are live code, not guards.

## 7. Detection control — probeD (mutant, one authored constant)

`for rnd in range(20)` → `range(19)` in `r99_probe_r99b_life.gd` (tree `probeD`,
0 net lines; receipt `probes/D-r99_probe_r99b_life.gd`). Result: `r99_animtree_life`
reddens, exactly **3 cells** move (`clsloop@{gp,jolt,dummy}`: `made` 340→323,
`skipped` 240→228, `sha` `9251889a008ea983`→`1413a90e5cf3d9cc`), the other 8 rows
are byte-identical, `seeds_unchanged=true`, and the comparator names the moved
cells and the moved fields. The detector chain is live at cell granularity.

## 8. Labrat probe status (frozen probeParent, exactly one)

One `ufo-labrat` was dispatched (read-only, no edits) with a bounded falsifiable
hypothesis on the committed `r99_animtree.gd`: (a) `"bound"` appears once and no
spec sets it; (b) `spec.get("rc", 0)` is the only spec-level `rc` read and no
spec sets it; (c) `w` is incremented only in the WARN1/WARN2 skip and read only
in the return dict; (d) the return keys `"m"`/`"w"` are read by nobody (and a
list of the keys that *are* read); (e) no per-cell `e` list contains `"leak"`,
so `allow.has("leak")` can never be true.

Its return: **all five parts CONFIRMED** with the literal lines — `spec.get("bound", BOUND_S)`
L698; `spec.get("rc", 0) as int` L651 (all other `"rc"` hits are result-dict
reads/writes L625/L650/L737); `var w := 0` L508 → `w += 1` L518 → return L546,
with the only other `w` being the unrelated loop variable in `_cells_order`
L361–365; `"m"`/`"w"` unread, while `err,rc,sha,ee,raw,ue` are read; and every
`"e":` literal (`wire` L250, `pposerr` L255, `dupn` L441, `dups` L444,
`badstate` L446) excludes `"leak"`. It wrote nothing (`PROBE VERDICT: confirmed-all`).

## 9. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
R=corpus/live/r99-simplifier

# 1. frozen committed seed + byte verification against the committed blobs
git archive f1ff626 corpus/fixtures | tar -x -C $R/seed-frozen --strip-components=2
#    (139 files; each re-compared to `git show f1ff626:<path>`: 0 mismatches)

# 2. census + probe trees (strict unique-anchor edits; aborts on any drift)
python3 $R/scripts/census99.py $R/seed-frozen | tee $R/out/census99.txt
python3 $R/scripts/prepare_trees.py        | tee $R/out/prepare-trees.txt

# 3. the 9-row battery on each tree (183 cells / 183 children per pass)
bash $R/scripts/run99.sh $R/seed-frozen      ref1
bash $R/scripts/run99.sh $R/seed-frozen      ref2
bash $R/scripts/run99.sh $R/trees/probeA     probeA1
bash $R/scripts/run99.sh $R/trees/probeA     probeA2
bash $R/scripts/run99.sh $R/trees/probeB     probeB1
bash $R/scripts/run99.sh $R/trees/probeC     probeC1     # refuted fold -> FAIL 8/9 (intended)
bash $R/scripts/run99.sh $R/trees/probeC     probeC2     # refuted fold -> FAIL 8/9 (intended)
bash $R/scripts/run99.sh $R/trees/probeD     probeD1     # control -> FAIL 8/9 (intended)
bash $R/scripts/run99.sh $R/trees/probeE     probeE1

# 4. every comparison + pin audit + census, regenerated from the receipts
bash $R/scripts/verify_all.sh | tee $R/out/verify-all.txt
```

## 10. Receipts pointer

`corpus/live/r99-simplifier/` (gitignored scratch): `seed-frozen/` (the
`git archive f1ff626` seed, 139 files re-verified against `git show` blobs);
`trees/probe{A..E}/` (throwaway, byte-reproducible from `prepare_trees.py`);
`probes/` (the edited artifacts kept as receipts — `A-r99_animtree.gd`
`613ae279…`, `B-r99_animtree.gd` `7300ef21…`, `C-r99_probe_r99b_core.gd`
`b0fafda4…`, `D-r99_probe_r99b_life.gd` `081d195a…`, `E-r99_probe_r99b_modes.gd`
`5605f28e…`); `runs/<label>/<UTCstamp>/` (`verdicts.json` + `scratch/` holding the
183 per-cell `child.log` receipts per run — 1647 logs across the 9 runs; the
per-run seed copies and the per-child `project.godot`/probe copies were pruned
after the crosschecks to keep this seat's footprint off a host shared with other
battery-running seats, 197 MB → 75 MB, **and the prune was verified harmless by
re-running the pin audit on a pruned scratch → `183 checked, 183 identical` and
the comparator → `0 diffs`**); `out/` (`census99.txt`, `deadlocals.txt`,
`empties-ref1.txt`, `compare-ref.txt`, `compare-probeA.txt`, `compare-probeB.txt`,
`compare-probeC.txt`, `compare-probeD.txt`, `compare-probeE.txt`, `pin-audit.txt`,
`verify-all.txt`, `prepare-trees.txt`); `scripts/` (`census99.py`, `analyze99.py`,
`verify_pins99.py`, `prepare_trees.py`, `run99.sh`, `verify_all.sh`); and the
per-run `*.log` (wall time + load before→after).

Provenance: this seat wrote only this report and its scratch tree. No committed
fixture, probe, runner row or report was modified; **no commit made**, per the
task contract.
