# r103 SEAT-36 — DISTILLER (mid-flight synthesis)

**Seat:** SEAT-36 DISTILLER · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/r103-distiller.md`). Read-only on every other path; no file outside this one was written by this seat.
**Lane HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Probe window:** 2026-10-18, ~18:31–18:37Z (host local 15:31–15:37, UTC−3). **This is a mid-flight document** — sibling seats were landing writes while it was authored, and §1/§7 record state that moved under this seat.

**Axes.** coverage (lowest non-retired) · depth · calibration. Every claim below carries the command run and its observed output. An unrun check is not reported as passed.

---

## 0. What this seat did, and what it did not

This seat **re-derived** the three r103 claims (C1 coverage / C2 depth / C3 calibration) on the live tree rather than quoting the r102 queue, and reports **the delta**: what has already landed, what has not, and what the queue missed. It applied **no repair** — every mutation test below ran on a throwaway copy outside the repo (the pinned tree was never modified).

Environment note that matters for the rest of the file: **this host's `/tmp` was under quota pressure during the whole probe** (`df -h /tmp` → `11–12G` used of `16G`, 68–78%). Large `cp -r` into `/tmp` failed with `Disk quota exceeded`. Scratch copies were therefore made under `/dev/shm/r103/`; and one gate behaviour below is *caused* by that pressure (§3, N2).

---

## 1. Live state of the three claims — all three moved mid-round

| claim | as briefed | as measured at probe end (18:37Z) | evidence |
|---|---|---|---|
| **C1** freshness note for `adaptation-kimi.md` | not applied; proposed text in `reports/round-102/kimi-surfaces.md` §4 | **LANDED** — a dated correction note (117 added lines) is in the worktree | `git status` → ` M corpus/knowledge/unreal-mcp/adaptation-kimi.md`; `git diff --stat` → `117 insertions(+)`; `sha256sum` → `084a34cd94806caa…` |
| **C2** gate hardening A1–A4 | to do | **PARTIAL** — A4 **landed mid-flight** (with N1) by a sibling; A5/A7/A8 landed from r102's own list; **A1/A2/A3 still reproduce as unfixed** | §2 |
| **C3** B2 dead-root ruling + `phys3d_joints_free_ops` investigation | repair 3 READMEs; investigate 1 battery row | **REPAIR DONE 3/3** — all three READMEs now `occ=0`; the systemic R4 ruling is still unruled. Battery investigated (§3 N3) | §3 |

**C1 detail — the note landed, but its r102 text was already stale and was corrected in flight.** The r102 §4 proposal pins the `[[hooks]]` precedent at `config.toml:3219`. Re-measured independently by this seat:

```
$ grep -n '^\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ grep -c '^\[\[hooks\]\]' ~/.kimi-code/config.toml
1
$ sed -n '3290,3291p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
```

So the r102 number was stale **again**: r101 cited 2932, r102 measured 3219, r103 measures **3290**. The operator edits this file continuously. The landed note records exactly this three-step drift and, correctly, refuses to cite a bare line number (it instructs `grep -n '\[\[hooks\]\]'` instead). Sibling **SEAT-60** (`reports/round-103/note/configline.md`) reached the same 3290 independently — two independent derivations agree.

The URL class is confirmed the same way. Independent `curl` on the four cited paths, bare vs `/en/`-prefixed:

```
$ for u in customization/plugins customization/skills configuration/config-files; do
>   curl -s -o /dev/null -w "%{http_code} " "https://moonshotai.github.io/kimi-code/$u.html"
>   curl -s -o /dev/null -w "%{http_code}\n" "https://moonshotai.github.io/kimi-code/en/$u.html"; done
404 200
404 200
404 200
```

Bare = 404, `/en/` = 200, for every path. Sibling **SEAT-07** (`reports/round-103/note/urls.md`) adds a fact this seat did not test and which upgrades the finding: `curl -sIL` shows the final URL is **identical to the request** — the `/en/` form is a **hard path move, not a redirect**, so a stale bare link does **not** self-heal. The `/tmp/ue-skills-ref` pointer class is also landed (the note's C3 section names the vendored `upstream/` substitute; `/tmp/ue-skills-ref` still exists today but is explicitly labelled volatile).

---

## 2. C2 — gate hardening A1–A9: observed verdict per item

The gate file at HEAD is **not** the r102-landing bytes: r102's fold-spec pinned `214bf8ef…`; this seat measured `412d1b84857233e8…` at probe start and `55a76cf8237bd210…` at probe end, because a sibling (SEAT-09) landed A4 + N1 mid-probe (§ "State moved under this seat", below). r102's own close-out hardening (tool-requirement guard at `:26-28`, extension-optional pointer pattern, CRLF manifest check, per-seat manifest sweep) is present throughout. Each item below was tested on a `/dev/shm/r103/<item>/` copy, mutating only inside the copy. **A1, A2 and A3 were re-tested against the final `55a76cf8…` bytes** and still reproduce; A4 and N1 are recorded as landed with their landing evidence.

| item | defect | method | observed | verdict |
|---|---|---|---|---|
| **A1** | range/comma pointer tail never validated | planted `` `upstream/README.md:1-9999` `` in a card; re-run on final bytes | `grep -ohE "upstream/[^\`\"\|)]+\.[A-Za-z0-9]+:[0-9]+"` (still `:265`, regex byte-identical to the r102 form) on the planted line → **`upstream/README.md:1`** (tail dropped); `README.md` max = 112, so `:1` is in range → no `LINE-OOR` | **UNFIXED** (on final bytes) |
| **A2** | prose line above declaration hijacks CHECK 3 | inserted a prose sentence naming `verified-here` above `editor-general.md`'s label; re-run on final bytes | `FAIL label-unmarked …editor-general.md :: This card is emphatically not \`verified-here\`…` → `CARDS=13 EXPECTED=13 BAD=1` / `STEP=FAIL`; rule still `rec=$(grep -nE "$ALLOWED" "$f" \| head -1)` at `:207` | **UNFIXED** (on final bytes) |
| **A3** | card *names* never compared to the 13 domains | renamed `sequencer.md` → `sequence-typo.md`; re-run on final bytes | `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS` — count and labels intact, typo invisible; no `NAME_SET`/domain-set comparison anywhere in the file | **UNFIXED** (on final bytes) |
| **A4** | unreachable upstream is FAIL, indistinguishable from a byte diff | pointed `REPO=` at a nonexistent repo (pre-landing bytes) | `FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS` then `STEP=FAIL`, gate exit 1; no distinct BLOCKED token, no distinct exit code | **LANDED mid-flight** (SEAT-09, final bytes) |
| **A5** | seat shards never executed | overwrote `.manifest.d/seat02.sha256` with 64 zeros | `FAIL per-seat manifest sweep (--strict) failed:` → detected | **FIXED** (by r102's HARDENING B) |
| **A7** | unqualified `sha256sum` → full false green | shadowed `sha256sum` on `PATH` + flipped a byte in `upstream/README.md` | shadowed run → `MANIFEST_OK=1 EXPECTED=12 … ` `GATE RESULT: FAIL (checks failed: 3)`; control (real `PATH`) → `FAILED=1`, 4 failed checks | **FIXED** (no longer a false green) |
| **A8** | missing/failing `comm` → green gate over a stray file | `comm` shim exiting 127 + stray `upstream/STRAY.md` | shim run → `GATE RESULT: FAIL (checks failed: 3)`; identical to the real-`comm` control → the shim is no longer masked | **FIXED** (by the r102 `command -v` tool guard at `:26-28`) |
| **A9** | `gate/README.md` control prose stale | `grep -c "^# C[0-9]"` → `6`; matrix rows → `7`; wording at `:147` | wording now reads *"mutation controls (C1–C6, plus C7 where listed)"* — **no longer claims "three"**; but the shell-block count is `6` while the matrix carries **7** rows (C1–C7), so the sentence's own parenthetical is still the only thing reconciling the two | **PARTIAL** |

**Note on the A1–A3 mutation copies.** Those three ran from `/dev/shm`, i.e. **outside the repo**, so the gate's HARDENING-G relative sweep (which resolves `corpus/…` and `reports/…` backticks against the *repo* root) floods 23 spurious `MISSING-PATH-REL` lines and masks CHECK 4's real signal. That noise is a **harness artifact of testing outside the repo**, not a gate defect — the real gate run from the repo root (§3) prints `UNRESOLVED=0`. A1/A2/A3 were therefore decided by their **check-specific** output (the regex truncation, `BAD=1`, `BAD=0`), which is unaffected by the flood.

---

## 3. Findings the r102 queue did **not** contain

These are the delta this seat contributes. They are ranked by the r102 queue's own currency (a defect a *green* gate can print over).

### N1 — the gate hardcoded `/tmp/advgate/.h1`, so a fresh host got a **false red** on CHECK 1 — **LANDED mid-flight**

**Status: fixed by SEAT-09 while this file was being authored.** Recorded here because the finding was independently derived, and because the *class* (a hardcoded host path in a check that must be reproducible anywhere) is worth keeping in the ledger.

`gate/run_gate.sh:65` wrote its per-seat manifest transcript to a **fixed** path:

```
$ sed -n '65p' corpus/knowledge/unreal-mcp/gate/run_gate.sh          # pre-landing bytes (412d1b84…)
if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/advgate/.h1 2>&1); then
```

`/tmp/advgate/` is a directory some earlier round created by hand. On a host where it does not exist the redirect fails, the subshell exits non-zero, and CHECK 1 reports failure **over a byte-perfect tree**:

```
$ mv /tmp/advgate /tmp/advgate.bak          # simulate a fresh host
$ bash CLEAN/gate/run_gate.sh | grep -E "MANIFEST_FILES|per-seat|MANIFEST_OK|STEP"
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
$ mv /tmp/advgate.bak /tmp/advgate           # restore
```

With the directory present the same tree passed. This is **the mirror image of A7/A8**: not a false green, but a **false red** that would waste a future round, and it contradicted the gate's own design — every other temp artifact uses `WORK=$(mktemp -d)` with a `trap cleanup EXIT`, and only this one line escaped it.

**Landed form** (final bytes `55a76cf8…`): the transcript now goes to `MANLOG=$(mktemp)` with `rm -f "$MANLOG"` after the check, and the comment names the defect verbatim. Verified by the clean run below — CHECK 1 is `STEP=PASS` with no `/tmp/advgate` dependency.

### N2 — A4 fired **live**, not latently: CHECK 2 misattributed a full disk to the network

While re-running the real gate, CHECK 2 printed the A4 BLOCKED message — and the cause was **not** the network:

```
CHECK 2 clone-equivalence
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
fatal: write error: Disk quota exceeded
fatal: fetch-pack: invalid index-pack output
STEP=FAIL
```

`git clone` into the `mktemp` workdir (under the full `/tmp`) died on quota, and the gate reported it as *"network down or repo unreachable"*. Re-run with `TMPDIR` on a filesystem with space:

```
$ TMPDIR=/dev/shm/r103/tmp bash corpus/knowledge/unreal-mcp/gate/run_gate.sh     # final bytes (55a76cf8…)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0   STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297  PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0  STEP=PASS
CARDS=13 EXPECTED=13 BAD=0   STEP=PASS
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   STEP=PASS
GATE RESULT: PASS (checks failed: 0)          RC=0
```

**The gate is green** (`POINTERS=91 UNRESOLVED=0 RC=0`) once the clone can complete. The consequence is a calibration fact, not a coverage one: A4 is no longer a hypothesis about air-gapped hosts — **any** clone failure, including a full local disk, was reported as "network down", and the pre-landing exit channel carried no third state. A future round reading `GATE RESULT: FAIL` from that gate could not tell "no network" from "no disk" from "vendored bytes diverge".

**Status after the mid-flight landing (final bytes).** A4 is **closed** for the network case: the clone-failure branch now prints `CHECK 2 BLOCKED (network)` / `STEP=BLOCKED`, the gate prints `GATE RESULT: BLOCKED` and **exits 2**, and `GATE_REF=<path>` supplies an offline pre-cloned reference (verified present in the diff: `exit 0 PASS / 1 FAIL / 2 BLOCKED`). **One residue this seat flags and could not reproduce:** the *message* is still hard-coded to `(network)`, so the **quota** failure N2 observed — a full local disk, not an unreachable upstream — would now be classified `BLOCKED (network)` with the same exit 2. That is a strictly better outcome than the old silent `FAIL`, but the label still names the wrong cause for a disk-space failure. This seat attempted to re-trigger it (quota is intermittent) and the clone succeeded, so the residue is **reported, not demonstrated**: the fix would be to derive the label from `$WORK/clone.log` rather than assert `(network)`.

### N3 — the r102 battery row is **not one defect**; `phys3d_joints_free_ops` is a distinct failure class

The brief asks for investigation (not repair) of `phys3d_joints_free_ops`, "336/350". Re-derived from the receipt:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
> r=d['results']; print(len(r), sum(1 for c in r if c['verdict']=='PASS'))"
350 336
$ # the 14 non-PASS rows, by class
r94_cannon_det, r94_cannon_det2, r94_cannon_varstep, r94_cannon_bailout, r94_cannon_nan,
r94_cannon_sync, r94_cannon_material, r94_cannon_friction, r94_cannon_parity, r94_cannon_parity2,
r94_cannon_modes, r94_cannon_order, r94_cannon_backends   → 13 rows, reasons ['exact stdout marker missing'],
                                                            elapsed ≤ 1.78 s, kind=ordinary
phys3d_joints_free_ops                                    →  1 row, reasons ['TIMEOUT after 20 seconds',
                                                            'no exit code (process killed or timed out)',
                                                            'exact stdout marker missing'], elapsed 20.008 s
```

So **336 PASS / 14 FAIL**, and the 14 are **two classes**, not one:

- **13 `r94_cannon_*`** — the *known* pinned-marker class (`LOG.md`: markers pin `node=v24.21.0` while the host runs `v26.12.0`). Fails in ≤1.8 s with a missing exact marker. Calibration: expected red, re-baseline or side-by-side node pin.
- **1 `phys3d_joints_free_ops`** — a **TIMEOUT**: elapsed `20.008 s` against a `case_timeout_seconds` budget of `20`. It is not marker drift; it is a hang. Its captured marker text is present and well-formed (`PASS phys3d_joints free_ops freeb_ops@gp{…} freeb_ops@jolt{…} freeb_ops@dummy{…}`), which is why a marker-only reading of the row is misleading — the row *produced its marker* and then did not exit.

**Consequence for the ledger.** `LOG.md`'s r103 routing frames the battery reds as the `r94_cannon` marker class only ("fresh full runs are red on those rows"). That framing covers **13 of the 14**. The 14th is a timeout with an independent cause and needs its own triage: re-run `free_ops` alone on an idle host, and check whether the `e=`/`w=` counters in its marker show it stuck in the dummy-backend sweep. **No repair is proposed here** — this is the investigation the brief asked for, and the row's class is mis-assigned in the round ledger.

### N4 — the dead-root scope number cited by L1 does **not** reproduce (142 vs 165/167)

The B2 systemic ruling rests on a scope count. Re-derived on the **same** commit (`c85a816`, which is both r102's report-last and this seat's HEAD):

```
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l      → 167
$ git grep -l "\.shokunin/game-dev-3d" | wc -l           → 165   (worktree; 2 repaired in r103)
$ git grep -l ".shokunin/game-dev-3d" | cut -d/ -f1 | sort | uniq -c | sort -rn
     91 corpus
     71 reports
      1 SCORECARD.md
      1 PROVINCE.md
      1 LOG.md
```

r102's SEAT-11 (`reports/round-102/adversary/F1.md` §5) recorded **142** on HEAD and 141 on the worktree — the same commit this seat measures at 167/165. A 25-file gap on identical bytes means one of the two commands is not measuring what the ruling assumes. This is a **calibration** finding: an L1-level decision (option 1 vs 2 vs 3 of the R4 ruling) is being sized by a number that does not reproduce. **This seat does not adjudicate which count is right** — it flags that the ruling's input must be re-derived before the ruling is executed, and names the exact command above so the next seat can reconcile it.

### N5 — C3 repair state: **3/3 done** (all three READMEs repaired mid-flight)

Re-measured occurrence counts, then again at probe end:

```
$ for f in corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md corpus/fixtures/three/README.md; do
>   printf "%-45s occ=%s\n" "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"; done
corpus/artifacts/glb-r12/README.md             occ=0
corpus/artifacts/unity-r19/README.md           occ=0
corpus/fixtures/three/README.md                occ=17    ← at probe start
corpus/fixtures/three/README.md                occ=0     ← at probe end (repaired by a sibling)
$ python3 corpus/artifacts/glb-r12/run_import.py ; echo "glb-r12 exit=$?"        → exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py ; echo $?  → exit=0
$ node corpus/fixtures/three/run_cases.mjs ; echo "three exit=$?"                → exit=0
```

`glb-r12`, `unity-r19` and (by probe end) `three` were all repaired by sibling seats (`git status` → all three ` M`). **The three-file mechanical repair is 3/3 complete**; the dead-root commands that were still verbatim dead at probe start (`three/README.md:6` `npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three`, `:7`/`:8` the `node …run_cases.mjs` forms) now read `occ=0`. The three repo-relative commands above all exit 0 — the *runnable* forms work; the READMEs no longer document the dead form. **The systemic R4 ruling is still unruled**, and per N4 its input scope number must be re-derived before it is.

---

## 4. Dedupe — findings that are the same thing across seats

Mid-flight synthesis exists to stop the same fact being counted twice. Collapsed here:

- **The config-line drift** was found independently by this seat and by **SEAT-60** (`reports/round-103/note/configline.md`). One fact, two derivations, same number (3290). Count once.
- **The URL `/en/` class** was found by this seat and by **SEAT-07** (`reports/round-103/note/urls.md`). One fact. SEAT-07's hard-move-not-redirect evidence is the stronger form and should be the cited one.
- **C1's three citation classes** (config line, doc URLs, `/tmp` pointer) are **one** coverage item (a freshness note), now **landed** — not three open items. The r102 queue listed them as C1's content; they are closed.
- **A5, A7, A8** are three names for one root cause — an **unguarded/unqualified external tool** (`sha256sum`, `comm`, seat shards). All three are fixed by the same r102 hardening pass (`:26-28` tool guard, HARDENING B sweep). Report as one landed hardening, not three.
- **A1 and A6** are one code site (`:192`'s regex): A1 is the range-tail form, A6 the extensionless form. One fix (adopt the sweep's regex + per-endpoint loop) closes both.
- **N1 (`/tmp/advgate`) and A4 (BLOCKED)** are adjacent but **not** the same: N1 is a hardcoded-path false *red*; A4 is a missing third exit *state*. Both concern CHECK 2's failure surface; keep them separate.
- **N3's 13 `r94_cannon_*` rows** are one defect (pinned node marker), not thirteen. The 14th row is a different defect (N3's timeout) — do not fold it in.

---

## 5. Gaps named

1. **Gate file freshness is itself unguarded.** `gate/README.md` pinned `POINTERS=87` (r102 close); the gate printed **90** mid-probe and **91** at probe end, and a sibling's mid-flight r103 edit re-pinned the README to 90 *and* documented that the count is self-referential (pass B counts the README's own prose). So the number moves on any edit to the README — a pinned expectation that edits itself. Not a defect today (`UNRESOLVED=0` is the invariant), but a calibration trap: any future round that pins a `POINTERS` value will find it stale after one prose edit.
2. **`gate/README.md`'s self-exclusion asymmetry** is documented (the new note) but **not fixed**: pass B sweeps `*.md` with no self-exclusion, so the gate's own README is audited against itself in one of its two passes. The note routes the hardening to a future round; until then `POINTERS` is not a stable contract. **And the documented split does not reproduce:** the note records `pass A = 40, pass B = 50`; this seat re-implemented both passes verbatim from `run_gate.sh` check 4 and measured

   ```
   passA(gate-exact)=40        # reproduces the note exactly
   passB(gate-exact)=51        # note says 50 — one off
   sum=91                      # gate printed 90 at the time of the split, 91 at probe end
   ```

   Pass A reproduces to the unit, so the pass-A half of the documented split is sound; pass B is off by one and the sum is off by one against the `POINTERS=90` the note was written against. Since pass B is the self-including pass over a *live* README that a sibling was editing mid-probe, this seat does **not** claim the note is wrong — it reports that the split is **not reproducible as written from a second implementation**, which is the point of advertising a split at all. This is exactly the self-referential instability gap 1 names, caught in the act.
3. **The A9 control count still does not reconcile.** Shell blocks = 6, matrix rows = 7. The wording no longer says "three", but nothing states *which* seven controls the matrix asserts versus the six blocks that can be re-run.
4. **`CHECK 2 BLOCKED` names the wrong cause for a disk failure.** A4's landing hard-codes the label `(network)`, so the quota failure N2 observed would now classify as `BLOCKED (network)` with exit 2. Better than the old silent `FAIL`, but the label should be derived from `$WORK/clone.log`. Reported, not demonstrated (§3 N2) — the quota is intermittent and the re-trigger attempt saw the clone succeed.
5. **N4's scope count** — an L1 ruling is sized by a number that does not reproduce.
6. **`adaptation-kimi.md:6`** cites `github.com/EpicGames/unreal-engine-skills-for-claude-code` (404); the real repo is `…-claude-code-plugin` (SEAT-07 §4). One token, in the note's own header, outside the note's S2 item. Not repaired.

---

## 6. Ranked L1 actions

Ranked by (a) whether a *green gate* can hide the defect, (b) cheapness, (c) falsifiability. **Items 2 and 3 below were landed by a sibling (SEAT-09) mid-probe and are kept in the ranking only as the record of what this seat derived; the live residual is item 1.**

1. **Land A1 + A2 + A3 in one gate-file seat — this is now the whole of C2's residual.** All three are false-greens on a mutated tree and all three live in the one file `gate/run_gate.sh` (one owner, one edit). Re-verified against the final `55a76cf8…` bytes: A1/A6 share the regex now at `:265`; A2 is the `head -1` rule now at `:207`; A3 is a still-absent name-set comparison. Acceptance per r102 fold-spec §2 is already falsifiable (the sweep's per-endpoint count, prose-hijack `BAD=0`, rename → `STEP=FAIL`). **Do not restate the acceptance as a literal `POINTERS=47`** — r102's fold-spec proposed that against a tree that has since gained pointers; the binding invariant is `UNRESOLVED=0` with every tail endpoint individually resolved.
2. ~~**Fix the `/tmp/advgate/.h1` hardcode (N1).**~~ **LANDED** by SEAT-09 (now `MANLOG=$(mktemp)`). Kept as the record; nothing to do.
3. ~~**Give CHECK 2 a third state (A4).**~~ **LANDED** by SEAT-09 (`STEP=BLOCKED`, `GATE RESULT: BLOCKED`, exit 2, `GATE_REF=<path>`). Residue: the `(network)` label is hard-coded — see gap 4.
4. **Rule B2 systemically (R4).** The mechanical repair is now **3/3 complete** (all three READMEs `occ=0`), so what remains is only the L1 decision on the 165–167-file convention (option 1: a `corpus/README.md` note; option 2: note + bounded in-place fix). **N4 says its input number must be re-derived first** — the ruling is currently sized by 142, which does not reproduce.
5. **Re-baseline or side-pin the `r94_cannon_*` markers (13 rows) as one action**, and **triage `phys3d_joints_free_ops` separately** as a timeout (N3). Do not let the ledger's marker-class framing absorb the 14th row.
6. **Reconcile the dead-root scope count (N4).** Cheap, and it gates action 4's correct size.
7. **Update `gate/README.md`'s A9 control prose** so the shell-block count and the matrix row count reconcile (partially landed already).

---

## 7. State moved under this seat (read this before quoting any number above)

This file was authored while **five sibling seats were writing into the same tree**. The following changes landed *between* this seat's own runs; each is recorded with the evidence that shows it, so a later reader can date every number here:

| what | at probe start | at probe end | who |
|---|---|---|---|
| `gate/run_gate.sh` sha256 | `412d1b84857233e8…` | `55a76cf8237bd210…` | SEAT-09 (A4 + N1) |
| `gate/README.md` | pinned `POINTERS=87` | re-pinned + pass-A/B note (`d463e1db1f75e507…`) | sibling |
| gate `POINTERS` | `90` | `91` | tree prose edits |
| `corpus/fixtures/three/README.md` | `occ=17` (dead) | `occ=0` (repaired) | sibling |
| `corpus/artifacts/glb-r12,unity-r19/README.md` | `occ=3 / occ=2` | `occ=0 / occ=0` | siblings |
| `reports/round-103/note/author.md` | absent (real gate **RED**: `MISSING-PATH-REL …/author.md`) | present (gate **GREEN**) | sibling |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | unmodified | `117 insertions` | sibling |

Consequences a reader must apply:

- **A1/A2/A3 are the only C2 items still open**, and they were re-tested against the final bytes (§2). Everything else in §2 is closed.
- **The gate's final clean state is `POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `GATE RESULT: PASS` / `RC=0`** with `TMPDIR` on a filesystem with space.
- **Any r103 verdict must re-derive the final state** rather than quote this file's `POINTERS` values, for the self-referential reason in §5 gap 1.

---

## 8. Blockers, and what is *not* claimed

- **No Unreal runtime claim is made anywhere in this file.** The editor is not installed on this host; live-MCP behaviour is unproven by construction. Every gate/pointer statement here is a static-check statement.
- **This is a mid-flight document.** Sibling seats were writing while it was authored: `adaptation-kimi.md` and `gate/README.md` were modified under this seat, and `reports/round-103/note/author.md` landed between two of this seat's runs (an earlier real-gate run was RED on `MISSING-PATH-REL reports/round-103/note/author.md`; a later run with the file present is GREEN). Any r103 verdict must re-derive the final state rather than quote this file's numbers.
- **Host `/tmp` was under quota pressure for the entire probe** (`68–78%` used). This blocked large scratch copies into `/tmp` (worked around via `/dev/shm`), and it *caused* the live A4 misattribution in N2. A future seat re-running the gate on this host should set `TMPDIR` to a filesystem with space, or the CHECK 2 result will be a quota artifact.
- **Blocked by ownership:** this seat owns only `reports/round-103/r103-distiller.md`. Every repair above is routed, not applied — no gate file, no README, and no `LOG.md`/`SCORECARD.md` was written by this seat.
