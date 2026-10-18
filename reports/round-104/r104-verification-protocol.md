# r104 close-out verification protocol

**Seat:** SEAT-32 VERIFIER-CHAIR · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only. No tracked file was modified by this seat.
**Executed by:** the L1 at round close, on the **committed** r104 tree.
**Audience:** a non-author verifier. Every step re-derives its own evidence; nothing here asks you
to trust an author's transcript — including the numbers below.
**Written:** 2026-10-18, against worktree HEAD `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e`
(r103 report-last; r103 work `8c9d9ad`). **The r104 work is uncommitted at write time.**

Round axes: **depth / coverage / calibration**. Coverage is the lowest non-retired axis.

---

## 0. What this protocol gates

| claim | axis | what must hold at close |
|---|---|---|
| **C1** | depth | `corpus/fixtures/phys3d_joints.gd` carries the R3 concurrent-children fix; the row `phys3d_joints_free_ops` **PASSES at the unchanged `CASE_TIMEOUT_SECONDS = 20`**; its marker is **byte-identical** to the r103 pin; `corpus/fixtures/run_battery.py` is **byte-untouched** (no r104 design doc names it) |
| **C2** | coverage | `gate/run_gate.sh` resolves its scratch root as **`GATE_WORKDIR > TMPDIR > /tmp`**, validates it up front, and prints it; a durable **flake harness** exists and reports STABLE 10/10 on a real-disk scratch; the r102/r103 **attack suite still detects every planted mutation** |
| **C3** | calibration | a lane-level **`SKILL.md`** exists carrying the *Unreal-content claim discipline* decision table (rows A–E), every row's canonical command **re-runs green**, and no row carries a gate **line number** |

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
# SCRATCH ON REAL DISK — this is not cosmetic this round. See §0.3.
WORK=$HOME/.cache/r104-closeout
rm -rf "$WORK" && mkdir -p "$WORK"
export GATE_WORKDIR=$WORK/gate-scratch
mkdir -p "$GATE_WORKDIR"
```

Required on PATH: `bash git sha256sum grep find sort comm curl python3 node npm jq shellcheck`.
Network is required by gate CHECK 2 and by step 8. **Put `$WORK` outside `/tmp`, and export
`GATE_WORKDIR`:** this host's `/tmp` is a 16 GB tmpfs that measured **80 % full (3.1 GB free)** at
protocol-write time and returned `Disk quota exceeded` on `git clone` and on `mktemp` — §0.3.

### 0.2 The tree at protocol-write time — measured, not remembered

```sh
git status --porcelain
```

Observed 2026-10-18T19:22Z:

```
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? SKILL.md
?? reports/round-104/
?? .r104-seat17/
```

Two consequences that govern the whole protocol.

1. **Both artifacts under test are modified but not yet committed.** A verifier who runs the gate on
   a pristine `git archive HEAD` export gets the **r103 bytes**, where the scratch-root fix is
   absent. The expected outputs below are for the tree **after** the L1 lands the r104 commit.
2. **`SKILL.md` is new and untracked.** It did not exist at HEAD — there is no prior byte-identity
   to preserve, and step 7 checks the *content* conditions, not a diff against nothing.

**The gate file was rewritten at least four times inside this round** while this seat measured it:

| identity | lines | scratch-root handling |
|---|---:|---|
| `577c8b54…` | 347 | `mktemp` in `TMPDIR` — the r103 bytes |
| `15fc46d5…` | 418 | `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, validated |
| `b6d8c61a…` | 433 | same, `WORK_ROOT_FREE` printed |
| **`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`** | **—** | last measured by this seat |

**Every expected output below is stated as a property, not as a literal file hash.** Re-hash the
gate before acting on any number here, and where a number has moved, the re-run wins. The same
warning applies to `reports/round-104/gate/flake_harness.sh`, whose sha moved
`a51cdf86… → c8869b67… → 5816b0f5… → 59835042… → 38c6394e… → 06d5b79f… → 1aeec700…` inside this
seat's window — in one intermediate revision it **failed `bash -n`** with a syntax error while still
printing a plausible tally. Step 2.4 exists because of that.

`SKILL.md` also moved inside the window (`1055a52f…` at 174 lines → `de8ada36…` at 182 lines), and
`gate/README.md` was rewritten repeatedly (`834f468d…` → `e3bc66b7…` at the last check, +110/−5 and
still climbing). **All three artifacts under test changed identity while this protocol was being
written.** That is not a defect of any one of them; it is the condition the protocol is designed for.
The gate (`e5521304…`) and the fixture (`c7e77638…`) held still across this seat's final measurement
pass; SKILL.md, README.md and the harness did not. Re-run everything on the frozen commit and report
that commit's SHA.

### 0.3 Why `$WORK` must not be `/tmp` — measured this round

`/tmp` is a tmpfs, 16 GB, **80 % full (3.1 GB free), 64 % of inodes used** at write time. Three
failure modes were observed by this seat, live:

```
$ git clone --quiet https://github.com/EpicGames/…-plugin $W/clone
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/hooks/pre-rebase.sample' to
      '/tmp/tmp.sgoygTpZnq/clone/.git/hooks/pre-rebase.sample': Disk quota exceeded
```

```
$ cp -r corpus/knowledge/unreal-mcp /tmp/x/sub
cp: error writing '/tmp/x/sub/upstream/README.md': Disk quota exceeded      (×44 files)
```

and, on the **unfixed** gate, a bare `mktemp` whose redirect fails:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh     # r103 bytes, TMPDIR=/tmp
FAIL per-seat manifest sweep (--strict) failed:      <-- spurious, on a CLEAN tree
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
GATE RESULT: FAIL (checks failed: 1)
```

Six consecutive default-`TMPDIR` runs on the r103 bytes reproduced that spurious fail-closed 6/6.
**A `Disk quota exceeded` line anywhere in a step's output invalidates that step.** Use
`$HOME/.cache/...` or `/dev/shm` for every scratch tree in this protocol.

---

## 1. Tree and protected-path preconditions  *(mechanical)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD
git status --porcelain
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md \
    corpus/fixtures/run_battery.py reports/round-101 reports/round-102 reports/round-103
git diff --name-only HEAD -- "$SUB/upstream" "$SUB/.manifest.d"
```

**Expected:** `HEAD` = the r104 close commit; `git status --porcelain` **empty** (everything landed);
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

**Scope question the L1 must rule, not absorb.** The licensed r104 edit set for `corpus/fixtures/**`
was `phys3d_joints.gd` alone (SEAT-04's declared scope; `run_battery.py` only *if* the r104 design
doc named it, and `reports/round-104/physics/sentinel.md` §1 rules it was **not** named). Step 6.1
proves the second half. If any *third* fixture path appears in that diff, it is an unruled scope
breach — the r103 precedent (§9.6 of `reports/round-103/r103-verification-protocol.md`) shows how
one was absorbed silently last round.

---

## 2. Gate: scratch-root resilience, self-containment, and the clean run  *(C2, non-author)*

### 2.1 The scratch-root contract

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
GATE=$SUB/gate/run_gate.sh
test -x "$GATE" && echo GATE_EXECUTABLE || echo GATE_NOT_EXEC
bash -n "$GATE" && echo "bash -n OK"
grep -nE 'GATE_WORKDIR|WORK_ROOT|TMPDIR' "$GATE" | head -20
```

**Expected:** `GATE_EXECUTABLE`; `bash -n OK`; and a block showing the precedence chain
`${GATE_WORKDIR:-${TMPDIR:-/tmp}}` plus an up-front **validation** of that root. The r103 bytes
(`577c8b54…`) had neither — they called bare `mktemp`, so the root was implicitly `/tmp` and a
failure surfaced only as an empty redirect.

### 2.2 The three scratch-root states — each must behave distinctly

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
GATE=$SUB/gate/run_gate.sh
GW=$WORK/gw; rm -rf "$GW"; mkdir -p "$GW"

# (a) explicit GATE_WORKDIR on real disk — must PASS and NAME the root it used
GATE_WORKDIR=$GW bash "$GATE" > "$WORK/a.txt" 2>&1; echo "gw_rc=$?"
grep -E '^WORK_ROOT|^MANIFEST_OK|^CLONE_HEAD|^GATE RESULT' "$WORK/a.txt"

# (b) GATE_WORKDIR points at a path that does not exist — must fail LOUDLY and EARLY
GATE_WORKDIR=/nonexistent-xyz bash "$GATE" > "$WORK/b.txt" 2>&1; echo "badgw_rc=$?"
head -4 "$WORK/b.txt"

# (c) unwritable TMPDIR, GATE_WORKDIR unset — same loud path, not a silent one
TMPDIR=/nonexistent-xyz bash "$GATE" > "$WORK/c.txt" 2>&1; echo "badtmp_rc=$?"
head -4 "$WORK/c.txt"
```

**Expected:**

```
gw_rc=0
WORK_ROOT=<the GW you passed> (from GATE_WORKDIR)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
GATE RESULT: PASS (checks failed: 0)

badgw_rc=1
FAIL scratch root is not a directory: /nonexistent-xyz
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory

badtmp_rc=1
FAIL scratch root is not a directory: /nonexistent-xyz
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory
```

**Observed 2026-10-18 by this seat:** exactly that, on gate sha `e5521304…`. On the r103 bytes the
same (c) probe printed `mktemp: failed to create file via template …` followed by the **spurious**
`FAIL per-seat manifest sweep` — a false FAIL on a clean tree, which is the defect C2 removes. A
verifier who still sees the `mktemp:` line and the spurious per-seat FAIL is running the **r103**
gate: re-hash, do not report it as an r104 result.

**Do not read (b)/(c) as "the gate is broken".** Exiting 1 with a named, actionable message is the
**fix**. The pre-fix behaviour was exit 1 with a *misleading* message that blamed the manifest.

### 2.3 The clean run, default environment

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
shellcheck "$GATE"; echo "shellcheck_exit=$?"
bash "$GATE" > "$WORK/clean.txt" 2>&1; echo "GATE_EXIT=$?"
grep -E '^MANIFEST_FILES|^MANIFEST_OK|^CLONE_HEAD|^CLONE_DIRTY|^CLONE_TRACKED|^PATH_|^BLOB_DIFFS|^CARDS=|^NAME_SET|^CENSUS|^POINTERS|^GATE RESULT' "$WORK/clean.txt"
```

**Expected** (with `GATE_WORKDIR` exported per §0.1):

```
GATE_EXIT=0
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
literal backtick), declared by a `# shellcheck disable=SC2016` directive at the top of the file. The
same info is present on the r102 and r103 bytes. Record it; do not "fix" it.

**`POINTERS` is NOT a stable number — never assert it.** It measured `88 → 90 → 91 → 95 → 98 → 100
→ 101` across r103 on **prose edits alone**, because pass B sweeps backtick-wrapped repo-relative
paths across the whole subtree *including `gate/README.md` itself* and *including `reports/`*.

**It moved again inside r104 while this protocol was being written: `101 → 103`** — this seat
measured `101`, then `103` minutes later, with no gate-logic change in between, only prose landed in
the subtree and in `reports/round-104/**`. `gate/README.md` now pins **`103`** in four places and
still carries **two stale `101` lines** (plus one `87` from r102). That is the drift class r103 §9.4
recorded, reproducing itself exactly as predicted. **A verifier must expect `103`-vs-`101` drift in
the README and must NOT report it as a gate failure** — the README is a document, the pin is a
measurement, and the invariant is `UNRESOLVED=0`. Re-run and use whatever the live run prints; where
it differs from `103`, the re-run wins.

**Network caveat.** CHECK 2 clones the upstream repo. If the clone cannot complete — **and on this
host a `/tmp` clone frequently cannot, §0.3** — the gate prints `CHECK 2 BLOCKED (network)` /
`STEP=BLOCKED` and exits **2** (see §2.5). Record BLOCKED as BLOCKED; never as PASS, and never
substitute a cached clone without saying so.

### 2.4 The flake harness — 10/10, and it must be run on a real-disk scratch

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
H=reports/round-104/gate/flake_harness.sh
test -f "$H" && echo HARNESS_PRESENT
bash -n "$H" && echo "harness bash -n OK"
GATE_WORKDIR=$WORK/flake bash "$H" 10 > "$WORK/flake.txt" 2>&1; echo "harness_rc=$?"
tail -16 "$WORK/flake.txt"
```

**Expected:**

```
HARNESS_PRESENT
harness bash -n OK
harness_rc=0
GATE_WORKDIR=<the dir you passed> (passed as GATE_WORKDIR and TMPDIR to each run)
SCRATCH_PREFLIGHT=OK (0/20 probe writes failed in <dir>)
RUNS=10 EXPECT=PASS
run  1/10  rc=0  verdict=PASS       POINTERS=<n>   …s  run-1.log
… (10 lines, all rc=0 / PASS)
TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 unexpected=0
HARNESS RESULT: STABLE (10/10 runs returned PASS with a matching exit code)
```

**Field note on the tally line.** An earlier harness revision printed
`TALLY runs=… truncated=0 unexpected=…`; the current one printed
`TALLY runs=10 pass=10 fail=0 blocked=0 empty=0 truncated=0 unexpected=0` and the last measurement
`runs=10 pass=10 fail=0 blocked=0 empty=0 unexpected=0`. **Do not assert the field list** — assert
`pass=<N>` with `fail=blocked=empty=unexpected=0` and `HARNESS RESULT: STABLE (N/N …)`. The harness
gained a `truncated` counter between revisions; a verifier matching the tally string literally will
report a false FAIL on a harness that is working.

**Observed by this seat:** `STABLE (10/10)` — twice, on `GATE_WORKDIR` and on `TMPDIR`. **The same
harness with the default `/tmp`** prints
`SCRATCH_PREFLIGHT=UNWRITABLE (20/20 probe writes failed in /tmp)`, then `blocked=3/3` and
`HARNESS RESULT: FLAKY`. That is the harness doing its job, not a gate defect: it **names the scratch
root and proves it writable before the run**, which is exactly the diagnostic the r103 flake lacked.
The preflight is load-bearing — without it, a scratch-exhaustion `BLOCKED` is indistinguishable from
a genuine network block.

**`bash -n "$H"` is not optional.** This file changed identity six times inside r104 and in one
intermediate revision **failed `bash -n`** with `syntax error near unexpected token` — it still
printed a plausible `TALLY` line for the runs it got through, because bash parses lazily. A harness
that cannot parse is not a harness; step 2.4's second line is the guard.

**`FLAKE_EXPECT=FAIL|BLOCKED`** are supported for the plant runs of §3; `FLAKE_N`/`$1` sets the run
count. Exit codes: `0` stable, `1` flaked, `2` usage/setup error — the third state matters, because
"the harness could not run" must not read as "the gate is stable".

### 2.5 A4 — an unreachable clone is a distinct BLOCKED state with exit 2

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
A=$WORK/attacks; rm -rf "$A"; mkdir -p "$A"
fresh() { rm -rf "$A/c"; mkdir -p "$A/c"; git archive HEAD | tar -x -C "$A/c" || exit 1
          cp "$GATE" "$A/c/$GATE"; }

fresh
( cd "$A/c" && GATE_WORKDIR=$A https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 \
   ALL_PROXY=http://127.0.0.1:1 bash "$GATE" > "$A/blocked.txt" 2>&1 ); echo "blocked_exit=$?"
grep -E 'BLOCKED|^STEP=|^GATE RESULT' "$A/blocked.txt"

# GATE_REF: an existing clone at the pin, offline — must be scored normally
( cd "$A/c" && GATE_WORKDIR=$A GATE_REF=/tmp/ue-skills-r104-ref \
   https_proxy=http://127.0.0.1:1 http_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 \
   bash "$GATE" > "$A/ref.txt" 2>&1 ); echo "ref_exit=$?"
grep -E 'GATE_REF=|^CLONE_HEAD|^PATH_|^BLOB_DIFFS|^STEP=|^GATE RESULT' "$A/ref.txt"

# BLOCKED **and** another check failing: the third state must not swallow the failure
fresh; printf '\nsee upstream/README.md:200\n' >> "$A/c/$SUB/README.md"
( cd "$A/c" && GATE_WORKDIR=$A https_proxy=http://127.0.0.1:1 ALL_PROXY=http://127.0.0.1:1 \
   bash "$GATE" > "$A/mixed.txt" 2>&1 ); echo "mixed_exit=$?"
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
GATE_REF=/tmp/ue-skills-r104-ref (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)

mixed_exit=1
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)
```

**Observed 2026-10-18 by this seat:** all three exactly as above. `GATE_REF` must be a real clone at
the pin; a path that is not a git clone is a genuine FAIL, not BLOCKED
(`FAIL GATE_REF is not a git clone`). A clone at the pin existed at `/tmp/ue-skills-r104-ref` and
returned `a6aa73ad…` at write time.

**The mixed case is a known residual, not a pass.** The `exit 2` branch is guarded by
`[ "$FAILS" -eq 0 ]`, so BLOCKED **plus** any other failure reports `GATE RESULT: FAIL` / exit 1 —
the reader again cannot tell "check 2 could not run" from "the bytes diverge". `gate/README.md`
records this (search for "One residual"). A verifier should **not** treat exit 1 in the mixed case as
a clean FAIL; read the `STEP=BLOCKED` line.

---

## 3. Gate hardening A1–A4 — each must be falsified by a plant  *(C2, non-author)*

A gate that cannot fail proves nothing, and a hardening that is only *described* proves less. Each
sub-step plants one mutation on a **throwaway copy of the whole repo** and asserts the gate goes red
for the right reason.

**Harness rule, learned the hard way.** Copy the **whole repo**, not just the subtree. The gate's
pass-B sweep resolves `corpus/…` and `reports/…` pointers against the repo root, so a subtree-only
copy makes the gate FAIL spuriously with `MISSING-PATH-REL`. Every plant below uses this pair, and
**every one must run with `GATE_WORKDIR` set** (§0.3), or a quota failure can be mistaken for a
detection:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
A=$WORK/attacks; rm -rf "$A"; mkdir -p "$A"
fresh() { rm -rf "$A/c"; mkdir -p "$A/c"; git archive HEAD | tar -x -C "$A/c" || exit 1
          cp "$GATE" "$A/c/$GATE"; }
run()  { ( cd "$A/c" && GATE_WORKDIR=$A bash "$GATE" ) > "$A/out.txt" 2>&1; local rc=$?
         printf '%-24s rc=%s | %s\n' "$1" "$rc" \
           "$(grep -E '^FAIL|^GATE RESULT' "$A/out.txt" | head -2 | tr '\n' ' ')"; }
fresh; run "M0-control"        # must be rc=0 — rules out "this copy fails for other reasons"
```

`fresh` must never emit a `Disk quota exceeded` line (§0.3).

### 3.1 A1 — every endpoint of a `:a-b` / `:a,b` range is validated

```sh
fresh; printf '\nsee upstream/README.md:1-9999\n' >> "$A/c/$SUB/executability/materials.md"
run "A1-plant-range-tail"
grep -E 'LINE-OOR|^POINTERS' "$A/out.txt"
```

**Expected:** control `rc=0` / `GATE RESULT: PASS`; plant `rc=1` with
`LINE-OOR … :: upstream/README.md:1-9999 (max 112)` and `UNRESOLVED=1`. **Observed:** exactly that.
On the r102 bytes the same plant left the gate **green**, which is the defect A1 removed.

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
NC3 `FAIL no-label` `BAD=1`. **A verifier who expects the prose-hijack plant to be RED has the
polarity inverted** — on the r102 bytes it false-FAILed a correctly labelled card.

### 3.3 A3 — the card-name set is compared, not just counted

```sh
fresh; mv "$A/c/$SUB/executability/sequencer.md" "$A/c/$SUB/executability/sequence-typo.md"; run "A3-rename-card"
grep -E '^CARDS=|^NAME_SET|card-name' "$A/out.txt"
```

**Expected:** `rc=1` with **both** directions named —
`FAIL card-name-missing sequencer.md`, `FAIL card-name-extra sequence-typo.md`,
`NAME_SET=BAD NAME_BAD=2`, and still `CARDS=13 EXPECTED=13 BAD=0` (the count is unchanged; only the
name set catches it). **Observed:** exactly that. On the r102 bytes the rename was caught only
*incidentally* by CHECK 4's pointer sweep, and went **fully green** once the referring documents were
made consistent.

### 3.4 A4 — see §2.5

The BLOCKED / exit-2 contract, the `GATE_REF` offline path and the mixed-state residual are all
measured in §2.5. Do not duplicate the plant; do not skip it.

### 3.5 The wider attack battery — all of these must be DETECTED

The hardening must not have *removed* detection. Re-run the classic set on whole-repo copies
(`fresh`/`run` as above); **every row must print `rc=1` unless the table says GREEN**:

| id | mutation | expected failing signal | observed |
|---|---|---|---|
| M1 | append one byte to `$SUB/upstream/README.md` | `FAIL per-seat manifest sweep`, `MANIFEST_OK=11 … FAILED=1`, `BLOB-DIFF README.md` | `rc=1`, 3 checks |
| M2 | delete `$SUB/executability/materials.md` | `FAIL card-name-missing materials.md` | `rc=1`, 2 checks |
| M3 | corrupt line 1 of `.manifest.d/audit-reference.sha256` | `FAIL per-seat manifest sweep` | `rc=1`, 2 checks |
| M4 | delete `$SUB/upstream/LICENSE` | `FAIL upstream file not vendored` | `rc=1` |
| M5 | append `see upstream/README.md:200` to `$SUB/README.md` | `LINE-OOR … (max 112)` | `rc=1` |
| M6 | duplicate a label token on `blueprints.md:4` | `FAIL multi-label` | `rc=1` |
| M7 | relabel `blueprints.md:4` `unproven-runtime` | census `11 / 2 / 0` ≠ `12 / 1 / 0` | `rc=1` |
| M8 | rename `sequencer.md` → `sequence-typo.md` | `FAIL card-name-missing` + `card-name-extra` | `rc=1` |
| M9 | append `see upstream/README.md:1-9999` | `LINE-OOR … :1-9999` | `rc=1` |
| **M10** | insert prose naming a token above `editor-general.md`'s declaration | **must stay `rc=0`** | **`rc=0` PASS** |
| H2 | symlink `/tmp/payload.md` → `$SUB/upstream/evil.md` | `FAIL non-regular file in pinned tree` | `rc=1` |
| H4 | `mkdir $SUB/executability/sub` with a 14th card inside | `FAIL nested entry under executability/` | `rc=1` |
| H14 | CRLF the audit manifest | `FAIL CR byte in manifest` | `rc=1` |
| H21 | append `see upstream/README.md:0` | `LINE-ZERO` | `rc=1` |
| H22 | empty a `.manifest.d/seat*.sha256` | `FAIL per-seat manifest sweep` | `rc=1` |
| H5 | append a backticked `reports/round-999/ghost.md` | `MISSING-PATH-REL` | `rc=1` |
| **C7** | plant **only** the exact sentinels (`upstream/README.md:500`) | **must stay `rc=0`**, `SKIPPED_CONTROL_SENTINELS=1` | **`rc=0` PASS** |

**Observed 2026-10-18 by this seat, whole-repo copies, `GATE_WORKDIR` on real disk:** every row
above in its stated direction — 15 red, **M10 and C7 green**. No mutation produced a false PASS.

**M10 is the polarity trap.** Every other mutation must go red; the prose-hijack plant must stay
green. A verifier who lists M10 among the "must be detected" rows will report a false FAIL.

**One open false-PASS class, measured — do NOT list it as a pass.** `H6` — appending
`see upstream/LICENSE:99999` — leaves the gate **GREEN** (`rc=0`, `UNRESOLVED=0`), because CHECK 4's
pointer regex requires a dotted path segment, so extensionless targets such as `upstream/LICENSE`,
`upstream/CODEOWNERS` and `upstream/.gitignore` are never swept. Fold-spec item **A6** was queued in
r102, not implemented in r103, and **still not implemented in r104** — re-confirmed this round.
Record it as a known residual; do not fold it silently and do not cite "A1–A4 landed" as "all
pointer gaps closed".

---

## 4. C1 — the physics wall-cost fix  *(depth, non-author)*

The r103 ruling: `phys3d_joints_free_ops` = `INTRINSIC_WALL_COST` — 21 serial child Godots × ~0.9 s
boot floor ≈ 19 s inside a 20 s cap, ~84 % of wall spent starved. The ruled preference was **R3,
concurrent children**. Confirm the fix exists, is the ruled shape, and works **at the unchanged cap**.

### 4.1 The fix is present and is the ruled shape

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum corpus/fixtures/phys3d_joints.gd
git diff --stat HEAD -- corpus/fixtures/phys3d_joints.gd
grep -n 'create_process\|is_process_running\|get_process_exit_code\|_spawn_child\|_collect_child' \
    corpus/fixtures/phys3d_joints.gd
grep -n 'CASE_TIMEOUT_SECONDS' corpus/fixtures/run_battery.py
```

**Expected:** a **non-empty** diff on `phys3d_joints.gd` and nothing else; `OS.create_process` /
`OS.is_process_running` / `OS.get_process_exit_code` present; a `_spawn_child` that returns a job
descriptor and a `_collect_child` that waits **and emits in the original nested-loop order**; and
`CASE_TIMEOUT_SECONDS = 20` **unchanged** at `run_battery.py:36`. **A raised cap is NOT this fix** —
R1 (global cap 20→60) was the operator fallback and was explicitly not preferred. If the constant
moved, the claim is not the one this protocol gates.

**Observed:** `phys3d_joints.gd` `88be87fa…` → **`c7e77638…`**, `+26/−7`; the `_spawn_child` /
`_collect_child` pair is present; `CASE_TIMEOUT_SECONDS = 20` unmoved.

### 4.2 The row PASSES at the unchanged cap, with the marker byte-identical

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
W=$WORK; mkdir -p "$W/runs-after"
S=$(date +%s%N)
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs "$W/runs-after" \
  > "$W/fo.out" 2>&1; echo "runner_rc=$?"
E=$(date +%s%N); echo "wall_ms=$(( (E-S)/1000000 ))"
head -2 "$W/fo.out"; grep -E '^totals' "$W/fo.out"
python3 - <<'PY'
import json, glob, hashlib
d = sorted(glob.glob(f"{__import__('os').environ['HOME']}/.cache/r104-closeout/runs-after/*/verdicts.json"))[-1]
j = json.load(open(d))
r = [x for x in j['results'] if x['case'] == 'phys3d_joints_free_ops'][0]
print('receipt', d)
print('verdict', r['verdict'], 'exit', r['actual_exit'], 'expected', r['expected_exit'])
print('elapsed', r['elapsed_seconds'], 'reasons', r['reasons'])
print('seeds_unchanged', j['seeds_unchanged'])
print('marker_bytes', len(r['marker']), 'marker_sha', hashlib.sha256(r['marker'].encode()).hexdigest())
PY
```

**Expected — this is the C1 pass condition:**

```
runner_rc=0
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
verdict PASS  exit 0  expected 0
elapsed < 5.0        reasons []
seeds_unchanged True
marker_bytes 3921    marker_sha 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
```

**Observed 2026-10-18 by this seat:** `runner_rc=0`, `wall_ms=2300`, `elapsed 2.062`,
`reasons []`, `seeds_unchanged True`, **marker 3921 bytes / sha `706ad915…`**. Re-run on a fresh
receipt minutes later: `fo_rc=0`, `elapsed 1.94`, same marker sha — so the row is stably green, not
green once. That sha is the
**byte-identity pin** from SEAT-03's `reports/round-104/physics/markers.md` §1 row 5, which in turn
was derived from the `CASES` table itself by `ast.literal_eval`. **A different marker sha is a
regression regardless of the verdict** — the fix must move the clock and not one byte of the stream.

**Before, for contrast (the r103/r104-pre-fix baseline, unchanged 20 s cap):**

```
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', …]
totals: cases=1 pass=0 fail=1
```

reproduced by this seat at **20.178 s wall** on the pre-fix bytes.

### 4.3 Two traps in this step

1. **`run_battery.py`'s exit code is `1` on any failing run — do not read it as the verdict.** The
   runner returns `0 if verdict == "PASS" else 1`, and its `verdict` is `PASS` only when **every**
   row passed. On this host a *full* run always exits `1` (the known reds below), so a non-zero exit
   there is **expected**, not a regression. Conversely, never capture the code through a pipeline
   (`… | tail -5; echo $?` reports `tail`'s status). In 4.2 the row is the **only** row, so
   `runner_rc=0` **is** the pass.
2. **`seeds_unchanged` can go false from an untracked-file event, not from a fixture edit.**
   `seed_digests()` walks `corpus/fixtures/` **recursively**, and the arm builds `res://r90bt_*`
   directories (`phys3d_joints.gd` `_spawn_child`). Normally those land in the run's scratch copy;
   a leak or a concurrent run flips the guard. **When `seeds_unchanged` is false, first check for
   untracked directories under `corpus/fixtures/` (step 6.2) before concluding a fixture was
   edited.** R3 makes this more important than in r103: 21 children are now alive at once.

---

## 5. C2 supporting — the gate's own bytes and the subtree pin  *(coverage)*

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- "$SUB"
(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256; echo "audit_rc=$?")
(cd "$SUB" && sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK$')
for f in .manifest.d/*.sha256; do (cd "$SUB" && sha256sum -c "$f" >/dev/null 2>&1 || echo "SHARD FAIL $f"); done
git diff --stat HEAD -- "$SUB/upstream" "$SUB/.manifest.d"; echo "pinned_dirs_rc=$?"
```

**Expected:** the subtree diff shows **only** `gate/run_gate.sh` (and `gate/README.md` if it was
touched) — **never** `upstream/` or `.manifest.d/`; 12 `OK` lines and `audit_rc=0`; the glob prints
**24** (12 paths twice: `audit-reference` + the 11 shard manifests); no `SHARD FAIL` line; the last
diff is empty with `pinned_dirs_rc=0`.

**Observed 2026-10-18:** 12/12 `OK` rc=0; glob **24**; all shards rc=0; `upstream/` and
`.manifest.d/` zero diff. (The glob count is **24**, not 12 — the `audit-reference.sha256` subset is
12. This is the **count-written-into-prose** trap that `SKILL.md` §2 names.)

**The r103 TMPDIR residual is now closed.** In r103, `TMPDIR=/nonexistent-xyz bash "$GATE"` produced
a **spurious** `FAIL per-seat manifest sweep` + exit 1 on a clean tree, because `mktemp` failed
before `sha256sum` ran. Re-run that probe as **step 2.2(c)**: on the r104 bytes it must print the
**loud** `FAIL scratch root is not a directory` and exit 1 **before** any check runs. A verifier who
sees the old `mktemp:` + spurious per-seat FAIL is on r103 bytes.

---

## 6. Battery bytes — the untouched-file invariant  *(C1/C2 supporting)*

Three independent proofs. **Step 6.2 is not optional** — the tracked-blob proof in 6.1 is blind to
untracked leaks, and §4.3 trap 2 is exactly that case.

### 6.1 `run_battery.py` identical to HEAD; `phys3d_joints.gd` is the only fixture edit

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git diff --stat HEAD -- corpus/fixtures/; echo "fixtures_diff_rc=$?"
sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
git hash-object corpus/fixtures/run_battery.py
git rev-parse HEAD:corpus/fixtures/run_battery.py
git ls-files corpus/fixtures | wc -l
```

**Expected:**

- the diff contains **exactly one path**, `corpus/fixtures/phys3d_joints.gd` (`+26/−7`, the R3
  rewrite). **Any second path is a FAIL** — `run_battery.py` was licensed only if the r104 design doc
  named it, and `reports/round-104/physics/sentinel.md` §1 rules it did **not**.
- `run_battery.py` sha256
  **`f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`**, with
  `git hash-object` == `git rev-parse HEAD:corpus/fixtures/run_battery.py`
  (blob `dd2d9b74448afddb88dcf2da56008302eba8060d`).
- `phys3d_joints.gd` sha256 **`c7e77638…`** (the landed R3 bytes; `88be87fa…` is the pre-fix HEAD
  blob `3ce066a6…` — do not accept that value as the post-fix state).
- **146** tracked fixture files.

**Observed 2026-10-18:** one diff path (`phys3d_joints.gd`, +26/−7); `run_battery.py` triple as
above; 146 files.

### 6.2 No untracked or leaked entry under `corpus/fixtures/`

```sh
git status --porcelain -uall -- corpus/fixtures/
ls corpus/fixtures | grep -c '^r90bt_' || true
git check-ignore -v corpus/fixtures/three/node_modules 2>/dev/null || echo "not-ignored"
```

**Expected:** **exactly one** porcelain line — ` M corpus/fixtures/phys3d_joints.gd` — and **zero**
`r90bt_*` entries. Any other line is a FAIL: a leaked `r90bt_*` directory means a Godot run used
`corpus/fixtures` as its project path, and a leak that survives to the commit lands untracked
fixture pollution in a HARD-RULES-protected tree. **R3 raises this risk** — 21 concurrent children
per arm now, each doing `DirAccess.make_dir_recursive_absolute`.

**Note:** `corpus/fixtures/three/node_modules/` **is** gitignored by a per-directory ignore file, so
it does not appear in `git status -uall` and does not affect the count.

### 6.3 The case table is intact (350 rows) and no expectation moved

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
print("phys3d_joints rows:", sum(1 for c in cases if c[1] == 'phys3d_joints.gd'))
PY
```

**Expected:** sha256 `f456bd00…`, **350** rows, `worktree==HEAD: True`, **8** rows with
`script == 'phys3d_joints.gd'`. **Observed:** exactly that. `ast.literal_eval` is used rather than
`import` (which would execute the runner) and rather than `grep` (which cannot see table structure);
it **errors out** on a non-literal element instead of coercing silently.

### 6.4 The full 350-row run — the pass condition is a **named set**, not "zero FAIL"

**This step needs a long window** (many minutes on this host; run it in the background and do not
accept a truncated capture).

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
python3 corpus/fixtures/run_battery.py > "$WORK/battery.out" 2>&1; echo "battery_rc=$?"
grep -E '^totals:' "$WORK/battery.out"
python3 - <<'PY'
import json, glob
# DO NOT pick the newest receipt directory, and DO NOT assume every verdicts.json is a
# battery receipt. Steps 4.2/6.3 also write 1-case and 13-case battery receipts into the
# same tree, and corpus/live/runs/ ALSO holds non-battery receipts from other fixtures
# (e.g. r12-import-*/verdicts.json, whose schema has no 'totals' key at all — reading it
# raises KeyError). Select on the battery shape AND the row count.
best = None
for p in glob.glob('corpus/live/runs/*/verdicts.json'):
    try:
        j = json.load(open(p))
    except Exception:
        continue
    t = j.get('totals') or {}
    if t.get('cases') == 350 and (best is None or p > best[0]):
        best = (p, j)
assert best, "no 350-case battery receipt found — the full run did not land, or was truncated"
path, d = best
print('receipt', path)
print('seeds_unchanged', d['seeds_unchanged'], 'totals', d['totals'])
bad = sorted(r['case'] for r in d['results'] if r['verdict'] != 'PASS')
print('non-PASS', len(bad))
for b in bad: print('  ', b)
print('free_ops verdict:', [r['verdict'] for r in d['results']
                            if r['case'] == 'phys3d_joints_free_ops'])
PY
```

**The receipt selector is load-bearing, twice over.** `--runs` defaults to `corpus/live/runs/`, so
*every* run in the protocol — the isolated `--only` row of step 4.2, the 8-row arm sweep, this full
run — writes a receipt into the same tree; and that tree **also** holds non-battery receipts from
other fixtures (`r12-import-*/verdicts.json`) whose schema has **no `totals` key**, so a naive read
raises `KeyError`. A verifier who takes the newest directory can read a **1-case** receipt and
conclude the full run was truncated; one who iterates without `.get('totals')` crashes. **Filter on
the battery shape and `cases == 350`.** Both failure modes were hit live by this seat while writing
this step.

**Expected, and read this carefully — `battery_rc=0` is the WRONG expectation here.** A full run is
**not** green on this host, so the runner exits **`1`** (its `verdict` is `PASS` only when every row
passed). The pass condition is:

1. `seeds_unchanged: true`;
2. `cases=350` (full row count ran, not a truncated capture);
3. **`phys3d_joints_free_ops` is NOT in the failing list** — this is the C1 measurement;
4. every remaining failing name is in the **known set**, and the known set is **exactly the 13
   `r94_cannon_*` marker rows**:

```
r94_cannon_backends  r94_cannon_bailout  r94_cannon_det      r94_cannon_det2
r94_cannon_friction  r94_cannon_material r94_cannon_modes    r94_cannon_nan
r94_cannon_order     r94_cannon_parity   r94_cannon_parity2  r94_cannon_sync
r94_cannon_varstep
```

**Count the set, not the prefix — `r94_cannon_` matches 19 rows, of which 13 fail.** The `CASES`
table holds **19** rows whose name starts `r94_cannon_`: the 13 above (all `expected_exit=0`) plus
**6 negative controls** (`r94_cannon_neg_dt`, `_neg_gravity`, `_neg_steps_early`, `_neg_elapsed`,
`_neg_wxyz`, `_neg_grid`, all `expected_exit=2`) which **PASS** in the receipt. A verifier who
matches on the prefix and expects 19 reds will report six false FAILs; one who matches the *names*
above will not. Derive the expected set from the receipt, not from a substring.

**Do not decide this on counts — read the paragraph after this one first.** The r102 receipt
(`corpus/live/runs/20261018T181301123479Z/verdicts.json`) recorded `336 pass / 14 fail`, and the 14th
of those was `phys3d_joints_free_ops` itself. On a clean idle host the expected r104 arithmetic is
therefore `fail = 13` / `pass = 337`. **But the counts are not the test**, because this seat's own
full run produced `336 / 14` *with C1 landed* — see the measurement below before you compare
anything. The binding check is the SET: `phys3d_joints_free_ops` in the **pass** set, and every red
either a `r94_cannon_*` row or an isolated-reproducible artifact.

**MEASURED — and this is the sharpest trap in the whole protocol.** This seat's full 350-row run
completed and returned:

```
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
seeds_unchanged True
battery_rc=1
```

**Those counts are IDENTICAL to the r102 receipt — `336/14` — and the round still landed C1.** The
*set* is what changed:

| receipt | pass/fail | `phys3d_joints_free_ops` | the other 14th row |
|---|---|---|---|
| r102 `…181301123479Z` | `336 / 14` | **FAIL** (`TIMEOUT after 20 seconds`) | — (it *was* the 14th) |
| r104 `…192045623599Z` (this seat) | `336 / 14` | **PASS** (`exit=0`) | `navagent3d_detour_mut_ctx_resume` (contention, §below) |

**A verifier who compares counts will conclude "nothing changed" and will be wrong about C1.** The
counts agree by coincidence: the fixed row was replaced, one-for-one, by a load artifact. **Compare
the failing SET, never the counts.** The C1 pass condition is the row's presence in the *pass* set,
and that is now measured in a real full-battery run at the unchanged 20 s cap — not merely in an
isolated `--only` invocation.

On an idle host the expected outcome is `fail = 13` with **`navagent3d_detour_mut_ctx_resume`
absent** (it is `PASS` 3/3 in isolation here, §below) — i.e. `pass = 337`. **If the L1's idle run
prints `337 / 13`, that is the clean result. If it prints `336 / 14` with `mut_ctx_resume` among the
reds, C1 still landed — check the SET.**

**The 13 `r94_cannon_*` rows are a marker-staleness class, not a physics failure.** Each is
`exit=0 expected=0` with `elapsed ≤ 1.8 s` and the single reason `['exact stdout marker missing']`;
the pinned marker contains `node=v24.21.0` and this host runs `node v26.12.0`. They are carried,
unchanged, from r102 and are **not** this round's claim. Quote them with that receipt.

**A measured load-artifact, so you do not mis-report it as a 15th name.** This seat ran its own
full battery *concurrently with its attack plants* on a host whose load average was **57** (the
r104 round ran a 64-seat swarm). One row outside the known set failed there:

```
FAIL navagent3d_detour_mut_ctx_resume: exit=1 expected=0 reasons=['exit 1 != expected 0',
  'exact stdout marker missing', 'unexpected stderr line: ERROR: navagent3d_detour:
   mut_ctx_resume step1 final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000', …]
```

It is `PASS` in the r102 receipt (`elapsed 1.371`, `reasons []`), and **re-run in isolation three
times by this seat it is `PASS` 3/3** at ~1.5 s. It is a contention artifact of running the battery
on a loaded host, not a regression. **Consequence for step 6.4: run the full battery on an IDLE
host.** If a name outside the 13 appears, re-run it in isolation before reporting a regression — and
report both the batched and isolated results, with the load average at each. (This is the same
discipline as §4.3 trap 2: a red is not evidence until it is reproduced under conditions that rule
out the environment.)

**Note this row's failure shape is distinguishable from the cannon class, which is why triage is
cheap.** It exits **`1`** with a *semantic* stderr assertion
(`mut_ctx_resume step1 final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000`) — the
arm ran and disagreed with itself. A cannon row exits **`0`** with the single reason
`exact stdout marker missing` and no stderr. **A row that exits 0 with only a marker reason is
environmental/staleness; a row that exits non-zero with a step assertion is a candidate real
failure and needs isolation before either conclusion.** Do not lump the two classes together.

---

## 7. C3 — the SKILL decision table  *(calibration, non-author)*

`SKILL.md` did not exist at HEAD; it was created this round. There is therefore **no prior byte
identity to preserve** and no "rest of the file" to keep stable — the gate is content.

### 7.1 The table is present with the required rows

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
test -f SKILL.md && echo SKILL_PRESENT
wc -l SKILL.md
grep -nE '^\| \*\*[A-E]\*\* \|' SKILL.md | sed 's/|.*claim type.*|.*/.../' | cut -c1-90
grep -c 'Unreal-content claim discipline' SKILL.md
grep -nE '^## ' SKILL.md
```

**Expected:** `SKILL_PRESENT`; a decision table with **five** claim-type rows A–E (A file
byte-identity, B static parse, C runtime behavior, D Kimi-side adaptation, E lane-authored static
descriptor); the §1 heading present; and sections for error patterns, a checklist, the open
precedence ruling, refusals, and re-derivation.

### 7.2 No gate line number is carried anywhere

```sh
grep -cE 'run_gate\.sh:[0-9]' SKILL.md
```

**Expected:** `0`. The r103 review measured that **all ten** of the r102 draft's
`gate/run_gate.sh:NN` citations had moved, because the gate changed identity four times in one
round. The landed file cites the gate by `CHECK n <name>` and by sha **only**. **This is the single
most likely regression in a re-edit** — a helpful seat "restoring" a line number would fail this
check. **Observed:** `0`.

### 7.3 Every row's canonical command re-runs green

Run each; the outputs below are what this seat observed on 2026-10-18.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# row A — file byte-identity
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "A_rc=$?")
# row A +NC — must go RED, on a COPY (never in the repo)
T=$WORK/nc-a; rm -rf "$T"; mkdir -p "$T"; tar -c corpus/knowledge/unreal-mcp | tar -x -C "$T"
printf '\n' >> "$T/corpus/knowledge/unreal-mcp/upstream/README.md"
(cd "$T/corpus/knowledge/unreal-mcp" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK$')
(cd "$T/corpus/knowledge/unreal-mcp" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': FAILED$')

# row B — static parse
(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo "B_jq_rc=$?")
(cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json >/dev/null 2>&1; echo "B_jq_dotless_rc=$?")
(cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo "B_shellcheck_rc=$?")
(cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh 2>&1 | grep -c '^In ')
(cd corpus/knowledge/unreal-mcp && bash -n upstream/hooks/unreal-context.sh; echo "B_bashn_rc=$?")

# row C — runtime behavior
which UnrealEditor UnrealEditor-Cmd >/dev/null 2>&1; echo "C_which_rc=$?"
ls /opt/UnrealEngine 2>&1 | head -1
git ls-remote https://github.com/EpicGames/unreal-engine HEAD >/dev/null 2>&1; echo "C_lsremote_rc=$?"

# row D — Kimi-side adaptation
/home/vgpnk/.kimi-code/bin/kimi --version
strings -n 6 /home/vgpnk/.kimi-code/bin/kimi 2>/dev/null | grep -c additionalContext

# row E — lane-authored descriptor, and its reject control
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "E_rc=$?"
python3 corpus/artifacts/unreal-r22/verify_descriptor.py \
  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "E_nc_rc=$?"
```

**Expected — and note the two counter-intuitive ones:**

```
A_rc=0
11          # the copy's OK count
1           # the copy's FAILED count   <-- 11/1, NOT 10/2
B_jq_rc=0
B_jq_dotless_rc=3        # the `.` filter is LOAD-BEARING; without it jq exits 3, not 0
B_shellcheck_rc=0
31                       # `shellcheck -o all` findings; the default ruleset is the one that passes
B_bashn_rc=0
C_which_rc=2
ls: cannot access '/opt/UnrealEngine': No such file or directory
C_lsremote_rc=128
2.2.0
0
E_rc=0
E_nc_rc=0
```

**Observed 2026-10-18 by this seat:** `A_rc=0`; copy `11 OK / 1 FAILED`; `B_jq_rc=0`;
`B_jq_dotless_rc=3`; `B_shellcheck_rc=0`; `shellcheck -o all` → **31**; `B_bashn_rc=0`;
`C_which_rc=2`; `/opt/UnrealEngine` absent; `C_lsremote_rc=128`; `kimi --version` → `2.2.0`;
`additionalContext` count `0`; `E_rc=0` with `PASS local-static actual=accept … reason=one
fixed-scope Unreal-style Runtime module descriptor (local static JSON)`; `E_nc_rc=0` with
`PASS local-static actual=reject … reason=unsupported module Type: 'Unknown'`.

**Three traps in this step.**

1. **Row A's control is `11/1`, not `10/2`.** The r102 draft printed `10/2`; the r103 review
   falsified it. An append to `upstream/README.md` flips **two** manifest rows but only **one**
   *file* — the count of `OK` lines is 11, and the count of `FAILED` lines is 1. A verifier who
   reads the draft's `10/2` as the expected value will report a false FAIL.
2. **`jq -e` without the `.` filter exits 3, not 0.** The dot-less form is what the r102 draft's cell
   printed as `rc 0`; the r103 review caught it as the **command-does-not-reproduce-its-printed-rc**
   error pattern. Both forms are asserted above so the difference is visible rather than assumed.
3. **`shellcheck` must be named with its ruleset.** Default → `rc 0`; `-o all` → `rc 1` with 31
   findings. "shellcheck passes" is meaningless without the ruleset, which is why the landed row
   names it.

### 7.4 The F7 clause's enumeration still holds

```sh
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
```

**Expected:** `6`. **Observed:** `6`. This is the count the F7 clause rests on — the six dissenting
cards. If it moves, the clause's list is stale.

### 7.5 The F7 precedence collision is **stated, not resolved**

```sh
grep -n 'open precedence ruling\|still owed\|F7' SKILL.md | head -10
```

**Expected:** a §4 that **names** the P/C collision, says the ruling is **still owed**, and says it
is not this file's to make — plus the binding interim rule (a row-C label is `unproven-runtime`; a
claim on one of the six dissenting subsystems must cite the card it contradicts). **A file that
silently resolves the collision is a FAIL of this step**, because the subtree is byte-pinned and the
two sides belong to other seats.

### 7.6 `SHONEN.md` box 1 is **not** closed by this landing

```sh
grep -n 'Real decision tables' SHONEN.md
```

**Expected:** the box reads `[~]` or `[ ]` — **not** `[x]`. `SHONEN.md` requires a **named
non-author verifier** for each box, and the author of `SKILL.md` cannot be that verifier. If a seat
has ticked box 1 on the strength of the file's existence alone, that is self-attestation and the
protocol FAILs it. **The L1 must not tick box 1 at close on author evidence.**

---

## 8. The Unreal-content reality check  *(all claims)*

```sh
which UnrealEditor 2>/dev/null || echo "no UnrealEditor on PATH"
ls ~/UnrealEngine 2>/dev/null || echo "no engine tree in HOME"
ls /opt/UnrealEngine 2>/dev/null || echo "no engine tree in /opt"
```

**Expected:** `no UnrealEditor on PATH`, `no engine tree in HOME`, `no engine tree in /opt`. If any
of these shows an editor, every `unproven-runtime` card and every row-C/D label in `SKILL.md` must be
re-examined — they would no longer be justified by construction.

**A green gate is NOT evidence of live-editor behaviour and must never be cited as such.** Unreal
Editor is not installed on this host; live-MCP behaviour is unproven by construction. Nothing in
this protocol, and nothing in the r104 work, is a runtime claim about Unreal.

---

## 9. Residuals and known-open items — do NOT read these as passes

These are measured, dated, and left open on purpose. A close-out that silently absorbs one is a
FAIL of the protocol.

**9.1 A6 is still open — extensionless pointer targets are never swept.** `see
upstream/LICENSE:99999` leaves the gate **GREEN** (measured, §3.5/H6). Queued in r102, not
implemented in r103, **still not implemented in r104**. Do not cite "A1–A4 landed" as "all pointer
gaps closed".

**9.2 A4's mixed case loses the third state.** BLOCKED **and** another check failing prints
`GATE RESULT: FAIL` / exit 1. Read the `STEP=BLOCKED` line, not the summary. Recorded in
`gate/README.md`.

**9.3 A7/A8 (r102 false-pass classes) survive unchanged.** A shadowing `sha256sum` and a
failing/absent `comm` are guarded only for presence, not integrity, so the r102 false-PASS classes
remain reachable under an adversarial `PATH`. Treat a green gate as *indicative* when the invocation
`PATH` is not the system default.

**9.4 The 13 `r94_cannon_*` reds are a marker-staleness class, carried from r102.** They pin
`node=v24.21.0`; this host runs `node v26.12.0`. Not this round's claim, not repaired this round, and
**not evidence of a physics regression**.

**9.5 `POINTERS` is a measurement, not a contract.** It moved `88 → 101` across r103 on prose edits
alone, **and `101 → 103` again inside r104** while this seat was writing — with no gate-logic change,
only prose landed in the subtree and in `reports/round-104/**`. `gate/README.md` was left pinning a
mix of `103` (four places) and stale `101`/`87` lines. Quote `UNRESOLVED=0`; expect the README's pin
to drift again on the next prose edit.

**9.6 This host's `/tmp` is a shared 16 GB tmpfs at ~80 %.** Any step run without `GATE_WORKDIR` can
flake for reasons that have nothing to do with the gate. This is *mitigated* this round (the gate
names and validates its scratch root; the harness preflights it) but **not eliminated** — the gate
still defaults to `/tmp` when neither `GATE_WORKDIR` nor `TMPDIR` is set. A close-out run that
reports FAIL without naming a `WORK_ROOT` should be re-run with `GATE_WORKDIR` set.

**9.7 The gate, the harness and the fixture were all rewritten mid-round, some revisions
mid-sentence.** The gate changed identity at least four times and the harness six, and one harness
revision **failed `bash -n`** while still printing a plausible tally. Every number in this protocol
is stamped with the identity it was measured against; **re-hash before acting on any of them.** The
r103 lesson applies verbatim: *attack verdicts must pin the target's hash.*

---

## Close-out decision rule

| gate | steps | claim | PASS requires |
|---|---|---|---|
| **G1** tree and protected paths frozen | 1 | all | close commit; ledger blobs `MATCH`; `upstream/` + `.manifest.d/` zero diff; `run_battery.py` + `reports/round-10{1,2,3}` zero diff |
| **G2** gate scratch-root contract | 2.1, 2.2 | C2 | `GATE_WORKDIR` named; real-disk root → PASS; bad root → loud early FAIL in **both** the `GATE_WORKDIR` and `TMPDIR` forms |
| **G3** gate green on the committed tree | 2.3 | C2 | exit 0, every pinned line matching, `NAME_SET=OK`, `UNRESOLVED=0` |
| **G4** flake harness stable | 2.4 | C2 | `bash -n` clean; **10/10 STABLE** on a real-disk scratch; preflight `OK` |
| **G5** A1–A4 implemented and falsified | 3.1–3.4, 2.5 | C2 | range-tail RED, prose-hijack GREEN, rename RED both directions, BLOCKED exit 2 + `GATE_REF` exit 0 |
| **G6** hardening removed no detection | 3.5 | C2 | 15 rows RED; **M10 and C7 GREEN**; H6 recorded as open, not passed |
| **G7** C1 row passes at the unchanged cap | 4 | depth | `PASS`, `elapsed < 5 s`, `reasons []`, `seeds_unchanged true`, marker sha `706ad915…`/3921 B, `CASE_TIMEOUT_SECONDS = 20` unmoved |
| **G8** battery bytes | 6 | C1/C2 | diff = `phys3d_joints.gd` **only**; `run_battery.py` `f456bd00…` == HEAD; 146 files; **zero leaked `r90bt_*`**; 350 `CASES` rows, 8 `phys3d_joints` |
| **G9** full-battery counting command | 6.4 | depth | `seeds_unchanged true`; `cases=350`; **`phys3d_joints_free_ops` is in the PASS set**; every failing name is either one of the 13 `r94_cannon_*` rows or a name proven to be a load artifact by isolated re-run. **Compare the SET, not the counts** — `336/14` with the row passing is a PASS, §6.4 |
| **G10** subtree byte-pin intact | 5 | C2 | 12 `OK` / rc 0, glob 24, shards all rc=0, `upstream/` + `.manifest.d/` zero diff |
| **G11** C3 table landed and green | 7.1–7.5 | calibration | rows A–E present; `run_gate.sh:NN` count **0**; every canonical command reproduces its printed rc; row A control `11/1`; F7 enumeration `6`; collision **stated, not resolved** |
| **G12** SHONEN box 1 not self-attested | 7.6 | calibration | box 1 is `[~]`/`[ ]` — not ticked on author evidence |
| **G13** host reality | 8 | all | editor still unavailable, so `static-only` / `unproven-runtime` remain correct |

**Adjudication.** C1 (depth) is supported by G7+G8+G9. C2 (coverage) by G2+G3+G4+G5+G6+G10.
C3 (calibration) by G11+G12. A round-close verdict of ADMIT for an axis requires its gate set green.
**The clause that distinguishes a landed C1 from a described one is the SET, not the count:** if the
full run reports `phys3d_joints_free_ops` among the **failures**, C1 is **not** landed no matter what
§4.2 printed. If it is in the **pass** set — even in a `336/14` run — C1 **is** landed; triage the
residue by the two failure shapes in §6.4. (This seat's own run landed exactly that way.)

---

## Status at protocol-write time (2026-10-18T19:33Z, uncommitted worktree)

**Measured by this seat, on the identities named:**

- **G2 — PASS.** `GATE_WORKDIR` named and validated; real-disk root → `rc=0` PASS; `GATE_WORKDIR=/nonexistent-xyz`
  and `TMPDIR=/nonexistent-xyz` → both `rc=1` with `FAIL scratch root is not a directory` and no
  check run. On the r103 bytes the `TMPDIR` form was a spurious FAIL on a clean tree (reproduced
  6/6). Gate sha at last measurement `e5521304…`.
- **G3 — PASS** (`rc=0`, all pinned lines, `NAME_SET=OK`, `UNRESOLVED=0`) with `GATE_WORKDIR` set.
  **Without it, on this host's `/tmp`, it is `rc=1` with a spurious per-seat FAIL and
  `CHECK 2 BLOCKED`** — see §9.6.
- **G4 — PASS.** `bash -n` clean; **`STABLE (10/10)`** twice, on `GATE_WORKDIR` and on `TMPDIR`.
  The same harness with default `/tmp` correctly reports `SCRATCH_PREFLIGHT=UNWRITABLE` and
  `FLAKY blocked=3/3`.
- **G5 — PASS.** A1 RED, A2 prose-hijack GREEN, A2-NC1 RED, A3 RED both directions, BLOCKED
  `rc=2` / `GATE RESULT: BLOCKED`, `GATE_REF` `rc=0` PASS, mixed `rc=1` — all on whole-repo copies.
- **G6 — PASS.** 15 rows RED; **M10 and C7 GREEN** as required; **H6 GREEN = known false-pass,
  recorded open**.
- **G7 — PASS.** `runner_rc=0`, `wall_ms=2300`, `elapsed 2.062`, `reasons []`,
  `seeds_unchanged True`, marker **3921 B / sha `706ad915…`**, `CASE_TIMEOUT_SECONDS = 20` unmoved.
  Before: `FAIL`, `TIMEOUT after 20 seconds`, 20.178 s wall.
- **G8 — PASS.** Diff = `phys3d_joints.gd` only (+26/−7); `run_battery.py` `f456bd00…` == HEAD;
  146 files; 350 `CASES` rows, 8 `phys3d_joints` rows; zero `r90bt_*` leaks at the close measurement.
- **G9 — PASS (closed by this seat, on a loaded host).** Full 350-row run completed:
  `cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0`, `seeds_unchanged True`,
  `battery_rc=1`, receipt `corpus/live/runs/20261018T192045623599Z/`.
  **`phys3d_joints_free_ops` is in the PASS set** (`exit=0`) — that is C1 measured end-to-end at the
  unchanged cap. The 14 reds are the 13 `r94_cannon_*` rows **plus**
  `navagent3d_detour_mut_ctx_resume` (the load artifact, `PASS` 3/3 in isolation).
  **The counts are identical to r102's `336/14` — the SET is what proves the fix.** See §6.4.
  The L1 should still re-run 6.4 on an **idle** host to get the clean `337/13`, but G9's substance is
  met: the counting command was run, the row moved from fail to pass, and the residue is triaged.
- **G10 — PASS.** 12/12 `OK` rc=0; glob 24; all shards rc=0; `upstream/` + `.manifest.d/` zero diff.
- **G11 — PASS.** Rows A–E present; `run_gate.sh:NN` count **0**; every canonical command
  reproduced its printed rc (`A_rc=0`, copy `11/1`, `B_jq_rc=0`, dot-less `3`, `B_shellcheck_rc=0`,
  `-o all` → 31, `C_which_rc=2`, `C_lsremote_rc=128`, `2.2.0`, `0`, `E_rc=0`, `E_nc_rc=0`);
  F7 enumeration `6`; collision stated, not resolved.
- **G12 — PASS at write time** (box 1 is `[ ]` in `SHONEN.md`; the L1 must not tick it).
- **G1 — NOT YET.** The tree is uncommitted; the L1 must land it and re-run steps 1–2 on the
  committed SHA. **The close-out verdict must name that commit's SHA.**
- **G13 — PASS** (editor absent).

**This protocol is a snapshot, not a verdict.** The gate was rewritten at least four times inside
this round, the flake harness six, and the fixture three
(`88be87fa… → 0cd74715… → c7e77638…`). Every number above was measured on the bytes named next to it.
**Re-run the whole sequence on the frozen commit and report that commit's SHA**; where a number here
has moved, the re-run wins.

**Identities at this seat's last measurement pass (2026-10-18T19:30Z), for a verifier to diff
against:**

| artifact | sha256 (last measured) |
|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf` |
| `reports/round-104/gate/flake_harness.sh` | `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2` |
| `corpus/fixtures/phys3d_joints.gd` | `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc` |
| `corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` |
| `SKILL.md` | `de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903` |
| HEAD | `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` |

Only `run_battery.py` and HEAD are *stable* in the sense that matters (the former is protected, the
latter is the base). The rest moved at least once during this seat's window and may move again.

---

## Appendix — one-shot runner

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
SUB=corpus/knowledge/unreal-mcp; GATE=$SUB/gate/run_gate.sh
WORK=$HOME/.cache/r104-closeout; rm -rf "$WORK"; mkdir -p "$WORK"
export GATE_WORKDIR=$WORK/gate-scratch; mkdir -p "$GATE_WORKDIR"

echo "== G1 tree =="; git rev-parse HEAD; git status --porcelain
echo "== G2 scratch root =="
GW=$WORK/gw; mkdir -p "$GW"
GATE_WORKDIR=$GW bash "$GATE" > "$WORK/gw.txt" 2>&1; echo "gw_rc=$?"
grep -E '^WORK_ROOT|^GATE RESULT' "$WORK/gw.txt"
GATE_WORKDIR=/nonexistent-xyz bash "$GATE" > "$WORK/badgw.txt" 2>&1; echo "badgw_rc=$?"
head -2 "$WORK/badgw.txt"
echo "== G3/G10 gate + pin =="
bash "$GATE" > "$WORK/clean.txt" 2>&1; echo "rc=$?"
grep -E '^MANIFEST_OK|^CLONE_HEAD|^PATH_|^BLOB_DIFFS|^CARDS=|^NAME_SET|^CENSUS|^POINTERS|^GATE RESULT' "$WORK/clean.txt"
(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK$')
(cd "$SUB" && sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK$')
echo "== G4 flake harness =="
bash -n reports/round-104/gate/flake_harness.sh && echo "harness bash -n OK"
GATE_WORKDIR=$WORK/flake bash reports/round-104/gate/flake_harness.sh 10 | tail -4
echo "== G5/G6 attacks (whole-repo copies, GATE_WORKDIR set!) =="
A=$WORK/attacks; rm -rf "$A"; mkdir -p "$A"
fresh(){ rm -rf "$A/c"; mkdir -p "$A/c"; git archive HEAD | tar -x -C "$A/c" || exit 1; cp "$GATE" "$A/c/$GATE"; }
# rc is captured into a variable FIRST: `printf … "$?" … "$(grep …)"` relies on the
# order in which bash expands arguments, which is exactly the fragility §7.3 trap 2
# warns about. Never read $? across a pipe or a command substitution.
run(){ ( cd "$A/c" && GATE_WORKDIR=$A bash "$GATE" ) > "$A/o" 2>&1; local rc=$?
       printf '%-22s rc=%s %s\n' "$1" "$rc" \
         "$(grep -E '^FAIL|^GATE RESULT' "$A/o" | head -2 | tr '\n' ' ')"; }
fresh; run M0-control
fresh; printf '\n' >> "$A/c/$SUB/upstream/README.md";                     run M1-byte-flip
fresh; rm "$A/c/$SUB/executability/materials.md";                        run M2-drop-card
fresh; printf '\nsee upstream/README.md:200\n' >> "$A/c/$SUB/README.md"; run M5-oor-pointer
fresh; mv "$A/c/$SUB/executability/sequencer.md" "$A/c/$SUB/executability/sequence-typo.md"; run M8-rename
fresh; printf '\nsee upstream/README.md:1-9999\n' >> "$A/c/$SUB/executability/materials.md"; run M9-range-tail
fresh; sed -i '4i This card is emphatically not `verified-here`; nothing was observed.' "$A/c/$SUB/executability/editor-general.md"; run M10-prose-hijack
fresh; printf '\nsee upstream/LICENSE:99999\n' >> "$A/c/$SUB/README.md"; run H6-extensionless
echo "== G7 C1 row =="
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs "$WORK/runs-after" \
  > "$WORK/fo.txt" 2>&1; echo "fo_rc=$?"
grep -E '^PASS|^FAIL|^totals' "$WORK/fo.txt"
sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
echo "== G8 battery bytes =="
git diff --stat HEAD -- corpus/fixtures/
git status --porcelain -uall -- corpus/fixtures/ ; ls corpus/fixtures | grep -c '^r90bt_'
git ls-files corpus/fixtures | wc -l
echo "== G11 SKILL =="
grep -cE '^\| \*\*[A-E]\*\* \|' SKILL.md; grep -cE 'run_gate\.sh:[0-9]' SKILL.md
grep -rln 'Not `unproven-runtime`' "$SUB/executability"/*.md | wc -l
grep -n 'Real decision tables' SHONEN.md
echo "== G13 host reality =="; which UnrealEditor 2>/dev/null || echo "no UnrealEditor on PATH"
```

**Then, on an idle host and with a long window, step 6.4** (the full 350-row run) — that is G9. This
seat closed it on a **loaded** host (`336/14` with `free_ops` passing); an idle re-run should give the
cleaner `337/13`. **Compare the failing SET in both cases, never the counts.**

Record every command with its observed output. **A step whose output was not captured was not run,
and has not passed.**
