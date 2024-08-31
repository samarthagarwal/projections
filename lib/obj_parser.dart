import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math.dart' as vmath;

class ObjParser {
  List<vmath.Vector3> vertices = [];
  List<List<int>> faces = [];

  Future<void> loadObj(String fileName) async {
    String objData = await rootBundle.loadString(fileName);

    for (var line in objData.split('\n')) {
      line = line.trim();
      if (line.startsWith('v ')) {
        // Parse vertex
        var vertexData = line.substring(2).split(' ');
        var vertex = vmath.Vector3(
          double.parse(vertexData[0]),
          double.parse(vertexData[1]),
          double.parse(vertexData[2]),
        );
        vertices.add(vertex);
      } else if (line.startsWith('f ')) {
        // Parse face
        var faceData = line.substring(2).split(' ');
        var face = faceData.map((index) => int.parse(index.split('/')[0]) - 1).toList();
        faces.add(face);
      }
    }
  }
}
