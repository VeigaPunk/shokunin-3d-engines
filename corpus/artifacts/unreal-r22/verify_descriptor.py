#!/usr/bin/env python3
"""Bounded local static .uplugin field check, never an Unreal Editor or UBT test."""
import argparse
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODULE_TYPES = {"Runtime", "RuntimeNoCommandlet", "Developer", "Editor", "EditorNoCommandlet", "Program"}


def no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def check(path: Path) -> tuple[bool, str]:
    try:
        payload = json.loads(path.read_text(), object_pairs_hook=no_duplicates)
    except (json.JSONDecodeError, ValueError) as exc:
        return False, f"invalid JSON: {exc}"
    if not isinstance(payload, dict) or set(payload) != {"FileVersion", "Version", "VersionName", "FriendlyName", "Description", "Category", "CanContainContent", "Modules"}:
        return False, "unexpected descriptor fields"
    if type(payload["FileVersion"]) is not int or payload["FileVersion"] != 3:
        return False, "FileVersion must be 3 for authored sample"
    if type(payload["Version"]) is not int or payload["Version"] != 1 or payload["VersionName"] != "1.0":
        return False, "authored version mismatch"
    if payload["FriendlyName"] != "Headless 3D Fixture" or not isinstance(payload["Description"], str) or not payload["Description"] or payload["Category"] != "Examples":
        return False, "authored descriptive fields mismatch"
    if type(payload["CanContainContent"]) is not bool or payload["CanContainContent"] is not False:
        return False, "authored content policy mismatch"
    modules = payload["Modules"]
    if not isinstance(modules, list) or len(modules) != 1 or not isinstance(modules[0], dict):
        return False, "expected exactly one module object"
    module = modules[0]
    if set(module) != {"Name", "Type", "LoadingPhase"}:
        return False, "module fields missing or unexpected"
    if module["Name"] != "Headless3DFixture":
        return False, "module Name missing or different"
    if type(module["Type"]) is not str or module["Type"] not in MODULE_TYPES:
        return False, f"unsupported module Type: {module['Type']!r}"
    if module["Type"] != "Runtime" or module["LoadingPhase"] != "Default":
        return False, "authored module type/loading phase mismatch"
    return True, "one fixed-scope Unreal-style Runtime module descriptor (local static JSON)"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", nargs="?", type=Path, default=HERE / "Headless3DFixture.uplugin")
    parser.add_argument("--expect-reject", action="store_true")
    args = parser.parse_args()
    accepted, reason = check(args.path)
    expected = not args.expect_reject
    print(f"{'PASS' if accepted == expected else 'FAIL'} local-static actual={'accept' if accepted else 'reject'} expected={'accept' if expected else 'reject'} path={args.path} reason={reason}")
    return 0 if accepted == expected else 1


if __name__ == "__main__":
    raise SystemExit(main())
