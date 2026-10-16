# r100 scribe — custody audit of author capstone `8183191`

Seat: `scribe` (UFO-FSD, devin substrate). Scope: audit the landing commit
`8183191f789acca8f3f0292392a1ee84fe317a50` (`r100 author:
fixed-fps/quit-after/render-target/Area3D lattice (8 rows/142 cells, +39/-0)`)
against (a) the claims in `reports/round-100/r100-author.md`, (b) the raw
receipts in `corpus/live/r100-author/`, and (c) the committed diff itself.
This seat re-ran nothing; every number below is read from artifacts on disk or
from the git object store.

**Status: PASSES-WF (with findings).** The load-bearing claims — pins
byte-equal to live receipts, insertion-only +39/-0, probe byte-identity,
green-run totals — all hold. Six findings (F1–F6: four claim/receipt
discrepancies, one provenance-precision note, one custody gap) and four
author-attested items (A1–A4) are recorded below; none is a fabrication
signal, all are bookkeeping drift on top of verified bytes. Nothing was
committed, edited, or re-derived by this seat.

---

## 0. Method (exact commands, all read-only)

```
git show --stat 8183191;  git show 8183191 --numstat
git diff --stat HEAD -- corpus/fixtures/r100_fpslat.gd corpus/fixtures/run_battery.py reports/round-100/r100-author.md   # empty = disk == HEAD
sha256sum corpus/fixtures/r100_fpslat.gd; git show HEAD:corpus/fixtures/r100_fpslat.gd | sha256sum
for f in area cls life modes rt sched; do cmp corpus/fixtures/r100_probe_r100b_$f.gd corpus/live/r100-boundary/probes/r100b_$f.gd; done
for f in area cls life rt sched; do cmp corpus/live/r100-scout/probes/rs_$f.gd corpus/live/r100-boundary/probes/r100b_$f.gd; done
python3  # json.load each runs/<id>/verdicts.json: totals, per-case verdicts, seed_digests, markers
python3  # import corpus/fixtures/run_battery.py; assert marker == pinned string per r100 row, per run
python3  # brace-depth cell counter over each committed pin line
grep -rhoE 'PASS\s+phys3d_events_script_size_gate' corpus/live/**/*.log | wc -l   # + FAIL census, recursive-glob Python variant
cmp a_/b_/c_/d_ arm logs pairwise; diff a_modes vs b_modes; diff a_qa vs c_qa
wc -l corpus/fixtures/r100_fpslat.gd  corpus/live/r100-author/runs/20261016T084518250447Z/scratch/r100_fpslat.gd
```

## 1. Committed diff vs report claims

| claim (r100-author.md) | committed diff / disk | verdict |
|---|---|---|
| "8 new battery rows … insertion-only, +39 lines, zero deletions" (§1) | `--numstat`: `run_battery.py 39/0`; 8 `r100_fpslat_*` tuples inserted in one block after the r99 rows | **HOLDS** |
| "new file `corpus/fixtures/r100_fpslat.gd`" (§1) | `892/0`, new file | HOLDS (new) |
| report itself lands in the commit | `reports/round-100/r100-author.md 133/0` | HOLDS |
| "879 lines, new file" for the fixture (§1) | committed blob = **892** lines; run-A scratch copy = **889**; derive-scratch copy = 892 | **MISMATCH** (F1) |
| "Nothing staged or committed by this seat" (§6) | commit exists, author/committer `game-dev-3d-shokunin <game-dev-3d@shokunin.local>`, 2026-10-16 07:00:41 -0300, 23 s after report mtime 07:00:18 | consistent (landed by another seat/operator, not the author seat) |
| working-tree disclosure (§6) | tracked files clean (`git diff HEAD` empty); untracked = the six `r100_probe_r100b_*.gd` seeds + 3 foreign `reports/frontier/*.md` (not this lane) | HOLDS |

Committed digests (verified equal on disk and in `HEAD`):

- `corpus/fixtures/r100_fpslat.gd` = `da11495de7a24703a911bb1c8fef15ba62481e5f492bda1efd56fc3b1950b537`
- `corpus/fixtures/run_battery.py` = `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`
- `reports/round-100/r100-author.md` = `881aa7f7077286b3d7f1800b40d3769f05c2ced89783545b9e90c218dd971b3a`

Cell arithmetic: brace-depth parse of the 8 committed pin lines gives
21+13+22+34+11+8+24+9 = **142 cells**, matching §1's table and the commit
message. Row names and cell labels match the report's per-row tables.

## 2. Fixture provenance

- **`r100_fpslat.gd` is new and self-contained**; the parent copies
  `res://r100_probe_<arm>.gd` → `<child>/r100b_<arm>.gd` byte-for-byte
  (`store_buffer`, fixture L795-800) and runs each child under
  `timeout -s KILL <bound>` (`BOUND_S := 15`, life unbound `bound=5`).
  Sampled child copy `scratch/r100t702024_sched_ffps60_gp/r100b_sched.gd`
  is `cmp`-identical to the seed. "Modeled on `r99_animtree.gd`" is
  structurally true (same child-project convention, header comment style).
- **Six probes, byte-identity chain (all `cmp`, sha256 confirmed):**

  | probe | scout `corpus/live/r100-scout/probes/` | boundary `corpus/live/r100-boundary/probes/` | seed `corpus/fixtures/` | sha256 (16) |
  |---|---|---|---|---|
  | area | `rs_area.gd` ✔ | `r100b_area.gd` ✔ | `r100_probe_r100b_area.gd` ✔ | `a577d6265f78f1ff` |
  | cls | `rs_cls.gd` ✔ | `r100b_cls.gd` ✔ | ✔ | `0adf98aadd38cdc6` |
  | life | `rs_life.gd` ✔ | `r100b_life.gd` ✔ | ✔ | `427fc7d159f524da` |
  | rt | `rs_rt.gd` ✔ | `r100b_rt.gd` ✔ | ✔ | `8bfd76adf5ae5551` |
  | sched | `rs_sched.gd` ✔ | `r100b_sched.gd` ✔ | ✔ | `c61025594deff49d` |
  | modes | — (boundary-new) | `r100b_modes.gd` | ✔ | `249c0caf8ac4a1d5` |

  The boundary lane's own manifest records the same digests, and its report
  says verbatim: *"`probes/` (5 byte-identical copies of the scout's probes +
  `r100b_modes.gd`)"*. So the author's chain line *"provenance chain: scout
  probe → boundary probe → battery seed"* (§2) is accurate for 5/6 seeds;
  `r100b_modes.gd` originates at the boundary lane (**F4**, precision only).
- Seed digests recorded inside every battery run (`verdicts.json →
  seed_digests`) equal the on-disk seeds for all six probes in all 7 full /
  targeted runs — the probes were not mutated between runs.
- **Boundary-survival decisions** (§2) are checkable against the pins and
  hold: scout formula `n_pr = 120·N/60 + 1` absent from the pins (boundary
  report: *"FALSIFIED (arithmetic) — the interleave is exact, the formula is
  not"*); `writemovie{rc=134,…,ee=1}` truncates at the fixture's declared
  `done: "   at: texture_2d_get"` line; `cap1_ffps1/cap8_ffps1 steps_max=60`,
  `cap1_ffps5/cap8_ffps5 steps_max=12` (cap bounds nothing below the physics
  budget); unbound life cells carry no `beq` and no `sha`.

## 3. Pins vs receipts

- **Pins are byte-equal to live receipts.** For all 8 rows, the marker text
  in the two green runs (`20261016T092110927416Z`, `20261016T094820350875Z`)
  is *exactly* the committed pin string (Python `==`, lengths equal per row).
  That is the observable part of §1's "every signature re-derived live on the
  final bytes".
- **Byte stability across runs B..GREEN2**: `seed_digests['r100_fpslat.gd']`
  = `da11495d…` and `seed_digests['run_battery.py']` = `f456bd00…` in
  `085634`, `090917`, `092110`, `093648`, `094820` — both equal the committed
  files. The pre-fix run A carries `1ff5988e…` (fixture) and `c131792d…`
  (battery), i.e. the re-pin is real and happened between A and B.
- **Arm-level derive logs vs final pin** (`corpus/live/r100-author/*.log`):

  | arm | logs matching final pin | note |
  |---|---|---|
  | sched | `a_sched.log`, `c_sched.log` | ≥2× |
  | compose | `a_compose.log`, `c_compose.log` | ≥2× |
  | rt | `a_rt.log`, `c_rt.log` | ≥2× |
  | area | `a_area.log`, `b_area.log` | ≥2× |
  | cls | `a_cls.log`, `c_cls_out.log` | ≥2× |
  | life | `d_life1.log`, `d_life2.log` (byte-identical to each other) | post-fix pair; `a_life`/`b_life` are the pre-fix 1153-char variant |
  | modes | `a_modes.log`, `b_modes.log` | aggregate PASS line identical; `a_modes.log` carries 2 parent-side `hashing_context.cpp:54` ERROR blocks (20 lines) that `b_modes.log` lacks — see F2 |
  | qa | **`c_qa.log` only** | `a_qa.log` is a stale revision: `quit0_t20k` (20 000 ticks) vs pin `quit0_t4k` (4 000); lengths 1299 vs 1291 — see F3 |

- The racy-beq narrative (§2/§4) is fully supported: run A's observed
  `r100_fpslat_life` marker carries `noquit_unbound@jolt{…,beq=0}` and
  `noquit_unbound@dummy{…,beq=0}` (env-cell hashes raced), the pre-A fixture
  emitted `beq` for env cells, and the only fixture delta between run A and
  the final bytes is the 1-line→4-line guard
  `… and env.is_empty():` (+3 lines, `diff scratch/r100_fpslat.gd
  corpus/fixtures/r100_fpslat.gd`). The re-pin is evidenced by the
  `run_battery.py` digest change A→B; the pre-A pin text itself is **not
  recoverable** (no copy of the pre-A `run_battery.py` exists under
  `corpus/live/r100-author/runs/`).

## 4. Run totals and flake disclosures (receipts)

| run dir | totals | r100 rows | fails |
|---|---|---|---|
| `…T084437209936Z` (targeted, `only`=8 rows) | 8/8 PASS | 8/8 | — |
| `…T084518250447Z` (A) | 348/350 FAIL | 7/8 | `phys3d_events_script_size_gate`, `r100_fpslat_life` (pre-fix) |
| `…T085634619080Z` (B) | 340/350 FAIL | 8/8 | 10× `bpy_rbw3d_*` (`TIMEOUT after 20 seconds`) |
| `…T090917786684Z` (C) | 340/350 FAIL | 8/8 | 10× `bpy_rbw3d_*` (same) |
| `…T092110927416Z` (GREEN 1) | 350/350 PASS | 8/8 | — |
| `…T093648988569Z` (run 5) | 349/350 FAIL | 8/8 | `phys3d_events_freed_space_methods` |
| `…T094820350875Z` (GREEN 2) | 350/350 PASS | 8/8 | — |

- Every number above matches §4's prose. The `bpy_rbw3d_*` timeouts show
  `exit=None, 'TIMEOUT after 20 seconds'` in the receipts; the *cause*
  ("48 foreign `yes` hogs on 32 cores from sibling lanes") is
  author-attested only — no load artifact exists in the audited tree (A2).
- Flake classes are documented in the artifacts as claimed:
  `phys3d_events_script_size_gate` has a long precedent history —
  census over `corpus/live/**/*.log`: **103 logs carry PASS summary lines
  (207 lines), 20 logs carry FAIL lines (39 lines)**, spanning r89/r93/r94/
  r95/r96/r98/r99 seats plus `r100-author/full_run1.log` (the r93/r100
  variant is the identical `min_thr drift` diagnostic).
  `phys3d_events_freed_space_methods` expected marker is
  `jolt=crash-or-dead@post_fetch` (run_battery.py L494) and run 5's failure
  detail is exactly that envelope (`crash=1 abort=0`, `slot >= slot_max`).
- **Unreferenced artifact**: `runs/20261016T093136961416Z/` contains
  `scratch/` only (mtime 06:31-06:34 local) — no `verdicts.json`, 0 `r100t*`
  child dirs, 112 pre-r100 entries. It is an aborted run that reached no
  r100 case and is not listed in the report (F6, custody note; it cannot
  have contributed evidence either way).

## 5. Findings — conflicts and gaps, verbatim for the canonical judge

- **F1 (claim vs artifact).** Author §1: *"corpus/fixtures/r100_fpslat.gd
  (879 lines, new file)"*. Measured: committed blob and disk = **892 lines**
  (`wc -l`; `git show HEAD:… | wc -l`); run-A scratch revision = **889**
  lines; the only post-A delta is +3 lines. `879` matches no reconstructable
  revision. No functional claim depends on it.
- **F2 (claim vs receipt).** Author §4: *"each arm run ≥2× with
  byte-identical aggregate output (modes, area, life, sched, qa, compose, rt,
  cls — `c_*.log`/`b_*.log`/`d_life*.log` …)"*. For **modes** the aggregate
  PASS line is identical (verified), but `a_modes.log` additionally contains
  2 parent-process ERROR blocks (`Condition "len == 0" is true … 
  core/crypto/hashing_context.cpp:54`, `_sha16` backtrace) absent from
  `b_modes.log`; the final fixture guards empty buffers (comment cites
  `e3b0c44298fc1c14`). The pair is *not* byte-identical as files, and this
  parent-side class is not in §3's flake list.
- **F3 (claim vs receipt).** Same §4 sentence for **qa**: the only two
  arm-level qa logs on file differ (`a_qa.log` len 1299 with
  `quit0_t20k{…n_pr=20000,n_ph=20000…}` vs `c_qa.log` len 1291 with
  `quit0_t4k{…n_pr=4000…}` = the final pin). Only `c_qa.log` matches the
  final pin, so the "≥2×" arm-run claim is evidenced for 7/8 arms, not 8/8.
  The qa pin itself is nonetheless live-observed: the 5 post-fix full-battery
  runs each compare the qa marker to the pin and pass.
- **F4 (precision).** Author §2: *"The six probe seeds … provenance chain:
  scout probe → boundary probe → battery seed."* Boundary report: *"`probes/`
  (5 byte-identical copies of the scout's probes + `r100b_modes.gd`)"* —
  `r100b_modes.gd` is boundary-originated, not scout. Five of six seeds
  follow the stated chain; all six are byte-identical to the boundary corpus.
- **F5 (count wording).** Author §4: *"All 8 r100 rows went green in 5/5
  full runs"*. Six full-battery runs are on file (A, B, C, run 5, GREEN 1,
  GREEN 2). Run A is 7/8 (life, pre-fix). The sentence is exact only under
  the post-fix reading (B/C/5/G1/G2 = 5 runs, 8/8 each); as written it
  undercounts the run inventory by one.
- **F6 (unreferenced run dir).** `runs/20261016T093136961416Z/` — scratch
  only, no verdicts.json, zero r100 children; not disclosed anywhere in the
  report. No evidence value; recorded for completeness.

## 6. Author-attested, not evidenced in the audited artifacts

- A1: "no pin was authored from scout or boundary text" — method attestation;
  the observable consequence (pins byte-equal to live receipts on final
  bytes) holds.
- A2: the ambient-contention load figure behind the `bpy_rbw3d_*` timeouts
  (see §4).
- A3: "That fix is the only post-run-A change" — verified for the *fixture*
  (single 3-line guard, `diff` above); for `run_battery.py` only the digest
  change A→B is observable (re-pin), its exact text delta is unrecoverable.
- A4: the child `timeout -s KILL` bounds and scanner properties were
  code-inspected in the final fixture (ERR_ALLOW `wm/lerr/lfin/arerr/leak`,
  Jolt WARN1/WARN2 allowlist, ObjectDB-leak regex, `handle_crash` rejection,
  `mk=0` fail-loud, `eq`/`beq` = sha equality, env `beq` suppression) — all
  as §2/§3 describe.

## 7. Out of scope / not audited

- The contract files named in the header (`g3d-r100-authorfinish.md`,
  `g3d-r100-author.md`) are not present under this repo; the "finish seat"
  binding is not auditable from repo artifacts.
- The boundary/scout corpora were used only for byte-identity comparisons
  and verbatim cross-quotes; their own claims are other seats' custody.
- No cell was re-derived, no test re-run, no code touched. `reports/frontier/
  *.md` untracked files are foreign to this lane.

## 8. Artifact paths

- Commit: `8183191f789acca8f3f0292392a1ee84fe317a50`
- Report audited: `reports/round-100/r100-author.md`
- Fixture: `corpus/fixtures/r100_fpslat.gd` (892 lines, `da11495d…`)
- Battery: `corpus/fixtures/run_battery.py` (`f456bd00…`, r100 block L877-916)
- Seeds: `corpus/fixtures/r100_probe_r100b_{area,cls,life,modes,rt,sched}.gd`
- Receipts: `corpus/live/r100-author/runs/<7 run dirs>/verdicts.json`,
  `full_run1..6.log`, `a_*/b_*/c_*/d_*` arm logs, `derive-scratch/`
- This audit: `reports/round-100/r100-scribe.md` (not committed)
