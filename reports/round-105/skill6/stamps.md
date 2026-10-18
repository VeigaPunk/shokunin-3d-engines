# r105 SEAT-09 — SKILL §6 artifact stamps

**Seat:** SEAT-09 SKILL-STAMPS. Re-hashed after the r105 sixth row was present. HEAD was `1eaa568`; hashes below describe the observed worktree. The stale existing hashes were the gate runner and Kimi adaptation; §6 now carries their current hashes. I also added §6 entries for row F's report, saved receipt, runner, and fixture, and for the existing §1 re-derivation report. The Unreal-r22 directory and frozen round-101 group were expanded file-by-file in the record below. No fixture files were written.

## Hash command and observed output

Command run from the lane repository root:

```sh
sha256sum SKILL.md \
  corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  corpus/knowledge/unreal-mcp/gate/README.md \
  corpus/knowledge/unreal-mcp/README.md \
  corpus/knowledge/unreal-mcp/PROVENANCE.md \
  corpus/knowledge/unreal-mcp/adaptation-kimi.md \
  corpus/lessons/r102-unreal-integration.md \
  corpus/knowledge/engines.md \
  corpus/artifacts/unreal-r22/README.md \
  corpus/artifacts/unreal-r22/Headless3DFixture.uplugin \
  corpus/artifacts/unreal-r22/verify_descriptor.py \
  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin \
  reports/round-101/r101-reviewer-c1.md \
  reports/round-101/r101-reviewer-c2.md \
  reports/round-101/r101-reviewer-c3.md \
  reports/round-101/r101-mutation-tester.md \
  reports/round-101/r101-critic-c3.md \
  reports/round-102/skill-decision-table-draft.md \
  reports/round-103/skill-table-review.md \
  reports/round-104/skill/author.md \
  corpus/fixtures/run_battery.py \
  corpus/fixtures/phys3d_joints.gd \
  reports/round-104/physics/author.md \
  reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json
```

Observed SHA-256 output:

```text
ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608  SKILL.md
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf  corpus/knowledge/unreal-mcp/gate/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01  corpus/knowledge/unreal-mcp/PROVENANCE.md
a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1  corpus/knowledge/unreal-mcp/adaptation-kimi.md
cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2  corpus/lessons/r102-unreal-integration.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b  corpus/artifacts/unreal-r22/README.md
2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9  corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
ce07e9d5c03e892b0d9847b89ec67cc6b293f0979d2f5be5a99c6a53b21cea76  corpus/artifacts/unreal-r22/verify_descriptor.py
b56a356ef3c47a4880bd22f5dbcbb2ccf43e1cb65d263498674ef9b1c586ccf0  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin
e4b34df7e060298cf0b1f806c8519498620faed67e8e8ee7ce84299d81a7fb58  reports/round-101/r101-reviewer-c1.md
4a9e4bbeaa44d5d36d985dd1c81b9253b2d139f495156275d403566bb1e4d874  reports/round-101/r101-reviewer-c2.md
2113b3c5a8ae1aa3e4e1f85ac75e8c121540261ec8f31cc44ea379acdc0db45d  reports/round-101/r101-reviewer-c3.md
0885e58005b8b06febaa996a4fc54077ec62ebfe7f82337efecef3bc524974e5  reports/round-101/r101-mutation-tester.md
77ec9b360283980f6d542acad6646763f8c63d755f77af6c11715d2fe54f49c5  reports/round-101/r101-critic-c3.md
fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2  reports/round-102/skill-decision-table-draft.md
95d40d92432252f66d6edf886ac99bf60e190461f075db3d7936bf94527d6815  reports/round-103/skill-table-review.md
454ad5b6a215ea5ddfe01b8a6ebc69d91cc9c34c72e79f4fead8cc9e01ae5933  reports/round-104/skill/author.md
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
4b3cbbf04ec35960b5d4a4362d596eb4c3c3ab291a9e2ea6c32749a637f02b81  reports/round-104/physics/author.md
17b037d5154b7cf51a55df197a142f09ce3ea0fb9b4471f75a74a028f508397c  reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json
```

## Stamp changes and checks

- `corpus/knowledge/unreal-mcp/gate/run_gate.sh`: stale §6 value `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` → current `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`.
- `corpus/knowledge/unreal-mcp/adaptation-kimi.md`: stale §6 value `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` → current `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`.
- All other pre-existing literal hashes in §6 matched this output. The prior “worktree, uncommitted” labels for the gate files described the older r104 capture and were removed from the current re-hash table.
- Added §6 stamps for the row F source report and receipt, and the runner/fixture whose seed digests are in that receipt; `corpus/fixtures/**` remained read-only.

Command `git diff --check -- SKILL.md` completed successfully with no output (rc 0). The verification-time `git status --short` output was:

```text
 M SKILL.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
?? corpus/lessons/r105-unreal-lifecycle.md
?? reports/round-105/
```

This status contains no `corpus/fixtures/` change.
