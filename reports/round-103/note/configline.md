# r103 SEAT-60 — CONFIG-LINE-VERIFIER

Scope: independently verify the exact current line number **and content** of the `[[hooks]]`
`Notification` entry in `~/.kimi-code/config.toml` that `adaptation-kimi.md` row 2 should cite.
Read-only on every file outside this report.

- Host / lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816`
- Probe date: **2026-10-18** (config mtime `2026-10-18 17:50:34 UTC`)
- Label vocabulary: `verified-here` = command run on this host, output pasted below.

---

## 0. Ruling

**Row 2 must cite `~/.kimi-code/config.toml:3290-3294`, not `:3219`.**

`3219` is what r102 (`reports/round-102/kimi-surfaces.md` S1, §4) recorded — and it was correct at
that moment, but it is **already stale as of this probe**. The operator's config file was edited
**~8 minutes after** r102's receipt (receipt `2026-10-18T17:42:33Z`; file mtime
`2026-10-18T17:50:34Z`), growing `3251 → 3322` lines. The single `[[hooks]]` block moved down
`71` lines to **`3290`**.

Consequence for the r102-proposed note text: its clause *"The file's only `[[hooks]]` is at **line
3219**"* must be replaced before landing. Corrected clause is in §4 below.

## 1. Numbered context (verified-here)

```bash
$ wc -l ~/.kimi-code/config.toml
3322 /home/vgpnk/.kimi-code/config.toml
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ grep -c '\[\[hooks\]\]' ~/.kimi-code/config.toml
1
$ sed -n '3288,3296p' ~/.kimi-code/config.toml | nl -ba -v3288
  3288	"zai-coding-plan/glm-5.3-flash" = "FAST bucket, zai lane. GLM 5.3 Flash at default effort, 1M context — selectable for swarm subagents (entry pre-existed; pool registration added 2026-10-18)."
  3289	
  3290	[[hooks]]
  3291	event = "Notification"
  3292	matcher = "task\\.completed"
  3293	command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
  3294	timeout = 5
  3295	
  3296	[mcp_servers.rea]
```

Byte-exactness of the block (no trailing-whitespace or CRLF surprises — `cat -A` shows plain `$`
terminators, and `—` is UTF-8 `M-bM-^@M-^T` on the unrelated line 3288):

```bash
$ sed -n '3290,3294p' ~/.kimi-code/config.toml | cat -A
[[hooks]]$
event = "Notification"$
matcher = "task\\.completed"$
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"$
timeout = 5$
$ sed -n '3290,3294p' ~/.kimi-code/config.toml | sha256sum
b1cfc756b79d8fdaeee3738b94b3b963499cda1bf4614dc4e7e78b81552112f5  -
```

Field-by-field, this is the live precedent row 2 depends on: `event` / `matcher` / `command` /
`timeout`, same vocabulary as the row's `hooks.json` + `SessionStart` target. Only the event value
differs (`Notification` vs `SessionStart`). Block identity is unambiguous:

```bash
$ grep -n -i 'hook' ~/.kimi-code/config.toml
3290:[[hooks]]
$ grep -n -i 'hook' ~/.kimi-code/tui.toml          # (no output — 0 matches)
$ grep -n 'notify-send' ~/.kimi-code/config.toml
3293:command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
```

There is exactly one `[[hooks]]` table in the file, and it is this one — so "the file's sole
`[[hooks]]` block" is a stable description that survives further line drift.

## 2. Drift evidence — why 3219 is already wrong

```bash
$ stat -c '%y' ~/.kimi-code/config.toml
2026-10-18 14:50:34.896343019 -0300      # = 17:50:34 UTC
$ stat -c '%s bytes' ~/.kimi-code/config.toml
107496 bytes
$ sed -n '3219,3224p' ~/.kimi-code/config.toml   # what r102's "3219" points at NOW
                                    # 3219 is blank; 3220 begins a [models.*] table
[models."kimi-code/k3-256k"]
provider = "managed:kimi-code"
model = "k3-256k"
max_context_size = 262144
capabilities = [ "thinking", "always_thinking", "image_in", "tool_use", "dynamically_loaded_tools" ]
```

| Datum | r102 (`:3219`) | r103 (this probe) |
|---|---|---|
| file line count | 3251 | **3322** |
| `[[hooks]]` line | 3219 | **3290** |
| block content | identical 5 lines | identical 5 lines |
| file mtime (UTC) | ≤ `17:42:33` (receipt) | **`17:50:34`** |

The block's **content is unchanged**; only its offset moved. So r102's S1 conclusion ("the citation
is void as written, but its substance survives: a live `[[hooks]]` precedent exists") still holds —
but its replacement line number is itself now stale, which is exactly the class of drift S1 was
diagnosing. This is the second-hop confirmation that a bare line number is the wrong citation form
for a file the operator edits continuously.

## 3. Verification commands (all run, outputs in §1-§2)

```bash
wc -l ~/.kimi-code/config.toml
grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
grep -c '\[\[hooks\]\]' ~/.kimi-code/config.toml
sed -n '3288,3296p' ~/.kimi-code/config.toml | nl -ba -v3288
sed -n '3290,3294p' ~/.kimi-code/config.toml | cat -A
sed -n '3290,3294p' ~/.kimi-code/config.toml | sha256sum
grep -n -i 'hook' ~/.kimi-code/config.toml
grep -n -i 'hook' ~/.kimi-code/tui.toml
grep -n 'notify-send' ~/.kimi-code/config.toml
stat -c '%y' ~/.kimi-code/config.toml
```

## 4. Corrected row-2 citation / corrected note clause

For the owning seat (this seat does not write `adaptation-kimi.md`):

- **Row 2 pointer** — prefer the drift-proof form, with the current offset as a dated parenthetical:
  `~/.kimi-code/config.toml` — its **sole** `[[hooks]]` table (`:3290-3294` as of 2026-10-18,
  `Notification` / `task\.completed` → `notify-send`); live `[[hooks]]` precedent.
- **Corrected r102 §4 note clause** — replace *"The file's only `[[hooks]]` is at **line 3219**,
  and its event is `Notification`, not `SessionStart`."* with:

  > The file's only `[[hooks]]` table is at **line 3290** as of 2026-10-18 (it was at 3219 on
  > 2026-10-18T17:42Z; the file was edited again at 17:50Z and the block moved down 71 lines —
  > content identical). Its event is `Notification`, not `SessionStart`.

## 5. Boundaries

- No file outside `reports/round-103/note/configline.md` was written. `adaptation-kimi.md` and all
  `corpus/**` paths were read only.
- No Unreal runtime claim is made anywhere in this note: the Unreal Editor is not installed on this
  host, so live-MCP behavior stays `unproven-runtime`. Nothing here touches the plugin pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
- This note verifies one citation class (config.toml line drift). The other two r102 classes (docs
  URL `/en/` prefix, `/tmp/ue-skills-ref` → vendored copy) are out of this seat's scope.
