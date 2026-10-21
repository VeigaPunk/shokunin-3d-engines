# r107 · SEAT SCRIBE-LOG — 3D lane LOG.md entry + SCORECARD verdict table

PLAN (5 lines):
1. Extract conventions from `LOG.md` tail (r105/r106 entries) + `SCORECARD.md` (round table, verdict-class vocabulary, axis names).
2. Read the r107 peer shards (cards, gate, kimi-adapt, pindelta, unlock, VENDOR-A/B, verify, verify2) as the evidence base for the round's claims.
3. Confirm r107 round facts independently (git pin, manifest 12/12, gate, docker pull state) with exact commands + observed output, labelled [O]/[I]/[?].
4. Draft the LOG.md r107 entry in the established voice (round summary / LAWS / ROUTED / L0 lines) and the SCORECARD verdict table, no state cell moved unless evidence says so.
5. Flag UNPROVEN honestly (UE runtime) and keep the shard under 400 lines; orchestrator lands, this seat does not commit.

STATUS: DONE — drafts below; orchestrator lands. Every number in the drafts traces to a command in §1 or to a named sibling shard.

---

## 1. Independent re-observation (this seat's own commands, 2026-10-19)

**[O] THE PIN DID NOT MOVE.** This reframes the round: the "fresh pin" is the r101 pin.

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main        exit 0

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits?per_page=3 \
    --jq '.[] | "\(.sha[0:12]) \(.commit.author.date) \(.commit.message | split("\n")[0])"'
a6aa73ada02a 2026-09-17T01:19:50Z [MCP] Permit safe concurrent tool calls
d1b05809e4f0 2026-09-10T23:03:32Z Document MCP proxy setup and recovery, bump to `3.1.0`
7e3b09bbf6d2 2026-07-22T19:18:50Z Merge pull request #31 from docs/point-install-at-claude-marketplace

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '{default_branch,pushed_at,private}'
{"default_branch":"main","pushed_at":"2026-09-17T02:27:43Z","private":false}
```

=> upstream `main` HEAD is still `a6aa73ad…`, last pushed 2026-09-17. The re-vendor target is
**byte-identical in identity to r101**; the round's value is the independent re-derivation, not a
content delta. Cross-confirmed independently by `reports/round-107/r107-verify.md` §0 **[O]** and
`reports/round-107/r107-VENDOR-A.md` §1/§4 **[O]**.

**[O] Vendored tree invariants (green):**

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
… (12 rows, all OK) …
rc=0

$ find upstream -type f | wc -l
12

$ diff -rq /var/tmp/r107-va/repo corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)  rc=0     # fresh anonymous clone == vendored tree, all 12 tracked files
```

**[O] Gate re-run on the landed tree (my run, scratch under `/var/tmp/r107-scribe-log`):**

```
$ GATE_WORKDIR=/var/tmp/r107-scribe-log bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
…
CHECK 3 verdict-card-scan
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
CHECK 4 pointer-sweep
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          rc=0
```

Gate script sha256 `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`; its pinned
constant `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297` (`gate/run_gate.sh:73`) already equals the
live pin, so the gate needs no pin-constant edit this round.

**[O] Subtree census:** `find corpus/knowledge/unreal-mcp -type f | wc -l` → **42** =
13 executability cards + 2 `gate/` + 12 `upstream/` + 12 `.manifest.d/` + 3 top-level
(`PROVENANCE.md`, `README.md`, `adaptation-kimi.md`).
*Discrepancy for the orchestrator:* `r107-cards-crit.md` §0 records "14 executability cards"; the
measured count is **13** (`ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → 13), matching
the gate's `CARDS=13 EXPECTED=13`. Treat the 14 as a scribe error in that shard, not a card count.

**[O] UE runtime — still UNPROVEN.**

```
$ date -Is ; tail -1 /var/tmp/ue-pull.log ; wc -l < /var/tmp/ue-pull.log
2026-10-19T00:10:33-03:00
3fc5ed8760e3: Download complete
76
$ docker images | grep -ci unreal
0
$ ps aux | grep -c "[d]ocker pull"
3
```

=> `wukakuki/unreal-engine:dev-slim-5.8.3` pull is **still in flight** (76 log lines and rising,
layers `Download complete`/`Pull complete`, no local image); no Unreal image present, no container
ever started. The runtime label at close is therefore **UNPROVEN-with-attempt-log** (docker unlock
attempt recorded; pull unfinished) unless the pull completes and a sibling lands a bounded smoke
probe before close. Peer `r107-pull-watch.md` sizes the image at **24.95 GiB** (registry manifest,
30 layers) with 4.61 GiB downloaded at its snapshot — so the pull is nowhere near complete.

**[O] Lane invariants:** `git diff --stat HEAD -- corpus/fixtures` → empty (0 diff);
`sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`
(stable). Branch `main`; identity `game-dev-3d-shokunin <game-dev-3d@shokunin.local>`;
`git status --short` shows only `?? reports/round-107/` — no seat committed.

**[O] Stale out-of-pin census (finding for the PROVENANCE draft):** `r107-verify.md` §1 records
**six** open PR refs (1,2,4,5,8,9) on the remote, whereas `PROVENANCE.md` §8 (r101) lists only
PRs 1 and 4. §8's surface list is a stale snapshot; the r107 refresh should say so.

## 1b. Peer corroboration (read after §1; cited, not inherited)

Where a peer shard supplies a fact I did not re-derive, it is named here so the orchestrator can
trace each draft number to its source.

- **Zero pin delta, confirmed three ways.** `r107-pindelta.md` §2/§3: `git log --oneline
  a6aa73a..origin/main` → empty; delta table (old pin vs new pin) shows `none` in every row incl.
  plugin version `3.1.1` → `3.1.1`; `diff -rq` new clone vs `upstream/` → empty rc=0. **[O]** in
  that shard, matching my own `ls-remote`/`gh api` reading.
- **Three transports agree on 12/12.** VENDOR-A (`git clone` https, `r107-VENDOR-A.md` §1–§3),
  VENDOR-B (codeload tarball, `r107-VENDOR-B.md` §6–§7, archive sha256
  `d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf`), VERIFY-LEAD/VERIFY-2
  (GitHub REST blobs). All report `a6aa73ad…` and 12/12 byte-identity. **[O]** in each.
- **The real delta is OUT of pin.** `r107-pindelta.md` §4 + `r107-verify.md` §6: **15 out-of-pin
  paths across 6 open PRs** (r101 §8 recorded 2 PRs); PR 9 is `plugin.json` `3.1.1` → **`3.1.2`**
  and is the one that will move the pin if merged; PR 8 adds an `opencode/` subtree (10 files).
  **None is merged, none is vendored.** **[O]**/**[I]** in those shards. This is the round's only
  content-delta finding, and it is explicitly out of scope for the vendored pin.
- **Runtime label confirmed UNPROVEN-with-attempt-log.** `r107-pull-watch.md` (W-CRON) measures the
  pull against the registry manifest: **30 layers, 26 791 359 421 B = 24.95 GiB** total; at its
  snapshot 1, 4.61 GiB downloaded (25/30 layers), 14 unpacked; gated by one 12.75 GiB layer
  (`7a31e2ef5f97`). `r107-unlock.md` and `r107-unlock-ver.md` had asserted **no label** at my read;
  `r107-unlock-nodocker.md` records the non-docker routes as absent (no `lutris`, no `legendary`/
  `heroic`, no Epic account). **[O]** in each.

*Correction to my §1 note:* the peer shard recording "14 executability cards" is `r107-cards-crit.md`
§0; the gate's `CARDS=13 EXPECTED=13` and `ls | wc -l` → 13 remain the arbiter.

---

## 2. LOG.md entry — DRAFT (append after the ROUND 106 block; orchestrator lands)

```markdown
- ROUND 107 (2026-10-19): 3D side-round — re-vendor of the EpicGames
  unreal-engine-skills-for-claude-code-plugin subtree. 40-seat swarm. The
  round's premise was FALSIFIED BY MEASUREMENT: upstream `main` is still
  `a6aa73ada02a9fb1f5415bec491f9942c519b297` (last pushed 2026-09-17), i.e.
  the "fresh pin" IS the r101 pin — there is no content delta to vendor. The
  round's delivered value is therefore an INDEPENDENT re-derivation, not a
  re-pin: 12/12 tracked files re-verified byte-identical through three
  transports that share no local state (git clone; codeload tarball; GitHub
  REST blobs), the vendored `upstream/` tree diff-clean vs a fresh anonymous
  clone (`diff -rq` rc=0), manifest 12/12 rc=0, gate re-run PASS (CARDS=13,
  static-only 12 / unproven-runtime 1 / verified-here 0, POINTERS=103
  UNRESOLVED=0). Executability cards re-evaluated at the same pin; the
  Claude→Kimi adaptation table refreshed. The round's only content delta is
  OUT of pin: 15 paths across 6 open PRs (r101 §8 recorded 2), PR 9 the
  `plugin.json` 3.1.1→3.1.2 bump that will move the pin if merged — none
  merged, none vendored. UE runtime: docker unlock attempted
  (`wukakuki/unreal-engine:dev-slim-5.8.3`) — pull still in flight at close
  (24.95 GiB manifest; 4.61 GiB downloaded at the watcher's snapshot), no
  image, no container ⇒ **UNPROVEN-with-attempt-log**. ADMIT at <WORK> +
  report-last.
- LAWS: "re-vendor at a fresh pin" is a HYPOTHESIS about the remote, not a
  given — resolve the pin from the wire first (`git ls-remote` + `gh api`), or
  the round ships a fabricated delta. An unchanged pin makes the re-derivation
  the deliverable: the value of a re-vendor is independence of transport, not
  novelty of bytes. A card count is a measured fact, not a remembered one
  (a sibling shard recorded 14 cards against a measured 13 — the gate's
  `CARDS=13` is the arbiter). A binary UNPROVEN label does not weaken because
  an unlock was ATTEMPTED — the attempt log is the evidence class, and the
  pull's incompleteness is part of it.
- ROUTED (r108+): finish the UE-runtime unlock attempt (pull completion +
  bounded non-interactive smoke probe, no license acceptance, no engine build)
  — operator-owned image decision; PROVENANCE §8 out-of-pin census refresh
  (six open PRs now vs two recorded in r101); the r106 remainder carried
  forward (sweep chunk completion, consistency chunk audits, jolt ruling);
  P/C precedence ruling still with the operator; cursor Pro rate-limit
  recovery operator-owned.
- L0: Epic link / docker image / lutris / P-C ruling — unchanged.
```

*Notes to the orchestrator on this block:* (a) the swarm size "40-seat" is the round's stated
seat count from the task brief — verify against the actual dispatch before landing; (b) `<WORK>`
is the work-commit placeholder, filled at the integration commit per the lane's report-last
convention; (c) if the docker pull completes and a sibling lands a bounded probe before close,
swap the runtime clause to `PROVEN-with-evidence` and cite that probe's shard — otherwise leave
UNPROVEN as written.

---

## 3. SCORECARD.md verdict table — DRAFT (append after the ROUND 106 block)

```markdown
## Round 107 verdict — 2026-10-19

| axis | verdict | evidence |
|---|---|---|
| coverage | **improved** (out-of-pin census; 0 vendored bytes) | The vendored pin is unchanged — `git ls-remote <upstream> main` → `a6aa73ad…`, `gh api …/commits?per_page=3` top commit still 2026-09-17, `git log a6aa73a..origin/main` empty — so **0 new in-pin bytes exist** and a content-delta claim would be fabricated; the 12/12 tracked files re-verified byte-identical across three transports sharing no local state (`diff -rq` fresh-clone vs `upstream/` rc=0, `sha256sum -c .manifest.d/audit-reference.sha256` 12×OK rc=0). The coverage that DID move is the **out-of-pin surface census**: r101 `PROVENANCE.md` §8 recorded 2 open PRs; the round measured **15 out-of-pin paths across 6 open PRs** (PR 9 = `plugin.json` 3.1.1→3.1.2, the one that moves the pin if merged; PR 8 adds a 10-file `opencode/` subtree). Mapped, recorded, **not vendored**. |
| depth | **improved** (bounded) | Gate re-run on the landed tree: `GATE RESULT: PASS (checks failed: 0)` rc=0, `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0`, `POINTERS=103 UNRESOLVED=0`. The gate needed no pin-constant edit (`run_gate.sh:73` already `a6aa73ad`), which is itself the falsification result: the round's premise, not the gate, was wrong. Bound: the adversary-suite extension (new attack classes over the refreshed gate) was still in progress at this seat's read — depth credit is for the re-verified gate + the premise falsification, not for unlanded attack classes. |
| calibration | **improved** | The round's headline premise ("fresh pin") is converted from an assumption into a measured, refuted claim with the exact command that refutes it — the fabrication class the lane's evidence discipline exists to catch. Executability cards re-checked at the same pin (label census 12/1/0 re-derived, not inherited); adaptation-kimi freshness re-verified; PROVENANCE §8's out-of-pin census found STALE (six open PRs vs two recorded) and routed as a dated refresh. UE runtime labelled **UNPROVEN-with-attempt-log** (pull in flight at close, no image, no container) — UNPROVEN kept UNPROVEN. |

Non-author: the pin identity was re-derived by three seats through three transports (VENDOR-A
git clone, VENDOR-B codeload tarball, VERIFY-LEAD/VERIFY-2 REST blobs) with agreement on
`a6aa73ad…` and 12/12 byte-identity; the gate PASS above is this seat's own independent run.

Bounded: no live-editor claim exists or can exist on this host (editor absent; install
operator-gated); the UE-runtime unlock is UNPROVEN-with-attempt-log (docker pull incomplete at
close); the round vendors **0 new bytes** — it re-establishes an unchanged pin, so no `depth` or
`coverage` credit is claimed for content novelty; adversary-suite results are attributed only if
their shards land before the integration commit. Work `<WORK>`; report-last follows.
```

*Notes to the orchestrator on this table:* (a) `coverage` is drafted as
**improved** (out-of-pin census; 0 vendored bytes) — the round adds no in-pin bytes (the pin did
not move) but it does map a genuinely larger out-of-pin surface (15 paths / 6 PRs vs r101's 2).
If the orchestrator prefers a stricter reading, `**unchanged**` is also defensible provided the
"0 new in-pin bytes" bound survives; do not let any wording imply new vendored content.
(b) `depth: improved (bounded)` is conditional on the adversary shards (`r107-adv1.md`,
`r107-adv2.md`, `r107-rev-gate.md`, `r107-mut-gate.md`) — all still plan-only at my final read; if
they land, replace the bound sentence with their detection matrix. (c) `<WORK>` is the work-commit
placeholder.

---

## 4. Convention notes (why the drafts look the way they do)

- **LOG entry shape** (r101–r106): `- ROUND NNN (DATE): <title>. <swarm>. <what landed>.
  <invariants>. ADMIT at <WORK> + report-last.` then `- LAWS:`, `- ROUTED (rNNN+):`, `- L0:`.
  Prose is wrapped at ~72 cols; the round number is bold-free plain text; ADMIT class named
  (`ADMIT` / `ADMIT-with-findings` / `ADMIT-corr`).
- **SCORECARD shape** (r101–r106): `## Round NNN verdict — DATE` + a 3-column table
  (`| axis | verdict | evidence |`, verdict in bold) + a `Non-author:` paragraph + a `Bounded:`
  paragraph. r101–r106 dropped the older one-line index row (`| rNN | lane | title | verdict |
  work |`) that r85–r98 used — this draft follows r101+.
- **Axis vocabulary:** owned axes are `depth`, `coverage`, `calibration`; verdicts in use are
  `**improved**`, `**improved** (bounded)`, `**unchanged**`, `**improved locally**`.
- **Evidence discipline:** every cell cites a command + observed output; labels `[O]`/`[I]`/`[?]`;
  UNPROVEN never silently promoted.
- This seat wrote **only** `reports/round-107/r107-scribe-log.md`; scratch was
  `/var/tmp/r107-scribe-log/` (gate workdir). Nothing under `corpus/` was touched.

## 5. What remains for the orchestrator

1. Land the LOG.md block (§2) and the SCORECARD block (§3) verbatim or with the two conditional
   notes applied.
2. Decide the `coverage` verdict wording (`improved (out-of-pin census)` vs `unchanged`) — both
   are defensible; the bound "0 new in-pin bytes" must survive either way.
3. Replace `<WORK>` with the integration commit and verify swarm size.
4. If the docker pull completed and a bounded probe landed, re-label the runtime clause.
