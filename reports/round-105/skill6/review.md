# SEAT-07 — sixth-row review

Axes: depth, coverage, calibration.

## Verdict

**Receipt-less `verified-here`: NOT admissible under row F.** The label cell requires a saved, bounded host execution; the evidence cell requires a saved `verdicts.json` and names its path, scope, timeout, invocation, and runner/fixture digests. The §3 F checklist repeats the saved-receipt requirement. This is a textual rule, not an automated prose validator; no such validator was tested.

| Row F cell | Verdict | Review |
|---|---|---|
| Claim type | PASS | “Lane fixture runtime result” and “named battery row” scope the claim to a particular fixture case. |
| Permissible label | PASS | `verified-here` is conditional on a saved bounded run and explicitly does not prove an engine generally or promote its census row. A receipt-less label contradicts this condition. |
| Required evidence | REVISE | It names the row's PASS/exit/reasons, receipt, command, scope, timeout and seed digests, but omits explicit `verdicts.json` top-level `verdict=PASS` and `seeds_unchanged=true`. The runner can emit a row-level PASS while its overall receipt is FAIL if the seed-integrity check fails; require both top-level fields. |
| Canonical command | REVISE / literal rerun blocked | The example writes under protected `reports/round-104/**`, which this round forbids modifying. I reran the same `--only phys3d_joints_free_ops` case with only `--runs` redirected to a temporary directory; the case passed. The example should use a current-round output path or be presented as a historical receipt, not a re-runnable command into frozen reports. |
| Justified by | PASS | The cited historical receipt exists and its SHA matches the §6 stamp; its runner and fixture digests match the current files. The cited report sections provide the scope/bound context. |

## Commands run and observed output

1. Row command rerun with a safe temporary output root:

```sh
RUNS=$(mktemp -d /tmp/r105-seat07-skill6.XXXXXX) && printf 'RUNS=%s\n' "$RUNS" && python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs "$RUNS"
```

Observed: `RUNS=/tmp/r105-seat07-skill6.58nWkU`; `PASS phys3d_joints_free_ops: exit=0 expected=0`; totals `cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0`; `PASS battery: /tmp/r105-seat07-skill6.58nWkU/20261018T203532196657Z/verdicts.json`. The temporary receipt was inspected, then removed with `rm -r -- /tmp/r105-seat07-skill6.58nWkU` → `removed temporary receipt directory`.

2. Receipt inspection command (both the row's historical receipt and the temporary rerun receipt):

```sh
python3 - <<'PY'
import json
paths = [
    'reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json',
    '/tmp/r105-seat07-skill6.58nWkU/20261018T203532196657Z/verdicts.json',
]
for path in paths:
    d = json.load(open(path))
    r = next(row for row in d['results'] if row['case'] == 'phys3d_joints_free_ops')
    print('RECEIPT=' + path)
    print('TOTALS=' + str(d['totals']) + ' ONLY=' + str(d['only']) + ' TIMEOUT=' + str(d['case_timeout_seconds']))
    print('ROW=' + str({k: r[k] for k in ('case','verdict','actual_exit','reasons','elapsed_seconds')}))
    print('SEEDS_UNCHANGED=' + str(d['seeds_unchanged']))
    print('RUNNER_SHA=' + d['seed_digests']['run_battery.py'])
    print('FIXTURE_SHA=' + d['seed_digests']['phys3d_joints.gd'])
    print('GODOT=' + str(d['godot']) + ' VERSION=' + str(d['godot_version']))
    print('ROW_COMMAND=' + ' '.join(r['command']))
PY
```

Observed for both receipts: `cases=1 pass=1 fail=0`, `ONLY=phys3d_joints_free_ops`, `TIMEOUT=20`, row `PASS`, exit `0`, `reasons=[]`, `SEEDS_UNCHANGED=True`, Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Runner SHA `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; fixture SHA `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`.

3. File/receipt digest command:

```sh
sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json
```

Observed: the three digests match the values above and the receipt stamp `17b037d5154b7cf51a55df197a142f09ce3ea0fb9b4471f75a74a028f508397c`.

4. Read-only policy/runner inspection command:

```sh
python3 - <<'PY'
from pathlib import Path
p = Path('SKILL.md')
for line in p.read_text().splitlines():
    if line.startswith('| **F**'):
        print('ROW_F=' + line)
text = Path('corpus/fixtures/run_battery.py').read_text().splitlines()
for start, end in ((1343, 1348), (1366, 1383)):
    print(f'RUNNER_LINES_{start}_{end}=')
    for i in range(start - 1, end):
        print(f'{i+1}: {text[i]}')
PY
sha256sum SKILL.md && git status --short -- reports/round-104 corpus/fixtures
```

Observed `ROW_F=` requires a saved bounded execution and saved `verdicts.json`; `RUNNER_LINES_1366_1383` shows the aggregate receipt verdict is `PASS` only if `failed == 0`, `seeds_unchanged`, each probe check, and any mutation probe pass. The receipt stores `seeds_unchanged` and top-level `verdict`, which row F does not explicitly require. `sha256sum SKILL.md` → `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608`.

Reviewed `SKILL.md` §1 row F at SHA-256 `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608`.