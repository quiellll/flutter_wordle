import 'package:flutter/material.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';
import '../models/models.dart';
import '../services/validation_provider.dart';
import '../widgets/game/game_board.dart';
import '../widgets/game/game_keyboard.dart';
import '../widgets/game/game_end_overlay.dart';
import '../widgets/theme/theme_toggle.dart';
import '../widgets/effects/popper_generator.dart';

class GamePage extends StatefulWidget {
  final Language language;
  final Function(bool won, int attempts)? onGameComplete;

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
  
  String _currentMessage = '';
  bool _isMessageVisible = false;
  Widget? overlayWidget;

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
            actions: [
              const ThemeToggle(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRestart,
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 50,
                child: AnimatedBuilder(
                  animation: _messageController,
                  builder: (context, child) {
                    final colors = Theme.of(context).brightness == Brightness.dark
                        ? WordleColors.darkTheme
                        : WordleColors.lightTheme;
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
                                  color: colors.errorBackground,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _currentMessage,
                                    style: TextStyle(
                                      color: colors.errorText,
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
        if (overlayWidget != null) overlayWidget!,
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
    }
  }

  void _handleSubmit() {
  final result = provider.submitAttempt();
  switch (result) {
    case ValidationResult.win:
      // Update stats immediately
      widget.onGameComplete?.call(true, provider.attempts.length);
      
      // Then handle animations
      Future.delayed(const Duration(milliseconds: 1200), () {
        _confettiController.forward();
      });
      _showGameEndOverlay(true);
      break;
      
    case ValidationResult.end:
      // Update stats immediately
      widget.onGameComplete?.call(false, provider.attempts.length);
      _showGameEndOverlay(false);
      break;
      
    case ValidationResult.continue_:
    case ValidationResult.invalid:
    case ValidationResult.notInWordList:
      break;
  }
}

  void _handleRestart() {
    setState(() {
      overlayWidget = null;
      _confettiController.reset();
      _currentMessage = '';
      _isMessageVisible = false;
      _messageController.reset();
      
      // Remove old listener
      provider.removeListener(_handleValidationMessage);
      
      // Create new provider with fresh state
      provider = ValidationProvider(language: widget.language);
      provider.addListener(_handleValidationMessage);
    });
  }

  void _showGameEndOverlay(bool won) {
    setState(() {
      overlayWidget = GameEndOverlay(
        won: won,
        answer: provider.answer,
        attempts: provider.attempts.length,
        onBackToMenu: () => Navigator.of(context).pop(),
        onRestart: _handleRestart,
        lastAttemptStates: provider.tileStates[provider.attempts.length - 1],
      );
    });
  }
}