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

import 'package:scores/mixin/my_mixin.dart';

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

class Game with MyMixin {
  int? id;
  String name = "";
  List<String> roundList = <String>[];
  ShowFutureRoundsType showFutureRoundsType =
      ShowFutureRoundsType.showNoFutureRounds;
  WinCondition winCondition = WinCondition.highestScore;

  //   GameType({required this.name});

  // String get name => name;
  // List<String> get roundList => roundList;

  // Constructor
  Game() {
    winCondition = WinCondition.highestScore;
  }

  Game.name(String name) {
    name = name;
    winCondition = WinCondition.highestScore;
  }

//-----------------------------------------------------------------

  Game.id(int id) {
    id = id;
    winCondition = WinCondition.highestScore;
  }

//-----------------------------------------------------------------

  // int? get id => id;

  // set id(int id) => _id = id;

//-----------------------------------------------------------------

  bool fixedNumRounds() {
    return roundList.isNotEmpty;
    // return showFutureRoundsType !=
    //         ShowFutureRoundsType.showNoFutureRounds;
  }
//-----------------------------------------------------------------

bool useRoundLabels(){
  return roundList.isNotEmpty;
}

//-----------------------------------------------------------------
  // Convert Game to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roundList': roundList.join(','), // Store as csv
      'showFutureRoundsType': showFutureRoundsType.name,
      'winCondition': winCondition.name,
    };
  }

//-----------------------------------------------------------------

  // Create Game from Map when reading from database
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game()
      ..id = map['id']
      ..name = map['name']
      ..roundList = (map['roundList'] as String).isEmpty
          ? []
          : (map['roundList'] as String).split(',')
      ..showFutureRoundsType = ShowFutureRoundsType.values.byName(
        map['showFutureRoundsType'],
      )
      ..winCondition = WinCondition.values.byName(map['winCondition']);
  }

//-----------------------------------------------------------------

  @override
  String toString() {
    return "id $id name $name ${roundList.toString()} showFutureRoundsType $showFutureRoundsType winCondition $winCondition";
  }

  //-----------------------------------------------------------------
}
