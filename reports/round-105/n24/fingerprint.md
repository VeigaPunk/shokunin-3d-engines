# SEAT-53 — Node 24 environment fingerprint

## Finding

This shell has fnm Node `v24.21.0` installed and its `default` alias points to it, but the effective default `node` is mise Node `v26.12.0`. PATH order is the cause: mise's `installs/node/latest/bin` is entry 3, then its shim at entry 4; both precede the active fnm multishell entry at 5. More precisely, entry 3's direct executable wins; it is not the shim that `command -v node` selects. Prefixing fnm's 24.21.0 `bin` directory makes it win without changing shell configuration or fixtures.

## Evidence

**E1 — PATH order and default selection.** Commands run:

```sh
python3 -c 'import os; print("\n".join(f"{i:02d} {p}" for i,p in enumerate(os.environ["PATH"].split(":"),1)))'
type -a node
command -v node; node --version
```

Observed:

```text
03 /home/vgpnk/.local/share/mise/installs/node/latest/bin
04 /home/vgpnk/.local/share/mise/shims
05 /run/user/1000/fnm_multishells/1974941_1792342566751/bin
06 /home/vgpnk/.local/share/fnm
node is /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
node is /home/vgpnk/.local/share/mise/shims/node
node is /run/user/1000/fnm_multishells/1974941_1792342566751/bin/node
command -v node: /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
node --version: v26.12.0
```

Also run: `mise which node; readlink -f /home/vgpnk/.local/share/mise/installs/node/latest/bin/node; /home/vgpnk/.local/share/mise/installs/node/latest/bin/node --version; file /home/vgpnk/.local/share/mise/shims/node`. Observed: mise selected `.../installs/node/latest/bin/node`, its resolved target was `.../installs/node/26.12.0/bin/node`, version `v26.12.0`, and `shims/node` is a symlink to `/usr/bin/mise`.

**E2 — fnm default alias.** Commands run: `ls -la /home/vgpnk/.local/share/fnm/aliases; readlink /home/vgpnk/.local/share/fnm/aliases/default; fnm list; fnm current; fnm exec --using default node --version`. Observed:

```text
default -> /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation
* v24.21.0 default
* system
fnm current: v24.21.0
fnm exec --using default node --version: v24.21.0
```

`default` is an alias symlink to the installed version; it does not override earlier PATH entries. Direct-prefix check run: `PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH sh -c 'command -v node; node --version'`. Observed the prefixed binary path and `v24.21.0`. The tested runbook form is:

```sh
PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH python3 corpus/fixtures/run_battery.py ...
```

**E3 — battery call sites.** Command run: `Grep(pattern='\bnode --version\b|timeout[^\n]*\bnode\b|\bnode ["$].*\.mjs', path='corpus/fixtures', glob='*.gd')`. Observed these two executable call sites in `corpus/fixtures/r94_cannon.gd`:

```text
127 OS.execute("/bin/sh", ["-c", "node --version"], out, true)
169 var cmd := ("timeout -s KILL %d node \"%s\" %s" + " > \"%s\" 2>&1")
```

Lines 172 executes that second command through `/bin/sh -c`. The first probes the version for the PASS marker; the second launches each `r94_child.mjs` case under `timeout` with bare `node`. The fixture comments at lines 15–16 say this resolves through inherited PATH.

Runner scan command: `Grep(pattern='^def run_process|subprocess\.run\(command|version_out, version_err|command = \[args\.godot', path='corpus/fixtures/run_battery.py')`. Observed `subprocess.run(command, ...)` at line 951 without an `env` override, and the version/case command arrays use `args.godot` at lines 1263 and 1268. The runner launches Godot, not Node directly.

Read-only AST count command:

```sh
python3 -c 'import ast, pathlib; p=pathlib.Path("corpus/fixtures/run_battery.py"); t=ast.parse(p.read_text()); cases=next(n.value for n in t.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=="CASES" for x in n.targets)); r=[x for x in cases.elts if isinstance(x,ast.Tuple) and isinstance(x.elts[0],ast.Constant) and str(x.elts[0].value).startswith("r94_cannon")]; pos=[x for x in r if x.elts[3].value==0]; pins=sum("node=v24.21.0" in x.elts[4].value for x in pos); neg=sum(x.elts[3].value==2 for x in r); print("rows={} positive={} positive_marker_pin={} negative={}".format(len(r),len(pos),pins,neg))'
```

Observed: `rows=19 positive=13 positive_marker_pin=13 negative=6`. All 13 positive arms pin `node=v24.21.0`; six negative-control arms expect exit 2.

**E4 — inherited PATH verified end-to-end.** Command run:

```sh
PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH \
  python3 corpus/fixtures/run_battery.py --only=r94_cannon_nan \
  --runs /tmp/gd3d-r105-seat53-probe
```

Observed: `PASS r94_cannon_nan: exit=0 expected=0`, `totals: cases=1 pass=1 fail=0`, and receipt stdout `PASS r94_cannon nan node=v24.21.0 ...`; receipt field `seeds_unchanged` was `true`. This exercises Python → Godot → `/bin/sh` → `node`. The isolated temporary probe tree was removed after inspection.

A same-case default-env rerun command, `python3 corpus/fixtures/run_battery.py --only=r94_cannon_nan --runs /tmp/gd3d-r105-seat53-default-probe`, failed during fixture-to-scratch copying before Godot launched: `OSError: [Errno 122] Disk quota exceeded` while copying `phys3d_events.gd`. Therefore this seat does not count a default-env battery case as rerun evidence; default selection itself is evidenced by E1. No fixture or persistent environment changes were made.
