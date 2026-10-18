# SEAT-15 GATE-REGRESSION-ATTACKS — r104 attack suite against the WORKDIR-PATCHED gate

**Seat:** SEAT-15 GATE-REGRESSION-ATTACKS · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only.
**Date:** 2026-10-18
**Harness:** `/var/tmp/r104suite/` — `build_min.sh`, `suite.sh`, `pin_current.sh`, `quota_proof.sh`, `flake_tight.sh`
**Raw logs:** `/var/tmp/r104suite/rows.txt` (the 31-row ledger), `out_<label>.txt` (one per row), `q_*.txt` (quota proof)

**No Unreal runtime claim.** Nothing here concerns Unreal Editor. The editor is not installed on
this host. A green gate is evidence about *bytes*; it is never evidence about editor behavior.

---

## 0. Target revision — the gate moved three times inside this round

The installed gate was being edited by SEAT-12 (the C2 workdir seat) while this suite ran. I
snapshotted each revision and pinned the copy into the throwaway workspace, so no row below can be
silently re-targeted by a later sibling edit.

| when (this host, -0300) | `gate/run_gate.sh` sha256 (first 16) | bytes | state |
|---|---|---|---|
| 16:16 (== `HEAD` 88c3b2c) | `577c8b54…` | 19347 | r103-hardened, A1–A4; scratch = bare `mktemp` |
| 16:20 | `7903c589…` | 21720 | + `WORK_ROOT` validated, but `mktemp` still bare → **knob was a no-op** |
| 16:22 | `b6d8c61a…` | 24486 | `mktemp -p "$WORK_ROOT"` at both sites + signal traps |
| 16:30 → stable | **`e5521304…`** | **25169** | + clone stderr captured in memory, and a disk-vs-network cause classifier |

```
$ for i in 1 2 3; do sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh | cut -c1-16; sleep 2; done
e55213049db7538d
e55213049db7538d
e55213049db7538d
```

**Every result below is bound to `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`
(25169 bytes).** `gate/README.md` sha at the same instant: `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`.

The whole suite was run at **both** `b6d8c61a…` and `e5521304…`; both passes gave 0 mismatches. The
numbers below are the `e5521304…` pass (31 rows), which adds A4-6 (§3.5).

A caution for the lane: the `7903c589…` intermediate is worth remembering as a near-miss. It printed
`WORK_ROOT=… (from GATE_WORKDIR)` and validated the directory, so it *looked* like the remedy had
landed — but both scratch sites still called bare `mktemp`, which ignores `WORK_ROOT` entirely. The
remedy is only real once `-p "$WORK_ROOT"` is passed; the printed banner is not the proof.

---

## 1. Method — minimal workspace, mutation-landed proof

The r103 harnesses under `/tmp` are gone, and `/tmp` itself was at its per-user quota for most of
this run (see §3), so I rebuilt from the method docs (`reports/round-102/gate/adversary-a.md`,
`reports/round-103/gate/regression.md`) on `/var/tmp` (root fs, 772G free).

`build_min.sh` copies the subtree (552 KB) plus only the 29 repo-relative paths the gate's pass-B
pointer extraction resolves → **844 KB total**, and it reproduces the live verdict exactly:

```
$ bash /var/tmp/r104suite/build_min.sh /var/tmp/r104suite/ws
pointers=29 copied=29 unresolved_in_live=0
workspace=844K
$ ( cd ws && env GATE_REF=/var/tmp/r104suite/ref bash corpus/knowledge/unreal-mcp/gate/run_gate.sh )
WORK_ROOT=/tmp (from default)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)          rc=0
```

(`POINTERS` reads `101` at `b6d8c61a…` and `103` at `e5521304…` — see §5. It is not a stable
contract; the pass-B pointer set grows as peer reports land.)

**Every row records `applied(N)`** — the number of `diff -rq` entries between the pristine workspace
and the mutated one — so no attack is scored against a mutation that did not take effect.

`GATE_WORKDIR=/var/tmp/r104suite/scratch` is exported for every row, so the suite itself is immune
to the `/tmp` pressure it is characterizing. Each row runs on a fresh `cp -a` copy; the suite never
`cd`s into the live repo.

Two rows were **rejected and rebuilt**, not reported:

- *H1 first attempt*: I edited line 3 of `blueprints.md`, but the label is on line 4, so the
  mutation never touched the label and the row read a spurious `rc=0`. Re-pointed at line 4;
  verified the mutation lands (`sed -n 4p` → `**Label:** \`NOT-static-only\``) before scoring.
- *First full pass*: 8 rows misbehaved. Every one carried the same signature — an **empty**
  `FAIL per-seat manifest sweep` log body — i.e. the harness was measuring `/tmp` exhaustion, not
  the gate. Discarded; re-run with the scratch root pinned. That discarded pass is what produced
  the §3 root-cause work.

---

## 2. Results — 31 rows, 0 mismatches

`DETECTED` = gate exited non-zero and named the failure. `PASS` = exit 0, as intended.

### A. Baseline control

| # | scenario | exit | expected | result |
|---|---|---|---|---|
| A0 | clean tree, no mutation | 0 | PASS | **PASS** ✔ `POINTERS=103`, `UNRESOLVED=0` |

### B. The 11 content attacks (`reports/round-102/gate/adversary-a.md` F1–F6)

| # | attack | applied | exit | result |
|---|---|---|---|---|
| H2 | symlink planted in `upstream/` | 1 | 1 | **DETECTED** ✔ `FAIL non-regular file in pinned tree` |
| H3 | 14th card as symlink in `executability/` | 1 | 1 | **DETECTED** ✔ same |
| H4 | 14th card in a subdir of `executability/` | 1 | 1 | **DETECTED** ✔ `FAIL nested entry under executability/` |
| H1 | label `NOT-static-only` | 1 | 1 | **DETECTED** ✔ `FAIL no-label`; census 12→11 |
| H1b | label `static-onlyness` | 1 | 1 | **DETECTED** ✔ `FAIL multi-label … **Verdict:** \`static-onlyness\`` |
| H5 | dangling `executability/ghost.md:12` | 1 | 1 | **DETECTED** ✔ `MISSING-PATH-REL executability/ghost.md` |
| H6 | pointer with a space: `upstream/a b.md:5` | 1 | 1 | **DETECTED** ✔ `MISSING-PATH … upstream/a b.md:5` |
| H22 | all 11 `seat*.sha256` emptied | **11** | 1 | **DETECTED** ✔ `FAIL per-seat manifest sweep (--strict)` |
| H14 | CRLF appended to `audit-reference.sha256` | 1 | 1 | **DETECTED** ✔ `FAIL CR byte in manifest` |
| H21 | pointer `upstream/README.md:0` | 1 | 1 | **DETECTED** ✔ `LINE-ZERO` |
| H20 | uppercase `NOTES.MD` with out-of-range pointer | 1 | 1 | **DETECTED** ✔ `LINE-OOR … (max 112)` |

**11/11 DETECTED.**

### C. A1 — every endpoint of a range / list

| # | probe | exit | expected | result |
|---|---|---|---|---|
| R1 | `upstream/README.md:1-9999` (range **tail**) | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR … :1-9999 (max 112)` |
| R2 | `upstream/README.md:112,9999` (list tail) | 1 | DETECTED | **DETECTED** ✔ `LINE-OOR` |
| R3 | `upstream/README.md:0-5` (range head zero) | 1 | DETECTED | **DETECTED** ✔ `LINE-ZERO` |
| R4 | `upstream/README.md:1-3` (valid range) | 0 | PASS | **PASS** ✔ `POINTERS=103 POINTER_STRINGS=42` — endpoints counted, no false positive |

### D. A2 — prose hijack

| # | probe | exit | expected | result |
|---|---|---|---|---|
| A2 | prose "emphatically not `verified-here`" above a valid `**Label:**` | 0 | PASS | **PASS** ✔ prose no longer hijacks the declaration |
| A2b | prose token only, no declaration line | 1 | DETECTED | **DETECTED** ✔ `FAIL no-label`; `BAD=1` |

### E. A3 — card name set

| # | probe | exit | expected | result |
|---|---|---|---|---|
| A3 | `blueprints.md` → `blueprintz.md` (count still 13) | 1 | DETECTED | **DETECTED** ✔ `NAME_SET=BAD`, `NAME_BAD=2`, `card-name-missing/extra` |
| A3b | drop `sequencer.md`, add `evil.md` (count still 13) | 1 | DETECTED | **DETECTED** ✔ `NAME_SET=BAD`, `NAME_BAD=2` |

### F. A4 — `BLOCKED` is a third state, not a flavour of FAIL

`git` wrapper failing **only** on `clone` (passes `rev-parse`, `ls-files`, `status`, `show` through):

| # | scenario | exit | expected | result |
|---|---|---|---|---|
| A4-1 | clone fails, nothing else wrong | **2** | BLOCKED | **BLOCKED** ✔ `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` |
| A4-2 | clone fails **and** a real failure exists | 1 | FAIL | **FAIL** ✔ BLOCKED never masks a real failure |
| A4-3 | `GATE_REF` = a clone at the pin | 0 | PASS | **PASS** ✔ `CLONE_HEAD=<pin>`, `BLOB_DIFFS=0`, no clone attempted |
| A4-5 | `GATE_REF` offline + a planted `:1-9999` | 1 | DETECTED | **DETECTED** ✔ offline mode does not weaken the sweep |
| A4-6 | clone fails with `Disk quota exceeded` | **2** | BLOCKED | **BLOCKED** ✔ `CHECK 2 BLOCKED (local-resource)` — see §3.5 |

### G. Tool robustness

| # | probe | exit | expected | result |
|---|---|---|---|---|
| D1 | `comm` absent from `PATH` | 1 | DETECTED | **DETECTED** ✔ `FAIL required tool missing: comm` |
| D3 | `git` absent from `PATH` | 1 | DETECTED | **DETECTED** ✔ `FAIL required tool missing: git` |
| D4 | `git` present, every subcommand fails | **2** | BLOCKED | **BLOCKED** ✔ honest: nothing could be compared |
| **D2** | **`comm` present but non-functional** | **0** | DETECTED | **✘ FALSE-PASS** — see §4 |

### H. Determinism

| # | probe | exit | result |
|---|---|---|---|
| E1 | 3 consecutive clean runs | 0,0,0 | **identical** ✔ `POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=0`, `CARDS=13`, `NAME_SET=OK` on all three |

**Verdict: at revision `e5521304…` (25169 bytes), 31/31 rows behave as specified.** 11/11 content
attacks detected, A1/A2/A3/A4 all demonstrably effective, clean control green, deterministic.

---

## 3. The C2 remedy, verified end-to-end — and the flake it closes

This is the part of the round's brief I can now answer with a reproduction rather than a ruling.

### 3.1 The root cause is live on this host, not historical

`/tmp` is a 16 GB tmpfs shared under a per-user quota. For most of this run it sat at the EDQUOT
edge:

```
$ dd if=/dev/zero of=/tmp/r104_probe.bin bs=1M count=1 status=none; echo rc=$?
dd: error writing '/tmp/r104_probe.bin': Disk quota exceeded
rc=1
$ M=$(mktemp); printf 'x%.0s' $(seq 1 900) >"$M"; echo rc=$? bytes=$(wc -c <"$M")
rc=1 bytes=0
$ df -h /tmp
tmpfs  16G  13G  3.1G  80% /tmp
```

A **900-byte** write into a `/tmp` file fails. That is the whole mechanism: the gate's own scratch
redirect could not flush 864 bytes of `sha256sum` output.

### 3.2 The r103 close-window flake, reproduced on a clean tree

At `577c8b54…` (the r103 revision), with `/tmp` squeezed and the tree **untouched**, `flake_tight.sh`
produced the r103 signature deterministically — `FAIL per-seat manifest sweep` with an **empty** log
body on a **clean** tree, 6/6:

```
tight-run1 rc=1 log_bytes=0
… (5/5 in the direct probe, then 6/6 gate runs)
tight-default-with-REF   rc=1 spurious_per_seat_FAIL=1 | MANIFEST_OK=12 … FAILED=0 RC=0;GATE RESULT: FAIL (checks failed: 2)
tight-default-noREF      rc=1 spurious_per_seat_FAIL=1 | … CHECK 2 BLOCKED (network);GATE RESULT: FAIL (checks failed: 1)
```

Note the two line-pairs: `MANIFEST_OK=12 … FAILED=0 RC=0` — **CHECK 1 says every byte is fine** —
while the hardening sweep two blocks above reports the manifest sweep as broken. The tree is
perfect; the scratch file could not be written. This is exactly the "silent or misleading failure"
r103 routed, and it is a **fail-closed spurious red**, the mirror image of a false green.

### 3.3 The remedy works, end-to-end, on the pinned revision

`quota_proof.sh`, pinned gate `e5521304…`, `/tmp` squeezed to EDQUOT in the middle of the run:

```
gate sha: e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08
=== 1. baseline, /tmp has room ===
baseline-default               rc=0   | GATE RESULT: PASS (checks failed: 0)
=== 2. /tmp squeezed to EDQUOT ===
squeeze coarse=8 fine=0
  /tmp 1MB write probe: dd: error writing '/tmp/r104_probe.bin': Disk quota exceeded  rc=1
quota-default-scratch          rc=1   | FAIL per-seat manifest sweep (--strict) failed:;GATE RESULT: FAIL (checks failed: 2)
quota-GATE_WORKDIR             rc=0   | GATE RESULT: PASS (checks failed: 0)
quota-TMPDIR                   rc=0   | GATE RESULT: PASS (checks failed: 0)
=== 3. cleanup, control ===
after-cleanup                  rc=0   | GATE RESULT: PASS (checks failed: 0)
```

Same tree, same instant, same revision — the **only** difference is where scratch lives. Default
scratch: red. `GATE_WORKDIR` (or `TMPDIR`) on the root fs: green. The remedy is real, and it is
**observable**, not just documented.

The banner is worth reading as evidence in its own right — it names the source and the free space:

```
WORK_ROOT=/var/tmp/r104suite/scratch (from GATE_WORKDIR)
WORK_ROOT_FREE=771G of 930G (16% used)
```

### 3.4 The patch's own controls

| # | probe | exit | observed |
|---|---|---|---|
| W1 | `GATE_WORKDIR=/nope/not/here` | 1 | `FAIL scratch root is not a directory: /nope/not/here` |
| W2 | `GATE_WORKDIR=/proc/sys` (exists, not writable) | 1 | `FAIL scratch root is not writable: /proc/sys` |
| W3 | `GATE_WORKDIR=relpath` (relative) | 1 | `FAIL scratch root is not a directory: relpath` |
| W4 | `GATE_WORKDIR` set **and** `TMPDIR` bogus | 0 | `WORK_ROOT=… (from GATE_WORKDIR)` — precedence holds, TMPDIR ignored |
| W5 | `GATE_WORKDIR=` (empty) | 0 | `WORK_ROOT=/tmp (from default)` — falls through cleanly |
| W6 | scratch dir after a run | — | **0 leftovers** — the EXIT/INT/TERM/HUP traps clean up |

The up-front validation is a genuine improvement over a bare `mktemp`: an unset or typo'd
`GATE_WORKDIR` now fails by **name**, before any check runs, instead of leaving `$WORK` empty and
surfacing later as an unexplained `BLOCKED`.

### 3.5 The disk-vs-network classifier (A4-6) — verified, and the r103 contract preserved

`e5521304…` added a branch that reads the clone's failure text and distinguishes a **local disk**
failure from an **unreachable upstream**. r103's actual root cause was exactly that confusion —
`git clone` dying on `error: copy-fd: write returned: Disk quota exceeded` was reported as
`BLOCKED (network)`, sending the reader to the wrong subsystem. Verified with a `git` wrapper that
fails only on `clone`, emitting that exact string:

```
$ git wrapper: echo "error: copy-fd: write returned: Disk quota exceeded" >&2; exit 128
A4-6-quota-block   expect=2  rc=2  applied=0  DETECTED
A4-6-header        CHECK 2 BLOCKED (local-resource)
A4-1-header        CHECK 2 BLOCKED (network)
```

The gate prints:

```
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
error: copy-fd: write returned: Disk quota exceeded
```

Two things to note, both good:

- **Exit 2 is unchanged** — the A4 contract (BLOCKED ⇒ 2) is not renegotiated by the new branch.
- **The r103 A4a control still matches verbatim.** The genuine-network path still prints exactly
  `CHECK 2 BLOCKED (network)` (row `A4-1-header` above), so the header string r103 pinned is
  preserved; the classifier only *adds* a distinct header for the disk case. Both headers were
  observed in the same suite run.

One honest limit: the classifier is a **grep over the clone's stderr**, so it is a heuristic, not a
proof of cause. A clone that fails for a local reason without emitting one of the matched phrases
(`disk quota exceeded|no space left|out of diskspace|write error|quota exceeded`) still reports as
`(network)`. That is the right failure direction — it stays fail-closed at exit 2 either way — but
the header should be read as a hint, not a diagnosis.

Worth recording as a design win: the same revision moved the clone log **into memory** before
touching disk (`C2_LOG=$(git clone … 2>&1)`, then a best-effort on-disk copy). Writing the
diagnostic straight to `"$WORK/clone.log"` put the evidence on the very filesystem that had just
filled, so the cause line was destroyed exactly when it was needed. This seat observed that
directly in §3.2: `FAIL per-seat manifest sweep` with an **empty** log body.

---

## 4. Residual defect — `comm` present but non-functional is still a silent false-pass

Carried over from r103 (§5 of `reports/round-103/gate/regression.md`), and **still live** at
`e5521304…` (re-confirmed at the final revision). The tool guard tests only that a tool *exists*
(`command -v`), never that it *works*.
`comm` is used only by CHECK 2c to compute `PATH_EXTRA`/`PATH_MISSING`; a `comm` that exists but
fails makes both invocations return empty, so both counts print `0` and the path-set check passes.

Demonstrated on a tree carrying a stray attacker file in the pinned `upstream/`:

```
$ # stray file, working comm (control)
$ printf 'ATTACKER BYTES\n' > aw2/corpus/knowledge/unreal-mcp/upstream/stray.md
$ ( cd aw2 && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ) | grep -E 'PATH_EXTRA|GATE RESULT'
PATH_EXTRA=1 PATH_MISSING=0
GATE RESULT: FAIL (checks failed: 1)          rc=1

$ # SAME stray file, comm present but non-functional
$ ln -sf /bin/false /var/tmp/r104suite/bin-commfalse/comm
$ ( cd aw2 && env PATH=/var/tmp/r104suite/bin-commfalse:$PATH bash …/run_gate.sh ) | grep -E 'PATH_EXTRA|GATE RESULT'
PATH_EXTRA=0 PATH_MISSING=0
GATE RESULT: PASS (checks failed: 0)          rc=0
```

Arbitrary attacker content entering the pinned tree — precisely the "over-full" case CHECK 2c exists
to catch — is missed, and the gate is green.

Severity **low-to-medium**: it requires a broken `comm` on the runner's `PATH`, which is not the
normal case. But the failure is *silent* and lands on a high-severity class (content injection into
the vendored tree). **Not fixed here — this seat owns no gate path.** One-line fix in the spirit of
the existing guard: after the `command -v` loop, prove each tool works, e.g.
`printf 'a\n' | comm -23 /dev/null /dev/null || exit 1`.

---

## 5. Boundary observation — the pinned subtree's gate is coupled to mutable peer files

Unchanged from r103 §6, and re-observed here. `adaptation-kimi.md` (a byte-pinned subtree file)
cites `reports/round-103/**`, and CHECK 4's pass B resolves `reports/**` against the **repo root** —
i.e. against live peer working trees. The effect is real but bounded: it can manufacture a red (a
cited peer file not yet written) or a green (a cited peer file later deleted), but it cannot *mask*
a real failure, because CHECK 4 still resolves every path it counts. The binding invariant remains
`UNRESOLVED=0`; `POINTERS` is scanner-, tree- and self-relative and is **not** a stable contract.
`POINTERS=103` here is bound to `e5521304…` at this tree state — and it moved `101` → `103` between
two revisions of the gate inside this same round, purely from peer reports landing.

---

## 6. Reproduction

```sh
bash /var/tmp/r104suite/pin_current.sh     # snapshot + pin the installed revision into the ws
bash /var/tmp/r104suite/suite.sh           # 31-row attack suite  -> /var/tmp/r104suite/rows.txt
bash /var/tmp/r104suite/quota_proof.sh     # /tmp-EDQUOT remedy proof (trap-cleaned filler)
bash /var/tmp/r104suite/flake_tight.sh     # deterministic repro of the r103 flake class
```

The harnesses mutate only paths under `/var/tmp/r104suite/`; the `flake_*`/`quota_*` scripts fill
`/tmp/r104suite_filler` and remove it under `trap … EXIT INT TERM`, so the shared tmpfs is never
left full. Nothing outside the owned report path was written in the lane repo.

---

## 7. Live state at close of this seat's run

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08   (== the revision tested)
$ sha256sum corpus/knowledge/unreal-mcp/gate/README.md
e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf
```

`git status --short corpus/knowledge/unreal-mcp/` shows `M gate/run_gate.sh` and `M gate/README.md` —
the C2 patch is a working-tree edit by SEAT-12, not yet committed. Any re-run must re-pin first (§0):
this gate changed **four** times inside one round.
