import 'package:explore3d/model.dart';
import 'package:vector_math/vector_math.dart';

Model diamond = Model(
  points: [
    // Top half vertices
    Vector3(0, 2, 0), // Top apex
    Vector3(-1, 0, -1), // Mid front-left
    Vector3(1, 0, -1), // Mid front-right
    Vector3(1, 0, 1), // Mid back-right
    Vector3(-1, 0, 1), // Mid back-left

    // Bottom half vertices
    Vector3(0, -1, 0), // Bottom apex
  ],
  lines: [
    [0, 1], [0, 2], [0, 3], [0, 4],

    // Middle connections (around the base)
    [1, 2], [2, 3], [3, 4], [4, 1],

    // Bottom half
    [5, 1], [5, 2], [5, 3], [5, 4],
  ],
);
