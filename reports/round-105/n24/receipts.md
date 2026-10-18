# Node 24.21.0 full-battery receipts

## Result

| Run | Node resolution | Cases | Pass / fail | Receipt |
|---|---|---:|---:|---|
| r104 default environment | `node` → `v26.12.0` | 350 | 337 / 13 | `reports/round-104/physics/author-runs-full/20261018T192105574998Z/verdicts.json` |
| r105 pinned environment | `PATH`-prefixed `node` → `v24.21.0` | 350 | **350 / 0** | `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` |

The r104 receipt's 13 non-PASS cases are exactly the 13 positive `r94_cannon_*` marker rows. On the r105 run, all 19 `r94_cannon_*` rows pass, including the six negative controls. The pinned receipt is `verdict=PASS`, `seeds_unchanged=true`, `ordinary=291`, `negative_controls=59`.

## Commands and observed results

Runtime check, from the repository root:

```sh
node --version
# v26.12.0
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
# v24.21.0
```

Runner integrity check:

```sh
sha256sum corpus/fixtures/run_battery.py
# f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

Pinned full run (the stdout file contains every case line and the complete verdict):

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py
```

Observed final lines:

```text
totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T204240718894Z/verdicts.json
```

The run was executed with that command-scoped `PATH` prefix; it does not export or persist a change to the shell or mise/fnm configuration. `corpus/fixtures/PINNED-ENV.md` had SHA-256 `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f` both immediately before and after the accepted run. Its contents were included in the runner's fixture digest set. The runner reports `seeds_unchanged=true`.

The comparison was independently extracted from the two JSON receipts with this command:

```sh
python3 - <<'PY'
import json
for label,p in [('r104-default','reports/round-104/physics/author-runs-full/20261018T192105574998Z/verdicts.json'),('r105-node24','reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json')]:
 d=json.load(open(p)); bad=[r['case'] for r in d['results'] if r['verdict']!='PASS']
 print(label,'receipt='+p,'totals='+repr(d['totals']),'verdict='+d['verdict'],'seeds_unchanged='+str(d['seeds_unchanged']),'nonpass='+repr(bad))
PY
```

Observed: r104 default = `cases=350 pass=337 fail=13`, `seeds_unchanged=True`; non-PASS is `r94_cannon_det`, `r94_cannon_det2`, `r94_cannon_varstep`, `r94_cannon_bailout`, `r94_cannon_nan`, `r94_cannon_sync`, `r94_cannon_material`, `r94_cannon_friction`, `r94_cannon_parity`, `r94_cannon_parity2`, `r94_cannon_modes`, `r94_cannon_order`, `r94_cannon_backends`. r105 pinned = `cases=350 pass=350 fail=0`, `verdict=PASS`, `seeds_unchanged=True`, non-PASS `[]`.

## Durable files and SHA-256

The complete stdout was captured directly at its durable `reports/round-105/n24/runs/` path during the run; the complete `verdicts.json` was copied from ignored `corpus/live/runs/` into that directory. The accepted JSON copy was checked byte-identical to its source with `cmp -s`.

| File | SHA-256 |
|---|---|
| `runs/node24-full-rerun-20261018T204240Z.stdout` | `f80d61001c51e1380ddfdeb66b530bc805c2e5960406f49fe5e87e2934839286` |
| `runs/node24-full-rerun-20261018T204240Z.verdicts.json` | `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5` |
| `runs/node24-full-20261018T202944Z.stdout` | `adf138203fa5898f5e839602ea15812e56f7ff1efcef5968cbf70d92f2793999` |
| `runs/node24-full-20261018T202944Z.verdicts.json` | `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5` |

The first Node 24 run is retained for audit but is not the accepted receipt: it also ran all 350 rows successfully, but `seeds_unchanged=false` because the permitted `corpus/fixtures/PINNED-ENV.md` note was created during that run (it was absent from the start digest). After the note settled, the rerun above included it in the starting digest, confirmed its hash unchanged across the run, and exited 0. The reusable runbook is `corpus/fixtures/PINNED-ENV.md` (not modified by this seat).
