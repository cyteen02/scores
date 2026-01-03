/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/24/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scores/database/player_repository.dart';
import 'dart:io';

import 'package:scores/models/player.dart';
import 'package:scores/utils/my_utils.dart';

// class Player {
//   String name;
//   Color favouriteColour;
//   String? photoPath;

//   Player({
//     required this.name,
//     required this.favouriteColour,
//     this.photoPath,
//   });
// }

class PlayerFormScreen extends StatefulWidget {
  final Player? player; // null for new person, existing person for edit

  const PlayerFormScreen({super.key, this.player});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColour = Colors.blue;
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  final playerRespository = PlayerRepository();
  bool creatingNewPlayer = true;

  //----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing existing person
    if (widget.player != null) {
      creatingNewPlayer = false;
      _nameController.text = widget.player!.name;
      _selectedColour = widget.player!.color;
      _photoPath = widget.player!.photoPath;
    }
  }

  //----------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  //----------------------------------------------------------------

  Future<void> _showColorPicker() async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Favourite Colour'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
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
                    Colors.black,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(color),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColour == color
                                ? Colors.white
                                : Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _selectedColour = pickedColor;
      });
    }
  }

  //-------------------------------------------------------------

  Future<String?> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final playerName = _nameController.text;

      if (creatingNewPlayer) {
        bool playerExists = await playerRespository.nameExists(playerName);
        if (playerExists) {
          return "Player $playerName already exists";
        }
      }

      final player = Player();

      if (!creatingNewPlayer) {
        player.id = widget.player?.id ?? 0;
      }
      player.setName(playerName);
      player.setColor(_selectedColour);
      player.photoPath = _photoPath ?? "";

      if (creatingNewPlayer) {
        playerRespository.insertPlayer(player);
      } else {
        playerRespository.updatePlayer(player);
      }

      // Return the person object to the previous screen
      if (mounted) {
        Navigator.of(context).pop(player);
      }
    }
    return null;
  }

  //-------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(creatingNewPlayer ? 'New Player' : 'Edit Player'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                    child: _photoPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(_photoPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey.shade600,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    _photoPath != null ? 'Change Photo' : 'Add Photo',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Favourite colour field
              InkWell(
                onTap: _showColorPicker,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Colour',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.palette),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _selectedColour,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(_getColourName(_selectedColour)),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: () async {
                  final error = await _savePlayer();
                  if (error != null) {
                    if (context.mounted) {
                      showPopupError(context, error);
                    }
                  }
                },
                //                onPressed: _savePlayer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  creatingNewPlayer ? 'Create Player' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------------------

  String _getColourName(Color color) {
    if (color == Colors.red) return 'Red';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.deepPurple) return 'Deep Purple';
    if (color == Colors.indigo) return 'Indigo';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.lightBlue) return 'Light Blue';
    if (color == Colors.cyan) return 'Cyan';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.green) return 'Green';
    if (color == Colors.lightGreen) return 'Light Green';
    if (color == Colors.lime) return 'Lime';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.amber) return 'Amber';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.deepOrange) return 'Deep Orange';
    if (color == Colors.brown) return 'Brown';
    if (color == Colors.grey) return 'Grey';
    if (color == Colors.blueGrey) return 'Blue Grey';
    if (color == Colors.black) return 'Black';
    return 'Custom';
  }

  //----------------------------------------------------------------
}
