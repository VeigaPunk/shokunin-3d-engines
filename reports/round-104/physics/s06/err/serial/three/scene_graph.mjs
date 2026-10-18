// Headless scene-graph and transform assertions; no WebGL renderer or pixels.
// npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
// npm test --prefix .shokunin/game-dev-3d/corpus/fixtures/three
// node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --wrong-order
// node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --mutate-offset
import { Object3D, Vector3 } from 'three';

const wrongOrder = process.argv.includes('--wrong-order');
const mutatedOffset = process.argv.includes('--mutate-offset');
const parent = new Object3D();
parent.position.set(2, 0, 0);
parent.rotation.y = Math.PI / 2;
const child = new Object3D();
child.position.set(0, 0, mutatedOffset ? -4 : -3);
child.rotation.x = Math.PI / 2;
parent.add(child);
parent.updateMatrixWorld(true);
const world = child.getWorldPosition(new Vector3());
const origin = [world.x, world.y, world.z];
const expected = [-1, 0, 0]; // R_y(90)·(0,0,-3) + (2,0,0)
const dist = Math.hypot(...origin.map((v, i) => v - expected[i]));
const correctlyParented = child.parent === parent && parent.children.includes(child);
const directComposition = parent.matrixWorld.clone().multiply(child.matrix).elements;
const actualWorld = child.matrixWorld.elements;
const compositionMatches = actualWorld.every((v, i) => Math.abs(v - directComposition[i]) < 1e-10);
// R_y·R_x and R_x·R_y differ; the reversed composition is intentionally invalid.
const reversed = child.matrix.clone().multiply(parent.matrixWorld);
const reversedWorld = new Vector3().setFromMatrixPosition(reversed);
const reversedDist = reversedWorld.distanceTo(new Vector3(...expected));
if (!correctlyParented || !compositionMatches) {
  console.error('ERROR: scene graph parent/child setup or composition failed');
  process.exit(1);
}
if (wrongOrder) {
  if (dist > 1e-10 || reversedDist < 0.5) {
    console.error('ERROR: wrong-order control setup failed');
    process.exit(1);
  }
  console.log(`NEGATIVE REJECTED: three3d wrong_order expected=-1,0,0 reversed=${reversedWorld.toArray().map(v => v.toFixed(3)).join(',')} parent_intact=true`);
  process.exit(2);
}
if (dist > 1e-10) {
  console.error(`ERROR: three3d world origin mismatch observed=${origin.map(v => v.toFixed(3)).join(',')} expected=-1,0,0`);
  process.exit(1);
}
if (reversedDist < 0.5) {
  console.error('ERROR: reversed-order discrimination absent');
  process.exit(1);
}
console.log('PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true');
