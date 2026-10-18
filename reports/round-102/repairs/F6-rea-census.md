# F6 — `corpus/knowledge/rea.md` tool-census repair (JADX / Binwalk / Unblob + sweep)

- Seat: SEAT-10 REPAIR. Owned path: `corpus/knowledge/rea.md` (only).
- Round: r102. Date: 2026-10-18. Lane HEAD at repair: `2c99b7b`.
- Discipline applied: the mint census sentence is a *historical factual claim*, so it is **left
  verbatim** and the correction is a **dated note appended to the same file**. No other lane file,
  lesson, fixture, or the byte-pinned r101 `corpus/knowledge/unreal-mcp/` subtree was touched.
- Subject file before-state sha256 (matches the sibling before-capture
  `reports/round-102/before/F6-rea-census.md`): `9be388f3137666a68b0ca49a0284696bedc77e22ea2b632415ff386c25da1c32`

## Defect

`corpus/knowledge/rea.md:7-9` claims, as of mint:

```
v6.4.0). Provider readiness: native-provider install remains blocked
(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
mint).
```

Re-measured on this host, **three of the four clauses are false** (JADX, Binwalk, Unblob are all
installed and runnable), and a fourth is false in a narrower sense than a PATH probe reveals
(pwntools is importable through the env-routed interpreter, not through plain `python3`).

## BEFORE (fail) — stale blanket claim present, contradicted by the host

```
$ grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md
1
$ which jadx binwalk unblob; echo rc=$?
/usr/bin/jadx
/usr/bin/binwalk
/home/vgpnk/.local/bin/unblob
rc=0
```

The census asserts absence; `which` finds all three. Exit 0 on the probe = the file is wrong.

## 1. JADX, Binwalk, Unblob — measured present, with version receipts

```
$ jadx --version; echo rc=$?
1.5.6
rc=0

$ binwalk --version; echo rc=$?
binwalk 3.1.0
rc=0

$ unblob --version; echo rc=$?
26.6.4
rc=0
```

Install provenance (so the versions are attributable, not just PATH artifacts):

```
$ pacman -Q jadx binwalk
jadx 1.5.6-1
binwalk 3.1.0-1

$ ls -l /home/vgpnk/.local/bin/unblob
lrwxrwxrwx 1 vgpnk vgpnk 51 Oct 13 13:53 /home/vgpnk/.local/bin/unblob -> /home/vgpnk/.local/share/uv/tools/unblob/bin/unblob

$ uv tool list
unblob v26.6.4
- unblob
```

JADX and Binwalk are pacman-owned system packages; unblob is a `uv tool` per-user install whose
shim is on PATH. All three exit 0 on `--version`.

## 2. pwntools — present, but only through the env-routed interpreter

The first probe reproduced the before-capture's negative result, because it used the default
interpreter:

```
$ python3 -c "import pwnlib"
ModuleNotFoundError: No module named 'pwnlib'
rc=1
```

A `REA_*` environment census on this host then showed a dedicated interpreter is configured, and
the import succeeds there:

```
$ echo "$REA_PWNTOOLS_PYTHON"
/home/vgpnk/.local/share/kaidoku-pwnenv/bin/python

$ "$REA_PWNTOOLS_PYTHON" -c "import pwnlib; print('pwnlib', pwnlib.version)"; echo rc=$?
pwnlib 4.15.0
rc=0

$ ls -l /home/vgpnk/.local/share/kaidoku-pwnenv/bin/python
lrwxrwxrwx 1 vgpnk vgpnk 79 Oct 13 13:45 .../bin/python -> /home/vgpnk/.local/share/uv/python/cpython-3.11-linux-x86_64-gnu/bin/python3.11
```

So the correct statement is **not** "pwntools absent" but "pwntools 4.15.0 importable only through
`REA_PWNTOOLS_PYTHON`; plain `python3` has no `pwnlib`". `inspect_binary_layout`'s
caller-supplied-pwntools prerequisite is therefore satisfiable on this host.

## 3. The JADX provider prerequisite is also satisfied

```
$ echo "$REA_JADX_MCP_JAR"
/home/vgpnk/.local/opt/jadx-headless-mcp/jadx-headless-mcp-0.7.1-all.jar

$ ls -l "$REA_JADX_MCP_JAR"
-rw-r--r-- 1 vgpnk vgpnk 42619858 Oct 13 13:54 .../jadx-headless-mcp-0.7.1-all.jar

$ unzip -l "$REA_JADX_MCP_JAR" | head -4
Archive:  /home/vgpnk/.local/opt/jadx-headless-mcp/jadx-headless-mcp-0.7.1-all.jar
  Length      Date    Time    Name
---------  ---------- -----   ----
       81  1980-02-01 00:00   META-INF/MANIFEST.MF
       2042  1980-02-01 00:00   com/atxx/jhmcp/BenchKt$benchMain$1$invokeSuspend$$inlined$sortedByDescending$1.class

$ echo "JAVA_HOME=${JAVA_HOME:-<unset>}"; java -version 2>&1 | head -1
JAVA_HOME=/usr/lib/jvm/java-21-openjdk
openjdk version "21.0.12.1" 2026-08-18
```

The headless JADX MCP JAR is the exact 0.7.1 version the skill's
`references/android-applications.md:16` names, it is a valid archive (unzip lists entries, rc=0),
and Java 21 exceeds the required Java 17. The earlier census word "blocked" no longer describes
this route.

## 4. Full `REA_*` env census (additional providers present)

```
$ env | grep -i "^REA_" | sort
REA_ADB_PATH=/usr/bin/adb
REA_APKTOOL_COMMAND=/usr/bin/apktool
REA_BINWALK_COMMAND=/usr/bin/binwalk
REA_JADX_MCP_JAR=/home/vgpnk/.local/opt/jadx-headless-mcp/jadx-headless-mcp-0.7.1-all.jar
REA_PWNTOOLS_PYTHON=/home/vgpnk/.local/share/kaidoku-pwnenv/bin/python
REA_UNBLOB_COMMAND=/home/vgpnk/.local/bin/unblob
REA_WAKARU_COMMAND=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/lib/node_modules/wakaru/node_modules/@wakaru/cli-linux-x64/wakaru
```

Spot-checks of the two that are runnable without a target:

```
$ apktool --version
3.0.3
$ ls -l /usr/bin/adb /usr/bin/apktool
-rwxr-xr-x 1 root  root  2951104 Sep  4 18:49 /usr/bin/adb
-rwxr-xr-x 1 root  root     2271 Oct 13 13:52 /usr/bin/apktool
$ "$REA_WAKARU_COMMAND" --version
wakaru 1.14.0
```

## 5. Controls — clauses re-measured and found STILL TRUE (no correction needed)

```
$ which ghidra ghidraRun analyzeHeadless
which: no ghidra in (...)
which: no ghidraRun in (...)
which: no analyzeHeadless in (...)

$ ls -d /opt/ghidra* /usr/share/ghidra* ~/ghidra*; ls /opt
ls: cannot access '/opt/ghidra*': No such file or directory
ls: cannot access '/usr/share/ghidra*': No such file or directory
ls: cannot access '/home/vgpnk/ghidra*': No such file or directory
1Password  claude-code  containerd  intel  packages  spotify

$ which rea; echo rc=$?
rc=1
```

Ghidra: absent (no PATH hit, no `/opt`/`/usr/share`/`~` install) — **census clause still true**.
`rea` CLI: absent (`which rea` rc=1) — **census clause still true**. Hopper was also probed
(`which hopper` fails, no `/opt/hopper*`): absent, consistent with the skill's provider notes.

## 6. Package pin currency (a staleness note, not a falsification)

```
$ npm view rea-agents version
6.7.0
$ npm view rea-agents dist-tags
{ latest: '6.7.0' }
$ npm view rea-agents@6.4.0 version
6.4.0
```

The pinned `npx -y rea-agents@6.4.0` still resolves, so the mint line "verified working at mint
time, v6.4.0" is **stale-but-working, not broken**. Per discipline this is not rewritten in place;
the dated note records that registry latest is 6.7.0 and that the skill source itself now documents
`@6.7.0`.

## Summary table (every row backed by a command above)

| Tool / claim (`rea.md:7-9`) | Census | Host 2026-10-18 | Verdict |
|---|---|---|---|
| Ghidra | absent | `which` fails; no `/opt`/`/usr/share`/`~` install | claim **still true** (control) |
| JADX | absent | `/usr/bin/jadx` 1.5.6, rc=0; pacman `jadx 1.5.6-1` | **claim false** |
| Binwalk | absent | `/usr/bin/binwalk` 3.1.0, rc=0; pacman `binwalk 3.1.0-1` | **claim false** |
| Unblob | absent | `/home/vgpnk/.local/bin/unblob` 26.6.4, rc=0; `uv tool` | **claim false** |
| pwntools | absent | `pwnlib` 4.15.0 via `REA_PWNTOOLS_PYTHON`; plain `python3` rc=1 | **claim false as worded** |
| no `rea` CLI | absent | `which rea` rc=1 | claim **still true** (control) |
| `rea-agents@6.4.0` | verified at mint | resolves; registry latest 6.7.0 | stale, not broken |

## AFTER (pass)

```
$ grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md
1                      # historical sentence preserved verbatim (not silently rewritten)

$ grep -c "Correction note (r102" corpus/knowledge/rea.md
1                      # dated correction note present

$ which jadx binwalk unblob; echo rc=$?
/usr/bin/jadx
/usr/bin/binwalk
/home/vgpnk/.local/bin/unblob
rc=0                   # the note's present-clause is reproducible from a clean shell

$ sha256sum corpus/knowledge/rea.md
3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059  corpus/knowledge/rea.md

$ wc -l corpus/knowledge/rea.md
63 corpus/knowledge/rea.md
```

Before → after: 27 lines / `9be388f3…` → 63 lines / `3932fc53…`. The growth is entirely the
appended dated note; the mint sentence and all other original lines are byte-identical.

## Boundary notes

- **No Unreal runtime claim** is made or implied anywhere in this repair; the Unreal editor is not
  installed and live-MCP behavior remains unproven by construction. The byte-pinned r101 subtree
  `corpus/knowledge/unreal-mcp/` was not read for content nor modified.
- **Prerequisites ≠ capability.** This repair records that the *provider prerequisites* for the
  JADX/Binwalk/Unblob/pwntools routes are satisfiable on this host. It does **not** prove an REA
  run: there is still no `rea` CLI, no MCP server registered in this session, and no analysis was
  executed. The corrected note says so explicitly.
- **Authorization unchanged.** The correction does not widen this lane's authorized REA use; the
  file's existing rule that first REA use must be its own declared falsifiable axis-move with a
  rejection control still stands, and the note restates it.
- The before-capture sibling artifact `reports/round-102/before/F6-rea-census.md` (SEAT-05) was
  read but not modified; this file is the repair-side counterpart.

## Reproduce

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
jadx --version; binwalk --version; unblob --version
"$REA_PWNTOOLS_PYTHON" -c "import pwnlib; print(pwnlib.version)"
unzip -l "$REA_JADX_MCP_JAR" | head -3
which ghidra ghidraRun analyzeHeadless; which rea
grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md
```
