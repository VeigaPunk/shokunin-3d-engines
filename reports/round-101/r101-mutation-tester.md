# SEAT-54 MUTATION-TESTER — r101

**Claim under test:** the C1 byte-identity gate actually bites. A manifest that passes on a pristine tree proves nothing on its own; the gate must be shown to *fail* on tampering.

**Verdict: PROVEN.** Every content mutation tried against the vendored tree is caught by `sha256sum -c`; the two mutations that are *not* caught (file mode, mtime) are outside content identity by design, and the one structural mutation that `sha256sum -c` cannot see (an extra unlisted file) is caught by the set-equality check. The repository copy of the mutated file was never modified.

---

## 0. Fixtures, pinned before any mutation

| item | value |
|---|---|
| gate manifest | `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` |
| gate command | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` |
| entries in manifest | 12 (6 comment lines + 12 `digest  path` lines = 18 lines) |
| vendored files | 12, 0 symlinks (`find . -type f`) |
| upstream pin | `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| clone used | `/tmp/ue-skills-ref` — `git rev-parse HEAD` = `a6aa73ada02a9fb1f5415bec491f9942c519b297`, equals pin |
| hashing tool | `sha256sum (GNU coreutils) 9.11`, `/usr/bin/sha256sum` |
| host | Arch Linux; Unreal Editor NOT installed (irrelevant to this seat — no runtime claim is made) |

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ cd corpus/knowledge/unreal-mcp && find upstream -type f | wc -l ; find upstream -type l | wc -l
12
0
```

---

## 1. PROBE A — baseline: the gate passes on the pristine repo

```
### PROBE A — baseline gate on the repo (pristine)
exit=0
12
```
`sha256sum -c` exit 0, 12 `: OK` lines, 0 non-OK lines. This is the "before" state the mutation must break.

## 2. PROBE B — the seat's core ask: one byte flipped on a /tmp copy

The repo file was **copied** to `/tmp/r101-mutation/iso/README.md`; the flip was applied to the copy only.

```
### PROBE B — isolated byte flip on a /tmp copy (repo file not touched)
copy sha256        : 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
manifest entry     : 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
match before flip  : YES
flipped offset 2: 'U' -> 'u' (XOR 0x20)
copy sha256 after  : 267735b6a765cc4afabcd8ef40bad8d4c7074bca358a83b4ddaef8cfb29d94e8
match after flip   : NO
gate verdict       : FAIL-caught
size before/after  : 8398 / 8398  (byte-length gate would NOT bite)
lines before/after : 112 / 112  (line-count gate would NOT bite)
```

Exactly one byte differs, and the file is byte-for-byte the same length:

```
### PROBE O — how many bytes differ between pristine and flipped copy
   3 125 165
differing byte count: 1
lengths: 8398 vs 8398
```
(`cmp -l` position 3, octal `125`=`U` → `165`=`u`; 1 differing byte; both 8398 bytes.)

The corresponding cheap gates are shown blind on the same pair, which is why the sha256 gate is the one that carries the claim:

```
### PROBE L — naive size+line gate vs sha256 gate, same mutation
pristine  : size=8398 lines=112
mutated   : size=8398 lines=112
size gate  : PASS (blind)
lines gate : PASS (blind)
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  .../corpus/knowledge/unreal-mcp/upstream/README.md
267735b6a765cc4afabcd8ef40bad8d4c7074bca358a83b4ddaef8cfb29d94e8  /tmp/r101-mutation/iso/README.md
```

## 3. PROBE C — the real gate command over a full mutated tree copy

A complete copy of `upstream/` plus the manifest was made in `/tmp`; the pristine copy is a negative control; then one byte was flipped inside the copied tree.

```
### PROBE C — real gate command run over a FULL MUTATED TREE copy
pristine copy exit=0 (negative control)
mutated copy exit=1  (gate must be non-zero)
OK lines=11  FAILED lines=1
upstream/README.md: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```
11 files still `OK`, exactly the tampered file `FAILED`, overall exit 1 — the gate localizes the failure, it does not just fail globally.

## 4. PROBE D — mutation sensitivity matrix

Each case on a fresh `/tmp` copy of the tree, one mutation at a time, gate re-run:

```
### PROBE D — mutation sensitivity matrix (all on /tmp copies, one at a time)
1-byte case flip (same size)       exit=1 CAUGHT
append single trailing newline     exit=1 CAUGHT
LF -> CRLF whole file              exit=1 CAUGHT
truncate last byte                 exit=1 CAUGHT
add trailing spaces + newline      exit=1 CAUGHT
chmod 755 only (content intact)    exit=0 MISSED
mtime backdate only (content intact) exit=0 MISSED
```
The two `MISSED` rows are **correct behavior, not a defect**: the claim is *byte*-identity, and `chmod`/`touch` leave bytes identical. Recorded here so nobody later reads the manifest as attesting file mode or timestamp.

## 5. PROBE F — coverage: hidden files, deletions, other file types

```
### PROBE F — coverage/edge cases (each on a fresh /tmp tree copy)
rm_hidden                        exit=1 CAUGHT | sha256sum: upstream/.gitignore: No such file or directory
rm_file                          exit=1 CAUGHT | sha256sum: upstream/skills/unreal-skill/SKILL.md: No such file or directory
mut_hidden                       exit=1 CAUGHT | upstream/.gitignore: FAILED
mut_small                        exit=1 CAUGHT | upstream/CODEOWNERS: FAILED
mut_script                       exit=1 CAUGHT | upstream/hooks/unreal-context.sh: FAILED
add_extra                        exit=0 MISSED |
```
- Deletion is caught (missing-file error, non-zero exit).
- Dotfiles are covered — the manifest explicitly lists them (`PROBE G` below), so the classic `sha256sum *` shell-glob blindness does not apply here.
- A mutated 64-byte `CODEOWNERS` and a mutated executable shell hook are both caught, so coverage is not limited to the large markdown files.

```
### PROBE G — hidden-file extra: does the manifest list dotfiles? (shell-glob blindness check)
2
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  upstream/.claude-plugin/plugin.json
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  upstream/.gitignore
```

The one `MISSED` row, `add_extra`, is the known structural limit of `sha256sum -c`: it verifies listed paths and is silent about *unlisted* ones. That direction is closed separately in PROBE F3.

```
### PROBE F3 — extra unlisted file, both directions
sha256sum -c with extra file      : exit=0 (0 = MISSED)
set-equality vs upstream ls-files : exit=1 (non-zero = CAUGHT)
12d11
< skills/unreal-skill/EXTRA.md
```
So: `sha256sum -c` covers **no missing / no changed**; the set-equality check against `git ls-files` covers **no extra**. Together they close both directions. Any C1 audit must run both.

## 6. PROBE F2 — manifest tampering (and the mitigation)

The manifest is a plain text file with no self-integrity guard, so it is worth stating what happens if the manifest itself is edited. Content pristine, only the manifest's README digest line changed:

```
### PROBE F2 (clean redo) — manifest tampering
13:483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
edited byte offset 1048
13:083693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
--- content of tree is pristine: 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
exit=1 (content pristine, ONLY manifest edited)
upstream/README.md: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```
A hand-edited digest makes the gate *fail* rather than silently pass — the gate is not trivially silenceable by editing the manifest. The residual risk is an attacker who rewrites **both** the file and its digest; that is closed by re-derivation from the pin, which PROBE R shows is exact:

```
### PROBE R — re-derive manifest from pinned clone == vendored manifest?
IDENTICAL: re-derived from clone a6aa73a matches vendored manifest byte-for-byte
```
The re-derived manifest (built fresh from `/tmp/ue-skills-ref` via `git ls-files` + `sha256sum`) is byte-identical to the vendored `audit-reference.sha256` body. That is the anchor of trust: the pin, not the manifest file.

## 7. PROBE H/I/K — agreement and completeness of the C1 gate

```
### PROBE H — cross-manifest agreement (all 12 manifests over the repo)
.manifest.d/audit-reference.sha256 exit=0
.manifest.d/seat01.sha256          exit=0
... (seat02..seat10) ...
.manifest.d/seat11.sha256          exit=0
```
All 12 manifests in `.manifest.d/` (the `audit-reference` plus 11 per-seat manifests, which together carry the same 12 entries) verify clean.

```
### PROBE I — vendored set == upstream tracked set (completeness of C1)
IDENTICAL SETS (12 files each)
symlinks in vendored: 0
```
```
### PROBE K — independent byte-identity vs pinned clone (diff -r, not the manifest)
diff -r exit=0 (0 lines of output)
clone HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297  pinned=a6aa73ada02a9fb1f5415bec491f9942c519b297
```
`diff -r upstream/ /tmp/ue-skills-ref --exclude=.git` is clean — the vendored tree equals the pinned clone by an *independent* method (byte diff, not the manifest being audited).

## 8. PROBE M/N — CI usability and determinism

```
### PROBE M — exit-code contract of the gate (for CI wiring)
pristine  exit=0
mutated   exit=1
=> exit 0 clean / exit 1 tampered: usable as a CI gate without output parsing.
```
```
### PROBE N — determinism: gate run 3x on pristine repo
df76d6d15b03e056
df76d6d15b03e056
df76d6d15b03e056
```
Exit code alone is a sufficient signal (no output parsing needed), and repeated runs give identical results — no nondeterminism to explain away.

## 9. PROBE E/J2/Q — the repo file was never touched

The mutation was applied only to `/tmp/r101-mutation/iso/README.md`. After all probes:

```
### PROBE J2 — repo file untouched (corrected cwd)
repo/upstream/README.md mtime=2026-10-18 14:13:32.260920327 -0300 size=8398
repo/upstream/README.md sha256=483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
manifest entry          sha256=483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
probe workdir mtimes (all under /tmp): 2026-10-18 14:14:45.745672372 -0300
```
```
### PROBE E — repo file untouched
repo README sha256 now : 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
manifest entry         : 483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e
repo gate re-run exit  : 0
```
- Repo `README.md` digest still `483693ad…` = the manifest entry; the gate re-runs exit 0.
- Its mtime `14:13:32` **predates every probe write** (`14:14:45` and later), which is independent evidence no write touched it.
- `git status --porcelain` shows only pre-existing untracked paths (`?? corpus/knowledge/unreal-mcp/`, `?? reports/round-101/probes/`); no modification to any tracked file. No `git` mutating command was run.

Nothing was "restored", because nothing in the repo was changed to begin with.

---

## 10. Verdict table

| mutation (applied to /tmp copies) | gate result | correct? |
|---|---|---|
| 1-byte flip, same size (README.md) | CAUGHT (exit 1) | yes |
| append trailing newline | CAUGHT | yes |
| LF → CRLF | CAUGHT | yes |
| truncate last byte | CAUGHT | yes |
| trailing whitespace | CAUGHT | yes |
| delete listed file (incl. dotfile) | CAUGHT | yes |
| mutate 203-byte dotfile | CAUGHT | yes |
| mutate 64-byte CODEOWNERS | CAUGHT | yes |
| mutate shell hook | CAUGHT | yes |
| manifest digest hand-edited | gate FAILS (exit 1) | yes |
| add unlisted file | missed by `sha256sum -c`; CAUGHT by set-equality | yes, with second check |
| chmod mode only | missed | yes — bytes unchanged |
| mtime only | missed | yes — bytes unchanged |

## 11. Residual gaps / follow-up for the L1

1. **Two-check requirement.** C1 should be described as `sha256sum -c` **plus** set-equality against `git ls-files`. `sha256sum -c` alone does not see extra files (PROBE F3). Everything else needed is already in place.
2. **Trust anchor is the pin.** The manifest has no self-integrity guard; re-derivation from `a6aa73ada02a9fb1f5415bec491f9942c519b297` is what makes it meaningful (PROBE R). If a future round re-vendors, re-derive rather than hand-edit.
3. **Mode/mtime are deliberately out of scope.** Not defects; do not read the manifest as attesting them. If executability of `hooks/unreal-context.sh` ever matters, that is a separate check.
4. **No runtime claim made or implied.** This seat touches only static bytes; Unreal Editor is not installed on this host and nothing here speaks to live-editor MCP behavior.

## 12. Reproduction

Probe scripts (kept in `/tmp`, not in the repo, per seat scope): `/tmp/r101-mutation/probe.sh` (A–B) and `/tmp/r101-mutation/probe2.sh` (C–E); probes F–R were run inline. Minimal reproduction of the core ask:

```sh
cd corpus/knowledge/unreal-mcp
sha256sum -c .manifest.d/audit-reference.sha256 ; echo "pristine exit=$?"   # 0
cp upstream/README.md /tmp/mut.md
python3 -c "import sys;p='/tmp/mut.md';b=bytearray(open(p,'rb').read());b[2]^=0x20;open(p,'wb').write(bytes(b))"
sha256sum /tmp/mut.md                    # 267735b6...  !=  483693ad...
cmp -l upstream/README.md /tmp/mut.md    # 1 differing byte, same length
sha256sum -c .manifest.d/audit-reference.sha256 ; echo "repo exit=$?"       # still 0
```
