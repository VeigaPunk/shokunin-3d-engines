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
