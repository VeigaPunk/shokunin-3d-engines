# r107-cards-crit — CARDS-CRITIC seat (round 107, 3D side-round)

KEY=CARDS-CRITIC. Adversarial seat: attack the refreshed executability cards. Shard
`reports/round-107/r107-cards-crit.md`. Scratch `/var/tmp/r107-cards-critic/`. Adversary mode:
assume every card claim is wrong until a command says otherwise.

## Plan header (5 lines)

1. Establish ground truth **independently of the tree's own manifest** — the manifest is the
   artifact under audit and cannot be its own witness.
2. Verify the 12 tracked upstream files byte-identical via 3 transports with independent failure
   modes: fresh clone, `raw.githubusercontent.com`, GitHub contents API.
3. Cross-check 3 named cards line-by-line against the fresh bytes: every `path:LINE` citation,
   quoted symbol, and quantitative claim.
4. Attack the two failure classes a byte-check cannot see: **path/version drift** (a claim true
   when written, false now) and **host-conditional claims** (falsifiable only against live state
   that moves).
5. Land findings as [O]/[I]/[?] rows with exact command + observed output; draft only, orchestrator
   lands. No writes into `corpus/knowledge/unreal-mcp/`.

Labels: **[O]** observed here · **[I]** inference · **[?]** unknown.

---

## 1. Verdict summary

**One real defect (D2), plus one *confirmed-but-already-documented* finding (D1) — not one byte-level
card claim is falsified.** The vendored bytes are exactly what the cards say they are; what is wrong
is what the cards say about *the world outside the pin*. The close-out gate is **GREEN** while D2 is
live (§8b).

| # | severity | defect | status |
|---|---|---|---|
| D2 | medium | Two cards assert no containerised UE exists; a public 26.79 GB Unreal Linux image exists at the exact tag this round is pulling | **new** — `sequencer.md:297`, `testing-automation.md:278` |
| D1 | none (redundant) | Adaptation table cites a `config.toml` line range that now holds a model block | **already documented in-file** (§C1) and **already fixed** by seat KIMI-ADAPT — see §5 |
| D3 | note | Gate passes green on byte scope and is structurally blind to both | `gate/run_gate.sh` CHECK 4 (§8b) |

**Honesty note on my own findings.** I first graded D1 as a new medium defect; it is not — the file's
own correction note already records the drift, and a sibling seat already re-pinned it this round. I
keep it in the shard as a *confirmation*, explicitly marked redundant, rather than deleting it, so a
reviewer can see I checked it and found it handled. D2 is the one finding that is mine: no other seat
reported the two card sentences as falsified (the scribe folded D2 after this shard's §6 was written;
CARDS-LEAD noted the pull but did not flag the sentences).

Neither finding touches the 12/12 byte-identity claim, the quantitative claims, or the historical-blob
facts — all of which reproduce exactly (§3, §4).

---

## 2. Byte-identity via 3 independent transports — 12/12 [O]

Run 2026-10-19. `V=corpus/knowledge/unreal-mcp/upstream`, `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297`.

**A — fresh clone:**

```
$ git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin clone
$ git -C clone rev-parse HEAD → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C clone ls-files -s | wc -l → 12   # all mode 100644; no symlinks/submodules
$ diff -rq clone $V --exclude=.git ; echo $? → 0
$ diff <(git -C clone ls-tree -r HEAD | awk '{print $3,$4}' | sort) \
       <(cd $V && find . -type f | sed 's|^\./||' | sort | while read p; do \
           printf '%s %s\n' "$(git hash-object "$p")" "$p"; done | sort)
(no output)   → 12/12 blob-SHA-1 IDENTICAL
```

**B — `raw.githubusercontent.com`** (no git, no clone): all 12 → HTTP 200; `diff` of the 12 sha256
sums vs vendored → no output, **12/12 IDENTICAL**.

**C — GitHub contents API** (`?ref=$PIN`, base64-decoded): all 12 → 200; every `d['size']` matches the
vendored byte count; decoded sha256s **12/12 IDENTICAL**; API-reported `d['sha']` blob SHA-1s **12/12
IDENTICAL** to the clone's.

**[O]** Three transports with independent failure modes — git protocol, CDN, REST API — agree with the
vendored bytes, and the API's own blob SHA-1s match the clone's, so byte-identity is corroborated by a
source *outside* this repository. For the record (not as evidence): the committed manifest verifies
12×OK, exit 0.

### Pin freshness — NOT stale [O]

```
$ git -C clone log --oneline a6aa73ad..origin/main   → (empty)
$ git -C clone rev-list --count HEAD                 → 53
$ git ls-remote <url> main  → a6aa73ada02a9fb1f5415bec491f9942c519b297  refs/heads/main
```

**[O]** `a6aa73ad` is still the tip of `main` (53 commits, one branch). The round-107 "fresh pin"
resolves to the same commit as r101 — **no upstream version drift** to attack, so any card defect must
be host-side, not pin-side.

---

## 3. Three named cards, line-by-line against the fresh bytes

Mechanical citation sweep (`/var/tmp/r107-cards-critic/three_cards.py`): every `path:LINE` resolved
against `upstream/` and range-checked.

| card | in-range citations | real problems |
|---|---|---|
| `ui-umg-slate.md` | 28 | 0 |
| `materials.md` | 58 | 0 (5 flags were historical-blob cites) |
| `testing-automation.md` | 17 | 0 (2 flags were historical / `setup.md:31`) |

**Every flagged citation was a checker artifact, verified individually:** `materials.md:141,142,181`
cite `toolsets.md:33/35` **@ `823f598^`** and `:150` cites `SKILL.md:68-73` **@ `be8c183`** — both
files deleted upstream, cited from history by design (resolved in §4). `testing-automation.md:161`
cites `create-toolset/SKILL.md:388` — verified: line 388 is `Run tests via MCP:` ✓ (420-line file);
`:172` cites `setup.md:31` — verified: "`AllToolsets` is an editor-only aggregator with
`EnabledByDefault` off…" ✓

### Quantitative claims reproduce exactly [O]

```
# ui-umg-slate §2/§3
$ grep -ric -E 'umg|slate|widget|WBP_' plugin.json README.md unreal-context.sh SKILL.md
plugin.json:1  README.md:3  unreal-context.sh:1  SKILL.md:2   # card table 1/3/1/2  ✓
$ grep -rn -i -E 'umg|slate|widget|WBP_' <all tracked> | wc -l   → 7   # "7 lines"  ✓
$ grep -rhoE '\b[A-Z][A-Za-z]*(Tools|Toolset)\b' <all> | sort -u | wc -l → 16  # "16 names"  ✓
$ grep -rn 'WidgetBlueprint\|UWidget\|UUserWidget\|SlateAutomation\|AutomationDriver\|SWidget' <all>
(no output; rc=1)                                               # zero hits  ✓
$ grep -c -i -E 'umg|slate|widget' setup.md operations.md       → 0 / 0  ✓
# materials §4
$ find $V -type f | wc -l                 → 12
$ find $V -type f -exec cat {} + | wc -l  → 1022                # "1022 vendored lines"  ✓
$ grep -rnoE "[A-Za-z]+Tools(et)?\.[A-Za-z_]+" . | wc -l → 12   # "12 hits"  ✓
```

**[O]** Every quoted symbol resolves at the cited line; every count is exact. Spot-checked
`README.md:102/106/107/108/112`, `plugin.json:4`, `SKILL.md:3/8/16/20/24/30/33`,
`unreal-context.sh:72`, `operations.md:34`, `setup.md:12/14/29/31/35/121/125/127/131` — all verbatim
as cited.

**[O] One nitpick:** `ui-umg-slate.md:70` says "the source line is 1031 chars". Measured: `awk
'NR==3{print length}' skills/unreal-mcp/SKILL.md` → **1030** (chars, no newline); `wc -c` → 1031
(bytes incl. newline); no non-ASCII present. "1031 chars" holds only if "chars" means
bytes-including-newline. Cosmetic; the substantive claim (line elided for length, both quoted
fragments verified present by `grep -c` = 1) holds.

---

## 4. Historical-blob facts verify against the fresh clone [O]

`materials.md` cites facts from *deleted* upstream history — the hardest claims to check, since the
pin does not contain the files. Re-derived from my own clone:

```
$ git cat-file -s eaf2e838a259fb41be10309f9373bca8778607c5       → 8306   # "8306 bytes"  ✓
$ git show 823f598^:…/toolsets.md | sha256sum
1b184bbb31836319ef50ad0661306f7e22bbcf19bf71bed70b6a58d60da69cec  -     # same  ✓
$ git show 823f598^:…/toolsets.md | sed -n '31,35p'
## Materials / **MaterialTools** authors Materials: add expression nodes … /
**MaterialInstanceTools** creates and edits Material Instances: set/get scalar, vector, texture,
and static switch parameters. …                                        # F19/F20 verbatim  ✓
$ git log --oneline --all -- skills/unreal-mcp/references/toolsets.md
823f598 Remove/references toolsets.md (#19) / cd1365a Add `LiveCodingToolset`… / 74dba95 … ✓ F22
$ git show be8c183:…/SKILL.md | sed -n '68,73p'
### Material Instances / 1. `MaterialInstanceTools.create` against an existing parent material. …  ✓ F21
$ git rev-parse be8c183:skills/unreal-mcp/SKILL.md  → f3a6d614…  ✓ F21 blob
$ git log -1 --format='%H%n%ci%n%s' 6514615
65146159d6a2fffcedcefa7662b942361dbbf461 / 2026-06-01 22:16:17 -0700 / Trim toolset-specific…  ✓ F24
$ git grep -n -E "MaterialTools\." $(git rev-list --all) | wc -l → 0   # F25 "zero across every revision"  ✓
```

**[O]** All six historical facts (F19–F25) reproduce exactly, including blob SHA-1s and the
deletion-commit log order — byte-precise against a clone the card author did not use.

---

## 5. D1 — the config.toml drift: already documented, already fixed (NOT a new defect)

**Status: redundant confirmation.** I re-derived the drift before reading the file's own correction
note. It is already recorded in-file, so it is *not* a finding of mine.

Row 2 (line 35) cited a **live host path** as its `verified-here` precedent
(`~/.kimi-code/config.toml:2932-2937`). Re-checked 2026-10-19:

```
$ wc -l ~/.kimi-code/config.toml                    → 3570
$ sed -n '2932,2937p' ~/.kimi-code/config.toml
(blank) / [models."opencode-go-7/qwen3.8-flash"] / base_url = "…/anthropic" / protocol = "anthropic" /
provider = "opencode-go-7" / model = "qwen3.8-flash"   # NOT a [[hooks]] block — a model definition
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml  → 3538:[[hooks]]
$ sed -n '3538,3542p' ~/.kimi-code/config.toml
[[hooks]] / event = "Notification" / matcher = "task\\.completed" / command = "notify-send …"
$ grep -c 'SessionStart' ~/.kimi-code/config.toml   → 0   # no SessionStart hook on this host
$ stat -c '%y %s' ~/.kimi-code/config.toml          → 2026-10-18 23:20:43 114434
```

**[O] Already handled, twice over:** (1) the file's own `## Correction note — 2026-10-18 (r103)` §C1
says exactly this — "Row 2's `config.toml:2932-2937` is void … **The line number is not stable and
must not be cited as if it were:** r101 cited 2932, r102 re-measured 3219, r103 measures 3290", and
judges the substance to survive; (2) seat **KIMI-ADAPT** applied the fix this round
(`r107-kimi-adapt.md:282` re-pins row 2 to "the file's **sole** `[[hooks]]` block (line 3538 @
2026-10-19 — moving target, locate with `grep -n`)").

**[O] What my re-derivation adds:** a **4th** observation at a new line (3538, file 3570 lines),
confirming the trend §C1 predicts — a *process* finding (the pointer class is inherently unstable),
not a defect. **Recommendation: none — already satisfied.**

**Same class, still resolving [O]:** `config.toml:1` → `default_permission_mode = "auto"` (row 13);
`installed.json` = 13 lines (row 7 cites `:1-13`); `mcp.json` = 11 lines (row 11 cites `:1-11`);
`kimi --version` → `2.2.0`; BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`;
`KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json"` present in the binary strings (row 1's constant is real).

---

## 6. D2 — the container-route claim is falsified (CONFIRMED) [O]

Two cards dismiss a containerised engine **as a matter of fact**:

> `sequencer.md:297` — "None of this unblocks Sequencer: **the editor is not a containerised
> artifact**, and a Lutris-based Epic-login path is operator-owned…"

> `testing-automation.md:278` — "Neither is a route to this card's `verified-here`: **no
> public Unreal Linux container is named anywhere in the vendored tree**, and Lutris's Epic
> route is an operator-owned login."

Both are wrong. The second is wrong by construction of its own argument.

**The registry says the image exists** (Docker Hub token endpoint — no pull needed, so this
is independent of whether the round's pull finishes):

```
$ curl -sS "https://auth.docker.io/token?service=registry.docker.io&scope=repository:wukakuki/unreal-engine:pull" | jq -r .token
$ curl -sS -H "Authorization: Bearer $TOKEN" "https://registry-1.docker.io/v2/wukakuki/unreal-engine/tags/list"
{"name":"wukakuki/unreal-engine","tags":[ … "dev-5.8.2","dev-5.8.3","dev-slim-5.8.2",
  "dev-slim-5.8.3","runtime-5.8.3","multi-user-server-5.8.3", … ]}     # 126 tags total
# real engine, not a stub:
$ curl -sS -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
    -o m2.json "…/manifests/dev-slim-5.8.3"      # HTTP 200
layers: 30   total: 26791359421 bytes (26.79 GB)   largest: 13.69 GB, 5.92 GB, 1.83 GB …
$ curl -sSL … /blobs/sha256:b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e
WorkingDir: /home/ue4/UnrealEngine   Cmd: ['/bin/bash']   created: 2026-09-26T23:14:48+08:00
history: ubuntu 22.04 base + NVIDIA runtime env + apt i386 multiarch + …
```

**[O]** `wukakuki/unreal-engine:dev-slim-5.8.3` is a public, 26.79 GB, 30-layer Unreal Engine 5.8.3
Linux image whose working directory is `/home/ue4/UnrealEngine`. This round is already pulling
exactly this tag (`docker pull wukakuki/unreal-engine:dev-slim-5.8.3`, log `/var/tmp/ue-pull.log`;
20/30 layers complete at hand-off, pid 596299).

**Two distinct problems, graded separately:**

- `sequencer.md:297` — a **factual error**. The editor *is* available as a containerised artifact. The
  sentence sits inside a §4 whose purpose is to enumerate blockers; one enumerated blocker does not
  hold.
- `testing-automation.md:278` — a **non-sequitur**, and worse. The stated reason ("no public Unreal
  Linux container is named anywhere in the vendored tree") tests whether *the pinned plugin repo
  mentions a container* — never a precondition for a container existing. A plugin that never mentions
  Docker says nothing about Docker Hub. The card uses an in-tree-absence test to rule out an
  out-of-tree artifact, which cannot support the conclusion drawn.

**Scope — what this does NOT falsify [I]:** the container route does not by itself unlock the cards.
Several cards block at "no MCP server configured / no `.uproject`", and a container still needs (a) the
MCP + AllToolsets plugins enabled in a project inside the container, (b) a port published to the host,
(c) a client config. The labels may survive — but for reasons the cards did not give. The correct
statement is "the runtime path exists and is reachable in principle; no bounded probe has been run",
closer to `unproven-runtime` than the cards' "absent by construction".

**Recommendation:** strike or qualify both sentences and record image + tag + registry command as the
newly-identified runtime path — it changes a *label justification*, not just a pointer.

---

## 7. Host receipts re-derived 2026-10-19 [O]

```
$ ls /usr/bin/UnrealEditor /opt/unreal-engine /usr/share/unreal-engine
ls: cannot access '/usr/bin/UnrealEditor': No such file or directory   (×3)
$ command -v UnrealEditor UnrealEditor-Cmd ; echo $?        → 1
$ ss -ltn | grep -c 8000                                    → 0
$ ls -d /home/vgpnk/*/Engine   → ls: cannot access '/home/vgpnk/*/Engine': No such file or directory
$ shellcheck upstream/hooks/unreal-context.sh ; echo $?      → 0   # actors-scene R17 ✓
$ bash upstream/hooks/unreal-context.sh | jq -e '.hookSpecificOutput.hookEventName == "SessionStart"'
true                  # R17 reproduces (run from a dir containing a .uproject)
```

**[O]** Every host receipt in the cards that I re-ran still reproduces — the *engine-absence*
claims are sound. It is specifically the *existence* claims (D1's hook block, D2's container)
that drifted, the pattern one expects: absence is stable, presence moves.

### Version-drift sweep [O]

```
$ curl -sS 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' | grep -E '^pkgver=|^pkgrel='
pkgver=5.8.2 / pkgrel=1
$ curl -sS 'https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine' | jq -r '.results[0].Version'  → 5.8.2-1
```

**[O]** The AUR `unreal-engine` package is **still** `5.8.2-1`, exactly as the cards cite
(`sequencer.md:275`, `materials.md:210`, `scripting-programmatic.md:203`, `testing-automation.md:211`).
No AUR version drift. **Cross-cutting gap it exposes:** the cards' engine-version anchor is 5.8.2
(AUR) while the round's container attempt is 5.8.3, and the plugin pin is silent on engine version
— any card reasoning "engine 5.8.2 → X" should say which 5.8.x it means.

---

## 8. Consistency sweep [O]

```
$ ls -1 executability/*.md | wc -l      → 13
$ grep -n 'executability/' README.md    → 13 rows, paths match the 13 files one-for-one
```

Label distribution (first label token per card): `actors-scene.md` → `unproven-runtime`; the other 12
→ `static-only`. `gameplay-gas.md:151` states the same split. Index's cited lines
`README.md:204/209/213/227/237/240` all resolve verbatim.

**[I]** The split is defensible but not forced: `actors-scene.md` alone chose `unproven-runtime` and
flagged the tension for the adjudicator; `gameplay-gas.md` and `animation-controlrig.md` argue the
stricter test. A *documented* disagreement, not an inconsistency — but the set is not uniform by
accident, and the adjudicator should know it.

---

## 8b. The close-out gate is GREEN and does not see D2 [O]

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
CHECK 1 manifest-verify    MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CHECK 2 clone-equivalence  CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12
                           PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0            STEP=PASS
CHECK 3 verdict-card-scan  CARDS=13 EXPECTED=13 BAD=0
                           CENSUS static-only=12 unproven-runtime=1 verified-here=0
                           NAME_SET=OK NAME_BAD=0                             STEP=PASS
CHECK 4 pointer-sweep      POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0
                           UNRESOLVED=0                                       STEP=PASS
GATE RESULT: PASS (checks failed: 0)     exit=0
```

**Load-bearing close-out fact for round 107: the gate is green while D2 is live.** Not a gate bug —
its scope is explicit and it holds it — but it must not be read as "the cards are verified." Verified
why it is blind:

```
$ grep -c 'adaptation-kimi' corpus/knowledge/unreal-mcp/gate/run_gate.sh   → 0
                         # the adaptation table is never referenced by the gate
$ printf '~/.kimi-code/config.toml:2932-2937\n' | grep -oE "upstream/…:[0-9]+([,-][0-9]+)*"
(no match)               # CHECK 4's regex only matches `upstream/`-prefixed pointers
$ printf 'setup.md:31\n' | grep -oE "upstream/…"   → (no match)   # short-form unscanned
```

**[O]** CHECK 4's two passes cover exactly (a) `upstream/<path>:<line>` and (b) backtick-wrapped
`corpus/…`, `reports/…`, `executability/…`, `gate/…`, `upstream/…`, `.manifest.d/…` paths. A
**host-state pointer** (`~/.kimi-code/…`) is in neither set; a **short-form citation**
(`setup.md:31`, `SKILL.md:68`) is in neither set. The config.toml drift lives in the first blind
spot; **D2 is not a pointer defect at all, so no pointer sweep could ever see it.**

**[I]** Consequence: **a green gate certifies the *bytes*, and this round's defect is in *a claim
about the world*.** The gate's own README says as much, so the honest close-out wording is "gate
green (byte scope)" — never "cards verified." Covering this class needs a second, host-state checker:
re-resolve every live-host pointer and diff against a recorded baseline, and grep the card prose for
*falsifiable existence claims* to re-test against the live world. That checker does not exist yet; it
is this shard's concrete follow-up.

---

## 9. What I could not attack [?, and why]

- **Runtime behavior of any toolset.** Unreachable: no editor on the host (§7) and the container has
  not finished pulling. Everything below `static-only` remains unproven — including whether
  `wukakuki/unreal-engine` ships the `AllToolsets` plugin the corpus needs (`setup.md:31`). **That is
  the one claim D2 does not settle**, and it is the right next probe: once the image is local,
  `docker run --rm <img> ls /home/ue4/UnrealEngine/Engine/Plugins` (or a `.uproject` grep for
  `AllToolsets`) converts "container exists" into "container is a viable runtime path" or kills the
  route. Not run: the pull is incomplete, and a container smoke probe is an orchestrator-owned step.
- **The other 10 cards.** Attacked the 3 assigned line-by-line and swept all 13 mechanically; the
  sweep found no range violations outside the historical-blob class. Full line-by-line on the
  remaining 10 is unwritten.
- **Legal/license.** Out of scope (PROVENANCE §3 owns it).

---

## 10. Hand-off to the orchestrator

**Must-fix before landing (draft here, not an edit):** `sequencer.md:297` and
`testing-automation.md:278` — strike/qualify the "no containerised UE" sentences and record the image
+ tag + registry command (D2, §6).

**Already handled, no action:** the `config.toml` pointer drift (§5) is documented in the file's own
§C1 and fixed by seat KIMI-ADAPT.

**Should-do:** consider a host-state pointer checker to complement CHECK 4 (D3, §8b).

**Evidence of record:** byte-identity 12/12 on 3 transports (§2); 3 named cards clean (§3); historical
blobs F19–F25 exact (§4); AUR still 5.8.2-1 and host receipts reproduce (§7); gate green, exit 0, byte
scope only (§8b).

**Explicitly not claimed:** no card's *byte-level* claim failed. The one new defect is a host-state
claim — a falsified existence claim — the failure class that survives a perfect byte-check, which is
the reason this seat exists. My other candidate finding turned out to be already documented; I report
it as a confirmation, not a defect.

**Pull status at hand-off:** `docker pull wukakuki/unreal-engine:dev-slim-5.8.3`, 20/30 layers, pid
596299 alive, image not yet in `docker images`. If it completes, the plugin-presence probe in §9 is
the highest-value follow-up.
