import 'package:flutter/material.dart';

class Player {
  String _name = "";
  Color _color = Colors.black;

  // Constructors
  Player (String name){
    _name = name;
  }

  // Getters
  String get name => _name;
  Color get color => _color;

  // Setters

  set name (String name ) => _name = name ;

  void setName(String name) {_name = name;}

  void setColor(Color color) => _color = color;



  // Methods
  @override
  String toString() {
    return "Name: $_name";
  }
}
