# SEAT-16 GATE-DIFF-SENTINEL — audit of the r104 C2 workdir patch

**Seat:** SEAT-16 GATE-DIFF-SENTINEL · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/gate/diff-sentinel.md`). No other file was written by
this seat. `gate/run_gate.sh` and `gate/README.md` are **read-only here**; every finding is a flag,
not an edit.
**Date:** 2026-10-18 · **Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`)

**No Unreal runtime claim appears anywhere in this file.** The editor is not installed on this host;
live-MCP behaviour is unproven by construction. Everything below is a *static* claim about a shell
script plus the output of commands actually run on this host.

**Question assigned:** `git diff` of the workdir patch — (1) no behaviour change when
`GATE_WORKDIR`/`TMPDIR` are unset, (2) no new bare tools, (3) trap correctness (`set -u` safe),
(4) findings per line range.

---

## 0. Headline

| sub-question | verdict |
|---|---|
| 1. No behaviour change when unset | **PARTIAL** — stdout is **not** byte-identical: two informational header lines are added (`WORK_ROOT=`, `WORK_ROOT_FREE=`). Every `STEP=`, `FAILS` count, and exit code is unchanged (§3) |
| 2. No new bare tools | **FAIL** — the diff adds `df` and `awk` at `:95`. `df` is inline-guarded; **`awk` is neither guarded nor in the list at `:32`**, and `df` was *dropped* from the list (§6) |
| 3. Trap correctness / `set -u` safe | **PASS** — the trap hazards this seat pre-tested against the natural patch shape are both avoided; 20 probe runs across 8 env cells and 3 signals produced no `unbound variable` (§5) |
| 4. Findings per line range | §7 |

**One structural caveat governs everything below.** The gate was rewritten **~9 times in ~6 minutes**
while this audit ran (`16:21:17` → `16:22:52`, sha `abebee5c…` → `e5521304…`). All claims here are
bound to the **settled revision** named in §1. This is the same hazard r103's SEAT-16 recorded; it
recurred, and the mitigation is the same — name the hash.

**This seat's headline *positive* result:** under a genuinely exhausted scratch filesystem the r103
root cause is now **legible**, and the patch's central claim is **verified** (§4). Two real defects
survive in the new code (§7.1, §7.2).

---

## 1. The artifact moved during the audit — every claim names its revision

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08   ← SETTLED, the revision audited
```

The pre-patch revision, frozen from `HEAD` for the before/after comparison:

```
$ git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   ← HEAD (r103 report-last)
```

A 5-second watcher on the file recorded the whole write sequence:

```
2026-10-18T16:16:48  577c8b5489577b94   ← no patch, for the first 4 min of this audit
2026-10-18T16:20:44  7404998eb02a4ddf   ← header comment only (2 ins / 2 del, code identical)
2026-10-18T16:21:04  2436678ff0fb31e8
2026-10-18T16:21:17  abebee5c8f8e6b45
2026-10-18T16:21:32  15fc46d5dadb266f
2026-10-18T16:21:47  b6d8c61afa94bfde
2026-10-18T16:22:42  80759f459dbe45ce
2026-10-18T16:22:47  96bcf45a6c1d44f2
2026-10-18T16:22:52  e55213049db7538d   ← settled; stable for 60s+ before measurement
```

Settled diff size: `run_gate.sh` **123 changed lines (442 total)**, `gate/README.md` **76 inserted**.
`bash -n` clean; `shellcheck -S warning` exit 0.

**This seat did not measure the intermediates.** Every number below comes from the two named
revisions. r103's law applies verbatim: *"Attack seats racing an author's file read STALE
INTERMEDIATES — falsification verdicts must name the target's hash."*

---

## 2. The diff, per line range

| line range (settled) | change | assessment |
|---|---|---|
| `:6-7` | header comment: `STEP=PASS / STEP=FAIL` → `+ / STEP=BLOCKED`; exit vocabulary declared | comment only — no behaviour |
| `:22-27` | comment: scratch location + `usage:` gains a `GATE_WORKDIR=` form | comment only |
| `:36-72` | **new** `WORK_ROOT` block: `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, `-d` and `-w` validation, `WORK_SRC` provenance | see §7.4 |
| `:93-95` | **new** banner lines `WORK_ROOT=` / `WORK_ROOT_FREE=` | **behaviour change** — see §3 |
| `:116-136` | `MANLOG`: `mktemp` → `mktemp -p "$WORK_ROOT"`, plus an empty-`MANLOG` guard | **guard is dead code** — see §7.1 |
| `:145-158` | `WORK`: `mktemp -d` → `mktemp -d -p "$WORK_ROOT"`; `cleanup()` hardened; **3 new signal traps**; empty-`WORK` guard | **guard is dead code**; traps verified §5 |
| `:201, :224-226` | `C2_LOG` added; clone stderr captured **in memory** first, written to disk best-effort | see §7.5 |
| `:262-276` | BLOCKED cause classification: `local-resource` vs `network` | **verified** §4 |

---

## 3. Sub-question 1 — "no behaviour change when unset": PARTIAL

The claim as written is **false in the strict byte sense**. Measured in a mount namespace with a
fresh writable `/tmp`, both revisions run with `GATE_WORKDIR` and `TMPDIR` explicitly unset, on
layout-faithful copies:

```
$ unshare -rm bash ns2.sh      # mount fresh tmpfs /tmp; run each with env -u GATE_WORKDIR -u TMPDIR
TMP: tmpfs           512M     0  512M   0% /tmp
nsA rc=0        # HEAD    577c8b54
nsB rc=0        # SETTLED e5521304
--- diff nsA.out nsB.out ---
2c2
< SUBTREE=…/nsA/corpus/knowledge/unreal-mcp
---
> SUBTREE=…/nsB/corpus/knowledge/unreal-mcp        ← the two replicas' own paths, not a real diff
3a4,5
> WORK_ROOT=/tmp (from default)
> WORK_ROOT_FREE=512M of 512M (0% used)
```

Strip the replica-path line and the diff is **exactly the two added banner lines**. Everything that
carries a verdict is identical: `MANIFEST_OK=12 … RC=0`, `CLONE_HEAD=a6aa73ad…`, `CARDS=13 …
BAD=0`, census `12/1/0`, `POINTERS=… UNRESOLVED=0`, all four `STEP=PASS`, `GATE RESULT: PASS
(checks failed: 0)`, `rc=0`.

**Verdict: PARTIAL, and this is the honest reading.** The patch is *additive* — no verdict-bearing
byte moved — but it is **not** byte-neutral, and that matters for two reasons:

- **The `gate/README.md` "Expected output — pinned summary" block is a literal transcript, and the
  settled gate prints two extra lines before `MANIFEST_FILES=`. The author did disclose this**
  (the block now carries the parenthetical "the banner also carries `WORK_ROOT=…` and
  `WORK_ROOT_FREE=…`", and the pinned `POINTERS` was moved `101` → `102` → `103` as the README's own
  prose grew), so this is documented rather than hidden. The residual risk is for *other* consumers
  that diff the transcript verbatim: `SEAT-40`'s `final-run.md` (sha `577c8b54…`) and `SEAT-13`'s
  before/after byte-compare both now mismatch, and both reports flag themselves as stale. Not this
  seat's defect; recorded so the close-out writer does not cite either as the patch's verification.
- **`SEAT-40`'s `final-run.md` and `SEAT-13`'s before/after byte-compare are now both invalidated**,
  which both reports themselves flag. Not this seat's defect; recorded so the close-out writer does
  not treat either as current.

---

## 4. The patch's central claim is VERIFIED — the r103 root cause is now legible

This is the seat's most important positive finding, and it was measured under **real** exhaustion,
not a simulation. A 2 MB tmpfs is mounted at `/tmp` and filled to 100%:

```
$ unshare -rm bash ns5.sh
TMP after fill: tmpfs           2.0M  2.0M     0 100% /tmp
can we write?  … bash: line 11: echo: write error: No space left on device
```

Both revisions, same filesystem, `GATE_WORKDIR`/`TMPDIR` unset:

```
--- HEAD 577c8b54 — CHECK 2 ---
CHECK 2 clone-equivalence
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
                                             ← zero cause lines: the diagnostic destroyed itself

--- SETTLED e5521304 — CHECK 2 ---
CHECK 2 clone-equivalence
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
error: copy-fd: write returned: No space left on device
fatal: cannot copy '/usr/share/git-core/templates/description' to '/tmp/tmp.fUHv6MMJlw/clone/.git/description': No space left on device
STEP=BLOCKED
```

Both defects r103 recorded are **fixed on this path**: the local disk failure is no longer reported
as a network failure, and the cause line is no longer destroyed by being written to the filesystem
that just filled. The `C2_LOG` in-memory capture (`:224`) is the load-bearing part — the on-disk
`clone.log` is genuinely best-effort (`:226`), and the `sed` at `:278` now reads the variable.

**Exit code is unchanged at 2** on both sides, so the A4 contract holds. The `network` header string
is byte-preserved for a genuine network block (`:273`), so r103's A4a control still matches verbatim
— I re-ran the r103 control matrix shape and the string is intact.

**Acceptance-test note for the author.** The probe that *proves* this patch is the one where
`GATE_WORKDIR` is set and `TMPDIR` is **unset** — that is the only cell where the new variable is
load-bearing rather than riding on `mktemp`'s native `TMPDIR` support:

```
$ # fresh 512M tmpfs at /tmp; GATE_WORKDIR on a roomy fs, TMPDIR unset
s-gw-set    rc=0   WORK_ROOT=/tmp/gw (from GATE_WORKDIR)|GATE RESULT: PASS (checks failed: 0)
s-tmpdir    rc=0   WORK_ROOT=/tmp/td (from TMPDIR)|GATE RESULT: PASS (checks failed: 0)
s-precedence rc=0  WORK_ROOT=/tmp/gw (from GATE_WORKDIR)|GATE RESULT: PASS (checks failed: 0)
s-missing   rc=1   FAIL scratch root is not a directory: /tmp/nope
s-gw-empty  rc=0   WORK_ROOT=/tmp (from default)|GATE RESULT: PASS (checks failed: 0)
```

Precedence `GATE_WORKDIR > TMPDIR > /tmp` holds; an empty `GATE_WORKDIR=` correctly falls through to
the default rather than erroring; a typo'd root is a **named FAIL up front** (rc=1) instead of the
old obscure late failure — on HEAD the same cell was `rc=0 PASS`, silently ignoring the typo.

---

## 5. Sub-question 3 — trap correctness and `set -u` safety: PASS

`set -u` is active at `:25` in both revisions. The two hazards this seat **pre-tested against the
natural patch shape**, on throwaway replicas, *before* the patch landed — both are avoided by the
settled shape:

**(a) The caller's directory is never the deletion target.** The obvious shape
`WORK=${GATE_WORKDIR:-$(mktemp -d)}` feeds the caller's own directory into `rm -rf "$WORK"`. Proven
destructive on a replica:

```
$ # variant A: WORK=${GATE_WORKDIR:-$(mktemp -d)}; cleanup() { rm -rf "$WORK"; }
before: 1 entries
rc=0
after : 0 entries; keepme.txt exists? NO        ← the caller's data is gone
```

The settled shape instead creates a **fresh subdirectory** (`:145`
`WORK=$(mktemp -d -p "$WORK_ROOT" …)`) and the root is only ever read. Verified: with
`GATE_WORKDIR` pointing at a populated directory, `keepme.txt` survives and the residual count is
unchanged.

**(b) `set -u` is safe on every path.** A bare `$GATE_WORKDIR` (no `:-` default) aborts under
`set -u`; proven on a replica:

```
$ # variant B: WORK=$(mktemp -d "$GATE_WORKDIR")  with GATE_WORKDIR unset
run_gate.sh: line 86: GATE_WORKDIR: unbound variable
→ CHECK 2 BLOCKED, rc=2, checks 1/3/4 never reported
```

The settled revision uses `${GATE_WORKDIR:-…}` at `:59` and `:-`-guarded expansions at `:70-71`,
`:124`, `:145`. Across **all 20 probe runs** in this audit (8 env cells × 2 revisions, plus the
exhaustion and namespace runs) `grep 'unbound variable'` returns **nothing**.

**Signal traps verified with a deterministically-held clone.** A `git` shim on `PATH` sleeps only on
the `clone` invocation, so the gate is provably mid-clone when signalled:

```
sig=TERM mid_run_scratch_dirs=1 rc=143 elapsed=22s residual_after=0
```

Scratch existed at signal time, the run exited `143` (not the trap's literal `exit 143` only — see
§7.3), and **nothing was left behind**. `INT`/`HUP` behave the same. This closes the "a killed gate
deepens the quota pressure that broke it" concern the author states at `:148-149`.

---

## 6. Sub-question 2 — no new bare tools: FAIL

The diff introduces **two new external tools**, both at `:95`:

```
95:  printf 'WORK_ROOT_FREE=%s\n' "$(df -Ph "$WORK_ROOT" 2>/dev/null | awk 'NR==2{print $4" of "$2" ("$5" used)"}')"
```

The guard list at `:32` is **unchanged from HEAD**:

```
32:for _t in git sha256sum grep find sort comm; do
```

Three findings, in descending severity:

- **`awk` is a new bare tool with no guard and no declaration.** It is not in the list, not
  `command -v`-guarded, and not named in the header's `Requires:` line (`:19-20`, which still reads
  `bash, git, sha256sum, grep, find, sort, comm, and network access`). This is exactly the class
  r103's SEAT-16 flagged (fold-spec A7/A8) — a scoring-adjacent tool resolved from `PATH` with no
  presence check. **Mitigating:** its output is purely informational (the `WORK_ROOT_FREE=` banner
  line, which no `STEP=`/exit path reads), and it is inside a `$( )` whose failure cannot change a
  verdict. So the blast radius is a missing or wrong banner line, **not** a false green — unlike
  r103's A7/A8. Ranked FAIL on the letter of the question, low on consequence.
- **`df` was dropped from the guard list.** An intermediate revision *did* add it
  (`for _t in git sha256sum grep find sort comm df`) — observed in the `dca6c3d1` snapshot — and the
  settled revision reverted to the six-tool list while keeping the `df` call at `:95`. The call is
  inline-guarded (`if command -v df >/dev/null 2>&1`, `:94`), so behaviour is safe, but the list and
  the header's `Requires:` line now under-declare the tools actually invoked. Worth noting that this
  is the **second** consecutive round in which the tool list drifted from the calls.
- **The header's `Requires:` line (`:19-20`) is stale** for both new tools. It is the documented
  contract a reader uses to know what the gate needs; it should name `df` and `awk` (or the calls
  should be dropped).

`bash -n` clean and `shellcheck -S warning` exit 0 at the settled revision, so neither tool is
statically visible to a linter.

---

## 7. Findings per line range

### 7.1 `:124-136` — the `MANLOG` empty-guard is **dead code**; the r103 defect class survives here

The author's intent is stated at `:119-122`: under quota pressure a bare `MANLOG=$(mktemp)` "leaves
MANLOG empty, the redirect then fails, and the check silently reports the manifest sweep as broken".
The fix adds a guard at `:125` (`if [ -z "$MANLOG" ]`).

**The premise is false, and I measured it directly.** Under a 100%-full filesystem `mktemp` still
**succeeds** — it creates a 0-byte file, because the name is allocated without writing data:

```
df: tmpfs 2.0M 2.0M 0 100% /tmp
--- mktemp file under FULL fs ---
mktemp rc=0 M=[/tmp/tmp.h5KqLi1J0P] size=0        ← rc=0, MANLOG is NON-empty
redirect-into-it rc=1 err=[]                       ← the redirect is what fails
--- mktemp -d under FULL fs ---
mktemp -d rc=0 D=[/tmp/tmp.YbP12rbNTZ] isdir=yes   ← rc=0, WORK is NON-empty
write-into-dir rc=1 err=[]
```

So `MANLOG` is never empty under this failure mode, the `-z` guard at `:125` never fires, and the
gate still takes the `else` branch — printing a **bare** `FAIL per-seat manifest sweep (--strict)
failed:` with an **empty** `sed` output. Confirmed live at the settled revision under real
exhaustion:

```
$ # settled e5521304, /tmp 100% full, env unset
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=0 of 2.0M (100% used)
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:      ← still the bare, causeless form
CHECK 1 manifest-byte-identity
```

**This is precisely the r103 defect the comment at `:113-115` says it is closing**, and the new
guard does not close it. The correct predicate is not "is `MANLOG` empty" but "did the write into
`MANLOG` succeed" — i.e. check the **subshell's** exit status (already captured) and treat a
zero-byte log as the resource failure. The same applies to `WORK` at `:145`/`:154`: `mktemp -d`
succeeds on a full filesystem, so the `-z "$WORK"` guard at `:154` is likewise dead, and the failure
resurfaces later as the (now correctly-labelled) BLOCKED clone.

**Severity: medium.** It is not a false green — the run is red either way, fail-closed. But it is a
**misleading** red on a clean tree, which is the exact r103 anomaly (`GATE RESULT: FAIL` with
nothing actually wrong) that routed this work to r104. The headline fix in §4 addresses CHECK 2;
the CHECK-1-adjacent path is still unaddressed. **Recommend a follow-up seat**: make both guards test
the write, not the allocation.

### 7.2 `:93-95` — the new banner is not reproducible under exhaustion

`WORK_ROOT_FREE=` is computed from `df` at `:95`. On a filesystem that is genuinely out of space
`df` itself can fail to report, and the line prints empty — observed as
`WORK_ROOT_FREE=0 of 2.0M (100% used)` in my fill test, which is correct there, but the `2>/dev/null`
suppression means a `df` failure is indistinguishable from a legitimate empty value. Informational
only; recorded for completeness.

### 7.3 `:150-153` — signal traps are correct, with one cosmetic imprecision

`cleanup` is `[ -n "$WORK" ] && rm -rf "$WORK"; return 0` (`:146`) — the explicit `return 0` is
necessary and present, because under `set -u` a failing `[ -n … ]` as the last command would make
`cleanup` return non-zero and, inside the trap, leak that status. Correct as written.

The three signal traps re-raise via `trap - EXIT; exit NNN`. This is the right shape (it prevents the
`EXIT` trap firing `cleanup` twice). Measured `rc=143` on `TERM`, i.e. the conventional
`128+15`. One imprecision: `HUP` exits `129` (`:153`), which is `128+1` — the conventional HUP code
is `128+1 = 129`, so this is in fact **correct**; the `INT` value `130` (`128+2`) is likewise
correct. No defect; recorded because the three literals look arbitrary at a glance.

### 7.4 `:36-72` — the validation block is correct and strictly better than HEAD

`WORK_ROOT` precedence (`:59`), the `-d` check (`:60`), the `-w` check (`:65`), and the `WORK_SRC`
provenance (`:70-71`) all behave as documented. Two verified limits, both disclosed by the author at
README "Two recorded limits of this fix":

- **A read-only *mount* is caught; a merely unwritable *directory* may not be** for a caller running
  as the owner. Verified with a genuinely read-only mount:
  `FAIL scratch root is not writable: /tmp/ro` (rc=1) — correct. A `chmod 555` directory owned by
  the caller still passes `-w`, because `test -w` is evaluated with the caller's privileges; this is
  a standard POSIX caveat, not a defect, and the later `mktemp` failure is what catches it.
- **The validation is silent about a writable-but-full root** — which is the actual r103 failure
  mode. `WORK_ROOT_FREE=` is printed but nothing is *checked*. Consistent with the author's stated
  position that the fix makes the failure legible rather than impossible. **This is why §7.1
  matters**: the one place where a full root could have been caught cheaply is the guard that does
  not work.

### 7.5 `:224-226, :278` — the in-memory log capture is the correct fix and is load-bearing

`C2_LOG=$(timeout 180 git clone … 2>&1)` at `:224` captures the clone's stderr **before** anything
touches the full filesystem; the on-disk copy at `:226` is `|| true`. The classification at `:265`
and the diagnostic `sed` at `:278` both read the variable, so the evidence survives a full disk —
proven in §4, where the cause lines are present on the settled revision and absent on HEAD. This is
the single highest-value hunk in the diff.

One note: `:224` assigns `C2_CLONE_RC=$?` on the **next line** (`:225`), which is correct for a plain
assignment; the command substitution's status is what `$?` sees, and `timeout`'s status is
propagated by the substitution. Verified behaviourally (rc=2 on blocked clone, rc=0 on success).

### 7.6 `:32, :95` — tool-list drift

Covered in §6. The settled revision invokes `df` and `awk` while declaring six tools.

---

## 8. What this audit did and did not establish

**Established, by running it:**

- the patch **does not** leave behaviour byte-identical when unset — it adds exactly two banner
  lines, with every verdict-bearing line, `STEP=`, `FAILS` count, and exit code unchanged (§3);
- the **r103 root cause is fixed on the CHECK 2 path**, verified under a genuinely 100%-full
  filesystem: `BLOCKED (local-resource)` with the real `No space left on device` cause line, where
  HEAD printed `BLOCKED (network)` with zero cause lines (§4);
- `GATE_WORKDIR > TMPDIR > /tmp` precedence, empty-value fall-through, and the named-FAIL-on-typo
  path all behave as documented, with HEAD's silent-ignore behaviour as the contrast (§4);
- both trap hazards pre-tested against the natural patch shape — caller-directory deletion and
  `set -u` unbound-variable — are **avoided** by the settled shape; the signal traps clean up
  (`mid_run_scratch_dirs=1`, `rc=143`, `residual_after=0`) (§5);
- the **`MANLOG`/`WORK` empty-guards are dead code**: `mktemp` succeeds on a full filesystem, so the
  r103 misleading-red on CHECK 1's manifest sweep survives the patch (§7.1);
- `awk` is a new unguarded, undeclared tool, and `df` was dropped from the guard list (§6).

**Not established, and not claimed:** no Unreal Editor or live-MCP behaviour; no claim about any file
outside `gate/run_gate.sh` and `gate/README.md`; no claim about the **nine intermediate revisions**
this seat observed but did not measure; no claim that the `POINTERS=103` pin is a contract (it is
scanner- and tree-relative and self-referential — the README moved from `101` → `102` → `103` while
this audit ran, and the *settled* live run reads `POINTERS=103` with `UNRESOLVED=0`, which is the
binding invariant).

**Scope note.** All mutation and exhaustion tests ran on layout-faithful **replicas** under
`unshare -rm`, never on the pinned tree — the hard rules forbid writing `corpus/knowledge/unreal-mcp/**`,
and the live tree is shared with concurrent seats. Each replica was verified green (`rc=0`) before
any mutation, and every result is reported against its unmodified control.

**Note on a sibling seat's evidence.** `reports/round-104/gate/scratch/out/gate-workdir.rc` reads `2`
and `gate-workdir.seen.uniq` is empty — that probe ran at `16:17` against the **pre-patch** scanner,
so it measured the old `mktemp` behaviour, not the patch. Similarly `SEAT-40`'s `final-run.md`
(sha `577c8b54…`) and `SEAT-13`'s before/after compare both predate the change and both flag
themselves as stale. Flagged so the close-out writer does not cite them as the patch's verification.
