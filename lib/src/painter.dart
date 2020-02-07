import 'package:flutter/rendering.dart';
import 'package:sigma/src/graph.dart';

class GraphPainter extends CustomPainter {
  final Graph graph;

  GraphPainter({this.graph});

  @override
  void paint(Canvas canvas, Size size) {
    graph.draw(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
