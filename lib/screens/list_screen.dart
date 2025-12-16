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
//import 'package:flutter/widget_previews.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scores/mixin/my_utils.dart';

import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:scores/screens/add_round_screen.dart';
import 'package:scores/services/game_storage.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.game});
  final Game game;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

//---------------------------------------------------------------

class _ListScreenState extends State<ListScreen> with MyUtils {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('We are playing ${widget.game.name}'),
        centerTitle: true,
      ),
      body: Container(child: scoresList(widget.game)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addButtonPressed(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //---------------------------------------------------------------

  //  @Preview(name: 'My Sample Text')
  Widget scoresList(Game game) {
    List<Widget> rows = [];

    rows.add(playersRow(game.players));

    rows.add(totalScoresRow(game));

    for (var round in game.rounds) {
      rows.add(scoresRow(game, round));
    }

    return Center(
      child: ListView(padding: const EdgeInsets.all(8), children: rows),
    );
  }

  //---------------------------------------------------------------

  Widget playersRow(List<Player> players) {
    List<Text> playerTexts = [];

    for (Player player in players) {
      playerTexts.add(
        Text(
          player.name,
          style: TextStyle(color: player.color, fontSize: 30),
          textAlign: TextAlign.center,
        ),
      );
    }
    return textRow(playerTexts);
  }

  //---------------------------------------------------------------

  Widget totalScoresRow(Game game) {
    List<Text> totalScoreTexts = [];

    for (int score in game.getTotalScores()) {
      totalScoreTexts.add(
        Text(
          score.toString(),
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }
    return textRow(totalScoreTexts);
  }

  //---------------------------------------------------------------

  Widget scoresRow(Game game, Round round) {
    List<Text> textItems = [];

    for (var item in round.getScores()) {
      textItems.add(
        Text(
          item.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return (slider(game, round, textRow(textItems)));
  }

  //---------------------------------------------------------------

  Widget textRow(List<Text> textItems) {
    List<Widget> rowChildren = [];

    for (Text item in textItems) {
      rowChildren.add(
        Expanded(
          child: Padding(padding: const EdgeInsets.all(14.0), child: item),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey,
            style: BorderStyle.solid,
          ), //BorderSide
        ), //Border
      ), //BoxDecoration

      child: Row(children: rowChildren),
    );
  }

  //---------------------------------------------------------------
  Widget slider(Game game, Round round, Widget row) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      //  key: const ValueKey(0),

      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        //    dismissible: DismissiblePane(onDismissed: () {}),

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (context) {
              deleteRowSlider(game, round);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              editRowSlider(game, round);
            },
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: row,
      //      child: const ListTile(title: Text('Slide me')),
    );
  }

  // void doNothing(BuildContext context) {}

  //   void onPressedMethod(BuildContext context){
  //     print(">>onPressedMethod");
  //   }

  //---------------------------------------------------------------

  Future<void> addButtonPressed(BuildContext context) async {
    debugMsg("addButtonPressed ... waiting");

    Round newRound = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoundScreen(game: widget.game),
      ),
    );
    debugMsg('addButtonPressed result=$newRound');

    widget.game.addRound(newRound);


    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState addButtonPressed saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState addButtonPressed ${e.toString()}", true);
    } 

    // Update UI or handle the returned data
    //    widget.game.addRound(newRound);

    setState(() {});
  }

  //---------------------------------------------------------------
  
  void deleteRowSlider(Game game, Round round) {
    debugMsg("deleteRowSlider round $round");

    debugMsg("num rounds before ${game.rounds.length}");

    game.rounds.remove(round);

    debugMsg("num rounds after ${game.rounds.length}");

    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState deleteRowSlider saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState deleteRowSlider ${e.toString()}", true);
    } 
    setState(() {});
  }

  //---------------------------------------------------------------

  Future<void> editRowSlider(Game game, Round round) async {
    debugMsg("editRowSlider round $round");

    final index = game.rounds.indexWhere((r) => r == round);

    debugMsg("editing round index $index");
    debugMsg("num rounds before edit ${game.rounds.length}");

    Round changedRound = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRoundScreen(game: widget.game, currentRound: round),
      ),
    );

    //    final index = game.rounds.indexWhere((r) => r == round);
    game.rounds[index] = changedRound;

    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState editRowSlider saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState editRowSlider ${e.toString()}", true);
    } 


    setState(() {});

    debugMsg("num rounds after edit ${game.rounds.length}");
  }
  //---------------------------------------------------------------
}
