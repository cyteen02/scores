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
import 'package:scores/data/models/player_set.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/data/repositories/location_repository.dart';
import 'package:scores/data/repositories/match_history_repository.dart';
import 'package:scores/data/repositories/match_player_stats_repository.dart';
import 'package:scores/data/repositories/match_repository.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/data/repositories/player_set_repository.dart';
import 'package:scores/data/repositories/round_label_repository.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/presentation/screens/list_games_screen.dart';
import 'package:scores/presentation/screens/list_players_screen.dart';
import 'package:scores/presentation/screens/location_screen.dart';
import 'package:scores/presentation/screens/match_stats_list_screen.dart';
import 'package:scores/presentation/screens/test_screen.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/presentation/screens/list_rounds_screen.dart';
import 'package:scores/data/services/match_storage.dart';
import 'package:sqflite/sqflite.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

//--------------------------------------------------------------

class _MainMenuState extends State<MainMenu> with MyMixin {
  List<Game> games = [];
  Future<Map<String, dynamic>>? _dataFuture;

  //  Match game = Match();

  String gameName = "";
  bool isLoading = true;

  //  final dbHelper = DatabaseHelper.instance;
  final matchRepository = MatchRepository(
    PlayerSetRepository(),
    MatchHistoryRepository(),
    MatchStatsRepository(),
    MatchPlayerStatsRepository()
  );

  final gameRepository = GameRepository(RoundLabelRepository());
  final playerSetRepository = PlayerSetRepository();
  final matchStatsRepository = MatchStatsRepository();
  final matchHistoryRepository = MatchHistoryRepository();

  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();
    _dataFuture = _fetchGameData();
    // _loadGames();
  }

  //--------------------------------------------------------------

  void refreshData() {
    debugMsg("refreshData");
    setState(() {
      _dataFuture = _fetchGameData();
    });
  }
  //--------------------------------------------------------------

  Future<Map<String, dynamic>> _fetchGameData() async {
    final loadedGames = await gameRepository.getAll();
    debugMsg("_fetchGameData loaded ${loadedGames.length} games");
    return {'gamesList': loadedGames};
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            }

            final data = snapshot.data!;
            return _buildMainMenuScreen(data);
          },
        ),
      ),
    );
  }

  //-----------------------------------------------------------------

  Widget build2(BuildContext context) {
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
          : Text('gamesButtons()'),
    );
  }

  //--------------------------------------------------------------

  Widget _buildMainMenuScreen(Map<String, dynamic> data) {
    final games = data['gamesList'];

    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20,
      color: Colors.black,
      ),
      side: BorderSide(
      color: Colors.black,
      width: 2,
    ),
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
              manageGames();
              // setState(() {
              //   _loadGames();
              // });
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
        padding: const EdgeInsets.only(top: 48),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                manageLocations();
              });
            },
            child: const Text('Manage Locations'),
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

    Match match;
    Match? loadedMatch = await loadMatchData(gameName);

    if (loadedMatch == null) {
      // set up a new match with game definition from the database
      Game game = await gameRepository.getGameByName(gameName);

      match = Match(game: game, playerSet: PlayerSet());
    } else {
      match = loadedMatch;
    }
    debugMsg("match.game is ${match.game.toString()}");

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListRounds(
            match: match,
            matchRepository: matchRepository,
            gameRepository: gameRepository,            
            playerSetRepository: playerSetRepository,
            matchStatsRepository: matchStatsRepository
          ),
        ),
      );
    }
  }

  //--------------------------------------------------------------

  Future<Match?> loadMatchData(String gameName) async {
    debugMsg("_ListGamesState loadMatchData gameName $gameName");

    Match? loadedMatch;

    final MatchStorage storage = MatchStorage();

    // get num players last time this game was played
    int lastNumPlayers = 0;
    try {
      lastNumPlayers = await storage.loadLastNumPlayers(gameName);
      debugMsg("lastNumPlayers $lastNumPlayers");
    } catch (e) {
      debugMsg("_ScoresState loadLastNumPlayers ${e.toString()}", true);
    }

    if (lastNumPlayers > 0) {
      // Get the match last played with this many players
      try {
        loadedMatch = await storage.loadMatch(gameName, lastNumPlayers);
        debugMsg("Match at this point is ${loadedMatch.toString()}");
      } catch (e) {
        debugMsg("_ScoresState loadGameData ${e.toString()}", true);
      }
    }

    return loadedMatch;
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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayersListScreen()),
    );
  }
  //--------------------------------------------------------------

  void manageGames() async {
    debugMsg("manageGame");

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListGamesScreen(gameRepository: gameRepository),
      ),
    );

    refreshData();

    debugMsg("end of manageGame");
  }

  //--------------------------------------------------------------

  void manageLocations() async {
    debugMsg("manageLocations");

    final db = await openDatabase(dbName);
    final locationRepository = LocationRepository(db);

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(repository: locationRepository),
        ),
      );
    }

    refreshData();

    debugMsg("end of manageGame");
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
      final dbHelper = DatabaseHelper.instance;
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
