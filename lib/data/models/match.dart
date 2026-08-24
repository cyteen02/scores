/*---------------------------------------------------------------------------

* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*----------------------------------------------------------------------------*/

import 'dart:convert';
import 'dart:math';

import 'package:scores/data/models/location.dart';
import 'package:scores/data/models/player_set.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/round.dart';
import 'package:scores/data/models/game.dart';

//---------------------------------------------------------------------------

// a MATCH is where a SET of PLAYERs play a GAME

class Match with MyMixin {
  int id;
//  int gameId;
  Game game;
//  Game? _game; // Cached, private
  PlayerSet playerSet;
  Location? location;
  List<Round> rounds;
  
  //---------------------------------------------------------------------------
  
  // Constructor
  Match({
    int? id,
//    required this.gameId,
    required this.game,
    required this.playerSet,
    this.location,
    List<Round>? rounds,
  }) : id = id ?? MyMixin.generateId(),
       rounds = rounds ?? [];

  // Match() {
  //   _name = "";
  //   _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  // }

  // Match.name(String name) {
  //   _name = name;
  //   _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  //   game = Game.name(name);
  // }

  // Match.id(int id) {
  //   id = id;
  // }

  // getters
  String get name => game.name;

//---------------------------------------------------------------------------

  // WinCondition get winCondition =>
  //     game.winCondition;

//---------------------------------------------------------------------------

  // GameLengthType get gameLengthType =>
  //     game.gameLengthType;


//---------------------------------------------------------------------------

  // ShowFutureRoundsType get showFutureRounds =>
  //     _game?.showFutureRoundsType ?? ShowFutureRoundsType.showNoFutureRounds;

//---------------------------------------------------------------------------

  // bool get fixedNumRounds =>
  //     (_game?.gameLengthType == GameLengthType.fixedLength);

//---------------------------------------------------------------------------

  // List<RoundLabel> get roundLabels => _game?.roundLabels ?? [];

//---------------------------------------------------------------------------

  List<Player> get players => playerSet.players;

  //---------------------------------------------------------------------------

  // Future<Game> getGameForId(int gameId) async {
  //   _game = await _gameRepository.getById(gameId);
  //   return _game!;
  // }

  // //---------------------------------------------------------------------------

  // Future<Game> getGame() async {
  //   _game ??= await _gameRepository.getById(gameId);
  //   return _game!;
  // }

  //---------------------------------------------------------------------------
  
  // Future<void> reloadGame() async {
  //   await getGame();

  //   if ( fixedNumRounds && 
  //        ( showFutureRounds == ShowFutureRoundsType.showAllFutureRounds ) &&
  //      ( rounds.length < roundLabels.length ) ) {
  //       initMissingRounds();
  //     }
  // }

  //---------------------------------------------------------------------------

  String get playersCsv {
    return playerSet.toCsv;
  }

  //---------------------------------------------------------------------------

  void setPlayers(List<Player> newPlayers) {
    debugMsg("Match setPlayers $newPlayers");
    playerSet = PlayerSet(players: newPlayers);
    // playerSet.clearPlayers();
    // players.addAll(newPlayers);
  }

  //---------------------------------------------------------------------------

  void setRounds(List<Round> newRounds) {
    debugMsg("Match setRounds $newRounds");
    rounds.clear();
    rounds.addAll(newRounds);
  }
 
  //-----------------------------------------------------------------

  void addPlayer(Player player) {
    playerSet.addPlayer(player);
  }

  //-----------------------------------------------------------------

  void addPlayers(List<Player> newPlayers) {
    playerSet.addPlayers(newPlayers);
  }

  //-----------------------------------------------------------------

  void initFirstRound() async {

    debugMsg("Match initFirstRound");

    Round firstRound = Round();
    if ( game.roundLabels.isNotEmpty) {
      firstRound.roundLabel = game.roundLabels[0];
    }
    firstRound.initPlayerScores(playerSet.players);
    rounds.clear();
    rounds.add(firstRound);
  }

  //-----------------------------------------------------------------

  void initAllRounds() async {

    debugMsg("Match initAllRound");

    // Set the init scores for all the rounds

    Round round;
    for (int r = 0; r < game.roundLabels.length; r++) {
      round = Round();
      round.initPlayerScores(playerSet.players);
      rounds.add(round);
    }
  }

//---------------------------------------------------------------------------

  void initMissingRounds2() async {

    // Set the init scores for all the rounds
//    final game = await getGame();

    Round round;
    for (int r = rounds.length ; r < game.roundLabels.length; r++) {
      round = Round();
      round.initPlayerScores(playerSet.players);
      rounds.add(round);
    }
  }
  //-----------------------------------------------------------------
  
  bool useRoundLabels() {
    return game.roundLabels.isNotEmpty;
  }

  //-----------------------------------------------------------------

  ShowFutureRoundsType showFutureRoundsType() {
    return game.showFutureRoundsType ;
  }

  //-----------------------------------------------------------------

  void addRound(Round round) {
    rounds.add(round);
  }

  //-----------------------------------------------------------------

  Location? getPlayerByName(String playerName) {
    return playerSet.players.cast<Location?>().firstWhere(
      (p) => p?.name == playerName,
      orElse: () => null,
    );
  }
  //-----------------------------------------------------------------

  Location? getPlayerById(int playerId) {
    return playerSet.players.cast<Location?>().firstWhere(
      (p) => p?.id == playerId,
      orElse: () => null,
    );
  }

  //-----------------------------------------------------------------

  List<String> getPlayerNames() {
    return playerSet.players.map((p) => p.name).toList();
  }

  //-----------------------------------------------------------------

  List<int> getPlayerIds() {
    return playerSet.players.map((p) => p.id).toList();
  }

  //-----------------------------------------------------------------

  int numPlayers() {
    return playerSet.numPlayers;
  }

  //-----------------------------------------------------------------

  void replacePlayer(Player oldPlayer, Player newPlayer) {
    playerSet.replacePlayer(oldPlayer, newPlayer);
    // relpace player in all the rounds as well
    for (Round round in rounds) {
      round.replacePlayer(oldPlayer, newPlayer);
    }
  }
  //-----------------------------------------------------------------

  void replacePlayers(List<Player> newPlayers) {
    playerSet.replacePlayers(newPlayers);
  }
  //-----------------------------------------------------------------

  int numRoundsPlayed() {
    return rounds.length;
  }
  //-----------------------------------------------------------------

  //   int totalScoreForPlayerId(int playerId) {
  //     int totalScore = 0;
  //     for (Round round in rounds) {
  //       totalScore += round.getScoreById(playerId) ?? 0;
  //     }
  //     return totalScore;
  //   }

  //   //-----------------------------------------------------------------

  //   int numRoundsMatchingScore(int playerId, int score) {
  //     int numRounds = 0;
  //     for (Round round in rounds) {
  //       if ((round.getScoreById(playerId) ?? 0) == score) {
  //         numRounds++;
  //       }
  //     }
  //     return numRounds;
  //   }

  //   //-----------------------------------------------------------------

  //   int maxScoreForPlayerId(int playerId) {
  //     int maxScore = 0;
  //     for (Round round in rounds) {
  //       var playerScore = round.getScoreById(playerId) ?? 0;
  //       if (playerScore > maxScore) {
  //         maxScore = playerScore;
  //       }
  //     }
  //     return maxScore;
  //   }

  //   //-----------------------------------------------------------------

  //   int minScoreForPlayerId(int playerId) {
  //     // hoping this is a reasonable highest score!
  //     int minScore = 999999;
  //     for (Round round in rounds) {
  //       var playerScore = round.getScoreById(playerId) ?? 0;
  //       if (playerScore < minScore) {
  //         minScore = playerScore;
  //       }
  //     }
  //     return minScore;
  //   }

  //   //-----------------------------------------------------------------

  //   double avgScoreForPlayerId(int playerId) {
  // //    return totalScoreForPlayerId(playerId) / numRoundsPlayed();
  //     return double.parse((totalScoreForPlayerId(playerId) / numRoundsPlayed()).toStringAsFixed(2));

  //   }

  //   //-----------------------------------------------------------------

  //   List<int> getTotalScores() {
  //     debugMsg("Match getTotalScores");

  //     Map<int, int> totalScores = {};

  //     for (Player player in players) {
  //       totalScores[player.id ?? 0] = totalScoreForPlayerId(player.id ?? 0);
  //     }

  //     return totalScores.values.toList();
  //   }

  //   //-----------------------------------------------------------------

  //   int getHighestScore() {
  //     return getTotalScores().reduce((a, b) => a > b ? a : b);
  //   }

  //   //-----------------------------------------------------------------

  //   int getLowestScore() {
  //     return getTotalScores().reduce((a, b) => a < b ? a : b);
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getHighestScorePlayers() {
  //     // return a list of players who get the winning score

  //     List<Player> highestScorePlayers = [];
  //     int highestScore = getHighestScore();

  //     for (Player player in players) {
  //       if (totalScoreForPlayerId(player.id ?? 0) == highestScore) {
  //         highestScorePlayers.add(player);
  //       }
  //     }
  //     return highestScorePlayers;
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getLowestScorePlayers() {
  //     // return a list of players who get the lowest score

  //     List<Player> lowestScorePlayers = [];
  //     int lowestScore = getLowestScore();

  //     for (Player player in players) {
  //       if (totalScoreForPlayerId(player.id ?? 0) == lowestScore) {
  //         lowestScorePlayers.add(player);
  //       }
  //     }
  //     return lowestScorePlayers;
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getWinningPlayers() {
  //     if (game.winCondition == WinCondition.highestScore) {
  //       return getHighestScorePlayers();
  //     } else {
  //       return getLowestScorePlayers();
  //     }
  //   }
  //   //-----------------------------------------------------------------

  // List<int> totalScoresList = [];

  // totalScores.forEach((player, score) {
  //   totalScoresList.add(totalScores[player] ?? 0);
  // });

  // return totalScoresList;
  // }

  //-----------------------------------------------------------------

  // void record() {
  //   debugMsg("Match record");
  // }

  //-----------------------------------------------------------------

  void resetScores() {
    debugMsg("Match resetScores");
    //    rounds.clear();
    rounds = [];

      if (game.showFutureRoundsType ==
          ShowFutureRoundsType.showAllFutureRounds) {
        // initialise all the next rounds
        initAllRounds();
      }
  }

  //-----------------------------------------------------------------

  void clear() {
    debugMsg("Match clear");

    rounds.clear();
    // generate a new id
    id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  }

  //-----------------------------------------------------------------

  bool matchFinished() {
    final finished =
        (rounds.isNotEmpty && rounds.length == game.roundLabels.length);

    debugMsg("matchFinished finished $finished");

    return finished;
  }

  //-----------------------------------------------------------------
  // Convert to Map for SQLite
  // note match is never recorded in the database.
  // its in local storage during play
  // then match_history and _stats is recorded after

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game': game.toMap(),
      'players': jsonEncode(playerSet.players.map((p) => p.toMap()).toList()),
      'location': location?.toMap(),
      'rounds': jsonEncode(rounds.map((r) => r.toMap()).toList()),
    };
  }

  //-----------------------------------------------------------------
  // For JSON serialization (calls toMap)
  //  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game': game.toJson(),
      'playerSet': playerSet.toJson(),
      'location': location?.toMap(),
      'rounds': jsonEncode(rounds.map((r) => r.toMap()).toList()),
    };
  }

  //-----------------------------------------------------------------

  // Create from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    int id = json['id'];

    Game game = Game.fromJson(json['game']);

    PlayerSet playerSet = PlayerSet();
    if (json.containsKey('playerSet')) {
      playerSet = PlayerSet.fromJson(json['playerSet']);
    }

    Location? location;
    if (json.containsKey('location')) {
      location = json['location'] == null
          ? null
          : Location.fromMap(json['location']);
    }

    // if (json.containsKey('players')) {
    //   List<Player> players = json['players'] != null
    //       ? (jsonDecode(json['players']) as List)
    //           .map((playerJson) => Player.fromJson(playerJson))
    //           .toList()
    //     : <Player>[];

    //   match.playerSet = PlayerSet(players: players);
    // }

    // Decode the JSON string first, then map
    List<Round> rounds;

    rounds = json['rounds'] != null
        ? (jsonDecode(json['rounds']) as List)
              .map((roundJson) => Round.fromJson(roundJson))
              .toList()
        : <Round>[];

    Match match = Match(
      id: id,
      game: game,
      playerSet: playerSet,
      location: location,
      rounds: rounds,
    );

    debugMsg(match.toString());

    return match;
  }

  //---------------------------------------------------------------------------
  // Create a copy with optional field updates
  Match copyWith({
    int? id,
    required Game game,
    PlayerSet? playerSet,
    Location? location,
    List<Round>? rounds,
  }) {
    return Match(
      id: id ?? this.id,
      game: game,
      playerSet: playerSet ?? this.playerSet,
      location: location ?? this.location,
      rounds: rounds ?? this.rounds,
    );
  }

  //-----------------------------------------------------------------

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();

    buffer.write("id $id gameId ${game.id}");

    buffer.write("location $location");

    buffer.write(" players[");
    for (var player in playerSet.players) {
      buffer.write(" ");
      buffer.write(player.toString());
    }
    buffer.write("] rounds[");

    for (var round in rounds) {
      buffer.write(" ");
      buffer.write(round.toString());
    }
    buffer.write("]");

    return buffer.toString();
  }

  //-----------------------------------------------------------------
}
