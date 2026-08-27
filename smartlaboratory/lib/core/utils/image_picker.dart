import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () =>
                  Navigator.pop(bottomSheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Caméra'),
              onTap: () =>
                  Navigator.pop(bottomSheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    return pickedFile == null ? null : File(pickedFile.path);
  }
}
