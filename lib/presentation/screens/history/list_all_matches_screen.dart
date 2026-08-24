/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 07/05/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/business/services/historic_stats_service.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/data/models/match_history.dart';

import 'package:scores/data/repositories/repositories.dart';
import 'package:scores/presentation/screens/history/match_location_winners_screen.dart';
import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class ListAllMatchesScreen extends StatefulWidget {
  //  final MatchHistoryRepository matchHistoryRepository;

  const ListAllMatchesScreen({super.key});

  @override
  State<ListAllMatchesScreen> createState() => ListAllMatchesScreenState();
}

//---------------------------------------------------------------------------

class ListAllMatchesScreenState extends State<ListAllMatchesScreen> {
  late Future<(Map<int, int>, List<Game>)> _matchHistoryFuture;
  //late MatchHistoryRepository matchHistoryRepository;

  @override
  void initState() {
    super.initState();
    // Initialize your database call here so it only runs once when the screen opens
    _matchHistoryFuture = _loadGamesAndMatchCounts();

    debugMsg("ListAllMatchesScreenState initState");
  }

  //---------------------------------------------------------------------------

  Future<(Map<int, int>, List<Game>)> _loadGamesAndMatchCounts() async {
    final results = await Future.wait([
      matchHistoryRepository.getAll(),
      gameRepository.getAll(),
    ]);

    // Results comes back as a generic List, so we cast them safely
    final matchHistoryList = results[0] as List<MatchHistory>;
    final gameList = results[1] as List<Game>;

    final Map<int, int> matchCounts = calcMatchHistory(matchHistoryList);

    return (matchCounts, gameList);
  }

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match History'), centerTitle: true),
      body: FutureBuilder<(Map<int, int>, List<Game>)>(
        future: _matchHistoryFuture,
        builder: (context, snapshot) {
          // State A: Loading the database
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State B: Something went wrong (our safeDbCall caught an error)
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading match history'));
          }

          final (matchCounts, gameList) = snapshot.data!;

          final gameIds = matchCounts.keys.toList();

          // State C: No games played yet
          if (gameIds.isEmpty) {
            return const Center(
              child: Text('No games recorded yet. Time to play!'),
            );
          }

          // State D: The Data Ledger is open!
          return ListView.builder(
            itemCount: gameIds.length,
            itemBuilder: (context, index) {
              final gameId = gameIds[index];

              final game = gameList.firstWhere((game) => game.id == gameId);
              final gameName = game.name;
              final playCount = matchCounts[gameId] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    gameName,
                    style: TextStyle(color: game.color.toColor()),
                  ), // Later swapped for Game Name mapping
                  subtitle: Text("Played $playCount times"),
                  trailing: Icon(Icons.arrow_right),
                  onTap: () {
                    // Navigate to the mysterious placeholder screen!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchLocationWinnersScreen(
                          gameId: gameId,
                          gameName: gameName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//---------------------------------------------------------------------------
