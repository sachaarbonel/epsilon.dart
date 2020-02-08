import 'package:flutter/rendering.dart';
import 'package:sigma/src/graph.dart';

class GraphPainter extends CustomPainter {
  const GraphPainter({
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
  });
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
    graph.draw(canvas, selectedIndex, zoom, size, offset, settings: settings);
  }

  @override
  bool shouldRepaint(GraphPainter oldPainter) {
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
