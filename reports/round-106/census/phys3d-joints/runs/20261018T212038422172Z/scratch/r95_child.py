#!/usr/bin/env python3
"""r95 child probe — the Bullet/pybullet 3.2.7 physics lattice in headless
DIRECT/SHARED_MEMORY_SERVER mode, spawned per case by r95_bullet.gd:

    /usr/bin/python3 r95_child.py <case> <vendordir>

<vendordir> holds the pinned engine bytes
(r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so — the scout's venv build,
`strip --strip-debug`; sha in r95-author.md).  sys.path gets <vendordir> only:
no site-packages, no pip, no network.

Output contract (the parent scans for these prefixes):
    M0 case=<c> engine=.. api=.. py=.. build=".." dtBits=..   header, once
    M <c> <evidence>                                        evidence lines
    M DONE case=<c>                                         footer, once
    NEGATIVE REJECTED: r95_bullet <c> ..                      intended negative, exit 2
    ERROR: r95_child <c> ..                                   setup failure, exit 1
    # <line>                                                captured fd-2 diagnostics
Anything else on stdout/stderr counts against the digest's `o` surface (must
be 0).  BOTH fds are captured for the WHOLE process — the C++ build banner
and error paths write fd 2, but b3Warning refusals, solver-switch notices and
the SHM pump thread logs write fd 1 — and re-emitted as `#` lines, so the
process's whole print surface is pinned as a count (`d`), never verbatim
(build internals could name machine paths — they don't here, but the class
stays diagnostic-only).  Contract output goes through a duplicated fd of the
original stdout, which no engine print can reach.

Authored ONLY from claims that survived reports/round-95/r95-boundary.md, with
its corrections folded in:
  * every hash is the scout's state witness: sha256-16 over canonicalized
    IEEE-754 f64 bits of (pos, quat, linVel, angVel, bodyId) per body, NaN ->
    b"NAN", +-inf -> b"+INF"/b"-INF";
  * "no wall-clock path" is authored DIRECT-scoped only — `rt_*` cases pin
    DIRECT inertness, `shm_*`/`neg_shm_rt` pin the SHARED_MEMORY_SERVER
    correction (rt=1 pump live, stepped path non-reproducible: pinned as
    CLASSES `fell`/`distinct`/`pinFree`, never the moved distance or hashes);
  * `deterministicOverlappingPairs` neutrality is pinned 5-body-scene-scoped
    (`det_detpairs`); the 32-box pile pins the loud cross-scene contrast
    (`pile_lattice`);
  * bit-fixpoint is scene-dependent: `freeze_scene` never fixes (3000/3000),
    `freeze_ball` fixes at step 80 — both pinned;
  * equal *decimal* friction products are 1 ulp apart (`fr_bitexact` pins
    ulpEq=False); commutative products stay bit-exact;
  * the >=0 write gate is a NaN filter: NaN dropped, +inf stored
    (`nan_fields`/`fr_gate`/`nan_shape`);
  * sleep never fires on the createMultiBody path (analytics `iters=2`
    forever); `an=EMPTY` is the calibrated sleep signal (`sl_force_max`).
"""

import hashlib
import math
import os
import platform
import struct
import sys
import tempfile
import time

CASE = sys.argv[1] if len(sys.argv) > 1 else ""
VENDOR = (sys.argv[2] if len(sys.argv) > 2
          else os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "r95vendor"))

sys.dont_write_bytecode = True

# fd-1 + fd-2 capture for the whole process lifetime: b3Warning/b3Printf write
# to stdout, error paths to stderr, so BOTH are captured and re-emitted as '#'
# diagnostics.  All contract output goes through _real (a duplicate of the
# original stdout fd), which nothing else can reach.
_errbuf = tempfile.TemporaryFile(mode="w+b")
_real = os.fdopen(os.dup(1), "w", closefd=True)
os.dup2(_errbuf.fileno(), 1)
os.dup2(_errbuf.fileno(), 2)


def owrite(s):
    _real.write(s + "\n")
    _real.flush()


def diag(text):
    """explicit diagnostic line (measured, never pinned verbatim)."""
    owrite("# " + text)


if VENDOR:
    sys.path.insert(0, VENDOR)
try:
    import pybullet as p                      # noqa: E402
except Exception as _imp:                     # pragma: no cover
    owrite("ERROR: r95_child import pybullet failed: %s" % _imp)
    sys.exit(1)


class Reject(Exception):
    """Raised by negative cases once the naive claim is disproven."""


# --------------------------------------------------------------------------
# Witness plumbing — ported verbatim from corpus/live/r95-scout/probes.py
# (same canonicalization, so every hash here is comparable to the scout's
# pinned hashes byte-for-byte).
# --------------------------------------------------------------------------

G = -9.82
DT = 1.0 / 240.0
NBASE = 480          # 2.0 s
PIN_BASE = "02309c52da41ef33"


def fx(x):
    return f"{x:.9g}"


def bits(x):
    if math.isnan(x):
        return b"NAN"
    if math.isinf(x):
        return b"+INF" if x > 0 else b"-INF"
    return struct.pack(">d", x)


def raw(x):
    return struct.pack(">d", x).hex()


def cidkw(cid):
    return {"physicsClientId": cid}


def scene(cid, reverse=False):
    """Canonical scene (scout's): ground top face z=0, ball z=5, three boxes."""
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
    mk = [
        (0.0, g, [0, 0, -0.5]),
        (1.0, s, [0, 0, 5]),
        (1.0, b, [1.5, 0, 4]),
        (1.0, b, [-1.5, 0, 3]),
        (1.0, b, [0, 0, 2]),
    ]
    if reverse:
        mk = mk[::-1]
    ids = []
    for m, sh, pos in mk:
        ids.append(p.createMultiBody(m, sh, -1, pos, **cidkw(cid)))
    p.setGravity(0, 0, G, **cidkw(cid))
    return ids


def ball_only(cid, z=5.0):
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    ball = p.createMultiBody(1.0, s, -1, [0, 0, z], **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    return ball


def _ball(cid, z0=5.0, mx=False):
    """probes_ext version: mx=True -> maximal-coordinate btRigidBody."""
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    b = p.createMultiBody(1.0, s, -1, [0, 0, z0], useMaximalCoordinates=mx,
                          **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    return b


def state_hash(cid, n=None):
    if n is None:
        n = p.getNumBodies(**cidkw(cid))
    h = hashlib.sha256()
    for bid in range(n):
        pos, orn = p.getBasePositionAndOrientation(bid, **cidkw(cid))
        lv, av = p.getBaseVelocity(bid, **cidkw(cid))
        for x in pos + orn + lv + av:
            h.update(bits(x))
        h.update(struct.pack(">i", bid))
    return h.hexdigest()[:16]


def body_pos(cid, bid):
    return p.getBasePositionAndOrientation(bid, **cidkw(cid))[0]


def body_vel(cid, bid):
    return p.getBaseVelocity(bid, **cidkw(cid))


def ncontacts(cid):
    try:
        return len(p.getContactPoints(**cidkw(cid)))
    except Exception:
        return -1


def nan_scan(cid):
    """which body fields carry NaN/Inf; 'i.p+i.q+i.v+i.w' style."""
    where = []
    anynan = anyinf = False
    for bid in range(p.getNumBodies(**cidkw(cid))):
        pos, orn = p.getBasePositionAndOrientation(bid, **cidkw(cid))
        lv, av = p.getBaseVelocity(bid, **cidkw(cid))
        fields = [("p", pos), ("q", orn), ("v", lv), ("w", av)]
        for tag, vec in fields:
            if any(math.isnan(x) for x in vec):
                where.append(f"{bid}.{tag}")
                anynan = True
            if any(math.isinf(x) for x in vec):
                if f"{bid}.{tag}" not in where:
                    where.append(f"{bid}.{tag}")
                anyinf = True
    return anynan, anyinf, "+".join(where) if where else "none"


def run(cid, n):
    for _ in range(n):
        p.stepSimulation(**cidkw(cid))


def z(cid, bid):
    return body_pos(cid, bid)[2]


def try_or(fn, tag):
    try:
        return fn()
    except Exception as e:
        return f"threw:{type(e).__name__}:{str(e)[:80]}"


def _freeze_step(cid, bid, n_max=1400):
    """first step after which pos+vel bits never change again; -1 if none."""
    last = None
    changes = 0
    freeze_at = -1
    for i in range(1, n_max + 1):
        p.stepSimulation(**cidkw(cid))
        pos, orn = p.getBasePositionAndOrientation(bid, **cidkw(cid))
        lv, av = p.getBaseVelocity(bid, **cidkw(cid))
        key = hashlib.sha256(b"".join(bits(x) for x in pos + orn + lv + av)).hexdigest()
        if key == last:
            if freeze_at < 0:
                freeze_at = i
        else:
            freeze_at = -1
            changes += 1
        last = key
    return freeze_at, changes


def _row(r):
    """analytics tuple -> compact signature; EMPTY = no island processed."""
    if not r:
        return "EMPTY"
    return "+".join("i%s/n%d/it%d" % (d["islandId"], d["numBodies"],
                                      d["numIterationsUsed"]) for d in r)


def _rtflag(cid):
    return p.getPhysicsEngineParameters(**cidkw(cid)).get("useRealTimeSimulation", -1)


def _slide(cid, mu_ground, mu_body):
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[30, 10, 0.5], **cidkw(cid))
    b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    box = p.createMultiBody(1.0, b, -1, [0, 0, 0.51], **cidkw(cid))
    p.changeDynamics(0, -1, lateralFriction=mu_ground, **cidkw(cid))
    p.changeDynamics(box, -1, lateralFriction=mu_body, **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 30)
    p.resetBaseVelocity(box, linearVelocity=[5, 0, 0], angularVelocity=[0, 0, 0],
                        **cidkw(cid))
    run(cid, 600)
    return body_pos(cid, box)[0]


def _slide_hash(cid, mu_g, mu_b):
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[30, 10, 0.5], **cidkw(cid))
    bx = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5],
                                **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    box = p.createMultiBody(1.0, bx, -1, [0, 0, 0.51], **cidkw(cid))
    p.changeDynamics(0, -1, lateralFriction=mu_g, **cidkw(cid))
    p.changeDynamics(box, -1, lateralFriction=mu_b, **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 30)
    p.resetBaseVelocity(box, linearVelocity=[5, 0, 0], angularVelocity=[0, 0, 0],
                        **cidkw(cid))
    run(cid, 600)
    return body_pos(cid, box)[0], state_hash(cid)


def _pile(cid, nx=4, ny=4, nz=2, mx=False, reverse=False):
    """boundary's 32-box pile cell (128 resting contacts)."""
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    cells = [(i, j, k) for k in range(nz) for i in range(nx) for j in range(ny)]
    if reverse:
        cells = cells[::-1]
    ids = []
    for (i, j, k) in cells:
        pos = [(i - (nx - 1) / 2.0) * 1.02, (j - (ny - 1) / 2.0) * 1.02,
               0.5 + k * 1.02]
        ids.append(p.createMultiBody(1.0, b, -1, pos, useMaximalCoordinates=mx,
                                     **cidkw(cid)))
    p.setGravity(0, 0, G, **cidkw(cid))
    return ids


def _shm_client(rt):
    """one SHARED_MEMORY_SERVER in-process client; rt flag set before bodies."""
    cid = p.connect(p.SHARED_MEMORY_SERVER)
    if cid < 0:
        raise RuntimeError("SHARED_MEMORY_SERVER connect failed rc=%d" % cid)
    p.setRealTimeSimulation(rt, **cidkw(cid))
    time.sleep(0.05)   # let the pump thread's startup prints land
    return cid


def _shm_drop(cid):
    """disconnect an SHM client, letting its teardown prints land first."""
    p.disconnect(**cidkw(cid))
    time.sleep(0.05)


# ==========================================================================
# det — fixed-step determinism core (scout §1.1, all boundary-surviving)
# ==========================================================================

def c_det_base(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    ys = {}
    for i in range(1, NBASE + 1):
        p.stepSimulation(**cidkw(cid))
        if i in (1, 30, 60, 120, 240, 480):
            ys[i] = z(cid, 1)
    emit("base h=%s %s contacts=%d nan=%s" % (
        state_hash(cid),
        " ".join(f"z@{k}={fx(v)}" for k, v in ys.items()),
        ncontacts(cid), nan_scan(cid)[0]))


def c_det_rebuild(emit):
    cid = p.connect(p.DIRECT)
    ids1 = scene(cid)
    run(cid, NBASE)
    h1 = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    ids2 = scene(cid2)
    run(cid2, NBASE)
    h2 = state_hash(cid2)
    emit("rebuild h1=%s h2=%s eq=%s ids1=%s ids2=%s" % (
        h1, h2, h1 == h2, ",".join(map(str, ids1)), ",".join(map(str, ids2))))


def c_det_interleave(emit):
    cidA = p.connect(p.DIRECT)
    scene(cidA)
    run(cidA, 30)
    cidB = p.connect(p.DIRECT)
    scene(cidB)
    run(cidB, 30)
    hB = state_hash(cidB)
    run(cidA, NBASE - 30)
    hA = state_hash(cidA)
    cidC = p.connect(p.DIRECT)
    scene(cidC)
    run(cidC, 30)
    hC = state_hash(cidC)
    cidD = p.connect(p.DIRECT)
    scene(cidD)
    run(cidD, NBASE)
    hBase = state_hash(cidD)
    emit("interleave A=%s base=%s eqA=%s B=%s C=%s eqBC=%s" % (
        hA, hBase, hA == hBase, hB, hC, hB == hC))


def c_det_order(emit):
    """CORRECTED vs r94-cannon: creation order moves bits in Bullet."""
    cid = p.connect(p.DIRECT)
    scene(cid, reverse=False)
    run(cid, NBASE)
    hf = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    scene(cid2, reverse=True)
    run(cid2, NBASE)
    hr = state_hash(cid2)
    emit("order-probe h_forward=%s h_reverse=%s eq=%s" % (hf, hr, hf == hr))


def c_det_iters(emit):
    outs = []
    for it in (1, 50, 150):
        cid = p.connect(p.DIRECT)
        scene(cid)
        p.setPhysicsEngineParameter(numSolverIterations=it, **cidkw(cid))
        run(cid, NBASE)
        outs.append((it, state_hash(cid), z(cid, 1)))
        p.disconnect(**cidkw(cid))
    emit("iters " + " ".join(f"{i}:h={h},z={fx(v)}" for i, h, v in outs))


def c_det_iters0(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    p.setPhysicsEngineParameter(numSolverIterations=0, **cidkw(cid))
    run(cid, NBASE)
    nan, inf, wh = nan_scan(cid)
    emit("iters0 h=%s z=%s contacts=%d nan=%s inf=%s where=%s" % (
        state_hash(cid), fx(z(cid, 1)), ncontacts(cid), nan, inf, wh))


def c_det_substeps(emit):
    outs = []
    for n in (0, 4, 8):
        cid = p.connect(p.DIRECT)
        scene(cid)
        if n:
            p.setPhysicsEngineParameter(numSubSteps=n, **cidkw(cid))
        run(cid, NBASE)
        outs.append((n, state_hash(cid), z(cid, 1)))
        p.disconnect(**cidkw(cid))
    emit("substeps " + " ".join(f"n{n}:h={h},z={fx(v)}" for n, h, v in outs))


def c_det_detpairs(emit):
    """SCENE-SCOPED pin (boundary refinement): neutral in the 5-body scene."""
    outs = []
    for d in (0, 1):
        cid = p.connect(p.DIRECT)
        scene(cid)
        p.setPhysicsEngineParameter(deterministicOverlappingPairs=d, **cidkw(cid))
        run(cid, NBASE)
        outs.append((d, state_hash(cid)))
        p.disconnect(**cidkw(cid))
    emit("detpairs scene=5body " + " ".join(f"d{d}:h={h}" for d, h in outs) +
         " eq=%s" % (outs[0][1] == outs[1][1]))


def c_det_reset(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    run(cid, 120)
    p.resetSimulation(**cidkw(cid))
    scene(cid)
    run(cid, NBASE)
    h = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    scene(cid2)
    run(cid2, NBASE)
    h2 = state_hash(cid2)
    emit("reset h=%s h2=%s eq=%s" % (h, h2, h == h2))


def c_det_restore(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    run(cid, 120)
    sid = p.saveState(**cidkw(cid))
    run(cid, 120)
    h_mid = state_hash(cid)
    p.restoreState(stateId=sid, **cidkw(cid))
    h_restored = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    scene(cid2)
    run(cid2, 120)
    h_120 = state_hash(cid2)
    run(cid, 120)
    h_post = state_hash(cid)
    run(cid2, 120)
    h_240 = state_hash(cid2)
    emit("restore-state hRestored=%s h120=%s eqRestore=%s hPost=%s h240=%s eqPost=%s" % (
        h_restored, h_120, h_restored == h_120, h_post, h_240, h_post == h_240))


def c_det_perturb(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    cid2 = p.connect(p.DIRECT)
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid2))
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid2))
    bx = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid2))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid2))
    p.createMultiBody(1.0, s, -1, [0, 0, 5 + 1e-9], **cidkw(cid2))
    p.createMultiBody(1.0, bx, -1, [1.5, 0, 4], **cidkw(cid2))
    p.createMultiBody(1.0, bx, -1, [-1.5, 0, 3], **cidkw(cid2))
    p.createMultiBody(1.0, bx, -1, [0, 0, 2], **cidkw(cid2))
    p.setGravity(0, 0, G, **cidkw(cid2))
    rows = []
    for i in range(1, NBASE + 1):
        p.stepSimulation(**cidkw(cid))
        p.stepSimulation(**cidkw(cid2))
        if i in (20, 60, 120, 240, 360, 480):
            d = math.dist(body_pos(cid, 1), body_pos(cid2, 1))
            rows.append(f"{i}:{d:.3e}")
    emit("perturb-track mag=1e-9 " + " ".join(rows) +
         " heq=%s" % (state_hash(cid) == state_hash(cid2)))


def c_det_saturated(emit):
    """'resting' multi-body scene never bit-fixes (scout pass-2 correction)."""
    cid = p.connect(p.DIRECT)
    scene(cid)
    run(cid, 960)
    h960 = state_hash(cid)
    run(cid, 1)
    h961 = state_hash(cid)
    nan, inf, wh = nan_scan(cid)
    emit("steps-saturated h960=%s h961=%s eq=%s nan=%s" % (h960, h961, h960 == h961, nan))


def c_det_neutral(emit):
    """erp=0.9 and warmStartingFactor=0 are bit-neutral in this scene."""
    outs = []
    for k in (None, 0.9):
        cid = p.connect(p.DIRECT)
        scene(cid)
        if k is not None:
            p.setPhysicsEngineParameter(erp=k, **cidkw(cid))
        run(cid, NBASE)
        outs.append((k if k is not None else "def", state_hash(cid), z(cid, 1)))
        p.disconnect(**cidkw(cid))
    emit("erp " + " ".join(f"{k}:h={h},z={fx(v)}" for k, h, v in outs))
    outs = []
    for w in (None, 0.0):
        cid = p.connect(p.DIRECT)
        scene(cid)
        if w is not None:
            p.setPhysicsEngineParameter(warmStartingFactor=w, **cidkw(cid))
        run(cid, NBASE)
        outs.append((w if w is not None else "def", state_hash(cid), z(cid, 1)))
        p.disconnect(**cidkw(cid))
    emit("warmstart " + " ".join(f"{k}:h={h},z={fx(v)}" for k, h, v in outs))


# ==========================================================================
# freeze — bit-fixpoint is scene-dependent (boundary §5)
# ==========================================================================

def c_freeze_scene(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    last, first, changes = None, -1, 0
    for i in range(1, 3001):
        p.stepSimulation(**cidkw(cid))
        h = state_hash(cid)
        if h == last:
            if first < 0:
                first = i
        else:
            first = -1
            changes += 1
        last = h
    emit("freeze-scene steps=3000 changes=%d freezeStep=%d hFinal=%s" % (
        changes, first, last))


def c_freeze_ball(emit):
    cid = p.connect(p.DIRECT)
    b = _ball(cid, z0=1.0)
    last, first, changes = None, -1, 0
    for i in range(1, 1401):
        p.stepSimulation(**cidkw(cid))
        pos, orn = p.getBasePositionAndOrientation(b, **cidkw(cid))
        lv, av = p.getBaseVelocity(b, **cidkw(cid))
        h = hashlib.sha256(b"".join(bits(x) for x in pos + orn + lv + av)
                           ).hexdigest()[:16]
        if h == last:
            if first < 0:
                first = i
        else:
            first = -1
            changes += 1
        last = h
    emit("freeze-ball steps=1400 changes=%d freezeStep=%d" % (changes, first))


# ==========================================================================
# rt — wall-clock inertness, DIRECT-scoped (boundary correction: rt is dead
# in DIRECT only; the SHARED_MEMORY_SERVER correction lives in shm_*/neg_*)
# ==========================================================================

def c_rt_inert(emit):
    """canonical scene stepped explicitly: rt flag changes nothing in DIRECT."""
    hashes = {}
    for rt in (0, 1):
        cid = p.connect(p.DIRECT)
        scene(cid)
        p.setRealTimeSimulation(rt, **cidkw(cid))
        run(cid, NBASE)
        hashes[rt] = (state_hash(cid), _rtflag(cid))
        p.disconnect(**cidkw(cid))
    emit("rt-inert rt0:h=%s,flag=%s rt1:h=%s,flag=%s eq=%s" % (
        hashes[0][0], hashes[0][1], hashes[1][0], hashes[1][1],
        hashes[0][0] == hashes[1][0]))


def c_rt_idle(emit):
    """scout rt-idle verbatim: 0.6 s idle + 120 non-step API calls move nothing."""
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.setRealTimeSimulation(1, **cidkw(cid))
    z0 = z(cid, ball)
    time.sleep(0.6)
    z1 = z(cid, ball)
    for _ in range(120):
        p.getNumBodies(**cidkw(cid))
        time.sleep(0.004)
    z2 = z(cid, ball)
    emit("rt-idle flag=%s z0=%s z_after_0.6s_idle=%s z_after_120_api_calls=%s" % (
        _rtflag(cid), fx(z0), fx(z1), fx(z2)))


def c_rt_paced(emit):
    """boundary r95b_rt_long class: rt=1 + real sleeps between calls -> pin."""
    cid = p.connect(p.DIRECT)
    scene(cid)
    p.setRealTimeSimulation(1, **cidkw(cid))
    for i in range(NBASE):
        p.stepSimulation(**cidkw(cid))
        time.sleep(0.004)
    emit("rt-paced flag=%s h=%s eq=%s" % (
        _rtflag(cid), state_hash(cid), state_hash(cid) == PIN_BASE))


# ==========================================================================
# shm — SHARED_MEMORY_SERVER transport (boundary §2): physics-identical when
# stepped with rt=0; rt=1 pump is live and makes the stepped path
# non-reproducible.  Only CLASS fields are pinned there (fell/distinct/
# pinFree); measured values go to `#` diagnostics.
# ==========================================================================

def c_shm_step(emit):
    cid = _shm_client(0)
    scene(cid)
    run(cid, NBASE)
    h = state_hash(cid)
    emit("shm-step cid=%s rt=0 h=%s eqPin=%s" % (cid, h, h == PIN_BASE))
    _shm_drop(cid)


def c_shm_rtclass(emit):
    # (a) the wall-clock pump advances the world during a bare sleep — the
    # robustly-pinnable correction (boundary table row: SHM+rt=1 idle falls).
    cid = _shm_client(1)
    ball = ball_only(cid)
    z0 = z(cid, ball)
    time.sleep(2.0)
    z1 = z(cid, ball)
    fell = z1 < 5.0
    emit("shm-rt rtflag=%s idle2.0s fell=%s" % (_rtflag(cid), fell))
    diag("shm-rt measured z0=%s z1=%s" % (fx(z0), fx(z1)))
    # (b) the stepped path under rt=1 is load-dependently NON-reproducible:
    # the boundary saw 3 reps -> 3 hashes while this host replays the pin —
    # pump injection is a timing race, so stepped hashes stay '#' diagnostics.
    h1 = h2 = None
    for tag in ("w1", "w2"):
        c2 = _shm_client(1)
        scene(c2)
        run(c2, NBASE)
        h = state_hash(c2)
        diag("shm-rt %s stepped h=%s" % (tag, h))
        if tag == "w1":
            h1 = h
        else:
            h2 = h
        _shm_drop(c2)
    diag("shm-rt stepped distinct=%s pinFree=%d" % (
        h1 != h2, (h1 != PIN_BASE) + (h2 != PIN_BASE)))
    _shm_drop(cid)


# ==========================================================================
# sleep — nothing ever sleeps on the createMultiBody path (scout §2.4 + the
# pass-2 EMPTY calibration); measured pins only.
# ==========================================================================

def c_sl_iters(emit):
    cid = p.connect(p.DIRECT)
    p.setPhysicsEngineParameter(reportSolverAnalytics=1, **cidkw(cid))
    ball = ball_only(cid, z=1.0)
    rows = []
    for i in range(1, 1301):
        r = p.stepSimulation(**cidkw(cid))
        if i in (1, 60, 80, 120, 240, 480, 560, 600, 720, 960, 1200, 1300):
            ni = r[0]["numIterationsUsed"] if r else -1
            lv = body_vel(cid, ball)[0][2]
            rows.append("%d:iters=%s,v=%s,z=%s" % (i, ni, fx(lv), fx(z(cid, ball))))
    emit("sleep-default %s" % " ".join(rows))


def c_sl_velwrite(emit):
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    run(cid, 1200)
    zbefore = z(cid, ball)
    vbefore = body_vel(cid, ball)[0][2]
    p.resetBaseVelocity(ball, linearVelocity=[0, 0, 5], **cidkw(cid))
    vread = body_vel(cid, ball)[0][2]
    run(cid, 1)
    z1 = z(cid, ball)
    run(cid, 30)
    z2 = z(cid, ball)
    lv, av = body_vel(cid, ball)
    emit("sleep-velwrite zB=%s vB=%s vRead=%s z+1=%s z+31=%s v=%s" % (
        fx(zbefore), fx(vbefore), fx(vread), fx(z1), fx(z2), fx(lv[2])))


def c_sl_teleport(emit):
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    run(cid, 1200)
    zb = z(cid, ball)
    p.resetBasePositionAndOrientation(ball, [0, 0, 3.0], [0, 0, 0, 1], **cidkw(cid))
    zs = []
    for i in range(1, 121):
        p.stepSimulation(**cidkw(cid))
        if i in (1, 2, 10, 30, 60, 120):
            zs.append("%d:%s" % (i, fx(z(cid, ball))))
    emit("sleep-teleport zBefore=%s postTeleport %s" % (fx(zb), " ".join(zs)))


def c_sl_force_mb(emit):
    """reduced coords: forced SLEEP mid-air changes nothing (island still solved)."""
    cid = p.connect(p.DIRECT)
    p.setPhysicsEngineParameter(reportSolverAnalytics=1, **cidkw(cid))
    b = _ball(cid, z0=5.0)
    run(cid, 30)
    p.changeDynamics(b, -1, activationState=p.ACTIVATION_STATE_SLEEP, **cidkw(cid))
    rows = []
    for i in range(1, 121):
        r = p.stepSimulation(**cidkw(cid))
        if i in (1, 2, 5, 30, 60, 120):
            rows.append("%d:an=%s,z=%s,v=%s" % (i, _row(r), fx(z(cid, b)),
                                                fx(body_vel(cid, b)[0][2])))
    emit("sleep-force-mb " + " ".join(rows))
    # forced-rest + velocity write on a second body (scout's sleep-force tail)
    b2 = _ball(cid, z0=1.0)
    run(cid, 900)
    zb = z(cid, b2)
    p.changeDynamics(b2, -1, activationState=p.ACTIVATION_STATE_SLEEP, **cidkw(cid))
    p.resetBaseVelocity(b2, linearVelocity=[0, 0, 5], **cidkw(cid))
    p.stepSimulation(**cidkw(cid))
    z1 = z(cid, b2)
    run(cid, 30)
    emit("sleep-force forcedRest z=%s velwrite z+1=%s z+31=%s" % (
        fx(zb), fx(z1), fx(z(cid, b2))))


def c_sl_force_max(emit):
    """maximal coords: forced SLEEP -> island skipped (EMPTY) + body frozen.
    This is the calibration cell proving the analytics sleep signal is real."""
    cid = p.connect(p.DIRECT)
    p.setPhysicsEngineParameter(reportSolverAnalytics=1, **cidkw(cid))
    b = _ball(cid, z0=5.0, mx=True)
    run(cid, 30)
    p.changeDynamics(b, -1, activationState=p.ACTIVATION_STATE_SLEEP, **cidkw(cid))
    rows = []
    for i in range(1, 121):
        r = p.stepSimulation(**cidkw(cid))
        if i in (1, 2, 5, 30, 60, 120):
            rows.append("%d:an=%s,z=%s,v=%s" % (i, _row(r), fx(z(cid, b)),
                                                fx(body_vel(cid, b)[0][2])))
    emit("sleep-force-max " + " ".join(rows))


def c_sl_rest_max(emit):
    """maximal-coordinate resting body, 1400 steps: island solved every step."""
    cid = p.connect(p.DIRECT)
    p.setPhysicsEngineParameter(reportSolverAnalytics=1, **cidkw(cid))
    b = _ball(cid, z0=1.0, mx=True)
    rows = []
    for i in range(1, 1401):
        r = p.stepSimulation(**cidkw(cid))
        if i in (1, 80, 240, 480, 481, 600, 960, 1400):
            rows.append("%d:an=%s,z=%s,v=%s,cc=%d" % (
                i, _row(r), fx(z(cid, b)), fx(body_vel(cid, b)[0][2]),
                ncontacts(cid)))
    emit("sleep-rest-max " + " ".join(rows))


def c_sl_disable_pair(emit):
    """ACTIVATION_STATE_DISABLE_SLEEPING is byte-identical to default."""
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    fz, ch = _freeze_step(cid, ball, 1400)
    lv, av = body_vel(cid, ball)
    emit("sleep-freeze freezeStep=%d finalV=%s,%s z=%s" % (fz, fx(lv[2]), fx(av[2]), fx(z(cid, ball))))
    cid2 = p.connect(p.DIRECT)
    ball2 = ball_only(cid2, z=1.0)
    p.changeDynamics(ball2, -1, activationState=p.ACTIVATION_STATE_DISABLE_SLEEPING, **cidkw(cid2))
    fz2, ch2 = _freeze_step(cid2, ball2, 1400)
    lv2, av2 = body_vel(cid2, ball2)
    emit("sleep-disable freezeStep=%d finalV=%s z=%s eq=%s" % (
        fz2, fx(lv2[2]), fx(z(cid2, ball2)),
        (fz, fx(lv[2]), fx(av[2]), fx(z(cid, ball))) ==
        (fz2, fx(lv2[2]), fx(av2[2]), fx(z(cid2, ball2)))))


def c_sl_persist(emit):
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    rows = []
    prevz = None
    froze = -1
    for i in range(1, 1401):
        p.stepSimulation(**cidkw(cid))
        zz = z(cid, ball)
        if froze < 0 and prevz is not None and zz == prevz and i > 100:
            froze = i
        prevz = zz
        if i in (10, 120, 480, 720, 960, 1200, 1400):
            cp = p.getContactPoints(bodyA=ball, bodyB=0, **cidkw(cid))
            ds = [f"{fx(c[8])}" for c in cp]
            nf = [f"{fx(c[9])}" for c in cp]
            rows.append("s%d:cc=%d/d=%s/nf=%s" % (i, len(cp), ",".join(ds), ",".join(nf)))
    emit("sleep-contact-persist froze~%d %s" % (froze, " ".join(rows)))


def c_sl_stale(emit):
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    run(cid, 1200)
    cp1 = p.getContactPoints(bodyA=ball, bodyB=0, **cidkw(cid))
    p.resetBasePositionAndOrientation(0, [0, 0, -5.5], [0, 0, 0, 1], **cidkw(cid))
    cp2 = p.getContactPoints(bodyA=ball, bodyB=0, **cidkw(cid))
    cl = p.getClosestPoints(bodyA=ball, bodyB=0, distance=10.0, **cidkw(cid))
    run(cid, 1)
    cp3 = p.getContactPoints(bodyA=ball, bodyB=0, **cidkw(cid))
    znow = z(cid, ball)
    run(cid, 60)
    zafter = z(cid, ball)
    fmt = lambda cp: "n=%d d=%s" % (len(cp), ",".join(fx(c[8]) for c in cp))
    emit("stale-manifold pre{%s} postMove{%s} closest{%s} postStep{%s} zNow=%s z+60=%s" % (
        fmt(cp1), fmt(cp2), fmt(cl), fmt(cp3), fx(znow), fx(zafter)))


# ==========================================================================
# nan — degenerate inputs (scout §1.4 + pass-2 §2.9 Inf family)
# ==========================================================================

def c_nan_dt(emit):
    """dt lattice: negative/zero freeze, NaN/Inf poison (different widths)."""
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.setTimeStep(-DT, **cidkw(cid)), "setTimeStep")
    run(cid, 60)
    nan, inf, wh = nan_scan(cid)
    emit("neg-dt set=%s z=%s v=%s nan=%s inf=%s where=%s" % (
        ("ok" if r is None else r), fx(z(cid, ball)),
        fx(body_vel(cid, ball)[0][2]), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.setTimeStep(0.0, **cidkw(cid)), "setTimeStep")
    run(cid, 60)
    nan, inf, wh = nan_scan(cid)
    emit("zero-dt set=%s z=%s v=%s nan=%s inf=%s where=%s" % (
        ("ok" if r is None else r), fx(z(cid, ball)),
        fx(body_vel(cid, ball)[0][2]), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.setTimeStep(float("nan"), **cidkw(cid)), "setTimeStep")
    run(cid, 10)
    nan, inf, wh = nan_scan(cid)
    emit("nan-dt set=%s z=%s nan=%s inf=%s where=%s" % (
        ("ok" if r is None else r), fx(z(cid, ball)), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.setTimeStep(float("inf"), **cidkw(cid)), "setTimeStep")
    run(cid, 10)
    nan, inf, wh = nan_scan(cid)
    emit("inf-dt set=%s z=%s nan=%s inf=%s where=%s" % (
        ("ok" if r is None else r), fx(z(cid, ball)), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.setPhysicsEngineParameter(numSubSteps=-1, **cidkw(cid)), "nSub")
    run(cid, 60)
    emit("numsubsteps-neg set=%s z=%s h=%s" % (
        ("ok" if r is None else r), fx(z(cid, ball)), state_hash(cid)))


def c_nan_fields(emit):
    """gravity/pos/vel/quat poisoning, incl. the NaN-vs-Inf class split."""
    for tag, grav in (("nan", float("nan")), ("inf", float("inf"))):
        cid = p.connect(p.DIRECT)
        ball = ball_only(cid)
        p.setGravity(0, 0, grav, **cidkw(cid))
        run(cid, 10)
        nan, inf, wh = nan_scan(cid)
        emit("%s-gravity z=%s nan=%s inf=%s where=%s" % (
            tag, fx(z(cid, ball)), nan, inf, wh))
        p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.resetBasePositionAndOrientation(ball, [float("nan"), 0, 3], [0, 0, 0, 1], **cidkw(cid))
    run(cid, 10)
    nan, inf, wh = nan_scan(cid)
    emit("nan-pos nan=%s inf=%s where=%s" % (nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    try:
        b = p.createMultiBody(1.0, s, -1, [0, 0, float("inf")], **cidkw(cid))
        run(cid, 10)
        nan, inf, wh = nan_scan(cid)
        emit("inf-pos created=%s nan=%s inf=%s where=%s" % (b, nan, inf, wh))
    except Exception as e:
        emit("inf-pos threw=%s" % e)
    p.disconnect(**cidkw(cid))
    for tag, vx in (("nan", float("nan")), ("inf", float("inf"))):
        cid = p.connect(p.DIRECT)
        ball = ball_only(cid)
        p.setGravity(0, 0, 0, **cidkw(cid))
        p.resetBaseVelocity(ball, linearVelocity=[vx, 0, 0], **cidkw(cid))
        run(cid, 10)
        nan, inf, wh = nan_scan(cid)
        emit("%s-vel x=%s nan=%s inf=%s where=%s" % (
            tag, fx(body_pos(cid, ball)[0]), nan, inf, wh))
        p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.resetBasePositionAndOrientation(ball, [0, 0, 5], [0, 0, 0, 0], **cidkw(cid))
    pos, orn = p.getBasePositionAndOrientation(ball, **cidkw(cid))
    run(cid, 10)
    nan, inf, wh = nan_scan(cid)
    emit("zero-quat orn=%s rawQ=%s nan=%s inf=%s where=%s" % (
        ",".join(fx(x) for x in orn), raw(orn[3]), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.resetBasePositionAndOrientation(ball, [0, 0, 5], [0, 0, 0, float("nan")], **cidkw(cid))
    pos, orn = p.getBasePositionAndOrientation(ball, **cidkw(cid))
    run(cid, 10)
    nan, inf, wh = nan_scan(cid)
    emit("nan-quat ornW=%s z=%s nan=%s inf=%s where=%s" % (
        fx(orn[3]), fx(z(cid, ball)), nan, inf, wh))


def c_nan_mass(emit):
    """mass<=0/NaN -> static-but-stored; +inf -> whole-body NaN; write gate."""
    cid = p.connect(p.DIRECT)
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    ball = p.createMultiBody(0.0, s, -1, [0, 0, 5], **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 120)
    emit("mass0 z=%s nan=%s" % (fx(z(cid, ball)), nan_scan(cid)[0]))
    p.disconnect(**cidkw(cid))
    for tag, m0 in (("neg", -1.0), ("nan", float("nan")), ("inf", float("inf"))):
        cid = p.connect(p.DIRECT)
        s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
        r = try_or(lambda: p.createMultiBody(m0, s, -1, [0, 0, 5], **cidkw(cid)), "mkbody")
        p.setGravity(0, 0, G, **cidkw(cid))
        if isinstance(r, int):
            m = p.getDynamicsInfo(r, -1, **cidkw(cid))[0]
            run(cid, 60)
            nan, inf, wh = nan_scan(cid)
            emit("%s-mass-create id=%s dynMass=%s z=%s nan=%s inf=%s where=%s" % (
                tag, r, fx(m), fx(z(cid, r)), nan, inf, wh))
        else:
            emit("%s-mass-create %s" % (tag, r))
        p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    r = try_or(lambda: p.changeDynamics(ball, -1, mass=-1.0, **cidkw(cid)), "chdyn")
    m = p.getDynamicsInfo(ball, -1, **cidkw(cid))[0]
    run(cid, 120)
    nan, inf, wh = nan_scan(cid)
    emit("neg-mass set=%s dynMass=%s z=%s nan=%s inf=%s where=%s" % (
        ("ok" if r is None else r), fx(m), fx(z(cid, ball)), nan, inf, wh))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    ball = p.createMultiBody(1.0, s, -1, [0, 0, 5], **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 60)
    v0 = body_vel(cid, ball)[0][2]
    p.changeDynamics(ball, -1, mass=0.0, **cidkw(cid))
    m = p.getDynamicsInfo(ball, -1, **cidkw(cid))[0]
    rows = []
    for i in range(1, 31):
        p.stepSimulation(**cidkw(cid))
        if i in (1, 10, 30):
            rows.append("%d:z=%s,v=%s" % (i, fx(z(cid, ball)), fx(body_vel(cid, ball)[0][2])))
    emit("mass-change v0=%s newMass=%s %s" % (fx(v0), fx(m), " ".join(rows)))


def c_nan_damp(emit):
    """damping lattice: applied UNCLAMPED (d>1 legal); neg/NaN dropped by gate."""
    outs = []
    for d in (0.0, 1.0, 1.5, -0.5, float("nan")):
        cid = p.connect(p.DIRECT)
        ball = ball_only(cid)
        r = try_or(lambda: p.changeDynamics(ball, -1, linearDamping=d, **cidkw(cid)), "ch")
        run(cid, 120)
        nan, inf, wh = nan_scan(cid)
        outs.append("%s:set=%s,z=%s,nan=%s,inf=%s" % (
            fx(d) if not math.isnan(d) else "nan",
            ("ok" if r is None else "threw"), fx(z(cid, ball)), nan, inf))
        p.disconnect(**cidkw(cid))
    emit("damping " + " | ".join(outs))


def c_nan_shape(emit):
    """shape-arg lattice: halfExtents unchecked (0/-0.5/NaN accepted); radius
    <=0/NaN refused (neg arm); +inf radius accepted; coincident pair; ccd."""
    for tag, he in (("zero-box", [0, 0, 0]), ("neg-box", [-0.5, -0.5, -0.5])):
        cid = p.connect(p.DIRECT)
        r = try_or(lambda: p.createCollisionShape(p.GEOM_BOX, halfExtents=he, **cidkw(cid)), "mkshape")
        if isinstance(r, int):
            ball = p.createMultiBody(1.0, r, -1, [0, 0, 3], **cidkw(cid))
            g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
            p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
            p.setGravity(0, 0, G, **cidkw(cid))
            run(cid, 240)
            nan, inf, wh = nan_scan(cid)
            emit("%s z=%s nan=%s inf=%s where=%s contacts=%d" % (
                tag, fx(z(cid, ball)), nan, inf, wh, ncontacts(cid)))
        else:
            emit("%s %s" % (tag, r))
        p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    r = try_or(lambda: p.createCollisionShape(p.GEOM_SPHERE, radius=float("inf"), **cidkw(cid)), "infrad")
    emit("inf-radius accepted=%s" % (isinstance(r, int) and r >= 0))
    r = try_or(lambda: p.createCollisionShape(p.GEOM_BOX, halfExtents=[float("nan")] * 3, **cidkw(cid)), "nanhe")
    emit("nan-halfextents accepted=%s" % (isinstance(r, int) and r >= 0))
    p.disconnect(**cidkw(cid))
    # coincident spheres, g=0: fixed (1,0,0) normal, ballistic split
    cid = p.connect(p.DIRECT)
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    a = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
    b = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
    p.setGravity(0, 0, 0, **cidkw(cid))
    for i in range(121):
        p.stepSimulation(**cidkw(cid))
        if i in (0, 1, 5, 30, 120):
            cp = p.getContactPoints(bodyA=a, bodyB=b, **cidkw(cid))
            nn = ["%s,%s,%s/d=%s" % (fx(c[7][0]), fx(c[7][1]), fx(c[7][2]), fx(c[8])) for c in cp]
            pa = body_pos(cid, a)
            pb = body_pos(cid, b)
            emit("coincident i%d cc=%d n=[%s] sep=%s aX=%s bX=%s" % (
                i, len(cp), ";".join(nn), fx(math.dist(pa, pb)), fx(pa[0]), fx(pb[0])))
    p.disconnect(**cidkw(cid))
    # coincident pair under gravity
    cid = p.connect(p.DIRECT)
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    a = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
    b = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    for i in range(241):
        p.stepSimulation(**cidkw(cid))
        if i in (0, 1, 10, 60, 240):
            pa = body_pos(cid, a)
            pb = body_pos(cid, b)
            emit("coincG i%d sep=%s a=(%s,%s,%s) b=(%s,%s,%s)" % (
                i, fx(math.dist(pa, pb)), fx(pa[0]), fx(pa[1]), fx(pa[2]),
                fx(pb[0]), fx(pb[1]), fx(pb[2])))
    p.disconnect(**cidkw(cid))
    # teleport into ground -> fast depenetration snap
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    run(cid, 300)
    zb = z(cid, ball)
    p.resetBasePositionAndOrientation(ball, [0, 0, 0.2], [0, 0, 0, 1], **cidkw(cid))
    rows = []
    for i in range(1, 61):
        p.stepSimulation(**cidkw(cid))
        if i in (1, 2, 3, 5, 10, 20, 60):
            lv = body_vel(cid, ball)[0][2]
            rows.append("%d:z=%s,v=%s" % (i, fx(z(cid, ball)), fx(lv)))
    emit("teleport-into-ground zBefore=%s %s" % (fx(zb), " ".join(rows)))
    p.disconnect(**cidkw(cid))
    # ccd on this build's swept-sphere knob: inert here (both tunnel equally)
    for tag, ccd in (("ccd-off", None), ("ccd-on", 0.04)):
        cid = p.connect(p.DIRECT)
        g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.05], **cidkw(cid))
        s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.05, **cidkw(cid))
        p.createMultiBody(0.0, g, -1, [0, 0, 0], **cidkw(cid))
        ball = p.createMultiBody(1.0, s, -1, [0, 0, 5], **cidkw(cid))
        if ccd is not None:
            p.changeDynamics(ball, -1, ccdSweptSphereRadius=ccd, **cidkw(cid))
        p.resetBaseVelocity(ball, linearVelocity=[0, 0, -500], **cidkw(cid))
        p.setGravity(0, 0, 0, **cidkw(cid))
        run(cid, 30)
        emit("%s z=%s" % (tag, fx(z(cid, ball))))
        p.disconnect(**cidkw(cid))


# ==========================================================================
# fric / rest — combine lattices with the pass-2 1-ulp correction
# ==========================================================================

def c_fr_combine(emit):
    """9-digit slide-x lattice: equal-decimal products print equal x
    (fr_bitexact shows the underlying bits are 1 ulp apart)."""
    pairs = [(0.5, 0.5), (0.8, 0.8), (0.64, 1.0), (1.0, 0.64), (0.8, 1.0), (0.05, 0.05)]
    outs = []
    for mg, mb in pairs:
        cid = p.connect(p.DIRECT)
        outs.append((mg, mb, _slide(cid, mg, mb)))
        p.disconnect(**cidkw(cid))
    emit("fric-combine " + " ".join(
        f"g{mg}/b{mb}:x={fx(v)}" for mg, mb, v in outs))


def c_fr_bitexact(emit):
    pairs = [(0.8, 0.8), (0.64, 1.0), (1.0, 0.64), (0.8, 1.0), (0.5, 0.5),
             (0.05, 0.05)]
    outs = []
    for mg, mb in pairs:
        cid = p.connect(p.DIRECT)
        x, h = _slide_hash(cid, mg, mb)
        p.disconnect(**cidkw(cid))
        outs.append((mg, mb, x, h))
    prod = struct.pack(">d", 0.8 * 0.8).hex(), struct.pack(">d", 0.64).hex()
    emit("fric-bitexact prod0808=%s prod064=%s ulpEq=%s" % (
        prod[0], prod[1], prod[0] == prod[1]))
    emit("fric-bitexact " + " ".join(
        "g%s/b%s:x=%s:h=%s" % (mg, mb, fx(x), h) for mg, mb, x, h in outs))


def c_fr_gate(emit):
    """the >=0 write gate: negative mu dropped; mu=11 stored; mu=0 residual is
    nothing but default linearDamping=0.04 (damp0 -> ideal 12.5 m slide)."""
    outs = []
    for mg, mb in [(-0.5, 0.5), (0.5, -0.5), (-0.5, -0.5), (11.0, 1.0), (-0.3, 0.9)]:
        cid = p.connect(p.DIRECT)
        g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[30, 10, 0.5], **cidkw(cid))
        b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
        p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
        box = p.createMultiBody(1.0, b, -1, [0, 0, 0.51], **cidkw(cid))
        p.changeDynamics(0, -1, lateralFriction=mg, **cidkw(cid))
        p.changeDynamics(box, -1, lateralFriction=mb, **cidkw(cid))
        sg = p.getDynamicsInfo(0, -1, **cidkw(cid))[1]
        sb = p.getDynamicsInfo(box, -1, **cidkw(cid))[1]
        p.setGravity(0, 0, G, **cidkw(cid))
        run(cid, 30)
        p.resetBaseVelocity(box, linearVelocity=[5, 0, 0], angularVelocity=[0, 0, 0], **cidkw(cid))
        run(cid, 600)
        x = body_pos(cid, box)[0]
        outs.append("g%s/b%s:stored=%s,%s,x=%s" % (fx(mg), fx(mb), fx(sg), fx(sb), fx(x)))
        p.disconnect(**cidkw(cid))
    emit("fric-neg " + " ".join(outs))
    cid = p.connect(p.DIRECT)
    emit("fric-zero x=%s" % fx(_slide(cid, 0.0, 0.0)))
    p.disconnect(**cidkw(cid))
    # mu=0 residual decomposition (scout unknown #5, resolved pass 2)
    def slide(damp=None, grav=G):
        cid = p.connect(p.DIRECT)
        g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[30, 10, 0.5], **cidkw(cid))
        bx = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
        p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
        box = p.createMultiBody(1.0, bx, -1, [0, 0, 0.51], **cidkw(cid))
        p.changeDynamics(0, -1, lateralFriction=0.0, **cidkw(cid))
        kw = {"lateralFriction": 0.0}
        if damp is not None:
            kw["linearDamping"] = damp
        p.changeDynamics(box, -1, **kw)
        p.setGravity(0, 0, grav, **cidkw(cid))
        run(cid, 30)
        p.resetBaseVelocity(box, linearVelocity=[5, 0, 0], angularVelocity=[0, 0, 0], **cidkw(cid))
        v = []
        for i in range(1, 601):
            p.stepSimulation(**cidkw(cid))
            if i in (60, 300, 600):
                v.append("%d:vx=%s" % (i, fx(body_vel(cid, box)[0][0])))
        out = (body_pos(cid, box)[0], "|".join(v))
        p.disconnect(**cidkw(cid))
        return out
    rows = []
    for tag, kw in (("mu0", {}), ("mu0+damp0", {"damp": 0.0}),
                    ("mu0+g0", {"grav": 0.0}), ("mu0+g0+damp0", {"grav": 0.0, "damp": 0.0})):
        x, v = slide(**kw)
        rows.append("%s:x=%s[%s]" % (tag, fx(x), v))
    emit("fric-zero-mech " + " ".join(rows))


def c_rest_all(emit):
    """restitution: raw unclamped product; equal-f64 products are bit-exact."""
    outs = []
    for e_g, e_b in [(0.0, 0.0), (0.9, 0.9), (0.81, 1.0), (0.9, 1.0), (0.5, 0.5)]:
        cid = p.connect(p.DIRECT)
        g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
        s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
        p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
        ball = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
        p.changeDynamics(0, -1, restitution=e_g, **cidkw(cid))
        p.changeDynamics(ball, -1, restitution=e_b, **cidkw(cid))
        p.setGravity(0, 0, G, **cidkw(cid))
        apex = 0.0
        bounced = False
        prev_v = 0.0
        for i in range(600):
            p.stepSimulation(**cidkw(cid))
            v = body_vel(cid, ball)[0][2]
            if prev_v < 0 and v > 0:
                bounced = True
            prev_v = v
            if bounced:
                apex = max(apex, z(cid, ball))
        outs.append("g%s/b%s:apex=%s,bounced=%s" % (fx(e_g), fx(e_b), fx(apex), bounced))
        p.disconnect(**cidkw(cid))
    emit("rest-combine " + " ".join(outs))
    outs = []
    for mg, mb in [(0.9, 0.9), (0.81, 1.0), (0.9, 1.0), (0.5, 0.5), (0.0, 0.0)]:
        cid = p.connect(p.DIRECT)
        g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
        s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
        p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
        p.changeDynamics(0, -1, restitution=mg, **cidkw(cid))
        ball = p.createMultiBody(1.0, s, -1, [0, 0, 3.0], **cidkw(cid))
        p.changeDynamics(ball, -1, restitution=mb, **cidkw(cid))
        p.setGravity(0, 0, G, **cidkw(cid))
        run(cid, 300)
        outs.append((mg, mb, z(cid, ball), state_hash(cid)))
        p.disconnect(**cidkw(cid))
    emit("rest-bitexact " + " ".join(
        "g%s/b%s:z=%s:h=%s" % (mg, mb, fx(zz), h) for mg, mb, zz, h in outs))


# ==========================================================================
# knobs / solver — boundary census cells (one knob per fresh client)
# ==========================================================================

def c_kn_neutral(emit):
    """boundary-proven bit-neutral knobs, canonical scene."""
    knobs = [
        ("cone_fric_1", {"enableConeFriction": 1}),
        ("erp_0.2", {"erp": 0.2}), ("erp_0.8", {"erp": 0.8}),
        ("frictionERP_0.2", {"frictionERP": 0.2}),
        ("minIsland_0", {"minimumSolverIslandSize": 0}),
        ("innerIter_4", {"numNonContactInnerIterations": 4}),
        ("ccdPen_0.02", {"allowedCcdPenetration": 0.02}),
        ("detpairs_1", {"deterministicOverlappingPairs": 1}),
        ("warmstart_0", {"warmStartingFactor": 0.0}),
    ]
    parts = []
    nneut = 0
    for tag, kw in knobs:
        cid = p.connect(p.DIRECT)
        p.setPhysicsEngineParameter(**kw, **cidkw(cid))
        scene(cid)
        run(cid, NBASE)
        h = state_hash(cid)
        nneut += (h == PIN_BASE)
        parts.append("%s:h=%s" % (tag, h))
        p.disconnect(**cidkw(cid))
    emit("knobs-neutral %s eqBase=%d/%d" % (" ".join(parts), nneut, len(knobs)))


def c_kn_loud(emit):
    """boundary-proven bit-moving knobs, canonical scene, 480 steps each."""
    knobs = [
        ("contactERP_0.2", {"contactERP": 0.2}),
        ("contactSlop_0.01", {"contactSlop": 0.01}),
        ("resid_1e-6", {"solverResidualThreshold": 1e-6}),
        ("globalCFM_1e-5", {"globalCFM": 1e-5}),
        ("minIsland_2", {"minimumSolverIslandSize": 2}),
        ("iters_10", {"numSolverIterations": 10}),
        ("substeps_2", {"numSubSteps": 2}),
        ("ts_1/120", {"fixedTimeStep": 1.0 / 120.0}),
    ]
    parts = []
    for tag, kw in knobs:
        cid = p.connect(p.DIRECT)
        p.setPhysicsEngineParameter(**kw, **cidkw(cid))
        scene(cid)
        run(cid, NBASE)
        parts.append("%s:h=%s" % (tag, state_hash(cid)))
        p.disconnect(**cidkw(cid))
    emit("knobs-loud %s" % " ".join(parts))


def c_sv_backends(emit):
    """constraintSolverType backend axis: SI==unset==pin; PGS/DANTZIG differ."""
    parts = []
    for tag, st in (("unset", None),
                    ("SI", p.CONSTRAINT_SOLVER_LCP_SI),
                    ("PGS", p.CONSTRAINT_SOLVER_LCP_PGS),
                    ("DANTZIG", p.CONSTRAINT_SOLVER_LCP_DANTZIG)):
        cid = p.connect(p.DIRECT)
        if st is not None:
            p.setPhysicsEngineParameter(constraintSolverType=st, **cidkw(cid))
        scene(cid)
        run(cid, NBASE)
        parts.append("%s:h=%s,z=%s,cc=%d" % (tag, state_hash(cid), fx(z(cid, 1)),
                                             ncontacts(cid)))
        p.disconnect(**cidkw(cid))
    emit("solvertype " + " ".join(parts))


def c_sv_tps(emit):
    """setTimeStep lattice (n scales to 2.0 s) + the substep/dt equivalence."""
    outs = []
    for dt in (1.0 / 60.0, 1.0 / 120.0, 1.0 / 240.0, 1.0 / 480.0, 1.0 / 1000.0):
        cid = p.connect(p.DIRECT)
        p.setTimeStep(dt, **cidkw(cid))
        scene(cid)
        n = int(round(2.0 / dt))
        run(cid, n)
        outs.append((dt, state_hash(cid)))
        p.disconnect(**cidkw(cid))
    emit("tps " + " ".join("1/%d:h=%s" % (int(round(1.0 / dt)), h)
                           for dt, h in outs))
    # 1/480 x 960 calls ≡ numSubSteps=2 x 480 calls (boundary §3c)
    cid = p.connect(p.DIRECT)
    p.setTimeStep(1.0 / 480.0, **cidkw(cid))
    scene(cid)
    run(cid, 960)
    h_a = state_hash(cid)
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    p.setPhysicsEngineParameter(numSubSteps=2, **cidkw(cid))
    scene(cid)
    run(cid, 480)
    h_b = state_hash(cid)
    p.disconnect(**cidkw(cid))
    emit("substep-equiv dt480x960:h=%s nsub2x480:h=%s eq=%s" % (h_a, h_b, h_a == h_b))


def c_pile_lattice(emit):
    """32-box pile: detpairs is LOUD here (contrast with 5-body det_detpairs);
    creation order moves bits at scale; maximal coords differ too."""
    parts = []
    for tag, kw in (("default", {}), ("det0", {"det": 0}), ("det1", {"det": 1}),
                    ("rev", {"det": 0, "reverse": True}),
                    ("mb", {"det": 0, "mx": True})):
        cid = p.connect(p.DIRECT)
        if kw.get("det") is not None:
            p.setPhysicsEngineParameter(deterministicOverlappingPairs=kw["det"], **cidkw(cid))
        _pile(cid, mx=kw.get("mx", False), reverse=kw.get("reverse", False))
        run(cid, 600)
        parts.append("%s:h=%s,cc=%d" % (tag, state_hash(cid), ncontacts(cid)))
        p.disconnect(**cidkw(cid))
    emit("pile " + " ".join(parts))


# ==========================================================================
# misc — contact persistence/order, mutation boundary, world defaults
# ==========================================================================

def c_ms_contacts(emit):
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid, z=1.0)
    rows = []
    for i in range(1, 1401):
        p.stepSimulation(**cidkw(cid))
        if i in (10, 60, 120, 300, 480, 720, 1000, 1400):
            cp = p.getContactPoints(bodyA=ball, bodyB=0, **cidkw(cid))
            rows.append("s%d:cc=%d,z=%s" % (i, len(cp), fx(z(cid, ball))))
    emit("contact-rest %s" % " ".join(rows))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    for pos in ([1.2, 0, 1.0], [-1.2, 0, 1.0], [0, 0, 2.2]):
        p.createMultiBody(1.0, b, -1, pos, **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 300)
    cp = p.getContactPoints(**cidkw(cid))
    pairs = [(c[1], c[2]) for c in cp]
    emit("contact-order pairs=%s cc=%d" % (",".join(f"{a}-{b2}" for a, b2 in pairs), len(cp)))


def c_ms_mutate(emit):
    """writes land at the next stepSimulation boundary; margin write inert."""
    cid = p.connect(p.DIRECT)
    g = p.createCollisionShape(p.GEOM_BOX, halfExtents=[10, 10, 0.5], **cidkw(cid))
    b = p.createCollisionShape(p.GEOM_BOX, halfExtents=[0.5, 0.5, 0.5], **cidkw(cid))
    p.createMultiBody(0.0, g, -1, [0, 0, -0.5], **cidkw(cid))
    box = p.createMultiBody(1.0, b, -1, [0, 0, 0.6], **cidkw(cid))
    di = p.getDynamicsInfo(box, -1, **cidkw(cid))
    m0 = di[11]
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 240)
    zb = z(cid, box)
    p.changeDynamics(box, -1, collisionMargin=0.45, **cidkw(cid))
    m1 = p.getDynamicsInfo(box, -1, **cidkw(cid))[11]
    zimm = z(cid, box)
    rows = []
    for i in range(1, 31):
        p.stepSimulation(**cidkw(cid))
        if i in (1, 2, 5, 30):
            rows.append("%d:z=%s" % (i, fx(z(cid, box))))
    emit("margin-change margin %s->%s zBefore=%s zSameTick=%s %s" % (
        fx(m0), fx(m1), fx(zb), fx(zimm), " ".join(rows)))
    p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    run(cid, 60)
    v0 = body_vel(cid, ball)[0][2]
    p.setGravity(0, 0, 0, **cidkw(cid))
    p.stepSimulation(**cidkw(cid))
    v1 = body_vel(cid, ball)[0][2]
    p.stepSimulation(**cidkw(cid))
    v2 = body_vel(cid, ball)[0][2]
    emit("gravity-change v0=%s vAfter1Step=%s vAfter2=%s" % (fx(v0), fx(v1), fx(v2)))


def c_ms_defaults(emit):
    """engine defaults + getDynamicsInfo is a 12-field tuple with NO
    activation/sleep field (sleep is unobservable through the API)."""
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    params = p.getPhysicsEngineParameters(**cidkw(cid))
    di = p.getDynamicsInfo(ball, -1, **cidkw(cid))
    emit("world-defaults params=%s" %
         " ".join(f"{k}={params[k]}" for k in sorted(params)))
    emit("world-defaults dynInfo mass=%s latFric=%s restit=%s rollF=%s spinF=%s "
         "cDamp=%s cStiff=%s bodyType=%s margin=%s nfields=%d" % (
             fx(di[0]), fx(di[1]), fx(di[5]), fx(di[6]), fx(di[7]),
             fx(di[8]), fx(di[9]), di[10], fx(di[11]), len(di)))


# ==========================================================================
# negative arms — prove the live control, then the rejected claim (exit 2).
# ==========================================================================

def c_neg_dt(emit):
    cid = p.connect(p.DIRECT)
    scene(cid)
    run(cid, NBASE)
    h0 = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    p.setTimeStep(1.0 / 119.0, **cidkw(cid2))
    scene(cid2)
    run(cid2, NBASE)
    h1 = state_hash(cid2)
    emit("neg-dt control h=%s variant fixedTimeStep=1/119 h=%s" % (h0, h1))
    if h1 != h0:
        raise Reject("neg-dt fixedTimeStep=1/119 moves the hash %s->%s" % (h0, h1))


def c_neg_order(emit):
    """cannon-es order-neutrality does NOT transfer to Bullet."""
    cid = p.connect(p.DIRECT)
    scene(cid)
    run(cid, NBASE)
    hf = state_hash(cid)
    cid2 = p.connect(p.DIRECT)
    scene(cid2, reverse=True)
    run(cid2, NBASE)
    hr = state_hash(cid2)
    emit("neg-order forward=%s reverse=%s" % (hf, hr))
    if hr != hf:
        raise Reject("neg-order creation order is not bit-neutral %s->%s" % (hf, hr))


def c_neg_radius(emit):
    """shape-arg refusal lattice: radius<=0/NaN raise, +inf accepted."""
    cid = p.connect(p.DIRECT)
    s = p.createCollisionShape(p.GEOM_SPHERE, radius=0.5, **cidkw(cid))
    ball = p.createMultiBody(1.0, s, -1, [0, 0, 3], **cidkw(cid))
    p.setGravity(0, 0, G, **cidkw(cid))
    run(cid, 240)
    emit("neg-radius ctrl r=0.5 z=%s" % fx(z(cid, ball)))
    refused = 0
    for rv in (-0.5, 0.0, float("nan")):
        r = try_or(lambda: p.createCollisionShape(p.GEOM_SPHERE, radius=rv, **cidkw(cid)), "mk")
        if not (isinstance(r, str) and r.startswith("threw:")):
            break
        refused += 1
    rinf = p.createCollisionShape(p.GEOM_SPHERE, radius=float("inf"), **cidkw(cid))
    emit("neg-radius refused=%d infAccepted=%s" % (refused, isinstance(rinf, int) and rinf >= 0))
    if refused == 3:
        raise Reject("neg-radius radius<={-0.5,0,nan} refused (pybullet.error) "
                     "while radius=+inf accepted id=%s" % rinf)


def c_neg_simtime(emit):
    """simTimeScalingFactor kwarg refusal class (TypeError), both scales."""
    threw = 0
    msgs = []
    for sc in (1.0, 2.0):
        cid = p.connect(p.DIRECT)
        try:
            p.setPhysicsEngineParameter(simTimeScalingFactor=sc, **cidkw(cid))
            run(cid, 60)
        except TypeError as e:
            threw += 1
            msgs.append(str(e)[:60])
        p.disconnect(**cidkw(cid))
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.setPhysicsEngineParameter(numSolverIterations=50, **cidkw(cid))  # legal control
    run(cid, 60)
    emit("neg-simtime threw=%d ctrl z=%s" % (threw, fx(z(cid, ball))))
    if threw == 2:
        raise Reject("neg-simtime simTimeScalingFactor kwarg refused TypeError x2 "
                     "('%s')" % msgs[0])


def c_neg_badid(emit):
    """invalid-id / disconnected-client refusal class."""
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    run(cid, 60)
    emit("neg-badid ctrl z=%s" % fx(z(cid, ball)))
    refused = []
    for tag, fn in (("getpos", lambda: p.getBasePositionAndOrientation(999, **cidkw(cid))),
                    ("dyninfo", lambda: p.getDynamicsInfo(999, -1, **cidkw(cid))),
                    ("step9", lambda: p.stepSimulation(physicsClientId=9))):
        r = try_or(fn, tag)
        if isinstance(r, str) and r.startswith("threw:"):
            refused.append(tag)
    emit("neg-badid refused=%s" % ",".join(refused))
    if len(refused) == 3:
        raise Reject("neg-badid 3 invalid-id calls refused (pybullet.error)")


def c_neg_shm_rt(emit):
    """'SHM is a physics-neutral transport' is rejected under rt=1 via the
    live pump — NOT via stepped-hash divergence, which is pump-timing
    load-dependent (boundary saw divergence; this host can replay the pin).
    Robust discriminator: DIRECT+rt=1 idle freezes, SHM+rt=1 idle falls."""
    # live control: DIRECT rt=1 + idle -> frozen
    cid = p.connect(p.DIRECT)
    ball = ball_only(cid)
    p.setRealTimeSimulation(1, **cidkw(cid))
    z0 = z(cid, ball)
    time.sleep(1.0)
    zd = z(cid, ball)
    d_froze = zd == z0
    emit("neg-shm-rt ctrl direct-rt1 idle1.0s froze=%s" % d_froze)
    p.disconnect(**cidkw(cid))
    # variant: SHM rt=1 + idle -> pump advances the world
    cid = _shm_client(1)
    ball = ball_only(cid)
    z0 = z(cid, ball)
    time.sleep(2.0)
    zs = z(cid, ball)
    fell = zs < 5.0
    emit("neg-shm-rt shm-rt1 idle2.0s fell=%s" % fell)
    diag("neg-shm-rt measured z0=%s z1=%s" % (fx(z0), fx(zs)))
    _shm_drop(cid)
    if d_froze and fell:
        raise Reject("neg-shm-rt SHM transport is not physics-neutral under "
                     "rt=1: DIRECT froze idle (froze=True), SHM pump advanced "
                     "the world during a bare sleep (fell=True)")


CASES = {
    "det_base": c_det_base,
    "det_rebuild": c_det_rebuild,
    "det_interleave": c_det_interleave,
    "det_order": c_det_order,
    "det_iters": c_det_iters,
    "det_iters0": c_det_iters0,
    "det_substeps": c_det_substeps,
    "det_detpairs": c_det_detpairs,
    "det_reset": c_det_reset,
    "det_restore": c_det_restore,
    "det_perturb": c_det_perturb,
    "det_saturated": c_det_saturated,
    "det_neutral": c_det_neutral,
    "freeze_scene": c_freeze_scene,
    "freeze_ball": c_freeze_ball,
    "rt_inert": c_rt_inert,
    "rt_idle": c_rt_idle,
    "rt_paced": c_rt_paced,
    "shm_step": c_shm_step,
    "shm_rtclass": c_shm_rtclass,
    "sl_iters": c_sl_iters,
    "sl_velwrite": c_sl_velwrite,
    "sl_teleport": c_sl_teleport,
    "sl_force_mb": c_sl_force_mb,
    "sl_force_max": c_sl_force_max,
    "sl_rest_max": c_sl_rest_max,
    "sl_disable_pair": c_sl_disable_pair,
    "sl_persist": c_sl_persist,
    "sl_stale": c_sl_stale,
    "nan_dt": c_nan_dt,
    "nan_fields": c_nan_fields,
    "nan_mass": c_nan_mass,
    "nan_damp": c_nan_damp,
    "nan_shape": c_nan_shape,
    "fr_combine": c_fr_combine,
    "fr_bitexact": c_fr_bitexact,
    "fr_gate": c_fr_gate,
    "rest_all": c_rest_all,
    "kn_neutral": c_kn_neutral,
    "kn_loud": c_kn_loud,
    "sv_backends": c_sv_backends,
    "sv_tps": c_sv_tps,
    "pile_lattice": c_pile_lattice,
    "ms_contacts": c_ms_contacts,
    "ms_mutate": c_ms_mutate,
    "ms_defaults": c_ms_defaults,
    # negative controls (exit 2 after live control)
    "neg_dt": c_neg_dt,
    "neg_order": c_neg_order,
    "neg_radius": c_neg_radius,
    "neg_simtime": c_neg_simtime,
    "neg_badid": c_neg_badid,
    "neg_shm_rt": c_neg_shm_rt,
}


def _emit_captured():
    """re-emit captured fd-1/fd-2 content as '#' diagnostics (drains buffer)."""
    sys.stdout.flush()
    _errbuf.flush()
    _errbuf.seek(0)
    data = _errbuf.read().decode("utf-8", "replace")
    _errbuf.seek(0)
    _errbuf.truncate(0)
    for line in data.splitlines():
        if line.strip():
            owrite("# " + line.strip())


def _build_stamp():
    """extract 'pybullet build time: <ts>' captured during import."""
    _errbuf.flush()
    pos = _errbuf.tell()
    _errbuf.seek(0)
    data = _errbuf.read().decode("utf-8", "replace")
    _errbuf.seek(pos)
    for line in data.splitlines():
        if "build time:" in line:
            return line.split("build time:", 1)[1].strip()
    return "unknown"


def main():
    emit = lambda text: owrite("M %s %s" % (CASE, text))
    if CASE not in CASES:
        owrite("ERROR: r95_child unknown case %r (have %d)" % (CASE, len(CASES)))
        sys.exit(1)
    # engine identity for M0: api + fixedTimeStep bits (btScalar width) via a
    # throwaway DIRECT client.
    cid = p.connect(p.DIRECT)
    params = p.getPhysicsEngineParameters(**cidkw(cid))
    dtbits = raw(params["fixedTimeStep"])
    p.disconnect(**cidkw(cid))
    owrite("M0 case=%s engine=pybullet-3.2.7 api=%s py=%s dtBits=%s build=\"%s\"" % (
        CASE, p.getAPIVersion(), platform.python_version(), dtbits,
        _build_stamp()))
    try:
        CASES[CASE](emit)
    except Reject as r:
        _emit_captured()
        owrite("NEGATIVE REJECTED: r95_bullet %s %s" % (CASE, r))
        sys.exit(2)
    except Exception as e:
        _emit_captured()
        owrite("ERROR: r95_child %s %s: %s" % (CASE, type(e).__name__, str(e)[:120]))
        sys.exit(1)
    owrite("M DONE case=%s" % CASE)
    try:
        p.disconnect()
    except Exception:
        pass
    time.sleep(0.05)    # straggler prints land before the drain
    _emit_captured()
    sys.exit(0)


if __name__ == "__main__":
    main()
