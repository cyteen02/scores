/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/25/2025
*
*----------------------------------------------------------------------------*/

import 'package:scores/data/models/stats/location_winner_stat.dart';

import 'package:scores/data/repositories/database_helper.dart';

class HistoricDataRepository {
  final dbHelper = DatabaseHelper.instance;

  HistoricDataRepository();

  //----------------------------------------------------------------

  Future<List<LocationWinnerStat>> getLocationWinners(int gameId) async {
    return await dbHelper.safeDbCall(() async {
      final db = await dbHelper.database;

      final results = await db.rawQuery(
        '''
        SELECT 
            l.name AS location_name, 
            p.name AS player_name,
	          COUNT(*) AS win_count
        FROM match_history mh
        JOIN match_player_stats ps ON mh.match_id = ps.match_id
        FULL JOIN location l       ON mh.location_id = l.id
        JOIN player p              ON ps.player_id = p.id
        WHERE mh.game_id = ?
          AND ps.stat = 'WINNER'
        GROUP BY location_name, player_name  
        ''',
        [gameId],
      );

      // Turn the raw List<Map> into a crisp List<LocationWinnerStat>
      return results.map((row) => LocationWinnerStat.fromMap(row)).toList();
    }, context: "HistoricDataRepository.getLocationWinners") ??
    []; // Return empty list if it fails
  }

  //---------------------------------------------------------------------------
}
