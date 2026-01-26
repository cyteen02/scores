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
import 'package:scores/business/services/match_stats_service.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/location.dart';
import 'package:scores/data/models/player_set.dart';
import 'package:scores/data/models/round_label.dart';
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/data/repositories/location_repository.dart';

import 'package:scores/data/repositories/match_repository.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/data/repositories/player_repository.dart';
import 'package:scores/data/repositories/player_set_repository.dart';
import 'package:scores/presentation/dialogs/pick_location_dialog.dart';

import 'package:scores/presentation/dialogs/reorder_players_list.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/presentation/dialogs/pick_multiple_players_dialog.dart';
import 'package:scores/presentation/dialogs/pick_num_players.dart';
import 'package:scores/presentation/dialogs/pick_one_player_dialog.dart';
import 'package:scores/presentation/screens/end_match_screen.dart';
import 'package:scores/presentation/screens/next_round_screen.dart';
import 'package:scores/presentation/widgets/list_rounds_bottom_nav_bar.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/round.dart';
import 'package:scores/presentation/screens/add_round_screen.dart';
import 'package:scores/data/services/match_storage.dart';

//---------------------------------------------------------------

class ListRounds extends StatefulWidget {
  const ListRounds({
    super.key,
    required this.match,
    required this.matchRepository,
    required this.gameRepository,
    required this.playerSetRepository,
    required this.locationRepository,
    required this.matchStatsRepository,
  });

  final Match match;
  final MatchRepository matchRepository;
  final GameRepository gameRepository;
  final PlayerSetRepository playerSetRepository;
  final LocationRepository locationRepository;
  final MatchStatsRepository matchStatsRepository;

  @override
  State<ListRounds> createState() => _ListRoundsState();
}

//---------------------------------------------------------------

// each row on the screen is a round in the match
// build the rows with this class
// This helps keep the labels separate from the row data
class RoundRow {
  final RoundLabel? roundLabel; // null if no leading number
  final Widget row; // The actual row content

  RoundRow({this.roundLabel, required this.row});
}

//-----------------------------------------------------------------

class _ListRoundsState extends State<ListRounds> with MyMixin {
  bool isLoading = true;
  late Match match;
  late Game game;
  late MatchRepository matchRepository;
  late GameRepository gameRepository;
  late PlayerSetRepository playerSetRepository;
  late LocationRepository locationRepository;
  late MatchStatsRepository matchStatsRepository;

  double roundLabelsWidth = 0.0;

  List<Location> locations = [];

  //---------------------------------------------------------------------------

  @override
  void initState() {
    debugMsg("initState", box: true);
    super.initState();

    debugMsg("copying repositories");
    matchRepository = widget.matchRepository;
    gameRepository = widget.gameRepository;
    playerSetRepository = widget.playerSetRepository;
//   locationRepository = widget.locationRepository;
    matchStatsRepository = widget.matchStatsRepository;

    debugMsg("initState widget.match ${widget.match}");
    match = widget.match; // Copy to local state
    debugMsg("starting match.game ${match.game.toString()}");

    //    game = Game.name(match.name);

    // If fixed length, but no rounds set up yet - do this now
    if ((match.game.gameLengthType == GameLengthType.fixedLength) &&
        (match.numRoundsPlayed() == 0)) {
      match.initAllRounds();
    }

    debugMsg("starting match.game ${match.game.toString()}");
    if (match.useRoundLabels()) {
      roundLabelsWidth = calculateRoundLabelsWidth(match.game.roundLabels);
    } else {
      debugMsg("not using round labels");
    }  
  }

  //---------------------------------------------------------------

  @override
  void dispose() {
    debugMsg("_ListRoundsState dispose");

    saveMatchState();

    super.dispose();
  }
  //---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //     if (isLoading) {
    //   return CircularProgressIndicator();
    // }
    // ignore: no_leading_underscores_for_local_identifiers
    int _bottomNavBarSelection = 0;

    String title = match.location == null
        ? match.name
        : "${match.name} @ ${match.location?.name}";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () async {
              await _loadLocations();
              Location? result = await showLocationPickerDialog(context, locations);
              if (result?.name == 'NONE') {
                setState(() {
                  match.location = null;
                });
              } else if (result != null) {
                setState(() {
                  match.location = result;
                });
              }
            },
          ),
        ],
      ),
      body: Container(child: listRounds(context)),
      floatingActionButton:
          match.game.gameLengthType == GameLengthType.fixedLength
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (match.numPlayers() > 0 && !match.matchFinished()) {
                  addButtonPressed(context);
                }
              },
              backgroundColor: match.numPlayers() > 0 && !match.matchFinished()
                  ? Colors.blue
                  : Colors.grey,
              child: Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: ListRoundsBottomNavBar(
        currentIndex: _bottomNavBarSelection,
        onItemTapped: _bottomNavBarOnTapped,
        match: match,
      ),
    );
  }

  //---------------------------------------------------------------

  Widget listRounds(BuildContext context) {
    debugMsg("listRounds match $match");

    // Build a list of rows to display
    List<RoundRow> rows = [];

    if (match.players.isNotEmpty) {
      rows.add(playersRow(context, match.players));
    } else {
      rows.add(RoundRow(row: Center(child: Text("Add some players"))));
    }

    for (int r = 0; r < match.rounds.length; r++) {
      RoundLabel? roundLabel;
      if (match.game.useRoundLabels()) {
        roundLabel = match.game.roundLabels[r];
      }
      rows.add(roundScoresRow(context, roundLabel, match.rounds[r]));
    }

    if ((match.showFutureRoundsType() !=
            ShowFutureRoundsType.showNoFutureRounds) &&
        (match.rounds.length >= match.game.roundLabels.length) &&
        (match.game.gameLengthType != GameLengthType.fixedLength)) {
      rows.add(endMatchRow());
    } else if ( (match.showFutureRoundsType() ==
        ShowFutureRoundsType.showNextFutureRound) && 
        (match.rounds.length < match.game.roundLabels.length)) {
      rows.add(
        RoundRow(
          roundLabel: match.game.roundLabels[match.rounds.length],
          row: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: InkWell(
                onTap: showNextRoundScreen,
                child: Text(
                  "Next round is ${match.game.roundLabels[match.rounds.length].name}",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (match.showFutureRoundsType() ==
        ShowFutureRoundsType.showAllFutureRounds) {
      for (
        int index = match.rounds.length;
        index < match.game.roundLabels.length;
        index++
      ) {
        rows.add(futureRoundsRow(context, match.game.roundLabels[index]));
      }
    }

    if (match.players.isNotEmpty) {
      rows.add(RoundRow(row: SizedBox(height: 30)));
      rows.add(totalScoresRow());
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (BuildContext newContext, int index) {
        Widget label;
        if (match.useRoundLabels()) {
          label = roundLabelAvatar(
            context: newContext,
            roundLabel: rows[index].roundLabel,
          );
        } else {
          label = roundLabelAvatar(context: newContext);
        }

        return Container(
          key: Key("Row $index"),
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
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

  RoundRow playersRow(BuildContext context, List<Player> players) {
    List<Widget> playerNames = [];

    for (Player player in players) {
      debugMsg(
        "playersRow adding ${player.name} colour ${player.color} to the row",
      );

      playerNames.add(
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(4),
          ),
          builder: (BuildContext newContext, controller, child) {
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
                  player.name,
                  style: TextStyle(color: player.color.toColor(), fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          menuChildren: [
            MenuItemButton(
              child: Center(child: Text('Change player')),

              onPressed: () async {
                if (await changePlayer(context, player)) {
                  setState(() {
                    saveMatchState();
                  });
                }
              },
            ),
            MenuItemButton(
              child: Center(child: Text('Reorder players')),
              onPressed: () async {
                final newOrder = await showReorderPlayersDialog(
                  context,
                  players,
                );
                if (newOrder != null) {
                  setState(() => match.replacePlayers(newOrder));
                }
              },
            ),
          ],
        ),
      );
    }

    return RoundRow(row: listToRowWithDividers(playerNames));
  }

  //---------------------------------------------------------------

  void saveMatchState() {
    final MatchStorage storage = MatchStorage();

    try {
      debugMsg("_ListScreenState saveMatchState saving game");
      storage.saveMatch(match);
    } catch (e) {
      debugMsg("_ListScreenState saveMatchState ${e.toString()}", box: true);
    }
  }

  //---------------------------------------------------------------

  RoundRow totalScoresRow() {
    List<Widget> totalScoreTexts = [];

    for (int score in getTotalScores(match)) {
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

  RoundRow futureRoundsRow(BuildContext context, RoundLabel roundLabel) {
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
        return await _confirmDelete(context, round);
      },
      onDismissed: (direction) {
        _deleteRound(round);
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
          onTap: () => _editRound(context, round),
        ),
      ),
    );

    return RoundRow(roundLabel: roundLabel, row: r);
  }

  //---------------------------------------------------------------

  RoundRow roundScoresRow(
    BuildContext context,
    RoundLabel? roundLabel,
    Round round,
  ) {
    debugMsg("roundScoresRow");

    // return one row showing scores for all the players in this round
    // use a Dismissible widget to handle the ontap and
    // slide to delete functions

    return RoundRow(
      roundLabel: roundLabel,
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
          return await _confirmDelete(context, round);
        },
        onDismissed: (direction) {
          _deleteRound(round);
        },
        // Note IntrinsicHeight is needed so the
        // vertical separators display properly
        child: InkWell(
          child: IntrinsicHeight(child: scoresRow2(round)),

          onTap: () => _editRound(context, round),
        ),
      ),
    );
  }

  //---------------------------------------------------------------

  Widget roundLabelAvatar({
    required BuildContext context,
    RoundLabel? roundLabel,
  }) {
    Color labelColor;
    String labelText = "";
    if (roundLabel == null) {
      labelColor = Theme.of(context).colorScheme.surface;
    } else {
      labelColor = roundLabel.color.toColor();
      labelText = roundLabel.name;
    }

    return Container(
      width: roundLabelsWidth,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: labelColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        //      borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        labelText,
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

  double calculateRoundLabelsWidth(List<RoundLabel> roundLabels) {
    double maxWidth = 0;

    for (RoundLabel label in roundLabels) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label.name,
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

  Future<dynamic> _confirmDelete(BuildContext context, Round round) async {
    return await MyMixin.showDialogBox(
          context,
          "Delete round?",
          "Confirm",
          "Cancel",
        ) ==
        1;
  }

  //---------------------------------------------------------------

  // Future<dynamic> _confirmDelete3(
  //   BuildContext context,
  //   Match match,
  //   Round round,
  // ) async {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext newContext) {
  //       return AlertDialog(
  //         title: const Text('Delete Round'),
  //         content: Text('Are you sure you want to delete ${round.id}?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(newContext).pop(),
  //             child: const Text('CANCEL'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(newContext).pop();
  //               _deleteRound(match, round);
  //             },
  //             child: const Text('DELETE', style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //------------------------------------------------------------------

  Widget scoresRow2(Round round) {
    debugMsg("scoresRow2");

    List<Widget> textItems = [];
    final scoresList = round.getPlayersScores(match.players);

if ( scoresList.isEmpty ) {
    textItems.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("",


            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    
}

    for (var item = 0; item < scoresList.length; item++) {
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

  Widget listToRowWithDividers(List<Widget> textItems) {
    List<Widget> rowChildren = [];

    for (var item = 0; item < textItems.length; item++) {
      // add dividers, but not straight after the first
      // column with roundlabels

      if ((match.getPlayerIds().length > 1) & (item > 0)) {
        rowChildren.add(
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
        );
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
    return IntrinsicHeight(child: Row(children: rowChildren));
  }

  //---------------------------------------------------------------

  Future<void> addButtonPressed(BuildContext context) async {
    debugMsg("addButtonPressed ... waiting");

    if (match.game.fixedNumRounds()) {
      if (match.rounds.length >= match.game.roundLabels.length) {
        // the match has ended - no more round adds!
        showPopupMessage(context, "Match ended - no more scores to add");
        return;
      }
    }

    Round? newRound = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRoundScreen(match: match)),
    );
    debugMsg('addButtonPressed result=$newRound');

    if (newRound == null) {
      return;
    }

    setState(() {
      match.addRound(newRound);
    });

    final MatchStorage storage = MatchStorage();
    try {
      debugMsg("_ListScreenState addButtonPressed saving match");
      storage.saveMatch(match);
      debugMsg("match now has ${match.rounds.length} rounds");
    } catch (e) {
      debugMsg("_ListScreenState addButtonPressed ${e.toString()}", box: true);
    }
  }

  //--------------------------------------------------------------

  void _editRound(BuildContext context, Round round) async {
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
        debugMsg("_ListScreenState editRowSlider ${e.toString()}", box: true);
      }

      setState(() {});

      debugMsg("num rounds after edit ${match.rounds.length}");
    }
  }

  //---------------------------------------------------------------

  void _deleteRound(Round round) {
    debugMsg("deleteRound round $round");

    debugMsg("num rounds before ${match.rounds.length}");

    match.rounds.remove(round);

    debugMsg("num rounds after ${match.rounds.length}");

    final MatchStorage storage = MatchStorage();
    try {
      debugMsg("_ListScreenState deleteRound saving match");
      storage.saveMatch(match);
    } catch (e) {
      debugMsg("_ListScreenState deleteRound ${e.toString()}", box: true);
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

  RoundRow endMatchRow() {
    List<Player> winningPlayers = getWinningPlayers(match);

    String winnerText;
    if (winningPlayers.length == 1) {
      winnerText = "The End - ${winningPlayers[0].name} has won!";
    } else {
      winnerText = "The End - a draw!";
    }

    return RoundRow(row: Text(winnerText, style: TextStyle(fontSize: 24)));
  }

  //---------------------------------------------------------------

  void showNextRoundScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextRoundScreen(
          match: match,
          nextRoundLabel: match.game.roundLabels[match.rounds.length],
        ),
      ),
    );
  }

  //---------------------------------------------------------------
  // static const bnbNumPlayers = 0;
  // static const bnbMatchEnd = 1;
  // static const bnbClear = 2;

  // BottomNavigationBar bottomNavigationBar(BuildContext context, match) {
  //   return BottomNavigationBar(
  //     items: const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
  //       BottomNavigationBarItem(icon: Icon(Icons.save), label: 'The End'),
  //       BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Clear'),
  //     ],
  //     currentIndex: _bnbSelectedIndex,
  //     selectedItemColor: Colors.blue,
  //     onTap: ((int index) {
  //       setState(() {
  //         _bottomNavBarOnTapped(context, index, match);
  //       });
  //     }),
  //   );
  // }

  //---------------------------------------------------------------

  void _bottomNavBarOnTapped(
    BuildContext context,
    int index,
    Match oldMatch,
  ) async {
    debugMsg("_onItemTapped index $index");

    ListRoundsBottomNavBarEnum buttonTapped =
        ListRoundsBottomNavBarEnum.values[index];

    switch (buttonTapped) {
      case ListRoundsBottomNavBarEnum.players:
        debugMsg("calling pickNumPlayers");

        Match? newMatch = await playersButtonTapped();
        if (newMatch != null) {
          setState(() {
            match = newMatch.copyWith(
              id: newMatch.id,
              game: newMatch.game,
              playerSet: newMatch.playerSet,
              rounds: newMatch.rounds,
            );
            debugMsg("after playersButtonTapped match: $match");
          });
        }

      case ListRoundsBottomNavBarEnum.end:
        debugMsg("calling MyUtils.showDialogBox 1");

        MyMixin.showDialogBox(
          context,
          "End Match",
          "Confirm",
          "Cancel",
        ).then<int>((var r) {
          debugMsg("showDialogBox returned $r");
          if (r == 1) {
            debugMsg("go to EndMatchScreen");
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EndMatchScreen(
                    match: match,
                    matchRepository: matchRepository,
                    matchStatsRepository: matchStatsRepository,
                  ),
                ),
              );
            }
          }
          return r;
        });

      case ListRoundsBottomNavBarEnum.clear:
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
              resetMatch(context);
            });
          }
          return r;
        });

        break;
    }
    // setState(() {
    //   _bnbSelectedIndex = index;
    // });
  }

  //---------------------------------------------------------------

  // Future<int?> showNumberPicker(BuildContext context) async {

  //   return showDialog<int>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Number of players'),
  //         content: SizedBox(
  //           width: double.minPositive,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: 8,
  //             itemBuilder: (context, index) {
  //               return ListTile(
  //                 title: Text('${index + 1}'),
  //                 onTap: () {
  //                   debugMsg("onTap index $index");
  //                   Navigator.of(context).pop(index + 1);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //---------------------------------------------------------------

  Future<bool> resetMatch(BuildContext context) async {
    // Reload the game defintion and reset the scores

    match.game = await gameRepository.getGameByName(match.game.name);

    PlayerSet? loadedPlayerSet = await playerSetRepository.getById(
      match.playerSet.id ?? 0,
    );
    if (loadedPlayerSet != null) {
      match.playerSet = loadedPlayerSet;
    }

    match.resetScores();

    return true;
  }

  //---------------------------------------------------------------

  Future<bool> changePlayer(BuildContext context, Player oldPlayer) async {
    debugMsg("changePlayer oldPlayer $oldPlayer");

    final playerRespository = PlayerRepository();
    List<Player> allPlayersList = await playerRespository.getAllPlayers();

    // remove the existing players from the list to pick from
    for (Player p in match.players) {
      allPlayersList.removeWhere((player) => player.name == p.name);
    }

    if (context.mounted) {
      int? newPlayerIndex = await pickOnePlayer(context, allPlayersList);

      if (newPlayerIndex == null) {
        return false;
      }

      if (oldPlayer.name == allPlayersList[newPlayerIndex].name) {
        return false;
      }

      debugMsg("newPlayer is ${allPlayersList[newPlayerIndex]}");

      match.replacePlayer(oldPlayer, allPlayersList[newPlayerIndex]);
    }
    return true;
  }

  //---------------------------------------------------------------

  // Future<int?> showPlayerPicker(
  //   BuildContext context,
  //   List<Player> playersList,
  // ) async {
  //   return showDialog<int>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Pick a player'),
  //         content: SizedBox(
  //           width: double.minPositive,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: playersList.length,
  //             itemBuilder: (context, index) {
  //               return ListTile(
  //                 title: Text(
  //                   playersList[index].name(),
  //                   style: TextStyle(color: playersList[index].color),
  //                 ),
  //                 onTap: () {
  //                   debugMsg("showPlayerPicker onTap index $index");
  //                   Navigator.of(context).pop(index);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //---------------------------------------------------------------

  Future<Match?> playersButtonTapped() async {
    debugMsg("calling pickNumPlayers");

    int newNumPlayers = await pickNumPlayers(context) ?? 0;

    if ((newNumPlayers == 0) || (newNumPlayers == match.numPlayers())) {
      return null;
    }

    Match? savedMatch = await loadMatchData(match.game.name, newNumPlayers);

    if (savedMatch != null) {
      debugMsg("using saved match data");

      Match newMatch = match.copyWith(
        id: savedMatch.id,
        game: savedMatch.game,
        playerSet: savedMatch.playerSet,
        rounds: savedMatch.rounds,
      );

      return newMatch;
    }

    debugMsg("no saved match data");

    // otherwise get the user to pick new players
    // and set up a new match

    final playerRespository = PlayerRepository();
    List<Player> allPlayers = await playerRespository.getAllPlayers();

    List<Player> newPlayers = await pickMultiplePlayersDialog(
      context,
      allPlayers,
      newNumPlayers,
    );

    debugMsg("new players selected $newPlayers");

    if (newPlayers.isEmpty) {
      return null;
    }

    debugMsg("initilising playerSet $newPlayers");

    // does a playerSet exist for these players?

    PlayerSet playerSet = PlayerSet(players: newPlayers);
    List<int> newPlayerIds = newPlayers.map((p) => p.id).toList();

    int playerSetId = await playerSetRepository
        .getPlayerSetContainingAllPlayers(newPlayerIds);

    if (playerSetId > 0) {
      playerSet.id = playerSetId;
    }

    Match newMatch = match.copyWith(
      id: match.id,
      game: match.game,
      playerSet: playerSet,
    );

    //    newMatch.initFirstRound();

    debugMsg("newMatch $newMatch");

    return newMatch;
  }

  //---------------------------------------------------------------------------

  // Future<Match?> changeNumPlayersOLD(
  //   BuildContext context,
  //   match,
  //   int newNumPlayers,
  // ) async {
  //   debugMsg("changeNumPlayers newNumPlayers $newNumPlayers");

  //   // see if there's a previous match with the new num players
  //   // if so - just use this
  //   Match? savedMatch =
  //       await loadMatchData(match.name, newNumPlayers);

  //   if ( savedMatch != null ) {

  //     debugMsg("using saved match data");

  //   match.clear();

  //     match.copyWith(id: savedMatch.id,
  //           game: savedMatch.game,
  //           playerSet: savedMatch.playerSet,
  //           rounds: savedMatch.rounds );

  //     return match;
  //   }

  //   debugMsg("no saved match data");

  //   // otherwise get the user to pick new players
  //   // and set up a new match

  //   final playerRespository = PlayerRepository();
  //   List<Player> allPlayers = await playerRespository.getAllPlayers();

  //   if (context.mounted) {
  //     final newPlayers = await pickMultiplePlayersDialog(
  //       context,
  //       allPlayers,
  //       newNumPlayers,
  //     );

  //     debugMsg("new players selected $newPlayers");

  //     if (newPlayers.isEmpty) {
  //       return match;
  //     }

  //     debugMsg("initilising playerSet $newPlayers");

  //     // does a playerSet exist for these players?

  //     PlayerSet playerSet = PlayerSet(players: newPlayers);
  //     int playerSetId = playerSetRepository.getPlayerSetContainingAllPlayers(
  //       newPlayers.map((p) => p.id).toList());

  //     if ( playerSetId > 0 ) {
  //       playerSet.id = playerSetId;
  //     }

  //     match.playerSet = playerSet;
  //   }

  //   debugMsg("at the end of changeNumPlayers match is $match");

  //   return match;
  // }

  //---------------------------------------------------------------

  // Future<List<Player>> showPlayerSelectionDialog(
  //   BuildContext context,
  //   List<Player> allPlayers,
  //   int numPlayersRequired,
  // ) async {
  //   List<Player> selectedPlayers = [];

  //   return await showDialog<List<Player>>(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return StatefulBuilder(
  //             builder: (context, setState) {
  //               final canConfirm = selectedPlayers.length == numPlayersRequired;

  //               return AlertDialog(
  //                 title: Text('Select $numPlayersRequired Players'),
  //                 content: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(
  //                       'Selected: ${selectedPlayers.length} / $numPlayersRequired',
  //                       style: TextStyle(
  //                         color: canConfirm ? Colors.green : Colors.grey,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     SizedBox(height: 10),
  //                     Expanded(
  //                       child: SingleChildScrollView(
  //                         child: Column(
  //                           children: allPlayers.map((player) {
  //                             final isSelected = selectedPlayers.contains(
  //                               player,
  //                             );
  //                             return CheckboxListTile(
  //                               title: Text(player.name()),
  //                               value: isSelected,
  //                               onChanged: (bool? value) {
  //                                 setState(() {
  //                                   if (value == true) {
  //                                     selectedPlayers.add(player);
  //                                   } else {
  //                                     selectedPlayers.remove(player);
  //                                   }
  //                                 });
  //                               },
  //                             );
  //                           }).toList(),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: (() {
  //                       selectedPlayers.clear();
  //                       Navigator.pop(context, selectedPlayers);
  //                     }),
  //                     child: Text('Cancel'),
  //                   ),
  //                   TextButton(
  //                     onPressed: canConfirm
  //                         ? () => Navigator.pop(context, selectedPlayers)
  //                         : null,
  //                     child: Text('OK'),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         },
  //       ) ??
  //       [];
  // }

  //---------------------------------------------------------------

  Future<Match?> loadMatchData(String gameName, int numPlayers) async {
    debugMsg("_ScoresState loadMatchData");
    final MatchStorage storage = MatchStorage();

    Match? match;

    try {
      match = await storage.loadMatch(gameName, numPlayers);

      debugMsg("Match at this point is ${match.toString()}");
    } catch (e) {
      debugMsg("_ScoresState loadMatchData ${e.toString()}", box: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return match;
  }

  //-----------------------------------------------------------------

  Future<void> _loadLocations() async {
    locations = await widget.locationRepository.getAll();
    setState(() {});
  }
  //---------------------------------------------------------------------------
  
}
