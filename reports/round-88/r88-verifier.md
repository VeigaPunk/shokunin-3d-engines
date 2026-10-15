# game-dev-3d round 88 — verifier: independent re-verification of the r88 landing (seat: verifier, host: devin)

Assignment (verbatim from dispatch):

> You are the VERIFIER seat for game-dev-3d-shokunin round 88. … Read
> reports/round-88/r88-author.md first, then independently verify on this
> host — do NOT trust the author's receipts: (1) full battery twice;
> (2) prior-row stability rows 1–201 vs the frozen baseline tuples;
> (3) forge tests on the new arms; (4) kill test on one new CASES row.
> Receipts under corpus/live/r88-verify/. Never edit tracked files.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(`--headless`, 60 tps), Python 3.14.7, 32 cores. Verified tree = the r88
landing bytes: `phys3d_events.gd` sha256 `fd72730b…73e7`,
`run_battery.py` `50477429…1794f0`, `README.md` `34282953…5b136`
(re-computed by this seat, matching the author's declared worktree
digests). No `lsp` device in this seat; none needed — verification is the
battery itself plus scratch-copy forgeries. No `labrat` probe dispatched
(the frozen probeParent allowance was unused: every hypothesis below was
tested directly against the engine).

**Head-motion note.** The host committed the landing mid-verification:
`db64943` → `3028263` ("r88: PhysicsDirectSpaceState3D read family…")
at ~05:33Z, inside run 1's window. The commit moved HEAD only; worktree
bytes did not change — `git show HEAD:<file> | sha256sum` for all three
fixtures equals the digests above, so both runs measured exactly the
committed r88 content. `git status --porcelain -- corpus/` is clean at
filing; nothing was committed, pushed, or edited in tracked files by
this seat. All scratch lives under gitignored `corpus/live/r88-verify/`.

## Verdict summary

| item | verdict |
|---|---|
| 1. Full battery ×2, tuple delta | **PASS** (210/210 twice, 0 tuple mismatches) |
| 2. Prior rows 1–201 vs frozen baseline | **PASS** (201/201 index-identical, both runs) |
| 3a. Forge: expected-token mutation on a pinned cell | **PASS** (row FAILs, and only that row) |
| 3b. Forge: freed_space_methods fake breadcrumb, no crash | **PASS** (rc conjunct rejects it) |
| 3c. Forge: race_class torn channel outside envelope | **PASS** (envelope check rejects it) |
| 4. Kill test: delete one new CASES row | **PASS** (only that row's verdict changes) |

## 1. Full battery ×2 — PASS

Invocations (absolute `--runs`, four probes armed — the baseline/author
convention):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r88-verify/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout

| run | receipt | verdict | totals | probes | seeds_unchanged | wall |
|---|---|---|---|---|---|---|
| 1 | `runs/20261015T053220643854Z/verdicts.json` sha `c4d7709e4c7b149c9eb87b37415bf4b0dd4d5ab9fee1d1b725e7e9e0c8d3cc61` | PASS | 210/210 (ord 164, neg 46) | crash+stream+tree ok, mutation detected | true | 313 s (05:32:20→05:37:33Z) |
| 2 | `runs/20261015T053847599766Z/verdicts.json` sha `4e754fd2b18e8acffdac8380681a9f37c1546027f1164ba329595cbb7cb65601` | PASS | 210/210 | same | true | 306 s (05:38:47→05:43:53Z) |

**Tuple delta**: `[case, verdict, actual_exit, marker, stdout, stderr]`
compared index-by-index over all 210 rows: **0 mismatches** — the two
runs are tuple-identical, including the nine new rows (the marker is
branch-stable, as the author claimed). New-row markers observed:
`motion_split gp=wide jolt=tight`, `race_class … jolt=crash-or-classes`,
`freed_space_methods gp=crash6 jolt=crash-or-dead`.

Branch evidence in my runs (child logs inside each receipt's
`scratch/`): `rc_jolt` landed the **completed envelope** both times —
`envelope=ok refused=4`, classes `["is+cs+cm","cm","cm","is+cs+ri+cm"]`
(run 1) vs `["is+cs+cm","is+cm","is+cs+ri+cm","is+cs+ri+cm"]` (run 2)
with Jolt tear lines present — the class *set* varies, the envelope
holds; `rc_plain` was `["all"×4]` both times. All six `fmjolt*`
children crashed (core dumped, `timeout` witness line), all six
`fmplain*` crashed; `fmdummy` completed with the 30-token dict.

## 2. Prior-row stability (rows 1–201) — PASS

`corpus/live/r88-baseline/tools/verify_prior_rows_full.py` (the
baseline's own strict comparator, run read-only) against the frozen
6-tuple reference `corpus/live/r88-baseline/prior-201-godot-rows-full.json`:

```
run 1 (053220643854Z): index-identical prior rows 201/201, inserted rows 9
                       at tail ([202]…[210]), RESULT PASS
run 2 (053847599766Z): index-identical prior rows 201/201, inserted rows 9,
                       RESULT PASS
```

Byte/tuple equality (case, verdict, actual_exit, marker, stdout-lines,
stderr-lines) at identical positions — not a summary statistic. The nine
inserted rows are exactly the r88 CASES tail, all PASS. Log:
`corpus/live/r88-verify/prior201-verify.log`.

Cross-check on the landed diff: `git diff db64943 HEAD -- run_battery.py`
is the 9-row tail append plus the other lane's documented 5-line
`--runs` docstring/`resolve()` harness edit — CASES insertion-only at
the tail, `freed_space_methods` last, consistent with the author's
report.

## 3. Forge tests — all PASS (forgeries rejected)

Each forge lives in a **scratch copy** of `corpus/fixtures/` (55 files,
`three/` excluded — outside the digest set and the scratch copy;
pre-mutation file shas verified equal to the landed bytes), never in the
tracked tree. Forged scripts parse (`godot --check-only` clean). Forged
run_battery copies run their own `--runs` tree under
`corpus/live/r88-verify/<forge>/runs/`.

### 3a. Expected-signature token mutation on a pinned cell — PASS

Mutation (`forge-a/fixtures/phys3d_events.gd`, one token, one cell):
`expect_pq_plain` cell `"pq_plain_prec": "1,0,1"` → `"1,0,2"` — the
pinned signature of the `pq_plain` precedence cell in `param_purity`.

Full forged battery `forge-a/runs/20261015T054536343627Z/verdicts.json`
sha `fa4b76338ce5075fc6aeabe80cf21db6667f9c9db406134821b9f40a8a068542`:

- `totals: cases=210 pass=209 fail=1`, `seeds_unchanged=true`.
- The **only** FAIL is `phys3d_events_param_purity`:
  `exit=1 … ERROR: phys3d_events: param_purity plain drift exit=0
  serr=false v={ … "pq_plain_prec": "1,0,1" … }` — the child's whole-dict
  comparison reports the measured token back at
  `phys3d_events.gd:2528`; marker absent.
- Tuple-level diff of all 210 forged-run rows vs control run 1: exactly
  one differing row — index 204 `phys3d_events_param_purity`. The other
  209 are byte-identical.

The pin is real: corrupting one expected token fails that row and no
re-derivation rescues it.

### 3b. freed_space_methods fake breadcrumb, no crash — PASS

Mutation (`forge-b/fixtures/phys3d_events.gd`): `_child_freed_method`
gains an `arm == "fm_plain_pt"` branch that prints the *entire* fake
evidence set — `CHILD_NOTE fm_plain_pt alive=` / `pre=` / `refetch=`
(post= absent), plus forged witness text `SCRIPT ERROR: … previously
freed instance.`, `ERROR: Parameter "space" is null.`, and even
`handle_crash: Program crashed with signal 11` — then `_quit_clean()`
with **no `free_rid` and no crash**.

Run `forge-b/runs/20261015T054442967467Z/verdicts.json` sha
`c1ceec5d4373f39d3830a13bfa88293ba1b40a9c70ab9da16fd0877bc40784f2`
(`--only phys3d_events_freed_space_methods,phys3d_events_geom_split`):

- `phys3d_events_freed_space_methods` **FAIL**: `exit=1 … ERROR:
  phys3d_events: freed_space_methods plain pt rc=0 not signal-class`
  (`phys3d_events.gd:2781`). Control `geom_split` PASSes.
- Forged child log (`scratch/fmplainpt/child.log`) measured against the
  parent's own conjuncts: crash-line count 1, `previously freed` 1,
  `Parameter "space" is null` 1, `alive=`/`pre=`/`refetch=` notes 1
  each, `post=` 0, `CHILD_RESULT` 0 — **every log-side conjunct
  satisfied by the forgery**. The row fails solely on
  `rc ∈ {134,137}`, which cannot be forged without actually crashing.
  The unforged sibling children (e.g. `fmplainray`) really did crash in
  the same batch (core dumped at `_held_space`, the documented site).
- A non-crashing child cannot pass the crash envelope: the rc conjunct
  is checked before and independently of every printable witness. PASS.

### 3c. race_class torn channel outside the envelope — PASS

Mutation (`forge-c/fixtures/phys3d_events.gd`): `_sample_race` injects
`row["pt"] = 99` on every out-of-phase F sample — a count channel torn
to a value outside `{empty/zero, legal(=1)}`.

Run `forge-c/runs/20261015T054510638617Z/verdicts.json` sha
`b8704a21bed496ea933318f4fec5eba8fda9e711b356fb67e6d22b8ad11e66ad`
(`--only phys3d_events_race_class,phys3d_events_geom_split`):

- `phys3d_events_race_class` **FAIL**: `exit=1 … race_class plain drift
  … "rc_plain_envelope": "violation"` (`phys3d_events.gd:2429`).
- Child log evidence (`scratch/rcplainproj/child.log`):
  `legal={pt:1, ray:7, is:1, cs:2, cm:"frac", ri:6}
  classes=["pt=99","pt=99","pt=99","pt=99"]` then
  `CHILD_RESULT rc_plain_envelope=violation` — the child's own envelope
  logic names the torn channel, and the parent's whole-dict compare
  refuses it. Control `geom_split` PASSes.
- A torn value outside the envelope fails — the envelope is checked, not
  claimed. PASS.

## 4. Kill test: delete one new CASES row — PASS

Mutation (`kill/fixtures/run_battery.py`): the
`phys3d_events_param_purity` CASES entry (2 lines) deleted → 209 cases.

Run `kill/runs/20261015T055051694522Z/verdicts.json` sha
`98e29bf7a4b85dc63c89e8f23c9bb9b79ad055c3343f6f2b64e1a0332738e205`:

- `totals: cases=209 pass=209 fail=0`, verdict PASS,
  `seeds_unchanged=true`.
- `phys3d_events_param_purity` is absent from the run; every other row's
  6-tuple is **byte-identical to control run 1** (209/209 shared rows, 0
  mismatches). Deleting the row changes exactly that row's verdict (it
  is no longer produced); nothing cascades, nothing drifts. PASS.

## Receipts index (all under `corpus/live/r88-verify/`)

- `runs/20261015T053220643854Z/` — run 1 (verdicts + mutation/tree probes
  + scratch child-log tree); `runs/20261015T053847599766Z/` — run 2.
- `run1.log`, `run2.log` — battery stdout.
- `prior201-verify.log` — both strict prior-201 compares.
- `forge-a/` (expected-token forge, full 210-row run + `forge-a.log`),
  `forge-b/` (fake-breadcrumb forge, `--only` run; see
  `forge-b/runs/*/scratch/fmplainpt/child.log`),
  `forge-c/` (torn-channel forge, `--only` run; see
  `forge-c/runs/*/scratch/rcplainproj/child.log`),
  `kill/` (CASES-row deletion, full 209-row run + `kill.log`).
- Forged-copy seeds differ from landed bytes only at the stated patch
  (`forge-a` gd sha `47e60262…`, `forge-b` `69bde67b…`, `forge-c`
  `1e009ee8…`, `kill` py `1fcc2957…`).

## Risks / limits

- Both verification runs landed `rc_jolt`'s *completed* branch; the
  crash branch was not independently reproduced here (author observed
  both). The marker is branch-stable and the forged forge-c run proves
  the envelope still rejects out-of-envelope values — residual risk is
  "crash-branch unobserved this round", not "unchecked".
- Forge-b targeted a GodotPhysics child (`rc=0 not signal-class` is
  deterministic). A Jolt-side fake would instead trip the dead-branch
  conjuncts (`post != "nil"` / witness counts) — same verdict, different
  check site; not separately exercised.
- Kill test removed a non-crash row; row independence is structural
  (each CASES entry maps to one `--arm`), so the result generalizes.
- One host, one build (`4.7.2.stable.arch_linux.ed1daf0bf`); no
  cross-version inference. Sibling surfaces (bpy, three.js) were not
  re-run by this seat — out of the assigned scope.
- Blockers: none. The landing verifies clean on every assigned item.

**Seat output complete.** No tracked-file edits, no commits, no pushes;
all evidence under gitignored `corpus/live/r88-verify/`.
