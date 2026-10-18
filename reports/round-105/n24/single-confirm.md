# N24 single-row confirmation

Axes: **depth** (independent rerun), **coverage** (default and pinned runtime), **calibration** (state the marker mismatch, not a fixture defect).

Runner: `corpus/fixtures/run_battery.py`, SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (observed with `sha256sum corpus/fixtures/run_battery.py`). Same row and fixture bytes in both runs: **`r94_cannon_nan`** (`r94_cannon.gd`, `--arm=nan`).

## Default Node

Command executed:

```sh
node --version; python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs /dev/shm/r105-n24-single-default; rc=$?; printf 'COMMAND_EXIT=%s\n' "$rc"
```

Terminal receipt:

```text
v26.12.0
FAIL r94_cannon_nan: exit=0 expected=0 reasons=['exact stdout marker missing']

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
FAIL     r94_cannon_nan                     r94_cannon.gd              --arm=nan          0/0       ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
FAIL battery: /dev/shm/r105-n24-single-default/20261018T203112434975Z/verdicts.json
COMMAND_EXIT=1
```

Verdict JSON confirms `seeds_unchanged=true`; actual stdout marker was `PASS r94_cannon nan node=v26.12.0`, while the row expects `PASS r94_cannon nan node=v24.21.0`.

## fnm Node 24.21.0

Command executed:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs /dev/shm/r105-n24-single-pinned; rc=$?; printf 'COMMAND_EXIT=%s\n' "$rc"
```

Terminal receipt:

```text
v24.21.0
PASS r94_cannon_nan: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     r94_cannon_nan                     r94_cannon.gd              --arm=nan          0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /dev/shm/r105-n24-single-pinned/20261018T203113557353Z/verdicts.json
COMMAND_EXIT=0
```

Verdict JSON confirms `seeds_unchanged=true`; actual and expected stdout markers both name `node=v24.21.0`.

Both JSON receipts were independently parsed from the paths above: default `FAIL`, 0/1; pinned `PASS`, 1/1. `git status --short -- corpus/fixtures` returned no paths. The JSON run directories are in `/dev/shm`; the command transcripts and verified fields above are the durable pasted receipts.
