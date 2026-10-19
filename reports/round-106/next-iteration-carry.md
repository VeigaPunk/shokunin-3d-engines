# r106 SEAT-118 — next-iteration carry (r107–r139)

**Axes:** coverage (the open set is listed, not dropped), depth (each primary row re-derived on the live tree), calibration (a proposal, a green total, or an empty directory is not a ruling).

**Use:** before r107–r139 claims any row below closed, re-run that row's acceptance command and paste the output. A later battery PASS, a gate PASS, or `r90bt_*` count 0 is not a close.

**Frame:** `2026-10-18T21:56:35Z`. Lane HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last; work `3634bc0`). This seat wrote this file only, plus scratch under `reports/round-106/scratch/seat118/`. No commit, push, checkout, or reset. No protected path edited. **No Unreal runtime claim.** `command -v UnrealEditor` → absent, rc 1.

Tags: **[O]** command this seat ran · **[C]** peer or historical artifact, not re-executed · **[P]** proposal, not a ruling.

---

## 0. Status line (grep this)

```text
CARRY_PC=PENDING
CARRY_OPERATOR=PENDING
CARRY_JOLT=UNCONFIRMED
CARRY_WRITE_ISOLATION=NO_GUARD
```

LOG already routes these four at `LOG.md:1456-1464` (`ROUTED (r106+)` / `L0`). r105's close still says the P/C ruling is open by design, the empty-jolt curiosity is uninvestigated, and there is no live-editor claim (`reports/round-105/r105-report.md` L1 adjudication). This file is the r107–r139 reminder. It does not apply any of them.

---

## 1. P/C ruling — PENDING

Two label vocabularies still overlap. `SKILL.md` heading `## 4. The open precedence ruling (state it, do not resolve it)` still says **the P/C precedence ruling is still owed** and is not the skill file's to make. Until an operator ruling lands, the binding text is that section's own interim: a claim on one of the six dissenting subsystems stays `static-only` and must cite the card; `unproven-runtime` is used only where a runtime path is identified.

**[O] live census, not a ruling.** Parser copied from `reports/round-105/pc/ruling-draft.md` (five declaration shapes), run at `2026-10-18T21:44:35Z`:

```text
COUNTS static-only=12 unproven-runtime=1 verified-here=0 total=13 missing=0
```

`unproven-runtime` is `actors-scene.md` line 5. The other twelve cards are `static-only`. Dissent marker `Not \`unproven-runtime\`` is still exactly these six:

```text
animation-controlrig.md
blueprints.md
editor-general.md
gameplay-gas.md
materials.md
meshes-textures.md
dissent_count=6
```

```text
sha256sum corpus/knowledge/unreal-mcp/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721
git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability
pc_source_diff_rc=0
```

Gate constants, read not re-run: `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0` (`corpus/knowledge/unreal-mcp/gate/run_gate.sh:78-80`). A gate PASS checks that census. It does not choose the semantic rule.

**The packet is not one proposal.** Do not collapse these:

| artifact | sha256 this seat | what it asks | status |
|---|---|---|---|
| `reports/round-105/pc/ruling-draft.md` | `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30` | policy-first, keep 12/1/0 | proposal |
| `reports/round-105/pc/distiller.md` | `8e714525fa02b65e111e3e24809817eeea1a2f531ca155aa844923c24669c797` | later synthesis; r105 reviews scored older distiller hashes | not a same-hash approval |
| `reports/round-105/operator-package.md` | `83124766c85c14c381cb8c41c50fe5c15ce2ea2dfed37658e642c1e97a967d3a` | one-read decision request | not a ruling |

`git status --short` on those three files was empty; distiller blob `HEAD:` is `19a08a967b6feae6f9a49eceb1cbe97ade964e29`. The r105 report's own close says reviews scored moving proposal hashes. **Do not count those reviews as approval of the committed distiller.**

**[C]** same-round corroboration, not this seat's verdict: `reports/round-106/pc-carry.md` was present (152 lines) at `21:56:35Z` and records the package untouched. Re-read it; do not treat this sentence as a substitute for its evidence.

**Must not (r107–r139):**

- Edit `corpus/knowledge/unreal-mcp/README.md`, any executability card, `upstream/`, `.manifest.d/`, or the gate to "resolve" P/C. The subtree is byte-pinned. A lane seat does not own that edit.
- Flip the six dissent cards to make a headline census look consistent. The rejected flip path changes the gate census (ruling-draft names `6/7/0`). That is a different change set, not a cleanup.
- Treat `static-only` as binary `proven` for subsystem behavior, or write `verified-here` on an Unreal card. No editor is installed.
- Quote a bare `POINTERS=` number as if it were the ruling. Pointer counts are scanner-relative. This seat did not re-run the gate.

**Close (all required):** an operator answer recorded as a new LOG entry (append, never a rewrite of r101–r105) naming P, C, or an explicit hybrid; three independent reviews of that same proposal/diff hash; then, and only then, an authorized subtree edit whose post-change gate keeps `UNRESOLVED=0` and whose census matches the chosen branch. Until that LOG line exists, `CARRY_PC` stays `PENDING`.

---

## 2. Operator items — PENDING

r101's three questions are still the text at `reports/round-101/r101-report.md:338-341` **[O]** (`python3` print of those lines, `21:44:35Z`):

1. Link an Epic Games account to GitHub so `EpicGames/UnrealEngine` source becomes fetchable?
2. Authorize pulling the public `wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB, contents unverified) as a possible runtime unlock?
3. Prefer the Lutris/Epic-launcher path instead?

r105 added a fourth, and it is not a substitute for the first three (`LOG.md:1463-1464`): **which side of the P/C precedence ruling binds?** That is §1. Do not mark L0 clear because only one of the four has a package.

**[O]** `command -v UnrealEditor` → absent, rc 1, at `21:35:05Z`. This seat did not run `docker images`, did not start Lutris, and did not `git ls-remote`. Absence of the editor is measured. Image-not-pulled and account-not-linked are inherited from the unanswered L0, not re-probed.

Upstream pin, local only: `corpus/knowledge/unreal-mcp/gate/run_gate.sh:73` is `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297`. `git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` → `subtree_diff_rc=0`. `upstream/` is not a git checkout (`rev-parse` not run). Freshness against the remote is SEAT-73's job this round; do not move the pin because a later `ls-remote` differs until the operator accepts a re-pin.

**Node v24 is not an open operator question anymore.** Do not re-ask "install node 24." **[O]** `node --version` → `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`. The pinned binary `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version` → `v24.21.0`. r105's ruling is shadowing, not absence. The 13 `r94_cannon_*` rows still fail under the default PATH and pass under the fnm prefix. Do not re-baseline those markers, and do not call the default-PATH red a fixture drift.

**Must not:**

- Any indicative Unreal-side effect, any `verified-here` card, any "editor would" sentence.
- Pull the image, link an Epic account, or fetch `EpicGames/UnrealEngine` as if a seat were the operator.
- Cite `reports/round-105/operator-package.md` §2's "350/350 under Node 24 remains the acceptance bar and is not claimed here" as the current battery fact. That sentence is an assembly-time snapshot. The accepted receipt is below. Do not silently rewrite the package (it is a frozen r105 artifact).

**Close:** a new LOG line that quotes the operator's answer per question. Unanswered questions stay on the L0 list. Static-only work proceeds without them; it must keep saying so.

---

## 3. Jolt class — UNCONFIRMED

**Name the class, or a later round will "fix" the wrong thing.** r103 ruled `phys3d_joints_free_ops` as harness wall-cost (21 serial boots vs a 20 s cap). r104 closed that class with concurrent spawn. The empty-jolt curiosity is a **different class**. r105's close still calls it uninvestigated. Closing the timeout did not close this.

**What §5.1 actually recorded [C]** (`reports/round-103/physics/investigate.md` §5.1): one direct clean run emitted a marker in which `freeb_world@jolt` and `detachb_free@jolt` were empty (`rc=0,m=`) and three Dummy cells said `engine=DEFAULT` instead of `engine=Dummy`, and that run was reported as matching the pinned marker (3921 chars). The investigator did not promote it, and said it is not part of the timeout classification. Hint given there: the per-child `project.godot` write can occasionally be read empty. Candidate explanations the r106 jolt seats were assigned to separate: (a) real Jolt behavior, (b) log-capture race under concurrency, (c) benign marker artifact.

**[O] the live pin does not contain that artifact.** Extracted the `phys3d_joints_free_ops` marker from `corpus/fixtures/run_battery.py` at `21:53:53Z`:

```text
len 3921
sha256 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
empty_jolt_count 0
freeb_world@jolt head=rc=0,m=M0 case=freeb_world engine=Jolt Physics|...
detachb_free@jolt head=mode_ok=1,m4=e260e2a3c6282b25
```

That sha is the identity r104 preserved (`706ad915…`, 3921 bytes). A marker with empty `freeb_world@jolt` / `detachb_free@jolt` cells **cannot** be byte-equal to this pin. So §5.1's "empty cells, yet matched the pin" is in tension with the pin it claims to have matched. Do not remember the class as "the pin accepts empty cells." Remember it as an unconfirmed single sample that contradicts the pin unless a later seat shows the note was about child logs rather than the aggregated marker, and prints both.

**The scheduler under the fixture changed; the marker did not.** `phys3d_joints.gd` `_spawn_child` is the r104 R3 concurrent path (`OS.create_process`, comment at the function). The r103 sample was serial `OS.execute`. A post-r104 PASS does not reproduce that sample's scheduler. A failure to see empty cells on the concurrent path does not erase the historical note. Fixture sha this seat: `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` (same digest r105 physics-carry recorded for the r104 fix). `git diff --stat` on that file was empty.

**r106 investigation had not landed at this read.** At `21:56:35Z`:

```text
ABSENT reports/round-106/jolt/investigate.md
ABSENT reports/round-106/jolt/adversary.md
ABSENT reports/round-106/jolt/ledger.md
```

`find reports/round-106/jolt -type f | wc -l` → `0` at `21:53:53Z`. Absence is not a ruling. If those files exist when a later round starts, read them and carry **their** ruled class (with the fixture hash they name). If they do not, the class is still `UNCONFIRMED`.

**Must not:**

- Re-baseline the free_ops marker to absorb empty cells.
- Treat `PASS phys3d_joints_free_ops` as a close of §5.1. PASS means the populated pin matched.
- Call empty cells "Jolt engine behavior," a capture race, or a benign artifact without a named ruling that prints marker sha, fixture sha, spawn mode, and the child logs.
- Drop the item because the wall-cost class closed in r104.

**Close:** a named ruling, one of (a), (b), (c), or "historical note contradicted by pin `706ad915…`", with the hashes above and N independent child logs. Until that file exists, `CARRY_JOLT` stays `UNCONFIRMED`.

---

## 4. Write-isolation — NO GUARD

**The class:** a fixture that materializes child projects under `res://` will dirty `corpus/fixtures/` if Godot is launched with `--path` on the seed tree, and a concurrent writer during `run_battery.py` fails the battery on `seeds_unchanged` even when every row passed. Two sightings are already on the record. No guard has landed.

**Mechanism [O], read this seat:**

- `run_battery.py` header: seeds are copied to scratch; a seed mutation fails the battery. It detects a writer. It does not prevent one. Runner sha `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, `git diff --stat` empty.
- `phys3d_joints.gd:135-143`: `_spawn_child` builds `r90bt_%s_%s_%s`, `ProjectSettings.globalize_path("res://" + dirname)`, and writes `project.godot` there. `rg` for `seed|HERE|write-isolation|refuse` in that file → no guard tokens.
- `phys3d_events.gd` `_child_prepare` refuses an empty dirname, `..`, or a path separator (`corpus/fixtures/README.md:1037-1041` describes that r89 remediation). That is a traversal guard. It still writes under `res://` of whatever project path was launched. **Do not cite the events guard as the joints isolation fix.**

**Sightings [C], receipts re-parsed [O]:**

- r103 `investigate.md` §5: a reused scratch that already contained `r90bt_*` changed the marker. Fresh copies were required.
- r105 first pinned full run, `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json`: `verdict=FAIL`, `seeds_unchanged=False`, `totals={'cases': 350, 'pass': 350, 'fail': 0, ...}`. Row-green is not battery-green. The close attributes this to a concurrent seat's mid-run fixture write (second sighting).
- Accepted rerun, `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`, sha256 `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`, same digest as `corpus/live/runs/20261018T204240718894Z/verdicts.json`: `verdict=PASS`, `seeds_unchanged=True`, `totals pass=350 fail=0`.

**Live surface is clean, and that is not a fix [O]** (`21:35:05Z`):

```text
r90bt_under_fixtures=0
```

**Must not:**

- Treat `find corpus/fixtures -name 'r90bt_*'` count 0 as a closed item.
- Run `godot --path corpus/fixtures` or `--path .` from the seed tree. Scratch belongs under `reports/round-N/scratch/` or `$HOME`, never a big clone in `/tmp`.
- Read `seeds_unchanged=false` as a broken row. Name the writer, then rerun on a quiet tree. The r105 LAW is: a mid-run seed change means a concurrent writer, not a broken case.
- Edit `corpus/fixtures/phys3d_joints.gd` or `run_battery.py` from a sweep, citation, or carry seat. Fixture code stays protected until an authorized seat owns the guard.
- Use the events dirname check as proof the class is fixed.

**`/tmp` is not clearance.** At `21:56:35Z` a 1-byte write to `/tmp/seat118-quota-probe` succeeded and was removed. r103/r104 showed the per-user quota rejects writes while `df` still shows free space, and it is intermittent. Gate default is still `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` (`run_gate.sh:59`). Close-out gate runs set `GATE_WORKDIR` to a roomy path under the home directory or `reports/round-N/scratch/`.

**Close:** a fail-closed guard, demonstrated rather than described: launching the joints fixture with its project path inside `corpus/fixtures/` either refuses or writes no `r90bt_*` under the seed (`find` count 0 before and after), and a battery run on a quiet tree keeps `seeds_unchanged=true`. A concurrent-writer test, or an explicit harness rule that fails the run when a second writer appears, is part of the close. Until that demonstration exists, `CARRY_WRITE_ISOLATION` stays `NO_GUARD`.

---

## 5. Also do not drop

These are not the four named rows. They are the adjacent routed set a later round will lose if it only remembers the headline. Inherited items are marked. Do not upgrade them.

| item | status this seat | do not |
|---|---|---|
| Two-state battery | **[O]** pinned receipt PASS 350/350 `seeds_unchanged=True` (sha above). **[O]** `corpus/live/runs/20261018T201215739340Z/verdicts.json` is `verdict=FAIL`, `seeds_unchanged=True`, `pass=337` `fail=13`, and all 13 names are `r94_cannon_*`. That JSON has no node field; default-v26 attribution is the r105 package plus this seat's live `node --version`, not a string inside the file. | Collapse 337 and 350 into one total. Do not call 337 a regression of the pinned profile. |
| Mixed `BLOCKED`+`FAIL` | **[O]** `run_gate.sh:436` still requires `C2_BLOCKED=1 && FAILS=0` before exit 2. Not executed. | Claim the third state is preserved. A green gate did not exercise the mixed case. |
| Gate scratch | **[O]** default `WORK_ROOT` still falls through to `/tmp`. 1-byte `/tmp` write succeeded this instant. | Put clones or battery scratch on `/tmp`. |
| No Unreal runtime | **[O]** editor absent. | Let a static gate PASS or a card census stand for editor behavior. |
| Pin `a6aa73ad…` | **[O]** gate constant matches; subtree diff rc 0. Remote freshness not run. | Re-pin from a seat. |
| Row-F non-author replay | **[C]** `LOG.md:1458` still routes it. Not re-checked. | Let the author of a fixture-runtime claim be the verifier. |
| No checkout anywhere | **[C]** r105 recorded a verifier `git checkout` in an isolated clone. Templates now forbid checkout anywhere. | `git checkout` / `reset` even in `/dev/shm` or a worktree "just to read HEAD". |
| Citation discipline | **[C]** r103/r104 laws: bare line numbers rot; a count needs its scanner; corrections are dated notes, not silent rewrites. | Rewrite a historical lesson sentence because the live tree moved. Append a dated note. |
| Protected bytes | **[O]** scoped `git status --short` on `LOG.md` `SCORECARD.md` `SHONEN.md` `PROVINCE.md` `SKILL.md` and `reports/round-101`…`105` was empty at `21:35:05Z`. | Write those paths from a carry seat, or from any r106 seat that does not own them. |

---

## 6. What this seat did not do

- Did not run Godot, the battery, or the gate. Jolt status is a pin extraction plus the historical note, not a new 5× reproduction. SEAT-49/50/51 own that run.
- Did not apply a P/C ruling, a fixture guard, or an operator decision.
- Did not `ls-remote`, pull an image, or claim the Epic account state beyond "UnrealEditor is not on `PATH`."
- Did not edit `corpus/`, `SKILL.md`, `LOG.md`, or any prior round report.

Peer files present at `21:56:35Z` and not authored here: `reports/round-106/pc-carry.md`, `reports/round-106/operator-package-carry.md`. Re-read them before citing them; they can move after this stamp.

---

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD
# P/C
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l   # 6
sha256sum corpus/knowledge/unreal-mcp/README.md
rg -n 'The P/C precedence ruling is still owed' SKILL.md
# operator
command -v UnrealEditor; echo rc=$?
rg -n '^PIN=' corpus/knowledge/unreal-mcp/gate/run_gate.sh
node --version
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version
# jolt pin (no Godot)
python3 - <<'PY'
import hashlib, re, pathlib
text = pathlib.Path('corpus/fixtures/run_battery.py').read_text()
m = re.search(r'\("phys3d_joints_free_ops".*?\'(PASS phys3d_joints free_ops .*?)\'\)', text, re.S)
marker = m.group(1)
print(len(marker), hashlib.sha256(marker.encode()).hexdigest())
print('empty', len(re.findall(r'\{rc=0,m=\}', marker)))
PY
# isolation
find corpus/fixtures -name 'r90bt_*' | wc -l
rg -n 'globalize_path\("res://' corpus/fixtures/phys3d_joints.gd
# receipts
python3 - <<'PY'
import json
from pathlib import Path
for p in [
  'reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json',
  'reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json',
  'corpus/live/runs/20261018T201215739340Z/verdicts.json']:
    d = json.loads(Path(p).read_text())
    print(p, d['verdict'], d['seeds_unchanged'], d['totals'])
PY
```

Scratch receipts from this seat: `reports/round-106/scratch/seat118/probe.txt`, `probe2.txt`.
