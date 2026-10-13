#!/usr/bin/env python3
"""Strict local GLB 2.0 fixture check; this is NOT REA evidence."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

HERE = Path(__file__).resolve().parent

def inspect(path):
    raw = path.read_bytes()
    if len(raw) < 28:
        raise ValueError("short GLB")
    magic, version, declared = struct.unpack_from("<4sII", raw)
    if magic != b"glTF" or version != 2 or declared != len(raw):
        raise ValueError("GLB header magic/version/length mismatch")
    json_length, json_type = struct.unpack_from("<I4s", raw, 12)
    if json_type != b"JSON" or json_length % 4:
        raise ValueError("JSON chunk header invalid")
    body = json.loads(raw[20:20 + json_length].decode())
    binary_header = 20 + json_length
    binary_length, binary_type = struct.unpack_from("<I4s", raw, binary_header)
    binary_offset = binary_header + 8
    if binary_type != b"BIN\0" or binary_length % 4 or binary_offset + binary_length != len(raw):
        raise ValueError("BIN chunk header/length invalid")
    if body.get("asset", {}).get("version") != "2.0":
        raise ValueError("glTF asset version mismatch")
    accessor = body["accessors"][0]
    view = body["bufferViews"][accessor["bufferView"]]
    if (body["buffers"][view["buffer"]]["byteLength"] != binary_length
            or view["byteOffset"] != 0 or view["byteLength"] != 36
            or accessor["componentType"] != 5126 or accessor["count"] != 3
            or accessor["type"] != "VEC3"):
        raise ValueError("triangle accessor/buffer mismatch")
    positions = [list(struct.unpack_from("<fff", raw, binary_offset + 12 * index)) for index in range(3)]
    return {"sha256": hashlib.sha256(raw).hexdigest(), "byteLength": len(raw),
            "jsonChunkLength": json_length, "binChunkLength": binary_length,
            "jsonChunkOffset": 20, "binChunkOffset": binary_offset,
            "node": body["nodes"][0]["name"], "translation": body["nodes"][0]["translation"],
            "mesh": body["meshes"][0]["name"],
            "primitiveMode": body["meshes"][0]["primitives"][0]["mode"],
            "positions": positions}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--receipt", type=Path)
    args = parser.parse_args()
    truth = json.loads((HERE / "truth.json").read_text())
    good = inspect(HERE / truth["artifact"])
    expected = {key: value for key, value in truth.items() if key in good}
    if good != expected:
        raise ValueError(f"truth mismatch: {good!r} != {expected!r}")
    try:
        inspect(HERE / "triangle-invalid.glb")
    except ValueError as exc:
        rejected = str(exc) == "GLB header magic/version/length mismatch"
    else:
        rejected = False
    payload = {"positive": good, "negative_rejected": rejected,
               "rejection_reason": "GLB header magic/version/length mismatch",
               "verdict": "PASS" if rejected else "FAIL",
               "evidence_type": "local static validator, not REA"}
    if args.receipt:
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        args.receipt.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{payload['verdict']} local GLB static: positive truth matches; length-control rejected={rejected}")
    return 0 if rejected else 1

if __name__ == "__main__":
    raise SystemExit(main())
