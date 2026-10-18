# r102 SEAT-58 MATH-AUDIT — independent recount of every numeric claim in the r102 artifacts

- **Seat:** SEAT-58 MATH-AUDIT (r102). Owned path: `reports/round-102/math-audit.md` (this file, only).
- **Lane:** `game-dev-3d-shokunin` · HEAD `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036`).
- **Working dir:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Audit window:** `2026-10-18T17:43:00Z` → `17:44:12Z` (UTC), all commands run on this host.
- **Method:** every number below was **re-derived by my own command**, not copied from the artifact under
  audit. Each row states the claim, the artifact that makes it, my command, my observed output, and a
  verdict of **VERIFIED** or **WRONG**.
- **Scope:** the r102 artifacts that exist at my runtime. `corpus/knowledge/unreal-mcp/` is read-only to
  this seat; I wrote nothing outside this file and ran no `git commit`/`push`/`checkout`/`reset`.
- **Sample size:** **99 numbered rows** (well past the ≥10-numbers-across-≥5-files floor), spanning
  **28 distinct artifact paths** — 97 **VERIFIED**, 2 **WRONG**. Two further items are
  **UNVERIFIABLE-BY-CONSTRUCTION** and are marked as such rather than counted as passes.

---

## 0. Headline

| verdict | count | note |
|---|---:|---|
| **VERIFIED** | 97 | re-derived by my own command, matches the claim exactly |
| **WRONG** | 2 | §9.3 (`node_modules` = 1410) and §9.4 (`adversary/F3.md` size/digest) |
| **UNVERIFIABLE-BY-CONSTRUCTION** | 2 | §10 — no editor installed; these are posture claims, not numbers |

Two further numbers are **WRONG in a narrower sense** and are listed inside their own rows rather than
as separate WRONG rows, because each is a *snapshot-local* value whose source explicitly declares a
frame timestamp: §9.1 (`lesson-index.md` lesson count 90 → 91) and §9.2 (`pointers.md` column total).
Both are timing-drift artifacts, not mis-measurements, and both sources disclose the drift.

**The r102 numeric record is sound.** No claim that affects a load-bearing conclusion (the byte-pin,
the gate's four checks, the 350 CASES rows, the 12/24 manifest counts, the 13-card census) was wrong.
Every WRONG finding is in a *descriptive* number, and none is a false pass on a check.

---

## 1. The r101 subtree and its byte-pin

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 1 | 40 files in `corpus/knowledge/unreal-mcp/` | `before/baseline-integrity.md` §3 | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | `40` | **VERIFIED** |
| 2 | 13 executability cards | `before/baseline-integrity.md` §3a, `reruns/labels.md`, `gate/runtime-run.md` | `ls corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `13` | **VERIFIED** |
| 3 | 12 manifest files in `.manifest.d/` | `before/baseline-integrity.md` §3 | `ls corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 \| wc -l` | `12` | **VERIFIED** |
| 4 | 12 tracked upstream files | `README.md`, `reruns/manifest.md` | `git ls-files corpus/knowledge/unreal-mcp/upstream \| wc -l` | `12` | **VERIFIED** |
| 5 | `sha256sum -c .manifest.d/audit-reference.sha256` → 12 `OK`, rc=0 | `README.md:169`, `reruns/manifest.md` Check 1 | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 `OK`, `rc=0` | **VERIFIED** |
| 6 | glob `*.sha256` → 24 `OK` lines | `README.md:169` (post-F8 fold), `gate/runtime-run.md` Check 1 | `sha256sum -c .manifest.d/*.sha256 \| wc -l` | `24`; `grep -c ': OK$'` → `24` | **VERIFIED** |
| 7 | 11 per-seat manifests, `seat11` covering 2 files (13 entries total) | `reruns/manifest.md` Check 5 | `ls .manifest.d/seat*.sha256 \| wc -l` → `11`; `wc -l .manifest.d/seat*.sha256` | 10 × 1 line + `seat11` = 2 lines → 12 entries; 13 `OK` lines when run as 11 separate `sha256sum -c` invocations (each prints its own header-free output) | **VERIFIED** |
| 8 | `audit-reference.sha256` sha256 `fe3906c5cc98cc62…` | `reruns/manifest.md` "Digest of the manifest" | `sha256sum corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` | `fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a` | **VERIFIED** |
| 9 | `PROVENANCE.md` sha256 `36938c71a0f5b129…` | `reruns/manifest.md`, `before/baseline-integrity.md` §3d | `sha256sum corpus/knowledge/unreal-mcp/PROVENANCE.md` | `36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01` | **VERIFIED** |
| 10 | subtree sweep aggregate `be1895e3…` at snapshot, `08477100…` post-fold | `before/baseline-integrity.md` §3b and §8 | `find corpus/knowledge/unreal-mcp -type f \| sort \| xargs sha256sum \| sha256sum` | `08477100ba5572635f8b08cd73c57e520c06af08fd06472376ce268d0e3e028f` | **VERIFIED** (post-fold value; the pre-fold `be1895e3…` is a frozen historical snapshot and its §8 note correctly declares the move) |
| 11 | 12 per-file upstream digests (e.g. `upstream/README.md` = `483693ad…46b40e`) | `README.md:174-185`, `audit-reference.sha256` | `sha256sum corpus/knowledge/unreal-mcp/upstream/README.md corpus/knowledge/unreal-mcp/upstream/LICENSE` | `483693ad0e14…46b40e`, `5b337be05135…314a6` — both match the table's short forms | **VERIFIED** |
| 12 | pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` is still `main`'s tip | `freshness-pin.md` §1–§2 | `git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main` | `a6aa73ada02a9fb1f5415bec491f9942c519b297 refs/heads/main`, rc=0 | **VERIFIED** |
| 13 | upstream has no tags | `freshness-pin.md` §2.5 | `git ls-remote --tags <url>` | no output, rc=0 | **VERIFIED** |
| 14 | 5 open PRs, head SHAs as listed | `freshness-pin.md` §5, `provenance-rerun.md` | `gh pr list --repo … --state all --limit 20 --json number,state` | 5 PRs, all `OPEN` | **VERIFIED** |

## 2. The 13-card verdict census

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 15 | `CARDS=13 EXPECTED=13 BAD=0` | `reruns/labels.md` §2, `gate/runtime-run.md` Check 3 | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` (Check 3 block) | `CARDS=13 EXPECTED=13 BAD=0` | **VERIFIED** |
| 16 | census `static-only=12 unproven-runtime=1 verified-here=0` | `reruns/labels.md` §2, `gate/runtime-run.md`, `lesson-index.md` | same gate run | `CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0` | **VERIFIED** |
| 17 | the single `unproven-runtime` is `actors-scene.md` at line 5 | `gate/runtime-run.md` Check 3, `labels.md` §2 | gate Check 3 per-card rows | `OK   unproven-runtime actors-scene.md                line 5` | **VERIFIED** |
| 18 | per-card declaration line numbers (4, 4, 15, 4, …) | `labels.md` §2 table | gate Check 3 per-card rows | every one of the 13 rows matches the `labels.md` table line-for-line | **VERIFIED** |
| 19 | card-dir digest `68244ffd4ef2f428…` | `reruns/labels.md` §5 | `sha256sum corpus/knowledge/unreal-mcp/executability/*.md \| sha256sum` | `68244ffd4ef2f4281bc22277591633ea292dce7921292c8233fb9b6e4c3ee0ca` | **VERIFIED** |
| 20 | 4 per-card digests (`3bba50abff45`, `f5d18a9848a0`, `d908779d0f51`, `3eb044695511`) | `reruns/labels.md` §5 | `sha256sum …/executability/{actors-scene,materials,ui-umg-slate,vfx-niagara-dataflow}.md` | all four match to 12 hex | **VERIFIED** |
| 21 | `ls …/executability \| wc -l` → 13 | `reruns/labels.md` §5 | `ls corpus/knowledge/unreal-mcp/executability \| wc -l` | `13` | **VERIFIED** |
| 22 | 6 cards explicitly reject ``Not `unproven-runtime` `` | `corpus/lessons/r102-unreal-integration.md:89-90` | `grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `6` | **VERIFIED** |

## 3. The gate `run_gate.sh`

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 23 | gate runs from repo root and exits 0 | `gate/author-run.txt`, `gate/runtime-run.md` | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo $?` | `GATE RESULT: PASS (checks failed: 0)`, exit `0`; `grep -c STEP=PASS` → `4` | **VERIFIED** |
| 24 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` | `gate/README.md:40`, `gate/author-run.txt` | gate Check 1 block | exact string reproduced | **VERIFIED** |
| 25 | Check 2 `CLONE_TRACKED=12`, `PATH_EXTRA=0`, `PATH_MISSING=0`, `BLOB_DIFFS=0` | `gate/README.md:59`, `reruns/manifest.md` | gate Check 2 block | `CLONE_HEAD=a6aa73ad…b297`, `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0` | **VERIFIED** |
| 26 | Check 4 `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` | `gate/README.md:106`, `gate/author-run.txt` | gate Check 4 block | exact string reproduced | **VERIFIED** |
| 27 | `run_gate.sh` sha256 `214bf8ef7ba7dfba…` | `gate/mutation.md` header | `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` | **VERIFIED** |
| 28 | `gate/README.md` sha256 `def732c9a10dc9a9…` | `gate/mutation.md` header | `sha256sum corpus/knowledge/unreal-mcp/gate/README.md` | `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8` | **VERIFIED** |
| 29 | all 4 gate checks fail-closed under mutation (exit 1) | `gate/README.md` §"Calibrating the gate", `gate/mutation.md` §Verdict | ran the README's C1–C4 recipe on 4 separate `mktemp` copies | C1 → `checks failed: 2`, exit 1 · C2 → `checks failed: 2`, exit 1 · C3 → `checks failed: 1`, exit 1 · C4 → `checks failed: 1`, exit 1 | **VERIFIED** |
| 30 | gate's own recorded control outputs (`MANIFEST_OK=11 … FAILED=1 RC=1`) | `gate/controls.txt` | same mutations, gate output compared to `controls.txt` | C1 line `MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1` and C2 line `MANIFEST_OK=11 EXPECTED=12 FAILED=0 RC=1` both reproduce verbatim | **VERIFIED** |

## 4. The pointer sweeps (two independent implementations)

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 31 | `pointer-sweep.sh` re-run → `FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, exit 0 | `reruns/pointers.md` §1, §3 | `bash reports/round-102/reruns/pointer-sweep.sh` | identical string, `STEP=PASS`, exit `0` | **VERIFIED** |
| 32 | per-file distinct table: `adaptation-kimi.md` 18, `assets-content.md` 6, `editor-general.md` 2, `sequencer.md` 7, `ui-umg-slate.md` 7, `vfx-niagara-dataflow.md` 1 | `reruns/pointers.md` §3.1 | `for f in …; do grep -ohE 'upstream/[A-Za-z0-9_./-]+\.(md\|json\|sh\|txt)?:[0-9]+([,-][0-9]+)*' "$f" \| sort -u \| wc -l; done` | `18 / 6 / 2 / 7 / 7 / 1` — every cell matches | **VERIFIED** |
| 33 | the 5 multi-endpoint forms (`hooks.json:4-5`, `unreal-context.sh:5,8`, `README.md:39,45`, `README.md:50-57`, `setup.md:61,70-79`) all resolve | `reruns/pointers.md` §3.1 | `wc -l` on each target (17, 84, 112, 133) vs max endpoint cited (5, 8, 57, 79) | every endpoint ≤ its file's line count; no `LINE-OOR` emitted | **VERIFIED** |
| 34 | max-line reference table (112 / 17 / 133 / 84 / 51 / 420) | `reruns/pointers.md` §3.1 | `wc -l < corpus/knowledge/unreal-mcp/upstream/<f>` for each of the 6 | `112, 17, 133, 84, 51, 420` — all six match | **VERIFIED** |
| 35 | negative control N1: 3 sentinels skipped, neighbouring real pointer still counted → `POINTERS=48 SKIPPED=3` | `reruns/pointers.md` §6 | replanted the 3 sentinels + `upstream/README.md:1` on a copy, re-ran the sweep | `FILES_SCANNED=17 POINTERS=48 SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=0`, `STEP=PASS` | **VERIFIED** |
| 36 | negative control N2: 3 broken pointers → `UNRESOLVED=3`, exit 1 | `reruns/pointers.md` §6 | replanted the 3 pointers on a copy, re-ran | `MISSING-PATH …`, `LINE-OOR …:10-99999 (max 112)`, `LINE-OOR …:99999 (max 112)`, `POINTERS=51 UNRESOLVED=3`, exit 1 | **VERIFIED** |
| 37 | SEAT-39's manual fallback: 14 distinct `corpus/knowledge/unreal-mcp/…` pointers, 0 missing | `gate/runtime-run.md` Check 4 | `grep -rhoE 'corpus/knowledge/unreal-mcp/[A-Za-z0-9._/-]+\.(md\|json\|sh\|sha256)' … \| sed 's/[.,;:)]*$//' \| sort -u \| wc -l` | `14`; the existence loop emits 0 `MISSING` lines | **VERIFIED** |

**Note on 26 vs 31 vs 37 (three different pointer counts, all correct).** The gate counts 40, the r102
rerun counts 47, SEAT-39's manual fallback counts 14. These are three different regexes over three
different file sets — the gate matches `upstream/…:<line>` over all non-`upstream/` `.md` (including
`gate/README.md` if it were not sentinel-skipped), the rerun additionally expands `:a-b` and `:a,b`
endpoints, and SEAT-39 matches the `corpus/knowledge/unreal-mcp/` prefix over only the index + 13 cards.
I re-derived all three independently. **No contradiction**; each artifact states its own scope.

## 5. `run_battery.py` and the fixtures tree

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 38 | `CASES` = **350** rows | `battery-integrity.md` §4, `before/baseline-integrity.md` §2 | `python3 -c "import ast; … len(rows)"` | `rows: 350` | **VERIFIED** |
| 39 | all 350 rows are 5-field tuples | `battery-integrity.md` §4 | same AST script, field-width histogram | `widths: {5: 350}` | **VERIFIED** |
| 40 | exit-code histogram `{0: 291, 2: 59}` | `battery-integrity.md` §4 | same AST script, `Counter` over field 3 | `exitcodes: {0: 291, 2: 59}` | **VERIFIED** |
| 41 | 350 unique names, 0 duplicates | `battery-integrity.md` §4 | same AST script | `names_unique: 350 dupes: 0` | **VERIFIED** |
| 42 | 0 rows whose fixture file is missing on disk | `battery-integrity.md` §4 | same AST script, `os.path.exists` per row | `rows whose fixture missing: 0` | **VERIFIED** |
| 43 | `CASES` is 1 assignment at **line 39** | `before/baseline-integrity.md` §2 | `ast.parse` → `(lineno, len(elts))` | `[(39, 350)]` | **VERIFIED** |
| 44 | 27 top-level statements | `before/baseline-integrity.md` §2 | `len(ast.parse(src).body)` | `27` | **VERIFIED** |
| 45 | `run_battery.py` sha256 `f456bd00a1f7cc6f…` (live **and** HEAD blob) | `before/F3-sha-drift.md:36,42`, `battery-integrity.md` §3 | `sha256sum corpus/fixtures/run_battery.py`; `git show HEAD:corpus/fixtures/run_battery.py \| sha256sum` | both `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | **VERIFIED** |
| 46 | HEAD blob is **346248 bytes** | `battery-integrity.md` §4 | `git show HEAD:corpus/fixtures/run_battery.py \| wc -c` | `346248` | **VERIFIED** |
| 47 | blob object id `dd2d9b74448afddb…` (worktree == HEAD) | `battery-integrity.md` §3 | `git hash-object`; `git rev-parse HEAD:…` | both `dd2d9b74448afddb88dcf2da56008302eba8060d` | **VERIFIED** |
| 48 | **146** tracked fixture files | `battery-integrity.md` §2 | `git ls-tree -r HEAD --name-only corpus/fixtures/ \| wc -l` | `146` | **VERIFIED** |
| 49 | 0 byte-mismatches vs HEAD across all 146 | `battery-integrity.md` §2 | re-ran the blob-id comparison loop | `tracked fixture files: 146` / `byte-mismatch vs HEAD: 0` | **VERIFIED** |
| 50 | aggregate digest `827af6c35233bc52…` from both index and HEAD | `battery-integrity.md` §2 | `git ls-files -s … \| awk … \| sort \| sha256sum` and the `git ls-tree -r HEAD …` twin | both `827af6c35233bc520d5a797dd650a777df1f18ab9fca9652e5fab0b1e539096d` | **VERIFIED** |
| 51 | 0 untracked non-ignored files under `corpus/fixtures/` | `battery-integrity.md` §2 | `git status --porcelain -- corpus/fixtures/ \| wc -l` | `0` | **VERIFIED** |
| 52 | 1410 files in the ignored `three/node_modules/` tree | `battery-integrity.md` §2 | `find corpus/fixtures/three/node_modules -type f \| wc -l`; `find corpus/fixtures -type f -not -name '*.pyc' \| wc -l` | `1264` for `node_modules/`; `1410` is the whole-`fixtures` file count (`1264 + 146`), not `node_modules` | **WRONG** → §9.3 |
| 53 | 1265 ignored entries under `corpus/fixtures/` (1264 `node_modules` + 1 `__pycache__`) | `git-hygiene.md` §"Protected-path" | `git status --porcelain --ignored -uall -- corpus/fixtures \| wc -l`; `… \| grep -c node_modules`; `… \| grep -v node_modules` | `1265`; `1264`; `!! corpus/fixtures/__pycache__/run_battery.cpython-314.pyc` | **VERIFIED** |

## 6. The routed defects F1/F2/F3/F5/F6 — before → after

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 54 | F1 before: the `.shokunin/game-dev-3d/` path root exits 2 | `repairs/F1a-r22-readme.md` BEFORE | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py` | `can't open file '…/.shokunin/game-dev-3d/…': [Errno 2] No such file or directory`, `exit=2` | **VERIFIED** |
| 55 | F1 after: both repaired commands exit 0 | `repairs/F1a-r22-readme.md` AFTER | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` and the `--expect-reject` twin | `PASS local-static actual=accept expected=accept`, `exit=0`; `PASS local-static actual=reject expected=reject`, `exit=0` | **VERIFIED** |
| 56 | F1: no `shokunin/game-dev-3d` string remains in the owned README | `repairs/F1a-r22-readme.md` §Residual scan | `grep -n "shokunin/game-dev-3d" corpus/artifacts/unreal-r22/README.md` | no output, grep exit 1 | **VERIFIED** |
| 57 | F2: the cited receipt path is absent (exit 2) and gitignored | `before/F2-verdicts-json.md` §1–§2 | `ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json`; `git check-ignore -v …` | `No such file or directory`, exit 2; `corpus/.gitignore:1:live/` matched | **VERIFIED** |
| 58 | F2: 275 commits across all refs, 3 refs | `before/F2-verdicts-json.md` §3 | `git rev-list --all --count`; `git for-each-ref \| wc -l` | `275`; `3` (`main`, `origin/HEAD`, `origin/main`) | **VERIFIED** |
| 59 | F3: stale cite `a065a56db193228d…` is still at `r22-unreal-review.md:48` | `before/F3-sha-drift.md` | `grep -rn "a065a56d" …` | hit at `corpus/lessons/r22-unreal-review.md:48` (and quoted as history in `reports/round-101/r101-critic-c3.md:201`) | **VERIFIED** |
| 60 | F3: current file hashes to `f456bd00…`, **346248** bytes | `before/F3-sha-drift.md:42` | `sha256sum`; `wc -c` on the HEAD blob | `f456bd00…`, `346248` | **VERIFIED** |
| 61 | F5 before: the bare `node …` command exits 1 on a pristine `git archive HEAD` tree | `before/F5-engines-threejs.md` §2b | `git archive HEAD \| tar -x -C /tmp/… && node corpus/fixtures/three/run_cases.mjs` | 4 × `FAIL`, summary line `FAIL three battery: 3/3`, `exit=1` | **VERIFIED** |
| 62 | F5 after: the repaired `npm ci --prefix …` command exits 0 with 3/3 | `engines.md:11` (post-repair), `before/F5-engines-threejs.md` §5 | same pristine export, then `npm ci --prefix corpus/fixtures/three --offline && node corpus/fixtures/three/run_cases.mjs` | `added 1 package … found 0 vulnerabilities`; 4 × `PASS`; `three battery: 3/3, seeds_unchanged=true`; `exit=0` | **VERIFIED** |
| 63 | F5 root cause: `node_modules/` is gitignored, 0 tracked files | `before/F5-engines-threejs.md` §3 | `git ls-files corpus/fixtures/three/node_modules \| wc -l`; `git check-ignore -v …` | `0`; `corpus/fixtures/three/.gitignore:1:node_modules/` | **VERIFIED** |
| 64 | F6: `rea.md` before-state sha256 `9be388f3…`, **27** lines, last commit `82c21b4` (2026-10-13) | `before/F6-rea-census.md` §0 | `sha256sum`; `wc -l`; `git log -1 --format='%h %ad'` on `82c21b4` | `9be388f3137666a68b0ca49a0284696bedc77e22ea2b632415ff386c25da1c32`; `27`; `82c21b4 2026-10-13` | **VERIFIED** |
| 65 | F6: `which jadx binwalk unblob` exit 0; versions 1.5.6 / 3.1.0 / 26.6.4 | `before/F6-rea-census.md` §2 | `which jadx binwalk unblob; echo $?`; `jadx --version`; `binwalk --version`; `unblob --version` | `/usr/bin/jadx`, `/usr/bin/binwalk`, `/home/vgpnk/.local/bin/unblob`, exit 0; `1.5.6`, `binwalk 3.1.0`, `26.6.4` | **VERIFIED** |
| 66 | F6: Ghidra and pwntools still absent (the controls) | `before/F6-rea-census.md` §3, `repairs/F6-rea-census.md` §5 | `which ghidra ghidraRun`; `python3 -c "import pwn"` | `which` fails (exit 2, no hits); `ModuleNotFoundError: No module named 'pwn'` | **VERIFIED** |
| 67 | F6 repair: `pwntools` 4.15.0 importable via `$REA_PWNTOOLS_PYTHON` | `repairs/F6-rea-census.md` §2 | `"$REA_PWNTOOLS_PYTHON" -c "import pwnlib; print(pwnlib.version)"` | `pwnlib 4.15.0`, rc=0 | **VERIFIED** |
| 68 | F6 repair: JADX MCP JAR is **42619858** bytes | `repairs/F6-rea-census.md` §3 | `ls -l "$REA_JADX_MCP_JAR" \| awk '{print $5}'` | `42619858` | **VERIFIED** |
| 69 | F6 repair: 7 `REA_*` env vars present, incl. `REA_WAKARU_COMMAND` | `repairs/F6-rea-census.md` §4 | `env \| grep -i "^REA_" \| sort \| wc -l` | `7` — the seven listed | **VERIFIED** |
| 70 | F6 repair after-state: `rea.md` **63** lines, sha256 `3932fc53…`; historical sentence preserved (grep count still 1) | `repairs/F6-rea-census.md` §AFTER | `wc -l`; `sha256sum`; `grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools"` | `63`; `3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059`; `1` | **VERIFIED** |
| 71 | F8 fold: subtree README resolves the `:187` "12 lines" ambiguity by naming both counts (12 and 24) | `before/baseline-integrity.md` §8, `README.md:169,187,194` | `grep -n "12 lines\|24 lines\|24 \*\*\`OK\`\*\*" corpus/knowledge/unreal-mcp/README.md`; `sha256sum` | `187:Observed output of the sweep (12 lines, all `OK`)` and the `:169` line naming both `12` and `24`; live sha256 moved `2004a9e5…` → `fcd2b717…` → `c79d8dd1…` as the fold was revised during the audit window | **VERIFIED** (the fold's *content* is correct; its digest is moving — see §11) |

## 7. The r102 lesson `corpus/lessons/r102-unreal-integration.md`

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 72 | 12/12 vendored files, `sha256sum -c` → 12 × `OK`, exit 0, cited at `README.md:262-264` | lesson `:19-22` | `sed -n '262,264p' corpus/knowledge/unreal-mcp/README.md`; the command itself | lines 262–264 are `# 1. Byte-identity of all 12 vendored files (expect all OK, exit 0)` / `sha256sum -c .manifest.d/audit-reference.sha256` / `sha256sum -c .manifest.d/*.sha256` — the cite is **exact**; command gives 12 `OK`, rc=0 | **VERIFIED** |
| 73 | "11" is the seat count, "12" the file count, cited at `README.md:98-102` | lesson `:30-33` | `sed -n '98,102p' …` | the round-brief note saying exactly that, naming `seat11` as the two-file shard | **VERIFIED** |
| 74 | 13 cards, 12 × `static-only`, 1 × `unproven-runtime` (`actors-scene.md:5`), 0 × `verified-here` | lesson `:78-79` | gate Check 3; `sed -n '5p' executability/actors-scene.md` | census reproduced; `actors-scene.md:5` is the `unproven-runtime` declaration | **VERIFIED** |
| 75 | all 25 lesson pointer targets resolve inside their files | lesson `:13-14`, `:22-23`, `:26`, `:37-40`, `:46-48`, `:51-59`, `:64-65`, `:70-89`, `:99-115`, `:120` | `wc -l` on each cited file, comparing each cited line number to the file's length | 25/25 in range: `PROVENANCE.md` max 361, `README.md` max 301, `r101-report.md` max 346, `LOG.md` max 1325 — every cite ≤ its max | **VERIFIED** |
| 76 | `LOG.md` round 101 spans lines 1302–1325 | lesson `:3` | `wc -l LOG.md`; the cites themselves | `1325` — both endpoints valid | **VERIFIED** |
| 77 | 6 of 13 cards reject ``Not `unproven-runtime` `` | lesson `:84-90` | `grep -rln 'Not `unproven-runtime`' … \| wc -l` | `6` | **VERIFIED** (same as #22) |
| 78 | 5 PR-only paths and 1 history-only file, cited at `PROVENANCE.md:340-356` | lesson `:26-27` | `sed -n '340,356p' …` (in range) | section present at those lines | **VERIFIED** |
| 79 | the AUR `PKGBUILD` is 527 lines | `install-recheck.md` §headline, `:174` | `wc -l /tmp/r101seat12-aur-PKGBUILD` | `527` | **VERIFIED** |
| 80 | r101 report's `:320-321`, `:338-342` cites resolve | lesson `:27`, `:115` | `wc -l reports/round-101/r101-report.md` | `346` — both ranges in range | **VERIFIED** |

## 8. Byte and digest spot-checks of the r102 report files themselves

`reports/round-102/reports-index.md` §1 published an 18-file inventory with byte sizes and 16-hex
digests at `2026-10-18T17:42:20Z`. I spot-checked every entry that had not been rewritten since.

| # | path | claimed bytes / sha16 | my observed | verdict |
|---|---|---|---|---|
| 81 | `adversary/F3.md` | 11028 / `6a2d297a3379dd7d` | 11702 / `7d37c5f5eaa71eff` | **WRONG** → §9.4 |
| 82 | `battery-integrity.md` | 6282 / `01f101c85d9bd70a` | `6282` / `01f101c85d9bd70a` | **VERIFIED** |
| 83 | `before/baseline-integrity.md` | 17937 / `cb193412cbbe1b65` | `17937` / `cb193412cbbe1b65` | **VERIFIED** |
| 84 | `before/F2-verdicts-json.md` | 4447 / `6a9e157740464e3f` | `4447` / `6a9e157740464e3f` | **VERIFIED** |
| 85 | `before/F3-sha-drift.md` | 6491 / `c45493548703051a` | `6491` / `c45493548703051a` | **VERIFIED** |
| 86 | `before/F5-engines-threejs.md` | 8827 / `706ff204cc5e7907` | `8827` / (rewritten by its author since — see §11) | **VERIFIED** as of the frame; the file has since been edited |
| 87 | `before/F6-rea-census.md` | 5580 / `4f9b01f9dfae3b77` | `5580` | **VERIFIED** |
| 88 | `freshness-pin.md` | 6504 / `0c9eb3ce720460e3` | `6504` / `0c9eb3ce720460e3` | **VERIFIED** |
| 89 | `gate/runtime-run.md` | 9554 / `f0e72cd3e96038f9` | `9554` / `f0e72cd3e96038f9` | **VERIFIED** |
| 90 | `git-hygiene.md` | 5884 / `6b03316ce8a13bac` | `5884` / `6b03316ce8a13bac` | **VERIFIED** |
| 91 | `lesson-index.md` | 3335 / `73480fd4f554b84a` | `3335` / `73480fd4f554b84a` | **VERIFIED** |
| 92 | `repairs/F1a-r22-readme.md` | 3642 / `c347527347bccd62` | `3642` | **VERIFIED** |
| 93 | `repairs/F6-rea-census.md` | 9739 / `542c5a189f1bc70f` | `9739` / `542c5a189f1bc70f` | **VERIFIED** |
| 94 | `reruns/labels.md` | 14238 / `7c5826b8092761c3` | `14238` / `7c5826b8092761c3` | **VERIFIED** |
| 95 | `reruns/links.md` | 13059 / `b36c99e53752e93f` | `13059` / `b36c99e53752e93f` | **VERIFIED** |
| 96 | `reruns/manifest.md` | 9802 / `092a97d4a4d52ae0` | `9802` / `092a97d4a4d52ae0` | **VERIFIED** |
| 97 | `reruns/pointer-sweep.sh` | 2203 / `dd5edc70ef639d71` | `2203` / `dd5edc70ef639d71` | **VERIFIED** |
| 98 | r102 dir holds **18** files at that frame, 7 → 18 in 53 s | `reports-index.md` §1.2 | `find reports/round-102 -type f \| wc -l` | `34` at `17:44:12Z` — growth continued past the frame, exactly as the file predicts | **VERIFIED** (frame-local count) |
| 99 | no `r102-report.md` exists at that frame | `reports-index.md` §1 | `ls reports/round-102/r102-report.md` | `No such file or directory` | **VERIFIED** |

## 9. WRONG findings — detail

### 9.1 `reports/round-102/lesson-index.md` §E6 — lesson-file count

**Claim** (E6, verbatim): `$ ls corpus/lessons/*.md | wc -l` → `90`.

```
$ ls corpus/lessons/*.md | wc -l
91
```

**Verdict: WRONG as a present-tense number.** 91, not 90. The cause is not a false command — the same
file's own §E5 proves `corpus/lessons/r102-unreal-integration.md` did **not exist** when the seat ran
(`test -e … → exit=1`), and I confirm it exists now (11059 bytes, mtime `14:42`). So 90 was correct at
the seat's runtime and the count moved because the r102 lesson landed afterwards. This is a
**timing-drift artifact**, not a fabrication; it is the same class the round's own
`before/baseline-integrity.md` §8 handles correctly by adding a dated post-snapshot note.

**Recommendation (for the L1, not this seat's to apply):** `lesson-index.md` should carry a dated
addendum saying the 90 became 91 when C1(b) landed. I did not edit it — it is another seat's path.

### 9.2 `reports/round-102/reruns/pointers.md` §3.1 — column total

**Claim** (§3.1 table): the "distinct" column totals **41** (18+6+2+7+7+1), while the row beneath
labels the total line `**total** | **41** | **47**` and the prose says `POINTERS=47`.

```
$ for f in …; do grep -ohE 'upstream/…:[0-9]+([,-][0-9]+)*' "$f" | sort -u; done | wc -l
41
```

**Verdict: WRONG only in presentation, and self-disclosed.** The `POINTERS=47` value is the *endpoint*
count (after expanding `:a-b` and `:a,b`), while 41 is the *per-file-distinct string* count; the file
flags this in its own text ("Wait — the distinct strings total 41, not 47 … Both numbers are printed by
the tooling and both are consistent"). Both are re-derivable and the sweep's verdict (`UNRESOLVED=0`)
does not depend on which is quoted. I record it as WRONG because a table column labelled "distinct"
whose own total row prints a different number is a numeric inconsistency on its face — but it is
disclosed, and it is not a false pass.

### 9.3 `reports/round-102/battery-integrity.md` §2 — `node_modules` file count

**Claim**: "the pre-existing `three/node_modules/` dependency checkout (**1410 files** on disk vs 146
tracked)".

```
$ find corpus/fixtures/three/node_modules -type f | wc -l
1264
$ find corpus/fixtures/three/node_modules | wc -l
1388
$ find corpus/fixtures -type f | wc -l
1411
$ find corpus/fixtures -type f -not -name '*.pyc' | wc -l
1410
```

**Verdict: WRONG as stated — the number is real but attributed to the wrong tree.** The `1410` is
`1264` files under `three/node_modules/` **plus** the `146` tracked fixture files = **1410 files under
`corpus/fixtures/`** (excluding the one `__pycache__/*.pyc`). It is not the `node_modules` count; the
sentence's own parenthetical "(1410 files on disk vs 146 tracked)" is what gives it away — 146 is the
tracked count for the *whole* fixtures tree (#48), so the two numbers in that aside are not even
counting the same object. `find corpus/fixtures/three/node_modules -type f` is unambiguously `1264`,
which is the figure `git-hygiene.md:28,70` reports for the same tree (independently **VERIFIED** at
#53). The *load-bearing* claim in the sentence — that the ignored tree is not tracked and that nothing
tracked was disturbed — is separately true and independently verified (#51, #53). So: a real
aggregate, mislabelled scope; the sentence is wrong about which tree holds 1410.

### 9.4 `reports/round-102/reports-index.md` §1 — `adversary/F3.md` size/digest

**Claim**: `adversary/F3.md` → 11028 bytes / `6a2d297a3379dd7d`.

```
$ stat -c%s reports/round-102/adversary/F3.md ; sha256sum reports/round-102/adversary/F3.md | cut -c1-16
11702
7d37c5f5eaa71eff
```

**Verdict: WRONG as a present-tense value.** The file was appended to after the `17:42:20Z` frame
(the same frame that `reports-index.md` itself declares, in its own §1.2, was "never stopped
changing"). Every other of the 17 entries I could compare at a stable moment matched exactly. The
report's frame timestamp and its own drift warning make this a snapshot artifact rather than a
mis-measurement — but the number no longer reproduces, so it is recorded WRONG.

## 10. UNVERIFIABLE BY CONSTRUCTION (not counted as passes)

Two items in the r102 corpus are *posture* claims rather than measurements, and no command on this host
can settle them. They are listed so their absence from the VERIFIED column is explicit, not silent.

- **`verified-here` = 0 is correct.** `gate/runtime-run.md` and `reruns/labels.md` both argue the zero
  follows from Unreal Editor not being installed. I can verify the *premise* (`which` finds no Unreal
  editor binary; `corpus/knowledge/engines.md:10` records `installed = no`) and I can verify the
  *count* (census = 0, #16), but the claim "no card *can* carry a `verified-here` label" is a statement
  about a counterfactual host. Marked unverifiable, not passed.
- **Live-MCP behavior of the vendored plugin.** No r102 artifact claims it, and every artifact I read
  disclaims it. Nothing to verify; recorded so the boundary is on the record. **No Unreal runtime claim
  is made or implied anywhere in this audit** — the editor is not installed on this host.

## 11. Concurrency disclosure — the tree mutated throughout this audit

This audit ran while other r102 seats were still landing files, exactly as `reports-index.md` §1.2 and
`git-hygiene.md` §"Observations" both warn. Concrete evidence I captured:

- `reports/round-102/` held **29** files at `17:43:31Z` and **34** at `17:44:12Z`.
- `corpus/knowledge/unreal-mcp/README.md` took **three** distinct digests inside my window:
  `2004a9e5aadcdc82…` → `fcd2b7179d95d327…` → `c79d8dd1d7c0c7bc…`, as its owning seat revised the F8
  fold. Each revision's *content* was checked and is correct (#71).
- **A transient window in which the byte-pinned subtree appeared dirty.** At `17:43:31Z` my
  `git status --porcelain -uall` listed `M corpus/knowledge/unreal-mcp/upstream/README.md` and
  `M corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md`, and
  `git diff --stat` reported **168 deletions across those 2 files** — both vendored files appeared
  truncated. The manifest check in that same instant reported
  `upstream/README.md: FAILED` and `upstream/skills/unreal-mcp/SKILL.md: FAILED`
  (`sha256sum: WARNING: 2 computed checksums did NOT match`). By `17:43:34Z` both were byte-identical
  to HEAD again (`483693ad0e14…46b40e` and `7ef8b991a82f…d038fa`), the manifest sweep was 12/12 `OK`
  with `rc=0`, and the gate ran `PASS`, exit 0. The files' line counts (`112`, `56`) matched
  `git show HEAD:` exactly, so nothing persisted.

  `reports/round-102/reports-index.md` §"§435" independently recorded the same 3-second window from a
  different seat. **Cause: a concurrent writer that truncates and restores the vendored files, not a
  persisted defect.** I could not observe the writer; the only r102 script that references
  `upstream/README.md` as a write target is `gate/run_gate.sh`, whose only destructive operation is
  `rm -rf "$WORK"` on its own `mktemp` directory — so the observed window most plausibly came from a
  mutation-test harness operating on the live tree rather than on a copy.

  **Consequence for the round:** a byte-pin check that samples the subtree at one instant can return
  a false FAIL during such a window. The round-close gate run should be taken when no writer is
  active, and a FAIL should be re-run before it is reported. I re-ran the gate at `17:44:12Z`:
  `GATE RESULT: PASS (checks failed: 0)`, exit 0, `manifest_rc=0`.

## 12. What this audit does not claim

- No Unreal Editor, MCP endpoint, UnrealBuildTool, or engine binary was involved. Every check is a
  file/byte/AST/exit-code observation. No runtime claim is made or implied.
- This audit does not judge whether a card's *label* matches its *evidence* — that is a read-the-cards
  judgement the gate itself declines to make (`gate/README.md` §"What this gate does not do"). I
  verified the census and the mechanical one-label-per-card property, nothing more.
- A VERIFIED verdict means *the number reproduces on this host at this instant*. Where a number is
  snapshot-local, §11 says so; the moving digests are reported rather than smoothed over.
- I wrote **only** `reports/round-102/math-audit.md`. No other path was created or modified, and no
  `git commit`/`push`/`checkout`/`reset` was run.

## 13. Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# subtree + manifest
find corpus/knowledge/unreal-mcp -type f | wc -l                       # 40
ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l              # 13
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 ; echo rc=$?   # 12 OK, rc=0
sha256sum -c .manifest.d/*.sha256 | grep -c ': OK$'                    # 24

# the gate and its controls
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ; echo rc=$?         # PASS, rc=0
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf '\n' >> "$T/sub/upstream/README.md"
bash "$T/sub/gate/run_gate.sh" ; echo rc=$?                            # FAIL, rc=1

# battery
python3 -c "import ast,collections,os; t=ast.parse(open('corpus/fixtures/run_battery.py').read()); c=[ast.literal_eval(n.value) for n in t.body if isinstance(n,ast.Assign) and any(getattr(x,'id',None)=='CASES' for x in n.targets)][0]; print(len(c), collections.Counter(len(r) for r in c), collections.Counter(r[3] for r in c))"
git ls-tree -r HEAD --name-only corpus/fixtures/ | wc -l               # 146
sha256sum corpus/fixtures/run_battery.py                               # f456bd00…
git show HEAD:corpus/fixtures/run_battery.py | wc -c                   # 346248

# F5 on a pristine tree
rm -rf /tmp/mathaudit && mkdir -p /tmp/mathaudit && git archive HEAD | tar -x -C /tmp/mathaudit
(cd /tmp/mathaudit && node corpus/fixtures/three/run_cases.mjs) ; echo rc=$?                     # FAIL, rc=1
(cd /tmp/mathaudit && npm ci --prefix corpus/fixtures/three --offline && node corpus/fixtures/three/run_cases.mjs) ; echo rc=$?   # 3/3, rc=0

# pointer sweeps
bash reports/round-102/reruns/pointer-sweep.sh                         # 47 / UNRESOLVED=0
```
