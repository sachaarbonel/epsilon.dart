# Epsilon 

Epsilon is a Dart library dedicated to graph drawing.
"Epsilon" in reference to the mathematics way to denote the number of edges of a graph.

![20200209_210252.gif](20200209_210252.gif)


## Usage

A simple usage example:

```dart
import 'package:flutter/material.dart';
import 'package:epsilon/epsilon.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Epsilon(
            onNodeSelect: (Node node) {
              print('touching id ${node.id}');
              print('touching label ${node.label}');
            },
            graph: Graph(nodes: [
              Node(
                  id: 'n0',
                  label: 'A node',
                  position: Vector2(0, 0),
                  radius: 30),
              Node(
                  id: 'n1',
                  label: 'Another node',
                  position: Vector2(300, 100),
                  radius: 20),
              Node(
                  id: 'n2',
                  label: 'And a last one',
                  position: Vector2(100, 300),
                  radius: 20)
            ], edges: [
              Edge(id: 'e0', source: 'n0', target: 'n1'),
              Edge(id: 'e1', source: 'n1', target: 'n2'),
              Edge(id: 'e2', source: 'n2', target: 'n0')
            ]),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
```


Need to display Node with a different shape that a simple circle ? No problem we got you covered. Just define a define renderer like this :
```dart
import 'dart:math' as math;

void drawStar(Canvas canvas, double cx, double cy, int spikes, int outerRadius,
    int innerRadius) {
  var rot = math.pi / 2 * 3;
  var x = cx;
  var y = cy;
  var step = math.pi / spikes;
  final paint = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke
    ..color = Colors.blue;
  final path = Path()..moveTo(cx, cy - outerRadius);
  for (var i = 0; i < spikes; i++) {
    x = cx + math.cos(rot) * outerRadius;
    y = cy + math.sin(rot) * outerRadius;
    path.lineTo(x, y);
    rot += step;

    x = cx + math.cos(rot) * innerRadius;
    y = cy + math.sin(rot) * innerRadius;
    path.lineTo(x, y);
    rot += step;
  }
  path.lineTo(cx, cy - outerRadius);
  path.close();
  canvas.drawPath(path, paint);
}

class MyNodeRenderer extends NodeRenderer {
  @override
  void renderNode(Canvas canvas, Offset center, double radius, Paint paint) {
    drawStar(canvas, center.dx, center.dy, 5, 30, 15);
  }
}
```

## TODOs 

- [ ] fix center canvas
- [ ] add support for shaders
- [ ] add support for legend
- [ ] add support for graph theory algorithms (for example : on click highlight neighbours)
- [ ] support some physics
- [ ] add possibility to edit nodes on the fly (add, delete, remove, attach edge to another node)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
