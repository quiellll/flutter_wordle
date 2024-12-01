import 'package:flutter/material.dart';

class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;

  SlideRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: direction == SlideDirection.up 
    ? const Duration(milliseconds: 500)  // Slower for going to game
    : const Duration(milliseconds: 300), // Keep original speed for going back
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.right:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.left:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = const Offset(0.0, -1.0);
          break;
        case SlideDirection.down:
          begin = const Offset(0.0, 1.0);
          break;
      }

      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );
    },
  );
}

enum SlideDirection {
  right,
  left,
  up,
  down,
}