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
import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/location.dart';
import 'package:scores/data/repositories/location_repository.dart';

import 'package:scores/utils/my_utils.dart';

class Locations2ListScreen extends StatefulWidget {
  const Locations2ListScreen({super.key});

  @override
  State<Locations2ListScreen> createState() => _Locations2ListScreenState();
}

class _Locations2ListScreenState extends State<Locations2ListScreen> {
  List<Location> locations = [];
  final locationRepository = LocationRepository();
  bool isLoading = true;

  //--------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  //--------------------------------------------------------------

  Future<void> _loadLocations() async {
    debugMsg("_LocationsListScreenState _loadLocations");

    setState(() => isLoading = true);

    final loadedLocations = await locationRepository.getAll();
    setState(() {
      locations = loadedLocations;
      isLoading = false;
    });
  }

  //--------------------------------------------------------------

  void _deleteLocation(int index) {
    debugMsg("_deleteLocation index $index");

    final location = locations[index];

    // remove from screen
    setState(() {
      locations.removeAt(index);
    });
    // remove from database
    locationRepository.delete(location.id ?? 0);

    showPopupMessage(context, '${location.name} deleted');
  }

  //------------------------------------------------------------------

  Future<dynamic> _confirmDelete(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Location'),
          content: Text(
            'Are you sure you want to delete ${locations[index].name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLocation(index);
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to use'),
                  content: const Text(
                    'Tap a location to edit.\n\n'
                    'Swipe left to delete a location.\n\n'
                    'Use the + button to add new location.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('GOT IT'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : locations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add someone',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return Dismissible(
                  key: Key(location.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _confirmDelete(index);
                  },

                  onDismissed: (direction) {
                    _deleteLocation(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: location.color.toColor(),
                        child: Text(
                          (location.name)[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(location.name),

                      trailing: const Icon(Icons.chevron_right),

                      onTap: () =>
                          _showLocationDialog(location: locations[index]),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        //        onPressed: ((){_showLocationDialog();}),
        onPressed: _showLocationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  //--------------------------------------------------------------

  void _showLocationDialog({Location? location}) {
    showDialog(
      context: context,
      builder: (context) => LocationFormDialog(
        location: location,
        onSave: (newLocation) async {
          if (location == null) {
            await locationRepository.create(newLocation);
          } else {
            await locationRepository.update(newLocation);
          }
          _loadLocations();
        },
      ),
    );
  }
}

//-----------------------------------------------------------

class LocationFormDialog extends StatefulWidget {
  final Location? location;
  final Function(Location) onSave;

  LocationFormDialog({super.key, this.location, required this.onSave});

  final locationRepository = LocationRepository();

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

//-----------------------------------------------------------

class _LocationFormDialogState extends State<LocationFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;

  final _formKey = GlobalKey<FormState>();

  //-----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.location?.description ?? '',
    );
    _selectedColor = widget.location?.color.toColor() ?? Colors.blue;
  }

  //-----------------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //-----------------------------------------------------------

  void _save() {
    if (_formKey.currentState!.validate()) {
      final location = Location(
        id: widget.location?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        color: _selectedColor.toInt(),
      );
      widget.onSave(location);
      Navigator.pop(context);
    }
  }

  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
                        color: _selectedColor,
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
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  //-----------------------------------------------------------

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
}

//-----------------------------------------------------------
