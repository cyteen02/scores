/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/06/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/database/match_player_stats_repository.dart';
import 'package:scores/models/match_player_stats.dart';

class MatchPlayerStatsScreen extends StatefulWidget {
  final int matchId;

  const MatchPlayerStatsScreen({super.key, required this.matchId});

  @override
  State<MatchPlayerStatsScreen> createState() => _MatchPlayerStatsScreenState();
}

class _MatchPlayerStatsScreenState extends State<MatchPlayerStatsScreen> {
  List<MatchPlayerStats> matchPlayerStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerStats();
  }

  Future<void> _loadPlayerStats() async {
    // TODO: Replace with your actual database query

    MatchPlayerStatsRepository repository = MatchPlayerStatsRepository();

    final List<MatchPlayerStats> newMatchPlayerStats = await repository.getAll();

      matchPlayerStats = List.from(newMatchPlayerStats);
      isLoading = false;

    // Example: final db = await database;
    // final List<Map<String, dynamic>> maps = await db.query(
    //   'match_player_stats',
    //   where: 'match_id = ?',
    //   whereArgs: [widget.matchId],
    // );
    // setState(() {
    //   playerStats = maps.map((map) => MatchPlayerStat.fromMap(map)).toList();
    //   isLoading = false;
    // });

    // // Mock data for demonstration
    // await Future.delayed(const Duration(milliseconds: 500));
    // setState(() {
    //   matchPlayerStats = [
    //     MatchPlayerStats(
    //         id: 1, matchId: widget.matchId, playerId: 1, stat: 'kills', value: '15'),
    //     MatchPlayerStats(
    //         id: 2, matchId: widget.matchId, playerId: 1, stat: 'deaths', value: '3'),
    //     MatchPlayerStats(
    //         id: 3, matchId: widget.matchId, playerId: 2, stat: 'kills', value: '12'),
    //     MatchPlayerStats(
    //         id: 4, matchId: widget.matchId, playerId: 2, stat: 'deaths', value: '5'),
    //   ];
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match ${widget.matchId} - Player Stats'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchPlayerStats.isEmpty
              ? const Center(
                  child: Text(
                    'No player stats found for this match',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade200,
                        ),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Match ID')),
                          DataColumn(label: Text('Player ID')),
                          DataColumn(label: Text('Stat')),
                          DataColumn(label: Text('Value')),
                        ],
                        rows: matchPlayerStats.map((stat) {
                          return DataRow(
                            cells: [
                              DataCell(Text(stat.id.toString())),
                              DataCell(Text(stat.matchId.toString())),
                              DataCell(Text(stat.playerId.toString())),
                              DataCell(Text(stat.stat)),
                              DataCell(Text(stat.value)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}