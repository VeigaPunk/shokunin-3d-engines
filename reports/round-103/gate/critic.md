# r103 · SEAT-17 HARDENING-CRITIC — independent critique of the r103 gate hardening

**Seat:** SEAT-17 HARDENING-CRITIC · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/critic.md`). No other file was written by
this seat.
**Date:** 2026-10-18 · **Lane HEAD:** `c85a816` (r102 report-last; work `c6f655d`)

**Artefacts under review** (read at `2026-10-18T18:42Z`):

| file | HEAD blob | r103 working tree | md5 at capture |
|---|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `36e422a` (249 lines) | **+123 / −25** | `efc1e618…` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `ee4c58f` | **+164 / −20** | `21a7d6ff…` |

> **Revision caveat.** Both files were still being written while this seat worked. The **script**
> settled first (`03bfd89f` → `9ea943dc` → `c81802c5` → `9b6238d6` → `efc1e618` over ~5 min, then
> stable for 60 s). The **README** moved three more times during the critique
> (`e3c3a771` → `4ef02665` → `21a7d6ff`) as the author seat closed the documentation findings
> below. All *script* findings are pinned to `efc1e618…`; the README-dependent findings (F1, F3,
> F5) are stated with the revision they were re-checked at. F1, F3 and F5 were true of the
> mid-round revisions and were **fixed by the author seat before this report was written**; they
> are recorded as resolved, not deleted, so the round's change list is complete. If either file is
> edited again, re-run §2, §5 and the F-findings — the harness is listed in §8.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this
host and live-MCP behaviour is unproven by construction. The gate's own scope note — *"the
vendored bytes are byte-identical to the pinned upstream commit, and these static checks ran
here"* — is the strongest statement available and is not exceeded here.

**Method.** The installed gate was run on a **faithful in-place root**: a directory tree whose
`corpus/…` and `reports/…` siblings exist, so the gate's repo-relative resolution behaves exactly
as in the lane repo. This is load-bearing — a subtree-only copy produces false CHECK 4 failures
(finding **F2**). Every number below came from a command shown with its output.

---

## 1. Verdict

**PASS.** The hardening is **behaviour-preserving on a clean tree except for the three additions
it was meant to make**, stays **inside the A1–A4 scope** (plus one out-of-scope but correct and
previously-reported repair), is **not** a silent rewrite of any historical claim, and is
**independently verified** against every A-item and a 17-case attack matrix.

**No must-fix blocks this seat's acceptance.** Two defects remain, both documentation-level, none
requiring a re-implementation:

| # | finding | severity | status |
|---|---|---|---|
| **F2** | the README's *Calibrating* recipes copy **only the subtree**, which makes CHECK 4 fail spuriously (`C0`, unmodified copy → `UNRESOLVED=29`, exit 1) | should fix | **open** |
| **F4** | A2's anchored label rule rejects a declaration written as a markdown list item (`- **Label:** …`) — a *new* way for a correctly-labelled card to fail | should fix | **open** |
| F1 | README documented the pre-A4 "exits 1 … no partial-pass state" contract | must fix | **fixed mid-round** |
| F3 | the README pinned `POINTERS=100` while its own CHECK-4 section pinned `101` | should fix | **fixed mid-round** |
| F5 | `NAME_SET`/`POINTER_STRINGS`/`GATE_REF`/`STEP=BLOCKED`/exit 2 were undocumented | should fix | **fixed mid-round** |

## 2. Clean-tree behaviour — is anything different that should not be?

**No.** The two scripts were run back-to-back on the *same pristine HEAD subtree* (extracted with
`git archive HEAD`), with `/tmp/advgate` present so the pre-existing `.h1` artefact (F8) does not
confound the comparison:

```
$ # HEAD gate and final gate, same pristine tree
HEAD rc=0 ; NEW rc=0
=== CLEAN-TREE DIFF (HEAD gate -> final gate) ===
@@ -43,10 +43,11 @@
 CARDS=13 EXPECTED=13 BAD=0
 CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
+NAME_SET=OK NAME_BAD=0
 STEP=PASS

 CHECK 4 pointer-sweep
-POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
+POINTERS=95 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
 STEP=PASS

 GATE RESULT: PASS (checks failed: 0)
```

Every **verdict** line is byte-identical (`MANIFEST_OK`, `CLONE_HEAD`, `CLONE_DIRTY`,
`CLONE_TRACKED`, `PATH_EXTRA`, `PATH_MISSING`, `BLOB_DIFFS`, `CARDS`, `CENSUS`, `UNRESOLVED`,
`GATE RESULT`, exit code). The only differences are exactly the three the hardening was *meant*
to make:

1. `NAME_SET=OK NAME_BAD=0` — new, from A3.
2. `POINTERS=88 → 95` — A1's endpoint-counting (the same pointer *strings* are now counted once
   per endpoint; pass A = 47 endpoints from 41 strings).
3. `POINTER_STRINGS=41` — new; this is the old per-string number under a new name.

No `FAIL`/`MISSING`/`LINE-` line appears or disappears. **A clean tree still prints
`GATE RESULT: PASS (checks failed: 0)` and exits 0.**

### 2.1 The one clean-tree behaviour change not visible above — a fix

The `.h1` repair is invisible on this host only because `/tmp/advgate` exists. It is a real
clean-tree behaviour change elsewhere, and it is a **fix, not a regression**. Observed live during
this seat's session, on the pre-r103 script with `/tmp/advgate` removed:

```
FAIL per-seat manifest sweep (--strict) failed:
sed: can't read /tmp/advgate/.h1: No such file or directory
GATE RESULT: FAIL (checks failed: 2)          # on a CLEAN tree
```

The r103 script uses `mktemp`; the same clean tree is now `GATE RESULT: PASS (checks failed: 0)`.
See F8.

## 3. Scope — does the diff stay inside A1–A4?

`git diff` against HEAD is **123 added / 25 removed** lines in `run_gate.sh`, mapped to
`reports/round-102/fold-spec.md` §2:

| change | spec item | in scope? |
|---|---|---|
| `PINNED_CARD_NAMES` + both-direction name-set loop + `NAME_SET`/`NAME_BAD` + gate condition | **A3** | yes |
| `LABEL_RE` anchored declaration regex replaces the `ALLOWED` first-token rule in the CHECK 3 loop | **A2** | yes |
| `for ln in $(… tr ',-' '  ')` per-endpoint validation; extraction regex gains `([,-][0-9]+)*`; `POINTERS` counts endpoints, `POINTER_STRINGS` added | **A1** | yes |
| `C2_BLOCKED`, `GATE_REF`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, `exit 2` | **A4** | yes |
| `MANLOG=$(mktemp)` replaces `>/tmp/advgate/.h1` | **out of A1–A4** | legitimate — see below |
| `# shellcheck disable=SC2016` (literal backticks in check 4's regexes) | out of A1–A4 | cosmetic |
| comment rewrites (CHECK 3/4 headers, exit-code block) | — | yes |

**The `.h1` repair is out of A1–A4 but legitimate.** It was already reported (this seat's own live
discovery, and it matches the tool/scratch-file class of `fold-spec.md` A7); it is
behaviour-preserving on the lane repo and behaviour-correcting elsewhere; and it removes an
external-path dependency from a gate whose README claims it "requires no file outside the subtree
except a fresh clone". Ruling: **acceptable — name it in the round's change list so it is not
absorbed silently.**

**No change to the four checks' pass conditions beyond the A-items.** The exit-code block was
inserted *before* the existing `GATE RESULT` printf and only fires when `C2_BLOCKED=1 && FAILS=0`;
every other path falls through to the original line unchanged. No `set -e`, no `pipefail`, no new
tool requirement, no `PATH` hardening (A7 stays open — §8).

## 4. Undocumented output changes

The gate emits tokens the README did not originally define. Live counts (README `e3c3a771…`,
script `efc1e618…`):

| output token | in script | README, mid-round | README, final |
|---|---|---|---|
| `NAME_SET=OK NAME_BAD=0` | yes | 0 | **4** |
| `POINTER_STRINGS=41` | yes | 0 | **6** |
| `GATE_REF=…` | yes | 0 | **4** |
| `STEP=BLOCKED` | yes | 0 | **3** |
| `GATE RESULT: BLOCKED (…)` | yes | 0 | **1** |
| exit code `2` | yes | 0 | **1** (`exit 2`, plus a dedicated §"Exit codes") |
| the 13 pinned card names | yes | 0 | **present** (`:123-131`, `:203`) |

**This was finding F5 and it has been closed by the author seat during the round.** The script's
own comments claim the README mirrors them —

```
run_gate.sh:40  # gate/README.md ("Pinned card-name set"); both must be edited together.
run_gate.sh:123 #     in gate/README.md alongside the other codes.
```

— and both claims are now **true**: the name set is listed at `:123-131` and the exit-code contract
at `:208+`. The only residual wording nit is that the comment says `"Pinned card-name set"` while
the README's actual heading is `**The card-name set is pinned on purpose.**` — cosmetic.

## 5. Independent verification

### 5.1 Clean-tree diff

See §2. Verdict lines identical; three intended additions only.

### 5.2 A-item acceptance, each against its own criterion

Run against the installed gate (`efc1e618…`) on the faithful root:

- **A1 — PASS.** `upstream/README.md:1-9999` (tail out of range) is caught, where HEAD passed it:
  `LINE-OOR … (max 112)` / `UNRESOLVED=1` / exit 1. The comma form
  (`upstream/hooks/hooks.json:4,9999`) is caught too. On a clean tree the same pointer strings are
  counted per endpoint: `POINTERS=95 POINTER_STRINGS=41` vs HEAD's `POINTERS=88`.
- **A2 — PASS on its stated criterion.** A prose line naming a token above the declaration
  ("this card is emphatically not `verified-here`") no longer hijacks the rule:
  `OK static-only editor-general.md line 5` / `CARDS=13 BAD=0` / `GATE RESULT: PASS` / exit 0. The
  old controls still bite: no label → `FAIL`; multi-label on the declaration line →
  `FAIL multi-label`. **F4 records the regression this introduces.**
- **A3 — PASS.** Renaming `executability/sequencer.md` → `sequence-typo.md` now yields
  `NAME_SET=BAD NAME_BAD=2` / exit 1, where HEAD left `CARDS=13 BAD=0` green. A 14th card under a
  non-pinned name is caught as `FAIL card-name-extra`.
- **A4 — PASS.** With an unreachable `REPO` and no `GATE_REF`: `CHECK 2 BLOCKED (network)` /
  `STEP=BLOCKED` / `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` / **exit 2**.
  With `GATE_REF=<clone at the pin>` and the same unreachable `REPO`:
  `GATE_REF=… (offline reference; no clone attempted)` / `CLONE_HEAD=a6aa73ad…` /
  `BLOB_DIFFS=0` / `GATE RESULT: PASS` / exit 0 — air-gapped close-out now works. A blocked check
  coexisting with a real CHECK 4 failure correctly reports `GATE RESULT: FAIL` / exit 1, so the
  blocked state does not mask a genuine failure.

### 5.3 Attack matrix — r102's 11 attacks + the A-items

```
gate md5=efc1e618ce127f61b6112f04d0c3d95b
OK   A-symlink-upstream    rc=1   OK   A1-tail-oor          rc=1
OK   B-14th-card-symlink   rc=1   OK   A1b-comma-tail-oor   rc=1
OK   C-14th-card-subdir    rc=1   OK   A2-prose-hijack      rc=0  (must pass)
OK   D-NOT-static-only     rc=1   OK   A3-rename            rc=1
OK   E-static-onlyness     rc=1   OK   A4-unreachable       rc=2  STEP=BLOCKED
OK   F-dangling-rel        rc=1   OK   L-14th-card-plain    rc=1
OK   G-ptr-space           rc=1
OK   H-seat-manifests      rc=1
OK   I-crlf-auditref       rc=1
OK   J-pointer-line0       rc=1
OK   K-uppercase-MD        rc=1
== 17 / 17 OK ==
```

Every r102 hardening still fires; every A-item behaves as specified. Two entries in an earlier run
of this matrix read `MISS` (A2, A4) purely because a peer seat had momentarily cited a
not-yet-written `reports/round-103/gate/hardening.md` — the gate was correctly red for an unrelated
reason, and both cleared once that file landed. See §7.

## 6. Findings

### F1 — README documented the pre-A4 contract — **was must-fix; FIXED mid-round** [doc]

At the mid-round revisions `gate/README.md:73-75` still read *"… the run exits 1"* and `:159-160`
stated *"`0` iff all four checks print `STEP=PASS`; `1` otherwise. **There is no partial-pass
state**"* — both directly contradicted by A4's exit 2 / `STEP=BLOCKED`, and both would have led a
consumer to classify a blocked run (vendored bytes **UNCHECKED**) as a failure of the subtree.
The final README replaces this with a dedicated §"Exit codes" (`:208+`) declaring the third state,
and the CHECK-2 prose at `:95-98` now names `2` and `GATE_REF`. **Verified fixed:**

```
$ grep -c 'FAIL fresh clone failed' corpus/knowledge/unreal-mcp/gate/README.md  → 0
$ grep -c 'exit 2'                  corpus/knowledge/unreal-mcp/gate/README.md  → 1
```

### F2 — the *Calibrating* recipes still copy only the subtree — **open, should fix** [doc]

`gate/README.md:229-252` (the C1–C6 block a verifier actually runs) still says:

> Run them on a **copy** of the subtree …
> ```sh
> SUB=corpus/knowledge/unreal-mcp
> T=$(mktemp -d); cp -r "$SUB" "$T/sub"
> ```
> … a copied tree is gated by copying `gate/` with it (`cp -r` above does that).

That recipe is insufficient for CHECK 4's pass B, which resolves `corpus/…` and `reports/…`
against `SUB/../../..` (`REPO_ROOT`, `run_gate.sh:231`). A subtree-only copy has no repo siblings,
so every repo-relative pointer is reported missing. The README's own **C0** control ("unmodified
copy → exit 0") fails under the recipe it sits next to:

```
$ T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
$ bash "$T/sub/gate/run_gate.sh"; echo rc=$?
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=29
GATE RESULT: FAIL (checks failed: 1)
rc=1
MISSING-PATH-REL count=29
```

All 29 unresolved are `MISSING-PATH-REL corpus/…` / `reports/…` artefacts of the copy, not
defects. **The README is internally inconsistent:** the r103 control matrix at `:273` correctly
says *"run on a copy of the whole repo (check 4's pass B needs repo-relative paths to resolve)"*,
while the older C1–C6 block 20 lines above still gives the subtree-only recipe. Fix: change
`:229-252` to copy the whole repo (or a skeleton with `corpus/`+`reports/`), or note the
`-REL`-suffix caveat explicitly.

### F3 — the pinned summary block contradicted the CHECK-4 section — **was should-fix; FIXED mid-round** [doc]

At README `e3c3a771…` the file carried **two different pinned `POINTERS` values** — `:171` pinned
`101` while `:193` (the "pinned summary" block a verifier copies) still pinned `100`, stale by one.
The same paragraph at `:41` already concedes the count moves with every edit, which is precisely
why a **numeric** pin cannot serve as a pass criterion. **Verified fixed at README `21a7d6ff…`** —
all four pins now agree:

```
$ grep -nE 'POINTERS=[0-9]+' corpus/knowledge/unreal-mcp/gate/README.md
41:  … (the earlier `POINTERS=87` pin was stale — see the pin …
171: … `POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` …
193: POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
279:| **C0** | none (unmodified copy) | **0** | `POINTERS=101 … UNRESOLVED=0` …
304: POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

Residual recommendation (not a defect): since the count is tree-relative by construction (F7), the
binding pass criterion in the pinned block should be stated as `UNRESOLVED=0`, with `POINTERS` /
`POINTER_STRINGS` pinned only relative to a named scanner sha.

### F4 — A2's anchor rejects list-item label forms — **open, should fix** [behaviour, latent]

A2 replaces the first-token rule with `LABEL_RE`, anchored `^[[:space:]]*` with **no optional list
marker**. The anchor therefore rejects a declaration written as a markdown list item, the natural
way to place a label in a bullet list and a form the old rule accepted:

```
$ # card whose ONLY declaration is `- **Label:** `static-only`` (line 4)
FAIL label-too-deep …/executability/editor-general.md (line 232)
CARDS=13 EXPECTED=13 BAD=0→  CENSUS static-only=11 …  GATE RESULT: FAIL (checks failed: 1)
```

The gate resolves at a *later* token-bearing line (here line 232, deep in prose) and fails on
`label-too-deep`. Converting every card's declaration to a bullet item produced `FAIL no-label` on
**13 of 13**. No card uses this form today, so the defect is **latent** — but it is a *new* failure
mode introduced by the hardening.

The script's own comment is also falsified in both directions: `run_gate.sh:111-112` lists
`**Label:** **\`X\`` among "the five label shapes the 13 cards actually use", but no card uses it
and `LABEL_RE` does **not** match it (it matched only via the same deep-line fallback).

Fix: allow an optional list marker (`^[[:space:]]*([-*+][[:space:]]+)?`) or document the single
permitted form explicitly and drop the unsupported shapes from the comment.

### F5 — undocumented output tokens — **was should-fix; FIXED mid-round** [doc]

`NAME_SET`, `NAME_BAD`, `POINTER_STRINGS`, `GATE_REF`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED` and
exit `2` all appeared in the script and not the README, while two script comments claimed the
README mirrored them. The final README documents all of them (§4 table). **Verified fixed.**

### F6 — the extraction regex still admits a space-separated pointer pair — **nit, pre-existing**

`upstream/[^`"|)]+\.[A-Za-z0-9]+:[0-9]+` (unchanged by this diff) permits spaces, so two pointers
in one sentence are extracted as one string and reported as a single `MISSING-PATH`:

```
$ printf '\nTwo pointers: upstream/README.md:9999 and upstream/nope.md:5.\n' >> README.md
$ grep -ohE '<regex>' README.md | tail -1
upstream/README.md:9999 and upstream/nope.md:5
MISSING-PATH … :: upstream/README.md:9999 and upstream/nope.md:5
UNRESOLVED=1
```

It fails closed (a false FAIL, never a false PASS) and is pre-existing, so it is not a regression.
A one-line whitespace exclusion would fix it in a future round.

### F7 — `POINTERS` is self-referential — **accepted, no action**

The new README text correctly records that pass B counts this README's own prose, so editing the
README moves the count. That is honest and sufficient; the binding invariant `UNRESOLVED=0` is
unaffected. Noted only so the numeric pin is not treated as a contract (F3).

### F8 — the `.h1` hardcoded scratch path was a real clean-tree false FAIL — **fixed, credit**

Verified live, not inferred (see §2.1): with `/tmp/advgate` absent the pre-r103 gate printed
`FAIL per-seat manifest sweep` and `GATE RESULT: FAIL (checks failed: 2)` on a **clean** tree,
because `sha256sum … >/tmp/advgate/.h1` failed to open its target and the redirect failure became
the check's exit status. The r103 `mktemp` change removes it.

### F9 — A2's acceptance wording was ambiguous; the implementation chose the permissive branch — **no action**

`fold-spec.md` A2's criterion is "first marked line within 40 lines carrying exactly one allowed
token, whose stripped text is ≤ 8 words". The implementation anchors on a set of *label shapes*
instead of a word count. On the stated acceptance test (prose-hijack copy → `BAD=0`; the old
controls → `FAIL`) it **passes**, so the criterion is met; the divergence is a design choice with a
smaller false-negative surface than a word-count heuristic. Flagged so the choice is recorded, not
silently substituted. F4 is the price of this choice.

## 7. Live-tree state and the transient reds observed while critiquing

During this seat's session the live tree went **red three times, every time because a peer seat
cited an r103 note before writing it** — a recurrence of the class A1/A3 are meant to catch, in
reverse (a *new* citation to a *new* file):

| time | cause | observed |
|---|---|---|
| 15:32 | C1's `adaptation-kimi.md` cites `reports/round-103/note/author.md` before it existed | `MISSING-PATH-REL …/author.md`, `UNRESOLVED=1`, exit 1 |
| 15:34 | SEAT-05's `gate/README.md` cites `reports/round-103/note/gate-pin.md` before it existed | `MISSING-PATH-REL …/gate-pin.md`, `POINTERS=91`, `UNRESOLVED=1`, exit 1 |
| 15:41 | a peer's `gate/README.md` cites `reports/round-103/gate/hardening.md` before it existed | `MISSING-PATH-REL …/hardening.md`, exit 1 (this also produced the two transient `MISS` rows in §5.3) |

All cleared once the cited file landed. **This is the gate working as designed**, and it is
evidence *for* the hardening: the pre-r103 gate (no pass B) would have stayed green through all
three. Recorded here because a reader who ran the gate inside those windows saw a red tree that
was not a defect in the gate or the subtree.

**Final live-tree run, at the revision this critique pins** (`run_gate.sh` `efc1e618…`, README
`21a7d6ff…`, HEAD `c85a816`):

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo rc=$?
NAME_SET=OK NAME_BAD=0
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
rc=0
```

(`POINTERS=101` here, not `95` from §2, because the live subtree carries the C1 freshness note and
the r103 reports — the count is tree-relative by construction, F7.)

## 8. What this critique does not cover, and residual risk

- **A5–A9 are outside this seat's contract** (A1–A4). Two are visibly still open in the diff and
  worth the round's attention: **A7** — `sha256sum` is still invoked unqualified with no `PATH`
  hardening, the one class that has produced a *false green*; and **A8** — the `$(… | wc -l)`
  idioms A8 exploits are unchanged (no `set -e`/`pipefail` was added). **A5** may now be partly
  covered by the `.h1` repair, which runs the shard glob under `--strict`; this seat did **not**
  verify that.
- **This seat did not edit the gate or its README** (ownership is exclusive per file). F2 and F4
  are routed, not fixed.
- **Reproducibility.** The harness is:
  - clean-tree diff — seed a pristine `git archive HEAD` subtree into a faithful root, swap in the
    two scripts, `diff` their stdout after normalising `SUBTREE=`;
  - attack matrix — `/tmp/s17-critic/regress.sh` (17 cases, faithful root).
  Both are pinned to the md5s above; **re-run them if either file is edited again.**
