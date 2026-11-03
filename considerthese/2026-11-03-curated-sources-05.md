# game-dev-3d: conventional depth to reverse-Z, without blind shader migration

Candidate reading only, checked 2026-11-03. Assimilation requires the user’s later manual instruction. No rendering, installation, migration or corpus admission occurred. The comparison concerns depth representation and shader compatibility, not a universal current rendering state of the art.

## Timeline and source roles

- **Historical baseline:** Godot's [4.2 post-processing tutorial](https://docs.godotengine.org/en/4.2/tutorials/shaders/advanced_postprocessing.html) documents the older full-screen-quad and nonlinear depth reconstruction workflow. Keep this version as evidence of what an old shader expected, rather than silently judging it against later conventions.
- **Mechanism:** Nathan Reed's [NVIDIA article](https://developer.nvidia.com/blog/visualizing-depth-precision/), displayed October 21, 2021 and marked as republished, explains why reversing depth works particularly well with floating-point storage: its spacing offsets the nonlinear perspective distribution. It distinguishes numerical transformation error from depth quantization. Use the author's article body, not the page's added AI-generated summary; the displayed date is not claimed as the technique's invention date.
- **2024 adoption:** Clay John's [Godot announcement](https://godotengine.org/article/introducing-reverse-z/), April 29, says 4.3 adopts reverse-Z and identifies compatibility changes for direct clip-space position/depth operations. Its own age warning makes it historical evidence, not sufficient current guidance.
- **Current check:** the [4.7 post-processing documentation](https://docs.godotengine.org/en/4.7/tutorials/shaders/advanced_postprocessing.html) confirms near-depth 1 and far-depth 0, with nonlinear reconstruction through the inverse projection. It distinguishes Forward+/Mobile NDC conventions from Compatibility. This is version-scoped documentation observed today, not an immutable implementation pin.

## What changes, what survives

Reverse-Z changes the depth contract; it does not make every shader using depth automatically correct. The useful comparison is between coordinate spaces and storage conventions, not simply two screenshots labeled old/new. Existing inverse-projection reasoning remains valuable, while manually authored comparisons and constants need review.

My recommendation is to preserve conventional-depth reasoning for old-engine maintenance, external buffers and reproducible historical tests. An older method is useful when it matches the actual producer/consumer contract, even if a newer engine uses another representation. Do not apply the newer near/far convention to an unknown captured buffer by analogy. No source here establishes a measured speedup or visual improvement on this lane's host.

## Original post-hyaku comparison question

For a camera-distance ladder, can paired conventional/reversed representations reconstruct the same view-space positions while deliberately stale depth comparisons fail? Separate algebraic tolerances, actual depth-format quantization and rendered Z-fighting. The lane's headless projection fixtures can address only the first unless a real render path is separately established. The experiment has not run.

**Rights:** Godot contributors' documentation is [CC BY 3.0](https://raw.githubusercontent.com/godotengine/godot-docs/master/LICENSE.txt). No open license was established for the NVIDIA article or announcement imagery. No shader code, diagrams, screenshots or assets are copied; source access is not asset/training clearance.
