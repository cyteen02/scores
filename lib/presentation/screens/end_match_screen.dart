/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/23/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/business/services/historic_stats_service.dart';
import 'package:scores/business/services/match_stats_service.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/match_player_stats.dart';

import 'package:scores/data/repositories/match_player_stats_repository.dart';
import 'package:scores/data/repositories/match_repository.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/data/models/match.dart';

import 'package:scores/data/models/player.dart';
import 'package:scores/data/services/match_storage.dart';
import 'package:scores/utils/my_utils.dart';

class EndMatchScreen extends StatefulWidget {
  final Match match;
  final MatchRepository matchRepository;
  final MatchStatsRepository matchStatsRepository;

  const EndMatchScreen({
    super.key,
    required this.match,
    required this.matchRepository,
    required this.matchStatsRepository,
  });

  @override
  State<EndMatchScreen> createState() => _EndMatchScreenState();
}

//-------------------------------------------------------------------

class _EndMatchScreenState extends State<EndMatchScreen> {
  late Match match;
  late MatchRepository matchRepository;
  late MatchStatsRepository matchStatsRepository;

  @override
  void initState() {
    debugMsg("_EndMatchScreenState initState");
    super.initState();

    match = widget.match; // Copy to local state
    matchRepository = widget.matchRepository;
    matchStatsRepository = widget.matchStatsRepository;
  }

  //-------------------------------------------------------------------

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('${match.name} Endgame'), centerTitle: true),
  //     body: Container(child: endGameScreen(match)),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${match.name} Endgame'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchEndMatchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final data = snapshot.data!;
          return _buildEndGameScreen(data);
        },
      ),
    );
  }

  //-------------------------------------------------------------------

  Future<Map<String, dynamic>> _fetchEndMatchData() async {
    Map<String, dynamic> stats = {};

    debugMsg("_fetchEndMatchData");

    debugMsg("get stats for current match");
    // Get stats for the current match
    stats['match_max_scores'] = getMaxScoresForPlayers(match);
    stats['match_min_scores'] = getMaxScoresForPlayers(match);
    stats['match_zero_scores'] = getNumMatchingScoresForPlayers(match, 0);

    debugMsg("get stats for previous matches");
    // Get stats for previous matches for this game & players
    //    MatchStatsRepository matchStatsRepository = MatchStatsRepository();

    List<String> winnersList = await matchStatsRepository
        .getWinnersByGamePlayers(match.game.name, match.playersCsv);
    stats['winners'] = winnersList;

    MatchPlayerStatsRepository matchPlayerStatsRepository =
        MatchPlayerStatsRepository();

    // Map<int, String> scoreStats = await matchPlayerStatsRepository
    //     .getStatByGameIdAndPlayerSet(
    //       match.game.id ?? 0,
    //       match.playerSet.id ?? 0,
    //       "SCORE",
    //     );

    // Map<int, int> playerScores = {
    //   for (var entry in scoreStats.entries) entry.key: int.parse(entry.value),
    // };

    List<MatchPlayerStats> matchPlayerStatsList =
        await matchPlayerStatsRepository.getByGameIdAndPlayerSet(
          match.game.id ?? 0,
          match.playerSet.id ?? 0,
        );

    Map<String, dynamic> historicStats = calcMatchHistoricStats(
      matchPlayerStatsList,
    );

    stats.addAll(historicStats);

    return stats;

    // statsList.clear();
    //     for ( Player player in match.players ){
    //       statsList[player.id??0] = maxScoreForPlayerId(match, player.id??0);
    //     };
    //     stats['match_max_scores'] = statsList;

    //     ;

    //     // return {
    //     //   'winners': winnersList,
    //     //   'minScores': minScores,
    //     //   'maxScores': maxScores,
    //     //   'totalScores': totalScores,
    //     // };

    //           ("Max round", (int id) => maxScoreForPlayerId(match, id)),
    //           ("Ave score", (int id) => avgScoreForPlayerId(match, id)),
    //           ("Num zeros", (int id) => numRoundsMatchingScore(match, id, 0)),

    //     MatchStatsRepository matchStatsRepository = MatchStatsRepository();

    //     Map<String, dynamic> historicStats = {};

    //   allStats.addAll(historicStats);

    //     return allStats;
  }

  //-------------------------------------------------------------------

  //Future<Widget> endGameScreen(Match match) async {

  Widget _buildEndGameScreen(Map<String, dynamic> data) {
    // Build your UI synchronously with the fetched data
    //   return Column(
    //     children: [
    //       _buildHistoricalStatsTable(data['stats']),
    //       _buildWinnersSection(data['winners']),
    //     ],
    //   );
    // }

    debugMsg("_buildEndGameScreen");

    List<Widget> rows = [];

    rows.add(SizedBox(height: 30));

    if (match.numPlayers() > 1) {
      rows.addAll(winnersRow());
      rows.add(SizedBox(height: 30));
    }
    rows.add(matchStatsTable());
    rows.add(bottomButtons(match));
    rows.add(SizedBox(height: 50));

    rows.add(
      historicalStatsTable(
        data['numWins'],
        data['minScores'],
        data['maxScores'],
        data['totalScores'],
      ),
    );
    rows.add(SizedBox(height: 30));

    return Column(children: rows);
  }

  //-------------------------------------------------------------------

  List<Widget> winnersRow() {
    List<Widget> rows = [];

    List<Player> winners = getWinningPlayers(match);

    if (winners.length == match.numPlayers()) {
      rows.add(
        Text("A draw!", style: TextStyle(color: Colors.black, fontSize: 30)),
      );
    } else if (winners.length == 1) {
      rows.add(
        Text(
          "${winners[0].name} wins!",
          style: TextStyle(color: winners[0].color.toColor(), fontSize: 30),
        ),
      );
    } else {
      rows.add(
        Text(
          "The winners are",
          style: TextStyle(color: Colors.black, fontSize: 30),
        ),
      );

      for (Player winner in winners) {
        rows.add(
          Text(
            winner.name,
            style: TextStyle(color: winner.color.toColor(), fontSize: 30),
          ),
        );
      }
    }

    return rows;
  }

  //-------------------------------------------------------------------

  Widget matchStatsTable() {
    debugMsg("building matchStatsTable");

    List<DataColumn> dataColumns = [];
    dataColumns.add(DataColumn(label: Text("")));
    for (Player player in match.playerSet.players) {
      dataColumns.add(
        DataColumn(
          label: Text(
            player.name,
            style: TextStyle(color: player.color.toColor()),
          ),
        ),
      );
    }

    List<Widget> rows = [];

    rows.add(Center(child: Text("Stats from this match:")));

    List<DataRow> dataRows =
        [
          ("Max round", (int id) => maxScoreForPlayerId(match, id)),
          ("Ave score", (int id) => avgScoreForPlayerId(match, id)),
          ("Num zeros", (int id) => numRoundsMatchingScore(match, id, 0)),
        ].map((rowData) {
          return DataRow(
            cells: [
              DataCell(Text(rowData.$1)), // label
              ...match.playerSet.players.map(
                (player) => DataCell(Text(rowData.$2(player.id).toString())),
              ),
            ],
          );
        }).toList();

    rows.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: dataColumns,
              rows: dataRows,
            ),
          ),
        ),
      ),
    );

    return Column(children: rows);
  }

  //-------------------------------------------------------------------

  //   Future<Map<String, dynamic>> _fetchEndMatchData() async {

  //     MatchStatsRepository matchStatsRepository = MatchStatsRepository();

  // Map<String, dynamic> matchStats = matchStatsRepository.

  //     // Fetch all your async data here

  //     // Get winner history
  //     List<String> winnersList = await matchStatsRepository
  //         .getWinnersByGamePlayers(match.game.name, match.playersCsv);

  //     Map<String, dynamic> matchStats = {'winners':winnersList};

  //     // get individual player stats
  //     MatchPlayerStatsRepository matchPlayerStatsRepository =
  //         MatchPlayerStatsRepository();

  //     Map<int, int> maxScores = {};
  //     Map<int, int> totalScores = {};
  //     Map<int, int> minScores = {};

  //     int id = 0;
  //     List<String> scores = [];
  //     List<String> playerScores = [];

  // //    Map<String, dynamic> matchStats = {};

  //     for (Player player in match.players) {
  //       id = player.id ?? 0;

  //       scores = scores + await matchPlayerStatsRepository
  //           .getByGameAndPlayers(
  //             match.game.name,
  //             match.playersCsv,
  //             id,
  //             "SCORE",
  //           );

  //       final stats = calcGameHistoricStats(id, scores);
  //       stats.addAll({'winners':winnersList});
  //     }
  //       return stats;
  //   for (String score in scores) {
  //     var s = int.parse(score);

  //     if ((maxScores[id] ?? 0) < s) {
  //       maxScores[id] = s;
  //     }

  //     if ((minScores[id] ?? 9999) > s) {
  //       minScores[id] = s;
  //     }

  //     totalScores[id] = (totalScores[id] ?? 0) + s;
  //   }
  // }

  // return {
  //   'winners': winnersList,
  //   'minScores': minScores,
  //   'maxScores': maxScores,
  //   'totalScores': totalScores,
  // };
  // }
  //-------------------------------------------------------------------

  Widget historicalStatsTable(
    Map<int, int> numWins,
    Map<int, int> minScores,
    Map<int, int> maxScores,
    Map<int, int> totalScores,
  ) {
    if (minScores.isEmpty) {
      return Text("No historic data");
    }

    List<Widget> rows = [];

    rows.add(Center(child: Text("Stats from previous matches:")));

    //    Map<int, int> numWins = {};

    // // Initialize all players with 0 wins
    // for (Player player in match.playerSet.players) {
    //   numWins[player.id] = 0;
    // }

    // // Count wins for each match
    // for (String winners in winnersList) {
    //   int winnerId = int.tryParse(winners) ?? 0;
    //   numWins[winnerId] = numWins[winnerId]! + 1;
    // }

    // put the data into a table
    List<DataRow> dataRows = [];

    List<DataColumn> dataColumns = [];
    dataColumns.add(DataColumn(label: Text("")));
    for (Player player in match.players) {
      dataColumns.add(
        DataColumn(
          label: Text(
            player.name,
            style: TextStyle(color: player.color.toColor()),
          ),
        ),
      );
    }

    List<DataCell> dataCellList = [];
    dataCellList.add(DataCell(Text("Num wins")));
    for (Player player in match.players) {
      dataCellList.add(DataCell(Text(numWins[player.id].toString())));
    }

    dataRows.add(DataRow(cells: dataCellList));

    List<DataCell> dataCellList2 = [];
    dataCellList2.add(DataCell(Text("Highest score")));
    for (Player player in match.players) {
      dataCellList2.add(DataCell(Text(maxScores[player.id].toString())));
    }
    dataRows.add(DataRow(cells: dataCellList2));

    // =
    //     [
    //       ("Max round", (int id) => match.maxScoreForPlayerId(id)),
    //       ("Ave score", (int id) => match.avgScoreForPlayerId(id)),
    //       ("Num zeros", (int id) => match.numRoundsMatchingScore(id, 0)),
    //     ].map((rowData) {
    //       return DataRow(
    //         cells: [
    //           DataCell(Text(rowData.$1)), // label
    //           ...match.players.map(
    //             (player) =>
    //                 DataCell(Text(rowData.$2(player.id ?? 0).toString())),
    //           ),
    //         ],
    //       );
    //     }).toList();

    rows.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: dataColumns,
              rows: dataRows,
            ),
          ),
        ),
      ),
    );

    return Column(children: rows);
  }

  //-------------------------------------------------------------------

  Widget bottomButtons(Match match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: Text('Discard'),
          onPressed: () async {
            if (await MyMixin.showDialogBox(
                  context,
                  "Discard stats?",
                  "Confirm",
                  "Cancel",
                ) ==
                1) {
              discardMatch(match);
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
        SizedBox(width: 8),
        ElevatedButton(
          child: Text('Save Stats'),
          onPressed: () {
            saveMatchStats(match);
            showPopupMessage(context, "Stats saved");
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  //-------------------------------------------------------------------

  Future<void> saveMatchStats(Match match) async {
    debugMsg("saveMatchStats");

    await matchRepository.saveMatch(match);

    // now clear everything ready for next time
    discardMatch(match);
  }

  //-------------------------------------------------------------------

  void discardMatch(Match match) {
    debugMsg("discardMatchStats");
    match.clear();

    // save the cleared match, otherwise it just reloads
    // by creating a new empty match and overwriting the old one
    final MatchStorage storage = MatchStorage();
    storage.saveMatch(match);
  }

  //-------------------------------------------------------------------
}
