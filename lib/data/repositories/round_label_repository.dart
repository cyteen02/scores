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

import 'package:scores/data/models/round_label.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class RoundLabelRepository {

  final dbHelper = DatabaseHelper.instance;

  RoundLabelRepository();

  //----------------------------------------------------------------

  // Create a new round label
  Future<RoundLabel> create(RoundLabel roundLabel) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      'round_label',
      roundLabel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return roundLabel.copyWith(id: id);
  }

  //----------------------------------------------------------------

  // Get a single round label by ID
  Future<RoundLabel?> getById(int id) async {
    final db = await dbHelper.database;
        final maps = await db.query(
      'round_label',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return RoundLabel.fromMap(maps.first);
  }

  //----------------------------------------------------------------

  Future<List<RoundLabel>> getByGameId(int gameId) async {

    final db = await dbHelper.database;
    List<RoundLabel> roundLabelList = [];

    final List<Map<String, dynamic>> maps = await db.query(
      'round_label',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    if (maps.isEmpty) {
      return roundLabelList;
    }

    return maps.map((map) => RoundLabel.fromMap(map)).toList();
  }

  //----------------------------------------------------------------

  // Get all round labels
  Future<List<RoundLabel>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query('round_label', orderBy: 'name ASC');
    return maps.map((map) => RoundLabel.fromMap(map)).toList();
  }

  //----------------------------------------------------------------

  // Update an existing round label
  Future<int> update(RoundLabel roundLabel) async {
    final db = await dbHelper.database;
    return await db.update(
      'round_label',
      roundLabel.toMap(),
      where: 'id = ?',
      whereArgs: [roundLabel.id],
    );
  }

  //----------------------------------------------------------------

  // Delete a round label
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
        return await db.delete('round_label', where: 'id = ?', whereArgs: [id]);
  }

  //----------------------------------------------------------------

  // Search round labels by name
  Future<List<RoundLabel>> searchByName(String query) async {
        final db = await dbHelper.database;
    final maps = await db.query(
      'round_label',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => RoundLabel.fromMap(map)).toList();
  }

  //----------------------------------------------------------------

  // Get count of all round labels
  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM round_label',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //----------------------------------------------------------------
}
