# r100 verifier — capstone gate on committed `8183191`

**VERDICT: VERIFIED-WITH-FINDINGS.** The r100 lattice's *content* re-derives on
the committed bytes: **142/142 cells** rebuilt by this seat's own spawner and
own scanner (two reps, 0 problems), **137/137** sha-bearing cells identical
across **four** independent harness instances, `beq`/`eq` populations complete
(35/35 and 15/15), all four live expected-error classes matched at their exact
allowlist heads with **0** unexpected diagnostics and **0** leak lines, and
**6/6** scratch-copy mutations plus the battery's own mutation probe detected —
with **2/2** unmutated controls reproducing the pins byte-for-byte.

**Finding F1 (HIGH, closed by successor):** the landing *as committed* is not
self-contained. On a pristine `git archive 8183191` extraction the full battery
is **342/350**, and the eight failures are exactly the eight r100 rows — every
one of the **142 cells** reports `err=probe source missing` because the six
`corpus/fixtures/r100_probe_r100b_*.gd` seeds are untracked at `8183191`. A
sibling seat's fix commit `523c943` (07:06:31, mid-seat) commits the six seeds;
a pristine archive of `523c943` runs **8/8 rows PASS with stdout byte-equal to
the pins `8183191` committed**. Details in §6. Admission is the adjudicator's
call, not this seat's.

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 100. Assigned
landing: `8183191f789acca8f3f0292392a1ee84fe317a50` ("r100 author: fixed-fps/
quit-after/render-target/Area3D lattice (8 rows/142 cells, +39/-0)", 3 files,
+1064). Reads: `reports/round-100/r100-author.md`, the six worktree seeds, the
boundary probes. This seat wrote only `corpus/live/r100-verifier/**` inside its
**archive copies** (never the source worktree) plus this report; no commits.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/python3` `3.14.7`, 32 threads, 1-min load 2.8–9.4 across the seat (no
ambient hog farm). **No `lsp` device is exposed to this seat's toolset** (same
recorded absence as r85–r99); no symbol-aware work was in scope and no source
edit was made, so the hand-edit fallback was never in play.

## Byte custody

- **Assigned landing** `8183191`; `git show --stat` = `r100_fpslat.gd` +892,
  `run_battery.py` +39, `r100-author.md` +133 (1064 insertions, 0 deletions).
- **Pristine archive** `/home/vgpnk/g3d-r100-8183191` = `git archive 8183191`;
  `diff -r` against a fresh extraction of the same commit differs **only** by
  this seat's own `corpus/live/` scratch and `__pycache__` — the tree is the
  commit, byte-for-byte.
- **Blob shas** (archive = `git show HEAD:<path>`): `r100_fpslat.gd`
  `da11495de7a24703a911bb1c8fef15ba62481e5f492bda1efd56fc3b1950b537` (892
  lines), `run_battery.py`
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`,
  `r100-author.md`
  `881aa7f7077286b3d7f1800b40d3769f05c2ced89783545b9e90c218dd971b3a`.
- **The archive contains zero `r100_probe_*` seeds** — the driver's
  `_child_prepare` reads `res://r100_probe_<name>.gd`; this is F1's root cause.
- **Seed provenance**: all six worktree seeds are `cmp`-identical to
  `corpus/live/r100-boundary/probes/r100b_*.gd` (sha256-16: sched
  `c61025594deff49d`, modes `249c0caf8ac4a1d5`, rt `8bfd76adf5ae5551`, area
  `a577d6265f78f1ff`, life `427fc7d159f524da`, cls `0adf98aadd38cdc6`). The
  seed-restored extraction `/home/vgpnk/g3d-r100-8183191-seeds` pairs the two
  **8183191** code blobs with the six seed blobs that `523c943` later committed
  (identical bytes) — i.e. exactly the author's green-run condition.
- **CASES diff is insertion-only** (AST `literal_eval` on the committed blobs
  `c28783a` → `8183191`): **342 → 350**; strict prefix `new[:342] == old`;
  removed 0, changed 0, duplicate names 0; the 8 new rows are
  `r100_fpslat_{sched,qa,modes,compose,rt,area,life,cls}` on `r100_fpslat.gd`
  with `expected_exit=0`.
- **The repo moved mid-seat**: sibling commit `523c943` (07:06:31, "r100 landing
  fix: commit the six … seeds (reviewer F1 …)") landed while this seat was
  extracting. HEAD at report time is `523c943`; the assigned landing object is
  unchanged and still resolvable; **every run below executed in an archive
  copy**, never the source worktree. The source worktree has **0 tracked
  modifications** from this seat.

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | `git archive HEAD` to /home; committed bytes loaded; zero tracked writes | **PASS** — `/home/vgpnk/g3d-r100-8183191` ≡ `8183191` (diff clean); only this report added to the source repo, uncommitted |
| 2 | Full battery on committed bytes | **PASS-with-F1** — pristine `8183191` alone: **342/350**, the 8 failures exactly the 8 r100 rows (§1, §6) |
| 3 | Author's 350/350 ×2 claim | **PASS** — green1 **350/350** and green2 **350/350** (with `--probe-failing`), r100 8/8 pin-equal in both (§1) |
| 4 | Re-derive all 142 cells | **PASS** — **142/142** match+ok in two own-harness reps; **137/137** sha-bearing cells identical across 4 instances; 0 problems (§2) |
| 5 | Expected-error classes live-matched | **PASS** — arerr/lerr/lfin/wm all matched live at exact heads; `ue=0`, leaks `0` across 142 logs (§3) |
| 6 | Mutation / negative controls | **PASS** — 6/6 mutants detected with mechanism-specific evidence; 2/2 controls exact; battery's own probe `detected=True` (§5) |
| 7 | Envelope cells are load-bearing | **PASS** — `inert` predicate discriminates (pinned traps 1, working forms 0); unbound rc=137/boot=1/tickge1=1 (§4) |
| 8 | Scanner semantics | **PASS** — own re-implementation agrees **14/14** with the committed `_scan_lines` on synthetic streams |
| 9 | Author's cited receipts are real | **PASS** — 7 receipts re-read; 2×350/350; the disclosed flake classes are exactly what the receipts show (§7) |
| 10 | Hygiene / red flags | **PASS with INFO findings** — bounded children, dirname validation, fail-closed `ue`/rc/marker, no `user://`, no dead gates (§8) |

## 1. Batteries executed (all in archive copies)

| run | dir | condition | totals | r100 rows |
|---|---|---|---|---|
| pristine1 | `/home/vgpnk/g3d-r100-8183191/corpus/live/r100-verifier/battery/pristine1/20261016T100229972489Z` | **committed bytes alone** (`8183191`) | **342/350**, rc=1 | **0/8** — 142/142 cells `err=probe source missing`, row elapsed 0.53–0.70 s |
| green1 | `…-seeds/corpus/live/r100-verifier/battery/green1/20261016T101206818758Z` | committed bytes + six seeds | **350/350**, rc=0 | **8/8 PASS, stdout byte-equal to the pins**, 142 cells |
| green2 | `…-seeds/…/battery/green2/20261016T102121538842Z` | + `--probe-failing` | **350/350**, `probes=1`, rc=0 | **8/8 PASS, pin-equal**, 142 cells |
| successor | `/home/vgpnk/g3d-r100-523c943` (`git archive 523c943`) | pristine successor archive | **8/8**, rc=0 | **8/8 PASS, pin-equal** |

Per-row elapsed (battery's own 20 s cap), green1 / green2 / author's green:
sched 2.54/2.50/2.99 · qa 2.59/2.49/2.70 · modes 5.25/5.25/5.41 · compose
4.14/3.71/4.25 · rt 1.73/1.90/2.13 · area 1.09/1.40/1.25 · life 15.57/15.78/15.69
· cls 1.66/1.84/1.89. `seeds_unchanged=True` in all three of this seat's full
runs and in the successor run.

## 2. Independent re-derivation of all 142 cells

- **Cell inventory, two sources**: (a) the committed driver's own cell tables,
  executed by `tools/dump.gd` against a scratch copy of the committed
  `r100_fpslat.gd` — `sched 21, qa 13, modes 22, compose 34, rt 11, area 8,
  life 24, cls 9` = **142**; (b) the eight pinned markers parsed out of the
  committed `run_battery.py` (imported, literal tuples) — the same
  21/13/22/34/11/8/24/9.
- **This seat's own harness** (`tools/rederive.py` + `tools/vnorm.py`): own
  Python spawner (`/bin/sh -c`, `timeout -s KILL`, same command shape as
  `_child_prepare`), own scanner re-implemented from the declared contract,
  own field extraction, **real exit codes** (`rc=134` for `writemovie`, `rc=137`
  for the three unbound cells, `rc=0` elsewhere). Two full reps:
  **mine 142/142 match + cell_ok, 0 problems; mine_rep2 142/142, 0 problems**
  (8/8 arms, `match_and_ok=142`).
- **Cross-instance identity**: **137/137** sha-bearing cells have an identical
  `sha` in all four instances (green1, green2, mine, mine_rep2); the five
  envelope cells (2 `inert`, 3 `unbound`) carry no sha by design. `mk=0` never
  observed in any instance.
- **Flag census of the committed pins** (exact tokenizer): `beq=1` 25,
  `beq=0` 10 — population 35, equal to the driver's own comparison rule (names
  containing `@`, not `@gp`, no envelope); `eq=1` 11, `eq=0` 4 — population 15,
  equal to the declared `eq` cells; `ee=1` on 13 cells; envelope cells 5. The 10
  `beq=0` cells are the four Dummy divergences (`sched ffps60@dummy`, `rt
  srv@dummy`, `area enter/exit@dummy`) plus the six non-default `cls` census
  projects — all genuinely divergent, none stale.
- **Scanner differential** (`tools/scandiffcmp.py`): the committed fixture's own
  `_scan_lines` executed by Godot over 14 synthetic streams (banner/blank, Jolt
  pair complete and split, id mask, all wall prefixes, benchmark block,
  allowlist hit/miss, leak with/without allowlist, non-allowlisted SCRIPT
  ERROR/Parse Error/handle_crash, marker truncation) — **14/14 agree** with the
  re-implementation on kept lines, sha, `w`, `ee`, `ue`.

## 3. Expected-error classes live-matched (this seat's own 142 logs)

| class | declared cells | live-matched cells | distinct live line | exact allowlist head |
|---|---|---|---|---|
| `arerr` | 8 (all `area`) | **6** — the 2 Dummy cells emit no signal (the expected null; pins carry `ee=0` there) | 1 | yes |
| `lerr` | 3 | **3** | 1 | yes |
| `lfin` | 3 | **3** | 1 | yes |
| `wm` | 1 (`writemovie`) | **1** | 1 | yes |

- Live lines are the pins' own heads, verbatim: the `body_shape_entered`
  RID→Object callback diagnostic, the `no_such_method_at_all` call error, the
  `previously freed` `global_position` access error, and `ERROR: Parameter "t"
  is null.`
- **`ue = 0` across all 142 cells** and **0 ObjectDB-leak lines anywhere** (the
  driver declares a `leak` class but no cell requests it — a leak would fail
  closed; none occurred).
- `writemovie` re-derived live: `rc=134`, stream truncated at the deterministic
  `   at: texture_2d_get` line, `sha=aa2728fd5adc343f`, `ee=1`, `movie=,
  recording movie in 1152×648 @ 60 FPS...` — the ASLR backtrace is excluded, as
  declared.
- Jolt job-system warning pair: `w=1` in the first harness pass, `w=0` in rep2 —
  load-dependent, dropped from the hash and pinned nowhere, exactly as declared.

## 4. Negative / envelope controls

- **Flag-trap discrimination** (`tools/envctl.py`, seed-restored bytes): the
  pinned equals-form cell (`--fixed-fps=60`) reproduces `inert=1` with a
  free-running triple (`n_pr=292, fpt=[2:70, 3:49, 4:1]`); the pinned
  after-`--` cell reproduces `inert=1` (`n_pr=293`); the **same probes** with the
  working space form as engine flags read `inert=0` with the pinned-60 triple
  `n_pr=120, n_ph=120, fpt=[0:1, 1:119]` — **4/4 as expected**, so the envelope
  predicate is not vacuous.
- **Unbound envelope**: my own spawner records the real SIGKILL exit
  `rc=137` with `boot=1, tickge1=1` (LF_BOOT present, ≥1 LF_TICK) for all three
  backends; the bounded twin exits `rc=0` with the pinned sha.
- **Backend divergence is real**: the four `beq=0` cells' shas differ from their
  `@gp` references in every instance, and the Dummy trajectory hash
  `a2d4de09077612bf` is the non-integrating one.

## 5. Does the gate bite? (scratch-copy mutations, `tools/mutations.py`)

Each mutant is a copy of the seed-restored fixtures; one asserted patch; the
battery runs `--only <one arm>`; the committed tree is untouched.

| experiment | patch | result |
|---|---|---|
| control_area / control_cls | none | **PASS**, row stdout **== pin** (both) |
| M1 pin flip | one hex char in the committed `area` pin (`…600ae` → `…600af`) | battery **FAIL** (marker mismatch) — the pins are load-bearing |
| M2 seed teleport | probe `teleport_at := 34 → 30` | 4 `exit` cells move (`e_last 35→31`, sha `b5afba29…` → `a222c5bb60e9d00a`), row **FAIL** — pins measure live probe behavior |
| M3 allowlist removed | `arerr` key renamed in the driver | fixture's own row **FAILs**; `ue=ERROR: Error calling from signal 'body_shape_entered'…` on the 6 signal cells; their shas move (`62597d86…`→`b7269021bda7ae70`, `b5afba29…`→`97fa8dae1772d839`) — the class is live-matched and fail-closed |
| M4 backend substitution | `const DUMMY := ""` | the 2 Dummy cells become GodotPhysics (`e_first=29`, sha `62597d86…`/`b5afba29…`, **`beq` 0→1**), row **FAIL** — backend coupling proven |
| M5 marker suppressed | probe `AR_END` → `XX_END` | 8/8 cells `mk=0`, `e_first=`/`e_last=` empty, fixture row **FAIL** |
| M6 config mutation | `_base(tps := 60 → 120)` | 7/9 `cls` cells move (`census` reads `tps=120 (int)`, sha = the old `t120` census sha `dd1151ce…`; `census@t120`'s `beq` flips 0→1), row **FAIL** |

Battery-internal control: green2 ran `--probe-failing` (wall box depth
4.0 → 6.0 in `body3d_slide.gd`) with `detected=True`, `seeds_unchanged=True`,
`PASS`.

## 6. F1 — the landing as committed is not self-contained (HIGH; closed by `523c943`)

- **Evidence on the assigned bytes.** Pristine `8183191` archive, full battery:
  `totals: cases=350 pass=342 fail=8`; every failure is an r100 row, each with
  `exit=0` and `elapsed 0.53–0.70 s` (no child ever spawned). Row stdout:
  `FAIL r100_fpslat area enter@gp{err=probe source missing} …` — **142/142
  cells** carry `err=probe source missing`, one per cell, in the exact
  per-arm counts 21/13/22/34/11/8/24/9.
- **Root cause.** `r100_fpslat.gd::_child_prepare` copies
  `res://r100_probe_<probe>.gd` out of the fixture dir; `git archive 8183191`
  contains no such file. The author's §6 zero-commit disclosure names the six
  seeds as "inherited uncommitted" — the landing therefore cannot run its own
  deliverable from committed bytes.
- **Cross-seat convergence.** The sibling reviewer report
  `reports/round-100/r100-reviewer.md` (untracked) records the same finding with
  the same `err=probe source missing` evidence; the fix commit `523c943`
  ("r100 landing fix: commit the six … seeds") landed at 07:06:31, after this
  seat's pristine extraction and before its first mutation run.
- **Fix verified, not assumed.** Fresh `git archive 523c943` (6 seeds present,
  nothing from the worktree): battery `--only` the eight rows →
  `totals: cases=8 pass=8 fail=0`, `verdict PASS`, and **8/8 row stdout
  byte-equal to the pins `8183191` committed** (`successor.json`). F1 is closed
  in the successor tree; it stands as a finding against `8183191` itself.

## 7. Author receipts and claims re-read

Seven `corpus/live/r100-author/runs/*/verdicts.json` receipts re-read: two
**350/350** greens; `348/350` (run A: `phys3d_events_script_size_gate` +
`r100_fpslat_life` — the disclosed racy-`beq` failure, fixed before the greens);
two `340/350` (all ten `bpy_rbw3d_*` ambient-contention timeouts); `349/350`
(`phys3d_events_freed_space_methods`, the documented r88 envelope); and the 8/8
targeted battery. **r100 8/8 green in every receipt except run A's one row** —
the author's §4/§5 narrative is accurate as written. The claim "350/350 ×2" is
reproduced independently in §1 (green1/green2).

## 8. Findings, hygiene, blockers

- **F1 (HIGH)** — §6. Closed by `523c943`; stands against `8183191`.
- **F2 (INFO)** — the repository advanced mid-seat (`523c943`); this seat's
  evidence is pinned to archive bytes of the assigned landing and of the
  successor, never to a moving worktree.
- **F3 (INFO, infrastructure)** — the frozen `probeParent` privilege was used
  exactly once: one read-only `ufo-labrat` probe (hypothesis: the `area` Dummy
  pins are backend-coupled). That seat **has no shell capability on this host**;
  it returned static file inspection only (confirmed the `DUMMY` token and
  `dummy60` coupling, parsed the two `@dummy` pins) and explicitly marked the
  hypothesis UNTESTED. No second probe was dispatched (frozen budget). The
  hypothesis was closed empirically by this seat as **M4**.
- **F4 (INFO)** — the Jolt job-system warning pair is load-dependent (`w` 0–1
  across reps), dropped from the hash and pinned nowhere; a *lone* WARN1 would
  enter the hash and move the sha (fail-closed direction).
- **F5 (INFO)** — the `leak` allowlist class is declared in the driver's table
  but requested by no cell; 0 leak lines observed in 142 logs, so the class is
  dormant by construction and a leak would fail the cell (fail-closed).
- **Hygiene** — no `if false` / `or true` / TODO / FIXME in the committed r100
  files; no `user://` in fixture or seeds; children bounded
  `timeout -s KILL 15` (5 s unbound, 13 s fdelay200) under the battery's 20 s
  case cap; `CHUNK=8`; child dirnames validated (`..`, `/`, `\`, `:`, charset)
  and pid-namespaced; `_cell_ok` fail-closed on `ue`/rc/marker; seeds hashed
  before/after in every run (`seeds_unchanged=True`); all scratch confined to
  the archive copies.
- **Blockers**: none. This seat made no commits, no tracked writes, and no
  shipping decision.

## Artifacts (this seat)

- `tools/dump.gd` (cell/project table dump), `tools/specs.json` (142 specs),
  `tools/vnorm.py` (from-contract scanner/renderer), `tools/rederive.py`
  (own spawner, 142-cell re-derivation), `tools/scandiffcmp.py` (+`scandiff.gd`),
  `tools/errclasses.py`, `tools/envctl.py`, `tools/mutations.py`,
  `tools/successor.py` — all under `/home/vgpnk/g3d-r100-8183191[-seeds]/
  corpus/live/r100-verifier/tools/`.
- Receipts: `…/battery/pristine1/…/verdicts.json`, `…/battery/green1|green2/…/
  verdicts.json`, `…/mine/rederive.json`, `…/mine_rep2/rederive.json`,
  `…/mine/errclasses.txt`, `…/mine/mutations.log` +
  `/home/vgpnk/g3d-r100-8183191-mut/*/…/verdicts.json`, `…/envctl/envctl.json`,
  `/home/vgpnk/g3d-r100-523c943/successor.json`.
