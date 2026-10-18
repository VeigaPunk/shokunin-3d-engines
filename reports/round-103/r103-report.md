# r103 round report — freshness note + gate hardening A1–A4 + dead-root ruling (game-dev-3d shokunin)

**Seat:** SEAT-48 REPORT-DRAFT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Round:** 103 · **Axes:** depth / coverage / calibration (coverage = lowest non-retired)
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
@ `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`) — re-confirmed still the tip of `main`
this round (`reports/round-103/freshness-pin.md` §1, observed `2026-10-18T18:32:24Z`)
**Landing commit:** `8c9d9ad70b86c4408ac9d43e742076840b7c40db` — *to be filled at round close; the L1 lands one commit and
this report is the last artifact to land.*
**Report base HEAD at write:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (*"r102 report-last:
verdict (coverage/depth improved, calibration unchanged), LOG + SCORECARD, gate-hardening +
battery-boundary addendum — work `c6f655d`"*). Last measurement pass `2026-10-18T18:37:38Z`.
**Tracked-tree state at write [moving]:** `git status --porcelain` → **6 modified tracked files**
(`corpus/artifacts/glb-r12/README.md`, `corpus/artifacts/unity-r19/README.md`,
`corpus/fixtures/three/README.md`, `corpus/knowledge/unreal-mcp/adaptation-kimi.md`,
`corpus/knowledge/unreal-mcp/gate/README.md`, `corpus/knowledge/unreal-mcp/gate/run_gate.sh`)
+ **1 untracked path** (`reports/round-103/`); **42** entries with `-uall`.
`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md` are all byte-identical to HEAD
(`git hash-object` vs `git rev-parse HEAD:<path>` → MATCH ×4, this seat).

**Concurrency disclosure.** This round's artifacts landed *while this report was being drafted*, and
the **gate script itself moved six times in ~20 minutes** (`reports/round-103/gate/exit-codes.md` §1
records the series: `412d1b84` 18:31Z → `b5fecfc1` 18:35Z → `ff2c26c0` → `f23f3c8c` → `d226af6f` →
`0c1ca3e1` 18:36Z). This seat observed the gate at **four** distinct verdicts during its window,
including two transient REDs (`UNRESOLVED=1` on a sibling's not-yet-written citation) and one
transient BLOCKED (a real network drop, which the new A4 channel reported correctly). `reports/round-103/`
grew **1 → 36 files** during this seat's window. Every number below is stamped with the command that
produced it; counts and hashes that can still move are marked **[moving]** and must be re-measured at
`8c9d9ad70b86c4408ac9d43e742076840b7c40db`.

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.
Numbers marked `{{…}}` are round-close slots this scribe cannot measure; every other number below was
produced by a command run on this host, in this session.

---

## Work performed

One bullet per item, each with its evidence pointer.

- **C1 (coverage) — the `adaptation-kimi.md` freshness note landed as a dated correction note.**
  `corpus/knowledge/unreal-mcp/adaptation-kimi.md` grew **+143 lines / −0 lines** (363 → **506**
  lines, sha256 `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`), appending
  `## Correction note — 2026-10-18 (r103)` at `:367` with three sub-sections **C1/C2/C3** at
  `:380`, `:416`, `:442`. **No line above the heading was altered** — the r101 table stands verbatim
  as the historical record. This seat independently re-ran two of the three classes:
  `curl` on `customization/{plugins,hooks}.html` → bare **404**, `/en/`-prefixed **200** ×4; and
  `grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml` → **`3290:[[hooks]]`** (file now 3322 lines).
  Evidence: `reports/round-103/note/author.md` (author), `note/verify.md` (SEAT-03 non-author, four
  criteria PASS), `note/configline.md` (SEAT-60 independent derivation of 3290), `note/urls.md`,
  `note/crosscheck.md` (SEAT-08 sweep for other citations of the same stale targets),
  `note/rows.md` (all 15 rows re-run), `note/binary.md` (§5 pin intact), `note/adversary.md` (SEAT-04
  argues addendum-vs-row-edit and rules).
- **C2 (depth) — gate hardening A1–A4 on `corpus/knowledge/unreal-mcp/gate/run_gate.sh`, all four
  landed and all four independently attacked.** The script went **249 → 341 lines** (+138/−48 net vs
  HEAD, sha256 `0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`). This seat
  **re-ran every one of the four attacks on throwaway copies** and each now behaves as A1–A4
  specified — see *Before → after* below. Evidence: `reports/round-103/gate/a2-attack.md` (SEAT-12),
  `a3-attack.md` (SEAT-13), `a4-attack.md` (SEAT-14), `mutations.md` (SEAT-19, 3 classic mutations vs
  the installed gate), `docs-sync.md` (SEAT-20, README-vs-script drift flags), `exit-codes.md`
  (SEAT-61, exit-code design review), `final-run.md` (SEAT-53 receipt), `clean.md` + `clean.raw.txt` +
  `clean.now.txt` (SEAT-10).
- **C3 (calibration) — the dead `.shokunin/game-dev-3d/` roots in runnable contexts are repaired
  3/3, and the `phys3d_joints_free_ops` row is investigated (not repaired).** All three routed
  READMEs now grep **0**: `corpus/fixtures/three/README.md` (17 lines), `corpus/artifacts/glb-r12/README.md`
  (3), `corpus/artifacts/unity-r19/README.md` (2). The battery row's failure class is
  **harness-timeout, not engine behaviour and not a fixture defect** — independently reproduced by
  this seat. Evidence: `reports/round-103/b2/{repair-glb,repair-three,verify-unity,verify-three,scanner,postgrep,adversary}.md`,
  `reports/round-103/physics/investigate.md` (SEAT-32), `reports/round-103/pathroot-sweep.md` (SEAT-58).
- **Non-author verification and round hygiene landed.** `ledger-check.md` (SEAT-39) and
  `seats-ledger.md` (SEAT-55) both confirm **every protected path byte-identical to HEAD**;
  `subtree-integrity.md` (SEAT-54) confirms the pinned region is byte-stable;
  `install-recheck.md` (SEAT-57) re-runs the three install receipts with **zero deltas**;
  `freshness-pin.md` (SEAT-56) re-confirms the pin; `r103-scribe-audit.md` (SEAT-42) inventories this
  round's own report tree; `r103-distiller.md` (SEAT-36) re-derives all three claims mid-flight;
  `skill-table-review.md` (SEAT-59) re-reviews the r102 decision-table draft.
- **Zero-execution disclosure.** Unreal Editor is **not installed** on this host. The install wall was
  **re-run this round** (`install-recheck.md`, SEAT-57): `git ls-remote https://github.com/EpicGames/unreal-engine`
  → `Repository not found`, exit 128; `gh api repos/EpicGames/UnrealEngine` → 404; the AUR PKGBUILD
  still aborts at `prepare()` line 280. **Nothing changed since r101.** Every live-editor claim in
  this round is `unproven-on-this-host` by construction — labelled, never asserted. The gate's own
  README says so at `gate/README.md:20-22`: *"A green gate is not evidence of live-editor behavior
  and must never be cited as such."*

---

## Landed changes

Each row is tied to its r103 artifact and the commit that carries it (`8c9d9ad70b86c4408ac9d43e742076840b7c40db` for
everything below, since the whole round lands in one commit).

| artifact | what it is | pointer |
|---|---|---|
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | C1: dated correction note, 3 citation classes, +143 lines, zero deletions | `adaptation-kimi.md:367` |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | C2: A1 range-endpoint loop · A2 anchored label rule · A3 pinned card-name set · A4 BLOCKED/exit 2 + `GATE_REF` · `/tmp/advgate` → `mktemp` | `gate/run_gate.sh` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | C2: re-pinned expected values + pointer-count pin correction note | `gate/README.md:129`, `:204` |
| `corpus/artifacts/glb-r12/README.md` | C3: 3 dead-root command lines re-rooted | `corpus/artifacts/glb-r12/README.md:6-8` |
| `corpus/artifacts/unity-r19/README.md` | C3: 2 dead-root `uv run` lines re-rooted | `corpus/artifacts/unity-r19/README.md:10-11` |
| `corpus/fixtures/three/README.md` | C3: 17 dead-root lines re-rooted (prefix strip only) | `corpus/fixtures/three/README.md` |
| `reports/round-103/**` | 36 evidence artifacts across 4 subdirectories at the final frame **[moving]** | `reports/round-103/` |
| `reports/round-103/r103-report.md` | this report | this file |

**Not landed by this round (explicitly):** no `LOG.md` entry, no `SCORECARD.md` axis row, no
`SHONEN.md` box flip, no `SKILL.md` or `PROVINCE.md` edit. Measured: `grep -c 'ROUND 103' LOG.md`
→ `0`; `grep -c 'Round 103' SCORECARD.md` → `0`; `grep -c '^- \[x\]' SHONEN.md` → `1` (unchanged
from r102 — box 2 only). These are the L1's to land at close.

---

## Before → after measurements

One block per claim. Each carries the counting command and the revision it was measured against.
All commands were run from the lane root unless the block says otherwise.

**Measured revision:** report base HEAD `c85a816`, with the r103 artifacts on disk (this is the
surface the gate below was run against). At round close the same commands must be re-run on
`8c9d9ad70b86c4408ac9d43e742076840b7c40db`; a number that does not reproduce there is a FAIL for its claim.

### C1 — coverage: the freshness note is landed and the three classes resolve

| measurement | command | before | after |
|---|---|---|---|
| note present | `grep -n 'Correction note — 2026-10-18 (r103)' corpus/knowledge/unreal-mcp/adaptation-kimi.md` | absent (r102 proposed text only, `kimi-surfaces.md` §4) | **present**, `:367` |
| three classes | `grep -n '^### C[123]' …` | n/a | **C1 `:380` · C2 `:416` · C3 `:442`** |
| delta shape | `git diff --stat -- …/adaptation-kimi.md` | n/a | **`143 insertions(+)`, 0 deletions** — no silent rewrite |
| file size | `wc -l`; `sha256sum` | 363 lines (`e0f8ca9b…` at r102) | **506 lines**, `084a34cd…` |
| class 1 — hooks line | `grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml` | r101 cited `:2932`, r102 measured `:3219` | **`:3290`** (file 3322 lines) — third distinct number in three rounds |
| class 2 — doc URLs | `curl -s -o /dev/null -w '%{http_code}' …/kimi-code/{customization/{plugins,hooks}}` vs `/en/`-prefixed | bare form cited as a source | bare **404 ×4**, `/en/` **200 ×4** (this seat, independent) |
| class 3 — `/tmp` pointer | note C3 § | §3.2/§3.3/§4.2 ran against `/tmp/ue-skills-ref` | re-ran against the **vendored `upstream/`** copy; same verdict, digests match the manifest prefixes |
| binary anchor intact | `note/binary.md` | BuildID `5e67bdf9…` | **unchanged** — §5's invalidation rule is *not* triggered |
| non-author verdict | `note/verify.md` §0 | n/a | **PASS** — 15/15 rows have a resolving pointer; 4/4 URLs 200; 0 removed lines |

**Known scope boundaries this claim does not close** (stated, not hidden):

- **One 404 remains cited in a tracked file and was deliberately left uncorrected.**
  `adaptation-kimi.md:6` cites `…/unreal-engine-skills-for-claude-code` (missing the `-plugin`
  suffix). It is outside the three C1 citation classes and `note/verify.md` §6 reports it rather
  than repairing it. Routed, not closed.
- **The note's own citation broke the gate mid-write, then healed.** While `adaptation-kimi.md`
  cited `reports/round-103/note/author.md` before that file existed, the gate failed CHECK 4 with
  `MISSING-PATH-REL reports/round-103/note/author.md` (`POINTERS=89 UNRESOLVED=1`, exit 1). This seat
  observed that RED independently. Once `author.md` landed the gate returned to green. A real
  ordering transient, not a defect in the landed artifact (`note/verify.md` §5).
- **The r102 §4 proposed text was already stale when it was proposed.** It pins the `[[hooks]]`
  precedent at `:3219`; by r103 the file had moved again to `:3290`. The landed note records the
  three-step drift and — correctly — refuses to cite a bare line number, instructing
  `grep -n '\[\[hooks\]\]'` instead. Two independent derivations agree on 3290 (this seat,
  `note/configline.md`).

### C2 — depth: gate hardening A1–A4, each before(fail) → after(pass)

**The gate is green on the landed bytes** — this seat ran it, not quoted it:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0                                      STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297 CLONE_DIRTY=0 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0                                      STEP=PASS
CARDS=13 EXPECTED=13 BAD=0  CENSUS static-only=12 unproven-runtime=1 verified-here=0
NAME_SET=OK NAME_BAD=0                                                        STEP=PASS
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0       STEP=PASS
GATE RESULT: PASS (checks failed: 0)
rc=0
```

Every attack below was planted on a **throwaway copy** of the subtree under `/tmp`; the pinned tree
was never modified.

**A1 — validate ALL endpoints of a `:a-b` / `:a,b` pointer range**

| | command | observed |
|---|---|---|
| before | `grep -ohE "…:[0-9]+"` (no `([,-][0-9]+)*` group) | `upstream/README.md:1-9999` read as `:1` — in range against `max=112`; a **latent false PASS** (`fold-spec.md` §A1) |
| after (attack) | planted `upstream/README.md:1-9999` in `executability/materials.md`, ran the gate | `LINE-OOR … :: upstream/README.md:1-9999 (max 112)`, `UNRESOLVED=27`, `STEP=FAIL`, **exit 1** |
| after (control) | unmodified copy | `POINTERS=… UNRESOLVED=0`, `STEP=PASS` |
| mechanism | `run_gate.sh:295-308` | `for ln in $(printf '%s' "$rest" \| tr ',-' '  '); do … P_TOTAL=$((P_TOTAL+1))` — one increment and one bounds check per endpoint |

**A2 — prose-hijack-proof label rule**

| | command | observed |
|---|---|---|
| before | `rec=$(grep -nE "$ALLOWED" "$f" \| head -1)` | a prose sentence naming a token above the declaration hijacked the rule (`fold-spec.md` §A2, first found `reruns/labels.md` §3a) |
| after (attack) | inserted `This card is emphatically not \`verified-here\`; nothing was observed.` above the declaration in `editor-general.md` | `OK   static-only      editor-general.md              line 5`; `CARDS=13 EXPECTED=13 BAD=0` — the anchored rule ignores the prose line and reads the line-5 declaration |
| after (control) | unmodified copy | identical CHECK 3 verdict |
| mechanism | `run_gate.sh:225-231` + `LABEL_RE` | declaration must **start** with one of five anchored label shapes; a prose sentence is not-a-declaration |

**A3 — pinned card-name set comparison**

| | command | observed |
|---|---|---|
| before | `find … \| sort` then `grep -c .` — **no name comparison** | renaming `sequencer.md` → `sequence-typo.md` left `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS` — a card silently dropped-and-replaced (`fold-spec.md` §A3; `gate/a3-attack.md` §0 shows the full false PASS once the referring docs are made consistent) |
| after (attack) | renamed `executability/sequencer.md` → `sequence-typo.md` on a copy | `FAIL card-name-missing sequencer.md`; `FAIL card-name-extra sequence-typo.md`; `NAME_SET=BAD NAME_BAD=2`; **exit 1** |
| after (control) | unmodified copy | `NAME_SET=OK NAME_BAD=0` |
| mechanism | `run_gate.sh:246-256` | both directions checked against `$PINNED_CARD_NAMES`; `NAME_BAD` gates CHECK 3 |

**A4 — distinct BLOCKED signal + declared exit 2 when the fresh clone cannot complete**

| | command | observed |
|---|---|---|
| before | clone-failure branch printed `… — BLOCKED, not PASS`, set `C2_PASS=0` | `STEP=FAIL`, **exit 1** — byte-identical in shape to a real `BLOB_DIFFS>0` divergence; a reader of `GATE RESULT: FAIL` cannot tell "no network" from "the bytes diverge" (`fold-spec.md` §A4; `gate/a4-attack.md` §Verdict) |
| after (attack, no network) | `git` shim that fails only `clone` (`Could not resolve host`), on `PATH` | `CHECK 2 BLOCKED (network)` / `BLOCKED fresh clone could not complete — upstream unreachable, nothing compared` / `BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent`; `STEP=BLOCKED`; **`GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)`; rc=2** |
| after (attack, bad ref) | `GATE_REF=/tmp` (not a git clone) | `FAIL GATE_REF is not a git clone: /tmp`; `STEP=FAIL`; **rc=1** — a bad ref is a genuine FAIL, not BLOCKED |
| after (control, good ref) | `GATE_REF=/tmp/ue-skills-ref` (a clone at the pin) | `GATE_REF=/tmp/ue-skills-ref (offline reference; no clone attempted)`; `CLONE_HEAD=a6aa73ad…`; `GATE RESULT: PASS`; **rc=0** — the air-gapped path works |
| after (live, real drop) | gate re-run during an observed network drop | printed the BLOCKED triple and `STEP=BLOCKED` — the channel is real, not just shim-reachable |
| mechanism | `run_gate.sh:171-183`, `:285-294` | `C2_BLOCKED` is a **third state**, deliberately not counted in `FAILS`; exit codes `0` PASS · `1` FAIL · `2` BLOCKED |

**Adjacent defect fixed in the same file (found independently, then landed).** This seat observed a
hardcoded `/tmp/advgate/.h1` scratch path at `run_gate.sh:65`. On any host without that directory the
redirect fails, `sha256sum` never runs, and the gate prints `FAIL per-seat manifest sweep` + exit 1
**on a clean tree** — a spurious fail-closed. I confirmed the mechanism in isolation
(`sha256sum … >/tmp/no-such-dir-xyz/.h1` inside `if !` → the IF branch is taken). The landed fix
replaces it with `mktemp` (`run_gate.sh:66-72`), with the author's own note naming the failure mode.

**Known scope boundaries this claim does not close** (stated, not hidden):

- **The mixed case loses the third state.** `run_gate.sh:288-294`: `exit 2` fires only when
  `C2_BLOCKED=1 && FAILS=0`. When CHECK 2 is BLOCKED **and any other check also fails**, control
  falls through to `GATE RESULT: FAIL` / exit 1 — the distinction A4 exists to create is silently
  lost, and a reader cannot tell "check 2 could not run" from "the bytes diverge". Code-read by this
  seat; independently found by SEAT-61 (`gate/exit-codes.md` §3.3). **Open.**
- **`gate/README.md` declares the old exit semantics in two places.** `:156-157` still says *"`0` iff
  all four checks print `STEP=PASS`; `1` otherwise. There is no partial-pass state"*, and `:73-74`
  still says a failed clone *"exits 1"*. Three documents, two of them contradicting the code
  (`gate/exit-codes.md` §0, this seat re-read both lines). **Open.**
- **The README's pinned pointer counts are internally inconsistent at this frame.** `:129` says
  `POINTERS=91` (pass A = 40, pass B = 51); `:142` still pins `POINTERS=90` in the summary block; the
  installed gate prints `98`. The pin-correction note at `:204` claims `91`. The count moved because
  sibling seats kept editing prose (this seat measured `88 → 91 → 92 → 98` across its window), so the
  **number is not a stable contract** — but the README presents three different values at once.
  `gate/docs-sync.md` (SEAT-20) flags the same class. **Open.** The binding invariant,
  `UNRESOLVED=0`, held at every frame this seat measured.
- **The count is self-referential.** Sweep B (backtick repo-relative paths) has no self-exclusion, so
  editing `gate/README.md`'s own prose changes `POINTERS`. Recorded in the README at `:119-124` as a
  doc-level observation rather than fixed. `POINTER_STRINGS=41` is a **new** metric added this round
  to separate pointer strings from expanded endpoints.
- **No wrapper consumes the gate, and the lane's classifier has no could-not-evaluate vocabulary.**
  `git grep run_gate` outside the gate finds zero callers; and exit 2 already means *"this arm
  PASSED"* in `corpus/fixtures/README.md:46`, so a future wrapper would misread a gate BLOCKED as a
  pass when `expected_exit == 2` (`gate/exit-codes.md` §4.3). **Open — the wrapper contract must be
  pinned before any wrapper is written.**

### C3 — calibration: the dead-root class is closed and the battery row is classified

**B2 — the three routed READMEs, before(fail) → after(pass)**

| | command (from the repo root) | observed |
|---|---|---|
| before (glb-r12) | `python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py` | **exit 2** (`No such file or directory`) |
| before (unity-r19) | `uv run --no-project --with pyyaml python .shokunin/…/unity-r19/verify_scene.py` | **exit 2** |
| before (three) | `npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three` | **exit 1** |
| after (glb-r12) | `python3 corpus/artifacts/glb-r12/run_import.py` | **exit 0** |
| after (three) | `node corpus/fixtures/three/run_cases.mjs` | **exit 0** |
| hit counts | `grep -c "shokunin/game-dev-3d" <each>` | **0 / 0 / 0** (was 3 / 2 / 17) |
| whole-tree delta | `git grep -l '\.shokunin/game-dev-3d' \| wc -l` (worktree vs `HEAD`) | **164 vs 167** — exactly the 3 repaired files |
| repair scope | `git diff --stat` on each | glb-r12 3+/3−, unity-r19 2+/2−, three 17+/17− — **prefix strip only, zero non-command lines** |
| non-author verdict | `b2/verify-unity.md`, `b2/verify-three.md` | **PASS ×2** — each re-runs the commands on a pristine `git archive HEAD` export and confirms the checker still fails when the seeds are perturbed |
| keep-list ruling | `b2/adversary.md` (SEAT-30) | the repair-eligible class is **3 files / 22 lines**; **164 of 167 files must be kept** — repairing the class-B fixture seeds would falsify an already-landed cited SHA-256 |
| post-repair sweep | `b2/postgrep.md` (SEAT-31) | dead roots in runnable contexts = **0**; every survivor is a keep class (historical record, correction-note quote, append-only ledger, digest-pinned seed, tool receipt) |

**`phys3d_joints_free_ops` — investigation only, and the class is NOT the one r102 guessed**

| measurement | command | observed |
|---|---|---|
| reference receipt | `corpus/live/runs/20261018T181301123479Z/verdicts.json` | `cases=350 pass=336 fail=14`; the row is index 221 |
| failure fields | same receipt, row `phys3d_joints_free_ops` | `error="TIMEOUT after 20 seconds"`, `actual_exit=None`, `expected_exit=0`, `elapsed_seconds=20.008`, `reasons=[TIMEOUT…, no exit code…, exact stdout marker missing]` |
| contrast class | the 13 `r94_cannon_*` rows in the same receipt | `actual_exit=0`, `reasons=['exact stdout marker missing']` — **marker drift**, not a timeout. The physics row is a **categorically different class** |
| independent reproduction | `python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /tmp/r103-phys3d` | `FAIL … TIMEOUT after 20 seconds`, elapsed **20.15 s** |
| over-budget, not hung | same command with a **90 s** budget | **exit 0 in 24.0 s** — the arm completes; it is *over* the cap, not deadlocked |
| CPU vs wall | SEAT-32 `physics/investigate.md` §6 | **3.5 s CPU inside 22.5 s wall** — ~84 % blocked on process spawn; 21 serial child Godot processes (`OS.execute(..., blocking=true)`) inside one 20 s bound |
| decisive flip | raise only `CASE_TIMEOUT_SECONDS` 20 → 120 on a `/tmp` copy | row **PASS**, `reasons: []`, pinned marker verbatim, `seeds_unchanged: true` (`physics/investigate.md` §4) |
| historical frequency | scan of every stored receipt containing the row | **26/26 FAIL**, all `('FAIL', None, 'TIMEOUT after 20 seconds')`; never once passed on this host at the shipped bound |
| fixture integrity | `git diff HEAD -- corpus/fixtures/phys3d_joints.gd` | **empty** — the seed is byte-untouched |
| classification | `physics/investigate.md` §7 | engine-behaviour **no** · host-capability **no** · **harness-timeout yes** — sub-class *load-sensitive margin* (r93 saw it at 16.9/17.2 s) |
| repair | — | **none applied**; R1–R4 are design sketches only. `corpus/fixtures/**` is not a lane seat's to edit |

**A secondary symptom this seat found (recorded, not promoted).** Running the arm directly on the
*reused* r102 scratch, the `freeb_ops@gp` cell now reports `mode_ok=0,m6=e3b0c44298fc1c14` —
`e3b0c442…` is sha256 of the **empty string**, so that cell's child log was empty and the BIMODAL rule
closed the row. Isolated on a fresh copy the same child does crash as designed (`signal 11`,
`exit=134`, ~1.7 s). SEAT-32 §5.1 records the same cells diverging on a reused scratch and classifies
it as **unconfirmed** scratch-reuse noise; the pinned marker still matched byte-for-byte (3921/3921)
on its clean run. **Not part of the r103 classification.**

**One operational hazard observed (not caused by this seat).** During this window an invocation of
`godot --headless --path . --script res://phys3d_joints.gd -- --arm=free_ops` with `--path .`
pointing at the **repo root** briefly wrote 21 untracked `corpus/fixtures/r90bt_free_ops_*/`
directories (seen in `git status` at 18:34:34Z; gone by 18:37Z). `corpus/fixtures/**` is byte-pinned;
a `--path .` invocation against the seed tree is exactly the shape that would mutate pinned fixtures
if its scratch write ever failed. Recorded by SEAT-32 §9 as well.

### Round-level deltas (unchanged surfaces, measured so they are known not to have moved)

| surface | command | value |
|---|---|---|
| battery rows | AST parse of `CASES` in `corpus/fixtures/run_battery.py` | **350**; `run_battery.py` sha256 `f456bd00…f69f` — unchanged |
| fixture byte-stability | `git diff --stat HEAD -- corpus/fixtures/` | only `three/README.md` (17+/17−) — **zero fixture seed bytes changed** |
| pinned subtree | `git diff --name-only HEAD -- …/upstream …/.manifest.d` | **empty** — still byte-pinned |
| subtree file count | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | **42** (unchanged from r102 close) |
| `corpus/lessons/` | `ls corpus/lessons \| wc -l` | **93** (unchanged) |
| protected paths | `git hash-object` vs `git rev-parse HEAD:<path>` | `LOG.md` / `SCORECARD.md` / `SHONEN.md` / `PROVINCE.md` → **MATCH ×4** |
| `LOG.md` / `SCORECARD.md` last round | `grep -c 'ROUND 103' LOG.md`, `grep -c 'Round 103' SCORECARD.md` | **0 / 0** — r103 not yet recorded (expected pre-adjudication) |
| `SHONEN.md` checked boxes | `grep -c '^- \[x\]' SHONEN.md` | **1** (box 2 only) — unchanged |
| round-103 report files | `find reports/round-103 -type f \| wc -l` | **36** at the final frame `18:37:38Z` **[moving]** — was 1 at round start, 24 at `18:34`, 31 at `18:36` |
| modified tracked files | `git status --porcelain \| grep -c '^ M'` | **6** **[moving]** |
| untracked paths at write | `git status --porcelain -uall \| wc -l` | **42** **[moving]** |
| upstream pin | `git ls-remote <url> main` | `a6aa73ad…` — **still the tip of `main`** (`freshness-pin.md`) |

---

## SHONEN 4-box lines

`SHONEN.md` currently reads box 2 `[x]` and boxes 1, 3, 4 `[ ]` (`grep -c '^- \[x\]' SHONEN.md` → 1).
Per the skill's report shape, one line per box. Marks below are this round's **evidence pointers**,
not self-attested checks: a `[x]` requires a named non-author verifier, a `[~]` is the lane's own
assessment with a resolvable pointer, and an untouched box stays `[ ]`.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]`
  Round r103 does not land a decision table; it **re-reviews** the r102 draft against r103 reality
  (`reports/round-103/skill-table-review.md`, SEAT-59, subject sha256 unchanged since r102). The
  gate's own control table (C1–C7) and its new exit-code table (`0`/`1`/`2`) are working checklists
  with commands, but the exit-code table is exactly the part the round shows to be **declared
  inconsistently** (`gate/exit-codes.md` §0). Box stays open: `SKILL.md` does not exist in this lane
  (shonen seed form, `README.md:11`) and no non-author has accepted a table as the skill's own.
  Verifier: none named this round.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2 —
  `game-dev-3d-r2-review-retry` independently reproduced both battery commands, the mutation
  rejection and the source contact-plane derivation (`corpus/lessons/r2-independent-review.md`).
  **r103 does not add an end-to-end domain task**: no Unreal Editor exists on this host, so the
  round's own work is static/format evidence by construction. The battery row investigated this round
  is a real headless Godot execution, but it is an *investigation of a harness timeout*, not a
  new domain task, and this seat does not claim it as one.
- **Box 3 — instructions executable without oral context.** `[~]` Strengthened again this round. The
  gate now has a **declared three-state exit contract** (`0` PASS / `1` FAIL / `2` BLOCKED) and an
  **air-gapped path** (`GATE_REF=<clone-at-pin>`), both of which this seat executed without author
  input: `GATE_REF=/tmp/ue-skills-ref` → `PASS` rc=0; a clone-failing `git` shim → `GATE RESULT:
  BLOCKED`, rc=2; `GATE_REF=/tmp` → `FAIL`, rc=1. The three repaired READMEs now carry commands that
  **exit 0 from a clean `git archive HEAD` export** (`b2/verify-{unity,three}.md`). Residual blockers,
  all named and **not** closed: the README contradicts the code's exit semantics in two places; the
  mixed BLOCKED+fail case collapses to exit 1; and no wrapper consumes the gate. Verifier: SEAT-10
  (`gate/clean.md`), SEAT-53 (`gate/final-run.md`), SEAT-61 (`gate/exit-codes.md`) — three named
  non-authors, two of which re-ran it. This box is a candidate for `[x]` at adjudication; the L1
  should rule on whether the three residual blockers bar it.
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` Every r103 artifact lives
  under the lane's own write scope: `corpus/knowledge/unreal-mcp/gate/**`,
  `corpus/knowledge/unreal-mcp/adaptation-kimi.md`, three routed READMEs, and `reports/round-103/**`.
  `reports/round-103/seats-ledger.md` (SEAT-55) independently reports **0 violations**: `LOG.md`,
  `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `corpus/fixtures/**` and `reports/round-101/**` +
  `reports/round-102/**` are all content-identical to HEAD, with an explicit
  *no-additions-smuggled* sweep (`git ls-files --others --exclude-standard` over the pinned trees →
  empty). `reports/round-103/ledger-check.md` (SEAT-39) independently confirms the same.
  `reports/round-103/subtree-integrity.md` (SEAT-54) confirms the pinned region is byte-stable. The
  work is **static inspection in service of 3D craft evidence**, which `PROVINCE.md` explicitly
  permits for engines that cannot execute headless. No 2D, harness-audit, lore or live-target surface
  was touched. Verifier: SEAT-55 + SEAT-39 + SEAT-54 (all named non-authors) — but none was asked to
  rule on `PROVINCE.md` accuracy specifically, so this seat keeps it `[~]`.

---

## Reproduce at close

Run from the lane root, on `8c9d9ad70b86c4408ac9d43e742076840b7c40db`, after the untracked artifacts are committed:

```sh
# C1 — the freshness note (landed, +143/−0)
grep -n 'Correction note — 2026-10-18 (r103)' corpus/knowledge/unreal-mcp/adaptation-kimi.md   # :367
grep -n '^### C[123]' corpus/knowledge/unreal-mcp/adaptation-kimi.md                            # :380 :416 :442
git diff --stat HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md                          # 143 insertions(+), 0 deletions
grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml                                                # 3290 (a moving target)
curl -s -o /dev/null -w '%{http_code}\n' https://moonshotai.github.io/kimi-code/customization/plugins.html     # 404
curl -s -o /dev/null -w '%{http_code}\n' https://moonshotai.github.io/kimi-code/en/customization/plugins.html  # 200

# C2 — the gate, one command, four checks, fail-closed
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# expected 2026-10-18T18:37Z: GATE RESULT: PASS (checks failed: 0), rc=0
#   MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0 / STEP=PASS
#   CLONE_HEAD=a6aa73ad… CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0 / STEP=PASS
#   CARDS=13 EXPECTED=13 BAD=0; NAME_SET=OK NAME_BAD=0; CENSUS 12/1/0 / STEP=PASS
#   POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0 / STEP=PASS   [moving]

# C2 — A4's three exit states, each reproduced without the network
GATE_REF=/tmp/ue-skills-ref bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"   # PASS, rc=0
GATE_REF=/tmp bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"                 # FAIL, rc=1
# a `git` shim that fails only `clone` → GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run), rc=2

# C2 — A1 / A3 attacks, on a throwaway copy (never the pinned tree)
cp -r corpus/knowledge/unreal-mcp/. /tmp/r103a1/ && \
  echo 'planted upstream/README.md:1-9999' >> /tmp/r103a1/executability/materials.md && \
  bash /tmp/r103a1/gate/run_gate.sh | grep -E 'LINE-OOR|UNRESOLVED|GATE RESULT'   # LINE-OOR … UNRESOLVED=27, FAIL rc=1
cp -r corpus/knowledge/unreal-mcp/. /tmp/r103a3/ && \
  mv /tmp/r103a3/executability/sequencer.md /tmp/r103a3/executability/sequence-typo.md && \
  bash /tmp/r103a3/gate/run_gate.sh | grep -E 'card-name|NAME_SET|GATE RESULT'    # NAME_SET=BAD NAME_BAD=2, FAIL rc=1

# C3 — the dead-root class is closed
for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do
  echo -n "$f : "; grep -c 'shokunin/game-dev-3d' "$f"; done                     # 0 0 0
git grep -l '\.shokunin/game-dev-3d' | wc -l                                     # 164 (was 167 at HEAD)

# C3 — the battery row, investigation only
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /tmp/r103-phys3d
# FAIL … TIMEOUT after 20 seconds  (over budget, not hung: exit 0 in 24.0 s at a 90 s budget)

# round-level invariants
sha256sum corpus/fixtures/run_battery.py        # f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d  # empty
find reports/round-103 -type f | wc -l          # 1 → 24 → 31 → 36 during drafting; [moving], still rising
```

The gate is also reproduced inline in `reports/round-103/gate/{clean.raw.txt,clean.now.txt,final-run.md}`,
so a verifier never depends on a leftover `/tmp` file.

---

## Open items for the L1 / adjudicator

1. **`8c9d9ad70b86c4408ac9d43e742076840b7c40db`** — this report is written pre-landing; the hash slot and every round-close
   number above must be filled from the committed tree. Counts marked **[moving]**
   (`reports/round-103/` file count, the gate's sha256 and line count, the pointer count, the
   modified-file set) moved repeatedly during drafting and are the likeliest to need re-measurement.
   **`LOG.md` and `SCORECARD.md` carry zero r103 entries** — the L1's to land.
2. **The gate README contradicts the gate code on exit semantics — two places.** `:156-157` says
   *"`1` otherwise. There is no partial-pass state"* and `:73-74` says a failed clone *"exits 1"*,
   while the code implements `0`/`1`/**`2`**. Three documents, two contradicting the code
   (`gate/exit-codes.md` §0; re-read by this seat). The A4 *implementation* is verified correct; the
   *declaration* is not. **Fix the declaration before any wrapper is written.**
3. **The mixed case silently loses the third state.** `C2_BLOCKED=1 && FAILS≥1` → `GATE RESULT: FAIL`,
   exit 1. A reader cannot distinguish "check 2 could not run" from "the bytes diverge" — exactly the
   ambiguity A4 exists to remove (`gate/exit-codes.md` §3.3; code-read by this seat). **Open.**
4. **The README presents three different pointer counts at once** (`:129` → 91, `:142` → 90,
   `:204` → 91, installed gate → 98). The count is genuinely scanner- and tree-relative and moved
   under concurrent prose edits; the honest fix is one pinned value plus the rule, not three. The
   binding invariant `UNRESOLVED=0` held at every frame this seat measured. **Open** (`docs-sync.md`).
5. **A1–A4 are all landed and all four attacks are now detected, but the 12-attack suite has not been
   re-run against the final bytes.** This seat verified A1/A2/A3/A4 individually on throwaway copies;
   the full suite (`/tmp/advgate/verify_installed.sh`, if `/tmp` survived) must be re-run against
   `run_gate.sh` sha256 `0c1ca3e1…` **at close**, because the script changed six times during the
   round. **Routed to close.**
6. **The B2 systemic ruling (R4) is still unruled.** The three routed READMEs are repaired, but
   `git grep -l '\.shokunin/game-dev-3d'` still returns **164 files**, and `PROVINCE.md:46` still
   carries the prefix in its write-scope declaration. `b2/adversary.md` (SEAT-30) rules the
   repair-eligible class to be **3 files / 22 lines** and delivers a keep-list of 164 — the L1 should
   accept or overrule that ruling and record it, so a one-file fix does not convert a routed defect
   into a standing conformance defect.
7. **`phys3d_joints_free_ops` is classified harness-timeout and is NOT repaired** — correctly, since
   `corpus/fixtures/**` is byte-pinned and the fix changes the semantics of all 350 rows.
   `physics/investigate.md` §8 proposes R1 (raise `CASE_TIMEOUT_SECONDS` 20 → 60, a global constant —
   operator's call), R2 (per-case bound proportional to child count — the correct shape), R3 (stop
   serialising the 21 children — the durable fix), and R4 (re-baseline the marker — explicitly
   **not** recommended). **Operator queue, not a lane seat.**
8. **The battery's node-marker drift is unchanged from r102.** The 13 `r94_cannon_*` rows fail on
   `exact stdout marker missing` because the markers pin `node=v24.21.0` while the host runs
   v26.12.0. The receipt is gitignored (`corpus/.gitignore:1`), so the row list is the durable
   record. **Operator queue.**
9. **One 404 remains cited in a tracked file, deliberately unrepaired.** `adaptation-kimi.md:6` cites
   the upstream repo URL missing its `-plugin` suffix. Outside the three C1 classes; reported by
   `note/verify.md` §6, not fixed. **Open.**
10. **`gate/README.md`'s own control section still does not survive its own counts** (fold-spec §A9,
    carried forward): `:161` says *"These mutation controls (C1–C6, plus C7 where listed)"* while the
    matrix has 7 rows, and C7's pinned `SKIPPED_CONTROL_SENTINELS` is not re-derivable because it
    gives no `printf` command. **Open.**
11. **A `--path .` invocation against the seed tree is a live hazard.** This seat observed 21
    untracked `corpus/fixtures/r90bt_free_ops_*/` directories appear under the byte-pinned
    `corpus/fixtures/` tree at `18:34:34Z` and vanish by `18:37Z`, caused by a sibling running the
    physics fixture with `--path .` pointing at the repo root. No fixture byte was harmed, but the
    shape is one failed scratch write away from mutating pinned fixtures. **Worth a guard or a
    convention note.**
12. **No live-editor evidence exists or can exist here.** Engine install is blocked pending operator
    Epic-account linking; re-checked this round, **nothing changed** (`install-recheck.md`). Every
    runtime claim in this round is `unproven-on-this-host`; nothing in the round asserts otherwise.

---

## L1 adjudication (close-out)

*To be filled at round close by the L1, after the work commit lands as `8c9d9ad70b86c4408ac9d43e742076840b7c40db` and this
report is the last artifact to land.*

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** coverage **improved** · depth **improved** · calibration **improved**. The round
**admits** (work commit `8c9d9ad70b86c4408ac9d43e742076840b7c40db`; this report lands last).

**Ruling — the A4 falsification was a stale-intermediate race, not a landed defect.**
SEAT-14's attack (target md5 `7a206d…`, 249 lines, 15:15:52) legitimately falsified the gate
as it stood at that moment and its report is retained as evidence. SEAT-09's final
implementation (347 lines) was landed afterwards. At close the L1 re-ran the exact attack
against the installed script: `CHECK 2 BLOCKED (network)` + `STEP=BLOCKED` + `GATE RESULT:
BLOCKED (checks failed: 0; CHECK 2 could not run)` + **exit 2** under a live proxy kill, and
exit 0 on a clean re-run immediately after. Process defect recorded (LOG ROUND 103 LAWS):
falsification verdicts must name the target hash; future attack seats re-verify against the
final tree before close.

**Ruling — the physics row.** SEAT-32 investigated, SEAT-33's adversarial ruling is accepted:
`INTRINSIC_WALL_COST`, serial-spawn budget overrun, not engine behavior, not host capability,
not a hang. The arm is correct — its pinned marker reproduces byte-identically given a
sufficient bound. Repair routed to r104 with the ruled preference: concurrent children
(measured 15× wall reduction) or a per-case bound proportional to child count; raising the
global 20 s cap is the operator fallback, not the fix.

**Ruling — conformance defect (fixtures README).** The B2 repair edited
`corpus/fixtures/three/README.md`, which the r103 seat template had marked protected. The
ruling seat (SEAT-22) named that path from the scanner evidence; the edit is doc-only,
substantively correct, and every battery code byte is verified untouched (battery-consistency
PASS, `run_battery.py` `f456bd00…` stable). Ruled: **accepted as in-scope repair**; the
template ambiguity is the defect — r104+ templates must separate fixture CODE (pinned) from
fixture DOCS (repairable). The mid-round ledger-check verdict that predated the edit is
flagged stale in postgrep §4.1, not rewritten.

**Gate flakiness — root cause characterized.** Two anomalies in the close window (one
`FAIL (checks failed: 1)` with CHECK 4 green; one empty-output exit 1) plus SEAT-01's
mid-round "CHECK 2 flaky while network was up" share one cause class: `/tmp` is a shared 16 G
tmpfs (observed 77–80 % used during the round; `Disk quota exceeded` observed on `cp`), and
the gate's `mktemp` workdir + `git clone` live there — allocation or clone failure under
pressure surfaces as silent or misleading failures, indistinguishable from a real divergence
without the A4 channel (which is exactly why A4 matters). Six consecutive clean PASS runs on
the final script at close. Routed to r104: workdir resilience (`GATE_WORKDIR`, `TMPDIR`
documentation) + a flake-reproduction harness.

**Honest limits:** the boot-floor ruling rests on this host's measurements; the r93
quiet-host figures are inherited, not re-measured (SEAT-33's flagged input). The empty-jolt-
cells curiosity (investigate.md §5.1) is recorded, not explained. Ten historical
`/tmp/ue-skills-ref` mentions remain in the adaptation table by design (PARTIAL rows, marked).
No live-editor claim exists anywhere; `verified-here` remains 0 on Unreal surfaces by
construction.
