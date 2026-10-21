# r107 · VENDOR-B — fresh clone #2 via a DIFFERENT transport (codeload tarball)

Round r107 (3D side-round) · lane `game-dev-3d-shokunin` · seat **KEY=VENDOR-B**.
Written 2026-10-19. Labels: **[O]** observed here (exact command + output), **[I]**
inference, **[?]** unknown/not tested. No writes into `corpus/`; no commits.

## Plan (5 lines)

1. Establish the round-107 target pin from the remote (`git ls-remote`, `gh api`), independent of any local clone.
2. Fetch the same commit through a **different transport**: `curl` the GitHub **codeload tarball** (not `git clone`) into `/var/tmp/r107-vb/`.
3. Verify the tarball's commit identity (top-level dir embeds the SHA; `gh api commits/<sha>`) and enumerate tracked files (12 expected).
4. Hash all 12 files into `vb-manifest.json` (path → sha256 → size → git blob) plus a `sha256sum`-compatible flat file.
5. Cross-check pin agreement: VENDOR-B tarball vs. VENDOR-A `git clone` vs. VERIFY-LEAD tarball vs. vendored tree; label every claim.

## Status

- **DONE** — transport B reproduced the pin; 12/12 byte-identical; pin agrees with VENDOR-A, VERIFY-LEAD and the vendored tree at both sha256 and git-blob level.

## 1. Target pin, established without any local clone [O]

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
EXIT=0

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{default_branch,private,pushed_at,size}'
{"default_branch":"main","private":false,"pushed_at":"2026-09-17T02:27:43Z","size":97}
EXIT=0
```

`main` and `HEAD` agree on the same SHA; the repo is public. The r101 PROVENANCE
pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` is still the tip **[O]** — the
"fresh pin" for r107 is therefore the *same* commit as r101, and the vendored
tree's existing bytes remain the correct target.

Commit identity, via REST (not git):

```
$ gh api repos/EpicGames/…/commits/a6aa73ad… \
    --jq '{sha,subject:.commit.message,author:.commit.author.name,date:.commit.author.date,
           committer_date:.commit.committer.date,verified:.commit.verification.verified}'
{"author":"Thomas Mansencal","committer_date":"2026-09-17T01:28:32Z",
 "date":"2026-09-17T01:19:50Z","sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297",
 "subject":"[MCP] Permit safe concurrent tool calls\n…","verified":false}
```

**[O]** author/date/subject match PROVENANCE.md §1 exactly (the `+1200` there is
the same instant as `01:28:32Z`). `verified:false` = no GPG/SSH signature on the
commit; this is a fact about the commit, **not** a provenance failure, and it is
recorded rather than glossed. **[I]** an unsigned commit is normal for this repo
and does not weaken the byte-identity argument, which rests on content hashes.

## 2. Transport B — codeload tarball (deliberately NOT `git clone`) [O]

```
$ curl -sSL -w 'HTTP=%{http_code} BYTES=%{size_download}\n' -o ue-tar.tar.gz \
    https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297
HTTP=200 BYTES=22990
$ sha256sum ue-tar.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  ue-tar.tar.gz
$ file ue-tar.tar.gz
gzip compressed data, from Unix, original size modulo 2^32 81920
```

Extraction, and the top-level directory — which itself encodes the pin:

```
$ tar -tzvf ue-tar.tar.gz | head -1
drwxrwxr-x root/root 0 2026-09-16 22:28 unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/
```

**[O]** the archive's single root is
`unreal-engine-skills-for-claude-code-plugin-<40-hex>` where the suffix is the
requested SHA — GitHub stamps the commit id into the archive layout, so the
archive is self-identifying.

### 2a. Codeload is deterministic for a fixed SHA [O]

Two fetches of the *same* URL, 13 s apart:

```
$ curl -sSL -o ue-tar-2.tar.gz <same codeload URL>
$ sha256sum ue-tar.tar.gz ue-tar-2.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  ue-tar.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  ue-tar-2.tar.gz
$ cmp ue-tar.tar.gz ue-tar-2.tar.gz && echo CODELOAD-DETERMINISTIC
CODELOAD-DETERMINISTIC
```

Cross-seat corroboration: `reports/round-107/mutations/verify-manifest.json`
(seat VERIFY-LEAD) records `"tarball_sha256":
"d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf"` **[O]** —
an independent seat fetching the same URL got the *same bytes*, so this archive
hash is reproducible across seats, not an artifact of one curl.

### 2b. The REST tarball endpoint differs in bytes but not in content [O]

```
$ curl -sSL -o ue-tar-gh.tar.gz \
    https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/tarball/a6aa73ada02a9fb1f5415bec491f9942c519b297
HTTP=200 BYTES=23001
$ sha256sum ue-tar-gh.tar.gz
fc9f2a04ca7a4eae4a6b79f1671b04bbf03a0e47623b497124126976fc7deeed  ue-tar-gh.tar.gz
$ cmp ue-tar.tar.gz ue-tar-gh.tar.gz
ue-tar.tar.gz ue-tar-gh.tar.gz differ: byte 13, line 1
```

The two archives are **not** byte-equal (22990 vs 23001 bytes; first difference
at byte 13, inside the deflate stream). They also use different root names:

```
codeload : unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/
REST     : EpicGames-unreal-engine-skills-for-claude-code-plugin-a6aa73a/
```

Both extract to the same 12 files with identical content — proven by stripping
the differing top directory before hashing:

```
$ diff <(strip-topdir /tmp/h1) <(strip-topdir /tmp/h2)
TOP-DIR-STRIPPED-CONTENT-IDENTICAL-12/12
```

**[I]** the byte difference is the archive envelope (compression framing and the
root directory name), not the payload. **This is a real trap for any verifier
that compares archive hashes instead of extracted file hashes**: a hash-only
comparison across the two endpoints would produce a *false* mismatch. The
round-107 protocol must therefore pin the *codeload* URL, or compare per-file
hashes. Recorded here so no later seat "fixes" a non-discrepancy.

## 3. The 12 tracked files [O]

```
$ find . -type f | sed 's|^\./||' | sort | wc -l
12
$ find . -type l | wc -l
0
$ find . -type f -printf '%m %p\n' | sort -k2      # every mode
644  (all 12)
```

No symlinks, no submodules, no LFS pointers, no extra files — matching the r101
census. Sizes (bytes) and sha256, all 12:

| path | bytes | sha256 |
|---|---|---|
| `.claude-plugin/plugin.json` | 487 | `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44` |
| `.gitignore` | 203 | `0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538` |
| `CODEOWNERS` | 64 | `653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f` |
| `LICENSE` | 1073 | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` |
| `README.md` | 8398 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` |
| `hooks/hooks.json` | 357 | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` |
| `hooks/unreal-context.sh` | 3101 | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` |
| `skills/create-toolset/SKILL.md` | 23258 | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` |
| `skills/unreal-mcp/SKILL.md` | 7098 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` |
| `skills/unreal-mcp/references/operations.md` | 6497 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |
| `skills/unreal-mcp/references/setup.md` | 6065 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` |
| `skills/unreal-skill/SKILL.md` | 6955 | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` |

Note `hooks/unreal-context.sh` is mode `644` **in the tarball** — the archive
does not carry the executable bit. **[O]** the r101 manifest lists the same
mode `100644` for it, so the vendored tree and the archive agree; the hook is
invoked as `bash <path>`, not executed directly.

## 4. Independent content-level check: git tree reconstruction [O]

Rather than trust file hashes alone, the extracted tarball was re-hashed *as git
objects* and the resulting tree SHA compared to the tree the GitHub API reports:

```
$ git init -q treecheck && cp -a <extracted>/. treecheck/ && cd treecheck
$ git add -A && git write-tree
b5b9624b00fc90217240e823406699d0ab78b959
$ gh api repos/EpicGames/…/commits/a6aa73ad… --jq '.commit.tree.sha'
b5b9624b00fc90217240e823406699d0ab78b959
→ TREE-SHA-MATCHES-GITHUB
```

**[O]** This is the strongest single result in this shard: the tarball's *content*
reconstructs, bit-for-bit, the exact git tree object that GitHub associates with
commit `a6aa73ad…`. It ties the tarball transport to the git object graph
independently of any clone.

## 5. Cross-check: pins and bytes agree across every transport [O]

Five independent sources were compared. All agree at 12/12.

| # | source | transport | pin / identity | sha256 12/12? |
|---|---|---|---|---|
| 1 | VENDOR-B (this seat) | codeload tarball | top-dir SHA + `write-tree` = `b5b9624b…` | — (reference) |
| 2 | VENDOR-A (`r107-VENDOR-A.md`, `va-manifest.json`) | `git clone` https | `rev-parse HEAD` = `a6aa73ad…` | **yes** |
| 3 | VERIFY-LEAD (`verify-manifest.json`) | codeload tarball (separate) | `a6aa73ad…`, archive `d091941c…` | **yes** |
| 4 | vendored `corpus/knowledge/unreal-mcp/upstream/` | on-disk, r101 | `a6aa73ad…` | **yes** |
| 5 | `.manifest.d/audit-reference.sha256` | r101 audit clone | `a6aa73ad…` | **yes** |

Commands behind rows 2–5, run from this seat (not quoted from other shards):

```
$ jq -r '.files[]|"\(.git_blob_sha1)  \(.path)"' mutations/va-manifest.json | sort -k2 > va-blobs.sha1
$ diff va-blobs.sha1 vb-gitblob.sha1 && echo VA==VB-GIT-BLOBS-12/12
VA==VB-GIT-BLOBS-12/12

$ diff <(grep -E '^[0-9a-f]{64}' mutations/va-sha256.txt | sort -k2) \
       <(sort -k2 mutations/vb-manifest.sha256) && echo VA==VB-FLAT-IDENTICAL
VA==VB-FLAT-IDENTICAL

$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK$'
12
$ cd corpus/knowledge/unreal-mcp/upstream && { for f in $(find . -type f|sed 's|^\./||'|sort); do
    printf '%s  %s\n' "$(git hash-object "$f")" "$f"; done; } | sort -k2 > ondisk-gitblob.sha1
$ diff ondisk-gitblob.sha1 ../mutations/vb-gitblob.sha1 && echo VENDORED-TREE-GIT-BLOB-IDENTICAL-12/12
VENDORED-TREE-GIT-BLOB-IDENTICAL-12/12
```

Agreement holds on **two independent axes**: sha256 of the file bytes, and the
git SHA-1 blob id. **[I]** two axes agreeing makes an accidental match
implausible; a mismatch on either would have been a finding.

## 6. Git-protocol spot check (row 3 of the "3 transports" story) [O]

A third, mechanically different route — the git wire protocol — was also used to
confirm the blob ids, so the tarball's `git hash-object` values are not
self-consistent-but-wrong:

```
$ git init -q gitfetch && cd gitfetch && git remote add origin <url>
$ git fetch -q --depth=1 origin a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git rev-parse FETCH_HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git ls-tree -r FETCH_HEAD | awk '{print $3"  "$4}' | sort -k2 > gitfetch.sha256
$ diff vb-gitblob.sha1 gitfetch.sha256 && echo GIT-BLOB-IDENTICAL-12/12
GIT-BLOB-IDENTICAL-12/12
```

Caveat recorded honestly: `git ls-tree` column 3 is a **git SHA-1 blob id**, not
sha256. A first attempt compared that column directly against sha256 values and
"differed" 12/12 — that is an apples-to-oranges comparison and **not** a
discrepancy. The correct comparison (`git hash-object` on the tarball vs
`ls-tree` on the fetch) is the one shown, and it matches. Any seat repeating
this must hash the same way on both sides.

## 6a. Negative control — the comparison actually detects a bad byte [O]

A verification that always passes proves nothing, so one byte was flipped in a
throwaway copy and the same comparison re-run:

```
$ cp -a <extracted> negctl
$ printf 'X' | dd of=negctl/skills/unreal-mcp/SKILL.md bs=1 seek=100 conv=notrunc status=none
$ sha256sum negctl/skills/unreal-mcp/SKILL.md
1b89c338c8b1d56288f66424a09d2b22bf56855393644fc6f258a01c22bbda05  negctl/…/SKILL.md
   (clean value: 7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa)

$ diff vb-flat.sha256 neg.sha256
11c11
< 7ef8b991…  skills/unreal-mcp/SKILL.md
> 1b89c338…  skills/unreal-mcp/SKILL.md
→ MUTATION-DETECTED-BY-PIPELINE

$ stat -c %s negctl/…/SKILL.md   →  7098     (same as clean: 7098)
$ cmp -l negctl/…/SKILL.md <clean>…/SKILL.md
 101 130  40        # octal byte offset 101, 0o130 → 0o40
```

**[O]** One byte at offset 101 changed, file size unchanged, and the sha256
comparison caught it. So the pass in §5 is a real pass, not a vacuous one.

## 7. Artifacts produced by this seat

| path | what |
|---|---|
| `reports/round-107/r107-VENDOR-B.md` | this shard |
| `reports/round-107/mutations/vb-manifest.json` | 12-file manifest: path, sha256, size, mode, git blob, pin, archive sha256, tree sha |
| `reports/round-107/mutations/vb-manifest.sha256` | flat `sha256sum`-compatible, root-relative paths (no `upstream/` prefix) |
| `reports/round-107/mutations/vb-gitblob.sha1` | git blob ids for all 12, sorted by path |

Scratch (not landed): `/var/tmp/r107-vb/{ue-tar.tar.gz,ue-tar-2.tar.gz,ue-tar-gh.tar.gz,x/,y/,treecheck/,gitfetch/,vb-files.txt}`.
Archive sha256 to pin the transport: **`d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf`** (codeload, 22990 bytes).

## 8. What this seat did NOT prove [explicit]

- **[?]** That the codeload archive bytes are stable *forever* — only two fetches
  13 s apart (plus VERIFY-LEAD's) were compared. GitHub could change archive
  framing; per-file hashes are the durable invariant, archive hashes are not.
- **[?]** Nothing about Unreal Engine runtime behaviour — this seat only
  establishes provenance of the vendored plugin text. The UE runtime verdict
  (proven-with-evidence vs unproven-with-attempt-log) belongs to the unlock seats.
- **[?]** The commit is unsigned (`verified:false`); authenticity rests on
  GitHub's TLS + the byte-identity chain, not on a maintainer signature. Not
  tested whether a signed release/tag exists.
- **[O]** The docker pull (`wukakuki/unreal-engine:dev-slim-5.8.3`, pid 596299)
  was still running throughout this seat's work (~2 min elapsed, no image
  present in `docker images`); this seat neither started nor waited on it.
