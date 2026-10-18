# r103 · SEAT-56 FRESHNESS-PIN — upstream `main` re-check

Round r103 · lane game-dev-3d-shokunin · written 2026-10-18.
Seat scope: re-run `git ls-remote <upstream-url> main` and decide whether the
pin `a6aa73ad…` is still the tip of `main`, or whether upstream has drifted.
Every claim carries the command that produced it and the verbatim output
observed on this host. Labels: **[O]** observed here, **[I]** inference.

Upstream URL (from `PROVENANCE.md` §1 **[O]**):
`https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned commit under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 1. Verdict

**FRESH — no drift.** `main`'s tip is still `a6aa73ad…`, byte-for-byte equal to
the pin. Observed at `2026-10-18T18:32:24Z` **[O]**. No re-fetch, re-pin, or
decontamination is owed this round; the r102 freshness verdict is carried
forward unchanged and is now re-confirmed at a later timestamp.

## 2. Primary command (seat's own)

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T18:32:24Z
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0
```

**[O]** One ref returned, SHA equals the pin exactly, `exit=0`.

## 3. Corroborating transports

All three run at the same session, same host.

```
$ git ls-remote --symref https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
exit=0

$ git ls-remote --heads https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0

$ git ls-remote --tags https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
(no output)
exit=0

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{default_branch, pushed_at, archived, private}'
{"archived":false,"default_branch":"main","private":false,"pushed_at":"2026-09-17T02:27:43Z"}
```

**[O]** `HEAD → refs/heads/main → a6aa73ad…`; `main` is the only branch head;
upstream publishes no tags; repo is public, not archived, `default_branch: main`.
`pushed_at` (`2026-09-17T02:27:43Z`) is older than this round's query, so no
commit has landed since the pinned one **[I]** from that field; the load-bearing
observation is the ref-tip equality, which all four transports agree on.

## 4. Tip identity re-derived from a fresh clone

Freshness of the *pin* and integrity of the *bytes* were both re-checked so
"fresh" covers the copy actually vendored.

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin <scratch>
$ git -C <scratch> rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C <scratch> log -1 --format=%s
[MCP] Permit safe concurrent tool calls
$ git -C <scratch> log -1 --format='%an %ai'
Thomas Mansencal 2026-09-17 13:19:50 +1200
$ git -C <scratch> log -1 --format=%ci
2026-09-17 13:28:32 +1200
$ git -C <scratch> ls-files | wc -l
12
```

**[O]** The fresh clone's HEAD is the pin; subject, author and committer dates
match `PROVENANCE.md` §1 exactly; tracked-file count is 12 as recorded. So the
pin is not a stale local artifact — it is what a clone performs today.

```
$ cd corpus/knowledge/unreal-mcp
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
```

**[O]** 12/12 `OK`, `exit=0` — the vendored tree is byte-identical to the
manifest recorded at the pin, and the pin is still `main`'s tip (§2–§3). The
copy is fresh, not merely intact.

## 5. Freshness table

| question | answer | receipt |
|---|---|---|
| Has `main` moved since the r102 check? | **No** | §2, §3 |
| Is `a6aa73ad…` still the tip of `main`? | **Yes** | §2–§4 |
| Freshness status of the vendored copy | **FRESH — pin == tip** | §2–§4 |
| Re-fetch / re-pin action needed? | **None** | — |

**[O]** `PROVENANCE.md` §7's "later upstream commit would invalidate freshness"
contingency has not fired, so no staleness correction note is owed.

## 6. Gate re-run on the installed script (read-only context for C2)

Not this seat's deliverable, but observed while re-checking the copy, and it
bears on C2's A4 claim. The installed gate is unmodified since `c6f655d`
(`git log -1 --format=%H -- corpus/knowledge/unreal-mcp/gate/run_gate.sh` →
`c6f655d055b0fb5f4921e01c2081b82d15d38ef5`).

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
CHECK 1 manifest-byte-identity
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
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
exit=0
```

**[O]** Check 2 completed against a real network clone this round (its `WORK`
dir is `mktemp -d`, i.e. under `/tmp`). Note the pointer count is **88**, not the
87 quoted in this round's brief — the increase is attributable to edits other
seats made to `adaptation-kimi.md` (C1's target) in the working tree; the gate
was not modified by this seat **[I]**.

### Environmental caveat observed (relevant to C2 A4)

`/tmp` is a `tmpfs` and was near-full during this seat's run:

```
$ df -h /tmp
tmpfs  16G  13G  3.1G  80% /tmp
$ git clone --quiet <url> /tmp/r103-fresh
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '.../description' to '/tmp/r103-fresh/.git/description': Disk quota exceeded
```

**[O]** With `/tmp` at 80% a fresh clone into `/tmp` fails *before* reaching the
network — a failure mode indistinguishable, in the current script, from an
unreachable repo. The same clone into `$HOME` succeeded in 0.65 s **[O]**. This
is a live instance of the class A4 is meant to separate ("clone cannot complete"
≠ "clone proves the pin wrong"), and it strengthens A4's case; it is *not* a
claim that the current gate mis-reports — the gate only hits it when `/tmp`
fills, which did not happen in the run above.

## 7. What this file does not claim

- No Unreal Editor, MCP endpoint, or engine binary was involved; only remote-ref
  queries, one scratch clone, and a local hash check. No runtime claim is made.
- "Fresh" means *the pinned commit is still `main`'s tip*. It is not a claim that
  the vendored content is correct or executable — those verdicts live in
  `executability/` and the r101 evidence layer.
- The `pushed_at` reading is repo-level metadata; the ref-tip equality in §2–§4
  is the load-bearing observation.
- No historical claim was rewritten; this is an additive dated re-check of the
  r102 verdict, not a correction of it.
