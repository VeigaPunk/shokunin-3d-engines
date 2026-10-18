# r102 SEAT-51 — Git hygiene audit

Snapshot time: **2026-10-18T14:41:29-03:00** (container clock). HEAD **`2c99b7b8155841617d844c609813afcba77aa207`** (r101 report-last; work commit `1659c03`), branch `main`, `ahead 2` of `origin/main`. HEAD was re-read at the end of the audit and is unchanged — no commit/checkout/reset occurred during this seat.

**Verdict: 0 violations.** Every protected path is content-identical to HEAD; all r102 writes are confined to `reports/round-102/**` plus two authorized in-place conformance fixes outside it.

## Method (commands actually run)

```sh
git status --porcelain -uall
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md SKILL.md PROVINCE.md corpus/fixtures reports/round-101
git diff --quiet HEAD -- <each protected path>; git status --porcelain -uall -- <each protected path>
git hash-object LOG.md SCORECARD.md SHONEN.md          # vs git rev-parse HEAD:<path>
git status --porcelain --ignored -uall -- corpus/fixtures reports/round-101
git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
git stash list; ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge
```

## Protected-path verification

| path | content vs HEAD | porcelain entries | note |
|---|---|---|---|
| `LOG.md` | CLEAN | 0 | blob `e7d9ba7e…` == `HEAD:LOG.md` |
| `SCORECARD.md` | CLEAN | 0 | blob `cf85cea3…` == `HEAD:SCORECARD.md` |
| `SHONEN.md` | CLEAN | 0 | blob `8d85902c…` == `HEAD:SHONEN.md` |
| `SKILL.md` | CLEAN | 0 | — |
| `PROVINCE.md` | CLEAN | 0 | — |
| `corpus/fixtures/**` | CLEAN | 0 non-ignored | 1265 ignored entries, all under `three/node_modules/` (1264) + `__pycache__/` (1) |
| `reports/round-101/**` | CLEAN | 0 | r101 report frozen |

No staged content (`git diff --cached` empty). No `index.lock`, `MERGE_HEAD`, or rebase state. No stash.

**R101 byte-pin (discipline check).** `corpus/knowledge/unreal-mcp/upstream/` and `corpus/knowledge/unreal-mcp/.manifest.d/` are byte-identical to HEAD (`git diff --name-only HEAD -- …` empty). The only tracked change inside the pinned subtree is `corpus/knowledge/unreal-mcp/README.md`, i.e. the F8 wording fold, which is the exception the round explicitly authorizes. Independent confirmation that the wording fold is factually correct, run inside the subtree:

```sh
sha256sum -c .manifest.d/*.sha256   # 24 OK, 0 FAILED, exit 0
sha256sum -c .manifest.d/audit-reference.sha256   # 12 OK
```

The old text said "12 lines" for the glob sweep; the corrected text distinguishes 12 (`audit-reference.sha256`) from 24 (glob). Observed counts match the corrected text exactly, so the wording change is a correction, not a rewrite.

## Live write set at snapshot

Tracked modifications (3):

- `corpus/artifacts/unreal-r22/README.md` — F1 fix (`.shokunin/game-dev-3d/` prefix dropped in 2 command lines; diff is 2 insertions / 2 deletions). Verified live: both repaired commands exit `0` from repo root (`PASS local-static actual=accept expected=accept`; `PASS local-static actual=reject expected=reject`).
- `corpus/lessons/r22-unreal-review.md` — same F1 prefix fix in 5 command strings (7 insertions / 7 deletions).
- `corpus/knowledge/unreal-mcp/README.md` — F8 wording fold (see above).

Untracked, non-ignored (7 files, all under `reports/round-102/`):

```
reports/round-102/battery-integrity.md
reports/round-102/before/baseline-integrity.md
reports/round-102/before/F2-verdicts-json.md
reports/round-102/before/F3-sha-drift.md
reports/round-102/before/F5-engines-threejs.md
reports/round-102/before/F6-rea-census.md
reports/round-102/repairs/F1a-r22-readme.md
```

Every untracked path is a report artifact; no untracked write landed in `corpus/**`.

## Observations for the L1 (not violations)

1. **The tree was mutating while this audit ran.** `git status --porcelain -uall` returned 1 entry at 14:41:23, then 3, then 5, then 7 across four reads ~30 s apart. Seats were still landing `before/` artifacts and the two in-place conformance fixes. Numbers above are the 14:41:29 snapshot; the L1 should re-run `git status --porcelain -uall` after the last seat exits before committing.
2. **Two seats wrote outside `reports/round-102/`** — `corpus/artifacts/unreal-r22/README.md` and `corpus/lessons/r22-unreal-review.md`. Both are mechanical command/path conformance fixes, which the round's correction-note discipline explicitly permits in place, and both are required by claim C2 (F1). Flagged only so the L1 knows the round's write surface is wider than `reports/round-102/`.
3. **F5/F6 targets were untouched at snapshot.** `corpus/knowledge/engines.md` and `corpus/knowledge/rea.md` show no porcelain entry, so the C1(c) evidence-class update and the F6 rea.md census repair had not landed when this seat ran.
4. **F2/F3/F5 content repairs were still pending in `corpus/lessons/r22-unreal-review.md`.** The r22 lesson as of snapshot still cites the gitignored receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json` (confirmed ignored: `corpus/.gitignore:1:live/`) and the stale `run_battery.py` seed SHA `a065a56d…`. Only the F1 path prefixes were fixed there. This is expected mid-round, but it means the "no citation to a non-reproducible artifact" property does not yet hold repo-wide.
5. **Ignored churn under `corpus/fixtures/` is benign.** 1265 ignored files, 1264 of them the `three/node_modules/` tree (npm install, mtimes within the last 12 h) plus one `__pycache__/*.pyc`. Nothing tracked was disturbed, and no ignored artifact leaked into a non-ignored path.

## Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git status --porcelain -uall
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md SKILL.md PROVINCE.md corpus/fixtures reports/round-101
git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
```
