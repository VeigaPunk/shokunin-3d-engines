# SEAT-47 GATE-FINAL-RUN — r105 live-tree gate

**Run at:** `2026-10-18T20:31:00Z` (UTC)  
**Lane HEAD:** `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`  
**Gate script:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`  
**Gate script SHA-256:** `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`

## Invocation and result

The live-tree gate was run with the required repo-local scratch root:

```sh
GATE_WORKDIR="$PWD/reports/round-105/gate/scratch" corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Observed process return code: `0`.** All four checks printed `STEP=PASS`. CHECK 2 used a real fresh clone (no `GATE_REF` was supplied). Standard error was empty.

## Full stdout

```text
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-105/gate/scratch (from GATE_WORKDIR)
WORK_ROOT_FREE=765G of 930G (17% used)
LANE_HEAD=1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b

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
```

**Process result:** `RC=0`  
**Standard error:** empty (`reports/round-105/gate/scratch/gate-run.stderr`, 0 bytes)

## Durable raw artifacts

- `reports/round-105/gate/scratch/gate-run.stdout` — complete gate stdout above
- `reports/round-105/gate/scratch/gate-run.stderr` — empty stderr capture
- `reports/round-105/gate/scratch/gate-run.rc` — `0`

This is a static close-out gate only; it does not establish Unreal Editor or runtime behavior.
