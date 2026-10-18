// r94 child probe — the cannon-es 0.20.0 / three 0.186.1 "cannon.js/PyBullet-
// style" lattice in headless node, spawned per case by r94_cannon.gd:
//
//     node r94_child.mjs <case>
//
// Engine bytes are the VENDORED dist bundles in ./r94vendor/ (sha256-pinned
// seeds, byte-identical to npm cannon-es@0.20.0 dist/cannon-es.js and
// three@0.186.1 build/three.module.js+three.core.js — the scout's own pinned
// deps). No node_modules, no npm at battery time.
//
// Output contract (the parent scans for these prefixes):
//   M0 case=<c> engine=..                  header, once
//   M <case> <point> k=v ..                evidence lines — pinned fields only
//   M DONE case=<c>                        footer, once
//   NEGATIVE REJECTED: r94_cannon <c> ..   intended negative, exit 2
//   ERROR: r94_child <c> ..                setup failure, exit 1
// Anything else on stdout/stderr counts against the digest's e/w surface.
//
// Authored ONLY from claims that survived reports/round-94/r94-boundary.md:
// every fixed-step hash is the physics+render witness of the scout (h), NaN
// states are hashed CANONICALLY (never by payload bits — boundary §3), and
// wall-clock-driven modes are pinned as classes, never as counts:
//   * fixedStep(): not a call-count scheduler -> mode_ok (stepnumber<240)
//   * dt=0 in accumulator mode: accumulator=NaN, world frozen forever
//   * internalStep is a function of (bodies, world.time) — not pure
//   * body-add order is bit-neutral ONLY in the symmetric canon scene;
//     asym2/stack3/tri pin their own forward/reverse hashes
//   * "15*mu*g" deceleration is a one-point fit: pinned mass-inert /
//     mu-dependent / v0-dependent grid replaces the law
//   * GridBroadphase refuses at nx>=2 (TypeError class) — negative control
//   * the accumulator budget (substep spread 1..222 on one host), grid nx=10
//     (hang class) and the --no-opt NaN-payload flip (~34%/process) are
//     measured non-pinnables: reported, not authored.

import * as CANNON from './r94vendor/cannon-es.js';
import * as THREE from './r94vendor/three.module.js';
import { createHash } from 'node:crypto';

// ---------------------------------------------------------------------------
// Witness plumbing (verbatim port of the scout's lib.mjs semantics)
// ---------------------------------------------------------------------------
const _buf = new ArrayBuffer(8);
const _dv = new DataView(_buf);
const bits = (x) => { _dv.setFloat64(0, x); return _dv.getBigUint64(0).toString(16).padStart(16, '0'); };
const fx = (x, dp = 6) => Number.isNaN(x) ? 'NaN' : x === Infinity ? 'Inf' : x === -Infinity ? '-Inf' : x.toFixed(dp);
const vecBits = (v) => `${bits(v.x)}${bits(v.y)}${bits(v.z)}`;
const quatBits = (q) => `${bits(q.x)}${bits(q.y)}${bits(q.z)}${bits(q.w)}`;
const hash = (s) => createHash('sha256').update(s).digest('hex').slice(0, 16);
const bodyBits = (b) => [vecBits(b.position), quatBits(b.quaternion), vecBits(b.velocity),
  vecBits(b.angularVelocity), vecBits(b.interpolatedPosition), quatBits(b.interpolatedQuaternion),
  String(b.sleepState)].join('|');
const stateBits = (_w, bodies) => bodies.map((b, i) => `${i}:${bodyBits(b)}`).join('\n');
const physBits = (b) => [vecBits(b.position), quatBits(b.quaternion), vecBits(b.velocity), vecBits(b.angularVelocity)].join('|');
const physHash = (bodies) => hash(bodies.map((b, i) => `${i}:${physBits(b)}`).join('\n'));
const worldHash = (w, bodies) => hash(stateBits(w, bodies));
const valsOf = (bodies) => bodies.flatMap(b => [b.position.x, b.position.y, b.position.z,
  b.quaternion.x, b.quaternion.y, b.quaternion.z, b.quaternion.w,
  b.velocity.x, b.velocity.y, b.velocity.z, b.angularVelocity.x, b.angularVelocity.y, b.angularVelocity.z]);
const anyNaN = (bodies) => valsOf(bodies).some(Number.isNaN);
const anyInf = (bodies) => valsOf(bodies).some(v => !Number.isFinite(v));
const canon = (x) => Number.isNaN(x) ? 'NaN' : x === Infinity ? 'Inf' : x === -Infinity ? '-Inf' : bits(x);
const canonHash = (bodies) => hash(bodies.map((b, i) => [i, b.position, b.quaternion, b.velocity, b.angularVelocity]
  .map(v => (typeof v === 'number' ? v : `${canon(v.x)},${canon(v.y)},${canon(v.z)}`)).join('|')).join('\n'));
const nextUp = (x) => {
  if (Number.isNaN(x) || x === Infinity) return x;
  if (x === -Infinity) return -Number.MAX_VALUE;
  const buf = new ArrayBuffer(8); const dv = new DataView(buf);
  dv.setFloat64(0, x);
  let hi = dv.getUint32(0), lo = dv.getUint32(4);
  if (x === 0) return 5e-324;
  if (x > 0) { if (lo === 0xffffffff) { lo = 0; hi += 1; } else lo += 1; }
  else { if (lo === 0) { lo = 0xffffffff; hi -= 1; } else lo -= 1; }
  dv.setUint32(0, hi); dv.setUint32(4, lo);
  return dv.getFloat64(0);
};

// ---------------------------------------------------------------------------
// Emission
// ---------------------------------------------------------------------------
const CASE = process.argv[2];
const M0 = (c) => console.log(`M0 case=${c} engine=cannon-es-0.20.0+three-0.186.1`);
const M = (c, point, kv) => console.log(`M ${c} ${point} ${kv}`);
const DONE = (c) => console.log(`M DONE case=${c}`);
const fail = (msg) => { console.log(`ERROR: r94_child ${CASE} ${msg}`); process.exit(1); };
const reject = (msg) => { console.log(`NEGATIVE REJECTED: r94_cannon ${msg}`); process.exit(2); };

// ---------------------------------------------------------------------------
// Scenes (verbatim ports of the scout/boundary builders)
// ---------------------------------------------------------------------------
const DT = 1 / 60;
const DEFAULTS = { gravity: [0, -9.82, 0], dt: DT, steps: 240, order: 'forward',
  broadphase: 'naive', iterations: 10, tolerance: 1e-7, allowSleep: true, ballX: 0 };

function buildWorld(opts = {}) {
  const o = { ...DEFAULTS, ...opts };
  const world = new CANNON.World({ gravity: new CANNON.Vec3(...o.gravity) });
  world.broadphase = o.broadphase === 'sap' ? new CANNON.SAPBroadphase(world) : new CANNON.NaiveBroadphase();
  world.solver.iterations = o.iterations;
  world.solver.tolerance = o.tolerance;
  world.allowSleep = o.allowSleep;
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(o.ballX, 5, 0) });
  const mk = (x, y) => new CANNON.Body({ mass: 1, shape: new CANNON.Box(new CANNON.Vec3(0.5, 0.5, 0.5)), position: new CANNON.Vec3(x, y, 0) });
  const boxA = mk(1.5, 4.0), boxB = mk(-1.5, 3.0), boxC = mk(0.0, 2.0);
  const dyn = [ball, boxA, boxB, boxC];
  const ordered = o.order === 'reverse' ? [ground, ...[...dyn].reverse()] : [ground, ...dyn];
  for (const b of ordered) world.addBody(b);
  return { world, ground, ball, boxA, boxB, boxC, dyn, opts: o };
}
const stepFixed = (world, n, dt) => { for (let i = 0; i < n; i++) world.step(dt); };
const runScene = (opts = {}, steps = opts.steps ?? DEFAULTS.steps) => { const s = buildWorld(opts); stepFixed(s.world, steps, opts.dt ?? DT); return s; };
const SAMPLE_AT = [1, 30, 60, 120, 240];
function runSampled(opts = {}, steps = opts.steps ?? DEFAULTS.steps) {
  const s = buildWorld(opts);
  const samples = {};
  for (let i = 1; i <= steps; i++) { s.world.step(opts.dt ?? DT); if (SAMPLE_AT.includes(i)) samples[i] = `y@${i}=${fx(s.ball.position.y, 6)}`; }
  s.samples = samples;
  return s;
}
const BASE = '0e24fb5aca619253'; // the scout's canonical 240-step pin

function simpleScene() {
  const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
  world.addBody(ground); world.addBody(ball);
  return { world, ground, ball, dyn: [ball] };
}
function restScene(allowSleep = false) {
  const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0), allowSleep });
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 0.5, 0) });
  world.addBody(ground); world.addBody(ball);
  return { world, ground, ball };
}
function tumbleScene(steps = 120) {
  const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const box = new CANNON.Body({ mass: 1, shape: new CANNON.Box(new CANNON.Vec3(0.5, 0.5, 0.5)), position: new CANNON.Vec3(0.05, 3, 0.02) });
  box.quaternion.setFromEuler(0.4, 0.7, 0.2);
  box.angularVelocity.set(0.3, 1.1, -0.6);
  world.addBody(ground); world.addBody(box);
  for (let i = 0; i < steps; i++) world.step(DT);
  return { world, box, ground };
}
const mesh = () => new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1), new THREE.MeshBasicMaterial());
const angleDeg = (qa, qb) => { const d = Math.abs(qa.x * qb.x + qa.y * qb.y + qa.z * qb.z + qa.w * qb.w); return (2 * Math.acos(Math.min(1, d)) * 180) / Math.PI; };
const bodyWorldPos = (b) => new THREE.Vector3(b.position.x, b.position.y, b.position.z);

// Boundary's asymmetric order scenes
function makeOrderWorld() {
  const w = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
  w.broadphase = new CANNON.NaiveBroadphase();
  w.solver.iterations = DEFAULTS.iterations;
  w.solver.tolerance = DEFAULTS.tolerance;
  w.allowSleep = true;
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  return { w, ground };
}
const obox = (x, y, z, half, mass, euler) => {
  const b = new CANNON.Body({ mass, shape: new CANNON.Box(new CANNON.Vec3(half, half, half)), position: new CANNON.Vec3(x, y, z) });
  if (euler) b.quaternion.setFromEuler(euler[0], euler[1], euler[2]);
  return b;
};
const ORDER_SCENES = {
  canon: () => { const s = buildWorld(); return { world: s.world, ground: s.ground, dyn: s.dyn, ball: s.ball }; },
  asym2: () => {
    const { w, ground } = makeOrderWorld();
    const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
    const p = obox(0.49, 1.0, 0, 0.5, 1);
    const q = obox(-0.51, 1.05, 0, 0.5, 2, [0, 0.3, 0]);
    return { world: w, ground, ball, dyn: [ball, p, q] };
  },
  stack3: () => {
    const { w, ground } = makeOrderWorld();
    const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0.05, 5, 0) });
    const a = obox(0.0, 0.51, 0, 0.5, 1);
    const b = obox(0.12, 1.53, 0, 0.5, 1.5);
    const c = obox(-0.08, 2.55, 0, 0.5, 0.7, [0.04, 0, 0]);
    return { world: w, ground, ball, dyn: [ball, a, b, c] };
  },
  tri: () => {
    const { w, ground } = makeOrderWorld();
    const boxA = obox(0, 0.5, 0, 0.5, 3);
    const s1 = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(1.0, 0.9, 0) });
    const s2 = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(-0.6, 0.75, 0.2) });
    return { world: w, ground, ball: boxA, dyn: [boxA, s1, s2] };
  },
};
class EqRecorder extends CANNON.GSSolver {
  constructor() { super(); this.sig = []; }
  solve(dt, world) { this.sig.push(this.equations.map(e => `${e.bi.id}-${e.bj.id}`).join(' ')); return super.solve(dt, world); }
}
function orderRun(scene, order) {
  const { world, dyn, ground } = ORDER_SCENES[scene]();
  const solver = new EqRecorder();
  solver.iterations = DEFAULTS.iterations; solver.tolerance = DEFAULTS.tolerance;
  world.solver = solver;
  const ordered = order === 'reverse' ? [ground, ...[...dyn].reverse()] : [ground, ...dyn];
  for (const b of ordered) world.addBody(b);
  const contactRows = [];
  for (let i = 1; i <= 240; i++) {
    world.step(DT);
    if ([30, 60, 120, 240].includes(i)) contactRows.push(`${i}:n=${world.contacts.length}/${world.frictionEquations.length}`);
  }
  const sig = solver.sig.filter(x => x !== '');
  const rows = sig.map(r => r.split(' ').map(p => p.split('-').map(Number)));
  const canonRows = rows.map(r => r.map(([a, b]) => `${Math.min(a, b)}-${Math.max(a, b)}`).sort().join(' '));
  return { world, dyn, h: worldHash(world, dyn), ph: physHash(dyn), contactRows,
    sigRows: rows.length, rawSig: JSON.stringify(rows), canonSig: JSON.stringify(canonRows) };
}
function orderCase(c, scene) {
  const f = orderRun(scene, 'forward'), r = orderRun(scene, 'reverse');
  const rawSame = f.rawSig === r.rawSig, sortedSame = f.canonSig === r.canonSig;
  M(c, 'forward', `h=${f.h} ph=${f.ph}`);
  M(c, 'reverse', `h=${r.h} ph=${r.ph}`);
  M(c, 'eq', `h=${f.h === r.h} ph=${f.ph === r.ph} contacts=${f.contactRows.join(' ')}`);
  M(c, 'solver', `rows=${f.sigRows}/${r.sigRows} rawSame=${rawSame} sortedSame=${sortedSame}`);
}

// Material lattice scenes
const MODES = {
  no_material: () => ({}),
  mat_defaults: () => ({ mats: true }),
  mat_pair_05: () => ({ mats: true, fric: 0.5, rest: -1 }),
  mat_one_sided: () => ({ mats: true, fricGround: 0.5, fricBody: -1 }),
  mat_pair_rest05: () => ({ mats: true, rest: 0.5 }),
  cm_pair_09: () => ({ mats: true, cm: { friction: 0.9, restitution: 0 } }),
  cm_pair_09_rev: () => ({ mats: true, cm: { friction: 0.9, restitution: 0 }, cmReversed: true }),
  cm_pair_rest09: () => ({ mats: true, cm: { friction: 0.3, restitution: 0.9 } }),
  cm_and_mat_fric: () => ({ mats: true, fric: 0.5, cm: { friction: 0.9, restitution: 0 } }),
  cm_and_mat_rest: () => ({ mats: true, rest: 0.5, cm: { friction: 0.3, restitution: 0.9 } }),
  cm_rest_one_sided: () => ({ mats: true, restGround: 0.5, cm: { friction: 0.3, restitution: 0.9 } }),
  default_cm_rest06: () => ({ defaultCm: { restitution: 0.6 } }),
  fric_zero: () => ({ mats: true, fric: 0 }),
  shape_material: () => ({ mats: true, shapeMat: true, fricGround: -1, fricShape: 0.9 }),
  friction_gravity: () => ({ mats: true, fric: 0.5, zeroGravity: true, frictionGravity: true }),
};
function matBuild(mode) {
  const cfg = MODES[mode]();
  const world = new CANNON.World({ gravity: new CANNON.Vec3(0, cfg.zeroGravity ? 0 : -9.82, 0) });
  if (cfg.frictionGravity) world.frictionGravity = new CANNON.Vec3(0, -9.82, 0);
  if (cfg.defaultCm) {
    world.defaultContactMaterial.friction = cfg.defaultCm.friction ?? world.defaultContactMaterial.friction;
    world.defaultContactMaterial.restitution = cfg.defaultCm.restitution ?? world.defaultContactMaterial.restitution;
  }
  let mg = null, mb = null;
  if (cfg.mats) {
    mg = new CANNON.Material('ground'); mb = new CANNON.Material('body');
    if (cfg.fric !== undefined) { mg.friction = cfg.fric; mb.friction = cfg.fric; }
    if (cfg.fricGround !== undefined) mg.friction = cfg.fricGround;
    if (cfg.fricBody !== undefined) mb.friction = cfg.fricBody;
    if (cfg.rest !== undefined) { mg.restitution = cfg.rest; mb.restitution = cfg.rest; }
    if (cfg.restGround !== undefined) mg.restitution = cfg.restGround;
    if (cfg.cm) world.addContactMaterial(cfg.cmReversed ? new CANNON.ContactMaterial(mb, mg, cfg.cm) : new CANNON.ContactMaterial(mg, mb, cfg.cm));
  }
  return { world, mg, mb, cfg };
}
function slideScene(mode, fixedRotation = false) {
  const { world, mg, mb, cfg } = matBuild(mode);
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, material: mg,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const box = new CANNON.Body({ mass: 1, material: cfg.shapeMat ? null : mb, fixedRotation,
    shape: new CANNON.Box(new CANNON.Vec3(0.5, 0.5, 0.5)), position: new CANNON.Vec3(0, 0.501, 0) });
  if (cfg.shapeMat) { const sm = new CANNON.Material('shape'); sm.friction = cfg.fricShape; box.shapes[0].material = sm; }
  box.velocity.set(5, 0, 0);
  world.addBody(ground); world.addBody(box);
  let fricEqMax = 0; const profile = {};
  for (let i = 0; i < 180; i++) { world.step(DT); fricEqMax = Math.max(fricEqMax, world.frictionEquations.length); if ([15, 30, 60, 120].includes(i + 1)) profile[i + 1] = box.velocity.x; }
  const cm = world.defaultContactMaterial;
  const eff = (mg && mb) ? world.getContactMaterial(mg, mb) : undefined;
  return { x: box.position.x, vx: box.velocity.x, profile, fricEqMax, cmFriction: cm.friction, cmRestitution: cm.restitution, pairCm: eff ? `f${eff.friction}/r${eff.restitution}` : 'none', world };
}
function bounceScene(mode) {
  const { world, mg, mb, cfg } = matBuild(mode);
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, material: mg,
    shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
  const ball = new CANNON.Body({ mass: 1, material: cfg.shapeMat ? null : mb, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 3, 0) });
  world.addBody(ground); world.addBody(ball);
  let firstContact = -1, apex = -1, bounces = 0, rising = false;
  for (let i = 0; i < 300; i++) {
    world.step(DT);
    if (firstContact < 0 && world.contacts.length > 0) firstContact = i + 1;
    if (firstContact > 0) {
      if (ball.position.y > apex) { apex = ball.position.y; rising = true; }
      else if (rising && ball.velocity.y < 0) { if (apex > 0.55) bounces++; rising = false; }
    }
  }
  return { firstContact, apex, bounces, world };
}
function fricSlide(mu, mass, v0, steps = 2400) {
  const g = 9.82;
  const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -g, 0) });
  const mg = new CANNON.Material('g'); mg.friction = mu;
  const mb = new CANNON.Material('b'); mb.friction = mu;
  const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, material: mg,
    shape: new CANNON.Box(new CANNON.Vec3(200, 0.5, 200)), position: new CANNON.Vec3(0, -0.5, 0) });
  const ball = new CANNON.Body({ mass, material: mb, fixedRotation: true, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 0.501, 0) });
  ball.velocity.set(v0, 0, 0);
  world.addBody(ground); world.addBody(ball);
  let fricEqMax = 0;
  for (let i = 0; i < steps; i++) { world.step(DT); fricEqMax = Math.max(fricEqMax, world.frictionEquations.length); }
  const d = ball.position.x;
  const a = d > 0 ? (v0 * v0) / (2 * d) : Infinity;
  return { d, vx: ball.velocity.x, fricEqMax, a, ratio: a / (mu * g) };
}

// ---------------------------------------------------------------------------
// Cases — arm names match r94_cannon.gd ARM_CASES
// ---------------------------------------------------------------------------
const CASES = {
  // ---- det -----------------------------------------------------------------
  det_base: (c) => {
    const s = runSampled();
    M(c, 'base', `h=${worldHash(s.world, s.dyn)} ${SAMPLE_AT.map(k => s.samples[k]).join(' ')}`);
    M(c, 'meta', `contacts=${s.world.contacts.length} fric=${s.world.frictionEquations.length} sleep=${s.dyn.map(b => b.sleepState).join(',')} nan=${anyNaN(s.dyn)}`);
    M(c, 'ball', `x=${fx(s.ball.position.x, 9)} y=${fx(s.ball.position.y, 9)} q=${fx(s.ball.quaternion.x, 9)},${fx(s.ball.quaternion.y, 9)},${fx(s.ball.quaternion.z, 9)},${fx(s.ball.quaternion.w, 9)} stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(9)}`);
  },
  det_rebuild: (c) => {
    const a = runScene(), b = runScene();
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    M(c, 'rebuild', `h1=${ha} h2=${hb} eq=${ha === hb}`);
    M(c, 'ids', `ids1=${a.dyn.map(b => b.id).join(',')} ids2=${b.dyn.map(b => b.id).join(',')} ball.y=${fx(b.ball.position.y, 12)}`);
  },
  det_interleave: (c) => {
    const a = buildWorld(); stepFixed(a.world, 30, DT);
    const b = buildWorld(); stepFixed(b.world, 30, DT);
    stepFixed(a.world, 210, DT);
    const d = buildWorld(); stepFixed(d.world, 30, DT);
    const base = runScene();
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn), hc = worldHash(d.world, d.dyn), hbase = worldHash(base.world, base.dyn);
    M(c, 'interleave', `A=${ha} base=${hbase} eqA=${ha === hbase}`);
    M(c, 'bc', `B=${hb} C=${hc} eqBC=${hb === hc}`);
  },
  det_order_swap: (c) => {
    const f = runSampled({ order: 'forward' }), r = runSampled({ order: 'reverse' });
    const hf = worldHash(f.world, f.dyn), hr = worldHash(r.world, r.dyn);
    M(c, 'order', `forward=${hf} reverse=${hr} eq=${hf === hr}`);
    M(c, 'fwd', SAMPLE_AT.map(k => f.samples[k]).join(' '));
    M(c, 'rev', SAMPLE_AT.map(k => r.samples[k]).join(' '));
  },
  det_order_probe: (c) => {
    const f = orderRun('canon', 'forward'), r = orderRun('canon', 'reverse');
    M(c, 'order', `h_forward=${f.h} h_reverse=${r.h} eq=${f.h === r.h}`);
    M(c, 'solver', `rows=${f.sigRows}/${r.sigRows} rawSame=${f.rawSig === r.rawSig} sortedSame=${f.canonSig === r.canonSig}`);
  },
  det_sap: (c) => {
    const n = runSampled({ broadphase: 'naive' });
    const sap = runSampled({ broadphase: 'sap' });
    const hn = worldHash(n.world, n.dyn), hs = worldHash(sap.world, sap.dyn);
    M(c, 'broadphase', `naive=${hn} sap=${hs} eq=${hn === hs}`);
    const axes = [];
    for (const axis of [0, 1, 2]) {
      const v = buildWorld();
      const bp = new CANNON.SAPBroadphase(v.world); bp.axisIndex = axis; v.world.broadphase = bp;
      stepFixed(v.world, 240, DT);
      axes.push(`axis${axis}=${worldHash(v.world, v.dyn)}`);
    }
    M(c, 'axis', `${axes.join(' ')} eqSap=${axes.every(a => a.endsWith(hs))}`);
  },
  det_iters1: (c) => detVariant(c, 'iters1', { iterations: 1 }),
  det_iters5: (c) => detVariant(c, 'iters5', { iterations: 5 }),
  det_iters20: (c) => detVariant(c, 'iters20', { iterations: 20 }),
  det_tol0: (c) => detVariant(c, 'tol0', { tolerance: 0 }),
  det_tol1e3: (c) => detVariant(c, 'tol1e-3', { tolerance: 1e-3 }),
  det_steps_saturated: (c) => {
    const a = runScene(), b = runScene({}, 239);
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    M(c, 'steps-saturated', `240=${ha} 239=${hb} eq=${ha === hb} sleep=${a.dyn.map(x => x.sleepState).join(',')}`);
  },
  det_ulp: (c) => {
    const mag = 1e-9;
    const a = runSampled(), b = runSampled({ ballX: mag });
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    const dx = Math.abs(a.ball.position.x - b.ball.position.x);
    M(c, 'perturb', `mag=${mag} h_a=${ha} h_b=${hb} eq=${ha === hb}`);
    M(c, 'final', `dx=${dx.toExponential(6)} dy=${Math.abs(a.ball.position.y - b.ball.position.y).toExponential(6)} q=${Math.abs(a.ball.quaternion.x - b.ball.quaternion.x).toExponential(6)}`);
  },
  // ---- det2 ----------------------------------------------------------------
  det_iters_hist: (c) => {
    class CountingSolver extends CANNON.GSSolver {
      constructor() { super(); this.hist = new Map(); this.total = 0; this.steps = 0; }
      solve(dt, world) { const it = super.solve(dt, world); this.hist.set(it, (this.hist.get(it) ?? 0) + 1); this.total += it; this.steps += 1; return it; }
    }
    let i = 0;
    for (const tol of [1e-7, 1e-3, 0]) {
      const s = buildWorld();
      const solver = new CountingSolver();
      solver.iterations = DEFAULTS.iterations; solver.tolerance = tol;
      s.world.solver = solver;
      stepFixed(s.world, 240, DT);
      const hist = [...solver.hist.entries()].sort((x, y) => x[0] - y[0]).map(([k, v]) => `${k}x${v}`).join(',');
      M(c, `tol${i++}`, `tol=${tol} steps=${solver.steps} mean=${(solver.total / solver.steps).toFixed(3)} hist=${hist}`);
    }
  },
  det_perturb_track: (c) => {
    const mag = 1e-9;
    const a = buildWorld(), b = buildWorld({ ballX: mag });
    const track = []; const firstOver = {}; let lastD = 0;
    for (let i = 1; i <= 240; i++) {
      a.world.step(DT); b.world.step(DT);
      const d = Math.abs(a.ball.position.x - b.ball.position.x) + Math.abs(a.ball.position.y - b.ball.position.y);
      lastD = d;
      if (i % 20 === 0) track.push(`${i}:${d.toExponential(3)}`);
      for (const th of [1e-9, 1e-6, 1e-3]) if (firstOver[th] === undefined && d > th) firstOver[th] = i;
    }
    M(c, 'track', `mag=${mag} ${track.join(' ')}`);
    M(c, 'firstOver', `${Object.entries(firstOver).map(([k, v]) => `${k}@${v}`).join(' ') || 'none'} final=${lastD.toExponential(6)} growth=${(lastD / mag).toFixed(6)}`);
  },
  det_contacts_fwd: (c) => detContacts(c, 'forward'),
  det_contacts_rev: (c) => detContacts(c, 'reverse'),
  // ---- varstep -------------------------------------------------------------
  var_fixed: (c) => {
    const s = buildWorld(); stepFixed(s.world, 240, DT);
    M(c, 'fixed', `stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(9)} ball.y=${fx(s.ball.position.y, 12)}`);
    M(c, 'interp', `interpPos=${fx(s.ball.interpolatedPosition.x, 6)},${fx(s.ball.interpolatedPosition.y, 6)},${fx(s.ball.interpolatedPosition.z, 6)} pos=${fx(s.ball.position.x, 6)},${fx(s.ball.position.y, 6)},${fx(s.ball.position.z, 6)} eq=${vecBits(s.ball.interpolatedPosition) === vecBits(s.ball.position)}`);
    M(c, 'interpQ', `prevPos=${fx(s.ball.previousPosition.y, 6)} interpQuat=${quatBits(s.ball.interpolatedQuaternion)} quat=${quatBits(s.ball.quaternion)} qeq=${quatBits(s.ball.interpolatedQuaternion) === quatBits(s.ball.quaternion)}`);
  },
  var_exact: (c) => {
    const f = buildWorld(); stepFixed(f.world, 240, DT);
    const v = buildWorld();
    for (let i = 0; i < 240; i++) v.world.step(DT, DT, 10);
    const hf = worldHash(f.world, f.dyn), hv = worldHash(v.world, v.dyn);
    M(c, 'exact', `fixed=${hf} elapsed=dt ${hv} eq=${hf === hv} physEq=${physHash(f.dyn) === physHash(v.dyn)}`);
    M(c, 'counts', `fixed stepnumber=${f.world.stepnumber} time=${f.world.time.toFixed(9)} var stepnumber=${v.world.stepnumber} time=${v.world.time.toFixed(9)}`);
    M(c, 'interp', `var interpPos.y=${fx(v.ball.interpolatedPosition.y, 12)} pos.y=${fx(v.ball.position.y, 12)} fixed interpPos.y=${fx(f.ball.interpolatedPosition.y, 12)}`);
  },
  var_uneven: (c) => {
    const f = buildWorld(); stepFixed(f.world, 240, DT);
    const v = buildWorld();
    const sched = [1 / 90, 1 / 45];
    let elapsedTotal = 0;
    for (let i = 0; i < 240; i++) { const e = sched[i % 2]; elapsedTotal += e; v.world.step(DT, e, 1000); }
    const hf = worldHash(f.world, f.dyn), hv = worldHash(v.world, v.dyn);
    M(c, 'uneven', `fixed=${hf} uneven=${hv} eq=${hf === hv} physEq=${physHash(f.dyn) === physHash(v.dyn)}`);
    M(c, 'counts', `elapsedTotal=${elapsedTotal.toFixed(9)} world.time=${v.world.time.toFixed(9)} stepnumber=${v.world.stepnumber} fixedStepnumber=${f.world.stepnumber}`);
    M(c, 'ball', `ball.y=${fx(v.ball.position.y, 12)} fixedBall.y=${fx(f.ball.position.y, 12)} interpPos.y=${fx(v.ball.interpolatedPosition.y, 12)}`);
  },
  var_maxsub: (c) => {
    const v = buildWorld(); v.world.step(DT, 0.5, 10);
    M(c, 'maxsub', `stepnumber=${v.world.stepnumber} time=${v.world.time.toFixed(9)} accumulator=${v.world.accumulator.toExponential(6)} ball.y=${fx(v.ball.position.y, 12)}`);
    const v2 = buildWorld(); v2.world.step(DT, 0.5, 1000);
    M(c, 'maxsub1000', `stepnumber=${v2.world.stepnumber} time=${v2.world.time.toFixed(9)} ball.y=${fx(v2.ball.position.y, 12)}`);
    const f = buildWorld(); stepFixed(f.world, 30, DT);
    M(c, 'fixed30', `stepnumber=${f.world.stepnumber} time=${f.world.time.toFixed(9)} ball.y=${fx(f.ball.position.y, 12)}`);
  },
  var_interp: (c) => {
    const f = buildWorld(); stepFixed(f.world, 60, DT);
    const v = buildWorld(); for (let i = 0; i < 60; i++) v.world.step(DT, DT, 10);
    const w = buildWorld(); for (let i = 0; i < 60; i++) w.world.step(DT, DT + 1 / 240, 10);
    M(c, 'fixed', `interpPos.y=${fx(f.ball.interpolatedPosition.y, 9)} pos.y=${fx(f.ball.position.y, 9)}`);
    M(c, 'exact', `interpPos.y=${fx(v.ball.interpolatedPosition.y, 12)} pos.y=${fx(v.ball.position.y, 12)} prevPos.y=${fx(v.ball.previousPosition.y, 12)} interpEqPos=${vecBits(v.ball.interpolatedPosition) === vecBits(v.ball.position)}`);
    M(c, 'frac', `acc=${w.world.accumulator.toExponential(6)} interpPos.y=${fx(w.ball.interpolatedPosition.y, 12)} pos.y=${fx(w.ball.position.y, 12)} prevPos.y=${fx(w.ball.previousPosition.y, 12)}`);
    M(c, 'fracQ', `interpQuat=${quatBits(w.ball.interpolatedQuaternion)} quat=${quatBits(w.ball.quaternion)} qeq=${quatBits(w.ball.interpolatedQuaternion) === quatBits(w.ball.quaternion)}`);
  },
  var_sleep_phase: (c) => {
    const onsets = (s, log) => s.dyn.map(b => { if (b.sleepState === 2 && log[b.id] === undefined) log[b.id] = s.world.stepnumber; return log[b.id]; });
    const f = buildWorld(); const flog = {};
    for (let i = 0; i < 240; i++) { f.world.step(DT); onsets(f, flog); }
    const v = buildWorld(); const vlog = {};
    const sched = [1 / 90, 1 / 45];
    for (let i = 0; i < 240; i++) { v.world.step(DT, sched[i % 2], 1000); onsets(v, vlog); }
    const w = buildWorld(); const wlog = {};
    for (let i = 0; i < 240; i++) { w.world.step(DT, DT, 10); onsets(w, wlog); }
    const fmt = (log, s) => s.dyn.map(b => `${b.id}@${log[b.id] ?? 'never'}`).join(' ');
    M(c, 'fixed', `${fmt(flog, f)} time=${f.world.time.toFixed(9)}`);
    M(c, 'uneven', `${fmt(vlog, v)} time=${v.world.time.toFixed(9)}`);
    M(c, 'exact', `${fmt(wlog, w)} time=${w.world.time.toFixed(9)}`);
  },
  // ---- bailout (isolated: boundary-flagged wall-budget edge) ---------------
  var_bailout: (c) => {
    const tiny = buildWorld(); tiny.world.step(1e-5, 1e-3, 1000);
    M(c, 'bailout', `dt=1e-5 elapsed=1e-3 maxSubSteps=1000 stepnumber=${tiny.world.stepnumber} time=${tiny.world.time.toExponential(6)} accumulator=${tiny.world.accumulator.toExponential(6)} ball.y=${fx(tiny.ball.position.y, 12)}`);
    const control = buildWorld(); control.world.step(1e-5, 1e-3, 1);
    M(c, 'control', `dt=1e-5 elapsed=1e-3 maxSubSteps=1 stepnumber=${control.world.stepnumber} time=${control.world.time.toExponential(6)} ball.y=${fx(control.ball.position.y, 12)}`);
  },
  // ---- nan (canonical hash; raw payload bits are NOT pinned — boundary §3) --
  nan_all: (c) => {
    const NANCASES = nanCaseTable();
    const rows = [];
    for (const name of Object.keys(NANCASES)) {
      let s;
      try { s = NANCASES[name](); }
      catch (err) { rows.push({ name, nan: false }); M(c, name, `threw="${err.message}"`); continue; }
      const bodies = s.dyn;
      const nan = anyNaN(bodies), inf = anyInf(bodies);
      const where = bodies.map((b, i) => {
        const fields = [];
        for (const [k, v] of [['p', b.position], ['q', b.quaternion], ['v', b.velocity], ['w', b.angularVelocity]])
          if (Number.isNaN(v.x) || Number.isNaN(v.y) || Number.isNaN(v.z)) fields.push(`${i}.${k}`);
        return fields.join('+');
      }).filter(Boolean).join(',') || 'none';
      rows.push({ name, nan, inf });
      M(c, name, `nan=${nan} inf=${inf} where=${where} h=${canonHash(bodies)} ${s.note}`);
    }
    const nanCases = rows.filter(r => r.nan).map(r => r.name);
    const infCases = rows.filter(r => r.inf && !r.nan).map(r => r.name);
    M(c, 'summary', `cases=${rows.length} nan=${nanCases.length} [${nanCases.join(',')}] inf_only=${infCases.length} [${infCases.join(',')}]`);
  },
  // ---- sync -----------------------------------------------------------------
  sync_full: (c) => {
    const { world, box } = tumbleScene();
    const obj = mesh();
    obj.position.set(box.position.x, box.position.y, box.position.z);
    obj.quaternion.set(box.quaternion.x, box.quaternion.y, box.quaternion.z, box.quaternion.w);
    obj.updateMatrixWorld(true);
    const wp = obj.getWorldPosition(new THREE.Vector3());
    const wq = obj.getWorldQuaternion(new THREE.Quaternion());
    const dPos = wp.distanceTo(bodyWorldPos(box)), dRot = angleDeg(wq, box.quaternion);
    M(c, 'full', `dPos=${dPos.toExponential(3)} dRotDeg=${dRot.toExponential(3)} objQ=${quatBits(obj.quaternion)} bodyQ=${quatBits(box.quaternion)} qEq=${quatBits(obj.quaternion) === quatBits(box.quaternion)}`);
    M(c, 'mw', `matrixWorld[12,13,14]=${fx(obj.matrixWorld.elements[12], 9)},${fx(obj.matrixWorld.elements[13], 9)},${fx(obj.matrixWorld.elements[14], 9)} body=${fx(box.position.x, 9)},${fx(box.position.y, 9)},${fx(box.position.z, 9)}`);
  },
  sync_pos_only: (c) => {
    const { world, box } = tumbleScene(0);
    const obj = mesh(); let maxRot = 0;
    for (let i = 0; i < 240; i++) {
      world.step(DT);
      obj.position.set(box.position.x, box.position.y, box.position.z);
      obj.updateMatrixWorld(true);
      maxRot = Math.max(maxRot, angleDeg(obj.getWorldQuaternion(new THREE.Quaternion()), box.quaternion));
    }
    const dPos = obj.getWorldPosition(new THREE.Vector3()).distanceTo(bodyWorldPos(box));
    M(c, 'pos_only', `dPos=${dPos.toExponential(3)} maxRotDeg=${maxRot.toFixed(6)} finalRotDeg=${angleDeg(obj.getWorldQuaternion(new THREE.Quaternion()), box.quaternion).toFixed(6)}`);
    M(c, 'q', `objQ=${quatBits(obj.quaternion)} bodyQ=${quatBits(box.quaternion)} bodyW=${fx(box.angularVelocity.x, 6)},${fx(box.angularVelocity.y, 6)},${fx(box.angularVelocity.z, 6)}`);
  },
  sync_quat_only: (c) => {
    const { world, box } = tumbleScene(0);
    const obj = mesh();
    for (let i = 0; i < 240; i++) {
      world.step(DT);
      obj.quaternion.set(box.quaternion.x, box.quaternion.y, box.quaternion.z, box.quaternion.w);
      obj.updateMatrixWorld(true);
    }
    const dPos = obj.getWorldPosition(new THREE.Vector3()).distanceTo(bodyWorldPos(box));
    const dRot = angleDeg(obj.getWorldQuaternion(new THREE.Quaternion()), box.quaternion);
    M(c, 'quat_only', `dPos=${dPos.toFixed(6)} dRotDeg=${dRot.toExponential(3)} objPos=${fx(obj.position.x, 6)},${fx(obj.position.y, 6)},${fx(obj.position.z, 6)} bodyPos=${fx(box.position.x, 6)},${fx(box.position.y, 6)},${fx(box.position.z, 6)}`);
  },
  sync_nested: (c) => syncNested(c, false),
  sync_scale_parent: (c) => syncNested(c, true),
  sync_zero_quat: (c) => {
    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, 0, 0) });
    const b = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(1, 2, 3) });
    b.quaternion.set(0, 0, 0, 0);
    world.addBody(b); world.step(DT);
    const obj = mesh();
    obj.position.set(b.position.x, b.position.y, b.position.z);
    obj.quaternion.set(b.quaternion.x, b.quaternion.y, b.quaternion.z, b.quaternion.w);
    obj.updateMatrixWorld(true);
    const wq = obj.getWorldQuaternion(new THREE.Quaternion());
    const els = obj.matrixWorld.elements;
    const threeNorm = new THREE.Quaternion(0, 0, 0, 0).normalize();
    M(c, 'zero_quat', `cannonQ=${quatBits(b.quaternion)} threeCopied=${quatBits(obj.quaternion)} worldQ=${fx(wq.x, 6)},${fx(wq.y, 6)},${fx(wq.z, 6)},${fx(wq.w, 6)} threeNormalized=${fx(threeNorm.x, 6)},${fx(threeNorm.y, 6)},${fx(threeNorm.z, 6)},${fx(threeNorm.w, 6)}`);
    M(c, 'mw', `matrixWorld=[${els.map(e => fx(e, 3)).join(',')}] detScale=${fx(new THREE.Matrix4().copy(obj.matrixWorld).determinant(), 6)}`);
  },
  sync_interp: (c) => {
    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
    const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
    const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
    world.addBody(ground); world.addBody(ball);
    const obj = mesh();
    for (let i = 0; i < 60; i++) {
      world.step(DT);
      obj.position.set(ball.interpolatedPosition.x, ball.interpolatedPosition.y, ball.interpolatedPosition.z);
      obj.quaternion.set(ball.interpolatedQuaternion.x, ball.interpolatedQuaternion.y, ball.interpolatedQuaternion.z, ball.interpolatedQuaternion.w);
      obj.updateMatrixWorld(true);
    }
    const dPos = obj.getWorldPosition(new THREE.Vector3()).distanceTo(bodyWorldPos(ball));
    M(c, 'interp', `interpPos.y=${fx(ball.interpolatedPosition.y, 9)} bodyPos.y=${fx(ball.position.y, 9)} objWorld.y=${fx(obj.getWorldPosition(new THREE.Vector3()).y, 9)} dPos=${dPos.toFixed(6)}`);
    M(c, 'q', `interpQ=${quatBits(ball.interpolatedQuaternion)} bodyQ=${quatBits(ball.quaternion)}`);
  },
  sync_matrix_auto: (c) => {
    const { world, box } = tumbleScene();
    const obj = mesh();
    const q = new THREE.Quaternion(box.quaternion.x, box.quaternion.y, box.quaternion.z, box.quaternion.w);
    const p = bodyWorldPos(box);
    obj.matrixAutoUpdate = false;
    obj.matrix.compose(p, q, new THREE.Vector3(1, 1, 1));
    obj.matrixWorldNeedsUpdate = true;
    obj.updateMatrixWorld(true);
    const okErr = obj.getWorldPosition(new THREE.Vector3()).distanceTo(p);
    const obj2 = mesh();
    obj2.position.copy(p); obj2.quaternion.copy(q);
    obj2.matrixAutoUpdate = false;
    obj2.matrix.compose(new THREE.Vector3(0, 0, 0), new THREE.Quaternion(), new THREE.Vector3(1, 1, 1));
    obj2.updateMatrixWorld(true);
    const staleErr = obj2.getWorldPosition(new THREE.Vector3()).distanceTo(p);
    const pLen = p.length();
    M(c, 'matrix_auto', `manualComposeErr=${okErr.toExponential(3)} autoUpdateOffStaleErr=${staleErr.toFixed(6)} pLen=${pLen.toFixed(6)}`);
  },
  sync_lag: (c) => {
    const { world, box } = tumbleScene(0);
    const obj = mesh(); let maxLag = 0; let prev = null;
    for (let i = 0; i < 240; i++) {
      world.step(DT);
      obj.position.set(box.position.x, box.position.y, box.position.z);
      obj.quaternion.set(box.quaternion.x, box.quaternion.y, box.quaternion.z, box.quaternion.w);
      const stale = obj.getWorldPosition(new THREE.Vector3());
      if (prev) maxLag = Math.max(maxLag, stale.distanceTo(prev));
      prev = bodyWorldPos(box);
      obj.updateMatrixWorld(true);
    }
    const after = obj.getWorldPosition(new THREE.Vector3()).distanceTo(bodyWorldPos(box));
    M(c, 'lag', `maxStaleGap=${maxLag.toFixed(6)} afterUpdateErr=${after.toExponential(3)}`);
  },
  // ---- material -------------------------------------------------------------
  mat_all: (c) => {
    const rows = [];
    for (const mode of Object.keys(MODES)) {
      const s = slideScene(mode), sf = slideScene(mode, true), b = bounceScene(mode);
      rows.push({ mode, slideX: s.x, fixedX: sf.x, apex: b.apex, fricEqMax: s.fricEqMax });
      M(c, mode, `slideX=${fx(s.x, 9)} slideVx=${fx(s.vx, 9)} fricEqMax=${s.fricEqMax} defaultCm=f${s.cmFriction}/r${s.cmRestitution} pairCm=${s.pairCm} apex=${fx(b.apex, 9)} bounces=${b.bounces}`);
      M(c, `${mode}_fr`, `slideX=${fx(sf.x, 9)} vx=${fx(sf.vx, 9)} profile=${Object.entries(sf.profile).map(([k, v]) => `${k}:${v.toFixed(4)}`).join(' ')}`);
    }
    const by = (k) => rows.map(r => `${r.mode}:${r[k].toFixed(6)}`).join(' ');
    M(c, 'sum_slideX', by('slideX'));
    M(c, 'sum_fixedRotX', by('fixedX'));
    M(c, 'sum_apex', by('apex'));
    M(c, 'sum_fricEqMax', by('fricEqMax'));
  },
  mat_fric_sweep: (c) => {
    const g = 9.82;
    for (const mu of [0, 0.0005, 0.001, 0.002, 0.005, 0.01, 0.05, 0.3, 0.9]) {
      const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -g, 0) });
      const mg = new CANNON.Material('g'); mg.friction = mu;
      const mb = new CANNON.Material('b'); mb.friction = mu;
      const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, material: mg, shape: new CANNON.Box(new CANNON.Vec3(200, 0.5, 200)), position: new CANNON.Vec3(0, -0.5, 0) });
      const ball = new CANNON.Body({ mass: 1, material: mb, fixedRotation: true, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 0.501, 0) });
      ball.velocity.set(5, 0, 0);
      world.addBody(ground); world.addBody(ball);
      let fricEqMax = 0;
      for (let i = 0; i < 2400; i++) { world.step(DT); fricEqMax = Math.max(fricEqMax, world.frictionEquations.length); }
      const predicted = mu === 0 ? Infinity : (25 / (4 * mu * g));
      M(c, `mu${mu}`, `mu=${mu} slideX=${fx(ball.position.x, 6)} vx=${fx(ball.velocity.x, 6)} fricEqMax=${fricEqMax} predicted=${predicted === Infinity ? 'inf' : fx(predicted, 6)}`);
    }
  },
  // ---- friction (boundary's corrected law: mass-inert, mu- and v0-dependent) -
  fric_corrected: (c) => {
    const rows = [];
    const slide = (tag, mu, mass, v0) => {
      const r = fricSlide(mu, mass, v0);
      rows.push(`${tag} slideX=${fx(r.d, 6)} vx=${fx(r.vx, 6)} fricEqMax=${r.fricEqMax} a=${fx(r.a, 3)} aOverMuG=${mu === 0 ? 'inf' : fx(r.ratio, 3)}`);
    };
    slide('base_mu0.3_m1_v5', 0.3, 1, 5);
    slide('m0.25', 0.3, 0.25, 5); slide('m2', 0.3, 2, 5); slide('m10', 0.3, 10, 5);
    slide('mu0.05', 0.05, 1, 5); slide('mu0.9', 0.9, 1, 5);
    slide('v0_1', 0.3, 1, 1); slide('v0_20', 0.3, 1, 20);
    for (let i = 0; i < rows.length; i++) M(c, `s${i}`, rows[i]);
  },
  // ---- parity ---------------------------------------------------------------
  par_defaults: (c) => {
    const w = new CANNON.World({});
    const b = new CANNON.Body({ mass: 1 });
    const w2 = new CANNON.World({ allowSleep: true });
    M(c, 'world_defaults', `world.allowSleep=${w.allowSleep} world2.allowSleep=${w2.allowSleep} body.allowSleep=${b.allowSleep} body.sleepSpeedLimit=${b.sleepSpeedLimit} body.sleepTimeLimit=${b.sleepTimeLimit} default_dt=${w.default_dt} solver.iterations=${w.solver.iterations} solver.tolerance=${w.solver.tolerance} broadphase=${w.broadphase.constructor.name} defaultContactMaterial=f${w.defaultContactMaterial.friction}/r${w.defaultContactMaterial.restitution}`);
  },
  par_shrink: (c) => {
    const { world, ball } = restScene();
    stepFixed(world, 120, DT);
    const preN = world.contacts.length, preY = ball.position.y;
    ball.shapes[0].radius = 0.25;
    const writeTick = { n: world.contacts.length, y: ball.position.y, v: ball.velocity.y };
    world.step(DT);
    const nextTick = { n: world.contacts.length, y: ball.position.y, v: ball.velocity.y, step: world.stepnumber };
    const seq = [];
    for (let i = 0; i < 20; i++) { world.step(DT); seq.push(`s${world.stepnumber}:${fx(ball.position.y, 6)}/${world.contacts.length}`); }
    M(c, 'shape_shrink', `pre n=${preN} y=${fx(preY, 6)} writeTick n=${writeTick.n} y=${fx(writeTick.y, 6)} v=${fx(writeTick.v, 6)} nextTick n=${nextTick.n} y=${fx(nextTick.y, 6)} v=${fx(nextTick.v, 6)}`);
    M(c, 'seq', seq.join(' '));
  },
  par_grow: (c) => {
    const { world, ball } = restScene();
    stepFixed(world, 120, DT);
    const before = ball.position.y;
    ball.shapes[0].radius = 1.0;
    const seq = [];
    for (let i = 0; i < 12; i++) { world.step(DT); seq.push(`s${world.stepnumber}:${fx(ball.position.y, 6)}/${world.contacts.length}`); }
    M(c, 'shape_grow', `before=${fx(before, 6)} seq ${seq.join(' ')}`);
  },
  par_shared: (c) => {
    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
    const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
    const shared = new CANNON.Sphere(0.5);
    const b1 = new CANNON.Body({ mass: 1, position: new CANNON.Vec3(-2, 0.5, 0) });
    const b2 = new CANNON.Body({ mass: 1, position: new CANNON.Vec3(2, 0.5, 0) });
    b1.addShape(shared); b2.addShape(shared);
    world.addBody(ground); world.addBody(b1); world.addBody(b2);
    stepFixed(world, 60, DT);
    const y0 = [b1.position.y, b2.position.y];
    shared.radius = 0.25;
    stepFixed(world, 60, DT);
    M(c, 'shape_shared', `sameObject=${b1.shapes[0] === b2.shapes[0]} yBefore=${fx(y0[0], 6)},${fx(y0[1], 6)} yAfter=${fx(b1.position.y, 6)},${fx(b2.position.y, 6)} sharedRadius=${shared.radius}`);
  },
  // ---- parity2 --------------------------------------------------------------
  par_sleep_nat: (c) => {
    const { world, ball } = restScene(true);
    let sleepStep = -1;
    for (let i = 0; i < 400; i++) { world.step(DT); if (sleepStep < 0 && ball.sleepState === CANNON.Body.SLEEPING) sleepStep = world.stepnumber; }
    const stateAfterSleep = { state: ball.sleepState, y: ball.position.y, v: ball.velocity.y };
    const yBefore = ball.position.y;
    ball.velocity.set(0, 5, 0);
    world.step(DT);
    const afterVelWrite = { y: ball.position.y, v: ball.velocity.y, state: ball.sleepState };
    ball.wakeUp(); world.step(DT);
    const afterWakeUp = { y: ball.position.y, v: ball.velocity.y, state: ball.sleepState };
    M(c, 'sleep_natural', `world.allowSleep=${world.allowSleep} sleepStep=${sleepStep} state=${stateAfterSleep.state} y=${fx(stateAfterSleep.y, 6)} v=${fx(stateAfterSleep.v, 6)}`);
    M(c, 'velWrite', `y=${fx(afterVelWrite.y, 6)} v=${fx(afterVelWrite.v, 6)} state=${afterVelWrite.state} thenWakeUp y=${fx(afterWakeUp.y, 6)} v=${fx(afterWakeUp.v, 6)} state=${afterWakeUp.state} (yBefore=${fx(yBefore, 6)})`);
  },
  par_sleep_wake: (c) => {
    const { world, ball } = restScene(true);
    stepFixed(world, 400, DT);
    const slept = ball.sleepState;
    const mover = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 3, 0) });
    world.addBody(mover);
    const rows = [];
    for (let i = 0; i < 60; i++) { world.step(DT); if (i < 40) rows.push(`${world.stepnumber}:${mover.position.y.toFixed(4)}/${ball.sleepState}/${world.contacts.length}`); }
    M(c, 'sleep_wake', `sleptBefore=${slept} moverSpeedLimit=${ball.sleepSpeedLimit} rows ${rows.filter((_, i) => i % 5 === 0).join(' ')}`);
    M(c, 'final', `sleeperState=${ball.sleepState} sleeperY=${fx(ball.position.y, 6)} moverY=${fx(mover.position.y, 6)} contacts=${world.contacts.length}`);
  },
  par_contact_rest: (c) => {
    const rows = [];
    for (const allowSleep of [false, true]) {
      const { world, ground, ball } = restScene(allowSleep);
      for (let i = 0; i < 400; i++) {
        world.step(DT);
        if ([1, 10, 60, 100, 150, 200, 300, 400].includes(world.stepnumber))
          rows.push(`allowSleep=${allowSleep} s${world.stepnumber}:n=${world.contacts.length}/ball=${ball.sleepState}/ground=${ground.sleepState}/y=${fx(ball.position.y, 6)}`);
      }
    }
    M(c, 'contact_rest', rows.filter((_, i) => i % 2 === 1 || i > 13).join(' '));
  },
  par_multishape: (c) => {
    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
    const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
    const two = new CANNON.Body({ mass: 1, position: new CANNON.Vec3(0, 0.5, 0) });
    two.addShape(new CANNON.Sphere(0.5), new CANNON.Vec3(-0.6, 0, 0));
    two.addShape(new CANNON.Sphere(0.5), new CANNON.Vec3(0.6, 0, 0));
    world.addBody(ground); world.addBody(two);
    const rows = [];
    for (let i = 0; i < 120; i++) {
      world.step(DT);
      if ([1, 2, 3, 30, 60].includes(world.stepnumber))
        rows.push(`s${world.stepnumber}:n=${world.contacts.length} [${world.contacts.map(cc => `si${two.shapes.indexOf(cc.si)}-sj${ground.shapes.indexOf(cc.sj)}`).join(' ')}]`);
    }
    M(c, 'multishape_order', `shapeIds=${two.shapes.map(s => s.id).join(',')} offsets=${two.shapeOffsets.map(o => o.x).join(',')} rows ${rows.join(' ')}`);
  },
  par_sleep_thresh: (c) => {
    const rows = [];
    for (const [limit, time] of [[0.1, 1], [0.01, 1], [0.5, 1], [0.1, 0.1], [0.1, 5], [0, 1], [0.5, 0]]) {
      const { world, ball } = restScene(true);
      ball.sleepSpeedLimit = limit; ball.sleepTimeLimit = time;
      let sleepStep = -1;
      for (let i = 0; i < 900; i++) { world.step(DT); if (sleepStep < 0 && ball.sleepState === CANNON.Body.SLEEPING) sleepStep = world.stepnumber; }
      rows.push(`limit=${limit}/time=${time}:${sleepStep < 0 ? 'never' : sleepStep}`);
    }
    M(c, 'sleep_thresholds', `defaults=limit0.1/time1 ${rows.join(' ')}`);
  },
  // ---- modes (boundary's corrected laws) ------------------------------------
  mod_internal: (c) => {
    const s = buildWorld();
    for (let i = 0; i < 240; i++) s.world.internalStep(DT);
    M(c, 'internal', `h=${worldHash(s.world, s.dyn)} ph=${physHash(s.dyn)} eqBase=${worldHash(s.world, s.dyn) === BASE} stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} ball.y=${fx(s.ball.position.y, 9)} sleep=${s.dyn.map(b => b.sleepState).join(',')}`);
  },
  mod_internal_clocked: (c) => {
    const s = buildWorld();
    for (let i = 0; i < 240; i++) { s.world.internalStep(DT); s.world.time += DT; }
    const h = worldHash(s.world, s.dyn);
    M(c, 'internal-clocked', `h=${h} ph=${physHash(s.dyn)} eqBase=${h === BASE} time=${s.world.time.toFixed(12)} ball.y=${fx(s.ball.position.y, 9)} sleep=${s.dyn.map(b => b.sleepState).join(',')}`);
  },
  mod_dt_zero_acc: (c) => {
    const s = buildWorld();
    s.world.step(0, DT, 10);
    const after = { step: s.world.stepnumber, time: s.world.time, acc: s.world.accumulator, y: s.ball.position.y };
    s.world.step(DT, DT, 10);
    M(c, 'afterFirst', `stepnumber=${after.step} time=${after.time.toFixed(12)} acc=${Number.isNaN(after.acc) ? 'NaN' : after.acc.toExponential(17)} ball.y=${fx(after.y, 9)}`);
    M(c, 'afterNext', `stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} acc=${Number.isNaN(s.world.accumulator) ? 'NaN' : s.world.accumulator.toExponential(17)} ball.y=${fx(s.ball.position.y, 9)} frozen=${s.ball.position.y === after.y}`);
  },
  mod_dt_neg_acc: (c) => {
    const s = buildWorld();
    s.world.step(-DT, DT, 10);
    M(c, 'dt-neg-acc', `stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} acc=${s.world.accumulator.toExponential(17)} ball.y=${fx(s.ball.position.y, 9)} ball.v=${fx(s.ball.velocity.y, 9)} h=${worldHash(s.world, s.dyn)}`);
  },
  mod_two_arg: (c) => {
    const s = buildWorld();
    s.world.step(DT, 0.5);
    M(c, 'two-arg', `stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} accumulator=${s.world.accumulator.toExponential(17)} ball.y=${fx(s.ball.position.y, 9)} h=${worldHash(s.world, s.dyn)}`);
  },
  mod_elapsed_half: (c) => {
    const s = buildWorld();
    for (let i = 0; i < 10; i++) s.world.step(DT, DT / 2);
    const b = s.ball;
    M(c, 'elapsed-half', `calls=10 stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} acc=${s.world.accumulator.toExponential(17)} pos.y=${fx(b.position.y, 9)} interpPos.y=${fx(b.interpolatedPosition.y, 9)} prevPos.y=${fx(b.previousPosition.y, 9)}`);
  },
  mod_elapsed_neg: (c) => {
    const s = buildWorld();
    stepFixed(s.world, 240, DT);
    const before = { p: s.ball.position.y, ip: s.ball.interpolatedPosition.y };
    s.world.step(DT, -DT);
    const b = s.ball;
    M(c, 'neg-elapsed', `stepnumber=${s.world.stepnumber} time=${s.world.time.toFixed(12)} acc=${s.world.accumulator.toExponential(17)} beforePos=${fx(before.p, 9)} beforeInterp=${fx(before.ip, 9)} pos.y=${fx(b.position.y, 9)} interpPos.y=${fx(b.interpolatedPosition.y, 9)}`);
  },
  mod_fixedstep: (c) => {
    // CLASS pin, never a count pin: 240 tight-loop calls did not run 240 ticks.
    // `fixedStep`'s elapsed source is performance.now(); the measured count is
    // emitted as a '#' diagnostic only (1 in every measured rep, idle+load).
    const s = buildWorld();
    for (let i = 0; i < 240; i++) s.world.fixedStep(DT, 10);
    const modeOk = s.world.stepnumber < 240;
    console.log(`# fixedstep measured stepnumber=${s.world.stepnumber} ph=${physHash(s.dyn)}`);
    M(c, 'fixedstep', `calls=240 class=wallclock mode_ok=${modeOk ? 1 : 0} ticks_lt_calls=${s.world.stepnumber < 240}`);
  },
  // ---- order (corrected add-order law) --------------------------------------
  ord_canon: (c) => orderCase(c, 'canon'),
  ord_asym2: (c) => orderCase(c, 'asym2'),
  ord_stack3: (c) => orderCase(c, 'stack3'),
  ord_tri: (c) => orderCase(c, 'tri'),
  // ---- backends --------------------------------------------------------------
  be_broadphase: (c) => {
    const variants = [];
    const run = (label, mutate) => {
      const s = buildWorld(); mutate(s.world); stepFixed(s.world, 240, DT);
      const h = worldHash(s.world, s.dyn), ph = physHash(s.dyn);
      variants.push({ label, h });
      M(c, label, `h=${h} ph=${ph} eqBase=${h === BASE} ball.y=${fx(s.ball.position.y, 9)}`);
    };
    run('naive', () => {});
    run('sap_default', (w) => { w.broadphase = new CANNON.SAPBroadphase(w); });
    for (const axis of [0, 1, 2]) run(`sap_axis${axis}`, (w) => { const bp = new CANNON.SAPBroadphase(w); bp.axisIndex = axis; w.broadphase = bp; });
    // GridBroadphase nx=1 is the only usable grid (single bin == naive).
    const g = buildWorld();
    g.world.broadphase = new CANNON.GridBroadphase(new CANNON.Vec3(-12, -12, -12), new CANNON.Vec3(12, 12, 12), 1, 1, 1);
    g.world.step(DT);
    const naiveY = runSampled({ steps: 1 }).ball.position.y;
    M(c, 'grid1', `step=1 y=${fx(g.ball.position.y, 9)} naiveY=${fx(naiveY, 9)} eq=${g.ball.position.y === naiveY}`);
  },
  be_solver: (c) => {
    const rows = [];
    const run = (label, mutate) => {
      const s = buildWorld(); mutate(s.world); stepFixed(s.world, 240, DT);
      const h = worldHash(s.world, s.dyn), ph = physHash(s.dyn);
      rows.push(h);
      M(c, label, `h=${h} ph=${ph} eqBase=${h === BASE} ball.y=${fx(s.ball.position.y, 9)} contacts=${s.world.contacts.length} fric=${s.world.frictionEquations.length}`);
    };
    run('gs_default', () => {});
    run('gs_iters1', (w) => { w.solver.iterations = 1; });
    run('gs_iters5', (w) => { w.solver.iterations = 5; });
    run('gs_iters20', (w) => { w.solver.iterations = 20; });
    run('split_gs_default', (w) => { w.solver = new CANNON.SplitSolver(new CANNON.GSSolver()); });
    run('split_gs_iters1', (w) => { const s = new CANNON.SplitSolver(new CANNON.GSSolver()); s.iterations = 1; w.solver = s; });
    run('split_gs_iters20', (w) => { const s = new CANNON.SplitSolver(new CANNON.GSSolver()); s.iterations = 20; w.solver = s; });
    run('split_subsolver_iters1', (w) => { const sub = new CANNON.GSSolver(); sub.iterations = 1; w.solver = new CANNON.SplitSolver(sub); });
    M(c, 'summary', `variants=${rows.length} distinctHashes=${new Set(rows).size} gsEqBase=${rows[0] === BASE}`);
  },
  // ---- negatives -------------------------------------------------------------
  neg_dt: (c) => {
    const a = runScene(), b = runScene({ dt: 1 / 59.9 });
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    if (ha === hb) fail(`neg-dt dt=1/59.9 produced the same hash ${ha}`);
    reject(`neg-dt dt=1/59.9 moves the hash ${ha}->${hb} ball.y=${fx(b.ball.position.y, 9)}`);
  },
  neg_gravity: (c) => {
    const a = runScene(), b = runScene({ gravity: [0, -9.83, 0] });
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    if (ha === hb) fail(`neg-gravity g=-9.83 produced the same hash ${ha}`);
    reject(`neg-gravity g=-9.83 moves the hash ${ha}->${hb} ball.y=${fx(b.ball.position.y, 9)}`);
  },
  neg_steps_early: (c) => {
    const a = runScene(), b = runScene({}, 120);
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    if (ha === hb) fail(`neg-steps-early 120 steps produced the same hash ${ha}`);
    reject(`neg-steps-early 120 vs 240 moves the hash ${ha}->${hb} ball.y=${fx(b.ball.position.y, 9)}`);
  },
  neg_elapsed: (c) => {
    const a = buildWorld(); for (let i = 0; i < 240; i++) a.world.step(DT, DT, 10);
    const b = buildWorld(); for (let i = 0; i < 240; i++) b.world.step(DT, DT + (i % 2 === 0 ? 1e-6 : -1e-6), 10);
    const ha = worldHash(a.world, a.dyn), hb = worldHash(b.world, b.dyn);
    if (ha === hb) fail(`neg-elapsed a 1e-6 elapsed jitter produced the same hash ${ha}`);
    reject(`neg-elapsed elapsed jitter 1e-6 moves the hash ${ha}->${hb} stepnumber=${a.world.stepnumber},${b.world.stepnumber}`);
  },
  neg_wxyz: (c) => {
    const { box } = tumbleScene();
    const q = new THREE.Quaternion(box.quaternion.w, box.quaternion.x, box.quaternion.y, box.quaternion.z);
    const err = angleDeg(q, box.quaternion);
    if (err < 1) fail(`neg_wxyz w-first copy did not change the rotation (err=${err})`);
    reject(`neg-wxyz w-first ordering rotates the mesh by ${err.toFixed(3)} deg`);
  },
  neg_grid: (c) => {
    // Refusal class: GridBroadphase is usable ONLY at nx=1 (the live control);
    // nx=2..4 die in Narrowphase.getContacts on corrupt pair lists (boundary
    // §9). nx=10 (hang/RangeError at ~20 s) is a documented non-authored class.
    const g = buildWorld();
    g.world.broadphase = new CANNON.GridBroadphase(new CANNON.Vec3(-12, -12, -12), new CANNON.Vec3(12, 12, 12), 1, 1, 1);
    g.world.step(DT);
    const control = g.ball.position.y;
    if (Math.abs(control - 4.997272222) > 1e-9) fail(`neg-grid nx=1 live control failed y=${control}`);
    const errs = [];
    for (const nx of [2, 3, 4]) {
      const s = buildWorld();
      s.world.broadphase = new CANNON.GridBroadphase(new CANNON.Vec3(-12, -12, -12), new CANNON.Vec3(12, 12, 12), nx, nx, nx);
      try { for (let i = 0; i < 60; i++) s.world.step(DT); errs.push(`nx${nx}:no-throw`); }
      catch (e) { errs.push(`nx${nx}:${e.constructor.name}:${e.message}`); }
    }
    const refused = errs.every(e => e.includes('TypeError') && e.includes('material'));
    if (!refused) fail(`neg-grid expected TypeError refusal, got ${errs.join(' ')}`);
    reject(`neg-grid broadphase refused nx=2,3,4 TypeError=Cannot read properties of undefined (reading 'material') nx1_ok_y=${fx(control, 9)}`);
  },
};

function detVariant(c, label, opts) {
  const base = runScene();
  const hbase = worldHash(base.world, base.dyn);
  const v = runScene(opts);
  const hv = worldHash(v.world, v.dyn);
  M(c, label, `base=${hbase} variant=${hv} eq=${hbase === hv} ball.y=${fx(v.ball.position.y, 12)}`);
}
function detContacts(c, order) {
  const s = buildWorld({ order });
  const rows = [];
  let maxN = 0;
  for (let i = 0; i < 240; i++) {
    s.world.step(DT);
    if (s.world.contacts.length > 0) {
      maxN = Math.max(maxN, s.world.contacts.length);
      if ([1, 2, 3, 30, 60, 61, 62, 120, 200].includes(i + 1)) {
        const pairs = s.world.contacts.map(cc => `${cc.bi.id}-${cc.bj.id}/${cc.si.id}-${cc.sj.id}`).join(' ');
        rows.push(`step=${i + 1} n=${s.world.contacts.length} fric=${s.world.frictionEquations.length} ${pairs}`);
      }
    }
  }
  let i = 0;
  for (const r of rows) M(c, `s${i++}`, r);
  M(c, 'max', `order=${order} maxN=${maxN} rows=${rows.length}`);
}
function syncNested(c, scaled) {
  const { world, box } = tumbleScene();
  const parent = new THREE.Object3D();
  parent.position.set(10, 0, 0);
  parent.rotation.y = Math.PI / 2;
  if (scaled) parent.scale.set(2, 2, 2);
  const child = mesh();
  parent.add(child);
  parent.updateMatrixWorld(true);
  const bodyP = bodyWorldPos(box);
  child.position.copy(bodyP);
  child.updateMatrixWorld(true);
  const naiveWorld = child.getWorldPosition(new THREE.Vector3());
  const naiveErr = naiveWorld.distanceTo(bodyP);
  const local = parent.worldToLocal(bodyP.clone());
  child.position.copy(local);
  child.updateMatrixWorld(true);
  const fixedWorld = child.getWorldPosition(new THREE.Vector3());
  const fixedErr = fixedWorld.distanceTo(bodyP);
  const label = scaled ? 'scale_parent' : 'nested';
  M(c, label, `naiveWorld=${fx(naiveWorld.x, 6)},${fx(naiveWorld.y, 6)},${fx(naiveWorld.z, 6)} bodyWorld=${fx(bodyP.x, 6)},${fx(bodyP.y, 6)},${fx(bodyP.z, 6)} naiveErr=${naiveErr.toFixed(6)}`);
  M(c, `${label}_fix`, `local=${fx(local.x, 6)},${fx(local.y, 6)},${fx(local.z, 6)} fixedWorld=${fx(fixedWorld.x, 6)},${fx(fixedWorld.y, 6)},${fx(fixedWorld.z, 6)} fixedErr=${fixedErr.toExponential(3)}`);
}
function nanCaseTable() {
  return {
    zero_dt: () => { const s = simpleScene(); for (let i = 0; i < 240; i++) s.world.step(0); return { ...s, note: `stepnumber=${s.world.stepnumber} time=${s.world.time} invDt=${1 / 0}` }; },
    neg_dt: () => { const s = simpleScene(); for (let i = 0; i < 240; i++) s.world.step(-DT); return { ...s, note: `stepnumber=${s.world.stepnumber} time=${s.world.time}` }; },
    nan_dt: () => { const s = simpleScene(); s.world.step(NaN); s.world.step(DT); return { ...s, note: `stepnumber=${s.world.stepnumber}` }; },
    inf_elapsed: () => { const s = simpleScene(); s.world.step(DT, Infinity, 10); const afterInf = s.world.stepnumber; for (let i = 0; i < 60; i++) s.world.step(DT, DT, 10); return { ...s, note: `afterInf=${afterInf} accumulator=${s.world.accumulator} stepnumber=${s.world.stepnumber} time=${s.world.time}` }; },
    nan_elapsed: () => { const s = simpleScene(); s.world.step(DT, NaN, 10); for (let i = 0; i < 60; i++) s.world.step(DT, DT, 10); return { ...s, note: `accumulator=${s.world.accumulator} stepnumber=${s.world.stepnumber} time=${s.world.time}` }; },
    maxsub0: () => { const s = simpleScene(); for (let i = 0; i < 60; i++) s.world.step(DT, DT, 0); return { ...s, note: `stepnumber=${s.world.stepnumber} time=${s.world.time} accumulator=${s.world.accumulator} y=${fx(s.ball.position.y, 9)}` }; },
    iters0: () => { const s = simpleScene(); s.world.solver.iterations = 0; for (let i = 0; i < 240; i++) s.world.step(DT); return { ...s, note: `contacts=${s.world.contacts.length} sleep=${s.ball.sleepState} y=${fx(s.ball.position.y, 9)}` }; },
    nan_gravity: () => { const s = simpleScene(); s.world.gravity.set(0, NaN, 0); for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `gravity.length=${s.world.gravity.length()}` }; },
    nan_mass: () => { const s = simpleScene(); s.ball.mass = NaN; s.ball.updateMassProperties(); for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `invMass=${s.ball.invMass}` }; },
    mass0_dynamic: () => { const s = simpleScene(); s.ball.mass = 0; s.ball.updateMassProperties(); for (let i = 0; i < 240; i++) s.world.step(DT); return { ...s, note: `type=${s.ball.type} invMass=${s.ball.invMass} y=${fx(s.ball.position.y, 9)}` }; },
    damping_gt1: () => { const s = simpleScene(); s.ball.linearDamping = 1.5; for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `v=${fx(s.ball.velocity.y, 9)} pow=${Math.pow(1 - 1.5, DT)}` }; },
    damping_eq1: () => { const s = simpleScene(); s.ball.linearDamping = 1; for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `v=${fx(s.ball.velocity.y, 9)} y=${fx(s.ball.position.y, 9)}` }; },
    angdamping_gt1: () => { const s = simpleScene(); s.ball.angularDamping = 1.5; s.ball.angularVelocity.set(1, 2, 3); for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `w=${fx(s.ball.angularVelocity.x, 9)},${fx(s.ball.angularVelocity.y, 9)},${fx(s.ball.angularVelocity.z, 9)}` }; },
    zero_box: () => {
      const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
      const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
      const box = new CANNON.Body({ mass: 1, shape: new CANNON.Box(new CANNON.Vec3(0, 0, 0)), position: new CANNON.Vec3(0, 5, 0) });
      world.addBody(ground); world.addBody(box);
      for (let i = 0; i < 240; i++) world.step(DT);
      return { world, ground, ball: box, dyn: [box], note: `r=${box.shapes[0].boundingSphereRadius} inertia=${box.inertia.x},${box.inertia.y},${box.inertia.z} y=${fx(box.position.y, 9)}` };
    },
    coincident_spheres: () => {
      const world = new CANNON.World({ gravity: new CANNON.Vec3(0, 0, 0) });
      const a = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
      const b = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
      world.addBody(a); world.addBody(b);
      for (let i = 0; i < 5; i++) world.step(DT);
      const cc = world.contacts[0];
      return { world, ground: null, ball: a, dyn: [a, b], note: `contacts=${world.contacts.length} ni=${cc ? `${cc.ni.x},${cc.ni.y},${cc.ni.z}` : 'none'} cC=${cc ? cc.computeC() : 'n/a'} sep=${fx(Math.abs(a.position.y - b.position.y), 9)} a.v=${fx(a.velocity.y, 9)}` };
    },
    coincident_spheres_gravity: () => {
      const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
      const a = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
      const b = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.5), position: new CANNON.Vec3(0, 5, 0) });
      world.addBody(a); world.addBody(b);
      for (let i = 0; i < 120; i++) world.step(DT);
      return { world, ground: null, ball: a, dyn: [a, b], note: `contacts=${world.contacts.length} sep=${fx(Math.abs(a.position.y - b.position.y), 9)} a.y=${fx(a.position.y, 9)}` };
    },
    neg_radius: () => {
      const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -9.82, 0) });
      const ground = new CANNON.Body({ mass: 0, type: CANNON.Body.STATIC, shape: new CANNON.Box(new CANNON.Vec3(10, 0.5, 10)), position: new CANNON.Vec3(0, -0.5, 0) });
      const ball = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(-0.5), position: new CANNON.Vec3(0, 5, 0) });
      world.addBody(ground); world.addBody(ball);
      for (let i = 0; i < 240; i++) world.step(DT);
      return { world, ground, ball, dyn: [ball], note: `r=${ball.shapes[0].radius} y=${fx(ball.position.y, 9)}` };
    },
    zero_quat: () => { const s = simpleScene(); s.ball.quaternion.set(0, 0, 0, 0); for (let i = 0; i < 5; i++) s.world.step(DT); return { ...s, note: `q=${fx(s.ball.quaternion.x, 9)},${fx(s.ball.quaternion.y, 9)},${fx(s.ball.quaternion.z, 9)},${fx(s.ball.quaternion.w, 9)}` }; },
    nan_quat: () => { const s = simpleScene(); s.ball.quaternion.set(NaN, 0, 0, 1); for (let i = 0; i < 5; i++) s.world.step(DT); return { ...s, note: `q=${fx(s.ball.quaternion.x, 9)} y=${fx(s.ball.position.y, 9)}` }; },
    nan_radius_midsim: () => { const s = simpleScene(); for (let i = 0; i < 120; i++) s.world.step(DT); s.ball.shapes[0].radius = NaN; for (let i = 0; i < 5; i++) s.world.step(DT); return { ...s, note: `r=${s.ball.shapes[0].radius} y=${fx(s.ball.position.y, 9)}` }; },
    teleport_into_ground: () => { const s = simpleScene(); for (let i = 0; i < 120; i++) s.world.step(DT); s.ball.position.set(0, -1, 0); for (let i = 0; i < 60; i++) s.world.step(DT); return { ...s, note: `y=${fx(s.ball.position.y, 9)} v=${fx(s.ball.velocity.y, 9)}` }; },
    // Raw payload bits are NOT rep-stable under a non-default V8 flag set
    // (r94-boundary §3: ~34%/process flip under --no-opt). The pin is the
    // canonical hash only — `h` spells every NaN canonically, never by payload.
    nan_payload: () => { const s = simpleScene(); s.ball.angularDamping = 1.5; s.ball.angularVelocity.set(1, 2, 3); for (let i = 0; i < 10; i++) s.world.step(DT); return { ...s, note: `payload=canonical` }; },
  };
}

// ---------------------------------------------------------------------------
if (!CASE || !CASES[CASE]) fail(`unknown case "${CASE}"`);
try {
  M0(CASE);
  CASES[CASE](CASE);
  DONE(CASE);
} catch (err) {
  fail(`${err && err.stack ? String(err.stack).split('\n')[0] : err}`);
}
