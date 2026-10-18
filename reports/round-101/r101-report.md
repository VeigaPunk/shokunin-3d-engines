# r101 round report — Unreal Engine skills integration (game-dev-3d shokunin)

**Seat:** SEAT-58 SCRIBE · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Round:** 101 · **Axes:** depth / coverage / calibration (coverage = lowest non-retired)
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
@ `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`, subject
`[MCP] Permit safe concurrent tool calls`)
**Landing commit:** `1659c036c961c6cdfd0b2679db72ecb9517a2f3b` — *to be filled at round close; the L1 lands one
commit and this report is the last artifact to land.*
**Report base HEAD at write:** `cb87233` (*"game-dev-3d: frontier reports — bpy boundary,
navagent dissection, unknowns map"*). Last measurement pass `2026-10-18T14:19:38-03:00`.
**Tracked-tree state at write:** `git diff --name-only` empty; **12** untracked paths, all
round-101 artifacts (`corpus/knowledge/unreal-mcp/`, `reports/round-101/probes/`, ten
`reports/round-101/r101-*.md`). No `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`,
`PROVINCE.md`, fixture or lesson byte was modified this round.

**Concurrency disclosure.** This round's artifacts landed *while this report was being drafted*
— the card set went 0 → 2 → 11 → 12 → 13, and both C3 files landed mid-draft. Every number below
is stamped with the command that produced it; counts that move under concurrent seats are marked
**[moving]** and must be re-measured at `1659c036c961c6cdfd0b2679db72ecb9517a2f3b`.

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.
Numbers marked `{{…}}` are round-close slots this scribe cannot measure; every other number
below was produced by a command run on this host, in this session.

---

## Work performed

One bullet per item, each with its evidence pointer.

- **C1 — vendored the pinned upstream tree byte-identical, with provenance manifests.**
  `corpus/knowledge/unreal-mcp/upstream/` holds **12/12** tracked upstream files
  (63 556 bytes, 1 022 lines, no symlinks/submodules/LFS). Evidence:
  `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` →
  12 × `OK`, exit `0`; `diff -r --exclude=.git corpus/knowledge/unreal-mcp/upstream /tmp/ue-skills-ref`
  → clean, exit `0`.
- **C1 — provenance manifests.** `.manifest.d/` carries `audit-reference.sha256` (12 rows,
  SEAT-15) plus eleven per-seat shards `seat01…seat11` (seat11 covers two dotfiles);
  **12 manifest files** total. Evidence: `ls corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 | wc -l` → 12.
- **C2 — 13 subsystem executability verdict cards, each labeled exactly once.**
  `corpus/knowledge/unreal-mcp/executability/` holds 13 cards. Evidence: the verifier-chair's
  own `label-scan.sh` (materialised from `reports/round-101/r101-verification-protocol.md` §0)
  → `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`, exit `0`.
- **C2 — label census.** 12 × `static-only`, 1 × `unproven-runtime`
  (`executability/actors-scene.md:5`), **0 × `verified-here`** — the expected shape on a host
  with no editor.
- **C3 — Claude→Kimi adaptation table + proven/unproven policy.** Both declared files landed
  during this report's drafting. `adaptation-kimi.md` (20 525 B, 330 lines) carries the
  **15-row** adaptation table at §1 — every row with a non-empty source pointer, **6
  `verified-here` / 9 `static-only` / 0 `unproven-runtime`** — plus the three-class evidence
  policy at §5 and the unproven-runtime register at §6. `PROVENANCE.md` (16 666 B) carries the
  pin, byte-identity, license and install receipts across 7 sections. The binary policy itself
  is at `corpus/knowledge/unreal-mcp/README.md:12`, with the card-label mapping at `:33`.
  Evidence: row census of §1; `pointer-check.sh corpus/knowledge/unreal-mcp` →
  `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`.
- **Evidence probes (14 files).** `reports/round-101/probes/`: `byte-identity-reference.md`,
  `hook-shellcheck.md`, `install-path.md`, `license-audit.md`, `md-links.md`,
  `operations-inventory.md`, `plugin-json.md`, `prereq-matrix.md`, `r22-relation.md`,
  `security-surface.md`, `skill-frontmatter.md`, `toolset-census.md`, `ue-version-matrix.md`.
  Evidence: `ls reports/round-101/probes/*.md | wc -l` → 14.
- **Non-author verification landed.** `r101-reviewer-c1.md` (SEAT-44): **C1 CONFIRMED**, 12/12
  byte-identical across four independent transports (clone, codeload tarball, GitHub API blob
  SHA1, local `cmp`), path sets equal both ways, negative control flips the gate to exit `1`.
  `r101-mutation-tester.md` (SEAT-54): **PROVEN** — 11 content/structural mutations all caught,
  including a hand-edited manifest digest and a deleted listed file.
- **Adversarial and reconciliation reports.** `r101-critic-c1.md` (SEAT-45) argues C1 is
  *under-scoped* as worded ("all upstream content" vs "the pin"); `r101-connector.md` (SEAT-52)
  maps the subtree onto the lane's existing frontier; `r101-scribe-audit.md` (SEAT-55) inventories
  the report directory; `r101-scout-roster.md`, `r101-verification-protocol.md` (SEAT-64).
- **Close-out gates materialised and run.** This scribe extracted the four self-contained check
  scripts from `r101-verification-protocol.md` §0 into `/tmp/r101-closeout/` and executed all
  four against the live tree (results in Before → after below). No repo file was written by
  this seat other than this report.
- **Zero-execution disclosure.** Unreal Editor is **not installed** on this host; the AUR
  `unreal-engine` 5.8.2-1 PKGBUILD requires SSH access to `git@github.com:EpicGames/UnrealEngine`
  and `gh` is authed as `VeigaPunk`, not Epic-linked. Every live-editor claim in this round is
  **unproven-on-this-host by construction** — labelled, never asserted.

---

## Landed changes

Each row is tied to its round-101 artifact and the commit that carries it
(`1659c036c961c6cdfd0b2679db72ecb9517a2f3b` for everything below, since the whole round lands in one commit).

| artifact | what it is | pointer |
|---|---|---|
| `corpus/knowledge/unreal-mcp/upstream/**` | 12 vendored upstream files, byte-identical at the pin | `corpus/knowledge/unreal-mcp/upstream/` |
| `corpus/knowledge/unreal-mcp/.manifest.d/` | `audit-reference.sha256` (12 rows) + `seat01…seat11` shards | `.manifest.d/audit-reference.sha256` |
| `corpus/knowledge/unreal-mcp/README.md` | subtree index: provenance, layout, verification policy, card table, reproduce block | `:12`, `:33`, `:74`, `:116`, `:204`, `:257` |
| `corpus/knowledge/unreal-mcp/executability/*.md` | 13 subsystem verdict cards, one label each | `executability/` |
| `corpus/knowledge/unreal-mcp/PROVENANCE.md` | provenance manifest: pin, byte-identity, license, install receipts (7 sections) | `corpus/knowledge/unreal-mcp/PROVENANCE.md` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | Claude→Kimi adaptation table (15 rows) + three-class verification policy + unproven register | `adaptation-kimi.md:22`, `:267`, `:303` |
| `reports/round-101/probes/*.md` | 14 evidence probes (static checks run here) | `reports/round-101/probes/` |
| `reports/round-101/r101-*.md` | verification, adversarial, connector, roster, protocol reports | `reports/round-101/` |
| `reports/round-101/r101-report.md` | this report | this file |

**Not landed by this round (explicitly):** no `LOG.md` entry, no `SCORECARD.md` axis row, no
`SHONEN.md` box flip, no `SKILL.md` or `PROVINCE.md` edit, no `corpus/lessons/` entry, no
`corpus/knowledge/engines.md` row. The Unreal engine row in `engines.md:10` still reads
`installed: no / executable headless: no` — correct, and unchanged this round.

---

## Before → after measurements

One block per claim. Each carries the counting command and the revision it was measured against.
All commands were run from the lane root unless the block says otherwise.

**Measured revision:** report base HEAD `cb87233`, with the r101 artifacts untracked on disk
(this is the surface the gates below were run against). At round close the same commands must be
re-run on `1659c036c961c6cdfd0b2679db72ecb9517a2f3b`; a number that does not reproduce there is a FAIL for its claim.

### C1 — coverage: vendored byte-identity

| measurement | command | before | after |
|---|---|---|---|
| vendored upstream files | `find corpus/knowledge/unreal-mcp/upstream -type f \| wc -l` | 0 (subtree absent) | **12** |
| manifest files | `ls corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 \| wc -l` | 0 | **12** |
| manifest entries verified | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | n/a | **12 × `OK`, exit 0** |
| clone diff | `diff -r --exclude=.git corpus/knowledge/unreal-mcp/upstream /tmp/ue-skills-ref` | n/a | **clean, exit 0** |
| pin identity | `git -C /tmp/ue-skills-ref rev-parse HEAD` | n/a | **`a6aa73ada02a9fb1f5415bec491f9942c519b297`** (== pin) |
| upstream bytes vendored | `find …/upstream -type f -exec cat {} + \| wc -c` | 0 | **63 556** |
| non-author verdict | `reports/round-101/r101-reviewer-c1.md:20` | — | **C1 CONFIRMED** |
| mutation verdict | `reports/round-101/r101-mutation-tester.md` §10 | — | **PROVEN** (11/11 content mutations caught) |

**Known coverage gaps this claim does not close** (stated, not hidden): the mutation tester's
own residual list is that `sha256sum -c` alone cannot see an **extra unlisted file** — the
set-equality check against `git ls-files` catches that — and that **file mode and mtime** are
out of scope by design. `r101-critic-c1.md` further argues the wording "all upstream content
files" is under-scoped against "the pin": nothing outside the pinned commit is vendored, and
that is intentional.

### C2 — depth: 13 labeled verdict cards

| measurement | command | before | after |
|---|---|---|---|
| card count | `bash /tmp/r101-closeout/label-scan.sh` | 0 cards → `CARDS=0 EXPECTED=13` | **`CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`, exit 0** |
| `static-only` | same scanner output | — | **12** |
| `unproven-runtime` | same scanner output | — | **1** (`executability/actors-scene.md:5`) |
| `verified-here` | same scanner output | — | **0** |
| multi-label / unlabeled cards | same scanner output (`BAD`) | — | **0** |
| live-editor surface mentions left unlabeled | `bash /tmp/r101-closeout/runtime-claim-scan.sh` | — | **`UNLABELED=0` / `STEP=PASS`** — the denominator grows as seats land (`22` → `26` across this draft; the **zero** is the stable property) |
| vendored md relative links | `bash /tmp/r101-closeout/linkcheck.sh` | — | **`md_files=6 links_total=3 broken=0` / `STEP=PASS`** |
| `upstream/<path>:<line>` pointers, subtree only | `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` | — | **`POINTERS=40 UNRESOLVED=0` / `STEP=PASS`** |
| pointers, whole round minus the protocol's negative controls | see the sweep in the note below | — | **`POINTERS=78 UNRESOLVED=0` / `STEP=PASS`** |

**Note on the pointer sweep [O].** An unfiltered sweep of `reports/round-101` reports
`UNRESOLVED=2` / `STEP=FAIL`, but both hits are *deliberate negative controls*, not broken
pointers. `reports/round-101/r101-verification-protocol.md` step 7 instructs the verifier to
plant two unresolvable pointers — one to a file that does not exist, one to a line past the end
of a real file — and to expect `STEP=FAIL` from the control. The scanner walks `reports/round-101`
wholesale, so it counts those control strings as real pointers; this report named them when first
drafted, which made this file a second contaminating source.

**De-contaminated and re-measured [O].** Both strings have been removed from this file. The
verifier-chair's own protocol file still carries them by design, so the correct close-out sweep is
the subtree plus every round report **except** that one file:

```sh
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp \
  reports/round-101/probes reports/round-101/r101-report.md \
  reports/round-101/r101-reviewer-c1.md reports/round-101/r101-reviewer-c2.md \
  reports/round-101/r101-mutation-tester.md reports/round-101/r101-critic-c1.md \
  reports/round-101/r101-connector.md reports/round-101/r101-scout-roster.md \
  reports/round-101/r101-scribe-audit.md
```

Observed after de-contamination, on the report base: **`POINTERS=78 UNRESOLVED=0` / `STEP=PASS`**.
Re-measured at close on the committed tree (`1659c036c961c6cdfd0b2679db72ecb9517a2f3b`): **unchanged, 78 / 0 PASS**. The unfiltered
sweep over `reports/round-101` will always read `UNRESOLVED=2` for as long as the protocol's
controls stand — that is the scanner's known self-contamination, not a C3 defect.

### C3 — calibration: adaptation table + verification policy

| measurement | command | before | after |
|---|---|---|---|
| binary `proven`/`unproven` policy present | `sed -n '12,40p' corpus/knowledge/unreal-mcp/README.md` | absent | **present**, with the ternary→binary mapping table at `:33` |
| three-class evidence policy (proven-here / static-only / unproven-runtime) | `sed -n '267,302p' corpus/knowledge/unreal-mcp/adaptation-kimi.md` | absent | **present** (§5), incl. promotion, invalidation, negative-claim and live-editor rules |
| unproven-runtime register | `sed -n '303,316p' corpus/knowledge/unreal-mcp/adaptation-kimi.md` | absent | **present** (§6), 5 items each with "what would settle it" |
| `PROVENANCE.md` | `ls -la corpus/knowledge/unreal-mcp/PROVENANCE.md` | absent | **present, 16 666 B**, 7 sections, pin + byte-identity + license + install receipts |
| `adaptation-kimi.md` | `ls -la corpus/knowledge/unreal-mcp/adaptation-kimi.md` | absent | **present, 20 525 B / 330 lines**, 7 sections |
| adaptation table rows | row census of §1's table | 0 | **15 rows, 0 with an empty pointer column** |
| row status census | same | — | **6 × `verified-here`, 9 × `static-only`, 0 × `unproven-runtime`** |
| distinct `upstream/…:line` pointers inside `adaptation-kimi.md` | `grep -ohE 'upstream/…:[0-9]+' \| sort -u \| wc -l` | 0 | **17** |
| distinct `upstream/…:line` pointers across all 3 index files + 13 cards | same, over the subtree's non-upstream md | 0 | **38** |
| unresolvable pointers, subtree | `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` | — | **`POINTERS=40 UNRESOLVED=0` / `STEP=PASS`** |

**C3 closes at the report base [O].** Both declared files landed while this report was being
drafted: `PROVENANCE.md` at `14:17`, `adaptation-kimi.md` at `14:18`. The earlier drafts of this
report recorded them as absent — that reading was correct when taken and is superseded here. The
`r101-connector.md` §4.2 concern (*"a declared-layout file that does not exist is a broken promise
in the artifact that other seats will cite"*) is therefore resolved by landing, not by correcting
the index. The subtree `README.md` layout block still labels both as `(pending: …)`, which is now
stale text rather than a missing artifact — cosmetic, worth one edit if a later seat touches it.

### Round-level deltas (unchanged surfaces, measured so they are known not to have moved)

| surface | command | value |
|---|---|---|
| battery rows | AST parse of `CASES` in `corpus/fixtures/run_battery.py` | **350** (HEAD and worktree identical, sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`) |
| `corpus/lessons/` entries | `ls corpus/lessons \| wc -l` | **92** (no r101 lesson landed) |
| `LOG.md` / `SCORECARD.md` last round | `grep -n 'ROUND 100' LOG.md`, `grep -n 'Round 98' SCORECARD.md` | **Round 100 / Round 98** — r101 not yet recorded (expected pre-adjudication) |
| engine census Unreal row | `grep -n Unreal corpus/knowledge/engines.md` | `:10` — `installed: no / executable headless: no`, unchanged |
| subtree file count | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | **40** (upstream 12 + manifests 12 + index 3 + cards 13); re-measured on `1659c036`: **40** |
| round-101 report files | `find reports/round-101 -type f \| wc -l` | **33** at close (14 probes + 19 top-level `.md`, incl. this report) |
| untracked paths at work-commit | `git status --porcelain=v1 \| wc -l` | **1** (this report only; everything else in `1659c036`) |

---

## SHONEN 4-box lines

`SHONEN.md` currently reads box 2 `[x]` (r2 verifier) and boxes 1, 3, 4 `[ ]`. Per the skill's
report shape, one line per box. Marks below are this round's **evidence pointers**, not
self-attested checks: a `[x]` requires a named non-author verifier, a `[~]` is the lane's own
assessment with a resolvable pointer, and an untouched box stays `[ ]`.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]`
  Round r101 adds cited, checkable tables but **no** distilled decision table into `SKILL.md`
  (untouched this round): the 13-domain capability census with per-domain toolset pointers
  (`reports/round-101/probes/toolset-census.md` §E3), the `.manifest.d` provenance table
  (`corpus/knowledge/unreal-mcp/README.md:116`), the ternary→binary label mapping
  (`README.md:31-48`), the 15-row Claude→Kimi adaptation table
  (`corpus/knowledge/unreal-mcp/adaptation-kimi.md:22`), and the error patterns in
  `probes/hook-shellcheck.md` §6 (the incomplete JSON escaper, lines 80–82). Box stays open
  until a non-author verifier accepts them as the skill's own tables rather than round
  artifacts. Verifier for promotion: none named this round — queued for a future promotion review.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2 —
  `game-dev-3d-r2-review-retry` independently reproduced both battery commands, the mutation
  rejection and the source contact-plane derivation (`corpus/lessons/r2-independent-review.md`).
  **r101 does not add an end-to-end task**: no Unreal Editor exists on this host, so the round's
  own work is static/format evidence by construction, and no runtime claim is made anywhere.
- **Box 3 — instructions executable without oral context.** `[~]` The round ships a
  self-contained close-out protocol (`reports/round-101/r101-verification-protocol.md`) whose
  four check scripts were extracted and executed verbatim by this seat with no author input —
  `label-scan.sh` `STEP=PASS`, `runtime-claim-scan.sh` `STEP=PASS`, `linkcheck.sh` `STEP=PASS`,
  `pointer-check.sh` `STEP=PASS` once the protocol's own negative controls are excluded (it reads
  `STEP=FAIL` if they are swept in, by design). `corpus/knowledge/unreal-mcp/README.md:257`
  carries a four-command reproduce block, and `adaptation-kimi.md:143` carries five live probes
  with pasted output. No open blocker remains on this box's evidence. Verifier: none named this
  round — the L1 re-ran all four scripts on the committed tree (`1659c036`) green.
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` Every r101 artifact
  lives under the lane's own write scope (`corpus/knowledge/unreal-mcp/**`,
  `reports/round-101/**`); `git diff --name-only` at write is empty and all round paths are
  r101 artifacts. The work is **static inspection in service of 3D craft evidence**, which
  `PROVINCE.md` explicitly permits for engines that cannot execute headless — *"the lane builds
  format-level and static fixtures … and labels runtime behavior unproven — never fabricating
  runtime evidence."* `PROVINCE.md` names Unreal in its owned engine list and its `engines.md`
  row is unchanged. No 2D, harness-audit, lore or live-target surface was touched. Verifier:
  none named this round — scout rejected-fit table (`r101-scout-roster.md`) supports the claim.

---

## Reproduce at close

Run from the lane root, on `1659c036c961c6cdfd0b2679db72ecb9517a2f3b`, after the untracked artifacts are committed:

```sh
# C1 — byte-identity, pin, clone diff
git -C /tmp/ue-skills-ref rev-parse HEAD            # a6aa73ada02a9fb1f5415bec491f9942c519b297
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 ; echo "rc=$?"
diff -r --exclude=.git upstream /tmp/ue-skills-ref ; echo "rc=$?"
cd -

# C2 — the 13 cards, one label each (verifier-chair script, re-extract from the protocol if absent)
bash /tmp/r101-closeout/label-scan.sh               # CARDS=13 EXPECTED=13 BAD=0 / STEP=PASS
bash /tmp/r101-closeout/runtime-claim-scan.sh       # UNLABELED=0 / STEP=PASS
bash /tmp/r101-closeout/linkcheck.sh                # broken=0 / STEP=PASS

# C3 — pointers, excluding the protocol file's own negative controls
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp reports/round-101/probes \
  reports/round-101/r101-report.md reports/round-101/r101-reviewer-c1.md \
  reports/round-101/r101-reviewer-c2.md reports/round-101/r101-mutation-tester.md \
  reports/round-101/r101-critic-c1.md reports/round-101/r101-connector.md \
  reports/round-101/r101-scout-roster.md reports/round-101/r101-scribe-audit.md
# observed 2026-10-18T14:20Z: POINTERS=78 UNRESOLVED=0 / STEP=PASS
```

The four scripts are also reproduced inline in `reports/round-101/r101-verification-protocol.md`
§0, so a verifier never depends on a leftover `/tmp` file.

---

## Open items for the L1 / adjudicator

1. **`1659c036c961c6cdfd0b2679db72ecb9517a2f3b`** — this report is written pre-landing; the hash slot and every
   round-close number above must be filled from the committed tree. Counts marked **[moving]**
   moved repeatedly during drafting and are the likeliest to need re-measurement.
2. **`pointer-check.sh` self-contaminates** on the protocol's negative controls; sweep
   `reports/round-101` wholesale and the step reads `UNRESOLVED=2` / `STEP=FAIL` on strings the
   protocol itself tells the verifier to plant. Use the exclusion list above, or drop
   `r101-verification-protocol.md` from the sweep. (This report briefly carried the same
   contamination by quoting those strings; it has been removed.)
3. **The subtree `README.md` layout block is now stale text.** `:109`–`:110` still label
   `PROVENANCE.md` and `adaptation-kimi.md` as `(pending: …)` although both landed. Cosmetic
   only — one edit if a later seat touches the file. This is a *writer* surface, so this scribe
   did not touch it.
4. **C1 scope wording.** `r101-critic-c1.md` holds that "all upstream content files" is
   under-scoped against "the pinned commit". The vendoring is byte-perfect either way; the
   question is whether the claim's wording should be tightened at adjudication.
5. **C3's `verified-here` rows are Kimi-side, not Unreal-side.** 6 of the 15 adaptation rows are
   `verified-here` because they were reproduced against this host's Kimi CLI (BuildID
   `5e67bdf95c7646325b62decd0ca8d375d325ea19`, v2.2.0) — not against Unreal. `adaptation-kimi.md`
   §5 states the invalidation rule: any "`kimi` binary strings line N" pointer dies on a CLI
   upgrade. Nothing in C3 asserts Unreal behaviour.
6. **No live-editor evidence exists or can exist here.** Engine install is blocked pending
   operator Epic-account linking (AUR `unreal-engine` 5.8.2-1 PKGBUILD needs
   `git@github.com:EpicGames/UnrealEngine`). Every runtime claim in this round is
   `unproven-on-this-host`; nothing in the round asserts otherwise.

---

## L1 adjudication (close-out) — 2026-10-18

**Verdicts:** coverage **improved** · depth **improved** · calibration **improved**. No axis
harmed, no trade — the round **admits** (work commit `1659c036c961c6cdfd0b2679db72ecb9517a2f3b`,
this report lands last).

**Claim-scope adoption:** C1 is scored as *"all files tracked at the pinned commit"* —
12/12, byte-identical. The adversarial finding that "all upstream content" reaches beyond the
pin (5 PR-only paths, 1 history-only file) is accepted and recorded in `PROVENANCE.md` §8,
not vendored.

**Folds landed at close (both critic findings verified against current bytes before edit):**
`executability/meshes-textures.md:254` index line-cites corrected to `README.md:213-227` /
quote at `:209`; `executability/assets-content.md` "17 words" corrected to **13**
(`sed -n '102p' upstream/README.md | sed 's/^- \*\*Assets and Content\*\* - //' | wc -w` → 13).
Also folded: subtree `README.md` layout block no longer labels `PROVENANCE.md` /
`adaptation-kimi.md` as pending (both landed during the round).

**Routed queue (future rounds, recorded in LOG.md ROUND 101):** six pre-existing lane
defects from `r101-critic-c3.md` (r22 path drift, missing `verdicts.json`, sha drift,
`engines.md` three.js command, `rea.md` tool census, README glob line-count); connector
IP-2 (battery digest map covers 0 `corpus/knowledge/` files); sentinel S-5/S-8 (hook
`PATH`-shadowed `basename`; `.mcp.json` auto-load with `Origin: null`).

**L0 questions for the operator:** (1) link an Epic Games account to GitHub so
`EpicGames/UnrealEngine` source becomes fetchable? (2) authorize pulling the public
`wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB, contents unverified) as a possible
runtime unlock? (3) prefer the Lutris/Epic-launcher path instead? All three are
operator-owned; the lane proceeds static-only without them.

**Honest limits:** no live-editor evidence exists or can exist on this host; the C3
`verified-here` rows are Kimi-side probes only; the 27 GB container route is recorded, not
evaluated; report counts are close-of-round measurements on `1659c036`.
