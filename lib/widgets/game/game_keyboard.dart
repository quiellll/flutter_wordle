import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

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
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
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
                    _buildSpecialKey('ENTER', onEnter, isDarkMode),
                  ...row.map((letter) => _buildKey(letter, isDarkMode)),
                  if (row == layout.last)
                    _buildSpecialKey('⌫', onBackspace, isDarkMode),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String letter, bool isDarkMode) {
    Color getKeyColor() {
      switch (keyStates[letter]) {
        case KeyState.correct:
          return Colors.green;
        case KeyState.wrongPosition:
          return Colors.orange;
        case KeyState.wrong:
          return isDarkMode ? Colors.grey.shade800 : Colors.grey;
        default:
          return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
      }
    }

    final keyColor = getKeyColor();
    final textColor = isDarkMode || 
                     keyStates[letter] == KeyState.correct || 
                     keyStates[letter] == KeyState.wrongPosition 
        ? Colors.white 
        : Colors.black;

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

  Widget _buildSpecialKey(String text, VoidCallback onTap, bool isDarkMode) {
    final backgroundColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black;

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