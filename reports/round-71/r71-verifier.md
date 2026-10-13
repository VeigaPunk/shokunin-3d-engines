# Game-dev-3d round 71 — independent non-author verification (host: devin)

Verifier did not author any r71 content. Claim under test (committed at
HEAD `6888875`, the r71 integration commit):
`NavigationAgent3D.distance_to_target()` is Euclidean to the raw
`target_position` and **invariant** under `path_postprocessing` in
{corridorfunnel(0), edgecentered(1), none(2)} on the L-corridor detour —
distance=3.605551 under all three while pathlen changes
4.130649→4.707107→4.549510 and next changes (2,0,1)→(2,0,0.5);
`final`=(2.5,0,3.5) postprocessing-invariant. Author report:
`reports/round-71/r71-author.md`; before-state baseline:
`reports/round-71/r71-baseline.md` at `9458c18`.

Engine: `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`; Python
3.14.7; Node v24.21.0; three.js 0.186.1 (pre-provisioned
`corpus/fixtures/three/node_modules`).

All scratch writes confined to `corpus/live/r71-verifier/` (gitignored);
this report is the only other write. No git mutations (leaf: no
commit/push/checkout/stash).

## 1. Commit shape — AGREE

- `git show --stat 6888875`: 8 files, +933/−0 —
  `corpus/fixtures/navagent3d_detour.gd` **+45** (purely additive post
  arms), `corpus/fixtures/run_battery.py` **+4** (exactly the two
  declared CASES tuples), six `reports/round-71/r71-*.md` files
  (author/baseline/critic/reviewer/scout/simplifier). No deletions, no
  unrelated edits, no out-of-scope paths.
- `git status --porcelain` at verify time: only untracked
  `?? reports/round-71/r71-scribe.md` and `?? reports/round-71/r71-boundary.md`
  (sibling-seat reports in flight, outside the committed claim); **zero
  modified tracked files** — the tree I replayed is the committed tree.
- Cited commits resolve and are ancestors of HEAD in the canonical repo:

  | short | full | `merge-base --is-ancestor <c> HEAD` |
  |---|---|---|
  | `2a0e46f` | `2a0e46f5094b8d0543cdb86b529700260df7f442` | true (r70 work) |
  | `9458c18` | `9458c183988c8428503b9287d51cd86f7a48378b` | true (r70 adjudication / r71 before-state) |
  | `6888875` | `6888875741143180f6b130321ce0a35a77518ef0` | true (= HEAD, r71 integration) |

- Fixture sha256 `5b873cd0…` verified three ways and identical:
  `sha256sum corpus/fixtures/navagent3d_detour.gd`,
  `git cat-file blob HEAD:corpus/fixtures/navagent3d_detour.gd`, and the
  author's cited value — all
  `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647`.
  `run_battery.py` sha256
  `b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809`
  likewise matches the cited value (was `5a7d6c13…` at r70 baseline).

## 2. Direct fixture arms — AGREE (5/5 verbatim, real exit codes)

Scratch project `corpus/live/r71-verifier/spotcheck/` (copy of committed
`project.godot` only). The **tracked fixture file itself** was invoked by
absolute path — no copy, no res:// indirection:

    /usr/bin/godot --headless --path . \
      -s /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/fixtures/navagent3d_detour.gd [-- --arm]; echo "EXIT=$?"

| arm | exit | stdout (verbatim, minus engine banner) |
|---|---|---|
| (default) | **0** | `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false` |
| `--post-edgecentered` | **0** | `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false` |
| `--post-none` | **0** | `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false` |
| `--assert-pathsum` | **2** | `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551` |
| `--straight` | **2** | `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false` |

Every field of the committed claim is reproduced verbatim:
`distance=3.605551` identical under all three postprocessing values while
`pathlen` measures 4.130649 / 4.707107 / 4.549510 (three distinct queried
paths — the knob demonstrably took effect, so the invariance
discrimination is non-vacuous), `next` (2,0,1)→(2,0,0.5) under both
non-default values, `final=2.500,0.000,3.500` invariant — consistent with
the committed claim's own narrowing ("final changes" measured false;
final pinned as invariance witness).

## 3. Full battery replay — AGREE (PASS 90/90 + 4 probes)

Command (from the worktree so `.shokunin/game-dev-3d/` resolves into the
canonical repo; `--runs` absolute per the r69 caveat):

    cd ~/Projects/prymeagnt/game-dev-3d && \
      python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py \
      --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-verifier/runs \
      --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing

- Exit **0**. Tail verbatim:
  `totals: cases=90 pass=90 fail=0 ordinary=45 negative_controls=45 probes=4`
  `PASS battery: …/corpus/live/r71-verifier/runs/20261013T235428282427Z/verdicts.json`
- Receipt `runs/20261013T235428282427Z/verdicts.json`: `verdict: PASS`,
  `results: 90` (`Counter({'PASS': 90})`), `seeds_unchanged: true`,
  `godot_version: 4.7.2.stable.arch_linux.ed1daf0bf` (same build as
  baseline). All 90 stdout markers byte-exact vs CASES.
- Probes, all PASS with own receipts in the run dir: `crash_probe_ok:
  true`, `stream_probe_ok: true`, `tree_probe_ok: true` (verified
  detached-witness cleanup), mutation probe `detected: true`
  (`mutant_body3d_contact` exit 1 with the expected contact-plane
  diagnostic, `seeds_unchanged: true`, probe verdict PASS).
- The two new rows pass exactly as declared:
  `navagent3d_detour_post_edgecentered` exit 0,
  `navagent3d_detour_post_none` exit 0 — markers byte-exact vs the CASES
  literals.

## 4. Prior-88-row 11-field diff vs frozen baseline — AGREE (0 mismatches)

    python3 corpus/live/r71-verifier/diff_baseline.py \
      corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json \
      corpus/live/r71-verifier/runs/20261013T235428282427Z/verdicts.json

Per-case equality on the 11 raw fields the author names — `case, script,
flags, expected_exit, actual_exit, kind, marker, verdict, reasons,
stdout, stderr` — over all 88 baseline case names. Output verbatim:

    baseline rows: 88  my rows: 90
    compared cases: 88 x 11 fields
    mismatches: 0
    extra cases in my run: ['navagent3d_detour_post_edgecentered', 'navagent3d_detour_post_none']
    missing cases in my run: []
    shared-row ordering identical: True
    seed keys: baseline=52 mine=52 added=[] removed=[] changed=['navagent3d_detour.gd', 'run_battery.py']

**0 mismatches over 88 cases × 11 fields**; extras are exactly the two
declared post arms; ordering identical. Seed map 52→52: no added/removed
keys, the only changed digests are `navagent3d_detour.gd` and
`run_battery.py` — the intended r71 edits, matching the author claim.

Caveat carried forward from r70: the baseline receipt is gitignored,
on-disk only — it is nonetheless the exact artifact the claim names, and
my independently generated rows agree with it on every raw field.

## 5. Node three.js suites — AGREE (31/31, all seeds_unchanged)

    cd corpus/fixtures/three && for s in cases layer_cases order_cases \
      camera_cases ortho_cases ray_cases; do \
      node run_${s}.mjs --receipt ../../live/r71-verifier/runs/node/run_${s}.json; done

| suite | result | seeds_unchanged | exit |
| --- | --- | --- | --- |
| run_cases | 3/3 PASS | true | 0 |
| run_layer_cases | 4/4 PASS | true | 0 |
| run_order_cases | 9/9 PASS | true | 0 |
| run_camera_cases | 5/5 PASS | true | 0 |
| run_ortho_cases | 5/5 PASS | true | 0 |
| run_ray_cases | 5/5 PASS | true | 0 |

Total **31/31 PASS**, every suite `seeds_unchanged=true`, every exit 0.
Receipts: `corpus/live/r71-verifier/runs/node/run_*.json`.

## 6. DISCERNMENT sabotage — AGREE (exit 1, falsification line verbatim)

Own scratch copy `corpus/live/r71-verifier/sabotage/` (`project.godot` +
`navagent3d_detour.gd`; tracked fixture **untouched**, sha stays
`5b873cd0…`). One-line mutation forcing the routed-path semantic:

    var distance := pathlen  # SABOTAGE: path-sum substitution   (mutant sha 7ddf4be3…)

    /usr/bin/godot --headless --path . -s res://navagent3d_detour.gd

Output (stderr, verbatim):

    ERROR: navagent3d_detour: measured semantic=path_sum not euclidean distance=4.130649 pathlen=4.130649
       at: push_error (core/variant/variant_utility.cpp:1023)
       GDScript backtrace (most recent call first):
           [0] _fail (res://navagent3d_detour.gd:180)
           [1] _run (res://navagent3d_detour.gd:165)
    EXIT=1

The classifier caught the substitution at the authored falsification path
(`semantic != "euclidean"` → `_fail` → exit 1, no PASS marker). The
distance measurement is a real engine query, not a restated literal —
discernment confirmed independently of the runner's own mutation probe.

## 7. Secrets/credentials scan — CLEAN

All 941 `+` lines of `git show 6888875` scanned for credential patterns
(api[_-]key, secret, token, password, bearer, private-key blocks,
ghp_/glpat_/AKIA/sk-/eyJ prefixes, URL-embedded userinfo): zero hits.

## Claim-by-claim verdict

| # | Committed claim | Verdict |
| --- | --- | --- |
| 1 | `distance_to_target` Euclidean to raw `target_position`, **invariant** under `path_postprocessing` {0,1,2}: distance=3.605551 under all three | **AGREE** — reproduced verbatim on the tracked fixture by absolute path; same build |
| 2 | Path measurably reshaped per value: pathlen 4.130649→4.707107→4.549510, next (2,0,1)→(2,0,0.5), 3→4 points | **AGREE** — all three path shapes distinct; discrimination non-vacuous (convergent with critic's independent probe) |
| 3 | `final`=(2.5,0,3.5) postprocessing-invariant | **AGREE** — identical in all three arms |
| 4 | Fixture +45 additive, run_battery.py +4 (two CASES rows), commit `6888875` shape | **AGREE** — exact stat; sha256 `5b873cd0…`/`b4b31499…` match cited |
| 5 | Full battery 90/90 + 4 probes, seeds_unchanged, mutant detected | **AGREE** — exit 0, receipt PASS, all probes ok |
| 6 | 88 prior rows 0-mismatch vs frozen baseline | **AGREE** — 88×11 fields identical, extras exactly the 2 declared arms, seed map 52→52 with only the 2 declared digest changes |
| 7 | Negative arms: `--assert-pathsum` exit 2, `--straight` exit 2 (2.828427) | **AGREE** — verbatim |
| 8 | Node six suites 31/31, seeds_unchanged | **AGREE** |
| 9 | Falsification path live | **AGREE** — own sabotage `distance:=pathlen` → exit 1 with measured diagnostic |
| 10 | No secrets in added lines | **AGREE** — clean |

## Caveats / residual UNKNOWNs

- Bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, the
  authored L-corridor, a stationary agent at path start, default
  desired-distances — the fixture asserts these preconditions; no
  overclaim in markers.
- `next` is identical under edgecentered(1) and none(2) on this geometry;
  the arms are separated by `path[2]`/`pathlen` (4.707107 vs 4.549510,
  ~39× tol). The fixture pins all of path.size/next/pathlen/final per
  arm, so a flag that did not take effect cannot pass — sound.
- The frozen baseline receipt is gitignored/on-disk (carried from r70);
  mitigated by full independent re-derivation (my 88 rows match every raw
  field) and by the seed-digest map matching cited values.
- r68/r69 `navagent3d_retarget` intermittence did not manifest in my
  full run; caveat stands unretracted.
- Two untracked sibling reports (`r71-scribe.md`, `r71-boundary.md`)
  present in the tree at verify time; they are outside the committed
  claim and did not affect replay (no tracked file modified).
- Report is a recommendation; admission belongs to the parent judge.
