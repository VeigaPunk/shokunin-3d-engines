# r107-mut-gate — MUT-GATE seat (round 107, 3D side-round)

Seat KEY=MUT-GATE · lane `game-dev-3d-shokunin` · started 2026-10-19.
Mutation script: `reports/round-107/mutations/mut-gate.sh`.

**Plan (5 lines).**
1. Recover the gate's pin-mismatch class exactly: read `corpus/knowledge/unreal-mcp/gate/run_gate.sh` CHECK 2 (`CLONE_HEAD != PIN`, `BLOB_DIFFS`) and confirm which pin inputs are env-overridable.
2. Establish the old-pin tree (vendored `upstream/` @ `a6aa73ad`) and the refreshed gate's expected pin; note the observed no-drift finding (upstream `main` is still `a6aa73ad`).
3. Write `reports/round-107/mutations/mut-gate.sh`: stage the old-pin tree, run the refreshed gate at a MOVED pin, require REJECT; run the same-pin baseline and require PASS.
4. Construct the moved pin from real upstream objects (PR merge ref via `GATE_REF`) so no upstream content is fabricated; record exact commands + observed output, exit codes.
5. Record the detection matrix + what is NOT proven; label every claim [O]/[I]/[?]; UNPROVEN stays UNPROVEN; no writes into `corpus/knowledge/unreal-mcp/`.

STATUS: **DONE** — the refreshed gate REJECTS the old-pin tree on three independent
channels (2a, 2d, and the r107-new CHECK 5). 7/7 cases behaved as designed.

---

## 0. Scope + axes (Godspeed)

- **A1 falsifiability** — the mutation must produce a red for the *pin-mismatch* reason, not for a broken harness. Cases M-G0 (same pin → PASS) and M-G4 (coherent new tree → PASS) are the controls that prove the reds are caused by the pin move.
- **A2 independence** — the moved pin is a real commit object fetched from the same remote (PR #9 head `a5180ccd`), not an invented SHA.
- **A3 non-harm** — read-only against `corpus/`; all staging under `/var/tmp/r107-mut-gate/`; nothing landed.

## 1. The class under test, and the honest obstacle [O]

The gate's claim is *"the vendored bytes are byte-identical to upstream commit `$PIN`"*.
`run_gate.sh` hardcodes it at line 73 and carries it in two checks:

| site | signal on a moved pin |
|---|---|
| CHECK 2a | `FAIL clone HEAD != pin` (clone HEAD vs `$PIN`) |
| CHECK 2d | `BLOB-DIFF <path>` ×N, `BLOB_DIFFS=N` (vendored bytes vs `git show $PIN:<path>`) |
| CHECK 5 (r107-new) | `FAIL manifest header pin != PIN`, `FAIL pin-drift <file>:<line>` — the SHA restated in the subtree's prose |

**The obstacle, stated plainly [O].** A literal reading of the assignment — "run the
refreshed gate against the old pin's tree" — does **not** produce a mismatch this round,
because the round's "fresh pin" *is* the r101 pin:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main      exit 0
```

`PROVENANCE.md` §1 records the same `a6aa73ad…`, so there is no content delta to re-vendor.
The pin-mismatch class therefore has to be *exercised by construction* — a moved pin — and
that construction is what this seat's cases do. This is a finding, not a shortcut.

**The constructed moved pin [I] (input), [O] (gate behaviour).** The new pin is taken from a
**real upstream object**: PR #9's head `a5180ccd`, a genuine descendant of `a6aa73ad` with a
plausible next-`main` subject and an **identical 12-file path set** (only 3 file bodies differ):

```
$ git -C ref diff --name-only a6aa73ad a5180ccd
.claude-plugin/plugin.json
skills/unreal-mcp/SKILL.md
skills/unreal-mcp/references/operations.md
$ git -C ref merge-base --is-ancestor a6aa73ad a5180ccd && echo "alt is DESCENDANT of pin"
alt is DESCENDANT of pin
$ diff <(git ls-tree -r --name-only a6aa73ad|sort) <(git ls-tree -r --name-only a5180ccd|sort)
PATH-SETS IDENTICAL
```

The 12-file path-set identity matters: it isolates the *byte* mismatch (2d) from a
path-set mismatch (2c), which a PR that adds files would conflate.

## 2. Harness [O]

- **Gate under test.** The r107 refreshed gate, authored by GATE-LEAD, landed mid-run as
  `reports/round-107/mutations/gate-draft.sh`. It was still being edited by its author while I
  ran, so `mut-gate.sh` **freezes a copy** into `/var/tmp/r107-mut-gate/gate-frozen.sh` and
  names the revision it gated. The matrix below was reproduced end-to-end under **two**
  revisions (only the gate's own prose moved between them — one extra pin declaration):

  ```
  GATE_SRC_SHA256=d62705de5324a5dbf5b1ce69ce8d6086dcc3b32e236947dc4854bce2626906d1   (first full run)
  GATE_SRC_SHA256=0630198b0a81f407936e97ae1bf1650d97793e7185a449725960ddf8dacd2e61   (final re-run)
  ```

  Behaviour was identical across both; only the `checks failed` counts move by one because the
  gate's own README gained a pin declaration line (`PIN_DECL_LINES` 37→38). The figures quoted
  below are from the **final** revision unless noted.

  The installed r102..r106 gate (4 checks, no CHECK 5) is
  `sha256=390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`, used in M-G5.
- **Staging.** Each case builds a self-contained stand-in repo root under `/var/tmp/r107-mut-gate/stage/`:
  the subtree (prose + gate + executability + `.manifest.d`) with its `upstream/` replaced by
  the chosen pin's bytes, plus the 18 external `reports/…`/`corpus/…` paths CHECK 4 resolves
  (copied, never symlinked). The gate's `PIN=` constant is rewritten mechanically with `sed`.
- **The "refreshed gate" is simulated honestly.** For a non-r107 scenario the refreshed gate is
  the frozen draft with its `PIN=` rewritten; where the draft exists it is used verbatim.
- **Run command per case:** `GATE_WORKDIR=/var/tmp/r107-mut-gate/scratch bash <gate>`, 300 s timeout.
  Full transcripts: `/var/tmp/r107-mut-gate/out/<case>.out`; aggregate: `/var/tmp/r107-mut-gate/matrix.log`.

## 3. The matrix — 7 cases [O]

| # | gate @ pin | tree | upstream ref | expect | rc | GATE RESULT | failing signal |
|---|---|---|---|---|---|---|---|
| M-G0 | old `a6aa73ad` | old (old bytes) | `GATE_REF`@old | PASS | **0** | PASS | — (harness control) |
| M-G1 | new `a5180ccd` | **old** | `GATE_REF`@new | FAIL | **1** | FAIL (41) | `BLOB_DIFFS=3` + CHECK 5 drift |
| M-G2 | new | **old** | `GATE_REF`@old | FAIL | **1** | FAIL (41) | `FAIL clone HEAD != pin` + `BLOB_DIFFS=3` + CHECK 5 |
| M-G3 | new | **old** | network clone (moved `main`) | FAIL | **1** | FAIL (41) | `BLOB_DIFFS=3` + CHECK 5 drift |
| M-G4 | new | new (new bytes) | `GATE_REF`@new | PASS | **0** | PASS | — (satisfiability control) |
| M-G6 | new | new bytes, **stale prose** | `GATE_REF`@new | FAIL | **1** | FAIL (40) | CHECK 2 PASS, **only CHECK 5** rejects |
| M-G5 | **installed 4-check** @ new | new bytes, **stale prose** | `GATE_REF`@new | PASS | **0** | PASS | — (the blind spot the refresh closes) |

`(N)` = count of `^FAIL` lines in the transcript, from the final gate revision
(`0630198b…`); the first revision (`d62705de…`) printed one fewer on each of the
three `41`s and one fewer on the `40`, for the reason given in §2.

### 3.1 M-G0 — refreshed gate @ OLD pin, old tree → **PASS** (control) [O]

```
$ bash gate-frozen.sh   (PIN rewritten to a6aa73ad…)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
BLOB_DIFFS=0                                        STEP=PASS
CARDS=13 EXPECTED=13 BAD=0                          STEP=PASS
POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=0      STEP=PASS
MANIFEST_HEADER_PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
GATE_REF_README_PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
PIN_DECL_LINES=38 DRIFT=0                           STEP=PASS
GATE RESULT: PASS (checks failed: 0)                rc=0
```

**This is the load-bearing control:** the refreshed gate, run against the old pin's tree *at
the old pin*, is green. Every red below is therefore caused by the pin move, not by the
harness or by the refresh itself.

### 3.2 M-G1 — refreshed gate @ NEW pin, OLD tree, ref at new → **FAIL** [O]

The core mutation. CHECK 1 (manifests match the tree's own bytes) still PASSes — the old tree
is internally consistent; only the pin comparison catches it.

```
CHECK 2 clone-equivalence
GATE_REF=/var/tmp/r107-mut-gate/ref-new (offline reference; no clone attempted)
CLONE_HEAD=a5180ccd03c2813682a7fa19ca25ee9967bfe1de
CLONE_DIRTY=0   CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB-DIFF .claude-plugin/plugin.json
BLOB-DIFF skills/unreal-mcp/references/operations.md
BLOB-DIFF skills/unreal-mcp/SKILL.md
BLOB_DIFFS=3
STEP=FAIL
…
CHECK 5 pin-coherence
FAIL manifest header pin != PIN
FAIL gate/README upstream-pin row != PIN
FAIL pin-drift executability/blueprints.md:6 :: **Upstream pin:** … @ `a6aa73ada02a9…
… (38 pin declarations scanned, all 38 name the old SHA)
GATE RESULT: FAIL (checks failed: 41)     rc=1
```

Note `BLOB_DIFFS=3` is exactly the 3 files that differ between the two real commits — the
gate reports the true delta, not a blanket "everything differs".

### 3.3 M-G2 — ref at the OLD pin → **2a** fires [O]

```
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
FAIL clone HEAD != pin
BLOB_DIFFS=3
STEP=FAIL      GATE RESULT: FAIL (checks failed: 41)     rc=1
```

Same tree, same gate pin, different `GATE_REF` — this isolates **2a** (`clone HEAD != pin`) as
a *distinct* channel from **2d**. M-G1 and M-G2 are the 2d/2a pair.

### 3.4 M-G3 — the network clone path (no `GATE_REF`) [O]

To exercise the real `git clone` branch, the script builds a bare **upstream double** in
`/var/tmp/r107-mut-gate/mirror-new.git` whose `main` is forced to the new pin, and passes it as
`REPO=`. The input is labelled **[I] constructed**; the gate's behaviour on it is **[O]**.

```
MIRROR main -> a5180ccd03c2813682a7fa19ca25ee9967bfe1de  [I] constructed upstream double
CLONE_HEAD=a5180ccd03c2813682a7fa19ca25ee9967bfe1de
BLOB_DIFFS=3
GATE RESULT: FAIL (checks failed: 41)     rc=1
```

This is the only case where the gate performed a real clone; it agrees with the `GATE_REF`
cases. (The double is local, so this does not prove anything about the *public* remote — see §5.)

### 3.5 M-G4 — new bytes + refreshed prose → **PASS** (satisfiability control) [O]

```
CLONE_HEAD=a5180ccd03c2813682a7fa19ca25ee9967bfe1de
BLOB_DIFFS=0    MODE_DIFFS=0          STEP=PASS
MANIFEST_HEADER_PIN=a5180ccd…
PIN_DECL_LINES=38 DRIFT=0             STEP=PASS
GATE RESULT: PASS (checks failed: 0)  rc=0
```

The gate is **satisfiable at the new pin**: a correctly re-vendored, prose-coherent tree goes
green. Without this case the reds above would be consistent with a gate that is red by
construction.

### 3.6 M-G6 / M-G5 — the r107-new CHECK 5, and the blind spot it closes [O]

Same input (new bytes, manifests regenerated, **prose still naming the old pin**), two gate
revisions:

```
M-G6  refreshed 5-check gate:   CHECK 2 → BLOB_DIFFS=0  MODE_DIFFS=0  STEP=PASS
                                CHECK 5 → FAIL manifest header pin != PIN
                                          FAIL gate/README upstream-pin row != PIN
                                          + 38 pin-drift lines
                                GATE RESULT: FAIL (checks failed: 40)   rc=1

M-G5  installed 4-check gate:   CHECK 1/2/3/4 all STEP=PASS
                                (no CHECK 5 exists)
                                GATE RESULT: PASS (checks failed: 0)    rc=0
```

**The byte checks alone cannot reject this tree** — M-G6's CHECK 2 passes completely, and
M-G5 (the installed gate) is fully green on the identical tree. Only the refreshed gate's new
CHECK 5 rejects it. This is the discriminating evidence that the r107 refresh added a
genuinely independent rejection channel, and it is a *mutation result* about the gate, not a
claim about the upstream.

## 4. Detection matrix [O]

| mutation | channel expected | observed | caught? |
|---|---|---|---|
| old tree, gate pin moved, ref@new (M-G1) | 2d + 5 | `BLOB_DIFFS=3`, 37 drift lines, rc 1 | **YES** |
| old tree, gate pin moved, ref@old (M-G2) | 2a + 2d + 5 | `FAIL clone HEAD != pin`, `BLOB_DIFFS=3`, rc 1 | **YES** |
| old tree, moved-`main` clone (M-G3) | 2d + 5 | `BLOB_DIFFS=3`, rc 1 | **YES** |
| new bytes, stale prose (M-G6) | 5 only | CHECK 2 PASS; CHECK 5 FAIL, rc 1 | **YES** |
| same input under installed gate (M-G5) | none | all PASS, rc 0 | n/a — proves the blind spot |
| refreshed gate @ old pin, old tree (M-G0) | none | all PASS, rc 0 | control — no false red |
| new bytes + coherent prose (M-G4) | none | all PASS, rc 0 | control — satisfiable |

**Verdict [O]: the refreshed gate REJECTS the old pin's tree.** The rejection is the
pin-mismatch class (CHECK 2a/2d and, independently, the r107-new CHECK 5), it is *caused* by
the pin move (M-G0/M-G4 are green), and it is *not* a blanket red (M-G4 is green).

## 5. What this does NOT prove

- **[?] That upstream `main` has moved.** It has not: `git ls-remote` returns `a6aa73ad`
  [O]. The "new pin" is a real *descendant*, constructed as the moved pin. This seat proves the
  gate's *reaction* to a moved pin; it does not claim a real pin move occurred.
- **[?] Public-remote clone equivalence at a moved pin.** M-G3 clones a *local double*
  `[I]`; it exercises the gate's clone code path but says nothing about github.com reachability
  or content. The `GATE_REF` cases (M-G1/M-G2/M-G4/M-G6) never touch the network.
- **[?] That CHECK 5 is exhaustive.** It rejects the 38 declarations it *anchors*; a
  pin restated in a shape outside its anchor rules, or in a file extension it does not scan,
  is unproven. My M-G6 mutation only flips whole-file prose, not a partial restatement.
- **[?] Whether the real re-vendor will need prose changes.** If the orchestrator re-vendors at
  a genuinely moved pin, M-G4 shows a coherent tree passes; whether the *landed* subtree's
  prose is made coherent is the orchestrator's integration decision, not this seat's.
- **[I]** Because M-G0 is green, the frozen gate revision (`d62705de…`) does not
  false-positive on the current tree; any red the orchestrator sees later is a real change.

## 6. Artifacts

| path | what |
|---|---|
| `reports/round-107/mutations/mut-gate.sh` | the mutation harness (7 cases), self-contained |
| `/var/tmp/r107-mut-gate/out/M-G*.out` | full verbatim transcript per case |
| `/var/tmp/r107-mut-gate/matrix.log` | the aggregate run log (gate sha, refs, per-case rc + signals) |
| `/var/tmp/r107-mut-gate/gate-frozen.sh` | the exact gate revision gated (`sha256=d62705de…`) |
| `/var/tmp/r107-mut-gate/ref`, `ref-new` | real clones @ old / new pin (scratch) |
| `/var/tmp/r107-mut-gate/mirror-new.git` | `[I]` local upstream double for the clone path |

No file under `corpus/knowledge/unreal-mcp/` was written or modified by this seat.
