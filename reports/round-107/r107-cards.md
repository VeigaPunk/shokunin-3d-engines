# r107 · CARDS-LEAD — executability cards re-evaluated at the fresh pin

**Plan (5 lines)**
1. Read the fresh clone at `/var/tmp/r107-va/repo` and confirm the pin + tracked-file set first-hand.
2. Re-derive the subsystem census from the fresh `operations.md`/`setup.md`; confirm it is still 13 cards.
3. For each card, re-check its static-only / unproven-runtime / verified-here verdict against the fresh sources; cite the fresh line ranges.
4. Report deltas vs r101-era cards (byte-level: any tool name, count, or citation that moved).
5. Emit updated card drafts as **deltas only** (orchestrator lands the full files); label every claim [O]/[I]/[?].

**Seat:** KEY=CARDS-LEAD · lane `game-dev-3d-shokunin` · branch `main` · round 107 (3D side-round)
**Scratch:** `/var/tmp/r107-cards/` · **Shard:** `reports/round-107/r107-cards.md` (draft; orchestrator lands)
**Labels:** **[O]** observed here · **[I]** inference · **[?]** unknown

---

## 0. Headline

**All 13 cards keep their r101 verdicts at the fresh pin.** No label changes. The card set is
structurally sound and every load-bearing numeric claim I re-ran reproduces — except one
density table in `meshes-textures.md` whose grep patterns were never printed and which is
therefore not re-derivable. Two hygiene defects are worth a correction pass (§5).

The runtime unlock remains **UNPROVEN-WITH-ATTEMPT-LOG**: the `wukakuki/unreal-engine:dev-slim-5.8.3`
pull was still running when this shard was written (§6). Nothing in this shard claims runtime
execution.

---

## 1. Pin and byte-identity — re-established first-hand [O]

Fresh clone produced by the VENDOR-A seat at `/var/tmp/r107-va/repo`; I re-verified it rather
than trusting the peer shard.

```
$ cd /var/tmp/r107-va/repo && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git ls-remote origin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main      # remote agrees on the pin
$ git log -1 --format='%ci %s'
2026-09-17 13:28:32 +1200 [MCP] Permit safe concurrent tool calls
$ git ls-files -s | wc -l
12
```

**The pin has not moved since r101** [O]. Consequence for this seat: every r101 card citation
should still resolve, and the job is to *prove* that, not to re-derive the corpus from scratch.

### 1.1 Three independent transports, all 12/12

| # | transport | command | result |
|---|---|---|---|
| A | committed manifest, recomputed | `sha256sum -c .manifest.d/audit-reference.sha256` | **12 OK, 0 FAILED, exit 0** [O] |
| B | vendored bytes vs fresh clone worktree | `diff -rq <sub>/upstream /var/tmp/r107-va/repo --exclude=.git` | **no output, exit 0** [O] |
| C | git blob object vs worktree bytes | `git cat-file -p <blob> \| sha256sum` vs `sha256sum <path>`, per `git ls-files -s` | **12/12 OK** [O] |
| D | `raw.githubusercontent` at the pin | `curl -sf .../a6aa73ad.../<path> \| sha256sum` vs `sha256sum upstream/<path>` | **12/12 OK** [O] |

Transport C is the strongest of the four: it compares the vendored file against the **git
object store's own blob**, which a regenerated manifest could not fake. Transport D is the only
one that leaves the host and the only one that does not touch the local `.git`.

Transport-C transcript (excerpt, sha256 prefixes):

```
OK       483693ad0e14d027  README.md
OK       259124f0631b7d4b  hooks/hooks.json
OK       dbed002b4a46ab10  skills/unreal-mcp/references/operations.md
... 12/12 OK
```

Total bytes `63556`, total lines `1022`, files `12` — matches the r101 card basis exactly [O].

---

## 2. Census — still 13 cards, still 12/1/0 [O]

Ran the **real, unmodified** `gate/run_gate.sh` with scratch redirected off the tmpfs
(`GATE_WORKDIR=/var/tmp/r107-cards`), because this host's `/tmp` is a quota-limited tmpfs:

```
$ GATE_WORKDIR=/var/tmp/r107-cards bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
...
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          # EXIT=0
```

The gate's own CHECK 3 output enumerates every card with its declaration line:

| card | label | decl. line |
|---|---|---|
| `actors-scene.md` | `unproven-runtime` | 5 |
| `animation-controlrig.md` | `static-only` | 4 |
| `assets-content.md` | `static-only` | 15 |
| `blueprints.md` | `static-only` | 4 |
| `editor-general.md` | `static-only` | 4 |
| `gameplay-gas.md` | `static-only` | 4 |
| `materials.md` | `static-only` | 4 |
| `meshes-textures.md` | `static-only` | 4 |
| `scripting-programmatic.md` | `static-only` | 5 |
| `sequencer.md` | `static-only` | 5 |
| `testing-automation.md` | `static-only` | 5 |
| `ui-umg-slate.md` | `static-only` | 5 |
| `vfx-niagara-dataflow.md` | `static-only` | 6 |

Card-name set vs the gate's `PINNED_CARD_NAMES`, both directions:

```
$ ls executability/ | sed 's/\.md$//' | sort | tr '\n' ' '
actors-scene animation-controlrig assets-content blueprints editor-general gameplay-gas
materials meshes-textures scripting-programmatic sequencer testing-automation ui-umg-slate
vfx-niagara-dataflow
```
Byte-identical to the pinned set [O] — `NAME_BAD=0` confirms it from the gate side.

**Process note for the orchestrator.** My first census pass used a regex covering three of the
gate's five declaration shapes and reported `static-only=9` plus 3 `NODECL`. That was a *seat*
error, not a card defect: `assets-content.md` declares via the bare `**\`static-only\`**` shape
(line 15) and `scripting-programmatic.md` / `vfx-niagara-dataflow.md` declare below the first
`##` heading. Re-running with all five shapes reproduces 12/1/0. **Trust the gate's CHECK 3
output, not an ad-hoc grep** — the cards legitimately vary in formatting.

---

## 3. Per-card re-evaluation against the fresh bytes

Every card cites the pin `a6aa73ad…` [O] — 13/13, no stale-pin card.

| card | verdict at fresh pin | basis re-derived here | delta |
|---|---|---|---|
| `actors-scene` | `unproven-runtime` **unchanged** | domain = live session state, no on-disk artifact; dispatch path fully specified | none |
| `animation-controlrig` | `static-only` unchanged | 6 lines match `control rig\|state tree\|behavior tree\|animation`; 0 tool signatures | none |
| `assets-content` | `static-only` unchanged | 8 advertised clauses; `AssetTools`/`ObjectTools` named, 0 members | none |
| `blueprints` | `static-only` unchanged | 14 blueprint mentions, 5 files; 0 real Blueprint method | none |
| `editor-general` | `static-only` unchanged | `AIAssistantToolset.GetDockedContext` is the only Editor symbol | none |
| `gameplay-gas` | `static-only` unchanged | `GAS` ×3 as a name-drop; `AbilitySystemComponent`/`GameplayAbility`/`GameplayEffect`/`AttributeSet` → **0** | none |
| `materials` | `static-only` unchanged | 8 material mentions; `MaterialInstance` → **0** | none |
| `meshes-textures` | `static-only` unchanged | `SkeletalMesh` → **0**; dotted-method filter `mesh\|texture` → **empty** | none |
| `scripting-programmatic` | `static-only` unchanged | exactly 2 `execute_tool_script`/`ProgrammaticToolset` mentions, both `README.md:90,92` | none |
| `sequencer` | `static-only` unchanged | 10 tokens in 3 files; `SequencerTools.create_level_sequence` only symbol | none |
| `testing-automation` | `static-only` unchanged | exactly 10 tool-vocabulary mentions, all in `create-toolset/SKILL.md` | none |
| `ui-umg-slate` | `static-only` unchanged | `UMG` ×1, `Slate` ×3, `WidgetBlueprint` → **0** | none |
| `vfx-niagara-dataflow` | `static-only` unchanged | `Niagara`/`Dataflow` named, 0 signatures | none |

**No label changes, no card removed, no card added.** The r101 verdict set transfers intact.

### 3.1 The load-bearing cross-card table *does* reproduce

`meshes-textures.md` §2a is the one table other cards lean on ("9 of the 13 domains name no
dotted tool method"). It prints its own command, so I ran exactly that command:

```
$ awk 'NR>=100 && NR<=112' README.md | while IFS= read -r l; do
    d=$(echo "$l" | sed 's/^.* - //'); n=$(echo "$d" | awk -F'[;,]' '{print NF}'); ...
$ (same, printing the domain)
Actors and Scene       5      Sequencer              5
Blueprints             6      VFX                    1
Assets and Content     8      UI                     2
Materials              2      Gameplay               4
Meshes and Textures    6      Testing                3
Animation              2      Editor                 5
                              Scripting              1
```

All 13 rows match the card's table [O]. The "**9 of the 13** name no dotted method" claim also
holds: the corpus-wide dotted-method inventory is exactly **8 unique tokens**, of which one is
the `MyToolset.find_things` template placeholder — so 9 domains name no method [O]:

```
$ grep -rhoE "[A-Za-z]+(Tools|Toolset)\.[A-Za-z_]+" . --exclude-dir=.git | sort -u
AgentSkillToolset.GetSkills        LiveCodingToolset.CompileLiveCoding
AgentSkillToolset.ListSkills       MyToolset.find_things        # template placeholder
AIAssistantToolset.GetDockedContext  ProgrammaticToolset.execute_tool_script
BlueprintTools.create              SequencerTools.create_level_sequence
```

The `mesh|texture` filter over that list returns empty (grep exit 1) [O] — the card's
"zero callable member names" claim is confirmed.

---

## 4. Findings — deltas the orchestrator should land

### F1 · `meshes-textures.md` §2b density table is not re-derivable [O]

The table (also restated in the card's own headline bullets at line 19) claims per-domain
mention counts:

| domain | card claims |
|---|---|
| Sequencer | 1 |
| Materials | 2 |
| **Meshes and Textures** | **2** |
| Actors / UI / Gameplay / Scripting | 3 |
| Testing | 5 |
| Assets / Animation / VFX / Editor | 6 |
| Blueprints | 7 |

The command block prints only a helper whose argument is never bound:

```
$ run(){ grep -rniE "$2" . | wc -l; }   # per domain, its own bullet nouns
```

`"$2"` is called with no positional args, so **the patterns behind the table are absent from the
card and cannot be recovered from it**. I tried every plausible "own bullet nouns" alternation.
Direct counts over the fresh clone:

| domain | direct count (`grep -rniE`, lines) |
|---|---|
| Sequencer | 6 (`sequencer`) / 7 (full noun set) |
| Materials | 8 (`material`) |
| Meshes and Textures | 4–5 |
| Blueprints | 14 (`blueprint`) / 15 (noun set) |

Only 5 of the 13 rows match any alternation I tried; the rest do not [O]. The card's conclusion
("ties with Materials for second-thinnest, beaten by Sequencer") rests on numbers I cannot
reproduce, **and the ranking itself inverts** under direct counting (Materials 8 > Sequencer 6 >
Meshes 4).

**[I] Recommended correction (draft text, not landed):** either print the exact per-domain
pattern in the command block, or replace §2b and the line-19 bullet with a count that carries
its own command. The load-bearing claim in §1 is unaffected — it is the §2a conjunction
(*6 advertised capabilities + named toolset + 0 callable members*), which reproduces exactly.

### F2 · 50 citations point at a `/tmp` path that no longer exists [O]

Every card cites `/tmp/ue-skills-ref` as its reference clone:

```
$ grep -rc '/tmp/ue-skills-ref' executability/*.md | awk -F: '{s+=$2} END{print s}'
50
$ [ -d /tmp/ue-skills-ref ] && echo EXISTS || echo ABSENT
ABSENT
```

Per-card counts: `ui-umg-slate` 10, `assets-content` 8, `sequencer` 8, `gameplay-gas` 5,
`editor-general`/`scripting-programmatic` 4, `actors-scene`/`animation-controlrig` 3, the rest 2.

This is a **known and already-documented** class — `adaptation-kimi.md` §C3 ("the `/tmp`
working trees are volatile; the vendored `upstream/` copy is the durable substitute") names it
for its own sections [O]. But §C3 does **not** cover the 13 cards. The receipts are still
*true* (I re-ran each against the fresh clone in §3 and they reproduce), so this is a
**citation-durability** defect, not a correctness defect.

**[I] Recommended correction:** in each card's receipts table, cite
`corpus/knowledge/unreal-mcp/upstream/` (or the fresh clone) in place of `/tmp/ue-skills-ref`,
or add a one-line pointer to §C3. The substitute is byte-identical (§1.1), so no number moves.

### F3 · Structural unevenness across the 13 cards [O]

| card | unlock-condition section | host-receipt section |
|---|---|---|
| `testing-automation` | 1 | **0** |
| `vfx-niagara-dataflow` | 1 | **0** |
| `ui-umg-slate` | **2** | 1 |
| (the other 10) | 1 | 1–3 |

Two cards carry no host-receipt section at all; one carries two unlock sections. Not a
correctness problem — the gate's CHECK 3 anchors on the *first* declaration and both
`ui-umg-slate` unlock sections agree — but a normalisation candidate if a future round wants a
uniform card template. Recorded, not fixed.

---

## 5. What this shard does and does not assert

**Asserts [O]:**
- the pin is `a6aa73ada02a9fb1f5415bec491f9942c519b297` and the remote agrees;
- the vendored `upstream/` tree is 12/12 byte-identical to that pin via four independent
  transports (committed manifest, worktree diff, git blob objects, raw.githubusercontent);
- the 13-card set and the 12/1/0 label census hold, per the gate's own CHECK 3;
- each card's load-bearing static claim reproduces against the fresh bytes (§3);
- the §2a capability-clause table reproduces exactly with the card's own printed command.

**Does not assert:**
- **any Unreal runtime behavior.** No editor exists on this host; `verified-here` remains
  `0` and no card moved to it. The strongest statement available is "the vendored bytes equal
  the pinned upstream commit and these static checks ran here" [O].
- that the r101 card prose is *ideal* — §4 records three improvement candidates, none of which
  changes a verdict.
- anything about the sibling 2D lane or `corpus/fixtures/run_battery.py` (untouched; never run).

---

## 6. UE runtime — UNPROVEN-WITH-ATTEMPT-LOG

Docker unlock attempt, recorded rather than claimed:

```
$ docker pull wukakuki/unreal-engine:dev-slim-5.8.3   # pid 596299, log /var/tmp/ue-pull.log
$ ps -p 596299 -o etime=
      03:06                     # still running when this shard was written
$ docker images | grep -c unreal
0                               # image not yet present
```

Layer log shows steady `Download complete` / `Pull complete` progress with no error line, so
the pull is *progressing*, not wedged. **No image, therefore no container, therefore no smoke
probe, therefore no runtime verdict.** If the pull completes, the honest next step is a bounded
container smoke probe; if it fails, the log is the attempt record. Until then every runtime
claim in this subtree stays **UNPROVEN** — and the card labels correctly reflect that.

**Note [I]:** even a completed pull would not by itself move a card to `verified-here`. The
label requires *a bounded run of the subsystem on this host with a saved receipt*; a pulled
image is an unlock precondition, not a receipt.

---

## 7. Handoff

1. **Land nothing automatically** — this shard is a draft; `corpus/knowledge/unreal-mcp/` is
   untouched by this seat (verified: no writes outside `reports/round-107/`).
2. **F1 is the one finding that changes prose**: §2b + line 19 of `meshes-textures.md`.
3. **F2 is mechanical**: 50 citation swaps across 13 files, byte-identical substitute.
4. **F3 is optional** normalisation.
5. **Re-run the gate after any landing**: `GATE_WORKDIR=/var/tmp/<roomy> bash
   corpus/knowledge/unreal-mcp/gate/run_gate.sh` — expect `CARDS=13`, `CENSUS 12/1/0`,
   `NAME_SET=OK`, `UNRESOLVED=0`, exit 0. Any prose edit under the subtree moves `POINTERS`
   (it is scanner-relative and self-referential); `UNRESOLVED=0` is the binding invariant.
6. **Keep the pull alive** and record its terminal state in the round close-out.
