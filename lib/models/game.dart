import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';

class Game {
   String _name = "";
   List<Player> _players = <Player>[];
   List<Round> _rounds = <Round>[];

  // Constructor
  Game(String name) {
    _name = name;
  }

  // getters
  String get name => _name;

  List<Player> get players => _players;

  List<Round> get rounds => _rounds;

  // Setters

  set name(String name) => _name = name;

  void setName(String name) {
    _name = name;
  }

  void addPlayer(Player player) {
    _players.add(player);
  }

  void addPlayerByName(String playerName) {
    bool playerNameFound = false;
    for (Player p in players) {
      playerNameFound = playerNameFound | (p.name == playerName);
    }

    if (!playerNameFound) {
      var player = Player(playerName);
      addPlayer(player);
    }
  }

  void addRound(Round round) {
    _rounds.add(round);
  }

  List<String> getPlayerNames() {
    List<String> playersList = [];

    for (var player in _players) {
      playersList.add(player.name);
    }

    return playersList;
  }

  List<int> getTotalScores() {

    print(">> getTotalScores");

    Map<String, int> totalScores = {};

    for ( Round round in rounds ) {
    
      for ( String playerName in round.getPlayerNames()) {

        // int prevScore = totalScores[playerName] ?? 0;
        // print(">> prevScore $prevScore");

        int thisScore = round.getScoreByName(playerName) ?? 0;
        // print(">> thisScore $thisScore");

        // int newScore = prevScore + thisScore;

        // print(">> newScore $newScore");

        totalScores[playerName] = ( totalScores[playerName] ?? 0) + thisScore;
//        totalScores.update(playerName, (value) => newScore, ifAbsent: () => 0 );
      }
    }

    return totalScores.values.toList();

    
    // List<int> totalScoresList = [];

    // totalScores.forEach((player, score) {
    //   totalScoresList.add(totalScores[player] ?? 0);
    // });

    // return totalScoresList;
  }

  void clear() {
    _players.clear();
    _rounds.clear();
  }
  
  @override
  String toString() {
    String gameString = "Game name:$_name";

    for (var round in rounds) {
      gameString = '$gameString ${round.toString()}';
    }

    return gameString;
  }
}
