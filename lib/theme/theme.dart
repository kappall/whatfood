import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

// Gestione del tema
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme);

  void toggleTheme() {
    state = (state.brightness == Brightness.dark) ? lightTheme : darkTheme;
  }
}

// Definizione del tema
final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[100],
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.red,
    unselectedItemColor: Colors.grey,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF121212),
    selectedItemColor: Colors.orange,
    unselectedItemColor: Colors.white60,
  ),
);
