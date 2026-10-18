# SEAT-19 GATE-SENTINEL — audit of `gate/run_gate.sh`

Round r102 · lane `game-dev-3d-shokunin` · written 2026-10-18T17:45Z · lane HEAD `2c99b7b`
(`2c99b7b8155841617d844c609813afcba77aa207`).

**Artifact under audit** — `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
200 lines · `sha256 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`
(`sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh`). Author SEAT-17 GATE-AUTHOR.
This seat wrote **no** file inside `corpus/knowledge/unreal-mcp/`; the subtree is byte-pinned
and stayed clean throughout (`git status --porcelain corpus/knowledge/unreal-mcp/upstream/`
→ 0 lines; manifest re-check → 12/12 `OK`).

**Scope.** Three questions, each answered from commands run here: (a) is the gate **read-only**
over `upstream/`, `.manifest.d/`, `executability/` — does it write anywhere outside a `mktemp`
clone dir? (b) does it stay **off the network** beyond the pinned clone, and handle **no
secrets**? (c) is it **fail-closed** when its tools are missing, and can its PASS be trusted?

**Labels.** `verified-here` = a bounded run here produced the receipt · `static-only` = read,
not executed. No Unreal runtime claim appears anywhere below: the editor is not installed, so
every live-editor statement remains `unproven-runtime` by construction.

---

## 0. Verdict

**Read-only: PASS. Network: PASS. Secrets: PASS. Fail-closed on missing tools: PASS.
Trustworthy PASS: FAIL — one hole, demonstrated.**

- The gate is genuinely read-only over the pinned tree. `strace -f` shows **every** open of a
  tracked-tree path is `O_RDONLY` and every write lands inside `$WORK=$(mktemp -d)` (§2).
- It is off-network except for one `git clone` of the pinned public repo over TCP/443 (§3).
  It reads no secret, no `$HOME`, no env var of interest (§3).
- It fails closed when `git` or `sha256sum` is absent (§4). All three of the gate's own
  documented negative controls (C1/C2/C3) turn it red, as do two further mutations I added (§5).
- **The hole (H-1, §6): a PATH-shadowed `sha256sum` produces a full false green.** A stub
  earlier on `PATH` makes both the manifest check and the blob-identity check report success,
  and the gate exits `0` on a tree whose vendored bytes have been altered. Reproduced twice,
  including from a `PATH` entry the caller inherits — i.e. an attacker-placed binary in the
  invocation directory. `set -u` does not help; there is no `command -v` guard on `sha256sum`.

Net: the gate is safe to run and honest on a clean host with a sane `PATH`, and it is a
**stronger** artifact than a lint — but its PASS is not adversarial-grade, and it must not be
cited as proof of integrity against a host that has been tampered with. See §8 for the two
one-line fixes; neither was applied (not this seat's file).

---

## 1. Baseline — the gate runs green end to end

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207

CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK
… (12 lines, all OK) …
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
… (12 × static-only, 1 × unproven-runtime) …
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
exit=0
```
`verified-here`.

### 1.1 Independent re-derivation of the four counts

Re-derived with commands that do **not** use the gate's code, to confirm the gate's arithmetic
is not self-confirming:

| quantity | gate reports | independent command | observed |
|---|---|---|---|
| manifest `OK` lines | `MANIFEST_OK=12` | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 \| grep -c ': OK$'` | `12` |
| vendored files | `PATH_EXTRA=0 PATH_MISSING=0` | `cd …/upstream && find . -type f \| wc -l` | `12` |
| cards | `CARDS=13` | `ls corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `13` |
| clone HEAD | `CLONE_HEAD=<pin>` | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ad…b297` |
| label census | `12 / 1 / 0` | hand-read first label line of each of the 13 cards | `12 / 1 / 0` ✓ |

All five agree. `verified-here`. The hand-read (§7) also confirms the one `unproven-runtime`
card is `actors-scene.md` and that the 12 `static-only` cards use four different label
formats — the gate's scan rule tolerates all four, as documented.

**Pointer count 40 vs 37 — reconciled, not a defect.** `POINTERS=40` counts, per file, the
distinct `upstream/<path>:<line>` strings in that file and sums; my first hand count of `37`
de-duplicated **globally**. The globally distinct set is indeed `37`
(`… | sort -u | wc -l` → `37`) and the 16 non-`upstream/` markdown files hold them
(`adaptation-kimi.md` 17, `sequencer.md` 7, `ui-umg-slate.md` 7, `assets-content.md` 6,
`editor-general.md` 2, `vfx-niagara-dataflow.md` 1 = 40 file-local distinct occurrences across
37 global distinct pointers). Both numbers are right about different things.

---

## 2. Read-only over the pinned tree — PASS

`strace -f -qq -e trace=openat,creat,unlink,unlinkat,rename,mkdir,connect,socket` over a full
run (`/tmp/seat19-strace.txt`, 460 572 bytes), then filtered. `verified-here`.

**Every** access to a path under the lane root is read-only, and the pattern is exactly what
the gate claims (checks 1–4):

```
$ grep -E 'openat|creat|unlink|rename|mkdir' /tmp/seat19-strace.txt \
    | grep '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin' | head
25362 openat(AT_FDCWD, "…/.git/HEAD", O_RDONLY) = 3            # LANE_HEAD probe
29239 openat(AT_FDCWD, "…/unreal-mcp/upstream/.claude-plugin/plugin.json", O_RDONLY) = 3
29302 openat(AT_FDCWD, "…/unreal-mcp/upstream/CODEOWNERS", O_RDONLY) = 3
… (12 vendored files, all O_RDONLY) …
29912 openat(AT_FDCWD, "…/unreal-mcp/executability", O_RDONLY|…|O_DIRECTORY) = 4
29950 openat(AT_FDCWD, "…/unreal-mcp/executability/actors-scene.md", O_RDONLY|O_NOCTTY) = 3
… (13 cards, all O_RDONLY) …
$ grep -cE '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin' /tmp/seat19-strace.txt
85
```

Of those 85 hits, **not one** carries a write flag. The only three tracked-tree opens that are
not `O_RDONLY` on a content file are `…/.git/HEAD` reads for the `LANE_HEAD=` banner — and even
those are `O_RDONLY`. `git -C "$SUB" rev-parse --show-toplevel` (line 42) and
`rev-parse HEAD` (line 43) are read-only git plumbing; `git status`/`git clone` are never run
against the lane tree, only against `$WORK/clone`.

Writes are confined to `$WORK` (`run_gate.sh:47` `WORK=$(mktemp -d)`) and removed by
`run_gate.sh:48-49` (`cleanup(){ rm -rf "$WORK"; }; trap cleanup EXIT`). Observed write
targets, all under `/tmp/tmp.IuDNrYXLoY/`:

```
25405 mkdir(".claude-plugin", 0777)                                  # inside the fresh clone
25405 openat(AT_FDCWD, "LICENSE", O_WRONLY|O_CREAT|O_EXCL, 0666) = 4 # git checkout of the clone
31752 unlinkat(4, "clone-files.txt", 0)                              # trap cleanup
31752 unlinkat(6, "unreal-skill", AT_REMOVEDIR) = 0
```

The relative names (`mkdir(".claude-plugin")`, `openat("LICENSE")`) are resolved against the
`git clone` child's cwd, i.e. `$WORK/clone`; the absolute-path census confirms no write path
outside `/tmp/`:

```
$ grep -oE '"[^"]+"' /tmp/seat19-strace.txt | grep -E 'O_|/tmp/' | sort -u | head
"/tmp/tmp.IuDNrYXLoY"
"/tmp/tmp.IuDNrYXLoY/clone"
"/tmp/tmp.IuDNrYXLoY/clone-files.txt"
"/tmp/tmp.IuDNrYXLoY/clone/.git/config"
…
```

Post-run proof that nothing in the pinned tree moved:

```
$ git status --porcelain corpus/knowledge/unreal-mcp/upstream/ | wc -l
0
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK$')
12
```

`verified-here`. **No mutation of `upstream/`, `.manifest.d/`, or `executability/` by the gate.**

### 2.1 Caveat — `mktemp -d` follows the ambient `TMPDIR`

`run_gate.sh:47` is an unqualified `mktemp -d`, so the scratch tree lands wherever the caller's
`TMPDIR` points. `verified-here`:

```
$ TMPDIR=/tmp/seat19-hole4.CfWT/faketmp bash -c 'W=$(mktemp -d); echo "[$W]"'
[/tmp/seat19-hole4.CfWT/faketmp/tmp.t5qd2Ot5ra]
```

Consequence: a caller who runs the gate with a `TMPDIR` inside the repo would place the clone
under the lane tree — the gate's own writes would then be "inside the subtree". The gate cannot
control the caller's `TMPDIR`, and `mktemp -d` is still mode-`0700`; this is a hygiene note, not
a defect. It matters only because the read-only claim in §2 is conditional on a sane `TMPDIR`.
`static-only`.

---

## 3. Network and secrets — PASS

### 3.1 Network: one clone, one destination

`verified-here`. The only sockets in the trace are the clone's, and the only outbound TCP
connect is to GitHub over 443:

```
$ grep -E 'connect\(|socket\(' /tmp/seat19-strace.txt
25427 socket(AF_INET6, SOCK_DGRAM, IPPROTO_IP) = 5
25444 connect(5, {sa_family=AF_UNIX, sun_path="/run/systemd/resolve/io.systemd.Resolve"}, 42)
25444 connect(5, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("127.0.0.53")}, 16) = 0
25427 socket(AF_INET, SOCK_STREAM|…|SOCK_NONBLOCK, IPPROTO_TCP) = 5
25427 connect(5, {sa_family=AF_INET, sin_port=htons(443), sin_addr=inet_addr("4.228.31.150")}, 16) = -1 EINPROGRESS
```

The two `AF_UNIX` connects to `/run/systemd/resolve/io.systemd.Resolve` and the `AF_INET` DNS
query to `127.0.0.53` are the resolver's own machinery, triggered by the clone. There is no
second destination, no `POST`, no upload. The clone target is the pinned public repo
(`run_gate.sh:27` `REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`),
wrapped in `timeout 180` (line 86). A clone failure prints
`FAIL fresh clone failed … BLOCKED, not PASS` (line 112) and fails the check — network absence
is a red gate, never a silent pass. `verified-here`.

**Read-only reference confirmed:** the clone is fetched, never pushed; `git push`/`fetch`/`remote`
never appear. `static-only` (by inspection of the 200-line script — the only `git` invocations
are `rev-parse` ×2, `clone`, `ls-files`, `status`, `show`).

### 3.2 Secrets and environment

`static-only`. Grepping the script for credential and home-directory surfaces returns only
comments about the card-label rule:

```
$ grep -nE '\$HOME|~|\.env|id_rsa|\.ssh|token|secret|password|curl|wget|ssh|scp|nc |/etc/' \
    corpus/knowledge/unreal-mcp/gate/run_gate.sh
122:#   DECLARED label is the token on the FIRST line of the card that contains any
123:#   allowed token. That line must (a) appear within the first 40 lines,
124:#   (b) be bold- or heading-marked, (c) carry exactly ONE allowed token.
```

No `$HOME`, no `~`, no credential file, no `curl`/`wget`/`ssh`/`scp`. The gate does not read
the environment at all except through `PATH` resolution (§6) and `TMPDIR` via `mktemp` (§2.1).
The clone uses whatever git credentials the ambient git config supplies, but only for a
**public, read-only** repo — the reference clone needs no auth and the gate never inspects or
forwards a credential. `verified-here` for "no secret is read by the script's own logic";
`static-only` for the git-credential note.

---

## 4. Fail-closed on missing tools — PASS

Tested by running the gate under an isolated `PATH` (`env -i PATH=…`) containing symlinks to
the real tools minus the one under test. `verified-here`.

```
$ env -i PATH=/tmp/seat19-shim/nogit bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
FAIL git not available (check 2 requires git)     # run_gate.sh:81-83
STEP=FAIL
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: FAIL (checks failed: 1)
exit=1
```

`git` missing → check 2 fails explicitly, exit 1. The guard at `run_gate.sh:81` is a real
`command -v git` test, so the failure is named, not silent.

```
$ env -i PATH=/tmp/seat19-shim/nosha bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
MANIFEST_OK=0 EXPECTED=12 FAILED=0 RC=127
STEP=FAIL
…
GATE RESULT: FAIL (checks failed: 1)
exit=1
```

`sha256sum` missing → check 1's `RC=127` and `MANIFEST_OK=0` fail the check, exit 1. **But see
§6**: this is the one place the design is fragile. Check 1 fails here only because the count is
compared (`[ "$C1_OK" -eq 12 ]`) and the command's exit status is compared (`[ "$C1_RC" -eq 0 ]`).
Check 2's blob loop (lines 103-110) has **no** such guard, and reports `BLOB_DIFFS=0` in the
very same run above — see §6.

**Missing-`executability/` and symlink cases** (extra fail-closed probes I added):

```
$ # executability/ renamed away
CARDS=0 EXPECTED=13 BAD=0      → STEP=FAIL, exit=1

$ # one card replaced by a symlink to the same file outside the tree
CARDS=12 EXPECTED=13 BAD=0     → STEP=FAIL, exit=1
```

`find -type f` (line 130) correctly refuses to follow the symlink, so a card swapped for a
symlink is caught as a missing card. `verified-here`.

---

## 5. Negative controls — the gate discriminates

All three controls documented in `gate/README.md` were run on copies, plus two more.
`verified-here`.

| # | mutation (on a copy) | expected | observed | exit |
|---|---|---|---|---|
| C1 | append `\n` to `upstream/README.md` | CHECK 1 fails | `MANIFEST_OK=11 FAILED=1 RC=1`; also `BLOB_DIFFS=1` | `1` |
| C2 | `rm upstream/LICENSE` | CHECK 1 + 2 fail | `MANIFEST_OK=10 FAILED=1`; `PATH_MISSING=1`; `BLOB_DIFFS=2` | `1` |
| C3 | plant `upstream/README.md:113` (112-line file) | CHECK 4 fails | `LINE-OOR … (max 112)`; `POINTERS=41 UNRESOLVED=1` | `1` |
| C4 | duplicate a label token on the label line | CHECK 3 fails | `FAIL multi-label … :: **Label:** \`unproven-runtime\` static-only`; `BAD=1` | `1` |
| C5 | repoint a manifest line at a *valid* but wrong hash | CHECK 1 + 2 fail | `MANIFEST_OK=11`; `BLOB_DIFFS=1` | `1` |

C1/C2/C3 are the gate's own documented controls and all turn it red — the gate is not a
scanner that passes everything. C5 shows the two independent layers (manifest **and** per-blob
comparison against the fresh clone) catch a tampered *manifest*, which a manifest-only gate
would not. `verified-here`.

---

## 6. H-1 — PATH-shadowed `sha256sum` yields a full false green

**Severity: high for the gate's authority; low as an exploitation scenario.** `verified-here`.

### The mechanism

`sha256sum` is invoked **unqualified** at `run_gate.sh:58` (check 1) and `run_gate.sh:105-106`
(check 2, both sides of the blob comparison). There is no `command -v` guard, no absolute path,
and no `PATH` hardening (`set -u` is the only shell option, line 24 — no `set -e`, no
`pipefail`). A `sha256sum` that is found earlier on `PATH` therefore controls both the manifest
verdict and the blob-identity verdict.

### The receipt

Stub used (faithfully replays the manifest as `OK` and prints nothing in hashing mode, so the
blob comparison degrades to empty-vs-empty equality):

```sh
#!/usr/bin/env bash
if [ "${1:-}" = "-c" ]; then
  while IFS= read -r l; do
    case "$l" in ''|'#'*) continue;; esac
    printf '%s: OK\n' "${l#*  }"
  done < "$2"
  exit 0
fi
exit 0
```

Run against a copy whose vendored bytes were altered (`483693ad0e14d027…` → `30510fe2fcf72bda…`):

```
$ printf '\n### ATTACKER PAYLOAD ###\n' >> "$T/sub/upstream/README.md"
copy after tamper: 30510fe2fcf72bda
$ env -i PATH=/tmp/seat19-evil bash "$T/sub/gate/run_gate.sh"; echo "EXIT=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

**A tampered tree returns exit 0 with an all-`PASS` transcript that is byte-for-byte what a
clean tree prints.** The tamper is not detected — worse, the transcript *asserts* the exact
`MANIFEST_OK=12 … BLOB_DIFFS=0` values a verifier is told to expect.

### Not merely an `env -i` artifact

The same false green is reachable from an ordinary, inherited `PATH` — no `env -i` needed. Put
the stub in a directory on `PATH` ahead of `/usr/bin` (here: the invocation directory) and the
gate passes a tampered tree:

```
$ ( cd "$T/sub" && PATH="$T/evilbin:$PATH" bash gate/run_gate.sh; echo "EXIT=$?" )
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

This is the realistic shape: a bare `sha256sum` next to the corpus, or any earlier `PATH`
entry, is enough. It is the same class of defect SEAT-19 found in r101 in the vendored hook —
unqualified `basename`/`dirname`
(`reports/round-101/r101-sentinel.md`, finding **S-5**).

### Why the missing-`sha256sum` run (§4) did not expose it

With `sha256sum` genuinely absent, check 1 fails because its **count and exit status** are
compared (`[ "$C1_RC" -eq 0 ] && [ "$C1_OK" -eq 12 ]`, line 65). Check 2 has no equivalent
guard: `a=$(sha256sum …)` and `b=$(git … | sha256sum)` both expand to the empty string, `[ "$a" = "$b" ]`
is true, and it prints `BLOB_DIFFS=0`. It escaped a false PASS in that run only because check 1
had already failed. A stub that *succeeds* while lying — as above — defeats both checks at once.

### Aggravating factor — the stub's own output is counted

`C1_OK` is `grep -c ': OK$'` over the command's stdout (line 61). A shadowing stub that emits
`: OK` lines therefore satisfies the count as well as the exit status. My first stub attempt
(`exit 0`, no output) accidentally printed 18 `OK` lines by replaying the file's comment lines,
which is how this was noticed; the accurate stub above prints exactly 12 and passes cleanly.

### Two other limits worth recording (not defects)

- **A card's *body* is not inspected.** Appending fabricated evidence to
  `executability/sequencer.md` while leaving its label line intact yields
  `CARDS=13 BAD=0`, `CENSUS 12/1/0`, `GATE RESULT: PASS`, `exit=0`. This is *documented* in
  `gate/README.md` §"What this gate does not do" — check 3 is mechanical, and the semantic
  question ("does this `static-only` card rest on a static check that ran here?") is a
  read-the-cards judgement. Recorded because a green gate must not be read as certifying card
  *content*. `verified-here` for the observation; the limitation is the author's stated one.
- **`LANE_HEAD` is cosmetic.** `run_gate.sh:42-44` prints `LANE_HEAD` only when `$SUB` is inside
  a git worktree, and nothing compares it to a pin or to the `1659c036` work commit. A gate run
  from a different lane HEAD prints a different banner and still passes. Not a defect — the
  gate's claim is about bytes, not about which commit they sit on — but the banner should not be
  read as a provenance check. `static-only`.

---

## 7. Card census, read by hand

`verified-here`. First label-bearing line of each of the 13 cards (`grep -nE` on the label
vocabulary, `head -1`):

| card | declared label | line | format |
|---|---|---|---|
| `actors-scene.md` | `unproven-runtime` | 5 | `**Label:** \`…\`` |
| `animation-controlrig.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `assets-content.md` | `static-only` | 15 | `` **`…`** `` |
| `blueprints.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `editor-general.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `gameplay-gas.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `materials.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `meshes-textures.md` | `static-only` | 4 | `**Label:** \`…\`` |
| `scripting-programmatic.md` | `static-only` | 5 | `**Verdict label: \`…\`**` |
| `sequencer.md` | `static-only` | 5 | `**Label:** \`…\`` |
| `testing-automation.md` | `static-only` | 5 | `**Label:** \`…\`` |
| `ui-umg-slate.md` | `static-only` | 5 | `**Verdict:** \`…\`` |
| `vfx-niagara-dataflow.md` | `static-only` | 6 | `Verdict: **\`…\`**` |

13 cards, census `12 static-only / 1 unproven-runtime / 0 verified-here` — matches
`EXPECTED_*` at `run_gate.sh:30-33`. All labels sit at line ≤ 15 (well inside the ≤ 40
window), all are bold- or heading-marked, all carry exactly one token. Four distinct
formats, all tolerated by the scan rule — consistent with `gate/README.md`'s description.

**No `verified-here` card, correctly.** Unreal Editor is not installed; a `verified-here` card
would be a red flag, and the pinned `EXPECTED_VERIFIED=0` makes the gate fail on one (observed
in the tamper run in §6, where a planted `verified-here` card pushed `CENSUS` to `11/1/1` and
failed check 3 — the census pin works).

**No Unreal runtime claim in this report.** Every statement above is about static artifacts on
this host. Live-editor behavior remains `unproven-runtime` by construction.

---

## 8. Relationship to sibling gate findings

Two other seats audited the same 200-line file concurrently, with different axes. Their
findings are **complementary, not duplicative**, and the distinction matters for the fix:

| finding | seat | failure mode | tool state | false green? |
|---|---|---|---|---|
| F1 pointer-regex narrowness | SEAT-21 `adversary-b.md` §F1 | pointer silently skipped | tool present | no |
| F2 `comm` absent → `PATH_EXTRA/MISSING=0` | SEAT-21 `adversary-b.md` §F2 | check 2 vacuously equal | tool **missing** | yes (stray file) |
| F3 `find` absent → `POINTERS=0` | SEAT-21 `adversary-b.md` §F3 | check 4 sweeps nothing | tool **missing** | no (aggregate exit 1) |
| **H-1 `sha256sum` shadowed → all-`PASS`, exit 0** | **this seat §6** | check 1 **and** check 2 both lie | tool present but **lying** | **yes (altered bytes)** |

F2 and H-1 are different mechanisms: F2 is a tool that is *absent* (empty output), H-1 is a
tool that is *present and lying* (fabricated output). `adversary-b.md` §F2 recommends guarding
with `command -v comm sha256sum` (its lines 127-131, 149-150). That guard does **not** close
H-1 — a shadowing stub satisfies `command -v`:

```
$ env -i PATH=/tmp/seat19-guardtest bash --noprofile --norc -c \
    'for t in git comm sha256sum; do command -v "$t" >/dev/null 2>&1 \
     && echo "guard PASSES: $t -> $(command -v $t)" || echo "guard FAILS: $t"; done'
guard PASSES: git -> /tmp/seat19-guardtest/git
guard PASSES: comm -> /tmp/seat19-guardtest/comm
guard PASSES: sha256sum -> /tmp/seat19-guardtest/sha256sum
```

So the two fixes are additive: `command -v` closes F2/F3 (absence), and pinning the resolved
tool plus a 64-hex-character assertion on its output (recommendations 1 and 2 below) closes
H-1 (substitution). Neither subsumes the other.

## 9. Recommendations (owner: the gate's author, SEAT-17; not applied here)

Neither fix is in this seat's file. Both are one line; the first closes H-1.

1. **Pin the hash tool.** Resolve `sha256sum` once, near the top, with a fail-closed guard —
   e.g. `SHA=$(command -v sha256sum) || { printf 'FAIL sha256sum not available\n'; exit 1; }`
   — and call `"$SHA"` at lines 58, 105 and 106. (Or `/usr/bin/sha256sum` with a `command -v`
   check.) Same treatment for `git` (already guarded for check 2) and for `comm`/`find` if the
   threat model includes a hostile `PATH`.
2. **Guard check 2's blob comparison.** Assert the hash tool produced 64 hex characters before
   comparing, so `"" = ""` cannot read as identity:
   `case "$a$b" in *[!0-9a-f]*|"") printf 'FAIL hash tool failed\n'; C2_PASS=0;; esac`.
3. *(Optional)* `mktemp -d` → `TMPDIR=${TMPDIR:-/tmp} mktemp -d` with an assertion that `$WORK`
   is not inside `$SUB`, so §2's read-only claim holds regardless of the caller's `TMPDIR`.
4. *(Optional)* State in `gate/README.md` that `PASS` presumes an untampered host toolchain —
   the gate is not a defence against a compromised `PATH`.

---

## 10. Scope discipline — what this seat did and did not touch

- **Wrote exactly one file:** `reports/round-102/gate/sentinel.md` (this report).
- **Wrote nothing** in `corpus/knowledge/unreal-mcp/` — no edit to `gate/run_gate.sh`,
  `gate/README.md`, `upstream/`, `.manifest.d/`, `executability/`, `README.md`, or
  `PROVENANCE.md`. All mutations ran on `mktemp` copies under `/tmp/`.
- **No** `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`,
  or `reports/round-101/**` write. No git commit/checkout/reset.
- **Pinned tree verified clean after all testing:** manifest `12/12 OK`, `git status` on
  `upstream/` empty.
- `shellcheck corpus/knowledge/unreal-mcp/gate/run_gate.sh` → exit `0` (informational; the
  gate's own scope note says shellcheck is not one of its four checks).
- **An incident observed, outside this seat's ownership:** `/tmp/advgate/attacks3.sh` (a sibling
  seat's adversarial harness) contains `cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
  at lines 13 and 20 and then writes tampered content to
  `corpus/knowledge/unreal-mcp/upstream/README.md` — an absolute-`cd` escape that mutates the
  **real pinned tree** instead of its `$W` copy. It raced with this seat's `cp -r` at 14:43Z and
  produced one invalid observation, which I discarded and re-ran. The tree self-healed and is
  clean now (`483693ad0e14d027…`), but the harness is a live hazard to the byte-pinned subtree
  and its owner should be told. I did not edit it (not my file).

## 11. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# baseline — expect 4 × STEP=PASS and exit 0
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"

# read-only proof — every tracked-tree open is O_RDONLY, all writes under /tmp
strace -f -qq -e trace=openat,creat,unlink,rename,mkdir,connect,socket \
  -o /tmp/gate-strace.txt bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
grep -E 'openat|creat|unlink|rename|mkdir' /tmp/gate-strace.txt \
  | grep '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin'

# fail-closed — missing git or sha256sum must exit 1, never silently pass
env -i PATH=/tmp/seat19-shim/nogit  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
env -i PATH=/tmp/seat19-shim/nosha  bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"

# H-1 — a PATH-shadowed sha256sum returns a full false green on a tampered copy
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf '\npayload\n' >> "$T/sub/upstream/README.md"
env -i PATH=/tmp/seat19-evil bash "$T/sub/gate/run_gate.sh"; echo "exit=$?  # 0 = false green"
```

`/tmp/seat19-evil` is the stub directory built in §6; `/tmp/seat19-shim/{full,nogit,nosha}` are
the isolated-`PATH` trees built in §4. Both are reproducible from the snippets above.
