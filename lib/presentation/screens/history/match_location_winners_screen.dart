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
import 'package:scores/data/models/stats/location_winner_stat.dart';

import 'package:scores/data/repositories/repositories.dart';

//---------------------------------------------------------------------------

class MatchLocationWinnersScreen extends StatefulWidget {
  final int gameId;
  final String gameName;

  const MatchLocationWinnersScreen({
    super.key, 
    required this.gameId,
    required this.gameName
    });

  @override
  State<MatchLocationWinnersScreen> createState() =>
      MatchLocationWinnersScreenState();
}

//---------------------------------------------------------------------------

class MatchLocationWinnersScreenState
    extends State<MatchLocationWinnersScreen> {
  late Future<List<LocationWinnerStat>> _locationWinnersList;

  @override
  void initState() {
    super.initState();
    // Initialize your database call here so it only runs once when the screen opens

    _locationWinnersList = _loadLocationWinners(widget.gameId);
  }

  //---------------------------------------------------------------------------

  Future<List<LocationWinnerStat>> _loadLocationWinners(int gameId) async {
    return (historicDataRepository.getLocationWinners(gameId));
  }

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gameName} History'),
        centerTitle: true),
      body: FutureBuilder<List<LocationWinnerStat>>(
        future: _locationWinnersList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) return const CircularProgressIndicator();

          // State B: Something went wrong (our safeDbCall caught an error)
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading location and winner data'),
            );
          }

          final stats = snapshot.data!;

          return ListView.builder(
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return ListTile(
                title: Text('${stat.playerName} @ ${stat.locationName}'),
                trailing: Chip(
                  label: Text('${stat.winCount} wins'),
                  backgroundColor: Colors.amber[100],
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
