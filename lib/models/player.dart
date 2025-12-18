import 'package:flutter/material.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/extensions/color_extensions.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Player with MyUtils {
  String _id = "";
  String _name = "";
  int _color = 0;
  //  Color _color = Colors.black;

  // Constructors
  Player(String name) {
    _id = uuid.v1();
    _name = name;
  }

  Player.blank() {
    _id = uuid.v1();
  }

  // Getters
  String get name => _name;

  String get id => _id;

  Color get color {
    return _color.toColor();
  }

  // Setters

  set name(String name) => _name = name;

  void setName(String name) {
    debugMsg("Player setName from $_name to $name");
    _name = name;
  }

  void setColor(Color color) => _color = color.toInt();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("Player toJson");
    return {
      'id': _id,
      'name': _name,
      'color': _color, // Store color as integer
    };
  }

  // Create from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    Player player = Player.blank();
    player._id = json['id'] ?? '';
    player._name = json['name'] ?? '';
    player._color = (json['color'] ?? 0);
    return player;
  }

  // Methods
  @override
  String toString() {
    return "Id $_id Name: $_name";
  }
}
