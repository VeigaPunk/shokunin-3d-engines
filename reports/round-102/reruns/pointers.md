# r102 SEAT-37 — POINTERSWEEP-RERUN

**Seat:** SEAT-37 `POINTERSWEEP-RERUN` → `reports/round-102/reruns/pointers.md`
**Date:** 2026-10-18 · **Round base:** HEAD `2c99b7b` (work commit `1659c036`)
**Scope:** re-run the r101 pointer sweep over the byte-pinned subtree `corpus/knowledge/unreal-mcp`, with
my own script, and paste the `UNRESOLVED` count.
**Feeds:** C1 (coverage) — an independent re-derivation of the r101 pointer-sweep check, not an
independent confirmation of it (see §4.2: the check's result is checker-dependent).

---

## 1. Headline

```
$ bash reports/round-102/reruns/pointer-sweep.sh
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
exit=0
```

**UNRESOLVED = 0.** `STEP=PASS`, exit 0. The subtree carries no broken, unresolvable pointer under
the `upstream/<path>:<line>` convention, on the working tree and on the pristine `HEAD` tree alike
(§5). The gate's C3/G6 assertion holds on an independent re-derivation.

Two findings qualify that headline and are worth the reader's time up front:

- **§4.1** — `UNRESOLVED=0` does not mean every pointer cites the right line. Dereferencing all 43
  distinct endpoints found one off-by-one (`adaptation-kimi.md` row 5 cites `unreal-context.sh:47`;
  the site is `:46`). It resolves, so the sweep cannot see it.
- **§4.2** — the r101 protocol's checker exists in two variants (one with the sentinel filter, one
  without). Both reproduce r101's published `POINTERS=40` on the r101 tree, but on today's tree they
  read `UNRESOLVED=1` and `UNRESOLVED=3` against the new gate README — all false positives from
  control strings quoted in its prose.

**Note — the gate's own README is now on the tree.** The C1 seat created
`corpus/knowledge/unreal-mcp/gate/{README.md,run_gate.sh}` after my first run. The gate README carries
the protocol's control sentinels (2 sentinel occurrences found by `grep -cE`), so my exclusion branch
fires on it and **prints** the skip:

```
$ bash reports/round-102/reruns/pointer-sweep.sh
GATE-SENTINEL-SKIP corpus/knowledge/unreal-mcp/gate/README.md
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
exit=0
```

Same 47 / `UNRESOLVED=0`. So the sentinel exclusion is exercised on the real tree, not only in the
controls of §6 — and because it is printed, it cannot hide a failure.

**Caveat — the sweep is *not* byte-pinned.** All **16 of 16** scanned files are **untracked by
`.manifest.d/`**: the manifests pin 12 entries and every one of the 12 is `upstream/**`
(`grep -v '^upstream/'` over the concatenated manifests returns nothing). `adaptation-kimi.md` alone
carries 18 of the 41 distinct pointer strings (24 of the 47 endpoints). Those files are still covered
by the `HEAD`-tree run in §5, which is why the result is not contaminated by the in-flight peer edits
visible in `git status` — but the sweep is a working-tree sweep over unpinned files, and only the
`upstream/` targets it resolves against are byte-pinned.

**One mis-targeting pointer found — see §4.1.** `UNRESOLVED=0` is necessary but not sufficient: a
pointer can resolve to an existing file at an in-range line and still cite the *wrong* line. The
exhaustive endpoint dereference caught exactly one such case.

---

## 2. Script

`reports/round-102/reruns/pointer-sweep.sh` (written this seat; executable). Full text:

```sh
#!/usr/bin/env bash
# SEAT-37 / r102 — subtree pointer sweep, re-run.
# Pointers are written `upstream/<path>:<line>` (also `:a-b` ranges and `:a,b` lists);
# they resolve against corpus/knowledge/unreal-mcp.
#
# Exclusions, all deliberate and all PRINTED so they cannot hide a real failure:
#   * anything under upstream/ — the vendored upstream text is not this round's artifact;
#   * a gate file that carries the protocol's control sentinels (exact-match only, so a real
#     pointer on a line that merely mentions "control" is still counted) — counted as
#     SKIPPED_CONTROL_SENTINELS.
# Range/comma forms are resolved at every listed endpoint (a-b checks a and b; a,b checks both).
# shellcheck disable=SC2015,SC2086  # A&&B||C intended (B exits); $roots is a deliberate space-split list
set -u
roots=${*:-"corpus/knowledge/unreal-mcp"}
base=${BASE:-corpus/knowledge/unreal-mcp}
sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
ptr_re='upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+([,-][0-9]+)*'
total=0; bad=0; skipped=0; files=0
for root in $roots; do
  while IFS= read -r f; do
    case "$f" in */upstream/*) continue;; esac
    if [ "$(basename "$f")" = README.md ] && printf '%s' "$f" | grep -q '/gate/'; then
      if grep -qE "$sentinel" "$f"; then
        printf 'GATE-SENTINEL-SKIP %s\n' "$f"; continue
      fi
    fi
    files=$((files+1))
    while IFS= read -r ptr; do
      if printf '%s' "$ptr" | grep -qE "^($sentinel)$"; then skipped=$((skipped+1)); continue; fi
      p=${ptr%%:*}; rest=${ptr#*:}
      for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
        total=$((total+1))
        if [ ! -f "$base/$p" ]; then printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; bad=$((bad+1)); continue; fi
        n=$(wc -l < "$base/$p")
        [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; bad=$((bad+1)); }
      done
    done < <(grep -ohE "$ptr_re" "$f" | sort -u)
  done < <(find $root -name '*.md' -type f | sort)
done
printf 'FILES_SCANNED=%s POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$files" "$total" "$skipped" "$bad"
[ "$bad" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
```

Two changes over the r101 protocol checker (`reports/round-101/r101-verification-protocol.md:102-140`):

1. **Range/comma endpoints are resolved.** The r101 `ptr_re` stops at the first `[0-9]+`, so
   `upstream/README.md:50-57` was counted as the single endpoint `:50` and `:57` was never checked;
   the same for the second element of `:a,b` lists. My `ptr_re` captures the full suffix
   (`[0-9]+([,-][0-9]+)*`) and splits it with `tr ',-' '  '`.
2. **`BASE` is overridable**, so the same script can sweep a pristine `HEAD` extraction (§5)
   independently of in-flight peer edits.

The sentinel set is unchanged and still an **exact-match** filter, not a keyword filter — a real
pointer on a line that merely contains the word "control" is still counted.

---

## 3. Main run

```
$ bash reports/round-102/reruns/pointer-sweep.sh
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
exit=0
```

Files scanned — the 16 non-`upstream/`, non-`gate/` `.md` files in the subtree:

```
adaptation-kimi.md · PROVENANCE.md · README.md
executability/{actors-scene, animation-controlrig, assets-content, blueprints, editor-general,
  gameplay-gas, materials, meshes-textures, scripting-programmatic, sequencer,
  testing-automation, ui-umg-slate, vfx-niagara-dataflow}.md
```

`gate/README.md` is on the tree as of this run and is skipped by the sentinel branch — see §1.

### 3.1 Pointer count: 47, not 40 — why

My count is **47**; the r101 closeout and report both recorded `POINTERS=40 UNRESOLVED=0` for the same
subtree (`reports/round-101/r101-report.md:56,146,188`). Both r101 checker variants reproduce that 40
**on the pristine r101 tree**, i.e. on a `HEAD` extraction with no `gate/` directory (§4.2):

```
$ cd /tmp/seat37 && bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
POINTERS=40 UNRESOLVED=0
STEP=PASS
exit=0
```

(The same command on today's working tree reads `POINTERS=43 UNRESOLVED=3`: 40 from the subtree plus
the gate README's three control strings. Those are not subtree pointers — see §4.2.)

The delta has two independent causes, both verified by re-deriving the numbers three ways:

**(a) Endpoint expansion (+6).** The r101 `ptr_re` stops at the first `[0-9]+`, so a multi-endpoint
string is counted once. Five such forms exist; each contributes its extra endpoints only in my run:

```
upstream/hooks/hooks.json:4-5                           → 1 counted by r101, 2 by me  (+1)
upstream/hooks/unreal-context.sh:5,8                    → 1 → 2                       (+1)
upstream/README.md:39,45                                → 1 → 2                       (+1)
upstream/README.md:50-57                                → 1 → 2                       (+1)
upstream/skills/unreal-mcp/references/setup.md:61,70-79 → 1 → 3                       (+2)
```

**(b) One extra distinct string (+1).** The last form above truncates to exactly `setup.md:61`, which
**collides** with the bare `setup.md:61` cited separately in the same file — the r101 regex silently
merges two distinct citations into one string. Per-file-distinct counts under the two regexes:

```
r101-style regex  (upstream/...:[0-9]+)                      40
my regex          (upstream/...:[0-9]+([,-][0-9]+)*)         41
```

So: `40 + 1 + 6 = 47`. Both numbers are honest; they measure different things (strings vs. endpoints),
and the r101 figure under-counts the checkable surface by 7.

Reconciliation of the three counts, all from the same tree:

| measure | command shape | value |
|---|---|---:|
| per-file distinct strings, my regex | `grep -ohE … \| sort -u`, summed per file | **41** |
| per-file endpoints = `POINTERS` | same, then split on `,-` | **47** |
| globally-unique strings | `grep -rohE … --exclude-dir=upstream \| sort -u` | **38** |
| globally-unique endpoints | same, then split on `,-` | **44** |
| r101-regex per-file distinct | `grep -ohE 'upstream/…:[0-9]+' \| sort -u` | **40** |

`41 → 47` is endpoint expansion (+6); `41 → 38` is 3 pointer strings cited in more than one file
(`upstream/.claude-plugin/plugin.json:4`, `upstream/README.md:3`,
`upstream/skills/unreal-mcp/SKILL.md:3`), which `sort -u` applies per file and so counts twice.

The five multi-endpoint forms (all five resolve inside their files):

```
upstream/hooks/hooks.json:4-5                          (hooks.json = 17 lines)
upstream/hooks/unreal-context.sh:5,8                   (unreal-context.sh = 84 lines)
upstream/README.md:39,45                               (README.md = 112 lines)
upstream/README.md:50-57
upstream/skills/unreal-mcp/references/setup.md:61,70-79 (setup.md = 133 lines)
```

Max-line reference for every `upstream/` target touched by the subtree:

```
112 upstream/README.md          17 upstream/hooks/hooks.json
133 upstream/skills/unreal-mcp/references/setup.md      84 upstream/hooks/unreal-context.sh
 51 upstream/skills/unreal-mcp/references/operations.md 420 upstream/skills/create-toolset/SKILL.md
```

No `LINE-OOR` and no `MISSING-PATH` line was emitted in any run.

---

## 4. Full endpoint dereference (C3's "pointers resolve to the *right* line", not just *a* line)

`UNRESOLVED=0` only proves *path exists, line ≤ file length*. It does **not** prove a pointer cites
the line it claims to. So rather than sample, I dereferenced **every distinct endpoint** with
`sed -n "${line}p"` from `corpus/knowledge/unreal-mcp/upstream/`. The sweep counts 47 endpoint
occurrences; 3 strings are cited in more than one file, leaving **43 distinct `(path, line)` pairs**.
All 43 are below, so every endpoint the sweep counts is dereferenced at least once:

```
.claude-plugin/plugin.json            1  | {
.claude-plugin/plugin.json            4  |   "description": "Control Unreal Editor directly from Claude Code via MCP. …
hooks/hooks.json                      4  |     "SessionStart": [
hooks/hooks.json                      5  |       {
hooks/hooks.json                      6  |         "matcher": "startup|resume|clear",
hooks/hooks.json                      10 |             "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh",
hooks/unreal-context.sh               5  | # Opt-in debug logging: set CLAUDE_UE_HOOK_DEBUG to any non-empty value.
hooks/unreal-context.sh               8  |   if [ -n "$CLAUDE_UE_HOOK_DEBUG" ]; then
hooks/unreal-context.sh               47 | fi                                       <-- MIS-TARGETED, see §4.1
hooks/unreal-context.sh               72 | context="$context Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT ref…
hooks/unreal-context.sh               84 | printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}…
README.md                             3  | Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via U…
README.md                             13 | - **SessionStart** (`hooks/unreal-context.sh`) - injects a short note identifying the re…
README.md                             39 | /plugin install unreal-engine-skills-for-claude-code@claude-plugins-official
README.md                             45 | /plugin marketplace add anthropics/claude-plugins-official
README.md                             50 | Commit this to `.claude/settings.json` in the project that should use the plugin. Anyone
README.md                             57 | }
README.md                             64 | 3. In Claude Code, run `/plugin`. The **Installed** tab should list `unreal-engine-skill…
README.md                             65 | 4. Run `/mcp`. Check for `unreal-mcp`, or `unreal-mcp-proxy` if you installed the proxy.
README.md                             72 | > **Note:** This plugin does not ship a static `.mcp.json` file. Run `ModelContextProtoc…
README.md                             92 | **`--dangerously-skip-permissions` removes the per-tool approval gate.** In that mode Cl…
README.md                             102| - **Assets and Content** - find, load, save, move, duplicate assets; edit Data Tables, C…
README.md                             106| - **Sequencer** - create and edit Level Sequences, keyframe animation, manage cameras, C…
README.md                             107| - **VFX** - author Niagara systems and Dataflow graphs
README.md                             108| - **UI** - build UMG widget blueprints, automate Slate UI interaction
skills/create-toolset/SKILL.md        28 | **2. Is the request more general than it sounds?** Users often ask for something domain-…
skills/create-toolset/SKILL.md        45 | - **Don't duplicate existing tools.** For example, `ObjectTools` already handles generic…
skills/create-toolset/SKILL.md        413| - **Duplicated boilerplate.** Similar patterns repeated across tools that could share a …
skills/create-toolset/SKILL.md        415| - **Duplicate functionality.** A tool that does something another tool in this toolset o…
skills/unreal-mcp/SKILL.md            3  | description: "Use this skill to perform actions inside an Unreal Engine project via a li…
skills/unreal-mcp/SKILL.md            8  | You are wired into a live Unreal Editor through the `unreal-mcp` MCP server. The server …
skills/unreal-mcp/SKILL.md            16 | Tool search is on by default, so the MCP server advertises only three meta-tools for the…
skills/unreal-mcp/SKILL.md            20 | 1. Call `list_toolsets` to see what's registered, then `describe_toolset` on the candida…
skills/unreal-mcp/SKILL.md            30 | - **Save first, then save again.** Tell the user to save the project (or call `AssetTool…
skills/unreal-mcp/SKILL.md            33 | - **Always check the result.** Blueprint compilation, widget creation, material edits: m…
skills/unreal-mcp/references/operations.md  14 | | `ModelContextProtocol.GenerateClientConfig <client>` | Regenerate the per-client confi…
skills/unreal-mcp/references/operations.md  34 | - `unreal_mcp_status` reports whether the proxy holds an initialized upstream session. I…
skills/unreal-mcp/references/setup.md 31 | `AllToolsets` is an editor-only aggregator with `EnabledByDefault` off, so it must be en…
skills/unreal-mcp/references/setup.md 61 | **From a running editor (preferred):** run `ModelContextProtocol.GenerateClientConfig Cl…
skills/unreal-mcp/references/setup.md 70 | ```json
skills/unreal-mcp/references/setup.md 79 | ```
skills/unreal-mcp/references/setup.md 129 | - `/mcp` in Claude Code lists `unreal-mcp`, or `unreal-mcp-proxy` when installed, as con…
skills/unreal-skill/SKILL.md          3  | description: "Use this skill when creating, editing, or reviewing an Unreal Engine Agent…
```

**42 of 43 distinct endpoints land on content that matches the citing claim.** The single exception is
`hooks/unreal-context.sh:47` (§4.1). Note the contrast with the r101 closeout, which reported a
*ten-pointer* hand sample (`reports/round-101/r101-report.md:150`): that sample did not include
`unreal-context.sh:47`, which is why the r101 sweep read `UNRESOLVED=0` with no mis-targeting noted.

### 4.1 DEFECT — `adaptation-kimi.md` row 5 cites `unreal-context.sh:47`, site is `:46`

`corpus/knowledge/unreal-mcp/adaptation-kimi.md:38` (row 5) reads:

```
| 5 | Hook exit code semantics | same 0 = allow, 2 = block; other non-zero = fail-open allow | static-only | `upstream/hooks/unreal-context.sh:47` → docs `customization/hooks.html` §Return Values |
```

Observed at `:47`:

```
$ sed -n '47p' corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
fi
```

The exit-code site the row is about is one line earlier:

```
$ nl -ba corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh | sed -n '43,47p'
    43  project_root="$(find_project_root "$PWD")"
    44  if [ -z "$project_root" ]; then
    45    debug "no Unreal Engine project marker found walking up from $PWD"
    46    exit 0
    47  fi
```

`:46` is the only `exit` in the file (`grep -nE 'exit [0-9]'` → `46:  exit 0`), and it is the site
demonstrating the "0 = allow" half of the row's claim.

**Why this is a defect and not a preference.** The pointer resolves, so the mechanical sweep cannot see
it — the file exists and 47 ≤ 84. But a reader following it lands on a `fi` and learns nothing about
exit-code semantics, while the cited claim ("same 0 = allow") is exactly what `:46` demonstrates. It
is an off-by-one, not a disagreement about what the row means.

**Correction-note discipline.** The subtree is byte-pinned, so this seat does **not** silently rewrite
`adaptation-kimi.md`. Recorded here, dated, for the seat that owns the wording fix:

> **Correction note — 2026-10-18 (r102 SEAT-37).** `adaptation-kimi.md` row 5 cites
> `upstream/hooks/unreal-context.sh:47` for hook exit-code semantics. The site is `:46` (`exit 0`);
> `:47` is the closing `fi`. The cited claim is otherwise correct and unchanged. Fix is a one-character
> edit to the row's pointer, owned by whoever holds `adaptation-kimi.md`.

**Impact on this seat's headline:** none. `UNRESOLVED=0` is a statement about resolvability and stands
as reported. The finding narrows what that number *buys* — resolvability, not correct targeting — and
is the reason the hand check in §4 was widened from a sample to all distinct endpoints.

### 4.2 The r101 protocol ships two checker variants; the new gate file makes them disagree

The protocol's **source text** (`reports/round-101/r101-verification-protocol.md:102-140`) defines a
`sentinel` variable and an exact-match skip. The **as-built script** the r101 closeout actually ran
(`/tmp/r101-closeout/pointer-check.sh`, 26 lines) has **no sentinel filter at all** — no `sentinel`
variable, no `skipped` counter, no `SKIPPED_CONTROL_SENTINELS` in its output line. On the r101 tree
this made no difference; on today's tree it does. Compare:

```
$ awk '/^cat > "\$WORK\/pointer-check.sh"/{f=1;next} f&&/^EOF$/{exit} f' \
    reports/round-101/r101-verification-protocol.md > /tmp/seat37/proto-pointer-check.sh
$ grep -c sentinel /tmp/r101-closeout/pointer-check.sh        # as-built
0
$ grep -c sentinel /tmp/seat37/proto-pointer-check.sh          # protocol source
3
```

The as-built script has **zero** occurrences of the word `sentinel`; the protocol source has three
(a comment, the variable assignment, and the skip test).

**On the pristine r101 subtree the two variants agree** — the divergence is not an r101 bug:

```
$ cd /tmp/seat37 && bash /tmp/seat37/proto-pointer-check.sh corpus/knowledge/unreal-mcp
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
rc=0

$ cd /tmp/seat37 && bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
POINTERS=40 UNRESOLVED=0
STEP=PASS
rc=0
```

Both read exactly the `POINTERS=40 UNRESOLVED=0` r101 published. r101's number is fully reproducible
from its own protocol source; no gap there. The two scripts differ only in behaviour on control
strings, and at r101 time no scanned file outside the protocol's own self-exclusion carried any.

Run both against today's subtree, where the new `gate/README.md` does:

```
$ bash /tmp/seat37/proto-pointer-check.sh corpus/knowledge/unreal-mcp     # protocol source
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
POINTERS=41 SKIPPED_CONTROL_SENTINELS=2 UNRESOLVED=1
STEP=FAIL
exit=1

$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp     # as-built
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:500 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:9999 (max 112)
POINTERS=43 UNRESOLVED=3
STEP=FAIL
exit=1
```

Three distinct verdicts on the same tree (`1` / `3` / my `0`), all traceable to the gate README the C1
seat added *after* r101 closed. Every one of those hits is a **false positive against a documentation
file**, not a broken pointer:

- `gate/README.md:99-100` quotes the sentinels `upstream/README.md:9999` and `:500` in prose — skipped
  by the protocol variant (that is what `SKIPPED_CONTROL_SENTINELS=2` is), counted by the as-built one.
- `gate/README.md:147,168` document the gate's **own** negative control C3, which plants
  `upstream/README.md:200`. That string is *not* in the r101 sentinel set, so both variants count it
  and read `LINE-OOR … (max 112)`. The gate's own README states C3 expects `UNRESOLVED=1` — the
  planted string is a control, and reading it as a real defect inverts its meaning.

My script avoids all three by skipping any `gate/README.md` that carries sentinels, and **printing**
the skip (`GATE-SENTINEL-SKIP …`), so the exclusion is visible rather than silent. That is the design
decision the r101 protocol intended; the as-built script dropped it, which did not matter until now.

**Actionable consequence, stated plainly:** the r101 sweep is *not* re-runnable as-is against the
current tree. Running the round's own protocol against the subtree now reads `UNRESOLVED=1` or `=3` —
both false positives. Whoever owns the gate's C3 wording should either add
`upstream/README.md:200` to the sentinel set or exempt `gate/README.md`, otherwise the r102 gate will
report a red pointer check on its own documentation. Flagged for the gate owner; outside this seat's
write scope.

---

## 5. Working tree vs pristine `HEAD` (in-flight peer edits)

`git status --porcelain` on this base shows peer seats editing files outside my scope (snapshot at my
first run; the set grew as peers landed work — by my last check it also included
`corpus/knowledge/engines.md` and `corpus/knowledge/rea.md`, both other seats' files):

```
 M corpus/artifacts/unreal-r22/README.md
 M corpus/knowledge/unreal-mcp/README.md      <- inside my scope
 M corpus/lessons/r22-unreal-review.md
```

None of those edits can move my count: the only file among them inside the swept subtree is
`unreal-mcp/README.md`, and it has **zero** pointers. Verified by extracting the subtree at `HEAD` and
re-running, so the result is a property of the committed artifact and not of a half-finished edit:

```
$ git archive HEAD corpus/knowledge/unreal-mcp | tar -x -C /tmp/seat37
$ BASE=/tmp/seat37/corpus/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37/corpus/knowledge/unreal-mcp
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
exit=0
```

Identical. `corpus/knowledge/unreal-mcp/README.md` has **zero** pointers, so the peer's in-flight edit
to it cannot move the count either way — confirmed by the equality of the two runs.

This is the load-bearing property: **`UNRESOLVED=0` holds on the pinned, committed bytes**, not merely
on a tree that happens to have peers' uncommitted work in it.

### 5.1 Pinned subtree integrity (the sweep's ground truth)

Pointers are only meaningful if the files they resolve against are the pinned bytes. Re-verified:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c /tmp/seat37/manifest.txt   # concatenation of .manifest.d/*
… 12/12 entries: OK
rc=0
```

All 12 manifest entries pass, and all 12 are `upstream/**`; the manifests carry no non-`upstream`
entries (`grep -v '^[0-9a-f]*  upstream/'` returns only `#` comment lines). Pin: `a6aa73ad…` per the
manifest header.

---

## 6. Negative controls (the sweep can fail)

A green sweep is worthless unless the checker is demonstrably able to go red. Four controls, each on a
copy of the pristine extraction:

**N1 — sentinel strings are skipped, a neighbouring real pointer is not.** `NEGCTL.md` containing the
three protocol sentinels plus `upstream/README.md:1`:

```
$ BASE=/tmp/seat37neg/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37neg/knowledge/unreal-mcp
FILES_SCANNED=17 POINTERS=48 SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=0
STEP=PASS
exit=0
```

`SKIPPED_CONTROL_SENTINELS=3` — exactly the three planted sentinels, no more. The real
`upstream/README.md:1` on the next line was **still counted** (48 = 47 + 1), proving the filter is
exact-match and not keyword- or file-scoped.

**N2 — genuinely broken pointers are caught (3 ways).**

```
$ BASE=/tmp/seat37neg2/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37neg2/knowledge/unreal-mcp
MISSING-PATH /tmp/seat37neg2/knowledge/unreal-mcp/NEGCTL.md :: upstream/does/not/exist.md:1
LINE-OOR /tmp/seat37neg2/knowledge/unreal-mcp/NEGCTL.md :: upstream/README.md:10-99999 (max 112)
LINE-OOR /tmp/seat37neg2/knowledge/unreal-mcp/NEGCTL.md :: upstream/README.md:99999 (max 112)
FILES_SCANNED=17 POINTERS=51 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=3
STEP=FAIL
exit=1
```

Detects a missing path, an out-of-range single line, **and** a bad *range endpoint* — the last one
being precisely what the r101 regex could not see.

**N3 — a `gate/README.md` that carries the sentinels is skipped and *printed*.**

```
$ BASE=/tmp/seat37neg3/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37neg3/knowledge/unreal-mcp
GATE-SENTINEL-SKIP /tmp/seat37neg3/knowledge/unreal-mcp/gate/README.md
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
exit=0
```

**N4 — a `gate/README.md` *without* sentinels is scanned, not skipped** (so the exclusion cannot be
used as a hiding place):

```
$ BASE=/tmp/seat37neg4/knowledge/unreal-mcp bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37neg4/knowledge/unreal-mcp
MISSING-PATH /tmp/seat37neg4/knowledge/unreal-mcp/gate/README.md :: upstream/gone.md:3
FILES_SCANNED=17 POINTERS=50 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
exit=1
```

The planted broken pointer in the gate file was caught. **N3 + N4 together** prove the gate exclusion
is conditional on the sentinel strings and is printed either way, so it can neither hide a real
failure nor silently swallow the gate's own file.

---

## 7. Secondary finding (not a pointer; no count impact)

Two files in the subtree use a **`.../`-shorthand** for upstream paths that the `upstream/<path>:<line>`
grammar does not match, so the sweep does not audit them:

- `executability/testing-automation.md:15-16` — `.../README.md`, `.../create-toolset/SKILL.md`
- `executability/testing-automation.md:36-42` — `.../skills/create-toolset/SKILL.md:<symbol>`
- `executability/scripting-programmatic.md:202` — `.../PKGBUILD?h=unreal-engine` (an AUR URL, not a
  corpus pointer — correctly out of scope)

The two corpus-relevant shorthands **do resolve**, verified by hash rather than by path grammar:

```
$ cd corpus/knowledge/unreal-mcp/upstream && sha256sum README.md skills/create-toolset/SKILL.md
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md
```

These are byte-identical to the `:15`/`:16` cited hashes in that file. **No defect; no repair made.**
Recorded because it is a genuine blind spot in the sweep's coverage claim: a future `.../`-form
pointer *could* go stale without the sweep noticing. Worth folding into the gate's C3 wording if the
gate owner wants it — outside this seat's write scope.

---

## 8. Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash reports/round-102/reruns/pointer-sweep.sh                 # 47 / UNRESOLVED=0 / exit 0
git archive HEAD corpus/knowledge/unreal-mcp | tar -x -C /tmp/seat37
BASE=/tmp/seat37/corpus/knowledge/unreal-mcp \
  bash reports/round-102/reruns/pointer-sweep.sh /tmp/seat37/corpus/knowledge/unreal-mcp
# §4.2 — the two r101 checker variants, for comparison:
awk '/^cat > "\$WORK\/pointer-check.sh"/{f=1;next} f&&/^EOF$/{exit} f' \
  reports/round-101/r101-verification-protocol.md > /tmp/seat37/proto-pointer-check.sh
bash /tmp/seat37/proto-pointer-check.sh corpus/knowledge/unreal-mcp   # 41 / UNRESOLVED=1
bash /tmp/r101-closeout/pointer-check.sh  corpus/knowledge/unreal-mcp # 43 / UNRESOLVED=3
```

## 9. Limits

- **No Unreal runtime claim.** The editor is not installed; this seat makes no statement about live
  MCP behaviour, and the sweep is a static document check only.
- `UNRESOLVED=0` asserts *path exists and line ≤ file length*. Correctness of a pointer's *target*
  rests on the §4 endpoint dereference (42/43 distinct endpoints matching) and on the hash-verified
  subtree, not on the sweep alone. **One mis-targeting pointer survives the sweep** (§4.1) —
  resolvability is not targeting.
- The sweep is a working-tree sweep over 16 files, **none of which any manifest pins** (§1). The
  `HEAD`-tree run in §5 is what makes the result independent of in-flight peer edits.
- **The `UNRESOLVED` count is checker-dependent on the current tree** (§4.2). Three variants of the
  same check read `0`, `1`, and `3` here. Mine reads `0` because it skips a sentinel-carrying
  `gate/README.md` and prints the skip; the other two count control strings quoted in that file's
  prose. My number is not "more correct" than theirs — it answers a narrower question (does any
  *artifact* pointer break). All three agree at `40`/`0` on the r101 tree itself.
- **No file outside this seat's declared path was written.** `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
  `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, and the byte-pinned
  subtree (`upstream/`, `.manifest.d/`, and the subtree's own `.md` files) are untouched — `git
  status` shows no modification attributable to this seat. The two `correction-note` findings
  (§4.1, §4.2) are recorded here for their owners rather than edited into pinned files.
