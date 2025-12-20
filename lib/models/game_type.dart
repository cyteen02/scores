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

import 'package:flutter/material.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class GameType with MyUtils {
  String _name = "";
  List<String> _roundList = <String>[];


String get name => _name;
List<String> get roundList => _roundList;

// Constructor
  GameType(String name) {
    _name = name;

    if ( name == "Rummy") {
      _roundList = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "J", "Q", "K"];            
    }
  }
}