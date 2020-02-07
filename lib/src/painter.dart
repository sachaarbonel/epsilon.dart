import 'package:flutter/rendering.dart';
import 'package:sigma/src/graph.dart';

class GraphPainter extends CustomPainter {
  final Graph graph;
  final int selectedIndex;

  GraphPainter({this.graph, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    graph.draw(canvas, selectedIndex);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
