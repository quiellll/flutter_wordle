import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../theme/theme_provider.dart';
import '../theme/theme_colors.dart';

class GameTile extends StatefulWidget {
  final String letter;
  final TileState state;
  final int position;

  const GameTile({
    super.key,
    required this.letter,
    required this.state,
    required this.position,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  TileState? _previousState;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipped = true;
        });
        _controller.reverse();
      }
    });

    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi/2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _previousState = widget.state;
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset flip state if tile becomes empty
    if (widget.state == TileState.empty && oldWidget.state != TileState.empty) {
      setState(() {
        _isFlipped = false;
      });
    }
    // Normal flip animation for non-empty states
    else if (widget.state != _previousState &&
        _previousState == TileState.empty &&
        widget.state != TileState.empty) {
      _isFlipped = false;
      Future.delayed(Duration(milliseconds: widget.position * 200), () {
        if (mounted) {
          _controller.forward(from: 0);
        }
      });
    }
    _previousState = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final colors = isDarkMode ? WordleColors.darkTheme : WordleColors.lightTheme;

    // Force unflipped state for empty tiles
    final isEffectivelyFlipped = _isFlipped && widget.state != TileState.empty;

    // Get background color based on state
    final backgroundColor = isEffectivelyFlipped 
        ? widget.state == TileState.correct 
            ? colors.correctTile
            : widget.state == TileState.wrongPosition 
                ? colors.wrongPositionTile
                : colors.wrongTile
        : colors.emptyTile;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_flipAnimation.value),
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: !isEffectivelyFlipped || widget.state == TileState.empty 
                    ? colors.borderColor 
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isEffectivelyFlipped 
                    ? colors.tileText
                    : colors.textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}