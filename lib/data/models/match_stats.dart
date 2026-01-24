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

class MatchStats {
  int? id;
  int matchId = 0;
  String stat = "";  
  String value = ""; 

//-----------------------------------------------------------------

  MatchStats({
    this.id,
    required this.matchId,
    required this.stat,
    required this.value,
  });

//-----------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'stat': stat,
      'value': value,
    };
  }

//-----------------------------------------------------------------

  factory MatchStats.fromMap(Map<String, dynamic> map) {
    return MatchStats(
      id: map['id'] as int?,
      matchId: map['match_id'] as int,
      stat: map['stat'] as String,
      value: map['value'] as String,
    );
  }
  //-----------------------------------------------------------------
}
