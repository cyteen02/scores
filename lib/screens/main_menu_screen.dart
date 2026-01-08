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
import 'package:scores/database/database_helper.dart';
import 'package:scores/database/game_repository.dart';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/screens/list_games_screen.dart';
import 'package:scores/screens/list_players_screen.dart';
import 'package:scores/screens/match_stats_list_screen.dart';
import 'package:scores/screens/test_screen.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/models/match.dart';
import 'package:scores/models/game.dart';
import 'package:scores/screens/list_rounds_screen.dart';
import 'package:scores/services/match_storage.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

//--------------------------------------------------------------

class _MainMenuState extends State<MainMenu> with MyMixin {
  List<Game> games = [];

  Match game = Match();

  String gameName = "";
  bool isLoading = true;

  final dbHelper = DatabaseHelper.instance;
  final gameRespository = GameRepository();

  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();
    _loadGames();
  }

  //--------------------------------------------------------------

  Future<void> _loadGames() async {
    setState(() => isLoading = true);

    final loadedGames = await gameRespository.getAllGames();
    setState(() {
      games = loadedGames;
      debugMsg("_loadGames loaded ${games.length} gameTypes");
      isLoading = false;
    });
  }

  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick your game'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'match_stats') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchStatsListScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'match_stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('View Match Stats'),
                  ],
                ),
              ),
              // Add more menu items here as needed
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(child: gamesButtons()),
    );
  }

  //--------------------------------------------------------------

  Widget gamesButtons() {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
    );

    List<Widget> gameButtons = [];

    for (Game gameType in games) {
      gameButtons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              gameSelected(gameType.name);
            },
            child: Text(gameType.name),
          ),
        ),
      );
    }

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                manageGames();
              });
            },
            child: const Text('Manage Games'),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 48),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                managePlayers();
              });
            },
            child: const Text('Manage Players'),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 70),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              resetDatabase();
            },
            child: const Text('[ Reset database ]'),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              resetStorage();
            },
            child: const Text('[ Reset storage] '),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              testScreen();
            },
            child: const Text('[ Test screen] '),
          ),
        ),
      ),
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(children: gameButtons),
      ),
    );

    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(24.0),
    //     child: Column(
    //       children: <Widget>[
    //         SizedBox(
    //           width: double.infinity,
    //           child: ElevatedButton(
    //             style: style,
    //             onPressed: () {
    //               gameSelected("Rummy");
    //             },
    //             child: const Text('Rummy'),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.only(top: 24),
    //           child: SizedBox(
    //             width: double.infinity,
    //             child: ElevatedButton(
    //               style: style,
    //               onPressed: () {
    //                 gameName = "NEWGAME";
    //               },
    //               child: const Text('Define New Game'),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
  //--------------------------------------------------------------

  void gameSelected(String gameName) async {
    debugMsg("gameSelected gameName $gameName");

    game = Match.name(gameName);

    int lastNumPlayers = await loadLastNumPlayers(gameName);

    if (lastNumPlayers > 0) {
      loadGameData(gameName, lastNumPlayers);
    }

    Game? loadedGameType;

    loadedGameType ??= await gameRespository.getGameByName(gameName);

    if (loadedGameType != null) {
      game.game = loadedGameType;
    }

    debugMsg("game.gameType is ${game.game.toString()}");

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListRounds(match: game)),
      );
    }
  }

  //--------------------------------------------------------------

  Future<void> loadGameData(String gameName, int numPlayers) async {
    debugMsg(
      "_ListGamesState loadGameData gameName $gameName numPlayers $numPlayers",
    );

    final MatchStorage storage = MatchStorage();

    try {
      game = await storage.loadMatch(gameName, numPlayers);

      debugMsg("Game at this point is ${game.toString()}");
    } catch (e) {
      debugMsg("_ScoresState loadGameData ${e.toString()}", true);
    }
  }
  //--------------------------------------------------------------

  Future<int> loadLastNumPlayers(String gameName) async {
    debugMsg("_ListGamesState loadLastNumPlayers");

    final MatchStorage storage = MatchStorage();
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

  void managePlayers() async {
    debugMsg("managePlayers");

    // Create new person
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayersListScreen()),
    );
  }
  //--------------------------------------------------------------

  void manageGames() async {
    debugMsg("manageGame");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListGamesScreen()),
    );

    _loadGames();
  }

  //--------------------------------------------------------------

  void resetDatabase() async {
    if (await MyMixin.showDialogBox(
          context,
          "Really delete main database?",
          "Confirm",
          "Cancel",
        ) ==
        1) {
      dbHelper.deleteDB();
    }
  }

  //--------------------------------------------------------------

  Future<void> resetStorage() async {
    MatchStorage storage = MatchStorage();
    if (await MyMixin.showDialogBox(
          context,
          "Really reset local storage?",
          "Confirm",
          "Cancel",
        ) ==
        1) {
      storage.resetStorage();
    }

    if (mounted) {
      showPopupMessage(context, "local storage reset");
    }
  }

  //--------------------------------------------------------------

  Future<void> testScreen() async {
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TestScreen()),
      );
    }
  }
}
