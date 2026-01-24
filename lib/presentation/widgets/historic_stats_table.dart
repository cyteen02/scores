/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/12/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/player.dart';

  Widget historicStatsTable(
    Match match,
    List<String> winnersList,
    Map<int, int> minScores,
    Map<int, int> maxScores,
    Map<int, int> totalScores,
  ) {
    int numMatchesPlayed = winnersList.length;

    if (numMatchesPlayed == 0) {
      return Text("No historic data");
    }

    List<Widget> rows = [];

    rows.add(Center(child: Text("Stats from previous matches:")));

    Map<int, int> numWins = {};

    // Initialize all players with 0 wins
    for (Player player in match.players) {
      numWins[player.id] = 0;
    }

    // Count wins for each match
    for (String winners in winnersList) {
      int winnerId = int.tryParse(winners) ?? 0;
      numWins[winnerId] = numWins[winnerId]! + 1;
    }

    // put the data into a table
    List<DataRow> dataRows = [];

    List<DataColumn> dataColumns = [];
    dataColumns.add(DataColumn(label: Text("")));
    for (Player player in match.players) {
      dataColumns.add(DataColumn(label: Text(player.name)));
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