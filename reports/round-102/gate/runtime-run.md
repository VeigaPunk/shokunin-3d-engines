# SEAT-39 — GATE-RUN-RECEIPT (r102)

**Seat:** SEAT-39 GATE-RUN-RECEIPT
**Date:** 2026-10-18
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**HEAD at seat runtime:** `2c99b7b` (r101 report-last; work commit `1659c036`)
**Scope:** run `corpus/knowledge/unreal-mcp/gate/run_gate.sh` from the repo root and
record its full output + rc; if it does not exist, record that and run the four
underlying checks manually.

---

## 1. Gate availability at this runtime

```
$ ls corpus/knowledge/unreal-mcp/gate/run_gate.sh
ls: cannot access 'corpus/knowledge/unreal-mcp/gate/run_gate.sh': No such file or directory
$ ls corpus/knowledge/unreal-mcp/gate
ls: cannot access 'corpus/knowledge/unreal-mcp/gate': No such file or directory
$ echo $?
2
```

**Result: the gate does not exist at this runtime.** The directory
`corpus/knowledge/unreal-mcp/gate/` is absent, so there is nothing to execute and
no rc to record. This is the expected ordering outcome, not a failure: the gate is
C1(a), authored by another seat, and **the gate landed after this seat's runtime
window**. A `run_gate.sh` receipt must therefore be produced by a later seat (or a
re-run of this seat) once C1(a) lands. Nothing in this file should be read as a
gate pass — it is the *manual fallback* the seat brief specifies.

Sibling C1 artifacts were also absent at this runtime, confirming the whole C1
claim set lands after SEAT-39:

```
$ ls corpus/lessons/r102-unreal-integration.md
ls: cannot access 'corpus/lessons/r102-unreal-integration.md': No such file or directory
```

(exit 2). `corpus/knowledge/engines.md` does exist but had not yet received the
C1(c) Unreal-row evidence-class update at this runtime.

## 2. Manual execution of the four underlying checks

Run from the repo root. Each check below is exactly one of the four the gate is
specified to perform (manifest sha256 / path-set equality vs fresh pinned clone /
13-card label scan / pointer sweep with decontamination).

### 2.0 Fresh pinned clone (input to check 2)

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r102-gate-ref
clone rc=0
$ git -C /tmp/r102-gate-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

The clone HEAD equals the declared upstream pin `a6aa73ad…b297` **exactly**, so the
reference tree used by check 2 is the pinned revision, not a moving `main`.

### Check 1 — manifest sha256

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
upstream/README.md: OK
upstream/LICENSE: OK
upstream/.claude-plugin/plugin.json: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
rc=0
```

**PASS.** 24 `OK` lines, 0 `FAILED`, rc=0. 12 lines come from the 12/12
`audit-reference.sha256`; the remaining 12 come from the ten single-file
`seat01`–`seat10` manifests plus the two paths in `seat11` (`CODEOWNERS`,
`.gitignore`). The two sweeps cover the same 12 paths, so byte-identity is
confirmed by both the independent audit reference and the per-seat manifests.

### Check 2 — path-set equality vs fresh pinned clone

```
$ (cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sed 's|^\./||' | sort) > /tmp/lp.txt
$ (cd /tmp/r102-gate-ref && git ls-files | sort) > /tmp/rp.txt
$ diff /tmp/lp.txt /tmp/rp.txt
diff rc=0  local=12 ref=12
```

**PASS.** The vendored tree's file set and the pinned clone's `git ls-files` set
are **set-identical** — no missing file, no extra file, rc=0. This closes the
failure mode check 1 alone cannot see: a vendored file that was never added to any
manifest would still let `sha256sum -c` exit 0. Here the local set is exactly the
upstream-tracked set, 12/12, so the manifest coverage is complete.

### Check 3 — 13-card label scan

```
$ for f in corpus/knowledge/unreal-mcp/executability/*.md; do
    printf '%-42s ' "$(basename $f)"
    grep -m1 -oE '`(verified-here|static-only|unproven-runtime)`' "$f"
  done
actors-scene.md                            `unproven-runtime`
animation-controlrig.md                    `static-only`
assets-content.md                          `static-only`
blueprints.md                              `static-only`
editor-general.md                          `static-only`
gameplay-gas.md                            `static-only`
materials.md                               `static-only`
meshes-textures.md                         `static-only`
scripting-programmatic.md                  `static-only`
sequencer.md                               `static-only`
testing-automation.md                      `static-only`
ui-umg-slate.md                            `static-only`
vfx-niagara-dataflow.md                    `static-only`
card files: 13
```

**PASS.** All **13** intended cards are present (matching the 13 subsystems in
`upstream/README.md` → *What's Available* and the 13-row table at
`corpus/knowledge/unreal-mcp/README.md`), and each declares exactly one of the
three permitted labels. Distribution: **12 × `static-only`, 1 ×
`unproven-runtime`** (`actors-scene.md`), **0 × `verified-here`**.

The zero `verified-here` count is the correct and expected result on this host:
`verified-here` requires a saved receipt of a bounded run of the subsystem, and
Unreal Editor is not installed (README *Host reality*), so no such receipt can
exist. A `verified-here` label appearing here would be a defect, not progress.

Method note for the gate author: the three label tokens appear **multiple times
per card** (7–23 occurrences each) because cards discuss the other two labels when
justifying their own — e.g. `ui-umg-slate.md:25` reads "Why not
`unproven-runtime`". A naive scan that counts every token occurrence would report
`distinct=3` for all 13 cards and be useless as a verdict check. The scan above
takes the **first** canonical token in the file, which is the declared verdict in
all 13 cases; it was cross-checked against the explicit label field each card
carries in its header (`**Label:**`, `**Verdict label:**`, or `Verdict:`), and the
two agree for all 13.

### Check 4 — pointer sweep with decontamination

```
$ grep -rhoE 'corpus/knowledge/unreal-mcp/[A-Za-z0-9._/-]+\.(md|json|sh|sha256)' \
    corpus/knowledge/unreal-mcp/*.md corpus/knowledge/unreal-mcp/executability/*.md \
    | sed 's/[.,;:)]*$//' | sort -u > /tmp/p.txt
$ wc -l /tmp/p.txt
14 /tmp/p.txt
$ (loop: test -e on each pointer, print MISSING)
pointers=14 missing=0
```

**PASS.** 14 distinct repo-relative `corpus/knowledge/unreal-mcp/...` pointers
across the index and the 13 cards, **0 missing**, no `MISSING` line emitted.

"Decontamination" is applied in two ways: (a) trailing sentence punctuation
(`.`, `,`, `;`, `:`, `)`) is stripped before the existence test, so a pointer at
the end of a clause is not falsely reported missing; (b) the sweep is restricted
to the explicit `corpus/knowledge/unreal-mcp/` prefix, so the many bare
`upstream/…` and `executability/…` shorthands that cards define under their own
pointer convention (see `executability/actors-scene.md` "Pointer convention") are
not mis-tested against the repo root. Cards spell those shorthands out in full in
their §7, which is what the sweep picks up.

## 3. Subtree integrity at this runtime

The r101 subtree is byte-pinned and this seat wrote nothing into it. Confirmed:

```
$ git diff --stat -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(empty output)
rc=0
```

No tracked change under `upstream/` or `.manifest.d/` at this runtime. The
working-tree modifications reported by `git status` at seat time were
`corpus/artifacts/unreal-r22/README.md`, `corpus/knowledge/unreal-mcp/README.md`
(the F8 wording fold), and `corpus/lessons/r22-unreal-review.md` (F1/F2
correction notes) — all owned by other r102 seats, none of them mine, and none of
them inside the byte-pinned region.

## 4. Verdict

| check | result | evidence |
|---|---|---|
| 1 manifest sha256 | PASS | 24 × `OK`, rc=0 |
| 2 path-set equality vs pinned clone | PASS | diff empty, 12/12, clone HEAD = `a6aa73ad…b297` |
| 3 13-card label scan | PASS | 13 files, 1 label each, 12 `static-only` + 1 `unproven-runtime` |
| 4 pointer sweep | PASS | 14 pointers, 0 missing |

All four underlying checks pass on the r101 subtree as it stands. **The gate
script itself was not run, because it did not exist at this runtime** — so this is
a manual fallback receipt, not a gate receipt. When C1(a) lands, the gate must be
run from the repo root and its own raw output + rc recorded; the numbers above are
the baseline it should reproduce (and check 3's first-token method is the one it
should implement, per the method note in §2).

No Unreal runtime claim is made or implied anywhere in this report. The editor is
not installed on this host; every live-editor behavior remains `unproven` by
construction.
