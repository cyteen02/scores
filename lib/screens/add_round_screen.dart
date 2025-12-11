import 'package:flutter/material.dart';
// import 'package:flutter/widget_previews.dart';

import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';

class AddRoundScreen extends StatefulWidget {
  const AddRoundScreen({super.key, required this.game});
  final Game game;

  @override
  State<AddRoundScreen> createState() => _AddRoundScreenState();
}

class _AddRoundScreenState extends State<AddRoundScreen> {
  Round newRound = Round([]);

  @override
  void initState() {

    super.initState();
    // Your initialization code here
    print('>>_AddRoundScreenState initState');
    print('Received: ${widget.game}');
    newRound.setPlayers(widget.game.players);
  }

  @override
  Widget build(BuildContext context) {
    print(">> _AddRoundScreenState build");

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a round'),
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
      body: Container(child: addPlayerScores(widget.game)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget addPlayerScores(Game game) {
    //    Round newRound = Round(game.players);

    Container c = Container();

    List<Widget> scoresRow = [];

    for (Player player in game.players) {
      scoresRow.add(addPlayerScore(newRound, player));
    }
    return Column(children: scoresRow);
  }

  Widget addPlayerScore(Round round, Player player) {
    print(">> row for ${player.name} current ${round.getScore(player)}");
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

  void buttonPressed(Round round, Player player, int scoreButton) {
    print(">> buttonPressed ${player.name} add score of $scoreButton");

    setState(() {
      print(round);
      round.updatePlayerScore(player, scoreButton);
      print(round);
    });
  }

  void savePressed(Game game, Round newRound) {
    print(">> savePressed returning newRound $newRound");
//    widget.game.addRound(newRound);
    Navigator.pop(context, newRound);
  }
}
