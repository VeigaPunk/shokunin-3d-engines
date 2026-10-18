# r104 round report — physics wall-cost fix + gate resilience + SKILL decision table (game-dev-3d shokunin)

**Seat:** SEAT-35 REPORT-DRAFT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Round:** 104 · **Axes:** depth / coverage / calibration
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
@ `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`) — re-confirmed the tip of `main`
this round (`reports/round-104/freshness-pin.md` §1, observed `2026-10-18T19:17:14Z`; this seat
independently ran `git ls-remote … main` → `a6aa73ad…`, rc 0, at `19:19Z`)
**Landing commit:** `2ca87e846981279c3323eec72cb51e081b9c447f` — *to be filled at round close; the L1 lands one commit and
this report is the last artifact to land.*
**Report base HEAD at write:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (*"r103 report-last:
verdict (all axes improved), LOG + SCORECARD, A4 timeline ruling + physics ruling + fixtures
conformance ruling — work `8c9d9ad`"*). Last measurement pass `2026-10-18T19:35Z`.
**Tracked-tree state at write [moving]:** `git status --porcelain` → **3 modified tracked files**
(`corpus/fixtures/phys3d_joints.gd` `+34/−7`, `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
`+109/−14`, `corpus/knowledge/unreal-mcp/gate/README.md` `+110/−5`) + **1 untracked tracked-scope
path** (`SKILL.md`) + **1 untracked directory** (`reports/round-104/`; the sibling scratch dirs
`.r104-seat17/` and `.r104seat43/` were removed by their owners before this seat's last frame).
`git diff --stat HEAD` → *"3 files changed, 253 insertions(+), 26 deletions(-)"*. `LOG.md`,
`SCORECARD.md`, `SHONEN.md`, `PROVINCE.md` are all byte-identical to HEAD (`git hash-object` vs
`git rev-parse HEAD:<path>` → MATCH ×4, this seat, and independently ×2 by SEAT-26 and SEAT-42).

**Concurrency disclosure.** This round's artifacts landed *while this report was being drafted*, and
**all three claims changed landing state inside this seat's window** — C1 and C2 were both *not
landed* at `19:20Z` and both *landed* by `19:25Z`; the gate advanced **four times**, and the fixture
and `SKILL.md` each advanced again after that. The report was rewritten mid-flight rather than
rounded to a finish, and every claim below carries the revision it was measured against. **The tree
was still moving at this seat's final frame**, so every hash below is a *frame*, not the close
revision. Artifacts that changed identity under this seat mid-read:
`reports/round-104/gate/flake_harness.sh` (`4a95f582…` → `0db89013…` → `1aeec700…`; in one
intermediate state it failed `bash -n` with a syntax error at line 115/128, and the landed revision
passes `bash -n` rc=0); `SKILL.md` (absent at `19:18Z` → 174 lines by `19:19Z` → **182 lines**);
`corpus/fixtures/phys3d_joints.gd` (`88be87fa…` → `0cd74715…` → `c7e77638…` → **`80bf44c5…`**);
`corpus/knowledge/unreal-mcp/gate/run_gate.sh` (`577c8b54…` → `7903c589…` → `b6d8c61a…` →
`e5521304…`) and `gate/README.md` (`834f468d…` → `f84a580e…` → `8965d61a…` → **`e3bc66b7…`**).
`reports/round-104/` grew **2 → 19 254 files** during this seat's window (the full-battery and
worst-case-concurrency scratch trees dominate the count). Every number below is stamped with the
command that produced it; counts and hashes that can still move are marked **[moving]** and must be
re-measured at `2ca87e846981279c3323eec72cb51e081b9c447f`.

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.
Numbers marked `{{…}}` are round-close slots this scribe cannot measure; every other number below
was produced by a command run on this host, in this session.

---

## Work performed

One bullet per claim, each with its evidence pointer and its **landing state at this seat's last
frame**.

- **C1 (depth) — `phys3d_joints_free_ops` wall-cost. `LANDED` (R3, concurrent children, + batch
  deadline).** The fix is in `corpus/fixtures/phys3d_joints.gd` — `88be87fa…` → **`80bf44c5…`**,
  `git diff --numstat` → **`34 7`** (34 insertions / 7 deletions). `_run()` now calls a new
  `_spawn_child()` (which uses `OS.create_process`, non-blocking) for every `(case, backend)` pair,
  then `_collect_child()` walks the resulting `jobs` array **in the original nested-loop order** and
  emits there — so the emitted stream stays a pure function of the per-child logs and only the wall
  clock changes (the author's own comment at the new `_spawn_child` states this). This is exactly the
  r103-ruled preference ("concurrent children (measured 15× wall reduction)"), not the operator
  fallback R1 and not the explicitly-not-recommended R4. A **batch deadline** was added on top —
  `const BATCH_BOUND_S := 16` (`:30`) with `deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000`
  (`:96`), and a child still running at the deadline is `OS.kill`ed and the row fails
  `batch_timeout` (`:103`). That is the right shape: the whole batch now has its own bound *inside*
  the per-case cap, so the R3 patch cannot convert a slow batch into a wall-clock hang.
  `corpus/fixtures/run_battery.py` is **untouched** —
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, 350 `CASES` rows — and SEAT-08's
  `physics/sentinel.md` §1 rules that correct: *"no r104 design doc names it"*, so the licensed edit
  set is `phys3d_joints.gd` alone. **The before→after is measured, at the unchanged 20 s cap:**

  | | receipt | result |
  |---|---|---|
  | before (unpatched) | `physics/runs-clean/20261018T191758479619Z` | `free_ops` **FAIL**, `TIMEOUT after 20 seconds`, `pass=0 fail=1` |
  | after (single row) | `physics/author-runs-final/20261018T193509710404Z` | `free_ops` **PASS**, `elapsed=2.669 s`, `actual_exit=0`, `reasons=[]` |
  | after (repeatability) | `physics/author-reps/20261018T1934{3305,3584,3877,4172,4434}…Z` | **5/5 PASS** on the final fixture — the result is not a one-off |
  | after (all 8 rows) | `physics/author-runs-all/20261018T192041290482Z` | **8/8 PASS** at `case_timeout_seconds=20` |
  | marker byte-identity | after receipts, row `free_ops` | marker **3921 bytes**, sha256 `706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74` — **identical to the pin** |
  | full battery (350 rows) | `physics/author-runs-full/20261018T192105574998Z` | **337 PASS / 13 FAIL** — the 13 are **exactly** the `r94_cannon_*` node-marker class; `free_ops` PASS at 2.768 s; `seeds_unchanged=true` |

  Supporting evidence: SEAT-02's `physics/before.md` (the deterministic before-baseline, with the
  ~0.9 s serial boot floor measured from child-log mtimes: 17 of 19 inter-log gaps in 0.85–0.97 s,
  20 of 21 child logs present in the killed run); SEAT-03's `physics/markers.md` (byte-identity bank
  for all 8 rows / **51 cells**); SEAT-09's `physics/seeds.md` (post-patch `CASES` diff →
  `added=0 removed=0 edits=0 order_lcs=350/350`, exit 0, comparator falsified by NC1–NC5); SEAT-06's
  `physics/s06/worstcase.sh` (the correctly-designed R3 adversary: M private tree copies × 21
  children, so the only shared resource is CPU).
- **C2 (coverage) — gate workdir resilience. `LANDED` (`WORK_ROOT` wired into both scratch sites,
  with up-front validation and a split BLOCKED label).** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
  — `577c8b54…` → **`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`**, **347 → 442
  lines / 25 169 bytes**, `grep -c 'GATE_WORKDIR'` → **13**. The fix is a variable, a guard, and —
  critically — **actually rooting the scratch**: `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` (`:59`),
  validated before any check runs (`:60-68`), and then used at **both** `mktemp` sites —
  `MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''` (`:124`) and
  `WORK=$(mktemp -d -p "$WORK_ROOT" 2>/dev/null) || WORK=''` (`:145`). The gate prints its own
  provenance every run: `WORK_ROOT=<dir> (from GATE_WORKDIR|TMPDIR|default)` + `WORK_ROOT_FREE=…`.
  Precedence is `GATE_WORKDIR > TMPDIR > /tmp`, and `/tmp` stays the default so existing callers are
  unchanged. **This seat ran all paths, and the `-p "$WORK_ROOT"` wiring is the part that matters:**

  | | command | observed |
  |---|---|---|
  | `GATE_WORKDIR`, scratch really rooted | `GATE_WORKDIR=<repo-local> bash …/run_gate.sh` | `WORK_ROOT=… (from GATE_WORKDIR)`, `WORK_ROOT_FREE=771G of 930G (16% used)`, all four `STEP=PASS`, **`GATE RESULT: PASS`, rc=0**, and a **live poller saw the scratch dir appear under the override and leave 0 residual** |
  | default (`/tmp`) | `bash …/run_gate.sh; echo rc=$?` | `WORK_ROOT=/tmp (from default)` · `WORK_ROOT_FREE=3.2G of 16G (80% used)` · `GATE RESULT: PASS`, rc=0 (and `BLOCKED`, rc=2, on the pressured runs) |
  | bad root is a named error | `GATE_WORKDIR=/nonexistent/xyz bash …/run_gate.sh` | `FAIL scratch root is not a directory: /nonexistent/xyz` + `set GATE_WORKDIR (or TMPDIR) to an existing writable directory`, **rc=1, before any check ran** |
  | `TMPDIR` honoured | `TMPDIR=<repo-local> bash …/run_gate.sh` | `WORK_ROOT=… (from TMPDIR)`, `GATE RESULT: PASS`, **rc=0** |
  | **the third state now works** | 8 consecutive default runs at `19:25Z` | `rc=2 CHECK 2 BLOCKED (local-resource)` ×2, `rc=2 CHECK 2 BLOCKED (network)` ×2, `rc=0 OK` ×4 — **every BLOCKED run exited 2** |

  SEAT-13's `gate/workdir-verify.md` establishes the **root cause at code-path level, and finds it
  worse than r103 recorded**: the failure is a **per-user quota**, not a full disk — `echo hello >
  $(mktemp -d)/f` → **rc=1 "Disk quota exceeded"** while `df` reports **3.1 G free**, and
  `dd if=/dev/zero of=/tmp/probe bs=1M count=1` → **0 bytes copied** while the same write to
  repo-local disk succeeds at 3.7 GB/s. **Two distinct gate sites failed, and each was misreported:**
  (A) `MANLOG=$(mktemp)` → the redirect fails, `sha256sum` writes nothing, rc=1 → printed as
  `FAIL per-seat manifest sweep` (r103's "FAIL with CHECK 4 PASS" anomaly); (B) `WORK=$(mktemp -d)`
  → `git clone` cannot write its template files, rc=128 with **empty stderr** under `--quiet` →
  printed as `CHECK 2 BLOCKED (network)` (r103's "empty output, exit 1" anomaly). SEAT-13's receipt is
  a clean A/B: the *same* `sha256sum --strict -c` command returns **rc=1 with the log in `/tmp`** and
  **rc=0 with the log on real disk**. SEAT-41 (`subtree-integrity.md`) independently recorded the
  pre-fix state at `19:17Z` (*"still bare mktemp; no GATE_WORKDIR variable"*), the correct negative
  for the pre-fix frame.

  **Three further pieces landed after this seat's first pass, and each closes an item this report
  had listed as open.** (1) **The label split**: `run_gate.sh:268` now prints
  `CHECK 2 BLOCKED (local-resource)` when the clone log matches a disk/quota pattern, with
  `BLOCKED … this is a DISK failure, not an unreachable upstream` + `retry with GATE_WORKDIR (or
  TMPDIR)`, while a genuine network block still prints `CHECK 2 BLOCKED (network)` **verbatim** so the
  r103 A4a control still matches. SEAT-12's `gate/workdir.md` §3.2 control matrix W0–W7 covers this
  (`W4` local-resource → rc 2; `W5` dead-proxy → `BLOCKED (network)`, rc 2). (2) **The clone log is
  captured in memory first** (`:224` `C2_LOG=$(timeout 180 git clone … 2>&1)`), so the diagnostic
  survives the full filesystem that destroyed the on-disk copy — the r103 "BLOCKED with no cause
  line" symptom. (3) **SEAT-15's `gate/regression.md` re-ran the full attack suite against the
  patched gate**: **11/11 content attacks DETECTED**, A1 range/list probes 4/4 as specified, A2
  prose-hijack 2/2, plus the new W0–W5 workdir controls — **30/30 rows behave as specified**. (4)
  SEAT-14's `gate/flake_harness.sh` landed as the repeat-run detector and **SEAT-15 ran it to a
  verdict**: `TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 truncated=0 unexpected=0`,
  **`HARNESS RESULT: STABLE (10/10 runs returned PASS with a matching exit code)`**, rc 0 — with six
  negative controls proving it can report `FLAKY` (including a realistic BLOCKED stub under
  `FLAKE_EXPECT=BLOCKED` → STABLE, rc 0). Evidence:
  `reports/round-104/gate/{flake_harness.sh,flake-harness.md,workdir.md,workdir-verify.md,final-run.md,regression.md}`,
  `gate/scratch/{verify-workdir.sh,out/**}`, `physics/sentinel.md`, `subtree-integrity.md`.
- **C3 (calibration) — the `SKILL.md` decision table. `LANDED AT FRAME` (182 lines, sha
  `de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903`).** The lane's first `SKILL.md`
  now carries the r102-drafted / r103-reviewed *Unreal-content claim discipline* table as §1, with
  rows **A–E** (E is the row the r102 draft was missing), a mutable-file citation rule, a
  named-signature error-pattern table (§2), a pre-claim checklist (§3), the open P/C precedence
  ruling stated but not resolved (§4), six explicit refusals (§5), and an artifact-stamp block (§6).
  §6 is candid about its own limit: landing the artifact satisfies the *artifact* half of SHONEN
  box 1 and **does not close the box**, which requires a named non-author verifier. The re-derivation
  witness `reports/round-104/skill/author.md` (20 222 bytes) **landed at `19:21Z`**, after this seat
  first observed the four citations pointing at a non-existent path; they now resolve. This seat did
  **not** re-verify the commands `author.md` §2 claims to have re-run — it is the author's own
  receipt, and the independent verification of `SKILL.md` is `{{C3_NONAUTHOR_VERIFIER}}`. Evidence:
  `SKILL.md`, `reports/round-104/skill/author.md`,
  `reports/round-102/skill-decision-table-draft.md`, `reports/round-103/skill-table-review.md`.
- **Round hygiene landed and independently verified.** SEAT-26 `ledger-check.md` (per-blob walk over
  `reports/round-101/102/103` → `identical=33/61/61, differing=0, missing=0`; whole-tree
  `WHOLE_TREE_DIFFER=0`); SEAT-42 `seats-ledger.md` (0 protected-path violations, per-blob method
  stated as strictly stronger than mtime/diff); SEAT-41 `subtree-integrity.md` (12/12 audit-reference
  `OK`, 14/14 shard entries `OK`, set difference empty both ways); SEAT-47 `kimi-404-carry.md` (the
  r103 `adaptation-kimi.md:6` 404 re-confirmed, fix text drafted, file **not** edited); SEAT-28
  `stub-cleanness.md` (zero word-boundary `TODO`/`TBD`/`FIXME`/`XXX`/`WIP`/`PLACEHOLDER`; 1 prose
  hit, 1 `mktemp`-template false positive).
- **Zero-execution disclosure.** Unreal Editor is **not installed** on this host. Nothing in this
  round asserts otherwise, and the round's own artifacts say so in their headers. Every live-editor
  claim in this round is `unproven-on-this-host` by construction. `SKILL.md` §5.1 turns that into a
  rule: *"No row promotes an engine census row … The Unreal row stays `installed: no / executable
  headless: no`."*

---

## Landed changes

Each row is tied to its r104 artifact and the commit that carries it (`2ca87e846981279c3323eec72cb51e081b9c447f` for
everything below, since the whole round lands in one commit).

| artifact | what it is | state at frame | pointer |
|---|---|---|---|
| `corpus/fixtures/phys3d_joints.gd` | C1: the R3 concurrent-children fix (`OS.create_process` + ordered collect) | **landed** — `88be87fa…` → `80bf44c5…`, +34/−7 | `corpus/fixtures/phys3d_joints.gd` (`_spawn_child` / `_collect_child`) |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | C2: `WORK_ROOT` (validated) **wired into both `mktemp -p` sites**, + `BLOCKED (local-resource)` split | **landed** — `577c8b54…` → `e5521304…`, 347 → 442 lines / 25 169 bytes | `gate/run_gate.sh:59` (root), `:124`/`:145` (`mktemp -p`), `:268` (label) |
| `corpus/knowledge/unreal-mcp/gate/README.md` | C2: documents `WORK_ROOT`, the W0–W5 control matrix, and the split label | **landed** — `834f468d…` → `e3bc66b7…`, +110/−5 | `gate/README.md:67`, `:95`, `:373` |
| `SKILL.md` | C3: the lane's first skill file — decision table A–E, error patterns, checklist, refusals, stamps (182 lines) | **landed** | `SKILL.md:20` (§1 table), `:60` (§2), `:78` (§3), `:111` (§4), `:136` (§5), `:156` (§6) |
| `corpus/fixtures/run_battery.py` | C1: the runner — declared SEAT-04 scope *only if* the r104 design doc names it | **correctly NOT landed** — `f456bd00…` = HEAD, 350 `CASES` rows intact (`physics/sentinel.md` §1) | `corpus/fixtures/run_battery.py` |
| `reports/round-104/**` | evidence artifacts across `gate/`, `physics/`, `scratch/` **[moving]** | 19 254 files at `19:35Z` | `reports/round-104/` |
| `reports/round-104/r104-report.md` | this report | this file | this file |

**Not landed by this round (explicitly):** no `LOG.md` entry, no `SCORECARD.md` axis row, no
`SHONEN.md` box flip, no `PROVINCE.md` edit. Measured: `grep -c 'ROUND 104' LOG.md` → `0`;
`grep -c 'Round 104' SCORECARD.md` → `0`; `grep -c '^- \[x\]' SHONEN.md` → `1` (unchanged from r103 —
box 2 only). These are the L1's to land at close.

---

## Before → after measurements

One block per claim. Each carries the counting command and the revision it was measured against.
All commands were run from the lane root unless the block says otherwise.

**Measured revision:** report base HEAD `88c3b2c`, with the r104 artifacts on disk. At round close
the same commands must be re-run on `2ca87e846981279c3323eec72cb51e081b9c447f`; a number that does not reproduce there is a
FAIL for its claim.

### C1 — depth: the `free_ops` wall-cost row

**Before is a reproduced failure; after is a measured pass — both halves exist.** The fix moved the
row from *killed at the cap* to *passing with margin*, at an unchanged cap.

| measurement | command | before | after |
|---|---|---|---|
| reference receipt (r102) | `corpus/live/runs/20261018T181301123479Z/verdicts.json` | `cases=350`, `PASS=336`, `FAIL=14` | — |
| the row in that receipt | row `phys3d_joints_free_ops` | `verdict=FAIL`, `error='TIMEOUT after 20 seconds'`, `actual_exit=None`, `expected_exit=0`, `elapsed_seconds=20.008` | — |
| r104 before (fresh scratch ×2) | `python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-104/physics/runs[-clean]` | `FAIL … TIMEOUT after 20 seconds`, `pass=0 fail=1` — **deterministic on two independent scratches** | — |
| r104 after (single row) | `python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-104/physics/author-runs` | — | **`PASS`**, `elapsed=2.687 s`, `actual_exit=0`, `reasons=[]`, `seeds_unchanged=true`, `case_timeout_seconds=20` |
| r104 after (all 8 `phys3d_joints` rows) | same runner, `--only phys3d_joints_sweep,…,twopin` → `physics/author-runs-all` | — | **8/8 PASS** at the unchanged 20 s cap; `free_ops` `elapsed=2.89 s` |
| r104 after (full battery, 350 rows) | `python3 corpus/fixtures/run_battery.py --runs …/author-runs-full` | `PASS=336 / FAIL=14` (r102 receipt) | **`PASS=337 / FAIL=13`** — **the delta is exactly the one row this round repaired**, and the 13 survivors are **all** `r94_cannon_*` |
| **fixture digest** | `sha256sum corpus/fixtures/phys3d_joints.gd` | `88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73` (HEAD) | **`80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`** |
| runner digest | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00…f69f` | **`f456bd00…f69f` — unchanged, as required** |
| diff shape | `git diff --stat HEAD -- corpus/fixtures/phys3d_joints.gd` | — | **34 insertions(+), 7 deletions(-)** — `_run_child` split into `_spawn_child`/`_collect_child`, plus a `BATCH_BOUND_S := 16` batch deadline |
| **marker byte-identity** | row `free_ops` in both after receipts | 3921 bytes / `706ad915…` (pinned) | **3921 bytes / `706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74` — identical** |
| `CASES` row count | AST parse of `CASES` | 350 rows; 8 with `script='phys3d_joints.gd'` | **350 rows; 8 rows** (`physics/seeds.md` §5) |
| CASES-table invariance | `physics/seeds.md` §2–§5 (post-patch AST diff) | baseline 350 rows / 350 unique / 53 scripts / `expect_exit {0:291, 2:59}` | **`added=0 removed=0 edits=0 order_lcs=350/350`, exit 0** |
| comparator is falsifiable | `physics/seeds.md` §3 NC1–NC5 | — | **5/5 synthetic mutations exit 1**; the unmutated pair exits 0 |
| contrast class (unchanged) | the 19 `r94_cannon_*` rows in the r102 receipt | **13 FAIL / 6 PASS**, all fails `reasons=['exact stdout marker missing']` — node-marker drift, a **categorically different class** | unchanged this round |
| the row was the *only* non-cannon failure | same receipt | non-cannon FAILs = `[phys3d_joints_free_ops]` — **exactly one** | — |

**Known scope boundaries this claim does not close** (stated, not hidden):

- **The full-battery after-number is now measured, and it is the strongest single result of C1.**
  `physics/author-runs-full/20261018T192105574998Z/verdicts.json` → `cases=350`, **`PASS=337
  FAIL=13`**, `seeds_unchanged=true`, `case_timeout_seconds=20`. The before/after delta is **exactly
  one row**, and the 13 survivors are **all** `r94_cannon_*` with `reasons=['exact stdout marker
  missing']` — i.e. **zero non-cannon failures remain**, where r102 had one. This is the "counting
  command" the seat brief named, run to completion.
- **The after receipts are the author's own.** `physics/author-runs*` were produced by the C1
  author's seat. Non-author reproduction of the after state is `{{C1_NONAUTHOR_VERIFIER}}`; this seat
  read the receipts and re-ran the gate, but did not re-run the battery itself.
- **`phys3d_joints.gd` was still being written while SEAT-09 measured it.** Three digests were
  observed in sequence — `88be87fa…` (HEAD) → `0cd74715…` (intermediate, 11/5) → `c7e77638…`
  → `80bf44c5…`
  (final, 34/7). SEAT-09 anchored its verdict to `c7e77638…` after confirming it stable across three
  reads; the fixture then advanced once more to `80bf44c5…` (the batch-deadline revision). A
  close-time re-read is owed.
- **The r102 defect class is unchanged by this round's work.** The 13 `r94_cannon_*` node-marker
  failures still stand: the markers pin `node=v24.21.0` while the host runs v26.12.0. The receipt is
  gitignored (`corpus/.gitignore:1`), so the row list is the durable record. **Operator queue.**
- **The 6 `r94_cannon_*` rows that PASS in the same receipt** are worth noting for anyone who reads
  "13 cannon fails" as a uniform class — the node-marker class is load-sensitive too.
- **R3 trades a wall-clock cost for a concurrency cost, and the round built the adversary for it —
  and it passed.** SEAT-06's `physics/s06/worstcase.sh` runs **M private tree copies × 21 children**
  (so the only shared resource is CPU) against a serial solo reference, comparing each rep **byte-wise**
  against that reference. The landed results:

  | rep | serial wall | conc wall | verdict |
  |---|---|---|---|
  | `free_ops` M=4 | 22 203 ms | **3 232 ms** | `identical=4 differs=0` — **6.9× faster, zero byte drift** |
  | `free_ops` M=4 (b) | 23 714 ms | **4 410 ms** | `identical=4 differs=0` — **5.4× faster** |
  | `free_ops` M=6 | 26 051 ms | **6 394 ms** | `identical=6 differs=0` — **4.1× faster** |
  | `free_pair` M=2 | 11 636 ms | **3 029 ms** | `identical=2 differs=0` — **3.8× faster** |

  Corroborating, from SEAT-06's other harnesses: `s06/bytecmp.log` → `chain3` serial 5 417 ms / conc
  2 936 ms `IDENTICAL`; `twopin` serial 8 394 ms / conc 2 089 ms `IDENTICAL`; and `s06/pinanchor.log`
  → for `sweep`/`rid`/`free_pair`/`twopin` **both** the serial and conc trees reproduce the pinned
  marker (`serial==pin=True conc==pin=True`). So the concurrency change is byte-neutral *and* faster
  under adversarial load — which is exactly the claim R3 needs.
- **One `worstcase` log is not evidence, and the round says so.** `worstcase-free_pair-m3.log` shows
  `identical=0 differs=3 of 3`, but every rep is `rc=137` with `Killed` — **another seat's over-broad
  cleanup SIGKILLed the three serial parents**. `physics/adversary.md` §3c discloses this as the
  seat's own error and states the `m3` line *"should not be read as evidence for or against R3."*
  This seat agrees and reads the `m4`/`m4b`/`m6` logs instead. Worth noting that the same log is
  reused in `adversary.md` §188 as a genuine **mechanism** demonstration: the harness waited only on
  parents, so it reported the rep finished (`wall_ms=8393` against 11.6–26.1 s elsewhere) while
  **63 children were still live** — a real F2-class observation that a parent-only wait cannot see.

### C2 — coverage: gate workdir resilience

**The gate is now green on the default root — the fix moved the failure, not just the label.** The
flakiness was real and this seat reproduced both states inside one 90-second window; the landed
`WORK_ROOT` change makes the same default invocation pass.

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"      # 19:25Z, final landed gate
GATE unreal-mcp subtree
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.2G of 16G (80% used)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0                                      STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0                                      STEP=PASS
CARDS=13 EXPECTED=13 BAD=0  NAME_SET=OK NAME_BAD=0                            STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0      STEP=PASS
GATE RESULT: PASS (checks failed: 0)
rc=0
```

**The live flake, both states, same host — the RED was on the pre-fix script, the GREEN on the
landed one.**

| | command | observed |
|---|---|---|
| RED, ×5 consecutive (pre-fix, sha `577c8b54…`) | `for i in 1..5; do bash …/run_gate.sh; done` at `19:18–19:19Z` | every run `STEP=PASS STEP=BLOCKED STEP=PASS STEP=PASS` + **`GATE RESULT: FAIL (checks failed: 1)`** + **rc=1** — the third state was **lost** |
| RED, ×10 stored | `reports/round-104/lessons-carry-loop/run{1..10}.out` | 10/10 `GATE RESULT: FAIL (checks failed: 1)` |
| GREEN, ×10 consecutive | same command at `19:20:25Z` | `PASS=10 BLOCKED=0 FAIL=0 EMPTY=0` |
| **the third state, post-fix** | 8 consecutive default runs at `19:25Z` (sha `e5521304…`) | `rc=2 CHECK 2 BLOCKED (local-resource)` ×2, `rc=2 CHECK 2 BLOCKED (network)` ×2, `rc=0 OK` ×4 — **every BLOCKED run exited 2, and the two causes are now named differently** |
| GREEN, stored | `reports/round-104/gate/scratch/{seat40-run1,seat40-run2,seat40-final,live-gate}.out` | `GATE RESULT: PASS (checks failed: 0)`, `RC=0`, `real 0m0.830s` |
| network is **up** during the RED | `git ls-remote <url> main` at `19:19Z` | `a6aa73ad…  refs/heads/main`, **rc=0** — so the RED is **not** a network outage |

**Root cause pinned to a string, not inferred.**

```
$ W=$(mktemp -d); git clone --quiet <url> "$W/clone"; echo rc=$?
rc=128
$ W=$(mktemp -d); GIT_TRACE=1 git clone --quiet <url> "$W/c" 2>&1 | tail -3
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to '/tmp/tmp.XOyDIqNNFD/c/.git/description': Disk quota exceeded
$ df -h /tmp
tmpfs  16G  13G  3.1G  80%  /tmp
$ df -i /tmp
tmpfs  1048576  664980  383596  64%  /tmp
$ findmnt -no OPTIONS /tmp
rw,nosuid,nodev,nr_inodes=1048576,inode64,huge=advise,usrquota
$ W=$(mktemp -d -p /home/vgpnk); git clone --quiet <url> "$W/c"; echo rc=$?   # clone to /home
rc=0
```

The `/tmp` tmpfs carries `usrquota`; `df` still reports 3.1 G "available" because the **per-user
quota**, not the filesystem, is the binding limit — which is exactly why this presents as a silent
`rc=128` with **empty stderr** through the gate's own redirect (`>"$WORK/clone.log" 2>&1` produced a
0-byte log) and why `df` alone does not predict it. SEAT-13 sharpened this further: `echo hello >
$(mktemp -d)/f` → **rc=1**, and `dd … of=/tmp/probe bs=1M count=1` → **0 bytes copied**, while the
same write to repo-local disk succeeds at 3.7 GB/s.

| | command | observed |
|---|---|---|
| `GATE_WORKDIR`, scratch really rooted | `GATE_WORKDIR=<repo-local> bash …/run_gate.sh; echo rc=$?` | `WORK_ROOT=… (from GATE_WORKDIR)`, `WORK_ROOT_FREE=771G of 930G (16% used)`, all four `STEP=PASS`, **rc=0**; a live 20 ms poller saw the scratch dir **appear under the override and leave 0 residual** |
| `GATE_WORKDIR` variable exists | `grep -c 'GATE_WORKDIR' run_gate.sh` | **13** (was **0** pre-fix) |
| precedence implemented | `run_gate.sh:59` | `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`; `:93` prints the root and `:71` records the source |
| **scratch actually uses the root** | `grep -n 'mktemp' run_gate.sh` | `:124` `MANLOG=$(mktemp -p "$WORK_ROOT" …)`, `:145` `WORK=$(mktemp -d -p "$WORK_ROOT" …)` — the part that makes the knob real, not cosmetic |
| bad root is a named error, not a late obscure one | `GATE_WORKDIR=/nonexistent/xyz bash …/run_gate.sh` | `FAIL scratch root is not a directory: /nonexistent/xyz` + `set GATE_WORKDIR (or TMPDIR) to an existing writable directory` + **rc=1**, before any check |
| `TMPDIR` also works | `TMPDIR=<repo-local> bash …/run_gate.sh` | `WORK_ROOT=… (from TMPDIR)`, `GATE RESULT: PASS`, **rc=0** |
| default path inert | `bash …/run_gate.sh` with nothing set | `WORK_ROOT=/tmp (from default)` — existing callers unchanged |
| harness is syntactically sound | `bash -n reports/round-104/gate/flake_harness.sh` | **rc=0** (an earlier intermediate revision failed at line 115/128) |
| harness verdict | SEAT-15 `gate/flake-harness.md:22-23` | `TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 truncated=0 unexpected=0`; **`HARNESS RESULT: STABLE (10/10 runs returned PASS with a matching exit code)`**, rc 0 — with 6 negative controls proving it can report `FLAKY` |
| attack regression on the patched gate | SEAT-15 `gate/regression.md` | **11/11 content attacks DETECTED**; A1 range/list 4/4 as specified; A2 prose-hijack 2/2; A3 name set; **30/30 rows behave as specified** |

**Known scope boundaries this claim does not close** (stated, not hidden):

- **The mixed BLOCKED+FAIL code path still exists; this host no longer triggers it.** The exit block
  is unchanged (`run_gate.sh:436` `if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]`), so a run where
  CHECK 2 is BLOCKED **and** another check also fails still prints `GATE RESULT: FAIL` and exits 1 —
  the third state is lost in that combination. What changed is that the `-p "$WORK_ROOT"` wiring and
  the in-memory clone log removed this host's *trigger*, so all 4 BLOCKED runs this seat observed
  post-fix exited **2**. **Still open as a code path**, and worth a ruling on whether it is
  reachable in practice.
- **SEAT-15's regression suite is bound to a stale intermediate.** `gate/regression.md` §0 pins its
  verdicts to `b6d8c61afa94bfde…` (24 486 bytes); the gate then advanced to **`e5521304…`**
  (25 169 bytes). SEAT-15's own §0 warns about exactly this class (its `7903c589…` near-miss, where
  the banner printed `from GATE_WORKDIR` while `mktemp` was still bare). **The 30/30 result is
  therefore evidence for `b6d8c61a…`, not for the landed `e5521304…`** — a close-time re-run is owed,
  and this is the r103 lesson (*"falsification verdicts must name the target hash"*) applied to a
  passing verdict too.
- **The gate README now documents `WORK_ROOT`, but still carries a stale exit-semantics line.**
  `gate/README.md:292` still says *"There is no partial-pass state"* under the `1` exit code, while
  the split BLOCKED label and the W0–W5 matrix (added at `:381`) describe the third state. The
  contradiction r103 recorded at `:156-157` is narrowed but not closed.
- **The harness verdict was not measured by this seat.** SEAT-15 ran it; this seat ran the
  underlying gate loop directly (5 RED + 10 GREEN + 4 mixed post-fix runs), which is the same
  measurement without the harness's classifier. The two agree.
- **`flake_harness.sh` moved under this seat mid-read** (`4a95f582…` → `0db89013…` → `1aeec700…`).
  The landed revision passes `bash -n`; its own revision history is evidence the interface settled late.

### C3 — calibration: the `SKILL.md` decision table

| measurement | command | before | after |
|---|---|---|---|
| file exists | `ls -la SKILL.md` | absent (`README.md:11` — *"absent on lanes still in shonen seed form"*) | **present**, 182 lines |
| digest | `sha256sum SKILL.md` | n/a | `de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903` |
| section skeleton | `grep -n '^#\{1,3\} ' SKILL.md` | n/a | `:6` title · `:20` §1 table · `:60` §2 error patterns · `:77` §3 checklist · `:105` §4 open ruling · `:130` §5 refusals · `:150` §6 re-derivation |
| row count | §1 table rows | r102 draft: **4** rows (A–D) | **5** rows (**A–E**) — E is the lane-authored-static row the r103 review named as missing (`skill-table-review.md` §3.1) |
| source draft unchanged | `sha256sum reports/round-102/skill-decision-table-draft.md` | `fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2` | **unchanged** — the draft is the historical record, not rewritten |
| source review unchanged | `sha256sum reports/round-103/skill-table-review.md` | `95d40d92…` (quoted by `SKILL.md` §6) | **unchanged** |
| the F7 collision is stated, not papered over | `SKILL.md:105-127` §4 | n/a | §4 states the two vocabularies, names r101 F7, and **refuses to rule**: *"The P/C precedence ruling is still owed and is not this file's to make"* |
| the table's own authority is bounded | `SKILL.md:150-174` §6 | n/a | *"Landing this table satisfies the artifact half of `SHONEN.md` box 1. It does **not** close box 1"* |
| every row carries a canonical command + control | `grep -c '+NC' SKILL.md` | r102 draft: 2 rows had `+NC` | rows A, B, E carry a paired reject control |
| no bare gate line number carried | `grep -c 'run_gate.sh:' SKILL.md` | r102 draft carried 10 `gate/run_gate.sh:NN` cites, all rotted | **1**, and it is **prose in §2's citation rule** (`:54`, the sentence *"`gate/run_gate.sh:NN` citations had moved"*), **not a citation** — the gate is cited by `CHECK n <name>` and by sha only |

**Known scope boundaries this claim does not close** (stated, not hidden):

- **The `author.md` citations resolved mid-round, but only the author can vouch for them.**
  `SKILL.md` cites `reports/round-104/skill/author.md` §2 at `:42`, `:44`, `:45`, `:46` and `:153`;
  at `19:20Z` that path did not exist (`ls reports/round-104/skill/` → rc=2) and at `19:21Z` it did
  (20 222 bytes). The defect self-healed, but this seat did not re-run the commands `author.md`
  claims to have re-run — an author's own receipt is not a non-author verification, and the file's
  §6 says so. **The independent verification is `{{C3_NONAUTHOR_VERIFIER}}`.**
- **`SKILL.md` is at the repo root, outside the gate's scan root.** CHECK 4's `find` is anchored at
  `$SUB` = `corpus/knowledge/unreal-mcp` (`run_gate.sh:313`), so the gate **cannot** see a dangling
  pointer in `SKILL.md`. The transient defect above was invisible to the lane's only standing
  checker — which is why this seat found it by reading, not by running.
- **The gate ran `POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0` after `SKILL.md` landed, and
  `POINTERS=101` before it** — the count moved with the tree, exactly as the r103 lesson predicts,
  and the invariant `UNRESOLVED=0` held at every frame this seat measured. `POINTERS` is
  scanner-relative (`SKILL.md` §2 restates this as *scanner-relative datum*).
- **The P/C precedence ruling is still owed.** §4 states the collision honestly and does not resolve
  it. `corpus/knowledge/unreal-mcp/README.md`'s sha is unchanged (`c79d8dd1…`), so the six dissenting
  cards still disagree with the mapping. **Carried, not closed.**
- **Box 1 is not closed by this.** By the file's own §6, box 1 needs a **named non-author verifier**;
  no such verification of `SKILL.md` is among the r104 artifacts at this frame.

### Round-level deltas (surfaces measured so they are known to have or have not moved)

| surface | command | value |
|---|---|---|
| battery rows | AST parse of `CASES` in `corpus/fixtures/run_battery.py` | **350**; `run_battery.py` sha256 `f456bd00…f69f` — **unchanged** |
| fixture change surface | `git diff --stat HEAD` | **3 files, +245/−26** — `phys3d_joints.gd` (+34/−7), `gate/run_gate.sh` (+109/−14), `gate/README.md` (+115/−5); **every other fixture and subtree byte untouched** |
| fixture scope ruling | `physics/sentinel.md` §1 | **1 file changed under `corpus/fixtures/`** = SEAT-04's declared scope; `run_battery.py` byte-identical; **0 unlicensed edits** |
| gate identity | `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `577c8b54…` → **`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`**, 347 → **442** lines / 25 169 bytes |
| gate README | `sha256sum corpus/knowledge/unreal-mcp/gate/README.md` | `834f468d…` → **`e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`** (+110/−5: `WORK_ROOT`, W0–W5 matrix, split label) |
| pinned subtree | `git diff --name-only HEAD -- …/upstream …/.manifest.d` | **empty** — still byte-pinned |
| subtree file count | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | **42** (unchanged from r103 close) |
| `corpus/lessons/` | `ls corpus/lessons \| wc -l` | **93** (unchanged) |
| protected paths | `git hash-object` vs `git rev-parse HEAD:<path>` | `LOG.md` / `SCORECARD.md` / `SHONEN.md` / `PROVINCE.md` → **MATCH ×4** |
| tracked-file modification | `git status --porcelain \| grep -v '^??'` | **3 modified** (`phys3d_joints.gd`, `gate/run_gate.sh`, `gate/README.md`) — all declared scopes; **0 staged, 0 deletions** |
| `LOG.md` / `SCORECARD.md` last round | `grep -c 'ROUND 104' LOG.md`, `grep -c 'Round 104' SCORECARD.md` | **0 / 0** — r104 not yet recorded (expected pre-adjudication) |
| `SHONEN.md` checked boxes | `grep -c '^- \[x\]' SHONEN.md` | **1** (box 2 only) — unchanged |
| round-104 report files | `find reports/round-104 -type f \| wc -l` | **11 282** at `19:25Z` **[moving]** — was 2 at round start, 168 at `19:16`, 2 027 at `19:19` (the full-battery and worst-case scratch trees dominate) |
| upstream pin | `git ls-remote <url> main` | `a6aa73ad…` — **still the tip of `main`**, rc 0 (this seat + `freshness-pin.md`) |
| `/tmp` pressure | `df -h /tmp`; `findmnt -no OPTIONS /tmp` | **16 G, 13 G used, 80 %**; options include **`usrquota`** |
| full battery (after) | `python3 corpus/fixtures/run_battery.py --runs …/author-runs-full` | **`cases=350 pass=337 fail=13`** (`20261018T192105574998Z`); r102 before = `336 / 14`; **all 13 fails are `r94_cannon_*` node-marker**, 0 non-cannon |

---

## SHONEN 4-box lines

`SHONEN.md` currently reads box 2 `[x]` and boxes 1, 3, 4 `[ ]` (`grep -c '^- \[x\]' SHONEN.md` → 1).
Per the skill's report shape, one line per box. Marks below are this round's **evidence pointers**,
not self-attested checks: a `[x]` requires a named non-author verifier, a `[~]` is the lane's own
assessment with a resolvable pointer, and an untouched box stays `[ ]`.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]` — **the
  strongest move this round, and the one this seat judges closest to `[x]`.** `SKILL.md` now exists
  and carries exactly what the box names: a 5-row decision table with canonical commands and paired
  reject controls (§1), an error-pattern table with named search keys (§2), a checklist (§3), and
  six refusals (§5). It descends from two prior rounds of review rather than being written fresh.
  **The box is not closed, for three stated reasons:** (a) the file's own §6 says a named
  non-author verifier is required and none is named this round; (b) the four citations into
  `reports/round-104/skill/author.md` resolved only when that file landed mid-round, and an author's
  own receipt is not a non-author verification; (c) the P/C precedence ruling the table depends on
  (§4) is still owed. Verifier: **none named this round** — this seat flags the box as a candidate
  for `[x]` **only after** a non-author accepts the table and re-runs its commands.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2 —
  `game-dev-3d-r2-review-retry` independently reproduced both battery commands, the mutation
  rejection and the source contact-plane derivation (`corpus/lessons/r2-independent-review.md`).
  **r104 does not add an end-to-end domain task in the Unreal sense**: no Unreal Editor exists on
  this host. The round does add a real *headless Godot* result — the C1 fix moves a battery row from
  killed-at-the-cap to passing at 2.7 s with a byte-identical marker — but that is a harness/budget
  repair, not a new domain task, and this seat does not claim it as one.
- **Box 3 — instructions executable without oral context.** `[~]` — **moved, and this round can
  show it rather than assert it.** `SKILL.md` §3 is a checklist, §1 rows are runnable commands with
  controls, and §2's *implicit-cwd command* pattern names the exact defect that makes a command
  non-portable. The gate's air-gapped path (`GATE_REF`) and three-state exit contract remain from
  r103; the new `WORK_ROOT` reporting (`WORK_ROOT=<dir> (from GATE_WORKDIR|TMPDIR|default)` +
  `WORK_ROOT_FREE=…`) tells an operator what the gate did and where, and the split
  `BLOCKED (local-resource)` / `BLOCKED (network)` label sends them to the right subsystem — this
  seat ran all sources without any author input. **Residual blockers, all named and not closed:**
  `gate/README.md:292` still says *"There is no partial-pass state"* under the `1` exit code; the
  mixed BLOCKED+FAIL code path (`run_gate.sh:436`) still collapses to exit 1 when another check also
  fails; SEAT-15's 30/30 regression verdict is bound to a stale gate revision (`b6d8c61a…`, not the
  landed `e5521304…`); and no wrapper consumes the gate. Verifier: SEAT-12 (`gate/workdir.md`),
  SEAT-13 (`gate/workdir-verify.md`), SEAT-14 (`gate/flake-harness.md`), SEAT-15 (`gate/regression.md`),
  SEAT-40 (`gate/final-run.md`), SEAT-26/41/42 (hygiene) — six named non-authors, several re-running
  the gate. **Not a `[x]` this round.**
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` — every r104 artifact
  lives under the lane's own write scope. `reports/round-104/seats-ledger.md` (SEAT-42) reports
  **0 violations** with a per-blob method (strictly stronger than mtime or `git diff`), covering
  `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`, `corpus/fixtures/**` (except
  SEAT-04's two declared files) and `reports/round-101/102/103/**`. SEAT-08's
  `physics/sentinel.md` §1 sharpens that for the one path that *did* change: **exactly one file
  changed under `corpus/fixtures/` — `phys3d_joints.gd`, SEAT-04's declared scope — and
  `run_battery.py` stayed byte-identical throughout** because no r104 design doc named it, so the
  licensed set was correctly read as the single file. `reports/round-104/ledger-check.md` (SEAT-26)
  independently confirms the same, and `subtree-integrity.md` (SEAT-41) confirms the pinned region
  is byte-stable. This seat re-confirmed the four protected root files → **MATCH ×4**. The work is
  **static inspection plus headless-Godot evidence in service of 3D craft**, which `PROVINCE.md`
  permits for engines that cannot execute headless. No 2D, harness-audit, lore or live-target
  surface was touched. Verifier: SEAT-42 + SEAT-08 + SEAT-26 + SEAT-41 (all named non-authors) —
  but none was asked to rule on `PROVINCE.md` accuracy specifically, so this seat keeps it `[~]`.
  **One caveat:** untracked scratch directories appeared outside any declared round path
  (`.r104-seat17/`, `.r104seat43/` at the repo root); both were removed by their owners before this
  seat's last frame and neither was ever tracked, so no protected path was touched — but a cleaner
  convention would keep such scratch under `reports/round-104/`.

---

## Reproduce at close

Run from the lane root, on `2ca87e846981279c3323eec72cb51e081b9c447f`, after the untracked artifacts are committed:

```sh
# C1 — the wall-cost row. BEFORE reproduced, AFTER measured — both halves exist this round.
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /tmp/r104-phys3d
# BEFORE (HEAD fixture, 88be87fa…): FAIL … TIMEOUT after 20 seconds   [reproduced ×2]
# AFTER  (landed fixture, 80bf44c5…): PASS … freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} …  (2.669 s)
python3 corpus/fixtures/run_battery.py --only \
  phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,phys3d_joints_free_pair,\
phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin
# 8/8 PASS at case_timeout_seconds=20        [receipt: physics/author-runs-all/20261018T192041290482Z]
python3 corpus/fixtures/run_battery.py --runs /tmp/r104-full
# full 350 rows — cases=350 pass=337 fail=13, ALL 13 fails r94_cannon_* (r102 before = 336/14)
sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
#   f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  (350 CASES rows, UNCHANGED)
#   80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  (was 88be87fa… at HEAD)
git diff --numstat HEAD -- corpus/fixtures/phys3d_joints.gd   # 34  7
# marker byte-identity: reports/round-104/physics/markers.md — free_ops marker stays 3921 bytes / 706ad915…
# CASES-table invariance: reports/round-104/physics/seeds.md §5 — added=0 removed=0 edits=0 lcs=350/350
# R3 worst-case adversary (M private trees × 21 children): reports/round-104/physics/s06/worstcase.sh

# C2 — the gate, one command, four checks, fail-closed
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# expected at 19:25Z (final landed gate, e5521304…): GATE RESULT: PASS (checks failed: 0), rc=0
#   WORK_ROOT=/tmp (from default) / WORK_ROOT_FREE=3.2G of 16G (80% used)      [new lines]
#   MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0 / STEP=PASS
#   CLONE_HEAD=a6aa73ad… CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0 / STEP=PASS
#   CARDS=13 EXPECTED=13 BAD=0; NAME_SET=OK NAME_BAD=0; CENSUS 12/1/0 / STEP=PASS
#   POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0 / STEP=PASS   [moving]

# C2 — the workdir fix, all paths
GATE_WORKDIR=<repo-local dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# WORK_ROOT=<that dir> (from GATE_WORKDIR) / WORK_ROOT_FREE=771G of 930G (16% used) / PASS, rc=0, 0 residual
TMPDIR=<writable dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"          # PASS, rc=0
GATE_WORKDIR=/nonexistent/xyz bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# FAIL scratch root is not a directory: /nonexistent/xyz   →  rc=1, before any check runs
grep -c 'GATE_WORKDIR' corpus/knowledge/unreal-mcp/gate/run_gate.sh                           # 13 (was 0)
grep -n 'mktemp' corpus/knowledge/unreal-mcp/gate/run_gate.sh                                 # :124 and :145, both -p "$WORK_ROOT"

# C2 — the flake, reproduced and root-caused (this is the r104 finding)
for i in $(seq 1 10); do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; echo -n "$? "; done; echo
# 19:18Z (pre-fix): 1 1 1 1 1 (STEP=BLOCKED on CHECK 2, GATE RESULT: FAIL)   19:20Z: 0 0 0 0 0 0 0 0 0 0
# 19:25Z (post-fix): 2 2 2 2 0 0 0 0 — every BLOCKED run exits 2, and the cause is named
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
# a6aa73ad… refs/heads/main, rc=0  → the RED is NOT a network outage
W=$(mktemp -d); GIT_TRACE=1 git clone --quiet \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin "$W/c" 2>&1 | tail -2
# error: copy-fd: write returned: Disk quota exceeded
# fatal: cannot copy '/usr/share/git-core/templates/description' … Disk quota exceeded   (rc=128, 0-byte log)
findmnt -no OPTIONS /tmp        # … usrquota …  ← the binding limit is a per-user quota, not the 3.1 G df shows
bash -n reports/round-104/gate/flake_harness.sh                                             # rc=0
# harness verdict: reports/round-104/gate/flake-harness.md — TALLY pass=10 fail=0 empty=0 → STABLE, rc=0
# attack regression: reports/round-104/gate/regression.md — 11/11 DETECTED, 30/30 rows as specified
#   (bound to gate sha b6d8c61a…, NOT the landed e5521304… — re-run owed, see open items)

# C3 — the decision table landed
wc -l SKILL.md; sha256sum SKILL.md
# 182 SKILL.md ; de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903
grep -n '^#\{1,3\} ' SKILL.md                       # :20 :60 :77 :105 :130 :150
ls -la reports/round-104/skill/author.md            # present (20 222 bytes) — the re-derivation witness
grep -c 'run_gate.sh:' SKILL.md                     # 1 — the single hit is the §2 prose lesson, not a citation
sha256sum reports/round-102/skill-decision-table-draft.md reports/round-103/skill-table-review.md
#   fa360bde… / 95d40d92…  — both sources unchanged

# round-level invariants
git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d  # empty
git diff --stat HEAD                                # 3 files changed, 253 insertions(+), 26 deletions(-)
git status --porcelain | grep -v '^??'              # the 3 declared-scope files only
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
  [ "$(git hash-object -- $f)" = "$(git rev-parse HEAD:$f)" ] && echo "$f MATCH" || echo "$f DIFFER"; done
find reports/round-104 -type f | wc -l              # 2 → 168 → 2027 → 3362 → 98884 during drafting; [moving]
```

The gate is also reproduced inline in `reports/round-104/gate/{final-run.md,scratch/live-gate.out,scratch/seat40-run1.out,scratch/seat40-run2.out}`,
so a verifier never depends on a leftover `/tmp` file. The flake loop is stored at
`reports/round-104/lessons-carry-loop/run{1..10}.out`.

---

## Open items for the L1 / adjudicator

1. **`2ca87e846981279c3323eec72cb51e081b9c447f`** — this report is written pre-landing; the hash slot and every round-close
   number above must be filled from the committed tree. Counts marked **[moving]**
   (`reports/round-104/` file count, the pointer count, the untracked set) moved repeatedly during
   drafting and are the likeliest to need re-measurement. **`LOG.md` and `SCORECARD.md` carry zero
   r104 entries** — the L1's to land.
2. **C1 landed and the full-battery count is measured: `337 pass / 13 fail` (was `336 / 14`).** The
   delta is **exactly the one row this round repaired** — `phys3d_joints.gd` is `80bf44c5…` (+34/−7),
   the row passes at **2.669 s** (final fixture) / **2.768 s** (full-battery receipt) with a byte-identical 3921-byte marker, and all 8 `phys3d_joints`
   rows pass 8/8. The 13 survivors are **all** `r94_cannon_*` node-marker failures; **zero
   non-cannon failures remain**. Still owed: **non-author reproduction** of the after state
   (`{{C1_NONAUTHOR_VERIFIER}}`) and the **R3 worst-case result** (SEAT-06's M-trees × 21-children adversary — **measured, and it passed**: `identical=4 differs=0` at 6.9×/5.4× faster for `free_ops` M=4, `identical=6 differs=0` at 4.1× for M=6, `identical=2 differs=0` for `free_pair` M=2). The before-baseline, marker bank and CASES-invariance
   comparator are all landed and falsifiable (`added=0 removed=0 edits=0 lcs=350/350`).
3. **`GATE_WORKDIR` landed, wired, validated, and documented — the knob is real, not cosmetic.**
   `grep -c` → **13**; `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` at `:59` with up-front validation
   at `:60-68`; and — the part that decides whether the knob does anything — **both scratch sites now
   pass `-p "$WORK_ROOT"`** (`:124` `mktemp -p`, `:145` `mktemp -d -p`). This seat verified the root
   lands under the override and leaves nothing behind, and that a bad root is a named `FAIL` + rc=1
   before any check. `gate/README.md` was updated too (`834f468d…` → `e3bc66b7…`, +110/−5: the
   `WORK_ROOT` section, the W0–W5 control matrix, the split label). **Residual:** `gate/README.md:292`
   still says *"There is no partial-pass state"* under the `1` exit code, contradicting the third
   state the same file now documents. **Ruling owed** on whether `TMPDIR` alone suffices; the README
   contradiction is a one-line fix.
4. **The `BLOCKED (network)` mislabel is fixed by a label split.** `run_gate.sh:268` now prints
   `CHECK 2 BLOCKED (local-resource)` when the clone log matches a disk/quota pattern, with
   *"this is a DISK failure, not an unreachable upstream"* and a `GATE_WORKDIR` retry hint; a genuine
   network block still prints `CHECK 2 BLOCKED (network)` **verbatim**, so the r103 A4a control still
   matches. SEAT-12's `gate/workdir.md` W4/W5 controls both exit 2. This seat observed both labels in
   the wild (`local-resource` ×2, `network` ×2). **Closed as designed** — worth confirming at close.
5. **The mixed BLOCKED+FAIL code path still exists; this host no longer triggers it.** The exit block
   is unchanged (`run_gate.sh:436`: `exit 2` only when `C2_BLOCKED=1 && FAILS=0`), so a run with
   CHECK 2 BLOCKED **and** another check failing still prints `GATE RESULT: FAIL` and exits 1 — the
   third state lost in that combination. Pre-fix this seat saw that exact shape 5/5; post-fix all 4
   BLOCKED runs exited **2**, because the `-p "$WORK_ROOT"` wiring and the in-memory clone log removed
   the trigger. **Still open as a code path** — the L1 should rule whether it is reachable in practice
   or must be closed by construction.
6. **The `SKILL.md` citation defect self-healed, and the asymmetry that hid it is the real finding.**
   `SKILL.md` cites `reports/round-104/skill/author.md` §2 in five places; at `19:20Z` that path did
   not exist (`ls` → rc=2) and at `19:21Z` it did. Nothing caught it — because **CHECK 4's scan root
   is `corpus/knowledge/unreal-mcp` and `SKILL.md` is at the repo root**, so the lane's only standing
   checker is blind to its own skill file. **Open as a design question**, and it is item 9.
7. **An author's own receipt is not a non-author verification.** `SKILL.md` §6 says box 1 needs a
   named non-author verifier; `author.md` is the author's. `{{C3_NONAUTHOR_VERIFIER}}` is owed, and
   the natural shape is a seat that re-runs `author.md` §2's commands and reports what it observed.
8. **The P/C precedence ruling is still owed.** `SKILL.md` §4 states the collision and refuses to
   rule (correctly — the subtree is byte-pinned and the two sides belong to other seats).
   `corpus/knowledge/unreal-mcp/README.md` sha unchanged at `c79d8dd1…`, so the six dissenting cards
   still disagree. **Carried from r101 F7, three rounds running.**
9. **`SKILL.md` is at the repo root and no gate scans it.** If the lane intends its skill file to be
   covered by the standing checker, the scan root or a second root must be decided; otherwise state
   plainly that `SKILL.md` is verified by seats only. This is the design question behind item 6.
10. **SEAT-15's 30/30 regression verdict is bound to a gate revision that is no longer installed.**
    `gate/regression.md` §0 pins its results to `b6d8c61afa94bfde…` (24 486 bytes); the gate then
    advanced to **`e5521304…`** (25 169 bytes). SEAT-15's own §0 names this class of error — its
    `7903c589…` near-miss, where the banner printed `from GATE_WORKDIR` while `mktemp` was still bare
    and the knob was a no-op. **The 30/30 result is evidence for `b6d8c61a…`, not for the landed
    gate**; a close-time re-run is owed. This is the r103 lesson (*"falsification verdicts must name
    the target hash"*) applied to a **passing** verdict too — a green suite against a stale target is
    the same defect mirrored.
11. **The gate advanced four times inside one round** (`577c8b54…` → `7903c589…` → `b6d8c61a…` →
    `e5521304…`) while at least five seats were measuring it. Every seat that pinned a verdict to a
    hash was correct to do so; the round-level cost is that **no single revision was verified
    end-to-end by every suite**. A close-time consolidation run against the final sha is the only way
    to make the round's gate evidence cohere.
12. **The 13 `r94_cannon_*` node-marker failures are unchanged from r102.** Markers pin
    `node=v24.21.0` while the host runs v26.12.0. The receipt is gitignored (`corpus/.gitignore:1`),
    so the row list is the durable record. **Operator queue.** Note the same receipt shows 6 of 19
    cannon rows **PASS**, so the class is load-sensitive and not uniform.
13. **The `--path .` fixture-write hazard from r103 is not closed.** This seat did not observe a
    recurrence, but no guard was landed either. `reports/round-104/physics/` shows both the r103
    scratch-reuse artifact and fresh scratches side by side, which is the shape where it reappears.
    SEAT-08's `physics/sentinel.md` §1 confirms the *scope* held this round (1 licensed file changed,
    0 unlicensed), which is the evidence that would fail if the hazard fired.
14. **Untracked scratch directories appeared at the repo root during the round** (`.r104-seat17/`,
    `.r104seat43/`), outside any declared round path. Both were gone by this seat's last frame, and
    neither was ever tracked, so no protected path was touched — but the convention is worth pinning,
    since r104's own `ledger-check.md` §3 flagged the first of them while it existed.
15. **No live-editor evidence exists or can exist here.** Engine install is blocked pending operator
    Epic-account linking; re-checked this round, **nothing changed**. Every runtime claim in this
    round is `unproven-on-this-host`; nothing in the round asserts otherwise, and `SKILL.md` §5.1
    now makes that a written rule.

---

## L1 adjudication (close-out)

*To be filled at round close by the L1, after the work commit lands as `2ca87e846981279c3323eec72cb51e081b9c447f` and this
report is the last artifact to land.*

**Verdicts:** depth `{{V_DEPTH}}` · coverage `{{V_COVERAGE}}` · calibration `{{V_CALIBRATION}}`.

**Ruling — the C1 claim.** `{{RULING_C1}}`

**Ruling — the C2 claim (workdir resilience).** `{{RULING_C2}}`

**Ruling — the C3 claim (SKILL.md).** `{{RULING_C3}}`

**Ruling — the gate flake.** `{{RULING_FLAKE}}`

**Ruling — the `BLOCKED (network)` label (open item 4).** `{{RULING_BLOCKED_LABEL}}`

**Ruling — the mixed BLOCKED+FAIL code path (open item 5).** `{{RULING_MIXED}}`

**Ruling — the stale-target regression suite (open item 10).** `{{RULING_STALE_TARGET}}`

**Ruling — whether `SKILL.md` is inside the gate's scope (open item 9).** `{{RULING_SKILL_SCOPE}}`

**Honest limits:** the flake evidence rests on this host's `/tmp` quota state at `19:18–19:25Z` and
is a *frame*, not a constant — a second host may not reproduce it, and this host's own default-root
run went GREEN four times after the fix without the quota changing, so the *trigger* is intermittent
even where the *mechanism* is deterministic. The physics **after** receipts are the C1 author's own;
the full-battery after-count
(`337 / 13`) and the R3 worst-case adversary (`identical=M differs=0` across four reps) are both
measured and reported above.
The `flake_harness.sh` verdict is SEAT-15's, not this seat's. **The gate moved four times during this
seat's window and SEAT-15's 30/30 attack verdict is bound to a superseded revision** — so the round's
strongest gate evidence and its strongest attack evidence do not yet refer to the same bytes; a
close-time consolidation run is owed. `phys3d_joints.gd` was written four times during the round
(`88be87fa…` → `0cd74715…` → `c7e77638…` → `80bf44c5…`); every number above is anchored to
`80bf44c5…`, and a close-time re-read is owed. No live-editor claim exists anywhere; `verified-here` remains 0 on Unreal
surfaces by construction.

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** depth **improved** · coverage **improved** · calibration **improved**. The round
**admits** (work commit `2ca87e846981279c3323eec72cb51e081b9c447f`; this report lands last).

**C1 (depth) — the fix and its safety net.** SEAT-04 landed the r103-ruled fix: the seven
`phys3d_joints` arms now spawn their children as a concurrent batch (`_spawn_batch`, the
pattern `phys3d_events.gd:615-655` already ships), and the collection loop carries the
fail-closed deadline SEAT-01 demanded (`BATCH_BOUND_S := 16`, kill + named
`batch_timeout` failure — one notch below the per-case `BOUND_S = 20`, mirroring
`phys3d_events.gd`'s own bound). Measurements on the final bytes: L1 close run
`--only phys3d_joints_free_ops` → **PASS, 2.9 s, exit 0** (r102: killed at 20.008 s);
SEAT-07's full battery on the same bytes → **337/350** (`free_ops` PASS at 2.77 s,
336/336 previously-passing rows unbroken, the 13 `r94_cannon_*` rows unchanged,
`seeds_unchanged=true`; receipt
`reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`).
Determinism: serial vs concurrent arm outputs byte-identical (SEAT-06). Scope: only
`phys3d_joints.gd` changed; `run_battery.py` sha `f456bd00…` and all 350 CASES rows
AST-identical (SEAT-08/09).

**C2 (coverage) — resilience, verified where it matters.** `GATE_WORKDIR`/`TMPDIR`
landed and the L1 verified it end-to-end (PASS, scratch created and removed,
`WORK_ROOT`/`WORK_ROOT_FREE` reported). The gate README documented a `REPO` override the
script did not implement (SEAT-19 follow-up) — the L1 implemented
`REPO=${REPO:-…}` and verified both directions: bad-URL run → `CHECK 2 BLOCKED (network)`
+ `STEP=BLOCKED` + exit 2; clean run → PASS (gate sha now `390a25ae…`). Full attack
regression (SEAT-15) and SEAT-48's 6-run close series are durable under `gate/`.
The default-workdir flake class is root-caused live: the shared /tmp tmpfs has its
per-user quota exhausted (FS shows 3.1G free; a 4KiB write is refused) — deterministic
close runs use `GATE_WORKDIR`, and `temp-dir-dependent gate` is now a named SKILL.md
error pattern.

**C3 (calibration) — SKILL.md landed by revision, not by first draft.** The file landed
mid-round and was revised under fire: SEAT-19 (reviewer) found two mechanical defects,
SEAT-20 (critic) five label-column overreaches — all seven folds landed at close and the
acceptance greps read 0/1/2/0. The `⇔` overclaim is replaced by the conditional
(`unproven-runtime` only where a runtime path is identified; the six dissenting cards
take `static-only` + a cited contradiction); refusal 4 is reconciled with row D's
row-probe sense. The P/C precedence collision is stated as open (§4), not resolved by
this lane alone. SHONEN box 1: the artifact half is satisfied; the named-non-author-
verifier half remains open by design (SKILL.md §6 says so itself).

**Rulings recorded.** (1) SEAT-14's r103 A4 falsification = stale-intermediate race
(carried from r103). (2) The r104 fixtures-README conformance question is closed by the
r103 ruling's extension: fixture DOCS are repairable, fixture CODE is pinned — but the
stray-`r90bt_*`-dirs hazard (SEAT-32's observation, seen again from a peer probe) is
routed as a fixture write-isolation proposal. (3) The critic's sixth-row recommendation
(fixture-runtime claims) is routed, not folded — the table's "exhaustive" is now scoped
to the pinned subtree in-file.

**Honest limits.** The full-battery number above is SEAT-07's measurement on the final
fixture bytes; the L1's idle-host corroborating run (receipt
`corpus/live/runs/20261018T201215739340Z/verdicts.json`) **reproduced it exactly:
cases=350 pass=337 fail=13** — same classes, no new failures. The default gate run
remains load-sensitive while the host /tmp quota is exhausted. No live-editor claim
exists anywhere; `verified-here` on Unreal surfaces remains impossible by construction.
