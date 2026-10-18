# r105 SEAT-11 — N24-RUNBOOK-AUTHOR

Scope: pinned-Node runbook only. The companion instructions are in `corpus/fixtures/PINNED-ENV.md`. No fixture code, environment configuration, or existing fixtures README was changed.

## Runtime selection verified

Commands run from the repository root:

```text
$ node --version
v26.12.0
$ command -v node
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

The runnable full-battery command is:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py
```

The `PATH` assignment is scoped to that process tree; no persistent shell or system configuration is needed.

## Marker and receipt evidence

Source checks actually run:

```text
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ python3 -c 'import ast,pathlib; t=ast.parse(pathlib.Path("corpus/fixtures/run_battery.py").read_text()); n=next(n for n in t.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=="CASES" for x in n.targets)); c=ast.literal_eval(n.value); print("CASES="+str(len(c))+" pinned_node_24_rows="+str(sum("node=v24.21.0" in str(x) for x in c)))'
CASES=350 pinned_node_24_rows=13
```

The L1 receipt was read with this command:

```text
$ python3 -c 'import json; d=json.load(open("corpus/live/runs/20261018T202715395926Z/verdicts.json")); r=next(x for x in d["results"] if x["case"]=="r94_cannon_nan"); print("case="+r["case"]+" verdict="+r["verdict"]+" exit="+str(r["actual_exit"])+" seeds_unchanged="+str(d["seeds_unchanged"])); print(next(s.split("{",1)[0] for s in r["stdout"] if s.startswith("PASS "))); print("totals="+str(d["totals"]))'
case=r94_cannon_nan verdict=PASS exit=0 seeds_unchanged=True
PASS r94_cannon nan node=v24.21.0 nan_all
totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
```

This is a single-case probe, not the full-battery acceptance run. For default-environment history, `reports/round-104/physics/full-regression.md` §§2–3 records the r104 full-run command with `--runs /home/vgpnk/.cache/s07/runs-after` and 350 rows: 337 pass, 13 fail. Section 3.3 shows the 13 unchanged cannon rows had `exact stdout marker missing`, with expected `node=v24.21.0` versus observed `node=v26.12.0`. The separate r105 default-environment one-case reproduction in `reports/round-105/n24/pre-state.md` records its command and the same marker mismatch.

## Verification boundary

This seat did not run the 350-case battery, so it does not claim a current 350/350 N24 result or a full-run receipt. The command above is the runbook for that verification; the L1 receipt establishes only the named one-case probe. Fixture source remained unchanged: `git diff --quiet -- corpus/fixtures/run_battery.py corpus/fixtures/r94_cannon.gd` exited 0.
