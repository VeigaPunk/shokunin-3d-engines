# r107-scribe-lesson — SCRIBE-LESSON seat (3D side-round, round 107)

KEY=SCRIBE-LESSON · lane `game-dev-3d-shokunin` · started 2026-10-19.
Shard `reports/round-107/r107-scribe-lesson.md` · scratch `/var/tmp/r107-scribe-lesson/`.
**No writes into `corpus/knowledge/unreal-mcp/` and none into `corpus/lessons/`.** The draft
lesson below is the deliverable; the orchestrator lands it (single integration commit).

**Plan (5 lines).**
1. Survey the existing lesson shape (`r102-unreal-integration.md`, `r105-unreal-lifecycle.md`) and
   the r101–r106 records this lesson must supersede.
2. Re-observe the round-107 primary evidence first-hand (fresh pin, byte-identity transports,
   docker pull state, gate state) — no inherited claim without a command.
3. Draft `corpus/lessons/r107-unreal-revendor.md`: re-vendoring + gate-refresh + unlock-attempt
   lessons, each with command + observed output + [O]/[I]/[?] label.
4. Cross-check numbers against sibling shards that had landed; record divergences, do not smooth.
5. Land nothing; hand the draft body to the orchestrator.

Status: DRAFT COMPLETE. Every measurement below was run by this seat on 2026-10-19 unless the line
says otherwise. Labels: **[O]** observed here, **[I]** inference, **[?]** unknown.

---

## 0. Round-107 headline (the one fact the lesson exists to carry)

**The "fresh pin" is not fresh. Upstream `main` still resolves to the r101 pin.** The round's
brief was a from-scratch re-vendor at a fresh pin; the re-fetch returned the same commit. So the
substantive work is *re-verification*, and the delta that exists lives **outside** the pin (open
PRs), not in it. A round that assumes a pin moved because it was asked to re-vendor would have
written a false delta.

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-19T03:08:53Z
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
```
The only other refs advertised are `refs/pull/{1,2,4,5,8,9}/{head,merge}` — six open PRs, no newer
branch **[O]**. The r101 pin was `a6aa73ada02a9fb1f5415bec491f9942c519b297` (`corpus/knowledge/unreal-mcp/PROVENANCE.md`
§1). **Same value. Δ = none** [O]. Independent corroboration: `gh api …/commits?per_page=5` → newest
is `a6aa73ad…` 2026-09-17T01:28:32Z, next `d1b05809…` 2026-09-10 [O]; the PIN-DELTA seat
(`reports/round-107/r107-pindelta.md` §2) reports the same across nine transports.

**Lesson A — a re-vendor is a measurement, not an assumption.** The instruction "re-vendor at a
fresh pin" does not assert that the pin moved. Resolve the pin from the wire first; if it equals
the recorded pin, the correct output is an all-rows-`no-change` delta table plus a dated
re-verification stamp — not a manufactured diff.

---

## 1. Byte-identity across three transports (re-derived, not inherited)

Transport A — `git clone` (fresh, this seat):
```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin cloneA
clone exit=0
$ git -C cloneA rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C cloneA ls-files -s | wc -l
12
$ diff -rq cloneA /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)   exit 0
```
Transport B — GitHub **codeload tarball** (non-git):
```
$ curl -sL https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297 -o tarball.tar.gz
$ ls -la tarball.tar.gz   # 22990 bytes
$ tar -xzf tarball.tar.gz -C tb     # dir name carries the SHA
$ find tb/unreal-engine-skills-for-claude-code-plugin-*/ -type f | wc -l
12
$ diff -rq tb/<sha-dir> cloneA --exclude=.git ; echo exit=$?
(no output)   exit=0
$ diff -rq tb/<sha-dir> …/corpus/knowledge/unreal-mcp/upstream ; echo exit=$?
(no output)   exit=0
```
Transport C — GitHub **REST `git/trees` blob SHAs** vs A's local git object ids:
```
$ git -C cloneA ls-files -s | awk '{print $2" "$4}' | sort > A-blobs.txt
$ gh api 'repos/…/git/trees/a6aa73ad…?recursive=1' --jq '.tree[]|select(.type=="blob")|.sha+" "+.path' | sort > C-blobs.txt
$ diff A-blobs.txt C-blobs.txt ; echo exit=$?
(no output)   exit=0
```
All 12 paths, all 12 git blob ids, agree **[O]**. Corroborating transports from sibling seats:
PIN-DELTA lists nine (`r107-pindelta.md` §2) including a **raw file host** (`curl …/main/…/plugin.json
| sha256sum`), which this seat re-ran:
```
$ sha256sum corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44
$ curl -sL https://raw.githubusercontent.com/…/main/.claude-plugin/plugin.json | sha256sum
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  -
```
The manifest check also still passes: `sha256sum -c .manifest.d/audit-reference.sha256` from
`corpus/knowledge/unreal-mcp` → **12 × `OK`, exit 0** [O]. `find upstream -type f | wc -l` → `12` [O].

**Lesson B — three transports that share no local state, and name which is non-git.** `git clone`,
a codeload tarball, and the REST tree API disagree if any one is wrong; a single `sha256sum -c`
against the tree's own manifest cannot see an extra unlisted file (the r101 residual gap). Two of
the three here are non-`git`-worktree reads, so a clone artifact cannot hide.

---

## 2. Gate refresh — what actually changes when the pin does not

The in-repo gate was re-run by this seat against the live tree:
```
$ GATE_WORKDIR=/var/tmp/r107-scribe-lesson/gatework \
    bash corpus/knowledge/unreal-mcp/gate/run_gate.sh ; echo GATE_EXIT=$?
GATE unreal-mcp subtree
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/var/tmp/r107-scribe-lesson/gatework (from GATE_WORKDIR)
WORK_ROOT_FREE=748G of 930G (19% used)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
STEP=PASS
CHECK 3 verdict-card-scan
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
CHECK 4 pointer-sweep
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE_EXIT=0
```
Gate script sha256 at this run: `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (442
lines) — the same live digest the r106 correction note recorded [O]. The card census is unchanged
from r101 (12 `static-only` / 1 `unproven-runtime` / 0 `verified-here`) [O].

**Lesson C — a no-op pin means the gate's *constants* do not move; only the stamp does.** Nothing
in CHECK 1–4 needs a new expected value when the pin is identical. What a refresh owes is a
**dated re-verification stamp** (fetch date `2026-10-18` → `2026-10-19`) and a statement that the
re-fetch returned the same bytes. Do not "refresh" hashes that did not change — that is fabricated
delta. Run the gate from a writable `GATE_WORKDIR` so a scratch failure cannot be misread as a
network `BLOCKED` (the r103→r104 class).

---

## 3. The unlock attempt — label it, do not decorate it

The round carries a UE-runtime unlock attempt: a pre-existing `docker pull
wukakuki/unreal-engine:dev-slim-5.8.3` (pid 596299, log `/var/tmp/ue-pull.log`, launched from the
2D lane at ~00:07). State at this seat's last check **[O]**:
```
$ docker images | grep -i unreal        # NO UNREAL IMAGE
$ ps -o pid,etime -p 596299             # 596299  03:42  (alive)
$ tail -2 /var/tmp/ue-pull.log
84bd5dd0f39b: Pull complete
3fc5ed8760e3: Download complete
$ grep -c 'Download complete' /var/tmp/ue-pull.log   # 29
$ grep -c 'Pull complete'     /var/tmp/ue-pull.log   # 16
$ grep -c 'Pulling fs layer'  /var/tmp/ue-pull.log   # 30
$ grep -c '7a31e2ef5f97' /var/tmp/ue-pull.log        # 1  (only the fs-layer announce; the 12.75 GiB layer had NOT started)
```
Ground truth for size, resolved from the registry manifest (anonymous pull token) **[O]**:
```
docker-content-digest: sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef
schemaVersion 2 · layers 30 · total_bytes 26791359421 (24.95 GiB)
largest layer sha256:7a31e2ef5f97  13689053562 B
```
The 12-hex prefixes in the pull log are the manifest digests' first 12 hex chars, so `Download
complete`/`Pull complete` sets sum to real bytes; the pull is gated by one 12.75 GiB layer that had
not started at the W-CRON snapshot (`r107-pull-watch.md`). Disk is not the constraint (`df -h /` →
744G free, 19% used) [O].

**Verdict: UNPROVEN-with-attempt-log.** No image is present, so no container probe is possible, so
no live-editor claim can be made. The attempt log is `/var/tmp/ue-pull.log` plus this section and
the W-CRON snapshot table. **Lesson D — an unlock attempt that has not finished is UNPROVEN, and the
honest artifact is the attempt log with its byte-accurate state, not a promise.** Do not write "the
image is downloading, so runtime is nearly proven". The label moves to PROVEN-with-evidence only
when the image exists *and* a bounded probe ran inside it.

Corroborated, independently, by the non-docker seat (`r107-unlock-nodocker.md`, status COMPLETE,
232 lines): all four non-docker routes are **BLOCKED-without-credentials** — Epic account/EULA (A),
AUR `prepare()` SSH gate (B), AUR `unreal-engine-bin` `manual://` stub (C), Lutris+wine Epic login
(D) [O]. That seat names the docker pull as "the only one that has not hit a credential wall",
consistent with r101's G2 finding. So the round's unlock surface reduces to: **one in-flight pull
(docker) + four credential-gated routes (non-docker)** — and every one is UNPROVEN here.

---

## 4. What did NOT move (so the lesson cannot be over-read)

- **The card label collision persists.** The exact command
  `grep -rln 'Not \`unproven-runtime\`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l`
  → **6** of 13 cards explicitly reject the label that `README.md:41` defines as their exact
  condition [O]. The gate's one-label check passes (`BAD=0`) while the vocabulary is still split;
  a green gate does not resolve semantic disagreement (carried from r102 Law 3, still owed).
- **`verified-here` remains 0.** No bounded editor run happened here, so no card may be promoted.
- **`/tmp/ue-skills-ref` no longer exists** (`ls` → No such file or directory) [O]; the r101
  reference clone is gone. Re-establish the pin from PROVENANCE §1 + the wire, not from that clone.

---

## 5. Next-iteration hooks

1. **On any future "re-vendor" instruction, resolve the pin from the wire first.** If it equals the
   recorded pin, emit a `no-change` delta + a dated re-verification stamp; if it moved, re-run the
   three transports (git clone / codeload tarball / REST tree) and the manifest sweep. Never diff
   against `/tmp/ue-skills-ref` — it is cleared between rounds.
2. **Keep the gate in-repo and run it from a writable `GATE_WORKDIR`.** A no-op pin means only the
   fetch-date stamp changes; do not rewrite unchanged expected values.
3. **Carry the unlock label as binary.** UNPROVEN-with-attempt-log until the image exists and a
   bounded in-container probe ran; then PROVEN-with-evidence. Record the registry-manifest byte
   total (24.95 GiB, 30 layers, digest `sha256:3f0886cf…`) as the ground truth a log-only pull lacks.
4. **Watch the out-of-pin surface, not the pin.** The real r107 delta is two open PRs (#8 OpenCode
   port, #9 5.8.3 quirks bump to `3.1.2`) — neither merged, so the pin stays the freshest released
   state. Re-check `gh pr list` each round (`r107-pindelta.md` §4).
5. **Keep the P/C label-precedence ruling open.** Six cards still reject the defined
   `unproven-runtime`; a gate's one-label scan is not authority to edit the byte-pinned subtree.

---

## 6. Handoff to the orchestrator

- **Deliverable:** the draft lesson body = sections 0–5 above, intended as
  `corpus/lessons/r107-unreal-revendor.md`. It is written in the r102/r105 lesson voice (numbered
  lessons, command + observed output, [O]/[I]/[?] labels, Next-iteration hooks).
- **Landing:** orchestrator writes it; this seat wrote only this shard.
- **Evidence files (this seat's scratch):** `/var/tmp/r107-scribe-lesson/{cloneA,tb,tarball.tar.gz,
  A-blobs.txt,C-blobs.txt,manifest.json,mheaders.txt,gatework/}`.
- **Cross-check note:** no numeric divergence found against the sibling shards read at draft time
  (`r107-pindelta.md` nine transports; `r107-pull-watch.md` snapshot table; `r107-cards-crit.md`
  42-file subtree census). The pin value `a6aa73ad…` is identical in every seat's record.
- **Not verified by this seat:** any UE runtime behavior. UNPROVEN stays UNPROVEN.
