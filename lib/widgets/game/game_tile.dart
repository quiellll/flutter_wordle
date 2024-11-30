import 'package:flutter/material.dart';
import '../../models/models.dart';

class GameTile extends StatelessWidget {
  final String letter;
  final TileState state;

  const GameTile({
    super.key,
    required this.letter,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getColorForState(state),
        border: Border.all(
          color: state == TileState.empty ? Colors.grey : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: state == TileState.empty ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Color _getColorForState(TileState state) {
    switch (state) {
      case TileState.correct:
        return Colors.green;
      case TileState.wrongPosition:
        return Colors.orange;
      case TileState.wrong:
        return Colors.grey;
      case TileState.empty:
        return Colors.white;
    }
  }
}