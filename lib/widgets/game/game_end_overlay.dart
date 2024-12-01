import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';

class GameEndOverlay extends StatefulWidget {
  final bool won;
  final String answer;
  final int attempts;
  final VoidCallback onBackToMenu;
  final VoidCallback onRestart; // Handles game restart
  final List<TileState> lastAttemptStates;

  const GameEndOverlay({
    super.key,
    required this.won,
    required this.answer,
    required this.attempts,
    required this.onBackToMenu,
    required this.onRestart,
    required this.lastAttemptStates,
  });

  @override
  State<GameEndOverlay> createState() => _GameEndOverlayState();
}

class _GameEndOverlayState extends State<GameEndOverlay> with SingleTickerProviderStateMixin {
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

    Future.delayed(const Duration(milliseconds: 2500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLoseMessage() {
    int closeLetters = widget.lastAttemptStates.where(
      (state) => state == TileState.correct || state == TileState.wrongPosition
    ).length;
    return closeLetters >= 3 ? '¡Casi!' : '¡Inténtalo de nuevo!';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? WordleColors.darkTheme : WordleColors.lightTheme;

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Semi-transparent background
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
                        constraints: const BoxConstraints(maxWidth: 400),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.won ? '¡Felicitaciones!' : _getLoseMessage(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (widget.won)
                                Text(
                                  'Adivinaste la palabra en ${widget.attempts} ${widget.attempts == 1 ? 'intento' : 'intentos'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.textColor.withOpacity(0.7),
                                    decoration: TextDecoration.none,
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    Text(
                                      'La palabra era',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colors.textColor.withOpacity(0.7),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.answer,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textColor,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: widget.onRestart,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.correctTile,
                                        foregroundColor: colors.tileText,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Jugar de Nuevo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: widget.onBackToMenu,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.won 
                                            ? colors.correctTile 
                                            : colors.wrongTile,
                                        foregroundColor: colors.tileText,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Volver al Menú Principal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}