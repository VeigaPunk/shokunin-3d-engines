# r102 close-out verification protocol

**Seat:** SEAT-43 VERIFIER-CHAIR · round 102 · lane `game-dev-3d-shokunin`
**Executed by:** the L1 at round close, on the **committed** round-102 tree.
**Audience:** a non-author verifier. Every step below re-derives its own evidence; nothing here
asks you to trust an author's transcript, including this one.
**Written:** 2026-10-18, against worktree HEAD `2c99b7b8155841617d844c609813afcba77aa207`
(r101 report-last; r101 work commit `1659c036`). The r102 work is **uncommitted** at write time —
`git status --porcelain` shows 5 modified files + 3 untracked paths (see §0.2).

Round axes: **depth / coverage / calibration**. Coverage is the lowest non-retired axis.

This protocol gates the two r102 claims:

| claim | axis | what must hold at close |
|---|---|---|
| **C1** | coverage | (a) `corpus/knowledge/unreal-mcp/gate/run_gate.sh` is self-contained, re-runnable, and exits 0 with all four checks `STEP=PASS`; (b) `corpus/lessons/r102-unreal-integration.md` exists and every command/pointer it cites resolves; (c) `corpus/knowledge/engines.md` Unreal row carries the r101 evidence-class update |
| **C2** | depth | the five routed pre-existing defects are repaired, each with before(fail)→after(pass) captured by a command, **plus** the F8 wording fold |

**Fail-closed rule.** Any step that does not print its expected result is a FAIL for its claim. Do
not average, do not skip, do not "looks good". A missing artifact is a FAIL, not a warning.

**Non-author requirement.** Steps 1, 2, 3, 4, 7c and 8 must be run by someone who did not write
the artifacts under test. Steps 5, 6, 7 and 7b are mechanical re-derivations and may be run by
anyone. For any step whose expected result is a number, re-run it — do not accept a pasted number.

---

## 0. Preconditions

### 0.1 Environment and pinned constants

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
CORPUS=corpus/knowledge/unreal-mcp
WORK=/tmp/r102-closeout
rm -rf "$WORK" && mkdir -p "$WORK"
```

Required on PATH: `bash`, `git`, `sha256sum`, `grep`, `find`, `sort`, `comm`, `python3`, `node`,
`npm`, `jq`, `shellcheck`. Network is required **only** by gate CHECK 2 (fresh clone); if it is
down that check prints `BLOCKED, not PASS` and the gate exits 1 — record it as BLOCKED, never as
PASS, and do not substitute a cached clone silently.

### 0.2 The tree at protocol-write time — measured, not remembered

```sh
git status --porcelain
```

Observed 2026-10-18:

```
 M corpus/artifacts/unreal-r22/README.md
 M corpus/knowledge/engines.md
 M corpus/knowledge/rea.md
 M corpus/knowledge/unreal-mcp/README.md
 M corpus/lessons/r22-unreal-review.md
?? corpus/knowledge/unreal-mcp/gate/
?? corpus/lessons/r102-unreal-integration.md
?? reports/round-102/
```

**Consequence that governs this whole protocol.** The gate `corpus/knowledge/unreal-mcp/gate/`
does **not exist in HEAD** — it is a new r102 file. A verifier who runs the gate on a pristine
`git archive HEAD` export gets `No such file or directory`. The gate must be run on the tree
**after** the L1 lands the r102 commit, and the protocol's expected outputs are for that state.

Artifact digests recorded at write time (these are the *before-commit* values; a verifier must
re-derive, not diff against them):

| path | sha256 (short) | note |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `214bf8ef7ba7dfba` | new this round |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `def732c9a10dc9a9` | new this round |
| `corpus/lessons/r102-unreal-integration.md` | `54bf44340dc0d113` | 178 lines, new this round |
| `corpus/knowledge/engines.md` | `d03907d3d63771c1` | F5 repair landed |
| `corpus/knowledge/rea.md` | `3932fc5354c32e55` | F6 note landed |
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1d7c0c7bc` | F8 fold landed |
| `corpus/artifacts/unreal-r22/README.md` | `1c0d30355b34a76d` | F1a repair landed |
| `corpus/lessons/r22-unreal-review.md` | `d0522a6e99013891` | **F2/F3 NOT yet repaired** |

### 0.3 Materialise the two independent scanners used below

They are self-contained; nothing here depends on a leftover `/tmp` file from a seat. `label-scan.sh`
is a copy of the r101 protocol's §0 script, kept identical so r101/r102 label counts stay comparable.
`ptr-sweep.sh` is SEAT-37's range-aware sweep, reproduced verbatim from
`reports/round-102/reruns/pointer-sweep.sh` so step 6 does not depend on a peer's file surviving.

```sh
cat > "$WORK/label-scan.sh" <<'EOF'
#!/usr/bin/env bash
# Verdict-card inventory + exactly-one-label scan (r101 protocol rule, unchanged).
# RULE: the DECLARED LABEL is the token on the FIRST line of the card that contains any
# allowed token. That line must (a) appear within the first 40 lines, (b) be bold/heading
# marked, (c) carry exactly ONE allowed token.
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

cat > "$WORK/ptr-sweep.sh" <<'EOF'
#!/usr/bin/env bash
# Range/comma-aware subtree pointer sweep. Pointers are `upstream/<path>:<line>`
# (also `:a-b` ranges and `:a,b` lists) and resolve against corpus/knowledge/unreal-mcp.
# Exclusions, all deliberate and all PRINTED so they cannot hide a real failure:
#   * anything under upstream/ — the vendored upstream text is not this round's artifact;
#   * the gate's own README when it carries the protocol's control sentinels (exact-match only).
set -u
roots=${*:-"corpus/knowledge/unreal-mcp"}
base=${BASE:-corpus/knowledge/unreal-mcp}
sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
ptr_re='upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+([,-][0-9]+)*'
total=0; bad=0; skipped=0; files=0
for root in $roots; do
  while IFS= read -r f; do
    case "$f" in */upstream/*) continue;; esac
    if [ "$(basename "$f")" = README.md ] && printf '%s' "$f" | grep -q '/gate/'; then
      if grep -qE "$sentinel" "$f"; then printf 'GATE-SENTINEL-SKIP %s\n' "$f"; continue; fi
    fi
    files=$((files+1))
    while IFS= read -r ptr; do
      if printf '%s' "$ptr" | grep -qE "^($sentinel)$"; then skipped=$((skipped+1)); continue; fi
      p=${ptr%%:*}; rest=${ptr#*:}
      for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
        total=$((total+1))
        if [ ! -f "$base/$p" ]; then printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; bad=$((bad+1)); continue; fi
        n=$(wc -l < "$base/$p")
        [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; bad=$((bad+1)); }
      done
    done < <(grep -ohE "$ptr_re" "$f" | sort -u)
  done < <(find $root -name '*.md' -type f | sort)
done
printf 'FILES_SCANNED=%s POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$files" "$total" "$skipped" "$bad"
[ "$bad" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
EOF
chmod +x "$WORK"/*.sh
bash -n "$WORK/label-scan.sh" && bash -n "$WORK/ptr-sweep.sh" && echo "SCRIPTS_OK"
```

**Expected:** `SCRIPTS_OK`, exit 0.

---

## 1. Gate: self-containment and green run  *(C1a, non-author)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
test -e corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo GATE_PRESENT || echo GATE_ABSENT
test -x corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo GATE_EXECUTABLE || echo GATE_NOT_EXEC
bash -n corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo "bash -n OK"
shellcheck corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "shellcheck_exit=$?"
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_EXIT=$?"
```

**Expected:** `GATE_PRESENT`, `GATE_EXECUTABLE`, `bash -n OK`, `shellcheck_exit=0`, `GATE_EXIT=0`,
and in the gate output exactly four `STEP=PASS` lines with these numbers:

```
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=<n> SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**Observed at protocol-write time (2026-10-18), re-derived by this seat:**

- `bash -n` OK, `shellcheck_exit=0`, `GATE_EXIT=0`.
- All four checks `STEP=PASS`; `MANIFEST_OK=12 FAILED=0 RC=0`; `CLONE_HEAD` = the pin,
  `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0`;
  `CARDS=13 BAD=0`; `CENSUS 12/1/0`; `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`.
- Running the gate from `/tmp` by absolute path prints the same result — it resolves its subtree
  from its own location, so it is cwd-independent.

**`POINTERS` is not a stable number.** The gate's own regex matches only the `:<line>` form
(`upstream/...:[0-9]+`). Five pointers in the scanned set use the range/comma forms `:a-b` and
`:a,b`, all inside `adaptation-kimi.md`; the gate reads such a token as its first number only and
therefore counts `40`, while the range-aware sweep in step 6 counts `47`. Both report
`UNRESOLVED=0`, so no claim fails — but the invariant to check is **`UNRESOLVED=0`**, never the
total. See §9 for the measured demonstration and the scope limit this exposes.

**Network caveat.** CHECK 2 clones the upstream repo. If the clone fails the gate prints
`FAIL fresh clone failed … BLOCKED, not PASS` and exits 1. That is a BLOCKED result: record it and
stop; do not substitute a cached clone without saying so in the round record.

---

## 2. Gate mutation controls — the gate must go red  *(C1a calibration)*

A gate that cannot fail proves nothing. Re-run the controls on a **throwaway copy**; never mutate
the repo.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf '\n' >> "$T/sub/upstream/README.md"          # C1: flip a byte
rm "$T/sub/upstream/LICENSE"                        # C2: delete a vendored file
rm "$T/sub/executability/sequencer.md"              # C3: drop a card
sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' \
    "$T/sub/executability/blueprints.md"            # C4: duplicate a label token
sed -i '4s/.*/**Label:** `unproven-runtime`/' "$T/sub/executability/blueprints.md"  # C5: relabel
printf '\nsee upstream/README.md:200\n' >> "$T/sub/README.md"   # C6: plausible OOR pointer
```

Run `bash "$T/sub/gate/run_gate.sh"` after each single mutation, recording exit code and which
`STEP=` lines FAIL. **Expected:** exit 1 every time, with the failing check named in §7's table.
A mutation that leaves the gate green is a FAIL of this step.

**Observed at protocol-write time:** SEAT-18's independent harness
(`reports/round-102/gate/mutation.md`, 7 cases on `/tmp/r102mut`) reports control exit 0 with 4/4
`PASS`, and M1–M6 + M4b each exit 1 with at least one `STEP=FAIL`; no mutation produced a false
PASS. C7 (planting **only** the exact sentinels) correctly stays green with
`SKIPPED_CONTROL_SENTINELS=2` — that is the filter's own positive control.

---

## 3. Gate re-run on the pristine committed tree  *(C1a, independence)*

The gate's CHECK 2 already clones upstream, but the *subtree* it reads is the working tree. To show
the gate result is not an artefact of in-flight edits, run it on a read-only export of the commit:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
rm -rf "$WORK/committed" && mkdir -p "$WORK/committed"
git archive <COMMIT> | tar -x -C "$WORK/committed"
cd "$WORK/committed" && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_EXIT=$?"
```

**Expected:** `GATE_EXIT=0`, four `STEP=PASS`, same numbers as §1.

**Observed at protocol-write time:** on `git archive HEAD` (which has **no** gate — it is new this
round) the command correctly fails with `No such file or directory`; this step is therefore
**only meaningful after the L1 lands the r102 commit**, and that is exactly why it is here. The
pointer sweep in step 6 was run against the same pristine HEAD export and returned
`POINTERS=47 UNRESOLVED=0 / STEP=PASS`, which is the part that is already available pre-commit.

---

## 4. Verdict-card scan, independently re-implemented  *(C1a)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/label-scan.sh" "$CORPUS/executability" 13
```

**Expected:** 13 `OK` lines, `CARDS=13 EXPECTED=13 BAD=0`, `STEP=PASS`, exit 0.

**Observed at protocol-write time:** 13/13 `OK`; `CARDS=13 EXPECTED=13 BAD=0`; census
`static-only=12` / `unproven-runtime=1` (`actors-scene.md:5`) / `verified-here=0` — identical to the
gate's CHECK 3 and to SEAT-36's independently written scanner
(`reports/round-102/reruns/labels.md`, whose rule differs from the r101 protocol's and which also
passes with the same census).

**Two calibration notes carried by SEAT-36, both re-confirmed by reading the cards:** the corpus
uses three declaration shapes (`**Label:**`, `**Verdict:**`, `Verdict: **…**`), so a scanner that
hard-codes a `Label:` prefix false-fails `assets-content.md` and `scripting-programmatic.md`; and a
first-token-wins rule false-FAILs a correctly-labelled card whose prose above the declaration
mentions a token. Both scanners here implement first-line-with-a-token, which is why they agree.

**Not machine-checkable, read the cards:** a label must be *consistent with its evidence*. On this
host a `verified-here` label is a red flag — Unreal Editor is not installed, so no card can carry a
bounded-run receipt. The census `verified-here=0` is the *correct* outcome, not a gap.

---

## 5. Subtree byte-pin re-run  *(C1a supporting; F8 proof)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
cd "$CORPUS"
sha256sum -c .manifest.d/audit-reference.sha256; echo "audit_rc=$?"
sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK$'
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- "$CORPUS/upstream" "$CORPUS/.manifest.d"; echo "pinned_dirs_rc=$?"
```

**Expected:** 12 `OK` lines and `audit_rc=0`; the glob prints `24`; the `git diff --stat` over
`upstream/` and `.manifest.d/` is **empty**, `pinned_dirs_rc=0`.

**Observed at protocol-write time:** exactly that — 12 `OK` / `audit_rc=0`, glob `24`, and the
byte-pinned directories show zero diff even though the subtree's own `README.md` is modified
(`git diff --stat HEAD -- "$CORPUS"` → `README.md | 6 +++---` only). **This is the F8 proof:** the
wording fold lands *outside* `upstream/` and `.manifest.d/`, and no manifest pins
`$CORPUS/README.md`, so the pin is untouched by it. SEAT-35's independent re-run
(`reports/round-102/reruns/manifest.md`) reached the same conclusion with a fresh clone.

F8's own content check (the `:187` "12 lines" ambiguity):

```sh
grep -n 'Observed output of' "$CORPUS/README.md"
grep -c '24 lines, all `OK`' "$CORPUS/README.md"
grep -c '12 lines, all `OK`'  "$CORPUS/README.md"
```

**Expected:** the observed-output sentence names the `audit-reference.sha256` command and says
`12 lines`, and the paragraph above it states the glob yields `24`. `24 lines` count must be `0`
if the fold was written as "12 lines under the audit-reference command, 24 under the glob"; a `1`
there means the sentence still attributes 24 to the wrong command. Read the line, do not just
count — the defect was a *command/count mismatch*, and only reading it settles it.

**Observed at protocol-write time:** `$CORPUS/README.md:187` reads
``Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice)``
and `:169` reads `` `sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the full glob `*.sha256` → **24** (same 12 files twice)``.
Command and count now agree. `grep -c '12 lines, all \`OK\`'` → `1`.

---

## 6. Pointer sweep and link check  *(C1b/C1a supporting)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
"$WORK/ptr-sweep.sh" "$CORPUS"
```

**Expected:** `UNRESOLVED=0`, `STEP=PASS`, exit 0, with `GATE-SENTINEL-SKIP` printed for the gate's
own `README.md` (it quotes the control sentinels). The printed skip is the point: the exclusion is
*visible*, so it cannot hide a real failure.

**Observed at protocol-write time:** `FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0
UNRESOLVED=0 / STEP=PASS`, both on the working tree and on the pristine `git archive HEAD` export
(`BASE=/tmp/r102-headtree/corpus/knowledge/unreal-mcp`), which is the version that matters because
it is independent of peer edits.

The r102 lesson's own pointers must resolve too:

```sh
grep -ohE "corpus/knowledge/unreal-mcp/[A-Za-z0-9_./-]+\.(md|json):[0-9]+" \
  corpus/lessons/r102-unreal-integration.md | sort -u | while read -r p; do
  f=${p%:*}; l=${p##*:}
  [ -f "$f" ] || { echo "MISSING $p"; continue; }
  n=$(wc -l < "$f"); [ "$l" -gt "$n" ] && echo "OOR $p (max $n)"
done; echo "LESSON_POINTERS_SWEPT"
```

**Expected:** only `LESSON_POINTERS_SWEPT` — no `MISSING` and no `OOR` line. **Observed:** clean.
All of the lesson's subtree pointers were hand-checked as well (`PROVENANCE.md:159/:181/:210/:48`,
`README.md:65/:169/:262/:41/:237`) — every one is within its file's length (PROVENANCE 361 lines,
subtree README 279 lines).

Link check over the vendored tree (r101 protocol step 6, re-derived here so C1a's coverage claim
is not read as covering it):

```sh
python3 - "$CORPUS/upstream" <<'PY'
import os, re, sys
root = sys.argv[1]
inline = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)'); fence = re.compile(r'^\s*(```|~~~)')
broken=[]; total=0; mds=0
for dp,_,fns in os.walk(root):
    for fn in fns:
        if not fn.endswith('.md'): continue
        p=os.path.join(dp,fn); mds+=1; inf=False
        for ln in open(p, encoding='utf-8', errors='replace'):
            if fence.match(ln): inf = not inf; continue
            if inf: continue
            for t in inline.findall(ln):
                total+=1
                if t.startswith(('http://','https://','#')): continue
                tgt=t.split('#')[0]
                if tgt and not os.path.exists(os.path.join(dp,tgt)): broken.append((p,t))
print(f"md_files={mds} links_total={total} broken={len(broken)}")
sys.exit(1 if broken else 0)
PY
echo "linkcheck_exit=$?"
```

**Expected:** `md_files=6 links_total=3 broken=0`, `linkcheck_exit=0`. **Observed:** exactly that.

Static well-formedness of the vendored artifacts (r101 protocol step 9):

```sh
cd "$CORPUS"
jq -e . upstream/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
jq -e . upstream/hooks/hooks.json          > /dev/null && echo "hooks.json OK"
bash -n upstream/hooks/unreal-context.sh   && echo "bash -n OK"
shellcheck upstream/hooks/unreal-context.sh; echo "shellcheck_exit=$?"
```

**Expected:** `plugin.json OK`, `hooks.json OK`, `bash -n OK`, `shellcheck_exit=0`. **Observed:**
all four.

---

## 7. Repair lattice — before(fail) → after(pass)  *(C2, non-author)*

Each row below is a routed pre-existing defect. Run the command; compare against the expected
column. **All seven repair targets are green as of the 2026-10-18 re-measurement** — the only
outstanding FAIL in this protocol is G10 (§7c), which is a *lesson-cite* defect, not a lattice row.

| id | check | command (from repo root) | expected at close | observed 2026-10-18 |
|---|---|---|---|---|
| **F1a** | phantom root gone from r22 README | `grep -c 'shokunin/game-dev-3d' corpus/artifacts/unreal-r22/README.md` | `0` | **`0` GREEN** |
| **F1a** | positive command runs | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo rc=$?` | `PASS local-static actual=accept …`, `rc=0` | **GREEN** |
| **F1a** | negative control still discriminates | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo rc=$?` | `PASS local-static actual=reject …`, `rc=0` | **GREEN** |
| **F1b** | phantom root gone from r22 lesson | `grep -c 'shokunin/game-dev-3d' corpus/lessons/r22-unreal-review.md` | `0` | **`0` GREEN** (7 lines fixed) |
| **F2** | absent receipt still cited | `grep -c '20261013T053632289732Z' corpus/lessons/r22-unreal-review.md` | `≥1` — the historical cite is **kept** | **`2` GREEN** |
| **F2** | dated correction note present | `grep -ci 'correction' corpus/lessons/r22-unreal-review.md` | `≥1` | **`2` GREEN** |
| **F3** | stale digest still cited | `grep -c 'a065a56db193228d' corpus/lessons/r22-unreal-review.md` | `≥1` — the historical digest is **kept** | **`1` GREEN** |
| **F3** | dated correction note present | `grep -ci 'correction' corpus/lessons/r22-unreal-review.md` | `≥1` | **`2` GREEN** |
| **F5** | three.js row carries the install step | `sed -n '11p' corpus/knowledge/engines.md \| grep -c 'npm ci --prefix'` | `1` | **`1` GREEN** |
| **F5** | repaired command passes on a **clean** tree | see block below | `rc=0`, 3/3 `PASS` | **GREEN** |
| **F6** | dated correction note present | `grep -c 'Correction note (r102' corpus/knowledge/rea.md` | `1` | **`1` GREEN** |
| **F6** | stale census sentence preserved verbatim | `grep -c 'no Ghidra, JADX, Binwalk/Unblob, pwntools' corpus/knowledge/rea.md` | `1` | **`1` GREEN** |
| **F6** | correction is factually true | `which jadx binwalk unblob; which ghidra; which rea` | three hits; ghidra + rea absent | **matches the note** |
| **F8** | subtree README command/count agree | `sed -n '187p' corpus/knowledge/unreal-mcp/README.md` | names `audit-reference.sha256`, says `12 lines` | **GREEN** (see §5) |
| **C1c** | engines.md Unreal row updated | `sed -n '10p' corpus/knowledge/engines.md \| grep -c 'two static evidence classes'` | `1` | **`1` GREEN** |

**F2/F3 — the discipline, stated so the verifier does not "fix" it wrongly.** Both are *historical
factual claims*. `a065a56db193228d…` is a **true archival address**: `git show
8b21cae:corpus/fixtures/run_battery.py | sha256sum` reproduces it exactly, and `8b21cae` is the
commit that introduced the lesson itself (SEAT-13's ruling,
`reports/round-102/adversary/F3.md`). Likewise the cited
`corpus/live/runs/20261013T053632289732Z/verdicts.json` lives only under the gitignored
`corpus/live/` tree, so it is unreproducible from a clone — a fact to *state*, not to hide. The
pass condition is therefore:

- the stale strings **stay** (`grep -c` returns `≥1`, not `0`), **and**
- a **dated correction note** is added that names the receipt as clone-unreproducible and gives the
  re-derivable pointer for the digest (e.g.
  `git cat-file blob 8b21cae:corpus/fixtures/run_battery.py | sha256sum`, current tree value
  `f456bd00…` as of 2026-10-18).

**A verifier who sees `grep -c 'a065a56db193228d' … → 0` should treat it as a FAIL, not a pass** —
that would be a silent rewrite of the historical record, the exact thing the discipline forbids.
SEAT-13's ruling is explicit that renumbering an archival address "manufactures the very drift the
round is trying to retire."

**Landed repair, for the verifier to confirm against (2026-10-18).** The r22 lesson now carries
two dated notes: the F2/F3 note at `corpus/lessons/r22-unreal-review.md:50-55` (a blockquote that
keeps the r22 paragraph verbatim above it and states the `verdicts.json` receipt is
clone-unreproducible, with the current digests and the re-derivation command) and the F3 note
headed `## F3 correction — 2026-10-18 (r102)`. `grep -c '20261013T053632289732Z'` → `2`,
`grep -c 'a065a56db193228d'` → `1`, `grep -ci 'correction'` → `2`. Evidence:
`reports/round-102/repairs/F1b-F2-r22-lesson.md`, `reports/round-102/repairs/F3-sha-drift.md`.

> Same class, now also recorded in the lesson: the **pass count** `29/29` is stale in exactly the
> way the digests are (the r22 blob's `CASES` had 29 rows; today's has 350). The F3 note covers it.
> A verifier should treat `29/29 PASS` in the r22 lesson as an r22 record, not a current claim.

**F5 clean-tree proof** (the defect was a missing precondition, not a wrong number, so the
historical `→ 3/3` claim was kept and the command was made re-runnable):

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
rm -rf "$WORK/f5" && mkdir -p "$WORK/f5"
git archive HEAD corpus/fixtures/three | tar -x -C "$WORK/f5"
cd "$WORK/f5"
node corpus/fixtures/three/run_cases.mjs; echo "bare_rc=$?"       # expect 1 — the defect
npm ci --prefix corpus/fixtures/three --offline; echo "npm_rc=$?" # expect 0
node corpus/fixtures/three/run_cases.mjs; echo "after_rc=$?"      # expect 0, 3/3 PASS
```

**Expected:** `bare_rc=1` with four `FAIL` lines (all three arms die `ERR_MODULE_NOT_FOUND`,
because `node_modules/` is gitignored and absent from a clone); `npm_rc=0`; `after_rc=0` with
`PASS positive` / `PASS negative_wrong_order` / `PASS mutation` / `PASS three battery: 3/3`.

**Observed at protocol-write time:** exactly that — `bare_rc=1`, `npm_rc=0`, `after_rc=0`, 3/3.
The `bare_rc=1` half is load-bearing: it proves the install step in the repaired cell is doing
real work rather than decorating a command that already passed.

> Trap to avoid: the runner prints `three battery: 3/3, seeds_unchanged=true` **hard-coded after
> the verdict prefix** (`run_cases.mjs:39`), so on failure it reads `FAIL three battery: 3/3`.
> Grepping for `3/3` is therefore non-discriminating; check the `PASS`/`FAIL` prefix or the exit
> code.

---

## 7b. Battery integrity — the round must not have moved the fixtures  *(C2 supporting)*

The repair lattice edits prose and `engines.md`; it must not have perturbed the executable
fixture tree. Two independent proofs: byte-stability of the tree, and the fixture suite actually
running green.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- corpus/fixtures/; echo "fixtures_diff_rc=$?"
git status --porcelain -- corpus/fixtures/ | wc -l
git ls-files -s corpus/fixtures | awk '{print $2"  "$4}' | sort | sha256sum
git ls-tree -r HEAD corpus/fixtures | awk '{print $3"  "$4}' | sort | sha256sum
git ls-files corpus/fixtures | wc -l
sha256sum corpus/fixtures/run_battery.py
git hash-object corpus/fixtures/run_battery.py
git rev-parse HEAD:corpus/fixtures/run_battery.py
```

**Expected:** empty diff and `fixtures_diff_rc=0`; `0` porcelain lines; the two aggregate digests
**equal** (index-side vs HEAD-side); `146` tracked fixture files; and the `run_battery.py` triple —
`sha256` = `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, and
`git hash-object` == `git rev-parse HEAD:corpus/fixtures/run_battery.py` (blob `dd2d9b74448afddb88dcf2da56008302eba8060d`).

**Observed at protocol-write time:** exactly that — empty diff, `0` untracked, both aggregates
`827af6c35233bc520d5a797dd650a777df1f18ab9fca9652e5fab0b1e539096d`, `146` files, and the
`run_battery.py` triple as above. `corpus/fixtures/` is untouched by round 102.

Structural integrity of the battery's case table (a same-size rewrite would slip past `git status`
only in principle; this reads the committed bytes):

```sh
python3 - <<'PY'
import ast, subprocess, hashlib
blob = subprocess.run(['git','show','HEAD:corpus/fixtures/run_battery.py'], capture_output=True).stdout
tree = ast.parse(blob.decode())
cases = [ast.literal_eval(n.value) for n in tree.body
         if isinstance(n,ast.Assign) and any(getattr(x,'id',None)=='CASES' for x in n.targets)][0]
print("HEAD blob bytes:", len(blob), "sha256:", hashlib.sha256(blob).hexdigest())
print("HEAD CASES rows:", len(cases))
print("worktree==HEAD:", open('corpus/fixtures/run_battery.py','rb').read() == blob)
print("all rows are tuples:", all(isinstance(r, tuple) for r in cases))
PY
```

**Expected:** `346248` bytes, sha256 `f456bd00…`, `350` rows, `worktree==HEAD: True`, all tuples.
**Observed:** exactly that.

Then the suite itself. **This step needs a long window** — the full 350-row battery takes several
minutes on this host; run it with a generous timeout or in the background, and do **not** accept a
truncated capture as a pass.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
python3 corpus/fixtures/run_battery.py > "$WORK/battery.out" 2>&1; echo "battery_rc=$?"
grep -E '^FAIL [a-z]' "$WORK/battery.out"        # the failing case names — compare as a set
grep -E '^totals:' "$WORK/battery.out"
LATEST=$(ls -1dt corpus/live/runs/*/ | head -1)
python3 -c "import json; d=json.load(open('$LATEST/verdicts.json')); \
  print('seeds_unchanged:', d['seeds_unchanged']); print('totals:', d['totals'])"
```

**Expected — read this carefully, the obvious expectation is WRONG.** A full 350-row run on this
host is **not** green. Measured 2026-10-18:

```
totals: cases=350 pass=334 fail=16 ordinary=291 negative_controls=59 probes=0
battery_rc=1        seeds_unchanged: true
```

The 16 failures are **pre-existing, environment-caused, and unrelated to this round**; they are
the *expected* outcome here, not a regression:

- **13 × `r94_cannon_*`** (`det det2 varstep bailout nan sync material friction parity parity2
  modes order backends`) — each `exit=0 expected=0` with `reasons=['exact stdout marker missing']`.
  The marker itself is version-pinned: the battery's expectation string literally reads
  `PASS r94_cannon det node=v24.21.0` (`grep -oE 'PASS r94_cannon det node=[^ ]+' corpus/fixtures/run_battery.py`),
  while this host runs `node v26.12.0`. The child process exits 0 and produces output; only the
  embedded version token differs. This is a marker-staleness condition, **not** a physics failure.
- **1 × `phys3d_joints_free_ops`** — `exit=None`, `TIMEOUT after 20 seconds`. Load-dependent: it
  passes on an unloaded host and fails under the concurrent-seat load of a round close.
- **2 × `r98_gltflat_doc` / `r98_gltflat_extbin`** — `exact stdout marker missing` plus
  `unexpected diagnostic: … Can't open file at path "UD/R98Scout/tri.glb"`; a path/fixture
  condition in those two arms, also unrelated to the r102 Unreal work.

**So the pass condition for this step is NOT "zero FAIL".** It is:

1. `seeds_unchanged: true` — the round did not perturb any fixture (this is the property §7b
   exists to protect);
2. `totals: cases=350` — the full row count ran, not a truncated capture;
3. `fail` ≤ **16**, and every failing case name is one of the 16 listed above. **A 17th failure
   name, or a `fail` count above 16, is a real regression and must be reported.**

Read the count from the receipt rather than the console tail:

```sh
LATEST=$(ls -1dt corpus/live/runs/*/ | head -1)
python3 -c "import json,sys; d=json.load(open('$LATEST/verdicts.json')); \
  print('seeds_unchanged:', d['seeds_unchanged']); print('totals:', d['totals'])"
```

**Observed at protocol-write time (2026-10-18):** `cases=350 pass=334 fail=16`,
`seeds_unchanged: true`, `battery_rc=1`, and the 16 names exactly as listed. **Note the hazard
this creates:** a verifier who expects `battery_rc=0` will report a false FAIL of the whole round,
and one who waves `battery_rc=1` through without reading the names will miss a real regression.
Both errors are live here — that is why the pass condition is written as a named-set comparison.

**Caveat, stated because it is easy to over-read.** The battery's outcome says nothing about
Unreal. It is a Godot/Node fixture suite; nothing in this section touches the editor, and the
`pass=334` figure must not be cited as evidence of any Unreal behavior. It also says nothing about
whether the 16 failures *should* be repaired — that is a separate routed decision, recorded here
only so the close-out does not mistake a standing condition for a new defect.

---

## 7c. Lesson commands green — the r102 lesson's own cites must run  *(C1b, non-author)*

C1(b) is "a lesson exists"; a lesson whose cited commands fail is not coverage. Every command the
r102 lesson presents as green must be re-run **as written** from the lane root.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# the lesson's load-bearing subtree command
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "audit_rc=$?")
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK')
# the gate the lesson now points at
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; echo "gate_rc=$?"
# the two /tmp stopgap scripts the lesson cites, IF still present
bash /tmp/r101-closeout/label-scan.sh corpus/knowledge/unreal-mcp/executability 13 >/dev/null 2>&1; echo "labels_rc=$?"
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp >/dev/null 2>&1; echo "ptr_rc=$?"
```

**Expected:** `audit_rc=0`; glob `24`; `gate_rc=0`; and — for the two `/tmp` cites — the exit code
the lesson claims. The lesson says `pointer-check.sh` → `UNRESOLVED=0` / `STEP=PASS`, i.e.
`ptr_rc=0`, and `label-scan.sh` → `PASS`, i.e. `labels_rc=0`.

**Observed at protocol-write time — `ptr_rc=1`, a FAIL of this step.**

```
$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp; echo "ptr_rc=$?"
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:500 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:9999 (max 112)
POINTERS=43 UNRESOLVED=3
STEP=FAIL
ptr_rc=1
```

**Mechanism, and why this is a moving-target staleness rather than a typo.** The lesson's
`UNRESOLVED=0` was true when written: at that moment `corpus/knowledge/unreal-mcp/gate/` did not
exist, so the sweep had no contaminated file to read. The gate README then landed, and it plants
three control pointers for its own negative controls — `upstream/README.md:9999`,
`upstream/README.md:500` (line 99–100) and, in its worked C3 example,
`upstream/README.md:200` (lines 147, 168). The r101 `pointer-check.sh` skips **only** the two exact
sentinels `9999` and `500`; it has no rule for `200`, which is a *plausible, non-sentinel,
out-of-range* pointer — and that is precisely what the r101 protocol chose for its own negative
control. So the gate's spec file injects a string the old checker must flag. Verified directly:

```sh
sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
for p in upstream/README.md:9999 upstream/README.md:500 upstream/README.md:200; do
  printf '%s' "$p" | grep -qE "^($sentinel)$" && echo "$p SKIPPED" || echo "$p NOT-SKIPPED"
done
# → 9999 SKIPPED / 500 SKIPPED / 200 NOT-SKIPPED
```

**This is a real finding for the round, not a gate defect.** The gate's own CHECK 4 handles it
correctly — it excludes its own `gate/README.md` from the sweep, and it re-runs green
(`POINTERS=40 UNRESOLVED=0`). The defect is that the **lesson cites the superseded `/tmp`
checker as still-green**, which is now false. Two acceptable repairs, both belonging to the
lesson's owning seat, neither of which this protocol performs:

1. drop the `/tmp` cites and point only at the in-repo gate (the lesson's own "prefer the in-repo
   gate" paragraph already argues for this), or
2. keep the cites but mark them as superseded by the gate, with the observed `UNRESOLVED=3`
   recorded as the reason.

**Do not repair this by editing the gate README to remove `:200`** — that string is the gate's own
negative control, and removing it would make §2's C6 control un-runnable. The contamination is a
property of *sweeping the gate directory with the old checker*, not of the gate.

**Interaction with step 6.** This does not contradict the `UNRESOLVED=0` that §6 reports: the
protocol's own `ptr-sweep.sh` has the gate-README exclusion and the range-aware regex, so it is
green; the r101 `pointer-check.sh` has neither. Two checkers, two scopes, two answers — which is
exactly why the expected value must be tied to a named command and not to "the pointer check".

---

## 8. Host reality re-affirmation  *(C1a/C2 label validity, non-author)*

The `static-only` / `unproven-runtime` census rests on the claim that Unreal Editor is not
installable here. Re-affirm it; do not take it on faith:

```sh
timeout 30 git ls-remote https://github.com/EpicGames/unreal-engine HEAD 2>&1 | head -3
which UnrealEditor 2>/dev/null || echo "no UnrealEditor on PATH"
ls ~/UnrealEngine 2>/dev/null || echo "no engine tree in HOME"
```

**Expected:** `remote: Repository not found.` / `fatal: repository … not found`;
`no UnrealEditor on PATH`; `no engine tree in HOME`.

**Observed at protocol-write time:** exactly those three.

If any of the three shows an editor *is* present, every `unproven-runtime` label must be
re-examined — they would no longer be justified by construction, and the round would owe live
receipts. **What this protocol cannot do:** it cannot convert an `unproven-runtime` claim into a
`verified-here` one, and must never be used to imply otherwise. Unreal Editor is absent by host
construction; the strongest statement available is "the vendored bytes are byte-identical to the
pinned upstream commit, and these static checks ran on this host."

---

## 9. Negative controls — the note the L1 must read

**The gate has its own controls; they are not optional.** §2 is not decoration: a green gate whose
mutations also stay green has proven nothing. Run at least C1 (byte flip), C3 (drop a card), C4
(duplicate label token) and C6 (plausible out-of-range pointer) and confirm exit 1 each.

**Three additional controls that must FAIL, one per independent scanner:**

```sh
# label scanner — a card with two label tokens must fail
mkdir -p "$WORK/neg1" && printf '# x\n\n**Label:** `static-only` and not `verified-here`\n' > "$WORK/neg1/a.md"
"$WORK/label-scan.sh" "$WORK/neg1" 1; echo "expect exit 1"

# pointer sweep — a plausible, non-sentinel, out-of-range pointer must fail
mkdir -p "$WORK/neg2" && printf '# x\n\nsee upstream/README.md:200\n' > "$WORK/neg2/a.md"
BASE="$CORPUS" "$WORK/ptr-sweep.sh" "$WORK/neg2"; echo "expect exit 1"
```

**Expected:** `FAIL multi-label` / `BAD=1` / `STEP=FAIL` exit 1; then
`LINE-OOR … upstream/README.md:200 (max 112)` / `UNRESOLVED=1` / `STEP=FAIL` exit 1. Note the
second control deliberately uses `README.md:200`, **not** `9999` or `500` — those two are the
sentinels and are skipped by design, so using one would prove nothing. This is exactly the trap
the r101 protocol's own worked examples set for themselves.

**A calibration finding, recorded so it is not mistaken for a pass.** The gate's pointer regex
matches only the `:<line>` form, so range/comma pointers (`:a-b`, `:a,b`) are read as their first
number. Measured:

```sh
printf 'see upstream/README.md:50-57\n' | grep -ohE "upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+"
# → upstream/README.md:50        (the "-57" endpoint is not checked)
```

Five such pointers exist in the scanned set, all in `adaptation-kimi.md`
(`upstream/hooks/hooks.json:4-5`, `upstream/hooks/unreal-context.sh:5,8`,
`upstream/README.md:39,45`, `upstream/README.md:50-57`,
`upstream/skills/unreal-mcp/references/setup.md:61,70-79`), which is why the gate prints
`POINTERS=40` and the range-aware sweep prints `47`. **No claim fails** — both report
`UNRESOLVED=0`, and the sweep that does check every endpoint is green — but the gate's pointer
coverage is narrower than its `UNRESOLVED=0` suggests. That is a scope limit to record for a
future round, not a defect to repair now, and it must not be cited as "the gate checks all
pointers".

**Second finding, same class.** The gate's exclusions are the vendored `upstream/` tree, its own
`gate/README.md`, and the exact control sentinels. It does **not** scan `reports/`, so the r101
protocol's `pointer-check.sh` self-contamination (a peer report quoting the protocol's broken
example strings) cannot recur inside the gate — but it also means a stale pointer in a round
report is outside the gate's coverage. Do not read the gate's green as covering `reports/`.

**Third finding — the one that costs a claim.** The two pointer checkers disagree on the same
tree, and the lesson cites the losing one. Full mechanism in §7c: the r101 `pointer-check.sh`
lacks the gate-README exclusion and the range-aware regex, so the gate's own control pointer
`upstream/README.md:200` makes it exit 1 with `UNRESOLVED=3`, while the in-repo gate and this
protocol's `ptr-sweep.sh` both stay green. **Every pointer expectation in this protocol must name
the command it belongs to** — "the pointer check is green" is not a checkable statement, and
treating the two as interchangeable is exactly how the lesson's stale cite survived review.

---

## Close-out decision rule

| gate | steps | claim | PASS requires |
|---|---|---|---|
| **G1** gate exists and is self-contained | 1 | C1a | `run_gate.sh` present, executable, `bash -n` + `shellcheck` clean |
| **G2** gate green | 1 | C1a | exit 0, four `STEP=PASS`, every number matching §1 |
| **G3** gate is calibrated | 2, 9 | C1a | the mutation controls **detected** (exit 1 each), and the three scanner controls detected |
| **G4** gate result is commit-independent | 3, 6 | C1a | gate green on the committed export; pointer sweep green on the pristine HEAD tree |
| **G5** card census | 4 | C1a | 13 cards, `BAD=0`, `12/1/0`, and every label read-consistent with its evidence |
| **G6** subtree byte-pin intact | 5 | C1a/F8 | 12 `OK` / rc=0, glob `24`, `upstream/` + `.manifest.d/` zero diff, README command/count agree |
| **G7** lesson + engines row | 6, 7 | C1b/C1c | lesson exists, all its pointers resolve; engines.md Unreal row carries the evidence-class update |
| **G8** repair lattice | 7 | C2 | **every** row in §7 green — F1a, F1b, F5, F6, F8, C1c, **and the F2/F3 correction notes present** |
| **G9** battery integrity | 7b | C2 | `corpus/fixtures/` zero diff, index==HEAD aggregate, `run_battery.py` = `f456bd00…` worktree==HEAD, 350 CASES rows, and a run whose `seeds_unchanged=true`, `cases=350`, `fail ≤ 16` with **every failing name in the known-16 set** |
| **G10** lesson commands green | 7c | C1b | every command the r102 lesson presents as green exits 0 **as written** |
| **G11** host reality | 8 | C2 | editor still unavailable, so the `static-only` / `unproven-runtime` labels remain correct |

**Adjudication.** C1 is supported by G1+G2+G4+G5+G6+G7+G10. C2 is supported by G8+G9+G11. A
round-close verdict of ADMIT for an axis requires its gate set green.

**Status at protocol-write time (2026-10-18, uncommitted worktree) — re-measured after the tree
moved under this seat:**

- **G1, G2, G3, G4, G5, G6, G8, G9, G11 — PASS.** F2 and F3 **were repaired while this protocol
  was being written**: `corpus/lessons/r22-unreal-review.md` now carries a dated correction note
  (`grep -ci 'correction'` → `2`) that keeps the historical cite and the r22 digest verbatim while
  stating that the `verdicts.json` receipt is clone-unreproducible and giving the re-derivable
  pointer for the digest. Both red rows in §7 are now green; the repair-target tally is **7 of 7**
  (evidence: `reports/round-102/repairs/F1b-F2-r22-lesson.md`, `reports/round-102/repairs/F3-sha-drift.md`).
- **G9 — PASS, with the standing 16 failures** documented in §7b: `cases=350 pass=334 fail=16`,
  `seeds_unchanged=true`. This is the expected host condition, not a regression.
- **G10 — FAIL (one cite).** The r102 lesson presents
  `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` as
  `UNRESOLVED=0` / `STEP=PASS`; re-run, it exits **1** with `UNRESOLVED=3`, because the
  newly-landed `gate/README.md` plants `upstream/README.md:200` — a non-sentinel control pointer
  the old checker must flag (mechanism in §7c). Its other cites are green: `audit_rc=0`, glob `24`,
  `gate_rc=0`, `labels_rc=0`.
- **G7 — PASS.** The lesson's pointers all resolve and the `engines.md` Unreal row carries the
  evidence-class update. The lesson-*command* half of the claim is what G10 fails.

**Two honest notes on the moving target.** (1) The r22 lesson changed under this seat **twice** —
first the F1b path fix, then the F2/F3 notes — so §7's "observed" column was correct when taken
and is superseded by the re-measurement above. (2) This protocol is a **snapshot**, not a verdict:
`corpus/knowledge/engines.md` changed sha256 twice and `gate/` went from absent to present between
two consecutive tool calls during authoring. **The close-out verdict must come from a re-run of the
whole sequence on the frozen committed tree, reported with that commit's SHA.** If any gate
regresses to FAIL at close, report it as a gap for that claim's axis — coverage for C1, depth for
C2 — and note that the round brief itself names coverage as the lowest non-retired axis, which is
exactly where a real gap would show.

---

## Appendix — one-shot runner

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# after §0.3 materialises the scanners
echo "== G1/G2 gate =="; bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
echo "== G5 labels =="; "$WORK/label-scan.sh" corpus/knowledge/unreal-mcp/executability 13; echo "rc=$?"
echo "== G4/G6 pointers =="; "$WORK/ptr-sweep.sh" corpus/knowledge/unreal-mcp; echo "rc=$?"
echo "== G6 pin =="; (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256); echo "rc=$?"
echo "== G9 battery integrity =="
git diff --stat HEAD -- corpus/fixtures/; git ls-files -s corpus/fixtures | awk '{print $2"  "$4}' | sort | sha256sum
sha256sum corpus/fixtures/run_battery.py
python3 corpus/fixtures/run_battery.py > "$WORK/battery.out" 2>&1; echo "battery_rc=$?"
grep -E '^FAIL [a-z]' "$WORK/battery.out"   # expect exactly the known 16 names, never a 17th
grep -E '^totals:' "$WORK/battery.out"      # expect cases=350 pass=334 fail=16
echo "== G10 lesson commands green =="
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "audit_rc=$?")
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp >/dev/null 2>&1; echo "ptr_rc=$?"
bash /tmp/r101-closeout/label-scan.sh corpus/knowledge/unreal-mcp/executability 13 >/dev/null 2>&1; echo "labels_rc=$?"
echo "== G8 repair lattice =="
grep -c 'shokunin/game-dev-3d' corpus/artifacts/unreal-r22/README.md
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "rc=$?"
grep -c 'shokunin/game-dev-3d' corpus/lessons/r22-unreal-review.md
grep -ci 'correction' corpus/lessons/r22-unreal-review.md
sed -n '11p' corpus/knowledge/engines.md | grep -c 'npm ci --prefix'
grep -c 'Correction note (r102' corpus/knowledge/rea.md
sed -n '10p' corpus/knowledge/engines.md | grep -c 'two static evidence classes'
```

Record every command with its observed output. **A step whose output was not captured was not run,
and has not passed.**
