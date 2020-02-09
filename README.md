# Epsilon 

Epsilon is a Dart library dedicated to graph drawing.
"Epsilon" is a reference to the mathematics way to denote the number of edges of a graph.

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

## TODOs 

- [ ] fix center canvas
- [ ] add support for shaders
- [ ] add support for legend
- [ ] abstract draw methods with custom renderer (for example drawing molecules)
- [ ] add support for graph theory algorithms (for example : on click highlight neighbours)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
