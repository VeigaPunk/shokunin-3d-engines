# r95 verifier — wave-B gate on committed `0767b59`

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 95. Assigned
tree: `0767b5900f38949b6e077b0ab8317480f66166f8` ("r95 author: 20 bullet/pybullet
rows (304 total) — vendored .so byte-pinned, DIRECT-scoped purity + SHM
pump-live class, order non-neutrality; 304/304 x2"). Author report:
`reports/round-95/r95-author.md`; boundary: `r95-boundary.md`; scribe (landed
mid-seat, see Byte custody): `a042e49`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(`--headless` before `--script`), `/usr/bin/python3` `3.14.7`, 32-thread host.
**No `lsp` device is exposed to this seat's toolset** (same recorded absence
as r85–r94 lanes); no source edits were made, so the hand-edit fallback was
never in play. This seat wrote only `corpus/live/r95-verifier/**` (gitignored
via `corpus/.gitignore: live/`) and this report. No commits, no tracked
writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `0767b59`, `git status --porcelain`
  carried only the sibling's untracked `reports/round-94/r94-reviewer.md`.
  sha256 of `r95_bullet.gd` (`f988ba86…`), `r95_child.py` (`8821ebd5…`),
  `run_battery.py` (`0b9b7035…`), `r95vendor/pybullet.cpython-314-…so`
  (`eca749a0…`) all byte-match the committed blobs, re-verified identical at
  filing after every run below.
- **Vendored `.so` provenance proven by reproduction, not claim:** a copy of
  the scout's venv artifact `c035ebaf…` + `strip --strip-debug` yields
  **byte-identical** `eca749a0…` = the committed vendor file
  (`vendor-check/{orig,stripped}.so`). 91,047,408 → 7,063,864 B. The `.so` is
  inside `seed_digests()` both directions (`seeds_unchanged=true` in both my
  battery runs).
- **Mid-seat movement (documented, contained):** `a042e49` (r95 scribe,
  21:03) landed during the seat — `git diff 0767b59 a042e49 -- corpus/` is
  **empty**, report-only. Separately, a sibling r96-author seat is mid-flight
  in the *worktree*: `corpus/fixtures/run_battery.py` gained an uncommitted
  r96 append (+30 lines of `r96_joltdet_*` rows after
  `r95_bullet_neg_shm_rt`) and nine untracked `r96_probe_*.gd`/`r96_joltdet.gd`
  fixtures appeared ~21:0x. **Not touched by this seat**; both my verdicts
  record `run_battery.py` digest `0b9b7035…` = the `0767b59` bytes in their
  `seed_digests` maps, and all three r95 files re-verify byte-identical to
  the commit at filing — every measurement below ran on assigned-tree bytes.
- **Host context:** the corpus's normal multi-seat box; loadavg ranged
  ~50–127 across the seat, with an r95-critic mutation battery and sibling
  probes running concurrently during my sweeps — real ambient load, not
  simulated.

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | CASES diff insertion-only, +20 rows, 304 total | **PASS** — AST `literal_eval` on committed blobs: 284→304, strict-prefix tail insert of the 20 `r95_bullet_*` tuples after `r94_cannon_neg_grid`; `new[:284] == old` tuple-equal; removed=0, changed=0, dup-names=0; `expected_exit` ∈ {0,2}, script `r95_bullet.gd` on all 20; 46 `{rc=…}` cells + 6 negatives = 52 |
| 2 | Parent↔child dispatch completeness | **PASS** — parent's `ARM_CASES` (14 arms) + `NEGATIVE` (6) enumerate exactly the child's `CASES` dict, 52↔52 both directions, zero undispatched/unknown either way |
| 3 | All 20 r95 rows pass on committed bytes, under load | **PASS** — `--only` battery at loadavg ~80: **20/20 PASS**, `seeds_unchanged=true`, parent stderr 0 lines, elapsed 0.6–4.3 s (bound 20 s); full battery (§2): **20/20 r95 PASS** |
| 4 | Rep-stability: digest surface deterministic | **PASS with documented-class drift** — 4 reps × 20 arms standalone: **78/80 marker-exact + clean stderr**; both misses are `shm` `d`-count drift (`shm_step d=8→10`), the author's first documented flake class (§4). Child level: **208 execs, M-surfaces byte-identical per case across both .so builds and both reps, o=0 everywhere, rc correct (184×0 + 24×2)** |
| 5 | Wall-clock / transport-dependent surface confined | **PASS** — the only non-reproducible surface (SHM `rt=1` stepped hashes) is authored as `#`-only diagnostics; measured live: 24 stepped windows → 11 on-pin `02309c…` + 13 divergent across 7 distinct hashes, never on an M-line. `fell=True` held 12/12 dedicated + all arm runs; `froze=True` DIRECT control held in every `neg_shm_rt` |
| 6 | Full battery 304 rows on final bytes | **PASS** — **304/304**, `seeds_unchanged=true`, Σ458.3 s, max 15.63 s; zero FAILs including the historically flaky `navagent3d_retarget*` F1 rows and `phys3d_joints_free_ops` |
| 7 | Fixture hygiene / red flags | **PASS** — bounded machinery (`timeout -s KILL 15` per child, `BOUND_S=15`, battery `CASE_TIMEOUT_SECONDS=20`); child case names come only from `ARM_CASES`/`NEGATIVE` constants; children write only `child.log` under `res://r95ch_<case>` of the scratch project; child itself has zero fs/net/subprocess (`tempfile.TemporaryFile` only, unnamed); `o` counts every non-M/non-`#` line (any warning/traceback fails the cell); negatives require rc=2 **and** exactly one `NEGATIVE REJECTED:` **and** `o=0` after a live control |

## 1. Marker surface — corrections verified in the pins

All five boundary corrections named in the task are encoded in the committed
markers, and each was re-executed live:

- **DIRECT-scoped purity:** `rt_inert` pins `rt0:h=02309c…,flag=0 /
  rt1:h=02309c…,flag=1 eq=True` (flag readback pinned separately from the
  hash); `rt_idle` pins `z=5` through a 0.6 s idle + 120 API calls;
  `rt_paced` pins the canon hash under paced stepping.
- **SHM rt=1 pump-live class:** `shm_rtclass` pins `rtflag=1 idle2.0s
  fell=True` — the *class*, never the distance (measured `z1` is `#`-only;
  live `#` line showed `z0=5 z1=0.49999`). `neg_shm_rt` rejects via the
  froze/fell contrast, not the load-dependent stepped divergence.
- **Order non-neutrality:** `det_order` pins `h_forward=02309c52da41ef33
  h_reverse=76988acc55682c1a eq=False`; `neg_order` rejects the cannon-style
  neutrality claim; `pile_lattice` adds `rev=38cb12317d6644da`.
- **1-ulp friction:** `fr_bitexact` pins `prod0808=3fe47ae147ae147c` vs
  `prod064=3fe47ae147ae147b` `ulpEq=False` plus per-pair hashes
  (`54d2f4…`≠`3e79f2…`) while commutatives stay bit-exact (`g0.64/b1.0 ≡
  g1.0/b0.64`).
- **EMPTY-sleep calibration:** `sl_force_max` pins `an=EMPTY` at all six
  checkpoints; `sl_rest_max`/`sl_iters` pin the `i0/n1/it2`+`cc=1` never-
  sleeps lattice on both body representations.

Value provenance cross-checked: every pinned hash I spot-checked
(`02309c…`, `76988a…`, `daf67b…`, `a272ef…`, `38cb12…`, `99d3fd…`, `8606ea…`,
`71248c…`, `7e12786…`, `b7fd8f…`, `d3a2bd…`, `0282277…`, `4a1d38…`,
`3fe47ae147ae147b/c`, `freezeStep=80`, `changes=79`) appears **verbatim** in
the scout's pinned `rep1.out` files or the boundary's logs. The child's
`bits`/`state_hash`/`scene` are character-identical to the scout's
`probes.py` witness plumbing, so scout hashes and child hashes are directly
comparable.

## 2. Batteries executed (all on `0767b59` bytes)

| run | context | totals | receipts |
|---|---|---|---|
| `--only` 20 r95 rows, `runs/20261015T233335584967Z` | loadavg ~80 | **20/20 PASS**, `seeds_unchanged=true` | verdicts `a6b5450d…` |
| full, `runs/20261015T233746409111Z` | loadavg ~50–85, sibling batteries | **304/304 PASS**, `seeds_unchanged=true`, Σ458.3 s | verdicts `bf29ffad…` |
| arm rep sweep, `reps/` | 4 reps × 20 arms, concurrent with my own child sweep | 78/80 marker-exact; 2 `shm` `d`-drifts | `reps/rc.txt`, per-arm `.out`/`.err`, archived child logs |
| child dual-build sweep, `childreps/` | 52 cases × {strip,orig} × 2 reps = 208 execs | 52/52 M-surfaces byte-identical across builds & reps; rc 184×0 + 24×2; `o=0` all | `childreps/rc.txt`, per-case logs |
| SHM focus probe, `flips/` | 20×`shm_step` + 12×`shm_rtclass` on vendored .so | 0 `d`-drift; `fell=True` 12/12; stepped-hash race 11/24 on-pin | `flips/*.log` |

Total r95-surface executions this seat: 80 arm runs + 208 + 32 child execs +
104 battery-child execs ≈ **424 child processes**, plus both batteries'
guard surfaces.

## 3. Output-equivalence of the two `.so` artifacts (independent check)

The author claims contract-equivalence between the stripped vendored build
and the scout's unstripped build. This seat re-measured it: all 52 cases run
against **both** artifacts; the M/`NEGATIVE` surface is **byte-identical in
every case** (208 execs, zero M-line differences). The only cross-build
difference observed is inside the `#` channel (`shm_rtclass` counted `d=42`
once on the unstripped build vs `44` on the pinned build — §4 class).

## 4. The measured flake class — SHM `#`-diagnostic count drift

The author's first documented flake class is **real and was caught live in
this seat's verify window**:

- `shm_step` pinned `d=8`: arm-level drift to `d=10` in **2/6** arm runs
  (reps r2, r4 — during concurrent sweeps; clean in battery ×2 and the
  20-exec dedicated probe).
- `shm_rtclass` pinned `d=44`: `d=42` in **1/4** unstripped-build child execs;
  0/14 on the pinned build.
- `neg_shm_rt` `d` varies {9,11} — **unpinned by construction** for negative
  rows (only rc=2 + the reject line + `o=0` gate); harmless.

Mechanism (from archived `child.log` diffs): the SHM pump thread's
`PosixSharedMemory::releaseSharedMemory …` / `MotionThreadFunc` prints
interleave and concatenate differently under scheduling pressure — the r2
log carries two extra `#`-lines vs r1 with the same print set. This is a
line-count race on the diagnostic channel, exactly the disclosed class; the
M-surface is untouched in every observation (0 M-drifts anywhere).

**Disposition:** by design a drift reddens `r95_bullet_shm` — a legitimate
signal, per the author. Measured row-level flake rate is load-conditional:
~2/6 arm runs under concurrent-sweep load (~85–100), 0/36 in child-level and
battery contexts at ~50–85. The judge should treat `r95_bullet_shm` as the
battery's one residual flake candidate; all other 19 r95 rows were
flake-free in 424 executions.

**Labrat probe (the seat's one permitted depth-2 dispatch):** hypothesis
"the fatal `o`-surface cannot be polluted by engine output" — **CONFIRMED**,
advisory, read-only. Its independent enumeration: every contract-fd write
goes through `owrite()`; `_emit_captured` re-emits captured bytes with an
unconditional `# ` prefix (spoof-proof — a captured `M foo` emits `# M
foo`); the fd topology (`_real` = dup of pre-dup2 fd1, taken before
`import pybullet`) means no C++/pump-thread print can reach `child.log`'s
OFD; and its own exhaustive classification of the 208 childreps logs found
1,276/1,276 non-empty lines prefix-clean, zero `o` offenders. The sole `o`
contributor by design is child-authored `ERROR:` — fail-closed. This matches
this seat's own grep over all 240 child logs (0 violations).

## 5. Sibling-seat interaction

Scribe (`a042e49`) F1 — `sl_force_mb`'s forced-rest tail (`z=0.49998583`,
`z+1=0.510221593`, `z+31=0.735970268`) differs from the scout's
`sleep-force` same-named scenario because the child's setup legitimately
differs (sibling body stepped 30+120 vs 30+60). **This seat reproduces the
committed pin byte-exactly** in all contexts (battery ×2, arm reps ×4, child
sweep ×4 incl. both builds) — it is self-consistent and deterministic; the
scribe's own disposition is report-precision, not fixture. Noted for the
record; no conflict with the gate.

Scribe F3 is the same §4 class — their run saw `d=8/44` clean; this seat
adds the first measured drift instances.

## Files changed

None tracked beyond this report. Written by this seat (all gitignored):
`corpus/live/r95-verifier/{runs/…,reps/…,childreps/…,flips/,spot/proj/**,
vendor-check/,tools/{compare_cases.py,rep_sweep.sh,child_sweep.sh},
cases-diff.json,MANIFEST.txt,*.log}` — **1560 receipt files** hashed in
`MANIFEST.txt`.

Key receipt shas:
- r95-only verdicts `a6b5450d…` (20/20, `seeds_unchanged=true`, ~load 80)
- full verdicts `bf29ffad…` (304/304, `seeds_unchanged=true`, Σ458 s)
- vendor provenance `vendor-check/`: `c035ebaf…` → strip → `eca749a0…` ==
  committed bytes
- `reps/shm_step.r2.log` / `.r4.log`: the live `d=10` drift receipts

## Remaining risks / blockers

- **§4 SHM `d`-count drift** — `r95_bullet_shm` pins print-interleave counts
  (`d=8`/`d=44`) that raced twice at arm level under concurrent-sweep load
  (measured; documented by author as flake class #1). Top residual risk; a
  load-spiked battery can red this row without any physics change.
- The pins are host-scoped: `/usr/bin/python3` 3.14.7, this gcc-built
  `btScalar=f64` `.so` (`dtBits=3f71111111111111` pinned in every M0),
  `/usr/bin/godot` 4.7.2 — same host-pin class as prior rounds; boundary
  already priced the float-build divergence.
- `shm_rtclass`/`neg_shm_rt` depend on the rt=1 pump stepping inside a 2 s
  sleep; a >2 s pump stall flips `fell`/`froze` — documented class, never
  observed (12/12 + all runs fell).
- Stray-process check at filing: zero processes referencing
  `r95-verifier`, `r95ch_`, my tools, or my run dirs; the live r95 child
  processes on the box belong to the sibling r95-critic mutation battery
  (`corpus/live/r95-critic/mut2/**`), not this seat.
- No blockers to the gate decision itself.

## Verdict

The insertion is clean (284→304, strict-prefix append, zero prior rows
touched), the vendored engine bytes are proven byte-identical to `strip
--strip-debug` of the scout's sha-verified venv build, all five boundary
corrections are encoded in the pins (DIRECT-scoped purity, SHM pump-live
class, order non-neutrality, 1-ulp friction, EMPTY-sleep calibration), the
dispatch graph is complete 52↔52, and the pinned surface reproduced
byte-exactly on **20/20 + 304/304 battery passes, 78/80 arm reps, and 208/208
dual-build child execs** under sustained real load (~50–127). The one live
drift observed — SHM `#`-diagnostic line counts on `r95_bullet_shm` — is the
author's own documented flake class, confined to the `d` channel, fails
closed, and never touched an M-line in 424 executions.

**VERIFIED** — committed `0767b59` clears the wave-B gate, with the SHM
`d`-drift class carried forward as a measured (not merely documented)
load-conditional flake candidate for the canonical judge.
