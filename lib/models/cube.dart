import 'package:explore3d/model.dart';
import 'package:vector_math/vector_math.dart';

Model cube = Model(
  points: [
    Vector3(-1, -1, -1),
    Vector3(1, -1, -1),
    Vector3(1, 1, -1),
    Vector3(-1, 1, -1),
    Vector3(-1, -1, 1),
    Vector3(1, -1, 1),
    Vector3(1, 1, 1),
    Vector3(-1, 1, 1),
  ],
  lines: [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 0],
    [4, 5],
    [5, 6],
    [6, 7],
    [7, 4],
    [4, 0],
    [5, 1],
    [6, 2],
    [7, 3],
  ],
);
