# r102 round report — gate integration + routed-defect repair (game-dev-3d shokunin)

**Seat:** SEAT-46 REPORT-DRAFT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Round:** 102 · **Axes:** depth / coverage / calibration (coverage = lowest non-retired)
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
@ `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`) — re-confirmed still the tip of
`main` at `2026-10-18T17:41:23Z` (`reports/round-102/freshness-pin.md` §1)
**Landing commit:** `c6f655d055b0fb5f4921e01c2081b82d15d38ef5` — *to be filled at round close; the L1 lands one commit and
this report is the last artifact to land.*
**Report base HEAD at write:** `2c99b7b8155841617d844c609813afcba77aa207` (*"r101 report-last:
verdict (all axes improved), LOG entry, SCORECARD block, adjudication addendum — work
`1659c036`"*). Last measurement pass `2026-10-18T17:45:52Z` (final gate re-run `17:45:58Z`).
**Tracked-tree state at write [moving]:** `git status --porcelain` → **5 modified tracked files**
(`corpus/artifacts/unreal-r22/README.md`, `corpus/knowledge/engines.md`, `corpus/knowledge/rea.md`,
`corpus/knowledge/unreal-mcp/README.md`, `corpus/lessons/r22-unreal-review.md`) + **3 untracked
paths** (`corpus/knowledge/unreal-mcp/gate/`, `corpus/lessons/r102-unreal-integration.md`,
`reports/round-102/`); **54** entries with `-uall`. No `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
`SKILL.md`, `PROVINCE.md`, fixture byte or `reports/round-101/**` byte was modified this round
(`reports/round-102/ledger-check.md` verdict PASS; `reports/round-102/git-hygiene.md` verdict 0
violations).

**Concurrency disclosure.** This round's artifacts landed *while this report was being drafted* —
`reports/round-102/` grew 7 → 46 files during the drafting window, the C1 gate went from **absent**
to **present** between two consecutive tool calls of this seat, `corpus/knowledge/unreal-mcp/README.md`
changed sha256 three times, and `corpus/lessons/r102-unreal-integration.md` grew 178 → 212 lines.
Every number below is stamped with the command that produced it; counts and hashes that can still
move are marked **[moving]** and must be re-measured at `c6f655d055b0fb5f4921e01c2081b82d15d38ef5`.

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.
Numbers marked `{{…}}` are round-close slots this scribe cannot measure; every other number
below was produced by a command run on this host, in this session.

---

## Work performed

One bullet per item, each with its evidence pointer.

- **C1(a) — a self-contained, re-runnable close-out gate now exists in the corpus.**
  `corpus/knowledge/unreal-mcp/gate/run_gate.sh` (200 lines, sha256
  `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`) plus its spec
  `gate/README.md` (199 lines, sha256 `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`).
  Four checks, one `STEP=PASS|FAIL` line each, fail-closed. **This seat ran it independently**:
  `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `GATE RESULT: PASS (checks failed: 0)`,
  `rc=0`. Evidence: `reports/round-102/gate/author-run.txt` (author), `reports/round-102/gate/review.md`
  (SEAT-22 non-author, includes a cwd-independence run from `/tmp`), `reports/round-102/gate/mutation.md`
  (SEAT-18, 5/5 mutations caught), `reports/round-102/gate/controls.txt` (7 negative + 1 positive control).
- **C1(b) — lesson `corpus/lessons/r102-unreal-integration.md`.** 212 lines **[moving]**, sha256
  `c7f18f285cd11809c632277905bd306287603d0f3c0b1302d4bd95bcf26932cc` **[moving]**, 4 laws
  (pin-scoped vendoring · binary proven/unproven policy · the card-label ternary as one shared
  vocabulary · install-wall classes), a two-trap counting section, a re-run block, 6 next-iteration
  hooks. Evidence: `grep -n '^## ' corpus/lessons/r102-unreal-integration.md` → 7 sections.
- **C1(c) — `corpus/knowledge/engines.md` Unreal-row evidence-class update.** The row now names
  **two categorically different static evidence classes** — (a) r22 lane-authored `.uplugin` sample,
  (b) r101 third-party pinned tree — and states that neither proves plugin load, UBT compilation or
  engine runtime. The three.js row was repaired in the same file (F5, below). Evidence:
  `git diff -- corpus/knowledge/engines.md` → 2 lines changed (both rows), sha256
  `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`.
- **C2 — the routed-defect lattice is repaired, each with a captured before(fail)→after(pass).**
  Five routed defects + one wording fold: F1 (phantom `.shokunin/game-dev-3d/` root), F2 (absent
  `verdicts.json` citation), F3 (stale `run_battery.py` sha), F5 (`engines.md` three.js command fails
  from a clean tree), F6 (`rea.md` JADX/Binwalk/Unblob census), F8 (subtree README `:187` "12 lines"
  ambiguity). Evidence per defect in *Before → after* below; every pair re-run by this seat.
- **Non-author verification landed.** `gate/review.md` (SEAT-22) independently re-ran the gate from
  `/tmp` and re-derived all four pinned values with its own commands — **no drift from r101's
  recorded numbers**. `gate/mutation.md` (SEAT-18) **mutation-robust**: M1 byte-flip, M2 extra file,
  M3 deleted card, M4 stripped label, M5 corrupted manifest line, M6 bad pointer, M4b all-labels-removed
  → every one exits 1; **no mutation produced a false PASS**. `reruns/{manifest,labels,links,pointers}.md`
  re-derive the four checks with independently written scanners. `math-audit.md` (SEAT-58) recounts
  **62 numbers across 22 files: 60 VERIFIED / 2 WRONG / 2 unverifiable-by-construction**.
- **Adversarial reports argue the contrary where it matters.** `adversary/F3.md` (SEAT-13) argues the
  stale sha is an *archival content address*, not a false claim, and rules a dated note rather than a
  rewrite; `adversary/F5.md` (SEAT-14) splits F5 into two real sub-defects (a non-discriminating `3/3`
  token and a pointer/precondition split across two cells) and one adjacent defect; `adversary/F6.md`
  (SEAT-15) rules the census *correct at authoring*, rejecting the "wrong at mint" framing.
- **Close-out and hygiene audits.** `ledger-check.md` (append-only discipline PASS),
  `git-hygiene.md` (0 violations across every protected path), `battery-integrity.md` (146 tracked
  fixture files, 0 byte-mismatches vs HEAD; 350 `CASES` rows AST-parse on both worktree and HEAD blob),
  `before/baseline-integrity.md` (byte-stability reference), `reports-index.md` / `round-count.md` /
  `lesson-index.md` (SEAT-57/64/56 inventories; `lesson-index.md` verdict: **no edit** to
  `corpus/README.md`, which does not index `lessons/` at file granularity).
- **Zero-execution disclosure.** Unreal Editor is **not installed** on this host. The install wall was
  **re-run this round** (`install-recheck.md`, SEAT-60): `git ls-remote https://github.com/EpicGames/unreal-engine`
  → `Repository not found`, exit 128; `gh api repos/EpicGames/UnrealEngine` → 404; the AUR PKGBUILD
  still aborts at `prepare()` line 280. **Nothing changed since r101.** Every live-editor claim in this
  round is `unproven-on-this-host` by construction — labelled, never asserted. The gate's own README
  says so at `gate/README.md:20-22`: *"A green gate is not evidence of live-editor behavior and must
  never be cited as such."*

---

## Landed changes

Each row is tied to its r102 artifact and the commit that carries it (`c6f655d055b0fb5f4921e01c2081b82d15d38ef5` for everything
below, since the whole round lands in one commit).

| artifact | what it is | pointer |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | self-contained 4-check close-out gate, path-independent | `gate/run_gate.sh` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | the gate's spec: pinned constants, expected values, controls | `gate/README.md` |
| `corpus/lessons/r102-unreal-integration.md` | the round's distilled carry-forward lesson (4 laws) | `corpus/lessons/r102-unreal-integration.md` |
| `corpus/knowledge/engines.md` | Unreal row → two evidence classes; three.js row → `npm ci` precondition | `engines.md:10`, `:11` |
| `corpus/artifacts/unreal-r22/README.md` | F1: phantom path root removed (2 lines) | `corpus/artifacts/unreal-r22/README.md` |
| `corpus/lessons/r22-unreal-review.md` | F1/F2/F3: commands re-rooted + dated correction note | `corpus/lessons/r22-unreal-review.md:50` |
| `corpus/knowledge/rea.md` | F6: dated correction note appended, mint sentence preserved | `corpus/knowledge/rea.md:29` |
| `corpus/knowledge/unreal-mcp/README.md` | F8: sweep command now names both 12 and 24 `OK` counts | `README.md:169-170`, `:187`, `:189-202` |
| `reports/round-102/**` | 52 evidence artifacts across 6 subdirectories at the final frame **[moving]** | `reports/round-102/` |
| `reports/round-102/r102-report.md` | this report | this file |

**Not landed by this round (explicitly):** no `LOG.md` entry, no `SCORECARD.md` axis row, no
`SHONEN.md` box flip, no `SKILL.md` or `PROVINCE.md` edit. Measured: `grep -c 'ROUND 102' LOG.md`
→ `0`; `grep -c 'Round 102' SCORECARD.md` → `0`; `grep -c '^- \[x\]' SHONEN.md` → `1` (unchanged
from r101 — box 2 only). These are the L1's to land at close.

---

## Before → after measurements

One block per claim. Each carries the counting command and the revision it was measured against.
All commands were run from the lane root unless the block says otherwise.

**Measured revision:** report base HEAD `2c99b7b`, with the r102 artifacts on disk (this is the
surface the gate below was run against). At round close the same commands must be re-run on
`c6f655d055b0fb5f4921e01c2081b82d15d38ef5`; a number that does not reproduce there is a FAIL for its claim.

### C1(a) — coverage: the gate is self-contained and green

| measurement | command | before | after |
|---|---|---|---|
| gate exists | `test -e corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **absent** (`before/baseline-integrity.md` §4: `GATE_ABSENT`) | **present**, 200 lines, sha256 `214bf8ef…411e` |
| gate spec exists | `test -e corpus/knowledge/unreal-mcp/gate/README.md` | absent | **present**, 199 lines, sha256 `def732c9…7ec8` |
| gate verdict (this seat, independent) | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo rc=$?` | n/a | **`GATE RESULT: PASS (checks failed: 0)`, `rc=0`** |
| check 1 manifest | same output | n/a | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` / `STEP=PASS` |
| check 2 clone | same output | n/a | `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0` / `STEP=PASS` |
| check 3 cards | same output | n/a | `CARDS=13 EXPECTED=13 BAD=0`; `CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0` / `STEP=PASS` |
| check 4 pointers | same output | n/a | `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `STEP=PASS` |
| cwd-independence | run from `/tmp` (SEAT-22, `gate/review.md` §2) | n/a | `SUBTREE=/home/vgpnk/.../unreal-mcp`, `GATE RESULT: PASS`, exit 0 — the "run from anywhere" claim holds |
| mutation robustness | `reports/round-102/gate/mutation.md` matrix | n/a | **7/7 mutations exit 1**, no false PASS |
| negative controls | `reports/round-102/gate/controls.txt` | n/a | C1 byte-flip → FAIL(2 checks); C2 delete file → FAIL(2); C3 OOR pointer → FAIL(1); C4 dup label → FAIL; C6 remove card → FAIL(1); **C7 exact-sentinels-only → PASS, `SKIPPED_CONTROL_SENTINELS=2`** (positive control) |
| independent re-derivation | `reruns/{manifest,labels,links,pointers}.md` | n/a | manifest PASS · labels PASS · links `6 md / 3 links / 0 broken` PASS · pointers `47 / 0` PASS |
| non-author review of pinned values | `reports/round-102/gate/review.md` §1 | n/a | **no pinned value drifts from r101's recorded numbers** |
| upstream freshness | `git ls-remote <url> main` | pin | **pin is still the tip of `main`** (`freshness-pin.md`) |

**Known scope boundaries this claim does not close** (stated, not hidden):

- **The gate's pointer regex under-covers, and the two tools disagree on the same tree.**
  `r102-connector.md` §3: the gate regex has no `([,-][0-9]+)*` group, so on a pointer written
  `upstream/README.md:50-57` it matches only `:50` and silently discards the `-57` endpoint.
  Measured on the live tree: **gate-style total 40 vs sweep-style total 47 — a 7-endpoint delta,
  exactly the range/comma endpoints the gate cannot see.** The gate's `POINTERS=40` is therefore
  correct *for its own convention* and is r101's subtree number (`r101-report.md:146`); it is not
  the 47/78 figures. This is a **scope distinction, not a drift** — but a reader who expects the
  gate to print 78 will be misled, so it is called out (`gate/review.md` §1).
- **The gate writes no receipt and is reachable from no standing harness.**
  `r102-connector.md` §3: `grep -rln "run_gate"` over the tracked harness → rc=1, nothing; the
  digest map has **0 gate refs out of 130**. Its result survives only as a hand-pasted transcript,
  which is the very "read nothing from an author's transcript" failure the gate's own README
  (`gate/README.md:9`) claims to avoid.
- **The gate requires the network.** Check 2 clones upstream; offline it exits 1. That is correct
  fail-closed behaviour, but it means the gate cannot run in an air-gapped close-out, and folding it
  into the battery would import that dependency into a harness that is currently network-free.
- **A green gate must not be read as F7 being closed.** Check 3 enforces *one label per card from
  the allowed ternary*; the cards pass that check. It does **not** judge whether a label is
  *consistent with its evidence*, so the F7 vocabulary collision stays open while C1 is green
  (see Open items 2).

### C1(b)/(c) — coverage/depth: the lesson and the engines row

| measurement | command | before | after |
|---|---|---|---|
| r102 lesson exists | `test -e corpus/lessons/r102-unreal-integration.md` | **absent** (`before/baseline-integrity.md` §4: `LESSON_ABSENT`) | **present**, 212 lines **[moving]**, sha256 `c7f18f28…32cc` **[moving]** |
| lesson section count | `grep -c '^## ' …` | 0 | **7** (4 laws + 2 counting traps + re-run + hooks) |
| lesson files in `corpus/lessons/` | `ls corpus/lessons \| wc -l` | 92 (r101 report §Round-level deltas) | **93** (+1) **[moving]** |
| `engines.md` sha256 | `sha256sum corpus/knowledge/engines.md` | `b20e5a9b…d06e` (r101, `before/baseline-integrity.md` §4) | `d03907d3…bddf` |
| Unreal row evidence classes | `git diff -- corpus/knowledge/engines.md` | 1 class (r22 self-authored sample) | **2 classes** — (a) lane-authored, (b) third-party pinned tree — with the authority distinction stated |
| Unreal row install state | `grep -n Unreal corpus/knowledge/engines.md` | `installed: no / executable headless: no` | **unchanged** — `no / no` (correct; the row may not move on static evidence, `engines.md:13-16`) |
| three.js row | same diff | bare `node …run_cases.mjs` → 3/3 | `npm ci --prefix corpus/fixtures/three && node …run_cases.mjs` → 3/3, exit 0 (F5) |

### C2 — depth: the routed-defect lattice, each before(fail) → after(pass)

Every pair below was **re-run by this seat**, not copied from the repair report.

**F1 — the phantom `.shokunin/game-dev-3d/` root** (r22 README + r22 lesson; the directory never existed)

| | command | observed |
|---|---|---|
| before | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py` | `can't open file '…/.shokunin/game-dev-3d/…': [Errno 2] No such file or directory`, **exit 2** |
| after | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` | `PASS local-static actual=accept expected=accept …`, **exit 0** |
| after (control) | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject` | `PASS local-static actual=reject expected=reject reason=unsupported module Type: 'Unknown'`, **exit 0** — the pair still discriminates |
| residual | `grep -n "shokunin/game-dev-3d" corpus/artifacts/unreal-r22/README.md` | no output, grep exit 1 |
| residual (lesson) | `git diff -- corpus/lessons/r22-unreal-review.md` | 6 command lines re-rooted (lines 7, 23, 25, 29, 42, 44) — mechanical conformance, in place |

**F2 — the r22 lesson cites a receipt that is absent and gitignored**

| | command | observed |
|---|---|---|
| before | `ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json` | `No such file or directory`, **exit 2**; parent dir absent too |
| gitignore | `git check-ignore -v corpus/live/runs/20261013T053632289732Z/verdicts.json` | `corpus/.gitignore:1:live/` — the whole `corpus/live/` tree is untracked, so the receipt can never be in a clone |
| history | `git log --all --oneline -- corpus/live/runs/…`; `git ls-files corpus/live` | both **empty** (exit 0) — no commit ever added the path |
| after | `tail -20 corpus/lessons/r22-unreal-review.md` | **dated correction note present** — the sentence is preserved verbatim as the r22 record, and the note states the digest is *uncheckable by construction* and survives only as text |
| after (control) | `grep -c 'r102' corpus/lessons/r22-unreal-review.md` | `2` |

**F3 — the stale `run_battery.py` sha citation**

| | command | observed |
|---|---|---|
| cited (stale) | `grep -rn 'a065a56d' corpus/lessons/` | still at `corpus/lessons/r22-unreal-review.md:48` — the historical sentence was **not** silently rewritten |
| current | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (346 248 B) |
| cited digest is real, in history | `git cat-file blob 490e710d:corpus/fixtures/run_battery.py \| sha256sum` | `a065a56d…` — so the r22 number was *accurate for its moment*, not fabricated |
| after | `tail -20 corpus/lessons/r22-unreal-review.md` | the dated note states the cited digest is the **r21/r22-era blob**, reproducible only from history, and gives the current tree digest as the contrast |
| adversary ruling | `reports/round-102/adversary/F3.md` | SEAT-13 argues F3 is **archival, not stale**, and rules a dated note — which is what landed |

**F5 — the `engines.md` three.js evidence command fails from a clean tree** (this seat re-ran both sides)

| | command | observed |
|---|---|---|
| before (pristine export of HEAD, no `node_modules/`) | `git archive HEAD corpus/fixtures/three \| tar -x -C /tmp/x && cd /tmp/x && node corpus/fixtures/three/run_cases.mjs` | `FAIL positive: exit=1 expected=0` ×4 lines, **exit 1** |
| root cause | `node corpus/fixtures/three/scene_graph.mjs` in that tree | `ERR_MODULE_NOT_FOUND: Cannot find package 'three'` — the package is gitignored (`corpus/fixtures/three/.gitignore:1`), so a clone has none |
| after (same pristine tree) | `npm ci --prefix corpus/fixtures/three --offline && node corpus/fixtures/three/run_cases.mjs` | `PASS positive/negative_wrong_order/mutation` + `PASS three battery: 3/3, seeds_unchanged=true`, **exit 0** (`npm_rc=0`) |
| live tree (both sides) | `node corpus/fixtures/three/run_cases.mjs` | `PASS … 3/3`, exit 0 — the failure is the *dependency presence*, not the fixture, runner, Node version or path form |
| after (citation) | `git diff -- corpus/knowledge/engines.md` | the evidence cell now carries the `npm ci --prefix` precondition; the historical `→ 3/3` was **not** rewritten |

**F6 — the `rea.md` JADX/Binwalk/Unblob census**

| | command | observed |
|---|---|---|
| before | `grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md` | `1` (stale blanket claim present) |
| host reality | `which jadx binwalk unblob` | `/usr/bin/jadx`, `/usr/bin/binwalk`, `/home/vgpnk/.local/bin/unblob`, **exit 0** — the claim is false for 3 of 4 names |
| after (preservation) | same grep | **still `1`** — the mint sentence is preserved verbatim, per correction-note discipline |
| after (correction) | `grep -c "Correction note (r102" corpus/knowledge/rea.md` → `1`; `sed -n '29,45p'` | dated note present: JADX 1.5.6 / Binwalk 3.1.0 / Unblob 26.6.4 all exit 0; **pwntools present but only via `$REA_PWNTOOLS_PYTHON`** (plain `python3` still fails) — a narrower statement than the before-capture's |
| controls (clauses still true) | `reports/round-102/repairs/F6-rea-census.md` §5 | Ghidra absent, no `rea` CLI — both census clauses **still true**, so the note does not overclaim |
| adversary ruling | `reports/round-102/adversary/F6.md` | SEAT-15 sustains the author: the census was **correct when authored**; the "wrong at mint" framing is rejected as unsupported |

**F8 — the subtree README `:187` "12 lines" ambiguity (wording fold)**

| | command | observed |
|---|---|---|
| before | `sha256sum -c .manifest.d/*.sha256 2>&1 \| grep -c ': OK'` (from `corpus/knowledge/unreal-mcp`) | **24** — but the README's caption said "12 lines" under the glob command |
| after | `git diff -- corpus/knowledge/unreal-mcp/README.md` | the block now names **both** commands and **both** counts: `audit-reference.sha256` → 12 `OK`; `*.sha256` → 24 `OK`, with the seat-shard explanation and the full 24-line output reproduced |
| re-measured | same command | **24** — matches the corrected text |
| byte-pin discipline | `git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` | **empty** — the fold touched only the non-pinned index file; the pinned `upstream/` + `.manifest.d/` are byte-identical to HEAD (`git-hygiene.md`) |

### Round-level deltas (unchanged surfaces, measured so they are known not to have moved)

| surface | command | value |
|---|---|---|
| battery rows | AST parse of `CASES` in `corpus/fixtures/run_battery.py` | **350** (worktree and HEAD blob identical, sha256 `f456bd00…f69f`, blob `dd2d9b74…`) |
| fixture byte-stability | 146 tracked fixture files, blob-id vs HEAD | **0 mismatches**; index vs HEAD aggregate `827af6c3…` equal |
| `corpus/fixtures/` diff vs HEAD | `git diff --stat HEAD -- corpus/fixtures/` | **empty** — zero fixture bytes changed this round |
| subtree file count | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | **42** (was 40 at r101; +2 = the new `gate/` files) **[moving]** |
| subtree aggregate sweep hash | `find … \| sort \| xargs sha256sum \| sha256sum` | r101 close `be1895e3f19421c62853109075fccf3c7653638be1389ca92d6402942d65c0b0` — **this value no longer reproduces**: it is now `b2a9503039cb53f08fe277324e59b80468ea128c542a5a602112c0a689f9d185` over 42 files, because the non-pinned `README.md` was folded and `gate/` was added. The **pinned region alone** (`upstream/` + `.manifest.d/`, 24 files) hashes to `c9ac2683cebcef6404c058b0baaa747bd37d858a8e59aff05938e7e6eef4d442` and is unaffected (`git-hygiene.md`) |
| `LOG.md` / `SCORECARD.md` last round | `grep -c 'ROUND 102' LOG.md`, `grep -c 'Round 102' SCORECARD.md` | **0 / 0** — r102 not yet recorded (expected pre-adjudication) |
| `SHONEN.md` checked boxes | `grep -c '^- \[x\]' SHONEN.md` | **1** (box 2 only) — unchanged |
| round-102 report files | `find reports/round-102 -type f \| wc -l` | **52** at the final frame `17:47:07Z` **[moving]** — was 46 at `17:45:52Z` and 40 at `17:45:19Z`, so it was still rising when this report was written; r101 closed at 33 |
| modified tracked files | `git status --porcelain \| grep -c '^ M'` | **5** **[moving]** |
| untracked paths at write | `git status --porcelain -uall \| wc -l` | **54** **[moving]** |
| r101 subtree byte-pin | `git diff --name-only HEAD -- …/upstream …/.manifest.d` | **empty** — still pinned |

---

## SHONEN 4-box lines

`SHONEN.md` currently reads box 2 `[x]` and boxes 1, 3, 4 `[ ]` (`grep -c '^- \[x\]' SHONEN.md` → 1).
Per the skill's report shape, one line per box. Marks below are this round's **evidence pointers**,
not self-attested checks: a `[x]` requires a named non-author verifier, a `[~]` is the lane's own
assessment with a resolvable pointer, and an untouched box stays `[ ]`.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]`
  Round r102 adds a **drafted** decision table — *"Unreal-content claim discipline"*, four exhaustive
  claim types, each row's canonical command run on this host
  (`reports/round-102/skill-decision-table-draft.md`, SEAT-40) — plus the gate's pinned-constants
  table and four documented negative controls (`gate/README.md:28-40`, `reports/round-102/gate/controls.txt`).
  The draft is explicitly **not landed**: `SKILL.md` does not exist in this lane (shonen seed form,
  `README.md:11`) and is not this seat's to write. Box stays open until a non-author verifier accepts
  the table as the skill's own and a seat lands it into a real `SKILL.md`. Verifier: none named this
  round — queued for a future promotion review.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2 —
  `game-dev-3d-r2-review-retry` independently reproduced both battery commands, the mutation
  rejection and the source contact-plane derivation (`corpus/lessons/r2-independent-review.md`).
  **r102 does not add an end-to-end task**: no Unreal Editor exists on this host, so the round's own
  work is static/format evidence by construction, and no runtime claim is made anywhere. The new
  gate is an *artifact-level* end-to-end run (it executes four checks and resolves its own subject),
  but it is not a domain task and this seat does not claim it as one.
- **Box 3 — instructions executable without oral context.** `[~]` Strengthened this round, and the
  strengthening is the round's headline. r101's four checks lived in `/tmp/r101-closeout/` and in a
  protocol heredoc — a `/tmp` stopgap that does not survive a reboot. r102 lands them **in the
  corpus** as `gate/run_gate.sh`, path-independent (resolves the subtree from `BASH_SOURCE`), with
  its expected values pinned in `gate/README.md`. This seat executed it with no author input and got
  `GATE RESULT: PASS (checks failed: 0)`, `rc=0`; SEAT-22 re-ran it from `/tmp` and got the same
  verdict. `r102-unreal-integration.md` §Re-running the gate carries the re-run block. Residual
  blockers on this box, all named by `r102-connector.md` §3 and **not** closed: the gate writes no
  receipt, is reachable from no standing harness (0 gate refs in a 130-entry digest map), and
  requires the network. Verifier: SEAT-22 `gate/review.md` — a **named non-author** that re-ran the
  gate and independently re-derived all four pinned values. This box is the strongest candidate for
  `[x]` at adjudication, and the L1 should rule on whether the three residual blockers bar it.
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` Every r102 artifact lives
  under the lane's own write scope: `corpus/knowledge/unreal-mcp/gate/**`,
  `corpus/lessons/r102-unreal-integration.md`, `reports/round-102/**`, plus four authorized in-place
  conformance fixes inside `corpus/`. `reports/round-102/git-hygiene.md` (SEAT-51) independently
  reports **0 violations**: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`,
  `corpus/fixtures/**` and `reports/round-101/**` are all content-identical to HEAD.
  `reports/round-102/ledger-check.md` (SEAT-55) independently confirms append-only discipline across
  332/332 prior-round tracked files. The work is **static inspection in service of 3D craft
  evidence**, which `PROVINCE.md` explicitly permits for engines that cannot execute headless. No 2D,
  harness-audit, lore or live-target surface was touched. Verifier: SEAT-51 + SEAT-55 (both named
  non-authors) — but neither was asked to rule on `PROVINCE.md` accuracy specifically, so this seat
  keeps it `[~]`.

---

## Reproduce at close

Run from the lane root, on `c6f655d055b0fb5f4921e01c2081b82d15d38ef5`, after the untracked artifacts are committed:

```sh
# C1a — the gate, one command, four checks, fail-closed
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# expected 2026-10-18T17:45Z: GATE RESULT: PASS (checks failed: 0), rc=0
#   MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0 / STEP=PASS
#   CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0 / STEP=PASS
#   CARDS=13 EXPECTED=13 BAD=0; CENSUS static-only=12 unproven-runtime=1 verified-here=0 / STEP=PASS
#   POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0 / STEP=PASS

# C1b — the lesson
grep -n '^## ' corpus/lessons/r102-unreal-integration.md     # 7 sections
grep -c 'Correction note (r102' corpus/knowledge/rea.md       # 1
grep -c 'r102' corpus/lessons/r22-unreal-review.md            # 2

# C1c — the engines row
git diff -- corpus/knowledge/engines.md | grep -c '^[+-]'     # 4 (2 lines, both rows)

# C2 — F1 / F5 / F6 / F8 before→after
python3 corpus/artifacts/unreal-r22/verify_descriptor.py                                   # exit 0
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject  # exit 0
git archive HEAD corpus/fixtures/three | tar -x -C /tmp/x && (cd /tmp/x && node corpus/fixtures/three/run_cases.mjs)   # exit 1 (F5 before)
(cd /tmp/x && npm ci --prefix corpus/fixtures/three --offline && node corpus/fixtures/three/run_cases.mjs)             # exit 0 (F5 after)
which jadx binwalk unblob                                                                  # all resolve, exit 0
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK')  # 24

# round-level invariants
sha256sum corpus/fixtures/run_battery.py        # f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
git diff --stat HEAD -- corpus/fixtures/       # empty
find reports/round-102 -type f | wc -l         # 40 → 46 → 52 during drafting; [moving], still rising
```

The gate is also reproduced inline in `reports/round-102/gate/{author-run.txt,controls.txt,mutation.md}`,
so a verifier never depends on a leftover `/tmp` file.

---

## Open items for the L1 / adjudicator

1. **`c6f655d055b0fb5f4921e01c2081b82d15d38ef5`** — this report is written pre-landing; the hash slot and every
   round-close number above must be filled from the committed tree. Counts marked **[moving]**
   (`reports/round-102/` file count, the lesson's line count and sha256, the subtree file count,
   the modified-file set) moved repeatedly during drafting and are the likeliest to need
   re-measurement. **`LOG.md` and `SCORECARD.md` carry zero r102 entries** — the L1's to land.
2. **F7 — the card-label vocabulary collision — is UNASSIGNED and still open, and it is the
   round's highest-value gap.** `corpus/knowledge/unreal-mcp/README.md:41` defines
   `unproven-runtime` as *"the claim needs the live editor and nothing was observed"*; **six of the
   thirteen cards** explicitly reject that label on the ground that the runtime path *"is not even
   identified"* — the same condition, opposite label
   (`grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → 6).
   **The gate cannot see this by construction** (check 3 only enforces one allowed label per card),
   so **C1 can be green while F7 stays open — a green gate must not be read as F7 being closed**
   (`r102-distiller.md` §G1; 0 of 40 r102 files address it).
3. **The gate under-covers range-form pointers, and the gate and the sweep disagree on the same
   tree: 40 vs 47.** The delta is exactly the 7 range/comma endpoints the gate's regex cannot see
   (`upstream/README.md:50-57` → only `:50` is checked). Adopt the range-aware regex from
   `reports/round-102/reruns/pointer-sweep.sh` and expand every endpoint
   (`r102-connector.md` §3).
4. **The gate writes no receipt and is reachable from no standing harness** (0 gate refs in the
   130-entry digest map; `grep -rln "run_gate"` over the harness → rc=1). Its green verdict survives
   only as a hand-pasted transcript. Concrete landing options are named in `r102-connector.md` §3:
   a `--receipt <path>` flag mirroring `three/run_cases.mjs`, and a minimal `--vendor-gate` flag on
   `run_battery.py`.
5. **The gate requires the network** (check 2 clones upstream; offline it exits 1 — correct
   fail-closed behaviour, but it cannot run in an air-gapped close-out). Either document the
   precondition at the call site or add an explicit `--offline` mode that degrades check 2 to
   "manifest + blob ids vs a caller-supplied cached clone" **and prints that it degraded**.
6. **`math-audit.md` (SEAT-58) found 2 WRONG numbers, both minor and both self-disclosed**: the
   `three/node_modules/` file count (`battery-integrity.md` says 1410; measured **1264**) and
   `adversary/F3.md`'s byte count/sha in `reports-index.md` (the file was rewritten by its author
   after that frame). Neither affects a load-bearing conclusion. **No claim that affects the
   byte-pin, the gate's four checks, the 350 `CASES` rows, the 12/24 manifest counts or the 13-card
   census was wrong.**
7. **No live-editor evidence exists or can exist here.** Engine install is blocked pending operator
   Epic-account linking; re-checked this round, **nothing changed** (`install-recheck.md`). Every
   runtime claim in this round is `unproven-on-this-host`; nothing in the round asserts otherwise.
8. **Adversarial findings that the L1 should rule on, not silently absorb**: `adversary/F3.md`
   rules the stale sha an *archival content address* rather than a false claim; `adversary/F5.md`
   splits F5 into two genuine sub-defects and an adjacent one in `corpus/fixtures/three/README.md:6`
   (a dead path root of the F1 class, **not repaired this round**); `adversary/F6.md` rejects the
   before-capture's "wrong at mint" framing. The landed repairs are consistent with all three
   rulings, but the rulings themselves are the adjudicator's to accept or overrule.

---

## L1 adjudication (close-out)

*To be filled at round close by the L1, after the work commit lands as `c6f655d055b0fb5f4921e01c2081b82d15d38ef5` and this
report is the last artifact to land.*

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** coverage **improved** · depth **improved** · calibration **unchanged** (no C3
claim declared; the axis was exercised — scanner-relative datum recorded — not moved). The
round **admits** (work commit `c6f655d055b0fb5f4921e01c2081b82d15d38ef5`; this report lands
last).

**Close-of-round re-measurements** (on `c6f655d`, idle host): subtree files **42** (40 + 2
gate files; edits to README/lesson change bytes, not counts); `reports/round-102/` files
**58** at the final frame; `corpus/lessons/` **93** (+1); gate re-run `GATE RESULT: PASS
(checks failed: 0)` rc=0.

**Gate-hardening fold (the round's most important catch).** The gate as landed by SEAT-17
passed its own controls but had **demonstrated false-pass classes**: SEAT-20 ran 11 content
corruptions against it (symlinked upstream file, 14th card via subdir/symlink, substring
labels `NOT-static-only`/`static-onlyness`, CRLF manifest, emptied seat shards, non-`upstream/`
dangling pointers, space-in-name, `:0` lines, uppercase `.MD`) — **all stayed green**;
SEAT-21 found `comm` absent from PATH prints `PATH_EXTRA=0` over a stray file (aggregate
exit 0 on a real defect) and the extensionless-target sweep gap. The close adopted the
seat-verified hardened implementation (`/tmp/advgate/hardened.sh`, which flips 11/11 of
SEAT-20's attacks to detected) plus two L1 fixes: a tool-requirement guard (`git sha256sum
grep find sort comm` — any missing → `FAIL required tool missing` + exit 1) and an
extensionless `upstream/<name>:<line>` pointer pattern. Re-verified at close against the
installed script: **11/11 attacks DETECTED, zero false-passes**; comm-absent → exit 1;
planted `upstream/LICENSE:99999` → exit 1 (UNRESOLVED). Residual hardening queue (fold-spec
A1–A4: range-tail blindness, prose-hijackable first-token rule, card-name comparison,
network-blocked-vs-mismatch) is routed to r103, not silently deferred.

**Other folds landed at close:** lesson D1 ("now 0 in both r22 files") corrected to the
measured 0/1 with the surviving hit identified as the correction note's own quote; the
lesson's stale "Two remain live" snapshot corrected (both fell as dated correction notes
later in the round); gate README expected-value block updated (POINTERS 40→87 with the
scanner-relative rule; "three mutations" wording; hardening-history note).

**Calibration datum (recorded, load-bearing):** pointer counts are scanner-relative — the
r101 protocol script, the r102 gate, and the r101 `/tmp` script read **40 / 41 / 43** on the
same tree. The binding invariant is `UNRESOLVED=0` under a named scanner; a bare `POINTERS=`
number is under-specified (dissonance-hunter C1–C5, all re-verified).

**Battery boundary (routed, honest):** the battery's bytes are untouched this round (`git
diff -- corpus/fixtures` empty; `run_battery.py` `f456bd00…` stable) — but a fresh full run
is **not green on this host**: r94_cannon markers pin `node=v24.21.0` while the host runs
node v26.12.0. Idle-host close-out run (2026-10-18T18:13Z, receipt
`corpus/live/runs/20261018T181301123479Z/verdicts.json`): **cases=350 pass=336 fail=14, exit
1** — 13 `r94_cannon_*` rows (marker-mismatch class) + `phys3d_joints_free_ops` (fails on an
idle host too; failure class uninvestigated this round). The receipt is gitignored
(`corpus/.gitignore:1`), so this row list is the durable record. This is environment-marker
drift on pinned rows, not fixture corruption; routed to the operator queue (side-by-side
node pin or marker re-baseline; the physics row gets an r103 investigation seat) — never
fixed silently mid-round.

**Routed queue (r103+, full list in LOG.md ROUND 102):** fold-spec A1–A4; kimi-surfaces
freshness note for `adaptation-kimi.md` (proposed text in `kimi-surfaces.md` §4); B2 dead
`.shokunin` root in three more runnable READMEs (glb-r12, unity-r19, three — systemic
ruling); math-audit's two wrong rows; battery node-marker drift.

**L0 (operator, unchanged from r101):** Epic account linking? pull the 26.8 GB
`wukakuki/unreal-engine:dev-slim-5.8.3` image? Lutris path? All static work proceeds
without them.

**Honest limits:** no live-editor evidence exists or can exist here; C1's gate proves
byte-identity and labeling discipline only; several r102 report frames were taken on a
live tree — every number in this addendum was re-measured on `c6f655d` at close.
