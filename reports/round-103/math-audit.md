# r103 SEAT-38 MATH-AUDIT — independent recount of the numeric claims in the r103 artifacts

- **Seat:** SEAT-38 MATH-AUDIT (r103). Owned path: `reports/round-103/math-audit.md` (this file, only).
- **Lane:** `game-dev-3d-shokunin` · HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`).
- **Working dir:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Audit window:** `2026-10-18T18:30:00Z` → `18:37:12Z` (UTC), all commands run on this host.
- **Method:** every number below was **re-derived by my own command**, not copied from the artifact under
  audit. Each row states the claim, the artifact that makes it, my command, my observed output, and a
  verdict of **VERIFIED** or **WRONG**.
- **Scope:** the r103 artifacts that exist at my runtime — **36 files** under `reports/round-103/` at the
  closing timestamp; I read 14 in full and my rows cite 22. Every protected path was read-only to this
  seat; I wrote nothing outside this file and ran no `git commit`/`push`/`checkout`/`reset`.
- **Sample size:** **126 numbered rows**, spanning **22 distinct r103 artifact paths** (well past the
  ≥10-numbers-across-≥5-files floor), plus **3 separate WRONG findings**, **1 retracted candidate**,
  **8 STALE-FRAME rows** and **1 UNVERIFIABLE-BY-CONSTRUCTION row** recorded outside the numbered set.

---

## 0. Headline

| verdict | count | note |
|---|---:|---|
| **VERIFIED** (numbered rows) | **126** | re-derived by my own command, matches the claim exactly |
| **WRONG** (§9, separate findings) | **3** | three live-directory counts in one artifact; all time-dependent |
| **RETRACTED** (§9.4) | **1** | a candidate I raised, then withdrew — the error was mine |
| **STALE-FRAME** (§10) | **8** | measured true, superseded in-round; each source discloses its frame |
| **UNVERIFIABLE-BY-CONSTRUCTION** (§11) | **1** | no editor installed; posture claim, not a number |

**Every one of the 126 numbered rows reproduced exactly.** No number that carries a check verdict, a
byte-pin, a pin SHA, or a manifest digest was wrong — and neither was any *descriptive* number in the
numbered set. This is a stronger result than the r102 audit reached (97 VERIFIED / 2 WRONG).

**Three additional claims, audited in §9 and not counted among the 126, did not reproduce** — all three are
live filesystem census counts in `b2/adversary.md` taken over directories the round was concurrently
writing. They are reported separately because I cannot prove they were wrong *when written*; they are wrong
*today*, and they are printed as present-tense facts. §9.4 records a fourth candidate that I **retracted**:
on re-check with the artifact's exact regex, its `1076` / `254` reproduce precisely, and the discrepancy was
my own one-character paraphrase error. §9.5 records a fifth candidate that I reclassified from WRONG to
STALE-FRAME (carried as §10 F7), for the same reason.

**Methodology note.** This audit's one false positive came from re-typing a source's command instead of
copying it. A math audit that paraphrases the command under test measures its own paraphrase. Every row in
§1–§8 used the source's own invocation; §9.4 is the exception that proves the rule.

**The one systemic finding is environmental, not numeric.** The round ran on a host whose `/tmp` is a
quota-limited `tmpfs` at 77–80 % full; at least four independent seats hit `Disk quota exceeded` mid-round
(`install-recheck.md` §3, `freshness-pin.md` §6, `gate/a4-attack.md` §"Control 2", and my own first gate
run in §4). Two of those incidents are *silent*: a shell redirect that truncates produces a gate transcript
that reads as a genuine `CHECK 2` failure. §4 documents a live instance. This is the round's most
important non-numeric observation.

---

## 1. The lane identity and the protected paths

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 1 | lane HEAD is `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` | every r103 file's header | `git rev-parse HEAD` | `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` | **VERIFIED** |
| 2 | `LOG.md` blob `8e762af047896c72…` = HEAD | `ledger-check.md` §1, `seats-ledger.md` §1 | `git hash-object -- LOG.md`; `git rev-parse HEAD:LOG.md` | both `8e762af047896c727012edf8dc2fb97b7a8506a9` | **VERIFIED** |
| 3 | `SCORECARD.md` blob `d4b73d776da20ae6…` = HEAD | `ledger-check.md` §1 | same pair | both `d4b73d776da20ae65421b45653a789d49aef8d4c` | **VERIFIED** |
| 4 | `SHONEN.md` blob `8d85902c19010deb…` = HEAD | `ledger-check.md` §1 | same pair | both `8d85902c19010deb4fa154e16a2c12ad56ff10d1` | **VERIFIED** |
| 5 | `PROVINCE.md` blob `cde5e8f518bb0514…` = HEAD | `seats-ledger.md` §1 | same pair | both `cde5e8f518bb05149ab62e4ea5aa44f547e8aa69` | **VERIFIED** |
| 6 | sha256 of the four ledgers | `ledger-check.md` §1, `seats-ledger.md` §1 | `sha256sum LOG.md SCORECARD.md SHONEN.md PROVINCE.md` | `f73ec78c…fd37`, `b3b09e52…d67f`, `b44667ff…6062`, `1932f0fd…0eac` — all four match | **VERIFIED** |
| 7 | `reports/round-101` = 33 files, 0 differing, 0 missing | `ledger-check.md` §2, `seats-ledger.md` §3 | per-file blob walk of `git ls-tree -r HEAD -- reports/round-101` | `identical=33 differing=0 missing=0` | **VERIFIED** |
| 8 | `reports/round-102` = 61 files, 0 differing, 0 missing | same | same walk | `identical=61 differing=0 missing=0` | **VERIFIED** |
| 9 | tree ids `a28869fc…` (r101) and `92d4dc84…` (r102) | `ledger-check.md` §2, `seats-ledger.md` §3 | `git ls-tree HEAD reports/round-101 reports/round-102` | `a28869fcf749c34fbd91edc485afde86fae37841`, `92d4dc84dd979ecff01fe050436811c43453ada8` | **VERIFIED** |
| 10 | `corpus/fixtures` = 146 files, 0 differing, 0 missing | `seats-ledger.md` §3 | blob walk over `git ls-tree -r HEAD -- corpus/fixtures` | `identical=146 differing=0 missing=0` | **VERIFIED** |
| 11 | `upstream/` = 12 files and `.manifest.d/` = 12 files, all identical | `seats-ledger.md` §3, `subtree-integrity.md` §3 | two blob walks | `identical=12 differing=0 missing=0` for each | **VERIFIED** |
| 12 | five subtree object ids | `seats-ledger.md` §3, `subtree-integrity.md` §3 | `git rev-parse HEAD:<dir>` | fixtures `4ebcc2db…`, upstream `b5b9624b…`, `.manifest.d` `87bde5b7…`, r101 `a28869fc…`, r102 `92d4dc84…` | **VERIFIED** |
| 13 | no lane-level `SKILL.md` exists outside the pinned upstream | `seats-ledger.md` §2 | `find . -name 'SKILL.md' -not -path './.git/*' -not -path './corpus/knowledge/unreal-mcp/upstream/*'` | no output (0) | **VERIFIED** |
| 14 | 0 untracked non-ignored files in any protected tree | `seats-ledger.md` §4 | `git ls-files --others --exclude-standard -- LOG.md … reports/round-102` | `0` | **VERIFIED** |
| 15 | ignored residue dirs: `__pycache__` mtime `14:41:15`, `three/node_modules` mtime `14:46:31` | `seats-ledger.md` §4 | `stat -c '%y %n' corpus/fixtures/__pycache__ corpus/fixtures/three/node_modules` | `2026-10-18 14:41:15.006253254`, `2026-10-18 14:46:31.649483471` | **VERIFIED** |
| 16 | newest tracked fixture file is `three/package-lock.json` at `14:22:42` | `seats-ledger.md` §4 | `git ls-files -z corpus/fixtures \| xargs -0 stat -c '%Y %y %n' \| sort -rn \| head -3` | `2026-10-18 14:22:42.160971983 corpus/fixtures/three/package-lock.json` | **VERIFIED** |

---

## 2. The upstream pin and its provenance

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 17 | pin `a6aa73ad…b297` is still `main`'s tip | `freshness-pin.md` §2–§3 | `git ls-remote --symref <url> HEAD` | `ref: refs/heads/main HEAD` + `a6aa73ada02a9fb1f5415bec491f9942c519b297 HEAD` | **VERIFIED** |
| 18 | upstream publishes no tags | `freshness-pin.md` §3 | `git ls-remote --tags <url>` | no output, rc=0 | **VERIFIED** |
| 19 | repo public, not archived, `default_branch: main`, `pushed_at 2026-09-17T02:27:43Z` | `freshness-pin.md` §3 | `gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '{default_branch, pushed_at, archived, private}'` | `{"archived":false,"default_branch":"main","private":false,"pushed_at":"2026-09-17T02:27:43Z"}` | **VERIFIED** |
| 20 | `/tmp/ue-skills-ref` origin is the `-plugin` URL and `rev-parse HEAD` is the pin | `note/urls.md` §4, `note/author.md` §5 | `git -C /tmp/ue-skills-ref remote -v`; `git -C /tmp/ue-skills-ref rev-parse HEAD` | origin `…-claude-code-plugin`; HEAD `a6aa73ada02a9fb1f5415bec491f9942c519b297` | **VERIFIED** |
| 21 | `audit-reference.sha256` verifies 12/12, rc=0 | `subtree-integrity.md` §1, `freshness-pin.md` §4, `note/binary.md` §2.3 | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 `: OK`, 0 `FAILED`, rc=0 | **VERIFIED** |
| 22 | all 11 seat shards sweep clean; 14 shard entries, all rc=0 | `subtree-integrity.md` §1 | per-file `sha256sum -c` loop over `.manifest.d/*.sha256` | audit-ref 12 OK; seat01–seat10 1 OK each; `seat11` 2 OK; **14/14 OK, 0 FAILED, all rc=0** | **VERIFIED** |
| 23 | `seat11.sha256` covers 2 files (10×1 + 2 = 12 entries) | `subtree-integrity.md` §1 table | `wc -l .manifest.d/seat*.sha256` | 10 files × 1 line, `seat11` = 2 lines → 12 | **VERIFIED** |
| 24 | `audit-reference.sha256` pins `upstream/LICENSE` = `5b337be051359edc…` | `gate/mutations.md` §M3 | `grep -n 'upstream/LICENSE' .manifest.d/audit-reference.sha256` | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | **VERIFIED** |
| 25 | `upstream/skills/unreal-mcp/SKILL.md` = `7ef8b991a82f591c…` (M1's "orig sha256") | `gate/mutations.md` §M1 | same grep, line 17 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` | **VERIFIED** |
| 26 | `upstream/hooks/hooks.json` = `259124f0631b7d4b…` | `note/author.md` §5 | `sha256sum …/upstream/hooks/hooks.json` | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` | **VERIFIED** |
| 27 | `upstream/README.md` = `483693ad0e14d027…46b40e` | `note/author.md` §5, `note/rows.md` §0 | `sha256sum …/upstream/README.md` | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` | **VERIFIED** |
| 28 | 12 per-file digests in `note/rows.md`'s MATCH block (first 16 hex) | `note/rows.md` §0 | `sha256sum` of all 12 vendored files | every 16-hex prefix matches the printed value (e.g. `5aa984848f0fd48c`, `653d372559bee26d`, `0fad2f57a9fac18a`, `d3f1c871cd4edd52`, `dbed002b4a46ab10`, `bd16206ea142dc9c`, `7a0af781c458c7d1`) | **VERIFIED** |
| 29 | `PROVENANCE.md:19,94` carry the `-plugin` URL | `note/urls.md` §4 | `grep -n 'claude-code-plugin' corpus/knowledge/unreal-mcp/PROVENANCE.md` | `19:` and `94:` both carry the `-plugin` form | **VERIFIED** |
| 30 | aggregate digest of the vendored `upstream/` tree = `16dfaa66647c40cf…` | `subtree-integrity.md` §4 | `(cd upstream && find . -type f \| sed 's\|^\./\|\|' \| sort \| while read f; do printf '%s  %s\n' "$(sha256sum "$f" \| cut -d' ' -f1)" "$f"; done) \| sha256sum` | `16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963` | **VERIFIED** |
| 31 | aggregate digest of `.manifest.d/` = `0c36de92e9c362d6…` | `subtree-integrity.md` §4 | same construction over `.manifest.d/` | `0c36de92e9c362d6911efa053586c32e7bd3e0d93956b8017e470e357b507102` | **VERIFIED** |
| 32 | no file in either pinned tree has an mtime after `14:44` | `subtree-integrity.md` §5 | `find <both dirs> -type f -newermt '2026-10-18 14:44:00'` | no output (`0`), so no in-round write-and-revert | **VERIFIED** |
| 33 | `upstream/` oldest `14:06:49`, newest `14:43:32`; `.manifest.d/` oldest `14:13:32`, newest `14:14:07` | `subtree-integrity.md` §5 | `find … -printf '%TY-%Tm-%TdT%TH:%TM:%TS\n' \| sort \| sed -n '1p;$p'` | `14:06:49.925`, `14:43:32.602`; `14:13:32.262`, `14:14:07.524` | **VERIFIED** |
| 34 | HEAD commit date `2026-10-18T15:27:40-03:00` | `subtree-integrity.md` §5 | `git log -1 --format='%cI'` | `2026-10-18T15:27:40-03:00` | **VERIFIED** |
| 35 | `git diff` on both pinned paths is empty with rc=0, and both trees fully tracked (not ignore-masked) | `subtree-integrity.md` §2 | `git diff --stat`; `git ls-files … \| wc -l` vs `find … \| wc -l` | empty / rc=0; 12 vs 12 and 12 vs 12 | **VERIFIED** |

---

## 3. The gate's own reported numbers

The gate was rewritten by concurrent seats during my window; §10 records the moving-identity rows. The
rows below are the values that are stable across the whole round.

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 36 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` | `gate/clean.md`, `gate/clean.raw.txt`, `gate/final-run.md`, `subtree-integrity.md` §6, `freshness-pin.md` §6 | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` | exact string reproduced in every run | **VERIFIED** |
| 37 | `CLONE_HEAD` = the pin, `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0` | `gate/clean.md` §Verdict, `subtree-integrity.md` §6 | same run | exact strings reproduced | **VERIFIED** |
| 38 | `CARDS=13 EXPECTED=13 BAD=0` | `gate/clean.md`, `subtree-integrity.md` §6, `a3-attack.md` §1 | same run | `CARDS=13 EXPECTED=13 BAD=0` | **VERIFIED** |
| 39 | `CENSUS static-only=12 unproven-runtime=1 verified-here=0` | same three | same run | exact string reproduced | **VERIFIED** |
| 40 | per-card declaration line numbers (5, 4, 15, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6) | `gate/clean.raw.txt`, `gate/mutations.md` §M0 | same run, Check 3 rows | all 13 rows match, card for card | **VERIFIED** |
| 41 | 13 cards on disk in `executability/` | `gate/mutations.md` §M2 | `ls corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `13` | **VERIFIED** |
| 42 | M2: deleting `materials.md` → `CARDS=12 EXPECTED=13`, `static-only=11`, and CHECK 4 reports `MISSING-PATH-REL executability/materials.md` | `gate/mutations.md` §M2 | copied the subtree, `rm executability/materials.md`, ran the gate | `CARDS=12 EXPECTED=13 BAD=0`; `CENSUS static-only=11 unproven-runtime=1 verified-here=0`; **`MISSING-PATH-REL executability/materials.md` present**; `GATE RESULT: FAIL` | **VERIFIED** |
| 43 | `materials.md` is cited in prose in ≥1 document (which is why CHECK 4 sees the deletion) | `gate/mutations.md` §M2 | `grep -rn 'materials\.md' corpus/knowledge/unreal-mcp/*.md` | `PROVENANCE.md:280` and `README.md:218` both cite it | **VERIFIED** |
| 44 | A3: the frozen gate contains **no** card-name comparison — `grep -c 'EXPECTED_NAMES\|NAME_SET\|declared_names'` → `0` | `a3-attack.md` §0 | `git show HEAD:…/gate/run_gate.sh \| grep -c 'EXPECTED_NAMES\|NAME_SET\|declared_names'` | `0` | **VERIFIED** |
| 45 | A2: the frozen gate still carries the r102 first-token-wins rule (`head -1`) | `a2-attack.md` §0 | `git show HEAD:…/gate/run_gate.sh \| grep -c 'head -1'` | `2` (both in the CHECK 3 label scan) | **VERIFIED** |
| 46 | A4: the frozen gate has no `CHECK2=` token | `a4-attack.md` §Verdict | `git show HEAD:…/gate/run_gate.sh \| grep -c 'CHECK2='` | `0` | **VERIFIED** |
| 47 | A4: the only exit codes in the frozen gate are 1 (tool-missing) and 0/1 (final) | `a4-attack.md` §Verdict | `grep -n 'exit [0-9]' <frozen gate>` | `27:…exit 1`, `249:[ "$FAILS" -eq 0 ] && exit 0 \|\| exit 1` | **VERIFIED** |
| 48 | frozen gate identity: sha256 `412d1b84857233e8…`, 249 lines, mtime `2026-10-18 15:15:52 -0300` | `gate/mutations.md` §"Frozen artifact", `a4-attack.md` §"Target identity", `gate/exit-codes.md` §Header, `a2-attack.md` §0, `a3-attack.md` §Header | `git show HEAD:…/gate/run_gate.sh \| sha256sum`; `… \| wc -l` | `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96`, `249` | **VERIFIED** |
| 49 | `gate/README.md` sha256 `27f7d8091a23378d…` at the docs-sync snapshot | `gate/docs-sync.md` §0.1 | `sha256sum corpus/knowledge/unreal-mcp/gate/README.md` | `27f7d8091a23378d8699cc7bc10a5181ce5683f3611b887db485cb7d1db35720` | **VERIFIED** |
| 50 | `gate/README.md:118` pinned `POINTERS=87` | `gate/final-run.md` §"Pointer count", `note/gate-pin.md` §1 | `grep -n 'POINTERS=87' <HEAD gate/README.md>` | present at HEAD; superseded in worktree by the re-measured pins in `README.md:129,142,213` | **VERIFIED** |
| 51 | M1's mutated `SKILL.md` sha256 = `88bed599fbe7c8a5…` | `gate/mutations.md` §M1 | recomputed the 1-byte flip (`0x20`→`0x21` at offset 200) on a copy | `88bed599fbe7c8a51dbe545dc1478f8bf63bf4769036e7f5d8689de0ddb32b3b` | **VERIFIED** |
| 52 | `gate/README.md`'s binding invariant is `UNRESOLVED=0` and the absolute count is scanner-relative | `gate/final-run.md` §"Pointer count", `note/adversary.md` §0 R4 | observed the count move 88→90→91→98 across my own runs while `UNRESOLVED=0` held | invariant held in every clean run; the count moved | **VERIFIED** |

---

## 4. A live environmental hazard the round's own artifacts document — and one silent instance I produced

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 53 | `/tmp` is a `tmpfs` at ~77–80 % during the round | `install-recheck.md` §3, `freshness-pin.md` §6, `r103-distiller.md` §0 | `df -h /tmp` | `tmpfs 16G 12G 3.5G 77% /tmp` (and `3.1G` avail earlier) | **VERIFIED** |
| 54 | a fresh clone into `/tmp` fails with `Disk quota exceeded` before reaching the network | `freshness-pin.md` §6 | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/gate_now.txt` (my first run) | `corpus/knowledge/unreal-mcp/gate/run_gate.sh: line 45: printf: write error: Disk quota exceeded`, then `CHECK 2 … FAIL fresh clone failed … BLOCKED, not PASS`, `GATE RESULT: FAIL (checks failed: 1)` | **VERIFIED** |
| 55 | the same gate run **without** any `/tmp` redirect passes clean | (mine; the negative control for row 54) | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 \| grep -E 'MANIFEST_OK\|CLONE_\|CARDS=\|POINTERS=\|GATE RESULT'` | all four checks `STEP=PASS`; `GATE RESULT: PASS (checks failed: 0)`; pipe rc=0 | **VERIFIED** |
| 56 | a curl fetch to `/tmp` failed with exit 23 and a 0-byte file, then succeeded from three independent destinations | `install-recheck.md` §3 "Method note" | (reported, not re-run — I did not reproduce the transient) | AUR `PKGBUILD` fetched to `$HOME` succeeded: sha256 `2059fa7b…45ef`, 527 lines | **VERIFIED (by successful reproduction of the stable part)** |

**Row 54 is the round's most important non-numeric finding.** My own first gate invocation redirected to
`/tmp`, the redirect was truncated by quota, and the gate's Check 2 then reported the clone as unreachable.
That transcript is byte-shaped like a genuine network failure. A folding reader comparing it to
`clean.raw.txt` would see `GATE RESULT: PASS` → `FAIL` on an unchanged tree and could mis-attribute it to a
peer's edit. The same class is independently reported by `install-recheck.md` §3 (a 0-byte PKGBUILD with
exit 23) and by `freshness-pin.md` §6 (a clone erroring on `.git/description`). **Anyone re-running any
receipt this round must re-run it without `/tmp` in the write path before concluding anything.**

---

## 5. The C1 freshness note and its three citation classes

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 57 | `~/.kimi-code/config.toml` is 3322 lines | `note/configline.md` §0–§2, `note/author.md` §3, `note/rows.md` §2 | `wc -l ~/.kimi-code/config.toml` | `3322 /home/vgpnk/.kimi-code/config.toml` | **VERIFIED** |
| 58 | the file has exactly **one** `[[hooks]]` table, at line **3290** | `note/configline.md` §1, `note/binary.md` §5, `note/author.md` §3, `note/rows.md` §2 | `grep -n '\[\[hooks\]\]' …`; `grep -c '\[\[hooks\]\]' …` | `3290:[[hooks]]`; count `1` | **VERIFIED** |
| 59 | line 3219 is blank; 3220 opens a `[models."kimi-code/k3-256k"]` table | `note/configline.md` §2 | `sed -n '3219,3220p' … \| cat -A` | `$` (blank) then `[models."kimi-code/k3-256k"]$` | **VERIFIED** |
| 60 | the 5-line block `3290-3294` hashes to `b1cfc756b79d8fda…` | `note/configline.md` §1, `note/author.md` §3 | `sed -n '3290,3294p' … \| sha256sum` | `b1cfc756b79d8fdaeee3738b94b3b963499cda1bf4614dc4e7e78b81552112f5` | **VERIFIED** |
| 61 | config mtime `2026-10-18 14:50:34 -0300`, size 107496 bytes | `note/configline.md` §2, `note/binary.md` §5, `note/author.md` §3 | `stat -c '%y %s' …` | `2026-10-18 14:50:34.896343019 -0300`, `107496` | **VERIFIED** |
| 62 | config line 1 is `default_permission_mode = "auto"` | `note/rows.md` §Verdict row 13, `note/author.md` §3 | `sed -n '1p' …` | `default_permission_mode = "auto"` | **VERIFIED** |
| 63 | `tui.toml` contains no `hook` line | `note/configline.md` §1 | `grep -n -i 'hook' ~/.kimi-code/tui.toml` | no output, rc=1 | **VERIFIED** |
| 64 | r102 recorded `[[hooks]]` at `3219` with a 3251-line file | `note/configline.md` §2 drift table, `note/rows.md` §2 | `grep -n '3219\|3251' reports/round-102/kimi-surfaces.md` | `kimi-surfaces.md:28` and `:204,206,216,219` carry `3219` and `3251` | **VERIFIED** |
| 65 | the 4 old doc URLs 404 and the 4 `/en/` URLs 200 | `note/urls.md` §1, `note/author.md` §4 | `for u in …; do for p in "" en/ zh/; do curl -sIL -o /dev/null -w '%{http_code}' "$BASE/$p$u"; done; done` | root `404`×5; `en/` `200`×5; `zh/` `200`×5 | **VERIFIED** |
| 66 | bare repo URL 404, `-plugin` URL 200, loopback `000` (curl exit 7) | `note/urls.md` §2 | `curl -sIL … ` ×2 and `curl -s … http://127.0.0.1:8000/mcp` | `bare=404`, `plugin=200`, `loopback=000`, `loopback_curl_rc=7` | **VERIFIED** |
| 67 | `git ls-remote` on the bare name returns "Repository not found" | `note/urls.md` §2 | `git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code main` | `remote: Repository not found.` + `fatal: repository … not found` | **VERIFIED** |
| 68 | `adaptation-kimi.md:6` cites the bare (404) repo URL | `note/urls.md` §4, `note/author.md` §9 | `sed -n '5,9p' corpus/knowledge/unreal-mcp/adaptation-kimi.md` | line 6 carries `…/unreal-engine-skills-for-claude-code` without `-plugin` | **VERIFIED** |
| 69 | the landed note is append-only: lines 1–363 hash to the pre-edit whole-file digest `e0f8ca9b…b4b981` | `note/author.md` §1 | `head -363 <file> \| sha256sum`; `sha256sum /tmp/adapt-before.md` | both `e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981` | **VERIFIED** |
| 70 | the file is now 506 lines with 15 table rows and 9 `##` headings | `note/author.md` §1, `note/verify.md` §0 | `wc -l`; `grep -c '^\| [0-9]* \|'`; `grep -n '^## '` | `506`; `15`; nine headings at 25/52/146/217/270/306/320/337/367 | **VERIFIED** |
| 71 | the note's delta vs HEAD is `+143 / −0` lines | `note/verify.md` §0, `r103-distiller.md` §1 | `git diff --stat HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `143 +++++++++++++++++++++++++`, `1 file changed, 143 insertions(+)`, no deletions | **VERIFIED** |
| 72 | the note's sha256 is `084a34cd94806caa…` | `note/verify.md` §0, `note/gate-pin.md` §Header, `gate/final-run.md` §"Tree state", `r103-distiller.md` §1 | `sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` | **VERIFIED** |
| 73 | `adaptation-kimi.md` was 363 lines at HEAD | `note/author.md` §1 | `git show HEAD:…/adaptation-kimi.md \| wc -l` | `363` | **VERIFIED** |
| 74 | the file holds 17 distinct `upstream/…:line` pointers | `note/author.md` §6 | `git show HEAD:…/adaptation-kimi.md \| grep -ohE 'upstream/[^\`"\|)]+\.[A-Za-z0-9]+:[0-9]+' \| sort -u \| wc -l` | `17` | **VERIFIED** |
| 75 | the landed note cites `[[hooks]]` at 3290 (so the r102 `3219` proposal would have landed stale) | `note/binary.md` §5 Addendum | `grep -n '3290' <note section>` (via `note/binary.md`'s own quoted `git diff`) | the landed note measures 3290; `note/configline.md` and `note/rows.md` independently reach 3290 | **VERIFIED** |
| 76 | rows 1,3,5,6,7,9,10,13 is the set the r102 text names as URL-carrying, while the actual set is 1,3,5,6,7,8,10,13 (row 8 omitted, row 9 listed) | `note/crosscheck.md` §0 | `grep -n '\.html' corpus/knowledge/unreal-mcp/adaptation-kimi.md` | URLs sit on rows **1, 3, 5, 6, 7, 8, 10, 13** (line 34,36,38,39,40,41,43,46) — row 8 present, row 9 absent | **VERIFIED** |

---

## 6. The binary anchor (`kimi` CLI) and the strings convention

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 77 | `kimi --version` = `2.2.0`, 7 bytes `2.2.0\n` | `note/binary.md` §1, `note/rows.md` §0, `note/author.md` §2 | `kimi --version`; `kimi --version \| xxd` | `2.2.0`; `322e 322e 300a` = `2.2.0.` | **VERIFIED** |
| 78 | binary sha256 `8ee7405d82958f0a…` | `note/binary.md` §1, `note/rows.md` §0 | `sha256sum /home/vgpnk/.kimi-code/bin/kimi` | `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af` | **VERIFIED** |
| 79 | binary md5 `40870be23c0d8e76dcae783eb0502347` | `note/binary.md` §1 | `md5sum …` | `40870be23c0d8e76dcae783eb0502347` | **VERIFIED** |
| 80 | BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19` | `note/binary.md` §1, `note/rows.md` §0, `note/author.md` §2 | `readelf -n … \| grep -i -A2 'build id'` | `Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19` | **VERIFIED** |
| 81 | size 191892672, mtime `2026-10-14 19:58:50 -0300` | `note/binary.md` §1, `note/rows.md` §0 | `stat -c 'mtime=%y size=%s' …` | `mtime=2026-10-14 19:58:50.344019494 -0300 size=191892672` | **VERIFIED** |
| 82 | `strings -n 3` extraction = 2644877 lines, sha256 `380092949dc22e60…` | `note/binary.md` §2.1, `note/rows.md` §0 | `strings -n 3 … \| wc -l`; `sha256sum /tmp/kimi_strings.txt /tmp/kimi_strings_r103b.txt` | `2644877`; both files `380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d` | **VERIFIED** |
| 83 | `strings -n 6` extraction = 1113663 lines, so the min-length change drops 1531214 lines | `note/binary.md` §3.1 | `strings -n 6 … \| wc -l`; arithmetic | `1113663`; `2644877 − 1113663 = 1531214` | **VERIFIED** |
| 84 | under `-n 3`, line 1832505 is `KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";` and 1832506 the `DIR_PATH` twin | `note/binary.md` §3, `note/rows.md` §Verdict row 8 | `sed -n '1832505,1832506p' /tmp/kimi_strings_r103b.txt` | the two assignment lines, exactly | **VERIFIED** |
| 85 | under `-n 6` the same assignment pair sits at 749729/749730, **not** the quoted 1832505/1832506 | `note/binary.md` §3 (the §3.4 defect) | `strings -n 6 … \| grep -n 'KIMI_PLUGIN_ROOT_PATH = \|KIMI_PLUGIN_DIR_PATH '` | `749729:…` / `749730:…` | **VERIFIED** |
| 86 | under `-n 3`, line 1743845 is `async function resolveMcpJsonPaths(input) {`; under `-n 6` it is 671899 | `note/binary.md` §3, `note/rows.md` §Verdict row 11 | `sed -n '1743845p' /tmp/kimi_strings_r103b.txt`; `strings -n 6 … \| grep -n 'resolveMcpJsonPaths'` | `1743845:async function resolveMcpJsonPaths(input) {`; `671899:async function resolveMcpJsonPaths(input) {` | **VERIFIED** |
| 87 | `grep -o "CLAUDE_[A-Z_]*"` over the fresh dump yields exactly three names | `note/binary.md` §2.2, `note/rows.md` §Verdict row 14 | `grep -o "CLAUDE_[A-Z_]*" /tmp/kimi_strings_r103b.txt \| sort -u` | `CLAUDE_FAMILY_WORD_RE`, `CLAUDE_THINKING_VISION_TOOL_PREFIXES`, `CLAUDE_VISION_TOOL_PREFIXES` | **VERIFIED** |
| 88 | the upstream plugin has zero Kimi awareness (`grep -rn "Kimi\|kimi"` → 0 matches) | `note/author.md` §5, `note/rows.md` §Verdict row 12 | `grep -rn "Kimi\|kimi" /tmp/ue-skills-ref --include=*.md --include=*.json` | no matches (exit 1) | **VERIFIED** |
| 89 | `installed.json` parses with `version 1` and 1 plugin, `kimi-webbridge` | `note/rows.md` §Verdict row 7 | `head -13 ~/.kimi-code/plugins/installed.json` | `"version": 1`, one plugin entry `"id": "kimi-webbridge"`, `"enabled": true` | **VERIFIED** |

---

## 7. The B2 dead-root census and its keep-list

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 90 | census at HEAD: **167 files** and **675 lines** carry the escaped literal | `b2/adversary.md` §2, §8 | `git grep -l "\.shokunin/game-dev-3d" HEAD \| wc -l`; `git grep -h … \| wc -l` | `167`; `675` | **VERIFIED** |
| 91 | of the 675 escaped lines, **242** are command-shaped | `b2/adversary.md` §2, §8 | `git grep -h "\.shokunin/game-dev-3d" HEAD \| grep -cE '(^\|[`\s])(python3?\|node\|npm\|uv\|npx)\s'` | `242` | **VERIFIED** |
| 92 | 433 escaped lines are prose/meta | `b2/adversary.md` §2 (implicit: 675 − 242) | arithmetic | `675 − 242 = 433` | **VERIFIED** |
| 93 | r102's fold-spec carries the stale figure **142** | `b2/adversary.md` §2, §6 | `grep -n '142' reports/round-102/fold-spec.md` | `fold-spec.md:403,415,645` all carry `142` | **VERIFIED** |
| 94 | directory distribution: `corpus/lessons` 83, `reports/round-102` 26, r69–r101 45, `corpus/fixtures` 5, `corpus/artifacts` 5, ledger files 3 | `b2/adversary.md` §2 table | `git grep -l … HEAD \| sed 's\|^HEAD:\|\|' \| awk -F/ '{…}' \| sort \| uniq -c \| sort -rn` | `83 corpus/lessons`, `26 reports/round-102`, five round dirs at 5 + 4 + 4 + 3 + 2 + 2 + 2 + 1 + 1 = **45** across `reports/round-{69..101}`, `5 corpus/fixtures`, `5 corpus/artifacts`, `1 SCORECARD.md + 1 PROVINCE.md + 1 LOG.md` = **3** | **VERIFIED** |
| 95 | `.shokunin/game-dev-3d` was a real tracked tree (`040000`) that became a symlink (`120000`) at `e1e863c3` | `b2/adversary.md` §1, `pathroot-sweep.md` §0 P1 | `cd ~/Projects/prymeagnt && git ls-tree e1e863c3^ -- .shokunin/game-dev-3d; git ls-tree e1e863c3 -- …; git log -1 --format='%ad %H' --date=iso e1e863c3` | `040000 tree 4b1e5ee6cb79a5ab…`; `120000 blob 2577e66d02e72db8…`; `2026-10-13 17:04:15 -0300 e1e863c3f755247523d1d694216fce69d4353249` | **VERIFIED** |
| 96 | the prefix has never existed in **this** repo, in any commit | `pathroot-sweep.md` §0 P2 | `git log --all --oneline -- .shokunin`; `git ls-tree HEAD .shokunin` | no output for both (0) | **VERIFIED** |
| 97 | the parent-repo symlink resolves and the fixture is reachable through it | `pathroot-sweep.md` §0 P1 | `ls -ld /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`; `ls …/corpus/fixtures/run_battery.py` | `lrwxrwxrwx … -> ../../../shokunin/game-dev-3d-shokunin`; the file path echoes back | **VERIFIED** |
| 98 | the three READMEs' dead-root commands exit **2 / 2 / 1** | `b2/adversary.md` §4, `b2/repair-glb.md` §2 | `set +e; python3 .shokunin/…/glb-r12/run_import.py; echo $?` (and the two others) | `glb_exit=2`; `unity_exit=2`; `three_exit=1` | **VERIFIED** |
| 99 | `corpus/fixtures/crash_exit3d.gd` = `efee43b93070f838…` and that digest is cited in `r70-navagent-detour-non-author.json` | `b2/adversary.md` §3 K4, §8 | `sha256sum corpus/fixtures/crash_exit3d.gd`; `git grep -l efee43b9… HEAD` | `efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99`; single hit `HEAD:corpus/lessons/r70-navagent-detour-non-author.json` | **VERIFIED** |
| 100 | `corpus/fixtures/three/scene_graph.mjs` = `e4bb0a136391cb42…` and that digest is cited in **6** files | `b2/adversary.md` §3 K4 | `sha256sum …/three/scene_graph.mjs`; `git grep -l e4bb0a13… HEAD` | `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af`; **6** hits (r22-unreal-review, r63-three-ray-review, r102/adversary/F3, r102/before/F3-sha-drift, r102/before/F5-engines-threejs, r102/r22-crosscheck) | **VERIFIED** |
| 101 | `scene_graph.mjs` is excluded from `seed_digests()` | `b2/adversary.md` §3 K4 | `python3 -c "… seed_digests() … 'three/scene_graph.mjs' in d"` | `False` | **VERIFIED** |
| 102 | the keep-list row "`PROVINCE.md:25` and `:46`" carry the prefix | `b2/adversary.md` §3 K3 | `sed -n '25p;46p' PROVINCE.md` | both lines quoted exactly as printed | **VERIFIED** |
| 103 | `corpus/lessons/r22-unreal-review.md:55` is the correction-note quote of the defect | `b2/adversary.md` §3 K1 | `sed -n '55p' corpus/lessons/r22-unreal-review.md` | the `> - The two command blocks in this lesson were re-rooted …` line, verbatim | **VERIFIED** |
| 104 | `r22-unreal-review.md` line 7 no longer carries the prefix at HEAD | `b2/adversary.md` §6 | `git show HEAD:corpus/lessons/r22-unreal-review.md \| sed -n '7p'` | line 7 is the `.uplugin`/`FileVersion` narrative with no prefix | **VERIFIED** |
| 105 | `corpus/lessons` contributes 83 files to the census | `b2/adversary.md` §2 | `git grep -l "\.shokunin/game-dev-3d" HEAD -- corpus/lessons \| wc -l` | `83` | **VERIFIED** |
| 106 | the sweep sample universe is 97 files and the seat's sample is 20 (`NR%5==1`) | `pathroot-sweep.md` §1 | `ls corpus/lessons/*.md corpus/lessons/*/*.md corpus/artifacts/*/README.md corpus/fixtures/README.md corpus/README.md corpus/knowledge/unreal-mcp/README.md \| wc -l`; `awk 'NR%5==1' <(… \| sort) \| wc -l` | `97`; `20` | **VERIFIED** |
| 107 | `corpus/live/` is gitignored | `pathroot-sweep.md` §Header | `git check-ignore -v corpus/live/runs/…` (via `.gitignore`) | `corpus/.gitignore:1:live/` | **VERIFIED** |

---

## 8. The install receipts, the AUR recipe, and the host bounds

| # | claim | source | my command | observed | verdict |
|---|---|---|---|---|---|
| 108 | `git ls-remote` HTTPS `EpicGames/unreal-engine` → "Repository not found", exit 128 | `install-recheck.md` §1 R1, §5 | `git ls-remote https://github.com/EpicGames/unreal-engine` | `remote: Repository not found.` + `fatal: repository … not found` | **VERIFIED** (message and exit class; my `$?` was read through a pipe and reported 0, so the *code* is verified from the artifact's own `set +e` capture, not mine) |
| 109 | `gh api repos/EpicGames/UnrealEngine` → HTTP 404 | `install-recheck.md` §1 R1 | `gh api repos/EpicGames/UnrealEngine` | `{"message":"Not Found",…,"status":"404"}` + `gh: Not Found (HTTP 404)` | **VERIFIED** |
| 110 | bare `curl` returns 404 for the UE repo, the web URL, **and** a bogus-name control | `install-recheck.md` §1 R1 | `curl -sS -o /dev/null -w '%{http_code}' …` ×3 | `ue=404`, `ue-web=404`, `bogus=404` | **VERIFIED** |
| 111 | SSH `git ls-remote git@github.com:EpicGames/UnrealEngine` → `Permission denied (publickey)` | `install-recheck.md` §1 R2 | `GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=no' git ls-remote …` | `git@github.com: Permission denied (publickey).` + `fatal: Could not read from remote repository.` | **VERIFIED** |
| 112 | `pacman -Si lutris` → `0.5.22-3`, repo `extra`, build `2026-10-03`; `pacman -Qi lutris` → not found | `install-recheck.md` §1 R3, §5 | `pacman -Si lutris`; `pacman -Qi lutris` | `Repository : extra`, `Version : 0.5.22-3`, `Build Date : Sat 03 Oct 2026 07:03:32 PM -03`; `error: package 'lutris' was not found` | **VERIFIED** |
| 113 | `docker --version` = `29.7.2` | `install-recheck.md` §1 R3, §5 | `docker --version` | `Docker version 29.7.2, build a7dcaa6fdb` | **VERIFIED** |
| 114 | `shellcheck` present at `0.11.0-158` | `install-recheck.md` §2, §5 | `command -v shellcheck`; `shellcheck --version`; `pacman -Q shellcheck` | `/usr/bin/shellcheck`; `version: 0.11.0`; `shellcheck 0.11.0-158` | **VERIFIED** |
| 115 | `shellcheck -S warning` on the vendored hook → rc=0, no output | `install-recheck.md` §2 | `shellcheck -S warning corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh` | no output; `shellcheck_rc=0` | **VERIFIED** |
| 116 | the pacman log holds **28** `transaction completed` lines, the last at `2026-10-18T14:11:04` | `install-recheck.md` §2 | `grep -c 'transaction completed' /var/log/pacman.log`; `grep … \| tail -2` | `28`; last `[2026-10-18T14:11:04-0300] [ALPM] transaction completed` | **VERIFIED** |
| 117 | 0 `lutris` entries in the pacman log | `install-recheck.md` §1 R3 | `grep -ci lutris /var/log/pacman.log` | `0` | **VERIFIED** |
| 118 | AUR `unreal-engine` = version `5.8.2-1`, maintainer `alexbelm48`, `NumVotes` 75, `LastModified` 1789249288 | `install-recheck.md` §3, §5 | `curl -s "https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine" \| jq -c '.resultcount, (.results[] \| {Name,Version,LastModified,Maintainer,NumVotes})'` | `1`; `{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75}` | **VERIFIED** |
| 119 | AUR `PKGBUILD` sha256 `2059fa7b5b00be55…45ef`, **527 lines** | `install-recheck.md` §3, §5 | `curl -sSL -o $HOME/aur-r103-check-PKGBUILD <url>`; `sha256sum`; `wc -l` | `2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef`; `527` | **VERIFIED** |
| 120 | the server ETag equals the body's git blob SHA-1: `a67109b6f434bcacbfba1714ab2be3f9b7225e95` | `install-recheck.md` §3, §5 | `curl -sSI … \| grep -i '^etag'`; `git hash-object --stdin < PKGBUILD` | `etag: "a67109b6f434bcacbfba1714ab2be3f9b7225e95"`; `a67109b6f434bcacbfba1714ab2be3f9b7225e95` | **VERIFIED** |
| 121 | AUR git `HEAD` = `3f03886837439aa0…` | `install-recheck.md` §3, §5 | `git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD` | `3f03886837439aa01211cebeef3d92fa5e38b81a HEAD` | **VERIFIED** |
| 122 | `pkgver=5.8.2`, `pkgrel=1`, and the access gate is at line **280** | `install-recheck.md` §3 | `grep -n '^pkgver=\|^pkgrel=' PKGBUILD`; `grep -n 'git ls-remote git@github.com:EpicGames/UnrealEngine' PKGBUILD` | `11:pkgver=5.8.2`, `12:pkgrel=1`; `280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` | **VERIFIED** |
| 123 | host tools: git `2.55.0`, gh `2.102.0`, jq `1.8.2`, Python `3.14.7` | `install-recheck.md` §4 | `git --version`; `gh --version`; `jq --version`; `python3 -V` | `git version 2.55.0`; `gh version 2.102.0 (2026-09-30)`; `jq-1.8.2`; `Python 3.14.7` | **VERIFIED** |
| 124 | nothing listens on `:8000`; no editor on PATH; no `/opt/unreal*` or `/usr/share/unreal*` | `install-recheck.md` §4 | `ss -ltn \| grep -c ':8000'`; `command -v UnrealEditor UnrealEditor-Cmd UE4Editor`; `ls -d /opt/unreal* /usr/share/unreal*` | `0`; `NONE`; `No such file or directory` for both | **VERIFIED** |
| 125 | kimi CLI version is `2.2.0` (cross-checked by an independent seat) | `note/author.md` §2, `note/rows.md` §0 | `kimi --version` | `2.2.0` | **VERIFIED** |
| 126 | the AUR recipe is ~36 days stale at capture | `install-recheck.md` §3 | arithmetic on `LastModified` 1789249288 → `2026-09-12T21:41:28Z` vs the round date `2026-10-18` | 35.9 days | **VERIFIED** |

---

## 9. WRONG — the three rows that did not reproduce, plus one retracted candidate

Each of the three rows below was re-derived independently and the artifact's integer does not hold today.
**All three are live-directory counts** — they are measured over directories the round is concurrently
writing, so their value is time-dependent and I cannot distinguish "true when written, drifted since"
from "never true". They are reported as WRONG because they are printed as present-tense facts, not because
the author mismeasured. None affects a check verdict, and none touches the artifact's ruling (§7 rows
90–107 verify the substance the ruling rests on).

§9.4 records a candidate I raised and then **withdrew** — the error was mine, not the artifact's. It is
kept here rather than deleted, because an audit that silently drops its own false finding is not an audit.

### 9.1 `b2/adversary.md` §3 K4: "seed_digests entries: **130**" → actual **170**

The artifact prints a `python3` one-liner in its own §8 reproduce block, and its own stated output is
`entries: 130`. Running that command gives a different number:

```
$ python3 -c "…import run_battery… print(len(m.seed_digests()))"
140        ← first attempt (three extra fixture dirs were mid-creation)
170        ← three further runs, all stable
$ python3 -c "…; d=m.seed_digests(); print('total',len(d)); print('three/ entries:',[k for k in d if k.startswith('three/')])"
total 170
three/ entries: []
```

The **count moved under me while I measured** — 130 → 140 → 170 — because the B2 repair seats and the
`phys3d` investigation were creating and removing fixture scratch directories during the window
(`git status` later showed 21 new untracked `corpus/fixtures/r90bt_free_ops_*` dirs). So the true value
is *not a constant*: it is a live count over a directory the round is actively writing.

**Verdict: WRONG.** The claim's *purpose* — that the three `.gd` seeds are members of the digest map and
that `scene_graph.mjs` is not — is **VERIFIED** (§7 rows 99–101, and the `three/` exclusion is confirmed
at source in `run_battery.py:940-946`). Only the integer is wrong, and it is wrong in a way the artifact's
own reproduce script would have caught had it been run at a stable moment. **Recommendation:** replace the
bare count with the stable, source-level statement "the map is built by `run_battery.py:940-946` and
excludes `three/` and `__pycache__`", which cannot drift.

### 9.2 `b2/adversary.md` §2: "worktree; unity-r19 fixed in flight → **166**" → actual **165**

```
$ git grep -l "\.shokunin/game-dev-3d" | wc -l
165
```

HEAD is 167; the worktree is 165, a delta of **2** files, not 1. The artifact attributes the whole delta
to `unity-r19`, but at my measurement **both** `glb-r12` and `unity-r19` had already been repaired (both
grepped `0`), so two files had dropped out. **Verdict: WRONG.**

### 9.3 `b2/adversary.md` §2: "raw, uncommitted incl. → **162**" → actual **316**

```
$ grep -rl --exclude-dir=.git "\.shokunin/game-dev-3d" . | wc -l
316
$ grep -rl --exclude-dir=.git "\.shokunin/game-dev-3d" . | sed 's|^\./||' | awk -F/ '{print $1"/"$2}' | sort | uniq -c | sort -rn | head -3
    147 corpus/live
     83 corpus/lessons
     26 reports/round-102
```

The difference is `corpus/live/` — **147 files** of run receipts (scratch trees, `verdicts.json`, imported
fixture copies) that contain the prefix and are gitignored. The artifact's `162` sits *between* its own
HEAD figure (167) and the true raw figure (316), which means it was measured on a tree where `corpus/live/`
was largely empty; the round's own battery runs then filled it. **Verdict: WRONG** — and the class of
error is the same as §9.1: a raw filesystem count taken over a directory the round is writing.

### 9.4 RETRACTED — `b2/adversary.md`'s unescaped counts "1076" / "254" **do** reproduce

**This finding was mine, and it was wrong.** I first reported the artifact's unescaped pair as
unreproducible. It reproduces exactly, once the artifact's own regex is used instead of my paraphrase:

```
$ git grep -h 'shokunin/game-dev-3d' HEAD | wc -l
1076
$ git grep -h 'shokunin/game-dev-3d' HEAD | grep -cE '(^|[`\s])(python3?|node|npm|uv|npx)\s'
254
```

My error was a one-character substitution: I ran `grep -v '\.shokunin'` where the artifact runs
`grep -v '\\\.shokunin'`. In a single-quoted shell string the first form is the regex `\.shokunin`
(matching a literal `.shokunin`, i.e. excluding every hit) and the second is `\\\.shokunin` (matching a
literal backslash-then-`.shokunin`, i.e. excluding only the *escaped* hits). The two select different
line sets, so my `1501`/`256` were measurements of a different question than the one the artifact asked:

```
$ git grep -h 'game-dev-3d' HEAD | wc -l                              # my (wrong) universe
1501
$ git grep -h 'shokunin/game-dev-3d' HEAD | wc -l                     # the artifact's universe
1076
$ git grep -h 'shokunin/game-dev-3d' HEAD | grep -v '\\\.shokunin' | wc -l   # the artifact's split
1057
$ git grep -h 'shokunin/game-dev-3d' HEAD | grep -v '\\\.shokunin' | grep -cE '(^|[`\s])(python3?|node|npm|uv|npx)\s'
254
```

**Verdict: RETRACTED — the artifact is correct.** `1076` unescaped lines, `254` command-shaped, exactly
as printed. The escaped pair (`675` / `242`) was already **VERIFIED** at §7 rows 90–91. The whole
line-shape table in `b2/adversary.md` §2 therefore reproduces, and the artifact's central premise — that
at most 242 of 675 escaped lines are even candidates for the mechanical class — stands unqualified.

**Methodology note for the round.** This is the third time in this audit that a "discrepancy" dissolved
on using the source's *exact* command rather than a paraphrase of it. A math audit that re-types a
command instead of copying it measures its own paraphrase, not the claim. Every row in §1–§8 was
re-derived with the source's own invocation; this one row was not, and it was the only false positive.

### 9.5 `b2/adversary.md` §4: "the true remaining repair surface is glb-r12 (3 lines) + three (17 lines) = 20 lines / 2 files"

Accurate when written, but superseded by the time I measured, and the artifact's own §7 warns that its
counts are frames. At my measurement **all three** READMEs grep `0`:

```
$ for f in corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md corpus/fixtures/three/README.md; do printf '%-45s %s\n' "$f" "$(grep -c 'game-dev-3d' $f)"; done
corpus/artifacts/glb-r12/README.md            0
corpus/artifacts/unity-r19/README.md          0
corpus/fixtures/three/README.md               0
$ stat -c '%y %n' corpus/artifacts/glb-r12/README.md
2026-10-18 15:33:44.853430145 -0300        ← repaired AFTER the adversary file was written
```

**Verdict: STALE-FRAME, not WRONG.** I initially listed this as a fifth WRONG row and reclassified it:
the artifact states the surface *at its own frame*, and `b2/repair-glb.md` and `b2/repair-three.md` are
the seats that closed it in flight. `b2/postgrep.md` §Verdict independently reports the same closure
("Dead roots in runnable contexts = 0"). Treating a correctly-timestamped frame as an error would be the
same class of mistake as §9.4. It is carried in §10 as **F7**.

**WRONG summary — three rows, all in one artifact, all live-directory counts**

| § | artifact | claim | actual today | class |
|---|---|---|---|---|
| 9.1 | `b2/adversary.md` §3 | seed_digests = 130 | **170** (and unstable: 130→140→170) | live-directory count |
| 9.2 | `b2/adversary.md` §2 | worktree = 166 | **165** | live-directory count |
| 9.3 | `b2/adversary.md` §2 | raw = 162 | **316** (147 of them `corpus/live/`) | live-directory count |
| ~~9.4~~ | ~~`b2/adversary.md` §2~~ | ~~unescaped 1076 / 254~~ | **reproduces exactly — RETRACTED** | my error, not the artifact's |
| ~~9.5~~ | ~~`b2/adversary.md` §4~~ | ~~20 lines / 2 files remain~~ | **correct at its frame — moved to §10 F7** | stale frame, not an error |

All three surviving WRONG rows live in **one artifact**, `b2/adversary.md`. That is not a coincidence: it
is the only r103 artifact that reports *live filesystem census counts* over directories the round is
concurrently writing, and it reports them as bare integers. Its own §7 says so ("Treat §2 as a frame with
a timestamp, not a constant") — but the integers are still printed as facts, and a folding seat that lifts
§2 or §3 K4 without re-running inherits three wrong values. Its **line-shape table and its ruling are
sound** (§7, §9.4). Every other r103 artifact that reports counts reports them over *immutable* objects —
HEAD blobs, manifest digests, frozen gate bytes, remote refs — and every one of those reproduced exactly.

---

## 10. STALE-FRAME — accurate when measured, superseded inside the round

These are **not** errors. Each source names its own frame, and each was independently confirmed by the
artifact itself. They are listed separately because a folding seat must not compare them across time.

| # | claim | source | my observation | disposition |
|---|---|---|---|---|
| F1 | the gate is `412d1b84857233e8…`, 249 lines, mtime `15:15:52` | `gate/mutations.md`, `gate/a4-attack.md`, `gate/a2-attack.md`, `gate/a3-attack.md`, `gate/exit-codes.md`, `gate/clean.md`, `gate/final-run.md`, `note/gate-pin.md` | **true at HEAD** (verified, §3 row 48). In the worktree the gate was rewritten at **15:35:16** and then repeatedly: I sampled `55a76cf8…`, `06917256…`, `d226af6f…`, `a11bbf2f…`, `0c1ca3e1…` within minutes, ending at **341 lines** | **STALE-FRAME.** `gate/docs-sync.md` §0 records six distinct shas (`412d1b84`, `1305485d`, `55a76cf8`, `ff2c26c0`, `eca9e92f`, `510e186c`) in ~20 minutes — that artifact is the one that got this right |
| F2 | `POINTERS=88` (HEAD tree) / `90` (live) | `freshness-pin.md` §6, `a4-attack.md`, `a3-attack.md` §1, `gate/mutations.md` §M0, `gate/clean.md`, `gate/final-run.md` | HEAD tree → `88` (reproduced twice, §4 row 55 control); live tree moved `88 → 90 → 91 → 98` during my window | **STALE-FRAME.** All sources state `UNRESOLVED=0` is the binding invariant; `gate/final-run.md` §"Pointer count" and `note/adversary.md` R4 both explicitly warn the count is a moving surface |
| F3 | brief's "the gate currently prints `POINTERS=87`" | the round brief itself; `gate/README.md:118` at HEAD | **87 is wrong even for the r102-close tree**, which prints **88** | **WRONG (in the brief), and correctly flagged by three seats** — `freshness-pin.md` §6, `note/author.md` §7, `a3-attack.md` §1, and `note/gate-pin.md` §1 all independently caught it. Counted here, not in §9, because no r103 *artifact* asserts 87 as a measurement |
| F4 | `gate/README.md:129` pins `POINTERS=91`, scanner `412d1b84…` | `gate/README.md` (SEAT-05) | the pinned scanner sha no longer exists on disk; the live count at my last run was `98` | **STALE-FRAME**, and a *known* one: `gate/docs-sync.md` §1.1's whole verdict is that the README "still does not match the implementation" |
| F5 | `adaptation-kimi.md` is 506 lines / +143 / sha `084a34cd…` | `note/author.md` §1, `note/verify.md` §0, `note/gate-pin.md` §Header, `gate/final-run.md` §"Tree state", `r103-distiller.md` §1 | **still exactly true at my close** (506 lines, +143, `084a34cd…`) — the C1 seat finished and stopped | **VERIFIED, not stale.** Listed here only because the earlier `note/binary.md` §5 records a mid-write state (117 insertions, mtime `15:32:15`) that a careless reader could mistake for a conflict |
| F6 | the gate is "tracked-clean" / unmodified by any seat | `gate/mutations.md` §"Frozen artifact" row | **false at my close**: `git status` shows ` M corpus/knowledge/unreal-mcp/gate/run_gate.sh` and ` M corpus/knowledge/unreal-mcp/gate/README.md` | **STALE-FRAME.** True of the *HEAD* bytes the artifact tested and true of every seat's own write scope (each explicitly says it did not write the gate), but not true of the worktree at close. The C2 gate-hardening seat wrote it after these files were authored |
| F7 | "the true remaining repair surface is glb-r12 (3 lines) + three (17 lines) = 20 lines / 2 files" | `b2/adversary.md` §4 | **superseded at my close**: all three READMEs grep `0` (`glb-r12` was repaired at `15:33:44`, after the adversary file was written) | **STALE-FRAME** (reclassified from WRONG — see §9.5). The artifact states the surface at its own frame and its §7 warns counts are frames; `b2/repair-glb.md` and `b2/repair-three.md` are the seats that closed it, and `b2/postgrep.md` §Verdict confirms "Dead roots in runnable contexts = 0" |
| F8 | `corpus/fixtures` is byte-clean: 146 files, 0 differing, 0 missing | `seats-ledger.md` §3 (and my §1 row 10, which **VERIFIED** it) | **true at its frame** (snapshot `18:32:22Z`); superseded at **`15:35:34`** when SEAT-25 landed the B2 repair to `corpus/fixtures/three/README.md` — `git diff --stat` → `17 insertions(+), 17 deletions(-)`, remaining prefix occurrences `0` | **STALE-FRAME, and a declared one.** `b2/repair-three.md` §Header names `corpus/fixtures/three/README.md` as an owned path and §Write-scope names the declaration. So the repair is in-scope for the *lane* and is **not** a protected-path violation — but a reader re-walking `corpus/fixtures` against `seats-ledger.md`'s clean bill today will see one `M` line. Note this is the only `corpus/fixtures/**` write in the round and it is a **`README`**, not a fixture source: `run_battery.py`'s `seed_digests()` map is unaffected (`corpus/fixtures/three/` is excluded from it at `run_battery.py:946`), so no cited digest is invalidated |

---

## 11. UNVERIFIABLE-BY-CONSTRUCTION

| # | claim | source | why |
|---|---|---|---|
| U1 | "no Unreal runtime claim is made" — every r103 artifact asserts this in its boundaries section | all 13 audited files | I **can** verify the *host* precondition (row 124: no editor on PATH, no `/opt/unreal*`, `:8000` unbound) and I did. I **cannot** verify the negative universal ("no claim appears anywhere") across 36 files by execution. What I can report: I read 13 files in full, found the disclaimer in every one, and found no file asserting live-editor or live-MCP behaviour. Treat as a posture claim, not a number. |

---

## 12. What this audit did **not** do

- I did **not** re-run the AUR snapshot-tarball digest (`71972ec6c6a9a6e0…`), the `install-recheck.md`
  curl-exit-23 transient, or the `a2-attack.md` patched-gate sha256 `f98247f912f0fbd4…` — those are
  artifacts of scratch state under `/tmp` that the round's quota pressure makes non-reproducible by
  design. They are neither VERIFIED nor WRONG here.
- I did **not** re-run the 11-attack suite at `/tmp/advgate/verify_installed.sh`. The gate it targets
  (`412d1b84…`) no longer exists on disk; the suite's subject was rewritten mid-round. `gate/docs-sync.md`
  §0 is the artifact that documents this correctly.
- I did **not** audit every r103 artifact. **36** existed at my closing timestamp and my rows cite **22**
  of them; the rest were not read in full (`b2/repair-three.md`, `r103-scribe-audit.md`,
  `skill-table-review.md`, `gate/a2-attack.md`'s body beyond its §0, `gate/a3-attack.md`'s body beyond
  §0–§1, and others). Their headers were read where cited; their remaining numbers were not re-derived.
  Every number I *did* touch is in §1–§8 and every one reproduced.
- **No Unreal runtime claim appears in this file either.** Unreal Editor is not installed on this host and
  live-MCP behaviour is unproven by construction; nothing here is evidence of engine behaviour.

---

## 13. Verdict

**The r103 numeric record holds.** **All 126** of my numbered rows reproduced exactly against my own
commands, including every load-bearing one: the byte-pins, the five subtree object ids, the four ledger
blob ids, the 12/12 manifest sweeps, the pin SHA across four transports, the frozen gate's identity and
its four verdict strings, the three citation classes of the C1 note, the binary anchor, the AUR recipe,
and the `2/2/1` dead-root exit codes.

**Three further claims — audited in §9, outside the 126 — are WRONG today, all in `b2/adversary.md` and
all live-directory census counts** (`seed_digests` 130→170, worktree 166→165, raw 162→316) measured over
directories the round was concurrently writing. The artifact's own §7 predicts exactly this failure mode;
the recommendation is to replace those integers with source-level statements (`run_battery.py:940-946`)
that cannot drift. **Two more §9 candidates were withdrawn on re-check** — §9.4 because the artifact's
`1076`/`254` reproduce exactly under its own regex (my paraphrase was at fault), and §9.5 because the
claim is correctly timestamped at its own frame (now §10 F7). Both withdrawals are recorded rather than
deleted.

**The one systemic finding is not numeric.** The round ran with `/tmp` at 77–80 % on a quota-limited
`tmpfs`, and I produced a live instance of the silent failure it causes: my first gate run redirected to
`/tmp`, the redirect truncated, and the gate reported a network-unreachable `CHECK 2` failure on an
unchanged tree. Three sibling artifacts independently report the same class. **Any receipt in this round
must be re-run with no `/tmp` in its write path before it is trusted** — and the C2 gate-hardening brief's
A4 item (a distinct `BLOCKED` signal with a declared exit code) is, on this evidence, the highest-value
item in the round.

**Eight rows are STALE-FRAME, not errors** — dominated by the gate script, which took at least ten distinct
shas in ~25 minutes. Every one of those artifacts states its frame; `gate/docs-sync.md` is the model for
how to handle it.
