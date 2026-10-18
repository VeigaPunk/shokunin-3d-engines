# F8 — `corpus/knowledge/unreal-mcp/README.md` "12 lines" ambiguity, repaired

- Seat: **SEAT-28 SUBTREE-README-FIX**. Owned path: `corpus/knowledge/unreal-mcp/README.md` (only).
- Round: r102. Repo HEAD at seat start: `2c99b7b` (`2c99b7b8155841617d844c609813afcba77aa207`).
- Working dir: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
- Source finding: r101 critic F8 — `reports/round-101/r101-critic-c3.md:365-381` ("The README's own
  sweep command does not produce the 12 lines it prints").
- Discipline: this is a mechanical command/count conformance fix applied **in place** (the text
  named a command that does not produce the line count printed beneath it). No historical factual
  claim was rewritten, so no dated correction note is required. `upstream/` and `.manifest.d/`
  were not touched; no other file was modified.

## Defect

`README.md:169-170` (at HEAD) named the glob command:

> `sha256sum -c .manifest.d/*.sha256` → all `OK`, exit `0` (run here; output reproduced below).

and `README.md:187` captioned the block beneath it:

> Observed output of the sweep (**12 lines**, all `OK`):

The glob prints **24** `OK` lines, not 12. The block displayed is the 12-line
`audit-reference.sha256` subset, but the command printed above it is the glob. The conclusion
("all `OK`, exit `0`") is correct; the count does not match the named command.

## BEFORE (reproduced) — both commands run from `corpus/knowledge/unreal-mcp/`

`audit-reference.sha256` alone prints 12 lines:

```
$ sha256sum -c .manifest.d/audit-reference.sha256
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
exit=0
$ sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK'
12
```

The `*.sha256` glob prints 24 lines over 12 distinct files:

```
$ sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK'
24
$ sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c 'FAILED'
0
$ sha256sum -c .manifest.d/*.sha256 2>&1 | sed 's/: OK$//' | sort -u | wc -l
12
exit=0
```

Why 24 and not 12: the 12 tracked files are each listed twice — once in `audit-reference.sha256`
(12 entries) and once in the seat shards. The 11 shard files (`seat01`…`seat11`) total **12**
entries because `seat11.sha256` covers two files (`upstream/CODEOWNERS`, `upstream/.gitignore`).
Verified per-file multiplicity:

```
$ cat .manifest.d/*.sha256 | grep -E '^[0-9a-f]{64}' | awk '{print $2}' | sort | uniq -c
      2 upstream/.claude-plugin/plugin.json
      2 upstream/CODEOWNERS
      2 upstream/.gitignore
      2 upstream/hooks/hooks.json
      2 upstream/hooks/unreal-context.sh
      2 upstream/LICENSE
      2 upstream/README.md
      2 upstream/skills/create-toolset/SKILL.md
      2 upstream/skills/unreal-mcp/references/operations.md
      2 upstream/skills/unreal-mcp/references/setup.md
      2 upstream/skills/unreal-mcp/SKILL.md
      2 upstream/skills/unreal-skill/SKILL.md
```

The 24-line block output (glob order: `audit-reference.sha256` first, then `seat01`…`seat11`):

```
$ sha256sum -c .manifest.d/*.sha256
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
upstream/README.md: OK
upstream/LICENSE: OK
upstream/.claude-plugin/plugin.json: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
exit=0
```

## AFTER (pass)

Two line-blocks changed; the line count of the file is unchanged (278 → 278) so every downstream
citation of the form `README.md:NNN` keeps resolving to the same content. Verbatim diff:

```diff
@@ -166,8 +166,8 @@ per-seat manifests. What each file is:
 ## `.manifest.d/` — byte-identity manifests
 
-`sha256sum -c .manifest.d/*.sha256` → all `OK`, exit `0` (run here; output
-reproduced below). Manifests are relative to `corpus/knowledge/unreal-mcp/`.
+`sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the
+full glob `*.sha256` → **24** (same 12 files twice). Manifests are relative to `corpus/knowledge/unreal-mcp/`.
@@ -184,7 +184,7 @@ reproduced below). Manifests are relative to `corpus/knowledge/unreal-mcp/`.
 | `seat11.sha256` | `upstream/CODEOWNERS` + `upstream/.gitignore` | `653d3725…`, `0fad2f57…` |
 
-Observed output of the sweep (12 lines, all `OK`):
+Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):
```

Resulting text at `README.md:169-170`:

> `sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the full glob
> `*.sha256` → **24** (same 12 files twice). Manifests are relative to `corpus/knowledge/unreal-mcp/`.

and at `README.md:187`:

> Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the
> `*.sha256` glob prints 24 — the same 12 paths, each covered twice):

The caption now names the command that actually produces the 12-line block beneath it, and the
24-line glob count is stated alongside it, so both counts are unambiguous and each is attached to
its own command.

## Line-neutrality (why the fix is safe for the rest of the subtree)

```
$ git show HEAD:corpus/knowledge/unreal-mcp/README.md | wc -l
278
$ wc -l < corpus/knowledge/unreal-mcp/README.md
278
$ diff <(git show HEAD:...README.md | cat -n) <(cat -n corpus/.../README.md) | grep '^[<>]' | awk '{print $1, $2}'
< 169
< 170
> 169
> 170
< 187
> 187
```

Only lines 169, 170 and 187 differ; no line was added or removed. The live cards cite this file
by line number, e.g. `executability/actors-scene.md:322` (`README.md:209-211`),
`executability/actors-scene.md:364` (`README.md:204-240`), `executability/assets-content.md:332`
(`README.md:237`), `executability/meshes-textures.md:254` (`README.md:213-227`). All still resolve
to the same content:

```
$ sed -n '209p;237p;110p;41p' corpus/knowledge/unreal-mcp/README.md
209: it. This index does **not** restate the labels: the binding verdict and its
237: - **A card's label is set by that card's author from that card's own evidence.**
110: ├── adaptation-kimi.md     ← Claude→Kimi adaptation table + verification policy (SEAT-13)
41:  | `unproven-runtime` | the claim needs the live editor and nothing was observed …
```

These match the anchors the cards quote, so no card needs editing and no citation drifts.

## Verification commands and results

```
$ cd corpus/knowledge/unreal-mcp
$ sha256sum -c .manifest.d/audit-reference.sha256   # exit 0
$ sha256sum -c .manifest.d/*.sha256                 # exit 0, 0 FAILED
```

The printed 12-line block in the README was compared mechanically against live output:

```
printed block == audit-reference output: True | block lines: 12 | audit lines: 12
audit output == first 12 lines of glob output: True
```

i.e. the block is byte-identical to `sha256sum -c .manifest.d/audit-reference.sha256`, and that
same output is exactly the first 12 lines of the glob output.

File hashes:

```
BEFORE  sha256sum of HEAD version: 2004a9e5aadcdc825c15f60e34e76a70cc0930556fc63f3b15e2ce0f371b17b9
AFTER   sha256sum corpus/knowledge/unreal-mcp/README.md: c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721
```

## End-to-end corroboration (peer gate, run after the edit)

The r102 gate — a peer seat's deliverable, run as-is, not modified by this seat — was executed with
the edited README in the tree:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297  BLOB_DIFFS=0  STEP=PASS
CARDS=13 EXPECTED=13 BAD=0  static-only=12 unproven-runtime=1 verified-here=0  STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0 STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE_EXIT=0
```

So the subtree still passes byte-identity, path-set equality, card-label and pointer-sweep checks
after the repair — the README edit introduced no unresolved pointer and no manifest drift.

## Scope statement

- Files written by this seat: `corpus/knowledge/unreal-mcp/README.md` (3 lines changed),
  `reports/round-102/repairs/F8-readme-lines.md` (this note).
- Not touched: `corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`, `PROVENANCE.md`,
  `adaptation-kimi.md`, `executability/**`, any other report or lesson.
- No Unreal runtime claim is made or implied here: the editor is not installed, and this repair
  concerns a shell-command line count only.
