# r104 connector — where the integration frontier moved, and what r105 should do

**Seat:** SEAT-24 CONNECTOR · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-104/r104-connector.md`). Every other path is
read-only here. No commit.
**Repo HEAD at write:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (r103 report-last; work `8c9d9ad`)
**Measurement window:** 2026-10-18, 19:16Z–19:24Z.
**Tag key:** **[O]** command run by this seat with output pasted · **[I]** labelled inference ·
**[F]** a claim that did **not** reproduce here.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this
host; live-MCP and editor behaviour are unproven by construction. A green gate is static evidence
over vendored bytes and must never be read as live-editor evidence — `gate/README.md` says so itself.

---

## 0. The one-line verdict

**All three of r104's fixes landed, and each one I re-ran rather than read — but the tree moved under
me four times while I did it, and that movement is itself the finding.** The r103 connector's three
"integration gaps" were *prerequisites*; two of the three are now resolved, so the frontier has moved
from *"can we wire the gate?"* to *"the gate still has no durable, machine-readable verdict channel,
and no standing harness invokes it."* **Recommendation in §5: r105's primary move is a gate receipt +
a runner-of-runners; the `engines.md` census fix is the cheap unblocked coverage move; do not wire the
gate into the battery verdict this round.**

---

## 1. The frame, and the fact that it moved

### 1.1 Snapshot at write

```
$ for f in corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py \
           corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/engines.md SKILL.md; do
    printf "%-52s %s  %s lines\n" "$f" "$(sha256sum $f | cut -c1-12)" "$(wc -l < $f)"; done
corpus/fixtures/phys3d_joints.gd                     c7e776387f60  199 lines
corpus/fixtures/run_battery.py                       f456bd00a1f7  1387 lines
corpus/knowledge/unreal-mcp/gate/run_gate.sh         e55213049db7  442 lines
corpus/knowledge/engines.md                          d03907d3d637  16 lines
SKILL.md                                             1055a52f5704  174 lines

$ git rev-parse HEAD
88c3b2ca70fc83ec47a931d7b6dcff85a111c04e
```

At the round's opening I measured the **opposite** state — every claimed artifact byte-identical to
HEAD:

```
$ git show HEAD:corpus/fixtures/phys3d_joints.gd | sha256sum
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  -
$ sha256sum corpus/fixtures/phys3d_joints.gd        # worktree, 19:17Z
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  corpus/fixtures/phys3d_joints.gd
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   # == HEAD, 347 lines
$ ls SKILL.md
ls: cannot access 'SKILL.md': No such file or directory
```

### 1.2 The gate took at least five shas inside my window — and one was broken

The gate moved **347 → 352 → 433 → 442 lines** while this seat ran. I caught one revision that did
not parse:

```
$ bash reports/round-104/gate/flake_harness.sh 10     # at ~19:22Z
  | /home/vgpnk/…/gate/run_gate.sh: line 407: syntax error near unexpected token `)'
  | /home/vgpnk/…/gate/run_gate.sh: line 407: `^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)'
```

That was a **mid-edit intermediate**, not the landed file — the next revision is clean:

```
$ bash -n corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo SYNTAX_OK
SYNTAX_OK
```

**[I] This is the r103 law reproducing on a connector.** r103 recorded: *"Attack seats racing an
author's file read STALE INTERMEDIATES — falsification verdicts must name the target's hash."* I hit
the same class four times in eight minutes, in the *opposite* direction: I twice nearly reported a
landed fix as "not landed", and once nearly reported a transient syntax error as a gate defect.
**Every number below is bound to the sha named beside it; the §1.1 frame must be re-measured before
anyone edits these files.** I report the movement rather than hiding it, because a connector that
reads a tree once and recommends from it is reading a tree that no longer exists.

---

## 2. C1 (depth) — the physics fix landed, and it works end-to-end [O]

The r103 ruling was `INTRINSIC_WALL_COST`: 21 serial child Godot boots × ~0.90 s floor ≈ 19 s against
`CASE_TIMEOUT_SECONDS = 20`. The preferred fix was **R3, concurrent children**. That is what landed —
not a raised bound:

```
$ git diff -- corpus/fixtures/phys3d_joints.gd | head -40
-func _run_child(case: String, bk: String, engine: String) -> Dictionary:
+# r104 R3 — spawn every (case, backend) child first, then collect in the
+# original nested-loop order. The emitted stream stays a pure function of the
+# per-child logs; only the wall clock changes.
+func _spawn_child(case: String, bk: String, engine: String) -> Dictionary:
...
-	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
+	var pid := OS.create_process("/bin/sh", ["-c", cmd], false)
+	if pid <= 0:
+		return {"err": "spawn failed"}
+	return {"case": case, "bk": bk, "pid": pid, "log": logpath}
+
+func _collect_child(j: Dictionary) -> Dictionary:
+	while OS.is_process_running(j["pid"]):
+		OS.delay_msec(5)
+	var code := OS.get_process_exit_code(j["pid"])
```

**The counting command — this seat ran it, not a sibling:**

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /home/vgpnk/scratch-r104/s24runs
VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     phys3d_joints_free_ops             phys3d_joints.gd           --arm=free_ops     0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /home/vgpnk/scratch-r104/s24runs/20261018T192204206421Z/verdicts.json
BATTERY_RC=0
```

**Before → after:**

| | r102 receipt / r103 measurement | r104, this seat |
|---|---|---|
| verdict | `FAIL` — `['TIMEOUT after 20 seconds', …]` | **`PASS`** |
| elapsed | `20.01 s` (killed at the cap) | **`2.304 s`** |
| exit | `None` | `0` |

**And the marker did not move — which is the whole point of the fix.** The r103 ruling was explicit
that the arm is *correct* and the marker is byte-identical at a 120 s bound, so the fix must not move
one byte. I re-derived the pinned digest from the fresh receipt rather than quoting `markers.md`:

```
$ python3 - <<'PY'
import json,glob,hashlib
f=sorted(glob.glob('/home/vgpnk/scratch-r104/s24runs/*/verdicts.json'))[-1]
r=json.load(open(f))['results'][0]
m=r['marker']; print('marker bytes:',len(m)); print('marker sha256:',hashlib.sha256(m.encode()).hexdigest())
PY
marker bytes: 3921
marker sha256: 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
```

`reports/round-104/physics/markers.md` pins `phys3d_joints_free_ops` at **3921 bytes /
`706ad915…`**. **Exact match.** The stream is unchanged; only the clock moved. **[O]**

**[I] Speedup ≈ 8.7×** (20.01 s → 2.304 s), which is consistent with the r103 contention measurement
(21 concurrent boots = 1.0 s vs 21 serial ≈ 19 s) rather than with a core-count-limited bound.

**What this does *not* fix, and it matters for §5:** the **13 `r94_cannon_*` rows are still red**, on a
*different* class. Their markers are byte-pinned to `node=v24.21.0`; the host runs **`v26.12.0`**
(`node --version` → `v26.12.0`, this seat):

```
$ grep -n "v24.21.0" corpus/fixtures/run_battery.py | head -1
662:     'PASS r94_cannon det node=v24.21.0 det_base{rc=0,m=M0 case=det_base engine=cannon-es-0.20.0+three-0.186.1|…
$ python3 -c "…; print('CASES total',len(m.CASES),'cannon rows',len([x for x in m.CASES if 'cannon' in x[0]]))"
CASES total 350 cannon rows 19
```

Of the r102 receipt's **14** failures, **13 are `r94_cannon_*`** (`corpus/live/runs/20261018T181301123479Z/verdicts.json`).
So the battery's expected post-C1 count is **337 pass / 13 fail**, not 350/350 — **C1 removes exactly
the row it targeted and touches nothing else.**

---

## 3. C2 (coverage) — the resilience fix landed, and I reproduced the hazard it closes [O]

### 3.1 I reproduced the r103 root cause live, and it was worse than r103 recorded

r103's root cause was `/tmp` quota pressure silently breaking `mktemp`/clone. **At my first
measurement the gate was RED on a byte-clean tree**, 12/12 consecutive runs:

```
$ for i in 1 2 3 4 5 6; do out=$(bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1); echo "run$i: $(printf '%s' "$out" | grep -c 'FAIL per-seat') $(printf '%s' "$out" | tail -1)"; done
run1: 1 GATE RESULT: FAIL (checks failed: 1)      … run6: 1 GATE RESULT: FAIL (checks failed: 1)
```

**The mechanism, isolated:**

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G   80% /tmp
$ f=$(mktemp); echo "x" > "$f"; echo "write_rc=$?"
bash: line 1: echo: write error: Disk quota exceeded
write_rc=1
```

`mktemp` **succeeds** — it returns a path and creates a 0-byte file — but the *write* into it fails
with `Disk quota exceeded`. `df` reports **3.1G available**, so `df` is not a usable pre-flight check
here. The gate did `MANLOG=$(mktemp)` then `sha256sum … >"$MANLOG"`; the redirect failed, `sha256sum`
**never ran**, and the gate reported the *manifest sweep* as broken:

```
FAIL per-seat manifest sweep (--strict) failed:
```

**Control — the same sweep by hand exits 0, 24 OK lines:**

```
$ (cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/mlog.1 2>&1); echo "rc=$?"
rc=0
$ grep -v ': OK$' /tmp/mlog.1
(none)
```

**[I] This is a *worse* instance than r103 recorded.** r103's hazard broke CHECK 2's *clone* (the
largest scratch consumer) and the gate's own README calls that "a host-weather BLOCKED". The instance
I reproduced broke **CHECK 1's manifest scratch file** — a 1-line temp file — and converted a clean
tree into **exit 1 (FAIL)**, i.e. into the *verdict* channel, where it is indistinguishable from
vendored-byte divergence. The failure scaled *down* to a smaller allocation, so `GATE_WORKDIR` on the
clone alone would not have caught it.

### 3.2 The landed fix, and the matrix that proves it

The landed script (442 lines, `e55213049db7…`) introduces `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`,
validates it up front, routes **both** `mktemp` calls through it, and — the load-bearing part — makes
failure **loud and named** rather than silent:

```
$ sed -n '124,131p' corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''
if [ -z "$MANLOG" ]; then
  printf 'FAIL cannot create scratch file under %s (quota? permissions?)\n' "$WORK_ROOT"
  printf '     set GATE_WORKDIR (or TMPDIR) to a writable directory with room\n'
  FAILS=$((FAILS+1))
```

**Precedence matrix, 3 runs each, this seat:**

| env | exit codes | verdict |
|---|---|---|
| *(neither — default `/tmp`)* | `1 1 1` | host-weather dependent (§3.3) |
| `GATE_WORKDIR=<real disk>` | `0 0 0` | **PASS** |
| `TMPDIR=<real disk>` | `0 0 0` | **PASS** |
| offline (`unshare -rn`) + `GATE_WORKDIR` | `2` | **BLOCKED** |

And the two runs name their own provenance, which is what makes a red frame readable:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E "WORK_ROOT|GATE RESULT"
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
GATE RESULT: PASS (checks failed: 0)
$ GATE_WORKDIR=/home/vgpnk/scratch-r104/gw bash … | grep -E "WORK_ROOT|GATE RESULT"
WORK_ROOT=/home/vgpnk/scratch-r104/gw (from GATE_WORKDIR)
WORK_ROOT_FREE=772G of 930G (16% used)
GATE RESULT: PASS (checks failed: 0)
```

**The flake harness is landed and stable on a real-disk workdir:**

```
$ GATE_WORKDIR=/home/vgpnk/scratch-r104/gw bash reports/round-104/gate/flake_harness.sh 5
run  2/5  rc=0  verdict=PASS       POINTERS=101   1.06s  run-2.log
…
TALLY runs=5 pass=5 fail=0 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: STABLE (5/5 runs returned PASS with a matching exit code)
```

**[I] The r103 "no durable flake harness" gap is closed** — `reports/round-104/gate/flake_harness.sh`
tests the *complementary* property to the r102/r103 attack suites: same verdict on an unmodified tree,
run after run.

### 3.3 The residual: the default-workdir verdict is *still* host-weather, and now flaps between three states

Running the installed gate on its default `/tmp` workdir six times in one window produced **three
different verdicts**:

```
run1 rc=2 verdict=[GATE RESULT: BLOCKED]   CHECK 2 BLOCKED (network)
run2 rc=2 verdict=[GATE RESULT: BLOCKED]   CHECK 2 BLOCKED (local-resource)
run3 rc=1 verdict=[GATE RESULT: FAIL]      FAIL per-seat manifest sweep (--strict) failed: …
run4 rc=2 verdict=[GATE RESULT: BLOCKED]   CHECK 2 BLOCKED (network)
run5 rc=2 verdict=[GATE RESULT: BLOCKED]   CHECK 2 BLOCKED (local-resource)
run6 rc=2 verdict=[GATE RESULT: BLOCKED]   CHECK 2 BLOCKED (local-resource)
```

**[O] Note `run1` and `run4`: `BLOCKED (network)`.** The `git clone` died in its own template copy
under quota exhaustion *before* reaching the network, so the gate's **"network" label is still a
misattribution in that path** — the same H1 class the r103 connector named. The `local-resource`
branch is the *new*, correct discrimination; the `network` branch is reached when the clone fails for
a cause the gate has not established.

**[I] This is not a defect in the fix — it is the fix working as designed.** The gate now tells the
truth about *its own scratch* and routes around it; what remains is that **an unqualified gate
invocation on this host is not a reproducible experiment.** That single fact drives the §5
recommendation.

### 3.4 C3 landed: `SKILL.md` exists

```
$ head -20 SKILL.md
---
name: game-dev-3d-shokunin
description: Domain specialist — 3D game production verified by executable headless fixtures …
---
## 1. Unreal-content claim discipline — decision table
```

`SKILL.md` is **174 lines / 18759 bytes**, carrying the decision table as **5 rows A–E** (§1 at `:20`).
**[I]** The r103 connector recommended *deferring* this landing on four REVISE findings; the landed
table adds the **E row** ("lane-authored static descriptor") that
`reports/round-103/skill-table-review.md` §3.1 identified as missing, and its citations carry
`r104 re-derivation` pointers. Whether that discharges the four REVISE findings is a **verification**
question for a non-author seat, not this one — I confirm only that the file exists and the row set is
A–E, and I make **no** claim that the table is correct.

---

## 4. The three candidate frontiers, re-measured

### 4.1 Frontier 1 — wire `run_gate` into `run_battery` (the r102 proposal)

**Anchor.** `run_battery.py`'s `--probe-*` argument block (the `parser.add_argument("--probe-failing"…)`
run, `:1230` at this frame) and its `verdict = ("PASS" if failed == 0 …)` expression (`:1366` at this
frame) — the lane's own established extension point. **Measured state — the gap is unchanged, and I
re-derived it:**

```
$ python3 - <<'PY'
import importlib.util,sys
sys.dont_write_bytecode=True
s=importlib.util.spec_from_file_location("rb","corpus/fixtures/run_battery.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
d=m.seed_digests()
print("entries:",len(d),"knowledge:",sum('knowledge' in k for k in d),"gate:",sum('gate' in k for k in d))
PY
entries: 130 knowledge: 0 gate: 0
$ git grep -ln "run_gate" -- corpus/ | grep -v "gate/"
corpus/lessons/r102-unreal-integration.md
```

**Zero** gate references in `corpus/fixtures/`, **zero** gate entries in `seed_digests()`. Two repair
rounds made the corpus healthier; **neither made the gate automatic.** The only executable reference
to the gate anywhere in the tracked tree is prose.

**The r103 blocker is now demonstrated, not theoretical.** I built the mixed case — BLOCKED *and* a
real byte failure — on a copy, offline:

```
$ unshare -rn bash -c '… cp -a corpus/knowledge/unreal-mcp /tmp/mix2 && printf "x\n" >> /tmp/mix2/upstream/README.md && bash /tmp/mix2/gate/run_gate.sh 2>&1 | grep -E "STEP=|GATE RESULT"; echo "EXIT=${PIPESTATUS[0]}"'
STEP=FAIL
STEP=BLOCKED
STEP=PASS
STEP=FAIL
GATE RESULT: FAIL (checks failed: 3)
EXIT=1
```

**[O] The third state is lost exactly as the gate's own README warns** (its `One residual, recorded
rather than hidden:` paragraph under "Exit codes", `:299` at this frame: *"when CHECK 2 is BLOCKED **and**
another check also fails, the gate prints `GATE RESULT: FAIL` and exits `1` — the third state is lost in
the mixed case"*) — `STEP=BLOCKED` and
`GATE RESULT: FAIL`, exit 1. And the **exit-2 collision** with the lane's own convention is real:

```
$ sed -n '44,50p' corpus/fixtures/README.md
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: <case> <reason>` line | PASS |
Exit 2 is a *passing* negative control, not a failure: …
$ python3 -c "
lane_reads = {0:'PASS', 1:'FAIL', 2:'PASS (negative control)'}
for rc,label in [(0,'gate PASS'),(1,'gate FAIL'),(2,'gate BLOCKED')]:
    print(f'  gate exit {rc} ({label}) -> lane convention reads: {lane_reads[rc]}')"
  gate exit 0 (gate PASS) -> lane convention reads: PASS
  gate exit 1 (gate FAIL) -> lane convention reads: FAIL
  gate exit 2 (gate BLOCKED) -> lane convention reads: PASS (negative control)
```

**A wrapper folding the gate's status into a battery verdict using the lane's own convention reads a
blocked gate as GREEN.** §3.3 shows BLOCKED is reachable *right now* from local quota exhaustion alone.

**Verdict: still the right move, still the wrong round to rush.** The gate-side prerequisite (A4's
`GATE_REF` for hermeticity) is in place; what blocks it is a **ruling**, and §3.3 adds a second
reason: wiring a check whose default-invocation verdict is host-weather into a verdict with no
BLOCKED channel imports a new false-red class into the lane's primary harness.

### 4.2 Frontier 2 — the `engines.md` census (the r103 connector's option 3) — **still open, still cheapest**

**Measured state, re-derived at this frame:**

```
$ grep -c run_gate corpus/knowledge/engines.md
0
$ sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "verbatim_from_root_exit=$?"
verbatim_from_root_exit=1
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1); echo "subtree_exit=$?"
subtree_exit=0
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf   # == HEAD
```

**[O] The census is byte-unchanged and its cited command still fails verbatim from the repo root.**
That is a live prose-cites-a-command defect in the file `PROVINCE.md:14` designates as the maintained
census.

**And the census has now drifted visibly from the artifact it describes:**

```
$ for c in c6f655d 8c9d9ad; do printf "%s gate=%s engines=%s\n" "$c" "$(git show $c:corpus/knowledge/unreal-mcp/gate/run_gate.sh | wc -l)" "$(git show $c:corpus/knowledge/engines.md | sha256sum | cut -c1-12)"; done
c6f655d gate=249 engines=d03907d3d637
8c9d9ad gate=347 engines=d03907d3d637
$ wc -l < corpus/knowledge/unreal-mcp/gate/run_gate.sh
442
```

**[O] `engines.md` has been byte-identical across three rounds (`c6f655d` → `8c9d9ad` → this frame)
while the gate it should point at went 249 → 347 → 442 lines.** Five commits total have ever touched
`engines.md` (`git log --follow`), and its last touch was `c6f655d`. **[I]** A census that moves only
when a probe lands drifts from the artifacts it describes — and it currently under-describes its own
strongest evidence (0 references to the gate that performs the check).

**Verdict: do this one.** It is cheap, unblocked, purely mechanical, fixes a *currently failing*
command, and closes the last of the r103 connector's three options. It is a ~2-line evidence-cell edit
plus a rules-block line.

### 4.3 Frontier 3 — the r105 round shape

**Measured state — the standing machinery is thinner than the round volume suggests:**

```
$ ls *.sh 2>/dev/null; ls corpus/*.sh corpus/fixtures/*.sh 2>/dev/null
(none = no top-level check script)
$ for t in run_gate run_battery flake_harness; do printf "%-15s corpus-code-refs=%s\n" "$t" "$(grep -rl "$t" corpus/fixtures/*.py corpus/fixtures/*.mjs 2>/dev/null | wc -l)"; done
run_gate        corpus-code-refs=0
run_battery     corpus-code-refs=2
flake_harness   corpus-code-refs=0
$ git show --stat 8c9d9ad | grep -c 'corpus/'; git show --stat 8c9d9ad | grep -c 'reports/'
6
60
```

**[O] There is no runner-of-runners.** A round produces ~60 report artifacts against ~6 corpus-file
touches. The lane's three standing checks — the battery, the gate, the flake harness — share no entry
point, and the newest one (`flake_harness.sh`) is referenced from **0** files outside the round's own
report tree:

```
$ grep -rn "flake_harness" --include=*.md --include=*.py --include=*.sh . | grep -v "round-104"
(no output)
```

**[I] This is the real frontier, and it is what the r102/r103/r104 "wiring" proposals have been
circling without naming.** The lane has repeatedly tried to attach the gate to the *battery* — a
350-row, ~13-minute harness whose verdict is a single PASS/FAIL. But the gate and the battery are
different *kinds* of check (static subtree identity vs. headless engine behaviour), they have
different failure vocabularies (BLOCKED vs. TIMEOUT), and §4.1 shows the battery's verdict expression
has no room for the gate's third state. **The gate does not belong inside the battery's verdict; it
belongs beside it, under an entry point that runs both and reports each in its own vocabulary.**

### 4.4 The r105 luna-max round shape

**Evidence state: I found no lane-local artifact defining a "luna-max" round shape.**
`grep -rni luna` over the lane repo returns one hit, inside a vendored `three.js` example
(`LDrawLoader.js:305`); `grep -rni "r105"` over the lane returns nothing. The only route evidence is
fleet-level and outside this lane's write scope:

```
$ grep -n "lunamax" /home/vgpnk/Projects/shokunin/.ufo/reports/AGGREGATE.md | head -2
585:Route buckets conform to the MISSION.md map (`planner`/`connector` → `m_lunamax`;
696:… the route-map half of the old claim is **fixed** (`m_lunamax`/`m_flash`/`m_zfl` = the MISSION bucket)
$ grep -n "luna" /home/vgpnk/Projects/shokunin/.ufo/reports/round-12/kumitate.md | head -2
176:planner/connector `@m_lunamax` · executor/scribe/scout `@m_flash` ·
```

**[O]** So `m_lunamax` is the **planner/connector route bucket** on this fleet's route table — a *model
routing* fact, not a round-shape spec. **[I]** On the evidence available here, "the r105 luna-max round
shape" means *"a round whose planner/connector seats run on the lunamax route"*, and it is an
**operator/L1 scheduling decision with no lane-repo artifact behind it.** This seat can name it but
cannot recommend on it without inventing a spec — and per the round brief, model routing is decided by
the route table, never by the lane repo. **Flagged as an open question in §6 rather than answered.**

---

## 5. Recommendation for r105+

**Primary — a gate receipt + a runner-of-runners (coverage).** This is the move §4.3's measurement
justifies and the one the previous three rounds' wiring proposals were reaching for.

1. **Give the gate a machine-readable receipt.** Today it writes stdout only — still true, no
   `--receipt` flag exists (`grep -n "receipt" run_gate.sh` → no output). A `--receipt=<path>` that
   writes JSON `{verdict, exit, work_root, checks:[…], sha256s}` makes the gate's result *quotable*
   instead of *transcribable*. **Acceptance:** two consecutive runs produce byte-identical receipts
   modulo the timestamp, and the receipt's `verdict` field agrees with the run's own `GATE RESULT:`
   line and its exit code — the exact three-way agreement `flake_harness.sh` already checks.
2. **Add a top-level `check_all.sh` that runs battery → gate → flake harness in that order and
   reports each verdict in its own vocabulary**, never folding them into one code. **Acceptance:**
   with `GATE_WORKDIR` set to a real-disk path, the script exits 0 and prints three verdicts; with
   `GATE_WORKDIR` unset under quota pressure, it prints `gate=BLOCKED` and **still exits 0** — because
   a blocked static check is not a battery failure. *Owner:* one seat; this is the "no runner-of-
   runners" gap and it is small.

**Second — the `engines.md` census fix (coverage, unblocked, do it first because it is cheapest).**
1. Fix `engines.md`'s Unreal-row evidence cell to a **repo-root-runnable** command — either the
   `(cd corpus/knowledge/unreal-mcp && sha256sum -c …)` form or, better, a pointer to
   `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`, which resolves its own cwd.
2. Add a `run_gate.sh` reference to the rules block (`engines.md:13-16`), and cite the gate **by
   behaviour**, not by a bare sha — §1.2 shows the sha moved four times in one round.
   *Acceptance:* the cited command exits 0 verbatim from the repo root, and
   `grep -c run_gate corpus/knowledge/engines.md` ≥ 1. *Owner:* one seat owning `corpus/knowledge/engines.md`.

**Third — rule the exit-2 collision before *any* battery wiring (calibration).** Still an L1 decision,
and §4.1 now supplies the executed proof rather than an argument. Either (a) declare the gate's exit 2
a lane-wide third state and reconcile `corpus/fixtures/README.md`'s **"Exit contract"** table (whose
`negative control rejects as intended → 2` row is the colliding entry), or (b) **reject exit 2 for the
gate** and let the unambiguous `BLOCKED` **stdout token** carry the distinction. **(b) is cheaper and
collides with nothing.** *Acceptance:* the convention is written in `LOG.md`, and
`corpus/fixtures/README.md` and `gate/README.md` no longer contradict each other or the script.

**Fourth — `GATE_WORKDIR` must be the *documented default*, not an optional flag (coverage).**
§3.3 is the evidence: the unqualified invocation flapped across **three verdicts in six runs**. The
README documents `GATE_WORKDIR` (11 mentions at this frame), but the *recommended* invocation must set
it, and the
`network`-vs-`local-resource` misattribution in `run1`/`run4` should be closed by establishing the
cause before naming it. *Acceptance:* the README's canonical command sets `GATE_WORKDIR`, and a
quota-exhausted clone is never labelled `(network)`.

**Queue as small repairs (no ruling needed):**
- `run_gate.sh`'s `BLOCKED (network)` branch: soften to *"clone did not complete"* until the cause is
  established, or probe reachability separately. (§3.3, `run1`/`run4`.)
- The **13 `r94_cannon_*` rows**: an operator/L1 decision — they are a **node-version pin** problem
  (`node=v24.21.0` markers vs host `v26.12.0`), not a physics or fixture defect, and they are the
  entire remaining battery red after C1. **Do not** silently re-baseline 13 markers.

**Defer — the SKILL.md content review.** The file exists (§3.4); whether its A–E rows discharge the
r103 review's four REVISE findings is a **non-author verification** task, not a connector's. Note that
its citations stamp `run_gate.sh @ 577c8b54…`, which §1.2 shows is **two revisions stale**.

---

## 6. Open questions for the L1 / operator (not blocking)

1. **The r105 "luna-max round shape" has no lane-local definition** (§4.4). `m_lunamax` is the
   planner/connector *route bucket* in the fleet route table. If a specific round shape was intended,
   it lives outside this lane repo and this seat could not read it.
2. **`GATE_WORKDIR` default policy.** Should the lane's canonical gate command *require* an explicit
   `GATE_WORKDIR`, given §3.3's six-run three-verdict flap? A required flag is a contract change.
3. **The 13 `r94_cannon_*` rows** need an operator decision: re-pin the node markers to the host, pin
   the host node to v24, or retire the rows.

---

## 7. What a later seat must not assume

- **Every number here is a frame, not a constant.** The gate moved 347 → 352 → 433 → 442 lines inside
  eight minutes, one revision did not parse, and I twice mis-read a landed fix as unlanded. **Re-measure
  before editing.** The r103 law — *falsification verdicts must name the target's hash* — applies to
  connectors, not only to attack seats.
- **`POINTERS=101` is scanner- and tree-relative** and the gate's own README says so. `UNRESOLVED=0`
  is the binding invariant.
- **A `BLOCKED` result is not a pass and not a fail.** In this lane exit 2 *also* means a *passing
  negative control* — read the token, not the code. The mixed case loses the third state entirely
  (§4.1).
- **The default-workdir gate verdict is host-weather.** `df` reported 3.1G free while `echo x > /tmp/f`
  failed with `Disk quota exceeded`; six runs gave BLOCKED / BLOCKED / FAIL / BLOCKED / BLOCKED /
  BLOCKED. An unqualified invocation is not a reproducible experiment.
- **C1 fixed exactly one row.** The 13 `r94_cannon_*` failures are a node-version pin problem and are
  untouched. Expected battery state after C1: **337 pass / 13 fail.**
- **A green gate is not a clean bill and says so itself.** It proves 12 vendored files equal a manifest
  and a fresh clone at the pin, and that four static checks ran. It says nothing about plugin load,
  UBT compilation, or editor behaviour.
- **No Unreal runtime claim appears in this file**, and none can exist on this host.

---

## 8. Limits of this report

- **Read-only except this file.** No commit. I wrote no `corpus/` byte, no fixture, no gate, no
  `LOG.md`/`SCORECARD.md`/`SHONEN.md`/`PROVINCE.md`/`SKILL.md` byte, no other seat's report. Every
  mutation test ran on a copy under `/home/vgpnk/scratch-r104/`.
- **I ran 1 battery row, not 350.** I ran `--only phys3d_joints_free_ops` to verify C1 end-to-end, and
  read the r102 idle-run receipt for the rest. I assert nothing new about the 13 `r94_cannon_*` rows
  beyond what the receipt and the marker grep show.
- **I did not author any of r104's fixes.** All three landed from sibling seats; my contribution is
  independent re-execution (§2, §3.2), the live reproduction of the C2 hazard (§3.1), and the
  re-measurement of the three frontiers (§4).
- **`/tmp` was under per-user quota pressure throughout this seat** (13G of 16G; `df` unusable as a
  pre-flight). That both limited my scratch copies and — usefully — produced §3.1 and §3.3.
- **The gate's final sha is `e55213049db7…` (442 lines) at `2026-10-18T19:23Z`.** It had moved four
  times before that and may have moved again.
- **I could not locate a lane-local definition of the r105 luna-max round shape** (§4.4) and did not
  invent one.
- **This file was written about citation rot, so it was audited for citation rot.** After drafting I
  re-checked every line-number citation against the live frame and **four of them had already rotted**
  inside my own writing window: the `run_battery.py` anchors (`:1230-1237` → the `--probe-failing`
  argument at `:1230`; `:1374-1376` → the `verdict = (…)` expression at `:1366`), the gate README's
  mixed-case residual (`:221` → `:299`), and the `GATE_WORKDIR` mention count (6 → 11). All four were
  corrected and re-verified; the six line-cites that remain were each re-read with `sed -n` at
  `2026-10-18T19:25Z` and matched. The `gate/run_gate.sh:407` in §1.2 is a **transcript** of a
  transient intermediate, not a citation — that revision no longer exists.
