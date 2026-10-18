# r103 SEAT-08 — FRESHNESS-CROSSCHECK

**Seat:** SEAT-08 `FRESHNESS-CROSSCHECK` → `reports/round-103/note/crosscheck.md`
**Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · HEAD `c85a816` · probe date **2026-10-18**
**Scope:** sweep the whole subtree for *any other* citation of (a) the moved `~/.kimi-code/config.toml`
line range and (b) the old non-`/en/` documentation URLs, and list the hits as `file:line`.
Read-only on every file outside this report.

Label vocabulary: `verified-here` = reproduced by a command run on this host, output pasted ·
`other-hit` = a second citation of the same stale target, outside the file the freshness note repairs.

---

## 0. Verdict

**Both stale classes are confined. No other *runnable* context repeats either citation.**

| Class | Other citations outside the repaired row/note | Where they live | Disposition |
|---|---|---|---|
| **A** — `config.toml:2932-2937` | **10** tracked lines | `reports/round-101/**` (5), `reports/round-102/**` (5, of which 4 are meta) | correction note; reports are historical, **do not rewrite** |
| **B** — non-`/en/` doc URLs | **0** full-URL citations; **9** bare-relative-*row* citations | 8 rows in `adaptation-kimi.md` (already noted) + 1 verbatim re-quote in `reports/round-102/reruns/pointers.md` | covered by the landed C2 note; the other 29 bare-relative hits are prose about the pages, not row citations |
| **C** — `/tmp` working trees | **254** hits in **49** files for `/tmp/ue-skills-ref`, **37** for `/tmp/r101work`, **10** for `/tmp/kimi_strings.txt` | `corpus/knowledge/unreal-mcp/**` + `reports/round-101/**` | covered by the landed C3 note |

Three findings beyond the brief, in §4:

1. **A row-set membership defect** is inherited verbatim from r102 into the landed note: the rows
   that actually carry a docs `.html` pointer are **1, 3, 5, 6, 7, 8, 10, 13** — row **8** is
   omitted and row **9** is listed though it carries no URL.
2. **No other host form is stale.** `reports/round-101/r101-reviewer-c3.md` cites the docs under a
   *different* host (`www.kimi.com/code/docs/kimi-code-cli/…`), which returns **200** — a live
   alternative base, not a third stale class.
3. **The gate cannot see either class.** `run_gate.sh`'s pointer regex covers
   `md|sh|json|sha256|py|txt` only — **zero** `.html` handling — so class A and class B are both
   invisible to it. Its `POINTERS=91 UNRESOLVED=0` PASS says nothing about either.

---

## 1. Method and patterns

Tracked-file sweep via `git grep` (742 tracked files), plus an untracked working-tree sweep with
`grep -rn --exclude-dir=.git --exclude-dir=node_modules`. `node_modules` under
`corpus/fixtures/three/` is vendored JavaScript and excluded by construction — it contains no
`kimi` or `config.toml` citations (checked: every `2932` hit there is the three.js issue URL
`issues/10439#issuecomment-293260145`).

```bash
$ git ls-files | wc -l
742
$ git grep -n -E 'config\.toml:(2932|2937|[0-9]{3,})' -- . | wc -l
13
$ git grep -n -E 'kimi-code/(customization|configuration|release-notes)/' -- . | grep -v -E 'kimi-code/(en|zh)/' | wc -l
0
$ git grep -n -E '(customization|configuration)/[a-z-]+\.html' -- . | wc -l
38
```

Four patterns, chosen to catch both the literal range and its near-variants:

| id | pattern | catches |
|---|---|---|
| P1 | `config\.toml:(2932|2937)` | the exact moved range |
| P2 | `config\.toml:[0-9]{3,}` | any 3+‑digit line pointer, i.e. the class, not just one instance |
| P3 | `kimi-code/(customization\|configuration\|release-notes)/` **minus** `kimi-code/(en\|zh)/` | the old non-locale URL form, bare or fully qualified |
| P4 | `` `(customization\|configuration)/[a-z-]+\.html `` | the bare relative form the rows actually use |

---

## 2. Class A — other citations of the moved `config.toml` range

**10 other-hit lines** (excluding the repaired row and the landed note itself). Every one is in a
`reports/round-101/**` or `reports/round-102/**` file.

```bash
$ git grep -n -E 'config\.toml:(2932|2937|[0-9]{3,})' -- . | awk -F: '{print $1":"$2}'
corpus/knowledge/unreal-mcp/adaptation-kimi.md:35     # the repaired row itself
corpus/knowledge/unreal-mcp/adaptation-kimi.md:380    # the landed C1 note
corpus/knowledge/unreal-mcp/adaptation-kimi.md:382    # the landed C1 note
reports/round-101/probes/kimi-surfaces.md:144
reports/round-101/r101-distiller.md:319
reports/round-101/r101-reviewer-c3.md:74
reports/round-101/r101-reviewer-c3.md:124
reports/round-101/r101-reviewer-c3.md:201
reports/round-102/kimi-surfaces.md:28
reports/round-102/kimi-surfaces.md:193
reports/round-102/kimi-surfaces.md:317
reports/round-102/kimi-surfaces.md:334
reports/round-102/r102-distiller.md:211
```

Grouped by what each hit *is*:

### 2.1 — r101 hits that assert the range (5 lines, `other-hit`)

These are the citations that are **void as written** in the same way row 2 was:

| file:line | as written | note |
|---|---|---|
| `reports/round-101/probes/kimi-surfaces.md:144` | `` The live hook, verbatim (`config.toml:2932-2936`): `` | **variant range** `:2932-2936`, not `:2932-2937` — P1 alone would have missed it; P2 catches it |
| `reports/round-101/r101-distiller.md:319` | `` (the `~/.kimi-code/config.toml:2932-2937` hook precedent, and live probes §3.1–3.5) `` | echo of the row-2 pointer |
| `reports/round-101/r101-reviewer-c3.md:74` | `` | host config | `~/.kimi-code/config.toml:2932-2937` | file exists; range in bounds | 4 | `` | verdict table row |
| `reports/round-101/r101-reviewer-c3.md:124` | `` row 2: OK ~/.kimi-code/config.toml:2932-2937 -> 2964 lines `` | **the number that dates it**: the file was **2964** lines then |
| `reports/round-101/r101-reviewer-c3.md:201` | `` ### SPOT-CHECK 4: ~/.kimi-code/config.toml:2932-2937    (row 2, live [[hooks]] precedent) `` | section heading |

`reports/round-101/**` is protected. The discipline is a **dated correction note**, never a silent
rewrite of a historical claim — and these five lines are exactly why: `r101-reviewer-c3.md:124`
records `2964 lines`, which is a *true* record of the file at r101 and must stay true.

### 2.2 — r102 hits that *describe* the staleness (5 lines, meta not `other-hit`)

`reports/round-102/kimi-surfaces.md:28,193,317` and `reports/round-102/r102-distiller.md:211` do
not assert `:2932-2937` as valid; they name it as the thing that went stale. `:334` is the
one-line-variant proposal. These are the *diagnosis*, so they need no correction — though see §4.1,
where `:28` and `:318` carry the row-set defect.

### 2.3 — the r102 line number is itself already stale

Not a *sweep* hit but a live finding, and it bears on which correction text is safe to land:
`reports/round-102/kimi-surfaces.md:28,318,334` and `r102-distiller.md:212` all propose **line
3219** as the replacement. On this host that is already wrong:

```bash
$ wc -l ~/.kimi-code/config.toml
3322 /home/vgpnk/.kimi-code/config.toml
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ grep -c '\[\[hooks\]\]' ~/.kimi-code/config.toml
1
$ sed -n '3219p' ~/.kimi-code/config.toml | cat -A
$
```

Line 3219 is now **blank**; the sole `[[hooks]]` block is at **3290**. Any landed correction that
hard-codes a line number is stale on arrival. The landed C1 note handles this correctly
(`adaptation-kimi.md:404-407` records the 2932 → 3219 → 3290 walk and prescribes
`grep -n '\[\[hooks\]\]'` as the durable locator); this cross-check confirms that posture is the
right one and that 3290 is the current value. Independently reproduced by
`reports/round-103/note/configline.md` (SEAT-60) — same number, same block sha256.

---

## 3. Class B — other citations of the old non-`/en/` URLs

### 3.1 — full-URL form: **zero** other hits

```bash
$ git grep -n -E 'kimi-code/(customization|configuration|release-notes)/' -- . | grep -v -E 'kimi-code/(en|zh)/' | wc -l
0
```

No tracked file writes the old URL fully qualified. The 404-returning form appears in tracked files
**only** inside the landed C2 note's own evidence block (`adaptation-kimi.md:425-431`) and inside
`reports/round-102/kimi-surfaces.md`'s evidence block (`:226-231`), both as *demonstrations* of the
404, not as citations. Nothing else in the repo points at a non-locale path.

### 3.2 — bare relative form: the rows, plus one echo

The rows carry the paths without a host (`docs \`customization/plugins.html\` §Hooks in Plugins`),
which is why P3 returns 0 while P4 returns hits. P4's **38** total hits break down as:

```bash
$ git grep -n -E '(customization|configuration)/[a-z-]+\.html' -- . | awk -F: '{print $1}' | sort | uniq -c | sort -rn
     17 corpus/knowledge/unreal-mcp/adaptation-kimi.md
     10 reports/round-102/kimi-surfaces.md
     10 reports/round-101/r101-reviewer-c3.md
      1 reports/round-102/reruns/pointers.md
```

Of those 38, **9 are row citations** (the table below); the other **29** are *prose about* the pages
— the landed C2 note's evidence block (`adaptation-kimi.md:422-432`, 9), r102's evidence block
(`kimi-surfaces.md:226-248`, 10), and r101's resolvability discussion
(`r101-reviewer-c3.md:76-293`, 10). The 9 that matter:

| file:line | row | path cited |
|---|---|---|
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:34` | 1 | `customization/plugins.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:36` | 3 | `customization/hooks.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:38` | 5 | `customization/hooks.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:39` | 6 | `customization/plugins.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:40` | 7 | `customization/plugins.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:41` | 8 | `customization/plugins.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:43` | 10 | `customization/mcp.html` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md:46` | 13 | `configuration/config-files.html` |
| `reports/round-102/reruns/pointers.md:288` | 5 | `customization/hooks.html` |

`reports/round-102/reruns/pointers.md:288` is a **re-quoted row 5** — it reproduces the row
verbatim, pointer and all, so it inherits the staleness. It is a `reports/round-102/**` file, so
again: correction note, not rewrite.

### 3.3 — the third host is live, not stale

`reports/round-101/r101-reviewer-c3.md:291,296,375,376` cite the docs under a **different base**:

```bash
$ curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 \
    https://www.kimi.com/code/docs/kimi-code-cli/customization/plugins.html
200
$ curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 \
    https://www.kimi.com/code/docs/kimi-code-cli/customization/hooks.html
200
```

That host needs **no** `/en/` prefix and is not part of the S2 class. It is worth naming in the
cross-check because a reader who sweeps for "kimi docs URLs" will hit it and may wrongly count it as
a fourth stale citation.

### 3.4 — live re-confirmation of the 404/200 split (verified-here)

Independent of the landed note, re-run here:

```bash
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html \
           configuration/config-files.html; do
>   printf 'root %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 \
>     "https://moonshotai.github.io/kimi-code/$u"
>   printf 'en   %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 \
>     "https://moonshotai.github.io/kimi-code/en/$u"; done
root customization/plugins.html -> 404
en   customization/plugins.html -> 200
root customization/hooks.html -> 404
en   customization/hooks.html -> 200
root customization/mcp.html -> 404
en   customization/mcp.html -> 200
root configuration/config-files.html -> 404
en   configuration/config-files.html -> 200
```

`curl -sL` shows the final URL is **identical to the request** in every case — a hard path move, not
a redirect, so a stale link does **not** self-heal. Corroborates `reports/round-103/note/urls.md`
(SEAT-07) §1, which reached the same conclusion on the same day.

---

## 4. Findings beyond the brief

### 4.1 — the row set is mis-stated, in r102 and in the landed note (defect)

r102 enumerates the stale-URL rows as **`1,3,5,6,7,9,10,13`** (`reports/round-102/kimi-surfaces.md:29`,
repeated at `:323`), and the landed C2 note copies that enumeration verbatim
(`corpus/knowledge/unreal-mcp/adaptation-kimi.md:418`). Scanning each row line for a docs `.html`
pointer:

```bash
$ awk 'NR>=33 && NR<=50 && $0 ~ /^\| *[0-9]+ *\|/ {row=$0; sub(/^\| */,"",row); sub(/ \|.*/,"",row);
    if (/\.html/) {m=match($0,/`(customization|configuration)\/[a-z-]+\.html`/); p=substr($0,m,RLENGTH);
    printf "row %-3s IN-SET=%s  %s\n", row, (row ~ /^(1|3|5|6|7|9|10|13)$/?"yes":"NO "), p}
    else {printf "row %-3s IN-SET=%s  (no .html)\n", row, (row ~ /^(1|3|5|6|7|9|10|13)$/?"yes":"NO ")}}' \
  corpus/knowledge/unreal-mcp/adaptation-kimi.md
row 1   IN-SET=yes  `customization/plugins.html`
row 2   IN-SET=NO   (no .html)
row 3   IN-SET=yes  `customization/hooks.html`
row 4   IN-SET=NO   (no .html)
row 5   IN-SET=yes  `customization/hooks.html`
row 6   IN-SET=yes  `customization/plugins.html`
row 7   IN-SET=yes  `customization/plugins.html`
row 8   IN-SET=NO   `customization/plugins.html`
row 9   IN-SET=yes  (no .html)
row 10  IN-SET=yes  `customization/mcp.html`
row 11  IN-SET=NO   (no .html)
row 12  IN-SET=NO   (no .html)
row 13  IN-SET=yes  `configuration/config-files.html`
row 14  IN-SET=NO   (no .html)
row 15  IN-SET=NO   (no .html)
```

- **Row 8** (`.claude-plugin/plugin.json` manifest, `adaptation-kimi.md:41`) cites
  `customization/plugins.html` §Plugin Manifest and is **missing** from the set.
- **Row 9** (`.claude/settings.json` → `enabledPlugins`, `:42`) is **listed** but carries no URL —
  its stated evidence is the §4.1 grep plus a quoted sentence, not a page pointer.

Row 9 is not *unrelated* to the page: its quoted sentence is a verbatim quotation **from**
`en/customization/plugins.html`, confirmed live —

```bash
$ curl -s --max-time 20 https://moonshotai.github.io/kimi-code/en/customization/plugins.html \
  | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'per-user[^.]{0,90}' | head -3
per-user and apply to all projects; project-level installation scope is not yet supported
```

So the two enumerations differ in *sense*: r102/the note mean "rows whose content rests on a docs
page" (that set does include 9), while P4 measures "rows that carry a `.html` pointer" (that set
includes 8, excludes 9). Both are defensible; **the defect is that the note states one and the row
scan measures the other without saying which**, and row 8 is dropped from *both* readings. The
minimal repair is a one-clause amendment to the landed note — not a rewrite:

> The rows carrying a docs `.html` pointer are 1, 3, 5, 6, 7, **8**, 10, 13. Row **9** rests on the
> same `plugins.html` page but states its evidence as a quotation rather than a pointer; r102's
> enumeration omitted row 8 and listed row 9 in the pointer set.

### 4.2 — the gate is blind to both classes (scope note)

`run_gate.sh` CHECK 4 sweeps two shapes: `upstream/…:N` pointers, and backtick-wrapped
repo-relative paths matching

```bash
grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]'
```

— `md|sh|json|sha256|py|txt`, with **no `.html`**. `grep -c html run_gate.sh` → `0`. So a stale docs
URL, and a wrong row set in prose, are both outside the gate's reach. This is not a gate defect
(the gate validates *repo-internal* pointer resolvability; an external URL is a different kind of
pointer and would need network I/O to check), but it means the gate's PASS carries no information
about class A or class B — including about §4.1. Recording it so the next seat does not read
`GATE RESULT: PASS` as coverage.

**Re-checked against the C2-hardened gate.** `run_gate.sh` was rewritten by a concurrent seat
mid-round (mtime `2026-10-18 15:35:16`, sha256 `55a76cf8…f525293`). The A1-A4 hardening does not
change this finding:

```bash
$ grep -c 'html' corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
$ grep -n 'md|sh|json' corpus/knowledge/unreal-mcp/gate/run_gate.sh
280:done < <({ grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' --include='*.md' "$SUB" 2>/dev/null; …
$ grep -n 'config\.toml' corpus/knowledge/unreal-mcp/gate/run_gate.sh
$
```

The pointer regex is unchanged (no `.html`), and there is **no** `config.toml` reference anywhere in
the gate — so it does not validate the `~/.kimi-code/config.toml` line pointers of class A either.
A1's range validation (`:a-b` / `:a,b`) applies to the *repo-internal* pointers it already scans,
which is a different pointer population from both stale classes here.

Current gate state, re-run by this seat at HEAD `c85a816` **with this report in the tree**:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'CARDS=|POINTERS=|GATE RESULT'
CARDS=13 EXPECTED=13 BAD=0
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

`POINTERS=91` is not comparable to the `87` in this round's brief: the sweep covers the working
tree, and peers' `reports/round-103/**` files have been added since (the `90 → 91` step is this
report's own added `reports/round-103/note/crosscheck.md` self-reference). An earlier run in this
seat returned `… UNRESOLVED=1` on `reports/round-103/note/author.md`, a peer's file not yet written;
once it landed `UNRESOLVED` went to 0. No defect of mine; noting it only so the number is not read
as a regression.

### 4.3 — class C (/tmp) is broad, and the `kimi_strings` pointer is a fourth variant

The brief names class C in passing; the sweep shows its breadth, so it is worth a line here.

```bash
$ git grep -c '/tmp/ue-skills-ref' -- . | awk -F: '{s+=$2} END {print s}'
254
$ git grep -c '/tmp/ue-skills-ref' -- . | wc -l
49
$ git grep -n '/tmp/r101work' -- . | wc -l
37
$ git grep -n '/tmp/kimi_strings\.txt' -- . | wc -l
10
```

In-tree (i.e. outside `reports/`), `/tmp/ue-skills-ref` appears in
`corpus/knowledge/unreal-mcp/adaptation-kimi.md` (10), `PROVENANCE.md` (9), `README.md` (3) and
thirteen `executability/*.md` files (2-10 each). All three `/tmp` paths are **currently live**:

```bash
$ ls -d /tmp/ue-skills-ref /tmp/r101work /tmp/kimi_strings_r102.txt
/tmp/kimi_strings_r102.txt
/tmp/r101work
/tmp/ue-skills-ref
$ ls -la /tmp/kimi_strings.txt
-rw-r--r-- 1 vgpnk vgpnk 80157259 Oct 18 14:14 /tmp/kimi_strings.txt
```

`/tmp/kimi_strings.txt` (the dump `adaptation-kimi.md:219-265` greps against) **is** named by the
landed C3 note at `:445`, so it is covered in principle — but the note's §4.2 re-run switches to the
vendored copy while §4's greps still point at the `/tmp` dump, so the two halves of the note cite
different substitutes for the same artifact. The durable substitute for the *strings* dump is the
binary itself (`strings -n 3 ~/.kimi-code/bin/kimi`, anchored by the sha256 the note already
records), so a one-line carry-forward is enough. Recorded because this is the one class-C pointer
the note's own remedy does not fully cover.

---

## 5. What is clean

Negative results, with the command that produced them, so the next seat need not re-sweep:

| scope | result |
|---|---|
| `corpus/live/` | no hits for class A or B — `grep -rq … \|\| echo clean` → clean |
| `corpus/fixtures/` | clean |
| `corpus/artifacts/` | clean |
| `corpus/lessons/` | clean |
| `node_modules` (vendored three.js) | no `kimi`/`config.toml` citations; every `2932` is the three.js issue URL |
| full-URL non-locale doc citations, tracked | **0** |

The four clean scopes matter because they are the ones that *run*: no battery, fixture, artifact or
lesson repeats either stale citation, so nothing outside prose is affected.

---

## 6. Reproducibility

| Artifact | Path | Note |
|---|---|---|
| this report | `reports/round-103/note/crosscheck.md` | the only file this seat writes |
| host config | `~/.kimi-code/config.toml` | 3322 lines; sole `[[hooks]]` at 3290; mtime `2026-10-18 14:50:34 -0300` |
| landed C1 note | `corpus/knowledge/unreal-mcp/adaptation-kimi.md:380-407` | read-only here |
| landed C2 note | `corpus/knowledge/unreal-mcp/adaptation-kimi.md:418-432` | read-only here |
| landed C3 note | `corpus/knowledge/unreal-mcp/adaptation-kimi.md:444-445` | read-only here |
| peer URL recheck | `reports/round-103/note/urls.md` | SEAT-07; same 404/200 verdict |
| peer line recheck | `reports/round-103/note/configline.md` | SEAT-60; same 3290 verdict |
| gate revision verified | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | sha256 `55a76cf8237bd210d1338d4eeb3dde3bb6a2a7d6ff0f42391e543f662f525293`, mtime `2026-10-18 15:35:16 -0300` (concurrent SEAT's C2 hardening) |

All sweep commands are `git grep`/`grep`/`awk` one-liners quoted in §1-§4 above; re-run them from
the lane root. No network access is needed except the four `curl` status checks in §3.4 and the one
content grep in §4.1.

### 6.1 — No Unreal runtime claim

Nothing in this report asserts anything about Unreal Editor, the MCP plugin, or live-MCP behavior.
The Unreal Editor is not installed on this host, so every such question remains `unproven-runtime`
by construction. This seat's evidence is limited to files on disk (tracked source, `reports/`,
`corpus/`) and four HTTP status codes for the docs site; the only `~/.kimi-code` reads are
`config.toml` line counts and the `[[hooks]]` block, which are host-CLI surfaces, not Unreal
surfaces.
