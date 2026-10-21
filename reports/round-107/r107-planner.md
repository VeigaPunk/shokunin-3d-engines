# r107-planner — SPEC-PLANNER (3D side-round, round 107)

Plan (5 lines):
1. Read PROVENANCE.md/README.md at pin a6aa73ad + round-101..102 gate/adjudicator files + 2D contract side-round clause.
2. Establish fresh-pin target: current upstream HEAD sha + file inventory; compare to a6aa73ad.
3. Define 3-way verification protocol (3 independent transports) for 12/12 tracked files byte-identical.
4. Design gate-refresh, unlock evaluation plan (docker), seat roster, close-out criteria.
5. Emit spec here; no writes to corpus/knowledge/unreal-mcp/.

STATUS: **complete**. Lane HEAD `3ea02ff` (r106 report-last; work `4755b0e`). All measurements
`2026-10-19T03:08:41Z`–`03:11:25Z` UTC. Seat wrote this file only; nothing under
`corpus/knowledge/unreal-mcp/` was touched. Tags: **[O]** observed here · **[I]** inference ·
**[?]** unknown. **No Unreal runtime claim** — editor not installed, unlock in flight (§4).

---

## 0. Verdicts this seat delivers (grep these)

```text
PIN_TARGET=a6aa73ada02a9fb1f5415bec491f9942c519b297   (UNMOVED; re-pin is a no-move re-pin)
PIN_TRANSPORTS=4/4 AGREE
VERIFY_3WAY=GREEN on the current tree (12/12 byte-identical)
GATE_STATUS=PASS POINTERS=103 CARDS=13 CENSUS=12/1/0 UNRESOLVED=0
GATE_DEFECT=README scanner-sha pin stale (e5521304… cited, 390a25ae… installed)
UE_UNLOCK=UNPROVEN-IN-FLIGHT (pull running, 24.95 GiB / 30 layers, image not yet local)
```

---

## 1. Fresh-pin target and the re-pin protocol

### 1.1 What "fresh pin" must mean this round

**The upstream tip has not moved.** At `2026-10-19T03:08:41Z` four independent transports all
resolve `main` to the r101 pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` **[O]**:

```sh
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-19T03:08:41Z
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main      # exit 0
$ git ls-remote --symref <url> HEAD
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD                 # exit 0
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/main \
    --jq '.sha+" "+.commit.committer.date+" "+.commit.message'
a6aa73ada02a9fb1f5415bec491f9942c519b297 2026-09-17T01:28:32Z [MCP] Permit safe concurrent tool calls
$ git -C /var/tmp/r107-planner/clone rev-parse HEAD      # fresh clone made this round
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

The whole `ls-remote` ref list adds no branch head **[O]**: `refs/heads/main` is the only branch;
the other 12 refs are `refs/pull/{1,2,4,5,8,9}/{head,merge}` — PRs, none merged into `main`.

**Consequence for the round brief.** "re-vendor … at a fresh pin" cannot mean "re-vendor at a
new SHA" — there is no new SHA. It must mean: **re-clone from scratch, re-derive the pin, and
re-record it with a fresh fetch date and fresh receipts**, i.e. a *no-move re-pin*. Deliverable
form: `PROVENANCE.md` gains a re-pin row carrying the 2026-10-19 fetch date and the four
transport outputs; the SHA field itself stays `a6aa73ad…`. Any shard that claims a *new* pin
without a merged upstream commit is fabricating and must be rejected at adjudication.

### 1.2 The one way the target could move mid-round

PR **#9** (`[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2`) is **OPEN**, `mergedAt: null`,
head `a5180ccd03c2813682a7fa19ca25ee9967bfe1de`, last updated `2026-10-18T21:13:37Z` **[O]**. It
touches exactly 3 of the 12 tracked files (`plugin.json` +1/−1, `skills/unreal-mcp/SKILL.md`
+1/−1, `skills/unreal-mcp/references/operations.md` +7/−0) and would move the pin to
`a5180ccd…` **only if it merges into `main`**.

**Rule (binding for this round):** the round target is `main`'s tip, never a PR head. If a
freshness seat observes `main` ≠ `a6aa73ad…`, the round **stops and re-pins to the new tip**
(re-clone, re-hash all 12, new PROVENANCE rows) rather than mixing a PR head into the vendored
tree. A PR head must never be vendored: it is unreviewed, unmerged, and its `mergedAt: null`
makes the provenance record false.

### 1.3 Inventory invariants to re-assert at the new fetch date

```sh
$ git -C /var/tmp/r107-planner/clone ls-files | wc -l
12
$ git -C /var/tmp/r107-planner/clone ls-files
.claude-plugin/plugin.json  .gitignore  CODEOWNERS  LICENSE  README.md
hooks/hooks.json  hooks/unreal-context.sh
skills/create-toolset/SKILL.md  skills/unreal-mcp/SKILL.md
skills/unreal-mcp/references/operations.md  skills/unreal-mcp/references/setup.md
skills/unreal-skill/SKILL.md
$ git -C /var/tmp/r107-planner/clone rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959
```

`12` tracked files, all mode `100644`, no symlinks/submodules/LFS **[O]**. The round brief's
"12/12 tracked files" and r101's "11 upstream paths" are both correct about different things:
**11 vendoring seats**, of which `seat11` holds two files (`CODEOWNERS` + `.gitignore`) —
`.manifest.d/seat11.sha256` is 2 lines, `seat01`–`seat10` are 1 line each **[O]**. Keep the
12-file framing; do not "fix" the manifests to 12 seats.

### 1.4 Acceptance command for the fresh-pin claim

```sh
# run by a non-author seat at close, on the committed tree
git ls-remote <url> main | grep -q a6aa73ada02a9fb1f5415bec491f9942c519b297 && echo PIN_OK
```
Expected: `PIN_OK`. Any other SHA → the round is stale and must re-pin per §1.2.

---

## 2. Three-way verification protocol (12/12 byte-identical)

The contract asks for **3 independent transports**. This seat ran **four** and all agree on the
current tree **[O]**. The protocol below is the *re-runnable* form; a verifier must re-run it on
the committed bytes, not accept these pastes.

Pinned constants:

```sh
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
CORPUS=corpus/knowledge/unreal-mcp
WORK=/var/tmp/r107-<seat>        # NOT /tmp — per-user /tmp quota; see §3.4
```

**T1 — manifest sweep (local recompute vs committed reference).**
```sh
cd "$CORPUS" && sha256sum -c .manifest.d/audit-reference.sha256
```
Expected: 12× `OK`, `exit 0`. Observed `2026-10-19T03:09:00Z` **[O]**: 12× `OK`, exit 0.

**T2 — working-tree equivalence vs a fresh clone (path set + bytes).**
```sh
git clone "$REPO" "$WORK/clone" && git -C "$WORK/clone" rev-parse HEAD   # == $PIN
diff -rq "$WORK/clone" "$CORPUS/upstream" --exclude=.git
```
Expected: `rev-parse` == `$PIN`; `diff -rq` prints nothing, `exit 0`. Observed **[O]**: both hold.
This transport catches an *added or deleted* path, not only a changed byte.

**T3 — git object-id compare (content-addressed, independent of the working tree).**
```sh
git -C "$WORK/clone" ls-tree -r HEAD --format='%(objectname) %(path)' | sort -k2 > "$WORK/blob-clone.txt"
cd "$CORPUS" && for f in $(find upstream -type f | sed 's|^upstream/||' | sort); do
  printf '%s %s\n' "$(git hash-object "upstream/$f")" "$f"; done > "$WORK/blob-local.txt"
diff "$WORK/blob-clone.txt" "$WORK/blob-local.txt"
```
Expected: no output, `exit 0`. Observed **[O]**: identical, `T3 exit=0 IDENTICAL`. Genuinely
independent of T2: T2 compares bytes on disk, T3 compares git blob ids, so matching bytes with a
rewritten index still splits the two.

**T4 — GitHub REST blob API (network transport, does NOT use the git protocol).**
```sh
for p in $(git -C "$WORK/clone" ls-files); do
  a=$(gh api "repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/contents/$p?ref=$PIN" --jq .sha)
  b=$(git hash-object "$WORK/clone/$p"); [ "$a" = "$b" ] && echo "OK $p" || echo "DIFF $p"; done
```
Expected: 12× `OK`. Observed `2026-10-19T03:09:05Z` **[O]**: 12× `OK`. The API `sha` is the
git-blob **sha1** (`LICENSE` → `4a38912a3051e6b6fcf3aec79ac71ecdfbf81ff5`), so compare it to
`git hash-object`, **not** to sha256 — a seat comparing it to `sha256sum` reports 12 false
`DIFF`s. This transport survives a corrupted local object store, because the bytes come from
GitHub rather than from the clone.

**Failure semantics.** Any of T1–T4 red → the claim "12/12 byte-identical" is FAIL, not partial.
T4 unavailable (no network / rate limit) → record `T4=BLOCKED(network)` and keep T1–T3 as the
3-way; do **not** silently count a blocked transport as agreement.

---

## 3. Gate-refresh design

### 3.1 Current state (measured, not inherited)

`GATE_WORKDIR=/var/tmp/r107-planner corpus/knowledge/unreal-mcp/gate/run_gate.sh` at
`2026-10-19T03:09:00Z` **[O]**:

```text
CHECK 1  MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0                      STEP=PASS
CHECK 2  CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0
         BLOB_DIFFS=0                                                  STEP=PASS
CHECK 3  CARDS=13 EXPECTED=13 BAD=0 · CENSUS static-only=12 unproven-runtime=1 verified-here=0
         NAME_SET=OK NAME_BAD=0                                        STEP=PASS
CHECK 4  POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0  STEP=PASS
GATE RESULT: PASS (checks failed: 0)   exit=0
```

The gate is **green today**. r106's clean run and both its negative controls (dead `REPO` → exit
2 `BLOCKED`; bad `GATE_REF` → exit 1 `FAIL`) reproduce against this same scanner **[O/D]**.

### 3.2 The defect the refresh must fix — a stale scanner-sha pin in `gate/README.md`

The installed scanner is `run_gate.sh` sha256
`390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (442 lines) **[O]** — the
same sha cited by r105/r106 receipts and by r106's adjudicator draft **[O/D]**. But
`gate/README.md` still pins its expected values against the **superseded** scanner `e5521304…`
at lines 248, 283, 373, 440 **[O]**, and `390a25ae…` appears nowhere in that file **[O]**. So
the README's own "the pin is stated with a scanner sha256 rather than as a bare number" rule is
currently unsatisfiable: the stated scanner is not the shipped one. The *number* (`103`) is
correct — it was re-measured green at this scanner — but the *identity* attached to it is wrong.

**Refresh action (orchestrator lands it; this seat drafts only):** replace all four `e5521304…`
citations with `390a25ae…`, re-state the measured values (`POINTERS=103 POINTER_STRINGS=41
SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, `CARDS=13`, `CENSUS 12/1/0`, `NAME_SET=OK`) against
that sha, and add one line recording that it is the sha of the *shipped* file. Acceptance:

```sh
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # must equal the sha the README now cites
grep -c 'e5521304' corpus/knowledge/unreal-mcp/gate/README.md   # must be 0 (except a history note)
```

### 3.3 What must NOT change

- The 4-check structure, the fail-closed semantics, the `BLOCKED`-vs-`FAIL` split (exit 2 vs 1),
  the tool-requirement guard, and the `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` scratch logic
  are r102–r104 hardening that adversarial seats bought. Do not simplify them to make a refresh
  easier.
- `EXPECTED_CARDS=13`, `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0` — a
  refresh that moves the census to make a card "pass" is exactly the fabrication the gate exists
  to catch. If the unlock (§4) ever produced a `verified-here` receipt, the census change is a
  *claim* with its own evidence, adjudicated separately — never a quiet constant edit.
- Do not add a check that requires network *by default*. CHECK 2's clone is the only network
  dependency and it has a `BLOCKED` state; new checks must preserve that property.

### 3.4 Refresh risk: scratch root under quota pressure

`/tmp` on this host is a 16G tmpfs shared under a per-user quota and has exhausted mid-round
before (`reports/round-103/gate/close-runs.md`, `reports/round-104/gate/workdir.md`) **[O/D]**.
Every r107 gate run — by any seat, including adversary seats — must pass
`GATE_WORKDIR=/var/tmp/r107-<key>` (or a roomy dir under the lane). A run without it can die as
`Disk quota exceeded` and be misread as a content failure. `df -h /` → `930G, 18% used` **[O]**,
so the lane repo itself is a safe scratch root.

---

## 4. Unlock evaluation plan (UE runtime)

### 4.1 Status at this seat's runtime: **UNPROVEN-IN-FLIGHT**

```sh
$ ps aux | grep 'docker pull' | grep -v grep
vgpnk 596299  ... docker pull wukakuki/unreal-engine:dev-slim-5.8.3      # started 00:07 local
$ docker images | grep -i unreal
(no output)                                                             # image NOT local yet
$ tail -3 /var/tmp/ue-pull.log
70a18876cabd: Pull complete ; 99f3c2b0a1db: Download complete ; 84bd5dd0f39b: Pull complete
$ stat -c '%y %s' /var/tmp/ue-pull.log
2026-10-19 00:09:37 2308          # log mtime advanced repeatedly while this seat ran
$ docker manifest inspect wukakuki/unreal-engine:dev-slim-5.8.3
layers= 30   total_bytes= 26791359421   total_GiB= 24.95
config_digest= sha256:b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e
```

The pull is **alive and progressing** (new layers completed during this seat's window) but has
not finished. So the unlock is **not blocked** and **not proven** — it is in flight. Any shard
that reports either "UE runtime proven" or "UE runtime blocked" at this instant is wrong; the
honest label is `UNPROVEN (pull in flight)` with this receipt.

### 4.2 Decision tree for the unlock seat

Run these in order; the first one that fires decides the round's runtime label.

| # | test | command | result → label |
|---|---|---|---|
| U1 | pull completed? | `docker images --format '{{.Repository}}:{{.Tag}}' \| grep -x wukakuki/unreal-engine:dev-slim-5.8.3` | non-empty → go U2; empty → `UNPROVEN (pull in flight)` |
| U2 | image starts at all? | `timeout 120 docker run --rm --entrypoint /bin/sh <img> -c 'echo ALIVE'` | `ALIVE` → go U3; timeout/err → `UNPROVEN (image present, no bounded start)` |
| U3 | engine binary present? | `timeout 120 docker run --rm --entrypoint /bin/sh <img> -c 'ls -la /home/ue4/UnrealEngine/Engine/Binaries/Linux/ 2>/dev/null \|\| find / -maxdepth 6 -name UnrealEditor -type f 2>/dev/null \| head'` | a path → go U4; none → `UNPROVEN (image present, no editor binary)` |
| U4 | bounded smoke probe | `timeout 300 docker run --rm --entrypoint /bin/sh <img> -c '<editor> -NullRHI -unattended -ExecCmds="Quit" -log'` **or** a headless CLI probe the image documents | editor starts+exits 0 → candidate `proven-with-evidence`; non-zero/hang → `UNPROVEN (attempt log below)` |

**Bounded-probe rules (hard, from the contract and lane rules).**
- Every container run carries `--rm` and a `timeout`. No probe may run longer than 300 s; no
  editor session is left running. The contract forbids "running the UE editor outside bounded
  container smoke probes" — a probe *is* the authorized form, an interactive session is not.
- **Never** log into an Epic account, accept a license, or start an engine build >2 h, even
  inside the container. If the image demands an Epic login to start, that is `UNPROVEN
  (login-gated)` and the attempt log stops there.
- Record for every attempt: full command, `$?`, wall time, and the first/last 20 lines of output.
  An attempt with no saved output is not an attempt.
- A successful *container start* is **not** a runtime proof. Only a successful read-only Unreal
  tool call (or an editor process reaching a defined ready state and exiting cleanly) would be,
  and even then the receipt must name the tool and its output. `docker run` echoing `ALIVE` proves
  the image boots — nothing about Unreal.

### 4.3 Either way, the round closes

The contract says: "UE runtime status honestly labeled (proven with command evidence if the
docker unlock succeeds, else unproven with the attempt log)". Both outcomes close the side-round.
The unlock seat must produce `reports/round-107/unlock/attempt-log.md` with the U1–U4 table
filled, one row per attempt, **even in the success case** (the log is what makes a `proven` label
citable). If the pull is still in flight at round close, the log records
`U1=PENDING (24.95 GiB, 30 layers, pull pid …, log mtime …)` and the label is `UNPROVEN`.

---

## 5. Executability cards + Claude→Kimi adaptation table refresh

### 5.1 Cards — the census is the thing to protect

13 cards under `executability/`, exactly one label each, labels on lines 4–15 **[O]**. Current
census `static-only=12 unproven-runtime=1 verified-here=0`; the single `unproven-runtime` is
`actors-scene.md:5` **[O]**. Six cards carry an explicit dissent marker
(`Not \`unproven-runtime\``): `animation-controlrig, blueprints, editor-general, gameplay-gas,
materials, meshes-textures` **[O/D, r106]**.

**Refresh rule.** A card may be edited only to (a) cite the new fetch date, (b) cite the new
scanner/README shas, or (c) change a label **with** a receipt that justifies the new label. The
unlock (§4), if it succeeds, is the only plausible route to a `verified-here` label — and even
then only for the subsystem the probe actually exercised, one card at a time, never as a census
sweep. Absent an unlock receipt, the census must stay `12/1/0` and the gate's
`EXPECTED_STATIC/UNPROVEN/VERIFIED` constants stay untouched.

**P/C ruling is still PENDING and is not this round's to resolve.** `SKILL.md` §4
("state it, do not resolve it") remains the binding interim **[O/D]**. A refresh seat that
"resolves" the `static-only` vs `unproven-runtime` vocabulary overlap by editing labels is
overstepping; route it to the operator package instead.

### 5.2 Adaptation table — targeted refresh, not a rewrite

`adaptation-kimi.md` is 506 lines, 15 rows, every row `verified-here` or `static-only`, all
pointers `upstream/…:line` **[O]**. Kimi CLI is `2.2.0` (`/home/vgpnk/.kimi-code/bin/kimi`,
BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`) **[O]**.

**A same-SHA re-pin cannot invalidate any row** (all 15 source pointers are vendored bytes that
did not change). **Rows that an environment change can invalidate** — a Kimi upgrade or a
plugin-manifest change — are the `verified-here` set: **1, 2, 3, 4, 8, 9, 11**. The refresh seat
must re-run exactly those probes and, if one now disagrees, flip the row to `static-only`
**with the failing probe pasted**, rather than leaving a stale `verified-here`. If PR #9 merged
(§1.2), rows citing `skills/unreal-mcp/SKILL.md` / `references/operations.md` line numbers would
shift and must be re-pointed.

---

## 6. Seat roster — 40 seats, devin/deepseek-v4-1-flash-high

The contract fixes the side-round at "devin/deepseek-v4-1-flash-high, 32–64 seats"; the round
brief fixes 40. Partition by artifact so no two seats own a path:

`reports/round-107/r107-<key>.md` for all rows below (unlock rows: `reports/round-107/unlock/<key>.md`):

1 **SPEC-PLANNER** this spec · 2 FRESH-CLONE fresh clone at `$WORK`, re-derive pin + tree sha ·
3 PIN-TRANSPORT T1–T4 verbatim · 4 PIN-PR-WATCH PR #9 / `main` drift, stop-rule §1.2 ·
5 INVENTORY 12 tracked files, modes, seat-vs-file framing · 6–9 VERIFY-T1..T4 each transport ·
10 **VERIFY-CHAIR** owns the 3-way verdict (non-author) · 11 PROVENANCE-WRITER re-pin rows
(draft only) · 12 LICENSE-RECHECK MIT notice retention · 13 CARDS-CENSUS label scan + census +
dissent marker · 14 CARDS-ACTORS the single `unproven-runtime` card · 15 CARDS-DISSENT the 6
dissent cards, P/C framing · 16 ADAPT-ROWS rows 1–8 re-probe · 17 ADAPT-ROWS2 rows 9–15 ·
18 ADAPT-POLICY verification-policy consistency · 19 UNLOCK-DOCKER U1–U4 + attempt log ·
20 UNLOCK-IMAGE manifest/size/digest receipts · 21 UNLOCK-CONTAINER bounded smoke probe ·
22 UNLOCK-RUNTIME tool-call-level probe (only if 19–21 clear) · 23 **UNLOCK-CRITIC** attacks any
`proven` claim (non-author) · 24 GATE-REFRESH README scanner-sha re-pin (§3.2) ·
25 GATE-PIN-AUDIT every sha/number in gate README vs live · 26 GATE-ADVERSARY-A corruption suite ·
27 GATE-ADVERSARY-B false-pass class suite · 28 GATE-NEGATIVE BLOCKED/FAIL exit codes ·
29 GATE-RUN clean close run + receipt · 30 METHOD-DIFF differentiation, both lanes ·
31 PROVINCE-DRAFT draft PROVINCE/SKILL diff (draft only) · 32 SHONEN-CHECK box 4 cross-check ·
33 **SIBLING-GUARD** prove no 2D-lane path written · 34 GIT-HYGIENE porcelain + protected paths ·
35 LEDGER-CHECK MANIFEST/LOG/SCORECARD shape · 36 LESSON-INDEX side-round lesson ·
37 CARRY-QUEUE open items into r108+ · 38 DISSONANCE cross-shard contradictions ·
39 **ADJUDICATOR** admit/reject skeleton, 5 sections · 40 REPORT-SCRIBE round report.

Seats 10, 23, 24→29, 33, 39 must be **non-authors** of what they check. Every seat writes
`reports/round-107/r107-<KEY>.md` only, plus scratch under `/var/tmp/r107-<key>/`.

---

## 7. Close-out criteria (fail-closed)

The side-round is closed when **all** hold, each re-derived by a non-author on the committed
bytes:

1. **Fresh pin recorded** — `PROVENANCE.md` carries the 2026-10-19 fetch date and four transport
   outputs; SHA field = `a6aa73ad…` (§1.1) **or** the new `main` tip if upstream moved (§1.2).
2. **12/12 byte-identical, 3-way** — T1, T2, T3 green; T4 green or explicitly `BLOCKED` (§2).
3. **Cards + adaptation refreshed** — 13 cards, exactly-one-label, census `12/1/0` unless an
   unlock receipt justifies otherwise; 15 adaptation rows still resolvable (§5).
4. **Gate green under adversary seats** — clean run PASS/exit 0, plus ≥2 adversary suites and
   the two negative controls (`BLOCKED` exit 2, `FAIL` exit 1) reproducing (§3.1, §6).
5. **Runtime honestly labeled** — `proven-with-evidence` (U1–U4 receipt) **or**
   `unproven-with-attempt-log` (§4.3). No third state, no hedging.
6. **Method differentiation landed in both lanes**, non-author verified, SHONEN box 4
   cross-checked, no cross-domain bleed (contract DONE-WHEN).
7. **Isolation** — zero writes outside the lane; zero writes to `corpus/knowledge/unreal-mcp/`
   by seat shards (the orchestrator lands the integration commit).

**Stop-and-report triggers** (contract §STOP): the same blocker repeats three rounds; a claim
stays unprovable; an axis is harmed. The plausible one here is the docker pull never finishing —
that is `UNPROVEN` and closes the round; it is **not** a reason to force a runtime claim.

---

## 8. Evidence index (commands this seat ran)

| # | command | result |
|---|---|---|
| 1 | `git ls-remote <url> main` | `a6aa73ad…  refs/heads/main`, exit 0 |
| 2 | `git ls-remote --symref <url> HEAD` | `ref: refs/heads/main` → `a6aa73ad…`, exit 0 |
| 3 | `gh api repos/…/commits/main --jq '.sha…'` | `a6aa73ad… 2026-09-17T01:28:32Z [MCP] Permit safe concurrent tool calls` |
| 4 | `git ls-remote <url>` (all refs) | `main` + 12 `refs/pull/*`; no second branch |
| 5 | `gh pr list --state all` | #9 OPEN `mergedAt: null` head `a5180ccd…`; #1,2,4,5,8 also OPEN |
| 6 | `git clone <url> /var/tmp/r107-planner/clone` | exit 0; HEAD `a6aa73ad…`; `ls-files` = 12; tree `b5b9624b…` |
| 7–9 | T1 `sha256sum -c` · T2 `diff -rq clone upstream` · T3 blob-id compare | 12× `OK` exit 0 · no output exit 0 · identical exit 0 |
| 10 | `gh api …/contents/<p>?ref=$PIN --jq .sha` ×12 | 12× matches `git hash-object` |
| 11–12 | `GATE_WORKDIR=… run_gate.sh` · `sha256sum gate/run_gate.sh` | 4× `STEP=PASS`, `GATE RESULT: PASS`, exit 0, `POINTERS=103` · `390a25ae4e38…` (442 lines) |
| 13 | `grep -n 'e5521304' gate/README.md` | 4 hits (lines 248, 283, 373, 440) — stale pin |
| 14–16 | `docker images \| grep -i unreal` · `ps aux \| grep 'docker pull'` · `docker manifest inspect …` | no output · pid 596299 alive, log mtime 00:09:37 · 30 layers, 24.95 GiB, config `b99f8c5e…` |
| 17–19 | `wc -l .manifest.d/*.sha256` · `ls executability/*.md \| wc -l` · `grep -n unproven-runtime actors-scene.md` | `seat11` = 2 lines / `seat01`–`seat10` = 1 · 13 · label at line 5 |
| 20–21 | `kimi --version` · `df -h /` | `2.2.0` · 930G, 18% used, 752G avail |
