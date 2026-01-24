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
import 'package:flutter/services.dart';
import 'package:scores/business/services/match_stats_service.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/round_label.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:scores/data/models/match.dart';
//import 'package:scores/models/game.dart';
import 'package:scores/data/models/player.dart';
//import 'package:scores/models/round.dart';

class NextRoundScreen extends StatefulWidget {
  final Match match;
  final RoundLabel nextRoundLabel;

  const NextRoundScreen({
    super.key,
    required this.match,
    required this.nextRoundLabel,
  });

  @override
  State<NextRoundScreen> createState() => _NextRoundScreenState();
}

//---------------------------------------------------------------

class _NextRoundScreenState extends State<NextRoundScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WakelockPlus.enable(); // Keep screen on

    // Change screen to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  //---------------------------------------------------------------

  @override
  void dispose() {
    WakelockPlus.disable(); // Allow screen to sleep again

    // allow any orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  //---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            nextRoundCard(),
            SizedBox(height: 24),
            playerScoresRow(),

          ],
        ),
      ),
    );
  }
  //---------------------------------------------------------------

  Widget playerScoresRow() {
    StringBuffer playerScores = StringBuffer();

    for (Player p in widget.match.players) {
      playerScores.write(
        "${p.name}: ${totalScoreForPlayerId(widget.match, p.id)}  ",
      );
    }

    return Card(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [Text(playerScores.toString())],
            ),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------------------
  Card nextRoundCard() {
    // Next Round
    return Card(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Round',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.nextRoundLabel.name,
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: widget.nextRoundLabel.color.toColor() ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------------------
}
