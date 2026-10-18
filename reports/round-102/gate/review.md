# r102 · SEAT-22 GATE-REVIEW — independent review of `corpus/knowledge/unreal-mcp/gate/`

Round r102 · lane `game-dev-3d-shokunin` · written 2026-10-18.
Seat scope: **review only.** I read `gate/README.md` + `gate/run_gate.sh` at my runtime,
re-ran the gate, re-derived its four pinned expected values from the r101 subtree independently,
ran the documented negative controls, and flag any expected value that drifts from r101's
recorded numbers. No file outside this report was written by this seat.

Artifacts under review (read at `2026-10-18T14:43Z`, HEAD `2c99b7b`):

- `corpus/knowledge/unreal-mcp/gate/run_gate.sh` — 10233 B, mode `755`
- `corpus/knowledge/unreal-mcp/gate/README.md` — 10471 B (grew 8776→10471 B mid-review; see F3)

Labels: **[O]** observed here with the command shown, **[I]** inference.

---

## 1. Verdict

**The gate is green, calibrated, and its four pinned expected values match r101's recorded
reality. No pinned value drifts from r101's numbers.** Three wording/robustness observations are
flagged below (F1–F3); none changes a pass/fail outcome and none is a drift.

| pinned quantity | gate pins | my independent re-measurement | r101 recorded | drift? |
|---|---|---|---|---|
| manifest `OK` lines | `12` | `12` **[O]** | `12` (`r101-report.md:121`) | no |
| tracked upstream files | `12` | `12` **[O]** | `12` (`r101-report.md:119`) | no |
| verdict cards | `13` | `13` **[O]** | `13` (`r101-report.md:139`) | no |
| label census | `12 / 1 / 0` | `12 / 1 / 0` **[O]** | `12 / 1 / 0` (`r101-report.md:44,141–143`) | no |
| pointers (subtree) | `40`, `UNRESOLVED=0` | `40`, `UNRESOLVED=0` **[O]** | `40` (`r101-report.md:146,188`) | no |

**Scope note on the "78".** The round context pairs this gate with a "78-pointer subtree sweep".
The gate pins **`POINTERS=40`**, and 40 is exactly r101's *subtree-only* number
(`r101-report.md:146,188`). The **78 is r101's whole-round** figure — the subtree plus the
round's report files — recorded separately at `r101-report.md:147,170`. The gate deliberately
scopes to the subtree, so 40 is the correct pin for it; the 78 is **not** a subtree number and
the gate neither reproduces nor claims it. Decomposition, reproduced here **[O]**:
subtree `40` + `reports/round-101/probes/security-surface.md` `36` +
`reports/round-101/probes/r22-relation.md` `2` = `78`. This is a **scope distinction, not a
drift** — but a reader who expects the gate to print 78 will be misled, so it is called out.

---

## 2. The gate runs green, from anywhere

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
```

**Observed [O]:**

```
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
exit=0
```

**cwd-independence verified [O].** Run from `/tmp`, the gate resolved the subtree from its own
location and printed `SUBTREE=/home/vgpnk/.../corpus/knowledge/unreal-mcp` /
`GATE RESULT: PASS (checks failed: 0)`, exit `0` — the README's "run from anywhere" claim holds.
`bash -n run_gate.sh` → exit `0`; `shellcheck run_gate.sh` → exit `0` **[O]**.

**Check 2 really hits the network [O].** No `url.*` rewrite is configured (`git config
--get-regexp 'url\.'` → empty), and a manual fresh clone returned HEAD
`a6aa73ada02a9fb1f5415bec491f9942c519b297` in <1 s. The gate's `BLOCKED, not PASS` branch on
clone failure is therefore a live path, not a formality.

---

## 3. Independent re-derivation of each pinned value

Each was re-measured from the subtree with a command I ran, without reusing the gate's own code.

- **12 tracked files [O]** — `git ls-files corpus/knowledge/unreal-mcp/upstream/ | wc -l` → `12`;
  `find corpus/knowledge/unreal-mcp/upstream -type f | wc -l` → `12`. This is the **`upstream/`
  vendored set only**. The whole-subtree tracked count is **40** (`git ls-files
  corpus/knowledge/unreal-mcp/ | wc -l` → `40` = 12 upstream + 12 manifests + 3 index + 13
  cards), which is the r101 report's own figure (`r101-report.md:206`). The gate's
  `EXPECTED_TRACKED=12` is applied to the **clone's** `git ls-files` and to the vendored
  `upstream/` path set, so the "12" is read in the correct scope — no phantom-12th-file hazard.
- **13 cards [O]** — `find corpus/knowledge/unreal-mcp/executability -maxdepth 1 -name '*.md' |
  wc -l` → `13`.
- **12 / 1 / 0 census [O]** — re-ran the r101 label rule (first line containing an allowed token,
  within 40 lines, bold/heading-marked, exactly one token): `CARDS=13 BAD=0`, 12 × `static-only`
  + 1 × `unproven-runtime` (`executability/actors-scene.md:5`) + 0 × `verified-here`. A naive
  `grep '^\*\*Label:\*\*'` returns only `8 / 1` because four cards use other legitimately-marked
  forms (`**Verdict label: …**`, `Verdict: **…**`, etc.) — the gate implements the tolerant rule,
  not the naive one, so it is correct where a naive scan would false-FAIL.
- **Manifest `OK=12` [O]** — `sha256sum -c .manifest.d/audit-reference.sha256` → 12 × `OK`,
  rc=0. The manifest is 18 **physical** lines (12 rows + 6 `#` comments); the gate counts
  `: OK$` lines, so it is robust to the comment header where a `wc -l` gate would read 18.
- **Pointers `40` [O]** — reproduced with the gate's own exclusion set. See §5 for the one
  caveat (range forms).

---

## 4. Negative controls — all independently reproduced

I re-ran every documented control on a throwaway `cp -r` copy (never the pinned tree) and
confirmed each flips the gate red **[O]**:

| control | mutation I applied | observed | gate README's claimed signal | match |
|---|---|---|---|---|
| C1 | append `\n` to `upstream/README.md` | exit 1; `MANIFEST_OK=11 … FAILED=1`; `BLOB-DIFF README.md` | same | ✓ |
| C2 | `rm upstream/LICENSE` | exit 1; `PATH_MISSING=1`; `BLOB-DIFF LICENSE` | same | ✓ |
| C3 | plant `upstream/README.md:200` | exit 1; `LINE-OOR … (max 112)`; `UNRESOLVED=1` | same | ✓ |
| C4 | duplicate a label token on `blueprints.md:4` | exit 1; `FAIL multi-label`; `BAD=1` | same | ✓ |
| C5 | relabel a card `unproven-runtime` | exit 1; census `11 / 2 / 0` | census `11 / 2 / 0` | ✓ |
| C6 | `rm executability/sequencer.md` | exit 1; `CARDS=12 EXPECTED=13` | same | ✓ |
| C7 | plant **only** exact sentinels | exit **0**; `SKIPPED_CONTROL_SENTINELS=3`; `UNRESOLVED=0` | exit 0; `SKIPPED_CONTROL_SENTINELS=2` | mechanism ✓, count differs (see F2) |

The calibration is real: the "passes everything" failure mode is excluded, and C5/C6 show the
census pin catches a *censored* (relabelled / removed) tree, not only a corrupted one.

---

## 5. Flags — drift checks and wording observations

### F1 — [O] Check 4's pointer regex is range-blind (robustness note, no drift)

`run_gate.sh:192` matches `upstream/<path>:<line>` and captures only the **first** endpoint. The
subtree's `adaptation-kimi.md` carries **5** range/comma pointers — `upstream/hooks/hooks.json:4-5`,
`upstream/hooks/unreal-context.sh:5,8`, `upstream/README.md:39,45`, `upstream/README.md:50-57`,
`upstream/skills/unreal-mcp/references/setup.md:61,70-79` **[O]** — whose tail endpoints the gate
does not check. Count impact: gate-style scan → `POINTERS=40`; range-aware scan (every endpoint,
as in `reports/round-102/reruns/pointer-sweep.sh`) → `POINTERS=47` **[O]**. Both read
`UNRESOLVED=0`.

I hand-verified all five tail endpoints against their files' line counts and every one is
**in range** (`hooks.json:5` max 17; `unreal-context.sh:8` max 84; `README.md:57` max 112;
`setup.md:79` max 133) **[O]** — so there is no hidden unresolved pointer today. This is **not**
a drift from r101: r101's own subtree scan used the identical range-blind regex and also
recorded `40` (`r101-report.md:146,188`). The note is forward-looking: a future range pointer
whose **tail** endpoint is out of range would pass the gate. The gate's 40 is correct for its
stated rule and matches r101.

### F2 — [O] C7's observed count is not reproducible from the README as written

`gate/README.md:172` records C7 as `SKIPPED_CONTROL_SENTINELS=2`, but unlike C1–C6 the README
gives **no command** for C7 — so the "2" cannot be re-derived from the README alone. Planting all
three documented sentinels (`upstream/nope.md:1`, `upstream/README.md:9999`,
`upstream/README.md:500`) yields `SKIPPED_CONTROL_SENTINELS=3`, exit 0 **[O]**. The mechanism is
correct (exact-match skip, gate stays green, `UNRESOLVED=0`); only the pinned count is
unreproducible because the plant set is unspecified. Suggested fix for the owner: show C7's
`printf` command, as C1–C6 do.

### F3 — [O] `gate/README.md:135` says "three mutations" but the section lists six (C1–C6) plus C7

Line 135 reads "These three mutations must each turn the gate red", while the block below lists
**six** mutations (C1–C6) and the matrix adds C7 — seven rows. This is stale wording left from an
earlier draft (the README grew 8776 → 10471 B at `14:42:49` while this review was in progress).
It is a documentation inconsistency only; the controls themselves are correct and I reproduced all
seven. Flagged for SEAT-17 / the L1; this seat does not edit another seat's file.

### Non-flags — verified consistent, recorded for completeness

- The subtree README's own `.manifest.d` wording was **folded at `14:43`** (`:169` and `:187` now
  say "12 `OK` lines … the `*.sha256` glob prints 24 — the same 12 paths, each covered twice").
  I confirmed the reality it now describes: `audit-reference.sha256` alone → 12 `OK`; the full
  `*.sha256` glob → 24 `OK` **[O]**. This resolves the r101 "12 lines" ambiguity; it is a subtree
  README edit by its owning seat, outside this gate review's write scope.
- The gate's sentinel set matches the code exactly: README `:99–100` names
  `upstream/nope.md:<N>`, `upstream/README.md:9999`, `upstream/README.md:500`; `run_gate.sh:180`
  implements `upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)`. The `gate/README.md`
  self-exclusion is **load-bearing**: neutering it makes the gate fail on its own C3 worked
  example (`LINE-OOR … gate/README.md :: upstream/README.md:200`, `UNRESOLVED=1`) **[O]**.
- `run_gate.sh`'s `SELF=$GATE_DIR/README.md` correctly targets the gate's own spec, and the
  subtree carries no `.git` inside `upstream/` (`find … -name .git` → empty **[O]**), so check 2's
  plain-file enumeration of the vendored side is sound.

---

## 6. No Unreal runtime claim

Reiterating the gate's own boundary and confirming it holds **[O]**: the gate runs no Unreal
Editor, MCP server, or tool call. It cannot promote any card to `verified-here`; the census pin
`verified-here=0` is a guard against exactly that. Unreal Editor is not installed on this host, so
every runtime claim in the subtree remains `unproven-runtime`/`static-only` by construction, and a
green gate is **not** evidence of live-editor behavior.

---

## 7. Reproduce this review

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# gate green, from the lane root and from anywhere
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
(cd /tmp && bash /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/gate/run_gate.sh)

# independent re-derivation
git ls-files corpus/knowledge/unreal-mcp/upstream/ | wc -l                 # 12
git ls-files corpus/knowledge/unreal-mcp/ | wc -l                        # 40 (whole subtree)
find corpus/knowledge/unreal-mcp/executability -name '*.md' | wc -l      # 13
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK')  # 12

# range-blind vs range-aware pointer counts
bash reports/round-102/reruns/pointer-sweep.sh corpus/knowledge/unreal-mcp | tail -3   # POINTERS=47

# one negative control (repeat with the other mutations in gate/README.md §Calibrating)
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf '\n' >> "$T/sub/upstream/README.md"
bash "$T/sub/gate/run_gate.sh" | tail -1                                  # GATE RESULT: FAIL (checks failed: 2)
```

**Seat write scope honoured:** this report is the only file this seat created. No git-mutating
command was run; `git status --porcelain` was read-only. No pinned subtree byte
(`corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`) was touched; all control runs were
on `mktemp -d` copies.
