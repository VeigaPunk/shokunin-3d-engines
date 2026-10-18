# r102 · SEAT-41 SKILL-TABLE-REVIEW — adversarial review of the draft decision table

**Seat:** SEAT-41 SKILL-TABLE-REVIEW · round 102 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-102/skill-table-review.md` (this file only). No `corpus/`
file, no pinned subtree byte, and no other seat's report was written or modified.
**Subject reviewed:** `reports/round-102/skill-decision-table-draft.md`
(SEAT-40 SKILL-TABLE-AUTHOR), frozen at
`sha256 fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2`, **373 lines**,
snapshot kept at `/tmp/s41-draft-snapshot.md` (same hash). Every line citation below is to that
frozen revision, not to the live file — the draft moved **353 → 373 lines during this review**, so
line numbers in the live file may already differ. I re-hash before each claim.
**Date:** 2026-10-18 · lane HEAD `2c99b7b` · no commit.

Two questions, per the seat brief, answered row by row in §2:
**(Q1) is every row executable without oral context?** **(Q2) does any row permit a claim the
r101 evidence cannot support?**

Tags: **[O]** command run by this seat with output quoted · **[D]** deduped from another artifact ·
**[F]** falsified — the draft's own claim did not reproduce.

**No Unreal runtime claim is made or implied anywhere in this review.** Unreal Editor is not
installed on this host; nothing here asserts live-editor behavior. Row C's posture is the one part
of the draft I found sound without qualification, and I say so below.

---

## 1. Bottom line

| row | Q1 executable as written? | Q2 can it outrun the evidence? | verdict |
|---|---|---|---|
| **A** — file byte-identity | canonical command **yes**; its §2/§4 **receipts [F]** | no (the row itself is sound) | **REVISE — receipts falsified** |
| **B** — static parse | **NO** — the cell's `jq` command exits 3 as written; `shellcheck` is cwd-ambiguous | **yes** — `shellcheck rc 0` is true only under the default ruleset | **REVISE — not executable as written** |
| **C** — runtime behavior | **yes** | **yes, narrow** — inherits the unresolved F7 label collision | **PASS with one required qualifier** |
| **D** — Kimi-side adaptation | **yes** (one `rc` omission) | **yes** — `verified-here` carries two different meanings | **REVISE — `verified-here` is two vocabularies** |

Table-level verdicts, each with a receipt in §3:

- §0's word **"exhaustive"** is **[F]**: `corpus/artifacts/unreal-r22/` — a whole evidence class
  named by `engines.md:10` — is covered by no row and is never mentioned in the draft.
- §6's **"Every canonical command in §1 was run by this seat"** is **[F]** for row B.
- §4's **"every row's check was shown to be able to fail"** is **[F]** by the draft's own admission
  at line 192 (row C has "no pass/fail control by construction").

The draft is honest, well-cited, and its *refusals* (§5) are exactly right. It is not yet a table a
stranger can execute, and two of its four rows can carry a label further than the evidence goes.

---

## 2. Per-row verdicts

### Row A — file byte-identity → **REVISE (receipts falsified); the row itself is sound**

**Q1 — executable?** Yes. The §1 cell (snapshot line 62) carries its own cwd, unlike every other
row: `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256`. Run
verbatim:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
… upstream/skills/unreal-skill/SKILL.md: OK
rc=0        # 12 × OK
```

Its `+NC` is also executable: `printf '\n' >> upstream/README.md` on a *copy* →
`upstream/README.md: FAILED`, rc 1. **[O]**

**Q2 — outruns the evidence?** No. Byte-identity is the one class this host can prove, and row A
requires both the manifest row **and** the `git show <pin>:<path>` comparison. That is correct.

**But the row's receipts do not reproduce. [F]** §2 (snapshot lines 111–117) prints:

```
upstream/README.md: FAILED
upstream/skills/unreal-mcp/SKILL.md: FAILED
MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1
```

under the narration *"printf '\n' >> …/ncC1/upstream/README.md"* and explains it as *"the append
shifted the line count of a file that another manifest row also covers."* A genuine 1-byte append
does not do that:

```
$ T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"; printf '\n' >> "$T/sub/upstream/README.md"
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')   → 11
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED') → 1
$ (cd "$T/sub" && bash gate/run_gate.sh 2>&1 | grep -E 'MANIFEST_OK|BLOB_DIFFS|UNRESOLVED')
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
BLOB_DIFFS=1
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

**The explanation is false on its own terms.** `audit-reference.sha256` lists each of the 12
vendored paths **exactly once**:

```
$ awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 | sort | uniq -c
  # no line with count > 1  → 12 unique paths
```

So no second manifest row covers `README.md`, and an append to it cannot flip a second file. The
`FAILED=2` in the draft comes from a **different command and a different mutation**: the
`*.sha256` glob (which does cover each file twice, so `FAILED=2` there is real) applied to
`/tmp/r102-s40/ncC1/`, which I inspected:

```
$ wc -c /tmp/r102-s40/ncC1/upstream/README.md /tmp/r102-s40/ncC1/upstream/skills/unreal-mcp/SKILL.md
   55 /tmp/r102-s40/ncC1/upstream/README.md
   17 /tmp/r102-s40/ncC1/upstream/skills/unreal-mcp/SKILL.md
$ cat /tmp/r102-s40/ncC1/upstream/README.md   → "TAMPERED - README content replaced, hash would differ"
$ head -1 /tmp/r102-s40/ncC1/upstream/skills/unreal-mcp/SKILL.md → "# TAMPERED SKILL"
```

That is a **two-file wholesale replacement**, not a one-byte append. `MANIFEST_OK=10` matches that
dir exactly; the §2 narration does not describe it. The draft's §1 `+NC` text (line 62) says the
control yields a **single** `upstream/README.md: FAILED` — which contradicts §2's two `FAILED`
lines in the same document.

**Disposition.** Mechanical: re-run the control on a fresh copy and paste the real numbers
(`MANIFEST_OK=11 FAILED=1 RC=1`, `BLOB_DIFFS=1`, `UNRESOLVED=0`), or relabel the receipt as the
two-file replacement it actually was. Either way the §2 *reason* sentence must go — it is wrong for
`audit-reference.sha256`. This is a command/path-conformance defect, so it is an in-place fix, not
a dated correction note.

### Row B — static parse → **REVISE (not executable as written)**

**Q1 — executable without oral context? NO. [F]** The §1 cell (snapshot line 63) gives two
commands. The first, run verbatim, does not do what the cell says:

```
$ jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json ; echo "rc=$?"
jq: error: upstream/0 is not defined at <top-level>, line 1, column 1
jq: error: plugin/0 is not defined at <top-level>, line 1, column 18
jq: 3 compile errors
rc=3
```

The cell writes `→ rc 0`. The form that works has a `.` filter — which the §2 receipt has and the
§1 cell dropped:

```
$ jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json ; echo "rc=$?"
rc=0
```

So the table's own canonical command fails, while the receipt below it passes: a stranger
copying the cell gets exit 3 and no signal about which of the two forms is authoritative.

The second command is **cwd-ambiguous**, unlike row A which states its cwd:

```
$ shellcheck upstream/hooks/unreal-context.sh        # from lane root
upstream/hooks/unreal-context.sh: openBinaryFile: does not exist
rc=2
$ (cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh)
rc=0
```

Row B's cell names no cwd while listing a repo-root-relative path
(`corpus/knowledge/unreal-mcp/gate/run_gate.sh`) in the same cell. That is the definition of
"needs oral context".

**Q2 — outruns the evidence? YES, narrowly. [F]** The cell claims `shellcheck … → rc 0`
unconditionally. That is true only under shellcheck's **default** ruleset:

```
$ shellcheck --version | head -2         → ShellCheck 0.11.0
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null); echo rc=$?
rc=1        # 31 findings
```

`reports/round-101/r101-distiller.md:74` records the same default-vs-`-o all` split (it measured 50
findings then; it is 31 now — the number moves, the split does not). A row-B claimant can cite
"shellcheck rc 0" and be silently quoting a default-ruleset result that has 31 opt-in findings
behind it. The row must say **which ruleset**, or the claim is unfalsifiable at the boundary.

**Third gap.** The cell's required-evidence column accepts "a pointer sweep" as row-B evidence, but
row B's only `+NC` exercises the **label scan**. The pointer sweep's control lives in §4 (and in row
A's control), not in row B. Half of row B's declared evidence has no non-vacuity control attached
to the row that claims it.

### Row C — runtime behavior → **PASS with one required qualifier**

**Q1 — executable?** Yes. Every command reproduces:

```
$ which UnrealEditor UnrealEditor-Cmd        → rc=2
$ ls /opt/UnrealEngine                       → "No such file or directory", rc=2
$ git ls-remote https://github.com/EpicGames/unreal-engine HEAD
remote: Repository not found.  fatal: … rc=128
```

Minor omission: §2 (snapshot line ~178) also shows
`gh api repos/EpicGames/UnrealEngine --jq .id` → `{"message":"Not Found",…,"status":404}` with no
exit code. `gh` treats the 404 as an error:

```
$ gh api repos/EpicGames/UnrealEngine --jq .id >/dev/null 2>&1 ; echo rc=$?
rc=1
```

A receipt that prints JSON but exits 1 should say so.

**Q2 — outruns the evidence? YES, narrowly.** Row C's permissible-label column writes
`` `unproven` (binary) ⇔ `unproven-runtime` (ternary) ``. But the r101 subtree is not a single
vocabulary here, and row C silently inherits the collision:

- `corpus/knowledge/unreal-mcp/README.md:41` defines `unproven-runtime` as *"the claim needs the
  live editor and nothing was observed."*
- Six of the 13 cards reject exactly that label, arguing the path is not even identified
  (`executability/blueprints.md:113`). Re-derived:

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

So a row-C claim about Blueprint graphs is **forced to `unproven-runtime` by the table** while the
card for that same subsystem says that label is wrong. Row C therefore permits a label that half
the corpus disputes — which is the r101 F7 finding (`reports/round-101/r101-critic-c3.md:317`),
carried into the draft's §3 but applied there only to rows B and D.

**Disposition.** Row C is otherwise the strongest row in the table — it forbids the runtime claim
rather than permitting it, and it states its own lack of a pass/fail control. It needs one added
clause: *a row-C label is `unproven-runtime` until the F7 precedence ruling lands, and a claim on
one of the six dissenting subsystems must cite the card it contradicts.* Its honesty about having
no control is right — but see §4's heading, which contradicts it.

### Row D — Kimi-side adaptation → **REVISE (`verified-here` is two vocabularies)**

**Q1 — executable?** Mostly. `/home/vgpnk/.kimi-code/bin/kimi --version` → `2.2.0` **[O]**. The
strings probes reproduce:

```
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c additionalContext      → 0   (pipeline rc=1)
$ … grep -c CLAUDE_PLUGIN_ROOT                                                  → 0
$ … grep -c enabledPlugins                                                      → 0
$ grep -n 'KIMI_PLUGIN_ROOT_PATH = ' /tmp/s41-kimi_strings6.txt | head -1
749729:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
$ file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID\[sha1\]=[0-9a-f]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
```

The BuildID in the draft is correct **[O]**. One executable wrinkle: `grep -c` on a zero-hit search
prints `0` but **exits 1**. The cell writes `→ 0` with no `rc`; a reader scripting on the exit code
sees failure. The draft is careful to call these "negative-claim evidence," so this is a notation
gap, not a wrong claim — but a table a stranger executes should carry the exit code it actually
produces.

**Q2 — outruns the evidence? YES.** Row D's permissible-label column grants `verified-here` for six
adaptation rows. Those six are real:

```
$ sed -n '25,50p' corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -oE '\| (verified-here|static-only) \|' | sort | uniq -c
      6 | verified-here |
      9 | static-only |
```

— rows 2, 3, 4, 8, 9, 11, exactly as the draft says. **But the token means two different things in
the two files the row points at:**

- `README.md:39` (card ternary): `verified-here` = *"a bounded run of the subsystem actually
  happened on this host, with a saved receipt"* — a **subsystem-behavior** claim.
- `adaptation-kimi.md:27`: `verified-here` = *"reproduced by a command run on this host, output
  pasted in the row"* — a **row-probe** claim.

A reader who takes the adaptation table's row-level `verified-here` and maps it onto the card
ternary's subsystem-level `verified-here` has asserted editor behavior that r101 explicitly did not
observe. This is the sharpest instance of "a row permitting a claim the r101 evidence cannot
support": the label is correct in its home file and unsupported when the table re-exports it. §3
names the problem ("Rows B and D are not [unambiguous]") but the row-D cell still writes the bare
token, so the ruling never reaches the row a consumer actually reads.

**Disposition.** Row D must carry the qualifier inline — e.g. `verified-here (row-probe sense: a
command ran here; NOT the card sense of observed subsystem behavior)` — because the §3 discussion
is below the table and a consumer copying a row will not read it.

---

## 3. Table-level defects, each with its receipt

### 3.1 §0's "exhaustive" is false — the r22 evidence class has no row **[F]**

Snapshot line 27: *"the four claim types below are exhaustive over the Unreal artifacts in this
lane."* `corpus/knowledge/engines.md:10` names **two** evidence classes for the Unreal row:

```
| Unreal Engine | no | no | two static evidence classes, both `static-only` …:
  (a) r22 self-authored `corpus/artifacts/unreal-r22/` `.uplugin` sample + non-author review;
  (b) r101 third-party pinned tree `corpus/knowledge/unreal-mcp/` …
```

The table covers class (b) only. Class (a) — a lane-authored `.uplugin` with its own static checker,
which runs here and discriminates:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py ; echo rc=$?
PASS local-static actual=accept expected=accept … rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject ; echo rc=$?
PASS local-static actual=reject expected=reject … rc=0
```

— appears in **no** row, and the strings `unreal-r22` / `verify_descriptor` / `uplugin` occur **0**
times in the draft. §5's refusal 1 cites `engines.md` but only to forbid promotion, not to cover the
class. Either the table gains an E-row for lane-authored static artifacts, or §0 must say "exhaustive
over the *pinned-subtree* artifacts."

### 3.2 §6's "Every canonical command in §1 was run by this seat" is false for row B **[F]**

Snapshot line 338. Row B's §1 `jq` command exits 3 as written (§2, row B above); only the §2
variant with the `.` filter exits 0. The claim as written cannot be true of both forms.

### 3.3 §4's heading contradicts row C's own text **[F]**

Snapshot line 283: *"every row's check was shown to be able to fail."* Snapshot line 192, inside the
same section: *"This row has **no pass/fail control by construction**."* The heading must read
"every row that has a control" or similar. This is not pedantry — the heading is what a verifier
reads when deciding whether the table is non-vacuous, and row C is precisely the row where the
question is unanswerable.

### 3.4 Bare `README.md` is ambiguous between two files — a real oral-context dependency **[F]**

The draft header (snapshot line 7) cites `README.md:10-11` meaning the **lane root** `README.md`
(22 lines: *"SKILL.md — the distilled expertise: decision tables…"*). Rows A–C and §3 cite
`README.md:12-29`, `:31-48`, `:41`, `:204-211`, `:229-240`, `:257-274` meaning the **subtree**
`README.md` (278 lines). Resolved mechanically against both candidates:

```
README.md           10-11      len 22   OK              → lane root README
README.md           12-29      len 22   OUT-OF-RANGE    → (subtree README: 278 lines, OK there)
README.md           31-48      len 22   OUT-OF-RANGE
README.md           40         len 22   OUT-OF-RANGE
README.md           41         len 22   OUT-OF-RANGE
README.md           204-211    len 22   OUT-OF-RANGE
README.md           229-240    len 22   OUT-OF-RANGE
README.md           257-274    len 22   OUT-OF-RANGE
```

Eight citations are unresolvable if a reader uses the file the draft's own header establishes for
that token. Every one is correct against the subtree README — so the fix is cheap (write
`unreal-mcp/README.md:NN` or `corpus/knowledge/unreal-mcp/README.md:NN`), but as written the table
fails the "executable without oral context" test on its most-cited file.

### 3.5 §2's "independent" re-derivation is not reproducible by a stranger

Snapshot lines 104–110 run `diff` and a `git show` loop against `/tmp/r102-s40/clone` and
`/tmp/r102-s40/ncC1` — an **ephemeral** scratch tree (present now, gone on reboot) and an elided SHA
`a6aa73ad…`. The draft's own §1 correctly requires "a **fresh** clone" for row A; its receipt then
cites a cached one. This is the same class as the F5 three.js defect (a command that cannot
reproduce its own cited output from a clean tree). The gate's CHECK 2 already does this properly
with `mktemp`; the §2 block should defer to it.

### 3.6 Live-mutation disclosure is present but the citations are not re-hashable

The draft states its concurrency (§6) and this review confirms it: the draft moved **353 → 373
lines** and the subtree `README.md` was edited at 14:43 (the F8 fold, `git diff` = 3 insertions /
3 deletions, line count unchanged at 278 — which is why the subtree citations survived). The
lesson `corpus/lessons/r102-unreal-integration.md` moved **178 → 212 lines** mid-review; the
draft's `:168-212` and `:168-174` citations resolve against the *current* 212-line file **[O]**.
Every line citation in this review is pinned to `sha256 fa360bde…`; a landing seat must re-hash
before trusting any of them.

---

## 4. What the draft gets right (stated, because a review that only subtracts is not a review)

- **The §5 refusals are correct and load-bearing.** No row promotes an engine census row; no row
  lets a static check stand for behavior; no row accepts a prose count; no row lets `verified-here`
  appear without a receipt. Each restates a rule that the r101 evidence actually supports.
- **Row C's posture is exactly right.** It is the row that says *no*, and it says it with a
  reproducible receipt (`which` rc 2, `ls` rc 2, `git ls-remote` rc 128) rather than an assertion.
- **The §3 F7 collision is diagnosed accurately**, with the six-card census re-derived and the
  `blueprints.md:113` witness quoted verbatim. The diagnosis is right; only its *reach* is too
  narrow (§2 row C, row D above).
- **§4's controls are real.** C3 (`UNRESOLVED=1`) and C4 (`FAIL multi-label`) reproduce exactly as
  printed, and C6 (`CARDS=12 EXPECTED=13`) reproduces **[O]**. The gate is non-vacuous; only C1/C2's
  *numbers* are wrong, not the fact that the checks bite.

---

## 5. Required before this table can be called executable

1. **Row B:** restore the `.` filter in the §1 cell (`jq -e . <files>`) and state the cwd for the
   `shellcheck` line — or move both into a single `cd corpus/knowledge/unreal-mcp && …` prefix as
   row A does.
2. **Row A §2/§4:** replace the two-file-replacement receipt with a genuine one-byte-append receipt
   (`MANIFEST_OK=11 FAILED=1 RC=1`, `BLOB_DIFFS=1`, `UNRESOLVED=0`) and delete the false
   "another manifest row also covers" sentence.
3. **Row B:** name the shellcheck ruleset (`default` → rc 0; `-o all` → rc 1, 31 findings).
4. **Row D:** inline the `verified-here` disambiguation; do not leave it to §3.
5. **Row C:** add the F7 precedence clause.
6. **Table:** qualify §0's "exhaustive", fix §4's heading, disambiguate every bare `README.md`, and
   either add an E-row for `corpus/artifacts/unreal-r22/` or narrow §0's scope.

Until items 1–3 land, a stranger cannot execute rows A and B, and rows B and D can each carry a
label one step further than the r101 evidence reaches. Items 4–6 are correctness of scope rather
than of command.

---

## 6. Reproduce this review

From the lane root, on `2c99b7b`:

```sh
# the subject, frozen
cp reports/round-102/skill-decision-table-draft.md /tmp/s41-draft-snapshot.md
sha256sum /tmp/s41-draft-snapshot.md   # fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2

# row A canonical + the falsified append control
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)      # 12 OK, rc 0
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf '\n' >> "$T/sub/upstream/README.md"
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')    # 11, not 10
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED') # 1, not 2

# row B's cell command as written vs as receipted
jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json ; echo rc=$?          # rc 3
(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json; echo rc=$?)  # rc 0
shellcheck upstream/hooks/unreal-context.sh ; echo rc=$?                                  # rc 2 from root
(cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null; echo rc=$?)          # rc 1

# row C
which UnrealEditor UnrealEditor-Cmd ; echo rc=$?                                          # rc 2
git ls-remote https://github.com/EpicGames/unreal-engine HEAD ; echo rc=$?                # rc 128

# the F7 census row C inherits
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l # 6

# row D
strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c additionalContext                  # 0, rc 1
file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID\[sha1\]=[0-9a-f]*'                # 5e67bdf9…

# the class §0 calls "exhaustive" and the table never mentions
grep -c "unreal-r22\|verify_descriptor" reports/round-102/skill-decision-table-draft.md   # 0
python3 corpus/artifacts/unreal-r22/verify_descriptor.py ; echo rc=$?                      # rc 0
```

---

## 7. Limits of this review

- **I am a reviewer, not the author.** I did not edit the draft, and I did not resolve any defect
  I found — the fixes belong to the draft's owner or the landing seat.
- **I verified the four rows and the six table-level claims above. I did not re-audit every one of
  the draft's ~40 citations** — the line-range sweep in §3.4 covers all of them mechanically, but a
  range being *in bounds* is not a claim that the quoted words are on those lines; I checked the
  load-bearing ones by reading them.
- **No Unreal runtime claim.** The editor is not installed; nothing above asserts any live-editor
  behavior, and row C's inability to be controlled is a property of the host, not a defect.
- **The subject is live.** `fa360bde…`/373 lines is a snapshot; the draft and two of its cited files
  moved during this review. Re-hash before acting on any line number here.
