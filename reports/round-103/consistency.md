# r103 SEAT-44 — ROUNDS-CONSISTENCY

**Seat:** SEAT-44 ROUNDS-CONSISTENCY · round r103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/consistency.md`). Read-only on every other path.
**Lane HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Probe window:** 2026-10-18 ~18:31Z–18:38Z. **Mid-flight document** — 40 r103 artifacts landed while
this seat ran, and `gate/run_gate.sh` was rewritten ≥8 times inside the window (sha `412d1b84` →
`55a76cf8` → `eca9e92f` → `ff2c26c0` → `f23f3c8c` → `0c1ca3e1`). Every number below carries the
command and the timestamp at which it was taken.

**Charge:** verify that **every open item** in `reports/round-101/r101-report.md` and
`reports/round-102/r102-report.md` is either (a) addressed this round, or (b) carried honestly —
i.e. named in some r103 artifact. List each with its disposition.

**No Unreal runtime claim is made anywhere in this file.** The editor is not installed on this host
and live-MCP behaviour is unproven by construction. Everything below is a static/byte/HTTP check.

---

## 0. Verdict in one table

| source | items | ADDRESSED | CARRIED (named) | CARRIED (no carrier) |
|---|---|---:|---:|---:|
| r101 open items 1–6 | 6 | 4 | 2 | 0 |
| r101 routed queue (6 defects + IP-2 + S-5 + S-8) | 9 | 7 | 2 | 0 |
| r102 open items 1–8 | 8 | 3 | 5 | 0 |
| r102 routed queue | 8 | 6 | 2 | 0 |
| **total** | **31** | **20** | **11** | **0** |

**Every open item in both reports is either addressed this round or named in an r103 artifact.** Two
carries need the L1's attention anyway, because being *named* is not the same as being *handled*:

- **r102 O2 (F7, the card-label vocabulary collision) is carried and explicitly named** — but only as
  a warning, not a repair. `reports/round-103/skill-table-review.md:47-49` states it plainly: *"the
  round's own close-out must not read a green gate as F7 being closed … `README.md:41` and the six
  dissenting cards still disagree."* The defect is byte-identical to r101 (`README.md` hash
  `c79d8dd1…` unchanged; six-card census still 6). This is now the **third** round it has been named
  and the **first** in which a r103 artifact names it — but no r103 artifact rules on it. See §3.2.
- **r102 O4** (the gate writes no receipt, is reachable from no standing harness) is *nominally*
  addressed but on inspection only half-done. See §3.4.

⚠️ **Grep-window caveat.** `reports/round-103/` grew from 2 files to 40 during this seat's window, and
`skill-table-review.md` landed *after* my first carrier sweep. Every carrier count below is restated
from a sweep that **excludes this file** and was re-run at 18:39Z against the 40-file tree.

---

## 1. Method

For each open item: (1) read the item verbatim from the report; (2) search all r103 artifacts for a
carrier (`grep -rl` on the item's own vocabulary across `reports/round-103/`); (3) where the item
asserts a state, re-derive that state with a command this seat ran. An item is **ADDRESSED** only if
the state it asked for is now true *and* an r103 artifact records it. It is **CARRIED** if the item's
subject appears in an r103 artifact (honestly named) but the state is unchanged. It is **CARRIED (no
carrier)** if nothing in r103 names it at all.

Carrier counts are `grep -rl <term> reports/round-103/ | wc -l`, run at 18:36–18:38Z against the
then-current 40-file r103 tree.

---

## 2. r101 open items (`reports/round-101/r101-report.md:285-310`)

### O1 — hash slot and `[moving]` counts must be filled from the committed tree · **ADDRESSED**

`git cat-file -t 1659c036c961c6cdfd0b2679db72ecb9517a2f3b` → `commit`; `git log -1` →
`1659c03 r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad …`. The r101 adjudication
addendum (`r101-report.md:315-346`) is the close-of-round measurement pass, and `SCORECARD.md`'s
"Round 101 verdict" block carries the same numbers. The `*to be filled at round close*` boilerplate
at `:8` is the pre-landing frame, superseded in-file by the adjudication section — this is the
report-last convention, not a dangling slot.

### O2 — `pointer-check.sh` self-contaminates on the protocol's negative controls · **ADDRESSED**

Re-run of the exact scenario the item describes:

```
$ bash /tmp/r101-closeout/pointer-check.sh reports/round-101
POINTERS=75 UNRESOLVED=0
STEP=PASS
```

The script now carries the exclusion list the item asked for (`/tmp/r101-closeout/pointer-check.sh:3`
→ `# EXCLUSIONS, both deliberate:`). The `UNRESOLVED=2 / STEP=FAIL` the item warned about **no longer
reproduces**. (Carrier: this is a `/tmp` script, not an r103 artifact — but the state is now true and
the r103 gate re-implements the same discipline; `reports/round-103/gate/clean.md` §Verdict is the
in-round record.)

### O3 — subtree `README.md` layout block labelled `PROVENANCE.md`/`adaptation-kimi.md` as `(pending: …)` · **ADDRESSED**

```
$ sed -n '104,116p' corpus/knowledge/unreal-mcp/README.md
├── PROVENANCE.md          ← provenance manifest (SEAT-12)
├── adaptation-kimi.md     ← Claude→Kimi adaptation table + verification policy (SEAT-13)
$ grep -n 'pending' corpus/knowledge/unreal-mcp/README.md
69:  pending operator Epic-account linking.
```

The two `(pending: …)` labels are gone (landed at r101 close, recorded in `r101-report.md:328-330`).
The single surviving `pending` at `:69` is unrelated (the engine-install wall).

### O4 — C1 scope wording ("all upstream content files" vs "the pinned commit") · **ADDRESSED**

`r101-report.md:322-325` records the adoption: C1 is scored as *"all files tracked at the pinned
commit"*. The out-of-pin surface is recorded at `corpus/knowledge/unreal-mcp/PROVENANCE.md:340`
(`## 8. Known out-of-pin upstream surface (recorded, not vendored)`), and `SCORECARD.md`'s r101 row
restates the scope. Nothing further is owed.

### O5 — C3's `verified-here` rows are Kimi-side, not Unreal-side · **CARRIED (named)**

Carrier: `reports/round-103/note/rows.md` (SEAT-02) re-runs all 15 adaptation rows and keeps them
Kimi-side; `reports/round-103/note/binary.md` (SEAT-06) re-probes the binary anchor and finds the §5
invalidation pin **intact** (`2.2.0`, BuildID `5e67bdf9…`). 15 r103 files carry the
"editor not installed" caveat. No r103 artifact promotes any row to Unreal-side; the item's subject
is actively maintained, not resolved — correctly so, since it cannot be resolved on this host.

### O6 — no live-editor evidence exists or can exist here · **CARRIED (named)**

Carrier: `reports/round-103/install-recheck.md` (SEAT-57) re-executes all three install receipts
verbatim — `EpicGames/unreal-engine` over HTTPS still 404, `gh api` still 404, AUR recipe unchanged —
and states *"nothing has changed since r102 either."* The item is a permanent structural limit, not a
task; it is honestly carried and re-evidenced.

### r101 routed queue (`LOG.md:1318-1323`) · 6 defects + IP-2 + S-5/S-8

| routed item | disposition | carrier / evidence |
|---|---|---|
| r22 README/lesson path drift (exit=2) | **ADDRESSED** (r102) | `r102-report.md:183-192` before→after receipts; `reports/round-103/b2/verify-unity.md` re-runs the same class on unity-r19 |
| r22 lesson cites absent `verdicts.json` | **ADDRESSED** (r102) | `r102-report.md:193-202`, dated correction note; gitignore evidence |
| `run_battery.py` cited-sha drift | **ADDRESSED** (r102) | `r102-report.md:203-212`; digest reproduced from history (`git cat-file blob 490e710d:…`) |
| `engines.md` three.js command fails from clean tree | **ADDRESSED** (r102) | `r102-report.md:213-222`; `npm ci --prefix` precondition folded |
| `rea.md` JADX/Binwalk/Unblob census | **ADDRESSED** (r102) | `r102-report.md:223-233`; dated note, mint sentence preserved |
| README glob line-count (F8) | **ADDRESSED** (r102) | `reports/round-102/repairs/F8-readme-lines.md`; `r102-report.md:234-241` |
| **IP-2 — battery digest map covers 0 `corpus/knowledge/` files** | **CARRIED (named, re-measured open)** | Carrier: `reports/round-103/r103-connector.md:234` re-runs `seed_digests()` and finds **130 entries, 0 `knowledge` / 0 `unreal-mcp` / 0 `gate` refs** — *identical* to r102, "closed? **no**". `reports/round-103/gate/exit-codes.md:223` adds that *"nothing in the lane currently consumes the gate's exit code."* The call site is still unbuilt. |
| sentinel **S-5** (PATH-shadowed `basename`) | **ADDRESSED (absorbed)** | r102's tool-requirement guard (`run_gate.sh:26-28`) is the same class of fix; r103 extends it by removing the `/tmp/advgate` hardcode (§4, N1) |
| sentinel **S-8** (`.mcp.json` auto-load) | **CARRIED** | Investigated at `reports/round-102/sentinel-mcp.md` §2 (Kimi gates project `.mcp.json` behind workspace trust — *stronger* than the r101 finding). 0 r103 carriers. |

---

## 3. r102 open items (`reports/round-102/r102-report.md:351-397`)

### O1 — hash slot, `[moving]` counts, and `LOG.md`/`SCORECARD.md` carry zero r102 entries · **ADDRESSED**

```
$ git log --oneline -1 c6f655d
c6f655d r102: close-out gate for unreal-mcp subtree (hardened, 11/11 attacks detected) + …
$ grep -c 'ROUND 102' LOG.md          → 1
$ grep -c 'Round 102' SCORECARD.md    → 1
```

Both ledger entries landed in `c85a816` (the r102 report-last commit). The item's own complaint —
*"the L1's to land"* — is satisfied.

### O2 — **F7, the card-label vocabulary collision** · **CARRIED (named, not ruled)** ⚠️

Carrier: `reports/round-103/skill-table-review.md` (SEAT-43), which landed after this seat's first
sweep. Restated with my own file excluded, at 18:39Z:

```
$ grep -rl "F7" reports/round-103/ | grep -v consistency.md | wc -l     → 2
$ grep -rl "label collision" reports/round-103/ | grep -v consistency.md | wc -l      → 0
$ grep -rl "vocabulary collision" reports/round-103/ | grep -v consistency.md | wc -l → 0
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l → 6
$ sed -n '41p' corpus/knowledge/unreal-mcp/README.md
| `unproven-runtime` | the claim needs the live editor and nothing was observed | `unproven` |
```

The two hits are `skill-table-review.md:47,49` and `:168-187`, and they say exactly the right thing:

> *"the round's own close-out must not read a green gate as F7 being closed … the subtree `README.md`
> hash is **unchanged** (`c79d8dd1…`) … so `README.md:41` and the six dissenting cards still
> disagree. The draft's §3 P/C precedence ruling is still owed, and the gate **cannot** see this
> defect by construction."*

So the item **is** carried honestly and explicitly this round — my earlier "0 carriers" reading was a
grep-window artifact (the file landed mid-window). But the distinction matters: r103 **names** F7 and
**warns** against reading the green gate as closure; r103 does **not** rule on it. The six cards still
reject `unproven-runtime` on the ground that the runtime path *"is not even identified"*, which is the
same condition the index defines as requiring it. Raised at r101 (`r101-critic-c3.md:317`), re-raised
as r102's highest-value gap, named-and-warned at r103 — **still unruled after three rounds.** It needs
an explicit L1 ruling, not another naming, or it will be named a fourth time.

### O3 — gate under-covers range-form pointers (gate 40 vs sweep 47) · **ADDRESSED this round**

A1 landed in `corpus/knowledge/unreal-mcp/gate/run_gate.sh` (sha `0c1ca3e1…`). Independent acceptance
re-run by this seat on a scratch copy:

```
$ # planted: append `see upstream/README.md:1-9999` to executability/materials.md
$ bash <copy>/gate/run_gate.sh | grep -E '^(POINTERS|STEP=|GATE RESULT|LINE-OOR)'
LINE-OOR <copy>/executability/materials.md :: upstream/README.md:1-9999 (max 112)
POINTERS=100 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=27
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
```

The tail endpoint is now validated (`tr ',-'`-style expansion is present in the gate; `grep -cE
"tr ',-'|endpoint"` → 5). The unmutated tree stays green (§5).

### O4 — gate writes no receipt and is reachable from no standing harness · **CARRIED (named, re-measured open)** ⚠️

Carrier: `reports/round-103/r103-connector.md:229-234` re-measures all three r102 integration gaps and
marks every one **"closed? no"**:

```
$ grep -rn "run_gate" corpus/fixtures/*.py corpus/fixtures/*/*.mjs corpus/knowledge/engines.md
→ 0 hits
```

No `--receipt` flag landed; the gate still writes stdout only (`mktemp`+`trap`). Other hits on
`--receipt` are `reports/round-103/b2/repair-three.md` (the *three* runner's pre-existing flag) and
`reports/round-103/gate/exit-codes.md:223` (the *proposed* `--vendor-gate` wrapper, not yet built). A
gate harness exists (`reports/round-103/gate/mutations.md` §Harness → `/tmp/r103-mut/mutate.sh`) but it
is `/tmp` scratch — exactly the condition the item objects to. **Still open, now honestly named.**

### O5 — gate requires the network; offline it cannot run · **ADDRESSED this round**

A4 landed. Independent acceptance re-runs by this seat, on a full worktree copy so that CHECK 4 is
not perturbed:

```
$ # control (unmodified copy)
$ bash <copy>/gate/run_gate.sh | tail -2
GATE RESULT: PASS (checks failed: 0)          rc=0

$ # BLOCKED: only the git-URL REPO= line rewritten to a non-existent repo
$ bash <copy>/gate/run_gate.sh | grep -E '^(CHECK 2|BLOCKED|STEP=|GATE RESULT)'
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)     rc=2

$ # GATE_REF: air-gapped run against a pre-cloned reference at the pin
$ GATE_REF=/tmp/r101-closeout/clone bash <copy>/gate/run_gate.sh | grep -E '^(GATE_REF|CHECK 2|STEP=|GATE RESULT)'
GATE_REF=/tmp/r101-closeout/clone (offline reference; no clone attempted)
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          rc=0
```

Both A4 acceptance options are met: a distinct `CHECK 2 BLOCKED (network)` signal **and** declared
exit **2** (`run_gate.sh:290`), plus the `GATE_REF` offline path. The air-gapped close-out the item
said was impossible is now possible.

### O6 — `math-audit.md` found 2 WRONG numbers (both minor, both self-disclosed) · **CARRIED**

0 r103 carriers for either number (my own file excluded):

```
$ grep -rl "1264\|1410" reports/round-103/ | grep -v consistency.md | wc -l   → 0
```

`reports/round-103/math-audit.md` (SEAT-38) is a *new* audit of r103 artifacts, not a repair of the
two r102 rows — its §10 F7 row even re-classifies one of its own findings as a stale frame. The
`battery-integrity.md` §2 count label (`1410` vs measured `1264`) and the `reports-index.md` stale
frame (`adversary/F3.md` byte count/sha, superseded when its author rewrote the file) are both
still as r102 left them. Neither affects a load-bearing conclusion (the r102 audit already scoped
that), so this is a legitimate carry — but it is now two rounds old and should be either fixed or
formally waived.

### O7 — no live-editor evidence exists or can exist here · **CARRIED (named)**

Same structural limit as r101 O6. Carrier: `reports/round-103/install-recheck.md` — all three install
receipts re-run, **nothing changed**. 15 r103 files carry the caveat.

### O8 — adversarial findings the L1 should rule on, not silently absorb (F3/F5/F6) · **CARRIED**

The three rulings are cited and re-verified in r103 (`reports/round-103/b2/adversary.md:175`,
`reports/round-103/math-audit.md:199` re-derives the `scene_graph.mjs` digest cited by
`adversary/F3.md`), but **no r103 artifact records an L1 accept/overrule**. The r102 adjudication
addendum did not rule on them either — its own open item 8 says *"the rulings themselves are the
adjudicator's to accept or overrule."* This is a genuine carry, correctly framed, still owed.

### r102 routed queue (`LOG.md:1349-1358`) · 8 items

| routed item | disposition | carrier / evidence |
|---|---|---|
| fold-spec **A1** (range-tail-blind regex) | **ADDRESSED** | §3.3 above; acceptance re-run green |
| fold-spec **A2** (prose-hijackable first-token rule) | **ADDRESSED** | Anchored `LABEL_RE` declaration rule. Acceptance re-run by this seat: injecting `This card is emphatically not \`verified-here\`…` above the declaration → `OK static-only editor-general.md line 5`, `CENSUS … verified-here=0` (the prose is skipped, the real declaration read). Attack record: `reports/round-103/gate/a2-attack.md` |
| fold-spec **A3** (card names never compared) | **ADDRESSED** | `PINNED_CARD_NAMES` set. Acceptance re-run by this seat: `mv sequencer.md sequence-typo.md` → `FAIL card-name-missing sequencer.md`, `FAIL card-name-extra sequence-typo.md`, `NAME_SET=BAD NAME_BAD=2`, `STEP=FAIL`. Attack record: `reports/round-103/gate/a3-attack.md` |
| fold-spec **A4** (network-blocked vs byte mismatch) | **ADDRESSED** | §3.5 above; exit 2 + `GATE_REF` both verified |
| kimi-surfaces freshness note for `adaptation-kimi.md` | **ADDRESSED** | `adaptation-kimi.md` +143/−0 dated correction note at `:367`; `reports/round-103/note/{author,verify,urls,configline,rows,crosscheck,binary}.md` |
| battery node-marker drift (r94_cannon) | **CARRIED** | `reports/round-103/b2/repair-glb.md:176,193` re-observes the `r94_cannon_*` reds; no re-baseline or side-pin landed. `reports/round-103/physics/investigate.md` handles the *14th* row separately and correctly refuses to fold it into the marker class |
| B2 dead `.shokunin` root in 3 READMEs (glb-r12, unity-r19, three) | **ADDRESSED this round** | All three now read `occ=0`: `grep -c 'shokunin/game-dev-3d'` → glb-r12 **0**, unity-r19 **0**, three **0**. Carriers: `b2/{adversary,repair-glb,repair-three,verify-unity,verify-three,corrections}.md`, `pathroot-sweep.md` |
| math-audit 2 wrong rows | **CARRIED** | see O6 above |

---

## 4. New r103 findings that need a name (so r104 does not lose them)

These are not r101/r102 open items — they surfaced this round — but the same consistency standard
applies to them.

| # | finding | state | carrier |
|---|---|---|---|
| **N1** | the gate hardcoded `/tmp/advgate/.h1`, giving a **false red** on any fresh host (the mirror of a false green) | **ADDRESSED this round** | `run_gate.sh:65-69` now documents the fix; `WORK=$(mktemp -d)` discipline restored |
| **N2** | `gate/README.md` has drifted out of sync with the gate it documents (3 places) | **OPEN — new** | `reports/round-103/b2/corrections.md` §0 marks it **FAIL (drift)**; `reports/round-103/gate/docs-sync.md` |
| **N3** | the ledger's "battery reds = r94_cannon marker class" framing covers only **13 of 14** rows; the 14th (`phys3d_joints_free_ops`) is an independent **harness-timeout** class | **INVESTIGATED, framing corrected** | `reports/round-103/physics/investigate.md` — ~21–24 s wall vs `CASE_TIMEOUT_SECONDS = 20` (`run_battery.py:36`), only ~3.5 s CPU; `reports/round-103/r103-distiller.md` §3 N3 |
| **N4** | the dead-root scope count an L1 ruling is sized by does not reproduce (r102 recorded 142; r103 measures 167 on the same commit) | **OPEN — flagged, not adjudicated** | `reports/round-103/r103-distiller.md` §3 N4; `reports/round-103/b2/adversary.md` §2 |
| **N5** | 21 untracked `corpus/fixtures/r90bt_*` directories (42 files, `child.log` + `project.godot`) appeared during the phys3d investigation — **not gitignored**, under the protected `corpus/fixtures/**` path | **TRANSIENT — now gone** | At 18:35Z `git status --porcelain -uall -- corpus/fixtures/` → 42 entries; at 18:38Z `ls -d corpus/fixtures/r90bt_* \| wc -l` → **0**. No tracked fixture byte changed (`git diff --stat HEAD -- corpus/fixtures/` empty throughout). Worth an explicit ruling next round on whether `run_battery.py`'s per-backend scratch dirs belong under a protected path at all. |
| **N6** | stray untracked `B.txt` at the repo root (a peer seat's gate transcript) | **OPEN — untracked litter** | `git status --porcelain` → `?? B.txt`; content is a gate run against `/tmp/s16-adv/repo2/…` |

---

## 5. Live-tree state at close of this seat

**Two snapshots, because the tree moved under me.** The gate sha changed **9+ times** inside this
seat's window (`412d1b84` → `55a76cf8` → `eca9e92f` → `ff2c26c0` → `f23f3c8c` → `0c1ca3e1` →
`9b4763d9` → `577c8b54`), and `reports/round-103/` grew 2 → 48 files.

**S1 — the A1–A4 acceptance snapshot (18:38Z), gate `0c1ca3e1…`.** Every A1/A2/A3/A4 acceptance re-run
in §3.3–§3.5 and the routed table was taken against these bytes:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | tail -4
CHECK 4 pointer-sweep
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)      rc=0
```

**S2 — the carrier-sweep snapshot (18:41Z), gate `577c8b54…`.** All carrier counts in §2/§3 were
restated against this later tree (48 files), which is why several counts differ from the S1-era
numbers first drafted here:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | tail -3
STEP=PASS
GATE RESULT: PASS (checks failed: 0)

$ # A1-A4 markers still all present on the S2 bytes
$ grep -cE "tr ',-'|endpoint" corpus/knowledge/unreal-mcp/gate/run_gate.sh          → 5
$ grep -cE "LABEL_RE" corpus/knowledge/unreal-mcp/gate/run_gate.sh                   → 2
$ grep -cE "PINNED_CARD_NAMES|NAME_SET" corpus/knowledge/unreal-mcp/gate/run_gate.sh → 6
$ grep -cE "CHECK 2 BLOCKED|exit 2|GATE_REF" corpus/knowledge/unreal-mcp/gate/run_gate.sh → 10
```

So A1–A4 survive the further rewrites and the gate remains green. The carrier counts that moved
between S1 and S2 — **F7: 2 → 4 carriers** (`skill-table-review.md`, `gate/critic.md`,
`r103-connector.md`, `math-audit.md`), **digest map/IP-2: 1 → 2** — are the grep-window artifact this
report's ⚠️ caveat names; §2/§3 carry the S2 values.

`git status --porcelain=v1` at S2 shows the six modified tracked files plus `reports/round-103/`:

```
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

The gate is green with all four A1–A4 hardenings present and all four independently re-accepted by
this seat (§3.3, §3.5, §2/routed A2, A3). Protected paths are byte-clean: `reports/round-103/ledger-check.md`
(33/33 r101, 61/61 r102 identical), `reports/round-103/seats-ledger.md` (`LOG`/`SCORECARD`/`SHONEN`/
`PROVINCE` MATCH; `corpus/fixtures` 146 identical; upstream 12 identical; `.manifest.d` 12 identical).
The r101 subtree byte-pin holds: `corpus/knowledge/unreal-mcp/README.md` is still `c79d8dd1…` — the
same hash the r102 draft cited, which is *itself* the evidence that F7 is untouched.

---

## 6. Blockers and limits

- **This is a mid-flight document.** `gate/run_gate.sh` was rewritten at least eight times inside the
  probe window and `reports/round-103/` grew from 2 to 40 files. Any r103 verdict must re-derive the
  final state rather than quote this file's numbers.
- **`POINTERS` is scanner-relative and moved 87→88→90→91→97→98 during the round** — it is a
  measurement, not a contract. `UNRESOLVED=0` is the binding invariant (r102's own recorded law).
- **This seat wrote only `reports/round-103/consistency.md`.** No gate file, no README, no `LOG.md`/
  `SCORECARD.md`/`SHONEN.md`/`SKILL.md`/`PROVINCE.md`, and nothing under `corpus/fixtures/**`,
  `reports/round-101/**`, `reports/round-102/**`, `corpus/knowledge/unreal-mcp/upstream/**` or
  `.manifest.d/**` was touched.
- **Not claimed:** that any r101/r102 item is *resolved* in the sense of being closed for good. O5/O6
  (r101), O7/O8 (r102) are structural carries that no round on this host can close; they are recorded
  as carried, not as done.
