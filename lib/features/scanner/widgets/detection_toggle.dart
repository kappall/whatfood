import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DetectionToggle extends StatelessWidget {
  final onPressed;
  const DetectionToggle({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: SizedBox(
        height: 50.0,
        width: 50.0,
        child: FloatingActionButton(
          heroTag: Object(),
          onPressed: () => onPressed(ImageSource.gallery),
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.photo_library_outlined,
            size: 25,
          ),
        ),
      ),
    );
  }
}
