# r107 round report — Unreal re-vendor (side-round) · 3D lane

- **Seat:** SCRIBE-REPORT · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Round:** 107 (3D side-round) · **Axes:** depth / coverage / calibration
- **Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`)
- **Landing commit:** `<L1 fills at close>` — this report is intended to land last; the whole round lands in one orchestrator commit.
- **Report base HEAD at write:** `3ea02ffaafc6c618bb97a19f103a3d28ecdc2638` (`git rev-parse HEAD`). Subject `r106 report-last …`.
- **Evidence frame:** `2026-10-19T03:10Z`. Sibling shards were still landing; every value depending on a shard that was a header at this frame is marked **[moving]**.
- **Zero-execution disclosure.** Unreal Editor is **not installed** on this host and cannot be, without an Epic-account link. Every live-editor claim in this round is **unproven-on-this-host by construction**. The docker unlock attempt is in §W6.

Tags: **[O]** command run by this seat · **[P]** a peer shard this seat read, not re-run · **[I]** labelled inference · **[?]** unknown. **[moving]** = depends on a sibling shard still landing. `[~]` = lane assessment with pointer, not a verified `[x]`.

> **Headline finding (this seat, [O]).** The "fresh pin" resolves to the **same commit** as r101: `a6aa73ada02a9fb1f5415bec491f9942c519b297`. Two of my own transports agree — `git ls-remote … main` and `gh api repos/…/commits/main` — and six sibling seats independently resolved the same SHA. The round's value is *independent re-derivation at an unchanged pin*, not a content delta. **No new upstream bytes exist to vendor.**

---

## Summary at the evidence frame

- **C1 (re-vendor + byte-identity) — GREEN, no content delta.** The vendored `upstream/` tree is byte-identical to a fresh clone of the pinned commit: `sha256sum -c .manifest.d/audit-reference.sha256` → 12/12 `OK`, rc 0; `diff -rq <fresh clone> upstream --exclude=.git` → clean, rc 0; 12 tracked files, 63 556 bytes, 1 022 lines. Pin identical to r101 → **empty pin delta**.
- **C2 (gate close-out) — PASS at rc 0, re-run by this seat.** `GATE RESULT: PASS (checks failed: 0)`, `CARDS=13 EXPECTED=13 BAD=0`, census `12/1/0`, `POINTERS=103 … UNRESOLVED=0`. One gate-README defect found (§Findings).
- **C3 (cards + adaptation) — refreshed; verdicts landed.** 13 cards on disk, one label each (`12 static-only / 1 unproven-runtime / 0 verified-here`). CARDS-LEAD closed: **all 13 cards keep their r101 verdicts at the pin — no label moves**. KIMI-ADAPT-LEAD closed: the adaptation table is stale by **content, not anchor** (pin and Kimi binary unchanged); REV-ADAPT re-measured 5/5 rows — all reproduce as written. See the two late-frame blocks.
- **UE runtime — UNPROVEN-with-attempt-log.** `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` still running at every frame (no local image); manifest is 30 layers / 24.95 GiB. REV-UNLOCK extended the evidence base to tier **T1** (registry manifest matches the published tag digest; the image ships a prebuilt editor tree) but no container probe ran. **[moving]** UNLOCK seats.
- **Invariants held [O].** `corpus/fixtures/` diff clean; `run_battery.py` blob `dd2d9b74…` untouched and **never run**; protected roots `LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md` all MATCH HEAD; no seat committed (`git log -1` still `3ea02ff`).

---

## Work performed

One bullet per workstream, each with the evidence pointer.

### W1 — Re-vendor at a fresh pin + 3-transport byte-identity

- **Target pin resolved independently.** **[O]** `git ls-remote … main` → `a6aa73ada02a9fb1f5415bec491f9942c519b297  refs/heads/main` (rc 0); `gh api repos/…/commits/main` → same SHA, committer `2026-09-17T01:28:32Z`, subject `[MCP] Permit safe concurrent tool calls`. **[P]** Six seats agree: VENDOR-A, VENDOR-B, VERIFY-LEAD, REV-PIN, PIN-DELTA, planner.
- **Transport A — `git clone` (https).** **[P]** `r107-VENDOR-A.md`: 12 tracked files all mode `100644`, no symlinks/gitlinks/LFS; per-file sha256 + `va-manifest.json`; `git hash-object` vs index blob → 12/12 `OK`; cross-check vs vendored tree → `byte-identical=12/12`. **[P]** `r107-verify.md` §2 reproduces it.
- **Transport B — codeload tarball (no git protocol).** **[P]** `r107-VENDOR-B.md`: `curl …/tar.gz/a6aa73ad…` → HTTP 200, 22 990 B, sha256 `d091941c…`; top-level dir self-identifies the SHA; two fetches 13 s apart are byte-identical (`CODELOAD-DETERMINISTIC`). The extracted tarball **reconstructs the exact git tree object**: `git write-tree` → `b5b9624b00fc90217240e823406699d0ab78b959` = `gh api …/commits/<sha> --jq .commit.tree.sha`. **[P]** `r107-rev-pin.md` §2 transport C independently matches (same tarball sha).
- **Transport C/D — REST blobs + git-fetch.** **[P]** `r107-rev-pin.md` (DONE): 4 transports (clone, ls-remote, codeload, REST) agree on pin **and tree SHA**; `bash mutations/rev-pin.sh` → `VERDICT: PASS`, rc 0. **[P]** `r107-verify.md` §6 adds a git-wire fetch, blob-ids identical 12/12. **[P]** `r107-pindelta.md` §2 tabulates **nine** transports agreeing.
- **Whole-tree (not just per-file) equivalence.** **[P]** `r107-verify.md` §4: `diff -rq` fresh-clone vs tarball vs vendored, all rc 0 with no output → no differing **and no extra** files. This is the check that catches a stray/added path, which `sha256sum -c` alone cannot.
- **External corroboration.** **[P]** `r107-verify.md` §0 and `r107-pindelta.md` §4b: the Anthropic official marketplace entry (`anthropics/claude-plugins-official`) pins `source.sha = a6aa73ad…` — a channel **outside Epic's repo**, run by a different org, naming the same commit.
- **Negative control.** **[P]** `r107-rev-pin.md` §7: one byte flipped in `README.md` (length unchanged) → `sha256sum -c` `FAILED`, rc 1; unmutated → rc 0. Content-sensitive, not length-sensitive. **[moving]** `r107-mut-pin.md` (MUT-PIN) still in flight.

### W2 — Close-out gate refresh + adversary suite

- **Gate re-run here [O].** `cd <lane root> && corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo exit=$?` → `GATE RESULT: PASS (checks failed: 0)`, `exit=0`. Sub-checks: `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0`, `NAME_SET=OK NAME_BAD=0`; `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`. **[P]** `r107-planner.md` §3.1 and `r107-scribe-log.md` §1 reproduce the same run independently.
- **Gate pin constant already correct [O].** `gate/run_gate.sh:73` → `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297` = live pin; the gate needs **no pin-constant edit** this round. Gate script sha256 `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`.
- **Adversary extension.** **[moving]** `r107-adv1.md` (6 new attack classes A–F: wrong-pin acceptance, delta-blindness, card↔PROVENANCE inconsistency, pin-constant/tree divergence, manifest-superset blindness, PROVENANCE pin-prose drift), `r107-adv2.md` (17-class matrix = r102's 11 + ADV1's 6), `r107-rev-gate.md`, `r107-mut-gate.md`, `r107-mut-card.md` — all plan headers at this frame. The r102 11-class suite is on disk at `reports/round-102/adversary/F1–F6.md` + `reports/round-102/gate/`.

### W3 — Executability cards re-evaluated at the pin

- **W3 — Executability cards re-evaluated at the pin.** **[P]** `r107-cards.md` (CARDS-LEAD, COMPLETE): **all 13 cards keep their r101 verdicts at the pin; no label moves**; 12/1/0 census holds; four transports (manifest, worktree diff, git blob objects, `raw.githubusercontent`) all 12/12. Records one hygiene candidate: `meshes-textures.md` has a density table whose grep patterns were never printed and is therefore not re-derivable (no verdict change). **[moving]** `r107-cards-crit.md` (CARDS-CRITIC) and `r107-rev-cards.md` (REV-CARDS) were headers at the last poll.
- **Ground truth on disk [O].** `ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → **13**; per-card label scan → `12 static-only`, `1 unproven-runtime` (`actors-scene.md`), `0 verified-here`. The gate's card scan reproduced this independently. **[P]** `r107-planner.md` §5.1 adds: six cards carry an explicit `Not \`unproven-runtime\`` dissent marker.

### W4 — Claude→Kimi adaptation table

- **Anchor [O]/[P].** `r107-kimi-ver.md` §1 records `kimi --version` → `2.2.0`, `sha256sum ~/.kimi-code/bin/kimi` → `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af` — **identical** to the r103 correction note, so the §5 "CLI upgrade voids binary strings" invalidation rule is **not** triggered. **[O]** `adaptation-kimi.md` = 506 lines; **[P]** `r107-planner.md` §5.2: 15 rows, all pointers `upstream/…:line`.
- **Verdicts [P].** `r107-kimi-adapt.md` (KIMI-ADAPT-LEAD, COMPLETE, 487 lines): the table is stale by **content, not anchor** — the pin and the Kimi binary are both unchanged, so the §5 invalidation rule is not triggered; but three substantive gaps exist (new `.kimi-code/mcp.json` layer, project-MCP workspace-trust gate, `config.toml [mcp_servers.*]` ignored by the v2 engine), plus one promotion (`"type": "http"` tolerance → PROVEN-HERE). `r107-rev-adapt.md` (REV-ADAPT, COMPLETE, 413 lines): 5/5 rows re-measured, **all reproduce as written**, anchor chain INTACT. **[moving]** `r107-kimi-ver.md` (KIMI-ADAPT-VER) was a header at the last poll.

### W5 — PROVENANCE refresh + pin hygiene

- **PROVENANCE draft complete [P].** `r107-PROVENANCE-draft.md` (390 lines): refreshed pin/date/hash table (fetch date `2026-10-18` → `2026-10-19`), 4-transport byte-identity section, per-file hash table re-derived (identical to r101), install receipts R1–R3 re-run, and §9 preserving the r101 pin record verbatim as an append-only dated note.
- **Out-of-pin census refreshed, and it grew.** **[P]** `r107-PROVENANCE-draft.md` §8 + `r107-verify.md` §6 + `r107-pindelta.md` §4: the remote now advertises **6 open PRs** (1,2,4,5,8,9); r101 §8 recorded only PRs 1 and 4. Unvendored surface = **16 paths** (was 6), including a whole `opencode/` subtree from PR 8 and PR 9's UE-5.8.3 quirk note. **None vendored this round.**
- **PR 9 is the one that would move the pin.** **[P]** `r107-pindelta.md` §4/§5: PR 9 (`[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2`) is OPEN, unmerged, touches 3 of the 12 tracked files, and bumps plugin `3.1.1 → 3.1.2`. It also lands directly on the `executability/editor-general.md` card's "screenshots have no shipped tool" conclusion — recorded as a **testable prediction**, not adjudicated. **[P]** `r107-planner.md` §1.2 makes it a binding rule: the round target is `main`'s tip, never a PR head.
- **Pin hygiene.** **[moving]** `r107-crit-hygiene.md` (stale-hard/soft/durable classification) was a header at this frame.

### W6 — UE-runtime unlock (docker path)

- **Attempt log [O].** Pre-swarm `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` still running at this frame: `ps aux` → pid 596299; log `/var/tmp/ue-pull.log` (75 lines) ending in `…: Download complete`; `docker images | grep -i unreal` → **none**; no containers. **[P]** `r107-pull-watch.md`: image manifest = **30 layers, 26 791 359 421 B = 24.95 GiB**, config digest `b99f8c5e…`; one 12.75 GiB layer dominates the remainder. **[P]** `r107-planner.md` §4.1/§4.2 records the same and supplies a U1–U4 bounded-probe decision tree (all `--rm`, ≤300 s, no login, no license, no build).
- **Label.** UE runtime = **UNPROVEN-with-attempt-log**; the attempt log is the pull process + log tail. **[P]** `r107-rev-unlock.md` §1 names "chain link #1 — there is an unlock label to verify — BROKEN" (no seat had asserted one). **[P]** `r107-unlock-nodocker.md` §0 records the non-docker gates: no Lutris/legendary/heroic, no `~/.local/share/Epic*`, `/opt` clean; `r107-PROVENANCE-draft.md` §5 re-runs R1 (EpicGames/unreal-engine → 404), R2 (AUR → SSH publickey denied), R3 (Lutris present but operator-gated on Epic login).
- **UNLOCK-LEAD partial [moving].** `r107-unlock.md` (161 lines) has the setup, registry re-derivation, build-history analysis and safety envelope, but its §4 Results and §5 Verdict are **empty placeholders** — the probes have not run because the pull is incomplete. Its [O] contributions: measured unpack throughput **~258 MiB/s** (containerd snapshot growth over 60 s), 16/30 layers `Pull complete`, and a build history whose last step runs the editor target with `-SkipBuild` then `rm -R -f /home/ue4/.epic` (image ships with Epic credential state removed).

### W7 — Sentinels, scope, integration

- **Verdicts [P].** `r107-sent-scope.md`, `r107-sent-evid.md` (SENT-EVID COMPLETE — 34 shards audited; pin + 12/12 PASS), `r107-crit-scope.md` (COMPLETE — no cross-domain bleed; PROVINCE needs no edit), `r107-integrate.md` (COMPLETE — landing order + collision surface; confirms the 2D stray file). `r107-scribe-log.md` **DONE** (LOG + SCORECARD drafts); `r107-planner.md` **DONE** (spec, seat roster, close-out criteria); `r107-scribe-lesson.md` **DONE** (lesson draft). **[moving]** `r107-sent-scope.md` and `r107-crit-hygiene.md` were still headers at the last poll.

---

## Landed changes

**Nothing has landed yet — the orchestrator lands one integration commit.** Intended landing set (draft → destination). Rows marked **[moving]** had only a header at this frame; the orchestrator must not land a header.

| destination (corpus tree, orchestrator-owned) | source draft | state |
|---|---|---|
| `corpus/knowledge/unreal-mcp/upstream/**` (12 files) | re-vendored bytes | **[O]** on disk, byte-identical (no change needed — pin unchanged) |
| `corpus/knowledge/unreal-mcp/PROVENANCE.md` | `r107-PROVENANCE-draft.md` | **[P]** draft complete |
| `corpus/knowledge/unreal-mcp/executability/*.md` (13 cards) | `r107-cards.md` deltas | **[moving]** |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `r107-kimi-adapt.md` | **[moving]** |
| `corpus/knowledge/unreal-mcp/gate/README.md` | scanner-sha fix (§Findings) | **[moving]** |
| `corpus/lessons/r107-unreal-revendor.md` | `r107-scribe-lesson.md` | **[moving]** |
| `LOG.md` r107 entry · `SCORECARD.md` row | `r107-scribe-log.md` §2/§3 | **[P]** draft complete |
| `reports/round-107/**` (this report + all shards + `mutations/`) | — | **[O]** on disk, uncommitted |

**Not landed by this round (explicitly):** no `SHONEN.md` box flip (protected; see §SHONEN), no `PROVINCE.md` edit, no fixture or `run_battery.py` edit, no `engines.md` state-cell move. The Unreal row in `engines.md` stays `installed: no / executable headless: no`.

---

## Before → after measurements

Each carries the counting command. **Measured revision:** base HEAD `3ea02ffa…`, round-107 artifacts untracked on disk. At close the same commands must be re-run on the landing commit; a number that does not reproduce there is a FAIL for its claim.

### C1 — re-vendor / byte-identity

| measurement | command | r101 | r107 | label |
|---|---|---|---|---|
| remote pin | `git ls-remote <url> main` | `a6aa73ad…` | **`a6aa73ad…`** (unchanged) | [O] |
| pin delta | `git log --oneline old..new` | — | **empty (same SHA)** | [P] |
| vendored upstream files | `find …/upstream -type f \| wc -l` | 12 | **12** | [O] |
| manifest entries verified | `cd …/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 × `OK`, rc 0 | **12 × `OK`, rc 0** | [O] |
| clone diff | `diff -rq /var/tmp/r107-va/repo upstream --exclude=.git` | clean, rc 0 | **clean, rc 0** | [O] |
| upstream bytes | `find …/upstream -type f -exec cat {} + \| wc -c` | 63 556 | **63 556** | [O] |
| upstream lines | `… \| wc -l` | 1 022 | **1 022** | [O] |
| manifest files | `ls .manifest.d/*.sha256 \| wc -l` | 12 | **12** | [O] |
| tree object | `git write-tree` / `gh api …tree.sha` | n/a | **`b5b9624b…` (both agree)** | [P] |
| transports agreeing | — | 2 | **4–9 (seat-dependent)** | [P] |

### C2 — close-out gate

| measurement | command | before | after | label |
|---|---|---|---|---|
| gate result | `corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo exit=$?` | PASS, rc 0 (r106) | **`GATE RESULT: PASS (checks failed: 0)`, rc 0** | [O] |
| card scan | same run | `CARDS=13 … BAD=0` | **`CARDS=13 EXPECTED=13 BAD=0`** | [O] |
| label census | same run | `12/1/0` | **`12/1/0`** | [O] |
| pointer sweep | same run | `POINTERS=103 … UNRESOLVED=0` | **`POINTERS=103 … UNRESOLVED=0`** | [O] |
| gate README scanner sha | `grep -c e5521304 gate/README.md` | 4–5 hits | **5 hits — still stale** | [O] |
| adversary matrix (17 classes) | `mutations/adv*-*.sh` | r102: 11/11 caught | **[moving]** | — |

### C3 — cards + adaptation

| measurement | command | before | after | label |
|---|---|---|---|---|
| executability cards | `ls …/executability/*.md \| wc -l` | 13 | **13** | [O] |
| card labels | per-file label scan | `12/1/0` | **same** | [O] |
| subtree file census | `find …/unreal-mcp -type f \| wc -l` | 40 | **42** | [O] |
| adaptation rows | `grep -c '^\| ' adaptation-kimi.md` | 15 | **15 rows (506 lines)** | [P] |
| Kimi binary anchor | `sha256sum ~/.kimi-code/bin/kimi` | `8ee7405d…` | **`8ee7405d…`** (unchanged) | [P] |

### Runtime

| measurement | command | before | after | label |
|---|---|---|---|---|
| Unreal image present | `docker images \| grep -i unreal` | none | **none** | [O] |
| pull process | `ps aux \| grep [d]ocker pull` | running | **running (pid 596299)** | [O] |
| pull log tail | `tail /var/tmp/ue-pull.log` | layer lines | **`…: Download complete` (75 lines)** | [O] |
| image size | `docker manifest inspect …` | n/a | **30 layers / 24.95 GiB** | [P] |
| editor on host | `which UnrealEditor UnrealEditor-Cmd` | rc 2 | **rc 2** | [P] |

---

## Findings and defects (cross-shard)

1. **Gate README cites superseded scanner shas — never the installed one [O].** Installed `gate/run_gate.sh` sha256 = `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. `gate/README.md` cites **two** superseded scanners: `e5521304…` **5 times** (lines 42, 248, 283, 373, 440) and `577c8b54…` **2 times** (lines 40, 397) — and **never** `390a25ae…` (`grep -n 390a25ae gate/README.md` → no hits). So the README's own rule ("state the pin with a scanner sha256, not a bare number") is currently unsatisfiable: *neither* cited sha is the shipped file. The *number* (`POINTERS=103`) is correct and re-measured green at the installed scanner; the *identity* attached to it is stale. **[P]** `r107-planner.md` §3.2 raises the `e5521304…` half independently. Refresh action: replace the value-carrying citations with `390a25ae…` and add one line recording that the sha is the sha of the *shipped* file; acceptance `sha256sum gate/run_gate.sh` equals the sha the README now cites, and `grep -c 'e5521304\|577c8b54' gate/README.md` → 0 except a history note.
2. **`r107-VENDOR-A.md` size column is wrong on all 12 rows [O].** Its sha256 column is correct (I reproduced 12/12), but its byte sizes are not: it claims `LICENSE` = 11357, `README.md` = 7085, `plugin.json` = 178, etc. Ground truth (three ways): `git cat-file -s 4a38912a…` → **1073**; `stat -c%s upstream/LICENSE` → **1073**; `wc -c < upstream/LICENSE` → **1073**. My full per-file byte sweep matches `PROVENANCE.md` §2 exactly (LICENSE 1073, README 8398, plugin.json 487, …). **[P]** `r107-rev-pin.md` §6 flags the same defect. Impact: low (decorative metadata; the round's core claims are unaffected) but the orchestrator must **not** propagate VENDOR-A's sizes into the landed `PROVENANCE.md`.
3. **`r107-cards-crit.md` §0 miscounts the cards [O].** It records "40 files: **14** executability cards"; the measured count is **13** (`ls …/executability/*.md | wc -l` → 13), and the gate's `CARDS=13 EXPECTED=13` is the arbiter. **[P]** `r107-scribe-log.md` §1 flags the same. Treat the 14 as a scribe error, not a card count.
4. **Out-of-pin census was stale and has grown.** **[P]** r101 §8 recorded 6 paths across PRs 1 and 4; r107 finds **6 open PRs** and **16 unvendored paths**. Not a defect in the vendored bytes — a dated-snapshot refresh the PROVENANCE draft carries.
5. **`git ls-tree` blob ids are SHA-1, not sha256 [P].** `r107-VENDOR-B.md` §6 records that comparing the `ls-tree` column against sha256 values yields 12 false `DIFF`s. Any seat repeating the transport comparison must hash the same way on both sides.
6. **Two card host-state claims are now falsified by the in-flight image [O]/[P].** CARDS-CRIT (`r107-cards-crit.md` §6) found, and I reproduced, that `executability/sequencer.md:297` says *"the editor is not a containerised artifact"* and `testing-automation.md:278` says *"no public Unreal Linux container is named anywhere in the vendored tree"* — both contradicted by the `wukakuki/unreal-engine:dev-slim-5.8.3` pull this round is running. These are **host-state claims**, which is the failure class a perfect byte-check cannot catch (no card's byte-level claim failed). Refresh action: strike or qualify both sentences and record the image + tag + registry command. **Not this seat's to edit** — draft only.
7. **`adaptation-kimi.md` rows 2/3 carry a stale live-host pointer [P].** CARDS-CRIT §5: the rows cite `config.toml:2932-2937`, which today holds a `[models."opencode-go-7/qwen3.8-flash"]` table, not the hooks block they describe. **[O]** I reproduced that the cited lines are a models table. Re-pin or de-pin the pointer. (Same class as the gate-README sha drift: live-host state rots while vendored bytes do not.)
8. **The gate-README `e5521304…` drift is independently confirmed twice more [P].** `r107-crit-hygiene.md` §7 (`grep -c e5521304 gate/run_gate.sh` → **0**) and `r107-sent-evid.md` (§3.1/§4.3) both reach it; `r107-integrate.md` row 13/14 confirms 5 hits / 0 hits for `390a25ae…`. Four seats, independent routes — finding #1 is real and README-only.

---

## SHONEN for the 3D lane

**`SHONEN.md` is protected — this seat did not touch it and no box is flipped this round.** Measured here **[O]**: `git hash-object SHONEN.md` = `git rev-parse HEAD:SHONEN.md` = `8d85902c19010deb4fa154e16a2c12ad56ff10d1` (MATCH HEAD); `grep -c '^- \[x\]' SHONEN.md` → **1** (box 2 only). Boxes 1, 3, 4 remain `[ ]`. A `[x]` requires a **named non-author verifier** who is not a dispatched seat; self-attestation is `[~]`.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]` `SKILL.md` MATCH HEAD (unmodified this round). r106 recorded its shape (6 decision rows A–F, 8 error signatures, 12 checklist items, 6 refusals). **Not `[x]`** — no named non-author accepted the table; `SKILL.md` §4 P/C precedence still owed. r107 does not close it.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2 (verifier `game-dev-3d-r2-review-retry`, pointer `corpus/lessons/r2-independent-review.md`). **r107 adds no check** — this is a side-round; the end-to-end task is not re-run.
- **Box 3 — instructions executable without oral context.** `[~]` The `SKILL.md` §1 / `corpus/fixtures/PINNED-ENV.md` commands ran in r106 with no oral context. **Not `[x]`** — residuals open: P/C ruling; pinned total ≠ ambient PATH; `GATE_WORKDIR` needed (`/tmp` per-user quota exhausted); `engines.md` three.js parenthetical. r107 did not re-run them.
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` `PROVINCE.md` MATCH HEAD. **Not `[x]`** — r105 lesson bleed (`reports/round-105/lesson/bleed.md` ruled FAIL) is still carried; no seat was asked to rule `PROVINCE.md` accuracy this round.

**What `SHONEN.md` should remain.** Byte-identical to HEAD; a close-time flip of box 1, 3, or 4 is **not supported** by this round. Current text: boxes 1, 3, 4 `[ ]`, box 2 `[x]`.

---

## Gaps and open items (honest)

1. **Some sibling drafts remained incomplete at the late frames.** At the second late-frame poll the still-header-only shards were: ADV1/ADV2 (adversary matrix), REV-GATE, MUT-GATE, MUT-CARD, CARDS-CRIT, REV-CARDS, KIMI-VER, CRIT-HYGIENE, SENT-SCOPE, VERIFY-2, GATE-LEAD, UNLOCK-LEAD/UNLOCK-VER. Their workstreams are *status pointers*, not results; the orchestrator must re-measure them at the landing commit or land only the shards that closed.
2. **Adversary suite result absent.** The 17-class detection matrix (ADV1 6 + r102 11) had not run on paper; the gate PASS is the clean run only. MUT-PIN's 18-class *mutation* sweep did land (see addendum) but it exercises the transport legs, not `run_gate.sh`'s own checks.
3. **No unlock label exists.** UE runtime is UNPROVEN-with-attempt-log. If the pull finishes before close, UNLOCK seats must add a bounded U1–U4 probe transcript or the label stays UNPROVEN.
4. **Subtree census 40 → 42.** `r107-cards-crit.md` counted 40 files; this seat counts 42 (13 cards + 2 gate + 12 upstream + 12 manifest + 3 top-level). Re-measure at close; do not smooth.
5. **No live-editor evidence exists or can exist here.** Engine install is blocked pending an operator Epic-account link (R1 404, R2 SSH-denied). Nothing in this round asserts Unreal behavior.
6. **Report lands last.** The landing commit hash is an `<L1 fills>` slot; all close-of-round numbers above must reproduce on that commit.

---

## Late-frame addendum (shards that closed after the first evidence frame)

Re-polled at `2026-10-19T03:11Z`. These shards went from header → **complete** and supersede the **[moving]** marks above for their workstreams.

- **W6 — UNLOCK-NODOCKER COMPLETE [P].** `r107-unlock-nodocker.md` (232 lines): verdict **UNPROVEN-with-attempt-log**. All four non-docker routes are credential-gated — A (Epic direct download: CDN `403` with a 111-byte `application/xml` body; the web-page `403` is disambiguated as a **Cloudflare** bot wall, not a credential gate), B (every AUR source recipe gates on `git ls-remote git@github.com:EpicGames/UnrealEngine` in `prepare()`, before any compile), C (`unreal-engine-bin` is a `manual://` stub that delegates to A), D (Lutris installs freely but the engine needs an Epic login through wine). Sharpest receipt: `gh api user/orgs` → `vgpnk-holdings-llc` only — **no `EpicGames` membership** — while `gh api orgs/EpicGames` is publicly visible, so the repo 404 is the Epic-link gate, not a broken token. New census rows: `unreal-engine-src-5.4…5.8` (5.8.3 tracks the same engine line as the docker image). No login, no EULA, no `makepkg`, no container.
- **W4 — SCRIBE-LESSON DRAFT COMPLETE [P].** `r107-scribe-lesson.md` (219 lines): draft `corpus/lessons/r107-unreal-revendor.md` ready for the orchestrator. It independently reproduced three transports (clone / codeload tarball / REST tree), the manifest 12× `OK`, and the gate PASS, and carries the round's five lessons (re-vendor is a measurement not an assumption; three transports that share no local state; a no-op pin moves only the stamp; UNPROVEN-with-attempt-log; watch the out-of-pin surface not the pin). Cross-check: no numeric divergence vs sibling shards.
- **W1/W5 — PIN-DELTA + PROVENANCE drafts COMPLETE [P].** `r107-pindelta.md` (322 lines): verdict **no pin delta**, **nine** transports agree, out-of-pin census **6 → 16 paths across 6 open PRs**; PR 9 (`…bump to 3.1.2`) is the one that would move the pin, and it lands on the `editor-general.md` "no screenshot tool" conclusion (recorded as a testable prediction, not adjudicated). `r107-PROVENANCE-draft.md` (390 lines): 4-transport byte-identity, install receipts R1–R3 re-run, §8 refreshed to 16 paths, §9 preserves the r101 pin record verbatim. `r107-rev-pin.md` (386 lines): **DONE** — 4 transports agree on pin **and tree SHA `b5b9624b…`**; `bash mutations/rev-pin.sh` → `VERDICT: PASS`, rc 0; independently flags the VENDOR-A size defect (finding #2 above).
- **Still headers at the late frame [moving].** ADV1/ADV2 (adversary matrix), REV-GATE, MUT-GATE, MUT-CARD, CARDS-CRIT/REV-CARDS, KIMI-VER, CRIT-HYGIENE, SENT-SCOPE, VERIFY-2, GATE-LEAD, UNLOCK-LEAD/UNLOCK-VER. Their workstreams remain status pointers.
- **Docker (late frame) [O].** Pull still running (pid 596299, log now 76 lines, `…: Download complete`); `docker images | grep -i unreal` → **none**. Runtime label unchanged: **UNPROVEN-with-attempt-log**.

## Second late-frame block (verdicts that landed at ~03:12Z)

- **W2/W7 — SENT-EVID COMPLETE [P].** `r107-sent-evid.md` (264 lines): audited 34 shards against HARD RULE 5. **Verdict: the round's two load-bearing claims — pin identity and 12/12 byte-identity — PASS independent re-derivation**; two shards are defective (its F1 = my finding #2, its F2 = my finding #3, both reproduced by it independently); D5 (UNPROVEN honesty) PASSes fleet-wide. It also flags **F4**: `r107-gate.md` promised `mutations/gate-draft.sh`; no such file exists — the gate-refresh deliverable is **UNPROVEN, not done**.
- **W1 — MUT-PIN COMPLETE, negative control valid [P].** `r107-mut-pin.md` (268 lines): clean tree 4/4 PASS, mutated tree 0/4 PASS; an **18-class × 4-leg sweep** where all three byte transports catch every class (`transport blind spots: 0`). Three structural blind spots found and asserted: a **self-consistent regenerated manifest** passes its own `sha256sum -c`; an **extra file** is invisible to the manifest leg; a **content swap between two paths** defeats a path-blind multiset verifier. It independently reproduces my finding #2 (sizes) by a fifth route.
- **W3 — CARDS-LEAD COMPLETE [P].** `r107-cards.md` (324 lines): **all 13 cards keep their r101 verdicts at the pin; no label moves**; 12/1/0 census holds; four transports (manifest, worktree diff, git blob objects, `raw.githubusercontent`) all 12/12. Records that `meshes-textures.md` has one density table whose grep patterns were never printed and is therefore **not re-derivable** — a hygiene candidate, no verdict change.
- **W4 — KIMI-ADAPT-LEAD COMPLETE [P].** `r107-kimi-adapt.md` (487 lines): the adaptation table is stale by **content**, not anchor (pin unchanged, Kimi binary unchanged). Three substantive gaps: a new third MCP layer (`.kimi-code/mcp.json`); project-level MCP servers behind a **workspace-trust gate**; `config.toml [mcp_servers.*]` is a **Codex idiom the v2 engine ignores**. One **promotion**: the `"type": "http"` tolerance moves from `unproven-runtime` to **PROVEN-HERE**. **[P]** `r107-rev-adapt.md` (413 lines): 5/5 rows re-measured, **all reproduce as written**, anchor chain INTACT, no row wrong (one citation nit in a *prior* round's transcript).
- **W6 — REV-UNLOCK COMPLETE, extends evidence to tier T1 [P].** `r107-rev-unlock.md` (284 lines): verdict **UNPROVEN-with-attempt-log, on a T1 evidence base**. Load-bearing [O]: the registry manifest bytes it fetched hash to the **published tag digest** `sha256:3f0886cf…` (30 layers / 26 791 359 421 B); the config blob digest matches too; build history copies a **prebuilt editor tree** in and runs the editor target with `-SkipBuild`, so the image is built to *run* an editor, not to compile one. Blocker for T2: **no NVIDIA container runtime on this host**, so only a headless probe is possible once pulled. It supplies a T0–T3 adjudication tier table and flags that the pull was **launched from the 2D lane's cwd** — a provenance fact the orchestrator should record.
- **W7 — INTEGRATE COMPLETE [P].** `r107-integrate.md` (272 lines): landing order + collision surface. **[O]** Confirms a **stray `reports/round-107/r107-planner.md` in the 2D lane** (I reproduced it: 571 B, uncommitted) and that `SKILL.md:178` already cites the installed scanner sha `390a25ae…` while `gate/README.md` does not — i.e. the cascade is README-only. **[O]** `sha256sum -c .manifest.d/*.sha256` (glob) → rc 0, 24 lines.
- **W7 — CRIT-SCOPE COMPLETE [P].** `r107-crit-scope.md` (345 lines): **no cross-domain bleed** — all nine contest rows `NOT-ABSORBED` or `NO CHANGE`; `PROVINCE.md` needs no edit (`engines.md` Unreal cell unmoved; fixture tree diff-clean). One hygiene finding (the 2D stray file, self-corrected).
- **W3/W7 — CARDS-CRIT + CRIT-HYGIENE COMPLETE [P].** `r107-cards-crit.md` (520 lines): attacked 3 cards line-by-line + swept all 13 mechanically; **no card's byte-level claim failed** (12/12 identity, counts, history facts all confirmed), but two **host-state** claims are falsified (§Findings #6) and one live-host pointer is stale (#7). It also names the decisive next probe: once the image is local, `docker run --rm <img> ls …/Engine/Plugins` (or a `.uproject` grep for `AllToolsets`) converts "container exists" into "viable runtime path" or kills the route. `r107-crit-hygiene.md` (358 lines): stale-hard/soft/durable classification; independently confirms the gate-README drift (§Findings #8).
- **W1 — VERIFY-2 COMPLETE [P].** `r107-verify2.md` (233 lines): built its own manifests (never reading a sibling's) across transports A/B/C/D; **no disagreement found** — pin, tree id `b5b9624b…`, tarball sha `d091941c…`, and the 12/12 byte-identity all AGREE with VERIFY-LEAD/VENDOR-A/B; independently confirmed the gate PASS **offline and live** and both negative controls failing as designed. UE runtime correctly deferred to the unlock seats.
- **W7 — SENT-SCOPE COMPLETE [P].** `r107-sent-scope.md` (329 lines): boundary/identity audit — **PASS** on lane identity, all r107 writes inside `reports/round-107/`, fixtures byte-identical to HEAD (108/108 `OK`; battery `f456bd00…` both sides), no battery execution, no writes into `corpus/knowledge/unreal-mcp/`, zero commits, protected ledgers untouched. Two edge defects: **F1** the 2D-lane stray file (confirms my finding #7 — it is the first 9 lines of our planner shard + `STATUS: in-progress`) and **F2** 9 scratch files at bare `/tmp` (e.g. `/tmp/h1`, cited by `r107-VENDOR-B.md:122`) instead of `/var/tmp/r107-*`.
- **W6 — UNLOCK-LEAD still pending [moving].** `r107-unlock.md` (161 lines) has the setup, registry re-derivation, build-history analysis and safety envelope, but §4 Results and §5 Verdict are **empty placeholders** — the probes have not run because the pull is incomplete. Its [O] contribution: measured unpack throughput **~258 MiB/s** (containerd snapshot growth), 16/30 layers `Pull complete`; and the build history's last step runs the editor target with `-SkipBuild` and then `rm -R -f /home/ue4/.epic` (the image ships with Epic credential state removed). The runtime label is not yet asserted.
- **Docker (final frame) [O].** Still running; no image; pull log advancing through layers. Runtime label unchanged: **UNPROVEN-with-attempt-log**.

### Additional findings from the late shards (verified by this seat where marked)

7. **A stray `reports/round-107/r107-planner.md` sits in the 2D lane [O].** Reproduced: `ls ../game-dev-2d-shokunin/reports/round-107/` → `r107-planner.md` (571 B, untracked). A mis-cwd'd seat dispatch wrote into the sibling lane. It is **not** a 3D-lane artifact and must be deleted or recorded by the orchestrator; it is the one boundary slip this round (§HARD RULE 1). The 3D lane itself is clean (`git status --short` → only `?? reports/round-107/`).
8. **Gate-README citation cascade is contained [O].** `SKILL.md:178` cites the *installed* scanner `390a25ae…`; only `gate/README.md` cites the superseded `e5521304…` (×5) and `577c8b54…` (×2). So finding #1 is a README-only refresh, not a lane-wide one.
9. **`gate/README.md:248` also pins a stale `adaptation-kimi.md` sha [O].** It cites `084a34cd…`; the live file is `a2db1d283ef3…`. `084a34cd` appears nowhere else in the subtree, so it is a stale expectation in the same README refresh.
10. **`gate-draft.sh` was never produced [P].** `r107-gate.md` planned `reports/round-107/mutations/gate-draft.sh`; `mutations/` does not contain it. The gate-refresh deliverable is **outstanding** — the orchestrator must not treat the gate-refresh as done.
11. **504 tracked files cite the pin string [O].** `git grep -l a6aa73ad -- . | wc -l` → 504. Since the pin did not move, none need editing — but a future re-pin at a *moved* commit would touch a large citation surface (recorded for the carry queue).

---

## Commands this seat ran (receipts)

```text
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/main --jq '.sha+" | "+.commit.committer.date'
a6aa73ada02a9fb1f5415bec491f9942c519b297 | 2026-09-17T01:28:32Z

$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | tail -1
upstream/skills/unreal-skill/SKILL.md: OK          # 12/12 OK, rc 0
$ diff -rq /var/tmp/r107-va/repo upstream --exclude=.git ; echo rc=$?
rc=0
$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l
12
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh ; echo exit=$?
… CARDS=13 EXPECTED=13 BAD=0
… CENSUS static-only=12 unproven-runtime=1 verified-here=0
… POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
exit=0

$ ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l
13
$ find corpus/knowledge/unreal-mcp -type f | wc -l
42
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ grep -oE 'e5521304|390a25ae' corpus/knowledge/unreal-mcp/gate/README.md | sort | uniq -c
      5 e5521304            # stale scanner sha; 390a25ae absent
$ git cat-file -s 4a38912a3051e6b6fcf3aec79ac71ecdfbf81ff5 ; stat -c%s corpus/knowledge/unreal-mcp/upstream/LICENSE
1073
1073                            # VENDOR-A claims 11357 — refuted

$ git rev-parse HEAD
3ea02ffaafc6c618bb97a19f103a3d28ecdc2638
$ git hash-object SHONEN.md; git rev-parse HEAD:SHONEN.md; grep -c '^- \[x\]' SHONEN.md
8d85902c19010deb4fa154e16a2c12ad56ff10d1
8d85902c19010deb4fa154e16a2c12ad56ff10d1
1
$ git diff --quiet HEAD -- corpus/fixtures/ ; echo fixtures_clean=$?
fixtures_clean=0
$ git rev-parse HEAD:corpus/fixtures/run_battery.py
dd2d9b74448afddb88dcf2da56008302eba8060d

$ docker images | grep -ci unreal ; tail -2 /var/tmp/ue-pull.log
0
99f3c2b0a1db: Download complete
84bd5dd0f39b: Pull complete
```

**Honest limits.** This seat is a report assembler, not an author: it re-ran the load-bearing static checks (pin, manifest, clone diff, gate, census, invariants) and read every sibling shard, but it did **not** re-run the 3-transport verification, the adversary suite, or any runtime probe. Where a sibling had not landed, this report says so rather than inventing a result. No Unreal runtime claim is made anywhere in this file.
