import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const script = join(here, 'scene_graph.mjs');
const seeds = ['scene_graph.mjs', 'run_cases.mjs', 'package.json', 'package-lock.json'];
const digests = () => Object.fromEntries(seeds.map(name => [name, createHash('sha256').update(readFileSync(join(here, name))).digest('hex')]));
const before = digests();
const cases = [
  ['positive', [], 0, 'PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true'],
  ['negative_wrong_order', ['--wrong-order'], 2, 'NEGATIVE REJECTED: three3d wrong_order expected=-1,0,0 reversed=2.000,0.000,-3.000 parent_intact=true'],
  ['mutation', ['--mutate-offset'], 1, 'ERROR: three3d world origin mismatch observed=-2.000,0.000,-0.000 expected=-1,0,0'],
];
const results = cases.map(([name, flags, expectedExit, expectedLine]) => {
  const command = [process.execPath, script, ...flags];
  const proc = spawnSync(command[0], command.slice(1), { encoding: 'utf8', timeout: 5000 });
  const stdout = proc.stdout ?? '';
  const stderr = proc.stderr ?? '';
  const actualLines = (name === 'mutation' ? stderr : stdout).trim().split('\n');
  const otherStream = name === 'mutation' ? stdout : stderr;
  const pass = !proc.error && proc.status === expectedExit && proc.signal === null
    && actualLines.length === 1 && actualLines[0] === expectedLine && otherStream === '';
  return { name, command, expectedExit, actualExit: proc.status, signal: proc.signal,
    error: proc.error?.message ?? null, expectedLine, stdout, stderr, verdict: pass ? 'PASS' : 'FAIL' };
});
const seedsUnchanged = JSON.stringify(digests()) === JSON.stringify(before);
const verdict = seedsUnchanged && results.every(row => row.verdict === 'PASS') ? 'PASS' : 'FAIL';
const payload = { node: process.version, three: JSON.parse(readFileSync(join(here, 'package.json'))).dependencies.three,
  seedsUnchanged, seedDigests: before, results, verdict, boundedClaim: 'three.js Object3D scene-graph math under Node, no renderer, GL context, pixels, or browser.' };
if (process.argv.includes('--receipt')) {
  const file = process.argv[process.argv.indexOf('--receipt') + 1];
  if (!file) throw new Error('--receipt requires file path');
  writeFileSync(file, JSON.stringify(payload, null, 2) + '\n');
}
for (const result of results) console.log(`${result.verdict} ${result.name}: exit=${result.actualExit} expected=${result.expectedExit}`);
console.log(`${verdict} three battery: 3/3, seeds_unchanged=${seedsUnchanged}`);
process.exit(verdict === 'PASS' ? 0 : 1);
