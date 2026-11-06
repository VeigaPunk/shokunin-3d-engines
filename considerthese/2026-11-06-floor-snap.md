# Floor classification does not guarantee adhesion

[Godot4.7 CharacterBody3D](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html) separates slope classification from snapping. The existing floor-angle note explicitly excludes snap interactions; its measured threshold does not establish this behavior.

floor_snap_length defines a probe opposite up_direction. Contact and downward motion can keep the body attached, but upward velocity suppresses automatic snapping so jumps can detach. apply_floor_snap ignores velocity, yet does nothing when is_on_floor already reports true. 

The constant-speed option also requires snapping to remain attached on descending slopes. For movement review, distinguish contact classification, requested motion and adhesion before attributing a slope departure to the angle limit. Increasing probe distance is not evidence that every discontinuity is fixed.

This is selected versioned documentation, not a newly measured backend result or an invention-date claim. Neither the old threshold experiment nor this reading validates moving-platform interactions. No engine call or configuration changed.

Godot documentation carries CC BY3.0 terms; engine software and third-party rights remain separate. Original commentary only; no source or asset redistribution.
