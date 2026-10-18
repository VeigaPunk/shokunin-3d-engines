# r101 scout roster — province-boundary scan for the Unreal-MCP skill integration

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · round r101 · seat
**SEAT-53 SCOUT** · axis served: **coverage** (C1's province half).

Task: read `PROVINCE.md` and `corpus/knowledge/engines.md`, record **why no
existing lane province owns Unreal-MCP skill integration**, and produce the
rejected-fit table — the nearest provinces and why each rejects this demand —
with evidence pointers.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

**Write scope:** this file only. No commit, no `LOG.md`/`SCORECARD.md`/`SHONEN.md`
write, no touch of the three pre-existing r101 reports. Probe run
`2026-10-18T14:16:14-03:00` (`date -Is`).

---

## 0. Method and provenance

The scan follows the fleet's own sibling-mint procedure (`PROTOCOL.md:37-44`):
"scan `MANIFEST.json` + every `PROVINCE.md` and records the roster map it decided
against — that scan record is part of the mint evidence". Two prior scans in this
fleet establish the artifact format I reuse: `.ufo/scopes/shokunin-12h-20261014/mint-roster-scan.json`
(17 lanes, per-lane `province_sha256` + one-line rejection) and
`.ufo/scopes/kotodama-mint-20261017/mint-roster-scan.json` (19 lanes, `verdict`+`reason`).

What was actually read, and the commands that prove the scan's population:

```sh
$ find . -maxdepth 2 -name 'PROVINCE.md' -not -path './.git/*' | wc -l
21
$ python3 -c "import json; print(len(json.load(open('MANIFEST.json'))['roster']))"
13
```

21 province files exist; 13 are rostered in `MANIFEST.json`. The 8-lane gap is the
probation tier (`PROTOCOL.md:48` — a sibling self-iterates ≥3 verified rounds before
a roster row exists). **Both tiers were scanned**; a province is authoritative for
its own boundary whether or not it yet has a roster row. My own lane `game-dev-3d`
is one of the 14 probation lanes.

The demand under scan is concrete and file-anchored, not hypothetical: Epic Games'
*Unreal Engine Skills for Claude Code* plugin, pinned at
`a6aa73ada02a9fb1f5415bec491f9942c519b297`, 12 tracked files, MIT
(`LICENSE:1-3`), already vendored byte-identical by this round's C1 seats.

---

## 1. Finding

**No existing lane province owns Unreal-MCP skill integration.** The demand is not
merely unclaimed by an accident of naming; it fails to fit every candidate on a
declared-scope test, and the four greps below are the mechanical form of that.

The decisive scan is a *census of the demand's vocabulary across all 21 provinces*:

```sh
$ grep -c -i 'mcp' */PROVINCE.md | grep -v ':0'
kaidoku-shokunin/PROVINCE.md:16
```

Exactly **one** province names MCP at all, and it names only its own REA server.
MCP as a *class* is unowned.

```sh
$ grep -rli 'claude code\|marketplace\|claude-plugins' */PROVINCE.md
exit=1
```

**Zero** provinces name the Claude Code plugin/marketplace surface — the surface
this demand actually lives on (`.claude-plugin/plugin.json`, `hooks/hooks.json`).

```sh
$ grep -rli 'unreal' */PROVINCE.md
game-dev-3d-shokunin/PROVINCE.md
$ grep -rn -i 'toolset' */PROVINCE.md
revenger-shokunin/PROVINCE.md:5:...browser/Electron runtime evidence — using the REA skill and its toolset,
```

`unreal` appears in one province — mine. `toolset` appears once, and it is a **false
friend**: revenger's "toolset" is the REA skill's tool catalog
(`revenger-shokunin/PROVINCE.md:5`), not Unreal's `ToolsetRegistry`. No province
names `ToolsetRegistry`, `list_toolsets`, `describe_toolset`, or `call_tool`
(`grep -rn -i 'live editor\|live-editor\|automation\|toolsetregistry' */PROVINCE.md` → exit 1).

**[I]** The reason is structural rather than accidental. The demand is a *cross-layer*
artifact: its content is Unreal-domain knowledge (an engine concern), its form is
agent-skill packaging (a meta-craft concern), and its execution is MCP client/server
plumbing (a harness concern). Every province in this fleet is a single-layer domain,
and each layer's nearest owner explicitly refuses the other two layers. That is what
makes it unplaceable rather than merely unassigned — and it is the condition
`PROTOCOL.md:37` names as mint-worthy.

---

## 2. Rejected-fit table — the nearest provinces

Ordered by adjacency. "Province" is the sha256 of the province file as scanned
(`sha256sum <lane>-shokunin/PROVINCE.md`), so this table is re-checkable against
the exact bytes I read.

| Rank | Lane | Province sha256 | Nearest claim it holds | Why it rejects this demand | Pointer |
|---|---|---|---|---|---|
| 1 | `game-dev-3d` | `1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac` | "3D game production verified by **executable headless fixtures** … across 3D engines and rendering tooling: Godot, Unity, **Unreal Engine**, three.js" | The only province that names Unreal — but the owning verb is *headless-fixture verification*, and Unreal cannot execute headless here (`engines.md:10`, row `Unreal Engine \| no \| no`). The province already routes that case: "Where an engine cannot execute headless on this host, the lane builds **format-level and static fixtures** … and labels runtime behavior unproven". A `.claude-plugin/plugin.json` is neither a headless fixture nor a 3D format container. Also `PROVINCE.md:33` refuses "engine/editor source mutation" and the lane's write scope is `.shokunin/game-dev-3d/**` (`:46`) | `game-dev-3d-shokunin/PROVINCE.md:3-12,33-47`; `corpus/knowledge/engines.md:10` |
| 2 | `kotoba` | `4f11c1611b3aa7b8d8b5346750d4f0338c2d9b18f9c3efc9c5646cd94e667acb` | "prompt & skill craft — scopes SKILL.md/AGENTS.md quality, trigger fidelity" | The closest *form* match: this demand ships three SKILL.md files. Rejected on content, and kotoba says so itself — its SKILL.md anti-triggers name "domain content inside a skill's reference/ tree" (`SKILL.md:8-9`), and its body is explicit: "Won't audit the *content* of another skill's `reference/` tree — that's the owning domain's province. Report cross-domain evidence back, don't absorb it" (`SKILL.md:447-448`). kotoba audits skill *craft*; it explicitly does not own what a skill is *about*. Owning Unreal toolset semantics would be exactly the domain-content absorption its anti-trigger names | `kotoba-shokunin/PROVINCE.md:3-6`; `kotoba-shokunin/SKILL.md:8-9,447-448` |
| 3 | `kumitate` | `caa83fde27c036829e2f4c882e5c7b2270d95586bd6a12a551b3d75a72d491d2` | "orchestration & tooling — scopes OMP task/hub, ufo-fsd scripts & runtime" | Owns *this fleet's* orchestration substrate and does document a Kimi MCP plane (`corpus/knowledge/kimi-config-plane.md:257-258`, the `[mcp_servers.rea]` table). Rejected because that plane is the fleet's **own** client config, not a third-party editor bridge: `grep -c -i 'mcp' kumitate-shokunin/PROVINCE.md` → **0** — the MCP knowledge is corpus, never a declared surface. The province scopes "OMP task/hub, ufo-fsd scripts & runtime" and refuses "anything outside this domain" | `kumitate-shokunin/PROVINCE.md:3-6`; `kumitate-shokunin/corpus/knowledge/kimi-config-plane.md:257-258` |
| 4 | `kaidoku` | `fe7f3f61c6beb6d601bf6780194ad10f8641c402c2501067d6a93f29c3b37c1c` | "reverse engineering of shipped artifacts with REA on this Linux host" | The only province with MCP as a *named surface* (16 hits) — but the MCP server is REA's own (the `REA MCP server` surface row, `PROVINCE.md:44`; the literal `npx -y rea-agents@6.4.0 mcp` is `MINT.md:10`). The demand's artifact is a plugin of **instructions and JSON**, not a shipped binary to reverse; and the province's discipline is REA-tool operation, not editor control. It also refuses live-target runtime evidence, which is the demand's only unproven half | `kaidoku-shokunin/PROVINCE.md:3-26,44`; `kaidoku-shokunin/MINT.md:10` |
| 5 | `revenger` | `63acc3d033869f93f3e13da79e35023d86baa60b3f1d3b52861b019183b4b19f` | "reverse engineering of shipped artifacts … using the REA skill and its toolset" | Same REA-MCP shape as kaidoku, and the only other `toolset` hit. Rejected on the same test plus its own declared refusals — "live-target execution beyond the declared target and lifecycle (REA runtime discipline) … DRM circumvention … publishing reversed code" — which is the demand's only unproven half. (The phrase "reverse engineering as an end in itself" is `game-dev-3d`'s refusal, `PROVINCE.md:38`, not revenger's.) The plugin is vendored *as documentation*, not disassembled | `revenger-shokunin/PROVINCE.md:3-6,19-24` |
| 6 | `tabi` | `16c27b12a60dbbcc43903d40334c314f6587bd8703d1e890e076398eac1a946a` | "the kimi-webbridge plugin (`~/.kimi-code/plugins/managed/kimi-webbridge/`) as primary substrate documentation" | The only province that owns a *plugin* as a surface — so it is the nearest structural precedent — but the plugin is the browser/CDP bridge, and the province scopes "browser & web-interaction craft … driving real browsers against real sites". A UE editor plugin is not a browser target | `tabi-shokunin/PROVINCE.md:3-16` |
| 7 | `tameshi` | `f5e28bf144b0601c242e43d2a9d8b60b08b8ac9476728b9f5809aa655b77d89f` | "verification-fixture craft — the reusable method of honest checks" | Could verify the *static* half (byte-identity, shellcheck of the hook). Rejected by its own clause: "**Refuses: product domains** — every lane's gate remains its own; tameshi owns only the reusable craft". Unreal toolset coverage is a product domain | `tameshi-shokunin/PROVINCE.md:3-16` |
| 8 | `chousa` | `cf7826a43aaab7c00708ab54bb46577217e7a67ab44a43a33e17ee2a58c1bbec` | "deep-research method (調査) — the reusable craft of source research" | Could research the upstream. Rejected: "research method only; refuses domain content" — its own mint scan row for kotodama (`kotodama-mint-20261017/mint-roster-scan.json`, lane `chousa`) records exactly this verdict | `chousa-shokunin/PROVINCE.md:3-14`; `.ufo/scopes/kotodama-mint-20261017/mint-roster-scan.json` |
| 9 | `game-dev-2d` | `e166ddded9941bb2cf2eec1705559728f5b304de8579c3cba6da970bb90b40fc` | 2D production via headless fixtures | Rejected: 2D scope, same `engine/editor source mutation` refusal, and a `game-dev-2d/**` write boundary | `game-dev-2d-shokunin/PROVINCE.md:3-12` |

**The zero-contact tier.** Twelve further provinces score **0** on a combined
`grep -ci 'unreal\|mcp\|claude code\|marketplace\|toolset'` over their own province
file, i.e. they neither name nor could plausibly claim any layer of this demand:
`audio` `kagi` `kama` `kasegi` `kengaku` `kake` `lore` `kotodama` `mado` `mori`
`souji` `tsukuroi`. Together with the 9 rows above, all 21 provinces are accounted for.

---

## 3. What the scan does *not* establish

- **It does not mint anything.** A province-boundary scan is mint *evidence*
  (`PROTOCOL.md:37-44`), not a mint. It records the roster map a decision was
  made against. Nothing here creates a sibling repo, a `MINT.md`, a
  `shokunin.conf` lane declaration, or a `MANIFEST.json` row.
- **It does not prove the mint bar is met.** The bar is "two documented
  *unplaceable* demand instances **or** an explicit operator directive"
  (`PROTOCOL.md:28-30`). This scan supplies **one** unplaceable instance (this
  round's C1/C2/C3 work) and zero operator directives. A second instance, or the
  directive, is what a future mint would need; I did not search for one and do not
  claim it exists.
- **[?] The nearest-fit rejection is judgment, not measurement.** Ranks 2-9 are
  my readings of declared scope against observed text. The mechanical parts — the
  greps, the counts, the hashes — are receipts; the "why it rejects" column is
  argued. A non-author verifier should re-read the pointers, and the integrator
  arbitrates contested scope (`PROTOCOL.md:437-442`).
- **[?] Whether `game-dev-3d` should absorb it instead of a mint.** Row 1 is the
  genuinely arguable case: my own province names Unreal and already owns a
  format-level Unreal artifact (`corpus/artifacts/unreal-r22/`). I record the
  counter-argument rather than suppress it: the r22 precedent is a *static
  descriptor fixture*, and r101's C1/C2/C3 work is also landing as a read-only
  reference corpus (`corpus/knowledge/unreal-mcp/`) inside this lane. If the
  integrator reads the province's "any further 3D tooling the lane discovers and
  validates on its shonen path" clause as covering editor-bridge skill corpora,
  the demand is *absorbed*, not unplaceable — and this scan's conclusion would
  need revision. I state that because the honest reading of row 1 cuts both ways,
  and a scan that hid it would be worthless to the arbiter.
- **The host half is re-derived, not inherited.** The seat's instructions said to
  re-derive only if the seat declares it; this seat does declare it for the four
  facts its conclusion leans on: 32 cores (`nproc`), 30G RAM (`free -g`), 780G free
  on `/` (`df -h /`), `shellcheck 0.11.0` (`shellcheck --version`), and Unreal
  Editor absent (`command -v UnrealEditor UE4Editor` → nothing; `/opt/unreal-engine`
  and `/usr/share/unreal-engine` → No such file or directory). All match the
  round's host receipts.

---

## 4. Evidence index

Every claim above carries a command; the commands and their observed output:

| # | Claim | Command | Observed |
|---|---|---|---|
| 1 | province population | `find . -maxdepth 2 -name 'PROVINCE.md' -not -path './.git/*' \| wc -l` | `21` |
| 2 | rostered lanes | `python3 -c "import json;print(len(json.load(open('MANIFEST.json'))['roster']))"` | `13` |
| 3 | MCP named by one province | `grep -c -i 'mcp' */PROVINCE.md \| grep -v ':0'` | `kaidoku-shokunin/PROVINCE.md:16` |
| 4 | Claude Code / marketplace unnamed | `grep -rli 'claude code\|marketplace\|claude-plugins' */PROVINCE.md` | exit `1`, no files |
| 5 | Unreal named by one province | `grep -rli 'unreal' */PROVINCE.md` | `game-dev-3d-shokunin/PROVINCE.md` |
| 6 | `toolset` is a false friend | `grep -rn -i 'toolset' */PROVINCE.md` | `revenger-shokunin/PROVINCE.md:5` (REA toolset) |
| 7 | no toolset-registry vocabulary anywhere | `grep -rn -i 'live editor\|live-editor\|automation\|toolsetregistry' */PROVINCE.md` | exit `1` |
| 8 | kumitate's MCP count | `grep -c -i 'mcp' kumitate-shokunin/PROVINCE.md` | `0` |
| 9 | zero-contact tier | `for l in audio kagi kama kasegi kengaku kake lore kotodama mado mori souji tsukuroi; do grep -ci 'unreal\|mcp\|claude code\|marketplace\|toolset' $l-shokunin/PROVINCE.md; done` | `0` × 12 |
| 10 | Unreal row in the census | `grep -n 'Unreal' corpus/knowledge/engines.md` | `10:\| Unreal Engine \| no \| no \| census at mint; r22 … \| not installed …` |
| 11 | upstream pin verified | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| 12 | vendored content is byte-identical | per-file `sha256sum` diff, clone vs `corpus/knowledge/unreal-mcp/upstream/` | `OK` × **12/12**, `DIFF` × 0 |
| 13 | upstream size/type | `find /tmp/ue-skills-ref -path '*/.git' -prune -o -type f -print \| wc -l`; `du -sh` | `12` files, `92K`; all text (11 ASCII/UTF-8 + 1 shell script), no binaries, `git ls-files -s` → all mode `100644` |
| 14 | province hashes | `sha256sum <lane>-shokunin/PROVINCE.md` | see table §2 |
| 15 | host receipts | `nproc`; `free -g`; `df -h /`; `shellcheck --version`; `command -v UnrealEditor UE4Editor` | `32`; `Mem: 30`; `/dev/mapper/root 930G 133G 780G 15%`; `0.11.0`; (nothing) |

Precedent scan artifacts read for format, not cited as this round's evidence:
`.ufo/scopes/shokunin-12h-20261014/mint-roster-scan.json` (17 rows),
`.ufo/scopes/kotodama-mint-20261017/mint-roster-scan.json` (19 lanes),
`kaidoku-shokunin/MINT.md` §"Roster scan (rejected fits)".

**Hygiene:** one tracked-tree write (this file). `git status --porcelain` at
completion shows untracked `corpus/knowledge/unreal-mcp/`,
`reports/round-101/probes/`, and the sibling seats' r101 reports — none written by
this seat. No commit; the L1 lands the round commit.
