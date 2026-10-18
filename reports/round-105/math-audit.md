# r105 SEAT-32 MATH-AUDIT

**Axes:** depth / coverage / calibration. **Owned path:** this file only.

I independently re-derived numeric claims from nine distinct r105 artifacts (and the r104 receipt used as a historical source). Each verdict below is tied to a command I ran and the output observed; no value was copied from an author transcript as the sole evidence.

## Recount commands and observed output

**C1 — parse the runner's literal case table:**

```sh
python3 - <<'PY'
import ast
from pathlib import Path
src=Path('corpus/fixtures/run_battery.py').read_text()
tree=ast.parse(src)
cases=next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=='CASES' for x in n.targets))
cannon=[x for x in cases if x[0].startswith('r94_cannon_')]
print(f'CASES={len(cases)} UNIQUE={len({x[0] for x in cases})}')
print(f'CANNON={len(cannon)} PINNED_MARKERS={sum("node=v24.21.0" in x[4] for x in cannon)} POSITIVE={sum(x[3]==0 for x in cannon)} NEGATIVE={sum(x[3]==2 for x in cannon)}')
print('MARKER_VERSIONS='+','.join(sorted({v for x in cannon for v in x[4].split() if v.startswith('node=v')})))
PY
```

Observed:

```text
CASES=350 UNIQUE=350
CANNON=19 PINNED_MARKERS=13 POSITIVE=13 NEGATIVE=6
MARKER_VERSIONS=node=v24.21.0
```

**C2 — parse the stored r104 full-regression receipt:**

```sh
python3 - <<'PY'
import json
p='reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json'
d=json.load(open(p)); rs=d['results']; print(f'CASES={len(rs)} PASS={sum(r["verdict"]=="PASS" for r in rs)} FAIL={sum(r["verdict"]=="FAIL" for r in rs)} VERDICT={d["verdict"]}')
PY
```

Observed: `CASES=350 PASS=337 FAIL=13 VERDICT=FAIL`.

**C3 — resolve default, explicit pinned, fnm-default, and mise Node versions:**

```sh
printf 'DEFAULT='; node --version; printf 'PINNED='; /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version; printf 'FNM_DEFAULT='; fnm default; printf 'MISE_NODE='; mise ls node
```

Observed:

```text
DEFAULT=v26.12.0
PINNED=v24.21.0
FNM_DEFAULT=v24.21.0
MISE_NODE=node  26.12.0  ~/.config/mise/config.toml  latest
```

**C4 — re-probe both repository URLs:**

```sh
curl -sIL --max-time 20 -o /dev/null -w 'old=%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code
curl -sIL --max-time 20 -o /dev/null -w 'corrected=%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
```

Observed: `old=404` and `corrected=200`.

**C5 — rerun the static gate with temporary scratch under `/tmp`:**

```sh
GATE_WORKDIR=/tmp corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Observed output excerpts:

```text
MANIFEST_FILES=12
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**C6 — recount tracked paths in the protected report trees from HEAD:**

```sh
python3 - <<'PY'
import subprocess
counts=[]
for d in ('reports/round-101','reports/round-102','reports/round-103','reports/round-104'):
 out=subprocess.check_output(['git','ls-tree','-r','--name-only','HEAD','--',d],text=True)
 counts.append((d,sum(bool(x) for x in out.splitlines())))
print(' '.join(f'{d}={n}' for d,n in counts))
print('TOTAL='+str(sum(n for _,n in counts)))
PY
```

Observed: `reports/round-101=33 reports/round-102=61 reports/round-103=61 reports/round-104=21950`; `TOTAL=22105`.

**C7 — recount dissenting cards and labels:**

```sh
python3 - <<'PY'
from pathlib import Path
ps=sorted(Path('corpus/knowledge/unreal-mcp/executability').glob('*.md'))
hits=[p for p in ps if 'Not `unproven-runtime`' in p.read_text()]
print('CARDS',len(ps),'DISSENT',len(hits))
print('DISSENT_NAMES',' '.join(p.stem for p in hits))
print('LABELS',' '.join(next((s.split('`')[1] for s in p.read_text().splitlines() if s.startswith('**Label:**')), 'NO_LABEL') for p in hits))
PY
```

Observed: `CARDS 13 DISSENT 6`; dissent names `animation-controlrig blueprints editor-general gameplay-gas materials meshes-textures`; all six labels were `static-only`.

**C8 — parse the durable single-case Node 24 receipt:**

```sh
python3 - <<'PY'
import json
p='corpus/live/runs/20261018T202715395926Z/verdicts.json'
d=json.load(open(p)); r=d['results']
print(f'CASES={len(r)} PASS={sum(x["verdict"]=="PASS" for x in r)} FAIL={sum(x["verdict"]=="FAIL" for x in r)} VERDICT={d["verdict"]} SEEDS_UNCHANGED={d["seeds_unchanged"]}')
print('ONLY='+str(d['only']))
print('CASE='+r[0]['case']+' node_marker='+next((s.split('node=')[-1].split()[0] for s in r[0]['stdout'] if 'node=' in s),'none'))
PY
```

Observed: `CASES=1 PASS=1 FAIL=0 VERDICT=PASS SEEDS_UNCHANGED=True`; `ONLY=r94_cannon_nan`; `CASE=r94_cannon_nan node_marker=v24.21.0`.

**C9 — verify the completed r105 pinned-profile full run:**

```sh
python3 - <<'PY'
import re
from pathlib import Path
p=Path('reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout')
lines=p.read_text().splitlines(); rows=[s for s in lines if re.match(r'^(PASS|FAIL) \S+: exit=',s)]
print(f'ROWS={len(rows)} PASS={sum(s.startswith("PASS ") for s in rows)} FAIL={sum(s.startswith("FAIL ") for s in rows)}')
print('\n'.join(lines[-2:]))
PY
```

Observed: `ROWS=350 PASS=350 FAIL=0`; `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0`; terminal line `FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T202944290389Z/verdicts.json`.

```sh
python3 - <<'PY'
import json
p='corpus/live/runs/20261018T202944290389Z/verdicts.json'
d=json.load(open(p)); rs=d['results']; t=d['totals']
print('RUN='+d['started_utc']+' VERDICT='+d['verdict'])
print('TOTALS='+str(t))
print('SEEDS_UNCHANGED='+str(d['seeds_unchanged']))
print('GODOT='+d['godot_version']+' EXIT='+str(d['godot_version_exit'])+' ONLY='+str(d['only']))
print('CANNON='+str(sum(x['case'].startswith('r94_cannon_') for x in rs))+' CANNON_FAIL='+str(sum(x['case'].startswith('r94_cannon_') and x['verdict']=='FAIL' for x in rs)))
PY
```

Observed: `RUN=20261018T202944290389Z VERDICT=FAIL`; totals `{cases: 350, pass: 350, fail: 0, ordinary: 291, negative_controls: 59}`; `SEEDS_UNCHANGED=False`; Godot exit `0`; `ONLY=None`; `CANNON=19 CANNON_FAIL=0`.

```sh
python3 - <<'PY'
import json, runpy
receipt=json.load(open('corpus/live/runs/20261018T202944290389Z/verdicts.json'))
current=runpy.run_path('corpus/fixtures/run_battery.py')['seed_digests']()
before=receipt['seed_digests']
added=sorted(set(current)-set(before)); removed=sorted(set(before)-set(current)); changed=sorted(k for k in set(current)&set(before) if current[k]!=before[k])
print('RECEIPT_SEEDS_UNCHANGED='+str(receipt['seeds_unchanged']))
print('CURRENT_SEED_MAP='+str(len(current))+' RECEIPT_SEED_MAP='+str(len(before)))
print('ADDED='+str(added))
print('REMOVED='+str(removed))
print('CHANGED='+str(changed))
PY
```

Observed: `RECEIPT_SEEDS_UNCHANGED=False`; `CURRENT_SEED_MAP=131 RECEIPT_SEED_MAP=130`; `ADDED=['PINNED-ENV.md']`; `REMOVED=[]`; `CHANGED=[]`.

## Claim verdicts

1. **VERIFIED** — `reports/round-105/r105-connector.md:39-45`: runner has 350 unique cases; its cannon subset has 19 rows, with 13 positive rows whose expected markers pin Node 24.21.0. C1 observed all of these counts and only `node=v24.21.0` in the cannon marker set.
2. **VERIFIED** — `reports/round-105/n24/adversary.md:18-19` and `reports/round-105/n24/runbook.md:35-36`: the cannon subset splits into 13 positive rows and 6 negative controls. C1 observed `POSITIVE=13 NEGATIVE=6`.
3. **VERIFIED** — `reports/round-105/n24/adversary.md:11` and `reports/round-105/r105-connector.md:62`: the r104 default-environment receipt is 337 passes and 13 failures out of 350. C2 parsed the receipt as `350/337/13`, verdict `FAIL`.
4. **VERIFIED** — `reports/round-105/n24/pre-state.md:10-18,25-27`: default Node is 26.12.0 and the explicit fnm installation is 24.21.0. C3 re-resolved both versions.
5. **VERIFIED** — `reports/round-105/n24/revert.md:5-8`: fnm default is 24.21.0 while mise selects Node 26.12.0 (`latest`). C3 observed both values.
6. **VERIFIED** — `reports/round-105/kimi404/verify.md:10-14`: the old URL returns HTTP 404 and the corrected URL returns HTTP 200. C4 observed `old=404 corrected=200`.
7. **VERIFIED** — `reports/round-105/gate/final-run.md:28-43`: 12 manifest files, 12/12 checksum matches, 0 failed checks, RC 0. C5 independently returned those same counts.
8. **VERIFIED** — `reports/round-105/gate/final-run.md:45-51`: clone comparison has 12 tracked paths and zero extra, missing, or blob-different paths. C5 observed `CLONE_TRACKED=12`, all three zero counts.
9. **VERIFIED** — `reports/round-105/gate/final-run.md:67-70`: 13 cards, zero bad cards, census 12 static-only / 1 unproven-runtime / 0 verified-here. C5 reproduced the entire census.
10. **VERIFIED** — `reports/round-105/gate/final-run.md:72-80`: pointer sweep totals 103 endpoints from 41 strings, with zero skipped sentinels and zero unresolved pointers; process RC 0. C5 observed those exact values and `GATE RESULT: PASS`.
11. **VERIFIED** — `reports/round-105/ledger-check.md:40-44`: tracked counts for report trees 101–104 are 33, 61, 61, and 21,950. C6 independently recounted the four HEAD tree listings.
12. **VERIFIED** — `reports/round-105/ledger-check.md:48`: combined tracked-file count across those four trees is 22,105. C6 summed the same independently counted tree listings.
13. **VERIFIED** — `reports/round-105/pc/analyst-1.md:56-71`: six cards are listed as dissenting, all labeled `static-only`. C7 found the same six filenames and labels in the card files.
14. **VERIFIED** — `reports/round-105/n24/runbook.md:42-45` and `reports/round-105/r105-connector.md:55-60`: the durable pinned-runtime receipt covers one case, with 1 pass, 0 failures, `seeds_unchanged=true`, and the `v24.21.0` marker. C8 parsed the receipt directly.
15. **VERIFIED** — `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout:704-705`: all 350 case rows returned PASS (291 ordinary, 59 negative controls), with zero case-row failures. C9a counted all rows and read the final two output lines.
16. **WRONG** — treating that 350/350 case-row tally as a successful full-battery acceptance. The stdout ends `FAIL battery`; C9b parsed receipt `verdict=FAIL` and `seeds_unchanged=False`. C9c found one seed-map difference: current 131 files versus the receipt's 130, with `PINNED-ENV.md` added and no removed or changed entries. The cases passed, but the runner's integrity condition did not.

The full-run row tally is correct, but the overall battery verdict is FAIL; do not infer acceptance from per-case counts alone.
