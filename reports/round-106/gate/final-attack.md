# SEAT-106 FINAL-GATE-ATTACK — byte flip on a copy, plus comm-absent

**Seat:** SEAT-106 FINAL-GATE-ATTACK · round 106 · lane `game-dev-3d-shokunin`
**Owned path:** this file only. The live subtree was not written.
**Target:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Scanner sha256:** `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (442 lines)
**Lane HEAD at the run:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd`
**Scored run:** `2026-10-18T21:39:26Z` (UTC). Comm-absent check: `2026-10-18T21:38:43Z`.
**Raw logs:** `reports/round-106/scratch/seat106/logs/` (`12-clean.stdout`, `14-attack.stdout`, `05-comm.txt`). Scratch is not `/tmp` (per-user `/tmp` quota is exhausted).

**No Unreal runtime claim.** Unreal Editor is not installed on this host. A red or green gate is evidence about bytes and about the tool guard. It is not evidence of editor or MCP behavior. `verified-here` stayed 0 on both the clean copy and the attacked copy.

## Verdict

**Detected.** One in-place byte flip in a copy of `upstream/README.md` turned a green copy red. Exit **1**. The gate named that file twice: `upstream/README.md: FAILED` (CHECK 1, `MANIFEST_OK=11 FAILED=1`) and `BLOB-DIFF README.md` (CHECK 2, `BLOB_DIFFS=1`). CHECK 3 and CHECK 4 stayed `STEP=PASS`, so the red is the flipped file, not a harness-wide failure.

**Comm-absent: fail-closed.** With `comm` removed from `PATH` and the other required tools present, the installed script printed exactly `FAIL required tool missing: comm` and exited **1** before any check. Stderr was empty. No `STEP=PASS`, no `GATE RESULT`.

## Method

The gate resolves the subtree from its own path, so the attack runs a copy of `corpus/knowledge/unreal-mcp/` plus the 31 repo-relative paths CHECK 4 pass B resolves (`grep` of backtick `corpus|reports|docs` paths in the copy; all 31 existed in the live tree and were copied). `diff -rq` of the live subtree against the copy before the flip was **0 lines**. Upstream files 12/12, cards 13/13. Copy of `run_gate.sh` was `cmp`-identical to the installed script.

CHECK 2 used `GATE_REF=/var/tmp/r104suite/ref` (HEAD `a6aa73ada02a9fb1f5415bec491f9942c519b297`, `status --porcelain` count 0, origin `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`). No clone, no network, no `/tmp` scratch. The blob compare is still `sha256sum` of the vendored file against `git show <pin>:<path>`, which is the check that sees a flipped byte. `GATE_WORKDIR` was `reports/round-106/scratch/seat106/work`.

An earlier incomplete copy (destination directory missing, `cp` of the subtree failed) is **not scored**. Its logs are `02-clean.*` and `04-attack.*` in the same scratch dir. The scored pair is `12-clean` / `14-attack`.

## 0. Clean control — the harness is not the source of the red

```sh
cd reports/round-106/scratch/seat106/ws
env GATE_WORKDIR="$PWD/../work" GATE_REF=/var/tmp/r104suite/ref \
  /usr/bin/bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
echo "exit=$?"
```

Observed (`2026-10-18T21:39:26Z`): **exit 0**, stderr 0 bytes.

```text
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
GATE_REF=/var/tmp/r104suite/ref (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

`POINTERS=103` matches the current pin, so the minimal workspace reproduced the live sweep.

## 1. Classic attack — one byte flipped, same length

Same class as README control C1 (one vendored byte changed → CHECK 1 and CHECK 2 must fail). This seat flipped a byte in place rather than appending, so the length stayed 8398. Low bit of the first letter of `Control` (`upstream/README.md` offset 40, 0-based).

```text
offset=40 old=0x43 'C' new=0x42 'B'
context=b'or Claude Code\n\nBontrol Unreal E'
mut_bytes=8398
applied=1
cmp -l:  41 103 102
clean_readme_sha=483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
mut_readme_sha=159b40c59cd60645e8621c93566a4c1a55c73c4e8c00c24feb761212eb9589be
```

`cmp -l` printed one line (1-based offset 41, octal 103 → 102, which is `0x43` → `0x42`). `diff -rq` of the clean workspace against the mutated workspace printed one path: `upstream/README.md`. The copy's pre-flip sha matches the live file.

```sh
cd reports/round-106/scratch/seat106/mut
env GATE_WORKDIR="$PWD/../work" GATE_REF=/var/tmp/r104suite/ref \
  /usr/bin/bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
echo "exit=$?"
```

Observed: **exit 1**, stderr 0 bytes.

```text
FAIL per-seat manifest sweep (--strict) failed:
  upstream/README.md: FAILED
  sha256sum: WARNING: 1 computed checksum did NOT match
  upstream/README.md: FAILED
  sha256sum: WARNING: 1 computed checksum did NOT match
CHECK 1 manifest-byte-identity
upstream/README.md: FAILED
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL
CHECK 2 clone-equivalence
GATE_REF=/var/tmp/r104suite/ref (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB-DIFF README.md
BLOB_DIFFS=1
STEP=FAIL
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: FAIL (checks failed: 3)
```

The README C1 row lists failing checks **1, 2**. That still matches the numbered `STEP=` lines. The summary counter is **3** because hardening B (the per-seat `sha256sum --strict -c .manifest.d/*.sha256` sweep, before CHECK 1) also increments `FAILS`, and it also printed `upstream/README.md: FAILED` (twice — two manifests hash that file). That is extra detection, not a miss, and not a silent change to the README. CHECK 3 and CHECK 4 did not move.

## 2. Comm-absent quick check

Host `comm` is present (`/usr/bin/comm`). A directory was built with symlinks to every other tool the gate uses (`git`, `sha256sum`, `grep`, `find`, `sort`, …) and **not** `comm` (`bin_comm_count=0`). `PATH` for the run was that directory only (`env -i`). The interpreter was `/usr/bin/bash`, so the shebang did not depend on `PATH`. Target was the **installed** script. `GATE_WORKDIR` and `GATE_REF` were set only so a guard miss could not fall through into a `/tmp` clone; the guard did not fall through.

```sh
env -i PATH=reports/round-106/scratch/seat106/bin-nocomm HOME="$HOME" \
  GATE_WORKDIR=reports/round-106/scratch/seat106/work \
  GATE_REF=/var/tmp/r104suite/ref \
  /usr/bin/bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
echo "exit=$?"
```

Observed (`2026-10-18T21:38:43Z`):

```text
FAIL required tool missing: comm
```

**exit 1.** Stderr 0 bytes. `PATH=$BIN command -v git` resolved inside the bin dir; `command -v comm` printed `ABSENT`. The other four tools the loop checks before `comm` were on that `PATH`, so the miss is `comm` specifically, not an empty `PATH`.

## 3. Live tree untouched

After both scored commands, the live paths matched the pre-run identity:

```text
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  corpus/knowledge/unreal-mcp/upstream/README.md
mtime=2026-10-18 14:43:32.601836630 -0300 bytes=8398
porcelain=0
```

`git status --porcelain -- corpus/knowledge/unreal-mcp` was empty. The flip exists only under `reports/round-106/scratch/seat106/mut/`.
