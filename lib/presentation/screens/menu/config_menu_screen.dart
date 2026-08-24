/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/18/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/constants/app_assets.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';

import 'package:scores/presentation/screens/manage/game_list_screen.dart';
import 'package:scores/presentation/screens/manage/location_list_screen.dart';
import 'package:scores/presentation/screens/manage/player_list_screen.dart';

import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/game.dart';

class ConfigMenu extends StatefulWidget {
  const ConfigMenu({super.key});

  @override
  State<ConfigMenu> createState() => _ConfigMenuState();
}

//--------------------------------------------------------------

class _ConfigMenuState extends State<ConfigMenu> with MyMixin {
  List<Game> games = [];
  Future<Map<String, dynamic>>? _dataFuture;

  //  Match game = Match();

  String gameName = "";
  bool isLoading = true;


  //-----------------------------------------------------------------

  @override
  void initState() {
    debugMsg("_ScoresState initState");
    super.initState();
  }

  //--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Config'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            }

            final data = snapshot.data!;
            return _buildConfigMenuScreen(data);
          },
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------

  Widget _buildConfigMenuScreen(Map<String, dynamic> data) {

    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      side: BorderSide(color: Colors.black, width: 2),
    );

    List<Widget> gameButtons = [];

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                manageGames();
              });
            },
            child: const Text('Manage Games'),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 48),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                managePlayers();
              });
            },
            child: const Text('Manage Players'),
          ),
        ),
      ),
    );

    gameButtons.add(
      Padding(
        padding: const EdgeInsets.only(top: 48),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () {
              setState(() {
                manageLocations();
              });
            },
            child: const Text('Manage Locations'),
          ),
        ),
      ),
    );

    // return Center(
    //   child: Padding(
    //     padding: const EdgeInsets.all(24.0),
    //     child: Column(children: gameButtons),
    //   ),
    // );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(children: gameButtons),
      ),
    );


  }

  //--------------------------------------------------------------

  void managePlayers() async {
    debugMsg("managePlayers");

    // Create new person
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayersListScreen()),
    );

    debugMsg("end of managePlayers");

  }
  //--------------------------------------------------------------

  void manageGames() async {
    debugMsg("manageGame");

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamesListScreen(),
      ),
    );

    debugMsg("end of manageGame");
  }

  //--------------------------------------------------------------

  void manageLocations() async {
    debugMsg("manageLocations");

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationsListScreen()),
      );
    }
    debugMsg("end of manageLocations");
  }

  //--------------------------------------------------------------
  
}
