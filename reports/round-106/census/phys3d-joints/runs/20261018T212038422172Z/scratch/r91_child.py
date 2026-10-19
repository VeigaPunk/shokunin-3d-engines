"""r91 child probe — bpy rigid-body world + point-cache lattice (Blender
5.2.1 LTS headless, this host), spawned per case by bpy_rbw3d.gd:

    blender -b -P r91_child.py -- <case> [workdir]

Emits `M0 case=.. engine=..` / `M <case> <point> k=v ..` / `M DONE case=..`
lines on stdout (flush=True — a crash must not swallow a breadcrumb).
`workdir` (default /tmp) receives the files a case writes (.blend, PNGs);
only basenames/booleans are emitted, never a scratch path or a PNG/.blend
sha — those drift.

Self-contained port of the r91-scout arm set (corpus/live/r91-scout/probes/);
the canonical scene is identical: factory-empty scene, size-1 cube `ball`
ACTIVE at (0,0,5), 20x20 plane `floor` PASSIVE, rigidbody_world_add,
scene frames 1..60, RBW defaults (substeps 10, iters 10, split False,
time_scale 1.0), fps 24. Free-run reference h=3302e3c1de9c5dd0.
"""

import hashlib
import os
import sys

import bpy

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else ["free"]
CASE = argv[0]
WORKDIR = argv[1] if len(argv) > 1 else "/tmp"


def emit(case, point, **kv):
    body = " ".join("{}={}".format(k, v) for k, v in kv.items())
    print("M {} {} {}".format(case, point, body), flush=True)


def build():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, 5.0))
    ball = bpy.context.active_object
    ball.name = "ball"
    bpy.ops.mesh.primitive_plane_add(size=20.0, location=(0.0, 0.0, 0.0))
    floor = bpy.context.active_object
    floor.name = "floor"
    bpy.ops.rigidbody.world_add()
    bpy.context.view_layer.objects.active = ball
    bpy.ops.rigidbody.object_add()
    ball.rigid_body.type = "ACTIVE"
    bpy.context.view_layer.objects.active = floor
    bpy.ops.rigidbody.object_add()
    floor.rigid_body.type = "PASSIVE"
    sc.frame_start = 1
    sc.frame_end = 60
    return sc, ball, floor


def loc(sc, ball):
    t = ball.evaluated_get(bpy.context.evaluated_depsgraph_get()).matrix_world.translation
    return (round(t.x, 6), round(t.y, 6), round(t.z, 6))


def row(sc, ball, f, subframe=0.0):
    sc.frame_set(f, subframe=subframe)
    return (f,) + loc(sc, ball)


def sweep(sc, ball, fs):
    return [row(sc, ball, f) for f in fs]


def thash(traj):
    return hashlib.sha256(repr(traj).encode()).hexdigest()[:16]


def fmt(t):
    return "({:.6f},{:.6f},{:.6f})".format(t[0], t[1], t[2])


def traj_kv(traj):
    kv = {"h": thash(traj), "n": len(traj)}
    for f in (1, 10, 20, 30, 40):
        if f <= len(traj):
            kv["f{}".format(f)] = fmt(traj[f - 1][1:])
    kv["last"] = fmt(traj[-1][1:])
    return kv


def done():
    print("M DONE case={}".format(CASE), flush=True)


print("M0 case={} engine=blender-{}".format(
    CASE, bpy.app.version_string.split()[0]), flush=True)

if CASE == "free":
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    A = sweep(sc, ball, range(1, 41))
    emit(CASE, "sweep1", **traj_kv(A))
    emit(CASE, "cache_after1", info=pc.info, baked=pc.is_baked,
         outdated=pc.is_outdated)
    B = sweep(sc, ball, range(1, 41))
    emit(CASE, "sweep2", eq1=(A == B), **traj_kv(B))
    C = sweep(sc, ball, range(41, 61))
    D = sweep(sc, ball, range(1, 41))
    emit(CASE, "sweep3_after_excursion", eq1=(A == D), **traj_kv(D))
    emit(CASE, "fwd41_60", f45=fmt(C[4][1:]), f60=fmt(C[19][1:]))
    emit(CASE, "cache_after3", info=pc.info, baked=pc.is_baked,
         outdated=pc.is_outdated)
    done()

elif CASE == "bequiv":
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    emit(CASE, "ranges_before", pc_fs=pc.frame_start, pc_fe=pc.frame_end,
         scene_fs=sc.frame_start, scene_fe=sc.frame_end,
         disk=pc.use_disk_cache)
    A = sweep(sc, ball, range(1, 41))
    emit(CASE, "free_run", **traj_kv(A))
    r1 = bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "bake_all", ret=str(r1), baked=pc.is_baked,
         outdated=pc.is_outdated, info=pc.info, pc_fe=pc.frame_end)
    B = sweep(sc, ball, range(1, 41))
    emit(CASE, "baked_run", eq_free=(A == B), **traj_kv(B))
    bpy.ops.ptcache.free_bake_all()
    pc.frame_end = 20
    emit(CASE, "narrow_range", pc_fs=pc.frame_start, pc_fe=pc.frame_end,
         info=pc.info, baked=pc.is_baked)
    r2 = bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "bake_narrow", ret=str(r2), info=pc.info, baked=pc.is_baked)
    E = sweep(sc, ball, range(1, 21))
    emit(CASE, "narrow_readback", n=len(E), eq_free20=(A[:20] == E),
         f20=fmt(E[19][1:]))
    done()

elif CASE in ("bake20", "bake5_30", "scene20b", "presweep20"):
    # one bake per case: the parent's `b=` field counts the `bake: frame`
    # flood lines and is the per-case bake-range witness.
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    if CASE == "bake20":
        pc.frame_end = 20
    elif CASE == "bake5_30":
        pc.frame_start = 5
        pc.frame_end = 30
    elif CASE == "scene20b":
        sc.frame_end = 20
    elif CASE == "presweep20":
        sweep(sc, ball, range(1, 41))
        pc.frame_end = 20
        emit(CASE, "pre", info=pc.info, pc_fe=pc.frame_end)
    emit(CASE, "before", pc_fs=pc.frame_start, pc_fe=pc.frame_end,
         scene_fs=sc.frame_start, scene_fe=sc.frame_end, info=pc.info)
    bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "after", baked=pc.is_baked, info=pc.info,
         outdated=pc.is_outdated)
    A = sweep(sc, ball, range(1, 41))
    emit(CASE, "read", f20=fmt(A[19][1:]), f40=fmt(A[39][1:]),
         h=thash(A))
    done()

elif CASE in ("end20", "start20", "scene20w"):
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    if CASE == "end20":
        pc.frame_end = 20
    elif CASE == "start20":
        pc.frame_start = 20
    elif CASE == "scene20w":
        sc.frame_end = 20
    emit(CASE, "setup", pc_fs=pc.frame_start, pc_fe=pc.frame_end,
         scene_fs=sc.frame_start, scene_fe=sc.frame_end)
    A = sweep(sc, ball, range(1, 21))
    emit(CASE, "head20", f20=fmt(A[-1][1:]))
    B = sweep(sc, ball, range(21, 41))
    emit(CASE, "tail", f21=fmt(B[0][1:]), f25=fmt(B[4][1:]),
         f30=fmt(B[9][1:]), f40=fmt(B[19][1:]),
         frozen=all(r[1:] == B[0][1:] for r in B), h=thash(B))
    done()

elif CASE == "order":
    sc, ball, floor = build()
    sc.frame_set(40)
    emit(CASE, "jump40", loc=fmt(loc(sc, ball)), fcur=sc.frame_current)
    S = sweep(sc, ball, range(1, 41))
    emit(CASE, "jump_then_seq40", **traj_kv(S))
    B = sweep(sc, ball, [1, 20, 40, 60, 20, 1])
    emit(CASE, "backward", back1=fmt(B[0][1:]), back20=fmt(B[1][1:]),
         back40=fmt(B[2][1:]), fwd60=fmt(B[3][1:]), re20=fmt(B[4][1:]),
         re1=fmt(B[5][1:]))
    sc.frame_set(40)
    sub = row(sc, ball, 40, subframe=0.5)
    emit(CASE, "subframe", f40=fmt(B[2][1:]), f40_5=fmt(sub[1:]))
    nxt = row(sc, ball, 41)
    emit(CASE, "subframe_next", f41=fmt(nxt[1:]))
    sc.frame_set(0)
    emit(CASE, "frame0", loc=fmt(loc(sc, ball)), fcur=sc.frame_current)
    done()

elif CASE == "bjump":
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    pc.frame_end = 40
    bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "baked", baked=pc.is_baked, info=pc.info)
    sc.frame_set(40)
    emit(CASE, "jump40", loc=fmt(loc(sc, ball)))
    sc.frame_set(60)
    emit(CASE, "jump60_past_cache", loc=fmt(loc(sc, ball)))
    sc.frame_set(40)
    emit(CASE, "jump40_again", loc=fmt(loc(sc, ball)))
    S = sweep(sc, ball, range(1, 41))
    emit(CASE, "seq40", **traj_kv(S))
    done()

elif CASE == "stale":
    sc, ball, floor = build()
    rbw = sc.rigidbody_world
    pc = rbw.point_cache
    pc.frame_end = 40
    A = sweep(sc, ball, range(1, 41))
    emit(CASE, "free_ts1", **traj_kv(A))
    bpy.ops.ptcache.bake_all(bake=True)
    rbw.time_scale = 0.25
    emit(CASE, "mutate", ts=rbw.time_scale, outdated=pc.is_outdated,
         baked=pc.is_baked)
    B = sweep(sc, ball, range(1, 41))
    emit(CASE, "baked_ts025", eq_free=(A == B), **traj_kv(B))
    bpy.ops.ptcache.free_bake_all()
    emit(CASE, "freed", baked=pc.is_baked, outdated=pc.is_outdated,
         info=pc.info)
    C = sweep(sc, ball, range(1, 41))
    emit(CASE, "freed_ts025", eq_free=(A == C), **traj_kv(C))
    rbw.enabled = False
    D = sweep(sc, ball, range(1, 41))
    emit(CASE, "disabled", eq_free=(A == D), enabled=rbw.enabled,
         **traj_kv(D))
    rbw.enabled = True
    E = sweep(sc, ball, range(41, 61))
    emit(CASE, "beyond_cache", f45=fmt(E[4][1:]), f60=fmt(E[19][1:]),
         outdated=pc.is_outdated)
    done()

elif CASE == "resim":
    sc, ball, floor = build()
    rbw = sc.rigidbody_world
    pc = rbw.point_cache
    pc.frame_end = 20
    A20 = sweep(sc, ball, range(1, 21))
    emit(CASE, "pre_bake", f20=fmt(A20[-1][1:]))
    bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "baked", baked=pc.is_baked, info=pc.info)
    rbw.time_scale = 0.25
    emit(CASE, "mutate", ts=rbw.time_scale, outdated=pc.is_outdated)
    E = sweep(sc, ball, range(21, 41))
    emit(CASE, "post_mutation_forward", f21=fmt(E[0][1:]),
         f30=fmt(E[9][1:]), f40=fmt(E[19][1:]), h=thash(E))
    F = sweep(sc, ball, range(1, 21))
    emit(CASE, "reread_head", eq_pre=(A20 == F), f20=fmt(F[-1][1:]))
    rbw.enabled = False
    sweep(sc, ball, range(1, 3))
    rbw.enabled = True
    G = sweep(sc, ball, range(1, 21))
    emit(CASE, "after_toggle", eq_pre=(A20 == G), f20=fmt(G[-1][1:]),
         outdated=pc.is_outdated)
    bpy.ops.ptcache.free_bake_all()
    H = sweep(sc, ball, range(1, 21))
    emit(CASE, "after_free_bake", eq_pre=(A20 == H), f20=fmt(H[-1][1:]),
         info=pc.info, outdated=pc.is_outdated)
    I = sweep(sc, ball, range(41, 61))
    emit(CASE, "far_forward", f45=fmt(I[4][1:]), f60=fmt(I[19][1:]))
    done()

elif CASE == "partial":
    sc, ball, floor = build()
    rbw = sc.rigidbody_world
    pc = rbw.point_cache
    pc.frame_end = 60
    A = sweep(sc, ball, range(1, 21))
    emit(CASE, "head20", f20=fmt(A[-1][1:]), h=thash(A))
    rbw.time_scale = 0.25
    emit(CASE, "mutate", ts=rbw.time_scale, outdated=pc.is_outdated)
    B = sweep(sc, ball, range(21, 41))
    emit(CASE, "tail", f21=fmt(B[0][1:]), f25=fmt(B[4][1:]),
         f30=fmt(B[9][1:]), f40=fmt(B[19][1:]), h=thash(B))
    C = sweep(sc, ball, range(1, 21))
    emit(CASE, "head_reread", eq_head=(A == C), f20=fmt(C[-1][1:]))
    done()

elif CASE == "trace":
    # reduced resim_trace: only the discriminating reads of the scout cell
    # (R5/R20 stale hold, T frozen tail, H2 = ts025 control values, SUMMARY
    # hashes). The full per-frame dump stays a scout artifact.
    sc, ball, floor = build()
    rbw = sc.rigidbody_world
    pc = rbw.point_cache
    pc.frame_end = 60
    H1 = sweep(sc, ball, range(1, 21))
    rbw.time_scale = 0.25
    emit(CASE, "MUT", ts=rbw.time_scale, outdated=pc.is_outdated)
    r5 = row(sc, ball, 5)
    emit(CASE, "R5", f05=fmt(r5[1:]))
    r20 = row(sc, ball, 20)
    emit(CASE, "R20", f20=fmt(r20[1:]))
    T = sweep(sc, ball, range(21, 41))
    emit(CASE, "T", f21=fmt(T[0][1:]), f30=fmt(T[9][1:]),
         f40=fmt(T[19][1:]),
         frozen=all(r[1:] == T[0][1:] for r in T))
    H2 = sweep(sc, ball, range(1, 21))
    emit(CASE, "H2", f10=fmt(H2[9][1:]), f20=fmt(H2[19][1:]))
    T2 = sweep(sc, ball, range(21, 41))
    emit(CASE, "T2", f30=fmt(T2[9][1:]))
    T3 = sweep(sc, ball, range(41, 61))
    emit(CASE, "T3", f60=fmt(T3[19][1:]))
    emit(CASE, "SUMMARY", h1=thash(H1), t=thash(T), h2=thash(H2),
         t2=thash(T2), t3=thash(T3), h1_eq_h2=(H1 == H2),
         t_eq_t2=(T == T2))
    done()

elif CASE == "ctrl025":
    sc, ball, floor = build()
    sc.rigidbody_world.time_scale = 0.25
    A = sweep(sc, ball, range(1, 61))
    emit(CASE, "traj", ts=sc.rigidbody_world.time_scale, **traj_kv(A))
    done()

elif CASE == "fps":
    # in-process rebuild lattice (read_factory_settings rebuilds are
    # trajectory-identical on this host — author probe rebuild3, x3)
    for f_ in (24, 60, 120):
        sc, ball, floor = build()
        sc.render.fps = f_
        sc.render.fps_base = 1.0
        A = sweep(sc, ball, range(1, 41))
        emit(CASE, "fps{}".format(f_), fps=sc.render.fps,
             h=thash(A), last=fmt(A[-1][1:]))
    done()

elif CASE == "solv":
    for key, value in (("substeps", 1), ("substeps", 40),
                       ("iters", 1), ("split", 1)):
        sc, ball, floor = build()
        rbw = sc.rigidbody_world
        if key == "substeps":
            rbw.substeps_per_frame = value
        elif key == "iters":
            rbw.solver_iterations = value
        elif key == "split":
            rbw.use_split_impulse = True
        A = sweep(sc, ball, range(1, 41))
        emit(CASE, "{}{}".format(key, value),
             substeps=rbw.substeps_per_frame,
             iters=rbw.solver_iterations, split=rbw.use_split_impulse,
             h=thash(A), last=fmt(A[-1][1:]))
    done()

elif CASE == "polls":
    sc, ball, floor = build()
    emit(CASE, "env", background=bpy.app.background,
         version=bpy.app.version_string.split()[0])
    polls = {}
    for name in ("bake", "bake_all", "free_bake", "free_bake_all",
                 "bake_from_cache"):
        try:
            polls[name] = getattr(bpy.ops.ptcache, name).poll()
        except Exception as exc:
            polls[name] = "ERR:" + type(exc).__name__
    emit(CASE, "ptcache_polls", **polls)
    emit(CASE, "rigidbody_polls",
         bake_to_keyframes=bpy.ops.rigidbody.bake_to_keyframes.poll(),
         world_remove=bpy.ops.rigidbody.world_remove.poll())
    try:
        bpy.ops.ptcache.bake(bake=True)
        emit(CASE, "bake_call", err="none")
    except Exception as exc:
        emit(CASE, "bake_call", err=type(exc).__name__,
             msg=str(exc).split("\n")[0][:80])
    try:
        bpy.ops.ptcache.free_bake()
        emit(CASE, "free_call", err="none")
    except Exception as exc:
        emit(CASE, "free_call", err=type(exc).__name__,
             msg=str(exc).split("\n")[0][:80])
    try:
        bpy.ops.ptcache.bake_from_cache()
        emit(CASE, "from_cache_call", err="none")
    except Exception as exc:
        emit(CASE, "from_cache_call", err=type(exc).__name__,
             msg=str(exc).split("\n")[0][:80])
    done()

elif CASE == "b2k":
    # bake_to_keyframes polls True but dies inside the anim operator —
    # the execute failure prints `Error: Python: Traceback` + a
    # RuntimeError line to fd1 (parent e= counter witnesses it).
    sc, ball, floor = build()
    sweep(sc, ball, range(1, 41))
    bpy.ops.object.select_all(action="DESELECT")
    ball.select_set(True)
    bpy.context.view_layer.objects.active = ball
    try:
        r = bpy.ops.rigidbody.bake_to_keyframes(frame_start=1,
                                              frame_end=40, step=1)
        emit(CASE, "b2k_call", err="none", ret=str(r))
    except Exception as exc:
        # the message text carries the caller's script path — pin
        # identifying booleans, never the path
        emit(CASE, "b2k_call", err=type(exc).__name__,
             pollfail=("poll() failed" in str(exc)),
             kf_op=("keyframe_insert_by_name" in str(exc)))
    emit(CASE, "b2k_state", actions=len(bpy.data.actions),
         anim_data=ball.animation_data is not None)
    done()

elif CASE == "disk":
    out = os.path.join(WORKDIR, "cache")
    os.makedirs(out, exist_ok=True)
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    pc.filepath = os.path.join(out, "rb_")
    pc.use_disk_cache = True
    emit(CASE, "rbw_set", disk=pc.use_disk_cache, ext=pc.use_external,
         filepath=os.path.basename(pc.filepath))
    pc.use_external = True
    emit(CASE, "rbw_external", disk=pc.use_disk_cache, ext=pc.use_external)
    sweep(sc, ball, range(1, 6))
    files = sorted(os.listdir(out))
    emit(CASE, "rbw_after_sweep", n=len(files),
         names="|".join(files[:3]), info=pc.info)
    bpy.ops.ptcache.bake_all(bake=True)
    files = sorted(os.listdir(out))
    emit(CASE, "rbw_after_bake", n=len(files), names="|".join(files[:3]),
         baked=pc.is_baked, info=pc.info)
    sc2, ball2, floor2 = build()
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=8, y_subdivisions=8,
                                    size=2.0, location=(0.0, 0.0, 4.0))
    cloth = bpy.context.active_object
    cloth.name = "cloth"
    bpy.ops.object.modifier_add(type="CLOTH")
    mod = cloth.modifiers[0]
    cpc = mod.point_cache
    cpc.filepath = os.path.join(out, "cl_")
    cpc.use_disk_cache = True
    emit(CASE, "cloth_set", disk=cpc.use_disk_cache, ext=cpc.use_external,
         filepath=os.path.basename(cpc.filepath))
    for f in range(1, 11):
        sc2.frame_set(f)
    files = sorted(os.listdir(out))
    emit(CASE, "cloth_after_sweep", n=len(files),
         names="|".join(files[:3]), info=cpc.info)
    done()

elif CASE == "blend":
    # the .blend file bytes drift rep to rep (zstd container, 5.2.1) —
    # only the reload BEHAVIOUR is pinned, never the file sha/size.
    path = os.path.join(WORKDIR, "rbw.blend")
    sc, ball, floor = build()
    pc = sc.rigidbody_world.point_cache
    pc.frame_end = 40
    bpy.ops.ptcache.bake_all(bake=True)
    emit(CASE, "baked", info=pc.info, baked=pc.is_baked)
    bpy.ops.wm.save_as_mainfile(filepath=path, check_existing=False)
    emit(CASE, "saved", exists=os.path.exists(path))
    bpy.ops.wm.open_mainfile(filepath=path)
    sc2 = bpy.context.scene
    emit(CASE, "loaded", sc=sc2.name, fs=sc2.frame_start,
         fe=sc2.frame_end, rbw=sc2.rigidbody_world is not None)
    ball2 = bpy.data.objects.get("ball")
    pc2 = sc2.rigidbody_world.point_cache if sc2.rigidbody_world else None
    emit(CASE, "loaded_pc", info=pc2.info if pc2 else "none",
         baked=pc2.is_baked if pc2 else "none")
    sc2.frame_set(40)
    t = ball2.evaluated_get(
        bpy.context.evaluated_depsgraph_get()).matrix_world.translation
    emit(CASE, "jump40", loc=fmt((t.x, t.y, t.z)))
    sc2.frame_set(20)
    t = ball2.evaluated_get(
        bpy.context.evaluated_depsgraph_get()).matrix_world.translation
    emit(CASE, "jump20", loc=fmt((t.x, t.y, t.z)))
    done()

elif CASE == "shot":
    out = os.path.join(WORKDIR, "render")
    os.makedirs(out, exist_ok=True)
    sc, ball, floor = build()
    bpy.ops.object.camera_add(location=(12.0, -12.0, 10.0),
                              rotation=(1.1, 0.0, 0.785))
    sc.camera = bpy.context.active_object
    bpy.ops.object.light_add(type="SUN", location=(4.0, -4.0, 10.0))
    sc.render.engine = "CYCLES"
    sc.cycles.samples = 1
    sc.cycles.device = "CPU"
    sc.render.resolution_x = 64
    sc.render.resolution_y = 64
    sc.render.image_settings.file_format = "PNG"

    def shot(name):
        p = os.path.join(out, name + ".png")
        sc.render.filepath = p[:-4]
        pre = loc(sc, ball)
        r = bpy.ops.render.render(write_still=True)
        post = loc(sc, ball)
        digest = "none"
        if os.path.exists(p):
            with open(p, "rb") as fh:
                digest = hashlib.sha256(fh.read()).hexdigest()[:16]
        return r, pre, post, digest, sc.frame_current

    sc.frame_set(40)
    r1, pre1, post1, h1, f1 = shot("jump40")
    emit(CASE, "jump40", ret=str(r1), pre=fmt(pre1), post=fmt(post1),
         written=os.path.exists(os.path.join(out, "jump40.png")),
         fcur=f1)
    S = sweep(sc, ball, range(1, 21))
    emit(CASE, "after_step20", f20=fmt(S[-1][1:]))
    sc.frame_set(40)
    r2, pre2, post2, h2, f2 = shot("from20")
    emit(CASE, "jump40_from20", ret=str(r2), pre=fmt(pre2),
         post=fmt(post2),
         written=os.path.exists(os.path.join(out, "from20.png")),
         fcur=f2)
    S40 = sweep(sc, ball, range(1, 41))
    r3, pre3, post3, h3, f3 = shot("seq40")
    emit(CASE, "seq40", ret=str(r3), pre=fmt(pre3), post=fmt(post3),
         written=os.path.exists(os.path.join(out, "seq40.png")),
         fcur=f3)
    # PNG bytes are a non-witness (render_det pins stable=False); only
    # the pairwise booleans are emitted, never the digests.
    emit(CASE, "compare", h1_eq_h2=(h1 == h2), h3_diff=(h3 != h1),
         sim_f40=fmt(S40[-1][1:]))
    done()

elif CASE == "rdet":
    out = os.path.join(WORKDIR, "renderdet")
    os.makedirs(out, exist_ok=True)
    sc, ball, floor = build()
    bpy.ops.object.camera_add(location=(12.0, -12.0, 10.0),
                              rotation=(1.1, 0.0, 0.785))
    sc.camera = bpy.context.active_object
    bpy.ops.object.light_add(type="SUN", location=(4.0, -4.0, 10.0))
    sc.render.engine = "CYCLES"
    sc.cycles.samples = 1
    sc.cycles.device = "CPU"
    sc.render.resolution_x = 64
    sc.render.resolution_y = 64

    def shot(name):
        p = os.path.join(out, name + ".png")
        sc.render.filepath = p[:-4]
        bpy.ops.render.render(write_still=True)
        with open(p, "rb") as fh:
            return hashlib.sha256(fh.read()).hexdigest()[:16]

    S = sweep(sc, ball, range(1, 41))
    emit(CASE, "state", f40=fmt(S[-1][1:]))
    h1, h2, h3 = shot("a"), shot("b"), shot("c")
    emit(CASE, "same_state", stable=(h1 == h2 == h3))
    sc.frame_set(1)
    h4 = shot("moved")
    emit(CASE, "moved_state", differs=(h4 != h1))
    done()

elif CASE in ("ptr_stale", "ptr_fresh"):
    # stale RNA pointer across a factory reset: the write through the
    # pre-reset world pointer SIGSEGVs (rc 139 via timeout); the fresh
    # control must not. Breadcrumbs bound the write.
    sc_a, ball_a, floor_a = build()
    rbw_a = sc_a.rigidbody_world
    sc_b, ball_b, floor_b = build()
    rbw_b = sc_b.rigidbody_world
    emit(CASE, "reset", mode=CASE[4:], b_ok=rbw_b is not None,
         ts_b=rbw_b.time_scale)
    target = rbw_a if CASE == "ptr_stale" else rbw_b
    emit(CASE, "pre_write", alive="True")
    target.time_scale = 0.25
    emit(CASE, "post_write", ts=str(target.time_scale))
    done()

else:
    print("M {} unknown_case".format(CASE), flush=True)
    sys.exit(2)
