import 'package:flutter/material.dart';
import 'package:flutter_wordle/models.dart';

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
                    _buildSpecialKey('ENTER', onEnter),
                  ...row.map((letter) => _buildKey(letter)),
                  if (row == layout.last)
                    _buildSpecialKey('⌫', onBackspace),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String letter) {
    Color getKeyColor() {
      switch (keyStates[letter]) {
        case KeyState.correct:
          return Colors.green;
        case KeyState.wrongPosition:
          return Colors.orange;
        case KeyState.wrong:
          return Colors.grey;
        default:
          return Colors.grey.shade300;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: getKeyColor(),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => onKeyTap(letter),
          child: Container(
            width: 32,
            height: 48,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 48,
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}