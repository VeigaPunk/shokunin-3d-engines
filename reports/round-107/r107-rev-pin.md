# r107-REV-PIN — independent pin / verification derivation

Seat KEY=REV-PIN · round 107 (3D side-round) · lane `game-dev-3d-shokunin` · 2026-10-19.

## Plan header (5 lines)

1. Fresh clone from `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` into
   `/var/tmp/r107-rev-pin/` — derive the pin with commands that did not exist in r101 (no reuse of
   `/tmp/ue-skills-ref` or `/tmp/r101-audit`; both are gone, see §1).
2. Re-derive the pin by independent transports that share no local state: **A** fresh `git clone`,
   **B** `git ls-remote`, **C** codeload tarball at the SHA, **D** GitHub REST commit/tree API.
3. Re-check BOTH manifest families from inside the vendored tree, read-only:
   `.manifest.d/audit-reference.sha256` (12/12) and `.manifest.d/seat01..seat11.sha256`.
4. Re-derive all 12 `git ls-tree` blob ids + byte counts from the fresh clone; cross-check against
   PROVENANCE §2 and against the sibling VENDOR-A/VERIFY-2 shards.
5. Record every command with verbatim output; label [O]/[I]/[?]; no writes outside `reports/round-107/`
   and `/var/tmp/r107-rev-pin/`.

**STATUS: DONE.** Verdict: **pin CONFIRMED by 4 independent transports; vendored tree byte-identical
12/12 to a fresh clone and to the pinned tarball; both manifest families green.** One sibling-shard
defect found (§6). No upstream drift — see §2.

Reproduce everything: `bash reports/round-107/mutations/rev-pin.sh` → `VERDICT: PASS`, exit `0` [O].

---

## 1. Independence of this seat's evidence

The r101 reference clones named in PROVENANCE §1/§2 no longer exist on this host [O]:

```
$ ls -d /tmp/ue-skills-ref /tmp/r101-audit
ls: cannot access '/tmp/ue-skills-ref': No such file or directory
ls: cannot access '/tmp/r101-audit': No such file or directory
```

So no r101 artifact could have been reused even by accident: every value below was re-derived from
the wire in this round, under `/var/tmp/r107-rev-pin/` (created by this seat at 2026-10-19T03:0xZ).

Host clock at time of writing: `date` → `Mon Oct 19 12:09:32 AM -03 2026`; `date -u` →
`Mon Oct 19 03:09:32 AM UTC 2026` [O].

## 2. The pin, by four transports [O]

Expected pin: `a6aa73ada02a9fb1f5415bec491f9942c519b297`; expected tree
`b5b9624b00fc90217240e823406699d0ab78b959`.

**A — fresh `git clone` (https, anonymous, no credential helper):**

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    /var/tmp/r107-rev-pin/fresh-clone          # clone exit=0
$ git -C fresh-clone rev-parse HEAD                     → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C fresh-clone log -1 --format=%T                 → b5b9624b00fc90217240e823406699d0ab78b959
$ git -C fresh-clone rev-parse --abbrev-ref HEAD        → main
```

**B — `git ls-remote` (no clone, no working tree):**

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
435522c0c66685049ac624fef04568ec313bebe7	refs/pull/1/head
… (8 more refs/pull/*, all non-default; exit 0)
$ git ls-remote … refs/heads/main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

`HEAD` and `refs/heads/main` both equal the pin; the only other refs are the 12 `refs/pull/*`
entries (open PR heads/merges), which are *not* the default branch and are not vendored.

**C — codeload tarball at the SHA (hash-of-content transport; no git object store, no `.git`):**

```
$ curl -sSL -o pin.tar.gz \
    https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ad…
http=200 bytes=22990
$ sha256sum pin.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  pin.tar.gz
$ tar xzf pin.tar.gz -C tarx && ls tarx/
unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297
```

The tarball's own directory name carries the requested SHA, so C is self-identifying: codeload
served content for the SHA that was asked for, and that content matched the clone byte-for-byte
(§4). `tar tvzf` shows the expected modes (`-rw-rw-r--`, no symlinks, no gitlinks) [O].

**D — GitHub REST API (wire metadata, independent of git and of codeload):**

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/a6aa73ad… \
    --jq '{sha,msg,date,tree,verified}'
{"date":"2026-09-17T01:28:32Z","msg":"[MCP] Permit safe concurrent tool calls\n\n…Bump the plugin
 version to `3.1.1`…","sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297",
 "tree":"b5b9624b00fc90217240e823406699d0ab78b959","verified":false}
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '{default,license,private,size}'
{"default":"main","license":"MIT","private":false,"size":97}
$ gh api "…/git/trees/b5b9624b…?recursive=1" --jq '[.tree[]|select(.type=="blob")]|length'
12
```

**[O]** The API returns the *same tree SHA* as the local clone — a value the clone derived locally
from its own object store. Tree-SHA agreement across two unrelated transports is the strongest
identity statement available here: it pins the exact directory listing, not just the commit.

| transport | mechanism | pin observed | agrees |
|---|---|---|---|
| A | `git clone` https | `a6aa73ad…` | yes [O] |
| B | `git ls-remote` | `a6aa73ad…` (HEAD + main) | yes [O] |
| C | codeload tarball | dir name + content hash | yes [O] |
| D | GitHub REST API | `.sha` + `.tree.sha` | yes [O] |

**No drift [O].** The fresh clone's HEAD is the *same* SHA that r101 vendored
(`corpus/knowledge/unreal-mcp/PROVENANCE.md` §1). Round 107's "fresh pin" is therefore the r101
pin: upstream `main` has not moved between 2026-10-18 and 2026-10-19. This round is a
**re-verification**, not a re-pin — and the orchestrator's landing should not carry a new pin
number. Commit metadata re-derived: subject `[MCP] Permit safe concurrent tool calls`, author
`Thomas Mansencal <thomas.mansencal@epicgames.com>`, author date `2026-09-17 13:19:50 +1200`,
committer date `2026-09-17 13:28:32 +1200`, parent `d1b05809e4f089bd0ef174532c692fbcf1562eb7`,
no tags [O] — all identical to PROVENANCE §1.

## 3. Tracked census and modes [O]

```
$ git -C fresh-clone ls-tree -r HEAD | wc -l
12
$ git -C fresh-clone ls-tree -r HEAD | awk '{print $1}' | sort | uniq -c
     12 100644
$ git -C fresh-clone ls-tree -r HEAD | awk '$1=="160000"' | wc -l   # gitlinks
0
$ git -C fresh-clone ls-tree -r HEAD | awk '$1=="120000"' | wc -l   # symlinks
0
```

12 tracked files, every one mode `100644`, no gitlinks, no symlinks — matches PROVENANCE §1/§6
and the `recursive=1` blob count from transport D. The tarball file list
(`find . -type f | sed 's|^\./||' | sort`) is identical to the clone list (`diff` → exit 0,
12 lines) [O].

## 4. Byte identity, three ways, per file [O]

Per-file sha256 computed independently over (i) the codeload tarball, (ii) the fresh clone, and
(iii) the vendored `corpus/knowledge/unreal-mcp/upstream/`:

```
$ for p in $(cat clone-list.txt); do
    a=$(sha256sum "$TARDIR/$p"|cut -d' ' -f1)
    b=$(sha256sum "fresh-clone/$p"|cut -d' ' -f1)
    c=$(sha256sum "$VEND/upstream/$p"|cut -d' ' -f1)
    [ "$a" = "$b" ] && [ "$b" = "$c" ] && echo "OK   $p" || echo "DIFF $p"
  done
OK   .claude-plugin/plugin.json
OK   CODEOWNERS
OK   .gitignore
OK   hooks/hooks.json
OK   hooks/unreal-context.sh
OK   LICENSE
OK   README.md
OK   skills/create-toolset/SKILL.md
OK   skills/unreal-mcp/references/operations.md
OK   skills/unreal-mcp/references/setup.md
OK   skills/unreal-mcp/SKILL.md
OK   skills/unreal-skill/SKILL.md
three-way identical (0=yes): 0
```

Directory-level confirmations, both exit 0:

```
$ diff -rq tarx/<sha>/ corpus/knowledge/unreal-mcp/upstream          # tarball vs vendored
(no output)   exit 0
$ diff -rq fresh-clone corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)   exit 0
```

### 4b. Byte counts confirmed a fourth way — GitHub REST blob `size` [O]

The `recursive=1` tree listing carries each blob's `size` from GitHub's object store, independent
of both the git pack protocol and codeload. All 12 REST sizes equal `stat -c%s` on the fresh clone
(`OK` on every row); the values are the `bytes` column of the table below. Note `LICENSE` → `1073`,
the value `git cat-file -s`, `stat`, `wc -c` and PROVENANCE §2 all give — not VENDOR-A's prose
`11357` (§6).

### Per-file table re-derived at the pin

`bytes` = `stat -c%s` on the fresh clone and `git cat-file -s <blob>` (agreed on all 12);
`lines` = `wc -l`; `git blob` = first 8 of `git ls-tree -r` object id.

| # | path (relative to `upstream/`) | bytes | lines | sha256 | git blob |
|---|---|---|---|---|---|
| 1 | `README.md` | 8398 | 112 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` | `44c8dd3e` |
| 2 | `LICENSE` | 1073 | 21 | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | `4a38912a` |
| 3 | `CODEOWNERS` | 64 | 2 | `653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f` | `7ccb8b76` |
| 4 | `.gitignore` | 203 | 4 | `0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538` | `aa5fae26` |
| 5 | `.claude-plugin/plugin.json` | 487 | 10 | `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44` | `ba4e660a` |
| 6 | `hooks/hooks.json` | 357 | 17 | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` | `6be4b8b7` |
| 7 | `hooks/unreal-context.sh` | 3101 | 84 | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` | `8c06ba24` |
| 8 | `skills/unreal-mcp/SKILL.md` | 7098 | 56 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` | `9cd2cc26` |
| 9 | `skills/unreal-mcp/references/setup.md` | 6065 | 133 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` | `49a921a9` |
| 10 | `skills/unreal-mcp/references/operations.md` | 6497 | 51 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` | `e02d8d0e` |
| 11 | `skills/create-toolset/SKILL.md` | 23258 | 420 | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` | `febf5d5a` |
| 12 | `skills/unreal-skill/SKILL.md` | 6955 | 112 | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` | `a1513865` |

All 12 rows are **identical to PROVENANCE §2** in bytes, lines, sha256 and blob id — an
independent re-derivation that reproduces the r101 table exactly [O].

## 5. Both manifest families re-checked, read-only [O]

Run from inside `corpus/knowledge/unreal-mcp/`, no file modified:

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
audit exit=0

$ sha256sum -c .manifest.d/seat*.sha256          # 12 OK lines, combined exit=0
$ for f in .manifest.d/seat*.sha256; do sha256sum -c "$f" >/dev/null 2>&1 \
    && echo "$f ALL OK" || echo "$f FAIL"; done
.manifest.d/seat01.sha256 ALL OK
… seat02…seat10 ALL OK
.manifest.d/seat11.sha256 ALL OK
```

Line census of the manifests: `seat01`–`seat10` are 1 line each, `seat11` is 2 lines (it holds
`CODEOWNERS` + `.gitignore`) → 12 entries total [O]. This reproduces the r101
"11 seats / 12 files" reading in PROVENANCE §2, so that reconciliation still holds at this round's
re-check.

## 6. Cross-check against sibling r107 shards

| sibling shard | its claim | my independent re-derivation | verdict |
|---|---|---|---|
| `r107-VENDOR-A.md` §1 | pin `a6aa73ad…`, branch `main`, subject, committer date | same, via clone + ls-remote + API | **AGREE** [O] |
| `r107-VENDOR-A.md` §2 | 12 paths, all `100644`, blob ids | identical blob ids, 12/12 `100644` | **AGREE** [O] |
| `r107-VENDOR-A.md` §2 | **prose size column** (LICENSE `11357`, README `7085`, plugin.json `178`, …) | **contradicted** — see below | **DISAGREE** [O] |
| `r107-VENDOR-A.md` §2 | sha256 column | identical to mine on all 12 | **AGREE** [O] |
| `mutations/va-manifest.json` | `size_bytes` for all 12 files | identical to mine on all 12 | **AGREE** [O] |
| `r107-VENDOR-A.md` §3 | clone vs vendored = 12/12 byte-identical | reproduced (`diff -rq` exit 0) | **AGREE** [O] |
| `mutations/vb-manifest.json` | `size` + sha256 + blob for all 12, `tree_sha`, 12 files, 0 symlinks, 0 submodules | identical to mine on all 12 | **AGREE** [O] |
| `r107-verify2.md` | transports A/B/C, own manifests | **plan-only at read time** (17 lines, no results) — see below | **N/A** [O] |
| `r107-mut-pin.md` | negative control (unmutated passes, mutated fails) | **plan-only at read time** (11 lines, no results) — see below | **N/A** [O] |

### Note: two cited sibling shards were still plan-only when read

`r107-verify2.md` was 17 lines and `r107-mut-pin.md` 11 lines when I read them, both ending at
their plan header with no findings [O]. I therefore do **not** claim agreement with their results —
I cannot, since none were written yet. What I can say is weaker and worth stating precisely:

- **[I]** `r107-verify2.md`'s declared plan (transports A=`git clone`, B=codeload tarball, C=GitHub
  REST blobs) is a superset of mine; if executed it would land on the same values, but that is an
  expectation, not an observation. Its `mutations/v2-transport-c.sh` (972 B, transport C over
  REST blobs) and `mutations/verify-manifest.json` (6172 B) existed on disk at read time, so the
  seat was mid-flight, not idle.
- **[I]** My §7 negative control was designed independently and happens to exercise the same
  property `r107-mut-pin.md` plans (unmutated passes, mutated fails). That is convergence of
  intent, not corroboration. My §7 result stands on its own output.

The orchestrator should re-read both shards at integration time rather than take my rows as
verification of them.

### Defect: VENDOR-A's **prose** byte-size column is wrong on all 12 rows

`r107-VENDOR-A.md:59` claims `LICENSE` is `11357` bytes; `:60` claims `README.md` is `7085` bytes;
its table also lists `plugin.json` `178`, `.gitignore` `19`, `CODEOWNERS` `42`,
`hooks.json` `564`, `unreal-context.sh` `1530`, `create-toolset/SKILL.md` `4170`,
`unreal-mcp/SKILL.md` `12217`, `operations.md` `15383`, `setup.md` `17160`,
`unreal-skill/SKILL.md` `3317`.

**Scope of the defect, checked explicitly [O].** The error is confined to the *Markdown table in
the shard*. VENDOR-A's machine-readable artifact is correct:

```
$ python3 -c "import json; [print('%-45s %-7s' % (f['path'], f['size_bytes']))
              for f in json.load(open('mutations/va-manifest.json'))['files']]"
.claude-plugin/plugin.json                    487
.gitignore                                    203
CODEOWNERS                                    64
LICENSE                                       1073
README.md                                     8398
hooks/hooks.json                              357
hooks/unreal-context.sh                       3101
skills/create-toolset/SKILL.md                23258
skills/unreal-mcp/SKILL.md                    7098
skills/unreal-mcp/references/operations.md    6497
skills/unreal-mcp/references/setup.md         6065
skills/unreal-skill/SKILL.md                  6955
```

All 12 `size_bytes` values equal my own measurements, as do `vb-manifest.json`'s `size` fields and
the REST `size` field from transport D (§9). So the wrong numbers exist only in the shard's prose
table and in the `sha256sum`-free summary there.

Every one of those prose values is refuted by four independent measurements of the same files [O]:

```
$ git cat-file -s 4a38912a3051e6b6fcf3aec79ac71ecdfbf81ff5      # LICENSE blob at the pin
1073
$ stat -c%s corpus/knowledge/unreal-mcp/upstream/LICENSE
1073
$ wc -c < corpus/knowledge/unreal-mcp/upstream/LICENSE
1073
$ head -3 corpus/knowledge/unreal-mcp/upstream/LICENSE
MIT License

Copyright (c) 2026 Epic Games, Inc.
```

and likewise `README.md` → `8398` (VENDOR-A: `7085`), `plugin.json` → `487` (VENDOR-A: `178`).
All 12 of my byte counts match PROVENANCE §2 exactly. **[I]** The likely cause is that VENDOR-A's
size column was populated from something other than file bytes — the values are far too small for
the files they claim to describe (a 11357-byte LICENSE cannot be a 1073-byte MIT text), and they
do not correspond to any natural unit of these files (not line counts, not the sha256 hex length).
**[?]** The exact mechanism is not recoverable from the shard.

**Impact assessment.** Low for the round's core claims — VENDOR-A's *sha256* column, its blob ids,
its pin, its 12/12 byte-identity verdict and its cross-check against the vendored tree are all
correct and independently reproduced above. The sizes are decorative metadata in that shard.
**But**: PROVENANCE §2's per-file table is the authoritative record, and a future seat that
cross-checks the two tables will see a 12-row conflict. **Recommendation for the orchestrator:** do
not propagate VENDOR-A's size column into the landed `PROVENANCE.md`; either correct it in a note
or drop the column from the shard. PROVENANCE §2's numbers are the ones corroborated here.

## 7. Discrimination check (does this verification actually bite?) [O]

A verification that cannot fail proves nothing. Staged copy under `/var/tmp/r107-rev-pin/negctl/`,
one byte flipped at offset 5 of `README.md` (XOR `0x01`), byte count deliberately unchanged:

```
before sha256 483693ad0e14d027  bytes 8398     # == the pinned sha256 prefix
after  sha256 0ef585b9b1e180b7  bytes 8398     # same length, different content
$ sha256sum -c negctl.sha256
negctl/README.md: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
NEGCTL_EXIT=1
```

Same manifest, unmutated copy → `exit 0` (§5). So the check is **content-sensitive, not
length-sensitive**: a single flipped byte in one file is caught, and an unchanged tree passes.
`r107-mut-pin.md` plans the same property but was plan-only when read (§6), so this is my own
independent result, not a reproduction of theirs.

## 8. Artifacts

| path | what |
|---|---|
| `reports/round-107/mutations/rev-pin.sh` | the whole re-derivation as one runnable script; prints `VERDICT: PASS`, exit 0 |
| `reports/round-107/r107-rev-pin.md` | this shard |
| `/var/tmp/r107-rev-pin/fresh-clone` | transport A clone (scratch, not committed) |
| `/var/tmp/r107-rev-pin/tarx/…` | transport C extracted tarball |
| `/var/tmp/r107-rev-pin/{pin.tar.gz,clone-list.txt,tar-list.txt}` | raw outputs backing §2/§3 |
| `/var/tmp/r107-rev-pin/negctl`, `negctl.sha256` | §7 negative control |

`git status --porcelain` in the repo shows only `?? reports/round-107/` — this seat wrote nothing
into `corpus/`, touched no sibling lane, and did not run any battery [O].

## 9. What this shard does NOT claim

- **No runtime claim.** Unreal Editor is not installed on this host (PROVENANCE §5, unchanged and
  re-confirmed in r107 by sibling seats). Nothing here is evidence about engine behavior; it is
  evidence about *files and commit identity only*.
- **No freshness beyond this instant.** The pin agreed with upstream `main` at
  `2026-10-19T03:09Z` [O]. Upstream may move later; that would not invalidate the vendored bytes,
  only their freshness.
- **No license/legal claim.** §2's `license: MIT` from the API is metadata recording, not a rights
  analysis — the operative treatment remains `reports/round-101/probes/license-audit.md`.
- **Transport C is not fully independent of GitHub's infra.** codeload and the API are both
  GitHub-operated; the transports are independent *mechanisms* (pack protocol vs tarball vs REST),
  not independent *vendors*. A same-vendor failure would not be caught here. **[?]**
- **`verified: false`** in transport D is GitHub's signature check on the commit, which was
  unsigned/not verified by GitHub. It says nothing about content integrity, which the tree-SHA and
  three-way byte identity do establish. **[I]**
- The docker unlock attempt (`wukakuki/unreal-engine:dev-slim-5.8.3`, pull in flight) is a sibling
  seat's business; this seat did not depend on it. At my last check `/var/tmp/ue-pull.log` had 70
  lines, several layers `Pull complete`, no local image yet [O].
