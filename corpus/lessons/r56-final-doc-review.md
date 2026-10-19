# r56 final README correction — independent verification (2026-10-13)

**PASS, bounded.** I did not author commits `3f48f71ce41c285cf410a9a53b3a46438d45bb80` or `69cf9b2e101223bd245362d15a956145d4900f3d`. HEAD during this review was `69cf9b2`. `git diff --name-status 3f48f71 69cf9b2` names only `corpus/fixtures/README.md`; `git show 69cf9b2` changes just its opening `81 registered cases (39 ordinary` to `82 registered cases (40 ordinary`, retaining `42 negative controls`. The corrected opening now states **82 registered cases (40 ordinary, 42 negative controls)**. Parsing the actual `CASES` list in `corpus/fixtures/run_battery.py` independently yielded 82 entries, of which 40 have expected exit 0 and 42 expected exit 2.

From repository root I ran:

```sh
python3 corpus/fixtures/run_battery.py --only camera3d_ortho_near_boundary_exact,camera3d_ortho_near_boundary_inside,camera3d_ortho_near_boundary_outside
```

Runner process exit **0**. Raw receipt: `corpus/live/runs/20261013T122808952501Z/verdicts.json`, reporting `verdict=PASS`, `totals={cases:3, pass:3, fail:0, ordinary:2, negative_controls:1}`, `seeds_unchanged=true`, Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Every case has `verdict=PASS`, `error=null`, `reasons=[]`, `stderr=[]`; stdout is the engine banner, an empty line, then its exact marker:

- `camera3d_ortho_near_boundary_exact`: actual/expected exit **0/0**; `PASS camera3d_ortho near_boundary_exact depth=1.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false`.
- `camera3d_ortho_near_boundary_inside`: **0/0**; `PASS camera3d_ortho near_boundary_inside depth=1.010 screen=550.000,225.000 in_frustum=true outside_control=false`.
- `camera3d_ortho_near_boundary_outside`: **2/2**; `NEGATIVE REJECTED: camera3d_ortho near_boundary_outside depth=0.990 screen=550.000,225.000 in_frustum=false api_behind=true inside_control=true`.

The current receipt lists 50 seed digests. Compared to the prior full receipt `corpus/live/runs/20261013T122425975429Z/verdicts.json`, only `README.md` differs: SHA-256 `744e0fafd27a29490ccc38e991073096df18e5cd2cd4acc10b6cddc64dc9135f` → `8ff28c04fa9ccf317288efecb23913f1178f152f753ad81ee4f580210c5eb7cf`; the other 49 seeds agree. The three current raw markers also match those in the earlier full receipt.

**Attribution caveat:** The earlier independent full **82/82 plus four probes** PASS receipt and `corpus/lessons/r56-exact-near-review.md` were made before the README correction, at work commit `3f48f71`. They do **not** establish a full battery/probe run on `69cf9b2`; only the three focused cases above were rerun after correction. This final check proves the documented count matches registered cases and the focused runtime result survives the documentation-only change, not broader rendered output or floating-point portability. I wrote only this review file; no commit, push or merge.

## r106 path-root conformance (2026-10-18)

Mechanical re-root only (SEAT-08). Every `.shokunin/game-dev-3d/` prefix above was removed so citations are repo-relative from this lane root. Historical totals, markers, and SHA-256 digests were not rewritten. This note is not a re-run of the 2026-10-13 review.

Still non-resolvable (queued, not rewritten): cited `corpus/live/runs/20261013T…` receipts are gitignored (`corpus/.gitignore` `live/`) and absent. Commits `3f48f71` and `69cf9b2` resolve in `/home/vgpnk/Projects/prymeagnt/game-dev-3d`, not in this lane repo. The 82-case count is the count at that commit, not the current runner. Sweep evidence: `reports/round-106/sweep/chunk-08.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T122808952501Z/verdicts.json`
> - `corpus/live/runs/20261013T122425975429Z/verdicts.json`
