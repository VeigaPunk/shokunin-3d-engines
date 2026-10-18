# r19 self-authored Unity-style scene (static evidence only)

References read 2026-10-13:
- Unity 6.6 Manual, [Format of text serialized files](https://docs.unity3d.com/Manual/FormatDescription.html): scene objects are separate `--- !u!<class> &<fileID>` documents; `!u!1` GameObject and `!u!4` Transform examples show `m_GameObject`, `m_Children`, `m_Father`, `m_LocalPosition` and `{fileID: ...}` links.
- Unity 6.6 Manual, [UnityYAML](https://docs.unity3d.com/Manual/UnityYAML.html): custom YAML subset; explicitly warns against generating/editing Unity YAML directly. This authored sample has **not** been imported or validated by Unity Editor.

From repository root, use the declared isolated Python package environment:

```sh
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
```

`Hierarchy.unity` is four self-authored documents: GameObject IDs 100/200,
Transform IDs 101/201. Parent local (10,0,0) + child local (1,2,-3) yields
(11,2,-3) only under the locally assumed identity transform composition.
`Hierarchy.broken-reference.unity` changes **only** child `m_Father.fileID`
101→999; the local checker rejects that dangling link. It does not implement
UnityYAML or establish actual Unity import, scene execution, rendering, or
editor compatibility; strict literal checks intentionally scope the artifact.
