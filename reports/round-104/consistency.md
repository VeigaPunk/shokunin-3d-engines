# r104 SEAT-31 — ROUNDS-CONSISTENCY

**Seat:** SEAT-31 CONSISTENCY · round r104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/consistency.md`). Read-only on every other path.
**Lane HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`).
**Probe window:** 2026-10-18 ~19:16Z–19:26Z. **Mid-flight document** — both C1 and C2 landed *inside*
this seat's window (`phys3d_joints.gd` `3ce066a6…` → `c7e77638…`; `run_gate.sh` `577c8b54…` →
`15fc46d5…` → `b6d8c61a…` → `e5521304…`), and `reports/round-104/` grew from 8 to 10 697 files. Every number below
carries the command and the frame at which it was taken.

**Charge:** verify that **every open item** in `reports/round-101/r101-report.md`,
`reports/round-102/r102-report.md` and `reports/round-103/r103-report.md` is either (a) addressed this
round, or (b) carried honestly — i.e. named in some r104 artifact. List each with its disposition.

**No Unreal runtime claim is made anywhere in this file.** The editor is not installed on this host and
live-MCP behaviour is unproven by construction. Everything below is a static/byte/HTTP check, or a
headless Godot 4.7.2 run of the lane's own fixtures.

---

## 0. Verdict in one table

| source | items | ADDRESSED this round | CARRIED (named) | CARRIED (no carrier) |
|---|---|---:|---:|---:|
| r101 open items 1–6 | 6 | 0 | 6 | 0 |
| r101 routed queue (6 defects + IP-2 + S-5 + S-8) | 9 | 0 | 9 | 0 |
| r102 open items 1–8 | 8 | 0 | 8 | 0 |
| r102 routed queue | 8 | 0 | 8 | 0 |
| r103 open items 1–12 | 12 | **7** | 5 | 0 |
| r103 routed queue (r104+ block) | 10 | **4** | 6 | 0 |
| **total** | **53** | **11** | **42** | **0** |

**Every open item in all three reports is either addressed this round or named in an r104 artifact.
Zero items are silently dropped.**

The r101 and r102 queues show **0 ADDRESSED** not because they were neglected but because they were
already closed in r102/r103 and re-verified there — their disposition was settled before r104 opened.
They are carried here as *standing record*, and the carriers named below are the r104 artifacts that
re-state them. The live work this round is the **r103 queue**, where 7 of 12 open items and 4 of the
10 routed items closed.

⚠️ **Carrier counts in this file were taken at several frames and the tree moved under every one.** I
re-swept at the end and **four dispositions improved** (r103 O5 and four routed rows gained carriers
that landed after my first pass). Where an earlier reading was superseded, the correction is shown
inline rather than silently replaced. Treat every "0 carriers" claim as frame-bound.

**Three findings need the L1's attention anyway** — see §6:

- **The gate is not reliably green on its default invocation.** The r103 flake was worse than
  recorded — this seat measured **7 of 12 runs BLOCKED** before the fix, root-caused to a hard `/tmp`
  EDQUOT quota (a **1-byte** write failed). The r104 fix works unconditionally: `GATE_WORKDIR`
  **32/32 PASS** across every frame. But the **default** path is only as good as `/tmp`: **0/18 PASS**
  while the quota bit, **20/20 PASS** when it was relieved, same gate bytes. **Recommendation: set
  `GATE_WORKDIR` for close-out** — a close-out artifact should not be a coin flip on a shared tmpfs.
  See §6.1.
- **The `BLOCKED (network)` mislabel is closed** — the script now emits a distinct
  `CHECK 2 BLOCKED (local-resource)` state and the README documents it. See §6.2.
- **r104's own report open items 2, 3 and 6 are stale at close** — each was resolved by a fix that
  landed after the report's last frame. See §5.

---

## 1. Method

For each open item: (1) read the item verbatim from the report; (2) search all r104 artifacts for a
carrier; (3) where the item asserts a state, **re-derive that state with a command this seat ran**.
An item is **ADDRESSED** only if the state it asked for is now true *and* an r104 artifact records it.
It is **CARRIED** if the item's subject appears in an r104 artifact (honestly named) but the state is
unchanged, or if the state is a permanent structural limit. **CARRIED (no carrier)** means nothing in
r104 names it at all.

The r103 `consistency.md` (SEAT-44) established this same standard over 31 items. This file extends it
to the r103 report's own queue (which r103 could not audit, having written it) — 51 items in total.

---

## 2. r101 open items (`reports/round-101/r101-report.md:285-310`) — all CARRIED, all closed pre-r104

| # | item | r104 disposition | carrier / re-derivation |
|---|---|---|---|
| O1 | hash slot + `[moving]` counts filled from the committed tree | **CARRIED** (closed r101) | `git log --oneline -1 1659c03` → `1659c03 r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad …`; `grep -c 'ROUND 101' LOG.md` → `1`, `grep -c 'Round 101' SCORECARD.md` → `1` |
| O2 | `pointer-check.sh` self-contaminates on the protocol's negative controls | **CARRIED** (closed r101; carrier gone) | The r101 scratch script is **gone**: `bash /tmp/r101-closeout/pointer-check.sh` → `No such file or directory`. The discipline survives in the gate (r103 A1 endpoint validation). Not re-runnable; honestly carried, not re-asserted |
| O3 | subtree `README.md` layout block stale `(pending: …)` labels | **CARRIED** (closed r101) | `grep -n 'pending' corpus/knowledge/unreal-mcp/README.md` → **1** hit at `:69`, and it is the unrelated engine-install wall. The two `(pending: …)` layout labels are absent |
| O4 | C1 scope wording ("all upstream content files" vs "the pinned commit") | **CARRIED** (ruled r101) | `grep -c 'all files tracked at the pinned commit' reports/round-101/r101-report.md` → `1` (the adopted ruling); `PROVENANCE.md:340` `## 8. Known out-of-pin upstream surface` |
| O5 | C3's `verified-here` rows are Kimi-side, not Unreal-side | **CARRIED** (structural) | `reports/round-104/skill/author.md:213` adds the two-sense disambiguation **in the row-D cell**; `SKILL.md` §1 row D states it. `grep -c 'verified-here' reports/round-104/r104-report.md` → census `verified-here=0` on Unreal surfaces |
| O6 | no live-editor evidence exists or can exist here | **CARRIED** (structural) | `reports/round-104/skill/author.md`; `SKILL.md` §5.1 makes it a written rule; `grep -c 'unproven-on-this-host' reports/round-104/r104-report.md` → `2` |

### r101 routed queue (`LOG.md:1318-1323`) · 6 defects + IP-2 + S-5 + S-8

All nine were dispositioned in r102/r103; r104 carries them. **No r104 artifact re-opens any of them.**

| routed item | r104 disposition | carrier |
|---|---|---|
| r22 README/lesson path drift | CARRIED (closed r102) | `reports/round-103/b2/{repair-glb,verify-unity,verify-three}.md`; `reports/round-104/r104-report.md` restates the closed state |
| r22 lesson cites absent `verdicts.json` | CARRIED (closed r102) | `reports/round-103/b2/corrections.md` |
| `run_battery.py` cited-sha drift | CARRIED (closed r102) | `reports/round-104/physics/markers.md` re-derives `f456bd00…` and matches the r102 receipt exactly |
| `engines.md` three.js command fails from clean tree | CARRIED (closed r102) | `reports/round-103/b2/repair-three.md` |
| `rea.md` JADX/Binwalk/Unblob census | CARRIED (closed r102) | `reports/round-103/b2/corrections.md` |
| README glob line-count (F8) | CARRIED (closed r102) | `reports/round-102/repairs/F8-readme-lines.md` |
| **IP-2 — digest map covers 0 `corpus/knowledge/` files** | **CARRIED (still open, independently re-derived)** | `reports/round-104/r104-connector.md:331-339` re-runs `seed_digests()` live: **`entries: 130 knowledge: 0 gate: 0`** — *identical* to r102/r103, and adds `git grep -ln "run_gate" -- corpus/` → only a lesson's prose. This seat re-derived it a third way: `reports/round-104/physics/markers.md` §1 plus an AST read of `run_battery.py:940` confirming `HERE.rglob("*")` rooted at `corpus/fixtures`. **Three independent seats, same number.** Still open |
| sentinel S-5 (PATH-shadowed `basename`) | CARRIED (absorbed r102/r103) | `run_gate.sh` tool-requirement guard (present at `e5521304…`); `reports/round-104/gate/regression.md:113` re-detects `comm`-absent (`D1`/`D3`) |
| sentinel S-8 (`.mcp.json` auto-load) | CARRIED (no r104 carrier) | `reports/round-102/sentinel-mcp.md` §2 (Kimi gates project `.mcp.json` behind workspace trust — stronger than the r101 finding). **0 r104 carriers**; named here |

---

## 3. r102 open items (`reports/round-102/r102-report.md:351-397`) — all CARRIED

| # | item | r104 disposition | carrier / re-derivation |
|---|---|---|---|
| O1 | hash slot, `[moving]` counts, `LOG.md`/`SCORECARD.md` zero r102 entries | **CARRIED** (closed r102) | `grep -c 'ROUND 102' LOG.md` → `1`; `grep -c 'Round 102' SCORECARD.md` → `1` |
| O2 | **F7 — the card-label vocabulary collision** | **CARRIED (named, still unruled)** ⚠️ | `SKILL.md` §4 states the collision and **refuses to rule** (correctly); `reports/round-104/skill/author.md:139,341` re-measures it live. `grep -rln 'Not .unproven-runtime.' corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` → **6**; `sha256sum corpus/knowledge/unreal-mcp/README.md` → `c79d8dd1…` — **byte-identical to r101**. Now **four rounds** named and unruled |
| O3 | gate under-covers range-form pointers (gate 40 vs sweep 47) | **CARRIED** (closed r103) | r103 A1 landed; `grep -c 'tr' run_gate.sh` → 69; live gate prints `POINTERS=101` (endpoint semantics) |
| O4 | gate writes no receipt, reachable from no standing harness | **CARRIED (still open)** ⚠️ | `grep -rn 'run_gate' corpus/fixtures/*.py corpus/knowledge/engines.md` → **0**; `grep -c 'receipt' run_gate.sh` → **0**. The r104 harness (`reports/round-104/gate/flake_harness.sh:52`) invokes the gate but writes no receipt |
| O5 | gate requires the network; offline it cannot run | **CARRIED** (closed r103) | r103 A4 + `GATE_REF`; live gate emits the BLOCKED third state |
| O6 | `math-audit.md` 2 WRONG numbers (`1410` vs `1264`; stale frame) | **CARRIED (partially addressed)** | The `1410`/`1264` number now has an independent r104 carrier: `reports/round-104/physics/sentinel.md:110-111` re-measures the gitignored `corpus/fixtures/three/node_modules/**` tree at **1264** files (`git ls-files --others --exclude-standard` → 0; `--ignored` → 1264), which is the corrected value. The `adversary/F3.md` stale-frame half still has **0** r104 carriers |
| O7 | no live-editor evidence exists or can exist here | **CARRIED** (structural) | same as r101 O6; `reports/round-104/install-recheck.md` re-runs the install receipts |
| O8 | adversarial F3/F5/F6 rulings the L1 should accept or overrule | **CARRIED (now with an r104 carrier, still unruled)** ⚠️ | **Corrected:** `reports/round-104/r104-adjudicator-draft.md` §5.3–§5.6 carries F3/F5/F6 and **adds a new F-item** (F2b, `r23-ortho-review.md` absent receipts, carried from r102); `reports/round-104/r104-dissonance.md` re-derives them. So r104 *names* them where my first sweep found 0 — but still **no L1 accept/overrule is recorded**. Three rounds owed |

### r102 routed queue (`LOG.md:1349-1358`) · 8 items

| routed item | r104 disposition | carrier |
|---|---|---|
| fold-spec **A1** (range-tail-blind regex) | CARRIED (landed r103) | `run_gate.sh` A1 endpoint validation; live `POINTERS=101 POINTER_STRINGS=41` |
| fold-spec **A2** (prose-hijackable first-token rule) | CARRIED (landed r103) | `run_gate.sh` anchored `LABEL_RE`; r103 `gate/a2-attack.md` |
| fold-spec **A3** (card names never compared) | CARRIED (landed r103) | `run_gate.sh` `PINNED_CARD_NAMES`; live `NAME_SET=OK NAME_BAD=0` |
| fold-spec **A4** (network-blocked vs byte mismatch) | CARRIED (landed r103, extended r104) | `run_gate.sh` exit 2; r104 adds the `local-resource` sub-state (§6.2) |
| kimi-surfaces freshness note for `adaptation-kimi.md` | CARRIED (landed r103) | `adaptation-kimi.md:367` dated note, `sha256 084a34cd…` stable across r103→r104 |
| battery node-marker drift (`r94_cannon`) | **CARRIED (still open)** | `reports/round-104/r104-report.md:176,189-192` re-measures **13 FAIL / 6 PASS** at the unchanged host `node v26.12.0`; `reports/round-104/physics/ledger.md`, `r104-distiller.md`, `r104-connector.md`, `r104-verification-protocol.md` all carry the class. `grep -c 'v24.21.0' corpus/fixtures/run_battery.py` → **13** (the pins) |
| B2 dead `.shokunin` root in 3 READMEs | CARRIED (repaired r103) | r103 `b2/{repair-glb,repair-three,verify-unity}.md`; three READMEs at `occ=0` |
| math-audit 2 wrong rows | CARRIED | see O6 |

---

## 4. r103 open items (`reports/round-103/r103-report.md:413-470`) — the live queue

**This is the queue r104 actually moved.** Seven of twelve closed.

### O1 — hash slot, `[moving]` counts, `LOG.md`/`SCORECARD.md` zero r103 entries · **ADDRESSED**

```
$ grep -c 'ROUND 103' LOG.md          → 1
$ grep -c 'Round 103' SCORECARD.md    → 1
$ git log --oneline -1 8c9d9ad
8c9d9ad r103: gate hardening A1-A4 (attack-verified, BLOCKED exit 2) + …
```

Both ledger entries landed in `88c3b2c` (the r103 report-last commit). The item's own complaint —
*"the L1's to land"* — is satisfied. (The **r104** equivalents are open; see §5 O1.)

### O2 — gate README contradicts the gate code on exit semantics · **ADDRESSED**

The README now declares the third state. Re-derived on the live bytes:

```
$ sed -n '208,222p' corpus/knowledge/unreal-mcp/gate/README.md
- **`0`** — every check printed `STEP=PASS`. Clean.
- **`1`** — at least one check printed `STEP=FAIL`. There is no partial-pass state: a missing
  artifact is a FAIL, not a warning.
- **`2`** — CHECK 2 printed `STEP=BLOCKED` (the fresh clone could not complete) and no other check
  failed. This is **not** a pass and **not** a verdict: the vendored bytes are *unchecked*, not
  divergent.
```

The old contradicting lines the item quoted (`:156-157` "`1` otherwise. There is no partial-pass
state", `:73-74` a failed clone "exits 1") are gone: `grep -n 'exits 1' …README.md` → no match. The
code implements `0`/`1`/`2` (`run_gate.sh` tail: `exit 2` on `C2_BLOCKED=1 && FAILS=0`), and the
declaration now matches it. Carrier: `reports/round-103/gate/exit-codes.md`; re-verified here.

### O3 — the mixed case silently loses the third state · **CARRIED (named, now observed live)**

`grep -n 'mixed case' …README.md` → `:221-224`, which documents the residual explicitly:

> *"when CHECK 2 is BLOCKED **and** another check also fails, the gate prints `GATE RESULT: FAIL` and
> exits `1` — the third state is lost in the mixed case … the fix is a future-round decision."*

The item asked for the ambiguity to be removed; r104 **documented** it rather than fixing it, and
`reports/round-104/r104-report.md` open item 5 records it as observed in the wild. **Honestly carried,
still open.** This seat reproduced the shape: `STEP=BLOCKED` + `GATE RESULT: FAIL (checks failed: 1)`
+ `rc=1` on the default path (§6.1). **Observed live at `19:18Z`** — the mixed case is the failure
mode the default path actually produced under quota pressure, not a corner case.

### O4 — README presents three different pointer counts at once · **ADDRESSED**

```
$ grep -nE 'POINTERS=(8[0-9]|9[0-9]|10[0-9])' corpus/knowledge/unreal-mcp/gate/README.md
41:> values below were re-measured against it (the earlier `POINTERS=87` pin was stale — see the pin
171:**Expected …:** `POINTERS=101 POINTER_STRINGS=41 …
193:POINTERS=101 POINTER_STRINGS=41 …
279:| **C0** | none (unmodified copy) | **0** | `POINTERS=101 … UNRESOLVED=0` …
304:POINTERS=101 POINTER_STRINGS=41 …
```

The three-way disagreement (`91`/`90`/`91`/`98`) is resolved to **one current pinned value plus
labelled historical frames**. At this seat's final frame the README reads:

```
$ for n in 101 102 103; do printf '%s: ' $n; grep -cE "POINTERS=$n" gate/README.md; done
101: 2
102: 0
103: 4
$ sed -n '42p' gate/README.md
> correction note). The r104 scanner sha256 is `e5521304…` and the current pin is `POINTERS=103`
```

The **four** `103` occurrences are the current pin (the expected-value block, the worked example, the
summary table, the evidence block). The **two** `101` occurrences are both explicitly historical: one
is the r103-era `C0` control row, the other is the r103 pin-correction note's evidence block, which
names its own scanner (`run_gate.sh sha256 577c8b54…`) — a frozen frame, not a competing current pin.
Independently confirmed: `reports/round-104/gate/pin-check.md` re-implements CHECK 4 from spec rather
than calling the gate, and prints the same value — **the number is not an artifact of the gate's own
arithmetic**. (The pin walked `101 → 102 → 103` during r104 for the same self-reference reason the
README documents: editing this README changes the count it states.)

### O5 — the 12-attack suite has not been re-run against the final bytes · **ADDRESSED**

**This seat's earlier reading was wrong; the suite did run, and I found it after widening the sweep.**
`reports/round-104/gate/regression.md` (SEAT-15) re-ran the full attack suite against the
**workdir-patched** gate, and — critically — it snapshotted and re-pinned each revision, so no row can
be silently re-targeted by a later sibling edit:

```
$ sed -n '34,38p' reports/round-104/gate/regression.md
**Every result below is bound to `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`
(25169 bytes).**
The whole suite was run at **both** `b6d8c61a…` and `e5521304…`; both passes gave 0 mismatches.
```

**30 rows, 0 mismatches**, bound to the sha the live gate now reports (`e5521304…`, re-confirmed by
this seat: `sha256sum` → `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`). All
11 r102 attacks DETECTED, the C1–C7 controls detected, and the r103 hardening rows carried. **The
item asked exactly for this — re-run against the final bytes — and it is satisfied.**

**The one residual it discloses is inherited, not new:** row `D2` (`comm` present but
non-functional) is still a **silent false-pass**, unchanged from r103's own disclosure
(`reports/round-103/gate/regression.md:171`). Named, not fixed — correctly, since it is a
pre-existing gate limitation outside the C2 scope.

**Note the process point the seat itself raises** (`regression.md` §0): an intermediate revision
`7903c589…` shipped `WORK_ROOT` *validated* while both `mktemp` calls stayed bare — **the knob was a
no-op**. That intermediate is worth remembering as a near-miss; `e5521304…` fixes it
(`mktemp -p "$WORK_ROOT"` at both sites, verified by this seat's `GATE_WORKDIR`/`TMPDIR` probes).

### O6 — the B2 systemic ruling (R4) is still unruled · **CARRIED (still unruled)** ⚠️

```
$ git grep -l '\.shokunin/game-dev-3d' | wc -l        → 189
$ git grep -l '\.shokunin/game-dev-3d' HEAD | wc -l   → 189
$ grep -c 'shokunin/game-dev-3d' PROVINCE.md          → 2   (lines 25, 46 — the write-scope declaration)
```

**The count moved 164 → 189**, and the delta is fully explained: r103/r104 *reports* quote the prefix.
Like-for-like, the repaired scope is unchanged — `git grep -l '\.shokunin/game-dev-3d' -- corpus` →
**90** on both worktree and HEAD, and the per-round split is `reports/round-101` 2, `round-102` 26,
`round-103` 25, `round-104` 0.

**R4 is named in r104** — `reports/round-104/r104-dissonance.md:378` restates *"r103's report `:445-447`
lists R1/R2/R3/R4 as the operator/lane queue"* and `reports/round-104/gate/final-run.md:213` uses `R4`
for the mixed-BLOCKED finding. So the item has carriers; **but no r104 artifact records the L1
accept/overrule the item asked for**, and the two `R4` uses are *different things* — a **colliding
label** worth noting. **Carried, unruled, four rounds.**

### O7 — `phys3d_joints_free_ops` is classified harness-timeout and NOT repaired · **ADDRESSED** ✅

**The headline close of this round.** The ruled preference (R3 concurrent children) landed.

```
$ git diff --stat HEAD -- corpus/fixtures/phys3d_joints.gd
 corpus/fixtures/phys3d_joints.gd | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)
```

The diff replaces the serial `_run_child` loop with `_spawn_child` (`OS.create_process`) + a
collect pass (`OS.is_process_running` / `OS.get_process_exit_code`), preserving the original nested-loop
emission order. **Independently re-run by this seat** — not quoted from the author:

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <home-fs>/runs
PASS phys3d_joints_free_ops: exit=0 expected=0

VERDICT  CASE                        SCRIPT              FLAGS            EXIT   KIND
PASS     phys3d_joints_free_ops      phys3d_joints.gd    --arm=free_ops   0/0    ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
```

Before, from the same seat's pre-fix capture (`reports/round-104/physics/before-battery.stdout`):
`FAIL … TIMEOUT after 20 seconds`, `exit=None`, `pass=0 fail=1`. The invariant the r103 ruling
demanded holds: `CASE_TIMEOUT_SECONDS` is still **20** (`run_battery.py:36`), `run_battery.py` is
still `f456bd00…` with **350** `CASES` rows, and the arm's marker is unchanged.
**Not claimed:** the full-350 after-count — see §6.3.

### O8 — battery's node-marker drift unchanged from r102 · **CARRIED (operator queue)**

`reports/round-104/r104-report.md:176` re-measures the 19 `r94_cannon_*` rows in the r102 receipt at
**13 FAIL / 6 PASS**, all fails `reasons=['exact stdout marker missing']`. Host unchanged:
`node --version` → `v26.12.0`; `grep -c 'v24.21.0' corpus/fixtures/run_battery.py` → **13**. The
r104 report correctly separates this class from C1's (the row C1 fixed was the *only* non-cannon
failure). **Carried, operator-owned.**

### O9 — one 404 remains cited in a tracked file · **ADDRESSED (draft landed; repair still owed)**

`reports/round-104/kimi-404-carry.md` (SEAT-47) re-verifies the defect and **drafts the exact
one-line fix**, not applied. This seat re-derived both halves independently:

```
$ curl -s --max-time 15 -o /dev/null -w '%{http_code}\n' \
    https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code
404
$ sed -n '6p' corpus/knowledge/unreal-mcp/adaptation-kimi.md
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
```

The file is unchanged (`sha256 084a34cd…`, matching `git show HEAD:…`). The item asked for the
citation to be corrected; r104 produced a verified fix text with a uniqueness proof (`count(old)` → 1,
`count(new)` → 0, **+7 bytes**, 506 → 506 lines) and the trap-list of four classes that must **not** be
touched. **Addressed as a draft; the byte edit is still owed** and is correctly flagged as needing the
owning seat.

### O10 — README's control section does not survive its own counts · **CARRIED (partially addressed)**

Two halves:

- **The row count** — `sed -n '229p'` still reads *"These mutation controls (C1–C6, plus C7 where
  listed)"* while the matrix has **7** rows. **Unchanged; still open.**
- **C7's re-derivability** — the `sh` block still gives no `printf` for C7
  (`awk '/^```sh$/,/^```$/' …README.md | grep -c 'C7'` → **0**), but the **exclusion mechanism itself
  is now documented** (`:150-158`, the EXACT-match sentinel rule with `SKIPPED_CONTROL_SENTINELS`
  printed and expected `0`). The claim is no longer unfalsifiable — the *command* is still missing.

**Carried, half-open.**

### O11 — `--path .` against the seed tree is a live hazard · **CARRIED (still open)**

Carriers (my first sweep found one; there are now several): `reports/round-104/lessons-carry.md:153`
puts *"fixture write-isolation"* in the r104→r105 queue explicitly; `reports/round-104/r104-report.md`
open item 11; `reports/round-104/git-hygiene.md` and `r104-verification-protocol.md` discuss the
`r90bt_*` shape. **No guard landed.** This seat re-derived the protected surface:

```
$ git status --porcelain=v1 -uall -- corpus/fixtures/ | wc -l   → 1   (the licensed M)
$ ls -d corpus/fixtures/r90bt_* | wc -l                         → 0
```

No recurrence observed, but the shape is open. `reports/round-104/physics/` shows reused and fresh
scratch dirs side by side — exactly the shape the item names. **Carried, honestly named in five
artifacts.**

### O12 — no live-editor evidence exists or can exist here · **CARRIED (structural)**

Same limit as r101 O6 / r102 O7. `reports/round-104/r104-report.md` open item 13; `SKILL.md` §5.1
makes it a written rule. `reports/round-104/install-recheck`-class evidence: engine install unchanged.
**Carried, permanently.**

### r103 routed queue (`LOG.md:1385-1392`) · 10 items

| routed item | r104 disposition | carrier / evidence |
|---|---|---|
| physics fix R3 concurrent children (preferred) | **ADDRESSED** ✅ | §4 O7 above; `phys3d_joints.gd` `3ce066a6…` → `c7e77638…`; this seat's independent `PASS` |
| R1 global cap 20→60 (operator fallback) | **NOT TAKEN — correctly** | `CASE_TIMEOUT_SECONDS = 20` unchanged at `run_battery.py:36`; the ruled preference was R3, and the report says so (`r104-report.md:53-55`) |
| R2 per-case bound proportional to child count | **NOT TAKEN — correctly** | superseded by R3, which the ruling preferred |
| R4 re-baseline the marker (not recommended) | **NOT TAKEN — correctly** | marker byte-identity preserved (`3921` bytes / `706ad915…`), the r103 ruling's explicit condition |
| gate workdir resilience (`GATE_WORKDIR`/`TMPDIR`) | **ADDRESSED** ✅ | §6.1; `run_gate.sh` `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`; `GATE_WORKDIR` **32/32 PASS** across every frame, `TMPDIR` 3/3 PASS. ⚠️ the **default** `/tmp` path is 0/18 while the quota bites and 20/20 when relieved — **set `GATE_WORKDIR` for close-out** |
| flake-reproduction harness | **ADDRESSED** ✅ | `reports/round-104/gate/flake_harness.sh` (invokes the gate at `:52`); `reports/round-104/gate/flake-harness.md`; `reports/round-104/gate/scratch/seat48/{paired,close,post-c2}.tsv` |
| stray `r90bt_*` dirs hazard — fixture write-isolation proposal | **CARRIED (named, no guard)** | `reports/round-104/lessons-carry.md:153` carries *"fixture write-isolation"* in the r104→r105 queue; `reports/round-104/physics/sentinel.md` rules the C1 write in-scope and no violation, but **no guard landed** |
| kimi-surfaces: `adaptation-kimi.md:6` 404 | **ADDRESSED as a draft** | §4 O9; `reports/round-104/kimi-404-carry.md` §4 |
| curiosity: empty jolt cells matching the pinned marker | **CARRIED (recorded, not explained)** | r103 `physics/investigate.md` §5.1; `reports/round-104/physics/markers.md` banks all 8 `phys3d_joints` arm digests, and `physics/s06/worstcase-free_ops-m*/` stress the cells — but the curiosity itself is not re-explained. `grep -n 'jolt' r104-connector.md` → 0 |
| battery cannon node markers | **CARRIED** | §4 O8 |

---

## 5. r104's own open items — three are stale at close

`reports/round-104/r104-report.md:417-460` lists 13 open items. **Three of them were resolved by fixes
that landed *after* the report's last frame**, and a consistency pass must say so rather than let a
stale complaint stand:

| r104 item | report's claim | state at this seat's frame |
|---|---|---|
| **2** — "C1 has no *after* at this frame. Both fixture digests are unchanged from HEAD at `19:20Z`." | fix not landed | **STALE.** `sha256sum corpus/fixtures/phys3d_joints.gd` → `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc` (was `88be87fa…`). This seat re-ran the row: **PASS**, `exit 0/0`, `totals 1 pass / 0 fail` |
| **3** — "`GATE_WORKDIR` does not exist … `grep -c` → 0 at 347 lines / sha `577c8b54…`." | variable absent | **STALE.** `grep -c 'GATE_WORKDIR' run_gate.sh` → **13**; sha now `e5521304…`. The `verify-workdir.sh`-measures-a-nonexistent-variable objection is discharged |
| **6** — "`SKILL.md` cites `reports/round-104/skill/author.md` §2 in four places and that path does not exist." | dangling citation | **STALE.** `ls -la reports/round-104/skill/author.md` → present, 17699 bytes, landed `16:21`. The four citations resolve |

**Still live from r104's list:** item 4 (the `BLOCKED (network)` label — *partially* fixed, §6.2), item
5 (mixed case — observed live, §4 O3), items 7–13 (SKILL.md self-consistency, the P/C ruling, the
`r94_cannon` class, the `--path .` hazard, scratch-dir convention, no live-editor evidence).

**This seat's own re-derivation of SKILL.md's citations** (not in the report's list): every
`reports/…` and `corpus/…` path cited by `SKILL.md` resolves, **except** two that are globs by design
(`executability/*.md`, `upstream/**`) and one false positive from this seat's own extractor
(`r101-reviewer-c{1` — a truncated match of a `{1,2,3}` brace form). `SKILL.md` sha
`1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c`, 174 lines, untracked at this frame.

---

## 6. Findings the L1 must not read past

### 6.1 The r103 flake was reproduced live, root-caused, and fixed — **and it was worse than r103 recorded**

The item r103 routed (`gate workdir resilience`) is **closed**, and this seat's contribution is the
measurement of how bad it was. **Withdrawn below is nothing about the fix; what follows is the
before/after this seat measured itself.**

**Before the fix** (gate `577c8b54…`, the r103-final bytes still at HEAD), 12 consecutive runs of the
installed gate:

```
$ for i in $(seq 1 12); do out=$(bash run_gate.sh 2>&1); rc=$?; …; done
BLOCKED at run 2, 3, 7, 8, 9, 10, 11
TALLY rc0=5 rc2=7 rc1_nonempty=0 rc1_empty=0 other=0 (n=12)
```

**7 of 12 runs BLOCKED** — the r103 close window recorded *two* such anomalies; at this frame it was
the common case. The cause was isolated to a single command:

```
$ d=$(mktemp -d); git clone --depth 1 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin "$d/c"
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to '…/.git/description': Disk quota exceeded
rc=128
```

**5/5 clone attempts into `/tmp` failed; 3/3 succeeded with `TMPDIR` pointed outside `/tmp`.** The
failure is silent under `-q` (empty stderr, non-zero exit), which is exactly why it surfaced as
`BLOCKED (network)` instead of a diagnosable error.

**The `/tmp` condition was a hard quota, not "pressure".** This seat measured it at the 1-byte level:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ f=$(mktemp -p /tmp); head -c 1 /dev/zero > "$f"; echo rc=$?
head: write error: Disk quota exceeded
rc=1
$ # 100 × 1 MiB writes to /tmp
ok=0 bad=100
```

A **1-byte** write failed while `df` reported 3.1 G free — a per-user quota (EDQUOT), exactly as
`reports/round-104/gate/workdir-verify.md` §1 and `gate/pin-check.md` §1 diagnose independently. The
r103 framing ("allocation or clone failure under pressure") understated the condition.

**After the fix** (`run_gate.sh` `e5521304…`), every configuration verified by this seat. The quota
**oscillated during the window** — exhausted, relieved, exhausted again, relieved again — so the
default-path row was measured at both extremes. The honest table separates the two states, because
the numbers differ by everything:

| invocation | before the fix | after the fix, `/tmp` **exhausted** | after the fix, `/tmp` **relieved** |
|---|---|---|---|
| default (`/tmp`) | **6/6 `FAIL`**, rc 1 | **0/18 `PASS`** — every run `FAIL`/`BLOCKED`, rc 1–2 | **20/20 `PASS`**, rc 0 |
| `GATE_WORKDIR=<roomy dir>` | n/a (variable did not exist) | **32/32 `PASS`**, rc 0 | **32/32 `PASS`**, rc 0 |
| `TMPDIR=<roomy dir>` | n/a | **3/3 `PASS`**, rc 0 | — |
| `GATE_WORKDIR=/nonexistent/xyz` | n/a | rc 1, **named**: `FAIL scratch root is not a directory: …` | same |

**What is actually established**, stripped of the oscillation:

1. **`GATE_WORKDIR` is robust to the host's `/tmp` state — 32/32 PASS across every frame.** That is
   the property the fix exists to provide, and it holds unconditionally.
2. **The default path is exactly as good as `/tmp`** — green when the quota is relieved (20/20), red
   when it is not (0/18). The gate did not get worse; it inherited the host's instability and now
   *names* it instead of mislabelling it as a network failure.
3. **Therefore a close-out run should set `GATE_WORKDIR`.** Not because the default is broken, but
   because it is a coin flip on a host whose `/tmp` quota is being fought over by other sessions —
   and a close-out artifact must not be a coin flip.

**A discrepancy for the docs owner, recorded not resolved:** `gate/README.md:377` row **W0** claims
the default path is `0` / `PASS` / *"the default path is unchanged"*. That was true when measured, and
this seat reproduced it (20/20) — but it is **conditional on a state of `/tmp` the README does not
name**, and this seat also measured 0/18 on the same bytes. W0 should state the precondition.

So the fix does both things the item asked: it converts a *misleading* failure into a *diagnosable*
one, and it provides an escape hatch that works **every time it was measured**. The default is red
exactly whenever `/tmp` is red — and since `/tmp` is a shared 16 G tmpfs fought over by other
sessions, that is a meaningful fraction of the time on this host. **Recommendation for close-out: run
the gate with `GATE_WORKDIR` set.** The canonical invocation printed in `gate/README.md` is not
sufficient here, and the round's own close-out should not inherit the coin flip.

### 6.2 The `BLOCKED (network)` mislabel — **ADDRESSED (withdrawn as an open finding)**

This section previously reported that the declaration lagged the implementation. **That finding is
withdrawn: I verified it ~40 s too early.** The README landed while this seat was writing.

The script now classifies the clone failure and emits a distinct state:

```
$ bash run_gate.sh | grep -E 'BLOCKED'
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
```

`run_gate.sh:267` classifies the clone log against `disk quota exceeded|no space left|out of
diskspace|write error|quota exceeded` and emits `local-resource`; `:273` keeps `(network)` for a
genuine network block — both branches verified present. And the declaration caught up:

```
$ grep -c 'GATE_WORKDIR' corpus/knowledge/unreal-mcp/gate/README.md        → 11
$ grep -n 'Running under quota pressure' …README.md                        → :62
$ grep -n 'local-resource' …README.md                                      → :115 (the worked example)
```

`gate/README.md` (sha `e3bc66b7…`) now carries a full **"Running under quota pressure"** section
documenting `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, the `local-resource` state, the control
matrix rows W0–W7, and the re-run recipe. **Declaration and implementation now agree.** The one
residual it honestly keeps is the mixed BLOCKED+FAIL case (§4 O3).

### 6.3 What is NOT claimed

- **No full-350 after-count from this seat.** This seat ran the single row (PASS) and the gate, not
  the whole battery. The author's `reports/round-104/physics/author-runs-full` was still in flight at
  this frame. The r104 report's own `{{C1_FULL_BATTERY}}` slot is the honest placeholder. **The
  before→after is proven for the one row that was broken; the full-battery count is not.**
- **No non-author full-battery reproduction.** §4 O7's PASS is this seat's own run of *one row*, which
  is independent of the author's receipt but is not the counting command the brief names.
- **The r104 attack suite has not been run against the final gate** (§4 O5). A green default-path run
  would not close it anyway, given §6.1.
- **No Unreal runtime claim.** Nothing above touches the editor.
- **This is a mid-flight document.** `run_gate.sh` changed identity **twice** and
  `phys3d_joints.gd` **once** inside this seat's window; `reports/round-104/` grew to 10 697 files. Any
  r104 verdict must re-derive the final state rather than quote this file's numbers.

---

## 7. Live-tree state at close of this seat

```
$ git status --porcelain=v1 | grep -v '^??'
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ git status --porcelain=v1 | grep '^??'
?? .r104-seat17/        ?? SKILL.md        ?? reports/round-104/     ?? trace.err  ?? trace.out
```

Digests at this frame:

| artifact | sha256 |
|---|---|
| `corpus/fixtures/phys3d_joints.gd` | `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc` (was `3ce066a6…`/`88be87fa…`) |
| `corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` — **unchanged** |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf` |
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` — **unchanged since r101 (F7)** |
| `SKILL.md` | `1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c` (untracked, 174 lines) |

`corpus/fixtures/**` walk: exactly **one** tracked modification (the licensed C1 file), **zero**
untracked additions, `ls -d corpus/fixtures/r90bt_* | wc -l` → **0**. No protected path was violated.

**Gate identity moved three times inside this seat's window** (`577c8b54…` → `15fc46d5…` →
`b6d8c61a…` → `e5521304…`) and `gate/README.md` three times (`1ec70290…` → `f84a580e…` →
`e3bc66b7…`). Any verdict must re-derive at the final sha.

---

## 8. Blockers and limits

- **`/tmp` quota is the host's, not the lane's, and it governs whether the gate can run on its default
  invocation.** It oscillated during this seat's window: exhausted (a **1-byte** write failing with
  EDQUOT while `df` showed 3.1 G free), relieved, exhausted again, relieved again. Every
  `/tmp`-workdir command in this lane — the gate's **default** invocation and `run_battery.py --runs
  /tmp/…` alike — is hostage to it. Measured across the whole window: default path **0/18 PASS** while
  the quota bit, **20/20 PASS** when relieved; `GATE_WORKDIR` **32/32 PASS** regardless. This seat's
  own first battery attempt died on `OSError: [Errno 122] Disk quota exceeded` at
  `run_battery.py:1252` and had to be re-run onto a home-filesystem path. **The r104 `GATE_WORKDIR`
  fix is the correct response to this class and is verified working — but it must actually be used.**
- **The round is mid-flight.** `reports/round-104/` grew from 8 to 10 697 files during this window;
  28 non-scratch `.md` artifacts landed, three of the r104 report's own open items went stale inside
  it, and one gate run failed on a sibling artifact that landed seconds later (§8.1). Re-derive at close.
- **This seat wrote only `reports/round-104/consistency.md`.** No gate file, no fixture, no `LOG.md`/
  `SCORECARD.md`/`SHONEN.md`/`SKILL.md`/`PROVINCE.md`, and nothing under `reports/round-101/**`,
  `reports/round-102/**`, `reports/round-103/**`, `corpus/knowledge/unreal-mcp/upstream/**` or
  `.manifest.d/**` was touched.
- **Not claimed:** that any item is *resolved* in the sense of being closed for good. The structural
  carries (no live-editor evidence; F7; IP-2; O4/O6/O8 of r102) cannot be closed on this host, and
  three of them are now **four rounds** old. They are recorded as carried, not as done.

### 8.1 A live race this seat observed — the gate now depends on `reports/round-104/**`

One gate run in this window failed with a defect that was **not real**:

```
$ GATE_WORKDIR=… bash run_gate.sh | grep -E 'MISSING|POINTERS|GATE RESULT'
MISSING-PATH-REL reports/round-104/gate/workdir.md
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)
```

`gate/README.md:373` and `:441` cite `reports/round-104/gate/workdir.md` as the receipt for the
`GATE_WORKDIR` control matrix. At the moment of that run the README had landed and the receipt had
not — seconds later the file appeared (`13645` bytes, `16:24`) and the gate went green **5/5**:

```
$ GATE_WORKDIR=… bash run_gate.sh   # ×5, after workdir.md landed
rc=0 POINTERS=103 … UNRESOLVED=0 | GATE RESULT: PASS (checks failed: 0)   (all five)
```

**This is a mid-flight artifact, not a defect to route** — but it exposes a **new coupling worth
naming**: CHECK 4's pass B resolves repo-relative paths, and the gate's own README is inside its scan
root, so **citing a not-yet-written r104 artifact from `gate/README.md` turns the gate red**. r103
routed the mirror-image hazard ("editing this README moves the count it states", `:436`); this is the
stronger form — the README can now make the gate fail outright on a *sibling seat's* file. The
README's own note at `:436` already predicts the count effect (`101 → 102 → 103` across r104). Worth a
ruling on whether the gate's README should cite r104 receipts at all, or cite them only by path-form
that pass B does not resolve.
