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

import 'package:scores/data/models/location.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

class LocationRepository {
  final dbHelper = DatabaseHelper.instance;

  LocationRepository();

  //---------------------------------------------------------------------------

  // Create a new location
  Future<Location> create(Location location) async {
    final db = await dbHelper.database;

    final id = await db.insert(
      'location',
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return location.copyWith(id: id);
  }

  //-----------------------------------------------------------

  // Get a single location by ID
  Future<Location?> getById(int id) async {
    final db = await dbHelper.database;

    final maps = await db.query('location', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return null;
    }

    return Location.fromMap(maps.first);
  }

  //-----------------------------------------------------------

  // Get all locations
  Future<List<Location>> getAll() async {
    debugMsg("getAll");
    final db = await dbHelper.database;
    debugMsg("db $db");    
    final maps = await db.query('location', orderBy: 'name ASC');
    debugMsg("maps $maps");
    return maps.map((map) => Location.fromMap(map)).toList();
  }

  //-----------------------------------------------------------

  // Update an existing location
  Future<int> update(Location location) async {
    final db = await dbHelper.database;
    return await db.update(
      'location',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  //-----------------------------------------------------------

  // Delete a location
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('location', where: 'id = ?', whereArgs: [id]);
  }

  //-----------------------------------------------------------

  // Search locations by name
  Future<List<Location>> searchByName(String query) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'location',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Location.fromMap(map)).toList();
  }

  //-----------------------------------------------------------

  // Get count of all locations
  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM location');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //-----------------------------------------------------------
}
