/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/25/2025
*
*----------------------------------------------------------------------------*/

import 'package:scores/database/database_helper.dart';
import 'package:scores/models/game.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

class GameRepository {
  final dbHelper = DatabaseHelper.instance;

  //----------------------------------------------------------------

  Future<void> insertGame(Game game) async {
    final db = await dbHelper.database;
    final newId = await db.insert(
      'game',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    game.id = newId;
  }

  //----------------------------------------------------------------

  Future<Game?> getGame(int id) async {
    final db = await dbHelper.database;

    debugMsg("getGame id $id");

    final result = await db.query(
      'game', // your table name
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null; // no game found with that id
    }

    debugMsg("result $result");

    final map = result.first;

    Game game = Game();
    game.id = map['id'] as int;
    game.name = map['name'] as String;

    // Parse comma-separated string
    String roundListStr = map['roundList'] as String;
    game.roundList = roundListStr.isEmpty ? [] : roundListStr.split(',');
    game.showFutureRoundsType = ShowFutureRoundsType.values.byName(map['showFutureRoundsType'] as String);
    game.winCondition = WinCondition.values.byName(map['winCondition'] as String);

    return game;
  }

  //----------------------------------------------------------------

  Future<Game?> getGameByName(String name) async {
    final db = await dbHelper.database;

    debugMsg("getGameByName name $name");

    final result = await db.query(
      'game', // your table name
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isEmpty) {
      return null; // no game type found with that id
    }

    debugMsg("result $result");

    final map = result.first;

    Game game = Game();
    game.id = map['id'] as int;
    game.name = map['name'] as String;

    // Parse comma-separated string
    String roundListStr = map['roundList'] as String;
    game.roundList = roundListStr.isEmpty ? [] : roundListStr.split(',');
    game.showFutureRoundsType = ShowFutureRoundsType.values.byName(map['showFutureRoundsType'] as String);
    game.winCondition = WinCondition.values.byName(map['winCondition'] as String);



    return game;
  }

  //----------------------------------------------------------------

  Future<List<Game>> getAllGames() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('game');

      return List.generate(maps.length, (i) {
        return Game.fromMap(maps[i]);
      });
    } on Exception catch (e) {
      errorMsg('Error loading game: $e');
      return []; // Return empty list on error
    }
  }

  //----------------------------------------------------------------

  Future<bool> nameExists(String gameName) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM game WHERE name = ?',
      [gameName],
    );

    return (result.first['count'] as int > 0);
  }

  //----------------------------------------------------------------

  Future<void> updateGame(Game game) async {
    final db = await dbHelper.database;

    await db.update(
      'game',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  //----------------------------------------------------------------

  Future<void> deleteGame(int id) async {
    final db = await dbHelper.database;
    await db.delete('game', where: 'id = ?', whereArgs: [id]);
  }

  //----------------------------------------------------------------
}
