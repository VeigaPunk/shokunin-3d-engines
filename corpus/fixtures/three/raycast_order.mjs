// Ordered Raycaster intersections across two live triangle meshes under Node.
import { BufferGeometry, DoubleSide, Float32BufferAttribute, Mesh, MeshBasicMaterial, Raycaster, Vector3 } from 'three';

const nearOffAxis = process.argv.includes('--near-off-axis');
const swapDepths = process.argv.includes('--swap-depths');
const nearClip = process.argv.includes('--near-clip') || process.argv.includes('--mutate-near-clip');
const mutateNearClip = process.argv.includes('--mutate-near-clip');
const farClip = process.argv.includes('--far-clip');
const nearBoundary = process.argv.includes('--near-boundary') || process.argv.includes('--mutate-near-boundary');
const mutateNearBoundary = process.argv.includes('--mutate-near-boundary');
const farBoundary = process.argv.includes('--far-boundary');
const geometry = new BufferGeometry();
geometry.setAttribute('position', new Float32BufferAttribute([-1, -1, 0, 1, -1, 0, 0, 1, 0], 3));
const material = new MeshBasicMaterial({ side: DoubleSide });
const nearMesh = new Mesh(geometry, material);
const farMesh = new Mesh(geometry, material);
nearMesh.position.set(nearOffAxis ? 5 : 2, 0, swapDepths ? -5 : -3);
farMesh.position.set(2, 0, swapDepths ? -3 : -5);
nearMesh.updateMatrixWorld(true);
farMesh.updateMatrixWorld(true);
const ray = new Raycaster(new Vector3(2, 0, 0), new Vector3(0, 0, -1),
  nearBoundary ? (mutateNearBoundary ? 5.25 : 5) : nearClip ? (mutateNearClip ? 2 : 4) : 0,
  farBoundary ? 3 : farClip ? 4 : 10);
const close = (a, b) => Math.abs(a - b) < 1e-9;
if (geometry.getAttribute('position').count !== 3 || !nearMesh.isMesh || !farMesh.isMesh
  || nearMesh === farMesh || nearMesh.geometry !== farMesh.geometry) {
  console.error('ERROR: three3d ray order mesh setup failed');
  process.exit(1);
}
let baseline;
if (nearBoundary || farBoundary) {
  baseline = new Raycaster(ray.ray.origin.clone(), ray.ray.direction.clone(), 0, 10)
    .intersectObjects([farMesh, nearMesh], false);
  if (baseline.length !== 2 || baseline[0].object !== nearMesh || baseline[1].object !== farMesh
    || baseline[0].distance !== 3 || baseline[1].distance !== 5
    || !baseline[0].point.equals(new Vector3(2, 0, -3))
    || !baseline[1].point.equals(new Vector3(2, 0, -5))) {
    console.error(`ERROR: three3d ray boundary baseline failed measured_hits=${baseline.length}`);
    process.exit(1);
  }
}
const hits = ray.intersectObjects([farMesh, nearMesh], false);
if (nearBoundary || farBoundary) {
  const expected = nearBoundary ? farMesh : nearMesh;
  const distance = nearBoundary ? 5 : 3;
  if (hits.length !== 1 || hits[0].object !== expected || hits[0].distance !== distance
    || !hits[0].point.equals(new Vector3(2, 0, -distance))) {
    console.error(`ERROR: three3d ray boundary measured contradiction hits=${hits.length} first=${hits[0]?.object === nearMesh ? 'near' : hits[0]?.object === farMesh ? 'far' : 'none'} near=${ray.near.toFixed(3)} far=${ray.far.toFixed(3)} baseline_hits=${baseline.length}`);
    process.exit(1);
  }
  console.log(`NEGATIVE REJECTED: three3d ray_boundary ${nearBoundary ? 'near' : 'far'} hits=${hits.length} remaining=${nearBoundary ? 'far' : 'near'} distance=${distance.toFixed(3)} baseline_hits=${baseline.length}`);
  process.exit(2);
}
if (nearClip || farClip) {
  const expected = nearClip ? farMesh : nearMesh;
  const distance = nearClip ? 5 : 3;
  const point = new Vector3(2, 0, -distance);
  if (hits.length !== 1 || hits[0].object !== expected || !close(hits[0].distance, distance)
    || hits[0].point.distanceTo(point) > 1e-9) {
    console.error(`ERROR: three3d ray range measured contradiction hits=${hits.length} first=${hits[0]?.object === nearMesh ? 'near' : 'far'} near=${ray.near.toFixed(3)} far=${ray.far.toFixed(3)}`);
    process.exit(1);
  }
  console.log(`NEGATIVE REJECTED: three3d ray_range ${nearClip ? 'near_clip' : 'far_clip'} hits=${hits.length} remaining=${nearClip ? 'far' : 'near'} distance=${distance.toFixed(3)}`);
  process.exit(2);
}
if (nearOffAxis) {
  if (hits.length !== 1 || hits[0].object !== farMesh || !close(hits[0].distance, 5)
    || hits[0].point.distanceTo(new Vector3(2, 0, -5)) > 1e-9) {
    console.error(`ERROR: three3d ray order offset control failed measured_hits=${hits.length}`);
    process.exit(1);
  }
  console.log(`NEGATIVE REJECTED: three3d ray_order near_off_axis hits=${hits.length} remaining=far depth=5.000`);
  process.exit(2);
}
if (hits.length !== 2 || hits[0].object !== nearMesh || hits[1].object !== farMesh
  || !close(hits[0].distance, 3) || !close(hits[1].distance, 5)
  || hits[0].point.distanceTo(new Vector3(2, 0, -3)) > 1e-9
  || hits[1].point.distanceTo(new Vector3(2, 0, -5)) > 1e-9) {
  console.error(`ERROR: three3d ray order measured contradiction hits=${hits.length} first=${hits[0]?.object === nearMesh ? 'near' : 'far'} distances=${hits.map(hit => hit.distance.toFixed(3)).join(',')}`);
  process.exit(1);
}
console.log(`PASS three3d ray_order first=near distance=3.000 second=far distance=5.000 hits=${hits.length}`);
