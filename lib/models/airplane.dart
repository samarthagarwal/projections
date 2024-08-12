import 'package:explore3d/model.dart';
import 'package:vector_math/vector_math.dart';

Model airplane = Model(
  points: [
    // Fuselage (Body)
    Vector3(0, 0, 4), // Nose tip
    Vector3(-0.5, 0, -4), // Left tail end
    Vector3(0.5, 0, -4), // Right tail end

    // Wings
    Vector3(-2, 0, 0), // Left wing tip
    Vector3(2, 0, 0), // Right wing tip

    // Vertical stabilizer (optional)
    Vector3(0, 1, -3.5), // Tail top
  ],
  lines: [
    [0, 1], [0, 2], [1, 2], // Fuselage
    [0, 3], [0, 4], // Nose to wings
    [3, 1], [4, 2], // Wings to tail
    [3, 4], // Wing span
    [1, 5], [2, 5], // Vertical stabilizer (optional)
  ],
);
