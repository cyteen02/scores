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
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/location.dart';
import 'package:scores/data/repositories/repositories.dart';
import 'package:scores/presentation/screens/manage/location_form_screen.dart';

import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class LocationsListScreen extends StatefulWidget {
  const LocationsListScreen({super.key});

  @override
  State<LocationsListScreen> createState() => _LocationsListScreenState();
}

//---------------------------------------------------------------------------

class _LocationsListScreenState extends State<LocationsListScreen> {
  List<Location> locations = [];
//  final locationRepository = LocationRepository();
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
        centerTitle: true,
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
                      title: Text(location.name, style: TextStyle(color: location.color.toColor())),
                      leading: CircleAvatar(
                        // Check if the path exists AND the file is physically present in app storage
                        backgroundImage:
                            (location.photoPath.isNotEmpty &&
                                File(location.photoPath).existsSync())
                            ? FileImage(File(location.photoPath))
                                                   : const AssetImage(AppAssets.defaultLocationPhoto),
                        // // 2. Only show the text initial if there is NO background image
                        // child:
                        //     (location.photoPath.isNotEmpty &&
                        //         File(location.photoPath).existsSync())
                        //     ? null
                        //     : Text(
                        //         location.name[0].toUpperCase(),
                        //         style: const TextStyle(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                      ),
                      trailing: const Icon(Icons.chevron_right),

                      onTap: () =>
                          _editLocation(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        //        onPressed: ((){_showLocationDialog();}),
        onPressed: _addLocation,
        child: const Icon(Icons.add),
      ),
    );
  }

    
//---------------------------------------------------------------------------

  void _addLocation() async {
    
    final Location? newLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationFormScreen()),
    );

    if (newLocation != null) {
      setState(() {
        locations.add(newLocation);
      });
      if (mounted) {
        showPopupMessage(context, '${newLocation.name} added');
      }
    }
  }

  //--------------------------------------------------------------

  void _editLocation(int index) async {
    final Location? updatedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationFormScreen(location: locations[index]),
      ),
    );

    if (updatedLocation != null) {
      setState(() {
        locations[index] = updatedLocation;
      });
      if (mounted) {
        showPopupMessage(context, '${updatedLocation.name} updated');
      }
    }
  }
//---------------------------------------------------------------------------
}