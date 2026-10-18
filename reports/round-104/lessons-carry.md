# r104 · SEAT-46 LESSONS-CARRY — does r101–r103 warrant a new `corpus/lessons/` entry?

**Seat:** SEAT-46 LESSONS-CARRY · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-104/lessons-carry.md` (this file) plus three evidence
artifacts under `reports/round-104/lessons-carry-loop/` and
`reports/round-104/lessons-carry-gate-default-tmpdir.out`. **No `corpus/` file was written** —
`corpus/lessons/**` is not this seat's to edit, and the seat brief says *propose, do not write*.
**Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`)
**Date:** 2026-10-18 · probe window `19:16Z–19:25Z`.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed
on this host (`which UnrealEditor` → rc 2, re-run in r104 by `reports/round-104/skill/author.md` §2).
Everything below is a filesystem, byte, git, or static-parse operation.

Tags: **[O]** command run by this seat, output quoted · **[C]** cross-referenced to another r104
seat's independent report · **[P]** proposal, not landed.

---

## 0. Verdict

**Yes — the r102–r103 LOG LAWS warrant a new `corpus/lessons/` distillation entry, and the case is
stronger than "the LAWS are un-distilled".** (r101 is the exception: its laws are already distilled
into the r102 lesson's Laws 1–4, measured in §2 — the r105 entry does not re-distil r101.)

The stronger fact, measured this session: **the one lesson that does cover this material has already
rotted, in four places, inside one round.** `corpus/lessons/r102-unreal-integration.md` is the only
lesson file for r101–r103, and it now

1. **violates the very LAW it is the record of** — it pins a bare `POINTERS=40` twice (r102 LAW:
   *"never cite a bare POINTERS number without its scanner"*), while the installed gate prints `101`;
2. **cites a line that no longer says what it claims** — `gate/README.md:40` is now a sentence about
   exit 2, not "pins both counts";
3. **tells the reader to prefer two `/tmp` scripts that no longer exist**;
4. **states a false mechanism** — *"Two of its four checks compare against a fresh clone at the pin,
   so it needs network"*; only CHECK 2 clones, and since r103 it can run offline via `GATE_REF`.

That is not a defect in the r102 lesson — it was correct when written, and it says so
(*"re-measure rather than trusting either revision"*). It is the **class** the r103 LAWS name:
*a bare line-number citation rots*, and *a pinned count is a measurement, not a contract*. The
lesson corpus has no entry that carries that class forward, so every future reader re-learns it by
being burned.

**Proposed for r105 [P]:** one distillation entry, `corpus/lessons/r105-measurement-discipline.md`,
carrying the r102–r103 LAWS (and the r101 laws that are still only instance-cited) as falsifiable
laws with their source pointers. Full outline in §6. **Not written this round** — outline only.

---

## 1. What the lesson corpus actually looks like

```
$ ls corpus/lessons/*.md | wc -l
91
$ ls corpus/lessons/ | sed 's|.*/r||; s|-.*||' | sort -n | uniq | tr '\n' ' '
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 70 71 72 73 74 75 76 77 78 79 102
```

Two facts fall out of that list **[O]**:

- **The corpus stops at r79.** After r79 the only lesson files are round-scoped *reviews*
  (`r7-camera-review.md` … `r79-bpy-two-layer-model.md`), and the highest round with a lesson of any
  kind is **102**. Rounds **80–101 and 103 have zero** lesson entries:

```
$ for r in 80 81 82 83 84 85 86 87 88 89 92 93 94 95 96 97 98 99 100 101 102 103; do
    printf 'r%-4s lessons=%s\n' "$r" "$(ls corpus/lessons/ | grep -cE "^r${r}(-|\.)")"; done
r80  lessons=0
r81  lessons=0
...
r101 lessons=0
r102 lessons=1
r103 lessons=0
```

- **`r102-unreal-integration.md` is the whole of the r101–r103 distillation surface**: 217 lines,
  sha256 `cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2`, sectioned
  `## Law 1..4` (`:17`, `:43`, `:67`, `:95`), `## Two counting traps` (`:118`),
  `## Re-running the gate` (`:136`), `## Next-iteration hooks` (`:168`) **[O]**.

There is **no `corpus/lessons/README*` and no `corpus/QUALITY.md`** — the corpus is discovered by
directory listing, not by a maintained index (`ls corpus/lessons/README*` → rc 2;
`ls corpus/QUALITY.md` → rc 2) **[O]**. So a new lesson is found by `ls`, which is why the *name*
matters (§6.1).

---

## 2. The r101–r103 LAWS, and whether any lesson carries them

The three blocks, verbatim line ranges at HEAD **[O]**:

| round | LAWS block | lines |
|---|---|---|
| r101 | scope = all files tracked at the pin; install-wall classes; binary proven/unproven policy | `LOG.md:1309-1315` |
| r102 | scanner-relative pointer counts; "fixed" vs "fixed and documented"; a gate is only as strong as its attack suite; pinned-env markers are host-version receipts | `LOG.md:1341-1348` |
| r103 | a bare line-number citation rots; attack seats racing an author read stale intermediates; serial-child arms scale by boot floor; `/tmp` is a shared 16G tmpfs near quota | `LOG.md:1376-1384` |

Keyword sweep over the whole lesson corpus, one command per LAW **[O]**:

```
$ for k in "scanner-relative" "SCANNER-RELATIVE" "attack suite" "stale intermediate" \
           "target's hash" "boot floor" "tmpfs" "host-version" "line-number citation" \
           "fixed and documented" "INTRINSIC_WALL_COST" "BLOCKED"; do
    printf '%-24s files=%s\n' "$k" "$(grep -rlF -- "$k" corpus/lessons/ | wc -l)"; done
scanner-relative         files=0
SCANNER-RELATIVE         files=0
attack suite             files=0
stale intermediate       files=0
target's hash            files=0
boot floor               files=0
tmpfs                    files=0
host-version             files=0
line-number citation     files=0
fixed and documented     files=1        ← corpus/lessons/r102-unreal-integration.md
INTRINSIC_WALL_COST      files=0
BLOCKED                  files=0
```

**11 of 12 keywords appear in zero lesson files.** The twelfth (`fixed and documented`) appears
exactly once — inside the r102 lesson's *own* counting trap, where it is a self-referential citation,
not a carried law. r102's LAWS are therefore **cited by** its lesson but never **distilled into** the
corpus as transferable rules.

**Correction, measured after the first draft of this section (kept as a worked instance of proposed
Law 4).** The sentence above originally continued *"and r101's install-wall classification has no
lesson presence at all"*. That is **false**, and a targeted re-sweep caught it:

```
$ for k in "install wall" "at the pin" "unproven-runtime" "proven" "Epic-account"; do
    printf '%-20s files=%s  %s\n' "$k" "$(grep -rlF -- "$k" corpus/lessons/ | wc -l)" \
      "$(grep -rlF -- "$k" corpus/lessons/ | tr '\n' ' ')"; done
install wall         files=1  corpus/lessons/r102-unreal-integration.md
at the pin           files=1  corpus/lessons/r102-unreal-integration.md
unproven-runtime     files=1  corpus/lessons/r102-unreal-integration.md
proven               files=12 <12 files>
Epic-account         files=0
```

**r101's LAWS *are* distilled** — into `r102-unreal-integration.md` Laws 1–4, whose headings read
*"vendoring is scoped to the pin"*, *"the evidence policy is binary: `proven` or `unproven`"*,
*"the card label ternary is finer than the policy"*, and *"install walls come in classes"*
(`:17`, `:43`, `:67`, `:95`) **[O]**. So the accurate statement is narrower and it is the one §0
already makes: **r101 is distilled (by its own round's lesson); r102's and r103's LAWS are not** —
r102's are cited-but-not-carried, r103's have no lesson presence at all. The r105 entry's scope is
correspondingly Laws 1–9 in §6.2, **not** a re-distillation of r101.

This is a small instance of the class the entry is about: the first draft's claim was true for the
keywords swept and false for the question asked, and only a second sweep — with the right keywords —
falsified it. An unrun check is not a passed check; a run check with the wrong terms is not a check
either.

Two of r103's LAWS were also **still open as routed items** when this seat ran (`LOG.md:1385-1392`:
physics fix, gate workdir resilience, flake harness, fixture write-isolation) — and this seat
reproduced one of them live (§4), which is the second reason the r105 entry is warranted now rather
than later: the evidence is fresh.

---

## 3. The decisive new fact — the r102 lesson has rotted in four places

This is the finding that converts "un-distilled" (a coverage gap) into "actively misleading"
(a calibration defect). Every rotted claim is re-derived below.

### 3.1 It pins a bare `POINTERS` — the exact thing the r102 LAW forbids

```
$ grep -c 'POINTERS=40' corpus/lessons/r102-unreal-integration.md
2
$ sed -n '148p;153p' corpus/lessons/r102-unreal-integration.md
  `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `STEP=PASS`, check 3
  `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`;
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

`LOG.md:1341-1343` reads: *"pointer counts are SCANNER-RELATIVE — three scanners read 40/41/43 on the
same tree; never cite a bare POINTERS number without its scanner."* The lesson that the LAW cites as
its source does exactly that, twice. The count has since gone `40 → 87 → 88 → 90 → 98 → 101` as the
scanner and the prose changed; the *binding invariant* `UNRESOLVED=0` held at every frame this seat
measured, including the failing ones (§4) **[O]**.

### 3.2 A cited line that no longer says what the lesson claims

```
$ sed -n '127,129p' corpus/lessons/r102-unreal-integration.md
  (`reports/round-101/r101-critic-c3.md:365` F8, the finding; `gate/README.md:40`
  pins both counts). A later seat edited this block to state both counts
$ sed -n '40p' corpus/knowledge/unreal-mcp/gate/README.md
> state with exit **2**, not a folded FAIL. The scanner sha256 is now `577c8b54…`; the expected
```

`gate/README.md:40` is now a sentence about the BLOCKED exit state. The lesson's claim about that
line is false, and a reader who follows it lands in the r103 hardening prose **[O]**.

### 3.3 It sends the reader to scripts that no longer exist

```
$ sed -n '151,155p' corpus/lessons/r102-unreal-integration.md
- The same checks run standalone:
  `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` →
  `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`;
  `bash /tmp/r101-closeout/label-scan.sh corpus/knowledge/unreal-mcp/executability 13`
  → `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`.
$ ls /tmp/r101-closeout/
ls: cannot access '/tmp/r101-closeout/': No such file or directory
```

The lesson does warn *"The `/tmp` copies were the r101 stopgap and are not part of the tree"* — the
warning is right and the commands are dead. This is the r102 counting trap *("a documented sweep
command must produce the lines it prints")* caught happening to the document itself **[O]**.

### 3.4 A false mechanism, and it is the one a reader most needs

```
$ sed -n '176,179p' corpus/lessons/r102-unreal-integration.md
   lives at `corpus/knowledge/unreal-mcp/gate/run_gate.sh` and is green on the
   current bytes (`GATE RESULT: PASS`, exit 0). Two of its four checks compare
   against a *fresh* clone at the pin, so it needs network; run it before and
   after any edit to prove the byte-pinned `upstream/` and `.manifest.d/` were
   not perturbed.
$ grep -n 'git clone' corpus/knowledge/unreal-mcp/gate/run_gate.sh
43:# under pressure `git clone` fails with `error: copy-fd: write returned: Disk
214:      printf 'FAIL GATE_REF is not a git clone: %s\n' "$C2_REF"
224:    C2_LOG=$(timeout 180 git clone --quiet "$REPO" "$CLONE" 2>&1)
```

**One** of four checks clones (line 224, inside CHECK 2), not two — the other two hits are a comment
and a GATE_REF validation message. And since r103 an offline reference (`GATE_REF=<clone at the pin>`)
removes the network requirement from that one check too. The lesson's practical instruction
("this needs network") is now wrong in both halves, and it is the instruction a future seat would
act on **[O]**.

**Note on this block, which is itself the lesson.** The first draft of this section quoted the gate at
`197` / `208` / `218` — line numbers from the 347-line `577c8b54…` revision I had measured minutes
earlier. By the time I re-checked, the gate was 442 lines, sha `e5521304…`, and those numbers pointed
elsewhere. **The only reason the quote survived is that the command, not the number, was re-run.**
That is the whole of proposed Law 2, demonstrated inside the report that proposes it.

**Interpretation.** Four rots in one 217-line file, one round after it landed. None is a fabrication;
each was true when taken. That is precisely why the LAWS need to live somewhere that is *about the
class* rather than *about the instance* — the r105 entry's whole justification (§5).

---

## 4. The r103 `/tmp` LAW, reproduced live (and it is worse than the LOG records)

While re-running the gate for the evidence above, this seat hit the hazard r103 routed. It reproduced
on demand and it defeats the gate's own three-state exit contract.

### 4.1 Three verdicts, one tree, one script, ~5 minutes

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/r104seat46-gate.out 2>&1
GATE RESULT: PASS (checks failed: 0)                     # rc=0, 19:17:52Z
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > reports/round-104/lessons-carry-gate-default-tmpdir.out
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)   # rc=2, 19:19:15Z
$ for i in $(seq 1 10); do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ...; done
run1..run10  rc=1  verdict=GATE RESULT: FAIL              # 19:19:22Z, ten consecutive
```

Same tree (`git status` unchanged throughout: only untracked `reports/round-104/`), same script
sha256 `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0`. Raw logs in
`reports/round-104/lessons-carry-loop/run{1..10}.out` and
`reports/round-104/lessons-carry-gate-default-tmpdir.out` **[O]**.

**The gate moved under this seat while the report was being written** — and this is the second
demonstration of the class, not an aside. Revision stamp for every number in §4:

| measured at | gate sha256 | lines | `GATE_WORKDIR` refs | what §4 recorded |
|---|---|---|---|---|
| `19:17Z`–`19:19Z` | `577c8b54…` | 347 | **0** | PASS → BLOCKED → 10× FAIL (the three-verdict sequence) |
| `19:22Z`+ (re-measure) | `e5521304…` | **442** | **13** | 3× PASS default `/tmp`, 3× PASS `GATE_WORKDIR`; `POINTERS=101` → **102** |

So §4.1's sequence was taken against `577c8b54…` and **must not be quoted against the current bytes**.
The re-measure is in §4.5: the workdir fix landed in the gate itself (C2's declared scope,
`reports/round-104/gate/workdir-verify.md` had recorded `grep -c GATE_WORKDIR run_gate.sh` = 0), so
the hazard §4.1 demonstrates is **now mitigated by configuration rather than removed** — the default
is still `/tmp`:

```
$ sed -n '59p' corpus/knowledge/unreal-mcp/gate/run_gate.sh
WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
```

The default path is unchanged; a caller under quota pressure must now *know* to set `GATE_WORKDIR`.
That is why the LAW belongs in a lesson rather than only in the gate's own comment block.

### 4.2 The mechanism, isolated

```
$ echo hi > /tmp/s46-small.txt; echo "rc=$?"
/bin/bash: line 1: echo: write error: Disk quota exceeded
rc=1
$ head -c 100000000 /dev/zero > /tmp/s46-big.bin; echo "rc=$? size=$(stat -c%s /tmp/s46-big.bin 2>/dev/null)"
rc=1 size=0
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
```

`/tmp` refuses byte writes while `df` advertises 3.1 G free — it is a **per-user quota**, not a full
disk. `mktemp` still *succeeds* (it creates the inode), so the gate's scratch file exists but the
`sha256sum` redirect into it fails, and the check reports the failure with **no detail**:

```
$ sed -n '5,8p' reports/round-104/lessons-carry-loop/run1.out
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:        ← nothing follows the colon
CHECK 1 manifest-byte-identity
$ MANLOG=$(mktemp); (cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >"$MANLOG" 2>&1); echo "rc=$?"; wc -c <"$MANLOG"
rc=1
0
```

**The gate fails closed on a clean tree, and the diagnostic is empty.** A reader sees
`FAIL per-seat manifest sweep (--strict) failed:` and a green CHECK 1 (`MANIFEST_OK=12 EXPECTED=12
FAILED=0 RC=0`) — the two lines contradict each other and neither explains the other **[O]**.

### 4.3 The mixed case silently destroys the r103 third state

The FAIL run, verbatim (`reports/round-104/lessons-carry-loop/run1.out`, trimmed to the verdict
lines):

```
STEP=PASS          ← CHECK 1 (after the manifest-sweep FAIL above it)
STEP=BLOCKED       ← CHECK 2, with the full BLOCKED triple
STEP=PASS          ← CHECK 3, CARDS=13 NAME_SET=OK
STEP=PASS          ← CHECK 4, POINTERS=101 UNRESOLVED=0
GATE RESULT: FAIL (checks failed: 1)
```

CHECK 2 printed its complete A4 triple — `CHECK 2 BLOCKED (network)` /
`BLOCKED fresh clone could not complete` / `BLOCKED exit 2 is not a verdict` — and then the gate
exited **1**, because one other check had incremented `FAILS`. r103's own open item 3
(`reports/round-103/gate/exit-codes.md` §3.3, and `r103-report.md` open item 3) predicted exactly
this: *"`exit 2` fires only when `C2_BLOCKED=1 && FAILS=0` … the distinction A4 exists to create is
silently lost."* **This seat reproduced it live rather than by code-read** **[O]**.

Worse, the label is wrong in both directions: CHECK 2 was BLOCKED because of a **local disk quota**,
and the gate prints `BLOCKED (network)`. So a reader of `GATE RESULT: FAIL` cannot tell
"upstream unreachable" from "no local scratch space" from "the vendored bytes diverge" — the three
states A4 was built to separate collapse into one exit code with a mislabelled cause.

### 4.4 The workaround works, and it is the routing

```
$ for i in $(seq 1 8); do TMPDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ...; done
run1..run8  rc=0  verdict=GATE RESULT: PASS
```

Eight for eight PASS with `TMPDIR` on a filesystem that accepts writes; the tree was never the
problem. The r104 flake harness (`reports/round-104/gate/flake_harness.sh`, SEAT-14) already
implements `GATE_WORKDIR` → exported as `TMPDIR` **[C]**; at the time this seat measured,
`reports/round-104/gate/workdir-verify.md` §scope recorded `grep -c GATE_WORKDIR run_gate.sh` = **0**
**[C]**. This seat's contribution is the *live, reproducible* demonstration that the default
environment produces three different verdicts on one unchanged tree.

### 4.5 Re-measure against the moved gate (`e5521304…`, 442 lines)

Run after the gate gained `WORK_ROOT` (§4.1 stamp table) **[O]**:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08
$ for i in 1 2 3; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; done   # default /tmp
run1 rc=0  GATE RESULT: PASS (checks failed: 0)
run2 rc=0  GATE RESULT: PASS (checks failed: 0)
run3 rc=0  GATE RESULT: PASS (checks failed: 0)
$ for i in 1 2 3; do GATE_WORKDIR=/home/vgpnk/.cache/r104s46-gatewd bash …/run_gate.sh; done
run1 rc=0  GATE RESULT: PASS (checks failed: 0)
run2 rc=0  GATE RESULT: PASS (checks failed: 0)
run3 rc=0  GATE RESULT: PASS (checks failed: 0)
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E 'POINTERS|CARDS|NAME_SET'
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=102 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

Two things to carry forward:

- **The count moved again** — `POINTERS` read `101` at `19:17Z` and `102` at `19:22Z` on the same
  tree, because this report's own prose added a pointer string that CHECK 4's pass B sweeps. That is
  the self-referential property `gate/README.md:164-169` documents, reproduced by this seat as a side
  effect of writing about it. **`UNRESOLVED=0` held throughout.**
- **The mixed-state defect is unchanged** at the current bytes:

```
$ sed -n '436,442p' corpus/knowledge/unreal-mcp/gate/run_gate.sh
if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]; then
  printf 'GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)\n'
  exit 2
fi
printf 'GATE RESULT: %s (checks failed: %s)\n' \
  "$([ "$FAILS" -eq 0 ] && echo PASS || echo FAIL)" "$FAILS"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1
```

  `&& [ "$FAILS" -eq 0 ]` is still there: BLOCKED + any other failing check → `GATE RESULT: FAIL`,
  exit 1. This seat forced the mixed case on a `/tmp` copy of the current gate (planting
  `upstream/README.md:1-99999`, which makes CHECK 4 fail) and the run confirmed the third state is
  consumed **[O]** — the A1 control output was
  `LINE-OOR … (max 112) … POINTERS=104 … UNRESOLVED=31 / STEP=FAIL / GATE RESULT: FAIL
  (checks failed: 1)`. The exit-code issue r103 opened is **still open** at `e5521304…`.

**And the count moved a third time.** Minutes later, on the same unchanged tree:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -oE 'POINTERS=[0-9]+'
POINTERS=103
```

`101` → `102` → `103` in under ten minutes, driven by the r104 seats' own prose. **Three values, one
tree, one scanner.** No `POINTERS` number in this report is quotable, which is exactly why proposed
Law 1 is the first law rather than a footnote — and why `UNRESOLVED=0` is the thing to assert.

---

## 5. Why r105, and what the entry should be *about*

Three reasons the answer is "yes, and now":

1. **The material is un-distilled.** §2: 11/12 LAW keywords in zero lesson files. Precisely:
   r101's laws are distilled (into the r102 lesson's Laws 1–4), r102's laws are cited-but-not-carried,
   and **r103's four LAWS have no lesson presence at all**. The corpus contract
   (`~/.kimi-code/skills/shokunin/protocol/CORPUS.md`) is explicit that `lessons/` is the shokunin's
   *memory* and that *"a count carries its command"*, *"a negative claim carries its sweep"*,
   *"a quote names its location"* — the r102–r103 LAWS are the lane's own hard-won instances of
   exactly those rules, and they are being lost.
2. **The instance has already decayed (§3), which proves the class is the durable object.** A lesson
   that says "the gate printed POINTERS=40 in r102" is worthless by r104. A lesson that says "a
   `POINTERS` value without its scanner and its tree is not a claim; re-derive it or do not cite it"
   survives every round. r105's entry should be written the second way — and §3 is the worked
   example that justifies it.
3. **The evidence is fresh and independently reproducible (§4).** The `/tmp` hazard, the
   three-verdicts-one-tree demonstration, and the mixed-state collapse all reproduce on demand this
   round. A lesson written from r103's summary alone would carry the LOG's *"flake silently"*
   wording; the measured version is sharper (the check fails with an **empty diagnostic**, and the
   BLOCKED state is **lost**, not merely mislabelled).

**Scope discipline.** The entry should **not** try to be a full r80–r103 distillation — that is a
larger job than one round and would be prose without receipts. It should be **one entry, about
measurement and citation discipline**, carrying the r101–r103 LAWS as laws with source pointers.
The r80–r100 gap is a separate, larger coverage item and is **named here, not claimed**.

---

## 6. PROPOSED r105 lesson outline — **NOT WRITTEN** [P]

Proposal only. No `corpus/` byte was written by this seat; the outline below is the deliverable the
seat brief asked for.

### 6.1 Proposed identity

| field | value | why |
|---|---|---|
| path | `corpus/lessons/r105-measurement-discipline.md` | named for the **class**, not the round's topic — §5 reason 2; discovered by `ls`, so the stem must be self-describing (§1) |
| subject | how a claim in this lane is measured, cited, and invalidated | not "Unreal" — the LAWS are engine-neutral |
| source rounds | r101, r102, r103 | `LOG.md:1302-1400`; commit `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` |
| immediate worked example | `corpus/lessons/r102-unreal-integration.md` §3 rots | the entry's own justification |
| posture clause | **no Unreal runtime claim**; the editor is not installed | carried forward from r102 Law 2; must be re-stated, not inherited by reference |

### 6.2 Proposed laws (each with the source pointer the entry must cite)

**Law 1 — A measurement without its instrument is not a claim.**
Source: `LOG.md:1341-1343` (r102) *"three scanners read 40/41/43 on the same tree"*;
`corpus/knowledge/unreal-mcp/gate/README.md:164-169` (`POINTERS` is the sum of two passes and is
self-referential — editing the README moves it); `reports/round-103/note/gate-pin.md` §1
(`87` was one low at commit time, not drift). Re-derive command to embed:
`bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS` — which read **101** at
`577c8b54…` and **102** at `e5521304…` within five minutes of each other (§4.1). The law is that
neither number is quotable without its scanner; the invariant to embed instead is **`UNRESOLVED=0`**.

**Law 2 — A citation of a mutable artifact must be structural, not positional.**
Source: `LOG.md:1376-1377` (r103) *"a bare line-number citation rots"*;
the r103 precedent (`config.toml` `[[hooks]]` cited at 2932 → 3219 → **3290**, three numbers in
three rounds, `reports/round-103/note/configline.md`); and the worked counter-example in §3.2 above
(`gate/README.md:40`). Embed the drift-proof form the r103 note adopted:
`grep -n '\[\[hooks\]\]' <file>` — quote the command, not the line.

**Law 3 — A green result is only as strong as the attack suite that produced it, and a red one is
only as strong as its diagnostic.**
Source: `LOG.md:1344-1345` (r102) *"a new gate is only as strong as its attack suite"*;
`reports/round-102/adversary/*.md` (11 false-pass classes on the first landing) and
`reports/round-103/gate/a{1,2,3,4}-attack.md` (all four r103 hardenings verified **by falsification**,
not by reading). Add the r104 converse, measured this round: a **false red** with an empty diagnostic
(§4.2) is as damaging as a false green, because it costs a round and teaches nothing.

**Law 4 — A falsification verdict must name the hash of the thing it falsified.**
Source: `LOG.md:1378-1380` (r103) *"attack seats racing an author read STALE INTERMEDIATES"*;
`reports/round-103/r103-report.md` close-out ruling (SEAT-14 falsified a 249-line intermediate;
the final 347-line gate passed the same attack — the verdict was correct about the wrong bytes);
`reports/round-103/skill-table-review.md` §1 (the gate changed identity four times *during* one
review). Practical form to embed: `sha256sum <target>` printed **in the verdict**, not in a preamble.

**Law 5 — A count is round-relative, not just scanner-relative.**
Source: this seat, §7 **[O]** — `git grep -l '\.shokunin/game-dev-3d' <rev> | wc -l` reads
**167** at r102 close (`c85a816`), **189** at r103 close (`88c3b2c`), of which **25** are r103's own
report files. The r103 B2 ruling sized its repair at *"142 files scanned"* → 164 → 167 → 189 across
three rounds on the same nominal question. Any ruling sized by such a count must re-derive it in the
same breath.

**Law 6 — A pinned environment marker is a receipt about the host that produced it.**
Source: `LOG.md:1345-1348` (r102) — `r94_cannon_*` markers pin `node=v24.21.0`, the host runs
`v26.12.0`, 13 rows red by construction; carried forward unresolved into r104
(`LOG.md:1392` *"battery cannon node markers (carried)"*). Not re-measured by this seat; cite as
inherited **[C]**.

**Law 7 — Scratch space is a host input, and a silent scratch failure is indistinguishable from a
content failure.**
Source: `LOG.md:1382-1384` (r103) *"/tmp is a shared 16G tmpfs near quota — mktemp/clone workdirs
there flake silently"*; **sharpened by §4 of this report**: the quota rejects writes while `df`
reports 3.1 G free; `mktemp` succeeds and the redirect fails, so CHECK 1 fails with an **empty**
diagnostic on a clean tree; the same tree returns PASS / BLOCKED / FAIL within five minutes; and the
mixed BLOCKED+FAIL case collapses to exit 1, destroying the r103 A4 third state. Embed the
reproduction (ten-run loop) and the workaround — **`GATE_WORKDIR` (then `TMPDIR`, then `/tmp`)** —
noting that the fix is **configuration, not a changed default**: the gate still starts at `/tmp`
unless told otherwise (the `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` assignment, `run_gate.sh`
@ `e5521304…`, 442 lines), so a future seat under quota pressure must know the variable exists. §4.5
records that the variable landed in the gate mid-round, which is exactly why the *law* must outlive
the *fix*.

**Law 8 — Classify a failure before you fix it: engine behaviour, host capability, or harness.**
Source: `LOG.md:1371-1375` (r103) — `phys3d_joints_free_ops` ruled `INTRINSIC_WALL_COST`
(21 serial boots × ~0.9 s floor ≈ 19 s vs a 20 s cap; marker byte-identical at 120 s; 26/26 stored
receipts fail only at the cap), **not** engine behaviour and **not** a hang. Fix routed, not
re-baselined. The lesson is the *classification step*, and the temptation it defeats: calling a red
row a fixture defect.

**Law 9 — Two vocabularies for one situation is a defect even when every instance is honest.**
Source: `corpus/lessons/r102-unreal-integration.md` Law 3 (six cards reject `unproven-runtime` on the
ground the path "is not even identified", while the README defines the token as *"needs the live
editor"* — same condition, opposite labels; F7, still unresolved per
`reports/round-103/skill-table-review.md` §2 row C). **Extend with the r103 exit-code collision**
found by `reports/round-103/gate/exit-codes.md` §4.3: exit **2** means *BLOCKED* in the gate and
*"this negative control PASSED"* in `corpus/fixtures/README.md:46` — the same code, opposite
meanings, in one lane. Any wrapper written before that is resolved will misread one as the other.

### 6.3 Proposed `## Gate` section (required by `CORPUS.md`)

The corpus contract requires each lesson to carry candidates / admitted / rejected-with-reasons /
spot-check result. Proposed content:

- **Candidates:** the 12 keywords swept in §2 (scanner-relative counts; attack-suite strength;
  stale-intermediate race; boot floor; tmpfs quota; host-version markers; line-number rot;
  fixed-vs-documented; `INTRINSIC_WALL_COST`; `BLOCKED`; install-wall classes; binary proven/unproven).
- **Admitted:** Laws 1–9 above — each has a `LOG.md` line range plus at least one resolvable receipt.
- **Rejected with reasons:** (a) the r101 *ternary→binary label mapping* — already Law 3 of
  `r102-unreal-integration.md`, re-stating it would duplicate, so cite it (Law 9 keeps only the
  *new* exit-code half); (b) r101's Epic-account / 26.8 GB image / Lutris operator walls — these are
  **operator-owned open items** (`LOG.md:1324-1325`, `:1399-1400`), not laws; (c) the r80–r100
  mechanics laws (Jolt/GP splits, animtree matrix, etc.) — out of scope, named in §5 as a separate
  coverage item.
- **Spot-check result:** to be filled by the landing seat — one named non-author re-runs the
  embed-commands of Laws 1, 2, 4, 5, 7 and reports pass/fail per command. **This seat is not a
  candidate verifier for its own outline.**

### 6.4 Landing conditions (falsifiable, per the r103 review's style)

1. Every law carries a `LOG.md` line range **and** a command; acceptance:
   `grep -c 'LOG.md:' <entry>` ≥ number of laws, and every embedded command re-run by a second seat.
2. No bare `POINTERS=` value anywhere: acceptance `grep -cE 'POINTERS=[0-9]+' <entry>` → `0` **or**
   every hit carries scanner sha + tree revision on the same line.
3. No bare `file.md:NN` citation to a mutable artifact: acceptance
   `grep -cE '`[^`]+\.(md|sh):[0-9]+`' <entry>` → `0` (r103 review condition 1, applied to this file).
4. `## Gate` section present with all four sub-parts; acceptance `grep -c '^## Gate' <entry>` → `1`.
5. A named non-author verifier, and `SHONEN.md` box 1 **not** flipped by the author.

### 6.5 Self-audit — this report fails conditions 2 and 3

Run against this file, the conditions I just proposed are **not met**, and saying so is the point:

```
$ grep -cE 'POINTERS=[0-9]+' reports/round-104/lessons-carry.md
12
$ grep -oE '`[^`]+\.(md|sh):[0-9]+`' reports/round-104/lessons-carry.md | sort | uniq -c
   1 `LOG.md:1392`
   1 `corpus/fixtures/README.md:46`
   4 `gate/README.md:40`
   1 `reports/round-101/r101-critic-c3.md:365`
```

Both are defensible in context and neither is defensible as a *rule*:

- The 12 `POINTERS=` hits are almost all **quoted observations** (`POINTERS=40` as the r102 lesson's
  text, `POINTERS=101`/`102` as measured values with their revision stamped in §4.1) rather than
  claims. But a rule of the form "a `POINTERS=` value must carry its scanner on the same line" cannot
  be checked by a reader who has to judge which hits are quotes — so the honest form of condition 2 is
  a **command that returns the non-quoted hits**, and I did not write one.
- `gate/README.md:40` appears **four times** here, and the whole of §3.2 is the argument that citing a
  mutable file by line number is a defect. I cite it because the *defect* is that line number — a
  legitimate use — but a rule that admits "except when the line number is the subject" is not a rule
  a scanner can enforce.

**The lesson this report teaches, it also demonstrates about itself.** The r105 entry's landing
conditions should therefore be re-cut as executable checks with an explicit quote-exclusion (the same
shape r103's A1 fix used for the range-tail pointer), and the landing seat — not this one — should
write them. I am recording the failure rather than quietly passing my own audit.

---

## 6b. Revision stamp — every moving number in this report

This file was written while the tree moved under it. Numbers are only meaningful with the revision
that produced them.

| artifact | revision | value at that revision | measured |
|---|---|---|---|
| `corpus/lessons/r102-unreal-integration.md` | `cf237b88…`, 217 lines | 4 rots (§3) | `19:16Z` |
| `gate/run_gate.sh` | `577c8b54…`, 347 lines | `POINTERS=101`, `GATE_WORKDIR` refs **0** | `19:17Z` |
| `gate/run_gate.sh` | `e5521304…`, 442 lines | `POINTERS=102`, `GATE_WORKDIR` refs **13** | `19:22Z` |
| `gate/README.md` | `834f468d…`, 356 lines | pins `POINTERS=101` (four places) | `19:20Z` |
| `corpus/fixtures/run_battery.py` | `f456bd00…`, 350 `CASES` rows | unchanged all round | `19:20Z` |
| `LOG.md` / `SCORECARD.md` / `SHONEN.md` / `PROVINCE.md` | HEAD `88c3b2c` | byte-identical to HEAD | `19:20Z` |

`git status` at `19:22Z` additionally showed ` M corpus/fixtures/phys3d_joints.gd` (SEAT-04's declared
scope, C1 in flight) and untracked `SKILL.md` + `.r104-seat17/` — neither is this seat's. **Every
number in this report must be re-derived before it is quoted**; that is proposed Law 2 and Law 4
applied to the document that proposes them.

---

## 7. Round-relative count — worked example for proposed Law 5

```
$ git grep -l '\.shokunin/game-dev-3d' c85a816 -- . | wc -l
167
$ git grep -l '\.shokunin/game-dev-3d' HEAD    -- . | wc -l
189
$ git grep -l '\.shokunin/game-dev-3d' HEAD -- reports/round-103 | wc -l
25
```

167 (r102 close) − 3 (the READMEs r103 repaired) + 25 (r103's own report files) = **189** at r103
close. The class count grows by the round's own evidence, so the r103 B2 ruling's *"142 files
scanned"* / *"164"* / *"167"* series was never a stable input — and any future ruling that sizes
work by it will be sized by a number the ruling itself will move. Named here so the r105 entry can
cite a measured example rather than an assertion **[O]**.

*(Method note: `git grep <rev>` reads the tree at `<rev>`, so neither figure counts this round's
untracked `reports/round-104/**` — including this file, which cites the string. Add the round's own
reports to the count and it grows again. That is the law, not a caveat: the figure must be
re-derived, with its scanner named, at the moment it is used.)*

---

## 8. What this seat did and did not do

**Did:** re-derived the lesson-corpus census (§1); swept all 12 LAW keywords across the corpus (§2);
re-derived four rots in the r102 lesson with commands (§3); reproduced the `/tmp` quota hazard,
including three verdicts on one unchanged tree, the empty diagnostic, the mixed-state collapse, and
the `TMPDIR` workaround (§4); measured the round-relative count (§7).

**Did not:** write any `corpus/` byte — the r105 lesson is an **outline, not a file** (§6); adjudicate
the `POINTERS` value (the binding invariant is `UNRESOLVED=0`, per `reports/round-103/note/gate-pin.md`);
edit `corpus/lessons/r102-unreal-integration.md` (corrections to it are its owner's, and per
`CORPUS.md` *"corrections are new entries, never rewrites"* — which is itself an argument for the new
r105 entry); fix the gate's mixed-state exit logic (routed, `reports/round-103/gate/exit-codes.md` §3.3);
re-measure the `r94_cannon` node markers (inherited from r102, still carried).

**Host limits:** every number is from this host, this session, `/tmp` under a live quota; the quota is
intermittent, so §4's three-verdict sequence is a **reproduced observation**, not a deterministic
oracle — the *deterministic* claim is the one in §4.4 (`TMPDIR` on real disk → 8/8 PASS).

**No Unreal runtime claim anywhere.** Unreal Editor is not installed on this host; nothing above
asserts or implies live-editor behaviour, and the r105 entry proposed in §6 must carry that posture
clause explicitly rather than by reference.

---

## 9. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §1 — the corpus census
ls corpus/lessons/*.md | wc -l                                    # 91
ls corpus/lessons/ | grep -cE '^r103(-|\.)'                       # 0  (no r103 lesson)
wc -l corpus/lessons/r102-unreal-integration.md                   # 217
sha256sum corpus/lessons/r102-unreal-integration.md               # cf237b88…
ls corpus/lessons/README* ; echo "rc=$?"                          # rc=2 — no index

# §2 — the LAW keyword sweep
for k in "scanner-relative" "attack suite" "stale intermediate" "boot floor" \
         "tmpfs" "host-version" "fixed and documented" "BLOCKED"; do
  printf '%-24s files=%s\n' "$k" "$(grep -rlF -- "$k" corpus/lessons/ | wc -l)"; done

# §3 — the four rots in the r102 lesson
grep -c 'POINTERS=40' corpus/lessons/r102-unreal-integration.md   # 2
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS # 101 @577c8b54…, 102 @e5521304…
sed -n '40p' corpus/knowledge/unreal-mcp/gate/README.md           # a line about exit 2
ls /tmp/r101-closeout/                                            # rc=2 — deleted
grep -c 'git clone' corpus/knowledge/unreal-mcp/gate/run_gate.sh  # 3 hits; ONE is the clone (line 224)

# §4 — the /tmp quota hazard (the run count is the evidence; taken at gate 577c8b54…)
echo hi > /tmp/s46-probe.txt || echo "quota"                      # "quota" when live
df -h /tmp | tail -1                                              # 3.1G "free" anyway
for i in $(seq 1 10); do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; \
  echo "run$i rc=$?"; done                                        # 10 × rc=1 while quota is live
for i in $(seq 1 8); do TMPDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  >/dev/null 2>&1; echo "run$i rc=$?"; done                       # 8 × rc=0
# raw logs: reports/round-104/lessons-carry-loop/run{1..10}.out
#           reports/round-104/lessons-carry-gate-default-tmpdir.out

# §4.5 — re-measure on the moved gate, and re-confirm the open exit-code defect
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh            # e5521304… (442 lines)
for i in 1 2 3; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; echo "rc=$?"; done
for i in 1 2 3; do GATE_WORKDIR=/home/vgpnk/.cache/r104s46-gatewd \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1; echo "rc=$?"; done   # 3 × rc=0
sed -n '436,442p' corpus/knowledge/unreal-mcp/gate/run_gate.sh    # `&& [ "$FAILS" -eq 0 ]` still there

# §7 — the count is round-relative
git grep -l '\.shokunin/game-dev-3d' c85a816 -- . | wc -l          # 167
git grep -l '\.shokunin/game-dev-3d' HEAD    -- . | wc -l          # 189
```
