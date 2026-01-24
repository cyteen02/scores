/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/05/2026
*
*----------------------------------------------------------------------------*/

class MatchPlayerStats {
  int? id;
  int matchId;
  int playerId;
  String stat;
  String value;

  MatchPlayerStats({
    this.id,
    required this.matchId,
    required this.playerId,
    required this.stat,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'player_id': playerId,
      'stat': stat,
      'value': value,
    };
  }

  factory MatchPlayerStats.fromMap(Map<String, dynamic> map) {
    return MatchPlayerStats(
      id: map['id'] as int?,
      matchId: map['match_id'] as int,
      playerId: map['player_id'] as int,
      stat: map['stat'] as String,
      value: map['value'] as String,
    );
  }
}