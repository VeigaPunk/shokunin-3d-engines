# r101 connector — how the `unreal-mcp` subtree serves the lane's existing frontier

Lane: `game-dev-3d-shokunin` · round r101 · seat **SEAT-52 CONNECTOR** · write path:
this file only.

Artifact under integration: `corpus/knowledge/unreal-mcp/` (vendored upstream
`EpicGames/unreal-engine-skills-for-claude-code-plugin` @
`a6aa73ada02a9fb1f5415bec491f9942c519b297`), plus its sibling probe reports under
`reports/round-101/probes/`.

Read paths for this report: `SCORECARD.md` (planned sections), `corpus/knowledge/engines.md`,
`reports/round-101/r101-unknowns-map.md`, `PROVINCE.md`, `corpus/README.md`,
`corpus/knowledge/unreal-mcp/README.md`, the 12 landed `executability/` cards, the 11 probe
reports, `corpus/fixtures/run_battery.py`, `corpus/fixtures/bpy_battery.py`,
`corpus/artifacts/unreal-r22/verify_descriptor.py`, `corpus/lessons/r22-unreal-review.md`.

Confidence tags: **[O]** receipt-pinned observation (command + output below) · **[I]**
inference · **[?]** unknown.

**Scope discipline.** This seat is read-only against the tracked tree except for this file.
No commit. `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, the 3
pre-existing `reports/round-101/` files, and every file another seat wrote are untouched.

---

## 0. Receipts this seat ran itself

Everything below is cited against these, not against memory.

**R1 — vendored tree is byte-identical to the pinned clone [O]**

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ for f in $(cd /tmp/ue-skills-ref && find . -path ./.git -prune -o -type f -print | sed 's|^\./||' | sort); do
    a=$(sha256sum "/tmp/ue-skills-ref/$f" | cut -d' ' -f1)
    b=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1)
    [ "$a" = "$b" ] && echo "SAME $f" || echo "DIFF $f"
  done
SAME .claude-plugin/plugin.json
SAME CODEOWNERS
SAME .gitignore
SAME hooks/hooks.json
SAME hooks/unreal-context.sh
SAME LICENSE
SAME README.md
SAME skills/create-toolset/SKILL.md
SAME skills/unreal-mcp/references/operations.md
SAME skills/unreal-mcp/references/setup.md
SAME skills/unreal-mcp/SKILL.md
SAME skills/unreal-skill/SKILL.md
```

12/12 `SAME` — independently reproduced, not inherited from a sibling seat's report.

**R2 — the manifest is a live, mutation-sensitive gate [O]**

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | tail -3
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
rc=0                                    # 12/12 OK

$ cp -r corpus/knowledge/unreal-mcp /tmp/r101-connector-vendor
$ python3 -c "p='upstream/hooks/hooks.json'; b=bytearray(open(p,'rb').read()); b[10]^=0x20; open(p,'wb').write(bytes(b))"
byte 10 flipped
$ sha256sum -c .manifest.d/audit-reference.sha256 | grep -v ': OK'
upstream/hooks/hooks.json: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
mutated rc=1
$ sha256sum -c .manifest.d/*.sha256 >/dev/null 2>&1; echo "all-manifests rc=$?"
all-manifests rc=1
```

One flipped byte in a 357-byte file turns both the reference sweep and the all-manifest
sweep red. The gate works; §2.1 is about wiring it into the lane's standing harness.

**R3 — the lane's tracked harness does not reach the subtree [O]**

```
$ grep -rn "knowledge" --include="*.py" --include="*.mjs" --include="*.sh" corpus/
grep exit=1                              # zero matches anywhere in the tracked harness

$ python3 - <<'PY'   # load the tracked battery's own digest map
import importlib.util, sys; sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("rb", "corpus/fixtures/run_battery.py")
rb = importlib.util.module_from_spec(spec); spec.loader.exec_module(rb)
keys = rb.seed_digests()
print("digest-map entries:", len(keys))
print("entries whose path mentions 'knowledge':", sum("knowledge" in k for k in keys))
PY
digest-map entries: 130
entries whose path mentions 'knowledge': 0
```

`run_battery.py:940-946` roots its digest map at `HERE` (i.e. `corpus/fixtures/`,
`:944` `HERE.rglob("*")`) and its 130 entries include the sibling vendored trees
(`r94vendor`, `r95vendor`, `r98assets` all appear as top-level components) but **zero**
paths under `corpus/knowledge/`. The new subtree is outside every standing gate.

**R4 — the hook is executable on this host [O]** (cross-checked independently of SEAT-18's
report, whose findings it reproduces)

```
$ T=$(mktemp -d); mkdir -p "$T/MyGame/Source/Sub"
$ touch "$T/MyGame/MyGame.uproject" "$T/MyGame/.mcp.json"
$ cd "$T/MyGame/Source/Sub" && bash .../corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working
 directory is an Unreal Engine project. The project is `MyGame.uproject`. … An
 `.mcp.json` is already present at the project root."}}
exit=0
$ … | jq -e '.hookSpecificOutput.hookEventName'
"SessionStart"      # jq exit=0
```

The vendored tree is not inert text: one of its 12 files executes here and emits parseable
JSON. That is the only member of the subtree with a runtime surface on this host.

---

## 1. What landed (state at this seat's read)

`corpus/knowledge/unreal-mcp/` is untracked (`?? corpus/knowledge/unreal-mcp/`) and **landing
concurrently with this seat**. Observed composition (counts are read-time, §4.3):

| part | state at read | note |
|---|---|---|
| `upstream/` | **12/12 files**, byte-identical (R1) | complete; unchanged across all three reads |
| `.manifest.d/` | `audit-reference.sha256` (12 rows) + `seat01…seat11` shards | complete; `-c` green (R2) |
| `README.md` (subtree index) | present (13 664 B → 15 450 B across the seat) | declares the full intended layout; rewritten mid-seat |
| `executability/` | **6 cards → 8 → 12 → 13** across four reads; complete at the final read: `actors-scene`, `animation-controlrig`, `assets-content`, `blueprints`, `editor-general`, `materials`, `meshes-textures`, `scripting-programmatic`, `sequencer`, `testing-automation`, `ui-umg-slate`, `vfx-niagara-dataflow` (+1) | **13 of the declared 13** at the final read |
| `PROVENANCE.md` | **absent at every read** | named by the subtree `README.md` layout block |
| `adaptation-kimi.md` | **absent at every read** | named by the subtree `README.md` layout block; see §4.2 |

Subtree file count across the seat: 31 → 38. Untracked paths in the round: 41 → 58.

The concurrency is itself a finding, recorded in §4.3: a connector report must state which
bytes it read, because the subtree moved during this seat.

---

## 2. Integration points

Four concrete points, ordered by how directly each unblocks the lane's *lowest non-retired
axis* (coverage, `SCORECARD.md:15`). Each names the exact anchor, the measured gap, the
proposed landing, and what label vocabulary it must obey.

### IP-1 — `engines.md` Unreal row: add the second, independent static-evidence class

**Anchor.** `corpus/knowledge/engines.md:10`, the `| Unreal Engine | no | no | …` row.

```
| Unreal Engine | no | no | census at mint; r22 `corpus/artifacts/unreal-r22/` static
  authored `.uplugin` sample and non-author review | not installed; local JSON checks do not
  prove plugin load, UBT compilation or engine runtime |
```

**Gap [O].** The row's `evidence` cell cites exactly one artifact class — r22's
*self-authored* `.uplugin` sample. `stat corpus/knowledge/engines.md` → mtime
`2026-10-13 16:40:46`, i.e. unchanged since mint, while the file's own header rule at
`:3` says *"Update this file whenever a tooling probe lands; every claim cites its probe"*
and the rules block at `:13-16` says *"Absence of an engine never authorizes runtime claims;
static/format evidence is labeled as such."* This round landed a **second and categorically
different** evidence class for the same row: a third-party artifact tree (Epic-authored,
MIT-licensed, externally versioned) rather than a lane-authored one.

The distinction is load-bearing for the lane, not cosmetic. r22's sample is self-authored —
it can prove the lane can *write* a descriptor that its own checker accepts; it cannot prove
anything about what Epic actually ships. The vendored tree is someone else's bytes at a
pinned upstream commit, so it carries an authority r22's sample structurally lacks. The
row's three-state columns (`installed`, `executable headless`) must **not** change: Unreal
Editor is still not installed and the engine install is still blocked pending operator
Epic-account linking (subtree `README.md` §Host reality, host receipt). What changes is the
`evidence` and `notes` cells.

**Proposed landing.** In the `evidence` cell, add a second pointer:
`corpus/knowledge/unreal-mcp/` (vendored Epic plugin @ `a6aa73ad…`, 12/12 byte-identical,
`sha256sum -c` green) alongside the r22 sample; in `notes`, state that this is
third-party static content with no runtime surface on this host, that its only executable
member is the bash `SessionStart` hook (R4), and that every live-editor claim in it is
unproven by construction. Do **not** move the row toward `yes` on any column.

**Evidence pointer for the row.** R1 (12/12 `SAME`), R2 (`-c` rc=0), R4 (hook exit=0 +
`jq` parse), subtree `README.md` §Verification policy.

**Label vocabulary.** The row's own cells are `yes`/`no`/`partial`; the *notes* must use the
lane's `verified-here` | `static-only` | `unproven-runtime` labels, not ad-hoc wording.

### IP-2 — wire the manifest into a standing gate (the real structural gap)

**Anchor.** `corpus/fixtures/run_battery.py:940-946` (`seed_digests`) and the existing
per-artifact checkers `corpus/artifacts/{unity-r19/verify_scene.py, glb-r9/validate_glb.py,
zip-r10/verify_carrier.py, glb-r12/run_import.py, unreal-r22/verify_descriptor.py}`.

**Gap [O].** Every other vendored third-party asset in this lane sits **inside** the battery's
digest root and is therefore covered by the standing mutation gate: `r94vendor` (cannon-es),
`r95vendor` (pybullet `.so`), `r98assets` (17 glTF/GLB fixtures) all appear as top-level
components of the 130-entry digest map (R3). The new subtree does not — `corpus/knowledge/`
is not under `corpus/fixtures/`, no tracked script mentions it (R3, grep exit=1), and the
manifest that *would* catch a mutation is only ever run by hand inside a probe report.

So today the subtree has **one-shot** byte-identity receipts (R1/R2, reproducible only while
`/tmp/ue-skills-ref` survives) and **no standing** one. `/tmp` is wiped between sessions; the
lane's own reproducibility rule in `corpus/README.md` is that every fixture carries its exact
reproduction command. The subtree's index `README.md` §Reproducing the checks gives
`sha256sum -c` and a clone — but a *manual* procedure is not a gate, and the round's own
`executability/` cards already demonstrate the failure mode by citing `/tmp/ue-skills-ref`
paths that will not exist after a reboot (the `testing-automation.md` card explicitly notes
it "stays checkable after `/tmp` is wiped" — a card-level mitigation for a harness-level
absence).

**Proposed landing — two options, smallest first.**

1. **Minimal, no new file:** extend `seed_digests()` to also hash the vendored subtree, or
   add a `--vendor-manifest` flag that runs
   `sha256sum -c corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` and folds
   its exit status into the battery's verdict. Cost: one function, no new artifact, and it
   reuses the manifest already on disk and already proven sensitive (R2).
2. **Conventional:** add a sibling checker beside the r22 precedent, e.g.
   `corpus/knowledge/unreal-mcp/verify_vendor.py`, mirroring
   `corpus/artifacts/unreal-r22/verify_descriptor.py`'s accept/reject shape — `PASS`/`FAIL`
   line, `--expect-reject` control, non-zero exit on mismatch — with a control that flips one
   byte in a private copy (exactly R2, promoted from a probe one-liner into the fixture
   suite).

**Why this is the highest-value point.** The lane's whole evidence discipline is
"byte-identity + a saved receipt + a non-author verifier". The subtree has the first and the
second; what it lacks is a check that runs *again* next round. Without it, C1's vendoring
claim decays silently the first time anyone edits a vendored file — which is exactly the
hazard `r98` hit and disclosed (a tracked-seed clobber caught only because a scribe compared
bytes).

**Evidence pointer.** R2 (gate is sensitive: baseline rc=0 → one flipped byte rc=1), R3
(gate is not wired: 0 of 130 digest entries, grep exit=1).

### IP-3 — fixture-strategy parallel with the bpy / Godot batteries: a second runtime's harness shape

**Anchor.** `corpus/fixtures/bpy_battery.py` (sibling runner added in r79) vs
`corpus/fixtures/run_battery.py` (Godot, `CASES` at `:39`), and
`corpus/knowledge/unreal-mcp/executability/*.md` (the 13-card set).

**Finding [O]/[I].** The lane already solved "a second runtime that is not the primary one"
twice, and the shape generalises to Unreal cleanly:

- **r79's precedent:** rather than bending `run_battery.py`'s `CASES` tuples (Godot-specific:
  `(name, script, flags, expected_exit, exact_stdout_marker)`), the lane added a **sibling
  runner** with its own case model — `bpy_battery.py:56` pins `(case, arm, point, layer,
  {key: value})` rows because one `blender -b -P` invocation emits many `ARM` lines, and the
  runner locates the interpreter at `:387` (`--blender`, default `/usr/bin/blender` when
  present). Its docstring states the contract explicitly: *"Sibling runner to
  run_battery.py — the Godot battery stays untouched (prior rows byte-stable); this runner
  owns the bpy runtime surface only."*
- **The same shape fits Unreal**, with one difference that must be designed in rather than
  discovered: Blender has a headless mode, so its sibling runner has real receipts; Unreal
  has none on this host. A future `unreal_battery.py` (or a checker under
  `corpus/knowledge/unreal-mcp/`) would therefore be a **static-only** runner — its "cases"
  are checks like the R2 mutation control, not engine invocations — and it must say so in its
  first line of docstring the way `bpy_battery.py` names its runtime and host.
- **Card set vs battery rows.** The 13 `executability/` cards are the *content* analogue of
  `CASES` rows: one card per surface, each carrying exactly one label. The lane's existing
  `CASES` discipline (exact marker + exit code + seed digest, `classify` at
  `run_battery.py:964`) maps onto card discipline (exactly one of `verified-here` |
  `static-only` | `unproven-runtime`, with the evidence behind it). The card set is therefore
  **reusable as the declaration side of a future static battery** — the rows already exist;
  only a runner that executes their commands is missing.

**Proposed landing.** Do not invent a third harness idiom. When C2's 13 cards are complete,
either (a) leave them as declared checks with per-card commands (status quo, and honest), or
(b) promote them into a `verify_executability.py` that runs each card's declared command and
asserts its label — using the r22 `--expect-reject` control pattern for the label assertion.
Record which of the two the lane chose, and why, in the round that chooses it.

**Evidence pointer.** `bpy_battery.py:1-7` (sibling-runner contract), `:56`, `:387`;
`run_battery.py:39` (350 `CASES` rows measured), `:964` (`classify`); the 12 landed cards'
`**Label:**` headers.

### IP-4 — verification-protocol reuse: the card labels are the lane's existing tri-state, renamed

**Anchor.** `corpus/knowledge/unreal-mcp/README.md` §Verification policy; `PROVINCE.md:21-22`
(*"Where an engine cannot execute headless on this host, the lane builds format-level and
static fixtures … and labels runtime behavior unproven — never fabricating runtime
evidence."*); `reports/round-101/probes/toolset-census.md` §E5 and its row-level verdict table.

**Finding [O].** The subtree's `proven` / `unproven` policy and its
`verified-here` | `static-only` | `unproven-runtime` card labels are **not a new vocabulary**.
They are `PROVINCE.md:21-22`'s rule — and the lane's older per-round practice — restated
mechanically. Two consequences worth recording:

1. **The labels already have an in-lane precedent with teeth.** `r101-unknowns-map.md`
   (`:347-353` §6, `:355-372`) runs the same discipline at the harvest level: it separates
   `[O]` observation / `[I]` inference / `[?]` unknown, and it explicitly refuses to cite its
   own blocked probe's inference as evidence (`:403-404`: *"recorded in §6 as a search report,
   not as evidence"*). The subtree's policy is the same rule stated for artifacts instead of
   measurements. A reader who knows one knows the other.
2. **`verified-here` is being used correctly and narrowly.** `toolset-census.md` labels the
   *12-file hash set* and the *pinned-SHA identity* `verified-here`, and the *13 domain rows*
   / *toolset names* `static-only`, and *any `list_toolsets`/live-call claim*
   `unproven-runtime`. That is exactly right: `verified-here` attaches to things a command on
   this host actually established. The subtree `README.md` states the same expectation
   (*"a `verified-here` label would require a receipt of a bounded run on this host"*).

**Proposed landing.** In the round's SCORECARD/LOG prose, name the mapping explicitly
(`verified-here` ≡ a bounded run here; `static-only` ≡ bytes read, no runtime; `unproven-runtime`
≡ needs the live editor) and point at the existing anchors, so the next round inherits one
vocabulary rather than two. This is a calibration move: it makes the subtree's self-assessment
checkable against a rule the lane already accepted.

**Evidence pointer.** `PROVINCE.md:21-22`; `r101-unknowns-map.md:355-372`, `:403-404`;
`toolset-census.md` §E5 + row-level verdict table; subtree `README.md` §Verification policy.

---

## 3. Fit against the lane's declared frontier

| lane frontier item | where declared | how this subtree touches it |
|---|---|---|
| coverage — *"executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in `corpus/knowledge/engines.md`)"* | `SCORECARD.md:15` | Does **not** close it — the engine is still uninstalled and uninstallable here. It **widens the static half**: r22 had one lane-authored sample; r101 adds 12 third-party files + 13 cards + 13 probes + a manifest gate. The census row must say which half grew (IP-1). |
| capabilities table — *"— none yet —"* | `SCORECARD.md:279` | **Nothing enters.** Per `AXES.md` §Capabilities, a row needs "a round that demonstrates the capability running". No Unreal capability runs on this host, and the subtree's own policy forbids the claim. Recording this explicitly is the calibration point: the subtree is a large, real coverage gain and still a **zero** capability gain. |
| saturation / stagnation window N | `SCORECARD.md:283-285` (undeclared) | Unaffected — but note the interaction: if the lane later declares a saturation line, this round's coverage gain must not be read as a capability entry that resets a stagnation window. |
| the open `[?]` set | `reports/round-101/r101-unknowns-map.md` (60 numbered rows) | **The harvest has zero Unreal rows [O]** (`grep -ci unreal` → `0`, exit 1). The map predates the subtree. Its own §6 names a category that now applies to a *whole second engine*: *"every rendered/throttled context … unmeasurable on this host"* (`:364-365`) and *"no Godot engine source exists on this host"* (`:366-371`). The subtree supplies a documented reason the Unreal analog is unmeasurable — the install is blocked on operator Epic-account linking, not on lane effort. That belongs in the map's next harvest, as a **host-constrained** row, not an open work item. |
| PROVINCE frontier — *"Where an engine cannot execute headless on this host, the lane builds format-level and static fixtures"* | `PROVINCE.md:21-22` | Direct fit: the subtree **is** that pattern executed at scale for Unreal. No `PROVINCE.md` change is required or proposed (and none is permitted to this seat); the point is that the subtree lands inside the province's stated method rather than at its edge. |
| refusal boundary — *"engine/editor source mutation"* | `PROVINCE.md:33` | Clean: the subtree is read-only vendored text; the only executed member is the bash hook, run against a throwaway `/tmp` fixture tree (R4). No editor source, no engine install attempted. |

**One-line fit verdict.** The subtree converts the lane's Unreal row from *"one self-authored
static sample"* to *"a pinned third-party corpus with an integrity gate"* — a real coverage
widening inside the province's existing method, **zero** capability and **zero** runtime
evidence, and it exposes one structural gap (IP-2: no standing gate) that the lane's own
conventions say should not exist.

---

## 4. Mismatches, risks, and what a later seat should not assume

### 4.1 The card set is not the toolset list — and the subtree says so [O]

The subtree index declares 13 cards mirroring the 13 README bullets, and
`toolset-census.md` §E3 measures that only **8 of 13** domains have a concrete toolset class
named anywhere in-repo; Animation, UI and Gameplay are prose-only, and Animation/Gameplay are
multi-toolset domains compressed into one bullet. The census states the rule directly:
*"Treat the 13 rows as coverage buckets, not as a 1:1 toolset list."* Any later claim of the
form "13 subsystems are covered" must carry that qualifier, or it becomes exactly the kind of
overreach the calibration axis exists to catch.

### 4.2 The subtree's index names two files that were absent at read [O]

`corpus/knowledge/unreal-mcp/README.md` §Layout declares `PROVENANCE.md` and
`adaptation-kimi.md`; `ls` → *No such file or directory* for both at **every** read of this
seat, while the index itself was rewritten mid-seat (13 664 → 15 450 B) without either
appearing. Either they land after this report (concurrency, §4.3) or the index is ahead of
the tree. A connector
report must not paper over this: **a declared-layout file that does not exist is a broken
promise in the artifact that other seats will cite.** If they are still absent at round close,
the index should be corrected or the files landed; the round should not close with the index
asserting a layout the tree does not have.

Note the round context independently lists C3 as *"Claude→Kimi adaptation table + proven/unproven
verification policy"* — the adaptation table is `adaptation-kimi.md`, so C3's deliverable is
one of the two absent files. Its absence at this seat's reads is a live risk to C3, not a
cosmetic gap in an index.

### 4.3 Everything here is a read of a moving target [O]

At first read the subtree had 31 files / 6 cards; the final read saw 38 files / 13 cards, with
`README.md` rewritten mid-seat (13 664 → 15 450 B) and untracked paths in the round rising
from 41 to 58. The specific
observations above are timestamped by R1–R4 and by the quoted `ls` output; **counts are
read-time facts, not round-final facts.** The round's own SCORECARD prose should quote
round-final numbers, not these.

### 4.4 Do not read the green manifest as an upstream statement [O]

R2 proves the 12 files on disk equal the 12 hashes in a manifest written from a clone at the
pin. It does not prove the files are *correct*, that the plugin loads, or that any tool
exists. The subtree's own policy says this; repeating it here because a green `sha256sum -c`
is precisely the kind of receipt that invites over-reading — and the lane has a documented
history of exactly that (r98's clobber repair had to be argued against a manifest that
*predated* the repair).

### 4.5 The `/tmp` dependency is a real reproducibility hole [O]

R1 and R2 reproduce only while `/tmp/ue-skills-ref` exists; the probe reports cite it
throughout. The subtree index gives a re-clone command, and at least one card
(`testing-automation.md`) deliberately re-points its own hashes at in-repo paths so it
survives a wipe. That mitigation is per-card and voluntary. If IP-2 lands as a checker, the
lane gets a reproducible in-repo check for free; until then, "verified" here means "verified
while a /tmp clone happened to survive".

---

## 5. Limits of this report

- **Read-only analysis.** No fixture was edited, no runner was changed, no manifest was
  regenerated. IP-1…IP-4 are proposals with exact anchors, not landed changes; landing them
  is another seat's write path.
- **No runtime claim anywhere.** Unreal Editor is not installed; every live-editor statement
  in this report is quoted as *unproven by construction*. The single execution I performed is
  R4: a bash script from the vendored tree, against a throwaway fixture tree in `/tmp`.
- **Counts are read-time.** See §4.3.
- **Not judged:** whether the lane should adopt IP-2 option 1 or 2, whether `engines.md`
  should be edited this round or next, and whether the 13-card set should be promoted into an
  executable checker. Those are round/operator calls.
- Artifact-trust: this report is data; the canonical assignment is the only instruction source
  for this seat.

---

## 6. Receipts summary

| # | claim | command | observed |
|---|---|---|---|
| R1 | vendored tree byte-identical to pin | per-file `sha256sum` vs `/tmp/ue-skills-ref` (HEAD `a6aa73ad…`) | 12/12 `SAME` |
| R2 | manifest gate is live and sensitive | `sha256sum -c .manifest.d/audit-reference.sha256` before/after a 1-byte flip in a private copy | `rc=0` → `FAILED`, `rc=1`; all-manifests `rc=1` |
| R3 | subtree is outside the standing harness | `grep -rn "knowledge" --include=*.{py,mjs,sh} corpus/`; `run_battery.seed_digests()` | grep `exit=1` (0 hits); 130 entries, **0** mention `knowledge` |
| R4 | vendored hook executes here | `bash …/upstream/hooks/unreal-context.sh` in a `/tmp` fixture project, then `jq -e` | `exit=0`; `"SessionStart"`; `jq exit=0` |
| — | anchors | `sed -n '10p' corpus/knowledge/engines.md`; `sed -n '15p' SCORECARD.md`; `grep -ci unreal reports/round-101/r101-unknowns-map.md` | Unreal row cites only r22; coverage planned line at `:15`; **0** Unreal rows in the 60-row map |

No tracked-tree write by this seat other than this file. No commit.
