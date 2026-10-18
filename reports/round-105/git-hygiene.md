# r105 SEAT-34 — Git hygiene

Axes: coverage (all visible worktree paths), depth (attribution and protected-path check), calibration (point-in-time snapshot, not process-level authorship). Snapshot: `2026-10-18T20:37:52Z`, before this report was created. This report is the SEAT-34-assigned path and becomes one additional untracked file after the snapshot below.

## Evidence and full status

Command run: `date -u '+%Y-%m-%dT%H:%M:%SZ'; git status --porcelain=v2 --branch --untracked-files=all`.

Observed output:

```text
2026-10-18T20:37:52Z
# branch.oid 1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b
# branch.head main
# branch.upstream origin/main
# branch.ab +8 -0
1 .M N... 100644 100644 100644 7098aa31a1723d3dc9b450df24b88f5f746e5017 7098aa31a1723d3dc9b450df24b88f5f746e5017 SKILL.md
1 .M N... 100644 100644 100644 e2dcf2088fe4ec6cdfab6badb1577507fb86fb20 e2dcf2088fe4ec6cdfab6badb1577507fb86fb20 corpus/knowledge/unreal-mcp/adaptation-kimi.md
? corpus/fixtures/PINNED-ENV.md
? corpus/lessons/r105-unreal-lifecycle.md
? reports/round-105/freshness-pin.md
? reports/round-105/gate/final-run.md
? reports/round-105/gate/integrity.md
? reports/round-105/gate/pin-after-edits.md
? reports/round-105/gate/scratch/gate-run.rc
? reports/round-105/gate/scratch/gate-run.stderr
? reports/round-105/gate/scratch/gate-run.stdout
? reports/round-105/install-recheck.md
? reports/round-105/kimi404/author.md
? reports/round-105/kimi404/verify.md
? reports/round-105/ledger-check.md
? reports/round-105/ledger-math.md
? reports/round-105/lesson/bleed.md
? reports/round-105/lesson/critic.md
? reports/round-105/n24/adversary.md
? reports/round-105/n24/pre-state.md
? reports/round-105/n24/revert.md
? reports/round-105/n24/runbook.md
? reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout
? reports/round-105/n24/single-confirm.md
? reports/round-105/pc/analyst-1.md
? reports/round-105/pc/analyst-2.md
? reports/round-105/pc/cards.md
? reports/round-105/pc/distiller.md
? reports/round-105/pc/history.md
? reports/round-105/pc/ledger.md
? reports/round-105/physics-carry.md
? reports/round-105/r105-connector.md
? reports/round-105/scorecard-shape.md
? reports/round-105/seats-ledger.md
? reports/round-105/skill6/bleed.md
? reports/round-105/skill6/critic.md
? reports/round-105/stub-cleanness.md
? reports/round-105/subtree-integrity.md
```

Other commands run from the lane root:

- `git diff --name-status HEAD` → `M SKILL.md`, `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`.
- `git diff --cached --name-status` → empty (no staged paths).
- `git ls-files --others --exclude-standard` → 36 untracked paths, matching the 36 `?` entries above.
- `git diff --check` → exit 0, no output.
- `git rev-list --left-right --count origin/main...HEAD` → `0 8` (0 commits only on origin/main; 8 only on main).
- `git diff --stat HEAD` → `2 files changed, 31 insertions(+), 21 deletions(-)`.
- `git status --short -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md reports/round-101 reports/round-102 reports/round-103 reports/round-104 corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/unreal-mcp/gate/README.md` → only `M SKILL.md` and `?? corpus/fixtures/PINNED-ENV.md`.

## Attribution by path

Tracked modifications:

- `corpus/knowledge/unreal-mcp/adaptation-kimi.md` — SEAT-04. `git diff --` this path showed only the source locator URL changing from `.../unreal-engine-skills-for-claude-code` to `.../unreal-engine-skills-for-claude-code-plugin`; `reports/round-105/kimi404/author.md:1-5` declares SEAT-04 and the correction. This is within the SEAT-04/10 ownership rule.
- `SKILL.md` — restricted to SEAT-06, with SEAT-09 permitted for stamp updates. `git diff -- SKILL.md` showed the table scope broadened and row F (lane fixture runtime result) added for C1. `reports/round-105/seats-ledger.md:65` classifies it as the declared C1 owner exception; however, neither the worktree diff nor the available artifact headers establish whether the writer was SEAT-06. **Potential ownership-attribution violation; not proven unauthorized.** Confirm the writer was SEAT-06 (or that any SEAT-09 change was stamp-only). SEAT-08's critic and SEAT-55's bleed report are reviews, not authorship proof.

Untracked paths outside `reports/round-105/`:

- `corpus/fixtures/PINNED-ENV.md` — no author marker in the document. `reports/round-105/n24/runbook.md:1-3` is SEAT-11's runbook and identifies this as its companion instructions; this is the declared fixtures documentation exception, not fixture-code modification.
- `corpus/lessons/r105-unreal-lifecycle.md` — C1 lifecycle lesson; no author seat in its header. It is reviewed by SEAT-02 (`reports/round-105/lesson/critic.md:1`) and SEAT-54 (`reports/round-105/lesson/bleed.md:1`). SEAT-54 flags semantic harness/evidence-audit bleed as FAIL; this is a content/scope finding to resolve, not a Git path-ownership finding.

Round report/receipt paths (seat labels are from each artifact's header or explicit durable-artifact reference):

- `reports/round-105/freshness-pin.md` — SEAT-50.
- `reports/round-105/gate/final-run.md` — SEAT-47; `gate/scratch/gate-run.rc`, `gate/scratch/gate-run.stderr`, and `gate/scratch/gate-run.stdout` are the durable raw artifacts it names.
- `reports/round-105/gate/integrity.md` — SEAT-58.
- `reports/round-105/gate/pin-after-edits.md` — gate pin recheck; no seat marker in the file. It says the gate README pin was not edited.
- `reports/round-105/install-recheck.md` — SEAT-51.
- `reports/round-105/kimi404/author.md` — SEAT-04; `reports/round-105/kimi404/verify.md` — SEAT-05.
- `reports/round-105/ledger-check.md` — SEAT-33; `reports/round-105/ledger-math.md` — SEAT-62.
- `reports/round-105/lesson/bleed.md` — SEAT-54; `reports/round-105/lesson/critic.md` — SEAT-02.
- `reports/round-105/n24/adversary.md` — SEAT-15; `reports/round-105/n24/pre-state.md` — SEAT-12; `reports/round-105/n24/runbook.md` — SEAT-11.
- `reports/round-105/n24/revert.md`, `reports/round-105/n24/single-confirm.md`, and `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout` — N24/C2 artifacts with no explicit seat marker in the output/report headers; exact author attribution is unresolved.
- `reports/round-105/pc/analyst-1.md` — SEAT-19; `pc/analyst-2.md` — SEAT-20; `pc/distiller.md` — SEAT-27; `pc/history.md` — SEAT-56; `pc/ledger.md` — SEAT-28.
- `reports/round-105/pc/cards.md` — P/C card extraction, no seat marker in its header; exact author attribution is unresolved.
- `reports/round-105/physics-carry.md` — SEAT-59; `reports/round-105/r105-connector.md` — SEAT-31; `reports/round-105/scorecard-shape.md` — SEAT-61; `reports/round-105/seats-ledger.md` — SEAT-49.
- `reports/round-105/skill6/bleed.md` — SEAT-55; `reports/round-105/skill6/critic.md` — SEAT-08; `reports/round-105/stub-cleanness.md` — SEAT-35; `reports/round-105/subtree-integrity.md` — SEAT-48.

The attribution scan was run as a Python read-only pass over `git ls-files --others --exclude-standard`, printing each path's first three lines and any `SEAT-<n>` token; it observed `untracked=36`. Artifacts without a direct seat token are explicitly called out above rather than assigned by guess.

## Flags and limits

- No staged changes. No paths under the ledgers, r101–r104 reports, pinned upstream, manifest shards, or `corpus/knowledge/unreal-mcp/gate/README.md` appeared in the bounded status scan. The only fixture path is the SEAT-11 companion Markdown doc; no fixture code path changed.
- The SKILL.md owner check remains an attribution gap until SEAT-06/09 ownership is confirmed. The lifecycle lesson has the separate SEAT-54 content/scope FAIL noted above.
- This is a timestamped live-tree snapshot while other seats are working, not a close-time lock or proof of process authorship. Rerun `git status --porcelain=v2 --branch --untracked-files=all` after peer work settles.

## Follow-up snapshot — 2026-10-18T20:45:54Z

The worktree continued moving. This later status supersedes the earlier inventory above; it includes this report and the new receipts/reviews that arrived after the first capture.

Commands and observed output: `date -u '+%Y-%m-%dT%H:%M:%SZ'; git status --porcelain=v2 --branch --untracked-files=all` → full status below; `git ls-files --others --exclude-standard | wc -l` → `55`; `git diff --check` → exit 0, no output; `git rev-list --left-right --count origin/main...HEAD` → `0 8`; `git diff --stat HEAD` → `2 files changed, 33 insertions(+), 22 deletions(-)`; `git diff --name-status HEAD` → `M SKILL.md`, `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`; `git diff --cached --name-status` → empty. The bounded protected-path scan again returned only `M SKILL.md` and `?? corpus/fixtures/PINNED-ENV.md`.

```text
2026-10-18T20:45:54Z
# branch.oid 1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b
# branch.head main
# branch.upstream origin/main
# branch.ab +8 -0
1 .M N... 100644 100644 100644 7098aa31a1723d3dc9b450df24b88f5f746e5017 7098aa31a1723d3dc9b450df24b88f5f746e5017 SKILL.md
1 .M N... 100644 100644 100644 e2dcf2088fe4ec6cdfab6badb1577507fb86fb20 e2dcf2088fe4ec6cdfab6badb1577507fb86fb20 corpus/knowledge/unreal-mcp/adaptation-kimi.md
? corpus/fixtures/PINNED-ENV.md
? corpus/lessons/r105-unreal-lifecycle.md
? reports/round-105/freshness-pin.md
? reports/round-105/gate/final-run.md
? reports/round-105/gate/integrity.md
? reports/round-105/gate/pin-after-edits.md
? reports/round-105/gate/scratch/gate-run.rc
? reports/round-105/gate/scratch/gate-run.stderr
? reports/round-105/gate/scratch/gate-run.stdout
? reports/round-105/git-hygiene.md
? reports/round-105/install-recheck.md
? reports/round-105/kimi404/author.md
? reports/round-105/kimi404/verify.md
? reports/round-105/ledger-check.md
? reports/round-105/ledger-math.md
? reports/round-105/lesson/bleed.md
? reports/round-105/lesson/critic.md
? reports/round-105/lesson/verify.md
? reports/round-105/math-audit.md
? reports/round-105/n24/adversary.md
? reports/round-105/n24/fingerprint.md
? reports/round-105/n24/markers.md
? reports/round-105/n24/pre-state.md
? reports/round-105/n24/revert.md
? reports/round-105/n24/runbook-critic.md
? reports/round-105/n24/runbook.md
? reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout
? reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json
? reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout
? reports/round-105/n24/single-confirm.md
? reports/round-105/operator-package.md
? reports/round-105/pc/analyst-1.md
? reports/round-105/pc/analyst-2.md
? reports/round-105/pc/cards.md
? reports/round-105/pc/distiller.md
? reports/round-105/pc/history.md
? reports/round-105/pc/impact.md
? reports/round-105/pc/ledger.md
? reports/round-105/pc/review-3.md
? reports/round-105/pc/ruling-draft.md
? reports/round-105/physics-carry.md
? reports/round-105/r105-connector.md
? reports/round-105/r105-distiller.md
? reports/round-105/r105-report.md
? reports/round-105/r105-scribe-audit.md
? reports/round-105/r105-verification-protocol.md
? reports/round-105/scorecard-shape.md
? reports/round-105/seats-ledger.md
? reports/round-105/skill6/author.md
? reports/round-105/skill6/bleed.md
? reports/round-105/skill6/critic.md
? reports/round-105/skill6/review.md
? reports/round-105/skill6/stamps.md
? reports/round-105/stub-cleanness.md
? reports/round-105/subtree-integrity.md
```

### Follow-up ownership and flags

- The earlier tentative `SKILL.md` attribution flag is resolved by new evidence: `reports/round-105/skill6/author.md:1-7` declares SEAT-06 wrote the sixth-row content; `reports/round-105/skill6/stamps.md:1-3` declares SEAT-09's §6 stamp updates. These match the only permitted owners. No unauthorized SKILL write is indicated by the current evidence.
- Newly materialized seat-attributed paths: `reports/round-105/math-audit.md` (SEAT-32); `n24/fingerprint.md` (SEAT-53), `n24/markers.md` (SEAT-14), `n24/runbook-critic.md` (SEAT-57); `pc/impact.md` (SEAT-22), `pc/review-3.md` (SEAT-26), `pc/ruling-draft.md` (SEAT-23); `r105-distiller.md` (SEAT-30), `r105-report.md` (SEAT-42), `r105-verification-protocol.md` (SEAT-39); `skill6/author.md` (SEAT-06), `skill6/review.md` (SEAT-07), `skill6/stamps.md` (SEAT-09).
- `reports/round-105/operator-package.md` and `r105-scribe-audit.md` have no seat marker in their headers. New N24 outputs `n24/runs/node24-full-20261018T202944Z.verdicts.json` and `n24/runs/node24-full-rerun-20261018T204240Z.stdout` have no seat marker; they are C2 run artifacts, author identity unresolved. The N24 rerun stdout/receipt status is distinct from the existing `node24-full-20261018T202944Z.stdout`; do not merge their attribution.
- `reports/round-105/lesson/verify.md` has no seat marker in its header, but uses `/dev/shm/r105-seat03-*` paths and self-identifies a process exception. Its line 28 records the exact command `git -C /dev/shm/r105-seat03-pinclone checkout --quiet a6aa73ada02a9fb1f5415bec491f9942c519b297` and says it was contrary to the no-checkout rule. This is a reported hard-rule violation (seat inferred as SEAT-03; outside the lane worktree, but still a checkout). SEAT-34 did not run that command; the finding is from the report's self-disclosure. It says the lane HEAD/worktree was not switched.
- `reports/round-105/r105-scribe-audit.md:7` reports the Node-24 stdout at 350/350 rows while the paired durable JSON had `seeds_unchanged=false`; this seat did not independently inspect that receipt. Treat the full-battery acceptance as unresolved pending the receipt-based adjudication, not a Git-cleanliness result.
- The lifecycle lesson's content/scope flag remains: SEAT-54's `reports/round-105/lesson/bleed.md` calls semantic harness/evidence-audit bleed FAIL. The newly present `reports/round-105/lesson/verify.md` is a verification artifact, not author attribution for the lesson.
