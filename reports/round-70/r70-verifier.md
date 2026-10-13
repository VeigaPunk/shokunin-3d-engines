# Game-dev-3d round 70 — independent non-author verification (host: devin)

Verifier did not author any r70 content. Author report:
`.shokunin/game-dev-3d/reports/round-70/r70-author.md`; work commit
`2a0e46f` (HEAD~1), report commit `0ea70cf` (HEAD). Engine:
`4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`; Node v24.21.0;
three.js 0.186.1 (`node_modules` already provisioned in
`corpus/fixtures/three/`).

All scratch writes confined to `corpus/live/r70-verifier/`; this report is the
only other write. No git mutations.

## 1. Commit shape — AGREE

- `git show --stat HEAD~1` (`2a0e46f`, the r70 work commit): 9 files,
  +1084/−0 — `corpus/fixtures/navagent3d_detour.gd` +137,
  `corpus/fixtures/run_battery.py` +6 (exactly the three declared CASES
  tuples, two lines each), seven `reports/round-70/r70-*.md` files. No
  deletions, no unrelated edits.
- `git show --stat HEAD~2` (`e054cfe`): unrelated `Revert "HOURS.md…"`
  (−19 lines, HOURS.md/LOG.md only) — pre-r70 state.
- `git show --stat HEAD` (`0ea70cf`): `r70-simplifier.md` +124 only.
- `git diff HEAD~2 HEAD -- corpus/fixtures/run_battery.py | grep '^-'`:
  the only match is the `--- a/…` diff header — **zero removed content
  lines**. ✓
- `git status --porcelain` at verify time: clean (empty output).

## 2. Full battery replay — AGREE (PASS 88/88 + 4 probes)

Command (run from the worktree so `.shokunin/game-dev-3d/` resolves into the
canonical repo; `--runs` absolute per the r69 caveat):

    cd ~/Projects/prymeagnt/game-dev-3d && \
      python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py \
      --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r70-verifier/runs \
      --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing

- Exit **0**. Tail verbatim:
  `totals: cases=88 pass=88 fail=0 ordinary=43 negative_controls=45 probes=4`
  `PASS battery: …/corpus/live/r70-verifier/runs/20261013T230627836811Z/verdicts.json`
- Receipt `corpus/live/r70-verifier/runs/20261013T230627836811Z/verdicts.json`:
  `verdict: PASS`, `results: 88`, `seeds_unchanged: true`,
  `godot_version: 4.7.2.stable.arch_linux.ed1daf0bf` (same build as baseline),
  `crash_probe_ok/stream_probe_ok/tree_probe_ok: true`, mutation probe
  `verdict: PASS` (`mutant_body3d_contact` rejected, expected diagnostic).
- The three new rows pass exactly as declared:
  `navagent3d_detour` exit 0; `navagent3d_detour_straight` exit 2;
  `navagent3d_detour_assert_pathsum` exit 2 — markers byte-exact vs CASES.

## 3. Prior-85-row field comparison vs frozen baseline — AGREE (0 mismatches)

**Comparison run:** the named frozen baseline receipt **is present on disk**
at `corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json` but is
**gitignored, not committed** (`git check-ignore` → IGNORED; `git ls-files
corpus/live` → empty). Per dispatch fallback this is the "else" case; I
compared against it directly anyway (stronger than the lessons-ledger
reconstruction — it is the exact artifact the claim names).

Script: per-case field equality on the 11 raw fields the author names —
`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr` — over all 85 baseline case names against my run.

- **0 mismatches over 85 cases × 11 fields**; shared-row ordering identical.
- New cases in my run are exactly the three declared rows
  (`navagent3d_detour{,_straight,_assert_pathsum}`); none missing.
- Seed map 51→52 keys: only added key `navagent3d_detour.gd`; only changed
  digest `run_battery.py` (the intended +6-line edit). All other 50 digests
  unchanged, including `navagent3d_distance.gd` =
  `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a` (matches
  the r69-era value cited in `r70-baseline.md`).
- Digest cross-check vs report-cited values: my receipt's
  `navagent3d_detour.gd` sha256 =
  `669c539d0bb38c82184f1b39df0a4d70059276e532def125438f352899a7fc45` and
  `run_battery.py` sha256 =
  `5a7d6c13ac4a24960ce8f24bcc45b24a65da31919e78b5cc5934e3c248a79dee` — both
  match the digests quoted in the r70 seat reports.

Caveat on scope: "byte-identical" holds on the raw case fields; volatile
envelope fields (`command` paths, `elapsed_seconds`, run stamp) necessarily
differ between runs — the author's claim is correctly read as the 11 named
fields, which is what was compared.

## 4. DISCERNMENT spot-checks — AGREE (both verbatim)

Scratch project = `corpus/live/r70-verifier/spotcheck/` (copy of
`project.godot` + `navagent3d_detour.gd`), invoked exactly as the runner
does (`godot --headless --path <scratch> --script res://<script> -- <flags>`).

Admitted arm:

    /usr/bin/godot --headless --path . --script res://navagent3d_detour.gd --
    → exit 0
    PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false

(distance=3.605551 ✓, semantic=euclidean ✓, next=2.000,0.000,1.000 ✓,
pathlen=4.130649 ✓ — every declared field present verbatim.)

Rejected arm:

    /usr/bin/godot --headless --path . --script res://navagent3d_detour.gd -- --assert-pathsum
    → exit 2
    NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551

Additional arm (not required, run for completeness):

    … -- --straight → exit 2
    NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false

Fixture audit (read, not just replayed): the discrimination is sound —
`distance_to_target()` is classified against two authored candidates with
0.004 tolerance; the detour path's measured 3-point path (bend forced through
portal vertex (2,0,1), `path.size()==3` asserted) sums 4.130649 =
√2.5+√6.5, a 0.525 gap ≈131× tolerance from Euclidean √13=3.605551. The
`--straight` control correctly cannot discriminate (Euclidean = path-sum =
2.828427 on the r69 single-quad geometry), and `--assert-pathsum` correctly
exercises the refuted hypothesis. Hand-check of the geometry math confirms
all four constants.

## 5. Node three.js suites — AGREE (31/31, all seeds_unchanged)

    cd corpus/fixtures/three && for s in cases layer_cases order_cases \
      camera_cases ortho_cases ray_cases; do \
      node run_${s}.mjs --receipt ../../live/r70-verifier/runs/node/run_${s}.json; done

| suite | result | seeds_unchanged | exit |
| --- | --- | --- | --- |
| run_cases | 3/3 PASS | true | 0 |
| run_layer_cases | 4/4 PASS | true | 0 |
| run_order_cases | 9/9 PASS | true | 0 |
| run_camera_cases | 5/5 PASS | true | 0 |
| run_ortho_cases | 5/5 PASS | true | 0 |
| run_ray_cases | 5/5 PASS | true | 0 |

Total **31/31 PASS**, every suite `seeds_unchanged=true`. Receipts:
`corpus/live/r70-verifier/runs/node/run_*.json`.

## 6. Secrets/credentials scan — CLEAN

Scanned all 1218 added lines of `git diff HEAD~2 HEAD` for credential
patterns (api[_-]key, secret, token, password, bearer, private-key blocks,
ghp_/glpat_/AKIA/sk-/eyJ prefixes, URL-embedded userinfo, high-entropy
base64, 64-hex). Hits were exclusively benign: the words "author/authored",
commit SHAs, and sha256 content digests quoted in reports. No credentials.

## Claim-by-claim verdict

| # | Author claim | Verdict |
| --- | --- | --- |
| 1 | `distance_to_target` = Euclidean to raw authored `target_position` (3.605551 = √13), r69 UNKNOWN resolved | **AGREE** — independently reproduced; bend witness + pathlen 4.130649 both observed |
| 2 | New `navagent3d_detour.gd` + 3 CASES rows | **AGREE** — exact shape, +137/+6 lines |
| 3 | Full battery 88/88 with 4 probes | **AGREE** — exit 0, PASS, all probes ok |
| 4 | Prior 85 rows byte-identical vs frozen baseline | **AGREE** — 0 mismatches on all 11 named raw fields (vs on-disk gitignored baseline receipt; see §3 caveat) |
| 5 | Node suites 31/31, seeds_unchanged | **AGREE** |
| 6 | No secrets in added lines | **AGREE** — clean |

## Caveats / residual UNKNOWNs

- The frozen baseline receipt is gitignored: byte-stability evidence rests on
  an on-disk artifact that could be regenerated or drift unobserved. Mitigated
  here by independent re-derivation — my 85 prior rows match it on every raw
  field, and the seed digest map matches the r69-era cited values.
- The Euclidean claim remains bounded to Godot 4.7.2 headless, stationary
  agent at path start, default CORRIDORFUNNEL postprocessing — the fixture
  itself asserts these preconditions; no overclaim in the marker strings.
- Report is a recommendation; admission belongs to the parent judge.
