import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';

class GameKeyboard extends StatelessWidget {
  final Language language;
  final Map<String, KeyState> keyStates;
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;

  const GameKeyboard({
    super.key,
    required this.language,
    required this.keyStates,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme colors through the public static final properties
    final colors = Theme.of(context).brightness == Brightness.dark
        ? WordleColors.darkTheme
        : WordleColors.lightTheme;

    final List<List<String>> layout = language == Language.english ? 
      [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
      ] : 
      [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
        ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
      ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          for (var row in layout)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (row == layout.last) 
                    _buildSpecialKey('➔', onEnter, colors),
                  ...row.map((letter) => _buildKey(letter, colors)),
                  if (row == layout.last)
                    _buildSpecialKey('⌫', onBackspace, colors),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String letter, Object colors) {
    // Get theme-specific colors
    final themeColors = colors as dynamic;
    
    Color getKeyColor() {
      switch (keyStates[letter]) {
        case KeyState.correct:
          return themeColors.correctTile;
        case KeyState.wrongPosition:
          return themeColors.wrongPositionTile;
        case KeyState.wrong:
          return themeColors.wrongTile;
        default:
          return themeColors.keyboardDefault;
      }
    }

    final keyColor = getKeyColor();
    final textColor = keyStates[letter] == KeyState.correct || 
                     keyStates[letter] == KeyState.wrongPosition
        ? themeColors.tileText 
        : themeColors.textColor;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: keyColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => onKeyTap(letter),
          child: Container(
            width: 32,
            height: 48,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String text, VoidCallback onTap, Object colors) {
    // Get theme-specific colors
    final themeColors = colors as dynamic;
    final backgroundColor = themeColors.keyboardDefault;
    final textColor = themeColors.textColor;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 48,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}