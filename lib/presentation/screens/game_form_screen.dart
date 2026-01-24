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

import 'package:flutter/material.dart';
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/utils/my_utils.dart';

class GameFormScreen extends StatefulWidget {
  final GameRepository gameRepository;
  final Game? game;

  const GameFormScreen({super.key, 
          required this.gameRepository, 
          this.game});

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

//--------------------------------------------------------------

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roundController = TextEditingController();

  late GameRepository gameRespository;

  List<String> rounds = [];

  ShowFutureRoundsType showFutureRoundsType =
      ShowFutureRoundsType.showNoFutureRounds;

  WinCondition winCondition = WinCondition.highestScore;

  bool creatingNewGame = true;

  //--------------------------------------------------------------

  @override
  void initState() {

    super.initState();

    gameRespository = widget.gameRepository;

    if (widget.game != null) {
      creatingNewGame = false;
      _nameController.text = widget.game!.name;
      rounds = List.from(widget.game!.roundLabels);
      showFutureRoundsType = widget.game!.showFutureRoundsType;
      winCondition = widget.game!.winCondition;
    }
  }

  //--------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _roundController.dispose();
    super.dispose();
  }

  //--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("GameFormScreen build game ${widget.game}");

    return Scaffold(
      appBar: AppBar(
        title: Text(creatingNewGame ? 'New Game' : 'Edit Game'),
        // actions: [
        //   if (!isNewGameType)
        //     IconButton(
        //       icon: const Icon(Icons.delete),
        //       onPressed: _confirmDelete,
        //     ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Game Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<WinCondition>(
              decoration: InputDecoration(
                labelText: 'Win Condition',
                border: OutlineInputBorder(),
              ),
              initialValue: winCondition,
              items: WinCondition.values.map((WinCondition condition) {
                return DropdownMenuItem<WinCondition>(
                  value: condition,
                  child: Text(
                    condition.description,
                    // condition == WinCondition.highestScore
                    //     ? 'Highest Score'
                    //     : 'Lowest Score',
                  ),
                );
              }).toList(),
              onChanged: (WinCondition? newValue) {
                debugMsg("winCondition $newValue");
                setState(() {
                  winCondition = newValue!;
                });
              },
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<ShowFutureRoundsType>(
              decoration: InputDecoration(
                labelText: 'Show Rounds Ahead?',
                border: OutlineInputBorder(),
              ),
              initialValue: showFutureRoundsType,
              items: ShowFutureRoundsType.values.map((
                ShowFutureRoundsType type,
              ) {
                return DropdownMenuItem<ShowFutureRoundsType>(
                  value: type,
                  child: Text(type.description),
                );
              }).toList(),
              onChanged: (ShowFutureRoundsType? newValue) {
                debugMsg("showFutureRoundsType $newValue");
                setState(() {
                  showFutureRoundsType = newValue!;
                });
              },
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Rounds',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Round'),
                  onPressed: _addRound,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (rounds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No rounds added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...List.generate(rounds.length, (index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(rounds[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeRound(index),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final error = await _saveGame();
                if (error != null) {
                  if (context.mounted) {
                    showPopupError(context, error);
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                creatingNewGame ? 'Create Game' : 'Save Changes',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------

  void _addRound() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Round'),
        content: TextField(
          controller: _roundController,
          decoration: const InputDecoration(
            labelText: 'Round Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _submitRound(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _submitRound, child: const Text('Add')),
        ],
      ),
    );
  }

  //--------------------------------------------------------------

  void _submitRound() {
    if (_roundController.text.isNotEmpty) {
      setState(() {
        rounds.add(_roundController.text);
        _roundController.clear();
      });
      Navigator.pop(context);
    }
  }

  //--------------------------------------------------------------

  void _removeRound(int index) {
    setState(() {
      rounds.removeAt(index);
    });
  }

  //--------------------------------------------------------------

  Future<String?> _saveGame() async {
    debugMsg("_saveGame");

    if (_formKey.currentState!.validate()) {
      final gameName = _nameController.text;

      if (creatingNewGame) {
        bool gameExists = await gameRespository.nameExists(gameName);
        if (gameExists) {
          return "Game $gameName already exists";
        }
      }

      final game = Game(name: gameName);

      //if editing an existing game use the existing id
      if (!creatingNewGame) {
        game.id = widget.game?.id ?? 0;
      }

      game
        ..name = _nameController.text
//        ..roundLabels = rounds
        ..showFutureRoundsType = showFutureRoundsType
        ..winCondition = winCondition;

      debugMsg("Saving game $game");

      if (creatingNewGame) {
        await gameRespository.insertGame(game);
      } else {
        await gameRespository.updateGame(game);
      }

      if (mounted) {
        Navigator.pop(context, game);
      }
    }
    return null;
  }

  //----------------------------------------------------------------
}
