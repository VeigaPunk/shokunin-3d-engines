# r102 · SEAT-34 BATTERY-RELATION — wiring `run_gate.sh` into `run_battery.py`

Lane: `game-dev-3d-shokunin` · round r102 · HEAD at run `2c99b7b`
(`1659c036` work commit) · written 2026-10-18.
Owned path: this file only. **No fixture was edited, no gate was edited, no
`run_battery.py` line was changed.** Every `/tmp` tree below is a private copy;
`git status` at the end of this seat is listed in §7.

Subject: the r101 connector's **IP-2** gap — `corpus/fixtures/run_battery.py`
`seed_digests()` (`:940-946`) roots at `HERE = corpus/fixtures` (`:35`) and its
130-entry map contains **0** paths under `corpus/knowledge/`, so the r101
`unreal-mcp` subtree's bytes are outside the lane's only standing mutation gate.
C1(a) has since landed the close-out gate
`corpus/knowledge/unreal-mcp/gate/run_gate.sh` (sha256
`214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`,
matching SEAT-18's `reports/round-102/gate/mutation.md`). This seat proposes the
**call site** that makes it standing, and reports what a call site must survive.

Confidence tags: **[O]** observed on this host with the command shown · **[I]**
inference · **[?]** unknown.

---

## 0. Verdict

**Wire it, but not as a bare `subprocess` fold of the exit code.** The gate is
fast (0.77–1.07 s), deterministic, fail-closed, and its own negative controls
work (§2). Three measured facts make a naive fold wrong, and each has a cheap
fix at the call site:

1. **A truncated read of a subtree a peer is writing turns the gate red for
   reasons that are not byte divergence** — reproduced 15/15 (§3.1). Fix: the
   call site must classify the gate's output, not just its exit code, and must
   not let a stale read be reported as a mutation.
2. **Check 2 clones the default branch and demands `HEAD == pin`.** In a
   synthetic repo where `main` advanced past the pin, that check goes red while
   the vendored claim is still true; `git fetch --depth 1 <repo> <pin>` returns
   the pin exactly, before and after `main` moves (§3.2). Fix: fetch-by-SHA, or
   classify drift distinctly.
3. **The gate has no `--offline`.** Unreachable upstream → `STEP=FAIL`,
   `BLOCKED, not PASS`, exit 1, in 0.14 s (§3.3). A wired check therefore makes
   the battery network-dependent **for the first time** — both runners contain
   zero network calls (`grep -n "http\|network\|clone\|urlopen\|requests\|socket"`
   over both → no output, rc=1). Fix: a hermetic pin-check alternative that
   never touches the network (§5), prototyped and negative-controlled here.

A fourth, unrelated finding came out of the timing run and is recorded in §8:
**the unmodified battery is red on this host** — `336/350`, with 13 of the 14
failures being `r94_cannon` rows whose markers are byte-pinned to
`node=v24.21.0` while the host runs `v26.12.0`. That is not this seat's to
repair and not a subtree fact, but it means a wired green gate and a red battery
can coexist, and the call-site print must name its subject.

---

## 1. The gap, re-measured this seat

```
$ python3 -c "import importlib.util,sys; sys.dont_write_bytecode=True; \
  s=importlib.util.spec_from_file_location('rb','corpus/fixtures/run_battery.py'); \
  rb=importlib.util.module_from_spec(s); s.loader.exec_module(rb); \
  k=rb.seed_digests(); print(len(k), sum('knowledge' in x for x in k))"
130 0
```

Run twice this seat (17:43 and 17:45), unchanged. The gate exists; the call site
does not: `grep -rln "run_gate" corpus/fixtures/` → no output. So today the
subtree's integrity rests on a human remembering to run the gate, which is the
exact shape `seed_digests()` exists to replace mechanically.

**What folding the subtree into `seed_digests()` would cost [O].**

```
$ python3 … fold("corpus/knowledge") …
fixtures entries: 130  knowledge entries: 45  folded total: 175
$ du -sb corpus/knowledge
430820
```

45 files / 0.43 MB / ≈1 ms — cheap. But it is the **wrong** mechanism here, for
a reason this round demonstrates: `seeds_unchanged` is computed over the
battery's own run window, and `corpus/knowledge/` is *live round prose* that
peers write mid-round. `engines.md` carries mtime `14:42:49` this round while
seats were still running. A folded digest map would make the Godot battery fail
whenever any seat edits a lesson-adjacent knowledge file during a run — a
concurrency coupling, not a mutation gate. **Recommendation: do not fold;
call the gate.** (The fold also cannot reuse the manifest, so it would re-derive
12 hashes the manifest already pins.)

---

## 2. The gate as the call site would see it

```
$ time bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
GATE RESULT: PASS (checks failed: 0)
exit=0                       # real 0m0.801s  (3 reps: 1066 / 774 / 880 ms)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_TRACKED=12  PATH_EXTRA=0 PATH_MISSING=0  BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

Interface facts the call site depends on **[O]**:

| property | value | anchor |
|---|---|---|
| machine-greppable summary | `GATE RESULT: PASS (checks failed: 0)` | `run_gate.sh:198-199` |
| per-check token | exactly four `STEP=PASS` / `STEP=FAIL` lines | `:66,117,156,195` |
| exit | `0` iff all four `PASS`, else `1` | `:200` |
| cwd-independent | resolves its subject from `$BASH_SOURCE` | `:35` |
| own timeout | `timeout 180 git clone` | `:86` |
| writes | `mktemp -d`, removed by `trap` on exit | `:47-49` |

**Non-mutation, measured.** The subtree's aggregate hash is identical across
three consecutive gate runs:

```
$ find corpus/knowledge/unreal-mcp -type f -exec sha256sum {} + | sort | sha256sum
b13aff2f66e1732bce44c6863428d60b641a338097e41f1e04698c53247e3954  -
$ for i in 1 2 3; do bash …/run_gate.sh >/dev/null 2>&1; echo "rep $i exit=$?"; done
rep 1 exit=0 / rep 2 exit=0 / rep 3 exit=0
b13aff2f66e1732bce44c6863428d60b641a338097e41f1e04698c53247e3954  -
```

**Sensitivity, measured.** One appended byte in a private copy:

```
$ cp -r corpus/knowledge/unreal-mcp /tmp/seat34-gcopy && printf '\n' >> /tmp/seat34-gcopy/upstream/README.md
$ bash /tmp/seat34-gcopy/gate/run_gate.sh; echo "exit=$?"
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL … STEP=FAIL
GATE RESULT: FAIL (checks failed: 2)
exit=1
```

So the gate is a good *check*; §3 is about making it a good *call site*.

---

## 3. Three measured hazards for the call site

### 3.1 A concurrent writer makes the gate red for a stale read — reproducible 15/15 [O]

Earlier this seat I observed one `STEP=FAIL ×3` run at ≈17:43:5x that was green
20 s later. That was not a flake in the gate; it is a *read race* against a
writer, and it reproduces on demand. A background writer that truncates and
rewrites `upstream/README.md` while also appending to the subtree `README.md`:

```
$ rm -rf /tmp/s34conc2 && cp -r corpus/knowledge/unreal-mcp /tmp/s34conc2
$ ( for i in $(seq 1 60); do : > …/upstream/README.md; sleep 0.005; \
      cat …/upstream/CODEOWNERS > …/upstream/README.md; \
      printf 'upstream/README.md:%s\n' "$((i*100))" >> …/README.md; sleep 0.005; done ) &
$ for i in $(seq 1 15); do bash /tmp/s34conc2/gate/run_gate.sh >/dev/null 2>&1; echo "rep $i rc=$?"; done
… rc=1 (×15) …
FAILED reps with a truncating writer: 15/15
```

The failing lines are diagnostic — they name a *read* artifact, not a byte
difference:

```
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
BLOB_DIFFS=1
POINTERS=79 SKIPPED_CONTROL_SENTINELS=1 UNRESOLVED=52
```

`POINTERS=79 / UNRESOLVED=52` is not a plausible pointer regression in a subtree
whose clean value is `POINTERS=40 / UNRESOLVED=0`; it is the gate reading a file
mid-append. **Control:** the same experiment with a writer that appends only
well-formed pointer lines (no truncation) gave **0/12 failures** — so the hazard
is specifically *truncate-then-rewrite*, i.e. a peer seat replacing a file with
an editor's write-temp-rename or a shell truncation, not mere growth.

**Consequence for the call site.** A wired check that reports only `exit != 0`
will, during a concurrent round, print `FAIL` for a subtree that is byte-clean a
second later. That is the same false-red class the lane already guards against
elsewhere. The fix is not to weaken the gate: it is to have the call site record
the gate's own tokens and, on failure, re-run once after a short settle before
committing to a red — and to record both runs. A single retry is cheap (0.8 s)
and makes the wired check *stronger* than a manual run, because the receipt then
carries the transient too.

### 3.2 Check 2 is not pin-stable: `main` moving reds a true claim [O]

`run_gate.sh:86` clones the **default branch** and `:92` requires
`HEAD == PIN`. Synthetic repo, pin = first commit, `main` advanced to a second:

```
$ PIN=0bcfebf6… ; main now: 4dd83b39…
$ git clone -q /tmp/seat34-tb/origin cloneA && git -C cloneA rev-parse HEAD
4dd83b39942e833ba56231998eb776cc11f9557f
HEAD==PIN: NO -> gate check 2a goes red though the vendored claim is still true

$ mkdir fetchB && cd fetchB && git init -q . && git fetch -q --depth 1 /tmp/seat34-tb/origin "$PIN"
FETCH_HEAD=0bcfebf6e9cdff09190a8688d7a6f7050645da95
FETCH_HEAD==PIN: yes (pin-stable after main advanced)
```

Against the **real** upstream, fetch-by-SHA is just as cheap and equally exact:

```
$ time git fetch -q --depth 1 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin a6aa73ad…
real 0m0.620s   rc=0
FETCH_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
ls-tree count=12
```

The gate's README defends 2a as deliberate (*"a `main` that has moved past the
pin is a FAIL, because the subtree's claim is 'vendored at this SHA'"*). That is
a defensible **standalone** stance, and this round the two agree — SEAT-59's
`freshness-pin.md` found `main` still at the pin at 17:41:23Z. But for a
**standing** check the construction matters: as written, the check is red on
*upstream activity*, which is not lane-controlled, and it is red with the same
exit code as a real byte divergence. If the call site folds it into a verdict,
then the first upstream commit after the pin silently reds every battery run
until someone re-vendors.

**Consequence.** Two acceptable call-site postures, both honest; the report does
not pick for the round:

- **(i) fetch-by-SHA** (`git init && git fetch --depth 1 <repo> <pin>`), which
  is pin-stable by construction and keeps 2c/2d unchanged (`git ls-tree` in
  place of `git ls-files`, since there is no worktree);
- **(ii) keep the clone, classify the drift** — the call site reads
  `CLONE_HEAD` and reports a distinct `PIN_DRIFT` outcome (neither PASS nor a
  byte-mutation FAIL), so a moved `main` cannot masquerade as corruption. This
  is the same complaint `reports/round-102/fold-spec.md` A4 raises about
  `BLOCKED` vs `FAIL` sharing one exit channel.

### 3.3 The gate has no `--offline`, and folding it imports a network dependency [O]

```
$ grep -c "offline\|STEP=SKIP" corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
$ GIT_PROXY_COMMAND=/bin/false https_proxy=http://127.0.0.1:9 bash …/run_gate.sh; echo "exit=$?"
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
exit=1                       # real 0m0.135s
```

Correct fail-closed behaviour, but it means: (a) the gate cannot run in an
air-gapped close-out; (b) a wired battery would be network-dependent for the
first time. Measured network cost when it *does* work: shallow clone 240 KB,
0.6 s; the gate's own hard cap is `timeout 180` (`:86`), so the wired battery's
worst case grows by up to ~180 s.

---

## 4. Patch sketch (proposal — `run_battery.py` is NOT edited by this seat)

The lane's own extension point is the four `probe_*` helpers folded into
`main()`'s verdict: `--probe-crash-exit` / `--probe-stream-attribution` /
`--probe-tree-timeout` (`:1232-1237`) each set a `*_probe_ok` bool
(`:1288-1296`), which `:1366-1368` ANDs into `verdict`, and `:1369-1381` records
in `verdicts.json`. A vendor-gate check should use exactly that shape — no new
idiom, no new artifact, ~35 lines.

**Sketch A — the wiring (four hunks).**

```python
# (1) module level, near CASE_TIMEOUT_SECONDS (:36)
VENDOR_GATE = HERE.parent / "knowledge" / "unreal-mcp" / "gate" / "run_gate.sh"
VENDOR_GATE_TIMEOUT = 300          # gate's own clone cap is 180 s

# (2) beside the other probe_* helpers (:1101)
def probe_vendor_gate(run_dir, offline):
    """Run the r101 unreal-mcp close-out gate and fold it into the battery.

    Returns True only for a full green run. Three outcomes stay distinct so a
    stale read or a degraded run can never be read as a mutation PASS:
      gate absent                 -> MISSING  (not-wired is never PASS)
      exit != 0                   -> FAIL
      exit 0 with a STEP=SKIP     -> PARTIAL  (degraded run is not green)
      exit 0, four STEP=PASS      -> PASS
    """
    if not VENDOR_GATE.exists():
        print(f"FAIL vendor-gate: {VENDOR_GATE} absent (not wired, not PASS)")
        return False
    command = ["bash", str(VENDOR_GATE)] + (["--offline"] if offline else [])
    record = {"gate": str(VENDOR_GATE), "command": command, "offline": offline}
    for attempt in (1, 2):                      # one settle-retry, see §3.1
        stdout, stderr, code, error = run_process(command, VENDOR_GATE_TIMEOUT)
        steps = [l.strip() for l in stdout.splitlines() if l.startswith("STEP=")]
        record[f"attempt{attempt}"] = {
            "exit": code, "error": error, "steps": steps,
            "skipped": steps.count("STEP=SKIP"),
            "result_line": next((l.strip() for l in stdout.splitlines()
                                 if l.startswith("GATE RESULT:")), ""),
            "stdout": stdout.strip().splitlines(),
            "stderr": stderr.strip().splitlines()}
        ok = code == 0 and not steps.count("STEP=SKIP") and len(steps) == 4
        if ok or attempt == 2:
            break
        time.sleep(1.0)                         # let a concurrent writer settle
    record["verdict"] = "PASS" if ok else ("PARTIAL" if code == 0 else "FAIL")
    (run_dir / "vendor-gate.json").write_text(json.dumps(record, indent=2) + "\n")
    print(f"{record['verdict']} vendor-gate: exit={code} "
          f"steps={record['attempt%d' % attempt]['steps']} "
          f"-> {run_dir / 'vendor-gate.json'}", flush=True)
    return ok

# (3) flags, beside :1236
parser.add_argument("--vendor-gate", action="store_true",
                    help="also run the unreal-mcp close-out gate and fold it into the verdict")
parser.add_argument("--vendor-gate-offline", action="store_true",
                    help="pass --offline to the gate: check 2 degrades and the gate is PARTIAL, never PASS")

# (4) call site beside :1294-1296, and the verdict/payload fold
vendor_gate_ok = True
if args.vendor_gate:
    vendor_gate_ok = probe_vendor_gate(run_dir, args.vendor_gate_offline)
# :1366
verdict = ("PASS" if failed == 0 and seeds_unchanged and crash_probe_ok
           and stream_probe_ok and tree_probe_ok and vendor_gate_ok
           and (probe is None or probe["verdict"] == "PASS") else "FAIL")
# :1376 payload
"vendor_gate": args.vendor_gate, "vendor_gate_offline": args.vendor_gate_offline,
"vendor_gate_ok": vendor_gate_ok,
```

**Why `--vendor-gate` is a flag and not unconditional.** Unconditional wiring
would make `python3 corpus/fixtures/run_battery.py` — the lane's most-run
command, documented at `corpus/fixtures/README.md:20-22` — network-dependent and
would put a 0.8 s-to-180 s subtree gate in the path of every `--only` smoke run.
The flag mirrors how the three probes are opt-in today, and it keeps the
Godot battery's own contract (*"the Godot battery stays untouched (prior rows
byte-stable)"*, `bpy_battery.py:1-7`) literally true: the vendored subtree is a
different artifact and gets its own opt-in check.

**Sketch B — the sibling-runner alternative, rejected.** A separate
`unreal_battery.py` under `corpus/knowledge/unreal-mcp/` (the r79 `bpy_battery.py`
precedent, `r101-connector.md` IP-3) was considered. It is the wrong shape here:
`bpy_battery.py` exists because Blender *has* a headless mode and the case model
differs; this gate has **no runtime cases** — it is one artifact check with four
sub-checks and a single exit code. A runner whose entire body is
`subprocess.run(["bash", gate])` adds an artifact and a maintenance surface
without adding a case model. The gate *is* the runner; what is missing is the
call site. `reports/round-102/r102-boundary-scout.md` §5 reaches the same
conclusion independently (*"the only thing that closes IP-2 is a call site, not
a file move"*), and `reports/round-102/r102-connector.md` IP-2 option 1 proposes
the same flag.

**Sketch C — the lane close-out script, complementary.** Option 2 of
`r102-connector.md` IP-2 (a `reports/` script running battery + bpy + three +
gate) is worth having *in addition*, because it is the only place where all four
runtimes are checked in one command. It does not substitute for Sketch A: a
close-out script is another human-run procedure, and the point of IP-2 is to
stop relying on those.

**Receipt for the sketch.** I ran the sketch's exact classification logic
standalone against the real tree (the file is `/tmp/seat34-sketch/sibling_check.py`,
a `/tmp` scratch file — **not** a fixture, not landed):

```
$ python3 /tmp/seat34-sketch/sibling_check.py
offline=False ok=True  exit=0 steps=['STEP=PASS','STEP=PASS','STEP=PASS','STEP=PASS'] skipped=0 verdict=PASS
    GATE RESULT: PASS (checks failed: 0)
offline=True  ok=True  exit=0 steps=['STEP=PASS','STEP=PASS','STEP=PASS','STEP=PASS'] skipped=0 verdict=PASS
    GATE RESULT: PASS (checks failed: 0)
```

and against a `--offline` prototype tree (a patched copy in `/tmp`, §5):

```
ok= False verdict= PARTIAL steps=['STEP=PASS','STEP=SKIP','STEP=PASS','STEP=PASS'] skipped= 1
    GATE RESULT: PASS (checks failed: 0)     # exit 0, but degraded -> not green
missing gate: ok= False verdict= MISSING | gate absent — not wired, not PASS
```

That last line is the point of the classification: the prototype prints
`GATE RESULT: PASS` **and exits 0** while one of four checks did not run. A call
site that reads only `returncode` would report a degraded run as a full PASS.

---

## 5. The `--offline` pin-check alternative (proposed, prototyped, controlled)

Two distinct things are being conflated by "offline", and they deserve different
answers:

**(a) `--offline` on the gate** — degrade check 2 to `STEP=SKIP` and print it.
I prototyped this on a `/tmp` copy only (adding `OFFLINE=1` on `--offline`, a
`SKIP` branch in check 2, and `elif C2_PASS -eq 2 … STEP=SKIP`):

```
$ bash /tmp/seat34-gate-off/gate/run_gate.sh --offline; echo "exit=$?"
STEP=PASS
STEP=SKIP
STEP=PASS
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
exit=0
```

This is exactly the third state `fold-spec.md` A4 asks for, and it satisfies
`r102-connector.md` IP-4's requirement (*"a green offline run can never be
mistaken for a green online run"*) **only if the call site treats `STEP=SKIP`
as not-green** — hence the `PARTIAL` verdict in Sketch A. Landing it is a
C1-owned edit to a byte-pinned artifact, so this seat proposes and does not
apply it.

**(b) A hermetic pin-check the call site can run itself, with no gate change.**
If the round prefers not to touch the gate, the call site can run an offline
check that reuses artifacts already on disk and needs no network at all. Four
checks, prototyped as `/tmp/seat34-offline-gate.sh`:

1. `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256` —
   measured rc=0, **24** `OK` rows, ≈1 ms (12 in the audit reference + 12 in the
   seat shards; note `run_gate.sh:58` checks only the 12, `fold-spec.md` A5);
2. the declared pin line equals the expected pin —
   `grep -q "pinned SHA: $PIN" .manifest.d/audit-reference.sha256`;
3. **path-set equality, offline**: manifest rows vs on-disk `upstream/` files —
   measured `12 == 12`, `set-equal: True`, no extras either way;
4. `upstream/.git` absent (a nested clone would silently double-count).

Negative controls, each on a private copy:

```
delete_file  rc=1 :: CHECK1 FAIL CHECK3 FAIL ['upstream/LICENSE']
pin_tamper   rc=1 :: CHECK2 FAIL
extra_file   rc=1 :: CHECK3 FAIL ['upstream/EXTRA.md']
clean tree   rc=0
```

This is strictly weaker than the gate's check 2 (it cannot see a file that was
never copied *and* never manifested, nor compare against upstream blobs) — but
it is **hermetic**, it reuses the manifest already proven sensitive, and it
catches the three failure classes that matter offline: a mutated byte, a
tampered pin declaration, and an added file. Proposed usage: the call site runs
the gate when the network is up and this pin-check otherwise, and records which
one produced the receipt. That is `r102-connector.md` IP-4's *"degrade and print
that it degraded"* without touching the gate.

---

## 6. Risks register

| # | risk | severity | evidence | mitigation at the call site |
|---|---|---|---|---|
| R1 | wired check is network-dependent; battery has none today | high | §3.3; own `grep -n "http\|network\|clone\|urlopen\|requests\|socket"` over both runners → no output, rc=1, while `run_gate.sh:27,86` has a URL and a clone | `--vendor-gate` opt-in; hermetic pin-check fallback (§5b) |
| R2 | concurrent writer → stale-read red, indistinguishable from mutation | high | §3.1, 15/15 reproducible; real transient seen at 17:43:5x | classify tokens; one settle-retry; record both attempts |
| R3 | `main` drift reds a still-true vendored claim (same exit code as corruption) | medium | §3.2 synthetic repo; real upstream still at pin (SEAT-59) | fetch-by-SHA, or a distinct `PIN_DRIFT` outcome |
| R4 | degraded (`STEP=SKIP`) run reads as PASS by exit code | medium | §4 prototype: exit 0, `GATE RESULT: PASS`, one check skipped | require four `STEP=PASS`; `PARTIAL` otherwise |
| R5 | wired worst case adds up to 180 s (gate's clone cap) | low | `run_gate.sh:86`; normal run 0.77–1.07 s | keep it a flag; exclude from `--only` smoke runs |
| R6 | a red gate at round close may be a peer's in-flight write, not a defect | medium | §3.1; round-102 writers were active at 17:43 and 17:45 | re-run once after settle; the wired receipt should carry the retry |
| R7 | `unproven-runtime` over-read: a green gate is not live-editor evidence | high (epistemic) | `gate/README.md:18-22`; `PROVINCE.md:21-22` | the call-site print and JSON must repeat "no Unreal runtime claim" |

**Retraction of a claim I made mid-seat.** I briefly read the nested-card test
as a false-PASS in check 3. It is not: `run_gate.sh:130` uses
`find "$SUB/executability" -maxdepth 1 -type f -name '*.md'`, and a duplicate
card placed at `executability/nested/dup.md` is correctly excluded
(`CARDS=13`, exit 0). Recorded here so the claim is not inherited.

**Not re-litigated here.** `fold-spec.md` A1–A5 (range-pointer under-coverage,
card-name set, `BLOCKED` vs `FAIL`, shard manifests) are gate-internal
proposals owned by other seats; this report only notes where they interact with
a call site (R3, R4, §5b item 1).

---

## 7. Receipts and write scope

**Commands run this seat (all from the lane repo root unless noted).** Digest map
(×2) · full gate (×3 timed, ×8 in a loop, ×3 non-mutation reps, ×1 from `/tmp`,
×1 with an unreachable repo, ×1 against a one-byte mutation) · `/tmp` clones and
`git fetch --depth 1 <sha>` against the real upstream and a synthetic repo ·
hermetic pin-check with three negative controls · a 15-rep truncating-writer
race with a 12-rep non-truncating control · the sketch's classification against
green, `--offline`-prototype, and absent-gate inputs · `find`/`du`/`sha256sum`
over `corpus/knowledge`. `python3 corpus/fixtures/run_battery.py` (full, no
flags) was started as a background timing receipt.

**Write scope.** This file, plus `/tmp/seat34-*` scratch (sketches, prototypes,
copies, synthetic repos) which is disposable and outside the repo. No fixture,
gate, lesson, report of another seat, `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
`SKILL.md`, or `PROVINCE.md` was written.

```
$ git status --porcelain
 M corpus/artifacts/unreal-r22/README.md        # other seats (F1a / F8)
 M corpus/knowledge/engines.md                  # C1(c)
 M corpus/knowledge/rea.md                      # F6
 M corpus/knowledge/unreal-mcp/README.md        # other seats
 M corpus/lessons/r22-unreal-review.md          # F1/F2
?? corpus/knowledge/unreal-mcp/gate/            # C1(a)
?? corpus/lessons/r102-unreal-integration.md    # C1(b)
?? reports/round-102/                           # the round's reports, incl. this file
```

`corpus/fixtures/` appears in neither list — consistent with
`reports/round-102/battery-integrity.md` (SEAT-33), which independently proved
zero byte change there this round.

**Independent cross-check on the gate's identity.** My `sha256sum` of
`gate/run_gate.sh` (`214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`)
and of `gate/README.md` (`def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8`)
match the round-close baseline table in `reports/round-102/fold-spec.md` §1 and
SEAT-18's header in `reports/round-102/gate/mutation.md`. Three seats, one
identity — so the gate this report describes is the gate the round is folding.

**Limits.** This is a proposal, not a landing: `run_battery.py` is unmodified
and its 350 `CASES` rows are untouched, so the sketch carries no battery-side
receipt — only the classification logic has been executed, standalone, against
real gate output (§4). No Unreal runtime claim is made anywhere: the editor is
not installed, and nothing above promotes an `unproven-runtime` card. Which of
§3.2's two postures to adopt, and whether to land §5(a) as a gate edit, are
round/operator calls — not this seat's.

---

## 8. Side observation from the timing run: the battery is red on this host, for a reason outside the subtree

The full unmodified battery was run once for a wall-clock receipt:

```
$ python3 corpus/fixtures/run_battery.py          # 747 s wall
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
verdict FAIL, seeds_unchanged=true
FAIL battery: corpus/live/runs/20261018T174423377345Z/verdicts.json
```

The 14 failures split into two groups, **neither caused by this seat** —
`corpus/fixtures/` is byte-identical to HEAD (SEAT-33's `battery-integrity.md`,
and my own `git status --porcelain` in §7 shows no `fixtures/` entry):

**13 of the 19 `r94_cannon` rows: host Node-version drift [O].** All 13 markers
are byte-pinned to `node=v24.21.0`; this host runs `node v26.12.0`
(`/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`). The marker can
therefore never match:

```
$ grep -o "node=v[0-9.]*" corpus/fixtures/run_battery.py | sort -u
node=v24.21.0
$ node --version
v26.12.0
```

The diff is **exactly one token** — every simulation value is identical:

```
$ python3 … difflib over marker vs observed stdout for r94_cannon_det …
marker==stdout: False
- PASS r94_cannon det node=v24.21.0 det_base{rc=0,m=M0 case=det_base engine=cannon-es-0.20.0+three-0.186.1|M … y@1=4.997272 y@30=3.733635 y@60=1.561085 y@120=1.499985 … stepnumber=240 time=4.000000000|M …
+ PASS r94_cannon det node=v26.12.0 det_base{rc=0,m=M0 case=det_base engine=cannon-es-0.20.0+three-0.186.1|M … (identical) …
?                            ^^^^^^
len marker 3357  len got 3357
```

Both strings are 3357 bytes and differ only in the `v24`/`v26` token. The r100
verifier's receipt was `342/350` with *its* eight failures being the eight r100
rows — no `r94_cannon` row — so this is a host-toolchain change since r100, not
a pre-existing defect. **This is not this seat's to repair** (it is a `CASES`
edit in a file I do not own), but it belongs in the round's record: on the
current host, `python3 corpus/fixtures/run_battery.py` is red for a reason that
has nothing to do with any artifact, and a reader who sees `336/350` should not
read it as 14 regressions. It is also, incidentally, an argument for the
`--vendor-gate` design in §4: the gate's own markers are hashes and counts, not
a pinned host toolchain string, so it does not have this failure mode.

**`phys3d_joints_free_ops`: the documented 20 s timeout [O].** Timeout under the
battery's `CASE_TIMEOUT_SECONDS = 20` (`:36`), and documented pre-existing:

> `reports/round-93/r93-baseline.md:147` — *"`phys3d_joints_free_pair` / `_ops` |
> PASS 9.59 s / 16.94 s | PASS 8.60 s / 17.22 s | **documented 20 s-timeout
> pair (pre-existing)**"*

Direct timing on this loaded host (load average ≈12 on 32 cores) shows the arm
sitting just past the cap:

```
$ time timeout 120 godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops
rep 1 rc=0 24338 ms   rep 2 rc=0 23892 ms   (PASS marker emitted; 7 cases x 3 backends of children)
```

So the row is a **load-margin** failure, not a hang: it passes in ~17 s on an
idle host (r93) and takes ~24 s here. I did not re-run it on an idle host, so
the "load, not defect" reading is an inference from the r93 baseline plus the
observed 24 s, not a proven fact — stated as such.

**Consequence for §4's patch.** Nothing above changes the proposal, but it does
sharpen R5: a wired `--vendor-gate` would have been *green* through this run
while 14 Godot rows were red, and a reader must not conflate the two. The
call-site print should therefore name its subject explicitly (e.g.
`vendor-gate: PASS (unreal-mcp subtree)`) so its green cannot be read as a
statement about the Godot rows.
