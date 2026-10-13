#!/usr/bin/env python3
"""Run the read-only game-dev-3d Godot fixtures serially in an isolated scratch project.

Seeds in this directory are never edited: every case runs against a copy under
corpus/live/runs/<ts>/scratch, and the run records a SHA-256 map of the seeds
before and after so that any mutation of a seed fails the battery.

Exit contract per case (authored in each fixture's header comment):
  exit 0 + exact stdout "PASS ..." marker                        -> positive passes
  exit 2 + exact stdout "NEGATIVE REJECTED: ..." marker          -> intended negative
  exit 1, timeout, crash, missing marker, SCRIPT ERROR/Parse
  Error, any unexpected ERROR: line, or an ObjectDB leak warning -> FAIL

Battery exit code is 0 only when every case passes.
"""
import argparse
import hashlib
import json
import os
import re
import select
import shutil
import signal
import subprocess
import time
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
CASE_TIMEOUT_SECONDS = 20

# (case name, script, flags, expected exit, exact stdout marker line)
CASES = [
    ("camera3d_ortho", "camera3d_ortho.gd", [], 0,
     "PASS camera3d_ortho viewport=800,600 front_screen=550.000,225.000 deep_screen=550.000,225.000 near=1.000 far=10.000"),
    ("camera3d_ortho_outside", "camera3d_ortho.gd", ["--outside"], 2,
     "NEGATIVE REJECTED: camera3d_ortho lateral_outside screen=850.000,225.000 in_frustum=false controls_same_pixel=true"),
    ("camera3d_ortho_near", "camera3d_ortho.gd", ["--near-point"], 2,
     "NEGATIVE REJECTED: camera3d_ortho near_plane_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=true geometric_front=true controls_same_pixel=true"),
    ("scene3d_resource_disk_local", "scene3d_resource_disk.gd", [], 0,
     "PASS scene3d_resource_disk local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true"),
    ("scene3d_resource_disk_shared", "scene3d_resource_disk.gd", ["--shared"], 2,
     "NEGATIVE REJECTED: scene3d_resource_disk shared_mesh_mutation second_size=2.000,1.000,1.000 loaded_size=2.000,1.000,1.000 same_resource=true"),
    ("scene3d_resource_local", "scene3d_resource.gd", [], 0,
     "PASS scene3d_resource local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true"),
    ("scene3d_resource_shared", "scene3d_resource.gd", ["--shared"], 2,
     "NEGATIVE REJECTED: scene3d_resource shared_mesh_mutation second_size=2.000,1.000,1.000 source_size=2.000,1.000,1.000 same_resource=true"),
    ("scene3d_disk", "scene3d_disk.gd", [], 0,
     "PASS scene3d_disk loaded_world=11.000,2.000,2.000 source_intact=true mesh_present=true"),
    ("scene3d_disk_wrong_local", "scene3d_disk.gd", ["--wrong-local"], 2,
     "NEGATIVE REJECTED: scene3d_disk loadable_wrong_local source_intact=true loaded_world=12.000,2.000,2.000 expected_world=11.000,2.000,2.000 mesh_present=true"),
    ("scene3d_instances", "scene3d_instance.gd", [], 0,
     "PASS scene3d_instances source_intact=true first_world=11.000,2.000,-3.000 second_world=-9.000,2.000,2.000 distinct_nodes=true"),
    ("scene3d_instances_wrong_local", "scene3d_instance.gd", ["--wrong-local"], 2,
     "NEGATIVE REJECTED: scene3d_instances wrong_second_local source_intact=true first_world=11.000,2.000,-3.000 second_world=-8.000,2.000,2.000 expected_second=-9.000,2.000,2.000"),
    ("slope3d_floor", "slope3d_angle.gd", [], 0,
     "PASS slope3d_floor normal_y=0.866 floor_limit=45.000 on_floor=true on_wall=false live_contact=true"),
    ("slope3d_steep", "slope3d_angle.gd", ["--steep"], 2,
     "NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor normal_y=0.500 floor_limit=45.000 on_floor=false on_wall=true live_contact=true"),
    ("floor3d_ground", "floor3d_ground.gd", [], 0,
     "PASS floor3d_ground final_y=1.000 first_contact_tick=30 normal=0.000,1.000,0.000 on_floor=true ticks=60"),
    ("floor3d_airborne", "floor3d_ground.gd", ["--lower-floor"], 2,
     "NEGATIVE REJECTED: floor3d_ground airborne_with_lower_floor final_y=-2.000 contacts=0 on_floor=false floor_intact=true ticks=60"),
    ("body3d_contact", "body3d_slide.gd", [], 0,
     "PASS body3d_contact start_z=6.000 expected_plane_z=2.500 final_z=2.500 ticks=60 "
     "first_contact_tick=21 on_wall=true normal=0.000,0.000,1.000"),
    ("body3d_contact_far", "body3d_slide.gd", ["--far-body"], 2,
     "NEGATIVE REJECTED: body3d_contact no_contact_at_far_arrangement start_z=40.000 "
     "final_z=30.000 expected_plane_z=2.500 contacts=0 on_wall=false wall_intact=true"),
    ("area3d_chain", "area3d_chain.gd", [], 0,
     "PASS area3d_chain collected=1 entries=1 overlapping=1 body_name=Runner3D "
     "body_layer=2 entry_x=4.200 pickup_x=6.000"),
    ("area3d_chain_no_overlap", "area3d_chain.gd", ["--no-overlap"], 2,
     "NEGATIVE REJECTED: area3d_chain no_overlap_signal_absent collected=0 entries=0 "
     "overlapping=0 runner_x=6.000 pickup_x=40.000 monitoring=true mask_matches_layer=true"),
    ("camera3d_project", "camera3d_project.gd", [], 0,
     "PASS camera3d_project viewport=800,600 fov=90.000 proj_x_scale=0.750 "
     "proj_y_scale=1.000 world=2.000,1.000,-4.000 screen=550.000,225.000 "
     "center_screen=400.000,300.000 mirror_screen=250.000,375.000 behind=false in_frustum=true"),
    ("camera3d_project_behind", "camera3d_project.gd", ["--behind-camera"], 2,
     "NEGATIVE REJECTED: camera3d_project behind_camera_projection_rejected "
     "point=2.000,1.000,4.000 is_position_behind=true in_frustum=false "
     "raw_screen=250.000,375.000 collides_with_mirrored_control=true "
     "lateral_screen=3400.000,300.000 lateral_in_frustum=false in_front_control_accepted=true"),
    ("camera3d_depth", "camera3d_depth.gd", [], 0,
     "PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 "
     "screen=550.000,225.000 depth=4.000 far=10.000 near=1.000"),
    ("camera3d_depth_far", "camera3d_depth.gd", ["--far-point"], 2,
     "NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 "
     "in_frustum=false behind=false near_control_visible=true"),
    ("camera3d_depth_near", "camera3d_depth.gd", ["--near-point"], 2,
     "NEGATIVE REJECTED: camera3d_depth near_point_depth=0.500 screen=550.000,225.000 "
     "in_frustum=false api_behind=true geometric_front=true near_control_visible=true"),
    ("navigation3d_path", "navigation3d_path.gd", [], 0,
     "PASS navigation3d_path points=2 start=1.000,0.000,1.000 end=3.000,0.000,3.000 region_active=true"),
    ("navigation3d_path_disconnected", "navigation3d_path.gd", ["--disconnected"], 2,
     "NEGATIVE REJECTED: navigation3d_path disconnected_endpoint_rejected "
     "source_end=4.000,0.000,3.000 target_end=23.000,0.000,3.000 "
     "source_control_points=2 target_control_points=2"),
    ("raycast3d_hit", "raycast3d.gd", [], 0,
     "PASS raycast3d hits=1 position=0.000,2.000,0.000 normal=0.000,1.000,0.000 "
     "collider=Wall collider_id_matches=true miss_hits=0"),
    ("raycast3d_miss", "raycast3d.gd", ["--miss-ray"], 2,
     "NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 "
     "control_position=0.000,2.000,0.000 miss_from=0.000,6.000,9.000 miss_hits=0 "
     "miss_offset_z=9.000 box_half_depth_z=2.000"),
    ("transform3d_compose", "transform3d_compose.gd", [], 0,
     "PASS transform3d_compose parent_origin=2.000,0.000,0.000 "
     "child_local_origin=0.000,0.000,-3.000 global_origin=-1.000,0.000,0.000 "
     "basis_x=0.000,0.000,-1.000 basis_y=1.000,0.000,0.000 basis_z=0.000,-1.000,0.000 "
     "composition_identity=true determinant=1.000 wrong_order_rejected=true"),
    ("transform3d_compose_wrong_order", "transform3d_compose.gd", ["--wrong-order"], 2,
     "NEGATIVE REJECTED: transform3d_compose wrong_order_composition_rejected "
     "expected_origin=-1.000,0.000,0.000 wrong_order_origin=2.000,0.000,-3.000 "
     "expected_basis_x=0.000,0.000,-1.000 wrong_order_basis_x=0.000,1.000,0.000 "
     "correct_order_matches=true"),
    ("input3d_move", "input3d_move.gd", [], 0,
     "PASS input3d_move key=W receipts=1 releases=1 ticks=10 "
     "displacement=1.000,0.000,0.000 expected_x=1.000 post_release_ticks=5 "
     "post_release_displacement=0.000"),
    ("input3d_move_no_event", "input3d_move.gd", ["--no-input"], 2,
     "NEGATIVE REJECTED: input3d_move no_event_zero_displacement receipts=0 intent=false "
     "ticks=10 displacement=0.000,0.000,0.000 late_control_receipts=1 late_control_ticks=5 "
     "late_control_displacement=0.500"),
]

# Adversarial self-check, run only with --probe-failing. Exactly one authored
# constant of one fixture is mutated in a scratch copy: the wall box depth. The
# expected contact plane stays the hand-authored literal 2.5, so the engine stop
# at 3.5 must be rejected. A self-consistent re-derivation would have hidden
# this, which is the point of the probe.
MUTATION = {
    "case": "body3d_contact",
    "script": "body3d_slide.gd",
    "flags": [],
    "old": "const BOX_SIZE := Vector3(4.0, 4.0, 4.0)",
    "new": "const BOX_SIZE := Vector3(4.0, 4.0, 6.0)",
    "expected_exit": 1,
    "forbidden_stdout": "PASS body3d_contact",
    "expected_diagnostic": ("ERROR: body3d_slide: body did not stop at the contact "
                            "plane final_z=3.500 expected=2.500"),
}

LEAKED_OBJECTDB = re.compile(
    r"^WARNING: [1-9][0-9]* ObjectDB instances were leaked at exit"
    r"(?: \(run with `--verbose` for details\)\.)?$")


def seed_digests() -> dict:
    # __pycache__ is tooling residue (importing this runner creates it), not a
    # seed, so it is excluded from both the digest map and the scratch copy.
    return {str(path.relative_to(HERE)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(HERE.rglob("*"))
            if path.is_file() and "__pycache__" not in path.parts
            and path.relative_to(HERE).parts[0] != "three"}


def run_process(command, timeout_seconds):
    try:
        proc = subprocess.run(command, capture_output=True, text=True, timeout=timeout_seconds)
        return proc.stdout, proc.stderr, proc.returncode, None
    except subprocess.TimeoutExpired as exc:
        def text(value):
            if isinstance(value, bytes):
                return value.decode(errors="replace")
            return value or ""
        return (text(exc.stdout), text(exc.stderr), None,
                f"TIMEOUT after {timeout_seconds} seconds")
    except OSError as exc:
        return "", str(exc), None, f"launch error: {exc}"


def classify(stdout, stderr, code, error, expected_exit, marker):
    """Return (passed, reasons). The marker must be an exact stdout line."""
    reasons = []
    if error is not None:
        reasons.append(error)
    if code is None:
        reasons.append("no exit code (process killed or timed out)")
    elif code < 0:
        reasons.append(f"process died on signal {-code}")
    elif code != expected_exit:
        reasons.append(f"exit {code} != expected {expected_exit}")
    lines = [line.strip() for line in stdout.splitlines()]
    if marker not in lines:
        reasons.append("exact stdout marker missing")
    for line in stderr.splitlines():
        if line.strip():
            reasons.append(f"unexpected stderr line: {line.strip()}")
    for stream_name, stream in (("stdout", stdout), ("stderr", stderr)):
        if "SCRIPT ERROR:" in stream:
            reasons.append(f"SCRIPT ERROR on {stream_name}")
        if "Parse Error:" in stream:
            reasons.append(f"Parse Error on {stream_name}")
    for line in [line.strip() for line in (stdout + stderr).splitlines()]:
        if "ERROR:" in line:
            reasons.append(f"unexpected diagnostic: {line}")
        elif LEAKED_OBJECTDB.match(line):
            reasons.append(f"unexpected leak warning: {line}")
    return (not reasons, reasons)


def probe_crash_exit(godot, scratch, run_dir):
    marker = "CRASH_EXIT_3D: spatial node ready"
    script = "res://crash_exit3d.gd"
    normal_command = [godot, "--headless", "--path", str(scratch), "--script", script, "--"]
    normal_out, normal_err, normal_code, normal_error = run_process(normal_command, 8)
    normal_pass, normal_reasons = classify(normal_out, normal_err, normal_code, normal_error, 1, marker)
    normal = {"command": normal_command, "actual_exit": normal_code, "stdout": normal_out,
              "stderr": normal_err, "error": normal_error, "classified_normal": normal_pass,
              "reasons": normal_reasons}

    signal_command = normal_command + ["--hold-open"]
    signaled = {"command": signal_command, "actual_exit": None, "stdout": "", "stderr": "",
                "error": None, "marker_observed_while_live": False, "signal_sent": False,
                "classified_normal": None, "reasons": []}
    process = None
    try:
        if os.name != "posix":
            signaled["error"] = "POSIX SIGTERM unavailable"
        else:
            process = subprocess.Popen(signal_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            deadline = time.monotonic() + 8
            pending = b""
            while time.monotonic() < deadline:
                readable, _, _ = select.select([process.stdout], [], [],
                                                min(0.1, max(0, deadline - time.monotonic())))
                if readable:
                    chunk = os.read(process.stdout.fileno(), 4096)
                    pending += chunk
                    if any(line.strip() == marker.encode() for line in pending.split(b"\n")[:-1]):
                        signaled["marker_observed_while_live"] = process.poll() is None
                        break
                    if not chunk:
                        break
                if process.poll() is not None:
                    break
            if signaled["marker_observed_while_live"]:
                process.send_signal(signal.SIGTERM)
                signaled["signal_sent"] = True
            else:
                signaled["error"] = "exact marker not observed while child live before 8s deadline"
            try:
                remainder, stderr = process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                signaled["error"] = "cleanup exceeded 3s; child killed"
                process.kill()
                remainder, stderr = process.communicate(timeout=3)
            signaled["stdout"] = (pending + remainder).decode(errors="replace")
            signaled["stderr"] = stderr.decode(errors="replace")
            signaled["actual_exit"] = process.returncode
            classified, reasons = classify(signaled["stdout"], signaled["stderr"],
                                           process.returncode, signaled["error"], 1, marker)
            signaled["classified_normal"] = classified
            signaled["reasons"] = reasons
    except (OSError, ValueError) as exc:
        signaled["error"] = f"signal probe failed: {exc}"
    finally:
        if process is not None and process.poll() is None:
            process.kill()
            try:
                process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                signaled["error"] = "forced cleanup exceeded 3s"

    verdict = (normal_pass and normal_err == "" and signaled["error"] is None
               and signaled["marker_observed_while_live"] and signaled["signal_sent"]
               and signaled["actual_exit"] == -signal.SIGTERM
               and signaled["classified_normal"] is False
               and f"process died on signal {signal.SIGTERM}" in signaled["reasons"]
               and signaled["stderr"] == "")
    result = {"verdict": "PASS" if verdict else "FAIL", "marker": marker,
              "normal": normal, "signaled": signaled, "bounded_claim":
              "One Godot 4.7.2 Node3D setup and direct-child normal exit versus POSIX SIGTERM; "
              "not a spontaneous crash, process-tree timeout, or rendered output."}
    (run_dir / "crash-exit-verdicts.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"{result['verdict']} crash-exit probe: {run_dir / 'crash-exit-verdicts.json'}", flush=True)
    return verdict


def probe_stream_attribution(godot, scratch, run_dir):
    marker = "STREAM_3D_STDOUT: spatial node ready"
    diagnostic = "STREAM_3D_STDERR"
    script = "res://stream_attribution3d.gd"
    results = []
    for name, flags in (("accept", []), ("reject", ["--emit-stderr"])):
        command = [godot, "--headless", "--path", str(scratch), "--script", script, "--", *flags]
        stdout, stderr, code, error = run_process(command, 8)
        classified, reasons = classify(stdout, stderr, code, error, 0, marker)
        results.append({"case": name, "command": command, "stdout": stdout, "stderr": stderr,
                        "actual_exit": code, "error": error, "classified": classified,
                        "reasons": reasons})
    accept, reject = results
    marker_once = all(r["stdout"].splitlines().count(marker) == 1 for r in results)
    verdict = (marker_once and accept["stdout"] == reject["stdout"]
               and all(r["actual_exit"] == 0 and r["error"] is None for r in results)
               and accept["stderr"] == "" and accept["classified"] is True
               and reject["stderr"].strip() == diagnostic and reject["classified"] is False
               and reject["reasons"] == [f"unexpected stderr line: {diagnostic}"])
    payload = {"verdict": "PASS" if verdict else "FAIL", "marker": marker,
               "diagnostic": diagnostic, "results": results, "bounded_claim":
               "One Godot 4.7.2 Node3D fixture, same exit/stdout, unexpected stderr line; "
               "not general logging policy or other-engine behavior."}
    (run_dir / "stream-attribution-verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{payload['verdict']} stream-attribution probe: "
          f"{run_dir / 'stream-attribution-verdicts.json'}", flush=True)
    return verdict


def probe_tree_timeout(godot, scratch, run_dir):
    marker = "TREE_TIMEOUT_3D: spatial node ready"
    script = "res://timeout_tree3d.gd"
    normal_command = [godot, "--headless", "--path", str(scratch), "--script", script, "--"]
    normal_out, normal_err, normal_code, normal_error = run_process(normal_command, 8)
    normal_ok, normal_reasons = classify(normal_out, normal_err, normal_code, normal_error, 0, marker)
    normal = {"command": normal_command, "actual_exit": normal_code, "stdout": normal_out,
              "stderr": normal_err, "error": normal_error, "classified": normal_ok,
              "reasons": normal_reasons}

    command = normal_command + ["--hold-open"]
    record = {"command": command, "actual_exit": None, "cleanup_exit": None,
              "stdout": "", "stderr": "", "error": None, "timed_out": False,
              "marker_observed": False, "witness": None, "witness_verified": False,
              "witness_gone": False, "witness_cleanup": None, "classified": None, "reasons": []}
    process = None
    witness_pid = None
    witness_start = None
    witness_path = scratch / "timeout-descendant.json"

    def proc_identity(pid):
        proc = Path(f"/proc/{pid}")
        try:
            cmdline = (proc / "cmdline").read_bytes().split(b"\0")
            stat = (proc / "stat").read_text()
            fields = stat[stat.rfind(")") + 2:].split()
            return {"cmdline": [c.decode(errors="replace") for c in cmdline if c],
                    "state": fields[0], "ppid": int(fields[1]), "pgid": int(fields[2]),
                    "starttime": int(fields[19])}
        except (FileNotFoundError, ProcessLookupError):
            return None

    def same_live_witness():
        found = proc_identity(witness_pid) if witness_pid is not None else None
        return (found is not None and found["state"] not in ("Z", "X")
                and found["starttime"] == witness_start
                and str(scratch / "timeout_descendant.py") in found["cmdline"]
                and str(witness_path) in found["cmdline"])

    try:
        if os.name != "posix" or not Path("/proc/self/stat").exists():
            record["error"] = "Linux /proc and POSIX signals required"
        else:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       start_new_session=True)
            try:
                raw_out, raw_err = process.communicate(timeout=3)
                record["actual_exit"] = process.returncode
            except subprocess.TimeoutExpired as exc:
                record["timed_out"] = True
                record["error"] = "TIMEOUT after 3 seconds"
                record["actual_exit"] = None
                raw_out = exc.stdout or b""
                raw_err = exc.stderr or b""
                record["marker_observed"] = marker.encode() in raw_out.splitlines()
                if witness_path.is_file():
                    witness = json.loads(witness_path.read_text())
                    record["witness"] = witness
                    witness_pid = int(witness["pid"])
                    found = proc_identity(witness_pid)
                    witness_start = found["starttime"] if found else None
                    record["witness_verified"] = bool(
                        found and found["state"] not in ("Z", "X")
                        and found["ppid"] == process.pid and found["pgid"] == witness_pid
                        and str(scratch / "timeout_descendant.py") in found["cmdline"]
                        and str(witness_path) in found["cmdline"])
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGKILL)
                if record["witness_verified"] and same_live_witness():
                    os.kill(witness_pid, signal.SIGTERM)
                    record["witness_cleanup"] = "SIGTERM to verified detached witness"
                    deadline = time.monotonic() + 3
                    while time.monotonic() < deadline and same_live_witness():
                        time.sleep(0.02)
                    if same_live_witness():
                        os.kill(witness_pid, signal.SIGKILL)
                        record["witness_cleanup"] = "SIGKILL after 3s grace"
                        deadline = time.monotonic() + 3
                        while time.monotonic() < deadline and same_live_witness():
                            time.sleep(0.02)
                record["witness_gone"] = record["witness_verified"] and not same_live_witness()
                try:
                    raw_out, raw_err = process.communicate(timeout=3)
                    record["cleanup_exit"] = process.returncode
                except subprocess.TimeoutExpired:
                    record["error"] += "; Godot cleanup exceeded 3 seconds"
                record["stdout"] = raw_out.decode(errors="replace")
                record["stderr"] = raw_err.decode(errors="replace")
            else:
                record["stdout"] = raw_out.decode(errors="replace")
                record["stderr"] = raw_err.decode(errors="replace")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        record["error"] = f"timeout probe failed: {exc}"
    finally:
        if process is not None and process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            try:
                process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                record["error"] = (record["error"] or "") + "; final Godot cleanup timed out"
        if record["witness_verified"] and same_live_witness():
            os.kill(witness_pid, signal.SIGKILL)
            record["witness_cleanup"] = "forced final SIGKILL to verified identity"
            record["witness_gone"] = not same_live_witness()

    record["marker_observed"] = record["stdout"].splitlines().count(marker) == 1
    classified, reasons = classify(record["stdout"], record["stderr"],
                                   record["actual_exit"], record["error"], 0, marker)
    record["classified"] = classified
    record["reasons"] = reasons
    verdict = (normal_ok and normal_err == "" and record["timed_out"]
               and record["actual_exit"] is None and record["cleanup_exit"] is not None
               and record["marker_observed"] and record["classified"] is False
               and record["witness_verified"] and record["witness_gone"]
               and record["witness_cleanup"] == "SIGTERM to verified detached witness")
    payload = {"verdict": "PASS" if verdict else "FAIL", "normal": normal,
               "timeout": record, "bounded_claim": "One identified detached Godot-spawned "
               "witness terminated after direct-child timeout; not arbitrary process-tree cleanup."}
    (run_dir / "tree-timeout-verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{payload['verdict']} tree-timeout probe: {run_dir / 'tree-timeout-verdicts.json'}", flush=True)
    return verdict


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--godot", default="/usr/bin/godot" if Path("/usr/bin/godot").exists() else "godot")
    parser.add_argument("--runs", type=Path, default=HERE.parent / "live" / "runs")
    parser.add_argument("--only", default="", help="comma-separated case names to run")
    parser.add_argument("--probe-failing", action="store_true",
                        help="also mutate one authored constant in a scratch copy and prove detection")
    parser.add_argument("--probe-crash-exit", action="store_true",
                        help="compare a normal Godot exit to a SIGTERM-terminated live Godot child")
    parser.add_argument("--probe-stream-attribution", action="store_true",
                        help="compare identical stdout/exit with and without unexpected stderr")
    parser.add_argument("--probe-tree-timeout", action="store_true",
                        help="time out Godot and explicitly clean one identified detached witness")
    args = parser.parse_args()

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    run_dir = args.runs / stamp
    scratch = run_dir / "scratch"
    scratch.mkdir(parents=True)
    digests_before = seed_digests()
    for item in HERE.iterdir():
        if item.name in ("run_battery.py", "__pycache__", "three") or item.name.startswith("."):
            continue
        if item.is_dir():
            shutil.copytree(item, scratch / item.name,
                            ignore=shutil.ignore_patterns("__pycache__"))
        else:
            shutil.copy2(item, scratch / item.name)

    selected = CASES
    if args.only:
        wanted = {name.strip() for name in args.only.split(",") if name.strip()}
        selected = [case for case in CASES if case[0] in wanted]
        unknown = wanted - {case[0] for case in CASES}
        if unknown or not selected:
            print(f"FAIL unknown case names: {sorted(unknown)}")
            return 1

    version_out, version_err, version_code, version_error = run_process([args.godot, "--version"], 20)
    godot_version = version_out.strip().splitlines()[0] if version_out.strip() else ""
    results = []

    def execute(name, script, flags, expected_exit, marker, project):
        command = [args.godot, "--headless", "--path", str(project),
                   "--script", "res://" + script, "--", *flags]
        started = datetime.now(timezone.utc)
        stdout, stderr, code, error = run_process(command, CASE_TIMEOUT_SECONDS)
        elapsed = (datetime.now(timezone.utc) - started).total_seconds()
        passed, reasons = classify(stdout, stderr, code, error, expected_exit, marker)
        record = {"case": name, "script": script, "flags": flags, "command": command,
                  "expected_exit": expected_exit, "actual_exit": code, "error": error,
                  "kind": "negative_control" if expected_exit == 2 else "ordinary",
                  "marker": marker, "verdict": "PASS" if passed else "FAIL",
                  "reasons": reasons, "elapsed_seconds": round(elapsed, 3),
                  "stdout": stdout.strip().splitlines(), "stderr": stderr.strip().splitlines()}
        results.append(record)
        print(f"{record['verdict']} {name}: exit={code} expected={expected_exit}"
              + (f" reasons={reasons}" if reasons else ""), flush=True)
        return record

    for case in selected:
        execute(*case, scratch)

    crash_probe_ok = True
    if args.probe_crash_exit:
        crash_probe_ok = probe_crash_exit(args.godot, scratch, run_dir)
    stream_probe_ok = True
    if args.probe_stream_attribution:
        stream_probe_ok = probe_stream_attribution(args.godot, scratch, run_dir)
    tree_probe_ok = True
    if args.probe_tree_timeout:
        tree_probe_ok = probe_tree_timeout(args.godot, scratch, run_dir)

    probe = None
    if args.probe_failing:
        mutation_scratch = run_dir / "mutation-scratch"
        shutil.copytree(scratch, mutation_scratch, ignore=shutil.ignore_patterns(".godot"))
        target = mutation_scratch / MUTATION["script"]
        text = target.read_text()
        if MUTATION["old"] not in text:
            print(f"FAIL probe: mutation anchor absent from {MUTATION['script']}")
            return 1
        target.write_text(text.replace(MUTATION["old"], MUTATION["new"], 1))
        # The mutant is judged with the seeded case's own expectation: the same
        # exit code and marker that the unmutated fixture satisfies. Detection
        # means that classifier now rejects it, for the authored reason.
        seeded = next(case for case in CASES if case[0] == MUTATION["case"])
        mutated = execute("mutant_" + MUTATION["case"], seeded[1], seeded[2],
                          seeded[3], seeded[4], mutation_scratch)
        diagnostic_lines = [line.strip() for line in mutated["stderr"]
                            if line.strip() == MUTATION["expected_diagnostic"]]
        detected = (mutated["verdict"] == "FAIL"
                    and mutated["actual_exit"] == MUTATION["expected_exit"]
                    and not any(line.strip().startswith(MUTATION["forbidden_stdout"])
                                for line in mutated["stdout"])
                    and len(diagnostic_lines) == 1
                    and not any("SCRIPT ERROR:" in line or "Parse Error:" in line
                                for line in mutated["stdout"] + mutated["stderr"]))
        seeds_unchanged = seed_digests() == digests_before
        probe = {"mutation": MUTATION, "detected": detected, "seeds_unchanged": seeds_unchanged,
                 "seeded_expectation": {"case": seeded[0], "script": seeded[1],
                                        "expected_exit": seeded[3], "marker": seeded[4]},
                 "record": mutated,
                 "seed_digests_before": digests_before,
                 "seed_digests_after": seed_digests(),
                 "mutation_scratch": str(mutation_scratch),
                 "expected_diagnostic_lines": diagnostic_lines,
                 "verdict": "PASS" if detected and seeds_unchanged else "FAIL",
                 "bounded_claim": ("one authored constant (wall box depth 4.0 -> 6.0) mutated in a "
                                   "scratch copy of body3d_slide.gd; proves the contact-plane "
                                   "assertion measures engine geometry instead of restating it. "
                                   "Not a general mutation-coverage claim.")}
        # The probe case itself must not be counted as a seeded battery case.
        results.pop()
        (run_dir / "mutation-verdicts.json").write_text(json.dumps(probe, indent=2) + "\n")
        print(f"{probe['verdict']} adversarial mutation: detected={detected} "
              f"seeds_unchanged={seeds_unchanged} -> {run_dir / 'mutation-verdicts.json'}", flush=True)

    seeds_unchanged = seed_digests() == digests_before
    if not seeds_unchanged:
        print("FAIL seeds were modified during the run; seeds must stay read-only")
    ordinary = sum(1 for r in results if r["kind"] == "ordinary")
    negative = sum(1 for r in results if r["kind"] == "negative_control")
    passed = sum(1 for r in results if r["verdict"] == "PASS")
    failed = len(results) - passed

    print()
    print(f"{'VERDICT':8} {'CASE':34} {'SCRIPT':26} {'FLAGS':18} {'EXIT':9} KIND")
    for record in results:
        flags = ",".join(record["flags"]) or "-"
        exit_text = f"{record['actual_exit']}/{record['expected_exit']}"
        kind = "negative" if record["kind"] == "negative_control" else "ordinary"
        print(f"{record['verdict']:8} {record['case']:34} {record['script']:26} "
              f"{flags:18} {exit_text:9} {kind}")
    if probe is not None:
        print(f"{probe['verdict']:8} {'mutant_' + MUTATION['case']:34} {MUTATION['script']:26} "
              f"{'(scratch mutation)':18} {'-/1':9} probe")
    print(f"totals: cases={len(results)} pass={passed} fail={failed} "
          f"ordinary={ordinary} negative_controls={negative} "
          f"probes={(1 if probe is not None else 0) + (1 if args.probe_crash_exit else 0) + (1 if args.probe_stream_attribution else 0) + (1 if args.probe_tree_timeout else 0)}")

    verdict = ("PASS" if failed == 0 and seeds_unchanged and crash_probe_ok
               and stream_probe_ok and tree_probe_ok
               and (probe is None or probe["verdict"] == "PASS") else "FAIL")
    payload = {"godot": args.godot, "godot_version": godot_version,
               "godot_version_exit": version_code, "godot_version_error": version_error,
               "started_utc": stamp, "seed": str(HERE), "scratch": str(scratch),
               "case_timeout_seconds": CASE_TIMEOUT_SECONDS, "only": args.only or None,
               "probe_failing": args.probe_failing, "probe_crash_exit": args.probe_crash_exit,
               "crash_probe_ok": crash_probe_ok, "probe_stream_attribution": args.probe_stream_attribution,
               "stream_probe_ok": stream_probe_ok, "probe_tree_timeout": args.probe_tree_timeout,
               "tree_probe_ok": tree_probe_ok, "seeds_unchanged": seeds_unchanged,
               "seed_digests": digests_before, "results": results, "probe": probe,
               "totals": {"cases": len(results), "pass": passed, "fail": failed,
                          "ordinary": ordinary, "negative_controls": negative},
               "verdict": verdict}
    (run_dir / "verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{verdict} battery: {run_dir / 'verdicts.json'}")
    return 0 if verdict == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
