# r99 critic — adversarial review of the committed animtree landing (`f1ff626`)

Seat: **GAME-DEV-3D r99 CRITIC** (frozen `probeParent`). Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r99-critic.md`.
Attacked artifact: commit
`f1ff626f4d83e67ab841485a56e972e79869535d` — `corpus/fixtures/r99_animtree.gd`
(+779, new), six `corpus/fixtures/r99_probe_r99b_*.gd` (+1825, new),
`corpus/fixtures/run_battery.py` (+29/−0, insertion-only),
`reports/round-99/r99-author.md` (+124); **9 files, +2757, 0 deletions**;
**342 battery cases** (283 ordinary + 59 negative controls), the nine r99 rows
are the contiguous tail **rows 334–342**. Author/scout/boundary reports and
`corpus/live/r99-{author,scout,boundary}/` receipts were read, never written.

**Committed tree only.** All measurement ran on a frozen `git archive f1ff626`
tree (`corpus/live/r99-critic/frozen/`, fixture sha `75d63cbe…c8bc2` identical
to the committed blob). **This seat wrote no tracked file and made no commit**;
the only new tracked-path artifact is this report, left for the operator exactly
like the sibling seats' reports.

Environment (`corpus/live/r99-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, `/usr/bin/python3` **3.14.7**, kernel
7.2.3-arch1-3, 32 threads, 30 GB RAM, `--headless`. The box was loaded for the
whole seat (load1 **64.6 → 78.3**, 14 sibling Godot children observed live from
the concurrent r99 **scribe / verifier / simplifier** seats). Every number below
is a **loaded-host** measurement.

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded
absence as r85–r98). This seat made no source edit, so the hand-edit fallback
was never in play.

**`probeParent` seat:** exactly one read-only `ufo-labrat` was dispatched (a
static audit of the six committed probe sources: is every pinned field a runtime
measurement?). Its report is folded into §5.5 / F3; no other descendants,
nothing edited.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with findings that
are flake-disclosure and pin-strength class only; nothing contradicts an
authored law.**

- **183/183 cells re-derived byte-identically twice, by two independent
  routes**: (A) my own scanner over the **real battery's raw child logs** and
  (B) my own **spawn shape** (own project dirs, own argv, own capture) — 366
  re-derived cell instances, **0 diffs**, plus the 183 cells inside the battery
  run itself (**549 cell instances total**).
- **9/9 r99 rows green** on the frozen committed tree in this seat's battery run
  (receipt below), under load ~78.
- **122/122 `beq=1`** non-`@gp` cells verified statically, and the three
  backends are **demonstrably distinct** on this host (§5.2) — `beq=1` is a real
  comparison, not three identical runs.
- **The six committed probe copies are byte-identical to the boundary's own
  probe sources** (6/6 sha256), and the pins are the source seats' evidence.
- **10 mutation probes**: 8 detected, 2 non-detections that are *designed*
  behaviours of the `td` tolerance, each bounded and measured (§4).
- **The `td` teardown tolerance is bounded and fail-closed**, with the exact
  accepted/rejected rc matrix measured on this engine (§5.4) — including the
  control that the *declared* class (SIGABRT after the arm marker) really does
  pass, and the pre-marker abort really does fail.
- **The rate-flag plumbing is positively confirmed** (the r98-F2 hole does *not*
  reproduce): dropping `--fixed-fps` reddens `modes` and `order`, and the three
  rate-variant cells pin three distinct, reproducible shas (§5.1).

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, row arithmetic, custody of the 9 files | **CONFIRMED** | §1.1–1.2 |
| 2 | probe provenance: are the committed copies the boundary's bytes? | **CONFIRMED 6/6** | §1.2 |
| 3 | marker arithmetic: 183 = 61×3, `beq=1` 122/122, no `mk=0`/`err`/`ue` | **CONFIRMED** | §1.3 |
| 4 | reproduce the 9 rows on the committed bytes (frozen tree) | **CONFIRMED 9/9** | §2.1 |
| 5 | the author's greenness receipts (342/342 ×2, 9/9 ×2, 2 failed attempts) | **CONFIRMED verbatim** | §2.2 |
| 6 | is the evidence real (183 cells from raw child text)? | **CONFIRMED** — 549 cell instances, 0 diffs | §3 |
| 7 | are the pins load-bearing? | **8/10 mutants detected; 2 = designed `td` tolerances** | §4 |
| 8 | is `beq=1` backend-inertness vacuous? | **NO — the three bodies really are three backends** | §5.2 |
| 9 | the `srv=` mask | **declared; the server claim rides on extraction, not the hash** | §5.3 |
| 10 | is the `td` tolerance a hole? | **bounded + fail-closed; exact rc matrix measured** | §5.4 |
| 11 | are all pinned fields runtime measurements? | **NO — 8 echoed/tautological families (advisory probe + my check)** | §5.5, F3 |
| 12 | flake hunt on the committed bytes | **1 undisclosed clsloop census deviation observed (1/51), fails closed** | §5.6, F1 |
| 13 | hygiene: tracked writes, strays, cleanup | **CONFIRMED — zero tracked writes, scratch confined, no orphans** | §7 |

---

## 1. Custody and byte-level checks

### 1.1 Insertion-only, row arithmetic

```
git diff --numstat ba5ab41 f1ff626
779  0  corpus/fixtures/r99_animtree.gd
308  0  corpus/fixtures/r99_probe_r99b_core.gd
233  0  corpus/fixtures/r99_probe_r99b_life.gd
248  0  corpus/fixtures/r99_probe_r99b_modes.gd
212  0  corpus/fixtures/r99_probe_r99b_silent.gd
413  0  corpus/fixtures/r99_probe_r99b_sm.gd
411  0  corpus/fixtures/r99_probe_r99b_untracked.gd
 29  0  corpus/fixtures/run_battery.py
124  0  reports/round-99/r99-author.md
```

Zero deletions; `run_battery.py`'s 29 added lines are an 11-line comment block
plus 9 `CASES` tuples appended **after** the r98 tail. Parsing the frozen
`CASES` list: **342 entries**, the first r99 row at index 333, **nothing after
`r99_animtree_life`** — the nine rows are the contiguous tail 334–342, and the
r98 rows are untouched (333 rows before). `git status` at seat start showed only
the pre-existing untracked `reports/round-94/r94-reviewer.md` and
`reports/round-95/r95-reviewer.md`.

### 1.2 Probe provenance

The author claims the six committed probe copies are byte-identical copies of
the boundary's probe sources. Verified against the boundary's own live tree:

| probe | sha256 (committed = frozen = boundary) |
|---|---|
| `r99b_core` | `6683aba10439885d08488fd36275fabbb938895f04a853cb2650e4e10db0ff51` |
| `r99b_life` | `2eb2e2428a317934aa88682e1f3477352771243413fc5201df001b37e4724df8` |
| `r99b_modes` | `f6d23bb1f69e2c4f27d5904d846c3394edb83e73ae1386c25624f00ea6195ff5` |
| `r99b_silent` | `de0fd54e2ed5dbed8912f0848cb99d7775314510638a4802dc85571d54b645ee` |
| `r99b_sm` | `a8d41a1b1fd5c624d2f5501bbc4a1ba19cba15679ee5f01284120bcc8b229081` |
| `r99b_untracked` | `5981275d176f1fc06c5d644165ab3293cd079a54d9a700c7c2bca7eefb745afd` |

6/6 equal to `corpus/live/r99-boundary/probes/` — the tracked lattice carries
the boundary's measured bytes, and the r99 author's table is accurate.

### 1.3 Static audit of the nine markers (`static_rows.py`)

Parsing all 183 digest cells out of the committed markers:

- **183 cells = 61 logical × 3 backends**; every arm has all three of
  `gp/jolt/dummy` (core 7, ut_scope 7, ut_mech 7, modes 9, order 4, sm_adv 9,
  sm_misc 7, silent 5, life 6 logical cells).
- **`beq` present on exactly the 122 non-`@gp` cells and `=1` on all 122**;
  no `@gp` cell carries a `beq`. **No `mk=0`, no `err=`, no `ue=`, no empty
  pinned value, every `sha` 16 lowercase hex.**
- `rc` is `0` everywhere except the three `clsloop` cells (`0|134`) — the `td`
  encoding is confined to that cell and its three backends.
- `ee` appears on 15 cells (`core/wire` ×3, `core/pposerr` ×3,
  `silent/dupnode` ×3, `silent/dupstate` ×3, `silent/badstate` ×3) with the
  authored counts (`ee=1`,`1`,`1`,`1`,`6`) — the expected-error classes land
  exactly where the header declares them.
- sha reuse is structural, not suspicious: every logical cell repeats one sha
  across its three backends (the `beq=1` evidence), plus the two authored
  aliases `phys_pre == phys` and `idle_pre == idle` (same probe, same case
  args), plus one cross-arm coincidence: `ut_mech/manual` and `modes/manual`
  hash to the same stream `79a29c6826ccf3e7` (two different probes, two
  different case args, identical normalized manual-arm streams — noted, not a
  defect: each is pinned inside its own row).

---

## 2. Battery runs — the canonical judge

### 2.1 This seat's run on the frozen committed tree

```
python3 corpus/live/r99-critic/frozen/corpus/fixtures/run_battery.py \
  --runs corpus/live/r99-critic/battery-r99only-1 --only \
  r99_animtree_core,r99_animtree_ut_scope,r99_animtree_ut_mech,r99_animtree_modes,\
r99_animtree_order,r99_animtree_sm_adv,r99_animtree_sm_misc,r99_animtree_silent,r99_animtree_life
```

**PASS, 9/9** — `corpus/live/r99-critic/battery-r99only-1/20261016T075741709353Z/verdicts.json`
(`seeds_unchanged: true`, `ordinary=9`, `fail=0`). All nine rows exit 0 with the
exact authored marker; no stderr line, no unexpected diagnostic.

### 2.2 The author's receipts, re-read

| receipt | verdict | r99 rows |
|---|---|---|
| `runs/20261016T073752637660Z` | PASS 342/342 | 9/9 PASS, 1.7–3.7 s |
| `runs/20261016T074637746785Z` | PASS 342/342 | 9/9 PASS, 2.0–3.7 s |
| `runs/20261016T071708787743Z` (r99-only) | PASS 9/9 | 9/9 PASS, 2.2–3.9 s |
| `runs/20261016T071742046259Z` (r99-only) | PASS 9/9 | 9/9 PASS, 2.3–3.9 s |
| `runs/20261016T071812120994Z` (failed attempt) | FAIL 340/342 | **9/9 r99 PASS**; failures = `navagent3d_follow`, `phys3d_events_deferred_hang` |
| `runs/20261016T072806927381Z` (failed attempt) | FAIL 340/342 | **9/9 r99 PASS**; failures = `navagent3d_retarget`, `r96_joltdet_thread` |

The author's flake disclosure is accurate **verbatim**: both failed attempts
failed only on the four named legacy cells, all outside r99, and every r99 row
passed on all six recorded attempts plus my seventh.

### 2.3 Elapsed margin (r98-F4 class, structurally present here)

Measured r99 row wall time 1.6–6.0 s against the battery's
`CASE_TIMEOUT_SECONDS = 20` — a 3.3–12× margin on a host at load ~65–78. The
structural worst case is unchanged from r98: a row runs `ceil(cells/8)` chunks
of up to the fixture's own `BOUND_S = 14 s` (core = 3 chunks → 42 s > 20 s), so
a stalled chunk degrades from "fixture prints a diagnosis" to "battery TIMEOUT
with no cell text" (exactly what M5/M8 produce, §4). Fail-closed; see F2/F10.

---

## 3. Independent re-derivation (two routes, one scanner)

`corpus/live/r99-critic/rederive.py` implements the declared contract from
scratch: banner/empty drop, the exact 2-line Jolt warning drop, the five masks
(`#<digits>`, `srv=`, `seq=`, `idle_rows=`, `pf_rows=`), the ERROR-class
allowlist counting (`ee`) and unexpected-error capture (`ue`), the ObjectDB-leak
rule, sha256-16 over the masked stream, marker truncation for `td` cells, and
the field/`beq`/`peq`/`mk`/`dz`/`swpf` extraction. The 61 logical cells × their
case args, marks, allowlists and extraction prefixes were transcribed from the
fixture's declared cell tables (the contract), not from its GDScript scanner.

**Route A — the real battery's raw child logs** (183 `child.log` files from
§2.1's run, matched to cells by the fixture's own child-dir naming):

```
python3 corpus/live/r99-critic/rederive.py --mode A \
  --run-dir corpus/live/r99-critic/battery-r99only-1/20261016T075741709353Z
=> cells 183, missing [], diffs 0        (rederive-A.json)
```

**Route B — my own spawn shape** (own `project.godot` with
`config/name="R99Critic"`, own per-cell dirs, own `sh -c` + single-fd redirect,
own rc capture, `timeout -s KILL 14`):

```
python3 corpus/live/r99-critic/rederive.py --mode B --work corpus/live/r99-critic/own-run-1
=> cells 183, diffs 0, rc_histogram {0: 183}, elapsed_max 0.856 s, elapsed_sum 121.0 s
                                          (rederive-B.json)
```

183/183 cells reproduce **byte-identically**, including the `td` cell's
truncated hash `9251889a008ea983` on all three backends, every `beq=1`, the
`peq` split (1 on PHYSICS, 0 on IDLE), `dz=0`, and all 33 `swpf` values. Both
routes agree with the committed markers *and* with each other.

*Scanner-shape note (F7):* my first capture shape (Python's separate
stdout/stderr pipes) produced a **different sha with identical content** —
the pinned stream is the shell's merged `> log 2>&1` interleaving. See F7.

---

## 4. Mutation probes — are the pins load-bearing?

Every mutant is a minimal scratch copy of the frozen fixtures dir
(`run_battery.py` + `r99_animtree.gd` + the six probes + `project.godot`); the
judge is the **real** `run_battery.py` from that copy, restricted to the
targeted row(s) (`mutations.json`, `mutations2.json`, `mutations3.json`,
`mutations4.json`).

| # | mutation | row | expected | battery | result |
|---|---|---|---|---|---|
| M1 | one char of a pinned marker value (`tp 0.2167`→`0.2168`) | sm_misc | FAIL | **FAIL** | **DETECTED** (`exact stdout marker missing`) |
| M2 | probe value: wire animation end `Vector3(4,0,0)`→`(4.5,0,0)` | core | FAIL | **FAIL** | **DETECTED** (the committed probe copy is the measured input) |
| M3 | `--fixed-fps` never reaches any child (`eargs` → `""`) | modes, order | FAIL | **FAIL** | **DETECTED** (both rows; the rate flags are load-bearing) |
| M4a | `OS.crash` **before** the arm marker (rc=134, inside the `td` rc gate) | life | FAIL | **FAIL** | **DETECTED** (mark check + `ue=…handle_crash`) |
| M4b | `quit(3)` before the marker | life | FAIL | PASS | *mutant ineffective*: `quit()` is deferred and the arm's own `quit(0)` wins — see §5.4 |
| M4c | arm marker line deleted (rc=0, no crash) | life | FAIL | **FAIL** | **DETECTED** (`exact stdout marker missing`; the mark check alone) |
| M5 | marker printed, then the child **hangs** (60 s sleep) | life | ? | **FAIL** | **not a false pass** — cell tolerated, row failed on the outer 20 s bound + a parent-side engine ERROR (F2) |
| M6 | marker printed, then `OS.crash` (**the declared class**, rc=134) | life | PASS? | **PASS** | **intended tolerance confirmed** (4.1 s, no diagnostic) |
| M7 | `quit(7)` after the marker | life | FAIL | PASS | *mutant ineffective* (same `quit()` override as M4b) |
| M8 | **hang before** the marker (parent kill → rc=0, no marker) | life | FAIL | **FAIL** | **DETECTED** (mark missing; battery TIMEOUT 20.0 s) |
| M9 | `OS.kill(pid, 15)` after the marker | life | FAIL | **FAIL** | *mutant ineffective*: Godot 4.7's `OS.kill()` takes 1 arg → Parse Error, caught as `ue` |
| M10 | `OS.kill(get_process_id())` (SIGKILL) after the marker | life | FAIL | **FAIL** | **DETECTED** (rc outside `{0,134}` → fixture FAIL → marker missing) |

**8 of 10 effective mutants are rejected by the pins they target.** The two
"non-detections" (M5, and the two ineffective-quit mutants M4b/M7) are
explained and bounded: M4b/M7 never produced the rc I intended (`quit()` inside
a coroutine is deferred and the probe's final `quit(0)` overwrites it — a
property of the probe shape, not of the lattice), and M5 is analysed in §5.4/F2
where the *cell* tolerates a post-marker hang but the *row* still fails.

---

## 5. Named risks and encoded laws, measured

### 5.1 Rate-flag plumbing is positively confirmed (r98-F2 does **not** reproduce)

r98's critic could not distinguish "flag applied and inert" from "flag dropped".
Here the surface is **not** inert, so the same class of control discriminates.
`corpus/live/r99-critic/controls/controls.json` — the same `modes/idle` child
under four argv shapes, my own spawn:

| eargs | sha | `x_pf10/x_pf20/x_pf30/t_pf30/lead_zero` |
|---|---|---|
| `--fixed-fps 60` | `a8db5cb119c073ad` (= pinned `idle@gp`) | 0.5333/1.2000/1.8667/0.4667/1 |
| `--fixed-fps 30` | `a1f47c76f803bd87` (= pinned `idle_f30@gp`) | 0.5367/1.2000/1.8667/0.4667/2 |
| `--fixed-fps 30` (rep 2) | `a1f47c76f803bd87` (**identical — deterministic**) | same |
| `--fixed-fps 120` | `1b6eba439d239339` (= pinned `idle_f120@gp`) | 0.5667/1.2333/1.9000/0.4750/0 |
| *(flag dropped)* | `f16ba9ee04e22c8f` | 0.5879/1.2542/1.9209/0.4802/0 |
| *(flag dropped, rep 2)* | `a31d5e26cb5b2e4a` (**different — unthrottled, unstable**) | 0.5809/1.2463/1.9130/0.4782/0 |

Three distinct, reproducible per-rate shas that match the pins exactly, and a
dropped flag that produces a *different and non-reproducible* stream. M3
confirms the same at the row level. **The rate-variant cells can only pass if
the flag really reaches the child.**

### 5.2 `beq=1` backend-inertness is not vacuous

Control (`backend_control.gd`): a RigidBody3D dropped over a floor, 40 physics
ticks, in the same three project bodies the lattice uses —

```
gp     ENGINE engine=DEFAULT       FALL node=(0.0000,7.8154,0.0000) srv=(0.0000,7.8154,0.0000)
jolt   ENGINE engine=Jolt Physics  FALL node=(0.0000,7.9208,0.0000) srv=(0.0000,7.9208,0.0000)
dummy  ENGINE engine=Dummy         FALL node=(0.0000,10.0000,0.0000) srv=nil
```

The three bodies really select three different backends (Dummy does not
simulate at all), so the 122 `beq=1` cells are a real cross-backend comparison.
The lattice's claim is correspondingly narrow: the *animtree write* surface is
backend-inert, while general physics is not (GP ≠ Jolt in the control) — and the
`body` cell carries that boundary explicitly by pinning `srv=nil` on Dummy only.

### 5.3 The `srv=` mask: declared, and the server claim rides on extraction

`_mask` rewrites every `srv=<...>` to `srv=S` before hashing (declared in the
fixture header; it is what lets Dummy's `srv=nil` sit inside a `beq=1` cell).
Static control (`controls.json`): three lines differing only in the server value
— GP's real value, a mutated `(9.9999,…)`, and Dummy's `nil` — **mask to the
same string and the same sha**. So the hash/`beq` cannot see server-value
differences; every server-side claim is carried by the **extracted** `srv=`
field (42 cells pin one, verbatim from the unmasked line), and my two
re-derivation routes reproduce all of them. Correct as declared — noted so no
future reader treats `beq=1` on `body` as server-value evidence.

### 5.4 The `td` teardown tolerance: exact bounds, measured

`clsloop` is the only `td` cell: the hashed stream is truncated **at** the
`CLS_LOOP_ALIVE` marker and `rc ∈ {0, 134}` is accepted. What that admits, as
measured on this engine (`exitcode_probe.gd`, `exitcode_probe2.gd`, mutants):

| post/pre-marker outcome | child rc seen | `_cell_ok` | row |
|---|---|---|---|
| normal exit 0 | 0 | true | PASS |
| SIGABRT after the marker (`OS.crash`) — **the declared class** | 134 | true | **PASS (M6)** |
| SIGABRT **before** the marker | 134 | false (mark) | FAIL (M4a) |
| marker line absent, clean exit | 0 | false (mark) | FAIL (M4c) |
| SIGKILL after the marker | 9/137 | false (rc) | FAIL (M10) |
| hang before the marker (parent kill) | 0 | false (mark) | FAIL (M8) |
| hang after the marker | 0 (parent kill) *or* 137 (shell `timeout` wins) | true if 0 | **cell would PASS; row still FAILs** (M5, F2) |

*(The two KILL readings are shape-dependent: `timeout` wrapping `sh -c …`
yields 137 in the fixture's own command shape, while a bare killed inner
`sh -c` reported 9 in the first control — either way outside `{0,134}`.)*

Two engine facts this measurement pinned down (`exitcode_probe*.gd`):
`OS.get_process_exit_code()` returns the **raw signal-derived status**
(ABRT→134, SEGV→139, KILL→9/137) for signalled children, and returns **0** for a
child the parent killed *and reaped itself* — while also emitting
`ERROR: The process <pid> does not exist or is not a child of the calling
process.` to the parent's stderr. That stderr line is what makes M5 fail closed
at the battery level (`classify()` rejects any `ERROR:` on stderr), together
with the 20 s case bound. **The closure is therefore incidental, not an authored
guard** — see F2.

The author's disclosure ("abort during engine shutdown AFTER the arm marker")
is exactly the accepted class, and the boundary's receipts (939 children,
`rc` census `{0: 939}`, no kill, no watchdog) support its rarity. Note that the
tolerance is **rc-bounded, not "anything after the marker"** (M10), and that the
marker check — not the rc gate — is what defends the pre-marker crash (M4a).

### 5.5 Are the pins runtime measurements? (labrat audit + my verification)

The dispatched read-only probe's falsifiable hypothesis — *every pinned field is
a runtime measurement or an in-process comparison of two measurements* — was
**falsified**, in the bounded sense below. I verified each claim against the
frozen sources myself:

| family | pinned fields | class | evidence |
|---|---|---|---|
| `timescale` ×3 | `expect=0.2667` | literal restatement `2.0*8.0/60.0` | `r99_probe_r99b_core.gd:252` |
| `sm_adv` ×9 | `mode=`, `cond='…'` (SM_MODE) | echo of the call-site argument | `r99_probe_r99b_sm.gd:211` |
| `sm_misc` ×3 | `mode` (NX_MODE) | echo of the argument | `r99_probe_r99b_sm.gd:299` |
| `order` ×12 | `watcher=pre/post` | echo of the `--watcher` argv | `r99_probe_r99b_modes.gd` |
| `clsloop` ×3 | `rounds=20`, `names=29` | literal / `names.size()` of a hardcoded list | `r99_probe_r99b_life.gd:217,231` |
| `freetree` ×3 | `fr_tree_invalid=true` | **tautology** — `tree = null` then `not is_instance_valid(tree)` | `r99_probe_r99b_life.gd:143–146` |
| `freeplayer` ×3 | `fr_player_invalid=true` | **tautology** (same pattern) | `r99_probe_r99b_life.gd:156–158` |
| `missing_anim` ×3 | `anim='ghost'` | read-back of a literal just assigned | `r99_probe_r99b_silent.gd:108–114` |

None is covert — the constants are visible in the probe source, the markers
match exactly, and every one of these families sits beside genuinely measured
fields (`switch=`, `cond=` read-backs, `tp`, positions, `srv`, `made/skipped`).
The tautologies are the only ones that *cannot* detect a behaviour change on
their own. See F3.

The probe also audited for silent-pass paths and found none: every pinned prefix
prints unconditionally, and a missing line yields `field=` (empty) which cannot
equal any pinned value, while the arm's `mark` check fails the cell outright.

### 5.6 Flake hunt on the committed bytes

- **`clsloop` census deviation (new, F1).** One child in 51 observed clsloop
  children printed `CLS_LOOP made=341 skipped=239` (pinned 340/240) — on
  **jolt**, in the M5 mutant fixture's direct run:
  `corpus/live/r99-critic/direct-m5/r99t2043628_life_clsloop_jolt/child.log`.
  The three normally-`skipped` classes are split 4 `:decl` + 8 `:null`
  (`clsloop-census.gd`), and 34,800 single-attempt probes over 400 rounds ×
  29 classes × 3 backends (`clsloop-hunt.gd`) plus 30 further full `clsloop`
  case runs (`clsloop-diag.gd`) reproduced **340/240 with zero flips**. The
  deviation is real, rare (~1/51 in my window, 0 in 34,830 attempts), and
  **fails closed** (different sha + `beq=0` ⇒ the pinned text cannot match).
  It is **not in the author's disclosed flake list**.
- **Legacy load flakes** (`navagent3d_*`, `phys3d_events_deferred_hang`,
  `r96_joltdet_thread`) were observed only in the author's two failed attempts,
  all outside r99; my single 9-row run had none.
- **No `.godot` caches**: 0 minted in 366 child project dirs (F8).

---

## 6. Findings

**F1 (NOTE — undisclosed rare flake in a pinned cell; mine).** The `clsloop`
cell pins `made=340,skipped=240`, but I observed `made=341,skipped=239` once
(1/51 clsloop children; jolt; receipt above) — one normally-skipped class
instantiated. Not reproducible in 30 full-case reruns or 34,800 single-attempt
probes, so it is a rare engine-side nondeterminism, not a systematic mis-pin.
Impact is bounded and fail-closed (the sha and `beq` both move ⇒ the row fails),
but the author's flake disclosure covers only the teardown abort. Cheap fold:
add the flake to the author's known-flake list (and, if it recurs, drop the
count fields from the pin or pin a range).

**F2 (NOTE — the `td` cell's fail-closed closure for a post-marker hang is
incidental; mine).** A child that prints `CLS_LOOP_ALIVE` and then hangs is
*accepted by the cell logic*: the parent's deadline kill reaps it and
`OS.get_process_exit_code()` returns **0** (§5.4), which is inside the `td` rc
gate, and the truncation makes the silence invisible. The row still fails — but
because of (a) the battery's 20 s case bound and (b) an engine `ERROR:` line on
the parent's stderr from `get_process_exit_code` on a reaped pid. Neither is an
authored guard: raise `CASE_TIMEOUT_SECONDS` above ~25 s and the `td` cell alone
would report PASS for a hung child. Cheap fold: give the `clsloop` cells their
own tighter per-cell bound (so a hang cannot fit inside the battery timeout), or
record the parent-kill in the cell (e.g. a `killed=` field) so the tolerance is
explicit rather than inferred from truncation.

**F3 (NOTE — eight pinned-field families are echoes/tautologies; labrat, verified
by me).** `expect=` is a literal restatement; `mode=`/`cond=` (SM_MODE/NX_MODE),
`watcher=` and `rounds=/names=` echo arguments or constants; `fr_tree_invalid`
and `fr_player_invalid` are tautologically `true` (`x = null` then
`not is_instance_valid(x)`). None is covert and none carries a claim alone
(each sits beside measured read-backs), but the two `*_invalid` fields cannot
detect a behaviour change, and `expect=` enforces nothing by itself — the
equality is enforced only because `dtp` is pinned next to it. Cheap fold: derive
`*_invalid` from a real invariant (e.g. `tree.tree_root == null` after the free)
or drop it; replace `expect=2.0*8.0/60.0` with a second measurement (e.g. the
clock delta of an untimescaled twin).

**F4 (INFO — `swpf=-` conflates two states).** `-` means both "never reached
node=b" and "no `S pf=` row at all". The 33 `swpf` cells are still protected by
their sha and by the `mark` check (M4c), so the claim holds; the field is just
weaker than it reads.

**F5 (INFO — `dz=0` has no lower bound).** `dz` counts `E pf=` rows whose `d`
is non-zero; a stream with *no* `E pf=` rows would also yield `dz=0`. The
`min` cells are protected by sha + `mark`, so the "34-frame exactness" law is
carried by the hash rather than by `dz`. Cheap fold: pin the frame count next to
`dz`.

**F6 (INFO — `td` truncation hides all post-marker content for 3 cells).** For
`clsloop@{gp,jolt,dummy}` the hashed stream stops at the marker, so
`LIFE_DONE`, the exit status, and any ObjectDB-leak warning emitted at engine
exit are outside the pin. No r99 cell uses the `leak` allowlist, so a *pre*-marker
leak would fail the cell; a post-marker leak cannot be seen. Bounded by F2's
closure and by the boundary's 939-child clean census.

**F7 (INFO — the pinned `sha` includes a stdout/stderr interleaving).** The
child's stream is the shell's merged `> log 2>&1`; capturing the same child with
separate pipes yields **identical content, different sha** (my first spawn
shape, 3/3 cells). All recorded runs (author ×6, mine ×2 routes) agree on the
interleaving, so the pins are stable in the declared shape — but the hash
depends on flush/ordering, i.e. on something the lattice does not control.

**F8 (INFO — no cold-cache census in r99).** r98 pinned `gd=0`; r99 carries no
`gd` field. Empirically 0 `.godot` dirs were minted across 366 child project
dirs (both my routes + the battery), so the premise holds today; it is simply
unpinned. Cheap fold: keep the `gd` census in the digest cell.

**F9 (INFO — a cross-arm stream coincidence).** `ut_mech/manual` and
`modes/manual` produce the identical normalized stream
`79a29c6826ccf3e7` from different probes and different case args. Harmless
(each cell is pinned inside its own row) but it means the hash alone cannot
distinguish those two arms' manual cases.

**F10 (INFO — worst-case arm runtime exceeds the battery case timeout).** Same
class as the r98 critic's F4: `ceil(cells/8) × BOUND_S(14 s)` = 42 s for `core`
vs `CASE_TIMEOUT_SECONDS = 20`; measured 1.6–6.0 s, so the practical margin is
3.3–12× on a host at load ~65–78. A stalled chunk degrades to a battery TIMEOUT
with no cell text (exactly M5/M8). Fail-closed; worth a per-arm bound shrink.

---

## 7. Hygiene, writes, cleanup

- **Zero tracked writes by this seat.** `git status --short` shows only the
  pre-existing untracked `reports/round-94/r94-reviewer.md`,
  `reports/round-95/r95-reviewer.md`, and (after this seat) this report.
  `git diff HEAD -- corpus/fixtures reports/round-99` is empty: no committed
  byte was moved by this seat; all measurement ran on the `git archive` tree and
  on scratch copies.
- Scratch is confined to `corpus/live/r99-critic/**` (**47 MB**, gitignored via
  `corpus/.gitignore:1 live/`): `frozen/` (the archive tree), `battery-r99only-1/`,
  `own-run-1/` (183 child dirs), `mutants/` + `*_runs/`, `controls/`,
  `clsloop-flake/`, `direct-m5/`, `smoke/`, `exitprobe/`, `*.py`, `*.json`,
  `env.txt`. Disk: 158 GB used / 767 GB free.
- **No orphan processes from this seat**: every child was `timeout -s KILL`
  bounded and every `Popen` reaped; the 14 live Godot children observed at the
  end of the seat all belong to the concurrent r99 **scribe / verifier /
  simplifier** seats and were left untouched.
- The probe copies under `corpus/fixtures/` were **never** executed or written
  by this seat; every mutant ran from its own scratch copy, and the real battery
  judge re-copies seeds into per-run scratch (its `seeds_unchanged` flag was
  true in every run).

---

## 8. Remaining risks / verification gaps

1. **F1** — a rare, undisclosed `clsloop` census deviation (1/51 observed; 0
   flips in 34,800 single-attempt probes — 400 rounds × 29 classes × 3 backends
   — plus 30 further full `clsloop` case runs); fails closed, but it is a live
   flake in a pinned cell.
2. **F2** — the `td` cell's post-marker-hang closure is incidental (outer 20 s
   bound + an engine stderr ERROR), not an authored guard.
3. **F3** — eight pinned-field families are echoes/tautologies; two
   (`fr_tree_invalid`, `fr_player_invalid`) cannot detect a behaviour change.
4. **F6/F7** — the `td` truncation hides post-marker leaks, and the hash rides
   on a stdout/stderr interleaving the lattice does not control.
5. **F8/F10** — no cold-cache pin; worst-case arm runtime exceeds the battery
   case timeout.
6. **Not re-derived by this seat:** the boundary's 939-child hog runs and the
   author's arm-level `ftest` scratch runs; my statements about them are limited
   to the receipts I read (`RECEIPTS.md`, `verdicts.json`, manifests).
7. **Engine-version coupling**: the lattice pins rc/sha/text only (no `eng=`),
   but every sha is engine-build-specific; an engine bump reddens the rows
   rather than re-baselining them (intended).

---

## 9. Receipts and repro

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# frozen committed tree
git archive f1ff626 | tar -x -C corpus/live/r99-critic/frozen
# the judge, on the frozen bytes, 9 r99 rows
python3 corpus/live/r99-critic/frozen/corpus/fixtures/run_battery.py \
    --runs $PWD/corpus/live/r99-critic/battery-r99only-1 --only \
    r99_animtree_core,r99_animtree_ut_scope,r99_animtree_ut_mech,r99_animtree_modes,\
r99_animtree_order,r99_animtree_sm_adv,r99_animtree_sm_misc,r99_animtree_silent,r99_animtree_life
# static row audit (183 cells, beq 122/122, field census)
python3 corpus/live/r99-critic/static_rows.py
# independent re-derivation, route A (real battery child logs) and route B (own spawns)
python3 corpus/live/r99-critic/rederive.py --mode A \
    --run-dir corpus/live/r99-critic/battery-r99only-1/20261016T075741709353Z
python3 corpus/live/r99-critic/rederive.py --mode B --work corpus/live/r99-critic/own-run-1
# mutation suite (real battery as judge, scratch fixture copies)
python3 corpus/live/r99-critic/mutate.py
# controls: rate-flag plumbing, backend distinctness, srv masking (driver run
# inline; receipts in corpus/live/r99-critic/controls/controls.json + controls/fps,
# controls/backends)
# engine exit-code / td-bound controls
/usr/bin/godot --headless --path corpus/live/r99-critic/exitprobe \
    --script res://exitcode_probe2.gd --      # parent-kill rc=0, shell-timeout rc=137, ABRT 134, SEGV 139
# clsloop flake hunt
for b in gp jolt dummy; do /usr/bin/godot --headless \
    --path corpus/live/r99-critic/clsloop-flake/$b --script res://clsloop-hunt.gd --; done
```

Receipts (all gitignored, under `corpus/live/r99-critic/`): `env.txt`,
`frozen/`, `battery-r99only-1/20261016T075741709353Z/verdicts.json`,
`static_rows.py` + `static_rows.json`, `rederive.py` + `rederive-A.json` +
`rederive-B.json` + `own-run-1/`, `mutate.py` + `mutations{,2,3,4}.json` +
`mutants/` + `*_runs/`, `controls/controls.json` + `controls/` (fps, backends),
`exitcode_probe{,2}.gd` + `exitprobe/`, `clsloop-{census,hunt,diag}.gd` +
`clsloop-flake.json` + `clsloop-flake/`, `direct-m5/` (the F1 receipt),
`smoke/`, `mutations.log`.

Provenance: this seat wrote only `corpus/live/r99-critic/**` (gitignored scratch)
and this report. No fixture, probe, runner, contract, axis, or route was
touched; no commit was made. The one `labrat` descendant was read-only and
edited nothing.
