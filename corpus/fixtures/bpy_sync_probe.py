"""r79 tracked fixture: bpy two-layer read timing (Blender 5.2.1 headless).

Claim under test (round-79 declared axis-move):
  direct RNA writes are immediately visible to same-script RNA reads, BUT
  evaluated-dependency-graph reads (depsgraph / evaluated_get) lag by one
  evaluation -- a two-layer timing model analogous to Godot's
  getter-vs-NavigationServer3D-serve split.

r79 measured result (promoted from the r79-scout probes, verbatim arm set
plus the membership/draincheck/shared arms folded in from probe2/probe3):
  the split is WRITE-THROUGH vs EVALUATION-GATED, not RNA-vs-depsgraph:
    tier 0  written RNA props (location, hide flag, modifier stack,
            collection membership): fresh at write+0.
    tier 1  derived RNA props (matrix_world) AND held-handle depsgraph
            reads: stale until the next evaluation event.
    drain   absent: no implicit eval between statements in `blender -b -P`;
            unrelated RNA reads do not flush a held depsgraph handle.
  `evaluated_depsgraph_get()` is itself an evaluation event: a fresh get
  always sees fresh, and because the graph is SHARED (is_same=True) it
  flushes previously-held handles too. The held-handle stale regime is
  unbounded -- the bpy analogue of Godot's map_off permanence, not the
  2f/3f link/region edges.
  Non-signal: evaluated_obj.visible_get()/hide_get() do not track the
  mutation arms on this build (receipt-pinned as quirk; not a witness).

Sample points per arm (the bpy analogue of Godot's "wait" rungs):
  w0 = write+0   : read in the same script tick, no update, no frame change
  wU = post-view_layer.update()   : manual eval sync (analogue of forced serve)
  wF = post-scene.frame_set(+1)   : frame advance (analogue of tick drain)

Two read layers at every point:
  RNA : direct attribute on the original object
  DEG : object.evaluated_get(depsgraph) attribute / dg.object_instances

Emits machine-parseable lines:  ARM <name> | <point> | <layer> | <key>=<val> ...
Receipt contract: every line is exact-stdout; run via `blender -b -P <this>.py`.
Companion runner: corpus/fixtures/bpy_battery.py pins the measured lattice.
"""

import bpy
import traceback

D = bpy.data
C = bpy.context


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def v3(v):
    return "({:.3f},{:.3f},{:.3f})".format(v[0], v[1], v[2])


def emit(arm, point, layer, **kw):
    body = " ".join("{}={}".format(k, v) for k, v in kw.items())
    print("ARM {} | {} | {} | {}".format(arm, point, layer, body))


def deg_read(obj, arm, point, handle=None):
    """Read through evaluated depsgraph. handle=None -> fresh context handle."""
    try:
        dg = handle if handle is not None else C.evaluated_depsgraph_get()
        ev = obj.evaluated_get(dg)
        emit(arm, point, "DEG",
             loc=v3(ev.location),
             mw_t=v3(ev.matrix_world.translation),
             orig=str(ev.original == obj))
        return ev
    except Exception as e:
        emit(arm, point, "DEG", err=type(e).__name__ + ":" + str(e)[:80])
        return None


# ---------------------------------------------------------------- arm: transform
def arm_transform():
    reset_scene()
    arm = "transform"
    scn = C.scene
    col = scn.collection
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    col.objects.link(ob)
    C.view_layer.update()  # settle: depsgraph exists at baseline

    dg0 = C.evaluated_depsgraph_get()          # handle captured BEFORE write
    ob.location = (5.0, 0.0, 0.0)              # the mutation

    emit(arm, "w0", "RNA", loc=v3(ob.location), mw_t=v3(ob.matrix_world.translation))
    deg_read(ob, arm, "w0-held", handle=dg0)   # same handle, post-write
    deg_read(ob, arm, "w0-fresh")              # fresh handle, post-write

    C.view_layer.update()
    emit(arm, "wU", "RNA", loc=v3(ob.location), mw_t=v3(ob.matrix_world.translation))
    deg_read(ob, arm, "wU-held", handle=dg0)
    deg_read(ob, arm, "wU-fresh")

    scn.frame_set(scn.frame_current + 1)
    emit(arm, "wF", "RNA", loc=v3(ob.location), mw_t=v3(ob.matrix_world.translation))
    deg_read(ob, arm, "wF-held", handle=dg0)
    deg_read(ob, arm, "wF-fresh")

    # extra rung: does Depsgraph.update() exist / flush on this build?
    try:
        ob.location = (9.0, 0.0, 0.0)
        dg1 = C.evaluated_depsgraph_get()
        emit(arm, "w0b", "DEG", loc=v3(ob.evaluated_get(dg1).location))
        dg1.update()
        emit(arm, "wD", "DEG", loc=v3(ob.evaluated_get(dg1).location),
             mw_t=v3(ob.evaluated_get(dg1).matrix_world.translation))
        emit(arm, "wD", "RNA", mw_t=v3(ob.matrix_world.translation))
    except Exception as e:
        emit(arm, "wD", "ERR", err=type(e).__name__ + ":" + str(e)[:80])


# ---------------------------------------------------------------- arm: hide_set
def arm_hide():
    reset_scene()
    arm = "hide"
    scn = C.scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    scn.collection.objects.link(ob)
    C.view_layer.update()

    dg0 = C.evaluated_depsgraph_get()
    ob.hide_set(True)                          # the mutation

    def reads(point):
        emit(arm, point, "RNA", hide_get=ob.hide_get(),
             vis_get=ob.visible_get())
        try:
            ev = ob.evaluated_get(dg0 if point.endswith("held")
                                  else C.evaluated_depsgraph_get())
            emit(arm, point, "DEG", hide_get=ev.hide_get(),
                 vis_get=ev.visible_get())
        except Exception as e:
            emit(arm, point, "DEG", err=type(e).__name__ + ":" + str(e)[:60])

    reads("w0-held"); reads("w0-fresh")
    C.view_layer.update()
    reads("wU-held"); reads("wU-fresh")
    scn.frame_set(scn.frame_current + 1)
    reads("wF-held"); reads("wF-fresh")


# ---------------------------------------------------------------- arm: modifier
def arm_modifier():
    reset_scene()
    arm = "modifier"
    scn = C.scene
    me = D.meshes.new("m")
    # 1x1 subdividable quad grid (4x4 verts = 9 quads)
    vs, fs = [], []
    n = 4
    for y in range(n):
        for x in range(n):
            vs.append((x / (n - 1), y / (n - 1), 0.0))
    for y in range(n - 1):
        for x in range(n - 1):
            i = y * n + x
            fs.append((i, i + 1, i + 1 + n, i + n))
    me.from_pydata(vs, [], fs)
    ob = D.objects.new("o", me)
    scn.collection.objects.link(ob)
    C.view_layer.update()
    base_verts = len(me.vertices)

    dg0 = C.evaluated_depsgraph_get()
    mod = ob.modifiers.new("subd", 'SUBSURF')  # the mutation
    mod.subdivision_type = 'SIMPLE'
    mod.levels = 1

    def reads(point, handle=None):
        emit(arm, point, "RNA", nmods=len(ob.modifiers),
             names="|".join(m.name for m in ob.modifiers))
        try:
            dg = handle if handle is not None else C.evaluated_depsgraph_get()
            ev = ob.evaluated_get(dg)
            em = ev.to_mesh()
            emit(arm, point, "DEG", eval_verts=len(em.vertices),
                 base_verts=base_verts)
            ev.to_mesh_clear()
        except Exception as e:
            emit(arm, point, "DEG", err=type(e).__name__ + ":" + str(e)[:60])

    reads("w0-held", handle=dg0); reads("w0-fresh")
    C.view_layer.update()
    reads("wU-held", handle=dg0); reads("wU-fresh")
    scn.frame_set(scn.frame_current + 1)
    reads("wF-held", handle=dg0); reads("wF-fresh")


# ------------------------------------------------------------ arm: col link/unlink
def arm_collection():
    reset_scene()
    arm = "collink"
    scn = C.scene
    col_a = scn.collection                      # in view layer
    col_b = D.collections.new("b")              # orphan, NOT in view layer
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    col_a.objects.link(ob)
    C.view_layer.update()

    dg0 = C.evaluated_depsgraph_get()
    col_a.objects.unlink(ob)                    # mutation 1: unlink from VL col
    col_b.objects.link(ob)                      # mutation 2: link to orphan col

    def reads(point, handle=None):
        emit(arm, point, "RNA",
             in_a=ob.name in col_a.objects,
             in_b=ob.name in col_b.objects,
             users="|".join(sorted(c.name for c in ob.users_collection)),
             vis=ob.visible_get())
        try:
            dg = handle if handle is not None else C.evaluated_depsgraph_get()
            ev = ob.evaluated_get(dg)
            emit(arm, point, "DEG", ev_vis=ev.visible_get(),
                 hide=ev.hide_get())
        except Exception as e:
            emit(arm, point, "DEG", err=type(e).__name__ + ":" + str(e)[:60])

    reads("w0-held", handle=dg0); reads("w0-fresh")
    C.view_layer.update()
    reads("wU-held", handle=dg0); reads("wU-fresh")
    scn.frame_set(scn.frame_current + 1)
    reads("wF-held", handle=dg0); reads("wF-fresh")

    # reverse arm: link orphan-col object back into view layer
    col_b.objects.unlink(ob); col_a.objects.link(ob)
    emit(arm, "relink-w0", "RNA", in_a=ob.name in col_a.objects)
    try:
        ev = ob.evaluated_get(C.evaluated_depsgraph_get())
        emit(arm, "relink-w0", "DEG", ev_vis=ev.visible_get())
    except Exception as e:
        emit(arm, "relink-w0", "DEG", err=type(e).__name__ + ":" + str(e)[:60])
    C.view_layer.update()
    try:
        ev = ob.evaluated_get(C.evaluated_depsgraph_get())
        emit(arm, "relink-wU", "DEG", ev_vis=ev.visible_get())
    except Exception as e:
        emit(arm, "relink-wU", "DEG", err=type(e).__name__ + ":" + str(e)[:60])


# ------------------------------------------------------- arm: membership (probe2)
def arm_membership():
    """Depsgraph membership edge: object_instances enumeration is the
    staleness witness (evaluated visible_get() is a non-signal on this
    build -- see arm hide/vis arms). keep = control in view layer; mover
    is moved out to an orphan collection and back."""
    reset_scene()
    arm = "membership"
    scn = C.scene
    col_b = D.collections.new("orphan")          # never linked to scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    keep = D.objects.new("keep", me)
    mover = D.objects.new("mover", me)
    scn.collection.objects.link(keep)
    scn.collection.objects.link(mover)
    C.view_layer.update()

    def inst_names(dg):
        try:
            return "|".join(sorted(i.object.name for i in dg.object_instances
                                   if not i.is_instance))
        except Exception as e:
            return "ERR:" + type(e).__name__

    dg0 = C.evaluated_depsgraph_get()
    emit(arm, "base", "DEG", names=inst_names(dg0))

    scn.collection.objects.unlink(mover)
    col_b.objects.link(mover)

    emit(arm, "w0-held", "DEG", names=inst_names(dg0))
    emit(arm, "w0-fresh", "DEG",
         names=inst_names(C.evaluated_depsgraph_get()))
    emit(arm, "w0", "RNA", vis=mover.visible_get(),
         users="|".join(sorted(c.name for c in mover.users_collection)))

    C.view_layer.update()
    emit(arm, "wU-held", "DEG", names=inst_names(dg0))
    emit(arm, "wU-fresh", "DEG",
         names=inst_names(C.evaluated_depsgraph_get()))

    col_b.objects.unlink(mover)
    scn.collection.objects.link(mover)
    emit(arm, "relink-w0-held", "DEG", names=inst_names(dg0))
    emit(arm, "relink-w0-fresh", "DEG",
         names=inst_names(C.evaluated_depsgraph_get()))
    emit(arm, "relink-w0", "RNA", vis=mover.visible_get())
    C.view_layer.update()
    emit(arm, "relink-wU-held", "DEG", names=inst_names(dg0))
    try:
        ev = mover.evaluated_get(dg0)
        emit(arm, "relink-wU-held", "DEGobj", ev_vis=ev.visible_get())
    except Exception as e:
        emit(arm, "relink-wU-held", "DEGobj",
             err=type(e).__name__ + ":" + str(e)[:60])
    try:
        ev = mover.evaluated_get(C.evaluated_depsgraph_get())
        emit(arm, "relink-wU-fresh", "DEGobj", ev_vis=ev.visible_get())
    except Exception as e:
        emit(arm, "relink-wU-fresh", "DEGobj",
             err=type(e).__name__ + ":" + str(e)[:60])


# ------------------------------------------------------- arm: draincheck (probe2)
def arm_draincheck():
    """Does ANY unrelated read between writes flush a held handle?
    Godot drains its navserver serve queue per physics tick; `blender -b -P`
    has no idle pump -- this arm measures the absence."""
    reset_scene()
    arm = "draincheck"
    scn = C.scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob2 = D.objects.new("o2", me)
    scn.collection.objects.link(ob2)
    C.view_layer.update()
    dg1 = C.evaluated_depsgraph_get()
    ob2.location = (4.0, 0.0, 0.0)
    emit(arm, "w0-held", "DEG", loc=v3(ob2.evaluated_get(dg1).location))
    _ = scn.frame_current
    _ = len(D.objects)
    _ = ob2.matrix_world
    emit(arm, "w0-held2", "DEG", loc=v3(ob2.evaluated_get(dg1).location))
    _ = ob2.visible_get()
    emit(arm, "w0-held3", "DEG", loc=v3(ob2.evaluated_get(dg1).location))


# -------------------------------------------- arm: shared-graph flush (probe3)
def arm_shared():
    """Is the fresh-get evaluation graph-global (held handles flush too) or
    per-get? Measured: one shared graph object (is_same=True), evaluated in
    place -- a fresh get flushes previously-held handles."""
    reset_scene()
    arm = "shared"
    scn = C.scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    scn.collection.objects.link(ob)
    C.view_layer.update()

    dg0 = C.evaluated_depsgraph_get()
    ob.location = (2.0, 0.0, 0.0)
    emit(arm, "w0-held-a", "DEG", loc=v3(ob.evaluated_get(dg0).location))
    dgf = C.evaluated_depsgraph_get()          # fresh get -- evaluates
    emit(arm, "same-obj", "DEG", is_same=(dgf == dg0))
    emit(arm, "w0-fresh", "DEG", loc=v3(ob.evaluated_get(dgf).location))
    emit(arm, "w0-held-b", "DEG", loc=v3(ob.evaluated_get(dg0).location))


# -------------------------------------------- arm: fresh get auto-evaluates?
def arm_fresh_handle():
    reset_scene()
    arm = "freshhandle"
    scn = C.scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    scn.collection.objects.link(ob)
    C.view_layer.update()
    ob.location = (3.0, 0.0, 0.0)
    dg = C.evaluated_depsgraph_get()
    emit(arm, "w0-fresh", "DEG", loc=v3(ob.evaluated_get(dg).location))
    dg2 = C.evaluated_depsgraph_get()
    emit(arm, "w0-fresh2", "DEG", loc=v3(ob.evaluated_get(dg2).location))
    ob.location = (7.0, 0.0, 0.0)
    scn.frame_set(scn.frame_current + 1)
    emit(arm, "postF", "RNA", mw_t=v3(ob.matrix_world.translation))
    emit(arm, "postF", "DEG",
         loc=v3(ob.evaluated_get(C.evaluated_depsgraph_get()).location))


# -------------------------------------------- arm: evaluated-visibility quirk
def arm_vis_quirk():
    """Receipt-pin the non-signal: evaluated_obj.visible_get()/hide_get()
    stay False on an instantiated, RNA-visible object on this build. Pinned
    as observed quirk; NOT usable as a staleness witness."""
    reset_scene()
    arm = "vis"
    scn = C.scene
    me = D.meshes.new("m")
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    ob = D.objects.new("o", me)
    scn.collection.objects.link(ob)
    C.view_layer.update()
    ob.hide_set(True)
    emit(arm, "hidden", "RNA", vis=ob.visible_get(), hide=ob.hide_get(),
         hidevp=ob.hide_viewport)
    ev = ob.evaluated_get(C.evaluated_depsgraph_get())
    emit(arm, "hidden-ev", "DEG", vis=ev.visible_get(), hide=ev.hide_get(),
         hidevp=ev.hide_viewport)
    ob.hide_set(False)
    col_b = D.collections.new("orphan")
    scn.collection.objects.unlink(ob); col_b.objects.link(ob)
    C.view_layer.update()
    col_b.objects.unlink(ob); scn.collection.objects.link(ob)
    C.view_layer.update()
    ev = ob.evaluated_get(C.evaluated_depsgraph_get())
    emit(arm, "relinked", "RNA", vis=ob.visible_get())
    emit(arm, "relinked", "DEG", vis=ev.visible_get(), hide=ev.hide_get(),
         hidevp=ev.hide_viewport,
         in_inst=("o" in "|".join(i.object.name
                                  for i in C.evaluated_depsgraph_get()
                                  .object_instances if not i.is_instance)))


for f in (arm_transform, arm_hide, arm_modifier, arm_collection,
          arm_membership, arm_draincheck, arm_shared, arm_fresh_handle,
          arm_vis_quirk):
    try:
        f()
    except Exception:
        print("ARM {} | FATAL | {}".format(f.__name__,
                                           traceback.format_exc()[:400]))
print("PROBE_DONE")
