import 'package:flutter/material.dart';
import 'package:sigma/sigma.dart';
import 'package:vector_math/vector_math_64.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class MyApp extends StatelessWidget {
  final Graph graph;
  MyApp({this.graph});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: CustomPaint(painter: GraphPainter(graph: graph)),
        ),
      ),
    );
  }
}

void main() {
  final graph = Graph(nodes: [
    Node(id: 'n0', label: 'A node', position: Vector2(0, 0), size: 3),
    Node(id: 'n1', label: 'Another node', position: Vector2(30, 10), size: 2),
    Node(id: 'n2', label: 'And a last one', position: Vector2(10, 30), size: 1)
  ], edges: [
    Edge(id: 'e0', source: 'n0', target: 'n1'),
    Edge(id: 'e1', source: 'n1', target: 'n2'),
    Edge(id: 'e2', source: 'n2', target: 'n0')
  ]);

  runApp(MyApp(graph: graph));
}
