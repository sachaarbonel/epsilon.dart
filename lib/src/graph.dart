import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'painter.dart';

class Node {
  final String id;
  final String label;
  final Vector2 position;
  final double radius;
  Node({this.id, this.label, this.position, this.radius});

  void drawNode(
      Canvas canvas, Color color, double zoom, Size size, Offset offset) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(Offset(position.x, position.y), radius, paint);
  }

  void drawEdge(
      Canvas canvas, Node target, double zoom, Size size, Offset offset) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; //TODO: Stroke settings
    final path = Path()
      ..moveTo(position.x * zoom, position.y * zoom)
      ..lineTo(target.position.x * zoom, target.position.y * zoom)
      ..close();
    canvas.drawPath(path, paint);
  }

  void drawLabel(
      Canvas canvas, bool shouldDraw, double zoom, Size size, Offset offset) {
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

  void drawID(Canvas canvas, double zoom, Size size, Offset offset) {
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

class Sigma extends StatefulWidget {
  final Graph graph;
  final void Function(int) onSelected;
  final int selectedIndex;

  const Sigma({Key key, this.graph, this.onSelected, this.selectedIndex})
      : super(key: key);
  static const List<MaterialColor> kSwatches = <MaterialColor>[
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  _SigmaState createState() => _SigmaState();
}

class _SigmaState extends State<Sigma> {
  Offset _startingFocalPoint;

  Offset _previousOffset;

  Offset _offset = Offset.zero;

  double _previousZoom;

  double _zoom = 1.0;

  int _swatchIndex = 0;

  MaterialColor _swatch = Sigma.kSwatches.first;

  MaterialColor get swatch => _swatch;

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
    RenderBox box = context.findRenderObject();
    final offset = box.globalToLocal(details.globalPosition);
    final index =
        widget.graph.nodes.lastIndexWhere((node) => node.contains(offset));
    print('touching id ${widget.graph.nodes[index].id}');
    print('touching label ${widget.graph.nodes[index].label}');
    if (index != -1) {
      widget.onSelected(index);
      return;
    }
    widget.onSelected(-1);
  }

  void _handleDirectionChange() {
    setState(() {
      _forward = !_forward;
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
              graph: widget.graph,
              selectedIndex: widget.selectedIndex,
              zoom: _zoom,
              offset: _offset,
              swatch: swatch,
              forward: _forward,
              scaleEnabled: _scaleEnabled,
              tapEnabled: _tapEnabled,
              doubleTapEnabled: _doubleTapEnabled,
              longPressEnabled: _longPressEnabled,
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _scaleEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _scaleEnabled = value;
                          });
                        },
                      ),
                      const Text('Scale'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _tapEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _tapEnabled = value;
                          });
                        },
                      ),
                      const Text('Tap'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _doubleTapEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _doubleTapEnabled = value;
                          });
                        },
                      ),
                      const Text('Double Tap'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _longPressEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _longPressEnabled = value;
                          });
                        },
                      ),
                      const Text('Long Press'),
                    ],
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
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

  void draw(
      Canvas canvas, int selectedIndex, double zoom, Size size, Offset offset) {
    var i;
    Node source, target;
    for (i = 0; i < edges.length; i += 1) {
      source = nodes.firstWhere((node) => node.id == edges[i].source);
      target = nodes.firstWhere((node) => node.id == edges[i].target);
      source.drawEdge(canvas, target, zoom, size, offset);
    }
    for (i = 0; i < nodes.length; i += 1) {
      source = nodes[i];
      source.drawNode(
          canvas,
          i == selectedIndex ? Colors.blue : Colors.redAccent,
          zoom,
          size,
          offset); //TODO: Color settings
      source.drawLabel(canvas, i == selectedIndex, zoom, size, offset);
      source.drawID(canvas, zoom, size, offset);
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
