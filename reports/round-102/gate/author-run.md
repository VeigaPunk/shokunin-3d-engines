# r102 gate author-run — SEAT-17 GATE-AUTHOR

**Date:** 2026-10-18 · **Lane:** `game-dev-3d-shokunin` · **Round:** 102
**Deliverable:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh` + `gate/README.md`
**Tree gated:** lane HEAD `2c99b7b8155841617d844c609813afcba77aa207` (r101 work commit
`1659c036`), with the r102 in-flight repairs from peer seats present in the worktree.
**Verdict:** **PASS — 4/4 checks green, exit 0.** Seven mutation controls all behave as
designed (6 red, 1 intentionally green). Independently mutation-tested by SEAT-18
(`reports/round-102/gate/mutation.md`, 7 more cases, no false PASS).

Every number below was produced by the command shown, on this host, in this run. Nothing is
quoted from an author's transcript.

**Artifact hashes** (so a verifier can confirm the gate it runs is the gate tested):

| file | sha256 |
|---|---|
| `gate/run_gate.sh` | `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` |
| `gate/README.md` | `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8` |

Both match the hashes SEAT-18 recorded in its mutation report, so its verdict covers these
exact bytes.

---

## 1. Clean run — full pasted output

Command:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_EXIT=$?"
```

Full stdout:

```
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207

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
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
GATE_EXIT=0
```

Raw capture: `reports/round-102/gate/author-run.txt`.

### Observed values vs the README's pinned expectations

| quantity | pinned | observed | match |
|---|---|---|---|
| manifest lines `OK` | 12 | `MANIFEST_OK=12 FAILED=0 RC=0` | yes |
| clone HEAD | the pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | yes |
| tracked upstream files | 12 | `CLONE_TRACKED=12`, `CLONE_DIRTY=0` | yes |
| path-set extra / missing | 0 / 0 | `PATH_EXTRA=0 PATH_MISSING=0` | yes |
| blob diffs vs clone | 0 | `BLOB_DIFFS=0` | yes |
| cards | 13 | `CARDS=13 BAD=0` | yes |
| label census | 12 / 1 / 0 | `12 / 1 / 0` | yes |
| pointers unresolved | 0 | `UNRESOLVED=0` | yes |

---

## 2. Mutation controls — the gate must go red

Each control runs on a **throwaway copy** (`cp -r` into `mktemp -d`), never on the pinned tree.
The gate resolves its subtree from its own location, so the copy is self-gating. Raw capture:
`reports/round-102/gate/controls.txt`.

| # | mutation | exit | failing checks | observed signal |
|---|---|---|---|---|
| C1 | `printf '\n' >> upstream/README.md` | **1** | 1, 2 | `MANIFEST_OK=11 … FAILED=1 RC=1`; `BLOB-DIFF README.md`; `BLOB_DIFFS=1` |
| C2 | `rm upstream/LICENSE` | **1** | 1, 2 | `RC=1`; `PATH_MISSING=1`; `FAIL upstream file not vendored`; `BLOB-DIFF LICENSE` |
| C3 | append `see upstream/README.md:200` | **1** | 4 | `LINE-OOR … upstream/README.md:200 (max 112)`; `POINTERS=41 UNRESOLVED=1` |
| C4 | label line `**Label:** \`static-only\` and not \`verified-here\`` | **1** | 3 | `FAIL multi-label …`; `CARDS=13 BAD=1` |
| C5 | relabel a card `**Label:** \`unproven-runtime\`` | **1** | 3 | `BAD=0` but census `11 / 2 / 0` ≠ `12 / 1 / 0` |
| C6 | `rm executability/sequencer.md` | **1** | 3 | `CARDS=12 EXPECTED=13` |
| **C7** | append **only** exact sentinels (`upstream/nope.md:3`, `upstream/README.md:9999`) | **0** | none | `SKIPPED_CONTROL_SENTINELS=2 UNRESOLVED=0` → `GATE RESULT: PASS` |

Reading the matrix:

- **C1 and C2 fail two checks each, not one.** The byte-flip is caught by both the manifest and
  the blob-compare, and the deletion is caught by both the path-set diff and the blob-compare.
  This is the point of check 2's redundancy: a manifest can be regenerated from a corrupted tree,
  the blob-compare against a fresh clone cannot.
- **C5 is the calibration that matters most.** C4/C5/C6 all attack check 3, and C5 in particular
  produces a *self-consistent-looking* card set — 13 cards, every one with exactly one label,
  `BAD=0` — that only the **pinned census** catches. Without the `12/1/0` expectation the gate
  would have passed a silent relabel. `verified-here=0` is pinned for the same reason: on a host
  with no Unreal Editor, a `verified-here` card must fail the gate, not slip through.
- **C7 is the filter's own positive control.** It proves the sentinel rule skips *only* the exact
  control strings. If the filter were keyword-based it would also eat real pointers, and C7's
  `UNRESOLVED=0` alongside `SKIPPED=2` is the evidence that it does not.
- **C6 also shows a side effect worth noting:** removing `sequencer.md` dropped the pointer
  total `40 → 33`, because 7 of the 40 pointers live in that card. A pointer sweep that reported
  only `UNRESOLVED=0` without the total would have hidden that loss; the total is printed for
  exactly this reason.

---

## 3. Negative results and limits

- **No Unreal runtime claim is made anywhere in this run.** The editor is not installed on this
  host, so check 3's `verified-here=0` is the *correct* census, and a green gate is **not**
  evidence of live-editor behavior. The strongest statement the gate supports is: the vendored
  bytes are byte-identical to the pinned upstream commit, and these static checks ran here.
- **Check 2 is the only check needing network.** It succeeded here (fresh clone, 0.6 s). If the
  clone fails the gate prints `BLOCKED, not PASS` and exits 1 — a cached clone is never
  substituted silently.
- **Check 3 enforces label *mechanics*, not label *semantics*.** Whether a given `static-only`
  card actually rests on a static check that ran here is a read-the-cards judgement no script can
  make; `reports/round-101/r101-verification-protocol.md` §4 states the criterion and a verifier
  must apply it by hand. This gate does not claim otherwise.
- **The gate deliberately does not run r101 protocol steps 6 and 9** (markdown link check, JSON /
  `shellcheck` well-formedness). They are useful supporting checks but not among this gate's four;
  their absence here must not be read as their having passed.
- **F8 context.** The subtree README's `*.sha256` sweep line was corrected by a peer seat during
  this round (worktree diff at `corpus/knowledge/unreal-mcp/README.md:166-171`, now reading
  `12 OK` for the `audit-reference` subset and `24 OK` for the full glob). This gate pins the
  **`audit-reference.sha256` subset = 12** in check 1, which is consistent with that correction;
  check 1 was re-run after the correction landed and still prints `MANIFEST_OK=12 … RC=0`.
- **Incidental live-tamper detection (unplanned, worth recording).** During this session's final
  confirmation run, SEAT-18 GATE-MUTATION briefly overwrote the **live** pinned subtree
  (`upstream/README.md` replaced by a one-line `TAMPERED` stub, `upstream/skills/unreal-mcp/SKILL.md`
  also modified). The gate caught it on the real tree: exit 1, `MANIFEST_OK=10 EXPECTED=12 FAILED=2`,
  `BLOB_DIFFS=2` (`README.md`, `skills/unreal-mcp/SKILL.md`), and `UNRESOLVED=20` — every pointer
  into the truncated 1-line `README.md` reported `LINE-OOR … (max 1)`. The seat then restored the
  bytes and the re-run returned to `GATE RESULT: PASS`, exit 0, `POINTERS=40 UNRESOLVED=0`.
  This is the gate detecting an **unscheduled** mutation of the pinned tree, not a synthetic one —
  and it is the operational reason the gate's own spec file is excluded from check 4: a checker
  that is red because a peer is mid-mutation, then green once restored, is behaving correctly.
  SEAT-18's own report states it works under `/tmp/r102mut` and never modifies the repository;
  whatever caused this transient edit, the gate did not miss it and the pinned bytes verified
  clean again immediately after. **The authoritative green run for this seat is the one captured
  in `author-run.txt` after restoration** (pasted in §1).

## 4. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"     # expect exit=0, GATE RESULT: PASS
```

Portability checked: running the same command from `/tmp` (absolute path) printed the identical
`GATE RESULT: PASS (checks failed: 0)`. `bash -n` and `shellcheck` on `run_gate.sh` both exit 0.
