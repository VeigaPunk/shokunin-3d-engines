# 3D: better occlusion mathematics cannot recover missing geometry

[Bavoil and Sainz](https://developer.download.nvidia.com/SDK/10.5/direct3d/Source/ScreenSpaceAO/doc/ScreenSpaceAO.pdf), whitepaper1.1, September2008, replace three-dimensional ray marching with directional horizon searches on a single depth layer. Radius, angle bias and attenuation control different approximations. Their separated bilateral blur approximates a nonseparable filter; GPU timings do not predict local performance.

[Jimenez and colleagues](https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_COLOR.pdf), memo ATVI-TR-19-01, account for foreshortening and approximate near-field interreflection. Heightfield geometry still fails at thin occluders; a thickness heuristic and spatial/temporal reconstruction remain approximations. A more accurate integral cannot restore absent scene information.

These memo bytes are not identified as the2016 presentation. The original records a2020 publisher posting; that catalogue date was not refreshed. Directional/specular extensions are outside this selection. No rendering, proof verification or engine benchmark performed.

NVIDIA reserves rights and grants no implied patent license. No open memo reuse grant was established. Original commentary only.

Optional exercises omitted; originals retained.
