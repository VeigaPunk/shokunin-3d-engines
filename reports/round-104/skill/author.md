# r104 · SEAT-18 SKILL-AUTHOR — landing the "Unreal-content claim discipline" table

**Seat:** SEAT-18 SKILL-AUTHOR · round 104 · lane `game-dev-3d-shokunin`
**Owned paths written:** `SKILL.md` (the lane's first) and this file
(`reports/round-104/skill/author.md`). No `corpus/` byte, no fixture, no
`LOG.md`/`SCORECARD.md`/`SHONEN.md`/`PROVINCE.md` byte, no
`reports/round-10{1,2,3}/**` file, and no other seat's report was written or
modified.
**Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103
report-last; work `8c9d9ad`).
**Date:** 2026-10-18.

**No Unreal runtime claim is made or implied anywhere in this file or in
`SKILL.md`.** Unreal Editor is not installed on this host (`which UnrealEditor`
→ rc 2, re-run in §2). Every check below is a filesystem, byte, or static-parse
operation.

---

## 0. Bottom line

The seat brief said "land the table from `reports/round-102/skill-decision-table-draft.md`
as a new `SKILL.md` section, keep the rest of `SKILL.md` byte-stable".
**`SKILL.md` does not exist in this lane**, so there was no "rest" to keep
stable: the file had to be created, and "byte-stable" is discharged as a
measurable absence (there was no prior file to preserve — §3.6).

The r103 review's fold decision was **"do NOT land yet"**, gated on six
conditions (§6 of `reports/round-103/skill-table-review.md`). Its one blocking
condition — *land after the gate hardening is committed* — **is now satisfied**:
`run_gate.sh` is `577c8b54…` in the worktree **and** at `HEAD`, with a clean
`git status --porcelain` on it, so the A1–A4 hardening is no longer an
uncommitted worktree fact. Conditions 1–5 are applied in the landed file, each
with an acceptance command run in §3.

Three things the draft got wrong that the r103 review had already measured are
**corrected in the landed text, not carried forward**: the row-A control
(`11/1`, not `10/2`), row B's two non-reproducing commands, and the gate
line-number citations (zero carried; acceptance `grep -cE 'run_gate\.sh:[0-9]'
SKILL.md` → `0`).

---

## 1. What the brief assumed, and what the tree says

| brief says | measured | command |
|---|---|---|
| "as a new `SKILL.md` section" | `SKILL.md` does not exist at lane level | `ls SKILL.md` → `No such file or directory`, rc 2 |
| "keep the rest of `SKILL.md` byte-stable" | vacuously satisfied — there is no rest | `find . -name 'SKILL.md' -not -path './.git/*' -not -path './corpus/knowledge/unreal-mcp/upstream/*'` → **0** results (the only hits are the three vendored copies inside the pinned upstream, and this round's `reports/round-104/gate/scratch/**` clones of them) |

This matches the r103 record independently: `reports/round-103/seats-ledger.md`
§2 ("PASS (none exists outside the pinned upstream)"), `reports/round-103/math-audit.md`
row 13, and `reports/round-103/r103-connector.md` §3.1 (`ls SKILL.md` → `No such
file or directory`).

**Consequence.** Landing the table is a *promotion action* — it creates the
lane's skill file — and `SHONEN.md:1` box 1 is a promotion gate requiring a
**named non-author verifier**. This seat is the author, so nothing here closes
box 1; at most it moves the box from "no distilled table" to "distilled table
awaiting verification". That limit is stated inside `SKILL.md` §6 so a reader of
the file cannot overread it.

---

## 2. Per-row receipts — every canonical command re-run by this seat

All commands run from the lane repo root on 2026-10-18 against HEAD `88c3b2c`,
unless the command itself says otherwise. Outputs quoted verbatim.

### Row A — file byte-identity

```
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')
12
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "rc=$?")
rc=0
```

**The negative control, on a `/tmp` copy — and this is the number the r102 draft
got wrong.** The r102 draft printed `MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1`
and explained it with *"the append shifted the line count of a file that another
manifest row also covers"*. The r103 review falsified both halves. Re-derived
here:

```
$ T=$(mktemp -d /tmp/r104s18.XXXXXX); cp -r corpus/knowledge/unreal-mcp "$T/sub"
$ printf '\n' >> "$T/sub/upstream/README.md"
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')
11
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep 'FAILED')
upstream/README.md: FAILED
$ awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 | sort | uniq -d | wc -l
0
```

**11 OK / 1 FAILED**, and the manifest lists each of the 12 paths **exactly
once** (0 duplicates), so no second row can cover `README.md` and a 1-byte append
cannot flip a second file. The landed `SKILL.md` states `MANIFEST_OK=11 FAILED=1`
and contains no trace of the false sentence — acceptance in §3.2.

### Row B — static parse

```
$ (cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo "rc=$?")
rc=0
$ (cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo "rc=$?")
rc=3
$ (cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo "rc=$?")
rc=0
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo "rc=$?")
rc=1
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -cE '^In .* line')
31
$ (cd corpus/knowledge/unreal-mcp && bash -n upstream/hooks/unreal-context.sh; echo "rc=$?")
rc=0
```

All three r102 defects reproduce: the dot-less `jq` form exits **3** where the
draft's cell claimed `rc 0`; `shellcheck` is cwd-dependent (and here it happens
to pass from the repo root too, because the file argument is a path — but the
ruleset is what the draft never named). The landed cell carries the `.` filter,
the `(cd corpus/knowledge/unreal-mcp && …)` prefix on every command, and the
ruleset name with both rcs: default → 0, `-o all` → 1 with 31 findings.

### Row C — runtime behavior

```
$ which UnrealEditor UnrealEditor-Cmd >/dev/null 2>&1; echo "rc=$?"
rc=2
$ ls /opt/UnrealEngine >/dev/null 2>&1; echo "rc=$?"
rc=2
$ git ls-remote https://github.com/EpicGames/unreal-engine HEAD 2>&1 | head -2
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

The F7 collision is exactly as live as r101 measured it: six cards reject the
label the subtree `README.md` defines. The landed row C carries the r103
review's required clause **in the cell** (§3.4).

### Row D — Kimi-side adaptation

```
$ /home/vgpnk/.kimi-code/bin/kimi --version
2.2.0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c additionalContext
0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c CLAUDE_PLUGIN_ROOT
0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c enabledPlugins
0
$ file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID\[sha1\]=[0-9a-f]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
```

The landed cell inlines the two-sense disambiguation of `verified-here` (§3.4)
and keeps the BuildID clause, because the evidence dies on a CLI upgrade.

### Row E — lane-authored static descriptor (the row the draft was missing)

The r103 review's §3.1 held that the draft's §0 claim of an *exhaustive* four-row
partition is false, because `corpus/artifacts/unreal-r22/` had no row. Rather
than narrow the claim to "the pinned subtree", this seat **adds the row**, so the
partition is exhaustive over both Unreal evidence classes the lane actually
carries:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept path=…/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
rc=0
```

Both controls pass, so the row is non-vacuous. The cell forbids `verified-here`
and forbids any statement about Unreal accepting the descriptor — the checker is
the lane's own, so the claim reaches only the lane's writing. That distinction is
the same one `corpus/knowledge/engines.md` makes between evidence classes (a)
and (b).

### The gate — clean run, and the citation form it forces

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

`POINTERS=101` matches the pin in `gate/README.md` (re-measured 2026-10-18T18:43Z
at HEAD `c85a816`, scanner `577c8b54…`). The landed `SKILL.md` cites the gate by
`CHECK n <name>` plus its sha256 and carries **no** gate line number — the
acceptance command for that is in §3.1.

---

## 3. The r103 review's six landing conditions, each with its acceptance command

| # | condition (`reports/round-103/skill-table-review.md` §6) | status | acceptance command + observed result |
|---|---|---|---|
| 1 | re-cite the gate by name + hash, zero line numbers | **met** | `grep -cE 'run_gate\.sh:[0-9]' SKILL.md` → `0` |
| 2 | row A's control to 11/1; delete the false sentence | **met** | the file states `MANIFEST_OK=11 FAILED=1`; `grep -c 'another manifest row' SKILL.md` → `0` |
| 3 | fix row B's two commands; name the shellcheck ruleset | **met** | every row-B command in the cell carries `(cd corpus/knowledge/unreal-mcp && …)` and reproduces its printed rc (§2 row B); the cell names `default` → 0 and `-o all` → 1 / 31 findings |
| 4 | inline row D's disambiguation **and** add row C's F7 clause — *in the cell*, not in a section below | **met** | both clauses are inside the `permissible label` cell of rows D and B respectively; a consumer copying a row never has to read §4 |
| 5 | re-stamp the artifact index; qualify §0's "exhaustive" | **met** | §6 of `SKILL.md` re-stamps all eight artifacts with live sha256s; the "exhaustive" claim is discharged by **adding an E-row**, not by narrowing |
| 6 | a named **non-author** verifier moves box 1 `[ ]` → `[x]` | **owed, by construction** | this seat is the author; `SKILL.md` §6 states the box reads `[~]` until such a verifier records a pointer |

### 3.6 "Keep the rest of `SKILL.md` byte-stable"

There was no prior `SKILL.md`, so the closest honest discharge is a demonstration
that the file this seat created is the only lane-level `SKILL.md` and that no
pre-existing artifact was disturbed:

```
$ find . -name 'SKILL.md' -not -path './.git/*' -not -path './corpus/knowledge/unreal-mcp/upstream/*'
   … only reports/round-104/gate/scratch/**/upstream/skills/*/SKILL.md (another seat's scratch clones)
$ git status --porcelain corpus/knowledge/unreal-mcp/upstream/ corpus/knowledge/unreal-mcp/.manifest.d/
   (empty)
```

### 3.7 The file is beyond the table — deliberately

`PROTOCOL.md`'s promotion gate requires box 1 to carry **a decision table, an
error-pattern list, and a checklist**, each citing a resolvable source. The brief
named only the table, so landing the table alone would have produced a `SKILL.md`
that cannot close box 1 even after verification. The file therefore carries all
three, all sourced from this lane's own measured defects:

- §1 the decision table (rows A–E);
- §2 seven named error patterns (`prose-cites-bytes`, `count-written-into-prose`,
  `implicit-cwd command`, `scanner-relative datum`, `green-gate-overread`,
  `binary-strings-citation`, `command-does-not-reproduce-its-printed-rc`) — every
  one of which is a defect this lane actually observed and repaired;
- §3 the pre-claim checklist, each item a command.

This is an addition beyond the brief's minimum. It is reported here so the
integrator can rule on it rather than discover it.

---

## 4. A gate red observed mid-seat, and its attribution

At 16:19Z, immediately after `SKILL.md` was written, the gate reported:

```
FAIL per-seat manifest sweep (--strict) failed:
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)
GATE_RC=1
```

This is **not caused by `SKILL.md`**, and the attribution is a 2×2, not an
inference:

| `SKILL.md` | `TMPDIR` | gate result | rc |
|---|---|---|---|
| present | unwritable (`chmod 555` dir) | `FAIL per-seat manifest sweep` + `STEP=BLOCKED` | 1 |
| **absent** | unwritable | **identical red** | 1 |
| present | writable (`/tmp`, later) | `PASS` | 0 |
| **absent** | writable | `PASS` | 0 |

And the sharpest form of the pair — **two runs seconds apart on the same tree,
`SKILL.md` present in both, changing only `TMPDIR`**:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'FAIL|STEP=BLOCKED|GATE RESULT'
FAIL per-seat manifest sweep (--strict) failed:
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)          # rc 1

$ TMPDIR=/home/vgpnk/r104scratch-s18/tmp2 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'FAIL|MANIFEST_OK|STEP=|GATE RESULT'
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS ×4
GATE RESULT: PASS (checks failed: 0)          # rc 0
```

`df -h /tmp` read **13 G used / 3.1 G free** in both runs. The difference is
`TMPDIR` alone.

The cause is the `mktemp` at the top of the gate (`MANLOG=$(mktemp)`, and the
`WORK=$(mktemp -d)` used by CHECK 2). When `TMPDIR` cannot be written, `mktemp`
fails, the `sha256sum --strict` sweep never runs, and the gate prints a
**spurious fail-closed** — the exact defect class the gate's own r103 comment
records as fixed by replacing a hardcoded `/tmp/advgate` path with `mktemp`. The
fix removed the *hardcoded path*; it did not remove the *dependence on a writable
temp dir*. At the identity this seat measured (`577c8b54…`) the sweep was:

```
$ grep -n 'MANLOG=' corpus/knowledge/unreal-mcp/gate/run_gate.sh     # at 577c8b54…
116:MANLOG=$(mktemp)                                                   # bare: no -p, no failure branch
```

On this host `/tmp` is a shared 16 G tmpfs sitting at **13 G used / 3.1 G free
(80 %)**, and the mechanism reproduced deterministically both ways:

```
$ TMPDIR=<unwritable> mktemp
mktemp: failed to create file via template '<unwritable>/tmp.XXXXXXXXXX': Permission denied
mktemp rc=1
$ timeout 180 git clone --quiet <upstream-url> /tmp/r104clone.XXXXXX/clone
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to …: Disk quota exceeded
```

Three consecutive runs with a writable `TMPDIR` and `SKILL.md` present were all
`GATE RESULT: PASS`, rc 0. **The gate is green on the delivered revision.**

This is independent corroboration of C2's premise (`GATE_WORKDIR` + `TMPDIR`
support), found from a different direction: the r103 root cause was recorded as
"`/tmp` 16 G tmpfs quota pressure silently breaking `mktemp`/clone", and here the
same pressure produced a **red gate** rather than a silent one — because the
`MANLOG` redirect turned an infrastructure failure into a verdict.

### 4.1 SEAT-12 landed the C2 fix *during* this seat's run — and it closes this hazard

While this seat was re-stamping citations, `run_gate.sh` moved again, and the
change is precisely the `WORK_ROOT` hardening:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # observed sequence this seat
577c8b54…  (HEAD, 347 lines)   → 7903c589…  → 15fc46d5…  → b6d8c61a… (433)  → 96bcf45a… → e5521304… (442, settled)
$ grep -n 'MANLOG=' corpus/knowledge/unreal-mcp/gate/run_gate.sh   # at e5521304…
124:MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
…
GATE RESULT: PASS (checks failed: 0)          # rc 0
```

`mktemp` is now rooted at `${GATE_WORKDIR:-${TMPDIR:-/tmp}}` with a validated
root and a **loud** failure branch, and the banner prints `WORK_ROOT=` and
`WORK_ROOT_FREE=`. The gate is **green on the default `TMPDIR`** at `e5521304…`
— so the red reported in §4 is closed by the C2 seat's own fix, not by anything
this seat changed. `gate/README.md` documents it under "Running under quota
pressure" with controls W0/W1 (default `/tmp` → PASS, `POINTERS=103`).

**Two consequences for this seat's artifact.** (i) The gate is `M`
(worktree-modified, uncommitted) again — HEAD still carries `577c8b54…` — so
`SKILL.md` §6 marks both `gate/` stamps **worktree** and says to re-read them.
(ii) The hazard in §4 is now *fixed*, so `SKILL.md` §2 records it as an error
pattern (a named failure mode with a workaround) rather than as an open defect,
and the checklist tells a reader to redirect the scratch root before believing a
gate red. `POINTERS` read `103` at this identity against `101` at `577c8b54…` —
one more datum for the scanner-relative rule, and the reason `SKILL.md` still
quotes `UNRESOLVED=0` as the invariant rather than any count.

---

## 5. Files written

| path | sha256 | lines |
|---|---|---|
| `SKILL.md` | `de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903` | 182 |
| `reports/round-104/skill/author.md` (this file) | not self-referenceable — re-derive with `sha256sum reports/round-104/skill/author.md` | 402 |

Nothing else was created or modified. Scratch under `/tmp` and
`/home/vgpnk/r104scratch-s18/` (the row-A control copy, the writable-`TMPDIR`
probe, the mechanism repro, and the captured gate run) is outside the repo; the
`/tmp` copy was removed when `/tmp` hit quota.

**The two `gate/` stamps moved after this file's first write** (§4.1), so the
`SKILL.md` revision stamped above is the second one — the first
(`1055a52f…`, 174 lines) cited the pre-`WORK_ROOT` gate. The delivered revision
is the one in the table.

## 6. Limits, and what is owed

- **Box 1 is not closed and cannot be closed by this seat.** The file is the
  artifact half; the promotion half is a named non-author verifier. Both the
  draft's author (SEAT-40, r102) and its reviewers (SEAT-41, SEAT-59) are
  excluded, and so is this seat.
- **The F7 P/C precedence ruling is still owed and is not resolved here.**
  `SKILL.md` §4 states the collision and the interim binding text; it does not
  choose between Option P and Option C, because the subtree is byte-pinned and
  the two sides belong to other seats. `README.md`'s sha is unchanged
  (`c79d8dd1…`), so the disagreement is live at this revision.
- **Row D's evidence is BuildID-scoped.** `5e67bdf95c7646325b62decd0ca8d375d325ea19`
  (kimi v2.2.0). A CLI upgrade invalidates it; the cell says so.
- **New hazard routed — now closed by another seat, recorded here for the record.**
  At gate identity `577c8b54…` the gate converted an unwritable-`TMPDIR`
  infrastructure failure into `GATE RESULT: FAIL` + rc 1 rather than A4's
  `BLOCKED` / rc 2; evidence is §4. **SEAT-12's `WORK_ROOT` fix landed during this
  seat's run (§4.1) and closes it.** `run_gate.sh` is not this seat's path and this
  seat wrote no byte of it.
- **`SKILL.md` is not yet in `SHONEN.md`'s evidence chain.** `SHONEN.md` was not
  written by this seat (hard rule), so the box-1 line still reads `[ ]`. Flipping
  it is the verifier's action, on the evidence in this file.
- **This file's numbers are a frame.** The gate took ≥7 identities during r103 and
  `POINTERS` moved with concurrent prose edits. Re-hash before acting on any
  stamp above.
