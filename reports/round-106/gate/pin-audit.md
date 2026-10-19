# SEAT-99 PIN-AUDIT — gate README pin vs live POINTERS

Round r106 · lane `game-dev-3d-shokunin` · written 2026-10-18. Seat scope: this report plus scratch under `reports/round-106/gate/scratch/seat99/`. No file under `corpus/knowledge/unreal-mcp/` was written. `gate/**` is protected, so the provenance defect below is queued, not patched.

Labels: **[O]** observed here. No Unreal Editor / runtime claim. A green gate is static byte-identity only.

## Verdict

**Active pin matches the live count. Lesson-sweep edits did not move the subtree count. No mover.**

At `2026-10-18T21:31:21Z`, with nine `corpus/lessons/` files already dirty, the installed gate printed `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` and `GATE RESULT: PASS (checks failed: 0)`, exit `0` **[O]**. An independent recount (not a call into `run_gate.sh`) printed the same `103` at `21:31:20Z`, `21:37:52Z`, and `21:44:33Z` (`pass A 47 + pass B 56`). The unreal-mcp subtree stayed `42` files, `git diff` empty against HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. By `21:44:33Z` lesson porcelain had grown to 31 and the count had still not moved.

The binding invariant `UNRESOLVED=0` held. The numeric pin did not go stale.

## Live gate vs README pin

Command (roomy workdir; `/tmp` not used):

```sh
GATE_WORKDIR=$PWD/reports/round-106/scratch/seat99-workdir \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  > reports/round-106/gate/scratch/seat99/gate-run.stdout \
  2> reports/round-106/gate/scratch/seat99/gate-run.stderr
echo $? > reports/round-106/gate/scratch/seat99/gate-run.rc
```

Observed `2026-10-18T21:31:21Z` (stderr 0 bytes, rc file `0`, stdout 2147 bytes):

```text
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd
WORK_ROOT=…/reports/round-106/scratch/seat99-workdir (from GATE_WORKDIR)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

`grep -nE 'POINTERS=|pointer endpoints' corpus/knowledge/unreal-mcp/gate/README.md` at `21:31:20Z` — active pin sites, all `103`:

| README line | role | text | vs live `103` |
|---|---|---|---|
| 42 | current-pin sentence | `` `POINTERS=103` `` | match |
| 248 | expected (re-measured) block | `POINTERS=103 … UNRESOLVED=0` (pass A 47 / pass B 56) | match |
| 271 | pinned summary | `POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=0` | match |
| 283 | quantity table | `` `103` / `41` `` | match |
| 377 | W0 control row | `POINTERS=103` | match |

Two `101` sites are **not** the active pin. They are the dated r103 records already flagged in `reports/round-104/gate/pin-check.md`: line 357 (C0 control row) and line 401 (quoted r103 evidence block). Left untouched. A future re-run of C0 will not print `101`.

Other pinned quantities in the same run matched the README summary block: manifest `12`, clone HEAD = pin `a6aa73ada02a9fb1f5415bec491f9942c519b297`, tracked `12`, cards `13`, census `12/1/0`, `NAME_SET=OK`. `verified-here=0`.

## Independent recount

Same CHECK 4 regexes as `run_gate.sh` (pass A extract at the `upstream/…` `grep -ohE`, pass B backtick extract), self-file `gate/README.md` and `upstream/` excluded on pass A only, pass B not self-excluded. Not a call into `run_gate.sh`.

```text
2026-10-18T21:31:20Z
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=56
INDEPENDENT POINTERS=103 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0

2026-10-18T21:37:52Z
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=56
INDEPENDENT POINTERS=103 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0
lesson_dirty=9
subtree_dirty_names=0
subtree_files=42
```

`47 + 56 = 103`, matching the README decomposition on line 248. Pass A did not move. No `MISSING-PATH` / `MISSING-PATH-REL` / `OOR` lines.

## Subtree count vs the lesson sweep

CHECK 4's scan root is `corpus/knowledge/unreal-mcp` only (`run_gate.sh` `find "$SUB"`). `corpus/lessons/` is outside that root, so a lesson edit cannot enter pass A or pass B unless it also writes a subtree file.

Commands and observed output:

```text
2026-10-18T21:30:39Z  git status --porcelain -- corpus/knowledge/unreal-mcp  → empty
                      git ls-files / find -type f  → 42 / 42
                      lessons porcelain → 8
2026-10-18T21:31:20Z  git diff --name-only HEAD -- corpus/knowledge/unreal-mcp | wc -l → 0
                      lessons porcelain → 9 (r105-unreal-lifecycle.md joined)
2026-10-18T21:35:34Z  subtree porcelain empty; ls-files 42; find 42; untracked 0
                      lessons ls-files 96; find 96
2026-10-18T21:40:25Z  git ls-tree -r --name-only HEAD -- corpus/knowledge/unreal-mcp | wc -l → 42
                      git ls-tree -r --name-only HEAD -- corpus/lessons | wc -l → 96
                      subtree porcelain count → 0
                      lessons porcelain → the same 9 names
```

Newest subtree mtime at `21:35:34Z` was `adaptation-kimi.md` at `2026-10-18T17:29:19`, before this round's lesson edits. No in-round subtree write.

Lesson files dirty during the window (all `M`, none deleted, none under the subtree):

```text
corpus/lessons/r105-unreal-lifecycle.md
corpus/lessons/r61-stream-review.md
corpus/lessons/r62-three-ortho-near-review.md
corpus/lessons/r63-three-ray-review.md
corpus/lessons/r64-ray-side-review.md
corpus/lessons/r65-ray-order-review.md
corpus/lessons/r66-ray-range-review.md
corpus/lessons/r67-ray-boundary-review.md
corpus/lessons/r68-ray-layers-review.md
```

`git diff --stat HEAD -- corpus/lessons` at `21:31:20Z`: `9 files changed, 56 insertions(+), 36 deletions(-)`. Lessons file count stayed `96`. Subtree file count stayed `42`. `POINTERS` stayed `103`. **No mover — the count did not move.**

**Later bracket (dated, not a rewrite of the rows above).** At `2026-10-18T21:43:41Z` the lesson porcelain had grown from 9 to 31 (`git status --porcelain -- corpus/lessons | wc -l` → `31`; `find corpus/lessons -type f | wc -l` → `96`). Subtree porcelain was still `0` and `find corpus/knowledge/unreal-mcp -type f` was still `42`. Independent recount at `2026-10-18T21:44:33Z` again printed `passA_endpoints=47 passB_paths=56 POINTERS=103 UNRESOLVED=0` with `lesson_dirty=31`, `lesson_files=96`, `subtree_dirty_names=0`, `subtree_files=42`. The added dirty names are other `corpus/lessons/r*.md` files, still outside the scan root. Count still unmoved.

## Queued defect (not a count drift; not fixed here)

The **number** `103` matches. The **provenance label** on that number does not match the installed scanner, and `e5521304` is not a committed blob of `run_gate.sh`.

```text
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
  390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
sha256sum corpus/knowledge/unreal-mcp/gate/README.md
  e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf
sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md
  a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1
grep -c 390a25ae corpus/knowledge/unreal-mcp/gate/README.md → 0
grep -c e5521304 corpus/knowledge/unreal-mcp/gate/README.md → 5
```

Committed script shas (`git show <c>:…/run_gate.sh | sha256sum`), prefix only:

| commit | script | adaptation |
|---|---|---|
| `c6f655d` (r102) | `412d1b84…` | `e0f8ca9b…` |
| `8c9d9ad` (r103) | `577c8b54…` | `084a34cd…` |
| `2ca87e8` (r104, last script+README touch) | `390a25ae…` | `084a34cd…` |
| `3634bc0` (r105) / `0cc3f41` (HEAD) | `390a25ae…` | `a2db1d28…` |

`git rev-list --all -- corpus/knowledge/unreal-mcp/gate/run_gate.sh` produced no blob whose sha starts `e5521304`. README line 248 (blame `2ca87e8`) still says re-measured at lane HEAD `88c3b2c`, scanner `e5521304…`, adaptation `084a34cd…`. Line 42 calls `e5521304…` the scanner of the current pin. Live lane HEAD is `0cc3f416…`. Adaptation `084a34cd…` is the pre-r105 blob; `3634bc0` replaced it with `a2db1d28…` and the count did not move.

This is the same provenance caveat `reports/round-105/gate/integrity.md` queued. Still open. A dated correction belongs on `gate/README.md`, which this seat must not edit. Do not treat the stale label as a reason to restamp `POINTERS` — the live measurement is still `103`.

## What this seat did not do

- No edit under `corpus/knowledge/unreal-mcp/` (including `gate/README.md` and `run_gate.sh`).
- No Unreal Editor launch, no live MCP call, no promotion of `unproven-runtime`.
- Scratch clone dir under `reports/round-106/scratch/seat99-workdir` was empty after the gate's EXIT trap (`find` printed no residual).
