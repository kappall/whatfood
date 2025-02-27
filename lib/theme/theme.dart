import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme);

  void toggleTheme() {
    state = (state.brightness == Brightness.dark) ? lightTheme : darkTheme;
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[100],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.red,
    unselectedItemColor: Colors.grey,
  ),
  primaryColor: Colors.black87,
  secondaryHeaderColor: Colors.green,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, // Per sfondo visibile
    fillColor: Colors.grey[900], // Sfondo del campo di input
    hintStyle: TextStyle(color: Colors.grey[500]), // Colore placeholder
    labelStyle: TextStyle(color: Colors.white), // Colore etichetta
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent), // Bordo in focus
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey), // Bordo normale
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF121212),
    selectedItemColor: Colors.orange,
    unselectedItemColor: Colors.white60,
  ),
  primaryColor: Colors.white,
  secondaryHeaderColor: Colors.green,
);
