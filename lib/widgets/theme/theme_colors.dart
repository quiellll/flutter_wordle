import 'package:flutter/material.dart';

class WordleColors {
  // Existing button colors
  static const Color spanishButton = Colors.red;
  static const Color englishButton = Colors.blue;
  static const Color important = Colors.red;

  // Light theme colors
  static final lightTheme = _WordleThemeColors(
    // Home screen colors
    mainText: Colors.grey,
    secondaryText: Colors.grey.shade500,
    cardBackground: Colors.white,
    backgroundColor: Colors.grey.shade100,
    dividerColor: Colors.grey.withOpacity(0.2),
    shadowColor: Colors.black.withOpacity(0.08),
    statBoxBackground: Colors.grey[200]!,

    // Game colors
    correctTile: Colors.green,
    wrongPositionTile: Colors.orange,
    tileText: Colors.white,
    emptyTile: Colors.white,
    wrongTile: Colors.grey,
    borderColor: Colors.grey,
    textColor: Colors.black,
    keyboardDefault: Colors.grey.shade300,
    
    // Message colors
    errorBackground: Colors.red.shade100,
    errorText: Colors.red.shade800,
  );

  // Dark theme colors
  static final darkTheme = _WordleThemeColors(
    // Home screen colors
    mainText: Colors.grey,
    secondaryText: Colors.grey.shade500,
    cardBackground: const Color(0xFF2C2C2C),
    backgroundColor: const Color(0xFF1A1A1A),
    dividerColor: Colors.grey.withOpacity(0.2),
    shadowColor: Colors.black.withOpacity(0.15),
    statBoxBackground: Colors.grey[800]!,

    // Game colors
    correctTile: Colors.green,
    wrongPositionTile: Colors.orange,
    tileText: Colors.white,
    emptyTile: Colors.grey.shade900,
    wrongTile: Colors.grey.shade800,
    borderColor: Colors.grey.shade700,
    textColor: Colors.white,
    keyboardDefault: Colors.grey.shade700,
    
    // Message colors
    errorBackground: Colors.red.shade900,
    errorText: Colors.red.shade100,
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.grey,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightTheme.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightTheme.backgroundColor,
        foregroundColor: lightTheme.textColor,
        elevation: 0,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.grey,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkTheme.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: darkTheme.backgroundColor,
        foregroundColor: darkTheme.textColor,
        elevation: 0,
      ),
    );
  }
}

class _WordleThemeColors {
  final Color mainText;
  final Color secondaryText;
  final Color cardBackground;
  final Color backgroundColor;
  final Color dividerColor;
  final Color shadowColor;
  final Color statBoxBackground;
  
  final Color correctTile;
  final Color wrongPositionTile;
  final Color tileText;
  final Color emptyTile;
  final Color wrongTile;
  final Color borderColor;
  final Color textColor;
  final Color keyboardDefault;
  
  final Color errorBackground;
  final Color errorText;

  const _WordleThemeColors({
    required this.mainText,
    required this.secondaryText,
    required this.cardBackground,
    required this.backgroundColor,
    required this.dividerColor,
    required this.shadowColor,
    required this.statBoxBackground,
    required this.correctTile,
    required this.wrongPositionTile,
    required this.tileText,
    required this.emptyTile,
    required this.wrongTile,
    required this.borderColor,
    required this.textColor,
    required this.keyboardDefault,
    required this.errorBackground,
    required this.errorText,
  });
}