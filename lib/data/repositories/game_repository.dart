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

import 'package:scores/data/models/round_label.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/data/repositories/round_label_repository.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

class GameRepository {
  final dbHelper = DatabaseHelper.instance;
  final RoundLabelRepository _roundLabelRepository;

  GameRepository(this._roundLabelRepository);

  // final Database db;

  // GameRepository(this.db);

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

  Future<Game?> getGameOLD(int id) async {
    debugMsg("getGame id $id");

    final db = await dbHelper.database;
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

    Game game = Game(id: id, name: map['name'] as String);

    game.showFutureRoundsType = ShowFutureRoundsType.values.byName(
      map['showFutureRoundsType'] as String,
    );
    game.winCondition = WinCondition.values.byName(
      map['winCondition'] as String,
    );

    return game;
  }

  //----------------------------------------------------------------

  Future<Game> getGameByName(String name) async {
    debugMsg("getGameByName name $name");

    final db = await dbHelper.database;
    final result = await db.query(
      'game', // your table name
      where: 'name = ?',
      whereArgs: [name],
    );

    // if (result.isEmpty) {
    //   return null; // no game type found with that id
    // }

    debugMsg("query result $result");

    final map = result.first;

    Game game = Game(id: map['id'] as int, name: name);
    // game.id = map['id'] as int;
    // game.name = map['name'] as String;

    game.showFutureRoundsType = ShowFutureRoundsType.values.byName(
      map['showFutureRoundsType'] as String,
    );
    game.winCondition = WinCondition.values.byName(
      map['winCondition'] as String,
    );

    game.gameLengthType = GameLengthType.values.byName(
      map['gameLengthType'] as String,
    );

    game.roundLabels = await _roundLabelRepository.getByGameId(game.id ?? 0);

    return game;
  }

  //----------------------------------------------------------------

  Future<List<Game>> getAllGames() async {
    final db = await dbHelper.database;

    List<Game> games = [];

    try {
      final List<Map<String, dynamic>> maps = await db.query('game');

      Game game;
      for (Map<String, dynamic> gameMap in maps) {
        game = Game.fromMap(gameMap);
        var roundLabels = await _roundLabelRepository.getByGameId(game.id ?? 0);
        games.add(Game.fromMap(gameMap, roundLabels: roundLabels));
      }

      // return List.generate(maps.length, (i) {
      //   return Game.fromMap(maps[i]);
      // });
    } on Exception catch (e) {
      errorMsg('Error loading game: $e');
      return []; // Return empty list on error
    }

    return games;
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

    debugMsg("updateGame game $game");

    return await db.transaction((txn) async {
      try {
        debugMsg("${game.toMap()}",box: true);
        db.update('game', game.toMap(), where: 'id = ?', whereArgs: [game.id]);

        // Delete existing round labels if updating
        await txn.delete(
          'round_label',
          where: 'game_id = ?',
          whereArgs: [game.id],
        );

        // Insert all round labels
        for (final label in game.roundLabels) {
          await txn.insert('round_label', {
            ...label.toMap(),
            'game_id': game.id,
          });
        }
      } on Exception catch (e) {
        errorMsg(e.toString(), box: true);
      }
    });
  }

  //----------------------------------------------------------------

  Future<void> deleteGame(int id) async {
    final db = await dbHelper.database;
    await db.delete('game', where: 'id = ?', whereArgs: [id]);
  }

  //----------------------------------------------------------------

  // Delete a game (round labels will be cascade deleted if you set up the FK correctly)
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      // Delete round labels first
      await txn.delete('round_label', where: 'game_id = ?', whereArgs: [id]);

      // Delete game
      return await txn.delete('game', where: 'id = ?', whereArgs: [id]);
    });
  }

  //----------------------------------------------------------------

  // Get a single game by ID with its round labels
  Future<Game?> getById(int id) async {
    final db = await dbHelper.database;
    final gameMaps = await db.query('game', where: 'id = ?', whereArgs: [id]);

    if (gameMaps.isEmpty) {
      return null;
    }

    // Get associated round labels
    final labelMaps = await db.query(
      'round_label',
      where: 'game_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    final roundLabels = labelMaps
        .map((map) => RoundLabel.fromMap(map))
        .toList();

    return Game.fromMap(gameMaps.first, roundLabels: roundLabels);
  }
  //----------------------------------------------------------------

  Future<Game> saveGameWithRoundLabels(Game game) async {
    final db = await dbHelper.database;

    debugMsg("saveGameWithRoundLabels game $game");

    return await db.transaction((txn) async {
      // Save the game first
      final gameId =
          game.id ??
          await txn.insert('game', {
            'name': game.name,
            'showFutureRoundsType': game.showFutureRoundsType.name,
            'winCondition': game.winCondition.name,
          });
      // Delete existing round labels if updating
      if (game.id != null) {
        await txn.delete(
          'round_label',
          where: 'game_id = ?',
          whereArgs: [gameId],
        );
      }

      // Insert all round labels
      for (final label in game.roundLabels) {
        await txn.insert('round_label', {...label.toMap(), 'game_id': gameId});
      }

      return game.copyWith(id: gameId);
    });
  }

  //----------------------------------------------------------------

  // Get all games with their round labels
  Future<List<Game>> getAll() async {
    final db = await dbHelper.database;
    final gameMaps = await db.query('game', orderBy: 'name ASC');

    final games = <Game>[];
    for (final gameMap in gameMaps) {
      final gameId = gameMap['id'] as int;

      // Get round labels for this game
      final labelMaps = await db.query(
        'round_label',
        where: 'game_id = ?',
        whereArgs: [gameId],
        orderBy: 'id ASC',
      );

      final roundLabels = labelMaps
          .map((map) => RoundLabel.fromMap(map))
          .toList();
      games.add(Game.fromMap(gameMap, roundLabels: roundLabels));
    }

    return games;
  }

  //----------------------------------------------------------------
}
