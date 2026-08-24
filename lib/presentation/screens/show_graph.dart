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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:scores/data/models/match.dart';

import 'package:scores/data/extensions/double_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';

//---------------------------------------------------------------------------

class MatchScoreChartScreen extends StatelessWidget {
  final Match match;

  const MatchScoreChartScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Match Scores'))),
      body: MatchScoreChart(match: match),
    );
  }
}

//---------------------------------------------------------------------------

class MatchScoreChart extends StatelessWidget {
  final Match match;

  const MatchScoreChart({super.key, required this.match});

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 16,
            children: match.playerSet.players.map((player) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 20, height: 3, color: Color(player.color)),
                  const SizedBox(width: 4),
                  Text(player.name),
                ],
              );
            }).toList(),
          ),
        ),
        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                lineBarsData: _createLines(),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Rounds'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: roundLabel,
                      // getTitlesWidget: (value, meta) {
                      //   if (value.isInteger()) {
                      //     return Text('${value.toInt()}');
                      //   } else {
                      //     return Text("");
                      //   }
                      // },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30, // Give more space for labels
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),

                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //---------------------------------------------------------------------------

  List<LineChartBarData> _createLines() {
    return match.playerSet.players.map((player) {
      return LineChartBarData(
        spots: _createSpotsForPlayer(player.id),
        isCurved: false,
        color: Color(player.color),
        barWidth: 3,
        dotData: FlDotData(show: true),
      );
    }).toList();
  }

  //---------------------------------------------------------------------------

  List<FlSpot> _createSpotsForPlayer(int playerId) {
    List<FlSpot> spots = [
      FlSpot(0, 0), // Start at zero
    ];

    int score = 0;
    for (int i = 0; i < match.rounds.length; i++) {
      score += match.rounds[i].scores[playerId] ?? 0;
      spots.add(FlSpot(i + 1.toDouble(), score.toDouble()));
    }
    return spots;
  }

  //---------------------------------------------------------------------------

  Widget roundLabel(double value, TitleMeta meta) {
    Widget label = Text("");
    if (value > 0 && value.isInteger()) {
      int roundNum = value.toInt();

      if (roundNum > match.game.roundLabels.length) {
        label = Text('${value.toInt()}');
      } else {
        label = Text(
          match.game.roundLabels[roundNum-1].name,
          style: TextStyle(color: match.game.roundLabels[roundNum-1].color.toColor()),
        );
      }
    }

    return label;
  }

  //---------------------------------------------------------------------------
}
