# r103 close-out verification protocol

**Seat:** SEAT-45 VERIFIER-CHAIR · round 103 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only. No tracked file was modified by this seat.
**Executed by:** the L1 at round close, on the **committed** r103 tree.
**Audience:** a non-author verifier. Every step re-derives its own evidence; nothing here asks you
to trust an author's transcript — including the numbers below.
**Written:** 2026-10-18, against worktree HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
(r102 report-last; r102 work commit `c6f655d`). The r103 work is **uncommitted at write time**.

Round axes: **depth / coverage / calibration**. Coverage is the lowest non-retired axis.

## 0. What this protocol gates

| claim | axis | what must hold at close |
|---|---|---|
| **C1** | coverage | `corpus/knowledge/unreal-mcp/adaptation-kimi.md` carries a **dated correction note** for the three stale citation classes (config.toml line, four doc URLs needing `/en/`, the `/tmp/ue-skills-ref` pointer), with every row above the note left byte-verbatim |
| **C2** | depth | gate hardening **A1–A4** are implemented in `corpus/knowledge/unreal-mcp/gate/run_gate.sh`, each falsified by a plant that flips the gate red, and the clean tree still green |
| **C3** | calibration | the three dead `.shokunin/game-dev-3d/` roots in runnable contexts are repaired with the repair-vs-correction-note discipline honoured; the battery row `phys3d_joints_free_ops` is **investigated, not repaired**; the battery bytes are untouched |

**Fail-closed rule.** Any step that does not print its expected result is a FAIL for its claim. Do
not average, do not skip, do not "looks good". A missing artifact is a FAIL, not a warning.

**Non-author requirement.** Steps 2, 3, 4, 5 and 8 must be run by someone who did not write the
artifact under test. Steps 1, 6, 7 and 9 are mechanical re-derivations and may be run by anyone.
For any step whose expected result is a number, **re-run it** — do not accept a pasted number.

### 0.1 Environment and pinned constants

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
SUB=corpus/knowledge/unreal-mcp
GATE=$SUB/gate/run_gate.sh
WORK=$HOME/.cache/r103-closeout          # NOT /tmp — see §0.3
rm -rf "$WORK" && mkdir -p "$WORK"
```

Required on PATH: `bash git sha256sum grep find sort comm curl python3 node npm jq shellcheck`.
Network is required by gate CHECK 2 and by step 8. **Put `$WORK` outside `/tmp`:** this host's
`/tmp` is a 16 GB tmpfs that ran at 77 % during r103 and returned `Disk quota exceeded` mid-copy,
which silently truncates a `git archive` export and can make CHECK 2 look blocked (§0.3).

### 0.2 The tree at protocol-write time — measured, not remembered

```sh
git status --porcelain
```

Observed 2026-10-18T18:39Z:

```
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

Two consequences that govern the whole protocol.

1. **The gate is modified but not yet committed.** `git show HEAD:$GATE | sha256sum` is
   `412d1b84…`; the worktree file is `577c8b54…` (it was rewritten several times during r103 — see
   §9.4). A verifier who runs the gate on a pristine `git archive HEAD` export gets the
   **un-hardened r102 gate** — it will pass, but A1–A4 will all be absent and steps 3.1–3.4 will
   FAIL. The protocol's expected outputs are for the tree **after** the L1 lands the r103 commit.
2. **`corpus/fixtures/three/README.md` is modified inside `corpus/fixtures/`**, a HARD-RULES
   protected tree. That edit is the B2 repair (17 command lines), is substantively correct, and is
   flagged as an unruled scope question in `reports/round-103/b2/postgrep.md` §4.1. Step 6 exists
   partly to make that edit visible rather than silent.

Artifact digests at write time (these are *before-commit* values; re-derive, do not diff against
them):

| path | sha256 (short) | note |
|---|---|---|
| `$SUB/gate/run_gate.sh` | `577c8b54` | A1–A4 landed; `/tmp/advgate` hardcode gone |
| `$SUB/gate/README.md` | `b32a481f` | pass-A/B note + pin correction + exit-code section |
| `$SUB/adaptation-kimi.md` | `084a34cd` | +143/−0, C1 note at line 367 |
| `corpus/fixtures/three/README.md` | `19ad2c8c` | B2 repair, 17/17 lines |
| `corpus/artifacts/glb-r12/README.md` | `d87774dc` | B2 repair, 3/3 lines |
| `corpus/artifacts/unity-r19/README.md` | `12c4abd1` | B2 repair, 2/2 lines |

### 0.3 Why `$WORK` must not be `/tmp` — measured

`/tmp` is a tmpfs, 16 GB, 77 % full at write time. Two failure modes were observed during r103:

```
$ git archive HEAD | tar -x -C /tmp/r103-a2-attack
tar: PROVINCE.md: Cannot write: Disk quota exceeded
tar: corpus/fixtures/...: Cannot write: Disk quota exceeded
```

and a partly-extracted export makes the gate's pass-B sweep report `MISSING-PATH-REL` for files
that simply were not written. Use `$HOME/.cache/...` or `/dev/shm` for every scratch tree in this
protocol. **A `Disk quota exceeded` line anywhere in a step's output invalidates that step.**

---

## 1. Tree and protected-path preconditions  *(mechanical)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD
git status --porcelain
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md SKILL.md PROVINCE.md \
    corpus/fixtures/run_battery.py reports/round-101 reports/round-102
git diff --name-only HEAD -- "$SUB/upstream" "$SUB/.manifest.d"
```

**Expected:** `HEAD` = the r103 close commit; `git status --porcelain` **empty** (everything landed);
the two `git diff --name-only` calls print **nothing**. A non-empty ledger diff means a protected
path moved and the round cannot be admitted on this evidence.

```sh
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
  printf '%s wt=%s head=%s %s\n' "$f" "$(git hash-object -- "$f")" "$(git rev-parse "HEAD:$f")" \
    "$([ "$(git hash-object -- "$f")" = "$(git rev-parse "HEAD:$f")" ] && echo MATCH || echo DIFFER)"
done
```

**Expected:** four `MATCH` lines. (Blob comparison, not mtime — an edit that restores size or mtime
still shows `DIFFER`.)

---

## 2. Gate: self-containment and the clean run  *(C2, non-author)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
test -x "$GATE" && echo GATE_EXECUTABLE || echo GATE_NOT_EXEC
bash -n "$GATE" && echo "bash -n OK"
shellcheck "$GATE"; echo "shellcheck_exit=$?"
bash "$GATE" > "$WORK/clean.txt" 2>&1; echo "GATE_EXIT=$?"
grep -E '^MANIFEST_FILES|^MANIFEST_OK|^CLONE_HEAD|^CLONE_DIRTY|^CLONE_TRACKED|^PATH_|^BLOB_DIFFS|^CARDS=|^NAME_SET|^CENSUS|^POINTERS|^GATE RESULT' "$WORK/clean.txt"
```

**Expected:** `GATE_EXECUTABLE`, `bash -n OK`, `GATE_EXIT=0`, and these lines:

```
MANIFEST_FILES=12
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=<n> POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**`shellcheck_exit=1` is expected and is not a FAIL.** The gate carries one deliberate SC2016 info
on the pass-B `grep -oE '[`]…'` pattern (single quotes are intentional — the pattern matches a
literal backtick). The same info is present on the r102 bytes (`git show HEAD:$GATE | shellcheck -`
→ exit 1, same line). Record it; do not "fix" it.

**`POINTERS` is NOT a stable number — never assert it.** Measured on this host:

| tree | `POINTERS` | `POINTER_STRINGS` |
|---|---:|---:|
| pristine `git archive HEAD` export (r102 bytes, `412d1b84…`) | `88` | — |
| same export with the hardened gate copied in | `95` | `41` |
| live worktree, 18:34Z | `91` | `41` |
| live worktree, 18:39Z | `98` → `100` | `41` |
| live worktree, 18:41Z | `101` | `41` |
| live worktree, 18:43Z | `101` | `41` |

The count rose `88 → 90 → 91 → 95 → 98 → 100 → 101` during r103 with no gate-logic change, because
pass B (`run_gate.sh:322-330`) sweeps backtick-wrapped repo-relative paths across the whole subtree
**including `gate/README.md` itself** and **including `reports/`**, so every sentence any seat
writes into the subtree or into `reports/round-103/**` that names a backticked path moves it. The
binding invariant is **`UNRESOLVED=0`**; the count is an advertised measurement. A verifier who
asserts a literal `POINTERS` value will report a false FAIL — the README's pin agreed with the live
run at 18:43Z only by coincidence, and will diverge again on the next prose edit. See §9.4.

**Network caveat.** CHECK 2 clones the upstream repo. If the clone cannot complete, the gate prints
`CHECK 2 BLOCKED (network)` / `STEP=BLOCKED` and exits **2** (see §3.4). Record BLOCKED as BLOCKED;
never as PASS, and never substitute a cached clone without saying so.

---

## 3. Gate hardening A1–A4 — each must be falsified by a plant  *(C2, non-author)*

A gate that cannot fail proves nothing, and a hardening that is only *described* proves less. Each
sub-step plants one mutation on a **throwaway copy of the whole repo** and asserts the gate goes red
for the right reason.

**Harness rule, learned the hard way.** Copy the **whole repo**, not just the subtree. The gate's
pass-B sweep resolves `corpus/…` and `reports/…` pointers against `$(cd "$SUB/../../.." && pwd)`,
so a subtree-only copy makes the gate FAIL spuriously with `MISSING-PATH-REL`:

```
# WRONG — subtree-only copy, unmutated control:
$ bash /tmp/mc/$SUB/gate/run_gate.sh; echo rc=$?
GATE RESULT: FAIL (checks failed: 1)
rc=1                       # <-- not a mutation, just a missing repo root
```

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
A=$WORK/attacks; rm -rf "$A"; mkdir -p "$A"
fresh() { rm -rf "$A/c"; mkdir -p "$A/c"; git archive HEAD | tar -x -C "$A/c" || exit 1
          cp "$GATE" "$A/c/$GATE"; }
run()  { bash "$A/c/$GATE" > "$A/out.txt" 2>&1; printf '%-22s rc=%s | %s\n' "$1" "$?" \
          "$(grep -E '^FAIL|^GATE RESULT' "$A/out.txt" | head -3 | tr '\n' ' ')"; }
```

`fresh` must never emit a `Disk quota exceeded` line (§0.3).

### 3.1 A1 — every endpoint of a `:a-b` / `:a,b` range is validated

```sh
fresh; run "A1-M0-control"                                  # rc=0
fresh; printf '\nsee upstream/README.md:1-9999\n' >> "$A/c/$SUB/executability/materials.md"; run "A1-plant-range-tail"
grep -E 'LINE-OOR|^POINTERS' "$A/out.txt"
```

**Expected:** control `rc=0` / `GATE RESULT: PASS`; plant `rc=1` with
`LINE-OOR … :: upstream/README.md:1-9999 (max 112)` and `UNRESOLVED=1`. **Observed:** exactly that.
On the r102 bytes the same plant left the gate **green** (`UNRESOLVED=0`), which is the defect A1
removed.

### 3.2 A2 — a prose line above the declaration must not hijack the label

```sh
fresh; sed -i '4i This card is emphatically not `verified-here`; nothing was observed.' \
      "$A/c/$SUB/executability/editor-general.md"; run "A2-prose-hijack"
fresh; sed -i '4s/.*/A card with no label token on its declaration line./' \
      "$A/c/$SUB/executability/blueprints.md"; run "A2-NC1-unlabelled"
fresh; sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' \
      "$A/c/$SUB/executability/blueprints.md"; run "A2-NC2-multilabel"
fresh; sed -i '4s/.*/Label: static-only/' \
      "$A/c/$SUB/executability/blueprints.md"; run "A2-NC3-unmarked"
```

**Expected — note the directions.** The prose-hijack plant must stay **GREEN** (`rc=0`,
`CARDS=13 BAD=0`): the card is correctly labelled at line 5 and the prose above it must not be
mistaken for the declaration. The three negative controls must each go **RED** (`rc=1`, `BAD=1`).
**Observed:** prose-hijack `rc=0 PASS`; NC1 `FAIL no-label` `BAD=1`; NC2 `FAIL multi-label` `BAD=1`;
NC3 `FAIL no-label` `BAD=1`. On the r102 bytes the prose-hijack plant false-FAILed a correctly
labelled card (`FAIL label-unmarked … This card is emphatically not \`verified-here\``) — the defect
A2 removed. A verifier who expects the prose-hijack plant to be RED has the polarity inverted.

### 3.3 A3 — the card-name set is compared, not just counted

```sh
fresh; mv "$A/c/$SUB/executability/sequencer.md" "$A/c/$SUB/executability/sequence-typo.md"; run "A3-rename-card"
grep -E '^CARDS=|^NAME_SET|card-name' "$A/out.txt"
```

**Expected:** `rc=1` with **both** directions named —
`FAIL card-name-missing sequencer.md`, `FAIL card-name-extra sequence-typo.md`,
`NAME_SET=BAD NAME_BAD=2`, and still `CARDS=13 EXPECTED=13 BAD=0` (the count is unchanged; only the
name set catches it). **Observed:** exactly that. On the r102 bytes CHECK 3 printed
`CARDS=13 EXPECTED=13 BAD=0 / STEP=PASS` and the rename was caught only *incidentally* by CHECK 4's
pointer sweep noticing referring documents still name the old file — and went **fully green** once
those references were made consistent (`reports/round-103/gate/a3-attack.md` §0). That full
false-PASS is what A3 removes.

### 3.4 A4 — an unreachable clone is a distinct BLOCKED state with exit 2

```sh
# BLOCKED alone: no network, no other check failing
(cd "$A/c" && https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 \
   ALL_PROXY=http://127.0.0.1:1 bash "$GATE" > "$A/blocked.txt" 2>&1); echo "blocked_exit=$?"
grep -E 'BLOCKED|^STEP=|^GATE RESULT' "$A/blocked.txt"

# GATE_REF: an existing clone at the pin, offline — must be scored normally
(cd "$A/c" && GATE_REF=/tmp/ue-skills-ref https_proxy=http://127.0.0.1:1 \
   http_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 bash "$GATE" \
   > "$A/ref.txt" 2>&1); echo "ref_exit=$?"
grep -E 'GATE_REF=|^CLONE_HEAD|^STEP=|^GATE RESULT' "$A/ref.txt"

# BLOCKED **and** another check failing: the third state must not swallow the failure
fresh; printf '\nsee upstream/README.md:200\n' >> "$A/c/$SUB/README.md"
(cd "$A/c" && https_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 bash "$GATE" \
   > "$A/mixed.txt" 2>&1); echo "mixed_exit=$?"
grep -E 'BLOCKED|^STEP=|^GATE RESULT' "$A/mixed.txt"
```

**Expected:**

```
blocked_exit=2
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)

ref_exit=0
GATE_REF=/tmp/ue-skills-ref (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
GATE RESULT: PASS (checks failed: 0)

mixed_exit=1
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)
```

**Observed:** all three exactly as above. `GATE_REF` must be a real clone at the pin; a path that is
not a git clone is a genuine FAIL, not BLOCKED (`FAIL GATE_REF is not a git clone`).

The `GATE_REF=/tmp/ue-skills-ref` reference is **volatile** — `/tmp` is swept. If it is gone,
re-clone it, or skip the `GATE_REF` half and record it as not-run; do not substitute a clone at a
different SHA without saying so. (`/tmp/ue-skills-ref` existed and returned the pin at write time.)

**The mixed case is a known residual, not a pass.** `run_gate.sh:335` guards `exit 2` with
`[ "$FAILS" -eq 0 ]`, so BLOCKED **plus** any other failure reports `GATE RESULT: FAIL` / exit 1 —
the reader again cannot tell "check 2 could not run" from "the bytes diverge". `gate/README.md:211`
records this. A verifier should **not** treat exit 1 in the mixed case as a clean FAIL; read the
`STEP=BLOCKED` line.

### 3.5 The wider attack battery — all of these must be DETECTED

The hardening must not have *removed* detection. Re-run the classic set on whole-repo copies
(`fresh`/`run` as above); **every row must print `rc=1`**:

| id | mutation | expected failing signal |
|---|---|---|
| M1 | append one byte to `$SUB/upstream/README.md` | `FAIL per-seat manifest sweep`, `MANIFEST_OK=11 … FAILED=1`, `BLOB-DIFF README.md` |
| M2 | delete `$SUB/executability/materials.md` | `FAIL card-name-missing materials.md` |
| M3 | corrupt line 1 of `.manifest.d/audit-reference.sha256` | `FAIL per-seat manifest sweep` |
| M4 | delete `$SUB/upstream/LICENSE` | `FAIL upstream file not vendored` |
| M5 | append `see upstream/README.md:200` to `$SUB/README.md` | `LINE-OOR … (max 112)` |
| M6 | duplicate a label token on `blueprints.md:4` | `FAIL multi-label` |
| M7 | relabel `blueprints.md:4` `unproven-runtime` | census `11 / 2 / 0` ≠ `12 / 1 / 0` |
| M8 | rename `sequencer.md` → `sequence-typo.md` | `FAIL card-name-missing` + `card-name-extra` |
| M9 | append `see upstream/README.md:1-9999` | `LINE-OOR … :1-9999` |
| M10 | insert prose naming a token above `editor-general.md`'s declaration | **must stay `rc=0`** |
| H2 | symlink `/tmp/payload.md` → `$SUB/upstream/evil.md` | `FAIL non-regular file in pinned tree` |
| H4 | `mkdir $SUB/executability/sub` with a 14th card inside | `FAIL nested entry under executability/` |
| H14 | CRLF the audit manifest | `FAIL CR byte in manifest` |
| H21 | append `see upstream/README.md:0` | `LINE-ZERO` |
| H22 | empty every `.manifest.d/seat*.sha256` | `FAIL per-seat manifest sweep` |
| H5 | append a backticked `reports/round-999/ghost.md` | `MISSING-PATH-REL` |
| C7 | plant **only** the exact sentinels (`upstream/README.md:500`) | **must stay `rc=0`**, `SKIPPED_CONTROL_SENTINELS=1` |

**Observed 2026-10-18, whole-repo copies, hardened gate:** M1–M9 and H2/H4/H14/H21/H22/H5 all
`rc=1`; **M10 and C7 `rc=0` as required**. No mutation produced a false PASS.

**M10 is the polarity trap.** Every other mutation must go red; the prose-hijack plant must stay
green. A verifier who lists M10 among the "must be detected" rows will report a false FAIL.

**One open false-PASS class, measured.** `H6` — appending `see upstream/LICENSE:99999` — leaves the
gate **GREEN** (`rc=0`, `UNRESOLVED=0`), because CHECK 4's pointer regex requires a dotted path
segment (`…\.(md|json|sh|txt)?` / `…\.[A-Za-z0-9]+`), so extensionless targets such as
`upstream/LICENSE`, `upstream/CODEOWNERS` and `upstream/.gitignore` are never swept. Fold-spec item
**A6** was not implemented in r103 and is **still open**. Do not list H6 as a pass; list it as a
known residual (§9.2).

---

## 4. B2 — the dead `.shokunin/game-dev-3d/` roots  *(C3, non-author)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md \
         corpus/artifacts/unity-r19/README.md; do
  printf '%-42s %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"
done
git grep -l "\.shokunin/game-dev-3d" | wc -l
git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l
```

**Expected:** three `0` lines — **the postgrep is `0` for all three READMEs**. The worktree total is
**lower than HEAD** by exactly the number of files repaired (`164` vs `167` at write time; re-derive,
it moves as seats land edits — the three per-file counts are the binding number, not the total).

Then the repaired commands must actually run green **as written**:

```sh
python3 corpus/artifacts/glb-r12/run_import.py; echo "glb_rc=$?"
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py; echo "unity_rc=$?"
npm ci --prefix corpus/fixtures/three --offline; echo "npm_rc=$?"
node corpus/fixtures/three/run_cases.mjs; echo "three_rc=$?"
```

**Expected:** `glb_rc=0`, `unity_rc=0`, `npm_rc=0`, `three_rc=0` with
`PASS three battery: 3/3, seeds_unchanged=true`.

**The dead-root forms must still fail — that is what proves the repair did work, not decoration:**

```sh
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py  >/dev/null 2>&1; echo "dead_glb=$?"
uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py >/dev/null 2>&1; echo "dead_unity=$?"
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs >/dev/null 2>&1; echo "dead_three=$?"
```

**Expected:** `dead_glb=2`, `dead_unity=2`, `dead_three=1` (non-zero). **Observed:** exactly that.
If a dead-root form exits 0, the prefix resolved — i.e. you are running from the **parent** repo
(`~/Projects/prymeagnt/game-dev-3d`), where `.shokunin/game-dev-3d` is a symlink. The defect is a
path-conformance defect *measured from this repo root*, not a false statement about the author.

**Discipline check — the repair-vs-correction-note split.** Read `reports/round-103/b2/ruling.md`,
`…/corrections.md` and `…/postgrep.md`, then confirm on the tree:

```sh
git diff HEAD -- corpus/fixtures/three/README.md | grep -c '^[+-].*shokunin/game-dev-3d'
grep -c 'correction\|Correction' corpus/artifacts/unity-r19/README.md
```

**Expected:** `git diff … | grep -c` → `17` (the repair touches 17 command lines; each appears once on
its own `-`/`+` line, so the count is 17, not 34); `grep -c 'correction\|Correction'` on
`corpus/artifacts/unity-r19/README.md` → `0`, i.e. the three READMEs carry **no in-file correction
note** — the declaration lives in `reports/round-103/b2/corrections.md` §4.2, which
`…/corrections.md` rules is **PASS with declaration outside the file**. `corrections.md` §0 also
rules `gate/README.md` as **FAIL (drift)** — see §9.4; a verifier must not read that as a B2
failure.

---

## 5. The battery row `phys3d_joints_free_ops` — investigation, not repair  *(C3, non-author)*

The brief asks for **investigation only**. Confirm the investigation exists and that the row is
correctly *classified*, then reproduce it.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
test -f reports/round-103/physics/investigate.md && echo INVESTIGATION_PRESENT
python3 - <<'PY'
import json
d = json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'))
res = d['results']
bad = [r for r in res if r['verdict'] != 'PASS']
print('totals', d['totals'])
print('rows', len(res), 'non-PASS', len(bad))
for r in bad:
    print(' ', r['case'], r['verdict'], 'exit=', r['actual_exit'], 'exp=', r['expected_exit'],
          'elapsed=', r.get('elapsed_seconds'), r['reasons'])
PY
```

**Expected:** `INVESTIGATION_PRESENT`; `totals {'cases': 350, 'pass': 336, 'fail': 14, ...}`;
**14 non-PASS rows in two classes**, not one:

- **13 × `r94_cannon_*`** (`det det2 varstep bailout nan sync material friction parity parity2 modes
  order backends`) — `exit=0 expected=0`, `elapsed ≤ 1.8 s`, reason `['exact stdout marker
  missing']`. The marker pins `node=v24.21.0`; this host runs `node v26.12.0`. Marker staleness, not
  a physics failure.
- **1 × `phys3d_joints_free_ops`** — `exit=None expected=0`, `elapsed=20.008 s`, reasons
  `['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker
  missing']`. Its captured stdout contains **only** the Godot banner. This is a **wall-clock budget
  failure**, a different class.

**`336/350` is the r102 receipt's figure and must be quoted with that receipt.** The row's class is
mis-assigned in the standing ledger as one more member of the `r94_cannon` marker class; 13 of 14
are that class and the 14th is not (`reports/round-103/r103-distiller.md` §N3).

Isolated reproduction (this is what a verifier runs; **do not repair anything**):

```sh
timeout 120 python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops 2>&1 | tail -5
```

**Expected:** `FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20
seconds', …]` and `totals: cases=1 pass=0 fail=1`. **Observed:** reproduced twice, ~20 s wall clock
each time. `run_battery.py:36` sets `CASE_TIMEOUT_SECONDS = 20`; `reports/round-103/physics/
investigate.md` §1 measures the arm at 21–24 s wall against ~3.5 s CPU (≈84 % of wall is
starvation) and shows the pinned marker is emitted **byte-for-byte** (3921 chars) with `rc=0` on a
clean scratch. **Verdict: harness timeout, not engine behaviour and not a fixture defect.** No
repair is applied or owed this round.

**Two traps in this step.**

1. **`run_battery.py`'s exit code is `1` on any failing run — do not read it as the verdict.** The
   runner returns `0 if verdict == "PASS" else 1` (`run_battery.py:1384`), and its `verdict` is
   `PASS` only when **every** row passed. So on this host a full run always exits `1` (14 known
   failures), and so does a 1-case run of a failing row (measured `runner_rc=1`). Read the `totals:`
   line and the receipt; a non-zero exit here is **expected**, not a regression. Conversely, never
   capture the code through a pipeline (`… | tail -5; echo $?` reports `tail`'s status, not the
   runner's).
2. **`seeds_unchanged` can go false from an untracked-file event, not from a fixture edit.** One
   isolated run during r103 printed `FAIL seeds were modified during the run; seeds must stay
   read-only` while 21 untracked `corpus/fixtures/r90bt_*/` directories were present on disk. Those
   directories are created by the arm itself (`phys3d_joints.gd:118` builds `res://r90bt_<arm>_<case>
   _<bk>`), normally inside the run's scratch copy. `seed_digests()` walks `corpus/fixtures/`
   **recursively**, so anything that materialises there mid-run — including a leak from a concurrent
   run — flips the guard. On the two later isolated runs the guard read `true` and no leak
   recurred. **Consequence for this protocol:** when `seeds_unchanged` is false, first check for
   untracked directories under `corpus/fixtures/` (step 6.2) before concluding a fixture was edited.

---

## 6. Battery bytes untouched  *(C2/C3 supporting)*

Three independent proofs. **Step 6.2 is not optional** — the tracked-blob proof in 6.1 is blind to
untracked leaks, and a leak is exactly what §5's trap describes.

### 6.1 Tracked fixture bytes identical to HEAD

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- corpus/fixtures/; echo "fixtures_diff_rc=$?"
git ls-files -s corpus/fixtures | awk '{print $2"  "$4}' | sort | sha256sum
git ls-tree -r HEAD corpus/fixtures | awk '{print $3"  "$4}' | sort | sha256sum
git ls-files corpus/fixtures | wc -l
sha256sum corpus/fixtures/run_battery.py
git hash-object corpus/fixtures/run_battery.py
git rev-parse HEAD:corpus/fixtures/run_battery.py
```

**Expected:**

- the diff is **empty apart from the intended B2 edit** — `corpus/fixtures/three/README.md | 34
  ++++----` (17/17 command lines). **Any other path in that diff is a FAIL**; `fixtures_diff_rc=0`.
- the two aggregate digests are **equal**;
- `146` tracked fixture files;
- `run_battery.py` triple: sha256
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, and
  `git hash-object` == `git rev-parse HEAD:corpus/fixtures/run_battery.py`
  (blob `dd2d9b74448afddb88dcf2da56008302eba8060d`).

**Observed 2026-10-18:** both aggregates
`827af6c35233bc520d5a797dd650a777df1f18ab9fca9652e5fab0b1e539096d`; `146` files; the triple as
above; the only diff line is `three/README.md`.

### 6.2 No untracked or leaked entry under `corpus/fixtures/`

```sh
git status --porcelain -uall -- corpus/fixtures/
ls corpus/fixtures | grep -c '^r90bt_' || true
git check-ignore -v corpus/fixtures/three/node_modules 2>/dev/null || echo "not-ignored"
```

**Expected:** **exactly one** porcelain line — ` M corpus/fixtures/three/README.md` — and **zero**
`r90bt_*` entries. **Observed:** `1` porcelain line, `0` leaked directories (21 had accumulated
during the round and were removed before the close measurement). Any other line is a FAIL: a leaked
`r90bt_*` directory means a Godot run used `corpus/fixtures` as its project path, and a leak that
survives to the commit lands untracked fixture pollution in a HARD-RULES-protected tree.

**Note:** `corpus/fixtures/three/node_modules/` **is** gitignored — by a per-directory ignore file,
`corpus/fixtures/three/.gitignore:1:node_modules/` (`git check-ignore -v` confirms), so it does
**not** appear in `git status -uall`. It was present at write time and the porcelain count was still
`1`. The relevant lesson stands: if a future `npm ci` ever produces untracked entries here, they are
npm's install tree, and the only line that matters for the byte invariant is the tracked one. Any
`r90bt_*` entry, by contrast, is **not** ignored and must be reported.

### 6.3 The case table is intact (350 rows)

```sh
python3 - <<'PY'
import ast, subprocess, hashlib
blob = subprocess.run(['git','show','HEAD:corpus/fixtures/run_battery.py'], capture_output=True).stdout
tree = ast.parse(blob.decode())
cases = [ast.literal_eval(n.value) for n in tree.body
         if isinstance(n, ast.Assign) and any(getattr(x,'id',None)=='CASES' for x in n.targets)][0]
print("HEAD blob bytes:", len(blob), "sha256:", hashlib.sha256(blob).hexdigest())
print("HEAD CASES rows:", len(cases))
print("worktree==HEAD:", open('corpus/fixtures/run_battery.py','rb').read() == blob)
PY
```

**Expected:** sha256 `f456bd00…`, `350` rows, `worktree==HEAD: True`. **Observed:** exactly that.

### 6.4 The full 350-row run — the pass condition is a **named set**, not "zero FAIL"

**This step needs a long window** (several minutes on this host; run it in the background and do not
accept a truncated capture). It is required only if the L1 wants a fresh receipt; the r102 receipt
plus steps 6.1–6.3 already pin the byte invariant.

```sh
python3 corpus/fixtures/run_battery.py > "$WORK/battery.out" 2>&1; echo "battery_rc=$?"
grep -E '^totals:' "$WORK/battery.out"
python3 - <<'PY'
import json, subprocess
latest = subprocess.run("ls -1dt corpus/live/runs/*/ | head -1", shell=True,
                        capture_output=True, text=True).stdout.strip()
d = json.load(open(latest + 'verdicts.json'))
print('receipt', latest)
print('seeds_unchanged', d['seeds_unchanged'], 'totals', d['totals'])
print('non-PASS:', sorted(r['case'] for r in d['results'] if r['verdict'] != 'PASS'))
PY
```

**Expected, and read this carefully — `battery_rc=0` is the WRONG expectation here.** On this host
a full run is **not** green; measured `cases=350 pass=336 fail=14`, so the runner exits **`1`**
(`run_battery.py:1384`: `return 0 if verdict == "PASS" else 1`, and `verdict` is `PASS` only when
every row passed). The pass condition is:

1. `seeds_unchanged: true`;
2. `cases=350` (full row count ran, not a truncated capture);
3. `fail ≤ 14`, and **every failing name is in the known set** — the 13 `r94_cannon_*` rows plus
   `phys3d_joints_free_ops`. **A 15th name, or `fail > 14`, is a real regression and must be
   reported.**

Note the r102 protocol recorded `fail=16` (it also listed `r98_gltflat_doc` /
`r98_gltflat_extbin`); those two rows are **`PASS`** in the r102 receipt itself
(`corpus/live/runs/20261018T181301123479Z/verdicts.json`), so the r102 list was one class too long.
The binding set for r103 is the 14 rows named in step 5.

---

## 7. The byte-pinned subtree is intact  *(C1/C2 supporting)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- "$SUB/upstream" "$SUB/.manifest.d"; echo "pinned_dirs_rc=$?"
(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256; echo "audit_rc=$?")
(cd "$SUB" && sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK$')
git diff --stat HEAD -- "$SUB"
```

**Expected:** the first diff is **empty**, `pinned_dirs_rc=0`; 12 `OK` lines and `audit_rc=0`; the
glob prints `24` (12 paths twice); and `git diff --stat HEAD -- $SUB` shows **only** `README.md`,
`adaptation-kimi.md` and `gate/` — never `upstream/` or `.manifest.d/`. **Observed:** exactly that.

Per-seat shards, re-derived (the gate's HARDENING B runs this same glob):

```
audit-reference.sha256 rc=0 OK=12    seat06.sha256 rc=0 OK=1
seat01..seat10.sha256 rc=0 OK=1      seat11.sha256 rc=0 OK=2
```

**Expected:** 14/14 rc=0, 24 `OK` lines total, 0 `FAILED`.

**Host-independence of the manifest sweep (r103 fixed this).** The r102 bytes wrote this sweep to a
hardcoded `/tmp/advgate/.h1`; when that directory was absent the redirect failed before `sha256sum`
ran and the gate printed `FAIL per-seat manifest sweep` **plus exit 1 on a clean tree**. The r103
bytes use `mktemp`. Verify the fix with an unwritable `TMPDIR`:

```sh
TMPDIR=/nonexistent-xyz bash "$GATE" 2>&1 | grep -E 'per-seat|^MANIFEST_OK|^GATE RESULT'; echo "exit=${PIPESTATUS[0]}"
```

**Expected on the r103 bytes:** the gate still prints `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`.
It **does not** — measured, the `mktemp` itself fails under an unwritable `TMPDIR`, so the same
spurious `FAIL per-seat manifest sweep` + exit 1 returns. **This is a residual (§9.1), not a r103
regression:** the r103 fix removed the dependency on one *specific* directory but kept a dependency
on `TMPDIR` being writable. Record it; do not report the gate as broken for it, and do not run the
gate under a broken `TMPDIR`.

---

## 8. C1 — the freshness note  *(C1, non-author)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --numstat HEAD -- "$SUB/adaptation-kimi.md"
grep -c 'Correction note' "$SUB/adaptation-kimi.md"
grep -n 'r103' "$SUB/adaptation-kimi.md" | head -5
git diff HEAD -- "$SUB/adaptation-kimi.md" | grep -c '^-'
```

**Expected:** `143  0  …` (append-only — **zero deletions**); `Correction note` count `1`;
the note references `reports/round-103/note/author.md` and `…/urls.md`; and
`grep -c '^-'` → `0` apart from the `---`/`+++` diff headers. **A non-zero deletion count is a FAIL
of the discipline**: the r101 table must survive verbatim above the note.

Every file the note cites must exist (the gate's pass B enforces this too):

```sh
for p in reports/round-103/note/author.md reports/round-103/note/urls.md \
         reports/round-103/note/binary.md; do
  [ -e "$p" ] && echo "OK $p" || echo "MISSING $p"
done
```

**Expected:** three `OK` lines. **Observed:** three `OK`.

Now re-derive the note's three classes. **The `config.toml` line number is a moving target — the
note must be read for its *rule*, not its *number*.**

```sh
grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
wc -l ~/.kimi-code/config.toml
sed -n '1p' ~/.kimi-code/config.toml
kimi --version
sha256sum ~/.kimi-code/bin/kimi
```

**Expected / observed 2026-10-18:** one `[[hooks]]` block at line **3290** (file 3322 lines;
the operator edits this file continuously — r101 cited 2932, r102 measured 3219, r103 measures
3290, and the r102-proposed text still said 3219, which was already stale when it landed); line 1 is
`default_permission_mode = "auto"`; `kimi --version` → `2.2.0`; binary sha256
`8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af`. The note's **substance**
(the block exists, carries `event`/`matcher`/`command`/`timeout`, and its event is `Notification`,
not `SessionStart`) must hold; its **number** must not be asserted. A verifier who finds the block
at a different line than the note claims has found staleness, not a broken note — but must record it.

The four doc URLs must still be 404 bare and 200 prefixed (hard move, not a redirect):

```sh
for u in customization/plugins.html customization/hooks.html customization/mcp.html \
         configuration/config-files.html; do
  printf '%-40s bare=%s en=%s\n' "$u" \
    "$(curl -sIL --max-time 20 -o /dev/null -w '%{http_code}' "https://moonshotai.github.io/kimi-code/$u")" \
    "$(curl -sIL --max-time 20 -o /dev/null -w '%{http_code}' "https://moonshotai.github.io/kimi-code/en/$u")"
done
```

**Expected / observed:** `bare=404 en=200` on all four. A `bare=200` would mean the old citations
self-healed and the note overstates the defect.

**One URL defect the note deliberately leaves uncorrected:** `$SUB/adaptation-kimi.md:6` cites
`github.com/EpicGames/unreal-engine-skills-for-claude-code` (404 — the real repo carries a `-plugin`
suffix, and `PROVENANCE.md:19` already has the correct form). The note records it as *out of scope*
rather than folding it in. Confirm the note says so:

```sh
curl -sIL --max-time 20 -o /dev/null -w 'bare=%{http_code}\n' \
  https://github.com/EpicGames/unreal-engine-skills-for-claude-code
grep -c 'out of scope' "$SUB/adaptation-kimi.md"
```

**Expected:** `bare=404` and a non-zero `out of scope` count. **Observed:** `bare=404`, and
`grep -ci 'out of scope'` → `1` (the heading is `### Out of scope — a fourth defect this note does
*not* repair`, so the phrase is case-sensitive to the heading form; use `-i`).

Finally, the C1 evidence files must not break the gate's pass B — this is the interaction that made
the gate RED mid-round before `note/author.md` landed (`reports/round-103/r103-distiller.md` §7).
Step 2's `UNRESOLVED=0` is the check; re-run step 2 after step 8 if any `reports/round-103/**` file
changed in between.

---

## 9. Residuals and known-open items — do NOT read these as passes

These are measured, dated, and left open on purpose. A close-out that silently absorbs one is a
FAIL of the protocol.

**9.1 `mktemp` still requires a writable `TMPDIR`.** The r102 hardcode `/tmp/advgate/.h1` is gone
(`grep -c 'advgate' "$GATE"` → `1`, and that one hit is the explanatory **comment**, not a write
path), but `MANLOG=$(mktemp)` (`:74`) and `WORK=$(mktemp -d)` (`:86`) still fail under an unwritable
`TMPDIR`, reproducing the spurious `FAIL per-seat manifest sweep` + exit 1 on a clean tree. Measured
with `TMPDIR=/nonexistent-xyz`:

```
$ TMPDIR=/nonexistent-xyz bash "$GATE"
mktemp: failed to create file via template '/nonexistent-xyz/tmp.XXXXXXXXXX': No such file or directory
FAIL per-seat manifest sweep (--strict) failed:
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
GATE RESULT: FAIL (checks failed: 1)     exit=1
```

Mitigation: run the gate with a sane `TMPDIR`; `reports/round-103/gate/sentinel.md` §4.1-4.2 records
the same class. **Not fixed this round.** Note the r103 change *did* remove the dependency on one
specific directory (`/tmp/advgate`) — a real improvement — but did not remove the dependency on
`TMPDIR` being writable.

**9.2 A6 is still open — extensionless pointer targets are never swept.** `see
upstream/LICENSE:99999` leaves the gate **GREEN** (measured, §3.5/H6). Fold-spec item A6 was queued
and not implemented. The widened regex is behaviour-neutral on the real tree (per-file-unique sum
stays `40` for pass A), so the fix is cheap — but it is **not** in the r103 bytes. Do not cite
"A1–A4 landed" as "all pointer gaps closed".

**9.3 A4's mixed case loses the third state.** BLOCKED **and** another check failing prints
`GATE RESULT: FAIL` / exit 1 (`run_gate.sh:335` guards `exit 2` with `[ "$FAILS" -eq 0 ]`). Recorded
at `gate/README.md:211`. Read the `STEP=BLOCKED` line, not the summary.

**9.4 `gate/README.md` pins a `POINTERS` value the tree has already passed.**
`grep -oE 'POINTERS=[0-9]+' "$SUB/gate/README.md"` → one `87` (a stale r102 line) and four `101`,
and the live run prints `101` — so at 18:43Z the pin **agrees**. That agreement is incidental, not
structural: the count moved `88 → 101` on prose edits alone (§2) and will move again the moment
anyone edits a backticked path in the subtree or in `reports/round-103/**`. The README says the
count is "a measurement, not a contract" and names its scanner sha (`577c8b54`), so it is
self-consistent — but **`reports/round-103/b2/corrections.md` §3.4 ruled `gate/README.md` as FAIL
(drift)** when the pin was `98` against a live `100`/`101`, and the CHECK 2 prose still described
the pre-A4 "exits 1" behaviour at the time that ruling was written (it has since been rewritten to
the BLOCKED/exit-2 text). **Re-read `gate/README.md`; trust neither this file nor that ruling.**
Record the drift class; do not repair it inside this protocol.

**9.5 A7/A8 (r102 false-pass classes) survive unchanged.** A shadowing `sha256sum` and a
failing/absent `comm` are guarded only for presence, not integrity, so the r102 false-PASS classes
are still reachable under an adversarial `PATH`; `reports/round-103/gate/sentinel.md` §5-6 records
them. Treat a green gate as *indicative* when the invocation `PATH` is not the system default.

**9.6 The `three/README.md` repair landed inside a HARD-RULES-protected tree.** It is substantively
correct (that README is excluded from `seed_digests()` — verified: the map's `three/` keys are only
`r94vendor/three.core.js` and `r94vendor/three.module.js`, and `run_battery.py`'s copy loop skips
`three`), but the scope question is unruled and `reports/round-103/seats-ledger.md`'s "protected
paths untouched" verdict predates it (`…/b2/postgrep.md` §4.1). The L1 must rule it explicitly at
close rather than let step 6.1 absorb it silently.

**9.7 `phys3d_joints_free_ops` is a timeout, not a marker.** The standing ledger frames the battery
reds as the `r94_cannon` marker class; that covers 13 of the 14. The 14th needs its own triage
(`reports/round-103/r103-distiller.md` §N3, `…/physics/investigate.md`). **No repair is proposed or
owed.**

**9.8 No Unreal runtime claim is available anywhere in this round.** Unreal Editor is not installed
on this host; live-MCP behaviour is unproven by construction. A green gate is **not** evidence of
live-editor behaviour and must never be cited as such. Re-affirm with:

```sh
which UnrealEditor 2>/dev/null || echo "no UnrealEditor on PATH"
ls ~/UnrealEngine 2>/dev/null || echo "no engine tree in HOME"
```

**Expected:** `no UnrealEditor on PATH`, `no engine tree in HOME`. If either shows an editor, every
`unproven-runtime` card must be re-examined — they would no longer be justified by construction.

---

## Close-out decision rule

| gate | steps | claim | PASS requires |
|---|---|---|---|
| **G1** tree and protected paths frozen | 1 | all | close commit; ledger blobs `MATCH`; `upstream/` + `.manifest.d/` zero diff |
| **G2** gate green on the committed tree | 2 | C2 | exit 0, every pinned line matching, `NAME_SET=OK`, `UNRESOLVED=0` |
| **G3** A1–A4 implemented and falsified | 3.1–3.4 | C2 | range-tail plant RED, prose-hijack GREEN, rename RED both directions, BLOCKED exit 2 + `GATE_REF` exit 0 |
| **G4** hardening removed no detection | 3.5 | C2 | every M/H row RED except M10 and C7, which stay GREEN |
| **G5** B2 closed with the discipline | 4 | C3 | three READMEs grep `0`; repo-relative commands exit 0; dead-root forms non-zero; declaration present in `reports/round-103/b2/` |
| **G6** physics investigated, not repaired | 5 | C3 | `physics/investigate.md` present; 14 non-PASS in two named classes; isolated repro; no fixture edit |
| **G7** battery bytes untouched | 6 | C3 | fixture diff = the one intended README; aggregates equal; 146 files; `run_battery.py` triple; **zero leaked `r90bt_*`**; 350 CASES rows |
| **G8** subtree byte-pin intact | 7 | C1/C2 | 12 `OK` / rc 0, glob 24, shards 14/14, `upstream/` + `.manifest.d/` zero diff |
| **G9** C1 note landed append-only | 8 | C1 | `143 0` numstat, `Correction note` ≥ 1, cited files exist, 404/200 matrix holds |
| **G10** host reality | 9.8 | all | editor still unavailable, so `static-only` / `unproven-runtime` remain correct |

**Adjudication.** C1 is supported by G1+G8+G9. C2 by G2+G3+G4+G7+G8. C3 by G5+G6+G7. A round-close
verdict of ADMIT for an axis requires its gate set green. G7's "one intended README" clause and
§9.6's unruled scope are the **same** fact: the L1 must rule it, not the protocol.

**Status at protocol-write time (2026-10-18T18:41Z, uncommitted worktree) — measured by this seat:**

- **G2, G3, G4 — PASS** on the worktree bytes (`run_gate.sh` sha256 `577c8b54…`). All four
  hardenings verified fixed by plant; the wider battery (17 rows) detects everything except the two
  intended positives, and the one known false-PASS (H6/A6) is recorded in §9.2.
- **G5 — PASS.** Three READMEs grep `0`; repo-relative commands `0/0/0/0`; dead-root forms
  `2/2/1`; declaration in `reports/round-103/b2/corrections.md`.
- **G6 — PASS.** `physics/investigate.md` present; 14 non-PASS in two named classes; isolated
  repro reproduced twice at ~20 s; no fixture edit.
- **G7 — PASS with the §9.6 ruling owed.** Both aggregates equal, 146 files, triple correct, 350
  rows, zero `r90bt_*` leaks at the close measurement.
- **G8 — PASS.** 12/12, glob 24, shards 14/14 rc=0, pinned dirs zero diff.
- **G9 — PASS.** `143 0` append-only; note present; cited files exist; `404/200` matrix holds;
  `[[hooks]]` at 3290.
- **G1 — NOT YET.** The tree is uncommitted; the L1 must land it and re-run steps 1–2 on the
  committed SHA. **The close-out verdict must name that commit's SHA.**
- **G10 — PASS** (editor absent).

**This protocol is a snapshot, not a verdict.** The gate file was rewritten **eight times** inside
the r103 window (`412d1b84 → b5fecfc1 → ff2c26c0 → f23f3c8c → d226af6f → 0c1ca3e1 → 55a76cf8 →
577c8b54`, per `reports/round-103/gate/exit-codes.md` §1 and this seat's own re-measurement),
`adaptation-kimi.md` landed mid-round, and `POINTERS` moved `88 → 101` on prose edits alone. Every
number above was measured on the bytes named next to it. **Re-run the whole sequence on the frozen
commit and report that commit's SHA**; where a number here has moved, the re-run wins.

---

## Appendix — one-shot runner

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
SUB=corpus/knowledge/unreal-mcp; GATE=$SUB/gate/run_gate.sh
WORK=$HOME/.cache/r103-closeout; rm -rf "$WORK"; mkdir -p "$WORK"

echo "== G1 tree =="; git rev-parse HEAD; git status --porcelain
echo "== G2/G8 gate + pin =="; bash "$GATE" | grep -E '^MANIFEST_OK|^CLONE_HEAD|^PATH_|^BLOB_DIFFS|^CARDS=|^NAME_SET|^CENSUS|^POINTERS|^GATE RESULT'; echo "rc=$?"
(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK$')
echo "== G3 attacks (whole-repo copies!) =="
A="$WORK/attacks"; rm -rf "$A"; mkdir -p "$A"
fresh(){ rm -rf "$A/c"; mkdir -p "$A/c"; git archive HEAD | tar -x -C "$A/c" || exit 1; cp "$GATE" "$A/c/$GATE"; }
run(){ bash "$A/c/$GATE" > "$A/o" 2>&1; printf '%-22s rc=%s %s\n' "$1" "$?" "$(grep -E '^FAIL|^GATE RESULT' "$A/o" | head -2 | tr '\n' ' ')"; }
fresh; run M0-control
fresh; printf '\n' >> "$A/c/$SUB/upstream/README.md";                     run M1-byte-flip
fresh; rm "$A/c/$SUB/executability/materials.md";                        run M2-drop-card
fresh; printf '\nsee upstream/README.md:200\n' >> "$A/c/$SUB/README.md"; run M5-oor-pointer
fresh; mv "$A/c/$SUB/executability/sequencer.md" "$A/c/$SUB/executability/sequence-typo.md"; run M8-rename
fresh; printf '\nsee upstream/README.md:1-9999\n' >> "$A/c/$SUB/executability/materials.md"; run M9-range-tail
fresh; sed -i '4i This card is emphatically not `verified-here`; nothing was observed.' "$A/c/$SUB/executability/editor-general.md"; run M10-prose-hijack
echo "== G5 B2 =="; for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do printf '%s=%s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"; done
python3 corpus/artifacts/glb-r12/run_import.py >/dev/null 2>&1; echo "glb_rc=$?"
node corpus/fixtures/three/run_cases.mjs >/dev/null 2>&1; echo "three_rc=$?"
echo "== G6 physics =="; ls reports/round-103/physics/investigate.md
timeout 120 python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops 2>&1 | grep -E '^totals|^FAIL phys3d'
echo "== G7 battery bytes =="; git diff --stat HEAD -- corpus/fixtures/
git status --porcelain -uall -- corpus/fixtures/ ; ls corpus/fixtures | grep -c '^r90bt_'
sha256sum corpus/fixtures/run_battery.py
echo "== G9 C1 note =="; git diff --numstat HEAD -- "$SUB/adaptation-kimi.md"
grep -c 'Correction note' "$SUB/adaptation-kimi.md"
```

Record every command with its observed output. **A step whose output was not captured was not run,
and has not passed.**
