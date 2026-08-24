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

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/match_player_stats.dart';
import 'package:scores/data/models/player.dart';

import 'package:scores/business/services/historic_stats_service.dart';
import 'package:scores/business/services/match_stats_service.dart';

import 'package:scores/data/extensions/int_extensions.dart';

import 'package:scores/data/repositories/repositories.dart';

import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class StatsScreen extends StatefulWidget {
  final Match match;

  const StatsScreen({
    super.key,
    required this.match,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

//-------------------------------------------------------------------

class _StatsScreenState extends State<StatsScreen> {
  late Match match;

  @override
  void initState() {
    debugMsg("_EndMatchScreenState initState");
    super.initState();

    match = widget.match; // Copy to local state
  }

  //-------------------------------------------------------------------
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${match.name} stats'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final data = snapshot.data!;
          return _buildStatsScreen(data);
        },
      ),
    );
  }

  //-------------------------------------------------------------------

  Future<Map<String, dynamic>> _fetchStatsData() async {
    Map<String, dynamic> stats = {};

    debugMsg("_fetchStatsData");

    // Get stats for previous matches for this game & players
    
    List<MatchPlayerStats> matchPlayerStatsList =
        await matchPlayerStatsRepository.getByGameIdAndPlayerSet(
          match.game.id,
          match.playerSet.id ?? 0,
        );

    Map<String, dynamic> historicStats = calcMatchHistoricStats(
      matchPlayerStatsList,
    );

    stats.addAll(historicStats);

    return stats;
  }

  //-------------------------------------------------------------------

  //Future<Widget> endGameScreen(Match match) async {

  Widget _buildStatsScreen(Map<String, dynamic> data) {

    debugMsg("_buildStatsScreen");

    List<Widget> rows = [];

    rows.add(SizedBox(height: 30));

    rows.add(
      historicalStatsTable(
        data['numWins'],
        data['minScores'],
        data['maxScores'],
        data['totalScores'],
      ),
    );
    rows.add(SizedBox(height: 30));

    rows.add(bottomButtons(match));

    return Column(children: rows);
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
          child: Text('Close'),
          onPressed: () {
              if (mounted) {
                Navigator.pop(context);
              }
            }
        ),
      ],
    );
  }

 //-------------------------------------------------------------------
}
