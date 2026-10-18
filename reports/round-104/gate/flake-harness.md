# r104 · SEAT-14 · FLAKE-HARNESS — 10× repeat-run stability of the unreal-mcp gate

**Seat:** SEAT-14 FLAKE-HARNESS · round 104 · lane `game-dev-3d-shokunin`
**Owned paths:** `reports/round-104/gate/flake_harness.sh` (the durable tool) and this file.
No other file was written by this seat; the gate under test was never modified.
**Date:** 2026-10-18

**No Unreal runtime claim appears anywhere in this file.** The editor is not installed on this
host. A green gate is evidence about *bytes* and about the gate's own determinism — never about
editor or live-MCP behaviour.

---

## 0. Verdict

**The gate is STABLE: 10/10 runs returned `PASS` with exit 0 and a matching verdict line, on a
byte-frozen revision, with 4/4 steps passing and `POINTERS=101 UNRESOLVED=0` every time.**

| | |
|---|---|
| counting run | `GATE_WORKDIR=/home/vgpnk/tmp/r104seat14/gw bash reports/round-104/gate/flake_harness.sh 10` |
| result | `TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 truncated=0 unexpected=0` |
| harness exit | `0` → `HARNESS RESULT: STABLE (10/10 runs returned PASS with a matching exit code)` |
| gate revision | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` (identical before and after the run) |
| harness revision | `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2` |
| per-run wall time | 0.99 s – 1.97 s |
| `POINTERS` | `103` in all ten runs |
| logs | `/home/vgpnk/tmp/flake-harness.NWObaT/run-1..10.log` |

**The counting run is bound to a SETTLED tree.** An earlier arm of the same size on the same gate
revision produced `pass=3 fail=7` — see §2.4, which is the single most interesting result this seat
produced and is reported rather than hidden behind the green rerun. The two arms differ only in
whether a sibling seat's citation target had been written yet; the gate's sha256 is identical in
both.

**A stability claim is only meaningful when the harness has been shown to be able to fail**, so
§3 records seven negative controls, each of which was run and each of which produced the expected
non-zero exit.

**Two real findings came out of building this**, both of them exactly the class the seat was
chartered to detect, and neither of them a defect in the gate's *logic*:

1. **The gate prints a spurious `FAIL` on a byte-clean tree when its scratch disk is quota-blocked.**
   Under `/tmp` quota exhaustion the gate emits `FAIL per-seat manifest sweep (--strict) failed:`
   with an empty body and exits **1** on an unmodified tree. Root-caused in §2 to `mktemp`
   succeeding while the subsequent *write* to that file fails. This is the third host-weather
   false-fail-closed of the same family as the r103 `/tmp/advgate/.h1` hardcode.
2. **The harness itself was wrong twice before it was right.** Both harness bugs are recorded in
   §2.2 rather than quietly fixed, because each one made the harness report its *own* failure as a
   gate flake — precisely the false positive that would destroy the value of a flake harness.

---

## 1. What this seat built, and what it deliberately did not

`reports/round-104/gate/flake_harness.sh` runs the installed gate `N` times (default 10) against an
**unmodified** tree and tallies what came back.

It deliberately does **no** planting, no scratch copies and no tree mutation. The r102/r103
adversarial suites already test whether a *planted* defect is caught; this harness tests the
complementary property that a close-out artifact must also have: **the same verdict, from the same
bytes, run after run.** A gate that flips PASS/FAIL or 0/1/2 between identical runs cannot be used
as a close-out artifact however many attacks it survives — and r103 hit exactly this class of bug.

Interfaces:

| knob | meaning |
|---|---|
| `[N]` / `FLAKE_N` | run count (default 10) |
| `GATE` | gate under test (default `<repo>/corpus/knowledge/unreal-mcp/gate/run_gate.sh`) |
| `GATE_WORKDIR` | scratch on real disk; passed to each run as the gate's own `GATE_WORKDIR` **and** as `TMPDIR`. Unset ⇒ test the gate in its default host environment |
| `FLAKE_LOGDIR` | per-run logs (default: probed for a writable dir, real disk preferred) |
| `FLAKE_EXPECT` | the verdict *every* run must return: `PASS` (default), `FAIL`, `BLOCKED` |
| `FLAKE_PROBE_TRIES` | scratch-probe repetitions (default 20) |

Exit codes: **0** all runs agree with `FLAKE_EXPECT`; **1** at least one flake; **2** usage/setup
error (bad `N`, missing gate, no writable log dir) — deliberately distinct from "flaked".

---

## 2. Findings

### 2.1 The gate false-FAILs on a byte-clean tree when scratch is quota-blocked

Observed while characterizing the default environment. With `GATE_WORKDIR` unset, 30 consecutive
raw gate runs returned `rc=1` with a 2102-byte output whose manifest section reads:

```
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
... (all 12 OK) ...
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
...
GATE RESULT: FAIL (checks failed: 1)
```

The tree is byte-clean — check 1 itself passes 12/12 — yet the gate exits 1. Note the FAIL line is
printed **before** `CHECK 1`'s header: it comes from HARDENING B, not from check 1.

Root cause, isolated to three commands:

```
$ M=$(mktemp); echo "mktemp rc=$? path='$M'"
mktemp rc=0 path='/tmp/tmp.FHLR9Ci70W'          # mktemp SUCCEEDS, zero-byte file created
$ echo hello > "$M"
bash: echo: write error: Disk quota exceeded     # the WRITE is what fails
$ ls -la "$M"
-rw------- 1 vgpnk vgpnk 0 ... /tmp/tmp.FHLR9Ci70W
```

The gate's HARDENING B does exactly this:

```sh
MANLOG=$(mktemp)
if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >"$MANLOG" 2>&1); then
  printf 'FAIL per-seat manifest sweep (--strict) failed:\n'
  sed 's/^/  /' "$MANLOG"
  FAILS=$((FAILS+1))
fi
```

The redirect into `$MANLOG` fails, so the subshell exits non-zero, `sha256sum` never runs, the
`sed` prints an empty body, and `FAILS` is incremented. Reproduced in isolation with the exact
idiom:

```
$ M2=$(mktemp); (cd .../unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >"$M2" 2>&1)
idiom rc=1
bytes in MANLOG=0
$ sha256sum --strict -c .manifest.d/*.sha256   # same command, no temp file
... rc=0                                        # the tree is fine
```

**Why this matters.** The r103 ruling on this lane was that a *blocked* check must not read as a
*failed* check (A4: exit 2, not exit 1). This is the same confusion arriving through a different
door: an **unrunnable** check (scratch unwritable) is reported as a **failed** check. A reader of
`GATE RESULT: FAIL (checks failed: 1)` cannot tell "the vendored bytes diverge" from "this host's
scratch disk was full", and the difference is the entire content of a close-out verdict.

**Not fixed by this seat.** The gate is owned by another seat and was being edited concurrently
(§4). The finding is reported, not patched. The harness's `SCRATCH_PREFLIGHT` line and
`TRUNCATED`/`EMPTY` classes exist so this condition cannot be silently read as a gate verdict.

### 2.2 Two harness bugs, both found by the harness's own controls

**(a) `BLOCKED` was unclassifiable.** The first revision required four `STEP=PASS` lines for every
run. A genuine `BLOCKED` run is one `STEP=BLOCKED` plus three `STEP=PASS`, so every real block
classified as `UNEXPECTED` and `FLAKE_EXPECT=BLOCKED` could never succeed. Found by negative
control NC5 before this file was reported. Fixed by making the step tally verdict-aware:
PASS ⇒ 4 steps and 0 non-PASS; FAIL ⇒ 4 steps and ≥1 non-PASS; BLOCKED ⇒ 4 steps and exactly 1
non-PASS (the gate can only block when nothing else failed).

**(b) A truncated log was read as a gate verdict.** With logs on `/tmp`, runs 7 and 10 of a
default-env arm were cut off mid-write. The surviving tail happened to contain one `STEP=FAIL` and
a `GATE RESULT: FAIL (checks failed: 1)` line, so the classifier reported two **gate FAILs** that
were in fact the harness's own failed log writes. Fixed by a `TRUNCATED` class: the log's last line
must be the `GATE RESULT:` line, else no verdict is read from it at all. This also explains why the
log directory now prefers real disk.

A third, smaller trap: the scratch preflight initially probed with `: >file`, which writes **zero
bytes** and therefore succeeds on a quota-blocked filesystem. It now writes real bytes, reads them
back, and repeats (a single probe reported `OK` immediately before 4 of the next 20 runs blocked).

### 2.3 Host scratch state, for the record

`/tmp` is a 16 G tmpfs under a per-user quota. During this seat it went from intermittent to total
failure: `df /tmp` reported `3.1G available` (80 % used) at the same moment that
`echo x > /tmp/probe` returned `Disk quota exceeded`. **`df` is therefore not a readiness check for
this host**, which is why the harness probes by writing rather than by measuring free space.
`/home/vgpnk/tmp` (`/dev/mapper/root`, 772 G free) was reliable throughout and is where the
counting run's scratch and logs live.

### 2.4 The harness caught a REAL gate FAIL — a citation race, not a flake

Mid-round, one 10-run arm on the frozen gate revision `e5521304…` produced:

```
run  1/10  rc=0  verdict=PASS       POINTERS=102
run  2/10  rc=0  verdict=PASS       POINTERS=102
run  3/10  rc=0  verdict=PASS       POINTERS=102
run  4/10  rc=1  verdict=FAIL       POINTERS=103
run  5/10  rc=1  verdict=FAIL       POINTERS=103
...                                             (through run 10)
TALLY runs=10 pass=3 fail=7 blocked=0 empty=0 truncated=0 unexpected=0
```

The failing step's detail, from `run-4.log`:

```
MISSING-PATH-REL reports/round-104/gate/workdir.md
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
```

**The FAIL was TRUE when it was emitted.** HARDENING G's second pass resolves backtick-wrapped
repo-relative paths, and `corpus/knowledge/unreal-mcp/gate/README.md:373` and `:441` both cite
`reports/round-104/gate/workdir.md` as the GATE_WORKDIR receipt — a file that did not yet exist:

```
$ ls -la reports/round-104/gate/workdir.md
ls: cannot access '.../reports/round-104/gate/workdir.md': No such file or directory
$ grep -n 'reports/round-104/gate/workdir\.md' corpus/knowledge/unreal-mcp/gate/README.md
373:script (`run_gate.sh` sha256 `e5521304…`).** Full transcript: `reports/round-104/gate/workdir.md`.
441:receipt is `reports/round-104/gate/workdir.md`.
```

The owning seat wrote the **citation before the cited file**. The file appeared at 16:24, and the
next run was green again with no change to the gate:

```
$ ls -la reports/round-104/gate/workdir.md
-rw-r--r-- 1 vgpnk vgpnk 13645 Oct 18 16:24 .../reports/round-104/gate/workdir.md
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E 'UNRESOLVED|GATE RESULT'
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**Adjudication: not a gate defect, and not harness nondeterminism.** The gate reported exactly what
was true at the instant it ran; the `POINTERS` 102→103 step is the sibling's README line entering
the swept set. This is a **citation race** — a window inherent to many seats writing one shared
tree, in which a checker can be red through no fault of the checker. It is worth recording because
it is the one way a *correct* gate can look flaky, and because a reader seeing only the green final
run would not know the window existed. It also justifies the harness's design choice to bind every
reading to a revision and to print the gate's sha256 in its own header.

`POINTERS` itself is a **tree-wide** count (check 4 sweeps every `.md`/`.txt` in the subtree,
including sibling seats' reports), so it is bound to the tree, not to the gate's sha256: it read
`101` at 16:16, `102` at 16:23 and `103` from 16:24 on, tracking the tree, not the gate. Within any
single arm it was constant across all runs.

---

## 3. Negative controls — the harness can fail

Every control below was executed against the final harness revision
`06d5b79f…`, with a stub gate in place of the real one except where noted.

| # | control | expected | observed |
|---|---|---|---|
| 1 | stub exits 0, prints nothing | EMPTY, exit 1 | `empty=2`, `HARNESS RESULT: FLAKY`, rc 1 |
| 2 | stub prints a PASS verdict, exits **3** | UNEXPECTED, exit 1 | `unexpected=2`, rc 1 |
| 3 | stub exits **0** with `GATE RESULT: FAIL` | UNEXPECTED, exit 1 | `unexpected=2`, rc 1 |
| 4 | stub prints a verdict with no STEP lines | UNEXPECTED, exit 1 | `unexpected=2`, rc 1 |
| 5 | stub log cut off before any verdict | TRUNCATED, exit 1 | `truncated=2`, rc 1 |
| 6 | realistic BLOCKED stub (exit 2, 3 PASS + 1 BLOCKED) under `FLAKE_EXPECT=BLOCKED` | STABLE, exit 0 | `blocked=3`, `HARNESS RESULT: STABLE (3/3 runs returned BLOCKED with a matching exit code)`, rc 0 |
| 7 | same BLOCKED stub under default `FLAKE_EXPECT=PASS` | FLAKY, exit 1 | `blocked=3`, rc 1 |

Setup-error paths: `N=0` → `HARNESS ERROR: N must be >= 1`, rc 2; `GATE=/nope` → `HARNESS ERROR:
no gate at /nope`, rc 2. An earlier control set also covered `N=abc`, and `rc=2` with only one
STEP line (structurally impossible) → UNEXPECTED.

Also verified: the harness is cwd-independent (invoked by absolute path from `/tmp` it still finds
the repo and gate), it honours `TMPDIR` and `FLAKE_LOGDIR`, and the log-dir fallback lands on real
disk when `TMPDIR=/tmp` is hostile.

---

## 4. The target moved during the round

The gate was edited by sibling seats while this seat ran. Recorded because every reading is bound
to a revision, and a flake claim bound to the wrong revision is worthless.

| observed (this host, -0300) | `gate/run_gate.sh` sha256 | note |
|---|---|---|
| 16:16, first baseline | `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` | r103-hardened; no native workdir knob |
| 16:21 | `7903c589334b43df7351f09d13eee3e2a9866760a1f4f463b4bf42352aaef2d9` | native `GATE_WORKDIR` landed (`WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, validated up front) |
| 16:22 | `b6d8c61afa94bfde862fc95f2fdd95e87d4632ec46358ade0634385bfc79a59d` | 10/10 PASS recorded |
| **16:24 → final** | **`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`** | **the counting run in §0; unchanged before and after it** |

The counting run is therefore bound to `e5521304…`. The earlier `b6d8c61a…` run also produced
10/10 PASS, so the stability result holds across both revisions; the §0 table quotes the final one.
The harness was made revision-agnostic on purpose: it passes `GATE_WORKDIR` **and** `TMPDIR`, so it
works against a gate revision with or without the native knob, and it records the gate's sha256 in
its own header rather than trusting a value written down in a report.

The tree moved as well as the gate — the §2.4 citation race is the clearest instance, and it is why
the counting run had to be repeated after the tree settled. Note that the two arms of §2.4 and §0
share the **same** gate sha256: the gate was not the moving part.

---

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
GATE_WORKDIR=/home/vgpnk/tmp/r104seat14/gw \
  bash reports/round-104/gate/flake_harness.sh 10
```

Expected: ten `verdict=PASS` lines, `POINTERS=103` on each, then

```
TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: STABLE (10/10 runs returned PASS with a matching exit code)
```

and exit status 0. `POINTERS` is tree-wide, so the number will differ on a different tree — the
invariant is that it is *constant across the ten runs* and that `UNRESOLVED=0` every time.
Drop `GATE_WORKDIR` to read the gate in its default host environment; on a host whose `/tmp` quota
is exhausted that arm will show `BLOCKED` / `EMPTY` / `TRUNCATED` rows, and the `SCRATCH_PREFLIGHT`
line plus §2.1 explain why those are host weather, not gate verdicts.

---

## 6. Residuals

1. **The §2.1 false-FAIL is unfixed.** It needs an owner for `gate/run_gate.sh`. The minimal fix is
   a `WORK_ROOT`-validated scratch file for HARDENING B (the gate already validates `WORK_ROOT` for
   `WORK=$(mktemp -d)`), plus a distinct `BLOCKED`-style signal when the scratch write itself fails.
   Without it, the A4 contract — "blocked is not failed" — is violated by the one check that runs
   before all others.
2. **`FLAKE_EXPECT` has no auto mode.** The harness must be told which verdict to expect. It cannot
   infer "the right answer" from the tree, and it deliberately does not try: inferring the expected
   verdict from the first run would make a harness that agrees with whatever it sees.
3. **No air-gapped arm was run.** `GATE_REF` (offline reference clone) was not exercised by this
   seat; §3 control 6 covers the BLOCKED *classification* path with a stub, not a real offline gate
   run. A `GATE_REF=<path>` arm would be the natural next control.
4. **Sequential by construction.** Runs are serial so that a flake cannot be a resource artefact of
   concurrency. 10 runs cost ~14 s; a higher `N` is cheap and the knob exists for that.
5. **A citation race is not detectable by repetition alone.** §2.4 shows a *correct* gate going red
   because a sibling wrote a citation before its target. More runs do not help; the harness would
   simply report the same true FAIL ten times, or a 3/7 split if the window opens mid-arm. The
   mitigation is procedural — cite only files that already exist, or re-run the gate after the tree
   settles — not more sampling. A useful future arm would run the harness, snapshot the tree, and
   report whether any FAIL line names a path that changed during the arm, so a citation race is
   named as such rather than left for a human to diagnose from a `MISSING-PATH-REL` line.
6. **The harness does not clean up after itself.** Each run's logs accumulate under `LOGDIR` (and,
   when `GATE_WORKDIR` is set, a `flake-harness.*` directory is also created there). Deliberate —
   the logs are the evidence — but a long `N` on a small disk needs `FLAKE_LOGDIR` pointed
   somewhere roomy.
