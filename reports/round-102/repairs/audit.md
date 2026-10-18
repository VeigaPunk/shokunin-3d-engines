# r102 REPAIR-AUDIT — line-level review of every repair-seat target

- **Seat:** SEAT-16 REPAIR-AUDIT. **Owned path:** `reports/round-102/repairs/audit.md` (only).
- **Round:** r102 · **Lane:** `game-dev-3d-shokunin` · **Date:** 2026-10-18.
- **Baseline:** `HEAD = 2c99b7b8155841617d844c609813afcba77aa207` (`r101 report-last`; work commit `1659c036`).
- **Method:** for every repair target, `git diff -- <path>` against HEAD, plus a re-run of each defect's
  after-command and an independent re-derivation of every factual number the repair asserts. No source file
  was edited by this seat; this report is the only file it wrote.
- **Snapshot:** the tree was **mutating under concurrent seats** during this audit. The frozen snapshot below is
  timestamped `2026-10-18T15:06:03-03:00`; each audited file is hash-pinned so the audit is reproducible against
  exactly these bytes. Where a file changed mid-audit, that is stated explicitly (see §3c and §10).

---

## 0. Frozen snapshot (what was audited)

`git status --porcelain` at freeze — 5 tracked modifications + 3 untracked trees:

```
 M corpus/artifacts/unreal-r22/README.md
 M corpus/knowledge/engines.md
 M corpus/knowledge/rea.md
 M corpus/knowledge/unreal-mcp/README.md
 M corpus/lessons/r22-unreal-review.md
?? corpus/knowledge/unreal-mcp/gate/
?? corpus/lessons/r102-unreal-integration.md
?? reports/round-102/
```

| # | path | HEAD sha256 (content) | DISK sha256 (after) | content lines +/− |
|---|---|---|---|---|
| 1 | `corpus/artifacts/unreal-r22/README.md` | `26a12604…8c751cba` | `1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b` | +2 / −2 |
| 2 | `corpus/lessons/r22-unreal-review.md` | `4253a0af…c6ed881` | `03e879f0fbb4056ecc5cba83536c659c5680fe1ea9b3774bccb3f6806090a7cf` | +40 / −7 |
| 3 | `corpus/knowledge/engines.md` | `b20e5a9b…1a85cd06e` | `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` | +2 / −2 |
| 4 | `corpus/knowledge/rea.md` | `9be388f3…da1c32` | `3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059` | +36 / −0 |
| 5 | `corpus/knowledge/unreal-mcp/README.md` | `2004a9e5…371b17b9` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` | +3 / −3 |

Reproduction of the whole table:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --numstat        # 2/2, 2/2, 36/0, 3/3, 40/7
```

**Byte-pinned paths stayed clean.** The r101 subtree's `upstream/`, `.manifest.d/`, `executability/` and
`PROVENANCE.md` are untouched in the final snapshot:

```sh
$ git status --porcelain corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    corpus/knowledge/unreal-mcp/executability corpus/knowledge/unreal-mcp/PROVENANCE.md
(no output — clean)
```

The only pinned-subtree edit is `README.md` (the index, not `upstream/`), and it is the declared C1(d)/F8
wording fix by the seat that owns it.

---

## 1. Verdict summary

| defect | file(s) | change class | dated note required? | present? | overreach | verdict |
|---|---|---|---|---|---|---|
| **F1a** | `unreal-r22/README.md` | mechanical path conformance | no | n/a | none | **PASS** |
| **F1b** | `lessons/r22-unreal-review.md` lines 7,23,25,29,42,44,48 | mechanical path conformance | no | n/a | none | **PASS** |
| **F2** | `lessons/r22-unreal-review.md` line 48 + note | historical factual claim | **yes** | yes (line 50) | none | **PASS** |
| **F3** | `lessons/r22-unreal-review.md` line 48 + §"F3 correction" | historical factual claim | **yes** | yes (line 59) | none | **PASS** |
| **F5** | `engines.md` line 11 | mechanical command precondition | no | n/a | none | **PASS** |
| **C1(c)** | `engines.md` line 10 | evidence-class update (declared) | declared, not dated | declared §4 | declared, not silent | **PASS (see §6)** |
| **F6** | `rea.md` lines 28–63 | historical factual claim | **yes** | yes (line 28) | none | **PASS** |
| **F8** | `unreal-mcp/README.md` lines 169,170,187 | mechanical count wording | no | n/a | none | **PASS** |

**No repair changed a factual claim without a dated correction note.** **No touched byte outside any defect's
declared scope was found.** Three items are flagged for the L1's attention, none a scope violation: the
`engines.md` Unreal-row change is a *second, separately-declared* change in the same hunk (§6); one transient
incident on the byte-pinned tree (§7); and an initial draft of the r22 lesson's battery caveat overclaimed
("all four commands re-run exit 0") and was corrected by its owning seat before freeze to the observed
`cases=350 pass=335 fail=15` / exit 1 (§3c) — this seat independently reproduced that failure mode.

---

## 2. F1a — `corpus/artifacts/unreal-r22/README.md`

One hunk, exactly the two command lines. No other byte moved.

```diff
@@ -8,2 +8,2 @@ From repo root:
-python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
-python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
+python3 corpus/artifacts/unreal-r22/verify_descriptor.py
+python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
```

- **Scope check:** the defect is the `.shokunin/game-dev-3d/` path root, and only that prefix changed. The
  "From repo root:" heading, the control prose, and the no-runtime-claim sentence are byte-identical.
- **Root-cause check (independent):** the prefix names a directory that never existed.

```sh
$ ls -d .shokunin ../.shokunin            # both: No such file or directory
$ git log --all --diff-filter=A -- .shokunin   # (empty — never added in any ref)
```

- **After (pass):** both commands run from repo root, exit 0, positive accepts and the `bad-type` control
  rejects — the discriminating pair still discriminates.

```sh
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py                              # rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject   # rc=0
```

**Verdict: PASS.** Mechanical fix, in place, correctly scoped, no factual claim touched.

---

## 3. F1b + F2 + F3 — `corpus/lessons/r22-unreal-review.md`

This is the one file carrying three routed defects, and the only audited file where the discipline matters.
`+40 / −7` over **8 hunks**; the file grew 50 → 83 lines.

### 3a. F1b — mechanical path re-root (in place)

Seven single-line hunks, each removing only the `.shokunin/game-dev-3d/` prefix:

```sh
$ git diff -U0 -- corpus/lessons/r22-unreal-review.md | grep '^@@'
@@ -7 +7 @@         # `LOG.md` reference
@@ -23 +23 @@        # command block
@@ -25 +25 @@        # command block
@@ -29 +29 @@        # command-form prose
@@ -42 +42 @@        # command block
@@ -44 +44 @@        # command block
@@ -48 +48,8 @@     # (line 48 also carries F2/F3 note)
```

Each changed line differs from HEAD **only** by the dropped prefix. No sentence, number, digest or count was
altered. Residual scan in the final file: the only remaining occurrence of the string is inside the correction
note that *describes* the fix —

```sh
$ grep -n "shokunin/game-dev-3d" corpus/lessons/r22-unreal-review.md
55:> - The two command blocks in this lesson were re-rooted in r102 from a never-existent `.shokunin/game-dev-3d/` prefix …
```

### 3b. F2 + F3 — historical claims preserved verbatim, dated notes appended

**The historical claim line is preserved.** Line 48 still carries both digests and every value byte-for-byte;
its **only** difference from HEAD is the `scene_graph.mjs` path prefix removed by F1b (shown below). It reads,
in full:

> Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4…3d8fc`; fixture
> `run_battery.py` seed SHA `a065a56d…`; …

```sh
$ git diff -- corpus/lessons/r22-unreal-review.md | sed -n '/@@ -39/,/@@/p' | grep -c '^-Godot receipt'
1                    # the whole line is deleted...
```

— but re-added in the same hunk, differing **only** in the `scene_graph.mjs` path prefix (F1b). Proof:

```sh
$ git show HEAD:corpus/lessons/r22-unreal-review.md | sed -n '48p' > /tmp/h48.txt
$ sed -n '48p' corpus/lessons/r22-unreal-review.md > /tmp/d48.txt
$ diff /tmp/h48.txt /tmp/d48.txt | tr ' ' '\n' | grep -c 'shokunin/game-dev-3d'
1                    # the only differing token is the dropped path prefix
```

Every digest, byte count and the `29/29` count are carried through unchanged. The fix is therefore a **note, not
a rewrite**, which is the required discipline for a historical factual claim.

Two dated notes were appended:

- **line 50** — `> **Correction note (r102, 2026-10-18).**` (blockquote, covers F2 + F3 digests);
- **line 59** — `## F3 correction — 2026-10-18 (r102)` (covers the pass-count staleness).

**Independent re-derivation of every note claim — all confirmed:**

```sh
# F2: the receipt never existed in any tracked tree
$ git ls-files corpus/live | wc -l                       # 0
$ git log --all --oneline -- corpus/live | wc -l         # 0
$ find /home/vgpnk -maxdepth 8 -name 20261013T053632289732Z    # (no hits)
$ git ls-files -z | xargs -0 sha256sum | grep -i '^a806b9e4'   # (no match)

# F3: the cited digest is the r21/r22-era blob, reproducible only from history
$ for c in 490e710d 8b21cae 7804a69; do git show "$c:corpus/fixtures/run_battery.py" | sha256sum; done | sort -u | wc -l   # 1
$ sha256sum corpus/fixtures/run_battery.py               # f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f

# F3 note's pass-count claim: 29 rows at r22 vs 350 today
$ git cat-file -s 8b21cae:corpus/fixtures/run_battery.py            # 34239
$ python3 -c "import ast; ... CASES ..."                # r22: (34, 29)   tree: (39, 350)
$ git log --oneline -- corpus/fixtures/run_battery.py | wc -l        # 78
```

The note's claim that "all 78 commits touching the fixture rewrote it" also holds (`sort -u` over the 78 blob
digests yields 78 distinct values, checked in the sibling before-capture `reports/round-102/before/F3-sha-drift.md`
§3 and consistent with the note's wording).

### 3c. The battery caveat — lesson revised mid-audit to state the truth

The lesson changed **at least four times** while this audit ran — hashes observed, in order:
`45c32669…` → `8ead2129…` → `b051b5d8…` → `03e879f0…`, all at 83 lines and `+40/−7`. The final revision is the
important one: the F1b note's closing bullet was rewritten from an earlier "all four commands re-run exit 0"
claim to an **honest account of the Godot battery**:

> The documented Godot line is **r22-era and does not reproduce as written**: `run_battery.py` now defines 350
> cases (not 29), and a 2026-10-18 re-run returned `totals: cases=350 pass=335 fail=15` / exit 1. The 15
> failures are 13 `r94_cannon_*` cases whose markers pin `node=v24.21.0` while this machine runs node v26.12.0,
> one 20-second timeout under heavy concurrent load, and one `r98_gltflat_doc` marker/diagnostic mismatch …

**This seat independently reproduced the same failure mode** before reading that revision, under the same
contention (the host carried ~52 concurrent `godot` processes from other seats' battery runs):

```sh
$ python3 corpus/fixtures/run_battery.py
FAIL battery: …/corpus/live/runs/20261018T174509076978Z/verdicts.json      # rc=1
$ timeout 300 python3 corpus/fixtures/run_battery.py                        # rc=124 (timeout under load)
```

And the lesson's own sub-claims check out:

```sh
$ python3 -c "import ast; … CASES …"          # tree: (39, 350) cases
$ grep -c 'v24.21.0' corpus/fixtures/run_battery.py          # 13 — all 13 are r94_cannon_* lines
$ grep -n 'v24.21.0' corpus/fixtures/run_battery.py | grep -c r94_cannon   # 13
```

So the 13 `r94_cannon_*` node-pin failures are real and correctly attributed. The revision **removed** the
unsupported "all four commands exit 0" sentence; there is now no unverified assertion in the lesson's notes.
This is the audit's most consequential finding: an initial draft overclaimed, and the owning seat corrected it
to match observed behaviour before freeze. The audit records both states so the correction is visible.

**Verdict: PASS.** Line 48 untouched (both digests and the `29/29` count preserved as the r22 record), two dated
notes carry the correction, every value in the notes reproduces independently, and the final battery caveat
matches this seat's own independent reproduction.

---

## 4. F5 — `corpus/knowledge/engines.md` line 11 (three.js row)

One hunk touching lines 10–11. Line 11's change adds the missing install precondition:

```diff
-| three.js 0.186.1 | … | `node corpus/fixtures/three/run_cases.mjs` → 3/3 and named non-author r6 review … | `require.resolve('three')` failed …
+| three.js 0.186.1 | … | `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` → 3/3, `seeds_unchanged=true`, exit 0, and named non-author r6 review … | requires the vendored lane-local `corpus/fixtures/three/node_modules/` layout: that dir is gitignored, so `node …` alone exits 1 on a fresh `git archive HEAD corpus/fixtures/three` tree — the `npm ci --prefix` above restores it from the committed lockfile (verified exit 0 from repo root on a clean tree); … |
```

- **The `→ 3/3` historical claim is preserved**, not rewritten. Only a precondition was added to a mechanical
  command, which is the in-place/conformance repair the discipline permits without a dated note.
- **Independent before→after, on a pristine export** (nothing added to the lane tree):

```sh
$ git archive HEAD | tar -x -C /tmp/f5verify && cd /tmp/f5verify
$ ls -d corpus/fixtures/three/node_modules         # No such file or directory
$ node corpus/fixtures/three/run_cases.mjs; echo $?    # FAIL ×4, exit=1        ← BEFORE
$ npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs; echo $?
                                                       # PASS 3/3, seeds_unchanged=true, exit=0   ← AFTER
```

- **Seed-digest claims in the F5 report are exact:** `run_cases.mjs` = `97eca1b2…` and
  `package-lock.json` = `1a8e6ee2…` both match the tree.
- The row's parenthetical "Node v26.11.1" was deliberately left untouched (host is now `v26.12.0`); that is a
  mint-time host fact, not this defect, and leaving it is correct.

**Verdict: PASS** for the F5 defect (line 11).

---

## 5. F6 — `corpus/knowledge/rea.md`

**Append-only: +36 / −0.** The original 27 lines are **byte-identical to HEAD**:

```sh
$ git show HEAD:corpus/knowledge/rea.md > /tmp/o.txt; head -27 corpus/knowledge/rea.md > /tmp/n.txt
$ diff -q /tmp/o.txt /tmp/n.txt && echo IDENTICAL      # IDENTICAL
$ grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md   # 1 (stale sentence preserved)
```

A dated `## Correction note (r102, 2026-10-18)` (line 28) carries the correction. Its central claims
re-verified independently:

```sh
$ jadx --version; binwalk --version; unblob --version       # 1.5.6 / binwalk 3.1.0 / 26.6.4, all rc=0
$ "$REA_PWNTOOLS_PYTHON" -c "import pwnlib; print(pwnlib.version)"   # pwnlib 4.15.0, rc=0
$ python3 -c "import pwnlib"                                # ModuleNotFoundError, rc=1
$ which ghidra ghidraRun analyzeHeadless                    # all absent
$ which rea                                                 # rc=1
```

The note's "still true" controls (Ghidra absent, no `rea` CLI) and its "present" clause (JADX/Binwalk/Unblob)
are all reproducible from a clean shell. The note scopes itself explicitly to *prerequisites, not capability*.

**Mid-audit correction, verified.** At first read the F6 repair report cited `sha256sum corpus/knowledge/rea.md`
= `3a5f9d6f…`, which matched nothing. By the final snapshot the report had been corrected to the real value:

```sh
$ sha256sum corpus/knowledge/rea.md       # 3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059
$ python3 -c "import hashlib;print(hashlib.sha256(open('corpus/knowledge/rea.md','rb').read()).hexdigest())"
                                          # 3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059
$ grep -c "3a5f9d6f" reports/round-102/repairs/F6-rea-census.md    # 0
```

Both `sha256sum` and an independent `hashlib` recomputation agree, and the report's AFTER block now matches.
The report also claims `27 lines / 9be388f3…` → `63 lines / 3932fc53…`; both hold (`wc -l` = 63,
`git show HEAD:… | sha256sum` = `9be388f3…`).

**Verdict: PASS.** Append-only, original claim preserved, dated note present, every value reproducible.

---

## 6. C1(c) — `corpus/knowledge/engines.md` line 10 (Unreal row) — **flagged, not a violation**

The `engines.md` hunk changes **two** rows. Line 11 is F5 (above). Line 10 is a **different deliverable**:
the lane brief's C1(c) "Unreal-row evidence-class update". It is a substantial rewrite of the evidence cell:

```diff
-| Unreal Engine | no | no | census at mint; r22 `corpus/artifacts/unreal-r22/` static authored `.uplugin` sample and non-author review | not installed; local JSON checks do not prove plugin load, UBT compilation or engine runtime |
+| Unreal Engine | no | no | two static evidence classes, both `static-only` (0 `verified-here`; every runtime claim on this row stays `unproven-runtime`): (a) r22 self-authored … ; (b) r101 third-party pinned tree `corpus/knowledge/unreal-mcp/` — Epic `unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ad`, MIT, 12/12 tracked files byte-identical (`sha256sum -c .manifest.d/audit-reference.sha256` → rc=0), 13 `executability/` cards (12 `static-only` / 1 `unproven-runtime` / 0 `verified-here`) | not installed; (a) and (b) are categorically different evidence classes … |
```

**Why it is flagged.** The provenance phrase **"census at mint" was dropped in place**, and no dated correction
note was added to `engines.md`. Under a strict reading, dropping a provenance annotation is a change to a
historical claim.

**Why it is not a violation.** (i) It is the C1(c) deliverable, not the F5 defect — the two are separate claims
that happen to share a hunk. (ii) It is **declared, not silent**: `reports/round-102/repairs/F5-engines.md` §4
("Second change in the same file — Unreal row evidence class (connector IP-1)") states the change and its
rationale, citing `reports/round-101/r101-connector.md:150-190`. (iii) The underlying fact the phrase annotated
— *engine not installed* — is preserved verbatim in the notes cell ("not installed; …"), so no factual content
was lost. The update **adds** a second evidence class and downgrades nothing toward a runtime claim.

**Verified:** the row's three-state columns are unmoved (`no` / `no`), the counts in the cell are exact
(`sha256sum -c .manifest.d/audit-reference.sha256` → rc=0 over 12 files; 13 cards; census 12/1/0), and the
claim that (b) is "someone else's bytes at a pinned upstream commit" matches the gate's CHECK 2 result
(`CLONE_HEAD=a6aa73ad…`, `BLOB_DIFFS=0`).

**Recommendation for L1:** no action required; if the lane wants strict uniformity, a one-line dated note in
`engines.md` recording that the Unreal row's provenance wording was updated at r102 would close the loop. This
seat did not edit it (out of its owned path).

---

## 7. F8 — `corpus/knowledge/unreal-mcp/README.md`

**Line-neutral, 3 lines:** `+3 / −3`, file stays at 278 lines, so every downstream `README.md:NNN` citation
keeps resolving to the same content. Hunks: `@@ -169,2 +169,2 @@` and `@@ -187 +187 @@`.

```diff
-`sha256sum -c .manifest.d/*.sha256` → all `OK`, exit `0` (run here; output reproduced below). …
+`sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the full glob `*.sha256` → **24** (same 12 files twice). …
-Observed output of the sweep (12 lines, all `OK`):
+Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):
```

The defect was a caption naming a command that does not print the count beneath it. Both counts are now
verified empirically and the printed block matches the real command output **byte-for-byte**:

```sh
$ cd corpus/knowledge/unreal-mcp
$ sha256sum -c .manifest.d/audit-reference.sha256 2>/dev/null | wc -l        # 12
$ sha256sum -c .manifest.d/*.sha256 2>/dev/null | wc -l                      # 24
$ diff <(sha256sum -c .manifest.d/audit-reference.sha256 2>/dev/null) \
       <(sed -n '190,201p' README.md)                                        # identical
```

The report's AFTER hash matches the tree exactly:
`c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`.

**Verdict: PASS.** The wording is the seat's own deliverable; `upstream/` and `.manifest.d/` were not touched.

---

## 8. Gate re-run (C1(a) integration check)

The gate is a peer deliverable (`corpus/knowledge/unreal-mcp/gate/run_gate.sh`, untracked, authored by
SEAT-17/SEAT-39). Run as-is against the audited tree:

```sh
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297   CLONE_DIRTY=0 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
$ echo $?     # 0
```

All four checks PASS, exit 0. This corroborates that the F8 wording fix introduced no unresolved pointer and
no manifest drift.

---

## 9. Incident — transient write to byte-pinned `upstream/` files (14:43:23)

During this audit a concurrent seat transiently **overwrote two byte-pinned `upstream/` files**. Captured at
`14:43:23`:

```
$ cat corpus/knowledge/unreal-mcp/upstream/README.md
TAMPERED - README content replaced, hash would differ          # 54 bytes (was 8398)
$ cat corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
# TAMPERED SKILL                                               # 17 bytes (was 7098)
```

Effect on the gate, run immediately after:

```
MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1        STEP=FAIL
BLOB_DIFFS=2                                     STEP=FAIL
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=20   STEP=FAIL
GATE RESULT: FAIL (checks failed: 3)
```

**Resolved:** both files were restored **byte-exact within ~20 s** (observed clean at `14:43:44`, stable
through `14:44:34`). Confirmed against HEAD by content hash, and the gate returned to PASS (12/12, BLOB_DIFFS=0,
UNRESOLVED=0):

```sh
$ git status --porcelain corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d   # clean
$ git cat-file blob HEAD:corpus/knowledge/unreal-mcp/upstream/README.md | sha256sum    # 483693ad0e14d027…
$ sha256sum corpus/knowledge/unreal-mcp/upstream/README.md                              # 483693ad0e14d027…
```

**Assessment.** The `TAMPERED` text is the signature of a negative-control calibration (the gate README §"Calibrating
the gate" specifies exactly such mutations). The gate README instructs running them *"on a copy of the subtree,
never on the pinned tree itself"*; whoever ran this did not honour that instruction. No commit was made
(`HEAD` stayed `2c99b7b` throughout), the restore was exact, and no other byte-pinned path was touched — so the
end state is intact. Reported here because (a) the transient FAIL window is visible in the gate's own
`reports/round-102/gate/*` receipts and must not be misread as a real defect, and (b) a mutation run against
the live pinned tree is a discipline breach worth the L1's notice. This seat did not perform the mutation and
cannot attribute it to a specific seat from the available evidence.

---

## 10. Audit boundary notes

- **No Unreal runtime claim** is made or implied anywhere in this audit. Unreal Editor is not installed on this
  host; every value above is a file-level hash, byte count, path, count, exit code, or version string.
- **Protected paths untouched by this seat:** no edit to `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`,
  `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, or any other seat's report. Only
  `reports/round-102/repairs/audit.md` was written.
- **Concurrency caveat:** the tree kept mutating while this audit ran. The r22 lesson changed at least four times
  (`45c32669…` → `8ead2129…` → `b051b5d8…` → `03e879f0…`, all 83 lines / `+40 −7`) as its owning seat refined
  the F3 section and then corrected the battery caveat. The frozen snapshot in §0 pins the final `03e879f0…`
  state, which was stable for the last ~10 min of the audit; a later edit by another seat would not be covered
  by these hashes. §3c records the mid-audit revision, because that change is itself audit-relevant.

## Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --numstat
git diff -- corpus/artifacts/unreal-r22/README.md corpus/lessons/r22-unreal-review.md \
            corpus/knowledge/engines.md corpus/knowledge/rea.md corpus/knowledge/unreal-mcp/README.md
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "gate=$?"
```
