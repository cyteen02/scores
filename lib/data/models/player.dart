import 'package:flutter/material.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:scores/data/extensions/color_extensions.dart';


class Player with MyMixin {
  int id;
  String name;
  int color;
  String photoPath;


  // Constructors

  Player({
    required this.id,
    required this.name,
    this.color = 0,
    this.photoPath = ""
  });


// Player();

//   Player.name(String name) {
//     _name = name;
//   }

//   Player.id(int this.id);

  // Getters
//  String name => _name;
    // String get name => _name;

//  int? get id => id;

  // Color get color {
  //   return color.toColor();
  // }

  // String? get photoPath => _photoPath;

  // Setters

//  set id(int id) => this.id = id;

  // set name(String name) {
  //   _name = name;
  // }

  // set photoPath(String photoPath) => _photoPath = photoPath;
  
  // void setName(String name) {
  //   debugMsg("Player setName from $_name to $name");
  //   _name = name;
  // }

  void setColor(Color c) => color = c.toInt();

//---------------------------------------------------------------------------

  factory Player.copyFrom(Player oldPlayer) {

    return Player(id: oldPlayer.id,
                  name: oldPlayer.name,
                  color: oldPlayer.color,
                  photoPath: oldPlayer.photoPath);
  }

  //---------------------------------------------------------------------------
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("Player toJson");
    return {
      'id': id,
      'name': name,
      'color': color, // Store color as integer
      'photoPath': photoPath
    };
  }

  // Create from JSON
  factory Player.fromJson(Map<String, dynamic> json) {

  return Player(
    id: json['id'],
    name: json['name'],
    color: json['color'],
    photoPath: json['photoPath']??"");
  }


Map<String, dynamic> toMap() {
  return {
     'id': id,
    'name': name,
    'color': color,
    'photoPath': photoPath
  };
}

factory Player.fromMap(Map<String, dynamic> map) {
  return Player(
    id: map['id'],
    name: map['name'],
    color: map['color'],
    photoPath: map['photoPath']??""    
  );
}

  // Methods
  @override
  String toString() {
    return "Id $id Name: $name";
  }
}
