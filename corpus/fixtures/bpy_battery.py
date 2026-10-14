"""r79 bpy battery: run bpy_sync_probe.py under `blender -b -P` and pin the
measured two-layer lattice (Blender 5.2.1 LTS headless, this host).

Sibling runner to run_battery.py -- the Godot battery stays untouched (prior
rows byte-stable); this runner owns the bpy runtime surface only.

Case model differs from the godot CASES tuples: one blender invocation emits
all ARM lines; each CASES row asserts a (arm, point, layer) line carries the
pinned key=value assignments. A case FAILs if the line is missing or any
pinned key disagrees. `non_signal=True` rows pin the measured
evaluated-visibility quirk for determinism -- they are observations, never
staleness witnesses (see fixture docstring).

r80 adds the evalcat cases: per-mutation-class EDGE rows pinning the
frontier eval-event catalogue, incl. the closed-set `violations=0` row.
"""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROBE = HERE / "bpy_sync_probe.py"
TIMEOUT_S = 60

# (name, arm, point, layer, {key: pinned_value}, non_signal)
CASES = [
    # transform: written RNA fresh at w0; derived RNA (mw_t) STALE at w0
    ("transform_w0_rna_loc_fresh",    "transform", "w0", "RNA", {"loc": "(5.000,0.000,0.000)"}, False),
    ("transform_w0_rna_mwt_stale",    "transform", "w0", "RNA", {"mw_t": "(0.000,0.000,0.000)"}, False),
    # held depsgraph handle: stale until an eval event; fresh get evaluates
    ("transform_w0held_stale",        "transform", "w0-held", "DEG", {"loc": "(0.000,0.000,0.000)"}, False),
    ("transform_w0fresh_fresh",       "transform", "w0-fresh", "DEG", {"loc": "(5.000,0.000,0.000)", "mw_t": "(5.000,0.000,0.000)"}, False),
    ("transform_wUheld_flushed",      "transform", "wU-held", "DEG", {"loc": "(5.000,0.000,0.000)"}, False),
    ("transform_wFheld_flushed",      "transform", "wF-held", "DEG", {"loc": "(5.000,0.000,0.000)"}, False),
    # dg.update() flushes the derived RNA edge too
    ("transform_wD_rna_mwt_fresh",    "transform", "wD", "RNA", {"mw_t": "(9.000,0.000,0.000)"}, False),
    # hide: written flag visible on RNA; evaluated flags are the non-signal
    ("hide_w0_rna_flag",              "hide", "w0-fresh", "RNA", {"hide_get": "True", "vis_get": "False"}, False),
    ("hide_w0_deg_flag_nonsignal",    "hide", "w0-fresh", "DEG", {"hide_get": "False", "vis_get": "False"}, True),
    ("hide_wU_deg_flag_nonsignal",    "hide", "wU-fresh", "DEG", {"hide_get": "False", "vis_get": "False"}, True),
    # modifier: held handle misses the eval; fresh get runs SUBSURF (49 vs 16)
    ("modifier_w0held_stale",         "modifier", "w0-held", "DEG", {"eval_verts": "16", "base_verts": "16"}, False),
    ("modifier_w0fresh_evaluated",    "modifier", "w0-fresh", "DEG", {"eval_verts": "49", "base_verts": "16"}, False),
    ("modifier_wUheld_flushed",       "modifier", "wU-held", "DEG", {"eval_verts": "49"}, False),
    # collink: RNA membership immediate (in_a/in_b/users)
    ("collink_w0_rna_membership",     "collink", "w0-fresh", "RNA", {"in_a": "False", "in_b": "True", "users": "b"}, False),
    ("collink_relink_w0_rna",         "collink", "relink-w0", "RNA", {"in_a": "True"}, False),
    # membership: object_instances is the staleness witness
    ("membership_base",               "membership", "base", "DEG", {"names": "keep|mover"}, False),
    ("membership_w0held_stale",       "membership", "w0-held", "DEG", {"names": "keep|mover"}, False),
    ("membership_w0fresh_fresh",      "membership", "w0-fresh", "DEG", {"names": "keep"}, False),
    ("membership_w0_rna_users",       "membership", "w0", "RNA", {"users": "orphan"}, False),
    ("membership_relink_w0held",      "membership", "relink-w0-held", "DEG", {"names": "keep"}, False),
    ("membership_relink_w0fresh",     "membership", "relink-w0-fresh", "DEG", {"names": "keep|mover"}, False),
    ("membership_relink_wUheld",      "membership", "relink-wU-held", "DEG", {"names": "keep|mover"}, False),
    # draincheck: no implicit eval between statements (Godot-tick analogue ABSENT)
    ("draincheck_no_implicit_1",      "draincheck", "w0-held", "DEG", {"loc": "(0.000,0.000,0.000)"}, False),
    ("draincheck_no_implicit_2",      "draincheck", "w0-held2", "DEG", {"loc": "(0.000,0.000,0.000)"}, False),
    ("draincheck_no_implicit_3",      "draincheck", "w0-held3", "DEG", {"loc": "(0.000,0.000,0.000)"}, False),
    # shared graph: one object, evaluated in place; a fresh get flushes held handles
    ("shared_same_graph",             "shared", "same-obj", "DEG", {"is_same": "True"}, False),
    ("shared_held_stale_before",      "shared", "w0-held-a", "DEG", {"loc": "(0.000,0.000,0.000)"}, False),
    ("shared_fresh_evaluated",        "shared", "w0-fresh", "DEG", {"loc": "(2.000,0.000,0.000)"}, False),
    ("shared_held_flushed_by_fresh",  "shared", "w0-held-b", "DEG", {"loc": "(2.000,0.000,0.000)"}, False),
    # freshhandle: second consecutive fresh get consistent; frame_set evaluates
    ("freshhandle_w0_fresh",          "freshhandle", "w0-fresh", "DEG", {"loc": "(3.000,0.000,0.000)"}, False),
    ("freshhandle_w0_fresh2",         "freshhandle", "w0-fresh2", "DEG", {"loc": "(3.000,0.000,0.000)"}, False),
    ("freshhandle_postF_rna",         "freshhandle", "postF", "RNA", {"mw_t": "(7.000,0.000,0.000)"}, False),
    ("freshhandle_postF_deg",         "freshhandle", "postF", "DEG", {"loc": "(7.000,0.000,0.000)"}, False),
    # vis quirk (observed non-signal): evaluated flags stay False on a
    # relinked, instantiated, RNA-visible object
    ("vis_hidden_rna",                "vis", "hidden", "RNA", {"vis": "False", "hide": "True"}, False),
    ("vis_hidden_deg_nonsignal",      "vis", "hidden-ev", "DEG", {"vis": "False", "hide": "False"}, True),
    ("vis_relinked_rna",              "vis", "relinked", "RNA", {"vis": "True"}, False),
    ("vis_relinked_deg_nonsignal",    "vis", "relinked", "DEG", {"vis": "False", "hide": "False", "in_inst": "True"}, True),
    # ---------------- r80 evalcat: per-mutation-class edge rows ----------
    # Claim: the eval-event set {get, vl.update, frame_set, dg.update,
    # bpy.ops} is enumerable and CLOSED. EDGE rows carry held= state,
    # invoked= event (or none for bare mutations), per-handler deltas
    # (dpre/dpost/dfcp/dfc/dund) and the classified edge= label. Any
    # bare (invoked=none) row that flushes held or fires a watched
    # handler is auto-emitted edge=FALSIFIED -> the pins below FAIL.
    # Frontier-measured edge table (fa-bpy-evalcat.md) pinned verbatim;
    # op eval counts pinned as dup_fired (>=1), never exact (x1/x2 varies).
    # bare RNA write: no event, held stale -> edge=1
    ("evalcat_rna_write_edge1",       "evalcat", "rna_write", "EDGE",
     {"held": "stale", "invoked": "none", "dpre": "0", "dpost": "0",
      "dfcp": "0", "dfc": "0", "edge": "1",
      "held_loc": "(0.000,0.000,0.000)"}, False),
    # event rows: tagged path fires dup, frame path fires fc only
    ("evalcat_ev_get_flush",          "evalcat", "ev_get", "EDGE",
     {"held": "flushed", "invoked": "evaluated_depsgraph_get",
      "dup_fired": "True", "fc_fired": "False", "edge": "0",
      "held_loc": "(1.000,0.000,0.000)", "same_obj": "True"}, False),
    ("evalcat_ev_getclean_cond",      "evalcat", "ev_getclean", "EDGE",
     {"held": "na", "dpre": "0", "dpost": "0", "dfcp": "0", "dfc": "0",
      "edge": "cond"}, False),
    ("evalcat_ev_vlupdate_flush",     "evalcat", "ev_vlupdate", "EDGE",
     {"held": "flushed", "invoked": "view_layer.update",
      "dup_fired": "True", "fc_fired": "False", "edge": "0",
      "held_loc": "(2.000,0.000,0.000)"}, False),
    ("evalcat_ev_vlclean_cond",       "evalcat", "ev_vlclean", "EDGE",
     {"held": "na", "dpost": "0", "dfc": "0", "edge": "cond"}, False),
    ("evalcat_ev_frameset_flush",     "evalcat", "ev_frameset", "EDGE",
     {"held": "flushed", "invoked": "frame_set", "dup_fired": "False",
      "fc_fired": "True", "dpost": "0", "edge": "0",
      "held_loc": "(3.000,0.000,0.000)", "frame": "2"}, False),
    # frame_set to the SAME frame still evals (closes r79 unknown (c))
    ("evalcat_ev_framesame_flush",    "evalcat", "ev_framesame", "EDGE",
     {"held": "flushed", "invoked": "frame_set", "dup_fired": "False",
      "fc_fired": "True", "dpost": "0", "edge": "0",
      "held_loc": "(4.000,0.000,0.000)", "frame": "2"}, False),
    ("evalcat_ev_dgupdate_flush",     "evalcat", "ev_dgupdate", "EDGE",
     {"held": "flushed", "invoked": "dg.update", "dup_fired": "True",
      "fc_fired": "False", "edge": "0",
      "held_loc": "(5.000,0.000,0.000)"}, False),
    # driver writes: edge=1, one tagged eval binds + RNA copyback
    ("evalcat_driver_edge1",          "evalcat", "driver", "EDGE",
     {"held": "stale", "invoked": "none", "dpost": "0", "edge": "1",
      "held_loc": "(0.000,0.000,0.000)", "fresh": "(7.000,0.000,0.000)",
      "rna_x": "7.000"}, False),
    ("evalcat_driver_wU_copyback",    "evalcat", "driver_wU", "DEG",
     {"held": "(7.000,0.000,0.000)", "rna_x": "7.000"}, False),
    ("evalcat_driver_expr_edge1",     "evalcat", "driver_expr", "EDGE",
     {"held": "stale", "invoked": "none", "dpost": "0", "edge": "1",
      "held_loc": "(7.000,0.000,0.000)", "fresh": "(9.000,0.000,0.000)"}, False),
    # keyframe_insert: inert through a tagged eval, binds only at frame_set
    ("evalcat_keyframe_edge_frame",   "evalcat", "keyframe", "EDGE",
     {"held": "stale", "invoked": "none", "dpost": "0", "edge": "frame",
      "ret": "True", "tagged_fresh": "(0.000,0.000,0.000)",
      "f1": "(0.000,4.000,0.000)", "rna_y": "4.000"}, False),
    ("evalcat_keyframe_wU_inert",     "evalcat", "keyframe_wU", "DEG",
     {"upd_dup": "1", "held": "(0.000,0.000,0.000)",
      "fresh": "(0.000,0.000,0.000)"}, False),
    # explicit layered action build DOES tag -> edge=1 (differentiator)
    ("evalcat_key_explicit_edge1",    "evalcat", "key_explicit", "EDGE",
     {"held": "stale", "invoked": "none", "edge": "1", "build": "layered",
      "held_loc": "(0.000,0.000,0.000)", "fresh": "(0.000,0.000,8.000)"}, False),
    # constraint RNA add: edge=1
    ("evalcat_con_rna_edge1",         "evalcat", "con_rna", "EDGE",
     {"held": "stale", "invoked": "none", "dpost": "0", "edge": "1",
      "held_mw": "(0.000,0.000,0.000)", "fresh": "(3.000,0.000,0.000)",
      "rna_n": "1"}, False),
    ("evalcat_con_rna_wU_copyback",   "evalcat", "con_rna_wU", "DEG",
     {"held_mw": "(3.000,0.000,0.000)", "rna_mw": "(3.000,0.000,0.000)"}, False),
    # bpy.ops mutations: every op is itself an eval event -> edge=0
    ("evalcat_op_apply_edge0",        "evalcat", "op_apply", "EDGE",
     {"held": "flushed", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_mesh": "verts3:xmax6.000",
      "held_loc": "(0.000,0.000,0.000)", "rna_loc": "(0.000,0.000,0.000)"}, False),
    ("evalcat_op_add_edge0",          "evalcat", "op_add", "EDGE",
     {"held": "flushed", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_names": "Cube|o",
      "rna_n": "2"}, False),
    ("evalcat_op_modapply_edge0",     "evalcat", "op_modapply", "EDGE",
     {"held": "flushed", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_mesh": "verts49:xmax1.000",
      "rna_verts": "49", "rna_mods": "0"}, False),
    ("evalcat_op_mode_edit_edge0",    "evalcat", "op_mode_edit", "EDGE",
     {"held": "flushed", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_loc": "(5.000,0.000,0.000)"}, False),
    ("evalcat_op_mode_object_edge0",  "evalcat", "op_mode_object", "EDGE",
     {"held": "na", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_loc": "(5.000,0.000,0.000)"}, False),
    ("evalcat_op_locclear_edge0",     "evalcat", "op_locclear", "EDGE",
     {"held": "flushed", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "held_loc": "(0.000,0.000,0.000)",
      "rna_loc": "(0.000,0.000,0.000)"}, False),
    # constraint_add: constraint inert w/o target -> held=na, dup is the eval witness
    ("evalcat_op_conadd_edge0",       "evalcat", "op_conadd", "EDGE",
     {"held": "na", "invoked": "bpy.ops", "dup_fired": "True",
      "edge": "0", "ret": "FINISHED", "rna_n": "1"}, False),
    # RNA write after an op still needs its own eval -> edge=1
    ("evalcat_conadd_target_edge1",   "evalcat", "conadd_target", "EDGE",
     {"held": "stale", "invoked": "none", "dpost": "0", "edge": "1",
      "held_mw": "(0.000,0.000,0.000)", "fresh": "(3.000,0.000,0.000)"}, False),
    # wall-time axis: sleeps + context re-touch never flush -> edge=absent
    ("evalcat_walltime_absent",       "evalcat", "walltime", "EDGE",
     {"held": "stale", "invoked": "none", "dpre": "0", "dpost": "0",
      "dfcp": "0", "dfc": "0", "edge": "absent",
      "held_loc": "(0.000,0.000,0.000)"}, False),
    ("evalcat_walltime_fresh",        "evalcat", "walltime_fresh", "DEG",
     {"loc": "(6.000,0.000,0.000)"}, False),
    # closure: zero falsified rows across every probed mutation class
    ("evalcat_closed_set",            "evalcat", "closed", "EDGE",
     {"violations": "0"}, False),
]

ARM_LINE = re.compile(r"^ARM (\S+) \| (\S+) \| (\S+) \| (.*)$")


def run_process(command, timeout_seconds):
    try:
        proc = subprocess.run(command, capture_output=True, text=True,
                              timeout=timeout_seconds)
        return proc.stdout, proc.stderr, proc.returncode, None
    except subprocess.TimeoutExpired as exc:
        def text(v):
            return v.decode(errors="replace") if isinstance(v, bytes) else (v or "")
        return (text(exc.stdout), text(exc.stderr), None,
                f"TIMEOUT after {timeout_seconds} seconds")
    except OSError as exc:
        return "", str(exc), None, f"launch error: {exc}"


def parse_arms(stdout):
    arms = {}
    for line in stdout.splitlines():
        m = ARM_LINE.match(line.strip())
        if not m:
            continue
        arm, point, layer, body = m.groups()
        kv = dict(p.split("=", 1) for p in body.split() if "=" in p)
        arms[(arm, point, layer)] = kv
    return arms


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--blender",
                        default="/usr/bin/blender" if Path("/usr/bin/blender").exists() else "blender")
    parser.add_argument("--runs", type=Path, default=HERE.parent / "live" / "runs")
    args = parser.parse_args()

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    run_dir = args.runs / ("bpy-" + stamp)
    run_dir.mkdir(parents=True)

    version_out, _, version_code, version_err = run_process(
        [args.blender, "--version"], 20)
    blender_version = version_out.strip().splitlines()[0] if version_out.strip() else ""

    started = datetime.now(timezone.utc)
    stdout, stderr, code, error = run_process(
        [args.blender, "-b", "-P", str(PROBE)], TIMEOUT_S)
    elapsed = (datetime.now(timezone.utc) - started).total_seconds()
    (run_dir / "probe.stdout.txt").write_text(stdout)
    (run_dir / "probe.stderr.txt").write_text(stderr)

    arms = parse_arms(stdout)
    launch_ok = error is None and code == 0
    done_marker = "PROBE_DONE" in [l.strip() for l in stdout.splitlines()]
    fatals = [l for l in stdout.splitlines() if "| FATAL |" in l]

    results = []
    for name, arm, point, layer, pinned, non_signal in CASES:
        got = arms.get((arm, point, layer))
        reasons = []
        if got is None:
            reasons.append(f"missing ARM line for ({arm} | {point} | {layer})")
        else:
            for k, want in pinned.items():
                if got.get(k) != want:
                    reasons.append(f"{k}={got.get(k)!r} != pinned {want!r}")
        results.append({"case": name, "arm": arm, "point": point, "layer": layer,
                        "pinned": pinned, "observed": got,
                        "non_signal": non_signal,
                        "verdict": "PASS" if not reasons else "FAIL",
                        "reasons": reasons})

    passed = sum(1 for r in results if r["verdict"] == "PASS")
    failed = len(results) - passed
    signal_failed = sum(1 for r in results
                        if r["verdict"] == "FAIL" and not r["non_signal"])
    quirk_drift = sum(1 for r in results
                      if r["verdict"] == "FAIL" and r["non_signal"])
    for r in results:
        flag = " (non-signal)" if r["non_signal"] else ""
        print(f"{r['verdict']:8} {r['case']:36} "
              f"{r['arm']}|{r['point']}|{r['layer']}{flag}")

    print(f"totals: cases={len(results)} pass={passed} fail={failed} "
          f"(signal_fail={signal_failed} quirk_drift={quirk_drift}) "
          f"launch_ok={launch_ok} done_marker={done_marker} "
          f"fatals={len(fatals)} exit={code}")

    verdict = "PASS" if (signal_failed == 0 and launch_ok and done_marker
                         and not fatals) else "FAIL"
    payload = {"blender": args.blender, "blender_version": blender_version,
               "blender_version_exit": version_code,
               "blender_version_error": version_err,
               "probe": str(PROBE), "probe_exit": code, "probe_error": error,
               "probe_elapsed_s": elapsed, "started_utc": stamp,
               "done_marker": done_marker, "fatal_arms": fatals,
               "n_arm_lines": len(arms), "results": results,
               "totals": {"cases": len(results), "pass": passed, "fail": failed,
                          "signal_fail": signal_failed,
                          "quirk_drift": quirk_drift},
               "verdict": verdict}
    (run_dir / "verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{verdict} battery: {run_dir / 'verdicts.json'}")
    return 0 if verdict == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
