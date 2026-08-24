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
import 'package:scores/constants/app_assets.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/player_set.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/repositories/repositories.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';

import 'package:scores/presentation/screens/about_screen.dart';
import 'package:scores/presentation/screens/manage/game_list_screen.dart';
import 'package:scores/presentation/screens/manage/location_list_screen.dart';
import 'package:scores/presentation/screens/manage/player_list_screen.dart';
import 'package:scores/presentation/screens/match_stats_list_screen.dart';
import 'package:scores/presentation/screens/menu/history_menu_screen.dart';
import 'package:scores/presentation/screens/test_screen.dart';
import 'package:scores/presentation/screens/list_rounds_screen.dart';

import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/data/services/match_storage.dart';

class GamesMenu extends StatefulWidget {
  const GamesMenu({super.key});

  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

//--------------------------------------------------------------

class _GamesMenuState extends State<GamesMenu> with MyMixin {
  List<Game> games = [];
  Future<Map<String, dynamic>>? _dataFuture;

  String gameName = "";
  bool isLoading = true;

  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_GamesMenu initState");
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
        actions: [buildSubMenu()],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.backgroundImage),
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

  Widget buildSubMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'manage_games':
            manageGames();
            break;
          case 'manage_players':
            managePlayers();
            break;
          case 'manage_locations':
            manageLocations();
            break;
          case 'about':
            showAboutScreen();
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'manage_games',
          child: const Text('Manage games'),
        ),

        PopupMenuItem<String>(
          value: 'manage_players',
          child: const Text('Manage players'),
        ),

        PopupMenuItem<String>(
          value: 'manage_locations',
          child: const Text('Manage locations'),
        ),

        PopupMenuItem<String>(
          value: 'about',
          child: const Text('About'),
        ), // Add more menu items here as needed
      ],
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
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      side: BorderSide(color: Colors.black, width: 2),
    );

    List<Widget> gameButtons = [];

    for (Game game in games) {
      gameButtons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              gameSelected(game.id, game.name);
            },
            child: Text(
              game.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: game.color.toColor(),
              ),
            ),
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
              historyMenuScreen();
            },
            child: const Text('History'),
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
    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(24.0),
    //     child: Column(children: gameButtons),
    //   ),
    // );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(children: gameButtons),
      ),
    );
  }
  //--------------------------------------------------------------

  void gameSelected(int gameId, String gameName) async {
    debugMsg("gameSelected gameName $gameName");

    // Load full game from database

    Game game = await gameRepository.getGameByName(gameName);

    Match match;
    Match? loadedMatch = await loadMatchDFromSharedPreferences(gameId);

    if (loadedMatch == null) {
      match = Match(game: game, playerSet: PlayerSet());

      debugMsg("match.game.id is ${game.id}");
    } else {
      loadedMatch.game = game;
      match = loadedMatch;
      debugMsg("used loadedMatch match.game.id is ${match.game.id}");
    }

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListRounds(match: match)),
      );
    }
  }

  //--------------------------------------------------------------

  Future<Match?> loadMatchDFromSharedPreferences(int gameId) async {
    debugMsg("_ListGamesState loadMatchData gameName $gameId");

    Match? loadedMatch;

    final MatchStorage storage = MatchStorage();

    // get num players last time this game was played
    int lastNumPlayers = 0;
    try {
      lastNumPlayers = await storage.loadLastNumPlayers(gameId);
      debugMsg("lastNumPlayers $lastNumPlayers");
    } catch (e) {
      debugMsg("_ScoresState loadLastNumPlayers ${e.toString()}", box: true);
    }

    if (lastNumPlayers > 0) {
      // Get the match last played with this many players
      try {
        loadedMatch = await storage.loadMatch(gameId, lastNumPlayers);
        debugMsg("Match at this point is ${loadedMatch.toString()}");
      } catch (e) {
        debugMsg("_ScoresState loadGameData ${e.toString()}", box: true);
      }
    }

    return loadedMatch;
  }

  //--------------------------------------------------------------

  Future<int> loadLastNumPlayers(int gameId) async {
    debugMsg("_ListGamesState loadLastNumPlayers");

    final MatchStorage storage = MatchStorage();
    int lastNumPlayers = 0;

    try {
      lastNumPlayers = await storage.loadLastNumPlayers(gameId);
      debugMsg("lastNumPlayers $lastNumPlayers");
    } catch (e) {
      debugMsg("_ScoresState loadLastNumPlayers ${e.toString()}", box: true);
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
      MaterialPageRoute(builder: (context) => GamesListScreen()),
    );

    refreshData();

    debugMsg("end of manageGame");
  }

  //--------------------------------------------------------------

  void manageLocations() async {
    debugMsg("manageLocations");

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationsListScreen()),
      );
    }

    refreshData();

    debugMsg("end of manageGame");
  }

  //---------------------------------------------------------------------------

  Future<void> historyMenuScreen() async {
    debugMsg("historyMenuScreen");
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryMenu()),
      );
    }
    debugMsg("end of historyMenuScreen");
  }

  //--------------------------------------------------------------

  void showAboutScreen() async {
    debugMsg("showAboutScreen");
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutScreen()),
      );
    }
    debugMsg("end of showAboutScreen");
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

  //---------------------------------------------------------------------------
}
