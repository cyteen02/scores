/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/26/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/models/location.dart';

Future<Location?> showLocationPickerDialog(
  BuildContext context,
  List<Location> locations,
) async {
  return showDialog<Location>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: locations.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('None'),
                  leading: const Icon(Icons.location_off),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(Location(name: 'NONE', color: 0)); // Or pop a special "clear" value
                  },
                );
              }
              final location = locations[index - 1];
              return ListTile(
                title: Text(location.name),
                subtitle: location.description != null
                    ? Text(location.description!)
                    : null,
                leading: Icon(Icons.location_on, color: Color(location.color)),
                onTap: () {
                  Navigator.of(context).pop(location);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
  //---------------------------------------------------------------------------
}
