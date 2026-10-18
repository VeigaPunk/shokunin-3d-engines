# SEAT-50 · FRESHNESS-PIN

Round r105 · lane `game-dev-3d-shokunin` · checked 2026-10-18 UTC. Scope: this report only.

## Verdict: FRESH

The pinned commit recorded in `corpus/knowledge/unreal-mcp/PROVENANCE.md:22` is `a6aa73ada02a9fb1f5415bec491f9942c519b297`. At check time, upstream `main` resolved to that exact SHA; `HEAD` also resolved symbolically to `refs/heads/main` and to the same SHA. No pin drift observed.

Evidence from this host:

```
$ date -u '+%Y-%m-%dT%H:%M:%SZ'; git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin refs/heads/main
2026-10-18T20:31:06Z
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main

$ date -u '+%Y-%m-%dT%H:%M:%SZ'; git ls-remote --symref https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
2026-10-18T20:31:07Z
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
```

Independent pin-vs-remote comparison (`git show HEAD:corpus/knowledge/unreal-mcp/PROVENANCE.md` extracts the recorded pin; `git ls-remote` reads the live branch):

```
$ python3 -c 'import datetime,re,subprocess; url="https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin"; doc=subprocess.check_output(["git","show","HEAD:corpus/knowledge/unreal-mcp/PROVENANCE.md"],text=True); pin=re.search(r"\| pinned commit \| `([0-9a-f]{40})`",doc).group(1); row=subprocess.check_output(["git","ls-remote",url,"refs/heads/main"],text=True).strip(); remote=row.split()[0]; print("checked_at="+datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")); print("pin="+pin); print("ls-remote="+row); print("verdict="+("FRESH (exact match)" if pin==remote else "STALE (mismatch)"))'
checked_at=2026-10-18T20:31:23Z
pin=a6aa73ada02a9fb1f5415bec491f9942c519b297
ls-remote=a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
verdict=FRESH (exact match)
```

This ruling is about the moving `main` ref at the recorded check time; it does not assert any later upstream state or independently re-check vendored file contents.
