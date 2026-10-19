# r108 seat output — planner (agent W2RoundGameDev3d.R108Planner-5)

## Planner observations

- At base `7c4e589`, all three SCORECARD rows are `unscored`; the capability row is empty, saturation is a placeholder, and the four requested verdict blocks are absent (`SCORECARD.md:3–10, 275–285`; base snapshot inspection: `scorecard_unscored_rows=3`, `capability_empty=True`, `saturation_undeclared=True`, verdict blocks absent). `git cat-file -e 7c4e589:corpus/QUALITY.md` and the equivalent check for `corpus/SOURCES.md` both returned 128.
- Historical outcomes: r90 verifier **REJECT** on `191f131`; the repair at `6420dc7` was still held for adjudication (`reports/round-90/r90-repair.md:77–82`). r91 has an author-run 235/235 but no verifier in the base tree (`reports/round-91/r91-author.md:68–80`; base `cat-file` check absent). r99 was **ADMIT-with-findings**; r100 was **ADMIT-with-findings on successor `523c943`**, not on `8183191` alone.
- Proposed axes are the L1-declared set: C1 calibration, C2 coverage, C3 depth. Calibration is the lowest base axis: it has no numeric score or formal quality/saturation/capability records.
- The committed r90/91/99/100 records do not allocate their overall verdicts to individual axes. The draft below preserves the overall dispositions and leaves per-axis attribution unassigned rather than inferring it.

## Ordered steps and evidence

1. Set the base scores using the proposed evidence-quality anchors below; do not use case totals alone as scores (`SCORECARD.md:3–4`; `AXES.md:75–83`).
2. Declare the saturation line and stagnation window (`AXES.md:66–73`).
3. Add retroactive records for r90/r91/r99/r100 with the observed overall outcome and no unsupported axis split (reports cited below; base `cat-file` checks confirm absent r90 adjudicator and r91 verifier/adjudicator).
4. Only enter a capability row after its command is run and the cited pass output is recorded (`AXES.md:57–64`).

## Paste-ready SCORECARD draft

### 1. Proposed rubric

- **Depth:** 0 = no independently replayed mechanism; 5 = a source-backed measured behavior with a falsifier and non-author replay; 8 = multiple measured mechanisms with falsifiers, re-derivation and explicit limits; 10 = this evidence covers all mapped core/frontier behaviors across declared environments. Check CASES and committed verifier reports.
- **Coverage:** 0 = no inventory; 5 = at least five evidenced engine/artifact families with runtime vs. static status distinguished; 8 = Core/Frontier/Adjacent surfaces map to evidence or explicit gaps; 10 = every province surface has evidence or a reasoned frontier entry. Check `engines.md`, `PROVINCE.md`, `README.md`, and `SOURCES.md`.
- **Calibration:** 0 = no scored rubric or quality bar; 5 = evidence-backed scores and explicit misses; 8 = lesson-linked criteria with rechecks, saturation/window and a demonstrated capability; 10 = historical rejects and unknowns remain accurate and all admissions are independently adjudicated. Check `SCORECARD.md`, `QUALITY.md`, and reports.
- Use the highest fully met anchor (0/5/8/10); do not interpolate or treat row counts alone as a score.

### 2. Proposed base scores — before round 108

- **Depth — 8/10.** Multiple measured behaviors have falsifiers, independent re-derivation and scoped findings (`reports/round-99/r99-verifier.md:3–11, 49–53`; `reports/round-100/r100-adjudicator.md:12–18, 34–36`). The count is supporting inventory, not the score by itself.  
  Counting command: `git -C /home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/game-dev-3d-shokunin show 7c4e589:corpus/fixtures/run_battery.py | python3 -c 'import ast,sys; m=ast.parse(sys.stdin.read()); a=next(n for n in m.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=="CASES" for t in n.targets)); xs=a.value.elts; print(f"CASES={len(xs)} ordinary={sum(x.elts[3].value==0 for x in xs)} negative_controls={sum(x.elts[3].value==2 for x in xs)} distinct_scripts={len({x.elts[1].value for x in xs})}")'`  
  Output: `CASES=350 ordinary=291 negative_controls=59 distinct_scripts=53`.

- **Coverage — 5/10.** The base engine census has five evidenced rows, but execution is not demonstrated uniformly and several in-province surfaces remain static, partial, or unproven (`corpus/knowledge/engines.md:40–48`; `PROVINCE.md:14–22`).  
  Counting command: `git -C /home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/game-dev-3d-shokunin show 7c4e589:corpus/knowledge/engines.md | grep -cE '^\| (Godot|Unity|Unreal Engine|three\.js|Blender)'`  
  Output: `5`.

- **Calibration — 0/10.** Three score rows are unscored; the capability row is empty and saturation undeclared (`SCORECARD.md:3–10, 275–285`). `corpus/QUALITY.md` is absent at base (the base `git cat-file -e` check returned 128). Base snapshot inspection also found no r90/r91/r99/r100 SCORECARD verdict blocks.

### 3. Saturation and stagnation

- **Saturation line: 8/10** — high enough to reserve headroom for the lane’s recorded engine/build limits and unprobed frontier (`PROVINCE.md:14–22`).
- **Stagnation window N = 3 rounds** without a capability entering the table — tolerates a short gap while making repeated lack of capability growth trigger the AXES nudge (`AXES.md:66–73`).

### 4. Retroactive verdict blocks

#### Round 90 verdict — retroactive r108 record; not a pass

Overall disposition: **REJECT**. The repair commit does not supersede that verdict: its report says the repair was held for adjudication, and no r90 adjudicator is present at base (`reports/round-90/r90-repair.md:77–82`; base `git cat-file` check absent).

| axis | verdict | evidence |
|---|---|---|
| depth | unassigned | The verifier gives a round-level rejection, not a per-axis ruling: `reports/round-90/r90-verifier.md:101–107`, on `191f131`; repair `6420dc7` remains held for adjudication. |
| coverage | unassigned | Same round-level-only evidence: `reports/round-90/r90-verifier.md:101–107`, `191f131`; no adjudicator at base. |
| calibration | unassigned | Same round-level-only evidence: `reports/round-90/r90-verifier.md:101–107`, `191f131`; no adjudicator at base. |

#### Round 91 verdict — retroactive r108 record; not a pass

Overall disposition: **unverified**. The author reports 235/235, but the base tree contains no verifier or adjudicator for r91 (`reports/round-91/r91-author.md:68–80`; base `git cat-file` checks absent).

| axis | verdict | evidence |
|---|---|---|
| depth | unverified | Author-only report and no verifier: `reports/round-91/r91-author.md:68–80, 125–127`; salvage commit `b6ba234`. |
| coverage | unverified | Author-only report and no verifier: `reports/round-91/r91-author.md:68–80, 125–127`; salvage commit `b6ba234`. |
| calibration | unverified | Author-only report and no verifier: `reports/round-91/r91-author.md:68–80, 125–127`; salvage commit `b6ba234`. |

#### Round 99 verdict — retroactive r108 record; not a fresh pass

Overall disposition: **ADMIT-with-findings** on `f1ff626`. The adjudicator records the findings; it does not provide an owned-axis breakdown (`reports/round-99/r99-adjudicator.md:3–8, 14–18, 26–28`; adjudication commit `c28783a`).

| axis | verdict | evidence |
|---|---|---|
| depth | unassigned | The committed adjudicator gives an overall disposition only: `reports/round-99/r99-adjudicator.md:3–8, 26–28`; author commit `f1ff626`, adjudication commit `c28783a`. |
| coverage | unassigned | The committed adjudicator gives an overall disposition only: `reports/round-99/r99-adjudicator.md:3–8, 26–28`; author commit `f1ff626`, adjudication commit `c28783a`. |
| calibration | unassigned | The committed adjudicator gives an overall disposition only: `reports/round-99/r99-adjudicator.md:3–8, 26–28`; author commit `f1ff626`, adjudication commit `c28783a`. |

#### Round 100 verdict — retroactive r108 record; not a fresh pass

Overall disposition: **ADMIT-with-findings on successor `523c943`**, not on incomplete landing `8183191` alone (`reports/round-100/r100-adjudicator.md:3–18, 34–36, 67–69`; adjudication commit `78fa0f6`).

| axis | verdict | evidence |
|---|---|---|
| depth | unassigned | The adjudicator records an overall successor disposition, not an owned-axis breakdown: `reports/round-100/r100-adjudicator.md:3–18, 34–36`; successor `523c943`, adjudication commit `78fa0f6`. |
| coverage | unassigned | The adjudicator records an overall successor disposition, not an owned-axis breakdown: `reports/round-100/r100-adjudicator.md:3–18, 34–36`; successor `523c943`, adjudication commit `78fa0f6`. |
| calibration | unassigned | The adjudicator records an overall successor disposition, not an owned-axis breakdown: `reports/round-100/r100-adjudicator.md:3–18, 34–36`; successor `523c943`, adjudication commit `78fa0f6`. |

### 5. Capability candidates for this round

These are proposed demonstrations, not observed results; do not add a capability row until the command is actually run and its result recorded.

- **Unreal static-tree gate:** from the lane root, `GATE_WORKDIR="${XDG_RUNTIME_DIR:?}" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → expected `GATE RESULT: PASS (checks failed: 0)`, exit 0 (`corpus/knowledge/unreal-mcp/gate/run_gate.sh:440–442`; previous committed demonstration in `SCORECARD.md:301`). It needs the fresh-clone network check unless an existing `GATE_REF` is supplied.
- **Pinned-environment full battery:** `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --runs "${XDG_RUNTIME_DIR:?}/g3d-r108-pinned"` → expected final line `PASS battery: <XDG_RUNTIME_DIR>/g3d-r108-pinned/<UTC-stamp>/verdicts.json`; preceding totals must have `pass=cases` and `fail=0` (`PINNED-ENV.md:5–9`; `run_battery.py:1227–1243, 1362–1383`). The post-round case count is intentionally not fixed here.
- **Source-registry census:** the frozen contract’s malformed-row command, `awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ && NF!=13 {n++} END{print n+0}' corpus/SOURCES.md`, should print `0`; duplicate-ID, enum/tier, and mined-path checks should print nothing (`SOURCES-CONTRACT-v1.md:64–80`). The contract has no aggregate PASS line, so this is not a standalone capability receipt unless all census checks and their outputs are recorded.

### Hard blockers

No blocker to drafting. Per-axis historical verdict attribution is absent from the committed r90/91/99/100 records, and none of the proposed capability commands was executed in this read-only assignment.
