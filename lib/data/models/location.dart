/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/17/2026
*
*----------------------------------------------------------------------------*/

class Location {
  final int? id;
  final String name;
  final String? description;
  final int color;

  Location({
    this.id,
    required this.name,
    this.description,
    required this.color,
  });

  // Convert a Location to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }

//---------------------------------------------------------------------------

  // Create a Location from a Map (from database)
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
    );
  }

//---------------------------------------------------------------------------
  // Create a copy with optional field updates
  Location copyWith({
    int? id,
    String? name,
    String? description,
    int? color,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Location{id: $id, name: $name, description: $description, color: $color}';
  }
}