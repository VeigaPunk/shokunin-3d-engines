# r22 self-authored Unreal-style plugin descriptor (static only)

Epic Games, [Plugins in Unreal Engine](https://dev.epicgames.com/documentation/en-us/unreal-engine/plugins-in-unreal-engine), UE 5.8 documentation read 2026-10-13, *Plugin Descriptor Files*, *Descriptor File Format*, *Module Descriptors*: `.uplugin` is JSON; `FileVersion` is the only required top-level field (current documented value 3); code module entries require `Name` and `Type`, with documented values Runtime, RuntimeNoCommandlet, Developer, Editor, EditorNoCommandlet and Program. The example also shows `Version`, `VersionName`, `FriendlyName`, `Description`, `Category`, `CanContainContent`, `Modules`, and `LoadingPhase=Default`. Our selected field subset and exact author constants are checked locally, not by Unreal.

From repo root:

```sh
python3 corpus/artifacts/unreal-r22/verify_descriptor.py
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
```

The paired control changes only module `Type` from documented `Runtime` to `Unknown` while remaining valid JSON. The checker rejects duplicate JSON keys and extra modules, not a general Unreal descriptor schema. This sample has no actual plugin source/binary and **was not loaded by Unreal Editor or UnrealBuildTool**; it establishes neither runtime gameplay nor rendering.
