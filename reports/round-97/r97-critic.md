# r97 critic — adversarial review of the committed nodelat landing (`ec27b78`)

Seat: **GAME-DEV-3D r97 CRITIC** (frozen `probeParent`). Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r97-critic.md`.
Attacked artifact: commit
`ec27b782f8e1ed0337da75e3dcb1338d09241c83` — `corpus/fixtures/r97_nodelat.gd`
(+847, new), ten `corpus/fixtures/r97_probe_*.gd` (+1704, new),
`corpus/fixtures/run_battery.py` (+38/−0, insertion-only),
`reports/round-97/r97-author.md` (+218); **324 battery rows** (265 ordinary +
59 negative controls), the 8 r97 rows are rows **317–324** (contiguous tail).
Author / scout / boundary reports and `corpus/live/r97-{author,scout,boundary}/`
receipts were read, never written. **Nothing tracked was written by this seat;
no commit was made** (this report is the only new file; it is left for the
operator to commit, exactly like the sibling seats' reports).

Environment (`corpus/live/r97-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, `/usr/bin/python3` **3.14.7**, kernel
7.2.3-arch1-3, 32 threads, 30 GB RAM. The box was **loaded for the whole seat**
— load1 **51.0 → 58.8** (57 at report time), with concurrent sibling lanes
observed live: r94/r95 2D critics (full batteries), r96 lanes, an r98 authoring
lane, `r99-boundary`, plus the wave-B r97 seats. Every r97 measurement below is
therefore a **loaded-host** measurement; no quiet baseline existed (same caveat
as the boundary and the r96 seats).

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded
absence as r85–r96). This seat made no source edit, so the hand-edit fallback
was never in play; the one source-shape probe (fixture scanner) ran on a
scratch-only diagnostic copy under `corpus/live/r97-critic/`, never on a
tracked file.

**probeParent seat:** exactly one read-only `ufo-labrat` was dispatched (static
marker/key derivability probe over the 8 committed markers). Its report is
folded into §3.4; no other descendants, nothing edited.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with findings that
are comment/coverage/wording class only.** The eight r97 rows reproduced
**8/8 on a frozen `git archive ec27b78` tree in three independent battery runs
(one r97-only, two full 324-case runs)**, and an **independent child runner**
(own scratch, own spawn shape, own exit-code capture, own scanner) re-derived
**317/317 cells byte-identically to the committed markers** (3 × 79 cells across
the 8 arms, plus 10 further xr reps = 80 cells). **10 of 11 mutation probes are
rejected** by the pins they target (the 11th is rejected conditionally, see
§4.11). Every digest cell was recomputed from the raw child text, not restated
from the PASS line, and five sampled cells reproduce the **scout's own
receipts** byte-for-byte after the declared normalizations. The three named
risks were measured and behave as the author declared them.

The findings are: **F1** — the fixture header law comment still says "all 44
classes" while the pinned census is 45 (convergent with r97-verifier LOW-1 /
r97-reviewer F1 / r97-simplifier F-1); **F2** — the Jolt-warning normalization
is real and load-bearing but *only conditionally exercised* (~1/3 of runs), and
its `w` counter has no consumer (convergent with verifier LOW-3 / simplifier
F-2); **F3** — the deferred-pin **census** path is fail-open (census children's
`ue`/rc are never checked); **F4** — a methodology hazard: the cell `sha` is
computed over the **shell-merged stdout+stderr stream**, so a harness that
captures the two fds separately sees sha divergence on error-emitting cells
(this critic's own first pass, and a future-seat trap); **F5** — `SUM_PREFIX`/`f`
spec machinery is dead config (convergent with verifier LOW-4-class notes /
simplifier F-2). **No finding touches a physics pin, a marker, or committed
behavior.**

**Blockers: none.** The one permitted `labrat` probe returned a static reading
(its profile has no shell/exec — the same limitation the r94/r95/r96 critics
recorded); it found no marker inconsistency, and no evidence gate is left open.

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, prior rows untouched, row arithmetic | **CONFIRMED** | §1.1–1.2 |
| 2 | fixture/probe custody: shas, byte-identical probe copies | **CONFIRMED** | §1.3 |
| 3 | reproduce the 8 rows on the committed bytes (frozen tree) | **CONFIRMED** | §2.1–2.2 |
| 4 | full 324-case battery on the committed bytes | **322/324, 323/324 — failures pre-existing, outside r97; 8/8 r97 green in both** | §2.3 |
| 5 | is the evidence real (cells = raw child text)? | **CONFIRMED** | §3.1–3.2 |
| 6 | do the pins reproduce the scout's/boundary's own receipts? | **CONFIRMED** (7/7 spot checks) | §3.3 |
| 7 | are the pins load-bearing? | **CONFIRMED for 10/11; 1 conditional (F2)** | §4 |
| 8 | named risk 1: xr pins the degenerate rc=134 distribution | **CONFIRMED degenerate in my hands (52/52 + 12/12)**; strict pin, envelope comment (F-note) | §5.1 |
| 9 | named risk 2: softfloor two-valued census | **CONFIRMED two-valued, both branches deterministic; pinned branch is the deterministic one** | §5.2 |
| 10 | named risk 3: ClassDB census corrected 44 → 45 | **CONFIRMED 45 statically and at runtime; header comment stale (F1)** | §5.3 |
| 11 | flake hunt: r97 rows under load | **CONFIRMED stable** — 0 r97 deviations in 3 battery runs + 34 arm runs + 317 cells | §2.4 |
| 12 | hygiene: tracked writes, strays, cleanup | **CONFIRMED** — zero tracked writes, scratch confined, no orphan processes | §7 |

---

## 1. Custody and byte-level checks

### 1.1 Insertion-only, row arithmetic

`git diff --numstat eb641c2 ec27b78 -- corpus/fixtures/run_battery.py` =
**38 / 0** (single hunk, after the r96 `r96_joltdet_nc` row); `git show
--stat ec27b78` = 13 files, 2807 insertions, 0 deletions (12 new + this
report). `import run_battery` on the committed blob:
**324 CASES = 265 ordinary + 59 negative**; the 8 `r97_nodelat_*` rows are
indices **316–323** (contiguous tail), all `expected_exit=0`, all on
`r97_nodelat.gd`. Marker cell counts from the committed strings:
24+7+6+11+6+13+8+4 = **79 cells**; per-arm child census measured from a live
scratch (below) = **83 children** (79 pinned + 4 softfloor deferred-pin census).

### 1.2 The measured tree

The gate ran on `git archive ec27b78 | tar -x` extracted to
`corpus/live/r97-critic/frozen/` (a frozen copy, never the live tree, so the
sibling r98 lane's in-flight edits could not contaminate it). **HEAD moved
mid-seat** — from `ec27b78` to `77e873f` via `7c2b540` (simplifier), `20b8b19`
(scribe), `b418272` (verifier), `77e873f` (reviewer) — all **report-only**:
`git diff --name-only ec27b78..HEAD -- corpus/fixtures` is empty and all 11
`corpus/fixtures/r97_*` blobs re-hash byte-identical to `ec27b78`. The worktree
carries a sibling r98 lane's **+41-line insertion** in `run_battery.py` (r98
rows only, no r97 line touched) and its new `r98_*` files; none of it is this
seat's.

### 1.3 Custody shas

- `r97_nodelat.gd` = `c30aca993686733f43b4b0088f3613131cc25f2c65c7157bd6da3011907b36c5`
  — matches the author's RECEIPTS table.
- All **10** `r97_probe_*.gd` shas match the author's table, and `cmp` against
  the scout's/boundary's own probe sources is **byte-identical 10/10**
  (`r97-scout/probes/{cbedge,classdb,crashiso,dssparam,njoint,soft,vehicle,xrkeep}.gd`,
  `r97-boundary/probes/{r97b_free,r97b_softfloor}.gd`) — the §1 rename hazard is
  avoided by construction, not by claim.
- Committed `run_battery.py` blob = `0db6f9229307efd7b7c815f2a76b6c5cdc023e4ce7f2eb8526446e6a6dc4fb4f`
  (agrees with the sibling verifier/reviewer).

---

## 2. Reproduction on the committed bytes

### 2.1 r97-only battery (frozen tree)

`run_battery.py --only r97_nodelat_*` → **8/8 PASS, verdict PASS,
`seeds_unchanged=true`**; all eight `PASS` lines are **byte-identical** to the
committed `CASES` markers (length-checked + first-diff-checked in Python;
0 diffs). Elapsed 1.16–8.30 s (20 s case bound). Deferred-pin census line:
`pf0=2 pf1=2`.

### 2.2 Full batteries (frozen tree)

- **Run 1**: **322/324**. Failures: `phys3d_joints_free_ops` (TIMEOUT after
  20 s — the documented r93-era 20 s knife-edge row) and `r95_bullet_shm`
  (`shm-step … d=10` vs the committed `d=8` — the documented r95 SHM d-count
  race the r95 critic filed as F1 MEDIUM). **All 8 r97 rows PASS**
  (1.13–8.40 s). `seeds_unchanged=true`.
- **Run 2**: **323/324**. Failure: `navagent3d_retarget` (`exit 1 != 0`) — the
  documented navagent one-tick load flake; the sibling r97-verifier's own full
  run failed on `navagent3d_retarget_fixed` (same class). **All 8 r97 rows
  PASS.** `seeds_unchanged=true`.

So the commit subject's "324/324 x2 green" did **not** reproduce verbatim in my
window (the host was heavier than in the author's window: load1 51–59 plus a
live 2D critic full battery and an r98 authoring lane); every failure is a
**pre-existing, documented, non-r97 flake**, and no r97 row reddened in any
context. This is a load-shaped environment observation, not a landing defect —
the sibling verifier and reviewer both recorded fully green full batteries in
their own windows.

### 2.3 Independent child runner (no fixture code involved)

`corpus/live/r97-critic/runner.py` builds its own per-cell projects
(`gp60`/`jolt60`/`dummy60`/`gp120`/`jolt120`), copies the committed probe to its
original `res://` name, spawns `timeout -s KILL 14 godot --headless [eargs]
--path … --script res://<probe>.gd -- <case> > child.log 2>&1` 8-way, captures
the real exit status, and recomputes each cell with an independently written
scanner + cell formatter.

- **3 reps × 8 arms = 237/237 cells byte-identical** to the committed markers
  (`cells=237 differing=0`).
- **10 further xr reps = 80/80 cells byte-identical**.
- Total **317 cell re-derivations, 0 differing**, including every `rsha`/`req`/
  `rdiff`/`feq` cross-cell comparison and every `ee`/`lk` count.
- xr rc census **{134: 4, 0: 4} in all 13 reps** — 52 crash children, **0
  escapes**; softfloor 13/13 pinned cells stable per rep; freegrain 4/4.

### 2.4 Flake hunt

Beyond the three battery runs and 13 arm reps: two targeted re-runs of the
error-spamming `soft drop_unidx@gp` cell (raw child logs **byte-identical** to
the fixture's own child log), 8 deferred-pin probe runs and 4 `--pins=now`
runs (§5.2), and 11 mutation runs (§4). **No r97 marker ever deviated.**

---

## 3. Evidence integrity — the cells are re-derived, not restated

### 3.1 Independent scanner

My scanner re-implements the normalization (banner/empty lines, the exact
2-line Jolt warning pair at any position, `Load address:` → `A`,
`[n] <hex> …` → `[n] F` with the frame count kept, `<Class#12345>` → `<Class#N>`,
ERROR-class detection with the per-cell allowlists, the ObjectDB-leak regex)
and the cell formatter from scratch. **317/317 cells match**, which is only
possible if the pinned fields, the `ee`/`lk`/`rsha` derivations and the crash
sha are all reproducible from the raw text.

### 3.2 The fixture's own scanner, run as a control

To rule out "same bug, two implementations", I ran the **fixture's own scanner
verbatim** (a scratch-only diagnostic copy of `r97_nodelat.gd:376–443`) over a
raw child log and diffed the normalized stream line-by-line against my Python
scanner under the **same allowlist** (empty): **identical — sha
`7baf898c16090e1e`, 55 kept lines, `ue` = the same 9 error heads on both
sides**. With the cell's own `gp_soft` allowlist, both implementations yield the
committed `drop_unidx@gp` sha `99b57992e2481b29` (64 kept lines, `ee=9`). The
error-spamming cell — the only one whose stream is order-sensitive — is
therefore pinned on the same bytes by both implementations.

### 3.3 Provenance: the pins are the scout's/boundary's receipts

Spot checks (normalized streams, both sides through my scanner):

| fixture cell | receipt | result |
|---|---|---|
| `bind@gp` | scout `nj_proj_bind.r1.stdout.txt` | identical (sha `dea5b2a8461d1d4f`) |
| `maxres@gp` | scout `q_proj_maxres.r1.stdout.txt` | identical (sha `2010048e9ea3bdcc`) |
| `margin_hi@gp` | scout `cb_proj_margin_hi.r1.stdout.txt` | identical (sha `765796008882b411`) |
| `drop@gp` | scout `vh_proj_drop.r1.stdout.txt` | identical (sha `425a7c4a250955a0`) |
| `cls@gp` | scout `cls_proj.r1.stdout.txt` | identical (71/71 normalized lines) |
| `collide_now@gp` | boundary `r97b_pinphase_pp_proj_collide_t01_now.r1` | identical **except** the declared setup-line extension (`pin=top`; physics rows equal) |
| `drop_t01@gp` | boundary `r97b_replay_sf_proj_drop_t01.r1` | identical **except** the declared extension (`pins=deferred pin=top`) |

The author's "10 setup-line extension" disclosure is accurate on the two
sampled cells: the difference is a receipt-shape artifact of the final probe
revision, never a physics claim.

### 3.4 Marker/key derivability (the one `labrat` probe)

The dispatched read-only probe checked all 79 cells' pinned keys against the
probe sources: **every `_field`-extracted key maps to a ` key=` token a probe
actually prints**, every extraction prefix can match a printed line, and **no
pinned value is empty**. It counted the ClassDB `CANDIDATES` list at **45**
(2+1+4+2+1+4+4+3+2+3+3+2+3+4+2+3+2). Its one caveat: the *identity* of the 5
non-instantiable classes is runtime-determined (static inference only) — my
runtime runs pin `noinst=5` and reproduce it.

---

## 4. Mutation probes — are the pins load-bearing?

All mutants live under `corpus/live/r97-critic/mut-*` (gitignored); the frozen
tree was never modified. Probe-side mutants are judged by my runner (cell text
vs committed marker); fixture-side mutants and the marker mutant are judged by
the real `run_battery.py` on the mutant fixtures dir.

| # | mutation | detector | result |
|---|---|---|---|
| M1 | softfloor top-pin index 0→4 | runner | **DETECTED** — `collide_now@gp/@jolt` change |
| M2 | drop `WorldBoundaryShape3D` from CANDIDATES | runner | **DETECTED** — `cls@gp/@jolt` change |
| M3 | crashiso keeps XRServer alive (no `free()`) | battery | **DETECTED** — row FAIL, `ue=Interface not found…` |
| M4 | free probe drops `queue_free()` | runner | **DETECTED** — all 4 freegrain cells change |
| M5 | njoint `badpath` → a valid path | runner | **DETECTED** — `nob@gp` `req=1`→0 + 2 cells |
| M6 | gp_soft allowlist head text | battery | **DETECTED** — row FAIL, `ue=Soft body's mesh needs to have indices` |
| M7 | `cls@gp` spec `rc` 134→0 | battery | **DETECTED** — row FAIL |
| M8 | id mask weakened (`#[0-9]{25,}`) | battery | **DETECTED** — row FAIL |
| M9 | `plat_ride@jolt` drops the `fl` field | runner | **DETECTED** — cell text loses `fl` (the boundary-correction pin is real) |
| M10 | one character of the committed xr marker (`classes=45`→44) | battery | **DETECTED** — row FAIL (the runner compares markers exactly) |
| M11 | `WARN2` text changed | battery ×4 + ×8 | **CONDITIONAL** — 0/4 then **2/8 runs had a warning child, and both failed**; the other 6 passed |

M11 is the honest coverage limit (F2): the Jolt job-system warning appears in
the `ffps60` Jolt freegrain child only in ~1/3 of runs (observed: 2/3 in one
sweep, 1/4 battery runs, 2/8 in the mutant loop). When it appears, the
normalization is what keeps the cell byte-identical to the committed marker
(rep0/rep1 had the warning, rep2 did not, **all three cells identical**) — the
tolerance is real and load-bearing; a WARN2-text mutant is simply not
detectable in runs where the warning never fires.

---

## 5. The three named risks, measured

### 5.1 xr pins the degenerate rc=134 distribution

The fixture pins `rc=134` **strictly** for `cls@gp/@jolt` and `iso_xrs@gp/@jolt`
(`_cell_ok` rc equality) while the row comment phrases it as an envelope. My
runs: **52 crash children in 13 independent reps, 4/4 rc=134 every rep**, plus
12 crash children across the three battery runs — **64/64 rc=134, 0 escapes, 0
rc=0, 0 rc=137**, on a host at load 51–59. The boundary measured 66/66. The pin
is therefore a **degenerate-distribution pin** and is **fail-closed**: a future
engine build that exits 0 (no crash) or via the raw signal (139) fails the row
loudly rather than silently. Residual risk stays as the r90 lesson: this is a
teardown-ordering destructor class; the envelope wording in the comment is the
right hedge, and the strict pin is the conservative one.

### 5.2 softfloor two-valued census

Independent probe runs of `r97b_softfloor.gd --case=collide --thick=0.1`
(deferred pins, 8 reps): **pf=0 ×3** → `v4=0.0001,2.92696,0.00145
ball=-0.0137,0.24,-0.01219`; **pf=1 ×5** → `v4=0.00123,2.90701,-0.00033
ball=-0.02728,0.24,-0.01644`. Exactly **two value sets, both internally
deterministic, rc=0** — the declared startup race, reproduced. `--pins=now`
(4/4): pf=0, the same values the fixture pins (`collide_now@gp{…v4=0.0001,
2.92696,0.00145,ball=-0.0137,0.24,-0.01219}`). The battery's census line varies
across my runs (**pf0/pf1 = 2/2, 1/3, 1/3**) and **never affects the row** — the
two-valued branch is censused, never pinned, exactly as declared.

### 5.3 ClassDB census 44 → 45

Static: `r97_probe_classdb.gd` `CANDIDATES` has **45** entries. Runtime: the
pinned `cls` cells read `classes=45,noinst=5` on GP and Jolt, reproduced by my
runner. `CLEAN_SET` has **39** entries = the 40 instantiable candidates minus
`XRServer` (the one `iso_xrs` exercises separately) — so the author's "other 39
instantiable classes exit clean" is exact. The author's correction #2 is
accurate; the **fixture header line 71 still says "all 44"** (F1).

---

## 6. Findings

**F1 (LOW — comment accuracy; convergent with r97-verifier LOW-1, r97-reviewer
F1, r97-simplifier F-1).** `corpus/fixtures/r97_nodelat.gd:71` reads "all 44
classes exist" while the pinned census and the code are 45. Value surface
correct; the law comment is stale.

**F2 (NOTE — conditional coverage + dead counter; convergent with verifier
LOW-3, simplifier F-2).** The 2-line Jolt-warning normalization is exercised
only when the warning appears (~1/3 of runs; §4.M11), and the `w` counter it
increments is not surfaced in any cell or `#` note, so a row cannot report
"the warning was seen". Not a defect — the tolerance is defensive and provably
works when needed — but the r97 analogue of the r96 F1 drop-blindness class:
this normalization cannot be mutation-tested deterministically.

**F3 (NOTE — fail-open diagnostic path, mine).** The deferred-pin **census**
children are not fail-closed: `_run_softfloor` reads only `pf` from each census
child (`if pf == "0" … elif pf == "1" … else ok = false`), so a census child
that crashes (rc≠0) or emits an unexpected ERROR still contributes to the
`pf0/pf1` line as long as it printed a `pf=` field. Impact is bounded — census
children enter no pinned cell and their values are never asserted — but the
`#` diagnostic could in principle read "pf0=4" from children that also failed.
A cheap fold: apply `_cell_ok(res, {"rc": 0})` and `ue` emptiness to census
children too.

**F4 (NOTE — methodology hazard, mine).** Cell `sha`s are computed over the
**shell-merged stdout+stderr stream** (`… > child.log 2>&1`), so reproduction
requires the same merge shape: my first independent pass captured the two fds
separately and re-ordered the error lines, which produced 5 spurious cell diffs
(soft `drop_unidx@gp` sha + 4 xr `rc=-6` vs `134`) while the physics fields and
the raw file contents were identical. Two traps for future seats: (a) spawn
children through the same `> log 2>&1` shape or the error-interleaved cells
cannot match; (b) `subprocess` reports SIGABRT as **−6** where the fixture /
shell report **134** (128+6) — normalize before comparing rc.

**F5 (INFO — dead config; convergent with verifier LOW-4-class notes /
simplifier F-2).** The `SUM_PREFIX`/`f` sum-line extraction machinery exists in
the fixture but no committed cell spec uses `f` — dead configuration.

---

## 7. Hygiene, writes, cleanup

- **Zero tracked writes by this seat.** `git status --short` shows only the
  sibling r98 lane's `run_battery.py` modification (+41, r98 rows), its new
  `r98_*` files, the two pre-existing untracked r94/r95 reviewer reports, and
  (after this seat) this report. The 11 `corpus/fixtures/r97_*` blobs and
  `reports/round-97/r97-author.md` are byte-identical to `ec27b78`.
- Scratch is confined to `corpus/live/r97-critic/**` (85 MB; gitignored via
  `corpus/.gitignore: live/`): `frozen/` (the `git archive` tree),
  `battery-{r97only-1,full-1,full-2}/`, `runner.py`, `scanner.py`, `mutate.py`,
  `extra.py`, `mut-*/`, `work/`, logs. One runaway mutant run dir (the M11
  loop, whose battery run dirs nested copies of themselves — a harness bug of
  this seat, 204 GB at peak) was killed and **deleted**; the `mutate.py` fix
  (run dirs outside the fixture dir, minimal mutant dirs) is in the receipts.
  Disk is back to 143 GB used / 780 GB free.
- **No orphan processes**: no `r97-critic` Godot, driver or mutation process is
  alive at filing; all children were `timeout -s KILL 14` bounded inside the
  fixture and every one of my own runs used the same bound.
- Other lanes' processes (2D r94/r95 critics, r96/r98 lanes, `r99-boundary`)
  were observed and left untouched.

---

## 8. Remaining risks / verification gaps

1. **Full-battery greenness is load-shaped.** I could not reproduce a fully
   green 324-case run in my window (322/324, 323/324); the failing rows
   (`phys3d_joints_free_ops`, `r95_bullet_shm`, `navagent3d_retarget`) are
   pre-existing documented flakes outside r97 and pass/redden independently of
   this landing. No r97 row flaked anywhere.
2. **F2's conditional coverage** — the WARN normalization cannot be
   mutation-tested in runs where the warning does not fire; its `w` counter is
   invisible in the markers.
3. **F3's fail-open census path** — diagnostics only, no pinned claim.
4. **xr rc=134** is a strict pin over a degenerate destructor distribution
   (§5.1). Fail-closed, but any future engine change that alters the crash path
   will redden the row rather than adapt.
5. The `softfloor` `drop_t04@gp` sideways-ejection value and the vehicle
   chaotic-tail `rdiff=1` divergence witness are pinned snapshots; they were
   rep-stable in 13+ executions under load, but they are exactly the kind of
   cell that should be re-measured if the engine or the rig changes.

---

## 9. Receipts and repro

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# frozen committed tree
mkdir -p corpus/live/r97-critic/frozen && git archive ec27b78 | tar -x -C corpus/live/r97-critic/frozen
# r97-only battery, then two full batteries (frozen tree)
python3 corpus/live/r97-critic/frozen/corpus/fixtures/run_battery.py \
    --runs $PWD/corpus/live/r97-critic/battery-r97only-1 --only r97_nodelat_joint,r97_nodelat_soft,r97_nodelat_dss,r97_nodelat_cb,r97_nodelat_vehicle,r97_nodelat_softfloor,r97_nodelat_xr,r97_nodelat_freegrain
python3 corpus/live/r97-critic/frozen/corpus/fixtures/run_battery.py --runs $PWD/corpus/live/r97-critic/battery-full-1
python3 corpus/live/r97-critic/frozen/corpus/fixtures/run_battery.py --runs $PWD/corpus/live/r97-critic/battery-full-2
# independent child runner (3 reps all arms; 10 reps xr)
python3 corpus/live/r97-critic/runner.py --reps 3 --work corpus/live/r97-critic/work/rep3
python3 corpus/live/r97-critic/runner.py --arm xr --reps 10 --work corpus/live/r97-critic/work/xr10
# mutation suite + extra probes (census / WARN2 loop)
python3 -u corpus/live/r97-critic/mutate.py
python3 -u corpus/live/r97-critic/extra.py
```

Receipts (all gitignored, under `corpus/live/r97-critic/`): `env.txt`,
`battery-r97only-1/`, `battery-full-1/`, `battery-full-2/` (+ `.log`),
`runner-rep3.log`, `mutations.log`, `mut-*/`, `work/` (per-child `child.log`
and `project.godot` for every rep), `dump-fixture.txt` / `dump-python.txt` (the
scanner control), `census-proj/`, `scanner.py`, `runner.py`, `mutate.py`,
`extra.py`, `dump.gd`.

Provenance: this seat wrote only `corpus/live/r97-critic/**` (gitignored
scratch) and this report. No fixture, runner, probe, contract, axis, or route
was touched; no commit was made.
