# r105 SEAT-30 — DISTILLER (mid-flight synthesis)

**Seat:** SEAT-30 DISTILLER · round 105 · lane `game-dev-3d-shokunin`  
**Owned path written:** this file only (`reports/round-105/r105-distiller.md`).  
**Frame:** `2026-10-18T20:40:47Z`; HEAD `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b` (`1eaa568`).  
**Axes:** coverage · depth · calibration. Every status below is point-in-time; the worktree moved during this seat. No Unreal runtime claim is made.

## 0. Snapshot verdict

| claim | state at this frame | evidence / boundary |
|---|---|---|
| **C1 — lifecycle lesson, URL correction, sixth SKILL row** | **Partly landed; scope and verification remain open.** The lesson and URL correction exist; SKILL has rows A–F. | Lesson bleed review is against an older lesson hash; the sixth-row critic requires non-author replay before treating its evidence rule as complete. |
| **C2 — pinned Node environment matrix** | **In progress, not accepted.** The single-row PATH flip is reproduced; the full run is at **338/350 PASS lines, 0 FAIL lines**, still running. | Runbooks exist and fixture code is unchanged, but no complete r105 `verdicts.json` is in the report tree at this frame. |
| **C3 — P/C precedence package** | **Proposal assembled; no ruling and no required r105 reviews.** Two proposals disagree; the conditional impact/amendment package is present. | The PC directory contains seven Markdown files, but **0 `review-*.md`**; README and cards remain unchanged. |

Frame command: `date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD; git status --short; git diff --name-only HEAD -- corpus/fixtures; git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` → `20:37:39Z`; HEAD `1eaa568…`; status `M SKILL.md`, `M adaptation-kimi.md`, untracked `corpus/fixtures/PINNED-ENV.md`, `corpus/lessons/r105-unreal-lifecycle.md`, `reports/round-105/`; both code/pinned-subtree diff lists empty. A later measurement at `20:40:36Z` found the lesson at 162 lines / 10,154 bytes, SHA-256 `d089aae70c0fd251c6c2c9efc7a7c00e28a3c63d792d7a6fef3a92372c0349e6`.

## 1. C1 — coverage moved, but the lesson boundary needs a fresh ruling

### Lifecycle lesson

`wc -l -c corpus/lessons/r105-unreal-lifecycle.md` → `162 10154`. `grep -nE '^### [0-9]+\.|^## Next-iteration hooks' …` observed lifecycle sections for r101 pinning/vendoring, r102 gate placement, r102–r103 hardening, r102–r104 repairs, and six next-iteration hooks. The current final hook keeps the P/C collision open and refuses authority to edit byte-pinned content. The lesson itself disclaims a new Unreal-runtime claim.

**Scope counter-evidence:** `sed -n '31,45p' PROVINCE.md` prints `Refuses: … harness/evidence auditing (harness-integrity, gate-evidence, rlm-dispatch)…`. `reports/round-105/lesson/bleed.md` reports **FAIL** because the lesson's main subject is gate/evidence auditing. However, that report stamps the lesson as `dd9b9ac…`, **155 lines**; `sha256sum` and `wc -l -c` now report `d089aae…`, **162 lines**. The lesson changed after the bleed pass, so the negative boundary review is a serious finding but not yet a final-hash review. Re-run it against `d089aae…`; do not claim C1 is scope-clean meanwhile.

### Kimi URL fold

Commands run: `curl -sIL --max-time 20 -o /dev/null -w 'bare=%{http_code}…' <bare-url>`; same for the `-plugin` URL; `git ls-remote <plugin-url> refs/heads/main`; `git diff --unified=0 -- corpus/knowledge/unreal-mcp/adaptation-kimi.md`.

Observed: bare repo `404`; `-plugin` repo `200`; `main` still resolves to `a6aa73ada02a9fb1f5415bec491f9942c519b297`; diff is exactly one line changing only `adaptation-kimi.md:6` to the working repo URL. The dated 404 evidence remains historical. Current file SHA-256 is `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`.

### SKILL sixth row

`grep -nE '^\| \*\*[A-F]\*\*' SKILL.md` → six rows A–F. Row F is **Lane fixture runtime result**; the command sequence also reported `rows=6`, `fixture-runtime=4`. Current `SKILL.md` SHA-256 at `20:40:36Z` is `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608` (the file advanced during the round).

`reports/round-105/skill6/critic.md` recommends **revise unless named non-author replay is mandatory**: it says an author-produced fixture battery is not an independent oracle for fixture assertions and asks for a named verifier, exact replay, target/runtime digests, and its own durable report. The sixth row currently cites the r104 author's receipt. Treat the row as landed, not independently accepted; no SHONEN promotion follows from it.

## 2. C2 — the Node marker flip is proved; full acceptance is not yet proved

**Pinned environment:** `node --version; command -v node; PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; node --version` → default `v26.12.0` from mise; prefixed `v24.21.0`; default still `v26.12.0` after the scoped command. `sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (350 CASES).

**A/B row actually run by this seat:**

```sh
python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs /dev/shm/r105-seat30-default
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs /dev/shm/r105-seat30-node24
```

Observed first command: `FAIL r94_cannon_nan`, exit 0 vs expected 0, `exact stdout marker missing`; receipt under `/dev/shm/r105-seat30-default/…`. Second: `PASS r94_cannon_nan`, receipt under `/dev/shm/r105-seat30-node24/…`. This confirms PATH shadowing for one row, not a 350-row pass. Another default run at `20:37Z` reproduced the same FAIL.

**Full r105 run, still in flight at the declared frame:** sibling command observed in `ps`: `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py`, stdout redirected to `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout`. `grep -c '^PASS ' <stdout>` → **338**; `grep -c '^FAIL ' <stdout>` → **0**; `ps …` still showed the battery process. A recursive count found **0 `verdicts.json` receipts** under `reports/round-105/n24/` at that frame. Therefore 350/350, `seeds_unchanged`, and the final receipt are **not yet observed**.

`corpus/fixtures/PINNED-ENV.md` and `reports/round-105/n24/runbook.md` are present. `git diff --name-only HEAD -- corpus/fixtures/*.gd corpus/fixtures/*.py` and `git status --short -- .mise.toml mise.toml .tool-versions` both emitted no paths; the only fixture-scope addition observed is the explicitly allowed `PINNED-ENV.md` documentation. The scoped PATH invocation leaves default Node at v26.12.0; the runbook says the override is process-scoped. Completion still requires a fresh 350/350 run, durable final receipt(s), seeds unchanged, and the runbook/receipt pair to disclose both profiles. Do not alter fixture markers or global Node configuration.

## 3. C3 — real disagreement, proposed diffs, no adjudication

The two r105 analyses do not agree on the threshold:

- `reports/round-105/pc/analyst-1.md` argues policy-first for a runtime capability claim whenever an editor is required and no observation exists, whether or not a concrete path is identified.
- `analyst-2.md` argues card-first: a whole card remains `static-only` when its evidence is static and the path is unidentified; runtime behavior stays binary `unproven`, with `unproven-runtime` reserved for an identified path.

`reports/round-105/pc/ruling-draft.md` and the updated `pc/distiller.md` preserve both branches, have conditional impact diffs, and define a review/amendment contract. The current distiller explicitly declines to choose P or C until reviewers assess one shared proposal/diff hash. That is the correct current boundary: this is proposed for the operator, never applied. `git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability` → empty; the pinned upstream and manifest diff list is also empty.

Independent-review count command:

```sh
python3 - <<'PY'
from pathlib import Path
p=Path('reports/round-105/pc')
print('pc_files='+','.join(sorted(x.name for x in p.glob('*.md'))))
print('r105_review_count='+str(len(list(p.glob('review-*.md')))))
PY
```

Observed at `20:40:36Z`: seven packet files (`analyst-1.md`, `analyst-2.md`, `cards.md`, `distiller.md`, `history.md`, `ledger.md`, `ruling-draft.md`); **`r105_review_count=0`**. The three r104 skill reviews cited by the draft are historical context, not three reviews of the same r105 proposal/diff. The amendment set is therefore provisional; the six dissenting cards, README, and P/C rule must remain untouched pending operator decision and required review.

## 4. Axes and blockers for the next frame

- **Coverage:** the lifecycle lesson, Kimi URL repair, fixture runbook, and SKILL row F are visible. The lesson's out-of-province finding needs a fresh-hash review; row F still lacks the critic's requested named non-author replay.
- **Depth:** the default-vs-v24 marker flip is independently reproduced; the full run is 338/350 PASS and still active, so no matrix acceptance verdict yet.
- **Calibration:** C3 is accurately framed as open with conflicting P/C proposals and an unapplied amendment plan; 0/3 independent r105 reviews are present.
- **Hard boundary:** no Unreal Editor/runtime behavior was tested. No fixture code or byte-pinned upstream/manifest file changed in the measured tree; this seat wrote only this report.

**Recheck before round close:** full-battery final count/receipt under Node 24.21.0; current lifecycle-lesson hash and province review; SKILL row F's non-author replay; three independent reviews against one P/C proposal hash. Do not turn any in-flight count into a passed check.
