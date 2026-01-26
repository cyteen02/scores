/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/03/2026
*
*----------------------------------------------------------------------------*/

import 'package:scores/utils/my_utils.dart';

class RoundLabel {
  final int? id;
  final String name;
  final String? description;
  final int color;
  final int icon;

  RoundLabel({
    this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
  });

  //---------------------------------------------------------------------------

  // Convert a RoundLabel to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
    };
  }
  //---------------------------------------------------------------------------

  // Create a RoundLabel from a Map (from database)
  factory RoundLabel.fromMap(Map<String, dynamic> map) {
    return RoundLabel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
      icon: map['icon'] as int,
    );
  }
  //---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    debugMsg("Match toJson");

    Map<String, dynamic> jsonString;

    jsonString = {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
    };

    debugMsg(jsonString.toString(), box: true);
    return jsonString;
  }
  //---------------------------------------------------------------------------

  factory RoundLabel.fromJson(Map<String, dynamic> json) {
    return RoundLabel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as int,
      icon: json['icon'] as int,
    );
  }
  //---------------------------------------------------------------------------
  // Create a copy with optional field updates
  RoundLabel copyWith({
    int? id,
    String? name,
    String? description,
    int? color,
    int? icon,
  }) {
    return RoundLabel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
  //---------------------------------------------------------------------------

  @override
  String toString() {
    return 'RoundLabel{id: $id, name: $name, description: $description, color: $color, icon: $icon}';
  }
}
