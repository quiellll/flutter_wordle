import 'package:flutter/material.dart';

class WordleColors {
  // Language selection buttons
  static const Color spanishButton = Color(0xFF2C6E49);  // Emerald green
  static const Color englishButton = Color(0xFF2C6E49);  // Emerald green
  static const Color important = Color(0xFFBF2C2C);    // Rich crimson

  // Light theme colors
  static final lightTheme = _WordleThemeColors(
    // Home screen colors
    mainText: const Color(0xFF4A3728),  // Rich brown text
    secondaryText: const Color(0xFF7A6A5B),  // Softer brown text
    cardBackground: const Color(0xFFF5E6D3),  // Warm cream
    backgroundColor: const Color(0xFFEDE0CC),  // Light parchment
    dividerColor: const Color(0xFF7A6A5B).withOpacity(0.2),
    shadowColor: const Color(0xFF4A3728).withOpacity(0.08),
    statBoxBackground: const Color(0xFFE6D5BC),  // Slightly darker cream

    // Game colors
    correctTile: Color(0xFF2C6E49),  // Emerald green
    wrongPositionTile: Color(0xFFE5A343),  // Amber orange
    tileText: Color(0xFFF5E6D3),  // Warm cream
    emptyTile: const Color(0xFFF5E6D3),  // Matching cream background
    wrongTile: const Color(0xFF8B7355),  // Distinct leather brown for wrong tiles
    borderColor: const Color(0xFF7A6A5B),  // Medium brown
    textColor: const Color(0xFF4A3728),  // Rich brown
    keyboardDefault: const Color(0xFFD4C3AE),  // Light leather tone
    
    // Message colors
    errorBackground: const Color(0xFFBF2C2C),  // Your rich crimson
    errorText: const Color(0xFFFBEBEB),        // Very light pink-red

    // Dialog colors
    dialogBackground: const Color(0xFFF5E6D3),  // Warm cream
    dialogButton: const Color(0xFF8B4513),  // Saddle brown
    dialogButtonText: Colors.white,
    overlayBackground: const Color(0xFFF5E6D3),  // Warm cream for overlays
  );

  // Dark theme colors
  static final darkTheme = _WordleThemeColors(
    // Home screen colors
    mainText: const Color(0xFFD4C3AE),  // Light leather
    secondaryText: const Color(0xFFAA9884),  // Medium leather
    cardBackground: const Color(0xFF3C2A1E),  // Rich leather brown
    backgroundColor: const Color(0xFF2C1810),  // Deep leather
    dividerColor: const Color(0xFFAA9884).withOpacity(0.2),
    shadowColor: Colors.black.withOpacity(0.15),
    statBoxBackground: const Color(0xFF4A3728),  // Medium-dark brown

    // Game colors
    correctTile: Color(0xFF2C6E49),  // Emerald green
    wrongPositionTile: Color(0xFFE5A343),  // Amber orange
    tileText: Color(0xFFF5E6D3),  // Warm cream
    emptyTile: const Color(0xFF3C2A1E),  // Matching card background
    wrongTile: const Color(0xFF725544),  // Distinct darker leather for wrong tiles
    borderColor: const Color(0xFF8B7355),  // Medium leather
    textColor: const Color(0xFFE6D5BC),  // Light parchment
    keyboardDefault: const Color(0xFF4A3728),  // Rich brown
    
    // Message colors
    errorBackground: const Color(0xFF8B2525),  // Darker version of crimson
    errorText: const Color(0xFFFBEBEB),        // Light pink-red

    // Dialog colors
    dialogBackground: const Color(0xFF3C2A1E),  // Rich leather brown
    dialogButton: const Color(0xFF6B4423),  // Deeper brown
    dialogButtonText: const Color(0xFFE6D5BC),  // Light parchment
    overlayBackground: const Color(0xFF3C2A1E),  // Rich leather brown for overlays
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      primarySwatch: Colors.brown,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightTheme.backgroundColor,
      dialogBackgroundColor: lightTheme.dialogBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: lightTheme.backgroundColor,
        foregroundColor: lightTheme.textColor,
        elevation: 0,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.brown,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkTheme.backgroundColor,
      dialogBackgroundColor: darkTheme.dialogBackground,
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

  final Color dialogBackground;
  final Color dialogButton;
  final Color dialogButtonText;
  final Color overlayBackground;

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
    required this.dialogBackground,
    required this.dialogButton,
    required this.dialogButtonText,
    required this.overlayBackground,
  });
}