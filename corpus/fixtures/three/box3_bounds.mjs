// Three.js world-space Box3 bounds for a rotated mesh, and Box3/ray-pretest
// agreement, under Node without a renderer.
// npm ci --prefix corpus/fixtures/three
// node corpus/fixtures/three/box3_bounds.mjs
// node corpus/fixtures/three/box3_bounds.mjs --ray-agree
// node corpus/fixtures/three/box3_bounds.mjs --stale-box
// node corpus/fixtures/three/box3_bounds.mjs --local-world
// node corpus/fixtures/three/box3_bounds.mjs --mutate-expand
import { Box3, BoxGeometry, Mesh, MeshBasicMaterial, Raycaster, Sphere, Vector3 } from 'three';

const rayAgree = process.argv.includes('--ray-agree');
const staleBox = process.argv.includes('--stale-box');
const localWorld = process.argv.includes('--local-world');
const mutateExpand = process.argv.includes('--mutate-expand');

// R_z(45 deg) on a 2x1x1 box at the origin. World AABB half-extent per axis:
// |R| * halfExtents -> 1*cos45 + 0.5*sin45.
const mesh = new Mesh(new BoxGeometry(2, 1, 1), new MeshBasicMaterial());
mesh.rotation.z = Math.PI / 4;
mesh.updateMatrixWorld(true);

const box = new Box3().setFromObject(mesh);
if (mutateExpand) box.expandByScalar(0.5);
const sphere = box.getBoundingSphere(new Sphere());

const f = (v) => v.toFixed(3);
const close = (a, b) => Math.abs(a - b) < 1e-9;

const EXPECT_EXTENT = Math.SQRT2 / 2 + Math.SQRT2 / 4;
const EXPECT_R2 = 2 * EXPECT_EXTENT * EXPECT_EXTENT + 0.25;

if (!close(box.min.x, -EXPECT_EXTENT) || !close(box.min.y, -EXPECT_EXTENT)
  || !close(box.min.z, -0.5) || !close(box.max.x, EXPECT_EXTENT)
  || !close(box.max.y, EXPECT_EXTENT) || !close(box.max.z, 0.5)
  || !close(sphere.radius * sphere.radius, EXPECT_R2) || sphere.center.length() !== 0) {
  console.error('ERROR: three3d box3 aabb mismatch observed_min=' + f(box.min.x) + ',' + f(box.min.y) + ',' + f(box.min.z)
    + ' observed_max=' + f(box.max.x) + ',' + f(box.max.y) + ',' + f(box.max.z)
    + ' observed_r2=' + (sphere.radius * sphere.radius).toFixed(6));
  process.exit(1);
}

if (rayAgree) {
  const hitRay = new Raycaster(new Vector3(-5, 0.75, 0), new Vector3(1, 0, 0), 0, 20);
  const missRay = new Raycaster(new Vector3(-5, 1.2, 0), new Vector3(1, 0, 0), 0, 20);
  const hit = hitRay.intersectObject(mesh, false);
  const miss = missRay.intersectObject(mesh, false);
  const pretestHit = hitRay.ray.intersectsBox(box);
  const pretestMiss = missRay.ray.intersectsBox(box);
  if (hit.length !== 1 || miss.length !== 0 || pretestHit !== true || pretestMiss !== false) {
    console.error('ERROR: three3d box3 ray agreement mismatch hits=' + hit.length
      + ' misses=' + miss.length + ' pretest_hit=' + pretestHit + ' pretest_miss=' + pretestMiss);
    process.exit(1);
  }
  console.log('PASS three3d box3 ray_agree hit_distance=' + hit[0].distance.toFixed(3)
    + ' pretest_hit=' + pretestHit + ' pretest_miss=' + pretestMiss + ' mesh_miss=' + (miss.length === 0));
  process.exit(0);
}

if (staleBox) {
  const moved = new Mesh(new BoxGeometry(2, 1, 1), new MeshBasicMaterial());
  moved.rotation.z = Math.PI / 4;
  const beforeMove = new Box3().setFromObject(moved);
  moved.position.set(4, 0, 0);
  moved.updateMatrixWorld(true);
  const afterMove = new Box3().setFromObject(moved);
  const probe = new Vector3(4, 0, 0);
  const inStale = beforeMove.containsPoint(probe);
  const inFresh = afterMove.containsPoint(probe);
  if (inStale !== false || inFresh !== true) {
    console.error('ERROR: three3d box3 stale-box controls inverted in_stale=' + inStale + ' in_fresh=' + inFresh);
    process.exit(1);
  }
  console.log('NEGATIVE REJECTED: three3d box3 stale_box moved_point=4.000,0.000,0.000 in_stale=' + inStale
    + ' in_fresh=' + inFresh + ' stale_extent_x=' + f(Math.abs(beforeMove.min.x)));
  process.exit(2);
}

if (localWorld) {
  const worldMesh = new Mesh(new BoxGeometry(2, 1, 1), new MeshBasicMaterial());
  worldMesh.rotation.z = Math.PI / 2;
  worldMesh.position.set(4, 0, 0);
  worldMesh.updateMatrixWorld(true);
  const worldBox = new Box3().setFromObject(worldMesh);
  const rawLocal = new Vector3(1, 0.5, 0);
  const centerProbe = new Vector3(4, 0, 0);
  const rawContained = worldBox.containsPoint(rawLocal);
  const centerContained = worldBox.containsPoint(centerProbe);
  if (rawContained !== false || centerContained !== true) {
    console.error('ERROR: three3d box3 local-world controls inverted raw=' + rawContained + ' center=' + centerContained);
    process.exit(1);
  }
  console.log('NEGATIVE REJECTED: three3d box3 local_world raw_local=1.000,0.500,0.000 contained=' + rawContained
    + ' mesh_center=4.000,0.000,0.000 contained=' + centerContained);
  process.exit(2);
}

const inside = new Vector3(0.9, 0.9, 0);
const outside = new Vector3(1.2, 0, 0);
const insideBox = box.containsPoint(inside);
const outsideBox = box.containsPoint(outside);
if (insideBox !== true || outsideBox !== false) {
  console.error('ERROR: three3d box3 point classification mismatch inside=' + insideBox + ' outside=' + outsideBox);
  process.exit(1);
}
console.log('PASS three3d box3 aabb_extent=' + f(EXPECT_EXTENT) + ' sphere_r=' + f(sphere.radius)
  + ' inside_point=' + insideBox + ' outside_point=' + outsideBox);
process.exit(0);
