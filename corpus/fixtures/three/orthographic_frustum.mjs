// Three.js OrthographicCamera projection/frustum math under Node; no renderer or GL.
import { Frustum, Matrix4, OrthographicCamera, Vector3 } from 'three';

const mutateFar = process.argv.includes('--mutate-far');
const rejectFar = process.argv.includes('--far-outside');
const rejectNear = process.argv.includes('--near-outside');
const mutateNear = process.argv.includes('--mutate-near');
const camera = new OrthographicCamera(-4, 4, 3, -3, mutateNear ? 0.1 : 1, mutateFar ? 20 : 10);
camera.updateProjectionMatrix();
camera.updateMatrixWorld(true);
const frustum = new Frustum().setFromProjectionMatrix(
  new Matrix4().multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
);
const front = new Vector3(2, 1, -4);
const deep = new Vector3(2, 1, -8);
const outside = new Vector3(2, 1, -12);
const nearOutside = new Vector3(2, 1, -0.5);
const frontNdc = front.clone().project(camera);
const deepNdc = deep.clone().project(camera);
const outsideNdc = outside.clone().project(camera);
const nearNdc = nearOutside.clone().project(camera);
const frontVisible = frustum.containsPoint(front);
const deepVisible = frustum.containsPoint(deep);
const outsideVisible = frustum.containsPoint(outside);
const nearVisible = frustum.containsPoint(nearOutside);
const close = (a, b) => Math.abs(a - b) < 1e-9;
const lateralOk = [frontNdc, deepNdc, outsideNdc, nearNdc].every(point =>
  close(point.x, 0.5) && close(point.y, 1 / 3)
);
if (!lateralOk || !frontVisible || !deepVisible) {
  console.error('ERROR: three3d ortho setup or depth-invariant projection mismatch');
  process.exit(1);
}
if (outsideVisible) {
  console.error(`ERROR: three3d ortho far point entered frustum measured_outside=${outsideVisible} far=${camera.far.toFixed(3)}`);
  process.exit(1);
}
// z_ndc = (2d - near - far)/(far - near): -1/3, 5/9, 13/9.
if (nearVisible) {
  console.error(`ERROR: three3d ortho near point entered frustum measured_near=${nearVisible} near=${camera.near.toFixed(3)}`);
  process.exit(1);
}
if (!close(camera.near, 1) || !close(camera.far, 10) || !close(frontNdc.z, -1 / 3)
  || !close(deepNdc.z, 5 / 9) || !close(outsideNdc.z, 13 / 9)) {
  console.error('ERROR: three3d ortho depth projection mismatch');
  process.exit(1);
}
if (rejectNear) {
  console.log(`NEGATIVE REJECTED: three3d ortho_near depth=0.500 near_frustum=${nearVisible} controls_in_frustum=${frontVisible},${deepVisible} far_frustum=${outsideVisible} shared_screen=600.000,200.000`);
  process.exit(2);
}
if (rejectFar) {
  console.log(`NEGATIVE REJECTED: three3d ortho_far depth=12.000 outside_frustum=${outsideVisible} controls_in_frustum=${frontVisible},${deepVisible} shared_screen=600.000,200.000`);
  process.exit(2);
}
console.log(`PASS three3d ortho front=4.000 deep=8.000 both_in_frustum=${frontVisible},${deepVisible} outside_frustum=${outsideVisible} screen=600.000,200.000`);
