# r106 adjudicator DRAFT — admit/reject skeleton (game-dev-3d shokunin)

**Seat:** SEAT-66 ADJUDICATOR-DRAFT · round 106 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path written:** this file only. No commit, no `git` mutation, no other seat's path edited.
**Purpose:** a **draft**, not a verdict. It fixes the form of the r106 decision, states what is already measured and what is not, and names every finding the close-out must dispose of. The L1 owns the ruling, `LOG.md`, `SCORECARD.md`, and the axis rows.
**HEAD at every measurement:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (r105 report-last; work `3634bc0`). Window `2026-10-18T21:20:13Z`–`2026-10-18T21:49:22Z`.
**Upstream pin:** `a6aa73ada02a9fb1f5415bec491f9942c519b297` — `git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin.git HEAD` → that SHA, `rc=0` **[O]**.

Tags: **[O]** command run by this seat, output observed · **[D]** read from a peer artifact, not re-run · **[moving]** identity changed inside this window, or can still change · **[?]** not measured here.

**Concurrency disclosure — load-bearing.** The round was in flight for the whole window. `reports/round-106/` went from empty subdirs to peer reports while this file was being measured. Stamp every number with the hash it was taken against.

| artifact | first read | last read | note |
|---|---|---|---|
| `corpus/knowledge/engines.md` | `d03907d3…` (HEAD, 16 lines, equal to blob) | `149e61cf…` (122 lines) at `21:49:22Z` | **[moving]** rewritten mid-window; re-hash at close |
| `corpus/lessons/*.md` | 8 dirty (`r61`–`r68`) | **33** dirty at `21:44:50Z` | sweep seats still landing |
| `reports/round-106/sweep/chunk-05.md` | absent | **still absent** at `21:49:22Z` | 8 landed notes cite it |
| `corpus/fixtures/run_battery.py` | `f456bd00…` | same | unchanged **[O]** |
| `gate/run_gate.sh` | `390a25ae…` | same | protected; not edited |

---

## 0. Draft decision (for the L1 to confirm, amend, or overrule)

**`PENDING` on the r106 close commit. Not `ADMIT`. Not `REJECT`.**

Nothing measured in this window is a reject-by-construction: no Unreal runtime claim, no state-cell promotion, no protected-path write observed, runner digest unchanged. Nothing measured closes the three claims either. A bare `ADMIT` is unavailable — the findings list is the set the close must dispose of (fold, explicit carry, or reject).

**Fill `DECISION` only against §6, on the committed bytes:**

- **`ADMIT-with-findings`** if every claim's acceptance command passes and no axis is harmed. That is the only positive decision this draft will support. The round adds a citation-conformance sweep, a two-state census refresh, and a digest/receipt consistency pass. It does not close P/C, SHONEN box 1, the gate README's stale pins, or the gitignored-receipt mass.
- **`REJECT`** if any acceptance command fails, a historical count/sha/version is silently rewritten, a state cell moves without a same-round receipt, or any sentence reads a green gate or a static descriptor as Unreal editor evidence.

This draft does not assert the decision. It asserts the form, the before-counts, and the dispose-of list.

Axes in play (lane-owned): **coverage (C1)**, **depth (C2)**, **calibration (C3)**. A number is not a verdict.

---

## 1. The skeleton (fixed form — five sections)

Every adjudication in this lane since r98 uses this shape. Fill in this order.

```
# Adjudicator report — round 106 (citation sweep + engines census refresh + digest consistency)

DECISION: <ADMIT | ADMIT-with-findings | ADMIT-corr | REJECT> on <COMMIT>
          <one paragraph: what the round adds, in numbers, and what it does not close>

## Evidence And Disposition
          one bullet per claim, with the numbers and the falsification that produced them

## Findings Carried Forward
          numbered; each = {what, where, measured-by, why it matters, fold-or-accept}
          every item ends with a falsifiable acceptance command or "accept as disclosed contract"

## Fold Queue
          numbered; acceptance command per item

## Bounds And Non-Claims
          what the round does NOT prove, named explicitly
```

Invariants that must appear in the filled version, or the round fails:

- **No-editor posture.** `which UnrealEditor UnrealEditor-Cmd` → not found (`rc=2` in this seat's first probe); `ls /opt/UnrealEngine` → `No such file or directory` **[O]**. A green gate is static. `verified-here` on an Unreal card stays impossible here.
- **Byte-pin.** `upstream/` and `.manifest.d/` are read-only. Protected sweep at `21:42:54Z` printed nothing (`rc=0`) **[O]**:

```sh
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md \
  corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
  corpus/knowledge/unreal-mcp/gate \
  reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105
```

- **Fixture code stays pinned.** `run_battery.py` remains `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` **[O]**. `CASES` length is **350** (AST count) **[O]**. Fixture docs are sweepable only by their owning seat. Do not "fix" a marker by editing fixture code.
- **Two-state environment, not two counts of one run.** Default mise `v26.12.0` and pinned fnm `v24.21.0` are different PATH resolutions. Collapsing 337/350 and 350/350 into one battery score is a calibration defect.
- **Historical facts are not silently rewritten.** A path that never resolved in this repo may be re-rooted in place. A count, digest, version, or pass/fail that was true at its revision stays, with a dated note or a one-line back-pointer. `grep` of the old string hitting zero is **not** the acceptance test — notes must keep the old string.

---

## 2. C1 (coverage) — corpus citation sweep

### 2.1 Before-count, HEAD markdown under `corpus/` **[O]**

Backtick cites that look like `corpus/…` or `reports/…` paths, resolved against the worktree, on `git ls-files corpus` `*.md` (130 files):

| class | cite-instances | unique paths |
|---|---:|---:|
| resolved | (649 of 1103 backtick cites that matched the path regex) | — |
| missing, of which gitignored `corpus/live/` | **310** | most of the 249 unique misses |
| missing, other repo paths | **2** | both are truncated backticks (`corpus/artifacts/zip-r10/rea-`, `corpus/fixtures/three/run_`) — scanner false positives, not broken paths |
| missing `reports/…` | **4** | truncated `r71-` / `r72-` / `r73-` / `r77-` tokens, same class |

**Repo-relative complete paths in corpus markdown resolve.** A sweep that "repairs" 249 missing paths by deleting live-receipt cites is a silent rewrite and a **REJECT**. Those cites are the C3 class (§4), not a missing-file class.

### 2.2 The real C1 defect is the dead command root

`.shokunin/game-dev-3d` at HEAD (`git grep -l`, corpus) **[O]**: **77 lessons, 4 fixtures, 3 artifacts**. Lesson markdown line count: `git grep -n` on `corpus/lessons/*.md` → **279**.

Worktree at `21:44:50Z`, lessons only, crude split **[O] [moving]**:

| bucket | count |
|---|---:|
| files still containing the string | 70 |
| **runnable command lines outside a correction note** | **134** (57 files) |
| other mentions (notes, prose) | 133 |

Raw `grep -c` will not fall to zero, and must not be required to. The r61 diff (read by this seat) re-roots the command and **re-states the old root inside the note**. That is the right shape for a fact-preserving edit. Eight of those notes (`r61`–`r68`) cite `reports/round-106/sweep/chunk-05.md`, which **does not exist** at `21:49:22Z` **[O]**. A note whose evidence pointer 404s is not closed.

Fixture-code hits (4 paths at HEAD) are protected. They are a carry, not a C1 fail, unless a seat was assigned them and rewrote fixture code — that rewrite would itself be a reject.

### 2.3 Adversary ruling the L1 must accept or overrule **[D]**

`reports/round-106/consistency/adversary.md` (SEAT-47) argues: silent in-place fix is right for path/command conformance when the round report records before/after (S1); a dated note is mandatory when a count/digest/version was true and is now false (S2); living census files get the current value plus a one-line back-pointer, not an essay (S4).

Draft disposition: **consistent with the round charter**, which already splits mechanical path fixes from historical facts. Do not reject an in-file note that preserves a fact (r61 does not harm). Do not require every path re-root to grow an essay if the chunk report records the before/after. **Do reject** a silent change of a number, sha, or pass/fail. The L1 names which side binds; this draft does not silently absorb S1 as a license to drop notes that carry facts.

### 2.4 Draft disposition for C1

**Not closed at this frame.** Acceptance is in §6.1. Supported direction: dead command roots are being re-rooted with facts preserved. Not yet a coverage gain until the runnable-outside-note count is re-measured on the close tree and every note's `reports/round-106/` pointer resolves.

---

## 3. C2 (depth) — `engines.md` census refresh under the two-state model

### 3.1 What this seat re-probed **[O]**

| row | probe | observed |
|---|---|---|
| Godot 4.7.2 | `godot --version` | `4.7.2.stable.arch_linux.ed1daf0bf`, `/usr/bin/godot` |
| Unity | `command -v unity-editor Unity unityhub`; `ls /opt/Unity` | absent |
| Unreal | `which UnrealEditor UnrealEditor-Cmd`; `ls /opt/UnrealEngine` | absent. No runtime claim |
| three.js 0.186.1 | `node corpus/fixtures/three/run_cases.mjs` on **both** states | **3/3, exit 0, `seeds_unchanged=true`** under default `v26.12.0` and under a fresh `bash -lc` with the fnm prefix (`v24.21.0`) |
| gate (static, not an engine row) | `GATE_WORKDIR=reports/round-106/scratch/s66/gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `rc=0`, stderr 0, `MANIFEST_OK=12`, `CLONE_HEAD=a6aa73ad…`, `POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0`, `GATE RESULT: PASS`. Scanner `390a25ae…` |

Lockfile `packages["node_modules/three"].version` is `0.186.1` **[O]**. State column `partial` holds. No row may move to executable-headless beyond what it already says.

### 3.2 The landed census, verified where this seat could **[moving]**

At `21:49:22Z` the worktree file is 122 lines, sha256 `149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba`. It was `d03907d3…` / 16 lines at the start of the window. **Re-hash before citing.**

Claims in that text this seat checked, not inherited:

| claim in the worktree census | check | result |
|---|---|---|
| default full battery 337/13 at `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` | parsed JSON | **exists**; totals `350/337/13`, verdict FAIL, `seeds_unchanged=true`; **all 13 fails are `r94_cannon_*` / `exact stdout marker missing`** **[O]** |
| independent default receipt `corpus/live/runs/20261018T201215739340Z/verdicts.json` | parsed | same 337/13, same 13 cannon rows **[O]** |
| pinned full battery 350/350 | `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` | PASS, `seeds_unchanged=true`, 0 fails, runner digest `f456bd00…`, file sha `54b7140d…` **[O]** |
| Godot bounded receipt `reports/round-106/scratch/seat38/20261018T213322137930Z/verdicts.json` | parsed | `phys3d_joints_free_ops` PASS, exit 0, godot `4.7.2.stable.arch_linux.ed1daf0bf` **[O]** |
| mise node sha `caa24debe0…` / fnm node sha `7fde7b8afa…` | `sha256` of the two binaries | **both match** **[O]** |
| `Node v26.11.1` no longer presented as current | read of the diff | moved into a dated note; installed cell points at the two-state table **[O]** on the bytes read |
| Blender row | `grep -c -i blender` | **0** **[O]** |
| Unreal row | read of the diff | still `no` / `no`; green gate explicitly not a live-editor result |

The first capture `20261018T202944290389Z` is 350 row-passes and verdict FAIL / `seeds_unchanged=false` **[O]**. The census text says so. Do not cite it as the pinned PASS. That is the r105 stray-writer hazard, second sighting, still routed — not a row regression.

### 3.3 PATH prefix is not reliable in a dirty shell **[O]**

In this seat's already-hashed bash, `PATH="<fnm bin>:$PATH" node --version` returned **`v26.12.0`** and `command -v node` still pointed at mise. A fresh `bash -lc` with the same prefix returned **`v24.21.0`**, and `python3` `shutil.which("node")` under the prefix returned the fnm binary. `PINNED-ENV.md`'s documented command can lie if the shell has hashed `node`.

Draft disposition: **accept as a probe-method constraint, not a census defect**, provided every two-state receipt records `command -v node` and `node --version` from a shell that has not hashed `node` (`bash -lc`, `hash -r`, or the absolute binary). A receipt that only says "PATH was prefixed" is not evidence of `v24.21.0`.

### 3.4 Draft disposition for C2

**Direction supported, not closed.** State cells did not move, which is the correct depth result: the re-probe confirmed the census, it did not promote a row. Close must re-measure `sha256sum corpus/knowledge/engines.md` and re-parse the receipt paths on the committed bytes. A later edit that adds `verified-here` or "Unity installed" or "Unreal runtime observed" is a **REJECT**. Omitting Blender is not a reject (§5.8). Omitting the `v26.11.1` back-pointer, or presenting that string as the live default, fails §6.2.

---

## 4. C3 (calibration) — lesson numeric / digest consistency

### 4.1 What the naive scanner must not be cited as **[O]**

Paragraph-local pairing of any 64-hex string with any nearby path, on 92 lesson files at ~`21:28Z`: `sha_quoted_near_path=317`, `matched_live=2`, `mismatch=17`, `sha_path_unresolved=298`. The 17 "mismatches" include false pairs (`f456bd00…` next to `corpus/.gitignore` in `r22-unreal-review.md` — that digest **is** `run_battery.py`, confirmed live). **Do not put 17 in the verdict.** An unattributed sha-vs-any-path count is not a counting command.

### 4.2 Receipt cites — the real calibration mass **[O] [moving]**

Same scan: `corpus/live/runs/<ts>` cites in lessons → **present 1, absent 194**. Absent without a `correction note` in the file: **173 cites, 65 files**. Absent with a note: 21. Files containing `correction note` (case-insensitive): **11** at that instant; the set is growing.

`corpus/lessons/r23-ortho-review.md`: `grep -c -i 'correction note'` → **0** at `21:49:22Z` **[O]**. Three cited receipts still absent:

```
corpus/live/runs/20261013T053632289732Z
corpus/live/runs/20261013T054038500246Z
corpus/live/runs/20261013T054038500353Z
```

Carried since r102 F2b. `corpus/live/` is gitignored (`corpus/.gitignore`). Absence from a clone is expected. A cite with no dated note is not resolvable. That is the C3 defect, not a reason to delete the cite.

### 4.3 `SKILL.md` still stamps the pre-r106 census **[O]**

`grep -c d03907d3 SKILL.md` → **1**. `SKILL.md` is protected this round, so the stamp cannot be folded here. Once `engines.md` leaves `d03907d3…`, that cite is a stale live pin. The worktree census already says so. Close must not treat the SKILL stamp as the current digest.

`SHONEN.md` box 1 remains `[ ]`. This seat does not check it. `grep` of `^- \[x\]` is one box (box 2, r2 verifier). Landing `engines.md` does not promote box 1.

### 4.4 Draft disposition for C3

**Not closed.** Improved only where a touched lesson's live-claim digest matches, or an absent receipt gained a dated note that preserves the historical cite. A round text that says "corpus-wide consistency" while r23 and the residual absent-without-note set are uncounted is a **REJECT** of the calibration claim. A round text that publishes the residual count and queues it is `ADMIT-with-findings` on this axis, provided no historical number was silently rewritten.

---

## 5. Findings the close must dispose of

Format: **{finding} — {where} — {deciding command} — {draft disposition}**.

### 5.1 F1 — eight notes cite a missing chunk report **[live]**

`r61`–`r68` correction notes name `reports/round-106/sweep/chunk-05.md`. `ls` at `21:49:22Z` → no such file **[O]**. Sweep dir at that instant held `chunk-13.md`, `hygiene.md`, `province-audit.md` only.

Disposition: **fold before close.** Acceptance: every `reports/round-106/…` path named by a landed note exists, or the note is retargeted to a path that does. A 404 evidence pointer is not a correction.

### 5.2 F2 — runnable dead roots remain **[live, moving]**

134 runnable `.shokunin/game-dev-3d` command lines outside notes, 57 lesson files, at `21:44:50Z` **[O]**. Fixture-code hits (4 paths at HEAD) are protected.

Disposition: **C1 acceptance is the runnable-outside-note count on the close tree, plus a named residual.** Not `grep -c = 0`. Fixture code stays untouched.

### 5.3 F3 — `engines.md` is mid-edit **[process]**

Two identities observed: `d03907d3…` (16 lines) then `149e61cf…` (122 lines). A third write may already have landed.

Disposition: **re-hash at close.** A verdict against `149e61cf…` is not a verdict against a later sha. Same trap as r104's gate moving under the adjudicator.

### 5.4 F4 — bash hash makes the documented PATH prefix select the wrong node **[live]**

Reproduced **[O]** (§3.3). `PINNED-ENV.md` does not mention `hash -r`.

Disposition: **accept as disclosed probe constraint** if close-out receipts show `command -v` from a clean shell or the absolute binary. Do not add a fixture-code workaround. A one-line note in `PINNED-ENV.md` is SEAT-17's file if anyone's; this seat does not edit it.

### 5.5 F5 — r23 absent receipts, still no note **[carried since r102]**

§4.2. Disposition: **fold with a dated note of the r22 shape, or name it in the residual queue with the three paths verbatim.** Silent deletion of the cites is a reject.

### 5.6 F6 — gitignored receipt mass **[carried, not this round's silent fix]**

173 absent cites / 65 files without a note, at the scan instant **[moving]**. Disposition: **queue with the counting command. Do not require every historical lesson to grow a note this round** unless the claim text says corpus-wide closure — in which case the residual must be counted in the verdict, not implied fixed. Deleting cites to make the scanner green is a reject.

### 5.7 F7 — gate README pins a superseded scanner **[protected, cannot fold]**

Live scanner `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` **[O]**. `gate/README.md` still contains `e5521304` (5) and `577c8b54` (2). `POINTERS=101` remains in 2 cells; live run prints `POINTERS=103` **[O]**. Gate tree is protected this round.

Disposition: **carry. Do not edit.** Binding invariant remains `UNRESOLVED=0`. Cite `POINTERS` only with the scanner hash. A close sentence that says the README pin equals the live scanner is false.

### 5.8 F8 — Blender 5.2.1 is installed and unlisted **[queue, not a reject]**

`blender --version` → `Blender 5.2.1 LTS` **[O]**. `corpus/fixtures/bpy_battery.py` exists. `engines.md` blender hits: **0**. The census judgment queue (bytes read) refuses a `cannon-es` row and does not mention Blender.

Disposition: **accept as disclosed incompleteness relative to r79's measured runtime, not a failed re-probe of the four existing rows.** A sentence that calls the census complete for every installed engine is false. Adding a Blender row without a same-round bounded receipt would be a reject (promotion rule).

### 5.9 F9 — P/C precedence still open **[carried, operator]**

Six cards still reject `` `unproven-runtime` `` (`grep -rl` → 6) **[O]**. Gate census remains `12/1/0`. r105 left the ruling with the operator. This round's charter does not apply it.

Disposition: **carry. Do not read `CENSUS … EXPECTED=12/1/0 STEP=PASS` as semantic coherence.** Applying a relabel to the byte-pinned subtree this round is out of scope and a reject if it happens.

### 5.10 F10 — `SKILL.md` engines stamp will be stale **[protected]**

§4.3. Disposition: **carry.** Acceptance at a later round: the live pin matches `sha256sum corpus/knowledge/engines.md`, and `d03907d3…` survives only as a dated historical stamp.

### 5.11 F11 — two battery totals, one runner **[must be cited by receipt]**

Default **337/350** (13 cannon marker fails) and pinned **350/350** (`seeds_unchanged=true`) are both real **[O]**. `battery_rc` is non-zero whenever any row fails; a green battery is not the C2 acceptance condition on the default state.

Disposition: **the verdict names both receipts by path.** A bare `350/350` without "pinned env" is the count-written-into-prose defect.

### 5.12 F12 — SHONEN box 1 stays open **[promotion gate]**

Not this round's claim. A dispatched seat cannot check it. Disposition: **leave `[ ]`.**

---

## 6. Acceptance commands (the close runs these; this draft does not pre-pass them)

### 6.1 C1 — coverage

```sh
# runnable dead roots outside a note — expect a named residual, not necessarily 0
# re-run the split on the close tree; record files and the residual list
python3 - <<'PY'
import pathlib, re
pat=re.compile(r'\.shokunin/game-dev-3d')
run=re.compile(r'(python3|node|bash|npm|uv run|git show|git archive)')
cmd=note=0
for p in pathlib.Path('corpus/lessons').glob('*.md'):
    in_note=False
    for l in p.read_text(errors='replace').splitlines():
        if 'orrection note' in l: in_note=True
        if not pat.search(l): continue
        if run.search(l) and not in_note: cmd+=1
        else: note+=1
print('runnable_outside_note', cmd, 'other', note)
PY

# every r106 evidence pointer in a lesson note resolves
python3 - <<'PY'
import pathlib, re
root=pathlib.Path('.')
bad=[]
for p in root.glob('corpus/lessons/*.md'):
    t=p.read_text(errors='replace')
    if 'r106' not in t: continue
    for c in re.findall(r'reports/round-106/[A-Za-z0-9_./+-]+', t):
        c=c.rstrip('.)`')
        if not (root/c).exists(): bad.append((p.name,c))
print('unresolved', len(bad))
for row in bad: print(row)
PY
```

Pass: `unresolved=0`. `runnable_outside_note` is either 0 or printed as a named residual the verdict queues. Fixture code under `corpus/fixtures/` is unchanged (`git diff --name-only HEAD -- corpus/fixtures` empty except a doc the owning seat was assigned). No historical count/sha removed without a dated note in the same file.

### 6.2 C2 — depth

```sh
sha256sum corpus/knowledge/engines.md corpus/fixtures/run_battery.py
# runner must still be f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
# engines.md must not present "Node v26.11.1" as the current default
python3 - <<'PY'
import pathlib, re
t=pathlib.Path('corpus/knowledge/engines.md').read_text()
# current-cell test: the installed three.js cell (the table row) must not
# contain the old host string except inside a blockquote correction note
print('file_mentions', t.count('v26.11.1'))
print('rows', len(re.findall(r'^\| (Godot|Unity|Unreal|three)', t, re.M)))
PY
# receipt paths named in the Godot / two-state table must exist and parse
# to the totals the cell states. Re-parse; do not copy this draft's numbers
# if the file moved.
test ! -x /opt/UnrealEngine && ! command -v UnrealEditor
```

Pass: four rows; installed/headless cells unchanged (`yes/yes`, `no/no`, `no/no`, pin `0.186.1` / `partial`); `v26.11.1` only inside a dated note; every receipt path the file cites exists and its `totals` match the sentence; no `verified-here` on Unreal; runner digest unchanged. Both node states recorded with `command -v` from a clean shell.

### 6.3 C3 — calibration

```sh
# r23 either gained a dated note or is named in the residual queue
grep -c -i 'correction note' corpus/lessons/r23-ortho-review.md
# residual absent receipts without a note — publish the count, do not hide it
python3 - <<'PY'
import re, pathlib
live=re.compile(r'corpus/live/runs/(\d{8}T\d+Z)')
note=re.compile(r'correction note', re.I)
absent=0; files=set()
for p in pathlib.Path('corpus/lessons').glob('*.md'):
    t=p.read_text(errors='replace')
    miss=[m.group(0) for m in live.finditer(t) if not pathlib.Path(m.group(0)).exists() and not pathlib.Path(m.group(0)+'/verdicts.json').exists()]
    if miss and not note.search(t):
        absent += len(miss); files.add(p.name)
print('absent_cites_without_note', absent, 'files', len(files))
PY
# protected stamp — expect stale, must be disclosed not "fixed"
grep -c d03907d3 SKILL.md
```

Pass: the verdict prints `absent_cites_without_note` and either folds r23 or lists its three paths. No lesson diff replaces a historical digest with the live digest without a note that preserves the old digest. `SKILL.md` stale stamp disclosed, not edited.

### 6.4 No-harm (all claims)

```sh
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md \
  corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
  corpus/knowledge/unreal-mcp/gate corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd \
  reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105
# empty
sha256sum corpus/fixtures/run_battery.py
# f456bd00…
```

A non-empty protected diff is a reject regardless of claim text.

---

## 7. Fold queue (draft — ordered)

1. **F1** — land or retarget `chunk-05.md` before any note cites it. Acceptance: §6.1 `unresolved=0`.
2. **F3** — freeze `engines.md`; re-hash; re-parse cited receipts. Acceptance: §6.2 on that sha.
3. **F2** — finish runnable re-roots or publish the residual file list. Acceptance: §6.1 count plus the list.
4. **F5** — r23 dated note, historical cites verbatim. Acceptance: note present, three paths still in the file.
5. **F6** — residual absent-receipt count in the verdict. Acceptance: §6.3 number appears in the adjudication text.
6. **F7, F9, F10, F12** — carry, do not fold. Acceptance: the verdict names each as open and does not claim it closed.
7. **F4** — disclose the hash-trap next to any pinned-env command. Acceptance: one sentence plus `command -v` in the receipt.
8. **F11** — both receipts by path. Acceptance: the verdict contains both paths and does not print a bare `350/350`.

---

## 8. Bounds and non-claims

- **No live-editor evidence exists or can exist on this host.** Re-confirmed this window **[O]**.
- **A green gate is static.** This seat's run: `POINTERS=103 UNRESOLVED=0` at scanner `390a25ae…`, `GATE_WORKDIR` under `reports/round-106/scratch/s66/gate`, not `/tmp`. It does not prove plugin load, UBT, or the editor.
- **`POINTERS` is scanner-relative.** README still says 101 in two cells. Binding invariant is `UNRESOLVED=0`.
- **337/350 and 350/350 are different states.** Default fails are the 13 cannon marker rows, not fixture drift. Pinned PASS is the rerun receipt, not the `seeds_unchanged=false` first capture.
- **`battery_rc≠0` is expected on the default state.** Do not demand a green default battery.
- **C1 is not "249 missing paths fixed".** Those misses are gitignored receipts plus truncated backticks. The coverage move is command-root conformance.
- **C2 did not promote a row.** Confirming Godot/three.js and re-confirming Unity/Unreal absence is a depth refresh only if the receipts are in the committed census. It is not a new engine.
- **C3's 17 "sha mismatches" are not a finding.** The pairing was unattributed. Do not repair from that list.
- **P/C is not closed. SHONEN box 1 is not closed. Gate README pins are not folded.**
- **This draft is not the verdict.**

---

## 9. Reproduce (this seat's evidence)

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD
# 0cc3f4162f8c319f8d01a69a174fe939f36701bd

sha256sum corpus/fixtures/run_battery.py
# f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f

# two-state node — use a fresh shell; a hashed bash lies
node --version
# v26.12.0  (mise)
bash -lc 'PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node && node --version'
# …/installation/bin/node
# v24.21.0

godot --version
which UnrealEditor UnrealEditor-Cmd; ls /opt/UnrealEngine
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin.git HEAD

# gate, not /tmp
mkdir -p reports/round-106/scratch/s66/gate
GATE_WORKDIR="$PWD/reports/round-106/scratch/s66/gate" \
  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
# GATE RESULT: PASS  POINTERS=103 UNRESOLVED=0  rc=0
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
# 390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf

# both battery totals
python3 -c 'import json; d=json.load(open("corpus/live/runs/20261018T201215739340Z/verdicts.json")); print(d["totals"], d["verdict"])'
python3 -c 'import json; d=json.load(open("reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json")); print(d["totals"], d["verdict"], d["seeds_unchanged"])'

# three.js both states (this seat)
node corpus/fixtures/three/run_cases.mjs
bash -lc 'PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_cases.mjs'

grep -c -i "correction note" corpus/lessons/r23-ortho-review.md
# 0 at 21:49:22Z
ls reports/round-106/sweep/chunk-05.md
# absent at 21:49:22Z
```

Gate transcript this seat captured: `reports/round-106/scratch/s66/gate.stdout` (stderr 0 bytes). That scratch dir is measurement residue, not a second report.

---

## 10. Files this seat wrote

- `reports/round-106/r106-adjudicator-draft.md` — this file.
- Scratch only, not a deliverable: `reports/round-106/scratch/s66/gate.stdout` and `gate.stderr` (the gate capture above).

No commit, push, checkout, or reset. No protected path written. No `corpus/` byte written by this seat.
