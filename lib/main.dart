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

/* TERMINOLOGY

a game is a set of rules and rounds 
a player is a person who plays games
a playerSet is a number of people who have got together to play
a match a game played by a playerSet
*/


import 'package:flutter/material.dart';
import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

// import 'package:scores/models/game.dart';
// import 'package:scores/models/player.dart';
// import 'package:scores/models/round.dart';
import 'package:scores/presentation/screens/main_menu_screen.dart';
// import 'package:scores/models/player.dart';
// import 'package:scores/models/round.dart';

//import 'package:flutter/widget_previews.dart';
// import 'package:scores/screens/list_rounds.dart';
// import 'package:scores/services/game_storage.dart';
//import 'package:scores/extensions/color_extensions.dart';

void main() {
  runApp(Scores());
}

class Scores extends StatefulWidget {
  const Scores({super.key});

  @override
  State<Scores> createState() => _ScoresState();
}

class _ScoresState extends State<Scores> with MyMixin {
  // Game game = Game('Rummy');
  // //    Game? game;
  // bool isLoading = true;

  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();

    // Color c = Colors.red;
    // debugMsg(c.toString(), true);

    // loadGameData();

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

  // Future<void> loadGameData() async {
  //   debugMsg("_ScoresState loadGameData");
  //   final GameStorage storage = GameStorage();

  //   try {
  //     game = await storage.loadGame();

  //     // game.clear();

  //     // game.name = "Rummy";

  //     // Player player1 = Player('Paul');
  //     // player1.setColor(Colors.red);
  //     // game.addPlayer(player1);

  //     // Player player2 = Player('Jane');
  //     // player2.setColor(Colors.blue);
  //     // game.addPlayer(player2);

  //     // Round round = Round(game.players);
  //     // round.setScore(player1, 10);
  //     // round.setScore(player2, 15);
  //     // game.addRound(round);

  //     debugMsg("Game at this point is ${game.toString()}");
  //   } catch (e) {
  //     debugMsg("_ScoresState loadGameData ${e.toString()}", true);
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("_ScoresState build");

    // if (isLoading) {
    //   return CircularProgressIndicator();
    // }

    //     return Text('Game: ${game?.name}');
    //   }
    // }
    //   @override
    //   Widget build(BuildContext context) {

    //     final GameStorage _storage = GameStorage();

    //     Game newGame = _storage.loadGame() as Game;
    //     debugPrint(newGame.toString());

    return MaterialApp(
//      title: 'We are playing ${game.name}',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),

      //      home: home(game),
//      home: ListRounds(game: game),
      home: MainMenu()
    );
  }

  //-----------------------------------------------------------------

  @override
  void dispose() {
    debugMsg("_ScoresState dispose");
    // saveGameData();
    super.dispose();
  }

  //-----------------------------------------------------------------
}
