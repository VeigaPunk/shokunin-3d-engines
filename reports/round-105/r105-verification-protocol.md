# r105 close-out verification protocol

**Seat:** SEAT-39 VERIFIER-CHAIR · lane `game-dev-3d-shokunin`  
**Owned path:** this file only.  
**Axes:** coverage / depth / calibration.  
**Written against:** worktree `HEAD=1eaa568`; this is a protocol, not a close verdict. Run the ordered checks below against the final bytes after all writers stop. Any missing artifact, stale review hash, wrong output, or unrun step is **not passed**. A dispatched reviewer is still part of the lane; only the operator may make the lane-promotion decision.

## 0. State at protocol-write time — observations, not acceptance

Commands and observations from this host:

- `git rev-parse --short HEAD` → `1eaa568`. `git status --short` → `M SKILL.md`; `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`; `?? corpus/fixtures/PINNED-ENV.md`; `?? corpus/lessons/r105-unreal-lifecycle.md`; `?? reports/round-105/`. Work is in progress, not clean/frozen.
- `sha256sum SKILL.md corpus/lessons/r105-unreal-lifecycle.md corpus/fixtures/run_battery.py` → `0a66412401992efd1edad33a52f7d5e1ea18faece0568ccb4feb8db78f16b738`; `d089aae70c0fd251c6c2c9efc7a7c00e28a3c63d792d7a6fef3a92372c0349e6`; `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` respectively. An earlier lesson scope review (`reports/round-105/lesson/bleed.md`) is **FAIL** for out-of-province evidence/gate-audit content and names old lesson SHA `dd9b9ac0…`; the lesson is now 162 lines at `d089aae7…`. That review is stale and its finding is unresolved: rerun it on final lesson bytes, do not count lexical zero-hits as a pass.
- `node --version; command -v node; PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH node --version; PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH command -v node` → default `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`; prefixed `v24.21.0` at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`.
- Python AST check of `corpus/fixtures/run_battery.py` → `CASES=350`, SHA `f456bd00…1ef69f`. JSON re-read command on `corpus/live/runs/20261018T202715395926Z/verdicts.json` and `/tmp/r105-seat12-default-node-20261018/20261018T203000723964Z/verdicts.json` → `r94_cannon_nan PASS` (1/1) under the pinned profile; `r94_cannon_nan FAIL`, exit `0/0`, `exact stdout marker missing` under default Node. This is one case per receipt, **not** a full run.
- `curl -sIL --max-time 20 -o /dev/null -w '%{http_code} %{url_effective}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code` and the same command for `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` → `404 https://github.com/EpicGames/unreal-engine-skills-for-claude-code`; `200 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`.
- `GATE_WORKDIR=$HOME/.cache/r105-verifier-gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → four `STEP=PASS`, `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`, `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CARDS=13 EXPECTED=13 BAD=0`, `UNRESOLVED=0`, `POINTERS=103`, `GATE RESULT: PASS (checks failed: 0)`, exit `0`. `Grep` of the active `Expected output — pinned summary` in `gate/README.md` returned `POINTERS=103` and the table's `103 / 41`. This is the current live/pin match, not a substitute for the final rerun.
- `ls reports/round-105/pc` → `analyst-1.md`, `analyst-2.md`, `cards.md`, `distiller.md`, `history.md`, `ledger.md`; no `review-*.md` appeared in the current inventory. Analyses, proposed impact diff/ruling/amendments exist in the package, but its three independent r105 reviews are **not evidenced yet**. The distiller's cited r104 reviews do not satisfy this round's three-review requirement.
- `ls reports/round-105/n24` → `adversary.md`, `pre-state.md`, `revert.md`, `runbook.md`, `single-confirm.md`, and `runs/`. The runbook itself says it did not run the full battery. A `ps` snapshot found a full `python3 corpus/fixtures/run_battery.py` process still active; until its terminal result and `verdicts.json` exist, 350/350 is unverified.
- `git status --porcelain -- reports/round-101 reports/round-102 reports/round-103 reports/round-104 LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` printed only `?? corpus/fixtures/PINNED-ENV.md`. That doc is the declared SEAT-11 exception; fixture code and byte-pinned upstream/manifest paths were clean at this snapshot. Recheck at close.

### Post-write recheck — 2026-10-18

- The existing Node 24 rerun (PID `2029609`) terminated. `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout` (SHA-256 `f80d61001c51e1380ddfdeb66b530bc805c2e5960406f49fe5e87e2934839286`) has 704 lines and ends `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0` and `PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T204240718894Z/verdicts.json`. The receipt SHA-256 is `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`; parsed verdict `PASS`, `seeds_unchanged=True`. Against the r104 baseline: 350 cases, `337/337` prior passes retained, `13/13` former failures fixed, equal case sets, and runner SHA remains `f456bd00…1ef69f`. Baseline/fresh seed maps differ only by added `PINNED-ENV.md` (130→131 entries); no removals or changed common digests. Its receipt and current SHA both equal `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f`, and fixture status still shows only this allowed untracked doc. The runner returns 0 for a PASS verdict; the saved stdout itself has no separate `BATTERY_EXIT` line.
- Lesson remains SHA `d089aae70c0fd251c6c2c9efc7a7c00e28a3c63d792d7a6fef3a92372c0349e6`; same-hash `lesson/verify.md` is PARTIAL, `lesson/critic.md` is REVISE, and `lesson/bleed.md` remains FAIL against stale SHA `dd9b9ac0…`. At `2026-10-18T20:57:55Z`, the P/C inventory contained three reviews. Current proposal hashes are ruling `0dc0340a…`, impact `dd5c0e98…`, distiller `a17ce1fe…`. Review 1 binds ruling `0dc0340a…` with old distiller `d337efd2…`; review 2 says REVISE and binds ruling `0dc0340a…`, impact `dd5c0e98…`, and now-old distiller `7c514008…`; review 3 binds old ruling `c0d14e2e…` and distiller `890df366…`. None reviews the current distiller hash; three same-hash reviews are not evidenced. The current distiller text also says `review-2.md` was absent, a stale inventory claim. C1 and C3 remain blocked.

## 1. Freeze and scope guard — run first, on the landed tree

The comparison base is the round's starting HEAD `1eaa568`. Run only after all authors stop and the operator lands the final work; this seat does not commit.

```sh
BASE=1eaa568
git merge-base --is-ancestor "$BASE" HEAD
git rev-parse HEAD
git status --short
git diff --check "$BASE"..HEAD
git diff --name-only "$BASE"..HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md \
  reports/round-101 reports/round-102 reports/round-103 reports/round-104 \
  corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
git diff --name-only "$BASE"..HEAD -- corpus/fixtures
git status --porcelain -- corpus/fixtures
sha256sum SKILL.md corpus/lessons/r105-unreal-lifecycle.md \
  corpus/knowledge/unreal-mcp/adaptation-kimi.md \
  corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  corpus/knowledge/unreal-mcp/gate/README.md corpus/fixtures/run_battery.py
```

**Expected:** the base is an ancestor; final commit SHA is recorded; post-commit status is empty; `git diff --check "$BASE"..HEAD` is silent/exit 0; the protected-path diff is empty. The fixture-path diff may be empty or contain only the SEAT-11-declared doc `corpus/fixtures/PINNED-ENV.md`; status must be empty after it is landed. No fixture code, seed, marker, runner, environment configuration, reports/101–104, ledger, upstream, or manifest mutation is permitted. A new or changed fixture-code path is FAIL. Do not run a command whose output path points into `reports/round-101..104`.

## 2. C1 — lifecycle lesson and evidence rows

Subject under test: `corpus/lessons/r105-unreal-lifecycle.md`. The lesson must have a final-hash-bound, non-author scope/evidence review. Specifically resolve the out-of-province finding in `reports/round-105/lesson/bleed.md`; a hash change alone is not a resolution. Then the reviewer inventories every retained command/result row in the lesson, reruns each command against the stated target and working directory, and records one `PASS` per row with the observed output and target hash. Every row must be green; missing, stale-target, or inferred results fail C1. Keep historical facts explicitly tied to their source rounds; do not present them as current-run results. **Expected close lines:** `LESSON_SHA256=<final hash>`, `LESSON_SCOPE=PASS (same hash)`, `LESSON_ROWS=<N>/<N> PASS`, `LESSON_FAIL=0`. Current state is blocked by the stale-hash scope review above.

## 3. C1 — corrected Kimi upstream URL

```sh
BASE=1eaa568
curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code
curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
git diff --check "$BASE"..HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
git diff --numstat "$BASE"..HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
```

**Expected:** `404`, then `200`; whitespace check silent/exit 0; the authorized locator correction is exactly one insertion and one deletion (`1 1`). The round-105 diff against `BASE` is used because a post-commit worktree diff would be empty. The upstream pin remains `a6aa73ada02a9fb1f5415bec491f9942c519b297`; the URL check does not itself re-prove upstream freshness or runtime behavior.

## 4. C1 — SKILL.md sixth row, then its bounded replay

First hash the final `SKILL.md`; inspect row F (`Lane fixture runtime result`) and its canonical command. It must retain the narrow meaning of `verified-here` (this named receipt only, not an engine-wide claim), bounded-run disclosure, runner/fixture digests, and a non-author replay requirement.

**Path guard:** the row F command at the protocol-write snapshot directs `--runs` to `reports/round-104/physics/author-runs-final`. Do **not** execute it as written: it would write into a protected read-only report tree. The SKILL owner must repoint the command/receipt to an allowed durable location such as `corpus/live/runs`, then update the row's cited receipt. The exact revised row command is what the non-author reruns. No substitute receipt or old r104 result closes this step.

For the current one-case example, the required shape is:

```sh
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
  --runs corpus/live/runs
```

**Expected for that example:** a saved receipt outside reports/101–104; `cases=1 pass=1 fail=0`; `phys3d_joints_free_ops verdict=PASS actual_exit=0 reasons=[]`; `seeds_unchanged=true`; `case_timeout_seconds=20`; matching runner/fixture digests. The verifier records its identity, exact command, final SKILL/runner/fixture hashes, and receipt path. Run only after the row is safe and final; a review that reads the author's receipt is not a rerun.

## 5. C2 — pinned-Node full battery and receipt comparison

The known baseline is the r104 default-profile receipt `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`. A Python parse actually run on that file returned `cases=350`, `PASS=337`, `FAIL=13`, `seeds_unchanged=True`, timeout `20`, runner SHA `f456bd00…1ef69f`; its 13 failures are the positive `r94_cannon_*` marker rows. Do not call the default profile green.

Print and assert the selected binary before the full run; keep the PATH override local to this invocation:

```sh
N24=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
PATH="$N24:$PATH" command -v node
PATH="$N24:$PATH" node --version
sha256sum corpus/fixtures/run_battery.py
python3 - <<'PY'
import ast
from pathlib import Path
p = Path('corpus/fixtures/run_battery.py')
t = ast.parse(p.read_text())
n = next(n for n in t.body if isinstance(n, ast.Assign) and
         any(isinstance(x, ast.Name) and x.id == 'CASES' for x in n.targets))
print('CASES=' + str(len(ast.literal_eval(n.value))))
PY
```

**Expected:** executable path `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`; version `v24.21.0`; runner SHA `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; `CASES=350`.

Run one full battery only; if an existing full run is still active, wait for its exit/receipt rather than launching a duplicate. Capture stdout under r105 and keep the battery's durable JSON/scratch receipt under ignored `corpus/live/runs/`:

```sh
N24=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
mkdir -p reports/round-105/n24/runs
OUT="reports/round-105/n24/runs/node24-full-$(date -u +%Y%m%dT%H%M%SZ).stdout"
set -o pipefail
PATH="$N24:$PATH" python3 corpus/fixtures/run_battery.py \
  --runs corpus/live/runs 2>&1 | tee "$OUT"
rc=${PIPESTATUS[0]}
printf 'BATTERY_EXIT=%s\n' "$rc"
exit "$rc"
```

**Expected:** `totals: cases=350 pass=350 fail=0 ... probes=0`, `PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/<stamp>/verdicts.json`, `BATTERY_EXIT=0`. Keep the stdout, `verdicts.json`, and the receipt's `scratch/` directory; report the actual receipt path. The r105 runbook (`reports/round-105/n24/runbook.md`) and fixture-side note (`corpus/fixtures/PINNED-ENV.md`) must document the command-scoped PATH, executable/version preflight, default-vs-pinned distinction, how to locate receipts, and must not claim 350/350 before this receipt exists.

Set `FRESH` to the exact path printed by `PASS battery`, then compare it to the named r104 baseline:

```sh
FRESH='corpus/live/runs/REPLACE-WITH-PRINTED-STAMP/verdicts.json'
python3 - reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json "$FRESH" <<'PY'
import hashlib, json, sys
from collections import Counter
from pathlib import Path
b, n = (json.load(open(p)) for p in sys.argv[1:])
br, nr = b['results'], n['results']
bm, nm = {r['case']: r for r in br}, {r['case']: r for r in nr}
old_fail = {k for k, r in bm.items() if r['verdict'] != 'PASS'}
kept = sum(r['verdict'] == 'PASS' and nm.get(k, {}).get('verdict') == 'PASS'
           for k, r in bm.items())
added = set(n['seed_digests']) - set(b['seed_digests'])
removed = set(b['seed_digests']) - set(n['seed_digests'])
changed = {k for k in set(b['seed_digests']) & set(n['seed_digests'])
           if b['seed_digests'][k] != n['seed_digests'][k]}
pin_sha = hashlib.sha256(Path('corpus/fixtures/PINNED-ENV.md').read_bytes()).hexdigest()
print('baseline_cases=%d baseline_PASS=%d baseline_FAIL=%d' %
      (len(br), Counter(r['verdict'] for r in br)['PASS'], len(old_fail)))
print('pinned_cases=%d pinned_PASS=%d pinned_FAIL=%d' %
      (len(nr), Counter(r['verdict'] for r in nr)['PASS'],
       sum(r['verdict'] != 'PASS' for r in nr)))
print('case_set_equal=%s prior_PASS_preserved=%d/%d former_failures_fixed=%d/%d' %
      (set(bm) == set(nm), kept, len(br) - len(old_fail),
       sum(nm.get(k, {}).get('verdict') == 'PASS' for k in old_fail), len(old_fail)))
print('seed_map_added=%s removed=%s changed=%s pinned_env_matches=%s ' %
      (sorted(added), sorted(removed), sorted(changed),
       n['seed_digests'].get('PINNED-ENV.md') == pin_sha) +
      'seeds_unchanged=%s runner_sha=%s' %
      (n['seeds_unchanged'], n['seed_digests'].get('run_battery.py')))
assert len(br) == len(nr) == 350 and set(bm) == set(nm)
assert len(old_fail) == 13 and all(k.startswith('r94_cannon_') for k in old_fail)
assert all(bm[k]['expected_exit'] == 0 for k in old_fail)
assert all(r['verdict'] == 'PASS' for r in nr)
assert kept == 337 and all(nm[k]['verdict'] == 'PASS' for k in old_fail)
assert added == {'PINNED-ENV.md'} and not removed and not changed
assert n['seed_digests']['PINNED-ENV.md'] == pin_sha and n['seeds_unchanged'] is True
assert n['seed_digests']['run_battery.py'] == 'f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f'
print('RECEIPT_COMPARISON=PASS')
PY
```

**Expected:** baseline `350/337/13`; pinned run `350/350/0`; same 350-case set; all 337 baseline passes retained; all 13 prior failures fixed; every baseline seed digest preserved; the only map addition is `PINNED-ENV.md`, whose receipt digest matches the current file; no removals or changed common paths; `seeds_unchanged=True`; unchanged runner SHA; `RECEIPT_COMPARISON=PASS`. This allows only the declared SEAT-11 documentation exception against the pre-doc r104 baseline. A partial run, `--only` receipt, author transcript without JSON, any other seed-map delta, or missing durable receipt is FAIL. Confirm the `BASE..HEAD` fixture diff from step 1 contains no code/seed changes. No persistent PATH/configuration changes are permitted.

## 6. C2/C1 — rerun gate and compare its live pointer count to the active pin

Run on final bytes with roomy cache scratch, not `/tmp`:

```sh
WORK=$(mktemp -d "$HOME/.cache/r105-gate.XXXXXX")
mkdir -p "$WORK/gate"
GATE_WORKDIR="$WORK/gate" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | tee "$WORK/gate.stdout"
gate_rc=${PIPESTATUS[0]}
printf 'GATE_RC=%s\n' "$gate_rc"
python3 - "$WORK/gate.stdout" "$gate_rc" <<'PY'
import re, sys
from pathlib import Path
readme = Path('corpus/knowledge/unreal-mcp/gate/README.md').read_text()
section = readme.split('## Expected output — pinned summary', 1)[1]
pin = re.search(r'^POINTERS=(\d+)\b', section, re.M).group(1)
out = Path(sys.argv[1]).read_text()
live = re.search(r'^POINTERS=(\d+)\b', out, re.M).group(1)
unresolved = re.search(r'UNRESOLVED=(\d+)', out).group(1)
result = re.search(r'^GATE RESULT: (.+)$', out, re.M).group(1)
print(f'README_POINTERS_PIN={pin} GATE_POINTERS_LIVE={live} ' +
      f'POINTERS_PIN_MATCH={pin == live} UNRESOLVED={unresolved} ' +
      f'GATE_RESULT={result} GATE_RC={sys.argv[2]}')
assert pin == live and unresolved == '0' and result.startswith('PASS') and sys.argv[2] == '0'
PY
```

**Expected on the current measured tree:** README pin `103`, live `103`, match `True`, `UNRESOLVED=0`, four `STEP=PASS`, `GATE RESULT: PASS (checks failed: 0)`, `GATE_RC=0`. The pin is scanner/tree-relative: if SEAT-10 updates the active README pin, the final rerun's live number must equal that newly active pin; do not hard-code 103 as an eternal invariant.

## 7. C3 — P/C precedence proposal package, still unapplied

Inspect the package index/inventory and verify all five deliverable classes: (1) analyses of both P and C; (2) impact diff for both alternatives; (3) an explicit ruling proposal to the operator; (4) **three independent r105 reviews**; and (5) a distilled amendment set that maps each amendment to a branch and records dissent. Each reviewer must be distinct from the package authors, review the same proposal/diff SHA, state accept/revise with reasons, and leave a durable report. Inherited r104 reviews quoted by `distiller.md` do not count as r105 reviews.

```sh
BASE=1eaa568
find reports/round-105/pc -maxdepth 1 -type f -name 'review-*.md' -print | sort
git diff --quiet "$BASE"..HEAD -- corpus/knowledge/unreal-mcp/upstream \
  corpus/knowledge/unreal-mcp/.manifest.d \
  corpus/knowledge/unreal-mcp/README.md \
  corpus/knowledge/unreal-mcp/executability
```

**Expected:** exactly three review paths with matching proposal hash and three distinct non-author identities; the `git diff --quiet` command exits `0` with no output, proving the committed round introduced no P/C change to those sources. The package remains **PROPOSED**, not an adopted policy: no P/C amendment is applied to the byte-pinned upstream or manifest, no card relabel/README policy edit is implied, and no dispatched seat marks SHONEN box 1. If the operator has not ruled, retain the open state and report it as pending—not landed.

## Close verdict rule

C1 is green only after the lesson's final-hash-bound scope review and every retained lesson command row passes, the corrected URL is 200, and a safe non-author replay of the sixth row has a durable receipt. C2 is green only after a complete, compared Node 24.21.0 receipt proves 350/350, the runbook is complete, and fixture code/environment configuration remain unchanged. C3 is complete only as a reviewed proposal package with three independent same-version reviews and no application to pinned bytes. Report each claim separately; no average or gate PASS can hide a blocked claim. No Unreal Editor/runtime result is asserted by this protocol.
