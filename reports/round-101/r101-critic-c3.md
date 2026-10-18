# SEAT-49 REVIEW — adversarial calibration hunt (r101)

**Round:** r101 · **Lane:** game-dev-3d-shokunin · **Axis served:** calibration (C3)
**Seat:** SEAT-49 REVIEW. **Scope:** the r101 corpus subtree — find any claim that lacks its
counting command / resolvable evidence, and any unproven-runtime claim that is not labeled.
**Mode:** adversarial. Non-author. I did not author any vendored file, manifest, card, probe,
lesson, or the subtree README. Every finding below carries a command I ran plus its observed
output.

**Snapshot (the tree mutates under concurrent seats — this is a frozen instant, not a claim
about the final state):**

```
$ date -Iseconds ; git rev-parse HEAD
2026-10-18T14:23:26-03:00
cb87233904d7041c100aab02f6d736e545b939a8
```

**Tags:** `[O]` command-run observation · `[I]` inference · `[?]` unknown.
**Evidence labels used here:** the r101 ternary — `verified-here` | `static-only` |
`unproven-runtime`.

---

## 0. Verdict

**The C1 vendoring claim survives adversarial attack. The calibration layer does not, as of this
snapshot: 11 findings — 8 open defects and 3 observed in a transient state and closed by the
time of writing.**

Open at snapshot (each with the command that shows it, re-verified at the end of the review):

- **F1** — two documented reproduction commands do not run (wrong path root; `exit=2`).
- **F2** — a cited receipt file lives under gitignored `corpus/live/` and does not exist.
- **F3** — a cited `run_battery.py` SHA matches only a historical git blob, not any tree file.
- **F4** — a numeric claim (`17 words`) does not match its own stated command (which yields 13).
- **F5** — the cited three.js command fails (`exit=1`) from a clean tree (gitignored
  `node_modules`); its "3/3" evidence string is a case count that also appears on failure.
- **F6** — a host census (no JADX/Binwalk/Unblob) is falsified: all three are now present.
- **F7** — **the label vocabulary is not shared**: 6 cards argue `unproven-runtime` is the wrong
  label for a situation the README defines as exactly `unproven-runtime`. This is the
  highest-value finding; it defeats cross-card comparison.
- **F8** — `README.md:187` says its `*.sha256` sweep prints "12 lines"; the stated glob prints 24.

Closed during the review window (recorded for the ledger, not live): F9 (the "995"→"1022"
line-count fix), F10 (`PROVENANCE.md` + `adaptation-kimi.md` landed), F11 (the
all-`unproven-runtime` index column removed).

The most serious defects are **not** in the vendored bytes — those are byte-perfect — but in the
*prose that cites them* and in the *label semantics*. Nothing found is an unlabeled live-editor
claim of the kind the brief hunts for: every C2 card carries one of the three strings and the
Unreal rows are labeled. The failure modes are **a vocabulary collision** plus **evidence
pointers that do not resolve or do not reproduce**.

**Explicit answer to the brief's two questions, as of snapshot:**
1. *Any claim lacking its counting command/evidence?* — Yes: F1, F2, F3, F4, F5, F8 (6 claims).
2. *Any unproven-runtime claim not labeled?* — No unlabeled live-editor claim found; but F6 is an
   unlabeled *host* claim that re-derivation falsifies, and F7 shows the labels that *are*
   present cannot be compared across cards.

---

## 1. What is clean (so the L1 knows what survived)

These were attacked and held. Each is a command I ran.

**1.1 Vendored bytes are byte-identical, 12/12, both directions. [O]**

```
$ cd corpus/knowledge/unreal-mcp/upstream
$ for f in $(find . -type f | sort); do
    cmp -s "$f" "/tmp/ue-skills-ref/$f" && echo "OK   $f" || echo "DIFF $f"; done
OK   ./.claude-plugin/plugin.json
OK   ./CODEOWNERS
OK   ./.gitignore
OK   ./hooks/hooks.json
OK   ./hooks/unreal-context.sh
OK   ./LICENSE
OK   ./README.md
OK   ./skills/create-toolset/SKILL.md
OK   ./skills/unreal-mcp/references/operations.md
OK   ./skills/unreal-mcp/references/setup.md
OK   ./skills/unreal-mcp/SKILL.md
OK   ./skills/unreal-skill/SKILL.md
```

Reverse direction (upstream files not vendored) printed nothing — no missing file. The clone
HEAD equals the pin:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**1.2 Manifests verify and cross-consist. [O]**

```
$ cd corpus/knowledge/unreal-mcp
$ sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK'
12
$ for f in .manifest.d/seat*.sha256; do ...  # each shard entry vs audit-reference
CONSISTENT .manifest.d/seat01.sha256 upstream/README.md
CONSISTENT .manifest.d/seat02.sha256 upstream/LICENSE
CONSISTENT .manifest.d/seat03.sha256 upstream/.claude-plugin/plugin.json
CONSISTENT .manifest.d/seat04.sha256 upstream/hooks/hooks.json
CONSISTENT .manifest.d/seat05.sha256 upstream/hooks/unreal-context.sh
CONSISTENT .manifest.d/seat06.sha256 upstream/skills/unreal-mcp/SKILL.md
CONSISTENT .manifest.d/seat07.sha256 upstream/skills/unreal-mcp/references/operations.md
CONSISTENT .manifest.d/seat08.sha256 upstream/skills/unreal-mcp/references/setup.md
CONSISTENT .manifest.d/seat09.sha256 upstream/skills/create-toolset/SKILL.md
CONSISTENT .manifest.d/seat10.sha256 upstream/skills/unreal-skill/SKILL.md
CONSISTENT .manifest.d/seat11.sha256 upstream/CODEOWNERS
CONSISTENT .manifest.d/seat11.sha256 upstream/.gitignore
```

Every file under `upstream/` is covered by `audit-reference.sha256` (the "uncovered" scan
printed nothing).

**1.3 Card numerics I spot-checked are correct. [O]** — `vfx-niagara-dataflow.md` claims
`grep -c "^- \*\*" README.md` → 17 (measured 17); `meshes-textures.md` claims 884 Markdown
lines of 1022 (measured 884 and 1022); `blueprints.md` claims 14 "blueprint" mentions across 5
files (measured 14 / 5). The `1022` line-count figure was wrong in an earlier revision of
`blueprints.md` (it read "995"); it has since been corrected — see F9.

**1.4 C2 cards carry labels. [O]** — all 13 cards present in the snapshot resolve to exactly one
of the ternary labels (12 `static-only`, 1 `unproven-runtime`). `assets-content.md` declares
its label at `:15` inside a `## Verdict` block rather than on a `**Label:**` line, and also
marks its §1–§2 provenance checks `verified-here` for the *files* while stating that this is not
a second label on the subsystem (`:29`). That is self-documenting, not a violation.

---

## 2. Findings

### F1 — Two documented reproduction commands do not run (wrong path root) [O]

`corpus/artifacts/unreal-r22/README.md:8-9` and `corpus/lessons/r22-unreal-review.md:23,25,29,42,44`
give the reproduction commands rooted at `.shokunin/game-dev-3d/`:

```
python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
```

That root has never existed in this repository:

```
$ ls -d .shokunin
ls: cannot access '.shokunin': No such file or directory
$ git log --all --format='%h' -- '.shokunin/**' | wc -l
0
```

Run verbatim from the repo root, the command fails:

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3: can't open file '.../.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2
```

Corrected path (`corpus/...`) exits 0:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept ... exit=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py \
    corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject reason=unsupported module Type: 'Unknown'  exit=0
```

**Verdict:** the *claims* are reproducible; the *documented commands* are not. A reader
copy-pasting the cited command gets exit 2. This is a calibration defect — the evidence pointer
does not resolve as written.

### F2 — A cited receipt file does not exist [O]

`corpus/lessons/r22-unreal-review.md:48` cites:

> Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4…3d8fc`

At my first check `corpus/live/` did not exist at all (it is gitignored — `corpus/.gitignore:1`
is `live/`), and the specific timestamped directory is still absent after `corpus/live/` was
recreated by a concurrent seat:

```
$ ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json
ls: cannot access '.../verdicts.json': No such file or directory
$ ls corpus/live/runs/
20261018T171756783227Z          # only a 2026-10-18 run, created by this critic's own re-run
```

Because `corpus/live/` is gitignored, this receipt is **not in the tracked tree** and never was
in a pristine clone. The citation is unresolvable by anyone who clones the repo. The digest
`a806b9e4…` is therefore uncheckable.

### F3 — A cited seed SHA resolves only to history, not to any file in the tree [O]

`corpus/lessons/r22-unreal-review.md:48` cites `run_battery.py` seed SHA
`a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`. The current file is
different:

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

The cited digest is the r21/r22-era blob (it matches `git show <r21|r22 commit>:corpus/fixtures/run_battery.py`
for `490e710d`, `8b21cae`, `7804a69`). So the number is historically *accurate* but **not
reproducible from the tree**: no tracked path currently hashes to it. The lesson presents it
alongside live commands without a "as of r22" qualifier, so a reader cannot tell the claim is
historical.

### F4 — A numeric claim whose stated command yields a different number [O]

`corpus/knowledge/unreal-mcp/executability/assets-content.md:393`:

> Its total upstream specification is **17 words on one line** (`README.md:102`; `wc -w` on the
> line's text **after the `**Assets and Content** - ` label**)

The line it names is `README.md:102`. Measured — including the command the card itself names:

```
$ sed -n '102p' README.md | sed 's/.*\*\*Assets and Content\*\* - //' | wc -w
13          # ← exactly the command the card specifies: "after the label"
$ sed -n '102p' README.md | wc -w
18          # whole line
$ sed -n '102p' README.md | sed 's/^- //' | wc -w
17          # whole line minus only the leading bullet dash
```

The card's number, **17**, is produced by stripping *only the leading `- `*, not by the command
it prints. The command it prints ("text after the `**Assets and Content** - ` label") yields
**13**. So the number and its stated method disagree by 4 words.

This defect **persisted across a revision**: at `14:16` the same bullet read "**31 words on one
line**" with no command at all; by `14:19` it had been rewritten to "17 words" *with* a command
— and the command still does not produce the number. The count is also semantically unstable:
"specification" for this subsystem is arguably the capability text (13 words), the whole line
(18), or the line-minus-dash (17); the card picks one and labels it with a different one's
command. **Verdict: the number is checkable but does not match its own citation.**

### F5 — A documented evidence command fails from a clean tree [O]

`corpus/knowledge/engines.md:11` (three.js row) cites as evidence:

> `node corpus/fixtures/three/run_cases.mjs` → 3/3

`node_modules/` is gitignored (`corpus/fixtures/three/.gitignore:1`), so from a clean checkout
the module does not resolve and the runner **fails** — and its own summary line is misleading
because "3/3" is a case count, not a pass count:

```
$ node corpus/fixtures/three/run_cases.mjs ; echo "node exit=$?"
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
node exit=1
```

After an undeclared install step it passes:

```
$ npm install --no-audit --no-fund    # in corpus/fixtures/three
added 1 package in 279ms
$ node run_cases.mjs ; echo "node exit=$?"
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
node exit=0
```

Clean-tree reproducibility re-confirmed by removing `node_modules` and re-running:

```
$ mv node_modules /tmp/r101-nm-stash && node run_cases.mjs >/dev/null 2>&1 ; echo "clean-tree exit=$?"
clean-tree exit=1
```

**Fairness note:** the cell's *Notes* column does say "`require.resolve('three')` failed from
repo root before scoped install", so the author knew an install was required — but the
*Evidence* column (the one a reader copies) gives the bare `node …run_cases.mjs` command with no
install step and no working directory. A reader who runs it in a fresh clone gets `exit=1`.

**Verdict:** the cited command does not reproduce the cited result from a clean tree unless an
install step is run first, and the "3/3" in the evidence string is a **case count that also
appears on failure**, so the string cannot be used to tell pass from fail. This is the weakest
of the six findings (the claim *is* true once installed), but it is a real
reproduction-pointer defect: the number quoted is not the number that changes on failure.

### F6 — A host census is falsified by re-derivation [O]

`corpus/knowledge/rea.md:7-9`:

> native-provider install remains blocked (no Ghidra, JADX, Binwalk/Unblob, pwntools on this
> host — census as of mint)

Re-derived on this host:

```
$ for b in ghidra jadx binwalk unblob pwntools; do printf '%-9s %s\n' "$b" "$(command -v $b 2>/dev/null || echo ABSENT)"; done
ghidra    ABSENT
jadx      /usr/bin/jadx
binwalk   /usr/bin/binwalk
unblob    /home/vgpnk/.local/bin/unblob
pwntools  ABSENT
```

Three of the four named tools (**JADX, Binwalk, Unblob**) are now present. The claim is
time-stamped "as of mint", which is honest, but it is stated as a standing host fact and is
now **false for 3 of 4 tools**. No receipt is cited for the census, so the original claim was
already evidence-less; re-derivation now falsifies it. `[O]`

### F7 — Vocabulary collision: the same label means two incompatible things [O]

The ternary is defined in one file and redefined *oppositely* in another.

`corpus/knowledge/unreal-mcp/README.md:41`:

> `unproven-runtime` | the claim needs the live editor and **nothing was observed**

`corpus/knowledge/unreal-mcp/executability/blueprints.md:113` (identical wording now appears in
**6 of the 13 cards**):

> **Not `unproven-runtime`:** that label would assert a real, identified runtime path that
> merely went untested. Here the path is not even identified … That is `static-only`.

These are irreconcilable: per the README, "needs the live editor and nothing observed" is
*exactly* `unproven-runtime`; per these six cards, that same condition is *not*
`unproven-runtime` but `static-only`. `actors-scene.md:5` then labels its card
`unproven-runtime` on a basis that matches the README definition ("every capability named for
this domain is a mutation or read of live editor session state … no part of the surface can be
reduced to a local check").

The scale of the collision, re-derived at snapshot:

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
$ for f in corpus/knowledge/unreal-mcp/executability/*.md; do
    head -8 "$f" | grep -oE 'verified-here|static-only|unproven-runtime' | head -1; done | sort | uniq -c
     11 static-only
      1 unproven-runtime
```

So 6 cards explicitly reject `unproven-runtime` on the grounds that the runtime path is
"not even identified", while `actors-scene.md` labels itself `unproven-runtime` — and the
README's own definition (`needs the live editor and nothing was observed`) fits *both* groups
equally. Neither group is provably wrong under the README wording; they are using two
different, unwritten definitions.

**Verdict:** the ternary is not a shared vocabulary. Cards with the same epistemic situation
(surface documented but unspecified; no editor on host) land on opposite labels, and each cites
a *different* definition to justify itself. This is precisely the calibration axis's job to
catch: a label whose meaning is author-local cannot be compared across cards. The round brief
requires each card be "labeled exactly one of verified-here | static-only | unproven-runtime" —
the *string* is present in every card, but the *semantics* are not stable, so the 13 labels
cannot be read as a single comparable set. **This is the highest-value finding of the review**,
because it is a live calibration defect (not a transient one) and it defeats the very
cross-card comparison C2 exists to enable.

### F8 — The README's own sweep command does not produce the 12 lines it prints [O]

`corpus/knowledge/unreal-mcp/README.md:169-187` says:

> `sha256sum -c .manifest.d/*.sha256` → all `OK`, exit `0` … Observed output of the sweep
> (**12 lines**, all `OK`)

Running the stated command yields **24** `OK` lines (the 12-entry audit reference plus the 11
seat shards, one of which — `seat11` — covers two files, so the shards total 12):

```
$ sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK'
24
$ sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK'
12
```

The displayed block is the 12-line `audit-reference.sha256` subset, but the command printed
above it is the glob. The conclusion ("all OK, exit 0") is correct; the line count does not
match the command. Minor, but it is a counting claim that does not survive its own command.

### F9 — Counting errors that were fixed mid-round (recorded for the calibration ledger) [O]

At `2026-10-18T14:13` an earlier revision of `executability/blueprints.md` read "anywhere in
the **995** vendored lines". Measured total is **1022**:

```
$ cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort | xargs wc -l | tail -1
 1022 total
```

By `14:16` the same file read **1022** in all three places. The defect is closed at snapshot;
recorded because a per-round reviewer working a few minutes earlier would have logged it, and
because it shows the subtree's numbers are being edited after publication. **No live defect.**

### F10 — Two deliverable references did not resolve, now closed [O]

At the review's first pass (`14:16`), `corpus/knowledge/unreal-mcp/README.md:109-110` listed in
its Layout block two files that did not exist:

```
├── PROVENANCE.md          ← provenance manifest (pending: authored by another seat)
├── adaptation-kimi.md     ← Claude→Kimi adaptation table (pending: another seat)

$ ls -la corpus/knowledge/unreal-mcp/PROVENANCE.md corpus/knowledge/unreal-mcp/adaptation-kimi.md
ls: cannot access '.../PROVENANCE.md': No such file or directory
ls: cannot access '.../adaptation-kimi.md': No such file or directory
```

**Both landed by `14:19`** (PROVENANCE.md 16669 B, adaptation-kimi.md 21744 B). The README was
honest throughout — it marked both "(pending)" — so this was a *concurrency* artifact, not a
false claim. C1's "provenance manifest" requirement was satisfied in substance the whole time by
`.manifest.d/audit-reference.sha256` (12/12, verified). **Closed; recorded for the ledger.**

Spot-check of the late-landing C3 deliverable: `adaptation-kimi.md` carries a 15-row
Claude→Kimi table whose every row has a Status (`verified-here` / `static-only` /
`unproven-runtime`) and a Source pointer of the form `upstream/<path>:<line>`, plus a §6
register segregating editor-dependent claims. Its pointers resolve against the vendored tree
(e.g. `upstream/hooks/hooks.json:4-5`, `upstream/README.md:39,45`). This is the C3 deliverable
the brief names and it meets the "every row carries a resolvable source pointer" bar. **[O]**

### F11 — An earlier index mislabeled all 13 cards; since corrected [O]

At `14:14` the README's card index carried a fourth column "expected verdict" reading
`unproven-runtime` for **all 13** rows, including the 8 cards that resolve to `static-only`.
At snapshot the column is gone — `README.md:204-241` now has three columns (`# | card path |
subsystem`) and states "This index does **not** restate the labels: the binding verdict and its
evidence live in each card". The mismatch is closed. Recorded because it was a genuine
index-vs-card contradiction during the window in which the cards were landing, and it is the
kind of drift a single frozen read can miss.

---

## 3. Claims examined and **not** faulted

To bound the hunt honestly, these were attacked and passed:

- `blueprints.md` §6 host receipts — re-derived: `which UnrealEditor UnrealEditor-Cmd` → both
  absent; `/opt/UnrealEngine`, `/opt/unreal-engine`, `~/UnrealEngine` → all "No such file";
  `ss -ltnp | grep :8000` → no listener; `.mcp.json` → absent. All four reproduce. `[O]`
- `blueprints.md` mention sweep — `grep -rniE "blueprint" . | wc -l` → 14; per-file 1/3/4/1/5;
  `grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+"` → exactly `BlueprintTools.create` and
  `SequencerTools.create_level_sequence`. Reproduces. `[O]`
- `vfx-niagara-dataflow.md` counts — 17 bullets in README, `niagara` 6 occurrences / 4 files,
  `NiagaraTools` ×1. Reproduces. `[O]`
- `meshes-textures.md` counts — 1022 total lines, 884 Markdown. Reproduces. `[O]`
- `engines.md` Godot row ("yes, `/usr/bin/godot`", "executable headless: yes") — `godot
  --version` → `4.7.2.stable.arch_linux.ed1daf0bf`; the lane's own battery re-ran here green
  (`python3 corpus/fixtures/run_battery.py` → all `PASS … expected=…`, exit 0). The *claim* is
  true; only its *cited receipt pointer* fails (F2-class).
- `assets-content.md:329` — reports a transient `LISTEN 127.0.0.1:8000` from a `python3` pid,
  explicitly labeled "observed-and-transient, not a standing conflict". Correctly hedged; not
  an unlabeled runtime claim.

---

## 4. Does the corpus hold any unlabeled unproven-runtime claim?

The brief asks specifically for unproven-runtime claims that are not labeled. Answer, as of
snapshot: **no unlabeled live-editor claim was found in the r101 subtree.** Every card carries
one of the three strings; `README.md` §Verification-policy labels the policy; `engines.md`
labels the Unreal row ("not installed; local JSON checks do not prove plugin load, UBT
compilation or engine runtime"); `unreal-r22/README.md` titles itself "(static only)" and says
the sample "was not loaded by Unreal Editor or UnrealBuildTool".

The defects found are adjacent to that requirement, not a violation of it:

- **F7** is the real calibration failure — the label *strings* are present but their
  *definitions* collide, so a reader cannot compare cards.
- **F6** is an unlabeled *host* claim (a tooling census) that re-derivation falsifies. It is
  not a live-editor claim, but it is an unlabeled, uncited factual assertion now known false.
- **F2/F3/F5/F8** are evidence pointers that do not resolve or do not reproduce — the
  "claim lacks its counting command/evidence" half of the brief.

---

## 5. Limits of this review

- The subtree was **mutating under concurrent seats** for the whole review (file mtimes
  `14:13`–`14:24`). F9, F10 and F11 are findings observed in a transient state and closed by the
  end of the review; **F1–F8 were all re-verified as still open at the final pass**
  (`14:24`), each with the command recorded in its section.
- I did **not** re-derive the pinned SHA by fresh clone; I used `/tmp/ue-skills-ref` after
  confirming `rev-parse HEAD` equals the pin. F1–F11 do not depend on that clone.
- I made **two untracked, gitignored side effects**, disclosed for custody: (a) running
  `python3 corpus/fixtures/run_battery.py` wrote receipts under `corpus/live/runs/`; (b)
  running `npm install` in `corpus/fixtures/three/` created `node_modules/`. Both paths are
  gitignored (`corpus/.gitignore:1`, `corpus/fixtures/three/.gitignore:1`) and appear in
  neither `git status --porcelain` nor the tracked tree. No tracked file was modified; nothing
  was committed.
- Runtime claims about Unreal Editor remain **unproven-on-this-host by construction** (editor
  not installed) and are neither made nor tested here.
- **What I did not audit:** the r70–r76 nav-agent lessons, the bpy/navagent dissection reports,
  the `corpus/predecessor/` tree, and the `corpus/fixtures/` battery seeds beyond the one
  command re-run in F5/§3. The brief scoped this seat to the r101 corpus subtree; those older
  artifacts may carry their own evidence-pointer defects of the F1/F3 class and were not swept.
