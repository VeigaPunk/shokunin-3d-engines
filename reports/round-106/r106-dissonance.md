# r106 · SEAT-52 DISSONANCE — contradictions across r106 artifacts and vs r101–r105

**Seat:** SEAT-52 DISSONANCE · round 106 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path:** this file only. No other file was written except scratch under `reports/round-106/scratch/seat52/`. No commit, push, checkout, or reset.
**HEAD throughout:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last; work `3634bc0`).
**Window:** `2026-10-18T21:20:55Z` → `2026-10-18T22:12:57Z`. The round tree was live. `engines.md` changed identity at least four times inside the window. Every number below names the command and the frame.
**Tags:** **[O]** this seat's command/output · **[C]** peer artifact · **[?]** not resolved.
**No Unreal runtime claim.** `which UnrealEditor UnrealEditor-Cmd` at `21:20:55Z` printed both absent and exited 2; `ls /opt/UnrealEngine` was `No such file or directory`. A green gate is a static check.

## Headline

Five contradictions, plus one carry that early r106 files omit and the later consistency file names.

| id | class | one line |
|---|---|---|
| **A1** | r105 report body vs the commit that contains it | lesson / SKILL / distiller / review-3 identities in the report body are not the landed blobs |
| **A2** | r105 close and LOG vs the landed reviews | close and LOG say two REVISE; the three landed review files, and the report body, say three |
| **B1** | r104 "landed gate" vs every commit from the r104 work commit forward | content sha is `390a25ae…`, not `e5521304…`; the README still attributes `POINTERS=103` to the unpublished scanner |
| **B2** | r106 artifacts vs a file that moved under them | census seats pinned `engines.md` at `d03907d3…`; the worktree file was rewritten during this window; `SKILL.md` §6 still stamps the old sha |
| **C1** | calibration the r106 lesson note did not touch | the lesson's `2.9 s` is not the `elapsed_seconds` of the receipt it cites (`2.607`) nor the author receipt (`2.669`) |

What is **not** a new contradiction: the two-state spot checks agree with each other and with the r105 receipts; the gate's live count is `103` / `UNRESOLVED=0` on scanner `390a25ae…`; card census is still `12/1/0`. Those are in §6 so the failures are calibrated.

## 1. A1 — the r105 report quotes identities that are not in its own commit

**Side A (report body, frozen with HEAD).** `reports/round-105/r105-report.md:26` prints lesson sha `dd9b9ac064511b9cbc95cd4ebed6d62b995606dd3db069453f0ff653afefe758` and `155` lines. `:44` prints `SKILL.md` sha `f3c84fb57ccdddd909f4794e0577dab223e6cb9cf2a19d6e09b0e3afc5aaa687` and `190` lines. `:144` prints distiller `c0e3c7a486d0190b621fdd7c3519879d4cd740a2fa08e57a6de11430dc406a41` and "the latest review-3 report" as `44e48b1cf751aee9b7d4a0afb1a5567ec2cc0d8525814a5bfeeca68e5767e321`, reviewing distiller `8e572560…`.

**Side B (landed bytes).** **[O]**

```text
$ git show 0cc3f41:corpus/lessons/r105-unreal-lifecycle.md | sha256sum
c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729
$ git show 0cc3f41:corpus/lessons/r105-unreal-lifecycle.md | wc -l
162
$ git show 0cc3f41:SKILL.md | sha256sum
8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371
$ git show 0cc3f41:SKILL.md | wc -l
199
$ sha256sum reports/round-105/pc/distiller.md reports/round-105/pc/review-3.md
8e714525fa02b65e111e3e24809817eeea1a2f531ca155aa844923c24669c797  distiller.md
87575deedc62ec0733f48b315aa58d60b168a9e8432e003dc000cf3afd24d879  review-3.md
```

`git show 3634bc0:` of the lesson and of `SKILL.md` produced the same two content hashes as `0cc3f41`. `git cat-file -t` on `dd9b9ac0…`, `f3c84fb5…`, and `d089aae7` (the hash `reports/round-105/r105-dissonance.md` treated as current) all returned `fatal: Not a valid object name`. That only shows they are not git object ids; the content comparison above is the proof they are not the landed files.

`review-3.md:111` itself calls `44e48b1c…` the **prior** review-3, and its header reviews distiller `498fd04e…`, not `8e572560…`. The report's "latest" is the file's "prior".

Ruling-draft `0dc0340a…` and impact `dd5c0e98…` **do** match the live files. The runner sha `f456bd00…` matches. The defect is selective: the moving identities were pasted from a pre-close frame and not replaced when the close folded the lesson and row F.

The close section (`r105-report.md:184-188`) says the lesson's 2.9 s claim was folded to cite a receipt. It does not name the new lesson sha. A reader of the body still gets `dd9b9ac0…` / 155 lines.

## 2. A2 — two REVISE in the close, three REVISE in the files

**Side A.** `reports/round-105/r105-report.md:193` says "Three independent strong reviews landed (two REVISE)". `LOG.md:1443` says "3 independent reviews REVISE x2".

**Side B.** **[O]** Live review headers, hashed this seat:

- `review-1.md` `72435018…` line 9: **REVISE**
- `review-2.md` `4f7cfa37…` line 3: **REVISE**
- `review-3.md` `87575dee…` line 10: **REVISE**

The report **body** (`:16`, `:140-142`) already says all three current reports say REVISE. The body and the close disagree, and the close agrees with LOG against the files. **[C]** `reports/round-106/pc-carry.md:140` re-measured the same three REVISE headers. Do not cite LOG or the close sentence as the review count.

`reports/round-105/pc/distiller.md:5` correctly says none of those reviews is of the current distiller. Live distiller sha is `8e714525…`; the three reviewed hashes in the distiller's own §0 are `d337efd2…`, `7c514008…`, and `498fd04e…`. Same-hash gate still blocked. The distiller table also lists `SKILL.md` as `ae79cab1…` under "Current input identities"; both `3634bc0` and `0cc3f41` contain `8ea7ae5c…`. That row is a pre-fold frame inside the landed file.

**Resolved, do not reopen.** `reports/round-105/r105-dissonance.md:21` said `r105-report.md:128` still denied a pinned-Node full-battery pass. That sentence is not in the landed report. `rg` for `does not claim the pinned` in the report returned no hit. The close (`:179`) and the body (`:15`, `:124`) both accept the clean rerun. That mid-round contradiction was repaired before land.

**Still live, dated by a later seat.** `reports/round-105/operator-package.md:26` says "350/350 under Node 24 remains the acceptance bar and is not claimed here" and "No full Node-24 receipt was available". `:11` says `pc_reviews=0`. Both sentences are in the commit that also contains the 350/350 close and three review files. **[C]** `pc-carry.md:138-144` dates both as assembly-time text and does not treat them as current. The close (`:198`) still points at that package as the decision package without repeating the Node-section frame limit. Use `pc-carry.md`, not the package's Node paragraph, for the current reading.

## 3. B1 — `e5521304` is not the committed gate; `103` still is the live count

**Side A.** `reports/round-104/r104-report.md:514` expects the "final landed gate, `e5521304…`". `:350-356` says the suite advanced to that sha as the installed revision. `corpus/knowledge/unreal-mcp/gate/README.md:248` and `:283` still attribute `POINTERS=103` to scanner `e5521304…` and, at `:248`, to `adaptation-kimi.md` `084a34cd…`, measured at lane HEAD `88c3b2c`.

**Side B.** **[O]** Content sha of the script, not a git object id:

```text
$ git show 2ca87e8:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ git show 1eaa568:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ git show 3634bc0:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ git show 0cc3f41:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ git log --oneline -- corpus/knowledge/unreal-mcp/gate/run_gate.sh
2ca87e8 r104: …
8c9d9ad r103: …
c6f655d r102: …
```

From the r104 work commit forward, the committed script is `390a25ae…`. This seat did not re-hash `c6f655d` or `8c9d9ad`. **[C]** `reports/round-106/gate/pin-audit.md:133-142` claims those are `412d1b84…` and `577c8b54…`, and that `grep -c e5521304` on the README is 5 while `grep -c 390a25ae` is 0. This seat did not re-run that grep. Do not treat "not a git object name" as proof: a content sha256 is not a git object id. The `git show | sha256sum` comparison is the proof.

The **number** is not the contradiction. **[C]** `reports/round-106/gate/final-run.md:20` and `gate/pin-audit.md:41` both record `POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0` on `390a25ae…`. `final-run.md:20` says the summary lines matched the README expected block. That is true of the digits and false of the scanner attribution. `pin-audit.md:118-144` is the reading that keeps both facts. `gate/**` is protected this round; the provenance note is queued, not landed.

Live `adaptation-kimi.md` sha, this seat, is `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`, not the README's `084a34cd…`.

## 4. B2 — r106 census artifacts describe an `engines.md` that has since moved

**Opening frame.** **[O]** `21:20:55Z`: `sha256sum corpus/knowledge/engines.md` → `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`, `wc -l` → 16. That is the HEAD blob. The three.js installed cell said `Node v26.11.1`. Default `node --version` was `v26.12.0` via mise; the fnm prefix resolved `v24.21.0`.

**Later frames, same path, same HEAD.** **[O]**

| utc | content sha256 | lines |
|---|---|---:|
| `21:20:55Z` | `d03907d3…c3bddf` | 16 |
| `21:42:42Z` | `62a70d04…3af19d` | (not counted) |
| `21:58:22Z` | `149e61cf…7bffba` | 122 |
| `22:01:14Z` | `055ea7df…24c021` | 158 |
| `22:12:57Z` | `501b30df…21f933` | 166 |

At `22:12:57Z` the state cells were still Godot `yes`/`yes`, Unity `no`/`no`, Unreal `no`/`no`, three.js `partial`, and the two-state table still said default `v26.12.0` / pinned `v24.21.0`. Line numbers moved between the `21:58` read and the `22:12` read (the default-state row was line 26, then line 22). Do not cite an `engines.md` line number from this report.

**Peers that pinned the opening sha, and are therefore not a description of the worktree at close of this window:**

- **[C]** `reports/round-106/engine-count.md:28,195` — sha `d03907d3…`, "Not a rewrite of `engines.md`". True at its write. False as a current-state sentence.
- **[C]** `reports/round-106/census/verify.md:9,23` — same sha, drift on `v26.11.1` "queued, not fixed".
- **[C]** `reports/round-106/consistency.md` worktree section — at `21:40:08Z` its `git diff` of `engines.md` was empty, and it says not to treat the stale host string as a reopen. By `22:12:57Z` the file is a 166-line rewrite with a dated correction note. The consistency register is a frame, not the close reading of `engines.md`.

`SKILL.md` §6 still stamps `engines.md` at `d03907d3…`. `SKILL.md` is protected. The census file's own judgment queue says that stamp is stale once the edit lands. That sentence was present at the `21:58` read. Re-hash before acting on the §6 stamp. State cells did not move; the contradiction is identity and citation, not a promotion.

**[O]** The r104 default-env receipt the census cites, `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`, parses to `verdict=FAIL`, `cases=350 pass=337 fail=13`, `seeds_unchanged=true`. That half of the two-state table matches the file on disk.

## 5. C1 — `2.9 s` is not the receipt field

**[O]** `corpus/live/runs/20261018T201215739340Z/verdicts.json` parses to `verdict=FAIL`, `pass=337 fail=13`, `seeds_unchanged=true`. Row `phys3d_joints_free_ops` is `PASS`, `elapsed_seconds=2.607`. The author one-row receipt `reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json` has the same row at `2.669`. `reports/round-104/r104-report.md:579` says `2.669 s` / `2.768 s`. `LOG.md` rounds the repair to `2.9s`. The lesson sentence that cites the `201215` receipt still says **2.9 s PASS**.

The r106 edit of that lesson is a dated note, not a silent rewrite. **[O]** `git diff HEAD -- corpus/lessons/r105-unreal-lifecycle.md` at the window was `14 +++++++++++++-`: it keeps the 2.9 s sentence and adds "Environment pairing (r106, 2026-10-18)" binding `337/350` to default mise `v26.12.0` and `350/350` to the pinned rerun. Worktree lesson sha at `22:01:14Z` was `c4aa80ec…`, 174 lines, against committed `c7f6a27f…`, 162 lines. The note fixes the environment pairing. It does not fix the 2.9 s figure.

## 6. What reproduces (so the failures are calibrated)

These r106 artifacts agree with each other and with the r105 receipts. They are not contradictions.

- **Two-state spot checks.** **[C]** `battery-default-quick.md` — default `r94_cannon_nan` FAIL, marker missing, Node `v26.12.0`, and `phys3d_joints_free_ops` PASS. `pinned-quick.md` — pinned `r94_cannon_nan` PASS, token `v24.21.0`. `census/cannon.md` — pinned `r94_cannon_det` PASS. `census/phys3d-joints.md` — both free rows PASS on the default path, case elapsed `2.765` / `2.774`. None of them claims a new 350-row run.
- **three.js.** **[C]** `census/three-default.md` 3/3 and 5/5 under `v26.12.0`. `census/three-pinned.md` says the same suites' stdout is byte-identical under `v24.21.0`. `partial` does not move. Agrees with the census state cell.
- **Gate digits.** **[C]** `gate/final-run.md`, `gate/blocked-check.md`, `gate/flake-rerun.md` (36/36 PASS), and `gate/pin-audit.md` all print `POINTERS=103 UNRESOLVED=0` on `390a25ae…`, pin `a6aa73ad…`, census `12/1/0`. `blocked-check.md` N1 is exit 2 BLOCKED (network); N2 is exit 1 FAIL on a missing `GATE_REF`. That pair does not exercise mixed BLOCKED+FAIL.
- **Receipts unmodified.** **[C]** `r105-receipt-carry.md` — four durable N24 files byte-identical to `3634bc0` and `0cc3f41`. Index row `7f76f1d7…` / 10377 bytes is the index's own mid-write frame; post-close identity is `n24/receipts.md` (`f80d6100…` stdout, `54b7140d…` JSON). The report body's `54b7140d…` matches that JSON.
- **r22 pair.** **[C]** `r22-regression.md` accept and reject both exit 0, and the crossed expectations exit 1. Matches `SKILL.md` row E's pasted strings.
- **P/C not applied.** **[O]** `test -f corpus/knowledge/unreal-mcp/label-precedence.md` → rc 1. **[O]** `rg -l 'Not \`unproven-runtime\`' corpus/knowledge/unreal-mcp/executability` → 6 files. **[C]** `pc-carry.md` census `12/1/0`, package bytes `differ=0`.

`command -v` absence is rc 1 (`engine-count.md`); `which` absence is rc 2 (this seat). Those are different commands. Both are absence. Not a contradiction.

## 7. Carries — named, or absent from the files on disk

`reports/round-106/consistency.md` exists (close stamp `consist_rc=0`) and its still-open paragraph names the load-bearing items: P/C, mixed BLOCKED+FAIL (`run_gate.sh:436-442`, this seat read the same exit block — exit 2 only when `C2_BLOCKED=1 && FAILS=0`), attack suite unbound to `390a25ae…`, README scanner `e5521304…`, gate harness / IP-2, C7 command, partial-pass sentence at README `:292`, fixture write-isolation, `mode_ok` not checked before `quit(0)`, empty-jolt, default Node marker mismatch, SKILL scan scope, systemic `.shokunin` ruling, no Unreal Editor. This seat confirmed the `mode_ok` half: `phys3d_joints.gd:118-120` prints PASS and `quit(0)`; `mode_ok` is a marker field at `:202-204`, not a fail-closed guard. **[O]**

That is a carry, not a drop, **once consistency.md is in the tree**. It was a drop relative to the earlier r106 set: at `21:22Z` a scan of r106 markdown outside `scratch/` and `runs/` found `mode_ok` in 0 files, `write-isolation` in 0, `empty-jolt` in 0, `e5521304` in 0. Those names arrived with `consistency.md` and `gate/pin-audit.md`. A reader of only the census and gate-final files would miss them.

**Absent at `22:01:14Z`:** `reports/round-106/jolt/investigate.md` (`jolt_rc=1`). `r106-scribe-audit.md:79` uses `jolt` as an empty directory name, not as the investigation. consistency.md carries the curiosity as unexplained. Do not mark it investigated because a directory exists.

**Not adopted.** consistency.md:4 says "Nothing is dropped." This seat did not re-count its register. The spot-check above is the load-bearing set only.

## 8. Limits

This file is a frame, not an axis verdict and not an operator ruling. `engines.md` was still being rewritten at `22:12:57Z` (`501b30df…`, 166 lines); a later census edit can supersede the sha table in §4 without changing the state cells. Non-scratch r106 markdown count at `22:01:14Z` was 55 and was still growing. No Unreal Editor was run. The only path this seat intends as a deliverable is this file.
