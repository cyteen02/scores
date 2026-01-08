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
const int dbVersion = 3;

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
    //    String path = "/data/user/0/com.example.scores/databases/scores.db";

    debugMsg("path is $path");

    Database db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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

  Future _createDB(Database db, int version) async {
    debugMsg("_createDB db $db version $version");

    await db.execute('''
      CREATE TABLE game (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        roundList TEXT NOT NULL,
        showFutureRoundsType TEXT DEFAULT "showNoFutureRounds",        
        winCondition TEXT DEFAULT "highestScore"
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
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE match (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id TEXT NOT NULL,
        match_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE round (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        score INT
      )
    ''');

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
  }

  Future deleteDB() async {
    String path = "/data/user/0/com.example.scores/databases/scores.db";
    await deleteDatabase(path);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
