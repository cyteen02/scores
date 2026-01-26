/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/17/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/location.dart';
import 'package:scores/data/repositories/location_repository.dart';

class ListLocationsScreen extends StatefulWidget {
  
  final LocationRepository repository;

  const ListLocationsScreen({super.key, 
                        required this.repository});

  @override
  State<ListLocationsScreen> createState() => _ListLocationsScreenState();
}

//-----------------------------------------------------------

class _ListLocationsScreenState extends State<ListLocationsScreen> {
  List<Location> _locations = [];
  bool _isLoading = true;

  //-----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  //-----------------------------------------------------------

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final locations = await widget.repository.getAll();
    setState(() {
      _locations = locations;
      _isLoading = false;
    });
  }

  //-----------------------------------------------------------

  void _showLocationDialog({Location? location}) {
    showDialog(
      context: context,
      builder: (context) => LocationFormDialog(
        location: location,
        onSave: (newLocation) async {
          if (location == null) {
            await widget.repository.create(newLocation);
          } else {
            await widget.repository.update(newLocation);
          }
          _loadLocations();
        },
      ),
    );
  }

  //-----------------------------------------------------------

  Future<void> _deleteLocation(Location location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && location.id != null) {
      await widget.repository.delete(location.id!);
      _loadLocations();
    }
  }

  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
              ? const Center(child: Text('No locations yet. Add one!'))
              : ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: location.color.toColor(),
                      ),
                      title: Text(location.name),
                      subtitle: location.description != null
                          ? Text(location.description!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showLocationDialog(location: location),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteLocation(location),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLocationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

//-----------------------------------------------------------

class LocationFormDialog extends StatefulWidget {
  final Location? location;
  final Function(Location) onSave;

  const LocationFormDialog({
    super.key,
    this.location,
    required this.onSave,
  });

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
    _descriptionController = TextEditingController(text: widget.location?.description ?? '');
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
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
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
            children: [
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
                      color: color == _selectedColor ? Colors.black : Colors.grey,
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
