---
name: game-dev-3d-shokunin
description: Domain specialist — 3D game production verified by executable headless fixtures — spatial queries, camera/frustum, transforms, scene structure, determinism — across Godot, three.js, Unity and Unreal. Use for 3D fixture work, headless battery runs, engine/version census questions, or any claim about what a 3D engine did on this host. Trigger strings: "3D fixture", "headless battery", "phys3d", "camera3d/frustum", "engine census", "is Unreal installed". Anti-trigger: 2D production surfaces (sibling `game-dev-2d-shokunin`); reverse engineering as an end in itself (`revenger-shokunin`). Sibling arbitration: 2D fixture patterns are inherited, 2D product surfaces are not; contested scope is reported per `PROVINCE.md`, never absorbed.
---

# game-dev-3d-shokunin

Craft for one province: **3D game production verified by executable headless
fixtures**, across Godot / three.js / Unity / Unreal. The domain boundary,
the engine census and the standing refusals live in `PROVINCE.md` and
`corpus/knowledge/engines.md`; this file carries the decision procedures.

Every rule below cites an artifact that exists in this repo, and every command
is one that was actually run — the round and the observed output are named in
`reports/`. Nothing here is oral knowledge, and no claim in this file is a
runtime claim about an engine that is not installed.

---

## 1. Unreal-content claim discipline — decision table

**This table decides, before an Unreal-content claim is written, which label it
may carry and what evidence it must cite.** It is a decision procedure over
claim *types*, not a summary of any round. Four claim types are exhaustive over
the pinned subtree (`corpus/knowledge/unreal-mcp/`); a fifth row covers the
lane's own authored static artifacts, which the r102 draft left out
(`reports/round-103/skill-table-review.md` §3.1).

**Two vocabularies exist and both are stated where they apply**
(`corpus/knowledge/unreal-mcp/README.md` §Verification policy, §How the binary
policy maps onto the ternary card labels):

- the **binary policy** — `proven` / `unproven` — governs *claims*;
- the **ternary card label** — `verified-here` / `static-only` /
  `unproven-runtime` — governs *subsystem cards*.

The two collide without a precedence rule; §3 states the collision and the
open ruling. Until it lands, a row states both labels where both apply.

| # | claim type | permissible label | required evidence | canonical command (run from the lane repo root) | justified by |
|---|---|---|---|---|---|
| **A** | **File byte-identity** — "this vendored file is what upstream shipped at the pin" | `proven`. **No** ternary card label: the ternary is for subsystem cards, not file claims. An A-row is a **precondition** for a card's `static-only` label, not its ground: the ground is the static check the card itself cites. | (a) `sha256` of the file equals the committed manifest row **and** (b) the path set equals `git ls-files` of a **fresh** clone at the pin, **both ways**. | `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)` → 12 × `OK`, rc 0. Gate CHECK 1 + CHECK 2 cover it in one run: `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`. **+NC:** `printf '\n' >> <copy>/upstream/README.md` on a copy → `upstream/README.md: FAILED`, `MANIFEST_OK=11 FAILED=1`, rc 1. | gate CHECK 1/CHECK 2 (`corpus/knowledge/unreal-mcp/gate/run_gate.sh`; cite by check name + the sha in §6, never by line number — the script took ≥5 identities during r104); `corpus/knowledge/unreal-mcp/PROVENANCE.md` §2 (byte-identity); non-author `reports/round-101/r101-reviewer-c1.md` §Verdict; mutation matrix `reports/round-101/r101-mutation-tester.md`; independent re-runs `reports/round-102/reruns/manifest.md`; r104 re-derivation `reports/round-104/skill/author.md` §2 |
| **B** | **Static parse** — "this file is well-formed / this card declares exactly one label / this prose pointer resolves **line-range only** (CHECK 4 verifies the cited line exists and its endpoint is in range; it does **not** read line content — an in-range but semantically wrong pointer still gives `UNRESOLVED=0`, demonstrated by the planted-pointer control in `reports/round-104/skill/critic.md` §2)" | `proven` for the property of *the bytes read*. Ternary: `static-only` is the correct **card** label when a subsystem's document facts are proven but its behavior is not. **F7 clause (required):** on this host a card label is `static-only` or `unproven-runtime`; a `verified-here` label is a red flag, not a stronger result. A claim that contradicts one of the six dissenting cards must **cite the card it contradicts**. | a tool that actually ran here, with its output recorded: `jq -e .`, `bash -n`, `shellcheck` (ruleset named), a label scan, a pointer sweep. Static means the tool ran; it does **not** mean the content is semantically correct. | `(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json)` → rc 0 (the `.` filter is load-bearing: without it `jq` exits **3**). `(cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh)` → rc 0 under the **default** ruleset; `shellcheck -o all` → rc 1, **31** findings. `(cd corpus/knowledge/unreal-mcp && bash -n upstream/hooks/unreal-context.sh)` → rc 0. Gate CHECK 3 (label census) + CHECK 4 (pointer sweep). **+NC:** duplicate a label token on the declaration line → `FAIL multi-label …`, `BAD=1`, rc 1. | gate CHECK 3/CHECK 4 (`corpus/knowledge/unreal-mcp/gate/run_gate.sh`; cite by check name + the sha in §6, never by line number); `corpus/knowledge/unreal-mcp/README.md` §Verification policy + §How the binary policy maps onto the ternary card labels; `corpus/knowledge/unreal-mcp/adaptation-kimi.md` §5; label controls NC1–NC5 `reports/round-102/reruns/labels.md`; pointer controls `reports/round-102/reruns/pointers.md`; F7 collision `reports/round-101/r101-critic-c3.md` §F7 and `corpus/knowledge/unreal-mcp/executability/blueprints.md` ("Not `unproven-runtime`") |
| **C** | **Runtime behavior** — any `list_toolsets` / `describe_toolset` / `call_tool` / actor mutation / Live Coding / automation-test / Niagara / Sequencer / Control Rig statement | **`unproven`**; the card label is **`unproven-runtime`** only where a runtime path is identified (`README.md:41`'s definition). Where the runtime path is not even identified — the six dissenting cards — the label is `static-only` **and the claim must cite the card it contradicts** (§1 row B's F7 clause). `verified-here` is permissible **only** with a saved receipt of a bounded run on this host — which cannot exist here. Never the indicative mood. | none is sufficient on this host. The row must be **labeled**, and must state what would settle it. A connected MCP client, a cached tool catalog, or a successful `unreal_mcp_status` is **not** evidence of reachability. | `which UnrealEditor UnrealEditor-Cmd` → `no … in (…)`, rc 2; `ls /opt/UnrealEngine` → `No such file or directory`, rc 2; `git ls-remote https://github.com/EpicGames/unreal-engine HEAD` → `Repository not found`, rc 128. | `corpus/knowledge/unreal-mcp/README.md` §Host reality (receipts) + §Verification policy; `corpus/knowledge/unreal-mcp/adaptation-kimi.md` §6 (unproven-runtime register) and its live-editor rule; `corpus/lessons/r102-unreal-integration.md` Law 2 (binary policy) + Law 4 (install-wall classes); r104 re-derivation `reports/round-104/skill/author.md` §2 |
| **D** | **Kimi-side adaptation** — "Claude mechanism X maps to Kimi mechanism Y" | `verified-here` **iff** a probe ran on this host with output pasted. **Disambiguation (required, in-cell):** this is the *row-probe* sense — "reproduced by a command run on this host, output pasted in the row". It is **not** the card sense ("a bounded run of the subsystem happened here with a saved receipt"). A row-D `verified-here` says nothing about any Unreal subsystem. Else `static-only` if read from a shipped artifact with a resolvable pointer; `unproven-runtime` if it needs a live editor or a live MCP server. | the probe's command **and** observed output, or a resolvable artifact pointer (config path + structural description, docs page). `NONE-FOUND` requires the exact search that returned 0. A "binary strings line N" pointer is a **re-derivation**, never a citation — it dies on a CLI upgrade. | `/home/vgpnk/.kimi-code/bin/kimi --version` → `2.2.0`; `strings -n 6 /home/vgpnk/.kimi-code/bin/kimi \| grep -c additionalContext` → `0`; `… grep -c CLAUDE_PLUGIN_ROOT` → `0`; `… grep -c enabledPlugins` → `0`. Valid only for BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`. | `corpus/knowledge/unreal-mcp/adaptation-kimi.md` §1 (adaptation table), §5 (verification policy: promotion / invalidation / negative-claim rules), §6 (register); two-sense witness `reports/round-103/skill-table-review.md` §2 row D; r104 re-derivation `reports/round-104/skill/author.md` §2 |
| **E** | **Lane-authored static descriptor** — "the lane wrote a `.uplugin` its own checker accepts" | `static-only`. **Never** `verified-here`, and never a statement about Unreal accepting it: the checker is the lane's, so the claim is only about the lane's own writing. | the checker's command and its `PASS … reason=…` line, **plus** its paired reject control. The row must state what the evidence does *not* reach. | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` → `PASS local-static actual=accept … reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)`, rc 0. **+NC:** `python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject` → `PASS local-static actual=reject … reason=unsupported module Type: 'Unknown'`, rc 0. | `corpus/artifacts/unreal-r22/README.md`; `corpus/knowledge/engines.md` Unreal row (evidence class (a)); `reports/round-103/skill-table-review.md` §3.1 (the missing E-row); r104 re-derivation `reports/round-104/skill/author.md` §2 |

**Citation rule for mutable files.** Cite a mutable artifact by **section heading
plus a sha256 stamp**, not by bare line number; cite a frozen artifact
(`reports/round-101/**`, `corpus/knowledge/unreal-mcp/upstream/**`,
`.manifest.d/**`) by line number. A line-number citation into a file another
seat may still be editing is itself a prose-cites-bytes defect. This rule is
what r103 §4.1 measured the r102 draft violating: all ten of its
`gate/run_gate.sh:NN` citations had moved, because the gate changed identity
four times in that round. **No gate line number is carried into this file** —
the gate is cited by `CHECK n <name>` and by its sha.

---

## 2. Error patterns — named signatures

Each is a defect this lane has observed and repaired at least once. The name is
the search key.

| signature | what it looks like | what to do | source |
|---|---|---|---|
| **prose-cites-bytes** | prose quotes a line number or an exact string from a file that has since moved | cite by section heading + sha256, or re-verify the quote before landing | `corpus/lessons/r102-unreal-integration.md` §Next-iteration hooks (hook 3); `reports/round-103/skill-table-review.md` §4.1 |
| **count-written-into-prose** | a count in a sentence ("12 files", "two files flip") that no longer matches the enumeration | never accept a count written into prose; run the enumeration. The glob `sha256sum -c .manifest.d/*.sha256` yields **24** `OK` lines, not 12 — the `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` subset yields 12 | `corpus/knowledge/unreal-mcp/README.md` §`.manifest.d/`; `reports/round-103/skill-table-review.md` §2 row A |
| **implicit-cwd command** | a command that only works from one directory, quoted as if it were portable — the manifest stores relative paths, so it verifies only with the subtree as cwd | prefix the command with its cwd, or point at the gate, which resolves its own cwd | `reports/round-103/r103-connector.md` §3.3; `corpus/knowledge/engines.md` Unreal row |
| **scanner-relative datum** | a bare `POINTERS=` quoted as a constant; it is a measurement of *this scanner on this tree* and moved `87 → 88 → 90 → 91 → 98 → 101 → 103` across r102–r104 | quote `UNRESOLVED=0` (the invariant) and name the scanner + tree state with any count | `corpus/knowledge/unreal-mcp/gate/README.md` (pin correction note); `reports/round-103/r103-connector.md` §5; `reports/round-104/skill/author.md` §4 |
| **temp-dir-dependent gate** | a gate whose scratch `mktemp` is rooted in an unwritable or full temp dir reports an infrastructure failure as a **verdict** (`FAIL per-seat manifest sweep`) instead of a could-not-evaluate state | redirect the scratch root — `GATE_WORKDIR=<roomy dir>` (or `TMPDIR=`) — before believing a red; a green run with the default root is only valid while that root is writable | `corpus/knowledge/unreal-mcp/gate/README.md` §Running under quota pressure (controls W0/W1); `reports/round-104/skill/author.md` §4 |
| **green-gate-overread** | a passing gate read as closing a defect it cannot see by construction — CHECK 3 enforces one *allowed* token per card and a name-set comparison; it cannot judge whether a `static-only` card rests on a static check that ran | state what the gate does not cover in the same breath as the PASS | `reports/round-103/skill-table-review.md` §2 row C; §3 below |
| **binary-strings-citation** | a claim resting on "line N of the binary" | re-derive with the search command; a CLI upgrade invalidates every such line number | `corpus/knowledge/unreal-mcp/adaptation-kimi.md` §5; row D above |
| **command-does-not-reproduce-its-printed-rc** | a cell whose command, copy-pasted, returns a different code than the cell prints — the dot-less `jq` form exits 3 where the cell said 0 | run the cell's own command from the stated cwd before landing the row | `reports/round-103/skill-table-review.md` §2 row B |

---

## 3. Checklist — before writing any Unreal-content claim

Run the commands; the claim is admissible only when the relevant line holds.

- [ ] **Which row is this?** Pick A / B / C / D / E from §1. If it fits none, the
      claim is outside this table's authority — narrow it or open a row.
- [ ] **A-row:** `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)`
      → 12 × `OK`, rc 0, **and** `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`
      → `STEP=PASS` (or `STEP=BLOCKED`, exit 2, under a network cut — see below) on CHECK 2
      (`PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`). **Precondition:** the gate's scratch
      root must be writable — `GATE_WORKDIR=<roomy dir>` (or `TMPDIR=`) — or a quota-bound
      `/tmp` fails the run for infrastructure reasons (§2 `temp-dir-dependent gate`).
- [ ] **B-row:** the tool ran *here* and its rc is recorded — and the cell's
      command reproduces that rc from the stated cwd.
- [ ] **C-row:** `which UnrealEditor UnrealEditor-Cmd` → rc 2. The claim carries
      `unproven` / `unproven-runtime` and names what would settle it.
- [ ] **D-row:** the probe command and its output are pasted; if it rests on a
      binary string, the re-derivation search is pasted instead of a line number.
- [ ] **E-row:** the checker's `PASS` line **and** its reject control are both pasted.
- [ ] **Label:** exactly one label, drawn from the vocabulary §1 names for that
      row — and both labels stated where both apply.
- [ ] **F7:** if the claim touches one of the six dissenting cards
      (`animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`,
      `materials`, `meshes-textures`), the card it contradicts is cited by name.
      Check: `grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → 6.
- [ ] **Citation form:** mutable file → heading + sha256; frozen file → line number.
      No gate line number anywhere.
- [ ] **Before believing a gate red:** re-run with a scratch root that is writable
      and has room — `GATE_WORKDIR=<roomy dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`.
      A temp-dir failure surfaces as `FAIL per-seat manifest sweep`, which reads
      like a byte mismatch but is not one; the gate prints `WORK_ROOT=…` and
      `WORK_ROOT_FREE=…` on every run so the two are distinguishable.
- [ ] **No indicative mood** about an Unreal-side effect.

---

## 4. The open precedence ruling (state it, do not resolve it)

The lane carries two label vocabularies that overlap without a precedence rule,
and the collision is live:

- `corpus/knowledge/unreal-mcp/README.md` §How the binary policy maps onto the
  ternary card labels defines `unproven-runtime` as *"the claim needs the live
  editor and nothing was observed"*.
- Six of the 13 cards reject that exact label, on the ground that the runtime
  path is **not even identified** — a weaker statement, which they call
  `static-only`.

Both readings are internally honest; the census is not comparable across the two
groups. This is r101's finding F7, carried forward as hook 1 of
`corpus/lessons/r102-unreal-integration.md`, and re-measured unchanged in r103
(the subtree `README.md` sha is unchanged at `c79d8dd1…`, so the disagreement
persists). **The P/C precedence ruling is still owed** and is not this file's to
make: the subtree is byte-pinned and the two sides belong to other seats.

Until it lands, the binding text is the one in §1 row B's **F7 clause** and row C's
conditional: a claim on one of the six dissenting subsystems is labeled `static-only`
and must cite the card it contradicts; `unproven-runtime` is used only where a
runtime path is identified.

---

## 5. What this table refuses

Stated as decisions, because a table that only permits is not a discipline.

1. **No row promotes an engine census row.** `corpus/knowledge/engines.md`
   requires a saved bounded-fixture receipt **and** a non-author verifier before
   any row moves to "executable headless". Row A/B/E evidence — however green —
   is not that receipt. The Unreal row stays `installed: no / executable
   headless: no`.
2. **No row lets a static check stand for behavior.** A static check proves the
   *files* it read, not the *behavior* they describe.
3. **No row accepts a count written into prose.** Enumerate.
4. **No row lets a `verified-here` label appear without a bounded-run receipt.**
   This governs **card** labels (and Unreal-side claims generally): on this host the gate fails
   on `verified-here=1` by construction. Row D's `verified-here` is the **row-probe** sense —
   "reproduced by a command run on this host" — which is permissible there with its probe pasted.
5. **No row asserts an Unreal-side effect in the indicative mood.**
6. **No row cites a mutable file by bare line number** — and no row carries a
   gate line number at all.

---

## 6. Re-deriving this file

Every command in §1 is re-run and its output pasted in
`reports/round-104/skill/author.md` §2, on lane HEAD `88c3b2c` (2026-10-18).
Artifact stamps at that revision (re-hash before acting on any of them). The two
`gate/` rows are marked **worktree** because both moved *during* this seat's run —
re-read them, never trust the stamp alone:

| artifact | role in this file | sha256 (at write time) |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | CHECK 1–4, the standing close-out gate — **worktree, uncommitted** (HEAD still carries `577c8b54…`; it took ≥5 identities during r104) | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | the gate's own contract, pin notes, quota-pressure controls — **worktree, uncommitted** | `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf` |
| `corpus/knowledge/unreal-mcp/README.md` | binary policy + ternary mapping + host reality | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` |
| `corpus/knowledge/unreal-mcp/PROVENANCE.md` | pin + byte-identity + install receipts | `36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | rows D's source; table, policy, register | `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` |
| `corpus/lessons/r102-unreal-integration.md` | Laws 1–4, counting traps, hooks | `cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2` |
| `corpus/knowledge/engines.md` | the no-promotion rule §5.1 restates | `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` |
| `corpus/artifacts/unreal-r22/` | row E's subject (descriptor + checker + reject control) | per file |
| `reports/round-101/r101-reviewer-c{1,2,3}.md`, `reports/round-101/r101-mutation-tester.md`, `reports/round-101/r101-critic-c3.md` | non-author confirmations; F7 witness | frozen |
| `reports/round-102/skill-decision-table-draft.md` | the draft this section's table descends from | `fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2` |
| `reports/round-103/skill-table-review.md` | the review whose landing conditions §1–§5 apply | `95d40d92432252f66d6edf886ac99bf60e190461f075db3d7936bf94527d6815` |

**Scope of this file's authority.** Landing this table satisfies the *artifact*
half of `SHONEN.md` box 1. It does **not** close box 1: the box is a promotion
gate requiring a **named non-author verifier**, and the author of this file
cannot be that verifier. Until such a verifier records a pointer, box 1 reads
`[~]`, not `[x]`.
