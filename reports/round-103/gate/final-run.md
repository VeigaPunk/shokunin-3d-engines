# SEAT-53 — GATE-RERUN-RECEIPT — final run on the live tree

Round r103. Seat artifact: `reports/round-103/gate/final-run.md`.
Command run (verbatim, from the lane root `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`):

```
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Runtime: **2026-10-18T18:33:32Z** (UTC) / 15:33 local (-0300).

## Tree state at run time

```
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c   (r102 report-last)
PIN      =a6aa73ada02a9fb1f5415bec491f9942c519b297   (upstream plugin)
```

Hashes of the two files that determine the gate's own behaviour and its scanned
pointer set, captured immediately before **and** immediately after the run — identical,
so this transcript is reproducible against these bytes:

```
084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879  corpus/knowledge/unreal-mcp/adaptation-kimi.md
412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96  corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

`git status --porcelain` at run time:

```
 M corpus/artifacts/unity-r19/README.md          (peer seat, outside the scanned subtree)
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md (peer seat, INSIDE the scanned subtree)
?? reports/round-103/
```

`adaptation-kimi.md` is dirty because C1's freshness-note seat is writing it in
parallel with this seat. It is in the check-4 scan set, which is why the pointer
count below is **not** the committed value — see "Pointer count" further down.

## Full output (verbatim, `rc` appended)

```
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c

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
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

**rc = 0.** All four checks `STEP=PASS`. No Unreal runtime claim is made or
implied: the editor is not installed on this host, so the strongest statement
available is that the vendored bytes are byte-identical to the pinned upstream
commit and that these static checks ran here.

## Pointer count — `POINTERS=90` is a live-tree value, not the committed one

The count is scanner-relative by design (`gate/README.md:118`) and, unlike the
other three checks, it is computed over a **dirty** tree: `adaptation-kimi.md` was
being rewritten by C1's seat during this run. Three serial reruns minutes apart
read `88`, `89`, then `90` as that file grew; `UNRESOLVED=0` throughout.

To separate live drift from a defect I ran the gate against a pristine `git archive HEAD`
extracted to a scratch dir (nothing of round-103 present):

```
git archive HEAD | tar -x -C /tmp/seat53-head
bash /tmp/seat53-head/corpus/knowledge/unreal-mcp/gate/run_gate.sh
  → POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   STEP=PASS
  → GATE RESULT: PASS (checks failed: 0)                    rc=0
```

Two consequences, both stated as observed:

1. **`gate/README.md:118`'s pinned `POINTERS=87` is stale.** On the committed tree
   the gate emits `88`. The README text already declares the count
   scanner-relative and the binding invariant to be `UNRESOLVED=0`, so this is a
   doc-value drift, not a gate defect — but the literal `87` does not reproduce.
   Fixing it is outside this seat's write scope; routed as a finding.
2. **`POINTERS=90` in the transcript above is the live working tree**, which is the
   tree the seat was asked to gate. It is stable across repeated serial runs as
   long as the tree is unchanged (verified: 3 consecutive runs, all `90` / `rc=0`).

## Concurrency finding — an honest FAIL, not a flake

Four gate runs launched in parallel against the live tree all exited **1** with
`checks failed: 1` and:

```
CHECK 4 pointer-sweep
MISSING-PATH-REL reports/round-103/note/author.md
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
```

Cause, confirmed by inspection: a peer seat had written the pointer
`reports/round-103/note/author.md` into `corpus/knowledge/unreal-mcp/adaptation-kimi.md:372`
**before** that target file existed. The file appeared a minute later
(`reports/round-103/note/author.md`, mtime 15:33), after which the same run passes.
This is check 4 working correctly — it caught a genuinely dangling pointer in the
scanned set. It is recorded here because a reader comparing transcripts will
otherwise see a FAIL against a PASS for the same command.

Corollary for readers of any r103 gate transcript: because check 4 scans the whole
subtree and peers hold uncommitted edits there, **two r103 gate transcripts taken
minutes apart are not expected to agree on `POINTERS=`**, and a peer's half-written
pointer can turn a clean run red. The invariant that must hold is `UNRESOLVED=0`
plus `rc=0`.

## Gate defect found while isolating the above (not in this seat's write scope)

`run_gate.sh:65` redirects to a **hardcoded** path:

```sh
if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/advgate/.h1 2>&1); then
```

`/tmp/advgate` is a scratch dir created by an earlier round's attack harness; it is
not created by the gate. When it is absent the redirect itself fails (bash reports
`No such file or directory` and returns 1 *before* `sha256sum` runs), and the
`if !` reads that as a manifest-sweep failure. Demonstrated on a copy with the path
pointed at a non-existent directory:

```
/tmp/seat53-iso/.../run_gate.sh: line 65: /tmp/seat53-NOSUCHDIR/.h1: No such file or directory
sed: can't read /tmp/seat53-NOSUCHDIR/.h1: No such file or directory
FAIL per-seat manifest sweep (--strict) failed:
...
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
...
GATE RESULT: FAIL (checks failed: 1)     rc=1
```

Note the contradiction inside one transcript: `MANIFEST_OK=12 … FAILED=0` yet the
hardening line prints `FAIL` — the twelve manifest files are fine and the "failure"
is purely the missing scratch dir. On a clean host (no `/tmp/advgate`) this gate
would report FAIL for a healthy tree. Suggested repair for whoever owns the gate:
write to `$WORK/.h1` (the `mktemp -d` dir already created at line 75) or to
`$(mktemp)`, and move the `WORK=$(mktemp -d)` line above the hardening block.

## What this seat did not do

- Did not modify `run_gate.sh`, `gate/README.md`, or any protected path — read-only
  against them, per the seat's write scope.
- Did not fix the stale `87` or the `/tmp/advgate` dependency; both are reported
  above for the seats that own those files.
- Made no Unreal runtime claim (editor not installed; live-MCP unproven by
  construction).
