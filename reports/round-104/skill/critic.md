# r104 · SEAT-20 SKILL-CRITIC — adversarial review: does any row permit a claim stronger than its cited evidence?

**Seat:** SEAT-20 SKILL-CRITIC · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-104/skill/critic.md` (this file only). Nothing under `corpus/`
was written; the pinned subtree, `reports/round-101/**`, `reports/round-102/**`, `reports/round-103/**`
were read only. Every mutation ran on a throwaway skeleton under `reports/round-104/scratch/s20-*`
(created and deleted this seat) — never on a live tracked byte.
**Date:** 2026-10-18 · **Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103
report-last; work `8c9d9ad`) · no commit.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed on
this host (`which UnrealEditor UnrealEditor-Cmd` → rc 2, re-run below). Live-MCP behaviour is unproven
by construction.

---

## 0. What is under review changed mid-seat, and that is the first finding

The brief frames this seat against *"the r102-drafted, r103-reviewed decision table"* and describes C3 as
"land the table into SKILL.md". **C3 landed while this seat ran.** `SKILL.md` did not exist when I opened
(`ls SKILL.md` → `No such file or directory`); it exists now, written 16:19Z:

```
$ sha256sum SKILL.md ; wc -l SKILL.md
1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c  SKILL.md   # 16:19Z, first seen
de8ada369bf8bb1e7108a624…                                          SKILL.md   # 16:25Z, last seen
182 SKILL.md
$ ls -la SKILL.md
-rw-r--r-- 1 vgpnk vgpnk 20192 Oct 18 16:25 SKILL.md
```

So there are **two** candidate subjects, and an adversarial seat must say which it reviewed:

| subject | identity | status |
|---|---|---|
| `reports/round-102/skill-decision-table-draft.md` | `fa360bde…`, 373 lines | **superseded** — byte-frozen since r102; its text now lives inside `SKILL.md` §1 |
| **`SKILL.md`** | **`1055a52f…` → `5e9e57bb…` → `de8ada36…`, 174 → 182 lines** | **the shipped artifact — this is the review subject** |

**`SKILL.md` moved three times inside this seat's window** (16:19Z → 16:25Z), by a concurrent author
seat. Every finding below was **re-verified against the last-seen revision `de8ada36…`** before this
file was written; §9's acceptance commands are the ones a landing seat must drive to zero, and they
read `1 / 1 / 1 / 1` at that revision. Re-hash before acting — this is the same
`prose-cites-bytes` hazard the file's own §2 names, now demonstrated on the file itself.

**This review targets `SKILL.md`.** The draft is reviewed only where a defect survives into the landed
file (§7 records the ones that do not). Reviewing a superseded file as if it were the deliverable would
be the same class of error the file itself warns about — a claim pinned to bytes that have moved.

**Verdict: REVISE.** Five overreaches survive into the landed file; **one of them is new and is created
by the landing itself** (§4, O4). All five were re-confirmed at `de8ada36…`. The r102/r103 reviews' receipts-and-provenance findings are largely
repaired (§6). What remains is concentrated in the **label column**, which is exactly the brief's
question. Credit first, because the repairs are real: no gate line number survives anywhere
(`grep -cE 'run_gate\.sh:[0-9]' SKILL.md` → **0**), row B's commands now carry their cwd and name the
shellcheck ruleset, row D has an in-cell disambiguation, and a fifth row E exists with both controls
reproducing.

Tags: **[O]** command run by this seat with output quoted · **[M]** measured against a live surface ·
**[F]** the file's own claim did not reproduce.

---

## 1. Baseline — the three "post-r103 reality" facts, confirmed by this seat

The brief names three. All three hold, and I re-measured rather than inherited them.

**(a) The gate is hardened, and now also committed at HEAD.** At window open `git status` was clean and
HEAD carried `577c8b54…` (347 lines). It did not stay still — the r104 C2 seat landed
`GATE_WORKDIR`/`TMPDIR` into the worktree while this review ran:

| identity | lines | who | state |
|---|---|---|---|
| `577c8b5489577b94…` | 347 | r103 (SEAT-09) | **HEAD, clean** — verified committed |
| `7903c589334b43df…` | 361 | r104 C2, mid-flight | worktree `M` |
| `b6d8c61afa94bfde…` | 400 | r104 C2, mid-flight | worktree `M` |
| `e55213049db7538d…` | 442 | r104 C2, last seen | worktree `M` |

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   # at window open
$ git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   # identical → committed, not M
$ git status --porcelain corpus/knowledge/unreal-mcp/gate/run_gate.sh
(empty)
$ grep -c "GATE_WORKDIR" corpus/knowledge/unreal-mcp/gate/run_gate.sh
0                    # at window open; non-zero later in the same window
```

**(b) The labels are still ternary, and the gate's census is 12/1/0.** Confirmed on the live tree:

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
```

**(c) The physics row is a wall-cost class.** Confirmed from the ruling text, not from a re-run of the
21-boot arm (that is C1's seat, and re-running it would cost ~21 s of the very budget under repair):

```
$ grep -n "INTRINSIC_WALL_COST" reports/round-103/physics/adversary.md | head -2
18:**Ruled class (up front).** The row is **`INTRINSIC_WALL_COST`** — a **serial child-spawn budget overrun** …
144:**Ruled class: `INTRINSIC_WALL_COST` — serial child-spawn budget overrun.** Not `HANG` … Not `STARVATION` …
$ grep -n "CASE_TIMEOUT_SECONDS" corpus/fixtures/run_battery.py
36:CASE_TIMEOUT_SECONDS = 20
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
```

**And the consequence for the skill table, which the brief implies but does not state:** the table has
**no row that governs a fixture-runtime claim**. `grep -cin "battery\|godot\|phys3d\|run_battery"
SKILL.md` → **2**, both of which are the description's "headless battery"/"Godot" mentions, not a row.
A claim of the form *"the arm is correct — its marker is byte-identical at 120 s"* is exactly the kind of
claim this round's C1 produced, and no row of `SKILL.md` §1 admits it. See O5.

---

## 2. O1 — row A: byte-identity still licensed as a *ground* for a card label [O]

**The cell, verbatim (`SKILL.md` §1, row A — line 42 at `de8ada36…`; cited by row anchor, not line, per
the file's own citation rule):**

> `proven`. **No** ternary card label: the ternary is for subsystem cards, not file claims. A card may
> be `static-only` *on the strength of* an A-row.

The first two sentences are correct and are the file at its best. **The third is the overreach, and it
survived the landing unchanged** (`grep -c "on the strength of" SKILL.md` → **1**).

`static-only` is defined as a claim about a card's *document facts*:

```
$ sed -n '40p' corpus/knowledge/unreal-mcp/README.md
| `static-only` | the vendored document facts are proven by a static check run here; **no** runtime observation was made | `proven` for the document facts, `unproven` for the subsystem's behavior |
```

Row A's canonical command proves *file bytes* — `sha256sum -c …` → 12 × `OK`, rc 0. Byte-identity is a
**precondition** for `static-only` (a card whose bytes are not what upstream shipped cannot have proven
document facts), but it is not a **ground**: nothing in row A tests whether any document fact in a card
is true. The file says so itself, in its own refusal 2 (`SKILL.md` §5, item 2): *"No row lets a static
check stand for behavior. A static check proves the *files* it read, not the *behavior* they
describe."* **The cell and the refusal contradict each other, in the landed file.**

**Sharpening — the A-row control now reproduces, which is an improvement worth recording.** The draft
printed `MANIFEST_OK=10 … FAILED=2` and invented a mechanism for it (*"the append shifted the line count
of a file that another manifest row also covers"*). The landed file prints **11/1** and the control
reproduces exactly:

```
$ T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"; printf '\n' >> "$T/sub/upstream/README.md"
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')     → 11
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED')   → 1
$ (cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep 'FAILED')
upstream/README.md: FAILED
$ awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 \
    | sort | uniq -d | wc -l                                                                 → 0
```

So O1 is now a **pure label-overreach**, not a receipt defect: the evidence is honest, the label
permission is still too strong.

---

## 3. O2 — row B: a line-range check worded as semantic resolution [O]

**The cell's claim type (`SKILL.md` §1, row B)** includes *"this prose pointer resolves"*, and its
required evidence accepts *"a pointer sweep"* (`grep -c "this prose pointer resolves" SKILL.md` → 1;
`grep -c "a pointer sweep" SKILL.md` → 1).

I measured what the sweep actually proves, on a skeleton reproducing the full lane layout, by planting a
pointer that is **in range but semantically wrong** — citing `upstream/README.md:3` as the pin proof,
when line 3 is the plugin blurb:

```
$ sed -n '3p' corpus/knowledge/unreal-mcp/upstream/README.md
Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed …

# baseline skeleton
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: FAIL (checks failed: 1)          # the 1 is the in-flight per-seat sweep, see §8

# after planting the in-range-but-wrong pointer
POINTERS=102 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

`UNRESOLVED=0` — the sweep passed a pointer whose cited line says nothing like what the prose claims.
Reading the implementation confirms this is by construction: CHECK 4 compares the endpoint against
`wc -l` and never reads the line's content.

```
$ sed -n '/CHECK 4 pointer-sweep/,/P_TOTAL=$((P_TOTAL+1))/p' corpus/knowledge/unreal-mcp/gate/run_gate.sh
      [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; P_BAD=$((P_BAD+1)); }
```

So "this prose pointer resolves" is, mechanically, **"this pointer is in range."** A consumer of row B
reads the stronger claim, and the row permits it. **This is the exact defect class the file's own §2
names** — `green-gate-overread`, *"a passing gate read as closing a defect it cannot see by
construction"* — committed one table above the warning.

---

## 4. O4 — row C: the binding instruction would relabel six pinned cards. **New in the landed file.** [O]

This is the most serious finding and it is **created by the landing**, not inherited from the draft.

The draft diagnosed the F7 collision and declined to rule. The landed file **rules**:

```
$ sed -n '44p' SKILL.md | cut -c1-160
| **C** | **Runtime behavior** … | **`unproven`** ⇔ **`unproven-runtime`**. …
$ sed -n '124,126p' SKILL.md
Until it lands, the binding text is the one in §1 row B's **F7 clause**: a row-C
label is `unproven-runtime`, and a claim on one of the six dissenting subsystems
must cite the card it contradicts.
```

Now measure what that instruction does to the tree it is written about:

```
$ for c in animation-controlrig blueprints editor-general gameplay-gas materials meshes-textures; do
    printf "%-22s %s\n" "$c" "$(grep -m1 'Label:\*\*' corpus/knowledge/unreal-mcp/executability/$c.md | sed 's/.*Label:\*\* //' | cut -c1-14)"
  done
animation-controlrig   `static-only`
blueprints             `static-only`
editor-general         `static-only`
gameplay-gas           `static-only`
materials              `static-only`
meshes-textures        `static-only`
```

**All six dissenting cards are labelled `static-only`.** The file's binding instruction says a row-C
label is `unproven-runtime`. Followed literally, the instruction tells a consumer to write
`unproven-runtime` on claims about six subsystems whose own cards reject that label — and their ground
is quoted in the file's own §4 as the collision, in the words of `blueprints.md:113`:

> **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely went
> untested. Here the path is not even identified … The correct statement is weaker … That is
> `static-only`.

**The overreach, stated as the brief asks.** `unproven-runtime` asserts an *identified* runtime path.
For these six subsystems the lane has identified none. The file's binding text therefore **permits — in
fact requires — a claim stronger than the cited evidence supports**, and it does so while quoting, two
sections below, the card that says the weaker statement is the correct one. The `⇔` in the cell
(`grep -c '⇔' SKILL.md` → 1) is the mechanical form of that overreach.

The file half-anticipates this — its F7 clause adds *"a claim that contradicts one of the six dissenting
cards must cite the card it contradicts."* That mitigation is **insufficient**, because it governs
*citation* while the row's label column still **prescribes the label the card rejects**. A consumer who
cites `blueprints.md` and then writes `unproven-runtime` on it has followed both instructions and has
still contradicted the card it cited. **The `⇔` must become a conditional** (§9, condition 4).

Two honest qualifications:

1. This is a **live** collision, not a hypothetical: the subtree `README.md` hash is unchanged
   (`c79d8dd1d7c0c7bc…`), so `README.md:41` and the six cards still disagree, and
   `grep -rln 'Not `unproven-runtime`' …/executability/*.md | wc -l` → **6**.
2. The file's §4 is **right** to refuse to resolve the P/C precedence ruling itself (the subtree is
   byte-pinned; both sides belong to other seats). The defect is narrower and entirely within its
   authority: **a file that refuses to rule must not then bind a label in its checklist.**

---

## 5. O5 — scope: "exhaustive" is still the wrong word, and the lane's own axis is outside the table [O]

**The scope sentence (`SKILL.md` §1, preamble):**

> Four claim types are exhaustive over the pinned subtree (`corpus/knowledge/unreal-mcp/`); a fifth row
> covers the lane's own authored static artifacts, which the r102 draft left out.

The landing **narrowed** this correctly — the draft's false claim was *"exhaustive over the Unreal
artifacts in this lane"*, and the landed file scopes it to the pinned subtree. That is a real
repair. But two problems remain:

**(a) The word "exhaustive" is unsupported even at the narrower scope.** It is asserted, not tested. I
could not construct a counterexample inside the subtree, and I record that honestly — but the file's own
§2 error pattern `count-written-into-prose` requires an enumeration behind any such word, and none is
given. This is a wording defect, not a false claim.

**(b) The bigger gap, and the one this round makes visible: the table governs no fixture-runtime claim.**

```
$ grep -cin "battery\|godot\|phys3d\|run_battery" SKILL.md
2                    # both are the front-matter description, not a row
```

`SKILL.md`'s own description scopes the province as *"3D game production verified by executable headless
fixtures"* (`:3`). The lane's depth axis **is** the Godot battery — `run_battery.py` (`f456bd00…`, 350
`CASES` rows), the r103 `INTRINSIC_WALL_COST` ruling, and this round's C1 fix. A claim like *"the
fixture's marker is byte-identical given a sufficient bound"* is a first-class lane claim and **no row of
§1 admits it**. Row E covers a lane-authored *static descriptor*; nothing covers a lane-authored *runtime
fixture*. So the table is complete for Unreal content and **silent about the axis the round actually
advanced** — which is a coverage gap the next round should close, and which the file should not paper
over with "exhaustive".

---

## 6. O3 — provenance: the gate is cited by a sha that is already stale, and the checklist depends on a flaky command [O][M]

**(a) The gate stamp in §1 and §6 is `577c8b54…` — correct at write time, stale by the time you read
it.** The file cites the gate by sha, which is exactly right and is what r103 §4.1 demanded. But the C2
seat moved the gate four times inside this window, so the file's stamp now resolves to HEAD while the
worktree carries `e5521304…`. The file anticipates this (*"re-hash before acting on any of them"*,
`:154`) — so this is a **monitoring obligation**, not a defect. Recorded because a consumer who
copy-pastes the checklist gets a gate whose behaviour has changed underneath the stamp.

**(b) The landed §3 A-row admission criterion includes the one term that is not stable on this host.**
This is the finding only r104 could produce, and it is why the brief's C2 claim matters to the skill
table at all:

```
$ sed -n '83,85p' SKILL.md
- [ ] **A-row:** `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)`
      → 12 × `OK`, rc 0, **and** `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`
      → `STEP=PASS` on CHECK 2 (`PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`).
```

CHECK 2 is the fresh clone — the gate's largest scratch consumer. Measured this seat, same tree, same
pin, no repo mutation between runs:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ echo x > /tmp/r104s20-probe.txt
bash: echo: write error: Disk quota exceeded          # /tmp at HARD quota — 1 byte refused

run1  rc=0  GATE RESULT: PASS (checks failed: 0)
run2  rc=2  CHECK 2 BLOCKED (network) → GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
run3  rc=1  GATE RESULT: FAIL (checks failed: 1)
run4  rc=1  GATE RESULT: FAIL (checks failed: 1)
run5  rc=1  GATE RESULT: FAIL (checks failed: 1)
… then 20 consecutive rc=0 PASS runs …
… then rc=2 BLOCKED again
$ timeout 20 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD        # rc 0 — the network was UP throughout
```

**The consequence for the table is direct: an A-row's `proven` label rests on an admission criterion that
returned PASS, BLOCKED and FAIL on one unmodified tree inside one window.** A label whose evidence
includes a non-deterministic command is stronger than that evidence. The fix is not to weaken row A but
to make the criterion name its precondition — which the C2 seat's work already supplies:

```
$ TMPDIR=/nonexistent-dir-xyz bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo rc=$?
FAIL scratch root is not a directory: /nonexistent-dir-xyz
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory
rc=1                                     # NAMED, not silent — this is the C2 fix working
$ TMPDIR="$PWD/reports/round-104/scratch/s20-tmp" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)     # rc 0
```

But **at HEAD the fix is not landed** (`577c8b54…` carries no `GATE_WORKDIR`), so the flake is still
HEAD's behaviour and the checklist inherits it. The independent seat `reports/round-104/skill/author.md`
§4 reached the same attribution from the other direction (a 2×2 over `SKILL.md` × `TMPDIR`, plus two runs
seconds apart changing only `TMPDIR`) — two seats, same mechanism.

**One correction I owe, because an adversarial seat must not overclaim either.** Two of my early readings
in the series above were **my own redirect failing**, not the gate: `bash gate.sh > /tmp/out` produced a
0-byte file because `/tmp` refused the write. I record it because a reader reproducing these numbers will
hit it, and because it is the same failure mode the gate's own comment at `run_gate.sh:120-123`
describes. The non-zero *gate* runs above were captured through a pipe, not a `/tmp` redirect.

---

## 7. What survives scrutiny — stated so the verdict is not read as a rejection

Re-tested this seat and **sound**:

- **Every command in §1 that I re-ran reproduces its printed rc.** Row A: 12 × `OK`, rc 0; control 11/1.
  Row B: `jq -e .` rc 0 (and dot-less `jq` rc **3**, so the cell's warning is *correct and load-bearing*);
  `shellcheck` default rc 0; `shellcheck -o all` rc **1** with **31** findings — the count is right
  (`shellcheck -o all … | grep -cE '^In .*line [0-9]+:'` → 31). Row C: rc 2 / rc 2 / rc 128. Row D:
  `--version` → 2.2.0; the three `grep -c` → 0 each.
- **Row E is a genuine addition and its controls are honest.** Both commands reproduce:

  ```
  $ python3 corpus/artifacts/unreal-r22/verify_descriptor.py | tail -1
  PASS local-static actual=accept … reason=one fixed-scope Unreal-style Runtime module descriptor … ; rc=0
  $ python3 corpus/artifacts/unreal-r22/verify_descriptor.py …bad-type.uplugin --expect-reject | tail -1
  PASS local-static actual=reject … reason=unsupported module Type: 'Unknown' ; rc=0
  ```

  and the row's refusal is stronger than the artifact's own README claims — it forbids *"a statement
  about Unreal accepting it"*, which is precisely the right boundary for a lane-authored checker.
- **Row C's prohibition direction needs no qualifier.** A row that forbids a claim cannot overreach by
  permitting one; O4 concerns only its label *mapping*.
- **The citation rule (§1, after the table) and all six §5 refusals are correct and load-bearing**, and
  the file *practises* refusal 3 where it matters most: `POINTERS` is discussed as a measurement, never
  pinned as a constant — the exact trap that bit the r102 draft.
- **The gate's fail-by-construction on `verified-here=1` is real**, which is what makes row D's
  disambiguation necessary rather than decorative. Confirmed on a skeleton:

  ```
  $ sed -i '4s/static-only/verified-here/' "$S/…/executability/blueprints.md"
  $ bash "$S/…/gate/run_gate.sh" | grep -E "CENSUS|STEP=FAIL"
  CENSUS static-only=11 unproven-runtime=1 verified-here=1 EXPECTED=12/1/0
  STEP=FAIL
  ```

  `EXPECTED_VERIFIED=0` (`run_gate.sh:38`, enforced at `:260`) — which is exactly why O4's binding text
  cannot be the card sense.

---

## 8. O6 — a live gate red observed in my window, and its attribution

Not a finding against `SKILL.md` — recorded so the round's own close-out does not misattribute it, and
because it bears on O3(b).

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
FAIL per-seat manifest sweep (--strict) failed:
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CHECK 2 BLOCKED (local-resource)
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)
```

`MANIFEST_OK=12 FAILED=0` — the manifest itself is clean; the sweep's *scratch file* could not be
created. Running the sweep directly with no gate involved returns clean, which localizes it:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256; echo rc=$?
… 24 × OK …
rc=0
```

This is the C2 root cause, reproduced live rather than inherited. **It is not caused by `SKILL.md`** —
`SKILL.md` lives at the lane root, outside the gate's `SUB`, and the gate never reads it
(`grep -n "SKILL" corpus/knowledge/unreal-mcp/gate/run_gate.sh` → no output). The in-flight check's own
comment names the mechanism: a bare `mktemp` under quota pressure leaves `MANLOG` empty, the redirect
fails, and the sweep reports as broken — *"the same misleading-failure class this seat exists to
close"* (`run_gate.sh:120-123`).

**One hygiene note, measured because it would otherwise become a false red.** `SKILL.md` cites five
repo paths that resolve only from the subtree (`adaptation-kimi.md`, `gate/run_gate.sh`,
`audit-reference.sha256`, `r101-critic-c3.md`, `r101-mutation-tester.md`). Those are **not** dangling:
the gate's pass-B sweep only counts paths beginning `corpus/`/`reports/`/`docs/` (mapped to `REPO_ROOT`)
or `executability/`/`gate/`/`upstream/`/`.manifest.d/` (mapped to `SUB`), and it globs
`--include='*.md' "$SUB"` — so it never scans `SKILL.md` at all, and the subtree-relative forms are the
house style throughout. Verified by running the gate's own pass-B regex over `SKILL.md`: **0 would-flag
paths**. Recorded so a future seat does not "fix" a non-defect.

---

## 9. Verdict and landing conditions

**Verdict: REVISE. The file is worth landing; it is not yet the thing to land.** `SKILL.md` now exists
and its §6 correctly states that landing satisfies only the *artifact* half of `SHONEN.md` box 1 —
the box is a promotion gate requiring a **named non-author verifier**, and SEAT-40 (author), SEAT-41,
SEAT-59 and this seat (SEAT-20) are all excluded. Box 1 reads `[~]` at most.

**Repaired by the landing, and not re-raised:** all ten dead `gate/run_gate.sh:NN` citations (→ 0);
row B's cwd-less and dot-less commands; row D's undifferentiated `verified-here`; row A's falsified
10/2 control and its false explanation; the missing E-row; the artifact index's stale stamps.

**Four conditions this seat adds — all in the label column, which is where the brief's question lands.**

1. **Row A (`:42`): delete "on the strength of an A-row".** Replace with the accurate relation:
   byte-identity is a **precondition** for `static-only`, not a ground for it; the ground is the static
   check the card itself cites. Acceptance: `grep -c "on the strength of" SKILL.md` → **0** and the
   replacement sentence names "precondition".
2. **Row B (`:43`): qualify "resolves".** The cell must say the pointer sweep proves **line-range
   only** and that CHECK 4 does not read line content — with the control that demonstrates it
   (in-range, semantically wrong pointer → `UNRESOLVED=0`). Acceptance: the claim-type cell contains
   "line-range" and "resolves" is qualified in the same cell.
3. **Row D (`:45`) + refusal 4 (`:142`): reconcile.** Row D's `verified-here` is the row-probe sense and
   must say so **in the refusal too**, or refusal 4 must be reworded to "no *card* label". As landed, a
   reader of §5 alone is told the label is forbidden while row D grants it. Acceptance:
   `grep -c 'row-probe' SKILL.md` ≥ 2 (cell **and** refusal).
4. **Row C (`:44`) and §4 (`:124-126`): replace the `⇔` with a conditional, and stop binding a label the
   file refuses to rule on.** `unproven-runtime` applies **only where a runtime path is identified**; for
   the six dissenting subsystems the row must name `static-only` and require the claim to cite the card
   it contradicts. Acceptance: `grep -c '⇔' SKILL.md` → **0**, and §4's binding sentence no longer
   prescribes `unproven-runtime` for the six cards it names.

**And one condition the round's own scope imposes:**

5. **Make the A-row checklist criterion name its precondition, and land the C2 fix first.** §3's A-row
   box requires `STEP=PASS` on CHECK 2, which returned PASS/BLOCKED/FAIL on one unmodified tree (O3b).
   Acceptance: the box names `GATE_WORKDIR`/`TMPDIR`, and the gate's `GATE_WORKDIR` support is
   **committed** — at HEAD it is not.

**Recommended but out of this seat's authority:** a sixth row (or a scope note) for **fixture-runtime**
claims — the lane's own depth axis (O5b). Until it exists, the file's "exhaustive" is a claim about a
subtree while its own description scopes the province more widely.

---

## 10. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §0 — both subjects, and the landing that happened mid-seat
sha256sum SKILL.md                                      # 1055a52f… 174 lines, written 16:19Z
sha256sum reports/round-102/skill-decision-table-draft.md   # fa360bde… 373 lines (superseded)

# §1 — the gate: committed at HEAD, then moved under the r104 C2 seat
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum    # 577c8b54… (same at open)
git status --porcelain corpus/knowledge/unreal-mcp/gate/run_gate.sh       # empty at open, " M" later
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"           # PASS / BLOCKED rc 2 / FAIL rc 1

# §2 O1 — row A's control reproduces (11/1)
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"; printf '\n' >> "$T/sub/upstream/README.md"
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')     # 11
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED')   # 1
awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 \
  | sort | uniq -d | wc -l                                                                 # 0

# §3 O2 — CHECK 4 is content-blind. Build a skeleton reproducing the lane layout, confirm green,
# then append `See \`upstream/README.md:3\` for the pin proof.` to executability/materials.md
# (line 3 is the plugin blurb) → POINTERS 101→102, UNRESOLVED=0 unchanged.

# §4 O4 — the binding instruction vs the six cards
sed -n '44p;124,126p' SKILL.md
for c in animation-controlrig blueprints editor-general gameplay-gas materials meshes-textures; do
  printf "%-22s %s\n" "$c" "$(grep -m1 'Label:\*\*' corpus/knowledge/unreal-mcp/executability/$c.md | sed 's/.*Label:\*\* //' | cut -c1-14)"
done                                                    # all six: `static-only`
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l   # 6
sha256sum corpus/knowledge/unreal-mcp/README.md                                             # c79d8dd1… unchanged

# §5 O5 — scope
sed -n '24,27p' SKILL.md ; grep -cin "battery\|godot\|phys3d\|run_battery" SKILL.md          # 2, both front-matter
grep -n "INTRINSIC_WALL_COST" reports/round-103/physics/adversary.md | head -2
sha256sum corpus/fixtures/run_battery.py                                                    # f456bd00…

# §6 O3 — every printed command re-run
(cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo rc=$?)   # 3 (the cell's warning is right)
(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo rc=$?) # 0
(cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh >/dev/null; echo rc=$?)                          # 0
(cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -cE '^In .*line [0-9]+:')    # 31
python3 corpus/artifacts/unreal-r22/verify_descriptor.py | tail -1                                              # PASS accept, rc 0
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject | tail -1  # PASS reject, rc 0

# §6 O3b / §8 — the flake, and its named-failure fix
df -h /tmp; echo x > /tmp/probe.txt                       # 80% used; "Disk quota exceeded"
timeout 20 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD  # rc 0, network up
TMPDIR=/nonexistent-dir-xyz bash corpus/knowledge/unreal-mcp/gate/run_gate.sh   # FAIL scratch root…, rc 1 (NAMED)
TMPDIR="$PWD/reports/round-104/scratch/s20-tmp" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh  # PASS rc 0
(cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256); echo rc=$?       # 24 × OK, rc 0

# §8 — SKILL.md is invisible to the gate, and its subtree-relative cites are not dangling
grep -n "SKILL" corpus/knowledge/unreal-mcp/gate/run_gate.sh   # no output
grep -ohE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' SKILL.md \
  | tr -d '`' | sed 's/:[0-9]\+$//' | sort -u | while read p; do case "$p" in corpus/*|reports/*) [ -e "$p" ] || echo "WOULD-FLAG: $p";; esac; done   # (nothing)
```

---

## 11. Limits of this review

- **I am a reviewer, not the author.** I edited no file under `corpus/` and none named `SKILL.md`. Every
  mutation in §2, §3, §6, §8 ran on a throwaway skeleton under `reports/round-104/scratch/s20-*`, created
  and deleted this seat. The live repo was only read.
- **The subject moved while I reviewed, and so did the tooling.** `SKILL.md` appeared at 16:19Z, after I
  had begun reviewing the r102 draft it supersedes; the gate went through four identities; its
  `git status` went clean → `M`. Every number here is pinned to the identity in the same block — **re-hash
  before acting on any of them.**
- **`/tmp` is at hard quota on this host**, so all scratch had to be lane-local. Two of my own early
  measurements were corrupted by that before I moved the skeleton; §6b records it because a reader
  reproducing these commands will hit the same wall.
- **The five overreaches are graded, not equal.** O1/O2 are one-cell wording defects; O4 is the
  substantive one and needs a conditional in both row C and §4; O3/O5 are provenance and scope. O1 and
  O2 are contradictions *between a cell and the file's own refusals*; **O4 is the only one where the file
  positively instructs the stronger claim.**
- **I did not re-audit every citation in the file.** I re-ran every command in §1 and every command in §3,
  read the load-bearing prose, and swept the gate/artifact-index citations exhaustively. A range being
  *in bounds* is not a claim that the quoted words are on those lines, and CHECK 4's content-blindness
  (§3) means the gate cannot tell me either.
- **No Unreal runtime claim.** The editor is not installed; nothing above asserts live-editor behaviour,
  and row C's inability to be controlled is a property of this host, not a defect.
