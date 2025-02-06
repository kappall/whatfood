import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle({
    Color backgroundColor = Colors.green,
    Color foregroundColor = Colors.white,
    Color iconColor = Colors.white,
    Size? size = const Size(double.infinity, 50),
    EdgeInsets? padding =
        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconColor: iconColor,
      padding: padding,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      minimumSize: size,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static ButtonStyle textButtonStyle({
    Color textColor = Colors.blue,
  }) {
    return TextButton.styleFrom(
      foregroundColor: textColor,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
