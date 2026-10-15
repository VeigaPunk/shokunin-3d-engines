# r90 critic — adversarial review of the repaired BIMODAL envelope (6420dc7)

Seat: critic. Attack surface: the repaired `BIMODAL`/`mode_ok` envelope in
`corpus/fixtures/phys3d_joints.gd` + the 20 repinned cells in
`run_battery.py`. All forges ran live against the committed fixture
(`corpus/live/r90-critic/forge/`, uncommitted): the parent is copied
verbatim; only `r90_child.gd` is mutated. Godot 4.7.2.stable.arch_linux,
`--headless`, same spawn path as the battery. Working tree carries a
sibling lane's in-flight round-96 bpy edits (`run_battery.py` +30,
comment-only `phys3d_joints.gd` touch-up); the reviewed logic is
byte-identical to 6420dc7.

Evidence inventory: `forge/base/` (baseline byte-exact pin reproduction),
`forge/f1_replay/`, `f1b_overrun/`, `f1c_garbagetail/`, `f2_mutant/`,
`f3_earlycrash/`, `f5_jointonly.gd`+`f5_proj/`, `f4_hunt/hunt.csv` (800
committed-child reps), plus `corpus/live/r90-repair/mx*` (504-run matrix)
and mx child-log forensics.

## Findings

### 1. [HIGH] Clean-mode admission binds only the prefix — tail content is unmeasured on the 4 cells with `n_pre < full_msz`

Cells `freeb_ops@gp`/`freeb_ops@jolt` [6,8], `freeb_dyn@gp` [8,11],
`chain3_freemid@gp` [2,3]: clean admission is `rc==0 && sig11==0 &&
msz==full_msz` — a **count** check; the sha covers only the first `n_pre`
lines. Lines `n_pre+1 .. full_msz` are content-free.

**Counterexample (live):** `f1c_garbagetail/r90_child.gd` prints the two
bound `chain3_freemid` lines, then `M chain3_freemid TAIL_IS_FORGED
not_done=1` — **no `M DONE` at all** — and `quit(0)`. Emission:
`chain3_freemid@gp{mode_ok=1,m2=c1b063fbc58a5718}` — byte-identical to the
committed pin. The same forge on `@jolt` ([3,3]) was caught — the hole is
exactly the 4 prefix-bound cells. The sharpest instance is
`freeb_dyn@gp` [8,11]: the unbound tail is `t=7`/`t=8`/`DONE` — the
post-free body-state witness lines that are the case's payload — and a
clean `freeb_dyn@gp` has **never been observed** (52/52 crash across
mx+hunt), so the envelope asserts a stream whose tail content no run has
ever produced. Dispatch question (a) answered: yes — on prefix cells a
child can emit the bound prefix plus *arbitrary* tail and exit 0.

**Axes:** binding-strength / hidden-regression surface.

### 2. [HIGH] Crash admission is mechanism-blind and has no stream upper bound

Crash arm: `sig11==1 && rc∈{134,137,139} && msz>=n_pre`. Two holes:

- **Overrun admitted.** `f1b_overrun` emits the bound prefix + 6 junk
  M-lines + fake marker + `quit(134)` → msz=8 (full=3) →
  `chain3_freemid@gp{mode_ok=1,m2=c1b063fbc58a5718}` — byte-identical PASS.
  Any duplicated-/extra-emission regression (e.g., a second Watcher)
  survives under crash mode on all 20 cells. Honest streams can never
  exceed `full_msz` (emission is deterministic-modulo-truncation), so the
  missing `msz <= full_msz` bound admits only non-honest realizations.
- **Crash site/RID/cause unchecked.** `f2_mutant` (see F4) still crashed
  post-DONE — at `free_rid(joint)`, freeing a joint whose endpoint body
  was already freed — a *different* UAF than the modeled re-free, on a
  *different* RID; admitted `mode_ok=1`. Any SIGSEGV past the prefix —
  including one from an unrelated regression — is indistinguishable from
  the named mechanism. Dispatch question (c) answered: yes.

**Axes:** admission-soundness, mechanism-fidelity.

### 3. [HIGH] The "crash evidence" channel is fully child-producible

`sig11` counts the substring `handle_crash: Program crashed with signal
11` in a log the child itself writes; `rc` is whatever `quit(N)` chooses.
`f1_replay/r90_child.gd` prints canned M-lines + the literal marker +
`quit(134)` — zero physics, zero crash — and the **entire `chain3` row
emits byte-identical to the committed pin**
(`PASS … m2=c1b063f… m3=544e2f… dummy{rc=0,…}` verified against
`run_battery.py`). A hang works too (marker + never quit → timeout →
rc=137 ∈ set). This channel existed pre-repair (`rcc=sig`/`sig11=1` rode
the same signals), so it is not repair-new — but the repair doc's
"crash requires sig11=1 + exit 134/137/139" reads as crash provenance and
it is only text+exit-code provenance; it also *lowers* forge cost to
`n_pre` canned lines + 2 prints. The verifier's own §5 "crash-cell
honesty" check verified real crashes by reading child.logs — a manual
step the admission rule does not encode.

**Axes:** anti-forge/honesty, evidence-provenance.

### 4. [MED] `e`/`w` dropped on all 20 cells — child-side ERROR/WARNING deltas invisible

Repair dropped e/w as "mode-dependent". `f2_mutant` injects 4 forged
`ERROR:` lines on `freeb_ops`/`freeb_twice` non-Dummy backends:
`freeb_twice@jolt` child.log carried **e=5** (4 forged + 1 genuine
`Invalid ID`) → full `free_ops` PASS line **byte-identical to the pin**
(verified). Pre-repair these were pinned per-mode (e.g., freeb_twice
clean e=2 / crash e=1). Any child-side error-storm or warning regression
on the 20 exposed cells is now silent. mx+hunt show e/w stable per mode
(clean e=2, crash e=1 for that cell) — a per-mode bound was feasible.

**Axes:** hidden-regression surface, observability.

### 5. [MED→LOW after replication] Residual REJECT-class flake: the `n_pre` floor is empirical, not mechanism-derived

Any honest crash with `msz < n_pre` fails both arms → `mode_ok=0` → row
closes — the same "legal realization fails pin" class that got r90
rejected. Reachability is mechanism-backed: `freeb_dyn@gp` dies in
`wit()`'s `st(b_rid)` at msz=8 (52/52) — the *same* freed-RID read that
`freeb@gp`/`freea@gp` perform at t7/t8 yet have never crashed mid-window
(0/52); `chain3_freemid@jolt` is modeled post-DONE-only ([3,3]) while its
mid-ops window (solver walking the freed middle body t21–30) is
mechanically present and unrealized in 52 reps. Boundary demonstrated
live: `f3_earlycrash` emits the byte-exact msz=2 crash realization on
`@jolt` → `mode_ok=0` → row would FAIL.

**Empirical counterweight (must report):** my `f4_hunt` ran **800
committed-child reps under 16-way parallel load** across every exposed
tag — **zero out-of-envelope realizations**; every crash landed at
exactly its modeled msz (6/8/11/4/2). On this engine+heap the crash sites
are mechanism-bound, not heap-random. The flake residual lives at engine
builds/heap layouts where the crash depth shifts — precisely where a pin
battery has the least prior evidence.

**Axes:** determinism/flake-resistance (the original REJECT axis).

### 6. [MED] The mechanism model is incomplete — and the verifier's suggested escape hatch does not close the window

`r90-repair.md` models: teardown re-frees the case's freed RID → UAF.
`f5_jointonly.gd` skips *every* teardown free except `free_rid(joint)` →
**8/8 SIGSEGV at the joint free** (frame `on_e:209`), i.e., freeing a
joint that references a dead body is itself a UAF, independent of the
re-free. Consequence: the verifier's repair option 2 ("track freed RIDs,
skip them in teardown") — implemented verbatim in `f2_mutant` — does
**not** eliminate the teardown crash (still crashed, still admitted).
The actual deterministic fix is stronger and smaller: the teardown loop
is gratuitous (process exits a frame later and reaps RIDs) — `quit(0)`
immediately after `M DONE` removes the entire class and returns all 20
cells to single-mode full-stream pins, no envelope required. Cost: loses
an accidental measurement that was never a deliberate probe.

**Axes:** mechanism-fidelity, fix-correctness.

### 7. [LOW] Vacuous-arm accounting — dispatch question (b)

After mx(504)+hunt(800): crash-arm-never-realized on **10/20** tags
(`freea@jolt`, `freeb_make`@gp/jolt, `freeb_afterclear`@gp/jolt,
`freej_then_b`@gp/jolt, `detachb_free`@gp/jolt, `chain3_freemid@jolt`);
clean-arm-never-realized on **5/20** (`chain3_freemid@gp`,
`freeb_dyn`@gp/jolt, `freeb@jolt`, `freeb_twice@jolt` — and
`freeb_ops@jolt` in mx+hunt, though a clean was recorded pre-repair).
Anticipatory arms are honest coverage *if* the mechanism is reachable —
the repair doc's "mechanism present on all 20" claim is right. No
deterministic tag is wrongly enveloped: `freeb_world`/`detachb`/`twopin_*`
free nothing; `sweep`/`rid`/`api` quit in `_initialize` before the
teardown loop; Dummy's inert `free_rid` correctly stays hard-pinned. My
hunt corroborated the in-flight comment correction: `freeb@gp`'s crash
arm is real (3/40 realized post-DONE) — the "10th tag" wording now in the
working tree is accurate.

**Axes:** evidence-completeness (minor).

### 8. [LOW] Observability: `mode_ok` hides which mode realized

A cell flipping always-clean ↔ always-crash emits identical tokens; the
only forensic trail is per-run child.logs. Inherent to a byte-stable pin;
a parent-written realized-mode sidecar would restore it without touching
the digest. Also flagged: the in-flight `ptr_stale@bpy{mode_ok=1,m3=…,rc=139}`
token suggests the idiom is propagating to r96 with *different* shape
(rc inside the braces = crash-mode-only pinned — worth a scribe pass for
consistency).

## What held up

- 800/800 committed-child realizations admitted under load; all
  byte-stable emissions matched pins where checked; no honest
  realization fell outside the envelope on this host.
- Prefix-sha is collision-sound in the intended sense — no mutated set
  collides *unless it keeps the first n_pre lines*; the hole is coverage,
  not hashing.
- Non-exposed cells untouched; Dummy hard-pinned; prior-217 rows
  byte-identical (verifier PASS, unrebutted).

## Smallest safe corrections (ascending cost)

1. `crash := sig11==1 and rc in {134,137,139} and n_pre <= msz <=
   full_msz` — closes overrun (F2-hole) at zero cost; honest streams
   never exceed `full_msz`.
2. Per-mode `e`/`w` admission bounds in `BIMODAL` (e.g.
   `[n_pre, full, e_clean, e_crash, w_clean, w_crash]`) — unemitted
   predicates, byte-stable tokens preserved.
3. **Principled admission:** embed the expected M-stream per tag; admit
   clean iff `m == expected`, crash iff `sig11 && rc∈set && m` is an
   exact *prefix* of `expected` (msz>=1). Binds every emitted line,
   admits every truncation depth, kills F1/F2/F5 residuals. Emit
   `tag{mode_ok=1,et=<sha16 of expected table>}` — byte-stable.
4. **Or the deterministic route:** delete the teardown free loop (F6 —
   `quit(0)` post-DONE); 20 cells become single-mode full pins, the whole
   envelope evaporates. Track-and-skip does *not* suffice (F5 proof).
5. If forge-evidence matters: redirect `timeout`'s own stderr to a
   sibling `timeout.log` and require `dumped core` there — print/exit
   forges stop working (a deliberate sibling-file write is outside the
   regression/laziness threat model; document residual).

## Seat verdict (advisory)

The repair fixed the reported flake and is empirically sound on this host
(800/800), but the envelope admits a wider set than the named mechanism:
unbound tails on prefix cells (F1c), overrun + site-blind crash
admission (F1b, F2/F5), forgeable crash provenance (F1), and silent
error surfaces (F2). These are fixable defects, not fundamental
tradeoffs — corrections 1+2 are one-line/table changes; 3 or 4
structurally closes the class. Reported; not judged.
