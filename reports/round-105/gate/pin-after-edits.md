# r105 gate pin after adaptation edit

`git status --short -- corpus/knowledge/unreal-mcp/adaptation-kimi.md corpus/knowledge/unreal-mcp/gate/README.md` → `M corpus/knowledge/unreal-mcp/adaptation-kimi.md`; README unchanged.

`sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md corpus/knowledge/unreal-mcp/gate/README.md corpus/knowledge/unreal-mcp/gate/run_gate.sh` → adaptation `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`; README `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`; gate `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`.

`GATE_WORKDIR=/tmp bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; rc=$?; printf 'GATE_EXIT=%s\n' "$rc"; exit "$rc"` → `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`; CHECK 1 PASS; clone `a6aa73ada02a9fb1f5415bec491f9942c519b297`, clean, 12 tracked, no path/blob diffs; CHECK 2 PASS; `CARDS=13 EXPECTED=13 BAD=0`, census `12/1/0`, `NAME_SET=OK`; CHECK 3 PASS; `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`; CHECK 4 PASS; `GATE RESULT: PASS (checks failed: 0)`; `GATE_EXIT=0`.

`grep -nE '^\*\*Expected \(re-measured|^POINTERS=|pointer endpoints / strings' corpus/knowledge/unreal-mcp/gate/README.md` → active expected summary at line 271 is `POINTERS=103 ... UNRESOLVED=0`; table at line 283 pins `103 / 41`.

Measured POINTERS `103` matches the active README pin `103`; no pin drift, so `gate/README.md` was not edited.
