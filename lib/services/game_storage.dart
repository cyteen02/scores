/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*----------------------------------------------------------------------------*/

import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

//------------------------------------------------------------------

class GameStorage with MyUtils {
  static const String lastGameNameKey = 'LAST-GAME-NAME';
  static const String lastNumPlayersKey = 'LAST-NUM_PLAYERS';

  //----------------------------------------------------------------

  Future<int> loadLastNumPlayers(String gameName) async {
    debugMsg("GameStorage loadLastNumPlayers");

    final prefs = await SharedPreferences.getInstance();

    String lastNumPlayersKey = "LAST-$gameName-NUM-PLAYERS";

    int lastNumPlayers = prefs.getInt(lastNumPlayersKey) ?? 0;

    return lastNumPlayers;
  }


  //----------------------------------------------------------------

  String getStorageKey(String gameName, int numPlayers) {
    return "SCORE-$gameName-$numPlayers";
  }
  //----------------------------------------------------------------

  Future<void> saveGame(Game game) async {
    debugMsg("GameStorage saveGame $game");

    final prefs = await SharedPreferences.getInstance();

    String lastNumPlayersKey = "LAST-${game.name}-NUM-PLAYERS";
    await prefs.setInt(lastNumPlayersKey, game.numPlayers());

    String key = getStorageKey(game.name, game.numPlayers());
    await prefs.setString(key, jsonEncode(game.toJson()));
  }

  //----------------------------------------------------------------

  Future<Game> loadGame(String gameName, int numPlayers) async {
    debugMsg("GameStorage loadGame gameName $gameName numPlayers $numPlayers");

    final key = getStorageKey(gameName, numPlayers);

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    debugMsg("GameStorage jsonString $jsonString");

    Game game;
    if (jsonString == null) {
      game = Game.empty();
    } else {
      final jsonMap = jsonDecode(jsonString);
      game = Game.fromJson(jsonMap);
    }
    debugMsg("loaded game $game");
    return game;
  }

  //----------------------------------------------------------------

  // Future<void> clearTasks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_key);
  // }
}
