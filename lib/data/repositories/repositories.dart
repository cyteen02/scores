/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 07/06/2026
*
*----------------------------------------------------------------------------*/

// A single place where all your "database connections" live globally
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/data/repositories/historic_data_repository.dart';
import 'package:scores/data/repositories/location_repository.dart';
import 'package:scores/data/repositories/match_repository.dart';
import 'package:scores/data/repositories/match_history_repository.dart';
import 'package:scores/data/repositories/match_player_stats_repository.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/data/repositories/player_repository.dart';
import 'package:scores/data/repositories/player_set_repository.dart';
import 'package:scores/data/repositories/round_label_repository.dart';

final gameRepository = GameRepository();
final historicDataRepository = HistoricDataRepository();
final locationRepository = LocationRepository();
final matchRepository = MatchRepository();
final matchPlayerStatsRepository = MatchPlayerStatsRepository();
final matchStatsRepository = MatchStatsRepository();
final matchHistoryRepository = MatchHistoryRepository();
final playerRepository = PlayerRepository();
final playerSetRepository = PlayerSetRepository();
final roundLabelRepository = RoundLabelRepository();
