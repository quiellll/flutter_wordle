import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../theme/theme_provider.dart';
import '../theme/theme_colors.dart';

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
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final colors = isDarkMode ? WordleColors.darkTheme : WordleColors.lightTheme;

    return Container(
      margin: const EdgeInsets.all(2),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getColorForState(state, isDarkMode),
        border: Border.all(
          color: state == TileState.empty ? colors.borderColor : Colors.transparent,
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
          color: _getTextColor(state, isDarkMode),
        ),
      ),
    );
  }

  Color _getColorForState(TileState state, bool isDarkMode) {
    final colors = isDarkMode ? WordleColors.darkTheme : WordleColors.lightTheme;

    switch (state) {
      case TileState.correct:
        return colors.correctTile;
      case TileState.wrongPosition:
        return colors.wrongPositionTile;
      case TileState.wrong:
        return colors.wrongTile;
      case TileState.empty:
        return colors.emptyTile;
    }
  }

  Color _getTextColor(TileState state, bool isDarkMode) {
    final colors = isDarkMode ? WordleColors.darkTheme : WordleColors.lightTheme;

    if (state == TileState.empty) {
      return colors.textColor;  // Use the theme's text color instead of emptyTile
    }
    return colors.tileText;
  }
}