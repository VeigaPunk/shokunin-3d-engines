# r107-mut-pin — MUT-PIN seat (negative control for the 3-way byte verification)

Seat KEY=MUT-PIN · round 107 (3D side-round) · lane `game-dev-3d-shokunin` · 2026-10-19.

## Plan (5 lines)
1. Read the round-107 3-way verification protocol as implemented by sibling seats (transports A=`git clone`, B=codeload tarball, C=GitHub REST `git/blobs`); reuse their exact commands, not a paraphrase.
2. `reports/round-107/mutations/mut-pin.sh`: stage a throwaway copy of the vendored tree under `/var/tmp/r107-mut-pin/`, flip exactly ONE byte in ONE tracked file, prove the mutation landed with byte-level evidence (`cmp -l` offset, sha256 before/after, byte count unchanged).
3. Run the unmutated tree first (baseline must PASS on every leg), then the mutated tree (every leg must FAIL) — a control that cannot pass clean proves nothing, one that cannot fail dirty proves nothing.
4. Widen the claim with `mut-pin-sweep.sh`: 18 mutation classes × 4 detection legs, incl. the two attacks a manifest leg cannot see (self-consistent manifest; extra file) and the one a path-blind verifier cannot see (content swap).
5. Record exact commands + observed output, exit codes, mutated path, byte offset, mutant sha256; label [O]/[I]/[?]; no writes into `corpus/`.

## Status
- **DONE** — control valid (clean 4/4 PASS, mutated 0/4 PASS); 18/18 classes caught by all three byte transports; two manifest blind spots and one multiset blind spot confirmed and asserted.

## Axes (Godspeed)
- A1 non-vacuity: a verification protocol is only as good as its ability to fail. This seat supplies the failing input.
- A2 paired control: clean and dirty runs share one script and one set of transports; the only difference is the staged bytes.
- A3 falsifiability: every leg prints its own PASS/FAIL; the sweep asserts exact blind-spot counts, so an unexpected result turns the script red.
- A4 non-harm: writes only under `reports/round-107/` and `/var/tmp/r107-mut-pin/`; `corpus/knowledge/unreal-mcp/` read-only; no commits.

---

## 0. Target pin

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main        exit 0   [O]
```

Identical to the r101 pin and to the vendored `PROVENANCE.md` §1 — **no pin drift**,
so this round re-derives the same commit rather than landing a content delta. All
mutation work below therefore targets the bytes that are actually vendored.

---

## 1. Transports provisioned by this seat (independent of sibling scratch dirs)

`mut-pin.sh` fetches all three itself into `/var/tmp/r107-mut-pin/`, so the control
does not inherit another seat's clone or its bugs:

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin ref-clone
PASS  LA clone HEAD = a6aa73ada02a9fb1f5415bec491f9942c519b297                       [O]
$ curl -sSL -o pin.tar.gz https://codeload.github.com/$REPO/tar.gz/$PIN && tar -xzf pin.tar.gz -C tarx
PASS  LB tarball root unreal-engine-skills-for-claude-code-plugin-a6aa73ad…          [O]
$ gh api repos/$REPO/git/trees/$PIN?recursive=1 --jq '.tree[]|select(.type=="blob")|"\(.path)\t\(.sha)\t\(.size)"'
PASS  LC REST blob rows = 12                                                          [O]
```

| leg | transport | shares local state with |
|---|---|---|
| LA `clone` | https smart protocol (git) | nothing — fresh clone |
| LB `tar` | codeload tarball, no git protocol | nothing — curl + tar |
| LC `rest` | GitHub REST `git/blobs`, base64-decoded | nothing — HTTP API only |
| L0 `manifest` | `sha256sum -c` against a pinned reference manifest | the manifest file only |

---

## 2. The canonical mutation (one bit, one tracked file)

`mut-pin.sh` picks a deterministic target: the first occurrence of the unique
needle `Project skills` in `skills/unreal-mcp/SKILL.md`, then flips bit 5 of that
byte (`0x50` `P` → `0x70` `p`).

```
PASS  needle 'Project skills' unique in skills/unreal-mcp/SKILL.md (offset 5235)
== mutation evidence ==
target      : skills/unreal-mcp/SKILL.md
byte offset : 5235  (0-based)
before      : 7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  7098B
after       : d811795c8ff26f683d956bec3141cb7c8b18d04d311c603770f622e68853afa0  7098B
cmp -l      : 5236 120 160
PASS  mutation landed: 1 differing byte, size unchanged                                  [O]
```

`cmp -l` reports exactly one differing position (`5236` = 1-based → offset 5235),
`120` octal = `0x50`, `160` octal = `0x70`. Size is unchanged at 7098 B, so the
mutation is invisible to any size-based check.

### Paired result — the control only counts if both halves hold

```
--- CLEAN staged tree (baseline — must be 4/4 PASS) ---
  manifest  PASS
  clone     PASS
  tar       PASS
  rest      PASS
  4/4 legs pass
PASS  baseline: unmutated tree passes every leg

--- MUTATED staged tree (must be 0/4 PASS) ---
  manifest  FAIL
  clone     FAIL
  tar       FAIL
  rest      FAIL
  0/4 legs pass
PASS  mutated tree rejected by every leg

== MUT-PIN verdict: FAILS=0 (0 = control valid) ==       exit 0   [O]
```

**Verdict: the 3-way byte verification is non-vacuous for a single-bit mutation
in a tracked file.** Clean passes 4/4, mutated fails 4/4, from one script and one
set of transports.

---

## 3. Sweep — 18 mutation classes × 4 legs (`mut-pin-sweep.sh`)

`X` = mutation DETECTED, `.` = missed. Columns: `man`=pinned manifest,
`cln`/`tar`/`rst` = the three byte transports, `mset` = a deliberately
path-blind content-multiset verifier (included only to expose its blindness).

```
mutation class                                             |  man  cln  tar  rst  mset
M1 bit-flip in .claude-plugin/plugin.json                  |  X  X  X  X  X
M1 bit-flip in CODEOWNERS                                  |  X  X  X  X  X
M1 bit-flip in .gitignore                                  |  X  X  X  X  X
M1 bit-flip in hooks/hooks.json                            |  X  X  X  X  X
M1 bit-flip in hooks/unreal-context.sh                     |  X  X  X  X  X
M1 bit-flip in LICENSE                                     |  X  X  X  X  X
M1 bit-flip in README.md                                   |  X  X  X  X  X
M1 bit-flip in skills/create-toolset/SKILL.md              |  X  X  X  X  X
M1 bit-flip in skills/unreal-mcp/references/operations.md  |  X  X  X  X  X
M1 bit-flip in skills/unreal-mcp/references/setup.md       |  X  X  X  X  X
M1 bit-flip in skills/unreal-mcp/SKILL.md                  |  X  X  X  X  X
M1 bit-flip in skills/unreal-skill/SKILL.md                |  X  X  X  X  X
M2 truncate 1 byte (skills/unreal-mcp/references/setup.md) |  X  X  X  X  X
M3 append 1 byte (LICENSE)                                 |  X  X  X  X  X
M4 self-consistent manifest (tree+manifest agree)          |  .  X  X  X  X
M5 extra file added (not in pin)                           |  .  X  X  X  X
M5b tracked file deleted                                   |  X  X  X  X  X
M6 content swap between two paths                          |  X  X  X  X  .
```

```
rows=18
transport blind spots  (clone+tar+rest all failed to catch): 0  [want 0]
manifest blind spots   (sha256sum -c against the pinned manifest missed): 2
multiset blind spots   (path-blind verifier missed): 1
CLAIM: no mutation class in this sweep escapes all three byte transports.
CONFIRMED.                                                exit 0   [O]
```

M1 is a bit flip at the midpoint of **every one of the 12 tracked files**, so the
result is not an artifact of one lucky target. M2/M3 show the legs are not
size-sensitive; M5b shows a deletion is caught; M4/M5/M6 are the informative ones.

---

## 4. What the sweep proves is *load-bearing* (blind spots)

These are the real findings — each is a structural property, not an accident:

- **[O] M4 — a manifest regenerated from the mutated tree passes its own
  `sha256sum -c`.** The manifest leg is blind whenever tree and manifest are
  produced by the same (compromised) process. Detection then rests entirely on the
  three byte transports. *Consequence for the protocol:* the reference manifest
  must be pinned independently of the tree it validates — which is exactly why
  `.manifest.d/audit-reference.sha256` is pinned from a fresh clone, and why the
  transport legs exist at all.
- **[O] M5 — an extra file (a planted `PLANTED.md`) is invisible to the manifest
  leg**, because `sha256sum -c` only walks the paths it is told about. *Consequence:*
  the file *list* must come from the pinned index, not from a walk of the tree
  being verified. The sweep feeds every leg the path list from
  `git -C ref-clone ls-files`, which is why the transports catch M5 while the
  manifest does not.
- **[O] M6 — swapping the bytes of two files defeats a path-blind multiset
  verifier** (same content hashes, different paths). All three transports catch it
  because they compare path→hash, not just the set of hashes.

The sweep asserts these counts (`manifest_blind == 2`, `multiset_blind == 1`,
`transport_blind == 0`) and exits non-zero on any deviation, so a future change
that silently loses a detection surface turns the script red.

---

## 5. Cross-check against the sibling seats (independent, read-only)

My transport-C hashes (`/var/tmp/r107-mut-pin/c-rest.txt`, derived by this seat's
own `gh api` calls) compared path+sha256 against four independently produced lists:

```
$ diff <(sort c-rest.txt) <(sort reports/round-107/mutations/va-sha256.txt)          # VENDOR-A, clone transport
(no output)  → IDENTICAL                                                              [O]
$ diff <(sort c-rest.txt) <(sort /var/tmp/r107-vb/vb-flat.sha256)                    # VENDOR-B, tarball transport
(no output)  → IDENTICAL                                                              [O]
$ diff <(awk '{print $2,$1}' c-rest.txt|sort) <(awk '{print $2,$1}' /var/tmp/r107-verify2/c-rest.txt|sort)
(no output)  → IDENTICAL                                                              [O]
$ (cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sed 's|^\./||' | sort | xargs sha256sum) > landed.sha256
$ diff <(sort c-rest.txt) <(sort landed.sha256)
(no output)  → LANDED IDENTICAL                                                       [O]
```

So four independently derived manifests — clone, tarball, REST, and the on-disk
vendored tree — agree on all 12 paths. The control in §2/§3 therefore runs against
bytes that are genuinely the pinned upstream bytes, not a corrupted staging copy.

---

## 6. Side finding — VENDOR-A §2 size column is wrong [O]

While validating my own sizes I found that `reports/round-107/r107-VENDOR-A.md` §2
carries a `size (B)` column that disagrees with its own sha256s and with the wire:

| path | VENDOR-A §2 size | actual bytes | live REST `size` |
|---|---|---|---|
| `.claude-plugin/plugin.json` | 178 | **487** | 487 |
| `.gitignore` | 19 | **203** | 203 |
| `CODEOWNERS` | 42 | **64** | 64 |
| `LICENSE` | 11357 | **1073** | 1073 |
| `README.md` | 7085 | **8398** | 8398 |

Commands:

```
$ find corpus/knowledge/unreal-mcp/upstream -type f -printf '%s\t%p\n' | sort -k2
487   upstream/.claude-plugin/plugin.json   … 8398  upstream/README.md           [O]
$ cat /var/tmp/r107-verify2/c-tree.tsv      # live REST git/trees sizes
487, 203, 64, 1073, 8398 …                                                       [O]
```

The VENDOR-A sha256 values are **correct** (they match all other seats), so this is
a metadata error in one column, not a content problem. The origin of the wrong
numbers is **[?]** unknown to this seat — they do not correspond to any size
measured here, so no cause is asserted. Note also that
VENDOR-A's own earlier `find`-style listing in the same shard (the clone leg) is
consistent with the real bytes, so §2's table is internally inconsistent with §3.
The gate's CHECK 2 compares sha256 and paths, not sizes, so this does **not** turn
the gate red — it is a documentation defect for the orchestrator to fix when
landing, not a verification failure.

---

## 7. Scope and UNPROVEN

- **[O] Verified here:** the 3-way byte verification detects any single-bit flip in
  any of the 12 tracked files; it also detects truncation, appending, deletion,
  extra files, and content swaps; the clean tree passes all legs.
- **[?] UNPROVEN — a mutation to a *non-file* property.** This seat mutates file
  bytes only. It does not test mode-bit changes (`100644`→`100755`), symlink
  substitution, or gitlink (submodule) injection; the pinned tree has no such
  entries, so those classes are untested, not refuted.
- **[?] UNPROVEN — the real gate.** These scripts exercise the *transport*
  comparison legs. They do not run `gate/run_gate.sh` (the adversary seats own
  that) and I did not run the battery. Whether the gate's own CHECK 1/2/3 fail on
  these same mutations is not claimed here.
- **[I] Not tested — remote-side compromise.** All three transports read the same
  GitHub origin, so a mutation applied *upstream at the pin* would be invisible to
  all of them. That threat model is out of scope for a byte-identity control.
- **[O] No `corpus/` writes.** `git status --porcelain` shows only
  `?? reports/round-107/`; the vendored tree was opened read-only throughout.

---

## 8. Artifacts

| path | what |
|---|---|
| `reports/round-107/mutations/mut-pin.sh` | canonical control: one bit in one tracked file, 4 legs, paired clean/mutated run |
| `reports/round-107/mutations/mut-pin-sweep.sh` | 18-class sweep × 4 legs + multiset demonstrator, with asserted blind-spot counts |
| `/var/tmp/r107-mut-pin/run.log` | verbatim `mut-pin.sh` output (§2) |
| `/var/tmp/r107-mut-pin/sweep.log` | verbatim `mut-pin-sweep.sh` output (§3) |
| `/var/tmp/r107-mut-pin/c-rest.txt` | this seat's independently derived transport-C manifest (12 rows) |
| `/var/tmp/r107-mut-pin/{ref-clone,tarx,pin.tar.gz}` | the three transports, provisioned by `mut-pin.sh` |

Re-run: `bash reports/round-107/mutations/mut-pin.sh && bash reports/round-107/mutations/mut-pin-sweep.sh`
(both exit 0 on a valid control; `mut-pin.sh` must run first to provision the transports).
