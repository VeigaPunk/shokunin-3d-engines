# N24 default-environment pre-state — SEAT-12

Scope: one representative cannon row only; this is not a full-battery result.

## Default Node resolution

Commands run and output:

```text
$ which node
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ node --version
v26.12.0
$ type -a node
node is /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
node is /home/vgpnk/.local/share/mise/shims/node
node is /run/user/1000/fnm_multishells/1974941_1792342566751/bin/node
node is /run/user/1000/fnm_multishells/1630_1792206008234/bin/node
node is /run/user/1000/fnm_multishells/1981442_1792342591527/bin/node
```

The pinned fnm installation is present and directly reports v24.21.0:

```text
$ FNMBIN=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node; printf 'fnm_pinned_node=%s\n' "$FNMBIN"; if test -x "$FNMBIN"; then "$FNMBIN" --version; else printf 'not executable\n'; fi
fnm_pinned_node=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
v24.21.0
```

## Default-environment representative row

Command run with the default PATH and runner-default Godot executable:

```text
$ python3 corpus/fixtures/run_battery.py --only r94_cannon_nan --runs /tmp/r105-seat12-default-node-20261018
FAIL r94_cannon_nan: exit=0 expected=0 reasons=['exact stdout marker missing']

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
FAIL     r94_cannon_nan                     r94_cannon.gd              --arm=nan          0/0       ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
FAIL battery: /tmp/r105-seat12-default-node-20261018/20261018T203000723964Z/verdicts.json
battery_exit=1
```

Receipt `/tmp/r105-seat12-default-node-20261018/20261018T203000723964Z/verdicts.json`; extracted with:

```text
$ python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); r=d["results"][0]; print("case="+r["case"]+" verdict="+r["verdict"]+" expected_exit="+str(r["expected_exit"])+" actual_exit="+str(r["actual_exit"])); print("expected_marker="+r["marker"].split(" nan_all{", 1)[0]); print("actual_marker="+next(s for s in r["stdout"] if s.startswith("PASS ")).split(" nan_all{", 1)[0]); print("reason="+"; ".join(r["reasons"])); print("seed_run_battery_sha256="+d["seed_digests"]["run_battery.py"])' /tmp/r105-seat12-default-node-20261018/20261018T203000723964Z/verdicts.json
case=r94_cannon_nan verdict=FAIL expected_exit=0 actual_exit=0
expected_marker=PASS r94_cannon nan node=v24.21.0
actual_marker=PASS r94_cannon nan node=v26.12.0
reason=exact stdout marker missing
seed_run_battery_sha256=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
```

Conclusion: the row fails on Node-version marker mismatch, not a nonzero fixture exit: the recorded expected marker pins v24.21.0, while the executed fixture reports v26.12.0. `type -a node` shows the mise-installed Node and mise shim ahead of the active fnm multishell entries; the pinned fnm v24.21.0 binary is available but is not first on the default resolution path. The runner-receipt `seed_digests.run_battery.py` matches the observed local SHA-256.
