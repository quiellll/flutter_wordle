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
  late AnimationController _messageController;
  late Animation<double> _messageSlide;
  late Animation<double> _messageFade;
  late Animation<double> _messageRotate;
  
  // Keep track of the current message and visibility
  String _currentMessage = '';
  bool _isMessageVisible = false;

  @override
  void initState() {
    super.initState();
    provider = ValidationProvider(language: widget.language);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _messageSlide = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));
    
    _messageFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ));

    _messageRotate = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _messageController.addStatusListener(_handleAnimationStatus);
    provider.addListener(_handleValidationMessage);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      // Only hide the message when the animation is completely finished
      setState(() {
        _isMessageVisible = false;
        _currentMessage = '';
      });
    }
  }

  @override 
  void dispose() {
    _confettiController.dispose();
    _messageController.removeStatusListener(_handleAnimationStatus);
    _messageController.dispose();
    provider.removeListener(_handleValidationMessage);
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
          body: Column(
            children: [
              // Animated validation message
              SizedBox(
                height: 50,
                child: AnimatedBuilder(
                  animation: _messageController,
                  builder: (context, child) {
                    return ClipRect(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_messageRotate.value)
                          ..translate(0.0, _messageSlide.value * 50.0),
                        alignment: Alignment.topCenter,
                        child: _isMessageVisible
                            ? Opacity(
                                opacity: _messageFade.value,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  padding: const EdgeInsets.all(8.0),
                                  color: Colors.red.shade100,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _currentMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ),
              // Rest of the game content remains the same...
              Expanded(
                child: ListenableBuilder(
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
              ),
            ],
          ),
        ),
        // Confetti layer
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

  void _handleValidationMessage() {
    final newMessage = provider.validationMessage;
    if (newMessage.isNotEmpty) {
      setState(() {
        _currentMessage = newMessage;
        _isMessageVisible = true;
      });
      _messageController.forward();
    } else {
      _messageController.reverse();
      // Note: We don't clear the message here, we wait for animation to complete
    }
  }

  void _handleSubmit() {
    final result = provider.submitAttempt();
    switch (result) {
      case ValidationResult.win:
        Future.delayed(const Duration(milliseconds: 1200), () {
          _confettiController.forward().then((_) {
            Future.delayed(const Duration(milliseconds: 500), () {
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