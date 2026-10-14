"""r79+r80+r81 tracked fixture: bpy timing + evalcat + reorder (Blender 5.2.1 headless).

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
import os
import stat
import subprocess
import sys
import time
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


# ============================================================ r80: evalcat
# Round-80 arm: folds the frontier eval-event catalogue (reports/frontier/
# fa-bpy-evalcat.md, probes in corpus/live/frontier-bpyeval/) into pinned
# per-mutation-class edge rows. Same build: Blender 5.2.1 LTS headless.
#
# Claim under test (round-80 declared move): the eval-event set
#   {evaluated_depsgraph_get, view_layer.update, frame_set, dg.update,
#    bpy.ops}
# is enumerable and CLOSED -- falsified if any probed mutation class
# flushes a held depsgraph handle without one of those events firing.
# _ec_edge() enforces this mechanically per row: a bare (invoked=None)
# row whose held read moved OR which fired any watched handler ran an
# eval event outside the set -> edge forced to FALSIFIED and counted in
# the closing `closed` row's violations=N.
#
# Row schema (all under arm name "evalcat"):
#   ARM evalcat | <point> | EDGE | held=<flushed|stale|na> invoked=<e|none>
#        dpre=N dpost=N dfcp=N dfc=N dund=N dup_fired=<b> fc_fired=<b>
#        edge=<label> [per-class witnesses]
#   edge=0        the action is itself an eval event (bpy.ops / explicit)
#   edge=1        bare write: held stale at write+0, one tagged eval binds
#   edge=frame    inert through tagged evals; binds only at frame_set
#   edge=cond     enumerated event is conditional: clean graph fires nil
#   edge=absent   no eval event on this axis at all (wall-time drain)
#   edge=FALSIFIED closed-set violation (auto-computed, never caller-set)
#
# Handler snapshot per row: dpre/dpost = depsgraph_update_pre/post,
# dfcp/dfc = frame_change_pre/post, dund = undo_post. Per frontier,
# msgbus and undo_post are dead surfaces under `-b -P` -- dund is
# emitted for the receipt but is never a pinned witness.

EVALCAT_LOG = {"pre": [], "post": [], "fcp": [], "fc": [], "und": []}
EVALCAT_VIOLATIONS = [0]
EVALCAT_EVENTS = ("evaluated_depsgraph_get", "view_layer.update",
                  "frame_set", "dg.update", "bpy.ops")


def _ec_mk(key):
    def h(*a):
        EVALCAT_LOG[key].append(len(a))
    return h


def _ec_register():
    """read_factory_settings clears non-persistent handlers: reinstall the
    watched lists and zero counts once per sub-probe (frontier convention)."""
    for lst in (bpy.app.handlers.depsgraph_update_pre,
                bpy.app.handlers.depsgraph_update_post,
                bpy.app.handlers.frame_change_pre,
                bpy.app.handlers.frame_change_post,
                bpy.app.handlers.undo_post):
        for h in list(lst):
            lst.remove(h)
    bpy.app.handlers.depsgraph_update_pre.append(_ec_mk("pre"))
    bpy.app.handlers.depsgraph_update_post.append(_ec_mk("post"))
    bpy.app.handlers.frame_change_pre.append(_ec_mk("fcp"))
    bpy.app.handlers.frame_change_post.append(_ec_mk("fc"))
    bpy.app.handlers.undo_post.append(_ec_mk("und"))
    for k in EVALCAT_LOG:
        EVALCAT_LOG[k].clear()


def _ec_reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    _ec_register()


def _ec_snap():
    return {k: len(v) for k, v in EVALCAT_LOG.items()}


def _ec_since(h0):
    h1 = _ec_snap()
    return {k: h1[k] - h0[k] for k in h1}


def _ec_tri(name="m"):
    me = D.meshes.new(name)
    me.from_pydata([(0, 0, 0), (1, 0, 0), (0, 1, 0)], [], [(0, 1, 2)])
    return me


def _ec_grid(n=4):
    me = D.meshes.new("g")
    vs, fs = [], []
    for y in range(n):
        for x in range(n):
            vs.append((x / (n - 1), y / (n - 1), 0.0))
    for y in range(n - 1):
        for x in range(n - 1):
            i = y * n + x
            fs.append((i, i + 1, i + 1 + n, i + n))
    me.from_pydata(vs, [], fs)
    return me


def _ec_settle(me=None):
    """Fresh object linked in view layer + baseline eval; (ob, held dg0)."""
    ob = D.objects.new("o", me or _ec_tri())
    C.scene.collection.objects.link(ob)
    C.view_layer.update()
    return ob, C.evaluated_depsgraph_get()


def _ec_activate(ob):
    C.view_layer.objects.active = ob
    for o in C.scene.objects:
        o.select_set(o == ob)


def _ec_loc(ob, dg):
    try:
        return v3(ob.evaluated_get(dg).location)
    except Exception as e:
        return "ERR:" + type(e).__name__


def _ec_mw(ob, dg):
    try:
        return v3(ob.evaluated_get(dg).matrix_world.translation)
    except Exception as e:
        return "ERR:" + type(e).__name__


def _ec_verts(ob, dg):
    """Single-token evaluated-mesh witness (a space would break kv parse)."""
    try:
        ev = ob.evaluated_get(dg)
        me = ev.to_mesh()
        n = len(me.vertices)
        mx = max((v.co.x for v in me.vertices), default=-1.0)
        ev.to_mesh_clear()
        return "verts%d:xmax%.3f" % (n, mx)
    except Exception as e:
        return "ERR:" + type(e).__name__


def _ec_names(dg):
    try:
        return "|".join(sorted(i.object.name for i in dg.object_instances
                               if not i.is_instance))
    except Exception as e:
        return "ERR:" + type(e).__name__


def _ec_opret(r):
    try:
        return "|".join(sorted(r))
    except Exception:
        return str(r)


def _ec_held(pre, post, d):
    """Held-handle observation across one action window:
    moved -> flushed; unmoved but a watched eval/frame handler fired ->
    na (evaluated, this witness can't discriminate); unmoved + silent ->
    stale. Bare writes MUST come back stale; ops must not."""
    if post != pre:
        return "flushed"
    if d["post"] or d["fcp"] or d["fc"]:
        return "na"
    return "stale"


def _ec_edge(point, d, held, invoked, edge, **kw):
    """Emit one per-class edge row and enforce the closed-set rule.
    invoked = enumerated event deliberately run for this row (one of
    EVALCAT_EVENTS) or None for bare mutations / non-event axes."""
    if invoked is None and (held == "flushed" or d["pre"] or d["post"]
                            or d["fcp"] or d["fc"]):
        edge = "FALSIFIED"
        EVALCAT_VIOLATIONS[0] += 1
    emit("evalcat", point, "EDGE", held=held, invoked=(invoked or "none"),
         dpre=d["pre"], dpost=d["post"], dfcp=d["fcp"], dfc=d["fc"],
         dund=d["und"], dup_fired=(d["post"] > 0),
         fc_fired=(d["fc"] > 0), edge=edge, **kw)


def _ec_edge1(held, fresh, expected):
    """Classify a bare-write row: stale + one tagged eval binds -> edge 1.
    `held` is "stale" on every reachable path — flushed/na states mask to
    FALSIFIED via the closed-set predicate in _ec_edge before this value
    is emitted (all 11 edge=1 call sites measured held=stale)."""
    return "1" if fresh == expected else "unbound"


def _ec_op_edge(held):
    """Classify a bpy.ops row: auto-eval proven by held flush, or by a
    depsgraph_update fire when the witness can't discriminate (na)."""
    return "0" if held in ("flushed", "na") else "stale"


# ------------------------------------------- evalcat sub-probe: event axis
def _ec_events():
    """The five enumerated events + bare-write control, one scene: which
    handler family each fires and whether a held handle flushes."""
    _ec_reset()
    scn = C.scene
    ob, dg0 = _ec_settle()

    # bare RNA write -- the control: no event invoked, must not flush
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    ob.location = (1.0, 0.0, 0.0)
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("rna_write", d, held, None,
             "1" if held == "stale" else held, held_loc=post)

    # event 1: evaluated_depsgraph_get on a dirty graph (tagged path)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    dg1 = C.evaluated_depsgraph_get()
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("ev_get", d, held, "evaluated_depsgraph_get",
             "0" if held == "flushed" else "noeval",
             held_loc=post, same_obj=(dg1 == dg0))

    # ...but the get is CONDITIONAL: on a clean graph it fires nothing
    h0 = _ec_snap()
    _ = C.evaluated_depsgraph_get()
    d = _ec_since(h0)
    quiet = not (d["pre"] or d["post"] or d["fcp"] or d["fc"])
    _ec_edge("ev_getclean", d, "na", "evaluated_depsgraph_get",
             "cond" if quiet else "uncond")

    # event 2: view_layer.update on a dirty graph (tagged path)
    ob.location = (2.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    C.view_layer.update()
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("ev_vlupdate", d, held, "view_layer.update",
             "0" if held == "flushed" else "noeval", held_loc=post)

    # ...also conditional: clean updates fire nothing
    h0 = _ec_snap()
    C.view_layer.update()
    C.view_layer.update()
    d = _ec_since(h0)
    quiet = not (d["pre"] or d["post"] or d["fcp"] or d["fc"])
    _ec_edge("ev_vlclean", d, "na", "view_layer.update",
             "cond" if quiet else "uncond")

    # event 3: frame_set(+1) -- frame path: fires fc, bypasses dup
    ob.location = (3.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    scn.frame_set(scn.frame_current + 1)
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("ev_frameset", d, held, "frame_set",
             "0" if held == "flushed" else "noeval",
             held_loc=post, frame=scn.frame_current)

    # event 3b: frame_set to the SAME frame still evals (r79 cell closed)
    ob.location = (4.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    scn.frame_set(scn.frame_current)
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("ev_framesame", d, held, "frame_set",
             "0" if held == "flushed" else "noeval",
             held_loc=post, frame=scn.frame_current)

    # event 4: Depsgraph.update() on the held handle itself
    ob.location = (5.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    dg0.update()
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("ev_dgupdate", d, held, "dg.update",
             "0" if held == "flushed" else "noeval", held_loc=post)


# --------------------------------------------- evalcat sub-probe: drivers
def _ec_driver():
    _ec_reset()
    ob, dg0 = _ec_settle()
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    fc = ob.driver_add("location", 0)                # driver RNA writes
    if isinstance(fc, (list, tuple)):
        fc = fc[0]
    drv = fc.driver
    drv.type = 'SCRIPTED'
    drv.expression = "7.0"
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    _ec_edge("driver", d, held, None,
             _ec_edge1(held, fresh, "(7.000,0.000,0.000)"),
             held_loc=post, fresh=fresh,
             rna_x="%.3f" % ob.location[0])
    C.view_layer.update()
    emit("evalcat", "driver_wU", "DEG", held=_ec_loc(ob, dg0),
         rna_x="%.3f" % ob.location[0])

    # editing the driver expression itself is the same edge=1 class
    dg1 = C.evaluated_depsgraph_get()
    pre = _ec_loc(ob, dg1)
    h0 = _ec_snap()
    drv.expression = "9.0"
    d = _ec_since(h0)
    post = _ec_loc(ob, dg1)
    held = _ec_held(pre, post, d)
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    _ec_edge("driver_expr", d, held, None,
             _ec_edge1(held, fresh, "(9.000,0.000,0.000)"),
             held_loc=post, fresh=fresh)


# -------------------------------------------- evalcat sub-probe: keyframes
def _ec_keyframe():
    """keyframe_insert leaves no graph-visible tag: inert through tagged
    evals, binds only at frame_set -> edge=frame. Contrast: an explicit
    layered action build DOES tag -> edge=1."""
    _ec_reset()
    scn = C.scene
    ob, dg0 = _ec_settle()
    scn.frame_set(1)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    ob.location = (0.0, 4.0, 0.0)
    r = ob.keyframe_insert("location", index=1, frame=1)
    ob.location = (0.0, 0.0, 0.0)                    # base; anim should drive
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    emit("evalcat", "keyframe_ins", "DEG", ret=str(r), held=post)

    ob.hide_viewport = False                         # guaranteed pending tag
    hU = _ec_snap()
    C.view_layer.update()
    dU = _ec_since(hU)
    tagged = _ec_loc(ob, C.evaluated_depsgraph_get())
    emit("evalcat", "keyframe_wU", "DEG", upd_dup=dU["post"],
         held=_ec_loc(ob, dg0), fresh=tagged)

    scn.frame_set(2)
    f2 = _ec_loc(ob, C.evaluated_depsgraph_get())
    scn.frame_set(1)
    f1 = _ec_loc(ob, C.evaluated_depsgraph_get())
    emit("evalcat", "keyframe_f", "DEG", f2=f2, f1=f1,
         rna_y="%.3f" % ob.location[1])
    if held == "stale":
        edge = ("1" if tagged == "(0.000,4.000,0.000)"
                else "frame" if f1 == "(0.000,4.000,0.000)" else "unbound")
    else:
        edge = "0" if held == "flushed" else "na"
    _ec_edge("keyframe", d, held, None, edge, ret=str(r),
             tagged_fresh=tagged, f1=f1, rna_y="%.3f" % ob.location[1])

    # explicit layered action build: DOES raise the relations tag -> edge=1
    ob2 = D.objects.new("o2", _ec_tri("m2"))
    scn.collection.objects.link(ob2)
    C.view_layer.update()
    dg2 = C.evaluated_depsgraph_get()
    ad2 = ob2.animation_data_create()
    pre2 = _ec_loc(ob2, dg2)
    h0 = _ec_snap()
    build = "?"
    try:
        act2 = D.actions.new("a2")
        try:
            slot = act2.slots.new(ob2.id_type, "o2")
            layer = act2.layers.new("L")
            strip = layer.strips.new(type='KEYFRAME')
            cbag = strip.channelbags.new(slot=slot)
            fc2 = cbag.fcurves.new("location", index=2)
        except Exception:
            fc2 = act2.fcurves.new("location", index=2)
            slot = None
        fc2.keyframe_points.insert(1, 8.0)
        ad2.action = act2
        if slot is not None:
            ad2.action_slot = slot
        build = "layered" if slot is not None else "legacy"
    except Exception as e:
        build = "ERR:" + type(e).__name__ + ":" + str(e)[:50]
    d = _ec_since(h0)
    post2 = _ec_loc(ob2, dg2)
    held2 = _ec_held(pre2, post2, d)
    fresh2 = _ec_loc(ob2, C.evaluated_depsgraph_get())
    _ec_edge("key_explicit", d, held2, None,
             _ec_edge1(held2, fresh2, "(0.000,0.000,8.000)"),
             build=build, held_loc=post2, fresh=fresh2)


# --------------------------------- evalcat sub-probe: constraint via RNA
def _ec_con_rna():
    _ec_reset()
    scn = C.scene
    tgt = D.objects.new("tgt", _ec_tri("tm"))
    scn.collection.objects.link(tgt)
    tgt.location = (3.0, 0.0, 0.0)
    ob, dg0 = _ec_settle()                           # settle AFTER tgt exists
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    pre = _ec_mw(ob, dg0)
    h0 = _ec_snap()
    con = ob.constraints.new('COPY_LOCATION')
    con.target = tgt
    d = _ec_since(h0)
    post = _ec_mw(ob, dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_mw(ob, C.evaluated_depsgraph_get())
    _ec_edge("con_rna", d, held, None,
             _ec_edge1(held, fresh, "(3.000,0.000,0.000)"),
             held_mw=post, fresh=fresh, rna_n=len(ob.constraints))
    C.view_layer.update()
    emit("evalcat", "con_rna_wU", "DEG", held_mw=_ec_mw(ob, dg0),
         rna_mw=v3(ob.matrix_world.translation))


# ---------------------------------------- evalcat sub-probe: bpy.ops edges
def _ec_op_apply():
    _ec_reset()
    ob, dg0 = _ec_settle()
    _ec_activate(ob)
    ob.location = (5.0, 0.0, 0.0)                    # RNA write pre-op
    pre = _ec_verts(ob, dg0)
    h0 = _ec_snap()
    try:
        with C.temp_override(object=ob, active_object=ob,
                             selected_objects=[ob],
                             selected_editable_objects=[ob]):
            r = bpy.ops.object.transform_apply(location=True,
                                               rotation=False, scale=False)
        ret = _ec_opret(r)
    except Exception as e:
        ret = "ERR:" + type(e).__name__ + ":" + str(e)[:60]
    d = _ec_since(h0)
    post = _ec_verts(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("op_apply", d, held, "bpy.ops", _ec_op_edge(held),
             ret=ret, held_mesh=post, held_loc=_ec_loc(ob, dg0),
             rna_loc=v3(ob.location))


def _ec_op_add():
    _ec_reset()
    ob, dg0 = _ec_settle()
    pre = _ec_names(dg0)
    h0 = _ec_snap()
    try:
        r = bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 3.0))
        ret = _ec_opret(r)
    except Exception as e:
        ret = "ERR:" + type(e).__name__ + ":" + str(e)[:60]
    d = _ec_since(h0)
    post = _ec_names(dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("op_add", d, held, "bpy.ops", _ec_op_edge(held),
             ret=ret, held_names=post, rna_n=len(D.objects))
    emit("evalcat", "op_add_fresh", "DEG",
         names=_ec_names(C.evaluated_depsgraph_get()))


def _ec_op_modapply():
    _ec_reset()
    ob, dg0 = _ec_settle(_ec_grid())
    _ec_activate(ob)
    mod = ob.modifiers.new("subd", 'SUBSURF')        # RNA write, stays stale
    mod.subdivision_type = 'SIMPLE'
    mod.levels = 1
    pre = _ec_verts(ob, dg0)
    emit("evalcat", "op_modapply_w0", "DEG", held=pre,
         rna_verts=len(ob.data.vertices))
    h0 = _ec_snap()
    try:
        with C.temp_override(object=ob, active_object=ob,
                             selected_objects=[ob]):
            r = bpy.ops.object.modifier_apply(modifier="subd")
        ret = _ec_opret(r)
    except Exception as e:
        ret = "ERR:" + type(e).__name__ + ":" + str(e)[:60]
    d = _ec_since(h0)
    post = _ec_verts(ob, dg0)
    held = _ec_held(pre, post, d)
    _ec_edge("op_modapply", d, held, "bpy.ops", _ec_op_edge(held),
             ret=ret, held_mesh=post, rna_verts=len(ob.data.vertices),
             rna_mods=len(ob.modifiers))


def _ec_op_modes():
    _ec_reset()
    ob, dg0 = _ec_settle()
    _ec_activate(ob)
    ob.location = (5.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    try:
        with C.temp_override(object=ob, active_object=ob,
                             selected_objects=[ob]):
            h0 = _ec_snap()
            r1 = bpy.ops.object.mode_set(mode='EDIT')
            d1 = _ec_since(h0)
            post1 = _ec_loc(ob, dg0)
            held1 = _ec_held(pre, post1, d1)
            _ec_edge("op_mode_edit", d1, held1, "bpy.ops",
                     _ec_op_edge(held1), ret=_ec_opret(r1), held_loc=post1)

            h0 = _ec_snap()
            r2 = bpy.ops.object.mode_set(mode='OBJECT')
            d2 = _ec_since(h0)
            post2 = _ec_loc(ob, dg0)
            held2 = _ec_held(post1, post2, d2)
            _ec_edge("op_mode_object", d2, held2, "bpy.ops",
                     _ec_op_edge(held2), ret=_ec_opret(r2), held_loc=post2)

            h0 = _ec_snap()
            r3 = bpy.ops.object.location_clear()
            d3 = _ec_since(h0)
            post3 = _ec_loc(ob, dg0)
            held3 = _ec_held(post2, post3, d3)
            _ec_edge("op_locclear", d3, held3, "bpy.ops",
                     _ec_op_edge(held3), ret=_ec_opret(r3), held_loc=post3,
                     rna_loc=v3(ob.location))
    except Exception as e:
        emit("evalcat", "op_modes", "ERR",
             err=type(e).__name__ + ":" + str(e)[:80])


def _ec_op_conadd():
    _ec_reset()
    scn = C.scene
    tgt = D.objects.new("tgt", _ec_tri("tm"))
    scn.collection.objects.link(tgt)
    tgt.location = (3.0, 0.0, 0.0)
    ob, dg0 = _ec_settle()
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    _ec_activate(ob)
    pre = _ec_mw(ob, dg0)
    h0 = _ec_snap()
    try:
        with C.temp_override(object=ob, active_object=ob,
                             selected_objects=[ob]):
            r = bpy.ops.object.constraint_add(type='COPY_LOCATION')
        ret = _ec_opret(r)
    except Exception as e:
        ret = "ERR:" + type(e).__name__ + ":" + str(e)[:60]
    d = _ec_since(h0)
    post = _ec_mw(ob, dg0)
    held = _ec_held(pre, post, d)   # constraint inert w/o target: undiscriminating
    _ec_edge("op_conadd", d, held, "bpy.ops", _ec_op_edge(held),
             ret=ret, held_mw=post, rna_n=len(ob.constraints))

    # the RNA target write after the op is still a bare edge=1 write:
    # the op's auto-eval does not leave the graph permanently live
    pre = _ec_mw(ob, dg0)
    h0 = _ec_snap()
    con = ob.constraints[-1]
    con.target = tgt
    d = _ec_since(h0)
    post = _ec_mw(ob, dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_mw(ob, C.evaluated_depsgraph_get())
    _ec_edge("conadd_target", d, held, None,
             _ec_edge1(held, fresh, "(3.000,0.000,0.000)"),
             held_mw=post, fresh=fresh)


# --------------------------------------- evalcat sub-probe: wall-time axis
def _ec_walltime():
    """No wall-time drain under -b -P: sleeps + context re-touch never
    flush a held handle (frontier closed this axis at 0.5/2.0/1.0s)."""
    _ec_reset()
    ob, dg0 = _ec_settle()
    ob.location = (6.0, 0.0, 0.0)
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    for i, dt in enumerate((0.5, 2.0, 1.0)):
        time.sleep(dt)
        emit("evalcat", "walltime_s%d" % i, "DEG", dt=dt,
             held=_ec_loc(ob, dg0))
    _ = C.scene.frame_current
    _ = bpy.context.view_layer
    post = _ec_loc(ob, dg0)
    d = _ec_since(h0)
    held = _ec_held(pre, post, d)
    _ec_edge("walltime", d, held, None,
             "absent" if held == "stale" else held, held_loc=post)
    emit("evalcat", "walltime_fresh", "DEG",
         loc=_ec_loc(ob, C.evaluated_depsgraph_get()))


# ======================================================== r81: evalcat ext
# Round-81 fold (r80-critic fold-guidance): six representative bare classes
# from the measured-inert sweeps join the tracked catalogue, chosen from the
# critic's list -- scene-prop write, hierarchy link, data swap, parent
# write, objects.remove, orphans_purge. Same witness discipline: fresh
# factory scene + handler reinstall per sub-probe; held dg0 captured before
# the mutation; every fixture built OUTSIDE the witness window (r81 critic
# measured an in-window settle firing dpre/dpost -> spurious FALSIFIED).
# All six stay under the `closed` falsifier: a bare row that flushes held
# or fires a watched handler is auto-emitted edge=FALSIFIED and counted.
def _ec_x_frame_current():
    """scene-prop write: `scn.frame_current = 2` (RNA write, not frame_set)
    is silent at w0; the next tagged get binds the frame-dependent value
    with dup firing and fc NEVER firing (closes r80-boundary unknown (a))."""
    _ec_reset()
    scn = C.scene
    ob, _ = _ec_settle()
    scn.frame_set(1)
    ob.location = (0.0, 0.0, 0.0)
    ob.keyframe_insert("location", index=1, frame=1)
    scn.frame_set(2)
    ob.location = (0.0, 4.0, 0.0)
    ob.keyframe_insert("location", index=1, frame=2)
    scn.frame_set(1)
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    scn.frame_current = 2                     # the bare scene-prop write
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    h1 = _ec_snap()
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext_frame_current", d, held, None,
             _ec_edge1(held, fresh, "(0.000,4.000,0.000)"),
             frame=int(scn.frame_current), held_loc=post, fresh_loc=fresh,
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x_hier_link():
    """hierarchy link: `scene.collection.children.link(orphan col)` is
    RNA-visible at w0 while the held dg0 still serves the pre-link set."""
    _ec_reset()
    scn = C.scene
    ob, dg0 = _ec_settle()
    col2 = D.collections.new("c2")
    n = D.objects.new("n", _ec_tri("m2"))
    col2.objects.link(n)                      # orphan col, built pre-window
    pre = _ec_names(dg0)
    h0 = _ec_snap()
    scn.collection.children.link(col2)
    d = _ec_since(h0)
    post = _ec_names(dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_names(C.evaluated_depsgraph_get())
    _ec_edge("ext_hier_link", d, held, None,
             _ec_edge1(held, fresh, "n|o"),
             held_names=post, fresh_names=fresh,
             rna_child=str(col2.name in
                           [c.name for c in scn.collection.children]),
             rna_n=int(n.name in [o.name for o in scn.objects]))


def _ec_x_data_swap():
    """data swap: `ob.data = grid16` -- the held evaluated mesh keeps the
    old data until eval; the RNA vertex count flips immediately (tier 0)."""
    _ec_reset()
    ob, dg0 = _ec_settle()
    me2 = _ec_grid()                          # built pre-window
    pre = _ec_verts(ob, dg0)
    h0 = _ec_snap()
    ob.data = me2
    d = _ec_since(h0)
    post = _ec_verts(ob, dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_verts(ob, C.evaluated_depsgraph_get())
    _ec_edge("ext_data_swap", d, held, None,
             _ec_edge1(held, fresh, "verts16:xmax1.000"),
             held_mesh=post, fresh_mesh=fresh,
             rna_verts=len(ob.data.vertices))


def _ec_x_parent_write():
    """parent write: `ob.parent = tgt` -- held mw stays pre-parent, the
    fresh get binds tgt's offset. RNA matrix_world sampled AT w0 (pre-eval)
    is itself stale (tier-1 prop): the r81 scout sampling trap."""
    _ec_reset()
    scn = C.scene
    tgt = D.objects.new("tgt", _ec_tri("tm"))
    scn.collection.objects.link(tgt)
    tgt.location = (3.0, 0.0, 0.0)
    ob, dg0 = _ec_settle()                    # settle AFTER tgt exists
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    pre = _ec_mw(ob, dg0)
    h0 = _ec_snap()
    ob.parent = tgt
    d = _ec_since(h0)
    rna_mw_w0 = v3(ob.matrix_world.translation)   # sampled AT w0, pre-eval
    post = _ec_mw(ob, dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_mw(ob, C.evaluated_depsgraph_get())
    _ec_edge("ext_parent_write", d, held, None,
             _ec_edge1(held, fresh, "(3.000,0.000,0.000)"),
             held_mw=post, fresh_mw=fresh,
             rna_parent=str(ob.parent.name), rna_mw_w0=rna_mw_w0)


def _ec_x_obj_remove():
    """objects.remove: destructive ID removal -- the held dg0 still
    enumerates the freed object (freed-ID read: stable on this build,
    noted fragile); the RNA collection drops it at w0."""
    _ec_reset()
    scn = C.scene
    ob, _ = _ec_settle()
    keep = D.objects.new("keep", _ec_tri("mk"))
    scn.collection.objects.link(keep)
    C.view_layer.update()                     # victim + control settled
    dg0 = C.evaluated_depsgraph_get()         #   BEFORE the window
    pre = _ec_names(dg0)
    h0 = _ec_snap()
    D.objects.remove(ob)
    d = _ec_since(h0)
    post = _ec_names(dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_names(C.evaluated_depsgraph_get())
    _ec_edge("ext_obj_remove", d, held, None,
             _ec_edge1(held, fresh, "keep"),
             held_names=post, fresh_names=fresh,
             rna_objs="|".join(sorted(o.name for o in D.objects)))


def _ec_x_orphan_purge():
    """orphans_purge: data-layer destruction -- the 0-user mesh is dropped
    at w0 while the depsgraph witness is non-discriminating (o->o). No eval
    event exists on this axis -> edge=absent (label extended to the
    data-layer axis per the r81-scout label gap; the data-layer counts are
    the discriminating witnesses)."""
    _ec_reset()
    ob, dg0 = _ec_settle()
    _ = _ec_tri("orphan")                     # unlinked, 0 users, pre-window
    pre_n = len(D.meshes)
    pre = _ec_names(dg0)
    h0 = _ec_snap()
    n_purged = D.orphans_purge()
    d = _ec_since(h0)
    post_n = len(D.meshes)
    post = _ec_names(dg0)
    held = _ec_held(pre, post, d)
    fresh = _ec_names(C.evaluated_depsgraph_get())
    _ec_edge("ext_orphan_purge", d, held, None,
             "absent" if held == "stale" else held,
             purged=int(n_purged), rna_meshes_before=pre_n,
             rna_meshes_after=post_n, held_names=post, fresh_names=fresh)


# ===================================================== r82: evalcat fold 2
# Round-82 residual fold: the r80-critic fold list's uncovered remainder,
# pre-measured by r82-scout (corpus/live/r82-scout/r82_classes_probe.py,
# runs/classes a+b identical) and independently by r82-critic. Same witness
# discipline as the r81 fold: fresh factory scene + handler reinstall per
# sub-probe; fixtures built OUTSIDE the witness window; pending RNA writes
# land PRE-window so the window holds only the class action; the held dg0
# is captured pre-window. All six EDGE rows are bare (invoked=None) and run
# inside arm_evalcat before `closed`, so any flush/handler fire is
# auto-emitted edge=FALSIFIED and counted. The two DEG side cells are
# documentary (name-vs-behavior / refused-enum edges), not falsifier rows.
def _ec_all_names(dg):
    try:
        return "|".join(sorted(i.object.name for i in dg.object_instances))
    except Exception as e:
        return "ERR:" + type(e).__name__


def _ec_inst_count(dg):
    try:
        return sum(1 for i in dg.object_instances if i.is_instance)
    except Exception:
        return -1


def _ec_in_dg(dg, ob):
    """Name-membership precondition (pointer equality against i.object is
    unreliable: instances expose the evaluated copy)."""
    try:
        return str(ob.name in [i.object.name for i in dg.object_instances])
    except Exception:
        return "ERR"


def _ec_x2_update_tag():
    """update_tag: tag != eval -- the purest discriminating witness.
    Pending RNA write lands PRE-window; the window holds only
    ob.update_tag(). held must stay stale with zero deltas; the next
    tagged get binds the pending write (get_dup=1, fc NEVER fires)."""
    _ec_reset()
    ob, dg0 = _ec_settle()
    ob.location = (5.0, 0.0, 0.0)              # pending, pre-window
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    ob.update_tag()                            # the class action
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    h1 = _ec_snap()
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_update_tag_obj", d, held, None,
             _ec_edge1(held, fresh, "(5.000,0.000,0.000)"),
             held_loc=post, fresh_loc=fresh,
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_custom_matrix_world():
    """Custom setter class (matrix_world): the setter decomposes into
    loc/rot/scale RNA writes and tags the object internally. held stays
    stale; the RNA read is immediate; the tagged get binds."""
    from mathutils import Matrix
    _ec_reset()
    ob, dg0 = _ec_settle()
    pre = _ec_loc(ob, dg0)
    h0 = _ec_snap()
    ob.matrix_world = Matrix.Translation((3.0, 0.0, 0.0))
    d = _ec_since(h0)
    rna_loc = v3(ob.location)                  # tier-0 read, immediate
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    h1 = _ec_snap()
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_custom_matrix_world", d, held, None,
             _ec_edge1(held, fresh, "(3.000,0.000,0.000)"),
             held_loc=post, fresh_loc=fresh, rna_loc=rna_loc,
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_libraries_load():
    """Data-layer class (libraries.load, link=True): a .blend is written
    pre-window, then a linked object is pulled in + scene-linked. The RNA
    collection gains it at w0; the held dg0 does not know it; the tagged
    get serves it."""
    import tempfile
    _ec_reset()
    path = os.path.join(tempfile.mkdtemp(), "r82_lib_load.blend")
    src_ob = D.objects.new("libo", _ec_tri("libm"))  # built pre-window
    D.libraries.write(path, {src_ob})
    _ec_reset()                                    # fresh scene, same lib
    ob, dg0 = _ec_settle()
    ob.location = (4.0, 0.0, 0.0)              # pending, pre-window
    pre = _ec_loc(ob, dg0)
    pre_names = _ec_names(dg0)
    h0 = _ec_snap()
    with D.libraries.load(path, link=True) as (src, dst):
        dst.objects = list(src.objects)
    loaded = D.objects["libo"]
    C.scene.collection.objects.link(loaded)
    d = _ec_since(h0)
    post = _ec_loc(ob, dg0)
    held = _ec_held(pre, post, d)
    held_names = _ec_names(dg0)
    h1 = _ec_snap()
    fresh = _ec_loc(ob, C.evaluated_depsgraph_get())
    fresh_names = _ec_names(C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_libraries_load", d, held, None,
             _ec_edge1(held, fresh, "(4.000,0.000,0.000)"),
             held_loc=post, fresh_loc=fresh,
             pre_names=pre_names, held_names=held_names,
             fresh_names=fresh_names,
             rna_lib=str(loaded.library is not None),
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_instance_empty():
    """Relations class (instance_empty / instance_collection): an Empty
    switched to COLLECTION-instance of an orphan collection. Held dg0 does
    not see the instanced child; the fresh graph carries is_instance=True."""
    _ec_reset()
    scn = C.scene
    col = D.collections.new("ic")                  # orphan, pre-window
    src = D.objects.new("ic_o", _ec_tri("icm"))
    col.objects.link(src)
    e = D.objects.new("inst", None)                # Empty accepts COLLECTION
    scn.collection.objects.link(e)
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    e.location = (2.0, 0.0, 0.0)                   # pending, pre-window
    pre = _ec_loc(e, dg0)
    held_inst_pre = _ec_inst_count(dg0)
    h0 = _ec_snap()
    e.instance_type = "COLLECTION"
    e.instance_collection = col
    d = _ec_since(h0)
    post = _ec_loc(e, dg0)
    held = _ec_held(pre, post, d)
    held_inst_post = _ec_inst_count(dg0)
    held_all = _ec_all_names(dg0)
    h1 = _ec_snap()
    fresh = _ec_loc(e, C.evaluated_depsgraph_get())
    fresh_inst = _ec_inst_count(C.evaluated_depsgraph_get())
    fresh_all = _ec_all_names(C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_instance_empty", d, held, None,
             _ec_edge1(held, fresh, "(2.000,0.000,0.000)"),
             held_loc=post, fresh_loc=fresh,
             held_inst_pre=held_inst_pre, held_inst_post=held_inst_post,
             fresh_inst=fresh_inst,
             held_all=held_all, fresh_all=fresh_all,
             rna_type=str(e.instance_type),
             rna_coll=str(e.instance_collection.name
                          if e.instance_collection else "none"),
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_instance_refused():
    """Documentary side cell (DEG layer, outside the EDGE catalogue): mesh
    objects refuse instance_type='COLLECTION' on this build ("Only empty
    objects support collection instances") -- the enum assignment raises
    TypeError, the collection assignment is then a no-op write."""
    _ec_reset()
    col = D.collections.new("ic2")
    ob, dg0 = _ec_settle()
    h0 = _ec_snap()
    # The enum rejection ALSO prints a C-level "reports | ERROR" line to
    # fd1 with an uptime timestamp -- it bypasses the (buffered) print()
    # path and would jitter the receipt's raw stdout, so the two
    # assignments run under a bounded fd1->devnull redirect. The C stdio
    # buffer is flushed FIRST so already-pending C bytes (the startup
    # banner) land on fd1 before the redirect can swallow them. Python
    # emit() bytes are buffered and unaffected; fd1 is restored in
    # finally.
    try:
        import ctypes
        ctypes.CDLL("libc.so.6").fflush(None)   # land pending C stdout bytes
    except Exception:
        pass
    _fd1 = os.dup(1)
    try:
        _dn = os.open(os.devnull, os.O_WRONLY)
        os.dup2(_dn, 1)
        os.close(_dn)
        try:
            ob.instance_type = "COLLECTION"
            step1 = "ok"
        except Exception as exc:
            step1 = ("ERR:" + type(exc).__name__ + ":"
                     + str(exc)[:60]).replace(" ", "_")
        try:
            ob.instance_collection = col
            step2 = "ok"
        except Exception as exc:
            step2 = ("ERR:" + type(exc).__name__ + ":"
                     + str(exc)[:40]).replace(" ", "_")
    finally:
        os.dup2(_fd1, 1)
        os.close(_fd1)
    type_after = str(ob.instance_type)
    coll_after = str(ob.instance_collection.name
                     if ob.instance_collection else "none")
    d = _ec_since(h0)
    emit("evalcat", "ext2_instance_refused", "DEG",
         step1=step1, step2=step2,
         type_after=type_after, coll_after=coll_after,
         dpre=d["pre"], dpost=d["post"], dfcp=d["fcp"], dfc=d["fc"])


def _ec_x2_batch_remove():
    """Destructive batch class: bpy.data.batch_remove([live ids]). The
    witness rides a separate ctl object (subjects are freed); the held dg0
    still enumerates the freed IDs (freed-ID read -- stable on this build,
    fragile; r82-critic measured a SEGFAULT when batch_remove is applied to
    stale/already-freed references -- only live IDs are removed here)."""
    _ec_reset()
    scn = C.scene
    ob, _ = _ec_settle()
    ob2 = D.objects.new("o2", _ec_tri("m2"))
    scn.collection.objects.link(ob2)
    ctl = D.objects.new("ctl", _ec_tri("mc"))
    scn.collection.objects.link(ctl)
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()
    ctl.location = (5.0, 0.0, 0.0)             # witness pending, pre-window
    pre = _ec_loc(ctl, dg0)
    pre_names = _ec_names(dg0)
    h0 = _ec_snap()
    ret = D.batch_remove([ob, ob2])            # the class action
    d = _ec_since(h0)
    post = _ec_loc(ctl, dg0)
    held = _ec_held(pre, post, d)
    held_names = _ec_names(dg0)
    h1 = _ec_snap()
    fresh = _ec_loc(ctl, C.evaluated_depsgraph_get())
    fresh_names = _ec_names(C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_batch_remove", d, held, None,
             _ec_edge1(held, fresh, "(5.000,0.000,0.000)"),
             held_loc=post, fresh_loc=fresh,
             ret_type=type(ret).__name__,
             pre_names=pre_names, held_names=held_names,
             fresh_names=fresh_names,
             rna_objs="|".join(sorted(o.name for o in D.objects)),
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_evalget_unlinked():
    """evaluated_get on a stale ID -- the name-vs-behavior edge: an object
    NOT in the held graph returns the ORIGINAL object (same_id=True) whose
    .location is the RNA value (fresh-looking, un-evaluated); the linked
    control on the same held handle returns the evaluated copy (stale)."""
    _ec_reset()
    scn = C.scene
    ob = D.objects.new("og", _ec_tri("mg"))        # will leave the graph
    ctl = D.objects.new("ctl", _ec_tri("mc"))      # linked control
    scn.collection.objects.link(ob)
    scn.collection.objects.link(ctl)
    C.view_layer.update()
    scn.collection.objects.unlink(ob)              # out-of-graph ID
    C.view_layer.update()
    dg0 = C.evaluated_depsgraph_get()              # graph WITHOUT og
    og_in_dg = _ec_in_dg(dg0, ob)
    ctl_in_dg = _ec_in_dg(dg0, ctl)
    ob.location = (4.0, 0.0, 0.0)              # pending, pre-window
    ctl.location = (7.0, 0.0, 0.0)             # control pending, pre-window
    pre_ctl = _ec_loc(ctl, dg0)
    h0 = _ec_snap()
    try:
        ev = ob.evaluated_get(dg0)             # the class action
        og_same = bool(ev == ob)
        og_loc = v3(ev.location)
        og_name = str(ev.name)
        og_err = "none"
    except Exception as exc:
        og_same, og_loc, og_name = "na", "na", "na"
        og_err = type(exc).__name__ + ":" + str(exc)[:60]
    evc = ctl.evaluated_get(dg0)               # linked control, same handle
    ctl_same = bool(evc == ctl)
    ctl_loc = v3(evc.location)
    d = _ec_since(h0)
    post_ctl = _ec_loc(ctl, dg0)
    held = _ec_held(pre_ctl, post_ctl, d)
    h1 = _ec_snap()
    fresh_ctl = _ec_loc(ctl, C.evaluated_depsgraph_get())
    d2 = _ec_since(h1)
    _ec_edge("ext2_evalget_unlinked", d, held, None,
             _ec_edge1(held, fresh_ctl, "(7.000,0.000,0.000)"),
             held_loc=post_ctl, fresh_loc=fresh_ctl,
             og_in_dg=og_in_dg, ctl_in_dg=ctl_in_dg,
             og_same_id=og_same, og_ev_loc=og_loc, og_ev_name=og_name,
             og_err=og_err, og_rna_loc=v3(ob.location),
             ctl_same_id=ctl_same, ctl_ev_loc=ctl_loc,
             get_dup=d2["post"], get_fc=d2["fc"])


def _ec_x2_evalget_freed():
    """Documentary side cell (DEG layer, outside the EDGE catalogue):
    evaluated_get on a FREED ID -- the name-read failure mode on this
    build is ReferenceError (r82-critic: applying the *removal* to stale
    references can segfault; only the post-removal READ is probed here)."""
    _ec_reset()
    ob, dg0 = _ec_settle()
    D.objects.remove(ob)
    h0 = _ec_snap()
    try:
        ev = ob.evaluated_get(dg0)
        res = "ok"
        ev_loc = v3(ev.location)
        ev_name = str(ev.name)
    except Exception as exc:
        res = "ERR:" + type(exc).__name__
        ev_loc, ev_name = "na", "na"
    d = _ec_since(h0)
    emit("evalcat", "ext2_evalget_freed", "DEG",
         res=res, ev_loc=ev_loc, ev_name=ev_name,
         dpre=d["pre"], dpost=d["post"], dfcp=d["fcp"], dfc=d["fc"])


# --------------------------------------------------------- arm: evalcat
def arm_evalcat():
    """One arm, per-class edge rows: every sub-probe gets a fresh factory
    scene + handler reinstall. A FALSIFIED edge row (or a nonzero
    `closed` violations count) is the claim's refutation surface."""
    # r82 H1 (hazard cell, not a falsifier row): a forged `violations=0`
    # row injected mid-stream -- it lands BEFORE the genuine trailing
    # `closed` row, so parse_arms' physical last-wins keeps the real cell.
    # The battery pins the demonstrated resolution: forgery visible in raw
    # bytes only; a forgery landing physically LAST would take the cell.
    emit("evalcat", "closed", "EDGE", violations=0,
         forged="parent_midstream")
    for sp in (_ec_events, _ec_driver, _ec_keyframe, _ec_con_rna,
               _ec_op_apply, _ec_op_add, _ec_op_modapply, _ec_op_modes,
               _ec_op_conadd, _ec_walltime,
               # r81 fold: six representative bare classes appended to the
               # armed catalogue -- they run before `closed`, so a FALSIFIED
               # ext row still increments the violations counter.
               _ec_x_frame_current, _ec_x_hier_link, _ec_x_data_swap,
               _ec_x_parent_write, _ec_x_obj_remove, _ec_x_orphan_purge,
               # r82 residual fold: six more bare classes (r80-critic
               # remainder) + two documentary DEG side cells.
               _ec_x2_update_tag, _ec_x2_custom_matrix_world,
               _ec_x2_libraries_load, _ec_x2_instance_empty,
               _ec_x2_instance_refused, _ec_x2_batch_remove,
               _ec_x2_evalget_unlinked, _ec_x2_evalget_freed):
        try:
            sp()
        except Exception:
            emit("evalcat", sp.__name__, "FATAL",
                 err=traceback.format_exc()[:300].replace("\n", " | "))
    emit("evalcat", "closed", "EDGE",
         violations=EVALCAT_VIOLATIONS[0],
         events="|".join(EVALCAT_EVENTS))


# ===================================================== r81: reorder (X1)
# fd1-inheritance reorder, fabricated live. Under `blender -b -P` with a
# captured stdout the parent's print() path is block-buffered
# (line_buffering=False, write_through=False, isatty=False; buffer
# 131072 B -- r81 scout/critic receipts), so a spawned descendant that
# inherits fd1 commits its bytes BEFORE the parent's still-buffered ARM
# rows: prefix reordering of the ARM stream, a live hazard class for the
# battery's own parser (bpy_battery.py parse_arms: ^ARM-anchored,
# last-wins per (arm,point,layer) cell).
#
# Construction (r81 critic corrections applied):
#   * sys.stdout.flush() FIRST seals the prior rows' byte-prefix -- without
#     it the child's rows land at stream byte 0 and the r79/r80 prefix
#     chain silently drifts while case verdicts stay green.
#   * gluevictim: first buffered row after the flush is a deliberate
#     casualty -- the child's unterminated tail splices onto it; the parser
#     must DROP that merged line (^ARM fails), not misattribute it.
#   * pre_spawn: emitted before the spawn but withheld in the buffer, so it
#     lands physically AFTER every child byte -- the discriminating
#     topology cell (False if fd1 is not block-buffered on this runtime).
#   * dup: the child's forged row lands first, the parent's post-spawn row
#     lands last -> pins the parser's physical last-wins tie-break.
#   * child_marker: a descendant's syntactically-valid ARM row parses to
#     its own cell -- the injection surface, attributed to child bytes.
# PYTHONUNBUFFERED does NOT collapse the window on bpy (r81 scout); only
# flush()/reconfigure(line_buffering=True) do. The battery-side
# order_checks are the per-runtime falsifier.
def arm_reorder():
    sys.stdout.flush()                        # seal prior rows' byte-prefix
    emit("reorder", "gluevictim", "FD1", who="parent",
         note="first-buffered-after-spawn")
    emit("reorder", "pre_spawn", "FD1", who="parent")
    rc = "spawnfail"
    try:
        rc = subprocess.run(
            ["/bin/sh", "-c",
             "printf 'ARM reorder | child_marker | FD1 | who=child\\n';"
             "printf 'ARM reorder | dup | FD1 | src=child_inj\\n';"
             "printf 'REORDERGLUE::'"]).returncode
    except Exception as e:
        emit("reorder", "spawn", "ERR",
             err=type(e).__name__ + ":" + str(e)[:60])
    emit("reorder", "dup", "FD1", src="parent")
    try:
        fd1_fifo = str(stat.S_ISFIFO(os.fstat(1).st_mode))
    except Exception:
        fd1_fifo = "na"
    emit("reorder", "post_spawn", "FD1", who="parent", child_rc=rc,
         line_buf=getattr(sys.stdout, "line_buffering", "na"),
         write_through=getattr(sys.stdout, "write_through", "na"),
         fd1_fifo=fd1_fifo)
    sys.stdout.flush()


# ============================================ r82: parser-hazard cells
# ARM-B probe side (xconnector X6): the residual parse_hazard cells pinned
# by the battery live in raw stdout / subprocess capture, which the CASES
# model cannot express -- so the probe emits only the cells that resolve
# through the tracked parse_arms. Hazard pins are CONTRACT pins: they
# document measured parser behavior, never safety claims.
def arm_hazards():
    """dup_flush: two same-key rows on one stream -- the physically LATER
    forged value wins the (arm, point, layer) cell (parse_arms is
    last-wins). Pinned as the CONTRACT: a later forged row silently
    rewrites the pinned row; documented, not hidden."""
    emit("hazard", "dup_flush", "PARSE", src="row1", v="first")
    emit("hazard", "dup_flush", "PARSE", src="row2_forged", v="forged")


for f in (arm_transform, arm_hide, arm_modifier, arm_collection,
          arm_membership, arm_draincheck, arm_shared, arm_fresh_handle,
          arm_vis_quirk, arm_evalcat, arm_reorder, arm_hazards):
    try:
        f()
    except Exception:
        print("ARM {} | FATAL | {}".format(f.__name__,
                                           traceback.format_exc()[:400]))
print("PROBE_DONE")
