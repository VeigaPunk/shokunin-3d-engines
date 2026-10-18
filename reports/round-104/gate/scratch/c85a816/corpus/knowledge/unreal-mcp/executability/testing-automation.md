# Executability verdict card — Testing (C++ automation tests)

**Seat:** SEAT-41 EXEC · **Round:** r101 · **Lane:** game-dev-3d shokunin
**Subsystem:** Testing (discover / run / inspect C++ automation tests)
**Label:** `static-only`

Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
pinned at `a6aa73ada02a9fb1f5415bec491f9942c519b297` (plugin version `3.1.1`,
`.claude-plugin/plugin.json:3`). All paths below are the vendored, byte-identical
copies under `corpus/knowledge/unreal-mcp/upstream/` — verified this seat:

```
$ sha256sum corpus/knowledge/unreal-mcp/upstream/README.md \
            corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  .../README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  .../create-toolset/SKILL.md
$ sha256sum /tmp/ue-skills-ref/README.md   # clone at pinned SHA a6aa73ad…
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  /tmp/ue-skills-ref/README.md
```

Every pointer in this card resolves to a file in this repository, so the card
stays checkable after `/tmp` is wiped.

---

## 1. What the upstream surface actually is

The Testing surface is documented by exactly **one** of the 13 README domain
bullets (`README.md:110`) and **no** dedicated skill section — the 13 domains
are `README.md:100–112`. Grepping the whole vendored tree for the toolset's own
vocabulary:

```
$ grep -ro "AutomationTestToolset\|UnrealEditor-Cmd\|DiscoverTests\|RunTests\|ListTests\|GetTestStatus\|GetTestResults" \
    corpus/knowledge/unreal-mcp/upstream/ | sort | uniq -c | sort -rn
      2 .../skills/create-toolset/SKILL.md:UnrealEditor-Cmd
      2 .../skills/create-toolset/SKILL.md:RunTests
      2 .../skills/create-toolset/SKILL.md:DiscoverTests
      1 .../skills/create-toolset/SKILL.md:ListTests
      1 .../skills/create-toolset/SKILL.md:GetTestStatus
      1 .../skills/create-toolset/SKILL.md:GetTestResults
      1 .../skills/create-toolset/SKILL.md:AutomationTestToolset
```

Total across all 12 vendored files: **10 mentions, all in one file**
(`skills/create-toolset/SKILL.md`), plus a single catalog line in
`README.md:110`. The user-facing `skills/unreal-mcp/SKILL.md` — the file the
model actually loads for live-editor work — names the Testing toolset **nowhere**:
`grep -n "automation\|testing\|Test"` on it returns only two lines, and neither
is about Testing — line 8's generic "automation tests" list item inside a
sentence about toolset counts, and line 55's description of the unrelated
`create-toolset` skill. There is no tool name, no call sequence, no pointer to
one. `references/operations.md` and `references/setup.md` are likewise silent
(both grep to zero).

So the Testing subsystem is reachable only as a *side note inside the
toolset-authoring skill*, never as its own documented workflow.

### What is documented

The complete documented surface is one 4-step live-editor call sequence, a
`force_rediscover` iteration caveat, and a one-line headless command.

Live editor — `skills/create-toolset/SKILL.md:388–395`:

```
1. Load `AutomationTestToolset` and call `DiscoverTests`. This is required before
   any other test tool; skipping it causes empty results.
2. Call `ListTests` filtered to your toolset name to confirm the tests are discovered.
3. Call `RunTests` with the full test paths.
4. Poll `GetTestStatus`, then call `GetTestResults` for detailed per-test errors
   and warnings.
```

with the iteration caveat at `:395` — `DiscoverTests` needs
`force_rediscover=true` after a reload, or the automation system keeps the old
test set.

Test authoring — `skills/create-toolset/SKILL.md:232–251` (the `### Tests`
section): the C++ spec macro, at `:239–243`,

```cpp
BEGIN_DEFINE_SPEC(
    FMyToolsetSpec,
    "AI.MyToolset",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)
END_DEFINE_SPEC(FMyToolsetSpec)
```

and the Python counterpart at `:368–372` (`assertToolRaisesRuntimeError`, with
the package-reload rule at `:374`). The
spec's second macro argument (`"AI.MyToolset"`) is the **full test path** that
`RunTests` takes and that the `RunTests` filter matches — this is the only place
the naming contract is stated, and it is stated by example, not by rule.

### What is *not* documented (the static-only gaps)

- **No tool schema.** No `list_toolsets`/`describe_toolset` output, no
  argument types, no return shape for any of the six named tools. The
  `DiscoverTests`/`ListTests`/`RunTests`/`GetTestStatus`/`GetTestResults`
  parameter lists exist nowhere in the vendored tree.
- **No toolset plugin name.** `references/setup.md:31` says a project can enable
  "the specific toolset plugins you want instead of `AllToolsets`", but the
  Testing toolset's own plugin is never named. The `AutomationTestToolset`
  *class* is named; the plugin that registers it is not.
- **No filter grammar.** `RunTests` takes "the full test paths"
  (`:392`) and the CLI example filters on `AI.MyToolset` (`:404`), but the
  filter syntax (prefix vs glob vs regex, `+`/`-` operators, `Smoke:`/`Engine:`
  groups) is never given. The skill explicitly punts: "Check how existing tests
  in the same plugin are run to confirm the right flags and filter prefix"
  (`:407`).
- **No result schema.** "detailed per-test errors and warnings" (`:393`) —
  fields, severities and pass/fail encoding are unspecified.
- **No engine version floor.** Nothing in the vendored tree states a minimum
  Unreal version. A whole-tree sweep for any version signal returns **zero**
  hits:

  ```
  $ grep -rn -i "unreal engine 5\|ue5\|5\.[0-9]\|minimum\|requires engine\|engine version" .
  grep_exit_code=1
  hits=0
  ```

  (Exit 1 is grep's "no lines selected". The only `requires` in the tree is
  `README.md:25`'s `bash`-on-`PATH` requirement for the session hook, which the
  pattern above excludes by construction. So the card cannot say which engine
  version this plugin supports, only that no vendored line constrains it.)

---

## 2. Verdict: `static-only`

**Why not `verified-here`:** nothing in this card was observed running. The
Testing subsystem's only observable behaviour is behind a live Unreal Editor or
an `UnrealEditor-Cmd` binary, and this host has neither (see §3). No claim here
rests on an execution receipt.

**Why not `unproven-runtime`:** that label is for surfaces whose *runtime
behaviour* was attempted and could not be pinned. Here there was nothing to
attempt — the upstream text is a static document with no tool schemas, so even
a working editor would leave most of this card's content unverifiable from the
vendored bytes alone. The subsystem's contract is knowable **only** by reading
the pinned files, which is exactly what was done.

**What is solid (static, byte-pinned):** the six tool names, their call order,
the `DiscoverTests`-first precondition, the `force_rediscover` iteration rule,
the CLI invocation shape, the `BEGIN_DEFINE_SPEC` authoring pattern, and the
fact that the spec-name argument doubles as the `RunTests` path. Each is
anchored at a line number above and each file's sha256 is in
`.manifest.d/`.

**What is *not* solid:** every one of the five gaps in §1 — schemas, plugin
name, filter grammar, result shape, version floor. A consumer of this card must
not invent these. They are the concrete unlock payload (§4).

**Confidence tags:** `[O]` receipt-pinned observation from the vendored bytes;
`[I]` inference; `[?]` unknown.

| claim | tag |
|---|---|
| six tool names + call order, at `create-toolset/SKILL.md:388–395` | `[O]` |
| `DiscoverTests` required first, else empty results (`:390`) | `[O]` |
| `force_rediscover=true` needed after reload (`:395`) | `[O]` |
| `BEGIN_DEFINE_SPEC` / `EAutomationTestFlags` authoring pattern (`:242`) | `[O]` |
| spec-name arg is the `RunTests` path / CLI filter (`:392`,`:404`) | `[O]` |
| Testing toolset named nowhere in `unreal-mcp/SKILL.md`; `operations.md`/`setup.md` silent | `[O]` |
| tool argument/return schemas | `[?]` |
| Testing toolset's plugin name | `[?]` |
| `RunTests` filter grammar | `[?]` |
| result/error payload shape | `[?]` |
| minimum engine version | `[?]` |
| `AutomationTestToolset` is editor-only | `[I]` — inferred from `setup.md:31` ("`AllToolsets` is an editor-only aggregator") and from `EAutomationTestFlags::EditorContext` (`:242`); no vendored line states it for this toolset |
| the `-NullRHI -Unattended` pair actually completes a headless run | `[I]` — the flags are quoted, never demonstrated |

---

## 3. What a headless automation run WOULD require on Linux

*(Stated as requirement, not as a run — this is the `static-only` boundary.)*

The upstream gives the shape at `skills/create-toolset/SKILL.md:399–404`:

> When no editor is running, the command line launches a headless editor
> instance, runs the specified tests, and exits. It's slower due to startup time
> (~30 seconds) but requires no running editor and is useful in CI or when the
> editor isn't available.

```
UnrealEditor-Cmd.exe <Project>.uproject -ExecCmds="Automation RunTests AI.MyToolset;quit" -Unattended -NullRHI
```

Four things that line implies for this host, none of them free:

1. **An engine binary.** The example says `UnrealEditor-Cmd.exe`; on Linux the
   binary is `UnrealEditor-Cmd` (no extension) under `Engine/Binaries/Linux/`.
   This host has neither:

   ```
   $ which UnrealEditor-Cmd UnrealEditor UE4Editor
   which: no UnrealEditor-Cmd in (...PATH elided...)
   which: no UnrealEditor in (...PATH elided...)
   which: no UE4Editor in (...PATH elided...)
   ```

   (Only the `PATH` list inside the parentheses is elided; the verdicts are
   verbatim. Also checked: no `/opt/UnrealEngine`, no `~/UnrealEngine`, no
   `/usr/share/unreal-engine`.)

   The default route is a source build from
   `git@github.com:EpicGames/UnrealEngine` — the AUR `unreal-engine` PKGBUILD
   (`pkgver=5.8.2`, fetched to `/tmp/ue-pkgbuild`, 527 lines) gates on exactly
   that repo over SSH:

   ```
   $ grep -n "git ls-remote\|git clone" /tmp/ue-pkgbuild
   280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
   327:    git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine "${pkgname}"
   336:      git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine "${pkgname}"
   ```

   and that repo is not reachable from this account:

   ```
   $ git ls-remote https://github.com/EpicGames/UnrealEngine.git HEAD
   remote: Repository not found.
   fatal: repository 'https://github.com/EpicGames/UnrealEngine.git/' not found
   $ gh auth status
   github.com
     ✓ Logged in to github.com account VeigaPunk (keyring)
     - Active account: true
     - Git operations protocol: https
     - Token: gho_************************************
   ```

   (`gh` is authenticated as `VeigaPunk`, not as an Epic-linked account; the
   "Repository not found" is GitHub's answer for a private repo the caller
   cannot see, so it does not distinguish "not linked" from "not invited".)

   So step one is an **operator action**: link the Epic account to GitHub and
   accept the Unreal Engine EULA. Nothing on this host can substitute for it.

2. **The project must have the tests.** `RunTests` needs a filter matching a
   real spec; the example filters `AI.MyToolset`, i.e. a toolset spec compiled
   into the project. A bare `.uproject` has no such spec, so a smoke run needs
   either an existing plugin with specs or a new spec built per §1's
   `BEGIN_DEFINE_SPEC` pattern. Engine-provided specs (`Engine:`,
   `Smoke:` groups) exist inside a source build and are the cheapest first
   target — but their exact filter prefixes are `[?]` here, and the skill
   itself defers to "how existing tests in the same plugin are run" (`:407`).

3. **Headless viability.** `-NullRHI` is the load-bearing flag, and its
   semantics here are **`[I]`**, not vendored: the upstream only *quotes* the
   command and never explains a flag. `[I]` NullRHI drops the RHI so the run
   needs no GPU/display; `[I]` `-Unattended` suppresses dialogs; `[I]` the
   `;quit` in `-ExecCmds` is what makes the process exit rather than idle.
   Whatever the exact semantics, `-NullRHI` is the class of flag this lane has
   **no receipt for**: whether a given spec passes under a null RHI (any test
   touching rendering, Slate, or PIE behaviour) is `[?]`, and the upstream's
   own example spec uses `EAutomationTestFlags::EditorContext` (`:242`), the
   context most at risk from a null RHI. Expect a split between specs that run
   headlessly and specs that do not; the upstream does not help with the split.

4. **Startup cost and CI shape.** The upstream measures ~30 s of startup
   (`:399`) before any test executes. On this host a source build of UE 5.8.2
   is itself the dominant cost — tens of minutes to hours of compile across 32
   cores, plus tens of GB of disk (780 G free on `/`, so disk is not the
   blocker; the SSH-gated clone is).

The honest Linux summary: **the headless path is documented and plausibly
works, but every precondition for it is currently unmet on this host, and the
one hard blocker (Epic account linkage → engine source) is operator-owned, not
lane-owned.** Even fully unblocked, only the CLI path in `:399–404` becomes
measurable; the six-tool MCP path in `:388–395` additionally needs a live
editor and the MCP plugin, which is the *other* card's problem.

`docker` is present (`/usr/bin/docker`, client 29.7.2) and `lutris` is available
in `extra` (`extra/lutris 0.5.22-3`). Neither is a route to this card's
`verified-here`: no public Unreal Linux container is named anywhere in the
vendored tree, and Lutris's Epic route is an operator-owned login. Lutris would
install an *installed/launcher* build — which `references/setup.md:66` does
contemplate as a supported build kind — so a launcher build is **not** ruled out
as a future unlock; it is simply `[?]` whether such a build ships the
`ToolsetRegistry`/`AllToolsets` plugins this repo depends on
(`references/setup.md:6,14`, `README.md:76`). That check is cheap once any
`UnrealEditor-Cmd` exists and belongs in the unlock sequence, not in this
verdict.

---

## 4. Unlock condition

**Primary (operator-owned, hard):** an Epic-linked GitHub account with the
Unreal Engine EULA accepted, so `git@github.com:EpicGames/UnrealEngine` clones.
Then, in order:

1. Build the engine (AUR `unreal-engine` 5.8.2-1 or a manual source build);
   confirm `Engine/Binaries/Linux/UnrealEditor-Cmd` exists and
   `UnrealEditor-Cmd --version` reports an engine version. **Cheaper
   alternative worth trying first:** an installed/launcher build
   (`references/setup.md:66`) also provides `UnrealEditor-Cmd`; if one is
   reachable (Lutris/Epic route, operator login), check whether it ships
   `Engine/Plugins/Experimental/ToolsetRegistry` (`README.md:76`,
   `skills/unreal-skill/SKILL.md:85`) before committing to a multi-hour source
   build. Whether it does is `[?]` — this check is minutes, the source build is
   hours.
2. Make a project with the `ModelContextProtocol` + `AllToolsets` plugins
   enabled (`references/setup.md:6,14`) and at least one compiled spec
   following `BEGIN_DEFINE_SPEC` (`skills/create-toolset/SKILL.md:242`).
3. Run the documented CLI verbatim and capture exit code, stdout and the log:

   ```
   UnrealEditor-Cmd <Project>.uproject \
     -ExecCmds="Automation RunTests <Spec>;quit" -Unattended -NullRHI
   ```

   The receipt to record is: did the process exit on its own, did the automation
   controller emit a pass/fail summary, and what exit code mapped to
   pass vs fail. **A pass/fail exit-code contract is the single most valuable
   unknown to close** — it is the one thing the vendored bytes cannot supply and
   the one thing every future fixture would key on.

4. Then, and only then, resolve the five `[?]` gaps in §1 by calling
   `describe_toolset` against a live editor: this is the only route to the
   `DiscoverTests`/`ListTests`/`RunTests`/`GetTestStatus`/`GetTestResults`
   schemas, the toolset plugin name, and the filter grammar.

**Secondary (lane-owned, cheap, do first if the engine lands):** re-grep the
vendored tree at a *newer* upstream SHA. This card describes plugin `3.1.1`; the
Testing surface is one skill section away from being much better documented, and
re-vendoring is minutes of work versus hours of compile. Check whether
`skills/unreal-mcp/SKILL.md` has grown a Testing section before committing to a
source build.

**Label migration:** this card moves `static-only` → `unproven-runtime` the
moment an `UnrealEditor-Cmd` binary exists on the host (the attempt becomes
possible, the receipt still absent), and → `verified-here` only when step 3's
exit-code contract is captured with a command and its observed output.

**Explicitly out of scope for this card:** the MCP six-tool flow
(`:388–395`) stays `unproven-runtime` regardless, because it needs a live editor
with the proxy plugin — a different subsystem's unlock.

---

## 5. Consumer notes

- Do **not** cite `AutomationTestToolset` as a *verified* MCP toolset. It is
  named once, in a skill about authoring toolsets, as an example of an existing
  toolset to load. That is a weaker claim than "the Testing toolset is
  registered and callable", and this card does not make the stronger claim.
- Do **not** treat `UnrealEditor-Cmd.exe` as the Linux binary name. The
  upstream example is Windows-shaped; the Linux binary drops `.exe`. This is an
  `[I]` from Unreal convention, not a vendored line — flagged because a
  copy-pasted command will fail on this host for that reason alone.
- The `-ExecCmds="Automation RunTests …;quit"` string uses **Unreal console
  syntax**, not shell syntax: the `;` separates console commands and must stay
  inside the quoted argument. This is `[I]` (the vendored text shows the quoting
  but never explains it); flagged because getting it wrong yields a process that
  runs tests and then never exits.
