import 'package:vector_math/vector_math.dart';

class Model {
  final List<Vector3> points;
  final List<List<int>> lines;

  Model({required this.points, required this.lines});
}
