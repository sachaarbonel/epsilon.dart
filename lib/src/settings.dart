import 'dart:collection';

import 'package:flutter/material.dart';

class Settings {
  final TextStyle labelStyle;

  final Color edgeColor;

  final TextStyle iDStyle;

  final double edgeWidth;
  final List<NodeSelector> nodeSelectors;
  final Color nodeActiveColor;
  final bool renderID;

  Settings(
      {this.edgeColor = Colors.redAccent,
      this.labelStyle = const TextStyle(color: Colors.green),
      this.iDStyle = const TextStyle(color: Colors.blue),
      this.edgeWidth = 1.0,
      this.nodeSelectors, //TODO: handle null
      this.nodeActiveColor,
      this.renderID = true}); //TODO: default values
}

abstract class NodeAttribute {}

class NodeSelector extends NodeAttribute {
  final String type;
  LinkedHashMap<String, dynamic> _attributes = LinkedHashMap();
  LinkedHashMap<String, dynamic> get attributes => _attributes;
  set attributes(LinkedHashMap<String, dynamic> attributes) => _attributes;

  NodeSelector({this.type});
}
