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

// Match Stats List Screen
import 'package:flutter/material.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/data/models/match_stats.dart';
import 'package:scores/presentation/screens/match_player_stats_list_screen.dart';

class MatchStatsListScreen extends StatefulWidget {
  const MatchStatsListScreen({super.key});

  @override
  State<MatchStatsListScreen> createState() => _MatchStatsListScreenState();
}

class _MatchStatsListScreenState extends State<MatchStatsListScreen> {
  List<MatchStats> matchStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchStats();
  }

  //-------------------------------------------------------------------

  Future<void> _loadMatchStats() async {
    MatchStatsRepository repository = MatchStatsRepository();

    final List<MatchStats> newMatchStats = await repository.getAll();

    //    final List<Map<String, dynamic>> maps = await repository.getAll();
    setState(() {
      //    matchStats = maps.map((map) => MatchStats.fromMap(map)).toList();
      matchStats = List.from(newMatchStats);
      isLoading = false;
    });
  }

  //-------------------------------------------------------------------

  Map<int, List<MatchStats>> _groupByMatchId() {
    final Map<int, List<MatchStats>> grouped = {};
    for (var stat in matchStats) {
      if (!grouped.containsKey(stat.matchId)) {
        grouped[stat.matchId] = [];
      }
      grouped[stat.matchId]!.add(stat);
    }
    return grouped;
  }

  //-------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Stats')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final groupedStats = _groupByMatchId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Stats'),
        backgroundColor: Colors.blue,
      ),
      body: groupedStats.isEmpty
          ? const Center(
              child: Text(
                'No match stats found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedStats.length,
              itemBuilder: (context, index) {
                final matchId = groupedStats.keys.elementAt(index);
                final stats = groupedStats[matchId]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchPlayerStatsScreen(matchId: matchId),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Match ID: $matchId',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: stats.map((stat) {
                              return Chip(
                                label: Text('${stat.stat}: ${stat.value}'),
                                backgroundColor: Colors.blue.shade100,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  //-------------------------------------------------------------------
}
