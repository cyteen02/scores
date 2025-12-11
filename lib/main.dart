import 'package:flutter/material.dart';
import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';

//import 'package:flutter/widget_previews.dart';
import 'package:scores/screens/list_screen.dart';

void main() {
  runApp(Scores());
}

class Scores extends StatelessWidget {
  final Game game = Game('Rummy');

  Scores({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    game.clear();

    Player player = Player('Paul');
    player.setColor(Colors.red);
    game.addPlayer(player);

    player = Player('Jane');
    player.setColor(Colors.blue);
    game.addPlayer(player);

    Round round = Round(game.players);
    round.setScoreByName('Paul', 10);
    round.setScoreByName('Jane', 15);
    game.addRound(round);

    // round = Round(game.players);
    // round.setScoreByName('Paul', 20);
    // game.addRound(round);

    // round = Round(game.players);
    // round.setScoreByName('Paul', 30);
    // game.addRound(round);

    return MaterialApp(
      title: 'We are playing ${game.name}',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
//      home: home(game),
      home: ListScreen(game: game),
    );
  }

  // Widget home(Game game) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('We are playing ${game.name}'),
  //       centerTitle: true,
  //     ),
  //     body: Container(child: scoresList(game)),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {
  //         // Your action here
  //         print('Button pressed');
  //       },
  //       child: Icon(Icons.add),
  //     ),
  //     floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  //   );
  // }

  // @Preview(name: 'My Sample Text')
  // Widget scoresList(Game game) {
  //   List<Widget> rows = [];

  //   rows.add(playersRow(game.players));
  //   rows.add(totalScoresRow(game));

  //   for (var round in game.rounds) {
  //     rows.add(scoresRow(round.getScores()));
  //   }

  //   return Center(
  //     child: ListView(padding: const EdgeInsets.all(8), children: rows),
  //   );
  // }

  // Widget playersRow(List<Player> players) {
  //   List<Text> playerTexts = [];

  //   for (Player player in players) {
  //     playerTexts.add(
  //       Text(
  //         player.name,
  //         style: TextStyle(color: player.color, fontSize: 30),
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }
  //   return textRow(playerTexts);
  // }

  // Widget totalScoresRow(Game game) {
  //   List<Text> totalScoreTexts = [];

  //   for (int score in game.getTotalScores()) {
  //     totalScoreTexts.add(
  //       Text(
  //         score.toString(),
  //         style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }
  //   return textRow(totalScoreTexts);
  // }

  // Widget scoresRow(List<dynamic> items) {
  //   List<Text> textItems = [];

  //   for (var item in items) {
  //     textItems.add(
  //       Text(
  //         item.toString(),
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontSize: 20),
  //       ),
  //     );
  //   }

  //   return (textRow(textItems));
  // }

  // Widget textRow(List<Text> textItems) {
  //   List<Widget> rowChildren = [];

  //   for (Text item in textItems) {
  //     rowChildren.add(
  //       Expanded(
  //         child: Padding(padding: const EdgeInsets.all(14.0), child: item),
  //       ),
  //     );
  //   }

  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(
  //           width: 0.5,
  //           color: Colors.grey,
  //           style: BorderStyle.solid,
  //         ), //BorderSide
  //       ), //Border
  //     ), //BoxDecoration

  //     child: Row(children: rowChildren),
  //   );
  // }

  // void addButtonPressed(game){

  // }

}
