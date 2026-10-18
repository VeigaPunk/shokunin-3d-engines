# SEAT-05 KIMI404-VERIFY

**Scope:** verify the corrected upstream URL, the old URL, and the minimal change to `corpus/knowledge/unreal-mcp/adaptation-kimi.md`. Read-only for the source file; only this report was written.

## URL probes

Commands run:

```bash
curl -sI --max-time 20 https://github.com/EpicGames/unreal-engine-skills-for-claude-code
curl -sI --max-time 20 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
```

Observed response status lines, respectively: `HTTP/2 404` and `HTTP/2 200`.

## Source-file diff

Commands run:

```bash
git show HEAD:corpus/knowledge/unreal-mcp/adaptation-kimi.md | sha256sum
git diff --unified=0 -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
git diff --numstat -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md
git diff --check -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
```

Observed: the HEAD file SHA-256 is `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`; working-file SHA-256 is `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`. The unified-zero diff shows exactly one replacement on line 6: the bare repository URL gains `-plugin`; `--numstat` is `1 1`, and `git diff --check` emits no errors. No other line moved or changed in this file.
