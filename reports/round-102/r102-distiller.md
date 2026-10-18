# r102 distiller — mid-flight synthesis of round 102 (gate integration + routed-defect repair)

**Seat:** SEAT-31 DISTILLER · round 102 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only. No commit. `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
`SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**` and every other
seat's declared path were **not** touched.
**Synthesis runtime:** `2026-10-18T17:40:58Z → 17:43:45Z` (UTC).
**HEAD at every frame:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work
commit `1659c036`).
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @
`a6aa73ada02a9fb1f5415bec491f9942c519b297` (public repo, read-only reference).

**The tree was live-mutating under ~60 concurrent seats for the whole of my runtime.**
`reports/round-102/` grew **7 → 32 files** in under three minutes; `corpus/knowledge/engines.md`
changed sha256 **twice** (`b20e5a9b…` → `e039…` → `d03907d3…`) while I held it; the C1 gate
directory went from **absent** to **present** between two consecutive tool calls of mine. Every
count below carries the frame it was taken in. **This is a snapshot, not a final state** — and it
is deliberately *not* the round-close verdict.

Tags: **[O]** receipt-pinned observation I ran · **[D]** deduped from a peer seat's receipt
(pointer given) · **[?]** unknown / not measurable at my runtime.

---

## 1. What I did (method, so the receipts are separable)

Read every artifact under `reports/round-102/` and every r102-touched file under `corpus/`
present at my runtime; re-derived the load-bearing numbers myself rather than quoting a peer
transcript; collapsed the 32 artifacts' overlapping claims into one numbered list; then named
what no seat covered. **My own receipts are §6.** Findings marked **[O]** there are mine.

I did **not** re-run the four checks the gate performs as a substitute for reading it — I ran
the gate itself, and separately ran two negative controls against it (§6.3–6.4).

---

## 2. Deduped findings

Ordered by how much downstream work depends on them, not by seat.

### A0. Two adversary rulings that reframe the lattice (read before §B)

These landed late in my runtime and they change what "repair" should mean for F1 and F2. They
are not extra findings; they are **corrections to the routed framings**, and the L1 needs them
before adjudicating.

25. **F1's routed premise is REFUTED, and the in-flight repair is flagged non-conformant.**
    SEAT-11 `adversary/F1.md` argues the r101 filing's claim — "that root has never existed in
    this repository" — is a correct observation about *this* repo generalised into a false
    universal. The r22 author worked in the `prymeagnt` worktree where `.shokunin/game-dev-3d/`
    **was a real tracked directory**, which became a symlink ~14.5 h after r22 landed. I verified
    the two consequences that matter: (a) the affected population is **142 tracked files**
    (`git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l` → `142`), including `PROVINCE.md:46`
    which declares the lane's write scope as `Only writes .shokunin/game-dev-3d/**`; (b) the F1b
    repair **did** edit line 7, which is *narrative*, not a command block — `I checked
    \`.shokunin/game-dev-3d/LOG.md\`` became `I checked \`LOG.md\``. [O] §6.15.
    **SEAT-11's R2/R3/R5 therefore stand as a live adjudication item:** a one-file fix that leaves
    141 siblings and the lane's own scope declaration still carrying the prefix converts a routed
    defect into a standing conformance defect. Its recommended disposition is a single appended
    correction note in `corpus/README.md`, not a per-file rewrite. [D]

26. **F2 must not be repaired by deletion — the pointer is the only surviving record of the run.**
    SEAT-12 `adversary/F2.md` shows the full digest `a806b9e4…3d8fc` occurs in exactly **one
    tracked blob** in the whole repository (`corpus/lessons/r22-unreal-review.md`), scanned over
    2,365 objects; the r101 critic only ever wrote the elided form. The repair pattern the lane
    already uses is **additive**: r1 committed its receipts as
    `corpus/lessons/r1/{clean-verdicts,adversarial-controls,mutation-verdicts}.json`, and the
    sibling 2D lane tracks **680** `verdicts.json` receipts. I verified both:
    `git ls-files corpus/lessons/r1/` → 3 receipt files; `git -C ../game-dev-2d-shokunin ls-files |
    grep -c verdicts.json` → `680`, and that lane tracks **40 599** files under `corpus/live` — so
    the 3D lane's blanket `corpus/.gitignore:1` (`live/`) is the **fleet outlier**, not the fleet
    norm. [O] §6.16. **The ruled repair is: keep the run id and digest verbatim, append a dated
    note, and (separately) consider committing a durable copy — not delete the pointer.** [D]

### A. The C1 gate — built, and it works (coverage)

1. **C1(a) landed and passes 4/4 from a clean run.** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
   (+ its spec `gate/README.md`) exists and exits **0** with all four `STEP=PASS`. [O] §6.1.
   Corroborated by SEAT-17 (author, `gate/author-run.txt`), SEAT-39 (`gate/runtime-run.md`, the
   manual fallback it wrote *before* the gate existed), SEAT-35/36/37/38 (independent re-runs of
   checks 1–4). [D]

2. **The gate is non-vacuous — it fails closed on five distinct mutation classes.** I reproduced
   two myself: a one-byte append to `CODEOWNERS` → `MANIFEST_OK=11 FAILED=1` / `GATE RESULT: FAIL`
   / exit 1; a prose token inserted above a card's declaration → `FAIL label-unmarked` /
   `CARDS=13 BAD=1` / exit 1. [O] §6.3–6.4. The author's own seven controls
   (`gate/controls.txt`) cover byte-flip, file deletion, out-of-range pointer, duplicate label
   token, census drift, card removal, and a **positive** control proving the exact-sentinel
   filter is not eating real pointers (`SKIPPED_CONTROL_SENTINELS=2`, `GATE RESULT: PASS`). [D]

3. **Check 2 is stronger than a manifest check and the gate says why.** It requires the fresh
   clone's HEAD to **equal the pin exactly** (a moved `main` is a FAIL, not a warning), plus
   path-set equality **both ways** and per-file byte-identity against the clone's blobs — the
   comparison a regenerated manifest cannot fake. Observed: `CLONE_HEAD=a6aa73ad…`,
   `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0`, `PATH_MISSING=0`, `BLOB_DIFFS=0`. [O] §6.1.

4. **Check 2 is the gate's only network dependency and it is honest about being BLOCKED, not
   PASS,** when the clone fails (`FAIL fresh clone failed … BLOCKED, not PASS`). [D] `gate/README.md`.

5. **The r101 pin is still `main`'s tip — no re-pin is owed.** Three independent transports agree
   (git protocol, GitHub REST API, HEAD symref); `pushed_at` predates the r101 fetch; no tags
   exist upstream. [D] SEAT-59 `freshness-pin.md`. Confirmed independently by SEAT-52
   (`provenance-rerun.md`, Path A ref-name + Path B by-SHA in a second clone) and by my own
   gate run, whose check 2 clones fresh. [O] §6.1.

6. **C1(b) landed: `corpus/lessons/r102-unreal-integration.md`** (178 lines, 4 laws + 2 counting
   traps + 6 next-iteration hooks), every law carrying a resolvable `path:line` receipt. [O]

7. **C1(c) landed: the `engines.md` Unreal row now distinguishes two evidence classes** —
   (a) the r22 lane-authored sample and (b) the r101 third-party pinned tree — with the
   authority asymmetry stated explicitly ("(a) is lane-authored, so it can only prove the lane
   can write a descriptor its own checker accepts, while (b) is someone else's bytes at a pinned
   upstream commit"). [O] §6.5.

8. **The r101 subtree is still byte-pinned after every r102 repair.** `git diff --name-only HEAD --
   corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` is empty; the
   only tracked change inside the subtree is the F8 wording fold in `README.md`, which the round
   explicitly authorizes. [D] SEAT-51 `git-hygiene.md`, SEAT-35 `reruns/manifest.md`. [O] §6.1
   (manifest 12/12 OK with the wording fold in place).

### B. The routed defect lattice (depth)

9. **F1 — commands fixed in both files, but the *closure* is contested.** The phantom
   `.shokunin/game-dev-3d/` root is gone from `corpus/artifacts/unreal-r22/README.md` (SEAT-07,
   before `exit=2` → after `exit=0`) **and** from `corpus/lessons/r22-unreal-review.md`
   (the lesson diff is `7 insertions / 7 deletions`). **But the lesson diff is not
   "path-prefix only"** — it also rewrote narrative line 7, and SEAT-11 rules that
   non-conformant (see §A0 finding 25 and §6.15). So: the *commands* are fixed; the *repair's
   conformance* is an open adjudication item. [O] §6.6, §6.15.

10. **F3 — before-capture done, repair NOT landed.** `corpus/fixtures/run_battery.py` hashes to
    `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (346 248 bytes) live **and**
    in the HEAD blob; the stale `a065a56d…` string still sits at
    `corpus/lessons/r22-unreal-review.md:48`. [O] §6.6. SEAT-03 proved the cited digest is the
    real r21/r22-era blob (`git cat-file blob 490e710d:…` → `a065a56d…`, 34 239 bytes) and that
    78 commits touch the file with 78 distinct digests. [D]

11. **F2 — before-capture done, repair NOT landed.** `corpus/live/runs/20261013T053632289732Z/verdicts.json`
    is absent, and `corpus/.gitignore:1` (`live/`) means it can never be tracked. [O] §6.6.
    **The citation survives in two lessons, not one:** `r22-unreal-review.md:48` **and**
    `r23-ortho-review.md:3`. [O] §6.6. Only SEAT-02's before-capture names the r23 site; no
    repair seat has been routed to it. **This is the round's clearest orphan.**

12. **F5 — CLOSED.** `engines.md`'s three.js evidence cell now reads
    `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs`, with the
    install precondition spelled out in the notes cell. I re-derived the before/after pair myself
    on a pristine `git archive HEAD` export: bare command → `exit=1` with four `FAIL` lines and
    `ERR_MODULE_NOT_FOUND`; after `npm ci --prefix` → `exit=0`, 3/3 PASS. [O] §6.7.

13. **F6 — CLOSED by dated note, and the note's *framing* was corrected by an adversary.**
    `corpus/knowledge/rea.md` keeps the mint sentence verbatim and appends a dated correction note
    (27 → 63 lines). [O] §6.8. SEAT-15 `adversary/F6.md` showed from `/var/log/pacman.log` that
    the JADX/Binwalk install transaction ran at `2026-10-13T13:52:22-0300`, **13 h 51 m after**
    the census was authored (`82c21b4`, `2026-10-13T00:00:34-0300`) — so the census was **true
    when written**, and the before-capture's speculation that it "was already wrong at mint" is
    unsupported. [D] The landed note does not adopt that framing. [O] §6.8.

14. **F6's scope is wider than the routed defect.** The repair seat found pwntools is *present* via
    `$REA_PWNTOOLS_PYTHON` (pwnlib 4.15.0) though absent from plain `python3`, and that the JADX
    provider prerequisite is satisfied (`$REA_JADX_MCP_JAR`, Java 21 ≥ required 17). So the
    "3 of 4 tools now present" count in the before-capture was itself an undercount. [D]

15. **F8 — CLOSED, and the correction is provably right.** `corpus/knowledge/unreal-mcp/README.md`
    now separates `audit-reference.sha256` → **12** OK from the glob
    `.manifest.d/*.sha256` → **24** OK. I reproduced both counts exactly. [O] §6.9.

16. **F4 — not a live r102 defect; already closed at HEAD.** The r101 critic's F4 (the
    `assets-content.md` "17 words" claim not matching its own `wc -w` command) reads **13** at
    HEAD, which is exactly what the card's own command produces
    (`sed -n '102p' upstream/README.md | sed 's/.*\*\*Assets and Content\*\* - //' | wc -w` → 13;
    whole line → 18). [O] §6.10. No r102 report mentions F4 at all (0 of 32). [O]

17. **F7 — UNASSIGNED and still open. This is the round's highest-value gap.** [O] §6.11.
    See §3-G1.

18. **Every repair obeyed the correction-note discipline — with one contested exception.**
    I checked the two classes separately: mechanical command/path conformance fixes were applied
    **in place** (F1a README, F5, F8), and the historical factual claim was **preserved verbatim
    with a dated note** (F6). The r22 lesson's F2/F3 lines are historical factual claims and were
    correctly left alone. **The exception is the F1b lesson repair, which edited narrative line 7
    as well as the command blocks** — SEAT-11 rules that part non-conformant (§A0 finding 25,
    §6.15). [O] §6.6–6.9, §6.15.

### C. Round hygiene and the concurrency artifact

19. **No protected path was touched.** `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
    `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**` are all byte-identical
    to HEAD; 332/332 tracked files under `reports/` are byte-identical; zero deletions. [D]
    SEAT-55 `ledger-check.md`, SEAT-51 `git-hygiene.md`, SEAT-33 `battery-integrity.md`.

20. **The fixtures tree is byte-stable and structurally intact.** 146 tracked fixture files,
    0 blob-id mismatches vs HEAD, index-vs-HEAD aggregate sha256 equal (`827af6c3…`), 0 untracked
    non-ignored files; `run_battery.py` parses to exactly **350** CASES rows in both the worktree
    and the HEAD blob. [D] SEAT-33. Caveat recorded by that seat and worth repeating: it is a
    byte/AST proof only — **no battery execution was run**, so it says nothing about runtime
    pass/fail. [D]

21. **The round does not follow the `rNN-<seat>.md` naming convention** — 0 `r102-*.md` files
    against 15 in r101; every top-level file is a free-form topic slug. [D] SEAT-57
    `reports-index.md`. Not a violation of any stated rule, but it breaks cross-round greps.
    **My own filename follows the r101 distiller precedent (`r101-distiller.md`), not the
    r102 slug convention** — noted so the L1 can rename at close if it prefers uniformity.

22. **The repo's MCP exposure is thinner than r101 recorded.** Kimi Code 2.2.0 *does* gate
    project-level MCP behind a per-workspace trust flag, and **this lane's workspace is already
    trusted**; the only thing keeping the lane inert is that no `.mcp.json` exists at the git
    root. That is a one-file margin, not a control. [D] SEAT-53 `sentinel-mcp.md`.

23. **The C3-equivalent surface drifted and needs a note.** `adaptation-kimi.md`'s binary-anchored
    rows are still valid (same version `2.2.0`, same BuildID), but three non-binary citations are
    stale: `~/.kimi-code/config.toml:2932-2937` is now a `[models.*]` table (the only `[[hooks]]`
    is at line 3219), and all `moonshotai.github.io/kimi-code/{customization,configuration}/*.html`
    URLs now 404 (locale-prefixed `/en/…` pages return 200). [D] SEAT-62 `kimi-surfaces.md`.

24. **`PROVENANCE.md` §8's six out-of-pin hashes re-derive exactly (6/6)**, via two independent
    resolution paths, with two *surface* observations (a divergent sibling `marketplace.json` in
    PR 2, and a new PR 8 that did not exist when §8 was written). [D] SEAT-52.

---

## 3. Gaps no seat has covered

Each gap is named with the evidence that it is open, not assumed. Ordered by L1 leverage.

**G1 — The F7 label-vocabulary collision is still open, and it is the one finding the r101 critic
called its highest-value item.** [O] §6.11.
`corpus/knowledge/unreal-mcp/README.md:41` defines `unproven-runtime` as *"the claim needs the
live editor and **nothing was observed**"*. Six of the thirteen cards explicitly reject that label
on the ground that the runtime path *"is not even identified"* — which is the same condition.
Re-derived at my runtime:

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

Two groups with the same epistemic situation landed on opposite labels, each citing a different
(unwritten) definition. **The gate cannot see this by construction**: check 3 enforces
*one label per card from the allowed ternary*, and the cards pass that check. The gate's own
README says so — it "does not judge whether a card's label is *consistent with its evidence*".
So C1 can be green while F7 stays open, and **a green gate must not be read as F7 being closed.**
Evidence the collision is real and not a reading artifact: `editor-general.md:46-48` labels itself
`static-only` while explicitly conceding "`unproven-runtime` correctly labels the *live-call*
sub-claim", i.e. it resolves the collision by splitting the card rather than by sharing a
definition. **No r102 artifact addresses this** (0 of 32 files mention F7). [O]

**G2 — F2 has a second citation site that no repair seat was routed to.** [O] §6.6.
`reports/round-102/before/F2-verdicts-json.md` names `r23-ortho-review.md:3` as a second cite of
the same absent, gitignored receipt — but no `repairs/F2*` file exists, and the r23 line is
unchanged. If F2 is repaired by editing only the r22 lesson, the defect survives repo-wide.

**G3 — F2 and F3 have before-captures and adversary review but no repair artifacts.** [O] §6.6.
`repairs/` holds F1a, F5, F6 — **not** F2 or F3. Both are still live in
`corpus/lessons/r22-unreal-review.md:48`. The r102 lesson's own hook 4 lists them as carried
forward, which is consistent with "not this round" — but the round brief routes them as C2
repairs, so this is a **scope discrepancy the L1 must adjudicate**, not a silent omission.
**Both now also carry a ruled repair *direction* from an adversary** (§A0 findings 25–26), so the
L1 is adjudicating a direction, not inventing one.

**G4 — F5's fix has a cross-file remainder.** SEAT-14's adversary review found
`corpus/fixtures/three/README.md:6` uses the same dead `.shokunin/game-dev-3d/` root **and** the
same missing install precondition, and exits 1. `engines.md` was fixed; the fixture's own README
was not. [D] `adversary/F5.md` §P3.

**G5 — F5's citation-strength sub-defect is unfixed by design.** The quoted token `3/3` is
printed by **both** the PASS and the FAIL summary line, so the evidence string cannot
discriminate success from failure. The repair fixed the precondition, not the token. [D]
`adversary/F5.md` §P1.

**G6 — The F1 population is 142 tracked files and the round repaired 2 of them; the scope
question is now an explicit adjudication item, not a mechanical sweep.** [O] §6.15.
`git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l` → **142**, of which **80 are
`corpus/lessons/**`** — and `PROVINCE.md:25,46` carries it **twice**, once as the lane's own
declared write scope (`Only writes .shokunin/game-dev-3d/**`). SEAT-11's adversary report argues
the prefix is the *fleet worktree convention* the lane was spawned under, so a repo-root-relative
rewrite of all 142 would rewrite history across the corpus and touch `PROVINCE.md`. **Its
recommended disposition is a single appended correction note in `corpus/README.md`** stating that
the lane's historical lessons cite paths through the worktree convention, that the convention does
not resolve from the lane repo root, and that the repo-root-relative form is the executable one —
one note, one sweep, no history edited. This supersedes my earlier framing of G6 as a purely
mechanical `sed`. [D] `adversary/F1.md` §5 R4.

**G7 — `engines.md` is not referenced by any gate, and the gate is not referenced by the
subtree's own docs.** [O] §6.13. `grep -rn "gate/" corpus/knowledge/unreal-mcp/README.md
PROVENANCE.md adaptation-kimi.md` is **empty** — the gate is discoverable only from
`reports/round-102/`. A reader of the subtree cannot find the checker that certifies it. The
r102 lesson's hook 2 still describes the gate as future work ("Until it exists, cite the protocol
appendix") because the lesson landed before the gate did. Both are concurrency artifacts worth a
one-line fix at close.

**G8 — The gate hard-codes the r101 *first-token-wins* label rule, which SEAT-36 showed is
position-fragile.** [O] §6.4, [D] `reruns/labels.md` §3a. My negative control confirms the gate
*does* catch a prose token above a declaration today — but it catches it by **failing**, which is
the right outcome only because the false-positive is loud. SEAT-36's point stands: the rule reads
the card correctly only while no card puts prose above its declaration. Recommended rule
("first line matching `(Label|Verdict)…:` **or** a line that is nothing but a bolded token") is
recorded in `reruns/labels.md` and not yet adopted.

**G9 — The pointer sweep is not a pinned-bytes sweep.** [D] `reruns/pointers.md` §1.
7 of the 16 scanned files are untracked by `.manifest.d/` (the manifests pin 12 entries and all
12 are `upstream/**`); `adaptation-kimi.md` alone carries 18 of the 47 pointers. The result is
still sound because the seat also ran it against the pristine HEAD tree — but a reader who
assumes "the sweep is over pinned bytes" is wrong.

**G10 — `PROVENANCE.md` §6's file tree does not list `gate/`.** [O] §6.13. The subtree's declared
tree was written in r101 and now under-describes itself. Same class as G7.

---

## 4. Ranked L1 actions

Ranked by (leverage × cheapness). Each is concrete and checkable.

1. **Adjudicate the F1 scope question FIRST — it gates actions 2 and 6 and it is the round's
   largest unresolved blast-radius decision.** [O] §6.15, [D] `adversary/F1.md` §5.
   The population is **142 tracked files** (80 lessons, `PROVINCE.md` twice), and the prefix is
   the lane's own declared write scope, not merely a stale citation. SEAT-11's recommended
   disposition is a **single appended correction note in `corpus/README.md`** — one note, one
   sweep, no history rewritten — which satisfies both the reproducibility duty and the
   append-only discipline. The alternative (sweep all 142) rewrites history across the corpus.
   **The F1b repair already in the tree also needs a ruling**: it rewrote narrative line 7
   (`I checked \`.shokunin/game-dev-3d/LOG.md\`` → `I checked \`LOG.md\``), which is prose about
   what the author did, not a command block. *Check:* `git diff -- corpus/lessons/r22-unreal-review.md`.
   **Highest leverage: it decides whether the round's F1 "closure" is conformant.**

2. **Adjudicate F2/F3 — decide the direction and record it.** Both now have a ruled repair
   *direction*, not just a diagnosis: **keep the pointer, append a dated note, do not delete**
   (F2, §A0 finding 26), and for F3 the fix must not silently swap one driftable digest for
   another — use a re-derivable command (`git cat-file blob 8b21cae:corpus/fixtures/run_battery.py
   | sha256sum`). Include the **r23** site (G2). *Check:* `grep -c
   'a065a56d\|20261013T053632289732Z' corpus/lessons/r22-unreal-review.md
   corpus/lessons/r23-ortho-review.md`.

3. **Route F7 to a calibration seat, and make it a gate input.** This is the r101 critic's
   highest-value finding, it is unassigned, and — critically — **the C1 gate is green while it
   stands**. Either amend `README.md:41` to say which side of the split owns "path not even
   identified", or amend the six `static-only` cards. *Check:* `grep -rln 'Not `unproven-runtime`'
   corpus/knowledge/unreal-mcp/executability/*.md | wc -l` should be either 0 or the README
   definition should have changed. **The only live calibration defect that a green gate obscures.**

4. **Add a fifth gate check: the label-definition agreement, or at minimum record in the gate
   README that a green gate does not certify F7.** The gate already says it "does not judge whether
   a card's label is consistent with its evidence" — but that sentence is buried in
   *"What this gate does not do"*. The round's own lesson (Law 3) calls the shared vocabulary
   "the training point". A one-line pointer in `gate/README.md`'s *Verdict* section is cheap.
   *Check:* `grep -n 'F7\|vocabulary' corpus/knowledge/unreal-mcp/gate/README.md`.

5. **Wire the gate into the subtree's own documentation** (G7, G10): one line in
   `README.md` §Layout and one in `PROVENANCE.md` §6 naming `gate/run_gate.sh`. Otherwise the
   round's headline coverage deliverable is undiscoverable from the artifact it certifies.
   *Check:* `grep -rn 'gate/' corpus/knowledge/unreal-mcp/README.md`.

6. **Fix the r102 lesson's stale hook 2** (G7) — it still reads "Until it exists, cite the
   protocol appendix, not a `/tmp` file", which the gate landing falsified within the same round.
   *Check:* `grep -n 'Until it exists' corpus/lessons/r102-unreal-integration.md`.

7. **Fix the two F5 remainders** (G4, G5): the fixture README's dead root + missing install step,
   and the non-discriminating `3/3` token. Both are small and both are already diagnosed.
   *Check:* `git archive HEAD corpus/fixtures/three | tar -x -C /tmp/x && (cd /tmp/x && node
   corpus/fixtures/three/run_cases.mjs)` still exits 1.

8. **Adopt SEAT-36's declaration rule in the gate** (G8) before a future card lands prose above
   its label. Today the gate fails loudly rather than silently, so this is preventive, not urgent.
   *Check:* re-run SEAT-36's NC6 control (`reruns/labels.md` §3a) against the gate.

9. **Land the `adaptation-kimi.md` freshness note** (G23) — the proposal text is already written
   in `kimi-surfaces.md`; the owning seat only needs to apply it.

10. **Consider committing a durable receipt copy for future runs, and narrow `corpus/.gitignore`**
    (§A0 finding 26, [O] §6.16). r1 committed its receipts; the 2D lane tracks 40 599 files under
    `corpus/live` including 680 `verdicts.json`; this lane's blanket `live/` rule is the fleet
    outlier and is the *root cause* of the F2 class. Cheap now, prevents the whole defect family
    recurring. *Check:* `git -C ../game-dev-2d-shokunin ls-files | grep -c verdicts.json` vs
    `git ls-files corpus/live | wc -l` here.

11. **Re-run the countable DoD at close.** `round-count.md` is the round's own instrument and it
    says so: re-run §5 after the last seat exits. Several of its rows were `PENDING` at
    `17:43:14Z` and the tree kept moving after that frame. *Check:* `find reports/round-102 -type f
    | wc -l` and `git status --porcelain -uall` at close.

---

## 5. Claim status at my runtime

| claim | axis | deliverable | status at `17:43:45Z` |
|---|---|---|---|
| **C1(a)** gate | coverage | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` + `gate/README.md` | **LANDED and PASSING** — I ran it, exit 0, 4/4 `STEP=PASS`; two negative controls reproduced [O] §6.1, §6.3–6.4 |
| **C1(b)** lesson | coverage | `corpus/lessons/r102-unreal-integration.md` | **LANDED** (178 lines, 4 laws, resolvable receipts) [O] §6.2 |
| **C1(c)** engines row | coverage | `corpus/knowledge/engines.md:10` | **LANDED** — two evidence classes, authority asymmetry stated [O] §6.5 |
| **C2** F1 | depth | `corpus/artifacts/unreal-r22/README.md`, `corpus/lessons/r22-unreal-review.md` | **COMMANDS FIXED, closure contested** — exit 2 → exit 0; but the lesson repair also rewrote narrative line 7, which SEAT-11 rules non-conformant; and 142 tracked files still carry the prefix [O] §6.6, §6.15 |
| **C2** F2 | depth | — | **OPEN** — before-capture + adversary ruling (keep pointer, add dated note); absent in both r22 and r23 lessons [O] §6.6 |
| **C2** F3 | depth | — | **OPEN** — before-capture + adversary only; stale sha still cited [O] §6.6 |
| **C2** F5 | depth | `corpus/knowledge/engines.md` | **CLOSED** — before exit=1 → after exit=0, re-derived by me [O] §6.7 |
| **C2** F6 | depth | `corpus/knowledge/rea.md` | **CLOSED** — mint sentence preserved + dated note; framing corrected by adversary [O] §6.8 |
| **F8** wording fold | calibration | `corpus/knowledge/unreal-mcp/README.md` | **CLOSED** — 12 vs 24 both reproduced by me [O] §6.9 |
| **F4** | — | — | **already closed at HEAD**; not an r102 defect [O] §6.10 |
| **F7** | calibration | — | **OPEN and UNASSIGNED** — 0 of 32 r102 files mention it [O] §6.11 |

---

## 6. My own receipts

Every command below was run by me from the repo root
`/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` at HEAD `2c99b7b`, at the frame stated.
Output is verbatim.

### 6.1 The gate, run from a clean invocation (`17:43:45Z`)

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207

CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

Run twice (17:42:06Z and 17:43:45Z) with identical results, so the pass is stable across the
window in which `engines.md` and `rea.md` changed.

### 6.2 C1(b) lesson present

```
$ wc -l corpus/lessons/r102-unreal-integration.md
178 corpus/lessons/r102-unreal-integration.md
$ sha256sum corpus/lessons/r102-unreal-integration.md
ace4ce527ee382742f73c43f0de98e6175fe4c4477c00edbd2509b7e52767ccb  corpus/lessons/r102-unreal-integration.md
```

### 6.3 Negative control 1 — one byte appended to a vendored file (scratch copy)

```
$ rm -rf /tmp/r102-gate-nc && mkdir -p /tmp/r102-gate-nc && cp -r corpus/knowledge/unreal-mcp /tmp/r102-gate-nc/
$ cd /tmp/r102-gate-nc && printf '\n' >> unreal-mcp/upstream/CODEOWNERS
$ bash unreal-mcp/gate/run_gate.sh 2>&1 | grep -E "MANIFEST_OK|STEP=|GATE RESULT"
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
STEP=FAIL
STEP=FAIL
STEP=PASS
STEP=PASS
GATE RESULT: FAIL (checks failed: 2)
rc=1
```

Both check 1 (manifest) and check 2 (blob diff vs the clone) catch it — the double coverage the
gate README claims is real.

### 6.4 Negative control 2 — prose token above a card declaration (scratch copy)

```
$ rm -rf /tmp/r102-f7 && mkdir -p /tmp/r102-f7 && cp -r corpus/knowledge/unreal-mcp /tmp/r102-f7/
$ cd /tmp/r102-f7 && python3 -c "
p='unreal-mcp/executability/editor-general.md'
l=open(p).read().split('\n')
l.insert(3,'This card is emphatically not \`verified-here\`; nothing was observed.')
open(p,'w').write('\n'.join(l))"
$ bash unreal-mcp/gate/run_gate.sh 2>&1 | grep -E "editor-general|CARDS=|STEP=|GATE RESULT"
STEP=PASS
STEP=PASS
FAIL label-unmarked /tmp/r102-f7/unreal-mcp/executability/editor-general.md :: This card is emphatically not `verified-here`; nothing was observed.
CARDS=13 EXPECTED=13 BAD=1
STEP=FAIL
STEP=PASS
GATE RESULT: FAIL (checks failed: 1)
```

This is SEAT-36's NC6 control, run against the **gate** rather than against a standalone scanner.
It fails loudly, which is the correct outcome — but note *why* it fails: because the injected
line is not bold/heading-marked, not because the gate distinguishes declaration from prose by
position. See G8.

### 6.5 C1(c) engines row

```
$ git diff --stat -- corpus/knowledge/engines.md
 corpus/knowledge/engines.md | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
$ sed -n '10p' corpus/knowledge/engines.md
| Unreal Engine | no | no | two static evidence classes, both `static-only` (0 `verified-here`; every runtime claim on this row stays `unproven-runtime`): (a) r22 self-authored `corpus/artifacts/unreal-r22/` `.uplugin` sample + non-author review; (b) r101 third-party pinned tree `corpus/knowledge/unreal-mcp/` — Epic `unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ad`, MIT, 12/12 tracked files byte-identical (`sha256sum -c .manifest.d/audit-reference.sha256` → rc=0), 13 `executability/` cards (12 `static-only` / 1 `unproven-runtime` / 0 `verified-here`) | not installed; (a) and (b) are categorically different evidence classes — (a) is lane-authored, so it can only prove the lane can write a descriptor its own checker accepts, while (b) is someone else's bytes at a pinned upstream commit and carries an authority (a) structurally lacks; neither proves plugin load, UBT compilation or engine runtime; every live-editor claim in (b) is unproven by construction |
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
```

### 6.6 F1 closed, F2/F3 still open — measured directly

```
$ grep -c "shokunin/game-dev-3d" corpus/lessons/r22-unreal-review.md
0
$ git diff --stat -- corpus/lessons/r22-unreal-review.md
 corpus/lessons/r22-unreal-review.md | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)
$ grep -c "a065a56d" corpus/lessons/r22-unreal-review.md
1
$ grep -c "20261013T053632289732Z" corpus/lessons/r22-unreal-review.md
1
$ grep -c "20261013T053632289732Z" corpus/lessons/r23-ortho-review.md
1
$ grep -n "Correction" corpus/lessons/r22-unreal-review.md
(no output — no correction note landed in the r22 lesson)
```

Reading: the r22 lesson carries **only** the F1 path-prefix fix (7 insertions / 7 deletions, all
prefix). Both the F2 receipt citation and the F3 stale digest survive verbatim, and the **r23**
lesson carries the F2 citation too.

The current file digest is correct and HEAD-identical:

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ git show HEAD:corpus/fixtures/run_battery.py | sha256sum
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  -
```

### 6.7 F5 closed — before/after re-derived by me on a pristine export

BEFORE (bare command, exactly as the old cell cited it):

```
$ rm -rf /tmp/r102-f5b && mkdir -p /tmp/r102-f5b
$ git archive HEAD corpus/fixtures/three | tar -x -C /tmp/r102-f5b
$ cd /tmp/r102-f5b && node corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
exit=1
```

(A first attempt that copied files without `package-lock.json` died earlier with
`Error: ENOENT: no such file or directory, open '/tmp/r102-f5/package-lock.json'` — recorded
because it shows the runner also hard-depends on the lockfile being present, which the
`git archive` path preserves and a hand-copy can drop.)

AFTER (the new cell's documented command):

```
$ rm -rf /tmp/r102-f5-after && mkdir -p /tmp/r102-f5-after
$ git archive HEAD corpus/fixtures/three | tar -x -C /tmp/r102-f5-after
$ cd /tmp/r102-f5-after && npm ci --prefix corpus/fixtures/three >/dev/null 2>&1
$ node corpus/fixtures/three/run_cases.mjs; echo "exit=$?"
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

The F5 fix is real and the cited command now reproduces from the committed tree.

### 6.8 F6 closed by dated note

```
$ grep -c -E "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md
1
$ grep -c "Correction note (r102" corpus/knowledge/rea.md
1
$ which jadx binwalk unblob; echo "rc=$?"
/usr/bin/jadx
/usr/bin/binwalk
/home/vgpnk/.local/bin/unblob
rc=0
$ sha256sum corpus/knowledge/rea.md
3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059  corpus/knowledge/rea.md
$ wc -l corpus/knowledge/rea.md
63 corpus/knowledge/rea.md
```

The mint sentence is preserved verbatim (count 1) **and** the dated note is present (count 1) —
the correction-note discipline, executed correctly. Before → after: 27 lines / `9be388f3…` →
63 lines / `3932fc53…`.

### 6.9 F8 closed — both counts reproduced

```
$ cd corpus/knowledge/unreal-mcp
$ sha256sum -c .manifest.d/audit-reference.sha256 | wc -l
12
$ sha256sum -c .manifest.d/*.sha256 | wc -l
24
$ wc -l .manifest.d/seat11.sha256
2 .manifest.d/seat11.sha256
```

The README's corrected text distinguishes exactly these two numbers. The seat-shard arithmetic
checks out: ten single-line shards + one two-line shard = 12 entries, so the glob prints 12 + 12.

### 6.10 F4 is already closed at HEAD (not a live r102 defect)

```
$ sed -n '393p' corpus/knowledge/unreal-mcp/executability/assets-content.md
- Its total upstream specification is **13 words on one line** (`README.md:102`; `wc -w` on the
$ git show HEAD:corpus/knowledge/unreal-mcp/executability/assets-content.md | grep -n "words on one line"
393:- Its total upstream specification is **13 words on one line** (`README.md:102`; `wc -w` on the

$ sed -n '102p' corpus/knowledge/unreal-mcp/upstream/README.md | sed 's/.*\*\*Assets and Content\*\* - //' | wc -w
13
$ sed -n '102p' corpus/knowledge/unreal-mcp/upstream/README.md | wc -w
18
$ grep -n "17 words" corpus/knowledge/unreal-mcp/executability/assets-content.md
rc=1
```

The card's number (**13**) now matches the command it prints. The r101 critic's F4 was a
mid-round transient, closed before r101's final pass. **Zero of the 32 r102 artifacts mention
F4**, consistent with it not being a routed defect.

### 6.11 F7 — the collision, re-derived, and its absence from r102

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
$ for t in F1 F2 F3 F4 F5 F6 F7 F8; do printf "%s: " "$t"; grep -rl "\b$t\b" reports/round-102/ 2>/dev/null | wc -l; done
F1: 11
F2: 8
F3: 8
F4: 0
F5: 8
F6: 10
F7: 0
F8: 10
$ grep -rln "Not \`unproven-runtime\`\|label collision\|two vocabularies" reports/round-102/
(no output)
```

**Six cards reject the label; zero r102 artifacts address the collision.** The cards doing the
rejecting:

```
animation-controlrig.md, blueprints.md, editor-general.md, gameplay-gas.md, materials.md, meshes-textures.md
```

and the README definition they collide with is `README.md:41`. Note the split is not clean even
within the rejecting group: `editor-general.md:46-48` concedes "`unproven-runtime` correctly
labels the *live-call* sub-claim" while the other five argue the runtime path is "not even
identified". So there are at least **three** readings in play, not two.

### 6.12 The F1 class — a worktree-wide grep (superseded by §6.15's tracked count)

```
$ grep -rl "shokunin/game-dev-3d" corpus/ | wc -l
143
$ grep -rl "shokunin/game-dev-3d" corpus/lessons/ | wc -l
83
$ grep -rl "shokunin/game-dev-3d" corpus/artifacts/ corpus/fixtures/ | wc -l
10
```

Sample of the non-lesson sites (the r101 critic named this class and explicitly scoped itself
away from it):

```
corpus/artifacts/glb-r12/README.md:6
corpus/artifacts/unity-r19/README.md:10
corpus/fixtures/three/README.md:6
corpus/knowledge/unreal-mcp/executability/editor-general.md:292   (a `/home/…` absolute path, not the phantom root — benign)
```

Note the last row: this worktree grep is not a pure defect count, because
`editor-general.md:292` uses the repo's *real* absolute path, which happens to contain the
substring. **§6.15 is the authoritative figure: 142 *tracked* files at HEAD, 80 of them
lessons.** Use that number, not this one.

### 6.13 The gate is undiscoverable from the subtree it certifies

```
$ grep -rn "gate/" corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/PROVENANCE.md corpus/knowledge/unreal-mcp/adaptation-kimi.md
(no output; grep rc=1)
$ grep -n "Until it exists" corpus/lessons/r102-unreal-integration.md
155:   seat). Until it exists, cite the protocol appendix, not a `/tmp` file.
```

The subtree's three index documents do not name `gate/`, and the r102 lesson still describes the
gate as future work — both because they landed before the gate did. Concurrency artifacts, but
they will read as false to anyone who arrives after.

### 6.14 Round write surface at my final frame (`17:43:45Z`)

```
$ git status --porcelain -uall -- corpus/
 M corpus/artifacts/unreal-r22/README.md
 M corpus/knowledge/engines.md
 M corpus/knowledge/rea.md
 M corpus/knowledge/unreal-mcp/README.md
 M corpus/lessons/r22-unreal-review.md
?? corpus/knowledge/unreal-mcp/gate/README.md
?? corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? corpus/lessons/r102-unreal-integration.md
```

Five modified tracked files + three new files, and **not one of them inside the byte-pinned
region** `corpus/knowledge/unreal-mcp/{upstream,.manifest.d}/`. The round's write surface is
exactly what the brief declares. `find reports/round-102 -type f | wc -l` → **32** at this frame.

### 6.15 The F1 population is 142 tracked files, and the F1b repair edited narrative line 7

```
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l
142
$ git grep -l "\.shokunin/game-dev-3d" HEAD | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -4
     80 HEAD:corpus/lessons
      6 HEAD:reports/round-70
      5 HEAD:reports/round-78
      5 HEAD:reports/round-77
$ sed -n '46p' PROVINCE.md
Only writes `.shokunin/game-dev-3d/**` and its own reports. Domain source
$ sed -n '25p' PROVINCE.md
- corpus fixtures under .shokunin/game-dev-3d/corpus/ (predecessor suite
```

Note this is the **tracked** population (142) and includes `PROVINCE.md` twice — so the prefix is
the lane's own declared write-scope convention, not merely a stale citation. My earlier
worktree-wide `grep -rl … corpus/` count of 143 (152 with `reports/` included) is a *superset*: it
also catches a benign absolute path in `executability/editor-general.md:292` that merely contains
the substring. **142 is the number the L1 should use.**

The narrative-line edit, verified directly:

```
$ git show HEAD:corpus/lessons/r22-unreal-review.md | sed -n '7p' | grep -o 'I checked.*\.'
I checked `.shokunin/game-dev-3d/LOG.md` round 22, `PROVINCE.md`, and `corpus/artifacts/unreal-r22/README.md`. …
$ sed -n '7p' corpus/lessons/r22-unreal-review.md | grep -o 'I checked.*\.'
I checked `LOG.md` round 22, `PROVINCE.md`, and `corpus/artifacts/unreal-r22/README.md`. …
```

Line 7 is prose describing what the r22 author *did*, not a command a reader runs. SEAT-11's R2
holds that this is a committed historical record and that rewriting it misrepresents the author's
action — the correction-note discipline the brief states. **This is a live adjudication item, not
a settled repair.** [D] `adversary/F1.md` §5 R2/R5.

### 6.16 F2's pointer is the only surviving record; the lane's ignore rule is the fleet outlier

```
$ git ls-files corpus/lessons/r1/
corpus/lessons/r1/adversarial-controls.json
corpus/lessons/r1/clean-verdicts.json
corpus/lessons/r1/mutation-verdicts.json
$ ls corpus/lessons/ | grep -c "^r22"
1
$ git -C ../game-dev-2d-shokunin ls-files | grep -c "verdicts.json"
680
$ git -C ../game-dev-2d-shokunin ls-files corpus/live | wc -l
40599
$ cat corpus/.gitignore
live/
__pycache__/
*.pyc
```

Reading: r1 (the round that *created* this lane) committed its receipts as durable JSON; r22 did
not; the sibling 2D lane tracks 40 599 files under `corpus/live` including 680 `verdicts.json`
receipts. So the 3D lane's blanket `live/` ignore is the **outlier**, and the F2 defect is more
precisely a **missing durable copy** than a bad pointer. Deleting the citation would remove the
only surviving record of the run; the additive repair is the house style. [D] `adversary/F2.md`
§4–§5. (SEAT-12's blob-scan — the full digest in exactly one of 2,365 tracked objects — I did not
re-run; it is quoted as [D].)

### 6.17 The gate caught an unscheduled live tamper and returned green after restoration

Not my run, but the strongest evidence in the round that the gate is a real control rather than a
self-fulfilling script. During SEAT-17's final confirmation run, a peer seat briefly overwrote the
**live** pinned subtree (`upstream/README.md` replaced by a one-line `TAMPERED` stub). The gate
reported `MANIFEST_OK=10 EXPECTED=12 FAILED=2`, `BLOB_DIFFS=2`, and `UNRESOLVED=20` (every
pointer into the truncated 1-line README reported `LINE-OOR … (max 1)`), exit 1; after the bytes
were restored the re-run returned `GATE RESULT: PASS`, exit 0, `POINTERS=40 UNRESOLVED=0`. [D]
`gate/author-run.md` §"Incidental live-tamper detection". I re-ran the gate myself three times
across this window (17:42:06Z, 17:43:45Z, 17:44:28Z) and got 4/4 PASS each time, consistent with
the bytes having been restored.

---

## 7. What this synthesis does not establish

- **No Unreal runtime claim, anywhere.** Unreal Editor is not installed on this host; the source
  route is blocked at three distinct walls (404 / SSH `prepare()` gate / operator credential).
  Every live-editor claim in the r101 subtree is `unproven` by construction. The gate's green
  result says the *bytes* are right and four *static* checks ran here — it says nothing about
  plugin load, UBT compilation, or engine runtime.
- **This is a mid-flight snapshot, not a verdict.** The directory grew 7 → 32 files in under three
  minutes; `engines.md` changed sha256 twice while I held it. Several rows I marked LANDED may have
  been superseded by a later seat's write after my last frame. Re-run §6's commands at close.
- **I did not re-derive every peer number.** Findings tagged [D] are deduped from the cited
  receipt, not independently reproduced by me. The ones I did reproduce myself are §6.1–§6.14.
- **I did not audit the older corpus** (the r70–r76 nav-agent lessons, the bpy/navagent
  dissections, `corpus/predecessor/`). G6's 143-file count is a *grep* count, and the F1-class
  sweep it implies was explicitly out of scope for both the r101 critic and this round.
- **`corpus/knowledge/unreal-mcp/executability/*.md` are not byte-pinned**, so the 13-card census
  is only reproducible against the digests recorded in `reruns/labels.md` §5. A card edited after
  that frame would invalidate the label census without failing any gate check that pins digests.

---

*Written by SEAT-31 DISTILLER, r102. One file written: this one. No commit; the L1 lands commits
at round close.*
