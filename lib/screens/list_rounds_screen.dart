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
import 'package:scores/database/player_repository.dart';

import 'package:scores/dialogs/change_player_colour.dart';
//import 'package:scores/dialogs/change_player_name.dart';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/screens/end_game_screen.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/models/match.dart';
import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:scores/screens/add_round_screen.dart';
import 'package:scores/services/match_storage.dart';

//---------------------------------------------------------------

class ListRounds extends StatefulWidget {
  const ListRounds({super.key, required this.match});
  final Match match;

  @override
  State<ListRounds> createState() => _ListRoundsState();
}

//---------------------------------------------------------------

class _ListRoundsState extends State<ListRounds> with MyMixin {
  bool isLoading = true;
  int _bnbSelectedIndex = 0;
  late Match match;
  late Game game;
  //  int _counter = 0;
  double roundLabelsWidth = 0.0;

  @override
  void initState() {
    debugMsg("_ListRoundsState initState");
    super.initState();

    match = widget.match; // Copy to local state
    game = Game.name(match.name);

    debugMsg("starting match.game ${match.game.toString()}");
    if (match.useRoundLabels()) {
      roundLabelsWidth = calculateRoundLabelsWidth(match.game.roundList);
    } else {
      debugMsg("EMPTY");
    }
  }

  //---------------------------------------------------------------

  @override
  void dispose() {
    debugMsg("_ListRoundsState dispose");

    saveGameState();

    super.dispose();
  }
  //---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //     if (isLoading) {
    //   return CircularProgressIndicator();
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('We are playing ${match.name}'),
        centerTitle: true,
      ),
      body: Container(child: listRounds(match)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (match.players.isNotEmpty) {
            addButtonPressed(context);
          }
        },
        backgroundColor: match.players.isNotEmpty ? Colors.blue : Colors.grey,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: bottomNavigationBar(match),
    );
  }

  //---------------------------------------------------------------

  Widget listRounds(Match match) {
    debugMsg("listRounds match $match");

    // Build a list of rows to display
    List<RoundRow> rows = [];

    if (match.players.isNotEmpty) {
      rows.add(playersRow(match.players));
      rows.add(totalScoresRow(match));
    } else {
      rows.add(RoundRow(row: Center(child: Text("Add some players"))));
    }

    for (int r = 0; r < match.rounds.length; r++) {
      String roundLabel = "";
      if (match.game.useRoundLabels()) {
        roundLabel = match.game.roundList[r];
      }
      rows.add(roundScoresRow(match, roundLabel, match.rounds[r]));
    }

    if ((match.showFutureRoundsType() !=
            ShowFutureRoundsType.showNoFutureRounds) &&
        (match.rounds.length >= match.game.roundList.length)) {
      rows.add(endMatchRow(match));
    } else if (match.showFutureRoundsType() ==
        ShowFutureRoundsType.showNextFutureRound) {
      rows.add(
        RoundRow(
          label: match.game.roundList[match.rounds.length],
          row: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Next round is ${match.game.roundList[match.rounds.length]}",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      );
    } else if (match.showFutureRoundsType() ==
        ShowFutureRoundsType.showAllFutureRounds) {
      for (
        int index = match.rounds.length;
        index < match.game.roundList.length;
        index++
      ) {
        rows.add(futureRoundsRow(match, match.game.roundList[index]));
      }
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) {
        Widget label = roundLabelAvatar(
          "",
          Theme.of(context).colorScheme.surface,
        );

        if (match.useRoundLabels()) {
          label = rows[index].label != null
              ? roundLabelAvatar(rows[index].label ?? "", Colors.blue)
              : roundLabelAvatar("", Theme.of(context).colorScheme.surface);
        }

        return Container(
          key: Key("Row $index"),
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.green, width: 1.0)),
          ),
          child: Row(
            children: [
              label,
              Expanded(child: rows[index].row),
            ],
          ),
        );
      },
    );
  }
  //---------------------------------------------------------------

  RoundRow playersRow(List<Player> players) {
    List<Widget> playerNames = [];

    for (Player player in players) {
      debugMsg(
        "playersRow adding ${player.name()} colour ${player.color} to the row",
      );

      playerNames.add(
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(4),
          ),
          builder: (context, controller, child) {
            return InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  player.name(),
                  style: TextStyle(color: player.color, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          menuChildren: [
            MenuItemButton(
              child: Center(child: Text('Change player')),

              onPressed: () async {
                if (await changePlayer(context, match, player)) {
                  saveGameState();
                  //                  setState(() {});
                }
              },
            ),
            MenuItemButton(
              child: Center(child: Text('Change colour')),
              onPressed: () async {
                if (await changePlayerColour(context, player) == true) {
                  saveGameState();
                  //                  setState(() {});
                }

                // setState(() {
                //   changePlayerColour(player);
                // });
              },
            ),
          ],
        ),
      );
    }

        return RoundRow(row: listToRowWithDividers(playerNames));
  }

  //---------------------------------------------------------------

  void saveGameState() {
    final MatchStorage storage = MatchStorage();

    try {
      debugMsg("_ListScreenState changePlayerColour saving game");
      storage.saveMatch(match);
    } catch (e) {
      debugMsg("_ListScreenState changePlayerColour ${e.toString()}", true);
    }
  }

  //---------------------------------------------------------------

  RoundRow totalScoresRow(Match match) {
    List<Widget> totalScoreTexts = [];

    for (int score in match.getTotalScores()) {
      totalScoreTexts.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            score.toString(),
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RoundRow(row: listToRowWithDividers(totalScoreTexts));

  }

  //---------------------------------------------------------------

  RoundRow futureRoundsRow(Match match, String roundLabel) {
    debugMsg("scoresRow");

    // return one row showing a round to come, with the label
    // but no scores

    final round = Round();

    final r = Dismissible(
      key: ValueKey(round.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.zero,

        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDelete(match, round);
      },
      onDismissed: (direction) {
        _deleteRound(match, round);
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        //        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          // leading: match.useRoundLabels()
          //     ? roundLabelAvatar(roundLabel, Colors.grey)
          //     : null,
          title: Text(""),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _editRound(match, round),
        ),
      ),
    );

    return RoundRow(label: roundLabel, row: r);
  }

  //---------------------------------------------------------------

  RoundRow roundScoresRow(Match match, String roundLabel, Round round) {
    debugMsg("roundScoresRow");

    // return one row showing scores for all the players in this round
    // use a Dismissible widget to handle the ontap and
    // slide to delete functions

    return RoundRow(
      label: match.useRoundLabels() ? roundLabel : null,
      row: Dismissible(
        key: ValueKey(roundLabel),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.zero,
          //          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 32),
        ),
        confirmDismiss: (direction) async {
          return await _confirmDelete(match, round);
        },
        onDismissed: (direction) {
          _deleteRound(match, round);
        },
        // Note IntrinsicHeight is needed so the
        // vertical separators display properly
        child: InkWell(
          child: IntrinsicHeight(child: scoresRow2(match, roundLabel, round)),

          onTap: () => _editRound(match, round),
        ),
      ),
    );
  }

  //---------------------------------------------------------------

  Widget roundLabelAvatar(String roundLabel, Color color) {
    return Container(
      width: roundLabelsWidth,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        //      borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        roundLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //---------------------------------------------------------------

  double calculateRoundLabelsWidth(List<String> roundLabels) {
    double maxWidth = 0;

    for (String label in roundLabels) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            //            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }

    debugMsg("calculateRoundLabelsWidth maxWidth $maxWidth");

    // Add padding (15 horizontal padding on each side = 30 total)
    return maxWidth + 30;
  }

  //---------------------------------------------------------------
  Future<dynamic> _confirmDelete(Match match, Round round) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Roudn'),
          content: Text('Are you sure you want to delete ${round.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRound(match, round);
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //------------------------------------------------------------------

  Widget scoresRow2(Match match, String roundLabel, Round round) {
    debugMsg("scoresRow2");


    List<Widget> textItems = [];
    final scoresList = round.getScores();

    for ( var item = 0 ; item < scoresList.length ; item++){  

      textItems.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            scoresList[item].toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }
    return (listToRowWithDividers(textItems));
  }

  //---------------------------------------------------------------

  Widget listToRowWithDividers(List<Widget> textItems) 
  {
    List<Widget> rowChildren = [];

    for ( var item = 0 ; item < textItems.length ; item++) 
    {

      // add dividers, but not straight after the first
      // column with roundlabels
    
      if ( ( match.getPlayerIds().length > 1 ) &
           ( item > 0 ) ) {
          rowChildren.add(
            VerticalDivider(width: 1, thickness: 1, color: Colors.grey)          );
      }

      rowChildren.add(Expanded(child: textItems[item]));
    }


    // for (Widget item in textItems) {
    //   if (item is VerticalDivider) {
    //     rowChildren.add(item);
    //   } else {
    //     rowChildren.add(
    //       Expanded(child: item),
    //       // Expanded(
    //       //   child: Padding(padding: const EdgeInsets.all(14.0), child: item),
    //       // ),
    //     );
    //   }
    // }
    return IntrinsicHeight(child: 
    Row(children: rowChildren));
  }

  //---------------------------------------------------------------

  Future<void> addButtonPressed(BuildContext context) async {
    debugMsg("addButtonPressed ... waiting");

    if (match.game.fixedNumRounds()) {
      if (match.rounds.length >= match.game.roundList.length) {
        // the match has ended - no more round adds!
        showPopupMessage(context, "Match ended - no more scores to add");
        return;
      }
    }

    Round newRound = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRoundScreen(match: match)),
    );
    debugMsg('addButtonPressed result=$newRound');

    setState(() {
      match.addRound(newRound);
    });

    final MatchStorage storage = MatchStorage();
    try {
      debugMsg("_ListScreenState addButtonPressed saving match");
      storage.saveMatch(match);
      debugMsg("match now has ${match.rounds.length} rounds");
    } catch (e) {
      debugMsg("_ListScreenState addButtonPressed ${e.toString()}", true);
    }
  }

  //--------------------------------------------------------------

  void _editRound(Match match, Round round) async {
    final index = match.rounds.indexWhere((r) => r == round);

    debugMsg("editing round index $index");
    debugMsg("num rounds before edit ${match.rounds.length}");

    Round? changedRound = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoundScreen(match: match, currentRound: round),
      ),
    );

    if (changedRound != null) {
      match.rounds[index] = changedRound;

      final MatchStorage storage = MatchStorage();
      try {
        debugMsg("_ListScreenState editRowSlider saving match");
        storage.saveMatch(match);
      } catch (e) {
        debugMsg("_ListScreenState editRowSlider ${e.toString()}", true);
      }

      setState(() {});

      debugMsg("num rounds after edit ${match.rounds.length}");
    }
  }

  //---------------------------------------------------------------

  void _deleteRound(Match match, Round round) {
    debugMsg("deleteRound round $round");

    debugMsg("num rounds before ${match.rounds.length}");

    match.rounds.remove(round);

    debugMsg("num rounds after ${match.rounds.length}");

    final MatchStorage storage = MatchStorage();
    try {
      debugMsg("_ListScreenState deleteRound saving match");
      storage.saveMatch(match);
    } catch (e) {
      debugMsg("_ListScreenState deleteRound ${e.toString()}", true);
    }
    setState(() {});
  }

  //---------------------------------------------------------------

  // void deleteRowSlider(Match match, Round round) {
  //   debugMsg("deleteRowSlider round $round");

  //   debugMsg("num rounds before ${match.rounds.length}");

  //   match.rounds.remove(round);

  //   debugMsg("num rounds after ${match.rounds.length}");

  //   final MatchStorage storage = MatchStorage();
  //   try {
  //     debugMsg("_ListScreenState deleteRowSlider saving match");
  //     storage.saveMatch(match);
  //   } catch (e) {
  //     debugMsg("_ListScreenState deleteRowSlider ${e.toString()}", true);
  //   }
  //   setState(() {});
  // }

  //---------------------------------------------------------------

  // Future<void> editRowSlider(Match match, Round round) async {
  //   debugMsg("editRowSlider round $round");

  //   final index = match.rounds.indexWhere((r) => r == round);

  //   debugMsg("editing round index $index");
  //   debugMsg("num rounds before edit ${match.rounds.length}");

  //   Round changedRound = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddRoundScreen(match: match, currentRound: round),
  //     ),
  //   );

  //   match.rounds[index] = changedRound;

  //   final MatchStorage storage = MatchStorage();
  //   try {
  //     debugMsg("_ListScreenState editRowSlider saving match");
  //     storage.saveMatch(match);
  //   } catch (e) {
  //     debugMsg("_ListScreenState editRowSlider ${e.toString()}", true);
  //   }

  //   setState(() {});

  //   debugMsg("num rounds after edit ${match.rounds.length}");
  // }

  //---------------------------------------------------------------

  RoundRow endMatchRow(Match match) {
    List<Player> winningPlayers = match.getWinningPlayers();

    String winnerText;
    if (winningPlayers.length == 1) {
      winnerText = "The End - ${winningPlayers[0].name()} has won!";
    } else {
      winnerText = "The End - a draw!";
    }

    return RoundRow(row: Text(winnerText, style: TextStyle(fontSize: 24)));
  }

  //---------------------------------------------------------------

  static const bnbNumPlayers = 0;
  static const bnbMatchEnd = 1;
  static const bnbClear = 2;

  BottomNavigationBar bottomNavigationBar(Match match) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
        BottomNavigationBarItem(icon: Icon(Icons.save), label: 'The End'),
        BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Clear'),
      ],
      currentIndex: _bnbSelectedIndex,
      selectedItemColor: Colors.blue,
      onTap: ((int index) {
        setState(() {
          _onItemTapped(index, match);
        });
      }),
    );
  }

  //---------------------------------------------------------------

  void _onItemTapped(int index, Match match) async {
    debugMsg("_onItemTapped index $index");

    switch (index) {
      case bnbNumPlayers:
        debugMsg("calling showNumberPicker");

        int? selectedNumber = await showNumberPicker(context);

        if (selectedNumber == null) return;

        debugMsg("selectedNumber $selectedNumber");

        if (selectedNumber != match.numPlayers()) {
          match = await changeNumPlayers(match, selectedNumber);
        }

      case bnbMatchEnd:
        debugMsg("calling MyUtils.showDialogBox 1");

        MyMixin.showDialogBox(
          context,
          "End Match",
          "Confirm",
          "Cancel",
        ).then<int>((var r) {
          debugMsg("showDialogBox returned $r");
          if (r == 1) {
            debugMsg("calling resetScores");
            setState(() async {
              // game.record();
              // game.resetScores();

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EndMatchScreen(match: match),
                ),
              );
            });
          }
          return r;
        });

      case bnbClear:
        debugMsg("calling MyUtils.showDialogBox 2");

        MyMixin.showDialogBox(
          context,
          "Clear scores?",
          "Confirm",
          "Cancel",
        ).then<int>((var r) {
          debugMsg("showDialogBox returned $r");
          if (r == 1) {
            debugMsg("calling resetScores");

            setState(() {
              match.resetScores();
            });
          }
          return r;
        });

        break;
      default:
    }
    setState(() {
      _bnbSelectedIndex = index;
    });
  }

  //---------------------------------------------------------------

  Future<int?> showNumberPicker(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Number of players'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 8,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${index + 1}'),
                  onTap: () {
                    debugMsg("onTap index $index");
                    Navigator.of(context).pop(index + 1);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  //---------------------------------------------------------------

  Future<bool> changePlayer(
    BuildContext context,
    Match match,
    Player oldPlayer,
  ) async {
    debugMsg("changePlayer oldPlayer $oldPlayer");

    final playerRespository = PlayerRepository();
    List<Player> allPlayersList = await playerRespository.getAllPlayers();

    // remove the existing players

    for (Player p in match.players) {
      allPlayersList.removeWhere((player) => player.name() == p.name());
    }

    if (context.mounted) {
      int? newPlayerIndex = await showPlayerPicker(context, allPlayersList);

      if (newPlayerIndex == null) {
        return false;
      }

      if (oldPlayer.name() == allPlayersList[newPlayerIndex].name()) {
        return false;
      }

      match.replacePlayer(oldPlayer, allPlayersList[newPlayerIndex]);
    }
    return true;
  }

  //---------------------------------------------------------------

  Future<int?> showPlayerPicker(
    BuildContext context,
    List<Player> playersList,
  ) async {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a player'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playersList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    playersList[index].name(),
                    style: TextStyle(color: playersList[index].color),
                  ),
                  onTap: () {
                    debugMsg("showPlayerPicker onTap index $index");
                    Navigator.of(context).pop(index);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  //---------------------------------------------------------------

  Future<Match> changeNumPlayers(Match match, int newNumPlayers) async {
    debugMsg("changeNumPlayers newNumPlayers $newNumPlayers");

    match.clear();

    Match savedMatch =
        await loadMatchData(match.name, newNumPlayers) ??
        Match.name(match.name);

    if (savedMatch.numPlayers() == 0) {
      final playerRespository = PlayerRepository();
      List<Player> allPlayers = await playerRespository.getAllPlayers();

      if (mounted) {
        final newPlayers = await showPlayerSelectionDialog(
          context,
          allPlayers,
          newNumPlayers,
        );

        debugMsg("new players selected $newPlayers");

        if (newPlayers.isEmpty) {
          return match;
        }

        // there's no saved match, so initialise
        debugMsg("initilising new players $newPlayers");
        match.addPlayers(newPlayers);
      }
    } else {
      debugMsg("using saved match data");
      match.setPlayers(savedMatch.players);
      debugMsg("m2 match $match");
      match.setRounds(savedMatch.rounds);
      debugMsg("m3 match $match");
    }
    debugMsg("m4 match $match");

    debugMsg("at the end match $match");

    return match;
  }

  //---------------------------------------------------------------

  Future<List<Player>> showPlayerSelectionDialog(
    BuildContext context,
    List<Player> allPlayers,
    int numPlayersRequired,
  ) async {
    List<Player> selectedPlayers = [];

    return await showDialog<List<Player>>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                final canConfirm = selectedPlayers.length == numPlayersRequired;

                return AlertDialog(
                  title: Text('Select $numPlayersRequired Players'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected: ${selectedPlayers.length} / $numPlayersRequired',
                        style: TextStyle(
                          color: canConfirm ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: allPlayers.map((player) {
                              final isSelected = selectedPlayers.contains(
                                player,
                              );
                              return CheckboxListTile(
                                title: Text(player.name()),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedPlayers.add(player);
                                    } else {
                                      selectedPlayers.remove(player);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: (() {
                        selectedPlayers.clear();
                        Navigator.pop(context, selectedPlayers);
                      }),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: canConfirm
                          ? () => Navigator.pop(context, selectedPlayers)
                          : null,
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        [];
  }

  //---------------------------------------------------------------

  Future<Match?> loadMatchData(String matchName, int numPlayers) async {
    debugMsg("_ScoresState loadMatchData");
    final MatchStorage storage = MatchStorage();

    Match match = Match();

    try {
      match = await storage.loadMatch(matchName, numPlayers);

      debugMsg("Match at this point is ${match.toString()}");
    } catch (e) {
      debugMsg("_ScoresState loadMatchData ${e.toString()}", true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return match;
  }

  //-----------------------------------------------------------------
}

class RoundRow {
  final String? label; // null if no leading number
  final Widget row; // The actual row content

  RoundRow({this.label, required this.row});
}

//-----------------------------------------------------------------
