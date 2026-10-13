# Round 53 README reproduction — independent LEAF review

Reviewer: `game-dev-3d-r53-doc-review`, non-author of r53 and r1. From repository root, without setup beyond documented host Python 3 and `/usr/bin/godot` 4.7.2, I ran these README commands verbatim; each exited 0:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only raycast3d_hit,raycast3d_miss
```

Fresh ignored `verdicts.json` receipts, in command order (relative to `.shokunin/game-dev-3d/corpus/live/runs/`):

- `20261013T110309648860Z/verdicts.json` SHA-256 `0b9ba8490c248db673656030c9012bcf33edef8dc20e01b517dc0f98236f026c`: 77/77 PASS, 37 ordinary, 40 negative, 0 probes.
- `20261013T110309648060Z/verdicts.json` SHA-256 `7099619581795752be3cd63600450b5a6818ff531699d70af1e3d9b5a70c234a`: 77/77 PASS, 37 ordinary, 40 negative, 4 probes. Its `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `tree-timeout-verdicts.json`, `mutation-verdicts.json` each report PASS. Mutation record intentionally has actual exit 1, expected ordinary exit 0, no PASS marker and a diagnostic on stderr; probe verdict PASS means the rejection was detected, not that the mutant passed.
- `20261013T110309648503Z/verdicts.json` SHA-256 `fd1b04a535983b9f4825bee23df7949880b814c30599c0670ee3db01f8cbc566`: 2/2 PASS, one ordinary/one negative, no probes. `raycast3d_hit`: actual/expected 0/0; exact marker `PASS raycast3d hits=1 position=0.000,2.000,0.000 normal=0.000,1.000,0.000 collider=Wall collider_id_matches=true miss_hits=0`. `raycast3d_miss`: actual/expected 2/2; exact marker `NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 control_position=0.000,2.000,0.000 miss_from=0.000,6.000,9.000 miss_hits=0 miss_offset_z=9.000 box_half_depth_z=2.000`.

For **each** of the 77 results in both full receipts and each subset result, inspected `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`: actual equals expected (ordinary 0; negative 2), verdict PASS, empty error/reasons/stderr, and exact marker appears once in stdout (alongside the Godot version banner). No classification or stream mismatch. All three report `seeds_unchanged=true` and identical `seed_digests`; each digest matches the current seed file SHA-256. Against obtainable r52 raw receipt `corpus/live/runs/20261013T083258787449Z/verdicts.json` (also reproducible via the combined README command), all 77 complete raw fields above match in order. The **only** r52-to-r53 seed digest change is `README.md`: `8ba4191e8d9823698ab433d216ba657c528b2820f1e69672d693cdaf44e6fc74` → `50826090cdc664fbb4ddfa99f83d91594002d046a21b04595a34b2ce51fbad5b`.

Verdict: README instructions reproduce the stated current totals and unchanged behavior without undocumented setup on this host. No falsification observed. Scope is this pinned Godot/Linux environment and finite headless fixtures, not other machines, engines or rendered output. Sole tracked write: this review; no code/README/LOG/manifest edits or commit.
