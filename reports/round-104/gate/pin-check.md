# SEAT-45 · GATE-PIN-CHECK — the `POINTERS` pin vs the live gate

Round r104 · lane `game-dev-3d-shokunin` · written 2026-10-18.
Seat scope: **`reports/round-104/gate/pin-check.md` only** (plus scratch under
`reports/round-104/gate/scratch/`). No file under `corpus/knowledge/unreal-mcp/` was written by
this seat; the subtree is read-only here.

Every claim carries the command that produced it and the output observed on this host. Labels:
**[O]** observed here, **[I]** inference.

## 1. Verdict

**No unresolved drift at close — but only because the C2 seat re-stamped the pin while this seat was
measuring it.** The pin moved `101 → 102 → 103` live during this window, and this seat caught each
step. Final state at `19:27:47Z`:

```
$ GATE_WORKDIR=… bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
rc=0
$ bash reports/round-104/gate/scratch/pincheck-independent.sh      # outside the gate
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=56
INDEPENDENT POINTERS=103 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0
```

**Pin `103` = live `103`, `UNRESOLVED=0`, all four checks `PASS`, `exit=0`** **[O]** — reproduced
independently (`47 + 56 = 103`), stable for two minutes before this was written
(`scratch/pin-timeseries.out`). Full transcript: `scratch/pin-final-green.out`.

**The pin was correct at HEAD and is correct at close; it was briefly *stale in between*, and the
cause is structural.** At HEAD (`88c3b2c`) it pinned `101` and the gate printed `101` — verified at
**six** distinct scanner revisions and across a 20-run sweep with one distinct output line **[O]**.
Then the C2 seat edited the subtree twice, and because `gate/README.md`'s pointer count is
*self-referential* (pass B counts the README itself), **the section documenting the fix moved the
count the same README pins**: `101 → 102` at 16:23:58, `102 → 103` at ~16:24:24 **[O]**. For several
minutes the live gate printed a value the README did not carry — the exact drift this seat was sent
to find.

**Two movers, both isolated to a single backtick path each — neither is the physics work:**

```
$ diff <(backtick paths in README@HEAD) <(backtick paths in README@close)
13a14
> reports/round-103/gate/close-runs.md
16a18
> reports/round-104/gate/workdir.md
```

`pass B 54 → 55 → 56`, `101 → 102 → 103` **[O]**. Both added paths resolve, so `UNRESOLVED` stayed
`0` throughout — the movement was a stale *count*, never a broken pointer.

**The physics work touched nothing here** (§5): at the start of this seat's run the subtree was
git-clean (`git status --porcelain corpus/knowledge/unreal-mcp/` → empty) with r103-era mtimes. Both
movers are the C2 seat's, and the seat's own report (§5) says so.

**A latent residual remains: two `101` sites are now un-updated.** The README's control-matrix rows
`C0` (`:357`) and the quoted r103 evidence block (`:401`) still read `101` while the pin above them
reads `103` **[O]**. Both are *historical records* of runs made at the old count, so leaving them is
defensible — but `C0` is a *live* control row a future runner will re-execute and compare, and it
will not print `101` any more. Flagged for the owner; not fixed here (out of scope).

**The pin's *label* is defective — and was independently fixed during this window.** At HEAD,
`gate/README.md:171` stamped the count with `lane HEAD c85a816` *and* scanner `577c8b54…`, a
combination that never existed (`c85a816` ships `412d1b84…`) **[O]**. The r104 README now reads
`lane HEAD 88c3b2c` with scanner `e5521304…` — both of which I verified are consistent **[O]** — so
that defect is closed by the C2 seat, not by this one.

**One blocking finding, outside the pin:** `/tmp` carries a per-user quota smaller than its free
space, which makes the *unhardened* gate print a spurious `FAIL` on CHECK 1 and mislabel CHECK 2 as
`BLOCKED (network)` when the clone actually dies on `Disk quota exceeded`. `GATE_WORKDIR` removes
both; the interleaved A/B is in §6.

## 2. The live run — pin vs printed

### 2a. At HEAD — the pin matched (scanner `577c8b54…`, 19:16:55Z)

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T19:16:55Z
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
LANE_HEAD=88c3b2ca70fc83ec47a931d7b6dcff85a111c04e
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
exit=0
```

**[O]** Every pinned quantity in `gate/README.md`'s table matched:

| pinned quantity | README pin | live | match |
|---|---|---|---|
| manifest `OK` lines | `12` | `12` | yes |
| clone HEAD | the pin | `a6aa73ad…` | yes |
| tracked upstream files | `12` | `12` | yes |
| cards | `13` | `13` | yes |
| card-name set | 13 stems | `NAME_SET=OK NAME_BAD=0` | yes |
| label census | `12 / 1 / 0` | `12 / 1 / 0` | yes |
| **pointer endpoints / strings** | **`101` / `41`** | **`101` / `41`** | **yes** |
| unresolved | `0` | `0` | yes |

The run is cwd-independent **[O]**: from `/tmp` it printed `POINTERS=101 …` and
`GATE RESULT: PASS` with the same `LANE_HEAD`.

### 2b. Mid-round — the pin went stale twice, live (16:23:58 → 16:24:24)

Minutes after 2a, the README changed under this seat and the count moved, twice **[O]**:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
e55213049db7538d…  run_gate.sh          # was 577c8b54… at HEAD
1ec702906cbaf2b1…  README.md            # was 834f468d… at HEAD, moving
$ GATE_WORKDIR=… bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E '^POINTERS|^GATE RESULT'
POINTERS=102 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**Live gate `102` vs README pin `101` — a one-unit mismatch.** The movers, isolated to the single
path each that entered pass B:

```
$ diff <(backtick paths in README@HEAD) <(backtick paths in README@close)
13a14
> reports/round-103/gate/close-runs.md
16a18
> reports/round-104/gate/workdir.md
```

**[O]** Both added paths exist (`reports/round-103/gate/close-runs.md` 953 B, 16:12;
`reports/round-104/gate/workdir.md`), so each new pointer resolves and `UNRESOLVED` stays `0` — the
mismatch was a stale *count*, not a broken pointer. Transcripts: `scratch/pin-drift-102.out`.

**This is the seat's finding, not a defect it introduced:** this seat wrote nothing under the
subtree (`git status --porcelain corpus/knowledge/unreal-mcp/` shows only `run_gate.sh` and
`README.md`, both modified by the C2 seat) **[O]**. The C2 seat then re-stamped the pin itself, so
this window closed on its own (§2c) — but the drift was live for several minutes and would have
shipped had the round closed in it.

### 2c. At close — re-stamped and converged (README `e3bc66b7…`, 19:27:47Z)

```
$ GATE_WORKDIR=… bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
rc=0
$ grep -n 'POINTERS=1[0-9][0-9]' corpus/knowledge/unreal-mcp/gate/README.md
 42: … the current pin is `POINTERS=103`
248: **Expected (re-measured 2026-10-18T19:24Z at lane HEAD `88c3b2c`, scanner … `e5521304…`):** `POINTERS=103 …`
271: POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
357: | **C0** | … | `POINTERS=101 …`      ← NOT updated (see below)
377: | **W0** | … | `POINTERS=103 …`
401: POINTERS=101 POINTER_STRINGS=41 …     ← NOT updated (r103 evidence quote, historical)
```

**Pin `103` = live `103`, `UNRESOLVED=0`, `exit=0` — converged** **[O]**. The stamp is also
consistent now: `lane HEAD 88c3b2c` with scanner `e5521304…` and `adaptation-kimi.md 084a34cd…` all
verified to co-exist **[O]**. Stable for 2 minutes (`scratch/pin-timeseries.out`); full run in
`scratch/pin-final-green.out`.

**Two `101` sites remain un-updated**, and they are not equivalent:

- **`:401` is a quoted r103 evidence block** — a historical transcript, correctly left as it was.
- **`:357` is the `C0` row of the live control matrix** — a control a future runner re-executes and
  compares. It will no longer print `101`. **[I]** Left as-is this row will look like a failing
  control on the next run, which is the failure mode that matters: a stale *control* is worse than a
  stale *quote*. Flagged for the file's owner; out of this seat's scope.

## 3. The count is not the gate grading itself

`POINTERS` is computed by the gate and compared against a pin the gate's own README carries, so
agreeing with the gate proves nothing by itself. Independent re-implementation
(`scratch/pincheck-independent.sh`), transcribed from the CHECK 4 spec in `gate/README.md` and the
scanner source, with no call into `run_gate.sh` — run twice, before and after the README edit:

```
$ bash reports/round-104/gate/scratch/pincheck-independent.sh     # at HEAD (README 834f468d…)
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=54
INDEPENDENT POINTERS=101 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0

$ bash reports/round-104/gate/scratch/pincheck-independent.sh     # mid-round (README 1ec70290…)
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=55
INDEPENDENT POINTERS=102 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0

$ bash reports/round-104/gate/scratch/pincheck-independent.sh     # at close (README e3bc66b7…)
INDEPENDENT passA_strings=41 passA_endpoints=47 passA_skipped=0 passB_paths=56
INDEPENDENT POINTERS=103 POINTER_STRINGS=41 SKIPPED=0 UNRESOLVED=0
```

**[O]** `47 + 54 = 101`, `47 + 55 = 102`, `47 + 56 = 103` — matching the gate's own decomposition
line (`pass A = 47 endpoints from 41 strings`, pass B counting the README), reproduced from outside
at each state. The independent script reads only the tree, so it tracked the README edits exactly as
the gate did. **Pass A never moved in any state** — `41` strings / `47` endpoints throughout — which
is the structural fact worth keeping: every unit of movement came from pass B, i.e. from prose in
the README itself.

**Determinism.** The CHECK 4 line was **byte-identical in every live run this seat made** until the
16:23:58 README edit — `POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`
**[O]**. A 20-run back-to-back sweep is saved verbatim (`scratch/determinism.out`): `sort | uniq -c`
over its `POINTERS` lines returns exactly one line, count `20`. That sweep ran across a **fourth**
live scanner revision (`b6d8c61a…`), so the count also survived the C2 `run_gate.sh` edit — it is
**only the README edit** that moved it. (The *verdict* moved under host pressure — §6 — but the
pointer count held at `101` throughout.)

## 4. Where 101 comes from — cross-commit matrix

Measured, not inferred. Each row is a real run on a full `git archive` extraction.

| scanner | tree | `POINTERS` | `UNRESOLVED` | verdict |
|---|---|---|---|---|
| `412d1b84…` (r102, at `c85a816`) | `c85a816` | **`88`** | `0` | `FAIL` — the CHECK 1 spurious sweep FAIL of §6 (CHECK 4 itself `STEP=PASS`) |
| `577c8b54…` (HEAD, at `8c9d9ad`) | `c85a816` | **`95`** | `0` | `PASS` |
| `577c8b54…` | `8c3b2c` HEAD | **`101`** | `0` | `PASS` |

Commands and outputs, saved:

```
$ cd <full c85a816 extraction> && bash corpus/.../run_gate.sh
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0        # r102 scanner on r102 tree
$ cp <HEAD scanner> .../gate/run_gate.sh && bash corpus/.../run_gate.sh
POINTERS=95 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   # HEAD scanner on r102 tree
```

**[O]** The decomposition is exactly two effects, both already documented by r103 and both
confirmed here against independently extracted trees:

- **`88 → 95` (+7) is scanner semantics, not tree drift.** A1 made CHECK 4 count *endpoints*, so
  the six range/list pointers expand. Same tree, different scanner. This is why the pin must be
  stated with a scanner sha — and why comparing `88` to `101` across scanners is meaningless.
- **`95 → 101` (+6) is tree prose.** The r103 hardening commit `8c9d9ad` added backtick paths to
  `gate/README.md` and `adaptation-kimi.md`; pass B counts this README, so the prose that *states*
  the pin also *moves* it.

**[O]** `UNRESOLVED=0` in all three rows — the binding invariant never varied, in either direction.

## 5. The mover — and the answer to "did physics touch it?"

**No. The physics work did not touch this subtree.** **[O]**

- `git status --porcelain corpus/knowledge/unreal-mcp/` → **empty** (0 lines) at the start of this
  seat's run. No tracked file modified, nothing untracked added.
- Every file under the subtree has an r103-era mtime (`adaptation-kimi.md` 15:32, `run_gate.sh`
  15:39, `README.md` 15:44) — all before this round opened.
- The only commit touching the subtree since `c85a816` is **`8c9d9ad`** (r103 gate hardening
  A1–A4), `git log c85a816..HEAD -- corpus/knowledge/unreal-mcp/` → that one commit **[O]**.

So the movers at HEAD, exhaustively: **(1)** A1's endpoint semantics (scanner), **(2)** `8c9d9ad`'s
prose (tree). Nothing this round moved the count while the tree was at HEAD.

**And then two peer edits landed, both after this seat's HEAD measurements — and one of them moved
the count.** Observed live:

- **`run_gate.sh`**, the C2 seat landing `GATE_WORKDIR` — changed under me **five** times
  (`577c8b54…` → `7404998e…` → `abebee5c…` → `15fc46d5…` → `b6d8c61a…` → `e5521304…`) **[O]**. It
  adds **no backtick pointer**, so `POINTERS` held at `101` through every one of those revisions,
  including the 20-run sweep **[O]**. Effect on the pin: the `run_gate.sh sha256 577c8b54…` stamp is
  **superseded**; the count is not.
- **`gate/README.md`**, the C2 seat documenting the same fix — edited at **16:23:58** and again at
  ~16:24:24, and **this one moved the count `101 → 102 → 103`** by adding one backtick path each
  time (§2b) **[O]**. Effect on the pin: the value went **stale** for several minutes; the C2 seat
  then re-stamped it to `103` and the pin converged (§2c). The README is the file that carries the
  pin, so it is also the file whose edits invalidate it.

**This is the round's one real cross-seat hazard, and it materialised:** the pin is tied to bytes
that a peer seat rewrote while the round was open, and the self-referential design means
*documenting a change to the pinned file can itself break the pin*. Both edits were correct in
isolation; the collision is the finding. It resolved only because the C2 seat re-stamped — **not
because anything enforced it.**

## 6. BLOCKING finding (outside the pin) — `/tmp` quota makes the gate lie

While measuring, the gate went red on a **clean, unmodified** tree. Traced to the host, not the
tree.

`/tmp` is a 16G tmpfs mounted `usrquota` **[O]** (`grep ' /tmp ' /proc/mounts`), currently 80% used
with 3.1G free — but the *per-user quota* is smaller than that free space. Reproduced directly:

```
$ cd corpus/knowledge/unreal-mcp
$ sha256sum --strict -c .manifest.d/*.sha256 2>&1 >/tmp/.s45c
sha256sum: write error: Disk quota exceeded        # rc=1, 0 bytes written
$ sha256sum --strict -c .manifest.d/*.sha256 >/dev/null 2>&1; echo rc=$?
rc=0                                               # 12 OK lines, nothing wrong with the tree
```

Two consequences, both observed:

- **CHECK 1 prints a red line while passing.** The manifest-sweep header `FAIL per-seat manifest
  sweep (--strict) failed:` appears with an **empty body** — the sweep's stderr went to `$MANLOG`
  and never landed — and the very next line still reports `MANIFEST_OK=12 EXPECTED=12 FAILED=0
  RC=0 … STEP=PASS`. The printed word `FAIL` and the verdict disagree. A reader grepping for `FAIL`
  would call a clean tree broken; a reader trusting `STEP=` would miss a real one.
- **CHECK 2 is mislabeled.** The gate prints `CHECK 2 BLOCKED (network)` / *"upstream unreachable"*,
  but the clone is not a network failure:

```
$ D=$(mktemp -d); git clone --quiet <url> "$D/clone"
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '.../templates/description' to '$D/clone/.git/description': Disk quota exceeded
$ D=reports/.../s45clone; git clone --quiet <url> "$D/clone"; git -C "$D/clone" rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297        # exact pin, 12 tracked files — outside /tmp
```

**[O]** Upstream was reachable the whole time (`git ls-remote` → the pin, rc=0); the clone dies
only because `/tmp` is full. The gate's own comment says the third state exists so a reader can tell
"could not run" from "diverged" — but `(network)` is a *diagnosis*, and here it is the wrong one.
That is worse than a bare BLOCKED: it points the next reader at DNS when the problem is disk.

**Interleaved A/B, same scanner (`15fc46d5…`), same tree, alternating within one command** **[O]**:

| pair | default (`/tmp`) | `GATE_WORKDIR` |
|---|---|---|
| 1–4 | `rc=1`, spurious CHECK 1 FAIL, `FAIL` | `rc=0`, no spurious FAIL, `PASS` |
| all 4 | 4/4 FAIL | 4/4 PASS |

`POINTERS=101` in both arms throughout. **This is a causal link, not a correlation:** the only
variable is where scratch lands, and the C2 seat's `GATE_WORKDIR` block removes both symptoms. The
finding is recorded here because it is *evidence for C2*, not against it — and because the pin must
be read against a run that used it.

**[I]** The r103 root cause ("`/tmp` quota pressure silently breaking `mktemp`/clone") is therefore
**confirmed**, and stronger than stated: it does not need pressure to *fail* the gate, only to make
it *misreport*. Note the earlier r104 `final-run.md` observed a green run in this same window and
correctly declined to call C2 unnecessary — that caution was warranted.

## 7. Cross-seat hazard — a peer verification report's premise was invalidated mid-round

This seat is the round's byte-identity checker, so it must record a second instance of the same
in-flight-edit problem, this one against **another seat's report** rather than the pin.

`reports/round-104/gate/workdir-verify.md` (SEAT-13, written **16:20:48**) states as its central
premise **[O]**:

> Gate under test: `…/run_gate.sh`, sha256 `577c8b54…` (unchanged all round —
> `grep -c GATE_WORKDIR run_gate.sh` = **0**).
> **The declared change is not in the gate; it is in the harness.**

At **16:22:49** — two minutes after that file was written — `run_gate.sh` was edited and the
installed gate now contains **13** `GATE_WORKDIR` occurrences, with a validated `WORK_ROOT` block
and hard named errors for an unset/unwritable root **[O]**:

```
$ grep -c GATE_WORKDIR corpus/knowledge/unreal-mcp/gate/run_gate.sh
13
$ git diff HEAD -- corpus/knowledge/unreal-mcp/gate/run_gate.sh | wc -l
194
$ stat -c '%y %n' reports/round-104/gate/workdir-verify.md corpus/knowledge/unreal-mcp/gate/run_gate.sh
2026-10-18 16:20:48  reports/round-104/gate/workdir-verify.md
2026-10-18 16:22:49  corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

So the C2 change **landed in the gate after all**, contradicting that report's premise. Two
consequences for the round:

1. **The report's §2–§5 no longer describe the installed gate.** SEAT-13's own §9 anticipated this
   exactly — *"If `flake_harness.sh` or `run_gate.sh` changes after this report, §2–§5 must be
   re-run"* — and that condition is now met. The report is not wrong; it is **stale**, and its
   caveat is doing its job.
2. **Both artifacts it verified have moved.** `run_gate.sh` (`577c8b54…` → `e5521304…`, 5+
   revisions) **and** `flake_harness.sh` (`28048131…` → `06d5b79f…`) **[O]**. A verifier pinning two
   shas whose targets both change during the same round needs a re-run, not a patch.

**This seat's own exposure is the same and is handled the same way:** every number above is stamped
with the scanner and README revision it was measured at, and §9 re-measures at close. The
transferable rule — already in `gate/README.md` for the pointer pin — is that a claim tied to bytes
must name the bytes, and a claim tied to a *moving* file must say so. **[I]**

## 8. Residuals — recorded, not fixed

1. **The pin moved `101 → 102 → 103` live this round, and only a re-stamp closed it** (§2b, §9).
   Movers isolated: SEAT-12's README edits added `` `reports/round-103/gate/close-runs.md` `` then
   `` `reports/round-104/gate/workdir.md` ``, one backtick path each into pass B (`54 → 55 → 56`).
   The C2 seat re-stamped to `103` and the pin now matches. **The structural risk is unclosed:** the
   README pins a number its own edits change, so the next README edit re-opens the drift. A gate
   whose pin can be invalidated by the act of documenting it needs either a non-self-referential
   pass B or a "re-measure after editing this file" rule that is enforced, not advisory. **[I]**
2. **Two `101` sites in the README are now un-updated** (§2c): `:357` (the `C0` control row — a
   *live* control a future runner re-executes) and `:401` (a quoted r103 evidence block —
   *historical*, correctly left). The `C0` row is the one that matters; it will no longer match on
   re-run. **Not fixed here: `gate/README.md` is out of this seat's scope.**
3. **The `lane HEAD c85a816` label defect was closed by the C2 seat**, not this one: the r104 README
   now reads `lane HEAD 88c3b2c` with scanner `e5521304…`, and this seat verified that pairing is
   internally consistent **[O]**. Recorded for the record: at HEAD the stamp cited `c85a816` (which
   ships scanner `412d1b84…`) alongside `577c8b54…`, a combination that never co-existed.
4. **CHECK 1's header can print `FAIL` with an empty body** (§6). Even with `GATE_WORKDIR` this is a
   latent reporting bug: the redirect target is unvalidated, so any failure to write it silently
   yields a red header over a passing check. Worth a future-round hardening — validate `$MANLOG`,
   or print the sweep result from a variable rather than a file.
5. **`CHECK 2 BLOCKED (network)` overstates its diagnosis.** The gate cannot distinguish "no route"
   from "no disk". C2's README section documents the fix as `BLOCKED (clone failed)`-style wording;
   the installed `e5521304…` scanner still printed `(network)` in the runs this seat made **[I]**, so
   the wording change and the code change need checking against each other.
6. **`POINTERS` remains an advertised measurement, not a contract** — and self-referential, since
   pass B counts the README that states it. This round is the proof: the pin moved **twice**
   *because* sections documenting a fix were added to the file that pins it. `UNRESOLVED=0` is the
   invariant that binds, and it held at `0` in every state above.

## 9. Close state — the drift this seat was sent to find, and its resolution

The count moved three times while this seat watched. All three states, in order:

| state | scanner | README | live `POINTERS` | README pin | match |
|---|---|---|---|---|---|
| HEAD (2a) | `577c8b54…` | `834f468d…` | `101` | `101` | **yes** |
| mid-round (2b) | `e5521304…` | `1ec70290…` | `102` | `101` | **no — drift** |
| mid-round (2b) | `e5521304…` | `acbbf0e5…` | `103` | `102` | **no — drift** |
| **close (2c)** | **`e5521304…`** | **`e3bc66b7…`** | **`103`** | **`103`** | **yes** |

**[O]** The middle two rows are the finding: for several minutes the live gate printed a value the
README did not carry, caused by the C2 seat's own README edits moving the self-referential count
(§2b). The C2 seat then re-stamped, and the pin converged at `103` — **but nothing in the process
prevented the drift; it was caught only because this seat happened to be measuring.** A future round
that adds prose to `gate/README.md` will re-open it.

**To reproduce the pin exactly**, four things must be stated, because all four moved this round:

```sh
# 1. the tree (this seat's target)
git rev-parse HEAD                                  # 88c3b2ca70fc83ec47a931d7b6dcff85a111c04e
# 2. BOTH subtree shas — re-read them, do NOT trust any sha quoted earlier
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
#    at HEAD:  577c8b548957… / 834f468ded21…    (gate prints 101)
#    at close: e55213049db7… / e3bc66b7f5d9…    (gate prints 103)
# 3. scratch must be off /tmp while the quota is tight
GATE_WORKDIR=$(mktemp -d /var/tmp/gate.XXXX) bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  | grep -E '^POINTERS|^GATE RESULT'
# 4. and re-check the README pin AFTER the run — editing the README changes the number it pins
grep -n 'POINTERS=1[0-9][0-9]' corpus/knowledge/unreal-mcp/gate/README.md
```

**Reading the pin, one line:** `POINTERS` is a *measurement of a scanner on a tree*, so it is only
meaningful with both named; `UNRESOLVED=0` is the invariant that actually binds — and because pass B
counts the README that states the pin, **any edit to that README invalidates the pin it carries.**

## 10. Scope compliance

- **Written by this seat:** `reports/round-104/gate/pin-check.md`, and scratch under
  `reports/round-104/gate/scratch/` (`pincheck-independent.sh`, `pincheck-ind-c85a816.sh`,
  `live-gate.out`, `pin-flake-1..5.out`, `pin-check-live2.out`, `pin-check-final.out`,
  `pin-check-at-close.out`, `pin-drift-102.out`, `pin-timeseries.out`, `pin-final-snapshot.out`,
  `pin-final-green.out`, `determinism.out`, `matrix-r102scanner-r102tree.out`,
  `matrix-headscanner-r102tree.out`, `s45work/`).
- **Not written:** anything under `corpus/knowledge/unreal-mcp/` — verified: the subtree shows only
  `run_gate.sh` and `README.md` as `M`, and both are the C2 seat's edits, not this one's. Also none
  of the round's protected paths (`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`,
  `reports/round-10{1,2,3}/**`, `corpus/fixtures/**`, upstream/manifest paths). No git
  commit/push/checkout/reset was run.
- **Left in place:** `scratch/c85a816/` belongs to SEAT-40 (it is cited in `seats-ledger.md:85`) and
  was not touched. Two of this seat's own extraction dirs (`full-c85a816/`, `s45clone/`, ~22M) were
  removed after their results were copied to `matrix-*.out`, since `/tmp`-adjacent disk pressure is
  this seat's own finding.
- **One caveat on the record:** this report describes a subtree that **changed under it twice during
  the round**. Every measurement above names the scanner and README revision it was taken at, and §9
  tabulates the three count states. If `run_gate.sh` or `README.md` changes again after 19:27:47Z,
  §2c and §9 must be re-run — the pin they confirm is valid only for the bytes they name.
