/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 08/24/2026
*
*----------------------------------------------------------------------------*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scores/constants/app_assets.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/player.dart';

//---------------------------------------------------------------------------

class PlayerListTile extends StatelessWidget {
  final Player player;
  final void Function(BuildContext, Player)? onTap;
  final Widget? trailing; // Optional trailing widget

  const PlayerListTile({
    super.key,
    required this.player,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        player.name, 
        style: TextStyle(color: player.color.toColor()),
      ),
      leading: CircleAvatar(
        backgroundImage: (player.photoPath.isNotEmpty && File(player.photoPath).existsSync())
            ? FileImage(File(player.photoPath))
            : const AssetImage(AppAssets.defaultPlayerPhoto) as ImageProvider,
      ),
      trailing: trailing,
      onTap: onTap != null ? () => onTap!(context, player) : null,
    );
  }
}

//---------------------------------------------------------------------------
