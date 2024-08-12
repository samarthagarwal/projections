import 'dart:math';

import 'package:explore3d/model.dart';
import 'package:vector_math/vector_math.dart';

int numLatitudes = 20; // Number of latitude circles
int numLongitudes = 20; // Number of longitude segments per circle
Random random = Random();
double randomness = 1;

Model sphere = Model(
  points: () {
    List<Vector3> points = [];
    Random random = Random();

    for (int i = 0; i < 200; i++) {
      // Randomly choose an angle theta (azimuthal angle) from 0 to 2*pi
      double theta = 2 * pi * random.nextDouble();

      // Randomly choose a value for z (cosine of the polar angle) from -1 to 1
      double z = 2 * random.nextDouble() - 1;

      // Compute the corresponding radius for the x-y plane
      double r = sqrt(1 - z * z);

      // Convert to Cartesian coordinates
      double x = r * cos(theta);
      double y = r * sin(theta);

      // Scale the points by the desired radius
      points.add(Vector3(x * 1, y * 1, z * 1));
    }

    return points;
  }(),
  lines: [],
);
