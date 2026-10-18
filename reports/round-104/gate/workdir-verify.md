# SEAT-13 — WORKDIR-VERIFIER (r104)

Scope: verify the r104 `GATE_WORKDIR` workdir-resilience change (**C2, coverage**).

**Verified artifact (final):** `corpus/knowledge/unreal-mcp/gate/run_gate.sh` sha256
`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`; `gate/README.md` sha256
`66bce16033550b87c787283f22f823fbaf35c7073cd57105f491659fa9b0d367`.
All evidence below was produced against this sha, bracketed by sha checks before and after.

**The change is real and in the gate** (not a harness workaround, which is what I first found):

```
run_gate.sh:59   WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
run_gate.sh:60-68 validation: not-a-directory / not-writable -> named FAIL, exit 1
run_gate.sh:124  MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''   # was: mktemp
run_gate.sh:145  WORK=$(mktemp -d -p "$WORK_ROOT" 2>/dev/null) || WORK=''    # was: mktemp -d
run_gate.sh:150-153 trap cleanup EXIT + INT/TERM/HUP
```

Raw evidence: `reports/round-104/gate/scratch/seat13/`.

---

## 1. Root cause — confirmed, and it is worse than r103 recorded

r103 logged "two anomalies". I reproduced both and pinned the exact code paths. It is a **per-user
quota** on `/tmp`, not a full disk — `df` reports free space while every write fails:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ D=$(mktemp -d); echo hello >"$D/f"; echo "rc=$?"
rc=1                          # "Disk quota exceeded" with 3.1 G reported FREE
$ dd if=/dev/zero of=/tmp/probe bs=1M count=1
0 bytes copied                # not one byte
$ dd if=/dev/zero of=<repo-local>/probe.bin bs=1M count=1
1048576 bytes copied, 3.7 GB/s
```

| # | Site (r103 gate) | Failure | Gate printed | r103 anomaly |
|---|---|---|---|---|
| A | `:74` `MANLOG=$(mktemp)` → `:75` `sha256sum … >"$MANLOG"` | redirect into /tmp fails, `sha256sum` writes nothing, returns 1 | `FAIL per-seat manifest sweep` → `GATE RESULT: FAIL`, rc 1 | (1) "FAIL with CHECK 4 PASS" |
| B | `:86` `WORK=$(mktemp -d)` → `:147` clone | clone cannot write templates, rc 128, empty stderr under `--quiet` | `CHECK 2 BLOCKED (network)` → rc 2 | (2) "empty output, exit 1" |

Path A, same command, only the log destination differs:
```
$ ( sha256sum --strict -c .manifest.d/*.sha256 >"$(mktemp)" 2>&1 ); echo rc=$?
rc=1                          # log in /tmp          -> SPURIOUS FAILURE
$ ( sha256sum --strict -c .manifest.d/*.sha256 >"<repo-local>" 2>&1 ); echo rc=$?
rc=0                          # log on real disk     -> PASS
```

Path B, the errno the gate swallowed:
```
$ git clone <repo> "$W/clone"
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '…/templates/description' to '…/.git/description': Disk quota exceeded
clone rc=128
```

**The BLOCKED label was a misdiagnosis** — network was up at that exact moment:
```
$ timeout 30 git ls-remote <repo> HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD      # correct pin, reachable
```
So a local scratch fault was reported as "upstream unreachable", inverting what exit 2 is
documented to mean ("UNCHECKED, not divergent") — the bytes were neither. `WORK_ROOT` closes this
class: the gate now names the scratch root and its free space in the banner, so a quota failure is
attributable from the output alone.

## 2. GATE_WORKDIR probe — workdir CREATED and REMOVED under it

```
$ GATE_WORKDIR=<repo>/reports/round-104/gate/scratch/seat13/final-gw bash run_gate.sh
rc=0
WORK_ROOT=…/scratch/seat13/final-gw (from GATE_WORKDIR)
GATE RESULT: PASS (checks failed: 0)
```

20 ms poller watching the root (the scratch dir lives only between `mktemp` and the EXIT trap, so a
poller is the only way to observe creation rather than infer it from "absent now"):

```
$ grep -oE 'final-gw/tmp\.[A-Za-z0-9]+' final-gw.seen | sort -u
final-gw/tmp.DOYYldYyZr
$ grep -E 'clone$|clone-files.txt|clone.log|vendored-files.txt' final-gw.seen | sort -u
tmp.DOYYldYyZr/clone
tmp.DOYYldYyZr/clone-files.txt
tmp.DOYYldYyZr/clone.log
tmp.DOYYldYyZr/vendored-files.txt
$ find <GATE_WORKDIR> -mindepth 1 | wc -l
0                             # removed by the EXIT trap
```

**CREATED: yes. REMOVED: yes (residual 0).**

## 3. Default run (no env) — NOT byte-identical; delta is exactly 2 banner lines

My seat's literal criterion was "default run behaviour byte-identical to before". It is **not**,
and I am reporting that rather than rounding it off. The r104 gate adds a scratch-root banner:

```
$ diff before.stdout new-tmpdir.stdout          # r103 gate vs r104 gate, TMPDIR=repo-local
3a4,5
> WORK_ROOT=…/scratch/seat13/tdnew (from TMPDIR)
> WORK_ROOT_FREE=772G of 930G (16% used)
```

That is the **entire** difference. Stripping those two lines makes the streams byte-identical:

```
$ grep -v '^WORK_ROOT' new-tmpdir.stdout > new-tmpdir.stripped
$ cmp before.stdout new-tmpdir.stripped && echo IDENTICAL
IDENTICAL
```

So: **all four checks, every STEP line, every counter and the GATE RESULT line are byte-identical
to r103; the banner grew by exactly two informational lines.** Whether that satisfies "byte-identical"
is a call for the parent — it is a deliberate, documented addition, not an accidental output change.

## 4. Precedence GATE_WORKDIR > TMPDIR > /tmp — all three modes verified

| Mode | Banner | Result |
|---|---|---|
| `GATE_WORKDIR=<dir>` | `WORK_ROOT=… (from GATE_WORKDIR)` | 6/6 PASS, residual 0 |
| `TMPDIR=<dir>` only | `WORK_ROOT=… (from TMPDIR)` | 6/6 PASS, residual 0 |
| neither | `WORK_ROOT=/tmp (from default)` | 3/6 PASS, 3/6 FAIL — host weather |

```
### GATE_WORKDIR=real-disk, 6 runs
SCRATCH_PREFLIGHT=OK (0/20 probe writes failed in …/final-gw)
run  1/6  rc=0  verdict=PASS  POINTERS=102  1.78s
run  2/6  rc=0  verdict=PASS  POINTERS=102  1.13s
run  3/6  rc=0  verdict=PASS  POINTERS=102  1.48s
run  4/6  rc=0  verdict=PASS  POINTERS=102  1.16s
run  5/6  rc=0  verdict=PASS  POINTERS=102  0.96s
run  6/6  rc=0  verdict=PASS  POINTERS=102  1.23s
TALLY runs=6 pass=6 fail=0 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: STABLE (6/6 runs returned PASS with a matching exit code)

### TMPDIR=real-disk, 6 runs
TALLY runs=6 pass=6 fail=0 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: STABLE (6/6 runs returned PASS with a matching exit code)

### default (no env), 6 runs, logdir on real disk
GATE_WORKDIR=/tmp (inherited; GATE_WORKDIR unset)
SCRATCH_PREFLIGHT=UNWRITABLE (20/20 probe writes failed in /tmp)
run  1/6  rc=1  verdict=FAIL       POINTERS=102  0.64s
run  2/6  rc=1  verdict=FAIL       POINTERS=102  0.53s
run  3/6  rc=1  verdict=FAIL       POINTERS=102  0.69s
run  4/6  rc=0  verdict=PASS       POINTERS=102  1.52s
run  5/6  rc=0  verdict=PASS       POINTERS=102  1.30s
run  6/6  rc=0  verdict=PASS       POINTERS=102  1.15s
TALLY runs=6 pass=3 fail=3 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: FLAKY
```

The default column is the control: leaving `/tmp` as the default is correct (existing callers
unchanged), and the flakiness there is host weather the fix is designed to route *around*, not to
eliminate. With a real-disk root the gate is deterministic across every run I made.

## 5. Validation of a bad root — named error, before any check

```
$ GATE_WORKDIR=/nonexistent/xyz bash run_gate.sh; echo rc=$?
FAIL scratch root is not a directory: /nonexistent/xyz
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory
rc=1

$ GATE_WORKDIR=<existing but chmod 555> bash run_gate.sh
FAIL scratch root is not writable: …/scratch/seat13/ro2
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory
rc=1

$ GATE_WORKDIR=/etc/hostname bash run_gate.sh     # a FILE, not a dir
FAIL scratch root is not a directory: /etc/hostname
rc=1
```

Both paths exit 1 with the offending path named, before CHECK 1 runs — this is the "unset/typo'd
GATE_WORKDIR used to fail later and obscurely" hazard the script's own comment claims to close, and
it does.

## 6. NEW FINDING — the gate is currently RED, deterministically

Against the final sha, three consecutive default runs all fail:

```
SHA_RUN_GATE=e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08
run1 rc=1 GATE RESULT: FAIL | POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=1
run2 rc=1 GATE RESULT: FAIL | POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=1
run3 rc=1 GATE RESULT: FAIL | POINTERS=103 POINTER_STRINGS=41 … UNRESOLVED=1

$ grep -E 'MISSING-PATH|STEP=' fin1.out
STEP=PASS
STEP=PASS
STEP=PASS
MISSING-PATH-REL reports/round-104/gate/workdir.md
STEP=FAIL
```

`gate/README.md` references its own receipt twice, and the file does not exist:

```
gate/README.md:373: … Full transcript: `reports/round-104/gate/workdir.md`.
gate/README.md:441: receipt is `reports/round-104/gate/workdir.md`.
$ ls reports/round-104/gate/
final-run.md  flake-harness.md  flake_harness.sh  pin-check.md  scratch  workdir-verify.md
```

**This is not a gate defect** — it is the gate working exactly as designed: a peer's documentation
promises a receipt that has not been written yet, and CHECK 4's repo-relative sweep catches it. It is
also not my file (mine is `workdir-verify.md`; the README names `workdir.md`, which is SEAT-12's).

**Resolved during the round.** SEAT-12's receipt landed; re-run at the same gate sha:

```
$ ls reports/round-104/gate/workdir.md
reports/round-104/gate/workdir.md
$ bash run_gate.sh | grep -E 'MISSING-PATH|GATE RESULT'
GATE RESULT: PASS (checks failed: 0)
```

So this was a transient mid-round red, not a standing one — but it is the second time this round that
the gate's verdict tracked a *documentation* file rather than the gate logic, which is worth knowing
when reading any red from this window.

## 7. Mid-round hazard — a gate under concurrent edit produces torn reads

The implementation landed *while I was verifying*, in four successive shas within ~10 minutes
(`577c8b54` → `b6d8c61a` → `96bcf45a` → `e5521304`). Two runs executed against a half-written file:

```
run_gate.sh: line 186: syntax error near unexpected token `('
run_gate.sh: line 186: `2 BLOCKED (network)\n''
run_gate.sh: line 273: syntax error near unexpected token `('
run_gate.sh: line 273: `printf 'BLOCKED retry with GATE_WORKDIR (or TMPDIR) …'
```

The harness classifies these as `UNEXPECTED` / `TRUNCATED`, i.e. **as flakes** — indistinguishable
from the real flake class C2 exists to detect. With a 64-seat swarm editing a shared tree, "run the
gate N times" is only meaningful once the script is quiescent; my §4 numbers were taken with sha
checks bracketing the runs for exactly this reason.

## 8. Incidental — the POINTERS pin moved

The r103 pin was `POINTERS=101`; the r104 gate prints `102`, and `gate/README.md:248` re-pins
`POINTERS=102` with a fresh measurement note. Cause: `POINTERS` is a measurement of the scanner *on
this tree*, and `gate/README.md` is itself inside the scanned subtree (it excludes only its own
worked examples) — so updating the README grows the count. `POINTER_STRINGS=41` is unchanged. Not a
defect, but any seat quoting a pinned `POINTERS` must re-read it.

**It moved again within the same round.** Re-checked at the end of my window:

```
$ grep -oE 'POINTERS=[0-9]+ POINTER_STRINGS=[0-9]+' gate/README.md | sort | uniq -c
      1 POINTERS=101 POINTER_STRINGS=41      # historical, in the pin-correction note
      2 POINTERS=102 POINTER_STRINGS=41      # the current pin
$ bash run_gate.sh | grep -oE 'POINTERS=[0-9]+ …'
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

The README pins `102`, the live scanner prints `103`, and the gate still exits 0 — because the gate
does **not** assert `POINTERS`; only `UNRESOLVED=0` gates CHECK 4. So a stale `POINTERS` pin cannot
turn the gate red, but it will mislead any seat that compares against it. This is inherent to
measuring a scanner over a tree that contains the document recording the measurement: every edit to
the pin line changes the number it pins. Recommend the pin be stated as a *range or a re-measure
instruction* rather than an exact expected value.

## 9. Verdict on my seat's checklist

| Requirement | Status | Evidence |
|---|---|---|
| workdir created under `GATE_WORKDIR` | **PASS** | §2 poller: `tmp.DOYYldYyZr/` with `clone/`, `clone-files.txt`, `clone.log`, `vendored-files.txt` |
| workdir removed under `GATE_WORKDIR` | **PASS** | §2 `find … \| wc -l` = 0; §4 residual 0 in both GATE_WORKDIR and TMPDIR modes |
| default run byte-identical output | **NOT MET — 2-line banner delta** | §3: `cmp` identical only after removing `WORK_ROOT`/`WORK_ROOT_FREE`; all four checks byte-identical |

## 10. Limits — what this is not

- **No Unreal runtime claim.** The editor is not installed here; nothing above is evidence about
  live-MCP or editor behaviour. This is a static checker over vendored bytes.
- I did not modify the gate or any fixture; all my edits are under
  `reports/round-104/gate/scratch/seat13/` and this file.
- Verified against the *installed* sha `e5521304…`. If `run_gate.sh` or `gate/README.md` changes
  again, §2–§6 must be re-run — the README is both the pinned-values doc *and* an input to CHECK 4.
- Quota readings (`3.1 G free`, 80 %) are point-in-time on this host; the transferable part is the
  mechanism (`df` free ≠ writable under a per-user quota).
- The `/tmp` pressure is intermittent: it failed at 16:19, was writable at 16:22, and failed again
  at 16:28. "I ran it once and it passed" is not evidence on this host.
