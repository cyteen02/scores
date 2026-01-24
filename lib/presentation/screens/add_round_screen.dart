/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/round_label.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/round.dart';


//--------------------------------------------------------------

class AddRoundScreen extends StatefulWidget {
  final Match match;
  final Round? currentRound;
  final RoundLabel? roundLabel;
  
  const AddRoundScreen({super.key, required this.match, this.currentRound, this.roundLabel});

  @override
  State<AddRoundScreen> createState() => _AddRoundScreenState();
}

//--------------------------------------------------------------

class _AddRoundScreenState extends State<AddRoundScreen> with MyMixin {

  Round newRound = Round();
  bool editExistingRound = true;

  @override
  void initState() {
    super.initState();
    debugMsg('_AddRoundScreenState initState');

    editExistingRound = (widget.currentRound != null);

    debugMsg('Received: ${widget.match} editExistingRound $editExistingRound');

    if (editExistingRound) {
      newRound = widget.currentRound!;
    } else {

      if ( widget.roundLabel != null ){
        newRound.roundLabel = widget.roundLabel;
      }
      newRound.initPlayerScores(widget.match.players);
    }
  }

  //--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("_AddRoundScreenState build");

    return Scaffold(
      appBar: AppBar(
        title: Text("${editExistingRound ? 'Edit' : 'Add'} a round"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              savePressed(widget.match, newRound);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(child: addPlayerScores(widget.match)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //--------------------------------------------------------------

  Widget addPlayerScores(Match match) {
    
        List<Widget> scoresRow = [];

    for (Player player in match.players) {
      scoresRow.add(addPlayerScore(newRound, player));
    }
    return Column(children: scoresRow);
  }

  //--------------------------------------------------------------

  Widget addPlayerScore(Round round, Player player) {
    debugMsg("row for ${player.name} current ${round.getScore(player)}");
    return Column(
      children: [
        Row(
          children: [
            Text(
              player.name,
              style: TextStyle(color: player.color.toColor(), fontSize: 30),
              textAlign: TextAlign.left,
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              scoreTextButton(round, player, "+1"),
              scoreTextButton(round, player, "+5"),
              scoreTextButton(round, player, "+10"),
              scoreTextButton(round, player, "+100"),
            ],
          ),
        ),

        Text(
          round.getScore(player).toString(),
          style: TextStyle(color: Colors.black, fontSize: 50),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              scoreTextButton(round, player, "-100"),
              scoreTextButton(round, player, "-10"),
              scoreTextButton(round, player, "-5"),
              scoreTextButton(round, player, "-1"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Divider(thickness: 0.5),
        ),
      ],
    );
  }

  //--------------------------------------------------------------

  Widget scoreTextButton(Round round, Player player, String scoreText) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(width: 0.5),
        ),
      ),
      onPressed: () {
        buttonPressed(round, player, int.parse(scoreText));
      },
      child: Text(scoreText),
    );
  }

  //--------------------------------------------------------------

  void buttonPressed(Round round, Player player, int scoreButton) {
    debugMsg("buttonPressed ${player.name} add score of $scoreButton");

    setState(() {
      debugMsg(round.toString());
      round.updatePlayerScore(player, scoreButton);
      debugMsg(round.toString());
    });
  }

  //--------------------------------------------------------------

  void savePressed(Match match, Round newRound) {
    debugMsg("savePressed returning newRound $newRound");
    Navigator.pop(context, newRound);
  }

  //--------------------------------------------------------------
}
