import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'raycast_layers.mjs');
const seeds = ['raycast_layers.mjs', 'run_layer_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['default', [], 0, 'PASS three3d ray_layers default hits=1 first=near distance=3.000'],
  ['far_only', ['--far-only'], 2, 'NEGATIVE REJECTED: three3d ray_layers far_only hits=1 first=far last=far'],
  ['both', ['--both'], 2, 'NEGATIVE REJECTED: three3d ray_layers both hits=2 first=near last=far'],
  ['mutate_far_layer', ['--mutate-far-layer'], 1, 'ERROR: three3d ray layers measured contradiction hits=0 first=none ray_mask=2 far_mask=1'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const diagnostic = name === 'mutate_far_layer';
  const selectedStream = diagnostic ? stderr : stdout;
  const other = diagnostic ? stdout : stderr;
  const pass = !proc.error && proc.status === expectedExit && proc.signal === null
    && selectedStream === expectedLine + '\n' && other === '';
  return { name, command, expectedExit, actualExit: proc.status, signal: proc.signal,
    error: proc.error?.message ?? null, expectedLine, stdout, stderr, verdict: pass ? 'PASS' : 'FAIL' };
});
const seedsUnchanged = JSON.stringify(digests()) === JSON.stringify(before);
const verdict = seedsUnchanged && results.every(row => row.verdict === 'PASS') ? 'PASS' : 'FAIL';
const payload = { node: process.version, three: JSON.parse(readFileSync(join(here, 'package.json'))).dependencies.three,
  seedsUnchanged, seedDigests: before, results, verdict,
  boundedClaim: 'three.js CPU Raycaster mask selection on two live triangle meshes under Node; no renderer/visibility/GL/pixels/browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(`${row.verdict} ${row.name}: exit=${row.actualExit} expected=${row.expectedExit}`);
console.log(`${verdict} three layer battery: ${results.filter(row => row.verdict === 'PASS').length}/${results.length}, seeds_unchanged=${seedsUnchanged}`);
process.exit(verdict === 'PASS' ? 0 : 1);
