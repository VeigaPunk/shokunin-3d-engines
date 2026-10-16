# r100 critic — adversarial gate on the fixed-fps capstone (`8183191`, + `523c943`)

Seat: critic (attack the approach, not the owner). Scope: the **8 `r100_fpslat` rows** in
`corpus/fixtures/run_battery.py` and the **`corpus/fixtures/r100_fpslat.gd`** driver, plus
the six `r100_probe_r100b_*.gd` seeds they require. Reviewed at `8183191` (author landing);
the seed fix `523c943` landed mid-review and is covered below. This seat does not admit,
edit, or commit anything.

Method: static read of driver + seeds + all 142 pins; **pristine-archive reproduction**;
**13 probe runs over 10 distinct mutations**; 2 clean reps of all 8 rows; load-margin
measurement; dead-entry and flake-class audit; provenance cross-checks against the r100
scout/boundary reports. Archive: `/home/vgpnk/critic-r100-archive/` (committed /
committed+probes / 13 mutation trees / 16 run roots). Never `/tmp`.

---

## 0. Bottom line

| claim attacked | result |
|---|---|
| the 8 receipts on the final bytes | **reproduced 8/8 PASS ×2** (mine, on the tip bytes); no counterexample |
| 142 cells / 8 arms | **confirmed** (21/13/22/34/11/8/24/9 = 142) |
| provenance chain (seeds ≡ boundary corpus) | **confirmed**, all six `cmp`-identical |
| pins are non-vacuous | **7/7 expected-FAIL probes failed for the authored reason; 3/3 expected-PASS controls passed** |
| envelope cells assert something | **1/1 content injection into the unbound stream NOT detected** → declared blind spot, demonstrated; a cheap deterministic projection exists |
| the landing is self-contained | **falsified on `8183191`** (0/8, every cell `err=probe source missing`) — converged with reviewer F1, **fixed by `523c943`**, re-verified |
| the life row fits the 20 s case cap | **falsified in margin**: 15.54–15.69 s / 20 s (78 %), by construction; one-line fix measured at 9.60 s |
| `leak` / `w` / `beq` / `eq` surfaces | **dead or derived** (inventory §6) |

Three **fixable defects** (§2, §3, §6), three **tradeoffs the canonical judge must rule on**
(§4, §7), zero counterexamples to the current green claim.

---

## 1. Reproduction and archive

```
git archive 8183191 | tar -x -C /home/vgpnk/critic-r100-archive/committed
cp -a committed committed+probes && cp <worktree>/corpus/fixtures/r100_probe_r100b_*.gd committed+probes/corpus/fixtures/
```

* **`8183191` alone** (`runs-committedonly/20261016T100241964960Z/verdicts.json`):
  `8 cases, pass=0, fail=8`, reasons `exact stdout marker missing`; every one of the 142
  cells renders `{err=probe source missing}`, e.g.
  `FAIL r100_fpslat sched ffps60@gp{err=probe source missing} ffps60@jolt{err=probe source missing} …`.
  This is the same F1 the reviewer found independently (`r100-reviewer.md` §3); the
  counterexample is confirmed, not new.
* **`523c943`** adds exactly the six seeds (`+710`); their sha256-16 match my archive
  copies byte-for-byte (`a577d6265f78f1ff / 0adf98aadd38cdc6 / 427fc7d159f524da /
  249c0caf8ac4a1d5 / 8bfd76adf5ae5551 / c61025594deff49d`). So the two green runs below
  **are** tip verification.
* **Clean reps** on `committed+probes` (all 8 rows, `--godot /usr/bin/godot`, battery's own
  20 s cap, 2–5 batteries concurrent, loadavg 3.6–5.4 on 32 cores):
  `runs-probes/20261016T100249134903Z` **8/8 PASS**,
  `runs-runB2/20261016T100718212385Z` **8/8 PASS**. No flake observed in any r100 row
  under mild contention.
* Provenance: all six seeds `cmp`-identical to `corpus/live/r100-boundary/probes/r100b_*.gd`.
  Cross-checked the pins against the boundary tables where they overlap (tps=30
  `ffps30/60/120` → `120/239/478`, `[0:1,1:119]/[0:1,2:119]/[1:1,4:119]`, `c9625c56…`;
  tps=120 `ffps60/120` → `61/120`, `c20df6e2…`) — **agreement, no stale copies**. The
  falsified scout formula `n_pr = 120·N/60 + 1` is absent from the pins (N=90 → 180≠181,
  N=120 → 239≠241, N=240 → 478≠481), and the author *corrected* the boundary's
  "SIGSEGV (rc=134)" mislabel to "SIGABRT after the signal-11 handler". Both are positive
  provenance evidence.
* Internal law consistency (pins checked against each other, not the reports): the 85
  `traj` hashes collapse to 21 groups exactly as the claimed delta law requires
  (`2311ff14`=1/60 in 49 cells, `c9625c56`=1/30 in 7, `c20df6e2`=1/120 in 4,
  `a2d4de09`=Dummy non-integrating in 2, `e3b0c44298fc1c14`=empty traj in the 4 `n_ph=0`
  cells); `ffpsfloat`(modes) ≡ `ffps59`(compose) sha `4da72254fb27d565` confirms the
  "59.94 truncates to 59" law across arms; `aa6dc8609ca2e39d` (1 tick) shared by
  `quit_ffps60` and `qa1_ffps60` across two different probes. No contradiction found.

---

## 2. Fixable defect F1 — the life row sits at 78 % of the fixed case cap, by construction

**Counterexample**: `r100_fpslat_life` cannot finish faster than ~15 s because the three
`noquit_unbound` cells carry a 5 s outer `timeout -s KILL` and land in three *different*
chunks (`CHUNK := 8`, cells ordered gp|jolt|dummy) → three serialized 5 s bounds.

Measured (`elapsed_seconds`, 20 s cap):

| run | sched | qa | modes | compose | rt | area | **life** | cls |
|---|---|---|---|---|---|---|---|---|
| `runs-probes` | 2.59 | 2.71 | 5.50 | 4.30 | 2.04 | 1.31 | **15.54** | 1.89 |
| `runs-runB2` | 2.74 | 2.62 | 5.21 | 4.35 | 1.96 | 1.23 | **15.69** | 1.88 |
| `mut-append` (life only) | | | | | | | **15.66** | |

4.4 s of headroom on the one row that already failed once in the author's run A, under a
contention story (48 foreign `yes` hogs, 10 unrelated arms killed at the same cap) that the
report itself documents. A parent-cap kill is attributed to the row, not to load.

**Smallest safe correction (measured)**: `d["bound"] = 5` → `3` for `noquit_unbound`
(`r100_fpslat.gd:521`). Probe `mut-bound3` (same tree, one constant changed):
`runs-mutbound3/20261016T100747725720Z` **PASS**, life elapsed **9.60 s** — headroom more
than doubles, envelope unchanged (`rc=137,boot=1,tickge1=1`; the author's own unbound logs
show ~1 tick/17 ms, i.e. ~170 ticks in 3 s vs the `tickge1` floor of 1). No pin moves.

---

## 3. Fixable defect F2 — expected-error receipts embed probe **source line numbers**

My first blind-spot probe (a *line-adding* injection in the `noquit_unbound` branch) failed
the row for a completely unrelated reason: `finalize_touch@gp` flipped from the pinned
`sha=c43c098988f53d9b` to `sha=f693ced6aadcfb23`. Cause, from the child logs:

```
clean :          at: _finalize (res://r100b_life.gd:91)
line-adding mut: at: _finalize (res://r100b_life.gd:92)
```

The `lfin`/`lerr` design deliberately **keeps** the SCRIPT ERROR in the hash (`ee=1`,
anti-masking — correct), but the `at:` + GDScript-backtrace lines ride along as ordinary
content, so the pin is a function of the probe's *source layout*. Same for the `err` cell
(`at: _physics_process (res://r100b_life.gd:68)`), i.e. 6 life cells.

* Control `mut-append` (comment appended at EOF, no line shift): **PASS** → the coupling is
  to line *shifts*, not to edits in general.
* Precedent: the r99 simplifier's SP-5 and the r99 adjudicator's fold-queue #2 already
  adjudicated this class — *"frozen-probe rows are line-coupled to the probe source —
  **record the coupling**, never delete probe lines without re-deriving cells."*
* r100 **re-introduces** the class and records it nowhere: not in the driver header's
  normalization block, not in the author report. Today it is latent (the seeds are
  byte-frozen and just landed), but it is exactly the hazard that made my own probe lie.

**Smallest safe correction**: one header line in `r100_fpslat.gd` (and a §2 bullet in the
author report) stating the disposition the r99 adjudicator chose — *any* edit to
`r100_probe_r100b_life.gd` (or any re-copy that changes its line numbering) invalidates the
`err`/`finalize_touch` pins and requires re-derivation. Do **not** mask the line numbers
here: that would move 6 pins and contradict the r99 disposition.

---

## 4. The assigned question — does the env-`beq` suppression mask real divergence?

**Scope of the suppression (verified by reading, not by report):** `r100_fpslat.gd:754`
emits `beq` only when `not name.ends_with("@gp") and "@" in name and env.is_empty()`, and
`_cell_text:734` emits `sha` only for non-env cells. So exactly **3 of 142 cells**
(`noquit_unbound@gp/@jolt/@dummy`) lose stream identity. The other 139 keep their full
receipts; 137 of the 142 pin a literal sha (the 5 sha-less cells are the 3 unbound + the 2
inert-flag cells, which pin `inert`/`argz`/`userz` witnesses instead), and 35 cells carry
`beq`.

**The suppression removed a flake, not signal** — evidence:
* the author's pre-fix derives show `noquit_unbound@jolt/@dummy{…,beq=0}` while the fix
  targets a *racy* comparison; the post-fix derives are the current pins (I diffed all four
  life derive lines: the only token deltas are the two dropped `,beq=0` suffixes);
* my own run's unbound child logs differ in length per backend (6031 / 6123 / 6192 bytes) —
  the full-stream hash is genuinely load-dependent.

**But the residual blind spot is real, and I demonstrated it**:
* `mut-envblind2` — line-count-neutral content change *inside* the unbound stream
  (`LF_TICK n_e=%d pf=%d` → `… injected=1`), envelope fields untouched →
  `runs-mutenvblind2/20261016T100556003125Z` **row PASS**. A stream change of any size that
  preserves `rc=137,boot=1,tickge1=1` is invisible to this row.
* The reviewer's §4 calls this "the declared contract for racy/unpinned surfaces, not a
  defect". I agree it is declared — but it is not free: **a deterministic projection exists
  and is already proven by the author's own logs.** The first 8 `LF_TICK` rows are
  `n_e=1..8, pf=1..8` in **every** rep and **every** backend (4 reps × 3 backends in
  `corpus/live/r100-author/derive-scratch/`).
* Demo (`mut-prefix` vs `mut-prefix-clean`, a 16-line prefix digest added to
  `_env_fields("unbound")`, nothing else):

```
clean   : noquit_unbound@gp/@jolt/@dummy{rc=137,boot=1,tickge1=1,pre=36975b339c7f24f9}   ← identical ×3 backends
injected: noquit_unbound@gp/@jolt/@dummy{rc=137,boot=1,tickge1=1,pre=6efb1ed6eaab7b92}   ← differs, caught
```

(Both patched rows FAIL against the unmutated pin because the receipt gains a field; the
demo's claim is the `pre=` comparison, not a green run.)

**Classification**: T1 — a declared tradeoff with a measured, cheap tightening, not a
defect. The judge's call: either accept the envelope as-is, or add a bounded prefix
assertion (+ a `beq` on it, which becomes meaningful for the first time in the unbound arm).
Honest bound: a prefix digest covers the head only; the load-dependent tail stays unpinned
by design. Note the deterministic full-stream version of this arm is *not* uncovered — the
bound twin `noquit_bound` (all three backends) pins a full sha with `beq=1`.

---

## 5. Mutation matrix (10 distinct mutations, 13 probe runs, all on archived copies)

| # | mutation (one change per tree) | expected | observed |
|---|---|---|---|
| 1 | `mut-pin`: sched pin `n_pr=120`→`121` (first cell) | FAIL | **FAIL** — live receipt unchanged (0 token diffs vs the unmutated pin), the mutated expectation is what rejects it |
| 2 | `mut-joltbody`: `jolt60` body += `physics_jitter_fix=0.0` | FAIL | **FAIL** — `ffps60@jolt` sha `cf0da079…`→`0e371732…`, `beq 1→0` (2 token diffs) |
| 3 | `mut-leak`: inject `WARNING: 3 ObjectDB instances were leaked at exit` into cls | FAIL (fail-closed) | **FAIL** — 9 cells `ue=WARNING: 3 ObjectDB instances were leaked at exit`; sha tokens *unchanged* (line excluded from hash) |
| 4 | `mut-inert`: `ffpseq60` eargs equals-form → consumed form | FAIL | **FAIL** — `{rc=0,inert=0,b_argz=2,b_userz=1}` vs pinned `inert=1,b_argz=3`; sibling `afterdashes` and the `ffps60` anchor unchanged (isolated) |
| 5 | `mut-wmoff`: writemovie `e:["wm"]` → `e:[]` | FAIL | **FAIL** — `writemovie{rc=134,sha=b9714c5288797397,…}` + ERROR head → `ue` |
| 6 | `mut-nodone` ×2: writemovie `done` truncation removed | FAIL + unstable | **FAIL ×2** — sha `7b58fe500462b89c` vs `f20fc0b0100b0f36` (≠ each other, ≠ pinned `aa2728fd…`) → the ASLR backtrace is nondeterministic, so the truncation is **load-bearing, not cosmetic** |
| 7 | `mut-envblind2`: content injection in the unbound stream | (attack) | **PASS → blind spot** (§4) |
| 8 | `mut-prefix2` / `mut-prefix-clean`: prefix digest, injected vs clean | digest differs | `pre` `6efb1ed6…` vs `36975b33…`; clean `pre` identical ×3 backends (§4) |
| 9 | `mut-append`: comment appended at probe EOF | PASS (control) | **PASS** → isolates F2 to line shifts |
| 10 | `mut-bound3`: unbound `bound` 5→3 | PASS + margin | **PASS**, 9.60 s (§2) |

Also 14 single-row executions across the 13 mutation trees (13 listed above, plus the
confounded `mut-envblind` of §3). Accounting: **7/7 expected-FAIL probes failed for the
authored reason** (probes 1–6, with 6 run twice); **3/3 probes expected to pass did pass**
(7 = the blind-spot demonstration itself, 9 and 10 = controls); the two digest-demo runs (8)
failed only because the receipt gains a `pre=` field — their claim is the cross-tree `pre=`
comparison, not a green run. No drift in any unmutated cell of any mutation tree.

---

## 6. Dead-entry inventory (all verified by grep/log counts)

| surface | shape | disposition |
|---|---|---|
| `{"m": m, "raw": raw, "sha": …, "w": w, "ee": ee, "ue": ue}` (line 628) | `"m"` and `"w"` keys are **written, never read** anywhere in the driver | the r99 adjudicator's fold-queue #2 already queued this (`_scan_lines` write-only `w` + `"m"`/`"w"` keys, −2 lines); still open in `r99_animtree.gd` **and now duplicated** into the new driver → two copies of the same fold debt |
| `ERR_ALLOW["leak"]` + `_allowed` `head == "leak"` skip (579) + `allow.has("leak")` branch (616) | **dead path**: no cell in any of the 8 rows arms `leak`, so `ee` can never count a leak; a leak line always lands in `ue` (proved by probe 3) | fail-closed, harmless; the author report §3 lists `leak` among the *counted* expected-error classes — inaccurate (it is a documented **failure** class) |
| `_id_re = "#-?[0-9]+"` mask | **unexercised**: 0 hits across all 142 cells' child logs in my run | harmless guard; the header's "runtime object ids `#-<digits>`→`#N`" normalization is untested by these rows |
| `inert60` predicate (689–698) | hard-codes the pinned-60 triple (`n_ph==120 and n_pr==120 and fpt==[0:1,1:119]`) that is *also* pinned literally in `run_battery.py` | **second authority** for one triple, in a different file: if the triple ever changes, the trap cell degrades to a silent pass (`inert=1` = "not the old triple"). One-sided by design (a two-sided `eq` against the anchor is structurally vacuous — the equals-form's argv witness always differs) |
| `beq` (35) / `eq` (15) fields | **derived**: all 35 `beq` values are implied by the literal sha pins (checked programmatically against the `@gp` reference; 0 exceptions); all 15 `eq` values likewise by inspection | not a defect, but they add **no discriminating power** — the row's pass/fail is carried by the literal shas/fields. Read "beq=1 122/122 backends" as a *derived* identity, not an independent assertion |
| `_cell_ok` (761–770) | validates `err`/`ue`/`rc`/`mark` only | the **parent's** `PASS` does not validate the receipt; only the battery's exact-line match does. The author's derive logs are parent-level receipts, so their `PASS` is weaker evidence than the battery's |

---

## 7. Flake-class honesty review (arerr / wm / lerr / lfin / jolt / leak)

* **Correctly scoped, kept in-hash and counted**: `arerr` (the failed `body_shape_entered`
  RID→Object call — a real probe signature defect, classified not hidden, `ee=1` per
  non-Dummy area receipt), `wm` (crash head, `ee=1`), `lerr`, `lfin` (both `ee=1`, rc=0
  blindness preserved). Probe 5 proves `wm` is load-bearing; probe 4 proves the trap
  envelopes are two-sided in practice (`argz` *and* the counter predicate move together).
* **`jolt`**: the pair is *dropped* (not hashed) and position-tolerant, count `w` computed
  but **never emitted** → the tolerance is unbounded and unobservable in the receipt. This
  is what makes the pins stable (boundary: 38–92 % occurrence), so it is the right call;
  only the dead `w` channel is noted.
* **`leak`**: declared but unarmed → always fatal (`ue`). Honest fail-closed behaviour,
  wrong label in §3.
* **Unknown `WARNING:` lines are hashed silently** (neither allowlisted nor flagged). This
  is *load-bearing*: the `renderthread` cell's `eq=0` exists because
  `WARNING: The separate rendering thread feature is experimental…` is hashed (my runB logs:
  1 Jolt pair + 1 renderthread warning + 0 leak lines). Undocumented policy → smallest
  correction is one header line declaring it; adding a failing `uw` channel would break the
  `renderthread` cell unless that warning is allowlisted for it.
* `_allowed` uses `line == head or line.begins_with(head)` → a *tail* change after an
  allowlisted head is tolerated; a change *inside* the head is not. Acceptable.
* The writemovie `done` truncation and the Jolt drop are both **proved necessary** here
  (probes 6 and the boundary's rate measurement) — normalizations, not content changes.

---

## 8. Impacted axes (proposed names; the canonical judge owns the axis set)

* **receipt-nonvacuity** — 7/7 expected detections; pins are exact-receipt, not prefix.
  No regression found.
* **loadmargin** — the only axis with a *measured regression*: life 15.5–15.7 s / 20 s by
  construction (§2). One-constant fix verified at 9.60 s.
* **selfcontainment** — `8183191` fails it (0/8 pristine); `523c943` restores it (8/8 on the
  same bytes I archived). No residual risk on the tip.
* **claimhonesty** — the env envelope is declared but under-asserts; `leak` is mislabelled
  as counted; `beq`/`eq` read as stronger than they are; the line-coupling is undisclosed.
* **folddebt** — the r99 fold-queue #2 item is still open and now duplicated into a second
  driver (§6).

---

## 9. Smallest safe corrections (for the owner/judge; this seat does not edit)

1. **F1 (defect, measured)**: `r100_fpslat.gd:521` `d["bound"] = 5` → `3`. Keeps all pins;
   life 15.6 s → 9.6 s; row green; envelope intact.
2. **F2 (defect, protocol)**: record the probe-line-number coupling in the driver header +
   author report (r99 SP-5 disposition: *record, never edit probe lines without
   re-deriving*). Do not mask line numbers.
3. **F3 (fold debt)**: apply the r99 fold-queue #2 item to **both** drivers (`"m"`/`"w"`
   keys, dead `leak` path) in one deliberate diff — or, if the leak class is meant to be
   usable, arm it on a cell that documents a leak (today `ee` can never count one).
4. **F4 (documentation)**: §3's `leak` class is a failure class, not a counted one; declare
   the unknown-WARNING policy; note that `beq`/`eq` are derived fields; note that `_id_re`
   is unexercised by these 142 cells.
5. **T1 (judge's call, optional)**: give the unbound envelope a bounded deterministic
   projection (16-line prefix digest, or the first `LF_TICK` row) + a cross-backend `beq` on
   it — measured identical ×3 backends / ≥6 reps; the injection that today passes would be
   caught. Re-derives 3 pins.
6. **T2/T3 (judge's call, no change)**: `beq`/`eq` as derived fields and the silent-hashed
   unknown-warning policy are acceptable as-is if declared.

No counterexample was found to: the 8 rows' receipts on the final bytes, the 142-cell
count, the provenance chain, the named-class scoping, the writemovie/Jolt normalizations,
or the fixed-fps interleave/trajectory laws as pinned.

---

## 10. Receipts

Archive root `/home/vgpnk/critic-r100-archive/`:
`runs-committedonly/20261016T100241964960Z` (0/8 pristine), `runs-probes/20261016T100249134903Z`
(8/8), `runs-runB2/20261016T100718212385Z` (8/8), `runs-mutpin/20261016T100456254662Z`,
`runs-mutjolt/20261016T100501591493Z`, `runs-mutleak/20261016T100501591246Z`,
`runs-mutinert/20261016T100621514198Z`, `runs-mutwmoff/20261016T100621514788Z`,
`runs-mutnodone1/20261016T100621513997Z`, `runs-mutnodone2/20261016T100621514158Z`,
`runs-mutenvblind2/20261016T100556003125Z`, `runs-mutprefix2/20261016T100556003525Z`,
`runs-mutprefixclean/20261016T100556001834Z`, `runs-mutappend/20261016T100704812942Z`,
`runs-mutbound3/20261016T100747725720Z` (PASS, 9.595 s; the sibling stamp
`…T100737581459Z` is this seat's own killed first attempt — scratch only, no verdicts.json,
not a landing artifact), plus `log-*.txt` per tree and
`runs-mutenvblind/20261016T100501591114Z` (the confounded line-adding probe, §3).

This report is filed uncommitted (`reports/round-100/r100-critic.md`); no repo file was
edited, staged, or committed by this seat. Admission belongs to the canonical judge.
