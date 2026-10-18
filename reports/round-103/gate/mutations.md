# SEAT-19 MUTATION-CROSS — 3 classic mutations vs the installed close-out gate

Round r103, seat 19. Date 2026-10-18.

**Seat claim.** Plant three classic mutations — (M1) a 1-byte flip in a vendored
file, (M2) deletion of a verdict card, (M3) corruption of one manifest line — on
a `/tmp` copy, run the **current** gate (`corpus/knowledge/unreal-mcp/gate/run_gate.sh`)
against each, and show that every one is detected. Nothing in the live repo is
mutated: every mutation is applied to a throwaway copy, and the live repo is only
ever read.

**Frozen artifact under test.** All four runs below (M0 control + M1–M3) executed
against one unchanged gate binary.

| item | value |
|---|---|
| gate | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` |
| gate sha256 | `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96` |
| gate mtime | `2026-10-18 15:15:52 -0300` |
| lane HEAD | `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` |
| upstream pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| gate tracked-clean? | yes — `git diff --stat -- .../gate/run_gate.sh` is empty; gate mtime predates this seat's first run |

**Harness.** `/tmp/r103-mut/mutate.sh`. For each case it builds a fresh copy of
the pinned subtree (`tar` of `corpus/knowledge/unreal-mcp` plus the repo-relative
files the gate's own pointer sweep resolves), stubs any still-dangling
repo-relative pointer target so that a peer's concurrent edit cannot move the
result, applies the mutation, and runs the gate from the copy's root. The gate
itself is copied byte-for-byte, not adapted — `sha256sum` of the copy equals the
live gate hash above.

---

## Result summary

| case | mutation | detected? | gate exit | checks failed |
|---|---|---|---|---|
| **M0** | none (control) | must stay PASS | `0` | 0 — `GATE RESULT: PASS` |
| **M1** | 1-byte flip, `upstream/skills/unreal-mcp/SKILL.md` | **yes** | `1` | 3 (per-seat manifest sweep, CHECK 1, CHECK 2) |
| **M2** | delete `executability/materials.md` | **yes** | `1` | 2 (CHECK 3, CHECK 4) |
| **M3** | corrupt one line of `.manifest.d/audit-reference.sha256` | **yes** | `1` | 2 (per-seat manifest sweep, CHECK 1) |

Every planted mutation is detected; the unmutated control in the same harness run
still prints `GATE RESULT: PASS` and exits `0`. Re-running the harness reproduced
the same verdicts.

The M0 control is what makes M1–M3 meaningful: it rules out "the gate fails on
this copy for unrelated reasons", so each FAIL below is attributable to the
planted mutation alone.

Per-mutation detection notes:

- **M1** is caught *three* independent ways — the per-seat `--strict` manifest
  sweep, CHECK 1 byte-identity, and CHECK 2's blob diff against the fresh clone.
  The blob diff is the load-bearing one: it would still fire if the manifest had
  been regenerated from the corrupted tree.
- **M2** is caught two independent ways — CHECK 3's card inventory
  (`CARDS=12 EXPECTED=13`, census `static-only=11`) and CHECK 4's dangling-pointer
  sweep (`MISSING-PATH-REL executability/materials.md`), which finds the card
  referenced from prose after the file itself is gone.
- **M3** is caught by the per-seat sweep and CHECK 1. Note CHECK 2 stays `PASS`:
  corrupting the *manifest* does not touch the tree, so the blob diff is correctly
  silent. The manifest is not self-authenticating here — the per-seat manifests
  are what catch a corrupted `audit-reference.sha256`.

---

## M0 — control, no mutation (expected PASS, exit 0)

```
GATE unreal-mcp subtree
SUBTREE=/tmp/r103-mut/tree/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

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
EXIT=0
```

---

## M1 — 1-byte flip in a vendored file

Applied at `upstream/skills/unreal-mcp/SKILL.md`, byte offset 200 (0-based):

```
flip @offset 200: 0x20 ' ' -> 0x21 '!'
orig sha256 7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa
mut  sha256 88bed599fbe7c8a51dbe545dc1478f8bf63bf4769036e7f5d8689de0ddb32b3b
/tmp/r103-mut/m1.orig /tmp/r103-mut/tree/.../SKILL.md differ: byte 201, line 3
cmp: differ at byte 201 line 3 (1 byte changed)
```

The mutation is exactly one byte: `cmp` reports the first difference at byte 201
(1-based) and the two hashes differ; the original hash equals the value pinned in
`.manifest.d/audit-reference.sha256` for that path. Gate output (excerpts; full
run in `/tmp/r103-mut/m1.out`):

```
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
  upstream/.claude-plugin/plugin.json: OK
  ...
  upstream/skills/unreal-mcp/SKILL.md: FAILED
  ...
  sha256sum: WARNING: 1 computed checksum did NOT match
  upstream/skills/unreal-mcp/SKILL.md: FAILED
  sha256sum: WARNING: 1 computed checksum did NOT match
CHECK 1 manifest-byte-identity
...
upstream/skills/unreal-mcp/SKILL.md: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB-DIFF skills/unreal-mcp/SKILL.md
BLOB_DIFFS=1
STEP=FAIL

CHECK 3 verdict-card-scan
...
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 3)
EXIT=1
```

**Detected.** Three checks fail. CHECK 3 and CHECK 4 correctly stay green — the
mutation is invisible to a card scan and to a pointer sweep, which is the point:
the byte-level checks carry it alone.

---

## M2 — delete a verdict card

`executability/materials.md` removed; 13 cards on disk become 12:

```
cards on disk: 12
```

Gate output (full run in `/tmp/r103-mut/m2.out`):

```
CHECK 1 manifest-byte-identity
...
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
...
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=12 EXPECTED=13 BAD=0
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL

CHECK 4 pointer-sweep
MISSING-PATH-REL executability/materials.md
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL

GATE RESULT: FAIL (checks failed: 2)
EXIT=1
```

**Detected.** Two checks fail. `materials.md` is absent from the `OK` list, the
card count drops to 12, and the census drops to `static-only=11`. CHECK 4 catches
the same deletion from the other side — the file is still cited in prose, so the
backtick-pointer sweep reports `MISSING-PATH-REL`.

Note CHECK 1 and CHECK 2 stay green: the deleted card is *not* a vendored
upstream file, so it is correctly outside the manifest's scope. A card deletion is
only ever visible to CHECK 3 / CHECK 4 — which is exactly where it fires.

---

## M3 — corrupt one manifest line

First byte of the `upstream/LICENSE` digest flipped in
`.manifest.d/audit-reference.sha256` (`5b337be0…` → `fb337be0…`):

```
before: 5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  upstream/LICENSE
after : fb337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  upstream/LICENSE
```

Gate output (excerpts; full run in `/tmp/r103-mut/m3.out`):

```
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
  upstream/.claude-plugin/plugin.json: OK
  upstream/CODEOWNERS: OK
  upstream/.gitignore: OK
  upstream/hooks/hooks.json: OK
  upstream/hooks/unreal-context.sh: OK
  upstream/LICENSE: FAILED
  upstream/README.md: OK
  ...
  sha256sum: WARNING: 1 computed checksum did NOT match
CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: FAILED
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
...
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 2)
EXIT=1
```

**Detected.** Two checks fail: the per-seat sweep and CHECK 1, both naming the
`upstream/LICENSE` line. CHECK 2 is correctly silent — the vendored tree is
untouched, so the blob diff has nothing to say. This is the case that motivates
the per-seat manifest sweep: corrupting the audit manifest itself is caught by
the seat manifests, not by re-reading the manifest that was corrupted.

---

## Cross-check: pointer count moved 87 → 90 during this seat

The seat brief cites the r102 close state as `POINTERS=87`; this seat's baseline
control prints `POINTERS=90 UNRESOLVED=0`. That is **not** gate drift — the gate
binary is unchanged (`412d1b84…`, mtime predates the first run). The count moved
because `corpus/knowledge/unreal-mcp/adaptation-kimi.md` was edited in the working
tree by a concurrent peer seat while this seat ran. `git status --porcelain` shows
it modified; its pointer-bearing path set grew from 15 (at HEAD) to 19 (worktree),
a delta of three new repo-relative pointers plus one `/tmp` path the sweep ignores:

```
7,9d6
< PROVENANCE.md:19
< reports/round-103/note/author.md
< reports/round-103/note/urls.md
11d7
< /tmp/kimi_strings.txt
```

The binding invariant documented in `gate/README.md` §CHECK 4 is `UNRESOLVED=0`,
which holds here; the absolute count is scanner-relative and explicitly not to be
compared across time. Recorded so that a later reader comparing 87 against 90 does
not mistake a peer's prose edit for a gate regression.

## Caveats

- No Unreal runtime claim is made or implied. The editor is not installed on this
  host; these are static checks over vendored bytes, and live MCP remains unproven
  by construction. Nothing in this seat exercises the Unreal editor or MCP.
- CHECK 2 needs network access for its fresh clone. All four runs above reached the
  clone and reported `CLONE_HEAD=a6aa73ad…` equal to the pin; had the clone been
  unreachable, the run would have been BLOCKED, not PASS.
- The copy is deliberately trimmed to the pinned subtree plus the repo-relative
  pointer targets, so this harness does not exercise a peer's concurrent edits
  outside those paths. That trimming is what keeps M0 a clean control; it does not
  weaken M1–M3, which mutate inside the subtree.
- Raw gate transcripts from the run: `/tmp/r103-mut/{m0,m1,m2,m3}.out`, harness
  `/tmp/r103-mut/mutate.sh`, combined log `/tmp/r103-mut/run.log`. These are
  `/tmp` artifacts and will not survive a reboot; the pasted outputs above are the
  durable record.
