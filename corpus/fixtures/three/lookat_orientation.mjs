// Three.js lookAt orientation conventions for cameras and plain Object3D,
// executed under Node without a renderer.
// npm ci --prefix corpus/fixtures/three
// node corpus/fixtures/three/lookat_orientation.mjs
// node corpus/fixtures/three/lookat_orientation.mjs --object3d
// node corpus/fixtures/three/lookat_orientation.mjs --camera-plusz
// node corpus/fixtures/three/lookat_orientation.mjs --object-minusz
// node corpus/fixtures/three/lookat_orientation.mjs --flip-up
import { Object3D, PerspectiveCamera, Vector3 } from 'three';

const object3d = process.argv.includes('--object3d');
const cameraPlusz = process.argv.includes('--camera-plusz');
const objectMinusz = process.argv.includes('--object-minusz');
const flipUp = process.argv.includes('--flip-up');

const f = (v) => v.toFixed(3);
const f3 = (v) => f(v.x) + ',' + f(v.y) + ',' + f(v.z);
const close = (a, b) => Math.abs(a - b) < 1e-9;

// Camera and plain object both sit at the origin and look at TARGET = (1,1,2);
// n = normalize(TARGET). With up = (0,1,0) the camera basis is
// x = (-2,0,1)/sqrt(5), y = (-1,5,-2)/sqrt(30), z = -n; with up = (0,-1,0)
// only x and y flip sign. Camera forward is -z, i.e. n itself. A plain
// Object3D uses the opposite facing axis: its +Z basis points at n.
const TARGET = new Vector3(1, 1, 2);
const TOWARD = TARGET.clone().normalize();
const EXPECT_Y = flipUp
  ? new Vector3(1, -5, 2).divideScalar(Math.sqrt(30))
  : new Vector3(-1, 5, -2).divideScalar(Math.sqrt(30));
// Up probe = TARGET + (0,0.5,0); with fov=90 (tan 45 deg = 1) its ndc y is
// (probe . y) / (-(probe . z)) = (2.5/sqrt(30)) / (6.5/sqrt(6)) = sqrt(5)/13.
const EXPECT_UP_PROBE_NDC_Y = Math.sqrt(5) / 13;

const camera = new PerspectiveCamera(90, 4 / 3, 0.1, 10);
if (flipUp) camera.up.set(0, -1, 0);
camera.lookAt(TARGET);
camera.updateMatrixWorld(true);

const obj = new Object3D();
obj.lookAt(TARGET);
obj.updateMatrixWorld(true);

const col = (o, i) => new Vector3().setFromMatrixColumn(o.matrixWorld, i);
const camDir = camera.getWorldDirection(new Vector3());
const camZ = col(camera, 2);
const objZ = col(obj, 2);

// Live controls: without these the negative arms below would be vacuous.
if (!close(camDir.x, TOWARD.x) || !close(camDir.y, TOWARD.y) || !close(camDir.z, TOWARD.z)
  || !close(camZ.x, -TOWARD.x) || !close(camZ.y, -TOWARD.y) || !close(camZ.z, -TOWARD.z)
  || !close(objZ.x, TOWARD.x) || !close(objZ.y, TOWARD.y) || !close(objZ.z, TOWARD.z)) {
  console.error('ERROR: three3d lookat control mismatch cam_dir=' + f3(camDir)
    + ' cam_z=' + f3(camZ) + ' obj_z=' + f3(objZ));
  process.exit(1);
}

if (object3d) {
  const towardDot = objZ.dot(TOWARD);
  if (!close(towardDot, 1) || !close(objZ.x, TOWARD.x) || !close(objZ.y, TOWARD.y)
    || !close(objZ.z, TOWARD.z)) {
    console.error('ERROR: three3d lookat object3d mismatch z_basis=' + f3(objZ)
      + ' toward_dot=' + towardDot.toFixed(3));
    process.exit(1);
  }
  console.log('PASS three3d lookat object3d_plusz z_basis=' + f3(objZ)
    + ' toward_dot=' + towardDot.toFixed(3));
  process.exit(0);
}

if (cameraPlusz) {
  // Claim under test: "the camera world +Z axis points where the camera
  // looks." A probe one unit along +Z from the origin sits behind the
  // camera because camera forward is the -Z axis.
  const behindDot = camDir.dot(camZ);
  if (behindDot >= 0) {
    console.error('ERROR: three3d lookat camera_plusz controls inverted world_dir='
      + f3(camDir) + ' behind_dot=' + behindDot.toFixed(3));
    process.exit(1);
  }
  console.log('NEGATIVE REJECTED: three3d lookat camera_plusz world_dir=' + f3(camDir)
    + ' plusz_probe=behind behind_dot=' + behindDot.toFixed(3));
  process.exit(2);
}

if (objectMinusz) {
  // Claim under test: "plain Object3D.lookAt follows the camera convention
  // and faces the target with its -Z axis." Measured: the +Z basis points
  // at the target, so -Z faces away; the facing axis is +Z.
  const towardDot = objZ.dot(TOWARD);
  if (towardDot <= 0) {
    console.error('ERROR: three3d lookat object_minusz controls inverted z_basis='
      + f3(objZ) + ' toward_dot=' + towardDot.toFixed(3));
    process.exit(1);
  }
  console.log('NEGATIVE REJECTED: three3d lookat object_minusz toward_dot='
    + towardDot.toFixed(3) + ' z_basis=' + f3(objZ));
  process.exit(2);
}

if (flipUp) {
  // Claim under test: "inverting camera.up leaves the image-up direction
  // unchanged." Measured: the up probe above the target projects below the
  // horizon and the y-basis flips sign.
  const yBasis = col(camera, 1);
  const probeNdcY = TARGET.clone().add(new Vector3(0, 0.5, 0)).project(camera).y;
  if (probeNdcY >= 0 || !close(yBasis.x, EXPECT_Y.x) || !close(yBasis.y, EXPECT_Y.y)
    || !close(yBasis.z, EXPECT_Y.z)) {
    console.error('ERROR: three3d lookat flipped_up controls inverted probe_ndc_y='
      + f(probeNdcY) + ' y_basis=' + f3(yBasis));
    process.exit(1);
  }
  console.log('NEGATIVE REJECTED: three3d lookat flipped_up probe_ndc_y=' + f(probeNdcY)
    + ' y_basis=' + f3(yBasis));
  process.exit(2);
}

// Default arm: camera forward is n, the target projects to the NDC origin,
// and the up probe above the target projects above the horizon.
const targetNdc = TARGET.clone().project(camera);
const upProbeNdcY = TARGET.clone().add(new Vector3(0, 0.5, 0)).project(camera).y;
if (!close(targetNdc.x, 0) || !close(targetNdc.y, 0) || !close(upProbeNdcY, EXPECT_UP_PROBE_NDC_Y)) {
  console.error('ERROR: three3d lookat camera_forward mismatch target_ndc=' + f(targetNdc.x)
    + ',' + f(targetNdc.y) + ' up_probe_ndc_y=' + f(upProbeNdcY));
  process.exit(1);
}
console.log('PASS three3d lookat camera_forward dir=' + f3(camDir)
  + ' target_ndc=' + f(targetNdc.x) + ',' + f(targetNdc.y) + ' up_probe_ndc_y=' + f(upProbeNdcY));
process.exit(0);
