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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scores/constants/app_assets.dart';

import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/repositories/repositories.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/data/services/photo_service.dart';

import 'package:scores/presentation/dialogs/pick_color.dart';

import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class PlayerFormScreen extends StatefulWidget {
  final Player? player; // null for new person, existing person for edit

  const PlayerFormScreen({super.key, this.player});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

//---------------------------------------------------------------------------

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _playerColor = Colors.black;
  String? _photoPath;
  //  final ImagePicker _picker = ImagePicker();
  final photoService = PhotoService();

  bool creatingNewPlayer = true;

  //----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing existing person
    if (widget.player != null) {
      creatingNewPlayer = false;
      _nameController.text = widget.player!.name;
      _playerColor = widget.player!.color.toColor();

      _loadPhotoPath();

      debugMsg("_PlayerFormScreenState initState _photoPath $_photoPath");
    }
  }

  //----------------------------------------------------------------
  // Our asynchronous side-routine
  void _loadPhotoPath() async {
    String? path = await photoService.getPath(
      category: 'player',
      id: widget.player!.id,
    );

    // see if path actually points to a file, if not, set to null
    if (!File(path).existsSync()) {
      path = null;
    }

    // Check if the user hasn't already backed out of the screen while we were looking up the file
    if (!mounted) return;

    // Update the ledger and trigger a redraw
    setState(() {
      _photoPath = path;
      debugMsg("_PlayerFormScreenState _loadPhotoPath _photoPath $_photoPath");
    });
  }
  //----------------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------

  Future<void> _pickImage() async {
    final imagePath = await photoService.capturePhoto();

    if (imagePath != null) {
      setState(() {
        _photoPath = imagePath;
      });
    }
  }

  //---------------------------------------------------------------------------

  Future<void> _showColorPicker() async {
    Color? pickedColor = await showColorPicker2(context, _playerColor);

    if (pickedColor != null) {
      setState(() {
        _playerColor = pickedColor;
      });
    }
  }

  //---------------------------------------------------------------------------

  Future<String?> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      debugMsg("_savePlayer creatingNewPlayer $creatingNewPlayer");

      final playerName = _nameController.text;

      if (creatingNewPlayer) {
        bool playerExists = await playerRepository.nameExists(playerName);
        if (playerExists) {
          return "Player $playerName already exists";
        }
      }

      int playerId = 0;
      if (!creatingNewPlayer) {
        playerId = widget.player?.id ?? 0;
      }

      final player = Player(
        id: playerId,
        name: playerName,
        color: _playerColor.toInt(),
        photoPath: _photoPath ?? "",
      );

      if (creatingNewPlayer) {
        player.id = await playerRepository.insertPlayer(player);
        debugMsg("newly created player id ${player.id}");
      } else {
        await playerRepository.updatePlayer(player);
      }

      if (_photoPath != null) {
        photoService.savePhoto(
          photoPath: _photoPath ?? "",
          category: "player",
          id: player.id,
        );
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

              // Colour field
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
                              color: _playerColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(getColourName(_playerColor)),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Photo section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 75, // Radius is half the width/height (150 / 2)
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (_photoPath != null && _photoPath!.isNotEmpty)
                        ? FileImage(File(_photoPath!))
                        : const AssetImage(AppAssets.defaultPlayerPhoto)
                              as ImageProvider,
                  ),
                  // child: Container(
                  //   width: 150,
                  //   height: 150,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade200,
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: _photoPath != null
                  //       ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                  //       : Image.asset(AppAssets.defaultPlayerPhoto, fit: BoxFit.cover),
                  // ),
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

  //---------------------------------------------------------------------------
}
