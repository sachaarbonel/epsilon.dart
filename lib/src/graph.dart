import 'package:epsilon/src/settings.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Node {
  final String id;
  final String label;
  final Vector2 position;
  final double radius;

  Node(
      {@required this.id,
      this.label,
      @required this.position,
      @required this.radius})
      : assert(id != null, "Your Graph must be defined with a valid Node ID"),
        assert(position != null,
            "Your Graph must be defined with a valid Node position"),
        assert(radius != null,
            "Your Graph must be defined with a valid Node radius");

  void _drawNode(
      Canvas canvas, Color color, double zoom, Size size, Offset scaleOffset) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;
    final center = _recenter(zoom, scaleOffset);
    canvas.drawCircle(center, radius, paint);
  }

  Offset _recenter(double zoom, Offset scaleOffset) =>
      Offset(position.x, position.y) * zoom + scaleOffset;

  void _drawEdge(
      Canvas canvas, Node target, double zoom, Size size, Offset scaleOffset,
      {Settings settings}) {
    final paint = Paint()
      ..color = settings.edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.edgeWidth; //TODO: Stroke settings
    final center = _recenter(zoom, scaleOffset);
    final centerTarget = target._recenter(zoom, scaleOffset);
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(centerTarget.dx, centerTarget.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, bool shouldDraw, double zoom, Size size,
      Offset scaleOffset,
      {Settings settings}) {
    if (shouldDraw) {
      TextPainter(
          text: TextSpan(
              style: settings.labelStyle, text: label), //TODO: Text settings
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr)
        ..layout()
        ..paint(
            canvas,
            Offset(position.x + radius + radius / 2, position.y - radius / 4) *
                    zoom +
                scaleOffset); //TODO: extension method on Offset to recenter
    }
  }

  void _drawID(Canvas canvas, double zoom, Size size, Offset scaleOffset,
      {Settings settings}) {
    TextPainter(
        text: TextSpan(style: settings.iDStyle, text: id), //TODO: Text settings
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout()
      ..paint(
          canvas, Offset(position.x - 5, position.y - 5) * zoom + scaleOffset);
  }

  bool _contains(Offset offset, double zoom, Offset scaleOffset) =>
      Rect.fromCircle(
              center: Offset(position.x, position.y) * zoom + scaleOffset,
              radius: radius)
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

class Graph {
  final List<Edge> edges;
  final List<Node> nodes;

  Graph({@required this.edges, @required this.nodes})
      : assert(
            nodes != null, "Your graph must be defined with a list of nodes"),
        assert(
            edges != null, "Your graph must be defined with a list of edges");

  void draw(Canvas canvas, int selectedIndex, double zoom, Size size,
      Offset scaleOffset,
      {Settings settings}) {
    var i;
    Node source, target;
    for (i = 0; i < edges.length; i += 1) {
      source = _nodeSource(i);
      target = _nodeTarget(i);
      source._drawEdge(canvas, target, zoom, size, scaleOffset,
          settings: settings);
    }
    for (i = 0; i < nodes.length; i += 1) {
      source = nodes[i];
      source._drawNode(
          canvas,
          i == selectedIndex ? Colors.blue : Colors.redAccent,
          zoom,
          size,
          scaleOffset); //TODO: Color settings
      source._drawLabel(canvas, i == selectedIndex, zoom, size, scaleOffset,
          settings: settings);
      source._drawID(canvas, zoom, size, scaleOffset, settings: settings);
    }
  }

  Node _nodeSource(int idx) =>
      nodes.firstWhere((node) => node.id == edges[idx].source);

  Node _nodeTarget(int idx) =>
      nodes.firstWhere((node) => node.id == edges[idx].target);

  int getNodeIndex(BuildContext context, TapDownDetails details, double zoom,
      Offset scaleOffset) {
    RenderBox box = context.findRenderObject();
    final offset = box.globalToLocal(details.globalPosition);
    return nodes
        .lastIndexWhere((node) => node._contains(offset, zoom, scaleOffset));
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

class Edge {
  final String id;
  final String source;
  final String target;

  Edge({@required this.id, @required this.source, @required this.target})
      : assert(id != null, "Edge ID must not be null"),
        assert(source != null, "Edge source must not be null"),
        assert(target != null, "Edge target must not be null");

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
