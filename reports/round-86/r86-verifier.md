# game-dev-3d round 86 — verifier (seat: verifier, host: devin) — independent re-derivation of `4e65726`

Wave `shokunin-train-20261101-w17`, lane g3d. Assignment (dispatch prompt,
verbatim):

> SEAT: g3d r86 VERIFIER — independent re-derivation of 4e65726. Repo:
> /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
>
> AGREE/DISAGREE: 195/195 on your own runs x2; prior 191 rows at identical
> positions with stdout+stderr byte-identical; each new cell re-derived
> (script_size_gate sizes refused-vs-granted in YOUR generated children;
> deferred_hang rc137 + refusal/abort lines; backend_tier class splits incl.
> the Jolt inversion; dummy_floor 11-token signature); the nav-cell refusal —
> can YOU reproduce the scout's safe_n=10 or the author's safe_n=0? (run
> corpus/live/r86-author/nav-replication/ command yourself).
> corpus/live/r86-verifier/ + reports/round-86/r86-verifier.md.

**Verdict: AGREE on every landed claim — 195/195 ×2 on my own runs, prior 191
rows byte-identical over 11 fields at identical positions against two
independent references, all four new cells re-derived with the verifier's own
generated children, and a 4-mutation adversarial check (3 detected as
designed, 1 explained). One DISAGREE, on the *reason* recorded for the parked
nav cell: the scout's `safe_n=10` receipt **is** reproducible on this host —
in a directory with a `project.godot` (6/6, 4/4, 4/4, 3/3 in four
environments, line-identical to the scout's receipt) — and fails to reproduce
only in the author's project-less `nav-replication/` layout (6/6 `safe_n=0`,
matching the author's own 8/8). The author's measurement is accurate; its
stated conclusion ("the cell's central witness is unreproducible on this host
today") is not.**

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17 01:18:38 UTC), `--headless`,
60 tps, GodotPhysics3D / Jolt Physics / Dummy backends of this build, this
host, 32 cores. Verified commit `4e657267fdb116579741ecce028e3f5c4511aa3d`
(HEAD, unmutated by me). Verified bytes = committed bytes:

    sha256sum corpus/fixtures/phys3d_events.gd corpus/fixtures/run_battery.py \
              corpus/fixtures/README.md
      66c92c38c9a1e0e981b3b2d6c871dbd3fc63c0b14fc646d2f62da047f1e14296  phys3d_events.gd   (1870 lines)
      e2df9f966d00c5637e051946c2c28e56ab629161e8f437d8648437aa0fdc69e4  run_battery.py     (195 CASES)
      d89e7be6758495c79d0756cad2dbd135f98478cc80cc7d1611ca284f514f96ca  README.md
    git diff --stat HEAD -- corpus/fixtures/   -> empty
    git rev-parse HEAD                        -> 4e657267fdb116579741ecce028e3f5c4511aa3d

All three match the author's declared landed bytes (§0 of `r86-author.md`)
exactly, and the worktree carries no uncommitted fixture edit.

**LSP unavailability recorded (per seat card).** `mcp_list_servers` exposes
only `rea` for this repo — no `lsp` device answers, and no LSP binary is on
`PATH` (same recorded absence as every r85/r86 sibling lane). No
symbol-aware operation was needed: this is a verification pass over
already-landed bytes, and the semantic check that replaces a server here is
Godot's own GDScript compiler — every new symbol in the diff (`_spawn_probe`,
`_size_probe_body`, `_backend_name`, the three new child bodies, the
`script_res`/`bound_s` parameters) is resolved at load, so a missing or
misspelled name is a `Parse Error` in the child log or a `push_error` drift
line, both of which the harness classifies. That mechanism is what the
mutation check below exercises from the other side.

---

## 0. Claim table

| # | claim (author `r86-author.md`) | verdict | one-line evidence |
|---|---|---|---|
| 1 | 195/195 PASS, rc 0, twice, from the landed bytes | **AGREE** | 2 fresh full batteries, `verdicts.json` sha `1d71deec…` / `2fb49ca4…`, `cases=195 pass=195 fail=0 ordinary=149 negative_controls=46`, `seeds_unchanged=true` |
| 2 | prior 191 rows byte-identical at identical positions (11 fields incl. stdout+stderr) | **AGREE** | 11 fields × 191 rows × {run1, run2} × {r86 frozen receipt @ `3d42f77`, author pristine baseline} = **0 mismatches**; the two references also agree with each other 191/191 |
| 3 | the 4 new rows are byte-identical between the two runs | **AGREE** | indices 191–194 byte-identical run1↔run2 **and** against the author's `final1`/`final2` rows |
| 4 | insertion-only: 682 insertions / 8 deletions, all replaced in place | **AGREE** | `git show --numstat` = 615/7 + 59/1 + 8/0; the 8 deleted lines are the extended `_spawn_child` signature/doc/`selfpath`/`cmd`/`res` forms and the README count line; no arm body, `CASES` row or `classify` rule touched |
| 5 | `script_size_gate`: refused@25 threaded, granted@1025 threaded, granted@25 unthreaded, fixture child granted | **AGREE** | verifier's own generator, 3 padding shapes × 3 reps: 26-line child `refused` thr / `granted` plain; 1025-line child `granted` thr; 9/9 per side |
| 6 | `deferred_hang`: rc 137, no marker, refusal line + abort line; Dummy contrast rc 0 | **AGREE** | verifier's own deref child: rc **137** through `/bin/sh` (2/2), log carries the refusal **and** the `SCRIPT ERROR` abort, no `CHILD_RESULT`; Dummy+threaded child rc 0 printing `PhysicsDirectSpaceState3DDummy` |
| 7 | `backend_tier`: area override `honors`/`ignores`/`floor`, margin `inert`/`binds`/`empty`, sepray `same-signature`/`differs-constants`/`floor` | **AGREE** | verifier's own sweep, 2 reps × 3 backends: identical classes **and** identical raw floats; the Jolt inversion (write lands, effect does not) reproduced verbatim |
| 8 | `dummy_floor`: 11-token signature + 2 real-backend refusals with those prefixes | **AGREE** | verifier's own floor probe: `["rid0","nil","2","rid0","0.0","dummy","nil","nil","0","rid0","nil"]` under Dummy; `["rid","v3","3","rid","16.0","nil","xform","value","1","rid","value"]` + `Parameter "space" is null.` / `Invalid ID.` under DEFAULT |
| 9 | "each new child log is byte-identical too" (§6.2) | **AGREE with caveat** | 10/11 are byte-identical across run1, run2 and the author's `final1`; `floorrealproj` is byte-identical only **modulo the embedded scratch path** — it differs between the author's own `final1` and `final2` (`bfa952c5…` vs `9671ecde…`), the same class §6.1 already discloses for `thrproj`/`joltthrproj` |
| 10 | nav Cell A "pre-measured witness does not replicate … unreproducible on this host today" (§7) | **DISAGREE as stated** | the scout's receipt reproduces **line-identically** (RID-normalized) in 17/17 fresh processes that run in a directory containing a `project.godot` (seed project 6/6, full seed copy 4/4, minimal project of mine 4/4, empty project file 3/3); it fails only where no `project.godot` exists (my 6/6 = 0, the author's 8/8 = 0, the exact `nav-replication/` command 3/3 = 0) |

---

## 1. Battery ×2 — 195/195 both runs, from the committed bytes

Two fresh full batteries, no probes (same shape as the author's `final1`/
`final2`), absolute `--runs`, run serially so the 8 s hang bound is never
under CPU contention:

| run | run dir | exit | verdict | totals | elapsed (Σ cases) | `verdicts.json` sha256 |
|---|---|---|---|---|---|---|
| verifier run 1 | `runs1/20261014T203820459943Z` | 0 | **PASS** | `cases=195 pass=195 fail=0 ordinary=149 negative_controls=46` | 211.2 s | `1d71deec6f767f56…` |
| verifier run 2 | `runs2/20261014T204155421648Z` | 0 | **PASS** | identical | 208.2 s | `2fb49ca4975582a1…` |

`seeds_unchanged=true` in both; `godot_version`
`4.7.2.stable.arch_linux.ed1daf0bf` in both; `seed` =
`/home/vgpnk/…/game-dev-3d-shokunin/corpus/fixtures` — the run measured the
worktree bytes, which §"verified bytes" shows equal the committed bytes.

The four new rows in run 1 (run 2 byte-identical):

    PASS phys3d_events_script_size_gate  exit 0  2.346 s
      PASS phys3d_events script_size_gate min_thr=refused min_plain=granted pad_thr=granted fixture_thr=granted child_exit=0
    PASS phys3d_events_deferred_hang     exit 0  9.065 s
      PASS phys3d_events deferred_hang threaded_rc=137 abort=true no_marker=true dummy_rc=0 floor_no_hang=true child_exit=0
    PASS phys3d_events_backend_tier      exit 0  2.528 s
      PASS phys3d_events backend_tier plain=honors jolt=ignores dummy=floor margin=inert,binds,empty sepray=same,differs,floor child_exit=0
    PASS phys3d_events_dummy_floor       exit 0  1.421 s
      PASS phys3d_events dummy_floor dummy=silent-floor dummy_errs=0 real=real-values real_errs=2 child_exit=0

The hang row lands at 9.065 s inside the harness's 20 s `CASE_TIMEOUT_SECONDS`
(author: 8.72 / 8.84 s) — the same ~16× margin on a ~0.5 s healthy child.

The README's documented `--only` command was also run on the four new rows
(`solo/20261014T204650059258Z`, sha `ceb8182b…`): **4/4 PASS**, so the
documented command works as written (the `.shokunin/game-dev-3d/…` path form
is this README's convention in all 43 of its command lines, not an r86
defect).

## 2. Prior 191 rows — byte-identical, identical positions, 0 drift

`tools/compare_runs.py` compares **all 11 fields** the receipt carries
(`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr`) row-for-row at index `i`:

    run1 vs frozen@3d42f77 (r86-baseline/runs/20261014T200631955691Z)  rows=191 mismatches=0
    run1 vs author-pristine (r86-author/pristine-baseline)             rows=191 mismatches=0
    run2 vs frozen@3d42f77                                             rows=191 mismatches=0
    run2 vs author-pristine                                            rows=191 mismatches=0
    frozen vs author-pristine (the two references agree)               rows=191 mismatches=0

The frozen reference is a receipt taken on `git archive HEAD` @ `3d42f77`
(before any r86 edit could exist), so it cannot carry the author's changes —
the strongest available pre-move baseline. `stdout` and `stderr` are compared
as line lists, not normalised: the prior 191 rows' **stdout and stderr are
byte-identical at identical positions** across the round boundary.

Seed digests (55 keys) are identical run1↔run2 and differ from the frozen
reference in **exactly the 3 declared files** (`README.md`,
`phys3d_events.gd`, `run_battery.py`), with **0 added, 0 removed** — the
insertion-only claim measured from the harness's own digest map.

## 3. The four new cells, re-derived with the verifier's own children

Everything in this section comes from `corpus/live/r86-verifier/direct/`,
whose probe sources and `project.godot` files are **written by this seat** —
they do not call `_size_probe_body`, `_spawn_child`, any child body, or
`run_battery.py`. A reproduction here is therefore a second implementation
measuring the same engine, not a replay of the author's code path.
`repro.json` sha `8a27ee4b…`.

### 3a. `script_size_gate` — refused vs granted in MY generated children

| probe | lines | threaded | unthreaded |
|---|---|---|---|
| `vars` pad 0 (author-shaped `var vN := N`) | 26 | **refused** 3/3 | **granted** 3/3 |
| `vars` pad 999 | 1025 | **granted** 3/3 | — |
| `funcs` (3-line function per pad) | 26 / 1026 | **refused** 3/3 / **granted** 3/3 | granted 3/3 (26) |
| `consts` (`const cN := N*2+1`) | 26 / 1025 | **refused** 3/3 / **granted** 3/3 | granted 3/3 (26) |

So the outcome is a function of size, not of the padding construct: three
different padding shapes give the same refused→granted flip at the same
nominal sizes, and the unthreaded control is granted at 26 lines. The
author's pin (`SIZE_PAD` 1000 → 1025 lines) is independently measured on
both sides.

**Band ladder (verifier's own, two sessions).** Pooled reps per point:
400 lines **4/4 refused**, 475 **8/8 refused**, 500 **8/8 refused**, 525
**7/8 refused**, 575 **1/8 refused**, 700 **4/4 granted**. The qualitative claim —
stochastic band, deterministic refusal below, deterministic grant above — is
confirmed, and both pinned endpoints sit far outside every edge I observed.
The 50 % point is *session-dependent*: my session refused 7/8 at 525 lines
where the boundary seat's table shows 1/6, and my first session saw 1/4
refusals at 575 where the second saw 0/4. That is what "race" means, and it
is why the author's decision to pin 450 lines clear of both edges is the
right one — but it also means the README's `~475–575` band is an
approximation of *that* session, not a reproducible boundary. (Author §8's
own named risk — "no seat has measured 1025 specifically" — is now closed on
this host: the 1025-line child is granted **6/6** in the `vars` shape across
the two revisions of my generator, and **3/3** each in `consts` (1025) and
`funcs` (1026 lines).)

### 3b. `deferred_hang` — rc 137 + refusal/abort lines, from my own child

The verifier's own generated deref child (same body as its size probe, `deref`
mode), under my own threaded DEFAULT project, wrapped in the same
`timeout -s KILL 8 /bin/sh -c` shape the fixture uses:

    sh_rc=137                       (direct subprocess rc = -9; 128+SIGKILL = 137 through /bin/sh, re-measured here)
    ERROR: Space state is inaccessible right now, wait for iteration or physics process notification.
    SCRIPT ERROR: Attempt to call function 'get_class' in base 'null instance' on a null instance.
    (no CHILD_RESULT / no VRESULT line at all)

2/2 reps, identical. The Dummy+threaded contrast of the same body: rc 0,
zero refusals, `VRESULT abort=PhysicsDirectSpaceState3DDummy` — 2/2. The
process-level `rc` and the two engine lines are independent witnesses of the
same event, exactly as the arm's comment claims.

### 3c. `backend_tier` — class splits incl. the Jolt inversion (my own sweep)

My own sweep, 2 reps per backend, raw `VNOTE` values (not just classes):

| backend | dss class | area override | margin (0 / 0.04 / 0.5) | sepray |
|---|---|---|---|---|
| DEFAULT | `GodotPhysicsDirectSpaceState3D` | `honors` — `base=(0,-9.8,0)/0.1` → `over=(0,20,0)/2.0`, readback `20.0` | `inert` — `[0.14453125, 0.150390625]` ×3 | `same-signature` — `[0.197265625, 0.203125]` |
| Jolt | `JoltPhysicsDirectSpaceState3D` | **`ignores`** — `base=(0,-9.8,0)/0.1` → `over=(0,-9.8,0)/0.1` **while readback `20.0`** | `binds` — `[0.1498413…, 0.1500244…]` → `[0.1459960…, 0.1461791…]` → `[0.0998535…, 0.1000366…]` | `differs-constants` — `[0.1998291015625, 0.20001220703125]` |
| Dummy | `PhysicsDirectSpaceState3DDummy` | `floor` — `(0,0,0)/0.0`, readback `<null>` | `empty` — `[]` ×3 | `floor` — data `<null>`, type `2`, cast `[]` |

The Jolt inversion is reproduced with the same raw numbers as the author's
child log: the write to the area parameter lands (readback `20.0`) and the
body's total gravity/damping does not move. Both engine hints are checked
before spawning, so an absent backend is an honest `BLOCKED`, never a
fabricated split.

### 3d. `dummy_floor` — the 11-token signature, from my own probe

My own floor probe prints the same 11 tokens in the same order:

    Dummy    tokens=["rid0", "nil", "2", "rid0", "0.0", "dummy", "nil", "nil", "0", "rid0", "nil"]  -> silent-floor
    DEFAULT  tokens=["rid", "v3", "3", "rid", "16.0", "nil", "xform", "value", "1", "rid", "value"] -> real-values
             ERROR: Parameter "space" is null.
             ERROR: Invalid ID.

2/2 each. (`shape_get_type` → `2` for a box shape is the "wrong constant, not
a zero" token; `space_get_direct_state(RID())` → non-null Dummy and
`free_rid(RID())` → the two loud refusals on a real backend. My probe, unlike
the fixture's children, does not free its RIDs, so it additionally prints RID
leak `ERROR:` lines at exit — a property of my minimal probe, not of the
cell.)

## 4. Adversarial check — 4 verifier mutations on scratch copies

`tools/mutate_check.py` (sha `56b153c5…`), each mutation applied to a scratch
copy under `mut/`; the tracked fixture is never touched. Expected result: rc
1, the arm's `PASS` marker absent, one `push_error` drift line naming the arm.

| # | mutation | side | expected | result |
|---|---|---|---|---|
| V-M1 | `HANG_RC 137 → 0` | parent pin | detect | **detected** — `deferred_hang drift exit=137 expected=0 marker={} abort=true refusal=true` |
| V-M3 | `_child_tier` area gravity `20.0 → 5.0` | child body | detect | **detected** — `backend_tier plain drift … v={…}` |
| V-M4 | `_child_floor` a second `free_rid(RID())` | child body | detect | **detected** — `dummy_floor real-backend refusal drift … errs=[…3 refusals…]` |
| V-M2 | `_child_floor` `free_rid(RID()) → free_rid(fresh)` | child body | no-detect, by design | **not detected**, mechanism confirmed: the freed space RID is freed again by `_cleanup_rids`, so the engine re-emits `ERROR: Invalid ID.` at `_cleanup_rids:225` — the count stays 2 and the parent still passes |

V-M2 is reported as a *negative* result with its mechanism: it was designed to
delete the second refusal and it cannot, because the double-free produces the
same engine line at another callsite. Read correctly it says something useful
— the `errs.size()==2` pin tracks the engine's refusals, not the body's text
— but it is not evidence that the pin is unbreakable, and the honest mutation
that *does* break it is V-M4.

## 5. The nav-cell refusal — DISAGREE with the recorded reason

The author's §7 states that the nas-scout's Cell A witness does not
replicate: `safe_n=0` in 8/8 fresh processes against the scout's own receipt
(`safe_n=10`), concluding "the cell's central witness (`velocity_computed`
delivery, `last_safe`) is unreproducible on this host today". The
replication lives in `corpus/live/r86-author/nav-replication/` with the exact
command:

    timeout -s KILL 40 /usr/bin/godot --headless --path . --script res://probe_nav_node_rid.gd

Both probe files there are byte-identical to the scout's pinned manifest
entries (`probe_nav_node_rid.gd` `68f0b843…`, `nav_node_rid_driver.gd`
`1c6a60ff…`) — re-hashed here, match. I ran that exact command in that exact
directory: **`safe_n=0`, 3/3 more reps** (11/11 including the author's 8), and
the directory is unchanged afterwards. The author's measurement is accurate.

But the directory has **no `project.godot`** — and that is the whole
difference. Same probe bytes, same host, same build, only the environment
varies (`nav/nav_repro.py`, `nav/nav_repro.json` sha `90c17946…`):

| env | `project.godot` | reps | `safe_n` (A/B/C) | probe lines vs scout receipt |
|---|---|---|---|---|
| E1 — author's layout (2 `.gd` files only) | absent | 6 | **0 / 0 / 0** | differs only in the 6 safe/`TAIL_SAFE` lines |
| author's own dir, exact command | absent | 3 | **0 / 0 / 0** | identical to E1 |
| E5 | **empty file** | 3 | **10 / 10 / 10** | **identical** to scout receipt (RID-normalized) |
| E4 | minimal `[application] config/name` | 4 | **10 / 10 / 10** | **identical** |
| E2 | tracked seed `project.godot` | 6 | **10 / 10 / 10** | **identical** |
| E3 | full byte copy of `corpus/fixtures` + probes | 4 | **10 / 10 / 10** | **identical** |

The A/B is *measured*; the mechanism is *inference*: with no `project.godot`
Godot runs the script without loading a project (no `.godot` import cache is
written in either case, and E1 emits no project error), and in that mode the
`NavigationAgent3D` avoidance callback is not delivered to this probe while
every other server read (`srv_vel`, `srv_pos`, `in_map`, `has_cb`,
`same_tick_srv`) is unchanged. An empty `project.godot` file is enough to
flip it (E5, 3/3), so this is not about any particular project setting. The
practical consequence for the lane is independent of the mechanism: every
battery child runs `--path <scratch>` where scratch is a copy of the seed dir
and therefore contains `project.godot`.

`nav/compare_nav.py` extracts the probe's own six output-line families,
normalizes the per-process `RID(...)`, and compares against
`corpus/live/nas-scout/runs/p6/nav_node_rid.stdout.txt`: **every one of the
17 project-present runs is line-identical to the scout's receipt**, including
`A_node_setter … node_vel=(2.0, 0.0, 0.0)` with `TAIL_SAFE` all zeros,
`B_server_rid … same_tick_srv=(2.0, 0.0, 0.0)` with `TAIL_SAFE` all
`(2.0, 0.0, 0.0)`, `C_server_rid_forced` zeros, `CTL_RID … agents_in_map=1`,
`NODE_RID in_map=true … avoidance_enabled=true has_cb=true`. The scout's
`last_safe`/`safe_n=10` pins are **reproducible on this host**; they are
simply not reproducible *outside a Godot project*, and the author's
`nav-replication/` layout is outside one.

Two further observations from the same data:

- The scout's receipt and the author's rerun differ **only** in the six
  safe-callback lines (`nav/nav_compare.txt`): `TAIL_SRV`, `srv_pos`,
  `node_vel`, `same_tick_srv`, `CTL_RID` and `NODE_RID` are identical. So
  neither seat's *structural* measurements are in question; the entire
  discrepancy is callback delivery.
- The scout's own three `nav_node_rid` receipts (`p6`, `det4-d1`,
  `det4-d2`) all record `safe_n=10` for all three arms, consistent with its
  `RECEIPTS.md` determinism table, and the scout ran in per-case scratch
  directories copied from the seed (which contain `project.godot`). So the
  scout's receipt was taken in the project-present environment; the author's
  replication was not.

**What this does and does not change.** It does not land the nav cell — that
is the author's and L1's call, and the assignment's "if clean" condition was
the author's to judge. It does mean the *recorded reason* for parking it is
wrong as written: the honest statement is "the witness is not reproducible
outside a Godot project; inside one it reproduces line-identically, 17/17".
An r87 author arming `navagent3d_set_velocity_inert` must run the probe with
a `project.godot` present (as every battery child does, via the seed-dir
scratch copy) and must re-derive the `last_safe` pins in that environment.
Whether the cell should be armed is not this seat's verdict.

## 6. Hygiene, write scope, repository state

- **Tracked files: zero edits by this seat.** `git status --porcelain` shows
  only sibling untracked reports (`r86-baseline.md`, `r86-critic.md`,
  `r86-reviewer.md` at the time of writing) — no ` M` entries on tracked
  paths. No commit, no push, no branch operation, no `git add`.
- **No orphan processes.** `ps -eo pid,ppid,cmd | awk '$2==1 && /godot/'` →
  empty; `pgrep -a godot` → empty after the runs. The hang child is killed by
  its own `timeout -s KILL 8` inside the fixture's `/bin/sh` wrapper, so no
  zombie survives the arm.
- **Disk:** 5.0 MB total under `corpus/live/r86-verifier/` (551 pinned files),
  all inside the gitignored `corpus/live/` root. Each battery run's scratch
  tree is ~1 MB.
- The author's `nav-replication/` directory was read and the documented
  command re-run inside it; it is byte-unchanged afterwards (5 files, same
  shas) — the probe run writes nothing there.

## 7. What I did NOT verify, and residual risk

- **The author's own 9-mutation matrix** (§6.3) was not re-run; I ran my own
  four (§4). The author's matrix is plausible and its anchors are visible in
  the diff, but its 9/9 count is their receipt, not mine.
- **The boundary seat's ladder** (`r86-boundary.md` §1) was not re-run; I ran
  my own (§3a) and it agrees qualitatively but not numerically at the 50 %
  point. Anything a future round pins *inside* 475–575 lines would need a
  fresh, host-controlled ladder, not a quoted table.
- **`floorrealproj`'s child log is not byte-stable across runs** (path
  embedding). The map (`CHILD_RESULT`/`CHILD_NOTE` lines) is the witness, as
  the author's §6.1 already says for `thrproj`/`joltthrproj`; §6.2's blanket
  "each new child log is byte-identical too" should be read as
  "10/11 byte-identical, `floorrealproj` map-identical".
- **One session, one host, one build** for every number above
  (`4.7.2.stable.arch_linux.ed1daf0bf`); the band's 50 % point and any
  Jolt/Dummy solver constant are build-and-load dependent by construction.
- **The bpy and three.js surfaces** are out of scope for this seat; the
  r86-baseline seat owns the cross-surface replay.
- The `mutation_check.py` V-M2 result is a *negative* control with a
  mechanism, not a detected mutation; the verdict of that tool is computed
  against the per-mutation expectation, not against "all detected".

## 8. Bounded claim

On this host, this build, at commit `4e65726`: the four landed phys3d cells
are **independently re-derived** (my own generated children, not the
fixture's), the prior 191 Godot rows are byte-identical at identical
positions over all 11 receipt fields against two independent pre-move
references, the two full batteries are 195/195, the new rows are
byte-stable across four runs (mine ×2, the author's ×2), and two of the
three designed verifier mutations plus one added mutation are detected while
the third is explained. The nav-cell refusal's recorded reason does not
survive replication: the scout's witness reproduces line-identically in any
directory that contains a `project.godot`, and fails only in the
project-less directory the replication used.

## 9. Receipts (all under `corpus/live/r86-verifier/`, sha-pinned in `manifest.sha256`, 551 files)

| artifact | what it is |
|---|---|
| `runs1/20261014T203820459943Z/verdicts.json` `1d71deec…` | full battery #1, 195/195 PASS |
| `runs2/20261014T204155421648Z/verdicts.json` `2fb49ca4…` | full battery #2, 195/195 PASS |
| `solo/20261014T204650059258Z/verdicts.json` `ceb8182b…` | documented `--only` command on the 4 new rows, 4/4 |
| `logs/compare.log` | 11-field × 191-row comparison vs both references |
| `runs1/…/scratch/{szminproj,szplainproj,szpadproj,szfxproj,hangproj,hangdummyproj,tierplainproj,tierjoltproj,tierdummyproj,floordummyproj,floorrealproj}/child.log` | the 11 new child logs from my run (shas in §3; 10/11 byte-identical to the author's) |
| `direct/repro.py` + `direct/repro.json` `8a27ee4b…` | verifier's own generator + driver for all four cells |
| `direct/size_exact.py` + `size_exact.json` `6fa13928…` | exact-line-count follow-up (three padding shapes at 26 / 1025 lines) |
| `direct/logs/`, `direct/logs-formatbug/` | per-run logs (the `logs-formatbug/` set is the first revision of my own probe, which emitted a string-formatting `ERROR` in its `VNOTE` line; the refused/granted classification was computed before that print and is unaffected — kept for honesty, superseded by `logs/`) |
| `nav/nav_repro.py`, `nav/nav_repro.json` `90c17946…`, `nav/E{1..5}/`, `nav/E*_r*.log`, `nav/author_dir_r{1,2,3}.log` | the nav replication matrix (6/6/4/4/3 reps) + the exact author-dir command |
| `nav/compare_nav.py`, `nav/nav_compare.txt` | line-level comparison of every nav run against the scout's `p6` receipt |
| `tools/compare_runs.py` | the 11-field prior-row comparator |
| `tools/mutate_check.py`, `mutation_check.json` `56b153c5…` | the 4 verifier mutations |
| `mut/` | the mutation scratch copies + their child logs (tracked fixture untouched) |

Not committed — the integrator commits. No tracked file was modified by this
seat; `corpus/live/` is gitignored (`corpus/.gitignore:1`).
