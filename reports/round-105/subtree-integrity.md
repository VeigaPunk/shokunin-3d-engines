# r105 SEAT-48 — SUBTREE-INTEGRITY

Round axes: depth / coverage / calibration. This seat checks pinned-subtree byte integrity and reports only observed worktree state.

## Snapshot

- HEAD: `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`
- Upstream pin: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- Check window: `2026-10-18T20:30:28Z`–`2026-10-18T20:34:28Z` (UTC)
- No commit, push, checkout, reset, fixture edit, or pinned-subtree edit performed.

## Manifest sweep — PASS

Commands run from the repository root:

```sh
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
```

Observed: all 12 listed `upstream/` paths printed `OK`; `AUDIT_RC=0`.

```sh
cd corpus/knowledge/unreal-mcp && for f in .manifest.d/seat*.sha256; do sha256sum -c "$f"; done
```

Observed: all 11 seat shard files returned rc=0; 12 shard entries printed `OK` (seat11 contains two entries); `SEAT_SHARD_ENTRIES=12 FAILED_SHARDS=0`.

## Pinned-directory diff — PASS (empty)

```sh
git diff --exit-code HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
```

Observed: no output; `PINNED_DIR_DIFF_RC=0`.

## Subtree diff — snapshot caveat

```sh
git diff --name-status HEAD -- corpus/knowledge/unreal-mcp
git status --porcelain -uall -- corpus/knowledge/unreal-mcp
```

Observed at the check window: both commands report only `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`. No `upstream/` or `.manifest.d/` path is changed. No `gate/` change was present in this snapshot; therefore the requested “gate/ + adaptation-kimi.md” final-state comparison is not yet established and must be re-run after SEAT-10 lands its gate edits.

```sh
git diff --check
```

Observed: `DIFF_CHECK_RC=0`.

## Verdict

**PASS, scoped to the snapshot above:** reference manifest and all per-seat shard hashes validate; `upstream/` and `.manifest.d/` are clean against HEAD. Recheck command `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` confirmed `AUDIT_RC=0 AUDIT_OK=12`; `git diff --check` confirmed `DIFF_CHECK_RC=0`. **Final subtree-diff status remains pending SEAT-10:** `git status --short -- corpus/knowledge/unreal-mcp reports/round-105 && git diff --name-status HEAD -- corpus/knowledge/unreal-mcp` at `2026-10-18T20:34:28Z` showed `adaptation-kimi.md` as the only subtree diff and `reports/round-105/` untracked; gate edits were still absent. Re-run after SEAT-10 lands; no claim is made about later concurrent changes.
