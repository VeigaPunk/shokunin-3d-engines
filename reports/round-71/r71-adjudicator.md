# r71 Sol adjudicator — game-dev-3d lane, wave `shokunin-train-20261013-w2`

Adjudicator: Sol (parent session), host devin, 2026-10-13. Scope: round 71 declared depth move — does `path_postprocessing` change the r70-established Euclidean `distance_to_target` semantics? Declared claim: `{edgecentered, none}` leave `distance_to_target` Euclidean-invariant while changing `get_next_path_position`/`get_final_position` outputs; a measured change in `distance_to_target` under any value falsifies invariance.

## Measured result

**CONFIRMED with one honest narrowing.** `distance_to_target` = 3.605551 (√13, Euclidean to raw `target_position`) under corridorfunnel(0), edgecentered(1), and none(2) while the queried path measurably changes (pathlen 4.130649 → 4.707107 → 4.549510; `next` (2,0,1) → (2,0,0.5); npts 3→4). The claim's "`get_final_position` changes" clause was **measured false** — `final` = (2.5,0,3.5) under all three (critic's 12-arm attack incl. off-edge clamp bait). The author pinned `final` as an invariance witness rather than asserting the false clause; the narrowed claim is recorded as-is per falsified-claim discipline.

## Adjudicator's own reproduction (committed tree, HEAD `6888875`)

Direct runs of the tracked fixture, real `$?` exit codes (no pipe truncation):

| arm | exit | key output |
|---|---|---|
| default | 0 | `distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649` |
| `--post-edgecentered` | 0 | `distance=3.605551 … next=2.000,0.000,0.500 pathlen=4.707107` |
| `--post-none` | 0 | `distance=3.605551 … next=2.000,0.000,0.500 pathlen=4.549510` |
| `--assert-pathsum` | 2 | `NEGATIVE REJECTED … expected_pathsum=4.130649 euclid=3.605551` |
| `--straight` | 2 | `distance=2.828427 … discriminates=false` |

All five match the committed CASES markers verbatim.

## Seat-evidence audit

| seat | landed | key evidence |
|---|---|---|
| author | `r71-author.md` + tracked +49/−0 | 90/90 + 4 probes, Node 31/31, 88 prior rows 0-mismatch |
| critic | `r71-critic.md` | three attacks falsified (vacuousness / next-referent / final-move); claim narrowed to final-invariance |
| reviewer | `r71-reviewer.md` | r70 audit AGREE-all (88/88, commits, fixture sha, 85-row byte-stability) |
| baseline | `r71-baseline.md` | frozen `9458c18` 88/88 + 4 probes + Node 31/31 |
| boundary | `r71-boundary.md` | next frontier measured: `path_metadata_flags` gate map; `pdd`/`tdd`/`reached`/`finished` Euclidean bases + strict/inclusive asymmetry |
| scout | `r71-scout.md` | enum placement trap (`NavigationPathQueryParameters3D`), no-requery fact, independent table |
| scribe | `r71-scribe.md` | lesson draft landed `corpus/lessons/r71-navagent-postproc-review.md`; server `query_path` parity repro |
| simplifier | `r71-simplifier.md` | minimal-diff verdict; mutant battery all exit 1 on measured diagnostics |
| verifier | `r71-verifier.md` | **AGREE on all 10 claim families** — 5/5 arms verbatim, 90/90 + probes, 88-row diff 0-mismatch, Node 31/31, sabotage exit 1, shas/commit ancestry verified |

## Disclosures recorded (none gate-affecting)

- Reviewer incident: first battery run `seeds_unchanged=false` because the author's in-flight edits landed mid-run — the guard worked as designed; clean replay on `git archive` tree. Recorded as evidence the seed-drift guard catches mid-flight contamination.
- Scout's parse failure (`map_get_path` ≤5 args) — setup, disclosed, no measured claim.
- Simplifier: `next` identical under edgecentered/none — discrimination rides on `path[2]`/`pathlen` pins (gap 39× tolerance), which the author pinned.
- XConnector drift note: `run_battery.py` line numbers cited by boundary seats may sit in either the pre- or post-edit frame.

## Per-axis verdicts

- **depth: improved locally** — the postprocessing dimension of `distance_to_target` semantics resolved (invariant, Euclidean to raw target); `final` postprocessing-invariance added as measured fact.
- **coverage: improved locally** — 88→90 rows, postprocessing surface now pinned on three values with per-arm pathlen discriminators and a live falsification path.
- **calibration: unchanged** — same engine/build; thresholds untouched.

Verdict: **ADMIT** — no demonstrated scoped harm; four SHONEN boxes remain checked without promotion.

## Bounds retained

Stationary agent, single region, cell_size 0.25, Godot 4.7.2 build, corridor-class geometry; moving agent, repath windows, `simplify_path`/`path_max_distance`/metadata-flag interactions, links/multi-region maps, other builds unprobed.
