import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'painter.dart';

class Settings {
  final TextStyle labelStyle;

  final Color edgeColor;

  final TextStyle iDStyle;

  final double edgeWidth;

  Settings({this.edgeColor, this.labelStyle, this.iDStyle, this.edgeWidth});
}

class Node {
  final String id;
  final String label;
  final Vector2 position;
  final double radius;

  Node({this.id, this.label, this.position, this.radius});

  void drawNode(
      Canvas canvas, Color color, double zoom, Size size, Offset scaleOffset) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;
    final center = recenter(zoom, scaleOffset);
    canvas.drawCircle(center, radius, paint);
  }

  Offset recenter(double zoom, Offset scaleOffset) =>
      Offset(position.x, position.y) * zoom + scaleOffset;

  void drawEdge(
      Canvas canvas, Node target, double zoom, Size size, Offset scaleOffset,
      {Settings settings}) {
    final paint = Paint()
      ..color = settings.edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = settings.edgeWidth; //TODO: Stroke settings
    final center = recenter(zoom, scaleOffset);
    final centerTarget = target.recenter(zoom, scaleOffset);
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(centerTarget.dx, centerTarget.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void drawLabel(Canvas canvas, bool shouldDraw, double zoom, Size size,
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

  void drawID(Canvas canvas, double zoom, Size size, Offset scaleOffset,
      {Settings settings}) {
    TextPainter(
        text: TextSpan(style: settings.iDStyle, text: id), //TODO: Text settings
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr)
      ..layout()
      ..paint(
          canvas, Offset(position.x - 5, position.y - 5) * zoom + scaleOffset);
  }

  bool contains(Offset offset, double zoom, Offset scaleOffset) =>
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

class Epsilon extends StatefulWidget {
  final Graph graph;
  final void Function(Node node) onNodeSelect;
  final Settings settings;

  const Epsilon({Key key, this.graph, this.onNodeSelect, this.settings})
      : super(key: key);

  @override
  _SigmaState createState() => _SigmaState();
}

class _SigmaState extends State<Epsilon> {
  int _selectedIndex;
  Offset _startingFocalPoint;

  Offset _previousOffset;

  Offset _offset = Offset.zero;

  double _previousZoom;

  double _zoom = 1.0;

  bool _forward = true;

  bool _scaleEnabled = true;

  bool _tapEnabled = true;

  bool _doubleTapEnabled = true;

  bool _longPressEnabled = true;

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      _startingFocalPoint = details.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _zoom = _previousZoom * details.scale;

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = details.focalPoint - normalizedOffset * _zoom;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
    });
  }

  void _handleTap(TapDownDetails details) {
    final int index =
        widget.graph.getNodeIndex(context, details, _zoom, _offset);
    widget.onNodeSelect(widget.graph.nodes[index]);

    if (index != -1) {
      _onSelected(index);
      return;
    }
    _onSelected(-1);
  }

  void _handleDirectionChange() {
    setState(() {
      _forward = !_forward;
    });
  }

  void _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onScaleStart: _scaleEnabled ? _handleScaleStart : null,
          onScaleUpdate: _scaleEnabled ? _handleScaleUpdate : null,
          onTapDown: _tapEnabled ? _handleTap : null,
          onDoubleTap: _doubleTapEnabled ? _handleScaleReset : null,
          onLongPress: _longPressEnabled ? _handleDirectionChange : null,
          child: CustomPaint(
            painter: GraphPainter(
              settings: widget.settings,
              graph: widget.graph,
              selectedIndex: _selectedIndex,
              zoom: _zoom,
              offset: _offset,
              forward: _forward,
              scaleEnabled: _scaleEnabled,
              tapEnabled: _tapEnabled,
              doubleTapEnabled: _doubleTapEnabled,
              longPressEnabled: _longPressEnabled,
            ),
          ),
        ),
      ],
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

  void draw(Canvas canvas, int selectedIndex, double zoom, Size size,
      Offset scaleOffset,
      {Settings settings}) {
    var i;
    Node source, target;
    for (i = 0; i < edges.length; i += 1) {
      source = nodeSource(i);
      target = nodeTarget(i);
      source.drawEdge(canvas, target, zoom, size, scaleOffset,
          settings: settings);
    }
    for (i = 0; i < nodes.length; i += 1) {
      source = nodes[i];
      source.drawNode(
          canvas,
          i == selectedIndex ? Colors.blue : Colors.redAccent,
          zoom,
          size,
          scaleOffset); //TODO: Color settings
      source.drawLabel(canvas, i == selectedIndex, zoom, size, scaleOffset,
          settings: settings);
      source.drawID(canvas, zoom, size, scaleOffset, settings: settings);
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

  Node nodeSource(int idx) =>
      nodes.firstWhere((node) => node.id == edges[idx].source);

  Node nodeTarget(int idx) =>
      nodes.firstWhere((node) => node.id == edges[idx].target);

  int getNodeIndex(BuildContext context, TapDownDetails details, double zoom,
      Offset scaleOffset) {
    RenderBox box = context.findRenderObject();
    final offset = box.globalToLocal(details.globalPosition);
    return nodes
        .lastIndexWhere((node) => node.contains(offset, zoom, scaleOffset));
  }
}
