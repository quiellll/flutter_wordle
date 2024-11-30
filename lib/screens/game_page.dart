import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/validation_provider.dart';
import '../widgets/game/game_board.dart';
import '../widgets/game/game_keyboard.dart';
import '../widgets/theme/theme_toggle.dart';

class GamePage extends StatefulWidget {
  final Language language;
  final Function(bool won, int attemts)? onGameComplete;

  const GamePage({
    super.key,
    required this.language,
    this.onGameComplete,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late ValidationProvider provider;

  @override
  void initState() {
    super.initState();
    provider = ValidationProvider(language: widget.language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle'),
        centerTitle: true,
        actions: const [
          ThemeToggle(),
        ],
      ),
      body: ListenableBuilder(
        listenable: provider,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: GameBoard(
                  attempts: provider.attempts,
                  currentAttempt: provider.currentInput,
                  tileStates: provider.tileStates,
                ),
              ),
              GameKeyboard(
                language: provider.language,
                keyStates: provider.keyStates,
                onKeyTap: provider.addLetter,
                onBackspace: provider.removeLetter,
                onEnter: _handleSubmit,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSubmit() {
    final result = provider.submitAttempt();
    if (result == ValidationResult.win) {
      _showGameEndDialog(true);
      // Call the callback with game results
      widget.onGameComplete?.call(true, provider.attempts.length);
    } else if (provider.gameEnded) {
      _showGameEndDialog(false);
      // Call the callback with game results
      widget.onGameComplete?.call(false, 6); // Max attempts reached
    }
  }

  void _showGameEndDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '¡Ganaste!' : 'Game Over'),
        content: Text(won 
          ? 'Felicitaciones, adivinaste la palabra!'
          : 'La palabra era: ${provider.answer}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to main menu
            },
            child: const Text('Volver al menú'),
          ),
        ],
      ),
    );
  }
}