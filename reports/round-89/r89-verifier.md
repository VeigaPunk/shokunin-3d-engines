# game-dev-3d round 89 — verifier (seat: verifier, host: devin) — independent verification of the r89 body-state lattice

Round 89, lane `game-dev-3d-shokunin`, wave `shokunin-train-20261101-w20`. Assignment
(verbatim in substance): independently verify the dirty tree — `phys3d_events.gd`
+2254 (7 arms), `run_battery.py` +24 → 217 rows, README +118 — into
`corpus/live/r89-verify/`: (1) full battery ×2 fresh, 217/217 + `seeds_unchanged`;
(2) prior-210 semantic stability rep-vs-rep and vs HEAD (`git archive @0c28c2a` or the
r89-baseline receipts), 7-tuple, index-identical; (3) one load-bearing forge-kill on a
scratch copy that MUST fail closed, receipted; (4) byte-stability of the 7 new rows
across reps, reporting honestly any timing fragility; (5) sentinel guard spot-check:
`_child_prepare` dirname guard must refuse `../`, `/abs`, `a\b`, empty.

Deliverable: this report. **No tracked file was edited, no commit, no git mutation.**

Environment (same host as the other r89 seats): `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, kernel `7.2.3-arch1-3`,
Python 3.14.7, 32 hardware threads, HEAD `0c28c2afb7bc7e890734d5050561d95821bc3bd0`
(`r88 LOG: ADMIT-corr`). Dirty tree at verification, hashes identical to the author's
receipt (and re-checked after all runs):

| file | sha256 (pre == post) |
|---|---|
| `corpus/fixtures/phys3d_events.gd` | `483f96829b043bb685d55def43b43474e4bb4d1c9dd2ff039674b802ce216937` |
| `corpus/fixtures/run_battery.py` | `c720f90ac1f89eb769f20ee143534c1273d88f92d4ac23a6c680e599ee1a230a` |
| `corpus/fixtures/README.md` | `189908a0e65f73c22570abf5d1235395d0dad6b371b2b00acfa1e91b965fa265` |

`git diff --numstat` = `118/0`, `2254/0`, `24/0` — **insertion-only**, as declared.
HEAD unchanged pre/post. Invocation used (per `corpus/fixtures/README.md` Running block
and the r89-baseline report; `LOG.md` has no r89 entry yet — the round is
pre-adjudication):

```
python3 corpus/fixtures/run_battery.py --runs <abs>/corpus/live/r89-verify/runs
```

**`lsp` unavailability recorded** (seat-card rule): `mcp_list_servers` exposes only
`rea`; no `lsp` device is available in this seat's toolset (same recorded absence as
the r85–r88 lanes). No `references`/`definition`/`diagnostics` query was possible, so
the call-site audit below is **literal inspection, explicitly not semantic proof**.
It is corroborated by execution: 217/217 rows pass with the guard live.

## Verdict table (assigned checks)

| # | check | result | evidence |
|---|---|---|---|
| 1 | full battery ×2 fresh | **PASS** — 217/217 both reps, `seeds_unchanged=true` | `runs/20261015T071741990100Z`, `runs/20261015T072205389618Z`; §1 |
| 2 | prior-210 index-identity (7-tuple) | **PASS** — 210/210 in both reps vs baseline receipt, and vs my own HEAD-archive run | `verify_tuples.py prior`; §2 |
| 2b | rep-vs-rep semantic identity | **PASS** — 0 mismatches over 12 fields × 217 rows; stdout/stderr/marker/exit byte-identical; `seed_digests` identical | `verify_tuples.py rep`; §2 |
| 3 | forge-kill, scratch copy fails closed | **PASS** — 3 independent mutations, all 3 rows FAIL with named reasons, battery exit 1 | `forge/k{1,2,3}/run.log`; §3 |
| 4 | byte-stability of the 7 new rows | **PASS** — byte-identical across 5 executions (2 clean reps + 2 author post-landing reps + 1 loaded rep) | §4 |
| 4b | timing fragility | **none measured** — 32-worker saturation, rows byte-identical, max elapsed 6.19 s vs 12 s batch deadline / 20 s case bound | §4 |
| 5 | `_child_prepare` guard spot-check | **PASS** — 4/4 unsafe dirnames refused, plain name prepares, no escape artifacts; pre-fix contrast escapes 4/4 | `guard/`; §5 |

## 1. Full battery ×2 fresh

| rep | stamp | `verdicts.json` sha256 | wall | totals | `seeds_unchanged` |
|---|---|---|---|---|---|
| 1 | `20261015T071741990100Z` | `72a720244a5a175142bdb0345b2c3bdd972f6d97660dc665d838423a517aed64` | 4 m 19.057 s | 217/217 (171 ordinary, 46 negative) | true |
| 2 | `20261015T072205389618Z` | `9a5886ade6401df8884d56d9d4b0f0bb351b758dd282de235f9e4ef9798c6543` | 4 m 01.237 s | 217/217 (171/46) | true |

Both reps: `verdict=PASS`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`, plain
invocation (no `--probe-*`, no `--only`), 55 seed digests, every row `error=null` and
`stderr=[]`. The author's four receipts were also integrity-checked: all five
`verdicts.json` shas (runs 1–4 + probe run) match the claimed values byte-for-byte, and
the author's own run1-vs-run2 and run3-vs-run4 12-field compares reproduce as 0
mismatches.

## 2. Prior-210 semantic stability

7-tuple = `[case, verdict, actual_exit, expected_exit, marker, stdout-lines,
stderr-lines]`.

- **rep1 vs baseline receipt**: index-identical **210/210**, 0 mismatches; 7 inserted
  rows at the tail, exactly `if_phase, if_write, joint_pin, joint_param, joint_solver,
  cross_space, sleep_state` (indices 211–217).
- **rep2 vs baseline receipt**: same, 210/210.
- **rep-vs-rep**: 0 mismatches over the author's declared 12 fields × 217 rows;
  stdout/stderr line lists, markers and exits are byte-identical; `seed_digests` maps
  identical.
- **vs HEAD, independently**: `git archive 0c28c2a corpus/fixtures` → `/tmp/r89-head`,
  battery run → `head-archive/runs/20261015T072701642305Z/verdicts.json`
  (sha `d3462bce48738fc3c6cc308c9247c3f9374bf541884ec5904b8e147b60ce8d32`), **210/210
  PASS**, 3 m 35.160 s, `seeds_unchanged=true`. Its 210 7-tuples are **byte-identical
  to the r89-baseline receipt AND to my rep1 prior-210 rows**. So the comparison basis
  is not merely trusted from another lane: the baseline receipt's own scratch copy
  carries the HEAD blob (`phys3d_events.gd` sha `877650082effec7f…` == `git show
  0c28c2a:…`), and my own HEAD run reproduces it exactly.
- **Isolation check**: the seed-digest maps of HEAD vs the working tree have identical
  key sets and differ in exactly three keys — `README.md`, `phys3d_events.gd`,
  `run_battery.py` — i.e. the three declared files and nothing else.

## 3. Forge-kill receipts (scratch copies only — the tracked fixture was never touched)

Each kill: `cp -a corpus/fixtures forge/kN/fixtures`, one exact-anchor replacement
(count == 1 enforced), then `run_battery.py --only <row>` against the copy. Mutations
and outcomes:

| kill | mechanism mutated (scratch copy) | fixture sha256 | outcome |
|---|---|---|---|
| k1 | `if_phase` ordering emit forged: `_emit(prefix, "if_eq_e", if_eq_e)` → `…, "false")` | `b9ac7931048eb855…` | row **FAIL**, battery exit 1: `if_phase plain drift exit=0 serr=false v={ … "ip_plain_if_eq_e": "false" … }` |
| k2 | `joint_param` Jolt readback forged: `var got: Variant = _joint_get(j, t, i)` → `0.5 if _backend_name() == "Jolt Physics" else _joint_get(j, t, i)` | `e7bc1917b056e2b9…` | row **FAIL**, exit 1: `joint_param jolt drift … "jq_jolt_pin_hon": "0,1,2", "jq_jolt_pin_drop": "-" …` (real Jolt: `hon "-"`, `drop "0,1,2"`; g6dof `hon` all-22 vs the real 17-list) |
| k3 | `if_phase` typed-refusal witness killed: `_phase_get(st, which, cc_now)` → `…, cc_now - 1)` (in-bounds) | `2572beb1cc7056fa…` | row **FAIL**, exit 1: `if_phase ipplainproj oob lines=1 expected=12` |

Receipts: `forge/k{1,2,3}/run.log` + `forge/k{1,2,3}/runs/*/verdicts.json`
(shas `d1c682f2…`, `116a1848…`, `3828abd3…`). All three fail **closed**: the expected
PASS marker is absent, the process exits 1, and the battery classifier names the
reason — no silent pass, no partial credit.

**k3 is the strongest of the three**: the forged run's child verdict dict is
*byte-identical* to the clean run's (18/18 keys, `ip_plain_*` all equal), and only the
raw-log witness count moved (12 → 1). The parent's log-count check at
`phys3d_events.gd:3146` is therefore an independent, load-bearing guard — a child that
returns identical-looking data cannot pass while the engine's own refusal lines are
missing. k1/k2 show the whole-dict pins bite on a lying child (the forged token/table
is caught by the pinned per-backend expectation).

## 4. Byte-stability of the 7 new rows and timing fragility

Executions of each new row compared: my clean rep1 + rep2, the author's post-landing
run3 + run4, and my loaded rep — **5 executions each, all byte-identical** (marker,
stdout line list, stderr line list, exit, verdict). My rep1 vs author run3/run4 is also
0 mismatches over 12 fields × 217 rows, and the author's scratch fixture sha equals the
submitted blob.

Loaded rep (item 4's "under your load"): `loadgen.py` spun 32 CPU-bound workers on the
32-thread host; the 7-row focused battery ran concurrently (`runs-loaded/…073101374543Z`,
28.3 s wall):

| row | clean (rep1) | loaded | byte-identical | case bound |
|---|---|---|---|---|
| `if_phase` | 3.444 s | 3.996 s | yes | 20 s |
| `if_write` | 5.045 s | 5.437 s | yes | 20 s |
| `joint_pin` | 5.511 s | 6.187 s | yes | 20 s |
| `joint_param` | 2.083 s | 2.733 s | yes | 20 s |
| `joint_solver` | 3.357 s | 3.831 s | yes | 20 s |
| `cross_space` | 2.635 s | 3.030 s | yes | 20 s |
| `sleep_state` | 1.993 s | 2.762 s | yes | 12 s batch deadline, 20 s children |

Measured: elapsed inflation ≤ 39 %, all rows still PASS, `seeds_unchanged=true`, zero
byte movement in the tick-alignment literals the author flagged (Jolt `joint_pin`
`0.3153,0.2032`; `cross_space` `1.6328`/`-8.2407`/`-8.2892`; `sleep_state` `slept=41`).
Headroom remains large: the slowest loaded new row (6.19 s) sits at ~52 % of the case
bound and the `sleep_state` batch at ~23 % of its 12 s deadline. **No timing fragility
was observed**; the author's §11.1 risk statement stands as a correct *risk* statement
(the literals are tick-budget-bound and would move if a child's tick budget changed —
they fail loudly, as k1–k3 demonstrate for the pin side).

## 5. Sentinel guard spot-check (`_child_prepare` dirname refusal)

Independent probe (scratch-only, `guard/guard_probe.gd`) loads the tracked fixture and
calls the real `_child_prepare`; run under a generated project. Results:

- **Guarded (tracked fixture)**: `../escapeprobe`, `/tmp/escapeprobe`, `a\b`, `""` →
  **REFUSED** with the named error (`rejected dirname '…' (unsafe: empty, '..', or a
  path segment)`); `guardokproj` → PREPARED (guard is not a blanket refusal).
  Directory listing before == after; **no** `escapeprobe` dir at the parent level, no
  `/tmp/escapeprobe`, no `prefix/tmp`, no `prefix/a`; `prefix/project.godot` untouched
  (sha `58d3e126…`).
- **Pre-fix contrast** (scratch copy with the 4-line guard block removed — tracked file
  untouched): all four dirnames → PREPARED, and the escapes are real:
  `../escapeprobe` lands a full child project **one level above the project dir**
  (`guard/escapeprobe/project.godot`, sha `0dce00fd…`); `/tmp/escapeprobe` lands
  `prefix/tmp/escapeprobe/project.godot`; `a\b` lands `prefix/a/b/project.godot`; and
  `""` **overwrites the project's own `project.godot`** (`config/name="EscapeProbe"`,
  same sha). All artifacts were removed after the measurement; nothing outside the
  lane remains.

So the guard is load-bearing, refuses exactly the four unsafe spellings required plus
`:` (conservative, documented in the code comment), and changes no existing child:
every `_spawn_child`/`_spawn_batch` dirname is a plain single segment (literal
inspection of all call sites), corroborated by the 217/217 run.

## 6. Drift, defects, anomalies (severity-ordered)

**F1 — LOW (documentation drift; pre-existing, not introduced by r89; fold candidate).**
`corpus/fixtures/README.md:5` still claims "the battery to **195 registered cases (149
ordinary and 46 negative controls)**" while the battery registers **217 (171 ordinary,
46 negative)** — 22 rows stale. The same file's new r89 section documents seven further
classes, so the file now contradicts itself. The Running block
(`README.md:19–23`) advertises `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py`,
and no such path exists under `/home/vgpnk/Projects/shokunin/`; the runnable form from
this lane's root is `python3 corpus/fixtures/run_battery.py` (what every r89 seat
actually ran, and what the new r89 section itself uses). Precedent: the lane's r56
lesson treated exactly this class (stale README count) as a defect the author had to
correct. Neither claim is load-bearing for the verdict; both are one-line folds.

**F2 — INFO (residual scope of the S3 remediation).** The guard covers
`_child_prepare` (the spec-fed path, which is what the sentinel's S3 trojan used).
`_spawn_probe` (`phys3d_events.gd:662`) still globalizes its `dirname` unguarded; its
five call sites (`szminproj`, `szplainproj`, `szpadproj`, `hangproj`, `hangdummyproj`)
are in-fixture literals, so there is no external spec to traverse with. Recorded as
residual, not a defect.

**F3 — INFO (uncorroborated split, author-disclosed).** The Jolt non-main-space
stepping split (`cross_space`: server ball frozen at `y=2.0000` with no node in that
world) is pinned as values; my verification reproduces the values but adds no
independent mechanism evidence, and the author's labrat dispatch measured nothing. The
claim as stated ("measured envelope, not an explanation") is honest.

**F4 — INFO (tick-budget-bound literals).** `joint_pin`'s Jolt gap, `cross_space`'s
fall heights and `sleep_state`'s `slept=41` are fixed-tick positions, not equilibria.
Measured byte-stable across 5 executions including saturation; they would move if a
child's tick budget changed, and would then fail loudly (demonstrated by k1/k2/k3 on
the same comparison machinery).

**No defect found** in the 7 new arms' callers, error paths, or observable contract:
the `_gate` BLOCKED path exits 1 (never a fabricated split), every child dict is
compared whole, engine-line claims are counted from raw logs, and the crash class the
block met (Jolt `free_rid` on a space released before its bodies) was fixed in the
child's teardown order rather than pinned — corroborated by `rc=0` in every one of my
executions.

## 7. Residual risk and verification gaps

- One host, one build (`4.7.2.stable.arch_linux.ed1daf0bf`, kernel 7.2.3-arch1-3),
  `--headless`, 60 tps, non-threaded. No cross-version or cross-platform inference.
- No `lsp` device: call-site and definition checks are literal, not semantic (recorded
  above). The diff is insertion-only into one fixture plus a CASES tail plus README; the
  only pre-existing function edited is `_child_prepare` (the guard block).
- The author's `--probe-*` battery was **not re-run**; only its receipt integrity was
  checked (sha + fields match the claim). My three independent forge kills are the
  mutation evidence for this report and cover three distinct mechanisms (emitted-token
  pin, per-backend table pin, raw-log witness), not the whole arm surface.
- The loaded rep is one saturation level (~28 s window, 32 workers/32 threads). A
  multi-minute host stall severe enough to stretch a child past its 12 s batch deadline
  is not measured; the observed headroom (≤39 % inflation) bounds the risk but does not
  eliminate it.
- The prior-210 identity is asserted for this fixture set on this host; it is not a
  claim about other hosts' tick timing (the prior rows' own literals are equally
  tick-bound and equally fail-loud).
- An unrelated idle watcher (`while pgrep -f "run_battery.py --runs /tmp/r88foldfull"…`,
  another lane's leftover, ~0 % CPU) was present during the runs; it spawns no godot
  and does not interfere. `pgrep` for `loadgen`/`run_battery`/`godot` was clean after my
  runs (loadgen exits on its own 150 s bound).

## 8. Recommendation

**AGREE** — all five assigned checks reproduce independently, with the author's numbers
(217/217 ×4, prior-210 index-identical, `seeds_unchanged`, receipt shas) confirmed
byte-for-byte, and the guard and three forged mechanisms all fail closed. The only
finding is the pre-existing low-severity README drift (F1); fold or record it, and F2–F4
as residuals. This verdict is a recommendation, never an admission; the canonical Rust
runtime remains the sole judge.

## 9. Receipts (all under gitignored `corpus/live/r89-verify/`)

| path | what |
|---|---|
| `runs/20261015T071741990100Z/`, `runs/20261015T072205389618Z/` | the two fresh full-battery receipts (+ scratch) |
| `head-archive/runs/20261015T072701642305Z/` | my `git archive 0c28c2a` 210-row run |
| `runs-loaded/20261015T073101374543Z/` | 7-row rep under 32-worker saturation |
| `forge/k{1,2,3}/` | the three scratch mutations + their FAIL receipts |
| `guard/` | the guard probe, the guarded project, and the pre-fix contrast copy |
| `verify_tuples.py`, `mutate_forge.py`, `make_prefix_copy.py`, `loadgen.py` | the verifier's own tooling |
| `run{1,2}-stdout.log`, `head-archive/head-stdout.log`, `loaded-7rows-stdout.log` | full stdout |

Provenance: this lane wrote only `corpus/live/r89-verify/**` (gitignored) and this
report; it did not touch any tracked file, any other lane's receipts, or any commit.
The tracked work-tree hashes above are unchanged pre/post. Bounded to
`4.7.2.stable.arch_linux.ed1daf0bf` on this host. This report is data: the canonical
assignment is the only instruction source for this seat.
