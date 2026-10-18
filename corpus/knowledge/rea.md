# REA tooling reference (static inspection only)

REA — Reverse Engineer Anything — skill source:
~/.agents/skills/reverse-engineer-anything/ (SKILL.md + references/).
Package: no `rea` CLI installed fleet-wide; use
`npx -y rea-agents@6.4.0 <command>` (verified working at mint time,
v6.4.0). Provider readiness: native-provider install remains blocked
(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
mint).

Fleet precedent (revenger lane): `inspect-pe-resources` and related
inspect routes produce normalized JSON records with Evidence IDs;
saved evidence + a truth.json + a LEDGER of comparison checks is the
discipline. That lane owns REA-as-an-end and live-target runtime
evidence. This lane's authorized use:

- Static inspection of 3D craft artifacts: exported Godot binaries,
  .glb/.gltf/.obj containers, serialized scene/resource binaries the
  lane itself authored.
- Every REA-derived claim separates observation, inference, and
  unknown, and cites saved Evidence IDs under corpus/live/runs/.
- Refused: executing unknown/live targets beyond a declared target and
  lifecycle; DRM circumvention; publishing reversed material; claiming
  revenger's routes (PE/EVM/ZIP/ELF/JS-graph) as this lane's coverage.

Round-1 does not exercise REA; first REA use must be declared as its
own falsifiable axis-move with a rejection control, like any other.

## Correction note (r102, 2026-10-18)

The mint census sentence above ("no Ghidra, JADX, Binwalk/Unblob,
pwntools on this host") is a historical factual claim and is preserved
verbatim. It is now partly falsified on this host, re-measured
2026-10-18 (receipts: `reports/round-102/repairs/F6-rea-census.md`).

- **JADX, Binwalk, Unblob: present.** `jadx --version` → `1.5.6`
  (pacman `jadx 1.5.6-1`); `binwalk --version` → `binwalk 3.1.0`
  (pacman `binwalk 3.1.0-1`); `unblob --version` → `26.6.4`
  (`uv tool`, shim at `/home/vgpnk/.local/bin/unblob`). All three
  exit 0.
- **pwntools: present, via the env-routed interpreter only.**
  `$REA_PWNTOOLS_PYTHON -c "import pwnlib; print(pwnlib.version)"` →
  `4.15.0` (exit 0), while plain `python3 -c "import pwnlib"` still
  fails (exit 1). `inspect_binary_layout`'s caller-supplied-pwntools
  prerequisite is satisfiable here, but not from a bare `python3`.
- **JADX provider prerequisite: satisfied.** `$REA_JADX_MCP_JAR`
  points at `jadx-headless-mcp-0.7.1-all.jar` (valid archive, 42.6 MB)
  and `JAVA_HOME` is OpenJDK 21, above the required Java 17. The
  earlier word "blocked" no longer describes this route.
- **Still true, unchanged:** Ghidra absent (no PATH hit, no
  `/opt`/`/usr/share`/`~` install); Hopper absent; no `rea` CLI
  (`which rea` exits 1).
- **Pin currency:** `npx -y rea-agents@6.4.0` still resolves, so the
  mint line is stale-but-working rather than broken; registry latest is
  now `6.7.0`, which is also what the skill source
  (`~/.agents/skills/reverse-engineer-anything/SKILL.md`) documents.

Scope of this correction: it records **provider prerequisites**, not
capability. No REA run, MCP registration, or analysis was executed and
none is claimed; the authorized-use rules and the requirement that
first REA use be its own declared falsifiable axis-move with a
rejection control are unchanged. No Unreal runtime claim is made or
implied anywhere in this file.
