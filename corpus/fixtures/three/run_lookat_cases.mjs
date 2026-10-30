import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'lookat_orientation.mjs');
const seeds = ['lookat_orientation.mjs', 'run_box3_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['camera_forward', [], 0, 'PASS three3d lookat camera_forward dir=0.408,0.408,0.816 target_ndc=-0.000,0.000 up_probe_ndc_y=0.172'],
  ['object3d_plusz', ['--object3d'], 0, 'PASS three3d lookat object3d_plusz z_basis=0.408,0.408,0.816 toward_dot=1.000'],
  ['camera_plusz', ['--camera-plusz'], 2, 'NEGATIVE REJECTED: three3d lookat camera_plusz world_dir=0.408,0.408,0.816 plusz_probe=behind behind_dot=-1.000'],
  ['object_minusz', ['--object-minusz'], 2, 'NEGATIVE REJECTED: three3d lookat object_minusz toward_dot=1.000 z_basis=0.408,0.408,0.816'],
  ['flipped_up', ['--flip-up'], 2, 'NEGATIVE REJECTED: three3d lookat flipped_up probe_ndc_y=-0.172 y_basis=0.183,-0.913,0.365'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const diagnostic = name === 'mutate_expand';
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
  boundedClaim: 'three.js lookAt orientation conventions for cameras and plain Object3D under Node; no renderer, GL context, pixels or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(row.verdict + ' ' + row.name + ': exit=' + row.actualExit + ' expected=' + row.expectedExit);
console.log(verdict + ' three lookat battery: ' + results.filter(row => row.verdict === 'PASS').length + '/' + results.length + ', seeds_unchanged=' + seedsUnchanged);
process.exit(verdict === 'PASS' ? 0 : 1);
