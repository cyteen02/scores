/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/03/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/models/match.dart';

enum ListRoundsBottomNavBarEnum {
  players('Players', Icons.people),
  stats('Stats', Icons.query_stats),
  graph('Graph', Icons.show_chart),
  end('Game End', Icons.save),
  clear('Clear', Icons.clear);

  final String label;
  final IconData icon;

  const ListRoundsBottomNavBarEnum(this.label, this.icon);
}

class ListRoundsBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(BuildContext, int, Match) onItemTapped;
  final Match match;

  const ListRoundsBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {

List<BottomNavigationBarItem> items = ListRoundsBottomNavBarEnum.values
          .map(
            (tab) =>
                BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
          )
          .toList();

    return BottomNavigationBar(
         type: BottomNavigationBarType.fixed,
   showUnselectedLabels: true,
      items:items,
      currentIndex: currentIndex,
      fixedColor: Colors.black,
      onTap: ((int index) {
        onItemTapped(context, index, match);
      }),
    );
  }

  //---------------------------------------------------------------
}
