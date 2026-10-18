# r104 · SEAT-19 SKILL-REVIEWER — non-author re-run of every command the decision table cites

**Seat:** SEAT-19 SKILL-REVIEWER · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-104/skill/review.md` (this file only). No `corpus/` file, no
fixture byte, no pinned subtree byte, no other seat's report was written or modified. Every mutation
below was applied to a `/tmp` or `/var/tmp` skeleton, never to the repo.
**Date:** 2026-10-18 · **Lane HEAD:** `88c3b2c` (r103 report-last; work `8c9d9ad`) · no commit.

**Subject under review — two artifacts, because the second landed while this seat worked.**

| subject | sha256 | lines | state |
|---|---|---|---|
| `SKILL.md` — **the table as landed** (C3's target) | `de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903` | 182 | worktree, untracked (`?? SKILL.md`), written 16:25Z *during this review* |
| `reports/round-102/skill-decision-table-draft.md` — the draft it descends from | `fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2` | 373 | unchanged since r102 |
| `reports/round-103/skill-table-review.md` — the review whose landing conditions it claims to meet | `95d40d92432252f66d6edf886ac99bf60e190461f075db3d7936bf94527d6815` | — | r103, unchanged |

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed
on this host; re-run below. Row C's posture is the one part of the table that needs no qualifier.

Tags: **[O]** command run by this seat with output quoted · **[F]** the subject's own claim did not
reproduce · **[C]** cross-referenced to another seat's report.

---

## 0. Bottom line

**Every one of the five rows (A–E) is EXECUTABLE: I re-ran each cited command and it reproduced.**
That is a first for this table — r103's review returned `REVISE` on three of four rows, and the
author's r104 response fixed all of them. The r103 findings that mattered are closed by measurement,
not by assertion:

| r103 finding | r103 verdict | r104, re-measured by this seat |
|---|---|---|
| row A receipts falsified (`10 OK / FAILED=2`) | REVISE | **fixed** — the landed file states `MANIFEST_OK=11 FAILED=1`, which is what I measure [O] |
| row B not executable as written (dot-less `jq` exits 3; no cwd named) | REVISE | **fixed** — the cell now writes `jq -e .` **and** names the ruleset (`default` → 0, `-o all` → 1 / 31 findings) [O] |
| row C's F7 qualifier owed | PASS + qualifier | **fixed** — the F7 clause is now inside row B's `permissible label` cell [O] |
| row D `verified-here` is two vocabularies | REVISE | **fixed** — the disambiguation is in-cell [O] |
| §3.1 `unreal-r22` had no row ("exhaustive" was false) | holds | **fixed** — a fifth row **E** exists and its accept+reject controls both reproduce [O] |
| §4.1 all ten `run_gate.sh:NN` citations invalid | holds | **fixed** — `grep -cE 'run_gate\.sh:[0-9]' SKILL.md` → **0**; the file cites `CHECK n <name>` + sha [O] |
| §4.2 three artifact-index hashes stale | holds | **fixed** — all seven §6 stamps I re-hashed match live, including both gate rows [O] |

**But the landed table carries two new defects of its own, and one residual class it did not close.**

1. **Row B's `bash -n` command is not runnable from the cwd the table names.** The cell writes
   ``bash -n upstream/hooks/unreal-context.sh` → rc 0``, but the column header says *"run from the
   lane repo root"*, and from there it exits **127** (`No such file or directory`). Every other row-B
   command carries the `(cd corpus/knowledge/unreal-mcp && …)` prefix; this one does not. It is the
   *same defect* r103 filed against row B, surviving in the one command the repair did not touch.
   → **REVISE (one mechanical edit).**
2. **Five of the table's twenty-seven path references do not resolve from the lane root.**
   `adaptation-kimi.md`, `gate/run_gate.sh`, `audit-reference.sha256`, `r101-critic-c3.md`,
   `r101-mutation-tester.md` are written as bare names. Three of the five do not resolve from the
   subtree either. The gate's CHECK 4 cannot see this because `SKILL.md` is **outside its sweep
   root** — so a green gate is not evidence here.
3. **The gate flake is real and the landed gate reduced but did not eliminate it.** The r104 workdir
   hardening (`GATE_WORKDIR`/`TMPDIR` → `WORK_ROOT`) is a genuine fix — `FAIL` on a clean tree fell
   from **20/30 to 0/40** — but a *different* scratch write inside CHECK 2 still converts a disk
   failure into a verdict-shaped `STEP=FAIL`, and CHECK 2 still prints `BLOCKED (network)` when the
   cause was local. Both are quantified in §5.

**Fold decision: land the table.** Five executable rows, correct citation discipline, in-cell
qualifiers, no gate line numbers, stamps that match. The two defects above are mechanical edits to
row B and to five path spellings; neither touches a row's claim or its evidence. Nothing in this
review falsifies any of the five rows.

---

## 1. What moved during this review — the gate took three identities

Measured by this seat, not quoted. `[O]`

| gate identity | lines | when | how I obtained it |
|---|---|---|---|
| `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` | 347 | HEAD (`git show HEAD:…`) and the live file at review start | ran the full control matrix against it |
| `b6d8c61afa94bfde862fc95f2fdd95e87d4632ec46358ade0634385bfc79a59d` | 433 | appeared mid-run; snapshotted to `/var/tmp/r104s19-gate-snapshot.sh` | the workdir fix (`WORK_ROOT`) landed here |
| **`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`** | 433 | current at review write; **is** `SKILL.md` §6's stamp | the in-memory `$C2_LOG` capture landed here |

```
$ sha256sum SKILL.md corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903  SKILL.md
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08  corpus/knowledge/unreal-mcp/gate/run_gate.sh
e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf  corpus/knowledge/unreal-mcp/gate/README.md
$ git status --porcelain | head
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? .r104-seat17/
?? SKILL.md
?? reports/round-104/
```

`SKILL.md` §6 says the script *"took ≥5 identities during r104"*. I can witness **three** first-hand
(`577c8b54`, `b6d8c61a`, `e5521304`); the other two are claimed in other seats' reports and are
**[C]**, not measured here. The §6 stamps for **both** gate rows match the live files exactly, which
is the property that matters — and the file marks them **worktree, uncommitted**, which is true.

**Consequence for every verdict below:** a verdict is only meaningful against a named hash. The
per-row verdicts in §2 are against the gate as it stood when that row's command ran; where the gate
was involved I re-ran it at the final `e5521304` and say so.

---

## 2. Per-row verdicts — every cited command re-run

Legend: **EXECUTABLE** = I ran the command and it produced the output the table claims, from the cwd
the table names. **NOT** = it did not.

### Row A — file byte-identity → **EXECUTABLE** (r103's falsification is fixed)

```
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)
… 12 lines, all `: OK` …
RC=0
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK')
12
```

The second command the row's evidence column requires — path-set equality both ways against a
**fresh** clone — re-derived by this seat without the gate:

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /var/tmp/r104s19-ref
$ git -C /var/tmp/r104s19-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ diff <(cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort) \
       <(cd /var/tmp/r104s19-ref && git ls-files | sed 's|^|./|' | sort) ; echo "pathset rc=$?"
pathset rc=0
$ # per-blob compare, 12 files
BLOBCOMPARE files=12 diffs=0
```

**The +NC reproduces at 11/1, not 10/2 — and the landed table says 11/1.**

```
$ cp -r corpus/knowledge/unreal-mcp /var/tmp/r104s19-ncA2 && printf '\n' >> /var/tmp/r104s19-ncA2/upstream/README.md
$ (cd /var/tmp/r104s19-ncA2 && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')
11
$ (cd /var/tmp/r104s19-ncA2 && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep 'FAILED')
upstream/README.md: FAILED
$ awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 | sort | uniq -d | wc -l
0
```

Zero duplicate manifest rows, so no second file can flip. r103's finding stands and the landed text
now agrees with it: `SKILL.md` states `MANIFEST_OK=11 FAILED=1`, and
`grep -c 'another manifest row' SKILL.md` → `0` — the false sentence is gone.

**Row A verdict: EXECUTABLE.** Both canonical commands, both evidence halves, and the control all
reproduce. r103's `[F]` is closed.

### Row B — static parse → **NOT** (one command in the cell is unrunnable as written)

Four of the five command groups reproduce exactly as printed:

```
$ (cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo rc=$?)
rc=0
$ (cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo "dotless rc=$?")
dotless rc=3                     # the cell's "the `.` filter is load-bearing" is correct
$ (cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo rc=$?)
rc=0                             # default ruleset, as the cell states
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo rc=$?)
rc=1
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -c '^In ')
31                               # the cell's "31 findings" is exact
```

**The fifth does not.** The cell's canonical-command group is, verbatim and in order:

```
`(cd corpus/knowledge/unreal-mcp && jq -e . …)` → rc 0 …
`(cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh)` → rc 0 under the **default** ruleset …
`bash -n upstream/hooks/unreal-context.sh` → rc 0.
```

The third command carries **no `cd` prefix**, while the column header reads *"canonical command (run
from the lane repo root)"*. Run it there, as the header instructs:

```
$ bash -n upstream/hooks/unreal-context.sh ; echo "rc=$?"
bash: upstream/hooks/unreal-context.sh: No such file or directory
rc=127
$ (cd corpus/knowledge/unreal-mcp && bash -n upstream/hooks/unreal-context.sh ; echo "rc=$?")
rc=0                             # only with the subtree as cwd
$ bash -n corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh ; echo "rc=$?"
rc=0                             # or with the full path from the root
```

This is precisely the r103 §2 row-B defect (*"`shellcheck` is cwd-ambiguous: the cell names no
cwd"*) — repaired for `jq` and `shellcheck`, **not** for `bash -n`, which was added in the same
edit. The table's own §2 error-pattern row `implicit-cwd command` names this class and prescribes the
fix: *"prefix the command with its cwd, or point at the gate"*.

Also re-tested, and **closed**: r103 §3.2's claim that §6's *"every canonical command in §1 was run
by this seat"* was false for row B. §6 now says the outputs are pasted in
`reports/round-104/skill/author.md` §2, that file exists, and its row-B block contains the same
commands and the same rcs I measured (`rc=0`, `rc=3`, `rc=0`, `rc=1`, 31 findings) [C].

**Row B verdict: NOT — REVISE.** One edit: add the `(cd corpus/knowledge/unreal-mcp && …)` prefix,
or full-path the argument. The row's *claims* are all correct; only its runnability is at fault.

### Row C — runtime behavior → **EXECUTABLE** (the F7 qualifier has landed in-cell)

```
$ which UnrealEditor UnrealEditor-Cmd >/dev/null 2>&1; echo rc=$?
rc=2
$ ls /opt/UnrealEngine >/dev/null 2>&1; echo rc=$?
rc=2
$ git ls-remote https://github.com/EpicGames/unreal-engine HEAD >/dev/null 2>&1; echo rc=$?
rc=128
```

The F7 witness still reads 6, and the subtree `README.md` hash is still `c79d8dd1…`, so the P/C
collision is **exactly as live as it was**:

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

r103's required clause — *"a row-C label is `unproven-runtime` until the F7 precedence ruling lands,
and a claim on one of the six dissenting subsystems must cite the card it contradicts"* — is now
**inside row B's `permissible label` cell**, and §4 restates it while correctly declining to resolve
it. The six cards are enumerated in §3's checklist, which is a real improvement: a consumer copying a
row no longer has to read §4 to know the rule.

**Row C verdict: EXECUTABLE.** Every command reproduces; the qualifier is present and correctly
placed. The P/C ruling remains owed (§4) and the table says so rather than papering over it.

### Row D — Kimi-side adaptation → **EXECUTABLE** (the two-sense disambiguation is in-cell)

```
$ /home/vgpnk/.kimi-code/bin/kimi --version
2.2.0
$ file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID\[sha1\]=[0-9a-f]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c additionalContext
0                                # pipeline rc 1; the table writes this as the row-D negative claim
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c CLAUDE_PLUGIN_ROOT
0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c enabledPlugins
0
```

The BuildID in the cell matches the live binary, so the row's stated validity condition is currently
satisfied — and the row says a CLI upgrade invalidates it, which is the right shape.

r103 §2 row D's finding was that `verified-here` means two different things in the two vocabularies.
The landed row carries the required in-cell disambiguation:

```
row-probe sense:  "reproduced by a command run on this host, output pasted in the row"
card sense:       "a bounded run of the subsystem happened here with a saved receipt"
— and: "A row-D `verified-here` says nothing about any Unreal subsystem."
```

That is the finding closed. Note the r103 concern about the *source* file: `adaptation-kimi.md` is
still `084a34cd…` (506 lines), so the citations into it resolve to the same content they did at
r103. §6 stamps it correctly.

**Row D verdict: EXECUTABLE.** Commands reproduce, disambiguation present, BuildID condition stated.

### Row E — lane-authored static descriptor → **EXECUTABLE** (the r103 §3.1 gap is closed)

r103's review found the draft's claim that four rows were *"exhaustive over the Unreal artifacts in
this lane"* to be **false**, because `corpus/artifacts/unreal-r22/` had no row. The landed table adds
row E, and both its halves reproduce:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py ; echo rc=$?
PASS local-static actual=accept expected=accept path=…/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject ; echo rc=$?
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
rc=0
```

The reject control is a genuine non-vacuity control: it makes the checker report `reject` where the
first reports `accept`, so the checker is shown able to say no. The row's label — `static-only`,
*never* `verified-here*, *"never a statement about Unreal accepting it: the checker is the lane's"* —
is exactly right for a lane-authored artifact, and the row states what its evidence does not reach.

**Row E verdict: EXECUTABLE.** Both commands, including the paired reject control, reproduce.

---

## 3. Citation discipline — the rule the table writes, measured against the table

The table's own §1 states: *"Cite a mutable artifact by section heading plus a sha256 stamp, not by
bare line number … **No gate line number is carried into this file.**"* Tested:

```
$ grep -cE 'run_gate\.sh:[0-9]' SKILL.md
0
```

**The rule is honoured.** This is the r103 §4.1 finding — all ten of the draft's gate line numbers had
moved — closed by removing the citation form entirely rather than by re-numbering. That is the right
fix: re-numbering would have rotted again within the same round, as the three identities above show.

**The §6 artifact index re-hashed against live, all seven rows:**

| artifact | §6 stamp | live | verdict |
|---|---|---|---|
| `gate/run_gate.sh` | `e5521304…` | `e5521304…` | **match** (marked worktree) |
| `gate/README.md` | `e3bc66b7…` | `e3bc66b7…` | **match** (marked worktree) |
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1…` | `c79d8dd1…` | match |
| `PROVENANCE.md` | `36938c71…` | `36938c71…` | match |
| `adaptation-kimi.md` | `084a34cd…` | `084a34cd…` | match |
| `corpus/lessons/r102-unreal-integration.md` | `cf237b88…` | `cf237b88…` | match |
| `corpus/knowledge/engines.md` | `d03907d3…` | `d03907d3…` | match |
| `skill-decision-table-draft.md` / `round-103/skill-table-review.md` | `fa360bde…` / `95d40d92…` | same | match |

r103 §4.2's finding — *"the gate row is the worst: one hash for a script and a README that no longer
share a value"* — is fixed: two files, two stamps, and both are current. The stale-hash class is
**closed by measurement**.

**The residual: five path references do not resolve from the lane root.** Resolving every
backtick-wrapped repo-relative path in the file:

```
$ for p in $(grep -oE '`[A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt|uplugin)`' SKILL.md | tr -d '`' | sort -u); do
    [ -e "$p" ] || echo "MISSING $p"; done
MISSING adaptation-kimi.md
MISSING audit-reference.sha256
MISSING gate/run_gate.sh
MISSING r101-critic-c3.md
MISSING r101-mutation-tester.md
paths=27 missing=5
```

These are *subtree-relative* names used as if they were repo-relative. Two of the five
(`adaptation-kimi.md`, `gate/run_gate.sh`) do resolve from `corpus/knowledge/unreal-mcp/`, because
the table's prose is written from inside the subtree's frame; the other three do not resolve from
either root:

```
$ for p in adaptation-kimi.md gate/run_gate.sh audit-reference.sha256 r101-critic-c3.md r101-mutation-tester.md; do
    [ -e "corpus/knowledge/unreal-mcp/$p" ] && echo "subtree-relative OK: $p" || echo "subtree-relative MISSING: $p"; done
subtree-relative OK: adaptation-kimi.md
subtree-relative OK: gate/run_gate.sh
subtree-relative MISSING: audit-reference.sha256
subtree-relative MISSING: r101-critic-c3.md
subtree-relative MISSING: r101-mutation-tester.md
```

`audit-reference.sha256` lives at `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256`;
the two r101 files live under `reports/round-101/`. This is the table's own
`implicit-cwd command` error pattern, and it is the same defect as the row-B `bash -n`: the file
mixes two frames of reference without saying which is in force. Note it is **not** a gate failure —
the gate is green — because `SKILL.md` sits at the lane root and CHECK 4's sweep root is
`corpus/knowledge/unreal-mcp/`:

```
$ find corpus/knowledge/unreal-mcp -name 'SKILL.md' | head
corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md
corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
```

The lane's own `SKILL.md` is not among them. **The gate cannot check this file at all**, which is
worth recording: the artifact that carries the decision table is outside the sweep that would
validate its pointers, and the r104 gate work did not extend it. A `PASS` on the gate is therefore
not evidence about the table's pointers — the table's own `green-gate-overread` error pattern,
applied to the table itself.

---

## 4. Non-vacuity — the control matrix, re-run end to end

Every control was run on a **relocated repo root** (`/var/tmp/r104s19-h/<case>`) with the subtree
real-copied and the rest of `corpus/`/`reports/` symlinked, so CHECK 4's pass B resolves
repo-relative paths exactly as it does in the lane — the arrangement the gate's own README requires.
The unmutated copy is the harness control.

**Harness control (C0) — unmodified relocated copy, gate `577c8b54`:**

```
GATE RC=0
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

**The eight documented controls plus the four r103 A-controls, gate `577c8b54` (`GATE_WORKDIR` on a
real disk so CHECK 2 scores rather than blocks):**

| control | mutation | rc | observed signal | intended check |
|---|---|---|---|---|
| **C1** | append a byte to `upstream/README.md` | 1 | `MANIFEST_OK=11 … FAILED=1`; `BLOB_DIFFS=1` | 1 + 2 ✔ |
| **C2** | delete `upstream/LICENSE` | 1 | `MANIFEST_OK=11 … FAILED=0 RC=1`; `PATH_MISSING=1`; `BLOB_DIFFS=1` | 1 + 2 ✔ |
| **C3** | plant `upstream/README.md:200` | 1 | `LINE-OOR … (max 112)`; `UNRESOLVED=1` | 4 only ✔ |
| **C4** | duplicate a label token | 1 | `FAIL multi-label`; `BAD=1`; census `11/1/0` | 3 only ✔ |
| **C5** | relabel a card `unproven-runtime` | 1 | census `11/2/0` vs `12/1/0` | 3 only ✔ |
| **C6** | remove `executability/sequencer.md` | 1 | `CARDS=12 EXPECTED=13`; `card-name-missing`; `NAME_BAD=1` | 3 (+4: its pointers went unresolved) ✔ |
| **C7** | plant **only** the exact sentinels, one per line | **0** | `SKIPPED_CONTROL_SENTINELS=2`, `UNRESOLVED=0` | filter's positive control ✔ |
| **A1a** | plant `upstream/README.md:1-9999` | 1 | `LINE-OOR … (max 112)` — the **range tail** is validated | 4 ✔ |
| **A1c** | plant a *valid* `upstream/README.md:39,45` | **0** | `UNRESOLVED=0` — the range form is not simply rejected | 4 ✔ |
| **A2a** | prose line naming a token **above** the declaration | **0** | `BAD=0` — the hijack no longer satisfies the rule | 3 ✔ |
| **A2b** | anchored line with two tokens | 1 | `FAIL multi-label` | 3 ✔ |
| **A2c** | declaration removed, prose only | 1 | `FAIL no-label` | 3 ✔ |
| **A3** | rename `sequencer.md` → `sequence-typo.md` | 1 | `card-name-missing` + `card-name-extra`; `NAME_BAD=2` | 3 ✔ |
| **A4b** | valid `GATE_REF`, no clone attempted | 0 | `GATE_REF=… (offline reference)`; `BLOB_DIFFS=0` | 2 ✔ |

**Every control moved its intended check and no other.** C7 is the important one for the table's
argument: it proves the sentinel filter is an **exact-match** rule, so `SKIPPED_CONTROL_SENTINELS`
cannot silently eat a real pointer.

**Two r103 controls did NOT reproduce as r103 documented, and one of them was my error first.**

- **A4a (`REPO=<unreachable>`, no `GATE_REF`) → I got `rc=0`, r103 documented `rc=2`.** My first
  attempt was wrong in a way worth recording, because it is the trap the gate's own README warns
  about: `run_gate.sh` sets `REPO=<url>` at line 32 with **no** `${REPO:-…}` default, so an exported
  `REPO` cannot override it. My `export REPO=…` did nothing, the real clone succeeded, and CHECK 2
  passed. The documented way to reach the BLOCKED branch is `GATE_REF`-less **plus** a clone that
  actually fails. I reached that branch through the *real* failure mode instead (§5) — the disk — and
  the gate did print `STEP=BLOCKED` and exit 2. So the A4 contract holds; r103's reproduction recipe
  is what is fragile, and `gate/README.md` documents the override in prose that the script does not
  implement.
- **C7 with both sentinels on one line → `UNRESOLVED=1`, `rc=1`.** The sweep's regex takes the first
  pointer string it finds and the rest of the line as its line-number tail
  (`MISSING-PATH … :: upstream/nope.md:1 and upstream/README.md:9999`). One sentinel per line, as the
  gate's own README writes them, gives `SKIPPED_CONTROL_SENTINELS=2` and `rc=0`. This is a
  *harness* detail, not a defect: the sentinel filter is line-anchored by construction, and the
  README's worked example is the one-sentinel-per-line form.

**Both of those are recorded as measured, not as defects in the table.** Neither touches a row.

---

## 5. The flake — C2's subject, measured, and what the landed fix does and does not close

The r103 root cause was that `/tmp` is a 16G tmpfs near quota, so gate scratch writes fail. Measured
here at review start:

```
$ df -h /tmp ; df -i /tmp
tmpfs  16G  13G  3.1G  80% /tmp
tmpfs  1048576 inodes, 64% used
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r104s19-clonetest
fatal: write error: Disk quota exceeded
fatal: fetch-pack: invalid index-pack output
clone_rc=128
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD ; echo rc=$?
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
rc=0
```

The network is **fine** (`ls-remote` rc 0) while a clone into `/tmp` fails. So on this host the
pre-r104 gate's `BLOCKED (network)` diagnosis was simply wrong — and worse, its `FAIL per-seat
manifest sweep` was a verdict-shaped red on a clean tree.

**Old gate (`577c8b54`), identical clean tree, 30 consecutive runs:**

| scratch root | PASS | BLOCKED | **FAIL** |
|---|---|---|---|
| inherited `/tmp` (default) | 9 | 1 | **20** |
| `TMPDIR=/var/tmp` | 28 | 2 | 0 |

Each of the 20 FAILs is a **spurious** red: the same run prints `MANIFEST_OK=12 EXPECTED=12 FAILED=0
RC=0 / STEP=PASS`, and then:

```
FAIL per-seat manifest sweep (--strict) failed:
CHECK 1 manifest-byte-identity
… all 12 `: OK` …
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
…
GATE RESULT: FAIL (checks failed: 1)
```

The cause is not `mktemp` failing — `mktemp` succeeds. The **write** to the tmpfs-backed file fails,
so `sha256sum >"$MANLOG"` produces nothing, the `if !` is satisfied, and the gate prints `FAIL` with
an empty reason block. That is the r103 E1 class exactly (`"a spurious fail-closed on a green tree,
which trains a reader to ignore the gate's red"`), reached by a different route.

**New gate (`e5521304`), same tree, same conditions:**

| scratch root | PASS | BLOCKED | **FAIL** |
|---|---|---|---|
| inherited `/tmp` (default) | 35 | 5 | **0** |
| `GATE_WORKDIR=/var/tmp/…` | 28 | 2 | 0 |

The `FAIL` count goes **20/30 → 0/40**. That is the fix working: `mktemp -p "$WORK_ROOT"` is checked
and its failure is loud and named (`FAIL cannot create scratch file under …`), so the empty-reason
`FAIL per-seat manifest sweep` no longer occurs — I measured **0** of them in 40 runs, against 17 in
an earlier 40-run sample of the intermediate `b6d8c61a` build.

**But a residual of the same class survives, and it is a verdict-shaped red.** Captured at run 7 of
40 on the default root, gate `e5521304`:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ; echo rc=$?
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
MANIFEST_FILES=12
CHECK 1 manifest-byte-identity
… all 12 `: OK` …
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
fatal: sha1 file '/tmp/tmp.4Q6pFodmqA/clone/.git/index.lock' write error: Disk quota exceeded
sort: fflush failed: 'standard output': Disk quota exceeded
sort: write error
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=0
FAIL tracked count 0 != 12
sort: fflush failed: 'standard output': Disk quota exceeded
sort: write error
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=FAIL
…
GATE RESULT: FAIL (checks failed: 1)
rc=1
```

Read that as a reader would: `STEP=FAIL`, `rc=1`, `FAIL tracked count 0 != 12` — *"the vendored bytes
diverge."* The truth is that `git clone` could not write its index, `git ls-files` returned nothing,
and **nothing was compared at all**. The gate's own A4 comment states the contract this violates:
*"a reader of `GATE RESULT: FAIL` could not tell 'this host had no network' from 'the vendored bytes
diverge'"* — the r104 work classified the *clone-failure* path, but this failure lands **after** a
successful clone, so it falls through to the verdict branch rather than the BLOCKED branch. The same
root also produced `BLOCKED (network)` with a disk error printed under it (5 such runs in 40), which
the in-memory `$C2_LOG` capture now surfaces but does not reclassify.

This is **not** a defect in the decision table, and it does not touch any row. It is the C2 subject
reported as measured: the workdir resilience work is real and large (20/30 → 0/40), the loud-mktemp
failure is real, and one verdict-shaped red remains reachable from the default scratch root.

---

## 6. Fold decision and required edits

**Land the table.** Against the landed `SKILL.md` (`de8ada36`):

| row | verdict | evidence |
|---|---|---|
| **A** — file byte-identity | **EXECUTABLE** | 12 OK rc 0; pathset+blob vs fresh clone both clean; NC 11/1 as stated |
| **B** — static parse | **NOT** | 4/5 command groups reproduce; `bash -n` exits **127** from the named cwd |
| **C** — runtime behavior | **EXECUTABLE** | rc 2 / rc 2 / rc 128; F7 count 6; qualifier now in-cell |
| **D** — Kimi-side adaptation | **EXECUTABLE** | 2.2.0; BuildID matches; three `grep -c` zeros; disambiguation in-cell |
| **E** — lane-authored descriptor | **EXECUTABLE** | accept rc 0 **and** reject rc 0 |

**Two mechanical edits, neither of which changes a claim or an evidence requirement:**

1. **Row B, `bash -n`:** add the `(cd corpus/knowledge/unreal-mcp && …)` prefix that every other
   command in the cell already carries. (Or full-path the argument.) As landed it reproduces
   `rc 127`, not the `rc 0` the cell prints — the table's own
   `command-does-not-reproduce-its-printed-rc` error pattern.
2. **§1 prose and §6 index, five bare names:** `adaptation-kimi.md` and `gate/run_gate.sh` are
   subtree-relative; `audit-reference.sha256` needs `.manifest.d/`; `r101-critic-c3.md` and
   `r101-mutation-tester.md` need `reports/round-101/`. State the frame once (`paths are relative to
   the lane repo root unless the row says otherwise`) or full-path them.

**Two things this review does not close, stated so they are not read as closed:**

- **The P/C precedence ruling is still owed** (§4 of `SKILL.md` says so itself). The subtree
  `README.md` is still `c79d8dd1…` and the six cards still dissent. No command in this review can
  settle it — it is a ruling, not a measurement.
- **Box 1 is not closed by this review.** `SHONEN.md` box 1 needs a *named non-author verifier*, and
  §6 of `SKILL.md` correctly says the author cannot be it. I am a non-author and I have verified the
  five rows — but box 1 is a promotion gate on the *lane*, and whether a per-row re-run of the kind
  recorded here satisfies it is a decision for the round's adjudicator, not for this seat. What I can
  state is what I measured: five rows, every cited command re-run, two mechanical defects, and the
  citation discipline intact.

**No Unreal runtime claim is made anywhere in this file**, and none is implied by any row of the
table: row C is the row that exists to prevent one, and it reproduces on a host where
`which UnrealEditor` exits 2.

---

## 7. Provenance

- **Every command quoted above was run by this seat on 2026-10-18**, from the lane root unless the
  command says otherwise, and its output is pasted verbatim. Nothing is cited from another seat's
  transcript except where marked **[C]**.
- **This seat wrote exactly one file:** `reports/round-104/skill/review.md`. No file under `corpus/`
  was written or modified; the pinned subtree `corpus/knowledge/unreal-mcp/` (its `upstream/` and
  `.manifest.d/`) was read only. All mutations were applied to copies under `/var/tmp/`.
- **Concurrency, recorded.** The gate took three identities during this review (`577c8b54` →
  `b6d8c61a` → `e5521304`) and `SKILL.md` landed mid-review at 16:25Z. I reviewed the landed file,
  not the draft, once it appeared; the draft is reviewed only where the landed file descends from it.
  Verdicts name the hash they were measured against. `gate/README.md` also moved
  (`834f468d` → `e3bc66b7`) and its §6 stamp is current.
- **Reproduce:**

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum SKILL.md corpus/knowledge/unreal-mcp/gate/run_gate.sh   # de8ada36… / e5521304…
grep -cE 'run_gate\.sh:[0-9]' SKILL.md                            # 0
bash -n upstream/hooks/unreal-context.sh; echo rc=$?              # 127  <- the row-B defect
(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json); echo rc=$?   # 0
(cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh); echo rc=$?                     # 1
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo rc=$?                                                   # 0
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo rc=$?  # 0
for p in $(grep -oE '`[A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt|uplugin)`' SKILL.md | tr -d '`' | sort -u); do [ -e "$p" ] || echo "MISSING $p"; done  # 5 lines
```
