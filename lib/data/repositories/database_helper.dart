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

import 'package:path/path.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = "scores.db";
const int dbVersion = 11;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

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

    await db.execute('''
      CREATE TABLE game (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        showFutureRoundsType TEXT DEFAULT "showNoFutureRounds",        
        winCondition TEXT DEFAULT "highestScore",
        gameLengthType TEXT DEFAULT "variableLength"        
      )
    ''');

    await db.execute('''
      CREATE TABLE round_label (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES game (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE player (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE location (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
    CREATE TABLE player_set (
      id INTEGER PRIMARY KEY
    )
  ''');

    await db.execute('''
    CREATE TABLE player_set_players (
      player_set_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      PRIMARY KEY (player_set_id, player_id),
      FOREIGN KEY (player_set_id) REFERENCES player_set(id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
      CREATE TABLE round (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INT NOT NULL,
        desc TEXT,
        FOREIGN KEY (game_id) REFERENCES game (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE match_history (
        match_id INTEGER PRIMARY KEY,
        game_id INTEGER NOT NULL,
        player_set_id NOT NULL,
        match_date TEXT NOT NULL,        
        location_id INTEGER REFERENCES location(id) ON DELETE SET NULL,
       FOREIGN KEY (game_id) REFERENCES game (id),
       FOREIGN KEY (player_set_id) REFERENCES player_set (id)       
      )
    ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS match_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (match_id) REFERENCES match_history (match_id) ON DELETE CASCADE          
        )
      ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS match_player_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          player_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (match_id) REFERENCES match_history (match_id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
        CREATE VIEW IF NOT EXISTS game_players_view
        AS
        SELECT DISTINCT m1.match_id, m1.value as 'GAME_NAME', m2.value AS 'PLAYERS'
          FROM match_stats m1
          INNER JOIN match_stats m2 ON m1.match_id = m2.match_id
            WHERE m1.stat = 'NAME' 
              AND m2.stat = 'PLAYERS'
      ''');
  }

  //---------------------------------------------------------------------------

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugMsg("_onUpgrade oldVersion $oldVersion newVersion $newVersion");

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS match_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS match_player_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          player_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL,
          FOREIGN KEY (match_id) REFERENCES match_stats (match_id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute("DROP TABLE match_player_stats");

      await db.execute('''
        CREATE TABLE IF NOT EXISTS match_player_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          match_id INTEGER NOT NULL,
          player_id INTEGER NOT NULL,
          stat TEXT NOT NULL,
          value TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
      CREATE VIEW IF NOT EXISTS game_players_view
      AS
        SELECT DISTINCT m1.match_id, m1.value as 'GAME_NAME', m2.value AS 'PLAYERS'
          FROM match_stats m1
          INNER JOIN match_stats m2 ON m1.match_id = m2.match_id
            WHERE m1.stat = 'NAME' 
              AND m2.stat = 'PLAYERS'
      ''');
    }

    if (oldVersion < 9) {
      await db.execute('''
    CREATE TABLE  player_set(
      id INTEGER PRIMARY KEY
    )
  ''');

      await db.execute('''
    CREATE TABLE player_set_players (
      player_set_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      PRIMARY KEY (player_set_id, player_id),
      FOREIGN KEY (player_set_id) REFERENCES player_set(id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
  ''');
    }

    if (oldVersion < 11) {
      await db.execute('''
        DROP TABLE match_history
    ''');

      await db.execute('''
      CREATE TABLE match_history (
        match_id INTEGER PRIMARY KEY,
        game_id INTEGER NOT NULL,
        player_set_id INTEGER NOT NULL,
        match_date TEXT NOT NULL        
      )
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

  Future<void> insertTestData(Database db) async {
    await db.execute('''
INSERT INTO GAME (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (1, 'Simple', 'showNoFutureRounds', 'highestScore', 'variableLength');
      ''');

    await db.execute('''
INSERT INTO GAME (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (2, 'Rummy', 'showAllFutureRounds', 'lowestScore', 'variableLength');
      ''');

    await db.execute('''
INSERT INTO GAME (id, name, showFutureRoundsType, winCondition, gameLengthType) 
VALUES (3, 'KD', 'showNoFutureRounds', 'highestScore', 'fixedLength');
      ''');

    await db.execute('''
INSERT INTO LOCATION (id, name, description, color) 
VALUES (1, 'The Mill', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO LOCATION (id, name, description, color) 
VALUES (2, 'Dice Box', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO LOCATION (id, name, description, color) 
VALUES (3, 'At Home', NULL, 4280391411);
      ''');

    await db.execute('''
INSERT INTO PLAYER (id, name, color, photoPath) 
VALUES (1, 'John', 4280391411, NULL);
      ''');

    await db.execute('''
INSERT INTO PLAYER (id, name, color, photoPath) 
VALUES (2, 'Paul', 4278228616, NULL);
      ''');

    await db.execute('''
INSERT INTO PLAYER (id, name, color, photoPath) 
VALUES (3, 'Jane', 4288423856, NULL);
      ''');

    await db.execute('''
INSERT INTO PLAYER (id, name, color, photoPath) 
VALUES (4, 'Becca', 4288423856, NULL);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (1, 2, 'A', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (2, 2, '2', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (7, 2, '3', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (8, 2, '4', NULL, 4280391411, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (10, 3, 'Forest', NULL, 4283215696, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (11, 3, 'Desert', NULL, 4294961979, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (12, 3, 'Clay', NULL, 4288585374, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (13, 3, 'Gold', NULL, 4284513675, 58858);
      ''');

    await db.execute('''
INSERT INTO ROUND_LABEL (id, game_id, name, description, color, icon) 
VALUES (14, 3, 'Sea', NULL, 4280391411, 58858);
      ''');
  }
}
