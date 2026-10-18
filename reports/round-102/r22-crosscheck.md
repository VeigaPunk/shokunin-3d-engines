# r102 · SEAT-29 · R22-CROSSCHECK — every repaired r22 command re-run against the real fixtures

**Seat:** SEAT-29 (R22-CROSSCHECK) · round 102 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · **HEAD:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work `1659c036`)
**Runtime of the measurements below:** 2026-10-18T17:44–17:58Z
**Writes:** this file only. Nothing under `corpus/` was written by this seat.

**Question this seat answers:** after the r102 repair seats landed, do the repaired r22 commands
*still work* against the actual fixtures (`Headless3DFixture.uplugin` + `verify_descriptor.py`), do the
descriptor and control still validate, do byte counts still match the repaired README, and did any
repair **break the fixture story**?

**Verdict up front: the fixture story holds.** Every r22 *descriptor/three.js* command re-runs
clean on the current worktree (all exit 0); the positive descriptor is accepted and the paired
control is rejected; the descriptor and control bytes are **untouched** by every r102 repair. The
fourth command in the lesson block — the shared Godot battery — exits 1, for two pre-existing
host conditions with no connection to r22 or to any r102 repair (§8). Four flags are raised in §6 —
none is a fixture regression; two are citation drifts already addressed by the repaired lesson's own
dated correction note, and two are reported for seats that own the files.

---

## 1. The repaired r22 commands, re-run

Command block as it now stands in `corpus/artifacts/unreal-r22/README.md:8-9` and
`corpus/lessons/r22-unreal-review.md:23-27` (both re-rooted to repo-relative form by the F1a/F1b
repairs). Run from the lane repo root:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "exit=$?"
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unreal-r22/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
exit=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "exit=$?"
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
exit=0

$ node corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0

$ node corpus/fixtures/three/scene_graph.mjs; echo "exit=$?"
PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true
exit=0
```

The pair **still discriminates**: the same checker accepts the source and rejects the control, and
the two runs are not the same code path — the rejection reason (`unsupported module Type: 'Unknown'`)
is produced by the `MODULE_TYPES` membership test, not by a parse error.

### 1.1 The defect is real, and the fix is load-bearing (clean-tree control)

An "it exits 0 in my worktree" claim is weak, because the worktree is where the repair was made.
The strong form: take the *committed* tree and run the *pre-repair* command text against it.

```
$ rm -rf /tmp/r102-xcheck/head && mkdir -p /tmp/r102-xcheck/head
$ git archive HEAD corpus/artifacts/unreal-r22 | tar -x -C /tmp/r102-xcheck/head
$ ls /tmp/r102-xcheck/head/corpus/artifacts/unreal-r22/
Headless3DFixture.bad-type.uplugin
Headless3DFixture.uplugin
README.md
verify_descriptor.py

$ cd /tmp/r102-xcheck/head && python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py; echo "exit=$?"
python3: can't open file '/tmp/r102-xcheck/head/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2
```

The four artifact files are all present in the archive, and the command still cannot find them —
the defect was a **path root**, not a missing file. With the repaired repo-relative text the same
four files resolve and the pair exits 0/0 (§1). The fix is therefore load-bearing, not cosmetic.

---

## 2. Descriptor bytes vs the repaired README

The repaired README (F1a) changed only the two command lines (`git diff` = 2 insertions /
2 deletions, both inside the fenced `sh` block). The descriptors and the checker were not touched:

```
$ git diff --stat -- corpus/artifacts/unreal-r22/
 corpus/artifacts/unreal-r22/README.md | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

$ stat -c '%n %s' corpus/artifacts/unreal-r22/*
corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin 374
corpus/artifacts/unreal-r22/Headless3DFixture.uplugin 374
corpus/artifacts/unreal-r22/README.md 1394
corpus/artifacts/unreal-r22/verify_descriptor.py 3122

$ sha256sum corpus/artifacts/unreal-r22/*
b56a356ef3c47a4880bd22f5dbcbb2ccf43e1cb65d263498674ef9b1c586ccf0  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin
2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9  corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b  corpus/artifacts/unreal-r22/README.md
ce07e9d5c03e892b0d9847b89ec67cc6b293f0979d2f5be5a99c6a53b21cea76  corpus/artifacts/unreal-r22/verify_descriptor.py
```

The two descriptor files are byte-identical to the values the r22 lesson records
(`2543b337…` / `b56a356e…`), and `verify_descriptor.py` still hashes to `ce07e9d5…` — the checker
under test is the same checker the r22 review tested. **No repair perturbed the fixture bytes.**

---

## 3. The descriptor still validates, independently of the lane's checker

The lane checker is a *fixed-scope* validator (it enforces one exact authored sample). To make sure
the pair still carries the *documented* Unreal contract — not merely that the lane's own checker is
self-consistent — both files were re-read with a second, independent rule set built only from the
vocabulary the lesson cites (`.uplugin` is JSON; `FileVersion` required; each code module needs
`Name` + `Type`; `Type` from Epic's six documented values):

```
$ python3 - <<'EOF'
import json,pathlib
DOC_TYPES={"Runtime","RuntimeNoCommandlet","Developer","Editor","EditorNoCommandlet","Program"}
for p in ["corpus/artifacts/unreal-r22/Headless3DFixture.uplugin",
          "corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin"]:
    d=json.loads(pathlib.Path(p).read_text())
    ok_doc = isinstance(d.get("FileVersion"),int) and all(
        isinstance(m,dict) and "Name" in m and "Type" in m for m in d.get("Modules",[]))
    bad=[m["Type"] for m in d.get("Modules",[]) if m.get("Type") not in DOC_TYPES]
    print(f"{p}: doc-required-fields-ok={ok_doc} module_types_outside_documented_enum={bad}")
EOF
corpus/artifacts/unreal-r22/Headless3DFixture.uplugin: doc-required-fields-ok=True module_types_outside_documented_enum=[]
corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin: doc-required-fields-ok=True module_types_outside_documented_enum=['Unknown']
```

Both parse as JSON objects with all eight authored top-level fields; the source's module type is
inside Epic's documented enum, the control's is outside it. That is exactly the discrimination the
lesson claims, re-derived without the lane checker in the loop.

---

## 4. The control is still the same one-byte-class control

The lesson asserts the control is **exactly** `source_bytes.replace(b'"Type": "Runtime"', b'"Type": "Unknown"')`,
with only offsets 320–326 changing. Re-derived:

```
$ python3 - <<'EOF'
import hashlib,pathlib
src=pathlib.Path('corpus/artifacts/unreal-r22/Headless3DFixture.uplugin').read_bytes()
bad=pathlib.Path('corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin').read_bytes()
tok=b'"Type": "Runtime"'
print("token count in src:",src.count(tok))
print("control == src.replace(token, Unknown):",bad==src.replace(tok,b'"Type": "Unknown"'))
diff=[i for i in range(len(src)) if src[i:i+1]!=bad[i:i+1]]
print("len src/bad:",len(src),len(bad),"diff offsets:",diff)
EOF
token count in src: 1
control == src.replace(token, Unknown): True
len src/bad: 374 374 diff offsets: [320, 321, 322, 323, 324, 325, 326]
```

Token occurs once, replacement reproduces the control byte-for-byte, and the same seven offsets
320–326 change — identical to the r22 review's claim. Same byte count (374) is incidental, as the
lesson says.

The three private controls the lesson tabulates were **reconstructed from the lesson's own prose**
(not copied from its `/tmp`, which no longer exists) and each reproduced the recorded digest exactly:

```
$ python3 - <<'EOF'   # reconstruct from the lesson's stated transformations
import pathlib
s=pathlib.Path('corpus/artifacts/unreal-r22/Headless3DFixture.uplugin').read_text()
pathlib.Path('/tmp/r102-xcheck/missing-name.uplugin').write_text(s.replace('      "Name": "Headless3DFixture",\n',''))
pathlib.Path('/tmp/r102-xcheck/duplicate-key.uplugin').write_text(s.replace('      "Type": "Runtime",\n','      "Type": "Runtime",\n      "Type": "Runtime",\n'))
mod='    {\n      "Name": "Headless3DFixture",\n      "Type": "Runtime",\n      "LoadingPhase": "Default"\n    }\n'
pathlib.Path('/tmp/r102-xcheck/extra-module.uplugin').write_text(s.replace('    }\n','    },\n'+mod,1))
pathlib.Path('/tmp/r102-xcheck/editor-type.uplugin').write_text(s.replace('"Type": "Runtime"','"Type": "Editor"'))
pathlib.Path('/tmp/r102-xcheck/fv2.uplugin').write_text(s.replace('"FileVersion": 3','"FileVersion": 2'))
EOF
$ sha256sum /tmp/r102-xcheck/*.uplugin
f163a3ba1e58b04668f2a15d4dc24cece31cb73fbcb3caf96e073b9c493a7a3b  /tmp/r102-xcheck/duplicate-key.uplugin
4e1bb981665b535768522aea6583e57bcdccdf950ba4a7d5d4c862f14bb19b5a  /tmp/r102-xcheck/editor-type.uplugin
e0f73b4475cf0805c428b8a04c1d119ab82f27eb2523b644b808966590bcaa5d  /tmp/r102-xcheck/extra-module.uplugin
f2a885970ee1ccb9aa26b304883eda1efb81bd3c6219847eccb82567c354e582  /tmp/r102-xcheck/fv2.uplugin
09acc4ce50d0e5642ad6794ecb70b991fb1ed62d2e2f7f609803524c87035a7e  /tmp/r102-xcheck/missing-name.uplugin
```

All five match the lesson's table (`09acc4ce…`, `f163a3ba…`, `e0f73b44…`, `4e1bb981…`,
`f2a88597…`). Each was then run through the repaired command form:

```
$ for n in missing-name duplicate-key extra-module editor-type fv2; do
    python3 corpus/artifacts/unreal-r22/verify_descriptor.py /tmp/r102-xcheck/$n.uplugin --expect-reject; echo "exit=$?"; done
PASS local-static actual=reject expected=reject … reason=module fields missing or unexpected       exit=0
PASS local-static actual=reject expected=reject … reason=invalid JSON: duplicate JSON key: Type    exit=0
PASS local-static actual=reject expected=reject … reason=expected exactly one module object        exit=0
PASS local-static actual=reject expected=reject … reason=authored module type/loading phase mismatch exit=0
PASS local-static actual=reject expected=reject … reason=FileVersion must be 3 for authored sample  exit=0
```

Five of five still behave as tabulated, with the recorded reasons. The lesson's calibration caveat
also still holds verbatim: `editor-type` and `fv2` are **documented-legal** Unreal descriptors that
the lane's fixed-scope checker rejects on purpose — that is the local checker enforcing an authored
sample, not Unreal rejecting anything.

---

## 5. Non-interference with the byte-pinned r101 subtree and the gate

This seat ran the gate to confirm the r22 repairs did not disturb the r101 subtree story:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
GATE unreal-mcp subtree
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207
CHECK 1 manifest-byte-identity
… 12 × OK …
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0  CLONE_TRACKED=12  PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
STEP=PASS
CHECK 3 verdict-card-scan
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
exit=0
```

The gate's own hashes match the SEAT-17 author-run receipt, so this PASS covers those exact bytes:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e  corpus/knowledge/unreal-mcp/gate/run_gate.sh
def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8  corpus/knowledge/unreal-mcp/gate/README.md
```

Directly over the pinned region, the r22 repairs are a no-op:

```
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
rc=0
```

The F8 wording fold is re-derived independently rather than taken on trust, since it is the one
r102 edit inside the subtree README:

```
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 | grep -c ': OK')
24
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 >/dev/null 2>&1; echo "glob_rc=$?")
glob_rc=0
```

24 `OK` lines from the full glob, 12 from the `audit-reference.sha256` subset alone. The folded
text at `corpus/knowledge/unreal-mcp/README.md:169-170` and `:187` states exactly those two numbers
and names which command yields which, so the `:187` ambiguity (a bare "12 lines" under a sweep
heading) is resolved and the replacement numbers are true.

---

## 6. Flags — repairs and citation state at this runtime

Nothing here is a fixture regression. Both items are **citation-level**, and both are already
addressed inside the F2/F3 correction note that landed at `corpus/lessons/r22-unreal-review.md:50-56`
during this seat's run.

**FLAG-1 (resolved): the F1a README repair invalidated the lesson's byte-count table row.**
The F1a repair changed `README.md` from 1460 B to 1394 B, so the lesson's digest table row
`| README.md | 1460 | 26a12604… |` stopped describing the tree. Verified:

```
$ python3 - <<'EOF'   # lesson table vs actual
… for each of the four rows: compare lesson (bytes, sha) to the file on disk …
Headless3DFixture.uplugin          lesson=374/2543b337 actual=374/2543b337 OK
Headless3DFixture.bad-type.uplugin lesson=374/b56a356e actual=374/b56a356e OK
verify_descriptor.py               lesson=3122/ce07e9d5 actual=3122/ce07e9d5 OK
README.md                          lesson=1460/26a12604 actual=1394/1c0d3035 **STALE**
EOF
$ git show HEAD:corpus/artifacts/unreal-r22/README.md | wc -c; git show HEAD:corpus/artifacts/unreal-r22/README.md | sha256sum
1460
26a126047b7fb7671f5216313ee8938a6076a4c3de5cfd06fb11b4338c751cba  -
```

The row is not wrong — it describes the **r22 blob**, which is still exactly 1460 B / `26a12604…` at
HEAD — but read bare it looks like a claim about the file on disk. The correction note now says so
in one sentence (`:54`), naming both the old pair and the new `1394` / `1c0d3035…`. **This is the
correct repair discipline**: the historical claim is preserved and the drift is annotated, not
silently renumbered.

**FLAG-2 (resolved): the F3 stale `run_battery.py` digest.** `a065a56d…` was the r22-era blob, not
today's file. Re-derived both halves of that claim:

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py

$ for c in 490e710d 8b21cae 7804a69; do printf '%s run_battery=' "$c"; git show $c:corpus/fixtures/run_battery.py | sha256sum | cut -c1-8; \
  printf '%s run_cases=' "$c"; git show $c:corpus/fixtures/three/run_cases.mjs | sha256sum | cut -c1-8; done
490e710d run_battery=a065a56d  run_cases=f9f40d47
8b21cae run_battery=a065a56d  run_cases=f9f40d47
7804a69 run_battery=a065a56d  run_cases=f9f40d47
```

Both the lesson's `a065a56d…` (battery seed) and its `f9f40d47…` (three.js runner) are genuine
**r22-era content addresses**, reproducible from all three named commits, while the tree now carries
`f456bd00…` and `97eca1b2…`. The `scene_graph.mjs` and `package-lock.json` digests in the same
sentence still match the tree:

```
$ sha256sum corpus/fixtures/three/scene_graph.mjs corpus/fixtures/three/package-lock.json
e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af  corpus/fixtures/three/scene_graph.mjs
1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8  corpus/fixtures/three/package-lock.json
```

The lesson's correction note gets this split exactly right (battery seed and runner are era blobs;
scene source and lock still match) — confirmed line by line above.

**FLAG-3 (new, unresolved, outside this seat's ownership): a second file carries the phantom
`.shokunin/game-dev-3d/` root, and its commands are still broken.** The F1a/F1b repairs fixed
`corpus/artifacts/unreal-r22/README.md` and `corpus/lessons/r22-unreal-review.md`, but
`corpus/fixtures/three/README.md` has ten more occurrences and every one of its commands fails:

```
$ grep -c 'shokunin/game-dev-3d' corpus/fixtures/three/README.md
10
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
Error: Cannot find module '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs'
exit=1
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py; echo "exit=$?"
python3: can't open file '…/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory
exit=2
```

The same phantom root also appears in `corpus/artifacts/glb-r12/README.md:6-8`,
`corpus/artifacts/unity-r19/README.md:10-11`, and in the *evidence commands* recorded in
`SCORECARD.md:8-9` and `PROVINCE.md:25,46`. Those files are owned by other seats (and
`SCORECARD.md`/`PROVINCE.md` are lane-close artifacts this seat may not touch), so this is reported,
not repaired. It is the same defect class as F1 and the same fix (drop the `.shokunin/game-dev-3d/`
prefix); note `corpus/fixtures/three/README.md`'s commands additionally need the `npm ci --prefix`
precondition the F5 repair documented.

**FLAG-4 (cosmetic, in a peer's check string):** `reports/round-102/round-count.md` row D10 greps
for ``24 lines, all `OK` `` in the subtree README, which returns 0 — the fold actually reads
"the `*.sha256` glob prints 24". The check string is stale, the fold is correct (24 verified in §5).
Reporting only; that file is not this seat's.

---

## 7. Boundary — what this crosscheck does not show

- **No Unreal runtime claim, anywhere.** Unreal Editor and UnrealBuildTool are not installed on this
  host. Every statement above is about local static JSON checks and file bytes. Gate check 3's
  `verified-here=0` census is correct for this host and a green gate is not evidence of live-editor
  behavior.
- **The checker is not a general Unreal schema validator.** It enforces one authored field subset,
  exactly one module, `FileVersion == 3`, and `Type == "Runtime"`. It deliberately rejects two
  descriptors (`Editor` type, `FileVersion 2`) that Epic's cited guidance permits. Nothing here
  generalizes to arbitrary plugin descriptors.
- **`--expect-reject` exit 0 means an expected *local* rejection**, not Unreal rejecting anything.
- **The Godot battery is a regression control, not r22 evidence.** `corpus/fixtures/run_battery.py`
  is the lane's shared fixture; it was not modified by any r102 repair (byte-level proof:
  `reports/round-102/battery-integrity.md` §2, 146 tracked fixture files, 0 byte-mismatches vs HEAD).
  Its result is recorded below as a load/health datapoint only.
- **The three.js 3/3 result does not cover the F5 clean-tree precondition.** `node_modules/` is
  gitignored, so on a fresh `git archive` the bare `node …run_cases.mjs` exits 1; the F5 repair's
  `npm ci --prefix corpus/fixtures/three && node …` form is the green one (verified by SEAT-08, not
  re-derived here).

---

## 8. Godot battery (regression control)

Run concurrently with ~11 other Godot processes from peer seats, so this is a contended-host number:

```
$ python3 corpus/fixtures/run_battery.py
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
FAIL battery: corpus/live/runs/20261018T174521611949Z/verdicts.json
exit=1   (wall ~14 min under contention; 13 Godot processes were running concurrently)
```

**336/350, 14 failures, zero `seeds_unchanged` complaints.** This is **not** an r22 regression and
not caused by any repair in this round — `corpus/fixtures/` is byte-identical to HEAD
(`reports/round-102/battery-integrity.md` §2: 146 tracked fixture files, 0 byte-mismatches), and the
two other seats that ran the same unmodified battery this round recorded the identical totals
(`reports/round-102/repairs/F3-sha-drift.md:341-342`, `reports/round-102/battery-relation.md:522`:
both `cases=350 pass=336 fail=14`).

The 14 distinct failing case names, extracted from this seat's own log
(`grep '^FAIL ' … | sed -E 's/^FAIL +//; s/:.*//; s/ .*//' | sort -u` → 14):

```
phys3d_joints_free_ops
r94_cannon_backends   r94_cannon_bailout   r94_cannon_det       r94_cannon_det2
r94_cannon_friction   r94_cannon_material  r94_cannon_modes     r94_cannon_nan
r94_cannon_order      r94_cannon_parity    r94_cannon_parity2   r94_cannon_sync
r94_cannon_varstep
```

That is exactly 13 `r94_cannon_*` positive arms plus the one timeout, matching the fixture's 13
`node=v24.21.0` pins one-for-one. The 6 `r94_cannon_neg_*` arms all PASS in this run
(`grep 'r94_cannon_neg' /tmp/r102-seat29-battery.txt` → 6 × `PASS … exit=2 expected=2`), which is the
control showing the drift is confined to the version-carrying marker.

They split into two independent, pre-existing classes, both diagnosed by peer seats and both
re-confirmed in this seat's log:

| Class | Cases | Evidence in this seat's run |
|---|---|---|
| **node-version pin drift** | 13 `r94_cannon_*` positive arms | `FAIL r94_cannon_det: exit=0 expected=0 reasons=['exact stdout marker missing']` — the marker pins `node=v24.21.0`; the host now runs `v26.12.0` (`node --version` → `v26.12.0`, `grep -oE 'node=v…' run_battery.py \| uniq -c` → 13 × `v24.21.0`). The 6 negative arms (`exit 2`) still pass because their markers carry no version. Root cause and byte-level proof: `reports/round-102/repairs/F3-sha-drift.md:330-410`. |
| **20 s case timeout under host load** | 1 `phys3d_joints_free_ops` | `FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)']` — deterministic on this contended host, also seen by SEAT-34 and SEAT-08. |

Neither class is a fixture-logic or physics defect: the `r94` cannon-es lattice output is identical
apart from the version digits, and the timeout is a load-sensitive wall-clock limit. **Honest limit
on the second class:** re-running `--only phys3d_joints_free_ops` *on this still-loaded host* also
fails with the same `TIMEOUT after 20 seconds`, so this seat did **not** observe it passing in
isolation — an unloaded-host pass is a plausible explanation consistent with the peer reports, not
something measured here. It is reported as a contended-host observation.

**What this battery run therefore does and does not establish.** It establishes that the r102
repairs left the shared fixture tree untouched and that the lane's health is unchanged from the
start of the round. It does **not** establish 29/29 or any r22 claim — and it is worth stating
plainly that the r22 lesson's own baseline line (`exit 0, 29/29 PASS`) no longer reproduces on this
host for a reason entirely outside r22: the fixture has grown from 29 to 350 cases since, and the
`node` pin has since drifted. That is a **pre-existing, round-independent** condition, already
routed by other seats, not a defect introduced by any r102 repair.

### 8.1 Note on the `29/29` line

For completeness, since §1 quotes the lesson's command block verbatim: the lesson's *command* is
correct and re-runnable (it exits per the fixture's own verdict), but its *recorded baseline*
`29/29 PASS` is an r22-era observation against a 29-case fixture. The r22 record is preserved
verbatim per lane discipline; its correction is the business of the F2/F3 note at
`corpus/lessons/r22-unreal-review.md:50-56`, which is out of this seat's scope.

---

## 9. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "exit=$?"
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "exit=$?"
sha256sum corpus/artifacts/unreal-r22/*
node corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256); echo "rc=$?"
```
