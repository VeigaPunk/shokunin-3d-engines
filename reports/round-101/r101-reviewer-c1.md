# SEAT-44 REVIEW — C1 coverage, non-author verification

Round: r101 · Lane: game-dev-3d-shokunin · Seat: SEAT-44 (review)
Target claim: **C1 (coverage)** — all upstream content files vendored byte-identical
under `corpus/knowledge/unreal-mcp/upstream/` with a provenance manifest.
Review mode: **non-author, independent.** I did not write the vendored tree, any
`.manifest.d/` manifest, or `corpus/knowledge/unreal-mcp/README.md`. All evidence
below is re-derived from a fresh clone I made myself.

Host receipts used (from the round brief, cited not re-derived): Arch Linux, 32
cores, 30 GB RAM; `jq`, `python3`, `node`, `shellcheck` 0.11.0 present; Unreal
Editor NOT installed. Tool versions actually observed in this review:
`git 2.55.0`, `sha256sum (GNU coreutils) 9.11`, `jq-1.8.2`, `Python 3.14.7`,
`shellcheck 0.11.0`.

---

## Verdict

**C1 CONFIRMED, with one coverage caveat that is not a byte-identity defect.**

- Every one of the **12** content files tracked by upstream at the pinned commit
  exists under `corpus/knowledge/unreal-mcp/upstream/` and is **byte-identical**
  to a fresh clone — verified **four independent ways** (git clone, codeload
  tarball, GitHub API blob SHA1, and local `cmp`), 12/12 with zero mismatches.
- The vendored tree contains **no extra files** and **no missing files**:
  the path sets are exactly equal in both directions.
- A provenance manifest exists at
  `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` (12/12
  reference) plus 11 per-seat manifests; `sha256sum -c` over all of them exits
  `0` with every line `OK`.
- The check is **not vacuous**: a negative control (1-byte append, and a file
  deletion) correctly flips the check to exit `1`.
- **Caveat (coverage, not identity):** the round brief says "all 11 vendored
  paths". Upstream actually tracks **12**. The vendored tree correctly has 12;
  the brief undercounts. Separately, `corpus/knowledge/unreal-mcp/README.md`
  advertises `PROVENANCE.md` and `adaptation-kimi.md` in its Layout block, and
  **neither exists yet** — those are C2/C3 deliverables still in flight at review
  time, not C1 content files.

---

## 1. Independent source resolution (pin re-established from scratch)

I did not trust `/tmp/ue-skills-ref` (it was in fact absent). I cloned fresh:

```bash
cd /tmp && rm -rf /tmp/r101review && \
  git clone --quiet \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin \
  /tmp/r101review
git -C /tmp/r101review rev-parse HEAD
```

Observed:

```
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Equals the pinned SHA → all subsequent comparisons are against the right commit.

Independently confirmed against the remote rather than a local ref:

```bash
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
```

And the pin is the tip of `main`, the repo's only branch/ref:

```bash
git ls-remote --heads --tags origin
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

Commit metadata observed:

```bash
git -C /tmp/r101review log -1 --format='%H%n%ci%n%an%n%s'
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17 13:28:32 +1200
Thomas Mansencal
[MCP] Permit safe concurrent tool calls
```

---

## 2. Full upstream file-tree inventory (the denominator)

The review question is a set question: does every upstream content file exist
vendored? So the denominator must be enumerated, not assumed.

```bash
cd /tmp/r101review
git ls-files | sort
```

```
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

**12 tracked files.** On-disk count excluding `.git` is also 12, so nothing
untracked exists that a vendoring pass could have missed:

```bash
find . -path ./.git -prune -o -type f -print | wc -l
```

```
12
```

Structure census — confirms there is no hidden file class that a plain-file
enumeration would drop:

```bash
find . -path ./.git -prune -o -type l -print | wc -l   # symlinks
git ls-files -s                                        # modes
git submodule status; ls .gitattributes; git lfs ls-files
```

```
0                                # symlinks
100644 ... (all 12 entries)      # every file is mode 100644
                                 # submodule status: empty
ls: cannot access '.gitattributes': No such file or directory
                                 # git lfs ls-files: empty
```

All 12 are mode `100644`, no symlinks, no submodules, no `.gitattributes`, no
LFS pointers. So the file inventory is complete and needs no special-casing.

---

## 3. The vendored tree, same enumeration

```bash
cd corpus/knowledge/unreal-mcp/upstream
find . -type f -print0 | sed 's|^\./||' | xargs -0 sha256sum | sort -k2
```

**12 files, same 12 paths.** Set difference in both directions:

```bash
comm -23 <(awk '{print $2}' /tmp/a.sha256 | sort) <(awk '{print $2}' /tmp/b.sha256 | sort)
comm -13 <(awk '{print $2}' /tmp/a.sha256 | sort) <(awk '{print $2}' /tmp/b.sha256 | sort)
```

```
(empty)   # upstream files missing from vendored: none
(empty)   # vendored files not in upstream:       none
```

Vendored tree also has 0 symlinks and all files mode `644`.

---

## 4. Byte-identity — four independent transports

### 4a. sha256 over the whole set (clone vs vendored)

```bash
diff /tmp/upstream_fresh.sha256 /tmp/vendored.sha256 && echo DIFF_EMPTY_OK
```

```
DIFF_EMPTY_OK
```

### 4b. `cmp` on every file (stronger than hash equality — byte-for-byte)

```bash
cd /tmp/r101review
while IFS= read -r f; do
  cmp -s "$f" "/…/corpus/knowledge/unreal-mcp/upstream/$f" || echo "MISMATCH: $f"
done < <(git ls-files | sort)
```

```
compared=12 mismatches=0
```

### 4c. Third transport — GitHub codeload tarball (bypasses git entirely)

```bash
curl -sSL -o /tmp/r101tar/src.tar.gz \
  "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297"
tar xzf /tmp/r101tar/src.tar.gz && cd unreal-engine-skills-…-a6aa73ada02a9fb1f5415bec491f9942c519b297
find . -type f -print0 | sed 's|^\./||' | xargs -0 sha256sum | sort -k2
```

12 lines, byte-identical hash list. Normalized 3-way comparison in Python:

```
counts: fresh=12 vendored=12 tarball=12
path sets equal (fresh==vendored==tarball): True
paths with 3/3 identical sha256: 12/12  disagreements=0
```

### 4d. Fourth transport — GitHub API git-blob SHA1 recomputed from vendored bytes

The API gives each blob's git SHA1 at the pinned commit. I recomputed the git
blob SHA1 (`sha1("blob <len>\0" + bytes)`) directly from the **vendored** file
contents, which verifies the vendored bytes against GitHub's own object store
without any git client in the loop:

```
OK  api=ba4e660a4b05 clone=ba4e660a4b05 vendored=ba4e660a4b05  .claude-plugin/plugin.json
OK  api=aa5fae267620 clone=aa5fae267620 vendored=aa5fae267620  .gitignore
OK  api=7ccb8b76fd2c clone=7ccb8b76fd2c vendored=7ccb8b76fd2c  CODEOWNERS
OK  api=4a38912a3051 clone=4a38912a3051 vendored=4a38912a3051  LICENSE
OK  api=44c8dd3ef9ac clone=44c8dd3ef9ac vendored=44c8dd3ef9ac  README.md
OK  api=6be4b8b7b7e0 clone=6be4b8b7b7e0 vendored=6be4b8b7b7e0  hooks/hooks.json
OK  api=8c06ba2493a5 clone=8c06ba2493a5 vendored=8c06ba2493a5  hooks/unreal-context.sh
OK  api=febf5d5a7073 clone=febf5d5a7073 vendored=febf5d5a7073  skills/create-toolset/SKILL.md
OK  api=9cd2cc2656d0 clone=9cd2cc2656d0 vendored=9cd2cc2656d0  skills/unreal-mcp/SKILL.md
OK  api=e02d8d0ef920 clone=e02d8d0ef920 vendored=e02d8d0ef920  skills/unreal-mcp/references/operations.md
OK  api=49a921a9ab81 clone=49a921a9ab81 vendored=49a921a9ab81  skills/unreal-mcp/references/setup.md
OK  api=a1513865cb72 clone=a1513865cb72 vendored=a1513865cb72  skills/unreal-skill/SKILL.md
blob-sha1 agreement: 12/12 ok, 0 mismatched
```

The API response was `truncated: False` with exactly 12 blobs, so the API's
denominator also equals 12.

### Full path → sha256 inventory (all 12, from my own clone)

| # | path (relative to `upstream/`) | bytes | sha256 |
|---|---|---|---|
| 1 | `.claude-plugin/plugin.json` | 487 | `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44` |
| 2 | `CODEOWNERS` | 64 | `653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f` |
| 3 | `.gitignore` | 203 | `0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538` |
| 4 | `hooks/hooks.json` | 357 | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` |
| 5 | `hooks/unreal-context.sh` | 3101 | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` |
| 6 | `LICENSE` | 1073 | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` |
| 7 | `README.md` | 8398 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` |
| 8 | `skills/create-toolset/SKILL.md` | 23258 | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` |
| 9 | `skills/unreal-mcp/SKILL.md` | 7098 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` |
| 10 | `skills/unreal-mcp/references/operations.md` | 6497 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |
| 11 | `skills/unreal-mcp/references/setup.md` | 6065 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` |
| 12 | `skills/unreal-skill/SKILL.md` | 6955 | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` |

Line-ending / encoding sanity (a classic silent-corruption vector):

```bash
for f in $(git ls-files|sort); do grep -c $'\r' "$f"; tail -c1 "$f" | xxd -p; done
```

Every file: `cr_lines=0`, `lastbyte=0a` (LF only, trailing newline present). All
12 decode as valid UTF-8. So no CRLF or encoding mangling occurred in vendoring.

---

## 5. Provenance manifest

`corpus/knowledge/unreal-mcp/.manifest.d/` contains 12 manifests:

```bash
ls corpus/knowledge/unreal-mcp/.manifest.d/
```

```
audit-reference.sha256  seat01.sha256  seat02.sha256  seat03.sha256
seat04.sha256  seat05.sha256  seat06.sha256  seat07.sha256
seat08.sha256  seat09.sha256  seat10.sha256  seat11.sha256
```

`audit-reference.sha256` is the 12/12 provenance manifest: a 6-line `#` header
recording the repo URL, the pinned SHA, the clone location and the verification
command, followed by all 12 path/hash rows. `seat01`–`seat11` split the 12 files
across 11 seats (`seat11` covers two: `CODEOWNERS` + `.gitignore`).

### Positive control — the command the manifest itself documents

```bash
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
```

```
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
```

exit `0`. Over **all** manifests at once:

```bash
sha256sum -c .manifest.d/audit-reference.sha256 .manifest.d/seat*.sha256
```

exit `0`, 24 `OK` lines (12 unique paths, each covered twice: once by its seat
manifest, once by the audit reference). Every seat manifest's hash matches the
corresponding row of the audit reference — no per-seat disagreement.

### Negative control — proves the check is not vacuous

A manifest that prints `OK` for everything is worthless if it would also print
`OK` for corrupted content. Tested on a scratch copy, never on the real tree:

```bash
cp -a corpus/knowledge/unreal-mcp/. /tmp/negctl/
cd /tmp/negctl && printf 'X' >> upstream/README.md
sha256sum -c .manifest.d/audit-reference.sha256
```

```
upstream/README.md: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

exit `1`. Deleting a file instead:

```bash
rm /tmp/negctl/upstream/LICENSE && sha256sum -c .manifest.d/audit-reference.sha256
```

```
sha256sum: WARNING: 1 listed file could not be read
sha256sum: WARNING: 1 computed checksum did NOT match
```

exit `1`. The real tree re-checked clean immediately after (`exit 0`). So the
`OK` sweep in §5 is a real signal.

### Manifest self-hash claim

`reports/round-101/probes/byte-identity-reference.md:153` claims the audit
reference hashes to `fe3906c5…c323a`. Recomputed here:

```bash
sha256sum corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
```

```
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
```

Exact match → the probe's recorded hash is reproducible.

---

## 6. Cross-checks against sibling claims

- `corpus/knowledge/unreal-mcp/README.md` states "tracked files **12** (all mode
  `100644`; no symlinks, no submodules, no LFS, no `.gitattributes`)" and
  "vendored 12/12 byte-identical". **Independently confirmed** in §2 and §4.
- That README's per-file byte/line table was re-measured here with `stat -c%s`
  and `wc -l` for all 12 rows — every byte count and every line count matches
  the published table exactly (e.g. `create-toolset/SKILL.md` 23258 B / 420 L;
  `unreal-context.sh` 3101 B / 84 L; `README.md` 8398 B / 112 L).
- The README's note that the round brief's "11 vendored paths" is an undercount
  is correct: upstream tracks 12, and 12 are vendored.
- `plugin.json` version `3.1.1` and MIT license, as the README's provenance table
  states, read directly from the vendored file.

**One minor imprecision found (not a C1 defect).** The README's provenance table
labels `2026-09-17 13:19:50 +1200` as the "commit date". Git distinguishes
author date from committer date here:

```bash
git -C /tmp/r101review log -1 --format='author=%ai%ncommitter=%ci'
```

```
author=2026-09-17 13:19:50 +1200
committer=2026-09-17 13:28:32 +1200
```

`13:19:50` is the **author** date; the **committer** date is `13:28:32`. Both
belong to Thomas Mansencal. The value is correct and sourced, only the field
label is loose. Affects nothing about byte-identity; worth a one-word fix in the
README if a later seat touches it.

**No drift during review.** The vendored tree was re-hashed at the end of the
review and the hash list is unchanged (`NO_DRIFT_DURING_REVIEW_OK`), so the
verdict applies to the tree as it stands now, not to a stale snapshot.

---

## 7. Reproduce

```bash
rm -rf /tmp/r101review && git clone \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r101review
git -C /tmp/r101review rev-parse HEAD    # expect a6aa73ada02a9fb1f5415bec491f9942c519b297

cd corpus/knowledge/unreal-mcp/upstream
find . -type f | wc -l                   # 12
cd ..
sha256sum -c .manifest.d/audit-reference.sha256          # all OK, exit 0
sha256sum -c .manifest.d/audit-reference.sha256 .manifest.d/seat*.sha256   # 24 OK, exit 0

# set-difference both ways (expect both empty)
comm -3 <(git -C /tmp/r101review ls-files | sort) \
        <(cd upstream && find . -type f | sed 's|^\./||' | sort)
```

## 8. Verdict statement

**C1 holds.** Denominator established independently (12 tracked files, no
untracked, no symlinks/submodules/LFS); vendored set equals it exactly; all 12
byte-identical across four transports; provenance manifest present, self-hashing
correctly, passing both a positive and a negative control. The only residual
items are a brief/README count disagreement (12 is right, 11 is wrong) and a
loose "commit date" field label — neither touches byte-identity. `PROVENANCE.md`
and `adaptation-kimi.md`, advertised in the README Layout, did not exist at
review time; they are C2/C3 deliverables, outside this seat's C1 scope.

**Evidence label: `verified-here`** — every hash, count and exit code above was
produced by a command run on this host during this review. No live-editor claim
is made or implied.
