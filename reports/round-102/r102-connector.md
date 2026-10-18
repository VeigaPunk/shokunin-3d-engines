# r102 connector — how `gate/` + the repaired corpus fit the lane's batteries

Lane: `game-dev-3d-shokunin` · round r102 · seat **SEAT-30 CONNECTOR** · write path: **this file only**.
HEAD at every run below: `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036`).
Date: 2026-10-18.

Read paths: `corpus/knowledge/unreal-mcp/gate/run_gate.sh` + `gate/README.md`, `corpus/fixtures/run_battery.py`,
`corpus/fixtures/bpy_battery.py`, `corpus/fixtures/three/run_cases.mjs`, `corpus/artifacts/unreal-r22/verify_descriptor.py`,
`corpus/knowledge/engines.md`, `corpus/knowledge/rea.md`, `corpus/lessons/r102-unreal-integration.md`,
`reports/round-102/{battery-integrity.md,reruns/*.md,freshness-pin.md,gate/runtime-run.md,git-hygiene.md,ledger-check.md}`.

Labels: **[O]** command run here, output pasted · **[I]** inference · **[?]** unknown.

**No Unreal runtime claim** is made or implied anywhere in this report. Unreal Editor is not installed on
this host; every Unreal statement below is a file-level fact (bytes, paths, exit codes).

**Scope discipline.** Read-only against the tracked tree except this file. No commit. `LOG.md`, `SCORECARD.md`,
`SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, the byte-pinned
`corpus/knowledge/unreal-mcp/upstream/` + `.manifest.d/`, and every other seat's file are untouched.

---

## 0. The one-line integration verdict

The gate **works** — it passes clean, it bites on all four mutation classes, and it is the first
re-runnable artifact in this lane that resolves its own subject from `BASH_SOURCE` rather than from the
caller's cwd. What it does **not** yet do is *fit the lane's battery idiom*: it is the fourth runner in
this repo and the only one that writes **no receipt**, is **reachable from no standing harness**, and
**requires the network** to pass. Those three are the integration gap, and §3 names them as concrete,
command-backed next moves.

---

## 1. Receipts this seat ran itself

**R1 — the gate passes, end to end, from the repo root [O]**

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207

CHECK 1 manifest-byte-identity
… 12 × "upstream/…: OK" …
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
… (11 more static-only) …
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
exit=0
```

**R2 — the gate is cwd-independent; the manifest is not [O]**

This is the property that separates the gate from every earlier way of running these checks.

```
$ cd /tmp && bash /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/gate/run_gate.sh
…
GATE RESULT: PASS (checks failed: 0)
GATE_FROM_TMP_EXIT=0
```

The mechanism is `run_gate.sh:35` — `SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)` — and
`:58` then re-enters the subtree before invoking the manifest:
`C1_OUT=$(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1)`.

Contrast, the raw manifest with no wrapper, which is exactly the failure the wrapper absorbs:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "from-subtree rc=$?"
from-subtree rc=0
$ sha256sum -c corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "from-root rc=$?"
from-root rc=1
$ cd /tmp && sha256sum -c /home/vgpnk/…/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "from-tmp-abs rc=$?"
from-tmp-abs rc=1
```

The manifest stores **relative** paths (`upstream/…`), so it only verifies with the subtree as cwd.
Every earlier citation in the lane's history therefore had an implicit cwd precondition that was never
written down; the gate makes it explicit and removes it. **[I]** That is the single largest usability
gain of this round's C1(a), larger than the four checks themselves.

**R3 — the gate bites: all four mutation classes turn it red [O]**

```
$ T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
$ python3 -c "p='$T/sub/upstream/hooks/hooks.json'; b=bytearray(open(p,'rb').read()); b[10]^=0x20; open(p,'wb').write(bytes(b))"
$ bash "$T/sub/gate/run_gate.sh" | grep -E "MANIFEST_OK|BLOB_DIFFS|STEP=|GATE RESULT"
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL
BLOB_DIFFS=1
STEP=FAIL
STEP=PASS
STEP=PASS
GATE RESULT: FAIL (checks failed: 2)
exit=1
```

One flipped byte in a 357-byte file reddens **both** independent byte checks (manifest *and* clone-blob),
which is the right redundancy: a manifest can be regenerated from a corrupted tree, the clone-blob
comparison cannot.

```
$ printf '\nsee upstream/README.md:200\n' >> "$T/sub/README.md"
$ bash "$T/sub/gate/run_gate.sh" | grep -E "LINE-OOR|POINTERS|GATE RESULT"
LINE-OOR …/sub/README.md :: upstream/README.md:200 (max 112)
POINTERS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)
exit=1

$ sed -i '4s/.*/**Label:** `static-only` and `unproven-runtime`/' "$T2/sub/executability/blueprints.md"
$ bash "$T2/sub/gate/run_gate.sh" | grep -E "multi-label|CARDS=|GATE RESULT"
FAIL multi-label    …/blueprints.md :: **Label:** `static-only` and `unproven-runtime`
CARDS=13 EXPECTED=13 BAD=1
GATE RESULT: FAIL (checks failed: 1)
exit=1
```

Three classes confirmed by me, a fourth (missing file → checks 1+2) is documented and was not re-run
here. The gate is a gate, not a green rubber stamp.

**R4 — the gate is deterministic and writes nothing [O]**

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/g1.log 2>&1; echo "r1=$?"
r1=0
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/g2.log 2>&1; echo "r2=$?"
r2=0
$ diff /tmp/g1.log /tmp/g2.log && echo "DETERMINISTIC_IDENTICAL"
DETERMINISTIC_IDENTICAL
```

Two consecutive runs are byte-identical on stdout. And unlike every sibling runner:

```
$ grep -c "verdicts.json\|live/runs" /tmp/g1.log
0
$ grep -n "mktemp\|trap cleanup" corpus/knowledge/unreal-mcp/gate/run_gate.sh
47:WORK=$(mktemp -d)
49:trap cleanup EXIT
```

`mktemp` + `trap` means the clone scratch is removed on exit and **no artifact survives the run**.
That is a deliberate choice and it is defensible — but it is the opposite of the lane's receipt
convention, and §3 IP-1 is about that.

**R5 — the gate is fail-closed but NOT hermetic: it needs the network [O]**

```
$ unshare -rn bash -c 'cd …/game-dev-3d-shokunin && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh' | grep -E "BLOCKED|GATE RESULT"
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
GATE RESULT: FAIL (checks failed: 1)
```

With no network the gate exits **1**, and its own message correctly refuses to call that a pass
(`run_gate.sh:112`). This is honest behaviour and the right polarity. It is also the gate's one
environmental precondition, and it is the only one of the four checks that cannot be satisfied from the
committed tree alone. `run_gate.sh:86` wraps the clone in `timeout 180`, so a hung network degrades to
a bounded FAIL rather than a hang.

**R6 — the gate is untracked; the batteries are tracked [O]**

```
$ git ls-files --error-unmatch corpus/knowledge/unreal-mcp/gate/run_gate.sh
error: pathspec 'corpus/knowledge/unreal-mcp/gate/run_gate.sh' did not match any file(s) known to git
$ git ls-files --error-unmatch corpus/fixtures/run_battery.py >/dev/null 2>&1 && echo "run_battery TRACKED"
run_battery TRACKED
```

As of this seat's last read the gate is `??` (untracked) alongside the rest of `reports/round-102/`. The
L1 lands commits at round close, so this is expected — but it means the gate's own byte identity is
unpinned until then. Self-digests for the record:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e  corpus/knowledge/unreal-mcp/gate/run_gate.sh
def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8  corpus/knowledge/unreal-mcp/gate/README.md
```

**R7 — the bpy sibling runner still passes; the three.js receipt flag still works [O]**

Both were re-run by this seat so the "repaired corpus serves the batteries" claim rests on live
execution, not on an inherited report.

```
$ timeout 200 python3 corpus/fixtures/bpy_battery.py --runs /tmp/r102-conn-runs
totals: cases=83 pass=83 fail=0 (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0 exit=0
PASS battery: /tmp/r102-conn-runs/bpy-20261018T174301435007Z/verdicts.json
exit=0
```

```
$ node corpus/fixtures/three/run_cases.mjs --receipt /tmp/r102-conn-receipt.json
exit=0
$ python3 -c "import json;d=json.load(open('/tmp/r102-conn-receipt.json'));print('keys:',sorted(d));print('verdict:',d['verdict'])"
keys: ['boundedClaim', 'node', 'results', 'seedDigests', 'seedsUnchanged', 'three', 'verdict']
verdict: PASS
```

**R8 — the F5 repair works from a pristine export [O]**

`engines.md`'s three.js evidence cell now reads
`npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs`. Reproduced against a
clean `git archive HEAD` export with no `node_modules/`:

```
$ T=$(mktemp -d); git archive HEAD | tar -x -C "$T"; cd "$T"
$ npm ci --prefix corpus/fixtures/three >/dev/null 2>&1; echo "npm_ci_exit=$?"
npm_ci_exit=0
$ node corpus/fixtures/three/run_cases.mjs | tail -2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
three_exit=0
```

Before the repair the same pristine tree gave `exit=1` with all three arms failing
(`reports/round-102/before/F5-engines-threejs.md` §2b). The repaired command is genuinely re-runnable
from a clone — which is precisely the standard the gate is held to.

---

## 2. How the gate and the repaired corpus fit the batteries

### 2.1 The lane now has four runners, and they do not share a contract

| runner | path | case model | writes a receipt | cwd-independent | network |
|---|---|---|---|---|---|
| Godot battery | `corpus/fixtures/run_battery.py` | 350 `CASES` tuples `(name, script, flags, exit, marker)` at `:39` | **yes** — `verdicts.json` `:1381`, `mutation-verdicts.json` `:1339`, `tree-timeout-verdicts.json` `:1219` | yes — `args.runs.resolve()` `:1241` | no |
| bpy sibling | `corpus/fixtures/bpy_battery.py` | 83 `(name, arm, point, layer, {kv}, non_signal)` rows at `:56` | **yes** — `verdicts.json` `:602` | **no** — `args.runs / ("bpy-"+stamp)` `:393` (no `.resolve()`) | no |
| three.js | `corpus/fixtures/three/run_cases.mjs` | 3 `[name, flags, exit, marker]` rows `:12-16` | **opt-in** — `--receipt <file>` `:35-38` | yes — resolves `here` from `import.meta.url` | no |
| **unreal gate** | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | 4 shell checks, expected values pinned in `gate/README.md` | **no** — `mktemp`+`trap`, R4 | **yes** — `BASH_SOURCE` `:35` | **yes** — check 2 |

**What this says.** The lane's battery idiom, stated positively, is: *one runner per runtime, its own
case model, a machine-readable receipt under `corpus/live/runs/<ts>/`, seeds hashed before and after,
exit 0 only on total pass.* `bpy_battery.py:1-7` writes that contract into its own docstring —
*"Sibling runner to `run_battery.py` — the Godot battery stays untouched (prior rows byte-stable); this
runner owns the bpy runtime surface only"* — and it is the template the gate should be read against.

The gate satisfies the **spirit** of that idiom unusually well and one **letter** of it not at all:

- It satisfies it better than any sibling on *self-location*. `bpy_battery.py` is the only runner that
  never resolves its `--runs` path (`:393` vs `run_battery.py:1241`); the gate is fully
  `BASH_SOURCE`-relative (R2). The r101 lesson's hook #2 — *"Make the gate path-independent"*
  (`corpus/lessons/r102-unreal-integration.md`) — is **discharged**: the gate exists and it is
  path-independent.
- It satisfies it on *fail-closed polarity*: no partial-pass state, `exit 0 iff FAILS==0` (`:200`).
- It **fails** it on *receipts*. Every sibling leaves a JSON receipt keyed to a timestamped run dir;
  the gate leaves stdout and nothing else (R4). A green gate therefore cannot be cited from a
  committed receipt the way `r1 battery receipts under corpus/live/runs/` is cited in
  `engines.md:8` for Godot.

### 2.2 The gate is outside every standing harness — measured, not assumed

This was the r101 connector's IP-2 and it is still open, now in a sharper form: the gate exists, but
nothing invokes it.

```
$ grep -rln "run_gate" corpus/fixtures/ corpus/artifacts/ SCORECARD.md LOG.md 2>/dev/null; echo "rc=$?"
rc=1
```

```
$ python3 - <<'PY'
import importlib.util, sys
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("rb", "corpus/fixtures/run_battery.py")
rb = importlib.util.module_from_spec(spec); spec.loader.exec_module(rb)
k = rb.seed_digests()
print("entries:", len(k), "| gate refs:", sum("gate" in x for x in k), "| knowledge refs:", sum("knowledge" in x for x in k))
PY
entries: 130 | gate refs: 0 | knowledge refs: 0
```

`seed_digests()` (`run_battery.py:940-946`) roots at `HERE` = `corpus/fixtures/`, so the 130-entry map
covers `r94vendor`, `r95vendor`, `r98assets` — every other vendored third-party tree in this lane — and
**zero** paths under `corpus/knowledge/`. The r101 connector's R3 reproduced exactly, one round later,
against a subtree that has since grown a gate.

**[I]** Consequence: the gate is *re-runnable* but not *re-run*. Nothing in the lane's standing
machinery fails if someone edits a vendored byte next round; the gate only catches it if a human
remembers to type the command. That is the difference between an artifact and a gate.

### 2.3 The repaired corpus, in battery terms

The five F-routed defects all fall in one class — **prose citing bytes that no longer match** — and
that is the same class `seed_digests()` exists to prevent mechanically:

| defect | repair | verified how | fits the battery idiom? |
|---|---|---|---|
| F1 `.shokunin/game-dev-3d/` phantom root (r22 README + lesson) | in-place path conformance | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` → `PASS … actual=accept`, exit 0 (`repairs/F1a-r22-readme.md`) | yes — it makes an evidence command runnable, exactly what a receipt requires |
| F2 `verdicts.json` cite in gitignored `corpus/live/` | dated correction note | `git check-ignore -v` → `corpus/.gitignore:1:live/` (`before/F2-verdicts-json.md`) | **no** — this is the battery idiom's blind spot, see below |
| F3 stale `a065a56d…` sha | dated note, not silent rewrite | `sha256sum corpus/fixtures/run_battery.py` → `f456bd00…`; `git cat-file blob 8b21cae:… \| sha256sum` → `a065a56d…` (`adversary/F3.md`) | yes — and the archival reading is correct |
| F5 three.js evidence cmd | in-place install precondition | R8 above, pristine export, exit 0 | yes |
| F6 `rea.md` tool census | dated note | `which jadx binwalk unblob` → all three present (`repairs/F6-rea-census.md`) | yes |

**The F2 lesson for the battery idiom [I].** F2 is the one defect the battery idiom *cannot* catch, and
its shape is worth stating: `corpus/live/` is gitignored (`corpus/.gitignore:1`), so every receipt
written there is **ephemeral by construction** — `seed_digests()` will never hash it, no clone will
contain it, and any prose citing a `corpus/live/…` path is citing something that will be gone.
The gate's `mktemp`+`trap` design (R4) has exactly this property: it is honest (it writes no
dangling citation) but it also produces nothing durable. Both are the same trade-off seen from
opposite sides, and §3 IP-1 resolves it.

---

## 3. Three concrete next integration points

Each names the anchor, the measured gap, the proposed landing, and the command that proves it.

### IP-1 — give the gate the battery's receipt contract (highest value)

**Anchor.** `gate/run_gate.sh:47-49` (`mktemp` + `trap cleanup EXIT`) vs `run_battery.py:1381`
(`(run_dir / "verdicts.json").write_text(...)`) and `bpy_battery.py:602` (same). Receipt root
convention: `run_battery.py:1228` / `bpy_battery.py:389`, both defaulting to
`HERE.parent / "live" / "runs"`.

**Gap [O].** R4: the gate emits stdout only. A green gate is not citable from a committed receipt, so
`engines.md:8`'s Godot pattern — *"r1 battery receipts under `corpus/live/runs/`"* — has no Unreal
analogue. Worse, the gate's result is currently preserved only in `reports/round-102/gate/author-run.txt`,
a hand-pasted transcript, i.e. the exact "read nothing from an author's transcript" failure the gate's
own README (`gate/README.md:9`) claims to avoid.

**Landing.** Add an opt-in `--receipt <path>` flag mirroring `three/run_cases.mjs:33-37`, writing the
four STEP lines plus `GATE RESULT` and the pinned constants as JSON, defaulting to
`corpus/live/runs/<ts>/gate-verdicts.json`. Do **not** make it mandatory: the no-write default is a
real virtue for CI-style use and should stay the default.

**Evidence.** The wrapper already works end to end when a caller supplies it — I simulated it:

```
$ TS=$(date -u +%Y%m%dT%H%M%S%fZ); mkdir -p "corpus/live/runs/$TS"
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > "corpus/live/runs/$TS/gate-verdicts.txt" 2>&1
wrapper_exit=0
$ ls -la "corpus/live/runs/$TS/"
-rw-r--r-- 1 vgpnk vgpnk 1925 Oct 18 14:43 gate-verdicts.txt
$ git check-ignore -v "corpus/live/runs/$TS/gate-verdicts.txt"
corpus/.gitignore:1:live/	corpus/live/runs/$TS/gate-verdicts.txt
```

(The scratch dir I created for this probe was removed; `corpus/live/runs/` holds 11 pre-existing run
dirs, none of them mine.) So the receipt path is already gitignored and convention-compatible — the
only missing piece is the flag.

### IP-2 — put the gate inside a standing harness, or stop calling it standing

**Anchor.** `run_battery.py:940-946` (`seed_digests`), `:1228` (`--runs`), the existing per-artifact
checker precedent `corpus/artifacts/{unity-r19/verify_scene.py, glb-r9/validate_glb.py,
zip-r10/verify_carrier.py, glb-r12/run_import.py, unreal-r22/verify_descriptor.py}`, and the new
`gate/run_gate.sh`.

**Gap [O].** §2.2: `grep -rln "run_gate"` over the tracked harness returns nothing (rc=1); the digest
map has 0 gate refs out of 130. The gate is invoked by humans and by nothing else.

**Landing — two options, smallest first.**

1. **Minimal, no new file:** a `--vendor-gate` flag on `run_battery.py` that shells out to
   `gate/run_gate.sh` and folds its exit status into the battery verdict, exactly as
   `--probe-crash-exit` / `--probe-stream-attribution` / `--probe-tree-timeout` (`:1232-1237`) already
   fold three extra probes into `main()`'s `verdict` expression (`:1374-1376`). This is the lane's own
   established extension point — no new idiom.
2. **Conventional:** a lane close-out script under `reports/` that runs battery + bpy + three + gate
   and exits non-zero if any is red, mirroring the `--only` / `--probes` composition already used.

**Evidence.** The gate is already shell-invocable and already fail-closed, so option 1 is a ~10-line
change: the gate returns 0/1 (`run_gate.sh:200`) and prints a machine-greppable summary
(`GATE RESULT: PASS (checks failed: 0)`). Note the one caveat that makes this a *decision* rather than
a mechanical wiring: check 2 needs the network (R5), so folding the gate into the battery would make
the battery network-dependent for the first time. That is why IP-4 below matters if IP-2 is taken.

### IP-3 — fix check 4's range-pointer coverage gap (found this seat, reproducible)

**Anchor.** `gate/run_gate.sh:192`, the pointer-extraction regex:

```
done < <(grep -ohE "upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+" "$f" | sort -u)
```

Compare `reports/round-102/reruns/pointer-sweep.sh`, which uses a **range-aware** form:

```
ptr_re='upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+([,-][0-9]+)*'
```

**Gap [O] — the gate under-covers, and the two tools disagree on the same tree.**

The gate's regex has no `([,-][0-9]+)*` group, so on a pointer written `upstream/README.md:50-57` it
matches only `upstream/README.md:50` and **silently discards the `-57` endpoint**. Measured on the
live tree:

```
$ # gate-style: per-file-unique, truncating regex
gate-style total=40          # matches the gate's own POINTERS=40
$ # sweep-style: range-aware, every endpoint expanded
sweep-style total=47         # matches the sweep's POINTERS=47
```

The gate reports `POINTERS=40`; the sweep reports `POINTERS=47`. Same tree, same round, **7 endpoints
difference** — and the delta is exactly the range/comma endpoints the gate's regex cannot see. The
real tree contains **5** range-form pointers:

```
$ grep -rn 'upstream/README.md:50-57' corpus/knowledge/unreal-mcp/ | head -1
corpus/knowledge/unreal-mcp/adaptation-kimi.md:42:… | `upstream/README.md:50-57` → search §4.1 …
$ # all range/comma forms in the subtree's own prose
upstream/hooks/hooks.json:4-5
upstream/hooks/unreal-context.sh:5,8
upstream/README.md:39,45
upstream/README.md:50-57
upstream/skills/unreal-mcp/references/setup.md:61,70-79
```

**The gap is not cosmetic — it is a false pass.** I planted an out-of-range *range endpoint* in a card
on a copy of the subtree:

```
$ T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
$ printf '\nsee upstream/README.md:100-9999\n' >> "$T/sub/executability/blueprints.md"
$ bash "$T/sub/gate/run_gate.sh" | tail -6
CHECK 4 pointer-sweep
POINTERS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
gate_exit=0
```

**The gate passes a tree containing a pointer to line 9999 of a 112-line file.** The same mutation,
run through the r102 rerun sweep, is caught:

```
$ BASE="$T/sub" bash reports/round-102/reruns/pointer-sweep.sh "$T/sub" | grep -E "LINE-OOR|POINTERS|STEP"
LINE-OOR …/sub/executability/blueprints.md :: upstream/README.md:100-9999 (max 112)
FILES_SCANNED=16 POINTERS=49 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
sweep_exit=1
```

**Landing.** Adopt the range-aware regex and the endpoint-expansion loop from
`reruns/pointer-sweep.sh` into `run_gate.sh` check 4 (i.e. `([,-][0-9]+)*` plus
`for ln in $(printf '%s' "$rest" | tr ',-' '  ')`). This is a strictly-strengthening change: the live
tree still passes (47 endpoints, `UNRESOLVED=0`, verified), and the false pass above becomes a FAIL.
**It is not this seat's file to edit** — `gate/run_gate.sh` belongs to the gate's authoring seat, and
the round's byte-pinned discipline makes an unowned edit to a C1 artifact doubly wrong.

**Boundary, stated honestly.** `gate/README.md:91-104` documents check 4's exclusions carefully but says
nothing about range forms, and its calibration list (`:146`) plants only a bare `:200`-style pointer —
so the gap is an **un-noticed** under-coverage, not a documented limitation. **[I]** It is also worth
noting the gate's README claims the gate *"reads nothing from any author's transcript"*
(`gate/README.md:9`); this finding is a case where a **sibling** transcript (the rerun sweep) is
strictly stronger than the gate, which is the argument for cross-checking the two rather than treating
the gate as the ceiling.

### IP-4 (brief, conditional on IP-2) — decide the gate's network posture explicitly

**Anchor.** `gate/run_gate.sh:86` (`timeout 180 git clone`) and `:112` (`BLOCKED, not PASS`).

**Gap [O].** R5: offline, the gate exits 1. That is correct fail-closed behaviour, but it means the
gate **cannot be run in an air-gapped close-out**, and folding it into the battery (IP-2 option 1)
would import that dependency into a harness that is currently network-free.

**Landing.** Either accept it and document the precondition at the call site (cheapest, and arguably
right — check 2 is the gate's strongest check), or add an explicit `--offline` mode that degrades
check 2 to "manifest + blob ids vs a caller-supplied cached clone" and **prints that it degraded**, so
a green offline run can never be mistaken for a green online run. Do not silently skip check 2.

---

## 4. What a later seat must not assume

- **Do not read R1's green as an upstream statement.** It proves the 12 vendored files equal the 12
  hashes in a manifest and in a fresh clone at the pin. It does not prove the plugin loads, that any
  tool exists, or that any editor behaviour is real. `gate/README.md:18-22` says this; repeated here
  because a green four-check summary is exactly the artifact that invites over-reading.
- **The gate's `POINTERS=40` is not the subtree's pointer count.** It is 47 by the range-aware
  count (IP-3). Any future citation of "40 pointers" should name the regex that produced it.
- **Check 3 enforces one-label-per-card, not label correctness.** `gate/README.md:191-194` states that
  the semantic question — does this `static-only` card actually rest on a static check that ran here? —
  is a read-the-cards judgement no script makes. The r101 lesson's hook #1 (the F7 label collision,
  6 cards rejecting `unproven-runtime` on grounds `README.md:41` assigns to it) is **not** closed by
  this gate; a mechanically green check 3 is fully compatible with the collision still being present.
- **`reports/round-102/gate/runtime-run.md` is a manual fallback, not a gate run.** SEAT-39 ran before
  the gate existed (`ls corpus/knowledge/unreal-mcp/gate` → exit 2 at its runtime) and ran the four
  checks by hand. Its numbers and mine agree where they overlap, but only R1 above is an actual
  `run_gate.sh` invocation.
- **Everything in §1 is timestamped by the commands shown.** The tree moved under this seat — the gate,
  `gate/README.md`, the r102 lesson, and the `engines.md`/`rea.md` repairs all landed mid-seat. The
  gate/lesson shas in R6 and `reports/round-102/gate/author-run.txt` are the pins for what I read.
- **No Unreal runtime claim anywhere in this report.** The editor is not installed; the install wall is
  operator-gated (`reports/round-102/install-recheck.md` re-ran the three receipts, all reproduced).

---

## 5. Limits of this report

- **Read-only analysis of other seats' artifacts.** No file was edited except this one. IP-1…IP-4 are
  proposals with exact anchors and measured deltas, not landed changes.
- **No battery execution beyond the two re-runs in R7.** I ran `bpy_battery.py` (83/83) and
  `three/run_cases.mjs` (3/3) to prove the repaired corpus still executes; I did **not** run the
  350-case Godot battery (`reports/round-102/battery-integrity.md` proves its inputs byte-stable but
  explicitly asserts nothing about runtime pass/fail).
- **The IP-3 mutation is my own probe on a private copy.** The repo's `executability/` cards were never
  modified; the mutated trees live in `mktemp` dirs that are gone.
- **Scratch state cleaned.** The `corpus/live/runs/<ts>/gate-verdicts.txt` wrapper probe and the
  `corpus/live/three-r6.json` receipt probe were removed; `corpus/live/runs/` holds only the
  pre-existing run dirs.
