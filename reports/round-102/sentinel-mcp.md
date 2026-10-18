# r102 SEAT-53 SENTINEL-MCP — security posture re-check of the lane repo

Round r102 · lane `game-dev-3d-shokunin` · axis: coverage / depth / calibration
Seat question: **does the lane repo, or any new r102 file, introduce a `.mcp.json` or a hook
auto-load (the r101 sentinel S-8 class)?** Sweep the repo; state the lane's current exposure.

Snapshot: HEAD **`2c99b7b8155841617d844c609813afcba77aa207`** (`r101 report-last`; work commit
`1659c036`), branch `main`. Host Linux, Kimi Code **2.2.0**, BuildID
`5e67bdf95c7646325b62decd0ca8d375d325ea19` (`file ~/.kimi-code/bin/kimi`). No commit/checkout/reset
was run; the only write this seat made is this file.

Evidence classes as in r101: **[O]** observed here with the command shown · **[S]** static-only
(artifact read/parsed, described behaviour not executed) · **[?]** unknown.

---

## 0. Verdict

**No.** The lane repo introduces no `.mcp.json` and no hook auto-load in r102, and the tracked tree
was already inert before r102. **But the r101 "inert" conclusion rested on an assumption that does
not hold on this harness, and the corrected version makes the lane's margin thinner than r101
recorded.** Kimi Code 2.2.0 *does* gate project-level MCP — behind a per-workspace trust flag — and
**this lane's workspace is already trusted** [O]. The gate that would stop a repository-supplied
`.mcp.json` from loading is therefore already open on this host; the only thing keeping the lane
inert is that no `.mcp.json` exists at the git root. That is a one-file margin, not a control.

---

## 1. The sweep (commands run, results pasted)

**1.1 Tracked `.mcp.json` — none.**

```
$ git ls-files | grep -c '\.mcp\.json'
0
```

**1.2 `.mcp.json` anywhere on disk — one, and it is gitignored r101 residue.**

```
$ find . -path ./.git -prune -o -name '.mcp.json' -print
./corpus/live/r101-sentinel/mcp2/proj/.mcp.json

$ git check-ignore -v corpus/live/r101-sentinel/mcp2/proj/.mcp.json
corpus/.gitignore:1:live/	corpus/live/r101-sentinel/mcp2/proj/.mcp.json

$ git ls-files --error-unmatch corpus/live/r101-sentinel/mcp2/proj/.mcp.json
error: pathspec '...' did not match any file(s) known to git
```

That file is the r101 sentinel's own mock-project fixture
(`{"mcpServers":{"unreal-mcp":{"type":"http","url":"http://127.0.0.1:8001/mcp"}}}`). It is
**untracked and uncommittable** (ignored by `corpus/.gitignore:1`), it points at a port nothing
listens on, and it is not at the git root — so Kimi's resolver never reaches it (§2.1). Inert.

**1.3 No harness config directory of any kind in the lane tree.**

```
$ find . -path ./.git -prune -o \( -name '.claude' -o -name '.kimi-code' -o -name 'settings.json' \) -print
        (empty)
$ git ls-files | grep -Ei '(AGENTS\.md|CLAUDE\.md|\.cursorrules|\.windsurfrules)$'
        (empty, exit 1)
$ git ls-files | grep -c 'enabledPlugins'
0
```

No `AGENTS.md`, no `CLAUDE.md`, no `.claude/`, no `.kimi-code/`, no `.cursorrules`. There is no
auto-instruction file and no project-scoped plugin-enable file anywhere in the repo.

**1.4 Hook surfaces in the tracked tree — two, both vendored data, both byte-pinned.**

```
$ git ls-files | grep -Ei '(hooks\.json|\.claude-plugin|kimi\.plugin\.json)'
corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
corpus/knowledge/unreal-mcp/upstream/hooks/hooks.json

$ sha256sum corpus/knowledge/unreal-mcp/upstream/hooks/hooks.json \
             corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  .../hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  .../hooks/unreal-context.sh
```

Both hashes equal the pin recorded in r101 §1.1 (`a6aa73ada02a9fb1f5415bec491f9942c519b297`), and
`reports/round-102/reruns/manifest.md:92-93` independently re-confirms `MATCH` this round. These are
**Claude Code plugin manifests, not Kimi config**: nothing in the lane reads them, and the r102
harness does not have a `.claude` directory to enable them from. They are the reference artifact,
not a live registration — the same conclusion r101 §1.2 reached, re-verified.

**1.5 Nothing is listening; no integration component is installed.**

```
$ ss -ltn | grep -E ':(8000|8001|8002)'      → (empty, exit 1)
$ command -v unreal_mcp_proxy                  → (empty, exit 1)
$ find / -maxdepth 4 -iname 'UnrealEditor*'    → (empty)
```

**1.6 r102's own new files introduce no config surface.** Every file added or modified this round
(`git status --porcelain -uall`) is `.md`, `.sha256`, `.txt`, or one of two `.sh` scripts:

```
$ find reports/round-102 corpus/knowledge/unreal-mcp -newermt "2026-10-17" -type f \
    | sed 's/.*\.//' | sort | uniq -c
     31 md   12 sha256   2 json   2 sh   1 LICENSE   1 CODEOWNERS   1 gitignore
```

The two `.json` are the vendored `plugin.json` / `hooks.json` of §1.4 (byte-pinned, unchanged). The
two `.sh` are `corpus/knowledge/unreal-mcp/gate/run_gate.sh` (SEAT-37) and
`reports/round-102/reruns/pointer-sweep.sh` (SEAT-37). Neither is a hook and neither auto-loads:

```
$ grep -nE 'source |^\s*\. |eval|mcp\.json|hooks\.json|\.kimi-code|\.claude|exec ' \
    corpus/knowledge/unreal-mcp/gate/run_gate.sh
   (only comment lines; no source/eval/exec, no config write)
```

`run_gate.sh` is manually invoked, is not registered anywhere, and does not install or enable
anything. **One security-relevant property to record rather than hide**: it runs
`git clone --quiet "$REPO" "$CLONE"` (line 86) against the pinned public repo, i.e. it performs
network egress to `github.com` when run. That is a documented, operator-initiated fetch to a
read-only public reference — not a hook, not at session start — but a future reader should know the
gate is not network-free.

---

## 2. The r102 calibration finding — the S-8 class does exist on Kimi, and the gate is already open

This is the one result that changes the picture, and it is why this seat did not simply re-confirm
r101's wording.

### 2.1 Kimi 2.2.0 resolves a project-root `.mcp.json`, and gates it behind workspace trust

Decompiled from the shipped binary (`strings -n 6 ~/.kimi-code/bin/kimi > /tmp/k53_strings.txt`):

```
// /tmp/k53_strings.txt:671899  (packages/agent-core-v2/.../mcpConfig/configLoader.ts)
async function resolveMcpJsonPaths(input) {
	const start = normalize$2(input.cwd);
	const projectRoot = (await findGitWorkTree(input.fs, start))?.root ?? start;
	return {
		user: join$93(resolveKimiHome(input.homeDir), "mcp.json"),
		projectRoot: join$93(projectRoot, ".mcp.json"),
		project: join$93(input.cwd, ".kimi-code", "mcp.json")
```

and the gate itself:

```
// /tmp/k53_strings.txt:682309
const [fileServers, pluginServers] = await Promise.all([loadMcpServers({
    fs: this.fs,
    cwd: this.workspace.cwd,
    homeDir: this.bootstrap.homeDir,
    includeProject: this.trust.isTrusted()
}), this.plugins.enabledMcpServers()]);

// /tmp/k53_strings.txt:682491
isTrusted() { return this.envTrusted || this.trusted; }

// /tmp/k53_strings.txt:682467
TRUST_WORKSPACE_ENV = "KIMI_CODE_TRUST_WORKSPACE";
```

The user-facing half is a startup warning on untrusted folders:

```
// /tmp/k53_strings.txt:976566
Warning: this folder is not trusted; skipped N project-level MCP servers: <list>.
  Run `kimi` here and choose "Trust this folder", or set KIMI_CODE_TRUST_WORKSPACE=1, to enable them.
```

So: **`<git work tree root>/.mcp.json` is read natively by Kimi, but only when the workspace is
trusted.** This is the direct Kimi counterpart of r101's S-8, and it is *stronger* than Claude
Code's behaviour as r101 measured it — r101 S-8 recorded Claude Code auto-loading a project
`.mcp.json` with **no** operator prompt in non-interactive mode; Kimi gates the same thing behind a
persisted trust decision. That is a real, measurable improvement and it is worth recording as such.

### 2.2 …but this lane is already trusted

```
$ ls ~/.kimi-code/workspace-trust/
wd_game-dev-3d-shokunin_1d5718ea9394  wd_shokunin_8c4a99c6228c  wd_projects_48a771e908b1  ...

$ cat ~/.kimi-code/workspace-trust/wd_game-dev-3d-shokunin_1d5718ea9394
{"root":"/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin","trustedAt":1792342592733}
                                              # = 2026-10-18T13:56:32-03:00

$ env | grep KIMI_CODE
                                              (empty — the trust is persisted, not env-forced)
```

`readWorkspaceTrust` returned true for this workspace's root, so `this.trust.isTrusted()` is true,
so `includeProject` is true, so a `<lane root>/.mcp.json` **would** load on the next session start
in this repo. The trust file is the same object `kimi doctor` and the interactive "Trust this
folder" prompt write; it is a persisted operator decision, not something the repository can set.

**Consequence for the lane.** The lane is inert for exactly one reason: the git root has no
`.mcp.json`:

```
$ ls -la .mcp.json
ls: cannot access '.mcp.json': No such file or directory   (exit 2)
```

Two adjacent facts make that margin thinner than it looks:

1. **The parent directories are trusted too** — `wd_shokunin` (`/home/vgpnk/Projects/shokunin`) and
   `wd_projects` (`/home/vgpnk/Projects`) both carry trust records [O]. Trust is granted per
   workspace root and the lane root is a git work tree, so this does not by itself widen the lane's
   exposure; it does mean the operator has already accepted the prompt broadly on this tree.
2. **A project-root `.mcp.json` entry can be `stdio`, and stdio entries spawn a command at session
   start** — the shipped `mcp-config` skill text says so explicitly
   (`/tmp/k53_strings.txt:684137`: "Mention once that project-root and project-local stdio entries
   spawn commands at session start, so they should only live in trusted repos"). r101's S-8 framing
   was about an **HTTP** endpoint; the higher-blast-radius variant on Kimi is a `stdio` command,
   because it executes rather than merely connects.

Neither the lane repo nor r102 supplies such a file. The point is that **the repo's safety here is
the absence of a file, and the file is exactly what an Unreal integration is documented to create**
(`upstream/skills/unreal-mcp/references/setup.md:57-79` instructs the operator to write
`.mcp.json` into the project; `upstream/README.md:72` notes the plugin ships none, so it is always
hand- or editor-generated). The `.gitignore` does **not** cover it — the lane has no root
`.gitignore` and `corpus/.gitignore` only ignores `live/`, `__pycache__/`, `*.pyc` — so a future
`.mcp.json` at the lane root would be **committed**, not silently ignored. That is the concrete
hazard for this lane: not an attacker, but a well-meaning seat following `setup.md:57-79`.

---

## 3. Host residue from r101 (not a repo finding)

Recorded so a later reader does not mistake probe leftovers for a live install, and to confirm
r101 §8.1 still holds.

```
$ python3 -c "... json.load(open('~/.claude.json')) ..."
top keys: [..., 'pluginUsage', ...]
has enabledPlugins: False
pluginUsage: {'unreal-engine-skills-for-claude-code@inline': {'usageCount': 51,
              'lastUsedAt': 1792344227628}}          # = 2026-10-18T14:23:47-03:00
mcpServers: {}
projects keys: ['/tmp/r101work/seat17/projA']
```

- The only `unreal` reference in `~/.claude.json` is a **usage counter** for the `@inline` source
  that `--plugin-dir` produces, last touched at 14:23:47 — inside r101's probe window (r101 §1.3
  places its harness runs at 14:19–14:24). It is a telemetry counter, not an enablement.
- `enabledPlugins` is **absent**; `~/.claude/settings.json` does not exist; `~/.claude/plugins/data/`
  holds one empty directory (`…-inline`); `grep -rl enabledPlugins ~/.claude` → nothing.
- The lane repo path appears **0 times** in `~/.claude.json` (`grep -c game-dev-3d-shokunin` → 0),
  so no Claude Code project entry points at this repo.
- `~/.kimi-code/plugins/installed.json` lists exactly one plugin, `kimi-webbridge` (unrelated,
  enabled), and no Unreal plugin. `~/.kimi-code/config.toml` has exactly one `[[hooks]]` table
  (`:3219`, `Notification` / `task\.completed` → `notify-send`, pre-existing, unrelated to Unreal).
- `kimi doctor` reports the only config complaint is `Unknown top-level key ignored by the v2
  engine: mcp_servers` — i.e. the `[mcp_servers.rea]` table in `config.toml` is dead config under
  v2; Kimi reads `~/.kimi-code/mcp.json` (currently only the `cli-agents` stdio server).

No cleanup is needed to make this lane safe; nothing here is a live integration.

---

## 4. Lane exposure, in one paragraph

**The lane repo is currently inert and r102 keeps it that way — no tracked `.mcp.json`, no
`.claude/` or `.kimi-code/` config directory, no `AGENTS.md`/`CLAUDE.md`, no `enabledPlugins`
anywhere in 678 tracked files, no listener on 8000/8001/8002, and the only hook artifact in the tree
is the vendored `upstream/hooks/hooks.json` + `unreal-context.sh`, both byte-identical to the pin
and read by nothing (`git ls-files | grep -c '\.mcp\.json'` → 0; `sha256sum` → `259124f0…` /
`d3f1c871…`). The single `.mcp.json` on disk
(`corpus/live/r101-sentinel/mcp2/proj/.mcp.json`) is untracked, gitignored by `corpus/.gitignore:1`,
and not at the git root, so Kimi's resolver never reaches it.** The residual exposure is not an
attacker and not r102: Kimi Code 2.2.0 resolves `<git root>/.mcp.json` natively and gates it behind
workspace trust (`/tmp/k53_strings.txt:671904`, `:682309`), and **this lane's workspace is already
trusted** (`~/.kimi-code/workspace-trust/wd_game-dev-3d-shokunin_1d5718ea9394`, trusted
2026-10-18T13:56:32) — so the gate is open and the repo's safety rests solely on the absence of that
file. `upstream/skills/unreal-mcp/references/setup.md:57-79` instructs an operator to create exactly
that file, the lane has no root `.gitignore` to stop it being committed, and a `stdio` entry in it
would spawn a command at session start (`/tmp/k53_strings.txt:684137`). The forward-looking rule for
this lane is therefore narrow and mechanical: **do not let a `.mcp.json` (or a `.kimi-code/mcp.json`)
land at the lane root**, and treat the existing workspace-trust record as the reason that rule
matters here rather than as a control that already covers it.

---

## 5. What this seat did NOT establish

- **No execution of any MCP server or client.** No `.mcp.json` was created, no MCP connection was
  opened, and the trust gate was not exercised end-to-end — §2 is read from the binary and from the
  persisted trust record, so the `includeProject` behaviour is **[S]**, not [O]. I did not run a
  session in an untrusted folder to watch the warning fire.
- **No Unreal runtime claim.** The editor is not installed; nothing here speaks to live MCP
  behaviour, which is `unproven-runtime` by construction, exactly as r101 §8 states.
- **Kimi-version-bound.** The `resolveMcpJsonPaths` / trust-gate strings are valid only for BuildID
  `5e67bdf95c7646325b62decd0ca8d375d325ea19` (v2.2.0); a CLI upgrade invalidates them, per the same
  invalidation rule `corpus/knowledge/unreal-mcp/adaptation-kimi.md:§5` sets for its own pointers.
- **r101's S-8 wording is not wrong, but it is Claude-Code-specific.** It says a project `.mcp.json`
  "is auto-loaded and connected without an operator prompt in non-interactive mode". That is a
  Claude Code measurement and remains true of Claude Code; it should not be read as a Kimi
  behaviour, where the equivalent load is trust-gated. Flagging for the calibration seat — this is a
  harness-transfer row, the same class as r101 §9 item 3, and it now has an answer.
