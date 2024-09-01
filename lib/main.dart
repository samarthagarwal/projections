import 'dart:math';
import 'dart:ui';

import 'package:explore3d/model.dart';
import 'package:explore3d/models/airplane.dart';
import 'package:explore3d/models/sphere.dart';
import 'package:explore3d/obj_parser.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:vector_math/vector_math.dart' hide Colors;

import 'models/cube.dart';
import 'models/diamond.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double angleX = 0;
  double angleY = 0;
  double _previousX = 0;
  double _previousY = 0;

  void _updateCube(DragUpdateDetails data) {
    if (angleY > 360.0) {
      angleY = angleY - 360.0;
    }
    if (_previousY > data.globalPosition.dx) {
      setState(() {
        angleY = angleY + 0.025;
      });
    }
    if (_previousY < data.globalPosition.dx) {
      setState(() {
        angleY = angleY - 0.025;
      });
    }
    _previousY = data.globalPosition.dx;

    if (angleX > 360.0) {
      angleX = angleX - 360.0;
    }
    if (_previousX > data.globalPosition.dy) {
      setState(() {
        angleX = angleX - 0.025;
      });
    }
    if (_previousX < data.globalPosition.dy) {
      setState(() {
        angleX = angleX + 0.025;
      });
    }
    _previousX = data.globalPosition.dy;
  }

  void _updateY(DragUpdateDetails data) {
    _updateCube(data);
  }

  void _updateX(DragUpdateDetails data) {
    _updateCube(data);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    // _animationController.addListener(() {
    //   setState(() {});
    // });
    // _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Model>(future: () async {
        ObjParser objParser = ObjParser();
        await objParser.loadObj("assets/models/Porsche_911_GT2.obj");
        Model modelToDraw = Model(points: objParser.vertices, lines: objParser.faces);
        return modelToDraw;
      }(), builder: (context, snapshot) {
        return Center(
          child: GestureDetector(
            onHorizontalDragUpdate: _updateY,
            onVerticalDragUpdate: _updateX,
            child: Container(
              color: Colors.white.withOpacity(0.1),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: CubePainter(
                      angleX: 170,
                      angleY: angleY,
                      side: min(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2),
                      model: snapshot.data ?? sphere,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class CubePainter extends CustomPainter {
  final double angleX;
  final double angleY;
  final double side;
  final Model model;

  CubePainter({this.angleX = 0.0, this.angleY = 0.0, this.side = 100, required this.model});

  @override
  void paint(Canvas canvas, Size size) {
    double side = this.side / 2;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.1
      ..style = PaintingStyle.stroke;

    List<Vector3> points = model.points.map((point) => Vector3.copy(point)).toList();

    // scale points as per side
    points = points.map((point) {
      return point
        ..x *= side
        ..y *= side
        ..z *= side;
    }).toList();

    // Rotate the points around the Y-axis
    final rotationMatrix = vector_math.Matrix4.rotationY(angleY);
    // convert degrees to radians
    double degrees = angleX;
    double radians = degrees * pi / 180;
    final rotationMatrixX = vector_math.Matrix4.rotationX(radians);

    final transformedPoints = points.map((point) {
      // final transformedPoint = point.clone();
      var transformedPoint = rotationMatrix.transform3(point);
      transformedPoint = rotationMatrixX.transform3(transformedPoint);
      // Apply perspective projection
      // double perspective = (2 + (transformedPoint.z / (side * 2)));
      double perspective = 1 / (2 - transformedPoint.z / (side * 2));
      // perspective should be between 0 and 1

      transformedPoint
        ..x *= perspective
        ..y *= perspective;

      // Move to the center of the canvas
      transformedPoint
        ..x += size.width / 2
        ..y += size.height / 2;

      return vector_math.Vector3(transformedPoint.x, transformedPoint.y, transformedPoint.z);
    }).toList();

    // draw all transformed points
    for (int i = 0; i < transformedPoints.length; i++) {
      // calculate the radius of the point based on the z value
      double radius = 0.2 * transformedPoints[i].z / side / 2; //1.25 + 3 * transformedPoints[i].z / side / 2;
      try {
        canvas.drawCircle(Offset(transformedPoints[i].x ?? 0, transformedPoints[i].y ?? 0), radius, paint..style = PaintingStyle.fill);
      } catch (e) {
        print(e);
        print(transformedPoints[i]);
      }
    }

    // Draw the edges of the cube
    for (var i = 0; i < model.lines.length; ++i) {
      final line = model.lines[i]; // [0, 1]
      final v1 = transformedPoints[line[0]];
      final v2 = transformedPoints[line[1]];
      Vector3 v3;
      if (line.length == 3) {
        v3 = transformedPoints[line[2]];
      } else {
        v3 = transformedPoints[line[0]];
      }

      // culling back faces
      final normal = calculateNormal(v1, v2, v3);

      final viewDirection = Vector3(0, 0, -1);

      if (!isFaceVisible(normal, viewDirection)) {
        continue; // Skip rendering this face
      }

      for (var j = 0; j < line.length; j += 1) {
        final start = transformedPoints[line[j]];
        final end = transformedPoints[line[(j + 1) % line.length]];
        _drawLine(i, canvas, paint, start, end);
      }
    }
  }

  void _drawLine(int index, Canvas canvas, Paint paint, vector_math.Vector3 p1, vector_math.Vector3 p2) {
    Offset o1 = Offset(p1.x, p1.y);
    Offset o2 = Offset(p2.x, p2.y);

    canvas.drawLine(
      o1,
      o2,
      paint
        ..color = Colors.black.withOpacity(clampDouble(p1.z / side, 0.5, 1))
        ..strokeWidth = clampDouble(p1.z / side, 0.1, 0.2),
    );
  }

  Vector3 calculateNormal(Vector3 v1, Vector3 v2, Vector3 v3) {
    final edge1 = v2 - v1;
    final edge2 = v3 - v1;
    final normal = edge1.cross(edge2);
    normal.normalize();
    return normal;
  }

  bool isFaceVisible(Vector3 normal, Vector3 viewDirection) {
    final dotProduct = normal.dot(viewDirection);
    return dotProduct < 0;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return angleX != (oldDelegate as CubePainter).angleX || angleY != (oldDelegate).angleY;
  }
}
