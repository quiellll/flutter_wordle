import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  final List<String> attempts;
  final String currentAttempt;
  final List<List<TileState>> tileStates;
  
  const GameBoard({
    super.key,
    required this.attempts,
    required this.currentAttempt,
    required this.tileStates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (row) {
          String displayText = row < attempts.length 
              ? attempts[row]
              : row == attempts.length 
                  ? currentAttempt.padRight(5)
                  : '     ';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (col) => GameTile(
                  letter: displayText[col],
                  state: tileStates[row][col],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
