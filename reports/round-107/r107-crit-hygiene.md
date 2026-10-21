# r107-crit-hygiene — what goes stale when the pin changes

Seat: **CRIT-HYGIENE** · round 107 (3D side-round, re-vendor at fresh pin) · lane `game-dev-3d-shokunin`
Date: 2026-10-19. Labels: **[O]** observed here w/ command, **[I]** inference, **[?]** unknown.
Owned write: this file only. No `corpus/` landing (orchestrator owns the integration commit).

## Plan (5 lines)

1. Enumerate every in-lane artifact that names the OLD pin `a6aa73ad` or asserts bytes/counts derived from it.
2. Classify each claim: **stale-hard** (now false) · **stale-soft** (pointer/date only) · **durable** (pin-agnostic).
3. Check the lessons corpus + scorecard pointers for pin/count citations that rot.
4. Check the r101/r102 reports' byte claims (`diff -rq`, `sha256sum -c`) — true after re-vendor, and under what condition.
5. Emit paste-ready dated-correction notes + the orchestrator landing checklist.

---

## 0. Headline — the premise is falsified by the wire

**The pin did not move.** The round brief says "re-vendor … at a fresh pin". The
live remote ref is the r101 pin, byte for byte:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main          exit 0
$ git clone --quiet <same-url> ref && git -C ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C ref log -1 --format='%ci%n%s'
2026-09-17 13:28:32 +1200
[MCP] Permit safe concurrent tool calls
$ git -C ref ls-files -s | wc -l
12
```

**[O]** Same SHA, same subject, same committer date, same 12 tracked files as
`PROVENANCE.md:22` (pin), `:24` (subject), `:29` (12 files). `refs/heads/main` is
the only branch; `HEAD` is the same object. So this round re-derives an identical
pin — **there is no content delta**, and every byte-level claim from r101/r102
remains true *by construction*, not by luck.

**Consequence for this seat.** "What goes stale when the pin changes" must be
answered in the conditional, plus the two things that are stale **now for
non-pin reasons** (a dead scratch path; an out-of-pin snapshot). §1–§3 do both.

---

## 1. Classification table — every pin-bearing artifact

Method: `git grep -l "a6aa73ad" HEAD` (race-free against concurrent seats), then
read each hit in context. Verified state re-measured 2026-10-19 on HEAD `3ea02ff`.

```
$ git grep -l 'a6aa73ad' HEAD | wc -l
504        # 480 of them inside reports/round-101..106 (frozen round records)
$ git grep -l 'a6aa73ad' HEAD | grep -vc '^HEAD:reports/'
24         # the live surface: LOG, SCORECARD, engines.md, the subtree, 2 lessons
```

The table below covers those **24** non-report files; rows 18–19 are the
report/frozen surface, listed for completeness, not enumerated.

| # | artifact | pin-bearing content | class if pin moves | class **today** |
|---|---|---|---|---|
| 1 | `corpus/knowledge/unreal-mcp/PROVENANCE.md` §1 (`:19,22,29`) | repo URL, SHA, subject, 12 files | **stale-hard** (SHA/subject/date rows) | durable — still exact |
| 2 | `PROVENANCE.md` §2 (`:48`) | `diff -rq /tmp/ue-skills-ref …` | stale-soft (path) | **stale-hard** — `/tmp` clone gone (§3) |
| 3 | `PROVENANCE.md` §8 (`:340-356`) | out-of-pin PR table | **stale-hard** (table becomes wrong pin context) | **stale-soft** — PR set is a snapshot (§2) |
| 4 | `PROVENANCE.md` §7 (`:336`) | "main agreed with the pin when checked on 2026-10-18" | durable (dated) | durable |
| 5 | `.manifest.d/audit-reference.sha256` | 12 sha256 + `upstream/` prefix | **stale-hard** — all 12 hashes change | durable — 12/12 OK [O] |
| 6 | `.manifest.d/seat01..seat11.sha256` | same 12 hashes, split | stale-hard | durable |
| 7 | `README.md:91-92,273` | clone recipe + `git -C /tmp/ue-skills-ref rev-parse HEAD` | stale-soft | line 91 self-contained; **line 273 bare → dead** |
| 8 | `README.md:85` (`tracked files 12`), `:170,174` | counts | **stale-hard** only if the new pin adds/removes files | durable |
| 9 | `gate/run_gate.sh:73,75,76` | `PIN=`, `EXPECTED_*` | **stale-hard** — the gate *pins* the SHA | durable; gate PASS [O] |
| 10 | `gate/README.md:136,165,267` | expected `CLONE_HEAD=<pin>` | stale-hard | durable |
| 11 | 13 × `executability/*.md` | `diff -r`/`rev-parse` vs `/tmp/ue-skills-ref` | stale-soft | **stale-hard** — 69 bare commands (§3) |
| 12 | `adaptation-kimi.md:7,343,498` | clone path + SHA | stale-soft | **stale-hard** at `:446` liveness (§2) |
| 13 | `corpus/lessons/r102-unreal-integration.md:5` | pin quoted in the law | stale-soft | durable (historical law) |
| 14 | `corpus/lessons/r105-unreal-lifecycle.md:16,21` | pin + "12 files" | stale-soft | durable |
| 15 | `corpus/knowledge/engines.md:44` | Unreal row quotes pin + 12× OK | stale-soft | durable |
| 16 | `SCORECARD.md:291,301` | r101/r102 verdict rows | **historical record — must NOT be rewritten** | durable |
| 17 | `LOG.md:1310` | ROUND 101 entry | historical record | durable |
| 18 | `reports/round-101/**` (182 hits), `round-102/**` (13) | frozen round records | frozen — never edited | durable |
| 19 | `corpus/live/r101-sentinel/receipts/S10.static.txt` | pin line | gitignored, untracked | **absent from a fresh clone** (§3) |

**The rule this table encodes** (matches `reports/round-106/consistency/adversary.md`
S1/S2 and the r106 citation-form proposal): a *living* file whose claim becomes
false needs a **dated correction note**; a *frozen round record* is never edited —
a new round's report carries the correction. Rows 16–18 are the frozen set.

---

## 2. The two things stale **now** (not pin-driven)

### 2a. `PROVENANCE.md` §8 — the PR-set snapshot (stale-soft, *hashes are durable*)

§8 (`:340-356`) records "open PR 1" / "open PR 4" for six out-of-pin paths. I
re-derived all six against today's refs:

```
$ git fetch -q origin refs/pull/1/head && git show FETCH_HEAD:.claude-plugin/marketplace.json | sha256sum
390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8   908 B   → §8 MATCHES
$ git fetch -q origin refs/pull/4/head
  .github/workflows/ci.yml    1116 B  4bac0081…4cc38d   → MATCHES
  hooks/unreal-context.ps1    3322 B  eaf782fe…f1c7f    → MATCHES
  tests/test_hooks.sh         2778 B  35215587…9caa65   → MATCHES
  tests/test_hooks.ps1        3796 B  755befe2…3c06a8   → MATCHES
```

**[O] All five re-derivable hashes still match exactly.** The sixth row
(`toolsets.md`, history-only) is a blob id, unchanged. So §8's *content claims are
durable*; what is stale is its **"where it lives" column**:

| fact | §8 says | live, 2026-10-19 |
|---|---|---|
| open PRs | 1 and 4 | **6** (`refs/pull/{1,2,4,5,8,9}`) |
| `.claude-plugin/marketplace.json` | "open PR 1", 908 B | also PR 4 (same blob); **PR 2 carries a different one — 907 B, `1de11f5620043f9a3168da232d3dc0e9a736c45d5557564d9fa8e6542124551f`** |
| PR 8 (OpenCode port) | not mentioned | 22 files, head `1a3476f7…` |
| PR 9 (`bump to 3.1.2`) | not mentioned | 12 files, head `a5180ccd…` |

```
$ for pr in 1 2 4 5 8 9; do git fetch -q origin refs/pull/$pr/head; \
    echo "PR$pr $(git ls-tree -r --name-only FETCH_HEAD | wc -l) files"; done
PR1 13   PR2 13   PR4 17   PR5 12   PR8 22   PR9 12
$ git ls-tree -r --name-only HEAD | wc -l
12
```

**[O] This is a known, already-routed defect that never landed.** r102 queued it
as **B4** (`reports/round-102/fold-spec.md:465,650`) — "PROVENANCE §8 predates PR
#8". Evidence it is still open:

```
$ git log --oneline -- corpus/knowledge/unreal-mcp/PROVENANCE.md
366bb02 r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad …   ← one commit, ever
$ grep -c "OpenCode" corpus/knowledge/unreal-mcp/PROVENANCE.md
0
```

**[O]** `fold-spec.md` §7 point 6 routes B4 to "one authorized seat"; the r102
report's "five routed defects repaired" (`:60`) names F1/F2/F3/F5/F6/F8 — B4 is
**not** among them, so the r102 verdict is accurate and B4 is simply still open.
r104 (`freshness-pin.md:220`), r106 (`freshness-pin.md:269`) both re-confirmed the
status without editing the subtree. **r107 is the natural landing for it.**

### 2b. `adaptation-kimi.md:446` — a false liveness claim (stale-hard)

```
$ sed -n '446,447p' corpus/knowledge/unreal-mcp/adaptation-kimi.md
removes them. They happen to be **currently live** (`/tmp/ue-skills-ref` still exists and
`git -C /tmp/ue-skills-ref rev-parse HEAD` still returns the pin `a6aa73a…`), so the sections
$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: cannot change to '/tmp/ue-skills-ref': No such file or directory     exit 128
```

**[O]** The sentence was true when written (r103) and is false now. Under the
r106 S2 rule this is exactly the case that requires a **dated note, not a
silent rewrite** — the file says "currently live" and a trusting reader would be
told a different fact today. It is also the *only* liveness assertion in the
subtree (grep for `currently live|still exists` → 1 hit). r106 already queued it
(`reports/round-106/freshness-pin.md:280-298`) and did not land it.

Related, same file: `adaptation-kimi.md:486-503` narrates a header-URL defect
that **r105 already fixed** (`sed -n '6p'` shows the `-plugin` form;
`git log -1 -- adaptation-kimi.md` → `830095a`, the r105 commit). r106 queued the
note (`freshness-pin.md:301-310`); still open.

---

## 3. The reproduction-path class — 74 subtree citations, 69 now dead

This is the biggest *mechanical* staleness, and it is invisible to the gate.

```
$ git grep -nE '/tmp/(ue-skills-ref|r101-audit|r101work|kimi_strings)' HEAD -- corpus/knowledge/unreal-mcp | wc -l
88
$ git grep -nE '/tmp/(ue-skills-ref|r101-audit)' HEAD -- corpus/knowledge/unreal-mcp | wc -l
72         # narrower pattern: 72 of the 88 name the two dead r101 clones
$ ls -ld /tmp/ue-skills-ref /tmp/r101-audit
ls: cannot access '/tmp/ue-skills-ref': No such file or directory
ls: cannot access '/tmp/r101-audit': No such file or directory
```

*(Counts use `git grep HEAD` deliberately: the working-tree `grep` I ran first
read 87 → 74 → 72 across successive calls because concurrent r107 seats were
writing shards into `reports/`. HEAD is race-free; the shard is pinned to it.)*

**[O]** Both r101 reference clones are **gone from this host**. Classified by
whether the citing block is self-contained (contains its own `git clone`):

| area | citations | self-contained | **bare (dead)** |
|---|---:|---:|---:|
| `.manifest.d/audit-reference.sha256` (header comment) | 1 | 0 | 1 |
| `PROVENANCE.md` | 10 | 3 | 7 |
| `README.md` | 3 | 2 | 1 |
| `adaptation-kimi.md` | 10 | 0 | 10 |
| 13 × `executability/*.md` | 50 | 0 | 50 |
| **subtree total** | **74** | **5** | **69** |

**[O]** Measured with a fence-aware parser (a citation counts self-contained only
if its own fenced block contains `git clone …/tmp/ue-skills-ref`). Every one of
the 69 bare commands exits 128 today. Two representative receipts:

```
$ diff -rq /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream --exclude=.git
diff: /tmp/ue-skills-ref: No such file or directory          rc=2
$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: cannot change to '/tmp/ue-skills-ref'                 rc=128
```

**Why this matters more than it looks.** The standing gate is green right now:

```
$ GATE_WORKDIR=/var/tmp/r107-crit-hygiene/gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | tail -12
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_DIRTY=0  CLONE_TRACKED=12  PATH_EXTRA=0 PATH_MISSING=0  BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0   CENSUS static-only=12 unproven-runtime=1 verified-here=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**[O]** `GATE RESULT: PASS`, exit 0 — while 69 unrunnable commands sit in the
tree it guards. That is not a gate defect: CHECK 4's sweep is deliberately scoped
to `upstream/<path>:<line>` and backticked `corpus/|reports/|docs/|executability/|
gate/|upstream/|.manifest.d/` paths (`run_gate.sh:360-430`). `/tmp/…` matches
neither pattern. **A green gate is silent on this class** — the finding, not a bug.

**Is a fix owed?** Under r106 S1: the *recipe* form (README:91, PROVENANCE:94-98)
is self-contained and needs nothing. The 69 bare `git -C /tmp/ue-skills-ref …`
lines are **path/command non-conformance**: the *fact* they evidence (the vendored
tree equals a clone at the pin) is unchanged and re-established this round, but the
command as written no longer runs. S1 makes silent in-place repair the right
instrument *if* the round report holds the before/after — so this is a **queued
sweep item, not a note**. Row 18 of §1 (the frozen round reports, 195 hits) must
not be touched at all. Fixable surface: the 74 subtree hits.

---

## 4. Answering the three questions asked of this seat

**Q1 — lesson cites that rot.** Lessons cite the pin twice
(`r102-unreal-integration.md:5`, `r105-unreal-lifecycle.md:16,21`) and the
12-file count once. Both are **historical laws** ("vendoring is scoped to the
pin") — correct at their revision, and correct today since the pin is unmoved.
**No edit.** If a future pin moves, they gain a dated note, never a rewrite.
`r105-unreal-lifecycle.md:20,23` cite `/tmp/ue-skills-ref` in a *historical
receipt* frame; same treatment.

**Q2 — scorecard pointers.** `SCORECARD.md:291,301` are **frozen verdict rows**
for closed rounds. They must never be edited to track a new pin — the r10x
verdict for r101 is a fact about r101. **No edit.** One live pointer is
non-resolvable and worth naming:

```
$ ls /tmp/r102-gate-verify-full.txt
ls: cannot access '/tmp/r102-gate-verify-full.txt': No such file or directory
```
`SCORECARD.md:301` cites it as "mirrored in round report". The 11/11 result **is**
in `reports/round-102/r102-report.md:429` and `gate/adversary-a.md:264`, so the
claim survives — but the `/tmp` half of the pointer is dead and the row should be
read through the report, not the `/tmp` path. r106's receipt-discipline rule
(`reports/round-106/consistency/adversary.md`, "`/tmp` is not evidence") covers
this class; **no new note needed, this seat records it.**

**Q3 — r101/r102 byte claims.** Under re-vendor at the *same* pin: **still
exactly true**, verified today, not merely inherited:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
… 12 lines, all "OK"                                             rc=0
$ sha256sum -c .manifest.d/seat0*.sha256 .manifest.d/seat1*.sha256
… 12 lines, all "OK"
```
Under a re-vendor at a *different* pin, the condition is precise: **the 12
sha256 values, the SHA in PROVENANCE §1, the `PIN=`/`EXPECTED_*` constants in
`run_gate.sh`, and the expected `CLONE_HEAD` in `gate/README.md` all move
together.** They are one atomic unit; changing any subset turns the gate red.
r101's `diff -rq` and r102's `sha256sum -c` claims are *pin-relative*, so they
stay true only while the pin does — which today it does.

---

## 5. Paste-ready dated-correction notes (drafts — orchestrator lands)

> **Note (1) — `PROVENANCE.md` §8, after the table.**
> **Dated correction (r107, 2026-10-19).** The "where it lives" column above is a
> point-in-time snapshot (r101, 2026-10-18) and is now incomplete — it names only
> PRs 1 and 4, though the review it cites found **four** PR refs (1, 2, 4, 5,
> `r101-critic-c1.md` §3b). The recorded **hashes remain exact**: all five
> re-derivable ones were re-derived this round
> (`reports/round-107/r107-crit-hygiene.md` §2a). Live ref set: **6** open PRs
> (`refs/pull/{1,2,4,5,8,9}`); `.claude-plugin/marketplace.json` also lives in PR 4
> (same 908 B blob) and PR 2 carries a **different** one (907 B,
> `1de11f5620043f9a3168da232d3dc0e9a736c45d5557564d9fa8e6542124551f`); PR 8
> (OpenCode port, head `1a3476f7…`, 22 files) and PR 9 (head `a5180ccd…`) opened
> after this table. `main` is unchanged at the pin, so nothing here is vendored.
> Re-derive with `git ls-remote <url> 'refs/pull/*/head'`. Closes r102 `fold-spec`
> item B4. **Superseded by the r107 `PROVENANCE.md` rewrite (§8 refreshed,
> 16 paths / 6 PRs)** — land the rewrite *or* this note, not both.

> **Note (2) — `adaptation-kimi.md`, end of §C3.**
> **Dated correction (r107, 2026-10-19).** The parenthetical above asserting
> `/tmp/ue-skills-ref` is "currently live" was true at its revision and is now
> false: `git -C /tmp/ue-skills-ref rev-parse HEAD` → `fatal: cannot change to
> '/tmp/ue-skills-ref': No such file or directory`, exit 128. The note's own
> recommendation stands and is now the only working path: cite
> `corpus/knowledge/unreal-mcp/upstream/`. Re-derive: `ls -d /tmp/ue-skills-ref`
> (`reports/round-107/r107-crit-hygiene.md` §2b).

> **Note (3) — `adaptation-kimi.md`, end of the header-URL paragraph (`:503`).**
> **Dated correction (r107, 2026-10-19).** The paragraph above says the line-6
> defect "is left **uncorrected on purpose**". It is not: the same commit that
> added this paragraph also repaired line 6 (`git show 830095a -- adaptation-kimi.md`
> shows `-claude-code` → `-claude-code-plugin`), so `sed -n '6p'` now prints the
> `-plugin` URL. The paragraph is therefore internally false and this note closes
> it. Residual display string: the H1 on line 1 still omits `-plugin`.

*(Note 3 overlaps r106 `freshness-pin.md:301`; land one, not both — S3 forbids a
second note on the same claim.)*

### Coordination with the r107 PROVENANCE-WRITER draft (important)

`reports/round-107/r107-PROVENANCE-draft.md` is a **full PROVENANCE.md rewrite**
that already refreshes §8 (its §8a/§8b: 6 PRs, 16 unvendored paths). If the
orchestrator lands that rewrite, **note (1) is superseded and must not also land**
(S3: one note per claim). Notes (2) and (3) target `adaptation-kimi.md`, which the
rewrite does not touch, so they stay independent. Two discrepancies this seat
measured against the draft:

| draft says | measured here | verdict |
|---|---|---|
| §9: "r101 §8 recorded … four PR refs: 1, 2, 4, 5" | §8's *table* names only PRs **1 and 4** (2 and 5 appear only in the review it cites) | draft is **charitable**; the table was narrower |
| §8b: "was 6 in r101" paths | §8's table has exactly **6 rows** | agrees |

Neither is a defect in the draft's substance — both are worth one line so the
orchestrator does not land two §8 corrections.

---

## 6. Orchestrator landing checklist

| step | action | acceptance command |
|---|---|---|
| 1 | Land **either** note (1) **or** the PROVENANCE-WRITER rewrite (not both) | `grep -c 'OpenCode' corpus/knowledge/unreal-mcp/PROVENANCE.md` → `1` |
| 2 | Land note (2) at `adaptation-kimi.md` §C3 end | `grep -c 'Dated correction (r107' corpus/knowledge/unreal-mcp/adaptation-kimi.md` → `1` |
| 3 | Land note (3) (or fold into (2) if one block) — S3 caps at one note per claim | `sed -n '6p'` → `-plugin` URL |
| 4 | Re-run the gate after landing (notes add pointers/text) | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `GATE RESULT: PASS`, exit 0 |
| 5 | Re-verify manifests (untouched by notes) | `sha256sum -c .manifest.d/audit-reference.sha256` → 12 × OK |
| 6 | Do **not** edit `SCORECARD.md`/`LOG.md` r101/r102 rows | `git diff --name-only` excludes them |
| 7 | Do **not** edit `reports/round-101/**`, `round-102/**` | frozen round records |
| 8 | Optionally queue the 69 dead `/tmp` commands as an r108 sweep item | `grep -rc 'git -C /tmp/ue-skills-ref' corpus/knowledge/unreal-mcp/executability/` |

**Watch-out for step 4 — measured, not predicted.** Both notes land inside the
gate's CHECK 4 sweep scope (they cite a `reports/` path). I applied the exact note
text to a full scratch copy of the lane and re-ran the gate:

```
baseline (HEAD)                    POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0 → PASS
after landing notes (2)+(3)        POINTERS=104 POINTER_STRINGS=41 UNRESOLVED=0 → PASS
```

**[O]** Landing the notes does **not** fail the gate: `POINTERS` moves `103 → 104`
(+1 unique backticked path, deduped by the pass-B `sort -u`) and `UNRESOLVED`
stays `0`. The hazard is the opposite of a failure: `gate/README.md:248` pins the
expected value at `103` (scanner `e5521304…`), so **that pinned line becomes stale
and needs the r104-style dated note the README already models.** If the shard is
committed *after* the gate re-run, the `reports/round-107/…` path is present and
resolves either way; the ordering does not change the result.

---

## 7. Adjacent finding (outside this seat's core scope, recorded)

`gate/README.md` names `e5521304…` as "the r104 scanner sha256" (`:42`) and "the
current pin … at scanner sha256 `e5521304…`" (`:440`), but the live gate is
`390a25ae…` and `e5521304…` appears **zero** times in `run_gate.sh`:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ grep -c e5521304 corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
```
This is **gate-version drift, not pin drift** — out of this seat's charge, already
flagged by r106 (`r105-unreal-lifecycle.md:198` dated note; `citation-form-rule.md:192`).
Recorded here so it is not lost; **r107-crit-scope / the gate seat owns it.**

---

## 8. What this shard does NOT claim

- No Unreal Editor, MCP call, UBT, or engine runtime was involved. Editor absent
  (`command -v UnrealEditor` → none). Every live-editor claim stays
  `unproven-runtime`; a green gate is static evidence only.
- The docker unlock attempt is **not** this seat's; the pull was still in flight at
  last check (no `wukakuki/unreal-engine` image present) and is reported by the
  unlock seats.
- No `corpus/` file was written by this seat. Artifacts: this file,
  `/var/tmp/r107-crit-hygiene/{ref,gate}`.
- "The pin did not move" is asserted for the window ending `2026-10-19T03:11Z`
  **[O]**; it is not a prediction.
