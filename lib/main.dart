/*----------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*-------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';

//import 'package:flutter/widget_previews.dart';
import 'package:scores/screens/list_screen.dart';
import 'package:scores/services/game_storage.dart';
import 'package:scores/extensions/color_extensions.dart';

void main() {
  runApp(Scores());
}

class Scores extends StatefulWidget {
  const Scores({super.key});

  @override
  State<Scores> createState() => _ScoresState();
}

class _ScoresState extends State<Scores> with MyUtils {
  Game game = Game('Rummy');
  //    Game? game;
  bool isLoading = true;

  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();


    Color c = Colors.red;
debugMsg(c.toString(),true);


    loadGameData();

    // game.clear();

    // Player player = Player('Paul');
    // player.setColor(Colors.red);
    // game.addPlayer(player);

    // player = Player('Jane');
    // player.setColor(Colors.blue);
    // game.addPlayer(player);

    // Round round = Round(game.players);
    // round.setScoreByName('Paul', 10);
    // round.setScoreByName('Jane', 15);
    // game.addRound(round);

    // isLoading = false;

    // round = Round(game.players);
    // round.setScoreByName('Paul', 20);
    // game.addRound(round);

    // round = Round(game.players);
    // round.setScoreByName('Paul', 30);
    // game.addRound(round);
  }
  //-----------------------------------------------------------------

  Future<void> loadGameData() async {
    debugMsg("_ScoresState loadGameData");
    final GameStorage storage = GameStorage();


    try {
      game = await storage.loadGame();

      // game.clear();

      // game.name = "Rummy";

      // Player player = Player('Paul');
      // player.setColor(Colors.red);
      // game.addPlayer(player);

      // player = Player('Jane');
      // player.setColor(Colors.blue);
      // game.addPlayer(player);

      // Round round = Round(game.players);
      // round.setScoreByName('Paul', 10);
      // round.setScoreByName('Jane', 15);
      // game.addRound(round);

      debugMsg("Game at thsis point is ${game.toString()}");

    } catch (e) {
      debugMsg("_ScoresState loadGameData ${e.toString()}", true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("_ScoresState build");

    if (isLoading) {
      return CircularProgressIndicator();
    }

    //     return Text('Game: ${game?.name}');
    //   }
    // }
    //   @override
    //   Widget build(BuildContext context) {

    //     final GameStorage _storage = GameStorage();

    //     Game newGame = _storage.loadGame() as Game;
    //     debugPrint(newGame.toString());

    return MaterialApp(
      title: 'We are playing ${game.name}',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      //      home: home(game),
      home: ListScreen(game: game),
    );
  }

  //-----------------------------------------------------------------

  @override
  void dispose() {
    debugMsg("_ScoresState dispose");
    saveGameData();
    super.dispose();
  }

  //-----------------------------------------------------------------

  Future<void> saveGameData() async {
    debugMsg("_ScoresState saveGameData");

    final GameStorage storage = GameStorage();

    try {
      await storage.saveGame(game);
    } catch (e) {
      debugMsg(e.toString(), true);
    }
  }

  //-----------------------------------------------------------------
}
