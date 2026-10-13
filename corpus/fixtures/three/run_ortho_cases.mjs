import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'orthographic_frustum.mjs');
const seeds = ['orthographic_frustum.mjs', 'run_ortho_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['inside', [], 0, 'PASS three3d ortho front=4.000 deep=8.000 both_in_frustum=true,true outside_frustum=false screen=600.000,200.000'],
  ['far_outside', ['--far-outside'], 2, 'NEGATIVE REJECTED: three3d ortho_far depth=12.000 outside_frustum=false controls_in_frustum=true,true shared_screen=600.000,200.000'],
  ['mutate_far', ['--mutate-far'], 1, 'ERROR: three3d ortho far point entered frustum measured_outside=true far=20.000'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const diagnostic = name === 'mutate_far';
  const line = (diagnostic ? stderr : stdout).trim();
  const other = diagnostic ? stdout : stderr;
  const pass = !proc.error && proc.status === expectedExit && proc.signal === null
    && line === expectedLine && other === '';
  return { name, command, expectedExit, actualExit: proc.status, signal: proc.signal,
    error: proc.error?.message ?? null, expectedLine, stdout, stderr, verdict: pass ? 'PASS' : 'FAIL' };
});
const seedsUnchanged = JSON.stringify(digests()) === JSON.stringify(before);
const verdict = seedsUnchanged && results.every(row => row.verdict === 'PASS') ? 'PASS' : 'FAIL';
const payload = { node: process.version, three: JSON.parse(readFileSync(join(here, 'package.json'))).dependencies.three,
  seedsUnchanged, seedDigests: before, results, verdict,
  boundedClaim: 'three.js OrthographicCamera/Frustum math under Node; no renderer, GL context, pixels or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(`${row.verdict} ${row.name}: exit=${row.actualExit} expected=${row.expectedExit}`);
console.log(`${verdict} three ortho battery: ${results.filter(row => row.verdict === 'PASS').length}/${results.length}, seeds_unchanged=${seedsUnchanged}`);
process.exit(verdict === 'PASS' ? 0 : 1);
