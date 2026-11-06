# 3D: silencing a derivative diagnostic does not repair execution

The [WGSL Candidate Recommendation Draft](https://www.w3.org/TR/2026/CRD-WGSL-20261026/), dated2026-10-26, makes a shader portability boundary explicit: derivatives collaborate across fragment invocations, rather than evaluating each pixel independently.

Its uniformity analysis attempts to prove collective operations execute together. Failure to prove this triggers a derivative diagnostic, normally an error. That is a static-analysis outcome, not evidence that every observed execution diverged.

Diagnostic filters can reduce severity, but the derivative function descriptions still specify indeterminate results under nonuniform control flow. Compiler acceptance after suppression therefore does not establish meaningful gradients. Implicit texture sampling also belongs to the derivative-dependent family.

Fine and coarse variants describe different neighborhood calculations; selecting fine does not remove the control-flow requirement. 

This dated draft documents a contract, not a browser conformance result or an invention date. No rendering claim is established.

The linked W3C Software and Document License2023 permits reuse with notices and modification disclosures. Only original commentary and links are proposed; no source code, examples, rendering, training or assimilation.
