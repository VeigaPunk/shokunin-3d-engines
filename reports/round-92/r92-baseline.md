# game-dev-3d round 92 — BASELINE: frozen-tree regression replay @ `c218823`, dual receipt (seat: baseline)

Assignment (`.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r92-baseline.md`,
verbatim):

> # r92 BASELINE (g3d) — frozen-tree regression replay
>
> Repo: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD at
> dispatch = reconcile commit `c218823` (pin the sha you froze).
>
> Copy the tracked tree into `corpus/live/r92-baseline/tree/` (do not
> mutate the worktree). Run `corpus/fixtures/run_battery.py` inside the
> frozen tree **twice** (see `reports/round-90/`/`r91` baseline reports or
> the battery README for the established invocation; backend projects are
> generated per battery convention).
>
> Report: rows replayed, byte-identical count vs committed receipts, drift
> rows named individually. Write `reports/round-92/r92-baseline.md`.
> Scratch only under `corpus/live/r92-baseline/`. No tracked writes, no
> commits. All godot runs `timeout`-bounded and `--headless`.

Declared invariant under test: the **235 committed CASES rows** at the
dispatched HEAD are green twice in a row inside the frozen tree (battery exit
0, `seeds_unchanged=true`), and the two receipts are semantically identical
row-for-row against the committed expectations.

## Headline

| measure | value |
|---|---|
| **rows replayed** | **235** (189 ordinary + 46 negative controls), twice |
| **byte-identical count vs committed receipts** | **235 / 235** |
| **drift rows** | **none — 0 / 235** (run1↔run2, run1↔committed CASES, run1↔prior r91 receipt) |
| battery verdict | **PASS** both runs, exit 0, `seeds_unchanged=true` |

## HEAD note (prompt vs actual, and a mid-seat report-only move)

- Dispatch named HEAD `c218823`; actual HEAD at freeze was
  **`c21882354418ae5623bb3a5a053393495c4ef19a`**
  (`reconcile: late r90 critic+boundary reports + round-1 advisory record +
  forward scout reports r96-r98`) — the dispatched sha, exact. `git status
  --porcelain` at freeze: **0 lines** (no tracked dirty, no untracked).
- **HEAD moved mid-seat**, exactly the contingency the freeze step exists for:
  at filing HEAD = **`91ce055ae3e3f2e041792bf302d896beddf77f21`** (`r92
  boundary: notify_transform kill verdict …`, landed by the *boundary* seat
  while run 1 was executing). `git diff --stat c218823..HEAD` = **1 file
  changed, 342 insertions** — `reports/round-92/r92-boundary.md` only. No
  fixture, runner, or project byte moved.
- The frozen tree was **not** invalidated: the 3-way fixture digest compare
  (frozen tree vs live worktree vs current `HEAD` blob) re-run *after* both
  batteries is **59/59 files, 0 mismatches** — the frozen bytes are byte-equal
  to what `HEAD` carries now, so this baseline holds for both `c218823` and
  `91ce055`.
- **No tracked edits, no commits by this seat.** The only tracked write is
  this report file.

Environment (`corpus/live/r92-baseline/env.txt`, sha
`653efda942a656be28e843c44d5da0648b75038b8e582e17503519d3be7c9f25`):
`/usr/bin/godot` = **4.7.2.stable.arch_linux.ed1daf0bf**, kernel
**7.2.3-arch1-3** (Linux x86_64), Python 3.14.7, AMD Ryzen 9 9950X (32
threads). Single host. No `lsp` device is exposed to this seat's toolset
(same recorded absence as the r85–r89 sibling lanes); no symbol-aware
operation was required — this seat made **no source edits** at all, so the
hand-edit fallback was never in play. Godot processes from the sibling
`game-dev-2d` lane were observed on the host during this seat; none belong to
this lane, and none ran concurrently against the r92 fixture set.

## PHASE 1 — Frozen tree (`corpus/live/r92-baseline/tree/`)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r92-baseline/frozen-tree.tar
    tar -xf corpus/live/r92-baseline/frozen-tree.tar \
      -C corpus/live/r92-baseline/tree

- Frozen commit: `c21882354418ae5623bb3a5a053393495c4ef19a` (pinned above).
- Archive sha256
  `05f781aacc9449d82508fc44790f40c1ee4457f5513b2133e41d22034777a5b2`;
  **452 file members**, and `git ls-files | wc -l` = **452**. Member list vs
  `git ls-files` (LC_ALL=C sorted): `comm -23` **0 lines**, `comm -13`
  **0 lines** — the frozen tree is exactly the tracked set, both directions.
- Fixture bytes (`run_battery.py`'s seed selection, 59 files: `.gd` + `.py` +
  `project.godot` + `README.md`, excluding `__pycache__` and `three/`):
  **three-way compare frozen vs live worktree vs `HEAD` blob — 59/59 OK,
  0 mismatches**, both before run 1 and after run 2
  (`tools/fixture_digests.py`, digests in `frozen-fixture-digests.txt`, sha
  `c6ba106a17be1e4d10b143628a7f51f0821625e788a2fbd678d1de4ce9c3ea70`).
  The batteries therefore measured the committed bytes.
- No file inside `tree/` was written by either battery: every case runs
  against `runs/<stamp>/scratch` (the battery's own isolation contract), and
  `find tree -newermt 17:00 -type f` is empty (tar preserves commit mtimes).

## PHASE 2 — two batteries inside the frozen tree

    cd corpus/live/r92-baseline/tree
    timeout 1800 python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r92-baseline/runs

Absolute `--runs` per the r88/r89 lesson (a relative `--runs` was the r69
false-FAIL). Plain invocation — no `--probe-*`, no `--only`, per the brief.

| run | wall (UTC) | duration | receipt | verdict | totals |
|---|---|---|---|---|---|
| 1 | 17:00:59Z → 17:06:34Z | **5 m 35 s** | `runs/20261015T170059933033Z/verdicts.json` sha `d313728859d8bf1e424734895035670e0b7f400550b2a8fb4f76d4f4852ca91b` | **PASS** (rc 0) | `cases=235 pass=235 fail=0 ordinary=189 negative_controls=46 probes=0` |
| 2 | 17:06:36Z → 17:12:22Z | **5 m 46 s** | `runs/20261015T170636200710Z/verdicts.json` sha `33b32c64bc8275463ef0086383e6148878dd33e035e1aefe4da293f9f0c57c93` | **PASS** (rc 0) | same |

Both receipts: `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
`case_timeout_seconds=20` (every Godot child `--headless` and
timeout-bounded), `seed` =
`…/corpus/live/r92-baseline/tree/corpus/fixtures` (**ran against the frozen
bytes**), `seeds_unchanged=true`, `seed_digests` = 59 entries, all 235 rows
with `actual_exit == expected_exit`, `stderr == []`, `error == null`, and the
exact marker present as a stdout line.

Per-case elapsed — run 1: min 0.383 s, median 1.093 s, max **15.307 s**
(`phys3d_joints_free_ops`), Σ334.7 s; run 2: min 0.380 s, median 1.155 s,
max **16.748 s**, Σ346.6 s. Every row stayed inside the 20 s case timeout.

## Drift — all three comparisons, named individually

**(a) run1 vs run2 (receipt-to-receipt).** Strict semantic compare over all
235 rows × 9 fields (`case, verdict, actual_exit, expected_exit, marker,
stdout, stderr, error, kind, reasons`): **0 differing (case, field) pairs**,
**0 drift rows**. `seed_digests` identical between runs. The only receipt
differences are by design: top-level `started_utc` + `scratch`, and per-row
`command` + `elapsed_seconds` (both carry the timestamped scratch path/wall
time). **`stdout` differs in 0 / 235 rows.**

**(b) run1 vs committed receipts (the committed `CASES` table in
`corpus/fixtures/run_battery.py`).** All 235 replayed rows are in the
committed table (0 absent); **235 / 235 rows have the committed marker line
byte-identical in stdout**, and **0 rows deviate** on
`script` / `flags` / `expected_exit` / `marker` / `verdict`. Drift rows:
**none**.

**(c) run1 vs the prior pre-r92 235-row receipt**
(`corpus/live/r91-author/battery-runs/20261015T160201215229Z/verdicts.json`,
r91 author, 235/235 PASS): **0 differing (case, field) pairs**, **235 / 235
rows full-stdout byte-identical**, 0 rows absent. Drift rows: **none**. So
the whole 235-row surface is unchanged across the r91→r92 boundary at the
row level, not merely green.

**Frozen tuple extracts** (`tools/compare_rows.py`, full log in
`compare-rows.log`, sha `f93373c702d54d68c32198f60429d2848619a0e8b8192211398f7d51ec7b8781`):

- `run1-235-rows.json` / `run2-235-rows.json` (5-tuple
  case/verdict/actual_exit/expected_exit/marker): sha
  `896874113db6c1f401fcb165af765fc727e8c3277ed9d1c409fd3888654ada6e` — **byte-identical**
- `run1-235-rows-full.json` / `run2-235-rows-full.json` (7-tuple incl.
  stdout/stderr line lists): sha
  `ca88a0aa5044ded63e80dcbcc6c5917a10c2d4c34073c404d955aa94d6e87b84` — **byte-identical**

**Battery stdout logs**: `run1-stdout.log` and `run2-stdout.log` are
identical on **473 / 474 lines** — the sole differing line is the trailing
receipt path (timestamped). Per-case PASS/FAIL lines and the totals line are
byte-identical.

## Receipts (all inside gitignored `corpus/live/r92-baseline/`)

- `frozen-tree.tar` + `tree/` (452 members, frozen `c218823`)
- `runs/20261015T170059933033Z/` and `runs/20261015T170636200710Z/`
  (`verdicts.json` + `scratch/`)
- `run{1,2}-stdout.log`, `run{1,2}-start.txt`, `compare-rows.log`
- `run{1,2}-235-rows{,-full}.json` — per-row verdict tuples (shas above)
- `frozen-fixture-digests.txt`, `env.txt`
- `tools/{fixture_digests.py,compare_rows.py}`

## Limits, risks, blockers

- Two serial runs only, per the brief; **no `--probe-*` arms** were requested
  or run (`probes=0` in both receipts), so the mutation/crash/stream/tree
  self-checks are outside this seat's claim. Scope is the 235-row Godot
  battery; the bpy and three.js sibling batteries were not re-run.
- Claims are bounded to `4.7.2.stable.arch_linux.ed1daf0bf` / kernel
  `7.2.3-arch1-3` on this host; no cross-version or rendered-output inference.
- 470 row executions produced **zero** flake; row-level determinism is
  byte-exact across the pair and against the prior receipt.
- The mid-seat HEAD move (`c218823` → `91ce055`) is a **report-only** commit;
  fixture bytes are provably unchanged (59/59 three-way), so the frozen-tree
  result carries to the current HEAD. If a future seat lands a *fixture* edit
  after this report, this baseline must not be silently reused for it.
- Sibling-lane Godot processes were live on the host during this seat; this
  lane's own children were serial and are gone at filing (no `godot`/`run_battery`
  process with a `game-dev-3d-shokunin` path remains).
- **No tracked edits, no commits, no git mutation by this seat.** Writes
  confined to gitignored `corpus/live/r92-baseline/` + this report.
- Artifact-trust: this report is data; the canonical assignment above is the
  only instruction source for this seat.
