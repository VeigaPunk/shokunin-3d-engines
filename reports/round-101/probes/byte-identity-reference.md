# SEAT-15 PROBE — byte-identity reference for the vendored Unreal skills plugin

Round: r101 (game-dev-3d shokunin, Unreal Engine skills integration).
Seat: SEAT-15 PROBE. Axis served: **coverage** (C1) — an independent byte-identity
reference against which every vendor seat's work is checkable.

Deliverables written by this seat:

| Path | Purpose |
| --- | --- |
| `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` | sha256 of every upstream content file, at the same repo-relative paths the vendors use |
| `reports/round-101/probes/byte-identity-reference.md` | this note: commands run and observed output |

Nothing else in the repo was touched. No commit was made (L1 lands the round commit).

## Provenance

- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
- Pinned SHA: `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`)
- Independent clone used for this reference: `/tmp/r101-audit` (fresh, deleted and re-cloned)
- Host: `Linux 7.2.3-arch1-3 x86_64`, 32 cores, `git version 2.55.0`, probe run `2026-10-18T17:14:26Z`

The reference was produced from a **fresh clone**, not from the pre-existing
`/tmp/ue-skills-ref` and not from the vendored copy, so it cannot inherit a
mistake made while vendoring.

## 1. Fresh clone and SHA verification

```
$ rm -rf /tmp/r101-audit && git clone --quiet \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r101-audit
clone exit=0

$ cd /tmp/r101-audit && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ git log --oneline -1
a6aa73a [MCP] Permit safe concurrent tool calls

$ git status --porcelain | wc -l
0
```

Cross-checks on the clone:

```
$ git rev-parse --abbrev-ref HEAD
main

$ [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] && echo "HEAD == origin/main"
HEAD == origin/main

$ git tag -l | head
(no output — repo carries no tags)

$ git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main

$ git log -1 --format='%H%n%an <%ae>%n%ad%n%s' --date=iso-strict
a6aa73ada02a9fb1f5415bec491f9942c519b297
Thomas Mansencal <thomas.mansencal@epicgames.com>
2026-09-17T13:19:50+12:00
[MCP] Permit safe concurrent tool calls

$ git rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959

$ git rev-parse --is-shallow-repository
false
```

**Result: clone HEAD equals the pin exactly.** The reference is therefore anchored
to the intended revision, and the working tree is clean (no post-clone mutation).

## 2. Enumerating the upstream content set

```
$ git ls-files | sort
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

$ git ls-files | wc -l
12

$ git ls-files -s | awk '$1=="120000"||$1=="160000"'
(no output — no symlinks, no gitlinks/submodules)

$ ls .gitattributes
ls: cannot access '.gitattributes': No such file or directory

$ find . -path ./.git -prune -o -type f -print | wc -l
12
```

**Content set = the 12 tracked regular files.** Tracked-file count equals
on-disk file count, so nothing untracked exists to vendor. There are no symlinks,
no submodules, no Git LFS pointer files and no `.gitattributes`; the plain-file
enumeration is therefore complete and no special-casing is required.

## 3. The reference manifest

Produced with a fresh per-file hash of the clone, then rewritten to the
`upstream/…` prefix that the vendor seats use:

```
$ cd /tmp/r101-audit && git ls-files | sort | while IFS= read -r f; do \
    printf '%s  upstream/%s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$f"; done \
    > /tmp/audit-manifest.txt
$ wc -l < /tmp/audit-manifest.txt
12
```

Written to `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` with a
6-line provenance header (`#` comments, ignored by `sha256sum -c`). Full contents:

```
# SEAT-15 PROBE — audit-reference manifest (byte-identity reference)
# upstream: https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
# pinned SHA: a6aa73ada02a9fb1f5415bec491f9942c519b297 (main)
# produced: fresh clone at /tmp/r101-audit, git rev-parse HEAD verified equal to pin
# scope: every tracked file (git ls-files), 12/12; no symlinks, no submodules, no LFS, no .gitattributes
# verify: cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  upstream/.claude-plugin/plugin.json
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  upstream/CODEOWNERS
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  upstream/.gitignore
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  upstream/hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  upstream/hooks/unreal-context.sh
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  upstream/LICENSE
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  upstream/skills/create-toolset/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  upstream/skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  upstream/skills/unreal-mcp/references/setup.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  upstream/skills/unreal-mcp/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  upstream/skills/unreal-skill/SKILL.md
```

Self-hash of the manifest file itself:

```
$ sha256sum corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
```

## 4. Verification of the manifest (positive control)

Replayed from inside the vendored directory — the exact command printed in the
manifest header:

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
vendored-verify-exit=0
```

The same rows were also replayed against the fresh clone, with the `upstream/`
prefix stripped, to confirm the manifest describes the clone rather than the
vendored tree it was compared against:

```
$ cd /tmp/r101-audit && sha256sum -c /tmp/clone-verify.sha256
… 12 lines …
12/12 OK, clone-verify-exit=0
```

## 5. Independent second method — git blob identity

sha256 equality plus a tree walk is one method; git's own object hashing is an
independent one, and it also catches mode differences and content that
`sha256sum -c` would only catch by path.

```
$ cd corpus/knowledge/unreal-mcp/upstream && for f in $(cd /tmp/r101-audit && git ls-files | sort); do \
    v=$(git hash-object "$f"); c=$(cd /tmp/r101-audit && git rev-parse "HEAD:$f"); \
    [ "$v" = "$c" ] && s=MATCH || s=MISMATCH; printf '%-46s %s\n' "$f" "$s"; done
.claude-plugin/plugin.json                     MATCH
CODEOWNERS                                     MATCH
.gitignore                                     MATCH
hooks/hooks.json                               MATCH
hooks/unreal-context.sh                        MATCH
LICENSE                                        MATCH
README.md                                      MATCH
skills/create-toolset/SKILL.md                 MATCH
skills/unreal-mcp/references/operations.md     MATCH
skills/unreal-mcp/references/setup.md          MATCH
skills/unreal-mcp/SKILL.md                     MATCH
skills/unreal-skill/SKILL.md                   MATCH
```

**12/12 MATCH by git blob SHA against `HEAD:<path>` of the pinned clone.**

Whole-tree structural diff, which additionally catches files present on one side
only (sha256 lists alone would not):

```
$ diff -r --no-dereference /tmp/r101-audit \
    corpus/knowledge/unreal-mcp/upstream -x .git
diff-exit=0
(no output)
```

**Exit 0 with no output = the vendored tree and the pinned clone are identical as
directory trees**, including absence of extra or missing files.

File modes and types (vendors must not have re-encoded or `chmod`-ed anything):

```
$ find . -type f | sort | xargs -I{} stat -c '%a %n' {} | sort -u
644 ./.claude-plugin/plugin.json
644 ./CODEOWNERS
… all 12 files at 644 …

$ for f in $(find . -type f | sort); do printf '%-46s %s\n' "$f" "$(file -b "$f")"; done
./.claude-plugin/plugin.json                   JSON text data
./CODEOWNERS                                   ASCII text
./.gitignore                                   ASCII text
./hooks/hooks.json                             JSON text data
./hooks/unreal-context.sh                      Bourne-Again shell script, ASCII text executable
./LICENSE                                      ASCII text
./README.md                                    ASCII text, with very long lines (583)
./skills/create-toolset/SKILL.md               Unicode text, UTF-8 text, with very long lines (1069)
./skills/unreal-mcp/references/operations.md   ASCII text, with very long lines (379)
./skills/unreal-mcp/references/setup.md        ASCII text, with very long lines (460)
./skills/unreal-mcp/SKILL.md                   Unicode text, UTF-8 text, with very long lines (1030)
./skills/unreal-skill/SKILL.md                 Python script, Unicode text, UTF-8 text executable, with very long lines (1056)
```

All 12 are plain regular files at mode 644 — no CRLF artefacts, no binary
transcoding, no stray executable bit. Total vendored bytes:

```
$ find . -type f -printf '%s\n' | awk '{s+=$1} END{print s}'
63556
```

Per-file sizes are recorded in the table below for cross-checking any future
re-vendor without re-hashing.

| repo-relative path | bytes |
| --- | --- |
| `.claude-plugin/plugin.json` | 487 |
| `CODEOWNERS` | 64 |
| `.gitignore` | 203 |
| `hooks/hooks.json` | 357 |
| `hooks/unreal-context.sh` | 3101 |
| `LICENSE` | 1073 |
| `README.md` | 8398 |
| `skills/create-toolset/SKILL.md` | 23258 |
| `skills/unreal-mcp/references/operations.md` | 6497 |
| `skills/unreal-mcp/references/setup.md` | 6065 |
| `skills/unreal-mcp/SKILL.md` | 7098 |
| `skills/unreal-skill/SKILL.md` | 6955 |

## 6. Negative control — the manifest discriminates

A manifest that passes everything is worthless. A copy of the vendored tree was
made in `/tmp/negctl`, one byte appended to `upstream/hooks/unreal-context.sh`,
and the manifest replayed:

```
$ printf 'echo tamper\n' >> /tmp/negctl/upstream/hooks/unreal-context.sh
$ cd /tmp/negctl && sha256sum -c m.sha256 | grep -v ': OK$'
upstream/hooks/unreal-context.sh: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
negctl-exit=1
```

**Exactly one row failed, exit 1.** The manifest detects single-file content
drift and does not mask it. (Note the limitation honestly: sha256+path checking
cannot detect a *swap* of two files with identical content, but §5's whole-tree
`diff` and the file-count check do cover added/removed files.)

## 7. Cross-check against the sibling vendor seats

At probe time the sibling seats had written 11 single-file manifests into the
same `.manifest.d/` directory (seats 01–11). Every row they wrote was compared
against this reference:

```
$ for f in corpus/knowledge/unreal-mcp/.manifest.d/seat*.sha256; do echo "--- $f"; cat "$f"; done
--- seat01: 483693ad…  upstream/README.md
--- seat02: 5b337be0…  upstream/LICENSE
--- seat03: 5aa98484…  upstream/.claude-plugin/plugin.json
--- seat04: 259124f0…  upstream/hooks/hooks.json
--- seat05: d3f1c871…  upstream/hooks/unreal-context.sh
--- seat06: 7ef8b991…  upstream/skills/unreal-mcp/SKILL.md
--- seat07: dbed002b…  upstream/skills/unreal-mcp/references/operations.md
--- seat08: bd16206e…  upstream/skills/unreal-mcp/references/setup.md
--- seat09: e9d05008…  upstream/skills/create-toolset/SKILL.md
--- seat10: 7a0af781…  upstream/skills/unreal-skill/SKILL.md
--- seat11: 653d3725…  upstream/CODEOWNERS
           0fad2f57…  upstream/.gitignore
```

All 12 rows across the 11 sibling manifests are byte-equal to the corresponding
rows of `audit-reference.sha256`, and their union covers exactly the 12-file
upstream set — no duplicate, no missing file, no hash disagreement. This is
independent confirmation of C1's byte-identity leg at the time of the probe.

## 8. Standing instructions for other seats

1. Verify a vendored file with
   `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256`.
2. If a row fails, do **not** edit the reference manifest. Re-clone to a fresh
   `/tmp` directory, re-verify `git rev-parse HEAD` against the pin, and treat a
   genuine mismatch as a finding for the L1.
3. The reference is valid only for SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
   A different upstream revision needs a new reference, not an edited one.
4. The clone at `/tmp/r101-audit` is a working copy; if it is deleted, the
   reference remains reproducible from the pin because the pinned SHA plus the
   manifest's hashes are sufficient to re-derive it.

## 9. Scope and honesty notes

- **What is proven:** at pinned SHA `a6aa73ad…`, the upstream tree contains
  exactly 12 tracked files (no symlinks/submodules/LFS); every one is vendored at
  the same repo-relative path with an identical sha256 and identical git blob
  hash; the vendored tree is structurally identical to the clone (`diff -r` exit
  0); the manifest detects tampering (negative control fails exactly one row).
- **What is not proven:** anything about *executing* the upstream skills. This
  seat is a byte-identity reference only. Unreal Editor is not installed on this
  host, and live-editor MCP runtime claims remain unproven-on-this-host by
  construction — those are other seats' verdicts to label.
- **Residual risk:** the reference is a point-in-time snapshot of a *public*
  repo at a pinned SHA. Upstream could force-push or delete the repository,
  which would break re-derivation; the manifest's recorded hashes plus this
  note's blob SHAs (`HEAD^{tree}` = `b5b9624b00fc90217240e823406699d0ab78b959`)
  are the durable record if that happens.
