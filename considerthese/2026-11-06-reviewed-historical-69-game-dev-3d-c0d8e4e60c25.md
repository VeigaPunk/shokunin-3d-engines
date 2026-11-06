# 3D: transition coverage is not clip count

[Kovar, Gleicher and Pighin](https://graphics.cs.wisc.edu/Papers/2002/KGP02/mograph.pdf), attributed to2002 in the original record: Motion Graphs evaluates temporal neighborhoods rather than isolated poses. Its pruning already addresses dead ends and sinks; indefinite playback alone need not cover the collection.

[Heck–Gleicher](https://graphics.cs.wisc.edu/Papers/2007/HG07/PMGFullPaper.pdf), attributed to2007: Parametric Motion Graphs represents transitions between motion families using sampled regions. Smoothness supports interpolation, not exhaustive verification. An edge requires a destination for every source motion. Fixed parameters within a clip and transitions near its end restrict responsiveness.

This expands what a graph node represents; it does not make sampled examples certificates for all possible joins. Discrete graphs remain useful for a fixed repertoire. Review required sequences, interruption timing and missing connections separately from clip quality. No animation execution or local performance result occurred.

The retained manuscripts are prepublication copies; final proceedings identity was not refreshed. No unrestricted reuse grant is established. Original commentary and links only, no motion assets or paper figures.

Optional exercises omitted; originals retained.
