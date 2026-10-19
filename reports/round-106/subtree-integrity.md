# r106 SEAT-71 — SUBTREE-INTEGRITY

Round axes: depth / coverage / calibration. This seat proves `corpus/knowledge/unreal-mcp/upstream/` and `corpus/knowledge/unreal-mcp/.manifest.d/` are byte-stable: (a) `sha256sum` sweep rc=0, (b) `git diff` on those two paths empty. Read-only on the subtree. The only file this seat leaves is this report. Scratch clone and gate workdir lived under `reports/round-106/scratch/seat71/` and were removed before close.

- HEAD under test: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`r105 report-last: verdict … — work 3634bc0`), re-read at close and unchanged.
- Upstream pin under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- Check window (UTC): `2026-10-18T21:20:25Z` – `2026-10-18T21:43:00Z`
- **No Unreal runtime claim.** No editor launched, no live MCP connection. Unreal Editor is not installed; nothing here promotes an `unproven-runtime` card. A green gate is static byte-identity only.
- No `git commit` / `push` / `checkout` / `reset`. No write into `upstream/`, `.manifest.d/`, `gate/`, fixtures, or rounds 101–105.

## 1. sha256 sweep — PASS (rc=0)

Command, subtree as cwd, as the manifest header prescribes:

```sh
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
```

Observed at `2026-10-18T21:20:25Z` window start, and reconfirmed at close `2026-10-18T21:43:00Z` (`AUDIT_RC=0`):

```text
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
AUDIT_RC=0
```

12/12 `OK`, 0 `FAILED`.

Per-seat shards, same cwd:

```sh
for f in .manifest.d/seat*.sha256; do sha256sum -c "$f"; done
```

Observed: 11 shard files, every rc=0, `SEAT_SHARD_FAILED_FILES=0 SEAT_SHARD_OK_ENTRIES=12` (seat11 carries two entries; `wc -l .manifest.d/seat11.sha256` → `2`). Shard set equals the audit reference both ways:

```sh
comm -23 <(cat .manifest.d/*.sha256 | grep -v '^#' | grep -v '^$' | sort -u) \
         <(grep -v '^#' .manifest.d/audit-reference.sha256 | grep -v '^$' | sort -u)
comm -13 <(cat .manifest.d/*.sha256 | grep -v '^#' | grep -v '^$' | sort -u) \
         <(grep -v '^#' .manifest.d/audit-reference.sha256 | grep -v '^$' | sort -u)
```

Both `comm` diffs empty. Unique paths: `12`. The `*.sha256` glob still prints 24 `OK` lines (audit reference plus shards), matching the live README's "24" claim. No correction owed.

## 2. Pinned-directory diff — PASS (empty)

```sh
git diff --stat -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
git diff --exit-code HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
```

Observed: no output; `DIFF_STAT_RC=0`; `PINNED_DIR_DIFF_RC=0` at open and again at `2026-10-18T21:43:00Z` after the gate run and scratch removal. `git status --porcelain -uall -- corpus/knowledge/unreal-mcp` empty at both ends. `git diff --cached --stat -- corpus/knowledge/unreal-mcp` empty. `git diff --check` → `DIFF_CHECK_RC=0`.

The empty diff is substantive, not an untracked or ignored tree:

```text
git ls-files …/upstream | wc -l          → 12
find …/upstream -type f | wc -l          → 12
git ls-files …/.manifest.d | wc -l       → 12
find …/.manifest.d -type f | wc -l       → 12
diff tracked-set vs on-disk set          → UPSTREAM_SET_IDENTICAL_TO_TRACKED
                                         → MANIFEST_SET_IDENTICAL_TO_TRACKED
git check-ignore -v upstream/README.md .manifest.d/seat01.sha256 → rc=1 (nothing ignored)
find …/upstream -type l | wc -l          → 0
```

Whole-subtree blob walk (`git hash-object` vs `git ls-tree -r HEAD`): `identical=42 differing=0 missing=0` (tracked count 42). That closes the r105 seat's snapshot caveat (`reports/round-105/subtree-integrity.md`: gate edits not yet landed). **Dated note, not a rewrite of that report:** at r106 open HEAD `0cc3f41` the whole subtree, including `gate/` and `adaptation-kimi.md`, is clean against HEAD. This report does not claim the subtree stays clean after `2026-10-18T21:43:00Z` if a later seat writes it.

Tree ids, unchanged from the r103/r104 reports:

```text
040000 tree 87bde5b7bc9517664cfbdae46d3cfeaded62e3e2  corpus/knowledge/unreal-mcp/.manifest.d
040000 tree b5b9624b00fc90217240e823406699d0ab78b959  corpus/knowledge/unreal-mcp/upstream
```

Per-dir blob walk: upstream `identical=12 differing=0 missing=0`; `.manifest.d` the same.

## 3. Vendored bytes vs a fresh pin clone — PASS (12/12)

`/tmp/r101-audit` is gone (`ls` → cannot access). `/tmp` df at open: `tmpfs 16G 13G 3.1G 80%`. Host note says the per-user `/tmp` quota is exhausted, so the clone was not placed there.

```sh
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
git clone --no-checkout --depth 1 <url> reports/round-106/scratch/seat71/pin-clone
```

Observed: `ls-remote` rc=0, `a6aa73ada02a9fb1f5415bec491f9942c519b297 refs/heads/main`. `CLONE_RC=0`. `git -C <clone> rev-parse HEAD` → the same pin (`PIN_MATCH=yes`), so no extra fetch. Pin tracked files: 12. Path-set `diff` vs vendored `upstream/` → `UPSTREAM_SET_IDENTICAL_TO_PIN`.

Per-file `sha256sum` of the worktree file vs `git show HEAD:<path> | sha256sum`: 12 `MATCH`, `FILES_CHECKED=12 CROSSCHECK_FAIL=0`. Manifest-independent.

Consolidated digests (sorted `sha256  path` lines, then `sha256sum`), reproducing the r103/r104 values:

```text
upstream worktree     16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963
.manifest.d worktree  0c36de92e9c362d6911efa053586c32e7bd3e0d93956b8017e470e357b507102
pin-clone blobs       16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963
```

Vendored digest equals the clone-derived digest.

Mtimes: newest upstream file `2026-10-18T14:43:32` (`skills/unreal-mcp/SKILL.md`); newest manifest `2026-10-18T14:14:07` (`audit-reference.sha256`). `find upstream .manifest.d -type f -newermt '2026-10-18 15:32:00'` empty. No mid-round write in either tree, so no silent rewrite to disclose and no dated correction inside those trees.

## 4. Installed gate — PASS (rc=0), corroboration only

```sh
GATE_WORKDIR=$PWD/reports/round-106/scratch/seat71/gate-work \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Observed `2026-10-18T21:21:41Z`, `GATE_RC=0`:

```text
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=…/reports/round-106/scratch/seat71/gate-work (from GATE_WORKDIR)
WORK_ROOT_FREE=756G of 930G (18% used)
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

`verified-here=0` is the correct census: editor not installed. Post-gate `git diff --exit-code` on the two pinned dirs was still rc=0; the gate did not write the subtree. Scanner sha at this run: `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. README sha: `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`.

## 5. Citation sweep of this chunk — no mechanical fix

Verify command cited from the lane root in `SKILL.md`, `corpus/knowledge/unreal-mcp/README.md`, `PROVENANCE.md`, `engines.md`, and the executability cards — `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)` — is the command in §1. It resolves, rc=0, 12 `OK`.

Path-cite scan of `corpus/knowledge/**/*.md`, `corpus/lessons/**/*.md`, `SKILL.md`, `README.md`, `PROVINCE.md` (115 files; vendored `upstream/**` excluded): 21 unique `upstream/` or `.manifest.d/` path strings, 6 not `is_file()`. All six are false misses, re-read in source:

- `PROVENANCE.md` `.manifest.d/seat` is the glob `.manifest.d/seat*.sha256` (the `*` stopped the extractor).
- `adaptation-kimi.md` `upstream/` and `upstream/skills/unreal-mcp/references/`, and `scripting-programmatic.md` `…/upstream/skills/`, are directory prefixes. All three directories exist.
- `materials.md` `.manifest.d/seat01` is the ellipsis form `seat01…seat11.sha256`. `seat01.sha256` exists.
- `gate/README.md` `upstream/nope.md` is the documented exact control sentinel. `test -f` rc=1, as intended. Not a broken cite.

No path in this seat's chunk was rewritten. No dated correction note was inserted into a living file.

## 6. Queued judgment defect (not patched)

`gate/**` is protected. Do not silently rewrite.

`corpus/knowledge/unreal-mcp/gate/README.md:248` still presents the current expected line as measured at lane HEAD `88c3b2c`, scanner `e5521304…`, `adaptation-kimi.md` sha256 `084a34cd…`, with `POINTERS=103`. Lines 42, 283, and 440 also name scanner `e5521304…` as the current pin's scanner. Observed here: live scanner `390a25ae…`; `sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md` → `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`; HEAD `0cc3f41`; live gate still printed `POINTERS=103 … UNRESOLVED=0`. The numeric pin holds. The provenance sentence does not describe this tree. Same class already recorded by r105 `reports/round-105/gate/integrity.md` and, concurrently, r106 `reports/round-106/gate/pin-audit.md`. Left queued for the gate-README owner. This seat did not edit it.

## 7. Scratch

`rm -rf reports/round-106/scratch/seat71` before the close reconfirm. `SCRATCH_REMOVED`. Other seats' scratch under `reports/round-106/scratch/` was not touched. No pinned byte was written.

## Verdict

**PASS.** At HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`, window close `2026-10-18T21:43:00Z`:

- `sha256sum -c .manifest.d/audit-reference.sha256` → **rc=0, 12/12 OK**; 11 seat shards rc=0, 12/12 OK; both `comm` diffs empty.
- `git diff --exit-code HEAD -- upstream .manifest.d` → **rc=0, empty**, reconfirmed after the gate. Both trees fully tracked, not ignored, 0 symlinks. Whole subtree blob walk 42/42 identical.
- Fresh clone of pin `a6aa73ad…` (still `main` at `ls-remote`) → **12/12 byte match**; consolidated digests equal r103/r104 (`16dfaa66…` upstream, `0c36de92…` `.manifest.d`).
- Gate corroboration → **PASS rc=0**, `MANIFEST_OK=12`, `BLOB_DIFFS=0`, `POINTERS=103 … UNRESOLVED=0`, `verified-here=0`.

**Blockers:** none for this verdict. One queued, unpatched provenance defect in protected `gate/README.md` (§6). No runtime claim.
