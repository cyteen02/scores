
import 'package:flutter/material.dart';

import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/player.dart';


Future<bool> changePlayerName(BuildContext context, Match match, Player player) async {
    debugMsg("changePlayerName $player");

    bool changed = false;
    final name = await changeNameDialog(context, match);

    if (name != null && name.isNotEmpty) {
      debugMsg('Name entered: $name');
      player.name = name;
      changed = true;
      // Do something with the name
    } else {
      debugMsg('Dialog cancelled or empty name');
    }

//    debugMsg("Game is now ${widget.game}");

//    setState(() {});

    return changed;
  }

  //---------------------------------------------------------------

  Future<String?> changeNameDialog(BuildContext context, Match match) async {
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
                if (match.playerSet.nameExists(value)) {
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