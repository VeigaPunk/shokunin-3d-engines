# r103 · SEAT-35 DISSONANCE — contradictions between r103 artifacts and the r101/r102 record

**Seat:** SEAT-35 DISSONANCE · round 103 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/r103-dissonance.md`). No other file was written or
modified by this seat; no `git commit`/`push`/`checkout`/`reset` was run. All commands read-only.
**Lane HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Probe window:** `2026-10-18T18:31:07Z` → `18:42Z`. **The tree was live throughout.** `reports/round-103/`
grew 2 → 53 files while this seat ran; `gate/run_gate.sh` and `gate/README.md` were rewritten by peers
≥10 times inside the window. Every number below carries the command that produced it and the sha of the
bytes it was taken against; where a value moved, **both** values are given.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed on
this host; live-MCP behaviour is unproven by construction. Everything below is a static/byte/HTTP check.

Tags: **[O]** command run by this seat with output quoted · **[C]** cross-referenced to an r103 seat · **[?]** unresolved.

---

## 1. Headline

Nineteen contradictions in five classes. The load-bearing ones are **A1** and **B6**:

| class | count | meaning |
|---|---|---|
| **A. the r102 report's own numbers never reproduced — even at its landing commit** | 4 | r102 verdict text states a gate sha, a pointer count and a file count the frozen tree does not produce |
| **B. an r103 artifact is contradicted by the tree or by another r103 artifact** | 6 | stale-frame verdicts written mid-rewrite, plus one forward-dated measurement |
| **C. the r103 pointer count is a moving target; any pin is stale within minutes** | 3 | 88 → 101 in ~11 minutes; one transient red |
| **D. r102 open items carried only by the carrier-audit seat itself** | 3 | O4, O6, O8 are named in exactly one file — `consistency.md` — and no independent artifact touches their state |
| **E. r103 artifacts contradict the pinned ledger's framing** | 3 | the battery's 14 reds framed as one class in `LOG.md`/`SCORECARD.md`, corrected only in r103 reports |

**Most consequential finding (A1).** The r102 report pins the gate it landed at
`sha256 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`, 200 lines
(`reports/round-102/r102-report.md:40-41,130`), and the r102 fold-spec repeats that sha
(`reports/round-102/fold-spec.md:33`). **No such blob exists in this repository's history, and neither
does the README sha `def732c9…` the same lines pin.** The gate actually committed at `c6f655d` is
`412d1b84…`, **249** lines; the README is `df2effe9…`, **211** lines. The r102 report's C1(a) receipt
describes bytes that were never committed — a stale mid-draft frame that shipped as a landed receipt.

---

## 2. A — r102 claims that do not reproduce on the frozen tree

### A1 — the r102 gate/README shas and line counts describe a blob that never existed

**Side A (r102 report).** `reports/round-102/r102-report.md:40-42`:

> `gate/run_gate.sh` (200 lines, sha256 `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`) plus its spec `gate/README.md` (199 lines, sha256 `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`)

and again at `:130-131` ("present, 200 lines, sha256 `214bf8ef…411e`" / "present, 199 lines, sha256
`def732c9…7ec8`"). `reports/round-102/fold-spec.md:33` independently pins `214bf8ef…` for the script.

**Side B (frozen tree).** **[O]**

```
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96  -
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/run_gate.sh | wc -l
249
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/README.md | sha256sum
df2effe9bdcbc708703044ef8d3725340114bc2e27fb4705346e69de91c5dc94  -
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/README.md | wc -l
211
$ git cat-file -t 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e
fatal: Not a valid object name …
$ git cat-file -t def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8
fatal: Not a valid object name …
```

A full sweep of every revision's gate blob (`for c in $(git rev-list --all); do git show "$c:…/run_gate.sh" | sha256sum; done | sort -u`) yields exactly two distinct values: `412d1b84…` (the committed r102/r103 file) and the empty-string hash `e3b0c442…` for revisions where the path is absent. **`214bf8ef…` appears nowhere.** Neither does `def732c9…`.

**Verdict: CONFIRMED contradiction.** Both the script sha, the README sha, and both line counts are
wrong; `412d1b84…` is the correct landed identity and r103 artifacts cite it (`reports/round-103/gate/exit-codes.md:7`,
`reports/round-103/gate/clean.md:6`). The r103 seats noticed the *number changed* (`exit-codes.md` §6:
"the file moved after the r102 fold-spec pinned it") and attributed it to drift — but the pinned value
was never a real blob, so this is not drift, it is a **stale-frame receipt that never matched its own
commit**. **[O]**

### A2 — r102 states `POINTERS=40` and the same commit's README pins `87`; the committed gate prints `88`

**Side A (r102 report, `:136` and `:322`).** `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` /
`STEP=PASS`, presented as the check-4 receipt.

**Side A′ (r102 gate README, same commit `c6f655d`, `:118` and `:129`).** **[O]**

```
$ git show c6f655d:corpus/knowledge/unreal-mcp/gate/README.md | grep -n 'POINTERS='
118:**Expected (as measured at r102 close …):** `POINTERS=87 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` …
129:POINTERS=87 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

**Side B (the committed gate, run by this seat on a pristine `git archive`).** **[O]**

```
$ git archive c6f655d | tar -x -C ~/.cache/s35/c6f
$ ( cd ~/.cache/s35/c6f && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E '^POINTERS|^GATE RESULT' )
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**Verdict: CONFIRMED contradiction, three-way.** On one commit the report says 40, its own README says
87, and the gate prints 88. The `40` is the *old* r101-narrow-regex reading (r102 report `:150` admits
it is "the gate's `POINTERS=40`" and treats it as the range-blind count); the README's `87` is a
one-low transcription (r103 SEAT-10 derived it independently — `reports/round-103/gate/clean.md:110-133`,
`40 + 48 = 88`). r103's `docs-sync.md` §2.2 calls `87` "reproducible by nothing". **This is the direct
antecedent of the r103 count chaos in §C.** **[O]**

### A3 — the r102 "58 files at the final frame" claim does not reproduce

**Side A (r102 report, `:414-415`).** "`reports/round-102/` files **58** at the final frame".

**Side B (frozen tree).** **[O]**

```
$ git ls-tree -r c6f655d --name-only reports/round-102 | wc -l
60
$ git ls-tree -r HEAD    --name-only reports/round-102 | wc -l
61
```

**Verdict: CONFIRMED contradiction.** The committed r102 tree carries **60** tracked files at its own
work commit (`c6f655d`) and **61** at HEAD; `58` matches neither. The r103 seats' protected-path audit
measures the same 61 (`reports/round-103/seats-ledger.md:78` → `reports/round-102 identical=61`), so the
discrepancy is in the r102 report, not the tree. Note the *subtree* count in the same sentence ("subtree
files **42**") **does** reproduce (`git ls-tree -r HEAD --name-only corpus/knowledge/unreal-mcp | wc -l`
→ `42`) — one right, one wrong, in the same breath. **[O]**

### A4 — "12-attack suite" (README) vs "11/11 attacks" (report) — the same round's own documents disagree

**Side A (r102 gate README, HEAD `:31`).** "the **12-attack** suite".
**Side B (r102 report, `:425,429`).** "the seat-verified hardened implementation (`/tmp/advgate/hardened.sh`,
which flips **11/11** …)"; "**11/11 attacks DETECTED**, zero false-passes".

**Verdict: CONFIRMED contradiction.** Independently found by r103 `docs-sync.md` §4.2 (which cites the
same pair). Neither number is verifiable now: `/tmp/advgate/` survives but `verify_installed.sh` and
`hardened.sh` do not (`ls /tmp/advgate/hardened.sh` → *No such file or directory*), so the suite that
produced "11/11" cannot be re-run, and r103's own `clean.md` §"Not verified" records the same blocker
(`/tmp` quota killed the `cp -a`). **[O]**

---

## 3. B — r103 artifacts contradicted by the tree or by each other

### B1 — `gate/a3-attack.md` says "the A3 gap, still open" while the live gate has A3 landed

**Side A.** `reports/round-103/gate/a3-attack.md:24` (mtime `15:34:21`): *"That is the A3 gap, **still
open**"*, resting on `grep -c 'EXPECTED_NAMES\|NAME_SET\|declared_names' run_gate.sh` → `0` (`:20`, `:229`).

**Side B (live gate, this seat, 18:41Z).** **[O]**

```
$ grep -n 'PINNED_CARD_NAMES' corpus/knowledge/unreal-mcp/gate/run_gate.sh
41:PINNED_CARD_NAMES='actors-scene animation-controlrig … vfx-niagara-dataflow'
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E '^NAME_SET|^CARDS'
CARDS=13 EXPECTED=13 BAD=0
NAME_SET=OK NAME_BAD=0
```

**Verdict: CONFIRMED contradiction — stale frame.** A3 landed between `15:34` (this file's mtime) and
`15:38` (`docs-sync.md` §0.1 snapshot). `docs-sync.md:45` states the reverse of `a3-attack.md:24`: *"all
four A1–A4 behaviors have now landed in the script"*. The a3-attack file is an honest mid-rewrite frame,
but **it is not annotated as superseded**, so a reader folding r103 sees both "A3 still open" and
`NAME_SET=OK` for the same script. **[O]**

### B2 — `gate/docs-sync.md` contradicts itself: header says "not implemented", §0.1 says "all four landed"

**Side A.** `reports/round-103/gate/docs-sync.md:11-13` (its own verdict line): *"**DOES NOT MATCH on all
four assigned criteria.** A1–A4 are not documented because they are **not implemented** (the installed
gate is byte-frozen at r102)"*.
**Side B.** Same file, `:45-46`: *"**Headline verdict: all four A1–A4 behaviors have now landed in the
script, and the README documents none of them.**"*

**Verdict: CONFIRMED contradiction, internal to one file.** §0 (added later, "The target moved while
this seat measured — read this first") supersedes §1–§2 but the summary at `:11` was not revised. The
substantive claim at `:45` is the correct one (`NAME_SET=OK`, `CHECK 2 BLOCKED`, `exit 2` all present in
the live script — verified in §B1 and §B3 below). **[O]**

### B3 — `gate/a4-attack.md` says "the A4 defect stands exactly as folded" while the live gate implements A4

**Side A.** `reports/round-103/gate/a4-attack.md:15`: *"## Verdict — FALSIFIED. The A4 defect stands
exactly as folded."*, tested against `md5 7a206daa9efe8920a094d62ebbe6fcc9`, **249 lines** (`:5`) — i.e.
the r102-frozen script.

**Side B (live gate, this seat).** **[O]** I pointed `REPO=` at a non-existent repo on a scratch copy of
the **current** script:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh   # REPO=https://github.com/EpicGames/definitely-not-a-real-repo-xyz
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
A4 rc=2
```

**Verdict: CONFIRMED contradiction — stale frame.** The a4-attack file is bound to the *r102* script
(249 lines, pre-A4); the current script has `CHECK 2 BLOCKED` (`:179`) and `exit 2` (`:343`). The
r103 report's own summary records the reverse of a4-attack (`reports/round-103/r103-report.md:336`:
"`BLOCKED`, rc=2; `GATE_REF=/tmp` → `FAIL`, rc=1"). **[O]**

### B4 — the r103 gate README presents three different pointer counts at once

**Side A.** `corpus/knowledge/unreal-mcp/gate/README.md` at sha `2bb22762…`: `:161` → `POINTERS=98`,
`:183` → `POINTERS=98`, `:271` → `POINTERS=91`. Earlier at sha `27f7d809…`: `:129` → 91, `:142` → 90,
`:213` → 91. At the final frame (sha `f3848963…`): `:171` → 101, `:193` → 101, `:279` → 100.

**Side B (the live gate, same frame).** **[O]**

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

**Verdict: CONFIRMED contradiction.** r103's own report flags this as open item 4: *"The README presents
three different pointer counts at once (:129 → 91, :142 → 90, :204 → 91, installed gate → 98). … The
honest fix is one pinned value plus the rule, not three."* The README itself concedes the count is
self-referential (`:157-160`). This is the r102 `40`/`87`/`88` problem (§A2) reproducing in r103. **[O]**

### B5 — the r103 gate README's measurement timestamp is in the future

**Side A.** `corpus/knowledge/unreal-mcp/gate/README.md:171`: *"**Expected (re-measured 2026-10-18T19:00Z**
at lane HEAD `c85a816` …)"*.

**Side B.** **[O]**

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T18:42:18Z
$ stat -c '%y' corpus/knowledge/unreal-mcp/gate/README.md
2026-10-18 15:41:47.147106064 -0300          # = 18:41:47Z
```

**Verdict: CONFIRMED contradiction.** The README, written at `18:41:47Z`, claims its values were
re-measured at `19:00Z` — **18 minutes in the future**. The pinned `POINTERS=101` did happen to match
the gate at `18:42` (§B4), so the *value* is not wrong; the *receipt timestamp* is fabricated. A
forward-dated receipt is exactly the "measurement discipline" failure this round's own §4 exists to
catch, and it is in the file other seats treat as the gate's contract. **[O]**

### B6 — `gate/clean.md` attributes the `87` pin to `c6f655d` while §A1 shows `c6f655d`'s README carries it — but the file's other hash claims are stale

**Side A.** `reports/round-103/gate/clean.md:6` stamps the gate at `sha256 = 412d1b84…`, mtime
`15:15:52`, and `:110-114` says `87` was *"written by the same commit that authored the gate (`c6f655d`,
r102 close, `2026-10-18 15:20:00 -0300`)"*.
**Side B.** **[O]** `c6f655d`'s gate blob is `412d1b84…` (§A1) — consistent — **but** the r102 *report*
and *fold-spec* attribute the gate to `214bf8ef…` (§A1), and `clean.md` does not flag that the two
r102 artifacts disagree with the commit they name.

**Verdict: CONFIRMED contradiction (between clean.md and the r102 report).** clean.md's own numbers
reproduce; the r102 report's do not. clean.md correctly identifies `87` as the r102 README value but
does not carry the finding back to §A1's conclusion — that the r102 report's *identity* receipts were
never real. This is a **carry**, not a defect in clean.md. **[O]**

---

## 4. C — the r103 pointer count is a moving target (and one transient red)

### C1 — I measured six different counts in eleven minutes on a HEAD that never moved

**[O]** `git rev-parse HEAD` → `c85a816…` throughout.

| time (UTC) | gate sha | `POINTERS` | source |
|---|---|---|---|
| 18:31:07 | `412d1b84…` | **88** | `reports/round-103/gate/clean.raw.txt` (mtime 15:31:10) |
| 18:33:29 | `412d1b84…` | **90** | `reports/round-103/gate/clean.now.txt` (mtime 15:33:29) |
| 18:34–18:37 | `412d1b84…` → `0c1ca3e1…` | **91 / 98** | `gate/README.md:129,161` |
| 18:41:07 | `577c8b54…` | **101** | this seat, live |
| 18:41:33 | `577c8b54…` | **101** | this seat, live |
| 18:42:18 | `577c8b54…` | **101** | this seat, live |

**Verdict: CONFIRMED — the count is not a stable quantity.** It is a function of (a) how many prose
files a peer has written into the subtree and (b) which regex the current script uses. `UNRESOLVED=0`
held at every frame. Any r103 verdict that quotes a bare `POINTERS=` without its scanner sha and its
timestamp is quoting an under-specified measurement — the same rule r102 established and r103's own
README now restates. **[O]**

### C2 — I observed the gate flip PASS → FAIL → PASS on the same tree in ~90 seconds

**[O]** At `18:33:12` three consecutive runs printed:

```
MISSING-PATH-REL reports/round-103/note/author.md
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)      rc=1
```

then at `18:33:32` (after the peer's file landed):

```
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)      rc=0
```

**Verdict: CONFIRMED, and correctly diagnosed by a peer.** A C1 seat had written the pointer
`reports/round-103/note/author.md` into `adaptation-kimi.md:372` *before* creating that file. Two r103
seats record the same window (`gate/clean.md:137-162`; `gate/final-run.md:132-156`). This is check 4
working as designed, but it means **two r103 gate transcripts taken minutes apart legitimately disagree
on `POINTERS=` and on `GATE RESULT`** — a reader folding the round must not read the red as a defect. **[O]**

### C3 — a dangling r103 pointer persisted long enough to matter, and the brief's `87` is already stale

**Side A (this seat's brief).** "The gate currently prints `POINTERS=87` and passes clean."
**Side B.** **[O]** At HEAD `c85a816` the gate printed **88** on the pristine committed tree (first
measurement, 18:31:07) and **101** live at 18:42. The brief's `87` is the r102 README pin, not a gate
output.

**Verdict: CONFIRMED — the brief itself carries a stale number.** Same class as §A2. **[O]**

---

## 5. D — r102 open items: what r103 carries, and by whom

The r103 `consistency.md` (SEAT-44) audits all 27 open items and finds **0 "CARRIED (no carrier)"**. That
conclusion is correct **but self-referential**: for three items the *only* r103 carrier is
`consistency.md` itself. Grep, excluding that file:

```
$ grep -rlE "standing harness|reachable from no|writes no receipt" reports/round-103/ | grep -v consistency.md
reports/round-103/r103-connector.md
$ grep -rl "1264\|1410" reports/round-103/ | grep -v consistency.md
reports/round-103/r103-verification-protocol.md
$ grep -rl "F5.md\|F6.md" reports/round-103/ | grep -v consistency.md
(none)
```

### D1 — r102 O4 (gate writes no receipt / reachable from no standing harness) — thin carry

Carrier: `consistency.md:200` (**HALF-ADDRESSED**) and `r103-connector.md:233` (a table row:
"outside every standing harness … 0 hits"). No `--receipt` flag landed, no wrapper consumes the gate.
`reports/round-103/r103-report.md` (the round report) does **not** name O4 in its open-items list
(`:413-440`). `LOG.md`'s ROUTED block does not list it either. **Not silently dropped, but carried by
one audit row and one connector cell only.**

### D2 — r102 O6 (math-audit's 2 WRONG rows) — carried, numbers untouched

`consistency.md:245` marks it **CARRIED** and states its own grep returns 0 carriers. `LOG.md:1356`
routed "math-audit 2 wrong rows (battery-integrity count label, reports-index stale frame)" into r103,
but **no r103 artifact repairs or re-derives either number**: `grep -rn "1410\|1264" reports/round-103/`
returns only `consistency.md:243,247` (the audit restating the carry) and
`r103-verification-protocol.md:530` (an unrelated `~1264` for `npm ci` file counts). The r102
`battery-integrity.md` `1410`-vs-`1264` label and the `reports-index.md` stale frame are **two rounds
old and unaddressed**.

### D3 — r102 O8 (F3/F5/F6 rulings the L1 should rule on) — carried, unruled

`consistency.md:248` marks it **CARRIED**: *"no r103 artifact records an L1 accept/overrule. The r102
adjudication addendum did not rule on them either."* `grep -rl "F5.md\|F6.md" reports/round-103/ |
grep -v consistency.md` → none. `b2/adversary.md:175` re-cites `adversary/F3.md` only as a digest
witness (`scene_graph.mjs` sha cited in 6 files), not as a ruling. **Two rounds carried, still owed.**

**Verdict (D1–D3): not silently dropped, but carried without an independent artifact touching their
state.** The round's carrier-audit is honest; the risk is that a folding seat reads "CARRIED" as
"handled". `consistency.md` itself warns against that (`:31-40`). **[O]**

---

## 6. E — r103 artifacts contradict the pinned ledger's battery framing

### E1 — `LOG.md` and `SCORECARD.md` frame all 14 battery reds as the `r94_cannon` marker class; r103 proves the 14th is a different class

**Side A (pinned ledger — not writable this round).** `LOG.md:1345-1347`: *"Battery r94_cannon markers
pin node=v24.21.0 while the host runs v26.12.0; fresh full runs are red on those rows"*.
`SCORECARD.md:305`: *"a fresh full-battery run state is recorded in the round report (r94_cannon
node-marker drift, routed …)"*.

**Side B (the receipt, re-derived by this seat).** **[O]**

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
> r=d['results']; print(len(r), sum(1 for c in r if c['verdict']=='PASS'))"
350 336
$ python3 -c "…  # the 14 non-PASS rows, by class"
phys3d_joints_free_ops  FAIL  reasons=['TIMEOUT after 20 seconds','no exit code (process killed or timed out)','exact stdout marker missing']  elapsed=20.008  actual_exit=None
r94_cannon_{det,det2,varstep,bailout,nan,sync,material,friction,parity,parity2,modes,order,backends}  FAIL  reasons=['exact stdout marker missing']  elapsed ≤ 1.8  actual_exit=0
```

**Verdict: CONFIRMED contradiction.** The ledger's marker-class framing covers **13 of 14** rows.
`phys3d_joints_free_ops` is a 20-second **TIMEOUT** that *produced its pinned marker* and then did not
exit — a categorically different failure. Independently found and named by r103's `r103-distiller.md` §3
N3 and `physics/investigate.md` (which re-runs it in isolation: ~21–24 s wall vs `CASE_TIMEOUT_SECONDS
= 20` at `run_battery.py:36`, only ~3.5 s CPU → **harness-timeout, not engine behaviour**). The ledger
cannot be corrected this round (`LOG.md`/`SCORECARD.md` are protected); it is a carry, but it is a live
contradiction between the pinned record and the measured receipt. **[O]**

### E2 — the brief's `336/350` reproduces exactly; the brief's "POINTERS=87" does not

**Side A (brief).** "failed the r102 idle run (receipt `…/20261018T181301123479Z/verdicts.json`,
336/350)" and "the gate currently prints POINTERS=87".
**Side B.** **[O]** `336/350` → **exact** (above). `POINTERS=87` → the committed gate prints **88**
(§C3). One reproduces, one does not.

### E3 — `LOG.md`'s dead-root scope "142 files scanned" does not reproduce

**Side A (pinned ledger).** `LOG.md:1356`: *"B2 dead .shokunin root in 3 more runnable READMEs (…)
— systemic ruling, **142 files scanned**"*; `reports/round-102/fold-spec.md:403,415,645` carry `142`.
**Side B.** **[O]**

```
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l     → 167
$ git grep -l "\.shokunin/game-dev-3d" | wc -l          → 164
```

**Verdict: CONFIRMED contradiction.** Found independently by `r103-distiller.md` §3 N4 and
`b2/adversary.md` §2 (`167` at HEAD, `675` lines), and re-verified in `math-audit.md` §7 (rows 90–93
**VERIFIED**). r102's `142` is stale by 25 files on the *same* commit. `LOG.md` is protected, so this
is a carry. **[O]**

---

## 7. What reproduces (so the failures are calibrated)

| r101/r102 claim | command | result |
|---|---|---|
| upstream pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` | gate CHECK 2 | `CLONE_HEAD=a6aa73ad…`, `BLOB_DIFFS=0` **[O]** |
| manifest 12 files byte-identical | gate CHECK 1 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` **[O]** |
| 13 cards, census 12/1/0 | gate CHECK 3 | `CARDS=13 EXPECTED=13 BAD=0`; `CENSUS static-only=12 unproven-runtime=1 verified-here=0` **[O]** |
| battery `336/350` | `json.load(…verdicts.json)` | `350 336` **[O]** |
| subtree 42 files | `git ls-tree -r HEAD -- corpus/knowledge/unreal-mcp \| wc -l` | `42` **[O]** |
| `adaptation-kimi.md` r103 note is +143/−0, additive | `git diff --stat` | `1 file changed, 143 insertions(+)`, no deletions **[O]** |
| the three B2 READMEs repaired | `grep -c 'shokunin/game-dev-3d'` each | glb-r12 **0**, unity-r19 **0**, three **0** **[O]** |
| config.toml `[[hooks]]` at 3290 (brief said ~3219) | `grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml` | `3290:[[hooks]]`; file now 3322 lines **[O]** |
| 4 doc URLs need `/en/` | `curl -o /dev/null -w '%{http_code}'` ×8 | bare **404**, `/en/` **200** for all four **[O]** |
| no Unreal runtime claim | `which UnrealEditor` | rc 2 (not installed) **[O]** |

---

## 8. Ranked findings for the L1

1. **§A1 — the r102 report's gate identity receipt (`214bf8ef…`, 200 lines) is a blob that never
   existed.** This is the round's highest-value dissonance: it means r102's C1(a) receipt — the one the
   r102 verdict rests on — was never true of the commit it names. The r102 verdict should be annotated
   with a dated correction note; the report itself is protected and cannot be edited in place.
2. **§B5 — the r103 gate README's receipt timestamp (`19:00Z`) is 18 minutes in the future.** Fix the
   timestamp (or replace it with the sha+rule, as the round's own open item 4 proposes) before close.
3. **§B4/§C1 — `POINTERS` has moved 88 → 101 in eleven minutes and the README prints three values at
   once.** Retire the literal pin; keep only `UNRESOLVED=0` under a named scanner sha.
4. **§B1/B2/B3 — three r103 gate artifacts carry verdicts that the live script has already falsified**
   (`a3-attack` "still open", `a4-attack` "stands exactly as folded", `docs-sync` header "not
   implemented"). Each needs a dated supersession line, or a folding seat will read them as current.
5. **§D2/D3 — r102 O6 and O8 are two rounds old and still unaddressed**, carried only by the audit seat.
6. **§E1/E3 — the pinned `LOG.md`/`SCORECARD.md` battery and dead-root framings contradict the r103
   measurements** (13-of-14 rows; 142 vs 167). Protected paths → the L1's to correct at close.

---

## 9. Limits of this file

- **The tree was live and moving.** `reports/round-103/` went 2 → 53 files during this seat's window,
  and both gate files were rewritten ≥10 times. Every number above is stamped with the time and sha it
  was measured against; where a value moved, both are given. A folding seat must re-derive the final
  frame rather than quote this file's counts.
- **`/tmp` was under quota pressure throughout** (`df -h /tmp` → 13 G used of 16 G, 80 %), which killed
  one scratch `sort` mid-run and blocked the 11/12-attack suite re-run (`verify_installed.sh` and
  `hardened.sh` are both gone from `/tmp/advgate`). I could not re-run the attack suite; I did re-run
  the A4 attack against the live script (§B3) and the gate itself repeatedly (§C).
- **No Unreal runtime claim is made or implied.** Unreal Editor is not installed on this host; nothing
  here promotes an `unproven-runtime` card, and a green gate is static evidence only.
- **This seat wrote only `reports/round-103/r103-dissonance.md`.** Every protected path
  (`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`,
  `reports/round-101/**`, `reports/round-102/**`, the pinned `upstream/` and `.manifest.d/` trees) was
  read-only.

## 10. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §A1 — the r102 report's gate identity never existed
git show c6f655d:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum   # 412d1b84…, not 214bf8ef…
git show c6f655d:corpus/knowledge/unreal-mcp/gate/run_gate.sh | wc -l      # 249, not 200
git cat-file -t 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e   # fatal

# §A2/§C3 — the committed gate prints 88; README pinned 87; report said 40
rm -rf ~/.cache/s35/c6f && mkdir -p ~/.cache/s35/c6f
git archive c6f655d | tar -x -C ~/.cache/s35/c6f
( cd ~/.cache/s35/c6f && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS )

# §A3 — 58 does not reproduce
git ls-tree -r c6f655d --name-only reports/round-102 | wc -l    # 60

# §B1/B3 — the live gate has A3 and A4 that the attack files call unlanded
grep -c 'PINNED_CARD_NAMES' corpus/knowledge/unreal-mcp/gate/run_gate.sh   # 1
grep -n 'CHECK 2 BLOCKED\|exit 2' corpus/knowledge/unreal-mcp/gate/run_gate.sh

# §B5 — forward-dated receipt
grep -o 're-measured 2026-10-18T[0-9:]*Z' corpus/knowledge/unreal-mcp/gate/README.md   # 19:00Z
date -u +%Y-%m-%dT%H:%M:%SZ

# §E1 — the 14th battery row is a timeout, not a marker drift
python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
r=d['results']; print(len(r), sum(1 for c in r if c['verdict']=='PASS'));
[print(c['case'], c['reasons'], c['elapsed_seconds']) for c in r if c['verdict']!='PASS']"

# §E3 — 142 vs 167
git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l    # 167
```
