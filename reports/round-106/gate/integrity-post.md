# SEAT-117 — GATE-INTEGRITY-POST

Snapshot window `2026-10-18T21:21:42Z`–`2026-10-18T21:41:16Z` (UTC). Lane HEAD stayed `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (r105 report-last; work `3634bc0748f2ae1e02e20571874b39a3f3705daa`). No commit, push, checkout, reset, or write under `corpus/knowledge/unreal-mcp/gate/`, `upstream/`, or `.manifest.d/`. Scratch and the gate clone lived under `reports/round-106/scratch/seat117-gate` (`GATE_WORKDIR`), not `/tmp`.

No Unreal runtime claim. This seat did not launch an editor. The gate census printed `verified-here=0`.

## Vs round start

Round start is HEAD `0cc3f41`. At `2026-10-18T21:41:16Z`, `git status --porcelain -uall -- corpus/knowledge/unreal-mcp` printed nothing (`0` lines) and `git diff --exit-code 0cc3f41 -- corpus/knowledge/unreal-mcp/gate corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/unreal-mcp/upstream` exited `0`. Working-tree sha256 of `run_gate.sh` and `gate/README.md` equal the blobs at `0cc3f41`. The r106 post tree, for this seat's checked set, is the round-start tree.

| quantity | round start (`0cc3f41` / r105 close) | this snapshot |
|---|---|---|
| `run_gate.sh` sha256 | `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` | same |
| `gate/README.md` sha256 | `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf` | same |
| upstream pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | same |
| manifest | 12/12 OK | 12/12 OK |
| gate | PASS, `POINTERS=103` (`reports/round-105/gate/final-run.md`, `integrity.md`) | PASS, `POINTERS=103` |

Committed history of `run_gate.sh` (only three commits touch the path): `2ca87e84` (r104) blob sha256 `390a25ae…` — identical to HEAD and to the working tree; `8c9d9ad` / report-last `88c3b2c` blob `577c8b54…`; `c6f655d` blob `412d1b84…`.

## Gate sha

Command: `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md` and `git show 0cc3f41:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum` (README the same way).

Observed working tree and `0cc3f41` blob, both:

```text
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  run_gate.sh
e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf  gate/README.md
```

`git rev-parse 0cc3f41:corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `1a3019f73e48c79cc6e3aad63f81742ed7a6223d` (git blob id, not the sha256).

## Manifest sweep

Commands, from the repo root, at `2026-10-18T21:21:42Z`:

```sh
find corpus/knowledge/unreal-mcp/.manifest.d -maxdepth 1 -name '*.sha256' | wc -l
(cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/audit-reference.sha256); echo AUDIT_RC=$?
(cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256); echo ALLMAN_RC=$?
grep -lU $'\r' corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 || echo NO_CR
find corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/executability corpus/knowledge/unreal-mcp/.manifest.d ! -type f ! -type d | wc -l
```

Observed: `12` manifest files. Audit reference: 12 `OK`, `AUDIT_RC=0`. Strict sweep of every `*.sha256`: `ALLMAN_RC=0`, 24 `OK` lines (the 12 audit lines plus 12 seat-shard lines; `seat11.sha256` has 2 entries, `seat01`–`seat10` have 1 each). `NO_CR`. Non-regular files in those three directories: `0`.

Per-shard recheck (`sha256sum --strict -c` per file): every shard `ok` count equalled its entry count. Shard file sha256:

```text
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  audit-reference.sha256
3ad108c74406a7458c209353c9cf8bb6fff8dc1fb3d7b2a7fed3e035f217f4f4  seat01.sha256
d06036f41c11389291e3894d6a8af930689e1ce7f78bf28295af44321c43af6f  seat02.sha256
c8ab8cae7f24635c03df892ad0cb930dd038f1578fb36c5df10ebbc585e05971  seat03.sha256
abf8df4e1c3055fa76862b343c1879841d48d809693f4406138263bc632a926f  seat04.sha256
773fbbd2cc6ecb460684a65a73e836c2650f0f7bc9c498cfb091f8b53cc26f7d  seat05.sha256
7876c99c18ed740a9f105fa8c63a93e954f6fea226d92b4065328a7f5efbaf75  seat06.sha256
fcff225a0ae84f5475e233d70d183e58dfc3286f2b4d8500162355c8c402bfba  seat07.sha256
a01f03f0a68b74b0993a9402850d31edf0ecb3eafa4e3d9afd77ec83d88db724  seat08.sha256
f8409f8f94d575a761a92d3c4e00955e9fc24fe8cc5b4a7319a2d7f4ce47a3d7  seat09.sha256
b8c0492ff2ecc156b1b4612b437aec987b82e4ba48339dc481885dcc340d149e  seat10.sha256
86dbe11f32d00a91a9a0be61f7bca040fc115e5db8faad5e011791de0309f318  seat11.sha256
```

## One `GATE_WORKDIR` PASS

`GATE_REF` was unset. `git config --show-origin --get-regexp 'insteadof|insteadOf'` printed nothing (`NO_INSTEADOF_ANY_LEVEL`), so the clone URL was not rewritten to a local mirror. Stdout contains `0` lines matching `GATE_REF=` (the script prints that line only when `GATE_REF` is set).

```sh
GATE_WORKDIR="$PWD/reports/round-106/scratch/seat117-gate" \
  corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  >reports/round-106/scratch/seat117-gate/gate-pass.stdout \
  2>reports/round-106/scratch/seat117-gate/gate-pass.stderr
```

Started `2026-10-18T21:21:46Z`, ended `2026-10-18T21:21:47Z`. Process `RUN_RC=0`. Stderr `0` bytes (sha256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`). Stdout 56 lines, sha256 `3a9745c050aa81fe0ccba129cf7ff84a2cf21943c8bc708934740abf608a0587`. The gate's own cleanup removed the clone directory; the receipt files above were not part of that cleanup.

Observed stdout:

```text
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/scratch/seat117-gate (from GATE_WORKDIR)
WORK_ROOT_FREE=756G of 930G (18% used)
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd

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
NAME_SET=OK NAME_BAD=0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
```

`grep -c '^STEP=PASS$'` on that stdout → `4`. Numeric pin in `gate/README.md` lines 271 and 283 is still `POINTERS=103` / `103` / `41`. Live measurement matches the number.

## Queued — no rewrite (gate/ is protected)

Dated correction, not a silent edit. `corpus/knowledge/unreal-mcp/gate/**` is not this seat's writable chunk.

**Scanner provenance still stale (carried from r105).** README lines 42, 248, 283, 373, and 440 still name scanner `e5521304…` as the current / re-measurement scanner for `POINTERS=103`. That prefix is the r104 worktree measurement in `reports/round-104/gate/workdir.md` (`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`), not a committed blob of `run_gate.sh`. `git show 88c3b2c:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum` → `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0`. The landed r104/r105/r106 blob is `390a25ae…`. r104 `pin-check.md` already recorded `e5521304…` as a dirty-tree hash against HEAD `577c8b54…`. The numeric pin is not wrong; the attribution is. Same carry as `reports/round-105/consistency.md` (r103 O4) and `reports/round-105/gate/integrity.md`.

**Line 248 adaptation digest is historical, not live.** `git show 88c3b2c:corpus/knowledge/unreal-mcp/adaptation-kimi.md | sha256sum` → `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`, which matches the `084a34cd…` in that dated sentence. Live and `0cc3f41` blob is `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1` (same figure r105 `pin-after-edits.md` recorded). Do not read `084a34cd…` as the current adaptation digest. The live expected summary at README line 271 does not repeat it.

## Verdict

**PASS** on the tree observed in the window above: gate sha unchanged from round start, manifest sweep clean, one `GATE_WORKDIR` run `RC=0` with four `STEP=PASS` and `POINTERS=103 UNRESOLVED=0`. Subtree porcelain was still empty at `2026-10-18T21:41:16Z`. If a later seat edits subtree prose that CHECK 4 scans, this PASS is a snapshot and must be re-run; nothing in `gate/`, `upstream/`, or `.manifest.d/` moved during the window.
