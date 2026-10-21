# r107-gate — GATE-LEAD shard (round 107, 3D side-round)

Seat **KEY=GATE-LEAD** · lane `game-dev-3d-shokunin` · started 2026-10-19.
Owned path: this shard + `reports/round-107/mutations/` only. The live subtree was **not**
written; the orchestrator lands `gate-draft.sh`. Labels: **[O]** observed here w/ command,
**[I]** inference, **[?]** unknown. UNPROVEN stays UNPROVEN.

## Plan header (5 lines)

1. Read the r102-era gate + prior-round reports; recover its shape, check list, and pinned values.
2. Re-aim the gate at the fresh pin; keep the adversary-suite runner intact.
3. Produce `mutations/gate-draft.sh` (draft only) with the updated pin and any new coherence check.
4. Self-check the draft: syntax, shellcheck, clean run on a throwaway copy, full control matrix.
5. Record UNPROVEN items honestly; keep <400 lines.

STATUS: **DONE** — draft produced and mutation-tested 27/27. See the headline below.

---

## 0. Headline for the orchestrator

**The fresh pin is the r101 pin: `a6aa73ad…b297` has NOT moved.** [O] Three independent
transports agree (below), so "re-aim the gate at the fresh pin" is a **no-op on the PIN
constant** — the r102-era gate already targets the correct commit. The re-aim therefore reduces
to **pin COHERENCE** (does every prose restatement of the pin match the constant?) and **mode
equivalence**, neither of which the installed gate had. The draft adds both as **CHECK 5** and
**CHECK 2e**, and is otherwise a strict superset of the installed gate.

| artifact | sha256 | lines |
|---|---|---|
| installed gate `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` | 442 |
| **draft** `reports/round-107/mutations/gate-draft.sh` | **`0630198b0a81f407936e97ae1bf1650d97793e7185a449725960ddf8dacd2e61`** | 560 |
| gate spec `gate/README.md` | `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf` | — |

Sibling seat `r107-adv2.md` scored this exact draft (`0630198b…`, 560 lines) — the draft was
**frozen** at that hash before the final matrix run. [O]

## 1. The fresh pin — three independent transports

**[O]** all run 2026-10-19, this host:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD refs/heads/main
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/main --jq '.sha,.commit.committer.date'
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17T01:28:32Z

$ curl -sL https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ad…
$ tar -tzf tarball.tgz | head -1
unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/
```

Fresh clones by sibling seats (VENDOR-A `/var/tmp/r107-va/repo`, PIN-DELTA `/var/tmp/r107-pindelta/new-pin`,
VERIFY-2 `/var/tmp/r107-verify2/clone`) each `rev-parse HEAD` → `a6aa73ad…` [O]. The codeload
tarball at that SHA yields **12 tracked files, all byte-identical** to the vendored `upstream/`
tree (12/12 `SAME` under `sha256sum` comparison) [O]. So the vendored bytes are already correct;
**do not rewrite the 12 files** (a rewrite can only introduce a diff and invalidate `.manifest.d/`).

## 2. What the installed gate could NOT see (the re-aim's real content)

Two blindness classes, both demonstrated on throwaway copies [O]:

### 2a. Pin-string drift (D1/D2/D3/D8 below)

The pin is machine-checked in exactly ONE place — the `PIN=` constant. It is restated in prose in
~17 files (manifest header, `gate/README.md`, subtree `README.md`, `PROVENANCE.md`, all 13 cards,
`adaptation-kimi.md`). CHECK 1 hashes only the 12 vendored files; CHECK 2 compares only vendored
bytes. **Flipping the SHA string in `PROVENANCE.md`, `README.md`, or the manifest header left the
installed gate GREEN (exit 0)** — observed directly:

```
$ # on a copy, flip a6aa73ad… → deadbeef… in PROVENANCE.md, run the INSTALLED gate
D1-provenance-pin-drift   exit=0  STEP=PASS STEP=PASS STEP=PASS STEP=PASS GATE RESULT: PASS
D2-readme-pin-drift       exit=0  GATE RESULT: PASS
D3-manifest-header-drift  exit=0  GATE RESULT: PASS
D8-provenance-other-hex   exit=0  GATE RESULT: PASS
```

A tree that **vendors** pin X while its prose **says** pin Y is a quiet lie the old gate could not
see. This is the gap CHECK 5 closes — offline, no clone.

### 2b. Mode drift (D5 below)

The vendored tree is all mode `100644` (`git ls-files -s` in the fresh clone confirms [O]).
`chmod +x` on a vendored file keeps the bytes identical, so CHECK 1 and CHECK 2a–2d are blind:
observed `D5-mode-drift exit=0 GATE RESULT: PASS` against the installed gate. CHECK 2e closes it.

## 3. The draft — CHECK 5 (pin coherence) + CHECK 2e (mode)

**CHECK 5** anchors each pin declaration so a prose mention cannot hijack it (the r103 A2 lesson):
a **declaration** is a 40-hex token on a line matching a pin-declaration *shape* (table row naming
a pin; `**…pin…**`; `Pinned SHA:`/`pinned commit`; `pinned at`) or on a `rev-parse HEAD` /
`CLONE_HEAD=` / `# pinned SHA:` line. A bare history SHA in prose (`be8c183…`, `eaf2e838…`,
`5e67bdf9…` — the subtree legitimately carries several) is deliberately **not** a declaration.
Two structural sites are checked exactly by name: `MANIFEST_HEADER_PIN` and `GATE_README_PIN`.

**CHECK 2e** compares each vendored file's worktree mode against the mode the clone records
(`git ls-files -s` → `100644`), prints `MODE_DIFFS=<n>`, fails on any mismatch, and degrades to
`MODE_DIFFS=SKIP (stat unavailable)` if `stat` is absent.

Draft diff vs installed: **only the header line changed** (`FOUR`→`FIVE`) plus pure additions —
`diff <(installed) <(draft) | grep '^<'` returns exactly that one line. So every r102–r104
hardening (A1–A4, HARDENING A/B/H/F/G, WORK_ROOT, signal traps) is preserved verbatim. [O]

**Clean run of the frozen draft** (`0630198b…`) on a throwaway copy, exit **0**:

```
CHECK 1 manifest-byte-identity   MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0   STEP=PASS
CHECK 2 clone-equivalence        CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12
                                 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0 MODE_DIFFS=0  STEP=PASS
CHECK 3 verdict-card-scan        CARDS=13 EXPECTED=13 BAD=0 NAME_SET=OK  CENSUS 12/1/0  STEP=PASS
CHECK 4 pointer-sweep            POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0  STEP=PASS
CHECK 5 pin-coherence            MANIFEST_HEADER_PIN=a6aa73ad… GATE_README_PIN=a6aa73ad…
                                 PIN_DECL_LINES=38 DRIFT=0  STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

`bash -n` OK; `shellcheck -S warning` clean (rc 0) [O].

## 4. Control matrix — 27/27 as designed

Harness: `reports/round-107/mutations/gate-control-matrix.sh`; ledger
`…/gate-control-matrix.rows.txt`; scratch `/var/tmp/r107-gatelead/`. Every row runs on a throwaway
copy of a minimal workspace; the live subtree was never mutated. **[O]** result:

```
rows=27 mismatches=0
```

| group | rows | expectation | result |
|---|---|---|---|
| A regression (old checks) | A0, C1–C7 | C1–C6 red, A0/C7 green | 8/8 OK |
| B CHECK 5 pin coherence | D1,D2,D3,D8,D9,D10,D11,D12,D13 | all exit 1 | 9/9 OK |
| C CHECK 2e mode | M1,M2,M3 (`755`/`600`/`777`) | all exit 1 | 3/3 OK |
| D CHECK 5 false positives | N1–N4 (history SHAs in prose) | all exit 0 | 4/4 OK |
| E determinism | E1-det-1..3 | exit 0 each | 3/3 OK |

Representative observed signals:

```
D1-provenance   rc=1  FAIL pin-drift PROVENANCE.md:22 :: | pinned commit | `deadbeef…`
D3-manifest-hdr rc=1  FAIL manifest header pin != PIN
D10-gate-readme rc=1  FAIL gate/README upstream-pin row != PIN
D11-clonehead   rc=1  FAIL pin-drift gate/README.md:… 
D13-vfx-card    rc=1  FAIL pin-drift executability/vfx-niagara-dataflow.md:21
M1-mode-755     rc=1  MODE-DIFF upstream/hooks/hooks.json mode=755 expected=644
N1-history-sha  rc=0  GATE RESULT: PASS   (no false positive on `be8c183…`)
N2-prose-pin-history rc=0 GATE RESULT: PASS
```

### 4a. Two false-positive classes found and removed during design

Prototype v1 anchored a declaration on "backticked 40-hex **and** the substring `pin`". That
false-positived on prose: a line like *"The file was pinned long ago; blob \`be8c183…\` was
dropped."* carries both, and the gate went red on a **clean** tree. [O] v3's shape anchor removes
it. The trade-off is recorded, not hidden: the shape anchor is a **denylist of prose forms**, so a
*new* declaration shape a future editor invents (not one of the four measured) would be missed —
`reports/round-107/r107-adv1.md` class G ("spec-blind") probes adjacent ground.

### 4b. C7 — a harness artifact, not a regression

An early matrix pass reported `C7-sentinels expect=0 rc=1 MISMATCH`. Investigated: my first C7
planted the two control sentinels **joined on one line** (`upstream/nope.md:1 and
upstream/README.md:9999`), which pass A extracts as ONE non-sentinel string → red. The **installed**
gate behaves identically on that input (`MISSING-PATH … :1 and …:9999`, exit 1) [O], so it is not a
draft regression. `gate/README.md`'s own C7 quotes separate tokens; planting them separately (in a
`.txt`, which pass A scans and pass B ignores) gives exit 0, `SKIPPED_CONTROL_SENTINELS=2`,
`UNRESOLVED=0` on **both** gates [O]. The matrix script carries the corrected control.

## 5. Verification I ran, and what I did NOT

**Ran [O]:** 3-transport pin agreement; byte-identity of all 12 files vs the codeload tarball;
installed-gate clean run (exit 0); installed-gate drift probes (D1/D2/D3/D8/D5 → all wrongly
green); draft `bash -n` + shellcheck + clean run (5/5 PASS, exit 0); the 27-row control matrix
(0 mismatches); FP probes on v1 (2 false positives) and v3 (0).

**NOT run / UNPROVEN [?]:**
- **No Unreal runtime claim.** The editor is not installed; the draft's README section and this
  shard assert nothing about editor or MCP behaviour. `verified-here` stays 0.
- **The 12-attack adversary suite was not re-run by me.** The r104 runner survives at
  `/var/tmp/r104suite/suite.sh` (31 rows) and I read it, but re-running it is the assignment of
  `r107-adv2.md` (which did score this draft). My CHECK 5/2e controls are **additions** to that
  suite, not a replacement. [I] The adversary seats' coverage of the draft is the authoritative
  run.
- **`gate/README.md` is NOT updated by this seat.** The draft `mutations/gate-README-check5.md`
  holds the CHECK 5 / CHECK 2e documentation section for the orchestrator to merge. Until it
  lands, the draft gate's behaviour is ahead of its spec — a known, deliberate split (the README
  also carries two stale scanner-sha pins per `r107-rev-gate.md` F-C, an orchestrator-owned fix).
- **CHECK 5's coverage is shape-bounded.** A pin declaration written in a shape not among the four
  measured is not scanned. Stated in §4a; no claim is made that the enumeration is complete.
- **The mode check assumes the upstream tree is all-`100644`.** True at this pin [O]; if a future
  upstream commit adds a `100755` file, CHECK 2e compares against the clone's recorded mode (not a
  hardcoded `644`), so it stays correct — but that has not been exercised. [?]

## 6. Files

- `reports/round-107/r107-gate.md` — this shard.
- `reports/round-107/mutations/gate-draft.sh` — **the draft** (`0630198b…`, 560 lines).
- `reports/round-107/mutations/gate-README-check5.md` — draft README section for CHECK 5/2e.
- `reports/round-107/mutations/gate-control-matrix.sh` + `.rows.txt` — the 27-row harness + ledger.
- `reports/round-107/mutations/gate-check5-proto.sh` — standalone CHECK 5 shape-anchor prototype.
- Scratch: `/var/tmp/r107-gatelead/` (workspaces, prototypes, logs). Not landed.
