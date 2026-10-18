# SEAT-35 MANIFEST-RERUN — r102 independent re-run of the r101 unreal-mcp byte-pin

Scope: re-run, from the lane tree at HEAD `2c99b7b8155841617d844c609813afcba77aa207`, the two
byte-identity checks over the r101 Unreal subtree `corpus/knowledge/unreal-mcp/`.

- Run at: 2026-10-18T17:41:28Z (UTC)
- Lane HEAD: `2c99b7b8155841617d844c609813afcba77aa207`
- Subtree-owning commit: `1659c03` (r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad)
- Upstream pin: `a6aa73ada02a9fb1f5415bec491f9942c519b297` (public repo, read-only reference)
- Subtree status at run time: `git status --porcelain corpus/knowledge/unreal-mcp/` was empty
- Re-run at 2026-10-18T17:4xZ after a sibling seat applied the F8 wording fold to
  `corpus/knowledge/unreal-mcp/README.md` (see the re-run section at the end)
- No Unreal runtime claim is made or implied here: the editor is not installed and live-MCP
  behavior is unproven by construction. These checks cover file bytes only.

## Check 1 — manifest sha256

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
RC=0
```

Result: **PASS** — 12/12 `OK`, 0 failures, rc=0. No `FAILED` / `WARNING` lines.

## Check 2 — path-set equality vs a fresh pinned clone

```
$ cd /tmp && rm -rf r102-verify && git clone -q \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin r102-verify
CLONE_RC=0
$ cd /tmp/r102-verify && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git checkout -q a6aa73ada02a9fb1f5415bec491f9942c519b297 && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ cd corpus/knowledge/unreal-mcp/upstream
$ find . -type f -not -path './.git/*' | sed 's|^\./||' | sort > /tmp/r102-seat35-local.txt
$ cd /tmp/r102-verify && git ls-files | sort > /tmp/r102-seat35-upstream.txt
$ diff /tmp/r102-seat35-local.txt /tmp/r102-seat35-upstream.txt && echo "PATH_SET_EQUAL=yes"
PATH_SET_EQUAL=yes
$ wc -l /tmp/r102-seat35-local.txt /tmp/r102-seat35-upstream.txt
 12 /tmp/r102-seat35-local.txt
 12 /tmp/r102-seat35-upstream.txt
 24 total
```

Result: **PASS** — the clone's HEAD equals the declared pin without an explicit checkout (the pin
is the clone default `main` tip), the diff is empty, and both sides carry exactly 12 tracked files.
The vendored `upstream/` carries no `.git/` of its own (`git -C ... rev-parse --show-toplevel`
resolves to the lane root), so the local side is enumerated as plain files, not via `git ls-files`.

## Check 3 (extra, beyond seat brief) — manifest hashes vs clone-computed hashes

Independent of Check 1, the recorded digests were compared against digests recomputed from the
fresh clone rather than from the lane tree:

```
$ cd /tmp/r102-verify && for f in $(git ls-files); do sha256sum "$f"; done | sort -k2 \
    > /tmp/r102-seat35-clone.sha256
$ cd corpus/knowledge/unreal-mcp && grep '^[0-9a-f]\{64\}  ' .manifest.d/audit-reference.sha256 \
    | sed 's|  upstream/|  |' | sort -k2 > /tmp/r102-seat35-manifest.norm
$ diff /tmp/r102-seat35-manifest.norm /tmp/r102-seat35-clone.sha256 && echo "MANIFEST_VS_CLONE=identical"
MANIFEST_VS_CLONE=identical
```

Result: **PASS** — the manifest is not merely self-consistent with the lane tree; it reproduces the
upstream bytes at the pin exactly.

## Check 4 (extra, beyond seat brief) — local bytes vs clone bytes, per file

```
$ cd corpus/knowledge/unreal-mcp/upstream
$ for f in $(cat /tmp/r102-seat35-local.txt); do \
    a=$(sha256sum "$f" | cut -d' ' -f1); \
    b=$(sha256sum "/tmp/r102-verify/$f" | cut -d' ' -f1); \
    if [ "$a" != "$b" ]; then echo "MISMATCH $f"; else echo "MATCH $f $a"; fi; done
MATCH .claude-plugin/plugin.json 5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44
MATCH CODEOWNERS 653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f
MATCH .gitignore 0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538
MATCH hooks/hooks.json 259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c
MATCH hooks/unreal-context.sh d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd
MATCH LICENSE 5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6
MATCH README.md 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
MATCH skills/create-toolset/SKILL.md e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c
MATCH skills/unreal-mcp/references/operations.md dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113
MATCH skills/unreal-mcp/references/setup.md bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a
MATCH skills/unreal-mcp/SKILL.md 7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa
MATCH skills/unreal-skill/SKILL.md 7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087
```

Result: **PASS** — 12/12 MATCH, 0 MISMATCH.

## Check 5 (extra, beyond seat brief) — the 11 per-seat manifests

`.manifest.d/` holds 11 further manifests (`seat01..seat11`), each pinning one or two files:

```
$ for m in .manifest.d/seat*.sha256; do out=$(sha256sum -c "$m" 2>&1); rc=$?; \
    n=$(echo "$out" | grep -c ': OK$'); bad=$(echo "$out" | grep -vc ': OK$'); \
    echo "$m rc=$rc ok=$n other=$bad"; done
.manifest.d/seat01.sha256 rc=0 ok=1 other=0
.manifest.d/seat02.sha256 rc=0 ok=1 other=0
.manifest.d/seat03.sha256 rc=0 ok=1 other=0
.manifest.d/seat04.sha256 rc=0 ok=1 other=0
.manifest.d/seat05.sha256 rc=0 ok=1 other=0
.manifest.d/seat06.sha256 rc=0 ok=1 other=0
.manifest.d/seat07.sha256 rc=0 ok=1 other=0
.manifest.d/seat08.sha256 rc=0 ok=1 other=0
.manifest.d/seat09.sha256 rc=0 ok=1 other=0
.manifest.d/seat10.sha256 rc=0 ok=1 other=0
.manifest.d/seat11.sha256 rc=0 ok=2 other=0
```

Result: **PASS** — all 11 rc=0, 13 `OK` lines total, no non-OK lines.

## Digest of the manifest itself (for downstream drift detection)

```
$ sha256sum corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
$ sha256sum corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/PROVENANCE.md
2004a9e5aadcdc825c15f60e34e76a70cc0930556fc63f3b15e2ce0f371b17b9  corpus/knowledge/unreal-mcp/README.md
36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01  corpus/knowledge/unreal-mcp/PROVENANCE.md
```

(Superseded for `README.md` by the re-run below.)

## Re-run — after the F8 wording fold landed in the subtree README

At 2026-10-18T17:42:06Z a sibling seat applied the F8 wording fold to
`corpus/knowledge/unreal-mcp/README.md` (the `:187` / "12 lines" ambiguity). Because that file
lives inside the pinned subtree — not inside `upstream/` — every check above was re-run rather
than reported from the pre-edit snapshot.

```
$ git status --porcelain corpus/knowledge/unreal-mcp/
 M corpus/knowledge/unreal-mcp/README.md
$ git diff --stat corpus/knowledge/unreal-mcp/README.md
 corpus/knowledge/unreal-mcp/README.md | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 > /tmp/rc.txt 2>&1
RC=0 ; grep -c ': OK$' /tmp/rc.txt → 12 ; grep -v ': OK$' /tmp/rc.txt → (no output)

$ for m in .manifest.d/seat*.sha256; do sha256sum -c "$m" >/dev/null 2>&1; echo "$m rc=$?"; done
.manifest.d/seat01.sha256 rc=0 ... .manifest.d/seat11.sha256 rc=0   # all 11 rc=0

$ cd corpus/knowledge/unreal-mcp/upstream   # 12/12 file hashes vs /tmp/r102-verify
(no MISMATCH lines printed)
$ find . -type f -not -path './.git/*' | sed 's|^\./||' | sort | diff - /tmp/r102-seat35-upstream.txt \
    && echo "PATH_SET_EQUAL=yes"
PATH_SET_EQUAL=yes
```

Updated digests at this later snapshot:

```
$ sha256sum corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  .../audit-reference.sha256
$ sha256sum corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/PROVENANCE.md
ef17c7759c69888f57376603fbaeed79f9ab9eed73d03a39d4fee22b701b71cb  corpus/knowledge/unreal-mcp/README.md
36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01  corpus/knowledge/unreal-mcp/PROVENANCE.md
```

Note the `.manifest.d/*.sha256` files pin only paths under `upstream/`; none pins
`corpus/knowledge/unreal-mcp/README.md`. That is why the F8 fold does not invalidate the pin, and
why the pin still reports 12/12 after the fold. The `audit-reference.sha256` digest is itself
unchanged (`fe3906c5…`) across both snapshots, as is `PROVENANCE.md` (`36938c71…`).

## Verdict

All five checks PASS at HEAD `2c99b7b`, both before and after the F8 fold. The r101 byte-pin over
`corpus/knowledge/unreal-mcp/` reproduces exactly against a fresh clone of the pinned upstream
`a6aa73ad`, and the vendored `upstream/` tree is byte-identical throughout. The F8 fold touches
only the subtree's own `README.md`, which no manifest pins.

One observation for the L1, not a defect in the pin: `corpus/knowledge/unreal-mcp/gate/` and its
`run_gate.sh` did **not** exist when this seat ran (checked `ls corpus/knowledge/unreal-mcp/gate`
→ exit 2), so C1(a) of this round was not yet on disk at that time; this seat's checks were run
against the subtree directly and are reproducible without that script. This seat did not create
the gate — it is another seat's declared path.
