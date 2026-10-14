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
                            or d["fcp"] or d["fc"] or d["und"]):
        edge = "FALSIFIED"
        EVALCAT_VIOLATIONS[0] += 1
    emit("evalcat", point, "EDGE", held=held, invoked=(invoked or "none"),
         dpre=d["pre"], dpost=d["post"], dfcp=d["fcp"], dfc=d["fc"],
         dund=d["und"], dup_fired=(d["post"] > 0),
         fc_fired=(d["fc"] > 0), edge=edge, **kw)


def _ec_edge1(held, fresh, expected):
    """Classify a bare-write row: stale + one tagged eval binds -> edge 1."""
    if held == "stale":
        return "1" if fresh == expected else "unbound"
    return "0" if held == "flushed" else "na"   # flush -> FALSIFIED below


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
        t0 = time.monotonic()
        time.sleep(dt)
        emit("evalcat", "walltime_s%d" % i, "DEG", dt=dt,
             held=_ec_loc(ob, dg0), slept="%.2f" % (time.monotonic() - t0))
    _ = C.scene.frame_current
    _ = bpy.context.view_layer
    post = _ec_loc(ob, dg0)
    d = _ec_since(h0)
    held = _ec_held(pre, post, d)
    _ec_edge("walltime", d, held, None,
             "absent" if held == "stale" else held, held_loc=post)
    emit("evalcat", "walltime_fresh", "DEG",
         loc=_ec_loc(ob, C.evaluated_depsgraph_get()))


# --------------------------------------------------------- arm: evalcat
def arm_evalcat():
    """One arm, per-class edge rows: every sub-probe gets a fresh factory
    scene + handler reinstall. A FALSIFIED edge row (or a nonzero
    `closed` violations count) is the claim's refutation surface."""
    for sp in (_ec_events, _ec_driver, _ec_keyframe, _ec_con_rna,
               _ec_op_apply, _ec_op_add, _ec_op_modapply, _ec_op_modes,
               _ec_op_conadd, _ec_walltime):
        try:
            sp()
        except Exception:
            emit("evalcat", sp.__name__, "FATAL",
                 err=traceback.format_exc()[:300].replace("\n", " | "))
    emit("evalcat", "closed", "EDGE",
         violations=EVALCAT_VIOLATIONS[0],
         events="|".join(EVALCAT_EVENTS))


for f in (arm_transform, arm_hide, arm_modifier, arm_collection,
          arm_membership, arm_draincheck, arm_shared, arm_fresh_handle,
          arm_vis_quirk, arm_evalcat):
    try:
        f()
    except Exception:
        print("ARM {} | FATAL | {}".format(f.__name__,
                                           traceback.format_exc()[:400]))
print("PROBE_DONE")
