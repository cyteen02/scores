/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/19/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/data/extensions/icon_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/data/models/round_label.dart';
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/utils/my_utils.dart';

class GameEditScreen extends StatefulWidget {
  final Game? game; // null for new game, existing game for edit
  final GameRepository gameRepository;

  const GameEditScreen({super.key, this.game, required this.gameRepository});

  @override
  State<GameEditScreen> createState() => _GameEditScreenState();
}

//---------------------------------------------------------------------------

class _GameEditScreenState extends State<GameEditScreen> {
  late TextEditingController _nameController;
  late List<RoundLabel> _roundLabels;
  
  ShowFutureRoundsType showFutureRoundsType =
      ShowFutureRoundsType.showNoFutureRounds;
  WinCondition winCondition = WinCondition.highestScore;
  GameLengthType gameLengthType = GameLengthType.variableLength;
  
  late GameRepository gameRespository;

  bool editExistingGame = false;
  final _formKey = GlobalKey<FormState>();

  //---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    gameRespository = widget.gameRepository;

    Game? game = widget.game;

    if (game != null) {
      editExistingGame = true;
      _nameController = TextEditingController(text: game.name);
      showFutureRoundsType = game.showFutureRoundsType;
      winCondition = game.winCondition;
      gameLengthType = game.gameLengthType;

      // Create a mutable copy of round labels
      _roundLabels = List<RoundLabel>.from(game.roundLabels);
    } else {
      _nameController = TextEditingController(text: '');
      _roundLabels = [];
    }
  }

  //---------------------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //---------------------------------------------------------------------------

  Future<bool> _save() async {
    if (_formKey.currentState!.validate()) {
      final gameName = _nameController.text;

      if (!editExistingGame) {
        bool gameExists = await gameRespository.nameExists(gameName);
        if (gameExists) {
          if (mounted) {
            showPopupError(context, "Game $gameName already exists");
          }
          return false;
        }
      }

      final game = Game(
        id: widget.game?.id,
        name: _nameController.text.trim(),
        showFutureRoundsType: showFutureRoundsType,
        winCondition: winCondition,
        gameLengthType: gameLengthType,
        roundLabels: _roundLabels,
      );

      try {
        Game savedGame;
        if (editExistingGame) {
          debugMsg("updating existing game $game");
          await widget.gameRepository.updateGame(game);
          savedGame = game;
        } else {
          debugMsg("savings new game $game");
          savedGame = await widget.gameRepository.saveGameWithRoundLabels(game);
        }
        if (mounted) {
          Navigator.pop(context, savedGame); // Return true to indicate saved
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving game: $e')));
        }
      }
    }
    return true;
  }

  //---------------------------------------------------------------------------

  void _cancel() {
    Navigator.pop(context, null); // Return false, nothing saved
  }

  //---------------------------------------------------------------------------

  void _addRoundLabel() {
    showDialog(
      context: context,
      builder: (context) => RoundLabelFormDialog(
        onSave: (label) {
          setState(() {
            _roundLabels.add(label);
          });
        },
      ),
    );
  }

  //---------------------------------------------------------------------------

  void _editRoundLabel(int index) {
    showDialog(
      context: context,
      builder: (context) => RoundLabelFormDialog(
        roundLabel: _roundLabels[index],
        onSave: (label) {
          setState(() {
            _roundLabels[index] = label;
          });
        },
      ),
    );
  }

  //---------------------------------------------------------------------------

  void _deleteRoundLabel(int index) {
    setState(() {
      _roundLabels.removeAt(index);
    });
  }

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugMsg("GameEditScreen build game ${widget.game}");

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.game == null ? 'New Game' : 'Edit Game'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Game Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a game name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<WinCondition>(
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
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<GameLengthType>(
                  decoration: InputDecoration(
                    labelText: 'Game Length?',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: gameLengthType,
                  items: GameLengthType.values.map((
                    GameLengthType type,
                  ) {
                    return DropdownMenuItem<GameLengthType>(
                      value: type,
                      child: Text(type.description),
                    );
                  }).toList(),
                  onChanged: (GameLengthType? newValue) {
                    debugMsg("GameLengthType $newValue");
                    setState(() {
                      gameLengthType = newValue!;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<ShowFutureRoundsType>(
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
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Round Labels (${_roundLabels.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: _addRoundLabel,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Label'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _roundLabels.isEmpty
                    ? const Center(
                        child: Text('No round labels yet. Add one above!'),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _roundLabels.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = _roundLabels.removeAt(oldIndex);
                            _roundLabels.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final label = _roundLabels[index];
                          return Card(
                            key: ValueKey(label.hashCode),
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: label.color.toColor(),
                                child: Icon(
                                  label.icon.toIcon(),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(label.name),
                              subtitle: label.description != null
                                  ? Text(label.description!)
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editRoundLabel(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteRoundLabel(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//---------------------------------------------------------------------------

class RoundLabelFormDialog extends StatefulWidget {
  final RoundLabel? roundLabel;
  final Function(RoundLabel) onSave;

  const RoundLabelFormDialog({
    super.key,
    this.roundLabel,
    required this.onSave,
  });

  @override
  State<RoundLabelFormDialog> createState() => _RoundLabelFormDialogState();
}

//---------------------------------------------------------------------------

class _RoundLabelFormDialogState extends State<RoundLabelFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.roundLabel?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.roundLabel?.description ?? '',
    );
    _selectedColor = widget.roundLabel?.color.toColor() ?? Colors.blue;
    _selectedIcon = widget.roundLabel?.icon.toIcon() ?? Icons.sports_golf;
  }

  //---------------------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //---------------------------------------------------------------------------

  void _save() {
    if (_formKey.currentState!.validate()) {
      final roundLabel = RoundLabel(
        id: widget.roundLabel?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor.toInt(),
        icon: _selectedIcon.toInt(),
      );
      widget.onSave(roundLabel);
      Navigator.pop(context);
    }
  }

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.roundLabel == null ? 'Add Round Label' : 'Edit Round Label',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showColorPicker(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text('Icon: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showIconPicker(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_selectedIcon, size: 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  //---------------------------------------------------------------------------

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: color == _selectedColor
                              ? Colors.black
                              : Colors.grey,
                          width: color == _selectedColor ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------

  void _showIconPicker() {
    final icons = [
      Icons.sports_golf,
      Icons.sports,
      Icons.flag,
      Icons.sports_score,
      Icons.emoji_events,
      Icons.star,
      Icons.grade,
      Icons.workspace_premium,
      Icons.timer,
      Icons.schedule,
      Icons.calendar_today,
      Icons.trending_up,
      Icons.trending_down,
      Icons.show_chart,
      Icons.sports_tennis,
      Icons.sports_baseball,
      Icons.sports_basketball,
      Icons.circle,
      Icons.label,
      Icons.bookmark,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: icons.map((icon) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(
                      color: icon == _selectedIcon ? Colors.black : Colors.grey,
                      width: icon == _selectedIcon ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 32),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------
}
