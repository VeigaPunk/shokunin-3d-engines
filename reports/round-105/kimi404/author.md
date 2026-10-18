# SEAT-04 KIMI404-AUTHOR — r105

Axes: coverage (working upstream pointer); calibration (HTTP reachability evidence).

Line 6 of `corpus/knowledge/unreal-mcp/adaptation-kimi.md` is a source locator (`Upstream:`), not a historical observation, so it was corrected in place. The pin remains `a6aa73ada02a9fb1f5415bec491f9942c519b297`; the matching repository URL is recorded in `corpus/knowledge/unreal-mcp/PROVENANCE.md` §1.

Verification actually run:

```bash
curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
```

Observed output:

```text
200
```

Diff check actually run: `git diff -- corpus/knowledge/unreal-mcp/adaptation-kimi.md`.
Observed changed lines:

```diff
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
+ Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` pinned at
```

Only the URL on line 6 changed. The later r103 dated note remains untouched as the historical record of the former 404. No fixtures or environment state were mutated.
