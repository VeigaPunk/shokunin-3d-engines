# Node 24.21.0 full battery

**Status: ACCEPTED on clean rerun.** Under pinned Node 24.21.0, 350/350 case rows pass (291 ordinary, 59 negative controls), `seeds_unchanged=true`, and the runner returns `PASS`. All 13 positive `r94_cannon_*` markers and `phys3d_joints_free_ops` pass; there are zero non-PASS case names. The first complete receipt below failed only because a new fixture documentation file was added during that run; the post-addition rerun produced the accepted receipt.

## Runtime and runner pins

- Command: `env PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" bash -c 'node --version; command -v node'`
- Observed: `v24.21.0`; `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`.
- `sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; AST count → `CASES 350`.

## Direct launch and initial receipt accounting

The SEAT-13 launch used the requested command, `env PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py`, but its background tool wrapper hit the 600-second cap after `r97_nodelat_dss`; it produced no totals and is not the accepted receipt.

The first complete capture, `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout`, reported `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0`, then `FAIL battery`; receipt: `corpus/live/runs/20261018T202944290389Z/verdicts.json`. There were zero non-PASS case names. The run-level failure was `seeds_unchanged=false`: comparison against the current fixture tree showed `new_seed_files=['PINNED-ENV.md']`, `removed_seed_files=[]`, `changed_existing=[]`; `git status --short corpus/fixtures` reported `?? corpus/fixtures/PINNED-ENV.md`. This declared documentation file was added during that run, invalidating its snapshot without changing any pre-existing seed.

## Accepted clean rerun

Capture: `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout`. Final output:

```text
totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T204240718894Z/verdicts.json
```

Receipt check command:

```sh
python3 - <<'PY'
import hashlib, json
from pathlib import Path
p = Path('corpus/live/runs/20261018T204240718894Z/verdicts.json')
d = json.loads(p.read_text())
seed = Path(d['seed'])
before = d['seed_digests']
current = {
    str(f.relative_to(seed)): hashlib.sha256(f.read_bytes()).hexdigest()
    for f in sorted(seed.rglob('*'))
    if f.is_file() and '__pycache__' not in f.parts
    and f.relative_to(seed).parts[0] != 'three'
}
nonpass = [r['case'] for r in d['results'] if r['verdict'] != 'PASS']
cannon = [r for r in d['results'] if r['case'].startswith('r94_cannon_')]
pos = [r for r in cannon if r['expected_exit'] == 0]
free_ops = [r for r in d['results'] if r['case'] == 'phys3d_joints_free_ops']
print('totals', d['totals'], 'verdict', d['verdict'], 'seeds_unchanged', d['seeds_unchanged'])
print('nonpass_cases', nonpass)
print('r94_cannon', len(cannon), 'all_pass', all(r['verdict'] == 'PASS' for r in cannon), 'positive_markers', len(pos), 'positive_all_pass', all(r['verdict'] == 'PASS' for r in pos))
print('phys3d_joints_free_ops', [(r['verdict'], r['actual_exit'], r['expected_exit']) for r in free_ops])
print('seed_files', len(before), 'current_tree_matches_receipt', current == before, 'new', sorted(set(current) - set(before)), 'removed', sorted(set(before) - set(current)))
PY
```

Observed output:

```text
totals {'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59} verdict PASS seeds_unchanged True
nonpass_cases []
r94_cannon 19 all_pass True positive_markers 13 positive_all_pass True
phys3d_joints_free_ops [('PASS', 0, 0)]
seed_files 131 current_tree_matches_receipt True new [] removed []
```

The pinned-runtime check `env PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" bash -c 'node --version; command -v node'` returned `v24.21.0` and `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`.
