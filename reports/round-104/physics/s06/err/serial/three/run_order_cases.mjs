import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'raycast_order.mjs');
const seeds = ['raycast_order.mjs', 'run_order_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['ordered', [], 0, 'PASS three3d ray_order first=near distance=3.000 second=far distance=5.000 hits=2'],
  ['near_off_axis', ['--near-off-axis'], 2, 'NEGATIVE REJECTED: three3d ray_order near_off_axis hits=1 remaining=far depth=5.000'],
  ['near_clip', ['--near-clip'], 2, 'NEGATIVE REJECTED: three3d ray_range near_clip hits=1 remaining=far distance=5.000'],
  ['far_clip', ['--far-clip'], 2, 'NEGATIVE REJECTED: three3d ray_range far_clip hits=1 remaining=near distance=3.000'],
  ['near_boundary', ['--near-boundary'], 2, 'NEGATIVE REJECTED: three3d ray_boundary near hits=1 remaining=far distance=5.000 baseline_hits=2'],
  ['far_boundary', ['--far-boundary'], 2, 'NEGATIVE REJECTED: three3d ray_boundary far hits=1 remaining=near distance=3.000 baseline_hits=2'],
  ['swap_depths', ['--swap-depths'], 1, 'ERROR: three3d ray order measured contradiction hits=2 first=far distances=3.000,5.000'],
  ['mutate_near_clip', ['--mutate-near-clip'], 1, 'ERROR: three3d ray range measured contradiction hits=2 first=near near=2.000 far=10.000'],
  ['mutate_near_boundary', ['--mutate-near-boundary'], 1, 'ERROR: three3d ray boundary measured contradiction hits=0 first=none near=5.250 far=10.000 baseline_hits=2'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const diagnostic = name === 'swap_depths' || name === 'mutate_near_clip' || name === 'mutate_near_boundary';
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
  boundedClaim: 'three.js Raycaster two-triangle hit order under Node; no renderer, GL context, pixels or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(`${row.verdict} ${row.name}: exit=${row.actualExit} expected=${row.expectedExit}`);
console.log(`${verdict} three order battery: ${results.filter(row => row.verdict === 'PASS').length}/${results.length}, seeds_unchanged=${seedsUnchanged}`);
process.exit(verdict === 'PASS' ? 0 : 1);
