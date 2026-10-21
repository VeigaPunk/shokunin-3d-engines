# r107-mut-card — MUT-CARD seat (round 107, 3D side-round)

KEY=MUT-CARD. Mutation seat: **corrupt one executability card's path** and prove the
cards review catches it. Shard `reports/round-107/r107-mut-card.md`.
Scratch `/var/tmp/r107-mut-card/`. Lane `game-dev-3d-shokunin`, branch `main`.

## Plan header (5 lines)

1. Establish the two "path" surfaces a card carries — its own **filename** (gate CHECK 3
   `PINNED_CARD_NAMES`) and its in-body **citation pointers** (`upstream/<path>:<line>`,
   gate CHECK 4 pointer sweep) — plus the cards-critic review procedure as a second reviewer.
2. Stage a full throwaway copy of the lane repo at `/var/tmp/r107-mut-card/stage/lane` so the
   gate's `REPO_ROOT` (= `SUB/../../..`) resolves exactly as in production; never write into
   `corpus/knowledge/unreal-mcp/`.
3. Baseline first: the UNMUTATED staged tree must run the real `gate/run_gate.sh` green
   (CHECK 3 + CHECK 4 `STEP=PASS`) — a mutation harness only counts if clean passes.
4. Apply one mutation per variant, one card at a time: M1 filename, M2 pointer path,
   M3 pointer line-out-of-range, M4 header `Vendored at` path, M5 label token, M6 backtick
   repo-relative path — each confirmed to have landed byte-level, then re-run the gate and
   the cards review.
5. Report a detection matrix (mutation × {gate CHECK 3, gate CHECK 4, cards review}), exact
   commands + observed output, exit codes, and what is explicitly NOT proven; label [O]/[I]/[?].

## Axes (Godspeed)

- A1 falsifiability: each variant carries the command that must produce a FAIL; a mutation
  that nothing catches is reported as a *gate hole*, not silently dropped.
- A2 fidelity: the harness runs the **real, unmodified** `run_gate.sh` (copied bytes), not a
  paraphrase; the mutation lands on a copy of the real card bytes.
- A3 independence: the cards-review checker is written from the card's *own* claims (extract
  every cited path, resolve it), not from the gate's regex, so the two reviewers disagree
  independently.
- A4 non-harm: writes confined to `reports/round-107/` + `/var/tmp/r107-mut-card/`; no
  `corpus/` landing; no engine, no network write, no battery run.

## Status

- **COMPLETE.** 10 variants run (1 clean control + 9 mutations). Two independent gate blind
  spots found (three variants); all caught by the cards review. Artifacts drafted, nothing
  landed in `corpus/`.

---

## 0. Method and environment

[O] All runs on this host, 2026-10-19, lane `game-dev-3d-shokunin`.

```
$ df -h /var/tmp | tail -1
/dev/mapper/root  930G  174G  744G  19% /

$ git -C /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin rev-parse HEAD
3ea02ffaafc6c618bb97a19f103a3d28ecdc2638
```

[O] Staged copy of the whole lane (so the gate's `REPO_ROOT=SUB/../../..` resolves the same
way it does in production):

```
$ cp -a /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin /var/tmp/r107-mut-card/stage/lane
real 0m2.8s ; 2.2G

$ # staged subtree vs live lane, file-by-file
IDENTICAL=42 DIFFERENT=0
```

[O] Variant trees are `cp -al` hardlink clones of the staged copy (`~1.7 s`, `1.8G` apparent,
negligible real usage), so each variant starts from pristine bytes at zero disk cost.

Artifacts produced by this seat (drafts; orchestrator lands):

| file | role |
|---|---|
| `reports/round-107/mutations/mut-card.sh` | the mutation harness (10 variants, two reviewers) |
| `reports/round-107/mutations/cards-review.sh` | independent cards reviewer (the "cards review" half) |
| `reports/round-107/mutations/mut-card-matrix.txt` | verbatim run matrix, 187 lines |

## 1. What "a card's path" actually is

[O] Two distinct path surfaces, both carried by every card:

1. **The card's own filename** — gate CHECK 3 pins the 13 stems:
   `PINNED_CARD_NAMES='actors-scene animation-controlrig assets-content blueprints
   editor-general gameplay-gas materials meshes-textures scripting-programmatic sequencer
   testing-automation ui-umg-slate vfx-niagara-dataflow'` (`gate/run_gate.sh:84`).
2. **In-body citation pointers** — the card claims facts *at* a path:line in the vendored
   tree, e.g. `upstream/README.md:106`, and repo-relative paths such as
   `corpus/knowledge/unreal-mcp/upstream/` in the `**Vendored at:**` header line.

[O] CHECK 4's baseline is `POINTERS=103 POINTER_STRINGS=41` — but those are **subtree-wide**,
not card-only. Re-running the gate's own loops by hand decomposes them:

| scope | unique pointer strings | endpoints |
|---|---|---|
| pass 1 — `upstream/<path>:<line>` citations, all non-`upstream/` files | 41 | 47 |
| pass 2 — backticked repo-relative paths (HARDENING G) | (not counted by the gate) | 56 |
| **gate total** | **`POINTER_STRINGS=41`** | **`POINTERS=103`** |

[O] `POINTER_STRINGS` counts pass 1 only; `POINTERS` sums both passes. The pass-1 citations
live in `adaptation-kimi.md` (18), `executability/sequencer.md` (7), `executability/ui-umg-slate.md` (7),
`executability/assets-content.md` (6), `executability/editor-general.md` (2),
`executability/vfx-niagara-dataflow.md` (1).
[O] **Card-only** (the 13 `executability/*.md`): 6 of the 13 cards cite upstream at all —
**20 unique pointer strings / 30 endpoints**. So the cards are roughly half of pass 1 and a
minority of the 103 total; the rest is this subtree's own prose.
[O] `**Vendored at:**` is present in **7 of the 13** cards — `actors-scene`, `animation-controlrig`,
`blueprints`, `editor-general`, `gameplay-gas`, `materials`, `meshes-textures`
(`grep -l '^\*\*Vendored at:\*\*' executability/*.md | wc -l` → 7); the other 6 declare the
vendored tree in other words. M4 targets `blueprints.md:7`.

## 2. Baseline — the clean control (M0)

```
$ GATE_WORKDIR=/var/tmp/r107-mut-card bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE RESULT: PASS (checks failed: 0)          # exit 0
CHECK 3 ... CARDS=13 EXPECTED=13 BAD=0
        CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
        NAME_SET=OK NAME_BAD=0                # STEP=PASS
CHECK 4 POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0  # STEP=PASS
```

[O] Same result on the live lane tree and on the staged copy. The harness is therefore
anchored: a variant's exit 1 is the mutation's effect, not harness noise.

## 3. Detection matrix

Reviewer `G` = `corpus/knowledge/unreal-mcp/gate/run_gate.sh`; `R` = `cards-review.sh`.
Full verbatim output: `reports/round-107/mutations/mut-card-matrix.txt`.

| # | mutation (one card, one path) | G exit | G CHECK 3 | G CHECK 4 | R exit | caught by |
|---|---|---|---|---|---|---|
| M0 | none (control) | 0 | PASS | PASS | 0 | — |
| M1 | `executability/blueprints.md` → `blueprint.md` (filename typo) | 1 | **FAIL** | **FAIL** | 1 | both |
| M2 | `upstream/README.md:106` → `upstream/READMEE.md:106` | 1 | PASS | **FAIL** | 1 | both |
| M3 | `upstream/README.md:106` → `upstream/README.md:4242` | 1 | PASS | **FAIL** | 1 | both |
| M4 | `**Vendored at:**` `.../upstream/` → `.../upstreme/` | **0** | PASS | PASS | 1 | **review only** |
| M5 | `**Label:** static-only` → `verified-here` | 1 | **FAIL** | PASS | 1 | both |
| M6 | backticked `.../executability/blueprints.md` → `blueprints-typo.md` | 1 | PASS | **FAIL** | 1 | both |
| M7a | backticked `corpus/.../README.md:213-227` → `:9999` | **0** | PASS | PASS | 1 | **review only** |
| M7b | backticked `.../blueprints.md` → `.../blueprints.md:5000` | **0** | PASS | PASS | 1 | **review only** |
| M8 | bare `upstream/README.md:4242` (no backticks) | 1 | PASS | **FAIL** | 1 | both |

[O] **The clean control is green on both reviewers and every mutation is red on at least one.**
[O] Three variants (M4, M7a, M7b) leave the close-out gate **completely green (exit 0)** and
are caught only by the cards review. That is the answer to this seat's question, and it is a
"no" for the gate alone.

### Evidence for the three gate holes (verbatim from the matrix)

M4:
```
gate exit=0  GATE RESULT: PASS (checks failed: 0)
  G| POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
review exit=1
  R| REVIEW-FAIL blueprints.md UNRESOLVED-LOCAL-PATH `corpus/knowledge/unreal-mcp/upstreme/`
  R| REVIEW-FAIL blueprints.md VENDORED-AT-NOT-A-DIR `corpus/knowledge/unreal-mcp/upstreme/`
```

M7a:
```
gate exit=0  GATE RESULT: PASS (checks failed: 0)
review exit=1
  R| REVIEW-FAIL meshes-textures.md LINE-OOR `corpus/knowledge/unreal-mcp/README.md:9999` (max 278)
```

M7b (same class, path that previously carried no line suffix):
```
gate exit=0  GATE RESULT: PASS (checks failed: 0)
  G| POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
review exit=1
  R| REVIEW-FAIL meshes-textures.md LINE-OOR `corpus/knowledge/unreal-mcp/executability/blueprints.md:5000` (max 155)
```

## 4. Root cause of the two holes, in the gate's own source

[O] **Hole 1 — M4 (`Vendored at`).** The header line is
`**Vendored at:** \`corpus/knowledge/unreal-mcp/upstream/\``. CHECK 4's backtick sweep only
matches tokens ending in a known extension:

```
gate/run_gate.sh:427
done < <({ grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' --include='*.md' "$SUB" 2>/dev/null; ... }
```

[O] A directory path (`.../upstream/`) has no extension and matches nothing. The sibling
`upstream/<path>:<line>` regex (`:407`) also misses it, because the token is
`corpus/knowledge/...`, not `upstream/...`. [I] The consequence: **the single line that
asserts where the card's bytes came from is the one path in the card the gate never checks.**
(It is not the *only* such path — every short-form token, e.g. `references/setup.md`, is
equally invisible to this sweep; see §9.4.)

[O] **Hole 2 — M7 (`path:line`).** The same sweep strips the line suffix *before* the
existence test, and only after the match:

```
gate/run_gate.sh:427 (tail)  ... | tr -d '`' | sed 's/:[0-9]\+$//' | sort -u
```

[O] The match itself does allow `(:[0-9]+)?`, but the suffix is discarded by `sed`, so
`README.md:9999` is tested as `README.md` — the file exists and the check passes. [I] The
line number in a backticked `path:line` citation is therefore **never range-validated** by
CHECK 4.

[O] Contrast: the `upstream/<path>:<line>` pass *does* validate endpoints (A1, SEAT-09 r103,
one `P_TOTAL` increment per endpoint), which is why M2/M3/M8 are caught. The gap is specific
to the backticked repo-relative pass.

[O] **M8 is a negative result worth keeping.** I expected the gate's `[^\`"|)]+` character
class to be blocked by the backtick before `upstream/`, making a bare in-table citation
invisible. It is not: `POINTERS=104` and `LINE-OOR ... upstream/README.md:4242 (max 112)`.
The `\`` inside the bracket expression is a literal backtick in ERE, and the regex starts
matching at `upstream/` itself, so both backticked and bare forms are swept. **No hole.**

## 5. Reviewer bugs found while building this (and fixed)

Recorded because each one would have produced a wrong verdict.

[O] **(a) My own reviewer missed M7 on the first run.** R3a's token regex was
`` `[A-Za-z0-9_.-][A-Za-z0-9_./-]*` `` — it excludes `:`, so `path:line` was never captured
and `M7-relpath-line review_exit=0`. Fixed by admitting `:` into the class
(`` [A-Za-z0-9_.:/-]* ``) and splitting the token at the last `:` before the filesystem test.
**The first matrix run reported M7 as undetected by both reviewers; that was a reviewer
defect, not a second hole.** After the fix, M7a/M7b are `review_exit=1`.

[O] **(b) `assets-content.md` declares its label on a later line.** Its first 40 lines are
`# SEAT-33 — Verdict card: ...`, then `## Verdict`, then `**\`static-only\`**`. A reviewer
that greps only for `**Label:**` reports `no-label` on a clean tree (12/13 labeled). Fixed by
reusing the gate's five anchored declaration shapes, which include `**\`X\`**`.

[O] **(c) Over-broad path tier.** Treating every backticked token containing `/` as a path
claim flagged `EpicGames/UnrealEngine` (a repo slug), `tools/list` (an MCP method) and
`references/setup.md` (a documented short form) — 49 false positives on a clean tree. Split
into R3a (strict: first segment is a known local root — a failure) and R3b (advisory, counted
and printed, never a failure). Advisory count rose to 248 tokens (110 unique) after the `:`
widening; still 0 failures on the clean tree.

[O] **(d) The advisory tier is not merely a false-positive filter — it hides real dangling
paths.** Offline experiment (not part of the harness): of the 110 unique card advisory tokens,
**94 resolve** once short-form bases (`upstream/skills/unreal-mcp/`, `upstream/skills/`,
`upstream/`) are tried; **16 do not**, and they are not all noise:

- `Engine/Binaries/Linux/UnrealEditor-Cmd`, `Engine/Plugins/Experimental/…`,
  `Intermediate/PythonStub/unreal.py`, `Toolsets/` — editor-install paths, correct not to resolve;
- `EpicGames/…`, `tools/list`, `http://127.0.0.1:8000/mcp`, URLs — not path claims;
- `be8c1833…:skills/unreal-mcp/SKILL.md` — a `git rev-parse` argument, not a path;
- **`references/toolsets.md` and `skills/unreal-mcp/references/toolsets.md` — a real dangling
  path.** `ls upstream/skills/unreal-mcp/references/` → only `operations.md` and `setup.md`.
  The cards *intend* this: `materials.md:126` calls it "a per-toolset capability reference,
  **deleted before the pin**", cited via `git show 823f598^:…` and present only in history.

[I] So a reviewer cannot classify these mechanically without reading each card's prose — but
the class is now *enumerated*: 16 tokens, 15 benign, 1 dangling-by-design. Carried forward as
a known limitation rather than an unknown one.

## 6. Harness bugs found (a reusable lesson)

[O] **`cp -al` plus in-place rewrite writes through the hardlink.** The first harness used
`python write_text()` directly on a variant file. Because the variant tree and the staged
copy share inodes, that rewrote the **staged source**, so later variants started from already
mutated bytes. Detected by hashing the staged copy against the live lane:

```
sequencer       stage=af261ac9dd9bb89e repo=8ca709e1bb6ebb7a CORRUPTED
blueprints      stage=728da7d099979424 repo=f971ee1e4c74b251 CORRUPTED
materials       stage=2755f513e215c7e2 repo=f5d18a9848a026db CORRUPTED
meshes-textures stage=3102d98a5d1c0985 repo=7f33c3727ca52d51 CORRUPTED
```

[O] Fixed: re-staged from the lane, and every mutation now goes through `edit_file()`, which
`rm -f`s the variant's link first so the replacement gets a private inode, then asserts the
anchor is unique and the post-edit hash differs from the source. [O] The final run's
post-check is the proof the fix holds:

```
=== post-run source integrity (staged copy vs live lane) ===
  STAGED_SOURCE_IDENTICAL=42 DIFFERENT=0
```

[O] Two smaller harness bugs, both fixed: `REVIEW` passed as a relative path while each
variant `cd`s into its own tree (`review_exit=127`); and backticks inside `printf` format
strings executed as command substitution (`**Vendored: command not found`).

[O] **One test-design error, kept in the harness as a comment.** M3 first used
`upstream/README.md:9999` — which is one of the gate's own documented **control sentinels**
(`SENTINEL='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'`, `run_gate.sh:383`),
deliberately skipped by CHECK 4. A green gate there would have proven nothing. M3 now uses
`:4242` (out of range; `README.md` is 112 lines) and is not a sentinel. [O] Confirmed by
`SKIPPED_CONTROL_SENTINELS=0` in every variant's output.

[O] **[Note on M7a's line number.]** M7a rewrites `README.md:213-227` to `README.md:9999`.
That token is in the *backticked* sweep, which has no sentinel filter, so `9999` is a valid
out-of-range value there. The sentinel only applies to the `upstream/` pass — which is exactly
why M3 had to be changed and M7a did not.

## 7. What this does and does not prove

**Proven here [O]:**
- The gate is green on a clean tree and red on M1/M2/M3/M5/M6/M8 — those six classes are
  genuinely covered, and the harness itself is anchored by the clean control.
- Three concrete path corruptures (M4, M7a, M7b) leave the close-out gate **exit 0 / PASS**.
- The independent cards review catches all nine rows including all three gate holes.

**Not proven [I]/[?]:**
- [?] **Coverage is by construction, not exhaustive.** One mutation per class on 4 of the 13
  cards. I did not mutate all 13 cards, nor every pointer in any card. A card whose *only*
  pointer is a `Vendored at` line, or a hole in a card I never touched, is not excluded.
- [?] **No claim about the cards-critic seat's human/LLM procedure.** `cards-review.sh` is a
  *mechanical proxy* for "the cards review". Whether the r107 CARDS-CRITIC seat's prose review
  would catch M4/M7 is not measured here.
- [?] **A mutation that keeps the file set consistent is not tested.** E.g. renaming a card
  *and* updating every citation to it; M1/M6 deliberately corrupt only one side.
- [?] **Gate behaviour under `GATE_REF` (offline) was not exercised.** All runs cloned live.
- [?] **No claim that the two holes matter in practice.** They are latent — a corruption that
  hits M4/M7 would need to survive review by a human or the CARDS-CRITIC seat as well. What is
  proven is narrower and exact: *the automated close-out gate alone does not catch them.*
- [O] No Unreal runtime claim is made or implied anywhere here; nothing was executed against
  an editor, and no engine, container, or network write was involved beyond the gate's own
  anonymous `git clone` of the public upstream repo.

## 8. Reproduce

```
# independent cards review, live tree (read-only)
$ bash reports/round-107/mutations/cards-review.sh corpus/knowledge/unreal-mcp
CARDS-REVIEW cards_labeled=13 expected=13
CARDS-REVIEW FAILS=0 ADVISORY_UNRESOLVED=248
CARDS-REVIEW RESULT: PASS                     # exit 0

# full 10-variant matrix (~28 s; needs a staged lane copy first)
$ cp -a . /var/tmp/r107-mut-card/stage/lane
$ bash reports/round-107/mutations/mut-card.sh \
    /var/tmp/r107-mut-card/harness \
    /var/tmp/r107-mut-card/stage/lane \
    reports/round-107/mutations/cards-review.sh \
    /var/tmp/r107-mut-card/out
M0-clean         gate_exit=0 review_exit=0
M1-filename      gate_exit=1 review_exit=1
M2-pointer-path  gate_exit=1 review_exit=1
M3-line-oor      gate_exit=1 review_exit=1
M4-vendored-at   gate_exit=0 review_exit=1
M5-label         gate_exit=1 review_exit=1
M6-relpath       gate_exit=1 review_exit=1
M7a-relpath-line gate_exit=0 review_exit=1
M7b-relpath-line gate_exit=0 review_exit=1
M8-bare-ptr      gate_exit=1 review_exit=1
```

## 9. Handoff to the orchestrator (draft only — nothing landed)

1. **No `corpus/` landing is proposed by this seat.** Both holes are in
   `corpus/knowledge/unreal-mcp/gate/run_gate.sh`; the fix is a gate change, which is
   GATE-LEAD's artifact, not mine. Drafted here as evidence for that seat.
2. **Suggested gate hardening, if GATE-LEAD wants it** (not implemented here):
   - extend CHECK 4's backtick sweep to also match extension-less directory paths under
     `corpus/`, or add a dedicated `**Vendored at:**` resolution check;
   - in the backticked pass, validate the `:line` endpoint instead of `sed`-ing it away
     (the `upstream/` pass already does this — the two passes disagree today).
3. **`cards-review.sh` is a candidate close-out artifact**: it is a strict superset of the
   gate's card-path checks on the clean tree and catches all three gate holes. If adopted, the
   `ADVISORY_UNRESOLVED` tier must be documented as advisory, not a failure.
4. **Known limitation to carry forward:** the reviewer does not resolve each card's documented
   short forms (`README.md` → `upstream/README.md`, `references/setup.md` →
   `upstream/skills/unreal-mcp/references/…`). Resolving them requires parsing each card's own
   mapping sentence; until then those tokens stay advisory and a corruption in one would be
   missed. The advisory class is at least enumerated in §5(d): 110 unique tokens, 94 resolvable
   with generic short-form bases, 16 not, of which 15 are benign and 1
   (`references/toolsets.md`) is dangling by design.
5. **Runnable artifact for the close-out gate.** If the orchestrator wants the cards review in
   the r107 close-out, `cards-review.sh` needs only `bash` + `coreutils` and takes the subtree
   root as its single argument; it exits 0 on the current clean tree and 1 on every mutated
   variant in the matrix. It writes nothing.
