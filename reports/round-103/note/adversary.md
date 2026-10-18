# r103 SEAT-04 — NOTE-ADVERSARY

**Question put to this seat:** argue that the `adaptation-kimi.md` freshness fix should be a
**separate addendum file** rather than edits to the table rows (historical-record preservation);
deliver a **ruled recommendation** citing the correction-note discipline precedents (r22 lesson,
r102 lesson D1).

- Host / lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816`
- Probe date: **2026-10-18**
- Owned path: `reports/round-103/note/adversary.md` (only file this seat wrote)
- Label vocabulary: `verified-here` = a command run on this host with the output pasted below.
- No Unreal runtime claim is made anywhere here: the editor is not installed, so live-MCP behavior
  stays `unproven-runtime`. Nothing here touches the plugin pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 0. Ruling (short form)

**The argument's conclusion is ADOPTED for the *rows* and PARTLY REJECTED for the *placement*.**

| # | Ruling | Status |
|---|---|---|
| **R1** | **No row is ever edited.** The fix must be append-only / addendum-form. | **ADOPTED — mandatory.** Already honored by the landed note. |
| **R2** | The addendum should live **outside** the byte-pinned subtree, as its own file, with a short forward pointer left in the table. | **ADOPTED as preferred form.** |
| **R3** | The *landed inline-append* form is **acceptable, not a defect** — provided two conditions hold (no in-subtree pointer to a not-yet-existing file; no bare line number for a moving target). | **ACCEPTED WITH CONDITIONS.** |
| **R4** | The gate's `POINTERS=` count is a **moving surface** (87 → 88 → 89 → 90 → 91 in one round) and must be reported as such, not as a fixed expectation. | **ADOPTED.** |

The decisive finding is not aesthetic. **The landed note moved the gate from PASS to FAIL and back
to PASS with no edit to the gate at all** — purely by adding one cross-file pointer inside the
swept subtree. That makes placement a gate-relevant decision, and it is why R2 is a real
recommendation rather than a style preference. Details in §3.

---

## 1. The precedents, quoted (both directions)

### 1.1 r102 lesson law #4 — the rule R1 rests on

`corpus/lessons/r102-unreal-integration.md:206`:

> Repair by dated correction note, never by silent rewrite.

Same file, `:189-193`, describes the repair of the r22 lesson as exactly this shape — the
correction was appended, and the file's own text records that a bare `grep` cannot distinguish
"fixed" from "fixed and documented":

> Precisely: `grep -c 'shokunin/game-dev-3d'` reads **0** in
> `corpus/artifacts/unreal-r22/README.md` and **1** in `corpus/lessons/r22-unreal-review.md` — the
> surviving hit is the r102 correction note's own quotation of the dead prefix (`:55`); a bare grep
> cannot distinguish "fixed" from "fixed and documented", so read the hit's context.

### 1.2 r102 lesson-critic D1 — the rule that forbids the *silent* fix

`reports/round-102/lesson-critic.md:426-429`:

> **D1 (blocking).** Replace "`grep -c 'shokunin/game-dev-3d'` now 0 in both r22 files" with the
> per-file counts (0 and 1) and the note that the single occurrence is the correction note's
> quotation. **Do not change the number to 1 silently — the distinction is the finding.**

Read that literally: the defect was not that the value was wrong; it was that **rewriting the value
in place would destroy the finding**. The correction had to be *visible as a correction*. That is
precisely the addendum-vs-edit distinction this seat was asked to argue, and D1 rules for the
addendum.

### 1.3 The counter-precedent, stated honestly — r22 lesson *was* edited in place

`corpus/lessons/r22-unreal-review.md:55`, inside its own dated note:

> The two command blocks in this lesson were re-rooted in r102 from a never-existent
> `.shokunin/game-dev-3d/` prefix to repo-relative paths (**mechanical conformance fix, not a
> factual change**).

So in-place editing *did* happen in the r22 lesson. This is the strongest counter to a blanket
"never touch the bytes" rule, and it must not be hidden. But note the two limiting conditions that
case actually satisfies:

1. it is accompanied by a **dated note naming the edit** (so it is not a silent rewrite), and
2. the edited file is a **lesson**, not an artifact inside a subtree the round designated as a
   byte-identity / citation anchor.

The r103 target satisfies (1) but sits on the contested side of (2). §3 shows (2) is not a
philosophical nicety: it is measurable.

### 1.4 The addendum-for-another-seat's-file precedent

`reports/round-102/math-audit.md:205`:

> **Recommendation (for the L1, not this seat's to apply):** `lesson-index.md` should carry a dated
> addendum saying the 90 became 91 when C1(b) landed. I did not edit it — it is another seat's path.

This is the third and cleanest precedent for R2: when the defect is a **stale number in someone
else's artifact**, the r102 round's own practice was to recommend a **dated addendum** rather than
edit the artifact.

---

## 2. Why the *rows* must not be edited (R1) — verified-here

The current worktree state of the target file, measured at this seat's probe time:

```bash
$ F=corpus/knowledge/unreal-mcp/adaptation-kimi.md
$ echo "HEAD:     $(git show HEAD:$F | wc -lc)  $(git show HEAD:$F | sha256sum | cut -d' ' -f1)"
HEAD:       363 21744  e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981
$ echo "worktree: $(wc -lc < $F)  $(sha256sum $F | cut -d' ' -f1)"
worktree:   506 29976  084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879
$ git diff --numstat $F
143     0       corpus/knowledge/unreal-mcp/adaptation-kimi.md
```

**`143 insertions, 0 deletions`.** The landed freshness note is a pure append: every byte of the
r101 record survives, including the stale `config.toml:2932-2937` in row 2 (`:35`) and every
unprefixed docs URL. That is R1 already satisfied, and it is the right call — the alternative
(editing row 2's pointer to `3290`) would have been the exact silent rewrite D1 forbids.

The reason row edits are *especially* wrong for this particular file is that **18+ citations of it
by line number exist across the repo**, and several were already dead before r103:

```bash
$ grep -rnoE 'adaptation-kimi\.md:[0-9]+(-[0-9]+)?' --include='*.md' . | wc -l
51
$ for n in 22 267 303; do printf ':%s -> [%s]\n' "$n" "$(sed -n "${n}p" $F)"; done
:22 -> []
:267 -> []
:303 -> []
```

All three r101 line-number citations resolve to **blank lines today**. Editing the table in place
would move every downstream line number again; appending below line 363 moves none of them
(`363` is still the r101 record's last line). **Append-only is the only form that is both
discipline-correct and line-number-safe.** This is R1, verified.

---

## 3. The load-bearing new evidence: the note flipped the gate, with no gate edit

This is the finding that decides R2. It is a timing-drift artifact, and I am reporting it as such —
not as a defect in any seat's work. But it is a hard, reproducible fact about *where the note sits*.

### 3.1 Sequence (all measured today, all `verified-here`)

| Time | State | Gate result |
|---|---|---|
| 15:31 | sibling gate seat's run, `reports/round-103/gate/clean.raw.txt` | `POINTERS=88 … UNRESOLVED=0` / **PASS** |
| 15:32 | freshness note landed in the subtree; it cites `reports/round-103/note/author.md` at `:372`; that file **did not exist yet** | `POINTERS=89 … UNRESOLVED=1` / **FAIL (exit 1)** |
| 15:33 | sibling seat wrote `reports/round-103/note/author.md` | `POINTERS=90 … UNRESOLVED=0` / **PASS (exit 0)** |
| 15:33+ | I wrote this seat's own note; a sibling then began editing `gate/README.md` (a **swept** file) | `POINTERS=91 … UNRESOLVED=1` / **FAIL**, then `UNRESOLVED=0` again once the cited path landed |

The last row is the same mechanism firing a second time, in the opposite direction: the transient
`UNRESOLVED=1` appeared while a sibling was mid-edit on a swept file, and cleared on re-run once the
target existed:

```bash
$ timeout 300 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'POINTERS|GATE RESULT'
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)
$ timeout 300 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'POINTERS|GATE RESULT'
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

So a single seat's *read* of the gate is not stable during a multi-seat round: `POINTERS` moved
**88 → 89 → 90 → 91** and `UNRESOLVED` toggled **0 → 1 → 0 → 1 → 0** across roughly two minutes of
this seat's work, with `gate/run_gate.sh` byte-identical to HEAD throughout. The gate's own README,
edited concurrently by the C2 seat, independently reaches the same conclusion:

> **Expected (re-measured 2026-10-18T18:33Z …):** `POINTERS=90 … UNRESOLVED=0`, then `STEP=PASS`
> (pass A = 40, pass B = 50). … The binding invariant is `UNRESOLVED=0`; the count is an advertised
> measurement, not a contract. It is also self-referential — **editing this README's own prose
> changes it**, because sweep B (below) counts this file.

That is R4, confirmed from two independent directions.

The middle row, run by me from the repo root:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/r103_seat04_live_gate.txt 2>&1; echo "exit=$?"
exit=1
$ grep -nE 'MISSING|UNRESOLVED|GATE RESULT' /tmp/r103_seat04_live_gate.txt
50:MISSING-PATH-REL reports/round-103/note/author.md
51:POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
54:GATE RESULT: FAIL (checks failed: 1)
```

And the final row, after the sibling file landed:

```bash
$ timeout 300 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/s04_gate_now.txt 2>&1; echo "exit=$?"
exit=0
$ grep -nE 'MISSING|UNRESOLVED|POINTERS|GATE RESULT' /tmp/s04_gate_now.txt
50:POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
53:GATE RESULT: PASS (checks failed: 0)
```

**`gate/run_gate.sh` was byte-identical to HEAD throughout** (`git diff --stat HEAD --
corpus/knowledge/unreal-mcp/gate/run_gate.sh` → empty). The red and the green differ by nothing but
the existence of one file referenced from inside the swept subtree.

### 3.2 Why this happens — the mechanism, not an accident

CHECK 4's second sweep walks `find "$SUB" … -name '*.md'` (i.e. everything under
`corpus/knowledge/unreal-mcp/`) and resolves every backtick-wrapped `reports/*` or `corpus/*` path
against the **repo root**:

```bash
$ grep -n 'MISSING-PATH-REL\|find "\$SUB"' corpus/knowledge/unreal-mcp/gate/run_gate.sh
   ...  done < <(find "$SUB" -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.markdown' \) | sort)
   ...  [ -e "$base/$ptr" ] || { printf 'MISSING-PATH-REL %s\n' "$ptr"; P_BAD=$((P_BAD+1)); }
```

So a file **inside** the subtree can create a gate failure by naming a file that does not exist
**outside** it, in another seat's directory, at a moment when that seat has not yet written it. The
r22 and r102 lesson correction notes carry the same kind of cross-file pointer, but they live at
`corpus/lessons/` — **outside `$SUB`** — so they are never swept. That is the structural difference,
and it is the whole of R2.

A second, sharper consequence of the same mechanism: `reports/round-103/` is **untracked**:

```bash
$ git ls-files reports/round-103 | wc -l
0
$ git status --porcelain reports/round-103
?? reports/round-103/
```

The gate runs against the **working tree**, so `reports/round-103/note/author.md` resolves and the
gate is green *here*. In a fresh clone of HEAD, that path does not exist and the same gate over the
same committed subtree bytes would fail. The note's PASS therefore depends on untracked local
state — which is worth one line in the round report regardless of which placement is chosen.

### 3.3 The measured cost of an in-subtree addendum

| Placement | Gate sweep-set membership | Cross-file pointer risk | sha256 identity |
|---|---|---|---|
| **Inside `corpus/knowledge/unreal-mcp/`** (landed) | swept by CHECK 4 | every backtick `reports/*` path becomes a gate failure mode | table record and correction share one digest |
| **Outside, e.g. `corpus/lessons/r103-*.md`** | not swept (outside `$SUB`) | none | record digest (`e0f8ca9b…`) stays the frozen r101 artifact |

Note that `adaptation-kimi.md` is **not itself sha256-pinned**:

```bash
$ grep -c 'adaptation-kimi' corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 | grep -v ':0' || echo "NO manifest entry"
NO manifest entry (file itself not sha-pinned)
```

So editing/appending it does **not** break CHECK 1 or CHECK 2 — the 12 pinned `upstream/` blobs are
untouched (`MANIFEST_OK=12 EXPECTED=12 FAILED=0`). The objection to inline placement is *not*
byte-pin violation; it is sweep-set membership plus the loss of "which bytes are the r101 record",
which currently can only be recovered with `git show HEAD:…`. A separate file makes that boundary
visible without git.

---

## 4. Ruled recommendation

**R1 — No row edits. Mandatory.** The landed `143 insertions / 0 deletions` append is the correct
form and satisfies r102 lesson law #4 (`:206`) and D1 (`lesson-critic.md:426-429`). Do not "tidy"
row 2's pointer to `3290`; that is the silent rewrite D1 exists to forbid. Evidence: §2.

**R2 — Preferred placement: outside the byte-pinned subtree.** Land the freshness note as its own
file outside `corpus/knowledge/unreal-mcp/` (the `corpus/lessons/` location already used by the r22
and r102 correction notes), and leave a 2–3 line forward pointer in the table. Rationale, in
priority order:
1. it removes the note from CHECK 4's `find "$SUB"` walk, so a not-yet-written sibling file can no
   longer turn the gate red (§3.1, §3.2 — measured, not hypothesised);
2. it keeps `adaptation-kimi.md`'s sha256 as the frozen r101 record, so "record vs correction" is
   answerable without `git`;
3. it matches the r102 practice of recommending an addendum rather than editing another seat's
   artifact (`math-audit.md:205`, §1.4).

**R3 — If the L1 keeps the landed inline form, it is ACCEPTED and is not a defect.** The content of
the landed note is sound and I have no correction to it; in particular it already does the right
thing on the very trap this round found, by refusing a bare line number:

> **Correct citation:** "`~/.kimi-code/config.toml`, the file's sole `[[hooks]]` block (line 3290 as
> of 2026-10-18; a moving target — locate it with `grep -n '\[\[hooks\]\]'`, do not trust the
> number)".

That is the correct form, and it is independently confirmed — a sibling r103 seat measured the same
value (`reports/round-103/note/configline.md:15` → `config.toml:3290-3294`), while r102's proposed
`:3219` is already stale because the operator edited `config.toml` eight minutes after r102's
receipt (`note/configline.md` §2: file `3251 → 3322` lines, block `3219 → 3290`, content
identical). Two conditions if the inline form stays:
- **(a)** no backtick pointer inside the subtree may name a file that does not exist at commit time;
  the transient `UNRESOLVED=1` in §3.1 is the concrete cost of skipping this.
- **(b)** the moving-target citation form above is retained; never a bare `config.toml:<line>`.

**R4 — Report the pointer count as a moving surface.** The round brief's `POINTERS=87` is already
superseded. Measured in this seat's own runs, minutes apart, on an unchanged `run_gate.sh`:
the r103 gate seat's `clean.raw.txt` (15:31) read **88**; my run with `author.md` absent read **89**;
my run with it present read **90**; a later re-run read **91**. The count tracks sibling seats
editing swept files mid-round, not gate correctness. The binding invariant is `UNRESOLVED=0` — and
even that toggled during a sibling's mid-edit window (§3.1). Cite the count with a timestamp and the
scanner's sha256, never as a fixed expectation.

---

## 5. Incidental observations (outside this seat's scope; flagged, not ruled)

1. **The installed gate hardcoded `/tmp/advgate` as its scratch path — FLAGGED, then FIXED upstream
   while this note was being written.** At HEAD the line was:
   `if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/advgate/.h1 2>&1); then`
   When that directory is absent the redirect fails, the `if` is false, and the gate **FAILs a clean
   tree**. Reproduced without touching the shared directory:
   ```bash
   $ (cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/r103s04-nonexistent-dir/.h1 2>&1); echo "rc=$?"
   /bin/bash: line 1: /tmp/r103s04-nonexistent-dir/.h1: No such file or directory
   rc=1
   ```
   **Status: resolved.** The C2 seat (SEAT-09) replaced the fixed path with `mktemp` in the same
   round, with a comment naming the exact failure mode. Current worktree, verified:
   ```bash
   $ sed -n 69,70p corpus/knowledge/unreal-mcp/gate/run_gate.sh
   MANLOG=$(mktemp)
   if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >"$MANLOG" 2>&1); then
   $ git diff --stat corpus/knowledge/unreal-mcp/gate/run_gate.sh
   53 insertions(+), 8 deletions(-)   # also carries A4's BLOCKED/exit-2 branch
   ```
   I did not edit the gate; this is recorded so the flag is not re-filed as an open defect.

2. **Lane-hygiene hazard — I disturbed a concurrent seat's `/tmp` state; reported, not hidden.**
   To test the above I ran `mv /tmp/advgate /tmp/advgate_MOVED_AWAY` and back. That window
   collided with a concurrent seat's run: the leftover `/tmp/advgate/seat16-verify.txt` reads
   `bash: verify_installed.sh: No such file or directory` / `VERIFY_RC=127`. What survived the
   window: `/tmp/advgate/advgate.bak/` holds `.h1`, `hg.out` and the full 736M `hw3/` repo copy, and
   the C2 seat had **already relocated the attack suite** to `~/advgate-r103/` (`attacks.sh`,
   `evilcard.md`, `payload.md`, `clean.out`, `hg.out`, `tpl/`, `w/` — 15:33–15:34), which is the
   recommendation below already acted on. My own `/tmp/advgate_probe` and `/tmp/r103s04_pristine`
   scratch were removed. **Two independent reasons not to keep the suite in `/tmp/advgate`: the
   HEAD gate failed without it, and it is a concurrently-written shared directory.** I record the
   interference as an incident rather than presenting the suite as untouched; I cannot prove no
   other file was lost in that window, and a sibling's `VERIFY_RC=127` shows at least one run was
   affected.

3. **Disk pressure is a real operational blocker.** `/tmp` is a 16G tmpfs with 4.5G free; a
   full-tree `cp -a` of this repo dies mid-copy with `cp: error writing '…': Disk quota exceeded`
   (dozens of files, including `reports/round-103/note/author.md` and `LOG.md`). Scratch copies
   should copy only the subtree needed. I cleaned up my own.

4. **The `unity-r19` B2 repair is in flight** (`git status` → ` M corpus/artifacts/unity-r19/README.md`,
   2 insertions/2 deletions, dropping the dead `.shokunin/game-dev-3d/` root). Not this seat's path;
   noted only so the B2 seat's report is not read as contradicting the live tree.

---

## 6. Verification commands (all run; outputs in §1–§5)

```bash
F=corpus/knowledge/unreal-mcp/adaptation-kimi.md
git show HEAD:$F | wc -lc ; git show HEAD:$F | sha256sum
wc -lc < $F ; sha256sum $F ; git diff --numstat $F
grep -rnoE 'adaptation-kimi\.md:[0-9]+(-[0-9]+)?' --include='*.md' .
for n in 22 267 303; do sed -n "${n}p" $F; done
grep -c 'adaptation-kimi' corpus/knowledge/unreal-mcp/.manifest.d/*.sha256
git ls-files reports/round-103 | wc -l ; git status --porcelain reports/round-103
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh                    # exit 1, UNRESOLVED=1
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh                    # exit 0, POINTERS=90
git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sed -n 65p
(cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/r103s04-nonexistent-dir/.h1 2>&1); echo "rc=$?"
grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml ; wc -l ~/.kimi-code/config.toml
for u in customization/plugins.html customization/hooks.html customization/mcp.html configuration/config-files.html; do
  curl -s -o /dev/null -w "root %{http_code}\n" "https://moonshotai.github.io/kimi-code/$u"
  curl -s -o /dev/null -w "en   %{http_code}\n" "https://moonshotai.github.io/kimi-code/en/$u"; done
git diff --stat HEAD -- corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

URL check result (independently re-run, matches `reports/round-103/note/urls.md`):
all four root-relative docs paths **404**, all four `/en/`-prefixed paths **200**.

---

## 7. Boundaries

- **Wrote:** `reports/round-103/note/adversary.md` only. Removed my own scratch:
  `/tmp/advgate_probe`, `/tmp/r103s04_pristine`, `/tmp/r103_seat04_live_gate.txt` (kept
  `/tmp/s04_gate_now.txt`, the green re-run). **Did not write** `adaptation-kimi.md`, the gate, or
  any other seat's path; no git commit/push/checkout/reset was run.
- **Read-only on:** the byte-pinned subtree, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`,
  `reports/round-101/**`, `reports/round-102/**`, `corpus/fixtures/**`.
- **Known unowned side effect, disclosed:** the `mv /tmp/advgate …` window in §5.2.
- **No Unreal runtime claim** is made or implied: the editor is not installed on this host, so
  every editor- or live-MCP-dependent statement remains `unproven-runtime`.
- **Not in this seat's scope:** the gate hardening A1–A4 implementation (C2), the B2 systemic ruling
  (C3), and the `phys3d_joints_free_ops` battery investigation (C3). §5.1 is a *flag* for the C2
  seat, not a claim of having fixed or fully scoped it.
