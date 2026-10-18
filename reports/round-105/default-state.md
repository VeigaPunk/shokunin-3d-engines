# SEAT-60 BATTERY-DEFAULT-STATE — r105

Axes: calibration (distinguish PATH-selected states), coverage (pair both durable receipts), depth (retain reproducible checks and integrity caveat).

## Two-state model

The counts are environment-dependent, not contradictory. The default shell resolves mise's Node v26.12.0; the battery's 13 positive `r94_cannon_*` markers pin Node v24.21.0. Prepending the existing fnm installation path changes only the battery process's `PATH` and selects Node v24.21.0.

| State | Durable receipt | Case totals | Receipt integrity |
|---|---|---:|---|
| Default PATH, Node v26.12.0 | `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` (stdout: `.../20261018T194637610772Z-battery.stdout`) | 350 cases; 337 pass, 13 fail | `seeds_unchanged=true`; the 13 fails are all `r94_cannon_*` with `exact stdout marker missing` |
| PATH-prefixed fnm Node v24.21.0 | `corpus/live/runs/20261018T202944290389Z/verdicts.json` (stdout: `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout`) | 350 cases; 350 pass, 0 fail | **Overall verdict FAIL** because `seeds_unchanged=false` |

The pinned receipt is the C2 counting artifact: it records **350/350 row passes**, and all 13 positive cannon rows pass with `node=v24.21.0`. Do not describe it as a clean battery PASS: the runner's top-level verdict is FAIL due to the seed-tree integrity check. A clean, durable 350/350 acceptance receipt requires a pinned rerun after the fixture documentation tree is stable. This seat did not rerun the expensive default battery; the default row above is the archived r104 artifact.

`corpus/fixtures/run_battery.py` is unchanged at SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`.

## Integrity blocker

The pinned run began at `2026-10-18T17:29:44-03:00`. The runner's saved pre-run digest map has 130 paths and does not include `PINNED-ENV.md`. The only current fixture-tree delta against that map is the allowed documentation file `corpus/fixtures/PINNED-ENV.md`, created at `17:35:35-03:00` while the full battery was running: current map 131, added `PINNED-ENV.md`, removed none, changed none. `run_battery.py:940-946` hashes fixture files recursively and `:1343-1345` requires the before/after maps to match. Thus all 350 case results pass, but the concurrent documentation addition invalidated the receipt's unchanged-seed gate. No fixture code file was changed by this seat; the scoped `git status` check showed only that doc.

## Commands actually run and observed output

Node resolution (PATH override is command-scoped):

```text
$ node --version; command -v node; PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Default receipt readout (the parser command did not rerun the battery):

```text
$ python3 -c "import json; p='reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json'; d=json.load(open(p)); bad=[r for r in d['results'] if r['verdict']!='PASS']; toks=sorted({line.split('node=',1)[1].split()[0] for r in bad for line in r['stdout'] if 'node=' in line}); print('receipt='+p); print('totals='+str(d['totals'])); print('verdict='+d['verdict']); print('seeds_unchanged='+str(d['seeds_unchanged'])); print('failed_cases='+str(len(bad))); print('failure_reasons='+str(sorted({tuple(r['reasons']) for r in bad}))); print('failed_case_node_tokens='+str(toks))"
receipt=reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
totals={'cases': 350, 'pass': 337, 'fail': 13, 'ordinary': 291, 'negative_controls': 59}
verdict=FAIL
seeds_unchanged=True
failed_cases=13
failure_reasons=[('exact stdout marker missing',)]
failed_case_node_tokens=['v26.12.0']
```

The pinned run's launched command (observed in the process list) was:

```text
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py > reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout 2>&1
```

Its final stdout lines were `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0` and `FAIL battery: .../corpus/live/runs/20261018T202944290389Z/verdicts.json`. The receipt parser command and output were:

```text
$ python3 -c "import json; p='corpus/live/runs/20261018T202944290389Z/verdicts.json'; d=json.load(open(p)); bad=[r for r in d['results'] if r['verdict']!='PASS']; cr=[r for r in d['results'] if r['case'].startswith('r94_cannon_') and not r['case'].startswith('r94_cannon_neg')]; toks=sorted({line.split('node=',1)[1].split()[0] for r in cr for line in r['stdout'] if 'node=' in line}); print('receipt='+p); print('totals='+str(d['totals'])); print('verdict='+d['verdict']); print('seeds_unchanged='+str(d['seeds_unchanged'])); print('result_rows='+str(len(d['results']))); print('nonpass_rows='+str(len(bad))); print('cannon_positive_rows='+str(len(cr))); print('cannon_all_pass='+str(all(r['verdict']=='PASS' for r in cr))); print('cannon_node_tokens='+str(toks)); print('seed_digests_before='+str(len(d['seed_digests']))); print('PINNED-ENV.md_in_before_map='+str('PINNED-ENV.md' in d['seed_digests']))"
receipt=corpus/live/runs/20261018T202944290389Z/verdicts.json
totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59}
verdict=FAIL
seeds_unchanged=False
result_rows=350
nonpass_rows=0
cannon_positive_rows=13
cannon_all_pass=True
cannon_node_tokens=['v24.21.0']
seed_digests_before=130
PINNED-ENV.md_in_before_map=False
```

The pre-run/current-tree digest comparison was run as follows:

```text
$ python3 -c "import hashlib,json; from pathlib import Path; p=Path('corpus/live/runs/20261018T202944290389Z/verdicts.json'); d=json.loads(p.read_text()); root=Path('corpus/fixtures'); before=d['seed_digests']; after={str(x.relative_to(root)):hashlib.sha256(x.read_bytes()).hexdigest() for x in sorted(root.rglob('*')) if x.is_file() and '__pycache__' not in x.parts and x.relative_to(root).parts[0] != 'three'}; print('before='+str(len(before))+' after='+str(len(after))); print('added='+str(sorted(set(after)-set(before)))); print('removed='+str(sorted(set(before)-set(after)))); print('changed='+str(sorted(k for k in before.keys() & after.keys() if before[k] != after[k])))"
before=130 after=131
added=['PINNED-ENV.md']
removed=[]
changed=[]
```

Timing and worktree evidence:

```text
$ stat -c '%n mtime=%y' corpus/fixtures/PINNED-ENV.md; python3 -c "import json,datetime; d=json.load(open('corpus/live/runs/20261018T202944290389Z/verdicts.json')); t=datetime.datetime.strptime(d['started_utc'],'%Y%m%dT%H%M%S%fZ').replace(tzinfo=datetime.timezone.utc).astimezone(); print('run_started_local='+t.isoformat(timespec='seconds'))"; git status --short -- corpus/fixtures
corpus/fixtures/PINNED-ENV.md mtime=2026-10-18 17:35:35.666705142 -0300
run_started_local=2026-10-18T17:29:44-03:00
?? corpus/fixtures/PINNED-ENV.md
```

The runner logic was checked with `python3 -c "from pathlib import Path; p=Path('corpus/fixtures/run_battery.py'); a=p.read_text().splitlines(); print('seed_digests: '+a[939]); print('walk: '+a[943]); print('seed_compare: '+a[1342]); print('failure_notice: '+a[1344])"`; output: `def seed_digests() -> dict:`, recursive `HERE.rglob("*")`, `seeds_unchanged = seed_digests() == digests_before`, and `print("FAIL seeds were modified during the run; seeds must stay read-only")`.

The fixture script pin and scoped worktree check were run with `sha256sum corpus/fixtures/run_battery.py; git status --short -- corpus/fixtures`:

```text
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
?? corpus/fixtures/PINNED-ENV.md
```

Durable file hashes were checked with `sha256sum reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json reports/round-104/physics/full-regression-runs/20261018T194637610772Z-battery.stdout reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout corpus/live/runs/20261018T202944290389Z/verdicts.json`:

```text
5daeb6f9cbb863d26093e9266ab5dcfb2875ee5207af6c2046327dfd147f9293  reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
c414c3041d5ff081b60be9bc28d274bfcf9c15acf597661ce5f7ee3bb1c6ae38  reports/round-104/physics/full-regression-runs/20261018T194637610772Z-battery.stdout
adf138203fa5898f5e839602ea15812e56f7ff1efcef5968cbf70d92f2793999  reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout
cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5  corpus/live/runs/20261018T202944290389Z/verdicts.json
```
