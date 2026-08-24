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
import 'package:scores/data/models/location.dart';
import 'package:scores/data/repositories/repositories.dart';
import 'package:scores/presentation/dialogs/pick_color.dart';
import 'package:scores/presentation/widgets/color_picker.dart';

import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/services/photo_service.dart';

//---------------------------------------------------------------------------

class LocationFormScreen extends StatefulWidget {
  final Location? location; // null for new location

  const LocationFormScreen({super.key, this.location});

  @override
  State<LocationFormScreen> createState() => _LocationFormScreenState();
}

//-----------------------------------------------------------

class _LocationFormScreenState extends State<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _locationColor = Colors.black;

  String? _photoPath;
  final photoService = PhotoService();

  bool creatingNewLocation = true;

  //-----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    if (widget.location != null) {
      creatingNewLocation = false;
      _nameController.text = widget.location?.name ?? '';
      _descriptionController.text = widget.location?.description ?? '';

      _locationColor = widget.location?.color.toColor() ?? Colors.blue;

      _loadPhotoPath();
    }
  }

  //-----------------------------------------------------------

  // Our asynchronous side-routine
  void _loadPhotoPath() async {
    String? path = await photoService.getPath(
      category: 'location',
      id: widget.location!.id ?? 0,
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
      debugMsg(
        "_LocationFormScreenState _loadPhotoPath _photoPath $_photoPath",
      );
    });
  }

  //----------------------------------------------------------------
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  Future<String?> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      debugMsg("_saveLocation creatingNewLocation $creatingNewLocation");

      final locationName = _nameController.text.trim();

      if (creatingNewLocation) {
        bool locationExists = await locationRepository.nameExists(locationName);
        if (locationExists) {
          return "Location $locationName already exists";
        }
      }

      int locationId = 0;
      if (!creatingNewLocation) {
        locationId = widget.location?.id ?? 0;
      }

      final location = Location(
        id: locationId,
        name: locationName,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _locationColor.toInt(),
        photoPath: _photoPath ?? "",
      );

      if (creatingNewLocation) {
        final newLocation = await locationRepository.insertLocation(location);
        debugMsg("newly created location id ${newLocation.id}");
      } else {
        await locationRepository.updateLocation(location);
      }

      if (_photoPath != null) {
        photoService.savePhoto(
          photoPath: _photoPath ?? "",
          category: "location",
          id: location.id ?? 0,
        );
      }

      // Return the person object to the previous screen
      if (mounted) {
        Navigator.of(context).pop(location);
      }
    }
    return null;
  }

  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(creatingNewLocation ? 'New Location' : 'Edit Location'),
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

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Colour field
              // InkWell(
              //   onTap: _showColorPicker,
              //   child: InputDecorator(
              //     decoration: const InputDecoration(
              //       labelText: 'Colour',
              //       border: OutlineInputBorder(),
              //       prefixIcon: Icon(Icons.palette),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Row(
              //           children: [
              //             Container(
              //               width: 30,
              //               height: 30,
              //               decoration: BoxDecoration(
              //                 color: _locationColor,
              //                 shape: BoxShape.circle,
              //                 border: Border.all(color: Colors.grey.shade400),
              //               ),
              //             ),
              //             const SizedBox(width: 12),
              //             Text(getColourName(_locationColor)),
              //           ],
              //         ),
              //         const Icon(Icons.arrow_drop_down),
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 24),
              colorPickerWidget(context, _locationColor, _showColorPicker),

              // Photo section
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 75, // Radius is half the width/height (150 / 2)
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (_photoPath != null && _photoPath!.isNotEmpty)
                        ? FileImage(File(_photoPath!))
                        : const AssetImage(AppAssets.defaultLocationPhoto)
                              as ImageProvider,
                  ),
                  // child: Container(
                  //   width: 150,
                  //   height: 150,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade200,
                  //     shape: BoxShape.circle,
                  //     border: Border.all(color: Colors.grey.shade400, width: 2),
                  //   ),
                  //   child: _photoPath != null
                  //       ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                  //       : Image.asset(AppAssets.defaultLocationPhoto, fit: BoxFit.cover),                  ),
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
                  final error = await _saveLocation();
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
                  creatingNewLocation ? 'Create Location' : 'Save Changes',
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

  Widget build2(BuildContext context) {
    return AlertDialog(
      title: Text(widget.location == null ? 'Add Location' : 'Edit Location'),
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
                        color: _locationColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
        ElevatedButton(onPressed: _saveLocation, child: const Text('Save')),
      ],
    );
  }

  //---------------------------------------------------------------------------

  Future<void> _showColorPicker() async {
    Color? pickedColor = await showColorPicker2(context, _locationColor);

    if (pickedColor != null) {
      setState(() {
        _locationColor = pickedColor;
      });
    }
  }

  //---------------------------------------------------------------------------
}
