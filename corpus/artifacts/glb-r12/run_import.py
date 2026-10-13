#!/usr/bin/env python3
"""Bounded Godot headless import contrast for self-authored GLB bytes."""
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
LANE = HERE.parents[1]
SOURCE = LANE / "artifacts" / "glb-r9"
FIXTURES = LANE / "fixtures"
CASES = {"valid": SOURCE / "triangle.glb",
         "tolerated_header": SOURCE / "triangle-invalid.glb",
         "bad_magic": HERE / "triangle-bad-magic.glb"}
GOOD_LINES = ["IMPORT_ROOT name=triangle children=1",
              "IMPORT_CHILD name=TriangleNode type=MeshInstance3D position=(2.0, 0.0, -3.0) children=0",
              "IMPORT_MESH surfaces=1 vertices=3 points=[(0.0, 0.0, 0.0), (0.0, 1.0, 0.0), (1.0, 0.0, 0.0)]"]

def run(command):
    try:
        proc = subprocess.run(command, capture_output=True, text=True, timeout=20)
        return {"command": command, "exit": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr, "error": None}
    except subprocess.TimeoutExpired as exc:
        return {"command": command, "exit": None, "stdout": str(exc.stdout), "stderr": str(exc.stderr), "error": "TIMEOUT after 20s"}

def main():
    root = LANE / "live" / "runs" / ("r12-import-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ"))
    root.mkdir(parents=True)
    original_hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in CASES.items()}
    data = {}
    for name, source in CASES.items():
        scratch = root / name
        scratch.mkdir()
        shutil.copy2(FIXTURES / "project.godot", scratch / "project.godot")
        shutil.copy2(SOURCE / "inspect_import.gd", scratch / "inspect_import.gd")
        shutil.copy2(source, scratch / "triangle.glb")
        editor = run(["godot", "--headless", "--editor", "--import", "--path", str(scratch)])
        scene = run(["godot", "--headless", "--path", str(scratch), "--script", "res://inspect_import.gd"] )
        has_scene = bool(list((scratch / ".godot" / "imported").glob("*.scn")))
        data[name] = {"source_sha256": original_hashes[name], "editor": editor, "scene": scene,
                      "imported_scene_exists": has_scene, "scratch": str(scratch)}
    good = all(data[name]["editor"]["exit"] == 0 and data[name]["editor"]["stderr"] == ""
               and data[name]["scene"]["exit"] == 0 and data[name]["scene"]["stderr"] == ""
               and data[name]["imported_scene_exists"]
               and data[name]["scene"]["stdout"].strip().splitlines()[-3:] == GOOD_LINES
               for name in ("valid", "tolerated_header"))
    bad = data["bad_magic"]
    rejected = (bad["editor"]["exit"] == 0
                and "ERROR: Error importing 'res://triangle.glb'." in bad["editor"]["stderr"]
                and "ERROR: glTF: Error parsing .gltf JSON data:" in bad["editor"]["stderr"]
                and bad["scene"]["exit"] == 2
                and "IMPORT_REJECTED: no PackedScene" in bad["scene"]["stderr"]
                and not bad["imported_scene_exists"])
    unchanged = original_hashes == {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in CASES.items()}
    data["verdict"] = "PASS" if good and rejected and unchanged else "FAIL"
    data["positive_and_tolerated_control_same_scene"] = good
    data["bad_magic_rejected"] = rejected
    data["source_digests_unchanged"] = unchanged
    (root / "verdicts.json").write_text(json.dumps(data, indent=2) + "\n")
    print(f"{data['verdict']} Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt={root / 'verdicts.json'}")
    return 0 if data["verdict"] == "PASS" else 1

if __name__ == "__main__":
    sys.exit(main())
