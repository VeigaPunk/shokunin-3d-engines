# r105 round report — lifecycle lesson, Node profile, P/C package

- **Seat:** SEAT-42 REPORT-DRAFT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Round:** 105 · **Axes:** depth / coverage / calibration
- **Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- **Landing commit:** `3634bc0748f2ae1e02e20571874b39a3f3705daa` — L1 fills this at close; this report is intended to land last.
- **Report base HEAD:** `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b` (`git rev-parse HEAD`, observed 2026-10-18T20:34:58Z).
**Status at that frame:** `git status --short` showed `M SKILL.md`, `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`, `?? corpus/lessons/r105-unreal-lifecycle.md`, and `?? reports/round-105/`. The worktree continued moving; this is a frame, not the round-close revision.

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown or not yet measured. A green or in-progress run is not reported as a completed result.

## Summary at the last evidence frame

- **C1 (coverage) — partial.** The lifecycle lesson, one-line Kimi URL correction, and `SKILL.md` row F are present. The lesson's scope audit found semantic gate/evidence-auditing bleed; the row-F critic recommends mandatory named non-author replay. Neither issue is silently adjudicated here.
- **C2 (depth) — accepted for the pinned profile.** The clean Node 24.21.0 rerun passed 350/350 rows with `seeds_unchanged=true` across 131 files and the unchanged runner digest; matching JSON receipts are copied under `reports/round-105/n24/runs/`, alongside the runbook. The first run's seed-guard failure is separately documented and not counted as the passing receipt.
- **C3 (calibration) — proposed, not ruled.** Three independent r105 reviews exist, and all three current reports say REVISE; review-3's earlier conditional-accept-for-discussion wording concerned an older snapshot. All three target older distiller revisions, so none reviews the current proposal pair; the same-hash gate and precedence ruling remain open. The three r104 reviews are historical, not votes on this proposal; byte-pinned sources remain unchanged.

## Work performed and evidence

### C1 — lifecycle lesson, Kimi URL fold, fixture-runtime row

**Lifecycle lesson.** `corpus/lessons/r105-unreal-lifecycle.md` distills a pin → vendor → gate → harden → repair lifecycle from r101–r104 LAWS. The lesson itself states that it makes no new Unreal-runtime claim. Its identity and line count were recorded by SEAT-54:

```text
$ sha256sum corpus/lessons/r105-unreal-lifecycle.md && wc -l corpus/lessons/r105-unreal-lifecycle.md
dd9b9ac064511b9cbc95cd4ebed6d62b995606dd3db069453f0ff653afefe758  corpus/lessons/r105-unreal-lifecycle.md
155 corpus/lessons/r105-unreal-lifecycle.md
```

The semantic scope review is a material counter-signal, not a keyword false positive. `reports/round-105/lesson/bleed.md` reports zero lexical hits for its lore/2D/harness-identifier scan, then compares the lesson's gate/scanner/adversarial-control substance with `PROVINCE.md` and rules **FAIL (semantic harness/evidence-audit bleed)**. It recommends rerouting or re-scoping. **[I]** The lesson exists, but its in-province status is unresolved; the L1 should rule before calling this an unqualified coverage gain.

**Kimi 404 URL fold.** `corpus/knowledge/unreal-mcp/adaptation-kimi.md:6` now points at the repository URL with the `-plugin` suffix. The author ran:

```sh
curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
```

Observed `200`. SEAT-05 independently ran `curl -sI` against old and corrected URLs and observed `HTTP/2 404` / `HTTP/2 200`; its `git diff --numstat` was `1 1`, `git diff --check` emitted no errors, and the unified-zero diff was only the one URL replacement. The correction leaves the r103 dated correction note as historical evidence; the upstream pin remains `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

**`SKILL.md` row F.** The table now includes a sixth row for a lane fixture runtime result. The row limits `verified-here` to a saved, bounded receipt for that fixture run, explicitly does not promote an engine-census row, and requires the invocation, receipt, timeout, and seed digests. The current artifact frame was measured directly:

```text
$ sha256sum SKILL.md; wc -l SKILL.md; grep -c '^| \*\*[A-F]\*\*' SKILL.md; git diff --check -- SKILL.md
f3c84fb57ccdddd909f4794e0577dab223e6cb9cf2a19d6e09b0e3afc5aaa687  SKILL.md
190 SKILL.md
6
```

`git diff --check` emitted no errors. The diff also narrows the table heading and scope to Unreal-content **and lane-fixture** claims. SEAT-08's `reports/round-105/skill6/critic.md` recommends **REVISE unless row F requires a named non-author rerun and a verifier-owned durable report/receipt**; it notes that this verifies reproducibility of lane-authored checks, not an independent oracle for engine truth. SEAT-55's scope-only review (`skill6/bleed.md`) rules row F in-province because `PROVINCE.md` includes executable headless 3D fixtures. Therefore the row's domain scope is supported, but its independence requirement remains a review issue.

### C2 — pinned Node environment matrix

**The marker mismatch is a runtime-selection result, not a fixture edit.** My read-only checks observed:

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

A read-only AST count returned `CASES rows: 350`. SEAT-12's default-profile probe of `r94_cannon_nan` records `FAIL`, expected and actual process exit both 0, and `reasons=['exact stdout marker missing']`; its receipt extraction showed expected marker `node=v24.21.0` versus actual `node=v26.12.0`. The r105 single-row confirmation independently measured the same case failing on default Node and passing under the prefixed Node 24.21.0 PATH, with `seeds_unchanged=true` in both JSON receipts. My direct read of `corpus/live/runs/20261018T202715395926Z/verdicts.json` observed `cases=1`, `PASS=1`, and `r94_cannon_nan` = `PASS`, exit 0, reasons empty. This is a one-case receipt only.

The default-profile **full** comparator remains the r104 run: `337/350`, with the 13 cannon marker failures. SEAT-15's r105 adversary says not to relabel that result as a default-profile pass. It also records that 19 `r94_cannon_*` rows comprise 13 Node-pinned positive rows and six negative controls; the full acceptance applies to the complete battery, not an assumed uniform cannon prefix.

SEAT-11 supplied `reports/round-105/n24/runbook.md` and `corpus/fixtures/PINNED-ENV.md`. The runbook scopes the override to one command and reports the exact expected executable/version. The accompanying doc says the standard runner writes JSON below ignored `corpus/live/runs/<timestamp>/` by default and distinguishes the one-case probe from a full run. `ls reports/round-105/n24/runs` now returns two run `.stdout` files and their two copied `.verdicts.json` receipts.

The first completed command was:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py > reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout 2>&1
```

Its stdout had **705** lines and ended:

```text
totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0
FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T202944290389Z/verdicts.json
```

I read the first copied receipt with:

```sh
python3 -c 'import json; d=json.load(open("reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json")); print("first verdict="+d["verdict"]+" totals="+str(d["totals"])+" seeds_unchanged="+str(d["seeds_unchanged"])+" seed_files="+str(len(d["seed_digests"])))'
```

Observed: `first verdict=FAIL totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59} seeds_unchanged=False seed_files=130`. `sha256sum corpus/fixtures/run_battery.py` returned `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. The seed guard's `seed_digests()` includes fixture files (runner lines 940–946). I compared the receipt's `seed_digests` to current fixture files with:

```sh
python3 -c 'import hashlib,json,pathlib; r=pathlib.Path("corpus/fixtures"); d=json.load(open("corpus/live/runs/20261018T202944290389Z/verdicts.json")); cur={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(r.rglob("*")) if p.is_file() and "__pycache__" not in p.parts and p.relative_to(r).parts[0]!="three"}; b=d["seed_digests"]; diff=[(k,b.get(k),cur.get(k)) for k in sorted(set(b)|set(cur)) if b.get(k)!=cur.get(k)]; print("snapshot=%d current=%d diffs=%d"%(len(b),len(cur),len(diff))); print(diff)'
```

Output: `snapshot=130 current=131 diffs=1` and `[('PINNED-ENV.md', None, '90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f')]`. `stat -c '%n %y' corpus/fixtures/PINNED-ENV.md` returned mtime `2026-10-18 17:35:35.666705142 -0300` (20:35:35Z), after the receipt's 20:29:44Z start. **[I]** This declared companion documentation file appeared during the first run and explains its seed-guard failure; it is not fixture code.

The second run used the same process-scoped Node 24.21.0 prefix:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py > reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout 2>&1
```

Its stdout ended:

```text
totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T204240718894Z/verdicts.json
```

I inspected the copied JSON using:

```sh
python3 -c 'import json; d=json.load(open("reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json")); print("rerun verdict="+d["verdict"]+" totals="+str(d["totals"])+" seeds_unchanged="+str(d["seeds_unchanged"])+" seed_files="+str(len(d["seed_digests"]))+" runner_sha256="+d["seed_digests"]["run_battery.py"])'
```

Observed: `rerun verdict=PASS totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59} seeds_unchanged=True seed_files=131 runner_sha256=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. The `r94_cannon_nan` marker is `PASS r94_cannon nan node=v24.21.0`. I checked the durable copy with:

```sh
sha256sum corpus/live/runs/20261018T204240718894Z/verdicts.json reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
cmp -s corpus/live/runs/20261018T204240718894Z/verdicts.json reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
```

Both hashes were `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`; `cmp -s` returned 0. This completes the 350/350 pinned-profile battery with unchanged seed files, unchanged runner digest, a durable report-directory receipt, and the runbook. It does not change the separate default-Node r104 result of 337/350.

**Mutation boundary.** `git diff --name-only HEAD -- corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability` emitted no paths; `git status --short --` the same scope returned only `?? corpus/fixtures/PINNED-ENV.md`. SEAT-11 states no fixture code or environment configuration changed, and `n24/revert.md` confirms default `node` remained `v26.12.0` after the process-scoped override. The fixture code remains read-only; the doc addition is not a fixture-code change.

### C3 — P/C precedence: evidence and proposal, not a ruling

`reports/round-105/pc/history.md` traces F7 from r101 through r104 and gives the fresh r105 measurement: six cards still reject `unproven-runtime`; `corpus/knowledge/unreal-mcp/README.md` remains at SHA-256 `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`; the current card census is 13 total (`static-only=12`, `unproven-runtime=1`). Its recorded current-tree command `git status --short -- <README, executability, SKILL.md>` emitted no output and `git diff --quiet HEAD -- <same paths>` returned 0.

The package currently contains:

- `pc/cards.md`: extracts the six cards' distinct arguments and the `actors-scene.md` counterexample, with the extraction command and excerpts.
- `pc/analyst-1.md`: argues for the README's direct runtime-claim predicate even when a concrete tool path is not yet identified.
- `pc/analyst-2.md`: argues card-first; retain `static-only` on a mixed-evidence card when its runtime path is unidentified, with runtime behavior still binary `unproven`.
- `pc/ruling-draft.md`: proposes Option P with an identified-operation threshold, plus impact and amendment sets; it is not an adopted ruling.
- `pc/ledger.md`: keeps both operator branches visible, records the current census/gate baseline, and prescribes three independent reviews of the same proposal/diff hash before a final amendment set.
- `pc/distiller.md`: recommends P-narrow with a three-part path test, a candidate `13/0/0` census, and a nine-item falsifiable amendment set. It synthesizes three independent r104 reviews, which are historical inputs, **not** r105 votes, and incorporates the three r105 review reports. Its current status says those reviews examined different earlier packet snapshots and none reviewed this distiller revision.
- `pc/review-1.md` (SEAT-24): verdict **REVISE**; requires an operational “identified operation” test, consistent branch/impact, and a frozen review identity.
- `pc/review-2.md` (SEAT-25): verdict **REVISE** on the proposal hashes current at that review; flags inconsistent impacts and an unproven 13-card census.
- `pc/review-3.md` (SEAT-26): latest verdict **REVISE**; identifies likely qualifying Sequencer/Testing routes and says the proposed 13/0/0 census cannot be accepted without the full audit. Its earlier report version conditionally accepted P-narrow for discussion only, not implementation.

The proposal remains unresolved: analyst-1 applies the README's literal runtime-claim predicate even when a route is unknown; analyst-2 retains the whole-card `static-only` label for documentary findings; the ruling draft recommends path-qualified P while preserving 12/1/0; the current distiller proposes P-narrow with 13/0/0. The latest measurement found `ruling-draft.md=0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30` and `distiller.md=c0e3c7a486d0190b621fdd7c3519879d4cd740a2fa08e57a6de11430dc406a41`. Review-1 records the current ruling hash and distiller hash `d337efd2dd32bd853e91497b5e08b51ffc48c7ff695a01af9ecec2914df55e24`; review-2 records the same ruling hash and distiller hash `7c51400847eb6a203df241f2e7869b325ecb51fcc0f0d6a93e928f44a7e12cf7`. The latest review-3 report (SHA-256 `44e48b1cf751aee9b7d4a0afb1a5567ec2cc0d8525814a5bfeeca68e5767e321`) says it reviewed distiller hash `8e572560b999208e6de328e9dafa580a397e4ba49c77d0f7064335af20ac3d36`, the current ruling hash, and impact hash `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f`; the older review-3 version recorded distiller `890df3662f357a0a68d4e586b4690f3a375bafd465a1c196bac1191993d3b4e7` and ruling `c0d14e2e35b560ede713b426b5b98ce61beef21272b0d8725738a80df353ddb0`. Therefore, all three latest reviews target older distiller revisions, though they cite the current ruling draft. None reviews the currently measured distiller, so the three-review same-hash gate remains blocked. No precedence rule was applied; the proposal is for the operator.

The P/C sources remain unchanged in this report frame: a direct scoped status/diff check showed no changes under `corpus/knowledge/unreal-mcp/README.md` or `executability/`, nor in `upstream/` or `.manifest.d/`. The live gate evidence from SEAT-47 (`reports/round-105/gate/final-run.md`) is `GATE RESULT: PASS`, rc 0, with `POINTERS=103`, `UNRESOLVED=0`; that gate verifies declared census/path constraints, **not** semantic precedence.

## Round-level invariants and honest limits

- `reports/round-105/ledger-check.md` records all four protected root ledgers byte-identical to HEAD and no changes in reports/round-101..104: **22,105 tracked files identical, 0 differing, 0 missing**. The protected files were not written by this seat.
- The only checked `SHONEN.md` box remains box 2: my `grep -c '^- \[x\]' SHONEN.md` returned `1`. A dispatched seat cannot promote box 1; this report does not do so.
- No Unreal Editor or live Unreal runtime claim is present. SEAT-51's `install-recheck.md` found no `UnrealEditor` executable and no `:8000` listener; this remains static/headless evidence only.
- This report claims a passing pinned Node 24.21.0 full battery only on the clean rerun, not a default-Node pass; C3 remains undecided and the lifecycle lesson's in-province status remains unresolved. Re-measure moving paths at `3634bc0748f2ae1e02e20571874b39a3f3705daa`; the current HEAD was the pre-round work base.

## L1 close-out — fill after the work commit

**Verdicts:** depth `{{V_DEPTH}}` · coverage `{{V_COVERAGE}}` · calibration `{{V_CALIBRATION}}`.

**C1 ruling (lesson scope and row-F verification threshold):** `{{RULING_C1}}`

**C2 ruling (full Node 24.21.0 battery, receipt, and mutation boundary):** `{{RULING_C2}}`

**C3 ruling (P/C proposal; three-review requirement):** `{{RULING_C3}}`

**Round admission:** `{{R105_ADMISSION}}` (work commit `3634bc0748f2ae1e02e20571874b39a3f3705daa`; this report lands last).

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** coverage **improved** · depth **improved** · calibration **improved**. The round
**admits** (work commit `3634bc0748f2ae1e02e20571874b39a3f3705daa`; this report lands last).

**The node-marker story is rewritten — shadowing, not drift.** The r102–r104 routed defect
("host upgraded past the pinned node") was wrong in its mechanism: fnm has carried node
v24.21.0 all along; mise's v26 shim precedes it in PATH. Proven end-to-end this round:
same seed, same row — FAIL under the default resolution, PASS under the fnm PATH prefix
(L1 probe + SEAT-52's independent confirmation); the full battery under the pinned
environment is **350/350** with `seeds_unchanged=true` (accepted rerun receipt, durable
copy at `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`).
`corpus/fixtures/PINNED-ENV.md` carries the runbook and the two-state model; SEAT-14's
census proves exactly 13 rows embed a node pin and no other marker is env-exposed.

**Folded at close (three).** (1) SKILL.md row F per its review+critic: evidence now requires
the aggregate `PASS battery` line + `seeds_unchanged=true` + a named non-author replay
(reproducibility, not an oracle); its canonical command no longer writes receipts into the
frozen round-104 tree. (2) The r105 lesson's 2.9 s physics claim now cites its receipt
(lesson-critic's REVISE). (3) The close-receipt seat's RED on C2 was scored against the
superseded first launch (a concurrent seat's mid-run fixture write tripped the seed
integrity check — the stray-writer hazard, second sighting); the accepted clean rerun
supersedes it, and the hazard is routed as a fixture write-isolation proposal.

**P/C package — complete, and deliberately not applied.** Three independent strong reviews
landed (two REVISE), the distiller's amendment set is folded into the proposal, and the
operator queue (`reports/round-105/pc/ledger.md`) names what lands under either ruling
with acceptance commands. The byte-pinned subtree was not touched; the ruling belongs to
the operator. `reports/round-105/operator-package.md` assembles the one-page decision
package.

**Process defect recorded.** A verifier ran `git checkout` inside an isolated `/dev/shm`
clone (self-disclosed; the lane worktree was never switched). Permissible in effect, and
the templates now say "no checkout anywhere" to remove the ambiguity.

**Honest limits.** Reviews scored against moving proposal hashes (distiller-recorded);
the P/C ruling remains open by design; the empty-jolt-cells curiosity from r103 remains
uninvestigated; no live-editor claim exists anywhere — `verified-here` on Unreal surfaces
stays impossible by construction.
