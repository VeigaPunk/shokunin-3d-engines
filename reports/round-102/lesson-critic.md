# r102 lesson-critic — adversarial read of `corpus/lessons/r102-unreal-integration.md`

Seat: **SEAT-24 LESSON-CRITIC**. Round r102, lane game-dev-3d-shokunin.
Run date: 2026-10-18 (UTC). All commands below were executed on this host this
session; output is verbatim.

Subject under test:

| field | value |
|---|---|
| path | `corpus/lessons/r102-unreal-integration.md` |
| sha256 at review | `c7f18f285cd11809c632277905bd306287603d0f3c0b1302d4bd95bcf26932cc` |
| lines | 212 |
| mtime | 2026-10-18 14:44:38 -0300 |
| lane HEAD | `2c99b7b8155841617d844c609813afcba77aa207` |

**Verdict: ADMIT-WITH-CORRECTIONS.** The lesson's laws are sound and its
no-runtime-claim posture is intact (no unlabeled runtime claim found anywhere in
it). Five defects were reproduced, all of them in the *evidence* layer rather
than the *law* layer: one claim falsified by its own command (D1), one pointer
whose target does not say what the lesson claims (D2), two observations that no
longer reproduce (D4, D5), and one count that is simultaneously correct for one
scanner and stale for another (D3). None of the five touches an axis claim, and
none asserts Unreal behavior. Every defect is a *prose-cites-bytes* failure —
exactly the class the lesson itself names — which is why they matter to a
coverage/calibration round. None is a fabrication: in each case the cited value
was true when taken and stopped being true when the tree moved under it.

Method note: the lesson was revised **during this review**. The first revision I
read (178 lines, sha `ace4ce52…`) cited `README.md` by line number; the second
(212 lines, sha `c7f18f28…`) cites it by section heading instead, and the subtree
`README.md` itself changed shape twice (`…ef17c775…` → `c79d8dd1…`). All findings
below are against the current 212-line revision. Findings that existed only in
the superseded revision are recorded in §6, not scored.

---

## 1. Scope of the adversarial read

The seat brief asks for three things: any unlabeled runtime claim, any pointer
that does not resolve, any law stated without its source. I ran all three as
mechanical sweeps, then hand-checked every hit.

| check | command | result |
|---|---|---|
| pointer resolution (subtree base) | `bash /tmp/r102-seat24/resolve.sh` | 29/29 in-range; see §3 |
| line-number pointers | same | 1 bad (`engines.md:15-17` in the *earlier* revision only) |
| runtime-claim labels | `bash /tmp/r101-closeout/runtime-claim-scan.sh /tmp/r102-seat24/lesson` | `RUNTIME_NAMED_FILES=1 LABELED_OR_DISCLAIMED=1 UNLABELED=0` / `STEP=PASS` |
| law sources | hand-check of every `Law N` bullet | every law cites a receipt; see §5 |
| the lesson's own cited commands | re-executed verbatim | **2 of 4 no longer reproduce**; see §2 |

Pointer-base convention, resolved and confirmed: the lesson writes bare
`README.md` / `PROVENANCE.md` / `adaptation-kimi.md` / `executability/*.md`
(subtree-relative, base `corpus/knowledge/unreal-mcp/`) and full
`corpus/knowledge/...` / `reports/...` paths (lane-relative). Both conventions
resolve; the mixed base is a readability hazard, not a defect, because the
subtree-relative form is used only for files that exist only in the subtree.

---

## 2. D1 — a claim falsified by its own command (the load-bearing defect)

`corpus/lessons/r102-unreal-integration.md:189-191`:

> Of the routed pre-existing defects, three were fixed in r102 by other seats
> (r22 wrong path root — `grep -c 'shokunin/game-dev-3d'` now 0 in both r22
> files; …

Re-run the command the lesson names:

```
$ for f in corpus/artifacts/unreal-r22/README.md corpus/lessons/r22-unreal-review.md; do
    printf '%-44s grep -c = %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"; done
corpus/artifacts/unreal-r22/README.md        grep -c = 0
corpus/lessons/r22-unreal-review.md          grep -c = 1
```

The claim is **false for one of the two files it names**. The surviving hit is
the repair's own correction note, `corpus/lessons/r22-unreal-review.md:55`:

> The two command blocks in this lesson were re-rooted in r102 from a
> never-existent `.shokunin/game-dev-3d/` prefix to repo-relative paths
> (mechanical conformance fix, not a factual change); all four commands re-run
> exit 0.

So the dead prefix is *gone from the commands* (the F1 repair is real and
correct) but it is *quoted in the correction note that documents the repair*.
The lesson's one-line test therefore cannot distinguish "fixed" from "fixed and
documented" — and it reports 0 where the honest reading is "0 occurrences as a
command root, 1 as a quoted historical token".

**Severity: high for this round.** The lesson is the carry-forward artifact; a
future seat that greps this number and gets 1 will conclude the F1 repair
regressed. The correct phrasing is `grep -c 'shokunin/game-dev-3d'` → 0 in
`corpus/artifacts/unreal-r22/README.md`, 1 in `corpus/lessons/r22-unreal-review.md`
(the correction note's quotation), 0 as a live command root in both.

**Repair (for the lesson's owner, not this seat):** state the count per file, or
use a root-anchored pattern (`grep -cE '(^|[^.])\.shokunin/game-dev-3d/'`) that
excludes the quoted token. Do not silently change the number to 1 — the
distinction is the point.

---

## 3. D2 — a resolving pointer whose target does not say what the lesson claims

`corpus/lessons/r102-unreal-integration.md:127-128`:

> (`reports/round-101/r101-critic-c3.md:365` F8, the finding; `gate/README.md:40`
> pins both counts).

`gate/README.md:40` is:

```
$ awk 'NR==40' corpus/knowledge/unreal-mcp/gate/README.md
**Expected:** `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`, then `STEP=PASS`.
```

That line pins the **12**-entry manifest check only. It does not mention 24:

```
$ grep -n "24" corpus/knowledge/unreal-mcp/gate/README.md
(no output; grep exit 1)
```

The string `24` occurs **nowhere** in `corpus/knowledge/unreal-mcp/gate/README.md`.
The pointer resolves (the file exists, line 40 is in range) but its *claim about
the target* is false — the more dangerous kind of bad pointer, because a range
check passes it.

**Where the counts actually live:** `corpus/knowledge/unreal-mcp/README.md:169-170`
and `:187` (the F8 fold), and the gate's own CHECK 1 output. The pointer should
name those, or drop the `:40` and cite the gate's observed output instead.

---

## 4. D3–D5 — observations that no longer reproduce

### D3 — the lesson falls into its own "never trust a count in prose" trap

The lesson's second counting trap (`:130-134`) says: *"Enumerate, never trust a
count written into prose."* Its own `Re-running the gate` section then writes two
counts into prose, and one of them is stale.

The subtlety is worth stating precisely, because the *same number* is right in
one place and wrong in another:

| lesson line | cites | status |
|---|---|---|
| `:148` | in-repo gate CHECK 4 → `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` | **correct** — the gate excludes its own `gate/README.md` |
| `:153` | `/tmp` standalone script → `POINTERS=40 UNRESOLVED=0` | **stale** — that script does *not* exclude `gate/README.md`; it now reads 43/3 |

So `POINTERS=40` is not simply "an old number": it is the *current, correct* gate
output and the *stale* `/tmp` output, because the two scanners disagree about
what to exclude. The lesson quotes one number for both, which is the actual
defect — see D4.

Separately, the superseded revision cited `find corpus/knowledge/unreal-mcp
-type f | wc -l` → `40` with the breakdown "12 upstream + 12 manifests + 3 index
+ 13 cards". Re-run:

```
$ find corpus/knowledge/unreal-mcp -type f | wc -l
42
```

The delta is exactly the new `gate/` directory (2 files). The current revision
has dropped that citation; it is recorded in §6, not scored.

### D4 — the `/tmp` standalone sweep no longer passes

`corpus/lessons/r102-unreal-integration.md:151-155`:

> The same checks run standalone:
> `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` →
> `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`;

Re-executed verbatim:

```
$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:500 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:9999 (max 112)
POINTERS=43 UNRESOLVED=3
STEP=FAIL
```

`POINTERS` moved 40 → 43 and `UNRESOLVED` moved 0 → 3. All three new failures
are attributable to one file:

```
$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp 2>&1 \
    | grep LINE-OOR | sed 's/ ::.*//' | sort | uniq -c
      3 LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md
```

**Cause, precisely:** the r101 script's only exclusions are `*/upstream/*` and
the protocol file itself:

```
$ grep -n 'case "$f" in' /tmp/r101-closeout/pointer-check.sh
15:    case "$f" in */upstream/*|"$self") continue;; esac
```

The r102 gate added `gate/README.md`, which — by design — quotes deliberately
broken control pointers (`upstream/README.md:9999`, `:500`, `:200`,
`upstream/nope.md:N`) as its own worked examples. The r101 script does not
exclude it, so it reports the gate's specification as three broken pointers.
This is the *same* self-contamination mechanism the lesson describes one
paragraph later (`:162-166`) for the protocol file — the lesson names the
mechanism but does not notice that its own new gate file is a second instance of
it, and cites the now-failing numbers as observed.

**Proof of attribution (removal test).** Copy the subtree without `gate/` and
re-run the identical script:

```
$ T=/tmp/r102-seat24/nogate; rm -rf $T; mkdir -p $T
$ cp -r corpus/knowledge/unreal-mcp/* $T/ && rm -rf $T/gate
$ bash /tmp/r101-closeout/pointer-check.sh $T
POINTERS=40 UNRESOLVED=0
STEP=PASS
```

With `gate/` present: `POINTERS=43 UNRESOLVED=3 / STEP=FAIL`. With `gate/`
removed: `POINTERS=40 UNRESOLVED=0 / STEP=PASS` — the cited numbers return
*exactly*. The decomposition, replicating the script's own per-file `sort -u`
summation, is `40` (rest of subtree) `+ 3` (`gate/`) `= 43`, and those 3 are
exactly `gate/README.md`'s distinct control pointers:

```
$ (per-file sort -u summed, non-gate subtree) = 40
$ (per-file sort -u summed, gate/)           = 3
$ sum = 43
```

The cited `40` was correct for the pre-gate subtree; it is not a fabrication, it
is a number whose denominator changed under it.

The **in-repo gate is green** (see §5); only the `/tmp` stopgap is red. The
lesson's advice ("prefer the in-repo gate over the `/tmp` scripts", `:157-160`)
is therefore correct — but the observation it prints next to that advice is
stale and self-contradicting.

### D5 — the self-contamination number

`corpus/lessons/r102-unreal-integration.md:162-164`:

> The pointer scanner **self-contaminates** on the protocol's own negative
> controls: sweeping `reports/round-101` wholesale reads `UNRESOLVED=2` /
> `STEP=FAIL` on strings the protocol instructs the verifier to plant.

Re-run unfiltered:

```
$ (unfiltered sweep over reports/round-101, no self-exclusion)
MISSING-PATH reports/round-101/r101-verification-protocol.md :: upstream/nope.md:3
LINE-OOR reports/round-101/r101-verification-protocol.md :: upstream/README.md:200 (max 112)
LINE-OOR reports/round-101/r101-verification-protocol.md :: upstream/README.md:500 (max 112)
LINE-OOR reports/round-101/r101-verification-protocol.md :: upstream/README.md:9999 (max 112)
UNFILTERED_UNRESOLVED=4
```

**No scan of the committed tree yields the cited `2`.** I first wrote here that
the protocol's control block had grown; that was an inference and it is
**wrong** — `reports/round-101/r101-verification-protocol.md` is frozen at the
r101 work commit (`git diff --stat HEAD -- …` → empty; `git log --oneline -- …`
→ one commit, `1659c03`), so its control strings cannot have changed since r101.
The real explanation is in the r101 report itself,
`reports/round-101/r101-report.md:154-155`:

> this report named them when first drafted, which made this file a second
> contaminating source.
>
> **De-contaminated and re-measured [O].** Both strings have been removed from
> this file.

So `UNRESOLVED=2` was a **drafting-time measurement taken when
`r101-report.md` itself still quoted the control strings**; both were removed
before the report landed. The number is therefore stale by construction and
cannot reproduce — which is exactly why the same report hedges it as "will
always read `UNRESOLVED=2`" (`:172`) while its own table records `0` (`:146-147`).

**Direct proof by simulation.** Restore the drafting-time state in a copy of just
that one file and re-run the same scanner:

```
$ T=/tmp/r102-seat24/draftsim; rm -rf $T; mkdir -p $T
$ cp reports/round-101/r101-report.md $T/
$ printf '\nsee upstream/README.md:9999 and upstream/nope.md:3\n' >> $T/r101-report.md
$ bash /tmp/r101-closeout/pointer-check.sh $T
LINE-OOR /tmp/r102-seat24/draftsim/r101-report.md :: upstream/README.md:9999 (max 112)
POINTERS=2 UNRESOLVED=2
STEP=FAIL

$ U=/tmp/r102-seat24/landsim; rm -rf $U; mkdir -p $U
$ cp reports/round-101/r101-report.md $U/
$ bash /tmp/r101-closeout/pointer-check.sh $U
POINTERS=0 UNRESOLVED=0
STEP=PASS
```

The simulated drafting-time file yields `UNRESOLVED=2` **exactly**, and the
landed file yields `0`. The cited number is thus fully explained and provably
unreproducible against the committed tree — a stale artifact of the r101
drafting process, not an error the lesson invented.

I also confirmed the negative: no *other* file under `reports/round-101` quotes
the control strings (`grep -rln 'upstream/README.md:9999\|upstream/nope.md'
reports/round-101/*.md | grep -v r101-verification-protocol` → empty), so the
protocol file is the sole remaining source and the script excludes it by name
(`self=reports/round-101/r101-verification-protocol.md`, line 11).

Note the honest reading of the distinct scans, which the lesson conflates:

| scan | exclusion | now |
|---|---|---|
| r101 `/tmp` script over `reports/round-101` | excludes the protocol file | `POINTERS=75 UNRESOLVED=0` / PASS |
| r102 `reports/round-102/reruns/pointer-sweep.sh` over `reports/round-101` | sentinel-based, does not exclude the protocol | `POINTERS=127 UNRESOLVED=1` / FAIL |
| hand-rolled unfiltered sweep (no exclusion at all) | none | `UNFILTERED_UNRESOLVED=4` |

The lesson should attribute the `2` to the r101 report as a superseded
drafting-time number, or re-measure. As written it reads as a fresh observation.

---

## 5. What the lesson gets right (verified, not assumed)

Every one of these was re-run by me against current bytes; the lesson's claim is
confirmed.

- **The in-repo gate passes.** `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`
  → `GATE RESULT: PASS (checks failed: 0)`, exit `0`; CHECK 1
  `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`; CHECK 2 `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`,
  `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0`; CHECK 3
  `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0`;
  CHECK 4 `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`. The lesson's
  quoted CHECK 3/4 numbers (`:146-150`) are exact.
- **The pin holds, independently.** Fresh clone
  `git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r102-seat24-ref`
  → `clone_rc=0`, `git rev-parse HEAD` → `a6aa73ad…`, `tracked=12`, and
  `diff` of local vs clone path sets → `PATH_SET_EQUAL=yes`. The lesson's
  Law-1 re-derivation command (`:21`) reproduces: from
  `corpus/knowledge/unreal-mcp/`, `sha256sum -c .manifest.d/audit-reference.sha256`
  → 12 `OK`, rc=0.
- **The F8 counts are as the lesson states.** `audit-reference.sha256` → **12**
  `OK`; glob `*.sha256` → **24** `OK` (verified from inside the subtree, the
  documented base). The lesson's own re-derivation line (`:123-125`) is exact.
- **The F7 six-card claim is exact.** `grep -rln 'Not `unproven-runtime`'
  corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → `6`
  (`animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`,
  `materials`, `meshes-textures`). The lesson's "Six of the 13 cards" is right.
- **The label census is exact.** 13 cards, 12 × `static-only`,
  1 × `unproven-runtime` (`executability/actors-scene.md:5`), 0 × `verified-here`.
- **`engines.md:13-16` resolves and is the right text.** Current
  `corpus/knowledge/engines.md` has 16 lines; `:13-16` is the "Rules: an engine
  row may move … only with a saved receipt of a bounded fixture run and a
  non-author verifier" block. (An earlier revision cited `:15-17`, which was
  out of range at 16 lines; the current revision is correct.)
- **`engines.md:10` status cells did not move.** The row still reads
  `| Unreal Engine | no | no | …` — the lesson's claim at `:202-206` is exact,
  and the evidence column does now name the two static classes.
- **The three "fixed" defects really are fixed.** `npm ci --prefix` present in
  `engines.md` (1 hit); `rea.md` carries a dated correction note at `:29` naming
  JADX 1.5.6 / Binwalk 3.1.0 / Unblob 26.6.4 as present; the r22 lesson carries
  a dated correction note at `:50` covering the non-resolvable `verdicts.json`,
  the era-blob digests, and the re-rooted commands.
- **The two "still live" defects are still live.** `corpus/live/runs/20261013T053632289732Z/verdicts.json`
  → `No such file or directory`; `a065a56d…` appears twice in the r22 lesson —
  once as the historical citation (`:48`) and once inside the correction note
  (`:53`), which is the correct shape.
- **No law lacks its source.** Every bullet under Law 1–4 carries at least one
  resolvable receipt path, and every one I spot-checked resolves to text that
  supports the law. `LOG.md:1302-1325` is the ROUND 101 entry (1302–1325 in
  range).
- **No unlabeled runtime claim.** `RUNTIME_NAMED_FILES=1 LABELED_OR_DISCLAIMED=1
  UNLABELED=0` / `STEP=PASS` on the lesson alone. Hand-read confirms it: the
  lesson names live-editor surfaces only inside the policy's `unproven` list
  (`:49-51`) and in negations ("nothing here asserts Unreal behavior", `:8`;
  "No live-editor evidence exists or can exist here", `:14`). The `UNLABELED=0`
  invariant the lesson itself recommends at `:210` holds for its own text.

---

## 6. Superseded-revision findings (recorded, not scored)

The first revision (178 lines, sha `ace4ce52…`, read at 17:42:51Z) had additional
pointer drift that the current revision fixes. Recorded here because the lesson's
own hook 3 (`:182-187`) warns that the subtree `README.md` is a moving surface,
and these are the evidence for that warning:

| # | superseded citation | actual target | status |
|---|---|---|---|
| S1 | `README.md:262-264` for the byte-identity sweep | `:262-264` is the "Reproducing the checks" block; the sweep block is `:169-187` | **fixed** — current revision cites the section heading |
| S2 | `README.md:257-263` for "Enumerate what is actually present" | that bullet is at `:232-236` (unchanged in both revisions) | **fixed** — now cited by section + bullet text |
| S3 | `engines.md:15-17` for the file's own rule | file has 16 lines | **fixed** — now `:13-16` |
| S4 | `find … \| wc -l` → `40` | 42 (gate added 2 files) | dropped in current revision |
| S5 | `README.md` "12 lines" block cited as the F8 defect | the fold had already landed; the block then printed 24 | correctly reframed as "a later seat edited this block … re-measure rather than trusting either revision" |

The fact that five pointer/count defects in revision 1 became one (D2) in
revision 2 is itself the round's most useful calibration datum: **the lesson
improved by citing sections instead of lines.** That is worth keeping as a
standing rule — line-number citations into a concurrently-edited file are
defects waiting to happen.

---

## 7. Per-axis judgment

| axis | movement | basis |
|---|---|---|
| coverage | **improved** | the lesson is the first carry-forward artifact to name the gate, the pin scope, and the card-ternary collision in one place; the gate itself is re-runnable and green |
| depth | **improved, modestly** | D4's root cause (a second self-contamination site: the gate's own specification) is a genuinely new mechanism, found by adversarial read rather than by authoring |
| calibration | **improved, with a caveat** | the lesson names its own defect class ("prose-cites-bytes") and then commits four instances of it — the caveat is that naming a class is not yet avoiding it |

No axis claim in the lesson is harmed by any finding. D1 is the only one that
could mislead a downstream seat into a wrong conclusion (that the F1 repair
regressed); D2 is a false claim about a resolving target; D3–D5 are stale
observations.

---

## 8. Required corrections (for the lesson's owner)

1. **D1 (blocking).** Replace "`grep -c 'shokunin/game-dev-3d'` now 0 in both r22
   files" with the per-file counts (0 and 1) and the note that the single
   occurrence is the correction note's quotation. Do not change the number to 1
   silently — the distinction is the finding.
2. **D2.** Retarget the "pins both counts" pointer from `gate/README.md:40` to
   `README.md:169-170`/`:187` (where the counts live) or to the gate's CHECK 1
   observed output.
3. **D4.** Either re-measure the `/tmp` standalone sweep and record the current
   `POINTERS=43 UNRESOLVED=3 / STEP=FAIL`, or drop the `/tmp` observation
   entirely (the lesson already recommends the in-repo gate). If keeping it, add
   the cause: `gate/README.md` is a second self-contamination site that the r101
   script does not exclude.
4. **D5.** Attribute the `UNRESOLVED=2` reading to the r101 report as a
   superseded *drafting-time* number (both contaminating strings were removed
   before that report landed — `r101-report.md:154-158`), or re-measure. As
   written it reads as a fresh observation. Note the two scans now disagree
   anyway (`0` with the protocol excluded, `4` unfiltered), so a bare number
   without its command is not evidence.
5. **Adopt section-heading citations** for the subtree `README.md` throughout —
   revision 2 already does this in most places; finish the job for the F8 line.

---

## 9. Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# D1
for f in corpus/artifacts/unreal-r22/README.md corpus/lessons/r22-unreal-review.md; do
  printf '%-44s %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"; done

# D2
awk 'NR==40' corpus/knowledge/unreal-mcp/gate/README.md
grep -n "24" corpus/knowledge/unreal-mcp/gate/README.md        # no hits, exit 1

# D4
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp

# D5
bash reports/round-102/reruns/pointer-sweep.sh reports/round-101

# clean side: the in-repo gate
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

No Unreal runtime claim is made anywhere in this document. The Unreal Editor and
UnrealBuildTool are not installed on this host; every Unreal statement above is a
file-level fact (a path, a hash, a count, a line of text) and proves nothing
about plugin load, compilation, or engine runtime behavior. This seat wrote only
`reports/round-102/lesson-critic.md`; no lesson, subtree, fixture, or pinned file
was modified.
