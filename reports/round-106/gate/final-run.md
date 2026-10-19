# SEAT-70 GATE-FINAL — r106 live-tree gate

**Run at:** `2026-10-18T21:20:13Z` (UTC; command start)  
**Lane HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (branch `main`)  
**Gate script:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`  
**Gate script SHA-256:** `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`

Same scanner sha as the r105 final receipt (`reports/round-105/gate/final-run.md`). No edits to the gate script or to the unreal-mcp subtree by this seat.

## Invocation and result

Scratch root created first (`mkdir -p reports/round-106/gate/scratch`), then the live-tree gate with the required repo-local workdir (not `/tmp` — host per-user `/tmp` quota is exhausted):

```sh
GATE_WORKDIR="$PWD/reports/round-106/gate/scratch" corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Observed process return code: `0`.** All four checks printed `STEP=PASS`. CHECK 2 used a real fresh clone (no `GATE_REF` was supplied). Standard error was empty (0 bytes). Wall time of the invocation was under 1 s (0.882 s). After exit, scratch held only the three capture files — the clone workdir was removed by the script's EXIT trap (`residual` = the three captures only).

Pinned summary lines all matched the gate README's expected block: `MANIFEST_OK=12`, clone HEAD = pin `a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`, `CARDS=13 BAD=0`, census `12/1/0`, `NAME_SET=OK`, `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`.

This is a static close-out gate only. It does not establish Unreal Editor or runtime behavior. Unreal Editor is not installed on this host; `verified-here` remains 0.

## Full stdout

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
**Standard error:** empty (`reports/round-106/gate/scratch/gate-run.stderr`, 0 bytes; sha256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`)

## Durable raw artifacts

- `reports/round-106/gate/scratch/gate-run.stdout` — complete gate stdout above (56 lines, 2137 bytes, sha256 `c69c93614b99db75047bb174b0406323fb9801d400e055f8eaf12e5b3c159c2b`)
- `reports/round-106/gate/scratch/gate-run.stderr` — empty stderr capture
- `reports/round-106/gate/scratch/gate-run.rc` — `0` (sha256 `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa`)
