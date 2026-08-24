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
import 'package:scores/constants/app_assets.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/presentation/screens/history/list_all_matches_screen.dart';
import 'package:scores/utils/my_utils.dart';

class HistoryMenu extends StatefulWidget {
  const HistoryMenu({super.key});

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

//--------------------------------------------------------------

class _HistoryMenuState extends State<HistoryMenu> with MyMixin {
  
  @override
  void initState() {
    debugMsg("HistoryMenuState initState");
    super.initState();
  }

  //-----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        centerTitle: true,

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(AppAssets.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildHistoryMenuScreen()
        ),

    );
  }

  //--------------------------------------------------------------

  Widget _buildHistoryMenuScreen() {

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
              listAllMatches();
            },
            child: const Text('List All Matches'),
          ),
        ),
      ),
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(children: gameButtons),
      ),
    );
  }

  //--------------------------------------------------------------

  void listAllMatches() async {
    debugMsg("listAllMatches");

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListAllMatchesScreen()),
    );
  }
  //--------------------------------------------------------------
}
