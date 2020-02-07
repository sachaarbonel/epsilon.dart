import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'painter.dart';

class Node {
  final String id;
  final String label;
  final Vector2 position;
  final double radius;
  Node({this.id, this.label, this.position, this.radius});

  void drawNode(Canvas canvas, MaterialColor materialColor) {
    final paint = Paint()
      ..color = materialColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(Offset(position.x, position.y), radius, paint);
  }

  void drawEdge(Canvas canvas, Node target) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; //TODO: Stroke settings
    final path = Path()
      ..moveTo(position.x, position.y)
      ..lineTo(target.position.x, target.position.y)
      ..close();
    canvas.drawPath(path, paint);
  }

  void drawLabel(Canvas canvas, bool shouldDraw) {
    if (shouldDraw) {
      TextPainter(
          text: TextSpan(
              style: TextStyle(color: Colors.blue[800]),
              text: label), //TODO: Text settings
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr)
        ..layout()
        ..paint(canvas,
            Offset(position.x + radius + radius / 2, position.y - radius / 4));
    }
  }

  void drawID(Canvas canvas) {
    TextPainter(
        text: TextSpan(
            style: TextStyle(color: Colors.blue[800]),
            text: id), //TODO: Text settings
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(position.x - 5, position.y - 5));
  }

  bool contains(Offset offset) =>
      Rect.fromCircle(center: Offset(position.x, position.y), radius: radius)
          .contains(offset);

  factory Node.fromJson(Map<String, dynamic> json) => Node(
        id: json['id'],
        label: json['label'],
        position: Vector2(json['x'], json['y']),
        radius: json['size'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'x': position.x,
        'y': position.y,
        'size': radius,
      };
}

class Sigma extends StatelessWidget {
  final Graph graph;
  final void Function(int) onSelected;
  final int selectedIndex;

  const Sigma({Key key, this.graph, this.onSelected, this.selectedIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        RenderBox box = context.findRenderObject();
        final offset = box.globalToLocal(details.globalPosition);
        final index =
            graph.nodes.lastIndexWhere((node) => node.contains(offset));
        print('touching id ${graph.nodes[index].id}');
        print('touching label ${graph.nodes[index].label}');
        if (index != -1) {
          onSelected(index);
          return;
        }
        onSelected(-1);
      },
      child: CustomPaint(
        // size: Size(320, 240),
        painter: GraphPainter(graph: graph, selectedIndex: selectedIndex),
      ),
    );
  }
}

class Edge {
  final String id;
  final String source;
  final String target;

  Edge({this.id, this.source, this.target});

  factory Edge.fromJson(Map<String, dynamic> json) => Edge(
        id: json['id'],
        source: json['source'],
        target: json['target'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'target': target,
      };
}

class Graph {
  final List<Edge> edges;
  final List<Node> nodes;

  Graph({this.edges, this.nodes});

  void draw(Canvas canvas, int selectedIndex) {
    var i;
    Node source, target;
    for (i = 0; i < edges.length; i += 1) {
      source = nodes.firstWhere((node) => node.id == edges[i].source);
      target = nodes.firstWhere((node) => node.id == edges[i].target);
      source.drawEdge(canvas, target);
    }
    for (i = 0; i < nodes.length; i += 1) {
      source = nodes[i];
      source.drawNode(
          canvas,
          i == selectedIndex
              ? Colors.blue
              : Colors.redAccent); //TODO: Color settings
      source.drawLabel(canvas, i == selectedIndex);
      source.drawID(canvas);
    }
  }

  factory Graph.fromJson(Map<String, dynamic> json) => Graph(
        nodes: List<Node>.from(json['nodes'].map((x) => Node.fromJson(x))),
        edges: List<Edge>.from(json['edges'].map((x) => Edge.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'nodes': List<dynamic>.from(nodes.map((x) => x.toJson())),
        'edges': List<dynamic>.from(edges.map((x) => x.toJson())),
      };
}
