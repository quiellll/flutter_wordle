import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildExampleTile(String letter, TileState state, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? WordleColors.darkTheme : WordleColors.lightTheme;

    Color getBackgroundColor() {
      switch (state) {
        case TileState.correct:
          return colors.correctTile;
        case TileState.wrongPosition:
          return colors.wrongPositionTile;
        case TileState.wrong:
          return colors.wrongTile;
        default:
          return colors.emptyTile;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: getBackgroundColor(),
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
          color: state == TileState.empty ? colors.textColor : colors.tileText,
          decoration: TextDecoration.none,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildExampleRow(List<TileState> states, String word, String explanation, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            word.length,
            (index) => _buildExampleTile(word[index], states[index], context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          explanation,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
            decoration: TextDecoration.none,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? WordleColors.darkTheme : WordleColors.lightTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Opacity(
              opacity: _fadeAnimation.value * 0.5,
              child: Container(color: Colors.black),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                      decoration: BoxDecoration(
                        color: isDark ? colors.emptyTile : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Cómo Jugar',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textColor,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Adivina la palabra oculta en seis intentos.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.textColor.withOpacity(0.7),
                                  decoration: TextDecoration.none,
                                  height: 1.4,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cada intento debe ser una palabra válida de cinco letras.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.textColor.withOpacity(0.7),
                                  decoration: TextDecoration.none,
                                  height: 1.4,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Ejemplos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textColor,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildExampleRow(
                                [TileState.correct, ...List.filled(4, TileState.empty)],
                                'GATOS',
                                'La letra G está en la palabra y en la posición correcta.',
                                context,
                              ),
                              _buildExampleRow(
                                [TileState.empty, TileState.wrongPosition, ...List.filled(3, TileState.empty)],
                                'VOCAL',
                                'La letra O está en la palabra pero en otra posición.',
                                context,
                              ),
                              _buildExampleRow(
                                List.filled(5, TileState.wrong),
                                'PISTA',
                                'Ninguna de estas letras está en la palabra.',
                                context,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.correctTile,
                                    foregroundColor: colors.tileText,
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '¡Entendido!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}