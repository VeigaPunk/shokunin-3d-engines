# r105 lesson — Unreal lifecycle: pin, vendor, gate, harden, repair

Distilled from the Unreal-mcp LAWS recorded in `LOG.md` ROUND 101–104
(`LOG.md:1302-1431`). This is a training lesson about evidence and maintenance,
not a new Unreal-runtime claim: Unreal Editor is not installed here
(`reports/round-101/r101-report.md:75-78`; `reports/round-104/r104-report.md:161-165`).
Commands and outputs below are the recorded round evidence; retain the target,
working directory, and revision with every measurement.

## Lifecycle: pin → vendor → gate → harden → repair

### 1. Pin the object before describing its scope (r101)

The object is the upstream tree tracked at the exact commit, not “all upstream
content.” r101 pinned
`a6aa73ada02a9fb1f5415bec491f9942c519b297`; the adjudicated scope was **12 files
tracked at that pin**. The pin and scope are part of the claim, not background
metadata (`reports/round-101/r101-report.md:115-133,320-323`).

- `git -C /tmp/ue-skills-ref rev-parse HEAD` →
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
- `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256`
  → **12 × `OK`, exit 0**; `diff -r --exclude=.git upstream /tmp/ue-skills-ref`
  → **clean, exit 0** (`reports/round-101/r101-report.md:115-126`).
- Hash checks prove listed files, not set equality: explicitly compare the
  vendored path set with `git ls-files` at the pin so an extra unlisted file
  cannot hide (`reports/round-101/r101-report.md:128-133`; mutation result,
  `reports/round-101/r101-report.md:62-66`).

### 2. Vendor only what the pin owns (r101)

Keep byte-identity evidence separate from runtime behavior. Content outside the
pin is a recorded scope boundary, not an implicit vendoring obligation; static
identity does not prove what an editor would do. The five PR-only paths and
history-only `toolsets.md` were excluded and recorded
(`reports/round-101/r101-report.md:320-323`; `corpus/knowledge/unreal-mcp/PROVENANCE.md` §8).

### 3. Put the gate in the corpus and run it from outside its directory (r102)

A reproducible gate belongs beside the artifact, not only in `/tmp` or an
author's transcript. r102 landed `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
with four checks and a pinned expected contract. The report's independent run
was `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` →
`GATE RESULT: PASS (checks failed: 0)`, `rc=0`; a non-author also ran it from
`/tmp` and got PASS (`reports/round-102/r102-report.md:126-142`). A green result
proves only what those checks cover; it does not certify Unreal runtime or
semantic consistency (`reports/round-102/r102-report.md:162-165,358-366`).

### 4. Harden against attacks, then bind the verdict to final bytes (r102–r103)

A gate is not trustworthy merely because its positive path passes. r102's first
landing admitted false passes; adversarial controls exposed 11 classes. The
close adopted hardened checks, and the report records **11/11 attacks detected**
(`reports/round-102/r102-report.md:418-432`). r103 added range-endpoint,
declaration-anchored-label, pinned-name-set, and distinct BLOCKED handling; its
reported attack probes failed closed (`reports/round-103/r103-report.md:169-205`).

Every attack or review verdict must name the exact target bytes. SEAT-14's r103
falsification was valid for its named 249-line intermediate; the final 347-line
gate was a different target, and the L1 re-ran the attack against the installed
version before ruling (`reports/round-103/r103-report.md:484-492`). r104 found
the mirror image: a **30/30 passing** regression result bound to superseded
`b6d8c61a…`, not landed `e5521304…`; it was evidence for the old hash only
(`reports/round-104/r104-report.md:350-356,622-629`). Hash and rerun after the
last edit; a stale PASS is as non-transferable as a stale FAIL.

### 5. Repair with dated evidence, not silent rewrites (r102–r104)

When a historical sentence was true at its own revision, preserve it as history
and append a dated correction with the new command and result. r102's lesson
critic caught its own “0 in both” claim: the recorded per-file command returned
`0` for the README and `1` for the lesson because the correction note quotes the
old path; the truthful distinction was **zero live command roots, one historical
quote** (`reports/round-102/lesson-critic.md:61-101`; fold at
`reports/round-102/r102-report.md:434-437`). A bare grep count cannot decide
whether a repair regressed; inspect the matching context.

Repairs also have to change behavior, not only the message. r104's workdir fix
was real because both `mktemp` sites were rooted under the selected path and
validated, not just because the gate printed an override banner
(`reports/round-104/r104-report.md:86-104,328-339`). The close-out then found a
documented `REPO` override that the code had not implemented; the L1 wired it
and tested both directions: a bad URL produced BLOCKED/exit 2, while the clean
reference passed (`reports/round-104/r104-report.md:715-721`; `reports/round-104/gate/closeout-runs.md:13-17`).
Treat prose/API mismatches as defects until a real invocation exercises the
promised branch.

## Recurring error-pattern classes

- **Prose-cites-bytes — earned r102.** A prose claim does not survive unless its
  own named command and target revision support it. Example:
  `grep -c 'shokunin/game-dev-3d'` → README **0**, lesson **1**; the latter hit
  was the dated correction note, not a live command root
  (`reports/round-102/lesson-critic.md:69-101`). Record per-file scope and inspect
  hits; do not silently replace a historical measurement.

- **Scanner-relative datum — earned r102.** `POINTERS=N` is a scanner's output,
  not a universal property: three scanners read **40/41/43** on the same tree.
  Name the scanner and tree/revision; prefer the invariant `UNRESOLVED=0` over
  comparing bare totals (`reports/round-102/r102-report.md:440-443`; gate run
  and independent scanner outputs at `reports/round-102/r102-report.md:126-142`).

- **Stale-intermediate falsification — earned r103, reinforced r104.** A failing
  (or passing) test on a file that later changed says nothing about the final
  file. r103's attack named a 249-line target; close reran it against the final
  implementation (`reports/round-103/r103-report.md:484-492`). r104's 30/30
  result was similarly tied to a superseded gate hash (`reports/round-104/r104-report.md:350-356`).
  Report the target hash in the verdict and rerun after the last edit.

- **Temp-dir-dependent gate — earned r103, diagnosed and repaired r104.** A
  shared `/tmp` quota caused `mktemp`/clone failures even while `df` showed free
  space; the gate could misreport a local resource failure as network trouble
  (`reports/round-103/r103-report.md:510-518`; `reports/round-104/r104-report.md:106-119,303-326`).
  Test the actual scratch path, not just its banner. Recorded checks:
  `GATE_WORKDIR=<writable-dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`
  → `WORK_ROOT=… (from GATE_WORKDIR)`, PASS/`rc=0`; bad root → named FAIL/`rc=1`
  (`reports/round-104/r104-report.md:98-104,328-339`).

- **Documented-but-unimplemented override — earned r104.** A knob in the README
  is not implemented until the executable consumes it and its branch is tested.
  The REPO override was missing in code, then implemented; the durable run
  matrix records `REPO=https://127.0.0.1:9/nope` → BLOCKED/exit 2 and a clean
  reference → PASS (`reports/round-104/r104-report.md:715-721`;
  `reports/round-104/gate/closeout-runs.md:13-17`). For every override, test
  both the failure/control path and the normal path.

- **Serial-spawn wall-cost — earned r103, repaired r104.** Twenty-one serial
  child launches incurred about a 19-second boot floor inside a 20-second case
  bound; the parallel-vs-serial experiment measured **15×** lower wall time
  (`reports/round-103/r103-report.md:269,484-499`; adversarial measurement,
  `reports/round-103/physics/adversary.md:58-69,139-156`). r104 switched to
  concurrent children with an in-bound fail-closed batch deadline; the row moved
  from timeout to **2.9 s PASS**, with its marker unchanged (L1 close receipt `corpus/live/runs/20261018T201215739340Z/verdicts.json` — full battery 337/350 corroboration under the default environment, mise Node v26.12.0, not the pinned fnm Node v24.21.0 total — and the r104 author runs under `reports/round-104/physics/author-runs-final/`; per SKILL.md row F, a fixture-runtime claim carries its receipt)
  (`reports/round-104/r104-report.md:700-713`). Measure spawn count × boot floor
  before blaming the engine or loosening a shared timeout.

  **Environment pairing (r106, 2026-10-18).** The `337/350` in the bullet above
  is the default-environment total only. Plain `node` resolves to mise
  `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`.
  The cited receipt parses to `cases=350 pass=337 fail=13`, `verdict=FAIL`,
  `seeds_unchanged=true`; all 13 failures are `r94_cannon_*` with observed
  `node=v26.12.0`. It is not the pinned-environment result. The clean pinned
  receipt, fnm Node `v24.21.0` prepended on `PATH`, is
  `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`
  (byte-identical to `corpus/live/runs/20261018T204240718894Z/verdicts.json`):
  `cases=350 pass=350 fail=0`, `verdict=PASS`, `seeds_unchanged=true`, positive
  cannon rows `node=v24.21.0`.

## Next-iteration hooks

1. On any upstream refresh, record the exact commit, compare the complete tracked
   path set, verify every manifest entry, and state exclusions by pin. Start with
   the r101 reproduce block (`reports/round-101/r101-report.md:257-281`).
2. Keep the gate in-repo. After each change, run positive and adversarial controls
   against the final hash; rerun after any later edit. Use `UNRESOLVED=0` under a
   named scanner, not an unqualified pointer total
   (`reports/round-102/r102-report.md:126-142,418-443`; `reports/round-103/r103-report.md:484-492`).
3. For every factual sentence, identify the file, revision, command, and output.
   When correcting an old record, date the correction and state what the search
   includes; distinguish source claims from correction-note quotes
   (`reports/round-102/lesson-critic.md:69-101`).
4. For every documented environment knob, inspect the implementation and run
   both its positive and negative branch. Put gate scratch on an explicitly
   writable `GATE_WORKDIR` for deterministic evidence
   (`reports/round-104/gate/closeout-runs.md:3-17`).
5. For process-heavy fixtures, compare serial and concurrent runs byte-for-byte,
   preserve markers/seeds, and set a fail-closed batch deadline below the
   per-case bound (`reports/round-104/r104-report.md:700-713`).
6. Keep the P/C label-precedence collision open until the subtree owners rule it;
   a gate's one-label check does not resolve semantic disagreement. r102 found six
   cards rejecting the defined `unproven-runtime` condition, and r104 still recorded
   the precedence ruling as owed (`reports/round-102/r102-report.md:358-366`;
   `reports/round-104/r104-report.md:615-618,727-735`). Do not treat this lesson
   as authority to edit the byte-pinned subtree.

## Correction note — r106, 2026-10-18

The environment-pairing note above is left as written. This note only splits
the `2.9 s` figure from the file it must not be read out of.

> **`2.9 s` is not the elapsed in the 337/350 file.** The bullet's `2.9 s
> PASS` is the figure in `reports/round-104/r104-report.md:706` (L1 `--only
> phys3d_joints_free_ops`). Parsed this seat,
> `corpus/live/runs/20261018T201215739340Z/verdicts.json` has `only=None`,
> aggregate `verdict=FAIL`, `cases=350 pass=337 fail=13`,
> `seeds_unchanged=true`, and `phys3d_joints_free_ops` `verdict=PASS`,
> `actual_exit=0`, `reasons=[]`, `elapsed_seconds=2.607`. It corroborates the
> row's PASS and the default-environment 337/350 total. It is not the 2.9 s
> measurement. Among `reports/round-104/physics/author-runs-final/`,
> `20261018T195013600353Z/verdicts.json` is the `--only` receipt with
> `elapsed_seconds=2.907`, `totals cases=1 pass=1 fail=0`, `verdict=PASS`,
> `seeds_unchanged=true`. The other author receipt,
> `20261018T193509710404Z/verdicts.json`, is also `--only` PASS, elapsed
> `2.669`. SKILL.md row F's aggregate `PASS` / `fail=0` is that `--only`
> shape, not the 337/350 file. This note does not add a `verified-here`
> label. No Unreal runtime is claimed.

> **Digest correction (r106, 2026-10-18).** The r104 sentence that calls `e5521304…` the landed gate hash is left verbatim; it cites `reports/round-104/r104-report.md:350-356,622-629`, and that report's full form is `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` (`:88`). That digest is not a blob of `run_gate.sh` in `git rev-list --all` (3 commits). Live and HEAD content hash is `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (25178 bytes, commit `2ca87e8`). The other two historical blobs are `577c8b54…` (19347 bytes, `8c9d9ad`) and `412d1b84…` (13106 bytes, `c6f655d`). Do not treat `e5521304…` as the live gate digest. Pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` still matches `corpus/knowledge/unreal-mcp/README.md` and `PROVENANCE.md`. `sha256sum -c .manifest.d/audit-reference.sha256` from `corpus/knowledge/unreal-mcp` still prints 12 × `OK`.
>
> ```
> $ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
> 390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
> $ git rev-list --all -- corpus/knowledge/unreal-mcp/gate/run_gate.sh
> 2ca87e846981c4e0c3e0e0e0  # abbreviated in the seat note; full ids recorded in reports/round-106/consistency/chunk-01.md
> ```
