# r104 SEAT-25 MATH-AUDIT — independent recount of the numeric claims in the r104 artifacts

- **Seat:** SEAT-25 MATH-AUDIT (r104). Owned path: `reports/round-104/math-audit.md` (this file, only).
- **Lane:** `game-dev-3d-shokunin` · HEAD `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (r103 report-last; work `8c9d9ad`).
- **Working dir:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Audit window:** `2026-10-18T19:16Z` → `19:30Z` (UTC), all commands run on this host.
- **Method:** every number below was **re-derived by my own command**, never copied from the artifact
  under audit. Each row gives the claim, the artifact, my command, my observed output, and a verdict of
  **VERIFIED** or **WRONG**.
- **Scope:** r104 artifacts that existed at my runtime. I read 18 in full and my rows cite **15 distinct
  r104 artifact paths** — past the ≥10-numbers-across-≥5-files floor: `physics/{before,markers,seeds,sentinel}.md`,
  `gate/{final-run,workdir-verify,pin-check}.md`, `gate/flake_harness.sh`, `gate/scratch/pincheck-independent.sh`,
  `ledger-check.md`, `subtree-integrity.md`, `freshness-pin.md`, `kimi-404-carry.md`, `stub-cleanness.md`,
  `skill/author.md`, `r104-report.md`, `lessons-carry.md`, plus the lane-root `SKILL.md`. I wrote nothing
  outside this file and ran no `git commit`/`push`/`checkout`/`reset`.
- **No Unreal runtime claim is made anywhere in this file.** Unreal Editor is not installed on this
  host (`which UnrealEditor UnrealEditor-Cmd` → `no … in (…)`, rc 2). Nothing here is evidence about
  live-MCP or editor behaviour.
- **Live round.** The tree moved *while I audited it* — `run_gate.sh` changed identity four times
  (`577c8b54…` → `15fc46d5…` → `b6d8c61a…` → `abebee5c…` → `e5521304…`), `flake_harness.sh` twice
  (`28048131…` → `1aeec700…`), `gate/README.md` once. Every row below is stamped with the revision it
  was measured against.

---

## 0. Headline

| verdict | count |
|---|---:|
| **VERIFIED** (numbered rows §1–§12) | **97** |
| **WRONG** (§13, separate findings) | **2** |
| **STALE-FRAME** (§14, self-disclosed frames) | **4** |
| **FALSIFIED-AT-REVISION, fixed in-round** (§15) | **1** |

**Two numbers did not reproduce, and neither is load-bearing for a claim verdict.**

- **W1 — a mislabelled count in the C3 artifact itself.** `SKILL.md:43` (and the `author.md` and r103
  `skill-table-review.md` cells it descends from) says ``shellcheck -o all`` → rc 1, **31** findings.
  The rc is right; **31 is the number of offending source LINES, not findings. The finding count is 50.**
  This is exactly the defect class the table exists to prevent — a scanner-relative count quoted with
  the wrong noun — inside the decision table that teaches the rule.
- **W2 — a stale premise presented as a round-long fact.** `gate/workdir-verify.md` states as its
  central premise that `run_gate.sh` is sha `577c8b54…` **"(unchanged all round — `grep -c GATE_WORKDIR
  run_gate.sh` = 0)"**. The parenthetical is falsified: at `16:22:49` the gate became `e5521304…` with
  **13** `GATE_WORKDIR` references. The report's own §9 bounds its frame, so I carry the *numeric* claim
  as WRONG and the *frame* as self-disclosed (§14 S1).

**The two most useful findings are not numeric.** (a) I reproduced the C2 root cause live and
independently: the gate is RED on this host for environmental reasons, and `run_gate.sh` still failed
open into a spurious `FAIL` at the revision I first ran. (b) `flake_harness.sh` at revision `28048131…`
probed the wrong directory in its own preflight — reporting `SCRATCH_PREFLIGHT=UNWRITABLE` for a
**healthy** real-disk `GATE_WORKDIR`. Both are recorded in §16 with commands.

---

## 1. Lane identity and the fixture pin

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 1 | lane HEAD is `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` | every r104 artifact header | `git rev-parse HEAD` | `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` | **VERIFIED** |
| 2 | `run_battery.py` sha256 is `f456bd00…1ef69f` | `physics/markers.md` §head, `physics/seeds.md` §2, `physics/sentinel.md` §3.1, `r104-report.md` §3 | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | **VERIFIED** |
| 3 | HEAD's blob for `run_battery.py` is the same digest | `physics/seeds.md` §2 | `git show HEAD:corpus/fixtures/run_battery.py \| sha256sum` | `f456bd00…1ef69f` | **VERIFIED** |
| 4 | `run_battery.py` git blob is `dd2d9b74448afddb…` | `physics/markers.md` §head | `git hash-object corpus/fixtures/run_battery.py` | `dd2d9b74448afddb88dcf2da56008302eba8060d` | **VERIFIED** |
| 5 | `run_battery.py` equals the r102 receipt's `seed_digests` entry | `physics/markers.md` §head, `physics/before.md` §2 | load `corpus/live/runs/20261018T181301123479Z/verdicts.json` → `seed_digests['run_battery.py']` | `f456bd00…1ef69f` | **VERIFIED** |
| 6 | `phys3d_joints.gd` at HEAD is `88be87faee02e6f0…` | `physics/before.md` §2, `physics/seeds.md` §4 | `git show HEAD:corpus/fixtures/phys3d_joints.gd \| sha256sum` | `88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73` | **VERIFIED** |
| 7 | the C1 write changed it to `c7e776387f607f08…` | `physics/sentinel.md` §3.1 | `sha256sum corpus/fixtures/phys3d_joints.gd` | `c7e776387f607f08…` (disk) vs `88be87fa…` (HEAD) | **VERIFIED** |
| 8 | exactly **1** of 146 tracked fixture blobs differs from HEAD, 0 missing | `physics/sentinel.md` §3 | per-blob `git hash-object` walk over `git ls-tree -r HEAD -- corpus/fixtures` | `tracked=146 identical=145 differing=1 missing=0`; the one `DIFFER` is `phys3d_joints.gd` | **VERIFIED** |
| 9 | 0 untracked files under `corpus/fixtures/` outside `three/node_modules` | `physics/sentinel.md` §3 | `git ls-files --others --exclude-standard corpus/fixtures` | `0` | **VERIFIED** |
| 10 | `three/node_modules` holds 1264 untracked files | `physics/sentinel.md` §3 | `find corpus/fixtures/three/node_modules -type f \| wc -l` | `1264` | **VERIFIED** |
| 11 | the four root ledgers are byte-identical to HEAD | `ledger-check.md` §1, `subtree-integrity.md` §3 | `git hash-object` vs `git rev-parse HEAD:<path>` ×4 | `LOG.md c0904c98e781…`, `SCORECARD.md 3403589a4a00…`, `SHONEN.md 8d85902c1901…`, `PROVINCE.md cde5e8f518bb…` — all IDENTICAL | **VERIFIED** |
| 12 | the four ledgers' sha256[:12] are `033ec85fe536` / `5083eee2040d` / `b44667ff4f0d` / `1932f0fd7103` | `physics/sentinel.md` §6 | `sha256sum LOG.md SCORECARD.md SHONEN.md PROVINCE.md` | `033ec85fe536`, `5083eee2040d`, `b44667ff4f0d`, `1932f0fd7103` | **VERIFIED** |
| 13 | `SKILL.md` is a **new** file, absent from HEAD | `physics/sentinel.md` §6.1 | `git rev-parse HEAD:SKILL.md` | `fatal: path 'SKILL.md' exists on disk, but not in 'HEAD'` | **VERIFIED** |
| 14 | `SKILL.md` is 174 lines, sha256 `1055a52f5704…` | `physics/sentinel.md` §6.1 | `wc -l SKILL.md; sha256sum SKILL.md` | `174`; `1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c` | **VERIFIED** |

## 2. The `CASES` table

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 15 | `CASES` holds **350** rows | `physics/markers.md` §head, `physics/seeds.md` §2, `r104-report.md` §3 | `ast.parse` + `literal_eval` on the module-level `CASES` assignment | `rows: 350` | **VERIFIED** |
| 16 | the `CASES` assignment is at **line 39** | `physics/seeds.md` §2 | AST node `lineno` | `CASES line: 39` | **VERIFIED** |
| 17 | **350** unique names, 0 duplicates | `physics/seeds.md` §2 | `len(set(names))` | `unique names: 350 dups: 0` | **VERIFIED** |
| 18 | **53** distinct scripts | `physics/seeds.md` §2 | `len(set(c[1] for c in cases))` | `53` | **VERIFIED** |
| 19 | `expect_exit` distribution is `{0: 291, 2: 59}` | `physics/seeds.md` §2, `r104-report.md` §3 | `collections.Counter(c[3])` | `{0: 291, 2: 59}` | **VERIFIED** |
| 20 | first / last row are `navagent3d_retarget` / `r100_fpslat_cls` | `physics/seeds.md` §2 | index 0 / -1 | `navagent3d_retarget` / `r100_fpslat_cls` | **VERIFIED** |
| 21 | **8** rows carry `script='phys3d_joints.gd'`, named sweep…twopin | `physics/markers.md` §head, `r104-report.md` §3 | filter + list names | `8` → `sweep, rid, api, free_pair, free_ops, detach, chain3, twopin` | **VERIFIED** |
| 22 | HEAD and worktree `CASES` are field-identical, canonical sha `4401f367ab7c698f…` | `physics/seeds.md` §5 | extract from live file and from `git show HEAD:…`; `json.dumps(cases, sort_keys=True)` → sha256 | both `4401f367ab7c698f574a17453078e23c303a4eb5b48d7d052ee8e62f5ca926e9` | **VERIFIED** |
| 23 | the 8 `phys3d_joints` block occupies lines 522–536, `free_ops` at 530 | `physics/seeds.md` §2 | `grep -n '^\s*("phys3d_joints'` | `522, 524, 526, 528, 530, 532, 534, 536` | **VERIFIED** |
| 24 | `ARM_CASES` holds **8** arms; `free_ops` holds **7** sub-cases; `BACKENDS` holds **3** → **21** children | `physics/before.md` §5 | parse `const ARM_CASES` / `const BACKENDS` in `phys3d_joints.gd` | `arms: 8`; `free_ops sub-cases: 7` (`freeb_ops, freeb_twice, freeb_make, freeb_world, freeb_afterclear, freej_then_b, detachb_free`); `BACKENDS` 3 entries; `7*3 = 21` | **VERIFIED** |

## 3. The marker bank (`physics/markers.md`)

Every whole-marker byte count and sha256 in the bank's §1 table, re-derived from the `CASES` literal:

| # | row | bytes claimed | bytes measured | sha claimed | sha measured | verdict |
|---|---|---|---|---|---|---|
| 25 | `phys3d_joints_sweep` | 675 | 675 | `84e0a9abe19ffce9…` | match | **VERIFIED** |
| 26 | `phys3d_joints_rid` | 1001 | 1001 | `94a5ddaa4739e3da…` | match | **VERIFIED** |
| 27 | `phys3d_joints_api` | 2574 | 2574 | `fb36001cbe41c661…` | match | **VERIFIED** |
| 28 | `phys3d_joints_free_pair` | 1514 | 1514 | `a8f66074ea928699…` | match | **VERIFIED** |
| 29 | `phys3d_joints_free_ops` | 3921 | 3921 | `706ad9151452e18d…` | match | **VERIFIED** |
| 30 | `phys3d_joints_detach` | 2596 | 2596 | `fe2743f8a825f289…` | match | **VERIFIED** |
| 31 | `phys3d_joints_chain3` | 281 | 281 | `26912caaa4ee260f…` | match | **VERIFIED** |
| 32 | `phys3d_joints_twopin` | 6623 | 6623 | `f3a829393a088ab9…` | match | **VERIFIED** |
| 33 | combined payload is **19185** bytes; concat sha256 `acabe35fbbc8676e…` | 19185 / `acabe35f…` | `19185`; `acabe35fbbc8676e0efb1ec2f35f4bd13501457d6f19a0572f8b1b0afec358ab` | | **VERIFIED** |
| 34 | per-row cell counts: 3 / 3 / 3 / 9 / **21** / 3 / 3 / 6 | — | regex `(\S+?)@(gp\|jolt\|dummy)\{…\}` per row | `3,3,3,9,21,3,3,6` — all match | **VERIFIED** |
| 35 | the §3.2 embedded `m<N>` pin table holds **12** rows (the 12 `gp`/`jolt` cells) | 12 rows listed | extract `m\d+=[0-9a-f]+` from the `free_ops` marker | `m-pins: 12` — the same 12 values, in order | **VERIFIED** |

## 4. The r102 reference receipt

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 36 | the receipt records `cases=350`, `PASS=336`, `FAIL=14` | `r104-report.md` §5, r103 ruling | `json.load` → `totals` | `{'cases': 350, 'pass': 336, 'fail': 14, 'ordinary': 291, 'negative_controls': 59}` | **VERIFIED** |
| 37 | the 14 failures are **13** `r94_cannon_*` + **1** `phys3d_joints_free_ops` | round context; `r103-report.md` | `collections.Counter` over non-PASS rows | `13` rows named `r94_cannon_*`, `1` named `phys3d_joints_free_ops` | **VERIFIED** |
| 38 | the 13 cannon rows fail with `exact stdout marker missing` (not a timeout) | `r103-report.md` | read each row's `reasons` | all 13: `['exact stdout marker missing']`, `error=None` | **VERIFIED** |
| 39 | the physics row fails with `TIMEOUT after 20 seconds`, `actual_exit=None`, `expected_exit=0` | `r104-report.md` §5 | read that row | `error='TIMEOUT after 20 seconds'`, `actual_exit=None`, `expected_exit=0` | **VERIFIED** |
| 40 | its `elapsed_seconds` is **20.008** | `r104-report.md` §5 | same row | `20.008` | **VERIFIED** |
| 41 | it is **row index 221** | `r103-report.md` line 264 | `[k for k,x in enumerate(results) if …][0]` | `221` | **VERIFIED** |
| 42 | `case_timeout_seconds` is **20** | `physics/before.md` §4.1 | `d['case_timeout_seconds']` | `20` | **VERIFIED** |
| 43 | `seed_digests` holds **130** entries | `physics/sentinel.md` §4 | `len(d['seed_digests'])` | `130` | **VERIFIED** |
| 44 | the receipt's Godot is `4.7.2.stable.arch_linux.ed1daf0bf` | `physics/before.md` §2 | `d['godot_version']`; `/usr/bin/godot --version` | both `4.7.2.stable.arch_linux.ed1daf0bf` | **VERIFIED** |

## 5. The before-measurement (`physics/before.md`)

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 45 | the isolated before-run caps at `elapsed=20.024`, `actual_exit=None` | §4 | `json.load` on `physics/runs-clean/20261018T191758479619Z/verdicts.json` | `{'verdict':'FAIL','actual_exit':None,'error':'TIMEOUT after 20 seconds','reasons':[3 reasons],'elapsed_seconds':20.024}` | **VERIFIED** |
| 46 | stdout in that receipt is the engine banner **and nothing else**; stderr is empty | §4 | read `results[0]['stdout']` / `['stderr']` | `['Godot Engine v4.7.2…']`; `[]` | **VERIFIED** |
| 47 | the second (polluted-then-clean) run A also caps at `20.024` | §4.1 | `physics/runs/20261018T191620117114Z/verdicts.json` | `elapsed_seconds=20.024`, `error='TIMEOUT after 20 seconds'` | **VERIFIED** |
| 48 | **20 of 21** child logs exist in the clean scratch; `detachb_free_dummy` never wrote one | §5 | `ls -d …/r90bt_free_ops_*` and count `child.log` | `20` dirs, `20` `child.log` files; the missing name is `r90bt_free_ops_detachb_free_dummy` | **VERIFIED** |
| 49 | **17 of 19** inter-log gaps fall in 0.85–0.97 s | §5 | sort child-log mtimes, take deltas | `17 of 19` in range; the 2 exceptions are `1.851 s` (`freeb_twice_gp`) and `0.848 s` (`freeb_ops_jolt`) | **VERIFIED** |
| 50 | first log → last log = **17.942 s** of child time inside a 20.024 s case | §5 | `ms[-1] - ms[0]` | `17.942 s` | **VERIFIED** |
| 51 | the uncapped control stdout is **4023 bytes / 3 lines**, one PASS line, 0 FAIL lines, stderr empty | §6 | `wc -c`, `wc -l`, `cat` | `4023`, `3`, `1` PASS line, `[]` FAIL lines, `0`-byte stderr | **VERIFIED** |
| 52 | that marker is **byte-identical** to the pin, sha16 `706ad9151452e18d`, 3921 bytes | §6 | compare `pas[0] == pin` | `marker==pin: True`; `sha16 standalone: 706ad9151452e18d`; `len 3921 3921` | **VERIFIED** |
| 53 | uncapped wall was **21.024 s** against a 20 s cap | §6 | read the seat's own `RC=0 WALL=21.024` line (not re-run by me — see §17) | `21.024` recorded in `before.md` §6; consistent with `20.024` capped + the observed ~1 s overshoot | **VERIFIED (arithmetically consistent, not re-run)** |
| 54 | `21 × 0.9 s ≈ 18.9 s floor is already inside the cap's margin` | §5 | `python3 -c "21*0.9"` | `18.900000000000002` → `< 20` | **VERIFIED** |
| 55 | sibling `phys3d_joints` rows pass at 3.636 / 3.685 / 3.607 / 12.078 / 4.133 / 5.753 / 9.403 s | §4.1 | read the same r102 receipt | `sweep 3.636, rid 3.685, api 3.607, free_pair 12.078, detach 4.133, chain3 5.753, twopin 9.403` — all PASS | **VERIFIED** |

## 6. The after-measurement (`physics/sentinel.md` §8, `r104-report.md` §3)

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 56 | the single-row after receipt is `PASS`, `actual_exit=0`, `reasons=[]`, `elapsed=2.687` | `sentinel.md` §8, `r104-report.md` §3 | `json.load` on `physics/author-runs/20261018T192031033448Z/verdicts.json` | `{'verdict':'PASS','actual_exit':0,'expected_exit':0,'reasons':[],'elapsed_seconds':2.687}` | **VERIFIED** |
| 57 | `case_timeout_seconds` is **unchanged at 20** and `seeds_unchanged=True`, `tree_probe_ok=True` | `sentinel.md` §8 | same receipt | `timeout 20`, `seeds_unchanged True`, `tree_probe_ok True` | **VERIFIED** |
| 58 | the pinned marker is present **byte-exact** as a stdout line in that receipt | `sentinel.md` §8 | `pin in receipt['stdout']` | `marker exact in stdout: True` | **VERIFIED** |
| 59 | all **8** `phys3d_joints` rows pass after the patch (`8/8`, 0 fails) | `sentinel.md` §8 | `physics/author-runs-all/20261018T192041290482Z/verdicts.json` | `{'cases': 8, 'pass': 8, 'fail': 0, …}`, `seeds_unchanged True`, `timeout 20` | **VERIFIED** |

## 7. The seed-digest machinery

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 60 | the seed map has **130** entries now, **130** at r102, 0 keys-only, **1** differing (`phys3d_joints.gd`) | `physics/sentinel.md` §4 | rebuild the `rglob` map (minus `__pycache__`, minus `three`) and diff against the r102 `seed_digests` | `current entries: 130`; `differing vs r102: ['phys3d_joints.gd']`; `keys only now: []` | **VERIFIED** |
| 61 | the canonical seed digest **moved** (`a3d62eb1…` → `7a737c37…`) | `physics/sentinel.md` §4 | sha256 of my own canonical JSON | my canonical differs between the two revisions in the same way; the *movement* and the *single differing key* reproduce | **VERIFIED (movement + key set; the two literal digests are serializer-dependent — see §17)** |
| 62 | the two r104 baseline receipts both carry `seeds_unchanged=True` | `physics/sentinel.md` §4 | read both receipts | both `True` | **VERIFIED** |

## 8. Gate pins and the pointer count

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 63 | the gate's `PIN` is `a6aa73ada02a9fb1f5415bec491f9942c519b297` | every gate transcript | `grep -n '^PIN=' run_gate.sh`; read `baseline.out` | `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297` | **VERIFIED** |
| 64 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` | `final-run.md`, `baseline.out`, `workdir-verify.md` §3 | `grep` the transcripts | identical in all | **VERIFIED** |
| 65 | CHECK 2 reports `CLONE_HEAD=a6aa73ad…`, `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0` | `final-run.md` | `grep` | identical | **VERIFIED** |
| 66 | `CARDS=13 EXPECTED=13 BAD=0`, `NAME_SET=OK NAME_BAD=0`, census `12/1/0` | `final-run.md`, `workdir-verify.md` §3 | `grep` | identical; and `ls corpus/knowledge/unreal-mcp/executability/ \| wc -l` → `13` | **VERIFIED** |
| 67 | the gate pins `POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` at scanner `577c8b54…` | `baseline.out`, `seat40-run*.out`, `workdir-verify.md` §3, `subtree-integrity.md` §6 | `md5sum` the three pre-C2 captures; `grep` | all three byte-identical, md5 `076da5e237e1d59289b22f173ce4368f`; the pinned line reproduces | **VERIFIED** |
| 68 | the r104 scanner is `e5521304…` and the current pin is `POINTERS=103` | `gate/README.md` line 248, `lessons-carry.md` §6b | `sha256sum run_gate.sh`; run the gate ×3 | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`; `POINTERS=103` three times | **VERIFIED** |
| 69 | an **independent** re-implementation of CHECK 4 reproduces the count: pass A = 47 endpoints from 41 strings, pass B = 56 paths | `gate/README.md` line 248; `scratch/pincheck-independent.sh` | `bash reports/round-104/gate/scratch/pincheck-independent.sh` | `INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=56` / `INDEPENDENT POINTERS=103 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0` | **VERIFIED** |
| 70 | the scanner sha the README advertised earlier (`577c8b54…`) matches the r103 gate | `workdir-verify.md` §1, `subtree-integrity.md` §5 | `git show HEAD:…gate/run_gate.sh \| sha256sum` | `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` | **VERIFIED** |

## 9. Subtree integrity

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 71 | `upstream/` tree id `b5b9624b00fc9021…`, `.manifest.d/` tree id `87bde5b7bc951766…` | `subtree-integrity.md` §3 | `git ls-tree HEAD …` | `b5b9624b00fc90217240e823406699d0ab78b959`, `87bde5b7bc9517664cfbdae46d3cfeaded62e3e2` | **VERIFIED** |
| 72 | consolidated `upstream/` digest `16dfaa66647c40cf…`; `.manifest.d/` digest `0c36de92e9c362d6…` | `subtree-integrity.md` §4 | the same `sha256sum`-pipeline over both dirs | `16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963`, `0c36de92e9c362d6911efa053586c32e7bd3e0d93956b8017e470e357b507102` | **VERIFIED** |
| 73 | `.manifest.d/` holds 12 files; the 11 seat shards hold 14 entries covering exactly the same 12 `(digest, path)` pairs | `subtree-integrity.md` §1 | count per shard; `comm` both directions | `audit-reference=12`, `seat01..seat10=1 each`, `seat11=2` → 14; distinct paths `12`; both `comm` diffs empty | **VERIFIED** |
| 74 | `reports/round-101/102/103` are `33 / 61 / 61` files, all identical, 0 differing, 0 missing | `ledger-check.md` §2, `r104-report.md` | per-file blob walk over each subtree | `identical=33 differing=0 missing=0`, `identical=61 differing=0 missing=0`, `identical=61 differing=0 missing=0` | **VERIFIED** |
| 75 | their subtree ids are `a28869fc…`, `92d4dc84…`, `739f668f…` | `ledger-check.md` §2 | `git ls-tree HEAD reports/round-101 …` | `a28869fcf749c34fbd91edc485afde86fae37841`, `92d4dc84dd979ecff01fe050436811c43453ada8`, `739f668f55316ac36c5c04487a20a3e5f8b789f5` | **VERIFIED** |
| 76 | `adaptation-kimi.md` sha256 is `084a34cd94806caa…` | `kimi-404-carry.md` §head, `gate/README.md` pin note | `sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` | **VERIFIED** |
| 77 | `adaptation-kimi.md` is 506 lines and **unmodified** | `kimi-404-carry.md` §head, §4 | `wc -l`; `git status --porcelain` | `506`; not listed as modified | **VERIFIED** |

## 10. The 404 carry (`kimi-404-carry.md`)

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 78 | the bare slug 404s on web **and** API; the `-plugin` slug returns 200 on both | §2.1, §2.2 | `curl -sIL -w '%{http_code}'` and `curl -s api.github.com/repos/EpicGames/<slug>` | web `404` / api `404`; web `200` / api `200` | **VERIFIED** |
| 79 | `git ls-remote` against the bare slug exits 128, against `-plugin` returns the pin | §2.3, §2.4 | `git ls-remote … main` | bare: `Repository not found` / rc `128`; `-plugin`: `a6aa73ada02a9fb1f5415bec491f9942c519b297 refs/heads/main` | **VERIFIED** |
| 80 | the fix is unique: the old string occurs **1×**, the new string **0×**, delta **+7 bytes**, 506 → 506 lines | §4 | `s.count(old)`, `s.count(new)`, byte-length delta | `old count: 1`, `new count: 0`, `byte delta: 7`, `lines: 506` | **VERIFIED** |
| 81 | `PROVENANCE.md` §2's 12 blob prefixes are correct | `freshness-pin.md` §5 | `git rev-parse HEAD:corpus/knowledge/unreal-mcp/upstream/<path>` ×12 | `44c8dd3e, 4a38912a, 7ccb8b76, aa5fae26, ba4e660a, 6be4b8b7, 8c06ba24, 9cd2cc26, 49a921a9, e02d8d0e, febf5d5a, a1513865` — all 12 match the table | **VERIFIED** |

## 11. The C3 artifact (`SKILL.md`)

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 82 | the §6 stamp table's artifact digests resolve to the named files | `SKILL.md` §6 | `find … -exec sha256sum` + resolve each 64-hex stamp | `084a34cd…`→`adaptation-kimi.md`; `36938c71…`→`PROVENANCE.md`; `c79d8dd1…`→`unreal-mcp/README.md`; `d03907d3…`→`corpus/knowledge/engines.md`; `cf237b88…`→`corpus/lessons/r102-unreal-integration.md`; `fa360bde…`→`reports/round-102/skill-decision-table-draft.md`; `95d40d92…`→`reports/round-103/skill-table-review.md` — **7/7 resolve, all with the stated role** | **VERIFIED** |
| 83 | `gate/README.md`'s digest at write time was `834f468d…` | `SKILL.md` §6 | `git show HEAD:corpus/knowledge/unreal-mcp/gate/README.md \| sha256sum` | `834f468ded21fcdf069ab378c2774298158f71a93954aef9ee0df86bd90927d2` — equals HEAD, correct at write | **VERIFIED** |
| 84 | `jq -e .` → rc 0, and the `.` filter is load-bearing (without it rc 3) | `SKILL.md` row B | both forms, from the subtree | `jq rc=0`; `jq no-filter rc=3` | **VERIFIED** |
| 85 | `bash -n upstream/hooks/unreal-context.sh` → rc 0 | `SKILL.md` row B | `bash -n` | `bash -n rc=0` | **VERIFIED** |
| 86 | `shellcheck …` (default) → rc 0 | `SKILL.md` row B | `shellcheck <file>` from the subtree | `rc=0` | **VERIFIED** |
| 87 | the Kimi-side probe values: `kimi --version` = `2.2.0`; `strings` counts `additionalContext` / `CLAUDE_PLUGIN_ROOT` / `enabledPlugins` = 0 / 0 / 0 | `SKILL.md` row D | `kimi --version`; `strings -n 6 … \| grep -c` | `2.2.0`; `0`, `0`, `0` | **VERIFIED** |
| 88 | row E: the descriptor checker accepts, and its reject control rejects | `SKILL.md` row E | both invocations | `PASS local-static actual=accept … reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)`, rc 0; `PASS local-static actual=reject … reason=unsupported module Type: 'Unknown'`, rc 0 | **VERIFIED** |
| 89 | row C: `which UnrealEditor UnrealEditor-Cmd` → rc 2; `ls /opt/UnrealEngine` → not found | `SKILL.md` row C | both | `no UnrealEditor in (…)`, rc `2`; `No such file or directory` | **VERIFIED** |
| 90 | `SKILL.md` carries no stub token and no `{{…}}` slot | `stub-cleanness.md` §0 | `grep -nE '\b(TODO\|TBD\|FIXME\|XXX\|WIP\|PLACEHOLDER)\b' SKILL.md`; `grep -nE '\{\{[^}]*\}\}'` | no output for either | **VERIFIED** |

## 12. Ledger, stub and report-draft numbers

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 91 | `stub-cleanness.md`'s strict-hit count in the **lane-authored** surface is **0** at every frame, with the two named exceptions | §0, §1 | re-derive: the only authored hits are `physics/seeds.md:116` (now `STATUS: LANDED and verified.`) and `flake_harness.sh`'s `XXXXXX` mktemp template | `seeds.md` `STATUS` line now reads `LANDED and verified`; `XXXXXX` is a substring of a `mktemp` template — both are non-defects | **VERIFIED** |
| 92 | `flake_harness.sh`'s `mktemp -d "${TMPDIR:-/tmp}/flake-harness.XXXXXX"` is the `XXX` substring hit | §0 (C) | `grep -n 'XXXXXX' flake_harness.sh` | present at the `LOGDIR` default | **VERIFIED** |
| 93 | `r104-report.md`'s before/after table matches the receipts | §3 | read each cited receipt | `runs-clean…` FAIL/`pass=0 fail=1`; `author-runs…` PASS `2.687` `reasons=[]`; `author-runs-all…` `8/8` at `case_timeout_seconds=20`; marker `3921` / `706ad915…` — all match | **VERIFIED** |
| 94 | `r104-report.md`'s "17 of 19 inter-log gaps in 0.85–0.97 s, 20 of 21 child logs present" | §3 | same as rows 48–49 | matches | **VERIFIED** |
| 95 | `r104-report.md` leaves the full 350-row after-battery as a `{{C1_FULL_BATTERY}}` slot | §5 | grep the slot | still unfilled at my window; no full-battery receipt exists under `reports/round-104/physics/author-runs-full/` (only `scratch/`) | **VERIFIED** |
| 96 | the 8 `phys3d_joints` rows are all present and named | `physics/seeds.md` §5 | row 21 above | matches | **VERIFIED** |
| 97 | `ledger-check.md`'s whole-tree sweep is `WHOLE_TREE_DIFFER=0` | §3 | my own whole-tree `git ls-files` × `git hash-object` sweep | `WHOLE_TREE_DIFFER=0` — **but see §14 S4**: this held only at that seat's frame | **VERIFIED (at its frame)** |

---

## 13. WRONG findings

### W1 — `SKILL.md:43` (and its two ancestors): "`shellcheck -o all` → rc 1, **31** findings" — the count is mislabelled

**Claim.** `SKILL.md:43` row B, in the canonical-command column:

> `shellcheck -o all` → rc 1, **31** findings.

The same number appears in the cell's ancestor chain: `reports/round-104/skill/author.md:112-113` and
`reports/round-103/skill-table-review.md:372`.

**My command and output.** Run from the subtree, as the cell prescribes:

```
$ cd corpus/knowledge/unreal-mcp
$ shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo "rc=$?"
rc=1
$ shellcheck -o all -f json upstream/hooks/unreal-context.sh 2>/dev/null \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d))"
50
$ shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -coE 'SC[0-9]+ \('
50
$ shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -cE '^In .* line'
31
$ shellcheck --version | head -3
version: 0.11.0
```

**Verdict: WRONG.** The exit code (`1`) is correct. **The count is not: the finding count is 50, not
31.** The two codes involved are `SC2250` (36 occurrences) and `SC2292` (14) — 50 in total. **31 is the
number of distinct offending source LINES**: `shellcheck` prints one `In <file> line N:` header and then
one or more `SCxxxx` issue lines under it, and the author's own command (`grep -cE '^In .* line'`) counts
the headers, not the issues. A `-f json` count and an `SC`-token count agree on 50; only the
line-header grep yields 31.

**Why this matters more than its size.** This is the C3 artifact — the decision table whose whole
purpose is to stop a scanner-relative number being quoted with the wrong noun. `gate/README.md:169`
states the lane's own law: *"treat `POINTERS` as a measurement of this scanner on this tree"*. W1 is
that same defect class, inside the file that teaches it, and it is the *inherited* form: the number
was copied from `skill-table-review.md` (r103) through `author.md` (r104) into `SKILL.md` without
being re-derived against the noun it was labelled with. The repair is one word — either "31 lines
with findings (50 findings)" or "50 findings across 31 lines" — and it is above the line the table
declares for its own re-derivation.

**Not corrected by me:** `SKILL.md` is outside this seat's declared scope, and a math audit reports
rather than edits.

### W2 — `gate/workdir-verify.md` §1 / header: `run_gate.sh` is `577c8b54…` **"(unchanged all round)"** — the parenthetical is false

**Claim.** `reports/round-104/gate/workdir-verify.md`, its scope header and §1:

> Gate under test: `corpus/knowledge/unreal-mcp/gate/run_gate.sh`, sha256 `577c8b54…`
> (**unchanged all round** — `grep -c GATE_WORKDIR run_gate.sh` = **0**).

**My command and output.**

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08
$ grep -c "GATE_WORKDIR" corpus/knowledge/unreal-mcp/gate/run_gate.sh
13
$ stat -c '%y' corpus/knowledge/unreal-mcp/gate/run_gate.sh
2026-10-18 16:22:49 -0300        # the seat's report was written 16:20:48
```

**Verdict: WRONG** — as a statement about the round. Both halves of the parenthetical are false today,
and were false 121 seconds after the report was written: the gate became `e5521304…` with **13**
`GATE_WORKDIR` references. `pin-check.md` §7 independently recorded the same event ("at **16:22:49**
… the installed gate now contains **13** `GATE_WORKDIR` occurrences").

**Frame note, and why I still call it WRONG rather than merely stale.** The report's own §9 does bound
its frame (*"I verified the installed harness at sha `28048131…. If `flake_harness.sh` or `run_gate.sh`
changes after this report, §2–§5 must be re-run"*), which is why I also carry it as **S1** in §14. What
is not bounded is the phrase **"unchanged all round"** — that is a claim about the *round*, not about
the seat's window, and the round's whole point (C2) was to change that file. The numeric content (§2–§5)
is honest and frame-stamped; the one word that overreaches is `all round`.

---

## 14. STALE-FRAME rows (measured true, superseded in-round, each source discloses its frame)

| id | artifact | claim | today's value | why not WRONG |
|---|---|---|---|---|
| **S1** | `gate/workdir-verify.md` §1, §9 | scanner is `577c8b54…`, `GATE_WORKDIR` refs = 0 | `e5521304…`, 13 refs | §9 states the re-run condition; the sha is correct for the stated frame |
| **S2** | `gate/workdir-verify.md` §4 | default (`/tmp`) config: **0/12** PASS, 12/12 `FAIL (checks failed: 1)` | default now passes **3/3** (`rc=0`, `GATE RESULT: PASS`, 0 manifest FAILs) | the 12 runs were against the pre-C2 scanner; the *mechanism* (path A) is still present in principle |
| **S3** | `gate/final-run.md` §Result | `GATE RESULT: PASS`, `RC=0`, scanner `577c8b54…` | the report's own header now reads `e5521304…` and §"Quota windows" | the seat updated its own header; its run-1/2/3 captures remain the pre-C2 green evidence |
| **S4** | `ledger-check.md` §3, `subtree-integrity.md` §2 | `WHOLE_TREE_DIFFER=0` / subtree diff empty | false today: `M corpus/fixtures/phys3d_joints.gd`, `M …gate/run_gate.sh`, `M …gate/README.md` | both seats explicitly timestamp the claim ("*clean as of 19:17Z*, not clean at close") and name git-hygiene as the close-time check |

`gate/README.md` also moved mid-round (`834f468d…` → `66bce160…`); `SKILL.md`'s stamp for it is
correct at write time (row 83), so it is a normal frame, not a finding.

## 15. FALSIFIED-AT-REVISION, fixed in-round

**F1 — `flake_harness.sh` at `28048131…`: `SCRATCH_PREFLIGHT=UNWRITABLE` for a *healthy* `GATE_WORKDIR`.**

The harness's preflight probe ran a bare `mktemp`, which resolves against the **inherited** `TMPDIR`
(here `/tmp`), not against `$GATE_WORKDIR`. I observed, at revision
`28048131d8d8e9e8b651de54dc138ff96f976bae7d4343bfcc8ee683fa88b85e`:

```
$ GATE_WORKDIR=/home/vgpnk/scratch-ma104/gw \
    FLAKE_LOGDIR=/home/vgpnk/scratch-ma104/flake4 \
    bash reports/round-104/gate/flake_harness.sh 1
GATE_WORKDIR=/home/vgpnk/scratch-ma104/gw (exported as TMPDIR to each run)
SCRATCH_PREFLIGHT=UNWRITABLE (20/20 probe writes failed)
PREFLIGHT WARNING: scratch dir is unreliable: /home/vgpnk/scratch-ma104/gw
PREFLIGHT WARNING: re-run with GATE_WORKDIR=<path on real disk> for a meaningful reading.

$ printf 'x\n' > /home/vgpnk/scratch-ma104/gw/probe && cat …/probe && rm …/probe
x
GATE_WORKDIR write+readback OK      # 772G free on /home
```

Two defects in one line of output: the preflight measured `/tmp` while naming `GATE_WORKDIR`, and the
warning's own remedy ("re-run with `GATE_WORKDIR=<path on real disk>`") is what had already been done —
circular.

**Fixed in a later revision.** At `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2`
the probe is rooted at `$PROBE_ROOT`:

```
139:  _probe=$(mktemp "$PROBE_ROOT/probe.XXXXXX" 2>/dev/null) || _probe=
```

and the two configurations now report the truth:

```
GATE_WORKDIR=/tmp (inherited; GATE_WORKDIR unset) → SCRATCH_PREFLIGHT=UNWRITABLE (20/20 … in /tmp)
GATE_WORKDIR=/home/vgpnk/scratch-ma104/gw        → SCRATCH_PREFLIGHT=OK (0/20 … in /home/…/gw)
run  1/1  rc=0  verdict=PASS       POINTERS=101   1.51s
```

So the row is **not** a standing defect; it is recorded because a seat that ran the harness only in the
earlier window would have an inverted reading of which directory was broken.

---

## 16. Non-numeric findings, with commands (the round's most important results)

### 16.1 The C2 root cause, reproduced live and independently

At `19:17Z` the gate was RED on this host, and the red was environmental:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G   80% /tmp
$ echo hello > /tmp/ma-test.txt
bash: line 1: echo: write error: Disk quota exceeded
$ for i in 1 2 3; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E '^GATE RESULT'; done
GATE RESULT: FAIL (checks failed: 1)
GATE RESULT: FAIL (checks failed: 1)
GATE RESULT: FAIL (checks failed: 1)
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | sed -n '7,8p'
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
```

The `FAIL` came from `MANLOG=$(mktemp)` at `run_gate.sh:120` plus a redirect into `/tmp`. The same
command redirected to a repo-local `mktemp` file succeeded **6/6** (rc 0, 864 bytes) where the `/tmp`
form failed **6/6** (rc 1, 0 bytes) — same second, same bytes, only the destination differing:

```
$ f=$(mktemp);                  (cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >"$f" 2>&1); echo "tmp rc=$? size=$(stat -c%s $f)"
tmp rc=1 size=0
$ f=$(TMPDIR=/home/vgpnk/scratch-ma104/wk mktemp); (cd … && sha256sum --strict -c .manifest.d/*.sha256 >"$f" 2>&1); echo "local rc=$? size=$(stat -c%s $f)"
local rc=0 size=864
```

**`mktemp` succeeding is not the check** — it returns a path; the *write* is what fails. This is the
residual hole behind the r103 comment at `run_gate.sh:73` ("*mktemp keeps the check host-independent*").

After the C2 fix landed (`e5521304…`, `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`), the default path is
clean **3/3** and `TMPDIR`-rooted runs are clean **6/6** in my window. The gate now prints its chosen
root (`WORK_ROOT=… (from TMPDIR)`), which is what made my reading unambiguous.

### 16.2 The flake harness found a real flake in its own first reading

```
$ FLAKE_LOGDIR=… bash reports/round-104/gate/flake_harness.sh 3     # default /tmp root
TALLY runs=3 pass=2 fail=0 blocked=1 empty=0 unexpected=0
FLAKE verdict: expected PASS on all 3 runs, got pass=2 fail=0 blocked=1
HARNESS RESULT: FLAKY
RC=1
```

A **BLOCKED** on run 3 of 3 with the default root, PASS on runs 1–2 — the harness detected the host
weather it was written to detect. Same harness with `GATE_WORKDIR` set: `STABLE (3/3)`, and at N=10
`STABLE (10/10)`.

### 16.3 A useful negative: the harness's `UNEXPECTED` classification caught a genuinely broken gate revision

At the intermediate scanner `15fc46d5…` the gate emitted **3** `STEP=` lines while printing
`GATE RESULT: PASS` and exiting 0, and its own output carried
`run_gate.sh: line 228: —: command not found` in the CHECK 2 region. The harness's `classify()`
(`[ "$n_total" -eq 4 ]`) scored that run `UNEXPECTED` rather than `PASS`:

```
run  1/1  rc=0  verdict=UNEXPECTED POINTERS=101   2.00s  run-1.log
```

That is the harness doing exactly its job — refusing a structurally impossible rc/verdict pair. The
current scanner emits **4** `STEP=` lines and the harness returns `PASS`. Recorded as a control, not a
defect.

---

## 17. Limits — what this audit is not

- **No Unreal runtime claim.** The editor is not installed (`which …` → rc 2). Every row above is a
  filesystem, byte, JSON, HTTP or process measurement.
- **Three rows are arithmetic-consistency checks, not re-runs** and are marked as such: row 53
  (the 21.024 s uncapped wall — I did not re-run a 21-second uncapped battery inside a live round
  that was already running the same arm), and row 61 (the two canonical seed digests are
  serializer-dependent: my `json.dumps(sort_keys=True)` reproduces the *movement* and the *single
  differing key* exactly, but the literal digest strings depend on the separator choices the other
  seat used — I verified the claim's content, not its two literal strings).
- **Row 22's `4401f367…` reproduced on the second attempt.** My first canonicalization
  (`separators=(',',':')`) gave `c8c4c174…`; `json.dumps(cases, sort_keys=True)` with default
  separators gave `4401f367…`, matching `physics/sentinel.md` §5. The digest is serializer-relative
  and the seat's value is correct for a standard choice — a math-audit reminder that an
  unqualified "canonical JSON sha" is itself a scanner-relative number.
- **Point-in-time.** The gate changed identity four times inside my window and `reports/round-104/`
  grew from 5 to 239 302 files. Rows 63–70 are stamped with the scanner they were read at; rows
  67 and 68 are deliberately split because they pin *different* scanners. Re-derive before quoting.
- **`reports/round-104/**` file counts are unusable as a metric.** `stub-cleanness.md` reports 1754
  files at `16:19:47`; `r104-report.md` reports 98 884 at `19:22Z`; I measured 239 302 and 10 556 at
  two points minutes apart (the scratch trees churn). All three are honestly marked `[moving]`; none
  is a finding.
- **I wrote only this file.** No fixture, no gate, no `SKILL.md`, no ledger; no `git` mutating command.
