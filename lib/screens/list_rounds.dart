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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//import 'package:flutter/widget_previews.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scores/mixin/my_utils.dart';

import 'package:scores/models/game.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:scores/screens/add_round_screen.dart';
import 'package:scores/services/game_storage.dart';

//---------------------------------------------------------------

class ListRounds extends StatefulWidget {
  const ListRounds({super.key, required this.game});
  final Game game;

  @override
  State<ListRounds> createState() => _ListRoundsState();
}

//---------------------------------------------------------------

class _ListRoundsState extends State<ListRounds> with MyUtils {
  bool isLoading = true;
  int _bnbSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //     if (isLoading) {
    //   return CircularProgressIndicator();
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('We are playing ${widget.game.name}'),
        centerTitle: true,
      ),
      body: Container(child: scoresList(widget.game)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addButtonPressed(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: bottomNavigationBar(widget.game),
    );
  }

  //---------------------------------------------------------------

  //  @Preview(name: 'My Sample Text')
  Widget scoresList(Game game) {
    debugMsg("scoresList game $game");
    List<Widget> rows = [];

    rows.add(playersRow(game.players));

    rows.add(totalScoresRow(game));

    for (var round in game.rounds) {
      rows.add(scoresRow(game, round));
    }

    return Center(
      child: ListView(padding: const EdgeInsets.all(8), children: rows),
    );
  }

  //---------------------------------------------------------------

  Widget playersRow(List<Player> players) {
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
          builder: (context, controller, child) {
            return InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Text(
                player.name,
                style: TextStyle(color: player.color, fontSize: 30),
                textAlign: TextAlign.center,
              ),
            );
          },
          menuChildren: [
            MenuItemButton(
              child: Center(child: Text('Change name')),
              onPressed: () {
                setState(() {
                  changePlayerName(player);
                });
              },
            ),
            MenuItemButton(
              child: Center(child: Text('Change colour')),
              onPressed: () {
                setState(() {
                  changePlayerColour(player);
                });
              },
            ),
          ],
        ),
      );
    }

    return widgetRow(playerNames);
  }

  //---------------------------------------------------------------

  void changePlayerName(Player player) async {
    debugMsg("changePlayerName $player");

    final name = await changeNameDialog(context);

    if (name != null && name.isNotEmpty) {
      debugMsg('Name entered: $name');
      player.setName(name);
      // Do something with the name
    } else {
      debugMsg('Dialog cancelled or empty name');
    }

    debugMsg("Game is now ${widget.game}");

    setState(() {});
  }

  //---------------------------------------------------------------

  Future<String?> changeNameDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Name'),
          
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(
                    context,
                  ).pop(controller.text); // Or whatever you need to do
                }
              },              
              validator: (value) {
                debugMsg("Checking $value");
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                if (widget.game.playerNameExists(value)) {
                  return 'Sorry $value is already a player';
                }

                return null;
              },
            ),
          ),
          
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(
                    context,
                  ).pop(controller.text); // Or whatever you need to do
                }
              },
            ),
          ],
        );
      },
    );
  }

  //---------------------------------------------------------------

  void changePlayerColour(Player player) async {
    debugMsg("changePlayerColour $player");
    Color? newColour = await showColorPickerDialog(
      context,
      initialColor: player.color,
    );
    debugMsg("newColor $newColour");
    if (newColour != null) {
      setState(() {
        player.setColor(newColour);
      });

      final GameStorage storage = GameStorage();
      try {
        debugMsg("_ListScreenState changePlayerColour saving game");
        storage.saveGame(widget.game);
      } catch (e) {
        debugMsg("_ListScreenState changePlayerColour ${e.toString()}", true);
      }
    }
  }

  //---------------------------------------------------------------

  Future<Color?> showColorPickerDialog(
    BuildContext context, {
    Color initialColor = Colors.blue,
  }) async {
    Color selectedColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              //              paletteType: PaletteType.hsv,
              displayThumbColor: false,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedColor),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
  //---------------------------------------------------------------

  Widget totalScoresRow(Game game) {
    List<Text> totalScoreTexts = [];

    for (int score in game.getTotalScores()) {
      totalScoreTexts.add(
        Text(
          score.toString(),
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }
    return widgetRow(totalScoreTexts);
  }

  //---------------------------------------------------------------

  Widget scoresRow(Game game, Round round) {
    List<Text> textItems = [];

    for (var item in round.getScores()) {
      textItems.add(
        Text(
          item.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return (slider(game, round, widgetRow(textItems)));
  }

  //---------------------------------------------------------------

  Widget widgetRow(List<Widget> textItems) {
    List<Widget> rowChildren = [];

    for (Widget item in textItems) {
      rowChildren.add(
        Expanded(
          child: Padding(padding: const EdgeInsets.all(14.0), child: item),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey,
            style: BorderStyle.solid,
          ), //BorderSide
        ), //Border
      ), //BoxDecoration

      child: Row(children: rowChildren),
    );
  }

  //---------------------------------------------------------------

  Widget slider(Game game, Round round, Widget row) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      //  key: const ValueKey(0),

      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        //    dismissible: DismissiblePane(onDismissed: () {}),

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (context) {
              deleteRowSlider(game, round);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              editRowSlider(game, round);
            },
            backgroundColor: Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: row,
      //      child: const ListTile(title: Text('Slide me')),
    );
  }

  //---------------------------------------------------------------

  Future<void> addButtonPressed(BuildContext context) async {
    debugMsg("addButtonPressed ... waiting");

    Round newRound = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoundScreen(game: widget.game),
      ),
    );
    debugMsg('addButtonPressed result=$newRound');

    widget.game.addRound(newRound);

    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState addButtonPressed saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState addButtonPressed ${e.toString()}", true);
    }

    // Update UI or handle the returned data
    //    widget.game.addRound(newRound);

    setState(() {});
  }

  //---------------------------------------------------------------

  void deleteRowSlider(Game game, Round round) {
    debugMsg("deleteRowSlider round $round");

    debugMsg("num rounds before ${game.rounds.length}");

    game.rounds.remove(round);

    debugMsg("num rounds after ${game.rounds.length}");

    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState deleteRowSlider saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState deleteRowSlider ${e.toString()}", true);
    }
    setState(() {});
  }

  //---------------------------------------------------------------

  Future<void> editRowSlider(Game game, Round round) async {
    debugMsg("editRowSlider round $round");

    final index = game.rounds.indexWhere((r) => r == round);

    debugMsg("editing round index $index");
    debugMsg("num rounds before edit ${game.rounds.length}");

    Round changedRound = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddRoundScreen(game: widget.game, currentRound: round),
      ),
    );

    //    final index = game.rounds.indexWhere((r) => r == round);
    game.rounds[index] = changedRound;

    final GameStorage storage = GameStorage();
    try {
      debugMsg("_ListScreenState editRowSlider saving game");
      storage.saveGame(widget.game);
    } catch (e) {
      debugMsg("_ListScreenState editRowSlider ${e.toString()}", true);
    }

    setState(() {});

    debugMsg("num rounds after edit ${game.rounds.length}");
  }
  //---------------------------------------------------------------

  static const bnbNumPlayers = 0;
  static const bnbGameEnd = 1;
  static const bnbClear = 2;

  BottomNavigationBar bottomNavigationBar(Game game) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
        BottomNavigationBarItem(icon: Icon(Icons.save), label: 'The End'),
        BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Clear'),
      ],
      currentIndex: _bnbSelectedIndex,
      selectedItemColor: Colors.blue,
      onTap: ((int index) {
        _onItemTapped(index, game);
      }),
    );
  }

  //---------------------------------------------------------------

  void _onItemTapped(int index, Game game) async {
    debugMsg("_onItemTapped index $index");

    switch (index) {
      case bnbNumPlayers:
        debugMsg("calling showNumberPicker");

        int? selectedNumber = await showNumberPicker(context);

        if (selectedNumber == null) return;

        debugMsg("selectedNumber $selectedNumber");

        if (selectedNumber != game.numPlayers()) {
          setState(() {
            changeNumPlayers(game, selectedNumber);
          });
        }

      case bnbGameEnd:
        debugMsg("calling MyUtils.showDialogBox 1");

        MyUtils.showDialogBox(
          context,
          "End Game",
          "Confirm",
          "Cancel",
        ).then<int>((var r) {
          debugMsg("showDialogBox returned $r");
          if (r == 1) {
            debugMsg("calling resetScores");
            setState(() {
              game.record();
              game.resetScores();
            });
          }
          return r;
        });

      case bnbClear:
        debugMsg("calling MyUtils.showDialogBox 2");

        MyUtils.showDialogBox(
          context,
          "Clear scores?",
          "Confirm",
          "Cancel",
        ).then<int>((var r) {
          debugMsg("showDialogBox returned $r");
          if (r == 1) {
            debugMsg("calling resetScores");

            setState(() {
              game.resetScores();
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

  void changeNumPlayers(Game game, int newNumPlayers) async {
    final firstNames = ['Alice', 'Bob', 'Charlie', 'Diana', 'Emma', 'Frank'];

    debugMsg("changeNumPlayers newNumPlayers $newNumPlayers");

    // Game? newGame;

    //    newGame = await loadGameData(game.name, newNumPlayers);
    // debugMsg("after loadGameData newGame $newGame");

    // newGame ??= Game(game.name);

    // debugMsg("newGame.numPlayers() ${newGame.numPlayers()}");
    game.clear();
    Game savedGame =
        await loadGameData(game.name, newNumPlayers) ?? Game(game.name);

    if (savedGame.numPlayers() == 0) {
      // there's no saved game, so initialise
      debugMsg("initilising new players");
      for (int n = 0; n < newNumPlayers; n++) {
        game.addPlayerByName(firstNames[n]);
      }
    } else {
      debugMsg("using saved game data");
      game.setPlayers(savedGame.players);
      debugMsg("m2 game $game");
      game.setRounds(savedGame.rounds);
      debugMsg("m3 game $game");
    }
    debugMsg("m4 game $game");
    //      newGame.initFirstRound();
    // debugMsg("at the end newGame $newGame");

    // game = newGame;

    // game.setPlayers(newGame.players);
    //    game.initFirstRound();

    debugMsg("at the end game $game");
  }

  //---------------------------------------------------------------

  Future<Game?> loadGameData(String gameName, int numPlayers) async {
    debugMsg("_ScoresState loadGameData");
    final GameStorage storage = GameStorage();

    Game game = Game.empty();

    try {
      game = await storage.loadGame(gameName, numPlayers);

      debugMsg("Game at this point is ${game.toString()}");
    } catch (e) {
      debugMsg("_ScoresState loadGameData ${e.toString()}", true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return game;
  }

  //-----------------------------------------------------------------
}
