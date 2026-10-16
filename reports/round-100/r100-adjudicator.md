# Adjudicator report - round 100 (fixed-fps capstone)

DECISION: **ADMIT-with-findings on successor `523c943`**, not on the
incomplete author landing `8183191` alone. The round adds 8 rows
(342 -> 350), covering 142 cells. This closes the lane's round-100
integration and review queue; it does not close the fold debt below.

## Evidence And Disposition

All five independent wave-B reports are filed in this directory:

- Verifier: pristine `8183191` is **342/350**, with exactly the eight
  new rows failing because their probe sources are missing. With the
  six seeds present, two full batteries are **350/350**; independent
  cell re-derivation covers 142/142 cells twice, with 137/137
  sha-bearing cells stable across four instances. Six mutations are
  detected and two controls remain exact. A pristine archive of
  successor `523c943` passes all eight new rows with unchanged pins.
- Reviewer: all eight worktree rows reproduce the committed markers;
  the fresh-checkout failure is correctly reported as HIGH severity.
  The six missing seeds, not the measured laws, are the landing defect.
- Critic: successor-equivalent bytes pass 8/8 twice; all six seed
  comparisons against the boundary probes match. Seven expected-fail
  probe executions detect their intended changes. The unbound-stream
  injection that passes is a demonstrated envelope blind spot, not
  counted as a successful detection.
- Simplifier: paired scratch-tree runs prove the proposed parent-side
  folds preserve the pinned surface. No simplifier patch is landed by
  this adjudication.
- Scribe: author receipts, pins and seed-copy provenance hold internally;
  the stale line count and stale qa citation are documentary findings.
  Internal custody does not excuse the missing committed dependencies.

`523c943` closes the self-containment defect, independently verified by
critic and verifier on archived successor bytes. The failure remains
part of `8183191`'s record; it is not retroactively called green.

## Findings Carried Forward

1. **Load margin:** the life row takes about 15.6 s against a 20 s parent
   cap because three serialized children each use a 5 s bound. The
   critic measured the exact `d["bound"] = 5 -> 3` candidate green at
   9.60 s without pin changes. This repair is proven but **not landed**.
2. **Probe line coupling:** six error-bearing cells hash source line
   numbers from the frozen life probe. Do not insert/delete probe lines
   or mask those numbers without fresh derivation and explicit re-pins.
3. **Unbound envelope:** only rc=137, boot and tick liveness are pinned
   for the three unbounded cells; content-preserving-envelope changes
   can escape. Accept that disclosed contract for this landing. A
   deterministic prefix digest is a tightening proposal, not an
   already-admitted law.
4. **Dead parent state:** simplifier SP-1/SP-2/SP-3 remain queued.
   Removing the dormant leak allowlist withdraws an unused extension
   path; it is not a zero-tradeoff cleanup. The related r99 debt remains.
5. **Disclosure precision:** the driver is 892 lines, its error table
   is `ERR_ALLOW`, and one qa derive citation predates the final sizing.
   Nine bpy arms timed out in the cited runs; the tenth returned an
   inner degraded receipt. Unknown warnings are hashed, the Jolt pair
   is dropped, and `beq`/`eq` are derived checks rather than independent
   witnesses. The Area3D ordering observation uses a failed-call
   diagnostic because the inherited shape callback has a signature defect.

The two author full greens and independent successor checks support
admission of the corrected artifact. They do not establish that every
older row is flake-free or that any queued fold has shipped.

Adjudicated by the lane orchestrator after the final verifier report
arrived. This commit carries the five reports and this disposition;
no fixture, pin, probe, or normalization changes accompany it.
