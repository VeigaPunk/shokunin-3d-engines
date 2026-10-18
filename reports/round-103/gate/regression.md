# SEAT-15 REGRESSION-SUITE — r103 re-run of the 11-attack suite + README C1–C7 + comm-absent, against the CURRENT installed gate

**Seat:** SEAT-15 REGRESSION-SUITE · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only.
**Date:** 2026-10-18
**Harness:** `/tmp/r103suite/run_suite.sh`, `/tmp/r103suite/suite2.sh`, `/tmp/r103suite/build_min.sh`
**Raw logs:** `/tmp/r103suite/results.txt`, `/tmp/r103suite/suite2.txt`, `/tmp/r103suite/s2_*.txt`, `/tmp/r103suite/a4_*.txt`, `/tmp/r103suite/p_*.txt`

**No Unreal runtime claim.** Nothing in this report concerns Unreal Editor. The editor is not
installed on this host; a green gate is evidence about *bytes*, never about editor behavior.

---

## 0. The target moved mid-round — read this first

The seat brief said "the gate currently prints POINTERS=87 and passes clean". That was true when
the brief was written and **false by the time I ran**. The installed gate was rewritten by SEAT-09
while this round was in progress:

| when (this host, -0300) | `gate/run_gate.sh` sha256 | bytes | state |
|---|---|---|---|
| 15:15 (committed `c6f655d`) | `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96` | 13106 | r102-hardened; **no A1–A4**; scratch file hardcoded `/tmp/advgate/.h1` |
| 15:31 (my first baseline) | `412d1b84…` | 13106 | prints `POINTERS=88`, PASS, exit 0 |
| 15:39 → stable | **`577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0`** | **19347** | **A1–A4 landed** + SEAT-09 host-dependency fixes |

Commands (observed):

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # x3 over 6s at 15:41
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   (identical all three times)
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96
```

**Every result below is bound to revision `577c8b54…` (19347 bytes).** I snapshotted it to
`/tmp/r103suite/gate-pinned.sh` and the suite installs that snapshot into the throwaway copy, so a
later edit by a sibling seat cannot silently re-target the run. Live gate re-checked at the end of
the run: still `577c8b54…` (see §7).

What A1–A4 changed (from `diff c6f655d → 577c8b54`): A1 validates every endpoint of a `:a-b`
range / `:a,b` list and adds `POINTER_STRINGS`; A2 anchors CHECK 3's declaration match to five
label shapes so prose cannot hijack it; A3 compares the 13 card filenames against a pinned
`PINNED_CARD_NAMES` set (`NAME_SET=OK|BAD`); A4 makes an unreachable upstream a distinct `BLOCKED`
state with **exit 2**, plus `GATE_REF` for air-gapped runs. Two unrelated host fixes rode along:
the `/tmp/advgate/.h1` hardcode → `mktemp` (SEAT-09 comment, line 69) and check 4's repo root
renamed `REPO` → `REPO_ROOT` so `REPO=<url>` no longer repoints pass B.

---

## 1. Harness construction

`/tmp/advgate/verify_installed.sh` **survived** in `/tmp`, and I adapted it rather than rebuild the
attacks from `reports/round-102/gate/adversary-a.md`. The adaptation was forced by environment, not
choice:

- **/tmp quota.** `/tmp` is a 16 GB tmpfs shared with sibling seats under a per-user quota.
  `verify_installed.sh` and the r102 harnesses each `cp -a` the **whole lane repo (~725 MB)** per
  attack. Mid-run I hit `cp: error writing '…/three.webgpu.js': Disk quota exceeded` and
  `rsync: write failed … (122)`, which silently produced an incomplete workspace and a string of
  meaningless `exit=127` rows. Those first-run results are **discarded**, not reported.
- **Minimal workspace.** `build_min.sh` copies the full subtree (536 KB) plus **only** the files
  that the gate's own pass-B pointer extraction actually resolves (28 repo-relative paths, e.g.
  `reports/round-102/gate/adversary-a.md`, `corpus/knowledge/engines.md`) — 816 KB total.
  Verified equivalent to the live tree:

  ```
  $ bash /tmp/r103suite/build_min.sh
  rel pointers copied=28 unresolved_in_live=0  workspace=816K
  MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
  CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
  PATH_EXTRA=0 PATH_MISSING=0   BLOB_DIFFS=0
  CARDS=13 EXPECTED=13 BAD=0    CENSUS static-only=12 unproven-runtime=1 verified-here=0
  POINTERS=100 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
  GATE RESULT: PASS (checks failed: 0)
  ```

  This is the same verdict and the same `POINTERS=100` as the live tree at the same moment, so the
  trimmed workspace is a faithful stand-in. (Live `POINTERS` is `100`–`101` depending on the
  instant; see §6.)
- **Mutation-landed proof.** Every row records `applied(N)` — the count of `diff -rq` entries
  between the pristine workspace and the mutated one — so no attack can be scored against a
  mutation that did not take effect. (`applied(11)` = the eleven `seat*.sha256` files for H22;
  `no-mutation` = env-only probes.)

---

## 2. Summary table — all attacks, pinned revision `577c8b54…`

`DETECTED` = gate exited non-zero and named the failure. `PASS` = exit 0, as intended.

### A. Baseline

| # | scenario | exit | expected | result |
|---|---|---|---|---|
| A0 | clean tree, no mutation | 0 | PASS | **PASS** ✔ |

### B. The 11-attack suite (from `verify_installed.sh`, re-pointed at the current gate)

| # | attack | exit | expected | result |
|---|---|---|---|---|
| H2 | symlink planted in `upstream/` | 1 | DETECTED | **DETECTED** ✔ `FAIL non-regular file in pinned tree` |
| H3 | 14th card as symlink in `executability/` | 1 | DETECTED | **DETECTED** ✔ same |
| H4 | 14th card in a subdir of `executability/` | 1 | DETECTED | **DETECTED** ✔ `FAIL nested entry under executability/` |
| H1 | label `NOT-static-only` | 1 | DETECTED | **DETECTED** ✔ `FAIL label-too-deep … (line 97)`; census 11 |
| H1b | label `static-onlyness` | 1 | DETECTED | **DETECTED** ✔ same |
| H5 | dangling `executability/ghost.md:12` | 1 | DETECTED | **DETECTED** ✔ `MISSING-PATH-REL executability/ghost.md` |
| H6 | pointer with a space: `upstream/a b.md:5` | 1 | DETECTED | **DETECTED** ✔ `MISSING-PATH … upstream/a b.md:5` |
| H22 | all 11 `seat*.sha256` emptied | 1 | DETECTED | **DETECTED** ✔ `FAIL per-seat manifest sweep (--strict)` |
| H14 | CRLF in `audit-reference.sha256` | 1 | DETECTED | **DETECTED** ✔ `FAIL CR byte in manifest` |
| H21 | pointer `upstream/README.md:0` | 1 | DETECTED | **DETECTED** ✔ `LINE-ZERO` |
| H20 | uppercase `NOTES.MD` with out-of-range pointer | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR … (max 112)` |

**11/11 DETECTED.**

### C. README `gate/README.md` controls C1–C7

| # | control | exit | expected | result |
|---|---|---|---|---|
| C1 | append a byte to `upstream/README.md` | 1 | DETECTED | **DETECTED** ✔ `MANIFEST_OK=11 FAILED=1`; `BLOB-DIFF README.md` |
| C2 | delete `upstream/LICENSE` | 1 | DETECTED | **DETECTED** ✔ `RC=1`; `PATH_MISSING=1`; `BLOB-DIFF LICENSE` |
| C3 | plant `upstream/README.md:200` | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR … (max 112)`; `UNRESOLVED=1` |
| C4 | duplicate a label token on its label line | 1 | DETECTED | **DETECTED** ✔ `FAIL multi-label`; `BAD=1` |
| C5 | relabel a card `unproven-runtime` | 1 | DETECTED | **DETECTED** ✔ census `11/2/0` vs `12/1/0` |
| C6 | remove `executability/sequencer.md` | 1 | DETECTED | **DETECTED** ✔ `CARDS=12`; `NAME_SET=BAD`; `UNRESOLVED=1` |
| **C7** | plant **only** the exact sentinels | **0** | **PASS** | **PASS** ✔ `SKIPPED_CONTROL_SENTINELS=3`, `UNRESOLVED=0` |

**7/7 correct.** C7 is the filter's own positive control and still stays green — the sentinel
exclusion skips exactly the three exact strings and does not mask real pointers.

### D. A1–A4 — the new hardening's own probes

| # | probe | exit | expected | result |
|---|---|---|---|---|
| R1 | `upstream/README.md:1-9999` (range **tail** out of range) | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR … :1-9999 (max 112)` — **A1 works** |
| R2 | `upstream/README.md:112,9999` (list tail) | 1 | DETECTED | **DETECTED** ✔ |
| R3 | `upstream/README.md:0-5` (range head zero) | 1 | DETECTED | **DETECTED** ✔ `LINE-ZERO` |
| R4 | `upstream/README.md:1-3` (valid range) | 0 | PASS | **PASS** ✔ no false positive |
| A2 | prose "not `verified-here`" above a valid `**Label:**` | 0 | PASS | **PASS** ✔ — **A2 works**, prose no longer hijacks |
| A2b | prose token only, no declaration line | 1 | DETECTED | **DETECTED** ✔ `label-too-deep`; census 11 |
| A3 | rename `blueprints.md` → `blueprintz.md` (count still 13) | 1 | DETECTED | **DETECTED** ✔ `NAME_SET=BAD`; 2× `card-name-missing/extra` |
| A3b | drop `sequencer.md`, add `evil.md` (count still 13) | 1 | DETECTED | **DETECTED** ✔ `NAME_SET=BAD`; census 11 |
| A4a | `GATE_REF=/nonexistent` | 1 | DETECTED | **DETECTED** ✔ `FAIL GATE_REF is not a git clone` |
| A4b | `REPO=<bogus url>` (the old pass-B shadowing trap) | 0 | PASS | **PASS** ✔ — **A4b fix works**, no spurious `MISSING-PATH-REL` |

**A1, A2, A3, A4 all demonstrably effective.**

### E. A4 `BLOCKED` state — the headline claim, verified directly

A `git` wrapper that fails **only** on `clone` (passes `rev-parse`, `ls-files`, `status`,
`show` through to the real git) isolates the clone-failure branch:

| # | scenario | exit | expected | result |
|---|---|---|---|---|
| A4-1 | clone fails, nothing else wrong | **2** | BLOCKED | **BLOCKED** ✔ `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` |
| A4-2 | clone fails **and** a real failure exists | **1** | FAIL | **FAIL** ✔ `GATE RESULT: FAIL (checks failed: 1)` — BLOCKED never masks a real failure |
| A4-3 | `GATE_REF` = a clone at the pin | 0 | PASS | **PASS** ✔ `CLONE_HEAD=<pin>`, `BLOB_DIFFS=0`, no clone attempted |
| A4-4 | `GATE_REF` = valid repo at the **wrong** commit | 1 | DETECTED | **DETECTED** ✔ `FAIL clone HEAD != pin`, `tracked count 742 != 12` — divergence reads as FAIL, not BLOCKED |
| A4-5 | `GATE_REF` offline + a planted `:1-9999` | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR … UNRESOLVED=1` — offline mode still catches attacks |

**A4 behaves exactly as documented**: exit 0/1/2 is a genuine three-way distinction, `BLOCKED` is
not counted in `FAILS`, a bad `GATE_REF` is a FAIL (not a BLOCKED), and the offline path does not
weaken the pointer sweep.

### F. Tool robustness / determinism

| # | probe | exit | expected | result |
|---|---|---|---|---|
| D1 | `comm` absent from `PATH` | 1 | DETECTED | **DETECTED** ✔ `FAIL required tool missing: comm` |
| D3 | `git` absent from `PATH` | 1 | DETECTED | **DETECTED** ✔ `FAIL git not available` |
| D4 | `git` present but every subcommand fails | **2** | BLOCKED | **BLOCKED** ✔ (honest: nothing could be compared) |
| **D2** | **`comm` present but non-functional** | **0** | DETECTED | **✘ FALSE-PASS** — see §5 |
| E1 | determinism, 3 consecutive clean runs | 0,0,0 | identical | **identical** ✔ `POINTERS=100 POINTER_STRINGS=41 … UNRESOLVED=0`, `CARDS=13`, `NAME_SET=OK` on all three |

---

## 3. Verdict

**At revision `577c8b54…` (19347 bytes), the gate passes its full regression suite.**

- Clean tree → `GATE RESULT: PASS (checks failed: 0)`, exit 0.
- **11/11** of the r102 attack suite DETECTED.
- **7/7** of the README's own controls behave as documented (including C7 staying green).
- **A1, A2, A3, A4 all demonstrably effective** on purpose-built probes, and A4's `BLOCKED`/exit-2
  three-way state verified directly.
- Deterministic across repeated runs.

One residual defect found (§5), one systemic coupling worth flagging (§6).

**Evidence hygiene — the `D2` row in `/tmp/r103suite/suite2.txt` must not be read as a pass.** The
background suite finished with **34/34 rows and 0 mismatches**, but its `D2-comm-is-false` row is
**confounded**: that run's stripped `PATH` also lacked `cut`, so CHECK 2 failed for a different
reason and the row prints `DETECTED`/exit 1. That is a harness artifact, not a gate behaviour — it
is exactly why I re-ran the probe in isolation (§5) with the real `PATH` plus a single
non-functional `comm`. The isolated result is the valid one: **exit 0, `PATH_EXTRA=0
PATH_MISSING=0`, `GATE RESULT: PASS` on a tree carrying a stray file in `upstream/`.** Treat
`suite2.txt`'s `D2` row as a rejected measurement.

---

## 4. Reproduction

```sh
bash /tmp/r103suite/build_min.sh      # rebuild the trimmed workspace from the live tree
bash /tmp/r103suite/run_suite.sh      # 11 attacks + C1-C7 + extras  -> /tmp/r103suite/results.txt
bash /tmp/r103suite/suite2.sh         # pinned-revision suite        -> /tmp/r103suite/suite2.txt
```

The harnesses mutate only absolute paths under `/tmp` and never `cd` into the live repo. The
`rm -rf "$W"` in each `fresh()` targets `/tmp/r103suite/aw` only.

---

## 5. Residual defect — `comm` present but non-functional is a silent false-pass

The L1 tool guard tests only that a tool **exists** (`command -v comm`), never that it **works**.
`comm` is used solely by CHECK 2c (`comm -23` / `comm -13` to compute `PATH_EXTRA`/`PATH_MISSING`).
A `comm` that exists but fails (a shadowing wrapper on `PATH`, a broken binary) makes both
invocations return empty, so both counts print `0` and the path-set check **silently passes**.

Demonstrated — same stray file, two environments:

```
$ # control: stray file, working comm
$ printf 'ATTACKER BYTES\n' > $W/corpus/knowledge/unreal-mcp/upstream/stray.md
$ bash $W/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo exit=$?
PATH_EXTRA=1 PATH_MISSING=0
GATE RESULT: FAIL (checks failed: 1)
exit=1

$ # same stray file, comm present but non-functional
$ ln -sf /bin/false /tmp/r103suite/bin3/comm
$ env PATH=/tmp/r103suite/bin3:$PATH bash $W/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo exit=$?
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
exit=0
```

A stray file in `upstream/` — arbitrary attacker content entering the pinned tree — is **exactly**
the "over-full" case `gate/README.md` §CHECK 2 says CHECK 2c exists to catch. With a broken `comm`
it is missed and the gate is green. The r102 README claims the guard covers "shadowed/absent
tools"; this shows a **shadowed `comm` is not covered**.

Severity **low-to-medium**: it needs a broken `comm` on the runner's `PATH`, which is not the
normal case — but the failure is *silent* and lands on a high-severity class (content injection
into the vendored tree). It is a one-line fix in the same spirit as the existing guard: after the
`command -v` loop, prove each tool works, e.g. `printf 'a\n' | comm -23 /dev/null /dev/null ||
exit 1` (or simply treat a non-zero `comm` exit as a FAIL). **Not fixed here — this seat owns no
gate path**; routed as a residual for the gate's owner.

---

## 6. Systemic finding — the pinned subtree's gate is live-coupled to mutable peer files

`adaptation-kimi.md` (a byte-pinned subtree file) cites sibling-owned artifacts:

```
corpus/knowledge/unreal-mcp/adaptation-kimi.md:372:in `reports/round-103/note/author.md`.
corpus/knowledge/unreal-mcp/adaptation-kimi.md:506:same conclusion: `reports/round-103/note/urls.md` §4 (SEAT-07).
```

CHECK 4's pass B resolves `reports/**` backtick pointers against the **repo root** — which, for a
subtree gate, means against live peer working trees. Observed during this round, with **no
subtree change** (`git diff c6f655d..HEAD -- corpus/knowledge/unreal-mcp` is empty):

```
15:31  POINTERS=88   UNRESOLVED=0  PASS     (brief said 87)
15:37  POINTERS=89   UNRESOLVED=1  FAIL     <- reports/round-103/note/author.md had not landed yet
15:42  POINTERS=100  UNRESOLVED=0  PASS
```

The transient FAIL at 15:37 was **purely** the peer file being mid-write. So a gate that is
supposed to certify the pinned subtree can flip to red because a *different seat's report* is not
written yet — a false red, and equally a false green if a cited peer artifact is later deleted.

**Pointer-count pin drift.** `gate/README.md` pinned `POINTERS=87`; the live value moved
87 → 88 → 89 → 98 → **101** during this round, and the README was itself edited three times
(its pin text, and its own pass-B self-inclusion, which the current README now documents: pass A
excludes the self-file, pass B does not). The README's own words are the right conclusion, and I
confirm them by measurement: **`POINTERS` is not a stable contract** — it is scanner- and
tree-relative and self-referential. The binding invariant is `UNRESOLVED=0`. Anyone citing a
specific `POINTERS` value (including the brief's `87`) should cite the revision it was measured on.

Both are doc/process issues, not gate correctness bugs: CHECK 4 still resolves every path it
counts, so the coupling cannot *mask* a real failure — it can only manufacture a red or a green
from a peer edit. Routed to the L1 as a boundary observation.

---

## 7. Live state at close of this seat's run

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   (== the revision tested)
```

`gate/run_gate.sh` was still `577c8b54…` when this suite finished, so the results above describe
the gate as it stood at the end of the round's gate-hardening work — but note §0: it changed twice
inside this round, so any future re-run must re-pin the revision first.
