// Three.js Raycaster against a translated triangle, under Node without a renderer.
import { BufferGeometry, DoubleSide, Float32BufferAttribute, Mesh, MeshBasicMaterial, Raycaster, Vector3 } from 'three';

const lateralMiss = process.argv.includes('--lateral-miss');
const mutateOffset = process.argv.includes('--mutate-offset');
const geometry = new BufferGeometry();
geometry.setAttribute('position', new Float32BufferAttribute([
  -1, -1, 0, 1, -1, 0, 0, 1, 0,
], 3));
geometry.computeVertexNormals();
const mesh = new Mesh(geometry, new MeshBasicMaterial({ side: DoubleSide }));
mesh.position.set(mutateOffset ? 3 : 2, 0, -5);
mesh.updateMatrixWorld(true);
const cast = (x) => new Raycaster(new Vector3(x, 0, 0), new Vector3(0, 0, -1), 0, 10)
  .intersectObject(mesh, false);
const hits = cast(2);
const miss = cast(5);
const close = (a, b) => Math.abs(a - b) < 1e-9;
if (geometry.getAttribute('position').count !== 3 || mesh.material.side !== DoubleSide
  || !mesh.isMesh || !close(mesh.position.z, -5)) {
  console.error('ERROR: three3d ray mesh setup mismatch');
  process.exit(1);
}
if (hits.length !== 1 || hits[0].object !== mesh
  || !close(hits[0].distance, 5) || hits[0].point.distanceTo(new Vector3(2, 0, -5)) > 1e-9) {
  console.error(`ERROR: three3d ray interior hit mismatch observed_hits=${hits.length} expected_point=2.000,0.000,-5.000`);
  process.exit(1);
}
if (miss.length !== 0) {
  console.error(`ERROR: three3d ray lateral miss intersected observed_hits=${miss.length}`);
  process.exit(1);
}
if (lateralMiss) {
  console.log(`NEGATIVE REJECTED: three3d ray lateral_miss x=5.000 hits=${miss.length} hit_control=${hits.length} mesh_intact=true`);
  process.exit(2);
}
console.log(`PASS three3d ray interior_hit point=${hits[0].point.toArray().map(v => v.toFixed(3)).join(',')} distance=${hits[0].distance.toFixed(3)} miss_control=${miss.length}`);
