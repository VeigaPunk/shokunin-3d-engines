# r106 SEAT-76 — PC-CARRY

**Axes:** coverage (card-label census and the six dissent lines), depth (operator package still present and environment identity still matches), calibration (worktree bytes vs HEAD `0cc3f41` and vs r105 work `3634bc0`).

**Verdict: PASS.** The P/C package is untouched this round. Card labels are unchanged anywhere this seat can see a declaration. The operator package file is byte-identical to the r105 commit. No ruling was applied. This seat wrote only this file (scratch under `reports/round-106/scratch/seat76/` holds the command receipts). No commit, push, checkout, or reset. No Unreal Editor or runtime claim.

Snapshot start: `date -u` → `2026-10-18T21:22:23Z`. `git rev-parse HEAD` → `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`).

## 1. Census re-grep — 12/1/0

Command (lane root, `set +e` so a zero bucket cannot abort the loop):

```sh
for label in verified-here static-only unproven-runtime; do
  n=0
  for f in corpus/knowledge/unreal-mcp/executability/*.md; do
    hit=$(grep -m1 -oE 'verified-here|static-only|unproven-runtime' "$f")
    if [ "$hit" = "$label" ]; then n=$((n+1)); fi
  done
  echo "${label}=${n}"
done
find corpus/knowledge/unreal-mcp/executability -maxdepth 1 -type f -name '*.md' | wc -l
```

Observed at `2026-10-18T21:22:50Z`:

```text
verified-here=0
static-only=12
unproven-runtime=1
cards=13
```

Declaration-line parser (same five heading shapes as `reports/round-105/pc/ruling-draft.md`) observed the same census, one label each, `missing=0`. The single `unproven-runtime` card is `actors-scene.md:5` (`**Label:** `unproven-runtime``). The other twelve declarations are `static-only`. Full table: `reports/round-106/scratch/seat76/declarations.txt`.

Gate constants were read, not re-run (SEAT-70 owns the gate): `grep -n 'EXPECTED_STATIC|EXPECTED_UNPROVEN|EXPECTED_VERIFIED|EXPECTED_CARDS' corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `EXPECTED_CARDS=13`, `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0`. That is the pinned 12/1/0, unchanged. This seat does not claim a fresh `GATE RESULT: PASS`.

## 2. Six dissent lines — same six, same spans

```sh
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | sort
```

Observed `dissent_files=6`:

```text
corpus/knowledge/unreal-mcp/executability/animation-controlrig.md
corpus/knowledge/unreal-mcp/executability/blueprints.md
corpus/knowledge/unreal-mcp/executability/editor-general.md
corpus/knowledge/unreal-mcp/executability/gameplay-gas.md
corpus/knowledge/unreal-mcp/executability/materials.md
corpus/knowledge/unreal-mcp/executability/meshes-textures.md
```

An earlier `dissent_count=0` in this seat's first shell was a backtick-quoting failure under `set -e`, not a missing marker. The command above is the count that counts. Receipt: `reports/round-106/scratch/seat76/dissent-files.txt` (`wc -l` → `6`).

Span extract used the line ranges in `reports/round-105/pc/cards.md` (animation 170–172, blueprints 113–115, editor-general 46–52, gameplay-gas 149–151, materials 192–194, meshes-textures 243–250). Each span still contains `Not `unproven-runtime``, and each distinctive phrase quoted in `cards.md` is still in the live span (`dissent-byte-compare.txt`, all six `needle_in_live_span=True`). Marker lines observed:

- `animation-controlrig.md:170` — `**Not `unproven-runtime`:**` path not identified (F6); label stays `static-only`.
- `blueprints.md:113` — same shape (F7).
- `editor-general.md:46` — `Not `unproven-runtime` **as the card label**`.
- `gameplay-gas.md:149` — stricter test; `static-only`.
- `materials.md:192` — path not identified (F10); `static-only`.
- `meshes-textures.md:243` — path not identified (F7); stronger negative label.

No dissent file was added or dropped. Full span text: `reports/round-106/scratch/seat76/dissent-extract.txt`.

## 3. Untouched this round — byte identity

```sh
git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/README.md \
  corpus/knowledge/unreal-mcp/executability \
  reports/round-105/operator-package.md reports/round-105/pc
echo "quiet_rc=$?"
git status --short --untracked-files=all -- corpus/knowledge/unreal-mcp
git diff --numstat HEAD -- corpus/knowledge/unreal-mcp/executability \
  corpus/knowledge/unreal-mcp/README.md reports/round-105/operator-package.md \
  reports/round-105/pc
```

Observed: `quiet_rc=0`; `unreal_mcp_status_lines=0`; numstat empty (zero line changes). `git status --short` on the executability tree, README, `reports/round-105/pc`, and `reports/round-105/operator-package.md` was empty at `2026-10-18T21:22:23Z`.

Blob walk (`git hash-object` vs `git rev-parse HEAD:<path>` and vs `3634bc0748f2ae1e02e20571874b39a3f3705daa:<path>`) over README + 13 cards + operator package + 11 `reports/round-105/pc/*.md`:

```text
tracked=26 differ=0 missing=0
vs_3634bc0 tracked=26 differ=0
```

Worktree-wide declaration scan (reports/round-106 excluded, so this seat's own write cannot fake a hit):

```sh
git diff -U0 HEAD -- . ':(exclude)reports/round-106' \
  | grep -cE '^[+-].*(Label|Verdict).*(static-only|unproven-runtime|verified-here)'
```

Observed `label_decl_diff_count=0` at `2026-10-18T21:27:30Z`. No card-label declaration line was added or removed outside this round's report tree. `corpus/knowledge/unreal-mcp/label-precedence.md` is absent (`ls` → `No such file or directory`), so the ledger's post-ruling landing file was not created.

`git diff --quiet HEAD -- SKILL.md` → `skill_quiet_rc=0`. `SKILL.md:119` is still `## 4. The open precedence ruling (state it, do not resolve it)` and line 135 still says `The P/C precedence ruling is still owed`. This seat did not edit `SKILL.md`.

Card sha256 (worktree, matches HEAD blobs): `reports/round-106/scratch/seat76/sha-cards.txt`. README sha256:

```text
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
```

That is the same README digest the operator package and the r105 ruling draft quote.

Last commit touching the cards is r101 `1659c036c961c6cdfd0b2679db72ecb9517a2f3b` (2026-10-18 14:31:29 -0300). README last touched by r102 `c6f655d055b0fb5f4921e01c2081b82d15d38ef5`. Operator package and `reports/round-105/pc/` last touched by r105 `3634bc0748f2ae1e02e20571874b39a3f3705daa`. Nothing in r106 has moved them.

## 4. Operator package still intact

File: `reports/round-105/operator-package.md`. `wc -l` → 34. sha256 `83124766c85c14c381cb8c41c50fe5c15ce2ea2dfed37658e642c1e97a967d3a`. Git blob `d0a6691c3a81bef2654f4d61207db585cafb8790` is identical for worktree, `HEAD:`, and `3634bc0:`.

Section headers still present (`grep -n '^## '`):

- `## 1. P/C label precedence — decision requested`
- `## 2. Node 24 — two execution profiles, not a fixture drift`
- `## 3. Three L0 questions for the operator`

Both branches and the hybrid recommendation are still in the file (`P — policy-first`, `C — card-first`, `Recommendation (hybrid proposal)` all `PRESENT=True`). The package still says the six labels stay unless a reviewed amendment lands, and that the proposal is not applied.

L0 questions still match r101. Command actually run:

```sh
python3 -c "p='reports/round-101/r101-report.md'; print(''.join(open(p).readlines()[337:342]), end='')"
```

Observed the same three operator-owned questions (Epic↔GitHub link, `wukakuki/unreal-engine:dev-slim-5.8.3`, Lutris/Epic launcher). All three strings are present in the operator package.

Environment identity re-probed at `2026-10-18T21:23:04Z` (not a battery rerun):

```text
default_node=v26.12.0 path=/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
pinned_exists=yes pinned_version=v24.21.0
```

Pinned binary: `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`. That matches section 2's two profiles. The package's 13-case `0/13` vs `13/13` totals, and its statement that no full Node-24 receipt was in the assembly scan, are historical sentences inside an intact file. This seat did not re-run those cases. Later r105 receipts (`reports/round-105/n24/runs/`) are outside this carry check.

`reports/round-105/pc/` still has 11 files (`analyst-1.md`, `analyst-2.md`, `cards.md`, `distiller.md`, `history.md`, `impact.md`, `ledger.md`, `review-1.md`, `review-2.md`, `review-3.md`, `ruling-draft.md`). Digests in `reports/round-106/scratch/seat76/sha-pc.txt`. Ruling draft still `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`. All three reviews still open with **REVISE** (`review-1.md:9`, `review-2.md:3`, `review-3.md:10`). They reviewed different distiller hashes; none is a same-hash accept. That is why the ruling stays unapplied, which is what the empty card diff shows.

### Calibration note — not a fail

`operator-package.md` says a package-assembly scan saw `pc_reviews=0`. That sentence is frozen historical text. The live inventory, measured here, is 3 review files. Do not read `pc_reviews=0` as the current count. The conclusion that sentence was supporting — proposed, not applied — is still true: labels unchanged, `label-precedence.md` absent, `SKILL.md` §4 still owed, reviews are REVISE on unequal hashes.

## 5. What this seat did not do

- Did not edit cards, README, gate, `SKILL.md`, lessons, fixtures, or any r101–r105 report.
- Did not re-run `run_gate.sh` (SEAT-70) or the 13 cannon cases quoted in the operator package.
- Did not treat the operator package's assembly-time battery paragraph as a fresh 350/350 claim.

No blocker. Carry stands: census `12/1/0`, dissent `6`, package bytes `differ=0`.
