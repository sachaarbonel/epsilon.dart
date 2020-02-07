import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Node {
  final String id;
  final String label;
  final Vector2 position;
  final double size;
  Node({this.id, this.label, this.position, this.size});

  void drawNode(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(Offset(position.x, position.y), size, paint);
  }

  void drawEdge(Canvas canvas, Node target) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path()
      ..moveTo(position.x, position.y)
      ..lineTo(target.position.x, target.position.y)
      ..close();
    canvas.drawPath(path, paint);
  }
}

class Edge {
  final String id;
  final String source;
  final String target;

  Edge({this.id, this.source, this.target});
}

class Graph {
  final List<Edge> edges;
  final List<Node> nodes;

  Graph({this.edges, this.nodes});

  void draw(Canvas canvas) {
    var i;
    Node source, target;
    for (i = 0; i < edges.length; i += 1) {
      source = nodes.firstWhere((node) => node.id == edges[i].source);
      target = nodes.firstWhere((node) => node.id == edges[i].target);
      source.drawEdge(canvas, target);
    }
    for (i = 0; i < nodes.length; i += 1) {
      source = nodes[i];
      source.drawNode(canvas);
    }
  }
}
