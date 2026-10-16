# r95 scribe — custody + consistency audit of the committed bullet/pybullet landing (`0767b59`)

Seat: GAME-DEV-3D r95 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`0767b5900f38949b6e077b0ab8317480f66166f8`**
(`2026-10-15 20:31:58 -0300`, *"r95 author: 20 bullet/pybullet rows (304 total) — vendored
.so byte-pinned, DIRECT-scoped purity + SHM pump-live class, order non-neutrality;
304/304 x2"*), `git status --porcelain --untracked-files=all` = **1 line**
(`?? reports/round-94/r94-reviewer.md`, an r94-wave leftover) at audit start. Read-only
audit plus **one** fresh behavioral run of the full battery on the committed bytes
**under load** (§6) and **one** dispatched read-only `labrat` probe that returned
**SUPPORTED** (§9). No fixture, runner, contract, axis, or route touched; **no commits**.
This seat reports; the canonical Rust judge remains the sole Pareto authority. No `lsp`
device is exposed to this seat and this seat made **no source edits at all**, so the
hand-edit fallback was never in play.

Commit contents (`git show 0767b59 --stat`): `r95_bullet.gd` +196, `r95_child.py` +1673,
`r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` (7063864 B), `run_battery.py` +40,
`reports/round-95/r95-author.md` +81 — **5 files, 1990 insertions, 0 deletions**.
Committed sha256: `r95_bullet.gd` **`f988ba86fdef62a0…`**, `r95_child.py`
**`8821ebd50459dd13…`**, vendored `.so` **`eca749a0d9b53964…`**, `run_battery.py`
**`0b9b7035cc0af0a1…`** (git blobs `14dbeb32`/`6545eb52`/`4b5c0fe5`/`93d6014a`).

Receipts: `corpus/live/r95-scribe/` (gitignored, `corpus/.gitignore:1: live/`; incl. a
23 MB annex of the author's `/tmp` evidence — §7).

---

## 1. Custody — `sha256sum -c` over both r95 manifests, plus the author's receipts

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r95-scout/manifest.sha256` | 11768 | **11768** | 0 | no self-entry; exclusions = itself + 847 `__pycache__` + 4 `venv/bin` symlinks (excluded by the documented `find -type f` rule) |
| `corpus/live/r95-boundary/manifest.sha256` | 1847 | **1847** | 0 | no self-entry; exclusions = itself + `build_float/**` (7493 files) + `__pycache__` — all stated in its `RECEIPTS.md` |

Both replays `rc=0` (`custody/{scout,boundary}-sha-check.log`); census in
`custody/manifest-census.txt`. The r93-era scout self-entry mismatch class does not
exist here: neither manifest carries a self-entry, and 0 entries fail. Both exclusion
sets are disclosed, not silent (scout `RECEIPTS.md:58-69`, boundary `RECEIPTS.md:46-60`);
the **used** engine bytes are covered twice — by the scout manifest (venv
`site-packages` .so, replayed OK) and by every battery run's `seed_digests()` map.
The boundary's quoted manifest sha `3fddafe1…` and its float-build artifacts
(`build.log eb4096a1…`, float `.so` 7d578878…) all reproduce.

**Author battery receipts** (three runs, all on the committed bytes):

| run | receipt | totals | verdict | seeds_unchanged |
|---|---|---|---|---|
| r95-only pre-run | `corpus/live/runs/20261015T224412369946Z/verdicts.json` | 20 = 14 ord + 6 neg, 20/20 P | PASS | true |
| run 1 (full) | `…20261015T224443567926Z/verdicts.json` | **304/304 PASS** (454.0 s) | PASS | true |
| run 2 (full) | `…20261015T232218926492Z/verdicts.json` | **304/304 PASS** (499.9 s) | PASS | true |

- **Seed custody:** the seed map has **74 entries** and **all 74 digests equal the
  on-disk committed blobs** — including `r95_bullet.gd f988ba86…`, `r95_child.py
  8821ebd5…`, `r95vendor/…so eca749a0…` and `run_battery.py 0b9b7035…`. All three runs
  carry the same three r95 digests, so **every author run ran the committed bytes**
  (no r93-F1-style pre-commit delta).
- **Row-level custody:** in all three runs every one of the 20 r95 rows has its exact
  marker line in stdout, `stderr=[]`, the authored exit code, and exactly one extra
  stdout line (the Godot banner) — `author-verdict-rows.txt`.
- **Scout pass-1 self-consistency:** `runs/20261015T071515Z` vs `…T075938Z` (its
  byte-diff rerun) are **byte-identical: 558/558 files** (`scout-pass1-vs-pass1rerun.txt`).

**Vendor byte-identity (exact operation, not just a claim):** the committed `.so` is
**byte-identical to `strip --strip-debug` applied to the scout's venv build**
(`corpus/live/r95-scout/venv/…/pybullet.cpython-314-x86_64-linux-gnu.so`, sha
`c035ebaf…` as quoted) — reproduced copy + strip + `cmp` in
`vendor-stripcheck/`; the venv copy carries the full `.debug_*` DWARF set, the
committed copy carries `.symtab` only (`vendor-stripcheck/sections.txt`). The `.so`
is an ELF64 x86-64 shared object (`cpython-314` ABI tag, py3.14-bound).

## 2. Claim arithmetic — every author number re-measured

| claim (author report) | measured | verdict |
|---|---|---|
| "Before: 284 cases → After: 304 = +20 r95 rows (14 ordinary + 6 negative)" | AST census of `CASES` at `05e72ef` = 284; at `0767b59` = 304; the 284-name list is a strict **prefix**; field-compare of every pre-existing row = **0 modified**; added = exactly the 20 `r95_bullet_*` rows (14 + 6) | **verified** |
| totals "245 ordinary + 59 negative" | AST count: 245 / 59 | **verified** |
| `run_battery.py` "insertion-only — `git diff` = +40 lines" | `git show 0767b59 --numstat` = **40 + / 0 −**, appended after `r94_cannon_neg_grid`; the author's `/tmp/r95rows.txt` paste is **byte-identical** to the committed block | **verified** |
| "20 CASES rows → **52 child cells** per battery pass" | `ARM_CASES` (14 arms) = 46 cases + 6 negative arms = **52** cells; per-row counts `det 13, freeze 2, rt 3, shm 2, sleep 5, sleep2 4, nan 2, nan2 3, fric 3, rest 1, knobs 2, solver 2, pile 1, misc 3` | **verified** |
| "`r95_child.py` — **52 cases** (46 positive + 6 negative)" | `CASES` dict = 52 entries, 46 positive + 6 `neg_*` | **verified** |
| "13 positive arms fold each child's merged log into `{rc,m,o,d}` … `o` must be 0, `d` counted never pinned verbatim" | rebuilt all 52 cells from 4 independent run trees (§3): `o=0` in every cell; the `#` diagnostic surface never enters a pin (`distinct`/`pinFree`/`z1=` absent from all 20 pins); `d` histogram `{1:43, 4:1 (sv_backends), 8:1 (shm_step), 44:1 (shm_rtclass)}` | **verified** |
| "6 negative arms require the child's live control + `NEGATIVE REJECTED:` + rc 2; the parent echoes the exact line and quits 2" | code-read of `_run_negative`/`_run_child`; all 6 negative pins carry their live control (`neg_dt` `02309c…→3e5afa1e…`, `neg_order` `→76988a…`, `neg_radius` `+inf accepted id=1`, `neg_simtime` TypeError ×2, `neg_badid` 3 refusals, `neg_shm_rt` DIRECT `froze=True` vs SHM `fell=True`); battery records `actual_exit=2` for all 6 in all 3 author runs + this seat's run | **verified** |
| "Run 1/run 2: 304/304, seeds_unchanged=true" | §1; run sums 454.0 s / 499.9 s (r95 rows 25.9 s / 29.7 s) | **verified** |
| "Vendor equivalence: all 52 cases … contract lines byte-identical" | `/tmp/r95run` (vendored) vs `/tmp/r95orig/out` (unstripped venv): **52/52 files byte-identical** (full output, not just contract lines) | **verified** |
| "Child rep sweep: all 52 cases × 3 fresh processes … identical rc/o/d" | annexed `/tmp/r95rep`: 52 cases × 3 reps, folds identical, `o=0`, and every swept `(m,o,d)` equals the committed pin (52/52 + 6 negative lines) | **verified** |
| "Fixture rep sweep: all 20 arms × 3 godot runs → byte-identical markers" | annexed `/tmp/r95marks`: 20 arms × 3 runs, marks byte-identical, all `.err` empty, every mark == the committed pin (20/20) | **verified** |
| "All positive M-lines diffed against the scout's pinned `rep1.out` files … byte-identical" | label-matched: **69 M payloads are exact source lines**; 10 same-label lines are format extensions/merges; **1 carries genuinely different values** (`sl_force_mb` forced-rest tail — F1) | **overbroad by one cell** |
| "Slowest child ~4.5 s (`shm_rtclass`)" | single-child wall times: `shm_rtclass` 2.52 s idle-host (row elapsed 3.2–4.2 s under load) — consistent | **verified (load-dependent)** |

## 3. Pin provenance — the markers were rebuilt, not hand-typed

All 20 pinned marker lines / 52 cells were **rebuilt from the child logs** with an
independent re-implementation of the parent's `_run_child`/`_emit` fold
(`pin-provenance/rebuild.py`), byte-compared with the `CASES` pins:

| source | cells rebuilt | arms compared | mismatches |
|---|---|---|---|
| author pre-run scratch | 52 | 20 | **0** |
| author run 1 scratch (committed bytes) | 52 | 20 | **0** |
| author run 2 scratch (committed bytes) | 52 | 20 | **0** |
| this seat's under-load run scratch | 52 | 20 | **0** |

`o=0` in all 52 cells; the fold counts `#` lines but pins only the count.

**Value provenance:** of the 43 distinct 16-hex hashes in the pins, **42 appear
verbatim in the scout+boundary evidence corpus**; the single miss is the `neg_dt`
live-control hash `3e5afa1e3405090d` (a new probe value, deterministic in 6 author
sweep runs + this seat's run — F2). The 3 long decimals not present in the sources are
the `sl_force_mb` tail (F1). The M0 header is engine-derived: `api` from
`getAPIVersion()`, `dtBits` from the engine's stored `fixedTimeStep` (f64 bits of 1/240
= `3f71111111111111`; the float rebuild reads `3f71111120000000`), `build` from the
engine's own import banner, `py` from `platform.python_version()`; `engine=pybullet-3.2.7`
is the one authored literal, corroborated by the pinned sdist trace (§9).

**Path independence:** running children from `cwd=/` with absolute paths gives
identical M lines and rc 0 (positives) / 2 (`neg_dt`) — the vendor dir is
self-contained (`path-independence.txt`).

## 4. Rep-stability and the runtime surface

### 4.1 Rep stability on the committed bytes
The author's 52×3 child sweep and 20×3 fixture sweep are byte-identical across reps
(§2), and this seat's under-load run adds a fourth independent full-battery
observation: **all 20 r95 rows' stdout is byte-identical to both author runs** (§6).

### 4.2 Runtime surface
Every PASS line pins `py=3.14.7` and each M0 header pins the engine identity. The
vendored `.so` is a `cpython-314` extension module, so the Python ABI is a hard host
pin of the same class as the godot/blender pins (no cross-version portability claim
is made anywhere). The pinned `d`-count classes reproduce under load in this seat's
run (`shm_step d=8`, `shm_rtclass d=44`).

### 4.3 Vendor equivalence
52/52 case outputs byte-identical between the vendored stripped `.so` and the
unstripped venv build (§2), and the committed `.so` is exactly the stripped artifact
(§1).

## 5. Corrections vs scout + boundary — every mandatory fold is landed

| correction (task list / boundary falsification) | encoded in the committed pins | verdict |
|---|---|---|
| **DIRECT-scoped purity** (boundary §2: "no wall-clock path" is DIRECT-only) | `rt_inert` (`rt0≡rt1 h=02309c52da41ef33`, flags read back 0/1), `rt_idle` (0.6 s idle + 120 API calls move nothing), `rt_paced` (stepped pin under rt=1), plus `shm_step` `rt=0 h=02309c52da41ef33 eqPin=True` (transport-neutral when stepped) | **landed** |
| **SHM rt=1 pump-live class** (boundary: falls during a bare sleep) | `shm_rtclass` `rtflag=1 idle2.0s fell=True`; `neg_shm_rt` rejects via the robust pump-liveness contrast (DIRECT `froze=True` vs SHM `fell=True`); the stepped divergence stays `#`-only (`distinct`/`pinFree` never pinned) | **landed** |
| **Order non-neutrality** (vs the r94-cannon canon result) | `det_order h_forward=02309c52da41ef33 h_reverse=76988acc55682c1a eq=False`; `det_interleave`; `pile` `rev=38cb12317d6644da`; `neg_order` rejection | **landed** |
| **1-ulp friction** (boundary §2.7/§7.14) | `fr_bitexact prod0808=3fe47ae147ae147c prod064=3fe47ae147ae147b ulpEq=False`, per-pair hashes (`54d2f4…` vs `3e79f2…`), commutativity bit-exact (`g0.64/b1.0 ≡ g1.0/b0.64`) | **landed** |
| **EMPTY-sleep calibration** (scout §2.4/§2.9c, survives) | `sl_force_max` (maximal coords) `an=EMPTY` + frozen body; `sl_force_mb` (reduced coords) forced sleep ignored; `sl_rest_max an=i0/n1/it2 cc=1` through 1400 steps | **landed** |
| `deterministicOverlappingPairs` scene-scoped | `det_detpairs` `scene=5body … eq=True` + `pile_lattice det1=a272ef21dd510162` (loud at scale) | **landed** |
| bit-fixpoint scene-dependent | `freeze_scene changes=3000/3000 freezeStep=-1` vs `freeze_ball changes=79 freezeStep=80` | **landed** |
| `>=0` write gate is a NaN filter | `fr_gate` (`mu=-0.5` dropped → `stored=0.5`, `mu=11` stored), `nan_mass` (NaN dropped, `+inf` stored), `nan_damp` (unclamped `d=1.5`, neg/NaN dropped) | **landed** |
| b3Warning rides stdout (fd 1) | both fds captured for the whole process and re-emitted as `#`; the pinned surface is `d` counts only; `o=0` everywhere | **landed** |
| solver-backend / knob / tick-rate axes (boundary §3) | `sv_backends` (SI≡unset, PGS `8606ea0c…`, DANTZIG `71248c7a…`), `sv_tps` lattice + substep/dt equivalence, `kn_neutral eqBase=9/9` / `kn_loud` 8 hashes | **landed** |

## 6. Verdict on the committed tree — fresh under-load battery run

    python3 corpus/fixtures/run_battery.py \
      --runs corpus/live/r95-scribe/battery-committed      # started 23:33:17Z

| measure | value |
|---|---|
| wall / load | **8 m 26 s** (23:33:17Z → 23:41:43Z); load1 = 79.4 at start, 86.1–86.7 mid-run (12 self-owned hogs + sibling-seat load), 74.2 at end; 93 runnable processes at arming |
| receipt | `battery-committed/20261015T233317241106Z/verdicts.json` sha `96b9c53e83802d01…` |
| totals | **304 cases, 301 PASS / 3 FAIL** (245 ordinary + 59 negative), `seeds_unchanged=true` (74/74 digests == committed) |
| FAILs | `navagent3d_retarget` (`before=1.754246` = +1 tick), `navagent3d_follow` (`first=1.636395` = +1 tick), `phys3d_events_deferred_hang` (`drift exit=0 expected=137 … abort=false refusal=false` — the exact r93 "granted-under-load" signature) — **all three on the documented flake list** |
| **r95 rows** | **20/20 PASS**; marker present as an exact stdout line; `stderr=[]`; `(stdout, stderr, exit)` **byte-identical to author run 1 AND run 2 for all 20 rows**; r95 sum 28.9 s; `shm_step d=8`, `shm_rtclass d=44` reproduce the pinned classes |
| deltas vs author run 2 | 4 rows: the three flake rows + `r92_animphys_idlemode`'s `#` envelope diagnostic (its only differing lines; stdout/stderr/exit otherwise equal) |
| hog hygiene | self-owned hogs only, killed **by exact PID** at 23:41:43Z (all 12 confirmed dead; no pattern-wide `pkill`) |

**Conclusion: the committed tree is behaviorally the tree the author measured.** The
20-row surface is load-invariant across the author's 52×3 child sweep and 20×3 fixture
sweep, all three author battery runs, and this seat's independent under-load run; the
only failures in this seat's run are three documented load-flake rows, and the
`304/304` headline is a genuine run on the committed bytes (run 1 and run 2), not a
pre-commit artifact.

## 7. Untracked census, freshness, and the /tmp annex

- `git status --porcelain --untracked-files=all` = **1 line** at audit start
  (`?? reports/round-94/r94-reviewer.md`); at filing: that line + this report. **This
  seat wrote no tracked file**; receipts live in the gitignored
  `corpus/live/r95-scribe/` (`git check-ignore -v` → `corpus/.gitignore:1:live/`).
- **Sibling wave-B seats ran concurrently** (r95 critic/reviewer/simplifier/verifier):
  their gitignored receipt dirs appeared mid-audit; HEAD never moved from `0767b59`.
- **`/tmp` annex:** the author's evidence exists only in `/tmp` (ephemeral). This seat
  annexed the g3d-lane artifacts into `annex-author-tmp/` — `rep-sweep/` (165 files),
  `marks-sweep/` (100), `vendor-run/` (52), `orig-run/` (52), `scratch/`, `test/`, the
  `r95rows*.txt` pastes — **23 MB**. Foreign audio-lane files matching the `/tmp/r95*`
  glob (`r95_info*.json`, `r95_xc*.log`, `r95_props_test.*`, `r95_rendered.*`,
  `r95_manual_{rep,rev}.sh`, `r95-manifest.txt`) were **excluded** as not this lane's
  evidence.
- **Freshness.** `LOG.md`: last section header is `## round 92` (line 1205) with
  "ROUND 93"/"ROUND 94" bullets appended inside it; `SCORECARD.md`: last verdict block
  is **Round 94** (line 225); no r95 section/row yet — expected pre-adjudication (F5).
- **Landing commits:** `r95-scout.md` and `r95-boundary.md` are tracked; the author
  report landed in `0767b59` itself.

## 8. Findings (ranked, for the canonical judge)

- **F1 (medium-low, claim accuracy + a real physics observation).** The `sl_force_mb`
  cell's forced-rest tail is **not** byte-identical to the scout's `sleep-force` cell of
  the same scenario: pinned `forcedRest z=0.49998583 velwrite z+1=0.510221593
  z+31=0.735970268` vs the scout's `z=0.49999 z+1=0.510225597 z+31=0.735969337`. The
  author's "All positive M-lines … byte-identical" claim is therefore overbroad by this
  one cell (the cell's first half — the `sleep-force-mb` rows — IS byte-identical).
  Cause isolated by a bounded experiment (`force-mb-probe/`, deterministic ×2): the
  child merges the pass-2 `sleep-force-mb` history (first body stepped 30+120) with the
  pass-1 `sleep-force` tail (first body 30+60), and the extra 60 steps of the **other**
  body shift the second body's resting penetration by ~4.2e-6 (variant A = scout
  numbers exactly; variant D = child numbers exactly; `reportSolverAnalytics` and the
  explicit `useMaximalCoordinates=False` kwarg are **irrelevant** — variants C/E
  reproduce the scout). The pinned values are the child's own deterministic measurement
  and reproduce in all sweeps and this seat's run; the disposition is a report-precision
  correction, not a fixture change. Observation for a future round: a resting state is
  **not** a pure function of that body's own history — a sibling body's step count
  moves it (solver/warm-start state class).
- **F2 (low, provenance).** `neg_dt`'s live-control hash `3e5afa1e3405090d` is the only
  one of 43 pinned hashes absent from the scout+boundary evidence corpus — new probe
  evidence rather than a copied pin; it is deterministic across the 3-rep sweep and all
  four battery runs (7 observations).
- **F3 (low, documented flake class).** The SHM `#`-diagnostic counts are pinned as
  counts (`d=8`/`d=44`) and the author documents the drift class: if a teardown print
  lands post-drain the count moves and the row reddens by design. This seat's run
  reproduced both counts under load (7th independent observation of the class).
- **F4 (low, census scope).** Manifest exclusions: scout 847 `__pycache__` + 4
  `venv/bin` symlinks (the latter excluded by the manifest's own `find -type f` rule) +
  itself; boundary `build_float/**` (7493 files, its post-run prune of 267 compiler
  objects disclosed) + `__pycache__` + itself. All disclosed in `RECEIPTS.md`; the used
  engine bytes are anchored by the scout manifest and by 74/74 seed digests. No custody
  loss.
- **F5 (freshness, expected).** `LOG.md`/`SCORECARD.md` carry no r95 section/row yet
  (pre-adjudication).
- **F6 (observation).** The r95 scout report's wall-clock section is already
  DIRECT-scoped (its §2.2 heading and summary table say "in DIRECT"), and the boundary's
  general falsification (SHM) is encoded in the pins; no r94-F8-class unamended
  overclaim was found in the scout report.
- **F7 (custody event, not a defect).** Sibling wave-B seats' gitignored receipts dirs
  appeared mid-audit; HEAD unchanged at `0767b59`; no tracked file modified; §1–§6
  remain valid for the `0767b59` artifact set.
- **F8 (observation, durability).** The author's rep-sweep/pre-run evidence lived only
  in `/tmp`; this seat annexed it (§7). The author report's rep-stability section should
  be read with that annex as its receipt.

## 9. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with a single falsifiable hypothesis — the
vendored `.so` comes from the pinned sdist tree built with `-DBT_USE_DOUBLE_PRECISION`,
version 3.2.7 / API 202010061. It returned **SUPPORTED** (this substrate's labrat DID
have read-only recon tools, unlike the r94 scribe's) with a file:line trace:
`setup.py:73` `CXX_FLAGS += '-DBT_USE_DOUBLE_PRECISION '` (unconditional);
`setup.py:508 version='3.2.7'` / `PKG-INFO:3`;
`examples/SharedMemory/SharedMemoryPublic.h:12 #define SHARED_MEMORY_MAGIC_NUMBER 202010061`;
`examples/pybullet/pybullet.c:13475 fprintf(stderr, "pybullet build time: %s %s\n", __DATE__, __TIME__)`
(so the M0 `build=` string is a compile stamp, not a version discriminator);
`src/LinearMath/btScalar.h:309-314` double/float typedef switch. Full return in
`labrat-probe.md`. Its own caveat: the trace proves the pinned tree *can* produce these
bytes; byte-identity to the venv build plus matching constants makes an alternative
source unlikely but not formally excluded. Advisory only; no writes.

## 10. Verified vs pending

**Verified (receipt/artifact-pinned):** scout 11768/11768 and boundary 1847/1847
manifest replays; no self-entries; disclosed exclusions; committed shas for all 4 r95
artifacts; 74/74 seed digests == committed bytes in all three author runs; vendor
byte-identity to `strip --strip-debug` (exact operation) and `.debug_*`-only removal;
scout pass-1 vs pass-1-rerun 558/558 byte-identical; boundary manifest sha + float
artifacts as quoted; `304 = 284 + 20 = 245 + 59` with prefix identity and 0 modified
pre-existing rows; `run_battery.py` +40/−0; 52 cells (46+6) with `o=0` everywhere and
`d` counted only; all 20 pins rebuilt byte-identically from **four** independent run
trees; 42/43 hashes + all source-shared values verbatim in scout/boundary evidence; the
five named corrections plus the other six disclosures encoded; the 52×3 child sweep and
20×3 fixture sweep byte-identical and equal to the pins; 52/52 vendor-equivalence;
child path-independence; the M0 header's engine-derived fields and the double/float
`dtBits` discriminator; this seat's under-load 304-case run (301/304, 20/20 r95 rows
byte-identical to both author runs, seeds unchanged, `d=8/44` classes reproduced).

**Pending / for the operator or adjudicator (not blockers for this seat):** F1 is a
report-precision correction (no fixture change proposed); F2–F8 are observations for
the round record. Nothing in this audit blocks adjudication of `0767b59`; no fixture,
contract, axis, route, or receipt was mutated, and no commit was made.

## 11. Evidence index

`corpus/live/r95-scribe/` — `RECEIPTS.md`, `env-at-start.txt`, `custody/` (both
manifest replays + census), `pin-provenance/` (rebuild tool + 4 run rebuilds),
`pin-analysis.txt`, `pin-value-provenance.txt`, `pin-hash-provenance.txt`,
`scout-crosscheck.txt`, `scout-line-compare.txt`, `child-rep-sweep-check.txt`,
`marks-sweep-check.txt`, `author-verdict-rows.txt`, `author-run-timings.txt`,
`scout-pass1-vs-pass1rerun.txt`, `vendor-stripcheck/`, `force-mb-probe/`,
`path-independence.txt`, `child-timings.txt`, `labrat-probe.md`,
`battery-committed/20261015T233317241106Z/` (this seat's run: `verdicts.json` +
`scratch/` with per-case child logs), `battery-committed.log`, `battery-load.txt`,
`scribe-vs-author-compare.txt`, `annex-author-tmp/` (the `/tmp` annex).

Reproduce any cell: `python3 corpus/fixtures/run_battery.py --runs <dir>` (full, 304);
`python3 corpus/live/r95-scribe/pin-provenance/rebuild.py <run>/scratch
corpus/fixtures/run_battery.py corpus/fixtures/r95_bullet.gd <out.json>` (pin rebuild);
`/usr/bin/python3 corpus/fixtures/r95_child.py <case> corpus/fixtures/r95vendor`
(single child, one fresh process).
