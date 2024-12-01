import 'package:flutter/material.dart';

class WordleColors {

  static const Color spanishButton = Colors.red;
  static const Color englishButton = Colors.blue;
  static const Color important = Colors.red; 

  // Light theme colors
  static final lightTheme = _WordleThemeColors(
    // Home screen colors
    mainText: Colors.grey,

    // Game colors
    correctTile: Colors.green,
    wrongPositionTile: Colors.orange,
    tileText: Colors.white,
    emptyTile: Colors.white,
    wrongTile: Colors.grey,
    borderColor: Colors.grey,
    textColor: Colors.black,
    keyboardDefault: Colors.grey.shade300,
  );

  // Dark theme colors
  static final darkTheme = _WordleThemeColors(
    // Home screen colors
    mainText: Colors.grey,

    // Game colors
    correctTile: Colors.green,
    wrongPositionTile: Colors.orange,
    tileText: Colors.white,
    emptyTile: Colors.grey.shade900,
    wrongTile: Colors.grey.shade800,
    borderColor: Colors.grey.shade700,
    textColor: Colors.white,
    keyboardDefault: Colors.grey.shade700,
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.grey,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // You can add more theme configurations here
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.grey,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey.shade900,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // You can add more theme configurations here
    );
  }
}

class _WordleThemeColors {
  final Color mainText;
  final Color correctTile;
  final Color wrongPositionTile;
  final Color tileText;
  final Color emptyTile;
  final Color wrongTile;
  final Color borderColor;
  final Color textColor;
  final Color keyboardDefault;

  const _WordleThemeColors({
    required this.mainText,
    required this.correctTile,
    required this.wrongPositionTile,
    required this.tileText,
    required this.emptyTile,
    required this.wrongTile,
    required this.borderColor,
    required this.textColor,
    required this.keyboardDefault,
  });
}