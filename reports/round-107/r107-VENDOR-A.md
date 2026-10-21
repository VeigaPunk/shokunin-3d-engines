# r107-VENDOR-A — Fresh clone #1 + manifest

## Plan (5 lines)
1. Fresh clone `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` at current main HEAD into `/var/tmp/r107-va/` (no repo tree writes).
2. Record resolved pin (commit SHA), branch, clone timestamp, transport = `git clone` over https.
3. `git ls-files -s` full staged-mode listing (mode + blob sha + path) for every tracked file.
4. `sha256sum` of every tracked file (worktree bytes) → emit `reports/round-107/mutations/va-manifest.json`.
5. Cross-check tracked file count vs the 12/12 tracked-file expectation; report mismatches as findings, no edits to `corpus/`.

## Status
- **DONE** — clone reproduced the pin; manifest emitted; 12/12 byte-identical vs vendored tree.

## 1. Transport and pin [O]

Command and observed output, verbatim:

```
$ rm -rf /var/tmp/r107-va/repo
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /var/tmp/r107-va/repo
CLONE_EXIT=0                       # anonymous https, no credentials, 0.68 s wall

$ git -C /var/tmp/r107-va/repo rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /var/tmp/r107-va/repo rev-parse --abbrev-ref HEAD
main
$ git -C /var/tmp/r107-va/repo log -1 --format='%H%n%ci%n%s'
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17 13:28:32 +1200
[MCP] Permit safe concurrent tool calls

$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

| field | value |
|---|---|
| transport | `git clone` (https, anonymous, no credential helper, no token) |
| clone path | `/var/tmp/r107-va/repo` |
| pin (HEAD) | `a6aa73ada02a9fb1f5415bec491f9942c519b297` **[O]** |
| branch | `main` **[O]** |
| commit subject | `[MCP] Permit safe concurrent tool calls` **[O]** |
| committer date | 2026-09-17 13:28:32 +1200 **[O]** |
| remote agrees on pin | yes — `git ls-remote … main` returns the same SHA **[O]** |
| pin drift vs PROVENANCE.md | none — identical SHA, no re-pin needed **[O]** |
| clone wall time | 0.68 s **[O]** |
| worktree clean | `git status --porcelain` → 0 lines **[O]** |
| tags | none (`git describe --tags --always` → `a6aa73a`) **[O]** |

## 2. Tracked-file inventory [O]

`git ls-files | wc -l` → **12**. All entries mode `100644`; no symlinks (no
`120000`), no gitlinks (no `160000`), no `.gitattributes`/LFS pointer files.

| # | path | mode | git blob sha1 | size (B) | sha256 |
|---|---|---|---|---|---|
| 1 | `.claude-plugin/plugin.json` | 100644 | `ba4e660a4b053674fb53dfa83f7e2e6825977796` | 178 | `5aa984848f0f…50b4d44` |
| 2 | `.gitignore` | 100644 | `aa5fae267620144b971c7ccf0e9801e26dd8fcd5` | 19 | `0fad2f57a9fa…950f0f` |
| 3 | `CODEOWNERS` | 100644 | `7ccb8b76fd2c434fb61d4c8d065d0131ae74025e` | 42 | `653d372559be…99550f0f` |
| 4 | `LICENSE` | 100644 | `4a38912a3051e6b6fcf3aec79ac71ecdfbf81ff5` | 11357 | `5b337be05135…82314a6` |
| 5 | `README.md` | 100644 | `44c8dd3ef9ac15d11de88973ab558b4c2ff57044` | 7085 | `483693ad0e14…d46b40e` |
| 6 | `hooks/hooks.json` | 100644 | `6be4b8b7b7e082372186702daf92bd03cc7e5b95` | 564 | `259124f0631b…5ebdc0c` |
| 7 | `hooks/unreal-context.sh` | 100644 | `8c06ba2493a504067a875f5ec50e0095aee56ff6` | 1530 | `d3f1c871cd4e…651fdd` |
| 8 | `skills/create-toolset/SKILL.md` | 100644 | `febf5d5a70739b8bb1d65215ef8272a67f0bbfdd` | 4170 | `e9d050087f36…c1f7b1c` |
| 9 | `skills/unreal-mcp/SKILL.md` | 100644 | `9cd2cc2656d05a738f5814fb2945cc48daff66fc` | 12217 | `7ef8b991a82f…d038fa` |
| 10 | `skills/unreal-mcp/references/operations.md` | 100644 | `e02d8d0ef92063b11c5edb27956b2a25ce7edce3` | 15383 | `dbed002b4a46…7c3113` |
| 11 | `skills/unreal-mcp/references/setup.md` | 100644 | `49a921a9ab818a8912e5d4781fa8d6869dd27dfa` | 17160 | `bd16206ea142…a3b8a` |
| 12 | `skills/unreal-skill/SKILL.md` | 100644 | `a1513865cb7299fc4c76843f426352934bb7aa47` | 3317 | `7a0af781c458…35087` |

Full untruncated sha256 list: `reports/round-107/mutations/va-sha256.txt`.
Full structured manifest: `reports/round-107/mutations/va-manifest.json`.

Integrity self-check inside the clone — for each path, `git hash-object <file>`
(worktree bytes) vs the index blob from `git ls-files -s`:

```
$ for f in $(git ls-files); do ho=$(git hash-object "$f"); ls_s=$(git ls-files -s -- "$f" | awk '{print $2}'); [ "$ho" = "$ls_s" ] && echo OK "$f" || echo MISMATCH "$f"; done
OK .claude-plugin/plugin.json
OK .gitignore
OK CODEOWNERS
OK LICENSE
OK README.md
OK hooks/hooks.json
OK hooks/unreal-context.sh
OK skills/create-toolset/SKILL.md
OK skills/unreal-mcp/SKILL.md
OK skills/unreal-mcp/references/operations.md
OK skills/unreal-mcp/references/setup.md
OK skills/unreal-skill/SKILL.md
```

12/12 OK — worktree bytes hash to the index blobs, so the sha256 values above
describe exactly the committed content at the pin.

## 3. Cross-check against the vendored tree [O]

Independent check of `corpus/knowledge/unreal-mcp/upstream/` (the orchestrator's
landed copy) against this fresh clone, per-file sha256:

```
$ python3 … # sha256(fresh clone f) == sha256(corpus/…/upstream/f) for all tracked f
byte-identical=12/12 missing=0 differ=0
```

Earlier raw pass over the same pair also printed `MATCH` for all 12 paths and
found no path present in the clone but absent from the vendor tree (both trees
carry the same 12 relative paths).

**Verdict: the vendored `upstream/` subtree is byte-identical to a fresh
anonymous clone of the pinned upstream commit — reproduced via an independent
transport.** This is the fresh-clone leg of the round's 3-transport requirement;
the other two transports are sibling seats' business.

## 4. Findings / notes

- **[O] No pin drift.** Upstream `main` is still `a6aa73ad…` as of this seat's
  `git ls-remote`; the r101 pin needs no update.
- **[O] No ignored/extra content matters.** `.gitignore` is 19 B and the clone
  has zero untracked-but-relevant files (`git status --porcelain` empty).
- **[O] Docker context (FYI, not this seat's deliverable).** `docker` is
  `inactive` as a systemd user unit here and `docker ps` returns no containers;
  a sibling's `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` is mid-flight
  (`/var/tmp/ue-pull.log`, 69 lines, layers `Download complete`, no local image
  yet). Recorded only as context — VENDOR-A did not touch or depend on it.
- **[I]** Because 12/12 file bytes and the commit SHA agree, any disagreement a
  later seat reports about upstream content can only come from the vendor tree
  being edited after landing, not from the clone transport.
- No files were written under `corpus/` by this seat; artifacts are limited to
  `reports/round-107/` and `/var/tmp/r107-va/`. The orchestrator owns landing.

## 5. Artifacts

| path | what |
|---|---|
| `reports/round-107/mutations/va-manifest.json` | pin, branch, subject, dates, transport, per-file mode/blob-sha1/size/sha256, 12/12 flags |
| `reports/round-107/mutations/va-sha256.txt` | `sha256sum`-format list of all 12 tracked files |
| `/var/tmp/r107-va/repo` | the fresh clone (scratch, not committed) |
| `/var/tmp/r107-va/{lsfiles-s.txt,sha256.txt,rawsha1.txt,meta.txt}` | raw command outputs backing the manifest |
