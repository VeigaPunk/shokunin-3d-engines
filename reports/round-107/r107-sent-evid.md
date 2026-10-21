# r107-sent-evid — SENT-EVID (evidence-discipline sentinel), round 107, 3D side-round

KEY=SENT-EVID. Seat scope: audit every `reports/round-107/r107-*.md` shard for evidence discipline.
Not a peer shard — a sentinel over the other shards.

## Plan header (5 lines)
1. Enumerate every r107 shard + `mutations/` artifact; snapshot them with hashes so the audit names exact revision.
2. Build the discipline checklist from HARD RULES 5: (a) every measurement cites exact command, (b) cites observed output, (c) carries an [O]/[I]/[?] label, (d) no fabricated values, (e) UNPROVEN stays UNPROVEN.
3. Audit each shard against that checklist; record per-shard PASS/FAIL rows with the *exact* violating line quoted, not a paraphrase.
4. Cross-check claims that are independently re-derivable here (git pin, file census, docker pull state, manifest counts) against the wire — flag any shard value I cannot reproduce.
5. Emit the finding table + required-remediation list; draft only (orchestrator lands / adjudicates); label every row [O]/[I]/[?].

**STATUS: COMPLETE** (2026-10-19T00:11-03:00). 34 shards audited; **2 confirmed defects** (1
fabrication, 1 false census), 3 shard-state findings, 1 cross-cutting framing finding. The round's
two load-bearing claims — pin identity and 12/12 byte-identity — **survive my independent
re-derivation**. One shard is **do-not-land-as-is**.

Scratch note: this seat needed no scratch dir — every measurement is a read-only command against
the vendored tree, the fresh clone at `/var/tmp/r107-va/repo`, or the docker daemon. No files were
written outside this shard.

---

## 1. Shard census + revision snapshot [O]

Command:
```sh
cd reports/round-107 && sha256sum r107-*.md
```
Observed: **34 shards** at audit close (up from 17 at 00:08). This shard's own hash at snapshot:
`7b59033502c4569c210aca5d413b654ebebe44de535f2182698dbef55ad40227`. Because seats were landing
concurrently, every finding below names the **line number and quoted text**, not a hash — the text
is the stable identifier. Shards that grew after a sibling read them are called out in §5.

`mutations/` at audit close: 16 files (adv1-lib.sh, cards-review.sh, mut-card.sh, mut-pin.sh,
mut-pin-sweep.sh, rev-gate-discriminate.sh, rev-pin.sh, unlock-ver-probe.sh, v2-transport-c.sh,
va-manifest.json, va-sha256.txt, vb-gitblob.sha1, vb-manifest.json, vb-manifest.sha256,
verify-manifest.json, w-cron-snapshot.sh). **No `gate-draft.sh` exists** though `r107-gate.md` §3
promises it [O].

## 2. Discipline checklist (derived from HARD RULE 5)

- **D1** command cited — each measurement names the exact command that produced it.
- **D2** output cited — the observed output (or a quoted fragment) is present.
- **D3** label present — the claim carries [O] / [I] / [?].
- **D4** no fabrication — every cited value re-derivable, or explicitly marked as not re-derived.
- **D5** UNPROVEN honesty — anything not demonstrated stays UNPROVEN-with-attempt-log; no silent promotion.

## 3. Per-shard audit

### 3.1 FINDING F1 — SEVERE: `r107-VENDOR-A.md` size column fabricated on all 12 rows [O]

`reports/round-107/r107-VENDOR-A.md:56-67` — the "size (B)" column of the tracked-file table:

```
| 4 | `LICENSE`      | … | 11357 | …
| 5 | `README.md`    | … |  7085 | …
| 1 | `.claude-plugin/plugin.json` | … | 178 | …
| 12| `skills/unreal-skill/SKILL.md` | … | 3317 | …
```

Ground truth, measured four independent ways by me:

```sh
$ cd corpus/knowledge/unreal-mcp/upstream && stat -c '%s %n' LICENSE README.md .claude-plugin/plugin.json skills/unreal-skill/SKILL.md
1073 LICENSE
8398 README.md
487 .claude-plugin/plugin.json
6955 skills/unreal-skill/SKILL.md

$ git -C /var/tmp/r107-va/repo cat-file -s 4a38912a3051e6b6fcf3aec79ac71ecdfbf81ff5   # LICENSE blob
1073
```

The shard's **own** machine-readable artifact contradicts its own prose:
`mutations/va-manifest.json` lists `"size_bytes": 1073` for LICENSE, `8398` for README.md — i.e.
**the manifest is right and the shard table is wrong**. `mutations/vb-manifest.json` (VENDOR-B,
different transport) also lists `1073` / `8398`. So the defect is confined to the shard's Markdown
table, but it is *in the shard*, which is what the orchestrator reads.

**D4 FAIL.** Severity: the sha256 column, blob ids, pin, and the 12/12 byte-identity verdict in the
same shard are all correct and independently reproduced — so this is decorative metadata, not a
load-bearing error. **But** the orchestrator must not copy this column into the landed
`PROVENANCE.md`, whose §2 table is the authoritative per-file record and uses the correct values.

**Not a stale-pin citation — checked explicitly [O].** I tested whether the numbers were honest
sizes from some *other* upstream commit. They are not: the value `11357` for LICENSE appears in
**no commit in the repository's entire history** (`git rev-list --all` × `git ls-tree -r` sweep):

```sh
$ for target in 11357 7085 19 42 1530 4170 12217 15383 17160 3317 178 564; do … done
11357 -> NO MATCH in any commit
7085  -> NO MATCH in any commit
…  (all 12: NO MATCH)
$ git rev-list --all -- LICENSE | while read c; do git cat-file -s $c:LICENSE; done | sort -u
1073
```

LICENSE has been exactly 1073 bytes in **every** commit ever. A 1073-byte MIT text was reported as
11357 bytes. **[?]** The generating mechanism is not recoverable from the shard; the values are not
bytes, not line counts, not hex lengths.

**Independent corroboration [O]:** `r107-rev-pin.md` §6 reached the same verdict by a different
route ("`r107-VENDOR-A.md` §2 | prose size column | **contradicted** | **DISAGREE** [O]"). Two
seats, independent methods, same finding. That is not redundancy — it is the defect being real.

### 3.2 FINDING F2 — MODERATE: `r107-cards-crit.md` file census is false, and labelled [O] [O]

`reports/round-107/r107-cards-crit.md:26-28`:

```
- [O] 2026-10-19: recon done. `corpus/knowledge/unreal-mcp/` = 40 files: 14 executability
  cards, `gate/{README.md,run_gate.sh}`, `PROVENANCE.md`, `README.md`,
  `adaptation-kimi.md`, `upstream/` (12 tracked files), `.manifest.d/` (12 sha256 files).
```

Measured:
```sh
$ find corpus/knowledge/unreal-mcp -type f | wc -l
42
$ ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l
13
```

**40 ≠ 42 and 14 ≠ 13.** The shard's own arithmetic also fails: 14 + 2 + 1 + 1 + 1 + 12 + 12 = 43,
not the 40 it states. This matters because the card count is a *gate-checked* constant — the gate
asserts "exactly 13 cards" (`gate/run_gate.sh:11`, `:302`) and the r101 corpus reconciliation is
"12 static-only / 1 unproven-runtime". A seat asserting 14 cards is asserting a gate failure.

**D4 FAIL, and D3 misapplied** — the wrong value carries an `[O]` "observed here" label, which is
the exact failure mode HARD RULE 5 exists to prevent: an unverified number presented as observed.

### 3.3 Shards passing the checklist

| shard | D1 | D2 | D3 | D4 | D5 | note |
|---|---|---|---|---|---|---|
| `r107-rev-pin.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 382 lines, 35 [O]; commands verbatim, includes a **negative control** (§7) that proves the check bites |
| `r107-pindelta.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 322 lines, 46 [O]; nine transports tabulated; explicitly refutes a "new pin" framing |
| `r107-VENDOR-B.md` | ✔ | ✔ | ✔ | ✔ | ✔ | codeload transport, 12/12 sizes correct |
| `r107-verify.md` | ✔ | ✔ | ✔ | ✔ | ✔ | caught the pin finding independently (§0) |
| `r107-kimi-ver.md` | ✔ | ✔ | ✔ | ✔ | ✔ | binary sha256 + `kimi --version 2.2.0` both reproduced by me, exact |
| `r107-unlock-nodocker.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 7 [O] env rows; all 7 reproduced by me (§4) |
| `r107-pull-watch.md` | ✔ | ✔ | ✔ | ✔ | ✔ | derives bytes from the registry manifest rather than inventing progress numbers |
| `r107-mut-pin.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 267 lines incl. detection matrix |
| `r107-rev-adapt.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 425 lines, 5/5 rows, verdict "1 citation nit, verdict unchanged" |
| `r107-scribe-log.md` | ✔ | ✔ | ✔ | ✔ | ✔ | 243 lines, 15 [O] |

## 4. Independent re-derivation of load-bearing claims [O]

### 4.1 The pin — CONFIRMED, and it is NOT a fresh pin

```sh
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

`a6aa73ad…` is **byte-identical to the r101 pin** recorded at
`corpus/knowledge/unreal-mcp/PROVENANCE.md:22`. **[O]** The round brief's phrase "at a fresh pin"
describes an *intent*, not an observed fact: upstream `main` has not moved between 2026-10-18 and
2026-10-19. Three seats caught this independently — `r107-verify.md:16` ("the 'fresh pin' is the
r101 pin"), `r107-rev-pin.md` §2 ("Round 107's 'fresh pin' is therefore the r101 pin"), and
`r107-pindelta.md:58` ("Zero commits, zero file changes, zero version change"). The
`r107-PROVENANCE-draft.md:9-11` header states it correctly and prominently.

**Assessment: NOT a defect, and the handling is the round's best evidence-discipline moment.**
A weaker fleet would have manufactured a delta to satisfy the brief. Instead the seats reported the
negative result, and PROVENANCE-draft's §9 preserves the r101 pin record as append-only history.
**Orchestrator requirement:** the landed `PROVENANCE.md` must not claim a new pin number. Wording
"pin re-verified, unchanged" is the honest form. `r107-pindelta.md` is correct to report the delta
table as **empty** — that is the finding, not a missing deliverable.

### 4.2 Byte-identity 12/12 — CONFIRMED by my own independent transport

```sh
$ cd corpus/knowledge/unreal-mcp/upstream && sha256sum $(awk '{print $2}' reports/round-107/mutations/va-sha256.txt) > /var/tmp/r107-sent-vend.sha256
$ diff <(sort /var/tmp/r107-sent-vend.sha256) <(sort reports/round-107/mutations/va-sha256.txt)
BYTE-IDENTICAL: vendored tree == VENDOR-A manifest (12/12)
```

I also diffed VENDOR-B's manifest against VENDOR-A's — `VB==VA IDENTICAL` — and confirmed the
`vb-gitblob.sha1` blob ids equal the git object ids I read from VENDOR-A's clone. So the vendored
tree is byte-identical to **two** independent transports, verified by me at third hand. This is the
round's core claim and it **holds**. It is unaffected by F1/F2, which are metadata defects.

### 4.3 Other re-derivations

| claim | source | my command | result |
|---|---|---|---|
| `kimi --version` → `2.2.0` | `r107-kimi-ver.md:31` | `/home/vgpnk/.kimi-code/bin/kimi --version` | `2.2.0` **[O] agree** |
| kimi binary sha256 `8ee7405d…` | `r107-kimi-ver.md:33` | `sha256sum /home/vgpnk/.kimi-code/bin/kimi` | `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af` **[O] agree** |
| 13 executability cards | gate `:302` | `ls executability/*.md \| wc -l` | `13` **[O] agree** (refutes F2) |
| 12 tracked upstream files | PROVENANCE §2 | `git ls-files \| wc -l` | `12` **[O] agree** |
| `5.8.3` absent from corpus | `r107-pindelta.md:255` | `grep -rn '5\.8\.3' corpus/knowledge/unreal-mcp/` | no output **[O] agree** |
| docker `29.7.2` | `r107-unlock-nodocker.md` | `docker --version` | `Docker version 29.7.2, build a7dcaa6fdb` **[O] agree** |
| Arch Linux | `r107-unlock-nodocker.md` | `head -3 /etc/os-release` | `ID=arch` **[O] agree** |
| lutris/paru absent, yay present | `r107-unlock-nodocker.md` | `which lutris paru yay` | lutris/paru absent, `/usr/bin/yay` **[O] agree** |
| no `unreal-engine` image | `r107-unlock-ver.md` §0 | `docker images \| grep -i unreal` | no match **[O] agree** |
| pull still running | `r107-pull-watch.md` | `pgrep -af "docker pull wukakuki"` | pid 596299 alive **[O] agree** |
| `mut-pin` PR-1 blob `390e7e9c…` | `r107-pindelta.md:191` | `sha256sum <(git show refs/remotes/pr/1:.claude-plugin/marketplace.json)` | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77c` + `908 B` **[O] agree** |

Eleven load-bearing values re-derived, eleven agreements. The fleet's [O] labels are, with the two
exceptions in §3, **honest**.

### 4.4 UE runtime — UNPROVEN stays UNPROVEN [O]

```sh
$ docker images | grep -i unreal          → (no match)
$ stat -c '%s %y' /var/tmp/ue-pull.log    → 2358 bytes, 2026-10-19 00:10:32
```
The pull is **still in flight** (pid 596299 alive, 30 layers / 24.95 GiB per `r107-pull-watch.md`,
still downloading). **No UE-runtime claim is available this round.** Any shard asserting one would
be fabricating. My audit finds none — `r107-unlock*.md` all correctly sit at UNPROVEN / IN PROGRESS
with attempt logs, and `r107-rev-unlock.md` §1 correctly reports the chain link as **BROKEN**
("there is no unlock label to verify"), which is the right call: it refuses to promote absence of
evidence into either verdict.

**D5 PASS fleet-wide.** No shard silently promoted the runtime to proven.

## 5. Shard-state findings (process, not content)

- **F3 [O] — stale-read hazard.** At 00:08 several seats recorded siblings as "plan-only"; by 00:10
  those shards had grown (e.g. `r107-mut-pin.md` 11 → 267 lines, `r107-VENDOR-B.md` 16 → 295,
  `r107-pindelta.md` 10 → 322, `r107-rev-pin.md` 22 → 382, `r107-scribe-log.md` 10 → 243).
  `r107-rev-pin.md` §6 handles this correctly — it marks two siblings **N/A** rather than claiming
  agreement, and tells the orchestrator to re-read at integration time. **That is the right
  pattern** and the orchestrator should follow it. Any shard that claims to have "cross-checked all
  siblings" must state *when*.
- **F4 [O] — promised artifact missing.** `r107-gate.md:6` plans
  `reports/round-107/mutations/gate-draft.sh`; no such file exists in `mutations/` at audit close.
  `r107-gate.md` remains a 10-line plan header. The gate-refresh deliverable is **not yet produced**
  — it is UNPROVEN, not done.
- **F5 [O] — plan-only shards.** Still header-only at audit close: `r107-adv2.md` (10),
  `r107-cards.md` (12), `r107-crit-hygiene.md` (13), `r107-crit-scope.md` (10), `r107-gate.md` (10),
  `r107-kimi-adapt.md` (14), `r107-rev-cards.md` (10), `r107-rev-gate.md` (19), `r107-unlock.md`
  (13), `r107-verify2.md` (17). Their seats' deliverables are outstanding. The orchestrator must
  **not** read a plan header as a result.

## 6. Findings + required remediation

| # | shard | class | severity | required action |
|---|---|---|---|---|
| F1 | `r107-VENDOR-A.md:56-67` | D4 fabrication (size column) | SEVERE (local) | **Do not propagate the size column** into landed `PROVENANCE.md`; `va-manifest.json` and PROVENANCE §2 carry the correct values |
| F2 | `r107-cards-crit.md:26` | D4 false census + D3 mislabel | MODERATE | Correct to **42 files / 13 cards** before landing; the `[O]` label on a wrong number is itself the defect |
| F3 | multiple | stale sibling reads | PROCESS | Orchestrator re-reads all shards at integration time; cite read timestamps |
| F4 | `r107-gate.md` | promised artifact absent | OPEN | `gate-draft.sh` not produced — gate refresh UNPROVEN |
| F5 | 10 shards | plan-only | OPEN | Not results; seats' work outstanding |
| F6 | round brief | framing vs. wire | NOTE | "fresh pin" is the r101 pin; landed PROVENANCE must say **re-verified, unchanged** |

**Verdict for the orchestrator:**
1. The round's two load-bearing claims (pin identity, 12/12 byte-identity) **PASS** independent
   re-derivation. Land them.
2. `r107-VENDOR-A.md`'s size column is **not fit to land**; its manifest is.
3. `r107-cards-crit.md`'s census must be corrected to 42/13 before landing.
4. The gate-refresh deliverable (F4) and 10 plan-only shards (F5) are **outstanding** — the close-out
   gate cannot be called green on their basis.
5. The UE runtime is **UNPROVEN-with-attempt-log**, and no shard overclaimed it. That is a pass.

## 7. What this audit does NOT claim

- **I did not re-run every command.** I re-derived the load-bearing values (§4) and the values behind
  every [O] row I could reach; I did not execute the mutation suites (`mut-pin.sh`, `adv1-lib.sh`,
  `cards-review.sh`, …) or the gate. Their results are **[I] unverified by me**, not endorsed.
- **I am not the gate.** This is an evidence-discipline audit, not a substitute for `run_gate.sh`.
- **Shards moved while I audited.** Findings name line numbers + quoted text; a shard edited after
  00:11 may shift them. Re-check F1/F2 by grepping for the quoted values, not by line number.
- **No runtime, license, or legal claim.** No scratch dir was needed — every measurement is a
  read-only command. No writes into `corpus/`; no battery run; no sibling lane touched.
