import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/validation_provider.dart';
import '../widgets/game/game_board.dart';
import '../widgets/game/game_keyboard.dart';
import '../widgets/theme/theme_toggle.dart';
import '../widgets/effects/popper_generator.dart';

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

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late ValidationProvider provider;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    provider = ValidationProvider(language: widget.language);
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
  }

  @override void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                  if (provider.validationMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red.shade100,
                    child: Text(
                      provider.validationMessage,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
        ),
        for (final direction in [PopDirection.forwardX, PopDirection.backwardX])
          Positioned.fill(
            child: PartyPopperGenerator(
              direction: direction,
              motionCurveX: PopperConfig.motionCurveX,
              motionCurveY: PopperConfig.motionCurveY,
              controller: _confettiController,
              numbers: PopperConfig.defaultProps['numbers'] as int,
              posX: PopperConfig.defaultProps['posX'] as double,
              posY: PopperConfig.defaultProps['posY'] as double,
              pieceHeight: PopperConfig.defaultProps['pieceHeight'] as double,
              pieceWidth: PopperConfig.defaultProps['pieceWidth'] as double,
            ),
          ),
      ],
    );
  }

  void _handleSubmit() {
  final result = provider.submitAttempt();
  switch (result) {
    case ValidationResult.win:
    // Wait for tiles to stop flipping (HARDCODED TRASH idgaf its 1:10 am and im working my ass off for some confetti lol)
      Future.delayed(const Duration(milliseconds: 1200), () {
        _confettiController.forward().then((_) {
          // Wait for the confetti to drop before showing results
          Future.delayed(const Duration(milliseconds:500), () {
          _confettiController.reset();
          _showGameEndDialog(true);
          });
        });
      });
      widget.onGameComplete?.call(true, provider.attempts.length);
      break;
    case ValidationResult.end:
      _showGameEndDialog(false);
      widget.onGameComplete?.call(false, provider.attempts.length);
      break;
    case ValidationResult.continue_:
      break;
    case ValidationResult.invalid:
    case ValidationResult.notInWordList:
      // These are handled by the validation messages in the provider
      break;
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