# Round 53 README reproduction — independent LEAF review

Reviewer: `game-dev-3d-r53-doc-review`, non-author of r53 and r1. From repository root, without setup beyond documented host Python 3 and `/usr/bin/godot` 4.7.2, I ran these README commands verbatim; each exited 0:

```sh
python3 corpus/fixtures/run_battery.py
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 corpus/fixtures/run_battery.py --only raycast3d_hit,raycast3d_miss
```

Fresh ignored `verdicts.json` receipts, in command order (relative to `corpus/live/runs/`):

- `20261013T110309648860Z/verdicts.json` SHA-256 `0b9ba8490c248db673656030c9012bcf33edef8dc20e01b517dc0f98236f026c`: 77/77 PASS, 37 ordinary, 40 negative, 0 probes.
- `20261013T110309648060Z/verdicts.json` SHA-256 `7099619581795752be3cd63600450b5a6818ff531699d70af1e3d9b5a70c234a`: 77/77 PASS, 37 ordinary, 40 negative, 4 probes. Its `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `tree-timeout-verdicts.json`, `mutation-verdicts.json` each report PASS. Mutation record intentionally has actual exit 1, expected ordinary exit 0, no PASS marker and a diagnostic on stderr; probe verdict PASS means the rejection was detected, not that the mutant passed.
- `20261013T110309648503Z/verdicts.json` SHA-256 `fd1b04a535983b9f4825bee23df7949880b814c30599c0670ee3db01f8cbc566`: 2/2 PASS, one ordinary/one negative, no probes. `raycast3d_hit`: actual/expected 0/0; exact marker `PASS raycast3d hits=1 position=0.000,2.000,0.000 normal=0.000,1.000,0.000 collider=Wall collider_id_matches=true miss_hits=0`. `raycast3d_miss`: actual/expected 2/2; exact marker `NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 control_position=0.000,2.000,0.000 miss_from=0.000,6.000,9.000 miss_hits=0 miss_offset_z=9.000 box_half_depth_z=2.000`.

For **each** of the 77 results in both full receipts and each subset result, inspected `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`: actual equals expected (ordinary 0; negative 2), verdict PASS, empty error/reasons/stderr, and exact marker appears once in stdout (alongside the Godot version banner). No classification or stream mismatch. All three report `seeds_unchanged=true` and identical `seed_digests`; each digest matches the current seed file SHA-256. Against obtainable r52 raw receipt `corpus/live/runs/20261013T083258787449Z/verdicts.json` (also reproducible via the combined README command), all 77 complete raw fields above match in order. The **only** r52-to-r53 seed digest change is `README.md`: `8ba4191e8d9823698ab433d216ba657c528b2820f1e69672d693cdaf44e6fc74` → `50826090cdc664fbb4ddfa99f83d91594002d046a21b04595a34b2ce51fbad5b`.

Verdict: README instructions reproduce the stated current totals and unchanged behavior without undocumented setup on this host. No falsification observed. Scope is this pinned Godot/Linux environment and finite headless fixtures, not other machines, engines or rendered output. Sole tracked write: this review; no code/README/LOG/manifest edits or commit.

## r106 path-root conformance (2026-10-18)

Mechanical re-root only (SEAT-08). Every `.shokunin/game-dev-3d/` prefix above was removed so citations are repo-relative from this lane root. Historical totals, markers, and SHA-256 digests were not rewritten. This note is not a re-run of the 2026-10-13 review.

Still non-resolvable (queued, not rewritten): cited `corpus/live/runs/20261013T…` receipts are gitignored (`corpus/.gitignore` `live/`) and absent on disk. The sentence that each digest matches the then-current seed file is a 2026-10-13 claim, not a re-measurement. Sweep evidence: `reports/round-106/sweep/chunk-08.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T110309648860Z/verdicts.json`
> - `corpus/live/runs/20261013T110309648060Z/verdicts.json`
> - `corpus/live/runs/20261013T110309648060Z/crash-exit-verdicts.json`
> - `corpus/live/runs/20261013T110309648060Z/stream-attribution-verdicts.json`
> - `corpus/live/runs/20261013T110309648060Z/tree-timeout-verdicts.json`
> - `corpus/live/runs/20261013T110309648060Z/mutation-verdicts.json`
> - `corpus/live/runs/20261013T110309648503Z/verdicts.json`
> - `corpus/live/runs/20261013T083258787449Z/verdicts.json`
