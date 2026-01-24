/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/15/2026
*
*----------------------------------------------------------------------------*/

class MatchHistory {
  int matchId;
  int gameId;
  int playerSetId;
  DateTime matchDate;

  MatchHistory({
    required this.matchId,
    required this.gameId,
    required this.playerSetId,
    DateTime? matchDate,
  }) : matchDate = matchDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'game_id': gameId,
      'player_set_id': playerSetId,
      'match_date': matchDate.toIso8601String(),
    };
  }

  factory MatchHistory.fromMap(Map<String, dynamic> map) {
    return MatchHistory(
      matchId: map['match_id'] as int,
      gameId: map['game_id'] as int,
      playerSetId: map['player_set_id'] as int,
      matchDate: DateTime.parse(map['match_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory MatchHistory.fromJson(Map<String, dynamic> json) => MatchHistory.fromMap(json);
}
