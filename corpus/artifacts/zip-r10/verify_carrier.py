#!/usr/bin/env python3
"""Compare retained REA ZIP inventory to independently read member bytes/truth."""
import hashlib
import json
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ART = HERE.parent / "glb-r9"
truth = json.loads((ART / "truth.json").read_text())

def inspect(name, receipt_name):
    path = HERE / name
    report = json.loads((HERE / receipt_name).read_text())
    if not report.get("ok") or report["data"].get("operation") != "inspect_artifact":
        raise ValueError("REA inspection did not succeed")
    evidence = report["data"]
    detail = evidence["normalized_result"]["substeps"][0]["evidence"]["normalized_result"]
    if not evidence.get("evidence_id") or detail["manifest"]["root_format"] != "zip":
        raise ValueError("REA Evidence/ZIP manifest missing")
    if detail["manifest"]["root_sha256"] != hashlib.sha256(path.read_bytes()).hexdigest():
        raise ValueError("REA ZIP root digest mismatch")
    occurrences = {item["logical_path"]: item for item in detail["occurrences"]}
    nodes = {node["artifact_id"]: node for node in detail["nodes"]}
    if set(occurrences) != {".", "triangle.glb", "truth.json"}:
        raise ValueError("REA member inventory mismatch")
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        if sorted(names) != ["triangle.glb", "truth.json"]:
            raise ValueError("ZIP member list mismatch")
        hashes = {entry: hashlib.sha256(archive.read(entry)).hexdigest() for entry in names}
    for entry, digest in hashes.items():
        occurrence = occurrences[entry]
        node = nodes[occurrence["artifact_id"]]
        if node["sha256"] != digest or occurrence["hash_status"] != "verified":
            raise ValueError("REA/member byte digest mismatch")
    if hashes["truth.json"] != hashlib.sha256((ART / "truth.json").read_bytes()).hexdigest():
        raise ValueError("embedded truth differs from source")
    return {"evidence_id": evidence["evidence_id"], "root_sha256": detail["manifest"]["root_sha256"],
            "member_sha256": hashes}

good = inspect("triangle-carrier.zip", "rea-positive.json")
bad = inspect("triangle-invalid-carrier.zip", "rea-negative.json")
if good["member_sha256"]["triangle.glb"] != truth["sha256"]:
    raise ValueError("positive member differs from truth")
if bad["member_sha256"]["triangle.glb"] == truth["sha256"]:
    raise ValueError("invalid member false accept")
# REA accepts ZIP inventory for both carriers; the local GLB validator rejects the bad header.
valid_raw = (ART / "triangle.glb").read_bytes()
invalid_raw = (ART / "triangle-invalid.glb").read_bytes()
differences = [i for i, (a, b) in enumerate(zip(valid_raw, invalid_raw)) if a != b]
if len(valid_raw) != len(invalid_raw) or differences != [8]:
    raise ValueError("invalid control is not exactly one altered byte at GLB length")
if bad["member_sha256"]["triangle.glb"] != hashlib.sha256(invalid_raw).hexdigest():
    raise ValueError("invalid ZIP member not authored rejection bytes")
print(json.dumps({"verdict": "PASS", "rea_positive_evidence": good["evidence_id"],
                  "rea_negative_evidence": bad["evidence_id"],
                  "positive_member_sha256": good["member_sha256"]["triangle.glb"],
                  "negative_member_sha256": bad["member_sha256"]["triangle.glb"],
                  "negative_rejected_by_local_identity": True,
                  "rea_does_not_parse_glb": True}, indent=2))
