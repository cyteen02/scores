import 'package:flutter/material.dart';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:scores/extensions/color_extensions.dart';

class Player with MyMixin {
  int? id;
  String _name = "";
  int _color = 0;
  String? _photoPath;


  // Constructors

//   Player({
//     required this.name,
//     required this.favouriteColour,
//     this.photoPath,
//   });


Player();

  Player.name(String name) {
    _name = name;
  }

  Player.id(int this.id);

  // Getters
//  String name => _name;
    String get name => _name;

//  int? get id => id;

  Color get color {
    return _color.toColor();
  }

  String? get photoPath => _photoPath;

  // Setters

//  set id(int id) => this.id = id;

  // set name(String name) {
  //   _name = name;
  // }

  set photoPath(String photoPath) => _photoPath = photoPath;
  
  void setName(String name) {
    debugMsg("Player setName from $_name to $name");
    _name = name;
  }

  void setColor(Color color) => _color = color.toInt();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("Player toJson");
    return {
      'id': id,
      'name': _name,
      'color': _color, // Store color as integer
    };
  }

  // Create from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    Player player = Player();
    player.id = json['id'] ?? '';
    player._name = json['name'] ?? '';
    player._color = (json['color'] ?? 0);
    return player;
  }


Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': _name,
    'color': _color,
    'photoPath': _photoPath,
  };
}

factory Player.fromMap(Map<String, dynamic> map) {
  return Player()
    ..id = map['id']
    .._name = map['name']
    .._color = map['color']
    .._photoPath = map['photoPath'];
}

  // Methods
  @override
  String toString() {
    return "Id $id Name: $_name";
  }
}
