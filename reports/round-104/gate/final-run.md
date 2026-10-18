# SEAT-40 GATE-FINAL-RUN — r104 close-out gate run on the live tree

**Author:** SEAT-40 GATE-FINAL-RUN · round 104 · lane `game-dev-3d-shokunin`
**Run at:** 2026-10-18T19:26Z (UTC), host `plazir27`, Linux 7.2.3-arch1-3
**Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`)
**Subtree HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e`
**Gate script:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`,
sha256 `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` (`e5521304…`)

> **Headline: the gate PASSES on this tree — `RC=0`, four `STEP=PASS`, every pinned value matched.**
> But this seat also proved that on this host the gate's exit code is a function of `/tmp` quota
> pressure, not of the tree, and that `GATE_WORKDIR` is what removes that dependence. Read
> "Quota windows" before quoting any single run.

## Result

Canonical invocation and the observed exit code, at 19:26:12Z on scanner `e5521304…`:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
# → GATE RESULT: PASS (checks failed: 0)
# → RC=0
```

| invocation | exit | `GATE RESULT` | note |
|---|---|---|---|
| `run_gate.sh` (default `WORK_ROOT=/tmp`) | **0** | `PASS (checks failed: 0)` | this quota window was clear |
| `GATE_WORKDIR=<repo-local> run_gate.sh` | **0** | `PASS (checks failed: 0)` | passes in every window measured |

Both arms agree right now. They did **not** agree earlier in the same seat — see below.

## Verbatim output — `scratch/FINAL-default.out` (default root, quota window clear)

```text
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.2G of 16G (80% used)
LANE_HEAD=88c3b2ca70fc83ec47a931d7b6dcff85a111c04e

MANIFEST_FILES=12
CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
RC=0
```

**stderr:** empty. `scratch/FINAL-gw.out` is the identical output with
`WORK_ROOT=…/scratch/localwork (from GATE_WORKDIR)` and `WORK_ROOT_FREE=770G of 930G (16% used)`;
the two runs differ only in those two lines (both cloned for real, so both carry CHECK 2's
`CLONE_*` lines). Verified with a line-by-line diff of the two files, not by eye.

## Every pinned expectation matched

| pinned quantity | expected (`gate/README.md`) | observed | match |
|---|---|---|---|
| CHECK 1 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` | identical | yes |
| CHECK 2 clone HEAD | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | identical | yes |
| CHECK 2 | `CLONE_DIRTY=0 CLONE_TRACKED=12` | identical | yes |
| CHECK 2 | `PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0` | identical | yes |
| CHECK 3 | `CARDS=13 EXPECTED=13 BAD=0`, `NAME_SET=OK NAME_BAD=0` | identical | yes |
| CHECK 3 census | `12 / 1 / 0` | `static-only=12 unproven-runtime=1 verified-here=0` | yes |
| CHECK 4 | `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` | identical | yes |
| exit code | `0` on all-`PASS` | `RC=0` | yes |

`POINTERS=103` is the current pin: `gate/README.md:42` and the pinned-constants table (`:283`) both
read `103` against scanner `e5521304…`, re-measured by SEAT-12 at 19:24Z. The earlier `101` pin
belonged to the old scanner `577c8b54…`; the count moved because the README's own prose grew (sweep B
counts `gate/README.md` itself). **`POINTER_STRINGS=41` is unchanged across all four scanners**, which
is the reassuring signal: the pointer *set* did not change, only the endpoint expansion.

## Quota windows — why the exit code is not a property of the tree

`/tmp` on this host is a 16G tmpfs under a **per-user quota that `df` cannot see**. Writes fail with
**`EDQUOT` (errno 122)** while `df` reports ~3.1G free:

```console
$ python3 -c "open('/tmp/x','wb').write(b'x')"
OSError: [Errno 122] Disk quota exceeded
$ df -h /tmp
tmpfs   16G   12G   3.1G   80%   /tmp
```

The pressure comes and goes in **windows**, so a single run proves nothing about the host:

| window | sample | default `/tmp` | `GATE_WORKDIR` |
|---|---|---|---|
| 19:22Z (pressure on) | 20 runs each | `rc0=0 rc1=20` — **0/20 PASS** | `rc0=20` — **20/20 PASS** |
| 19:23Z (mixed) | 10 runs | `0 0 0 0 0 2 2 1 2 2` | (not sampled) |
| 19:25Z (mixed) | 12 runs | 4×`BLOCKED`, 1×`rc1`, 7×`rc0` | (not sampled) |
| 19:26Z (clear) | 24 runs | **24/24 PASS** | (not sampled) |

In the pressured window the split was total and reproducible: `GATE_WORKDIR` **never** failed and the
default root **never** passed. The failure evidence the gate itself emitted is unambiguous `EDQUOT`:

```text
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to '/tmp/tmp.ycnc1MtT1r/clone/.git/description': Disk quota exceeded
```

and in a later pressured run, on the clone's config write instead of the template copy:

```text
error: failed to write new configuration file /tmp/tmp.zuSsWzWemS/clone/.git/config.lock
fatal: could not set 'core.filemode' to 'true'
```

Both are preserved: `scratch/FINAL-default.out` (the `BLOCKED (network)` variant of the second one)
and `scratch/quota-default.out`. `WORK_ROOT_FREE=3.1G of 16G (80% used)` appears in the *same* output
as the quota errors — the gate's own space readout is exactly the check that cannot see this failure.

**Consequence for the receipt:** run the close-out gate with `GATE_WORKDIR` set, or accept that a
red result may be a `/tmp` artifact. A green default-root run is not evidence the host is healthy —
at 19:26Z it passed 24/24, and minutes earlier it passed 0/20.

## What this run claims and does not claim

- **Claims:** on the frozen tree above, the vendored `upstream/` bytes are byte-identical to pinned
  commit `a6aa73ad` — CHECK 1 from the committed manifest and CHECK 2 independently against a *fresh*
  clone's blobs — the path set matches upstream both ways, the 13 verdict cards exist under the pinned
  filenames with one anchored, in-range, single-token label each, and every pointer in the subtree's
  prose resolves (`UNRESOLVED=0`).
- **No Unreal runtime claim.** Unreal Editor is not installed here — `command -v UnrealEditor UE4Editor`
  finds nothing, and no `/opt`, `/usr/local` or `~/UnrealEngine` exists. The census is still
  `12 static-only / 1 unproven-runtime / 0 verified-here`; nothing was promoted. A green gate is not
  evidence of live-editor behaviour and must never be cited as such.
- **CHECK 2 used the real network** in both final runs (`GATE_REF` unset), so its `PASS` is a genuine
  comparison, not an offline substitute. In the pressured runs the clone failed *before* any
  comparison, which is why the state is `BLOCKED` and the bytes are correctly called `UNCHECKED`.

## Residuals for the round-1 writer

**R1 — the new `mktemp` guard cannot catch the failure it was written for.** Verified on the final
scanner. The guard is `MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''`, then a named FAIL
if `MANLOG` is empty. But under `EDQUOT`, `mktemp` **succeeds** — it creates a 0-byte inode, which
costs no quota:

```console
$ M=$(mktemp -p /tmp); echo "rc=$? path=[$M]"     # rc=0, path=/tmp/tmp.tCqP8Gxsc6
$ printf 'x%.0s' $(seq 1 864) > "$M"; echo "rc=$?" # rc=1
$ ls -la "$M"                                      # -rw------- 0 bytes
```

So the guard passes, the redirect `>"$MANLOG"` fails, and the gate prints the **misleading**
`FAIL per-seat manifest sweep (--strict) failed:` with an **empty body** — the exact false-red class
SEAT-12 set out to close. The guard tests *creatability*; the failure mode is *writability*.
Suggested shape: verify a byte, e.g. `printf 'x' >"$MANLOG" 2>/dev/null || MANLOG=''` after the
`mktemp`, so a 0-byte-inode success is caught and reported by the named message instead.

**R2 — the r104 classifier is a real improvement, and it is observable.** On `577c8b54…` the same
`EDQUOT` produced `CHECK 2 BLOCKED (network)` — a disk failure reported as a network failure, sending
the reader to the wrong subsystem. On `e5521304…` it produces `CHECK 2 BLOCKED (local-resource)` plus
`BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream`. Both texts are
in this seat's captures. **The classifier is a keyword match, so it is only as good as git's wording.**
`corpus/knowledge/unreal-mcp/gate/run_gate.sh:267` tests the clone log against
`disk quota exceeded|no space left|out of diskspace|write error|quota exceeded`. That matched the
pressured-window failure whose log read `copy-fd: write returned: Disk quota exceeded`, but **missed**
a later `/tmp` write failure whose log read
`error: failed to write new configuration file /tmp/…/clone/.git/config.lock` /
`fatal: could not set 'core.filemode' to 'true'` — no keyword fired, so the gate labelled a local disk
failure `BLOCKED (network)`. Observed both ways in this seat. Treat `BLOCKED` as "CHECK 2 did not
run" and read the `error:`/`fatal:` lines below it, not the label, to attribute cause. A cheap
hardening would be to also classify on the scratch root being the default (`WORK_SRC=default`) with a
non-empty `C2_LOG`, or to add `config.lock`/`filemode` to the pattern.

**R3 — the scanner moved four times during this seat** (`577c8b54` → `15fc46d5` → `b6d8c61a` →
`e5521304`), all between 16:21Z and 16:22Z, all SEAT-12/C2 edits. Any receipt quoting a `run_gate.sh`
sha must re-measure at write time. This report pins `e5521304…` and matches the README's own
`e5521304…` pin; if the file changed after 19:26Z, re-run and treat these numbers as
scanner-specific. (`gate/README.md` was also edited in the same pass — `git diff --stat` shows +110
lines — which is what moved `POINTERS` 101 → 103.)

**R4 — the mixed BLOCKED+FAIL state is reachable, not theoretical.** `GATE RESULT: FAIL` with
`RC=1` while `FAILS=1` and CHECK 2 was BLOCKED was observed for real in this seat (manifest-sweep
"FAIL" + CHECK 2 BLOCKED), losing the third state exactly as `gate/README.md`'s residual note warns.

**R5 — transient network flake is real but rare.** On the old scanner 1 of 12 runs exited `2` from an
unreachable upstream alone; `git ls-remote` returned the pin `rc=0` again ~20s later and
`curl https://github.com` returned `200`. Not a defect; recorded so nobody re-derives it.

## Artifacts

| file | contents |
|---|---|
| `scratch/FINAL-default.out` / `.err` | final default-root run, full stdout/stderr |
| `scratch/FINAL-gw.out` / `.err` | final `GATE_WORKDIR` run, full stdout/stderr |
| `scratch/window-pass-default.out`, `window-pass-gw.out` | the 19:26Z clear-window pair |
| `scratch/quota-default.out` | pressured-window failure on the pre-C2 scanner (`BLOCKED (network)`) |
| `scratch/seat40-run1.out`, `seat40-run2.out`, `seat40-final.out` | three clean `RC=0` runs on old scanner `577c8b54…` (only evidence of a pre-C2 green state) |
| `scratch/tree-before.sha256`, `tree-after.sha256` | full subtree sha256 snapshot; `diff` empty |

`localwork/` is the `GATE_WORKDIR` used above; the gate empties it via its own `trap cleanup EXIT`.

## Re-run recipe

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # e5521304… for THIS report to apply
D=reports/round-104/gate/scratch
GATE_WORKDIR=$PWD/$D/localwork corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
```

Expect `RC=0`, four `STEP=PASS`, `POINTERS=103 … UNRESOLVED=0`. If you instead see
`BLOCKED (local-resource)` or `FAIL per-seat manifest sweep`, the host is in a quota window — check
`GATE_WORKDIR` is actually set and points at the repo filesystem. Air-gapped equivalent (`GATE_REF`
names an existing clone at the pin, no network touched):

```sh
REF=$(mktemp -d)/pin
git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin "$REF"
git -C "$REF" checkout --quiet a6aa73ada02a9fb1f5415bec491f9942c519b297
GATE_WORKDIR=$PWD/$D/localwork GATE_REF=$REF corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
```

A *bad* `GATE_REF` (not a git clone) is a genuine `FAIL`/exit 1, not BLOCKED — so a green run with
`GATE_REF` set still means CHECK 2 actually compared something.
