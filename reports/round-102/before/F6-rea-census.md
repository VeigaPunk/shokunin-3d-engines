# F6 before-capture — `corpus/knowledge/rea.md` tooling census vs host reality

Seat: SEAT-05 (r102). Scope: BEFORE state only — no edits made to any file.
Date: 2026-10-18. Lane HEAD at capture: `2c99b7b`.

Subject file: `corpus/knowledge/rea.md`
- sha256 `9be388f3137666a68b0ca49a0284696bedc77e22ea2b632415ff386c25da1c32`
- 27 lines total
- last touched by `82c21b4` (2026-10-13) "game-dev-3d r1: headless 3D battery, 12/12 with discriminating negatives"

## 1. The defect — verbatim census sentences

Command:

```bash
grep -n -i -E "jadx|binwalk|unblob" corpus/knowledge/rea.md
```

Observed output (single hit, line 8):

```
8:(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
```

Full sentence, byte-exact across lines 7–9 (`sed -n '6,9p' corpus/knowledge/rea.md`):

```
v6.4.0). Provider readiness: native-provider install remains blocked
(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
mint).
```

Supporting census vocabulary in the same file (`grep -n -i -E "census|not installed|absent|blocked" corpus/knowledge/rea.md`):

```
7:v6.4.0). Provider readiness: native-provider install remains blocked
8:(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
```

So there is exactly **one** census claim, in one sentence, covering four tools: Ghidra, JADX, Binwalk/Unblob (two names), pwntools. It is time-stamped ("census as of mint"), which is the only hedge it carries.

## 2. Host reality now — `which` census

Command:

```bash
which jadx binwalk unblob; echo "---exit=$?"
```

Observed output:

```
/usr/bin/jadx
/usr/bin/binwalk
/home/vgpnk/.local/bin/unblob
---exit=0
```

All three resolve. Exit 0 — every name on the `which` line was found.

### Version flags

Command:

```bash
for t in jadx binwalk unblob; do echo "=== $t ==="; ( $t --version 2>&1 || true ) | head -5; echo "rc=$?"; done
```

Observed output:

```
=== jadx ===
1.5.6
rc=0
=== binwalk ===
binwalk 3.1.0
rc=0
=== unblob ===
26.6.4
rc=0
```

Re-probed exit codes in isolation (`$t --version >/dev/null 2>&1; echo "$t --version rc=$?"`):

```
jadx --version rc=0
binwalk --version rc=0
unblob --version rc=0
```

### Provenance / install shape

Command:

```bash
for t in jadx binwalk unblob; do p=$(which $t); echo "$t -> $p"; ls -l "$p" | awk '{print "   size="$5" mtime="$6" "$7" "$8}'; done
pacman -Qo /usr/bin/jadx /usr/bin/binwalk
uv tool list
```

Observed output:

```
jadx -> /usr/bin/jadx
   size=29 mtime=Jul 18 18:37
binwalk -> /usr/bin/binwalk
   size=3893960 mtime=Oct 31 2024
unblob -> /home/vgpnk/.local/bin/unblob
   size=51 mtime=Oct 13 13:53
/usr/bin/jadx is owned by jadx 1.5.6-1
/usr/bin/binwalk is owned by binwalk 3.1.0-1
unblob:
unblob v26.6.4
- unblob
```

Reading: JADX and Binwalk are pacman-owned system packages; unblob is a `uv tool` shim (`/home/vgpnk/.local/bin/unblob`, 51-byte wrapper whose shebang points at `/home/vgpnk/.local/share/uv/tools/unblob/bin/python`) — i.e. a per-user install that is on PATH. The `unblob` mtime (Oct 13) is the *same day* as the r1 commit that wrote the census (`82c21b4`, Oct 13) — the install postdates or is contemporaneous with the census, and the census was wrong on that same day too, or was written from an assumption rather than a probe.

## 3. Controls — what the census gets right

To keep the repair honest, the same sentence's other two names were probed:

```bash
which ghidra ghidraRun
python3 -c "import pwntools, pwn; print('pwntools', pwn.__version__)"
```

Observed output:

```
which: no ghidra in (...)
which: no ghidraRun in (...)
    ^^^^^^^^^^^^^^^^^^^^
ModuleNotFoundError: No module named 'pwntools'
```

So of the four tool names in the census sentence, **two remain true** (Ghidra absent, pwntools absent) and **three names are now false** (JADX, Binwalk, Unblob — the last counted as one name covering two spellings). This matters for the repair wording: a blanket "the census is stale" would overclaim. The precise statement is "the census's JADX / Binwalk / Unblob clause is falsified as of 2026-10-18; the Ghidra and pwntools clauses still hold."

## 4. Summary table (all rows backed by a command above)

| Tool | Census claim (line 8) | Host reality 2026-10-18 | Verdict |
|---|---|---|---|
| Ghidra | absent | `which` fails, exit≠0 | claim still true |
| JADX | absent | `/usr/bin/jadx`, 1.5.6, rc=0 | **claim false** |
| Binwalk | absent | `/usr/bin/binwalk`, 3.1.0, rc=0 | **claim false** |
| Unblob | absent | `/home/vgpnk/.local/bin/unblob`, 26.6.4, rc=0 | **claim false** |
| pwntools | absent | `ModuleNotFoundError`, rc=1 | claim still true |

## 5. Boundary notes for the repairing seat

- No Unreal runtime claim is made or implied here; this is host tooling census only.
- The subject file `corpus/knowledge/rea.md` was **not modified** by this seat. Its sha256 above is the before-state to diff against.
- Per lane discipline this is a *historical factual claim*, so the repair is a dated correction note, not a silent rewrite of the r1 sentence. Suggested anchor: append a note after line 9 stating the census's JADX/Binwalk/Unblob clause was falsified, with the observed versions and probe date; leave the Ghidra/pwntools clauses untouched.
- Exact before/after command pair for the repair seat's evidence:
  - before: `grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md` → `1` (stale claim present)
  - after: the same grep must still return 1 (historical sentence preserved) while a new dated note carries the correction, and `which jadx binwalk unblob` exits 0.
