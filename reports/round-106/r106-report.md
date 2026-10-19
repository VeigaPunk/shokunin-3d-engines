# r106 round report — citation sweep, census refresh, consistency audit

- **Seat:** SEAT-65 REPORT-DRAFT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Round:** 106 · **Axes:** depth / coverage / calibration
- **Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- **Landing commit:** `26cd9f2b6b30dc0c4ad06560c0350600dbb93cdf` — L1 fills this at close; this report is intended to land last.
- **Report base HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`, observed `2026-10-18T21:20:44Z` and again `2026-10-18T21:31:31Z`). Subject: `r105 report-last` — work `3634bc0748f2ae1e02e20571874b39a3f3705daa`.
- **Evidence frame:** `2026-10-18T21:34:11Z`. The worktree was still moving. Hashes below are a frame, not the close revision. Re-measure at `26cd9f2b6b30dc0c4ad06560c0350600dbb93cdf`.

Tags: **[O]** command-run observation by this seat · **[I]** labelled inference · **[P]** a peer report this seat read, not a command this seat re-ran. A green spot check is not a full-battery result. No Unreal Editor or live Unreal runtime claim is made anywhere in this file.

## Summary at the last evidence frame

- **C1 (coverage) — partial, not closed.** Path-root mechanical fixes had landed in eight lessons (`r61`–`r68`), each with a dated correction note, not a silent rewrite of the historical counts. The notes cite `reports/round-106/sweep/chunk-05.md`, and that path was absent at this frame (`ls` of `reports/round-106/sweep` was an empty directory). It existed by the `22:08:03Z` re-check below; the eight post-edit digests in it were not re-hashed here. Gate pointer sweep remains a different instrument: captured stdout says `POINTERS=103` `UNRESOLVED=0`.
- **C2 (depth) — probed; census file unedited at this frame, edited later.** Every engine *state cell* was re-checked and did not move. At `21:34:11Z` `corpus/knowledge/engines.md` was still the r102 blob (`d03907d3…`, `git diff` empty) and still said `Node v26.11.1`. Live default is mise `v26.12.0`; pinned is fnm `v24.21.0`. By `22:08:03Z` the worktree file had a dated note, a two-state table, and a new Blender row at `partial` (sha `055ea7df…`). Spot receipts exist under both Node states. The full battery was not re-run. Carried totals, re-parsed here: default-env **337/350** (`reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`) and pinned-env **350/350** (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`).
- **C3 (calibration) — notes landing, ruling not applied.** The r105 lifecycle lesson gained an environment-pairing note that keeps `337/350` as the default-env total and points at the pinned `350/350` receipt. Eight path notes preserve historical counts and the recorded `v26.11.1`. SEAT-47's dated-note fatigue ruling is a proposal (`reports/round-106/consistency/adversary.md`), not a lane ruling. P/C remains unapplied (`12/1/0`).

## Work performed and evidence

### C1 — citation sweep (path/command resolution)

**What had landed in tracked files at `2026-10-18T21:34:11Z`.** `git diff --stat HEAD`:

```text
 corpus/lessons/r105-unreal-lifecycle.md       | 14 +++++++++++++-
 corpus/lessons/r61-stream-review.md           |  9 +++++----
 corpus/lessons/r62-three-ortho-near-review.md |  9 +++++----
 corpus/lessons/r63-three-ray-review.md        | 13 +++++++------
 corpus/lessons/r64-ray-side-review.md         | 13 +++++++------
 corpus/lessons/r65-ray-order-review.md        |  9 +++++----
 corpus/lessons/r66-ray-range-review.md        |  9 +++++----
 corpus/lessons/r67-ray-boundary-review.md     |  7 ++++---
 corpus/lessons/r68-ray-layers-review.md       |  9 +++++----
 9 files changed, 56 insertions(+), 36 deletions(-)
```

**[O]** `rg -l 'Correction note \(r106'` under `corpus/lessons` returned **8** files, one hit each: `r61` through `r68`. Each note says the `.shokunin/game-dev-3d/` prefix was re-rooted to a repo-relative path, that `ls -d .shokunin` exits 2, and that the historical counts (83/83, 3/3, 5/5, 9/9, and the recorded Node `v26.11.1`) are left as that round's record. That is the required shape for a historical fact: dated note, not a silent rewrite. **[I]** It is also a long in-file essay. SEAT-47's S1 would have recorded a pure path-conformance fix in the round report and not also narrated it inside the lesson. This seat does not pick that fight; it queues it.

**Unresolved evidence pointer.** Every one of those eight notes ends by citing `reports/round-106/sweep/chunk-05.md`. At `21:34:11Z`:

```text
$ ls -la reports/round-106/sweep
total 0
drwxr-xr-x … Oct 18 18:20 .
drwxr-xr-x … Oct 18 18:30 ..
```

**[O]** The directory existed and was empty. A correction note whose evidence file is not on disk is not yet a closed citation repair. Queue: land the chunk report, or date the pointer. Do not treat the eight notes as sweep-complete until that path resolves.

**Commands that still resolve, from peer re-runs this seat read and spot-checked.** **[P]** `reports/round-106/r22-regression.md`: both descriptor arms exit 0 (accept the authored `.uplugin`, reject the bad-Type control); crossed expectations exit 1. **[P]** `reports/round-106/glb-unity-regression.md`: `python3 corpus/artifacts/glb-r12/run_import.py` exit 0; `uv run … verify_scene.py` exit 0. This seat confirmed the captured exit files:

```text
$ cat reports/round-106/glb-unity/glb-r12-20261018T212038Z.exit
GLB_EXIT=0
$ cat reports/round-106/glb-unity/unity-r19-20261018T212038Z.exit
UNITY_EXIT=0
```

Unity's PASS line is `local-static`. It is not a Unity Editor import. **[O]** `command -v Unity` / `UnityEditor` / `unity-editor` returned rc 1 at `21:21:07Z`.

**Gate pointer sweep is not the corpus citation sweep.** This seat did not re-run the gate. It grepped the captured stdout SEAT-70 wrote:

```text
$ rg -n 'POINTERS=|GATE RESULT' reports/round-106/gate/scratch/gate-run.stdout
53:POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
56:GATE RESULT: PASS (checks failed: 0)
```

**[O]** stdout sha256 `c69c93614b99db75047bb174b0406323fb9801d400e055f8eaf12e5b3c159c2b`. **[P]** `reports/round-106/gate/final-run.md` records rc 0, pin `a6aa73ad…`, census `12/1/0`, `GATE_WORKDIR` under `reports/round-106/gate/scratch` (not `/tmp`). **[P]** `reports/round-106/gate/blocked-check.md`: dead `REPO` → rc 2 `BLOCKED`; bad `GATE_REF` → rc 1 `FAIL`, not `BLOCKED`. Same scanner sha `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`, which this seat also hashed on the live script. A passing gate does not see a missing `sweep/chunk-05.md`.

**Upstream pin, not a runtime claim.** **[P]** `reports/round-106/freshness-pin.md`: `main` still `a6aa73ada02a9fb1f5415bec491f9942c519b297`; vendored tree byte-identical to that tip; open PR #9 is not on `main`. **[P]** `reports/round-106/install-recheck.md`: engine HTTPS 404 (rc 128), SSH public-key denied, Lutris not installed. This seat's own absence check:

```text
$ which UnrealEditor UnrealEditor-Cmd; echo which_rc=$?
which_rc=2
$ ls -d /opt/UnrealEngine
ls: cannot access '/opt/UnrealEngine': No such file or directory
```

### C2 — engines.md census under the two-state model

**The census file did not move.** **[O]**

```text
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
$ git diff --stat HEAD -- corpus/knowledge/engines.md
(empty)
$ git hash-object corpus/knowledge/engines.md; git rev-parse HEAD:corpus/knowledge/engines.md
5eef89d484b60e26ab78c29dd86a64781b0df86f
5eef89d484b60e26ab78c29dd86a64781b0df86f
```

Four data rows. State cells at this frame: Godot `yes` / `yes`; Unity `no` / `no`; Unreal `no` / `no`; three.js `partial`. **Promotions: 0.** **[P]** `reports/round-106/engine-count.md` and `reports/round-106/census/verify.md` agree and queue the same host-string drift. This seat read the live row: the three.js installed cell still says `(Node v26.11.1)`.

**Two states, this seat, `2026-10-18T21:21:07Z` and again `21:31:31Z`.**

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ command -v godot; godot --version
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
```

`type -a node` puts the mise `latest/bin` first, then the mise shim, then fnm multishells. The pinned binary is present and is not the default. That is the r105 shadowing model, re-observed, not a new mechanism.

**Spot receipts this seat parsed (`json.load`), not inherited from prose.**

| receipt | env | parsed |
|---|---|---|
| `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` | default, carried | `verdict=FAIL` `cases=350 pass=337 fail=13` `seeds_unchanged=true` runner `f456bd00…`; 13 non-pass cases, all `r94_cannon_*`; sample reason `exact stdout marker missing` |
| `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` | pinned, carried | `verdict=PASS` `cases=350 pass=350 fail=0` ordinary 291 / negative 59 `seeds_unchanged=true` runner `f456bd00…` sha prefix `54b7140d` 131 seed files |
| `reports/round-106/battery-default-quick-receipts/` via SEAT-87's report, and the scratch verdicts that report names | default, this round, one row | **[P]** `r94_cannon_nan` FAIL, exits 0/0, reason `exact stdout marker missing`, expected `node=v24.21.0`, observed `node=v26.12.0`, `seeds_unchanged=true` |
| `reports/round-106/n24/runs/seat88-pinned-quick-20261018T212035Z.verdicts.json` | pinned, this round | **[O]** `r94_cannon_nan` PASS exit 0/0 reasons `[]` `seeds_unchanged=true` runner `f456bd00…` sha `2c98d3b805bc8c49` 19147 bytes. Stdout receipt lines 10–16 show `PASS r94_cannon_nan` and `COMMAND_EXIT=0` |
| `reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json` | pinned, this round | **[O]** `r94_cannon_det` PASS exit 0/0 `seeds_unchanged=true` sha `11109a3cad610b75` |
| `reports/round-106/census/phys3d-joints/runs/20261018T212035512412Z/verdicts.json` | default | **[O]** `phys3d_joints_free_pair` PASS elapsed 2.765 s `seeds_unchanged=true` |
| `reports/round-106/census/phys3d-joints/runs/20261018T212038422172Z/verdicts.json` | default | **[O]** `phys3d_joints_free_ops` PASS elapsed 2.774 s `seeds_unchanged=true` |

**[P]** `reports/round-106/census/three-default.md`: default-node `run_cases.mjs` 3/3 and `run_camera_cases.mjs` 5/5, both `seeds_unchanged=true`, node recorded `v26.12.0`, three `0.186.1`. This seat did not re-run those suites. **[P]** `reports/round-106/census/verify.md`: the same 3/3 runner also exits 0 under the fnm prefix, child `execPath` the v24.21.0 binary. `executable headless` stays `partial`. No GL, pixel, or browser claim.

**Runner bytes did not move.** **[O]** `sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `phys3d_joints.gd` → `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`. `git status --short -- corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/engines.md` was empty at `21:34:11Z`.

**Queued for the census owner, not applied here.** Date-correct the `Node v26.11.1` parenthetical as a mint-time host fact. Current default on 2026-10-18 is mise `v26.12.0`. Pinned state is fnm `v24.21.0`, command-scoped, documented in `corpus/fixtures/PINNED-ENV.md` (sha `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f`, this seat). Do not silently replace `v26.11.1`. Do not move any `installed` / `executable headless` cell. A spot check is not a new 350/350.

### C3 — lesson numeric and digest consistency

**Environment pairing note, dated, not silent.** `git diff -- corpus/lessons/r105-unreal-lifecycle.md` at `21:34:11Z` inserts a block headed `Environment pairing (r106, 2026-10-18)`. It keeps the `337/350` sentence as the default-env total and names the pinned receipt `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`. This seat's parse of that JSON matches the note: `pass=350`, `verdict=PASS`, `seeds_unchanged=true`. This seat's parse of the r104 default receipt matches the kept number: `pass=337`, `fail=13`, `verdict=FAIL`. **[I]** The note is the right instrument for a count that was true of one environment and is false if read as the only total. It was uncommitted at this frame.

**Historical counts were not rewritten in the eight path notes.** The notes this seat read (`r61`, `r63`, `r65`, `r66`, `r67`, `r68` in full via `rg -n`) explicitly leave `83/83`, the round's own Node suite counts, and `v26.11.1` as the review record, and they say today's `node` is `v26.12.0`. `r65`/`r66`/`r63` also say the *current* runner count is higher than the historical count (9/9 or 5/5 versus the round's 3/3 or 6/6) because later rounds added arms. That distinction is the calibration claim. This seat did not re-run those Node suites; the re-run lines inside the notes are the sweep seat's, and their evidence file was missing (C1).

**Carried receipt identity.** **[O]** The accepted pinned JSON parses as above, sha prefix `54b7140d`, 854841 bytes. **[P]** `reports/round-106/r105-receipt-carry.md`: the four durable `reports/round-105/n24/runs/` files are byte-identical to both `3634bc0` and `0cc3f41`. The r105 `reports-index.md` rerun-stdout row (`7f76f1d7…`, 10377 bytes) is the index's own mid-write snapshot, not the landed stdout (`f80d6100…`, 55282 bytes, per that seat). The index is protected this round. Queue a dated note in a later index; do not rewrite the frozen one. This seat did not re-hash the index row.

**Stamps that still match, and one that must not be quoted as frozen.** **[O]** `sha256sum corpus/lessons/r102-unreal-integration.md` → `cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2`, the same stamp `SKILL.md` §6 carries. `engines.md` sha above matches that same table. `SKILL.md` itself was byte-identical to HEAD at `21:34:11Z` (`git hash-object` MATCH). `grep -c '^| \*\*[A-F]\*\*' SKILL.md` → `6`. The r105 lifecycle lesson was dirty at the frame, so this seat does not publish a post-edit sha for it. Before that edit, `git hash-object` equalled `HEAD:` (`59ead0358a49561937c10fe1692282955ecbf54d`) and `sha256sum` was `c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729` at 162 lines — that pair is pre-note, not close.

**Fatigue ruling is queued, not applied.** **[P]** `reports/round-106/consistency/adversary.md` (SEAT-47) adopts dated notes for facts that were true at their revision (digests, counts, pass/fail) and allows a silent path-conformance fix only when the round report already records it. It rejects fatigue as a license to stop dating. It also says a living census file should carry the current value plus a one-line back-pointer, not an essay. `engines.md` still has the stale string and zero notes. L1 should pick the form before anyone appends a third essay to a 16-line census.

**P/C is unchanged and is not this round's ruling.** **[P]** `reports/round-106/pc-carry.md`: census `verified-here=0` `static-only=12` `unproven-runtime=1` `cards=13`; operator package byte-identical to the r105 commit; no ruling applied. The six dissenting cards stay `static-only`. Nothing in this report promotes a card.

## Round-level invariants and honest limits

- **Ledgers.** **[O]** At `21:34:11Z`, `git hash-object` matched `HEAD:` for `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, and `SKILL.md`. `git status --short -- reports/round-101` … `reports/round-105` printed nothing. **[P]** `reports/round-106/ledger-check.md` and `ledger-final.md` say the same, earlier in the window. A later ledger write makes those PASS lines stale.
- **SHONEN.** **[O]** `grep -c '^- \[x\]' SHONEN.md` → `1` (box 2 only). This report does not check box 1.
- **No Unreal runtime.** Editor not on `PATH` (rc 2). Gate `verified-here=0`. Unity and Unreal rows stay `installed: no` / `executable headless: no`. GLB and `.uplugin` PASSes are local static or Godot-import checks.
- **Full battery not re-run.** Default 337/350 and pinned 350/350 are carried receipts, corroborated by one-row spot checks under both states. Do not relabel either total from a one-row PASS or FAIL.
- **Moving tree.** At `21:21:33Z` non-scratch `reports/round-106` held 24 files. At `21:34:11Z` this seat's markdown inventory was 20 files and did not include this report. SEAT-59 had already recorded the tree growing 941 → 2419 files inside two minutes (`reports/round-106/r106-scribe-audit.md`). Do not quote a file count as the close.
- **`/tmp` not used by this seat.** Scratch peers used `reports/round-106/scratch/` or `mktemp -p` under `$HOME`.

## Post-frame re-check — `2026-10-18T22:08:03Z`

The `21:34:11Z` frame above is not rewritten. This seat re-ran a narrow check before handoff. The tree was still moving (tracked dirty count `49`; between `21:55:28Z` and `22:03:59Z` the `engines.md` diffstat grew). Do not treat this re-check as the close either.

```text
$ test -f reports/round-106/sweep/chunk-05.md && echo CHUNK_NOW=yes
CHUNK_NOW=yes
$ ls -l reports/round-106/sweep/chunk-05.md
-rw-r--r-- 1 vgpnk vgpnk 10862 Oct 18 18:53 reports/round-106/sweep/chunk-05.md
$ sha256sum corpus/knowledge/engines.md
055ea7df5443a7ee0ea692d9be84e86023739d3e1668adf41cfdf11b4e24c021  corpus/knowledge/engines.md
$ git diff --stat HEAD -- corpus/knowledge/engines.md
 corpus/knowledge/engines.md | 152 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 147 insertions(+), 5 deletions(-)
```

**[O]** `chunk-05.md` now exists. Its header, read this seat, is SEAT-05's chunk E over the eight `r61`–`r68` lessons. This seat did not re-hash the eight post-edit digests printed in that file. Queue item 2 is no longer "file absent"; it is "pointer landed after the draft frame, digests not re-checked here."

**[O]** `engines.md` is no longer the r102 blob. A parser of the worktree file at `22:08:03Z` printed state cells: Godot `yes`/`yes`, Unity `no`/`no`, Unreal `no`/`no`, three.js `partial`, plus a new Blender `5.2.1 LTS` row `yes` / `partial`. `v26.11.1` still occurs 6 times; the three.js installed cell now points at the correction note instead of presenting that string as the live default. This seat read the diff header, not every new receipt the census owner cites. **[I]** Existing state cells did not promote. The Blender `partial` add is a census-owner write this seat did not re-probe (`blender --version` was not run here). Queue item 1 is no longer "file untouched"; L1 still has to accept or reject that write, including whether `partial` is the right new cell.

**[O]** `git hash-object` still matched `HEAD:` for `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, and `SKILL.md`. `sha256sum corpus/fixtures/run_battery.py` was still `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `SKILL.md` §6 still stamps the pre-edit `engines.md` digest `d03907d3…`. That stamp is now stale relative to the worktree and must be re-stamped or dated at close; this seat did not edit `SKILL.md`.

## Judgment defects queued (not adjudicated)

1. At `21:34:11Z`, `engines.md` still said `Node v26.11.1` as the live parenthetical. By `22:08:03Z` a dated note and a two-state table were in the worktree, and a Blender row had been added as `partial`. L1 accepts or rejects that write. Do not promote Blender to `yes` without a new bounded battery receipt plus a non-author verifier. Do not move Unity or Unreal off `no`/`no`.
2. Eight correction notes cite `reports/round-106/sweep/chunk-05.md`. Absent at `21:34:11Z`; present at `22:08:03Z` (10862 bytes, SEAT-05 header). Re-hash the eight post-edit digests in that file before calling the pointer closed.
3. SEAT-47 S1 vs the long in-file path notes: L1 chooses whether path-conformance narration stays in the lessons or moves to the round report. This seat did not shorten them.
4. r105 `reports-index.md` rerun-stdout row is a disclosed mid-write snapshot (SEAT-113). Protected. Later index only.
5. P/C precedence remains the operator's. Census still `12/1/0`. Not applied.

## L1 close-out — fill after the work commit

**Landing commit:** `26cd9f2b6b30dc0c4ad06560c0350600dbb93cdf`

**Verdicts:** depth `{{V_DEPTH}}` · coverage `{{V_COVERAGE}}` · calibration `{{V_CALIBRATION}}`.

**C1 ruling (sweep completeness, missing chunk pointer, path-note shape):** `{{RULING_C1}}`

**C2 ruling (engines.md date-note vs state cells; carried 337/350 and 350/350):** `{{RULING_C2}}`

**C3 ruling (dated-note fatigue proposal; receipt-index mismatch):** `{{RULING_C3}}`

**Round admission:** `{{R106_ADMISSION}}` (work commit `26cd9f2b6b30dc0c4ad06560c0350600dbb93cdf`; this report lands last).

Re-measure before filling: `git diff --stat HEAD`, the eight post-edit digests in `reports/round-106/sweep/chunk-05.md`, and `sha256sum corpus/knowledge/engines.md` (worktree at `22:08:03Z` was `055ea7df5443a7ee0ea692d9be84e86023739d3e1668adf41cfdf11b4e24c021`, still dirty). A green gate and a one-row PASS do not close those three. `SKILL.md` §6 still stamps the pre-edit engines digest `d03907d3…`.

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** coverage **improved** (bounded) · depth **improved** · calibration **improved** (bounded).
The round closes as **ADMIT-with-findings (interrupted round)** — work commit
`26cd9f2b6b30dc0c4ad06560c0350600dbb93cdf`; this report lands last.

**Provider history (named per the stop rule).** The scheduled lane
(xai-oauth/grok-4.7-fast, 128 seats) exhausted its credits at 47/128. Refire #1
on cursor/grok-4.7-xhigh-fast (lane probe green) landed substantial work, then
the Cursor Pro account hit its rate limit; the swarm's automatic retries
inflated the agent count and those retries returned rate-limit payloads — they
are NOT seat completions and are not counted as work. Cursor recovery
(upgrade/wait) is operator-owned. The operator's directive to use the hyper
lane for one of the remaining deepseek-v4.1-flash rounds is recorded for r110
or an iteration-2 round.

**What verifies at close (L1-measured).** Gate PASS; manifest 12/12 rc=0;
fixtures 0 diff; `run_battery.py` `f456bd00…` stable; LOG/SCORECARD/SHONEN/
PROVINCE/SKILL untouched by seats; `AGENTS.md` added (lane ops runbook, L1-
authored). Edit mass: 85 files, +1534/−163, sample-audited — every sampled
change is a mechanical path-root fix or a dated correction/receipt note;
historical sentences preserved. A 581 MB seat scratch tree (with a stray
`.git`) was removed before commit (hygiene; no report cites it).

**Bounds (stated, not hidden).** The sweep is incomplete: several chunk seats
rate-limited before filing chunk reports, so the defect census derives from
`git diff` + samples rather than complete chunk ledgers. The consistency chunk
audits and the jolt adversary/ledger did not land; the jolt investigation
landed and rejects the flush-race explanation by contradiction (its r103
sample's raw bytes no longer exist — its own limit says so). All of it is
routed to r107's queue.

**Push.** Operator-directed: `git push origin main` after the report-last
commit (origin is the only remote — VeigaPunk/shokunin-3d-engines).
