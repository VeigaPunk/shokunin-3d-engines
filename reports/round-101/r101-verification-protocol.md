# r101 close-out verification protocol

**Seat:** SEAT-64 VERIFIER-CHAIR · round 101 · lane `game-dev-3d-shokunin`
**Executed by:** the L1 at round close, on the committed round-101 tree.
**Audience:** a **non-author** verifier. Every step below was written so that it can be
run without trusting any author's transcript — each step re-derives its own evidence.
**Date written:** 2026-10-18

Round axes: depth / coverage / calibration. Coverage is the lowest non-retired axis.
This protocol gates the three r101 claims:

| claim | axis | what must hold at close |
|---|---|---|
| **C1** | coverage | all upstream content files vendored byte-identical under `corpus/knowledge/unreal-mcp/upstream/` with a provenance manifest |
| **C2** | depth | executability assessment: **13** subsystem verdict cards, each labeled exactly one of `verified-here` \| `static-only` \| `unproven-runtime`, each with its evidence |
| **C3** | calibration | Claude→Kimi adaptation table + proven/unproven verification policy, every row carrying a **resolvable** source pointer |

**Fail-closed rule.** Any step that does not print its expected result is a FAIL for its
claim. Do not average, do not skip, do not "looks fine". A missing artifact is a FAIL, not
a warning: this round's whole point is that coverage is the weak axis, so an absent card is
exactly the defect the gate exists to catch.

**Non-author requirement.** Steps 1, 2, 4, 6 and 8 must be run by someone who did not write
the artifacts being checked. Steps 3, 5 and 7 are mechanical re-derivations and may be run
by anyone. The verifier must not accept an author's pasted output for any step whose
"expected result" is a number — re-run it and compare.

---

## 0. Preconditions and pinned constants

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
CORPUS=corpus/knowledge/unreal-mcp
WORK=/tmp/r101-closeout            # scratch; never inside the repo
mkdir -p "$WORK"
```

Materialise the four check scripts used below (they are self-contained; nothing in this
protocol depends on a leftover `/tmp` file from a seat):

```sh
cat > "$WORK/label-scan.sh" <<'EOF'
#!/usr/bin/env bash
# Verdict-card inventory + exactly-one-label scan.
# RULE (declared, not guessed): the DECLARED LABEL is the token on the FIRST line of
# the card that contains any allowed token. That line must (a) appear within the first
# 40 lines, (b) be bold/heading-marked, (c) carry exactly ONE allowed token.
# usage: label-scan.sh [dir] [expected_cards]
# shellcheck disable=SC2015  # A && B || C is intended: B ends in `exit 0`, so C is unreachable when A&&B hold
set -u
root=${1:-corpus/knowledge/unreal-mcp/executability}
expected=${2:-13}
allowed='verified-here|static-only|unproven-runtime'
cards=$(find "$root" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)
n=$(printf '%s' "$cards" | grep -c . || true)
bad=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  rec=$(grep -nE "$allowed" "$f" | head -1)
  if [ -z "$rec" ]; then printf 'FAIL no-label       %s\n' "$f"; bad=$((bad+1)); continue; fi
  ln=${rec%%:*}; text=${rec#*:}
  cnt=$(printf '%s' "$text" | grep -oE "$allowed" | wc -l)
  lab=$(printf '%s' "$text" | grep -oE "$allowed" | head -1)
  if [ "$ln" -gt 40 ]; then printf 'FAIL label-too-deep %s (line %s)\n' "$f" "$ln"; bad=$((bad+1)); continue; fi
  case "$text" in *'**'*|*'#'*) ;; *) printf 'FAIL label-unmarked %s :: %s\n' "$f" "$text"; bad=$((bad+1)); continue;; esac
  if [ "$cnt" -ne 1 ]; then printf 'FAIL multi-label    %s :: %s\n' "$f" "$text"; bad=$((bad+1)); continue; fi
  printf 'OK   %-16s %-30s line %s\n' "$lab" "$(basename "$f")" "$ln"
done <<< "$cards"
printf 'CARDS=%s EXPECTED=%s BAD=%s\n' "$n" "$expected" "$bad"
[ "$n" -eq "$expected" ] && [ "$bad" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
EOF

cat > "$WORK/runtime-claim-scan.sh" <<'EOF'
#!/usr/bin/env bash
# A file that NAMES a live-editor surface must carry a label token
# (verified-here|static-only|unproven-runtime|unproven) or an explicit
# non-observation disclaimer. Quote-only mentions are not runtime claims.
# shellcheck disable=SC2015,SC2086  # A&&B||C intended (B exits); $roots is a deliberate space-split list
set -u
roots=${*:-"reports/round-101 corpus/knowledge/unreal-mcp"}
surface='list_toolsets|describe_toolset|call_tool|execute_tool_script|ModelContextProtocol\.StartServer'
label='verified-here|static-only|unproven-runtime|unproven'
disclaimer='never invoked|not observed|not executed|documented, not|no editor|not installed|was never|unproven-on-this-host'
hits=0; files=0; ok=0
for root in $roots; do
  while IFS= read -r f; do
    case "$f" in */upstream/*) continue;; esac
    grep -qE "$surface" "$f" || continue
    files=$((files+1))
    if grep -qE "$label" "$f"; then ok=$((ok+1)); continue; fi
    if grep -qiE "$disclaimer" "$f"; then ok=$((ok+1)); printf 'DISCLAIMED %s\n' "$f"; continue; fi
    printf 'UNLABELED %s\n' "$f"; hits=$((hits+1))
  done < <(find $root -name '*.md' -type f | sort)
done
printf 'RUNTIME_NAMED_FILES=%s LABELED_OR_DISCLAIMED=%s UNLABELED=%s\n' "$files" "$ok" "$hits"
[ "$hits" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
EOF

cat > "$WORK/pointer-check.sh" <<'EOF'
#!/usr/bin/env bash
# Pointers are written `upstream/<path>:<line>`; they resolve against the corpus root.
# EXCLUSIONS, all deliberate and all printed so they cannot hide a real failure:
#   * anything under upstream/ — the vendored upstream text is not this round's artifact;
#   * this protocol file itself — it is the CHECKER'S OWN SPECIFICATION. Its control blocks
#     plant deliberately-broken pointers (upstream/nope.md, upstream/README.md:9999,
#     upstream/README.md:500) and its worked examples quote pointers in prose. Auditing a
#     checker against its own specification is a false positive by construction. Step 7's
#     hand-sample separately verifies that this file's EXAMPLE pointers are real, so nothing
#     is being waved through.
#   * EXACT control sentinels — kept as a second line of defence, because peers' reports
#     quote the protocol verbatim and would otherwise re-import its broken strings.
#     This is an EXACT-match filter, NOT a keyword filter: a real pointer that happens to
#     sit on a line containing the word "control" (e.g. a hook-escaper finding) is still
#     counted. The skip count is printed as SKIPPED_CONTROL_SENTINELS.
# shellcheck disable=SC2015,SC2086  # A&&B||C intended (B exits); $roots is a deliberate space-split list
set -u
roots=${*:-"reports/round-101 corpus/knowledge/unreal-mcp"}
base=corpus/knowledge/unreal-mcp
self=reports/round-101/r101-verification-protocol.md
sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
total=0; bad=0; skipped=0
for root in $roots; do
  while IFS= read -r f; do
    case "$f" in */upstream/*|"$self") continue;; esac
    while IFS= read -r ptr; do
      if printf '%s' "$ptr" | grep -qE "^($sentinel)$"; then skipped=$((skipped+1)); continue; fi
      p=${ptr%:*}; ln=${ptr##*:}
      total=$((total+1))
      if [ ! -f "$base/$p" ]; then printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; bad=$((bad+1)); continue; fi
      n=$(wc -l < "$base/$p")
      [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; bad=$((bad+1)); }
    done < <(grep -ohE "upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+" "$f" | sort -u)
  done < <(find $root -name '*.md' -type f | sort)
done
printf 'POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$total" "$skipped" "$bad"
[ "$bad" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
EOF

cat > "$WORK/linkcheck.sh" <<'EOF'
#!/usr/bin/env bash
# Relative markdown link check over the vendored tree. Fenced code blocks excluded.
set -u
root=${1:-corpus/knowledge/unreal-mcp/upstream}
python3 - "$root" <<'PY'
import os, re, sys
root = sys.argv[1]
inline = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')
fence = re.compile(r'^\s*(```|~~~)')
broken=[]; total=0; rel=0; abs_=0; frag=0; mds=[]
for dp,_,fns in os.walk(root):
    for fn in fns:
        if not fn.endswith('.md'): continue
        p=os.path.join(dp,fn); mds.append(p); infence=False
        for ln in open(p, encoding='utf-8', errors='replace'):
            if fence.match(ln): infence = not infence; continue
            if infence: continue
            for t in inline.findall(ln):
                total+=1
                if t.startswith(('http://','https://')): abs_+=1; continue
                if t.startswith('#'): frag+=1; continue
                rel+=1; tgt=t.split('#')[0]
                if tgt and not os.path.exists(os.path.join(dp,tgt)): broken.append((p,t))
print(f"md_files={len(mds)} links_total={total} relative={rel} absolute={abs_} fragment_only={frag} broken={len(broken)}")
for p,t in broken: print("BROKEN", p, "->", t)
sys.exit(1 if broken else 0)
PY
rc=$?; [ "$rc" -eq 0 ] && echo STEP=PASS || echo STEP=FAIL; exit "$rc"
EOF
chmod +x "$WORK"/*.sh
```

Expected at the end of §0: four executable scripts in `$WORK`, exit 0 throughout.

---

## Step 1 — Provenance: fresh clone at the pin  *(C1, non-author)*

```sh
rm -rf "$WORK/clone"
timeout 120 git clone --quiet "$REPO" "$WORK/clone"
git -C "$WORK/clone" rev-parse HEAD
git -C "$WORK/clone" status --porcelain | wc -l
git -C "$WORK/clone" ls-files | wc -l
```

**Expected**

```
a6aa73ada02a9fb1f5415bec491f9942c519b297
0
12
```

Notes for the verifier:

- The clone **must be fresh**. A pre-existing `/tmp/ue-skills-ref` is acceptable as a
  convenience only after `git -C /tmp/ue-skills-ref rev-parse HEAD` is shown to equal
  `$PIN` **and** `status --porcelain` is empty. Do not skip the re-derivation.
- `HEAD` must equal `$PIN` exactly. A `main` that has moved past the pin is a FAIL for C1
  as written ("pinned at SHA"): re-vendoring against a newer commit would be a different
  claim.
- The repo is public; this step needs network. If the network is down, the step is
  **BLOCKED**, not PASS — record it and stop; do not substitute a cached clone for a
  fresh one without saying so.
- **Observed at protocol-write time (2026-10-18, this host):** clone succeeded, HEAD equals
  the pin, worktree clean, `12` tracked files.

## Step 2 — Byte-identity: manifest recompute and independent diff  *(C1)*

```sh
cd "$CORPUS"
# 2a. the committed manifests verify
sha256sum -c .manifest.d/audit-reference.sha256
sha256sum -c .manifest.d/*.sha256 2>/dev/null | wc -l
```

**Expected 2a:** 12 lines, every one `OK`, exit 0; the second command prints `24`
(12 files × the audit reference, plus the 12 files covered across the 11 seat shards —
`seat11` covers two files). **No** line may say `FAILED`.

```sh
# 2b. independent recompute, NOT read from the manifest
sha256sum $(find upstream -type f | sort) | sort -k2 > "$WORK/recomputed.txt"
grep -v '^#' .manifest.d/audit-reference.sha256 | sort -k2 > "$WORK/manifest.txt"
diff "$WORK/manifest.txt" "$WORK/recomputed.txt"
```

**Expected 2b:** empty diff, exit 0. This is the step that makes the manifest evidence
rather than an assertion: the verifier recomputes the hashes itself and compares.

```sh
# 2c. the strongest form — compare the vendored bytes to the FRESH CLONE, not to the manifest
cd "$WORK/clone"
for f in $(git ls-files); do
  a=$(git show "$PIN:$f" | sha256sum | cut -d' ' -f1)
  b=$(sha256sum "/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/$CORPUS/upstream/$f" | cut -d' ' -f1)
  [ "$a" = "$b" ] || echo "DIFF $f"
done
echo BLOBCOMPARE_DONE
```

**Expected 2c:** the single line `BLOBCOMPARE_DONE` with **no** `DIFF` lines above it.
A manifest can be regenerated from a corrupted tree; this comparison cannot.

```sh
# 2d. whole-tree diff and file-list diff
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
diff -r --exclude=.git "$CORPUS/upstream" "$WORK/clone"          # expect empty, exit 0
diff <(cd "$CORPUS/upstream" && find . -type f | sort) \
     <(cd "$WORK/clone" && git ls-files | sed 's|^|./|' | sort)   # expect empty, exit 0
```

**Expected 2d:** both diffs empty, both exit 0.

**Observed at protocol-write time:** 2a all `OK` / `24`; 2b empty diff exit 0; 2c
`BLOBCOMPARE_DONE` with no `DIFF`; 2d both exit 0.

## Step 3 — File inventory count  *(C1)*

```sh
cd "$CORPUS"
echo "vendored files: $(find upstream -type f | wc -l)   (expect 12)"
echo "vendored dirs : $(find upstream -type d | wc -l)"
echo "symlinks      : $(find upstream -type l | wc -l)   (expect 0)"
echo "submodules    : $(find upstream -name .gitmodules | wc -l)   (expect 0)"
echo "gitattributes : $(find upstream -name .gitattributes | wc -l)   (expect 0)"
echo "modes         : $(find upstream -type f -printf '%m\n' | sort -u | tr '\n' ' ')   (expect 644)"
# extras / missing vs the tracked upstream file list
comm -23 <(cd upstream && find . -type f | sed 's|^\./||' | sort) \
         <(git -C "$WORK/clone" ls-files | sort) | tee "$WORK/extras.txt" | wc -l   # expect 0
comm -13 <(cd upstream && find . -type f | sed 's|^\./||' | sort) \
         <(git -C "$WORK/clone" ls-files | sort) | wc -l                            # expect 0
```

**Expected:** `12` files, `0` symlinks, `0` submodules, `0` `.gitattributes`, modes exactly
`644`, `0` extras, `0` missing. The extras/missing pair is the real inventory check: a
vendored tree can pass every hash check and still be **incomplete** if a file was never
copied, or **over-full** if a stray file was added.

Cross-check the README's declared byte/line table (12 rows) against reality:

```sh
for p in README.md LICENSE CODEOWNERS .gitignore .claude-plugin/plugin.json \
         hooks/hooks.json hooks/unreal-context.sh skills/unreal-mcp/SKILL.md \
         skills/unreal-mcp/references/setup.md skills/unreal-mcp/references/operations.md \
         skills/create-toolset/SKILL.md skills/unreal-skill/SKILL.md; do
  printf '%-52s bytes=%-7s lines=%s\n' "$p" "$(stat -c%s upstream/$p)" "$(wc -l < upstream/$p)"
done
```

**Expected:** the counts match the table in `$CORPUS/README.md` §"`upstream/` — the 12
vendored paths" exactly:

```
README.md 8398/112 · LICENSE 1073/21 · CODEOWNERS 64/2 · .gitignore 203/4 ·
plugin.json 487/10 · hooks.json 357/17 · unreal-context.sh 3101/84 ·
unreal-mcp/SKILL.md 7098/56 · setup.md 6065/133 · operations.md 6497/51 ·
create-toolset/SKILL.md 23258/420 · unreal-skill/SKILL.md 6955/112
```

**Observed at protocol-write time:** all 12 rows matched the README table; extras 0;
missing 0.

## Step 4 — Verdict-card inventory and label scan  *(C2)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/label-scan.sh" "$CORPUS/executability" 13
```

**Expected:** exactly 13 `OK` lines (one per card), a final line
`CARDS=13 EXPECTED=13 BAD=0`, and `STEP=PASS`, exit 0.

The rule the scan enforces, stated explicitly because the cards legitimately vary in
formatting (observed forms at write time: `**Label:** \`static-only\``,
`**Label: \`static-only\`.**`, `**Verdict:** \`static-only\``,
`**Verdict label: \`static-only\`**`, `Verdict: **\`static-only\`**`):

1. The **first line containing any allowed token** is the declared label.
2. It must appear within the first 40 lines (a label buried in §7 is not a declaration).
3. It must be bold- or heading-marked (so a prose sentence like "this is not
   `verified-here`" is not mistaken for a declaration).
4. It must carry **exactly one** allowed token — a card that says
   "not `verified-here`, and not `unproven-runtime`" in its label line is ambiguous and
   fails.

Also required, and **not** machine-checkable — read the cards:

- Every card's label must be **consistent with its evidence**: a `verified-here` label
  requires a receipt of a bounded run on this host; `unproven-runtime` requires an
  identified runtime path; `static-only` is the correct label for a documented-but-
  unspecified surface. On this host, a `verified-here` label on any card is a red flag:
  Unreal Editor is not installed, so no live-editor behavior can be verified here.
- The 13 card names must be exactly the 13 domains in `$CORPUS/README.md`
  §"`executability/` — 13 subsystem verdict cards":

  ```
  actors-scene.md  blueprints.md  assets-content.md  materials.md
  meshes-textures.md  animation-controlrig.md  sequencer.md
  vfx-niagara-dataflow.md  ui-umg-slate.md  gameplay-gas.md
  testing-automation.md  editor-general.md  scripting-programmatic.md
  ```

**Observed — re-verified 2026-10-18 after the set completed.** **13/13 cards present,
`BAD=0`, `STEP=PASS`.** Twelve are labeled `static-only`; `actors-scene.md` is labeled
`unproven-runtime` (its label basis cites `corpus/knowledge/unreal-mcp/README.md:41` — the
live-editor dispatch path is fully specified but nothing was observed, which is exactly the
`unproven-runtime` criterion). Card names match the 13-name list above exactly
(`diff` → `CARD-NAMES-MATCH-EXACTLY`). No card claims `verified-here`, which is the correct
outcome on a host with no Unreal Editor.

> History for the verifier: at protocol-write time the tree held only **9 of 13** cards
> (`assets-content, blueprints, editor-general, meshes-textures, scripting-programmatic,
> sequencer, testing-automation, ui-umg-slate, vfx-niagara-dataflow`), and the scan
> correctly reported `CARDS=9 EXPECTED=13` → `STEP=FAIL` with `actors-scene.md`,
> `materials.md`, `animation-controlrig.md`, `gameplay-gas.md` missing. The four arrived
> from concurrent seats. **Re-run this step on the frozen close-out tree** — the count is a
> moving target while seats are still landing, and only the frozen state counts.

## Step 5 — Unlabeled runtime-claim scan  *(C2 / C3)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/runtime-claim-scan.sh" reports/round-101 "$CORPUS"
```

**Expected:** `UNLABELED=0` and `STEP=PASS`, exit 0. Files that name a live-editor surface
(`list_toolsets`, `describe_toolset`, `call_tool`, `execute_tool_script`,
`ModelContextProtocol.StartServer`) but make no runtime claim are printed as `DISCLAIMED`;
that is acceptable, not a failure.

**Calibrate the scan before believing it.** A scan that passes everything is worthless.
Run the negative control — it must FAIL:

```sh
rm -rf "$WORK/negctl" && mkdir -p "$WORK/negctl"
printf '# mutation probe\n\nWe ran `list_toolsets` and it returned 12 toolsets.\n' > "$WORK/negctl/assertion.md"
"$WORK/runtime-claim-scan.sh" "$WORK/negctl"; echo "expect exit 1"
```

**Expected:** `UNLABELED /tmp/r101-closeout/negctl/assertion.md`, `UNLABELED=1`,
`STEP=FAIL`, exit 1. If the control passes, the scan is broken and step 5 proves nothing.

**Observed — re-verified 2026-10-18 after more probes landed:** `RUNTIME_NAMED_FILES=26
LABELED_OR_DISCLAIMED=26 UNLABELED=0` → `STEP=PASS` (two files,
`probes/security-surface.md` and `probes/skill-frontmatter.md`, were `DISCLAIMED` — both
quote upstream text and explicitly state the tools were never invoked). The negative
control correctly printed `UNLABELED=1` / `STEP=FAIL`, exit 1. **The file count is not a
stable number** — it rose 22 → 25 → 26 across this session's re-runs as seats landed probes.
The invariant to check is `UNLABELED=0`, never the total.

## Step 6 — Link check  *(C3)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/linkcheck.sh" "$CORPUS/upstream"
```

**Expected:** `broken=0` and `STEP=PASS`, exit 0. Fenced code blocks are excluded, so C++
lambda captures such as `[this]()` inside a ```` ```cpp ```` block are correctly not
counted as links.

Negative control — must FAIL:

```sh
rm -rf "$WORK/negctl2" && mkdir -p "$WORK/negctl2"
printf '# x\n\nSee [gone](./nope.md).\n' > "$WORK/negctl2/a.md"
"$WORK/linkcheck.sh" "$WORK/negctl2"; echo "expect exit 1"
```

**Expected:** `broken=1`, `BROKEN ... -> ./nope.md`, `STEP=FAIL`, exit 1.

**Observed at protocol-write time:** real run `md_files=6 links_total=3 relative=2
absolute=1 fragment_only=0 broken=0` → `STEP=PASS`; control `broken=1` → `STEP=FAIL`.

## Step 7 — Source-pointer resolution  *(C3)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/pointer-check.sh" reports/round-101 "$CORPUS"
```

**Expected:** `UNRESOLVED=0` and `STEP=PASS`, exit 0. C3 requires that **every row carries
a resolvable source pointer**; this step mechanically resolves each
`upstream/<path>:<line>` against the corpus root and bounds-checks the line number.
`SKIPPED_CONTROL_SENTINELS` is informational — it must be a small number (the two control
strings, repeated wherever the protocol is quoted), and a large or growing value would mean
the filter is eating real pointers.

**Do not "fix" a FAIL by adding a keyword exclusion.** During authoring, this step initially
failed on the protocol file's own control strings; a naive keyword filter (`control|expect|
plant`) would have silently skipped a **real** pointer at
`probes/security-surface.md` — a hook-escaper finding whose line happens to say
"control chars". The rule is therefore: exclude the checker's own specification file, plus an
**exact sentinel match** on the impossible control strings — never a keyword match.

Negative control — must FAIL:

```sh
rm -rf "$WORK/negctl3" && mkdir -p "$WORK/negctl3"
printf '# x\n\nsee upstream/README.md:9999 and upstream/nope.md:3 and upstream/README.md:200\n' > "$WORK/negctl3/a.md"
"$WORK/pointer-check.sh" "$WORK/negctl3"; echo "expect exit 1"
```

**Expected:** the two sentinels are skipped; `LINE-OOR` is reported for
`upstream/README.md:200` — a plausible-looking, non-sentinel, out-of-range pointer, which
proves the filter skips only the exact control strings; `UNRESOLVED=1`, `STEP=FAIL`, exit 1.
(Do **not** use `README.md:500` in this control: that string appears in the protocol's own
worked examples and is therefore itself a sentinel.)

Then hand-verify a sample. A pointer can resolve and still point at the wrong content:

```sh
for p in upstream/README.md:90 upstream/skills/unreal-mcp/references/setup.md:14 upstream/hooks/hooks.json:6; do
  f=${p%:*}; l=${p##*:}; echo "--- $p"; sed -n "${l}p" "$CORPUS/$f"
done
```

**Expected:** line 90 of `README.md` is the `execute_tool_script` security warning; line 14
of `setup.md` is the two-plugins requirement; line 6 of `hooks.json` is the
`"startup|resume|clear"` matcher. **Observed — re-verified 2026-10-18:** exactly those three
lines, and `POINTERS=78 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` → `STEP=PASS` (the skip
count is 0 in the clean run because the checker's own specification file — the only place the
control strings live — is excluded; it rises only if a peer report quotes the protocol).

## Step 8 — Declared-artifact presence  *(C1 / C3)*

`$CORPUS/README.md` declares two artifacts that C3 depends on. They must exist:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
for p in "$CORPUS/README.md" "$CORPUS/PROVENANCE.md" "$CORPUS/adaptation-kimi.md"; do
  [ -f "$p" ] && echo "PRESENT $p" || echo "MISSING $p"
done
```

**Expected:** all three `PRESENT`.

- `PROVENANCE.md` — the provenance manifest required by C1 (upstream repo, pinned commit,
  per-file hash table).
- `adaptation-kimi.md` — the Claude→Kimi adaptation table plus the proven/unproven
  verification policy required by C3.

**Observed — re-verified 2026-10-18.** All three are **PRESENT**. `PROVENANCE.md` landed
from seat SEAT-12 WRITER and `adaptation-kimi.md` from seat SEAT-13 while this protocol was
being written. So both the C1 provenance manifest and the C3 adaptation table exist in the
strong form; the adaptation table carries 15 `upstream/<path>:<line>` pointers, all of which
resolve under step 7.

> History: at protocol-write time both were missing; at the first re-run `PROVENANCE.md` had
> arrived and `adaptation-kimi.md` had not. A verifier should treat step 8 as a moving target
> until the round is frozen — presence is the claim, and presence must be re-derived, not
> remembered.

## Step 9 — Static well-formedness of the vendored artifacts  *(C1, supporting)*

```sh
cd "$CORPUS"
jq -e . upstream/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
jq -e . upstream/hooks/hooks.json          > /dev/null && echo "hooks.json OK"
bash -n upstream/hooks/unreal-context.sh   && echo "bash -n OK"
shellcheck upstream/hooks/unreal-context.sh; echo "shellcheck exit $?"
```

**Expected:** `plugin.json OK`, `hooks.json OK`, `bash -n OK`, and `shellcheck exit 0`.

**Observed at protocol-write time:** all four as expected (shellcheck 0.11.0, exit 0).

## Step 10 — Host-reality re-affirmation  *(C2 label validity)*

The `static-only` / `unproven-runtime` labels rest on the claim that Unreal Editor is not
installable here. Re-affirm it; do not take it on faith:

```sh
timeout 30 git ls-remote https://github.com/EpicGames/unreal-engine HEAD 2>&1 | head -3
which UnrealEditor 2>/dev/null || echo "no UnrealEditor on PATH"
ls ~/UnrealEngine 2>/dev/null || echo "no engine tree in HOME"
```

**Expected:** `Repository not found` (the EpicGames/unreal-engine repo is private and this
host's GitHub account is not Epic-linked); `no UnrealEditor on PATH`; `no engine tree in
HOME`. **Observed — re-verified 2026-10-18:** exactly those three
(`remote: Repository not found.` / `fatal: repository … not found`; `no UnrealEditor on
PATH`; `no engine tree in HOME`).

If any of the three shows an editor *is* present, then every `unproven-runtime` label must
be re-examined — the labels would no longer be justified by construction, and the round
would owe live receipts.

---

## Close-out decision rule

| gate | steps | claim | PASS requires |
|---|---|---|---|
| **G1** byte-identity | 1, 2 | C1 | fresh clone at pin; manifest `OK`; independent recompute and blob-compare both clean; tree + file-list diffs empty |
| **G2** inventory | 3 | C1 | 12 files, 0 extras, 0 missing, modes `644`, README table matched |
| **G3** verdict cards | 4 | C2 | **13/13** cards present, `BAD=0`, each label exactly one allowed token and consistent with its evidence |
| **G4** label discipline | 5 | C2/C3 | `UNLABELED=0`, and the negative control **detected** |
| **G5** links | 6 | C3 | `broken=0`, and the negative control **detected** |
| **G6** pointers | 7 | C3 | `UNRESOLVED=0`, hand-sample matches, and the negative control **detected** |
| **G7** declared artifacts | 8 | C1/C3 | `PROVENANCE.md` and `adaptation-kimi.md` both present |
| **G8** host reality | 10 | C2 | engine still unavailable, so the `static-only` / `unproven-runtime` labels remain the correct labels |

**Adjudication.** C1 is supported by G1+G2. C2 is supported by G3+G4+G8. C3 is supported by
G4+G5+G6+G7. A round-close verdict of ADMIT for an axis requires its gate set green.

**Status as of the 2026-10-18 re-run (on the not-yet-frozen tree): all eight gates PASS** —
G1 byte-identity, G2 inventory, G3 13/13 cards, G4 label discipline, G5 links, G6 pointers,
G7 declared artifacts, G8 host reality. Every one was re-derived on this host by the commands
above; none is quoted from an author's transcript. The stable per-gate numbers on that run:
clone HEAD = the pin / 12 tracked; manifest `12` audit + `24` total lines, `0` `FAILED`;
recompute and blob-compare diffs empty; 12 files, 0 extras, 0 missing, modes `644`;
`CARDS=13 EXPECTED=13 BAD=0`; `UNLABELED=0`; `broken=0`; `POINTERS=78 UNRESOLVED=0`;
all three declared artifacts present. All three negative controls were **detected**
(`STEP=FAIL`, exit 1 each).

Caveat that outranks that result: **the tree was not frozen.** Four verdict cards, the
provenance manifest and the adaptation table all landed *while this protocol was being
written*, and each arrival moved a gate from FAIL to PASS. The sequence is therefore proven
runnable and currently green, but the close-out verdict must come from a re-run on the frozen
commit. If any gate regresses to FAIL at close, report it as a gap for that claim's axis
(coverage for C1, depth for C2, calibration for C3) — the round brief itself names coverage as
the lowest non-retired axis, so this is exactly where a real gap would show up.

**What this protocol cannot do.** It cannot convert an `unproven-runtime` claim into a
`verified-here` one, and it must never be used to imply otherwise. Unreal Editor is absent
by host construction; the strongest statement available here is "the vendored bytes are
byte-identical to the pinned upstream commit, and these static checks ran on this host."

**Frozen-tree rule.** Several r101 artifacts (verdict cards, `PROVENANCE.md`, probe files)
landed *while this protocol was being written*, so step counts and file inventories moved
during authoring. The verifier must run the whole sequence on the **frozen** close-out tree
and report that tree's commit — not any intermediate state, and not the numbers quoted here
as "observed".

---

## Appendix — one-shot runner

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# (after §0 materialises the scripts)
for s in 1 2 3; do :; done   # steps 1–3 are inline above; run them in order
"$WORK/label-scan.sh"        "$CORPUS/executability" 13
"$WORK/runtime-claim-scan.sh" reports/round-101 "$CORPUS"
"$WORK/linkcheck.sh"          "$CORPUS/upstream"
"$WORK/pointer-check.sh"      reports/round-101 "$CORPUS"
```

Record every command with its observed output. A step whose output was not captured was
not run, and has not passed.
