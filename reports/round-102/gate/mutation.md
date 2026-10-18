# SEAT-18 GATE-MUTATION — mutation testing of the r102 unreal-mcp close-out gate

- Seat: **SEAT-18 GATE-MUTATION** (r102)
- Lane: `game-dev-3d-shokunin`
- Owned path: `reports/round-102/gate/mutation.md` (this file, only)
- Date: 2026-10-18
- Repo HEAD at run: `2c99b7b8155841617d844c609813afcba77aa207`
- Gate under test: `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
  - sha256 `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`
  - spec `gate/README.md` sha256 `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`
- Method: copy the live subtree to `/tmp/r102mut/case`, plant **one** mutation at a time,
  run the gate, record exit code and which `STEP=` lines FAIL. **The repository is never
  modified** — all work happens under `/tmp/r102mut`. Harness: `/tmp/r102mut_harness.sh`.

## Verdict

**The gate is mutation-robust.** Control (unmutated copy) exits 0 with all four checks
`PASS`. Each of the five required mutations makes the gate exit 1, and in every case at
least one of the four checks reports `STEP=FAIL`. Two extra probes (M6 pointer corruption,
M4b total label-token removal) also behave correctly. No mutation produced a false PASS.

## Summary matrix

| Case | Mutation | exit | CHK1 manifest | CHK2 clone | CHK3 cards | CHK4 pointer |
|---|---|---|---|---|---|---|
| C0 | none (control) | **0** | PASS | PASS | PASS | PASS |
| M1 | flip a byte in `upstream/README.md` | **1** | **FAIL** | **FAIL** | PASS | PASS |
| M2 | add extra file under `upstream/` | **1** | PASS | **FAIL** | PASS | PASS |
| M3 | delete card `executability/sequencer.md` | **1** | PASS | PASS | **FAIL** | PASS |
| M4 | strip verdict label from `blueprints.md` | **1** | PASS | PASS | **FAIL** | PASS |
| M5 | corrupt one manifest line | **1** | **FAIL** | PASS | PASS | PASS |
| M6 | point a card at `upstream/DOES-NOT-EXIST.md:3` | **1** | PASS | PASS | PASS | **FAIL** |
| M4b | remove **all** label tokens from `blueprints.md` | **1** | PASS | PASS | **FAIL** | PASS |

Notes on the diagonal (each mutation hits the check it targets):
- **M1** trips both CHK1 and CHK2 — correct: the manifest is byte-identity vs the
  committed reference, and CHK2 compares blobs vs a fresh clone. A flipped byte breaks both.
- **M3/M4** trip CHK3 with different sub-failures (`CARDS=12 EXPECTED=13` vs
  `label-too-deep`/`no-label`), so the two card defects are distinguishable.
- **M2** correctly leaves CHK1 untouched (the extra file is not in the manifest) and is
  caught only by CHK2's path-set equality (`PATH_EXTRA=1`).

## Captured outputs (verbatim)

Each block is the complete stdout+stderr of `bash gate/run_gate.sh` run from inside the
mutated copy at `/tmp/r102mut/case`.

### C0 — control, unmutated copy — exit 0

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
```

### M1 — flip a byte in `upstream/README.md` — exit 1

Byte 0 of `upstream/README.md` XORed with `0x01`.

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: FAILED
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
sha256sum: WARNING: 1 computed checksum did NOT match
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFF README.md
BLOB_DIFFS=1
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
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 2)
```

### M2 — add extra file `upstream/PLANTED-EXTRA.md` — exit 1

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
PATH_EXTRA=1 PATH_MISSING=0
FAIL vendored file not tracked upstream (see above)
BLOB_DIFFS=0
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
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

### M3 — delete `executability/sequencer.md` — exit 1

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=12 EXPECTED=13 BAD=0
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL

CHECK 4 pointer-sweep
POINTERS=33 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

Note: deleting the card also drops the pointer count from 40 to 33 — the missing card's
own pointers are gone with it, so CHK4 stays PASS. The deletion is still caught by CHK3.

### M4 — strip the `**Label:**` line from `executability/blueprints.md` — exit 1

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
FAIL label-too-deep /tmp/r102mut/case/executability/blueprints.md (line 97)
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=1
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

The sub-failure is `label-too-deep (line 97)`: with the declared label line removed, the
scanner falls through to the next line carrying an allowed token (a prose mention deep in
the card). Either way the card is counted `BAD`, and the census drops to 11 `static-only`.

### M5 — corrupt one manifest line (`.manifest.d/audit-reference.sha256`) — exit 1

First data line's leading hex zeroed, so the stored hash no longer matches the file.

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: FAILED
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
sha256sum: WARNING: 1 computed checksum did NOT match
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL

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
OK   static-only      sequencer.md                  line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

CHK2 stays PASS — correct: the *tree* is unmodified, only the reference manifest is
wrong, so blob comparison vs the clone still matches. CHK1 is the check that owns
manifest integrity, and it catches this alone.

### M6 — repoint a card pointer to a non-existent upstream path — exit 1

Extra probe (not in the required five). In `executability/sequencer.md`,
`upstream/README.md:3` → `upstream/DOES-NOT-EXIST.md:3`.

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
OK   static-only      sequencer.md                  line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
MISSING-PATH /tmp/r102mut/case/executability/sequencer.md :: upstream/DOES-NOT-EXIST.md:3
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL

GATE RESULT: FAIL (checks failed: 1)
```

CHK4 alone catches it — the pointer sweep is the only check that reads card prose
pointers, so a broken pointer cannot hide behind the other three.

### M4b — remove *all* label tokens from `executability/blueprints.md` — exit 1

Extra probe (not in the required five). Every `verified-here` / `static-only` /
`unproven-runtime` token replaced with `REDACTED`.

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r102mut/case
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
FAIL no-label       /tmp/r102mut/case/executability/blueprints.md
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=1
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

This is the complementary card mutation to M4: with no allowed token anywhere in the
card, the scanner reports `no-label` rather than `label-too-deep`. Both paths count the
card `BAD` and fail CHK3.

## How each mutation was planted (reproducible)

All commands run from `/tmp/r102mut`, against `case/` (a `cp -a` of the live subtree):

```bash
BASE=/tmp/r102mut
SRC=<repo>/corpus/knowledge/unreal-mcp
fresh() { rm -rf "$BASE/case"; cp -a "$SRC" "$BASE/case"; }

# M1
fresh; python3 -c "p='$BASE/case/upstream/README.md'; b=bytearray(open(p,'rb').read()); b[0]^=1; open(p,'wb').write(b)"
# M2
fresh; printf 'planted extra file (SEAT-18 mutation M2)\n' > "$BASE/case/upstream/PLANTED-EXTRA.md"
# M3
fresh; rm -f "$BASE/case/executability/sequencer.md"
# M4   (strip the '**Label:**' line)
fresh; python3 -c "import re;p='$BASE/case/executability/blueprints.md';t=open(p).read();open(p,'w').write(re.sub(r'^\*\*Label:\*\*.*$','',t,count=1,flags=re.M))"
# M5   (corrupt first data line of the manifest)
fresh; python3 -c "p='$BASE/case/.manifest.d/audit-reference.sha256';L=open(p).read().splitlines(keepends=True);i=next(k for k,l in enumerate(L) if l.strip() and not l.lstrip().startswith('#'));L[i]='0'*64+L[i][64:];open(p,'w').write(''.join(L))"
# M6
fresh; python3 -c "import re;p='$BASE/case/executability/sequencer.md';t=open(p).read();open(p,'w').write(t.replace('upstream/README.md:3','upstream/DOES-NOT-EXIST.md:3',1))"
# M4b
fresh; python3 -c "import re;p='$BASE/case/executability/blueprints.md';t=open(p).read();open(p,'w').write(re.sub(r'(verified-here|static-only|unproven-runtime)','REDACTED',t))"

# run the gate in each case
( cd "$BASE/case" && bash gate/run_gate.sh ); echo "exit=$?"
```

Harness script: `/tmp/r102mut_harness.sh` (does the same for C0, M1–M5 and writes
per-case stdout + exit code into `/tmp/r102mut/out/`).

## Positive control on the live tree

The mutations ran against a `/tmp` copy. As a sanity check that the copy is faithful,
the gate was also run once directly in the repository subtree
(`cd corpus/knowledge/unreal-mcp && bash gate/run_gate.sh`):

```
exit=0
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

So the gate passes on the real tree and fails on each planted defect — the mutation
matrix is measuring the gate, not an artifact of the copy.

## Repository untouched — evidence

- The seat wrote **only** this file. The subtree copy was made under `/tmp`; `case/` is
  destroyed and re-created per mutation, and nothing was written back.
- `git status --short` after the run shows the same foreign modifications present before
  the run (other seats' `F1/F2/F3/F5/F6` repairs, the F8 README wording fold, and the
  C1a seat's new `gate/` dir) — no new path attributable to SEAT-18.
- `git diff --stat HEAD -- corpus/knowledge/unreal-mcp/` shows only
  `corpus/knowledge/unreal-mcp/README.md` (the F8 wording fold owned by another seat),
  i.e. SEAT-18 changed nothing under the subtree.

## Scope / honesty statement

No Unreal runtime claim is made here. This seat tested the **gate**, not the engine: the
gate's four checks are static (sha256, clone/path/blob comparison, grep-based card and
pointer scans). That Unreal Editor is absent on this host is by construction; nothing in
this report asserts live-editor or live-MCP behavior. The gate itself passes on the
unmutated tree, and fails on each planted defect — that is the whole of the claim.
