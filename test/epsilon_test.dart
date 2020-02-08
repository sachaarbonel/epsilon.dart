import 'package:epsilon/epsilon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('A group of tests', () {
    test('Serialize graph test', () {
      final graph = Graph(nodes: [
        Node(
            id: 'n0',
            label: 'A node',
            position: Vector2(0, 0),
            radius: 3,
            type: 'input'),
        Node(
            id: 'n1',
            label: 'Another node',
            position: Vector2(30, 10),
            radius: 2,
            type: 'hidden'),
        Node(
            id: 'n2',
            label: 'And a last one',
            position: Vector2(10, 30),
            radius: 1,
            type: 'output')
      ], edges: [
        Edge(id: 'e0', source: 'n0', target: 'n1'),
        Edge(id: 'e1', source: 'n1', target: 'n2'),
        Edge(id: 'e2', source: 'n2', target: 'n0')
      ]);
      final jsonGraph = {
        'nodes': [
          {
            'id': 'n0',
            'label': 'A node',
            'x': 0.0,
            'y': 0.0,
            'size': 3.0,
            'type': 'input'
          },
          {
            'id': 'n1',
            'label': 'Another node',
            'x': 30.0,
            'y': 10.0,
            'size': 2.0,
            'type': 'hidden'
          },
          {
            'id': 'n2',
            'label': 'And a last one',
            'x': 10.0,
            'y': 30.0,
            'size': 1.0,
            'type': 'output'
          }
        ],
        'edges': [
          {'id': 'e0', 'source': 'n0', 'target': 'n1'},
          {'id': 'e1', 'source': 'n1', 'target': 'n2'},
          {'id': 'e2', 'source': 'n2', 'target': 'n0'}
        ]
      };
      expect(graph.toJson(), jsonGraph);
      expect(Graph.fromJson(jsonGraph).toJson(),
          graph.toJson()); //not ideal TODO: implement equatable
    });
  });
}
