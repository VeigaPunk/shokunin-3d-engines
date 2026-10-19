# SEAT-89 SCORECARD-SHAPE — r106

Axes: coverage (all three claims represented), calibration (each claim's evidence is a pasteable counting command, not status prose), depth (the command identifies a reproducible check that covers the whole claim).

**Shape verdict: not complete.** At `2026-10-18T21:30:06Z` the SCORECARD/LOG r106 drafts do not exist. The command-as-drafted for C1, C2, and C3 is **missing**. This seat does not substitute inferred commands, spot-check receipts, or standing key facts for draft text. A claim is not counted as having a complete counting command until the draft text itself contains one.

No Unreal runtime claim is made. The editor is not installed. This seat wrote only this file.

## Frame

Commands run from the lane root. HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`, earlier in the same window).

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:30:06Z
$ git diff --quiet -- LOG.md SCORECARD.md; echo LEDGER_DIFF_EXIT:$?
LEDGER_DIFF_EXIT:0
$ git status --short -- LOG.md SCORECARD.md; echo STATUS_EXIT:$?
STATUS_EXIT:0
$ git hash-object -- LOG.md; git hash-object -- SCORECARD.md
2c199c6ea630736d4a23753f5892a893e04e5909
658afba9a080cf2195b563dfbb9ccdfdfdedc455
```

Both blobs match `HEAD` (same hashes on the `21:21:30Z` and `21:23:50Z` rechecks). `rg -n 'Round 106|ROUND 106' LOG.md SCORECARD.md` printed nothing (`NO_R106_VERDICT_ROW`). The only `r106` hit in either ledger is carry-forward, not a round row: `LOG.md:1456` `ROUTED (r106+): P/C operator ruling...`. SCORECARD ends at the Round 105 verdict (`SCORECARD.md:327`). LOG ends at the ROUND 105 entry (`LOG.md:1435–1464`).

Draft seats that would carry the counting commands were absent at the same frame:

```text
ABSENT reports/round-106/r106-report.md
ABSENT reports/round-106/r106-verification-protocol.md
ABSENT reports/round-106/r106-distiller.md
ABSENT reports/round-106/final-verdict-prep.md
ABSENT reports/round-106/ledger-math.md
ABSENT reports/round-106/final-count.md
ABSENT reports/round-106/scorecard-shape.md
```

`find reports/round-106/sweep -name '*.md'` → `SWEEP_MD_COUNT:0`. `find reports/round-106/consistency -name '*.md'` → only `consistency/adversary.md`. Census markdown at `census/` top level: `cannon.md`, `n24-state.md`, `phys3d-joints.md`, `three-default.md`, `verify.md` (5 files). At `21:21:49Z`, `git status --short` was only `?? reports/round-106/`. At `21:26:06Z` the same command's first column was already `8 M` and `1 ??`; names were not captured in that frame. The immediate follow-up after `21:30:06Z`, `git diff --name-only HEAD`, listed nine lesson paths and nothing else:

```text
corpus/lessons/r105-unreal-lifecycle.md
corpus/lessons/r61-stream-review.md
corpus/lessons/r62-three-ortho-near-review.md
corpus/lessons/r63-three-ray-review.md
corpus/lessons/r64-ray-side-review.md
corpus/lessons/r65-ray-order-review.md
corpus/lessons/r66-ray-range-review.md
corpus/lessons/r67-ray-boundary-review.md
corpus/lessons/r68-ray-layers-review.md
```

That list is a moving worktree, not a counting command, and it already moved once inside this seat's window (8 `M` lines, then 9). Do not freeze it into a draft as the C1 after-count.

## Claim mapping

| Claim | Counting command in SCORECARD/LOG/report draft | Shape finding |
|---|---|---|
| C1 coverage — corpus-wide citation sweep: path/command resolution, mechanical fixes with dated notes, judgment defects queued | **Missing** | No claim row. Sweep chunk reports are 0. Nine lesson diffs are not a drafted command and are not the corpus-wide count. |
| C2 depth — `engines.md` census refresh: every engine row re-probed under the two-state model, durable receipts | **Missing** | No claim row. `engines.md` is still the HEAD blob (see below). Five census receipts do not cover every row or both states. |
| C3 calibration — lesson numeric/digest consistency: quoted shas/counts vs the live tree; receipt citations resolvable or dated-note | **Missing** | No claim row. The only consistency artifact is `consistency/adversary.md`, which is a ruling essay, not a digest-vs-tree count. |

## What "complete" requires (audit standard, not a drafted command)

Protocol (`templates/round-prompt.md` §2.4–2.5, `AXES.md` SCORECARD contract): each claim's draft row must carry a pasteable counting command, the before value, the after value, and the commit it was measured against. The same command must appear in the SCORECARD round-106 row, the LOG ROUND 106 entry, and the report's Before → after section. A prose verdict is not a counting command.

The landed r105 shape fails that bar and must not be copied. `rg -n '```|^## Round 105' SCORECARD.md` matched only the heading at line 327. The r105 evidence cells (`SCORECARD.md:331–333`) and the LOG ROUND 105 block (`LOG.md:1435–1448`) are status sentences. They name receipts; they do not paste a command a reader can re-run. An r106 row written in that shape is incomplete even if the verdict word is `improved`.

The measured commit cannot be filled yet. Work is uncommitted. A draft that writes a real commit hash before the work commit exists is a shape defect. A close placeholder is allowed only if the command itself is pasteable against the worktree and the placeholder is marked as unfilled.

Per claim, the command's own output must separate these counts. Collapsing them into one status sentence fails the claim.

**C1.** Output must distinguish (1) files swept, corpus-wide, not one chunk; (2) citations tested, each as path-exists-from-repo-root or command rc; (3) mechanical fixes landed, with silent factual rewrites = 0 and every historical-fact change carrying a dated correction note; (4) judgment defects queued, with the queue path named. A per-chunk report, a single `curl`, or `git diff --name-only` alone is not this command.

**C2.** Output must cover every `engines.md` data row. There are four: Godot 4.7.2, Unity Editor, Unreal Engine, three.js 0.186.1 (`python3` row parse in this seat: `NAMED_ROWS 4`). Where a row is environment-exposed, the command must name both states: default `node` via mise, and pinned `node` at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin`. This seat observed, at `2026-10-18T21:21:40Z`:

```text
DEFAULT=v26.12.0
DEFAULT_PATH=/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
PINNED=v24.21.0
PINNED_PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Durable receipt paths must be in the command's output. State cells move only where a receipt warrants a move; expected promotions are zero unless a later receipt says otherwise. A one-row `--only` PASS is not the census command. No Unreal runtime figure belongs in this command: the row stays `unproven-runtime` / not installed.

At this frame the after-state cannot be measured. `engines.md` is still HEAD:

```text
$ git diff --quiet -- corpus/knowledge/engines.md; echo ENGINES_DIFF_EXIT:$?
ENGINES_DIFF_EXIT:0
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
$ git hash-object -- corpus/knowledge/engines.md
5eef89d484b60e26ab78c29dd86a64781b0df86f
```

The content sha and the git blob hash are different hashes of the same unchanged file. Line 11 still says `Node v26.11.1`. The live default is `v26.12.0`. That string is a queued dated-note candidate, not a state-cell promotion, and it is not yet in a draft command.

**C3.** Output must compare quoted sha256 values and numeric counts in the lesson tree to the live tree, and classify every cited receipt as resolvable-on-disk or dated-note. A consistency essay is not this count. Lesson edits without a digest-diff command are not this count.

## Do not substitute these for the missing commands

These were observed or read. None is a drafted C1/C2/C3 counting command.

- Gate receipt `reports/round-106/gate/final-run.md`: `GATE RESULT: PASS`, `POINTERS=103`, pin `a6aa73ada02a9fb1f5415bec491f9942c519b297`. Static gate only. Not the sweep, not the census, not the digest audit.
- `run_battery.py` sha `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (`sha256sum`, `21:21:40Z`). Identity of the runner, not a claim count.
- Standing battery facts `337/350` (default) and `350/350` (pinned, `reports/round-105/n24/runs/`) are r104/r105 receipts. `reports/round-106/battery-default-quick.md` says its own probes are "not a 337/350 recount."
- `census/three-default.md`: 3/3 and 5/5 under default `v26.12.0` only. Not both states, not all four engine rows.
- `census/cannon.md`: one pinned-env row, `r94_cannon_det` PASS. Not the census.
- `census/phys3d-joints.md`: two default-env rows PASS. Not the census.
- `engine-count.md` (SEAT-98): `ENGINE_ROWS=4`, promotions 0, `engines.md` unchanged, `Node v26.11.1` queued not applied. That is a pre-refresh count. It becomes the C2 before-value only if the draft pastes the command and re-runs it after SEAT-38 lands.

## Close rule

Re-run this audit after SCORECARD.md, LOG.md, and `reports/round-106/r106-report.md` contain r106 rows. Until those rows exist, C1–C3 counting commands are missing. Absence is not evidence that the claims passed or failed. A later draft that copies the r105 prose-only evidence cell, cites one spot-check as the corpus-wide count, or writes a commit hash before the work commit, is still incomplete.
