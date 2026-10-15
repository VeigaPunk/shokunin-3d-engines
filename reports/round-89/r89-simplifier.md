# game-dev-3d round 89 — simplifier (seat: simplifier, host: devin) — the r89 insertion's own weight: 5 dead writers, 18 dispatch entries, 1 doc over-claim; the spawn-triple question answered with numbers

Round 89, lane `game-dev-3d-shokunin`, wave `shokunin-train-20261101-w20`. Assignment
(verbatim in substance):

> Lane: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin. Dirty:
> phys3d_events.gd +2254 (7 arms + helpers + S3 guard), run_battery.py +24,
> README +118. Hunt YAGNI: duplicated child-spawn boilerplate across the 7 arms
> (iw/cx/js/sl dispatchers share shape — extractable?), dead helper variants,
> contradictory comments.
>
> PROOF: vfold in scratch under corpus/live/r89-simplifier/ — run affected arms
> (or 217-cell battery if feasible), PASS + byte-identical tuples vs dirty rep.
> Doc folds exempt.
>
> DELIVERABLE: reports/round-89/r89-simplifier.md — folds+receipts or 'no safe
> folds'. READ-ONLY tracked. Do NOT commit.

Environment (same host as the other r89 seats): `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, kernel `7.2.3-arch1-3`,
Python 3.14.7, 32 threads, HEAD `0c28c2afb7bc7e890734d5050561d95821bc3bd0`
(`r88 LOG: ADMIT-corr`).

**No tracked file was edited, nothing was committed.** The three dirty files carry
the same sha256 before and after every run in this lane (re-checked at filing, §8):

| file | sha256 (pre == post) |
|---|---|
| `corpus/fixtures/phys3d_events.gd` | `483f96829b043bb685d55def43b43474e4bb4d1c9dd2ff039674b802ce216937` |
| `corpus/fixtures/run_battery.py` | `c720f90ac1f89eb769f20ee143534c1273d88f92d4ac23a6c680e599ee1a230a` |
| `corpus/fixtures/README.md` | `189908a0e65f73c22570abf5d1235395d0dad6b371b2b00acfa1e91b965fa265` |

**`lsp` unavailability recorded** (seat-card rule): `mcp_list_servers` exposes only
`rea` — no `lsp` device in this seat's toolset, so no `references` / `definition` /
`diagnostics` query was possible. The call-site audit below is **literal inspection
(grep), explicitly not semantic proof**, and it is corroborated by execution: every
deletion candidate was deleted in a scratch copy and the whole 217-row battery was
re-run against that copy. (Every deletion candidate here is a *write-only* variable —
the strongest literal form of "no reader": its name occurs exactly twice in the
repository, once as the declaration and once as the write, with no other file
referencing it.)

**Receipts**: `corpus/live/r89-simplifier/` — `dirtyrep/` (pristine copy of the dirty
fixtures), `vfold/` (P1+P2+P3 applied), `vfold4/` (P1+P2+P3+P4), the run dirs
`runs-dirty-only/`, `runs-vfold-only/`, `runs-vfold-full/`, `runs-vfold4-14/`,
`runs-vfold4-full{,2,3}/`, `runs-fm10-{vfold,dirty}-*/`, `runs-fmrep-*`,
`runs-{vfold,dirty}-fmctl/`; the patches `p1p2.patch`, `p3-readme.patch`, `p4.patch`;
the scripts `fold.py`, `fold4.py`, `analyze_spawns.py`, `compare_vfold.py`; and the logs
`dirty-only.log`, `vfold-only.log`, `vfold-full.log`, `vfold4-full{,2,3}.log`,
`bogus-probe.log`, `fm-10x.log`, `fm-reps.log`.

---

## 0. Verdict

| # | fold | weight | proof | call |
|---|---|---|---|---|
| **P1** | 5 write-only r89 class vars + their single writes (`ip_e`, `ip_f`, `iw_ball`, `sl_cell`, `sl_slept`) | **−10 lines** | full 217-cell battery on the folded scratch | **take** |
| **P2** | the 18 literal child-dispatch entries for the 6 r89 matrix arms → 6 grouped-label branches | **−24 lines** | same battery | **take** |
| **P3** | README `if_write` bullet: drop `apply_impulse` / `apply_force`, which the arm never measures | doc | doc-exempt; claim checked against the arm's own `IW_MEMBERS` + every pinned `iw_*` key | **take** |
| **P4** | `_spawn_triple` for the 14 arms that spawn the shape-uniform plain/jolt/dummy triple (8 prior + 6 r89) | **−136 lines** | the 14 affected rows, 12-field byte-identical to both the dirty rep and the P1+P2+P3 rep, on a third scratch (`vfold4`); full-battery re-run in §5 | **L1's scope call** (rewrites 8 prior-round arms; the card says don't widen scope — the patch and its receipt are here either way) |

P1+P2+P3: `phys3d_events.gd` 7097 → 7063 (−34), README 2 lines changed.
P1+P2+P3+P4: 7097 → 6927 (−170, −2.4 %).

The patches apply with `patch -p1` from `corpus/fixtures/` (dry-run verified):
`p1p2.patch` + `p3-readme.patch` against the dirty hashes above, then `p4.patch`
against the P1+P2+P3 result if the L1 takes it.

The lane's headline question — *"duplicated child-spawn boilerplate across the 7 arms
… extractable?"* — is answered in §5 with a measured census: **6 of the 7 arms spawn a
triple, that triple's shape is shared with 8 prior arms (14 arms in one shape-uniform
family, with three argument-tail variants), and the 6-arm-only extraction is
inadmissible** (it would open the second spawn path the r88 `_spawn_batch` comment
explicitly forbids); the 14-arm fold is mechanical, offered as P4, and proven on its 14
affected rows.

---

## 1. The evidence chain

**(a) Reference rep.** The dirty-tree reference is the r89-verifier's rep 2
(`corpus/live/r89-verify/runs/20261015T072205389618Z/verdicts.json`, 217/217,
`seeds_unchanged=true`) — a rep of the *same* three dirty hashes, produced by an
independent seat. Re-verified: those hashes are the hashes on disk now (§8).

**(b) Cross-session link.** My own dirty `--only` run of the 7 r89 rows
(`runs-dirty-only/20261015T080313585601Z`, 7/7 PASS) is **12-field byte-identical** to
that rep's 7 rows (0 mismatches over `case, script, flags, expected_exit, actual_exit,
error, kind, marker, verdict, reasons, stdout, stderr`) — the reference is rep-stable
across sessions, so a fold-vs-reference comparison is not confounded by host drift.

**(c) Affected rows, side by side.** `vfold` `--only` run
(`runs-vfold-only/20261015T080341827535Z`, 7/7 PASS) vs the dirty `--only` run:
`verify_tuples.py rep` (the r89-verifier's own comparator) → **0 12-field mismatches,
0 stdout/stderr/marker/exit byte-diff rows**. (That script prints `RESULT FAIL` only
because it also requires `seed_digests` equality — the seed digests *must* differ here:
the seed files are the fold. Its own output line is
`12-field mismatches: 0` / `stdout/stderr/marker/exit byte-diff rows: 0`.)

**(d) Whole battery, folded.** `runs-vfold-full/20261015T080432332055Z`: **217/217
PASS**, ordinary 171 / negative 46, `seeds_unchanged=true`, battery exit 0.
`compare_vfold.py` against the reference rep:

```
12-field mismatches (all 217 rows): 0
stdout/stderr byte-diff rows: 0 []
prior-210 index-identity (7-tuple): 210/210
seed files differing (the fold fingerprint): 2
   README.md:          dirty=189908a0e65f73c2 folded=f88a81c92e239e5b
   phys3d_events.gd:   dirty=483f96829b043bb6 folded=9d8bea033433ed0c
RESULT PASS
```

`run_battery.py` is **not** in the differing set — P1–P4 do not touch it.

**(e) The 14 P4-affected rows.** `runs-vfold4-14/20261015T082051914121Z`: **14/14 PASS**, and all 14 are **12-field byte-identical to both** the dirty rep and the `vfold` (P1+P2+P3) rep — 0 mismatches on either comparison, i.e. P4 moves nothing the 14 rewritten arms report. The rows: `backend_tier`, `body_handle`, `body_tier`, `freed_space`, `motion_split`, `param_purity`, `body_inertia`, `wrong_args`, `if_phase`, `if_write`, `joint_pin`, `joint_param`, `joint_solver`, `cross_space`. A full-battery re-run of `vfold4` is reported in §5.

---

## 2. P1 — five write-only class variables (−10 lines)

Every one of these was introduced by the r89 insertion and is written exactly once and
never read. Occurrence counts are over the whole repository (`.gd`, `.py`, `.md`,
`.mjs`), excluding `corpus/live/`:

| var | declaration (dirty line) | the single write (dirty line) | readers |
|---|---|---|---|
| `ip_e` | 5951 `var ip_e := 0` | 6665 `ip_e += 1` in `on_e()` | none |
| `ip_f` | 5952 `var ip_f := 0` | 6674 `ip_f += 1` in `on_f()` | none |
| `iw_ball` | 5960 `var iw_ball: IFRB = null` | 6100 `iw_ball = ball` | none (`iw_ball_rid` is the used handle; the node is kept alive by `owned_nodes`) |
| `sl_cell` | 5962 `var sl_cell := ""` | 6487 `sl_cell = cell` | none (the local `cell` drives the `match`) |
| `sl_slept` | 5966 `var sl_slept := -1` | 6520 `sl_slept = slept` | none (`slept` is a local and is what every emit reads) |

`ip_e`/`ip_f` are additionally redundant with state the arm already reports: the call
counts are the row arrays' sizes (`_note(... "if_rows=%d e_rows=%d f_rows=%d" ...)`,
and the emits use `ip_if`). Deleting the two increments changes no value the arm reads.

Deletion = 5 declarations + 5 writes, `p1p2.patch` hunks `@@ -5948` / `@@ -5957` /
`@@ -6097` / `@@ -6484` / `@@ -6517` / `@@ -6662` / `@@ -6671`.

**Proof**: the folded scratch re-ran all 217 rows with these identifiers gone
(§1d) — the 7 r89 rows are byte-identical, and the three arms that touch them
(`if_phase`, `if_write`, `sleep_state`) pass 3/3 focused reps and the battery.

---

## 3. P2 — 18 dispatch entries → 6 grouped branches (−24 lines)

`_run()`'s child dispatch carried, for each of the six r89 matrix arms, three
two-line literal entries whose only difference is the backend suffix:

```gdscript
			"ip_plain":
				await _child_if_phase("ip_plain")
			"ip_jolt":
				await _child_if_phase("ip_jolt")
			"ip_dummy":
				await _child_if_phase("ip_dummy")
```

36 lines → 12, one branch per matrix, the argument read once:

```gdscript
			"ip_plain", "ip_jolt", "ip_dummy":
				await _child_if_phase(arm_any)
```

Why this is behavior-identical *by construction*, not just by measurement:

- `arm_any := _argval("--arm=", "")` is the value the enclosing
  `match _argval("--arm=", "")` matched on; `_argval` is a pure scan of
  `OS.get_cmdline_user_args()` (first `--arm=` wins), so inside the branch it returns
  exactly the matched name — including the pathological double-`--arm=` case.
- **Totality is preserved exactly.** Only the three exact names match; `ip_bogus`
  still falls through to the `var bad:` refusal (`CHILD_RESULT child_arm=unknown`,
  rc 2) that the r84-critic comment above the table demands. This is why the
  *other* available shape — extending the `fm_`/`sl_` prefix dispatch — was
  **rejected**: it would re-open the totality hazard for six more prefixes (§7, D1).
- The six grouped labels sit inside the same literal table, in the same order, with
  the same targets; the table's closed set is unchanged.

**Proof**: the affected six rows (`if_phase`, `joint_pin`, `joint_param`, `if_write`,
`cross_space`, `joint_solver`) plus `sleep_state` are byte-identical (§1c), and the
full battery passes with the folded table (§1d). The dispatch table is exercised by
every child-spawning `phys3d_events` row, not only the r89 ones — the fold touches a
shared path, and the whole battery re-proves it.

---

## 4. P3 — the README's `if_write` member list (doc fold)

The r89 README section says, of `if_write`:

> Immediate: `set_linear_velocity`, `set_angular_velocity`, `set_transform`,
> `apply_central_impulse` / `apply_impulse` / `apply_torque_impulse`. **Deferred one
> step**: `apply_central_force` / `apply_force` / `apply_torque` …

The arm measures **12 members** (`IW_MEMBERS`): `baseline`, `linvel`, `angvel`,
`xform`, `cimpulse`, `timpulse`, `cforce`, `torque`, `setcforce`, `sleep`,
`reentrant`, `detach` — and the child's writer (`_iw_write`) calls
`apply_central_impulse`, `apply_torque_impulse`, `apply_central_force`, `apply_torque`
only. There is no `apply_impulse` and no `apply_force` member anywhere in the arm: the
expect dicts contain `iw_*_cimpulse_*`, `iw_*_timpulse_*`, `iw_*_cforce_*`,
`iw_*_torque_*`, `iw_*_setcforce_*` and no off-centre variant. The two off-centre names
are an over-claim: they are the family the central writes belong to, not members this
arm measured.

Patch (`p3-readme.patch`, 2 lines): list only the measured members. Doc folds are exempt
from the battery by the assignment (the battery never reads the README); the claim is
instead checked against the arm's own member list and every pinned key, which is what
the battery *does* pin.

The top-of-file arm block and the parent-arm comment use family-level wording
("impulse writes", "force / torque / constant-force writes") and are accurate as
written — not touched.

---

## 5. P4 — the spawn-triple question, with the census

`analyze_spawns.py` walks every parent arm and classifies its `_spawn_child` calls.
Measured:

- **26 parent arms** spawn children; **14 of them** spawn the same *shape*: three
  children per arm, stem-consistent in all three names (`<stem>plainproj` /
  `<Stem>Plain` / `<stem>_plain` and the Jolt/Dummy pair) — **8 prior-round arms**
  (`backend_tier`/`tier`, `body_handle`/`bh`, `body_tier`/`bt`, `freed_space`/`fs`,
  `motion_split`/`mo`, `param_purity`/`pq`, `body_inertia`/`bi`, `wrong_args`/`wa`)
  and **6 r89 arms** (`if_phase`/`ip`, `joint_pin`/`jp`, `joint_param`/`jq`,
  `if_write`/`iw`, `cross_space`/`cx`, `joint_solver`/`js`).
- **The 14 sites are shape-uniform but NOT byte-identical** — this is the correction
  my first two applications earned. Three argument-tail variants exist:
  **7 arms** pass the defaults (`tier`, `bh`, `mo`, `pq`, `bi`, `jp`, `cx`);
  **6 arms** pass `"res://phys3d_events.gd", 30, <stem>_allow`
  (`bt`, `wa`, `ip`, `jq`, `iw`, `js` — their children carry an expected-witness
  allow list); and **1 arm** passes `"res://phys3d_events.gd", CRASH_BOUND_S`
  (`fs` — the crash family's 6 s bound, not 30 s). A generator must therefore take
  `(stem, allow := [], bound := 30)`, and the `fs` call site reads
  `_spawn_triple("fs", [], CRASH_BOUND_S)`.
- The 7th r89 arm (`sleep_state`) is **not** in the family: it spawns 13 children in
  one parallel batch through the r88 `_spawn_batch` — already single-sourced.
- Near-misses a triple helper cannot cover (different children or counts):
  `inactive_space` (plain/thr/joltthr), `acq_use`/`step_stamp`/`race_class`/
  `geom_split` (2 each), `fetch_gate` (5), `dummy_floor` (2), `write_loss`,
  `jolt_edge`, `jolt_threaded`, `dummy_refused`, `threaded_edge` (1 each).

**Why the hint's "across the 7 arms" extraction is inadmissible as stated**: folding
only the 6 r89 arms would leave the other 8 arms inline — i.e. it would *open a second
spawn path for the same job*, which is exactly what the r88 `_spawn_batch` comment
records the lane's norm against ("reuses the SAME single-sourced conventions instead of
opening a second spawn path"). The only shape that removes weight *without* creating a
second convention is the full 14-arm fold, and that rewrites 8 prior-round arms — a
scope decision above this seat, so it is delivered as an opt-in patch with its own
receipt rather than folded unilaterally.

**The patch and how it was earned** (`p4.patch`, 14 call sites + a 20-line generator
placed beside `_spawn_batch`; same calls, same order, same `err` short-circuit, same
arguments — now including the two variant tails). Three applications were measured, and
the two failures are the reason the patch is trustworthy:

| application | battery result | what it proves |
|---|---|---|
| attempt 1 | **41 rows FAIL** — `Parse Error: Expected closing ")"` at one line, all phys3d rows dead | the rewrite had also renamed identifiers **inside string literals** (`"CHILD_NOTE fs_plain held="` in the `fs` arm's `_log_count` tokens). The battery is fail-closed: a fold that breaks the fixture cannot pass. |
| attempt 2 | **214/217** — `body_tier`, `wrong_args`, `freed_space_methods` FAIL | `bt`/`wa` really were missing their allow lists, and `fs` really was spawned with the default 30 s bound; `freed_space_methods` is the pre-existing lottery of §7 D3 (it fails on the untouched tree too). |
| attempt 3 (fixed) | **216/217** — the only failure is `freed_space_methods`, the pre-existing lottery of §7 D3; **all 14 P4 rows and all 7 r89 rows PASS** | the fold moves nothing those arms report. |

The rewrite is scoped to the parent-arm region — the child-dispatch table above it keeps
its own labels (the two namespaces share the `<stem>_<backend>` spelling; the first
version clobbered the dispatch labels, and the region boundary is now explicit in
`fold4.py`).

**Residual risk if P4 is taken** (recorded, not hidden): the generator's `bound`
parameter defaults to 30, so a *future* crash arm that calls `_spawn_triple("xx")`
without passing its crash bound would silently get the 30 s bound. The landed form
states the bound at the one crash call site; a fold commit should keep that explicit.
And P4 rewrites 8 prior-round arms, so its diff is 725 lines of mechanical churn — the
L1 may reasonably prefer the literal per-arm spawns as the fixture's auditable record.
If P4 is declined, nothing else in this report changes.

---

## 6. Candidates examined and **not** folded

| candidate | measured weight | why not |
|---|---|---|
| parent-side triple, r89-only (6 arms) | ~−70 lines | opens a second spawn path for a job 8 other arms do inline (the r88 norm) — see §5. Offered as the 14-arm P4 instead. |
| node-ball construction helper | ~−20 lines (4 r89 sites) | the same inline node-body block appears **15×** in the file (`CollisionShape3D.new()` count): 9 sites in r83–r88 arms (`jolt_edge`, `jolt_threaded`, `dummy_refused`, `gs`, `bh`), 6 in r89's children (4 node balls + 2 static nodes). Folding the r89 sites alone is a second convention; folding all 15 rewrites 5 prior arms — same scope call as P4, smaller win. |
| `_iw_y` / `_iw_z` → one indexed reader | −3 lines | trades two self-documenting names (`_iw_y(s1)`) for a magic index (`_iw_comp(s1, 1)`). Weight down, readability down — not Pareto on the axis that matters for a fixture read by humans. |
| `_phase_pairs_equal` / `_phase_next_equal` → one offset-parameterised helper | −6 lines | these two functions *are* the arm's two laws (`IF(pf=k)==E(pf=k)`, `F(pf=k)==IF(pf=k+1)`); a shared `offset` argument makes each law implicit at the call site. Marginal weight, real clarity cost. |
| `_cx_cls` vs the r88 `_fmt_read` | 0 | two Variant-classifiers coexist, but both emit **pinned** strings: merging would rewrite the measured `cx_*` pins (evidence), not weight. Recorded as an observation only. `_cx_cls` also lacks `_fmt_read`'s `is_instance_valid` guard — its inputs are live direct-space-state handles, and a freed one would raise and fail the row loudly (fail-closed), so this is a narrower contract, not a hazard. |
| `_child_sleep`'s missing `_:` default (a bogus `sl_*` cell exits rc 0 with a partial dict) | +3 lines to fix | a *finding*, not a fold (a fix adds weight). See §7 D1. A typo'd cell in `sl_specs` still fails the row (the parent compares the whole dict against `sl_want[arm]`), so the practical exposure is a hand-run bogus arm. |
| the expect dicts / `sl_want` / pin tables | ~2 000 lines | **not a fold target at any price**: they are the measurement. A generated expectation would let a wrong-but-consistent child pass. |
| `PHASE_GETTERS`, `IW_MEMBERS`, `JP_VARIANTS`, `JP_TYPES`, `JP_TICKS`, `SLEEP_CELLS`, `SLEEP_BOUND`, `IW_WRITE_TICK` | 0 | all read at least once (census in the receipt run); no dead constant in the insertion. |

---

## 7. Findings (the "contradictory comments" hunt)

**D1 — the dispatch-totality comment is now false for two prefixes (finding; repair
costs weight, so it is not a fold).** The r84-critic comment above the child dispatch
says the dispatch "must be total -- a bare or unknown `--arm` used to run the threaded
body silently", and the `var bad:` arm implements that for the literal table. But the
r88 `fm_` prefix dispatch and the r89 `sl_` prefix dispatch do not validate their
suffix. Measured directly against the landed fixture (a scratch copy of
`runs-dirty-only/…/scratch`, `bogus-probe.log`):

| `--child --arm=` | rc | what happened |
|---|---|---|
| `bogus_bare` | 2 | `CHILD_RESULT child_arm=unknown arm='bogus_bare'` — the literal table is total ✓ |
| `sl_bogus` | **0** | ran the whole sleep child and emitted a **partial** map (`sl_bogus_slept=41`, `sl_bogus_if_calls=42`) — no refusal |
| `sl_reads_plain` | 0 | the intended cell works (9 fields) |
| `fm_bogus` | **134** | defaulted the method to `pt` and ran the crash-prone freed-space child; it aborted |

No CASES row uses a bogus name, so no battery row is affected, and a typo'd *spec* still
fails the parent's whole-dict compare (the missing keys never match `sl_want` /
`fm_want`). This is a latent totality gap and a comment that no longer describes the
code below it — the `fm_` form fails *loudly* (rc 134), the `sl_` form fails *silently*
(rc 0 + partial map). The minimal repair (a `_:` refusal in `_child_sleep`, a
membership guard in `_child_freed_method`) *adds* lines; it belongs to the
critic/adjudicator, not to this seat. P2 deliberately preserves the literal table's
totality rather than extending the prefix shape.

**D2 — the README's unmeasured members** (folded as P3, §4).

**D3 — `phys3d_events_freed_space_methods` is a lottery on the landed tree (finding;
not touched by any fold here).** While proving P4 I hit this row failing with
`freed_space_methods jolt is crash envelope rc=134 … errs=[3 × 'Condition "slot >=
slot_max" is true. Returning: nullptr']`, and it fails on the **untouched** `vfold`
tree too — so I measured it as a controlled experiment (`fm-10x.log`): 10 targeted
runs per tree, alternating on one host in one minute:

| tree | targeted `--only` runs | FAIL |
|---|---|---|
| landed (`dirtyrep`, hash `483f9682…`) | 10 | **5** |
| folded P1+P2+P3 (`vfold`) | 10 | **2** |

Both trees fail; the landed tree failed *more* in this sample, so the fold is not the
cause. The mechanism is the one the r88 author documented for that arm: Jolt's crash
mode is heap-layout dependent ("the freed space's memory is either still shaped enough
like a live Jolt system that the internal check fires and the uncaught throw aborts, or
it is not and the query dereferences it into Godot's own SIGSEGV handler"). In the
segv mode the child also prints three `slot >= slot_max` ERROR lines, which the arm's
`freed_allow` list does not admit and its envelope requires empty — so one of the two
documented modes *fails* this row. In full-battery context the row passed in every rep
I have on record (the author's four invocations, the verifier's two, and my
P1+P2+P3 full run) and failed once (my `vfold4` attempt 2). **Consequence for the
round**: the "217/217" receipts are real but this row's stability is context-dependent;
if the round wants that row to be a *pinned* envelope rather than a lottery, the
segv-mode token belongs in `freed_allow` (a critic/author change, not a fold).
Recorded here because it changes what a 217/217 means.

**Checked and clean** (worth recording, since the hint asked for contradictions): the
7 arm doc-blocks at the top of the file match the 7 parent arms' checks — the oob
witness count (`PHASE_GETTERS.size() + 1` = 12) matches the if_phase parent's
`_log_count` expectation and the `oob_calls` pin; the `if_write` "witnessed zero" claim
matches the parent's `!= 0` refusal count and its Jolt-only detach witness (1/0/0); the
`joint_param` slider-guard count matches `JP_TYPES["slider"]` = 22; and the README's
`joint_solver` / `cross_space` numbers were spot-verified against the pinned dicts
(`prio_after=32`, `ctl_gap 0.8900 → pri_gap 0.6473`, `pri_lv 11.6509`, `clear_lv_next
-0.1633`, `remade_type 0`; rays `-0.5000` / `-10.5000` / `1.0000`, `srv_box 1.0000` /
`node_box 0.5000`). The one wording nuance found — the `if_write` child comment's "read
three ways … (`rel=2/3`)" while only `rel1`/`rel2` are emitted (the third read is used
for the detach class) — is consistent with the code and the pins, and is recorded here
rather than folded.

---

## 8. Shared-tree byte-identity and scope

- `git status --porcelain` before and after this lane: the same three modified tracked
  files, the same untracked `reports/round-1-20261015/`, plus this lane's own untracked
  `reports/round-89/r89-simplifier.md` and `corpus/live/r89-simplifier/`
  (`corpus/.gitignore` covers `live/`). No `.godot/` or other artifact was created in
  `corpus/fixtures/` (every godot invocation ran against a battery scratch under
  `corpus/live/r89-simplifier/runs-*/…/scratch/`).
- HEAD unchanged (`0c28c2a`), nothing committed, nothing pushed.
- Not touched: `run_battery.py` (the +24 rows are correct as authored and outside any
  fold here), the expect/pin tables, the r83–r88 arm bodies (except in the **opt-in**
  P4 patch), and every provenance comment explicitly marked historical.
- Scratch trees `dirtyrep/`, `vfold/`, `vfold4/` are throwaway copies; `dirtyrep/` is
  byte-identical to the tracked fixtures (sha256 verified above). Folded copies:
  `vfold` (P1+P2+P3) `9d8bea03…`, `vfold4` (P1+P2+P3+P4) `bf6f97d9…`.
- Additional receipts cited above: `bogus-probe.log` (D1), `fm-10x.log` +
  `runs-fm10-{vfold,dirty}-*/` (D3), `runs-fmrep-*`, `runs-vfold4-14/`,
  `vfold4-full{,2,3}.log`, `analyze_spawns.py` (the census), `fold.py` / `fold4.py`
  (the two fold scripts, applied only to scratch copies).

## 9. Stop condition

The next deletion would harm an axis: the pin tables *are* the evidence; the parent
arms' per-arm readability is what makes a 7 000-line fixture auditable; and the
totality repair (D1) costs weight to buy robustness. Fold set stops at P1–P3
(proven), with P4 handed to the L1 as a proven scope call.
