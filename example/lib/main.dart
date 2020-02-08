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
            settings: Settings(
              nodeActiveColor: Colors.blue,
                nodeSelectors: [
                  NodeSelector(
                    type: 'input',
                  )..attributes['color'] = Colors.red,
                  NodeSelector(
                    type: 'hidden',
                  )..attributes['color'] = Colors.purple,
                  NodeSelector(
                    type: 'output',
                  )..attributes['color'] = Colors.green
                ],
                edgeColor: Colors.redAccent,
                labelStyle: TextStyle(color: Colors.green),
                edgeWidth: 1.0,
                iDStyle: TextStyle(color: Colors.blue[800])),
            onNodeSelect: (Node node) {
              print('touching id ${node.id}');
              print('touching label ${node.label}');
              //print('touching type ${node.type}');
            },
            graph: Graph(nodes: [
              Node(
                  id: 'n0',
                  label: 'A node',
                  position: Vector2(0, 0),
                  radius: 30,
                  type: 'input'),
              Node(
                  id: 'n1',
                  label: 'Another node',
                  position: Vector2(300, 100),
                  radius: 20,
                  type: 'hidden'),
              Node(
                id: 'n2',
                label: 'And a last one',
                position: Vector2(100, 300),
                radius: 20,
                type: 'output',
              )
            ], edges: [
              Edge(id: 'e0', source: 'n0', target: 'n1'),
              Edge(id: 'e1', source: 'n1', target: 'n2',),
              Edge(id: 'e2', source: 'n2', target: 'n0', )
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
