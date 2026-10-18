# r101 distiller — mid-flight synthesis of the Unreal-MCP integration round

**Seat:** SEAT-51 DISTILLER · round 101 · lane `game-dev-3d-shokunin`
**Declared write path:** this file only. No commit. `LOG.md`, `SCORECARD.md`,
`SHONEN.md`, `SKILL.md`, `PROVINCE.md` and the 3 pre-existing `reports/round-101/`
files were not touched.
**Synthesis runtime:** `2026-10-18T14:19–14:21-03:00`. The tree is **live-mutating
under concurrent seats** — the snapshot below is frozen at that time and is not a
claim about the final state.
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @
`a6aa73ada02a9fb1f5415bec491f9942c519b297`.

Tags: **[O]** receipt-pinned observation I ran · **[D]** deduped from another seat's
receipt (pointer given) · **[?]** unknown / not measurable here.

**Method.** Read every artifact under `corpus/knowledge/unreal-mcp/` and
`reports/round-101/` present at runtime; re-derive the load-bearing numbers myself
where cheap; collapse the 40 artifacts' overlapping claims into one numbered list;
then name what no seat covered. **My own receipts are in §6** — findings marked [O]
there are mine, not quoted from a peer transcript.

---

## 1. Deduped findings

Findings are ordered by how much downstream work depends on them, not by seat.

### A. Provenance and byte-identity (C1)

1. **The pin is real and the vendored tree is byte-identical to it.** 12/12 tracked
   upstream files vendored under `corpus/knowledge/unreal-mcp/upstream/`; a fresh
   clone I made myself reproduces the pin and `diff -r` against the vendored tree
   exits 0 with **no output at all**. [O] §6.1–6.2. Corroborated independently by
   SEAT-15 (`/tmp/r101-audit`), SEAT-44 (four transports: clone, codeload tarball,
   GitHub API blob SHA1, `cmp`), SEAT-24, SEAT-54. [D]

2. **Upstream tracks 12 files, not 11.** The round brief's "all 11 vendored paths"
   undercounts; the 11 seats split 12 files as 11 single-file shards plus `seat11`
   covering `CODEOWNERS` + `.gitignore`. [O] §6.3. Flagged independently by SEAT-44,
   SEAT-14, SEAT-53. [D] **The vendoring is correct either way; only the brief's
   wording is wrong.**

3. **The byte-identity gate is non-vacuous.** A one-byte append to a private copy of
   `CODEOWNERS` flips the sweep to exactly one `FAILED` row with
   `WARNING: 1 computed checksum did NOT match`. [O] §6.4. SEAT-54 proved the same
   over ~15 mutation classes and found the one blind spot: `sha256sum -c` cannot see
   an **extra unlisted file** — that needs a second check, set-equality against
   `git ls-files`. [D]

4. **Tree shape:** 12 files, 1022 lines, 63 556 bytes, **0 symlinks**, no submodules,
   no LFS, no `.gitattributes`; all modes `100644`. [O] §6.5.

5. **Plugin identity:** name `unreal-engine-skills-for-claude-code`, version `3.1.1`,
   license `MIT`, author Thomas Mansencal `<thomas.mansencal@epicgames.com>`;
   pin subject `[MCP] Permit safe concurrent tool calls`, authored 2026-09-17
   13:19:50 +1200; tree hash `b5b9624b00fc90217240e823406699d0ab78b959`; no tags;
   `HEAD == origin/main`. [D] SEAT-15, SEAT-16, SEAT-12 (`PROVENANCE.md`).

6. **MIT permits this vendoring and the one condition is satisfied** (notice
   retained in `upstream/LICENSE`). No `NOTICE`, no third-party dir, no per-file
   SPDX header anywhere. **Lane-level consequence flagged for the L1:** the subtree
   is untracked, and the lane remote `VeigaPunk/shokunin-3d-engines` is **PUBLIC**,
   so committing this round publishes a verbatim MIT copy — permitted, but a
   deliberate choice. [D] SEAT-28.

### B. The bash hook — the only executable artifact here

7. **The hook is the one upstream artifact that actually runs on this host, and it
   behaves as documented.** 4 branches exercised: `.uproject` + no `.mcp.json`
   → "No `.mcp.json` is present"; `.uproject` + `.mcp.json` → "already present";
   no project marker → silent, exit 0; `CLAUDE_UE_HOOK_DEBUG=1` → debug line on
   stderr, clean JSON on stdout. All exit 0, all stdout `jq`-valid. [O] §6.6.

8. **`shellcheck` default ruleset is clean (exit 0); `shellcheck -o all` yields 50
   findings, 100 % severity=style** (SC2250 ×36 require-variable-braces, SC2292 ×14
   require-double-brackets). None is correctness-bearing, and `-o all` is opt-in, so
   a default CI run reports nothing. [O] §6.7 (default run); SEAT-18 (full `-o all`
   dump). [D]

9. **REAL DEFECT (not a style nit): the hook hand-rolls JSON escaping and omits C0
   control characters.** `unreal-context.sh:80-82` escapes only `\` and `"`. A
   `.uproject` **filename** containing LF, TAB or other control bytes makes the hook
   emit **malformed JSON on stdout while still exiting 0 and printing no
   diagnostic**. Reproduced by SEAT-18 across 3 cases (N/O/P); the escaping chain is
   exactly as they describe. Blast radius is low (legal on Linux/macOS, impossible
   on Windows; default project names never trigger it). Not a security issue — no
   command is evaluated from the value. **The fix shape is to route the value through
   a real JSON encoder** (`jq -Rn --arg v …`) rather than extend the substitution
   chain. [D] SEAT-18 §4.1, SEAT-24 F10. **No seat has applied or tested a fix.**

10. **The hook's `SessionStart` envelope is a Claude-Code-specific contract and does
    NOT transfer to Kimi.** The emitted
    `{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":…}}`
    is not a shape Kimi injects; Kimi parses only
    `{message, hookSpecificOutput{message, permissionDecision, permissionDecisionReason}}`,
    so a straight port would **silently discard the injected context**. The matcher
    also drifts: upstream `startup|resume|clear` vs Kimi's regex over `source` with
    `startup`/`resume` only. [D] SEAT-24 §6, adaptation rows 3–4.

11. **Documented false negative in the hook's project-root rule.** The hook looks for
    `.mcp.json` in the `.uproject` directory, but `setup.md:65` writes it to the
    **workspace root** for source builds — the hook then reports the file absent even
    though the editor generated it. [D] SEAT-21 D4.

### C. What the docs actually specify

12. **13 domain bullets, exactly** in `README.md` §What's Available (lines 96–112).
    [O] §6.8. This is the denominator C2's 13 cards are built on.

13. **But "30+ toolsets / hundreds of tools" is not supported by the vendored bytes.**
    Only **14 real toolset class names** appear anywhere in the tree (17 raw tokens
    minus 2 template placeholders `MyToolset`/`UMyToolset` minus `RefreshTools`, which
    is a console command caught by a dotted-suffix match). **3 of the 13 domains —
    Animation, UI, Gameplay — have no named toolset at all**, and Animation/Gameplay
    are multi-toolset domains compressed into one bullet. **The 13 rows are coverage
    buckets, not a toolset list**, and the "hundreds of tools" figure is
    `unproven-runtime` here — no catalog ships in the repo. [O] §6.9; SEAT-25 E3. [D]

14. **Tool-search mode is on by default and changes the whole client contract.**
    `tools/list` returns only `list_toolsets`, `describe_toolset`, `call_tool`; toolset
    tools like `BlueprintTools.create` are **never registered as native MCP tools** and
    are dispatched server-side through `call_tool`. Toggle: `bEnableToolSearch`
    (default `true`) under `[/Script/ModelContextProtocolEngine.ModelContextProtocolSettings]`.
    [D] `operations.md:16-28`, SEAT-21, SEAT-22.

15. **Exactly 4 console commands** are documented in `operations.md`'s table
    (`StartServer [port]`, `StopServer`, `RefreshTools`, `GenerateClientConfig <client>`),
    with a 6-value client enum (`ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`,
    `All`); 39 distinct backticked tokens in the file. [D] SEAT-22.

16. **The two JSON manifests are well-formed and minimal.** `plugin.json`: exactly 5
    top-level keys, no `mcpServers` key — deliberately, because the plugin ships no
    static `.mcp.json` and the editor generates it. `hooks.json`: `description` +
    `hooks`, one `SessionStart` matcher `startup|resume|clear`, `timeout: 5`. [O] §6.7
    (`jq -e` exit 0 on both); SEAT-16. [D]

17. **All 3 `SKILL.md` files carry exactly two frontmatter keys: `name` +
    `description` — and no tool-allowlist key exists in any of them, nor anywhere in
    the repo's 53-commit history.** This is a **calibration negative result**: a
    Claude→Kimi adapter that expects to read `allowed-tools` / `tools` /
    `permissions` will find nothing and must fail *open*, not closed. [D] SEAT-19.

18. **Frontmatter parsing hazards, measured:** `description` is a single 1005–1054-char
    double-quoted line (so a byte-budget reader silently truncates the skip clause);
    only `unreal-mcp` uses `\"` escapes (10 of them, so a naive `strip('"')` works on
    2 of 3 files and leaves literal backslashes on the third); skip-clause casing
    differs (`SKIP for:` vs `Skip for:`); `name` equals the directory name in all 3,
    making directory-derived naming a safe fallback. [D] SEAT-19 §6.

19. **The three documents agree on port `8000`, path `/mcp`, the three meta-tool
    names, and the `bEnableToolSearch` default; 4 divergences exist, all wording or
    scope.** The one **real contradiction**: `operations.md:46` tells you to check for
    **both** `unreal-mcp` and `unreal-mcp-proxy`, while `setup.md:115` says configure
    **one** Unreal connection, not both. Lower-severity: `localhost:8000` vs
    `127.0.0.1:8000`; `<port>` (required-looking) vs `[port]` (optional). [D] SEAT-21.

20. **Install path, measured against the live marketplace:** the documented
    marketplace install **is reproducible here** (v3.1.1, `Status: ✔ enabled`), but
    README's premise that `claude-plugins-official` "is available automatically" is
    **false on this host** — a fresh HOME lists only `anthropic-plugin-directory`, and
    installing by the documented *name* fails `not_found`. The **team flow**
    (`enabledPlugins` in `.claude/settings.json` → "prompted to install
    automatically") does **not** auto-install non-interactively: `claude plugin list
    --json` → `[]` even with the marketplace pre-added and the trust dialog accepted.
    The editor-free `.mcp.json` hand-write path **is** reproducible (Claude Code
    parsed it as `Pending approval`). [D] SEAT-26.

21. **`ModelContextProtocol` and `AllToolsets` are 5.8-only**, per Epic's release
    notes, its version-gated documentation, and its plugin index — all of which
    resolve at 5.8 and return a content-less stub at 5.7 and below. Every row is
    labeled `UNVERIFIABLE-HERE` (network-document grounded, loop not closable on this
    host). `unreal_mcp_proxy` is build-conditional under `Extras/Proxy` with 4
    documented platform paths; **whether any distribution actually ships it is not
    established by any source reachable here.** [D] SEAT-29.

22. **The r22 `.uplugin` and this `.claude-plugin/plugin.json` share no schema.**
    Both are valid JSON but their case-sensitive top-level key intersection is the
    **empty set**; after case-folding only `version`/`Version` and
    `description`/`Description` collide, and both are false friends (`Version` is a
    JSON **integer** in the `.uplugin`, a semver **string** here). Upstream ships no
    `.uplugin` of its own. **Vendoring this plugin gives the corpus no Unreal
    descriptor to compare against and makes r22 no more executable.** [D] SEAT-27.

23. **Markdown link integrity is clean.** 3 links across the 6 vendored `.md` files,
    **0 broken, 0 unresolved anchors**; the 4 apparent `[this]()` "links" in
    `create-toolset/SKILL.md` are C++ lambda captures inside a fenced block. [O] §6.10
    (I re-ran the probe script; identical result).

### D. The C2 verdict cards

24. **13 cards exist, each labeled exactly one of the three permitted values.** Census
    by my own scan: **12 × `static-only`, 1 × `unproven-runtime`
    (`actors-scene.md`), 0 × `verified-here`** — exactly the shape expected on a host
    with no editor. [O] §6.11.

25. **The cards' evidence is documentation-availability, not runtime.** The sharpest
    statement of it: the Blueprints card records that the corpus **advertises** a full
    Blueprint surface and **specifies none of it** — not one tool signature, node/pin
    schema, graph representation or compile-result contract exists in the 1022
    vendored lines. A reader learns that `BlueprintTools.create` is a *name shape* and
    cannot call, type, or predict it. [D] `executability/blueprints.md`.

26. **The subtree index was rewritten mid-round, and its "expected verdict" column
    was removed — do not grep it.** In the version I read at the start of this
    synthesis, the `executability/` table carried an *expected verdict* column
    declaring `unproven-runtime` for all 13 rows, which disagreed with the landed
    census (12 `static-only` + 1 `unproven-runtime`). By `14:16:52` a concurrent seat
    had replaced the table with a **card-path-only** table that deliberately
    restates no labels, adding the rule *"Neither the expectation nor this index
    overrides the card"* and a caveat that the card set is live-mutating. [O] §6.14.
    The lesson for close-out is the durable part: **the card is the only
    authoritative label source**; any count taken from the index, or from a peer
    report, is a snapshot that can be invalidated within minutes.

### E. The C3 adaptation artifact

27. **`adaptation-kimi.md` carries a 15-row Claude→Kimi table with 7 sections**
    (table, row notes, live probes, NONE-FOUND searches, verification policy,
    unproven-runtime register, ranked recommendation). Every row carries a source
    pointer of the form `upstream/<path>:<line>`; statuses used are `verified-here`,
    `static-only`, `unproven-runtime`. [O] §6.12.

28. **The policy is binary and has no middle ground**: *proven* = byte-identical
    vendored content **and** a static check actually run on this host; *unproven* =
    requires a live Unreal Editor. Corollary rules recorded: a connected MCP client, a
    visible cached catalog, or a successful `unreal_mcp_status` **does not** prove
    Unreal is reachable; absence of the engine never authorizes a runtime claim. [D]
    `corpus/knowledge/unreal-mcp/README.md:12-33`, adaptation §5–§6.

29. **`NONE-FOUND` rows are the load-bearing calibration output, not the mappings.**
    Five Claude mechanisms have **no** Kimi equivalent: the hook stdout envelope (§9
    above), project-scope plugin install (Kimi plugins are per-user only), the
    `GenerateClientConfig` Kimi target, `CLAUDE_UE_HOOK_DEBUG`, and `clear` as a hook
    matcher value. [D] adaptation rows 4, 9, 12, 14 and §4.

30. **One structural caveat on C3's "resolvable pointer" leg:** the upstream-side
    pointers resolve inside the corpus, but the **Kimi-side** pointers are host-local
    absolute paths — `~/.kimi-code/config.toml`, `~/.kimi-code/mcp.json`,
    `~/.kimi-code/plugins/installed.json`, `~/.claude/…` — which are **not** part of
    the corpus and will not resolve for any other host or reader. [O] §6.12.

### F. C1 scope and round hygiene

31. **C1's wording is under-scoped, and a seat found the concrete gap.** "All upstream
    content files" is satisfied against **the pinned commit**, but upstream has **open
    PR refs** (`pr/1`, `pr/2`, `pr/4`, `pr/5`) carrying **5 paths that are not on
    `main` and not vendored** — e.g. a `hooks/hooks.json` variant where the command is
    quoted differently. The vendoring is byte-perfect either way; the question is
    whether the claim's wording should be tightened at adjudication. [D] SEAT-45.

32. **Round hygiene holds.** `git diff --name-only` is **empty** — no tracked file was
    modified by any seat. `LOG.md`/`SCORECARD.md` (2026-10-16) and
    `SHONEN.md`/`PROVINCE.md` (2026-10-13) all predate the round; the 3 pre-existing
    `reports/round-101/` files carry their original 2026-10-15 mtimes. All round output
    is untracked new files. [O] §6.13.

33. **Directory-level artifacts the close-out should know about.** (a) `reports/round-101/`
    is live-mutating, so any count in any report is a snapshot, not a fact — including
    this one. (b) A **duplicate basename** `navagent-dissection.md` exists across
    rounds (`reports/frontier/` and `reports/round-101/`) and both carry load-bearing
    evidence. (c) `r101-mutation-tester.md` and `r101-reviewer-c1.md` deviate from the
    lane's `r101-<role>.md` convention used 26 times, so cross-round greps for
    `r101-reviewer.md` will miss them. (d) A **pre-written close-out protocol** exists
    with a fail-closed rule ("a missing artifact is a FAIL, not a warning") and a
    self-known defect: `pointer-check.sh` self-contaminates on its own negative
    controls, so `r101-verification-protocol.md` must be excluded from the pointer
    sweep or the step reads as a false FAIL. [D] SEAT-55, SEAT-64, SEAT-58.

### G. The host wall

34. **The source route to an engine is walled, confirmed by independent re-derivation:**
    `git ls-remote` fails identically on HTTPS and SSH; all 4 AUR recipes gate on
    exactly that probe and abort (`r101seat12-aur-PKGBUILD:280,327,336`); Epic's
    download endpoints return HTTP 403. [D] SEAT-46, SEAT-12. Consistent with the
    round's standing host receipt.

35. **The wall is NOT total — and this is the highest-leverage unproven fact in the
    round.** A public, anonymously-pullable Docker image
    `wukakuki/unreal-engine:dev-slim-5.8.3` (37 427 pulls) has a build history showing
    `Build.sh "$EDITOR_TARGET" Linux Development`, i.e. it contains a **built editor**.
    Its registry manifest and config blob were read **without pulling** (anonymous
    token). 26.8 GB compressed ≈ 36 min at 12.5 MB/s against 780 GB free. **Labeled
    `unproven`**: nobody pulled it, no editor was run, and whether that build ships the
    required `ModelContextProtocol` / `AllToolsets` plugins is **not established**. [D]
    SEAT-46 §0.

36. **No live-editor claim exists anywhere in the round, and none could.** Every
    runtime assertion is labeled `unproven-on-this-host` by construction. [O] — I
    checked: the only `verified-here` labels in the tree are attached to static checks
    (hashes, JSON parses, lint, link resolution, hook branches). [D] all seats.

---

## 2. Claim status at my runtime

| claim | axis | deliverable | status at `14:21-03:00` |
|---|---|---|---|
| **C1** | coverage | 12/12 byte-identical + provenance manifest | **complete and independently reviewed** (non-author C1 review + mutation tester + adversarial critic) |
| **C2** | depth | 13 cards, one label each, with evidence | **complete**: 13/13 cards, 12 `static-only` + 1 `unproven-runtime`, 0 `verified-here` |
| **C3** | calibration | adaptation table + proven/unproven policy, resolvable pointers | **artifact complete** (15 rows, 7 sections); **no non-author review of C3 exists yet** — see G9 |

**Mid-flight correction to my own earlier read.** When I started, `executability/`
held 5 cards and `PROVENANCE.md` / `adaptation-kimi.md` did not exist, while the
subtree index already advertised the latter two. Both defects closed during my run.
The index-before-artifact window is worth noting as a **process** finding: the
synthesis index landed ahead of its referents, so a checker sampling mid-round would
have recorded 2 missing C3 files and 8 missing C2 cards that were never actually
missing. Two peer seats independently filed the same transient as a "broken promise"
(SEAT-58 open item 2, SEAT-46 finding 3, SEAT-52 §4.2) — **all three are now stale.**

---

## 3. Gaps no seat has covered

Each gap is named with the evidence that it is open, not assumed.

**G1 — No non-author verification of C3.** C1 has a reviewer, a mutation tester and an
adversarial critic; C2 has a reviewer. The adaptation table's `verified-here` rows
(the `~/.kimi-code/config.toml:2932-2937` hook precedent, and live probes §3.1–3.5)
have **no independent re-derivation by any second seat**. C3 is the only claim whose
evidence is author-only. Highest-priority close-out gap.

**G2 — The Docker route is found but unexercised.** SEAT-46 identified a pullable
built editor and stopped at the manifest blob. Nobody has established whether
`wukakuki/unreal-engine:dev-slim-5.8.3` actually ships `ModelContextProtocol` and
`AllToolsets`. Until that is answered, "no live-editor evidence can exist here" is a
**hypothesis with a known counter-route**, not a closed fact.

**G3 — `setup.md` is cited by 11 probes but never audited as its own subject.** Every
probe that touches it does so for its own purpose (prerequisites, install steps,
transport facts). The **proxy installation procedure** (`setup.md` step 4: the
per-platform binary table, the `--mcp-json … install` command, the
`_upstreamEntry` rewrite, `uninstall` to revert, cache scoping) is labeled
`NOT-REPRODUCIBLE` and then dropped. No artifact states what the proxy procedure would
do if a binary existed, and no card covers "proxy" as a subsystem.

**G4 — No card or probe covers the Agent-Skill subsystem.** `AgentSkillToolset`
(`ListSkills` / `GetSkills` / `CreateSkill` / `UpdateSkill`) is explicitly reachable
**outside** `list_toolsets`, and `unreal-skill/SKILL.md` documents a whole authoring
path (Python class vs UAsset). It appears in **no** executability card — the 13
domains are runtime domains and this one fell between them. SEAT-25 flagged it as
cross-cutting; nobody picked it up.

**G5 — Cross-cutting toolsets are unassigned.** `ObjectTools` (generic UObject
get/set, reused by other toolsets), `LiveCodingToolset` (`CompileLiveCoding`) and
`AssetTools` are named upstream but belong to no card. `ObjectTools` in particular is
load-bearing for the "DRY" rule the authoring guide depends on.

**G6 — The authoring guides' technical claims are unassessed.** Frontmatter was probed
(SEAT-19), but the 420-line `create-toolset/SKILL.md` body asserts an entire API
surface — `UToolsetDefinition`, `ToolsetRegistry/ToolsetDefinition.h`,
`FToolsetJsonConverter`, `@toolset_registry.tool_call`, `ToolCallTestCase`,
`assertToolRaisesRuntimeError`, `BEGIN_DEFINE_SPEC`, the Python stub path
`<project_root>/Intermediate/PythonStub/unreal.py` — and **no artifact evaluates any
of it**. Every one of those is an engine-internal reference that cannot be resolved
here; the round has no "authoring" subsystem card to put them in.

**G7 — Plugin-load → skill-availability was never closed end-to-end.** SEAT-26 got the
plugin installed and `enabled` in a real client. **No probe then exercised a loaded
skill from that plugin** — the install is proven, the *use* is not. This is the one
runtime-adjacent step that was reachable here and was left on the table.

**G8 — The hook defect has no fix and no test.** Finding 9 is a real, reproducible
malformed-JSON defect with a stated fix shape. No seat wrote the fix, and no seat
tested the C0 cases *after* a port. Any Claude→Kimi port of this hook is likely to
rewrite exactly this code (adaptation row 4 says the envelope must be re-targeted
anyway), so the defect should be re-verified post-port, not assumed fixed.

**G9 — The 5 unvendored PR-ref paths have no disposition.** SEAT-45 extracted them and
left them in `/tmp/r101-verify/unvendored/pr{1,4}/…`. No seat decided whether they
belong in the corpus, in the claim's wording, or in a rejection note. As it stands
they are an **orphan artifact on a tmpfs** — the finding is in a report, the bytes are
in `/tmp`.

**G10 — The `verified-here` label has no land-claim.** Every card's evidence is a
static availability measurement, and the census is 12 `static-only` + 1
`unproven-runtime`. **No card says what receipt would move it** in a way a future
round could act on — the cards describe their limits well but the ladder
(`static-only` → `verified-here` requires a bounded run on this host) is stated only
in the index, not per card. If the Docker route (G2) ever opens, there is no
pre-written criterion for what would count.

**G11 — No cross-round integration decision.** The connector reports that
`corpus/knowledge/engines.md`'s Unreal row still cites **only r22**, that `SCORECARD.md`
carries the coverage planned line, and that the 60-row unknowns map contains **0**
Unreal rows. Whether `engines.md` gets an Unreal-MCP row this round or next is
**explicitly deferred to the operator** by the seat. That is a legitimate deferral,
but it means the round's coverage gain is not yet visible in the lane's own census file.

**G12 — Windows behavior is unprobed by construction.** `GenerateProjectFiles.bat`,
the `.command` branch, CRLF, and control chars in names were inspected but never
executed (Linux-only host). Correctly labeled `unproven-runtime` by SEAT-18; listed
here so it is not mistaken for covered.

---

## 4. Conflicts and stale statements (deduped)

| # | Conflict | Resolution / status |
|---|---|---|
| 1 | Brief says "11 vendored paths"; upstream tracks **12** | 12 is right (F2 above); brief wording wrong. Unanimous across SEAT-14/44/53 and my own `git ls-tree`. |
| 2 | Subtree index's `executability/` table once carried an "expected verdict" column (13 × `unproven-runtime`) that disagreed with the landed census (12 `static-only` + 1 `unproven-runtime`) | **Resolved by the index itself** — the column was removed at `14:16:52` and replaced with a card-path-only table stating cards are authoritative (F26). Grep the cards, never the index. |
| 3 | `operations.md:46` "check for both connections" vs `setup.md:115` "configure one" | **Real contradiction, unresolved** (F19/D1). |
| 4 | Three peer reports call `PROVENANCE.md` + `adaptation-kimi.md` absent; two call C2 incomplete at 12/13 cards | **All stale** — both files and the 13th card landed during my run. Do not carry these into adjudication as open items. |
| 5 | C1 wording "all upstream content files" vs "the pinned commit" | Open by design; needs an adjudication call, not a code change (F31/G9). |
| 6 | `r101-reviewer-c1.md` + `r101-critic-c1.md`, and `r101-reviewer-c2.md` + `r101-critic-c2.md` | Two review seats per claim by design; not duplication, but dedup before scoring so the same evidence is not counted twice. |

---

## 5. What the L1 should do next (ranked)

1. **Commission a non-author C3 review** (G1) — the only claim with author-only evidence.
2. **Decide the Docker question** (G2): either fund the ~36-min pull to test whether
   the built editor ships the two plugins, or record it as an explicit operator-gated
   route so "no runtime evidence is possible" stops being stated as a closed fact.
3. **Fix-or-file the hook escaper** (G8/F9) with the post-port re-verification noted.
4. **Assign the orphan subsystems** (G4/G5) — Agent-Skill toolset, `ObjectTools`,
   `LiveCodingToolset` — or record why they are out of the 13-domain scope.
5. **Land or reject the 5 PR-ref paths** (G9) before `/tmp` is cleared.
6. **Tighten C1's wording** at adjudication (F31) rather than re-vendoring.

---

## 6. My own receipts

Everything below was run by this seat on this host during this synthesis. Commands
are given so a non-author can re-run them.

**6.1 Pin identity [O]**
```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**6.2 Fresh clone + full-tree diff [O]** — the strongest independent check I ran;
it does not inherit the vendoring step.
```
$ rm -rf /tmp/seat51-fresh && git clone -q https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/seat51-fresh
clone exit=0
$ git -C /tmp/seat51-fresh rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ [ "$(git -C /tmp/seat51-fresh rev-parse HEAD)" = "a6aa73ada02a9fb1f5415bec491f9942c519b297" ] && echo "PIN MATCH"
PIN MATCH
$ diff -r /tmp/seat51-fresh corpus/knowledge/unreal-mcp/upstream --exclude=.git && echo "FRESH-IDENTICAL"
FRESH-IDENTICAL
```

**6.3 Tracked-file count [O]**
```
$ git -C /tmp/ue-skills-ref ls-tree -r --name-only HEAD | wc -l
12
```

**6.4 Manifest sweep + negative control [O]**
```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
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
exit=0

# negative control on a private copy (repo file never touched)
$ cp -r corpus/knowledge/unreal-mcp /tmp/seat51neg && printf 'x' >> /tmp/seat51neg/upstream/CODEOWNERS
$ cd /tmp/seat51neg && sha256sum -c .manifest.d/audit-reference.sha256 | grep -v ': OK'
upstream/CODEOWNERS: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

**6.5 Tree shape [O]**
```
$ cd corpus/knowledge/unreal-mcp/upstream
$ find . -type f | wc -l ; cat $(find . -type f) | wc -l ; cat $(find . -type f) | wc -c ; find . -type l | wc -l
12
1022
63556
0
```

**6.6 Hook behavioral probe [O]** — 4 branches, run as the plugin invokes it.
```
fixture: proj/MyGame.uproject, cwd proj/Source/Sub
run1 (no .mcp.json) → "No `.mcp.json` is present at the project root yet. …"   exit=0
run2 (with .mcp.json) → "An `.mcp.json` is already present at the project root." exit=0
run3 (no marker anywhere) → no stdout                                        exit=0
run4 (CLAUDE_UE_HOOK_DEBUG=1) → stderr: "project root: …/proj (type=game, uproject=MyGame.uproject, mcp_json=true)"
                              stdout: clean JSON                             exit=0
$ <hook output> | jq -e . >/dev/null && echo "json valid"
json valid
```

**6.7 Static checks [O]**
```
$ shellcheck --version | head -2
ShellCheck - shell script analysis tool
version: 0.11.0
$ shellcheck hooks/unreal-context.sh ; echo "exit=$?"
exit=0
$ bash -n hooks/unreal-context.sh ; echo "exit=$?"
exit=0
$ jq -e . hooks/hooks.json >/dev/null ; echo "exit=$?"
exit=0
$ jq -e . .claude-plugin/plugin.json >/dev/null ; echo "exit=$?"
exit=0
```

**6.8 README domain count [O]**
```
$ awk 'NR>=96 && NR<=112' README.md | grep -c '^- \*\*'
13
```

**6.9 Toolset-name census [O]** — the "30+ toolsets" gap (finding 13).
```
$ grep -rhoE '\b[A-Z][A-Za-z]*(Tools|Toolset|Toolsets)\b' . | sort -u | wc -l
17      # raw; − MyToolset/UMyToolset (template placeholders) − RefreshTools (console cmd) = 14 real
$ grep -rn "^## " README.md
5:## Contents   15:## Prerequisites   21:## Platform Support   30:## Installation
60:## Verification   68:## Configuration   84:## Security   96:## What's Available
```

**6.10 Link integrity re-run [O]** — I re-ran SEAT-20's probe script myself.
```
$ python3 /tmp/r101-seat20-probe.py corpus/knowledge/unreal-mcp/upstream
"broken": [], "unresolved_anchors": [],
"totals": {"absolute_urls":1,"broken":0,"links_total":3,"md_files":6,
           "relative_resolved":2,"same_file_fragments":0,"unresolved_anchors":0}
PROBE EXIT=0
```

**6.11 Card label census [O]** — finding 24 and the index divergence in 26.
```
$ ls corpus/knowledge/unreal-mcp/executability/ | wc -l
13
$ for f in executability/*.md; do grep -m1 -oiE '`(verified-here|static-only|unproven-runtime)`' "$f"; done | sort | uniq -c
     12 `static-only`
      1 `unproven-runtime`
# per-card primary label:
#   actors-scene.md          → `unproven-runtime`
#   all other 12 cards       → `static-only`
```

**6.12 C3 artifact shape [O]**
```
$ grep -c "^| [0-9]* |" corpus/knowledge/unreal-mcp/adaptation-kimi.md
15
$ grep -n "^## " corpus/knowledge/unreal-mcp/adaptation-kimi.md
22:## 1. Adaptation table        143:## 3. Live probes …        267:## 5. Verification policy …
49:## 2. Row notes               214:## 4. NONE-FOUND searches … 303:## 6. Unproven-runtime register
317:## 7. Recommended adaptation, ranked by cost
$ grep -oE '~/[A-Za-z0-9_./-]+|/home/[A-Za-z0-9_./-]+' corpus/knowledge/unreal-mcp/adaptation-kimi.md | sort -u
~/.agents/skills/  ~/.claude/AGENTS.md  ~/.claude/CLAUDE.md  ~/.claude/commands/
~/.claude.json  ~/.claude/skills/  /home/vgpnk/.kimi-code/bin/kimi
~/.kimi-code/config.toml  ~/.kimi-code/mcp.json  ~/.kimi-code/plugins/installed.json
~/.kimi-code/skills/
```

**6.13 Hygiene [O]**
```
$ git diff --name-only
(empty)
$ stat -c '%y %n' LOG.md SCORECARD.md SHONEN.md PROVINCE.md
2026-10-16 22:41:55 LOG.md        2026-10-16 22:41:55 SCORECARD.md
2026-10-13 16:40:46 SHONEN.md     2026-10-13 16:40:46 PROVINCE.md
$ stat -c '%y %n' reports/round-101/{bpy-dissection,navagent-dissection,r101-unknowns-map}.md
2026-10-15 17:22:10 bpy-dissection.md
2026-10-15 17:45:08 navagent-dissection.md
2026-10-15 17:14:53 r101-unknowns-map.md
```

**6.14 The index was rewritten under me [O]** — the receipt behind finding 26, and
the clearest demonstration of why this round's counts must be treated as snapshots.
```
# version read at synthesis start: an "expected verdict" column, 13 × unproven-runtime
$ sed -n '/| # | card | subsystem | expected verdict |/,/^$/p' corpus/knowledge/unreal-mcp/README.md | grep -oE 'unproven-runtime|static-only' | sort | uniq -c
(unmatched — the table no longer exists)

$ sha256sum corpus/knowledge/unreal-mcp/README.md
13d497c57c9d313b7b84ac59c529ca3841d06d7749b7b86cc799c428ce32bc96  corpus/knowledge/unreal-mcp/README.md
$ stat -c '%y %s' corpus/knowledge/unreal-mcp/README.md
2026-10-18 14:16:52.334198523 -0300 15450

# the replacement table is card-path-only, and says so explicitly:
$ grep -n "expected\|unproven-runtime" corpus/knowledge/unreal-mcp/README.md | sed -n '5,9p'
238:  A card that only reads vendored text and runs a local static check is expected
239:  to be `static-only`; a card whose claims need the live editor is expected to be
240:  `unproven-runtime`. Neither the expectation nor this index overrides the card.
$ grep -oE 'unproven-runtime|static-only|verified-here' corpus/knowledge/unreal-mcp/README.md | sort | uniq -c
      5 static-only
      4 unproven-runtime
      4 verified-here
```

**Snapshot counts at `14:21-03:00` [O]** — snapshots, not facts; the tree was still
mutating (`reports/round-101/` gained 2 report files during my final poll).
`corpus/knowledge/unreal-mcp/` = 40 files (12 upstream + 12 manifests + 13 cards +
index + `PROVENANCE.md` + `adaptation-kimi.md`); `reports/round-101/probes/` = 14
probe reports; `reports/round-101/r101-*.md` = 11 seat reports.

---

## 7. Limits of this synthesis

- **I am not a verifier.** Every [D] finding is one seat's transcript, re-read by me,
  not re-run by me. The [O] receipts in §6 are the only evidence this report
  establishes itself.
- **The snapshot is frozen and already partly stale.** Two of the three "open item"
  claims I found on arrival (missing C3 files, 12/13 cards) closed mid-run; I have
  marked them stale in §4 rather than dropping them, because peer reports still carry
  them as open.
- **No live-editor claim is made or implied.** Unreal Editor is not installed on this
  host. Nothing above asserts that any tool works, that any toolset is registered, or
  that the plugin loads — those are `unproven-runtime` by construction.
- **I did not re-run the peer probes I cite**, except the markdown-link probe (§6.10),
  which I chose because it is cheap and deterministic.
