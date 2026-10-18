# SEAT-21 GATE-ADVERSARY-B — operational-robustness attack on `gate/run_gate.sh`

**Seat:** SEAT-21 GATE-ADVERSARY-B · round 102 · lane `game-dev-3d-shokunin`
**Owned path:** this file only. Nothing under the byte-pinned r101 subtree was modified.
**Target:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
`sha256 = 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` (200 lines)
**Target spec:** `corpus/knowledge/unreal-mcp/gate/README.md`
`sha256 = def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`
**Date:** 2026-10-18 · **Method:** every scenario actually executed on this host; logs kept in
`/tmp/r102-adv-b/logs/`.

## Verdict

The gate is **operationally robust for every realistic invocation** and **fail-closed on every
real defect I could plant** — 12/12 mutations were caught, none false-passed. Two of the four
adversarial invocation axes behave exactly as the README claims; two expose **latent gaps in
degraded environments** (below). Neither gap is currently *active* on the pinned tree, so the
gate's green run on HEAD is **not wrong** — but one of them (F2) is an **aggregate false-pass**,
which is the exact failure mode an adversary must report.

## How the axes were exercised

Harness (scratch, outside the repo): `/tmp/r102-adv-b/attack.sh`, `path-attack.sh`,
`mutation.sh`, `mut2.sh`. `S*` = invocation/path scenario, `M*` = defect mutation.

### Invocation and path axes — each must pass-correctly or fail-closed

| # | scenario | exit | verdict |
|---|---|---|---|
| S0 | baseline, repo root, absolute path | 0 | PASS-correct |
| S1 | cwd `/` | 0 | PASS-correct |
| S2 | cwd `/tmp` | 0 | PASS-correct |
| S3 | relative path from repo root | 0 | PASS-correct |
| S4 | `bash ./run_gate.sh` from gate dir | 0 | PASS-correct |
| S5 | direct exec `./run_gate.sh` (shebang) | 0 | PASS-correct |
| S6 | **git absent from PATH** | **1** | **FAIL-CLOSED** (`FAIL git not available`) |
| S7 | empty PATH | 1 | FAIL-CLOSED (see F3) |
| S8 | subtree at a path **containing spaces** | 0 | PASS-correct |
| S9 | repo via a **symlinked** path (cwd = symlink) | 0 | PASS-correct |
| S10 | `TMPDIR` contains spaces (clone scratch) | 0 | PASS-correct |
| S11 | `TMPDIR` is a symlink | 0 | PASS-correct |
| S12 | **symlink to `run_gate.sh` itself** | **1** | **FAIL-CLOSED** (all 4 checks red) |
| S13 | read-only subtree (gate must not write inside it) | 0 | PASS-correct |
| S14 | `sh run_gate.sh` (`/bin/sh` → bash here) | 0 | PASS-correct |
| S15 | git present but **clone fails** (stub git) | **1** | **FAIL-CLOSED** (`BLOCKED, not PASS`) |
| S16 | cwd is a path containing spaces | 0 | PASS-correct |
| S17 | relative path from a different cwd | 0 | PASS-correct |

The subtree is resolved from `BASH_SOURCE` (line 35: `SUB=$(cd "$(dirname
"${BASH_SOURCE[0]}")/.." && pwd)`), so cwd never matters — S1/S2/S16 confirm the README's
cwd-independence claim, and S8/S9/S13 confirm it survives spaces, symlinks and a read-only
tree. S12 is the *correct* failure: a symlink to the script resolves `SUB` to the symlink's own
directory, every check goes red, exit 1 — a **safe wrong-answer**, not a false-pass.

### Defect mutations — each MUST turn the gate red

| # | mutation | exit | caught by |
|---|---|---|---|
| M1 | append one byte to `upstream/README.md` | 1 | CHECK 1 (`FAILED=1`) + CHECK 2 (`BLOB_DIFFS=1`) |
| M2 | add stray `upstream/STRAY.md` | 1 | CHECK 2 (`PATH_EXTRA=1`) |
| M3 | delete `executability/blueprints.md` | 1 | CHECK 3 (`CARDS=12`) |
| M4 | plant `upstream/README.md:99999` | 1 | CHECK 4 (`UNRESOLVED=1`) |
| M5 | second label token on a card's label line | 1 | CHECK 3 (`label-unmarked`/multi-label, `BAD=1`) |
| M6 | delete `upstream/LICENSE` | 1 | CHECK 1 (`RC=1`) + CHECK 2 (`PATH_MISSING=1`) |
| p5 | plant `upstream/hooks/unreal-context.sh:99999` | 1 | CHECK 4 (`UNRESOLVED=1`) |
| p6 | plant `upstream/README.md:777` (non-sentinel OOB) | 1 | CHECK 4 (`UNRESOLVED=1`) |

**No false-pass on any planted defect.** This independently reproduces the gate README's own
control matrix (C1–C6); p6 confirms the sentinel filter is exact (777 is not a sentinel and is
caught). M2's `PATH_EXTRA` path-set check is the strongest of the set — a hash-only gate would
miss a stray file entirely.

## Findings

### F1 — CHECK 4 silently ignores **extensionless** pointer targets (latent)

The sweep regex is `upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+` (line 192). The
literal `\.` means the path segment must contain a dot before the optional extension, so
pointers into `upstream/LICENSE`, `upstream/CODEOWNERS` or `upstream/.gitignore` are **never
swept**. Evidence — plant `upstream/LICENSE:99999` in `README.md`:

```
### p1-license-oob   exit=0  *** FALSE-PASS ***
    POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
    GATE RESULT: PASS (checks failed: 0)
```

**Latent, not active.** No `upstream/<ext-less>:<line>` pointer exists in the subtree today
(`grep -rhoE "upstream/[A-Za-z0-9_./-]+:[0-9]+"` minus the ext'd forms → empty), and the
extensionless mentions that *do* exist are `upstream/LICENSE: OK` hash lines with no `:<line>`,
so the current `POINTERS=40` is correct. The hole only opens if a future author writes a
`LICENSE:NN` pointer.

**Recommended fix (verified behavior-neutral).** Widen the regex to make the dot optional too:

```sh
grep -ohE "upstream/[A-Za-z0-9_./-]+(\.[A-Za-z0-9]+)?:[0-9]+" "$f" | sort -u
```

I ran the widened form against the real subtree: it yields **`POINTERS=40`**, identical to the
current regex (0 additions, 0 removals), and it still catches the F1 mutant
(`upstream/LICENSE:99999`). The three exact control sentinels still match and are still
skipped. So the fix removes the hole with zero change to the green run's numbers.

### F2 — `comm` absent from PATH → aggregate **false-pass** on a stray file (latent)

CHECK 2's path-set equality uses `comm` (lines 97–98) without a `command -v comm` guard. When
`comm` is missing, both pipeline substitutions yield the empty string, `wc -l` reads `0`, and
`PATH_EXTRA=0 PATH_MISSING=0` is printed as if the path sets matched — even with a stray file
present. With a stray `upstream/STRAY.md` and `comm` removed from PATH:

```
### extra-comm   exit=0
    line 97: comm: command not found
    PATH_EXTRA=0 PATH_MISSING=0
    BLOB_DIFFS=0
    GATE RESULT: PASS (checks failed: 0)
```

Contrast, **same mutant, normal PATH**: `PATH_EXTRA=1` → `STEP=FAIL` → exit 1. `comm` is
therefore isolated as the cause. This is the one scenario in the whole matrix that produced a
**green gate over a real defect** — a true false-pass, not merely a missing check.

**Recommended fix.** Guard the tools the same way `git` is guarded, and fail the check when a
required tool is absent, e.g. at the top of CHECK 2:

```sh
for t in git comm sha256sum; do
  command -v "$t" >/dev/null 2>&1 || { printf 'FAIL required tool missing: %s\n' "$t"; C2_PASS=0; }
done
```

and only run the `comm` comparison when `C2_PASS=1`. (The same shape as the existing
`git` guard on lines 81–83.)

### F3 — degraded PATH can make CHECK 4 **vacuously pass** (low severity)

With `find` missing from PATH, the CHECK 4 outer loop produces no files, so
`POINTERS=0 … UNRESOLVED=0` → `STEP=PASS` even though nothing was swept (full run still exits
1 because other checks fail). Under a fully empty PATH, CHECK 1 prints `MANIFEST_OK= EXPECTED=12
FAILED= RC=127` and CHECK 3 dies with `[: : integer expected`. The aggregate stays fail-closed
(exit 1) in both cases, so this is a **diagnostic** weakness rather than a false-pass: a
per-check PASS line is printed for a check that did not run. A minimal hardening is to assert
a non-zero `POINTERS`/`CARDS`/`MANIFEST_OK` before granting `STEP=PASS`, or to add the same
`command -v` guard for `find`, `sort`, `grep`, `sha256sum`.

## Recommendations (all non-blocking for the current green run)

1. **F2 is worth a one-line fix** — it is the only path to a green gate over a real defect. Add
   `command -v comm` (and `sha256sum`) to the required-tool guard.
2. **F1 is worth a one-line fix** — widen the pointer regex; verified neutral (`POINTERS=40`
   unchanged) and it closes a silent skip.
3. **F3** — optionally make each check's `STEP=PASS` conditional on having actually examined
   something, so a missing tool can never print a per-check PASS.
4. The gate already documents cwd-independence and ships a 7-row control matrix (C1–C7); this
   report adds the **environment-degradation** axis (missing tools) that the matrix does not
   cover. Recommend adding rows for "git absent", "comm absent + stray file", and "extensionless
   pointer" once fixed.

## What this report does not cover

- **No Unreal runtime claim.** The editor is not installed; nothing here promotes a
  `static-only` / `unproven-runtime` card, and a green gate is not evidence of live behavior.
- No test of CHECK 3's *semantic* question (does a label match its evidence) — that is a
  read-the-cards judgement no script makes, and the gate README says so.
- The invocation matrix was exercised on this host's bash 5.x with `/bin/sh → bash`. A
  non-bash POSIX `sh` was not available to test the shebang path; S14 therefore does not prove
  the script is POSIX-`sh`-clean, only that it ran under dash-as-bash.

## Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh          # baseline: exit 0
# env-degradation axes (harnesses are in /tmp, not committed):
bash /tmp/r102-adv-b/attack.sh  "$PWD/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
bash /tmp/r102-adv-b/path-attack.sh
bash /tmp/r102-adv-b/mutation.sh
```
