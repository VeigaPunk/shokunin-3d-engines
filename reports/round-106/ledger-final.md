# r106 SEAT-116 — LEDGER-FINAL

Scope: last pre-close check that `LOG.md` and `SCORECARD.md` are still untouched by r106 seats. Read-only audit. This report is the only path written. Not a lock: a seat that writes either file after the rehash below makes this verdict stale.

- HEAD: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`)
- HEAD subject: `r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0` (`git log -1 --format='%H%n%s'`)
- First measure: `2026-10-18T21:21:49Z`. Rehash immediately before this write: `2026-10-18T21:21:58Z`. Post-write rehash is the stamp at the bottom.
- Axes: calibration (byte identity vs HEAD), coverage (both ledger paths still the committed blobs). Depth not probed (no runtime).

## Verdict — PASS

Worktree blobs of `LOG.md` and `SCORECARD.md` are identical to `HEAD`. Index matches HEAD. `git status` on both paths is empty. No untracked copy. mtimes predate the r105 report-last commit. Last ledger entry is ROUND 105. The only `r106` string in `LOG.md` is the already-committed ROUTED forward pointer at line 1456, present in `HEAD:LOG.md`.

## Paste — hash-object vs HEAD

Command:

```
date -u +%Y-%m-%dT%H:%M:%SZ
git rev-parse HEAD
git log -1 --format='%H%n%s%n%ci'
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md; do
  wt=$(git hash-object -- "$f")
  hd=$(git rev-parse "HEAD:$f")
  printf '%-13s wt=%s head=%s %s\n' "$f" "$wt" "$hd" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"
done
```

Observed (`2026-10-18T21:21:49Z`, reconfirmed `2026-10-18T21:21:58Z` for the two ledger files):

```
0cc3f4162f8c319f8d01a69a174fe939f36701bd
0cc3f4162f8c319f8d01a69a174fe939f36701bd
r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0
2026-10-18 18:16:01 -0300
LOG.md        wt=2c199c6ea630736d4a23753f5892a893e04e5909 head=2c199c6ea630736d4a23753f5892a893e04e5909 IDENTICAL
SCORECARD.md  wt=658afba9a080cf2195b563dfbb9ccdfdfdedc455 head=658afba9a080cf2195b563dfbb9ccdfdfdedc455 IDENTICAL
SHONEN.md     wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 IDENTICAL
PROVINCE.md   wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 IDENTICAL
SKILL.md      wt=81970105e72856d7c17e83bf95820584883d52f2 head=81970105e72856d7c17e83bf95820584883d52f2 IDENTICAL
```

SHONEN / PROVINCE / SKILL are corroboration from the same command, not this seat's contract. SEAT-56 owns the broader ledger-check. At this runtime `reports/round-106/ledger-check.md`, `seats-ledger.md`, `final-integrity.md`, and `git-hygiene.md` were absent (`ls` exit non-zero, four "No such file" lines).

## Paste — status, index, numstat, sizes, sha256

Command:

```
git status --short --untracked-files=all -- LOG.md SCORECARD.md
echo "STATUS_EXIT=$?"
git diff --quiet HEAD -- LOG.md SCORECARD.md && echo PASS_LOG_SCORECARD_MATCH_HEAD
git diff --cached --name-status -- LOG.md SCORECARD.md
git diff --numstat HEAD -- LOG.md SCORECARD.md
git ls-files -v -- LOG.md SCORECARD.md
stat -c '%y %s %n' LOG.md SCORECARD.md
wc -l LOG.md SCORECARD.md
git cat-file -s HEAD:LOG.md
git cat-file -s HEAD:SCORECARD.md
sha256sum LOG.md SCORECARD.md
git cat-file blob HEAD:LOG.md | sha256sum
git cat-file blob HEAD:SCORECARD.md | sha256sum
```

Observed:

```
STATUS_EXIT=0
PASS_LOG_SCORECARD_MATCH_HEAD
H LOG.md
H SCORECARD.md
2026-10-18 18:15:23.621437394 -0300 282360 LOG.md
2026-10-18 18:15:23.621437394 -0300 51554 SCORECARD.md
  1464 LOG.md
   335 SCORECARD.md
  1799 total
282360
51554
6f9d4c08a156acdf039f0a791504fd2ce155dc6fef57d57604aeae9f9d0a65c7  LOG.md
50adb78d5c41f9eeb3dbe0f839289a2851f4b6b76b06094d1120d6d1470463ce  SCORECARD.md
6f9d4c08a156acdf039f0a791504fd2ce155dc6fef57d57604aeae9f9d0a65c7  -
50adb78d5c41f9eeb3dbe0f839289a2851f4b6b76b06094d1120d6d1470463ce  -
```

Empty `git status`, empty cached `name-status`, and empty `numstat` mean zero insertions, zero deletions, no staged delta, no untracked sibling. `H` is the ordinary cached flag, not assume-unchanged (`h`) and not skip-worktree (`S`). Worktree sha256 equals `git cat-file blob HEAD:<file>`. Blob sizes equal `stat` sizes (282360 and 51554). mtimes `18:15:23 -0300` are 38 seconds before the report-last commit timestamp `18:16:01 -0300`. `git log -1 -- LOG.md SCORECARD.md` is that same commit.

## Content bound (identity implies this; quoted so a later grep is not a false alarm)

`git grep -n -e 'round-106' -e 'ROUND 106' -e 'r106' HEAD -- LOG.md SCORECARD.md` matched one line only:

```
HEAD:LOG.md:1456:- ROUTED (r106+): P/C operator ruling (package + queue in reports/round-105/
```

Worktree `LOG.md` ends at line 1464 with the ROUND 105 L0 question (`which side of the P/C precedence ruling binds?`). No ROUND 106 heading. `SCORECARD.md` ends at line 335 with the Round 105 verdict block (`Work 3634bc0; report-last follows.`). No Round 106 verdict table.

## What this does not prove

Point-in-time only. Concurrent seats can still open either file after the stamp below. This seat did not edit `LOG.md` or `SCORECARD.md` and must not. A close scribe that appends ROUND 106 after this file lands will correctly make the blobs differ from HEAD; that is the operator fold, not a seat violation of this check. At `2026-10-18T21:21:49Z`, `git diff --name-only HEAD | wc -l` was `0` — no tracked path differed — but that count is not this seat's contract and will move as other seats land.

## Post-write rehash

Command rerun after this file was created (`date -u +%Y-%m-%dT%H:%M:%SZ` → `2026-10-18T21:32:37Z`):

```
for f in LOG.md SCORECARD.md; do
  wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f")
  printf '%s wt=%s head=%s %s\n' "$f" "$wt" "$hd" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"
done
git status --short --untracked-files=all -- LOG.md SCORECARD.md; echo "STATUS_EXIT=$?"
git diff --quiet HEAD -- LOG.md SCORECARD.md && echo PASS_LOG_SCORECARD_MATCH_HEAD
stat -c '%y %s %n' LOG.md SCORECARD.md
```

Observed:

```
LOG.md wt=2c199c6ea630736d4a23753f5892a893e04e5909 head=2c199c6ea630736d4a23753f5892a893e04e5909 IDENTICAL
SCORECARD.md wt=658afba9a080cf2195b563dfbb9ccdfdfdedc455 head=658afba9a080cf2195b563dfbb9ccdfdfdedc455 IDENTICAL
STATUS_EXIT=0
PASS_LOG_SCORECARD_MATCH_HEAD
2026-10-18 18:15:23.621437394 -0300 282360 LOG.md
2026-10-18 18:15:23.621437394 -0300 51554 SCORECARD.md
```

mtime unchanged across the write of this report. Verdict holds at `2026-10-18T21:32:37Z`: LOG and SCORECARD still match HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

Same two `git hash-object` comparisons rerun after this stamp was inserted: `2026-10-18T21:38:23Z`, both `IDENTICAL`, `STATUS_EXIT=0`, mtimes still `2026-10-18 18:15:23.621437394 -0300`. Close check PASS.
