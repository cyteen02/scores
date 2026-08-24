/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 07/22/2026
*
*----------------------------------------------------------------------------*/

class LocationWinnerStat {
  final String locationName;
  final String playerName;
  final int winCount;

  LocationWinnerStat({
    required this.locationName,
    required this.playerName,
    required this.winCount,
  });

//---------------------------------------------------------------------------

  // Factory constructor to parse directly from the database map
  factory LocationWinnerStat.fromMap(Map<String, dynamic> map) {
    return LocationWinnerStat(
      locationName: map['location_name'] as String? ?? 'Unknown Location',
      playerName: map['player_name'] as String? ?? 'Unknown Player',
      // SQLite returns COUNT(*) as an integer
      winCount: map['win_count'] as int? ?? 0, 
    );
  }
  //---------------------------------------------------------------------------
  
}
