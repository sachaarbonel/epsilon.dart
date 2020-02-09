import 'package:epsilon/epsilon.dart';
import 'package:epsilon/src/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:epsilon/src/graph.dart';

abstract class NodeRenderer {
  void renderNode(Canvas canvas, Offset center, double radius, Paint paint);
}

class NodeRendererImpl extends NodeRenderer {
  @override
  void renderNode(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
  }
}

class Epsilon extends StatefulWidget {
  final Graph graph;
  final void Function(Node node) onNodeSelect;
  final Settings settings;
  NodeRenderer _renderer;

  Epsilon(
      {Key key,
      this.graph,
      this.onNodeSelect,
      this.settings,
      NodeRenderer renderer})
      : assert(graph != null, "You must give sigma widget a graph to render"),
        assert(settings != null, "You must pass settings arguments"),
        _renderer = renderer != null ? renderer : NodeRendererImpl(),
        super(key: key);

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
    final size = MediaQuery.of(context).size;
    final int index =
        widget.graph.getNodeIndex(context, details, _zoom, _offset, size);
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
            painter: _GraphPainter(
              renderer: widget._renderer,
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

class _GraphPainter extends CustomPainter {
  const _GraphPainter({
    this.graph,
    this.selectedIndex,
    this.zoom,
    this.offset,
    this.forward,
    this.scaleEnabled,
    this.tapEnabled,
    this.doubleTapEnabled,
    this.longPressEnabled,
    this.settings,
    this.renderer,
  });

  final NodeRenderer renderer;
  final Settings settings;
  final Graph graph;
  final int selectedIndex;
  final double zoom;
  final Offset offset;

  //booleans
  final bool forward;
  final bool scaleEnabled;
  final bool tapEnabled;
  final bool doubleTapEnabled;
  final bool longPressEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    graph.draw(canvas, selectedIndex, zoom, size, offset,
        settings: settings, renderer: renderer);
  }

  @override
  bool shouldRepaint(_GraphPainter oldPainter) {
    return oldPainter.zoom != zoom ||
        oldPainter.offset != offset ||
        oldPainter.forward != forward ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.scaleEnabled != scaleEnabled ||
        oldPainter.tapEnabled != tapEnabled ||
        oldPainter.doubleTapEnabled != doubleTapEnabled ||
        oldPainter.longPressEnabled != longPressEnabled;
  }
}
