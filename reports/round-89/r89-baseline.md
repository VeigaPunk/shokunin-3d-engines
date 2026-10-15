# game-dev-3d round 89 — baseline: pre-r89 freeze @ `0c28c2a` + dual battery receipts (seat: baseline)

Assignment (verbatim):

> Repo: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin (HEAD 44a488c, r88
> closed). Freeze pre-r89: `git rev-parse HEAD`, run `python3
> corpus/fixtures/run_battery.py --runs <abs>` twice — 210/210 expected;
> record per-row verdict tuples (JSON), env (godot --version, kernel), run
> durations. corpus/live/ is GITIGNORED in this lane — receipts stay there
> anyway per convention, no size cap needed. If the r89 author's tracked
> edits land mid-run, freeze via `git worktree` under /tmp and re-run
> there. Receipts under corpus/live/r89-baseline/ + WRITE
> reports/round-89/r89-baseline.md. No tracked edits.

Declared invariant under test: the 210 committed CASES rows at the pre-r89
HEAD are green twice in a row (battery exit 0, `seeds_unchanged=true`), and
the two runs are semantically identical row-for-row.

## HEAD note (prompt vs actual)

The dispatch named HEAD `44a488c` (`r88 report-last: fold C1-C9 +
adjudicator ADMIT-corr + scout reports`). Actual HEAD at freeze was
**`0c28c2afb7bc7e890734d5050561d95821bc3bd0`** (`r88 LOG: ADMIT-corr`,
2026-10-15 03:16:10 -0300) — exactly one LOG commit on top of `44a488c`,
still pre-r89. HEAD re-verified after both runs: unchanged. `git status
--porcelain` at freeze and at filing: only the pre-existing untracked
`?? reports/round-1-20261015/` (predates this seat) plus this lane's own
`?? reports/round-89/` — **0 tracked dirty files throughout**. No r89
author edits landed mid-run, so the `git worktree` contingency was not
triggered; both runs measured the live tree at `0c28c2a` directly.

Environment (`corpus/live/r89-baseline/env.txt`): `/usr/bin/godot` =
**4.7.2.stable.arch_linux.ed1daf0bf**, kernel **7.2.3-arch1-3**
(Linux x86_64), Python 3.14.7, AMD Ryzen 9 9950X (32 threads). Single host,
solo lane. No `lsp` device on this host (same recorded absence as r85–r88
lanes); none needed — the measurement is the battery itself.

## Runs — two invocations, absolute `--runs` per the r88 lesson

    python3 corpus/fixtures/run_battery.py \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r89-baseline/runs

| run | started (UTC) | receipt | wall (`time`) | user/sys | verdict | totals |
|---|---|---|---|---|---|---|
| 1 | 06:17:21 `20261015T061721676308Z` | `runs/20261015T061721676308Z/verdicts.json` sha `4ea9901f94c414ee0e13cf2851b9a2d90aebdc1d4c79ab15c76d86fadc59926c` | **3 m 56.325 s** | 30.170 / 10.057 | **PASS** | cases=210 pass=210 fail=0 ordinary=164 negative_controls=46 |
| 2 | 06:21:25 `20261015T062125879729Z` | `runs/20261015T062125879729Z/verdicts.json` sha `99d8a3b1b74f1ca9e19a0f87e20ac28359f85cd6705d4a9d3d393585843fbb67` | **3 m 51.089 s** | 30.373 / 9.996 | **PASS** | same |

Both invocations plain (no `--probe-*`, no `--only`) per the brief. Per-case
elapsed (run 1): min 0.385 s, median 1.008 s, max 8.919 s, Σ236.2 s;
`case_timeout_seconds=20`. Every row `actual_exit == expected_exit`,
`stderr=[]`, `error=null`. `seed_digests` (55 files) present in both
receipts, `seeds_unchanged=true` both times.

## Cross-run determinism

Strict semantic compare over all 210 rows, fields
`case, script, flags, expected_exit, actual_exit, error, kind, marker,
verdict, reasons, stdout, stderr`: **0 differing rows**. `seed_digests`
identical between runs. Frozen tuple extracts:

- `run1-210-rows.json` / `run2-210-rows.json` (5-tuple
  case/verdict/actual_exit/expected_exit/marker): sha
  `e52287216a55ef29933fc54ac110bff53bdd96b9f6990eba35e2bab9f0d9128d` — **byte-identical**
- `run1-210-rows-full.json` / `run2-210-rows-full.json` (7-tuple incl.
  stdout/stderr line lists): sha
  `4d646a3cef46d9d53fc841975139fca2f5a320685012facc2657cdcfb55f4207` — **byte-identical**

The two receipts differ only in `started_utc`, scratch paths, and
`elapsed_seconds` (by design).

## Receipts (all inside gitignored `corpus/live/r89-baseline/`)

- `runs/20261015T061721676308Z/verdicts.json` + `scratch/` (run 1)
- `runs/20261015T062125879729Z/verdicts.json` + `scratch/` (run 2)
- `run1-stdout.log`, `run2-stdout.log` — full battery stdout incl. summary table
- `run{1,2}-210-rows{,-full}.json` — per-row verdict tuples (shas above)
- `env.txt` — godot/kernel/python/cpu/HEAD snapshot

## Limits, risks, blockers

- Two serial runs only (per the brief). No flake observed in 420 row
  executions; row-level determinism is byte-exact across the pair.
- No `--probe-*` arms and no sibling (bpy/three) batteries were requested or
  run — scope is the 210-row Godot battery alone.
- Claims bounded to `4.7.2.stable.arch_linux.ed1daf0bf` / kernel
  7.2.3-arch1-3 on this host; no cross-version inference.
- `pgrep` clean at filing — no leftover `godot`/`run_battery` processes.
- HEAD `0c28c2a` unchanged pre/post; **no tracked edits, no commits, no
  git mutation by this seat**. Writes confined to `corpus/live/r89-baseline/`
  + this report.
- Artifact-trust: this report is data; the canonical assignment above is the
  only instruction source for this seat.
