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

//import 'package:scores/data/models/player_set.dart';
import 'package:scores/data/models/round_label.dart';
import 'package:scores/presentation/mixin/my_mixin.dart';

enum ShowFutureRoundsType {
  showNoFutureRounds('Don\'t show future rounds'),
  showNextFutureRound('Show next round only'),
  showAllFutureRounds('Show all future rounds');

  final String description;
  const ShowFutureRoundsType(this.description);
}

enum WinCondition {
  highestScore('Highest Score'),
  lowestScore('Lowest Score');

  final String description;
  const WinCondition(this.description);
}

enum GameLengthType {
  variableLength('Variable'),
  fixedLength('Fixed');

  final String description;
  const GameLengthType(this.description);
}

class Game with MyMixin {
  int? id;
  String name;
  List<RoundLabel> roundLabels;
  ShowFutureRoundsType showFutureRoundsType;
  WinCondition winCondition = WinCondition.highestScore;
  GameLengthType gameLengthType = GameLengthType.variableLength;

  Game({
    this.id,
    required this.name,
    this.roundLabels = const [],
    this.winCondition = WinCondition.highestScore,
    this.showFutureRoundsType = ShowFutureRoundsType.showNoFutureRounds,
    this.gameLengthType = GameLengthType.variableLength,
  });

  //-----------------------------------------------------------------

  bool fixedNumRounds() {
    return gameLengthType == GameLengthType.fixedLength;
    //    return roundLabels.isNotEmpty;
    // return showFutureRoundsType !=
    //         ShowFutureRoundsType.showNoFutureRounds;
  }
  //-----------------------------------------------------------------

  bool useRoundLabels() {
    return roundLabels.isNotEmpty;
  }

  //-----------------------------------------------------------------

  // Convert Game to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'showFutureRoundsType': showFutureRoundsType.name,
      'winCondition': winCondition.name,
      'gameLengthType': gameLengthType.name,
    };
  }

  //-----------------------------------------------------------------

  // Create a Game from a Map (from database)
  factory Game.fromMap(
    Map<String, dynamic> map, {
    List<RoundLabel>? roundLabels,
  }) {
    return Game(
      id: map['id'] as int?,
      name: map['name'] as String,
      roundLabels: roundLabels ?? [],
      showFutureRoundsType: ShowFutureRoundsType.values.byName(
        map['showFutureRoundsType'],
      ),
      winCondition: WinCondition.values.byName(map['winCondition']),
      gameLengthType: GameLengthType.values.byName(map['gameLengthType']),
    );
  }

  //---------------------------------------------------------------------------

  // Convert Game to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roundLabels': roundLabels.map((label) => label.toJson()).toList(),
      'showFutureRoundsType': showFutureRoundsType.name,
      'winCondition': winCondition.name,
      'gameLengthType': gameLengthType.name,
    };
  }

  //-----------------------------------------------------------------
  // Create Game from JSON Map
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int?,
      name: json['name'] as String,
      roundLabels: (json['roundLabels'] as List<dynamic>)
          .map((labelJson) => RoundLabel.fromJson(labelJson))
          .toList(),
      showFutureRoundsType: ShowFutureRoundsType.values.firstWhere(
        (e) => e.name == json['showFutureRoundsType'],
      ),
      winCondition: WinCondition.values.firstWhere(
        (e) => e.name == json['winCondition'],
        orElse: () => WinCondition.highestScore,
      ),
      gameLengthType: GameLengthType.values.firstWhere(
        (e) => e.name == json['gameLengthType'],
        orElse: () => GameLengthType.variableLength,
      ),
    );
  }
  //---------------------------------------------------------------------------

  // Create a copy with optional field updates
  Game copyWith({
    int? id,
    String? name,
    List<RoundLabel>? roundLabels,
    ShowFutureRoundsType? showFutureRoundsType,
    WinCondition? winCondition,
    GameLengthType? gameLengthType,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      roundLabels: roundLabels ?? this.roundLabels,
      winCondition: winCondition ?? this.winCondition,
      showFutureRoundsType: showFutureRoundsType ?? this.showFutureRoundsType,
      gameLengthType: gameLengthType ?? this.gameLengthType,
    );
  }

  //-----------------------------------------------------------------

  @override
  String toString() {
    return "id $id name $name ${roundLabels.toString()} showFutureRoundsType $showFutureRoundsType winCondition $winCondition gameLengthType $gameLengthType";
  }

  //-----------------------------------------------------------------
}
