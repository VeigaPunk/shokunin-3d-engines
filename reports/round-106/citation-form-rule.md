# r106 SEAT-96 — CITATION-FORM-RULE

**Status: PROPOSED. NOT APPLIED.** This seat wrote this file only. `SKILL.md` and `AGENTS.md` were not edited. There is no `AGENTS.md` in the lane repo (`find` returned none). Do not create one to land this rule.

- Seat: SEAT-96 CITATION-FORM-RULE
- Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last; work `3634bc0`)
- Probe window: 2026-10-18, last clock read `2026-10-18T21:33:51Z`
- Target of the proposal: a future addition to `SKILL.md` (the file that already owns citation discipline). A later `AGENTS.md`, if minted, gets one pointer sentence, not a second copy of the rule.
- No Unreal runtime claim. `which UnrealEditor UnrealEditor-Cmd` → both absent, rc 2. Editor not installed. Pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` is named, not re-verified by a clone in this seat.

Axes this proposal is scored on:

- **Depth** — each clause is a form this seat measured, not a style preference.
- **Coverage** — path root, implicit cwd, host-absolute, `~/`, `/tmp`, gitignored `live/` receipts, basename+line, scanner counts, env-unpaired totals, host-file line numbers, URLs.
- **Calibration** — adopts the r106 dated-note ruling that had landed, and narrows the one premise that measurement falsifies. Does not rewrite historical facts. Does not stack a second essay into a living file.

Chunk sweep reports (`reports/round-106/sweep/`) were **absent** at `2026-10-18T21:29:25Z` (`ls` of that directory failed). This proposal is distilled from a corpus-wide form census run here, plus the one r106 ruling already on disk (`reports/round-106/consistency/adversary.md`, sha `bc6c56666159ecb0e2b560e5ffd92dd1b0519c5ebbaf1c9b71a90d4d6319a55c` at `21:33:51Z`, 365 lines). Later appends to that file are possible; cite the sha.

---

## 0. Where it lands (future seat, not this one)

Insert one new subsection in `SKILL.md` immediately after the paragraph that begins **Citation rule for mutable files** (end of §1, before §2). That paragraph stays. It is the mutable-vs-frozen half of this rule; it is not the whole rule. At probe time that paragraph is the block whose first line `rg -n 'Citation rule for mutable' SKILL.md` printed as line 51. Cite it by that heading, not by the line: `SKILL.md` sha at probe was `8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371`.

Add the signature rows in §7 below to `SKILL.md` §2. Do not open a parallel vocabulary. Do not restate the rule in `AGENTS.md`.

`SKILL.md` is protected this round. Applying this text now is a scope violation.

---

## 1. Proposed text (paste target: `SKILL.md`)

> ### Citation form
>
> A citation is admissible only if a reader at the **lane repo root**, on a fresh clone, can either resolve it or read **one dated line** that says it is historical and names the re-derivation command. The essay, the old number, and the failing command live in `reports/`. The living file does not also narrate them.
>
> **Discriminator, applied before either instrument.** Would a reader who trusts the file and never opens git be told a different fact? If yes, keep the old fact and add one dated line that points at the round report. If no — the old bytes were a path that fails from the cwd the sentence itself names, a typo, or a pointer whose checkable content is unchanged — fix the bytes and record before/after in the round report. Do not also narrate the fix inside the file. A second note on the same claim is a defect.
>
> The discriminator is the **cwd the sentence names**, not "does this string exist in this repo's git history." A command that exits 2 from the lane root and exits 0 from the predecessor worktree the lesson names was true. Rewriting it tells a different fact.
>
> **Required form**
>
> 1. **Runnable command.** Cwd is the lane repo root, or the command is written `(cd <dir> && ...)`. Paths are repo-relative (`corpus/...`, `reports/...`). No `.shokunin/game-dev-3d/` prefix in a contract whose stated cwd is this root. No bare `python3 run_battery.py` (the file is not at the root).
> 2. **Environment.** If the result depends on `node` or `PATH`, the same cell names the state: **default** (`command -v node` → mise) or **pinned** (fnm `v24.21.0` prefixed onto `PATH`, as `corpus/fixtures/PINNED-ENV.md` states). A battery total (`337/350`, `350/350`) without that state is not a census claim.
> 3. **Pointer shape.** Mutable file: section heading + sha256. Frozen artifact (`reports/round-<closed>/**`, `corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`): line number allowed. Gate: `CHECK n <name>` plus the script sha — never `run_gate.sh:NN`. Host file or binary (`~/.kimi-code/config.toml`, `strings` on `kimi`): the search command, not a line number. A basename plus a line (`README.md:41`) is not a citation: it does not name one file.
> 4. **Receipt.** `corpus/live/runs/<ts>` is evidence only while that directory exists, and only for that run. `corpus/.gitignore` ignores `live/`, so a fresh clone cannot see it. A claim that must survive the clone cites a copy under `reports/`, or is marked non-resolvable in one line. `/tmp` and `/dev/shm` are not evidence. "Exists today" is not a citation.
> 5. **Count or digest.** Name the enumeration command, the unit, and the blob or tree state. `POINTERS=` is a measurement of one scanner on one tree, not a constant. Do not replace a historical digest or pass/fail in place. Before an in-place repair of any file, run `s=$(git show HEAD:<file> | sha256sum | cut -d' ' -f1); git grep -l "$s" HEAD`. If that count is ≥1, the repair falsifies a citation and the citing record needs the one dated line.
> 6. **URL.** Retrieval date and HTTP status, or the word `unretrieved`. A 200 is not a byte pin. Prefer the vendored path when the claim is about bytes.
>
> **Disposition**
>
> | surface | old bytes true at the cwd the sentence names? | instrument |
> |---|---|---|
> | Reproduction contract — README command block, `engines.md` cell, `PINNED-ENV.md`, a `SKILL.md` canonical command — whose stated cwd is the lane root | no | silent mechanical fix; before/after in the round report; no in-file essay |
> | Lesson or review record, including a predecessor-worktree command that still succeeds there | yes | keep the command; one dated line, or report-only; do not rewrite |
> | Digest, count, or pass/fail that was true at its revision | yes | one dated line pointing at the report that holds both values; do not stack a second note; do not silently update the number |
> | Host line number already inside a correction note | the number is already dead | do not write "line N is now M"; the durable citation is the locator command |
> | Narrative of what the author consulted (`I checked <path>`) | yes, even if the path is awkward | keep; a silent retarget is a false claim |

---

## 2. Why this shape, and where it disagrees with a landed r106 ruling

`reports/round-106/consistency/adversary.md` (SEAT-47) had landed before this file was written. Its short ruling is adopted, with one narrowing.

Adopted, unchanged:

- Silent fix is right for path/command conformance when the edit changes no fact a reader could check, and the round report holds before/after (their S1).
- A dated note is mandatory when the sentence was true at its revision — a digest, a count, a census, a pass/fail (their S2). Precedent they cite, and this seat does not reopen: `corpus/lessons/r102-unreal-integration.md` hook 4, "Repair by dated correction note, never by silent rewrite."
- One note per claim per file. A second essay is the defect (their S3). `corpus/lessons/r22-unreal-review.md` already has two r102 notes on the same drift.
- A living operational file carries the current value plus at most one back-pointer. The essay lives in `reports/` (their S4). `engines.md` is 16 lines and has zero notes; do not make it the next `rea.md`.
- Fatigue is a per-file byte ratio, not a reason to stop dating factual corrections (their S5).

Narrowed:

Their S1 premise — "`.shokunin/game-dev-3d/` has never existed in this repo, so the old bytes were never a fact" — is true of **this repo's git** and false of **the cwd the lessons name**. Applying S1 to all 80 lesson files would tell a reader a different fact about what was run. That fails their own discriminator. The narrowing is the row "lesson or review record" in the table above.

The r102 in-place re-root of `corpus/lessons/r22-unreal-review.md` command blocks is the S1 precedent and stays. The silent rewrite of that file's "I checked `LOG.md`" line is the counter-example and stays a defect: it is a claim about what the author consulted, not a command block. `reports/round-103/b2/ruling.md` §3.5 already routed it. This proposal does not reopen that repair; it forbids repeating it.

Protocol clauses this rule is implementing, re-read this seat (line numbers still matched the r103 citations; cite them by heading if `PROTOCOL.md` moves):

- `~/.kimi-code/skills/shokunin/protocol/PROTOCOL.md` "Evidence standard" — an evidence pointer must resolve at closure, not only at write time; `/tmp` and `/dev/shm` are not evidence (line 341 at this probe).
- same file, line 351 — a falsified claim in an append-only file gets a named correction entry, appended, never rewritten.
- `~/.kimi-code/skills/shokunin/protocol/CORPUS.md` line 52 — corrections are new entries, never rewrites.
- Protocol sha at probe: `b1d4f4c0940522981a6ace84d8528acb0bad470ebaa69faeeb0dbd017b330c20`. CORPUS sha: `a77e2b57eb6309140b4eb4048a51731f3184706b809eff80a0084d99a9253561`.

---

## 3. Evidence (commands this seat ran)

Universe: `find corpus -name '*.md' -type f` → **223** files; `find corpus/lessons -name '*.md'` → **92**.

### 3.1 Dead relative root — cwd asymmetry, not a phantom path

```
$ git log --all --oneline -- .shokunin | wc -l
0
$ git ls-tree HEAD .shokunin | wc -l
0
$ readlink /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
../../../shokunin/game-dev-3d-shokunin
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --help
python3: can't open file '…/game-dev-3d-shokunin/.shokunin/…/run_battery.py': [Errno 2]
rc=2
$ ( cd /home/vgpnk/Projects/prymeagnt/game-dev-3d && python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --help )
parent_help_rc=0
```

The `--help` from the parent root is a resolution check, not a battery result. It is enough to show the prefix is live there.

```
$ rg -l --glob '*.md' '\.shokunin/game-dev-3d/' corpus | wc -l
80
$ rg -c --glob '*.md' '\.shokunin/game-dev-3d/' corpus | awk -F: '{s+=$2; n++} END {print n, s}'
80 files, 324 lines
```

All 80 are under `corpus/lessons/`. Outside lessons: **none** (`rg -l … --glob '!corpus/lessons/**'` printed `none_outside_lessons`). The r103 reproduction-contract repairs are still in force. The open mass is historical lesson commands.

Classifier over those 80 (runnable = line matches an executable token after stripping markdown prefixes): **79 files with runnable lines (252 lines), 1 prose-only** (`corpus/lessons/r1-headless-verification.md`). Of the 80: **19 also name `prymeagnt/game-dev-3d`**, **61 do not**, **52 say "from repo root"**. `corpus/lessons/r2-independent-review.md:3` names the working tree as `/home/vgpnk/Projects/prymeagnt/game-dev-3d` and `:7-11` says "From repo root" and then runs the prefix. That "repo root" is not this repo's root. A silent strip of the prefix would make the block reproduce here and would falsify the command the reviewer ran.

Absolute form, same class, worse because the cited scratch is gone:

```
$ rg -c --glob '*.md' '/home/vgpnk/Projects/prymeagnt/game-dev-3d/\.shokunin/' corpus
17 files, 33 lines
$ test -d /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/review-r39-private-rotation/setter-only
setter_only_rc=1
```

Example still in the tree: `corpus/lessons/r39-bone-rotation-review.md:24` (godot `--path` at that absolute scratch). Disposition: keep; one dated line. Do not invent a path.

### 3.2 Implicit cwd — a form the dead-root grep does not see

```
$ python3 run_battery.py --help
python3: can't open file '…/game-dev-3d-shokunin/run_battery.py': [Errno 2]
bare_rc=2
```

That line is `corpus/lessons/r1-headless-verification.md:15`. The file is the prose-only dead-root file; this defect is a different string.

```
$ sha256sum -c corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
sha256sum: upstream/.claude-plugin/plugin.json: No such file or directory
rc=1
(13 error lines)
$ ( cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 )
rc=0
12 × OK
```

`corpus/knowledge/engines.md:10` still prints the bare form `` `sha256sum -c .manifest.d/audit-reference.sha256` → rc=0 `` inside a cell whose reader is at the lane root. That is an implicit-cwd defect in a reproduction contract. Disposition under the rule: silent fix of the command to the `(cd corpus/knowledge/unreal-mcp && …)` form, before/after in the census report, no essay in `engines.md`. **Not applied here.** `engines.md` is owned by other seats. Live sha of that file at probe: `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` (matches the stamp in `SKILL.md` §6). `run_battery.py` sha `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (matches the brief and `SKILL.md` §6).

`SKILL.md` §2 already names **implicit-cwd command**. The addition is the acceptance command, not a new name.

### 3.3 `/tmp` is not evidence, including paths a prior round recorded as present

```
$ rg -o --glob '*.md' '/tmp/[A-Za-z0-9._@+-]+' corpus | sed 's/.*://' | sort -u | wc -l
27
```

Of those 27, **6 exist and 21 are missing** at this probe. Missing includes `/tmp/ue-skills-ref`, `/tmp/r101-closeout`, `/tmp/mission-game-dev-3d-standing.md`. r103's pathroot sweep recorded `/tmp/ue-skills-ref` and `/tmp/r101-closeout` as existing. They are gone now. That is the closure-time clause.

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: cannot change to '/tmp/ue-skills-ref': No such file or directory
ueref_rc=128
```

`corpus/lessons/r105-unreal-lifecycle.md:20` still cites `git -C /tmp/ue-skills-ref rev-parse HEAD` as the pin command. The pin string is also in the vendored tree's provenance; the `/tmp` command is not the durable citation. Disposition: one dated line pointing at the in-repo pin check, not a rewrite of the r105 sentence, and not a new line number into a missing directory.

31 corpus md files mention `/tmp/` (`rg -l`).

### 3.4 Gitignored receipts

```
$ git check-ignore -v corpus/live/runs
corpus/.gitignore:1:live/	corpus/live/runs
$ rg -o --glob '*.md' 'corpus/live/runs/[0-9]{8}T[0-9]{12}Z' corpus | sed 's/.*runs\///' | sort -u | wc -l
131
```

Of those 131 stamps, **2 directories exist, 129 do not**. All **150** distinct `20261013T…` stamps cited in corpus md are missing (`cited=150 missing=150`). `rg -l --glob '*.md' 'corpus/live/runs/' corpus` → **85 files**.

`corpus/live/runs/20261018T201215739340Z` (cited by `corpus/lessons/r105-unreal-lifecycle.md:133`) **existed** at this probe. That does not make the citation closure-durable: `live/` is gitignored. A fresh clone fails it. Durable form: the `reports/` copy, or one non-resolvable line.

### 3.5 Host line numbers die, including inside the note that warned they die

`corpus/knowledge/unreal-mcp/adaptation-kimi.md` §C1 says the `[[hooks]]` block is "line 3290 as of 2026-10-18" and tells the reader not to trust the number.

```
$ rg -n '^\[\[hooks\]\]' ~/.kimi-code/config.toml
3149:[[hooks]]
$ wc -l ~/.kimi-code/config.toml
3181
$ sed -n '1p' ~/.kimi-code/config.toml
default_permission_mode = "auto"
```

Same calendar day, the published correction is already stale. Line 1 of that file is still the permission mode, which is why a start-of-file cite can survive and a mid-file cite cannot. Disposition: the citation is `rg -n '^\[\[hooks\]\]' ~/.kimi-code/config.toml`. Do not append "3290 is now 3149". SEAT-47 exhibit D measured the same two numbers; this seat re-ran the commands rather than quoting them.

`~/` citations: **8** corpus md files. They are admissible only as host probes paired with the search, not as reproduction paths for repo files. `corpus/knowledge/rea.md:4` citing `~/.agents/skills/reverse-engineer-anything/` is that shape; this seat did not re-stat the directory.

### 3.6 Basename + line number does not resolve

```
$ rg -o --glob '*.md' '`[A-Za-z0-9_./-]+\.md:[0-9]+' corpus | sed 's/.*`//; s/:[0-9]*$//' | sort | uniq -c | sort -nr | head -1
193 README.md
$ find . -name README.md -not -path './.git/*' -not -path './corpus/live/*' | wc -l
88
```

Backtick `path:line` hits overall: **581 across 31 files**. Many of those targets are vendored upstream files (frozen; a line number is allowed **if the path is repo-relative**). A bare `README.md:NN` is not. Gate line cites inside `corpus/` and `SKILL.md`: **none** (`rg -n 'run_gate.sh:[0-9]+' corpus SKILL.md` printed `none`). Frozen `reports/round-102/**` still has them; that is history, not a living contract. `SKILL.md`'s existing "no gate line number" rule is holding. Keep it.

`POINTERS=` hits in corpus md + `SKILL.md`: **10 hits, 3 corpus files** plus `SKILL.md`. The invariant to quote is `UNRESOLVED=0` under a named scanner. This seat did not re-run the gate.

### 3.7 Environment-unpaired total

```
$ node --version
v26.12.0
$ command -v node
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ godot --headless --version
4.7.2.stable.arch_linux.ed1daf0bf
rc=0
```

`corpus/fixtures/PINNED-ENV.md:20` pairs `337/350` with the default mise `v26.12.0` path. `corpus/knowledge/engines.md:11` still says `Node v26.11.1`. Live default is `v26.12.0`. That cell is a living census claim (SEAT-47 S4: edit the row, do not append an essay). **Not applied here.**

`corpus/lessons/r105-unreal-lifecycle.md:133` says "full battery 337/350 corroboration" in a window that does not contain `default`, `pinned`, `v24.21.0`, or `v26` (classifier: `UNPAIRED`). The r104/r105 record is that 337/350 is the **default-env** total and 350/350 is the **pinned-env** total (`corpus/fixtures/PINNED-ENV.md`; receipts under `reports/round-105/n24/runs/`, not re-run by this seat). Disposition: one dated line naming the state, not a silent change of 337 to 350. Owned by the consistency seats, not this one.

### 3.8 URL

```
$ curl -sI -o /dev/null -w '%{http_code}\n' --max-time 15 \
    https://dev.epicgames.com/documentation/en-us/unreal-engine/plugins-in-unreal-engine
200
```

Retrieved 2026-10-18 by this seat. Status 200 does not pin the page bytes. `corpus/lessons/r22-unreal-review.md` already records a 2026-10-13 retrieval. That is the right shape. A URL without a date is `unretrieved`.

### 3.9 Forms checked and not defects

- One markdown link of the form `](../…)` in corpus md: `corpus/knowledge/unreal-mcp/PROVENANCE.md` → `reports/round-101/probes/license-audit.md`, resolved, exists. Parent-relative links are admissible when they resolve from the file that contains them. They are not a substitute for a repo-root path in a command.
- `corpus/lessons/r70-navagent-detour-review.md:33` `../../reports/round-70/r70-verifier.md` resolves and exists.

---

## 4. What a sweep seat may fix, under this rule

The r106 chunk contract says "FIX mechanical path-root defects" and also "dated correction notes for historical facts, never silent rewrites." Those two sentences are the same rule once the discriminator is applied. They are not a license to strip `.shokunin/game-dev-3d/` out of every lesson.

| measured class | count this seat | fix in the living file? |
|---|---|---|
| Dead prefix in lessons, command was true at the named cwd | 80 files / 324 lines; 19 name the predecessor worktree; parent-root `--help` rc 0 | **No.** One dated line or report-only. |
| Dead prefix in reproduction contracts outside lessons | 0 | already clean; if one reappears, silent fix |
| Absolute predecessor scratch in a godot `--path` | 17 files / 33 lines; sample dir missing | **No.** Keep; one line that the scratch is gone |
| Bare `python3 run_battery.py` | 1 lesson line, rc 2 | lesson: one line. A contract that says "from this root" and means this root: silent fix |
| `engines.md` bare `sha256sum -c` | 1 cell, rc 1 from root, rc 0 from subtree | **Yes, silent**, in the census owner's edit, report holds before/after |
| `/tmp` pin command in r105 lesson | rc 128 today | **No rewrite.** One line pointing at the in-repo pin check |
| 129/131 stamped `live/` receipts absent | structural (`live/` gitignored) | one non-resolvable line where a claim depends on the missing receipt; do not invent a path |
| `337/350` without an environment word | 1 lesson line (r105:133) | one line naming default-env; do not change the number |
| Host line number inside an existing note | `adaptation-kimi.md` C1, 3290 vs live 3149 | **Do not add a note.** Locator command is already in the note |

Before any silent fix, run the cited-blob test in §1 clause 5. The r103 unity README repair is the case where a mechanical path fix falsified two lesson digests. That test is what would have caught it before the note was owed.

---

## 5. Acceptance commands for the future landing

Run from the lane repo root after the `SKILL.md` edit, not before.

```sh
# the new subsection exists; the old paragraph was not deleted
rg -n 'Citation form|Citation rule for mutable' SKILL.md

# reproduction contracts do not grow the dead prefix back
rg -n '\.shokunin/game-dev-3d/' \
  corpus/artifacts corpus/fixtures corpus/knowledge/engines.md corpus/README.md \
  SKILL.md || echo 'no dead prefix in contracts'

# the admissible manifest command is the one that exits 0
( cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 )
# expect 12 × OK, rc 0

# a battery total in a living contract names its environment
rg -n '337/350|350/350' corpus/knowledge/engines.md corpus/fixtures/PINNED-ENV.md SKILL.md
```

A lesson file still containing `.shokunin/game-dev-3d/` is **not** a landing failure, if the hit is the historical command and a dated line (or a report pointer) says it does not resolve from this root. A landing that deletes those hits without that line is a landing failure.

---

## 6. Signature rows to add to `SKILL.md` §2 (names only)

The section already has `prose-cites-bytes`, `count-written-into-prose`, `implicit-cwd command`, `scanner-relative datum`, `temp-dir-dependent gate`, `binary-strings-citation`, `command-does-not-reproduce-its-printed-rc`. Add:

| signature | what it looks like | what to do |
|---|---|---|
| **cwd-asymmetric path** | command exits 2 here and 0 from the cwd the sentence names (predecessor symlink) | keep the historical command; one dated line; do not strip the prefix |
| **live-receipt-not-evidence** | `corpus/live/runs/<ts>` cited, directory absent or `live/` gitignored | cite the `reports/` copy, or one non-resolvable line; do not invent a stamp |
| **tmp-not-evidence** | `/tmp/…` cited as the way to re-derive a pin or a receipt | point at the in-repo command; "existed at write time" is not a cite |
| **host-line-number** | `~/.kimi-code/config.toml:NNNN` or "binary strings line N" | the search command; never a replacement line number in a new note |
| **basename-line-cite** | `` `README.md:41` `` with no repo-relative directory | not a citation; 88 `README.md` files exist in this tree |
| **env-unpaired total** | `337/350` or `350/350` with no default/pinned word in the same claim | one line naming the state; do not change the number to the other total |

---

## 7. Limits

- Sweep chunk reports were not on disk at `2026-10-18T21:29:25Z`. If a chunk seat later measures a form this file does not name, the rule's discriminator still applies; the form list in §3 is what this seat counted, not a claim that no other form exists.
- This seat did not re-run the gate, the battery, or a fresh upstream clone. Gate `POINTERS=103` is the brief's number, not a measurement here. Upstream pin is named, not re-fetched.
- Parent-root check was `run_battery.py --help`, rc 0. It is not a 350-case result.
- `reports/round-106/consistency/adversary.md` may still be appended by its owner. The sha above is the bytes at `21:33:51Z`.
- Scratch from the census commands is under `reports/round-106/scratch/seat96/` (host `/tmp` quota is exhausted; that directory is the authorized scratch). No corpus file was modified.
- No Unreal runtime was run.
