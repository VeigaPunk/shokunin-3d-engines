# r104 · SEAT-22 DISSONANCE — contradictions between r104 artifacts and the r101–r103 record

**Seat:** SEAT-22 DISSONANCE · round 104 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/r104-dissonance.md`). No other file was written or
modified by this seat; no `git commit`/`push`/`checkout`/`reset` was run. All commands read-only.
**Lane HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (r103 report-last; work `8c9d9ad`)
**Probe window:** `2026-10-18T19:16Z` → `19:26Z`. **The tree was live throughout and both claims
landed mid-window.** `reports/round-104/` grew 2 → 22 report files and ~8.6k files total; the gate
script moved through **five** distinct shas; `phys3d_joints.gd` moved `88be87fa… → c7e77638…`. Every
number below carries the command that produced it and the sha of the bytes it was taken against;
where a value moved, **both** values are given.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed
on this host (`which UnrealEditor` → rc 2); live-MCP behaviour is unproven by construction.
Everything below is a static/byte/HTTP/process check.

Tags: **[O]** command run by this seat with output quoted · **[C]** cross-referenced to a peer seat's
r104 artifact · **[F]** the claim did not reproduce · **[?]** unresolved.

---

## 1. Headline

Twenty-one contradictions in six classes. The two load-bearing ones are **A1** and **C1**:

| class | count | meaning |
|---|---|---|
| **A. r103's report pins gate identities that never existed as objects** | 3 | r103 C2 states the landed gate is `0c1ca3e1…` / 341 lines; no such blob exists, and the committed gate is `577c8b54…` / 347 |
| **B. r104 artifacts contradict the tree or each other on the C2 landing** | 5 | `GATE_WORKDIR` "does not exist" vs "landed"; gate reported at 418 lines while the live file was 442 |
| **C. the gate's own `/tmp` flake is real, was routed by r103, and r104's first artifact denies it** | 4 | `final-run.md` asserts run-to-run byte-identity; 8/20 runs I measured were non-PASS |
| **D. the gate README's scanner/pointer pins are stale or self-inconsistent at the final frame** | 3 | live gate prints `103`; README carries `87`/`101`/`102`/`103` in seven places and two scanner shas |
| **E. r104's round report is a stale frame presented as a verdict** | 3 | `C1` and `C2` bullets still say "not landed"/"does not exist" while the landed state is measured above them |
| **F. r101–r103 open items dropped without a carrier** | 3 | `mode_ok`/R2, F3/F5/F6 rulings, and the 12-attack-suite re-run have zero r104 carriers |

**Most consequential finding (A1).** `reports/round-103/r103-report.md:55-56` pins the r103-landed
gate at `sha256 0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`, 341 lines. **No
such object exists in this repository** — not in any commit, not as a loose object, not anywhere in
the object store. The gate actually committed at `8c9d9ad` is `577c8b54…`, **347** lines. This is the
exact class r103's own `r103-dissonance.md` §A1 charged against r102 (a stale mid-draft frame shipped
as a landed receipt) — **the same defect recurred one round later, in the round that named it.**

---

## 2. A — r103's gate identity receipts name blobs that never existed

### A1 — r103 C2's landed gate sha `0c1ca3e1…` / 341 lines is not an object

**Side A (r103 report, `:55-56`).**

> The script went **249 → 341 lines** (+138/−48 net vs HEAD, sha256 `0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`).

and again at `:435`: *"must be re-run against `run_gate.sh` sha256 `0c1ca3e1…` **at close**"*.
`reports/round-103/gate/a1-attack.md:134` and `docs-sync.md:19` both cite `0c1ca3e1…` as "the
snapshot this verdict is rendered against".

**Side B (the repository).** **[O]**

```
$ git cat-file -t 0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e
fatal: Not a valid object name 0c1ca3e1…
$ git cat-file --batch-all-objects --batch-check='%(objectname)' | grep -c '^0c1ca3e1'
0
$ for c in $(git rev-list --all); do git show "$c:corpus/knowledge/unreal-mcp/gate/run_gate.sh" 2>/dev/null | sha256sum | cut -c1-16; done | sort -u
412d1b84857233e8        # the r102/r103-committed gate
577c8b5489577b94        # the r103-report-last / r104-base gate
e3b0c44298fc1c14        # empty (path absent in pre-r101 revisions)
$ git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  -
$ git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | wc -l
347
```

Only **three** distinct gate blobs have ever existed in history: the r102/r103-committed
`412d1b84…` (249 lines), the r103-report-last `577c8b54…` (347 lines), and the empty-string hash for
revisions predating the path. **`0c1ca3e1…` appears nowhere, and neither does the "341 lines"
revision.** The report's *other* gate reference — the L1 adjudication at `:487`, *"SEAT-09's final
implementation (347 lines) was landed afterwards"* — names the correct 347-line revision, so the
round's own close-out contradicts its own C2 receipt.

**Verdict: CONFIRMED contradiction.** `0c1ca3e1…` was a mid-draft worktree frame; `577c8b54…` is the
correct landed identity and is what `gate/README.md:41` and the r104 seats cite. Same defect class as
the r102 `A1` finding that r103 filed. **[O]**

### A2 — r103's documented `GATE_REF=/tmp/ue-skills-ref` receipt no longer reproduces, and the clone is gone

**Side A (r103 report, "Reproduce at close").**

> `GATE_REF=/tmp/ue-skills-ref bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"   # PASS, rc=0`

**Side B (this seat, on HEAD).** **[O]**

```
$ ls -d /tmp/ue-skills-ref
ls: cannot access '/tmp/ue-skills-ref': No such file or directory
$ GATE_REF=/tmp/ue-skills-ref bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
GATE_REF=/tmp/ue-skills-ref (offline reference; no clone attempted)
FAIL GATE_REF is not a git clone: /tmp/ue-skills-ref
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
rc=1
```

**Verdict: CONFIRMED contradiction.** The r103 reproduce block's expected `PASS, rc=0` now yields
`FAIL, rc=1`, because `/tmp` is a shared tmpfs that swept the clone. Independently found by
`reports/round-104/freshness-pin.md` §4 (*"the r101 reference clone is gone — a standing citation now
falsified"*), which also quotes `adaptation-kimi.md:446`'s *"They happen to be **currently live**
(`/tmp/ue-skills-ref` still exists…)"* and marks it **false**. **[O]** Note this is the *r103 report's*
reproduce recipe, not a gate defect — but it is a landed receipt that no longer reproduces.

### A3 — the 11/12-attack suite cannot be re-run: both r102 and r103 evidence directories are gone

**Side A.** `reports/round-103/r103-report.md:445-447` and `close-count.md:42` cite
`bash /home/vgpnk/advgate-r103/attacks2.sh` as the 11/11 receipt; r102 cited `/tmp/advgate/hardened.sh`.

**Side B.** **[O]**

```
$ ls -la /home/vgpnk/advgate-r103/
ls: cannot access '/home/vgpnk/advgate-r103/': No such file or directory
$ ls -la /tmp/advgate/
ls: cannot access '/tmp/advgate/': No such file or directory
```

**Verdict: CONFIRMED contradiction (evidence lost).** Neither directory survives, so neither the r102
"11/11" nor the r103 "11/11 still detected" claim is re-runnable from its cited artifact. r104
`gate/regression.md` reconstructs a suite at `/var/tmp/r104suite/` and reports 11/11 DETECTED — but
against revision `b6d8c61a…`, which is **also not an object** (§B2). **[O]**

---

## 3. B — r104 artifacts contradict the tree or each other on the C2 landing

### B1 — `GATE_WORKDIR` "does not exist" vs "LANDED": two r104 artifacts disagree, and the round report holds both

**Side A (r104 round report, C2 bullet `:62-64`).**

> `grep -c 'GATE_WORKDIR' …/run_gate.sh` → **0**: the script is unchanged from HEAD at 347 lines / sha
> `577c8b54…`, with bare `mktemp` at `:74` and `:86`.

and its landed-changes table `:114`: *"`GATE_WORKDIR` support | **not landed** — 347 lines, sha
`577c8b54…` = HEAD, `grep -c GATE_WORKDIR` → 0"*.

**Side B (the tree, later in the same window).** **[O]**

```
$ grep -c 'GATE_WORKDIR\|TMPDIR' corpus/knowledge/unreal-mcp/gate/run_gate.sh
13
$ grep -n 'WORK_ROOT=' corpus/knowledge/unreal-mcp/gate/run_gate.sh | head -2
59:WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08  (442 lines)
```

**Verdict: CONFIRMED contradiction, and it is internal to one file.** The same round report carries
both "not landed / 347 lines" (`:114`) and "**landed** — `577c8b54…` → `15fc46d5…`, 347 → 418 lines"
(`:146`). The tree at final frame is `e5521304…` / **442** lines — a *third* value, matching neither.
The report's own header discloses the churn (`:30`: *"`577c8b54…` → `15fc46d5…`"*) but the landed-changes
table was not re-swept. **[O]**

### B2 — the gate revisions r104 names as "the installed revision" do not exist as objects

**Side A.** `reports/round-104/gate/regression.md:162`: *"at revision `b6d8c61a…` (24486 bytes), 30/30
rows behave as specified"*; the round report `:76,:146,:346` pins **`15fc46d5…`** as the landed C2 gate.

**Side B.** **[O]**

```
$ git cat-file -t b6d8c61afa94bfde862fc95f2fdd95e87d4632ec46358ade0634385bfc79a59d
fatal: Not a valid object name b6d8c61a…
$ git cat-file -t 15fc46d5
fatal: Not a valid object name 15fc46d5
$ git cat-file --batch-all-objects --batch-check='%(objectname)' | grep -c '^b6d8c61a'
0
```

**Verdict: CONFIRMED contradiction.** Both are uncommitted worktree intermediates. This is not
inherently wrong — r103's own LAWS entry rules that *"falsification verdicts must name the target's
hash"* — but it means **every** r104 gate receipt (regression 30/30, workdir-verify 3/3, final-run
PASS×3) is bound to a revision that no longer exists and cannot be re-derived. The only re-runnable
anchor is the live file, which I measured at `e5521304…` / 442 lines. **[O]**

### B3 — `final-run.md` claims run-to-run byte-identity; 8 of 20 runs I measured were non-PASS

**Side A (`reports/round-104/gate/final-run.md`, §"Evidence the run is reproducible").**

> `diff` of runs 1 and 2 after stripping the `time` lines: **empty** — the gate's output is
> byte-identical run to run on an unchanged tree (no timestamps, no path instability, no map-order
> dependence).

**Side B (this seat, same tree, minutes later).** **[O]**

```
$ for i in $(seq 1 20); do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/tmp/q$i.out 2>&1; rc=$?; printf '%s:%s/%s ' "$i" "$rc" "$(wc -c </tmp/q$i.out)"; done
1:0/1986 2:0/1986 3:0/1986 4:0/1986 5:0/1986 6:0/1986 7:2/2080 8:0/1986 9:0/1986 10:0/1986 11:2/2080 12:0/1986 13:0/1986 14:2/2080 15:2/2080 16:2/2080 17:0/1986 18:2/2080 19:2/2235 20:1/2102
```

**Verdict: CONFIRMED contradiction.** 7× `rc=2` and 1× `rc=1` against 8× `rc=0`, on one unchanged
tree inside one minute. `final-run.md`'s own §Notes 2 anticipated this honestly (*"this run neither
confirms nor refutes the r103 `/tmp`-quota root cause — it simply was not under enough pressure to
fail"*), but its headline stability claim is falsified by the very next measurement. **[O]**

### B4 — the gate can exit **silently with rc=1 and zero bytes on both streams**

**Side A.** `reports/round-103/gate/close-runs.md` recorded this as *"one run produced EMPTY output
with exit 1"* — an unexplained anomaly, routed to r104.

**Side B (this seat).** **[O]**

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/tmp/direct.out 2>/tmp/direct.err; echo "rc=$? out=$(wc -c </tmp/direct.out) err=$(wc -c </tmp/direct.err)"
rc=1 out=0 err=0
$ ( cd "$(pwd)" && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ) >/tmp/sub.out 2>&1; echo "rc=$? bytes=$(wc -c </tmp/sub.out)"
rc=1 bytes=0
```

**Mechanism, isolated.** Every diagnostic is swallowed by the same failing redirect; the failure is
`printf: write error: Disk quota exceeded` on the gate's own stdout, which `run_gate.sh` never checks:

```
$ for i in 1 2 3 4 5 6; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/tmp/s22r$i.out 2>&1; done
$ wc -c /tmp/s22r*.out
0 /tmp/s22r1.out ... 0 /tmp/s22r6.out
```

Independently root-caused by `reports/round-104/gate/workdir-verify.md` §6, which captured the full
39-line stderr series (`run_gate.sh: line 48: printf: write error: Disk quota exceeded`, lines 48
through 345). **[C]**

**Verdict: CONFIRMED — r103's "anomaly (2)" is fully explained and is not rare.** It is a
scratch-filesystem exhaustion on the *caller's* stdout, and the gate has no way to report it. **[O]**

### B5 — the `CHECK 2 BLOCKED (network)` label was a misdiagnosis on this host

**Side A (r103's A4 contract, `gate/README.md:91-99`, still the headline text at the final frame).**

> **BLOCKED is a third state, not a flavour of FAIL.** This is the only check needing network. When the
> clone cannot complete (upstream unreachable)…

**Side B.** **[O]** At the moment the gate printed `CHECK 2 BLOCKED (network)`, the network was up:

```
$ timeout 30 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
$ git clone --quiet <same-url> /tmp/s22c
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to '…/.git/description': Disk quota exceeded   (rc=128)
```

**Verdict: CONFIRMED contradiction.** A local disk failure was reported as an unreachable upstream,
sending the reader to the wrong subsystem. r104's C2 seat added a `local-resource` sub-state
(`run_gate.sh:263-266`, `CHECK 2 BLOCKED (local-resource)`) which fixes the *reporting* — but the
README's headline A4 paragraph still describes BLOCKED as exclusively network, and the round report
still lists this as **open** (item 4). **[O]**

---

## 4. C — the gate README's scanner and pointer pins at the final frame

### C1 — the README pins `577c8b54…` twice while the live scanner is `e5521304…`

**Side A.** `gate/README.md:397` — the r103 pin-correction note's evidence block:

> Evidence at the settled scanner (`run_gate.sh` sha256 `577c8b54…`)

and its printed block: `POINTERS=101 …`.

**Side B.** **[O]**

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08
$ GATE_WORKDIR=<repo-local> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep ^POINTERS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

**Verdict: CONFIRMED contradiction.** The r103 note is explicitly a *historical frame* (it names its
own scanner), which is defensible — but the live count is `103`, not `101`, and the README carries
`101` in two places and `102` in one, with the current pin `103` in four. A reader following the
"expected values" block without reading the dated parenthetical gets a number that will not reproduce.

### C2 — the README's own current pin is self-inconsistent

**Side A.** `:42` — *"The r104 scanner sha256 is `e5521304…` and the current pin is `POINTERS=103`"*.

**Side B.** **[O]** The README simultaneously prints:

```
$ grep -no "POINTERS=[0-9]*" corpus/knowledge/unreal-mcp/gate/README.md   # frame 1 (README 9ba489e0…)
41:POINTERS=87      42:POINTERS=103     248:POINTERS=103
271:POINTERS=103    357:POINTERS=101    377:POINTERS=102    401:POINTERS=101

$ grep -no "POINTERS=[0-9]*" corpus/knowledge/unreal-mcp/gate/README.md   # frame 2 (README e3bc66b7…), ~90 s later
41:POINTERS=87      42:POINTERS=103     248:POINTERS=103
271:POINTERS=103    357:POINTERS=101    377:POINTERS=103    401:POINTERS=101
```

**Verdict: CONFIRMED contradiction.** r103 open item 4 (three counts at once) was declared
**ADDRESSED** by `reports/round-104/consistency.md:170` — which validated its claim against a
**README sha that moved at least three times in my window** (`c2c563e2… → 9ba489e0… → e3bc66b7…`)
and against counts `101: 2 / 102: 0 / 103: 4`. Both my frames show `87` and `101` co-resident with
the current `103`, and frame 1 additionally carried a `102` that consistency's own sweep recorded as
**0**. The pin is genuinely scanner-relative and the README says so — but "ADDRESSED" was asserted
against a moving file, and the stale-count class it closed is still visible in the file two frames
later. **[O]**

### C3 — `consistency.md` marks the exit-semantics item ADDRESSED using a line range that no longer exists

**Side A.** `reports/round-104/consistency.md:141-150`:

> `$ sed -n '208,222p' corpus/knowledge/unreal-mcp/gate/README.md` … The old contradicting lines the
> item quoted (`:156-157` "`1` otherwise. There is no partial-pass state", `:73-74` a failed clone
> "exits 1") are gone: `grep -n 'exits 1' …README.md` → no match.

**Side B.** **[O]** `grep -n "exits 1" corpus/knowledge/unreal-mcp/gate/README.md` → **0 matches** —
**confirmed**, the two contradicting lines are gone. But the same grep still finds `:292`: *"There is
no partial-pass state"* in the current Exit-codes section, which is the *retained* sentence from the
old `:156-157`. The item's substantive point (the README now declares `0`/`1`/`2`) **does** hold.

**Verdict: PARTIAL.** The ADDRESSED verdict is substantively right; the evidence block quotes a
`sed` range against a revision that had already moved. This is the r103 LAWS entry *"a bare
line-number citation rots"* failing again inside the round that quotes it. **[O]**

---

## 5. D — r104's round report is a stale frame presented as a verdict

### D1 — the round report's own open-item list contradicts its own claim bullets

**Side A (`r104-report.md:462-466`, "Open items for the L1").**

> 2. **C1 has no "after" at this frame.** Both fixture digests are unchanged from HEAD at `19:20Z`.
> 3. **`GATE_WORKDIR` does not exist, and the round's own harness probes it.** `grep -c` → 0 at 347 lines / sha `577c8b54…`.

**Side B (`r104-report.md:48, :76`, same file, later revision).**

> **C1 (depth) … `LANDED` (R3, concurrent children).** The fix is in `corpus/fixtures/phys3d_joints.gd` — `88be87fa…` → **`c7e77638…`**
> **C2 (coverage) … `LANDED` (`WORK_ROOT`, with up-front validation).** `577c8b54…` → **`15fc46d5…`**

**Verdict: CONFIRMED contradiction, internal.** The report's headline claims were updated after the fix
landed; its open-items list was not. A reader who reads only §"Open items" concludes both claims
failed. r103's own `r103-dissonance.md` §B1–B3 flagged precisely this class (*"three r103 gate
artifacts carry verdicts that the live script has already falsified … each needs a dated supersession
line"*). **[O]**

### D2 — the report pins `15fc46d5…` / 418 lines as the landed C2 gate; the tree is `e5521304…` / 442

**[O]** `:76` and `:146` and `:346` all state `577c8b54… → 15fc46d5…`, **347 → 418 lines**. The live
file is **442** lines at `e5521304…`, and `15fc46d5` is not an object (§B2). The gate moved
`577c8b54 → abebee5c → b6d8c61a → e5521304` (distiller's own sequence at `r104-distiller.md:511`),
none of the intermediates committed. **CONFIRMED.**

### D3 — the report claims "no tracked file is modified"; three are

**Side A (`r104-report.md:20-22`).**

> **No tracked file is modified, staged or deleted** — `git status --porcelain | grep -v '^??'` is empty at every frame this seat measured.

**Side B.** **[O]**

```
$ git status --porcelain | grep -v '^??'
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Verdict: CONFIRMED contradiction.** The claim was true at the seat's frame and false minutes later
when both claims landed. The report's `:24-31` concurrency disclosure covers the churn, so this is a
frame problem rather than dishonesty — but the sentence as written is false at the final frame and is
the kind of line an adjudicator quotes. **[O]**

---

## 6. E — r101–r103 open items dropped or carried without an independent carrier

### E1 — r103's R2 (`mode_ok`/`degraded_cell`) fix has **zero** r104 carriers

**Side A.** `reports/round-103/physics/ledger.md:294-299`:

> **R2 (D2) — make `_finish()` honour `mode_ok`.** Fail the row when any cell reports `mode_ok=0`:
> print `FAIL phys3d_joints <arm> reason=degraded_cell …` and `quit(1)` … this can only turn PASS→FAIL,
> never FAIL→PASS, so it cannot create a false green.

r103's report `:445-447` lists R1/R2/R3/R4 as the operator/lane queue.

**Side B.** **[O]**

```
$ grep -rn 'degraded_cell' reports/round-104/*.md reports/round-104/*/*.md | grep -v scratch
(none)
$ grep -n 'func _finish' -A3 corpus/fixtures/phys3d_joints.gd
110:func _finish() -> void:
111-	print("PASS phys3d_joints %s %s" % [arm, " ".join(_parts)])
112-	quit(0)
```

**Verdict: CONFIRMED — R2 was dropped, not carried.** r104 landed **R3** only (the r103-ruled
preference), which is correct per the ruling. But `mode_ok`/`degraded_cell` appears in no r104 report
except as an incidental observation (`r104-distiller.md:130-147` discusses a *load-sensitive*
`mode_ok=0` and explicitly calls it *"the same phenomenon `ledger.md` §4.2 R2 named"* — naming the
item, not deciding it). The `_finish()` function is byte-unchanged: no guard, no `return`, no dated
entry. R2's own ledger text required *"its own dated entry rather than a silent fold"*. **No entry
exists.** **[O]**

### E2 — r102's O8 (adversarial F3/F5/F6 rulings) is now **three rounds** owed

**Side A.** `reports/round-103/r103-dissonance.md:343-350`: *"`grep -rl 'F5.md\|F6.md'
reports/round-103/ | grep -v consistency.md` → none … **Two rounds carried, still owed**."*

**Side B.** **[O]**

```
$ grep -rl 'F5.md\|F6.md' reports/round-104/ | grep -v scratch
(none — F5/F6 appear only as bare tokens in consistency.md and gate/regression.md)
$ grep -rn 'F3\|F5\|F6' reports/round-104/r104-report.md
(none)
```

`reports/round-104/consistency.md:106` independently marks it **CARRIED (still open)** ⚠️ with the
note *"No r104 artifact records an L1 accept/overrule. Three rounds owed."* **[C]**

**Verdict: CONFIRMED — third round carried, no ruling.** r103's dissonance report asked for this to
be named in the round report's open items; the r104 round report's open-item list does not mention
F3/F5/F6 at all. **[O]**

### E3 — r103's open item 5 (re-run the 12-attack suite against the final bytes) was routed "to close" and closed on a non-existent revision

**Side A.** `reports/round-103/r103-report.md:440-443`: *"the full suite … must be re-run against
`run_gate.sh` sha256 `0c1ca3e1…` **at close** … **Routed to close.**"*

**Side B.** **[O]** r104 `gate/regression.md:162` reports **11/11 DETECTED, 30/30 rows** — but at
revision `b6d8c61a…`, which is not an object (§B2), and the README still says the suite is
**"12-attack"** while both reports say 11/11 (the r102 `A4` contradiction, unchanged). The suite was
re-run, but not against any identity that survives.

**Verdict: CONFIRMED — re-run performed, receipt non-reproducible, and the 11-vs-12 count
contradiction is now three rounds old.** **[O]**

### E4 — the `--path .` fixture-write hazard has no guard, third round named

`reports/round-103/r103-report.md:449-452` (item 11) asked for *"a guard or a convention note"*.
r104 `r104-report.md:488-491` (item 11) states: *"This seat did not observe a recurrence, but no guard
was landed either."* I confirmed no guard: `grep -c 'r90bt' corpus/fixtures/phys3d_joints.gd` shows the
scratch dir is still derived from `res://` with no root pin. **[O]** Named both sides; **open**.

---

## 7. What reproduces (so the failures are calibrated)

| claim | command | result |
|---|---|---|
| upstream pin `a6aa73ad…` is still `main`'s tip | `git ls-remote <url> main` | `a6aa73ad… refs/heads/main`, rc 0 **[O]** |
| manifest 12 files byte-identical | gate CHECK 1 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` **[O]** |
| 13 cards, census 12/1/0, names pinned | gate CHECK 3 | `CARDS=13 … BAD=0`; `NAME_SET=OK NAME_BAD=0` **[O]** |
| `run_battery.py` untouched, 350 rows | `sha256sum` + AST parse | `f456bd00…`, **350** rows **[O]** |
| **C1 fix landed** | `python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <repo-local>` | **`PASS`, `exit=0`, `pass=1 fail=0`** **[O]** |
| **C1 marker byte-identity** | compare emitted line to the `CASES` pin | **3921 bytes, sha256 `706ad9151452e18d`, `BYTE-IDENTICAL True`** **[O]** |
| C1 all-8-rows | `physics/author-runs-all/20261018T192041290482Z` | **8/8 PASS** at `case_timeout_seconds=20` **[O]** |
| **C2 fix landed** | `grep -c 'GATE_WORKDIR\|TMPDIR'` | **13**; `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` at `:59` **[O]** |
| **C2 paired A/B** | default vs `GATE_WORKDIR` | default `rc=2,2,1,1,1`; workdir `rc=0,0,0,0,0` **[O]** |
| C3 `SKILL.md` landed | `wc -l`, `sha256sum` | **174 lines**, `1055a52f…` **[O]** |
| r104 report files | `find reports/round-104 -name '*.md'` (non-scratch) | **22** at `19:25Z` **[O]** |
| no Unreal runtime claim | `which UnrealEditor` | rc 2 (not installed) **[O]** |

**The C1 and C2 claims are substantively correct.** My contradiction findings are about *receipts and
frames*, not about whether the work was done.

---

## 8. Ranked findings for the L1

1. **§A1 — r103's C2 receipt (`0c1ca3e1…` / 341 lines) names a blob that never existed.** Annotate
   with a dated correction naming `577c8b54…` / 347. r103 filed this exact class against r102; it
   recurred. The process fix is the one r103 already wrote: *falsification verdicts must name the
   target's hash* — extend it to *"and the hash must be verifiable with `git cat-file`"*.
2. **§E1 — r103's R2 (`mode_ok` guard) was dropped without the dated entry its own ledger required.**
   Either land it or record a dated waiver. It is the only r103 physics recommendation with zero
   carrier.
3. **§B4/§B5 — the gate can exit 0-bytes/rc=1, and `BLOCKED (network)` is the wrong label for the
   class that actually bit this host.** r104 fixed the reporting (local-resource sub-state) but left
   the README's A4 headline paragraph describing BLOCKED as network-only. Fix the declaration.
4. **§D1/§D2 — the r104 round report's open-items list contradicts its own claim bullets and pins a
   gate revision (`15fc46d5…` / 418) that is neither an object nor the live file (`e5521304…` / 442).**
   Re-sweep at close.
5. **§C1/§C2 — the gate README carries four pointer counts and two scanner shas at the final frame.**
   Retire the literal pin; keep `UNRESOLVED=0` under a named scanner sha. (r103 item 4, re-opened.)
6. **§E2/§E3 — F3/F5/F6 unruled (three rounds), and the 11-vs-12-attack count contradiction is now
   three rounds old.** Both need a ruling, not another carry.
7. **§A2 — r103's `GATE_REF=/tmp/ue-skills-ref` reproduce recipe no longer yields `PASS, rc=0`.**
   The offline path works; the *clone it names* is gone. Re-point the recipe at a clone the reader
   makes.

---

## 9. Limits of this file

- **The tree was live and moving, and both claims landed inside my window.** The gate moved through
  five shas; `phys3d_joints.gd` through two; the gate README through at least three. Every number
  above is stamped with the sha it was measured against; where a value moved, both are given. A
  folding seat must re-derive the final frame rather than quote this file's counts.
- **`/tmp` was under per-user quota pressure throughout** (`df -h /tmp` → 13 G used of 16 G, 80 %,
  while `findmnt -no OPTIONS /tmp` shows `usrquota`). This killed my own first C1 run
  (`OSError: [Errno 122] Disk quota exceeded`) and produced the empty-output flake in §B4. **All my
  gate and battery runs after that point used `GATE_WORKDIR`/repo-local scratch** — which is why the
  §7 C1/C2 results are green and reproducible.
- **Two full-battery after-runs were in flight during my window** and neither produced a `verdicts.json`
  (the 350-row `{{C1_FULL_BATTERY}}` count does not exist yet at `19:26Z`). I did **not** run a full
  battery myself — it is not this seat's and the host was already saturated with several. The 8-row
  and single-row after-receipts in §7 are what I measured directly.
- **`reports/round-104/` reached ~8 600 files** (dominated by `physics/` at 237 MB and `scratch/` at
  3.6 GB), so `find`-based counts move by hundreds per minute. My file counts are point-in-time.
- **This seat wrote only `reports/round-104/r104-dissonance.md`.** Every protected path
  (`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `corpus/fixtures/**`,
  `reports/round-10{1,2,3}/**`, the pinned `upstream/` and `.manifest.d/` trees) was read-only.
- **No Unreal runtime claim is made or implied.** Unreal Editor is not installed on this host; a green
  gate is static evidence only.
