# r107-crit-scope.md — contest check: scope absorption + PROVINCE claim impact (seat KEY=CRIT-SCOPE)

Round 107 · lane `game-dev-3d-shokunin` · branch `main` · 2026-10-19. Labels: **[O]** observed here
with command, **[I]** inference, **[?]** unknown. Nothing below is inherited from a peer shard
without a command; peer claims are cited as peer claims.

## Plan (5 lines)

1. Inventory every round-107 shard/mutation for scope language that reads as 2D-lane, revenger/REA,
   harness-integrity, lore, or other-lane work.
2. Read 2D-lane PROVINCE.md (read-only) and diff its "owns" surface against anything the side-round
   actually produced (files, commands, claims).
3. Read the fresh pin delta (r107-pindelta.md, r107-VENDOR-*, r107-PROVENANCE-draft.md) and test each
   3D PROVINCE claim against it.
4. Ruling per finding: ABSORBED / NOT-ABSORBED / CONTESTED, with exact citation (file:line or
   command+output), labelled [O]/[I]/[?].
5. No writes outside reports/round-107/; shard < 400 lines.

---

## 0. Headline rulings

| # | question | ruling | strength |
|---|---|---|---|
| **A** | Does anything in the side-round absorb 2D-lane or other-lane scope? | **NO — not absorbed.** One hygiene finding (shard placement drift, self-corrected); zero other-lane product surface touched; closest call is the battery-immutability audit, ruled lane-local. | [O] |
| **B** | Does the fresh pin change any 3D-lane PROVINCE claim? | **NO — and it cannot.** There is **no fresh pin**: upstream `main` still resolves to `a6aa73ad…`, zero-commit delta. Independently, `PROVINCE.md` makes no claim about the plugin repo, so no pin move could change one. | [O] + [I] |
| **C** | Is the real delta (out-of-pin PR surface) a PROVINCE matter? | **NO.** It is a `PROVENANCE.md` §8 refresh, not a province claim. | [O] |

---

## A. Scope-absorption check

### A1. Write surface — 3D lane

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin && git status --porcelain -uall
?? reports/round-107/mutations/…   (8 artifacts)
?? reports/round-107/r107-*.md     (31 shards)
$ git status --porcelain -uall | wc -l
39
```

**[O]** Every untracked path is under `reports/round-107/`. Nothing outside it. Later re-census
(00:09) → 41 shards, same single root.

```
$ for f in PROVINCE.md SHONEN.md SCORECARD.md LOG.md corpus/knowledge/engines.md corpus/README.md; do
    git diff --quiet HEAD -- "$f" && echo MATCH || echo MOVED; done
PROVINCE.md                              MATCH
SHONEN.md                                MATCH
SCORECARD.md                             MATCH
LOG.md                                   MATCH
corpus/knowledge/engines.md              MATCH
corpus/README.md                         MATCH
$ git diff --quiet HEAD -- corpus/knowledge/unreal-mcp && echo MATCH
MATCH
$ git diff --cached --stat          → (empty, nothing staged)
$ git rev-parse HEAD                → 3ea02ffaafc6c618bb97a19f103a3d28ecdc2638   # r106 report-last
$ git log -1 --format='%s'          → r106 report-last: verdict …
```

**[O]** The vendored subtree is byte-identical to HEAD (correct: HARD RULE 3 forbids seats landing
there; the orchestrator lands). No protected root moved. No commit was made — HEAD is still the
r106 close-out, matching `r107-scribe-report.md:23` ("no seat committed (`git log -1` still `3ea02ff`)").

### A2. Does any shard propose writes outside the lane's own subtree?

```
$ grep -rn -E "corpus/lessons|corpus/fixtures|corpus/artifacts|corpus/README" reports/round-107/*.md
r107-scribe-lesson.md:6  3. Draft `corpus/lessons/r107-unreal-revendor.md` …
r107-scribe-lesson.md:8  … never write into `corpus/knowledge/unreal-mcp/` or `corpus/lessons/` myself.
r107-scribe-report.md:81 | `corpus/lessons/r107-unreal-revendor.md` | `r107-scribe-lesson.md` | **[moving]** |
r107-sent-scope.md:4,6   … byte-hash of the frozen battery `corpus/fixtures/run_battery.py` at HEAD …
```

**[O]** Only two out-of-subtree proposals exist, both **in-lane**:

- `corpus/lessons/r107-unreal-revendor.md` — the lane's **own** lesson corpus. Each lane keeps a
  private `corpus/lessons/`; the two are not shared:
  ```
  $ ls game-dev-3d-shokunin/corpus/lessons/ | wc -l   → 94
  $ ls game-dev-2d-shokunin/corpus/lessons/ | wc -l   → 212
  $ comm -12 <(ls 3d/corpus/lessons/|sort) <(ls 2d/corpus/lessons/|sort)   → r1-headless-verification.md
  ```
  **[O]** Exactly one filename coincides (a predecessor-seed name), so the 3D lane's `corpus/lessons/`
  is its own tree — a lesson drafted there is squarely in-lane, not a 2D surface.
- Nothing proposes a change to `corpus/fixtures/`, `corpus/artifacts/`, `corpus/README.md`,
  `SCORECARD.md`, `LOG.md`, `SHONEN.md`, or `PROVINCE.md` — only *drafts* of the LOG/SCORECARD rows,
  which is the normal scribe pattern.

**[O]** `r107-scribe-report.md:85` states the boundary explicitly:
> "**Not landed by this round (explicitly):** no `SHONEN.md` box flip (protected; see §SHONEN), no
> `PROVINCE.md` edit, no fixture or `run_battery.py` edit, no `engines.md` state-cell move. The
> Unreal row in `engines.md` stays `installed: no / executable headless: no`."

### A3. Battery boundary (HARD RULE 2)

```
$ git diff --stat HEAD -- corpus/fixtures/          → (empty)
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ git rev-parse HEAD:corpus/fixtures/run_battery.py → dd2d9b74448afddb88dcf2da56008302eba8060d
$ stat -c '%y' corpus/fixtures/run_battery.py       → 2026-10-16 05:56
$ ls reports/round-107/ | grep -iE 'receipt|verdict|run|scratch'   → (no match)
```

**[O]** Fixture tree is diff-clean vs HEAD; the battery's mtime predates the round; no
receipt/verdict/run artifact exists in the round tree. **No seat edited or ran the battery.**

**[?]** This seat did not exhaustively sweep for battery execution traces outside the round tree
(e.g. under `corpus/live/`, which is gitignored). The immutability and absence-of-artifacts claims
above are what I measured; "never executed anywhere" is `r107-sent-scope.md`'s seat to close.

### A4. Closest call — does the round absorb `harness-integrity` / `gate-evidence` scope?

`PROVINCE.md:33-35` refuses *"harness/evidence auditing (harness-integrity, gate-evidence,
rlm-dispatch)"*. The round contains adversary and sentinel seats, so this needs an explicit ruling.

| seat | object it audits | ruling |
|---|---|---|
| `r107-adv1.md`, `r107-adv2.md` | the lane's **own** `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **NOT-ABSORBED** — gate hardening on the lane's own subtree, precedent-landed at r102 and hardened r103/r104 |
| `r107-rev-gate.md`, `r107-mut-gate.md`, `r107-mut-card.md`, `r107-mut-pin.md` | the same lane-owned gate + lane-owned cards/manifest, via throwaway copies | **NOT-ABSORBED** — negative controls on lane artifacts |
| `r107-sent-evid.md` | "every `reports/round-107/r107-*.md` shard" — **round artifacts only** | **NOT-ABSORBED** — round-internal evidence discipline, mandated by HARD RULE 5 |
| `r107-sent-scope.md` | round hygiene + read-only hash comparison of the frozen battery | **NOT-ABSORBED, flagged** — it *reads* the battery's bytes to assert non-mutation (HARD RULE 2 enforcement), it does not evaluate harness behavior or run it |
| `r107-crit-hygiene.md` | staleness of in-lane artifacts naming the old pin | **NOT-ABSORBED** |

**[O]** The discriminating property: every one of these audits a **lane-owned artifact** or a
**round artifact**. None audits the fleet harness, the battery's behavior, or another lane's
evidence. `harness-integrity` / `gate-evidence` / `rlm-dispatch` are fleet-level auditors over the
shared harness and battery — a different object class.

**[I] Caveat, worth the orchestrator's eye.** `r107-sent-scope.md:6` is worded as *"prove no seat
executed the battery (no run artifacts, no trace)"* — a negative existence proof over the battery.
As written it is a byte-immutability + artifact-absence check and stays lane-local. If a future
round extends it to judging the battery's *outputs or verdicts*, that crosses into `gate-evidence`
territory and should be refused. Recorded as a boundary note, not a violation.

### A5. Cross-lane surface — the 2D lane

**(a) The docker pull's cwd is the 2D lane.**

```
$ ps aux | grep -E "docker pull" | grep -v grep
vgpnk 596297 … /bin/bash -c cd '/home/vgpnk/Projects/shokunin/game-dev-2d-shokunin' && \
  nohup docker pull wukakuki/unreal-engine:dev-slim-5.8.3 > /var/tmp/ue-pull.log 2>&1 &
vgpnk 596299 … docker pull wukakuki/unreal-engine:dev-slim-5.8.3
```

**[O]** The wrapper shell's cwd is the **2D lane**; the pull's only writes are `/var/tmp/ue-pull.log`
and the docker content store — neither lane's tree. **[I]** This is *inbound* to the 3D round (it
answers the 3D unlock question), not a 2D surface being absorbed. Also recorded by
`r107-pull-watch.md:25`. The pull is **still running** at 00:10:36 (`etime 03:18`, `docker images |
grep -ci unreal` → `0`).

**(b) Shard placement drift between the two round-107 directories — hygiene finding.**

At my first observation (T1, ~00:08:5x):
```
$ ls -la game-dev-2d-shokunin/reports/round-107/
r107-planner.md
r107-pull-watch.md
mutations/{snapshot.sh, snapshot2.sh}
```
At my second observation (T2, ~00:09:45–00:10):
```
$ find game-dev-2d-shokunin/reports/round-107 -type f
reports/round-107/r107-planner.md            # mtime 00:08:32
$ ls -la game-dev-3d-shokunin/reports/round-107/r107-pull-watch.md
-rw-r--r-- … 4533 Oct 19 00:09:51 r107-pull-watch.md
$ ls -la game-dev-3d-shokunin/reports/round-107/mutations/ | grep cron
-rwxr-xr-x … 1584 Oct 19 00:09 w-cron-snapshot.sh
```

**[O]** `r107-pull-watch.md` and the snapshot script were present in the **2D** round tree at T1 and
present in the **3D** round tree at T2 (mtimes 00:09:51 / 00:09), and absent from the 2D tree at T2.

**[I]** The 3D side-round's W-CRON seat initially wrote its shard and mutation script into the 2D
lane's `reports/round-107/` and then relocated them. I did **not** observe the move itself; the
inference rests on the two snapshots above.

**[O] Impact assessment — none on scope, all on hygiene:**
```
$ cd game-dev-2d-shokunin && git status --porcelain -uall
?? reports/round-107/r107-planner.md
$ git diff --stat HEAD -- corpus/        → (empty)
$ git ls-files reports/round-107/        → (empty; nothing tracked, nothing committed)
$ git log --oneline -- reports/round-107/ → (empty)
```
The 2D lane has **no tracked round-107 file and no round-107 commit**; its `corpus/` is clean. The
relocated content was never committed. So no 2D product surface was touched or absorbed — but the
orchestrator should confirm the leftover `game-dev-2d-shokunin/reports/round-107/r107-planner.md`
(`sha256 61947ff6933bfe84425b5f6f53e77901abdb98f8691eb751ce42089d7b4667f4`, mtime 00:08:32), whose
own header reads *"SPEC-PLANNER (3D side-round, round 107)"*, is removed or re-homed by its owner.
This is a **2D-lane-owned cleanup**, not a 3D-lane write — this seat did not touch it.

**(c) Does anything produced by the round map onto the 2D lane's `Owns` line?**

2D `PROVINCE.md` owns: *"2D game production verified by executable headless fixtures — loop, input,
physics, scenes, camera, UI, levels, juice, export readiness."*

**[O]** Round-107 deliverables are: a re-vendored third-party plugin tree, 13 Unreal executability
cards, a Claude→Kimi adaptation table, a gate refresh for that subtree, and a UE-runtime unlock
evaluation. None of the nine 2D owned surfaces is touched — no fixture, no battery row, no Godot
project, no export artifact. `PROVINCE.md:36-38` (3D) refuses *"2D production scope (game-dev-2d —
shared fixture patterns are inherited, 2D product surfaces are not)"*; **no shared-fixture
inheritance occurred either** (A3: fixture tree diff-clean).

### A6. Positive scope fit (why the round is in-province, not adjacent to it)

**[O]** `PROVINCE.md:7` names **Unreal Engine** in the lane's owned engine list. `PROVINCE.md:18-22`
authorizes exactly this artifact class: *"Where an engine cannot execute headless on this host, the
lane builds format-level and static fixtures (scene/asset containers, projection math, serialization
round-trips, REA inspection) and labels runtime behavior unproven."* The vendored subtree + cards +
gate is that clause executed; the unlock seat is the attempt to escape it.

**[O]** Consistent with the r101 finding (`r101-connector.md:323`: the subtree *"lands inside the
province's stated method rather than at its edge"*) — re-confirmed here, not changed.

---

## B. PROVINCE claim impact of the "fresh pin"

### B1. There is no fresh pin

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main        rc=0
$ git clone --depth 50 <url> /var/tmp/r107-crit-scope/remote && git -C … rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C … rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959
$ git -C … ls-files | wc -l          → 12
$ cat …/.claude-plugin/plugin.json | jq -r .version   → 3.1.1
$ diff -rq /var/tmp/r107-crit-scope/remote corpus/knowledge/unreal-mcp/upstream --exclude=.git
rc=0                                   # no output — byte-identical
```

**[O]** Fresh clone HEAD = `refs/heads/main` = the r101 pin `a6aa73ad…`; tree `b5b9624b…`; 12 tracked
files; plugin version still `3.1.1`; the vendored tree is byte-identical to it. HEAD commit date
`2026-09-17 13:28:32 +1200` — **upstream has not moved since r101.**

**[O]** Independent agreement: `r107-verify.md:16` ("the 'fresh pin' is the r101 pin"),
`r107-pindelta.md:11` ("**Verdict: THERE IS NO PIN DELTA**"),
`r107-rev-pin.md:19` ("pin CONFIRMED by 4 independent transports; vendored tree byte-identical").

### B2. Claim-by-claim test — every pin-sensitive artifact

| artifact | claim | does a "fresh pin" change it? |
|---|---|---|
| `corpus/knowledge/engines.md:44` | Unreal row cites pin `a6aa73ad…` and `sha256sum -c .manifest.d/audit-reference.sha256` → 12× OK | **No** [O] — same pin, same bytes |
| `gate/run_gate.sh:73,75-80` | `PIN=a6aa73ad…`, `EXPECTED_MANIFEST_OK=12`, `EXPECTED_TRACKED=12`, census `12/1/0` | **No** [O] — constants still correct |
| `PROVENANCE.md` §1/§2 | pin row, 12-file hash table, plugin version `3.1.1` | **No** [O] — all rows unchanged; only the *fetch date* row would refresh (that is `r107-crit-hygiene.md`'s stale-soft class) |
| 13 `executability/` cards | per-subsystem verdicts derived from pinned bytes | **No** [O] — same bytes |
| `adaptation-kimi.md` | rows anchored on the pinned tree | **No** [O] — same bytes |

**[I]** Since no artifact's pin-derived value moves, a re-vendor at this pin is a *re-derivation*, not
a content change. The round's value is independent confirmation (4 transports), as
`r107-verify.md:27` states.

### B3. Does any `PROVINCE.md` claim depend on the pin?

**[O]** `PROVINCE.md` (46 lines, read in full) contains **no** pin, hash, file count, or plugin-repo
claim. Its only Unreal content:

- `:7` — engine list *"Godot, Unity, Unreal Engine, three.js"*. Pin-independent.
- `:15-17` — *"The standing host fact at mint: Godot 4.7.2 headless is installed and is the
  executable runtime; Unity and Unreal editors are not installed"*. **Explicitly scoped "at mint"**,
  and pin-independent — the pinned repo is a *plugin*, not the engine; no pin move can install an
  engine.

**[I]** Therefore **no pin change, fresh or otherwise, can change a `PROVINCE.md` claim by
construction.** This holds even in the counterfactual where upstream had moved.

### B4. Falsification attempt — is the "Unreal not installed" host fact still true?

```
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool ; echo rc=$?
rc=1                                     # no output — none on PATH
$ ss -ltn | grep -c ':8000'              → 0
$ command -v godot && godot --version
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
$ docker images | grep -ci unreal        → 0
$ ps -p 596299 -o etime=                 → 03:18   (pull still running)
```

**[O]** Unreal editor/build binaries absent; no MCP endpoint; **no UE image in the local store**;
godot 4.7.2 present as claimed. The round's docker unlock attempt **has not succeeded**, so the
standing host fact is **corroborated, not falsified**, at `2026-10-19T00:10:36-03:00`. This matches
`engines.md:44` (*"editor absent (r106)"*) and `r107-scribe-report.md:85` (*"The Unreal row in
`engines.md` stays `installed: no / executable headless: no`"*).

**[?] Contingency for the orchestrator (not a claim of mine).** If the pull completes before close
and a bounded probe runs, the affected artifact is the **`engines.md` census row** — and only
under that file's own rule: *"an engine row may move to 'executable headless' only with a saved…"*
(engines.md, Rules). An image *present in the store* is not *executable headless*; a successful
bounded probe is required. **`PROVINCE.md` would still need no edit**, because its sentence is
scoped "at mint" and its engine list is unchanged either way. This seat asserts no unlock result —
that is the UNLOCK seats' label to land.

---

## C. The real delta is out-of-pin, and it is not a province matter

**[O]** `r107-pindelta.md:141-180`: six open PRs now advertised (`refs/pull/{1,2,4,5,8,9}`), of which
**PR 5, 8, 9 are new since r101** (r101 §8 recorded only PRs 1 and 4). PR 8 (`Add an OpenCode port`,
15 files, +959/−10) and PR 9 (`Document 5.8.3 toolset quirks, bump to 3.1.2`, 3 files, +9/−2), both
by non-Epic contributors, both **open and unmerged** — `main` unchanged.

**[O]** Ruling: this belongs to `PROVENANCE.md` §8 (*"Known out-of-pin upstream surface (recorded,
not vendored)"*), whose r101 text is now a **stale snapshot** (it lists PRs 1 and 4 only).
`PROVINCE.md` claims nothing about out-of-pin surface → **no province impact**.

**[I]** One coherence note, for the orchestrator, not a scope issue: PR 9's subject is *"Document
5.8.3 toolset quirks"*, and the docker image under pull is tagged `dev-slim-5.8.3` — the same engine
version. Both `r107-pindelta.md:281` and `r107-pull-watch.md` record the coincidence. It means the
unmerged PR 9 is *about* the runtime the unlock seat is trying to obtain; it does not license
vendoring PR 9 (out-of-pin), and it does not change any PROVINCE claim.

---

## D. Contest ledger

| # | contest | ruling | evidence |
|---|---|---|---|
| D1 | 2D product surfaces (loop/input/physics/scenes/camera/UI/levels/juice/export) absorbed? | **NOT-ABSORBED** | [O] A5(c); fixture tree diff-clean (A3) |
| D2 | 2D shared-fixture patterns inherited? | **NOT-ABSORBED** | [O] A3 — `git diff --stat HEAD -- corpus/fixtures/` empty |
| D3 | Writes into the 2D lane or a sibling? | **NOT-ABSORBED** | [O] A5(b) — 2D repo clean but for one untracked leftover; no round-107 commit in 2D |
| D4 | `harness-integrity` / `gate-evidence` / `rlm-dispatch` auditing absorbed? | **NOT-ABSORBED (flagged)** | [O] A4 — all adversary/sentinel seats audit lane-owned or round artifacts; see the A4 caveat |
| D5 | revenger / REA live-target scope absorbed? | **NOT-ABSORBED** | [O] the round's static inspection is confined to `corpus/knowledge/unreal-mcp/**`; **no REA package was run** and no live target was touched by any seat. The single REA string in the round (`r107-kimi-adapt.md:232`, `args = [ "-y", "rea-agents@6.7.0", "mcp" ]`) is a **quoted line of the host's own `~/.kimi-code/config.toml`** produced by `sed -n '3544,3548p'` while documenting that `[mcp_servers.*]` is ignored by the v2 engine — a config-surface observation, not a REA invocation |
| D6 | lore / narrative canon absorbed? | **NOT-ABSORBED** | [O] no lore artifact, no canon file referenced in any round-107 shard; the only `canonical` hit is `r107-mut-pin.md:59` using the word about a byte mutation |
| D7 | Any `PROVINCE.md` claim changed by the fresh pin? | **NO CHANGE** | [O] B1 (no fresh pin) + [I] B3 (no pin-dependent claim exists) |
| D8 | Any `engines.md` Unreal state cell moved? | **NO** | [O] B4 — no image, no editor binary, pull incomplete |
| D9 | Shard/script placement drift between lane round-107 dirs | **HYGIENE FINDING** | [O] A5(b) — self-corrected, uncommitted, 2D-owned cleanup owed |
| D10 | Round claims about the 2D lane / battery made without touching them? | **COMPLIANT** | [O] `r107-cards.md:285` ("does not assert … anything about the sibling 2D lane or `corpus/fixtures/run_battery.py` (untouched; never run)") and `r107-integrate.md:189` ("**nothing** outside `reports/round-107/`") are correctly scoped negatives |

## E. What this shard does not claim

- **[?]** "The battery was never executed anywhere" — I measured immutability + absence of round
  artifacts (A3); a full trace sweep is `r107-sent-scope.md`'s scope.
- **[?]** The relocation in A5(b) is inferred from two snapshots; I did not observe the move.
- **[?]** UE runtime unlock status is **UNPROVEN** from this seat — the pull had not completed and no
  probe ran at my last check (00:10:36). This seat asserts no label.
- **[I]** All peer-shard agreement rows are cited as *peer claims I independently reproduced*, not as
  inherited evidence; every value above carries its own command and output.
