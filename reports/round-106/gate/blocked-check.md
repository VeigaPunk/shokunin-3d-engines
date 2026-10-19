# SEAT-110 CLOSE-GATE-BLOCKED — r106 two negative paths

**Seat:** SEAT-110 CLOSE-GATE-BLOCKED · round 106 · lane `game-dev-3d-shokunin`
**Owned path:** this file (`reports/round-106/gate/blocked-check.md`). Receipt captures also written under `reports/round-106/gate/scratch/a4-dead-repo.{stdout,stderr}` and `reports/round-106/gate/scratch/bad-gate-ref.{stdout,stderr}`. No other file was written. The gate script and the unreal-mcp subtree were not edited.
**Date:** 2026-10-18 · command start `2026-10-18T21:20:48Z` (UTC)
**Lane HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (both runs print this as `LANE_HEAD`)
**Gate script:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Gate script SHA-256:** `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (unchanged after both runs; same scanner sha as `reports/round-105/gate/final-run.md` and as SEAT-70's r106 clean run in `reports/round-106/gate/final-run.md`)

**No Unreal runtime claim.** Unreal Editor is not installed on this host. These two runs are exit-code controls on CHECK 2's clone path. A BLOCKED result means the vendored bytes were **unchecked**, not divergent, and must never be cited as live-editor evidence. Upstream pin printed by both runs: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

**Question assigned:** the two negative paths documented at close.

1. `REPO` override to a dead URL, no `GATE_REF` — expect exit **2** `BLOCKED`.
2. `GATE_REF=/dev/shm-nonexistent` — expect **FAIL** exit **1**. A bad ref is a real FAIL, not BLOCKED.

Scratch was `GATE_WORKDIR=$PWD/reports/round-106/gate/scratch` (756G of 930G free, 18% used). `/tmp` was not used (host per-user quota exhausted). Both stderr captures are 0 bytes. The EXIT trap left no clone workdir from either run (`find reports/round-106/gate -name .git -type d` empty). `/dev/shm-nonexistent` was absent before and after (`test ! -e` → `GATE_REF_PATH_ABSENT=yes` / `ABSENT`).

A sibling seat (SEAT-70) had already recorded a clean live-tree PASS on this same scanner and HEAD at `2026-10-18T21:20:13Z`: `GATE RESULT: PASS (checks failed: 0)`, `RC=0`, `POINTERS=103 … UNRESOLVED=0`, fresh clone, no `GATE_REF` (`reports/round-106/gate/final-run.md`, receipt `reports/round-106/gate/scratch/gate-run.rc` = `0`). This seat did not re-run that positive path.

## Result

| path | setup | expected | observed | match |
|---|---|---|---|---|
| **N1** dead `REPO` | `REPO=https://invalid.example.invalid/unreal-engine-skills-does-not-exist`, `GATE_REF` unset, roomy `GATE_WORKDIR` | exit **2**, `CHECK 2 BLOCKED (network)`, `GATE RESULT: BLOCKED` | **RC=2**; `CHECK 2 BLOCKED (network)`; `STEP=BLOCKED`; `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` | yes |
| **N2** bad `GATE_REF` | `GATE_REF=/dev/shm-nonexistent`, `REPO` unset (`env -u REPO`), roomy `GATE_WORKDIR` | exit **1**, `STEP=FAIL`, not BLOCKED | **RC=1**; `FAIL GATE_REF is not a git clone: /dev/shm-nonexistent`; `STEP=FAIL`; `GATE RESULT: FAIL (checks failed: 1)`; no `BLOCKED` line | yes |

Classification held on N1: the header is `CHECK 2 BLOCKED (network)`, not `CHECK 2 BLOCKED (local-resource)`. Cause line from the in-memory clone log: `fatal: unable to access 'https://invalid.example.invalid/unreal-engine-skills-does-not-exist/': Could not resolve host: invalid.example.invalid`. Checks 1, 3, and 4 still ran and passed on both paths (`MANIFEST_OK=12`, census `12/1/0`, `NAME_SET=OK`, `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`). N2 never attempted a clone (`GATE_REF=/dev/shm-nonexistent (offline reference; no clone attempted)`), so a missing ref was not folded into the network-BLOCKED state.

## Commands actually run

```sh
mkdir -p reports/round-106/gate/scratch
date -u +%Y-%m-%dT%H:%M:%SZ          # 2026-10-18T21:20:40Z
git rev-parse HEAD                   # 0cc3f4162f8c319f8d01a69a174fe939f36701bd
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
# 390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
test ! -e /dev/shm-nonexistent && echo GATE_REF_PATH_ABSENT=yes

# N1 — dead URL. Observed A4_RC=2. stderr 0 bytes.
REPO='https://invalid.example.invalid/unreal-engine-skills-does-not-exist' \
GATE_WORKDIR="$PWD/reports/round-106/gate/scratch" \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  >reports/round-106/gate/scratch/a4-dead-repo.stdout \
  2>reports/round-106/gate/scratch/a4-dead-repo.stderr
echo "A4_RC=$?"

# N2 — nonexistent GATE_REF. Observed BADREF_RC=1. stderr 0 bytes.
env -u REPO \
GATE_REF='/dev/shm-nonexistent' \
GATE_WORKDIR="$PWD/reports/round-106/gate/scratch" \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  >reports/round-106/gate/scratch/bad-gate-ref.stdout \
  2>reports/round-106/gate/scratch/bad-gate-ref.stderr
echo "BADREF_RC=$?"
```

Post-check (`2026-10-18T21:21:44Z`): script sha unchanged, HEAD unchanged, `/dev/shm-nonexistent` still absent, both stderr files 0 bytes, no residual `.git` under `reports/round-106/gate`.

## Full stdout — N1 dead REPO (RC=2)

```text
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/gate/scratch (from GATE_WORKDIR)
WORK_ROOT_FREE=756G of 930G (18% used)
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd

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
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
fatal: unable to access 'https://invalid.example.invalid/unreal-engine-skills-does-not-exist/': Could not resolve host: invalid.example.invalid
STEP=BLOCKED

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

GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
```

## Full stdout — N2 bad GATE_REF (RC=1)

```text
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/gate/scratch (from GATE_WORKDIR)
WORK_ROOT_FREE=756G of 930G (18% used)
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd

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
GATE_REF=/dev/shm-nonexistent (offline reference; no clone attempted)
FAIL GATE_REF is not a git clone: /dev/shm-nonexistent
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

GATE RESULT: FAIL (checks failed: 1)
```

## Judgment

Both negative paths match the close contract on scanner `390a25ae…` at HEAD `0cc3f41`. Dead `REPO` is exit 2 BLOCKED (network), not a disk-quota misclassification and not a FAIL. A nonexistent `GATE_REF` is exit 1 FAIL, not BLOCKED. No defect queued. No corpus edit. The mixed case (BLOCKED plus another failing check → exit 1, third state lost) was not re-probed; it remains the residual already recorded in `gate/README.md` and `reports/round-103/gate/exit-codes.md`.
