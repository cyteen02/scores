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
import 'package:scores/mixin/my_utils.dart';
// import 'package:flutter/widget_previews.dart';

import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';

//--------------------------------------------------------------

class AddRoundScreen extends StatefulWidget {
  final Game game;
  final Round? currentRound;

  const AddRoundScreen({super.key, required this.game, this.currentRound});

  @override
  State<AddRoundScreen> createState() => _AddRoundScreenState();
}

//--------------------------------------------------------------

class _AddRoundScreenState extends State<AddRoundScreen> with MyUtils {
  Round newRound = Round([]);
  bool editExistingRound = true;

  @override
  void initState() {
    super.initState();
    // Your initialization code here
    debugMsg('_AddRoundScreenState initState');

    editExistingRound = (widget.currentRound != null);

    debugMsg('Received: ${widget.game} editExistingRound $editExistingRound');

    if (editExistingRound) {
      newRound = widget.currentRound!;
    } else {
      newRound.setPlayers(widget.game.players);
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
              savePressed(widget.game, newRound);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(child: addPlayerScores(widget.game)),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //--------------------------------------------------------------

  Widget addPlayerScores(Game game) {
    //    Round newRound = Round(game.players);

    //    Container c = Container();

    List<Widget> scoresRow = [];

    for (Player player in game.players) {
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
              style: TextStyle(color: player.color, fontSize: 30),
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

  void savePressed(Game game, Round newRound) {
    debugMsg("savePressed returning newRound $newRound");
    //widget.game.addRound(newRound);
    Navigator.pop(context, newRound);
  }

  //--------------------------------------------------------------
}
