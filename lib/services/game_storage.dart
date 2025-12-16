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
  static const String _key = 'game';

  //----------------------------------------------------------------

  Future<void> saveGame(Game game) async {
    debugMsg("GameStorage saveGame $game");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(game.toJson()));
  }

  //----------------------------------------------------------------

  Future<Game> loadGame() async {
    debugMsg("GameStorage loadGame");

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

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

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
