# SEAT-14 — A4-ATTACK: unreachable clone must yield a distinct BLOCKED signal + exit 2

**Round:** r103 · **Date:** 2026-10-18 · **Lane:** game-dev-3d-shokunin
**Target:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Target identity at time of attack:** `md5 7a206daa9efe8920a094d62ebbe6fcc9`, 249 lines, mtime `2026-10-18 15:15:52 -0300`
**Lane HEAD:** `c85a816e227984272a3c29b58aa7f7f1a76f1e9c`
**Spec under test:** `reports/round-102/fold-spec.md:156` §A4 — "either (a) print a distinct `CHECK2=BLOCKED`
token with a documented distinct exit code, or (b) accept a pre-cloned reference via `GATE_REF=<path>`.
… with an unreachable `REPO` and no `GATE_REF`, the output must name BLOCKED distinctly from a
`BLOB_DIFFS>0` failure."

**Claim under attack (this seat's contract):** make the clone unreachable *without touching the gate*; the
gate must print the distinct BLOCKED signal and exit 2 — **not** a plain check-2 FAIL and **not** exit 0.

## Verdict — FALSIFIED. The A4 defect stands exactly as folded.

The installed gate has **no distinct BLOCKED channel at all**:

| required by A4 acceptance | observed |
| --- | --- |
| distinct BLOCKED signal on the exit channel | **absent** — `grep -c 'CHECK2=' run_gate.sh` → `0` |
| exit **2** | **absent** — the only exit codes in the file are `1` (line 27, tool-missing) and `0`/`1` (line 249) |
| must not be a plain check-2 FAIL | **violated** — it prints `STEP=FAIL` and exits **1**, byte-identical in shape to a real `BLOB_DIFFS>0` divergence |
| must not exit 0 | satisfied, trivially, because the check fails |

```
$ grep -n 'BLOCKED' corpus/knowledge/unreal-mcp/gate/run_gate.sh
140:    printf 'FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS\n'
$ grep -c 'CHECK2=' corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
$ grep -c 'GATE_REF' corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
$ grep -n 'exit [0-9]' corpus/knowledge/unreal-mcp/gate/run_gate.sh
7:# Exit 0 only if all four pass; exit 1 otherwise (fail-closed).
27:  if ! command -v "$_t" >/dev/null 2>&1; then printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
82:#   the committed reference manifest. Expected: 12 lines, all OK, exit 0,
249:[ "$FAILS" -eq 0 ] && exit 0 || exit 1
```

`BLOCKED` exists only as **prose inside a `FAIL` line**; no parser keying on the token stream can separate
it from a byte mismatch. The gate is therefore air-gapped-unusable: a close-out reader sees
`GATE RESULT: FAIL (checks failed: 1)` and cannot tell "this host had no network" from "the vendored
bytes diverge from the pin".

## Attack construction (gate never modified)

Constraint honoured: the gate script was **never written to** — its md5 is unchanged before, during and
after every run below. The clone was made unreachable purely through the environment of the gate
invocation.

**Primary vector — proxy to a closed port.** `127.0.0.1:1` has no listener, so any HTTP(S) transport
the gate's `git clone` opens is refused at connect time. Set for the run only, never persisted:

```
https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Vector pre-check, proving it really kills the clone (and that the control network is live):

```
$ timeout 60 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
rc=0
$ https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 \
    timeout 60 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
fatal: unable to access 'https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/': Failed to connect to github.com:443 over proxy 127.0.0.1 after 0 ms: Could not connect to server
rc=128
```

**Secondary vector — git-side only, no environment variable.** Same effect through git's own config
channel for the run only (`GIT_CONFIG_*` is process-scoped; nothing is written to any config file):

```
GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=http.proxy GIT_CONFIG_VALUE_0=http://127.0.0.1:1 \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

## Observed output — primary vector (full, verbatim)

```
$ https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7f1a76f1e9c

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
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
fatal: unable to access 'https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/': Failed to connect to github.com:443 over proxy 127.0.0.1 after 0 ms: Could not connect to server
STEP=FAIL

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md       line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
EXIT=1
```

The secondary (git-config-only) vector produces the identical result: same `CHECK 2` block, same
`GATE RESULT: FAIL (checks failed: 1)`, `EXIT=1`.

**Failure mode observed:** `STEP=FAIL` on check 2, `GATE RESULT: FAIL (checks failed: 1)`, **exit 1**.
Not exit 2. Not exit 0. No distinct token.

## Control 1 — same tree, network live (the attack is the only difference)

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
… CHECK 2 …
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
…
CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Only the proxy environment differs between the two runs; check 1 / 3 / 4 output is identical, which
isolates the failure to check 2's clone step.

## Control 2 — the collision the A4 rule forbids (unreachable vs byte mismatch)

To demonstrate the indistinguishability directly, a **scratch copy** of the subtree (under `/tmp`, the
lane tree untouched) was given a real byte divergence *and* left with working network, so check 2 fails
by `BLOB_DIFFS>0` instead of by unreachability:

```
CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB-DIFF README.md
BLOB_DIFFS=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 3)
EXIT=1
```

Side by side, the discriminating token is **identical**:

```
network unreachable  → STEP=FAIL
byte mismatch        → STEP=FAIL
COLLISION: same token, no machine-readable discriminator
$ grep -c 'CHECK2=BLOCKED' attack.raw.txt control.raw.txt mismatch3.raw.txt
attack.raw.txt:0
control.raw.txt:0
mismatch3.raw.txt:0
```

Both exit **1**. A folding seat reading `GATE RESULT: FAIL` cannot recover which condition occurred.

## Non-persistence and non-contamination evidence

```
$ env | grep -i proxy              → (none)          # after all attack runs
$ git config --list --show-origin | grep -i proxy → (none)
$ sha256sum .git/config            → 79d0728dd674269023b87380ff95b8f062d331feeca26513cc01b373361c0e43  (identical before/after)
$ md5sum corpus/knowledge/unreal-mcp/gate/run_gate.sh → 7a206daa9efe8920a094d62ebbe6fcc9  (identical before/after)
$ find . -name run_gate.sh -not -path './.git/*'  → only ./corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

No `git config` write, no persisted environment, no gate edit. The only lane-tree path this seat wrote
is this report.

## Attack-surface note — what was ruled out as a vector (recorded so peers need not retry)

* **`GIT_CONFIG_GLOBAL=<hostile>` for the gate run** — **does not work.** Git sets
  `GIT_CONFIG_LOCAL` to the discovered local config, and the global file is silently ignored when it is
  not under `$HOME`. Verified: the gate stayed green under a hostile global.
* **DNS blackhole** — needs root (`/etc/hosts`, `nsswitch.conf`); not available and out of scope.
* **Network namespace / `unshare`** — not available on this host.
* **Repo-local config write** — *would* work, and is exactly what this seat must **not** do: it persists
  state into `.git/config` and is a silent lane mutation. Rejected; the process-scoped vectors above
  achieve the same falsification with zero residue.

## Boundary — exactly what is and is not proven

* **Proven here:** on this host, at HEAD `c85a816`, against gate md5 `7a206daa…`, an unreachable clone
  yields `STEP=FAIL` + `GATE RESULT: FAIL (checks failed: 1)` + exit 1, with no `CHECK2=` token and no
  exit 2 path anywhere in the file.
* **Not claimed:** any Unreal editor/runtime behaviour — the editor is not installed and no live-MCP
  path is exercised by this seat. No claim about upstream content beyond the pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
* **Not fixed by this seat:** A4 is a *finding* seat; no repair is attempted and none is proposed as
  applied. The fix (a distinct `CHECK2=BLOCKED` token + declared exit 2, or the `GATE_REF` bypass) is
  owned by whichever seat holds the A4 repair.

## Raw artefacts

| file | contents |
| --- | --- |
| `/tmp/r103-a4/attack.raw.txt` | primary vector, full 50-line gate output (exit 1) |
| `/tmp/r103-a4/attack.exit.txt` | `EXIT=1` |
| `/tmp/r103-a4/attack2.raw.txt` | secondary git-config-only vector, full output (exit 1) |
| `/tmp/r103-a4/control.raw.txt` | network-live control, full output (exit 0) |
| `/tmp/r103-a4/control.exit.txt` | `EXIT=0` |
| `/tmp/r103-a4/mismatch3.raw.txt` | byte-mismatch collision control, full output (exit 1) |
| `/tmp/r103-a4/live2.raw.txt` | re-run of the live tree after the attacks |
