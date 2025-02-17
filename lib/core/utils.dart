import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}

Future<File?> pickImageFromGallery() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  if (image != null) {
    return File(image.files.first.path!);
  }
  return null;
}

Future<File?> pickImageFromCamera() async {
  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 70,
  );

  if (photo != null) {
    return File(photo.path);
  }
  return null;
}

Future<File?> pickImage(BuildContext context) async {
  debugPrint('Showing image source dialog');
  final ImageSource? source = await showDialog<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      );
    },
  );

  if (source == null) {
    debugPrint('No source selected');
    return null;
  }

  debugPrint('Selected source: $source');
  
  try {
    if (source == ImageSource.gallery) {
      return await pickImageFromGallery();
    } else {
      return await pickImageFromCamera();
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
    return null;
  }
}
