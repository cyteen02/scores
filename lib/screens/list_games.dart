/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/18/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/game.dart';
import 'package:scores/screens/list_rounds.dart';
import 'package:scores/services/game_storage.dart';

class ListGames extends StatefulWidget {
  const ListGames({super.key});

  @override
  State<ListGames> createState() => _ListGamesState();
}

//--------------------------------------------------------------

class _ListGamesState extends State<ListGames> with MyUtils {
  Game game = Game.empty();

  String gameName = "";

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();
  }
  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick your game'), centerTitle: true),
      body: Container(child: gamesButtons()),
    );
  }

  //--------------------------------------------------------------

  Widget gamesButtons() {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: style,
                onPressed: () {
                  gameSelected("Rummy");
                },
                child: const Text('Rummy'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: style,
                  onPressed: () {
                    gameName = "NEWGAME";
                  },
                  child: const Text('Define New Game'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //--------------------------------------------------------------

  void gameSelected(String gameName) async {

    debugMsg("gameSelected gameName $gameName");

    game = Game(gameName);

    int lastNumPlayers = await loadLastNumPlayers(gameName) ;

    if ( lastNumPlayers > 0 ) {
      loadGameData(gameName, lastNumPlayers);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListRounds(game: game)),
    );
  }

  //--------------------------------------------------------------

  Future<void> loadGameData(String gameName, int numPlayers) async {
    debugMsg("_ListGamesState loadGameData gameName $gameName numPlayers $numPlayers");

    final GameStorage storage = GameStorage();

    try {
      game = await storage.loadGame(gameName, numPlayers);

      debugMsg("Game at this point is ${game.toString()}");
    } catch (e) {
      debugMsg("_ScoresState loadGameData ${e.toString()}", true);
    } 
  }
  //--------------------------------------------------------------

  Future<int> loadLastNumPlayers(String gameName ) async {
    debugMsg("_ListGamesState loadLastNumPlayers");

    final GameStorage storage = GameStorage();
    int lastNumPlayers = 0;

    try {
      lastNumPlayers = await storage.loadLastNumPlayers(gameName);
      debugMsg("lastNumPlayers $lastNumPlayers");
    } catch (e) {
      debugMsg("_ScoresState loadLastNumPlayers ${e.toString()}", true);
    }

    return lastNumPlayers;

  }
  //--------------------------------------------------------------

}
