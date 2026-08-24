/*----------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*-------------------------------------------------------------------------*/

/* TERMINOLOGY

a game is a set of rules and rounds 
a player is a person who plays games
a playerSet is a number of people who have got together to play
a match a game played by a playerSet
*/


import 'package:flutter/material.dart';
import 'package:scores/data/services/storage_migration_service.dart';
import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/presentation/screens/menu/games_menu_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Run the migration audit before the UI even draws
  await StorageMigrationService().checkAndMigrate();

  runApp(Scores());
}

class Scores extends StatefulWidget {
  const Scores({super.key});

  @override
  State<Scores> createState() => _ScoresAppState();
}

class _ScoresAppState extends State<Scores> with MyMixin {
  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("ScoresAppState initState");
    super.initState();
  }

  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("ScoresAppState build");

    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GamesMenu()
    );
  }

  //-----------------------------------------------------------------

  @override
  void dispose() {
    debugMsg("ScoresAppState dispose");
    // saveGameData();
    super.dispose();
  }

  //-----------------------------------------------------------------
}
