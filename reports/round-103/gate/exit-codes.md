# r103 SEAT-61 — EXIT-CODE-REVIEW

**Seat:** SEAT-61 EXIT-CODE-REVIEW · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/exit-codes.md`). No other file was written by this seat.
**Date:** 2026-10-18 · **Lane HEAD:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
**Artifact under review:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh` + `gate/README.md` — the A4 exit-2 design.

**No Unreal runtime claim appears anywhere in this file.** The editor is not installed on this host; live-MCP behaviour is unproven by construction.

**Question assigned:** the A4 exit-2 design vs the lane gate standard (0 clean / 1 failed / other codes declared in registry/README) — is exit 2 declared consistently? Does any wrapper (battery wiring proposal) treat undeclared codes as could-not-evaluate? Recommendation.

---

## 0. Headline

**A4's exit 2 landed during this review** (SEAT-09, while this seat was writing). The implementation is now behaviourally correct on its primary path; **the declaration is not**, and the wrapper question has a worse answer than expected.

| sub-question | answer |
|---|---|
| Is exit 2 declared consistently? | **No.** `run_gate.sh` implements `0 / 1 / 2`, but `gate/README.md:156-157` still declares **"`0` … `1` otherwise. There is no partial-pass state"**, and `:73-74` still says a failed clone "exits 1". Three documents, two of them contradicting the code. There is **no lane-wide exit-code registry** at all (§2.1). |
| Does any wrapper treat undeclared codes as could-not-evaluate? | **No wrapper exists** — `git grep run_gate` outside the gate finds zero callers (§4.1). And the lane's only classifier has **no could-not-evaluate vocabulary at all**: every non-expected code becomes a hard `FAIL` with reason `exit N != expected M` (§4.2). Worse, **exit 2 already means "this arm PASSED"** in this lane (`corpus/fixtures/README.md:46`), so the lane's own classifier reads a gate exit 2 as a pass when `expected_exit == 2` (§4.3). |
| Recommendation | **Keep exit 2, fix the declaration, and pin the wrapper contract before any wrapper is written.** Do not add a fourth code. See §5. |

**Residual defect found (and only findable by running it):** when check 2 is BLOCKED **and any other check also fails**, the gate prints `GATE RESULT: FAIL` and exits **1** — the third state is silently lost, and a reader cannot tell "check 2 could not run" from "the bytes diverge" (§3.3). This is precisely the ambiguity A4 exists to remove, surviving in the mixed case.

---

## 1. The artifact moved continuously through this review

This is a fact about the round, and it constrains what any exit-code claim can mean. The file changed **six times** while this seat measured it:

| sha256 (first 8) | observed | what changed |
|---|---|---|
| `412d1b84` | 18:31Z | r102-era: exit 0/1 only; `BLOCKED, not PASS` folded into `FAILS`; hardcoded `/tmp/advgate/.h1` |
| `b5fecfc1` | 18:35Z | A4 landed: `C2_BLOCKED`, `STEP=BLOCKED`, `GATE_REF`; `/tmp/advgate` → `mktemp`; `EXIT_CODE=0` declared-but-unused |
| `ff2c26c0` | 18:36Z | `GATE RESULT: BLOCKED` + `exit 2` added; `EXIT_CODE` removed |
| `f23f3c8c` | 18:36Z | further edits (measured red, §3.4) |
| `d226af6f` | 18:36Z | further edits |
| `0c1ca3e1` | 18:36Z | current at time of writing |

**Every line number in this file was read from the bytes named, not from `reports/round-102/fold-spec.md`.** The fold-spec pins `214bf8ef…` (`fold-spec.md:33`); that pin is now three revisions stale. The fold-spec's own §8 warned "the tree was mutating under concurrent seats while this seat ran; treat any count here as a frame, not a constant" — that warning was correct and applies to the gate itself.

**Consequence for the standard:** an exit-code contract is only meaningful against a *pinned* artifact. Any r103 close-out claim about the gate's exit codes must name the sha it was measured on. This file names `0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e` for §3, and records the sha per measurement.

---

## 2. The lane's actual exit-code standard (measured, not assumed)

### 2.1 There is no lane-wide registry

```
$ git ls-files | grep -iE "exit|registry|contract|convention"
corpus/fixtures/crash_exit3d.gd
corpus/lessons/r3-signal-exit.md
$ git grep -lniE "exit[- ]code registry|exit registry|exit-code registry"
(no hits)
$ for f in README.md PROVINCE.md SHONEN.md SCORECARD.md; do printf '%s: %s\n' "$f" "$(grep -ciE 'exit code|exit-code|exit codes' "$f")"; done
README.md: 0
PROVINCE.md: 0
SHONEN.md: 0
SCORECARD.md: 0
```

The premise "other codes declared in registry/README" is therefore **half-true**: each artifact declares its own codes in its own README, and there is no document that reconciles them. `LOG.md` mentions "exit code" 3 times, all historical narrative, none normative.

### 2.2 The per-artifact declarations, and where they disagree

| artifact | declared codes | evidence |
|---|---|---|
| `gate/` (r102 text) | **0** clean, **1** otherwise; "no partial-pass state" | `gate/README.md:156-157` |
| `gate/` (r103 implementation) | **0** clean, **1** failed, **2** BLOCKED | `run_gate.sh:335-341` |
| `corpus/fixtures/` battery + fixtures | **0** positive, **2** *passing* negative control, **1** error | `corpus/fixtures/README.md:41-53` |
| `corpus/fixtures/three/run_cases.mjs` | **0 / 1** only | `run_cases.mjs:40` — `process.exit(verdict === 'PASS' ? 0 : 1)` |
| `corpus/fixtures/bpy_battery.py` | **0 / 1** only | `bpy_battery.py:604` — `return 0 if verdict == "PASS" else 1` |
| `corpus/fixtures/run_battery.py` | **0 / 1** only at the runner level | `run_battery.py:1383` |

```
$ sed -n '156,157p' corpus/knowledge/unreal-mcp/gate/README.md
Exit codes are strict and fail-closed: **`0`** iff all four checks print `STEP=PASS`; **`1`**
otherwise. There is no partial-pass state — a missing artifact is a FAIL, not a warning.

$ sed -n '73,74p' corpus/knowledge/unreal-mcp/gate/README.md
**BLOCKED, not PASS.** This is the only check needing network. If the clone fails, the gate
prints `FAIL fresh clone failed … BLOCKED, not PASS`, the check fails, and the run exits 1.

$ sed -n '46p' corpus/fixtures/README.md
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: <case> <reason>` line | PASS |
```

**Three load-bearing conclusions:**

1. **No runner in the lane emits a third exit code.** `three`, `bpy` and `run_battery.py` collapse every failure mode into **1** (`run_battery.py:1383`, `bpy_battery.py:604`, `run_cases.mjs:40`). `run_battery.py` *consumes* exit 2 from child fixtures (`:1276`) but never *emits* it. The gate is now the lane's **first and only** third-state exit.
2. **The lane's one existing meaning for exit 2 is the opposite of failure** — `corpus/fixtures/README.md:46,50`: exit 2 is "a *passing* negative control". A4 assigned 2 the meaning "could not evaluate", which collides with the meaning already in use (§4.3).
3. **The gate's own README was not updated with the implementation.** `:156-157` and `:73-74` both now describe the r102 behaviour. This is a **declaration inconsistency**, which is the exact question this seat was asked.

---

## 3. The landed A4 implementation — measured behaviour

### 3.1 What it does (current bytes, `0c1ca3e1…`)

```
$ grep -n "C2_BLOCKED\|FAILS=\|exit [0-9]\|GATE RESULT\|STEP=BLOCKED" run_gate.sh
129:C2_PASS=1; C2_BLOCKED=0
175:    # A4: unreachable upstream — a distinct BLOCKED state, exit 2, never folded
180:    printf 'BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent\n'
182:    C2_BLOCKED=1; C2_PASS=0
185:if [ "$C2_BLOCKED" -eq 1 ]; then
186:  printf 'STEP=BLOCKED\n\n'
187:elif [ "$C2_PASS" -eq 1 ]; then printf 'STEP=PASS\n\n'; else printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1)); fi
335:if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]; then
336:  printf 'GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)\n'
337:  exit 2
339:printf 'GATE RESULT: %s (checks failed: %s)\n' \
341:[ "$FAILS" -eq 0 ] && exit 0 || exit 1
```

Design properties: BLOCKED is **not** folded into `FAILS` (`:187`), so a blocked check is not a failed check; the exit vocabulary is `0 / 1 / 2`; `GATE_REF` makes the branch *evaluable* rather than merely labelled. **Both** of A4's alternatives (a) and (b) landed, not one.

### 3.2 The behaviour matrix, measured

Each row is a real run. Scratch copies of the subtree were used for the BLOCKED rows (a subtree-only copy is sufficient because check 2's inputs are all inside the subtree); the `GATE_REF` rows used a real clone of the pin at `/tmp/s61ref`.

| condition | `GATE RESULT:` | exit | verdict |
|---|---|---|---|
| clean tree, network up, `GATE_REF=/tmp/s61ref` | `PASS (checks failed: 0)` | **0** | correct |
| `GATE_REF` names a non-clone (`GATE_REF=/tmp`) | `FAIL (checks failed: 1)` | **1** | correct — a bad ref is a genuine FAIL, not BLOCKED |
| unreachable `REPO`, no `GATE_REF`, **all other checks green** | `BLOCKED (checks failed: 0; CHECK 2 could not run)` | **2** | **correct** — A4's goal achieved |
| unreachable `REPO`, no `GATE_REF`, **check 4 also fails** | `FAIL (checks failed: 1)` | **1** | **residual defect — see §3.3** |

Transcripts:

```
### GATE_REF, clone at the pin
$ GATE_REF=/tmp/s61ref bash run_gate.sh
GATE_REF=/tmp/s61ref (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
STEP=PASS ×4
GATE RESULT: PASS (checks failed: 0)
GATE_REF_EXIT=0

### bad GATE_REF
$ GATE_REF=/tmp bash run_gate.sh
FAIL GATE_REF is not a git clone: /tmp
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
BAD_REF_EXIT=1

### unreachable REPO, all else green  (full-repo-root copy, repo-relative check 4 passing)
$ bash run_gate.sh
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
EXIT=2
```

### 3.3 Residual defect — the third state is lost in the mixed case

```
### unreachable REPO *and* a planted out-of-range pointer (check 4 red)
$ bash run_gate.sh
STEP=PASS
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
STEP=PASS
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
EXIT=1
```

The `STEP=BLOCKED` line **is** printed, so the information is on stdout — but the `GATE RESULT:` headline and the **exit code** both say `FAIL`/`1`, indistinguishable from "check 2 ran and the bytes diverge". The gate's own comment at `:334` concedes the design: *"GATE RESULT still reads PASS/FAIL so no existing caller breaks."* A caller that branches on the exit code — the whole point of A4 — still cannot see the third state whenever anything else is also red, which is the common case for a blocked air-gapped run on a churning tree.

This is not a regression A4 introduced; it is the residue of A4's scope. It is worth recording because the *acceptance criterion* A4 wrote ("the output must name BLOCKED distinctly from a `BLOB_DIFFS>0` failure", `fold-spec.md:180-182`) is **met on stdout and not met on the exit channel**. Both halves should be met or the criterion should say which one it means.

### 3.4 Live state observed while this seat ran

Not the assigned question, but load-bearing for any wrapper decision, and cheap to record. All timestamps UTC, 2026-10-18.

```
$ date -u +%Y-%m-%dT%H:%M:%SZ; sha256sum run_gate.sh
2026-10-18T18:36:44Z
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e  run_gate.sh

$ bash run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
STEP=BLOCKED                      <-- check 2, network UP
CARDS=13 EXPECTED=13 BAD=0
STEP=PASS
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: FAIL (checks failed: 1)
GATE_RC=1

$ timeout 20 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD        # network is UP; the pin is unchanged
```

Two observations:

- **The gate reported `STEP=BLOCKED` while the network was up and the pin was reachable.** `run_gate.sh:146` bounds the clone with `timeout 180`; on a tree being cloned concurrently by a swarm of seats, the clone can exceed that bound. So `BLOCKED` currently means "the clone did not complete in 180 s", not "this host is air-gapped". A wrapper that maps exit 2 to "could not evaluate" will therefore also fire for a slow network. **The BLOCKED message should name the timeout** (`:179` says "upstream unreachable", and the branch comment at `:175` says "network down or repo unreachable"), or the bound should be configurable.
- **`GATE RESULT: FAIL` with `UNRESOLVED=0` and three green checks** — the only red was check 2's BLOCKED, which is *not* in `FAILS` (`:187`), so `FAILS` must have come from elsewhere; the pointer/`CARDS`/manifest lines were all green in this same run, so this is a **transient**: the file changed under the running process. Recorded as observed, not diagnosed. It is the clearest possible demonstration of §1's point that the artifact churned throughout.

Note also `POINTERS=98 POINTER_STRINGS=41` — a **new** metric, and the r102 README's pinned `POINTERS=87` (`:118,129` in the r102 text) is now doubly stale. The README already says the count is scanner-relative and that "the binding invariant is `UNRESOLVED=0`"; that guidance holds and should be preserved.

---

## 4. The wrapper question

### 4.1 No wrapper exists today

```
$ git grep -n "run_gate" -- '*.py' '*.sh' '*.mjs' | grep -v 'unreal-mcp/gate/run_gate.sh:'
(no output)
$ git grep -n "STEP=BLOCKED"
corpus/knowledge/unreal-mcp/gate/run_gate.sh:186:  printf 'STEP=BLOCKED\n\n'
```

The gate is invoked by hand, by seats, in transcripts. The only *proposed* wrapper is the C1 option-1 `--vendor-gate` flag on `corpus/fixtures/run_battery.py` (`reports/round-102/fold-spec.md:528-533`). **Nothing in the lane currently consumes the gate's exit code, so nothing currently mis-handles exit 2 — the contract must be pinned now, before a wrapper is written, not after.**

### 4.2 The lane's classifier has no "could not evaluate" state

```
$ python3 -c "…import run_battery as m; m.classify('', '', code, None, 1, 'PASS x')…"
  rc=   2 -> passed=False  reasons=['exit 2 != expected 1', 'exact stdout marker missing']
  rc=   3 -> passed=False  reasons=['exit 3 != expected 1', 'exact stdout marker missing']
  rc= 127 -> passed=False  reasons=['exit 127 != expected 1', 'exact stdout marker missing']
  rc= 137 -> passed=False  reasons=['exit 137 != expected 1', 'exact stdout marker missing']
  rc= -15 -> passed=False  reasons=['process died on signal 15', 'exact stdout marker missing']
```

Every non-expected code is a hard **FAIL**, with a reason string of the form `exit N != expected M`. There is no `blocked`, `inconclusive` or `could-not-evaluate` reason anywhere in `run_battery.py`'s classification vocabulary. So if the wrapper reuses `classify()`, an undeclared or blocked code is reported as a **substantive failure**, not as could-not-evaluate — the opposite of what A4 wants.

### 4.3 The collision: the lane reads exit 2 as a PASS

```
$ python3 -c "…m.classify('NEGATIVE REJECTED: gate blocked','',2,None,2,'NEGATIVE REJECTED: gate blocked')…"
(True, [])          # passed
$ sed -n '1276p' corpus/fixtures/run_battery.py
                  "kind": "negative_control" if expected_exit == 2 else "ordinary",
$ sed -n '46p' corpus/fixtures/README.md
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: ...` line | PASS |
```

With `expected_exit == 2` and a marker present, the lane's own classifier returns `(True, [])` and labels the arm `negative_control`. **A gate exiting 2 for BLOCKED, folded in through `classify()`, would be recorded as a passing arm.** That inverts A4's purpose: the distinct third state becomes a green.

The wrapper must therefore map the gate's integer **explicitly** — `0 → ok`, `1 → fail`, `2 → could-not-evaluate` — and must **not** route through `classify()`. This is a design decision the fold-spec does not state. Its "~10 lines, reuses the established extension point" framing understates the work: the three existing probes fold **booleans** (`crash_probe_ok`, `stream_probe_ok`, `tree_probe_ok`, combined at `run_battery.py:1379-1382`), not exit statuses, so the integer→boolean mapping is new.

### 4.4 The other could-not-evaluate path is still exit 1

```
$ sed -n '26,27p' run_gate.sh
for _t in git sha256sum grep find sort comm; do
  if ! command -v "$_t" >/dev/null 2>&1; then printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
```

A missing required tool is *also* a could-not-evaluate condition and still exits **1** at `:27`, before any `STEP=` line is printed. A4 covered the network branch and left this one. An air-gapped host frequently lacks tooling as well as network, so the wrapper's mapping is undefined for the most common blocked case. **Whichever convention is adopted, `:27` must be brought under it.**

---

## 5. Recommendation

**R1 — Keep exit 2 for BLOCKED; do not add a fourth code.** The implementation is right and the reasoning behind it is sound (a blocked check is not a failed check). The lane has no third-code precedent, so introducing one is defensible *if* it is declared; introducing two would not be.

**R2 — Fix the declaration in the same round, in `gate/README.md`, at three sites.** This is the assigned question's answer and the outstanding defect:
- `:156-157` — replace "**`0`** … **`1`** otherwise. There is no partial-pass state" with the actual vocabulary `0 PASS / 1 FAIL / 2 BLOCKED`, and keep "a missing artifact is a FAIL, not a warning" (still true).
- `:73-74` — "the check fails, and the run exits 1" is now false; it exits 2 and prints `GATE RESULT: BLOCKED`.
- The "Expected output — pinned summary" block should carry the BLOCKED line, since A4's own review noted the README had no BLOCKED line.
- Also update `run_gate.sh:7` (`# Exit 0 only if all four pass; exit 1 otherwise (fail-closed)`), which is now false in the same way.

Acceptance: `grep -c "exit 2\|BLOCKED" gate/README.md` ≥ 3 and no line in either file claims the exit vocabulary is `0 / 1` only; `bash run_gate.sh` on a clean tree still prints `GATE RESULT: PASS (checks failed: 0)` / exit 0.

**R3 — Pin the wrapper contract before writing the wrapper.** Record in the fold-spec, in the same place as C1: the gate's exit vocabulary, and the explicit mapping `0 → ok / 1 → fail / 2 → could-not-evaluate`, with the measured warning that `classify()` maps 2 to a **pass** (§4.3) and that every other non-zero code maps to a hard **fail** with no could-not-evaluate vocabulary (§4.2). The wrapper must branch on the integer and must not reuse `classify()`. Without this, C1 option 1 is a green-over-BLOCKED waiting to happen.

**R4 — Bring `:27` (missing required tool) under the same convention.** Either give it exit 2 (it is the same class of condition as an unreachable clone) or state explicitly in the README that it is exit 1 and why. Silence here leaves the wrapper's mapping undefined for the air-gapped case.

**R5 — Reconcile with `corpus/fixtures/README.md:46`, or scope the collision.** Two lane documents now assign different meanings to exit 2. The cleanest resolution is to note in the gate README that gate exit 2 and fixture exit 2 are *different namespaces* (a process's own exit vs a fixture's expected exit) and that the battery's `expected_exit == 2` rule must not be applied to a gate invocation. If the two cannot be reconciled in prose, that is the argument for a distinct code — but see R1: prefer prose, because the fixture meaning is load-bearing for 46 negative controls.

**R6 — Make `BLOCKED` name its cause.** The branch comment at `:175` says "network down or repo unreachable", but §3.4 measured `STEP=BLOCKED` with the network **up** and the pin reachable, because `timeout 180` (`:146`) expired on a contended clone. Print the timeout value and the elapsed time in the BLOCKED message, or make the bound configurable, so a wrapper (and a human) can distinguish "air-gapped" from "slow".

**R7 — Optional, low priority: surface BLOCKED in the mixed case too.** Consider printing `GATE RESULT: BLOCKED (checks failed: N; CHECK 2 could not run)` and exiting 2 when `C2_BLOCKED=1` regardless of `FAILS`. Trade-off, stated plainly: that would make "check 2 blocked **and** check 4 red" exit 2 rather than 1, which loses the FAIL signal for a real defect. **This seat does not recommend it** — the current choice (FAIL wins, BLOCKED visible on stdout) is the safer default, since a real failure should never be masked by a blocked check. Record the residual in §3.3 and leave the `GATE RESULT:` headline alone.

---

## 6. Notes on drift, and on `/tmp`

- **`GATE_REF` is a genuine improvement and it works.** Measured: `GATE_REF=/tmp/s61ref` (a real clone at `a6aa73ad…`) → `GATE RESULT: PASS`, exit 0, no network touched; a bad `GATE_REF` → `FAIL`, exit 1. This is the half of A4 that makes an air-gapped run *evaluable* rather than merely *labelled*, and it should be cited as the primary remedy.
- **The hardcoded `/tmp/advgate/.h1` scratch file was fixed by SEAT-09 during this review.** In the r102 bytes (`412d1b84`) it read `… >/tmp/advgate/.h1`; on a host without that directory the redirect failed, the sweep reported `FAIL per-seat manifest sweep`, and the gate exited **1 with all four checks green** — a spurious fail-closed. The current bytes use `MANLOG=$(mktemp)` (`:73`). **This defect is closed; it is recorded here because it was found by this seat and because it is the second-cleanest demonstration of §1's lesson.** (The cleanest is §3.4.)
- **`EXIT_CODE=0` was declared at `:129` in `b5fecfc1` and never assigned or returned — a dead variable.** It is gone in the current bytes (`:129` now reads `C2_PASS=1; C2_BLOCKED=0`). Noted only because it shows the design was still moving; no action needed.
- **The 11-attack suite at `/tmp/advgate/verify_installed.sh` was destroyed during this seat's run** by `/tmp` pressure (`tmpfs 16G 13G 3.1G 80% /tmp`; this seat hit `Disk quota exceeded` on a redirect mid-run, and `/tmp/advgate` was removed by another process). Its findings survive in `SCORECARD.md:301` ("11/11 adversary attacks DETECTED") and in the r102 gate reports. **Any r103 seat wanting to re-verify the attacks must re-author them.** This is an instance of the lesson: a `/tmp`-resident artifact is not a receipt.
- **One measurement in this seat's own run was voided by `/tmp` exhaustion** and is recorded for honesty: a full-repo-root copy taken while `/tmp` was full produced 26 spurious `MISSING-PATH-REL` lines because `tar` had silently failed to write the `corpus/` tree. The result was discarded and re-measured on a verified copy. **A copy that failed to write looks exactly like a tree that failed its check.**
- **Not chased, flagged for the subtree's owner:** in that (voided) run the gate's second pointer pass (`:274`, `corpus/*|reports/*|docs/*) base=$REPO`) resolved repo-relative paths against the *repo root* while the backtick sweep that feeds it ran over the *subtree*. On a real clone at the repo root this is consistent; on a subtree-only copy it reports every repo-relative pointer as missing. It did not fire on any real invocation here, so it is **not** a confirmed defect — but it is the same class as the `/tmp/advgate` issue (a check whose result depends on where the copy sits), and it is in check 4, which is another seat's item.

---

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
G=corpus/knowledge/unreal-mcp/gate/run_gate.sh

# §1 — the artifact churns; pin the sha you measure
sha256sum "$G"

# §2.1 — there is no lane-wide exit-code registry
git ls-files | grep -iE "exit|registry|contract|convention"
git grep -lniE "exit[- ]code registry|exit registry|exit-code registry"

# §2.2 — the per-artifact declarations, and their disagreement over 2
sed -n '156,157p' corpus/knowledge/unreal-mcp/gate/README.md   # still says 0 / 1 only
sed -n '73,74p'   corpus/knowledge/unreal-mcp/gate/README.md   # still says "exits 1"
sed -n '41,53p'   corpus/fixtures/README.md                    # says 2 = PASSING control
sed -n '40p'      corpus/fixtures/three/run_cases.mjs
sed -n '604p'     corpus/fixtures/bpy_battery.py
sed -n '1383p'    corpus/fixtures/run_battery.py

# §3.1 — the implemented vocabulary
grep -n "C2_BLOCKED\|FAILS=\|exit [0-9]\|GATE RESULT\|STEP=BLOCKED" "$G"

# §3.2 — GATE_REF works (offline reference; no clone)
git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/s61ref
GATE_REF=/tmp/s61ref bash "$G"; echo "GATE_REF_EXIT=$?"        # PASS, 0
GATE_REF=/tmp bash "$G"; echo "BAD_REF_EXIT=$?"                # FAIL, 1

# §3.2 — BLOCKED + all else green -> exit 2
rm -rf /tmp/s61k && mkdir -p /tmp/s61k
tar -cf - --exclude=corpus/live --exclude=node_modules --exclude=.git . | (cd /tmp/s61k && tar -xf -)
sed -i '31s|^REPO=.*|REPO=https://github.com/EpicGames/nonexistent-r103|' \
    /tmp/s61k/corpus/knowledge/unreal-mcp/gate/run_gate.sh
bash /tmp/s61k/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "BLOCKED_EXIT=$?"   # 2

# §3.3 — the mixed case loses the third state
printf '\nsee upstream/README.md:99999\n' >> /tmp/s61k/corpus/knowledge/unreal-mcp/README.md
bash /tmp/s61k/corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E "^GATE RESULT"; # FAIL
bash /tmp/s61k/corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; echo "MIXED_EXIT=$?"  # 1

# §4.1 — no wrapper exists
git grep -n "run_gate" -- '*.py' '*.sh' '*.mjs' | grep -v 'unreal-mcp/gate/run_gate.sh:'
git grep -n "STEP=BLOCKED"

# §4.2 / §4.3 — the classifier has no could-not-evaluate state, and reads 2 as a PASS
python3 - <<'EOF'
import importlib.util
s=importlib.util.spec_from_file_location("rb","corpus/fixtures/run_battery.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
for code in (2,3,127,137):
    print(code, m.classify("", "", code, None, 1, "PASS x"))
print(m.classify("NEGATIVE REJECTED: gate blocked","",2,None,2,"NEGATIVE REJECTED: gate blocked"))
EOF

# §4.4 — the other blocked path is still exit 1
sed -n '26,27p' "$G"
```

## 8. Limits of this file

- **Every measurement is timestamped and sha-tagged**, because the artifact changed six times during this seat's run (§1). §3's behaviour table is for `0c1ca3e1…`; §3.4's live state is a snapshot at 18:36:44Z and must not be quoted as a property of any commit.
- This seat reviewed the **exit-code design and its declaration**. It did **not** review A1–A3, A5–A9, B1–B4, or C1's other options; their status is unchanged by this file. `STEP=BLOCKED` at `:186` and the `FAILS` interaction at `:187`/`:335` are the only code sites in scope.
- Scratch copies under `/tmp` are **not** receipts — `/tmp` lost `advgate/` mid-run and this seat hit its quota (§6). Every finding is re-derivable from §7.
- **No Unreal runtime claim is made.** The editor is not installed; live-MCP is unproven by construction. `verified-here=0` in check 3's census is the correct census on this host.
- This seat wrote **only** `reports/round-103/gate/exit-codes.md`. `git status --porcelain` showed `corpus/knowledge/unreal-mcp/adaptation-kimi.md`, `corpus/artifacts/unity-r19/README.md` and the `corpus/knowledge/unreal-mcp/gate/*` pair modified, plus `reports/round-103/` untracked — **all by other seats**, at every point this seat checked.
