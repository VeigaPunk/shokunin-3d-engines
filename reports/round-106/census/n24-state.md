# SEAT-37 CENSUS-N24-STATE — pinned Node per PINNED-ENV.md

Axes: **depth** (fnm path re-probed this seat, not inherited), **coverage** (one cannon row PASS under that path), **calibration** (reuse SEAT-28's receipt only after byte-binding it to the live tree; no engines.md rewrite).

Result: **PASS**. The PINNED-ENV.md path exists and is executable. Command-scoped `PATH` selects `v24.21.0`. Default `node` remains mise `v26.12.0`. One positive cannon row, `r94_cannon_det`, is PASS under the pinned path with `node=v24.21.0` and `seeds_unchanged=true`. This is one ordinary row, not a 350-case claim.

## What PINNED-ENV.md requires

`corpus/fixtures/PINNED-ENV.md` (SHA-256 `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f`, observed this seat) says: prepend `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin` for the invocation; expect `node --version` = `v24.21.0`; do not change the shell's persistent environment. Default `node` on this host is mise `v26.12.0`.

## Path and version (this seat, 2026-10-18T21:22:48Z)

Commands run from the repository root. HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Transcript: `reports/round-106/scratch/seat37/probe.txt`.

```sh
FNM_BIN=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
test -d "$FNM_BIN" && test -x "$FNM_BIN/node"
ls -ld "$FNM_BIN" "$FNM_BIN/node"
stat -c 'path=%n mode=%a size=%s mtime=%y' "$FNM_BIN/node"
file "$FNM_BIN/node"
readlink -f "$FNM_BIN/node"
PATH="$FNM_BIN:$PATH" command -v node
PATH="$FNM_BIN:$PATH" node --version
PATH="$FNM_BIN:$PATH" node -p 'process.execPath'
command -v node
node --version
node -p 'process.execPath'
```

Observed:

```text
fnm_bin_dir=exists
fnm_node_executable=yes
drwxr-xr-x ... /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
-rwxr-xr-x 1 vgpnk vgpnk 126595440 Sep  7 20:56 .../installation/bin/node
path=.../installation/bin/node mode=755 size=126595440 mtime=2026-09-07 20:56:43.000000000 -0300
ELF 64-bit LSB executable, x86-64, ... BuildID[sha1]=bd05d6407047594fc3d31dd4ed4a37fe48c01f93
readlink -f → the same path (not a symlink)
PATH-prefixed command -v node → .../installation/bin/node
PATH-prefixed node --version → v24.21.0
PATH-prefixed process.execPath → .../installation/bin/node
unprefixed command -v node → /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
unprefixed node --version → v26.12.0
unprefixed process.execPath → /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
```

The prefix is command-scoped. This seat did not write mise/fnm config and did not edit `corpus/fixtures/`.

## Cannon row (reused SEAT-28 receipt)

SEAT-28's durable receipt was present before this seat wrote. Reuse is allowed only because this seat re-checked the bytes against the live tree, not because the sibling report was trusted as text.

| Check | Observed |
|---|---|
| durable receipt | `reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json` |
| SHA-256 | `11109a3cad610b759974606e7784a5f215332c7d092ab0ead0c514b2fdac344f` |
| vs runner output `reports/round-106/scratch/seat28-cannon/20261018T212035892614Z/verdicts.json` | `cmp -s` → `BYTE_IDENTICAL` |
| transcript | `reports/round-106/census/cannon-run-20261018T212035Z.log` SHA-256 `64638c76cd22353d0c92b3340830194563370e45454845d7934954579980ecd4` |
| `verdict` / `seeds_unchanged` | `PASS` / `true` |
| `only` / `started_utc` | `r94_cannon_det` / `20261018T212035892614Z` |
| `totals` | cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 |
| row | exit 0/0, reasons `[]`, elapsed 1.68s, kind ordinary |
| stdout token | `node=v24.21.0` (expected marker also pins `node=v24.21.0`; prefix match true) |
| Godot | `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` |
| `seed_digests.run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` = live `sha256sum corpus/fixtures/run_battery.py` |
| `seed_digests["PINNED-ENV.md"]` | `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f` = live file (131 digests) |

SEAT-28's logged command was the PINNED-ENV.md form:

```sh
PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH \
  python3 corpus/fixtures/run_battery.py --only r94_cannon_det \
  --runs reports/round-106/scratch/seat28-cannon
```

Its log records `COMMAND_EXIT=0` and the same pinned `command -v` / `v24.21.0` pair. This seat did not re-run the row.

## What this does not claim

- Not a full battery. r105 pinned 350/350 remains `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`. Default-env 337/350 was not re-run here.
- Not an Unreal runtime claim. Editor is not installed.
- `corpus/knowledge/engines.md` was not edited. State cells do not move on this seat's evidence alone.
