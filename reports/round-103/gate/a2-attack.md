# r103 · SEAT-12 · A2-ATTACK — prose-hijack against gate CHECK 3, installed vs A2-hardened

**Seat:** SEAT-12 (A2-ATTACK) · round 103 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · **Repo HEAD at run time:** `c85a816` (r102 report-last)
**Claim:** **C2 (depth)** — gate hardening A2 on `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Spec attacked:** `reports/round-102/fold-spec.md` §2 item **A2** (latent defect, found first by
SEAT-36 at `reports/round-102/reruns/labels.md` §3a)
**Owned path:** this file only. **No repository file was modified by this seat.**

**Discipline:** every output below is pasted from a command this seat actually ran. The attack was
carried out on a **scratch copy** of the subtree outside the repo; the repo's `gate/run_gate.sh` was
read and hashed but never written. **No Unreal runtime claim is made anywhere in this file:** the
editor is not installed on this host, and live-MCP behaviour is unproven by construction.

---

## 0. What this seat did, and what it deliberately did not

The seat brief was: *plant a card whose label line is preceded by a prose line containing the label
token (prose-hijack per fold-spec A2); the hardened gate must still FAIL the card as unlabeled; paste
outputs.*

Three things had to be established first, and each is a finding in its own right:

1. **The installed gate is NOT hardened.** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
   (sha256 `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96`, 249 lines) still
   carries the r102 first-token-wins rule at CHECK 3:
   `rec=$(grep -nE "$ALLOWED" "$f" | head -1)`. A2 is therefore a **live attack surface today**, not
   a regression guard. (The A1/A3/A4 seats' files exist beside this one; A2 had not landed when this
   seat ran.)
2. **`/tmp/advgate/hardened.sh` is not the A2 rule.** That r102 artifact differs from the installed
   gate only by the tool-presence loop and the HARDENING G `upstream/`-in-`corpus/` grep; its CHECK 3
   is byte-for-byte the old first-token-wins block. It cannot serve as the A2 candidate.
3. **A naive "remove `head -1`" fix is not A2.** If the rule becomes "any marked line with one token",
   then *every* card in the set fails, because all 13 cards mention `verified-here` / `unproven-runtime`
   in prose later in the body (e.g. `editor-general.md:43`, `:233`, `:362`). The declaration must be
   *distinguished from* the prose, which is what A2's word cap is for.

**The A2 candidate this seat tested** is therefore the fold-spec's stated rule, implemented as a
minimal patch to the installed bytes: the **declared label is the first MARKED line (bold or heading)
within the first 40 lines whose stripped text carries an allowed token and is at most 8 words long.**
The patch is §4. Its sha256 is
`f98247f912f0fbd4f22592f263627bf4dbdcdda9e609ce07ae73fa9129be0ead`.

**Non-breakage was checked before attacking:** all 13 real cards' declaration lines are 1–3 words
under that rule (`Label: static-only` = 2 words, `**\`static-only\`**` = 1), so the cap is not
retroactive breakage — it separates declaration from prose without touching any existing card.

---

## 1. Setup — scratch copy, frozen gate bytes

`corpus/live/` (672 MB) is not copied; it is symlinked, and no swept pointer resolves into it
(`grep -rnoE 'corpus/live[^`")]*' corpus/knowledge/unreal-mcp --include='*.md'` → no output). The
scratch root also carries symlinks to the repo's `reports/` and sibling `corpus/` dirs so the gate's
own HARDENING G repo-relative sweep resolves identically to the real tree.

```
$ SRC=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ W=/home/vgpnk/.cache/a2-seat12 ; R=$W/hard ; G=$R/corpus/knowledge/unreal-mcp/gate
$ cp -a "$SRC/corpus/knowledge/unreal-mcp" "$R/corpus/knowledge/unreal-mcp"
$ cp "$SRC/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$G/run_gate-installed.sh"   # frozen INSTALLED bytes
$ python3 $W/patch_a2.py                                                              # -> $G/run_gate-a2.sh
$ sha256sum "$G/run_gate-installed.sh" "$G/run_gate-a2.sh"
412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96  .../gate/run_gate-installed.sh
f98247f912f0fbd4f22592f263627bf4dbdcdda9e609ce07ae73fa9129be0ead  .../gate/run_gate-a2.sh
```

Reproduction script: `/home/vgpnk/.cache/a2-seat12/run2.sh` (raw log: `.../matrix2.out`). Each probe
runs the gate, prints the CHECK 3 block, the `GATE RESULT` line and the real exit code.

---

## 2. The attack matrix

`V0` is the unplanted control. `V6`–`V9` are the attack; `V10`–`V12` are controls carried over from
SEAT-36 (`reports/round-102/reruns/labels.md` §3a: NC2 unlabelled, NC3 multi-label, NC5 unmarked) so
the hardened rule cannot pass by simply being permissive.

### V0 — baseline, unplanted

```
$ bash "$G/run_gate-installed.sh" | grep -E 'editor-general|CARDS=|CENSUS|^STEP=|GATE RESULT'
OK   static-only      editor-general.md              line 4
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          RC=0

$ bash "$G/run_gate-a2.sh" ... (same block)
OK   static-only      editor-general.md              line 4
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          RC=0
```

### V6 — THE ATTACK: card with **no declaration at all**, one LONG marked prose line carrying `static-only`

The planted card is `editor-general.md` with **every** token-bearing line removed except a single
planted prose line. It is genuinely unlabeled: the card declares nothing.

```
    | **Prose:** this card carries no declaration at all; the label token `static-only` is mentioned here in prose only.
    | # Editor domain — executability verdict card
    |

=== INSTALLED gate ===
OK   static-only      editor-general.md              line 1
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          RC=0        <-- FALSE PASS, exit 0

=== A2-HARDENED gate ===
FAIL no-declaration /home/vgpnk/.cache/a2-seat12/hard/corpus/knowledge/unreal-mcp/executability/editor-general.md (no marked line carrying a token in <=8 words, first 40 lines)
CARDS=13 EXPECTED=13 BAD=1
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)          RC=1        <-- correctly FAILS as unlabeled
```

**A2 is confirmed and the hardening is confirmed.** A card that declares **nothing** is accepted by
the installed gate because a sentence of prose mentions a token; the A2 rule refuses it.

### V7 — same attack, prose line kept SHORT (≤ 8 words) — the residual hole

```
    | **Note:** `static-only`, nothing ran.

=== INSTALLED gate ===   OK static-only line 1  CARDS=13 BAD=0  STEP=PASS  RC=0
=== A2-HARDENED gate === OK static-only line 1  CARDS=13 BAD=0  STEP=PASS  RC=0
```

The A2 word cap is **length-based**, so a short marked prose line is still read as a declaration.
This is a **residual of the fold-spec's own rule**, not a defect introduced here — see §5.1.

### V8 — LABELED card, LONG marked prose `verified-here` above the declaration

```
    | **Prose:** this card is emphatically not `verified-here`; nothing was observed here.
    | # Editor domain — executability verdict card
    | **Subsystem:** Editor (screenshots, camera control, actor/asset selection, content browser, log inspection)
    | **Label:** `static-only`              <-- the real declaration, line 5

=== INSTALLED gate ===  OK verified-here editor-general.md line 1   CENSUS ... verified-here=1   STEP=FAIL  RC=1
=== A2-HARDENED gate === OK static-only   editor-general.md line 5   CENSUS ... verified-here=0   STEP=PASS  RC=0
```

Installed gate reads the **prose** as the declaration; the hardened gate skips it and reads the real
declaration. (Both end at a FAIL/exit-1 here because the census `EXPECTED=12/1/0` disagrees with the
hijacked token — the *reading* is the point, not the verdict.)

### V9 — same prose but UNMARKED (SEAT-36's exact falsification)

```
    | This card is emphatically not `verified-here`; nothing was observed.     <-- no bold, no heading

=== INSTALLED gate ===  FAIL label-unmarked ...editor-general.md :: This card is emphatically not `verified-here`; nothing was observed.
                        CARDS=13 EXPECTED=13 BAD=1   STEP=FAIL   RC=1     <-- FALSE POSITIVE on a correctly labeled card
=== A2-HARDENED gate === OK static-only editor-general.md line 5  CARDS=13 BAD=0  STEP=PASS  RC=0
```

This is SEAT-36's §3a case reproduced end-to-end: the installed gate rejects a correctly labelled
card; the hardened gate accepts it. A2 removes a real false positive.

### V10 — control: multi-label declaration

```
**Label:** `static-only` / `verified-here`
=== INSTALLED ===  FAIL multi-label ... :: **Label:** `static-only` / `verified-here`   BAD=1  RC=1
=== A2-HARDENED == FAIL multi-label ... :: **Label:** `static-only` / `verified-here`   BAD=1  RC=1
```
Preserved — A2 does not loosen the one-token rule.

### V11 — control: UNMARKED declaration, no prose

```
Label: static-only                     <-- no bold, no heading
=== INSTALLED ===  FAIL label-unmarked ... :: Label: static-only          BAD=1  RC=1
=== A2-HARDENED == OK static-only editor-general.md line 35               BAD=0  RC=0   <-- INVERTED
```
See §5.2 — a second residual, and the more consequential one.

### V12 — control: no declaration and no prose at all (card stripped of every token line)

```
=== INSTALLED ===  FAIL no-label       ...editor-general.md            BAD=1  RC=1
=== A2-HARDENED == FAIL no-declaration ...editor-general.md            BAD=1  RC=1
```
Preserved — a truly empty card is still rejected by both.

---

## 3. Verdict table

| case | card | INSTALLED | A2-HARDENED | A2 correct? |
|---|---|---|---|---|
| V0 | unplanted | PASS rc0 | PASS rc0 | yes (non-breaking) |
| **V6** | **unlabeled + long marked prose token** | **PASS rc0 (FALSE PASS)** | **FAIL no-declaration rc1** | **yes — attack caught** |
| V7 | unlabeled + SHORT marked prose token | PASS rc0 | PASS rc0 | **no — residual §5.1** |
| V8 | labeled + long marked prose above decl | reads prose (line 1) | reads decl (line 5) | yes |
| V9 | labeled + long UNMARKED prose above decl | FAIL label-unmarked (false positive) | PASS rc0 | yes |
| V10 | multi-label decl | FAIL rc1 | FAIL rc1 | yes |
| V11 | unmarked decl, no prose | FAIL label-unmarked rc1 | PASS rc0 | **no — inverted §5.2** |
| V12 | no tokens at all | FAIL rc1 | FAIL rc1 | yes |

**The seat's acceptance is met:** the hardened gate still FAILs the prose-hijacked card as unlabeled
(V6: `FAIL no-declaration`, `BAD=1`, `GATE RESULT: FAIL`, `RC=1`), and the installed gate does not
(V6: `GATE RESULT: PASS`, `RC=0`).

---

## 4. The A2 patch (candidate bytes, sha256 `f98247f9…`)

Diff of installed → A2-hardened, CHECK 3 only:

```diff
 C3_N=$(printf '%s' "$CARDS" | grep -c . || true)
 C3_BAD=0; N_STATIC=0; N_UNPROVEN=0; N_VERIFIED=0
+# A2 HARDENING: the DECLARED label is the first MARKED line (bold/heading)
+# within the first 40 lines whose stripped text carries an allowed token and is
+# at most C3_DECL_MAX_WORDS words long. The word cap is what separates a
+# DECLARATION from PROSE that merely mentions a token above the declaration.
+C3_DECL_MAX_WORDS=${C3_DECL_MAX_WORDS:-8}
 while IFS= read -r f; do
   [ -z "$f" ] && continue
-  rec=$(grep -nE "$ALLOWED" "$f" | head -1)
-  if [ -z "$rec" ]; then printf 'FAIL no-label       %s\n' "$f"; C3_BAD=$((C3_BAD+1)); continue; fi
-  ln=${rec%%:*}; text=${rec#*:}
+  ln=0; text=""
+  while IFS= read -r rec; do
+    rln=${rec%%:*}; rtext=${rec#*:}
+    [ "$rln" -gt 40 ] && break
+    case "$rtext" in *'**'*|*'#'*) ;; *) continue;; esac
+    s=$(printf '%s' "$rtext" | sed -e 's/[#*`|]//g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
+    w=$(printf '%s' "$s" | wc -w)
+    [ "$w" -le "$C3_DECL_MAX_WORDS" ] || continue
+    ln=$rln; text=$rtext; break
+  done < <(grep -nE "$ALLOWED" "$f")
+  if [ -z "$text" ]; then
+    printf 'FAIL no-declaration %s (no marked line carrying a token in <=%s words, first 40 lines)\n' "$f" "$C3_DECL_MAX_WORDS"
+    C3_BAD=$((C3_BAD+1)); continue
+  fi
   cnt=$(printf '%s' "$text" | grep -oE "$ALLOWED" | wc -l)
   lab=$(printf '%s' "$text" | grep -oE "$TOKENS" | head -1)
-  if [ "$ln" -gt 40 ]; then printf 'FAIL label-too-deep %s (line %s)\n' "$f" "$ln"; C3_BAD=$((C3_BAD+1)); continue; fi
-  case "$text" in *'**'*|*'#'*) ;; *) printf 'FAIL label-unmarked %s :: %s\n' "$f" "$text"; C3_BAD=$((C3_BAD+1)); continue;; esac
   if [ "$cnt" -ne 1 ]; then printf 'FAIL multi-label    %s :: %s\n' "$f" "$text"; C3_BAD=$((C3_BAD+1)); continue; fi
   case "$lab" in
```

The `>40` cut and the unmarked rejection are folded into the selection loop, so the rule is applied
once rather than twice. This is **candidate** code; the seat that owns `gate/` must adopt or reject it.

---

## 5. Residuals this attack leaves open (for the gate-owner seat)

### 5.1 Short marked prose is still read as a declaration (V7)

The ≤8-word cap is **length-based**, so `**Note:** \`static-only\`, nothing ran.` (5 words) passes as
a declaration over a card that declares nothing. The installed gate and the hardened gate behave
identically here. A length cap cannot separate a short prose mention from a short declaration; a
**marker-based** rule would. Across the 13 real cards, a marker rule (`**Label:**` / `**Verdict:**` /
`## Verdict`) inside the first 40 lines is satisfiable by 12 of 13 —
`vfx-niagara-dataflow.md` has **0** marker lines in its head — so a marker rule would need that
card's head adjusted before it could be adopted. Neither rule is a superset of the other; both need
the gate-owner's decision, which is exactly why this seat tested the fold-spec's stated rule rather
than inventing one.

### 5.2 The marking test is applied inside the selection loop, so an UNMARKED declaration is now skipped (V11)

This is the sharpest residual. In the installed rule, marking is a *property required of the chosen
line*: `Label: static-only` (unmarked) is chosen, then rejected → `FAIL label-unmarked`. In the A2
rule as patched, marking is a *filter used to choose*: the unmarked line is never chosen, the loop
falls through to a later marked prose line, and the card **passes**. A card can therefore be
unlabeled-or-unmarked in its declaration and still be accepted — a *different* hole, not obviously a
smaller one.

Fix, if the gate-owner wants both properties: choose the first marked ≤8-word token line **and**,
when none exists, choose the first ≤8-word token line *whatever its marking*, then apply the marking
test to it. That preserves the old rejection of unmarked declarations and the new rejection of
prose-hijacked ones. This seat did not implement that variant because it is beyond the A2 spec as
written; it is recorded here so the fold does not silently trade one hole for another.

### 5.3 A2 is one of four; this file says nothing about A1/A3/A4

The A1 (range-tail endpoints), A3 (card-name set) and A4 (BLOCKED signal) seats own their own files
in this directory. This seat verified only that the installed gate is unhardened **for A2** (CHECK 3
block, §1) and did not audit the other three checks beyond confirming they were not already patched.

---

## 6. Reproduction

```
SRC=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
W=/home/vgpnk/.cache/a2-seat12
cp -a "$SRC/corpus/knowledge/unreal-mcp" "$W/hard/corpus/knowledge/unreal-mcp"
cp "$SRC/corpus/knowledge/unreal-mcp/gate/run_gate.sh" \
   "$W/hard/corpus/knowledge/unreal-mcp/gate/run_gate-installed.sh"
python3 "$W/patch_a2.py"                       # writes run_gate-a2.sh
bash "$W/run2.sh"                              # full V0,V6..V12 matrix
```

Raw output pasted above is `/home/vgpnk/.cache/a2-seat12/matrix2.out`. The scratch directory lives
outside the repo on purpose: `reports/round-103/gate/` and `corpus/knowledge/unreal-mcp/**` are other
seats' ownership or byte-pinned, and this seat wrote only this file.

## 7. Statement of non-claim

Nothing in this file observes, implies or relies on Unreal Editor or live-MCP behaviour. The whole
exercise is a static text-processing audit of a shell gate over vendored files on this host. The
upstream pin under test is `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 8. Addendum — the gate bytes moved under this seat mid-round (dated correction note)

**Added 2026-10-18, after §1–§7 were written.** This is a dated note, not a rewrite of anything above.

The gate file changed while this seat was running, because sibling seats hold it concurrently. Two
hashes are therefore in play and both are recorded so no reader mistakes one for the other:

| when | `gate/run_gate.sh` sha256 | A2 present? |
|---|---|---|
| §1–§7 matrix (frozen as `run_gate-installed.sh`) | `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96` | **no** |
| re-read at end of seat (frozen as `run_gate-current.sh`) | `55a76cf8237bd210d1338d4eeb3dde3bb6a2a7d6ff0f42391e543f662f525293` | **no** |

**A2 was still absent at the later hash.** The CHECK 3 block at `55a76cf8…` is byte-identical to the
`412d1b84…` block (§1): `rec=$(grep -nE "$ALLOWED" "$f" | head -1)`. The change was elsewhere in the
file (the sibling A1/A3/A4 work). So the attack and its verdict are unchanged by the move, and were
re-run against the newer bytes to prove it rather than assumed:

```
$ bash "$G/run_gate-current.sh"          # unplanted
OK   static-only      editor-general.md              line 4
CARDS=13 EXPECTED=13 BAD=0
GATE RESULT: PASS (checks failed: 0)          RC=0

$ # V6 card: no declaration, one long marked prose line carrying `static-only`
$ bash "$G/run_gate-current.sh"          # 55a76cf8…
OK   static-only      editor-general.md              line 1
CARDS=13 EXPECTED=13 BAD=0
GATE RESULT: PASS (checks failed: 0)          RC=0        <-- STILL a false PASS

$ bash "$G/run_gate-a2.sh"               # same planted card, A2 candidate
FAIL no-declaration .../executability/editor-general.md (no marked line carrying a token in <=8 words, first 40 lines)
CARDS=13 EXPECTED=13 BAD=1
GATE RESULT: FAIL (checks failed: 1)          RC=1        <-- STILL caught
```

The unplanted repo tree is green on the current bytes: `POINTERS=91 ... UNRESOLVED=0`, `STEP=PASS`,
`GATE RESULT: PASS (checks failed: 0)`, `RC=0`. (The pointer count rose 88 → 91 during the round as
sibling seats added prose; the count is not this seat's finding and is quoted only to date the run.)

