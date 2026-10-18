# r101-critic-c1 — adversarial coverage hunt against C1 (all upstream content vendored byte-identical)

Seat: SEAT-45 REVIEW. Round r101, lane game-dev-3d shokunin, Unreal Engine skills integration.
Date of run: 2026-10-18 (all commands below executed on this host, this session).
Verdict headline: **C1 as literally worded ("all upstream content files vendored") is UNDER-SCOPED — the pin is vendored byte-perfect, but "upstream content" extends past the pin.**

Pin under test: `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 0. Reference clone identity (gate before any conclusion)

```
$ cd /tmp/ue-skills-ref && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Matches the pinned SHA. `/tmp/ue-skills-ref` was usable; no fresh clone to `/tmp/r101work` was needed.
Worktree cleanliness (so that "what I hashed" == "what the pin contains"):

```
$ git -C /tmp/ue-skills-ref status --porcelain
(empty)
```

---

## 1. Byte-identity of the pinned tree — CONFIRMED, three independent ways

### 1a. Clone ↔ vendored, file-by-file

```
$ cd /tmp/ue-skills-ref && find . -type f -not -path './.git/*' | sed 's|^\./||' | sort | xargs sha256sum
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  .claude-plugin/plugin.json
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  CODEOWNERS
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  .gitignore
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  hooks/unreal-context.sh
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  LICENSE
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  skills/unreal-mcp/references/setup.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  skills/unreal-mcp/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  skills/unreal-skill/SKILL.md
```

```
$ cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort | xargs sha256sum
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  ./.claude-plugin/plugin.json
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  ./CODEOWNERS
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  ./.gitignore
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  ./hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  ./hooks/unreal-context.sh
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  ./LICENSE
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  ./README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  ./skills/create-toolset/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  ./skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  ./skills/unreal-mcp/references/setup.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  ./skills/unreal-mcp/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  ./skills/unreal-skill/SKILL.md
```

(12 hashes in each listing; sets identical.) `cmp` cross-check, path by path:

```
$ for f in $(find . -type f | sed 's|^\./||' | sort); do
    cmp -s "$f" "/tmp/ue-skills-ref/$f" || echo "MISMATCH $f"; done
(no MISMATCH lines)
```

### 1b. Independent fetch path — codeload tarball (does not use the clone)

This is the check that matters most: it re-derives the pin's content from GitHub's own archive endpoint, so a poisoned or stale local clone cannot fake it.

```
$ curl -sSL -o repo.tar.gz \
  "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297"
$ sha256sum repo.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  repo.tar.gz
$ tar xzf repo.tar.gz && find . -type f -not -name repo.tar.gz | sed 's|^\./[^/]*/||' | sort
.claude-plugin/plugin.json
CODEOWNERS
.gitignore
hooks/hooks.json
hooks/unreal-context.sh
LICENSE
README.md
skills/create-toolset/SKILL.md
skills/unreal-mcp/references/operations.md
skills/unreal-mcp/references/setup.md
skills/unreal-mcp/SKILL.md
skills/unreal-skill/SKILL.md
```

Tarball ↔ vendored, byte compare + set compare:

```
$ for f in $(find . -type f | sed 's|^\./||' | sort); do
    cmp -s "$f" "$V/$f" && echo "IDENTICAL $f" || echo "MISMATCH  $f"; done
IDENTICAL .claude-plugin/plugin.json
IDENTICAL CODEOWNERS
IDENTICAL .gitignore
IDENTICAL hooks/hooks.json
IDENTICAL hooks/unreal-context.sh
IDENTICAL LICENSE
IDENTICAL README.md
IDENTICAL skills/create-toolset/SKILL.md
IDENTICAL skills/unreal-mcp/references/operations.md
IDENTICAL skills/unreal-mcp/references/setup.md
IDENTICAL skills/unreal-mcp/SKILL.md
IDENTICAL skills/unreal-skill/SKILL.md
$ comm -23 <(tarball set) <(vendored set)   # tarball-only paths
(empty)
$ comm -13 <(tarball set) <(vendored set)   # vendored-only paths
(empty)
FAIL=0
```

So: **12/12 byte-identical, no extra paths, no missing paths**, confirmed against an archive endpoint independent of the clone. C1's *pin-scoped* claim holds.

### 1c. Manifest sweep exits 0

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
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
EXIT=0
```

Every per-seat manifest (`seat01`–`seat11`) also verifies `OK` on its own paths.

---

## 2. Structural traps — each checked, each CLEAN

| trap | command | observed result | verdict |
|---|---|---|---|
| LFS pointers | `cat .gitattributes`; `git lfs ls-files`; `grep -rn '^version https://git-lfs' upstream/` | `.gitattributes: No such file or directory`; no lfs output; no matches | CLEAN |
| `.gitattributes` anywhere in history | `git log --all --pretty=format: --name-only \| sort -u \| grep -i 'gitattributes\|gitmodules\|lfs'` | (empty) | CLEAN — never existed |
| submodules | `cat .gitmodules`; `git submodule status`; `git ls-tree -r HEAD \| awk '$1=="160000"'`; `git log --all --pretty=format: --raw \| grep '^:160000'` | all empty | CLEAN |
| symlinks | `find . -type l \| wc -l` (both sides) | `0` / `0` | CLEAN |
| case-sensitivity collision | `git ls-tree -r HEAD --name-only \| tr 'A-Z' 'a-z' \| sort \| uniq -d` (and on vendored) | (empty) / (empty) | CLEAN — no `README.md` vs `readme.md` class hazard for a case-insensitive checkout |
| non-UTF8 bytes | python3 strict `decode('utf-8')` over every file | no output → all files decode | CLEAN |
| NUL bytes | `grep -qP '\x00'` per file | no output | CLEAN |
| CRLF / lone CR | `grep -qP '\r'` per file | no output | CLEAN — LF only |
| UTF-8 BOM | `head -c3 \| grep -qP '\xef\xbb\xbf'` per file | no output | CLEAN |
| zero-byte files | `git ls-tree -r -l HEAD \| awk '$4==0'` | (empty) | CLEAN |
| LFS-looking large files | `find upstream -type f -size +1M` | (empty) | CLEAN |
| dangling/unreachable objects | `git fsck --lost-found` | no output | CLEAN |
| hidden refs / notes / stash | `git for-each-ref refs/notes refs/stash`; `cat .git/packed-refs` | only `refs/remotes/origin/main` | CLEAN |
| file modes | `git ls-tree -r HEAD` vs `find -printf '%m'` | upstream `100644` ×12; vendored `644` ×12 | CLEAN (note: `hooks/unreal-context.sh` is `100644` in git, yet `file` calls it "executable"; git mode is what governs, and it matches) |
| dotfiles at pin | `git ls-tree -r HEAD --name-only \| grep '^\.'` vs `find upstream -name '.*'` | upstream `.claude-plugin/plugin.json`, `.gitignore`; vendored `.gitignore` + `.claude-plugin/plugin.json` (present; `find -name` misses it only because the *directory* is dotted) | CLEAN — verified separately: `upstream/.claude-plugin/plugin.json: OK` in §1c |

Object-type census at the pin contains only blobs, commits and trees — no `160000` gitlink entries:

```
$ git cat-file --batch-all-objects --batch-check | awk '{print $2}' | sort | uniq -c
     98 blob
     58 commit
    134 tree
```

**No trap fired.** The vendoring is structurally faithful, not merely superficially matching.

---

## 3. FINDING — the coverage surface extends past the pin, and the vendoring stopped at the pin

This is the adversarial result. "All upstream content files" is not the same set as "all files at the pinned commit", and the difference is real, enumerable, and unvendored.

### 3a. Branches and tags: the pin is the whole story (no gap here)

```
$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
$ git tag -l | wc -l
0
$ git ls-remote --heads --tags origin
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

```
$ gh release list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin
(empty)
$ gh api repos/.../tags
[]
$ gh api repos/.../branches
[{"name":"main","commit":{"sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297"}, ...}]
```

One branch, zero tags, zero releases. Also `git log --oneline HEAD..origin/main` is empty, i.e. **the pin is the tip of `main`** — there is no "newer main we forgot".

### 3b. GAP — four open PR refs carry content the pin does not have

`git ls-remote origin` advertises more than branches/tags:

```
$ git ls-remote origin
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
435522c0c66685049ac624fef04568ec313bebe7	refs/pull/1/head
f425ff946c82cf602c754c69871bc23d233a0daa	refs/pull/1/merge
6dd839e996900e226316b30a7fc00ee6f58a6772	refs/pull/2/head
dba9b0161e01f948dba80f012ee934908170815a	refs/pull/2/merge
83807c0ea52bef194537e8ccbe3028d4b9daedc9	refs/pull/4/head
721993ece2ebcbadf711c05cfcc17857a4de02bc	refs/pull/4/merge
c64c609745de466cecb184707ff5974fb9375339	refs/pull/5/head
962126c7d5660f673c1375d32c92224a66738f09	refs/pull/5/merge
```

All four are **OPEN** and unmerged at the time of the run:

```
$ gh pr view <n> --json state,mergedAt
1 OPEN merged=null :: Add missing .claude-plugin/marketplace.json so the documented install paths work
2 OPEN merged=null :: Add Marketplace.json
4 OPEN merged=null :: feat: add marketplace manifest to enable local directory and fork installation
5 OPEN merged=null :: Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command
```

**Paths that exist in PR refs but are ABSENT at the pin — 5 paths, all unvendored:**

```
$ { for r in 1 2 4 5; do git ls-tree -r refs/remotes/origin/pr/$r --name-only; done; } | sort -u > /tmp/allrefs.txt
$ git ls-tree -r main --name-only | sort -u > /tmp/mainrefs.txt
$ comm -23 /tmp/allrefs.txt /tmp/mainrefs.txt
.claude-plugin/marketplace.json
.github/workflows/ci.yml
hooks/unreal-context.ps1
tests/test_hooks.ps1
tests/test_hooks.sh
$ comm -23 /tmp/allrefs.txt /tmp/mainrefs.txt | wc -l
5
```

Identities of those unvendored bytes (extracted and hashed; not present in `corpus/`):

```
refs/remotes/origin/pr/1  .claude-plugin/marketplace.json  git=199814c301d081e8035a4ab3aa8c463d92c3ab1a  bytes=908   sha256=390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8
refs/remotes/origin/pr/4  .github/workflows/ci.yml        git=31193716cc234f0e72a05ec8f80ab615b1824b9f  bytes=1116  sha256=4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d
refs/remotes/origin/pr/4  hooks/unreal-context.ps1         git=0dab1245aa06a1d99a06aaf2abc56c1d64b6a46c  bytes=3322  sha256=eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f
refs/remotes/origin/pr/4  tests/test_hooks.sh              git=853f1f4c344e9e765ff65590ca9176ef6bb5322f  bytes=2778  sha256=35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65
refs/remotes/origin/pr/4  tests/test_hooks.ps1             git=ce2e220e7e9e39da6c617066e3027b390fb6bcf9  bytes=3796  sha256=755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8
```

Independently, `git show refs/remotes/origin/pr/4:<path> | sha256sum` reproduces the same five hashes.

Why this is not a hypothetical: **`hooks/unreal-context.ps1` (3322 B) is a second, fully implemented hook**, and `tests/test_hooks.sh` (2778 B) plus `tests/test_hooks.ps1` (3796 B) are the repo's only test suite. PR4's README diff states the intent explicitly:

```
-The `SessionStart` hook is a bash script (`hooks/unreal-context.sh`) ...
+-The `SessionStart` hook injects project context at startup (`hooks/unreal-context.sh` for bash, with a companion `hooks/unreal-context.ps1` for PowerShell). ...
+- **Windows:** ... For native PowerShell environments without `bash` on `PATH`, the companion script `hooks/unreal-context.ps1` provides identical detection logic ...
```

The vendored pin's README instead says "There is no separate PowerShell companion script today" — which is true *at the pin* and false *upstream*. A reader of the corpus alone cannot discover the PS1 hook or the tests.

### 3c. GAP — six pin paths have divergent bytes in PR refs (the pin is one of several live versions)

```
VARIES .claude-plugin/plugin.json  pin=ba4e660a4b05  pr/1=71b9aad60068  pr/2=71b9aad60068
VARIES hooks/hooks.json            pin=6be4b8b7b7e0  pr/5=8343f455ec4d
VARIES README.md                   pin=44c8dd3ef9ac  pr/1=6e51b0194716  pr/2=c119ba253e29  pr/4=fe5635d37b75
VARIES skills/unreal-mcp/references/operations.md  pin=e02d8d0ef920  pr/1=c4c6f50f9b6e  pr/2=c4c6f50f9b6e
VARIES skills/unreal-mcp/references/setup.md       pin=49a921a9ab81  pr/1=7dc77fc60046  pr/2=7dc77fc60046
VARIES skills/unreal-mcp/SKILL.md                  pin=9cd2cc2656d0  pr/1=e11bd338c1eb  pr/2=e11bd338c1eb
```

The PR5 divergence is the sharpest one, because it is a **one-line correctness fix to the file the corpus vendors as authoritative**:

```
$ git diff main refs/remotes/origin/pr/5 -- hooks/hooks.json
-            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh",
+            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh\"",
```

The vendored `hooks/hooks.json` (verified `OK` against the pin) contains the **unquoted** form. Upstream considers that a bug and has an open PR to quote it. The corpus therefore vendors a known-fragile command string with no note that a fix exists.

### 3d. GAP — deleted-in-history content is absent at the pin and unvendored

`skills/unreal-mcp/references/toolsets.md` (8306 B) was deleted in `823f598 Remove/references toolsets.md (#19)`:

```
$ git rev-parse 823f598^:skills/unreal-mcp/references/toolsets.md
eaf2e838a259fb41be10309f9373bca8778607c5
$ git cat-file -e HEAD:skills/unreal-mcp/references/toolsets.md
fatal: path 'skills/unreal-mcp/references/toolsets.md' does not exist in 'HEAD'
$ git cat-file -s eaf2e838a259fb41be10309f9373bca8778607c5
8306
$ git cat-file blob eaf2e838... | sha256sum
1b184bbb31836319ef50ad0661306f7e22bbcf19bf71bed70b6a58d60da69cec
```

Set difference "ever existed anywhere" minus "at pin" — the full unvendored-because-not-at-pin surface:

```
$ comm -23 <(git log --all --pretty=format: --name-only | sort -u | grep -v '^$') \
           <(git ls-tree -r HEAD --name-only | sort)
.claude-plugin/marketplace.json
.github/workflows/ci.yml
hooks/unreal-context.ps1
skills/unreal-mcp/references/toolsets.md
tests/test_hooks.ps1
tests/test_hooks.sh
```

Six paths. Note `toolsets.md` is history-only (deleted), while the other five live in open PRs. Either way, none are vendored.

Importantly, `toolsets.md` is the file the pin *replaced* with prose: the current `skills/unreal-mcp/SKILL.md` describes tool discovery in behavioural terms, while the deleted file was a concrete per-toolset catalogue. It is not merely redundant history.

### 3e. GAP — a second distribution channel for the same plugin

The vendored README documents installation from Anthropic's official marketplace:

```
README.md:32:This plugin is published in Anthropic's official Claude Code plugin marketplace, `claude-plugins-official` ...
README.md:39:/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official
```

That channel exists and is separately pinned:

```
$ gh api repos/anthropics/claude-plugins-official/contents/.claude-plugin/marketplace.json --jq '.content' | base64 -d | jq '.plugins[] | select(.name|test("unreal";"i"))'
{
  "name": "unreal-engine-skills-for-claude-code",
  "description": "Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed ...",
  "author": { "name": "Epic Games" },
  "category": "development",
  "source": {
    "source": "url",
    "url": "https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin.git",
    "sha": "a6aa73ada02a9fb1f5415bec491f9942c519b297"
  },
  "homepage": "https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor"
}
```

Two consequences, one reassuring and one not:

- **Reassuring:** the official marketplace's `source.sha` equals the corpus pin exactly. An independent third party (Anthropic) corroborates `a6aa73a…` as the version users actually get. This strengthens the pin choice.
- **Not covered by C1:** the marketplace entry carries fields with no home in the vendored tree — `category`, `author.name: "Epic Games"` (vs the pin's `Thomas Mansencal`), and `homepage`. The homepage resolves:

```
$ curl -sS -o /dev/null -w "HTTP %{http_code} final=%{url_effective}\n" -L \
  "https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor"
HTTP 200 final=https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
```

  So there is reachable, authoritative Epic documentation for this MCP surface that the corpus neither vendors nor points at. A reader relying only on the corpus would not know it exists.

Also confirmed absent: no engine-side plugin repository is discoverable, so no additional upstream repo is missing from the corpus on that count:

```
$ gh search repos --owner EpicGames "mcp" --limit 20 --json fullName   → (empty)
$ gh search repos "ModelContextProtocol unreal" --limit 10 --json fullName → (empty)
```

### 3f. GAP — the round brief's own count is wrong, and the index records it as "11"

The brief says "all 11 vendored paths". Upstream tracks **12** files:

```
$ git ls-tree -r HEAD | wc -l
12
```

The corpus index already flags this (11 single-file manifests + `seat11` covering two files). Confirmed correct: the 12 vendored files are the 12 tracked files. No action needed, but the brief's number should not be propagated into any C1 acceptance check, or a future reviewer will "find" a phantom 12th file.

---

## 4. Cross-seat integrity observations (found while auditing; not my files to fix)

The corpus subtree is being written concurrently by sibling seats during this run (file mtimes advance between my commands; `executability/` went 6 → 9 → 11 → 12 cards while I worked). Two observations worth passing to the L1, both re-verified at `2026-10-18T14:16:46-03:00`:

1. **Index references two files that do not exist yet.** `corpus/knowledge/unreal-mcp/README.md` (SEAT-14) describes its own layout as including `PROVENANCE.md` and `adaptation-kimi.md`, and calls `PROVENANCE.md` "the provenance manifest" / "Authoritative record of where this content came from". At audit time both were absent:

```
$ ls -la $V/PROVENANCE.md $V/adaptation-kimi.md
ls: cannot access '.../PROVENANCE.md': No such file or directory
ls: cannot access '.../adaptation-kimi.md': No such file or directory
```

   This bears directly on C1, which requires "a provenance manifest". The manifest that *does* exist is `.manifest.d/audit-reference.sha256` (1676 B, carrying URL + pinned SHA + scope note), so C1's requirement is arguably met — but the index advertises a different file as authoritative. Either the files land before round close or the index needs a pointer correction. I did not touch either file (not my seat).

2. **Index says 13 cards; 12 exist; the `expected verdict` column disagrees with the cards.** The index's `executability/` section is titled "13 subsystem verdict cards" and lists a 13-row table with every card's `expected verdict` as `unproven-runtime`. The cards on disk instead declare `static-only` as their binding verdict:

```
$ ls $V/executability/ | wc -l
12
$ grep -rn -E 'Verdict.{0,30}(static-only|unproven-runtime)' $V/executability/
testing-automation.md:125:## 2. Verdict: `static-only`
vfx-niagara-dataflow.md:6:Verdict: **`static-only`**
scripting-programmatic.md:5:**Verdict label: `static-only`**
ui-umg-slate.md:5:**Verdict:** `static-only`
```

   Counts of the three labels across cards: `static-only` 69, `unproven-runtime` 33, `verified-here` 29 — and every `verified-here` occurrence I inspected is negated or definitional ("Not `verified-here`", "Why not `verified-here`", "To move this card ... to `verified-here`"). The one near-miss is `assets-content.md:26`, which grants `verified-here` to *provenance facts about the artifact* while explicitly scoping the card verdict to `static-only`:

```
| Card verdict (applies to the subsystem) | **`static-only`** |
| Provenance facts in §1–§2 (clone identity, byte-identity, hashes) | `verified-here` — but these are claims about the *artifact*, not about the subsystem's behaviour |
```

   So no card asserts a runtime claim — the labelling discipline holds. But the index's `expected verdict` column (all `unproven-runtime`) contradicts the cards it points at (all `static-only`), and the index itself says "the authoritative verdict and its evidence live in each card ... Read the card, not this table". Under C2's requirement ("each labeled exactly one of ..."), the cards are compliant; the index table is stale/misleading and should be reconciled before round close. Both files are outside my seat.

---

## 5. Assessment against C1

| sub-claim | status | evidence |
|---|---|---|
| every file at the pin is vendored, byte-identical | **CONFIRMED** | §1a, §1b, §1c — clone and independent tarball both give 12/12, sets equal, `sha256sum -c` exit 0 |
| no structural trap hides content (LFS/submodule/symlink/case/encoding) | **CONFIRMED** | §2 — 15 checks, none fired |
| no other branch/tag/release holds different content | **CONFIRMED** | §3a — one branch, zero tags, zero releases; pin is tip of `main` |
| **"all upstream content files" is fully captured** | **NOT CONFIRMED** | §3b–§3f — 5 open-PR-only paths, 1 history-only path, 6 PR-divergent byte-versions, 1 external marketplace entry, 1 reachable Epic doc page, all outside the pin and none vendored |
| a provenance manifest exists | **PARTIAL** | `.manifest.d/audit-reference.sha256` exists and carries repo URL + pinned SHA + scope + verify command; the file the index calls "the provenance manifest" (`PROVENANCE.md`) was absent at audit time (§4.1) |

**Bearing on the axis.** C1 is a *coverage* claim, and coverage is the lowest non-retired axis — so the distinction I am drawing is the axis-relevant one. The pin-scoped work is flawless: I could not make a single byte diverge, and I tried the obvious structural tricks. But "vendored byte-identical" was interpreted as "the pinned commit's tracked files", and the pinned commit is one of at least **seven** live content states of this repo (main + 4 PR heads + history + the marketplace entry). Everything outside the pin is currently invisible to the corpus.

This is a scoping decision, not a defect — pinning a commit is the correct way to make vendoring reproducible, and chasing open PRs forever is not reproducible. The gap is that **the corpus never says so**. Nothing in the vendored tree or the manifests records "we vendored `main@a6aa73a` and deliberately excluded N PR-only paths, M history-only paths, and the marketplace entry", nor gives their identities. A future reader will reasonably conclude the corpus is the whole upstream, which it is not.

**Minimum fix to make C1's wording true** (cheapest move that improves coverage and harms nothing, and I cannot make it myself — not my seat's paths):

1. Extend `PROVENANCE.md` (or `audit-reference.sha256`) with an explicit *out-of-scope surface* section: the four PR refs with their SHAs and open/merged state, the 5 unvendored path identities from §3b, the `toolsets.md` blob + SHA from §3d, and the marketplace entry from §3e. Identities are all already computed above; this is a copy-in, not new research.
2. Reword C1 from "all upstream content files" to "all files tracked at the pinned commit `a6aa73a…`", which is what was actually (and correctly) achieved.
3. Optionally vendor the PR4/PR5 artifacts under `upstream-pr/` with a clear "not at pin, not authoritative" banner — `hooks/unreal-context.ps1`, the two test files, and the PR5 quoted `hooks.json` are the highest-value ones, since they are a working test suite and a known bug fix.

---

## 6. Command log (every claim above is reproducible from these)

```
# identity + cleanliness
git -C /tmp/ue-skills-ref rev-parse HEAD                 # a6aa73ada02a9fb1f5415bec491f9942c519b297
git -C /tmp/ue-skills-ref status --porcelain             # empty

# byte-identity, three ways
cd /tmp/ue-skills-ref && find . -type f -not -path './.git/*' | sed 's|^\./||' | sort | xargs sha256sum
cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort | xargs sha256sum
curl -sSL -o repo.tar.gz https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256          # exit 0

# structural traps
git -C /tmp/ue-skills-ref ls-tree -r HEAD ; git -C /tmp/ue-skills-ref ls-tree -r -l HEAD
git -C /tmp/ue-skills-ref ls-tree -r HEAD --name-only | tr 'A-Z' 'a-z' | sort | uniq -d
git -C /tmp/ue-skills-ref log --all --pretty=format: --name-only | sort -u | grep -i 'gitattributes\|gitmodules\|lfs'
git -C /tmp/ue-skills-ref fsck --lost-found
git -C /tmp/ue-skills-ref cat-file --batch-all-objects --batch-check | awk '{print $2}' | sort | uniq -c

# coverage surface
git -C /tmp/ue-skills-ref ls-remote origin               # 4 open PR head+merge refs
gh pr view {1,2,4,5} --repo EpicGames/unreal-engine-skills-for-claude-code-plugin --json state,mergedAt
for r in 1 2 4 5; do git -C /tmp/ue-skills-ref ls-tree -r refs/remotes/origin/pr/$r --name-only; done
comm -23 <(all PR refs, sorted) <(main refs, sorted)     # 5 unvendored paths
git -C /tmp/ue-skills-ref show refs/remotes/origin/pr/5:hooks/hooks.json   # unquoted vs PR5 quoted
git -C /tmp/ue-skills-ref rev-parse 823f598^:skills/unreal-mcp/references/toolsets.md
gh api repos/anthropics/claude-plugins-official/contents/.claude-plugin/marketplace.json
curl -sS -o /dev/null -w '%{http_code}\n' -L https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor
```

Artifacts left on disk for the L1: `/tmp/ue-skills-ref` (clone, pin-verified), `/tmp/r101-verify/tarball/repo.tar.gz` (sha256 `d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf`), `/tmp/r101-verify/unvendored/pr{1,4}/…` (the 5 extracted unvendored files).

Host receipts unchanged and consistent with the brief: Unreal Editor not installed, so no live-editor claim is made or implied anywhere in this report. Every statement above is a filesystem or GitHub-API observation on this host.
