#!/usr/bin/env python3
"""Strict local static Unity-style scene reference check, not Unity import."""
import argparse
import re
from pathlib import Path

import yaml


class NoDuplicateLoader(yaml.SafeLoader):
    pass


def unique_mapping(loader, node):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node)
        if key in result:
            raise ValueError(f"duplicate mapping key: {key}")
        result[key] = loader.construct_object(value_node)
    return result


NoDuplicateLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)

HERE = Path(__file__).resolve().parent
HEADER = re.compile(r"^--- !u!(1|4) &(\d+)$", re.M)


def check(path: Path) -> tuple[bool, str]:
    text = path.read_text()
    if not text.startswith("%YAML 1.1\n%TAG !u! tag:unity3d.com,2011:\n"):
        return False, "missing Unity-style preamble"
    headers = list(HEADER.finditer(text))
    if len(headers) != 4 or len(set(int(m.group(2)) for m in headers)) != 4:
        return False, "expected four unique class/object documents"
    if text[len("%YAML 1.1\n%TAG !u! tag:unity3d.com,2011:\n"):headers[0].start()].strip():
        return False, "unexpected text before first document"
    documents = {}
    for index, match in enumerate(headers):
        segment = text[match.end():headers[index + 1].start() if index + 1 < len(headers) else len(text)]
        try:
            obj = yaml.load(segment, Loader=NoDuplicateLoader)
        except (yaml.YAMLError, ValueError) as exc:
            return False, f"invalid document YAML: {exc}"
        class_name = "GameObject" if match.group(1) == "1" else "Transform"
        if not isinstance(obj, dict) or set(obj) != {class_name} or not isinstance(obj[class_name], dict):
            return False, f"class tag/document mismatch fileID={match.group(2)}"
        documents[int(match.group(2))] = (class_name, obj[class_name])
    if {id_: kind for id_, (kind, _) in documents.items()} != {100: "GameObject", 101: "Transform", 200: "GameObject", 201: "Transform"}:
        return False, "unexpected object classes or fileIDs"
    def ref(value):
        if not isinstance(value, dict) or set(value) != {"fileID"} or type(value["fileID"]) is not int:
            raise ValueError(f"invalid fileID reference: {value!r}")
        return value["fileID"]
    try:
        parent_go, parent_tr = documents[100][1], documents[101][1]
        child_go, child_tr = documents[200][1], documents[201][1]
        if parent_go["m_Name"] != "Parent3D" or child_go["m_Name"] != "Child3D":
            return False, "unexpected named objects"
        if not isinstance(parent_go["m_Component"], list) or not isinstance(child_go["m_Component"], list):
            return False, "GameObject component lists malformed"
        if len(parent_go["m_Component"]) != 1 or len(child_go["m_Component"]) != 1:
            return False, "unexpected GameObject component references"
        if (not isinstance(parent_go["m_Component"][0], dict)
                or set(parent_go["m_Component"][0]) != {"component"}
                or not isinstance(child_go["m_Component"][0], dict)
                or set(child_go["m_Component"][0]) != {"component"}):
            return False, "GameObject component reference shape invalid"
        if ref(parent_go["m_Component"][0]["component"]) != 101 or ref(child_go["m_Component"][0]["component"]) != 201:
            return False, "GameObject component references broken"
        if ref(parent_tr["m_GameObject"]) != 100 or ref(child_tr["m_GameObject"]) != 200:
            return False, "Transform GameObject back-references broken"
        if ref(parent_tr["m_Father"]) != 0 or [ref(x) for x in parent_tr["m_Children"]] != [201]:
            return False, "parent hierarchy references broken"
        if ref(child_tr["m_Father"]) != 101 or child_tr["m_Children"] != []:
            return False, f"child father reference broken: {child_tr['m_Father']}"
        def xyz(value):
            return tuple(value[key] for key in ("x", "y", "z"))
        if xyz(parent_tr["m_LocalPosition"]) != (10, 0, 0) or xyz(child_tr["m_LocalPosition"]) != (1, 2, -3):
            return False, "local position literal mismatch"
        if xyz(parent_tr["m_LocalScale"]) != (1, 1, 1) or xyz(child_tr["m_LocalScale"]) != (1, 1, 1):
            return False, "local scale mismatch"
        for transform in (parent_tr, child_tr):
            if transform["m_LocalRotation"] != {"x": 0, "y": 0, "z": 0, "w": 1}:
                return False, "non-identity rotation"
        world = tuple(a + b for a, b in zip(xyz(parent_tr["m_LocalPosition"]), xyz(child_tr["m_LocalPosition"])))
        if world != (11, 2, -3):
            return False, "world position literal mismatch"
    except (KeyError, IndexError, TypeError, ValueError) as exc:
        return False, f"malformed or unresolved reference: {exc}"
    return True, "two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?", type=Path, default=HERE / "Hierarchy.unity")
    parser.add_argument("--expect-reject", action="store_true")
    args = parser.parse_args()
    accepted, reason = check(args.path)
    expected = not args.expect_reject
    print(f"{'PASS' if accepted == expected else 'FAIL'} local-static actual={'accept' if accepted else 'reject'} expected={'accept' if expected else 'reject'} path={args.path} reason={reason}")
    return 0 if accepted == expected else 1


if __name__ == "__main__":
    raise SystemExit(main())
