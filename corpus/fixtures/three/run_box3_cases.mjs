import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'box3_bounds.mjs');
const seeds = ['box3_bounds.mjs', 'run_box3_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name,
  createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['aabb_sphere', [], 0, 'PASS three3d box3 aabb_extent=1.061 sphere_r=1.581 inside_point=true outside_point=false'],
  ['ray_agree', ['--ray-agree'], 0, 'PASS three3d box3 ray_agree hit_distance=5.043 pretest_hit=true pretest_miss=false mesh_miss=true'],
  ['stale_box', ['--stale-box'], 2, 'NEGATIVE REJECTED: three3d box3 stale_box moved_point=4.000,0.000,0.000 in_stale=false in_fresh=true stale_extent_x=1.061'],
  ['local_world', ['--local-world'], 2, 'NEGATIVE REJECTED: three3d box3 local_world raw_local=1.000,0.500,0.000 contained=false mesh_center=4.000,0.000,0.000 contained=true'],
  ['mutate_expand', ['--mutate-expand'], 1, 'ERROR: three3d box3 aabb mismatch observed_min=-1.561,-1.561,-1.000 observed_max=1.561,1.561,1.000 observed_r2=5.871320'],
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
  boundedClaim: 'three.js Box3/Sphere world-space bounds and Box3 ray-pretest agreement under Node; no renderer, GL context, pixels or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires a path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const row of results) console.log(row.verdict + ' ' + row.name + ': exit=' + row.actualExit + ' expected=' + row.expectedExit);
console.log(verdict + ' three box3 battery: ' + results.filter(row => row.verdict === 'PASS').length + '/' + results.length + ', seeds_unchanged=' + seedsUnchanged);
process.exit(verdict === 'PASS' ? 0 : 1);
