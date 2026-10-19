# r102 lesson — Unreal integration: pin-scoped vendoring and the no-editor posture

Distilled from round 101 (`LOG.md` ROUND 101, lines 1302–1325;
`reports/round-101/r101-report.md`), which vendored the Epic *Unreal Engine
Skills for Claude Code* plugin at `a6aa73ada02a9fb1f5415bec491f9942c519b297`
and assessed 13 editor subsystems **without a running editor**. This is the
carry-forward discipline, not a re-run: each law cites a resolvable receipt, and
nothing here asserts Unreal behavior.

The host fact that fixes the whole posture: Unreal Editor is **not installed**.
`EpicGames/unreal-engine` returns 404 for this account, and the AUR PKGBUILD
aborts at `prepare()` on an SSH `git ls-remote`
(`corpus/knowledge/unreal-mcp/PROVENANCE.md:159` R1, `:181` R2, `:210` R3;
`corpus/knowledge/unreal-mcp/README.md:65-72`). No live-editor evidence exists
or can exist here. That is a property of the host, not a backlog item.

## Law 1 — vendoring is scoped to the pin, and the scope wording is part of the claim

- **Scope = all files tracked *at the pinned commit*.** 12/12 vendored
  byte-identical. Re-derive with
  `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256`
  → 12 × `OK`, exit `0` (`PROVENANCE.md:51-65`, frozen; subtree `README.md`
  section "`.manifest.d/` — byte-identity manifests"); the independent transport
  is `diff -rq` against a fresh clone, clean, exit `0` (`PROVENANCE.md:48`).
- **Content outside the pin is recorded, not vendored.** Adversarial review found
  5 PR-only paths and 1 history-only file (`PROVENANCE.md:340-356`;
  `reports/round-101/r101-report.md:320-321`). The adjudicated wording is "all
  files tracked at the pinned commit" — the wider phrase "all upstream content"
  over-claims and was rejected at close.
- **Count the thing, then say which thing.** The brief said 11 paths; upstream
  tracks 12. "11" is the *seat* count (`seat11` covers two files), "12" is the
  *file* count — both correct about different objects (`README.md:98-102`,
  `PROVENANCE.md:101-110`). A number without its unit is a defect.
- **Residual gap, stated not hidden.** `sha256sum -c` alone cannot see an *extra
  unlisted file* — only set-equality against `git ls-files` catches that — and
  file mode/mtime are out of scope by design
  (`reports/round-101/r101-report.md:128-131`;
  `reports/round-101/r101-mutation-tester.md:5`, verdict **PROVEN**, 11/11
  content mutations caught). Non-author confirmation:
  `reports/round-101/r101-reviewer-c1.md:20` (**C1 CONFIRMED**, four
  independent transports).

## Law 2 — the evidence policy is binary: `proven` or `unproven`, no middle ground

- The policy is stated as binary and forbids "probably"
  (`README.md:14-15`). **`proven`** requires *both* (a) byte-identity with the
  pin and (b) a static check actually run on this host — checksum sweep, JSON
  parse, shell lint, line/byte count (`README.md:17-22`). **`unproven`** is
  anything needing the live editor: server start, `list_toolsets` /
  `describe_toolset` / `call_tool`, actor mutation, Live Coding, automation
  tests, Niagara/Sequencer/Control Rig authoring (`README.md:23-29`).
- **A connected client is not reachability.** A visible cached tool catalog or a
  successful `unreal_mcp_status` does not prove Unreal is reachable; only a
  successful read-only Unreal tool call would (`README.md:52-54`;
  `adaptation-kimi.md:299-302`, the live-editor rule: no Unreal-side effect may
  be written in the indicative mood on this host).
- **A static check proves the files it read, not the behavior they describe.**
  Byte-identity proves the vendored skill file is what upstream shipped; it says
  nothing about whether the editor honors it (`README.md:57-59`).
- **The policy carries its own maintenance rules** — promotion (a `static-only`
  row becomes `verified-here` only when someone runs the command and pastes the
  output), invalidation (any "binary strings line N" pointer dies on a CLI
  upgrade; every `upstream/...` pointer dies if the pin moves), and negative
  claims (`NONE-FOUND` means the named search returned 0, never "cannot exist")
  (`adaptation-kimi.md:287-297`).

## Law 3 — the card label ternary is finer than the policy, and it must be one shared vocabulary

- Three labels, mapped explicitly onto the binary policy
  (`README.md:33-42`): `verified-here` → `proven` (a bounded run happened here
  with a saved receipt); `static-only` → document facts `proven`, subsystem
  behavior `unproven`; `unproven-runtime` → `unproven`.
- **`static-only` is not a third policy state** — it is the honest *split* of a
  card whose file-level claims are proven and whose behavior claims are not
  (`README.md:43-48`). On a host with no editor the expected shape is
  `static-only` or `unproven-runtime`; a `verified-here` label would require a
  bounded-run receipt that cannot exist here (`README.md:46-48`).
- **Measured shape (this host, r101):** 13 cards, 12 × `static-only`,
  1 × `unproven-runtime` (`executability/actors-scene.md:5`), 0 ×
  `verified-here`; the exactly-one-label scan returns
  `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`
  (`reports/round-101/r101-report.md:44-46`;
  `reports/round-101/r101-verification-protocol.md:307-315`).
- **What r101 did *not* achieve: the ternary was not a shared vocabulary.**
  Six of the 13 cards explicitly reject `unproven-runtime` on the ground that the
  runtime path "is not even identified" (`executability/blueprints.md:113`),
  while `README.md:41` defines `unproven-runtime` as exactly *"needs the live
  editor and nothing was observed"* — the same condition (`reports/round-101/r101-critic-c3.md:317`
  F7; 6 cards, re-derived by `grep -rln 'Not `unproven-runtime`'
  corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → 6). Two groups with
  the same epistemic situation landed on opposite labels. **A label defined in
  one file and re-derived in another is two vocabularies** — the training point,
  and it defeats cross-card comparison even when every individual card is honest.

## Law 4 — install walls come in classes; classify before you escalate

Three distinct walls, three different owners (`PROVENANCE.md:157-230`):

- **Account-gated (404).** `git ls-remote https://github.com/EpicGames/unreal-engine`
  → `Repository not found`, exit 128; `gh api repos/EpicGames/UnrealEngine` → 404.
  The token has `repo` scope, so this is *not* an auth failure — it is the
  expected consequence of the account not being Epic-linked
  (`PROVENANCE.md:159-179`). No local work closes it.
- **Protocol-gated (SSH).** The AUR `unreal-engine` 5.8.2-1 PKGBUILD gates in
  `prepare()` on `git ls-remote git@github.com:EpicGames/UnrealEngine`
  (line 280), so the build aborts before compiling (`PROVENANCE.md:181-208`).
  Same account, different transport — a distinct wall, worth a distinct receipt.
- **Credential/operator-gated.** Lutris is one `pacman -S` away and `docker` is
  present, so the *mechanism* exists; the block is an Epic Games Store login, an
  operator-owned credential (`PROVENANCE.md:210-230`). This wall is not a host
  wall — do not route it as one.
- **Record unlock paths as `unproven`, never as plans.** The public
  `wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB, contents unverified)
  is recorded as an unproven unlock path and explicitly *not* evaluated
  (`reports/round-101/r101-report.md:338-342`). The lane proceeds static-only
  without operator input.

## Two counting traps this round exposed

- **A documented sweep command must produce the lines it prints.** The subtree
  `README.md` section "`.manifest.d/` — byte-identity manifests" printed a
  12-line block under a `sha256sum -c .manifest.d/*.sha256` glob that actually
  yields **24** `OK` lines (re-derived:
  `sha256sum -c .manifest.d/*.sha256 2>&1 | grep -c ': OK'`
  → 24, versus 12 for the `audit-reference.sha256` subset). The conclusion ("all
  OK, exit 0") holds; the count does not match its own command
  (`reports/round-101/r101-critic-c3.md:365` F8, the finding; `gate/README.md:40`
  pins both counts). A later seat edited this block to state both counts
  correctly; re-measure rather than trusting either revision.
- **Enumerate, never trust a count written into prose.** The card table is the
  intended set; sibling seats land cards concurrently, so `ls executability/`
  is the truth and any snapshot in an index goes stale within minutes
  (`README.md` section "`executability/` — 13 subsystem verdict cards", the
  bullet beginning "Enumerate what is actually present").

## Re-running the gate

The r101 checks were originally ad-hoc: the protocol carries each script inline
plus a one-shot runner appendix
(`reports/round-101/r101-verification-protocol.md:30` §0, `:582`). A
self-contained, path-independent gate now exists at
`corpus/knowledge/unreal-mcp/gate/run_gate.sh` (4 checks: manifest sha256 /
path-set equality vs a fresh pinned clone / 13-card label scan / pointer sweep).
Observed this round from the lane root:

- `corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `GATE RESULT: PASS (checks
  failed: 0)`, exit `0`; check 4 printed
  `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `STEP=PASS`, check 3
  `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS static-only=12 unproven-runtime=1
  verified-here=0`.
- The same checks run standalone:
  `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` →
  `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`;
  `bash /tmp/r101-closeout/label-scan.sh corpus/knowledge/unreal-mcp/executability 13`
  → `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`.

Prefer the in-repo gate over the `/tmp` scripts: a gate that lives in the corpus
survives a reboot, and it resolves the subtree relative to its own location, so
it can be run from anywhere. The `/tmp` copies were the r101 stopgap and are not
part of the tree.

The pointer scanner **self-contaminates** on the protocol's own negative
controls: sweeping `reports/round-101` wholesale reads `UNRESOLVED=2` /
`STEP=FAIL` on strings the protocol instructs the verifier to plant. Exclude
`r101-verification-protocol.md` from the sweep, or use the exclusion list at
`reports/round-101/r101-report.md:161-168`.

## Next-iteration hooks

1. **Resolve the F7 label collision.** Either amend the `README.md` ternary table
   row for `unproven-runtime` to state which side of the split owns "path not
   even identified", or amend the six `static-only` cards. Until one wins, a
   cross-card label census is not evidence of anything.
   (`reports/round-101/r101-critic-c3.md:317`)
2. **Keep the gate in-repo and re-run it after any wording fix.** The gate now
   lives at `corpus/knowledge/unreal-mcp/gate/run_gate.sh` and is green on the
   current bytes (`GATE RESULT: PASS`, exit 0). Two of its four checks compare
   against a *fresh* clone at the pin, so it needs network; run it before and
   after any edit to prove the byte-pinned `upstream/` and `.manifest.d/` were
   not perturbed. Do not re-introduce a `/tmp`-resident gate — that was the r101
   stopgap.
3. **Treat the subtree `README.md` as a moving surface.** It was edited by a
   concurrent seat during r102 and its byte-identity section changed shape twice
   in one session (one revision stated both counts, 24 and 12; another reverted
   to "12 lines"). Cite it by section heading, or re-read it before quoting a
   line number. `PROVENANCE.md` and `adaptation-kimi.md` were stable throughout —
   prefer them when a citation must survive.
4. **Prose-cites-bytes is the recurring defect class, and it is only half
   repaired.** Snapshot as first drafted 2026-10-18 (preserved per the
   correction-note discipline): of the routed pre-existing defects, three were
   fixed in r102 by other seats (r22 wrong path root; the `engines.md` three.js
   command now names `npm ci --prefix` first; `rea.md` now records
   JADX/Binwalk/Unblob as present), and two — the r22 lesson's
   `corpus/live/runs/20261013T053632289732Z/verdicts.json` pointer and its stale
   `run_battery.py` sha citation — were still live at drafting time.
   **Correction (r102 close, same day, after
   `reports/round-102/lesson-critic.md` D1 and the seat repairs landed):** all
   five are now repaired. Precisely: `grep -c 'shokunin/game-dev-3d'` reads **0**
   in `corpus/artifacts/unreal-r22/README.md` and **1** in
   `corpus/lessons/r22-unreal-review.md` — the surviving hit is the r102
   correction note's own quotation of the dead prefix (`:55`); a bare grep
   cannot distinguish "fixed" from "fixed and documented", so read the hit's
   context. The two lesson citations fell as dated correction notes in the same
   file (evidence `reports/round-102/repairs/F1b-F2-r22-lesson.md`). The
   recurring class is unchanged: a claim that does not survive its own command.
   Repair by dated correction note, never by silent rewrite.
5. **Never promote an engine row on static evidence.** `corpus/knowledge/engines.md:10`
   still reads Unreal `installed: no / executable headless: no` (the evidence
   column was rewritten in r102 to name the two static classes — lane-authored
   r22 descriptor vs third-party pinned r101 tree — but the two status cells did
   not move). Per the file's own rule (`engines.md:13-16`) a row may move only
   with a saved bounded-fixture receipt *and* a non-author verifier. No such
   receipt exists, and none can on this host.
6. **Keep the no-editor posture explicit in every future Unreal artifact.** The
   cheap invariant to re-check is `UNLABELED=0` on a live-editor-surface scan
   (`reports/round-101/r101-report.md:144`) — the denominator grows with each
   seat; the zero is the stable property.

## Correction notes — r106, 2026-10-18

Historical sentences above are left as the r102 record. These notes are the
live reading. Do not silently retarget a line number that was true at authoring.

> **`engines.md` line numbers moved (r106 census rewrite).** Hook 5 cites
> `corpus/knowledge/engines.md:10` and `engines.md:13-16`. Those numbers were
> the Unreal row and the promotion rule at r102 close
> (`git show c6f655d:corpus/knowledge/engines.md`). r106 inserted a two-state
> host section and kept writing the file during this check (116 lines on an
> earlier read, 166 at the snapshot). Do not use `:10` or `:13-16`. Re-derive:
> `grep -n '^| Unreal Engine |' corpus/knowledge/engines.md` and
> `grep -n '^Rules:' corpus/knowledge/engines.md`. Snapshot
> 2026-10-18T22:09:39Z, sha256
> `501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933`: Unreal
> row line 44, cells `no` / `no`; `Rules:` at line 48. The status cells did
> not move. A later census write can move the line again; the grep is the
> citation, not the number.

> **`gate/README.md:40` does not pin the 24/12 counts.** The counting-trap
> paragraph cites that line as pinning both counts. At r102 close (`c6f655d`)
> line 40 was the upstream-repo constant, not the 24/12 pin. On this check it
> is the A4 BLOCKED/exit-2 sentence (file sha256
> `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`). The
> 24/12 statement is `corpus/knowledge/unreal-mcp/README.md:169-170` and
> `:187`. Re-measured from the subtree cwd: `sha256sum -c
> .manifest.d/audit-reference.sha256` → 12 × `OK`, rc 0; `sha256sum -c
> .manifest.d/*.sha256` → 24 × `OK`, rc 0.

> **In-repo gate `POINTERS=40` is the r102 observation.** The "Re-running the
> gate" block records what that round's scanner printed
> (`reports/round-102/r102-report.md:136`). Re-run 2026-10-18 r106:
> `GATE_WORKDIR=reports/round-106/scratch/seat122/gate
> corpus/knowledge/unreal-mcp/gate/run_gate.sh`, scanner sha256
> `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`, rc 0,
> stderr empty. Observed `POINTERS=103 POINTER_STRINGS=41
> SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, `CARDS=13 EXPECTED=13 BAD=0`,
> census `static-only=12 unproven-runtime=1 verified-here=0`, `GATE RESULT:
> PASS (checks failed: 0)`. PASS and the card census still match. The pointer
> total does not. `/tmp/r101-closeout` and `/tmp/ue-skills-ref` remain absent
> (`ls` → No such file or directory). Prefer the in-repo gate, as the
> paragraph already says. This is a static gate, not an Unreal runtime result.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T053632289732Z/verdicts.json`
