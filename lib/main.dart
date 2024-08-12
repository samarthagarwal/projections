import 'dart:math';

import 'package:explore3d/model.dart';
import 'package:explore3d/models/airplane.dart';
import 'package:explore3d/models/sphere.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          color: Colors.white.withOpacity(0.1),
          width: 400,
          height: 400,
          child: Center(
            child: CustomPaint(
              painter: CubePainter(
                angle: _animationController.value * 2 * pi,
                side: 100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CubePainter extends CustomPainter {
  final double angle;
  final double side;

  CubePainter({this.angle = 0.0, this.side = 100});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Model modelToDraw = sphere;

    List<Vector3> points = modelToDraw.points.map((point) => Vector3.copy(point)).toList();

    // scale points as per side
    points = points.map((point) {
      return point
        ..x *= side / 2
        ..y *= side / 2
        ..z *= side / 2;
    }).toList();

    // Rotate the points around the Y-axis
    final rotationMatrix = vector_math.Matrix4.rotationY(angle);
    // final rotationMatricX = vector_math.Matrix4.rotationX(cos(15));

    final transformedPoints = points.map((point) {
      // final transformedPoint = point.clone();
      var transformedPoint = rotationMatrix.transform3(point);
      // transformedPoint = rotationMatricX.transform3(transformedPoint);
      // Apply perspective projection
      double perspective = (2 + (transformedPoint.z / (side * 2)));
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
      double radius = 1.25 + 3 * transformedPoints[i].z / side / 2;
      try {
        canvas.drawCircle(Offset(transformedPoints[i].x ?? 0, transformedPoints[i].y ?? 0), radius, paint..style = PaintingStyle.fill);
      } catch (e) {
        print(e);
        print(transformedPoints[i]);
      }
    }

    // Draw the edges of the cube
    // for (var i = 0; i < modelToDraw.lines.length; ++i) {
    //   final line = modelToDraw.lines[i]; // [0, 1]
    //   final startPoint = transformedPoints[line[0]];
    //   final endPoint = transformedPoints[line[1]];
    //   _drawLine(canvas, paint, startPoint, endPoint);
    // }
  }

  void _drawLine(Canvas canvas, Paint paint, vector_math.Vector3 p1, vector_math.Vector3 p2) {
    Offset o1 = Offset(p1.x, p1.y);
    Offset o2 = Offset(p2.x, p2.y);
    canvas.drawLine(o1, o2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return angle != (oldDelegate as CubePainter).angle;
  }
}
