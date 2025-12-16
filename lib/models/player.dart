import 'package:flutter/material.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/extensions/color_extensions.dart';

class Player with MyUtils {
  String _name = "";
  int _color = 0;
//  Color _color = Colors.black;

  // Constructors
  Player(String name) {
    _name = name;
  }

  Player.blank();

  // Getters
  String get name => _name;

  Color get color {
    return _color.toColor();
  }

  // Setters

  set name(String name) => _name = name;

  void setName(String name) {
    _name = name;
  }

  void setColor(Color color) => _color = color.toInt();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("Player toJson");
    return {
      'name': _name,
      'color': _color, // Store color as integer
    };
  }




  // Create from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    Player player = Player.blank();
    player._name = json['name'] ?? '';
    player._color = (json['color'] ?? 0);
    return player;
  }

  // Methods
  @override
  String toString() {
    return "Name: $_name";
  }
}
