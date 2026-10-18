# r102 fold-spec — the r103 fold/queue

**Seat:** SEAT-63 FOLD-SPEC · round 102 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-102/fold-spec.md`). No other file was written by this seat.
**Date:** 2026-10-18 · **Repo HEAD at authoring:** `2c99b7b` (r101 report-last; work commit `1659c036`)
**Axes served:** all three; the queue is weighted to **coverage** (the lowest non-retired axis) because
the r102 round's coverage artifact is the gate, and the gate's own residual gaps are coverage gaps.

## 0. What this file is, and what it is not

This is the **fold/queue spec for r103**: every r102 finding that should be folded, as a numbered
queue with an owner-seat suggestion and a **falsifiable acceptance** per item — a command whose
observed output decides PASS/FAIL, not a judgement call.

It is **not** a verdict, not a score, and not a repair. Nothing here was applied. Every item below
was re-derived by this seat on the current tree; where a sibling seat found it first, this file names
that seat's path and **re-runs the deciding command** rather than quoting it.

**Discipline carried forward (all items).** The r101 subtree `corpus/knowledge/unreal-mcp/` is
byte-pinned: `upstream/` and `.manifest.d/` are read-only to every seat except the one that owns an
explicit wording fix (item **B3**). Repairs elsewhere follow the correction-note rule — a historical
factual claim gets a **dated note**, never a silent rewrite; mechanical command/path conformance
fixes are applied in place. **No Unreal runtime claim is made anywhere in this file:** the editor is
not installed, and live-MCP behaviour is unproven by construction.

## 1. Round-close baseline this queue is measured against

Captured by this seat at HEAD `2c99b7b`. These are the values a folding seat must not perturb, and
the sha256s that pin the surfaces the queue edits.

| surface | sha256 | state |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` | untracked, new in r102 |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8` | untracked, new in r102 |
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` | modified (F8 fold) |
| `corpus/lessons/r102-unreal-integration.md` | `ec6880a6dbd763d43f761cb0813de1a4e40002bb92ff44c60b48086a13601bd2` | untracked, new in r102 |
| `corpus/knowledge/engines.md` | `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` | modified (F5 + IP-1) |
| `corpus/knowledge/rea.md` | `3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059` | modified (F6 note) |
| `corpus/artifacts/unreal-r22/README.md` | `1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b` | modified (F1a) |
| `corpus/lessons/r22-unreal-review.md` | `3905038b9a54586e2a5f0e3d09265199ad3d09f3ef3a9aee56dea7b67f988143` | modified (F1b + F2/F3 note) |

**The gate is green on these bytes** — this seat ran it, not quoted it:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0   STEP=PASS
CARDS=13 EXPECTED=13 BAD=0 CENSUS static-only=12 unproven-runtime=1 verified-here=0  STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0                     STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

So **every item below is a residual**, not a live red. **[live defect]** = reproducible failure
today. **[latent]** = a gap this seat (or a named sibling) falsified by planting a mutation on a
scratch copy; the repo was never modified. **[doc]** = a documentation inconsistency.

> **A green gate is not a clean bill.** Sibling seats and this seat proved four separate ways the
> gate can print `GATE RESULT: PASS` over a real defect (A1, A6, A7, A8) or over a check that did not
> run (A5). The round report says the same thing about F7: *"C1 can be green while F7 stays open."*

---

## 2. Queue — gate hardening (the C1(a) artifact)

All of §2 has **one owner-seat suggestion**: the seat that owns `corpus/knowledge/unreal-mcp/gate/`
(the SEAT-17 GATE-AUTHOR successor), r103. Do not split a single gate file across seats.

### A1 — CHECK 4 never range-checks a multi-endpoint pointer's tail **[latent]**

**Where:** `gate/run_gate.sh:192`. The extraction regex
`upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+` matches only the **first** number of a
range/comma pointer; `p=${ptr%:*}; ln=${ptr##*:}` then resolves that one endpoint.
**Found first by:** `reports/round-102/gate/review.md` §F1, `reports/round-102/r102-connector.md`
IP-3, `reports/round-102/r102-report.md` open item 3, `reports/round-102/reruns/pointers.md` §1.

The round's own sweep (`reports/round-102/reruns/pointer-sweep.sh`) resolves **every** endpoint
(`tr ',-' '  '`). The two disagree by construction on the same tree:

```
$ # per-file sort -u, gate-style (first number only)   → 40   (what the gate prints: POINTERS=40)
$ # per-file sort -u, every endpoint                   → 47   (what the sweep prints)
delta=7
  upstream/hooks/hooks.json:4-5                            endpoints=2
  upstream/hooks/unreal-context.sh:5,8                     endpoints=2
  upstream/README.md:39,45                                 endpoints=2
  upstream/README.md:50-57                                 endpoints=2
  upstream/skills/unreal-mcp/references/setup.md:61,70-79  endpoints=3
```

Falsified on a scratch copy: a planted `upstream/README.md:1-9999` is read by the gate as `:1` — in
range against `max=112` — while the sweep reads `:1-9999` and fails:

```
$ grep -ohE "<gate regex>"  …/materials.md   → upstream/README.md:1
$ grep -ohE "<sweep regex>" …/materials.md   → upstream/README.md:1-9999
$ BASE=/tmp/r102-gate-neg bash reports/round-102/reruns/pointer-sweep.sh /tmp/r102-gate-neg
LINE-OOR …/materials.md :: upstream/README.md:1-9999 (max 112)   UNRESOLVED=1   STEP=FAIL
```

**All 11 tail endpoints are in range today** (individually checked: `hooks.json` 4,5 ≤ 17;
`unreal-context.sh` 5,8 ≤ 84; `README.md` 39,45,50,57 ≤ 112; `setup.md` 61,70,79 ≤ 133), so this is
latent, not a live false PASS. The gate's own control C3 plants a *single-endpoint* OOR pointer, which
it does catch — the blind spot is specifically the multi-endpoint form.

**Falsifiable acceptance:** adopt the sweep's regex plus a per-endpoint loop; then
`bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` must print `POINTERS=47` (not 40) with
`UNRESOLVED=0` / `STEP=PASS`, and the planted-tail scratch copy must flip CHECK 4 to `STEP=FAIL` /
exit 1.

### A2 — CHECK 3 reuses the position-fragile first-token-wins rule **[latent]**

**Where:** `gate/run_gate.sh:135` — `rec=$(grep -nE "$ALLOWED" "$f" | head -1)`.
**Found first by:** `reports/round-102/reruns/labels.md` §3a (SEAT-36).

SEAT-36 showed a prose sentence naming a token above the declaration hijacks the rule. Re-falsified
here by running the gate's CHECK 3 block verbatim against a scratch copy whose `editor-general.md`
carries one extra prose line above its declaration:

```
$ rec=$(grep -nE '<allowed>' editor-general.md | head -1)
first-hit line: 4 :: This card is emphatically not `verified-here`; nothing was observed.
$ # gate CHECK 3 block, verbatim, over the 13-card scratch set
FAIL label-unmarked editor-general.md :: This card is emphatically not `verified-here`; nothing was observed.
C3_BAD=1
```

The card is correctly labelled (`**Label:** \`static-only\`` at line 5). The gate passes today only
because no card happens to put prose above its declaration.

**Falsifiable acceptance:** with the declaration rule changed to "first marked line within 40 lines
carrying exactly one allowed token, whose stripped text is ≤ 8 words", the prose-hijack scratch copy
must yield `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`, while SEAT-36's NC2/NC3/NC5 controls
(unlabelled, multi-label, unmarked) must still flip it to `STEP=FAIL`.

### A3 — CHECK 3 counts cards but never compares their **names** **[latent]**

**Where:** `gate/run_gate.sh:130-131` — `find … -name '*.md' | sort` then `grep -c .`. The 13 expected
domains are listed in `gate/README.md` and in `reports/round-101/r101-verification-protocol.md` §4,
but no code compares the two sets.

Falsified: renaming `executability/sequencer.md` → `executability/sequence-typo.md` on a scratch copy
leaves count and labels intact:

```
CARDS=13 EXPECTED=13 BAD=0  -> gate CHECK 3 verdict: STEP=PASS
```

A card can be silently dropped-and-replaced under a typo'd name and the gate stays green.

**Falsifiable acceptance:** CHECK 3 must compare the `basename` set against the 13 declared domain
names and print `NAME_SET=OK`; the rename above must produce `STEP=FAIL` / exit 1, and the unmodified
tree must still print `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`.

### A4 — CHECK 2 renders an unreachable upstream as FAIL, indistinguishable from a byte mismatch **[latent]**

**Where:** `gate/run_gate.sh:111-114`. **Also raised by:** `reports/round-102/r102-report.md` open
item 5, `reports/round-102/r102-connector.md` IP-4.

The clone-failure branch prints `… — BLOCKED, not PASS` and then sets `C2_PASS=0`, so the check
reports `STEP=FAIL` and the gate exits 1. Falsified with a scratch copy whose `REPO=` is
unreachable:

```
CHECK 2 clone-equivalence
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
remote: Repository not found.
STEP=FAIL
```

The message says "BLOCKED, not PASS" but the **exit channel carries no third state**, so a folding
seat reading only `GATE RESULT: FAIL` cannot tell "this host had no network" from "the vendored bytes
diverge". `gate/README.md` §"Expected output" has no BLOCKED line either. Air-gapped close-out is
impossible today.

**Falsifiable acceptance:** either (a) print a distinct `CHECK2=BLOCKED` token with a documented
distinct exit code, or (b) accept a pre-cloned reference via `GATE_REF=<path>`. Acceptance: with
`GATE_REF` set to a clone at the pin, the gate must print `STEP=PASS` / exit 0 with networking
unavailable; with an unreachable `REPO` and no `GATE_REF`, the output must name BLOCKED distinctly
from a `BLOB_DIFFS>0` failure.

### A5 — CHECK 1 covers only the 12-entry audit reference, not the 11 seat shards **[latent]**

**Where:** `gate/run_gate.sh:58` — `sha256sum -c .manifest.d/audit-reference.sha256`. `gate/README.md`
CHECK 1 states this is deliberate (the audit reference is the 12/12 set), so the consequence is
unrecorded: `.manifest.d/seat01..seat11.sha256` are **never executed by the gate** — 13 of the 24
`OK` lines the r101 README sweep prints sit outside the gate.

Falsified: overwriting `seat02.sha256` with a bogus 64-zero digest on a scratch copy leaves it green:

```
$ grep -c . .manifest.d/seat02.sha256          → 1
$ bash gate/run_gate.sh | tail -3
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

**Falsifiable acceptance:** CHECK 1 must additionally run the shard glob and report
`SHARD_MANIFESTS=11 SHARD_OK=13 SHARD_FAILED=0`; the corrupted `seat02.sha256` scratch copy must
produce `STEP=FAIL` / exit 1, and the unmodified tree must still print
`MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` plus the shard line, all green.

### A6 — CHECK 4 silently ignores **extensionless** pointer targets **[latent]**

**Where:** `gate/run_gate.sh:192`, same regex as A1 — the literal `\.` requires a dot in the path
segment, so pointers into `upstream/LICENSE`, `upstream/CODEOWNERS` or `upstream/.gitignore` are
never swept. **Found first by:** `reports/round-102/gate/adversary-b.md` §F1.

Falsified here: planting `upstream/LICENSE:99999` leaves the gate green.

```
$ bash /tmp/r102-extless/gate/run_gate.sh | grep -E "^POINTERS|^GATE RESULT"
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

The sibling's widened regex is behaviour-neutral on the real tree — this seat re-derived it, matching
the gate's own per-file-unique summation:

```
$ # per-file unique, summed, with the extension-optional regex
per_file_sum=40         # identical to the current regex: 0 additions, 0 removals
```

(Do **not** compare a single global `sort -u` across all files — that deduplicates *across* files and
reads 37, not the gate's 40. The gate sums per-file unique counts, which is the comparable number.)

**Latent, not active:** no `upstream/<ext-less>:<line>` pointer exists today; the extensionless
mentions that do exist are `upstream/LICENSE: OK` hash lines with no `:<line>`.

**Falsifiable acceptance:** with the widened regex, the unmodified tree still prints
`POINTERS=40` / `STEP=PASS`, and the planted `upstream/LICENSE:99999` scratch copy prints
`UNRESOLVED=1` / `STEP=FAIL` / exit 1.

### A7 — unqualified `sha256sum` → a **full false green** over tampered bytes **[latent, highest severity]**

**Where:** `gate/run_gate.sh:58` (check 1) and `:105-106` (check 2, both sides of the blob compare).
`sha256sum` is invoked unqualified, with no `command -v` guard and no `PATH` hardening (`set -u` is
the only shell option — no `set -e`, no `pipefail`). **Found first by:**
`reports/round-102/gate/sentinel.md` §6 (SEAT-19).

A shadowing `sha256sum` that replays the manifest as `OK` and prints nothing in hashing mode makes
check 2's comparison empty-vs-empty equal, so a tampered tree returns exit 0 with a transcript
byte-for-byte identical to a clean run — *asserting* the `MANIFEST_OK=12 … BLOB_DIFFS=0` values a
verifier is told to expect. The sibling showed it is reachable from an ordinary inherited `PATH`
(no `env -i` needed), and that the aggregating factor is `C1_OK=$(… | grep -c ': OK$')` counting the
stub's own output. This is the same class as the r101 vendored-hook defect **S-5**
(`reports/round-101/r101-sentinel.md` §3.1 — unqualified `basename`/`dirname`).

**Falsifiable acceptance:** qualify the calls (`/usr/bin/sha256sum`) or add a `command -v` guard plus
an integrity check that fails the check when the tool is not the system one; then a scratch copy with
the stub ahead on `PATH` **and** one byte flipped in `upstream/README.md` must print
`STEP=FAIL` / exit 1, while the unmodified tree under a normal `PATH` still prints `GATE RESULT: PASS`.

### A8 — a missing/failing `comm` → a green gate over a **stray file** **[latent]**

**Where:** `gate/run_gate.sh:97-98`. The path-set equality uses `comm` with no `command -v` guard, so
when `comm` is absent **or fails**, both pipeline substitutions yield the empty string, `wc -l` reads
`0`, and `PATH_EXTRA=0 PATH_MISSING=0` is printed as if the sets matched. **Found first by:**
`reports/round-102/gate/adversary-b.md` §F2.

Independently re-derived by this seat with a `comm` shim that exits 127, on a scratch copy carrying a
stray `upstream/STRAY.md`:

```
$ printf '#!/bin/sh\nexit 127\n' > /tmp/r102-badcomm/comm ; chmod +x /tmp/r102-badcomm/comm
$ PATH=/tmp/r102-badcomm:$PATH bash /tmp/r102-comm/gate/run_gate.sh | grep -E "^PATH_EXTRA|^BLOB_DIFFS|^GATE RESULT"
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
$ bash /tmp/r102-comm/gate/run_gate.sh | grep -E "^PATH_EXTRA|^GATE RESULT"   # control, working comm
PATH_EXTRA=1 PATH_MISSING=0
GATE RESULT: FAIL (checks failed: 1)
```

`comm` is isolated as the cause, and this is the one case in the round's whole matrix that produced a
**green gate over a real defect** — a true false-pass, not merely a missing check.

**Falsifiable acceptance:** guard the required tools the way `git` is already guarded at `:81-83`
(`for t in git comm sha256sum; do command -v "$t" >/dev/null 2>&1 || C2_PASS=0; done`) and run the
`comm` comparison only when `C2_PASS=1`. Then the failing-`comm` scratch copy with the stray file must
print `STEP=FAIL` / exit 1, and the clean tree under a normal `PATH` must still print
`PATH_EXTRA=0 PATH_MISSING=0` / `STEP=PASS`.

### A9 — `gate/README.md`'s own control section does not survive its own counts **[doc]**

**Where:** `gate/README.md`. **Found first by:** `reports/round-102/gate/review.md` §F2/§F3.

1. **`:135` says "These three mutations must each turn the gate red"** while the block below lists
   **six** (C1–C6) and the matrix adds C7 — seven rows. Stale wording from an earlier draft.
2. **C7's pinned `SKIPPED_CONTROL_SENTINELS=2` is unreproducible from the README** because, unlike
   C1–C6, C7 gives no `printf` command for its plant set. Planting all three documented sentinels
   yields `SKIPPED_CONTROL_SENTINELS=3`, exit 0. The mechanism is correct; only the pinned count is
   not re-derivable.

**Falsifiable acceptance:** the count in the "three mutations" sentence matches the number of controls
actually listed — `grep -c "^# C[0-9]" corpus/knowledge/unreal-mcp/gate/README.md` → `6` (the shell
blocks) and the observed matrix table carries `7` rows (C1–C7); the sentence must name the right
number, or the block must be split into "must turn it red" (C1–C6) and "must stay green" (C7). And
re-running C7's documented command reproduces its pinned `SKIPPED_CONTROL_SENTINELS` value exactly —
note C7 is currently the *only* control with no `printf` command shown, which is why its pinned `2`
is not re-derivable as written.

---

## 3. Queue — wording nits and prose-cites-bytes

### B1 — the two r22 lesson citations: **LANDED mid-authoring — verify the residue** **[closed pending check]**

**Owner-seat suggestion:** none needed if the residue check passes; otherwise the seat that owns
`corpus/lessons/r22-unreal-review.md`, r103.

This item was a live defect when this seat started (`grep -c "Correction note" → 0`) and **landed
while this file was being written — twice, by two seats**. It is kept in the queue as a
*verification* item, because the acceptance below is cheap and the failure mode is silent. Note the
**counts moved as the repairs landed**: each of the three greps below reads `2`, not `1`, because a
second seat appended its own note — so the acceptance must be stated as *"the historical lines are
still present and a dated note exists"*, never as an exact count of 1.

Current state — re-derived:

```
$ grep -n "Correction note" corpus/lessons/r22-unreal-review.md
50:> **Correction note (r102, 2026-10-18).** The paragraph above is left verbatim as the r22 record; …
59:## Correction note — 2026-10-18 (r102)
$ grep -c "20261013T053632289732Z" corpus/lessons/r22-unreal-review.md     → 2
$ grep -c "a065a56d" corpus/lessons/r22-unreal-review.md                  → 2
$ sha256sum corpus/lessons/r22-unreal-review.md
3905038b9a54586e2a5f0e3d09265199ad3d09f3ef3a9aee56dea7b67f988143
$ sha256sum corpus/fixtures/run_battery.py | cut -c1-16                   → f456bd00a1f7cc6f
$ git cat-file blob 8b21cae:corpus/fixtures/run_battery.py | sha256sum | cut -c1-16 → a065a56db193228d
```

Line 48 — the original claim — is untouched (`sed -n '48p'` shows the r22 sentence verbatim), so
"preserved, not rewritten" holds; the doubled counts come from the *notes* quoting the cited values
in order to correct them, which is the intended shape, not a defect.

The note does what the two adversary rulings required: SEAT-12
(`reports/round-102/adversary/F2.md`) ruled the pointer **load-bearing and not to be deleted** — the
citation is the sole surviving trace of that run's digest — and SEAT-13
(`reports/round-102/adversary/F3.md`) ruled the sha an **archival content address**, repaired by a
dated note with a re-derivation pointer, **never by renumbering** (78 commits have produced 78
distinct digests; renumbering manufactures the next round's defect). The landed note states both the
r21/r22-era blob and the current tree value, and covers `run_cases.mjs`'s `f9f40d47…` too — the
second historical digest SEAT-13 found that r101 flagged only once.

**Falsifiable acceptance:** the historical lines are still present at their original numbers —
`sed -n '48p' corpus/lessons/r22-unreal-review.md` still shows the r22 sentence, and
`grep -c "20261013T053632289732Z"` ≥ `2` — **and** at least one dated correction note exists
(`grep -c "Correction note"` ≥ `1`, currently `2`); and both re-derivation commands reproduce their
stated digests (`git cat-file blob 8b21cae:corpus/fixtures/run_battery.py | sha256sum` →
`a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`;
`sha256sum corpus/fixtures/run_battery.py` →
`f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`).

**Sub-item B1b — the stale `29/29` pass count [closed by the second note; verify]:** the r22 lesson's
"29/29 PASS (14 ordinary, 15 negative)" was a third stale claim of the same class, which r101's F3 did
not flag (SEAT-13's table, `reports/round-102/adversary/F3.md` §3, caught the parallel case for
`run_cases.mjs`'s `f9f40d47…`). The second landed note covers it:

```
$ python3 -c "…ast…CASES…on the r22 blob"    → [(34, 29)]
$ python3 -c "…ast…CASES…on the tree"        → [(39, 350)]
```

Acceptance: `grep -c "29/29" corpus/lessons/r22-unreal-review.md` still ≥ 1 (the r22 record is
preserved) and the note states both the 29-row r22 count and the 350-row current count, with the
`CASES` line numbers (`34` → `39`).

### B2 — the dead `.shokunin/game-dev-3d/` root: three runnable READMEs **[live defect]**, scope ruling **[decision]**

**Owner-seat suggestion:** the three READMEs are mechanical in-place fixes (one seat, r103). The
**systemic scope must be ruled by the L1**, not by a seat — see the ruling note below.

**Live today** — every command exits non-zero, run verbatim from the repo root:

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py                               exit=2
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py  exit=2
$ npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three                                        exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                                     exit=1
```

Repo-relative forms of the same commands all exit 0:

```
$ python3 corpus/artifacts/glb-r12/run_import.py                                    exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py exit=0
$ node corpus/fixtures/three/run_cases.mjs                                          exit=0
```

F1 fixed exactly this class in two r22 files; these three are the same defect, **unrepaired this
round** (SEAT-14 flagged the three/README one as "P3, discovered here, different file, not in this
seat's ownership" — `reports/round-102/adversary/F5.md`). Occurrence counts:
`corpus/fixtures/three/README.md` **17** lines, `corpus/artifacts/glb-r12/README.md` **3**,
`corpus/artifacts/unity-r19/README.md` **2**.

**The scope is the real question, and it is already adjudicated as an L1 ruling.** SEAT-11
(`reports/round-102/adversary/F1.md` §5) re-derived the systemic scope and ruled:

```
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l      → 142
$ git grep -l "\.shokunin/game-dev-3d" | wc -l           → 141   (worktree, after the r22 fix)
```

- **R2/R3:** the in-place rewrite of the r22 lesson's *narrative* is forbidden; a bounded in-place fix
  is permitted **only** for the literal command block — and is **deferred until the L1 rules the
  systemic question**, because a one-file fix leaving 141 siblings (and `PROVINCE.md:46`'s
  write-scope declaration) still carrying the prefix converts a routed defect into a standing
  conformance defect.
- **R4 options, in that seat's order of preference:** (1) a single appended correction note in
  `corpus/README.md` stating the convention and the executable repo-root-relative form — one note,
  no history edited; (2) that note **plus** a bounded in-place fix of the class-B command blocks
  across the affected files; (3) full in-place sweep of all 142 — **rejected**.
- **R5:** the r22 in-place fix already in the tree (F1b) is flagged by that seat as non-conformant
  under its ruling. This seat takes no position on R5 — it is the adjudicator's call — but the queue
  must carry the flag so it is not silently absorbed.

**Falsifiable acceptance (per README):** `grep -c "shokunin/game-dev-3d" <each of the three READMEs>`
→ `0`, and the four verbatim commands above re-run from the repo root exit `0`. **Plus, for the
ruling:** one of R4's options is chosen and recorded in `LOG.md`, and `corpus/README.md` carries the
convention note (option 1 or 2).

### B3 — the byte-pinned subtree's own index has three stale spots **[live defect, wording-only]**

**Owner-seat suggestion:** the seat **explicitly authorized** to make a wording fix inside
`corpus/knowledge/unreal-mcp/` — the only seat allowed to touch this subtree, r103.
**Where:** `corpus/knowledge/unreal-mcp/README.md` (sha256 `c79d8dd1…`).

1. **Layout block omits `gate/`** (lines 107-114). It lists `README.md`, `PROVENANCE.md`,
   `adaptation-kimi.md`, `.manifest.d/`, `upstream/`, `executability/` — the gate directory this
   round's coverage claim rests on is absent, though the r102 lesson's own §"Re-running the gate"
   points at it.
2. **`executability/` still reads `(13 intended; seats land them)`** (line 113). All 13 cards landed
   in r101 and the gate asserts `CARDS=13 EXPECTED=13 BAD=0`; this is pre-landing text
   (`grep -c "13 intended" …` → `1`).
3. **The label-ternary definition still contradicts 6 cards (F7)** — `README.md:41` defines
   `unproven-runtime` as "needs the live editor and nothing was observed", while six cards reject that
   label because the runtime path "is not even identified":

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

   Re-derived by this seat; unchanged since r101. r102 did **not** fix it — the round report calls it
   *"UNASSIGNED and still open, and the round's highest-value gap"*, and notes **the gate cannot see
   it by construction** (check 3 only enforces one allowed label per card), so *"a green gate must not
   be read as F7 being closed."* The ruling is between `actors-scene.md`'s looser test and the
   stricter test the 12 other cards applied; the cards' evidence does not move either way.

**Why queued, not applied:** the subtree is byte-pinned, and its README is the **one** wording surface
the round's discipline allows a single owner to fix. Every edit must be followed by a manifest +
clone re-check.

**Falsifiable acceptance:** after the edit —
`bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` still prints `MANIFEST_OK=12 … RC=0` and
`BLOB_DIFFS=0` / `GATE RESULT: PASS` (proving `upstream/` untouched);
`grep -c "gate/"` in the layout block ≥ 1; `grep -c "13 intended" corpus/knowledge/unreal-mcp/README.md`
→ `0`; and for F7, either `grep -rln 'Not `unproven-runtime`' …` → `0` (cards relabelled) **or** the
README row for `unproven-runtime` states which side owns "path not even identified" — a census still
splitting 12/1 with both definitions live does **not** satisfy this item.

### B4 — PROVENANCE §8 predates PR #8 **[live defect, additive only]**

**Owner-seat suggestion:** the seat that owns `corpus/knowledge/unreal-mcp/PROVENANCE.md`, r103.
**Where:** `PROVENANCE.md` §8 (lines 340-364), the out-of-pin table.

SEAT-59 (`reports/round-102/freshness-pin.md` §5) re-enumerated the PR surface and observed a sixth
open PR not in the §8 table:

```
$ gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin --state all --limit 20 \
    --json number,title,state,mergedAt,headRefOid
#5 OPEN  Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command   c64c6097…
#4 OPEN  feat: add marketplace manifest …                        83807c0e…
#8 OPEN  Add an OpenCode port                                    1a3476f7…
#2 OPEN  Add Marketplace.json                                    6dd839e9…
#1 OPEN  Add missing .claude-plugin/marketplace.json …           435522c0…
```

`grep -c "OpenCode" corpus/knowledge/unreal-mcp/PROVENANCE.md` → `0`. SEAT-52
(`reports/round-102/provenance-rerun.md` §4b) independently recorded PR 8 appearing 16 minutes after
§8's snapshot, and §4a that PR 2 carries a *different* `marketplace.json` than the one §8 names (only
PR 1 is tabulated). The pin is unaffected — `a6aa73ad…` is still the tip of `main`, zero tags, no PR
merged.

**Falsifiable acceptance:** §8 gains PR 8's number, SHA and state (or an explicit "observed, not
tabulated" line) and a note that PR 1/2 carry divergent `marketplace.json` versions;
`grep -c "OpenCode" corpus/knowledge/unreal-mcp/PROVENANCE.md` ≥ 1; and the edit does not perturb
`upstream/` — `run_gate.sh` still prints `BLOB_DIFFS=0` / `GATE RESULT: PASS`.

---

## 4. Queue — the battery-wiring decision (structural, needs a ruling)

### C1 — the pinned subtree is outside every standing gate; the gate is manual and writes no receipt **[decision]**

**Owner-seat suggestion:** L1 for the ruling, then **one** implementation seat (the battery's owner).
Not a per-file repair; must not be split across seats.
**Where:** `corpus/fixtures/run_battery.py:940-946` (`seed_digests`), `:1228` (`--runs`),
`:1232-1237` / `:1374-1376` (the existing probe-flag extension point).
**Found first by:** connector IP-2 (`reports/round-101/r101-connector.md:191-236`), re-confirmed as
`reports/round-102/r102-connector.md` IP-2 and `reports/round-102/r102-report.md` open item 4.

Re-derived by this seat, not quoted:

```
$ python3 -c "…seed_digests()…"
entries: 130
knowledge entries: []
top-level dirs: ['README.md', 'animation3d_blend.gd', …, 'r94vendor', 'r95vendor', 'r98assets', …]
$ grep -rn "run_gate" --include='*.py' --include='*.sh' --include='*.mjs' corpus/ | grep -v 'unreal-mcp/gate/' | wc -l
0
```

`seed_digests()` roots at `corpus/fixtures/` (`HERE`), so the 130-entry digest map covers **0** files
under `corpus/knowledge/`. Every other vendored third-party asset in this lane (`r94vendor`
cannon-es, `r95vendor` pybullet `.so`, `r98assets` glTF/GLB) sits inside that root and is covered by
the standing mutation gate; the r101 subtree is not. The r102 gate is a **manual** artifact — nothing
runs it unless a seat remembers to — and it **emits stdout only**, so a green verdict survives only
as a hand-pasted transcript, which is exactly the "read nothing from an author's transcript" failure
the gate's own README claims to avoid.

**The decision (pick one, do not implement all):**

1. **Wire it in (smallest):** a `--vendor-gate` flag on `run_battery.py` that shells out to
   `gate/run_gate.sh` and folds its exit status into the battery verdict, exactly as
   `--probe-crash-exit` / `--probe-stream-attribution` / `--probe-tree-timeout` already fold three
   extra probes into `main()`'s verdict. Reuses the lane's own established extension point — no new
   idiom, ~10 lines.
2. **Receipt contract (independent, composes with 1):** an opt-in `--receipt <path>` flag on the gate
   mirroring `three/run_cases.mjs:33-37`, writing the four `STEP` lines plus `GATE RESULT` as JSON,
   defaulting to `corpus/live/runs/<ts>/gate-verdicts.json`. Keep the no-write default — it is a real
   virtue for CI-style use. SEAT-52 verified the receipt path is already gitignored and
   convention-compatible.
3. **Conventional:** a lane close-out script under `reports/` running battery + bpy + three + gate,
   non-zero if any is red.

**Why queued, not folded:** any of these mutates `corpus/fixtures/run_battery.py`, which r102 proved
byte-stable (146 tracked fixture files, 0 blob mismatches vs HEAD; 350 `CASES` rows AST-parse on both
worktree and HEAD blob — `reports/round-102/battery-integrity.md`). Touching it is a **battery-contract
change** and must be its own axis-move with its own before/after receipts.

**Falsifiable acceptance:** the subtree is reported by a standing harness, and the wiring is
**mutation-sensitive** — flipping one byte in a private copy of
`corpus/knowledge/unreal-mcp/upstream/README.md` flips the battery verdict to FAIL / non-zero exit,
while the unmodified tree stays green; the Godot battery's prior rows stay byte-stable
(`git diff --stat HEAD -- corpus/fixtures/` empty apart from the intended runner edit, 350/350 `CASES`
rows AST-parse). **A gate that only ever runs by hand does not satisfy this item.**

---

## 5. Items this seat considered and does **not** queue

- **Re-pin / re-vendor.** SEAT-59 re-checked three transports: `a6aa73ad…` is still the tip of
  `main`, zero tags, `pushed_at` older than the r101 fetch. No staleness note is owed;
  `PROVENANCE.md` §7's contingency has not fired.
- **Engine-install escalation.** SEAT-60 (`reports/round-102/install-recheck.md`) re-ran all three
  routes: HTTPS 404, AUR SSH publickey-denied, Lutris credential-gated. Unchanged and operator-owned;
  the three r101 L0 questions stand. Nothing here moves an `engines.md` row toward `yes`.
- **`corpus/README.md` indexing.** SEAT-56 proved it carries no per-file pointers at all
  (`grep -cE '\.md'` → 0), so there is no stale pointer to fix. **Note the interaction with B2:**
  R4 option 1 wants a *convention* note appended there — that is a new content, not an index repair.
- **Battery bytes / ledger discipline.** `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`,
  `PROVINCE.md`, `corpus/fixtures/**` and `reports/round-101/**` are all content-identical to HEAD
  (`git status --porcelain` over those paths → 0 lines). No fold item is owed. (`LOG.md` /
  `SCORECARD.md` carrying zero r102 entries is the L1's to land at close, not a fold item.)
- **The `F6-rea-census.md` duplicate basename.** `reports/round-102/reports-index.md` §3.1 recorded it
  as a deliberate consequence of the new `before/`→`repairs/` subdir convention. Not a defect.
- **Card set as a static battery.** Connector IP-3 (a future `unreal_battery.py` whose "cases" are
  static checks) is a *proposal*, not a finding; it needs a design decision first and would be a
  **static-only** runner by construction.
- **Two self-disclosed numeric slips** (`reports/round-102/math-audit.md`): the
  `three/node_modules/` file count (1410 stated, 1264 measured) and one rewritten-file byte count.
  Neither affects a load-bearing conclusion; both are already disclosed by their authors.

## 6. Suggested fold order for r103

Highest value first, ordered so later items are not invalidated by earlier ones:

1. **A7 + A8** — the two ways the gate prints green over a real defect. Highest value in the queue:
   a gate that can be fooled is not a gate, and this round's whole coverage claim rests on it.
2. **B1** — verify the landed r22 note's residue (one grep set; the failure mode is silent).
3. **A1 + A2 + A6** — the three provable blind spots, each with a ready-made mutation control.
4. **A3 + A5 + A4** — completeness and offline runnability of the same file.
5. **B2 (three READMEs)** — mechanical, in place; **plus the L1's systemic-scope ruling** (R4).
6. **B3 + B4** — the byte-pinned subtree's wording; one authorized seat, each edit re-gated.
7. **A9** — documentation consistency in `gate/README.md`; do it in the same pass as §2's code edits.
8. **C1** — the battery-wiring ruling; L1 decides, one implementation seat, its own round-level claim.
   **Do not fold it as a side effect of anything above.**

**Cross-cutting rule for every folding seat:** re-run
`bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` **before and after** each edit to the pinned
subtree, and cite the two `GATE RESULT:` lines. Two of its four checks compare against a fresh clone
at the pin, so a green run proves the pinned bytes were not perturbed by the wording change. And
until **A7/A8** land, treat a green gate as *indicative*, not authoritative, when the invocation
environment is not the system default `PATH`.

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §1 baseline — the gate, run by this seat
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/README.md \
          corpus/lessons/r102-unreal-integration.md corpus/knowledge/engines.md \
          corpus/knowledge/rea.md corpus/artifacts/unreal-r22/README.md \
          corpus/lessons/r22-unreal-review.md

# A1 — the two pointer counts on the same tree
BASE=corpus/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh corpus/knowledge/unreal-mcp

# A3 — card-name set is not compared
grep -n "find .*executability" corpus/knowledge/unreal-mcp/gate/run_gate.sh

# A5 — shards outside the gate
grep -n "audit-reference.sha256" corpus/knowledge/unreal-mcp/gate/run_gate.sh

# A6 — the widened (extension-optional) regex must still read 40 on the real tree,
# summed per file exactly as the gate does (a single global sort -u reads 37 — it dedups across files)
cd corpus/knowledge/unreal-mcp
tot=0; while IFS= read -r f; do case "$f" in ./upstream/*|./gate/README.md) continue;; esac; \
  n=$(grep -ohE "upstream/[A-Za-z0-9_./-]+(\.[A-Za-z0-9]+)?:[0-9]+" "$f" | sort -u | wc -l); tot=$((tot+n)); \
  done < <(find . -name '*.md' -type f | sort); echo "widened_per_file_sum=$tot"   # 40
cd -

# A7 — unqualified sha256sum is the trust anchor
grep -n "sha256sum" corpus/knowledge/unreal-mcp/gate/run_gate.sh

# A8 — comm is unguarded
grep -n "comm " corpus/knowledge/unreal-mcp/gate/run_gate.sh

# B1 — the r22 correction note
grep -c "Correction note" corpus/lessons/r22-unreal-review.md
grep -c "20261013T053632289732Z" corpus/lessons/r22-unreal-review.md
git cat-file blob 8b21cae:corpus/fixtures/run_battery.py | sha256sum
sha256sum corpus/fixtures/run_battery.py

# B2 — the dead path root, run verbatim from the repo root
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py; echo "exit=$?"
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l        # 142 — the L1's systemic-scope question

# B3 — F7 label collision
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l

# B4 — PR 8 absent from §8
grep -c "OpenCode" corpus/knowledge/unreal-mcp/PROVENANCE.md

# C1 — the subtree is outside the standing digest map
python3 - <<'EOF'
import importlib.util
s=importlib.util.spec_from_file_location("rb","corpus/fixtures/run_battery.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
d=m.seed_digests(); print("entries:",len(d),"knowledge:",[k for k in d if "knowledge" in k])
EOF
```

## 8. Limits of this file

- Every item is a **residual on the r102 working tree at `2c99b7b`**, not on a landed commit. The tree
  was mutating under concurrent seats while this seat ran; the sha256 table in §1 is the snapshot the
  queue is pinned to, and any folding seat must re-read the target file before editing it (the
  round's own lesson, hook 3, says exactly this about the subtree README). Two items moved *during*
  this seat's run — B1 landed and `gate/README.md` grew — so treat any count here as a frame, not a
  constant.
- The latent gate gaps were falsified by planting mutations on scratch copies under `/tmp`
  (`/tmp/r102-gate-neg`, `/tmp/r102-label-neg`, `/tmp/r102-extless`, `/tmp/r102-comm`,
  `/tmp/r102-badcomm`, `/tmp/r102-name-neg`, `/tmp/r102-gate-blocked-tree`, `/tmp/r102-shard-neg`).
  **No repository file was modified by this seat**, and no finding depends on a `/tmp` path surviving.
- **No Unreal runtime claim appears in this file or in any item it queues.** The editor is not
  installed; live-MCP behaviour is unproven by construction; a green gate is never evidence of
  live-editor behaviour.
- This seat wrote **only** `reports/round-102/fold-spec.md`. No source file, lesson, fixture,
  manifest, or other seat's report was touched.
