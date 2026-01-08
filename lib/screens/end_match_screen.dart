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
import 'package:scores/database/match_stats_repository.dart';
import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/models/match.dart';
import 'package:scores/models/player.dart';
import 'package:scores/services/match_storage.dart';
import 'package:scores/utils/my_utils.dart';

class EndMatchScreen extends StatefulWidget {
  const EndMatchScreen({super.key, required this.match});
  final Match match;

  @override
  State<EndMatchScreen> createState() => _EndMatchScreenState();
}

//-------------------------------------------------------------------

class _EndMatchScreenState extends State<EndMatchScreen> {
  late Match match;

  @override
  void initState() {
    debugMsg("_ListRoundsState initState");
    super.initState();

    match = widget.match; // Copy to local state
  }

  //-------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${match.name} Endgame'), centerTitle: true),
      body: Container(child: endGameScreen(match)),
    );
  }

  //-------------------------------------------------------------------

  Widget endGameScreen(Match match) {
    List<Widget> rows = [];

    List<Player> winners = match.getWinningPlayers();

    if (winners.length == match.players.length) {
      rows.add(
        Text("A draw!", style: TextStyle(color: Colors.black, fontSize: 30)),
      );
    } else if (winners.length == 1) {
      rows.add(
        Text(
          "${winners[0].name} wins!",
          style: TextStyle(color: winners[0].color, fontSize: 30),
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
            style: TextStyle(color: winner.color, fontSize: 30),
          ),
        );
      }
    }

    rows.add(SizedBox(height: 30));
    rows.add(bottomButtons(match));

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
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  //-------------------------------------------------------------------

  void saveMatchStats(Match match) {

    debugMsg("saveMatchStats");
    MatchStatsRepository repository = MatchStatsRepository();
    repository.saveStats(match);
    
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
