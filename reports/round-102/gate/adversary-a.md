# SEAT-20 GATE-ADVERSARY-A — content-corruption attack on `gate/run_gate.sh`

**Seat:** SEAT-20 GATE-ADVERSARY-A · round 102 · lane `game-dev-3d-shokunin`
**Owned path:** this file only. Nothing under the byte-pinned r101 subtree was modified
(see *Integrity note* at the end).
**Target:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
`sha256 = 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` (200 lines)
**Target spec:** `corpus/knowledge/unreal-mcp/gate/README.md`
`sha256 = def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`
**Date:** 2026-10-18 · **Method:** every scenario executed on this host against a `/tmp` copy of
the subtree; raw logs kept in `/tmp/advgate/log-*.txt`.

Baseline before attacking, on the real tree:

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
PATH_EXTRA=0 PATH_MISSING=0  BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
exit=0
```

The gate is **cwd-independent** and **locale-independent** — verified: `LC_ALL` ∈ {C, C.utf8,
en_US.utf8, POSIX} all exit 0; running from `/tmp` exits 0. So neither locale nor cwd is a hole.

## Verdict

The gate is **fail-closed against every hash, path-set and deletion mutation** I could plant: a
flipped byte, a deleted file, a stray file, a dropped manifest line, a renamed manifest, and all
six of the README's own controls (C1–C6) turn it red. That is the right core.

But it has **six classes of content-level false-pass** — a tree carrying a real corruption still
prints `GATE RESULT: PASS (checks failed: 0)` and exits 0. All six are **demonstrated below by
execution, with the mutation confirmed applied** (I re-checked `ls`/`find`/`sed -n` that each
edit actually landed before trusting the gate's exit code — an unapplied mutation would make the
result meaningless).

The common cause is that all four checks reason about *the files they already know to look at*.
Three of the four (`find -type f`, `-maxdepth 1 -name '*.md'`, the `upstream/…:N` pointer
pattern) are **enumerations with holes**, and the manifest sweep checks one manifest, not the
set. A file, link, or pointer that falls outside an enumeration is not "verified-and-passed";
it is **never seen**.

| # | hole | demonstrated by | severity |
|---|---|---|---|
| F1 | non-regular file in a pinned tree is invisible | H2, H2b, H3 | **high** — arbitrary content enters `upstream/` |
| F2 | nested file under `executability/` is invisible | H4 | medium — a 14th card is never scanned |
| F3 | label token matched as a substring | H1, H1b | medium — a *negated* label counts as its opposite |
| F4 | CRLF manifest accepted silently | H14 | low |
| F5 | per-seat manifests are never verified | H13, H22 | medium |
| F6 | pointer sweep has four enumeration gaps | H5, H6, H6b, H20, H21 | medium |

## F1 — a symlink (or any non-regular file) in a pinned tree is invisible — HIGH

`CHECK 2` builds its vendored path-set with `find . -type f` (line 96) and its byte check reads
`sha256sum "$SUB/upstream/$f"` over the **clone's** file list (lines 104–108). A symlink is
`-type l`, not `-type f`, so it is in neither list; and the clone has no such path, so the blob
loop never looks at it. `CHECK 3`'s card enumeration is also `-type f`.

```sh
# on a /tmp copy:
ln -s /tmp/advgate/payload.md  corpus/knowledge/unreal-mcp/upstream/backdoor.md
printf 'ATTACKER CONTROLLED BYTES\n' > /tmp/advgate/payload.md
```

Observed — gate is **green**:

```
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)   exit=0
```

Confirmed applied: `find upstream -type f | wc -l` → `12` (link not counted);
`find upstream -type l | wc -l` → `1`. A symlink whose *name* mimics a real file
(`upstream/extra-note.md → payload2/README.md`) behaves identically. The same trick plants a
**14th card** that `CHECK 3` never sees: `ln -s evilcard.md executability/zz-evil.md` →
`CARDS=13 … GATE RESULT: PASS`.

**Minimal hardening (verified).** Reject any non-regular entry in the pinned trees, before the
checks run:

```sh
NONREG=$(find "$SUB/upstream" "$SUB/executability" "$SUB/.manifest.d" ! -type f ! -type d)
[ -n "$NONREG" ] && { printf 'FAIL non-regular file in pinned tree:\n%s\n' "$NONREG"; FAILS=$((FAILS+1)); }
```

(`! -type d` is required — without it, every real directory is a false positive; I hit exactly
that false positive on the first draft of this patch.)

## F2 — a nested file under `executability/` is invisible — MEDIUM

`CHECK 3` enumerates `find "$SUB/executability" -maxdepth 1 -type f -name '*.md'` (line 130).
`-maxdepth 1` means anything in a subdirectory is never enumerated, so `CARDS` stays 13 and
`BAD` stays 0.

```sh
mkdir -p corpus/knowledge/unreal-mcp/executability/sub
printf '# evil card\n**Label:** `verified-here`\n' > .../executability/sub/zz-evil.md
```

Observed: `CARDS=13 EXPECTED=13 BAD=0` → **PASS**. Confirmed applied:
`find executability -name '*.md' | wc -l` → `14` vs `-maxdepth 1 … | wc -l` → `13`. Note the
planted card declares `verified-here`, the one label the gate's pinned census exists to forbid.

**Minimal hardening (verified).**

```sh
NESTED=$(find "$SUB/executability" -mindepth 2)
[ -n "$NESTED" ] && { printf 'FAIL nested entry under executability/:\n%s\n' "$NESTED"; FAILS=$((FAILS+1)); }
```

## F3 — the label token is matched as a substring — MEDIUM

`CHECK 3` uses `ALLOWED='verified-here|static-only|unproven-runtime'` with `grep -oE`, unanchored
(lines 129, 138–139). So a token embedded in a longer word is a valid label.

```sh
sed -i '4s/.*/**Label:** `NOT-static-only`/'     .../executability/blueprints.md   # H1
sed -i '4s/.*/**Verdict:** `static-onlyness`/'   .../executability/blueprints.md   # H1b
```

Observed for both: `OK static-only blueprints.md line 4`, `CENSUS static-only=12 …` → **PASS**.
The first is the worst case: a card that explicitly says it is **not** `static-only` is counted
*as* `static-only`, inflating the census with a card whose label is the negation of its meaning.
(The spec's own rule 3, "a prose sentence like 'this is not `verified-here`' is not mistaken for
a declaration", is implemented only as a bold/heading test on the *line* — it does not defend
against the negation appearing **inside** a bolded label line.)

**Minimal hardening (verified).** Anchor the token to word boundaries:

```sh
ALLOWED='(^|[^A-Za-z0-9-])(verified-here|static-only|unproven-runtime)([^A-Za-z0-9-]|$)'
TOKENS='verified-here|static-only|unproven-runtime'   # for the -oE count/census, keep as-is or anchored
```

After this, `NOT-static-only` and `static-onlyness` carry **no** allowed token, so the scan falls
through to the next matching line — and both plants then fail with `FAIL label-too-deep` (they
land at line 97), i.e. the card no longer declares a label in its first 40 lines. Verified.

## F4 — a CRLF manifest is accepted silently — LOW

`CHECK 1` is `sha256sum -c`, which strips a trailing `\r` from the path field. So a manifest
converted to CRLF verifies fine.

```sh
sed -i 's/$/\r/' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
```

Observed: `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` → **PASS**. Confirmed applied:
`od -c` shows `… 342 200 224 …` with `\r` before each `\n`. This matters because it means the
committed manifest is not a byte-stable artifact — a CRLF-converted or CRLF-mixed manifest is
indistinguishable from the original to the gate, and `.manifest.d/` is not itself pinned.

**Minimal hardening (verified).**

```sh
CRFILES=$(grep -lU $'\r' "$SUB"/.manifest.d/*.sha256 2>/dev/null)
[ -n "$CRFILES" ] && { printf 'FAIL CR byte in manifest:\n%s\n' "$CRFILES"; FAILS=$((FAILS+1)); }
```

## F5 — the per-seat manifests are never verified — MEDIUM

`CHECK 1` reads only `.manifest.d/audit-reference.sha256` (line 58). The twelve `seat*.sha256`
manifests are read by **nothing** — not check 1, not check 2 (which uses the clone's blobs), not
the pointer sweep (they are under `.manifest.d/`, which no pointer pattern matches). They are
dead weight the gate appears to vouch for.

```sh
# H13: corrupt one seat manifest
printf 'deadbeef00…00  upstream/README.md\n' > .../.manifest.d/seat01.sha256
# H22: empty ALL seat manifests
for m in .../.manifest.d/seat*.sha256; do printf '# cleared\n' > "$m"; done
```

Observed for both: `MANIFEST_OK=12 … GATE RESULT: PASS` → **PASS**.

**Minimal hardening (verified).** Sweep every manifest, strictly, and count them:

```sh
(cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/dev/null 2>&1) \
  || { printf 'FAIL per-seat manifest sweep (--strict) failed\n'; FAILS=$((FAILS+1)); }
printf 'MANIFEST_FILES=%s\n' "$(find "$SUB/.manifest.d" -maxdepth 1 -name '*.sha256' | wc -l)"
```

`--strict` is what makes coreutils treat an improperly-formatted line as an error; without it a
garbage line is a warning and the exit stays 0 (verified separately: `sha256sum -c` on a
manifest with one good line and one garbage line → `exit=0`; with `--strict` → `exit=1`).

## F6 — the pointer sweep has four enumeration gaps — MEDIUM

`CHECK 4` greps a single pattern (line 192):
`upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+`. Four demonstrated escapes:

| # | input | why it is invisible | observed |
|---|---|---|---|
| H5 | `` `executability/ghost.md:12` `` | pattern requires the `upstream/` prefix | `POINTERS=40 … PASS` |
| H6 | `upstream/a b.md:5` | space not in the char class | `POINTERS=40 … PASS` |
| H6b | `upstream/skills/x+y.md:5` | `+` not in the char class | `POINTERS=40 … PASS` |
| H21 | `upstream/README.md:0` | range test is `-gt` only, so line 0 passes | `POINTERS=41 … PASS` |

H20 adds a fifth: the sweep's file enumeration is `find "$SUB" -name '*.md'` (line 193) — a file
named `NOTES.MD` is not scanned, so a dangling pointer inside it is invisible.

The most consequential is H5: `CHECK 4` only audits pointers into the **vendored** tree, so a
dangling reference to a *sibling* artifact — e.g. a card citing `executability/ghost.md` that does
not exist — is never checked. A card's cross-references are exactly the kind of pointer a
reviewer relies on the gate to validate.

**Minimal hardening (verified).**
- add `-iname` to the file enumeration (line 193) and a lower bound to the range test:
  ```sh
  [ "$ln" -lt 1 ] && { printf 'LINE-ZERO %s :: %s\n' "$f" "$ptr"; P_BAD=$((P_BAD+1)); }
  ```
- widen the char class to admit spaces/plus: `upstream/[^`"|)]+\.[A-Za-z0-9]+:[0-9]+`.
- add a second sweep for subtree- and repo-relative backtick pointers
  (`` `executability/x.md:12` ``, `` `corpus/.../y.md` ``, `` `reports/.../z.md` ``), resolving
  each against the subtree root or the repo root as appropriate. **Caveat found while building
  this:** in `grep -E`, an escaped backtick `\`` inside the pattern silently matches **nothing**
  (verified: `\`…\`` → 0 hits, `[`]…[`]` → 220 hits). Use a bracket class, not `\``.

## Sentinel exclusion — working as designed, with one residual

`H16` planted 30 copies of the control sentinel `upstream/README.md:9999`; the gate stayed green
with `SKIPPED_CONTROL_SENTINELS=1` — the `sort -u` collapses identical lines, so the counter
cannot distinguish 1 from 30 (cosmetic; the exclusion itself is exact and correct). The residual
is inherent to an exact-match filter: an author who cites `upstream/README.md:500` or
`upstream/nope.md:N` in earnest writes a pointer the gate will **always skip**, because those
exact strings are the sentinels. Line 500 of a 112-line file is a real defect the filter masks.
Low severity and a deliberate trade-off, but it means `SKIPPED_CONTROL_SENTINELS` is a
*necessary* signal to watch, not a purely cosmetic counter.

## The hardened variant

A single patched copy implementing every recommendation above is at
`/tmp/advgate/hardened.sh` (`sha256 = 372d179f2261637e6f3b65ca4b162448219b84ede5a3ba40f3e9914ad473b4a8`,
245 lines). It is a **scratch artifact, not landed** — it exists to prove each recommendation
works, rather than assert it.

- Clean baseline: `GATE RESULT: PASS (checks failed: 0)`, `exit=0`, and the four pinned summary
  lines are **unchanged** (`MANIFEST_OK=12`, `CARDS=13`, `CENSUS 12/1/0`, `POINTERS=40`). No
  false positive introduced.
- All six README controls (C1–C6) still turn it red — no regression on the author's own matrix.

Every attack, re-run against the hardened copy (`/tmp/advgate/log-hardened.txt`):

| attack | real gate | hardened |
|---|---|---|
| H2 symlink in `upstream/` | PASS | **detected** (non-regular file) |
| H3 14th card as symlink | PASS | **detected** |
| H4 14th card in subdir | PASS | **detected** (nested entry) |
| H1 `NOT-static-only` | PASS | **detected** (label-too-deep) |
| H1b `static-onlyness` | PASS | **detected** |
| H5 subtree-relative dangling ptr | PASS | **detected** (MISSING-PATH-REL) |
| H6 space in pointer name | PASS | **detected** |
| H14 CRLF manifest | PASS | **detected** (CR byte) |
| H22 all seat manifests emptied | PASS | **detected** (strict sweep) |
| H21 `:0` pointer | PASS | **detected** (LINE-ZERO) |
| H20 uppercase `.MD` | PASS | **detected** |

11/11 flipped. Minimality was preserved deliberately: every patch is a few lines, and I rejected
the one shortcut that looked attractive — a keyword filter on the pointer sweep — because the
gate's README already documents that a keyword filter would eat real pointers (its "control" /
"expect" / "plant" example). The recommendations extend the enumerations; they do not add
heuristics.

## What this report does not cover

- **No Unreal runtime claim.** Nothing here concerns the editor; the editor is not installed. A
  green gate — hardened or not — is evidence about *bytes*, never about editor behavior.
- **Semantic label correctness.** `CHECK 3` enforces one label per card mechanically. Whether a
  `static-only` card actually rests on a static check that ran here is a read-the-cards
  judgement, and none of my findings change that.
- **Invocation/environment robustness** (missing `git`, empty `PATH`, symlinked script, read-only
  tree) is SEAT-21 GATE-ADVERSARY-B's axis; I did not re-derive it.

## Reproduction

```sh
# real gate, content attacks (never touches the live repo — all mutations under /tmp)
bash /tmp/advgate/real_attacks.sh    # -> /tmp/advgate/log-real-attacks.txt
bash /tmp/advgate/final_attacks.sh   # -> /tmp/advgate/log-final-attacks.txt
# hardening verification
bash /tmp/advgate/verify_hardened.sh # -> /tmp/advgate/log-hardened.txt
bash /tmp/advgate/controls.sh        # C1..C6 against both gates -> /tmp/advgate/log-controls.txt
```

The harnesses operate **only** on absolute paths under `/tmp` and never `cd` into the live repo.

## Integrity note (disclosure)

While developing the harness I hit a bug in an *early* version of it — an attack function `cd`-ed
back to the live repo root instead of the `/tmp` copy — and two vendored files
(`upstream/README.md`, `upstream/skills/unreal-mcp/SKILL.md`) were truncated in the live tree for
one tool call. I detected it immediately, restored both **byte-exactly** from the git object store
(`git show HEAD:<path>`, no checkout/reset), and re-verified: `sha256sum -c
.manifest.d/audit-reference.sha256` → `12/12 OK`, and the live gate returns `exit=0` with
`MANIFEST_OK=12`. The gate's own `sha256` is unchanged (`214bf8ef…`). The final harness is
hardened against this class of mistake; every result above comes from the fixed version.
