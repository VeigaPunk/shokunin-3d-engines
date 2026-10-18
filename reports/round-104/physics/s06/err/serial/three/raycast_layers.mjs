// CPU Raycaster layer-mask selection across two intact triangle meshes.
import { BufferGeometry, DoubleSide, Float32BufferAttribute, Mesh, MeshBasicMaterial, Raycaster, Vector3 } from 'three';

const farOnly = process.argv.includes('--far-only');
const both = process.argv.includes('--both');
const mutateFarLayer = process.argv.includes('--mutate-far-layer');
const geometry = new BufferGeometry();
geometry.setAttribute('position', new Float32BufferAttribute([-1, -1, 0, 1, -1, 0, 0, 1, 0], 3));
const material = new MeshBasicMaterial({ side: DoubleSide });
const nearMesh = new Mesh(geometry, material);
const farMesh = new Mesh(geometry, material);
nearMesh.position.set(2, 0, -3);
farMesh.position.set(2, 0, -5);
nearMesh.layers.set(0);
farMesh.layers.set(mutateFarLayer ? 0 : 1);
nearMesh.updateMatrixWorld(true);
farMesh.updateMatrixWorld(true);
const ray = new Raycaster(new Vector3(2, 0, 0), new Vector3(0, 0, -1), 0, 10);
if (farOnly || mutateFarLayer) ray.layers.set(1);
if (both) ray.layers.enable(1);
if (nearMesh === farMesh || nearMesh.geometry !== farMesh.geometry
  || geometry.getAttribute('position').count !== 3 || !nearMesh.isMesh || !farMesh.isMesh
  || !nearMesh.layers.isEnabled(0) || nearMesh.layers.isEnabled(1)
  || !farMesh.layers.isEnabled(mutateFarLayer ? 0 : 1)) {
  console.error('ERROR: three3d ray layers mesh setup failed');
  process.exit(1);
}
const hits = ray.intersectObjects([farMesh, nearMesh], false);
const expected = both ? [[nearMesh, 3], [farMesh, 5]] : [[farOnly || mutateFarLayer ? farMesh : nearMesh, farOnly || mutateFarLayer ? 5 : 3]];
if (hits.length !== expected.length || expected.some(([object, depth], index) =>
  hits[index].object !== object || hits[index].distance !== depth
  || !hits[index].point.equals(new Vector3(2, 0, -depth)))) {
  console.error(`ERROR: three3d ray layers measured contradiction hits=${hits.length} first=${hits[0]?.object === nearMesh ? 'near' : hits[0]?.object === farMesh ? 'far' : 'none'} ray_mask=${ray.layers.mask} far_mask=${farMesh.layers.mask}`);
  process.exit(1);
}
if (farOnly || both) {
  console.log(`NEGATIVE REJECTED: three3d ray_layers ${farOnly ? 'far_only' : 'both'} hits=${hits.length} first=${hits[0].object === nearMesh ? 'near' : 'far'} last=${hits.at(-1).object === farMesh ? 'far' : 'near'}`);
  process.exit(2);
}
console.log(`PASS three3d ray_layers default hits=1 first=near distance=3.000`);
