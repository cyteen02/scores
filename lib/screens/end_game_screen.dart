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
import 'package:scores/models/match.dart';

class EndMatchScreen extends StatefulWidget {
  const EndMatchScreen({super.key, required this.match});
  final Match match;

  @override
  State<EndMatchScreen> createState() => _EndMatchScreenState();
}

//-------------------------------------------------------------------

class _EndMatchScreenState extends State<EndMatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.match.name} Endgame'), centerTitle: true),
      body: Container(child: endGameScreen(widget.match)),
    );
  }

  //-------------------------------------------------------------------

  Widget endGameScreen(Match game) {
    return Column(children: [(Text("The End")), bottomButtons(game)]);
  }

  //-------------------------------------------------------------------

  Widget bottomButtons(Match game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Discard'),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => saveGameStats(game),
          child: Text('Save Stats'),
        ),
      ],
    );
  }

  //-------------------------------------------------------------------

  void saveGameStats(Match game) {}

  //-------------------------------------------------------------------
}
