# r107-verify2 — VERIFY-2, independent 3-way verification re-run

## Plan (5 lines)
1. Fresh clone `EpicGames/unreal-engine-skills-for-claude-code-plugin` (transport A, `git clone` https) into `/var/tmp/r107-verify2/clone`; resolve HEAD pin independently.
2. Transport B: codeload tarball at the resolved pin; transport C: GitHub REST `git/blobs` (base64); transport D: REST `contents` API — four transports sharing no local state.
3. Build my **own** manifests (`reports/round-107/mutations/v2-manifest-*.sha256`), never reading VERIFY-LEAD's or `.manifest.d/` files for values; compare A/B/C/D against each other and against the vendored tree.
4. Independently re-run the close-out gate (offline reference + live network), plus two negative controls that must fail; re-derive PROVENANCE §2 and §8 tables.
5. Record AGREE/DISAGREE per claim with exact command + observed output; label [O]/[I]/[?]; UNPROVEN stays UNPROVEN.

## Status
- **COMPLETE.** Verdict: **AGREE** with VERIFY-LEAD (byte-identity chain) and with the gate's PASS.
  Two non-blocking findings recorded in §6 for the orchestrator (same-pin round; stale §8 census).

## Axes (Godspeed)
- A1 independence — every value re-derived from the wire, no sibling artifact used as a source of values.
- A2 coverage — 12/12 paths × 4 transports + tree object + whole-tree `diff -rq`.
- A3 falsifiability — every claim paired with the command that would refute it; 3 negative controls run.
- A4 non-harm — writes only under `reports/round-107/` and `/var/tmp/r107-verify2/`; `corpus/` untouched.

---

## 1. Transport A — fresh `git clone` (https smart protocol) [O]

```
$ git clone -q https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin clone
clone_exit=0            # 2026-10-19T03:08:41Z
$ git -C clone rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C clone rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959
$ git -C clone ls-files | wc -l            → 12
$ git -C clone ls-files -s | awk '{print $1}' | sort | uniq -c   → 12 100644
symlinks=0  submodules=0  lfs=0  .gitattributes=absent
$ git -C clone log -1 --format='%H %an %ai %ci %s'
a6aa73ada02a9fb1f5415bec491f9942c519b297 Thomas Mansencal 2026-09-17 13:19:50 +1200 2026-09-17 13:28:32 +1200 [MCP] Permit safe concurrent tool calls
```

## 2. Transports B, C, D — three fetch classes that share no local state [O]

**B — codeload tarball** (plain HTTPS object download, no git wire protocol):
```
$ curl -sSL -o t.tar.gz "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ad…"
curl_exit=0  bytes=22990
$ sha256sum t.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  t.tar.gz
tarball top dir: unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297
pax_global_header comment: a6aa73ada02a9fb1f5415bec491f9942c519b297   # artifact self-identifies
members: 12 files, 8 dirs, 0 links
```
The tarball sha256 `d091941c…` and byte count 22990 match VERIFY-LEAD's independently [O] — a
same-value agreement produced by a separate seat's separate run.

**C — REST `git/blobs`** (base64-decoded bytes; no working tree, no git object store):
script `mutations/v2-transport-c.sh`; per blob `gh api …/git/blobs/<sha> --jq .content | base64 -d | sha256sum`.
Observed: 12 rows, every `rest_size == declared_size`, all hashes equal to A.

**D — REST `contents` API** (`?ref=<pin>`, a different endpoint family than `git/blobs`):
12 rows fetched path-by-path from the REST tree listing; all equal to A.

## 3. Byte-identity result — 4/4 transports identical, and identical to the vendored tree [O]

Each transport's sorted `sha256  path` manifest was built from its own bytes. Manifest sha256:

| transport | how fetched | rows | manifest sha256 |
|---|---|---|---|
| A clone | `git clone` https | 12 | `16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963` |
| B tarball | codeload tar.gz | 12 | `16dfaa66…` (same) |
| C blobs | REST git/blobs | 12 | `16dfaa66…` (same) |
| D contents | REST contents | 12 | `16dfaa66…` (same) |
| VENDOR | `corpus/knowledge/unreal-mcp/upstream/` | 12 | `16dfaa66…` (same) |

```
$ diff v2-A.sha256 v2-B.sha256   → no output, IDENTICAL
$ diff v2-A.sha256 v2-C.sha256   → no output, IDENTICAL
$ diff v2-D.sha256 v2-A.sha256   → no output, IDENTICAL
$ diff v2-A.sha256 v2-VENDOR.sha256 → no output, IDENTICAL
$ diff -rq clone <tarball-root>            → only "Only in clone: .git"; exit 1 (expected: tarball has no .git)
$ diff -rq clone corpus/knowledge/unreal-mcp/upstream --exclude=.git → no output, exit 0
```

Whole-tree `diff -rq` is stronger than per-file hashing: it also catches extra or missing files.
Both directions are clean for the vendored tree.

### Tree-object identity (above the file level) [O]
```
git -C clone rev-parse HEAD^{tree}                                    → b5b9624b00fc90217240e823406699d0ab78b959
gh api repos/…/commits/a6aa73ad… --jq .commit.tree.sha                → b5b9624b00fc90217240e823406699d0ab78b959
(reconstructed from the extracted tarball) git write-tree             → b5b9624b00fc90217240e823406699d0ab78b959
```
Three independently obtained tree ids agree; a stray/extra file in any transport would change this.

### Git blob ids re-derived from content [O]
`git hash-object <path>` for all 12 paths equals the `git ls-files -s` blob id in the clone, the
tree listing from the REST API, and the sha1 computed from the tarball's own bytes (`git hash-object`
run inside the extracted tarball, no git repo). 12/12 OK.

## 4. Cross-checks against the committed record [O]

| record | check | result |
|---|---|---|
| `PROVENANCE.md` §2 per-file table | bytes, lines, sha256, `git blob` (4 invariants × 12 rows) | all 48 hold |
| `.manifest.d/audit-reference.sha256` | diff vs my independent A-manifest (path-normalized) | identical (only the 5 comment lines differ) |
| `.manifest.d/seat01..seat11` | `cat seat*.sha256 \| sort` vs audit-reference | union identical — 12 entries, no extras, no gaps |
| `.manifest.d/*.sha256` | `sha256sum --strict -c` from inside the subtree | 12/12 PASS, exit 0 |
| §8 five recorded out-of-pin hashes | re-fetched from their PR refs, base64-decoded to file (byte-preserving) | 5/5 MATCH on sha256 **and** byte count |
| §8 history-only blob `eaf2e838` | `git/blobs` decode | 8306 bytes reproduced; sha256 `1b184bbb…` |

Byte-preserving decode matters: piping base64 output through a shell variable strips a trailing
newline and yields size−1 (my first pass showed `907/908` etc. for all five). Writing to a file
gives 5/5 exact MATCH. This is a methodology note, not a defect in §8.

## 5. Gate re-run and negative controls [O]

Run from `corpus/knowledge/unreal-mcp/` with scratch outside the lane tree.

**5a — clean, offline reference (my own fresh clone):**
```
$ GATE_WORKDIR=/var/tmp/r107-verify2/gatew GATE_REF=/var/tmp/r107-verify2/clone ./gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297 CLONE_DIRTY=0 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0            STEP=PASS
CARDS=13 EXPECTED=13 BAD=0  CENSUS static-only=12 unproven-runtime=1 verified-here=0
POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0        STEP=PASS
GATE RESULT: PASS (checks failed: 0)   exit 0
```

**5b — clean, live network clone (no `GATE_REF`):**
```
$ GATE_WORKDIR=/var/tmp/r107-verify2/gatew2 ./gate/run_gate.sh
CHECK 1 PASS · CHECK 2 CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12 BLOB_DIFFS=0 PASS
CHECK 3 PASS · CHECK 4 POINTERS=103 UNRESOLVED=0 PASS
GATE RESULT: PASS (checks failed: 0)   exit 0
```

**5c — negative control 1: mutated reference clone** (byte 50 of `skills/unreal-mcp/references/operations.md` XOR 1; size unchanged 6497):
```
$ GATE_REF=/var/tmp/r107-verify2/negclone ./gate/run_gate.sh
CHECK 2 → BLOB_DIFFS=1 STEP=FAIL ; GATE RESULT: FAIL (checks failed: 1)   exit 1
```
CHECK 1 still passes (the vendored tree is untouched) and CHECK 2 fails — the check that owns
clone equivalence is the one that fires. Correct attribution.

**5d — negative control 2: mutated subtree copy** (byte 10 of `upstream/README.md` XOR 1; size unchanged 8398):
```
$ (cd /var/tmp/r107-verify2/sub-mut && ./gate/run_gate.sh)
upstream/README.md: FAILED (×3 lines)
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1   STEP=FAIL
CHECK 2 FAIL · CHECK 3 PASS · CHECK 4 FAIL
GATE RESULT: FAIL (checks failed: 4)   exit 1
```
Two single-byte mutations at unchanged file sizes are caught with the exact expected check failing.
The gate is therefore **falsifiable, not vacuous** — it does not pass unconditionally.

## 6. Findings for the orchestrator [O]/[I]

**F1 — the "fresh pin" is the same pin as r101. [O]**
```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ gh api repos/…/commits?sha=main&per_page=5   # newest first
a6aa73ad… 2026-09-17  [MCP] Permit safe concurrent tool calls
d1b05809… 2026-09-10  Document MCP proxy setup and recovery, bump to 3.1.0
```
Only one branch (`main`), no tags advertised, `pushed_at 2026-09-17T02:27:43Z`, plugin `3.1.1`.
r101's PROVENANCE §1 records the same SHA. **The round re-establishes the same commit; there is no
content delta.** The value of the round is the independent re-derivation, not freshness — and the
"re-vendor at a fresh pin" wording should be reported as *attempted-and-found-unchanged*, not as
"fresh". Consequence: r101's pin-derived byte/count claims are **not** invalidated by this round
(they are reconfirmed), which resolves the CRIT-HYGIENE stale-hard question in the negative.

**F2 — PROVENANCE §8's out-of-pin census is materially stale. [O]**
§8 records 2 open PRs (1 and 4) and 6 out-of-pin paths. The remote advertises **6** open PRs
(1, 2, 4, 5, 8, 9) and the per-PR file lists give **15** out-of-pin paths:
- PR 2 duplicates PR 1's `.claude-plugin/marketplace.json` (not in §8).
- PR 5 modifies in-pin `hooks/hooks.json` (1+/1−) — §8 records only *added* paths.
- PR 8 adds a whole `opencode/` subtree (10 files) and edits 4 in-pin skills — the largest surface.
- PR 9 bumps `plugin.json` to **3.1.2** and edits 2 in-pin files — the one that moves the pin if merged.
Recommended §8 wording: pin's 12/12 closed and verified; out-of-pin surface = 15 paths across 6 open
PRs; none vendored this round. (VERIFY-LEAD reaches the same conclusion in its §6 — independent
agreement, not a copy.)

**F3 — manifest usage note worth landing. [O]** `.manifest.d/*.sha256` paths are relative to
`corpus/knowledge/unreal-mcp/`, not the repo root; running `sha256sum -c` from the repo root fails
for all 12. The gate handles this correctly (it `cd`s into the subtree), but a one-line usage note in
the landed README/PROVENANCE would prevent a future seat from misreading that failure as drift.

## 7. Where I AGREE / DISAGREE with VERIFY-LEAD

| claim | VERIFY-LEAD | my independent value | verdict |
|---|---|---|---|
| pin = `a6aa73ada02a9fb1f5415bec491f9942c519b297` | [O] | `a6aa73ad…` (A, B, C, D, ls-remote, REST) | **AGREE** |
| 12 tracked files, all `100644`, no symlink/submodule/LFS | [O] | same | **AGREE** |
| 12/12 byte-identical A vs B vs vendored | [O] | 4/4 transports + vendored all share manifest `16dfaa66…` | **AGREE** |
| tree id `b5b9624b00fc90217240e823406699d0ab78b959` | [O] | same from 3 sources | **AGREE** |
| tarball sha256 `d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf`, 22990 B | [O] | same | **AGREE** |
| r101 PROVENANCE §2 / audit-reference not drifting | [O] | 48/48 invariants; manifests identical | **AGREE** |
| §8 stale: 6 PRs, ~15 out-of-pin paths | [O]/[I] | same census, same recommendation | **AGREE** |
| UE runtime verdict | deferred to `r107-unlock.md` | no `wukakuki/unreal-engine` image present at my close (03:14:25Z, re-checked 6× over 150 s: `docker images \| grep -ci unreal` → 0 throughout); pull process alive, 0 errors in `/var/tmp/ue-pull.log`, `Pull complete` count 20 | **AGREE on deferral** |
| gate PASS | not asserted by VERIFY-LEAD | PASS offline **and** live; 2 negative controls fail as designed | **AGREE (independently confirmed)** |

No disagreement found. Nothing in VERIFY-LEAD's chain was unreproducible.

## 8. What this shard does NOT claim

- No Unreal Editor, UnrealBuildTool, or MCP tool call was run; no editor exists on this host. Every
  runtime claim in the subtree remains `unproven-runtime`. UE runtime stays **UNPROVEN-with-attempt-log**:
  `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` (pid 596299, log `/var/tmp/ue-pull.log`) was
  still running at my close (03:14:25Z) — no image, no digest, no probe; `Pull complete` count 20,
  0 error lines. The unlock label is `r107-unlock*.md`'s to assert, not mine.
- Byte-identity proves *the files are what upstream shipped at that commit*; it says nothing about
  whether the editor honors them.
- I read sibling shards only *after* forming my own values; no sibling manifest, `.manifest.d/` file,
  or PROVENANCE value was used as an input to any hash I report. The one deliberate comparison to
  VERIFY-LEAD/VENDOR-B manifests is recorded as an agreement check in §7, not as a source.
- `[?]` The upstream `main` ref could move after 2026-10-19T03:08Z; the pin is a snapshot, not a promise.

## 9. Reproduce (one block)

```sh
cd /var/tmp/r107-verify2
git clone -q https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin clone
git -C clone rev-parse HEAD          # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
curl -sSL -o t.tar.gz "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ad…"
sha256sum t.tar.gz                   # expect d091941c…
# transports C/D and the manifests: see reports/round-107/mutations/v2-transport-c.sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
GATE_WORKDIR=/tmp/v2w GATE_REF=/var/tmp/r107-verify2/clone ./gate/run_gate.sh   # expect PASS, exit 0
```

Artifacts (all under `reports/round-107/mutations/`): `v2-manifest-A-clone.sha256`,
`v2-manifest-B-tarball.sha256`, `v2-manifest-C-restblobs.sha256`, `v2-manifest-D-restcontents.sha256`
(each 12 rows, all sha256 `16dfaa66…`), `v2-transport-c.sh` (`6842191c…`),
`v2-transport-c-output.txt`, `v2-negative-control.sha256` (`5bf24c31…`).
