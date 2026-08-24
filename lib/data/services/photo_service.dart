/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 07/13/2026
*
*----------------------------------------------------------------------------*/

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto() async {
    debugMsg("PhotoService capturePhoto");
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 400, // Keep dimensions sensible so your storage stays light
      imageQuality: 85, // Compress slightly to keep files down to a few KB
    );

    debugMsg("PhotoService capturePhoto photo.path ${photo?.path}");

    return photo?.path;
  }

  //---------------------------------------------------------------------------

  Future<String?> savePhoto({
    required String photoPath,
    required String category,
    required int id,
  }) async {
    debugMsg(
      "PhotoService savePhoto path $photoPath category $category id $id",
    );

    try {
      // Get your app's permanent private fortress directory
      final directory = await getApplicationDocumentsDirectory();

      // Create a clean, unique deterministic filename (e.g., player_5.jpg)
      final String fileExtension = p.extension(photoPath);
      final String permanentFileName = '${category}_$id$fileExtension';
      final String permanentPath = p.join(directory.path, permanentFileName);

      // Copy the file from the temporary OS cache to your secure app storage
      final File savedFile = await File(photoPath).copy(permanentPath);

      // Return this absolute path to save into your Player object and sqflite

      debugMsg("PhotoService savePhoto savedFile.path ${savedFile.path}");

      final finalExists = File(permanentPath).existsSync();
      debugMsg("PhotoService savePhoto finalExists $finalExists");

      return savedFile.path;
    } catch (e) {
      debugMsg('PhotoService savePhoto error $e', box: true);
      return null;
    }
  }

  //---------------------------------------------------------------------------

  Future<String> getPath({required String category, required int id}) async {
    debugMsg("PhotoService getPath category $category id $id");

    try {
      // Get your app's permanent private fortress directory
      final directory = await getApplicationDocumentsDirectory();

      // Create a clean, unique deterministic filename (e.g., player_5.jpg)
      final String fileExtension = ".jpg";
      final String permanentFileName = '${category}_$id$fileExtension';
      final String permanentPath = p.join(directory.path, permanentFileName);

      debugMsg("PhotoService getPath permanentPath $permanentPath");


      final finalExists = File(permanentPath).existsSync();
      debugMsg("PhotoService getPath finalExists $finalExists");

      return permanentPath;
    } catch (e) {
      debugMsg('PhotoService getPath error $e', box: true);
      return "";
    }
  }

  //---------------------------------------------------------------------------
}
