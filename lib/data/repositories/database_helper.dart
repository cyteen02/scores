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

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = "scores.db";
const int dbVersion = 14;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Table Names
  static const tableGame = 'game';
  static const tableRoundLabel = 'round_label';
  static const tablePlayer = 'player';
  static const tableLocation = 'location';
  static const tablePlayerSet = 'player_set';
  static const tablePlayerSetPlayers = 'player_set_players';
  static const tableMatchHistory = 'match_history';
  static const tableMatchStats = 'match_stats';
  static const tableMatchPlayerStats = 'match_player_stats';
  static const viewGamePlayersView = 'game_players_view';

  // Create Statements
  static const createTableGame =
      '''
    CREATE TABLE $tableGame (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color INTEGER NOT NULL DEFAULT 0,
      showFutureRoundsType TEXT DEFAULT "showNoFutureRounds",        
      winCondition TEXT DEFAULT "highestScore",
      gameLengthType TEXT DEFAULT "variableLength"        
    )''';

  static const createTabletableRoundLabel =
      '''
    CREATE TABLE $tableRoundLabel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      game_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      color INTEGER NOT NULL,
      icon INTEGER NOT NULL,
      FOREIGN KEY (game_id) REFERENCES $tableGame (id) ON DELETE CASCADE
    )''';

  static const createTablePlayer =
      '''
    CREATE TABLE $tablePlayer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color INTEGER NOT NULL,
      photoPath TEXT
    )''';

  static const createTableLocation =
      '''
      CREATE TABLE $tableLocation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        photoPath TEXT
      )
    ''';

  static const createTablePlayerSet =
      '''

    CREATE TABLE $tablePlayerSet (
      id INTEGER PRIMARY KEY
    )
  ''';

  static const createTablePlayerSetPlayers =
      '''
    CREATE TABLE $tablePlayerSetPlayers (
      player_set_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      PRIMARY KEY (player_set_id, player_id),
      FOREIGN KEY (player_set_id) REFERENCES player_set(id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
    )
  ''';

  static const createTableMatchHistory =
      '''
      CREATE TABLE $tableMatchHistory (
        match_id INTEGER PRIMARY KEY,
        game_id INTEGER NOT NULL,
        player_set_id NOT NULL,
        match_date TEXT NOT NULL,        
        location_id INTEGER REFERENCES location(id) ON DELETE SET NULL,
       FOREIGN KEY (game_id) REFERENCES game (id),
       FOREIGN KEY (player_set_id) REFERENCES player_set (id)       
      )
    ''';

  static const createTableMatchStats =
      '''
        CREATE TABLE IF NOT EXISTS $tableMatchStats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (match_id) REFERENCES $tableMatchHistory (match_id) ON DELETE CASCADE          
        )
      ''';

  static const createTableMatchPlayerStats =
      '''
        CREATE TABLE IF NOT EXISTS $tableMatchPlayerStats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          player_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (match_id) REFERENCES $tableMatchHistory (match_id) ON DELETE CASCADE
        )
      ''';

  static const $createViewGamePlayersView =
      '''
        CREATE VIEW IF NOT EXISTS $viewGamePlayersView
        AS
        SELECT DISTINCT m1.match_id, m1.value as 'GAME_NAME', m2.value AS 'PLAYERS'
          FROM $tableMatchStats m1
          INNER JOIN $tableMatchStats m2 ON m1.match_id = m2.match_id
            WHERE m1.stat = 'NAME' 
              AND m2.stat = 'PLAYERS'
      ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);

    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    debugMsg("_initDb dbName $dbName version $dbVersion");

    /************************************************************
 TEMPORARY
 deleteDB();
 ************************************************************/

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    debugMsg("path is $path");

    Database db = await openDatabase(
      path,
      version: dbVersion,
      onOpen: _openDB,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      singleInstance: true,
    );

    await db.execute('PRAGMA foreign_keys = ON');

    return db;

    // return await openDatabase(
    //   path,
    //   version: dbVersion,
    //   onCreate: _createDB,
    //   onUpgrade: _onUpgrade,
    // );
  }

  //---------------------------------------------------------------------------

  Future _openDB(Database db) async {
    debugMsg("_openDB db $db");

    //    insertTestData(db);
  }

  //---------------------------------------------------------------------------
  Future _createDB(Database db, int version) async {
    debugMsg("_createDB db $db version $version");

    await db.execute(tableGame);
    await db.execute(tableRoundLabel);
    await db.execute(tablePlayer);
    await db.execute(tableLocation);
    await db.execute(tablePlayerSet);
    await db.execute(tablePlayerSetPlayers);
    await db.execute(tableMatchHistory);
    await db.execute(tableMatchStats);
    await db.execute(tableMatchPlayerStats);
    await db.execute(viewGamePlayersView);
  }

  //---------------------------------------------------------------------------

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugMsg("_onUpgrade oldVersion $oldVersion newVersion $newVersion");

    if (oldVersion < 2) {
      await db.execute(tableMatchStats);

      await db.execute(tableMatchPlayerStats);
    }

    if (oldVersion < 3) {
      await db.execute("DROP TABLE $tableMatchPlayerStats");
      await db.execute(tableMatchPlayerStats);
    }

    if (oldVersion < 4) {
      await db.execute(viewGamePlayersView);
    }

    if (oldVersion < 9) {
      await db.execute(tablePlayerSetPlayers);
    }

    if (oldVersion < 10) {
      await db.execute('''
        DROP TABLE $tableMatchHistory
    ''');
      await db.execute(tableMatchHistory);
    }

    if (oldVersion < 13) {
      await db.execute('''
        ALTER TABLE $tableGame 
          ADD COLUMN color INTEGER NOT NULL DEFAULT 0
    ''');
    }
    if (oldVersion < 14) {
      await db.execute('''
        ALTER TABLE $tableLocation 
          ADD COLUMN photoPath TEXT
    ''');
    }
  }

  //---------------------------------------------------------------------------

  Future deleteDB() async {
    //    String path = "/data/user/0/com.example.scores/databases/scores.db";
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    debugMsg("deleteDB");
    await deleteDatabase(path);
  }

  //---------------------------------------------------------------------------

  Future close() async {
    debugMsg("close");
    final db = await database;
    db.close();
  }

  //---------------------------------------------------------------------------

  Future<T?> safeDbCall<T>(
    Future<T> Function() action, {
    String context = "Database",
    BuildContext? uiContext, // Optional: if provided, it shows a SnackBar to you/Jane!
  }) async {
    try {
      return await action();
    } catch (e) {
      // 1. Log to the console for the dev (Paul)
      errorMsg("DB ERROR in $context: $e", box: true);

      // 2. If we have a UI context, show a red alert on the phone
      if (uiContext != null && uiContext.mounted) {
        showPopupError(uiContext, "Database error in $context");
      }

      return null;
    }
  }

  //---------------------------------------------------------------------------

  Future<void> insertTestData(Database db) async {
    await db.execute('''
INSERT INTO $tableGame (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (1, 'Simple', 'showNoFutureRounds', 'highestScore', 'variableLength');
      ''');

    await db.execute('''
INSERT INTO $tableGame (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (2, 'Rummy', 'showAllFutureRounds', 'lowestScore', 'variableLength');
      ''');

    await db.execute('''
INSERT INTO $tableGame (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (3, 'KD', 'showNoFutureRounds', 'highestScore', 'fixedLength');
      ''');

    await db.execute('''
INSERT INTO $tableLocation (id, name, description, color) 
VALUES (1, 'The Mill', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO $tableLocation (id, name, description, color) 
VALUES (2, 'Dice Box', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO $tableLocation (id, name, description, color) 
VALUES (3, 'At Home', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO $tablePlayer (id, name, color, photoPath) 
VALUES (1, 'John', 4280391411, NULL);
      ''');

    await db.execute('''
INSERT INTO $tablePlayer (id, name, color, photoPath) 
VALUES (2, 'Paul', 4278228616, NULL);
      ''');

    await db.execute('''
INSERT INTO $tablePlayer (id, name, color, photoPath) 
VALUES (3, 'Jane', 4288423856, NULL);
      ''');

    await db.execute('''
INSERT INTO $tablePlayer (id, name, color, photoPath) 
VALUES (4, 'Becca', 4288423856, NULL);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (1, 2, 'A', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (2, 2, '2', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (7, 2, '3', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (8, 2, '4', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (10, 3, 'Forest', NULL, 4283215696, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (11, 3, 'Desert', NULL, 4294961979, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (12, 3, 'Clay', NULL, 4288585374, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (13, 3, 'Gold', NULL, 4284513675, 58858);
      ''');

    await db.execute('''
INSERT INTO $tableRoundLabel (id, game_id, name, description, color, icon) 
VALUES (14, 3, 'Sea', NULL, 4280391411, 58858);
      ''');
  }
}
