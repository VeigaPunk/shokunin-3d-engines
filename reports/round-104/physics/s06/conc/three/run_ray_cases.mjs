import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'raycast_triangle.mjs');
const seeds = ['raycast_triangle.mjs', 'run_ray_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['hit', [], 0, 'PASS three3d ray interior_hit point=2.000,0.000,-5.000 distance=5.000 miss_control=0'],
  ['lateral_miss', ['--lateral-miss'], 2, 'NEGATIVE REJECTED: three3d ray lateral_miss x=5.000 hits=0 hit_control=1 mesh_intact=true'],
  ['backface', ['--backface'], 2, 'NEGATIVE REJECTED: three3d ray backface reverse_hits=0 forward_hits=1 side=FrontSide'],
  ['mutate_offset', ['--mutate-offset'], 1, 'ERROR: three3d ray interior hit mismatch observed_hits=0 expected_point=2.000,0.000,-5.000'],
  ['double_side', ['--backface', '--double-side'], 1, 'ERROR: three3d ray backface unexpectedly hit measured_reverse_hits=1 side=2'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const diagnostic = name === 'mutate_offset' || name === 'double_side';
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
  boundedClaim: 'three.js Raycaster triangle intersection under Node; no renderer, GL context, pixels or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(`${row.verdict} ${row.name}: exit=${row.actualExit} expected=${row.expectedExit}`);
console.log(`${verdict} three ray battery: ${results.filter(row => row.verdict === 'PASS').length}/${results.length}, seeds_unchanged=${seedsUnchanged}`);
process.exit(verdict === 'PASS' ? 0 : 1);
