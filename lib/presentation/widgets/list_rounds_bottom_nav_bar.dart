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
  end('The End', Icons.save),
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

    return BottomNavigationBar(
  items: ListRoundsBottomNavBarEnum.values.map((tab) => BottomNavigationBarItem(
    icon: Icon(tab.icon),
    label: tab.label,
  )).toList(),
      // items: const <BottomNavigationBarItem>[
      //   BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
      //   BottomNavigationBarItem(icon: Icon(Icons.save), label: 'The End'),
      //   BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Clear'),
      // ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      onTap: ((int index) {
          onItemTapped(context, index, match);
      }),
    );
  }

  //---------------------------------------------------------------

}