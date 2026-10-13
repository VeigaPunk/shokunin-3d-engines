// Three.js perspective/frustum math under Node; no renderer, GL or pixels.
import { Frustum, Matrix4, PerspectiveCamera, Vector3 } from 'three';

const mutateFar = process.argv.includes('--mutate-far');
const rejectFar = process.argv.includes('--far-outside');
const camera = new PerspectiveCamera(90, 4 / 3, 1, mutateFar ? 20 : 10);
camera.updateProjectionMatrix();
camera.updateMatrixWorld(true);
const frustum = new Frustum().setFromProjectionMatrix(
  new Matrix4().multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
);
const inside = new Vector3(2, 1, -4);
const outside = new Vector3(6, 3, -12);
const insideNdc = inside.clone().project(camera);
const outsideNdc = outside.clone().project(camera);
const insideVisible = frustum.containsPoint(inside);
const outsideVisible = frustum.containsPoint(outside);
const close = (a, b) => Math.abs(a - b) < 1e-9;
// x/z and y/z are the same: x_ndc = 0.375, y_ndc = 0.25.
// With an 800x600 viewport these correspond to (550,225), not rendered pixels.
const projectionOk = close(insideNdc.x, 0.375) && close(insideNdc.y, 0.25)
  && close(outsideNdc.x, 0.375) && close(outsideNdc.y, 0.25);
if (!projectionOk || !insideVisible || !close(camera.near, 1) || !close(camera.aspect, 4 / 3)) {
  console.error('ERROR: three3d camera setup or hand-derived projection mismatch');
  process.exit(1);
}
if (outsideVisible) {
  console.error(`ERROR: three3d far point entered frustum measured_outside=${outsideVisible} far=${camera.far.toFixed(3)}`);
  process.exit(1);
}
if (!close(camera.far, 10) || !close(insideNdc.z, 2 / 3) || !close(outsideNdc.z, 28 / 27)) {
  console.error('ERROR: three3d camera depth projection mismatch');
  process.exit(1);
}
if (rejectFar) {
  console.log(`NEGATIVE REJECTED: three3d camera_far outside_depth=12.000 outside_frustum=${outsideVisible} inside_frustum=${insideVisible} shared_screen=550.000,225.000`);
  process.exit(2);
}
console.log(`PASS three3d camera inside_depth=4.000 inside_frustum=${insideVisible} outside_frustum=${outsideVisible} screen=550.000,225.000`);
