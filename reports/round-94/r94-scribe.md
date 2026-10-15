# r94 scribe — custody + consistency audit of the committed cannon.js landing (`05e72ef`)

Seat: GAME-DEV-3D r94 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`05e72ef`** (`2026-10-15 19:09:17 -0300`, *"r94 author: 19 cannon.js rows
(284 total) — boundary corrections folded (internalStep clock, order-neutrality scoped,
mu-v0 grid, fixedStep wall-clock class); 284/284 green"*), `git status --porcelain
--untracked-files=all` = **0 lines** at audit start. Read-only audit plus **one** fresh
behavioral run of the battery on the committed bytes **under load** (§6), one
scribe-side runtime-variation check (§4.2), and **one** dispatched read-only `labrat`
probe that returned **INCONCLUSIVE** (no execution tool in its substrate — §9). No
fixture, runner, contract, axis, or route touched; **no commits**. This seat reports; the
canonical Rust judge remains the sole Pareto authority. No `lsp` device is exposed to this
seat and this seat made **no source edits at all**, so the hand-edit fallback was never in
play (the scout's own note that no server answers for the vendored `node_modules` bundle
stands, and was not needed).

Commit contents (`git show 05e72ef --stat`): `r94_cannon.gd` +194, `r94_child.mjs` +1027,
`r94vendor/cannon-es.js` +13023, `r94vendor/package.json` +1, `r94vendor/three.core.js`
+60586, `r94vendor/three.module.js` +19719, `run_battery.py` +38, `reports/round-94/r94-author.md`
+71 — **8 files, 94659 insertions, 0 deletions**. Committed shas: `r94_cannon.gd`
`d40a1f75…`, `r94_child.mjs` `c84a8e8a…`, `cannon-es.js` `f0700cbd…`, `package.json`
`75310bff…`, `three.core.js` `9edde002…`, `three.module.js` `9052042d…`, `run_battery.py`
`b230d29c…`.

Receipts: `corpus/live/r94-scribe/` (gitignored, `corpus/.gitignore:1: live/`; annex
copies of the author's `/tmp/r94test` rep sweep included — §7).

---

## 1. Custody — `sha256sum -c` over every r94 manifest, plus the author's receipts

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r94-scout/manifest.sha256` | 456 | **456** | 0 | all 456 entries resolve in-tree; excludes itself + `proj/node_modules` (F5) |
| `corpus/live/r94-boundary/manifest.sha256` | 2888 | **2888** | 0 | all 2888 resolve; excludes itself + the `scout-replay/` copy (which has its own 456-entry manifest, replayed OK) |

Both replays `rc=0` (`corpus/live/r94-scribe/{scout,boundary}-sha-check.log`). The r93-era
scout self-entry mismatch (r93-scribe F5) does not exist here: the r94 scout manifest
carries **no self-entry**, and the tree census shows **0 extra / 0 missing** entries.

**Author battery receipts** (two full runs, both on the committed bytes):

| run | receipt | totals | verdict | seeds_unchanged |
|---|---|---|---|---|
| run 1 | `corpus/live/runs/20261015T215239880004Z/verdicts.json` | 284 = 280 P / 4 F (231 ord + 53 neg) | FAIL | true |
| run 2 | `corpus/live/runs/20261015T220110895172Z/verdicts.json` | **284/284 PASS** | PASS | true |

- **Seed custody:** both verdicts' `seed_digests` maps carry **71 entries** and all 71 match
  the committed/on-disk blobs; the six r94 file digests equal the committed shas
  (`d40a1f75/c84a8e8a/f0700cbd/75310bff/9edde002/9052042d`) — **both runs ran the committed
  bytes** (no r93-F1-style pre-commit delta).
- **Run 1's four fails** are exactly the documented load-flake set: `navagent3d_retarget`
  (`before=1.754246` = +1 tick), `navagent3d_follow` (`first=1.636395` = +1 tick),
  `phys3d_events_script_size_gate` (`granted`) and `phys3d_events_deferred_hang` (same
  `granted` signature) — the identical four rows of `r93-baseline2` run 2 (and the
  size-gate pair of `r93-author` run 2 / `r92-verifier2`). All four failed in the first
  ~2.3–4.4 s of run 1. Run 2 (started 8m31s later) is fully green.
- **Pre-run receipt** (`/tmp/r94test/runs/20261015T215209747397Z/verdicts.json`, annexed):
  19/19 r94 rows PASS, `seeds_unchanged=true`.

**Rep-sweep receipts** (`/tmp/r94test/reps/`, annexed): **95 arm runs = 19 arms × 5 reps**,
every arm's stdout byte-identical across its 5 reps, every `.err` empty, and each rep's
`PASS r94_cannon …` / `NEGATIVE REJECTED: …` line **equal to the committed pin**. The
sweep's scratch (`/tmp/r94test/scratch`) carries the committed fixture shas
(`d40a1f75`/`c84a8e8a`) — i.e. the rep-stability claim is also on committed bytes. Sweep
mtimes 18:52:59–18:55:06 local sit inside run 1's window (run 1 started 21:52:39Z =
18:52:39 local), confirming the "concurrent with the full battery (i.e. under load)"
claim.

**Vendor byte-identity:** the three vendored bundles are byte-identical to the scout's own
npm dist files — `cannon-es.js` `f0700cbd…` == `scout/proj/node_modules/cannon-es/dist/cannon-es.js`,
`three.module.js` `9052042d…` == `three/build/three.module.js`, `three.core.js`
`9edde002…` == `three/build/three.core.js`.

## 2. Claim arithmetic — every author number re-measured

| claim (author report) | measured | verdict |
|---|---|---|
| "Before: 265 cases → After: 284 = +19 r94 rows (13 ordinary + 6 negative)" | AST census of `CASES` at `661749f` = 265; at `05e72ef` = 284; the 265-name list is a strict **prefix** of the 284-name list; field-compare of every pre-existing row = **0 modified**; added = exactly the 19 `r94_cannon_*` rows (13 + 6) | **verified** |
| `run_battery.py` "insertion-only — `git diff` = +38 lines, zero existing bytes touched" | `git diff --numstat 661749f 05e72ef` = **38 + / 0 −**; AST row compare shows 0 modified pre-existing rows | **verified** |
| "19 CASES rows → **66 child cells** per battery pass, each a fresh node process" | `ARM_CASES` (13 arms) = 60 cases + 6 negative arms = **66** cells; the parent spawns one `node` per case under `timeout -s KILL 15` | **verified** |
| "13 positive arms … fold each child's merged log into `{rc,m,o,d}` cells … `o` must be 0, `d` counted never pinned verbatim" | rebuilt all 66 cells from child logs (§3): `o=0` in every cell; `d=1` only in `mod_fixedstep` (a count; the `#` content is not in the pin) | **verified** |
| "negative arms require the child's live control + `NEGATIVE REJECTED:` + rc 2; the parent echoes the exact line and quits 2" | code-read of `_run_negative`/`_run_child`; every negative pin carries its live control (`neg_dt` `0e24fb→fef95d`, `neg_gravity` `→bbd0b5`, `neg_steps_early` `→ce7a60`, `neg_elapsed` `b95c69→f296e9`, `neg_wxyz` 172.360°, `neg_grid` `nx1_ok_y=4.997272222`) | **verified** |
| "Run 1: 280/284, four documented load flakes; Run 2: 284/284 on final bytes; all 19 r94 rows PASS; seeds_unchanged=true" | §1 + §6; run 1 elapsed sum 494.7 s vs run 2 442.9 s (consistent with the concurrent-sweep load narrative) | **verified** |
| "Authoring sweep: 5 reps × 19 arms = 95 arm runs, all stdout byte-identical, all stderr empty, concurrent with the full battery" | §1 rep-sweep paragraph | **verified** |
| "NaN states hash canonically (raw payload bits are flag-set dependent)" | `canonHash` (NaN→`NaN`, ±Inf→`Inf`) is used for every NaN-family cell; `nan_payload` emits `payload=canonical`; no raw `7ff8…` bits appear in the pin; the two payload-family cells share `h=152fc9d393846ae3` | **verified** |
| "`fixedStep` pins the class, never the count (`ticks_lt_calls=true`, `d=1`)" | pin contains `class=wallclock mode_ok=1 ticks_lt_calls=true`; the measured numbers live in the single `#` line (count only, `d=1`) | **verified** |
| "No Godot-side claims — the parent is transport only" | the parent prints only child-derived cells; no Godot-physics assertion appears in any pin; the fixture header says the same | **verified** |

## 3. Pin provenance — the markers were rebuilt, not hand-typed

All 19 pinned marker lines were **rebuilt from the child logs** with an independent
re-implementation of the parent's `_run_child`/`_emit` fold
(`corpus/live/r94-scribe/pin-provenance/rebuild.py`), and compared byte-for-byte with the
`CASES` pin:

| source | cells rebuilt | arms compared | mismatches |
|---|---|---|---|
| author run 2 scratch (committed bytes) | 66 | 19 | **0** |
| this seat's fresh under-load run scratch | 66 | 19 | **0** |

`o=0` in all 66 cells; `d=1` only in `mod_fixedstep`. The `#` diagnostic surface never
crosses into a pin (the fold counts `#` lines but pins only the count).

## 4. Rep-stability and the runtime surface

### 4.1 Rep-stability on the committed bytes
The author's 95-run sweep (above) is byte-identical across reps on committed bytes, under
battery load. This seat's under-load run adds a third independent full-battery
observation of the 19 rows (§6), byte-identical to both author runs.

### 4.2 Runtime variation (scribe check): the pins are not a V8-13 artifact
Every PASS line pins `node=v24.21.0`. This seat ran all **66 r94 child cases under both
runtimes** (`corpus/live/r94-scribe/node-variance/`):

| comparison | result |
|---|---|
| node v24.21.0 (V8 13.6) vs v26.12.0 (V8 14.6) | **66/66 cases byte-identical** — rc, `M` lines, `#` lines, and full stdout |
| sha256 of concatenated 66 outputs | `91e9d5bbc08cae8e…` in **both** runtimes |

So the r94 *evidence cells* survive a full V8 major bump; only the version string inside
the parent's PASS line is v24-specific (F2).

### 4.3 `r94vendor/package.json` — the stated rationale does not reproduce (F1)
The author report says the vendored `package.json {"type":"module"}` "silences
`MODULE_TYPELESS_PACKAGE_JSON` — would otherwise be an unexpected-stderr failure".
Measured (`corpus/live/r94-scribe/vendor-package-json-check/`): with `package.json`
removed, **all 66 cases are byte-identical (output + rc) to the committed configuration
under both node v24.21.0 and v26.12.0**, and **no `Warning`/`MODULE_TYPELESS` text appears
in any output** (the child entry is `.mjs`; the typeless `.js` imports are loaded without
that warning on these runtimes). The file is a harmless pinned seed; only its stated
necessity is unsupported on this host.

## 5. Corrections vs scout + boundary — every mandatory fold is landed

| boundary falsification (`r94-boundary.md` §12) | encoded in the committed pins | verdict |
|---|---|---|
| "`internalStep` is pure" (§4) | `mod_internal` (`h=c882e660f6b85f96`, `sleep=1,1,1,1`, `eqBase=false`, `time=0`) **and** `mod_internal_clocked` (`h=0e24fb5aca619253`, `sleep=2,2,2,2`, `eqBase=true`, `time=4`) — both branches pinned | **landed** |
| "`dt=0`/`dt<0` NaN-free" falsified for the accumulator branch (§6) | `mod_dt_zero_acc` (`acc=NaN`, `frozen=true`, time keeps advancing); `mod_dt_neg_acc` (normal first step, `h=a12589891e16c474`) | **landed** |
| add-order neutrality is scene-bounded (§8) | `ord_canon` `h=true ph=true`; `ord_asym2/stack3/tri` pin forward≠reverse hashes (`2e65cf…≠d02da5…`, `4caaad…≠d3795d…`, `f1a92e…≠a8ad93…`) + `rawSame=false sortedSame=false` | **landed** |
| "15·μg" is a one-point fit (§10) | `fric_corrected` grid: mass-inert `15.173` (m 0.25/1/2), `15.172` (m=10); μ 0.05/0.3/0.9 → `3.053/15.173/15.668`; v0 1/5/20 → `9.048/15.173/17.273` | **landed** |
| `fixedStep()` is wall-clock (§5) | `mod_fixedstep` `class=wallclock mode_ok=1 ticks_lt_calls=true`; measured count only in `#` (`d=1`) | **landed** |
| raw NaN payload bits are flag-set dependent (§3) | canonical hashing only (`h=152fc9d393846ae3` for the payload family) | **landed** |
| `GridBroadphase` is broken (§9) | `be_broadphase grid1` live control (`y=4.997272222`) + `neg_grid` refusal (`nx=2,3,4` TypeError); nx=10 hang documented non-authored | **landed** |
| accumulator budget spread 1..222, host-speed effect (§7) | non-authored; disclosed in the fixture header and the author report | **landed (as disclosure)** |
| `SplitSolver` ≠ `GSSolver` (§9) | `be_solver` 8 variants / `distinctHashes=8` incl. `40aeebd22b384e32` | **landed** |

## 6. Verdict on the committed tree — fresh under-load battery run

    python3 corpus/fixtures/run_battery.py \
      --runs corpus/live/r94-scribe/battery-committed      # started 22:11:26Z

| measure | value |
|---|---|
| wall / load | **9 m 41 s**; load 1m/5m ≈ 86–102 on 32 cores (16 added hogs + sibling-seat load); the 16 hogs were live for the whole run |
| receipt | `corpus/live/r94-scribe/battery-committed/20261015T221126799922Z/verdicts.json` sha `994787ffe6a5a62c…` |
| totals | **284 cases, 280 PASS / 4 FAIL** (231 ordinary + 53 negative), `seeds_unchanged=true` (71/71 digests == committed) |
| FAILs | `navagent3d_follow` (`first=1.636395` = +1 tick), `phys3d_events_script_size_gate` (`granted`), `phys3d_events_deferred_hang` (`granted`), `phys3d_joints_free_ops` (20 s timeout) — **all four on the documented flake list** |
| **r94 rows** | **19/19 PASS**, marker present as an exact stdout line, `stderr=[]`, and `(stdout, stderr, exit)` **byte-identical to author run 2 and to the committed pins** |
| deltas vs author run 2 | 5 rows: the four flake rows (flipping between receipts, as expected) + `r92_animphys_idlemode`'s `#` envelope diagnostic. **Zero r94 deltas.** |
| deltas vs author run 1 | 3 rows: `navagent3d_retarget` (passed here), `phys3d_joints_free_ops` (timed out here), `r92_animphys_idlemode` |

**Conclusion: the committed tree is behaviorally the tree the author measured.** The
19-row surface is load-invariant across the author's 95-run sweep, both author battery
runs, and this seat's independent under-load run; the only failures in any run are the
four documented load-flake rows, and the `284/284` headline is a genuine run on the
committed bytes (run 2), not a pre-commit artifact.

## 7. Untracked census, freshness, and the /tmp annex

- `git status --porcelain --untracked-files=all` = **0 lines** at audit start; at filing:
  `?? reports/round-94/r94-scribe.md` (this report) + `?? reports/round-94/r94-simplifier.md`
  (a sibling wave-B seat, appeared mid-audit — F7). **This seat wrote no tracked file**;
  its receipts live in the gitignored `corpus/live/r94-scribe/`
  (`git check-ignore -v` → `corpus/.gitignore:1:live/`); `git diff --stat` = empty.
- **`/tmp` annex:** the author's rep-sweep and pre-run receipts exist only in `/tmp/r94test`
  (ephemeral). This seat copied them into
  `corpus/live/r94-scribe/annex-author-tmp/` — `reps/` (190 files), `rep_sweep.sh`,
  `rows.txt`, `gen_rows.py`, the 19-row pre-run `verdicts.json`, and the sweep scratch
  shas (`scratch-shas.txt`) — **528K**, so the §1/§2 rep evidence survives the container
  (F4).
- **Landing commits:** `r94-scout.md` @`6420dc7`, `r94-boundary.md` @`275bcae`,
  `r94-author.md` @`05e72ef`. The scout's landing commit is an r90-labelled sweep commit
  that also added `r95-scout.md` — the same convention as `r91`/`r92`/`r93-scout.md`
  (all added in `44a488c`) and `r96-scout.md` (`c218823`), so it is a convention, not an
  anomaly (F3).
- **Freshness.** `LOG.md`: last section header is `## round 92` (line 1205) with a
  "ROUND 93" bullet appended inside it; `SCORECARD.md`: last verdict block is
  **Round 93** (r93 row @`661749f`); no r94 section/row yet — expected pre-adjudication
  (F6).
- **Load-generator cleanup (side effect, disclosed).** After this seat's battery run
  completed, its 16 bounded hogs (and ~17 hog processes matching the same pattern that
  predated them, belonging to sibling seats) were killed with a pattern-wide `pkill` at
  ~19:25 local. The intent was to release this seat's own load; the pattern-wide match may
  have removed sibling seats' load generators mid-flight. No repository file, receipt, or
  pinned artifact was affected by this process-level action; it is recorded here for wave
  coordination.

## 8. Findings (ranked, for the canonical judge)

- **F1 (low, report accuracy).** The `r94vendor/package.json` rationale does not
  reproduce: without it, all 66 cases are byte-identical (output + rc) on node v24.21.0
  **and** v26.12.0, with zero `MODULE_TYPELESS_PACKAGE_JSON`/`Warning` text (§4.3). The
  file is a harmless, pinned seed; only its stated necessity is unsupported on this host.
  Disposition is a record-keeping correction, not a fixture change.
- **F2 (low, host pin class).** The 19 pinned markers embed `node=v24.21.0` (as does every
  other r94 PASS line), so a PATH node change fails all 19 rows **even though the evidence
  cells are v26-identical** (§4.2). Recommend the adjudicator note the version string as a
  marker field of the same class as the godot/blender host pins, with the v24↔v26
  byte-identity recorded as the portability bound.
- **F3 (observation, provenance).** `r94-scout.md` is tracked but landed in the r90-labelled
  sweep commit `6420dc7` (with `r95-scout.md`); the same convention holds for the r91–r93
  and r96 scouts. No defect — recorded so the wave record's commit graph is readable (§7).
- **F4 (observation, custody durability).** The author's rep-sweep/pre-run evidence lived
  only in `/tmp/r94test`; this seat annexed it under `corpus/live/r94-scribe/annex-author-tmp/`.
  The author report's rep-stability section should be read with that annex as its receipt.
- **F5 (low, census scope).** The r94-scout manifest's 456 entries exclude
  `proj/node_modules` (1727 files in-tree), and the boundary manifest's 2888 exclude its
  `scout-replay/` copy (which has its own replayed 456-entry manifest). The *used* engine
  bytes are nonetheless anchored: the author's vendored copies are byte-identical to the
  scout's npm dist files and are battery seed-pinned (71/71). No custody loss.
- **F6 (freshness).** `LOG.md`/`SCORECARD.md` carry no r94 section/row yet (expected
  pre-adjudication).
- **F7 (custody event, not a defect).** `reports/round-94/r94-simplifier.md` appeared
  untracked mid-audit (sibling seat); HEAD unchanged at `05e72ef`; no tracked file
  modified; the §1–§5 checks remain valid for the `05e72ef` artifact set.
- **F8 (observation).** The tracked `r94-scout.md` still states the pre-boundary claims the
  boundary falsified (line 44 `internalStep` purity, line 382 "effective deceleration
  ≈ 15·μg", §4 item 8 "`dt=0`/negative dt NaN-free"); the corrections live in
  `r94-boundary.md` + `r94-author.md` §Corrections + the pins, and the scout report was
  not amended (a fold/record decision, per the boundary's own §14 blocker note). The wave
  record must be read scout → boundary → author; the author report discloses all eight
  corrections explicitly, so no reader of the author report is misled.

## 9. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with a single falsifiable hypothesis — "all 66
r94 child cases produce byte-identical `M` lines and exit codes under node v26.12.0 as
under v24.21.0". It returned **INCONCLUSIVE — not executed**: that seat's tool surface
contained no command-execution tool (the same limitation the r93 scribe recorded), so it
completed read-only reconnaissance of the emission contract only and reported the inability
rather than fabricating results. No writes, no subprocesses. This seat therefore ran the
hypothesis itself as a scribe-side bounded check (§4.2), and it **CONFIRMED**: 66/66
byte-identical. The labrat's static observations (emission contract in source) are
consistent with §2/§3.

## 10. Verified vs pending

**Verified (receipt/artifact-pinned):** scout 456/456, boundary 2888/2888; committed shas
for all 7 r94 files; vendor byte-identity to the scout's npm pins; author run 1/run 2 seed
custody (71/71) and their r94 rows (19/19, byte-identical to the pins and to each other);
the 95-run rep sweep on committed scratch bytes; `284 = 265 + 19 = 231 + 53` with prefix
identity and 0 modified pre-existing rows; `run_battery.py` +38/−0; 66 cells; all 19 pins
rebuilt byte-identically from two independent run trees; `o=0` everywhere, `d=1` only as a
count; canonical NaN hashing; all eight boundary corrections encoded; this seat's
under-load 284-case run (280/284, 19/19 r94, byte-identical to author run 2, seeds
unchanged); node v24↔v26 66/66 byte-identity; `package.json` non-necessity on both
runtimes.

**Pending / for the operator or adjudicator (not blockers for this seat):** F1–F2 are
record-keeping corrections; F3–F8 are observations for the round record. Nothing in this
audit blocks adjudication of `05e72ef`; no fixture, contract, axis, route, or receipt was
mutated, and no commit was made.

## 11. Evidence index

`corpus/live/r94-scribe/` — `RECEIPTS.md`, `manifest.sha256`, `env-at-start.txt`,
`custody/` (both manifest replays + committed shas), `pin-provenance/` (rebuild tool +
both run rebuilds), `rep-sweep/` (verify tool + result), `run12-compare/` (author run 1 vs
run 2 + pin check), `node-variance/` (66×2 case logs, runner, summary), `vendor-package-json-check/`
(no-`package.json` experiment), `annex-author-tmp/` (the `/tmp/r94test` annex),
`battery-committed/20261015T221126799922Z/` (this seat's run: `verdicts.json` +
`scratch/` with per-case child logs), `battery-committed.log`.

Reproduce any cell: `python3 corpus/fixtures/run_battery.py --runs <dir>` (full, 284);
`python3 corpus/live/r94-scribe/pin-provenance/rebuild.py <run>/scratch` (pin rebuild);
`node corpus/fixtures/r94_child.mjs <case>` (single child, one fresh process).
