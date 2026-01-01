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

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/models/match.dart';


//------------------------------------------------------------------

class MatchStorage with MyMixin {
  static const String lastGameNameKey = 'LAST-GAME-NAME';
  static const String lastNumPlayersKey = 'LAST-NUM_PLAYERS';

  //----------------------------------------------------------------

  Future<int> loadLastNumPlayers(String gameName) async {
    debugMsg("MatchStorage loadLastNumPlayers");

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

  Future<void> saveMatch(Match match) async {
    debugMsg("MatchStorage saveMatch $match");

    final prefs = await SharedPreferences.getInstance();

    String lastNumPlayersKey = "LAST-${match.name}-NUM-PLAYERS";
    await prefs.setInt(lastNumPlayersKey, match.numPlayers());

    String matchKey = getStorageKey(match.name, match.numPlayers());
    await prefs.setString(matchKey, jsonEncode(match.toJson()));
  }

  //----------------------------------------------------------------

  Future<Match> loadMatch(String matchName, int numPlayers) async {
    debugMsg("MatchStorage loadGame match $matchName numPlayers $numPlayers");

    final key = getStorageKey(matchName, numPlayers);

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    debugMsg("MatchStorage jsonString $jsonString");

    Match match;
    if (jsonString == null) {
      match = Match.name(matchName);
    } else {
      final jsonMap = jsonDecode(jsonString);
      match = Match.fromJson(jsonMap);
    }
    debugMsg("loaded match $match");
    return match;
  }

  //----------------------------------------------------------------

  // Future<void> clearTasks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_key);
  // }

  Future<void> resetStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
