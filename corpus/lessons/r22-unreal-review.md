# Round 22 — independent Unreal-style descriptor review

**Finding: qualified static coverage improvement.** I independently replayed the self-authored JSON descriptor and five adversarial controls. The checker accepted the source and rejected the paired bad Type, missing Name, duplicate Type JSON key, and appended second module. I made no implementation edits, push, or merge. No Unreal Editor or UnrealBuildTool was available or run.

## Source and cited format

Epic Games, [Plugins in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/plugins-in-unreal-engine), sections “Plugin Descriptor Files,” “Descriptor File Format,” and “Module Descriptors” (retrieved HTTP 200 on 2026-10-13), says `.uplugin` is JSON; `FileVersion` is the **only required descriptor field**, with current recommended value **3** (older values supported for compatibility). A plugin with code has module descriptors with required `Name` and `Type`; documented Type options: `Runtime`, `RuntimeNoCommandlet`, `Developer`, `Editor`, `EditorNoCommandlet`, `Program`. Epic's example contains `Version`, `VersionName`, `FriendlyName`, `Description`, `Category`, `CanContainContent` and module `LoadingPhase: Default`. I checked `.shokunin/game-dev-3d/LOG.md` round 22, `PROVINCE.md`, and `corpus/artifacts/unreal-r22/README.md`. The source has `FileVersion: 3`, one `Headless3DFixture` module with `Type: Runtime`; it has no actual plugin source/binary.

SHA-256 (byte-for-byte files):

| File relative to `corpus/artifacts/unreal-r22/` | Bytes | SHA-256 |
|---|---:|---|
| `Headless3DFixture.uplugin` | 374 | `2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9` |
| `Headless3DFixture.bad-type.uplugin` | 374 | `b56a356ef3c47a4880bd22f5dbcbb2ccf43e1cb65d263498674ef9b1c586ccf0` |
| `verify_descriptor.py` | 3122 | `ce07e9d5c03e892b0d9847b89ec67cc6b293f0979d2f5be5a99c6a53b21cea76` |
| `README.md` | 1460 | `26a126047b7fb7671f5216313ee8938a6076a4c3de5cfd06fb11b4338c751cba` |

Both descriptor files parse with standard Python `json.loads` into dictionaries. The control is **exactly** `source_bytes.replace(b'"Type": "Runtime"', b'"Type": "Unknown"')`: the source token occurs once, replacement yields precisely all control bytes, and byte offsets 320–326 alone change. Same byte count is incidental.

## Exact replay (repository root)

```sh
python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
# exit 0: PASS local-static actual=accept expected=accept; one fixed-scope Unreal-style Runtime module descriptor
python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
# exit 0: PASS local-static actual=reject expected=reject; unsupported module Type: 'Unknown'
```

I privately copied the source into `/tmp/r22-unreal-review-y5dqvv0d` and applied one control at a time; command form was `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py /tmp/r22-unreal-review-y5dqvv0d/<name>.uplugin --expect-reject`:

| `<name>` | Change | Exit; actual result/reason | SHA-256 of private copy |
|---|---|---|---|
| `missing-name` | delete sole module `Name` | 0; PASS reject, `module fields missing or unexpected` | `09acc4ce50d0e5642ad6794ecb70b991fb1ed62d2e2f7f609803524c87035a7e` |
| `duplicate-key` | add a second textual `"Type": "Runtime"` in the module | 0; PASS reject, `invalid JSON: duplicate JSON key: Type` | `f163a3ba1e58b04668f2a15d4dc24cece31cb73fbcb3caf96e073b9c493a7a3b` |
| `extra-module` | append a copy of the valid module | 0; PASS reject, `expected exactly one module object` | `e0f73b4475cf0805c428b8a04c1d119ab82f27eb2523b644b808966590bcaa5d` |

The duplicate-key control is syntactically parseable by ordinary last-wins JSON decoders, but the checker uses `object_pairs_hook` to reject duplicates. The missing Name and extra module controls remain ordinary valid JSON. In two **additional private boundary checks**, changing just Runtime→Editor (a **documented valid Type**) yielded exit 0 with `--expect-reject` and reason `authored module type/loading phase mismatch` (SHA `4e1bb981665b535768522aea6583e57bcdccdf950ba4a7d5d4c862f14bb19b5a`); changing just FileVersion 3→2 yielded exit 0 with `--expect-reject` and reason `FileVersion must be 3 for authored sample` (SHA `f2a885970ee1ccb9aa26b304883eda1efb81bd3c6219847eccb82567c354e582`). **These are not invalid Unreal descriptors** according to the cited vocabulary/version guidance; rejection is the local checker enforcing an exact authored sample. Its six-element `MODULE_TYPES` set matches Epic's list, but its later `module["Type"] != "Runtime"` rejects the other five. Likewise it deliberately enforces FileVersion 3, though Epic allows older values. It requires an exact top-level subset and one module; it is not a general Unreal schema validator. `--expect-reject` exit 0 means an *expected local rejection*, not Unreal rejection.

## Existing execution baselines

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
# exit 0, Godot 4.7.2.stable.arch_linux.ed1daf0bf; 29/29 PASS (14 ordinary, 15 negative), zero failures; seeds_unchanged=true; probes=0
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
# exit 0, PASS positive (0), negative_wrong_order (2), mutation (1); 3/3; seeds_unchanged=true
```

Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc`; fixture `run_battery.py` seed SHA `a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`. Three.js runner SHA `f9f40d4763748223a40e761c09c01e4762f21218744f09aeefe74f069a547d7f`, scene source SHA `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af`, pinned package lock SHA `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8`. A separate direct `node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs` exited 0 and printed its positive case only; the three-case runner above is the actual 3/3 evidence.

**Per-axis judgment:** coverage improved, narrowly, by adding a cited Unreal-style **static JSON descriptor and discriminating local negative controls**; depth unchanged, calibration unchanged. No tested Unreal plugin loading, binary resolution, UBT compilation, rendering, gameplay, full schema conformance, arbitrary plugin descriptors, or cross-engine behavioral inference. Local acceptance is not engine acceptance. No optional Godot probes were run in this review; default 29/29 is the sole Godot regression result.
