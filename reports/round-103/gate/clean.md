# SEAT-10 CLEAN-RUN-VERIFIER — gate clean run on the live tree

**Seat:** SEAT-10 CLEAN-RUN-VERIFIER · round 103 · lane `game-dev-3d-shokunin`
**Owned paths:** this file, `reports/round-103/gate/clean.raw.txt`, `reports/round-103/gate/clean.now.txt`
**Target:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
`sha256 = 412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96`, mtime `2026-10-18 15:15:52 -0300`
**Lane HEAD at run:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
**Host time of the pinned run:** `2026-10-18T18:31:07Z` (local `15:31`)
**Method:** the gate was executed unmodified on the live working tree; no Unreal runtime claim is
made anywhere below (editor not installed, live-MCP unproven by construction).

---

## Verdict

**GATE RESULT: PASS, rc=0.** All four checks print `STEP=PASS` and every expected value in the
seat's list is met:

| quantity | expected | observed |
|---|---|---|
| manifest lines `OK` | 12 | `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0` |
| clone HEAD | the pin | `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| clone worktree / tracked | clean / 12 | `CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0` |
| cards | 13 | `CARDS=13 EXPECTED=13 BAD=0` |
| label census | 12 / 1 / 0 | `CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0` |
| pointers unresolved | 0 | `UNRESOLVED=0` |

Two conditions of the seat's brief are **not** met, and are reported rather than papered over:

1. **The run is pre-hardening.** A1–A4 are *not* in the installed gate. The script's mtime is
   `15:15` (r102 close) and it contains none of the A1–A4 markers — no multi-endpoint range
   validation, no prose-hijack-proof label rule, no card-name set comparison, and its clone-failure
   branch still prints `BLOCKED, not PASS` and exits 1 rather than a distinct exit 2:
   ```
   $ grep -nE 'A1|A2|A3|A4|exit 2|card-name' corpus/knowledge/unreal-mcp/gate/run_gate.sh
   140:    printf 'FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS\n'
   ```
   So this is a clean run of the **r102 gate**, not of the hardened one.
2. **`POINTERS` does not equal the pinned `87`** (see next section).

---

## Full output — the pinned run (live tree, `POINTERS=88`, PASS rc=0)

`clean.raw.txt` is the verbatim capture; the final `RC=0` line is the shell's `$?`, not gate output.

```
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c

MANIFEST_FILES=12
CHECK 1 manifest-byte-identity
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
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
RC=0
```

**Determinism:** a second back-to-back run produced byte-identical output
(`diff` of the two captures empty apart from the appended `RC=` line) — the gate is reproducible at
a fixed tree state.

---

## Finding 1 — the pinned `POINTERS=87` does not match the committed tree (prints 88)

`gate/README.md:118` and `:129` pin `POINTERS=87`, written by the same commit that authored the
gate (`c6f655d`, r102 close, `2026-10-18 15:20:00 -0300`). The live tree at that commit prints
**88**. Reproduced against a pristine extraction of the committed tree so working-tree edits cannot
explain it:

```
$ git archive c6f655d | tar -x -C /tmp/r103_committed
$ ( cd /tmp/r103_committed && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh )
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Attribution, from an instrumented copy of check 4 run on that same pristine tree: loop 1 (the
`upstream/<path>:<line>` sweep) yields **40**; the `HARDENING G` relative-path sweep yields **48**;
`40 + 48 = 88`. The `87` figure is therefore a **one-low transcription** of the value the committed
gate actually prints, not tree drift. The binding invariant the README itself calls load-bearing
(`UNRESOLVED=0`) holds in both readings, and the README's own "scanner-relative" hedge partially
defuses the number — but the block is labelled *"Expected … as measured at r102 close"*, and the
measured value is 88. **This is a report-level observation for the parent; I did not edit the
protected `gate/README.md`.** Pinning `87` is now a live expectation mismatch for any future
clean-run verifier.

---

## Finding 2 — a peer's C1 edit landed mid-verification and drove the gate transiently red

At `2026-10-18 15:32:55 -0300` a peer (C1, freshness note) appended the r103 correction note to
`corpus/knowledge/unreal-mcp/adaptation-kimi.md`. That edit added exactly two new repo-relative
pointers — `reports/round-103/note/author.md` and `reports/round-103/note/urls.md` — taking the
count from 88 to 90.

For a window of roughly 23 seconds the gate **failed**, because `author.md` was cited before it
existed on disk:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
CHECK 4 pointer-sweep
MISSING-PATH-REL reports/round-103/note/author.md
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL

GATE RESULT: FAIL (checks failed: 1)
```

Once `author.md` was written (`15:33:18`) the gate returned to green:

```
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)   rc=0
```

`clean.now.txt` is that current capture. Two calibration data points fall out:

* **The gate is genuinely sensitive to a dangling repo-relative pointer** — `HARDENING G` caught a
  real transient breakage, not a false positive. That is the hardening working as designed.
* **A clean-run verifier must timestamp its run.** The subtree is being written concurrently by
  peers; the same command returned PASS(88), FAIL(90/1), PASS(90) within ~2.5 minutes on a tree
  whose git HEAD never moved. The pinned run in this report is anchored to `18:31:07Z` /
  gate `sha256 412d1b84…`.

---

## Not verified — stated plainly

* **A1–A4 hardening**: not present in the installed gate (Finding above), so no post-hardening
  clean run exists to verify. Nothing in this report should be read as a clean run of a hardened
  gate.
* **11-attack suite**: could **not** be re-run. `/tmp` (tmpfs) is at 77% with `2.1G` consumed by
  `/tmp/advgate`, and the suite's `cp -a` of the repo into its scratch copy died with
  `cp: error writing … Disk quota exceeded`; its output was therefore computed against a partially
  copied tree and is not trustworthy, so I did not use it. Re-running it needs the quota freed or a
  different scratch root (I moved my own scratch to `~/.cache/r103scratch` for this reason).

## Reproduce

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # 412d1b84…  (r102 gate)
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
# pristine-tree check of the 87-vs-88 mismatch:
rm -rf /tmp/r103_committed && mkdir -p /tmp/r103_committed
git archive c6f655d | tar -x -C /tmp/r103_committed
( cd /tmp/r103_committed && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS )
```
